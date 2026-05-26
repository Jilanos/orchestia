# REQ-0007: Job Offer Scoring

## Metadata

- ID: REQ-0007
- Status: Accepted
- Initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Primary need: [PN-0006 Job Offer Scoring](../primary-needs/PN-0006-job-offer-scoring.md)
- Proposed backlog item: [BL-0009 Job Offer Scoring](../backlog/BL-0009-job-offer-scoring.md)

## Problem Statement

`job-offer-analyzer` can parse manually provided job offers into structured fields, but it does not yet provide a transparent fit score. The next need is deterministic local scoring that helps a user prioritize an offer without using external services.

## Success Criteria

- Score a job offer based on transparent local heuristics.
- Include score categories:
  - technical fit
  - seniority fit
  - work mode fit
  - role clarity
  - red flag penalty
- Output a simple total score.
- Output a short recommendation.
- Use no AI API.
- Add no external dependency.
- Add no scraping or browser automation.

## Constraints

- Work only from user-provided local files.
- Python standard library only.
- Preserve existing CLI compatibility.
- Keep scoring deterministic and explainable.
- Keep compliance boundaries explicit.

## Non-Goals

- No LinkedIn scraping.
- No browser automation.
- No external API or AI API calls.
- No user profile persistence yet.
- No generated Markdown report yet.
- No project remote, push, or merge.

## Proposed Backlog Item

- [BL-0009 Job Offer Scoring](../backlog/BL-0009-job-offer-scoring.md)

## Status

- Status: Accepted

## Result

- Accepted by [REVIEW-0045 Job Offer Scoring Execution](../reviews/REVIEW-0045-job-offer-scoring-execution.md).
- Implemented in local `job-offer-analyzer` commit `c37d597 Add job offer scoring`.
- Autonomous-loop evidence: `task-runs/20260526T084858Z-autonomous-loop/`.
