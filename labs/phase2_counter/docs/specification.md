# Phase 2 Counter — Functional Specification

**DUT:** `rtl_counter`, a parametrizable `WIDTH`-bit unsigned up-counter (tested at WIDTH=4).

| Port | Direction | Meaning |
|---|---|---|
| `clk` | input | Positive-edge clock |
| `rst_n` | input | Asynchronous active-low reset |
| `enable` | input | Enables increment at positive edge |
| `count[WIDTH-1:0]` | output | Unsigned counter value |

## Functional contract
1. If `rst_n == 0`, `count` becomes zero without waiting for a clock edge.
2. Otherwise, at a rising clock edge, if `enable == 1`, increment by one modulo `2**WIDTH`.
3. If `enable == 0`, retain `count`; changing enable between edges does not itself change Q.
4. Assumes `WIDTH >= 1`; default `WIDTH = 4`.
5. Reset deassertion and asynchronous reset-release timing sign-off are outside simulation scope.

## Verification matrix
- RST-01: asynchronous assertion at time not aligned with clock.
- CNT-01: count from 0 to maximum and wrap to 0.
- EN-01: clock pulses while disabled retain nonzero count.
- RST-02: reset from nonzero state overrides enable.
- MIX-01: 64-cycle deterministic enabled/disabled regression.
- LINT-01: Verilator parses and lint-checks DUT.
- SYN-01: Yosys synthesizes DUT and `check -assert` succeeds.
- WAVE-01: nonempty VCD produced by simulation.

This lab is an educational regression, not production ASIC sign-off. No CDC, STA, DFT,
formal proof, power estimation, PVT characterization or technology mapping is claimed.
