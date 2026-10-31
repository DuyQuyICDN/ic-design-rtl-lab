#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== RTL + SYNTHESIS ==="
bash scripts/full_check.sh

echo "=== PYTHON COCOTB ==="
PYTHON_BIN="${IC_VERIFY_PYTHON:-$HOME/venvs/ic-verification/bin/python}"
"$PYTHON_BIN" -m pytest -s cocotb_tests/test_runner.py

echo "=================================="
echo " FULL RTL + COCOTB CHECK PASSED"
echo "=================================="
