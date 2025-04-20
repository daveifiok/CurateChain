

# CurateChain: Decentralized Content Curation Protocol

**CurateChain** is a Bitcoin-native content curation marketplace designed to connect high-quality submissions with engaged and thoughtful communities. By harnessing stacking-powered incentives and transparent reputation systems, CurateChain empowers contributors and curators to collaboratively surface the best content the web has to offer.

---

## Overview

CurateChain enables decentralized curation of content through an incentive-aligned protocol built on Clarity smart contracts. The protocol rewards participants for meaningful engagement and quality contribution, and penalizes manipulation, spam, and low-effort submissions.

At its core, CurateChain is a trustless reputation-driven marketplace — designed to maintain integrity, minimize gatekeeping, and create a sustainable feedback loop between content creators, curators, and audiences.

---

## Features

- **Decentralized Submissions:**  
  Contributors submit content under specific topics with an associated fee, encouraging thoughtful curation at the source.

- **Community Appraisals:**  
  Curators vote content up or down (`+1` / `-1`), directly affecting both the content’s visibility and their own credibility within the system.

- **Gratuity Rewards:**  
  Anyone can directly reward content creators with STX tokens for submissions they value.

- **Flagging Mechanism:**  
  Users can flag inappropriate or malicious content to signal it for review.

- **Reputation System:**  
  Both creators and appraisers build a reputation score over time, encouraging honest engagement.

- **Administrative Flexibility:**  
  Protocol administrators can adjust submission fees, manage content categories, and expunge malicious content when necessary.

---

## Core Concepts

| Feature                   | Purpose                                                             |
|----------------------------|----------------------------------------------------------------------|
| **Submission Charge**      | Deters spam by requiring an STX fee for content submissions.         |
| **Appraisals**             | Community-driven upvotes/downvotes influencing visibility and trust. |
| **Gratuities**             | Direct peer-to-peer tipping system rewarding content originators.    |
| **Flags**                  | Reporting system for malicious or inappropriate content.             |
| **Credibility Metric**     | Reputation tracking for each participant based on appraisal actions. |

---

## Key Functions

### Public Functions
- `contribute-item`: Submit new content.
- `appraise-item`: Upvote or downvote content with impact on personal reputation.
- `reward-originator`: Send STX tips directly to content authors.
- `flag-item`: Report problematic content for review.

### Read-Only Functions
- `retrieve-item-details`: Get detailed metadata about a content item.
- `retrieve-participant-appraisal`: Query your past appraisal of an item.
- `retrieve-aggregate-submissions`: Retrieve total number of submitted items.
- `retrieve-participant-credibility`: Get your or others’ reputation score.
- `retrieve-top-items`: Fetch high-quality, positively appraised content.

### Admin Functions
- `adjust-submission-charge`: Update the STX submission fee.
- `expunge-item`: Remove a specific item from the curated database.
- `introduce-topic`: Add a new valid content category to the system.

---

##  Protocol Constants

| Name                   | Description                                | Value                          |
|-------------------------|--------------------------------------------|--------------------------------|
| `MIN_HYPERLINK_LENGTH`  | Minimum length for valid hyperlinks.       | `10`                           |
| `MAX_UINT`              | Max uint value to prevent overflows.       | `340282366920938463463374607431768211455` |

---

##  Error Codes

| Code                 | Description                                            |
|-----------------------|--------------------------------------------------------|
| `u100`                | Unauthorized access attempt.                           |
| `u101`                | Invalid content submission.                            |
| `u102`                | Duplicate content entry.                               |
| `u103`                | Nonexistent content reference.                         |
| `u104`                | Inadequate STX balance for transaction.                |
| `u105`                | Invalid or unrecognized topic.                         |
| `u106`                | Invalid content flagging attempt.                      |
| `u107`                | Numerical overflow detected.                           |
| `u108`                | Invalid appraisal value (must be `1` or `-1`).          |
| `u109`                | Invalid content item identifier.                       |

---

## Security and Integrity

CurateChain is built with defense-in-depth principles:
- Immutable smart contract logic.
- Strict validation on all public inputs.
- Anti-spam economics through submission fees.
- Reputation-backed appraisal system.
- Admin-level controls for maintaining topic relevance and addressing abuse.

---

## Contributing

Contributions and community feedback are warmly welcomed!  
Open issues, suggest features, or submit pull requests to help shape the future of decentralized curation.

---

##  Final Thoughts

CurateChain is not just a protocol — it’s a vision for a fairer, signal-boosted web where valuable content isn’t drowned out by noise and manipulation. Join us in building a self-curating ecosystem, anchored by Bitcoin's security and designed for the long-term health of digital communities.

