#!/usr/bin/env bash
set -u

if [ "$#" -gt 1 ]; then
  echo "usage: $0 [run-directory]" >&2
  exit 2
fi

if [ "$#" -eq 1 ]; then
  run_dir="$1"
else
  if [ ! -d task-runs ]; then
    echo "No task-runs directory found."
    exit 0
  fi
  run_dir="$(find task-runs -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
fi

if [ -z "${run_dir:-}" ]; then
  echo "No task run directories found."
  exit 0
fi

if [ ! -d "$run_dir" ]; then
  echo "Run directory not found: $run_dir" >&2
  exit 1
fi

echo "Run directory: $run_dir"

if [ -f "$run_dir/git-status.txt" ]; then
  echo
  echo "Git status:"
  if [ -s "$run_dir/git-status.txt" ]; then
    cat "$run_dir/git-status.txt"
  else
    echo "(clean)"
  fi
fi

if [ -f "$run_dir/git-diff-stat.txt" ]; then
  echo
  echo "Diff stat:"
  if [ -s "$run_dir/git-diff-stat.txt" ]; then
    cat "$run_dir/git-diff-stat.txt"
  else
    echo "(no tracked diff)"
  fi
fi

if [ -f "$run_dir/test-command.txt" ]; then
  echo
  echo "Test command:"
  cat "$run_dir/test-command.txt"
fi

if [ -f "$run_dir/test-exit-code.txt" ]; then
  echo
  echo "Test exit code:"
  cat "$run_dir/test-exit-code.txt"
fi

if [ -f "$run_dir/test-output.txt" ]; then
  echo
  echo "Test output tail:"
  tail -n 20 "$run_dir/test-output.txt"
fi
