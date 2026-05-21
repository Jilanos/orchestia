#!/usr/bin/env bash
set -u

echo "Current directory: $PWD"

case "$PWD" in
  /mnt/c|/mnt/c/*)
    echo "warning: running under /mnt/c; use a WSL Linux filesystem clone by default"
    ;;
  *)
    echo "Path check: not under /mnt/c"
    ;;
esac

print_tool() {
  tool_name="$1"
  label="$2"
  version_command="$3"

  if command -v "$tool_name" >/dev/null 2>&1; then
    version="$($version_command 2>/dev/null | head -n 1 || true)"
    if [ -n "$version" ]; then
      echo "$label: found ($version)"
    else
      echo "$label: found"
    fi
  else
    echo "$label: missing"
  fi
}

echo
echo "Required tools:"
print_tool "bash" "bash" "bash --version"
print_tool "git" "git" "git --version"

echo
echo "Optional tools:"
print_tool "gh" "gh" "gh --version"
print_tool "node" "node" "node --version"
print_tool "npm" "npm" "npm --version"
print_tool "codex" "codex" "codex --version"

exit 0
