RISCV=riscv32-unknown-elf
GCC_ARGS=-march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -T link.ld -Wl,--build-id=none

.PHONY: all
all: build/uart-test-inst.mem

build/uart-test-inst.mem: build/uart-test-inst.hex
	python3 ../../../scripts/hex2mem.py build/uart-test-inst.hex build/uart-test-inst.mem 4 4

build/uart-test-inst.hex: build/uart-test-inst.bin
	$(RISCV)-bin2hex -w 32 build/uart-test-inst.bin build/uart-test-inst.hex

build/uart-test-inst.bin: build/uart-test.elf
	$(RISCV)-objcopy build/uart-test.elf -O binary --remove-section=.data --remove-section=.bss build/uart-test-inst.bin

build/uart-test.elf: uart-test.S
	mkdir -p build
	$(RISCV)-gcc $(GCC_ARGS) -o build/uart-test.elf uart-test.S
	$(RISCV)-objdump -D -Mnumeric build/uart-test.elf > build/uart-test.dump

clean:
	rm -r build

