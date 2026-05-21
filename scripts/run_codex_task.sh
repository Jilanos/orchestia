#!/usr/bin/env bash
set -u

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <task-file>" >&2
  exit 2
fi

task_file="$1"

if [ ! -f "$task_file" ]; then
  echo "task file not found: $task_file" >&2
  exit 1
fi

echo "Task file: $task_file"
echo "Indicative command:"
echo "codex \"$(sed 's/"/\\"/g' "$task_file")\""
echo "No command was executed by this helper."
