`default_nettype none

// If using a very new version of ecppll, remove the following line
`define OLD_ECPPLL

module top_ulx3s (
	output wire uart_main_dbg_tx,
	input wire uart_main_dbg_rx,

    inout wire io0,
    inout wire io1,
    inout wire io2,
    inout wire io3,
    inout wire io4,
    inout wire io5,
    inout wire io6,
    inout wire io7,
    inout wire io8,
    inout wire io9,
    inout wire io10,
    inout wire io11,
    inout wire io12,
    inout wire io13,
    inout wire io14,
    inout wire io15,
    inout wire io16,
    inout wire io17,
    inout wire io18,
    inout wire io19,

    inout wire audio_l,
    inout wire audio_r,

	output wire [7:0] led,
	input wire i_clk25,
	input wire i_rst_n
);

// Mirror PWM0/1 to audio
assign audio_l = io4;
assign audio_r = io5;

// Handle tristate I/Os
wire io0_i, io0_o, io0_oe;
assign io0 = io0_oe ? io0_o : 1'bZ;
assign io0_i = io0;
wire io1_i, io1_o, io1_oe;
assign io1 = io1_oe ? io1_o : 1'bZ;
assign io1_i = io1;
wire io2_i, io2_o, io2_oe;
assign io2 = io2_oe ? io2_o : 1'bZ;
assign io2_i = io2;
wire io3_i, io3_o, io3_oe;
assign io3 = io3_oe ? io3_o : 1'bZ;
assign io3_i = io3;
wire io4_i, io4_o, io4_oe;
assign io4 = io4_oe ? io4_o : 1'bZ;
assign io4_i = io4;
wire io5_i, io5_o, io5_oe;
assign io5 = io5_oe ? io5_o : 1'bZ;
assign io5_i = io5;
wire io6_i, io6_o, io6_oe;
assign io6 = io6_oe ? io6_o : 1'bZ;
assign io6_i = io6;
wire io7_i, io7_o, io7_oe;
assign io7 = io7_oe ? io7_o : 1'bZ;
assign io7_i = io7;
wire io8_i, io8_o, io8_oe;
assign io8 = io8_oe ? io8_o : 1'bZ;
assign io8_i = io8;
wire io9_i, io9_o, io9_oe;
assign io9 = io9_oe ? io9_o : 1'bZ;
assign io9_i = io9;
wire io10_i, io10_o, io10_oe;
assign io10 = io10_oe ? io10_o : 1'bZ;
assign io10_i = io10;
wire io11_i, io11_o, io11_oe;
assign io11 = io11_oe ? io11_o : 1'bZ;
assign io11_i = io11;
wire io12_i, io12_o, io12_oe;
assign io12 = io12_oe ? io12_o : 1'bZ;
assign io12_i = io12;
wire io13_i, io13_o, io13_oe;
assign io13 = io13_oe ? io13_o : 1'bZ;
assign io13_i = io13;
wire io14_i, io14_o, io14_oe;
assign io14 = io14_oe ? io14_o : 1'bZ;
assign io14_i = io14;
wire io15_i, io15_o, io15_oe;
assign io15 = io15_oe ? io15_o : 1'bZ;
assign io15_i = io15;
wire io16_i, io16_o, io16_oe;
assign io16 = io16_oe ? io16_o : 1'bZ;
assign io16_i = io16;
wire io17_i, io17_o, io17_oe;
assign io17 = io17_oe ? io17_o : 1'bZ;
assign io17_i = io17;
wire io18_i, io18_o, io18_oe;
assign io18 = io18_oe ? io18_o : 1'bZ;
assign io18_i = io18;
wire io19_i, io19_o, io19_oe;
assign io19 = io19_oe ? io19_o : 1'bZ;
assign io19_i = io19;

// Mirror highest I/Os to board builtin LEDs
assign led = {1'b0, io19_o, io18_o, io17_o, io16_o, io15_o, io14_o, io13_o};

wire clk;
pll pll (
`ifdef OLD_ECPPLL
	.clkin(i_clk25),
	.clkout0(clk),
`else
    .clki(i_clk25),
    .clko(clk),
`endif
	.locked()
);

// Bit of a hack to make reset not trigger on startup
reg [2:0] rst_sync;
always @(posedge clk) rst_sync <= {~i_rst_n, rst_sync[2:1]};

reg [24:0] rst_ctr = 0;
always_ff @(posedge clk) begin
    if (~rst_sync) rst_ctr <= 0;
    else if (rst_ctr < 2000000) rst_ctr <= rst_ctr + 1;
end

wire sys_rst = (rst_ctr >= 1500000);

soc soc (
	.sys_clk(clk),
	.sys_rst(sys_rst),

	.*
);

endmodule

