#!/usr/bin/env bash
set -u

if [ ! -d task-runs ]; then
  echo "No task-runs directory found."
  exit 0
fi

echo "Task run files:"
find task-runs -maxdepth 1 -type f | sort

latest_status="$(find task-runs -maxdepth 1 -type f -name '*-git-status.txt' | sort | tail -n 1)"
latest_tests="$(find task-runs -maxdepth 1 -type f -name '*-test-results.txt' | sort | tail -n 1)"

if [ -n "$latest_status" ]; then
  echo
  echo "Latest git status:"
  cat "$latest_status"
fi

if [ -n "$latest_tests" ]; then
  echo
  echo "Latest test results tail:"
  tail -n 20 "$latest_tests"
fi
