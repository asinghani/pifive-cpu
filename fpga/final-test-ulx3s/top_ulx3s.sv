`default_nettype none

module top_ulx3s (
	output wire uart0_tx,
	input wire uart0_rx,

	output wire uart1_tx,
	input wire uart1_rx,

	//output wire uart2_tx,
	//input wire uart2_rx,

	//inout wire i2c_sda,
	//inout wire i2c_scl,

	//inout wire gpio0,
	//inout wire gpio1,

    output wire spi0_clk,
    output wire spi0_mosi,
    input wire spi0_miso,

    inout wire [3:0] flash_dq,
    output wire flash_cs_n,
    output wire flash_clk,

    output wire oled_rstn,
    output wire oled_dc,
    output wire oled_csn,

	output wire [7:0] led,
	input wire [5:0] btn,

    inout wire [7:0] io_hb_dq,
    inout wire io_hb_rwds,

    output wire o_hb_rst_n,
    output wire o_hb_clk,
    output wire o_hb_cs3_n,

	input wire i_clk25,
	input wire i_rst_n
);

wire [7:0] dq_o;
wire dq_oe;
wire rwds_o;
wire rwds_oe;

assign io_hb_dq = dq_oe ? dq_o : 8'bZZZZZZZZ;
assign io_hb_rwds = rwds_oe ? rwds_o : 1'bZ;

wire [7:0] test_out;

assign oled_rstn = test_out[0];
assign oled_dc = test_out[1];
assign oled_csn = test_out[2];

/*wire i2c_scl_i = i2c_scl;
wire i2c_scl_o;
wire i2c_scl_oen;

wire i2c_sda_i = i2c_sda;
wire i2c_sda_o;
wire i2c_sda_oen;

// Open-drain tristate
assign i2c_scl = i2c_scl_o ? 1'bZ : 1'b0;
assign i2c_sda = i2c_sda_o ? 1'bZ : 1'b0;*/

wire clk;
pll pll (
	.clkin(i_clk25),
	.clkout0(clk),
	.locked()
);

soc soc (
	.sys_clk(clk),
	.sys_rst(~i_rst_n),

    .hyperram_dq_i(io_hb_dq),
    .hyperram_dq_o(dq_o),
    .hyperram_dq_oe(dq_oe),

    .hyperram_rwds_i(io_hb_rwds),
    .hyperram_rwds_o(rwds_o),
    .hyperram_rwds_oe(rwds_oe),

    .hyperram_ck(o_hb_clk),
    .hyperram_rst_n(o_hb_rst_n),
    .hyperram_cs_n(o_hb_cs3_n),
	.*
);

endmodule
