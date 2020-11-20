from migen import *
import math
from litex.soc.interconnect import wishbone as wb

class Timer(Module):
    def __init__(self, bus=None):
        self.irq = Signal()

        if bus is None:
            self.bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus = bus

        ctr = Signal(bits_sign=32, reset=0)

        # When enabled, runs for `load` cycles, then repeatedly reloads to `reload` cycles
        # (Unless reload is zero)
        running = Signal(reset=0)
        triggered = Signal(reset=0)
        reload = Signal(bits_sign=32)
        load = Signal(bits_sign=32)

        # Address space:
        # 00 = ctr
        # 04 = reload 
        # 08 = load 
        # 0C = enable 
        # 10 = triggered
        self.sync += [
            self.irq.eq(0),
            If(running,
               ctr.eq(ctr - 1),
               If(ctr == 1,
                  triggered.eq(1),
                  self.irq.eq(1),
                  If(reload != 0, ctr.eq(reload)).
                  Else(ctr.eq(0)))).
            Else(ctr.eq(0), triggered.eq(0)),

            self.bus.ack.eq(0),
            self.bus.err.eq(0),
            self.bus.dat_r.eq(0),
            If(self.bus.stb & self.bus.cyc & ~self.bus.ack,
               self.bus.ack.eq(1),

               If((self.bus.adr >> 2) == 0,
                  self.bus.dat_r.eq(ctr)),

               If((self.bus.adr >> 2) == 1,
                  If(self.bus.we & self.bus.sel[0], reload[0:8].eq(self.bus.dat_w[0:8])),
                  If(self.bus.we & self.bus.sel[1], reload[8:16].eq(self.bus.dat_w[8:16])),
                  If(self.bus.we & self.bus.sel[2], reload[16:24].eq(self.bus.dat_w[16:24])),
                  If(self.bus.we & self.bus.sel[3], reload[24:32].eq(self.bus.dat_w[24:32])),
                  self.bus.dat_r.eq(reload)),

               If((self.bus.adr >> 2) == 2,
                  If(self.bus.we & self.bus.sel[0], load[0:8].eq(self.bus.dat_w[0:8])),
                  If(self.bus.we & self.bus.sel[1], load[8:16].eq(self.bus.dat_w[8:16])),
                  If(self.bus.we & self.bus.sel[2], load[16:24].eq(self.bus.dat_w[16:24])),
                  If(self.bus.we & self.bus.sel[3], load[24:32].eq(self.bus.dat_w[24:32])),
                  self.bus.dat_r.eq(load)),

               If((self.bus.adr >> 2) == 3,
                  If(self.bus.we & self.bus.sel[0],
                     running.eq(self.bus.dat_w[0]),
                     If(self.bus.dat_w[0], ctr.eq(load))),
                  self.bus.dat_r.eq(running)),

               If((self.bus.adr >> 2) == 4,
                  If(self.bus.we & self.bus.sel[0] & self.bus.dat_w[0] == 0, triggered.eq(0)),
                  self.bus.dat_r.eq(triggered)),
              )
        ]

class UptimeTimer(Module):
    def __init__(self, bus=None, reset_less=False):

        if bus is None:
            self.bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus = bus

        if reset_less:
            ctr = Signal(bits_sign=64, reset_less=True)
        else:
            ctr = Signal(bits_sign=64, reset=0)

        # Reads are not guaranteed to be atomic
        # Read-procedure: 
        #   - Read high word
        #   - Read low word
        #   - Re-read high word
        #   - If high word has changed, re-read low word
        # Because the low word will only roll over after 4B clock cycles,
        # it is safe to read in this manner (with the last condition catching any rollovers)
        self.sync += [
            self.bus.ack.eq(0),
            self.bus.err.eq(0),
            self.bus.dat_r.eq(0),
            If(self.bus.stb & self.bus.cyc & ~self.bus.ack,
               self.bus.ack.eq(1),
               If((self.bus.adr >> 2) == 0, self.bus.dat_r.eq(ctr[0:32])),
               If((self.bus.adr >> 2) == 1, self.bus.dat_r.eq(ctr[32:64]))
              )
        ]

        self.sync += ctr.eq(ctr + 1)
