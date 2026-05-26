# TASK-0064: Compact Codex Operating Context

## Objective

Create compact reusable Codex operating context documents so future Orchestia prompts can reference shared policy, current state, validation, and task contract material instead of repeating long instructions.

## Context

Orchestia v0.3 prompts have grown large because they restate repository state, safety policy, validation commands, and Codex task rules. The next tasks should be able to cite stable local documents and include only task-specific overrides.

## Authorized Scope

- `docs/codex-task-contract.md`
- `docs/orchestia-current-state.md`
- `docs/orchestia-standard-validation.md`
- `docs/orchestia-safety-policy-compact.md`
- `logics/tasks/TASK-0064-compact-codex-operating-context.md`
- `logics/reviews/REVIEW-0059-compact-codex-operating-context.md`

## Out Of Scope

- Script changes.
- Project logic changes.
- Runtime behavior changes.
- Changes to unrelated Logics records.
- Release tags or publication workflow changes.

## Expected Steps

1. Verify the repository is clean on `master`.
2. Confirm the new document, task, and review IDs do not already exist.
3. Add compact reusable context documents.
4. Document how future prompts should reference those files.
5. Run documentation-only validation.
6. Commit and push the records.

## Acceptance Criteria

- All four compact context documents exist.
- The documents cover task contract, current state, standard validation, and safety policy.
- The documents explain how future prompts should reference them.
- No scripts or project logic are modified.
- Review record exists with an explicit decision.

## Verification Commands

```bash
git status --short
test -f docs/codex-task-contract.md
test -f docs/orchestia-current-state.md
test -f docs/orchestia-standard-validation.md
test -f docs/orchestia-safety-policy-compact.md
test -f logics/tasks/TASK-0064-compact-codex-operating-context.md
test -f logics/reviews/REVIEW-0059-compact-codex-operating-context.md
grep -R "Future prompts" docs/codex-task-contract.md docs/orchestia-current-state.md docs/orchestia-standard-validation.md docs/orchestia-safety-policy-compact.md
git diff --stat
git diff --check
```

## Result

Complete. Compact reusable context documents were added for future prompt references, with no script or project logic changes.
