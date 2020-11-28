from migen import *
from third_party import wishbone as wb

from soc import *
from util import *

from cpu import *
from io_control import *

from periphs import uart, i2c, pwm, spi, timer
from bus import wishbone_debug_bus, wishbone_bridge, wishbone_external
from debug import debug_mem, debug_probe, inst_buffer
from bus.wishbone_utils import *

from bootloader import bootrom

# Assuming byte-level addressing:
# 0xXXXX_XXXX = 4096 MiB
# 0x0XXX_XXXX =  256 MiB
# 0x00XX_XXXX =   16 MiB
# 0x000X_XXXX =    1 MiB
# 0x0000_XXXX =   64 KiB
# 0x0000_0XXX =    4 KiB

DMEM_SIZE = 2**17
IMEM_SIZE = 2**17

wb_address_map = {
    # Includes everything on the shared (slower) interconnect
    "periphs":    (0x0000_0000, 0x8000_0000, "byte", None, None,       None),

    # Low-speed memories: 0x0000_0000 to 0x4000_0000
    "bootrom":    (0x0000_0000, 0x0100_0000, "byte", None, None,       None),

    # Internal Peripherals: 0x4000_0000 to 0x6000_0000
    "ident":      (0x4000_0000, 0x4000_1000, "byte", None, "char",     None),

    "uptime":     (0x4000_1000, 0x4000_1100, "byte", None, "uint32_t", None),
    "timer0":     (0x4000_1100, 0x4000_1200, "byte", None, "uint32_t", None),
    "timer1":     (0x4000_1200, 0x4000_1300, "byte", None, "uint32_t", None),
    "timer2":     (0x4000_1300, 0x4000_1400, "byte", None, "uint32_t", None),
    "timer3":     (0x4000_1400, 0x4000_1500, "byte", None, "uint32_t", None),

    # I/O Peripherals: 0x6000_0000 to 0x8000_0000
    "ioctrl":     (0x6000_0000, 0x6000_1000, "byte", None, "uint32_t", None),

    "spi0":       (0x7000_0000, 0x7000_0100, "byte", None, "uint32_t", None),
    "spi1":       (0x7000_0100, 0x7000_0200, "byte", None, "uint32_t", None),

    "uart0":      (0x7000_1000, 0x7000_1100, "byte", None, "uint32_t", None),
    "uart1":      (0x7000_1100, 0x7000_1200, "byte", None, "uint32_t", None),

    "i2c0":       (0x7000_2000, 0x7000_2100, "byte", None, "uint32_t", None),

    "pwm0":       (0x7000_3000, 0x7000_3100, "byte", None, "uint32_t", None),
    "pwm1":       (0x7000_3100, 0x7000_3200, "byte", None, "uint32_t", None),
    "pwm2":       (0x7000_3200, 0x7000_3300, "byte", None, "uint32_t", None),
    "pwm3":       (0x7000_3300, 0x7000_3400, "byte", None, "uint32_t", None),
    "pwm4":       (0x7000_3400, 0x7000_3500, "byte", None, "uint32_t", None),
    "pwm5":       (0x7000_3500, 0x7000_3600, "byte", None, "uint32_t", None),

    # (Unused space): 0x8000_0000 to 0xC000_0000

    # Instruction memory
    "imem":       (0xC000_0000, 0xC000_0000+IMEM_SIZE, "word", None, "RAW", "RAW"),
    "dmem":       (0xD000_0000, 0xD000_0000+DMEM_SIZE, "word", None, "RAW", "RAW"),
}

# Final
debug_address_map = {
    "wb_bridge_debug":   (0x3020_0000, 0x3030_0000, "byte", None),
    "debug_probe_debug": (0x3040_0000, 0x3050_0000, "byte", None),
    "ioctrl_debug":      (0x3050_0000, 0x3060_0000, "byte", None),
}

FPGA_BUILD = False
NUM_IO = 20

IDENT = "PiFive SoC"

io_map = [
    ("sys_clk", 0, Pins("sys_clk")),
    ("sys_rst", 0, Pins("sys_rst")),

    *[(
        ("io{}".format(i), 0,
             Subsignal("i", Pins("io{}_i".format(i))),
             Subsignal("o", Pins("io{}_o".format(i))),
             Subsignal("oe", Pins("io{}_oe".format(i))),
        )
    ) for i in range(0, NUM_IO)],

    ("uart_main_dbg", 0,
        Subsignal("tx", Pins("uart_main_dbg_tx")),
        Subsignal("rx", Pins("uart_main_dbg_rx")),
    ),
]

class PiFive(SoC):
    def __init__(self, platform):
        debug_bus = wb.Interface(data_width=32, adr_width=32)
        CLK = int(25e6)

        super().__init__(
            platform, debug_controller=debug_bus,
            wishbone_delay_register=False
        )

        spi0_pads = make_pads_obj({
            "mosi": Signal(1),
            "miso": Signal(1),
            "clk":  Signal(1),
        })

        spi1_pads = make_pads_obj({
            "mosi": Signal(1),
            "miso": Signal(1),
            "clk":  Signal(1),
        })

        uart0_pads = make_pads_obj({
            "rx": Signal(1),
            "tx": Signal(1),
        })

        uart1_pads = make_pads_obj({
            "rx": Signal(1),
            "tx": Signal(1),
        })

        i2c0_pads = make_pads_obj({
            "sda_i":   Signal(1),
            "sda_o":   Signal(1),
            "sda_oen": Signal(1),
            "scl_i":   Signal(1),
            "scl_o":   Signal(1),
            "scl_oen": Signal(1),
        })

        pwm0_pad = Signal(1)
        pwm1_pad = Signal(1)
        pwm2_pad = Signal(1)
        pwm3_pad = Signal(1)
        pwm4_pad = Signal(1)
        pwm5_pad = Signal(1)

        # IO control setup
        # Input-only  = (input_wire, Signal(), Constant(0))
        # Output-only = (Signal(), output_wire, Constant(1))
        io_in  = lambda a, b, c: (a, b, c, Signal(), Constant(0))
        io_out = lambda a, b, c: (a, b, Signal(), c, Constant(1))

        UART_IO_IND = 1
        UART_RX_PORT = 0
        UART_TX_PORT = 1
        LED_PORT = 13

        io_config = [
            {
                "index": 0, "name": "GPIO0 / RX0", "mode": "standard", "sync": True,
                "options": [
                    io_in(UART_IO_IND, "uart", uart0_pads.rx),
                ],
            },
            {
                "index": 1, "name": "GPIO1 / TX0", "mode": "standard", "sync": True,
                "options": [
                    io_out(UART_IO_IND, "uart", uart0_pads.tx),
                ],
            },
            {
                "index": 2, "name": "GPIO2 / RX1", "mode": "standard", "sync": True,
                "options": [
                    io_in(UART_IO_IND, "uart", uart1_pads.rx),
                ],
            },
            {
                "index": 3, "name": "GPIO3 / TX1", "mode": "standard", "sync": True,
                "options": [
                    io_out(UART_IO_IND, "uart", uart1_pads.tx),
                ],
            },
            {
                "index": 4, "name": "GPIO4 / PWM0", "mode": "standard", "sync": True,
                "options": [
                    io_out(1, "pwm", pwm0_pad),
                ],
            },
            {
                "index": 5, "name": "GPIO5 / PWM1", "mode": "standard", "sync": True,
                "options": [
                    io_out(1, "pwm", pwm1_pad),
                ],
            },
            {
                "index": 6, "name": "GPIO6 / PWM2", "mode": "standard", "sync": True,
                "options": [
                    io_out(1, "pwm", pwm2_pad),
                ],
            },
            {
                "index": 7, "name": "GPIO7 / PWM3", "mode": "standard", "sync": True,
                "options": [
                    io_out(1, "pwm", pwm3_pad),
                ],
            },
            {
                "index": 8, "name": "GPIO8 / PWM4", "mode": "standard", "sync": True,
                "options": [
                    io_out(1, "pwm", pwm4_pad),
                ],
            },
            {
                "index": 9, "name": "GPIO9 / PWM5", "mode": "standard", "sync": True,
                "options": [
                    io_out(1, "pwm", pwm5_pad),
                ],
            },
            {
                "index": 10, "name": "GPIO10", "mode": "standard", "sync": True,
                "options": [],
            },
            {
                "index": 11, "name": "GPIO11 / SPI0-MOSI", "mode": "standard", "sync": True,
                "options": [
                    io_out(1, "spi", spi0_pads.mosi),
                ],
            },
            {
                "index": 12, "name": "GPIO12 / SPI0-MISO", "mode": "standard", "sync": True,
                "options": [
                    io_in(1, "spi", spi0_pads.miso),
                ],
            },
            {
                "index": 13, "name": "GPIO13 / SPI0-SCK", "mode": "standard", "sync": True,
                "options": [
                    io_out(1, "spi", spi0_pads.clk),
                ],
            },
            {
                "index": 14, "name": "GPIO14 / SPI1-MOSI", "mode": "standard", "sync": True,
                "options": [
                    io_out(1, "spi", spi1_pads.mosi),
                ],
            },
            {
                "index": 15, "name": "GPIO15 / SPI1-MISO", "mode": "standard", "sync": True,
                "options": [
                    io_in(1, "spi", spi1_pads.miso),
                ],
            },
            {
                "index": 16, "name": "GPIO16 / SPI0-SCK", "mode": "standard", "sync": True,
                "options": [
                    io_out(1, "spi", spi1_pads.clk),
                ],
            },
            {
                "index": 17, "name": "GPIO17", "mode": "standard", "sync": True,
                "options": [],
            },

            # I2C is open-collector, only output-enable when low
            {
                "index": 18, "name": "GPIO18 / I2C0-SDA", "mode": "standard", "sync": True,
                "options": [
                    (1, "i2c", i2c0_pads.sda_i, Constant(0), i2c0_pads.sda_o == 0),
                ],
            },
            {
                "index": 19, "name": "GPIO19 / I2C0-SCL", "mode": "standard", "sync": True,
                "options": [
                    (1, "i2c", i2c0_pads.scl_i, Constant(0), i2c0_pads.scl_o == 0),
                ],
            },

        ]

        assert len(io_config) == NUM_IO

        """I/O controller setup"""
        io_pins = {"io{}".format(i): platform.request("io{}".format(i)) for i in range(NUM_IO)}
        self.add_periph(IOControl(io_pins, io_config), "ioctrl")
        self.add_debug_periph(None, "ioctrl_debug", bus=self.ioctrl.debug_bus)

        """I/O peripherals"""
        self.add_periph(spi.SPI(spi0_pads), "spi0")
        self.add_periph(spi.SPI(spi1_pads), "spi1")

        self.add_periph(uart.UART(uart0_pads, fifo_depth=128), "uart0")
        self.add_periph(uart.UART(uart1_pads, fifo_depth=128), "uart1")

        self.add_periph(i2c.I2C(i2c0_pads, fifo_depth=8), "i2c0")

        self.add_periph(pwm.PWM(pwm0_pad), "pwm0")
        self.add_periph(pwm.PWM(pwm1_pad), "pwm1")
        self.add_periph(pwm.PWM(pwm2_pad), "pwm2")
        self.add_periph(pwm.PWM(pwm3_pad), "pwm3")
        self.add_periph(pwm.PWM(pwm4_pad), "pwm4")
        self.add_periph(pwm.PWM(pwm5_pad), "pwm5")

        """External memories"""
        # Disabled in this build - can be added as needed
        # Cached bus is read-only (designed to be used as an instruction-cache)
        # Uncached is read-write
        #self.submodules.ram = RAMSubsystem(platform.request("hyperram"), platform.request("cache_mem"))
        #self.add_mem(None, "hyperram0", bus=self.ram.bus_cached)
        #self.add_mem(None, "hyperram1", bus=self.ram.bus_uncached)

        """Internal memories"""
        self.add_periph(ROM(bootrom(
            ioctrl_addr = wb_address_map["ioctrl"][0],
            uptime_timer_addr = wb_address_map["uptime"][0],
            uart_addr = wb_address_map["uart0"][0],
            uart_io_ind = UART_IO_IND,
            rx_port = UART_RX_PORT,
            tx_port = UART_TX_PORT,
            led_port = LED_PORT,
            imem_base = wb_address_map["imem"][0],
            dmem_base = wb_address_map["dmem"][0],
            clk = CLK
        ), nullterm=False, endianness="little"), "bootrom")

        self.add_mem(wb.SRAM(IMEM_SIZE, bus=wb.Interface(data_width=32, adr_width=32)), "imem")
        self.add_mem(wb.SRAM(DMEM_SIZE, bus=wb.Interface(data_width=32, adr_width=32)), "dmem")

        """Misc non-I/O peripherals"""
        self.add_periph(ROM(IDENT), "ident")
        self.add_periph(timer.UptimeTimer(), "uptime")
        self.add_periph(timer.Timer(), "timer0")
        self.add_periph(timer.Timer(), "timer1")
        self.add_periph(timer.Timer(), "timer2")
        self.add_periph(timer.Timer(), "timer3")

        """Debug-related peripherals"""
        # Debug region is not necessary in final builds - it is primarily intended for inspecting and debugging CPU internals when the main system bus is congested or blocked

        #self.add_controller(wishbone_bridge.WishboneBridge(), "wb_bridge")
        #self.add_debug_periph(None, "wb_bridge_debug", bus=self.wb_bridge.debug_bus)
        #self.add_debug_periph(debug_probe.DebugProbe(probe_width=64, output_width=64), "debug_probe_debug")
        #self.add_controller(wishbone_debug_bus.WishboneDebugBus(platform.request("uart_debug_bus"), CLK, baud=115200), "wbdbgbus_debug")

        """External debug utilities"""
        self.add_controller(wishbone_debug_bus.WishboneDebugBus(platform.request("uart_main_dbg"), CLK, baud=115200), "wbdbgbus_main")

        """CPU Instantiation"""
        self.submodules.cpu = CPUWrapper()
        self.add_controller(None, "cpu_ibus", bus=self.cpu.instr_bus)
        self.add_controller(None, "cpu_dbus", bus=self.cpu.data_bus)

        # Fixed init PC
        self.comb += self.cpu.init_pc.eq(self.wb_address("bootrom")[0])

        # Only needed for debugging the CPU and busses on hardware
        #self.comb += self.cpu.stall_in.eq(self.debug_probe_debug.stall_out)
        #self.comb += self.debug_probe_debug.stall_in.eq(self.cpu.stall_out)
        #self.comb += self.cpu.cpu_reset.eq(self.debug_probe_debug.reset_out)
        #self.comb += self.debug_probe_debug.probe.eq(self.cpu.pc_out)

        self.comb += self.cpu.cpu_reset.eq(0)

        """Generate the bus"""
        main_mem_map, debug_mem_map = self.generate_bus()

        with open("build/mem_map.txt", "w+") as f:
            def println_both(x):
                print(x)
                f.write(x+"\n")

            println_both("Main Memory Map:")
            print_mem_map(main_mem_map, print_fn = println_both)
            println_both("")
            println_both("Debug Memory Map:")
            print_mem_map(debug_mem_map, print_fn = println_both)
            print()

        with open("build/platform.h", "w+") as f:
            def println_file(x):
                f.write(x+"\n")

            println_file("// THIS FILE IS AUTO-GENERATED AND SHOULD NOT BE EDITED BY HAND")
            println_file("#include <stdint.h>")
            println_file("")
            println_file("#ifndef PLATFORM_H")
            println_file("#define PLATFORM_H 1")
            println_file("")
            print_mem_map_defines(wb_address_map, print_fn = println_file)
            println_file("")
            print_io_map_defines(io_config, wb_address_map["ioctrl"][0], print_fn = println_file)
            println_file("#define CLK_FREQ        {}".format(CLK))
            println_file("#define CLKS_PER_MILLIS {}".format(CLK // 1000))
            println_file("")
            println_file("#endif")

        with open("build/platform_init.h", "w+") as f:
            def println_file(x):
                f.write(x+"\n")

            println_file("// THIS FILE IS AUTO-GENERATED AND SHOULD NOT BE EDITED BY HAND")
            println_file("")
            println_file("#ifndef PLATFORM_INIT_H")
            println_file("#define PLATFORM_INIT_H 1")
            println_file("")
            print_mem_map_defines(wb_address_map, print_fn = println_file, raw_only = True)
            println_file("#endif")

        with open("build/platform.ld", "w+") as f:
            def println_file(x):
                f.write(x+"\n")

            println_file("/* THIS FILE IS AUTO-GENERATED AND SHOULD NOT BE EDITED BY HAND */")
            println_file("")
            print_mem_map_ld(wb_address_map, print_fn = println_file)

    def wb_address(self, name):
        return wb_address_map.get(name)

    def debug_address(self, name):
        return debug_address_map.get(name)

    @classmethod
    def get_io(cls):
        return io_map
