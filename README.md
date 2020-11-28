# PiFive CPU & SoC Generator

32-bit RISC-V microcontroller designed in SystemVerilog, along with a fully automated SoC generator using Migen. This core achieves relatively-high performance while still being easy to integrate with many peripherals, and has been verified using the RISC-V test suite as well as being tested in hardware with various internal and external peripherals.

## Quickstart

```bash
git clone --recurse-submodules https://github.com/asinghani/pifive-cpu
cd pifive-cpu/

# For ULX3S board (yosys + nextpnr required)
cd fpga/ulx3s/
make ecppack
ujprog build/bitstream.bit
cd ../../

# For non-ULX3S board
cd soc/
make build/top.v
# Copy `build/top.v` into your preferred FPGA development environment and build the bitstream to your board (each of the I/Os on the top-level module, named `soc`, must be connected to a tristate I/O on the FPGA board)
# Upload the bitstream to the board

# For all boards
cd software/blinky
export PORT=/dev/ttyUSB0 # Change this to match the serial port that is connected (generally via a USB-UART breakout or similar) to I/Os 0 and 1 of the design
make upload
```

## CPU Core

The main CPU core is a 3-stage in-order pipeline (IF -> ID + EX -> MEM + WB) with data-forwarding and stall-handling. Branches are resolved (by design) during the ID+EX stage, which means that branches have zero overhead (the instruction fetched immediately after the branch instruction will always be correct, by design). It is a Harvard architecture, with one Wishbone bus for instructions and one for data, which allows it to run at the theoretical in-order maximum of 1 IPC.

The top-level CPU module is defined as follows (if using sv2v conversion, it will convert the wishbone busses into several ports of the format `instr_wb_<signal>` and `data_wb_<signal>`):
```verilog
module cpu #(
    parameter WISHBONE_PIPELINED = 0  // Whether to use a pipelined or classic wishbone bus
) (
    Wishbone.Controller instr_wb,
    Wishbone.Controller data_wb,

    // Intended for debug purposes only
    // i_stall_in should be fixed to a hardcoded 0 when the CPU is being used
    input wire i_stall_in,
    output wire o_stall_out,
    output wire [31:0] o_pc_out,

    // In most cases, this should be connected to a hardcoded value which is the initial program counter value for the CPU (in some rare cases this may need to be dynamic, however it must be connected to a register which does NOT reset along with the CPU, as it will be read immediately after `i_rst` is de-asserted).
    input wire [31:0] i_init_pc,

    input wire i_rst,
    input wire i_clk
);
```

The core is verified using the RISC-V test suite and a set of PyVerilator (must use [my custom fork](https://github.com/asinghani/pyverilator)) scripts which run the core through each test and produce a verification report as well as a basic benchmark of runtime (in # of cycles). To run the test suite:
```bash
cd cpu
make test
```

## SoC Architecture

The SoC is generated using a custom generator written in [Migen HDL](https://github.com/m-labs/migen), which pulls together the CPU, peripherals, and crossbar and creates the address mapping and the platform-support files needed to compile software for the core.

The included peripherals are as follows:
- I2C (uses [this core](https://github.com/alexforencich/verilog-i2c))
- PWM
- SPI
- Timer - Single-shot / multi-shot / countdown modes
- UptimeTimer - Clock cycles since startup
- UART
- HyperRAM
    - The HyperRAM controller includes a bursting instruction-cache (read-only), and a direct write-through bridge from wishbone to the HyperRAM interface
    - Requires Chisel3 to compile the HyperRAM support portion of the design (disabled by default)
- WishboneDebugBus - Allows external access (via an extra UART) to the system wishbone bus for debug purposes
- IOControl - Multiplexes the I/O ports between the different peripherals, as well as controlling their use as bit-banged GPIO ports
- ROM - Used for boot ROM and design identifier information
- SRAM - Mapped to the FPGA's built-in Block RAM

There is also a small bootloader which is written in assembly (see `soc/rtl/bootloader.py`), generated at build-time using Python (so the peripheral memory addresses can be substituted into the bootloader as necessary), and placed into a wishbone-accessible ROM (because the bootloader is not performance-sensitive, it is placed on the slower shared-interconnect).

The SoC has a triple-bus structure (the crossbar/shared-interconnect split is used to reduce resource utilization, and the debug bus makes it easier to probe the CPU when implemented in hardware):
1. Memory bus (crossbar)
    - Memories / Cache
    - All controllers

2. Peripheral bus (shared interconnect)
    - Low-performance peripherals
    - Connected to memory bus

3. Debug bus
    - Debug utilities, and bridge onto main bus
    - Controlled by external debug core

The file `soc/rtl/pifive.py` declares the SoC architecture:
- It begins by creating a memory map, where each peripheral is assigned a base address, an end address, an addressing-mode (some peripherals assume byte-level addressing while others assume word-level addressing), a custom translation function (if needed), and whether to include the peripheral in the platform-support header file.
- It then defines the ports of the SoC (including the I/O pins, which are all tristate, as well as the clock, reset, and optionally the debug UART).
- Based on the defined ports, the I/O config is created, which defines which peripherals each I/O port should be able to switch between (by default, each I/O functions only as a GPIO, but it can be configured such that the software is able to switch it between multiple different peripherals).
- The I/O controller and other peripherals are instantiated and added using `add_periph`, which adds them to the shared interconnect.
- The high-performance memories (data and instruction SRAMs) are instantiated and added using `add_mem`, which places them on the crossbar interconnect.
- The CPU itself is instantiated and its busses are connected to the crossbar
- The bus is actually generated - a crossbar is generated with each of the memories as peripherals, as well as a bridge to the shared interconnect (to reduce resource utilization).
- The `platform.h`, `platform_init.h`, and `platform.ld` support files are created. These files contain information about the supported I/O modes and the addresses of the MMIO peripherals, and must be used when compiling software for the CPU.
- Once the entire SoC has been constructed, it is transformed into verilog and written out to a file (to be used for the FPGA build).

Full directory structure of SoC:
```
soc
├── Makefile
├── memory-subsystem - Chisel3 project containing the wishbone -> HyperRAM bridge and instruction cache
│   ├── Makefile
│   ├── build.sbt
│   ├── project
│   ├── src
│   └── testcases
├── rtl
│   ├── bootloader.py - Bootloader for loading programs onto the CPU
│   ├── build.py - Top-level program to build the SoC and generate verilog
│   ├── bus
│   │   ├── wishbone_bridge.py
│   │   ├── wishbone_debug_bus.py
│   │   ├── wishbone_external.py
│   │   └── wishbone_utils.py
│   ├── cpu.py - Wrapper for the CPU itself (into a Migen class with a wishbone port)
│   ├── debug - Debug-bus related modules
│   │   ├── debug_mem.py
│   │   ├── debug_probe.py
│   │   └── inst_buffer.py
│   ├── io_control.py - Multiplexes I/Os between peripherals and allows software control of GPUO
│   ├── periphs
│   │   ├── i2c.py
│   │   ├── pwm.py
│   │   ├── ram_subsystem.py
│   │   ├── spi.py
│   │   ├── timer.py
│   │   └── uart.py
│   ├── pifive.py - Defines the actual SoC itself and connects all the peripherals
│   ├── soc.py - Generic SoC class - handles bus configuration given the list of peripherals
│   ├── third_party
│   │   └── wishbone.py - Wrapper for wishbone bus, SRAM, Arbiter, and Decoder (from LiteX)
│   ├── util.py
│   └── verilog - Verilog modules (for UART and DebugBus)
│       ├── sync_2ff.sv
│       ├── uart_fifo.sv
│       ├── uart_rx.sv
│       ├── uart_tx.sv
│       ├── wbdbgbus.sv
│       └── wbuart.sv
└── third_party - Third-party modules used as SoC peripherals
    ├── hyperram
    ├── spi-controller
    │   └── spi_controller.v
    └── verilog-i2c
```

To run a generic build of the SoC:
```bash
cd soc/
make build/top.v
```

## FPGA Build

The targeted FPGA platform is currently the [ULX3S](https://radiona.org/ulx3s/) (Lattice ECP5, using yosys+nextpnr), although no FPGA-specific features are used by the design, so it can be synthesized for almost any FPGA.

To build for ULX3S:
```bash
cd fpga/ulx3s/
make ecppack
# The bitstream will be generated in `build/bitstream.bit` (defaults to the 85F variant, although this can be changed by editing line 6 of the Makefile).

# To upload:
ujprog build/bitstream.bit
```

The utilization report for the design on ECP5 is below (for the default config which is in `soc/rtl/pifive.py`):
```
======= LUT & DFF Breakdown =======
Total LUT4s:     17098/83640    20%
    logic LUTs:  13278/83640    15%
    carry LUTs:   3274/83640     3%
      RAM LUTs:    364/41820     0%
     RAMW LUTs:    182/20910     0%
Total DFFs:       9140/83640    10%


======== Total Utilization ========
TRELLIS_SLICE: 10840/41820      25%
       DP16KD:   128/  208      61%
   MULT18X18D:     2/  156       1%
```

As such, it can fit onto any of the ECP5 parts, including the 12F (assuming yosys+nextpnr is used to build).

The SoC's IO pins (IO0-IO19) are connected to the ULX3S's GP0-GP19 pins respectively. IOs 4 and 5 (PWM 0 and 1) are mirrored to the audio jack (for left and right channel respectively), and IOs 13-19 are mirrored to the board's indicator LEDs. The `PWR` button is used to reset the SoC (it is active-low). The USB-UART bridge on the board is used for debugging - it is connected to a [wbdbgbus](https://github.com/asinghani/wbdbgbus) which has full access to the SoC's internal wishbone bus.

## Software Samples

There are several test programs in the `software` directory which can be used to test the functionality of the full SoC in hardware. They can be uploaded to the CPU (assuming the CPU has been loaded and the bootloader is running) as follows:
```bash
cd software/<desired design>/
export PORT=/dev/ttyUSB0 # Change this to match the serial port that is connected (generally via a USB-UART breakout or similar) to I/Os 0 and 1 of the design

# To just upload and start the program on the CPU
make upload

# To upload and start the program, and then open a serial terminal (at 115200 baud) to watch the program's output
make test
```

- `blinky` - Blinks an LED on pin 13 - Demonstrates GPIO out and timer peripherals
- `brightness` - Controls brightness of LED on pin 7 (PWM 3) using buttons on pins 10 and 11 - Demonstrates GPIO in, PWM (direct control mode), and timer peripherals
- `pi` - Computes digits of the irrational number pi using the Taylor series expansion for `4 * arctan(1)` (using only 32-bit integer arithmetic)
- `servo` - Sweeps a servo motor on pin 6 (PWM 2) back and forth - Demonstrates GPIO out, PWM (servo mode), and timer peripherals
- `temperature` - Gets the current temperature from a [TMP102](https://www.sparkfun.com/products/16304) sensor over I2C and displays it over UART to the user (also allows the user to select between units by sending `F` or `C` over the UART) - Demonstrates I2C, timer, and UART (both transmit and receive) peripherals
- `tone` - Plays a short tune through a speaker or buzzer connected to pin 4 (PWM 0) - Demonstrates PWM (tone mode) and timer peripherals

# License

[Apache-2.0](LICENSE)
