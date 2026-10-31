#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
mkdir -p build reports
printf '\n[SYNTHESIS] Mapping RTL to Yosys generic logic and exporting netlist\n'
if ! yosys -l reports/yosys_synth.log -p \
  'read_verilog -sv counter.sv; hierarchy -check -top counter; proc; opt; fsm; opt; techmap; opt; stat; write_verilog -noattr build/counter_generic_netlist.v' \
  >/dev/null; then
  echo 'ERROR: Yosys synthesis failed; last log lines:' >&2
  tail -n 45 reports/yosys_synth.log >&2 || true
  exit 1
fi
printf 'Saved: reports/yosys_synth.log\n'
printf 'Saved: build/counter_generic_netlist.v\n'
if command -v dot >/dev/null 2>&1; then
  printf '[SCHEMATIC] Exporting readable high-level RTL diagram\n'
  if ! yosys -p \
    'read_verilog -sv counter.sv; hierarchy -check -top counter; proc; opt; show -format svg -prefix reports/counter_rtl counter' \
    >/dev/null; then
    echo 'WARNING: Schematic SVG generation failed; synthesis still passed.' >&2
  else
    printf 'Saved: reports/counter_rtl.svg\n'
  fi
else
  echo 'NOTE: Graphviz dot not installed, skipping SVG diagram.'
fi
printf '\nYosys statistics:\n'
awk '/^=== counter ===/{print; shown=1; next} shown && /^$/{if (count++ > 0) exit} shown {print}' reports/yosys_synth.log | tail -n 24
printf '\nPASS: GENERIC SYNTHESIS\n'
