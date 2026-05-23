# TASK-0039: Validate Auto-loop Codex Execution

## Status

Blocked

## Objective

Validate real Codex execution through `scripts/orchestia_loop.sh auto-loop --execute-codex` on a disposable workspace under `task-runs/`.

## Context

TASK-0038 added real `codex exec` support to auto-loop, but only dry-run verification had been performed. This task validates the executable path against a disposable Git workspace, not against Orchestia, the sample todo CLI, or any real project.

## Authorized Scope

- Disposable files under `task-runs/`
- `docs/auto-loop-codex-execution-validation.md`
- `docs/mvp-roadmap.md`
- This task and review record

## Steps Performed

1. Verified repository path, branch, and clean status.
2. Verified `codex` availability.
3. Ran `codex --version`.
4. Ran `codex exec --help`.
5. Created `task-runs/auto-loop-codex-disposable-workspace/`.
6. Initialized Git in the disposable workspace.
7. Created and committed baseline `README.md` and `hello.txt`.
8. Created disposable prepared prompt under `task-runs/`.
9. Created disposable Loop state under `task-runs/`.
10. Ran auto-loop with `--execute-codex` and `--test "test -f validation.txt"`.
11. Inspected auto-loop evidence and disposable workspace status.
12. Documented the blocked validation result.

## Validation Commands

```bash
codex --version
codex exec --help
git init
git add README.md hello.txt
git commit -m "Disposable baseline"
bash scripts/orchestia_loop.sh auto-loop \
  task-runs/auto-loop-codex-disposable-loop-state.md \
  --workspace task-runs/auto-loop-codex-disposable-workspace \
  --max-steps 1 \
  --execute-codex \
  --test "test -f validation.txt"
```

## Acceptance Criteria

- Disposable workspace exists under `task-runs/`.
- Disposable Loop state and prepared prompt exist under `task-runs/`.
- Auto-loop invokes `codex exec` only against the disposable workspace.
- Codex execution evidence is captured.
- Decision remains pending.
- Loop state is not advanced.
- Result is documented accurately as success or blocked.

## Result

Blocked. Auto-loop invoked `codex exec`, but Codex ran with `sandbox: read-only` and approval `never`, so the requested file edits were rejected. Auto-loop captured Codex output and the failing test result. No Loop state advancement occurred.
