# REVIEW-0004: Prompt Templates

## Metadata

- ID: REVIEW-0004
- Status: Accepted
- Task: [TASK-0005 Improve Prompt Templates](../tasks/TASK-0005-improve-prompt-templates.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Backlog: [BL-0001 Foundation](../backlog/BL-0001-foundation.md)

## Checks

- `test -f prompts/research_prompt.md`
- `test -f prompts/planning_prompt.md`
- `test -f prompts/codex_task_prompt.md`
- `test -f prompts/review_prompt.md`
- `test -f prompts/repo_audit_prompt.md`
- `grep -R "Objective" prompts`
- `grep -R "Acceptance criteria" prompts/codex_task_prompt.md`
- `grep -R "accept, revise, split or reject" prompts/review_prompt.md`
- `git status --short`
- `git diff --stat`

## Result

The prompt templates now define repeatable standards for research, planning, Codex execution, review, and repository audit workflows.

## Accepted

- The templates are written in English and directly copyable.
- Each template includes clear rules and expected output.
- The Codex task template includes the mandatory task format.
- The review template requires one explicit decision.
- The repository audit template covers structure, operating assets, risks, and next tasks.

## Risks

- The templates may need refinement after repeated real task runs.
- Overly large user requests still need to be split before Codex execution.

## Next Step

Use the improved prompts for the next end-to-end Orchestia workflow and record any needed refinements as a small follow-up task.
