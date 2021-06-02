// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2.2 (lin64) Build 2348494 Mon Oct  1 18:25:39 MDT 2018
// Date        : Sun May 30 04:36:34 2021
// Host        : RedCoast running 64-bit Ubuntu 20.04.2 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/beihai/Documents/ece209_lei/209-Project/OptionC/rtl/ip/dsp_mac/dsp_mac_stub.v
// Design      : dsp_mac
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx485tffg1157-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "xbip_dsp48_macro_v3_0_16,Vivado 2018.2.2" *)
module dsp_mac(CLK, SCLR, A, B, C, D, P)
/* synthesis syn_black_box black_box_pad_pin="CLK,SCLR,A[24:0],B[17:0],C[47:0],D[24:0],P[47:0]" */;
  input CLK;
  input SCLR;
  input [24:0]A;
  input [17:0]B;
  input [47:0]C;
  input [24:0]D;
  output [47:0]P;
endmodule