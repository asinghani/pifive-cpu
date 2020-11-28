from migen import *
from third_party import wishbone as wb

class SPI(Module):
    def __init__(self, pads, bus=None):
        if bus is None:
            self.bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus = bus

        self.irq = Signal()

        wb_req = self.bus.cyc & self.bus.stb & ~self.bus.ack

        data_out_reg = Signal(8)
        data_out = Signal(8)
        data_out_valid = Signal()
        self.sync += If(data_out_valid, data_out_reg.eq(data_out))

        data_write = Signal(8)
        start_write = Signal()

        ready = Signal()
        mode = Signal(2)
        divider = Signal(16, reset=25) # 1Mhz at 50Mhz clk
        last_out_valid = Signal()

        # Address 0 = Config / Status = {13'b0, ready[0:0], mode[1:0], divider[15:0]}
        # Address 4 = Data Write (lowest 8 bits)
        # Address 8 = Data Read (lowest 8 bits)
        self.sync += [
            self.bus.ack.eq(0),
            self.bus.err.eq(0),
            self.irq.eq(0),
            start_write.eq(0),
            last_out_valid.eq(data_out_valid),
            If(data_out_valid & ~last_out_valid, self.irq.eq(1)),

            If(wb_req,
               self.bus.ack.eq(1),
               If((self.bus.adr >> 2) == 0,
                  If(self.bus.we & self.bus.sel[0], divider[0:8].eq(self.bus.dat_w[0:8])),
                  If(self.bus.we & self.bus.sel[1], divider[8:16].eq(self.bus.dat_w[8:16])),
                  If(self.bus.we & self.bus.sel[2], mode.eq(self.bus.dat_w[16:18])),
                  self.bus.dat_r.eq(Cat(divider, mode, ready))),
               ),
               If((self.bus.adr >> 2) == 1,
                  If(self.bus.we & self.bus.sel[0],
                     data_write.eq(self.bus.dat_w[0:8]),
                     start_write.eq(1)),
                  self.bus.dat_r.eq(data_write)
               ),
               If((self.bus.adr >> 2) == 2,
                  self.bus.dat_r.eq(data_out_reg),
               ),
        ]

        self.specials += Instance("spi_controller",
            i_i_TX_Byte=data_write,
            i_i_TX_DV=start_write,
            o_o_TX_Ready=ready,

            o_o_RX_Byte=data_out,
            o_o_RX_DV=data_out_valid,

            o_o_SPI_Clk=pads.clk,
            i_i_SPI_MISO=pads.miso,
            o_o_SPI_MOSI=pads.mosi,

            i_i_CPHA=mode[0],
            i_i_CPOL=mode[1],
            i_i_divider=divider,

            i_i_Clk=ClockSignal(),
            i_i_Rst=ResetSignal()
        )
