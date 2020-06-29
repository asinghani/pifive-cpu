`ifdef VERILATOR
`default_nettype none
`endif

module top (
    output wire [7:0] led,
    input wire [4:0] btn,

    input wire i_clk
);

endmodule
