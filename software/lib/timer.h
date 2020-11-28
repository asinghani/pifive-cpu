#include <stdint.h>
#include <stdbool.h>

#ifndef TIMER_H
#define TIMER_H 1

// Get the uptime of the core in clock-cycles (64-bit value)
uint64_t timer_uptime_clks(void *addr);

// Load and enable the given timer with an initial delay of load_us and a repeating interval of interval_us (set to 0 to use as one-shot timer)
void timer_load(void *addr, uint32_t load_us, uint32_t interval_us);

// Disable the given timer
void timer_disable(void *addr);

// Wait for the given timer to trigger
void timer_wait(void *addr);

// Poll the timer's current status
bool timer_poll(void *addr);

// Read the timer's current countdown value
uint32_t timer_counter(void *addr);

// Clear the timer's triggered status
void timer_clear(void *addr);

// Use the given timer to sleep for a certain amount of time
// Will clear whatever else is in the timer
void timer_sleep_us(void *addr, uint32_t us);

#endif
