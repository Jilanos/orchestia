# BL-0009: Job Offer Scoring

## Metadata

- ID: BL-0009
- Status: Accepted
- Request: [REQ-0007 Job Offer Scoring](../requests/REQ-0007-job-offer-scoring.md)
- Primary need: [PN-0006 Job Offer Scoring](../primary-needs/PN-0006-job-offer-scoring.md)

## Delivery Slice

Add transparent deterministic scoring to `job-offer-analyzer` so local manually provided job descriptions include fit categories, a total score, and a recommendation.

## Included Task

- [TASK-0050 Implement Job Offer Scoring](../tasks/TASK-0050-implement-job-offer-scoring.md)

## Acceptance Criteria

- CLI still works with `python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md`.
- Output includes Score, Technical fit, Seniority fit, Work mode fit, Role clarity, Red flag penalty, and Recommendation.
- Tests cover scoring behavior.
- README, sample input, and product brief remain consistent with the no scraping policy.
- No dependency, package metadata, external API, scraping, browser automation, remote, push, or merge is added.

## Dependencies

- [PN-0005 Job Offer Parsing](../primary-needs/PN-0005-job-offer-parsing.md)
- Project commit `22d431b Improve job offer parsing`

## Risks

- Scoring may imply more precision than the heuristics support.
- Parser errors can affect scoring quality.
- Future reporting must explain score inputs and limitations.

## Status

- Status: Accepted

## Result

- Delivered by [TASK-0050 Implement Job Offer Scoring](../tasks/TASK-0050-implement-job-offer-scoring.md).
- Accepted by [REVIEW-0045 Job Offer Scoring Execution](../reviews/REVIEW-0045-job-offer-scoring-execution.md).
- Local project commit: `c37d597 Add job offer scoring`.
