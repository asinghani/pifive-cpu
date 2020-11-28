#include <stdint.h>
#include "util.h"
#include "platform.h"
#include "pwm.h"

void pwm_configure(void *port, uint32_t period_us) {
    *(((volatile uint32_t*) port) + 1) = period_us * (CLK_FREQ / 1000000);
}

void pwm_setpulse(void *port, uint32_t pulse_us) {
    *(((volatile uint32_t*) port)) = pulse_us * (CLK_FREQ / 1000000);
}

void pwm_servo_write(void *port, uint32_t output) {
    pwm_configure(port, SERVO_PERIOD(output));
    pwm_setpulse(port, SERVO_SCALE_FUNC(output));
}

void pwm_tone(void *port, uint32_t frequency) {
    if (frequency == 0) {
        *(((volatile uint32_t*) port) + 1) = 0;
        *(((volatile uint32_t*) port)) = 0;
    } else {
        uint32_t period_clks = uint_divide(CLK_FREQ, frequency);
        *(((volatile uint32_t*) port) + 1) = period_clks;
        *(((volatile uint32_t*) port)) = period_clks >> 1;
    }
}
