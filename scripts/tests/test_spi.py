from wbdbgbus import DebugBus
import time
from tqdm import tqdm

DBG_PORT = "/dev/tty.usbserial-120001"
DBG_BAUD = 115200

MOSI = 0x00
CLK  = 0x08
DC   = 0x0C
RST  = 0x10
CS   = 0x14

GPIO_BASE = 0x8100_0000

SPI_CFG_REG = 0x8000_3000
SPI_REG     = 0x8000_3004

DRAW = True

with DebugBus(DBG_PORT, DBG_BAUD, fifo_size=1, timeout=0) as fpga:
    fpga.reset()
    
    # Set up SPI (assuming SPI is mode 1 for GPIO)
    fpga.write(GPIO_BASE+MOSI, 0b0_1_0001_00_00000_000)
    fpga.write(GPIO_BASE+CLK,  0b0_1_0001_00_00000_000)

    # Set DC to 0
    fpga.write(GPIO_BASE+DC, 0b0_1_0000_00_00000_100)

    # Set CS to 0
    fpga.write(GPIO_BASE+CS, 0b0_1_0000_00_00000_100)

    # Set RST to 0
    fpga.write(GPIO_BASE+RST, 0b0_1_0000_00_00000_100)

    time.sleep(0.1)

    # Set RST to 1
    fpga.write(GPIO_BASE+RST, 0b0_1_0000_00_00000_110)

    # Start device
    fpga.write(SPI_REG, 0xAE)
    while fpga.read(SPI_CFG_REG)[0] & 0x40000 != 0x40000: pass
    fpga.write(SPI_REG, 0xAF)
    while fpga.read(SPI_CFG_REG)[0] & 0x40000 != 0x40000: pass

    # Set DC to 1
    fpga.write(GPIO_BASE+DC, 0b0_1_0000_00_00000_110)

    # Write data
    if DRAW:
        for i in tqdm(range(64)):
            for j in tqdm(range(96)):
                pix = (((i >> 1) & 0b11111) << 11) | (((j >> 1) & 0b111111) << 5);
                fpga.write(SPI_REG, pix >> 8)
                fpga.write(SPI_REG, pix & 0xFF)
