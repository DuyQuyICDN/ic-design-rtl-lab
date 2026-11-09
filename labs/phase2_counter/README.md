# IC Design — Phase 2 RTL Verification Lab

This lab is **self-contained** and intentionally does **not** change existing RTL, testbenches,
Git history, or `.vscode/settings.json` in the parent repository.

## Layout
- `rtl/rtl_counter.sv`: synthesizable parameterized SystemVerilog counter.
- `tb/tb_rtl_counter.sv`: self-checking Icarus Verilog testbench.
- `docs/specification.md`: interface and expected behavior.
- `AGENTS.md`: Antigravity RTL + verification rules.
- `scripts/run_checks.sh`: checks runner and machine-readable report.
- `Makefile`: canonical tasks.
- `reports/runs/<timestamp>-<pid>/`: reports, logs, netlist and VCD; ignored by Git.

## Run
```bash
cd ~/rtl-test/labs/phase2_counter
make verify
```
Or `make lint`, `make sim`, `make synth` for an individual step. `make verify` is the gate.

Successful full runs produce `summary.md`, `summary.json`, simulator logs, synthesized netlist
and `waveforms/counter.vcd`. Only actual successful checks are marked PASS.

To view the latest report (read-only):
```bash
find reports/runs -name summary.md -print | sort | tail -n 1
```

## Version control and safety
- Do not commit generated VCD, compiled artifacts or secrets.
- The installer and runner do not `git add`, commit, push, delete or edit old project files.
- Re-running the installer preserves existing source files and creates a new report run.
- Parent `AGENTS.md` is created only when absent. Existing `AGENTS.md` is preserved.
- The lab's test PASS only validates this sample DUT/testbench, **not** the user's older RTL.
