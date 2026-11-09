# ASIC RTL Portfolio — Phase 4

Educational self-checking IP blocks for a student's RTL/verification portfolio.

| IP | Source | Testbench |
|---|---|---|
| UART TX 8N1 | `rtl/uart_tx.sv` | `tb/tb_uart_tx.sv` |
| Single-clock FIFO | `rtl/sync_fifo.sv` | `tb/tb_sync_fifo.sv` |
| SPI master mode 0 | `rtl/spi_master_mode0.sv` | `tb/tb_spi_master_mode0.sv` |

Run from repository root:

```bash
make -C labs/phase4_portfolio verify
```

Each run creates a unique `reports/runs/...` directory with lint, simulation, synthesis, generated VCD and generic netlist files. The executable verifies earlier phase 2 and 3 baselines as separate gates by default. CI sets `PHASE4_SKIP_BASELINES=1` because phase 3's Python/cocotb prerequisites are not installed by the phase 4 CI workflow.

Read `docs/specification.md` and the generated summary. OpenROAD/ORFS requires PDK libraries and a full flow; see `openroad/README.md`. The script only probes OpenROAD availability; it never falsely reports GDSII completion.

Review Git changes manually; the setup script does NOT commit or push. `.vscode/settings.json` may already be staged independently of this lab.
