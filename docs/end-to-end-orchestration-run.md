# End-To-End Orchestration Run

## Purpose

`orchestration-run` is the first v0.3 global runner for cockpit-driven orchestration. It connects need intake evidence, Logics draft generation, task prompt generation, local Codex execution, review evidence, acceptance policy, Loop state advancement evidence, and controlled auto-push.

This is a local orchestration engine. It does not merge, force push, rebase, tag, delete branches, or bypass controlled Git flow.

## Command Usage

```bash
bash scripts/orchestia_loop.sh orchestration-run task-runs/example-need-intake/need-intake.md \
  --workspace task-runs/example/workspace \
  --max-cycles 1 \
  --execute-codex \
  --auto-promote-logics \
  --auto-generate-task-prompts \
  --auto-accept-if-checks-pass \
  --advance-if-next-ready \
  --auto-push \
  --remote origin \
  --push-branch integration \
  --test "python3 -m unittest discover -s tests"
```

Default behavior is dry-run evidence and command preview. Codex execution, Logics promotion package creation, prompt generation, auto-accept, advancement evidence, and auto-push each require explicit flags.

## Policy Model

Each run writes `policy.md` with:

- Codex execution authorization.
- Logics promotion package authorization.
- task prompt generation authorization.
- auto-accept authorization.
- Loop state advancement authorization.
- auto-push authorization.
- remote and push branch.
- protected branches: main/master.
- max cycles.
- test command.
- workspace.
- stop conditions.

`main/master` are refused as auto-push branches by default. Merge remains separate and out of scope.

## Run Directory

Each invocation creates:

```text
task-runs/<timestamp>-orchestration-run/
├── orchestration-state.md
├── policy.md
├── events.log
├── errors.md
├── summary.md
├── need-intake/
├── logics-drafts/
├── promoted-logics/
├── prompts/
├── cycles/
├── reviews/
├── loop-state-updates/
└── git-flow/
```

Cycle evidence is stored under `cycles/cycle-001/` and includes prompt, Codex evidence when executed, test output, workspace status, decision, review draft, and advancement evidence when authorized.

## Cockpit Pages

- `/orchestration-runs`: list orchestration run directories.
- `/orchestration-run?path=...`: inspect summary, policy, events, errors, cycles, review evidence, and push evidence.
- `/orchestration/start`: create a request file and command preview under `task-runs/*-orchestration-request/`.

The cockpit does not execute this runner. It creates a request and copyable command preview. Instruction and stop actions append files inside an existing orchestration run directory only.

## Auto-Push Behavior

Auto-push requires:

- `--auto-push`
- `--remote`
- `--push-branch`
- a push branch that is not `main` or `master`
- passing tests
- a clean workspace

The runner calls:

1. `scripts/controlled_git_flow.sh auto-push` dry-run.
2. `scripts/controlled_git_flow.sh auto-push --execute` only if dry-run succeeds.

Both outputs are captured under `git-flow/`. No merge is performed.

## Stop Conditions

The runner stops on missing or invalid source, draft generation failure, promotion package failure, missing workspace, `/mnt/c` workspace, non-Git workspace, dirty workspace before execution, missing prompt, Codex non-zero exit, test failure, forbidden file changes, ambiguous next state, missing next prompt, `stop-request.md`, protected push branch, controlled auto-push failure, max cycles, or initial need completion.

## Human Control

Humans still control:

- enabling Codex execution
- enabling auto-accept
- enabling Loop state advancement evidence
- enabling auto-push
- choosing the target branch
- keeping `main/master` forbidden
- resolving ambiguous next primary needs
- confirming blocker resolution
- merge authorization

## Validation Result

Validation used only disposable resources under `task-runs/orchestration-run-disposable/`.

- Workspace: local Git repository on `integration`.
- Remote: local bare repository `task-runs/orchestration-run-disposable/remote.git`.
- Codex execution: `codex exec --sandbox workspace-write`, inspect-only prompt.
- Tests: `python3 -m unittest discover -s tests`.
- Auto-push: controlled dry-run then execute through `controlled_git_flow.sh`.
- Result: `integration` was pushed to the local bare remote.
- No GitHub remote was used.
- No real project was modified.
- No merge was performed.

## Limitations

- Final tracked Logics promotion is not implemented; this version records a promotion package under `task-runs/`.
- Loop state advancement is recorded as evidence unless a future explicit promoted Loop state path is supplied.
- The runner does not create commits. Auto-push requires a clean, already committed workspace.
- Multi-cycle generation is intentionally minimal in this first version.

## Next Tasks

- Add guarded promotion from reviewed drafts into final Logics records.
- Add task prompt preparation from reviewed Logics draft content.
- Add negative-path validation for protected push branches, dirty workspaces, failed tests, and invalid source paths.
