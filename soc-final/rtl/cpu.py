from migen import *
from litex.soc.interconnect import wishbone as wb

class CPUWrapper(Module):
    def __init__(self, use_barrel_shifter=True):
        self.instr_bus = wb.Interface(data_width=32, adr_width=32)
        self.data_bus = wb.Interface(data_width=32, adr_width=32)

        self.stall_in = Signal()
        self.stall_out = Signal()
        self.init_pc = Signal(32)

        self.cpu_reset = Signal(reset=0)

        self.sync += [
            self.instr_bus.cti.eq(Constant(0b000)),
            self.instr_bus.bte.eq(Constant(0b00)),
            self.data_bus.cti.eq(Constant(0b000)),
            self.data_bus.bte.eq(Constant(0b00))
        ]

        self.specials += Instance("cpu",
            o_instr_wb_cyc=self.instr_bus.cyc,
            o_instr_wb_stb=self.instr_bus.stb,
            o_instr_wb_we=self.instr_bus.we,
            o_instr_wb_sel=self.instr_bus.sel,
            o_instr_wb_addr=self.instr_bus.adr,
            o_instr_wb_data_wr=self.instr_bus.dat_w,
            i_instr_wb_ack=self.instr_bus.ack,
            i_instr_wb_err=self.instr_bus.err,
            i_instr_wb_data_rd=self.instr_bus.dat_r,

            o_data_wb_cyc=self.data_bus.cyc,
            o_data_wb_stb=self.data_bus.stb,
            o_data_wb_we=self.data_bus.we,
            o_data_wb_sel=self.data_bus.sel,
            o_data_wb_addr=self.data_bus.adr,
            o_data_wb_data_wr=self.data_bus.dat_w,
            i_data_wb_ack=self.data_bus.ack,
            i_data_wb_err=self.data_bus.err,
            i_data_wb_data_rd=self.data_bus.dat_r,

            i_i_stall_in=self.stall_in,
            i_i_init_pc=self.init_pc,
            o_o_stall_out=self.stall_out,

            i_i_clk=ClockSignal(),
            i_i_rst=ResetSignal() | self.cpu_reset,

            p_USE_BARREL_SHIFTER=use_barrel_shifter,
            p_WISHBONE_PIPELINED=0
        )
