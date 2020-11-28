#include <stdbool.h>
#include "platform.h"
#include "io.h"
#include "util.h"

void main() {
    // Configure UART
    gpio_configure(IO0, true, IO0_MODE_UART, IRQMODE_NONE);
    gpio_configure(IO1, true, IO1_MODE_UART, IRQMODE_NONE);
    uart_set_default(PLATFORM_ADDR_UART0);
    uart_clear(PLATFORM_ADDR_UART0);

    print("Hello World!\n");

    // Enable LED to blink
    gpio_configure(IO13, true, IO13_MODE_GPIO, IRQMODE_NONE);
    gpio_oe(IO13, true);

    // Blink LED
    while (true) {
        gpio_out(IO13, 1);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 1000000);

        gpio_out(IO13, 0);
        timer_sleep_us(PLATFORM_ADDR_TIMER0, 1000000);
    }
}
