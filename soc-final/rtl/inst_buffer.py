from migen import *
import math
from litex.soc.interconnect import wishbone as wb

# Instruction buffer - primarily for debug use
# Size specified in # of words
class InstBuffer(Module):
    def __init__(self, size=32, bus=None, debug_bus=None):
        self.irq = Signal()

        if bus is None:
            self.bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus = bus

        if debug_bus is None:
            self.debug_bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.debug_bus = debug_bus

        # TODO ignore high bits instead of clipping actual value
        mem = Array(Signal(32, reset_less=True) for _ in range(size))

        # Main bus (read-only port)
        self.sync += [
            self.bus.ack.eq(0),
            self.bus.err.eq(0),
            self.bus.dat_r.eq(mem[(self.bus.adr >> 2)]),
            If(self.bus.stb & self.bus.cyc & ~self.bus.ack,
               self.bus.ack.eq(1))
        ]

        # Debug bus (read/write port)
        self.sync += [
            self.debug_bus.ack.eq(0),
            self.debug_bus.err.eq(0),
            self.debug_bus.dat_r.eq(mem[(self.debug_bus.adr >> 2)]),
            If(self.debug_bus.stb & self.debug_bus.cyc & ~self.debug_bus.ack,
               self.debug_bus.ack.eq(1),
               If(self.debug_bus.we & self.debug_bus.sel[0], mem[(self.debug_bus.adr >> 2)][0:8].eq(self.debug_bus.dat_w[0:8])),
               If(self.debug_bus.we & self.debug_bus.sel[1], mem[(self.debug_bus.adr >> 2)][8:16].eq(self.debug_bus.dat_w[8:16])),
               If(self.debug_bus.we & self.debug_bus.sel[2], mem[(self.debug_bus.adr >> 2)][16:24].eq(self.debug_bus.dat_w[16:24])),
               If(self.debug_bus.we & self.debug_bus.sel[3], mem[(self.debug_bus.adr >> 2)][24:32].eq(self.debug_bus.dat_w[24:32])),
              )
        ]

