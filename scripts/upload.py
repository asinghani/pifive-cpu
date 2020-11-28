#!/usr/bin/env python3
# Upload program (inst and data hex files) to bootloader over UART
import sys
from serial import Serial
import time
from tqdm import tqdm

if len(sys.argv) < 6:
    print(f"Usage: {sys.argv[0]} <serial port> <instruction hex file> <data hex file> <instruction base address> <data base address> [init address = instruction base address] [baud = 115200]")
    sys.exit(-1)

serial_port = sys.argv[1]
inst_file = sys.argv[2]
data_file = sys.argv[3]
inst_base = sys.argv[4]
data_base = sys.argv[5]

if len(sys.argv) > 6:
    init = int(sys.argv[6], 0)
else:
    init = inst_base

if len(sys.argv) > 7:
    baud = int(sys.argv[7])
else:
    baud = 115200

# Convert 32-bit word to little-endian bytes
def word_to_bytes(word):
    return [(word & 0x000000FF) >> 0,
            (word & 0x0000FF00) >> 8,
            (word & 0x00FF0000) >> 16,
            (word & 0xFF000000) >> 24]

prog = []
with open(inst_file, "r") as f:
    for line in f.readlines():
        line = line.strip()
        prog += word_to_bytes(int(line, 16))

prog_checksum = sum(prog) & 0xFF
prog_base = word_to_bytes(int(inst_base, 0))
prog_len = word_to_bytes(len(prog))

data = []
with open(data_file, "r") as f:
    for line in f.readlines():
        line = line.strip()
        data += word_to_bytes(int(line, 16))

data_checksum = sum(data) & 0xFF
data_base = word_to_bytes(int(data_base, 0))
data_len = word_to_bytes(len(data))

upload_maindata = prog_base + prog_len + data_base + data_len + prog + data
num_acks = (len(prog) // 16) + (len(data) // 16)
upload_checksums = [prog_checksum, data_checksum]
init_addr = word_to_bytes(init)

print("Opening serial port...")
port = Serial(serial_port, baud, timeout=0, dsrdtr=False)

data = port.read(10000) # Read as much data is available

print("Resetting...")
port.dtr = 1
time.sleep(0.5)
port.dtr = 0
time.sleep(0.5) # Wait to enter bootloader

data = port.read(10000) # Read as much data is available

if data != [0x5]:
    print("Failed to reset automatically. Please manually reset the microcontroller.")
    data = b""
    while len(data) == 0:
        time.sleep(0.1)
        data = port.read(10000)

    print("Reset detected")
    time.sleep(0.5)
    data += port.read(10000)

    if data != b"\x05":
        print("Reset failed. Please ensure the serial port is connected properly and try again")
        sys.exit(1)

print("Uploading...")
for x in tqdm(upload_maindata):
    port.write(bytearray([x]))
    time.sleep(0.001)
time.sleep(0.3)

data = port.read(10000) # Read as much data is available

if set(data) != {0x6}:
    print("Invalid acknowledgement received")
    sys.exit(1)

if abs(len(data) - num_acks) > 2:
    print("Acknowledgements not received")
    sys.exit(1)

# Send checksums (this will trigger the program-start immediately)
print("Verifying checksums...")
port.write(bytearray(upload_checksums))
time.sleep(0.015)

data = []
while len(data) == 0:
    data = port.read(10000) # Read as much data is available

resp = data[0]

if resp == 0x13:
    print("Successful upload! Starting program...")
    port.write(bytearray(init_addr))
    port.close()
    sys.exit(0)
else:
    print("Upload failed with error code 0x{0:02X}".format(resp))
    port.close()
    sys.exit(1)
