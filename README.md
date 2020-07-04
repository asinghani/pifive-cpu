# RISC-V CPU

Design and verification of a simple hobby-grade 32-bit RISC-V CPU in SystemVerilog. This core takes advantage of several SystemVerilog features including structs, which are used to aid with passing data between the pipeline stages more easily (while still being optimized out by the synthesis tool when being built for the FPGA target). 

## Implementation Details

## Setup

The main module for this CPU is [rtl/cpu.sv](rtl/cpu.sv). It is a full SoC including all peripherals and memories. To embed it in an FPGA project, it must be wrapped in a top-level module (such as [rtl/top.sv](rtl/top.sv)) which handles the reset logic and 2FF-syncronization of all async inputs.

## Loading code

Code for this CPU can be written as C or ASM and built using gcc. A sample makefile and linker config can be seen at [software/blinky](software/blinky), and the memory map is defined at [mem/memory_controller.sv](mem/memory_controller.sv). Additional memory-mapped I/O can be added in [mem/mmio.sv](mem/mmio.sv). To load code onto the CPU, generate the `$PROGRAM-inst.hex` and `$PROGRAM-data.hex` files (the provided Makefiles generate these in a `build/` folder), and then run [scripts/program.py](scripts/program.py) with arguments `<Serial port> <Inst hex file> <Data hex file> <UART baud rate>`, which will reset the core and then upload the program.

## Notes on Synthesis

In order to be synthesizable across synthesis tools (tested with Vivado, Yosys, and Verilator), [zachjs/sv2v](https://github.com/zachjs/sv2v) is used to transpile SystemVerilog into pure Verilog. Additionally, no vendor-specific IP is used. Block RAMs and ROMs are inferred as sync-read, sync-write 36-bit wide RAMs (both Lattice ECP5 and Xilinx 7-Series chips support 36-bit wide BRAMs) and rely on the synthesis tools to techmap these to the correct BRAMs.

This design has been tested for synthesis on Lattice ECP5 (using yosys+nextpnr, with the provided Makefile) as well as Xilinx ZC7020 (using Vivado).
