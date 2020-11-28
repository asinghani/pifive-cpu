package mem

import chisel3._

class MemoryArbiter(val N: Int) extends Module {
    assert(N % 8 == 0)
    val NUM_BYTES = N / 8

    val io = IO(new Bundle {
        val in0 = new MemoryInterface(N)
        val in1 = new MemoryInterface(N)

        val out = Flipped(new MemoryInterface(N))
        val grant = Output(UInt(1.W))
    })

    val grant = RegInit(0.U(1.W))
    io.grant := grant

    when (grant === 0.U) {
        io.out <> io.in0
        io.in1.rd_d := 0.U
        io.in1.rd_rdy := false.B
        io.in1.busy := true.B
        io.in1.burst_wr_rdy := false.B
    } .otherwise {
        io.out <> io.in1
        io.in0.rd_d := 0.U
        io.in0.rd_rdy := false.B
        io.in0.busy := true.B
        io.in0.burst_wr_rdy := false.B
    }

    // Flip-flop between inputs when not active
    // Not optimal, but sufficient because memory access takes dozens of cycles
    // so an extra cycle delay is negligible
    when (!io.out.busy && !io.out.burst_wr_rdy &&
          !io.out.rd_req && !io.out.wr_req &&
          !RegNext(io.out.busy) && !RegNext(io.out.burst_wr_rdy) &&
          !RegNext(io.out.rd_req) && !RegNext(io.out.wr_req)) {
        grant := ~grant
    }
}
