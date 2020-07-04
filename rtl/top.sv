`default_nettype none

`define BROM_SIZE 128

module top #(
    parameter BROM_SIZE = `BROM_SIZE
) (
    output reg [7:0] o_led = 0,
    input wire [6:0] i_btn,

    output wire o_tx,
    input wire i_rx,
    input wire i_dtr_n,

    input wire i_clk
);

wire rx;
sync_2ff #(
    .DEFAULT(1)
) sync_rx (
    .o_out(rx),
    .i_in(i_rx),
    .i_clk(i_clk)
);

wire dtr_sync;
sync_2ff #(
    .DEFAULT(1)
) sync_dtr (
    .o_out(dtr_sync),
    .i_in(~i_dtr_n),
    .i_clk(i_clk)
);

wire dtr;
minimum_trigger #(
    // 0.2s at 25Mhz
    .MIN_CYCLES(5000000)
) dtr_trigger (
    .o_out(dtr),
    .i_in(dtr_sync),
    .i_clk(i_clk)
);

wire p_rst;
edge_detect edge_detect (
    .o_press_stb(p_rst),
    .i_btn(~i_btn[0]),
    .i_clk(i_clk)
);

wire [5:0] btn_in;
sync_2ff #(
    .WIDTH(6)
) sync_btn (
    .o_out(btn_in),
    .i_in(i_btn[6:1]),
    .i_clk(i_clk)
);

wire [31:0] gpio_out;

always_ff @(posedge i_clk) begin
    o_led <= gpio_out[7:0];
end

cpu #(
    .BROM_SIZE(BROM_SIZE),
    .BROM_INIT("software/botloader/build/bootloader-inst.mem"),

    .IMEM_SIZE(8192),
    .IMEM_INIT(""),

    .DMEM_SIZE(8192), // Top of stack = 0x8000
    .DMEM_INIT("software/bootloader/build/bootloader-data.mem")
) cpu (
    .o_gpio_out(gpio_out),
    .i_gpio_in({26'b0, btn_in}),
    
    .o_tx(o_tx),
    .i_rx(rx),

    .i_rst(p_rst | dtr),
    .i_clk(i_clk)
);

endmodule
