# TASK-0045: Initialize Job Offer Analyzer

## Metadata

- ID: TASK-0045
- Status: Complete
- Request: [REQ-0005 Job Offer Analyzer Foundation](../requests/REQ-0005-job-offer-analyzer-foundation.md)
- Backlog: [BL-0007 Job Offer Analyzer Foundation](../backlog/BL-0007-job-offer-analyzer-foundation.md)
- Review: [REVIEW-0042 Job Offer Analyzer Initialization](../reviews/REVIEW-0042-job-offer-analyzer-initialization.md)

## Objective

Initialize a new real mini project called `job-offer-analyzer` and register it as an Orchestia `v0.2-alpha` orchestration case.

## Context

The project validates Orchestia against a new real initial need after the `v0.2-alpha` release. The MVP must analyze manually provided job descriptions copied by the user, without scraping LinkedIn or automating browser access.

## Authorized Scope

- New local project under `/home/pmondou/ai-workspaces/job-offer-analyzer`
- New Orchestia Logics records for IN-0002, PN-0004 through PN-0008, REQ-0005, BL-0007, TASK-0045, REVIEW-0042, and LS-0002
- `docs/job-offer-analyzer-orchestration.md`
- Minimal update to `docs/mvp-roadmap.md`

## Out Of Scope

- Do not scrape LinkedIn.
- Do not automate browser access.
- Do not use external APIs.
- Do not install dependencies.
- Do not create or push a remote for `job-offer-analyzer`.
- Do not add package metadata.

## Expected Steps

1. Create the local project directory.
2. Initialize local Git.
3. Create Python standard-library CLI scaffold.
4. Add sample input, README, product brief, and tests.
5. Run checks.
6. Commit the local project.
7. Create Orchestia Logics records.
8. Verify and commit Orchestia records.

## Test Commands

```bash
cd /home/pmondou/ai-workspaces/job-offer-analyzer
python3 -m compileall src tests
python3 -m unittest discover -s tests
python3 -m src.job_offer_analyzer --help
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
git diff --check
```

## Acceptance Criteria

- Local project exists and is not under `/mnt/c`.
- CLI analyzes a local manually provided sample job file.
- Smoke tests pass.
- No scraping, browser automation, external API, dependency install, remote, or push is used.
- Orchestia Logics records are created.

## Watch Points

- Keep the parser heuristic and transparent.
- Do not imply LinkedIn integration.
- Do not collect personal data from LinkedIn.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not inspect credential stores or token files.
- Do not modify files outside the authorized scope.

## Result Summary

- Project path: `/home/pmondou/ai-workspaces/job-offer-analyzer`
- Project commit: `6df941b Initialize job offer analyzer`
- Files changed in project: README, `.gitignore`, CLI source, smoke tests, sample input, product brief
- Verification run: compileall, unittest, CLI help, sample analysis, diff check
- Diff summary: local project foundation created
- Remaining risks: parsing is intentionally minimal; next task should improve parser coverage
