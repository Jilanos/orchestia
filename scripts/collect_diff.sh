#!/usr/bin/env bash
set -u

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "not inside a Git repository" >&2
  exit 1
fi

mkdir -p task-runs
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
run_dir="task-runs/${timestamp}-diff"
mkdir -p "$run_dir"

git status --short > "$run_dir/git-status.txt"
git diff > "$run_dir/git-diff.patch"
git diff --stat > "$run_dir/git-diff-stat.txt"
git log --oneline --max-count=5 > "$run_dir/git-log.txt"

echo "Run directory: $run_dir"
