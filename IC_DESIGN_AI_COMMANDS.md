# IC Design Copilot Pro — 10 commands

These are local VS Code prompt files in `.github/prompts/`.
Use the **Local** harness in VS Code Chat. Type `/` to see installed prompt commands.

| Slash command | Purpose | Mode |
| --- | --- | --- |
| `/rtl-review` | Evidence-based RTL review | ask |
| `/rtl-debug` | Root-cause debugging | ask |
| `/rtl-check` | Propose full check; requires explicit approval to run | agent |
| `/rtl-report` | Formal verification/synthesis report | ask |
| `/tb-design` | Self-checking testbench design | ask |
| `/synthesis-audit` | Yosys synthesis audit | ask |
| `/analog-review` | SPICE and analog schematic review | ask |
| `/layout-drc-lvs` | DRC/LVS readiness / findings | ask |
| `/sta-readiness` | Timing analysis prerequisites | ask |
| `/ic-mentor` | Step-by-step IC Design tutoring | ask |

## How to run
1. Open VS Code connected to the `~/rtl-test` WSL workspace.
2. Open Chat (Ctrl+Alt+I in supported keymaps) and select **Local**.
3. Type `/rtl-review` or another command and add your question or reference file.
4. If a command isn't shown, run `Chat: Open Customizations`, inspect Workspace > Prompts and confirm this repository root is open.
5. Existing `.github/copilot-instructions.md` is intentionally preserved.

## Evidence boundaries
- Simulation PASS != measured 100% coverage.
- Generic Yosys cell stats != mapped silicon area/power/timing.
- Opening KLayout/Magic != completed DRC/LVS.
- An 8 GB Windows laptop should not be forced into full OpenROAD builds without resource checks.

## Security and repeatability
- This installer changes prompt files and this guide only, not RTL/testbench/EDA scripts or Git remote.
- Previous prompt files are backed up under `~/ic-design-prompt-backups/`.
- No network access or sudo is required.
- Review `git diff` before committing prompt changes.
