#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C
LAB3="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
ROOT="$(cd -- "$LAB3/../.." && pwd -P)"
LAB2="$ROOT/labs/phase2_counter"
OUT="$LAB3/reports/runs/$(date +%Y%m%dT%H%M%S)-$$"
mkdir -p -- "$OUT/logs" "$OUT/artifacts" "$OUT/cocotb"
STATUS="$OUT/status.tsv"
: > "$STATUS"

record() {
  printf '%s\t%s\t%s\n' "$1" "$2" "$3" >> "$STATUS"
  printf '[%s] %-25s %s\n' "$2" "$1" "$3"
}
run() {
  local label="$1"; shift
  local rc=0
  "$@" > "$OUT/logs/$label.log" 2>&1 || rc=$?
  if [[ "$rc" -eq 0 ]]; then record "$label" PASS "exit=0 (logs/$label.log)"; return 0; fi
  record "$label" FAIL "exit=$rc (logs/$label.log)"; return 1
}

printf '\nPHASE 3 QUALITY GATE\nRUN: %s\n' "$OUT"
run phase2_baseline make -C "$LAB2" verify || true

# Find the cocotb installation in the selected python environment.
PY="${PHASE3_PYTHON:-}"
if [[ -z "$PY" ]]; then
  for p in "$HOME/venvs/ic-verification/bin/python" "$HOME/.local/share/ic-design-phase3-venv/bin/python" "$(command -v python3)"; do
    if [[ -x "$p" ]] && "$p" -c 'import importlib.metadata as m; assert int(m.version("cocotb").split(".")[0]) == 2' >/dev/null 2>&1; then PY="$p"; break; fi
  done
fi
if [[ -z "$PY" || ! -x "$PY" ]] || ! "$PY" -c 'import importlib.metadata as m; assert int(m.version("cocotb").split(".")[0]) == 2' >/dev/null 2>&1; then
  record cocotb_regression FAIL 'cocotb missing: run Phase 3 installer to provision isolated venv'
else
  COCOTB_BIN="$(dirname "$PY")"
  if env -u PYTHONHOME -u PYTHONPATH PATH="$COCOTB_BIN:/usr/bin:/bin:$PATH" PHASE2_RTL="$LAB2/rtl/rtl_counter.sv" PHASE3_TESTS="$LAB3/tests" \
      make -C "$OUT/cocotb" -f "$LAB3/tests/Makefile.cocotb" SIM=icarus \
      > "$OUT/logs/cocotb_regression.log" 2>&1; then
    if [[ -s "$OUT/cocotb/results.xml" ]] && python3 - "$OUT/cocotb/results.xml" <<'XML'
import sys, xml.etree.ElementTree as ET
root=ET.parse(sys.argv[1]).getroot()
num=sum(int(e.attrib.get('tests','0')) for e in root.iter() if e.tag=='testsuite')
fail=sum(int(e.attrib.get('failures','0'))+int(e.attrib.get('errors','0')) for e in root.iter() if e.tag=='testsuite')
sys.exit(0 if num>=2 and fail==0 else 1)
XML
    then
      record cocotb_regression PASS 'two tests passed; results.xml available'
    else
      record cocotb_regression FAIL 'missing/invalid cocotb XML or fewer than two passing tests'
    fi
  else
    record cocotb_regression FAIL 'cocotb build/run failed (logs/cocotb_regression.log)'
  fi
fi

if run assertion_compile iverilog -g2012 -s tb_counter_properties -o "$OUT/artifacts/properties.vvp" \
     "$LAB2/rtl/rtl_counter.sv" "$LAB3/assertions/tb_counter_properties.sv"; then
  if run assertion_run vvp "$OUT/artifacts/properties.vvp"; then
    if grep -q 'ASSERT_PASS checks=' "$OUT/logs/assertion_run.log"; then
      record assertion_results PASS 'SV immediate assertions executed and passed'
    else
      record assertion_results FAIL 'missing ASSERT_PASS result'
    fi
  else
    record assertion_results FAIL 'assertion simulation failed'
  fi
else
  record assertion_run FAIL 'assertions did not compile'
  record assertion_results FAIL 'assertions unavailable'
fi

# Sequential equivalence of the *actual Phase 2 RTL* and a distinct reference.
cat > "$OUT/artifacts/equiv.ys" <<YOSYS
read_verilog -sv "$LAB2/rtl/rtl_counter.sv" "$LAB3/formal/counter_reference.sv"
proc
async2sync
equiv_make counter_reference rtl_counter equiv_counter
hierarchy -top equiv_counter
prep -top equiv_counter
equiv_simple -seq 3
equiv_induct -seq 5
equiv_status -assert
YOSYS
run formal_equivalence yosys -Q -T -s "$OUT/artifacts/equiv.ys" || true

# Provide a repeatable CI file, but it does not execute remotely until committed/pushed.
if [[ -f "$ROOT/.github/workflows/phase3-rtl-quality.yml" ]]; then
  record ci_workflow PASS 'GitHub Actions workflow file exists (not run remotely)'
else
  record ci_workflow FAIL 'GitHub Actions workflow missing'
fi

python3 - "$ROOT" "$LAB3" "$OUT" <<'REPORT'
from datetime import datetime, timezone
from pathlib import Path
import json, subprocess, sys
repo,lab,out=map(Path,sys.argv[1:])
checks=[]
for line in (out/'status.tsv').read_text().splitlines():
    name,status,detail=line.split('\t',2)
    checks.append({'check':name,'status':status,'detail':detail})
passed=sum(r['status']=='PASS' for r in checks)
failed=sum(r['status']=='FAIL' for r in checks)
try:
    git=subprocess.run(['git','-C',str(repo),'status','--short'],capture_output=True,text=True,check=False).stdout.strip()
except OSError: git='unknown'
obj={'phase':3,'timestamp_utc':datetime.now(timezone.utc).isoformat(),
     'result':'PASS' if checks and failed==0 else 'FAIL','pass':passed,'fail':failed,
     'checks':checks,'git_status_read_only':git,
     'scope':'Phase 2 WIDTH=4 counter only; no timing signoff or code/functional coverage percentage'}
(out/'summary.json').write_text(json.dumps(obj,indent=2,ensure_ascii=False)+'\n')
lines=['# Phase 3 — RTL Automation & Quality', '',
       f'**Overall: {obj["result"]} | {passed} PASS, {failed} FAIL**','',
       '| Check | Result | Detail |','|---|---|---|']
lines += [f'| {x["check"]} | {x["status"]} | {x["detail"]} |' for x in checks]
lines += ['', '## Scope and limits', '',obj['scope'], '',
          '## Git status (read-only)','', '```text', git or '(clean)', '```', '',
          'Generated waveforms and simulation binaries are ignored by Git. No add/commit/push was run.']
(out/'summary.md').write_text('\n'.join(lines)+'\n')
print('\n========== PHASE 3 REPORT ==========')
print(f'AUTOMATED CHECKS: {passed} PASS, {failed} FAIL')
print(f'OVERALL: {obj["result"]}')
print(f'REPORT: {out / "summary.md"}')
print(f'JSON: {out / "summary.json"}')
print('FAILURES: inspect logs/ and cocotb/results.xml if needed') if failed else None
sys.exit(0 if obj['result']=='PASS' else 1)
REPORT
