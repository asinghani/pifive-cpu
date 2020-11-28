#include <stdint.h>
#include <stdbool.h>
#include "i2c.h"

void i2c_setdivider(void *addr, uint16_t div) {
    *(((volatile uint32_t*) addr) + 3) = div;
}

void i2c_start(void *addr, uint8_t i2c_addr) {
    *(((volatile uint32_t*) addr) + 1) = (0x1 << 8) | i2c_addr;
}

void i2c_write(void *addr, uint8_t i2c_addr, uint8_t value, bool last) {
    *(((volatile uint32_t*) addr) + 2) = ((last & 0x1) << 9) | value;
    *(((volatile uint32_t*) addr) + 1) = (0x1 << 11) | i2c_addr;
}

void i2c_request(void *addr, uint8_t i2c_addr, uint8_t length) {
    for (int i = 0; i < length; i++) {
        *(((volatile uint32_t*) addr) + 1) = (0x1 << 9) | i2c_addr;
    }
}

// Need to refactor to handle FIFO overflow when doing extremely large transmissions
uint8_t i2c_read(void *addr) {
    return *(((volatile uint32_t*) addr) + 2);
}

void i2c_stop(void *addr, uint8_t i2c_addr) {
    *(((volatile uint32_t*) addr) + 1) = (0x1 << 12) | i2c_addr;
}
