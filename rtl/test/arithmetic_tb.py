import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

import numpy as np

def getDataArray(wl, size):
    dMax = 2**(wl-1) - 1
    dMin = -2**(wl-1)

    return np.random.randint(low=dMin, high=dMax, size=size)

def convert(din, wl):
    
    din_str = np.binary_repr(din, wl)
    return int(din_str, 2)

    # dout = 0
    # if din >= 0:
    #     dout = din
    # else:
    #     dout = din&(2**(wl-1)-1)|(2**(wl-1))
    # return dout

@cocotb.test()
async def testbench(dut):

    clock = Clock(dut.clk, 10, units="ns")
    cocotb.fork(clock.start())

    dut._log.info("Running test begin")

    din_x_array = getDataArray(8, 100)
    din_y_array = getDataArray(8, 50)

    await RisingEdge(dut.clk)
    for i in range(50):
        din_x0_raw = din_x_array[2*i]
        din_x1_raw = din_x_array[2*i+1]
        din_y_raw = din_y_array[i]

        dut._log.info("x0_raw={} ,x1_raw={}".format(din_x0_raw, din_x1_raw))

        din_x0_v = convert(8, din_x0_raw)
        din_x1_v = convert(8, din_x1_raw)
        din_y_v = convert(8, din_y_raw)
        dut._log.info("x0_in={}, y_in={}".format(din_x0_v|(din_x1_v<<8), din_y_v))
        
        dout_p0_ep = din_x0_raw*din_y_raw;
        dout_p1_ep = din_x1_raw*din_y_raw;

        dout_p0_ep_str = np.binary_repr(dout_p0_ep, 16)
        dout_p1_ep_str = np.binary_repr(dout_p1_ep, 16)

        # ! RTL Input
        dut.x <= (din_x0_v + (din_x1_v<<8))
        dut.y <= (din_y_v)
        dut.mode <= 0

        # ! RTL Output
        await ClockCycles(dut.clk, 4, rising=True)
        dout_receive = dut.p.value

        dout_p0_str = dout_receive.binstr[:-16]
        dout_p1_str = dout_receive.binstr[-16:]

        dut._log.info("p0_ep={}, p1_ep={}".format(dout_p0_ep_str, dout_p1_ep_str))
        dut._log.info("p0_rc={}, p1_rc={}".format(dout_p0_str, dout_p1_str))

        # assert dout_expect == dout_receive

    dut._log.info("Running test end")

