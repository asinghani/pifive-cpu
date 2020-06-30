# Convert a 32-bit wide hex file to a binary file for loading with readmemb.
import sys

if len(sys.argv) < 3:
    print("Usage: hex2mem.py <input hex file> <output mem file> [# padding bits per line] [# padding words at end]")

padding_bits = 0
padding_words = 0
if len(sys.argv) >= 4:
    padding_bits = int(sys.argv[3])
if len(sys.argv) >= 5:
    padding_words = int(sys.argv[4])


with open(sys.argv[1], "r") as f:
    data = ["{0:032b}".format(int(line.strip(), 16)) for line in f.readlines() if len(line.strip()) == 8] + (["0" * 32] * padding_words)

with open(sys.argv[2], "w+") as f:
    for word in data:
        f.write("{}{}\n".format("0" * padding_bits, word))

