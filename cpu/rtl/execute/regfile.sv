`default_nettype none

module regfile #(
    parameter RESET_REGS = 1  
) (
    input wire [4:0] i_rd_addr,
    input wire [31:0] i_rd_data,

    input wire [4:0] i_rs1_addr,
    output wire [31:0] o_rs1_data,

    input wire [4:0] i_rs2_addr,
    output wire [31:0] o_rs2_data,

    output wire [31:0] d_regs_out[0:31],

    input wire i_rst,
    input wire i_clk
);

assign d_regs_out = registers;

// Reg 0 is not used but kept for consistency
// (should be optimized out at synthesis-time)
reg [31:0] registers[0:31];

assign o_rs1_data = (i_rs1_addr == 0) ? (0) : (registers[i_rs1_addr]);
assign o_rs2_data = (i_rs2_addr == 0) ? (0) : (registers[i_rs2_addr]);

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        // TODO this breaks verilator for some reason
        // if (RESET_REGS) registers <= 0;
    end
    else if (i_rd_addr != 0) begin
        registers[i_rd_addr] <= i_rd_data;
    end
end

endmodule
