from migen import *
from util import *
from third_party import wishbone as wb

# Translate addresses by removing MSBs
class WishboneAddressTranslator(Module):
    def __init__(self, controller, peripheral, translate_fn):
        self.comb += controller.connect(peripheral, omit={"adr"})
        self.comb += peripheral.adr.eq(translate_fn(controller.adr))

# Interconnect with customizable shared bus size
class WishboneInterconnect(Module):
    def __init__(self, controllers, peripherals, shared=None, register=False):
        if shared is None:
            shared = wb.Interface(data_width=32, adr_width=32)
        self.submodules.arbiter = wb.Arbiter(controllers, shared)
        self.submodules.decoder = wb.Decoder(shared, peripherals, register)

# Simple crossbar
class WishboneCrossbar(Module):
    def __init__(self, controllers, peripherals, register=False):
        check_fns, periph_busses = zip(*peripherals)

        # TODO allow selectively blocking specific points in crossbar
        cross_points = [[wb.Interface(data_width=32, adr_width=32) for j in peripherals]
                            for i in controllers]

        for row, controller in zip(cross_points, controllers):
            self.submodules += wb.Decoder(controller, list(zip(check_fns, row)), register=register)
        for col, bus in zip(zip(*cross_points), periph_busses):
            self.submodules += wb.Arbiter(col, bus)

# ROM module
# Data passed to constructor is in bytes, not words
# Data read out through wishbone is in aligned words
class ROM(Module):
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
