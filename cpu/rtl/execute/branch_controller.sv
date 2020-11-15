`default_nettype none

module branch_controller (
    input wire [31:0] i_rs1,
    input wire [31:0] i_rs2,
    input wire [2:0] i_branch_type,

    output wire o_take_branch
);

wire invert = i_branch_type[0];
wire [1:0] btype = i_branch_type[2:1];

reg condition;
assign o_take_branch = invert ? (~condition) : (condition);

always_comb begin
    case (btype)
        0: condition = (i_rs1 == i_rs2);
        2: condition = ($signed(i_rs1) < $signed(i_rs2));
        3: condition = (i_rs1 < i_rs2);
        default: condition = 0;
    endcase
end

endmodule
