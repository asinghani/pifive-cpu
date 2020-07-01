`default_nettype none

// Output a strobe signal when the given signal goes low only if
// the input signal has been high for a certain amount of time
module minimum_trigger #(
    // Min number of cycles that signal must be high
    parameter MIN_CYCLES = 12500000
)(
    reg o_out = 0,
    wire i_in,

    wire i_clk
);

reg [$clog2(MIN_CYCLES):0] counter = 0;
reg last = 0;

always_ff @(posedge i_clk) begin
    o_out <= 0;
    last <= i_in;

    if (~i_in) begin
        counter <= 0;
    end
    else if (counter < MIN_CYCLES[$clog2(MIN_CYCLES):0]) begin
        counter <= counter + 1;
    end

    if (~i_in && last) begin
        if (counter == MIN_CYCLES[$clog2(MIN_CYCLES):0]) begin
            o_out <= 1;
        end
    end
end

endmodule
