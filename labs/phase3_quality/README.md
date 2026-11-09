# Phase 3 — Professional RTL Quality Lab

- Self-contained in `labs/phase3_quality`, reuses Phase 2 DUT without changing it.
- `tests/`: cocotb regression for async reset, rollover, hold and seeded scenarios.
- `assertions/`: immediate SystemVerilog assertions, checked by Icarus.
- `formal/`: Yosys sequential equivalence versus alternate 4-bit reference.
- `scripts/run_quality.sh`: quality gate and timestamped JSON/Markdown reports.
- `.github/workflows/phase3-rtl-quality.yml`: CI workflow (only runs on GitHub after commit/push).
- `AGENTS.md`: project rules for Google Antigravity.

Run: `make -C labs/phase3_quality verify` from repo root.
Cocotb must be importable from `PHASE3_PYTHON` or an existing supported venv.
A local private venv is created only if the installer cannot find cocotb.

Limitations: The formal stage checks WIDTH=4; proof depends on Yosys' sequential-equivalence
engine and reset assumptions. This is not gate-level timing, functional coverage,
CDC, physical design, DFT or silicon sign-off.
No script commits or pushes to GitHub; inspect new files before committing.
