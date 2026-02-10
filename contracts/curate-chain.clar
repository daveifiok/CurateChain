;; Title: CurateChain - Decentralized Content Curation Protocol
;; Summary: A Bitcoin-native curation marketplace connecting quality content with engaged communities
;; Description: This protocol enables decentralized content curation through stacking-powered incentives, 
;; creating a sustainable reputation system for both content contributors and curators.

;; Core Constants
(define-constant PROTOCOL_ADMINISTRATOR tx-sender)

;; Error Codes
(define-constant ERR_UNAUTHORIZED_ACCESS (err u100))
(define-constant ERR_INVALID_SUBMISSION (err u101))
(define-constant ERR_DUPLICATE_ENTRY (err u102))
(define-constant ERR_NONEXISTENT_ITEM (err u103))
(define-constant ERR_INADEQUATE_BALANCE (err u104))
(define-constant ERR_INVALID_TOPIC (err u105))
(define-constant ERR_INVALID_FLAG (err u106))
(define-constant ERR_OVERFLOW (err u107))
(define-constant ERR_INVALID_APPRAISAL (err u108))
(define-constant ERR_INVALID_ITEM_ID (err u109))

;; Protocol Parameters
(define-constant MIN_HYPERLINK_LENGTH u10)
(define-constant MAX_UINT u340282366920938463463374607431768211455)

;; State Variables
(define-data-var submission-charge uint u10)
(define-data-var aggregate-submissions uint u0)
(define-data-var content-topics (list 10 (string-ascii 20)) (list "Technology" "Science" "Art" "Politics" "Sports"))

;; Data Storage Maps
(define-map curated-items 
  { item-identifier: uint } 
  { 
    originator: principal, 
    headline: (string-ascii 100), 
    hyperlink: (string-ascii 200), 
    topic: (string-ascii 20),
    publication-epoch: uint, 
    appraisals: int,
    gratuities: uint,
    flags: uint
  }
)

;; participant-credibility now tracks last-update for decay
(define-map participant-credibility
  { participant: principal }
  { metric: int, last-update: uint }
)

(define-map participant-appraisals 
  { participant: principal, item-identifier: uint } 
  { appraisal: int }
)

;; Private Helper Functions

(define-private (item-exists (item-identifier uint))
  (is-some (map-get? curated-items { item-identifier: item-identifier }))
)

(define-private (not-none (item (optional {
    originator: principal, 
    headline: (string-ascii 100), 
    hyperlink: (string-ascii 200), 
    topic: (string-ascii 20),
    publication-epoch: uint, 
    appraisals: int,
    gratuities: uint,
    flags: uint
  })))
  (is-some item)
)

(define-private (retrieve-item-if-valid (id uint))
  (match (map-get? curated-items { item-identifier: id })
    item (if (>= (get appraisals item) 0) (some item) none)
    none
  )
)

(define-private (enumerate (n uint))
  (let ((limit (if (> n u10) u10 n)))
    (list
      (if (>= limit u1) u1 u0)
      (if (>= limit u2) u2 u0)
      (if (>= limit u3) u3 u0)
      (if (>= limit u4) u4 u0)
      (if (>= limit u5) u5 u0)
      (if (>= limit u6) u6 u0)
      (if (>= limit u7) u7 u0)
      (if (>= limit u8) u8 u0)
      (if (>= limit u9) u9 u0)
      (if (>= limit u10) u10 u0)
    )
  )
)

(define-private (is-non-zero (n uint))
  (not (is-eq n u0))
)

;; Public Content Curation Functions

(define-public (contribute-item (headline (string-ascii 100)) (hyperlink (string-ascii 200)) (topic (string-ascii 20)))
  (let
    (
      (item-identifier (+ (var-get aggregate-submissions) u1))
    )
    (asserts! (and 
                (>= (len headline) u1)
                (>= (len hyperlink) MIN_HYPERLINK_LENGTH)
                (>= (len topic) u1)
              ) ERR_INVALID_SUBMISSION)
    (asserts! (> item-identifier (var-get aggregate-submissions)) ERR_OVERFLOW)
    (asserts! (is-some (index-of (var-get content-topics) topic)) ERR_INVALID_TOPIC)
    (asserts! (>= (stx-get-balance tx-sender) (var-get submission-charge)) ERR_INADEQUATE_BALANCE)
    (try! (stx-transfer? (var-get submission-charge) tx-sender PROTOCOL_ADMINISTRATOR))
    (map-set curated-items
      { item-identifier: item-identifier }
      {
        originator: tx-sender,
        headline: headline,
        hyperlink: hyperlink,
        topic: topic,
        publication-epoch: stacks-block-height,
        appraisals: 0,
        gratuities: u0,
        flags: u0
      }
    )
    (var-set aggregate-submissions item-identifier)
    (print { type: "new-item", item-identifier: item-identifier, originator: tx-sender })
    (ok item-identifier)
  )
)

(define-public (appraise-item (item-identifier uint) (appraisal int))
  (let
    (
      (previous-appraisal (default-to 0 (get appraisal (map-get? participant-appraisals { participant: tx-sender, item-identifier: item-identifier }))))
      (target-item (unwrap! (map-get? curated-items { item-identifier: item-identifier }) ERR_NONEXISTENT_ITEM))
      (appraiser-standing (default-to { metric: 0, last-update: stacks-block-height } (map-get? participant-credibility { participant: tx-sender })))
    )
    (asserts! (item-exists item-identifier) ERR_NONEXISTENT_ITEM)
    (asserts! (or (is-eq appraisal 1) (is-eq appraisal -1)) ERR_INVALID_APPRAISAL)

    ;; Update participant credibility before new appraisal
    (let ((elapsed (- stacks-block-height (get last-update appraiser-standing))))
      (let ((decay (u0))) ;; simple example: can be scaled as needed
        (map-set participant-credibility
          { participant: tx-sender }
          { metric: (max u0 (- (get metric appraiser-standing) decay)), last-update: stacks-block-height }
        )
      )
    )

    ;; Record appraisal
    (map-set participant-appraisals
      { participant: tx-sender, item-identifier: item-identifier }
      { appraisal: appraisal }
    )
    (map-set curated-items
      { item-identifier: item-identifier }
      (merge target-item { appraisals: (+ (get appraisals target-item) (- appraisal previous-appraisal)) })
    )
    ;; Update participant credibility with new appraisal
    (map-set participant-credibility
      { participant: tx-sender }
      { metric: (+ (get metric (default-to { metric: 0, last-update: stacks-block-height } (map-get? participant-credibility { participant: tx-sender }))) appraisal), last-update: stacks-block-height }
    )
    (print { type: "appraisal", item-identifier: item-identifier, appraiser: tx-sender, appraisal: appraisal })
    (ok true)
  )
)

;; New Feature: Time-Weighted Reputation Decay
(define-public (decay-participant-credibility (participant principal))
  (let ((standing (default-to { metric: 0, last-update: stacks-block-height } (map-get? participant-credibility { participant: participant }))))
    (let ((elapsed (- stacks-block-height (get last-update standing))))
      ;; Apply simple decay: 1 point per 100 blocks elapsed
      (let ((decay (/ elapsed u100)))
        (map-set participant-credibility
          { participant: participant }
          { metric: (max u0 (- (get metric standing) decay)), last-update: stacks-block-height }
        )
      )
    )
    (ok true)
  )
)

