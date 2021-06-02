vlib work
vlib activehdl

vlib activehdl/xil_defaultlib

vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"../../../../dsp_mac/dsp_mac_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

