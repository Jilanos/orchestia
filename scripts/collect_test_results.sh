#!/usr/bin/env bash
set -u

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "not inside a Git repository" >&2
  exit 1
fi

case "$PWD" in
  /mnt/c|/mnt/c/*)
    echo "warning: running under /mnt/c; use a WSL Linux filesystem clone by default"
    ;;
esac

mkdir -p task-runs
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
run_dir="task-runs/${timestamp}-tests"
mkdir -p "$run_dir"

command_file="$run_dir/test-command.txt"
output_file="$run_dir/test-output.txt"
exit_code_file="$run_dir/test-exit-code.txt"

if [ "$#" -eq 0 ]; then
  echo "No test command provided."
  echo "Usage: $0 -- <command> [args...]"
  echo "Run directory: $run_dir"
  exit 0
fi

if [ "$1" != "--" ]; then
  echo "Test commands must be provided after --"
  echo "Usage: $0 -- <command> [args...]"
  echo "Run directory: $run_dir"
  exit 0
fi

shift

if [ "$#" -eq 0 ]; then
  echo "No test command provided after --."
  echo "Usage: $0 -- <command> [args...]"
  echo "Run directory: $run_dir"
  exit 0
fi

printf '%q ' "$@" > "$command_file"
printf '\n' >> "$command_file"

set +e
"$@" > "$output_file" 2>&1
exit_code=$?
set -u

printf '%s\n' "$exit_code" > "$exit_code_file"

echo "Run directory: $run_dir"
echo "Exit code: $exit_code"
exit "$exit_code"
