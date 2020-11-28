from migen import *
import math
from third_party import wishbone as wb

class PWM(Module):
    def __init__(self, out, bus=None):

        if bus is None:
            self.bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus = bus

        addr_spacing = self.bus.dat_r.nbits // 8

        ctr    = Signal(bits_sign=32, reset=0)
        width  = Signal(bits_sign=32, reset=0)
        period = Signal(bits_sign=32, reset=0)

        self.sync += [
            self.bus.ack.eq(0),
            self.bus.err.eq(0),
            self.bus.dat_r.eq(0),
            If(self.bus.stb & self.bus.cyc & ~self.bus.ack,
               self.bus.ack.eq(1),

               If((self.bus.adr >> 2) == 0,
                  If(self.bus.we & self.bus.sel[0], width[0:8].eq(self.bus.dat_w[0:8])),
                  If(self.bus.we & self.bus.sel[1], width[8:16].eq(self.bus.dat_w[8:16])),
                  If(self.bus.we & self.bus.sel[2], width[16:24].eq(self.bus.dat_w[16:24])),
                  If(self.bus.we & self.bus.sel[3], width[24:32].eq(self.bus.dat_w[24:32])),
                  self.bus.dat_r.eq(width)),

               If((self.bus.adr >> 2) == 1,
                  If(self.bus.we & self.bus.sel[0], period[0:8].eq(self.bus.dat_w[0:8])),
                  If(self.bus.we & self.bus.sel[1], period[8:16].eq(self.bus.dat_w[8:16])),
                  If(self.bus.we & self.bus.sel[2], period[16:24].eq(self.bus.dat_w[16:24])),
                  If(self.bus.we & self.bus.sel[3], period[24:32].eq(self.bus.dat_w[24:32])),
                  self.bus.dat_r.eq(period))

               )
        ]

        self.comb += out.eq(ctr < width)

        self.sync += [
            ctr.eq(ctr + 1),
            If(ctr >= (period - 1), ctr.eq(0))
        ]
