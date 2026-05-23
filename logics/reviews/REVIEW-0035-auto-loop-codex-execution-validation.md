# REVIEW-0035: Auto-loop Codex Execution Validation

## Reviewed Task

[TASK-0039](../tasks/TASK-0039-validate-auto-loop-codex-execution.md)

## Inputs Reviewed

- `scripts/orchestia_loop.sh`
- `scripts/orchestia_ui.py`
- `docs/mvp-roadmap.md`
- `REVIEW-0034`
- Disposable workspace under `task-runs/auto-loop-codex-disposable-workspace/`
- Disposable Loop state under `task-runs/auto-loop-codex-disposable-loop-state.md`
- Disposable prepared prompt under `task-runs/auto-loop-codex-disposable-prompt.md`
- Auto-loop evidence under `task-runs/20260523T202633Z-auto-loop/`

## Checks Performed

- Verified `codex` availability and `codex exec --help`.
- Initialized and committed a disposable Git workspace baseline.
- Ran `scripts/orchestia_loop.sh auto-loop` with `--execute-codex`.
- Reviewed `codex-stdout.txt`, `codex-stderr.txt`, `codex-exit-code.txt`, workspace status files, diff stat, test exit code, review draft, and errors.
- Confirmed no Loop state advancement occurred.
- Confirmed no push, merge, rebase, or tag occurred.

## Findings

- Auto-loop successfully invoked `codex exec` against the disposable workspace.
- Auto-loop captured the expected execution evidence files.
- Codex reported `sandbox: read-only` and approval `never`.
- Codex attempted to apply the requested minimal file changes, but the patch was rejected by the read-only sandbox.
- `codex-exit-code.txt` recorded `0`, but the requested `validation.txt` file was not created.
- The post-execution test `test -f validation.txt` failed with exit code `1`.
- The disposable workspace remained clean and unchanged.
- Decision remained pending, and Loop state was not advanced.

## Risks

- Codex exit code alone is not sufficient to determine task success; post-execution checks are required.
- Auto-loop currently does not force a writable sandbox mode for `codex exec`, so write tasks can be blocked even when `--execute-codex` is explicit.
- A future change must preserve safety while allowing workspace writes only for explicitly authorized disposable or target workspaces.

## Decision

revise

## Required Follow-Up

Revise auto-loop Codex execution so it can explicitly request a safe writable sandbox for the authorized target workspace, then rerun this disposable validation.

## Next Recommended Task

Add an explicit `codex exec` sandbox mode option to auto-loop, defaulting conservatively and documenting when writable execution is allowed.
