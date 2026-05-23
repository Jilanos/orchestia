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

## State-Driven Runner

The first state-driven loop runner is `scripts/orchestia_loop.sh`. It reads a Loop state file and can show status, identify the next step, print a Codex command for a prepared prompt, collect workspace evidence, or create a review draft:

```bash
bash scripts/orchestia_loop.sh status logics/loop-states/LS-0001-sample-todo-cli.md
bash scripts/orchestia_loop.sh next logics/loop-states/LS-0001-sample-todo-cli.md
bash scripts/orchestia_loop.sh run logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/orchestia-samples/todo-cli
bash scripts/orchestia_loop.sh collect logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/orchestia-samples/todo-cli --test "python3 -m unittest discover -s tests"
bash scripts/orchestia_loop.sh review-draft logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/orchestia-samples/todo-cli
```

The runner keeps decisions human-supervised. It does not update Loop state, create accept/revise/split/reject decisions, push, merge, rebase, tag, or force push.

The runner can also prepare a controlled Git flow handoff:

```bash
bash scripts/orchestia_loop.sh git-flow logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/orchestia-samples/todo-cli --remote origin --source-branch feature/example --target-branch integration --test "python3 -m unittest discover -s tests"
```

`orchestia_loop.sh` remains the state-driven runner, while `controlled_git_flow.sh` remains the Git automation runner. The `git-flow` handoff only generates safe commands and evidence; push and merge still require explicit human-approved execution through `controlled_git_flow.sh --execute`.

Git-flow evidence can be transformed into a draft review without creating a final Logics review:

```bash
bash scripts/orchestia_loop.sh git-flow-review-draft logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/orchestia-samples/todo-cli --evidence-dir task-runs/example-controlled-git-flow
```

The draft lives under `task-runs/`. Final review creation, decisions, and Loop state advancement remain human-controlled and separate from the runner.

When a human has reviewed a draft and chosen a decision, `finalize-review` can convert that ignored draft into a versioned Logics review:

```bash
bash scripts/orchestia_loop.sh finalize-review --draft task-runs/example/review-draft.md --review-id REVIEW-0031 --review-title "Example review" --reviewed-task TASK-0031 --decision accept
```

Review drafts are local and ignored under `task-runs/`. `finalize-review` requires the decision to be provided explicitly, writes the final record under `logics/reviews/`, and does not update Loop state, push, or merge.

## Controlled Auto Loop

`orchestia_loop.sh` also supports a controlled auto-loop checkpoint:

```bash
bash scripts/orchestia_loop.sh auto-loop logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/orchestia-samples/todo-cli --max-steps 1
```

The controlled auto loop is dry-run by default. It creates `task-runs/<timestamp>-auto-loop/`, writes command previews and evidence, reads human instructions from `instructions.md`, honors `stop-request.md`, and creates a pending review draft when no decision is supplied.

Execution requires explicit authorization with `--execute-codex`, `--execute-git-flow`, or `--execute-all`. Review decisions are never invented; a decision must be supplied as `--decision accept`, `--decision revise`, `--decision split`, or `--decision reject`. Loop state advancement is separate and requires `--advance`, an explicit decision, `--last-review`, `--next-action`, `--stop-condition`, and a Loop state file under `logics/loop-states/`.

Humans still control stop requests, additional instructions, next primary need selection when ambiguous, blocker declaration, execution flags, and controlled Git push or merge execution.

Supporting commands:

```bash
bash scripts/orchestia_loop.sh auto-loop-status task-runs/example-auto-loop
bash scripts/orchestia_loop.sh auto-loop-instruct task-runs/example-auto-loop "Prefer minimal changes."
bash scripts/orchestia_loop.sh auto-loop-stop task-runs/example-auto-loop "Stop before merge."
```

## Local Cockpit

The local cockpit is `scripts/orchestia_ui.py`, a read-only HTML interface for inspecting repository state, Loop state, `task-runs/`, Logics records, reviews, and debug status:

```bash
python3 scripts/orchestia_ui.py
```

Open `http://127.0.0.1:8765`. In this version the cockpit does not execute Codex, push, merge, update Loop state, create reviews, or write to Logics. It shows auto-loop runs, human action required, command previews, instructions, stop requests, and review drafts. Execution remains through the CLI scripts.

## Controlled Git Flow

After a task is reviewed and checks pass, `scripts/controlled_git_flow.sh` can inspect a workspace, dry-run a controlled auto push from an isolated branch, or dry-run a controlled auto merge into an explicitly declared target branch:

```bash
bash scripts/controlled_git_flow.sh status --workspace ~/ai-workspaces/example-project
bash scripts/controlled_git_flow.sh auto-push --workspace ~/ai-workspaces/example-project --remote origin --branch feature/example
bash scripts/controlled_git_flow.sh auto-merge --workspace ~/ai-workspaces/example-project --remote origin --source-branch feature/example --target-branch integration
```

The script defaults to dry-run and writes evidence under `task-runs/`. It performs push or merge only with `--execute`, never uses force push, never deletes branches, and keeps `main` and `master` protected unless an explicit override flag is provided. Failed tests block execution.

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
