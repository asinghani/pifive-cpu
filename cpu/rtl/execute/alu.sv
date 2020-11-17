`default_nettype none

`include "alu_ops.sv"

// ALU with one cycle delay
module alu #(
    parameter USE_BARREL_SHIFTER = 1
) (
    input wire [3:0] i_op,

    input wire [31:0] i_A,
    input wire [31:0] i_B,

    output reg [31:0] o_out,

    // Must not be combinationally dependent
    input wire i_valid,
    output reg o_valid,

    input wire i_clk,
    input wire i_rst
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

reg [31:0] next;
reg next_valid = 0;
always_ff @(posedge i_clk) begin
    o_valid <= 1;

    if (~o_valid && next_valid) begin
        o_valid <= 1;
        next_valid <= 0;
        o_out <= next;
    end
    else begin
        case (op)
            // TODO temporary hack, fix this
            `ALU_ADD: begin
                //o_out <= i_A + (sp ? (~i_B + 1) : i_B);
                next <= i_A + (sp ? (~i_B + 1) : i_B);
                next_valid <= 1;
                o_valid <= 0;
            end
            `ALU_XOR:  o_out <= i_A ^ i_B;
            `ALU_OR:   o_out <= i_A | i_B;
            `ALU_AND:  o_out <= i_A & i_B;
            `ALU_SLL:  o_out <= USE_BARREL_SHIFTER ? shift_out : 0;
            `ALU_SRL:  o_out <= USE_BARREL_SHIFTER ? shift_out : 0;
            `ALU_SLT:  o_out <= ($signed(i_A) < $signed(i_B)) ? 1 : 0;
            `ALU_SLTU: o_out <= (i_A < i_B) ? 1 : 0;
        endcase
    end
end

endmodule
