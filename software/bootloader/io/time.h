#include <stdint.h>
#include "platform.h"

// Get the millisecond time
#define MILLIS_PTR ((uint32_t*) PERIPH_MILLIS)

uint32_t millis() {
    return *MILLIS_PTR;
}

// Sleep for the given number of milliseconds
void sleep(uint32_t time_ms) {
    uint32_t start_time = millis();
    while((millis() - start_time) < time_ms);
}
