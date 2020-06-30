RISCV=riscv32-unknown-elf
GCC_ARGS=-march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -T link.ld -Wl,--build-id=none

.PHONY: all
all: build/bootloader-inst.mem build/bootloader-data.mem

build/bootloader-inst.mem: build/bootloader-inst.hex
	python3 ../../scripts/hex2mem.py build/bootloader-inst.hex build/bootloader-inst.mem 4 4

build/bootloader-data.mem: build/bootloader-data.hex
	python3 ../../scripts/hex2mem.py build/bootloader-data.hex build/bootloader-data.mem 4 4

build/bootloader-inst.hex: build/bootloader-inst.bin
	$(RISCV)-bin2hex -w 32 build/bootloader-inst.bin build/bootloader-inst.hex

build/bootloader-data.hex: build/bootloader-data.bin
	$(RISCV)-bin2hex -w 32 build/bootloader-data.bin build/bootloader-data.hex

build/bootloader-inst.bin: build/bootloader.elf
	$(RISCV)-objcopy build/bootloader.elf -O binary --remove-section=.data --remove-section=.bss build/bootloader-inst.bin

build/bootloader-data.bin: build/bootloader.elf
	$(RISCV)-objcopy build/bootloader.elf -O binary --only-section=.data --only-section=.bss build/bootloader-data.bin

build/bootloader.elf: bootloader.S
	mkdir -p build
	$(RISCV)-gcc $(GCC_ARGS) -o build/bootloader.elf bootloader.S
	$(RISCV)-objdump -D -Mnumeric build/bootloader.elf > build/bootloader.dump

clean:
	rm -r build

