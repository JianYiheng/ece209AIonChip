import numpy as np
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

def getData():
    # input feature map: 1 * ic * in * im
    data_ifm = np.load("conv_input_wl8_fl5.npy")
    # kernel: ic * y * x * oc
    data_ker = np.load("conv_kernel_wl8_fl7.npy")
    # output feature map: oc * on * om
    data_ofm = np.load("conv_out.npy")

    return data_ifm, data_ker, data_ofm

def ddrInit(data_ifm, data_ker):
    _, ifm_c, ifm_n, ifm_m = data_ifm.shape
    ker_ic, ker_y, ker_x, ker_oc = data_ker.shape

    ofm_n = ofm_m = ifm_n - ker_y + 1
    ofm_c = ker_oc

    ddr_ifm = np.transpose(data_ifm, (0, 2, 3, 1)).flatten()
    ddr_ker = np.transpose(data_ker, (1, 2, 3, 0)).flatten()

    return ddr_ifm, ddr_ker

@cocotb.test()
async def testbench(dut):
    data_ifm, data_ker, data_ofm = getData()
    ddr_ifm, ddr_ker = ddrInit(data_ifm, data_ker)

    ifm_len = len(ddr_ifm)
    ker_len = len(ddr_ker)
    ddr_ofm = np.zeros(32*32*8)

    for blk_ker_n in range(3):
        for blk_ker_m in range(3):
            blk_ker_num = (blk_ker_n*3+blk_ker_m)*8*64
            blk_ker = ddr_ker[blk_ker_num: blk_ker_num+512]
            for blk_ofm_n in range(32):
                for blk_ofm_m in range(32):
                    blk_ifm_num = ((blk_ofm_n+blk_ker_n)*34+(blk_ofm_m+blk_ker_m))*64
                    blk_ofm_num = blk_ofm_n*32*8 + blk_ofm_m*8
                    
                    blk_ifm = np.tile(ddr_ifm[blk_ifm_num: blk_ifm_num+64], 4)
                    cu_Res = ComputationUnit(blk_ifm, blk_ker[:256], blk_ker[256:])
                    ddr_ofm[blk_ofm_num: blk_ofm_num+8] += cu_Res
