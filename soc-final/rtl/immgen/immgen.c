#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 2) return -1;

    int32_t val = strtol(argv[1], NULL, 0);
    int32_t low = (val << 20) >> 20;
    int32_t high = ((val - low) >> 12);

    printf("%d,%d\n", low, high);
    
    return 0;
}
