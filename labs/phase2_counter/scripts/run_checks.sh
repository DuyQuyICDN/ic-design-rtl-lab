#!/usr/bin/env bash
set -Eeuo pipefail

LAB="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
MODE="${1:-all}"
case "$MODE" in all|lint|sim|synth) ;; *) echo "Usage: $0 [all|lint|sim|synth]" >&2; exit 2;; esac

RTL="$LAB/rtl/rtl_counter.sv"
TB="$LAB/tb/tb_rtl_counter.sv"
STAMP="$(date +%Y%m%dT%H%M%S)"
OUT="$LAB/reports/runs/${STAMP}-$$"
(umask 022; mkdir -p -- "$OUT/logs" "$OUT/simulation" "$OUT/synthesis" "$OUT/waveforms")
STATUS="$OUT/status.tsv"
printf '' > "$STATUS"

record() {
  local name="$1" result="$2" detail="$3"
  printf '%s\t%s\t%s\n' "$name" "$result" "$detail" >> "$STATUS"
  printf '[%s] %-21s %s\n' "$result" "$name" "$detail"
}

run_command() {
  local label="$1"; shift
  local log="$OUT/logs/$label.log" rc=0
  "$@" >"$log" 2>&1 || rc=$?
  if [[ "$rc" -eq 0 ]]; then
    record "$label" PASS "exit=0 (logs/$label.log)"
    return 0
  fi
  record "$label" FAIL "exit=$rc (logs/$label.log)"
  return 1
}

printf '\nPHASE 2 VERIFICATION (%s)\nRUN DIRECTORY: %s\n' "$MODE" "$OUT"

if [[ "$MODE" == all || "$MODE" == lint ]]; then
  if command -v verilator >/dev/null 2>&1; then
    run_command lint verilator --lint-only -Wall --top-module rtl_counter "$RTL" || true
  else
    record lint FAIL 'verilator not found'
  fi
fi

if [[ "$MODE" == all || "$MODE" == sim ]]; then
  if command -v iverilog >/dev/null 2>&1 && command -v vvp >/dev/null 2>&1; then
    if run_command sim_compile iverilog -g2012 -Wall -s tb_rtl_counter -o "$OUT/simulation/tb_rtl_counter.vvp" "$RTL" "$TB"; then
      if run_command sim_run bash -c 'cd -- "$1" && vvp "$2"' _ "$OUT/waveforms" "$OUT/simulation/tb_rtl_counter.vvp"; then
        if grep -q 'TEST_PASS: tb_rtl_counter' "$OUT/logs/sim_run.log"; then
          record testbench_assertions PASS 'self-checking testbench marker found'
        else
          record testbench_assertions FAIL 'TEST_PASS marker missing'
        fi
        if [[ -s "$OUT/waveforms/counter.vcd" ]]; then
          record waveform PASS 'nonempty waveforms/counter.vcd'
        else
          record waveform FAIL 'waveform missing or empty'
        fi
      else
        record testbench_assertions FAIL 'simulator exited with error'
        record waveform FAIL 'simulator failed'
      fi
    else
      record sim_run FAIL 'compile failed; not run'
      record testbench_assertions FAIL 'compile failed'
      record waveform FAIL 'compile failed'
    fi
  else
    record sim_compile FAIL 'iverilog/vvp not found'
    record sim_run FAIL 'cannot simulate'
    record testbench_assertions FAIL 'cannot simulate'
    record waveform FAIL 'cannot simulate'
  fi
fi

if [[ "$MODE" == all || "$MODE" == synth ]]; then
  if command -v yosys >/dev/null 2>&1; then
    if run_command synthesis yosys -Q -T -p \
      "read_verilog -sv \"$RTL\"; hierarchy -check -top rtl_counter; synth -top rtl_counter; check -assert; stat; write_verilog \"$OUT/synthesis/rtl_counter_netlist.v\""; then
      if [[ -s "$OUT/synthesis/rtl_counter_netlist.v" ]]; then
        record netlist PASS 'nonempty synthesis/rtl_counter_netlist.v'
      else
        record netlist FAIL 'synthesis netlist missing or empty'
      fi
    else
      record netlist FAIL 'synthesis failed'
    fi
  else
    record synthesis FAIL 'yosys not found'
    record netlist FAIL 'yosys not found'
  fi
fi

python3 - "$LAB" "$OUT" "$MODE" <<'REPORT'
import json
import pathlib
import subprocess
import sys
from datetime import datetime, timezone

lab = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])
mode = sys.argv[3]
rows = []
for line in (out / 'status.tsv').read_text().splitlines():
    check, status, detail = line.split('\t', 2)
    rows.append({'check': check, 'status': status, 'detail': detail})
passed = sum(x['status'] == 'PASS' for x in rows)
failed = sum(x['status'] == 'FAIL' for x in rows)
repo = lab.parent.parent
try:
    git_status = subprocess.run(['git', '-C', str(repo), 'status', '--short'], text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, check=False).stdout.strip()
except OSError:
    git_status = 'unavailable'
result = {
    'phase': 2, 'mode': mode, 'date_utc': datetime.now(timezone.utc).isoformat(),
    'repository': str(repo), 'lab': str(lab), 'report': str(out),
    'pass': passed, 'fail': failed, 'overall': 'PASS' if failed == 0 and rows else 'FAIL',
    'checks': rows, 'git_status': git_status
}
(out / 'summary.json').write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n')
lines = [
    '# Phase 2 RTL Verification Report', '',
    f'**Result:** {result["overall"]}  |  **PASS:** {passed}  |  **FAIL:** {failed}',
    '', f'- Mode: `{mode}`', f'- Lab: `{lab}`', f'- Report: `{out}`', '',
    '| Check | Status | Details |', '|---|---|---|',
]
lines.extend(f'| {r["check"]} | {r["status"]} | {r["detail"]} |' for r in rows)
lines.extend(['', '## Git (read-only)', '', '```text', git_status or '(clean)', '```', '',
              'This run checks the example counter only; it does not validate other RTL modules.'])
(out / 'summary.md').write_text('\n'.join(lines) + '\n')
print('\n========== PHASE 2 REPORT ==========')
print(f'AUTOMATED CHECKS: {passed} PASS, {failed} FAIL')
print(f'OVERALL: {result["overall"]}')
print(f'REPORT: {out / "summary.md"}')
print(f'JSON: {out / "summary.json"}')
if failed:
    print('Inspect per-check logs inside report/logs for the first failing tool.')
sys.exit(0 if result['overall'] == 'PASS' else 1)
REPORT
