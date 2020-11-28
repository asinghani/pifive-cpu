#include <stdint.h>
#include <stdbool.h>
#include "spi.h"

// Default polarity and phase to 0,0 if unknown
void spi_configure(void *addr, bool clock_polarity, bool clock_phase, uint16_t div) {
    *((volatile uint32_t*) addr) = ((clock_polarity & 0x1) << 17) | ((clock_phase & 0x1) << 16) | (div & 0xFFFF);
}

uint32_t spi_transfer(void *addr, uint32_t data) {
    *(((volatile uint32_t*) addr) + 1) = data;
    while(!((*(((volatile uint32_t*) addr) + 1) >> 18) & 0x1));
    return *(((volatile uint32_t*) addr) + 2);
}

