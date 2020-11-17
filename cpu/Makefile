TARGET=

VERILOG_PATH=-not -path "./build/*" -not -path "./sim_build/*" -not -path "./rtl/legacy/*"
VERILOG_SOURCES=$(shell find . $(VERILOG_PATH) -name "*.v") $(shell find . $(VERILOG_PATH) -name "*.sv")
PYTHON_SOURCES=$(wildcard *.py) $(wildcard **/*.py)

.PHONY: test
test: build/top_verif.v $(PYTHON_SOURCES)
	-rm -r sim_build/
	mkdir -p build
	mkdir -p sim_build
	python3 test.py $(TARGET)

.PHONY: clean
clean:
	-rm -r build/
	-rm -r sim_build/
	-rm -r __pycache__/
	make -C software/bootloader clean

build/top.v: $(VERILOG_SOURCES)
	mkdir -p build
	sv2v $(VERILOG_SOURCES) --exclude=assert > build/top.v

build/top_verif.v: $(VERILOG_SOURCES)
	mkdir -p build
	sv2v $(VERILOG_SOURCES) --exclude=assert --define=VERIFICATION --define=VERILATOR > build/top_verif.v
