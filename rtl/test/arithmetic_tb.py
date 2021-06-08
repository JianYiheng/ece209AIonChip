import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

import numpy as np
from queue import Queue

np.random.seed(0)

def getDataArray(size, wl):
    dMax = 2**(wl-1) - 1
    dMin = -2**(wl-1)

    return np.random.randint(low=dMin, high=dMax, size=size)

def convert(din, wl):
    
    din_str = np.binary_repr(din, wl)
    return int(din_str, 2)

def np221v(x0, x1, wl):
    x0_bin = np.binary_repr(x0, wl)
    x1_bin = np.binary_repr(x1, wl)
    return int(x1_bin+x0_bin, 2)

@cocotb.test()
async def testbench(dut):

    clock = Clock(dut.clk, 2, units="ns")
    cocotb.fork(clock.start())

    dut._log.info("Running test begin")

    din_x_array = getDataArray(100, 8)
    din_y_array = getDataArray(50, 8)

    dut.reset <= 1

    # await RisingEdge(dut.clk)
    await ClockCycles(dut.clk, 2, rising=True)
    dut.reset <= 0
    pQueue = Queue(7)
    for i in range(50):

        # ! raw data generated
        din_x0_raw = din_x_array[2*i]
        din_x1_raw = din_x_array[2*i+1]
        din_y_raw = din_y_array[i]


        # ! raw data combined input
        din_x_v = np221v(din_x0_raw, din_x1_raw, 8)
        din_y_v = convert(din_y_raw, 8)

        # ! RTL Input
        dut.x <= din_x_v
        dut.y <= din_y_v
        dut.mode <= 0

        # ! RTL Output
        # await ClockCycles(dut.clk, 4, rising=True)
        await RisingEdge(dut.clk)
        dout_receive = dut.p.value

        # ! raw data output
        dout_p0_np = din_x0_raw*din_y_raw;
        dout_p1_np = din_x1_raw*din_y_raw;


        # ! raw data combined output
        dout_p_np = np221v(dout_p0_np, dout_p1_np, 16) 

        cache = [din_x0_raw, din_x1_raw, din_y_raw, dout_p0_np, dout_p1_np, din_x_v, din_y_v, dout_p_np]

        # ! delay the output for 4 cycles
        if pQueue.full():
            din_x0_raw_s, din_x1_raw_s, din_y_raw_s, dout_p0_np_s, dout_p1_np_s, din_x_v_s, din_y_v_s, dout_p_np_s, dout_receive_s = pQueue.get()
            # assert dout_p_np_s == dout_receive
            dut._log.info("x0={}, x1={}".format(din_x0_raw_s, din_x1_raw_s))
            dut._log.info("y={}".format(din_y_raw_s))
            dut._log.info("p0={}, p1={}".format(dout_p0_np_s, dout_p1_np_s))
            dut._log.info("x_in={}, y_in={}".format(np.binary_repr(din_x_v_s, 16), np.binary_repr(din_y_v_s, 8)))
            dut._log.info("numpy output: {}".format(np.binary_repr(dout_p_np_s, 32)))
            dut._log.info("VPI   output: {}".format(dout_receive))
            dut._log.info("{}, {}".format(dout_receive.integer, dout_p_np_s))
            assert dout_receive.integer == dout_p_np_s
        pQueue.put([din_x0_raw, din_x1_raw, din_y_raw, dout_p0_np, dout_p1_np, din_x_v, din_y_v, dout_p_np, dout_receive])



    dut._log.info("Running test end")

