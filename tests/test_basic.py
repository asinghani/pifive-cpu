from .testbench import Testbench, asserteq
import os
import random

assert os.getcwd().replace("/", "").endswith("sim_build")

def parse_regs(data):
    binstr = "{0:01024b}".format(data)
    regs = [binstr[(x*32):((x+1)*32)] for x in range(0, 32)]
    regs = [int(x, 2) for x in regs]

    return regs

def test_basic():
    NOOP = 0x00000033
    prog_hex = """
0x14D00093
0x40000137
0x800002B7
0x04400313
0x00112223
0x00410183
0x00510203
0x00628023
0x006281A3
"""
    brom_data = [int(x, 0) for x in prog_hex.split("\n") if len(x) == 10]
    brom_data = brom_data + [NOOP, NOOP, NOOP]
    with open("/tmp/machinecode.txt", "w+") as f:
        for i in brom_data:
            f.write("{0:036b}\n".format(i))

    tb = Testbench("build/top.v", "test_basic",
                   verilator_args=["-O3", "--top-module", "cpu",
                                   "-DVERIFICATION"],
                   params={"BROM_INIT": "/tmp/machinecode.txt",
                           "BROM_SIZE": len(brom_data) + 32}, 
                   verilog_module_name="cpu")
    dut = tb.dut

    for i in range(18):
        tb.tick()
        tb.eval()
        print(parse_regs(dut.d_regs_out))

    print(hex(dut.o_gpio_out))


test_basic()
