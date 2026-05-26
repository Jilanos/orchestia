# REVIEW-0058: End-To-End Orchestration Run

## Reviewed Task

[TASK-0063 Add End-To-End Orchestration Run](../tasks/TASK-0063-add-end-to-end-orchestration-run.md)

## Files Changed

- `scripts/orchestia_loop.sh`
- `scripts/orchestia_ui.py`
- `README.md`
- `docs/workflow.md`
- `docs/local-cockpit.md`
- `docs/cockpit-driven-orchestration.md`
- `docs/mvp-roadmap.md`
- `docs/end-to-end-orchestration-run.md`
- `logics/tasks/TASK-0063-add-end-to-end-orchestration-run.md`
- `logics/reviews/REVIEW-0058-end-to-end-orchestration-run.md`

## Validation

- `bash -n scripts/orchestia_loop.sh`
- `python3 -m py_compile scripts/orchestia_ui.py`
- Disposable orchestration-run under `task-runs/`.
- Codex execution through `codex exec --sandbox workspace-write` against disposable workspace only.
- Test command: `python3 -m unittest discover -s tests`.
- Controlled auto-push dry-run and execute through `controlled_git_flow.sh`.
- Push target: local bare remote under `task-runs/orchestration-run-disposable/remote.git`.
- Cockpit GET smoke for dashboard, orchestration runs, start page, and debug.
- Cockpit POST smoke for orchestration request creation.
- Grep checks for routes, docs, auto-push, protected branch policy, and task/review records.
- `git diff --check`.

## Findings

- `orchestration-run` writes `policy.md`, `events.log`, `summary.md`, cycle evidence, review drafts, advancement evidence, and Git-flow evidence.
- Execution remains disabled unless explicit policy flags are supplied.
- Controlled auto-push is delegated to `controlled_git_flow.sh`.
- `main/master` are refused as push branches by default.
- The cockpit creates request files and command previews only; it does not execute Codex, push, merge, or run arbitrary commands.
- Validation used only disposable local resources and a local bare remote.

## Risks

- The first implementation records a Logics promotion package under `task-runs/` but does not write final tracked Logics records.
- The runner does not create commits; auto-push requires a clean, already committed workspace.
- Multi-cycle planning and next prompt selection remain intentionally limited.
- Future browser-triggered execution will need stronger negative-path validation before enabling.

## Decision

accept

## Required Follow-Up

- Add guarded Logics promotion from reviewed drafts to final records.
- Add negative-path validation for `orchestration-run`.
- Design the next cockpit action for reviewed task prompt preparation.

## Next Recommended Task

Implement guarded draft promotion with ID collision checks and human confirmation, still without Codex execution from the cockpit.
