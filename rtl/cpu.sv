`default_nettype none

module cpu # (
    parameter BROM_SIZE = 512,
    parameter BROM_INIT = "",

    parameter IMEM_SIZE = 512,
    parameter IMEM_INIT = "",

    parameter DMEM_SIZE = 512,
    parameter DMEM_INIT = "",

    parameter INIT_PC = 32'h10000000
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

wire take_branch;
wire take_jump;
reg [31:0] rd_write;
wire kill = take_branch | take_jump;

instruction_t instr_0;

wire [31:0] raw_instr;
reg [31:0] pc = INIT_PC - 4;
reg [31:0] next_pc;

wire [31:0] data_addr;
wire [31:0] data_rdata;
wire [31:0] data_wdata;
wire [1:0] data_width;
wire data_we;
wire data_zeroextend;

memory_controller #(
    .BROM_INIT(BROM_INIT),
    .BROM_SIZE(BROM_SIZE),

    .IMEM_INIT(IMEM_INIT),
    .IMEM_SIZE(IMEM_SIZE),

    .DMEM_INIT(DMEM_INIT),
    .DMEM_SIZE(DMEM_SIZE)
) mem_controller (
    .i_inst_addr(next_pc),
    .o_inst_data(raw_instr),

    .i_data_addr(data_addr),
    .o_data_data(data_rdata),
    .i_data_data(data_wdata),
    .i_data_width(data_width),
    .i_data_we(data_we),
    .i_data_zeroextend(data_zeroextend),

    .o_gpio_out(o_gpio_out),
    .i_gpio_in(i_gpio_in),

    .i_clk(i_clk)
);

decode decode (
    .i_instr(raw_instr),
    .i_pc(pc),
    .o_out(instr_0)
);

instruction_t instr_1;

wire [31:0] rs1_read;
wire [31:0] rs2_read;

// Forwarding
wire fwd1 = ((instr_1.rs1_addr == instr_2.rd_addr) && (instr_2.rd_addr != 0));
wire fwd2 = ((instr_1.rs2_addr == instr_2.rd_addr) && (instr_2.rd_addr != 0));
wire [31:0] rs1 = fwd1 ? rd_write : rs1_read;
wire [31:0] rs2 = fwd2 ? rd_write : rs2_read;

regfile regfile (
    .i_rd_addr(instr_2.rd_addr),
    .i_rd_data(rd_write),
    .i_rs1_addr(instr_1.rs1_addr),
    .o_rs1_data(rs1_read),
    .i_rs2_addr(instr_1.rs2_addr),
    .o_rs2_data(rs2_read),

`ifdef VERIFICATION
    .d_regs_out(d_regs_out),
`endif

    .i_clk(i_clk)
);

wire [31:0] alu_A = (instr_1.rs1_pc) ? instr_1.pc : rs1;
wire [31:0] alu_B = (instr_1.rs2_imm) ? instr_1.imm : rs2;

wire [31:0] alu_out;
alu alu (
    .i_op(instr_1.alu_op),
    .i_A(alu_A),
    .i_B(alu_B),
    .o_out(alu_out)
);

wire branch_out;
assign take_branch = (branch_out && instr_1.branch);
branch_controller branch (
    .i_rs1(rs1),
    .i_rs2(rs2),
    .i_branch_type(instr_1.branch_type),
    .o_take_branch(branch_out)
);

assign take_jump = instr_1.jump;

reg [31:0] alu_last = 0;
instruction_t instr_2;

assign data_wdata = rs2;
assign data_addr = alu_out;
assign data_width = instr_1.loadstore[1:0];
assign data_we = (instr_1.loadstore > 4);
assign data_zeroextend = instr_1.load_zeroextend;

always_comb begin
    if (instr_2.jump) begin
        rd_write = instr_2.pc + 4;
    end
    else if ((instr_2.loadstore > 0) && (instr_2.loadstore < 4)) begin
        rd_write = data_rdata;
    end
    else begin
        rd_write = alu_last;
    end
end

always_comb begin
    if (i_rst) begin
        next_pc = INIT_PC;
    end
    else if (take_jump | take_branch) begin
        next_pc = alu_out;
    end
    else begin
        next_pc = pc + 4;
    end
end

initial begin
    instr_1 = 0;
    instr_2 = 0;
end

always_ff @(posedge i_clk) begin
    instr_1 <= kill ? 0 : instr_0;
    instr_2 <= instr_1;
    alu_last <= alu_out;

    pc <= next_pc;
end

`ifdef VERIFICATION
    assign d_finished_instruction = instr_2.instr_raw[32] == 1 ? (instr_2.inst_raw[31:0]) : 0;
`endif

endmodule
