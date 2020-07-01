.section    .start
.global     _start

_start:
    // Set stack pointer
    li sp, 0x40008000
    j main
done:
    j done
