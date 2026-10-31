import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer

@cocotb.test()
async def counter_verification(dut):
    rng = random.Random(2026)
    dut.rst.value = 1
    dut.en.value = 0

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    expected = 0
    visited = set()

    for cycle in range(250):
        await FallingEdge(dut.clk)

        rst = int(cycle in (0, 1, 64, 65) or
                  (cycle >= 25 and rng.randrange(25) == 0))
        en = 1 if cycle < 25 else rng.randrange(2)

        dut.rst.value = rst
        dut.en.value = en

        await RisingEdge(dut.clk)

        if rst:
            expected = 0
        elif en:
            expected = (expected + 1) % 10

        await Timer(1, unit="ns")

        assert int(dut.q.value) == expected, (
            f"Cycle {cycle}: q mismatch"
        )
        assert int(dut.tc.value) == int(expected == 9), (
            f"Cycle {cycle}: tc mismatch"
        )

        visited.add(expected)

    assert len(visited) == 10, "Missing counter states"
    dut._log.info("COCOTB PASS: 250 CHECKED CYCLES")
