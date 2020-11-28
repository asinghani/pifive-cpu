package utils

import scala.reflect.ClassTag

/**
 * Progress bar iterator, backed by an array
 */
object Pb {
    def apply[T:ClassTag](seq: Seq[T]): Iterator[T] = new PbIterator[T](seq.toArray[T])

    class PbIterator[T](back: Array[T], use_utf8: Boolean = true, pb_length: Int = 10) extends Iterator[T] {
        private var i = 0
        def hasNext(): Boolean = i < back.length

        private var running_times = Array[Double]()
        private var last_time = System.currentTimeMillis;

        private var start_time = 0;

        private val num_to_average = Math.max(2, (0.05 * back.length).ceil).toInt

        def next(): T = {
            i += 1

            if (i == 1) {
                start_time = (System.currentTimeMillis / 1000.0).toInt
            }

            running_times = running_times :+ ((System.currentTimeMillis - last_time).toDouble / 1000.0)
            if (running_times.length > num_to_average) {
                running_times = running_times.drop(running_times.length - num_to_average)
            }

            val progress_float = i.toFloat / back.length.toFloat
            val percentage = Math.min(100, Math.max(0, (100.0 * progress_float).round.toInt))
            val percentage_string = percentage.toString.reverse.padTo(3, " ").mkString("").reverse

            val elapsed_time = (System.currentTimeMillis / 1000.0).toInt - start_time
            val remaining_time = ((running_times.sum / running_times.length) * (back.length - i)).toInt
            val time_string = if (i > 1) { s"[${timeFormat(elapsed_time)}<${timeFormat(remaining_time)}]          " } else { "" }

            val progress_bar = if (use_utf8) {
                progressBarUTF8(progress_float, pb_length)
            } else {
                progressBarASCII(progress_float, pb_length)
            }

            print(s" ${percentage_string}%|${progress_bar}| ${i}/${back.length} ${time_string}")

            if (i == back.length) {
                print("\n")
            } else {
                print("\r")
            }

            Console.out.flush()

            last_time = System.currentTimeMillis
            return back(i - 1)
        }

        private def timeFormat(seconds: Int): String = {
            val hrs = (seconds.toFloat / 3600.0).floor.toInt
            val mins = (seconds.toFloat / 60.0).floor.toInt % 60
            val secs = (seconds.toFloat % 60).toInt

            return (if (hrs > 0) { s"${hrs}:" } else { "" }) + f"${mins}%02d:${secs}%02d"
        }

        private def progressBarASCII(progress: Float, pb_length: Int): String = {
            val num_boxes = Math.min((progress * pb_length.toFloat).round, pb_length)
            val progress_bar = "█" * num_boxes + " " * (pb_length - num_boxes)

            return progress_bar
        }

        private def progressBarUTF8(progress: Float, pb_length: Int): String = {
            val full_boxes = Math.min(((progress-0.001) * pb_length.toFloat).floor.toInt, pb_length)
            val last_frac = (progress - (full_boxes.toFloat / pb_length.toFloat)) * pb_length.toFloat

            val last_box = if (last_frac < 0.125) {
                " "
            } else if (last_frac < 0.375) {
                "▎"
            } else if (last_frac < 0.625) {
                "▌"
            } else if (last_frac < 0.875) {
                "▊"
            } else {
                "█"
            }

            val progress_bar = "█" * full_boxes + last_box +
                " " * (pb_length - full_boxes - 1)

            return progress_bar
        }
    }
}