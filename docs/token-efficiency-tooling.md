# Token Efficiency Tooling

## Purpose

This document records optional tooling guidance for reducing token use in future Orchestia work. RTK and Caveman are optional aids only; Orchestia must remain usable without them.

## RTK

RTK is for command-output compression. It can help summarize long terminal output, test logs, diffs, or run evidence before that material is pasted into a prompt or review.

Use RTK when:

- command output is long but mostly repetitive;
- the decisive facts are pass/fail status, changed files, errors, and evidence paths;
- the compressed output can be verified against the original if needed.

Do not use RTK to hide or discard safety-critical facts.

## Caveman

Caveman is for compact agent communication. It can help express task state, blockers, decisions, and next actions in short structured language between operators or agents.

Use Caveman when:

- a handoff needs to be compact;
- the receiving agent already has access to the referenced repository docs;
- the message can safely rely on shared terms such as `accept`, `revise`, `blocked`, `workspace clean`, and `validation passed`.

Do not use Caveman when a task needs exact commands, exact file scope, release gates, or legal/security wording that must remain explicit.

## Optional Usage Policy

- RTK and Caveman are optional.
- Do not install either tool as part of a normal Orchestia task.
- Do not vendor external code.
- Do not add dependencies.
- Do not make future prompts require either tool.
- If a tool is unavailable, use plain text summaries and the compact prompt documents.

## Fallback Behavior

The fallback rule is simple: if optional tooling is missing, continue with concise plain text and repository docs.

If RTK is missing, summarize command output manually:

- command;
- exit status;
- decisive output lines;
- evidence path;
- blocker if present.

If Caveman is missing, use Compact Prompt Mode and concise plain English.

## Risks

- Compression can omit safety-critical facts such as dirty working trees, failed checks, protected branches, unauthorized remotes, secret exposure risks, or destructive commands.
- Compressed handoffs can become ambiguous if they omit exact file paths or decisions.
- Tool-specific shorthand can make reviews harder for humans who do not use the same tool.
- Over-compression can hide the reason a task was blocked.

## Examples

Bad RTK-style summary:

```text
Tests mostly OK. Some git stuff. Proceed.
```

Good RTK-style summary:

```text
Command: python3 -m unittest discover -s tests
Exit: 0
Result: 8 tests passed
Evidence: task-runs/20260526T000000Z-tests/test-output.log
Safety: no failed checks reported
```

Bad Caveman-style handoff:

```text
Done. Ship it.
```

Good Caveman-style handoff:

```text
TASK-0066 docs-only. Validation passed. REVIEW-0061 accept.
Changed: token tooling doc, policy references, task/review.
No scripts, dependencies, Codex runs, or project edits.
Next: use optional tooling only when safety-critical facts remain explicit.
```

## No Mandatory Dependency Policy

RTK and Caveman must never become mandatory dependencies for Orchestia operation. The canonical workflow remains repository docs, local shell commands, Git evidence, and human-readable reviews.
