from migen import *
from litex.soc.interconnect import wishbone as wb

class WishboneUART(Module):
    def __init__(self, uart, clk_freq, baud=115200, fifo_depth=16, bus=None):
        self.uart_tx = uart.tx
        self.uart_rx = uart.rx

        if bus is None:
            self.bus = wb.Interface()
        else:
            self.bus = bus

        addr_spacing = self.bus.dat_r.nbits // 8
        print(addr_spacing)

        self.specials += Instance("wbuart",
            o_o_tx=self.uart_tx,
            i_i_rx=self.uart_rx,

            i_i_wb_cyc=self.bus.cyc,
            i_i_wb_stb=self.bus.stb,
            i_i_wb_we=self.bus.we & self.bus.sel[0],
            i_i_wb_addr=self.bus.adr,
            i_i_wb_data=self.bus.dat_w,

            o_o_wb_ack=self.bus.ack,
            o_o_wb_err=self.bus.err,
            o_o_wb_data=self.bus.dat_r,

            i_i_clk=ClockSignal(),
            i_i_rst=ResetSignal(),

            p_UART_BAUD=baud,
            #p_CLK_FREQ=clk_freq,
            p_FIFO_DEPTH=fifo_depth,

            p_ADDR_STATUS=0,
            p_ADDR_WRITE=addr_spacing,
            p_ADDR_READ=2 * addr_spacing
        )
