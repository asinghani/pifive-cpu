package utils

import chisel3._

object RisingEdge {
    def apply(x: Bool): Bool = x && !RegNext(x)
}
