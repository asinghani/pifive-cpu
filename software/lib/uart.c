#include "uart.h"
#include "util.h"

char uart_getc(void *addr) {
    uint32_t *base = addr;
    while (!uart_hasc(addr));
    return (char) *(base + 3);
}

void uart_putc(void *addr, char c) {
    uint32_t *base = addr;
    while(!uart_ready(addr));
    *(base + 2) = c;
}

bool uart_hasc(void *addr) {
    uint32_t *base = addr;
    return ((*(base + 0)) & 0x1) == 0;
}

bool uart_ready(void *addr) {
    uint32_t *base = addr;
    return ((*(base + 0)) & 0x8) == 0;
}

void uart_setdivider(void *addr, uint16_t div) {
    uint32_t *base = addr;
    *(base + 1) = div;
}

void uart_clear(void *addr) {
    uint32_t *base = addr;
    while ((*base) != 0x5) {
        if (uart_hasc(addr)) uart_getc(addr);
    }
}

void *default_uart = 0;
void uart_set_default(void *addr) {
    default_uart = addr;
}

char getc() {
    return uart_getc(default_uart);
}

void putc(char c) {
    uart_putc(default_uart, c);
}

bool hasc() {
    return uart_hasc(default_uart);
}

void print(const char *c) {
    while (*c) putc(*(c++));
}

void println(const char *c) {
    print(c);
    print("\n");
}

void printint(int64_t x) {
    char str[24];
    int2str(x, str);
    print(str);
}

void printint_w(int64_t x, uint8_t width) {
    char str[24 + width];
    for (int i = 0; i < width; i++) str[i] = '0';
    int2str(x, ((char*)str) + width);
    int i = 0;
    for (i = 0; i < (24 + width); i++) if (!str[i]) break;
    i = i - width;
    print(((char*)str) + i);
}

