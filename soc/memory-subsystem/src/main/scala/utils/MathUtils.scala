package utils

object MathUtils {
    def intLog2(x: Int): Int = {
        val log = (Math.log(x) / Math.log(2.0)).round.toInt
        assert((1 << log) == x)
        return log
    }

    implicit class BinStrToInt(val sc: StringContext) extends AnyVal {
        def b(args: Any*): Int = {
            val strings = sc.parts.iterator
            val expressions = args.iterator
            val buf = new StringBuilder(strings.next())
            while(strings.hasNext) {
                buf.append(expressions.next())
                buf.append(strings.next())
            }

            Integer.parseInt("0" + buf, 2)
        }
    }
}
