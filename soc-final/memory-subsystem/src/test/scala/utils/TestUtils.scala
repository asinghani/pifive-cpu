package utils

import scala.util.Random

object TestUtils {
    def randInt(random: Random, min_val: Int, max_val: Int): Int = {
        return random.nextInt(max_val - min_val) + min_val
    }

    def randInt(min_val: Int, max_val: Int): Int = {
        return randInt(new Random, min_val, max_val)
    }

    def randIntArray(random: Random, length: Int, min_val: Int, max_val: Int): Array[BigInt] = {
        return (0 until length).map(x => BigInt(random.nextInt(max_val - min_val) + min_val)).toArray
    }

    def randIntArray(random: Random, length: Int, max_val: Int): Array[BigInt] = {
        return randIntArray(random, length, 0, max_val)
    }

    def randIntArray(length: Int, min_val: Int, max_val: Int): Array[BigInt] = {
        return randIntArray(new Random, length, min_val, max_val)
    }

    def randIntArray(length: Int, max_val: Int): Array[BigInt] = {
        return randIntArray(length, 0, max_val)
    }

    // Creates a stepped range but ensures that start, end, and 0 (if within [start, end]) are included
    def testRange(start: Int, end: Int, step: Int): Array[Int] = {
        val arr = (start to end by step).toArray ++ Array(start, end) ++ (if (0 > start && 0 < end) { Array(0) } else { Array[Int]() })
        return arr.toSet.toArray
    }

    def twosCompToUnsignedAndSign(x: Int, width: Int): Int = {
        return x.abs | (x & (1 << (width - 1)))
    }

    def unsignedAndSignToTwosComp(x: Int, width: Int): Int = {
        val sign = (x & (1 << (width - 1))) == (1 << (width - 1))
        val masked = x & ((1 << (width - 1)) - 1)

        if (sign) {
            return (~masked) + 1
        } else {
            return masked
        }
    }

    def signedToUnsigned(x: Int, width: Int): Int = {
        return x & ((1 << width) - 1)
    }

    def packBytes(arr: Seq[BigInt], width: Int): BigInt = {
        var result = BigInt(0)
        for (x <- arr) {
            result = (result << width) | (x & ((BigInt(1) << width) - BigInt(1)))
        }

        return result
    }
}
