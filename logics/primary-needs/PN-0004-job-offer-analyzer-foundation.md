# PN-0004: Job Offer Analyzer Foundation

## Metadata

- ID: PN-0004
- Status: complete
- Initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Related request: [REQ-0005 Job Offer Analyzer Foundation](../requests/REQ-0005-job-offer-analyzer-foundation.md)
- Related backlog items: [BL-0007 Job Offer Analyzer Foundation](../backlog/BL-0007-job-offer-analyzer-foundation.md)
- Related tasks: [TASK-0045 Initialize Job Offer Analyzer](../tasks/TASK-0045-initialize-job-offer-analyzer.md)

## Need Statement

Create a clean local Python standard-library project foundation with a minimal CLI, sample input, smoke tests, and compliance documentation.

## Completion Criteria

- Local Git repository exists outside `/mnt/c`.
- Minimal Python CLI runs without installing dependencies.
- CLI can analyze a user-provided local Markdown job offer file.
- README and product brief document no scraping and manual input boundaries.
- Smoke tests pass.

## Blockers

- None.

## Status

Allowed values: proposed, accepted, in_progress, complete, blocked, out_of_scope.

- Status: complete

## Result

- Accepted by [REVIEW-0042](../reviews/REVIEW-0042-job-offer-analyzer-initialization.md).
- Project commit: `6df941b Initialize job offer analyzer`.
- Foundation complete; Loop state advanced to [PN-0005 Job Offer Parsing](PN-0005-job-offer-parsing.md).
