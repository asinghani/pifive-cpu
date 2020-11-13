`default_nettype none

`include "alu_ops.sv"

module alu (
    input wire [3:0] i_op,

    input wire [31:0] i_A,
    input wire [31:0] i_B,

    output reg [31:0] o_out,

    // Used for memory acccesses
    // Less space-efficient, more clock-efficient
    // than using o_out w/ (i_op = 0)
    output wire [31:0] o_sum,

    output reg stall = 0,
    input wire i_clk
);

wire sp = i_op[3]; // Differentiate ADD/SUB, SRL/SRA
wire [2:0] op = i_op[2:0];

wire [31:0] shift_out;
barrel_shifter shifter (
    .i_in(i_A),
    .i_amt(i_B[4:0]),
    .i_dir(op[2]), // 5 = right, 1 = left
    .i_arith(sp),
    .o_out(shift_out)
);

always_ff @(posedge i_clk) begin
    stall <= ~stall;
end

assign o_sum = i_A + i_B;

always_comb begin

    case (op)
        `ALU_ADD:  o_out = i_A + (sp ? (~i_B + 1) : i_B);
        `ALU_XOR:  o_out = i_A ^ i_B;
        `ALU_OR:   o_out = i_A | i_B;
        `ALU_AND:  o_out = i_A & i_B;
        `ALU_SLL:  o_out = shift_out;
        `ALU_SRL:  o_out = shift_out;
        `ALU_SLT:  o_out = ($signed(i_A) < $signed(i_B)) ? 1 : 0;
        `ALU_SLTU: o_out = (i_A < i_B) ? 1 : 0;
    endcase
end

endmodule
