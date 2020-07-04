#include "platform.h"

.section    .start
.global     _start

_start:
    // Set stack pointer
    li sp, STACK_TOP
    j main
done:
    j done
