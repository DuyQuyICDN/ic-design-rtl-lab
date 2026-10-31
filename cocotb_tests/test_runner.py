from pathlib import Path
from cocotb_tools.runner import get_runner

ROOT = Path(__file__).resolve().parents[1]

def test_icarus_counter():
    runner = get_runner("icarus")

    runner.build(
        sources=[ROOT / "counter.sv"],
        hdl_toplevel="counter",
        build_dir=ROOT / "build" / "cocotb",
        build_args=["-g2012"],
        timescale=("1ns", "1ps"),
        always=True,
    )

    runner.test(
        hdl_toplevel="counter",
        test_module="cocotb_counter",
        build_dir=ROOT / "build" / "cocotb",
        test_dir=ROOT / "cocotb_tests",
    )
