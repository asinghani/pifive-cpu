package mem

import cache.ICache
import chisel3._
import test._

class MemorySubsystem(val LINE_WIDTH: Int = 32,
                      val NUM_SETS: Int = 8,
                      val INCLUDE_MEMORY: Boolean = false) extends Module {

    val io = IO(new Bundle {
        val flush_all = Input(Bool())
        val bus_cached = new Wishbone(32, INCLUDE_ERR = true)
        val bus_uncached = new Wishbone(32, INCLUDE_ERR = true)

        val cache_mem = Flipped(new MemoryInterfaceSimple(32))
        val main_mem = Flipped(new MemoryInterface(32))
    })

    // Addr: TTTT SS OOO
    // Tag, Set, Offset
    val cache = Module(new ICache(32, LINE_WIDTH, NUM_SETS))
    cache.io.bus <> io.bus_cached
    cache.io.flush_all <> io.flush_all

    val direct = Module(new WishboneMemoryBridge(32))
    direct.io.bus <> io.bus_uncached

    val arbiter = Module(new MemoryArbiter(32))
    arbiter.io.in0 <> cache.io.main_mem
    arbiter.io.in1 <> direct.io.mem
    arbiter.io.out <> io.main_mem

    println(s"EXPECTED MEMORY SIZE: ${NUM_SETS * LINE_WIDTH} BYTES")

    if (INCLUDE_MEMORY) {
        val cache_mem = Module(new SimpleRAM(32, NUM_SETS * LINE_WIDTH / 4))
        cache.io.cache_mem <> cache_mem.io.bus
        cache_mem.io.bus <> cache.io.cache_mem
        cache_mem.io.dbg_addr := 0.U
        cache_mem.io.dbg_data_wr := 0.U
        cache_mem.io.dbg_we := 0.U

        io.cache_mem <> DontCare
    } else {
        cache.io.cache_mem <> io.cache_mem
    }
}
