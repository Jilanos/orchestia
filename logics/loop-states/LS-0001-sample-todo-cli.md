# LS-0001: Sample Todo CLI Loop State

## Metadata

- ID: LS-0001
- Status: active
- Initial need: [IN-0001 Sample Todo CLI](../initial-needs/IN-0001-sample-todo-cli.md)
- Primary need: [PN-0003 Validation And Docs](../primary-needs/PN-0003-validation-and-docs.md)

## Loop State

- Current primary need: [PN-0003 Validation And Docs](../primary-needs/PN-0003-validation-and-docs.md)
- Current request: [REQ-0004 Sample Todo CLI Validation Docs](../requests/REQ-0004-sample-todo-cli-validation-docs.md)
- Current backlog item: [BL-0006 Sample Todo CLI Validation Docs](../backlog/BL-0006-sample-todo-cli-validation-docs.md)
- Current task: [TASK-0020 Sample Todo CLI Add Validation And Docs](../tasks/TASK-0020-sample-todo-cli-add-validation-and-docs.md)
- prepared Codex prompt: [todo-cli-task-0020-codex-prompt.md](../../prompts/samples/todo-cli-task-0020-codex-prompt.md)
- Last Codex run: sample project commit `1788bae Implement core todo CLI features`
- Last review: [REVIEW-0021 Sample Task 0019 Execution](../reviews/REVIEW-0021-sample-task-0019-execution.md)
- Decision: pending
- Next action: Execute the prepared TASK-0020 prompt in Codex from the dedicated sample workspace.
- Stop condition: Stop if the sample workspace is dirty, the path is unsafe, Codex requests secrets, Codex needs a destructive command, tests fail repeatedly, or implementation expands beyond validation and documentation.

## Decision

Allowed values: accept, revise, split, reject.

- Decision: pending

## Stop Condition

Allowed values:

- all primary needs complete
- remaining primary needs out of scope
- firm blocker reached
- human stop requested

- Stop condition: Stop if the sample workspace is dirty, the path is unsafe, Codex requests secrets, Codex needs a destructive command, tests fail repeatedly, or implementation expands beyond validation and documentation.

## Firm Blocker

- Blocker type: None
- Evidence: None
- Human decision needed: None

## Next Action

- Execute the prepared TASK-0020 prompt in Codex from the dedicated sample workspace.
