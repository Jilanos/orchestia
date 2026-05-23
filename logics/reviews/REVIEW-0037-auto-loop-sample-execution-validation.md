# REVIEW-0037: Auto-loop Sample Execution Validation

## Reviewed Task

[TASK-0041](../tasks/TASK-0041-validate-auto-loop-on-sample-project.md)

## Inputs Reviewed

- `scripts/orchestia_loop.sh`
- `docs/auto-loop-codex-execution-validation.md`
- `docs/mvp-roadmap.md`
- `REVIEW-0036`
- Temporary Loop state `task-runs/auto-loop-sample-validation-loop-state.md`
- Temporary prompt `task-runs/auto-loop-sample-validation-prompt.md`
- Auto-loop evidence directory `task-runs/20260523T212102Z-auto-loop/`
- Sample workspace `/home/pmondou/ai-workspaces/orchestia-samples/todo-cli`
- Sample branch `feature/auto-loop-sample-validation`

## Checks Performed

```bash
bash scripts/orchestia_loop.sh auto-loop \
  task-runs/auto-loop-sample-validation-loop-state.md \
  --workspace /home/pmondou/ai-workspaces/orchestia-samples/todo-cli \
  --max-steps 1 \
  --execute-codex \
  --test "python3 -m unittest discover -s tests"

grep -R "This README note was added by Orchestia auto-loop validation." README.md
python3 -m compileall src tests
python3 -m unittest discover -s tests
python3 -m py_compile todo_cli.py
git diff --check
```

## Findings

- Auto-loop ran real `codex exec` against the sample project on `feature/auto-loop-sample-validation`.
- The recorded command used `codex exec --sandbox workspace-write`.
- Codex exit code was `0`.
- Auto-loop test exit code was `0`.
- `README.md` was the only changed file.
- Source code and tests were not changed.
- The README contains the expected auto-loop validation note.
- Full sample checks passed after execution.
- The sample change was committed locally as `da28859 Validate auto-loop sample execution`.
- No sample push or merge was performed.
- Decision remained pending in auto-loop evidence.
- Loop state was not advanced.

## Risks

- `workspace-write` remains powerful within the target workspace and must stay behind explicit authorization.
- Prompt compliance must still be reviewed; the script captures evidence but does not prove semantic correctness by itself.
- The local sample branch has not been pushed or merged.

## Decision

accept

## Required Follow-Up

Add negative-path validation for executable auto-loop on a real sample branch, including dirty workspace refusal, missing prompt handling, failed test handling, and missing advancement-field handling.

## Next Recommended Task

Validate executable auto-loop guardrails on the sample project without changing protected branches.
