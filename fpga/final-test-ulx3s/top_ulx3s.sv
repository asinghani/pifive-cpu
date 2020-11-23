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
wire io6_i = 1; // Placeholder
wire io6_o; // Placeholder
wire io6_oe; // Placeholder
wire io7_i = 1; // Placeholder
wire io7_o; // Placeholder
wire io7_oe; // Placeholder
wire io8_i = 1; // Placeholder
wire io8_o; // Placeholder
wire io8_oe; // Placeholder
wire io9_i = 1; // Placeholder
wire io9_o; // Placeholder
wire io9_oe; // Placeholder
wire io10_i = 1; // Placeholder
wire io10_o; // Placeholder
wire io10_oe; // Placeholder
wire io11_i = 1; // Placeholder
wire io11_o; // Placeholder
wire io11_oe; // Placeholder
wire io12_i = 1; // Placeholder
wire io12_o; // Placeholder
wire io12_oe; // Placeholder
wire io13_i = 1; // Placeholder
wire io13_o; // Placeholder
wire io13_oe; // Placeholder
wire io14_i = 1; // Placeholder
wire io14_o; // Placeholder
wire io14_oe; // Placeholder
wire io15_i = 1; // Placeholder
wire io15_o; // Placeholder
wire io15_oe; // Placeholder
wire io16_i = 1; // Placeholder
wire io16_o; // Placeholder
wire io16_oe; // Placeholder
wire io17_i = 1; // Placeholder
wire io17_o; // Placeholder
wire io17_oe; // Placeholder
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






