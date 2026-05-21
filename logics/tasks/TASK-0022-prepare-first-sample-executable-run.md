# TASK-0022: Prepare First Sample Executable Run

## Metadata

- ID: TASK-0022
- Status: Complete
- Related task: [TASK-0018 Sample Todo CLI Create Project Foundation](TASK-0018-sample-todo-cli-create-project-foundation.md)
- Loop state: [LS-0001 Sample Todo CLI](../loop-states/LS-0001-sample-todo-cli.md)

## Objective

Prepare the first executable sample task run for the v0.2 todo CLI scenario without executing Codex or creating the sample project.

## Context

The sample Logics chain now points to `TASK-0018` as the pending next action. This task creates the Codex-ready prompt and manual run documentation needed to execute that task later in a dedicated sample workspace.

## Authorized Scope

- `prompts/samples/todo-cli-task-0018-codex-prompt.md`
- `docs/sample-v0.2-first-executable-run.md`
- `logics/loop-states/LS-0001-sample-todo-cli.md`
- `logics/tasks/TASK-0022-prepare-first-sample-executable-run.md`
- `logics/reviews/REVIEW-0018-first-sample-executable-run-preparation.md`

## Out Of Scope

- Do not execute Codex.
- Do not create the sample todo CLI project.
- Do not create source code for the sample todo CLI in Orchestia.
- Do not modify scripts or existing prompt templates.
- Do not push from the sample project.

## Expected Steps

1. Verify repository path, branch, and clean working tree.
2. Read the existing sample task, loop state, sample scenario, Codex task prompt, workflow, and security boundaries.
3. Create the prepared Codex prompt for `TASK-0018`.
4. Create the first executable run guide.
5. Update `LS-0001` to reference the prepared prompt and keep the decision pending.
6. Create this task record and the review record.
7. Run the verification commands.
8. Commit and push the preparation artifacts.

## Test Commands

```bash
pwd
git branch --show-current
test "$(git branch --show-current)" = "master"
test -f prompts/samples/todo-cli-task-0018-codex-prompt.md
test -f docs/sample-v0.2-first-executable-run.md
test -f logics/tasks/TASK-0022-prepare-first-sample-executable-run.md
test -f logics/reviews/REVIEW-0018-first-sample-executable-run-preparation.md
grep -R "orchestia-samples/todo-cli" prompts/samples/todo-cli-task-0018-codex-prompt.md docs/sample-v0.2-first-executable-run.md
grep -R "do not modify the Orchestia repository" prompts/samples/todo-cli-task-0018-codex-prompt.md
grep -R "do not work under /mnt/c" prompts/samples/todo-cli-task-0018-codex-prompt.md
grep -R "do not push" prompts/samples/todo-cli-task-0018-codex-prompt.md
grep -R "prepared Codex prompt" logics/loop-states/LS-0001-sample-todo-cli.md
grep -R "pending" logics/loop-states/LS-0001-sample-todo-cli.md
git status --short
git diff --stat
```

## Acceptance Criteria

- The Codex-ready sample prompt exists.
- The sample executable run documentation exists.
- `LS-0001` references the prepared prompt and remains pending.
- No Codex execution is performed.
- No sample todo CLI project is created.
- No source code for the sample todo CLI is created in Orchestia.

## Watch Points

- Keep this as preparation only.
- Do not weaken the `/mnt/c`, secrets, global dependency, or push restrictions.
- Do not modify sample requests, backlog items, primary needs, or initial needs.

## Security Rules

- Do not read, print, summarize, or log secrets.
- Do not print environment variables.
- Do not modify files outside the authorized scope.
- Do not merge, rebase, tag, or force push.

## Result Summary

Created a copyable Codex prompt for `TASK-0018`, documented the manual execution path, and updated `LS-0001` so the next action is ready but still pending.
