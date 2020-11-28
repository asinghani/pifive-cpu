package test

import chisel3._
import chisel3.util._
import chisel3.util.experimental.loadMemoryFromFile
import firrtl.annotations.MemoryLoadFileType
import mem.Wishbone
import utils.{IntToVec, MathUtils}

class WishboneRAM(val N: Int, val DEPTH: Int, val INIT_FILE: String = "") extends Module {
    assert(N % 8 == 0)
    val NUM_BYTES = N / 8

    val io = IO(new Bundle {
        val bus = new Wishbone(N, INCLUDE_ERR=false)

        val dbg_addr = Input(UInt(N.W))
        val dbg_data_wr = Input(UInt(N.W))
        val dbg_we = Input(Bool())
        val dbg_data_rd = Output(UInt(N.W))
    })

    val ram = SyncReadMem(DEPTH, Vec(NUM_BYTES, UInt(8.W)))

    if (INIT_FILE.length > 1) {
        loadMemoryFromFile(ram, INIT_FILE, MemoryLoadFileType.Hex)
    }

    io.bus.ack := RegNext(io.bus.stb && io.bus.cyc)

    io.bus.data_rd := 0.U
    when (io.bus.stb && io.bus.cyc) {
        when (io.bus.we) {
            ram.write(io.bus.addr, IntToVec(io.bus.data_wr, NUM_BYTES, 8), io.bus.sel.toBools)
        } .otherwise {
            io.bus.data_rd := ram.read(io.bus.addr).asUInt
        }
    }

    // Debug port
    io.dbg_data_rd := ram.read(io.dbg_addr).asUInt
    when (io.dbg_we) {
        ram.write(io.dbg_addr, IntToVec(io.dbg_data_wr, NUM_BYTES, 8))
    }
}
