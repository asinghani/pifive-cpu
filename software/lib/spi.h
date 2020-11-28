#include <stdint.h>

#ifndef SPI_H
#define SPI_H 1

// Default polarity and phase to 0,0 if unknown
void spi_configure(void *addr, bool clock_polarity, bool clock_phase, uint16_t div);

uint32_t spi_transfer(void *addr, uint32_t data);

#endif
