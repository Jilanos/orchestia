# LS-0002: Job Offer Analyzer Loop State

## Metadata

- ID: LS-0002
- Status: active
- Initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Primary need: [PN-0006 Job Offer Scoring](../primary-needs/PN-0006-job-offer-scoring.md)

## Loop State

- Current initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Current primary need: [PN-0006 Job Offer Scoring](../primary-needs/PN-0006-job-offer-scoring.md)
- Current request: planned REQ for scoring
- Current backlog item: planned BL for scoring
- Current task: planned scoring task
- Prepared Codex prompt: None
- Last Codex run: local project commit `22d431b Improve job offer parsing`
- Last review: [REVIEW-0043 Job Offer Parsing Execution](../reviews/REVIEW-0043-job-offer-parsing-execution.md)
- Decision: accept
- Next action: prepare scoring task
- Stop condition: continue until all primary needs are complete or a firm blocker is documented

## Decision

Allowed values: accept, revise, split, reject.

- Decision: accept

## Recent Completed Step

- Completed primary need: [PN-0005 Job Offer Parsing](../primary-needs/PN-0005-job-offer-parsing.md)
- Completed request: [REQ-0006 Job Offer Parsing](../requests/REQ-0006-job-offer-parsing.md)
- Completed backlog item: [BL-0008 Job Offer Parsing](../backlog/BL-0008-job-offer-parsing.md)
- Completed task: [TASK-0046 Implement Job Offer Parsing](../tasks/TASK-0046-implement-job-offer-parsing.md)
- Auto-loop evidence: `task-runs/20260525T130053Z-auto-loop/`
- Project commit: `22d431b Improve job offer parsing`
- Review: [REVIEW-0043 Job Offer Parsing Execution](../reviews/REVIEW-0043-job-offer-parsing-execution.md)

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

- Prepare scoring request, backlog item, task, and Codex prompt.
