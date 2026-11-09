"""Deterministic, independent cocotb regression against Phase 2 rtl_counter."""
import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer


async def reset_dut(dut):
    dut.clk.value = 0
    dut.enable.value = 0
    dut.rst_n.value = 0
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await Timer(2, unit="ns")
    assert int(dut.count.value) == 0, "Asynchronous reset failed"
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1


async def step(dut, value, expected, label):
    # Set inputs on falling edge to avoid DUT sampling races.
    await FallingEdge(dut.clk)
    dut.enable.value = value
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")  # Check only after nonblocking updates.
    if value:
        expected = (expected + 1) & 0xF
    actual = int(dut.count.value)
    assert actual == expected, f"{label}: expected {expected}, got {actual}"
    return expected


@cocotb.test()
async def exhaust_reset_hold_rollover(dut):
    await reset_dut(dut)
    expected = 0
    for i in range(16):
        expected = await step(dut, 1, expected, f"rollover {i}")
    assert expected == 0
    for i in range(8):
        expected = await step(dut, 0, expected, f"hold {i}")
    expected = await step(dut, 1, expected, "increment after wrap")
    # Assert reset between clock edges with Q nonzero.
    await Timer(2, unit="ns")
    dut.rst_n.value = 0
    await Timer(1, unit="ns")
    assert int(dut.count.value) == 0, "Reset from nonzero failed"
    dut.enable.value = 0
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1
    expected = 0
    expected = await step(dut, 0, expected, "hold after reset")
    assert expected == 0


@cocotb.test()
async def seeded_mixed_enable(dut):
    await reset_dut(dut)
    rng = random.Random(20261101)
    expected = 0
    for i in range(200):
        en = rng.randrange(2)
        expected = await step(dut, en, expected, f"seeded cycle {i}")
