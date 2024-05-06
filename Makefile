.PHONY: all
all: ALU EX FU ID IF REGFILE MEM WB DMEM.mem IMEM.mem
	ghdl -a --std=08 TOP.vhd
	ghdl -e --std=08 CPU

.PHONY: run
run: all
	ghdl -r --std=08 CPU --vcd=cpu.vcd
	gtkwave cpu.vcd

.PHONY: util
util:
	ghdl -a --std=08 util.vhd

.PHONY: ROM
ROM: util
	ghdl -a --std=08 ROM.vhd

.PHONY: RAM
RAM: util
	ghdl -a --std=08 RAM.vhd

.PHONY: REG
REG:
	ghdl -a --std=08 REG.vhd
	
.PHONY: ALU
ALU:
	ghdl -a --std=08 ALU.vhd

.PHONY: EX
EX:
	ghdl -a --std=08 EX.vhd

.PHONY: FU
FU:
	ghdl -a --std=08 FU.vhd

.PHONY: ID
ID:
	ghdl -a --std=08 ID.vhd

.PHONY: IF
IF: ROM
	ghdl -a --std=08 IF.vhd

.PHONY: REGFILE
REGFILE: REG
	ghdl -a --std=08 REGFILE.vhd

.PHONY: MEM
MEM: ROM RAM
	ghdl -a --std=08 MEM.vhd

.PHONY: WB
WB:
	ghdl -a --std=08 WB.vhd
