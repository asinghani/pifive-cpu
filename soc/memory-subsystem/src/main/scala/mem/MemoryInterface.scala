package mem

import chisel3._

class MemoryInterface(val N: Int) extends Bundle {
    assert(N % 8 == 0)
    val NUM_BYTES = N / 8

    val rd_req = Input(Bool())
    val wr_req = Input(Bool())
    val mem_or_reg = Input(Bool())
    val wr_byte_en = Input(UInt(NUM_BYTES.W))
    val rd_num_dwords = Input(UInt(6.W))
    val addr = Input(UInt(N.W))
    val wr_d = Input(UInt(N.W))
    val rd_d = Output(UInt(N.W))
    val rd_rdy = Output(Bool())
    val busy = Output(Bool())
    val burst_wr_rdy = Output(Bool())
}
