# REVIEW-0013: v0.2 Roadmap And Auto Policy

## Metadata

- ID: REVIEW-0013
- Status: Accepted
- Task: [TASK-0014 Define v0.2 Iterative Orchestration And Auto Policy](../tasks/TASK-0014-define-v0.2-iterative-orchestration-and-auto-policy.md)
- Backlog: [BL-0003 v0.2 Iterative Orchestration](../backlog/BL-0003-v0.2-iterative-orchestration.md)
- ADR: [ADR-0002 Controlled Auto Push And Merge Policy](../adr/ADR-0002-controlled-auto-push-merge-policy.md)
- Request: [REQ-0001 Orchestia MVP](../requests/REQ-0001-orchestia-mvp.md)

## Checks

- `grep -R "v0.2" docs/mvp-roadmap.md README.md`
- `grep -R "primary needs" docs/mvp-roadmap.md`
- `grep -R "firm blocker" docs/mvp-roadmap.md`
- `grep -R "Manual mode" README.md docs logics/adr`
- `grep -R "Auto branch mode" README.md docs logics/adr`
- `grep -R "Controlled auto merge mode" README.md docs logics/adr`
- `grep -R "force push" docs/security-boundaries.md logics/adr/ADR-0002-controlled-auto-push-merge-policy.md`
- `grep -R "main or master" docs/security-boundaries.md docs/workflow.md docs/mvp-roadmap.md`
- `grep -R "accept" docs/mvp-roadmap.md`
- `grep -R "revise" docs/mvp-roadmap.md`
- `grep -R "split" docs/mvp-roadmap.md`
- `grep -R "reject" docs/mvp-roadmap.md`
- `git status --short`
- `git diff --stat`

## Result

The v0.2 direction is documented as an iterative need-to-completion orchestration loop with controlled auto push and controlled auto merge allowed only under explicit guardrails.

## Accepted

- The roadmap defines initial need intake, primary needs, requests, backlog items, tasks, Codex prompt generation, execution, evidence collection, review, loop rules, completion criteria, firm blockers, and human control points.
- The workflow explains the macro loop and micro loop.
- The safety policy keeps main and master protected by default.
- ADR-0002 records controlled auto push and merge policy.
- No scripts or automation were implemented.

## Risks

- Future implementation must update prompts and templates before scripts.
- Auto push and auto merge remain policy only until guardrail checks are implemented.
- Existing out-of-scope policy files from earlier planning tasks may still need cleanup or consolidation in a later commit.

## Next Step

Update Logics templates and prompt templates to include execution mode, primary need linkage, target branch, and blocker fields before implementing any auto branch or auto merge scripts.
