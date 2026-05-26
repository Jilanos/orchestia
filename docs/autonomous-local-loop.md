# Autonomous Local Loop

## Purpose

The autonomous local loop is a second-level Orchestia runner for repeated local execution cycles. It reduces mechanical steps while staying local, evidence-first, and bounded by explicit Loop state fields.

It is not full autonomy. It does not push, merge, rebase, tag, delete branches, create remotes, choose ambiguous primary needs, or accept firm blockers for the human.

## Usage

Dry-run:

```bash
bash scripts/orchestia_loop.sh autonomous-loop \
  logics/loop-states/LS-0002-job-offer-analyzer.md \
  --workspace ~/ai-workspaces/example-project \
  --max-cycles 2
```

Executable local mode:

```bash
bash scripts/orchestia_loop.sh autonomous-loop \
  logics/loop-states/LS-0002-job-offer-analyzer.md \
  --workspace ~/ai-workspaces/example-project \
  --max-cycles 2 \
  --execute-codex \
  --auto-accept-if-checks-pass \
  --advance-if-next-ready \
  --test "python3 -m unittest discover -s tests"
```

## Default Dry-Run Behavior

By default the command creates an autonomous-loop run directory, resolves the current Loop state, writes command and state evidence, and stops without running Codex, accepting decisions, advancing state, pushing, or merging.

## Execute Flags

Codex execution is allowed only with:

- `--execute-codex`
- `--execute-all`

Execution uses:

```bash
codex exec --sandbox workspace-write
```

The workspace must exist, must be a Git repository, and must not be under `/mnt/c`.

## Auto-Accept Policy

`--auto-accept-if-checks-pass` allows a cycle decision of `accept` only when:

- Codex exits `0`.
- The provided test command exits `0`.
- Workspace evidence is captured.
- No secret-like file is touched.
- No stop request exists.
- No blocker exists.
- The workspace remains inside the authorized path.

Without this flag, the decision remains `pending` and the loop stops after evidence.

## Loop State Advancement Rules

`--advance-if-next-ready` allows the loop to advance only when the current cycle is accepted and the Loop state contains explicit next-state fields:

- `Next primary need`
- `Next request`
- `Next backlog item`
- `Next task`
- `Next prepared Codex prompt`

The next prepared prompt must exist. If a next field is missing or ambiguous, the loop stops and records human action required. The runner does not infer the next primary need.

## Stop Conditions

The loop stops safely on:

- max cycles reached
- missing Loop state
- missing prepared prompt
- missing workspace
- workspace under `/mnt/c`
- workspace not a Git repository
- dirty workspace before the first execution
- Codex exit non-zero
- test failure
- secret-like file modification
- invalid state
- missing next task or prompt
- ambiguous next primary need
- `stop-request.md`
- `--blocker`
- unexpected script error

## Run Directory Structure

Each invocation creates:

```text
task-runs/<timestamp>-autonomous-loop/
```

The directory contains:

- `autonomous-loop-state.md`
- `events.log`
- `summary.md`
- `instructions.md` when `--instruction` is supplied
- `errors.md` when blocked or failed
- `cycle-001/`
- `cycle-002/`

Each cycle directory may contain:

- `loop-state-before.md`
- `prompt-used.md`
- `codex-command.txt`
- `codex-stdout.txt`
- `codex-stderr.txt`
- `codex-exit-code.txt`
- `workspace-status-before.txt`
- `workspace-status-after.txt`
- `workspace-diff-stat-after.txt`
- `workspace-log-after.txt`
- `test-command.txt`
- `test-stdout.txt`
- `test-stderr.txt`
- `test-exit-code.txt`
- `review-draft.md`
- `decision.md`
- `loop-state-after.md`
- `errors.md`

## Cockpit Pages

The local cockpit exposes:

- `/autonomous-loop`: list autonomous-loop runs.
- `/autonomous-loop-run?path=task-runs/<run>`: inspect run status, cycles, latest decision, latest errors, instructions, stop requests, cycle files, and command previews.

The cockpit remains read-only.

## Human-Controlled Boundaries

Humans still control:

- enabling execution flags
- selecting the next primary need when ambiguous
- accepting or resolving firm blockers
- deciding whether to use autonomous acceptance policy
- controlled Git push or merge through separate guarded commands

## Validation Result

The final validation ran on a disposable workspace under `task-runs/autonomous-loop-disposable/`. The accepted run was:

```text
task-runs/20260526T081619Z-autonomous-loop/
```

Result:

- cycle 1 executed Codex with `workspace-write`, tests passed, decision `accept`
- cycle 2 executed Codex with `workspace-write`, tests passed, decision `accept`
- the run stopped after cycle 2 because no explicit next state remained
- no push or merge was performed
- no real project was modified

## Known Limitations

- The runner does not create final Logics reviews automatically.
- It does not commit target workspace changes.
- It does not infer next primary needs.
- It does not validate arbitrary project-specific allowed file lists yet.
- It treats missing next state as a human-action stop, not as completion unless terminal fields are explicit.

## Next Improvements

- Add project-specific allowed file policy checks.
- Add terminal completion fields for autonomous loops.
- Add stronger review-finalization integration with explicit review IDs.
- Validate the mode on `job-offer-analyzer` only after a dedicated task authorizes that scope.
