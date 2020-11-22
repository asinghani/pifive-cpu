package main

import tests._
import chisel3._
import chisel3.internal.LegacyModule
import test.FakeHyperRAM

object Main extends App {
    val EXEC_CONFIG = Array(
        "--backend-name", "verilator",
        "--generate-vcd-output", "on",
        "--target-dir", "test_build",
        "-tn", "test_build",
        "--no-dce"
    )

    /**
     * Format:
     * "name" -> (() => new Dut,
     *            (dut: LegacyModule) => new DutTest(dut.asInstanceOf[Dut])),
     */
    val TESTS = Map(
        "fake_hyperram_test" -> (() => new FakeHyperRAM(32, 512, "testcases/fake_hyperram_test.txt"),
            (dut: LegacyModule) => new FakeHyperRAMTest(dut.asInstanceOf[FakeHyperRAM])),
        "icache_test" -> (() => new ICacheTestHarness,
            (dut: LegacyModule) => new ICacheTest(dut.asInstanceOf[ICacheTestHarness])),
        "wishbone_mem_test" -> (() => new WishboneMemBridgeTestHarness,
            (dut: LegacyModule) => new WishboneMemBridgeTest(dut.asInstanceOf[WishboneMemBridgeTestHarness])),
    )

    var passed_tests = Array[String]()
    var failed_tests = Array[String]()

    // Args should be list of tests to run
    val tests_to_run = if (args(0) == "all") { TESTS.keys.toArray } else { args }
    for (test_name <- tests_to_run) {
        if (TESTS.contains(test_name)) {
            val (dut_func, tester_func) = TESTS(test_name)
            println("=" * 60)
            println("Running test "+test_name)
            println("=" * 60)

            val passed = iotesters.Driver.execute(EXEC_CONFIG, dut_func) { tester_func }

            if (passed) {
                println(Console.GREEN + "PASSED TEST " + test_name + Console.RESET)
                println()
                passed_tests = passed_tests :+ test_name
            } else {
                println(Console.RED_B + Console.BLUE + "FAILED TEST " + test_name + Console.RESET)
                println()
                failed_tests = failed_tests :+ test_name
            }

        } else {
            println(Console.YELLOW + "Warning: skipping unknown test " + test_name + Console.RESET)
            println()
        }
    }

    if (passed_tests.length != 0) {
        println(Console.GREEN + "PASSED TESTS: " + passed_tests.mkString(", ") + Console.RESET)
    }

    if (failed_tests.length != 0) {
        println(Console.RED_B + Console.BLUE + "FAILED TESTS: " + failed_tests.mkString(", ") + Console.RESET)
    } else {
        println(Console.GREEN + "PASSED ALL TESTS!" + Console.RESET)
    }

}