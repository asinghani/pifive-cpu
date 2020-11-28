#include <stdbool.h>
#include "platform.h"
#include "io.h"
#include "util.h"

void main() {
    // Enable PWM for LED
    gpio_configure(IO7, true, IO7_MODE_PWM, IRQMODE_NONE);

    // Enable buttons (active-high, must be externally pulled down)
    // 10 = down, 11 = up
    gpio_configure(IO10, true, IO10_MODE_GPIO, IRQMODE_NONE);
    gpio_configure(IO11, true, IO11_MODE_GPIO, IRQMODE_NONE);
    gpio_oe(IO10, false);
    gpio_oe(IO11, false);

    // Between 0 and 100
    int brightness = 20;
    
    // 1kHz PWM rate
    pwm_configure(PLATFORM_ADDR_PWM3, 1000);
    while (true) {
        if (gpio_in(IO10)) {
            brightness -= 4;
            if (brightness < 0) brightness = 0;
        }

        if (gpio_in(IO11)) {
            brightness += 4;
            if (brightness > 100) brightness = 100;
        } 

        pwm_setpulse(PLATFORM_ADDR_PWM3, 10 * brightness);

        // Delay to allow holding down button (plus as debounce)
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 100000);
    }
}
