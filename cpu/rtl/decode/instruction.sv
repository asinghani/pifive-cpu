`default_nettype none

// Wrapper interface to represent a decoded instruction

typedef struct packed {
    // Raw instruction (for verification only)
    // MSB = valid?
    logic [32:0] inst_raw;

    // Trigger invalid-instruction trap
    logic inst_invalid;

    // Operation to give to the ALU
    logic [3:0] alu_op;

    // Whether to replace rs1 with PC
    // Used for branch, jump, auipc
    logic rs1_pc;

    // Whether to replace rs2 with imm
    // Used for ALU imm instructions, load, store, branch, jump, lui, auipc
    logic rs2_imm;

    // Whether to branch and what type of branch comparison to use
    logic branch; 
    logic [2:0] branch_type;

    // Whether to jump
    // Includes setting rd <= PC + 4
    logic jump;

    // Whether to zero-extend the output of a partial load operation
    logic load_zeroextend;

    // 0 = no load/store, 1 = lb, 2 = lh, 3 = lw
    // 4 = no load/store, 5 = sb, 6 = sh, 7 = sw
    logic [2:0] loadstore;

    // Register addresses
    logic [4:0] rd_addr;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;

    // Value of imm, ready to be passed to ALU/adder
    // For signed operations, already sign-extended
    // For LUI/AUIPC, already shifted left by 12
    logic [31:0] imm;

    // Value of PC from where this instruction was taken
    logic [31:0] pc;

} instruction_t;

`define NOOP_INSTR 0
