from wbdbgbus import DebugBus
import time
from tqdm import tqdm
import random
from serial import Serial

TEST_PORT = "/dev/tty.usbserial-AM008QCN"

DBG_PORT = "/dev/tty.usbserial-120001"
DBG_BAUD = 115200

CLK = 25*1000*1000
TEST_BAUDS = [1200, 2400, 4800, 9600, 14400, 19200, 38400, 57600, 115200, 234000, 460800]

FIFO_SIZE = 4

STATUS_REG = 0x8000_0100
CONFIG_REG = 0x8000_0104
WRITE_REG  = 0x8000_0108
READ_REG   = 0x8000_010C

NUM_TESTS = 20

with DebugBus(DBG_PORT, DBG_BAUD, fifo_size=FIFO_SIZE, timeout=0) as fpga:
    fpga.reset()

    for baud in TEST_BAUDS:
        with Serial(TEST_PORT, baud, timeout=0) as uart:
            time.sleep(0.1)
            print("Testing {}".format(baud))
            divider = int(round((CLK / baud) / 2))
            fpga.write(CONFIG_REG, divider, verify=False)

            uart.read(10000)
            while fpga.read(STATUS_REG)[0] != 0b0101:
                time.sleep(0.1)
                fpga.read(READ_REG)

            for _ in tqdm(range(NUM_TESTS)):
                data = [random.randint(0, 255) for _ in range(FIFO_SIZE)]
                fpga.write_peripheral(WRITE_REG, data)
                while fpga.read(STATUS_REG)[0] & 0b0100 != 0b0100:
                    time.sleep(0.1)

                data_read = list(uart.read(10000))
                assert data_read == data

                data = [random.randint(0, 255) for _ in range(FIFO_SIZE)]
                uart.write(bytearray(data))
                time.sleep(0.1)
                data_written = []
                while fpga.read(STATUS_REG)[0] & 0b1 != 0b1:
                    data_written.append(fpga.read(READ_REG)[0])

                assert all([x & 0x100 == 0x100 for x in data_written])
                data_written = [x & 0xFF for x in data_written]

                assert data_written == data
