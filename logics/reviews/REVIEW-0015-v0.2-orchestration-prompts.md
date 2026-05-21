# REVIEW-0015: v0.2 Orchestration Prompts

## Metadata

- ID: REVIEW-0015
- Status: Accepted
- Task: [TASK-0016 Add v0.2 Orchestration Prompts](../tasks/TASK-0016-add-v0.2-orchestration-prompts.md)
- Backlog: [BL-0003 v0.2 Iterative Orchestration](../backlog/BL-0003-v0.2-iterative-orchestration.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)

## Checks

- `test -f prompts/initial_need_intake_prompt.md`
- `test -f prompts/primary_need_decomposition_prompt.md`
- `test -f prompts/orchestration_loop_prompt.md`
- `grep -R "Initial need" prompts/initial_need_intake_prompt.md prompts/primary_need_decomposition_prompt.md prompts/orchestration_loop_prompt.md`
- `grep -R "Primary need" prompts/initial_need_intake_prompt.md prompts/primary_need_decomposition_prompt.md prompts/orchestration_loop_prompt.md`
- `grep -R "Loop state" prompts/orchestration_loop_prompt.md`
- `grep -R "firm blocker" prompts`
- `grep -R "accept" prompts/orchestration_loop_prompt.md`
- `grep -R "revise" prompts/orchestration_loop_prompt.md`
- `grep -R "split" prompts/orchestration_loop_prompt.md`
- `grep -R "reject" prompts/orchestration_loop_prompt.md`
- `grep -R "initial_need_intake_prompt.md" README.md docs/workflow.md docs/mvp-roadmap.md`
- `grep -R "primary_need_decomposition_prompt.md" README.md docs/workflow.md docs/mvp-roadmap.md`
- `grep -R "orchestration_loop_prompt.md" README.md docs/workflow.md docs/mvp-roadmap.md`

## Result

The v0.2 orchestration prompts now support Initial need intake, Primary need decomposition, and manual Loop state planning.

## Accepted

- The prompts are written in English and directly copyable.
- The prompts use state model terminology.
- The prompts preserve human supervision and safety boundaries.
- Controlled auto push and controlled auto merge are referenced only under documented guardrails.
- No automation was implemented.

## Risks

- The prompts still need to be exercised in a real v0.2 manual orchestration run.
- Existing prompt templates were intentionally not modified, so users must choose the new prompts explicitly for v0.2 orchestration.

## Next Step

Use the new prompts and state templates in one manual v0.2 orchestration run.
