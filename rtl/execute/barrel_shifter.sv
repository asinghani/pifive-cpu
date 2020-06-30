`default_nettype none

// Variable-amount shifter
// Defined explicitly as a barrel shifter to limit reliance on synthesis tools
module barrel_shifter (
    input wire [31:0] i_in,
    input wire [4:0] i_amt,
    input wire i_dir, // 0 = left, 1 = right
    input wire i_arith, // 0 = logical, 1 = arithmetic
    output reg [31:0] o_out
);

reg [31:0] lt_shifts[0:31];
reg [31:0] rt_shifts[0:31];

integer ind;
always_comb begin
    for(ind = 0; ind < 32; ind = ind + 1) begin
        lt_shifts[ind] = i_in << ind;
        rt_shifts[ind] = i_arith ? (i_in >>> ind) : (i_in >> ind);
    end

    o_out = i_dir ? (rt_shifts[i_amt]) : (lt_shifts[i_amt]);
end

endmodule
