#include <stdint.h>
#include <stdbool.h>

#ifndef GPIO_H
#define GPIO_H 1

#define IRQMODE_NONE    0
#define IRQMODE_RISING  1
#define IRQMODE_FALLING 2

void gpio_configure(void *port, bool enable, uint8_t mode, uint8_t irqmode);

void gpio_out(void *port, bool out);
void gpio_oe(void *port, bool oe);
bool gpio_in(void *port);

#endif
