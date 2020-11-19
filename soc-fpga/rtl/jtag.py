# Based on https://raw.githubusercontent.com/lambdaconcept/jtagtap/master/jtagtap/tap.py

import math
from migen import *

class RegNextN(Module):
    def __init__(self, out_wire, in_wire, num_ff=1):
        regs = []

        if num_ff == 0:
            self.comb += out_wire.eq(in_wire)
        else:
            tmp = Signal.like(in_wire)
            self.sync += tmp.eq(in_wire)
            self.submodules += RegNextN(out_wire, tmp, num_ff=num_ff-1)

class JTAGTAP(Module):
    def __init__(self, pads, regs, ir_width=10, sync_ffs=2):
        self.regs = {
            index: Record([
                ("read_data", width, DIR_S_TO_M),
                ("write_data", width, DIR_M_TO_S),
                ("write_valid", 1, DIR_M_TO_S)
            ]) for index, width in regs.items()
        }

        ir = Signal(ir_width, reset=2)
        dr = Signal(max([width for index, width in regs.items()]))

        tck = Signal()
        tdi = Signal()
        tms = Signal()
        self.submodules += [
            RegNextN(tck, pads.tck, num_ff=sync_ffs),
            RegNextN(tdi, pads.tdi, num_ff=sync_ffs),
            RegNextN(tms, pads.tms, num_ff=sync_ffs)
        ]

        last_tck = Signal()
        tck_rising = Signal()
        tck_falling = Signal()
        tck_low = Signal()

        self.sync += [
            last_tck.eq(tck),
            tck_low.eq(tck_falling)
        ]

        self.comb += [
            tck_rising.eq(~last_tck & tck),
            tck_falling.eq(last_tck & ~tck)
        ]

        ntms = Signal()
        ntdi = Signal()
        self.sync += [
            If(tck_rising, ntms.eq(tms)),
            If(tck_rising, ntdi.eq(tdi))
        ]


        self.submodules.fsm = fsm = FSM(reset_state="TEST-LOGIC-RESET")

        fsm.act("TEST-LOGIC-RESET",
            NextValue(ir, 2),
            If(tck_falling,
                If(ntms, NextState("TEST-LOGIC-RESET")).
                Else(NextState("RUN-TEST-IDLE"))
            )
        )

        fsm.act("RUN-TEST-IDLE",
            If(tck_falling & ntms, NextState("SELECT-DR-SCAN"))
        )

        fsm.act("SELECT-DR-SCAN",
            If(tck_falling,
                If(ntms, NextState("SELECT-IR-SCAN")).
                Else(NextState("CAPTURE-DR"))
            )
        )

        fsm.act("CAPTURE-DR",
            *[If(ir == ind, NextValue(dr, reg.read_data))
              for ind, reg in self.regs.items()],
            If(tck_falling,
                If(ntms, NextState("EXIT1-DR")).
                Else(NextState("SHIFT-DR"))
            )
        )

        fsm.act("SHIFT-DR",
            pads.tdo.eq(dr[0]),
            *[If(ir == ind & tck_falling,
                 NextValue(dr, Cat(dr[1:len(reg.read_data)], ntdi)))
                 for ind, reg in self.regs.items()],

            If(tck_falling,
                If(ntms, NextState("EXIT1-DR"))
            )
        )

        fsm.act("EXIT1-DR",
            pads.tdo.eq(0),
            If(tck_falling,
                If(ntms, NextState("UPDATE-DR")).
                Else(NextState("PAUSE-DR"))
            )
        )

        fsm.act("PAUSE-DR",
            If(tck_falling & ntms, NextState("EXIT2-DR"))
        )

        fsm.act("EXIT2-DR",
            If(tck_falling,
                If(ntms, NextState("UPDATE-DR")).
                Else(NextState("SHIFT-DR"))
            )
        )

        fsm.act("UPDATE-DR",
            *[If(ir == ind,
                 NextValue(reg.write_data, dr),
                 reg.write_valid.eq(tck_falling))
                 for ind, reg in self.regs.items()],
            If(tck_falling,
                If(ntms, NextState("SELECT-DR-SCAN")).
                Else(NextState("RUN-TEST-IDLE"))
            )
        )

        fsm.act("SELECT-IR-SCAN",
            If(tck_falling,
                If(ntms, NextState("TEST-LOGIC-RESET")).
                Else(NextState("CAPTURE-IR"))
            )
        )

        fsm.act("CAPTURE-IR",
            If(tck_falling,
                If(ntms, NextState("EXIT1-IR")).
                Else(NextState("SHIFT-IR"))
            )
        )

        fsm.act("SHIFT-IR",
            pads.tdo.eq(ir[0]),
            If(tck_falling,
                NextValue(ir, Cat(ir[1:], ntdi)),
                If(ntms, NextState("EXIT1-IR"))
            )
        )

        fsm.act("EXIT1-IR",
            pads.tdo.eq(0),
            If(tck_falling,
                If(ntms, NextState("UPDATE-IR")).
                Else(NextState("PAUSE-IR"))
            )
        )

        fsm.act("PAUSE-IR",
            If(tck_falling & ntms, NextState("EXIT2-IR"))
        )

        fsm.act("EXIT2-IR",
            If(tck_falling,
                If(ntms, NextState("UPDATE-IR")).
                Else(NextState("SHIFT-IR"))
            )
        )

        fsm.act("UPDATE-IR",
            If(tck_falling,
                If(ntms, NextState("SELECT-DR-SCAN")).
                Else(NextState("RUN-TEST-IDLE"))
            )
        )
