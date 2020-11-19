from functools import partial
from migen import *
from util import *

from litex.build.generic_platform import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *

from litex.soc.interconnect import csr, csr_bus
from litex.soc.interconnect import wishbone as wb

"""
Quad-bus structure:
    1. Memory bus (crossbar)
        - Memories / Cache
        - All controllers
    2. Peripheral bus (shared)
        - Low-performance peripherals
        - Connected to memory bus
    3. CSR bus (shared)
        - Low-performance peripherals
        - Connected to memory(?) bus
    4. Management bus (shared)
        - Debug utilities, and bridged onto main bus
        - Controlled by external debug core

Wishbone address width: 32
Wishbone data width: 32
CSR address width: 14
CSR data width: 8
"""

# add_controller
# add_mem
# add_periph
# add_csr
# add_mgmt_periph

class SoC(Module):
    def __init__(self,
                 platform,
                 mgmt_controller=None,
                 wishbone_delay_register=False):

        self.submodules.crg = CRG(platform.request("sys_clk"), platform.request("sys_rst"))

        self.controllers = {}
        self.mem_bus = {}
        self.periph_bus = {}
        self.csr_bus = {}

        if mgmt_controller is None:
            mgmt_controller = wb.Interface(data_width=32, adr_width=32)
        self.mgmt_controller = mgmt_controller
        self.mgmt_bus = {}

        self.wishbone_delay_register = wishbone_delay_register

    def check_name(self, name):
        if name in list(self.controllers.keys()) + list(self.mem_bus.keys()) + \
                   list(self.periph_bus.keys()) + list(self.csr_bus.keys()) + \
                   list(self.mgmt_bus.keys()):
            raise ValueError("Name {} cannot be used twice".format(name))

    def add_controller(self, controller, name, bus=None):
        self.check_name(name)
        if bus is None:
            bus = controller.bus

        self.controllers[name] = (controller, bus)
        if controller is not None:
            setattr(self.submodules, name, controller)

    def add_mem(self, periph, name, bus=None):
        self.check_name(name)
        if bus is None:
            bus = periph.bus

        self.mem_bus[name] = (periph, bus)
        if periph is not None:
            setattr(self.submodules, name, periph)

    def add_periph(self, periph, name, bus=None):
        self.check_name(name)
        if bus is None:
            bus = periph.bus

        self.periph_bus[name] = (periph, bus)
        if periph is not None:
            setattr(self.submodules, name, periph)

    def add_csr(self, periph, name):
        self.check_name(name)
        self.csr_bus[name] = periph
        setattr(self.submodules, name, periph)

    def add_mgmt_periph(self, periph, name, bus=None):
        self.check_name(name)
        if bus is None:
            bus = periph.bus

        self.mgmt_bus[name] = (periph, bus)
        if periph is not None:
            setattr(self.submodules, name, periph)

    def generate_bus(self):
        if len(self.mem_bus) + len(self.csr_bus) + len(self.periph_bus) < 1:
            raise ValueError("Must have at least one peripheral or memory in order to generate bus")

        if len(self.mgmt_bus) < 1:
            raise ValueError("Must have at least one management peripheral in order to generate bus")

        if len(self.controllers) < 1:
            raise ValueError("Must have at least one controller in order to generate bus")

        cpu_address_map = [] # (addr, name) or (addr, name, [(addr, name), ...]) - all addresses are absolute
        mgmt_address_map = []

        if len(self.csr_bus) != 0:
            csr_addr_base, csr_addr_top = self.wb_address("csrs")[0:2]
            csr_address_map = []

            # Create bridge between wishbone and CSR
            wb_csr_bus = wb.Interface(data_width=32, adr_width=32)
            csr_controller = csr_bus.Interface(data_width=8, address_width=14, alignment=32)

            paging_bits = 10
            paging = 2**(paging_bits-2)

            # Verify address spacing
            last_addr = -100000
            for addr in sorted(self.csr_address(None)):
                if addr - last_addr < 2**paging_bits:
                    raise ValueError("CSR bases must have at least 0x{:x} gap".format(2**paging_bits))
                last_addr = addr

            csr_addr_lookup = lambda a, mem: (self.csr_address(a) - csr_addr_base) >> paging_bits
            csr_bank_array = csr_bus.CSRBankArray(self, csr_addr_lookup, paging=paging, ordering="little", soc_bus_data_width=8)
            self.submodules.csr_bank_array = csr_bank_array

            self.submodules.csr_con = csr_bus.Interconnect(csr_controller, csr_bank_array.get_buses())

            wb_csr = wb.Wishbone2CSR(wb_csr_bus, csr_controller, register=True)
            self.add_mem(wb_csr, "csrs", bus=wb_csr_bus)

            for periph_name, csr, base_addr, regs in csr_bank_array.banks:
                addr_map = []
                base_addr = base_addr << paging_bits
                for ind, reg in enumerate(regs.simple_csrs):
                    addr = csr_addr_base + base_addr + (ind << 2)
                    if addr not in range(csr_addr_base, csr_addr_top):
                        raise ValueError("CSR address {:08x} for {}->{} out of range".format(addr, periph_name, reg.name))

                    addr_map.append((addr, "{} ({}b)".format(reg.name, reg.size)))

                csr_address_map.append((csr_addr_base + base_addr, periph_name, addr_map))

            cpu_address_map.append((csr_addr_base, "CSRs", csr_address_map))

        if len(self.periph_bus) != 0:
            periph_addr_base, periph_addr_top = self.wb_address("periphs")[0:2]
            periph_address_map = []
            peripherals = []

            for name, periph in self.periph_bus.items():
                controller_bus = wb.Interface(data_width=32, adr_width=32)
                periph_bus = periph[1]

                base_addr, top_addr, size, translate_fn = self.wb_address(name)

                assert base_addr >= periph_addr_base and base_addr <= periph_addr_top
                assert top_addr >= periph_addr_base and top_addr <= periph_addr_top

                if translate_fn is None:
                    translate_fn = create_translate_fn(base_addr - 0, size)

                check_fn = create_check_fn(base_addr - 0, top_addr - 0)

                translator = WishboneAddressTranslator(controller_bus, periph_bus, translate_fn)
                setattr(self.submodules, name+"__translator", translator)

                peripherals.append((check_fn, controller_bus))
                periph_address_map.append((base_addr, name))

            cpu_address_map.append((periph_addr_base, "Peripherals", periph_address_map))

            shared = wb.Interface(data_width=32, adr_width=32)
            periph_bridge = wb.Decoder(shared, peripherals, register=True)
            self.add_mem(periph_bridge, "periphs", bus=shared)

        assert len(self.mem_bus) >= 1

        controllers = [x[1] for x in self.controllers.values()]
        mems = []

        for name, periph in self.mem_bus.items():
            controller_bus = wb.Interface(data_width=32, adr_width=32)
            periph_bus = periph[1]
            base_addr, top_addr, size, translate_fn = self.wb_address(name)

            if translate_fn is None:
                if name == "periphs":
                    translate_fn = lambda x: x
                elif name == "csrs":
                    translate_fn = create_translate_fn(base_addr, "word")
                else:
                    translate_fn = create_translate_fn(base_addr, size)

            check_fn = create_check_fn(base_addr, top_addr)

            translator = WishboneAddressTranslator(controller_bus, periph_bus, translate_fn)
            setattr(self.submodules, name+"__translator", translator)

            if name not in ["csrs", "periphs"]:
                cpu_address_map.append((base_addr, name))

            mems.append((check_fn, controller_bus))

        self.submodules.crossbar = WishboneCrossbar(controllers, mems, register=self.wishbone_delay_register)

        mgmt_address_map = []
        mgmt_peripherals = []

        for name, periph in self.mgmt_bus.items():
            controller_bus = wb.Interface(data_width=32, adr_width=32)
            periph_bus = periph[1]

            base_addr, top_addr, size, translate_fn = self.mgmt_address(name)

            if translate_fn is None:
                translate_fn = create_translate_fn(base_addr, size)

            check_fn = create_check_fn(base_addr, top_addr)

            translator = WishboneAddressTranslator(controller_bus, periph_bus, translate_fn)
            setattr(self.submodules, name+"__translator", translator)

            mgmt_peripherals.append((check_fn, controller_bus))
            mgmt_address_map.append((base_addr, name))

        self.submodules.mgmt_interconnect = wb.Decoder(self.mgmt_controller, mgmt_peripherals, register=True)

        return cpu_address_map, mgmt_address_map

def create_translate_fn(base, size):
    def fn(a, b):
        return (b - a[0])[(2 if a[1] == "word" else 0):]

    return partial(fn, (base, size))

def create_check_fn(base, top):
    def fn(a, b):
        return (b >= a[0]) & (b < a[1])

    return partial(fn, (base, top))
