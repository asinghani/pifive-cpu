`default_nettype none
module sync_2ff
# (
    parameter DEFAULT = 0
)
(
    output reg o_out = DEFAULT,
    input wire i_in,
    
    input wire i_clk
);

reg sync = DEFAULT;

always_ff @(posedge i_clk) begin
    sync <= i_in;
    o_out <= sync;
end

endmodule

