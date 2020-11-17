from .testbench import Testbench, asserteq
import os
import random

assert os.getcwd().replace("/", "").endswith("sim_build")

def parse_regs(data):
    binstr = "{0:01024b}".format(data)
    regs = [binstr[(x*32):((x+1)*32)] for x in range(0, 32)]
    regs = [int(x, 2) for x in regs]
    return regs

NOOP = 0x00000033

class ProgramTestbench:

    """
        Initialize the testbench, CPU, and memories
    """
    def __init__(self, test_name, program=[], dmem_init=[], dmem_size=512, custom_params={}):
        brom_data = program + [NOOP] * 8
        brom_size = len(brom_data)

        dmem_data = dmem_init
        dmem_size = max(len(dmem_data) + 8, dmem_size)

        with open("/tmp/brom_data.txt", "w+") as f:
            f.writelines(["{0:036b}\n".format(x) for x in brom_data])

        with open("/tmp/dmem_data.txt", "w+") as f:
            f.writelines(["{0:036b}\n".format(x) for x in dmem_data])

        build_params = {
            "BROM_INIT": "/tmp/brom_data.txt",
            "BROM_SIZE": brom_size,
            "DMEM_INIT": "/tmp/dmem_data.txt",
            "DMEM_SIZE": dmem_size
        }

        self.tb = Testbench("build/top_verif.v", test_name,
                       verilator_args=["-O3", "--top-module", "test_soc", "-Wno-MULTITOP"],
                       params={**build_params, **custom_params},
                       verilog_module_name="test_soc")

        self.dut = self.tb.dut

        self.tb.tick()

    """
        Advance the CPU forward `n` cycles
    """
    def tick(self, n=1):
        for i in range(n):
            self.tb.tick()

    """
        Test the CPU by loading the provided program into bootloader ROM and starting the CPU from the start of the program. Runs until data is written to GPIO output port.
    """
    def run_until_gpio_out(self, reference_registers=None, max_cycles=None):
        cycle = 0
        instr_num = 0
        last_instr = 0
        while True:
            cycle = cycle + 1
            if (max_cycles is not None) and (cycle > max_cycles):
                raise RuntimeError("Exceeded maximum number of cycles")

            self.tb.tick()

            if (self.dut.d_finished_instruction >> 32) == 1:
                if reference_registers is not None:
                    regs = parse_regs(self.dut.d_regs_out)
                    for i in range(32):
                        if regs[i] != reference_registers[instr_num][i]:
                            print("Reg {} incorrect. Expected {}, got {}".format(i, reference_registers[instr_num][i], regs[i]))
                            failed = True

                    if failed:
                        print("Last instruction: {0:08X}".format(last_instr))
                        raise RuntimeError("Registers did not match expected result")

                instr_num = instr_num + 1
                last_instr = dut.d_finished_instruction

            if self.dut.o_gpio_out != 0:
                break

        return self.dut.o_gpio_out, cycle
