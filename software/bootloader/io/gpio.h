#include <stdint.h>
#include "platform.h"

#define GPIO_OUT_PTR ((uint32_t*) PERIPH_GPIO_OUT)
#define GPIO_IN_PTR ((uint32_t*) PERIPH_GPIO_IN)

uint32_t gpio_read() {
    return (*GPIO_IN_PTR);
}

void gpio_write(uint32_t value) {
    (*GPIO_OUT_PTR) = value;
}

// Write to the GPIO but only write the bits for which the relevant mask bit is 1
void gpio_writemasked(uint32_t value, uint32_t mask) {
    uint32_t value_out = (value & mask) | ((*GPIO_OUT_PTR) & (~mask));
    gpio_write(value_out);
}

// Write a boolean value to a single GPIO port
void gpio_out(int port, int value) {
    uint32_t value_out = (value == 1) ? (1 << port) : 0;
    uint32_t mask_out = (1 << port);

    gpio_writemasked(value_out, mask_out);
}

// Read a boolean value from a single GPIO port
int gpio_in(int port) {
    uint32_t data = gpio_read();

    return (data & (1 << port)) == (1 << port);
}
