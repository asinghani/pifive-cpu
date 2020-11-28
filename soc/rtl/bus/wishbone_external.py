from migen import *
import math
from third_party import wishbone as wb

class WishboneExternal(Module):
    def __init__(self, pads, bus=None):

        if bus is None:
            self.bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus = bus

        self.enable = Signal(reset=1)

        self.comb += [
            pads.cyc.eq(self.enable & self.bus.cyc),
            pads.stb.eq(self.enable & self.bus.stb),
            pads.addr.eq(self.bus.adr),
            pads.data_wr.eq(self.bus.dat_w),
            self.bus.dat_r.eq(pads.data_rd),
            pads.sel.eq(self.bus.sel),
            pads.we.eq(self.bus.we),
            self.bus.ack.eq(self.enable & pads.ack),
            self.bus.err.eq(self.enable & pads.err)
        ]

class WishboneExternalController(Module):
    def __init__(self, pads, bus=None):

        if bus is None:
            self.bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus = bus

        self.comb += [
            self.bus.cyc.eq(pads.cyc),
            self.bus.stb.eq(pads.stb),
            self.bus.adr.eq(pads.addr),
            self.bus.dat_w.eq(pads.data_wr),
            pads.data_rd.eq(self.bus.dat_r),
            self.bus.sel.eq(pads.sel),
            self.bus.we.eq(pads.we),
            pads.ack.eq(self.bus.ack),
            pads.err.eq(self.bus.err),
        ]
