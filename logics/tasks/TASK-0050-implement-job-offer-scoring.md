# TASK-0050: Implement Job Offer Scoring

## Metadata

- ID: TASK-0050
- Status: Complete
- Request: [REQ-0007 Job Offer Scoring](../requests/REQ-0007-job-offer-scoring.md)
- Backlog: [BL-0009 Job Offer Scoring](../backlog/BL-0009-job-offer-scoring.md)

## Objective

Add transparent local scoring heuristics to `job-offer-analyzer` for manually provided job offer files.

## Context

The project at `/home/pmondou/ai-workspaces/job-offer-analyzer` already parses local Markdown or text job offers. The next primary need is scoring against simple explainable signals while preserving the no scraping and no external API boundaries.

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

1. Inspect the existing parser and CLI output.
2. Add a small deterministic scoring data structure or helper.
3. Score technical fit, seniority fit, work mode fit, role clarity, and red flag penalty.
4. Add total score and a short recommendation to CLI output.
5. Keep scoring transparent and heuristic.
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

- CLI output includes Score, Technical fit, Seniority fit, Work mode fit, Role clarity, Red flag penalty, and Recommendation.
- Tests pass.
- Scoring is deterministic and explainable.
- No forbidden dependencies, imports, API use, scraping, or browser automation is introduced.
- The project remains local-only and has no remote.

## Watch Points

- Do not overstate score accuracy.
- Keep scoring separate from opaque or AI-based judgment.
- Preserve existing command compatibility.
- Do not add files outside the authorized project scope.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not inspect credential stores or token files.
- Do not modify files outside the authorized scope.

## Result

- Result: accepted.
- Autonomous-loop run directory: `task-runs/20260526T084858Z-autonomous-loop/`.
- Cycle evidence: `task-runs/20260526T084858Z-autonomous-loop/cycle-001/`.
- Codex command used `codex exec --sandbox workspace-write`.
- Codex exit code: `0`.
- Test command: `python3 -m unittest discover -s tests`.
- Test exit code: `0`.
- Local project commit: `c37d597 Add job offer scoring`.
- Review: [REVIEW-0045 Job Offer Scoring Execution](../reviews/REVIEW-0045-job-offer-scoring-execution.md).
