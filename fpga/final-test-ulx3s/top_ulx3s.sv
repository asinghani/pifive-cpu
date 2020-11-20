`default_nettype none

module top_ulx3s (
	output wire uart0_tx,
	input wire uart0_rx,

	output wire uart1_tx,
	input wire uart1_rx,

	output wire uart2_tx,
	input wire uart2_rx,

	output wire [7:0] led,
	input wire [5:0] btn,

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
