# IN-0001: Sample Todo CLI

## Metadata

- ID: IN-0001
- Status: decomposed
- Created: 2026-05-21
- Review: [REVIEW-0016 Sample v0.2 Orchestration Scenario](../reviews/REVIEW-0016-sample-v0.2-orchestration-scenario.md)

## Original User Need

Build a small local todo CLI that can add, list, complete, and persist todo items in a simple local file.

## Success Criteria

- A user can add a todo item from the command line.
- A user can list open and completed todo items.
- A user can mark a todo item complete.
- Todo items persist between CLI runs.
- Basic usage is documented.

## Constraints

- Local-only CLI.
- No service, daemon, database server, or network dependency.
- No secrets or credentials.
- Work must remain bounded to an explicitly authorized project repository.

## Non-Goals

- No sync across machines.
- No multi-user support.
- No graphical interface.
- No package publishing.
- No auto push or auto merge unless separately authorized under policy.

## Primary Needs

- [PN-0001 Project Foundation](../primary-needs/PN-0001-project-foundation.md)
- [PN-0002 Core Todo Features](../primary-needs/PN-0002-core-todo-features.md)
- [PN-0003 Validation And Docs](../primary-needs/PN-0003-validation-and-docs.md)

## Global Status

Allowed values: intake, decomposed, in_progress, complete, blocked, cancelled.

- Status: decomposed

## Notes

- This is a sample Initial need for demonstrating Orchestia v0.2 state, not an implementation request.
