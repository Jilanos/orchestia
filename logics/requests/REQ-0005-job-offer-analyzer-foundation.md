# REQ-0005: Job Offer Analyzer Foundation

## Metadata

- ID: REQ-0005
- Status: Accepted
- Initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Primary need: [PN-0004 Job Offer Analyzer Foundation](../primary-needs/PN-0004-job-offer-analyzer-foundation.md)
- Proposed backlog item: [BL-0007 Job Offer Analyzer Foundation](../backlog/BL-0007-job-offer-analyzer-foundation.md)

## Problem Or Need Statement

The job offer analyzer needs a clean local project foundation before parsing, scoring, reporting, and validation work can proceed.

## Success Criteria

- Local Git repository is initialized.
- Minimal Python standard-library CLI exists.
- CLI can analyze a local manually provided sample file.
- README and product brief explain purpose, usage, no scraping policy, and limitations.
- Smoke tests pass.

## Constraints

- Local files only.
- No dependency install.
- No external APIs.
- No web scraping or browser automation.
- No LinkedIn API usage.
- No project remote yet.

## Non-Goals

- No robust parser yet.
- No scoring model yet.
- No Markdown report generation yet.
- No package metadata.
- No push or GitHub repository creation.

## Proposed Backlog Item

- [BL-0007 Job Offer Analyzer Foundation](../backlog/BL-0007-job-offer-analyzer-foundation.md)

## Result

- Accepted by [REVIEW-0042](../reviews/REVIEW-0042-job-offer-analyzer-initialization.md).
- Project commit: `6df941b Initialize job offer analyzer`.
