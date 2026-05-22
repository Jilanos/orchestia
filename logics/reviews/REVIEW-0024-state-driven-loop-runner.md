# REVIEW-0024: State-Driven Loop Runner

## Metadata

- ID: REVIEW-0024
- Status: Complete
- Reviewed task: [TASK-0028 Add State-Driven Loop Runner](../tasks/TASK-0028-add-state-driven-loop-runner.md)

## Inputs Reviewed

- `scripts/orchestia_loop.sh`
- `README.md`
- `docs/workflow.md`
- `docs/mvp-roadmap.md`
- `docs/orchestration-state-model.md`
- `logics/loop-states/LS-0001-sample-todo-cli.md`

## Checks Performed

- Bash syntax check.
- Executable-bit check.
- `status` command against `LS-0001`.
- `next` command against a complete loop.
- `run` command against the sample workspace.
- `collect` command with a sample unittest command.
- `review-draft` command against the sample workspace.
- Documentation grep checks.

## Findings

- The runner reads Loop state fields and reports current state.
- The runner handles completed loops without attempting execution.
- Workspace checks require a Git repository outside `/mnt/c`.
- Codex is not executed unless `--execute` is explicitly provided.
- The script does not update Loop state or create final review decisions.

## Risks

- Markdown parsing is intentionally simple and tuned to the current Loop state format.
- `collect --test` runs a user-provided shell command from the workspace; users should keep test commands safe and scoped.
- The completed sample loop only validates the complete-state path, so a future task should exercise a non-complete Loop state.

## Decision

accept

## Required Follow-Up

Exercise the runner against a non-complete Loop state and refine parsing if new state documents vary from the current template.

## Next Recommended Task

Create a small active Loop state fixture or use a future real task to validate the `run` path with a prepared prompt.
