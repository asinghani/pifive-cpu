package cache

import chisel3._
import chisel3.util._
import mem.{MemoryInterface, MemoryInterfaceSimple, Wishbone}
import utils._

// Direct-mapped read-only cache
// All parameters in bytes except N
class ICache(val N: Int, val LINE_WIDTH: Int, val NUM_SETS: Int) extends Module {
    assert(N % 8 == 0)
    val BYTES_PER_WORD = N / 8
    assert(LINE_WIDTH % BYTES_PER_WORD == 0)
    val WORDS_PER_LINE = LINE_WIDTH / BYTES_PER_WORD
    val LINE_BITS = MathUtils.intLog2(LINE_WIDTH) // Block offset
    val LINE_WORD_BITS = LINE_BITS - MathUtils.intLog2(BYTES_PER_WORD)
    val LINE_WORDS = LINE_WIDTH / BYTES_PER_WORD
    assert(MathUtils.intLog2(LINE_WORDS) == LINE_WORD_BITS)
    val SET_BITS = MathUtils.intLog2(NUM_SETS)
    val TAG_BITS = N - LINE_BITS - SET_BITS

    val state_idle :: state_pending :: state_load_line :: state_return_data :: Nil = Enum(4)

    val io = IO(new Bundle {
        val flush_all = Input(Bool()) // Raise to flush the cache
        val busy = Output(Bool())
        val bus = new Wishbone(N, INCLUDE_ERR=false) // Bus used to access the ICache
        val cache_mem = Flipped(new MemoryInterfaceSimple(N)) // Cache SRAM - must respond within 1 cycle
        val main_mem = Flipped(new MemoryInterface(N)) // Main slow memory access
    })

    val valids = RegInit(VecInit(Seq.fill(NUM_SETS)(false.B)))
    val tags = RegInit(VecInit(Seq.fill(NUM_SETS)(0.U(TAG_BITS.W))))
    println(s"Cache overhead size: ${NUM_SETS} valid bits, ${NUM_SETS * TAG_BITS} tag bits")
    println(s"Cache usable size: ${NUM_SETS * LINE_WIDTH} bytes")

    when (io.flush_all) { for (i <- (0 until NUM_SETS)) { valids(i) := false.B } }
    val state = RegInit(state_idle)
    val next_state = WireDefault(state)
    io.busy := (state =/= state_idle) || (next_state =/= state_idle) || io.main_mem.busy
    state := next_state

    if (io.bus.INCLUDE_ERR) io.bus.err := false.B
    val ack = WireDefault(false.B)
    io.bus.ack := RegNext(ack)
    val err = WireDefault(false.B)
    io.bus.err := RegNext(err)

    io.cache_mem.we := false.B
    io.cache_mem.we_sel := ((1 << BYTES_PER_WORD) - 1).U
    io.cache_mem.wr_d := 0.U
    io.cache_mem.addr := 0.U
    io.bus.data_rd := io.cache_mem.rd_d

    io.main_mem.wr_req := false.B
    io.main_mem.mem_or_reg := 0.U
    io.main_mem.wr_byte_en := 0.U
    io.main_mem.wr_d := 0.U
    io.main_mem.rd_num_dwords := WORDS_PER_LINE.U

    io.main_mem.rd_req := false.B
    io.main_mem.addr := RegInit(0.U(N.W))

    val word_ctr = RegInit(0.U(LINE_WORD_BITS.W))
    val pending_tag_bits = RegInit(0.U(TAG_BITS.W))
    val pending_set_index = RegInit(0.U(SET_BITS.W))
    val pending_block_offset = RegInit(0.U(LINE_WORD_BITS.W))

    val word_addr = io.bus.addr(N-1, MathUtils.intLog2(BYTES_PER_WORD))
    val addr_tag_bits = io.bus.addr(N-1, LINE_BITS+SET_BITS)
    val addr_set_index = io.bus.addr(LINE_BITS+SET_BITS-1, LINE_BITS)
    val _addr_block_offset = io.bus.addr(LINE_BITS-1, 0)
    val addr_block_offset_word = io.bus.addr(LINE_BITS-1, MathUtils.intLog2(BYTES_PER_WORD))
    val addr_block_offset_misaligned = io.bus.addr(MathUtils.intLog2(BYTES_PER_WORD)-1, 0) =/= 0.U

    when (state === state_idle && io.bus.stb && io.bus.cyc && !io.bus.ack) {
        when (io.bus.we) {
            if (io.bus.INCLUDE_ERR) err := true.B
            else ack := true.B
        } .otherwise {
            io.cache_mem.addr := Cat(addr_set_index, addr_block_offset_word)

            when (addr_block_offset_misaligned && io.bus.INCLUDE_ERR.B) {
                // Misaligned access
                err := true.B
            } .elsewhen ((!io.flush_all) && valids(addr_set_index) && (tags(addr_set_index) === addr_tag_bits)) {
                // Load data from cache line
                ack := true.B
            } .elsewhen (io.main_mem.busy) {
                // Cache line load pending
                next_state := state_pending
                pending_tag_bits := addr_tag_bits
                pending_set_index := addr_set_index
                pending_block_offset := addr_block_offset_word
            } .otherwise {
                // Load cache line
                next_state := state_load_line
                io.main_mem.rd_req := true.B
                io.main_mem.addr := Cat(addr_tag_bits, addr_set_index, 0.U(LINE_WORD_BITS.W))
                pending_tag_bits := addr_tag_bits
                pending_set_index := addr_set_index
                pending_block_offset := addr_block_offset_word
                word_ctr := 0.U
            }
        }
    } .elsewhen (state === state_pending) {
        when (!io.main_mem.busy) {
            // Load cache line
            next_state := state_load_line
            io.main_mem.rd_req := true.B
            io.main_mem.addr := Cat(pending_tag_bits, pending_set_index, 0.U(LINE_WORD_BITS.W))
            word_ctr := 0.U
        }
    } .elsewhen ((state === state_load_line) && io.main_mem.rd_rdy) {
        io.cache_mem.we := true.B
        io.cache_mem.wr_d := io.main_mem.rd_d
        io.cache_mem.addr := Cat(pending_set_index, word_ctr(LINE_WORD_BITS-1, 0))

        word_ctr := word_ctr + 1.U
        when (word_ctr === WORDS_PER_LINE.U - 1.U) {
            word_ctr := 0.U
            next_state := state_return_data
        }
    } .elsewhen (state === state_return_data) {
        valids(pending_set_index) := true.B
        tags(pending_set_index) := pending_tag_bits
        ack := true.B
        next_state := state_idle
        io.cache_mem.addr := Cat(pending_set_index, pending_block_offset)
    }
}
