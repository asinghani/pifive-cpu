from migen import *
import math
from litex.soc.interconnect import wishbone as wb

class IOControl(Module):
    def __init__(self, pins, config, bus=None, debug_bus=None):
        if bus is None:
            self.bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.bus = bus

        if debug_bus is None:
            self.debug_bus = wb.Interface(data_width=32, adr_width=32)
        else:
            self.debug_bus = debug_bus

        self.irq = Signal()
        self.sync += self.irq.eq(0)

        io = []

        assert 0 < len(config) and len(config) < 256

        """
            Pad naming: io0, io1, io2, ...

            Config:
            [
                {
                    index: 0, # must match index of pin in array
                    name: "", # optional
                    mode: "standard/passthrough/passthrough-direct",
                    sync: True/False,
                    options: [ # Only for standard-mode
                        (ind, name, i, o, oe), # ind must not be zero
                        (ind, name, i, o, oe),
                        (ind, name, i, o, oe),
                        ... up to 16
                    ],
                    passthrough: (i, o, oe) # Only for passthrough-mode
                }
            ]

            state = {4'b0, type[1:0], actual_enable, actual_select[3:0], actual_irqmode[1:0], actual_oe, actual_out, actual_in}
            Dbg reg: {15'b0, 1'b0, state[15:0]}
            CPU reg: {state[15:0], 1'b0, enable, select[3:0], irqmode[1:0], 5'b0, gpio_oe, gpio_out, gpio_in}

            Data:
            - GPIO in
            - GPIO out
            - GPIO oe
            - enable
            - select[3:0]
            - IRQ mode[1:0] - 0 = none, 1 = rising, 2 = falling

            State:
            - Actual out
            - Actual in
            - Actual oe
            - Actual enable
            - Actual select[3:0]
            - Actual irq mode[1:0]

            - type[1:0] - 0 = standard, 1 = passthrough, 2 = passthrough-silent

        """
        # Set up I/O
        for pin_ind, pin in enumerate(config):
            assert pin["index"] == pin_ind
            mode = pin["mode"]
            assert mode in ["standard", "passthrough", "passthrough-direct"]

            if mode != "standard":
                assert "options" not in pin or len(pin["options"]) == 0
                assert "passthrough" in pin

            pad = pins["io{}".format(pin_ind)]
            ind = Constant(pin_ind, bits_sign=8)

            if pin["sync"]:
                ff1   = Signal(reset_less=True)
                ff2   = Signal(reset_less=True)
                pad_i = Signal(reset_less=True)

                self.sync += [
                    ff1.eq(pad.i),
                    ff2.eq(ff1),
                    pad_i.eq(ff2),
                ]
            else:
                pad_i = pad.i

            pad_o  = pad.o
            pad_oe = pad.oe

            if mode == "standard":
                typ = Constant(0, bits_sign=2)
            elif mode == "passthrough":
                typ = Constant(1, bits_sign=2)
            elif mode == "passthrough-direct":
                typ = Constant(2, bits_sign=2)

            last = Signal(reset=0)
            self.sync += last.eq(pad_i)

            rising   = ~pad_oe & pad_i & ~last
            falling  = ~pad_oe & last & ~pad_i

            gpio_in  = Signal(reset=0)
            gpio_out = Signal(reset=0)
            gpio_oe  = Signal(reset=0)

            irqmode  = Signal(2, reset=0)
            select   = Signal(4, reset=0)
            enable   = Signal(reset=0)

            if mode == "passthrough-direct":
                state = Cat(Constant(0, bits_sign=3), irqmode, select, enable, typ, Constant(0, bits_sign=4))
            else:
                state = Cat(pad_i, pad_o, pad_oe, irqmode, select, enable, typ, Constant(0, bits_sign=4))

            assert len(state) == 16

            dbg_reg  = Cat(state, Constant(0, bits_sign=16))
            assert len(dbg_reg) == 32

            cpu_reg  = Cat(gpio_in, gpio_out, gpio_oe, Constant(0, bits_sign=5), irqmode, select, enable, Constant(0, bits_sign=1), state)
            assert len(cpu_reg) == 32

            if mode == "passthrough-direct" or mode == "passthrough":
                self.comb += [
                    pin["passthrough"][0].eq(pad_i),
                    pad_o.eq(pin["passthrough"][1]),
                    pad_oe.eq(pin["passthrough"][2]),
                ]
            else:
                # Set up standard I/O multiplexing
                options = [x for x in pin["options"]]
                assert not any([x[0] == 0 for x in options])
                #options.append((0, "gpio", gpio_in, gpio_out, gpio_oe))

                cases = {}
                cases["default"] = [
                    pad_o.eq(gpio_out),
                    pad_oe.eq(gpio_oe),
                ]

                self.comb += gpio_in.eq(pad_i)
                for opt_ind, name, i, o, oe in options:
                    self.comb += i.eq(pad_i)
                    cases[opt_ind] = [
                        pad_o.eq(o),
                        pad_oe.eq(oe),
                    ]

                self.comb += [
                    If(~enable, pad_oe.eq(0), pad_o.eq(0)).
                    Else(Case(select, cases))
                ]

                self.sync += [
                    If(rising & irqmode == 1, self.irq.eq(1)),
                    If(falling & irqmode == 2, self.irq.eq(1))
                ]

            assert pin_ind == len(io)
            io.append({
                "index": pin_ind,
                "gpio_in": gpio_in,
                "gpio_out": gpio_out,
                "gpio_oe": gpio_oe,
                "enable": enable,
                "select": select,
                "irqmode": irqmode,
                "cpu_reg": cpu_reg,
                "dbg_reg": dbg_reg,
            })

        # Main bus access
        # CPU reg: {state[15:0], 1'b0, enable, select[3:0], irqmode[1:0], 5'b0, gpio_oe, gpio_out, gpio_in}
        self.sync += [
            self.bus.ack.eq(0),
            self.bus.err.eq(0),

            If(self.bus.stb & self.bus.cyc & ~self.bus.ack,
               self.bus.ack.eq(1),

               *[If((self.bus.adr >> 2) == port["index"],
                    self.bus.dat_r.eq(port["cpu_reg"]),
                    If(self.bus.we & self.bus.sel[0],
                       port["gpio_out"].eq(self.bus.dat_w[1]),
                       port["gpio_oe"].eq(self.bus.dat_w[2])),
                    If(self.bus.we & self.bus.sel[1],
                       port["irqmode"].eq(self.bus.dat_w[8:10]),
                       port["select"].eq(self.bus.dat_w[10:14]),
                       port["enable"].eq(self.bus.dat_w[14]))
                    ) for port in io]
              )
        ]

        # Debug bus access
        self.sync += [
            self.debug_bus.ack.eq(0),
            self.debug_bus.err.eq(0),

            If(self.debug_bus.stb & self.debug_bus.cyc & ~self.debug_bus.ack,
               self.debug_bus.ack.eq(1),

               *[If((self.debug_bus.adr >> 2) == port["index"],
                    self.debug_bus.dat_r.eq(port["dbg_reg"]),
                    ) for port in io]
              )
        ]


