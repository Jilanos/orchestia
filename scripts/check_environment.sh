#!/usr/bin/env bash
set -u

echo "Current directory: $PWD"

if [ -z "${BASH_VERSION:-}" ]; then
  echo "bash: not detected"
else
  echo "bash: detected ($BASH_VERSION)"
fi

if command -v git >/dev/null 2>&1; then
  echo "git: detected ($(git --version))"
else
  echo "git: missing"
fi

if command -v gh >/dev/null 2>&1; then
  echo "gh: detected ($(gh --version | head -n 1))"
else
  echo "gh: missing"
fi

if command -v codex >/dev/null 2>&1; then
  echo "codex: detected ($(codex --version 2>/dev/null | head -n 1))"
else
  echo "codex: missing"
fi

case "$PWD" in
  *"/mnt/c"*)
    echo "warning: current path contains /mnt/c; avoid Windows-mounted paths by default in WSL"
    ;;
esac
