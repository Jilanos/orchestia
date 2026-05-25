# PN-0005: Job Offer Parsing

## Metadata

- ID: PN-0005
- Status: complete
- Initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Related request: [REQ-0006 Job Offer Parsing](../requests/REQ-0006-job-offer-parsing.md)
- Related backlog items: [BL-0008 Job Offer Parsing](../backlog/BL-0008-job-offer-parsing.md)
- Related tasks: [TASK-0046 Implement Job Offer Parsing](../tasks/TASK-0046-implement-job-offer-parsing.md)

## Need Statement

Improve parsing for manually provided job offer text and Markdown so common title, company, location, responsibilities, requirements, benefits, keywords, and red flags are extracted more reliably.

## Completion Criteria

- Parsing remains transparent and heuristic.
- Parser handles multiple manually provided text/Markdown formats.
- Tests cover representative input shapes.
- No web scraping, browser automation, LinkedIn API use, external API, or dependency install is introduced.

## Blockers

- None.

## Status

Allowed values: proposed, accepted, in_progress, complete, blocked, out_of_scope.

- Status: complete

## Review Notes

- Accepted by [REVIEW-0043 Job Offer Parsing Execution](../reviews/REVIEW-0043-job-offer-parsing-execution.md).
- Implemented in local project commit `22d431b Improve job offer parsing`.
- Auto-loop evidence: `task-runs/20260525T130053Z-auto-loop/`.
