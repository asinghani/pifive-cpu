_start:
    li t1, 500000
    li t2, 0
    li t3, 0x80000000
outer:
    li t0, 0
loop:
    addi t0, t0, 1
    blt t0, t1, loop
addi t2, t2, 1
sw t2, 0(t3)
j outer
