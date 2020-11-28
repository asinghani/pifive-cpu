#include <stdint.h>
#include "util.h"

#ifndef PWM_H
#define PWM_H 1

#define PWM_DEFAULT_PERIOD 1000
void pwm_configure(void *port, uint32_t period_us);
void pwm_setpulse(void *port, uint32_t pulse_us);

// Servo output is "fixed-point" scaled between 0 and 1000
// where 0 and 1000 are the leftmost and rightmost limits
void pwm_servo_write(void *port, uint32_t output);

// Scale unsigned number between 0 and 1000 to the pulse time in us
#define SERVO_SCALE_FUNC(X) MIN((X << 1) + 500, 2500)
// Scale unsigned number between 0 and 1000 to the total period in us
#define SERVO_PERIOD(X) 20000

// Create square wave with given frequency
void pwm_tone(void *port, uint32_t frequency);

#endif
