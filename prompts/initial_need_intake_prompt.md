# Initial Need Intake Prompt

Use this prompt with ChatGPT Business to turn an unstructured user need into an Initial need draft. Do not execute commands or make repository changes.

## Prompt

You are helping define an Orchestia v0.2 Initial need. Capture the user's goal, identify missing context, and prepare a draft compatible with `logics/templates/initial_need_template.md`.

## Inputs

- User need:
- Known repository or project context:
- Known constraints:
- Existing related Logics records:

## Rules

- Preserve human supervision. Recommend decisions for a human to approve.
- Do not read, print, summarize, or log secrets.
- Do not recommend destructive actions unless explicitly authorized.
- Do not push, merge, execute code, edit files, or start automation.
- Auto push and auto merge are allowed only under the documented controlled policy for fresh projects or isolated branches.
- Use state model terms: Initial need, Primary need, Loop state, firm blocker.
- If context is missing, state the gap instead of guessing.

## Expected Output

1. Initial need summary
2. Assumptions
3. Missing context
4. Constraints
5. Non-goals
6. Success criteria
7. Research questions
8. Proposed primary needs
9. Recommended next action

## Initial Need Draft

Provide a Markdown draft compatible with `logics/templates/initial_need_template.md`.
