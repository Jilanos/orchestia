# TASK-0003: Improve Helper Scripts

## Metadata

- ID: TASK-0003
- Backlog: [BL-0001 Foundation](../backlog/BL-0001-foundation.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Status: Completed
- Review: [REVIEW-0002 Helper Scripts](../reviews/REVIEW-0002-helper-scripts.md)

## Objective

Improve the MVP helper scripts so they are safe, usable, and consistent for local WSL-based task execution and result collection.

## Scope

- Update environment checks.
- Make Codex task execution explicit and opt-in.
- Capture Git inspection output into timestamped `task-runs/` directories.
- Capture optional test command output and exit codes.
- Summarize available task run outputs without modifying files.

## Completed Work

- `check_environment.sh` now distinguishes required and optional tools and reports detected versions.
- `run_codex_task.sh` validates the task file and Git repository, then prints a copyable Codex command by default.
- `collect_diff.sh` writes Git status, diff, diff stat, and recent log files into a timestamped run directory.
- `collect_test_results.sh` accepts commands after `--`, records output and exit code, and exits successfully when no command is provided.
- `summarize_task_result.sh` summarizes a provided or latest run directory and handles missing files gracefully.

## Verification

Run the checks listed in [REVIEW-0002 Helper Scripts](../reviews/REVIEW-0002-helper-scripts.md).
