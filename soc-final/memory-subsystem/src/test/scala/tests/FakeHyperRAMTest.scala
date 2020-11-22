package tests

import chisel3._
import chisel3.iotesters.PeekPokeTester
import chisel3.util._
import test.FakeHyperRAM
import utils.MathUtils._
import utils._

import scala.util.Random

class FakeHyperRAMTest(dut: FakeHyperRAM) extends PeekPokeTester(dut) {
    assert(dut.N == 32)
    assert(dut.DEPTH >= 256)
    assert(dut.INIT_FILE.contains("fake_hyperram_test"))

    val data = Array(0xDEADBEEFl, 0x12345678l, 0xABCDABCDl, 0x9876FFFFl)

    poke(dut.io.bus.rd_req, 0)
    poke(dut.io.bus.wr_req, 0)
    poke(dut.io.bus.mem_or_reg, 0)
    poke(dut.io.bus.wr_byte_en, b"1111")

    poke(dut.io.dbg_we, 0)
    poke(dut.io.dbg_addr, 0)
    step(1)
    expect(dut.io.dbg_data_rd, data(0))

    poke(dut.io.dbg_addr, 1)
    step(1)
    expect(dut.io.dbg_data_rd, data(1))

    poke(dut.io.bus.rd_req, 1)
    poke(dut.io.bus.rd_num_dwords, 1)
    poke(dut.io.bus.addr, 0)
    step(1)
    poke(dut.io.bus.rd_req, 0)
    while (peek(dut.io.bus.rd_rdy) == 0) { step(1) }
    expect(dut.io.bus.rd_d, data(0))
    while (peek(dut.io.bus.busy) == 1) {
        step(1)
        expect(dut.io.bus.rd_rdy, 0)
    }

    for (_ <- 0 until 500) {
        step(1)
        expect(dut.io.bus.rd_rdy, 0)
        expect(dut.io.bus.busy, 0)
    }

    poke(dut.io.bus.rd_req, 1)
    poke(dut.io.bus.rd_num_dwords, 16)
    poke(dut.io.bus.addr, 0)
    step(1)
    poke(dut.io.bus.rd_req, 0)
    for (i <- (0 until 16)) {
        while (peek(dut.io.bus.rd_rdy) == 0) { step(1) }
        expect(dut.io.bus.rd_d, data(i % data.length))
        step(1)
    }
    while (peek(dut.io.bus.busy) == 1) {
        step(1)
        expect(dut.io.bus.rd_rdy, 0)
    }

    for (_ <- 0 until 500) {
        step(1)
        expect(dut.io.bus.rd_rdy, 0)
        expect(dut.io.bus.busy, 0)
    }
}
