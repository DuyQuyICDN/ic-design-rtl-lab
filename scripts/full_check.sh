#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
mkdir -p reports
bash scripts/check_env.sh
bash scripts/verify.sh
bash scripts/synth.sh
basic="$(grep -oE 'Total checked steps: [0-9]+' reports/ai_sim.log | tail -n 1 | awk '{print $4}' || true)"
extra="$(grep -oE 'Checks: [0-9]+' reports/extra_sim.log | tail -n 1 | awk '{print $2}' || true)"
{
  printf 'IC DESIGN - FULL CHECK REPORT\n'
  printf 'Date: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
  printf 'Project: %s\n' "$PWD"
  printf 'RTL lint: PASS\n'
  printf 'Basic testbench: PASS (%s checks)\n' "${basic:-unknown}"
  printf 'Extended testbench: PASS (%s checks)\n' "${extra:-unknown}"
  if [[ "$basic" =~ ^[0-9]+$ && "$extra" =~ ^[0-9]+$ ]]; then
    printf 'Total checks: %s\n' "$((basic + extra))"
  fi
  printf 'Generic Yosys synthesis: PASS\n'
  printf 'Gate-level netlist: build/counter_generic_netlist.v\n'
  printf 'Note: No ASIC library mapping, STA, power or silicon-area signoff performed.\n'
} > reports/verification_summary.txt
printf '\n=====================================\n'
printf ' FULL CHECK PASSED: RTL + SYNTHESIS\n'
printf '=====================================\n'
printf 'Summary: reports/verification_summary.txt\n'
