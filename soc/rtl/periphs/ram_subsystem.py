from migen import *
from third_party import wishbone as wb

class RAMSubsystem(Module):
    def __init__(self, pads, cache_pads, bus_cached=None, bus_uncached=None):
        if bus_cached is None:
            self.bus_cached = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus_cached = bus_cached

        if bus_uncached is None:
            self.bus_uncached = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus_uncached = bus_uncached

        self.flush_all = Signal()

        main_mem_rd_req = Signal()
        main_mem_wr_req = Signal()
        main_mem_mem_or_reg = Signal()
        main_mem_wr_byte_en = Signal(4)
        main_mem_rd_num_dwords = Signal(6)
        main_mem_addr = Signal(32)
        main_mem_wr_d = Signal(32)
        main_mem_rd_d = Signal(32)
        main_mem_rd_rdy = Signal()
        main_mem_busy = Signal()
        main_mem_burst_wr_rdy = Signal()

        self.specials += Instance("MemorySubsystem",

            # Config
            i_io_flush_all=self.flush_all,

            # Cached bus connections
            i_io_bus_cached_cyc=self.bus_cached.cyc,
            i_io_bus_cached_stb=self.bus_cached.stb,
            i_io_bus_cached_we=self.bus_cached.we,
            i_io_bus_cached_sel=self.bus_cached.sel,
            i_io_bus_cached_addr=self.bus_cached.adr,
            i_io_bus_cached_data_wr=self.bus_cached.dat_w,
            o_io_bus_cached_ack=self.bus_cached.ack,
            o_io_bus_cached_err=self.bus_cached.err,
            o_io_bus_cached_data_rd=self.bus_cached.dat_r,

            # Uncached bus connections
            i_io_bus_uncached_cyc=self.bus_uncached.cyc,
            i_io_bus_uncached_stb=self.bus_uncached.stb,
            i_io_bus_uncached_we=self.bus_uncached.we,
            i_io_bus_uncached_sel=self.bus_uncached.sel,
            i_io_bus_uncached_addr=self.bus_uncached.adr,
            i_io_bus_uncached_data_wr=self.bus_uncached.dat_w,
            o_io_bus_uncached_ack=self.bus_uncached.ack,
            o_io_bus_uncached_err=self.bus_uncached.err,
            o_io_bus_uncached_data_rd=self.bus_uncached.dat_r,

            o_io_cache_mem_addr=cache_pads.addr,
            i_io_cache_mem_rd_d=cache_pads.data_rd,
            o_io_cache_mem_we=cache_pads.we,
            o_io_cache_mem_we_sel=cache_pads.we_sel,
            o_io_cache_mem_wr_d=cache_pads.data_wr,

            # Main memory access
            o_io_main_mem_rd_req=main_mem_rd_req,
            o_io_main_mem_wr_req=main_mem_wr_req,
            o_io_main_mem_mem_or_reg=main_mem_mem_or_reg,
            o_io_main_mem_wr_byte_en=main_mem_wr_byte_en,
            o_io_main_mem_rd_num_dwords=main_mem_rd_num_dwords,
            o_io_main_mem_addr=main_mem_addr,
            o_io_main_mem_wr_d=main_mem_wr_d,
            i_io_main_mem_rd_d=main_mem_rd_d,
            i_io_main_mem_rd_rdy=main_mem_rd_rdy,
            i_io_main_mem_busy=main_mem_busy,
            i_io_main_mem_burst_wr_rdy=main_mem_burst_wr_rdy,

            i_clock=ClockSignal(),
            i_reset=ResetSignal()
        )

        dq_oe_l = Signal()
        rwds_oe_l = Signal()

        self.specials += Instance("hyper_xface",
            # Input interface
            i_rd_req=main_mem_rd_req,
            i_wr_req=main_mem_wr_req,
            i_mem_or_reg=main_mem_mem_or_reg,
            i_wr_byte_en=main_mem_wr_byte_en,
            i_rd_num_dwords=main_mem_rd_num_dwords,
            i_addr=main_mem_addr,
            i_wr_d=main_mem_wr_d,
            o_rd_d=main_mem_rd_d,
            o_rd_rdy=main_mem_rd_rdy,
            o_busy=main_mem_busy,
            o_burst_wr_rdy=main_mem_burst_wr_rdy,

            # Config
            i_latency_1x=Constant(0x12),
            i_latency_2x=Constant(0x16),

            # HyperRAM connections
            i_dram_dq_in=pads.dq_i,
            o_dram_dq_out=pads.dq_o,
            o_dram_dq_oe_l=dq_oe_l,

            i_dram_rwds_in=pads.rwds_i,
            o_dram_rwds_out=pads.rwds_o,
            o_dram_rwds_oe_l=rwds_oe_l,

            o_dram_ck=pads.ck,
            o_dram_rst_l=pads.rst_n,
            o_dram_cs_l=pads.cs_n,

            i_reset=ResetSignal(),
            i_clk=ClockSignal()
        )

        self.comb += pads.dq_oe.eq(~dq_oe_l)
        self.comb += pads.rwds_oe.eq(~rwds_oe_l)
