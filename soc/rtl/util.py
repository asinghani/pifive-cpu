import os
from migen import *

from litex.build.generic_platform import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.uart import UARTWishboneBridge
from litex.soc.cores.gpio import GPIOIn, GPIOOut

from litex.soc.interconnect import csr, csr_bus
from litex.soc.interconnect import wishbone as wb

from migen.genlib import roundrobin
from migen.genlib.misc import split, displacer, chooser, WaitTimer

class VerilogPlatform(GenericPlatform):
    def __init__(self, io):
        GenericPlatform.__init__(self, "", io)
        self.io = io

    def build(self, fragment, module_name, filename, build_dir, **kwargs):
        os.makedirs(build_dir, exist_ok=True)
        old_dir = os.getcwd()
        os.chdir(build_dir)
        top_output = self.get_verilog(fragment, name=module_name)
        top_output.write(filename)
        os.chdir(old_dir)

# Downconvert by truncating / zero-padding
# Mostly exists for verbosity
class DumbDownConverter(Module):
    def __init__(self, master, slave):
        self.comb += master.connect(slave)

# Translate addresses by removing MSBs
class AddressTranslator(Module):
    def __init__(self, master, slave, translate_fn):
        self.comb += master.connect(slave, omit={"adr"})
        self.comb += slave.adr.eq(translate_fn(master.adr))

# Timeout module
# Slightly altered from original LiteX implementation
class WishboneTimeout(Module):
    def __init__(self, master, cycles):
        timer = WaitTimer(int(cycles))
        self.submodules += timer
        self.comb += [
            timer.wait.eq(master.stb & master.cyc & ~master.ack & ~master.err),
            If(timer.done,
                master.err.eq(1)
            )
        ]

(SP_WITHDRAW, SP_CE) = range(2)

class NRoundRobin(Module):
    def __init__(self, n, switch_policy=SP_WITHDRAW):
        self.request = Signal(n)
        self.grant = Signal(max=max(2, n))
        self.switch_policy = switch_policy
        if self.switch_policy == SP_CE:
            self.ce = Signal()

        ###

        if n > 1:
            cases = {}
            for i in range(n):
                switch = []
                for j in reversed(range(i+1, i+n)):
                    t = j % n
                    switch = [
                        If(self.request[t],
                            self.grant.eq(t)
                        ).Else(
                            *switch
                        )
                    ]
                if self.switch_policy == SP_WITHDRAW:
                    case = [If(~self.request[i], *switch)]
                else:
                    case = [If(~self.request[i] | self.ce, *switch)]
                cases[i] = case
            statement = Case(self.grant, cases)
            #if self.switch_policy == SP_CE:
            #    statement = If(self.ce, statement)
            self.sync += statement
        else:
            self.comb += self.grant.eq(0)

class NArbiter(Module):
    def __init__(self, masters, target):
        self.submodules.rr = NRoundRobin(len(masters), switch_policy=SP_CE)
        self.comb += self.rr.ce.eq(target.ack)

        masters = masters[::-1]

        # mux master->slave signals
        for name, size, direction in wb._layout:
            if direction == wb.DIR_M_TO_S:
                choices = Array(getattr(m, name) for m in masters)
                self.comb += getattr(target, name).eq(choices[self.rr.grant])

        # connect slave->master signals
        for name, size, direction in wb._layout:
            if direction == wb.DIR_S_TO_M:
                source = getattr(target, name)
                for i, m in enumerate(masters):
                    dest = getattr(m, name)
                    if name == "ack" or name == "err":
                        self.comb += dest.eq(source & (self.rr.grant == i))
                    else:
                        self.comb += dest.eq(source)

        # connect bus requests to round-robin selector
        reqs = [m.cyc for m in masters]
        self.comb += self.rr.request.eq(Cat(*reqs))

class NInterconnectShared(Module):
    def __init__(self, masters, slaves, shared=None, register=False):
        if shared is None:
            shared = wb.Interface()
        self.submodules.arbiter = wb.Arbiter(masters, shared)
        self.submodules.decoder = wb.Decoder(shared, slaves, register)


# Simple base SoC implementation
class GenericSoC(Module):
    def __init__(self, platform, sys_clk_freq, data_width=32, adr_width=30, csr_delay_register=True, wishbone_delay_register=True, crossbar=True):
        self.wb_masters = {}
        self.wb_slaves = {}
        self.csr_periphs = {}

        self.data_width = data_width
        self.adr_width = adr_width

        # Whether to include one-cycle delay on CSR and wishbone
        self.csr_delay_register = csr_delay_register
        self.wishbone_delay_register = wishbone_delay_register

        # Whether to use a crossbar (instead of a shared interconnect)
        self.crossbar = crossbar

    def check_name(self, name):
        if name in list(self.wb_masters.keys()) + list(self.wb_slaves.keys()) + list(self.csr_periphs.keys()):
            raise ValueError("Name {} cannot be used twice".format(name))

        if name.endswith("__width_converter"):
            raise ValueError("Name {} contains a reserved suffix".format(name))

        if name.endswith("__translator"):
            raise ValueError("Name {} contains a reserved suffix".format(name))

        if name.endswith("__timeout"):
            raise ValueError("Name {} contains a reserved suffix".format(name))

    def add_wb_master(self, master, name, bus=None, convert=False, timeout=None):
        self.check_name(name)

        if bus is None:
            assert master is not None
            bus = master.bus

        wb_iface = wb.Interface(data_width=self.data_width, adr_width=self.adr_width)
        self.wb_masters[name] = (master, wb_iface)

        if timeout is not None:
            setattr(self.submodules, name+"__timeout", WishboneTimeout(wb_iface, timeout))

        if convert:
            converter = wb.Converter(bus, wb_iface)
            setattr(self.submodules, name+"__width_converter", converter)
        else:
            self.comb += bus.connect(wb_iface)

        if master is not None:
            setattr(self.submodules, name, master)

    def add_wb_slave(self, slave, name, bus=None, convert=False, timeout=None):
        self.check_name(name)

        if bus is None:
            assert slave is not None
            bus = slave.bus

        wb_iface = wb.Interface(data_width=self.data_width, adr_width=self.adr_width)
        self.wb_slaves[name] = (slave, wb_iface)

        if timeout is not None:
            setattr(self.submodules, name+"__timeout", WishboneTimeout(wb_iface, timeout))

        if convert:
            converter = wb.Converter(wb_iface, bus)
            setattr(self.submodules, name+"__width_converter", converter)
        else:
            self.comb += wb_iface.connect(bus)

        if slave is not None:
            setattr(self.submodules, name, slave)

    def add_csr_periph(self, periph, name):
        self.check_name(name)
        self.csr_periphs[name] = periph
        setattr(self.submodules, name, periph)

    def generate_bus(self):
        if len(self.wb_slaves) + len(self.csr_periphs) < 1:
            raise ValueError("Must have at least one Wishbone slave or CSR peripheral in order to generate bus")

        if len(self.wb_masters) < 1:
            raise ValueError("Must have at least one Wishbone master in order to generate bus")

        if len(self.csr_periphs) != 0:
            # Create bridge between wishbone and CSR
            wb_csr_bus = wb.Interface(data_width=self.data_width, adr_width=self.adr_width)
            csr_master = csr_bus.Interface(data_width=8, address_width=14, alignment=8)

            csr_bank_array = csr_bus.CSRBankArray(self, self.csr_address_map, paging=1, ordering="little", soc_bus_data_width=self.data_width)
            self.submodules.csr_bank_array = csr_bank_array

            #print([([(a.size, a.name) for a in x.simple_csrs], n, m) for n, c, m, x in csr_bank_array.banks])
            for name, csr, base, regs in csr_bank_array.banks:
                print("(0x{:04x}) {}:".format(base, name))
                for i, dat in enumerate(regs.simple_csrs):
                    print("    (0x{:04x}) {} ({} bits):".format(base + i, dat.name, dat.size))
                print()

            self.submodules.csr_con = csr_bus.Interconnect(csr_master, csr_bank_array.get_buses())

            wb_csr = wb.Wishbone2CSR(wb_csr_bus, csr_master, register=self.csr_delay_register)
            self.add_wb_slave(wb_csr, "csr", bus=wb_csr_bus, convert=False)

        assert len(self.wb_slaves) >= 1

        masters = [x[1] for x in self.wb_masters.values()]

        slaves = []

        for name, slave in self.wb_slaves.items():
            master_bus = wb.Interface(data_width=self.data_width, adr_width=self.adr_width)
            slave_bus = slave[1]
            check_fn, translate_fn = self.wb_address_map(name)
            translator = AddressTranslator(master_bus, slave_bus, translate_fn)
            setattr(self.submodules, name+"__translator", translator)

            slaves.append((check_fn, master_bus))

        # Generate wishbone crossbar
        if self.crossbar:
            self.submodules.wb_con = wb_con = wb.Crossbar(masters, slaves, register=self.wishbone_delay_register)
        else:
            #self.submodules.wb_con = wb_con = NInterconnectShared(masters, slaves, register=self.wishbone_delay_register)
            shared = wb.Interface(data_width=self.data_width, adr_width=self.adr_width)
            self.submodules.wb_con = wb_con = NInterconnectShared(masters, slaves, shared=shared, register=self.wishbone_delay_register)
