_start:
    li x1, 0x80000010 # UART status address
    li x2, 0x80000014 # UART read address
    li x3, 0x80000018 # UART write address
    li x5, 1 # Hardcoded to 1
    li x6, 2 # Hardcoded to 2

# Send ABCD to UART until buffer is full
# Should send total ~100-150 chars for a
# 128-length FIFO depending on clock and baud rate
init_loop:
    li x4, 0x41
    sb x4, 0(x3)
    li x4, 0x42
    sb x4, 0(x3)
    li x4, 0x43
    sb x4, 0(x3)
    li x4, 0x44
    sb x4, 0(x3)
    lw x4, 0(x1)
    andi x4, x4, 1
    beq x4, x5, init_loop

wait_for_ready:
    lw x4, 0(x1)
    andi x4, x4, 1
    bne x4, x5, wait_for_ready

# Read data from UART
loop_back:
    lw x4, 0(x1)
    andi x4, x4, 2
    bne x4, x6, loop_back
    lw x7, 0(x2)
    xori x7, x7, 32 # Swap case

send_value:
    lw x4, 0(x1)
    andi x4, x4, 1
    bne x4, x5, send_value
    sw x7, 0(x3)
    j loop_back
    
