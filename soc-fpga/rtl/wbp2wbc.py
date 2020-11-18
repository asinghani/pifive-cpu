from migen import *
from litex.soc.interconnect import wishbone as wb

class WBP2WBC(Module):
    def __init__(self, bus_in=None, bus_out=None):
        if bus_in is None:
            self.bus_in = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus_in = bus_in

        if bus_out is None:
            self.bus_out = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus_out = bus_out

        self.sync += [
            self.bus_out.cti.eq(Constant(0b000)),
            self.bus_out.bte.eq(Constant(0b00))
        ]

        self.specials += Instance("wbp2classic",
            i_i_mcyc=self.bus_in.cyc,
            i_i_mstb=self.bus_in.stb,
            i_i_mwe=self.bus_in.we,
            i_i_maddr=self.bus_in.adr,
            i_i_mdata=self.bus_in.dat_w,
            i_i_msel=self.bus_in.sel,
            o_o_mack=self.bus_in.ack,
            o_o_mdata=self.bus_in.dat_r,
            o_o_merr=self.bus_in.err,

            o_o_scyc=self.bus_out.cyc,
            o_o_sstb=self.bus_out.stb,
            o_o_swe=self.bus_out.we,
            o_o_saddr=self.bus_out.adr,
            o_o_sdata=self.bus_out.dat_w,
            o_o_ssel=self.bus_out.sel,
            i_i_sack=self.bus_out.ack,
            i_i_sdata=self.bus_out.dat_r,
            i_i_serr=self.bus_out.err,

            i_i_clk=ClockSignal(),
            i_i_reset=ResetSignal(),

            p_AW=32,
            p_DW=32
        )
