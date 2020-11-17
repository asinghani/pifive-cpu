`default_nettype none

module test_soc #(
    // Num words
    parameter BROM_SIZE = 512,
    parameter DMEM_SIZE = 512,

    // Top 4 bits
    parameter BROM_BASE = 4'h1,
    parameter DMEM_BASE = 4'h4,
    parameter PERI_BASE = 4'h8,

    parameter BROM_INIT = "",
    parameter DMEM_INIT = "",

    parameter INIT_PC = 32'h10000000,
    parameter USE_BARREL_SHIFTER = 1
) (
    output wire [31:0] o_gpio_out,
    input wire [31:0] i_gpio_in,

`ifdef VERIFICATION
    output wire [31:0] d_regs_out[0:31],
    output wire [31:0] d_finished_instruction,
`endif

    input wire i_rst,
    input wire i_clk
);

Wishbone instr_wb();
Wishbone data_wb();

wbram #(
    .BASE_ADDR({BROM_BASE, 28'b0}),
    .DEPTH_WORDS(BROM_SIZE),
    .INIT_FILE(BROM_INIT),
    .LATENCY(3)
) instr_ram (
    .wb(instr_wb.Peripheral),
    .i_clk(i_clk),
    .i_rst(i_rst)
);

wbram_withgpio #(
    .BASE_ADDR({DMEM_BASE, 28'b0}),
    .GPIO_ADDR({PERI_BASE, 28'b0}),
    .DEPTH_WORDS(DMEM_SIZE),
    .INIT_FILE(DMEM_INIT),
    .LATENCY(7)
) data_ram (
    .wb(data_wb.Peripheral),
    .o_gpio_out(o_gpio_out),
    .i_clk(i_clk),
    .i_rst(i_rst)
);

cpu #(
    .INIT_PC(INIT_PC),
    .USE_BARREL_SHIFTER(USE_BARREL_SHIFTER),
    .WISHBONE_PIPELINED(1)
) cpu (
    .instr_wb(instr_wb.Controller),
    .data_wb(data_wb.Controller),

    .i_disable(0),

`ifdef VERIFICATION
    .d_regs_out(d_regs_out),
    .d_finished_instruction(d_finished_instruction),
`endif

    .i_rst(i_rst),
    .i_clk(i_clk)
);

// Shared interconnect

endmodule
