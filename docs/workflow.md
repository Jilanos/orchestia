# Workflow

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

## 10. Reinjection Into ChatGPT

Record the review in `logics/reviews/`. Feed the accepted facts, risks, and follow-up needs back into ChatGPT Business before planning the next step.

## 11. Next Task Selection

Choose the next bounded task from reviewed evidence. Do not expand execution scope mid-task; create a new task when more work is needed.
