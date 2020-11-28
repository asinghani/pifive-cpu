from functools import partial
from migen import *
from util import *

from third_party import wishbone as wb
from bus.wishbone_utils import *

"""
Tri-bus structure:
    1. Memory bus (crossbar)
        - Memories / Cache
        - All controllers
    2. Peripheral bus (shared)
        - Low-performance peripherals
        - Connected to memory bus
    3. Debug bus (shared)
        - Debug utilities, and bridge onto main bus
        - Controlled by external debug core

Wishbone address width: 32
Wishbone data width: 32
"""

# CRG with no power-on reset
class SimpleCRG(Module):
    def __init__(self, clk, rst=0):
        self.clock_domains.cd_sys = ClockDomain()

        self.comb += [
            self.cd_sys.clk.eq(clk),
            self.cd_sys.rst.eq(rst)
        ]

class SoC(Module):
    def __init__(self,
                 platform,
                 debug_controller=None,
                 wishbone_delay_register=True):

        self.submodules.crg = SimpleCRG(platform.request("sys_clk"), platform.request("sys_rst"))

        self.controllers = {}
        self.mem_bus = {}
        self.periph_bus = {}

        if debug_controller is None:
            debug_controller = wb.Interface(data_width=32, adr_width=32)
        self.debug_controller = debug_controller
        self.debug_bus = {}

        self.wishbone_delay_register = wishbone_delay_register

    def check_name(self, name):
        if name in list(self.controllers.keys()) + list(self.mem_bus.keys()) + \
                   list(self.periph_bus.keys()) + list(self.debug_bus.keys()):
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

    def add_debug_periph(self, periph, name, bus=None):
        self.check_name(name)
        if bus is None:
            bus = periph.bus

        self.debug_bus[name] = (periph, bus)
        if periph is not None:
            setattr(self.submodules, name, periph)

    def generate_bus(self):
        if len(self.mem_bus) + len(self.periph_bus) < 1:
            raise ValueError("Must have at least one peripheral or memory in order to generate bus")

        if len(self.debug_bus) < 1:
            raise ValueError("Must have at least one debug peripheral in order to generate bus")

        if len(self.controllers) < 1:
            raise ValueError("Must have at least one controller in order to generate bus")

        cpu_address_map = [] # (addr, name) or (addr, name, [(addr, name), ...]) - all addresses are absolute
        debug_address_map = []

        if len(self.periph_bus) != 0:
            periph_addr_base, periph_addr_top = self.wb_address("periphs")[0:2]
            periph_address_map = []
            peripherals = []

            for name, periph in self.periph_bus.items():
                controller_bus = wb.Interface(data_width=32, adr_width=32)
                periph_bus = periph[1]

                base_addr, top_addr, size, translate_fn, c_type, c_type_top = self.wb_address(name)

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
            base_addr, top_addr, size, translate_fn, c_type, c_type_top = self.wb_address(name)

            if translate_fn is None:
                if name == "periphs":
                    translate_fn = lambda x: x
                else:
                    translate_fn = create_translate_fn(base_addr, size)

            check_fn = create_check_fn(base_addr, top_addr)

            translator = WishboneAddressTranslator(controller_bus, periph_bus, translate_fn)
            setattr(self.submodules, name+"__translator", translator)

            if name not in ["periphs"]:
                cpu_address_map.append((base_addr, name))

            mems.append((check_fn, controller_bus))

        self.submodules.crossbar = WishboneCrossbar(controllers, mems, register=self.wishbone_delay_register)

        debug_address_map = []
        debug_peripherals = []

        for name, periph in self.debug_bus.items():
            controller_bus = wb.Interface(data_width=32, adr_width=32)
            periph_bus = periph[1]

            base_addr, top_addr, size, translate_fn = self.debug_address(name)

            if translate_fn is None:
                translate_fn = create_translate_fn(base_addr, size)

            check_fn = create_check_fn(base_addr, top_addr)

            translator = WishboneAddressTranslator(controller_bus, periph_bus, translate_fn)
            setattr(self.submodules, name+"__translator", translator)

            debug_peripherals.append((check_fn, controller_bus))
            debug_address_map.append((base_addr, name))

        self.submodules.debug_interconnect = wb.Decoder(self.debug_controller, debug_peripherals, register=True)

        return cpu_address_map, debug_address_map

def create_translate_fn(base, size):
    def fn(a, b):
        return (b - a[0])[(2 if a[1] == "word" else 0):]

    return partial(fn, (base, size))

def create_check_fn(base, top):
    def fn(a, b):
        return (b >= a[0]) & (b < a[1])

    return partial(fn, (base, top))
