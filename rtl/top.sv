`default_nettype none

`define BROM_SIZE 128

module top #(
    parameter BROM_SIZE = `BROM_SIZE
) (
    output wire [7:0] o_led,
    input wire [6:0] i_btn,

    input wire i_clk
);

wire p_rst;

edge_detect edge_detect (
    .o_press_stb(p_rst),
    .i_btn(~i_btn[0]),
    .i_clk(i_clk)
);

wire [31:0] gpio_out;
assign o_led = gpio_out[7:0];

cpu #(
    .BROM_SIZE(BROM_SIZE),
    .BROM_INIT("software/bootloader/build/bootloader-inst.mem"),

    .IMEM_SIZE(512),
    .IMEM_INIT(""),

    .DMEM_SIZE(512),
    .DMEM_INIT("software/bootloader/build/bootloader-data.mem")
) cpu (
    .o_gpio_out(gpio_out),
    .i_gpio_in({26'b0, i_btn[6:1]}),
    .i_rst(p_rst),
    .i_clk(i_clk)
);

endmodule
