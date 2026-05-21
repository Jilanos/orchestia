#!/usr/bin/env bash
set -u

mkdir -p task-runs
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
output_file="task-runs/${timestamp}-test-results.txt"

if [ "$#" -eq 0 ]; then
  echo "No test command provided." > "$output_file"
  echo "Provide a command to execute and capture, for example:"
  echo "$0 npm test"
  echo "Wrote $output_file"
  exit 0
fi

echo "Command: $*" > "$output_file"
echo "Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$output_file"

"$@" >> "$output_file" 2>&1
exit_code=$?

echo "Finished: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$output_file"
echo "Exit code: $exit_code" >> "$output_file"
echo "Wrote $output_file"

exit "$exit_code"
