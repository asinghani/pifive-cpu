package test

import chisel3._
import chisel3.util.experimental.loadMemoryFromFile
import firrtl.annotations.MemoryLoadFileType
import mem.MemoryInterface
import utils._

class FakeHyperRAM(val N: Int, val DEPTH: Int, val INIT_FILE: String = "") extends Module {
    assert(N % 8 == 0)
    val NUM_BYTES = N / 8

    val io = IO(new Bundle {
        val bus = new MemoryInterface(N)

        val dbg_addr = Input(UInt(N.W))
        val dbg_data_wr = Input(UInt(N.W))
        val dbg_we = Input(Bool())
        val dbg_data_rd = Output(UInt(N.W))
    })

    val ram = Mem(DEPTH, UInt(N.W))

    if (INIT_FILE.length > 1) {
        loadMemoryFromFile(ram, INIT_FILE, MemoryLoadFileType.Hex)
    }

    val DELAY = 10

    val addr_save = RegInit(0.U(N.W))
    val rd_word_ctr = RegInit(0.U(20.W))
    val rd_word_total = RegInit(0.U(20.W))
    val rd_cycle_ctr = RegInit(0.U(20.W))
    val busy = RegInit(false.B)
    io.bus.burst_wr_rdy := 0.U
    io.bus.busy := busy
    io.bus.rd_rdy := false.B
    io.bus.rd_d := 0.U

    when (io.bus.rd_req) {
        busy := true.B
        rd_word_ctr := 0.U
        rd_word_total := io.bus.rd_num_dwords
        rd_cycle_ctr := DELAY.U
        addr_save := io.bus.addr
    } .elsewhen (busy && rd_cycle_ctr =/= 0.U) {
        rd_cycle_ctr := rd_cycle_ctr - 1.U
        when (rd_cycle_ctr - 1.U === 0.U) {
            rd_cycle_ctr := DELAY.U
            rd_word_ctr := rd_word_ctr + 1.U
            when (rd_word_ctr === rd_word_total - 1.U) {
                rd_word_ctr := 0.U
                rd_cycle_ctr := 0.U
                busy := false.B
            }
            io.bus.rd_rdy := true.B
            io.bus.rd_d := ram.read(addr_save.asUInt + rd_word_ctr)
        }
    }

    // TODO writes are ignored
    // wr_req, wr_byte_en, wr_d

    // Debug port
    io.dbg_data_rd := ram.read(io.dbg_addr)
    when (io.dbg_we) {
        ram.write(io.dbg_addr, io.dbg_data_wr)
    }
}
