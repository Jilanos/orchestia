# REQ-0006: Job Offer Parsing

## Metadata

- ID: REQ-0006
- Status: Accepted
- Initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Primary need: [PN-0005 Job Offer Parsing](../primary-needs/PN-0005-job-offer-parsing.md)
- Proposed backlog item: [BL-0008 Job Offer Parsing](../backlog/BL-0008-job-offer-parsing.md)

## Problem Statement

The initial `job-offer-analyzer` foundation can analyze a simple sample file, but parsing is shallow. The next need is a more reliable transparent parser for manually provided Markdown or plain text job descriptions.

## Success Criteria

- Manually provided job offer text can be parsed into structured fields.
- Parser handles Markdown and plain text.
- Parser extracts or guesses:
  - title
  - company
  - location
  - contract type
  - remote/hybrid/on-site mode
  - seniority
  - missions
  - requirements
  - technologies or keywords
  - languages
  - red flags
- Output stays transparent and heuristic.
- No scraping, browser automation, LinkedIn API, external API, AI API call, dependency install, or package metadata is introduced.

## Constraints

- Work only from user-provided local files.
- Python standard library only.
- Preserve existing CLI compatibility.
- Keep changes minimal and reviewable.
- Keep compliance boundaries explicit.

## Non-Goals

- No LinkedIn scraping.
- No browser automation.
- No external API or AI API calls.
- No scoring engine yet.
- No Markdown report generation yet.
- No project remote, push, or merge.

## Proposed Backlog Item

- [BL-0008 Job Offer Parsing](../backlog/BL-0008-job-offer-parsing.md)

## Result

- Accepted by [REVIEW-0043 Job Offer Parsing Execution](../reviews/REVIEW-0043-job-offer-parsing-execution.md).
- Implemented in local `job-offer-analyzer` commit `22d431b Improve job offer parsing`.
- Auto-loop evidence: `task-runs/20260525T130053Z-auto-loop/`.

## Status

- Status: Accepted
