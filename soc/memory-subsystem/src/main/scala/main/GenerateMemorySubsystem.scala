package main

import java.io.{BufferedWriter, File, FileWriter}

import chisel3.stage.ChiselStage
import mem.MemorySubsystem
import utils._

object GenerateMemorySubsystem extends App {
    val LINE_WIDTH = 32 // Bytes
    val NUM_SETS = 8

    val INCLUDE_MEMORY = false

    val build_dir = new File("build/")
    if (!build_dir.exists) build_dir.mkdirs

    val outfile = new File("build/MemorySubsystem.v")

    val BUILD_ARGS = Array(
        "--target-dir", "build"
    )

    val verilog = new ChiselStage().emitVerilog(
        new MemorySubsystem(LINE_WIDTH = LINE_WIDTH, NUM_SETS = NUM_SETS, INCLUDE_MEMORY = INCLUDE_MEMORY),
        args = BUILD_ARGS
    )

    val writer = new BufferedWriter(new FileWriter(outfile))
    writer.write(verilog)
    writer.close()
}
