# BL-0007: Job Offer Analyzer Foundation

## Metadata

- ID: BL-0007
- Status: Accepted
- Request: [REQ-0005 Job Offer Analyzer Foundation](../requests/REQ-0005-job-offer-analyzer-foundation.md)
- Primary need: [PN-0004 Job Offer Analyzer Foundation](../primary-needs/PN-0004-job-offer-analyzer-foundation.md)

## Delivery Slice

Create the first local repository scaffold, minimal CLI, sample input, product brief, README, and smoke tests.

## Included Tasks

- [TASK-0045 Initialize Job Offer Analyzer](../tasks/TASK-0045-initialize-job-offer-analyzer.md)

## Acceptance Criteria

- Local project exists at `/home/pmondou/ai-workspaces/job-offer-analyzer`.
- CLI help and sample analysis commands run.
- Tests pass.
- No scraping or external APIs are introduced.
- Local project has one commit and no remote.

## Dependencies

- None.

## Risks

- Initial parsing is intentionally heuristic and shallow.
- Future parsing must keep compliance boundaries explicit.

## Result

- Completed task: [TASK-0045 Initialize Job Offer Analyzer](../tasks/TASK-0045-initialize-job-offer-analyzer.md)
- Review: [REVIEW-0042 Job Offer Analyzer Initialization](../reviews/REVIEW-0042-job-offer-analyzer-initialization.md)
- Project commit: `6df941b Initialize job offer analyzer`
