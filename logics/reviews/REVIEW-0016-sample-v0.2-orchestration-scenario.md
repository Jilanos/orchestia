# REVIEW-0016: Sample v0.2 Orchestration Scenario

## Metadata

- ID: REVIEW-0016
- Status: Accepted
- Task: [TASK-0017 Add Sample v0.2 Orchestration Scenario](../tasks/TASK-0017-add-sample-v0.2-orchestration-scenario.md)
- Backlog: [BL-0003 v0.2 Iterative Orchestration](../backlog/BL-0003-v0.2-iterative-orchestration.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)

## Checks

- `test -f docs/sample-v0.2-orchestration-scenario.md`
- `test -f logics/initial-needs/IN-0001-sample-todo-cli.md`
- `test -f logics/primary-needs/PN-0001-project-foundation.md`
- `test -f logics/primary-needs/PN-0002-core-todo-features.md`
- `test -f logics/primary-needs/PN-0003-validation-and-docs.md`
- `test -f logics/loop-states/LS-0001-sample-todo-cli.md`
- `grep -R "Initial need" docs/sample-v0.2-orchestration-scenario.md logics/initial-needs`
- `grep -R "Primary need" docs/sample-v0.2-orchestration-scenario.md logics/primary-needs`
- `grep -R "Loop state" docs/sample-v0.2-orchestration-scenario.md logics/loop-states`
- `grep -R "sample-v0.2-orchestration-scenario.md" README.md docs/mvp-roadmap.md`

## Result

The sample scenario demonstrates how the v0.2 state model can represent an initial need, primary needs, and the first loop state.

## Accepted

- The sample Initial need, three Primary needs, and Loop state exist.
- Planned request, backlog, and task references are clearly marked.
- The sample explains the macro loop and micro loop.
- No todo CLI source code, scripts, automation, or external project changes were created.

## Risks

- The sample has not yet been expanded into actual request, backlog, and task records.
- The sample validates state shape only, not Codex execution.

## Next Step

Create the planned request, backlog, and first task for PN-0001 as a manual v0.2 orchestration run.
