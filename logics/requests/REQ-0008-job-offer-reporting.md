# REQ-0008: Job Offer Reporting

## Metadata

- ID: REQ-0008
- Status: Accepted
- Initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Primary need: [PN-0007 Job Offer Reporting](../primary-needs/PN-0007-job-offer-reporting.md)
- Proposed backlog item: [BL-0010 Job Offer Reporting](../backlog/BL-0010-job-offer-reporting.md)

## Problem Statement

`job-offer-analyzer` can parse and score manually provided job offer files, but it does not yet produce a structured Markdown report that a user can save, review, or use to prepare recruiter questions.

## Success Criteria

- Generate a Markdown report from a manually provided job offer file.
- Include parsed fields.
- Include scoring details.
- Include red flags.
- Include recommendation.
- Include recruiter questions.
- Include next action suggestions.
- Allow stdout output.
- Allow optional local file output if simple.
- Use no AI API.
- Add no external dependency.
- Add no scraping or browser automation.

## Constraints

- Work only from user-provided local files.
- Python standard library only.
- Preserve existing CLI compatibility.
- Keep reporting deterministic and explainable.
- Keep compliance boundaries explicit.

## Non-Goals

- No LinkedIn scraping.
- No browser automation.
- No external API or AI API calls.
- No user profile persistence yet.
- No remote, push, or merge.
- No rich HTML or hosted UI report in this slice.

## Proposed Backlog Item

- [BL-0010 Job Offer Reporting](../backlog/BL-0010-job-offer-reporting.md)

## Status

- Status: Accepted

## Result

- Accepted by [REVIEW-0047 Job Offer Reporting Execution](../reviews/REVIEW-0047-job-offer-reporting-execution.md).
- Implemented in local `job-offer-analyzer` commit `dc6792f Add job offer reporting`.
- Autonomous-loop evidence: `task-runs/20260526T090931Z-autonomous-loop/`.
