package mem

import cache.ICache
import chisel3._
import test._

class CacheTop extends Module {
    val io = IO(new Bundle {
        val flush_all = Input(Bool())
        val bus = new Wishbone(32, INCLUDE_ERR = true)
        val mem = Flipped(new MemoryInterface(32))
    })

    val LINE_WIDTH = 32
    val NUM_SETS = 8

    // Addr: TTTT SS OOO
    // Tag, Set, Offset
    val cache = Module(new ICache(32, LINE_WIDTH, NUM_SETS))
    cache.io.bus <> io.bus
    cache.io.flush_all <> io.flush_all

    val cache_mem = Module(new SimpleRAM(32, NUM_SETS * LINE_WIDTH / 4))
    cache.io.cache_mem <> cache_mem.io.bus
    cache_mem.io.bus <> cache.io.cache_mem
    cache_mem.io.dbg_addr := 0.U
    cache_mem.io.dbg_data_wr := 0.U
    cache_mem.io.dbg_we := 0.U

    cache.io.main_mem <> io.mem
}