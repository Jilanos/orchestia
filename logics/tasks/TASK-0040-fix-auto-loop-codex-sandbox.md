# TASK-0040: Fix Auto-loop Codex Sandbox

## Status

Complete

## Objective

Fix auto-loop Codex execution so explicitly authorized Codex runs use `codex exec --sandbox workspace-write`, then validate real execution on a disposable workspace.

## Context

REVIEW-0035 found that auto-loop invoked `codex exec`, but Codex defaulted to a read-only sandbox. Codex attempted the requested disposable patch, but writes were blocked, `validation.txt` was not created, and the test failed.

## Authorized Scope

- `scripts/orchestia_loop.sh`
- `scripts/orchestia_ui.py`
- README and workflow/local cockpit/roadmap documentation
- `docs/auto-loop-codex-execution-validation.md`
- Disposable validation files under `task-runs/`
- This task and review record

## Steps Performed

1. Updated auto-loop Codex execution to call `codex exec --sandbox workspace-write`.
2. Recorded the exact command in `codex-command.txt`.
3. Recorded sandbox mode in `codex-sandbox-mode.txt` and `auto-loop-state.md`.
4. Updated cockpit display for Codex sandbox mode.
5. Updated documentation.
6. Created a fresh disposable workspace under `task-runs/`.
7. Ran auto-loop with `--execute-codex` against only the disposable workspace.
8. Verified `hello.txt`, `validation.txt`, exit codes, review draft, and captured evidence.

## Validation Commands

```bash
bash -n scripts/orchestia_loop.sh
python3 -m py_compile scripts/orchestia_ui.py
bash scripts/orchestia_loop.sh auto-loop \
  task-runs/auto-loop-codex-sandbox-validation-loop-state.md \
  --workspace task-runs/auto-loop-codex-sandbox-validation-workspace \
  --max-steps 1 \
  --execute-codex \
  --test "test -f validation.txt"
```

## Acceptance Criteria

- Auto-loop uses `codex exec --sandbox workspace-write` when Codex execution is explicitly authorized.
- Auto-loop remains dry-run by default.
- No `danger-full-access` mode is used.
- Disposable workspace validation succeeds.
- Decision remains pending.
- Loop state is not advanced.
- Evidence and review draft are captured.

## Result

Complete. Disposable validation succeeded in `task-runs/20260523T205548Z-auto-loop/`: Codex exit code `0`, test exit code `0`, `hello.txt` updated, `validation.txt` created, and decision remained pending.
