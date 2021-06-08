import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

import numpy as np
from queue import Queue
from fixedpoint import FixedPoint as fp

np.random.seed(0)

@cocotb.test()
async def testbench(dut):
