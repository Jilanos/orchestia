# Token Efficiency Policy

## Purpose

Token efficiency matters because Orchestia tasks often combine repository state, safety rules, validation commands, and implementation instructions. Repeating all of that in every prompt makes work slower, harder to review, and more likely to drift from the current repository state. Compact prompts should cite shared local documents, then state only task-specific overrides.

## Recommended Limits

- Max recommended prompt size: 120 lines for normal Codex tasks.
- Max recommended context docs per task: 4 compact docs plus task-specific files.
- Target compact prompt examples: under 80 lines when the task is narrow.
- Long prompts are allowed when a task is high-risk, cross-repository, release-critical, or requires exact command sequencing that cannot safely be summarized.

## Reference-Over-Repetition Rule

Use reference-over-repetition as the default. A future prompt should cite stable local references such as:

- `docs/codex-task-contract.md`
- `docs/orchestia-current-state.md`
- `docs/orchestia-standard-validation.md`
- `docs/orchestia-safety-policy-compact.md`
- `docs/compact-prompt-mode.md`
- `docs/token-efficiency-tooling.md` when optional RTK or Caveman guidance is relevant

Then it should add only the task-specific objective, authorized files, forbidden actions, verification commands, and Git instructions.

## Optional Tooling Rule

RTK may be used as optional output compression for long command results. Caveman may be used as optional communication compression for compact handoffs. Neither tool is required, and missing tools should fall back to concise plain text summaries and Compact Prompt Mode.

Compression must not remove safety-critical facts. Keep dirty working trees, failed checks, unauthorized files, protected branches, remotes, destructive commands, secret risks, decisions, blockers, and exact evidence paths explicit.

## Compact Review Rule

Reviews should focus on findings, risks, missing verification, scope drift, and the decision. Do not restate the entire implementation history when links or file references already provide the evidence.

## Compact Validation Rule

Prompts should cite validation blocks from `docs/orchestia-standard-validation.md` and list only extra checks unique to the task. A prompt should not paste large standard validation blocks unless the executor cannot access the repository docs.

## task-runs Evidence Summarization Rule

When documenting `task-runs/` evidence, cite run directory names and summarize the decisive files. Do not paste full logs unless a failure requires a short excerpt. Prefer:

- run directory;
- command executed;
- pass/fail result;
- decision file or summary path;
- blocker excerpt only when needed.

## Context Reading Stop Condition

If Codex starts reading broad context beyond the referenced docs and task-specific files, stop and reassess. Continue only if the extra file is needed to verify current behavior, understand an authorized target, or resolve a concrete blocker. Record why additional context was needed in the final response or review.

## Bad Prompt Example

```text
Repeat every safety rule, all v0.2-beta history, all v0.3 roadmap text,
all standard validation commands, and the full current-state narrative.
Now make a two-file documentation change.
```

Why it is bad: it spends most of the prompt on stable context that already exists in repository docs.

## Good Prompt Example

```text
Use docs/codex-task-contract.md, docs/orchestia-current-state.md,
docs/orchestia-standard-validation.md, and
docs/orchestia-safety-policy-compact.md.

Objective: add a documentation-only policy file.
Authorized files: docs/example-policy.md, logics/tasks/TASK-0000.md,
logics/reviews/REVIEW-0000.md.
Validation: Documentation-Only Validation plus grep for "policy".
Git: commit "Add example policy" and push origin/master.
```

Why it is good: it is task-specific, references stable context, and stays under 80 lines.

## Good Release Prompt Example

```text
Use Compact Prompt Mode and the four compact operating docs.
Objective: prepare release readiness only.
Authorized files: docs/vX-release.md, README.md, TASK, REVIEW.
Do not modify scripts, run Codex, run orchestration-run, or tag unless the
review decision is accept.
Validation: release-specific checks plus Documentation-Only Validation.
Git: commit, push, then tag only if accepted.
```

This remains concise while preserving release safety gates.
