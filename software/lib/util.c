#include <stdint.h>
#include <stdbool.h>
#include "util.h"

// Double-dabble algorithm
// https://en.wikipedia.org/wiki/Double_dabble
void int2str(int64_t num, char *out) {
    char tmp[22];
    for (int x = 0; x < 22; x++) tmp[x] = 0;
    int smin = 19;

    bool neg = num < 0;

    uint64_t x;
    if (neg) x = -num;
    else x = num;

    uint32_t n1 = x & 0xFFFFFFFF;
    uint32_t n2 = (x >> 32) & 0xFFFFFFFF;

    for (int i = 0; i < 2; i++) {
        uint32_t n = i ? n1 : n2;

        for (int j = 0; j < 32; j++) {
            int bit_in = (n >> (31-j)) & 1;

            for (int k = smin; k < 21; k++) {
                tmp[k] += (tmp[k] >= 5) ? 3 : 0;
            }

            if (tmp[smin] >= 8) {
                smin -= 1;
            }

            for (int k = smin; k < 20; k++) {
                tmp[k] <<= 1;
                tmp[k] &= 0xF;
                tmp[k] |= (tmp[k+1] >= 8);
            }

            tmp[20] <<= 1;
            tmp[20] &= 0xF;
            tmp[20] |= bit_in;
        }
    }

    int i = 0;
    while (i < 20) {
        if (tmp[i] != 0) break;
        i++;
    }

    int j = 0;
    if (neg) out[j++] = '-';
    while (i < 21) {
        out[j++] = '0' + tmp[i++];
    }
    out[j] = 0;
}

uint32_t uint_divide(uint32_t a, uint32_t b) {
    if (b == 0) return 0; // Edge case

    uint32_t q = 0;
    int last_bit = 32;

    uint64_t a_ = a;
    uint64_t b_ = b;
    
    while (a_ >= b_) {
        for (int bit = last_bit; bit >= 0; bit--) {
            if ((b_ << bit) <= a_) {
                a_ -= (b_ << bit);
                q += (1 << bit);
                last_bit = bit;
                break;
            }
        }
    }

    return q;
}

uint64_t uint64_divide(uint64_t a, uint64_t b) {
    if (b == 0) return 0; // Edge case

    uint64_t q = 0;
    int last_bit = 64;

    uint64_t a_ = a;
    uint64_t b_ = b;
    
    while (a_ >= b_) {
        for (int bit = last_bit; bit >= 0; bit--) {
            if (((b_ << bit) >> bit) != b_) continue;

            if ((b_ << bit) <= a_) {
                a_ -= (b_ << bit);
                q += (1 << bit);
                last_bit = bit;
                break;
            }
        }
    }

    return q;
}

