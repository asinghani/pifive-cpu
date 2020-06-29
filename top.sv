`ifdef VERILATOR
`default_nettype none
`endif

module top (
    output wire [31:0] led,
    output wire [31:0] led2,
    input wire [31:0] btn,
    input wire prs,
    input wire prs2,
    input wire [2:0] prs3,

    input wire i_clk
);

reg [11:0] ctr = 0;

bram32 #(
    .DEPTH(4096)
) bram (
    .o_data(led),
    .i_addr(ctr),
    .i_data(btn),
    .i_we(prs2),
    .i_wr_subaddr(prs3),
    .i_clk(i_clk)
);

rom32 #(
    .DEPTH(512),
    .INIT_FILE("init.txt")
) romom (
    .o_data(led2),
    .i_addr(ctr+4),
    .i_clk(i_clk)
);

always_ff @(posedge i_clk) begin
    if (prs) begin
        ctr <= ctr + 1;
    end
end

endmodule
