`default_nettype none

module cpu #(
    parameter INIT_PC = 32'h10000000,
    parameter USE_BARREL_SHIFTER = 1,
    parameter WISHBONE_PIPELINED = 0,
    parameter INST_STALL_BUBBLE = 1
) (
`ifdef VERIFICATION
    output wire [31:0] d_regs_out[0:31],
    output wire [31:0] d_finished_instruction,
`endif

    Wishbone.Controller instr_wb,
    Wishbone.Controller data_wb,

    input wire i_stall_in,
    input wire [31:0] i_init_pc,
    output wire o_stall_out,

    input wire i_rst,
    input wire i_clk
);

wire alu_stall;
wire inst_stall;
wire data_stall;
wire stall = alu_stall || data_stall || i_stall_in || (INST_STALL_BUBBLE ? 0 : inst_stall);

assign o_stall_out = stall;

wire inst_valid;

wire take_branch;
wire take_jump;
reg [31:0] rd_write;

instruction_t instr_1;
instruction_t instr_2;

wire [31:0] raw_instr;
reg [31:0] pc;
reg [31:0] next_pc;
reg first;

wire [31:0] data_addr;
wire [31:0] data_rdata;
wire [31:0] data_wdata;
wire [1:0] data_width;
wire data_we;
wire data_read_en;
wire data_zeroextend;

wire [31:0] pc_req;

generate
    if (|WISHBONE_PIPELINED) begin
        imembus_wbp imembus (
            .wb(instr_wb),

            .i_addr(next_pc),
            .o_data(raw_instr),
            .o_read_addr(pc_req),
            .i_re(~(stall || inst_stall)),
            .o_stall(inst_stall),
            .o_valid(inst_valid),
            .o_error(),
            .o_unaligned(),

            .i_clk(i_clk),
            .i_rst(i_rst)
        );
    end
    else begin
        imembus_wbc imembus (
            .wb(instr_wb),

            .i_addr(next_pc),
            .o_data(raw_instr),
            .o_read_addr(pc_req),
            .i_re(~(stall || inst_stall)),
            .o_stall(inst_stall),
            .o_valid(inst_valid),
            .o_error(),
            .o_unaligned(),

            .i_clk(i_clk),
            .i_rst(i_rst)
        );
    end
endgenerate

generate
    if (|WISHBONE_PIPELINED) begin
        dmembus_wbp_alignedonly dmembus (
            .wb(data_wb),
            .o_bus_width_hint(),

            .i_addr(data_addr),
            .o_data(data_rdata),
            .i_data(data_wdata),
            .i_width(data_width),
            .i_we(data_we),
            .i_re(~stall && data_read_en),
            .i_zeroextend(data_zeroextend),
            .o_stall(data_stall),
            .o_error(),
            .o_unaligned(),

            .i_clk(i_clk),
            .i_rst(i_rst)
        );
    end
    else begin
        dmembus_wbc_alignedonly dmembus (
            .wb(data_wb),
            .o_bus_width_hint(),

            .i_addr(data_addr),
            .o_data(data_rdata),
            .i_data(data_wdata),
            .i_width(data_width),
            .i_we(data_we),
            .i_re(~stall && data_read_en),
            .i_zeroextend(data_zeroextend),
            .o_stall(data_stall),
            .o_error(),
            .o_unaligned(),

            .i_clk(i_clk),
            .i_rst(i_rst)
        );
    end
endgenerate

decode decode (
    .i_instr((inst_stall && INST_STALL_BUBBLE) ? 32'h13 : raw_instr),
    .i_pc(pc_req),
    .o_out(instr_1)
);


wire [31:0] rs1_read;
wire [31:0] rs2_read;

// Forwarding
wire fwd1 = ((instr_1.rs1_addr == instr_2.rd_addr) && (instr_2.rd_addr != 0) && ~stall);
wire fwd2 = ((instr_1.rs2_addr == instr_2.rd_addr) && (instr_2.rd_addr != 0) && ~stall);
wire [31:0] rs1 = fwd1 ? rd_write : rs1_read;
wire [31:0] rs2 = fwd2 ? rd_write : rs2_read;

regfile regfile (
    .i_rd_addr(stall ? 0 : instr_2.rd_addr),
    .i_rd_data(rd_write),
    .i_rs1_addr(instr_1.rs1_addr),
    .o_rs1_data(rs1_read),
    .i_rs2_addr(instr_1.rs2_addr),
    .o_rs2_data(rs2_read),

`ifdef VERIFICATION
    .d_regs_out(d_regs_out),
`endif

    .i_clk(i_clk),
    .i_rst(i_rst)
);

wire [31:0] alu_A = (instr_1.rs1_pc) ? instr_1.pc : rs1;
wire [31:0] alu_B = (instr_1.rs2_imm) ? instr_1.imm : rs2;

// One cycle delay across ALU
wire [31:0] alu_out;
wire alu_valid;
assign alu_stall = ~alu_valid;
alu #(
    .USE_BARREL_SHIFTER(USE_BARREL_SHIFTER)
) alu (
    .i_op(instr_1.alu_op),
    .i_A(alu_A),
    .i_B(alu_B),
    .o_out(alu_out),
    .i_valid(~stall),
    .o_valid(alu_valid),
    .i_clk(i_clk),
    .i_rst(i_rst)
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

assign data_wdata = rs2;
assign data_addr = (rs1 + instr_1.imm);
assign data_width = instr_1.loadstore[1:0];
assign data_we = ~stall && (instr_1.loadstore > 4);
assign data_read_en = ~stall && ((instr_1.loadstore > 0) && (instr_1.loadstore < 4));
assign data_zeroextend = instr_1.load_zeroextend;

always_comb begin
    if (instr_2.jump) begin
        rd_write = instr_2.pc + 4;
    end
    else if ((instr_2.loadstore > 0) && (instr_2.loadstore < 4)) begin
        rd_write = data_rdata;
    end
    else begin
        rd_write = alu_out;
    end
end

always_ff @(posedge i_clk) begin
    if (i_rst) first <= 1;
    else if (inst_valid) first <= 0;
end

wire [31:0] alu_sum = alu_A + alu_B;
always_comb begin
    if (i_rst || first) begin
        next_pc = i_init_pc;
    end
    else if (stall || inst_stall) begin
        next_pc = pc;
    end
    else if (take_jump | take_branch) begin
        // Jumps and branches should ignore low bit of PC, to align to 16-bit
        // bound
        next_pc = {alu_sum[31:1], 1'b0};
    end
    else begin
        next_pc = pc + 4;
    end
end

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        instr_2 <= 0;
    end
    else if (~stall) begin
        instr_2 <= i_rst ? 0 : instr_1;
        pc <= next_pc;
    end
end

`ifdef VERIFICATION
    assign d_finished_instruction = instr_2.inst_raw[32] == 1 ? (instr_2.inst_raw[31:0]) : 0;
`endif

endmodule
