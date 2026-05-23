# TASK-0036: Add Controlled Auto Loop

## Status

Complete

## Objective

Add a controlled auto loop mode that reduces mechanical loop steps while preserving explicit human control over execution, decisions, blockers, and Loop state advancement.

## Context

Orchestia v0.2 already has a state-driven loop runner, controlled Git flow helper, review drafts, review finalization, and a read-only local cockpit. The next step is a dry-run-first auto-loop checkpoint that can create evidence, read human instructions, honor stop requests, and prepare review drafts.

## Authorized Scope

- `scripts/orchestia_loop.sh`
- `scripts/orchestia_ui.py`
- README and workflow/roadmap/state-model/local-cockpit documentation
- This task and review record

## Out Of Scope

- `scripts/controlled_git_flow.sh`
- Prompts
- Security policy changes
- Sample project changes
- Real Codex execution
- Real controlled Git push or merge
- Automatic final reviews
- Autonomous decisions

## Expected Steps

1. Add `auto-loop`, `auto-loop-status`, `auto-loop-instruct`, and `auto-loop-stop` commands.
2. Create `task-runs/<timestamp>-auto-loop/` evidence directories.
3. Support instruction and stop request files.
4. Require explicit execute flags for execution paths.
5. Require explicit decisions before Loop state advancement.
6. Add local cockpit auto-loop pages.
7. Update documentation.
8. Run syntax, dry-run, and cockpit smoke verification.

## Verification Commands

```bash
bash -n scripts/orchestia_loop.sh
python3 -m py_compile scripts/orchestia_ui.py
bash scripts/orchestia_loop.sh auto-loop logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/orchestia-samples/todo-cli --max-steps 1
bash scripts/orchestia_loop.sh auto-loop-status task-runs/<timestamp>-auto-loop
bash scripts/orchestia_loop.sh auto-loop-instruct task-runs/<timestamp>-auto-loop "Test instruction from verification."
bash scripts/orchestia_loop.sh auto-loop-stop task-runs/<timestamp>-auto-loop "Test stop request from verification."
```

Cockpit smoke verification covered dashboard, auto-loop list, auto-loop detail, and debug pages.

## Acceptance Criteria

- `orchestia_loop.sh` supports controlled auto-loop commands.
- Auto-loop is dry-run by default.
- Execution requires explicit execute flags.
- Decisions must be explicit and limited to accept, revise, split, or reject.
- Loop state advancement requires `--advance` and required fields.
- Instruction and stop files are supported.
- The cockpit shows auto-loop runs and human action required.
- No real Codex execution, push, or merge occurs in this implementation task.

## Result

Implemented. Controlled auto-loop support is available through `scripts/orchestia_loop.sh`, and the local cockpit can inspect auto-loop evidence without executing actions.
