RISCV?=riscv32-unknown-elf-
GCC_ARGS=-march=rv32i -mabi=ilp32 -ffreestanding -mstrict-align -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -T link.ld -Wl,--build-id=none

PROJ=servo
SOURCES=$(PROJ).c start.S $(shell find ../lib -type f -name "*.c")
INCLUDE_DIRS=-I../lib/ -Ibuild

.PHONY: all
all: build/$(PROJ)-inst.mem build/$(PROJ)-data.mem

build/$(PROJ)-inst.mem: build/$(PROJ)-inst.hex
	python3 ../../scripts/hex2mem.py build/$(PROJ)-inst.hex build/$(PROJ)-inst.mem 4 4

build/$(PROJ)-data.mem: build/$(PROJ)-data.hex
	python3 ../../scripts/hex2mem.py build/$(PROJ)-data.hex build/$(PROJ)-data.mem 4 4

build/$(PROJ)-inst.hex: build/$(PROJ)-inst.bin
	$(RISCV)bin2hex -w 32 build/$(PROJ)-inst.bin build/$(PROJ)-inst.hex

build/$(PROJ)-data.hex: build/$(PROJ)-data.bin
	$(RISCV)bin2hex -w 32 build/$(PROJ)-data.bin build/$(PROJ)-data.hex

build/$(PROJ)-inst.bin: build/$(PROJ).elf
	$(RISCV)objcopy build/$(PROJ).elf -O binary --remove-section=.data --remove-section=.bss --remove-section=.sdata build/$(PROJ)-inst.bin

build/$(PROJ)-data.bin: build/$(PROJ).elf
	$(RISCV)objcopy build/$(PROJ).elf -O binary --only-section=.data --only-section=.bss --only-section=.sdata build/$(PROJ)-data.bin

build/$(PROJ).elf: $(SOURCES) build/platform.h build/platform_init.h build/platform.ld
	mkdir -p build
	$(RISCV)gcc $(GCC_ARGS) -o build/$(PROJ).elf $(INCLUDE_DIRS) $(SOURCES)
	$(RISCV)objdump -D build/$(PROJ).elf > build/$(PROJ).dump

.PHONY: build/platform.h
build/platform.h:
	mkdir -p build
	make -C ../../soc/ build/build_top.v
	cp ../../soc/build/platform.h build/platform.h

.PHONY: build/platform_init.h
build/platform_init.h:
	mkdir -p build
	make -C ../../soc/ build/build_top.v
	cp ../../soc/build/platform_init.h build/platform_init.h

.PHONY: build/platform.ld
build/platform.ld:
	mkdir -p build
	make -C ../../soc/ build/build_top.v
	cp ../../soc/build/platform.ld build/platform.ld

.PHONY: test
test: upload
	python3 -m serial --eol LF $(PORT) 115200

.PHONY: upload
upload: build/$(PROJ)-inst.hex build/$(PROJ)-data.hex
ifeq ($(PORT),)
	echo "Serial port must be specified in the PORT variable"
	exit 1
endif
	python3 ../../scripts/upload.py $(PORT) build/$(PROJ)-inst.hex build/$(PROJ)-data.hex 0xC0000000 0xD0000000 0xC0000000 115200

clean:
	rm -r build

