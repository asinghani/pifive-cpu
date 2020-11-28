#include <stdint.h>
#include <stdbool.h>

#ifndef UART_H
#define UART_H 1

char uart_getc(void *addr);
void uart_putc(void *addr, char c);
bool uart_hasc(void *addr);
bool uart_ready(void *addr);
void uart_setdivider(void *addr, uint16_t div);
void uart_clear(void *addr);

void uart_set_default(void *addr);

// Following use the default UART (selected by uart_set_default)
char getc();
void putc(char c);
bool hasc();
void print(const char *c);
void println(const char *c);
void printint(int64_t x);

// Force integer to be padded with zeros (useful for fixed point hacks)
void printint_w(int64_t x, uint8_t width);

#endif
