# TASK-0044: Add Negative-path Validation Suite

## Status

Complete

## Objective

Create and run a reusable `v0.2-alpha` negative-path validation suite for Orchestia guardrails, document the result, then commit and push.

## Context

`v0.2-alpha` positive-path validation was complete, but `REVIEW-0040` identified remaining guardrail gaps: failed-test blocking, dirty workspace refusal, protected branch refusal, missing prompt handling, missing evidence handling, merge conflict behavior, invalid decision refusal, and missing `--execute` preventing execution.

## Authorized Scope

- `scripts/validate_negative_paths.sh`
- `docs/v0.2-alpha-negative-path-validation.md`
- `docs/mvp-roadmap.md`
- `docs/validation-checklist.md`
- `logics/tasks/TASK-0044-add-negative-path-validation-suite.md`
- `logics/reviews/REVIEW-0041-negative-path-validation-suite.md`
- Disposable ignored evidence under `task-runs/`

## Validation Cases

1. Auto-loop missing prompt.
2. Auto-loop dry-run without execute.
3. Auto-loop dirty workspace refusal.
4. Invalid decision refusal.
5. `finalize-review` draft outside `task-runs/`.
6. `finalize-review` invalid decision.
7. Controlled auto-push protected branch refusal.
8. Controlled auto-push dirty workspace refusal.
9. Controlled auto-push failed-test blocking.
10. Controlled auto-merge protected target refusal.
11. Controlled auto-merge failed-test blocking.
12. Controlled auto-merge conflict blocking.
13. Git-flow review draft missing evidence handling.
14. Missing `--execute` prevents push and merge execution.

## Commands Run

```bash
bash -n scripts/validate_negative_paths.sh
bash scripts/validate_negative_paths.sh
```

## Acceptance Criteria

- The script exists and is executable.
- The suite uses only disposable resources under `task-runs/`.
- The suite does not use GitHub remotes.
- The suite does not modify the sample todo CLI project.
- All required negative-path guardrails are validated.
- A clear report is produced under `task-runs/`.
- Documentation and review records are created.

## Result

Complete. The suite produced `task-runs/20260524T071922Z-negative-path-validation/negative-path-validation.md` with 14 total cases, 14 passed, 0 failed, and 0 blocked.
