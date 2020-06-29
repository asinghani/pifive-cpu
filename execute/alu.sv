`default_nettype none

`include "alu_ops.sv"

module alu (
    input wire [3:0] i_op,

    input wire [31:0] i_A,
    input wire [31:0] i_B,

    output wire [31:0] o_out,

    input wire i_clk
);

wire sp; // Differentiate ADD/SUB, SRL/SRA
wire [2:0] op;

wire [31:0] shift_out;
barrel_shifter shifter (
    .i_in(i_A),
    .i_amt(i_B),
    .i_dir(op[2]), // 5 = right, 1 = left
    .i_arith(sp),
    .o_out(shift_out),

    .i_clk(i_clk)
);

always_comb begin
    sp = i_op[3];
    op = i_op[2:0];

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
