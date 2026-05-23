# REVIEW-0032: Controlled Auto Loop

## Reviewed Task

[TASK-0036](../tasks/TASK-0036-add-controlled-auto-loop.md)

## Inputs Reviewed

- `scripts/orchestia_loop.sh`
- `scripts/orchestia_ui.py`
- `README.md`
- `docs/workflow.md`
- `docs/mvp-roadmap.md`
- `docs/orchestration-state-model.md`
- `docs/local-cockpit.md`

## Checks Performed

- Bash syntax check for `scripts/orchestia_loop.sh`.
- Python syntax compilation for `scripts/orchestia_ui.py`.
- Dry-run `auto-loop` invocation against the sample Loop state.
- `auto-loop-status`, `auto-loop-instruct`, and `auto-loop-stop` verification.
- Documentation grep checks for auto-loop terms and decisions.
- Local cockpit smoke checks for dashboard, auto-loop list, auto-loop detail, and debug pages.
- Git status, diff stat, and diff check review.

## Findings

- The auto-loop creates a timestamped `task-runs/*-auto-loop` directory with state, events, command preview, evidence, and review draft files.
- Default behavior is dry-run and command preview only.
- Execution paths require explicit `--execute-codex`, `--execute-git-flow`, or `--execute-all` flags.
- Decisions are not inferred; they must be supplied as accept, revise, split, or reject.
- Loop state advancement is guarded by `--advance`, explicit decision, last review, next action, stop condition, and a backup under the auto-loop run directory.
- The cockpit remains read-only and exposes auto-loop status, human action required, and copyable instruction or stop commands.

## Risks

- The first auto-loop implementation is intentionally conservative and does not run a full multi-step autonomous loop.
- Loop state field updates use simple label-based Markdown rewriting and should remain aligned with the documented template.
- Browser controls are copyable CLI commands only; direct safe POST controls can be considered later.

## Decision

accept

## Required Follow-Up

Exercise auto-loop against a non-complete Loop state and add negative-path validation for missing decisions, missing advancement fields, dirty workspaces, and stop requests.

## Next Recommended Task

Add a dedicated validation task for controlled auto-loop guardrails.
