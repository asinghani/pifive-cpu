PYTHON_SOURCES=$(shell find ./rtl -name "*.py")
VERILOG_SOURCES=$(shell find ./rtl/verilog -name "*.v") $(shell find ./rtl/verilog -name "*.sv")

build/top.v: build/litex_top.v build/cpu_top.v $(VERILOG_SOURCES)
	mkdir -p build
	sv2v build/litex_top.v build/cpu_top.v $(VERILOG_SOURCES) --exclude=assert > build/top.v

build/top_verif.v: build/litex_top_verif.v build/cpu_top_verif.v $(VERILOG_SOURCES)
	mkdir -p build
	sv2v build/litex_top_verif.v build/cpu_top_verif.v $(VERILOG_SOURCES) --exclude=assert --define=VERIFICATION --define=VERILATOR > build/top_verif.v

build/litex_top_verif.v: $(PYTHON_SOURCES)
	mkdir -p build
	python3 rtl/build.py verif

build/litex_top.v: $(PYTHON_SOURCES)
	mkdir -p build
	python3 rtl/build.py main

.PHONY: build/cpu_top.v
build/cpu_top.v:
	mkdir -p build
	make -C ../cpu build/top.v
	cp ../cpu/build/top.v build/cpu_top.v

.PHONY: build/cpu_top_verif.v
build/cpu_top_verif.v:
	mkdir -p build
	make -C ../cpu build/top_verif.v
	cp ../cpu/build/top_verif.v build/cpu_top_verif.v
