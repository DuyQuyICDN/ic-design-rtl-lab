# Antigravity — Phase 4 ASIC RTL Portfolio
- Read `docs/specification.md` and each IP's contract before writing RTL.
- Prefer synthesizable SystemVerilog with explicit reset, clock and protocol timing.
- Separate educational simulation/synthesis from PDK-bound physical implementation.
- Never claim GDSII, STA, DRC, LVS, timing closure or tapeout without tool artifacts.
- Testbench PASS is limited to stated scenarios; it is not exhaustive proof.
- Run `make -C labs/phase4_portfolio verify` after approved changes.
- Request approval before editing pre-existing files; never delete, install, or git push automatically.
- Never expose credentials. Don't commit secrets, waveform logs or virtual environments.
