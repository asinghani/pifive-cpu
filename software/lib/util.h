#include <stdint.h>

#ifndef UTIL_H
#define UTIL_H 1

// Output array must have minimum size of 24
void int2str(int64_t num, char *out);

uint32_t uint_divide(uint32_t a, uint32_t b);

uint64_t uint64_divide(uint64_t a, uint64_t b);

#define MIN(a, b) (a < b ? a : b)

#endif
