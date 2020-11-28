package mem

import chisel3._

class MemoryInterfaceSimple(val N: Int) extends Bundle {
    assert(N % 8 == 0)
    val NUM_BYTES = N / 8

    val addr = Input(UInt(N.W)) // Byte-address, but can ignore low bits
    val rd_d = Output(UInt(N.W))
    val we = Input(Bool())
    val we_sel = Input(UInt(NUM_BYTES.W))
    val wr_d = Input(UInt(N.W))
}
