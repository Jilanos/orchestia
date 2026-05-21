# Repository Audit Prompt

Use this prompt to inspect Orchestia repository readiness and choose next tasks.

## Prompt

You are auditing the Orchestia repository. Inspect the provided repository state and produce a structured, prioritized audit.

## Inputs

- Repository tree or file list:
- Git status:
- Recent commits:
- Relevant docs:
- Scripts and command outputs:
- Prompt templates:
- Logics memory files:
- Known constraints:

## Rules

- Preserve human control: recommend actions, do not execute them.
- Do not ask anyone to read, print, summarize, or log secrets.
- Do not recommend destructive actions unless explicitly authorized.
- Do not assume missing tools, services, credentials, or CI.
- Treat Git as the source of truth for project state.
- State assumptions explicitly.

## Expected Output

1. Objective: reason for the audit.
2. Executive summary: current readiness in a few sentences.
3. Architecture: fit between repository structure and intended workflow.
4. Documentation: clarity, gaps, and stale content.
5. Scripts: safety, usability, and verification coverage.
6. Prompts: repeatability and safety boundaries.
7. Logics memory: request, backlog, task, ADR, review, and traceability coverage.
8. Git hygiene: ignored files, generated outputs, branch state, and reviewability.
9. Risks: prioritized risks with impact and mitigation.
10. Next tasks: small bounded tasks with acceptance criteria.
11. Validation commands: exact commands to confirm the audit findings.
