#ifndef PLATFORM_H
#define PLATFORM_H

/**
 * Define memory locations of MMIO
 **/
#define PERIPH_MILLIS      0x80000020

#define PERIPH_UART_READ   0x80000014
#define PERIPH_UART_WRITE  0x80000018
#define PERIPH_UART_STATUS 0x80000010

#define PERIPH_GPIO_OUT    0x80000000
#define PERIPH_GPIO_IN     0x80000004

// Other setup
#define STACK_TOP     0x40008000
#define PROG_MEM_BASE 0x20000000
#define DATA_MEM_BASE 0x40000000

#endif
