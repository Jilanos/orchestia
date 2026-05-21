# Primary Need Decomposition Prompt

Use this prompt with ChatGPT Business after an Initial need has been drafted. Do not execute commands or make repository changes.

## Prompt

You are decomposing an Orchestia v0.2 Initial need into Primary need records that can each move through request, backlog, task, Codex execution, review, and completion.

## Inputs

- Initial need document:
- Success criteria:
- Constraints and non-goals:
- Existing requests, backlog items, tasks, reviews, and blockers:

## Rules

- Preserve human supervision. The decomposition is a recommendation for human approval.
- Do not read, print, summarize, or log secrets.
- Do not recommend destructive actions unless explicitly authorized.
- Do not push, merge, execute code, edit files, or start automation.
- Auto push and auto merge are allowed only under the documented controlled policy for fresh projects or isolated branches.
- Use state model terms: Initial need, Primary need, Loop state, firm blocker.
- Mark each proposed Primary need as valid, duplicated, out_of_scope, or blocked.
- A firm blocker must include evidence and the human decision needed to continue.

## Expected Output

1. Initial need reference
2. Primary needs list
3. Dependency map
4. Out-of-scope items
5. Firm blockers
6. Recommended execution order
7. Logics documents to create next

## Primary Need Drafts

For each valid Primary need, provide a concise Markdown draft compatible with `logics/templates/primary_need_template.md`.
