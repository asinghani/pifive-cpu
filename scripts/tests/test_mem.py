from wbdbgbus import DebugBus
import time
from tqdm import tqdm
import random
from serial import Serial

DBG_PORT = "/dev/tty.usbserial-120001"
DBG_BAUD = 115200

MEM_RD_BASE = 0xA000_0000
MEM_WR_BASE = 0xC000_0000
MEM_SIZE = 8 * 1024 * 1024 # In bytes

READ_WR_SIDE = True

GAPS = range(1, 20+1)
GAPS_BYTE = [4*x for x in GAPS]

def regen_hash():
    global HASH_PARAM
    HASH_PARAM = str(hex(random.randint(1e9, 1e10)))

regen_hash()

with DebugBus(DBG_PORT, DBG_BAUD, fifo_size=1, timeout=0) as fpga:
    fpga.reset()

    print("Test gapped access")
    for gap in tqdm(GAPS_BYTE):
        for i in range(20):
            addr = i * gap
            if addr >= MEM_SIZE:
                break

            val = hash(HASH_PARAM + str(i)) & 0xFFFF_FFFF

            fpga.write(MEM_WR_BASE+addr, val)

            #assert fpga.read(MEM_RD_BASE+addr)[0] == val

            if READ_WR_SIDE:
                assert fpga.read(MEM_WR_BASE+addr)[0] == val

        r = list(range(20))
        for i in r:
            addr = i * gap
            if addr >= MEM_SIZE:
                break

            val = hash(HASH_PARAM + str(i)) & 0xFFFF_FFFF

            assert fpga.read(MEM_RD_BASE+addr)[0] == val

            if READ_WR_SIDE:
                assert fpga.read(MEM_WR_BASE+addr)[0] == val

        random.shuffle(r)
        for i in r:
            addr = i * gap
            if addr >= MEM_SIZE:
                break

            val = hash(HASH_PARAM + str(i)) & 0xFFFF_FFFF

            assert fpga.read(MEM_RD_BASE+addr)[0] == val

            if READ_WR_SIDE:
                assert fpga.read(MEM_WR_BASE+addr)[0] == val

