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

    print("Calculating Pi using Taylor series expansion for arctan(1)...\n");

	// Fixed-point representation (everything is scaled up by a factor of 10^8)
	uint64_t four = 400000000;
	uint64_t pi = 0;
	uint64_t last = 0;

    // Avoiding needing modulo
    int ctr = 0;
	for (uint64_t i = 0; ; i++) {
        last = pi;
        if (i % 2 == 0) {
            pi += uint_divide(four, 2*i + 1);
        } else {
            pi -= uint_divide(four, 2*i + 1);
        }

        ctr++;
        if (ctr == 10000) {
            ctr = 0;
            print("After ");
            printint(i + 1);
            print(" iterations, pi = ");
            printint((pi + last) >> 1);
            print("\n");
        }
    }
}
