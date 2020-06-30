_start:
    li t1, 300000
    li t2, 0
    li t3, 0x80000000
outer:
    li t0, 0
loop:
    lw t4, 4(t3)
    andi t4, t4, 1
    add t0, t0, t4
    blt t0, t1, loop
addi t2, t2, 1
sw t2, 0(t3)
j outer
