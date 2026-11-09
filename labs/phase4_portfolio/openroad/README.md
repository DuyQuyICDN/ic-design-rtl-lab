# Physical Design — Preparation, Not GDSII Sign-off

OpenROAD alone does not supply technology LEF, Liberty, placement sites, RC and routing rules. The complete **OpenROAD Flow Scripts (ORFS)** with a supported platform (e.g. Nangate45) and dependencies are required for RTL-to-GDSII.

This lab's `rtl/uart_tx.sv` has no timing constraints associated with a particular PDK. For a future ORFS experiment, choose a platform, add clock constraint (`create_clock`), and prepare a design-specific `config.mk` under an ORFS design directory. Run synthesis, floorplan, placement, CTS, routing and DRC with flow logs; don't claim successful GDS or timing sign-off until the actual artifacts exist and checks pass.

Official: https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts

Phase 4 setup reports whether `openroad` and `klayout` binaries exist; it **does not** install them or execute an incomplete physical design flow. Any `SKIP` is intentional rather than counted as PASS.
