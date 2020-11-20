from migen import *
import math
from litex.soc.interconnect import wishbone as wb

# Wrapper for I2C controller
class WishboneI2C(Module):
    def __init__(self, pads, fifo_depth=4, bus=None):

        # Check if power of 2
        fifo_addr_width = int(math.log2(fifo_depth))
        if 2**(fifo_addr_width) != fifo_depth:
            raise ValueError("Invalid FIFO depth, must be a power of 2")

        if bus is None:
            self.bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus = bus

        addr_spacing = self.bus.dat_r.nbits // 8
        print(addr_spacing)

        DEFAULT_PRESCALE = 32 # 400kHz @ 50Mhz

        last_stb = Signal()
        last_ack = Signal()
        self.sync += [
            last_stb.eq(self.bus.stb),
            last_ack.eq(self.bus.ack)
        ]

        self.specials += Instance("i2c_master_wbs_16",
            i_i2c_scl_i=pads.scl_i,
            o_i2c_scl_o=pads.scl_o,
            o_i2c_scl_t=pads.scl_oen,

            i_i2c_sda_i=pads.sda_i,
            o_i2c_sda_o=pads.sda_o,
            o_i2c_sda_t=pads.sda_oen,

            i_wbs_adr_i=self.bus.adr >> 1,
            i_wbs_dat_i=self.bus.dat_w,
            o_wbs_dat_o=self.bus.dat_r,
            i_wbs_we_i =self.bus.we & (self.bus.sel[1] | self.bus.sel[0]),
            i_wbs_sel_i=self.bus.sel,

            # Classic -> Pipelined
            i_wbs_stb_i=self.bus.stb & (~last_stb | last_ack),
            o_wbs_ack_o=self.bus.ack,
            i_wbs_cyc_i=self.bus.cyc,

            i_clk=ClockSignal(),
            i_rst=ResetSignal(),

            p_DEFAULT_PRESCALE = 32, # 400kHz @ 50Mhz
            p_FIXED_PRESCALE = 0,
            p_CMD_FIFO = 1,
            p_CMD_FIFO_ADDR_WIDTH = fifo_addr_width,
            p_WRITE_FIFO = 1,
            p_WRITE_FIFO_ADDR_WIDTH = fifo_addr_width,
            p_READ_FIFO = 1,
            p_READ_FIFO_ADDR_WIDTH = fifo_addr_width
        )
