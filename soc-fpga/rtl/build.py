import sys
from util import *
from soc import SoC

if __name__ == "__main__":
    if len(sys.argv) > 1:
        verif = (sys.argv[1] == "verif")
    else:
        verif = False

    if verif:
        platform_verif = VerilogPlatform(SoC.get_io())
        soc_verif = SoC(platform_verif)
        platform_verif.build(soc_verif, "soc", "litex_top_verif.v", "build")
    else:
        platform = VerilogPlatform(SoC.get_io())
        soc = SoC(platform)
        platform.build(soc, "soc", "litex_top.v", "build")
