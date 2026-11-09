#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C
LAB="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
ROOT="$(cd -- "$LAB/../.." && pwd -P)"
for tool in make python3 iverilog vvp verilator yosys; do command -v "$tool" >/dev/null || { echo "[ERROR] missing $tool"; exit 2; }; done
[[ ! -L "$LAB/reports" && ! -L "$LAB/reports/runs" ]] || { echo '[ERROR] symlink in output path'; exit 2; }
mkdir -p "$LAB/reports/runs"
RUN="$(mktemp -d "$LAB/reports/runs/$(date +%Y%m%dT%H%M%S)-$$-XXXX")"
mkdir -p "$RUN/logs" "$RUN/vcd" "$RUN/netlist"
cd "$RUN/vcd"
declare -a NAMES=() STATES=() DETAILS=()
pass=0; fail=0; skip=0
record() {
    NAMES+=("$1"); STATES+=("$2"); DETAILS+=("$3")
    case "$2" in PASS) pass=$((pass+1));; FAIL) fail=$((fail+1));; SKIP) skip=$((skip+1));; esac
    printf '[%s] %-24s %s\n' "$2" "$1" "$3"
}
run_gate() {
    local label="$1" log="$RUN/logs/${1}.log"
    shift
    if "$@" >"$log" 2>&1; then record "$label" PASS "logs/${label}.log"; else record "$label" FAIL "logs/${label}.log"; fi
}
simulate() {
    local ip="$1" module="$2" marker="$3" out="$RUN/${1}.vvp"
    iverilog -g2012 -s "$module" -o "$out" "$LAB/rtl/$ip.sv" "$LAB/tb/$module.sv" || return $?
    vvp "$out" || return $?
    # Require positive verification marker; simulator exit 0 alone isn't enough.
    # vvp log gets checked in the caller after output redirection.
}
synth() {
    local ip="$1"
    yosys -Q -T -p "read_verilog -sv \"$LAB/rtl/$ip.sv\"; hierarchy -check -top $ip; synth -top $ip; check -assert; write_verilog -noattr \"$RUN/netlist/${ip}_netlist.v\"" && [[ -s "$RUN/netlist/${ip}_netlist.v" ]]
}
echo 'PHASE 4 — ASIC IP QUALITY GATES'
echo "RUN: $RUN"
if [[ "${PHASE4_SKIP_BASELINES:-0}" == 1 ]]; then
  record phase2_baseline SKIP 'CI-only mode; independently verified earlier'
  record phase3_baseline SKIP 'CI-only mode; separately requires cocotb'
else
  run_gate phase2_baseline make -C "$ROOT/labs/phase2_counter" verify
  run_gate phase3_baseline make -C "$ROOT/labs/phase3_quality" verify
fi
for ip in uart_tx sync_fifo spi_master_mode0; do
  run_gate "lint_${ip}" verilator --lint-only -Wall --top-module "$ip" "$LAB/rtl/$ip.sv"
  case "$ip" in uart_tx) marker=UART_TX_PASS;; sync_fifo) marker=SYNC_FIFO_PASS;; spi_master_mode0) marker=SPI_MODE0_PASS;; esac
  run_gate "sim_${ip}" simulate "$ip" "tb_${ip}" "$marker"
  log="$RUN/logs/sim_${ip}.log"
  # Tighten simulation gate: output must contain explicit PASS marker and emitted VCD.
  idx=$((${#STATES[@]}-1))
  if [[ "${STATES[$idx]}" == PASS ]] && { ! grep -q "$marker" "$log" || [[ ! -s "$RUN/vcd/${ip}.vcd" ]]; }; then
    STATES[$idx]=FAIL; pass=$((pass-1)); fail=$((fail+1))
    printf '[FAIL] %-24s missing marker or VCD\n' "sim_${ip}"
  fi
  run_gate "synth_${ip}" synth "$ip"
done
if [[ -s "$ROOT/.github/workflows/phase4-rtl-portfolio.yml" ]] &&
   grep -q 'make -C labs/phase4_portfolio verify' "$ROOT/.github/workflows/phase4-rtl-portfolio.yml"; then
  record ci_workflow PASS 'workflow declared; remote CI not executed'
else
  record ci_workflow FAIL 'workflow missing or incorrect command'
fi
# Only inspect Git's staged index. Never print keys; fail when a recognizable key pattern exists.
if git -C "$ROOT" grep --cached -I -q -E \
   -e 'sk-proj-[A-Za-z0-9_-]+' \
   -e 'AIza[A-Za-z0-9_-]{20,}' \
   -e 'AQ\.Ab[A-Za-z0-9_-]{16,}' \
   -- . >/dev/null 2>&1; then
  record staged_secrets FAIL 'possible API key in staged files; inspect before commit'
else
  scan_rc=$?
  if [[ "$scan_rc" == 1 ]]; then
    record staged_secrets PASS 'no listed API key patterns found in staged index'
  else
    record staged_secrets FAIL "git grep failed with exit=$scan_rc"
  fi
fi
if command -v openroad >/dev/null 2>&1; then
  record physical_flow SKIP 'openroad installed; no PDK/ORFS configured; no GDSII'
else
  record physical_flow SKIP 'openroad not installed; PDK/ORFS required for GDSII'
fi
# A compact audit of the Git index; never stage/commit secrets automatically.
{
 echo 'STAGED PATHS (review manually before commit):'
 git -C "$ROOT" diff --cached --name-only
 echo 'GIT STATUS:'
 git -C "$ROOT" status --short
} > "$RUN/logs/git_review.log"
export PHASE4_RUN="$RUN" PHASE4_PASS="$pass" PHASE4_FAIL="$fail" PHASE4_SKIP="$skip"
# Write report from data through environment; no untrusted shell interpolation.
{
  for i in "${!NAMES[@]}"; do printf '%s\t%s\t%s\n' "${NAMES[$i]}" "${STATES[$i]}" "${DETAILS[$i]}"; done
} > "$RUN/rows.tsv"
python3 - <<'PY'
import json,os,pathlib
p=pathlib.Path(os.environ['PHASE4_RUN'])
rows=[dict(name=x[0],status=x[1],detail=x[2]) for line in (p/'rows.tsv').read_text().splitlines() if (x:=line.split('\t',2)) and len(x)==3]
pass_n=int(os.environ['PHASE4_PASS']); fail_n=int(os.environ['PHASE4_FAIL']); skip_n=int(os.environ['PHASE4_SKIP'])
result={'overall':'PASS' if fail_n==0 else 'FAIL','pass':pass_n,'fail':fail_n,'skip':skip_n,'checks':rows,'scope':'Educational RTL verification; no physical sign-off, no remote CI confirmation'}
(p/'summary.json').write_text(json.dumps(result,indent=2)+'\n')
md=['# Phase 4 — ASIC IP Portfolio Quality', '',f"**Overall: {result['overall']}** — {pass_n} PASS, {fail_n} FAIL, {skip_n} SKIP",'','| Check | Status | Evidence |','|---|---|---|']
md += [f"| {x['name']} | {x['status']} | {x['detail']} |" for x in rows]
md += ['','OpenROAD/GDSII not completed unless a separate technology-mapped physical flow is actually run. GitHub Actions workflow exists locally; remote run pending commit/push.','Review `logs/git_review.log` for staged paths.']
(p/'summary.md').write_text('\n'.join(md)+'\n')
PY
printf '\n========== PHASE 4 REPORT ==========\n'
printf 'AUTOMATED CHECKS: %s PASS, %s FAIL, %s SKIP\n' "$pass" "$fail" "$skip"
printf 'OVERALL: %s\n' "$([[ "$fail" -eq 0 ]] && echo PASS || echo FAIL)"
printf 'REPORT: %s/summary.md\nJSON: %s/summary.json\n' "$RUN" "$RUN"
[[ "$fail" -eq 0 ]]
