# TASK-0038: Execute Codex In Auto Loop

## Status

Complete

## Objective

Make controlled auto-loop mode execute prepared Codex prompts through `codex exec` when explicitly authorized, then collect evidence, create a review draft, handle explicit decisions, and allow guarded Loop state advancement.

## Context

The first controlled auto-loop implementation created dry-run evidence and command previews but did not execute Codex. v0.2 needs the real loop path from Loop state to prepared prompt, Codex execution, evidence collection, review draft, explicit decision, and optional Loop state advancement.

## Authorized Scope

- `scripts/orchestia_loop.sh`
- `scripts/orchestia_ui.py`
- README and workflow/local cockpit/roadmap documentation
- This task and review record

## Out Of Scope

- `scripts/controlled_git_flow.sh`
- Prompt templates
- Security boundary changes
- Sample project changes during verification
- Real Codex execution against the sample todo CLI during this implementation task
- Controlled Git flow execute mode
- Autonomous review decisions
- Automatic commits, pushes, or merges

## Expected Steps

1. Inspect local `codex exec` invocation style.
2. Extend `auto-loop` to resolve prepared prompt paths from Loop state.
3. Add `codex exec` execution behind `--execute-codex` or `--execute-all`.
4. Capture Codex stdout, stderr, exit code, workspace status, diff stat, and recent commits.
5. Capture optional post-execution test command output and exit code.
6. Preserve dry-run default and explicit decision requirements.
7. Update cockpit auto-loop views for execution evidence.
8. Update documentation.
9. Run syntax, dry-run, grep, and cockpit smoke verification.

## Verification Commands

```bash
codex --version
codex exec --help
bash -n scripts/orchestia_loop.sh
python3 -m py_compile scripts/orchestia_ui.py
bash scripts/orchestia_loop.sh auto-loop logics/loop-states/LS-0001-sample-todo-cli.md --workspace ~/ai-workspaces/orchestia-samples/todo-cli --max-steps 1
```

The implementation task intentionally did not run `--execute-codex` against the sample todo CLI.

## Acceptance Criteria

- `auto-loop` supports real Codex execution through `codex exec` only with explicit execute flags.
- Dry-run remains the default.
- Codex stdout, stderr, exit code, workspace status, diff stat, and recent commits are captured.
- Optional test command results are captured.
- Review drafts include execution evidence.
- Decisions remain explicit.
- Loop state advancement remains guarded by `--advance` and required fields.
- Cockpit pages show Codex execution state and evidence links.

## Result

Implemented. The auto-loop can now run prepared prompts through `codex exec` when explicitly authorized, while preserving human-owned decisions and guarded state advancement.
