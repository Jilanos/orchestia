# TASK-0033: Add Git Flow Review Draft Support

## Status

Complete

## Objective

Add a safe `git-flow-review-draft` command to the state-driven loop runner so controlled Git-flow evidence can be converted into a Markdown review draft.

## Context

`scripts/orchestia_loop.sh` already supports Loop state inspection, Codex prompt handoff, evidence collection, generic review drafts, and controlled Git-flow handoff. Controlled Git-flow execution evidence is stored under `task-runs/`, but final review decisions must remain human-owned.

## Authorized Scope

- `scripts/orchestia_loop.sh`
- Concise README and workflow documentation
- MVP roadmap and controlled Git-flow validation notes
- This task and its review record

## Out Of Scope

- Modifying `scripts/controlled_git_flow.sh`
- Running controlled Git flow with `--execute`
- Pushing or merging
- Updating Loop state automatically
- Creating final Logics review files automatically
- Making review decisions automatically

## Expected Steps

1. Add `git-flow-review-draft` to `scripts/orchestia_loop.sh`.
2. Require a Loop state path and `--workspace`.
3. Optionally accept an evidence directory under `task-runs/`.
4. Optionally accept a decision limited to `accept`, `revise`, `split`, or `reject`.
5. Generate a Markdown draft under `task-runs/`.
6. Update concise documentation.

## Verification Commands

```bash
bash -n scripts/orchestia_loop.sh
bash scripts/orchestia_loop.sh
bash scripts/orchestia_loop.sh status logics/loop-states/LS-0001-sample-todo-cli.md
bash scripts/orchestia_loop.sh git-flow-review-draft \
  logics/loop-states/LS-0001-sample-todo-cli.md \
  --workspace ~/ai-workspaces/orchestia-samples/todo-cli
bash scripts/orchestia_loop.sh git-flow-review-draft \
  logics/loop-states/LS-0001-sample-todo-cli.md \
  --workspace ~/ai-workspaces/orchestia-samples/todo-cli \
  --decision accept
```

## Acceptance Criteria

- `git-flow-review-draft` reads the Loop state file.
- The command verifies the target workspace.
- The command optionally reads evidence under `task-runs/`.
- The command writes a Markdown review draft under `task-runs/`.
- The default decision is `pending`.
- Provided decisions are limited to `accept`, `revise`, `split`, or `reject`.
- No final Logics review is created automatically.
- No Loop state update, push, or merge occurs.

## Result

Implemented. The state-driven runner can now draft a Git-flow evidence review while keeping final review creation and Loop state advancement separate.
