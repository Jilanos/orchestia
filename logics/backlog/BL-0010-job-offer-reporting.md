# BL-0010: Job Offer Reporting

## Metadata

- ID: BL-0010
- Status: Accepted
- Request: [REQ-0008 Job Offer Reporting](../requests/REQ-0008-job-offer-reporting.md)
- Primary need: [PN-0007 Job Offer Reporting](../primary-needs/PN-0007-job-offer-reporting.md)

## Delivery Slice

Add a local Markdown reporting flow to `job-offer-analyzer` so a manually provided job offer file can produce a clear report with extracted fields, scoring details, red flags, recruiter questions, and next actions.

## Included Task

- [TASK-0052 Implement Job Offer Reporting](../tasks/TASK-0052-implement-job-offer-reporting.md)

## Acceptance Criteria

- CLI still works with `python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md`.
- A report command or report option works for `examples/job-offer-sample.md`.
- Report output includes Job Offer Report, Summary, Extracted Fields, Score, Strengths, Weaknesses, Red Flags, Recruiter Questions, Recommendation, and Next Actions.
- Tests cover report output.
- README, sample input, and product brief remain consistent with the no scraping policy.
- No dependency, package metadata, external API, scraping, browser automation, remote, push, or merge is added.

## Dependencies

- [PN-0005 Job Offer Parsing](../primary-needs/PN-0005-job-offer-parsing.md)
- [PN-0006 Job Offer Scoring](../primary-needs/PN-0006-job-offer-scoring.md)
- Project commit `c37d597 Add job offer scoring`

## Risks

- Report wording can overstate heuristic confidence if limitations are not visible.
- Recruiter questions may be generic until user-specific criteria are added.
- Optional file output must stay local and avoid path surprises.

## Status

- Status: Accepted

## Result

- Delivered by [TASK-0052 Implement Job Offer Reporting](../tasks/TASK-0052-implement-job-offer-reporting.md).
- Accepted by [REVIEW-0047 Job Offer Reporting Execution](../reviews/REVIEW-0047-job-offer-reporting-execution.md).
- Local project commit: `dc6792f Add job offer reporting`.
