# Upload program (inst and data hex files) to bootloader over UART
import sys
from serial import Serial
import time

if len(sys.argv) < 4:
    print("Usage: program.py <serial port> <instruction hex file> <data hex file> [baud = 115200]")
    sys.exit(-1)

serial_port = sys.argv[1]
inst_file = sys.argv[2]
data_file = sys.argv[3]

if len(sys.argv) > 4:
    baud = int(sys.argv[4])
else:
    baud = 115200

# Convert 32-bit word to 4 bytes in little-endian order
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

prog_checksum = sum(prog) & 255
prog_len = word_to_bytes(len(prog))

data = []
with open(data_file, "r") as f:
    for line in f.readlines():
        line = line.strip()
        data += word_to_bytes(int(line, 16))

data_checksum = sum(data) & 255
data_len = word_to_bytes(len(data))

upload_maindata = prog_len + prog + data_len + data
upload_checksums = [prog_checksum, data_checksum]

print("Opening serial port...")
port = Serial(serial_port, baud, timeout=0, dsrdtr=False)

print("Resetting...")
port.dtr = 1
time.sleep(0.5)
port.dtr = 0

print("Uploading...")
for x in upload_maindata:
    port.write(bytearray([x]))
    time.sleep(0.005)
time.sleep(0.3)

data = port.read(10000) # Read as much data is available

if list(set(data)) != [6]: # Ensure only acknowledgements
    print("Invalid acknowledgement received")
    sys.exit(1)

# Send checksums (this will trigger the program-start immediately)
print("Verifying checksums...")
port.write(bytearray(upload_checksums))
time.sleep(0.015)

data = []
while len(data) == 0:
    data = port.read(10000) # Read as much data is available

resp = data[0]

port.close()

if resp == 0x13:
    print("Successful upload!")
    sys.exit(0)
else:
    print("Upload failed with error code 0x{0:02X}".format(resp))
    sys.exit(1)
