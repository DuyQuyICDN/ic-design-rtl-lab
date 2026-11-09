ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
.PHONY: all verify lint sim synth help
all: verify
verify:
	@bash "$(ROOT)/scripts/run_checks.sh" all
lint:
	@bash "$(ROOT)/scripts/run_checks.sh" lint
sim:
	@bash "$(ROOT)/scripts/run_checks.sh" sim
synth:
	@bash "$(ROOT)/scripts/run_checks.sh" synth
help:
	@printf 'Targets: verify (all checks), lint, sim, synth\n'
