#include "build/platform_init.h"
.section    .start
.global     _start

_start:
    li sp, PLATFORM_ADDR_DMEM_TOP
    jal main
done:
    j done
