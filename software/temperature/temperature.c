#include <stdbool.h>
#include "platform.h"
#include "io.h"
#include "util.h"

#define SENSOR_I2C_ADDR 0x48

// C to F for the specific fixed-point format
uint16_t convert(uint16_t x);

void main() {
    // Configure UART
    gpio_configure(IO0, true, IO0_MODE_UART, IRQMODE_NONE);
    gpio_configure(IO1, true, IO1_MODE_UART, IRQMODE_NONE);
    uart_set_default(PLATFORM_ADDR_UART0);
    uart_clear(PLATFORM_ADDR_UART0);

    print("I2C Thermometer Test\n");

    // Configure I2C
    gpio_configure(IO18, true, IO18_MODE_I2C, IRQMODE_NONE);
    gpio_configure(IO19, true, IO19_MODE_I2C, IRQMODE_NONE);
    i2c_setdivider(PLATFORM_ADDR_I2C0, 62); // ~100kHz speed

    bool fahrenheit = true;

    // Blink LED
    while (true) {
        // Request the data over I2C
        i2c_start(PLATFORM_ADDR_I2C0, SENSOR_I2C_ADDR);
        i2c_request(PLATFORM_ADDR_I2C0, SENSOR_I2C_ADDR, 2);
        i2c_stop(PLATFORM_ADDR_I2C0, SENSOR_I2C_ADDR);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 2000);

        // Format used by sensor
        // First byte is integer part, second byte is in 1/16ths
        uint16_t integer_part = i2c_read(PLATFORM_ADDR_I2C0);
        uint16_t fraction_part = i2c_read(PLATFORM_ADDR_I2C0) >> 4;

        // Convert to fixed point
        uint16_t value = (integer_part << 4) | (fraction_part & 0xFFFF);

        if (fahrenheit) {
            value = convert(value);
        }

        // Fixed-point print
        printint(value >> 4);
        print(".");
        printint_w(625 * (value & 0xFFFF), 4);
        print(fahrenheit ? " F\n" : " C\n");

        // Sample every half-second
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 500000);

        // Use UART to switch modes
        while (uart_hasc(PLATFORM_ADDR_UART0)) {
            char c = uart_getc(PLATFORM_ADDR_UART0);
            if (c == 'F' || c == 'f') fahrenheit = true;
            if (c == 'C' || c == 'c') fahrenheit = false;
        }
    }
}

// C to F conversion using fixed-point math
uint16_t convert(uint16_t x) {
    x = 9 * x;
    x = uint_divide(x, 5);
    x += 32 << 4;
    return x;
}
