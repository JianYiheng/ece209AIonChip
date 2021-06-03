######################################################################
# @author      : beihai (beihai@$HOSTNAME)
# @file        : Makefile
# @created     : Sunday May 30, 2021 03:15:48 PDT
######################################################################

DIR_HDL = hdl
DIR_OUT = icout
DIR_IP = ip

# TOOLS
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave

# SOURCE
SRC = $(DIR_HDL)/arithmetic_unit.v $(DIR_HDL)/dsp_mac.v
TB = $(DIR_HDL)/arithmetic_unit_tb.v
TBWAVE = $(DIR_OUT)/arithmetic_unit_wave.lxt
COUTPUT = $(DIR_OUT)/check.out
SOUTPUT = $(DIR_OUT)/simulate.out

# TOOL OPTIONS
COFLAGS = -o
SFLAGS = -v
SOFLAGS = -lxt2

all: check simulate display
	echo "Do whole simulation"

check: $(TB) $(SRC)
	$(COMPILER) $(COFLAGS) $(COUTPUT) $(SFLAGS) $(SRC)

simulate: $(SOUTPUT)
	$(SIMULATOR) $(SOUTPUT) $(SOFLAGS)

display: $(TBWAVE)
	$(VIEWER) $(TBWAVE) &

clean:
	rm -f $(TBWAVE) $(COUTPUT) $(SOUTPUT) *.vcd

# make dependencies
$(TBWAVE): $(COUTPUT)
	$(SIMULATOR) $(COUTPUT) $(SOUTPUT)

$(SOUTPUT): $(TB) $(SRC)
	$(COMPILER) $(COFLAGS) $(SOUTPUT) $(EXFLAGS) $(TB) $(SRC)

