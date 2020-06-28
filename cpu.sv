`default_nettype none

`ifdef FORMAL

`define RISCV_FORMAL
`define RISCV_FORMAL_NRET 1
`define RISCV_FORMAL_XLEN 32
`define RISCV_FORMAL_ILEN 32
`define RISCV_FORMAL_ALIGNED_MEM

`endif`

module cpu (
    `rvformal_rand_reg input wire [31:0] i_instr,
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
    output wire [31:0] rvfi_mem_wdata,

`endif
);



// Formal verification
`ifdef FORMAL
    
    // Bring instructions through the three-stage pipeline
    reg [63:0] instr_shiftreg;
    assign rvfi_insn = instr_shiftreg[31:0];
    always_ff @(posedge i_clk) begin
        instr_shiftreg <= {i_instr, instr_shiftreg[63:32]};
    end

    // When valid, increment order - the new order will be used
    // on the NEXT valid instruction
    always_ff @(posedge i_clk) begin
        if (rvfi_valid) begin
            rvfi_order <= rvfi_order + 1;
        end
    end


`endif

endmodule
