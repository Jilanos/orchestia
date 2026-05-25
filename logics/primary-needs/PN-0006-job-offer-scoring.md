# PN-0006: Job Offer Scoring

## Metadata

- ID: PN-0006
- Status: proposed
- Initial need: [IN-0002 Job Offer Analyzer](../initial-needs/IN-0002-job-offer-analyzer.md)
- Related request: planned REQ for scoring
- Related backlog items: planned BL for scoring
- Related tasks: planned scoring task

## Need Statement

Score manually provided job offers against user-defined local criteria such as desired keywords, location preferences, seniority fit, remote preference, and red flags.

## Completion Criteria

- User-defined criteria are local and simple.
- Scoring is explainable and deterministic.
- No external API or AI API call is used.
- Tests cover scoring behavior and edge cases.

## Blockers

- None.

## Status

Allowed values: proposed, accepted, in_progress, complete, blocked, out_of_scope.

- Status: proposed

## Review Notes

- Depends on more robust parsing from [PN-0005](PN-0005-job-offer-parsing.md).
