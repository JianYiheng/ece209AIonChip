# OPU-PE
This repo is available at https://github.com/JianYiheng/ece209AIonChip/
## Prerequisite
+ cocotb
```bash
pip install cocotb
```
+ icarus verilog
```bash
sudo apt install iverilog
```

## Directory
```
- ece209AIonChip/
    - README.md
    - data/
    - rtl/
        - arithmetic_unit_alt.v
        - pe_unit.v
        - test/
            - arithmetic_tb.py
            - Makefile
            - arithmetic_unit.vcd
```
+ *arithmetic_unit_alt.v*: the module of multiplication unit (MU). 
+ *pe_unit.v*: the module of processing unit (PE).
+ *arithmetic_tb.py*: the cocotb testbench for OPU PE. It would verify the 8-bit, 4-bit, and 2-bit multiplication function.

## Run
```bash
cd rtl/test
make
```
