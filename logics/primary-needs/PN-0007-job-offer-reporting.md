# PN-0007: Job Offer Reporting

## Metadata

- ID: PN-0007
- Status: complete
- Initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Related request: [REQ-0008 Job Offer Reporting](../requests/REQ-0008-job-offer-reporting.md)
- Related backlog items: [BL-0010 Job Offer Reporting](../backlog/BL-0010-job-offer-reporting.md)
- Related tasks: [TASK-0052 Implement Job Offer Reporting](../tasks/TASK-0052-implement-job-offer-reporting.md)

## Need Statement

Generate a local Markdown report that summarizes the job offer, fit signals, red flags, and suggested recruiter questions.

## Completion Criteria

- Report generation is local and deterministic.
- Output is Markdown.
- Report includes source-file reference, extracted fields, score explanation, red flags, and recruiter questions.
- No external services are used.

## Blockers

- None.

## Status

Allowed values: proposed, accepted, in_progress, complete, blocked, out_of_scope.

- Status: complete

## Review Notes

- Depends on parsing and scoring primary needs.
- Accepted by [REVIEW-0047 Job Offer Reporting Execution](../reviews/REVIEW-0047-job-offer-reporting-execution.md).
- Implemented in local project commit `dc6792f Add job offer reporting`.
- Autonomous-loop evidence: `task-runs/20260526T090931Z-autonomous-loop/`.
