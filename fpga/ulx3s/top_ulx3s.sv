`default_nettype none

module top_ulx3s (
	output wire uart0_tx,
	input wire uart0_rx,

	output wire [7:0] led,
	input wire [5:0] btn,

	inout wire [3:0] flash_dq,
	output wire flash_clk,
	output wire flash_cs_n,

	input wire jtag_tck,
	input wire jtag_tms,
	input wire jtag_tdi,
	output wire jtag_tdo,

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

JtagTest JtagTest (
    .io_jtag_TCK(jtag_tck),
    .io_jtag_TMS(jtag_tms),
    .io_jtag_TDI(jtag_tdi),
    .io_jtag_TDO_data(jtag_tdo),
    .io_jtag_TDO_driven(),
    .io_out0(led),
    .io_out1(),
    .io_out2()
);

endmodule
