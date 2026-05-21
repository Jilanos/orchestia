# Workflow

## Request

Capture the user need in `logics/requests/` with context, desired outcome, constraints, and open questions.

## Research

Use ChatGPT Business to identify relevant files, risks, dependencies, and likely implementation paths.

## Planning

Turn the request into a scoped plan with non-goals, acceptance criteria, verification commands, and Git instructions.

## Backlog

Promote approved work into `logics/backlog/` with priority, scope, risks, and success criteria.

## Task Generation

Create a bounded Codex task in `logics/tasks/`. The task must state objective, authorized scope, out-of-scope actions, steps, acceptance criteria, verification, and watch points.

## Codex Execution

Run Codex CLI against one task at a time. Codex should inspect the repository, make scoped edits, run verification, and report the result.

## Diff Collection

Use `scripts/collect_diff.sh` to write Git status and diff output into `task-runs/`.

## Tests

Run the task's verification commands. Use `scripts/collect_test_results.sh` when a command result should be captured.

## Review

Use ChatGPT Business to review the task result, focusing on correctness, scope control, test evidence, risks, and missing follow-up.

## Reinjection

Record review findings in `logics/reviews/` and update the related request, backlog item, task, spec, or ADR.

## Next Task

Create the next bounded task from reviewed evidence instead of expanding execution scope mid-task.
