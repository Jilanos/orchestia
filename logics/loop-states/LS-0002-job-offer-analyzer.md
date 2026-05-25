# LS-0002: Job Offer Analyzer Loop State

## Metadata

- ID: LS-0002
- Status: active
- Initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Primary need: [PN-0005 Job Offer Parsing](../primary-needs/PN-0005-job-offer-parsing.md)

## Loop State

- Current initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Current primary need: [PN-0005 Job Offer Parsing](../primary-needs/PN-0005-job-offer-parsing.md)
- Current request: planned REQ for parsing manually provided job offer text
- Current backlog item: planned BL for parsing manually provided job offer text
- Current task: planned parsing task
- Prepared Codex prompt: None
- Last Codex run: local project commit `6df941b Initialize job offer analyzer`
- Last review: [REVIEW-0042 Job Offer Analyzer Initialization](../reviews/REVIEW-0042-job-offer-analyzer-initialization.md)
- Decision: accept
- Next action: prepare parsing task
- Stop condition: continue until all primary needs are complete or a firm blocker is documented

## Decision

Allowed values: accept, revise, split, reject.

- Decision: accept

## Stop Condition

Allowed values:

- all primary needs complete
- remaining primary needs out of scope
- firm blocker reached
- human stop requested

- Stop condition: continue until all primary needs are complete or a firm blocker is documented

## Firm Blocker

- Blocker type: None
- Evidence: None
- Human decision needed: None

## Next Action

- Prepare parsing task for manually provided job offer text.
