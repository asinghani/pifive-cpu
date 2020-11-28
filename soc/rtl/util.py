import os
from migen import *
from migen.build.generic_platform import *
from migen.fhdl import verilog

from third_party import wishbone as wb

class VerilogPlatform(GenericPlatform):
    def __init__(self, io):
        GenericPlatform.__init__(self, "", io)
        self.io = io

    def build(self, fragment, module_name, filename, build_dir, **kwargs):
        os.makedirs(build_dir, exist_ok=True)
        old_dir = os.getcwd()
        os.chdir(build_dir)
        top_output = verilog.convert(fragment, self.constraint_manager.get_io_signals(), create_clock_domains=False, name=module_name)
        top_output.write(filename)
        os.chdir(old_dir)

def pack_list(data, endianness="little"):
    if endianness != "big":
        data = data[::-1]

    out = 0
    for x in data:
        out = (out << 8) | (x & 0xFF)

    return out

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

def print_mem_map(data, offset=0, print_fn = print):
    for x in sorted(data, key=lambda x: x[0]):
        if len(x) == 2:
            print_fn("{}0x{:08X}: {}".format("    "*offset, x[0], x[1]))
        else:
            assert len(x) == 3
            print_fn("{}0x{:08X}: {}".format("    "*offset, x[0], x[1]))
            print_mem_map(x[2], offset=offset + 1, print_fn = print_fn)
            print_fn("")

def print_mem_map_defines(data, print_fn = print, raw_only = False):
    longest = max(len(x)+4 for x in data.keys())
    longest_type_bot = max([len(c_type) for base_addr, top_addr, size, translate_fn, c_type, c_type_top in data.values() if c_type is not None] + [0])
    longest_type_top = max([len(c_type_top) for base_addr, top_addr, size, translate_fn, c_type, c_type_top in data.values() if c_type_top is not None] + [0])

    longest_type = max(longest_type_bot, longest_type_top)

    if longest_type_bot > 0:
        for name, (base_addr, top_addr, size, translate_fn, c_type, c_type_top) in data.items():
            if c_type:
                padding = " " * (longest - len(name))
                padding_type = " " * (longest_type - len(c_type))

                if c_type == "RAW":
                    print_fn("#define PLATFORM_ADDR_{} {}0x{:08X}".format(name.upper(), padding, base_addr))
                elif not raw_only:
                    print_fn("#define PLATFORM_ADDR_{} {}(({}*){} 0x{:08X})".format(name.upper(), padding, c_type, padding_type, base_addr))

        print_fn("")

    if longest_type_top > 0:
        for name, (base_addr, top_addr, size, translate_fn, c_type, c_type_top) in data.items():
            if c_type_top:
                padding = " " * (longest - len(name) - 4)
                padding_type_top = " " * (longest_type - len(c_type_top))

                if c_type_top == "RAW":
                    print_fn("#define PLATFORM_ADDR_{}_TOP {}0x{:08X}".format(name.upper(), padding, top_addr))
                elif not raw_only:
                    print_fn("#define PLATFORM_ADDR_{}_TOP {}(({}*){} 0x{:08X})".format(name.upper(), padding, c_type_top, padding_type_top, top_addr))

        print_fn("")

def print_mem_map_ld(data, print_fn = print):
    longest = max(len(x)+4 for x in data.keys())
    longest_type_bot = max([len(c_type) for base_addr, top_addr, size, translate_fn, c_type, c_type_top in data.values() if c_type is not None] + [0])
    longest_type_top = max([len(c_type_top) for base_addr, top_addr, size, translate_fn, c_type, c_type_top in data.values() if c_type_top is not None] + [0])

    longest_type = max(longest_type_bot, longest_type_top)

    if longest_type_bot > 0:
        for name, (base_addr, top_addr, size, translate_fn, c_type, c_type_top) in data.items():
            if c_type:
                padding = " " * (longest - len(name))
                padding_type = " " * (longest_type - len(c_type))

                if c_type == "RAW":
                    print_fn("PLATFORM_ADDR_{} = {}0x{:08X};".format(name.upper(), padding, base_addr))

        print_fn("")

    if longest_type_top > 0:
        for name, (base_addr, top_addr, size, translate_fn, c_type, c_type_top) in data.items():
            if c_type_top:
                padding = " " * (longest - len(name) - 4)
                padding_type_top = " " * (longest_type - len(c_type_top))

                if c_type_top == "RAW":
                    print_fn("PLATFORM_ADDR_{}_TOP = {}0x{:08X};".format(name.upper(), padding, top_addr))

        print_fn("")

def print_io_map_defines(data, base_addr, print_fn = print):
    longest = max(max([len(name) for ind, name, pad_i, pad_o, pad_oe in x["options"]] + [0]) for x in data)

    for io in data:
        if io["mode"] == "standard":
            print_fn("// {}".format(io["name"]))
            padding = " " if io["index"] < 10 else ""
            print_fn("#define IO{} {}((uint32_t*) 0x{:08X})".format(io["index"], padding, base_addr + 4 * io["index"]))

            opts = io["options"] + [(0, "gpio", None, None, None)]
            opts = sorted(opts, key=lambda x: x[0])
            for ind, name, pad_i, pad_o, pad_oe in opts:
                padding = " " * (longest - len(name) + (1 if io["index"] < 10 else 0))
                print_fn("#define IO{}_MODE_{} {} {}".format(io["index"], name.upper(), padding, ind))

            print_fn("")

# Converts dict into pads
def make_pads_obj(data):
    obj = lambda: None # Junk object
    for key, value in data.items():
        setattr(obj, key, value)

    return obj
