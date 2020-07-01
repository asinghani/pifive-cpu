RISCV=riscv32-unknown-elf
GCC_ARGS=-march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -T link.ld -Wl,--build-id=none

PROJ=blinky
SOURCES=$(PROJ).c start.S

.PHONY: all
all: build/$(PROJ)-inst.mem build/$(PROJ)-data.mem

build/$(PROJ)-inst.mem: build/$(PROJ)-inst.hex
	python3 ../../scripts/hex2mem.py build/$(PROJ)-inst.hex build/$(PROJ)-inst.mem 4 4

build/$(PROJ)-data.mem: build/$(PROJ)-data.hex
	python3 ../../scripts/hex2mem.py build/$(PROJ)-data.hex build/$(PROJ)-data.mem 4 4

build/$(PROJ)-inst.hex: build/$(PROJ)-inst.bin
	$(RISCV)-bin2hex -w 32 build/$(PROJ)-inst.bin build/$(PROJ)-inst.hex

build/$(PROJ)-data.hex: build/$(PROJ)-data.bin
	$(RISCV)-bin2hex -w 32 build/$(PROJ)-data.bin build/$(PROJ)-data.hex

build/$(PROJ)-inst.bin: build/$(PROJ).elf
	$(RISCV)-objcopy build/$(PROJ).elf -O binary --remove-section=.data --remove-section=.bss --remove-section=.sdata build/$(PROJ)-inst.bin

build/$(PROJ)-data.bin: build/$(PROJ).elf
	$(RISCV)-objcopy build/$(PROJ).elf -O binary --only-section=.data --only-section=.bss --only-section=.sdata build/$(PROJ)-data.bin

build/$(PROJ).elf: $(SOURCES)
	mkdir -p build
	$(RISCV)-gcc $(GCC_ARGS) -o build/$(PROJ).elf $(SOURCES)
	$(RISCV)-objdump -D -Mnumeric build/$(PROJ).elf > build/$(PROJ).dump

clean:
	rm -r build

