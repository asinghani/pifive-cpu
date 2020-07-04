#include <stdint.h>
#include "utils.h"

// Allow for expansion of macros in inline ASM
#define STR(x) #x
#define XSTR(s) STR(s)

int main() {
    gpio_out(0, 1);
    sleep(250);
    gpio_out(0, 0);

    volatile uint8_t *program_mem_ptr = (uint8_t*) PROG_MEM_BASE;
    volatile uint8_t *data_mem_ptr = (uint8_t*) DATA_MEM_BASE;

    // First 4 bytes is length of program
    uint32_t prog_length = uart_getw();
    uint8_t prog_checksum_calc = 0;
    
    for(int i = 0; i < prog_length; i++) {
        uint8_t x = (uint8_t) uart_getc();
        prog_checksum_calc += x;
        *(program_mem_ptr + i) = x;
    }

    // Next 4 bytes is length of data section
    uint32_t data_length = uart_getw();
    uint8_t data_checksum_calc = 0;
    
    for(int i = 0; i < data_length; i++) {
        uint8_t x = (uint8_t) uart_getc();
        data_checksum_calc += x;
        *(data_mem_ptr + i) = x;
    }

    // Last 2 bytes is program and data checksum
    uint8_t prog_checksum_ref = (uint8_t) uart_getc();
    uint8_t data_checksum_ref = (uint8_t) uart_getc();

    if (prog_checksum_ref != prog_checksum_calc) {
        uart_putc(0x11); // Program checksum failed
        while (1);
    }

    if (data_checksum_ref != data_checksum_calc) {
        uart_putc(0x12); // Data checksum failed
        while (1);
    }

    uart_putc(0x13); // Successful upload

    // Jump to start of instruction memory
    __asm__("lui t0, " XSTR(PROG_MEM_BASE >> 12) "\n\tjalr x0, t0, " XSTR(PROG_MEM_BASE & 0xFFF));

    while(1); // Program should never return to bootloader
}
