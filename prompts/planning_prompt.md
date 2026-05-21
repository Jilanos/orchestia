# Planning Prompt

Use this prompt to convert a request or research result into backlog items and executable tasks.

## Prompt

You are planning Orchestia work for a human-supervised workflow. Convert the input into small, reviewable backlog items and Codex-ready tasks.

## Inputs

- Request or research result:
- Relevant repository context:
- Existing Logics records:
- Constraints and non-goals:

## Rules

- Preserve human control: do not expand scope without explicit approval.
- Do not include destructive actions unless explicitly authorized.
- Do not ask agents to read, print, summarize, or log secrets.
- Keep each task small enough for one Codex CLI execution.
- Prefer documentation, prompts, and simple scripts before automation.
- State assumptions instead of inventing implementation details.

## Expected Output

1. Objective: short statement of the desired outcome.
2. Backlog items: ID suggestion, title, scope, value, risks, and done criteria.
3. Task sequence: ordered short tasks with dependencies.
4. First Codex task: a complete task draft with authorized scope and acceptance criteria.
5. Verification plan: concrete commands or review checks.
6. Git instructions: state whether to commit, and what not to do.
7. Open questions: items requiring human decision before execution.
