# MVP Roadmap

## Current MVP State

Orchestia has a usable local foundation for human-supervised AI-assisted software development. The repository supports a WSL-first workflow with documentation, prompt templates, helper scripts, a repository audit script, Logics project memory, and local `task-runs/` output collection.

## Completed Foundation Items

- Public GitHub repository.
- WSL-first workspace guidance.
- Main documentation for architecture, security, and workflow.
- Reusable prompts for research, planning, Codex tasks, reviews, and audits.
- Safe helper scripts for environment checks, Codex command preparation, diff capture, test capture, result summaries, and repository audits.
- Tracked Logics directories and initial project memory.
- `.gitignore` policy for generated task-run outputs and local artifacts.

## Remaining MVP Milestones

- Task file schema hardening.
- Review decision schema.
- Sample end-to-end task run.
- Repo audit review loop.
- Lightweight validation checklist.
- Optional Logics Manager compatibility check.
- User documentation cleanup.
- Release tag for MVP v0.1.

## Non-Goals

- Full autonomy or background agent execution.
- Cross-repository orchestration.
- Secret management automation.
- GitHub Actions or deployment automation.
- Global dependency installation.
- Broad framework or service integration.

full autonomy is explicitly out of scope for the MVP. The project should keep humans responsible for approving scope, reviewing diffs, and choosing the next task.

## Risk Register

- Scope drift: tasks may grow beyond one bounded Codex execution. Mitigation: split work before execution.
- Weak schemas: Logics files may vary too much to review consistently. Mitigation: harden task and review templates.
- Unproven loop: the workflow needs at least one complete sample run. Mitigation: execute and review a small documentation-only task.
- Local output loss: `task-runs/` is ignored by Git. Mitigation: summarize important evidence into tracked Logics reviews.
- Safety erosion: convenience automation could weaken human control. Mitigation: keep scripts local, transparent, and non-destructive.

## Proposed Next Tasks

1. Define a concise task file schema and checklist for `logics/tasks/`.
2. Define a review decision schema for accept, revise, split, and reject.
3. Run one sample end-to-end task and record the result in Logics memory.
4. Use `scripts/audit_repo.sh` and review the generated audit with `prompts/repo_audit_prompt.md`.
5. Add a lightweight MVP validation checklist.
6. Check optional Logics Manager compatibility for folder names and document conventions.
7. Clean up user-facing documentation after the sample run.
8. Prepare an MVP v0.1 release tag task, without tagging until explicitly authorized.

## MVP Completion Criteria

- A user can start from the README and understand the WSL-first workflow.
- A request can be researched, planned, executed as a bounded Codex task, reviewed, and reinjected into the next task.
- Task and review documents follow stable schemas.
- Helper scripts collect local evidence without destructive actions.
- Repository audit output can be reviewed and summarized into Logics memory.
- Security boundaries remain visible and unchanged.
- Remaining MVP risks are documented or accepted before an MVP v0.1 tag is created.
