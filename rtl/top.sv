`default_nettype none

`define BROM_SIZE 128

module top #(
    parameter BROM_SIZE = `BROM_SIZE
) (
    output reg [7:0] o_led = 0,
    input wire [6:0] i_btn,

    input wire i_clk
);

wire clk = i_clk;
wire locked;
clk_pll pll (
    .clkin(i_clk),
    .clkout0(),
    .locked(locked)
);

wire p_rst;

edge_detect edge_detect (
    .o_press_stb(p_rst),
    .i_btn(~i_btn[0]),
    .i_clk(clk)
);

wire [5:0] btn_in;
sync_2ff #(
    .WIDTH(6)
) sync_2ff (
    .o_out(btn_in),
    .i_in(i_btn[6:1]),
    .i_clk(clk)
);

wire [31:0] gpio_out;

always_ff @(posedge clk) begin
    o_led <= {locked, gpio_out[6:0]};
end

cpu #(
    .BROM_SIZE(BROM_SIZE),
    .BROM_INIT("software/bootloader/build/bootloader-inst.mem"),

    .IMEM_SIZE(512),
    .IMEM_INIT(""),

    .DMEM_SIZE(512),
    .DMEM_INIT("software/bootloader/build/bootloader-data.mem")
) cpu (
    .o_gpio_out(gpio_out),
    .i_gpio_in({26'b0, btn_in}),
    .i_rst(p_rst),
    .i_clk(clk)
);

endmodule
