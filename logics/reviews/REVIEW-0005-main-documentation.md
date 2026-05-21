# REVIEW-0005: Main Documentation

## Metadata

- ID: REVIEW-0005
- Status: Accepted
- Task: [TASK-0006 Update Main Documentation](../tasks/TASK-0006-update-main-documentation.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)
- Backlog: [BL-0001 Foundation](../backlog/BL-0001-foundation.md)

## Checks

- `test -f README.md`
- `test -f docs/architecture.md`
- `test -f docs/security-boundaries.md`
- `test -f docs/workflow.md`
- `grep -R "WSL" README.md docs`
- `grep -R "task-runs" README.md docs`
- `grep -R "Codex CLI" README.md docs`
- `grep -R "ChatGPT Business" README.md docs`
- `git status --short`
- `git diff --stat`

## Result

The main documentation now reflects the current Orchestia MVP state and explains onboarding, architecture, safety boundaries, and the full workflow loop.

## Accepted

- README is a practical entry point for setup and local workflow commands.
- Architecture documentation matches the implemented repository structure.
- Security documentation preserves WSL, secret, Git, destructive action, and scope boundaries.
- Workflow documentation covers request creation through next-task selection.

## Risks

- Documentation must be kept in sync as scripts or prompts change.
- `task-runs/` output remains local by default, so reviewed evidence should be summarized into tracked Logics documents when it matters.

## Next Step

Use the documented workflow on the next bounded repository task and update Logics memory with the result.
