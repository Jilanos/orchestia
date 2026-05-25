# TASK-0046: Implement Job Offer Parsing

## Metadata

- ID: TASK-0046
- Status: Complete
- Request: [REQ-0006 Job Offer Parsing](../requests/REQ-0006-job-offer-parsing.md)
- Backlog: [BL-0008 Job Offer Parsing](../backlog/BL-0008-job-offer-parsing.md)
- Review: [REVIEW-0043 Job Offer Parsing Execution](../reviews/REVIEW-0043-job-offer-parsing-execution.md)

## Objective

Improve `job-offer-analyzer` parsing so manually provided Markdown or plain text job descriptions produce structured, transparent, human-readable analysis.

## Context

The foundation project exists at `/home/pmondou/ai-workspaces/job-offer-analyzer` with commit `6df941b`. It currently has a minimal CLI and simple heuristic output. The next primary need is parser improvement while preserving compliance boundaries.

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

1. Inspect the existing CLI, sample, README, product brief, and tests.
2. Improve parsing with Python standard-library code only.
3. Support Markdown and plain text labels/headings.
4. Extract or infer title, company, location, contract, work mode, seniority, missions, requirements, technologies, languages, red flags, and recommendation.
5. Keep output human-readable and transparent.
6. Update sample input, README, product brief, and smoke tests as needed.
7. Run validation commands.

## Test Commands

```bash
python3 -m compileall src tests
python3 -m unittest discover -s tests
git diff --check
python3 -m src.job_offer_analyzer --help
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
```

## Acceptance Criteria

- Parser handles the updated sample job offer.
- CLI output includes all required sections.
- Tests pass.
- No forbidden dependencies, imports, API use, scraping, or browser automation is introduced.
- The project remains local-only and has no remote.

## Watch Points

- Do not overstate parsing accuracy.
- Keep all extraction heuristic and explainable.
- Preserve existing command compatibility.
- Do not add files outside the authorized project scope.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not inspect credential stores or token files.
- Do not modify files outside the authorized scope.

## Result

- Result: accepted.
- Auto-loop run directory: `task-runs/20260525T130053Z-auto-loop/`.
- Codex command used `codex exec --sandbox workspace-write`.
- Codex exit code: `0`.
- Test command: `python3 -m unittest discover -s tests`.
- Test exit code: `0`.
- Local project commit: `22d431b Improve job offer parsing`.
- Review: [REVIEW-0043 Job Offer Parsing Execution](../reviews/REVIEW-0043-job-offer-parsing-execution.md).
