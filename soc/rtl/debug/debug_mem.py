from migen import *
import math
from third_party import wishbone as wb

class DebugMemory(Module):
    def __init__(self, bus=None, debug_bus=None, enable_code=0xABAB12):
        if bus is None:
            self.bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus = bus

        if debug_bus is None:
            self.debug_bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.debug_bus = debug_bus

        wb_rd_req = self.bus.cyc & self.bus.stb & ~self.bus.ack & ~self.bus.we
        wb_wr_req = self.bus.cyc & self.bus.stb & ~self.bus.ack & self.bus.we

        wb_rd_data = Signal(32)

        self.comb += self.bus.dat_r.eq(wb_rd_data)

        enable_entry = Signal(32, reset=0)
        enabled = enable_entry == Constant(enable_code)

        # 00 = Cfg/Status {22'b0, err, ack, sel[3:0], 2'b0, rd_req, wr_req}
        # 04 = Addr
        # 08 = Write Data
        # 0C = Read Data
        # 10 = Enable

        self.sync += [
            self.bus.ack.eq(0),
            self.bus.err.eq(0),

            self.debug_bus.ack.eq(0),
            self.debug_bus.err.eq(0),
            self.debug_bus.dat_r.eq(0),

            If(self.debug_bus.stb & self.debug_bus.cyc & ~self.debug_bus.ack,
               self.debug_bus.ack.eq(1),

               If((self.debug_bus.adr >> 2) == 0,
                  If(enabled & self.debug_bus.we & self.debug_bus.sel[1],
                     If(self.debug_bus.dat_w[8], self.bus.ack.eq(1)).
                     Elif(self.debug_bus.dat_w[9], self.bus.err.eq(1))),

                  self.debug_bus.dat_r.eq(Cat(wb_wr_req, wb_rd_req, Constant(0, bits_sign=2), self.bus.sel))),

               If((self.debug_bus.adr >> 2) == 1,
                  self.debug_bus.dat_r.eq(self.bus.adr)),

               If((self.debug_bus.adr >> 2) == 2,
                  self.debug_bus.dat_r.eq(self.bus.dat_w)),

               If((self.debug_bus.adr >> 2) == 3,
                  If(self.debug_bus.we & self.debug_bus.sel[0], wb_rd_data[0:8].eq(self.debug_bus.dat_w[0:8])),
                  If(self.debug_bus.we & self.debug_bus.sel[1], wb_rd_data[8:16].eq(self.debug_bus.dat_w[8:16])),
                  If(self.debug_bus.we & self.debug_bus.sel[2], wb_rd_data[16:24].eq(self.debug_bus.dat_w[16:24])),
                  If(self.debug_bus.we & self.debug_bus.sel[3], wb_rd_data[24:32].eq(self.debug_bus.dat_w[24:32])),
                  self.debug_bus.dat_r.eq(wb_rd_data)),

               If((self.debug_bus.adr >> 2) == 4,
                  If(self.debug_bus.we & self.debug_bus.sel[0], enable_entry[0:8].eq(self.debug_bus.dat_w[0:8])),
                  If(self.debug_bus.we & self.debug_bus.sel[1], enable_entry[8:16].eq(self.debug_bus.dat_w[8:16])),
                  If(self.debug_bus.we & self.debug_bus.sel[2], enable_entry[16:24].eq(self.debug_bus.dat_w[16:24])),
                  If(self.debug_bus.we & self.debug_bus.sel[3], enable_entry[24:32].eq(self.debug_bus.dat_w[24:32])),
                  self.debug_bus.dat_r.eq(enable_entry)),
              )
        ]

