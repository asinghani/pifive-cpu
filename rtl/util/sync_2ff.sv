`default_nettype none
module sync_2ff
#(
    parameter DEFAULT = 0,
    parameter WIDTH = 1
)
(
    output reg [(WIDTH-1):0] o_out = DEFAULT,
    input wire [(WIDTH-1):0] i_in,
    
    input wire i_clk
);

reg [(WIDTH-1):0] sync = DEFAULT;

always_ff @(posedge i_clk) begin
    sync <= i_in;
    o_out <= sync;
end

endmodule

