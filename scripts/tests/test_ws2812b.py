from wbdbgbus import DebugBus
import colorsys
import math
import time

SIZE = 256
REPEAT = 1
gap = 1.0 / (SIZE / REPEAT)
CORRECT = True
B = 0.4
BRIGHTNESS = B if CORRECT else B/2

def gammacorrect(x):
    GAMMA = 2.8
    if CORRECT:
        return int(255.0 * ((float(x) / 255.0) ** GAMMA) + 0.5)
    else:
        return int(x)

def colors():
    arr = []
    for i in range(SIZE):
        r, g, b = [gammacorrect(int(255 * x)) for x in colorsys.hsv_to_rgb(i * gap, 1.0, BRIGHTNESS)]

        print(r, g, b)
        print(bin(r), bin((r >> 3) << 10))

        #v = ((r >> 3) << 10) | ((g >> 2) << 10) | (b >> 3)
        #print(v, hex(v), bin(v))
        #arr.append((v << 16) | v)
        arr.append((r << 16) | (g << 8) | b)

    return arr

data = colors()

with DebugBus("/dev/tty.usbserial-120001", 115200, fifo_size=2, timeout=0) as fpga:

    print("Starting write")
    for i, x in enumerate(data):
        fpga.write(4*i, x)
    print("Done with write")

    print("Starting read")
    for i, x in enumerate(data):
        assert fpga.read(4*i)[0] == x
    print("Done with read")

    print("Starting display")
    fpga.write(0x5000, 1)
    print("Done with display")

    time.sleep(1)
