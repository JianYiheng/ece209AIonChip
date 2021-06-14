import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

import numpy as np
from queue import Queue
from fixedpoint import FixedPoint as fp

np.random.seed(3)

def getDataArray(size, wl, fl):
    dMax = 2**(wl-1) - 1
    dMin = -2**(wl-1)

    return np.random.randint(low=dMin, high=dMax+1, size=size)/2**fl

@cocotb.test()
async def testbench_8bit(dut):
    clock = Clock(dut.clk, 2, units="ns")
    cocotb.fork(clock.start())

    dut._log.info("Running test begin")

    wl = 8
    flx = 4
    fly = 7

    din_x_array = getDataArray(100, wl, flx)
    din_y_array = getDataArray(50, wl, fly)

    dut.reset <= 1

    # await RisingEdge(dut.clk)
    await ClockCycles(dut.clk, 2, rising=True)
    dut.reset <= 0
    pQueue = Queue(7)
    for i in range(50):

        # ! raw data generated
        din_x0_raw = fp(din_x_array[2*i], signed=True, m=wl-flx, n=flx, str_base=2)
        din_x1_raw = fp(din_x_array[2*i+1], signed=True, m=wl-flx, n=flx, str_base=2)
        din_y_raw = fp(din_y_array[i], signed=True, m=wl-fly, n=fly, str_base=2)


        # ! raw data combined input
        din_x_v = str(din_x1_raw)+str(din_x0_raw)
        din_y_v = str(din_y_raw)

        # ! RTL Input
        dut.x <= int(din_x_v, 2)
        dut.y <= int(din_y_v, 2)
        dut.mode <= 0

        # ! raw data output
        dout_p0_np = din_x0_raw*din_y_raw;
        dout_p1_np = din_x1_raw*din_y_raw;

        # ! RTL Output
        await RisingEdge(dut.clk)

        cache = map(float, [din_x0_raw, din_x1_raw, din_y_raw, dout_p0_np, dout_p1_np]) 

        if pQueue.full():
            din_x0_raw_s, din_x1_raw_s, din_y_raw_s, dout_p0_np_s, dout_p1_np_s = pQueue.get()

            dout_v = np.binary_repr(dut.p.value, 32) 
            dout_p0_v = fp("0b"+dout_v[-16:], signed=True, m=dout_p0_np.m, n=dout_p0_np.n, str_base=2) 
            dout_p1_v = fp("0b"+dout_v[:-16], signed=True, m=dout_p1_np.m, n=dout_p0_np.n, str_base=2) 

            dut._log.info("x0={}, x1={}".format(din_x0_raw_s, din_x1_raw_s))
            dut._log.info("y={}".format(din_y_raw_s))
            dut._log.info("p0_np={}, p1_np={}".format(dout_p0_np_s, dout_p1_np_s))
            dut._log.info("p0_v={}, p1={}".format(float(dout_p0_v), float(dout_p1_v)))
            assert float(dout_p0_v) == dout_p0_np_s
            assert float(dout_p1_v) == dout_p1_np_s
        pQueue.put(cache)



    dut._log.info("Running test end")

@cocotb.test()
async def testbench_4bit(dut):
    clock = Clock(dut.clk, 2, units="ns")
    cocotb.fork(clock.start())

    dut._log.info("Running test begin")

    wl = 4
    flx = 3
    fly = 3

    din_x_array = getDataArray(200, wl, flx)
    din_y_array = getDataArray(50, wl, fly)

    dut.reset <= 1

    # await RisingEdge(dut.clk)
    await ClockCycles(dut.clk, 2, rising=True)
    dut.reset <= 0
    pQueue = Queue(7)
    for i in range(50):

        # ! raw data generated
        def np2fp(x):
            return fp(x, signed=True, m=wl-flx, n=flx, str_base=2)

        din_x_fp_array = (*map(np2fp, din_x_array[4*i: 4*i+4]),)
        din_y_fp = np2fp(din_y_array[i])

        # ! raw data combined input
        din_x_v = "".join((*map(str, din_x_fp_array),))
        din_y_v = str(din_y_fp)

        # ! RTL Input
        dut.x <= int(din_x_v, 2)
        dut.y <= int(din_y_v, 2)
        dut.mode <= 1

        # ! raw data output

        dout_p_fp_array = [x*din_y_fp for x in din_x_fp_array]
        dout_p_m = dout_p_fp_array[0].m
        dout_p_n = dout_p_fp_array[0].n

        # ! RTL Output
        await RisingEdge(dut.clk)

        cache = [din_x_fp_array, din_y_fp, dout_p_fp_array]

        if pQueue.full():
            din_x_fp_array_s, din_y_fp_s, dout_p_fp_array_s= pQueue.get()

            dout_v = np.binary_repr(dut.p.value, 32) 

            # breakpoint()
            dout_v_fp_array = [fp("0b"+dout_v[i*8: i*8+8], signed=True, m=dout_p_m, n=dout_p_n, str_base=2) for i in range(4)]

            dut._log.info((*map(float, din_x_fp_array_s),))

            dut._log.info(float(din_y_fp_s))

            dut._log.info((*map(float, dout_p_fp_array_s),))

            dut._log.info(dout_v)
            dut._log.info((*map(float, dout_v_fp_array),))
            dut._log.info((*map(str, dout_v_fp_array),))

            assert dout_v_fp_array == dout_p_fp_array_s

        pQueue.put(cache)

    dut._log.info("Running test end")

@cocotb.test()
async def testbench_2bit(dut):
    clock = Clock(dut.clk, 2, units="ns")
    cocotb.fork(clock.start())

    dut._log.info("Running test begin")

    wl = 2
    flx = 1
    fly = 1

    din_x_array = getDataArray(400, wl, flx)
    din_y_array = getDataArray(50, wl, fly)

    dut.reset <= 1

    # await RisingEdge(dut.clk)
    await ClockCycles(dut.clk, 2, rising=True)
    dut.reset <= 0
    pQueue = Queue(7)
    for i in range(50):

        # ! raw data generated
        def np2fp(x):
            return fp(x, signed=True, m=wl-flx, n=flx, str_base=2)

        din_x_fp_array = (*map(np2fp, din_x_array[8*i: 8*i+8]),)
        din_y_fp = np2fp(din_y_array[i])

        # ! raw data combined input
        din_x_v = "".join((*map(str, din_x_fp_array),))
        din_y_v = str(din_y_fp)

        # ! RTL Input
        dut.x <= int(din_x_v, 2)
        dut.y <= int(din_y_v, 2)
        dut.mode <= 2

        # ! raw data output

        dout_p_fp_array = [x*din_y_fp for x in din_x_fp_array]
        dout_p_m = dout_p_fp_array[0].m
        dout_p_n = dout_p_fp_array[0].n

        # ! RTL Output
        await RisingEdge(dut.clk)

        cache = [din_x_fp_array, din_y_fp, dout_p_fp_array]

        if pQueue.full():
            din_x_fp_array_s, din_y_fp_s, dout_p_fp_array_s= pQueue.get()

            dout_v = np.binary_repr(dut.p.value, 32) 
            dout_v_fp_array = [fp("0b"+dout_v[i*4: i*4+4], signed=True, m=dout_p_m, n=dout_p_n, str_base=2) for i in range(8)]

            dut._log.info(dout_v)
            dut._log.info((*map(float, din_x_fp_array_s),))
            dut._log.info(float(din_y_fp_s))
            dut._log.info((*map(float, dout_p_fp_array_s),))
            dut._log.info((*map(float, dout_v_fp_array),))
            dut._log.info((*map(str, dout_p_fp_array_s),))
            dut._log.info((*map(str, dout_v_fp_array),))

            assert dout_v_fp_array == dout_p_fp_array_s

        pQueue.put(cache)

    dut._log.info("Running test end")
