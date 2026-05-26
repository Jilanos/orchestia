# REQ-0009: Job Offer Validation Docs

## Metadata

- ID: REQ-0009
- Status: Accepted
- Initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Primary need: [PN-0008 Job Offer Validation Docs](../primary-needs/PN-0008-job-offer-validation-docs.md)
- Proposed backlog item: [BL-0011 Job Offer Validation Docs](../backlog/BL-0011-job-offer-validation-docs.md)

## Problem Statement

`job-offer-analyzer` can parse, score, and report on manually provided job offer files, but the local MVP still needs stronger validation coverage and user-facing documentation before IN-0002 can be considered complete.

## Success Criteria

- All CLI commands are documented and tested.
- README clearly explains setup, usage, and manual input workflow.
- No-scraping policy is explicit.
- Limitations are documented.
- Validation checklist exists.
- Example input is realistic.
- Tests cover parsing, scoring, and reporting basics.
- No external dependency is added.
- No API integration is added.
- No scraping or browser automation is added.

## Constraints

- Work only from user-provided local files.
- Python standard library only.
- Preserve existing CLI compatibility.
- Keep validation and documentation minimal, transparent, and release-oriented.
- Keep compliance boundaries explicit.
- Do not add remotes, push, merge, or publish the local project.

## Non-Goals

- No LinkedIn scraping.
- No browser automation.
- No LinkedIn API usage.
- No external API or AI API calls.
- No dependency installation.
- No package publishing.
- No hosted UI or background service.
- No user profile or account integration.

## Proposed Backlog Item

- [BL-0011 Job Offer Validation Docs](../backlog/BL-0011-job-offer-validation-docs.md)

## Status

- Status: Accepted

## Result

- Accepted by [REVIEW-0049 Job Offer Validation Docs Execution](../reviews/REVIEW-0049-job-offer-validation-docs-execution.md).
- Implemented in local `job-offer-analyzer` commit `96efb67 Add validation and documentation`.
- Autonomous-loop evidence: `task-runs/20260526T101212Z-autonomous-loop/`.
