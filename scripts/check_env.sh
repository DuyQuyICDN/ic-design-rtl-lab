#!/usr/bin/env bash
set -u
cd "$(dirname "$0")/.."
printf '\n=== IC DESIGN / WSL TOOL CHECK ===\n'
missing=0
for tool in bash python3 iverilog vvp verilator yosys; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '[OK] %-12s %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '[MISSING] %s\n' "$tool"
    missing=1
  fi
done
for tool in dot gtkwave git make; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '[OK] %-12s %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '[OPTIONAL MISSING] %s\n' "$tool"
  fi
done
printf 'Workspace: %s\n' "$PWD"
exit "$missing"
