# MVP Validation Checklist

Use this manual validation checklist before considering an Orchestia MVP v0.1 tag. It is a lightweight review aid, not a test framework or production-readiness guarantee.

## Repository State

- [ ] `git status --short` is clean except for intentional reviewed changes.
- [ ] Public remote is configured and points to the expected Orchestia repository.
- [ ] Latest intended commits are pushed before any v0.1 tag is considered.
- [ ] Generated `task-runs/` outputs are ignored by Git.

## Environment

- [ ] Commands are running from the WSL Linux filesystem.
- [ ] Current path is not under `/mnt/c`.
- [ ] `git` is available.
- [ ] `codex` is available, or explicitly marked missing for the run.
- [ ] `gh` is treated as optional.

## Scripts

- [ ] `bash -n` passes for all files in `scripts/`.
- [ ] `bash scripts/check_environment.sh` runs.
- [ ] `bash scripts/run_codex_task.sh <task-file>` prints a command without execution by default.
- [ ] `bash scripts/collect_diff.sh` creates ignored output under `task-runs/`.
- [ ] `bash scripts/collect_test_results.sh -- <command>` captures command output and exit code.
- [ ] `bash scripts/summarize_task_result.sh` summarizes the latest run.
- [ ] `bash scripts/audit_repo.sh` creates an ignored audit report.

## Documentation

- [ ] README links to core docs.
- [ ] `docs/architecture.md` exists.
- [ ] `docs/security-boundaries.md` exists.
- [ ] `docs/workflow.md` exists.
- [ ] `docs/mvp-roadmap.md` exists.
- [ ] `docs/sample-end-to-end-run.md` exists.
- [ ] Safety boundaries are explicit.
- [ ] Documentation makes no full autonomy claim.

## Prompts And Logics

- [ ] Prompt templates exist in `prompts/`.
- [ ] Logics templates exist in `logics/templates/`.
- [ ] Request, backlog, task, ADR, and review records exist.
- [ ] Review decisions use accept, revise, split or reject.
- [ ] Important local evidence from `task-runs/` is summarized into tracked Logics records when needed.

## Release Readiness

- [ ] Sample end-to-end run is documented.
- [ ] Known limitations are listed.
- [ ] Next risks are identified.
- [ ] MVP v0.1 tag can be considered only after this validation checklist is green.
- [ ] Tagging, pushing, or publishing is explicitly authorized by a human in a separate task.

## v0.2-alpha Negative-path Validation

Run the reusable negative-path suite:

```bash
bash scripts/validate_negative_paths.sh
```

Before considering a v0.2-alpha follow-up release, verify:

- [ ] Missing prepared prompts are refused without Codex execution.
- [ ] Auto-loop dry-run mode does not modify workspaces.
- [ ] Dirty workspaces block Codex execution and controlled push.
- [ ] Invalid decisions are refused.
- [ ] `finalize-review` refuses drafts outside `task-runs/`.
- [ ] `finalize-review` refuses invalid decisions.
- [ ] Controlled auto-push refuses protected branches without override.
- [ ] Failed tests block controlled auto-push.
- [ ] Controlled auto-merge refuses protected targets without override.
- [ ] Failed tests block controlled auto-merge.
- [ ] Merge conflicts stop controlled auto-merge without pushing unresolved state.
- [ ] Missing Git-flow evidence is handled safely without final review creation.
- [ ] Missing `--execute` leaves push and merge commands in dry-run mode.
- [ ] The suite uses only disposable resources under `task-runs/`.
- [ ] No GitHub remotes are used by the suite.
- [ ] The sample todo CLI project is not modified by the suite.
