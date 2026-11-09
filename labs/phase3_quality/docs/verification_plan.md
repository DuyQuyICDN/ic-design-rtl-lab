# Phase 3 Verification Plan — Educational ASIC Counter

DUT: Phase 2 parameterized counter, tested with WIDTH=4 (default).
Reference specification: `../phase2_counter/docs/specification.md`.

| ID | Property or scenario | Evidence |
|---|---|---|
| RST-A | Async active-low reset drives count=0 before next active edge | cocotb + SV immediate assertion test |
| HOLD | Disabled cycle retains current count | cocotb + SV immediate assertion test |
| INC | Enabled rising edge increases count by 1 | cocotb + SV immediate assertion test |
| WRAP | 4-bit counter wraps from 15 to 0 | cocotb + SV immediate assertion test |
| RAND | Seeded mixed enable/hold stress | cocotb |
| EQUIV | DUT equivalent to structurally different 4-bit reference counter | Yosys equivalence flow |
| BASE | Phase 2 lint, simulation, and synthesis still pass | Phase 2 Makefile |
| CI | Same gate available in GitHub Actions | workflow (runs only once committed to remote) |

Coverage is a *test plan*, not measured functional or code coverage percentage.
Formal equivalence is limited to WIDTH=4 and tool assumptions; no CDC/STA/DFT/PVT sign-off.
