#include <stdbool.h>
#include "platform.h"
#include "io.h"
#include "util.h"

void main() {
    // Enable LED
    gpio_configure(IO13, true, IO13_MODE_GPIO, IRQMODE_NONE);
    gpio_oe(IO13, true);

    // Enable servo PWM
    gpio_configure(IO6, true, IO6_MODE_PWM, IRQMODE_NONE);

    while (true) {
        // Sweep forward
        for (int i = 0; i < 1000; i += 5) {
            pwm_servo_write(PLATFORM_ADDR_PWM2, i);
            timer_sleep_us(PLATFORM_ADDR_TIMER0, 20000);
        }

        // Blink LED at ends
        gpio_out(IO13, 1);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 1000000);
        gpio_out(IO13, 0);

        // Sweep backward
        for (int i = 1000; i > 0; i -= 5) {
            pwm_servo_write(PLATFORM_ADDR_PWM2, i);
            timer_sleep_us(PLATFORM_ADDR_TIMER0, 20000);
        }

        // Blink LED at ends
        gpio_out(IO13, 1);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 1000000);
        gpio_out(IO13, 0);
    }
}
