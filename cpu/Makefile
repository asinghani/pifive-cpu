TARGET=

VERILOG_PATH=-not -path "./build/*" -not -path "./sim_build/*" -not -path "./rtl/legacy/*"
VERILOG_TEST_SOURCES=$(shell find . $(VERILOG_PATH) -name "*.v") $(shell find . $(VERILOG_PATH) -name "*.sv")
PYTHON_SOURCES=$(wildcard *.py) $(wildcard **/*.py)

.PHONY: test
test: $(VERILOG_TEST_SOURCES) $(PYTHON_SOURCES)
	-rm -r sim_build/
	mkdir -p build
	mkdir -p sim_build
	sv2v $(VERILOG_TEST_SOURCES) --exclude=assert --define=VERIFICATION --define=VERILATOR > build/top.v
	python3 test.py $(TARGET)

.PHONY: clean
clean:
	-rm -r build/
	-rm -r sim_build/
	-rm -r __pycache__/
	make -C software/bootloader clean
