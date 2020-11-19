import os
from migen import *

from litex.build.generic_platform import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *

from litex.soc.interconnect import csr, csr_bus
from litex.soc.interconnect import wishbone as wb


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

def pack_list(data, endianness="little"):
    if endianness != "big":
        data = data[::-1]

    out = 0
    for x in data:
        out = (out << 8) | (x & 0xFF)

    return out

# ROM module
# Data passed to constructor is in bytes, not words
# Data read out through wishbone is in aligned words
class WishboneROM(Module):
    def __init__(self, data, bus=None, nullterm=True, endianness="little"):
        if bus is None:
            bus = wb.Interface(data_width=32, adr_width=32)

        self.bus = bus

        num_bytes = bus.data_width // 8
        data = list(data)

        for i in range(len(data)):
            if isinstance(data[i], str):
                data[i] = ord(data[i])

            data[i] = int(data[i])

        if nullterm:
            data = data + [0]

        # Add padding
        data = data + [0] * ((num_bytes - (len(data) % num_bytes)) % num_bytes)
        assert len(data) % num_bytes == 0

        # Group into words
        data = [data[i:i+num_bytes] for i in range(0, len(data), num_bytes)]
        assert all([len(x) == num_bytes for x in data])

        # Pack words
        data = [pack_list(x, endianness=endianness) for x in data]

        self.sync += [
            self.bus.ack.eq(self.bus.cyc & self.bus.stb & ~self.bus.ack),
            self.bus.dat_r.eq(Array(data)[self.bus.adr >> 2])
        ]

# Translate addresses by removing MSBs
class WishboneAddressTranslator(Module):
    def __init__(self, controller, peripheral, translate_fn):
        self.comb += controller.connect(peripheral, omit={"adr"})
        self.comb += peripheral.adr.eq(translate_fn(controller.adr))

# Returns error on every request
class WishboneError(Module):
    def __init__(self, bus=None):
        if bus is None:
            bus = wb.Interface(data_width=32, adr_width=32)

        self.bus = bus
        self.sync += bus.err.eq(bus.cyc & bus.stb & ~bus.err)
        self.comb += [
            bus.ack.eq(0),
            bus.dat_r.eq(0)
        ]

# Interconnect with customizable shared bus size
class WishboneInterconnect(Module):
    def __init__(self, controllers, peripherals, shared=None, register=False):
        if shared is None:
            shared = wb.Interface(data_width=32, adr_width=32)
        self.submodules.arbiter = wb.Arbiter(controllers, shared)
        self.submodules.decoder = wb.Decoder(shared, peripherals, register)

# N-cycle delay register
class RegNextN(Module):
    def __init__(self, out_wire, in_wire, num_ff=1):
        assert num_ff >= 0

        if num_ff == 0:
            self.comb += out_wire.eq(in_wire)
        else:
            tmp = Signal.like(in_wire)
            self.sync += tmp.eq(in_wire)
            self.submodules += RegNextN(out_wire, tmp, num_ff=num_ff-1)

def print_mem_map(data, offset=0):
    for x in sorted(data, key=lambda x: x[0]):
        if len(x) == 2:
            print("{}{:08X}: {}".format("    "*offset, x[0], x[1]))
        else:
            assert len(x) == 3
            print("{}{:08X}: {}".format("    "*offset, x[0], x[1]))
            print_mem_map(x[2], offset=offset + 1)
            print()


