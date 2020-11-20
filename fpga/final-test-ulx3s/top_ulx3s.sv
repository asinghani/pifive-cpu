`default_nettype none

module top_ulx3s (
	output wire uart0_tx,
	input wire uart0_rx,

	output wire uart1_tx,
	input wire uart1_rx,

	output wire uart2_tx,
	input wire uart2_rx,

	inout wire i2c_sda,
	inout wire i2c_scl,

	inout wire gpio0,
	inout wire gpio1,

    output wire spi0_clk,
    output wire spi0_mosi,
    input wire spi0_miso,

    output wire oled_rstn,
    output wire oled_dc,
    output wire oled_csn,

	output wire [7:0] led,
	input wire [5:0] btn,

	input wire i_clk25,
	input wire i_rst_n
);

wire [7:0] test_out;

assign oled_rstn = test_out[0];
assign oled_dc = test_out[1];
assign oled_csn = test_out[2];

wire i2c_scl_i = i2c_scl;
wire i2c_scl_o;
wire i2c_scl_oen;

wire i2c_sda_i = i2c_sda;
wire i2c_sda_o;
wire i2c_sda_oen;

// Open-drain tristate
assign i2c_scl = i2c_scl_o ? 1'bZ : 1'b0;
assign i2c_sda = i2c_sda_o ? 1'bZ : 1'b0;

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
