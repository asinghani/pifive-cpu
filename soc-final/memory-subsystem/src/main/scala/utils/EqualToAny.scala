package utils

import chisel3._

object EqualToAny {
    def apply(input: UInt, values: Seq[UInt]): Bool =
        values.map(_ === input).reduce((a, b) => a | b)
}
