from migen import *
from litex.soc.interconnect import wishbone as wb

class WishboneDebugBus(Module):
    def __init__(self, uart, clk_freq, baud=115200, drop_clks=None, fifo_depth=16):
        if drop_clks is None:
            # Default to 0.1s timeout
            drop_clks = clk_freq // 10

        self.uart_tx = uart.tx
        self.uart_rx = uart.rx

        self.bus = wb.Interface(data_width=32, adr_width=32)

        self.ctr = Signal(16)

        last_stb = Signal()
        self.sync += [
            last_stb.eq(self.bus.stb),
            If(self.bus.cyc & self.bus.stb,
               If(~last_stb, self.ctr.eq(0)).
               Else(self.ctr.eq(self.ctr + 1)))
        ]

        self.sync += [
            self.bus.sel.eq(Constant(0b1111)),
            self.bus.cti.eq(Constant(0b000)),
            self.bus.bte.eq(Constant(0b00))
        ]

        self.specials += Instance("wbdbgbus",
            o_o_tx=self.uart_tx,
            i_i_rx=self.uart_rx,

            o_o_wb_cyc=self.bus.cyc,
            o_o_wb_stb=self.bus.stb,
            o_o_wb_we=self.bus.we,
            o_o_wb_addr=self.bus.adr,
            o_o_wb_data=self.bus.dat_w,

            i_i_wb_ack=self.bus.ack,
            i_i_wb_err=self.bus.err,
            i_i_wb_stall=0,
            i_i_wb_data=self.bus.dat_r,

            i_i_interrupt_1=0,
            i_i_interrupt_2=0,
            i_i_interrupt_3=0,
            i_i_interrupt_4=0,

            i_i_clk=ClockSignal(),

            p_CLK_FREQ=clk_freq,
            p_UART_BAUD=baud,
            p_DROP_CLKS=drop_clks,
            p_FIFO_DEPTH=fifo_depth
        )
