# IC Design RTL / EDA workspace

## Tools
VS Code Remote WSL + Icarus Verilog + Verilator + Yosys + Graphviz + GTKWave.
Copilot instructions are kept at `.github/copilot-instructions.md` if present.

## One-command workflow

```bash
cd ~/rtl-test
bash scripts/full_check.sh
```

This checks tools, lints the RTL, compiles and runs the basic + extended
self-checking testbenches, writes logs, runs generic synthesis,
exports a generic netlist and an SVG RTL schematic (when Graphviz is installed).

## Useful commands

- `bash scripts/check_env.sh` — tool availability
- `bash scripts/verify.sh` — lint + both testbenches
- `bash scripts/synth.sh` — generic Yosys netlist + RTL SVG
- `bash scripts/full_check.sh` — entire workflow
- `gtkwave counter_extra.vcd` — waveforms (if GUI available)

## Outputs

- `reports/ai_sim.log`
- `reports/extra_sim.log`
- `reports/yosys_synth.log`
- `reports/counter_rtl.svg`
- `reports/verification_summary.txt`
- `build/counter_generic_netlist.v`

## VS Code

The existing keyboard shortcut `Ctrl+Alt+R` targets the task label
`IC Design: Run RTL Tests`. Setup preserves this name and points it to
`scripts/full_check.sh` (verification + generic synthesis).
Additional tasks appear in **Terminal → Run Task**.

## Scope

This environment covers **digital RTL design, simulation, basic verification,
and generic logic synthesis**. It does not constitute ASIC technology mapping,
static timing analysis, physical design, signoff, analog simulation, or a tapeout.
Do not infer PPA, silicon area, timing closure or 100% functional coverage from PASS.

User RTL, testbench files, `run_ai_test.sh`, Copilot instructions and personal
keyboard shortcut settings are not overwritten by this setup script.
