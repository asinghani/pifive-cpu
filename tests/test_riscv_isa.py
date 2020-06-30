# Run the RISC-V test suite against the processor
import glob
import os
import sys
from .programtestbench import program_testbench

os.system("make -C ../software/tests/riscv-tests clean")
os.system("make -C ../software/tests/riscv-tests all")

print("Starting tests...")
for test in glob.glob("../software/tests/riscv-tests/build/hex/*-inst.hex")[1:]:
    name = os.path.splitext(os.path.basename(test))[0].replace("-inst", "")
    print("Running {}...".format(name), end=" ", flush=True)
    
    with open(test, "r") as f:
        program = [int(line.strip(), 16) for line in f.readlines() if len(line.strip()) == 8]


    with open(test.replace("-inst", "-data"), "r") as f:
        data = [int(line.strip(), 16) for line in f.readlines() if len(line.strip()) == 8]

        if len(data) == 0:
            data = [0]

    print(len(program))
    print(len(data))

    result = program_testbench("riscv_isa_"+name, program=program, dmem_init=data, max_cycles=1000)

    if result == 1:
        print("Passed", flush=True)
    else:
        print("Failed with error code {}".format(result >> 1))
        print("See software/tests/riscv-tests/build/dump/{}.dump for disassembly".format(name))
        print("See sim_build/{} for waveforms".format("riscv_isa_"+name), flush=True)

        os.system("sed -n '/<test_{}>/,/<fail>/p' ../software/tests/riscv-tests/build/dump/{}.dump".format(result >> 1, name))

        sys.exit(1)

    os.system("rm -r ../sim_build")
