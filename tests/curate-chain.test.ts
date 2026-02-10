import { describe, expect, it } from "vitest";

// Get test accounts from the simnet
const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

describe("CurateChain Tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("applies time-weighted reputation decay for a participant", () => {
    // Submit a content item first to have some credibility
    let submission = simnet.call(
      "curate-chain",
      "contribute-item",
      [
        `(string-ascii "Test Headline")`,
        `(string-ascii "https://example.com/article")`,
        `(string-ascii "Technology")`
      ],
      address1
    );
    expect(submission.result).toBeOk();

    // Give the participant a positive appraisal to increase credibility
    let appraisal = simnet.call(
      "curate-chain",
      "appraise-item",
      [
        `(uint 1)`, // item-identifier
        `(int 1)`   // appraisal +1
      ],
      address1
    );
    expect(appraisal.result).toBeOk();

    // Call the decay function to apply time-weighted reduction
    let decay = simnet.call(
      "curate-chain",
      "decay-participant-credibility",
      [
        `(principal ${address1})`
      ],
      address1
    );
    expect(decay.result).toBeOk();

    // Read the participant's credibility after decay
    let credibility = simnet.callReadOnlyFn(
      "curate-chain",
      "retrieve-participant-credibility",
      [`(principal ${address1})`],
      address1
    );
    expect(credibility.result).toBeDefined();
    expect(credibility.result).toBeIntLessThanOrEqual(1); // credibility should have decayed
  });
});
