#include <stdint.h>
#include <stdbool.h>
#include "gpio.h"

void gpio_configure(void *port, bool enable, uint8_t mode, uint8_t irqmode) {
    uint32_t status = *((volatile uint32_t*) port);

    // If still using direct GPIO control mode, retain the previous outputs, else zero them
    uint8_t next_out_oe = (mode == 0 && enable) ? (status & 0x7) : 0x0;

    // {state[15:0], 1'b0, enable, select[3:0], irqmode[1:0], 5'b0, gpio_oe, gpio_out, gpio_in}
    *((volatile uint32_t*) port) = ((enable & 0x1) << 14) | ((mode & 0xF) << 10) | ((irqmode & 0x3) << 8) | next_out_oe;
}

void gpio_out(void *port, bool out) {
    uint32_t status = *((volatile uint32_t*) port);
    // {state[15:0], 1'b0, enable, select[3:0], irqmode[1:0], 5'b0, gpio_oe, gpio_out, gpio_in}
    // 0b0_1_1111_11_00000_100 = 0x7F04
    *((volatile uint32_t*) port) = (status & 0x7F04) | ((out & 0x1) << 1);
}

void gpio_oe(void *port, bool oe) {
    uint32_t status = *((volatile uint32_t*) port);
    // {state[15:0], 1'b0, enable, select[3:0], irqmode[1:0], 5'b0, gpio_oe, gpio_out, gpio_in}
    // 0b0_1_1111_11_00000_010 = 0x7F02
    *((volatile uint32_t*) port) = (status & 0x7F02) | ((oe & 0x1) << 2);
}

bool gpio_in(void *port) {
    return *((volatile uint32_t*) port) & 0x1;
}
