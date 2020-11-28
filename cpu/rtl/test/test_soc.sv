`default_nettype none

module test_soc #(
    // Num words
    parameter BROM_SIZE = 512,
    parameter DMEM_SIZE = 512,

    // Top 4 bits
    parameter BROM_BASE = 4'h1,
    parameter DMEM_BASE = 4'h4,
    parameter PERI_BASE = 4'h8,

    parameter [1023:0] BROM_INIT = "",
    parameter [1023:0] DMEM_INIT = "",

    parameter INIT_PC = 32'h10000000,
    parameter USE_BARREL_SHIFTER = 1,
    parameter WISHBONE_PIPELINED = 0
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

Wishbone instr_wb2();
Wishbone data_wb2();

reg last_instr_stb = 0;
reg last_instr_ack = 0;
always @(posedge i_clk) begin
    last_instr_stb <= instr_wb.stb;
    last_instr_ack <= instr_wb.ack;
end

assign instr_wb2.cyc = instr_wb.cyc;
assign instr_wb2.stb = WISHBONE_PIPELINED ? instr_wb.stb : instr_wb.stb & (~last_instr_stb | last_instr_ack);
assign instr_wb2.we = instr_wb.we;
assign instr_wb2.sel = instr_wb.sel;
assign instr_wb2.addr = instr_wb.addr;
assign instr_wb2.data_wr = instr_wb.data_wr;

assign instr_wb.ack = instr_wb2.ack;
assign instr_wb.err = instr_wb2.err;
assign instr_wb.data_rd = instr_wb2.data_rd;

reg last_data_stb = 0;
reg last_data_ack = 0;
always @(posedge i_clk) begin
    last_data_stb <= data_wb.stb;
    last_data_ack <= data_wb.ack;
end

assign data_wb2.cyc = data_wb.cyc;
assign data_wb2.stb = WISHBONE_PIPELINED ? data_wb.stb : data_wb.stb & (~last_data_stb | last_data_ack);
assign data_wb2.we = data_wb.we;
assign data_wb2.sel = data_wb.sel;
assign data_wb2.addr = data_wb.addr;
assign data_wb2.data_wr = data_wb.data_wr;

assign data_wb.ack = data_wb2.ack;
assign data_wb.err = data_wb2.err;
assign data_wb.data_rd = data_wb2.data_rd;

wbram #(
    .BASE_ADDR({BROM_BASE, 28'b0}),
    .DEPTH_WORDS(BROM_SIZE),
    .INIT_FILE(BROM_INIT),
    .LATENCY(3)
) instr_ram (
    .wb(instr_wb2.Peripheral),
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
    .wb(data_wb2.Peripheral),
    .o_gpio_out(o_gpio_out),
    .i_clk(i_clk),
    .i_rst(i_rst)
);

cpu #(
    .INIT_PC(INIT_PC),
    .USE_BARREL_SHIFTER(USE_BARREL_SHIFTER),
    .WISHBONE_PIPELINED(WISHBONE_PIPELINED)
) cpu (
    .instr_wb(instr_wb.Controller),
    .data_wb(data_wb.Controller),
    .i_init_pc(32'h10000000),

`ifdef VERIFICATION
    .d_regs_out(d_regs_out),
    .d_finished_instruction(d_finished_instruction),
`endif

    .i_rst(i_rst),
    .i_clk(i_clk)
);

endmodule
