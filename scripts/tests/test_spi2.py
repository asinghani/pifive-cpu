from wbdbgbus import DebugBus
import time
from tqdm import tqdm

DBG_PORT = "/dev/tty.usbserial-120001"
DBG_BAUD = 115200

CFG_REG = 0x8800_0800
SPI_CFG_REG = 0x8000_3000
SPI_REG = 0x8000_3004

with DebugBus(DBG_PORT, DBG_BAUD, fifo_size=1, timeout=0) as fpga:
    fpga.reset()

    # Reset device
    fpga.write(CFG_REG, 0b010)
    fpga.write(CFG_REG, 0b011)

    # Start device
    fpga.write(CFG_REG, 0b001)
    fpga.write(SPI_REG, 0xAE)
    while fpga.read(SPI_CFG_REG)[0] & 0x40000 != 0x40000: pass
    fpga.write(SPI_REG, 0xAF)
    while fpga.read(SPI_CFG_REG)[0] & 0x40000 != 0x40000: pass

    # Enable fill
    fpga.write(SPI_REG, 0x26)
    fpga.write(SPI_REG, 0x01)

    # Draw on device
    fpga.write(SPI_REG, 0x22)
    fpga.write(SPI_REG, 0)
    fpga.write(SPI_REG, 0)
    fpga.write(SPI_REG, 64)
    fpga.write(SPI_REG, 96)
    fpga.write(SPI_REG, 0xFF)
    fpga.write(SPI_REG, 0xFF)
    fpga.write(SPI_REG, 0xFF)
    fpga.write(SPI_REG, 0xFF)
    fpga.write(SPI_REG, 0xFF)
    fpga.write(SPI_REG, 0xFF)
