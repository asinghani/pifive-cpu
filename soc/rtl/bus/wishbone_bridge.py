from migen import *
import math
from third_party import wishbone as wb

class WishboneBridge(Module):
    def __init__(self, bus=None, debug_bus=None, enable_code=0xABAB12):
        if bus is None:
            self.bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus = bus

        if debug_bus is None:
            self.debug_bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.debug_bus = debug_bus

        wb_sel = Signal(4, reset=0b1111)
        wb_addr = Signal(32)
        wb_wr_data = Signal(32)
        wb_rd_data = Signal(32)
        wb_rd_data_valid = Signal()
        wb_error = Signal()
        wb_in_progress = Signal()

        enable_entry = Signal(32, reset=0)
        enabled = enable_entry == Constant(enable_code)

        # 00 = Cfg/Status {19'b0, sel_valid, sel[3:0], 2'b0, error, in_progress, rd_valid, halt, rd_req, wr_req}
        # 04 = Addr
        # 08 = Write Data
        # 0C = Read Data
        # 10 = Enable

        # Main bus
        self.comb += [
            self.bus.stb.eq(wb_in_progress),
            self.bus.cyc.eq(wb_in_progress),
            self.bus.adr.eq(wb_addr),
            self.bus.dat_w.eq(wb_wr_data),
            self.bus.sel.eq(wb_sel)
        ]

        self.sync += [
            If(self.bus.ack,
               wb_in_progress.eq(0),
               wb_rd_data.eq(self.bus.dat_r),
               wb_rd_data_valid.eq(1),
               wb_error.eq(0)),
            If(self.bus.err,
               wb_in_progress.eq(0),
               wb_rd_data_valid.eq(0),
               wb_error.eq(1))
        ]

        # Debug bus
        self.sync += [
            self.debug_bus.ack.eq(0),
            self.debug_bus.err.eq(0),
            self.debug_bus.dat_r.eq(0),

            If(self.debug_bus.stb & self.debug_bus.cyc & ~self.debug_bus.ack,
               self.debug_bus.ack.eq(1),

               If((self.debug_bus.adr >> 2) == 0,
                  If(self.debug_bus.we & self.debug_bus.sel[0],
                     If(enabled & ~wb_in_progress & self.debug_bus.dat_w[0],
                        wb_in_progress.eq(1),
                        wb_error.eq(0),
                        wb_rd_data.eq(0),
                        wb_rd_data_valid.eq(0),
                        self.bus.we.eq(1)).

                     Elif(enabled & ~wb_in_progress & self.debug_bus.dat_w[1],
                          wb_in_progress.eq(1),
                          wb_error.eq(0),
                          wb_rd_data.eq(0),
                          wb_rd_data_valid.eq(0),
                          self.bus.we.eq(0)).

                     Elif(self.debug_bus.dat_w[2],
                          wb_in_progress.eq(0))),

                  If(self.debug_bus.we & self.debug_bus.sel[1],
                     If(self.debug_bus.dat_w[12] == 1,
                        wb_sel.eq(self.debug_bus.dat_w[8:12]))),

                  self.debug_bus.dat_r.eq(Cat(Constant(0, bits_sign=3), wb_rd_data_valid, wb_in_progress, wb_error, Constant(0, bits_sign=2), wb_sel, Constant(0, bits_sign=1)))),

               If((self.debug_bus.adr >> 2) == 1,
                  If(self.debug_bus.we & self.debug_bus.sel[0], wb_addr[0:8].eq(self.debug_bus.dat_w[0:8])),
                  If(self.debug_bus.we & self.debug_bus.sel[1], wb_addr[8:16].eq(self.debug_bus.dat_w[8:16])),
                  If(self.debug_bus.we & self.debug_bus.sel[2], wb_addr[16:24].eq(self.debug_bus.dat_w[16:24])),
                  If(self.debug_bus.we & self.debug_bus.sel[3], wb_addr[24:32].eq(self.debug_bus.dat_w[24:32])),
                  self.debug_bus.dat_r.eq(wb_addr)),

               If((self.debug_bus.adr >> 2) == 2,
                  If(self.debug_bus.we & self.debug_bus.sel[0], wb_wr_data[0:8].eq(self.debug_bus.dat_w[0:8])),
                  If(self.debug_bus.we & self.debug_bus.sel[1], wb_wr_data[8:16].eq(self.debug_bus.dat_w[8:16])),
                  If(self.debug_bus.we & self.debug_bus.sel[2], wb_wr_data[16:24].eq(self.debug_bus.dat_w[16:24])),
                  If(self.debug_bus.we & self.debug_bus.sel[3], wb_wr_data[24:32].eq(self.debug_bus.dat_w[24:32])),
                  self.debug_bus.dat_r.eq(wb_wr_data)),

               If((self.debug_bus.adr >> 2) == 3,
                  self.debug_bus.dat_r.eq(wb_rd_data)),

               If((self.debug_bus.adr >> 2) == 4,
                  If(self.debug_bus.we & self.debug_bus.sel[0], enable_entry[0:8].eq(self.debug_bus.dat_w[0:8])),
                  If(self.debug_bus.we & self.debug_bus.sel[1], enable_entry[8:16].eq(self.debug_bus.dat_w[8:16])),
                  If(self.debug_bus.we & self.debug_bus.sel[2], enable_entry[16:24].eq(self.debug_bus.dat_w[16:24])),
                  If(self.debug_bus.we & self.debug_bus.sel[3], enable_entry[24:32].eq(self.debug_bus.dat_w[24:32])),
                  self.debug_bus.dat_r.eq(enable_entry)),
              )
        ]

