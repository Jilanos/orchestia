# REVIEW-0002: Helper Scripts

## Metadata

- ID: REVIEW-0002
- Status: Accepted
- Task: [TASK-0003 Improve Helper Scripts](../tasks/TASK-0003-improve-helper-scripts.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Backlog: [BL-0001 Foundation](../backlog/BL-0001-foundation.md)

## Checks

- `bash -n scripts/check_environment.sh`
- `bash -n scripts/run_codex_task.sh`
- `bash -n scripts/collect_diff.sh`
- `bash -n scripts/collect_test_results.sh`
- `bash -n scripts/summarize_task_result.sh`
- `bash scripts/check_environment.sh`
- `bash scripts/run_codex_task.sh logics/tasks/TASK-0001-initial-scaffold.md`
- `bash scripts/collect_diff.sh`
- `bash scripts/collect_test_results.sh -- bash -n scripts/check_environment.sh`
- `bash scripts/summarize_task_result.sh`

## Result

The helper scripts are suitable for the MVP workflow. They inspect the environment, prepare bounded Codex task execution, collect Git diffs, capture test command results, and summarize task run outputs.

## Risks

- `collect_test_results.sh` executes the command supplied by the user, so callers must keep commands explicit and reviewable.
- `run_codex_task.sh --execute` depends on the local `codex` command and should remain opt-in.
- The scripts remain intentionally small and may need refinement after the first full task run.

## Next Step

Use these helpers on the next bounded Orchestia task and review the generated `task-runs/` output.
