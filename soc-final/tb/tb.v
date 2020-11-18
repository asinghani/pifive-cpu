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

soc soc (
	.sys_clk(clk),
	.sys_rst(rst)
	//.led(),
	//.btn(0),
	//.uart0_tx(),
	//.uart0_rx(0)
);

initial begin
	$dumpfile("v.vcd");
	$dumpvars;

	rst = 1;
	#100;
	@(negedge clk);
	rst = 0;

	#50000;
	
	$finish;
end

always #5 clk = ~clk;

endmodule
