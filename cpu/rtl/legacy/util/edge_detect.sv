// Take an async-clocked active-high button as input, run it through a 2FF syncronizer,
// debouncer, and create a 1-cycle stb signal when pressed and released

`default_nettype none

module edge_detect
#(
`ifdef FORMAL
    parameter DEBOUNCE_CLKS = 5
`elsif VERILATOR
    parameter DEBOUNCE_CLKS = 5
`else
    parameter DEBOUNCE_CLKS = 625000 // 25ms at 25mhz
`endif

) (
    output wire o_press_stb,
    output wire o_release_stb,

    input wire i_btn,
    input wire i_clk
);

reg btn_last = 0;
wire btn_sync;
wire btn_debounced;

sync_2ff sync_btn (
    .o_out(btn_sync),
    .i_in(i_btn),
    .i_clk(i_clk)
);

debounce #(
    .DEBOUNCE_CLKS(DEBOUNCE_CLKS)
) debounce (
    .o_out(btn_debounced),
    .i_in(btn_sync),
    .i_clk(i_clk)
);

// Rising edge
assign o_press_stb = btn_debounced && (~btn_last);

// Falling edge
assign o_release_stb = (~btn_debounced) && btn_last;

always_ff @(posedge i_clk) begin
    btn_last <= btn_debounced;
end

`ifdef FORMAL
    // Ensure debounce works

    reg past_valid = 0;

    integer k;
    integer j;
    always @(posedge i_clk) begin
        past_valid <= 1;

        if (past_valid) begin
            if(o_press_stb) begin
                for(k = 1; k < DEBOUNCE_CLKS; k = k + 1) begin
                    assert($past(~o_press_stb, k));
                end
            end

            if(o_release_stb) begin
                for(j = 1; j < DEBOUNCE_CLKS; j = j + 1) begin
                    assert($past(~o_release_stb, j));
                end
            end
        end
    end

    reg [10:0] num_presses = 1;
    // One release per press
    always @(posedge i_clk) begin
        if (o_press_stb) begin
            num_presses <= num_presses + 1;
        end

        if (o_release_stb) begin
            num_presses <= num_presses - 1;
        end

        assert((num_presses == 1) || (num_presses == 2));
    end

    // Never press and release on same cycle
    always @(*) begin
        assert(~(o_press_stb && o_release_stb));
    end

`endif

endmodule
