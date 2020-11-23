`default_nettype none

module top_ulx3s (
	output wire uart_user_dbg_tx,
	input wire uart_user_dbg_rx,

	output wire uart_mgmt_dbg_tx,
	input wire uart_mgmt_dbg_rx,

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

	output wire [7:0] led,
	input wire i_clk25,
	input wire i_rst_n
);

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
wire io18_i = 1; // Placeholder
wire io18_o; // Placeholder
wire io18_oe; // Placeholder
wire io19_i = 1; // Placeholder
wire io19_o; // Placeholder
wire io19_oe; // Placeholder
wire io20_i = 1; // Placeholder
wire io20_o; // Placeholder
wire io20_oe; // Placeholder
wire io21_i = 1; // Placeholder
wire io21_o; // Placeholder
wire io21_oe; // Placeholder
wire io22_i = 1; // Placeholder
wire io22_o; // Placeholder
wire io22_oe; // Placeholder
wire io23_i = 1; // Placeholder
wire io23_o; // Placeholder
wire io23_oe; // Placeholder
wire io24_i = 1; // Placeholder
wire io24_o; // Placeholder
wire io24_oe; // Placeholder
wire io25_i = 1; // Placeholder
wire io25_o; // Placeholder
wire io25_oe; // Placeholder
wire io26_i = 1; // Placeholder
wire io26_o; // Placeholder
wire io26_oe; // Placeholder
wire io27_i = 1; // Placeholder
wire io27_o; // Placeholder
wire io27_oe; // Placeholder
wire io28_i = 1; // Placeholder
wire io28_o; // Placeholder
wire io28_oe; // Placeholder
wire io29_i = 1; // Placeholder
wire io29_o; // Placeholder
wire io29_oe; // Placeholder
wire io30_i = 1; // Placeholder
wire io30_o; // Placeholder
wire io30_oe; // Placeholder
wire io31_i = 1; // Placeholder
wire io31_o; // Placeholder
wire io31_oe; // Placeholder
wire io32_i = 1; // Placeholder
wire io32_o; // Placeholder
wire io32_oe; // Placeholder
wire io33_i = 1; // Placeholder
wire io33_o; // Placeholder
wire io33_oe; // Placeholder
wire io34_i = 1; // Placeholder
wire io34_o; // Placeholder
wire io34_oe; // Placeholder
wire io35_i = 1; // Placeholder
wire io35_o; // Placeholder
wire io35_oe; // Placeholder
wire io36_i = 1; // Placeholder
wire io36_o; // Placeholder
wire io36_oe; // Placeholder
wire io37_i = 1; // Placeholder
wire io37_o; // Placeholder
wire io37_oe; // Placeholder

wire clk;
pll pll (
	.clkin(i_clk25),
	.clkout0(clk),
	.locked()
);

// Bit of a hack to make reset not trigger on startup
reg [2:0] rst_sync;
always @(posedge clk) rst_sync <= {~i_rst_n, rst_sync[2:1]};

reg [24:0] rst_ctr = 0;
always_ff @(posedge clk) begin
    if (~rst_sync) rst_ctr <= 0;
    else if (rst_ctr < 5000000) rst_ctr <= rst_ctr + 1;
end

wire sys_rst = (rst_ctr >= 4500000);

wire [13:0] cache_mem_addr;
wire [31:0] cache_mem_data_rd;
wire [31:0] cache_mem_data_wr;
wire cache_mem_we;
wire [3:0] cache_mem_we_sel;

DFFRAM cache_mem (
    .CLK(clk),
    .WE(cache_mem_we_sel & {4{cache_mem_we}}),
    .EN(1),
    .Di(cache_mem_data_wr),
    .Do(cache_mem_data_rd),
    .A(cache_mem_addr)
);

soc soc (
	.sys_clk(clk),
	.sys_rst(sys_rst),

	.*
);

endmodule

