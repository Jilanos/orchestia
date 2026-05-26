# TASK-0052: Implement Job Offer Reporting

## Metadata

- ID: TASK-0052
- Status: Complete
- Request: [REQ-0008 Job Offer Reporting](../requests/REQ-0008-job-offer-reporting.md)
- Backlog: [BL-0010 Job Offer Reporting](../backlog/BL-0010-job-offer-reporting.md)

## Objective

Add transparent local Markdown report generation to `job-offer-analyzer` for manually provided job offer files.

## Context

The project at `/home/pmondou/ai-workspaces/job-offer-analyzer` already parses and scores local Markdown or text job offers. The next primary need is a report that combines parsed fields, scoring details, red flags, recruiter questions, recommendation, and next action suggestions.

## Authorized Scope

Inside `/home/pmondou/ai-workspaces/job-offer-analyzer`, Codex may modify only:

- `README.md`
- `src/job_offer_analyzer/__main__.py`
- `tests/test_smoke.py`
- `examples/job-offer-sample.md`
- `docs/product-brief.md`

## Out Of Scope

- Do not modify Orchestia.
- Do not scrape LinkedIn.
- Do not automate browser access.
- Do not use LinkedIn APIs.
- Do not use external APIs or AI API calls.
- Do not install dependencies.
- Do not add package metadata.
- Do not add a remote, push, merge, rebase, tag, or force push.
- Do not read secrets or print environment variables.

## Expected Steps

1. Inspect the existing parser, scoring helpers, and CLI.
2. Add a deterministic Markdown report formatter.
3. Add a simple report command or report option while preserving the existing analyze command.
4. Include parsed fields, score details, strengths, weaknesses, red flags, recruiter questions, recommendation, and next actions.
5. Print the report to stdout by default.
6. Add optional local file output only if it stays simple.
7. Update sample input, README, product brief, and smoke tests as needed.
8. Run validation commands.

## Test Commands

```bash
python3 -m compileall src tests
python3 -m unittest discover -s tests
git diff --check
python3 -m src.job_offer_analyzer --help
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
python3 -m src.job_offer_analyzer report examples/job-offer-sample.md
```

## Acceptance Criteria

- Report output includes Job Offer Report, Summary, Extracted Fields, Score, Strengths, Weaknesses, Red Flags, Recruiter Questions, Recommendation, and Next Actions.
- Tests pass.
- Reporting is deterministic and explainable.
- Existing analysis command still works.
- No forbidden dependencies, imports, API use, scraping, or browser automation is introduced.
- The project remains local-only and has no remote.

## Watch Points

- Do not overstate score or parsing accuracy.
- Keep recruiter questions transparent and heuristic.
- Preserve existing command compatibility.
- Do not add files outside the authorized project scope.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not inspect credential stores or token files.
- Do not modify files outside the authorized scope.

## Result

- Result: accepted.
- Autonomous-loop run directory: `task-runs/20260526T090931Z-autonomous-loop/`.
- Cycle evidence: `task-runs/20260526T090931Z-autonomous-loop/cycle-001/`.
- Codex command used `codex exec --sandbox workspace-write`.
- Codex exit code: `0`.
- Test command: `python3 -m unittest discover -s tests`.
- Test exit code: `0`.
- Local project commit: `dc6792f Add job offer reporting`.
- Review: [REVIEW-0047 Job Offer Reporting Execution](../reviews/REVIEW-0047-job-offer-reporting-execution.md).
