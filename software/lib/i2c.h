#include <stdint.h>
#include <stdbool.h>

#ifndef I2C_H
#define I2C_H 1

void i2c_setdivider(void *addr, uint16_t div);

void i2c_start(void *addr, uint8_t i2c_addr);

void i2c_write(void *addr, uint8_t i2c_addr, uint8_t value, bool last);

void i2c_request(void *addr, uint8_t i2c_addr, uint8_t length);

uint8_t i2c_read(void *addr);

void i2c_stop(void *addr, uint8_t i2c_addr);

#endif
