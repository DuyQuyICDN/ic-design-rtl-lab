ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
.PHONY: verify quality help
verify quality:
	@bash "$(ROOT)/scripts/run_quality.sh"
help:
	@printf 'Run Phase 2 baseline + cocotb + assertions + formal quality gate: make verify\n'
