from wbdbgbus import DebugBus
import time
from tqdm import tqdm
import random
from serial import Serial

DBG_PORT = "/dev/tty.usbserial-AM008QCN"
DBG_BAUD = 115200

STATUS_REG = 0x4000_8000
ADDR_REG   = 0x4000_8004
WRITE_REG  = 0x4000_8008
READ_REG   = 0x4000_800C
ENABLE_REG = 0x4000_8010

data = [0] * 1024

ERROR_VALUE = 4 # 0x10

with DebugBus(DBG_PORT, DBG_BAUD, fifo_size=1, timeout=0) as fpga:
    fpga.reset()
    fpga.write(ENABLE_REG, 0xABAB12)

    while True:
        status = fpga.read(STATUS_REG)[0]
        assert status & 0b11 != 0b11

        if status & 0b10 == 0b10: # Write
            ind = (fpga.read(ADDR_REG)[0] >> 2) % len(data)
            dat = fpga.read(WRITE_REG)[0]
            if ind == ERROR_VALUE:
                fpga.write(STATUS_REG, 0x200)
                print("Errored on write to 0x{:08x}".format(ind))
            else:
                fpga.write(STATUS_REG, 0x100)
                data[ind] = dat
                print("Wrote 0x{:08x} to 0x{:08x}".format(dat, ind))

        if status & 0b01 == 0b01: # Read
            ind = (fpga.read(ADDR_REG)[0] >> 2) % len(data)
            if ind == ERROR_VALUE:
                fpga.write(STATUS_REG, 0x200)
                print("Errored on read from 0x{:08x}".format(ind))
            else:
                fpga.write(READ_REG, data[ind])
                fpga.write(STATUS_REG, 0x100)
                print("Read 0x{:08x} from 0x{:08x}".format(data[ind], ind))


