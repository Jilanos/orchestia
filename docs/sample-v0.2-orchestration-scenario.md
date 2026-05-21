# Sample v0.2 Orchestration Scenario

## Purpose

This sample shows how Orchestia v0.2 can represent an initial user need, decompose it into Primary need records, and track Loop state as sample tasks execute in a dedicated workspace.

## Sample Initial User Need

Build a small local todo CLI that can add, list, complete, and persist todo items in a simple local file.

## Primary Need Decomposition

- [PN-0001 Project Foundation](../logics/primary-needs/PN-0001-project-foundation.md): establish the project structure, runtime choice, and minimal CLI entry point.
- [PN-0002 Core Todo Features](../logics/primary-needs/PN-0002-core-todo-features.md): implement add, list, complete, and local persistence behavior.
- [PN-0003 Validation And Docs](../logics/primary-needs/PN-0003-validation-and-docs.md): add validation checks and concise user documentation.

## Macro Loop

Initial need -> primary needs -> request/backlog/tasks per primary need -> completion review -> next primary need.

For this sample, [IN-0001](../logics/initial-needs/IN-0001-sample-todo-cli.md) is decomposed into three Primary need records. Each Primary need now has a planned request, backlog item, and task.

## Micro Loop

Task -> Codex execution -> collect outputs -> review -> accept, revise, split or reject.

The sample [LS-0001 Loop state](../logics/loop-states/LS-0001-sample-todo-cli.md) started at PN-0001 and now advances to PN-0002 after the first accepted micro loop.

The accepted first micro loop used [REQ-0002](../logics/requests/REQ-0002-sample-todo-cli-foundation.md), [BL-0004](../logics/backlog/BL-0004-sample-todo-cli-foundation.md), and [TASK-0018](../logics/tasks/TASK-0018-sample-todo-cli-create-project-foundation.md). The sample project commit is `933cc67 Create todo CLI project foundation`, reviewed in [REVIEW-0019](../logics/reviews/REVIEW-0019-sample-task-0018-execution.md).

The current micro loop now points to [REQ-0003](../logics/requests/REQ-0003-sample-todo-cli-core-features.md), [BL-0005](../logics/backlog/BL-0005-sample-todo-cli-core-features.md), and [TASK-0019](../logics/tasks/TASK-0019-sample-todo-cli-implement-core-features.md).

## Expanded Logics Chain

| Primary need | Request | Backlog item | Planned task |
| --- | --- | --- | --- |
| [PN-0001 Project Foundation](../logics/primary-needs/PN-0001-project-foundation.md) | [REQ-0002](../logics/requests/REQ-0002-sample-todo-cli-foundation.md) | [BL-0004](../logics/backlog/BL-0004-sample-todo-cli-foundation.md) | [TASK-0018](../logics/tasks/TASK-0018-sample-todo-cli-create-project-foundation.md) |
| [PN-0002 Core Todo Features](../logics/primary-needs/PN-0002-core-todo-features.md) | [REQ-0003](../logics/requests/REQ-0003-sample-todo-cli-core-features.md) | [BL-0005](../logics/backlog/BL-0005-sample-todo-cli-core-features.md) | [TASK-0019](../logics/tasks/TASK-0019-sample-todo-cli-implement-core-features.md) |
| [PN-0003 Validation And Docs](../logics/primary-needs/PN-0003-validation-and-docs.md) | [REQ-0004](../logics/requests/REQ-0004-sample-todo-cli-validation-docs.md) | [BL-0006](../logics/backlog/BL-0006-sample-todo-cli-validation-docs.md) | [TASK-0020](../logics/tasks/TASK-0020-sample-todo-cli-add-validation-and-docs.md) |

## Sample Logics Files Created

- `logics/initial-needs/IN-0001-sample-todo-cli.md`
- `logics/primary-needs/PN-0001-project-foundation.md`
- `logics/primary-needs/PN-0002-core-todo-features.md`
- `logics/primary-needs/PN-0003-validation-and-docs.md`
- `logics/loop-states/LS-0001-sample-todo-cli.md`
- `logics/requests/REQ-0002-sample-todo-cli-foundation.md`
- `logics/requests/REQ-0003-sample-todo-cli-core-features.md`
- `logics/requests/REQ-0004-sample-todo-cli-validation-docs.md`
- `logics/backlog/BL-0004-sample-todo-cli-foundation.md`
- `logics/backlog/BL-0005-sample-todo-cli-core-features.md`
- `logics/backlog/BL-0006-sample-todo-cli-validation-docs.md`
- `logics/tasks/TASK-0018-sample-todo-cli-create-project-foundation.md`
- `logics/tasks/TASK-0019-sample-todo-cli-implement-core-features.md`
- `logics/tasks/TASK-0020-sample-todo-cli-add-validation-and-docs.md`

## What Is Validated

- The Initial need, Primary need, and Loop state templates are usable for a small scenario.
- The macro loop can be represented with linked Logics records.
- The micro loop can be initialized before any Codex execution occurs.
- Planned request, backlog, and task records can be linked clearly.
- The first task execution can be accepted and used to advance the loop state.

## What Is Not Validated

- Core todo features are not implemented.
- TASK-0019 has not been executed.
- No auto push or auto merge behavior is exercised.

## Known Limitations

- Remaining planned sample tasks are not executed and do not authorize work in this repository.
- Completion criteria are sample-level and would need refinement before execution.
- This sample demonstrates state progression, not production implementation quality.

## Next Recommended Task

Prepare or execute [TASK-0019](../logics/tasks/TASK-0019-sample-todo-cli-implement-core-features.md) in the dedicated sample project workspace.
