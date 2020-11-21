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
from debug_mem import *
from inst_buffer import *
from cpu import *
from timer import *

from litespi.modules import IS25LP032
from litespi.opcodes import SpiNorFlashOpCodes as Codes
from litespi.phy.generic import LiteSPIPHY
from litespi import LiteSPI

# TODO temp - remove
from simpleriscv import asm

from ram_subsystem import RAMSubsystem

from litex.soc.interconnect.csr import *

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

wb_address_map = {
    "iram":       (0x1000_0000, 0x2000_0000, "byte", None),
    "dram":       (0x4000_0000, 0x5000_0000, "word", None),

    "hyperram0":  (0xA000_0000, 0xB000_0000, "byte", None),
    "hyperram1":  (0xC000_0000, 0xD000_0000, "byte", None),

    "ibuffer":    (0x5000_0000, 0x5000_1000, "byte", None),
    "spiflash":   (0x6000_0000, 0x6100_0000, "byte", None),

    "periphs":    (0x8000_0000, 0x8800_0000, "byte", None),
    "user_ident": (0x8000_0000, 0x8000_0100, "byte", None),
    "uart":       (0x8000_0100, 0x8000_0200, "byte", None),
    "i2c":        (0x8000_0200, 0x8000_0300, "byte", None),

    "pwm0":       (0x8000_1000, 0x8000_1010, "byte", None),
    "pwm1":       (0x8000_1010, 0x8000_1020, "byte", None),

    "timer0":     (0x8000_2000, 0x8000_2020, "byte", None),
    "timer1":     (0x8000_2020, 0x8000_2040, "byte", None),
    "uptime":     (0x8000_2040, 0x8000_2060, "byte", None),

    "spi0":       (0x8000_3000, 0x8000_3020, "byte", None),

    "csrs":       (0x8800_0000, 0x8900_0000, "byte", None),

    "dbgmem":     (0xD000_0000, 0xE000_0000, "byte", None),
}

mgmt_address_map = {
    "mgmt_ident":    (0x3000_0000, 0x3000_0100, "byte", None),
    "ibuffer_mgmt":  (0x4000_0000, 0x4000_1000, "byte", None),
    "wb_bridge_dbg": (0x4000_1000, 0x4000_2000, "byte", None),
    "dbgmem_mgmt":   (0x4000_8000, 0x4000_9000, "byte", None),
}

io_map = [
    ("sys_clk", 0, Pins(1)),
    ("sys_rst", 0, Pins(1)),

    ("uart0", 0,
        Subsignal("tx", Pins(1)),
        Subsignal("rx", Pins(1)),
    ),

    ("uart1", 0,
        Subsignal("tx", Pins(1)),
        Subsignal("rx", Pins(1)),
    ),

    ("uart2", 0,
        Subsignal("tx", Pins(1)),
        Subsignal("rx", Pins(1)),
    ),

    ("i2c", 0,
        Subsignal("scl_i", Pins(1)),
        Subsignal("scl_o", Pins(1)),
        Subsignal("scl_oen", Pins(1)),
        Subsignal("sda_i", Pins(1)),
        Subsignal("sda_o", Pins(1)),
        Subsignal("sda_oen", Pins(1)),
    ),

    ("spi0", 0,
        Subsignal("mosi", Pins(1)),
        Subsignal("miso", Pins(1)),
        Subsignal("clk", Pins(1)),
    ),

    ("flash", 0,
        Subsignal("dq", Pins(4)),
        Subsignal("cs_n", Pins(1)),
        Subsignal("clk", Pins(1)),
    ),

    ("led", 0, Pins(8)),
    ("btn", 0, Pins(6)),

    ("gpio0", 0, Pins(1)),
    ("gpio1", 0, Pins(1)),

    ("test_out", 0, Pins(8)),

    ("hyperram", 0,
        Subsignal("dq_i", Pins(8)),
        Subsignal("dq_o", Pins(8)),
        Subsignal("dq_oe", Pins(1)),

        Subsignal("rwds_i", Pins(1)),
        Subsignal("rwds_o", Pins(1)),
        Subsignal("rwds_oe", Pins(1)),

        Subsignal("ck", Pins(1)),
        Subsignal("rst_n", Pins(1)),
        Subsignal("cs_n", Pins(1)),
    ),
]

class PiFive(SoC):
    def __init__(self, platform):
        # TODO syncronize and make external
        mgmt_bus = wb.Interface(data_width=32, adr_width=32)
        super().__init__(
            platform, mgmt_controller=mgmt_bus,
            wishbone_delay_register=False
        )

        tmp_clk = int(25e6)

        """flash = IS25LP032(Codes.READ_1_1_1)
        self.submodules.spiflash_phy = LiteSPIPHY(
            pads    = platform.request("flash"),
            flash   = flash,
            device  = "generic")

    #    self.add_csr(spiflash_phy, "spiflash_phy")

        self.submodules.spiflash_mmap = LiteSPI(
            phy             = self.spiflash_phy,
            clk_freq        = tmp_clk,
            mmap_endianness = "little")

    #    self.add_csr(spiflash_mmap, "spiflash_mmap")
        self.add_mem(None, "spiflash", bus=self.spiflash_mmap.bus)"""
        spi_pads = platform.request("flash")
        """pads = lambda:None
        pads.hold = spi_pads.dq[3]
        pads.wp = spi_pads.dq[2]
        pads.miso = spi_pads.dq[1]
        pads.mosi = spi_pads.dq[0]
        pads.clk = spi_pads.clk
        pads.cs_n = spi_pads.cs_n"""
        #self.add_mem(SpiFlashQuadReadWrite(spi_pads, dummy=16, div=2, with_bitbang=False, endianness="little"), "spiflash")


        # TODO ADD BACK
        #self.submodules.ram = RAMSubsystem(platform.request("hyperram"))
        #self.add_mem(None, "hyperram0", bus=self.ram.bus_cached)
        #self.add_mem(None, "hyperram1", bus=self.ram.bus_uncached)

        #self.add_csr(GPIOOut(platform.request("led")), "leds")


        ##### TODO ADD BACK
        #self.add_csr(GPIOIn(platform.request("btn")), "btns")
        #self.add_csr(GPIOOut(platform.request("test_out")), "test_out")

        self.add_controller(WishboneBridge(), "wb_bridge")
        self.add_mgmt_periph(None, "wb_bridge_dbg", bus=self.wb_bridge.debug_bus)

        self.add_mem(DebugMemory(), "dbgmem")
        self.add_mgmt_periph(None, "dbgmem_mgmt", bus=self.dbgmem.debug_bus)

        self.add_periph(WishbonePWM(platform.request("gpio0")), "pwm0")
        self.add_periph(WishbonePWM(platform.request("gpio1")), "pwm1")

        self.add_periph(WishboneROM("Test SoC User Space"), "user_ident")
        self.add_mgmt_periph(WishboneROM("Test SoC Mgmt Space"), "mgmt_ident")

        self.add_periph(WishboneSPI(platform.request("spi0")), "spi0")

        self.add_mem(InstBuffer(size=8), "ibuffer")
        self.add_mgmt_periph(None, "ibuffer_mgmt", bus=self.ibuffer.debug_bus)

        self.add_mem(WishboneROM(test_program(), nullterm=False, endianness="little"), "iram")

        #self.add_mem(wb.SRAM(512, init=[0x00000113, 0x40000237, 0x00020213, 0x800001B7, 0x00018193, 0xFFF14113, 0x0021A023, 0x009890B7, 0x68008093, 0xFFF08093, 0x00122023, 0xFE104CE3, 0xFE5FF06F, 0x80000137, 0x00010113, 0x00212023], bus=wb.Interface(data_width=32, adr_width=32)), "iram")

        #self.add_mem(wb.SRAM(512, init=[0xDEADBEEF], bus=wb.Interface(data_width=32, adr_width=32)), "dram")


        self.add_periph(WishboneUART(platform.request("uart2"), fifo_depth=4), "uart")

        self.add_periph(WishboneI2C(platform.request("i2c")), "i2c")

        self.add_periph(UptimeTimer(), "uptime")
        self.add_periph(Timer(), "timer0")
        self.add_periph(Timer(), "timer1")

        #self.add_controller(WishboneDebugBus(platform.request("uart0"), tmp_clk, baud=115200), "debugbus")
        #self.comb += platform.request("led").eq(Mux(self.debugbus.ctr[0:9] == self.debugbus.ctr, self.debugbus.ctr >> 1, Constant(255)))

        self.submodules.mgmt_ctrl = WishboneDebugBus(platform.request("uart1"), tmp_clk, baud=115200)
        self.sync += self.mgmt_ctrl.bus.connect(mgmt_bus)

        cpu = CPUWrapper()
        self.add_controller(cpu, "cpu_ibus", bus=cpu.instr_bus)
        self.add_controller(None, "cpu_dbus", bus=cpu.data_bus)

        #### TODO ADD BACK
        #self.add_csr(GPIOOut(cpu.disable), "cpu_disable")

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

def test_program():
    p = asm.Program()
    led_addr = "x1"
    led_data = "x2"

    p.LUI("x1", -262144) # 0xC000_0000 >> 12
    p.LABEL("start")
    p.LW("x0", "x1", 0)
    p.JAL("x0", "start")

    return p.machine_code

def test_program2():
    p = asm.Program()
    CTR_MAX = 2000000
    led_addr = "x1"
    ctr = "x2"
    ctr_max = "x3"
    led_data = "x4"

    p.ADDI(led_data, "x0", 0b1010)
    p.LUI(led_addr, -491520) # 0x8800_0000 >> 12
    p.LUI(ctr_max, CTR_MAX >> 12)
    p.ADDI(ctr_max, ctr_max, CTR_MAX & ((1 << 12) - 1))

    p.LABEL("start")
    #p.XORI(led_data, led_data, 0b1111)
    p.LW(led_addr, led_data, 0x400) # switch value
    p.SW(led_addr, led_data, 0)
    p.ADDI(ctr, "x0", 0)
    p.LABEL("ctr")
    p.ADDI(ctr, ctr, 1)
    p.BLT(ctr, ctr_max, "ctr")
    p.JAL("x0", "start")

    return p.machine_code
