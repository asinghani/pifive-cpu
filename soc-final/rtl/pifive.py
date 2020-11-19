import pprint
from migen import *

from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.uart import RS232PHY, UART
from litex.soc.cores.gpio import GPIOIn, GPIOOut

from litex.soc.interconnect import csr, csr_bus
from litex.soc.interconnect import wishbone as wb

from util import *
from wishbone_debug_bus import *
from wishbone_uart import *
from cpu import *

from soc import *

csr_address_map = {
    "leds":        0x8000_0000,
    "btns":        0x8000_0010,
}

wb_address_map = {
    "iram":    (0x1000_0000, 0x2000_0000, "word", None),
    "dram":    (0x4000_0000, 0x5000_0000, "word", None),
    "user_ident": (0xB000_0000, 0xB000_0100, "byte", None),
    "user_ident1": (0x2000_0000, 0x2000_0100, "byte", None),

    "csrs":    (0x8000_0000, 0x8000_1000, "byte", None),
    "periphs": (0xB000_0000, 0xFFFF_FFFF, "byte", None),
}

mgmt_address_map = {
    "mgmt_ident":   (0x3000_0000, 0x3000_0100, "byte", None),
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

    ("led", 0, Pins(8)),
    ("btn", 0, Pins(6))
]

class PiFive(SoC):
    def __init__(self, platform):
        # TODO syncronize and make external
        mgmt_bus = wb.Interface(data_width=32, adr_width=32)
        super().__init__(
            platform, mgmt_controller=mgmt_bus,
            wishbone_delay_register=False
        )

        self.add_csr(GPIOOut(platform.request("led")), "leds")
        self.add_csr(GPIOIn(platform.request("btn")), "btns")

        self.add_periph(WishboneROM("Test SoC User Space"), "user_ident")
        self.add_mem(WishboneROM("Test test test test"), "user_ident1")
        self.add_mgmt_periph(WishboneROM("Test SoC Mgmt Space"), "mgmt_ident")

        self.add_mem(wb.SRAM(512, init=[0x00000113, 0x40000237, 0x00020213, 0x800001B7, 0x00018193, 0xFFF14113, 0x0021A023, 0x009890B7, 0x68008093, 0xFFF08093, 0x00122023, 0xFE104CE3, 0xFE5FF06F, 0x80000137, 0x00010113, 0x00212023], bus=wb.Interface(data_width=32, adr_width=32)), "iram")

        self.add_mem(wb.SRAM(512, init=[0xDEADBEEF], bus=wb.Interface(data_width=32, adr_width=32)), "dram")

        tmp_clk = int(25e6)

        self.add_controller(WishboneDebugBus(platform.request("uart0"), tmp_clk, baud=115200), "debugbus")

        self.submodules.mgmt_ctrl = WishboneDebugBus(platform.request("uart1"), tmp_clk, baud=115200)
        self.sync += self.mgmt_ctrl.bus.connect(mgmt_bus)

        """
        cpu = CPU()
        self.add_controller(cpu, "cpu_ibus", bus=cpu.instr_bus)
        self.add_controller(None, "cpu_dbus", bus=cpu.data_bus)
        self.add_csr(GPIOOut(cpu.disable), "cpu_disable")
        """

        cpu_mem_map, mgmt_mem_map = self.generate_bus()

        print("CPU Memory Map:")
        print_mem_map(cpu_mem_map)
        print()
        print()
        print("Mgmt Memory Map:")
        print_mem_map(mgmt_mem_map)
        print()

    def csr_address(self, name):
        return csr_address_map.get(name)

    def wb_address(self, name):
        return wb_address_map.get(name)

    def mgmt_address(self, name):
        return mgmt_address_map.get(name)

    @classmethod
    def get_io(cls):
        return io_map

