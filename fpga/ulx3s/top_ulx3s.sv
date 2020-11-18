`default_nettype none

module top_ulx3s (
	output wire uart0_tx,
	input wire uart0_rx,

	output wire [7:0] led,
	input wire [5:0] btn,

	inout wire [3:0] flash_dq,
	output wire flash_clk,
	output wire flash_cs_n,

	input wire i_clk25,
	input wire i_rst_n
);

wire clk;

pll pll (
	.clkin(i_clk25),
	.clkout0(clk),
	.locked()
);

soc soc (
	.sys_clk(clk),
	.sys_rst(~i_rst_n),
	.*
);

endmodule
