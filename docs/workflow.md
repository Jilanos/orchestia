# Workflow

## v0.2 Iterative Orchestration Loop

v0.2 extends the local workflow into an iterative need-to-completion loop:

Initial user need -> primary needs -> request per primary need -> backlog items -> executable tasks -> Codex prompt generation -> Codex execution -> diff, logs and test collection -> review -> repeat until each primary need is complete or blocked.

The loop continues until the initial need is complete, all remaining work is explicitly out of scope, or a firm blocker prevents safe progress.

Use `prompts/initial_need_intake_prompt.md`, `prompts/primary_need_decomposition_prompt.md`, and `prompts/orchestration_loop_prompt.md` to run this loop manually before any automation exists.

## Macro Loop

The macro loop is:

Initial need -> primary needs -> request/backlog/tasks per primary need -> completion review -> next primary need.

Each primary need must have a request, backlog slice, executable tasks, and a completion review before the loop moves on.

## Micro Loop

The micro loop is:

Task -> Codex execution -> collect outputs -> review -> accept, revise, split or reject.

The review decision controls the next step. Accept advances the current need, revise creates a correction task, split creates smaller tasks, and reject returns to planning.

## 1. Request Creation

Capture the user need in `logics/requests/`. Include the desired outcome, known context, constraints, open questions, and links to related Logics records.

## 2. Research

Use ChatGPT Business with `prompts/research_prompt.md` to analyze the request. Identify missing context, assumptions, risks, constraints, research questions, candidate paths, and verification ideas.

## 3. Planning

Use `prompts/planning_prompt.md` to convert the request or research result into backlog items and short executable tasks. Keep each task small enough for one Codex CLI execution.

## 4. Backlog Slicing

Record approved slices in `logics/backlog/`. Each slice should state scope, value, risks, dependencies, and done criteria.

## 5. Codex Task Generation

Create a bounded task in `logics/tasks/` using `prompts/codex_task_prompt.md`. The task should include objective, context, authorized scope, out-of-scope actions, expected steps, test commands, acceptance criteria, watch points, and security rules.

Use `logics/templates/task_template.md` when creating a new task file.

## 6. Manual Or Semi-Manual Codex Execution

Print the Codex command first:

```bash
bash scripts/run_codex_task.sh logics/tasks/TASK-0001-initial-scaffold.md
```

Run Codex only after the task scope is approved:

```bash
bash scripts/run_codex_task.sh --execute logics/tasks/TASK-0001-initial-scaffold.md
```

Codex should inspect the repository, make only scoped edits, run the requested checks, and report the result.

## Execution Modes

Orchestia supports four documented execution modes. The mode must be declared by the project or task before execution.

- Manual mode: Codex proposes changes; a human reviews, commits, pushes, and merges.
- Assisted mode: Codex may prepare changes and commit locally; a human still pushes and merges.
- Auto branch mode: Codex may create or use an isolated working branch, then commit and push to that branch after checks pass.
- Controlled auto merge mode: Codex may merge only into an explicitly authorized target branch.

For auto branch mode and controlled auto merge mode, `main` and `master` are protected by default. Pushing directly to `main` or `master`, or merging into `main` or `master`, requires an explicit override; main or master are never implicit automation targets. The target branch must be declared, the working tree must be clean before the task starts, required checks must pass, `git diff --stat` must be reviewed or included in the result, and the automation must produce a review record.

Controlled auto push and controlled auto merge are intended only for fresh projects or isolated branches. They are not full autonomy and must not bypass failed checks, include secrets, merge out-of-scope changes, or modify files outside the repository.

## 7. Diff Collection

Collect Git inspection output into a timestamped local run directory:

```bash
bash scripts/collect_diff.sh
```

The generated files live under `task-runs/` and are ignored by Git by default.

## 8. Test Result Collection

Run verification commands directly or capture them with:

```bash
bash scripts/collect_test_results.sh -- bash -n scripts/check_environment.sh
```

The helper records the command, output, and exit code under `task-runs/`.

## 9. Review

Use ChatGPT Business with `prompts/review_prompt.md` to review the task, diff, logs, and test evidence. The review must produce one decision: accept, revise, split, or reject.

Use `logics/templates/review_template.md` when recording the review in Logics memory.

## 10. Repository Audit

When a repository-level check is useful, generate a local Markdown audit report:

```bash
bash scripts/audit_repo.sh
```

The script writes `repo-audit.md` under a timestamped `task-runs/` directory. Paste that report into ChatGPT Business with `prompts/repo_audit_prompt.md` to review architecture, docs, scripts, prompts, Logics memory, Git state, risks, and next tasks.

## 11. Reinjection Into ChatGPT

Record the review in `logics/reviews/`. Feed the accepted facts, risks, and follow-up needs back into ChatGPT Business before planning the next step.

## 12. Next Task Selection

Choose the next bounded task from reviewed evidence. Do not expand execution scope mid-task; create a new task when more work is needed.
