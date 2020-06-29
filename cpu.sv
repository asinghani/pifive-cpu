`default_nettype none

`define FORMAL

`ifdef FORMAL

`define RISCV_FORMAL
`define RISCV_FORMAL_NRET 1
`define RISCV_FORMAL_XLEN 32
`define RISCV_FORMAL_ILEN 32
`define RISCV_FORMAL_ALIGNED_MEM

`endif

module cpu (
`ifdef FASDASDASDORMAL
    `rvformal_rand_reg input wire [31:0] i_instr,
`else
    input wire [31:0] i_instr,
`endif

    input wire i_clk,

    // Formal verification
`ifdef FORMAL
    output wire rvfi_valid,
    output reg [63:0] rvfi_order = 0,
    output wire [31:0] rvfi_insn,
    output wire rvfi_trap,
    output wire rvfi_halt,
    output wire rvfi_intr,
    output wire [1:0] rvfi_mode,
    output wire [1:0] rvfi_ixl,

    output wire [4:0] rvfi_rs1_addr,
    output wire [4:0] rvfi_rs2_addr,
    output wire [31:0] rvfi_rs1_rdata,
    output wire [31:0] rvfi_rs2_rdata,
    output wire [4:0] rvfi_rd_addr,
    output wire [31:0] rvfi_rd_wdata,

    output wire [31:0] rvfi_pc_rdata,
    output wire [31:0] rvfi_pc_wdata,

    output wire [31:0] rvfi_mem_addr,
    output wire [3:0] rvfi_mem_rmask,
    output wire [3:0] rvfi_mem_wmask,
    output wire [31:0] rvfi_mem_rdata,
    output wire [31:0] rvfi_mem_wdata

`endif
);

instruction_t instr_0;



decode decode (
    .i_instr(i_instr),
    .i_pc(0),
    .o_out(instr_0),
    .i_clk(i_clk)
);

instruction_t instr_1 = 0;



instruction_t instr_2 = 0;

always_ff @(posedge i_clk) begin
    instr_1 <= instr_0;
    instr_2 <= instr_1;
end

// Formal verification
`ifdef FORMAL
    
    assign rvfi_insn = instr_2.inst_raw[31:0];
    assign rvfi_valid = instr_2.inst_raw[32];
    assign rvfi_trap = instr_2.inst_invalid;

    // When valid, increment order - the new order will be used
    // on the NEXT valid instruction
    always_ff @(posedge i_clk) begin
        if (rvfi_valid) begin
            rvfi_order <= rvfi_order + 1;
        end
    end


`endif

endmodule
