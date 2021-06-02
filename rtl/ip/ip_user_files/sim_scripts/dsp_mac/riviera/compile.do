vlib work
vlib riviera

vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"../../../../dsp_mac/dsp_mac_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

