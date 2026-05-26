# REVIEW-0053: Cockpit Action Layer

## Metadata

- ID: REVIEW-0053
- Status: Complete
- Reviewed task: [TASK-0058 Implement Cockpit Action Layer](../tasks/TASK-0058-implement-cockpit-action-layer.md)
- Decision: accept

## Files Changed

- `scripts/orchestia_ui.py`
- `scripts/orchestia_loop.sh`
- `README.md`
- `docs/workflow.md`
- `docs/local-cockpit.md`
- `docs/mvp-roadmap.md`
- `docs/v0.2-beta-readiness.md`
- `docs/cockpit-action-layer.md`
- `logics/tasks/TASK-0057-v0.2-beta-readiness.md`
- `logics/tasks/TASK-0058-implement-cockpit-action-layer.md`
- `logics/reviews/REVIEW-0052-v0.2-beta-readiness.md`
- `logics/reviews/REVIEW-0053-cockpit-action-layer.md`

## Checks Run

- `bash -n scripts/orchestia_loop.sh`: passed.
- `python3 -m py_compile scripts/orchestia_ui.py`: passed.
- `test -x scripts/orchestia_loop.sh`: passed.
- `test -x scripts/orchestia_ui.py`: passed.
- `bash scripts/orchestia_loop.sh autonomous-loop-status task-runs/20260526T101212Z-autonomous-loop`: passed.
- `git diff --check`: passed during validation.

## Smoke Tests

- GET `/`: passed.
- GET `/needs`: passed.
- GET `/needs/new`: passed.
- GET `/loop-dashboard`: passed.
- GET `/iterations`: passed.
- GET `/tokens`: passed.
- GET `/autonomous-loop`: passed.
- GET `/debug`: passed.
- POST `/needs/create`: created an ignored disposable draft under `task-runs/`.
- POST `/actions/autonomous-loop-instruct`: appended a disposable instruction to an existing autonomous-loop run.
- POST `/actions/autonomous-loop-stop`: appended a disposable stop request to an existing autonomous-loop run.

## Findings

- The cockpit now supports draft need intake without mutating Logics records.
- The Loop dashboard gives a compact state view for active and completed Loop states.
- The iteration timeline links task-runs, tasks, and reviews in one view.
- The token page parses local evidence when present and shows not available when usage is missing.
- Autonomous-loop run pages now include safe instruction and stop request POST actions.
- No arbitrary command execution, Codex execution, push, merge, or controlled Git flow execute action was added to the browser.
- `scripts/orchestia_loop.sh` gained a read-only `autonomous-loop-status` command.

## Risks

- The action layer has no authentication layer and should remain bound to localhost.
- The iteration timeline is inferred from filenames and simple Markdown parsing.
- Token usage parsing is best-effort and depends on local evidence format.
- Instruction and stop POST actions append to existing evidence directories; operators must still review active loop behavior in the CLI.

## Decision

accept

## Required Follow-Up

- Consider a reviewed draft-to-Logics promotion flow after more cockpit usage.
- Consider machine-readable token evidence for future Codex runs.

## Next Recommended Task

Run v0.2-beta release readiness and decide whether to tag only after a separate explicit release task.
