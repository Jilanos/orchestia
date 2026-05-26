# TASK-0051: Run Autonomous Loop Job Offer Analyzer

## Metadata

- ID: TASK-0051
- Status: Complete
- Related task: [TASK-0050 Implement Job Offer Scoring](TASK-0050-implement-job-offer-scoring.md)
- Review: [REVIEW-0046 Autonomous Loop Job Offer Analyzer](../reviews/REVIEW-0046-autonomous-loop-job-offer-analyzer.md)

## Objective

Run the autonomous local loop against `job-offer-analyzer` for the scoring primary need, then record evidence, review, and Loop state advancement.

## Context

The disposable autonomous-loop validation passed. This task validates the same mechanism on the real local mini project while preserving the product boundary: local files only, no scraping, no browser automation, no external APIs, no dependency install, and no project push or merge.

## Authorized Scope

- Orchestia scoring request, backlog, task, prompt, reviews, Loop state, and docs.
- `job-offer-analyzer` files authorized by TASK-0050.
- Ignored evidence under `task-runs/`.

## Autonomous-Loop Command

```bash
bash scripts/orchestia_loop.sh autonomous-loop \
  logics/loop-states/LS-0002-job-offer-analyzer.md \
  --workspace /home/pmondou/ai-workspaces/job-offer-analyzer \
  --max-cycles 1 \
  --execute-codex \
  --auto-accept-if-checks-pass \
  --advance-if-next-ready \
  --test "python3 -m unittest discover -s tests" \
  --instruction "Keep changes minimal. Do not scrape LinkedIn. Do not use external APIs. Stop if tests fail or next state is ambiguous."
```

## Run Evidence

- Autonomous-loop run directory: `task-runs/20260526T084858Z-autonomous-loop/`.
- Cycle evidence: `task-runs/20260526T084858Z-autonomous-loop/cycle-001/`.
- Cycle decision: `accept`.
- Codex exit code: `0`.
- Test exit code: `0`.

## Checks

```bash
python3 -m compileall src tests
python3 -m unittest discover -s tests
git diff --check
python3 -m src.job_offer_analyzer --help
python3 -m src.job_offer_analyzer analyze examples/job-offer-sample.md
test -z "$(git remote)"
```

All checks passed.

## Results

- Scoring was implemented and accepted.
- Local project commit: `c37d597 Add job offer scoring`.
- PN-0006 was marked complete.
- LS-0002 advanced to [PN-0007 Job Offer Reporting](../primary-needs/PN-0007-job-offer-reporting.md).

## Accepted Work

- Transparent scoring categories.
- Total score.
- Recommendation retained and backed by scoring details.
- Tests covering scoring output.
- README and product brief updated.

## Blockers

- None for scoring.
- Note: autonomous-loop could not auto-advance into reporting because no reporting prompt exists yet. Logics advancement was completed after review.

## Next Recommended Task

Prepare the reporting request, backlog item, task, and Codex prompt.
