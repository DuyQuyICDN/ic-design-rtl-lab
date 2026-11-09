#!/usr/bin/env bash
# Local Phase 2/3/4 checks, report evidence kept outside Git working tree.
set -Eeuo pipefail
export LC_ALL=C
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUT="$HOME/IC-Design-Beginner/maintenance/pro-quality-gates/$(date +%Y%m%d_%H%M%S)-$$"
mkdir -p -- "$OUT"
PASS=0; FAIL=0; SKIP=0
TIMEOUT="${IC_GATE_TIMEOUT:-240}"

run_gate(){
  local name="$1"; shift
  local status=0
  timeout "$TIMEOUT" "$@" > "$OUT/$name.log" 2>&1 || status=$?
  if (( status == 0 )); then
    echo "PASS | $name | log=$OUT/$name.log"
    PASS=$((PASS+1))
  else
    echo "FAIL | $name | exit=$status | log=$OUT/$name.log"
    tail -n 15 "$OUT/$name.log" || true
    FAIL=$((FAIL+1))
  fi
}

cd "$ROOT"
printf 'IC DESIGN LOCAL QUALITY GATES\nRepository: %s\nLogs: %s\n' "$ROOT" "$OUT"
if [[ -f labs/phase2_counter/Makefile ]]; then
  run_gate phase2 make -C labs/phase2_counter verify
else
  echo 'SKIP | phase2 | missing Makefile'; SKIP=$((SKIP+1))
fi
PY="$HOME/IC-Design-Beginner/.venv-ic-system/bin/python"
if [[ -f labs/phase3_quality/scripts/run_quality.sh && -x "$PY" ]]; then
  run_gate phase3 env PHASE3_PYTHON="$PY" PATH="$(dirname "$PY"):$PATH" bash labs/phase3_quality/scripts/run_quality.sh
else
  echo 'SKIP | phase3 | missing script or Cocotb system-Python venv'; SKIP=$((SKIP+1))
fi
if [[ -f labs/phase4_portfolio/Makefile ]]; then
  # Phase 2 and Phase 3 are separate gates above; do not mark their skips as rerun.
  run_gate phase4 env PHASE4_SKIP_BASELINES=1 make -C labs/phase4_portfolio verify
else
  echo 'SKIP | phase4 | missing Makefile'; SKIP=$((SKIP+1))
fi
printf 'PASS=%s FAIL=%s SKIP=%s\n' "$PASS" "$FAIL" "$SKIP" | tee "$OUT/summary.txt"
[[ "$FAIL" -eq 0 && "$SKIP" -eq 0 ]]
