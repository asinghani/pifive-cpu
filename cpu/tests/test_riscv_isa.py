# Run the RISC-V test suite against the processor
import glob
import os
import sys
from .programtestbench import ProgramTestbench

os.system("make -C ../../software/tests/riscv-tests clean")
os.system("make -C ../../software/tests/riscv-tests all")

NOOP = 0
SKIP = []

tests = []
max_prog_len = 0
max_data_len = 0
for test in glob.glob("../../software/tests/riscv-tests/build/hex/*-inst.hex"):
    name = os.path.splitext(os.path.basename(test))[0].replace("-inst", "")

    if name in SKIP:
        continue

    with open(test, "r") as f:
        program = [int(line.strip(), 16) for line in f.readlines() if len(line.strip()) == 8]
        max_prog_len = max(max_prog_len, len(program))

    with open(test.replace("-inst", "-data"), "r") as f:
        data = [int(line.strip(), 16) for line in f.readlines() if len(line.strip()) == 8]
        max_data_len = max(max_data_len, len(data))

    tests.append([name, program, data])

# Always use largest memory size - hacky workaround to avoid needing to do verilator rebuild every time
for test in tests:
    test[1] = test[1] + [NOOP] * (max_prog_len - len(test[1]))
    test[2] = test[2] + [0] * (max_data_len - len(test[2]))

print("Starting tests...")
for name, program, data in tests:
    print("Running {}...".format(name), end=" ", flush=True)

    tb = ProgramTestbench("riscv_isa_"+name, program=program, dmem_init=data)
    result, cycles = tb.run_until_gpio_out(max_cycles=10000)

    if result == 1:
        print("Passed ({} cycles)".format(cycles), flush=True)
    else:
        print("Failed with error code {}".format(result >> 1))
        print("See software/tests/riscv-tests/build/dump/{}.dump for disassembly".format(name))
        print("See sim_build/{}.vcd for waveforms".format("riscv_isa_"+name), flush=True)

        os.system("sed -n '/<test_{}>/,/<fail>/p' ../../software/tests/riscv-tests/build/dump/{}.dump".format(result >> 1, name))

        sys.exit(1)

print("All tests passed!")
