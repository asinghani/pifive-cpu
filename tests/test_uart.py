raise ValueError("Legacy test, do not use")

from .testbench import Testbench, asserteq
import os
import random
import string
from .programtestbench import ProgramTestbench
from .uart_sim import UARTSim

CLK_FREQ = 2500000
BAUD = 115200

os.system("make -C ../software/tests/uart-test clean")
os.system("make -C ../software/tests/uart-test all")

def test_uart():
    with open("../software/tests/uart-test/build/uart-test-inst.hex", "r") as f:
        program = [int(line.strip(), 16) for line in f.readlines() if len(line.strip()) == 8]

    cpu = ProgramTestbench("test_uart", program=program, dmem_init=[], custom_params={"CLK_FREQ": CLK_FREQ, "UART_BAUD": BAUD})
    uart = UARTSim(cpu.tb.write_port("i_rx"), cpu.tb.read_port("o_tx"), CLK_FREQ, BAUD)
    cpu.tb.add_tick_callback(uart.update)

    for i in range(150 * 10 * (CLK_FREQ // BAUD) // 20):
        cpu.tick(20)

    recvd = uart.get_recv_len()
    print("Recieved (expected ~128)", recvd)
    assert recvd > 120 and recvd < 200
    uart.get_recv_data(recvd)

    print("Initialization successful")

    for i in range(10):
        test_str = "".join(random.choice(string.ascii_uppercase + string.ascii_lowercase) for _ in range(20))
        expected = test_str.swapcase()

        input_data = [ord(a) for a in test_str]
        expected_out = [ord(a) for a in expected]

        uart.send_all(input_data)

        while uart.get_recv_len() < len(expected_out):
            cpu.tick(20)

        asserteq(uart.get_recv_data(len(expected_out)), expected_out)

    print("Passed")


test_uart()
