package utils

import chisel3._

object PseudoLatch {
    def apply[T <: Data](cond: Bool, value: T, init: T): T = {
        val reg = RegInit(init)
        when (cond) { reg := value }
        return Mux(cond, value, reg)
    }

    def apply[T <: Data](cond: Bool, value: T): T = {
        val reg = Reg(value.cloneType)
        when (cond) { reg := value }
        return Mux(cond, value, reg)
    }
}
