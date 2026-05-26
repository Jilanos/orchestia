# TASK-0066: Add Token Efficiency Tooling Guidance

## Objective

Document optional use of RTK for command-output compression and Caveman for compact agent communication while keeping Orchestia usable without either tool.

## Context

TASK-0065 added token efficiency policy and Compact Prompt Mode. TASK-0066 adds optional tooling guidance and clarifies that compression must preserve safety-critical facts.

## Authorized Scope

- `docs/token-efficiency-tooling.md`
- `docs/token-efficiency-policy.md`
- `docs/compact-prompt-mode.md`
- `docs/orchestia-current-state.md`
- `logics/tasks/TASK-0066-add-token-efficiency-tooling.md`
- `logics/reviews/REVIEW-0061-token-efficiency-tooling.md`

## Out Of Scope

- Installing tools.
- Vendoring external code.
- Adding dependencies.
- Script changes.
- Prompt changes.
- Codex, autonomous-loop, or orchestration-run execution.
- Real project changes.
- Secret access.

## Expected Steps

1. Read the compact task contract, current state, token efficiency policy, and Compact Prompt Mode.
2. Create optional token-efficiency tooling guidance.
3. Reference RTK and Caveman from existing token-efficiency docs.
4. Keep fallback behavior explicit.
5. Record this task and review.
6. Run documentation validation.
7. Commit and push authorized files.

## Acceptance Criteria

- `docs/token-efficiency-tooling.md` explains RTK, Caveman, optional usage, fallback behavior, risks, examples, and no mandatory dependency policy.
- `docs/token-efficiency-policy.md` references RTK, Caveman, fallback behavior, and safety-critical facts.
- `docs/compact-prompt-mode.md` references Caveman as optional communication compression.
- No tools are installed, vendored, or required.
- No scripts, prompts, dependencies, Codex runs, orchestration runs, or real projects are changed.

## Validation Commands

```bash
test -f docs/token-efficiency-tooling.md
test -f logics/tasks/TASK-0066-add-token-efficiency-tooling.md
test -f logics/reviews/REVIEW-0061-token-efficiency-tooling.md
grep -R "RTK" docs/token-efficiency-tooling.md docs/token-efficiency-policy.md
grep -R "Caveman" docs/token-efficiency-tooling.md docs/compact-prompt-mode.md
grep -R "optional" docs/token-efficiency-tooling.md
grep -R "fallback" docs/token-efficiency-tooling.md
grep -R "safety-critical" docs/token-efficiency-policy.md
git diff --check
git status --short
```

## Result

Complete. Optional RTK and Caveman guidance was documented without adding dependencies or changing runtime behavior.
