# Phase 4 — IP Specifications (Educational)

| IP | Clock/reset | Contract | Out of scope |
|---|---|---|---|
| UART TX | `clk`, active-low async reset | 8N1, LSB first, `start` accepted when `ready` high; CLKS_PER_BIT=4 for test | UART RX, parity, oversampling, baud error tolerance |
| Sync FIFO | single `clk`, active-low async reset | width 8, depth 4, registered read data, full/empty/used; full simultaneous read/write allowed; empty simultaneous ops accept write only | Dual clock/CDC, ECC, FWFT, arbitrary non-power-of-two depth |
| SPI Master | `clk`, active-low async reset | SPI mode 0, 8 bits MSB first, one transfer per `start`, `done` pulse, CLK_DIV=2 for test | CPOL/CPHA variants, multi-slave, variable word size, real I/O timing |

This is a teaching-quality portfolio, not a production IP certification. Synthesis is generic gate-level synthesis; no PDK area/timing or physical sign-off is claimed. Formal proof and coverage of all new IPs are not included.
