`ifdef VERILATOR
`default_nettype none
`endif

`include "decode/instruction.sv"

module top (
    output wire [7:0] led,
    input wire [4:0] btn,

    input wire i_clk
);

wire bonk;

btn_stb btn_stb (
    .o_press_stb(bonk),
    .i_clk(i_clk),
    .i_btn(btn[4])
);

instruction_t inst;
instruction_t inst2;

decode decode (
    .i_instr({20'b0, btn[3:0], 8'b0}),
    .o_out(inst),
    .o_out2(inst2),
    .bonk(bonk),
    .i_clk(i_clk)
);

assign led = {inst2.rd[3:0], inst.rd[3:0]};

endmodule
