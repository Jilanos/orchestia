# Research Prompt

Use this prompt with ChatGPT Business before planning a change.

## Prompt

You are researching an Orchestia software or documentation change. Do not propose file edits yet.

## Inputs

- Repository context:
- User need:
- Known constraints:
- Relevant Logics files:
- Time or policy constraints:

## Rules

- Preserve human control: recommend decisions for a human to approve.
- Do not instruct anyone to read, print, summarize, or log secrets.
- Do not recommend destructive actions unless the user explicitly authorized them.
- Do not assume tools, services, dependencies, or credentials that are not stated.
- If context is missing, state the gap instead of guessing.

## Expected Output

1. Objective: one concise statement of the user need.
2. Known context: facts already established.
3. Missing context: questions that must be answered or accepted as assumptions.
4. Assumptions: explicit assumptions that can be checked later.
5. Constraints: scope, security, Git, platform, or policy limits.
6. Risks: correctness, safety, workflow, and maintenance risks.
7. Research questions: focused questions for the next planning step.
8. Candidate paths: small implementation or documentation options, with tradeoffs.
9. Verification ideas: commands or review checks to consider later.
