from migen import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.interconnect import wishbone as wb

from litex.soc.cores.gpio import GPIOIn, GPIOOut
from spi_flash import *

from soc import *
from util import *
from wishbone_debug_bus import *
from wishbone_uart import *
from wishbone_i2c import *
from wishbone_pwm import *
from wishbone_spi import *
from wishbone_bridge import *
from wishbone_external import *
from debug_mem import *
from debug_probe import *
from inst_buffer import *
from io_control import *
from cpu import *
from timer import *

from litespi.modules import IS25LP032
from litespi.opcodes import SpiNorFlashOpCodes as Codes
from litespi.phy.generic import LiteSPIPHY
from litespi import LiteSPI

from simpleriscv import asm
import subprocess

from ram_subsystem import RAMSubsystem

from litex.soc.interconnect.csr import *

CACHE_ADDR_WIDTH = 14

csr_address_map = {
    "leds":        0x8800_0000,
    "btns":        0x8800_0400,
    "test_out":    0x8800_0800,
    #"spi0":        0x8800_0C00,
    "cpu_disable": 0x8810_0000,

    "spiflash_mmap": 0x8888_0000,
    "spiflash_csr": 0x8888_1000,
    "spiflash": 0x8888_2000,
}

# Assuming byte-level addressing:
# 0xXXXX_XXXX = 4096 MiB
# 0x0XXX_XXXX =  256 MiB
# 0x00XX_XXXX =   16 MiB
# 0x000X_XXXX =    1 MiB
# 0x0000_XXXX =   64 KiB
# 0x0000_0XXX =    4 KiB

wb_address_map = {
    "bootrom":    (0x0000_0000, 0x0100_0000, "byte", None),
    "blinky":     (0x0100_0000, 0x0200_0000, "byte", None),
    "dram":       (0x4000_0000, 0x5000_0000, "word", None),

    "hyperram0":  (0xA000_0000, 0xB000_0000, "byte", None),
    "hyperram1":  (0xC000_0000, 0xD000_0000, "byte", None),

    "ibuffer":    (0x5000_0000, 0x5000_1000, "byte", None),
    "spiflash":   (0x6000_0000, 0x6100_0000, "byte", None),

    "scratch0":   (0x6100_0000, 0x6200_0000, "word", None),
    "scratch1":   (0x6200_0000, 0x6300_0000, "word", None),

    "periphs":    (0x8000_0000, 0x8800_0000, "byte", None),
    "user_ident": (0x8000_0000, 0x8000_0100, "byte", None),
    "uart":       (0x8000_0100, 0x8000_0200, "byte", None),
    "i2c":        (0x8000_0200, 0x8000_0300, "byte", None),

    "pwm0":       (0x8000_1000, 0x8000_1010, "byte", None),
    "pwm1":       (0x8000_1010, 0x8000_1020, "byte", None),

    "ioctrl":     (0x8100_0000, 0x8101_0000, "byte", None),

    "timer0":     (0x8000_2000, 0x8000_2020, "byte", None),
    "timer1":     (0x8000_2020, 0x8000_2040, "byte", None),
    "uptime":     (0x8000_2040, 0x8000_2060, "byte", None),

    "spi0":       (0x8000_3000, 0x8000_3020, "byte", None),

    "csrs":       (0x8800_0000, 0x8900_0000, "byte", None),

    "dbgmem":     (0xD000_0000, 0xE000_0000, "byte", None),
}

#instr_memories = ["dram", "hyperram0", "ibuffer", "scratch0", "scratch1"]
instr_memories = ["hyperram0", "ibuffer"]

mgmt_address_map = {
    "mgmt_ident":    (0x3000_0000, 0x3000_0100, "byte", None),
    "ibuffer_mgmt":  (0x4000_0000, 0x4000_1000, "byte", None),
    "wb_bridge_dbg": (0x4000_1000, 0x4000_2000, "byte", None),
    "dbgmem_mgmt":   (0x4000_8000, 0x4000_9000, "byte", None),
    "debug_probe":   (0x5000_0000, 0x5000_1000, "byte", None),
    "ioctrl_mgmt":   (0x8100_0000, 0x8101_0000, "byte", None),
}

NUM_IO = 38

io_map = [
    ("sys_clk", 0, Pins(1)),
    ("sys_rst", 0, Pins(1)),

    *[(
        ("io{}".format(i), 0,
             Subsignal("i", Pins(1)),
             Subsignal("o", Pins(1)),
             Subsignal("oe", Pins(1)),
        )
    ) for i in range(0, NUM_IO)],

    # TODO temp remove
    ("led", 0, Pins(8)),

    ("uart_user_dbg", 0,
        Subsignal("tx", Pins(1)),
        Subsignal("rx", Pins(1)),
    ),

    ("uart_mgmt_dbg", 0,
        Subsignal("tx", Pins(1)),
        Subsignal("rx", Pins(1)),
    ),

    ("scratch0", 0,
        Subsignal("cyc", Pins(1)),
        Subsignal("stb", Pins(1)),
        Subsignal("addr", Pins(32)),
        Subsignal("data_wr", Pins(32)),
        Subsignal("data_rd", Pins(32)),
        Subsignal("sel", Pins(4)),
        Subsignal("we", Pins(1)),
        Subsignal("ack", Pins(1)),
        Subsignal("err", Pins(1)),
    ),

    ("scratch1", 0,
        Subsignal("cyc", Pins(1)),
        Subsignal("stb", Pins(1)),
        Subsignal("addr", Pins(32)),
        Subsignal("data_wr", Pins(32)),
        Subsignal("data_rd", Pins(32)),
        Subsignal("sel", Pins(4)),
        Subsignal("we", Pins(1)),
        Subsignal("ack", Pins(1)),
        Subsignal("err", Pins(1)),
    ),

    ("cache_mem", 0,
        Subsignal("addr", Pins(CACHE_ADDR_WIDTH)),
        Subsignal("data_rd", Pins(32)),
        Subsignal("data_wr", Pins(32)),
        Subsignal("we", Pins(1)),
        Subsignal("we_sel", Pins(4)),
    ),
]

class PiFive(SoC):
    def __init__(self, platform):
        mgmt_bus = wb.Interface(data_width=32, adr_width=32)
        super().__init__(
            platform, mgmt_controller=mgmt_bus,
            wishbone_delay_register=False
        )

        hr_pads = make_pads_obj({
            "dq_i": Signal(8),
            "dq_o": Signal(8),
            "dq_oe": Signal(1),

            "rwds_i": Signal(1),
            "rwds_o": Signal(1),
            "rwds_oe": Signal(1),

            "ck": Signal(1),
            "rst_n": Signal(1),
            "cs_n": Signal(1),
        })

        spi_pads = make_pads_obj({
            "mosi": Signal(1),
            "miso": Signal(1),
            "clk": Signal(1),
        })

        # IO control setup
        # Input-only  = (input_wire, Signal(), Constant(0))
        # Output-only = (Signal(), output_wire, Constant(1))
        io_config = [
            {
                "index": 0, "name": "gpio0 / spi_mosi", "mode": "standard", "sync": True,
                "options": [
                    (1, "spi", Signal(), spi_pads.mosi, Constant(1)),
                ],
            },
            {
                "index": 1, "name": "gpio1 / spi_miso", "mode": "standard", "sync": True,
                "options": [
                    (1, "spi", spi_pads.miso, Signal(), Constant(0)),
                ],
            },
            {
                "index": 2, "name": "gpio2 / spi_clk", "mode": "standard", "sync": True,
                "options": [
                    (1, "spi", Signal(), spi_pads.clk, Constant(1)),
                ],
            },

            *[{
                "index": i, "name": "gpio{}".format(i), "mode": "standard", "sync": True,
                "options": [],
            } for i in range(3, 6)],

            {
                "index": 6, "name": "hr_dq0", "mode": "passthrough", "sync": False,
                "passthrough": (hr_pads.dq_i[0], hr_pads.dq_o[0], hr_pads.dq_oe),
            },

            {
                "index": 7, "name": "hr_dq1", "mode": "passthrough", "sync": False,
                "passthrough": (hr_pads.dq_i[1], hr_pads.dq_o[1], hr_pads.dq_oe),
            },

            {
                "index": 8, "name": "hr_dq2", "mode": "passthrough", "sync": False,
                "passthrough": (hr_pads.dq_i[2], hr_pads.dq_o[2], hr_pads.dq_oe),
            },

            {
                "index": 9, "name": "hr_dq3", "mode": "passthrough", "sync": False,
                "passthrough": (hr_pads.dq_i[3], hr_pads.dq_o[3], hr_pads.dq_oe),
            },

            {
                "index": 10, "name": "hr_dq4", "mode": "passthrough", "sync": False,
                "passthrough": (hr_pads.dq_i[4], hr_pads.dq_o[4], hr_pads.dq_oe),
            },

            {
                "index": 11, "name": "hr_dq5", "mode": "passthrough", "sync": False,
                "passthrough": (hr_pads.dq_i[5], hr_pads.dq_o[5], hr_pads.dq_oe),
            },

            {
                "index": 12, "name": "hr_dq6", "mode": "passthrough", "sync": False,
                "passthrough": (hr_pads.dq_i[6], hr_pads.dq_o[6], hr_pads.dq_oe),
            },

            {
                "index": 13, "name": "hr_dq7", "mode": "passthrough", "sync": False,
                "passthrough": (hr_pads.dq_i[7], hr_pads.dq_o[7], hr_pads.dq_oe),
            },

            {
                "index": 14, "name": "hr_rwds", "mode": "passthrough", "sync": False,
                "passthrough": (hr_pads.rwds_i, hr_pads.rwds_o, hr_pads.rwds_oe),
            },

            {
                "index": 15, "name": "hr_ck", "mode": "passthrough", "sync": False,
                "passthrough": (Signal(), hr_pads.ck, Constant(1)),
            },

            {
                "index": 16, "name": "hr_rst_n", "mode": "passthrough", "sync": False,
                "passthrough": (Signal(), hr_pads.rst_n, Constant(1)),
            },

            {
                "index": 17, "name": "hr_cs_n", "mode": "passthrough", "sync": False,
                "passthrough": (Signal(), hr_pads.cs_n, Constant(1)),
            },

            *[{
                "index": i, "name": "gpio{}".format(i), "mode": "standard", "sync": True,
                "options": [],
            } for i in range(18, NUM_IO)]
        ]

        """I/O controller setup"""
        io_pins = {"io{}".format(i): platform.request("io{}".format(i)) for i in range(NUM_IO)}
        self.add_periph(IOControl(io_pins, io_config), "ioctrl")
        self.add_mgmt_periph(None, "ioctrl_mgmt", bus=self.ioctrl.debug_bus)

        """I/O peripherals"""
        self.add_periph(WishboneSPI(spi_pads), "spi0")

        """External memories"""
        self.submodules.ram = RAMSubsystem(hr_pads, platform.request("cache_mem"))
        self.add_mem(None, "hyperram0", bus=self.ram.bus_cached)
        self.add_mem(None, "hyperram1", bus=self.ram.bus_uncached)

        """Internal memories"""
        self.add_mem(WishboneROM(bootrom(), nullterm=False, endianness="little"), "bootrom")
        self.add_mem(WishboneROM(blinky(), nullterm=False, endianness="little"), "blinky")

        self.add_mem(InstBuffer(size=8), "ibuffer")
        self.add_mgmt_periph(None, "ibuffer_mgmt", bus=self.ibuffer.debug_bus)

        #self.add_mem(WishboneExternal(platform.request("scratch0")), "scratch0")
        #self.add_mem(WishboneExternal(platform.request("scratch1")), "scratch1")

        """Misc non-I/O user-side peripherals"""
        self.add_periph(WishboneROM("Test SoC User Space"), "user_ident")
        self.add_periph(UptimeTimer(), "uptime")
        self.add_periph(Timer(), "timer0")
        self.add_periph(Timer(), "timer1")

        """Management-core-side peripherals"""
        self.add_controller(WishboneBridge(), "wb_bridge")
        self.add_mgmt_periph(None, "wb_bridge_dbg", bus=self.wb_bridge.debug_bus)

        self.add_mem(DebugMemory(), "dbgmem")
        self.add_mgmt_periph(None, "dbgmem_mgmt", bus=self.dbgmem.debug_bus)

        self.add_mgmt_periph(WishboneROM("Test SoC Mgmt Space"), "mgmt_ident")

        self.add_mgmt_periph(DebugProbe(probe_width=64, output_width=64), "debug_probe")
        self.comb += self.ram.flush_all.eq(self.debug_probe.flush_out)

        # TODO remove
        #self.comb += self.debug_probe.probe.eq(self.debug_probe.output[::-1])

        """Temporary debug utilities (for testing only)"""
        tmp_clk = int(25e6)
        self.add_controller(WishboneDebugBus(platform.request("uart_user_dbg"), tmp_clk, baud=115200), "debugbus")
        self.submodules.dbg_timeout = WishboneTimeout(self.debugbus.bus, timeout_cycles=10000, return_error=False)
        #self.comb += platform.request("led").eq(Mux(self.debugbus.ctr[0:9] == self.debugbus.ctr, self.debugbus.ctr >> 1, Constant(255)))
        self.submodules.mgmt_ctrl = WishboneDebugBus(platform.request("uart_mgmt_dbg"), tmp_clk, baud=115200)
        self.sync += self.mgmt_ctrl.bus.connect(mgmt_bus)
        self.add_csr(GPIOOut(platform.request("led")), "leds")

        """CPU Instantiation"""
        self.submodules.cpu = CPUWrapper()
        self.add_controller(None, "cpu_ibus", bus=self.cpu.instr_bus)
        self.add_controller(None, "cpu_dbus", bus=self.cpu.data_bus)
        self.submodules.cpu_dbus_timeout = WishboneTimeout(self.cpu.data_bus, timeout_cycles=1000000, return_error=True)
        self.comb += self.cpu.init_pc.eq(self.wb_address("bootrom")[0])

        self.comb += self.cpu.stall_in.eq(self.debug_probe.stall_out)
        self.comb += self.debug_probe.stall_in.eq(self.cpu.stall_out)
        self.comb += self.cpu.cpu_reset.eq(self.debug_probe.reset_out)

        self.comb += self.debug_probe.probe.eq(self.cpu.pc_out)

        """Generate the bus!"""
        main_mem_map, mgmt_mem_map = self.generate_bus()

        print("Main Memory Map:")
        print_mem_map(main_mem_map)
        print()
        print()
        print("Mgmt Memory Map:")
        print_mem_map(mgmt_mem_map)
        print()

    def csr_address(self, name):
        if name is None:
            return csr_address_map.values()
        else:
            return csr_address_map.get(name)

    def wb_address(self, name):
        return wb_address_map.get(name)

    def mgmt_address(self, name):
        return mgmt_address_map.get(name)

    @classmethod
    def get_io(cls):
        return io_map

def test_program2():
    p = asm.Program()
    led_addr = "x1"
    led_data = "x2"

    p.LUI("x1", -262144) # 0xC000_0000 >> 12
    p.LABEL("start")
    p.LW("x0", "x1", 0)
    p.JAL("x0", "start")

    return p.machine_code

def immgen(p, reg, val, verbose=False):
    subprocess.run(["make", "-C", "rtl/immgen", "immgen"], stdout=subprocess.DEVNULL)
    out = subprocess.run(["rtl/immgen/immgen", str(val)], stdout=subprocess.PIPE).stdout
    if verbose:
        print(out)
    low, high = out.decode("ascii").strip().split(",")
    p.LUI(reg, high)
    p.ADDI(reg, reg, low)

"""
    Simple boot ROM. Iterates through each possible memory location, looking for a specific "marker" instruction, jumps to it whenever found. This allows the CPU to stay in a holding pattern while the program is loaded into whichever memory must be used (if using persistent memory, this instruction can be placed at the start of the persistent memory)
"""
def bootrom():
    p = asm.Program()
    allowed_locations = [wb_address_map[x][0] for x in instr_memories if (x in wb_address_map)]
    print(allowed_locations)
    target_instr = 0x4D2F8F93 # addi x31 x31 1234

    target_addr = "x5"
    target_val  = "x6"
    actual_val  = "x7"

    immgen(p, target_val, target_instr)
    p.LABEL("init")

    for loc in allowed_locations:
        immgen(p, target_addr, loc, verbose=False)
        p.LW(actual_val, target_addr, 0)
        p.BEQ(target_val, actual_val, "go")

    p.JAL("x0", "init")

    p.LABEL("go")
    p.JALR("x0", target_addr, 0)

    p.LABEL("stall")
    p.JAL("x0", "stall")

    """mc = p.machine_code
    for i in range(0, len(mc), 4):
        print(hex(mc[i] | (mc[i+1] << 8) | (mc[i+2] << 16) | (mc[i+3] << 24)))"""

    return p.machine_code

def blinky():
    p = asm.Program()
    CTR_MAX = 4000000
    led_addr = "x1"
    ctr = "x2"
    ctr_max = "x3"
    led_data = "x4"

    p.ADDI(led_data, "x0", 0b1010)
    #p.LUI(led_addr, -491520) # 0x8800_0000 >> 12
    immgen(p, led_addr, 0x8800_0000)
    immgen(p, ctr_max, CTR_MAX)
    #p.LUI(ctr_max, CTR_MAX >> 12)
    #p.ADDI(ctr_max, ctr_max, CTR_MAX & ((1 << 12) - 1))

    p.LABEL("start")
    p.XORI(led_data, led_data, 0b1111)
    #p.LW(led_addr, led_data, 0x400) # switch value
    p.SW(led_addr, led_data, 0)
    p.ADDI(ctr, "x0", 0)
    p.LABEL("ctr")
    p.ADDI(ctr, ctr, 1)
    p.BLT(ctr, ctr_max, "ctr")
    p.JAL("x0", "start")

    return p.machine_code
