RISCV=riscv32-unknown-elf
TEST_SOURCES=$(shell find riscv-tests/isa/rv32ui -type f -name "*.S")

.PHONY: $(TEST_SOURCES)
all:
	mkdir -p build/elf
	mkdir -p build/dump
	mkdir -p build/bin
	mkdir -p build/hex
	python3 build.py $(RISCV) $(TEST_SOURCES)

clean:
	rm -r build

