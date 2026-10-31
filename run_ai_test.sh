
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
mkdir -p reports

echo "=================================="
echo " IC DESIGN - RTL VERIFICATION"
echo "=================================="

echo "[1/5] Verilator RTL Lint"
verilator --lint-only -Wall \
    --top-module counter counter.sv

echo "[2/5] Compile Basic Testbench"
iverilog -g2012 -s tb_counter_ai \
    -o sim_ai.vvp \
    counter.sv tb_counter_ai.sv

echo "[3/5] Run Basic Verification"
vvp sim_ai.vvp | tee reports/ai_sim.log

if ! grep -Fxq "PASS: ALL TESTS COMPLETED" reports/ai_sim.log; then
    echo "BASIC TEST FAILED"
    exit 1
fi

echo "[4/5] Compile Advanced Testbench"
iverilog -g2012 -s tb_counter_extra \
    -o sim_extra.vvp \
    counter.sv tb_counter_extra.sv

echo "[5/5] Run Advanced Verification"
vvp sim_extra.vvp | tee reports/extra_sim.log

if ! grep -Fxq "PASS: TEST 8-12" reports/extra_sim.log; then
    echo "ADVANCED TEST FAILED"
    exit 1
fi

echo "=================================="
echo " ALL RTL TESTS PASSED"
echo "=================================="
