package utils

import chisel3.{Bool, Data, RegNext}

object RegNextN {
    def apply[T <: Data](next: T, init: T, n: Int): T = {
        return if (n == 0) { next } else { apply[T](RegNext(next, init), init, n-1) }
    }

    def apply[T <: Data](next: T, init: T): T = apply[T](next, init, 1)

    def apply[T <: Data](next: T, n: Int): T = {
        return if (n == 0) { next } else { apply[T](RegNext(next), n-1) }
    }

    def apply[T <: Data](next: T): T = apply[T](next, 1)

    def any(next: Bool, n: Int): Bool = {
        return if (n == 0) { next } else { next | RegNext(any(next, n-1)) }
    }
}
