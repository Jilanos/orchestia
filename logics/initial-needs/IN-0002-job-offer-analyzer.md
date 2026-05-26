# IN-0002: Job Offer Analyzer

## Metadata

- ID: IN-0002
- Status: complete
- Created: 2026-05-25
- Review: [REVIEW-0042 Job Offer Analyzer Initialization](../reviews/REVIEW-0042-job-offer-analyzer-initialization.md)

## Original User Need

Build a local job offer analyzer for job descriptions copied manually from LinkedIn or other job boards.

The tool must work only from user-provided text files, Markdown files, or pasted job descriptions. It must not scrape LinkedIn, automate browser access, log in to LinkedIn, use LinkedIn APIs, collect personal data from LinkedIn, or bypass platform rules.

## Success Criteria

- A local repository exists at `/home/paulm/ai-workspaces/job-offer-analyzer`.
- The project can analyze a manually provided text or Markdown job offer file.
- The CLI reports basic title, company, location, keywords, rough seniority, red flags, and recommendation.
- The project clearly documents the no scraping policy.
- Future primary needs cover parsing, scoring, reporting, validation, and docs.

## Constraints

- Python standard library first.
- Local CLI first.
- Local files only.
- No external API.
- No AI API call.
- No dependency install.
- No web scraping.
- No browser automation.
- No LinkedIn API usage.

## Non-Goals

- No LinkedIn scraping.
- No automated browser access.
- No account login automation.
- No collection of personal data from LinkedIn.
- No platform-rule bypass.
- No GitHub repository or remote for the mini project yet.
- No package publishing.

## Primary Needs

- [x] [PN-0004 Job Offer Analyzer Foundation](../primary-needs/PN-0004-job-offer-analyzer-foundation.md)
- [x] [PN-0005 Job Offer Parsing](../primary-needs/PN-0005-job-offer-parsing.md)
- [x] [PN-0006 Job Offer Scoring](../primary-needs/PN-0006-job-offer-scoring.md)
- [x] [PN-0007 Job Offer Reporting](../primary-needs/PN-0007-job-offer-reporting.md)
- [x] [PN-0008 Job Offer Validation Docs](../primary-needs/PN-0008-job-offer-validation-docs.md)

## Global Status

Allowed values: intake, decomposed, in_progress, complete, blocked, cancelled.

- Status: complete

## Notes

- Foundation was accepted by [REVIEW-0042](../reviews/REVIEW-0042-job-offer-analyzer-initialization.md).
- Parsing, scoring, reporting, and validation/docs primary needs are complete.
- Completion accepted by [REVIEW-0050 Job Offer Analyzer Completion](../reviews/REVIEW-0050-job-offer-analyzer-completion.md).
- Final local project commit: `96efb67 Add validation and documentation`.
- Current Loop state: [LS-0002 Job Offer Analyzer](../loop-states/LS-0002-job-offer-analyzer.md).
