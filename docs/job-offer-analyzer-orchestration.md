# Job Offer Analyzer Orchestration

## Purpose

Register `job-offer-analyzer` as the first new real mini project validation case after Orchestia `v0.2-alpha`.

The project builds a local job offer analyzer for descriptions manually copied by the user from LinkedIn or other job boards.

## Project Path

```text
/home/pmondou/ai-workspaces/job-offer-analyzer
```

## Current Status

- Local project repository initialized.
- Foundation primary need accepted.
- Local project commit: `6df941b Initialize job offer analyzer`.
- Current Loop state: [LS-0002 Job Offer Analyzer](../logics/loop-states/LS-0002-job-offer-analyzer.md).
- Next primary need: [PN-0005 Job Offer Parsing](../logics/primary-needs/PN-0005-job-offer-parsing.md).

## Initial Need

[IN-0002 Job Offer Analyzer](../logics/initial-needs/IN-0002-job-offer-analyzer.md)

Analyze manually provided job offers copied from LinkedIn or other job boards. The MVP must work from user-provided text files, Markdown files, or pasted job descriptions only.

## Primary Need Decomposition

- [PN-0004 Job Offer Analyzer Foundation](../logics/primary-needs/PN-0004-job-offer-analyzer-foundation.md): complete.
- [PN-0005 Job Offer Parsing](../logics/primary-needs/PN-0005-job-offer-parsing.md): next.
- [PN-0006 Job Offer Scoring](../logics/primary-needs/PN-0006-job-offer-scoring.md): planned.
- [PN-0007 Job Offer Reporting](../logics/primary-needs/PN-0007-job-offer-reporting.md): planned.
- [PN-0008 Job Offer Validation Docs](../logics/primary-needs/PN-0008-job-offer-validation-docs.md): planned.

## Completed Foundation Work

- Created local Git repository.
- Added Python standard-library CLI.
- Added sample manually provided job offer Markdown file.
- Added smoke tests.
- Added README and product brief.
- Verified CLI help and sample analysis.
- Committed local project foundation.

## Next Planned Task

Prepare the parsing request, backlog item, task, and Codex prompt for robust heuristic parsing of manually provided job offer text.

## Constraints And Non-Goals

- Python standard library first.
- Local CLI first.
- Local files only.
- No external API.
- No AI API call.
- No dependency install.
- No browser automation.
- No package publishing yet.
- No project remote yet.

## No Scraping Policy

No scraping is allowed.

The project must not:

- scrape LinkedIn or any other job board;
- automate browser access;
- log in to LinkedIn;
- use LinkedIn APIs;
- collect personal data from LinkedIn;
- bypass platform rules;
- use browser cookies or credentials.

All input must be manually provided by the user as local text, Markdown, or pasted job descriptions.

## Validation Commands

```bash
cd /home/pmondou/ai-workspaces/job-offer-analyzer
python3 -m compileall src tests
python3 -m unittest discover -s tests
python3 -m src.job_offer_analyzer --help
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
git diff --check
```

## Known Risks

- Initial parser is intentionally minimal.
- Keyword detection is simple substring matching.
- Seniority detection is heuristic.
- Future scoring and reporting need explicit criteria and tests.
- Compliance boundaries must remain visible in every future task.
