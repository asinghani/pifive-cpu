BIG_PRIME = 8078431
OFFSET = 48918939481
with open("cache_test.txt", "w+") as f:
    for i in range(4096):
        f.write("{:08x}\n".format((OFFSET + i * BIG_PRIME) & 0xFFFFFFFF))