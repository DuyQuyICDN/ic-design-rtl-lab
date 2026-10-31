#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
mkdir -p build reports
for file in counter.sv tb_counter_ai.sv tb_counter_extra.sv; do
  if [[ ! -f "$file" ]]; then
    echo "ERROR: Missing $file" >&2
    exit 1
  fi
done
printf '\n[VERIFICATION 1/5] Verilator RTL lint\n'
verilator --lint-only -Wall --top-module counter counter.sv
printf '[VERIFICATION 2/5] Compile basic testbench\n'
iverilog -g2012 -s tb_counter_ai -o build/sim_ai.vvp counter.sv tb_counter_ai.sv
printf '[VERIFICATION 3/5] Run basic testbench\n'
vvp build/sim_ai.vvp | tee reports/ai_sim.log
if ! grep -Fq 'PASS: ALL TESTS COMPLETED' reports/ai_sim.log; then
  echo 'ERROR: Basic PASS marker not found' >&2
  exit 1
fi
printf '[VERIFICATION 4/5] Compile extra testbench\n'
iverilog -g2012 -s tb_counter_extra -o build/sim_extra.vvp counter.sv tb_counter_extra.sv
printf '[VERIFICATION 5/5] Run extra testbench\n'
vvp build/sim_extra.vvp | tee reports/extra_sim.log
if ! grep -Fq 'PASS: TEST 8-12' reports/extra_sim.log; then
  echo 'ERROR: Extra PASS marker not found' >&2
  exit 1
fi
printf '\nPASS: BOTH RTL TESTBENCHES\n'
