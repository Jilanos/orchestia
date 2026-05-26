# Compact Prompt Mode

## Purpose

Compact Prompt Mode is the preferred prompt style for routine Orchestia Codex tasks. It keeps prompts short by referencing shared repository docs and stating only task-specific overrides.

## Required Sections

- Context references
- Objective
- Authorized scope
- Out of scope
- Expected steps
- Validation
- Git instructions
- Acceptance criteria
- Watch points

## Optional Sections

- Current expected state, when it differs from `docs/orchestia-current-state.md`
- Exact command sequence, when ordering matters
- Review decision rules
- Rollback or blocker documentation instructions
- Evidence paths

## Compact Task Prompt Template

```text
Use:
- docs/codex-task-contract.md
- docs/orchestia-current-state.md
- docs/orchestia-standard-validation.md
- docs/orchestia-safety-policy-compact.md
- docs/compact-prompt-mode.md

Objective:
Do TASK-00XX: <task title>.

Authorized scope:
- <files/directories>

Out of scope:
- <forbidden actions>

Expected steps:
1. Verify clean state and no ID collisions.
2. Make the scoped change.
3. Run validation.
4. Create/update TASK and REVIEW.
5. Commit and push if accepted.

Validation:
- Use Documentation-Only Validation.
- Extra checks: <grep/tests>

Git:
- Stage only authorized files.
- Commit: "<message>"
- Push: origin master.

Acceptance:
- <observable success conditions>
```

## Compact Implementation Prompt Template

```text
Use Compact Prompt Mode and the four compact operating docs.

Objective:
Implement <feature> for <surface>.

Authorized files:
- <exact files>

Constraints:
- No dependencies.
- No secrets.
- No unrelated refactors.
- Preserve existing behavior unless stated.

Steps:
1. Read only target files and direct references.
2. Implement minimal change.
3. Add focused tests or smoke checks.
4. Document TASK/REVIEW result.

Validation:
- Base Repository Validation.
- Script Validation if scripts changed.
- Feature-specific command: <command>.

Git:
Commit "<message>" and push origin/master.
```

## Compact Validation Prompt Template

```text
Use Compact Prompt Mode.

Objective:
Validate <feature/workflow> without modifying product files.

Scope:
- Read: <docs/scripts>
- Write: task-runs/ evidence and TASK/REVIEW only.

Out of scope:
- No Codex/autonomous-loop/orchestration-run unless explicitly listed.
- No pushes, merges, tags, dependencies, or real project edits.

Validation:
1. Run <commands>.
2. Capture evidence paths.
3. Record pass/fail and blockers.

Decision:
REVIEW decision accept only if all required checks pass; otherwise revise.
```

## Compact Release-Readiness Prompt Template

```text
Use Compact Prompt Mode and current-state docs.

Objective:
Prepare <release> readiness.

Authorized files:
- docs/<release>.md
- README.md
- docs/mvp-roadmap.md
- TASK/REVIEW records

Out of scope:
- No scripts, prompts, Codex runs, orchestration-run, or project edits.
- No tag unless REVIEW decision is accept and tagging is authorized.

Validation:
- Base Repository Validation.
- Required release smoke checks: <list>.
- Documentation-Only Validation.

Git:
Commit "<message>", push origin/master, then tag only if accepted.
```

## Example Under 80 Lines

The following example is intentionally under 80 lines.

```text
Use docs/codex-task-contract.md, docs/orchestia-current-state.md,
docs/orchestia-standard-validation.md, docs/orchestia-safety-policy-compact.md,
and docs/compact-prompt-mode.md.

Objective:
Add TASK-00XX documentation for a completed validation run.

Authorized files:
- docs/example-validation.md
- logics/tasks/TASK-00XX-example.md
- logics/reviews/REVIEW-00XX-example.md

Out of scope:
- No scripts, prompts, Codex runs, project edits, pushes to projects, or tags.

Validation:
- Documentation-Only Validation.
- grep -R "accept\\|revise" logics/reviews/REVIEW-00XX-example.md

Git:
Stage only authorized files.
Commit "Document example validation".
Push origin/master.

Acceptance:
- Docs and Logics records exist.
- Review decision is explicit.
- Final working tree is clean.
```

## Usage Rule

Future prompts should cite Compact Prompt Mode by name and include only the sections needed for the task. Use long prompts only when the risk or command ordering justifies the extra tokens.
