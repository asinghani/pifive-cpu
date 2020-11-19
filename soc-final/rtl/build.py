import sys
from util import *
from pifive import PiFive

TOP_SOC = PiFive

if __name__ == "__main__":
    if len(sys.argv) > 1:
        verif = (sys.argv[1] == "verif")
    else:
        verif = False

    if verif:
        platform_verif = VerilogPlatform(TOP_SOC.get_io())
        soc_verif = TOP_SOC(platform_verif)
        platform_verif.build(soc_verif, "soc", "litex_top_verif.v", "build")
    else:
        platform = VerilogPlatform(TOP_SOC.get_io())
        soc = TOP_SOC(platform)
        platform.build(soc, "soc", "litex_top.v", "build")
