#include <stdbool.h>
#include "platform.h"
#include "io.h"
#include "util.h"

void main() {
    // Enable PWM for speaker
    gpio_configure(IO4, true, IO4_MODE_PWM, IRQMODE_NONE);

    while (true) {
        // Play a short song/tune
        pwm_tone(PLATFORM_ADDR_PWM0, 262);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 250000);
        pwm_tone(PLATFORM_ADDR_PWM0, 0);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 325000);
        pwm_tone(PLATFORM_ADDR_PWM0, 196);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 125000);
        pwm_tone(PLATFORM_ADDR_PWM0, 0);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 163000);
        pwm_tone(PLATFORM_ADDR_PWM0, 196);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 125000);
        pwm_tone(PLATFORM_ADDR_PWM0, 0);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 163000);
        pwm_tone(PLATFORM_ADDR_PWM0, 220);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 250000);
        pwm_tone(PLATFORM_ADDR_PWM0, 0);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 325000);
        pwm_tone(PLATFORM_ADDR_PWM0, 196);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 250000);
        pwm_tone(PLATFORM_ADDR_PWM0, 0);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 825000); // Longer gap
        pwm_tone(PLATFORM_ADDR_PWM0, 247);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 250000);
        pwm_tone(PLATFORM_ADDR_PWM0, 0);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 325000);
        pwm_tone(PLATFORM_ADDR_PWM0, 262);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 250000);
        pwm_tone(PLATFORM_ADDR_PWM0, 0);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 325000);

        // Wait 2 seconds before starting again
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 2000000);
    }
}
