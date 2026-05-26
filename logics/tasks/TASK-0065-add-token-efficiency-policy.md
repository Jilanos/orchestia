# TASK-0065: Add Token Efficiency Policy

## Objective

Make Orchestia explicitly token-efficient for future Codex work by adding a token efficiency policy and Compact Prompt Mode templates.

## Context

TASK-0064 added compact reusable operating context documents. TASK-0065 builds on that by defining when to reference those documents, how short future prompts should be, and how to summarize evidence without repeating large context blocks.

## Authorized Scope

- `docs/token-efficiency-policy.md`
- `docs/compact-prompt-mode.md`
- `docs/codex-task-contract.md`
- `docs/orchestia-current-state.md`
- `logics/tasks/TASK-0065-add-token-efficiency-policy.md`
- `logics/reviews/REVIEW-0060-token-efficiency-policy.md`

## Out Of Scope

- Script changes.
- Prompt file changes.
- Existing Logics record changes other than this task and review.
- Codex, autonomous-loop, or orchestration-run execution.
- Real project changes.
- Dependency changes.
- Secret access.

## Expected Steps

1. Read the compact operating docs and v0.3 context docs.
2. Create a token efficiency policy.
3. Create Compact Prompt Mode templates.
4. Reference Compact Prompt Mode from the Codex task contract.
5. Refresh current-state with the latest known commit and next focus.
6. Run documentation validation.
7. Commit and push the authorized files.

## Acceptance Criteria

- `docs/token-efficiency-policy.md` exists and includes reference-over-repetition, compact review, compact validation, evidence summarization, stop condition, and bad/good prompt examples.
- `docs/compact-prompt-mode.md` exists and includes compact task, implementation, validation, and release-readiness templates.
- `docs/codex-task-contract.md` references Compact Prompt Mode.
- `docs/orchestia-current-state.md` records the latest known pre-task commit and v0.3 focus.
- Review decision is explicit.
- Final working tree is clean after commit and push.

## Validation Commands

```bash
test -f docs/token-efficiency-policy.md
test -f docs/compact-prompt-mode.md
test -f logics/tasks/TASK-0065-add-token-efficiency-policy.md
test -f logics/reviews/REVIEW-0060-token-efficiency-policy.md
grep -R "reference-over-repetition" docs/token-efficiency-policy.md
grep -R "Compact Prompt Mode" docs/compact-prompt-mode.md docs/codex-task-contract.md
grep -R "80 lines" docs/compact-prompt-mode.md docs/token-efficiency-policy.md
git diff --check
git status --short
```

## Result

Complete. Token efficiency policy and Compact Prompt Mode were added, and compact context references were updated without script, prompt, or project logic changes.
