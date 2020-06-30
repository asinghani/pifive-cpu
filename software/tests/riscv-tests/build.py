import os, sys
import subprocess

RISCV = sys.argv[1]
GCC = RISCV+"-gcc"
OBJDUMP = RISCV+"-objdump"
OBJCOPY = RISCV+"-objcopy"
BIN2HEX = RISCV+"-bin2hex"

GCC_ARGS = ["-march=rv32i", "-mabi=ilp32", "-static", "-mcmodel=medany", "-fvisibility=hidden", "-nostdlib", "-nostartfiles", "-T", "tvm/link.ld", "-Wl,--build-id=none"]
GCC_INCLUDES = ["-Itvm", "-Iriscv-tests/env", "-Iriscv-tests/isa/macros/scalar"]

sources = sys.argv[2:]

completed = 0
for src in sources:
    name = os.path.splitext(os.path.basename(src))[0]

    if name == "fence_i":
        print("fence_i (skipped)", end=" ", flush=True)
        continue
    else:
        print(name, end=" ", flush=True)

    completed += 1

    elf_file = os.path.join("build/elf", name+".elf")
    dump_file = os.path.join("build/dump", name+".dump")
    bin_inst_file = os.path.join("build/bin", name+"-inst.bin")
    bin_data_file = os.path.join("build/bin", name+"-data.bin")
    hex_inst_file = os.path.join("build/hex", name+"-inst.hex")
    hex_data_file = os.path.join("build/hex", name+"-data.hex")

    subprocess.call(" ".join([GCC] + GCC_ARGS + GCC_INCLUDES + [src, "-o", elf_file]), shell=True)
    subprocess.call(" ".join([OBJDUMP, "-D", "-Mnumeric", elf_file, ">", dump_file]), shell=True)

    subprocess.call(" ".join([OBJCOPY, elf_file, "-O", "binary", "--remove-section=.data", "--remove-section=.bss", bin_inst_file]), shell=True)
    subprocess.call(" ".join([OBJCOPY, elf_file, "-O", "binary", "--only-section=.data", "--only-section=.bss", bin_data_file]), shell=True)

    subprocess.call(" ".join([BIN2HEX, "-w", "32", bin_inst_file, hex_inst_file]), shell=True)
    subprocess.call(" ".join([BIN2HEX, "-w", "32", bin_data_file, hex_data_file]), shell=True)

print()
print("Compiled {} tests".format(completed))
