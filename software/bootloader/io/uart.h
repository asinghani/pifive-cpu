#include <stdint.h>
#include "platform.h"

#define UART_READ_PTR ((unsigned char*) PERIPH_UART_READ)
#define UART_WRITE_PTR ((unsigned char*) PERIPH_UART_WRITE)
#define UART_STATUS_PTR ((uint32_t*) PERIPH_UART_STATUS)

// Check if UART has data to read
int uart_hasc() {
    return (int) ((*UART_STATUS_PTR & 2) == 2);
}

unsigned char uart_getc() {
    while (!uart_hasc()); // Wait for data

    return (*UART_READ_PTR);
}

// Get a 32-bit word in LSB-first order
uint32_t uart_getw() {
    uint32_t word = 0;
    word |= ((uint8_t) uart_getc()) << 0;
    word |= ((uint8_t) uart_getc()) << 8;
    word |= ((uint8_t) uart_getc()) << 16;
    word |= ((uint8_t) uart_getc()) << 24;

    return word;
}

// Check if UART is ready to write
int uart_ready() {
    return (int) ((*UART_STATUS_PTR & 1) == 1);
}

void uart_putc(unsigned char c) {
    while (!uart_ready()); // Wait for buffer ready

    (*UART_WRITE_PTR) = c;
}

