import sys
from util import *
from pifive import PiFive

if __name__ == "__main__":
    if len(sys.argv) > 1:
        verif = (sys.argv[1] == "verif")
    else:
        verif = False

    if verif:
        platform_verif = VerilogPlatform(PiFive.get_io())
        soc_verif = PiFive(platform_verif)
        platform_verif.build(soc_verif, "soc", "build_top_verif.v", "build")
    else:
        platform = VerilogPlatform(PiFive.get_io())
        soc = PiFive(platform)
        platform.build(soc, "soc", "build_top.v", "build")
