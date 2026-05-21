#!/usr/bin/env bash
set -u

usage() {
  echo "usage: $0 [--execute] <task-file>" >&2
}

execute=false

if [ "$#" -eq 2 ] && [ "$1" = "--execute" ]; then
  execute=true
  task_file="$2"
elif [ "$#" -eq 1 ]; then
  task_file="$1"
else
  usage
  exit 2
fi

if [ ! -f "$task_file" ]; then
  echo "task file not found: $task_file" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "not inside a Git repository" >&2
  exit 1
fi

case "$PWD" in
  /mnt/c|/mnt/c/*)
    if [ "$execute" = "true" ]; then
      echo "refusing to execute Codex under /mnt/c; use a WSL Linux filesystem clone" >&2
      exit 1
    fi
    echo "warning: running under /mnt/c; use a WSL Linux filesystem clone by default"
    ;;
esac

echo "Task file: $task_file"
echo "Copyable command:"
printf 'codex < %q\n' "$task_file"

if [ "$execute" != "true" ]; then
  echo "No command was executed. Pass --execute to run Codex."
  exit 0
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "codex command not found" >&2
  exit 1
fi

codex < "$task_file"
