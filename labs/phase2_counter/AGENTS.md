# Antigravity — RTL Verification Lab Rules

## Design rules
- Read `docs/specification.md` before editing RTL.
- Prefer SystemVerilog `logic`, `always_ff`, and `always_comb` when applicable.
- Use nonblocking `<=` in sequential logic; avoid incomplete assignments and implicit nets.
- Verify widths, reset polarity, unsigned arithmetic, state transitions and timing assumptions.
- Reset style is a specification decision, not a universal rule.

## Verification rules
- Keep DUT RTL separate from testbench.
- Every change requires lint, self-checking simulation and synthesis checks (`make verify`).
- Test reset at an off-clock time, enable/hold, rollover and representative sequences.
- Report which tools were actually executed. Never invent PASS results.
- Evidence lives in timestamped `reports/runs/...` folders.

## Safety and review
- Propose a plan and show diffs before changing existing files.
- Don't run install commands, publish files or push to GitHub without approval.
- Never expose secrets or credentials; no `.env` files or API keys in this lab.
