package tests

import java.util.Random

import cache.ICache
import chisel3._
import chisel3.iotesters.PeekPokeTester
import test.{FakeHyperRAM, SimpleRAM}
import utils.MathUtils._
import chisel3._
import chisel3.util._
import mem.Wishbone
import utils._

class ICacheTestHarness extends Module {
    val io = IO(new Bundle {
        val flush_all = Input(Bool())
        val busy = Output(Bool())
        val bus = new Wishbone(32, INCLUDE_ERR = true)
    })

    val LINE_WIDTH = 32
    val NUM_SETS = 8

    // Addr: TTTT SS OOO
    // Tag, Set, Offset
    val cache = Module(new ICache(32, LINE_WIDTH, NUM_SETS))
    cache.io.bus <> io.bus
    cache.io.flush_all <> io.flush_all
    cache.io.busy <> io.busy

    val cache_mem = Module(new SimpleRAM(32, NUM_SETS * LINE_WIDTH / 4))
    cache.io.cache_mem <> cache_mem.io.bus
    cache_mem.io.bus <> cache.io.cache_mem
    cache_mem.io.dbg_addr := 0.U
    cache_mem.io.dbg_data_wr := 0.U
    cache_mem.io.dbg_we := 0.U

    val main_mem = Module(new FakeHyperRAM(32, 4096, "testcases/cache_test.txt"))
    cache.io.main_mem <> main_mem.io.bus
    main_mem.io.dbg_addr := 0.U
    main_mem.io.dbg_data_wr := 0.U
    main_mem.io.dbg_we := 0.U
}

class ICacheTest(dut: ICacheTestHarness) extends PeekPokeTester(dut) {

    def wb_read(addr: Int) : (BigInt, Int) = {
        var latency = 0
        poke(dut.io.bus.cyc, 1)
        poke(dut.io.bus.stb, 1)
        poke(dut.io.bus.we, 0)
        poke(dut.io.bus.addr, addr)
        step(1)
        latency += 1
        poke(dut.io.bus.cyc, 0)
        poke(dut.io.bus.stb, 0)
        poke(dut.io.bus.addr, 0)
        while (peek(dut.io.bus.ack) == 0) {
            expect(dut.io.bus.err, 0)
            step(1)
            latency += 1
        }
        expect(dut.io.bus.ack, 1)
        expect(dut.io.bus.err, 0)
        val out = peek(dut.io.bus.data_rd)

        (out, latency)
    }

    // Generate test data to match init file
    val BIG_PRIME = BigInt(8078431l)
    val OFFSET = BigInt(48918939481l)
    val MASK = BigInt(0xFFFFFFFFl)
    val data = (0 until 4096).map(x => (OFFSET + BigInt(x) * BIG_PRIME) & MASK)

    poke(dut.io.flush_all, 0)
    while (peek(dut.io.busy) == 1) { step(1) }

    poke(dut.io.bus.cyc, 0)
    poke(dut.io.bus.stb, 0)

    println("Round 1:")
    for (i <- 0 until 32) {
        val (out, latency) = wb_read(4*i)
        assert(out == data(i))
        println(s"Read addr=$i latency=$latency value=${out.toString(16)} expected=${data(i).toString(16)}")
    }

    println("Round 2:")

    for (i <- (0 until 16)) {
        val (out, latency) = wb_read(4*i)
        assert(out == data(i))
        println(s"Read addr=$i latency=$latency value=${out.toString(16)} expected=${data(i).toString(16)}")
    }

    for (i <- 0 until 16) {
        val (out, latency) = wb_read(4*i)
        assert(out == data(i))
        println(s"Read addr=$i latency=$latency value=${out.toString(16)} expected=${data(i).toString(16)}")
    }

    println("Round 3:")

    for (i <- 16 until 32) {
        val (out, latency) = wb_read(4*i)
        assert(out == data(i))
        println(s"Read addr=$i latency=$latency value=${out.toString(16)} expected=${data(i).toString(16)}")
    }

    poke(dut.io.flush_all, 1)
    step(1)
    poke(dut.io.flush_all, 0)

    for (i <- 16 until 32) {
        val (out, latency) = wb_read(4*i)
        assert(out == data(i))
        println(s"Read addr=$i latency=$latency value=${out.toString(16)} expected=${data(i).toString(16)}")
    }

    for (i <- 0 until 16) {
        val (out, latency) = wb_read(4*i)
        assert(out == data(i))
        println(s"Read addr=$i latency=$latency value=${out.toString(16)} expected=${data(i).toString(16)}")
    }

    for (i <- (0 until 16).reverse) {
        val (out, latency) = wb_read(4*i)
        assert(out == data(i))
        println(s"Read addr=$i latency=$latency value=${out.toString(16)} expected=${data(i).toString(16)}")
    }

    for (_ <- (0 until 512)) {
        val i = new Random().nextInt(128)
        val (out, latency) = wb_read(4*i)
        assert(out == data(i))
        println(s"Read addr=$i latency=$latency value=${out.toString(16)} expected=${data(i).toString(16)}")
    }

    for (i <- Pb(0 until 4096)) {
        val (out, latency) = wb_read(4*i)
        assert(out == data(i))
    }

    for (_ <- Pb(0 until 20000)) {
        val i = new Random().nextInt(4096)
        val (out, latency) = wb_read(4*i)
        assert(out == data(i))
    }
}
