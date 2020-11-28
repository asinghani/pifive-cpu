from simpleriscv import asm
from bitstring import Bits

# Emulate the li pseudoinstruction
def immgen(p, reg, val):
    assert val > -(2**31) and val < (2**31 - 1)
    binary = Bits(int=val, length=40).bin
    low = Bits(bin=binary[-12:])
    high = val - low.int
    highbin = Bits(int=high, length=40).bin[-32:-12]
    high = Bits(bin=highbin)

    low = low.int
    high = high.int

    p.LUI(reg, high)
    p.ADDI(reg, reg, low)

ind = 0
def uart_getc(p, dst_reg, uart_addr_reg):
    global ind
    ind += 1
    lab = "getc{}".format(ind)
    p.LABEL(lab)

    # Wait until !rx_fifo_empty
    p.LW(dst_reg, uart_addr_reg, 0x0)
    p.ANDI(dst_reg, dst_reg, 0x1)
    p.BNE(dst_reg, "zero", lab)

    p.LW(dst_reg, uart_addr_reg, 0xC)
    p.ANDI(dst_reg, dst_reg, 0xFF)

def uart_getw(p, dst_reg, tmp_reg, uart_addr_reg):
    p.ADDI(dst_reg, "zero", 0)

    for x in range(0, 32, 8):
        uart_getc(p, tmp_reg, uart_addr_reg)
        p.SLLI(tmp_reg, tmp_reg, x)
        p.OR(dst_reg, dst_reg, tmp_reg)

# TODO this could be made shorter by using proper function calls
def bootrom(ioctrl_addr, uptime_timer_addr, uart_addr, uart_io_ind, tx_port, rx_port, led_port, imem_base, dmem_base, clk):
    p = asm.Program()
    p.LI = lambda reg, val: immgen(p, reg, val)

    # Blink LED for 0.5 second
    led_blink_time = clk // 2
    p.LI("s0", ioctrl_addr)
    p.LI("s1", uptime_timer_addr)

    p.LW("t0", "s1", 0) # Load from timer
    p.LI("t1", led_blink_time)
    p.ADD("t0", "t0", "t1") # t0 = (init time) + (blink time)

    # Turn on LED
    p.LI("t2", 0b0100000000000110)
    p.SW("s0", "t2", 4 * led_port)

    # Wait until time > t0
    p.LABEL("led_loop")
    p.LW("t1", "s1", 0) # Load from timer
    p.BLTU("t1", "t0", "led_loop")

    # Turn off and disable LED
    p.LI("t2", 0b0000000000000000)
    p.SW("s0", "t2", 4 * led_port)

    # Configure UART pins
    p.LI("t2", 0b0100000000000000 | (uart_io_ind << 10))
    p.SW("s0", "t2", 4 * rx_port)
    p.SW("s0", "t2", 4 * tx_port)

    # Configure UART baud
    uart_divider = int((clk / 115200) / 2)
    p.LI("s0", uart_addr)
    uart_addr_reg = "s0"

    p.LI("t2", uart_divider)
    p.SW(uart_addr_reg, "t2", 0x4)

    # Send an init value
    p.LI("t0", 0x5)
    p.SW(uart_addr_reg, "t0", 0x8)

    ctr_reg = "a0"
    prog_top_reg = "a1"
    data_top_reg = "a2"

    prog_checksum = "a3"
    data_checksum = "a4"

    prog_base = "a5"
    data_base = "a6"

    # Get program length and addresses
    uart_getw(p, prog_base, "t0", uart_addr_reg)
    uart_getw(p, prog_top_reg, "t0", uart_addr_reg)

    uart_getw(p, data_base, "t0", uart_addr_reg)
    uart_getw(p, data_top_reg, "t0", uart_addr_reg)

    p.ADD(prog_top_reg, prog_top_reg, prog_base)
    p.ADD(data_top_reg, data_top_reg, data_base)

    for base, top, chk, name in [
            (prog_base, prog_top_reg, prog_checksum, "prog"),
            (data_base, data_top_reg, data_checksum, "data")]:
        # Loop start
        p.ADDI(ctr_reg, base, 0)
        p.LI(chk, 0)

        p.LABEL(name+"_loop")
        p.BGE(ctr_reg, top, name+"_end")

        # Read byte and save
        uart_getc(p, "t0", uart_addr_reg)
        p.ADD(chk, chk, "t0")
        p.SB(ctr_reg, "t0", 0)

        # Send ack every 16 bytes
        p.ANDI("t1", ctr_reg, 0xF)
        p.BNE("t1", "zero", name+"_no_ack")
        p.LI("t0", 0x6)
        p.SW(uart_addr_reg, "t0", 0x8)
        p.LABEL(name+"_no_ack")

        # Loop counter
        p.ADDI(ctr_reg, ctr_reg, 1)
        p.JAL("zero", name+"_loop")
        p.LABEL(name+"_end")

    prog_checksum_ref = "a5"
    data_checksum_ref = "a6"

    uart_getc(p, prog_checksum_ref, uart_addr_reg)
    uart_getc(p, data_checksum_ref, uart_addr_reg)

    p.ANDI(prog_checksum, prog_checksum, 0xFF)
    p.ANDI(data_checksum, data_checksum, 0xFF)

    # Check program checksum
    p.BEQ(prog_checksum, prog_checksum_ref, "prog_checksum_pass")
    p.LI("t0", 0x11)
    p.SW(uart_addr_reg, "t0", 0x8)
    p.JAL("zero", "stall")
    p.LABEL("prog_checksum_pass")

    # Check program checksum
    p.BEQ(data_checksum, data_checksum_ref, "data_checksum_pass")
    p.LI("t0", 0x12)
    p.SW(uart_addr_reg, "t0", 0x8)
    p.JAL("zero", "stall")
    p.LABEL("data_checksum_pass")

    p.LI("t0", 0x13)
    p.SW(uart_addr_reg, "t0", 0x8)

    # Get init address and jump to it
    dst_reg = "t6"
    uart_getw(p, dst_reg, "t0", uart_addr_reg)

    # Wait 2 seconds before launching program
    p.LI("s1", uptime_timer_addr)
    wait_time = 2 * clk
    p.LW("t0", "s1", 0) # Load from timer
    p.LI("t1", wait_time)
    p.ADD("t0", "t0", "t1") # t0 = (init time) + (wait time)

    # Wait until time > t0
    p.LABEL("wait_loop")
    p.LW("t1", "s1", 0) # Load from timer
    p.BLTU("t1", "t0", "wait_loop")

    # Jump to program init location
    p.JALR("ra", dst_reg, 0)

    # Program should never get here
    p.LABEL("stall")
    p.JAL("zero", "stall")

    return p.machine_code
