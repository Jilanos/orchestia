# REVIEW-0036: Auto-loop Codex Sandbox Fix

## Reviewed Task

[TASK-0040](../tasks/TASK-0040-fix-auto-loop-codex-sandbox.md)

## Previous Blocker

REVIEW-0035 showed that auto-loop invoked `codex exec`, but Codex ran with `sandbox: read-only`. The attempted disposable patch was rejected, `validation.txt` was not created, and the post-execution test failed.

## Commands Run

```bash
codex --version
codex exec --help
bash -n scripts/orchestia_loop.sh
python3 -m py_compile scripts/orchestia_ui.py
bash scripts/orchestia_loop.sh auto-loop \
  task-runs/auto-loop-codex-sandbox-validation-loop-state.md \
  --workspace task-runs/auto-loop-codex-sandbox-validation-workspace \
  --max-steps 1 \
  --execute-codex \
  --test "test -f validation.txt"
```

## Evidence Reviewed

- `task-runs/20260523T205548Z-auto-loop/codex-command.txt`
- `task-runs/20260523T205548Z-auto-loop/codex-sandbox-mode.txt`
- `task-runs/20260523T205548Z-auto-loop/codex-exit-code.txt`
- `task-runs/20260523T205548Z-auto-loop/test-exit-code.txt`
- `task-runs/20260523T205548Z-auto-loop/workspace-status-before.txt`
- `task-runs/20260523T205548Z-auto-loop/workspace-status-after.txt`
- `task-runs/20260523T205548Z-auto-loop/workspace-diff-stat-after.txt`
- `task-runs/20260523T205548Z-auto-loop/review-draft.md`
- Disposable workspace `hello.txt` and `validation.txt`

## Findings

- Auto-loop now records and executes `codex exec --sandbox workspace-write`.
- `danger-full-access` is not used.
- The disposable workspace was clean before execution.
- Codex updated `hello.txt` and created `validation.txt`.
- `codex-exit-code.txt` recorded `0`.
- `test-exit-code.txt` recorded `0`.
- `review-draft.md` was created.
- Decision remained pending.
- Loop state was not advanced.
- No Codex execution occurred against Orchestia or the sample todo CLI.
- No controlled Git flow execute path was used.

## Risks

- `workspace-write` allows writes within the verified target workspace, so it must remain behind explicit `--execute-codex` or `--execute-all`.
- Post-execution checks remain required; Codex exit code alone is not enough to prove task success.
- The disposable workspace remains dirty for review, as expected.

## Decision

accept

## Required Follow-Up

Add negative-path validation for executable auto-loop guardrails, including dirty workspace refusal, missing prompt, Codex non-zero exit, test failure, missing decision, and missing advancement fields.

## Next Recommended Task

Validate auto-loop negative paths before using executable auto-loop on a non-disposable project.
