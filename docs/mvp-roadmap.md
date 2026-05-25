# MVP Roadmap

## Current State

Orchestia v0.1 provides the local workflow foundation: WSL-first workspace guidance, helper scripts, repository audit output, prompt templates, Logics templates, a validation checklist, a sample end-to-end run, and a release readiness review.

The next goal is v0.2: iterative need-to-completion orchestration.

The minimal state model for v0.2 is defined in [Orchestration State Model](orchestration-state-model.md), with reusable templates in `logics/templates/`.

The v0.2 orchestration prompts are `prompts/initial_need_intake_prompt.md`, `prompts/primary_need_decomposition_prompt.md`, and `prompts/orchestration_loop_prompt.md`.

A sample v0.2 scenario is documented in [Sample v0.2 Orchestration Scenario](sample-v0.2-orchestration-scenario.md).

The first state-driven loop runner has been introduced as `scripts/orchestia_loop.sh`. It reads Loop state, helps identify or run the next prepared prompt, collects evidence, and drafts reviews while keeping state updates and decisions human-supervised.

The first controlled Git flow automation has been introduced as `scripts/controlled_git_flow.sh`. It supports dry-run-first status, guarded auto-push, and guarded auto-merge commands for isolated branches under the documented policy.

Controlled Git flow validation has passed against a dedicated sample GitHub repository after manual remote setup. The validation covered dry-run and execute paths for pushing an isolated feature branch and merging it into `integration`.

Controlled Git flow handoff has been introduced in `scripts/orchestia_loop.sh`. The state-driven runner can now generate copyable `controlled_git_flow.sh` commands and a handoff report without executing push or merge.

Git-flow review draft support has been introduced in `scripts/orchestia_loop.sh`. The runner can now turn controlled Git-flow evidence into a draft review under `task-runs/` while leaving final decisions and Loop state updates human-owned.

Human-approved review finalization support has been introduced in `scripts/orchestia_loop.sh`. The runner can convert a draft under `task-runs/` into a versioned Logics review only when an explicit review ID, reviewed task, title, and decision are provided.

The first local cockpit has been introduced as `scripts/orchestia_ui.py`. It provides a read-only HTML view of Loop state, `task-runs/`, Logics records, reviews, and debug status on `127.0.0.1`.

Controlled auto loop mode has been introduced in `scripts/orchestia_loop.sh`. It creates auto-loop evidence under `task-runs/`, previews commands, supports human instructions and stop requests, requires explicit execution flags, requires explicit decisions, and advances Loop state only when the required human-provided fields are present.

Codex execution in controlled auto-loop mode has been introduced behind explicit `--execute-codex` or `--execute-all` flags. The loop now uses `codex exec`, captures execution and test evidence, and still requires human-owned decisions and explicit advancement fields.

The read-only sandbox blocker found during auto-loop Codex execution validation has been fixed by invoking `codex exec --sandbox workspace-write` for explicitly authorized Codex execution. Follow-up validation confirmed disposable workspace writes and test capture.

Auto-loop Codex execution has also been validated on the sample todo CLI project using the isolated `feature/auto-loop-sample-validation` branch. The run produced a README-only change, captured evidence, left the decision pending, and did not advance Loop state automatically.

The full controlled chain has been validated on the dedicated sample repository: auto-loop evidence was finalized into a Logics review, the sample feature branch was pushed through controlled Git flow, the branch was merged into `integration`, and a full-chain review was finalized.

v0.2-alpha release readiness is complete and recorded in [v0.2-alpha Release](v0.2-alpha-release.md). This alpha is not production-ready and remains human-supervised.

The v0.2-alpha negative-path validation suite has been introduced as `scripts/validate_negative_paths.sh`. It validated missing prompts, dry-runs, dirty workspaces, invalid decisions, protected branches, failed tests, merge conflicts, missing evidence, and missing `--execute` guardrails with disposable local repositories under `task-runs/`.

Real mini project validation has started with `job-offer-analyzer`, a local Python standard-library CLI for manually provided job descriptions. The foundation is registered as [IN-0002 Job Offer Analyzer](../logics/initial-needs/IN-0002-job-offer-analyzer.md), with Loop state [LS-0002](../logics/loop-states/LS-0002-job-offer-analyzer.md) advancing to parsing work.

## v0.2 Goal

v0.2 takes an initial user need, decomposes it into primary needs, and for each primary need runs a structured Logics and Codex execution loop until the primary need is complete or a firm blocker is reached.

The system must continue until the initial need is complete, all remaining work is explicitly out of scope, or a firm blocker prevents safe progress.

## Macro Loop

Initial need -> primary needs -> request/backlog/tasks per primary need -> completion review -> next primary need.

The macro loop includes:

- Initial need intake.
- Primary need decomposition.
- Request creation per primary need.
- Backlog item creation.
- Task generation.
- Completion review for each primary need.
- Next primary need selection.

## Micro Loop

Task -> Codex execution -> collect outputs -> review -> accept, revise, split or reject.

The micro loop includes:

- Codex prompt generation.
- Codex execution.
- Diff, logs and test collection.
- Review decision.
- Follow-up task creation when the decision is revise, split or reject.

## Loop Rules

- One task should remain bounded and reviewable.
- The review decision must be one of: accept, revise, split or reject.
- Accepted work can advance the current primary need.
- Revise means continue with a scoped correction task.
- Split means create smaller tasks before continuing.
- Reject means discard the approach and return to planning.
- The loop stops only when completion criteria are met or a firm blocker is documented.

## Completion Criteria

The initial need is complete only when every primary need is one of:

- Accepted as complete.
- Explicitly out of scope.
- Blocked by a documented firm blocker.

## Firm Blocker Criteria

Firm blocker examples include:

- Missing credentials.
- Unclear product decision.
- Unsafe command required.
- Failing external dependency.
- Insufficient repository context.
- Repeated Codex failure on the same task.
- Unavailable test environment.

## Human Control Points

- Approve the initial need and primary needs.
- Approve scope for each request, backlog item, and task.
- Approve execution mode before Codex runs.
- Review diffs, logs, tests, and review records.
- Decide whether work is complete, out of scope, blocked, or safe to continue.
- Explicitly authorize any tag, push to protected branch, or merge into protected branch.

## Execution Modes

- Manual mode: Codex proposes changes; human reviews, commits, pushes and merges.
- Assisted mode: Codex may prepare changes and commit locally; human still pushes and merges.
- Auto branch mode: Codex may create or use an isolated working branch, then commit and push to that branch after checks pass.
- Controlled auto merge mode: Codex may merge only into an explicitly authorized target branch.

## Controlled Auto Push And Merge

For v0.2, Orchestia may support controlled auto branch execution, controlled auto push, and controlled auto merge only for fresh projects or isolated branches and only behind explicit policy checks.

`main` and `master` remain protected by default. Auto push directly to main or master, or auto merge into main or master, requires an explicit override.

## Non-Goals For v0.2

- Full autonomy.
- Background agents or daemons.
- Secret management automation.
- Unrestricted push or merge.
- Force push.
- Cross-repository orchestration.
- Modifying personal Windows files.
- Bypassing failed checks.

## v0.2 Candidate Tasks

1. Exercise `scripts/orchestia_loop.sh` against a non-complete Loop state.
2. Add execution mode fields to Logics task templates.
3. Add review schema fields for primary need completion and blockers.
4. Define a manual primary-need decomposition example against a real project.
5. Add negative-path validation for controlled Git flow guardrails.
6. Add execution mode fields to task templates.
7. Add review evidence fields for controlled push and merge.
8. Update validation checklist for v0.2 execution modes.
