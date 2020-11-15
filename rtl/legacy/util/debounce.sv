`default_nettype none

module debounce 
# (
    parameter DEBOUNCE_CLKS = 625000 // 25ms at 25mhz
)(
    output reg o_out,

    input wire i_in,
    input wire i_clk
);

reg last = 0;
reg [$clog2(DEBOUNCE_CLKS):0] timer = 0;

always_ff @(posedge i_clk) begin
    if (timer == 0) begin
        o_out <= i_in;

        if (i_in != o_out) begin
            /* verilator lint_off WIDTH */
            timer <= DEBOUNCE_CLKS;
            /* verilator lint_on WIDTH */

        end
    end
    else begin
        timer <= timer - 1;
    end
end

endmodule
