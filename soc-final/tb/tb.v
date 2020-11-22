`default_nettype none
`timescale 1ns/1ps

`define assert(condition) \
    if(!condition) begin \
        $error("Assertion failed"); \
        $finish; \
    end

module tb();

reg clk = 0;
reg rst = 0;

wire [7:0] dq;
wire [7:0] dq_o;
wire dq_oe;
assign dq = dq_oe ? dq_o : 8'bZZZZZZZZ;

wire rwds;
wire rwds_o;
wire rwds_oe;
assign rwds = rwds_oe ? rwds_o : 1'bZ;

wire ck, rstn, csn;

soc soc (
	.sys_clk(clk),
	.sys_rst(rst),
	//.led(),
	//.btn(0),
	//.uart0_tx(),
	//.uart0_rx(0)
	.hyperram_dq_i(dq),
	.hyperram_dq_o(dq_o),
	.hyperram_dq_oe(dq_oe),
	.hyperram_rwds_i(rwds),
	.hyperram_rwds_o(rwds_o),
	.hyperram_rwds_oe(rwds_oe),
	.hyperram_ck(ck),
	.hyperram_rst_n(rstn),
	.hyperram_cs_n(csn)
);

reg rst_tmp = 0;
s27kl0641 ram (
	.DQ7(dq[7]),
	.DQ6(dq[6]),
	.DQ5(dq[5]),
	.DQ4(dq[4]),
	.DQ3(dq[3]),
	.DQ2(dq[2]),
	.DQ1(dq[1]),
	.DQ0(dq[0]),
	.RWDS(rwds),
	.CSNeg(csn),
	.CK(ck),
	.RESETNeg(rst_tmp)
);

initial begin
	$dumpfile("v.vcd");
	$dumpvars;

	rst = 1;
	rst_tmp = 0;
	#500;
	@(negedge clk);
	rst_tmp = 1;

	#200000;
	@(negedge clk);
	rst = 0;


	#10000;
	
	$finish;
end

always #5 clk = ~clk;

endmodule
