VERILOG_TOP=top_ulx3s
CONSTRAINTS_FILE=constraints.lpf
CLK_FREQ=20 #Mhz

REMOTE_MACHINE=anish@anish-MBP.local

YOSYS_FLAGS=
NEXTPNR_FLAGS=--85k
ECPPACK_FLAGS=--compress

JSON_FILE=build/synthesis.json
CONFIG_FILE=build/pnr_out.config
BITSTREAM_FILE=build/bitstream.bit

SEARCH_PATH=-not -path "./build/*"
VERILOG_SOURCES=$(shell find . $(SEARCH_PATH) -name "*.v") $(shell find . $(SEARCH_PATH) -name "*.sv")

.PHONY: all
all: ecppack

###############################################
# ULX3S Synthesis, P&R, bitstream
###############################################

.PHONY: build/top_generic.v
build/top_generic.v:
	mkdir -p build
	make -C ../../soc build/top.v
	cp ../../soc/build/top.v build/top_generic.v
	cp ../../soc/build/*.init build/

# Generate PLL
.PHONY: build/pll.v
build/pll.v:
	ecppll -i 25 -o $(CLK_FREQ) -f build/pll.v

# Run sv2v conversion
build/top_ulx3s.v: $(VERILOG_SOURCES) build/pll.v build/top_generic.v
	mkdir -p build
	sv2v $(VERILOG_SOURCES) build/pll.v build/top_generic.v --exclude=assert > build/top_ulx3s.v

# Run synthesis
.PHONY: yosys
yosys: $(JSON_FILE)
$(JSON_FILE): build/top_ulx3s.v
	mkdir -p build
	yosys $(YOSYS_FLAGS) -p 'read_verilog -sv build/top_ulx3s.v; synth_ecp5 -json $(JSON_FILE) -top $(VERILOG_TOP)' > build/yosys.log
	@-grep '^Latch inferred' build/yosys.log && echo '' || true # Check for latches

# Run place-and-route
.PHONY: nextpnr
nextpnr: $(CONFIG_FILE)
$(CONFIG_FILE): $(JSON_FILE) $(CONSTRAINTS_FILE)
	nextpnr-ecp5 $(NEXTPNR_FLAGS) --json $(JSON_FILE) --lpf $(CONSTRAINTS_FILE) --textcfg $(CONFIG_FILE) 2> build/nextpnr.log
	@-grep 'frequency' build/nextpnr.log && echo '' || true # Clock frequency

# Create binary bitstream
.PHONY: ecppack
ecppack: $(BITSTREAM_FILE)
$(BITSTREAM_FILE): $(CONFIG_FILE)
	ecppack $(ECPPACK_FLAGS) $(CONFIG_FILE) $(BITSTREAM_FILE)


###############################################
# ULX3S Flashing
###############################################

# Program the FPGA from the binary bitstream
.PHONY: prog
prog: $(BITSTREAM_FILE)
	ujprog $(BITSTREAM_FILE)

.PHONY: prog-remote
prog-remote: $(BITSTREAM_FILE)
	cat $(BITSTREAM_FILE) | ssh $(REMOTE_MACHINE) 'fujprog'

# Reset the FPGA and clear the config SRAM
.PHONY: reset
reset:
	@echo -e "STATE IDLE;\nSTATE RESET;\nSTATE IDLE;\n\nSIR 8 TDI (C6);\nSDR 8 TDI (00);\nRUNTEST IDLE 2 TCK;\n\nSIR 8 TDI (0e);\nSDR 8 TDI (01);\nRUNTEST IDLE 32 TCK 1.00E-01 SEC;\n" > /tmp/clear-ulx3s.svf;
	ujprog /tmp/clear-ulx3s.svf

.PHONY: reset-remote
reset-remote:
	@ssh $(REMOTE_MACHINE) 'echo -e "STATE IDLE;\nSTATE RESET;\nSTATE IDLE;\n\nSIR 8 TDI (C6);\nSDR 8 TDI (00);\nRUNTEST IDLE 2 TCK;\n\nSIR 8 TDI (0e);\nSDR 8 TDI (01);\nRUNTEST IDLE 32 TCK 1.00E-01 SEC;\n" > /tmp/clear-ulx3s.svf && fujprog /tmp/clear-ulx3s.svf'

###############################################
# Misc utilities
###############################################

.PHONY: clean
clean:
	-rm -r build/
	-rm -r __pycache__/
