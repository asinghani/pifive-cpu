from wbdbgbus import DebugBus
import time
from tqdm import tqdm
import random

TEST_PORT = "/dev/tty.usbserial-AM008QCN"

DBG_PORT = "/dev/tty.usbserial-120001"
DBG_BAUD = 115200

CLK = 25*1000*1000

SECONDS_PER_CLK = 1.0 / CLK

CTR_REG    = 0x8000_2000
RELOAD_REG = 0x8000_2004
LOAD_REG   = 0x8000_2008
ENABLE_REG = 0x8000_200C
TRIG_REG   = 0x8000_2010

NUM_TESTS = 5
CHECKS_PER_TEST = 3 # for error

with DebugBus(DBG_PORT, DBG_BAUD, fifo_size=1, timeout=0) as fpga:
    fpga.reset()

    total_error = 0.0
    for _ in range(NUM_TESTS):
        fpga.write(ENABLE_REG, 0)
        print("Test countdown")
        ticks = random.randint(1*CLK, 3*CLK)
        secs = SECONDS_PER_CLK * ticks
        fpga.write(LOAD_REG, ticks)
        fpga.write(RELOAD_REG, 0)
        fpga.write(ENABLE_REG, 1)
        time.sleep(secs + 0.05)
        assert fpga.read(TRIG_REG)[0] == 1
        fpga.write(TRIG_REG, 0)
        assert fpga.read(TRIG_REG)[0] == 0
        time.sleep(2 * secs)
        assert fpga.read(TRIG_REG)[0] == 0

        print("Test time precision")
        fpga.write(LOAD_REG, 20*CLK)
        fpga.write(RELOAD_REG, 0)
        start = time.time()
        fpga.write(ENABLE_REG, 1)
        time.sleep(random.randrange(0.0, 2.0))
        total_error += abs(((20*CLK - fpga.read(CTR_REG)[0]) * SECONDS_PER_CLK) - (time.time() - start))
        time.sleep(random.randrange(0.0, 2.0))
        total_error += abs(((20*CLK - fpga.read(CTR_REG)[0]) * SECONDS_PER_CLK) - (time.time() - start))
        time.sleep(random.randrange(0.0, 2.0))
        total_error += abs(((20*CLK - fpga.read(CTR_REG)[0]) * SECONDS_PER_CLK) - (time.time() - start))
        assert fpga.read(TRIG_REG)[0] == 0
        fpga.write(ENABLE_REG, 0)
        assert fpga.read(CTR_REG)[0] == 0

        print("Test reloading")
        ticks1 = random.randint(1*CLK, int(1.5*CLK))
        secs1 = SECONDS_PER_CLK * ticks1
        ticks2 = random.randint(2*CLK, 3*CLK)
        secs2 = SECONDS_PER_CLK * ticks2
        fpga.write(LOAD_REG, ticks1)
        fpga.write(RELOAD_REG, ticks2)
        fpga.write(ENABLE_REG, 1)

        time.sleep(secs1 + 0.05)
        assert fpga.read(TRIG_REG)[0] == 1
        fpga.write(TRIG_REG, 0)
        assert fpga.read(TRIG_REG)[0] == 0

        time.sleep(secs2 + 0.05)
        assert fpga.read(TRIG_REG)[0] == 1
        fpga.write(TRIG_REG, 0)
        assert fpga.read(TRIG_REG)[0] == 0

        time.sleep(secs2 + 0.05)
        assert fpga.read(TRIG_REG)[0] == 1
        fpga.write(TRIG_REG, 0)
        assert fpga.read(TRIG_REG)[0] == 0
        
    print("Avg error = {:.2f}s".format(total_error / CHECKS_PER_TEST / NUM_TESTS))
