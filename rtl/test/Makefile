######################################################################
# @author      : beihai (beihai@$HOSTNAME)
# @file        : Makefile
# @created     : Wednesday Jun 02, 2021 02:24:26 PDT
######################################################################

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

HDL_DIR = $(PWD)/../hdl

VERILOG_SOURCES += $(HDL_DIR)/arithmetic_unit_alt.v
VERILOG_SOURCES += $(HDL_DIR)/dsp_mac.v

TOPLEVEL = arithmetic_unit
MODULE = arithmetic_tb

include $(shell cocotb-config --makefiles)/Makefile.sim
