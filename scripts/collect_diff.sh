#!/usr/bin/env bash
set -u

mkdir -p task-runs
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"

git status --short > "task-runs/${timestamp}-git-status.txt"
git diff > "task-runs/${timestamp}-git-diff.patch"

echo "Wrote task-runs/${timestamp}-git-status.txt"
echo "Wrote task-runs/${timestamp}-git-diff.patch"
