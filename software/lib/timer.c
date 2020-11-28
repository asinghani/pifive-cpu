#include <stdint.h>
#include <stdbool.h>
#include "platform.h"
#include "timer.h"

// Get the uptime of the core in clock-cycles (64-bit value)
uint64_t timer_uptime_clks(void *addr) {
    volatile uint32_t *lo_addr = addr;
    volatile uint32_t *hi_addr = lo_addr + 1;

    uint32_t hi1 = *hi_addr;
    uint32_t lo =  *lo_addr;
    uint32_t hi2 = *hi_addr;
    if (hi1 != hi2) lo = *lo_addr;

    return (((uint64_t) hi2) << 32) | lo;
}

#include "uart.h"

// Load and enable the given timer with an initial delay of load_us and a repeating interval of interval_us (set to 0 to use as one-shot timer)
void timer_load(void *addr, uint32_t load_us, uint32_t interval_us) {
    uint32_t load_clks = load_us * (CLK_FREQ / 1000000);
    uint32_t interval_clks = interval_us * (CLK_FREQ / 1000000);
    
    *(((uint32_t*) addr) + 4) = 0;
    *(((uint32_t*) addr) + 1) = interval_clks;
    *(((uint32_t*) addr) + 2) = load_clks;
    *(((uint32_t*) addr) + 3) = 1;
}

// Disable the given timer
void timer_disable(void *addr) {
    volatile uint32_t *enable = ((uint32_t*) addr) + 3;
    volatile uint32_t *trig   = ((uint32_t*) addr) + 4;
    *enable = 0;
    *trig = 0;
}

// Wait for the given timer to trigger
void timer_wait(void *addr) {
    volatile uint32_t *trig   = ((uint32_t*) addr) + 4;
    // Should eventually be replaced with WFI
    for(bool x = false; !x; x = *trig);
    *trig = 0;
}

// Poll the timer's current status
bool timer_poll(void *addr) {
    volatile uint32_t *trig   = ((uint32_t*) addr) + 4;
    return *trig;
} 

// Read the timer's current countdown value
uint32_t timer_counter(void *addr) {
    volatile uint32_t *ctr = ((uint32_t*) addr) + 0;
    return *ctr;
}

// Clear the timer's triggered status
void timer_clear(void *addr) {
    volatile uint32_t *trig   = ((uint32_t*) addr) + 4;
    *trig = 0;
}

// Use the given timer to sleep for a certain amount of time
// Will clear whatever else is in the timer
void timer_sleep_us(void *addr, uint32_t us) {
    timer_disable(addr);
    timer_load(addr, us, 0);
    timer_wait(addr);
    timer_disable(addr);
}
