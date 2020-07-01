import os
import sys

sys.path.append(".")

WIDTH = 80

TEST_DIR = "sim_build"
TEST_PACKAGE = "tests"

TESTS = ["test_riscv_isa", "test_uart"]

if len(sys.argv) > 1:
    targets = sys.argv[1:]
else:
    targets = None

os.makedirs(TEST_DIR, exist_ok = True)
os.chdir(TEST_DIR)

def header(msg):
    print(WIDTH * "#")
    msg = msg if len(msg) < (WIDTH - 2) else msg[0:(WIDTH - 2)]
    left_pad = ((WIDTH - 2) - len(msg)) // 2
    right_pad = ((WIDTH - 2) - len(msg) - left_pad)
    print("#{}{}{}#".format(" " * left_pad, msg, " " * right_pad))
    print(WIDTH * "#")
    print()


# Run tests
for test in TESTS:
    if (targets is None) or (test in targets):
        header("Starting " + test)
        __import__("{}.{}".format(TEST_PACKAGE, test))
        header("Passed " + test)
