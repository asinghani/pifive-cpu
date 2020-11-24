from migen import *
import math
from litex.soc.interconnect import wishbone as wb

class DebugProbe(Module):
    def __init__(self, original_init_pc=0x1000_0000, probe_width=32, output_width=32, bus=None, enable_code=0xABAB12):
        if bus is None:
            self.bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus = bus


        if probe_width <= 0 or probe_width > 512 or probe_width % 32 != 0:
            raise ValueError("Maximum 512 probes, and number of probes must be multiple of 32")

        if output_width <= 0 or output_width > 512 or output_width % 32 != 0:
            raise ValueError("Maximum 512 outputs, and number of outputs must be multiple of 32")

        _outputs = [Signal(32) for i in range(0, output_width, 32)]
        self.probe = Signal(probe_width)
        self.output = Cat(*_outputs)

        self.stall_out = Signal(reset=0)
        self.stall_in = Signal()

        self.reset_out = Signal(reset=0)
        self.flush_out = Signal(reset=0)
        self.init_pc = Signal(32)

        probes = Array(self.probe[i:i+32] for i in range(0, probe_width, 32))
        outputs = Array(_outputs)

        enable_entry = Signal(32, reset=0)
        enabled = enable_entry == Constant(enable_code)

        flush = Signal(reset=0)
        self.comb += self.flush_out.eq(flush & enabled)

        rst = Signal(reset=0)
        self.comb += self.reset_out.eq(rst & enabled)

        # Config Regs
        stall = Signal(reset=0)
        step_cycle = Signal(reset=0)
        step_pipe = Signal(reset=0)
        init_pc = Signal(32, reset_less=True)

        # Read-only Regs
        stall_ctr = Signal(32, reset=0)
        self.sync += stall_ctr.eq(Mux(self.stall_in, stall_ctr + 1, 0))

        self.comb += self.init_pc.eq(Mux(enabled, init_pc, Constant(original_init_pc)))

        # 000 = Cfg/Status {26'b0, flush, reset, step_cycle, step_pipe, stall(out), stall(in)}
        # 004 = Cycles since last non-stalled cycle
        # 008 = Unused
        # 00C = Unused
        # 010 = Enable
        # 200 = Probes
        # 400 = Outputs

        self.sync += [
            self.stall_out.eq(0),
            If(enabled & stall, self.stall_out.eq(1)),

            # TODO fix stepper
            #If(enabled & stall & step_cycle,
            #   self.stall_out.eq(0),
            #   step_cycle.eq(0)).
            #Elif(enabled & stall & step_pipe,
            #     If(self.stall_in == 0, step_pipe.eq(0)).
            #     Else(self.stall_out.eq(0)))
        ]

        # Debug bus
        self.sync += [
            self.bus.ack.eq(0),
            self.bus.err.eq(0),
            self.bus.dat_r.eq(0),

            If(self.bus.stb & self.bus.cyc & ~self.bus.ack,
               self.bus.ack.eq(1),

               If((self.bus.adr >> 2) == 0,
                  If(self.bus.we & self.bus.sel[0],
                     If(enabled, stall.eq(self.bus.dat_w[1])),
                     If(enabled, rst.eq(self.bus.dat_w[4])),
                     If(enabled, flush.eq(self.bus.dat_w[5])),

                     If(enabled & self.bus.dat_w[2],
                        step_pipe.eq(1)).

                     Elif(enabled & self.bus.dat_w[3],
                          step_cycle.eq(1))),

                  self.bus.dat_r.eq(Cat(self.stall_in, stall, step_pipe, step_cycle, rst, flush))),

               If((self.bus.adr >> 2) == 1,
                  self.bus.dat_r.eq(stall_ctr)),

               If((self.bus.adr >> 2) == 2,
                  If(self.bus.we & self.bus.sel[0], init_pc[0:8].eq(self.bus.dat_w[0:8])),
                  If(self.bus.we & self.bus.sel[1], init_pc[8:16].eq(self.bus.dat_w[8:16])),
                  If(self.bus.we & self.bus.sel[2], init_pc[16:24].eq(self.bus.dat_w[16:24])),
                  If(self.bus.we & self.bus.sel[3], init_pc[24:32].eq(self.bus.dat_w[24:32])),
                  self.bus.dat_r.eq(init_pc)),

               If((self.bus.adr >> 2) == 3,
                  self.bus.dat_r.eq(0x12341234)),

               If((self.bus.adr >> 2) == 4,
                  If(self.bus.we & self.bus.sel[0], enable_entry[0:8].eq(self.bus.dat_w[0:8])),
                  If(self.bus.we & self.bus.sel[1], enable_entry[8:16].eq(self.bus.dat_w[8:16])),
                  If(self.bus.we & self.bus.sel[2], enable_entry[16:24].eq(self.bus.dat_w[16:24])),
                  If(self.bus.we & self.bus.sel[3], enable_entry[24:32].eq(self.bus.dat_w[24:32])),
                  self.bus.dat_r.eq(enable_entry)),

               If((self.bus.adr >= Constant(0x200)) & (self.bus.adr < Constant(0x400)),
                  self.bus.dat_r.eq(probes[((self.bus.adr-0x200) >> 2)])),

               If((self.bus.adr >= Constant(0x400)) & (self.bus.adr < Constant(0x600)),
                  If(self.bus.we & self.bus.sel[0], outputs[((self.bus.adr-0x400) >> 2)][0:8].eq(self.bus.dat_w[0:8])),
                  If(self.bus.we & self.bus.sel[1], outputs[((self.bus.adr-0x400) >> 2)][8:16].eq(self.bus.dat_w[8:16])),
                  If(self.bus.we & self.bus.sel[2], outputs[((self.bus.adr-0x400) >> 2)][16:24].eq(self.bus.dat_w[16:24])),
                  If(self.bus.we & self.bus.sel[3], outputs[((self.bus.adr-0x400) >> 2)][24:32].eq(self.bus.dat_w[24:32])),
                  self.bus.dat_r.eq(outputs[((self.bus.adr-0x400) >> 2)])),
              )
        ]

