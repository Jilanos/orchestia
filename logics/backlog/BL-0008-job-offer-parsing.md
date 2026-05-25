# BL-0008: Job Offer Parsing

## Metadata

- ID: BL-0008
- Status: Accepted
- Request: [REQ-0006 Job Offer Parsing](../requests/REQ-0006-job-offer-parsing.md)
- Primary need: [PN-0005 Job Offer Parsing](../primary-needs/PN-0005-job-offer-parsing.md)

## Delivery Slice

Improve the parser in `job-offer-analyzer` so local Markdown and plain text job descriptions produce clearer structured output while remaining heuristic and dependency-free.

## Included Task

- [TASK-0046 Implement Job Offer Parsing](../tasks/TASK-0046-implement-job-offer-parsing.md)

## Acceptance Criteria

- CLI still works with `python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md`.
- Output includes title, company, location, contract, work mode, seniority, technologies, languages, missions, requirements, red flags, and recommendation.
- Tests cover the improved parser behavior.
- README, sample input, and product brief remain consistent with the no scraping policy.
- No dependency, package metadata, external API, scraping, browser automation, or project remote is added.

## Dependencies

- [PN-0004 Job Offer Analyzer Foundation](../primary-needs/PN-0004-job-offer-analyzer-foundation.md)
- Project commit `6df941b Initialize job offer analyzer`

## Risks

- Heuristics may overfit the sample input.
- Plain text formats vary widely.
- Future scoring should not depend on hidden or opaque parsing behavior.

## Result

- Delivered by [TASK-0046 Implement Job Offer Parsing](../tasks/TASK-0046-implement-job-offer-parsing.md).
- Accepted by [REVIEW-0043 Job Offer Parsing Execution](../reviews/REVIEW-0043-job-offer-parsing-execution.md).
- Local project commit: `22d431b Improve job offer parsing`.

## Status

- Status: Accepted
