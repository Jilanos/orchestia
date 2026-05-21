#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "not inside a Git repository" >&2
  exit 1
fi

case "$PWD" in
  /mnt/c|/mnt/c/*)
    echo "warning: running under /mnt/c; use a WSL Linux filesystem clone by default" >&2
    ;;
esac

mkdir -p task-runs
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
run_dir="task-runs/${timestamp}-repo-audit"
report="$run_dir/repo-audit.md"
mkdir -p "$run_dir"

write_check() {
  path="$1"
  if [ -e "$path" ]; then
    printf -- '- [x] `%s`\n' "$path"
  else
    printf -- '- [ ] `%s`\n' "$path"
  fi
}

{
  echo "# Repository Audit"
  echo
  echo "- Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "- Current directory: $PWD"
  echo "- Branch: $(git branch --show-current 2>/dev/null || true)"
  echo

  echo "## Remote URLs"
  echo
  if git remote -v | sed 's/^/- /'; then
    :
  else
    echo "- No remotes found."
  fi
  echo

  echo "## Recent Commits"
  echo
  git log --oneline --max-count=5 | sed 's/^/- /'
  echo

  echo "## Git Status"
  echo
  echo '```text'
  git status --short
  echo '```'
  echo

  echo "## Diff Stat"
  echo
  echo '```text'
  git diff --stat
  echo '```'
  echo

  echo "## Tracked File Overview"
  echo
  echo '```text'
  git ls-files | sort
  echo '```'
  echo

  echo "## Key File Checks"
  echo
  write_check "README.md"
  write_check "AGENTS.md"
  write_check "PROJECT_BRIEF.md"
  write_check "docs"
  write_check "prompts"
  write_check "scripts"
  write_check "logics"
  write_check "logics/requests"
  write_check "logics/backlog"
  write_check "logics/tasks"
  write_check "logics/specs"
  write_check "logics/adr"
  write_check "logics/reviews"
  write_check "task-runs/.gitkeep"
  echo

  echo "## Next Suggested Manual Checks"
  echo
  echo '- Review `git status --short` for unintended changes.'
  echo '- Review `git diff --stat` and the full diff before committing.'
  echo '- Confirm generated `task-runs/` output is not intended for commit.'
  echo "- Check that new work is tied to a Logics task and review."
  echo '- Paste this report into ChatGPT Business with `prompts/repo_audit_prompt.md` for review.'
} > "$report"

echo "Report: $report"
