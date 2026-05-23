# REVIEW-0034: Codex Auto Loop Execution

## Reviewed Task

[TASK-0038](../tasks/TASK-0038-execute-codex-in-auto-loop.md)

## Inputs Reviewed

- `scripts/orchestia_loop.sh`
- `scripts/orchestia_ui.py`
- `README.md`
- `docs/workflow.md`
- `docs/local-cockpit.md`
- `docs/mvp-roadmap.md`
- `codex exec --help`

## Checks Performed

- Verified `codex` availability and inspected `codex exec --help`.
- Bash syntax check for `scripts/orchestia_loop.sh`.
- Python syntax compilation for `scripts/orchestia_ui.py`.
- Dry-run `auto-loop` verification against the sample Loop state.
- Auto-loop run directory file checks.
- Grep checks for `codex exec`, execute flags, evidence filenames, and status values.
- Local cockpit smoke checks for dashboard, auto-loop list, auto-loop detail, and debug pages.
- Git status, diff stat, and diff check review.

## Findings

- `auto-loop` now resolves the prepared Codex prompt from Loop state and assembles a run-local prompt copy.
- Additional human instructions are appended to the prompt sent to `codex exec` without modifying the original prompt file.
- `--execute-codex` and `--execute-all` are the only paths that run Codex.
- Execution captures `codex-stdout.txt`, `codex-stderr.txt`, `codex-exit-code.txt`, workspace status before and after, diff stat, and recent commits.
- Optional `--test` output and exit code are captured after Codex execution.
- Failed Codex or test execution writes `errors.md` and requires human review.
- The cockpit shows Codex execution state, exit codes, evidence links, and human action required status.

## Risks

- The implementation uses shell command execution for the optional user-provided test command, matching existing helper behavior; task scopes must continue to keep tests safe.
- `codex exec` behavior depends on the installed local Codex CLI version.
- Loop state updates remain label-based Markdown rewrites and should be validated against future templates.

## Decision

accept

## Required Follow-Up

Run a separate disposable execution validation that uses `--execute-codex` against a fixture workspace under `task-runs/`, then review the captured evidence.

## Next Recommended Task

Add negative-path validation for executable auto-loop guardrails, including missing prompt, dirty workspace, Codex failure, test failure, missing decision, and missing advancement fields.
