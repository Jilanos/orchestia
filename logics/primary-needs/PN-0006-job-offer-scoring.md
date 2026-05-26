# PN-0006: Job Offer Scoring

## Metadata

- ID: PN-0006
- Status: complete
- Initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Related request: [REQ-0007 Job Offer Scoring](../requests/REQ-0007-job-offer-scoring.md)
- Related backlog items: [BL-0009 Job Offer Scoring](../backlog/BL-0009-job-offer-scoring.md)
- Related tasks: [TASK-0050 Implement Job Offer Scoring](../tasks/TASK-0050-implement-job-offer-scoring.md)

## Need Statement

Score manually provided job offers against user-defined local criteria such as desired keywords, location preferences, seniority fit, remote preference, and red flags.

## Completion Criteria

- User-defined criteria are local and simple.
- Scoring is explainable and deterministic.
- No external API or AI API call is used.
- Tests cover scoring behavior and edge cases.

## Blockers

- None.

## Status

Allowed values: proposed, accepted, in_progress, complete, blocked, out_of_scope.

- Status: complete

## Review Notes

- Accepted by [REVIEW-0045 Job Offer Scoring Execution](../reviews/REVIEW-0045-job-offer-scoring-execution.md).
- Implemented in local project commit `c37d597 Add job offer scoring`.
- Autonomous-loop evidence: `task-runs/20260526T084858Z-autonomous-loop/`.
