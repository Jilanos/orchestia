# REVIEW-0014: Orchestration State Model

## Metadata

- ID: REVIEW-0014
- Status: Accepted
- Task: [TASK-0015 Define Orchestration State Model](../tasks/TASK-0015-define-orchestration-state-model.md)
- Backlog: [BL-0003 v0.2 Iterative Orchestration](../backlog/BL-0003-v0.2-iterative-orchestration.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)

## Checks

- `test -f docs/orchestration-state-model.md`
- `test -f logics/templates/initial_need_template.md`
- `test -f logics/templates/primary_need_template.md`
- `test -f logics/templates/loop_state_template.md`
- `grep -R "Initial need" docs/orchestration-state-model.md logics/templates`
- `grep -R "Primary need" docs/orchestration-state-model.md logics/templates`
- `grep -R "Loop state" docs/orchestration-state-model.md logics/templates`
- `grep -R "firm blocker" docs/orchestration-state-model.md`
- `grep -R "accept" docs/orchestration-state-model.md`
- `grep -R "revise" docs/orchestration-state-model.md`
- `grep -R "split" docs/orchestration-state-model.md`
- `grep -R "reject" docs/orchestration-state-model.md`
- `git status --short`
- `git diff --stat`

## Result

The v0.2 orchestration state model is documented and has reusable Logics templates for initial need, primary need, and loop state records.

## Accepted

- Initial need, primary need, and loop state are defined.
- Allowed statuses, task decisions, stop conditions, and firm blocker criteria are documented.
- README and roadmap reference the state model.
- No scripts or automation were added.

## Risks

- The model is currently documentation only.
- Future prompts and task templates must adopt these fields before the loop can be run consistently.

## Next Step

Use the new templates in one manual v0.2 orchestration run before implementing automation.
