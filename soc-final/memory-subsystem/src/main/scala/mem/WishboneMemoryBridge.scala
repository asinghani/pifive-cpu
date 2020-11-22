package mem

import chisel3._
import utils.{MathUtils, PseudoLatch}

class WishboneMemoryBridge(val N: Int) extends Module {
    assert(N % 8 == 0)
    val NUM_BYTES = N / 8

    val io = IO(new Bundle {
        val bus = new Wishbone(N)
        val busy = Output(Bool())
        val mem = Flipped(new MemoryInterface(N))
    })

    val ack = RegInit(false.B)
    val ack_data = Reg(UInt(N.W))

    val txn_queued = RegInit(false.B)
    val txn_active = RegInit(false.B)
    val txn_we = RegInit(false.B)

    val wb_txn_valid = !txn_active && io.bus.stb && io.bus.cyc && !io.bus.ack && !ack
    val addr = PseudoLatch(wb_txn_valid, io.bus.addr)
    val sel = PseudoLatch(wb_txn_valid, io.bus.sel)
    val data_wr = PseudoLatch(wb_txn_valid, io.bus.data_wr)
    val we = PseudoLatch(wb_txn_valid, io.bus.we)

    io.mem.rd_req := false.B
    io.mem.wr_req := false.B

    io.mem.mem_or_reg := addr(27)
    io.mem.wr_byte_en := sel
    io.mem.rd_num_dwords := 1.U
    io.mem.addr := addr(26, MathUtils.intLog2(NUM_BYTES)) // Word address
    io.mem.wr_d := data_wr

    io.bus.err := false.B
    io.bus.ack := false.B
    io.bus.data_rd := 0.U

    io.busy := io.mem.busy

    when (ack) {
        ack := false.B
        io.bus.ack := true.B
        io.bus.data_rd := ack_data

    } .elsewhen (txn_active) {
        when (Mux(txn_we, !io.mem.busy, io.mem.rd_rdy))  {
            ack := true.B
            ack_data := io.mem.rd_d
            txn_active := false.B
        }
    } .elsewhen (txn_queued) {
        when (Mux(we, !io.mem.busy && !io.mem.burst_wr_rdy, !io.mem.busy)) {
            io.mem.rd_req := !we
            io.mem.wr_req := we
            txn_queued := false.B
            txn_active := true.B
            txn_we := we
        }
    }

    when (wb_txn_valid) {
        when (Mux(we, !io.mem.busy && !io.mem.burst_wr_rdy, !io.mem.busy)) {
            io.mem.rd_req := !we
            io.mem.wr_req := we
            txn_queued := false.B
            txn_active := true.B
            txn_we := we
        } .otherwise {
            txn_queued := true.B
        }
    }
}
