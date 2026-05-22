# TASK-0032: Add Controlled Git Flow Handoff

## Status

Complete

## Objective

Add a safe handoff from the state-driven loop runner to controlled Git flow automation without executing push or merge.

## Context

`scripts/orchestia_loop.sh` reads Loop state and helps run or collect loop evidence. `scripts/controlled_git_flow.sh` performs guarded Git status, auto-push, and auto-merge operations. Controlled Git flow was validated on the dedicated sample repository and remains separate from the loop runner.

## Authorized Scope

- `scripts/orchestia_loop.sh`
- README and workflow/roadmap/validation documentation
- New Logics task and review records for this work

## Out Of Scope

- Modifying `scripts/controlled_git_flow.sh`
- Running controlled Git flow with `--execute`
- Performing a real push or merge
- Updating Loop state automatically
- Making review decisions automatically

## Expected Steps

1. Add a `git-flow` subcommand to `scripts/orchestia_loop.sh`.
2. Verify Loop state and workspace inputs.
3. Generate copyable `controlled_git_flow.sh` status, auto-push, and auto-merge commands.
4. Mark execute commands as human-approved only.
5. Create a timestamped handoff report under `task-runs/`.
6. Update concise documentation.

## Verification Commands

```bash
bash -n scripts/orchestia_loop.sh
bash scripts/orchestia_loop.sh
bash scripts/orchestia_loop.sh status logics/loop-states/LS-0001-sample-todo-cli.md
bash scripts/orchestia_loop.sh git-flow \
  logics/loop-states/LS-0001-sample-todo-cli.md \
  --workspace ~/ai-workspaces/orchestia-samples/todo-cli \
  --remote origin \
  --source-branch feature/controlled-git-flow-validation \
  --target-branch integration \
  --test "python3 -m unittest discover -s tests"
```

## Acceptance Criteria

- `git-flow` reads the Loop state file.
- `git-flow` verifies the target workspace.
- `git-flow` creates a handoff report under `task-runs/`.
- `git-flow` generates controlled Git flow status, auto-push, and auto-merge commands.
- `git-flow` does not push or merge.
- `git-flow` marks execute commands as human-approved only.

## Result

Implemented. The loop runner now supports controlled Git flow handoff while keeping push and merge execution outside the runner.
