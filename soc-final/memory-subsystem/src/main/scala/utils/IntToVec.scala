package utils

import chisel3._

object IntToVec {
    def apply(input: UInt, elems: Int, elem_width: Int): Vec[UInt] = {
        val out_vec = Wire(Vec(elems, UInt(elem_width.W)))

        for (i <- 0 until elems) {
            out_vec(i) := input(i * elem_width + (elem_width - 1), i * elem_width)
        }

        return out_vec
    }

}
