from migen import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.interconnect import wishbone as wb

from litex.soc.cores.gpio import GPIOIn, GPIOOut
from litex.soc.cores.uart import UART, UARTPHY

from soc import *
from util import *
from wishbone_debug_bus import *
from wishbone_uart import *
from wishbone_i2c import *
from cpu import *

# TODO temp - remove
from simpleriscv import asm

csr_address_map = {
    "leds":        0x8800_0000,
    "btns":        0x8800_0400,
    "cpu_disable": 0x8800_0C00,
}

wb_address_map = {
    "iram":       (0x1000_0000, 0x2000_0000, "byte", None),
    "dram":       (0x4000_0000, 0x5000_0000, "word", None),

    "periphs":    (0x8000_0000, 0x8800_0000, "byte", None),
    "user_ident": (0x8000_0000, 0x8000_0100, "byte", None),
    "uart":       (0x8000_0100, 0x8000_0200, "byte", None),
    "i2c":        (0x8000_0200, 0x8000_0300, "byte", None),

    "csrs":       (0x8800_0000, 0x8900_0000, "byte", None),
}

mgmt_address_map = {
    "mgmt_ident": (0x3000_0000, 0x3000_0100, "byte", None),
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
        self.add_mgmt_periph(WishboneROM("Test SoC Mgmt Space"), "mgmt_ident")


        self.add_mem(WishboneROM(test_program(), nullterm=False, endianness="little"), "iram")

        #self.add_mem(wb.SRAM(512, init=[0x00000113, 0x40000237, 0x00020213, 0x800001B7, 0x00018193, 0xFFF14113, 0x0021A023, 0x009890B7, 0x68008093, 0xFFF08093, 0x00122023, 0xFE104CE3, 0xFE5FF06F, 0x80000137, 0x00010113, 0x00212023], bus=wb.Interface(data_width=32, adr_width=32)), "iram")

        self.add_mem(wb.SRAM(512, init=[0xDEADBEEF], bus=wb.Interface(data_width=32, adr_width=32)), "dram")

        tmp_clk = int(25e6)

        self.add_periph(WishboneUART(platform.request("uart1"), fifo_depth=4), "uart")

        self.add_periph(WishboneI2C(platform.request("i2c")), "i2c")

        self.add_controller(WishboneDebugBus(platform.request("uart0"), tmp_clk, baud=115200), "debugbus")

        self.submodules.mgmt_ctrl = WishboneDebugBus(platform.request("uart2"), tmp_clk, baud=115200)
        self.sync += self.mgmt_ctrl.bus.connect(mgmt_bus)

        """cpu = CPUWrapper()
        self.add_controller(cpu, "cpu_ibus", bus=cpu.instr_bus)
        self.add_controller(None, "cpu_dbus", bus=cpu.data_bus)
        self.add_csr(GPIOOut(cpu.disable), "cpu_disable")"""

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
