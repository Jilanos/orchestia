# REVIEW-0018: First Sample Executable Run Preparation

## Metadata

- ID: REVIEW-0018
- Status: Complete
- Reviewed task: [TASK-0022 Prepare First Sample Executable Run](../tasks/TASK-0022-prepare-first-sample-executable-run.md)
- Related loop state: [LS-0001 Sample Todo CLI](../loop-states/LS-0001-sample-todo-cli.md)

## Inputs Reviewed

- `prompts/samples/todo-cli-task-0018-codex-prompt.md`
- `docs/sample-v0.2-first-executable-run.md`
- `logics/loop-states/LS-0001-sample-todo-cli.md`
- `logics/tasks/TASK-0022-prepare-first-sample-executable-run.md`

## Checks Performed

- Confirmed the prompt targets `~/ai-workspaces/orchestia-samples/todo-cli`.
- Confirmed the prompt forbids modifying Orchestia.
- Confirmed the prompt forbids `/mnt/c`, secrets, global dependency installation, and push.
- Confirmed the run guide states expected outputs, collection steps, review path, and stop conditions.
- Confirmed `LS-0001` remains pending and references the prepared Codex prompt.

## Findings

- No blocking issues found in the preparation artifacts.
- The prepared prompt allows only a local commit in the dedicated sample project and does not allow push.
- The task remains unexecuted, so no sample project output exists yet.

## Risks

- Runtime choice is intentionally deferred and must remain dependency-light during execution.
- A pre-existing target directory could contain unrelated files; the prompt requires Codex to stop in that case.
- The sample project execution still needs a separate review after it is run.

## Decision

accept

## Required Follow-Up

Execute the prepared prompt manually in Codex from a safe WSL Linux filesystem workspace, then collect and review the sample project results.

## Next Recommended Task

Run `TASK-0018` using the prepared Codex prompt in the dedicated sample workspace.
