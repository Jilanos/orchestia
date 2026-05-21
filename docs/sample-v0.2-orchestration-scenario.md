# Sample v0.2 Orchestration Scenario

## Purpose

This sample shows how Orchestia v0.2 can represent an initial user need, decompose it into Primary need records, and track the first Loop state. It is documentation only and does not create a todo CLI or execute Codex on an external project.

## Sample Initial User Need

Build a small local todo CLI that can add, list, complete, and persist todo items in a simple local file.

## Primary Need Decomposition

- [PN-0001 Project Foundation](../logics/primary-needs/PN-0001-project-foundation.md): establish the project structure, runtime choice, and minimal CLI entry point.
- [PN-0002 Core Todo Features](../logics/primary-needs/PN-0002-core-todo-features.md): implement add, list, complete, and local persistence behavior.
- [PN-0003 Validation And Docs](../logics/primary-needs/PN-0003-validation-and-docs.md): add validation checks and concise user documentation.

## Macro Loop

Initial need -> primary needs -> request/backlog/tasks per primary need -> completion review -> next primary need.

For this sample, [IN-0001](../logics/initial-needs/IN-0001-sample-todo-cli.md) is decomposed into three Primary need records. Each Primary need has planned request, backlog, and task references that would be created in future work.

## Micro Loop

Task -> Codex execution -> collect outputs -> review -> accept, revise, split or reject.

The sample [LS-0001 Loop state](../logics/loop-states/LS-0001-sample-todo-cli.md) starts at PN-0001 and points to planned request, backlog, and task records. No Codex execution has occurred yet.

## Sample Logics Files Created

- `logics/initial-needs/IN-0001-sample-todo-cli.md`
- `logics/primary-needs/PN-0001-project-foundation.md`
- `logics/primary-needs/PN-0002-core-todo-features.md`
- `logics/primary-needs/PN-0003-validation-and-docs.md`
- `logics/loop-states/LS-0001-sample-todo-cli.md`

## What Is Validated

- The Initial need, Primary need, and Loop state templates are usable for a small scenario.
- The macro loop can be represented with linked Logics records.
- The micro loop can be initialized before any Codex execution occurs.
- Planned request, backlog, and task references can be marked clearly.

## What Is Not Validated

- No todo CLI source code is created.
- No Codex execution occurs.
- No external project is modified.
- No auto push or auto merge behavior is exercised.

## Known Limitations

- Planned request, backlog, and task files do not exist yet.
- Completion criteria are sample-level and would need refinement before execution.
- This sample demonstrates state shape, not implementation quality.

## Next Recommended Task

Create the planned request, backlog, and first task for PN-0001 as a manual v0.2 orchestration run.
