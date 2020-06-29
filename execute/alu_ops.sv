// Definitions of operations for ALU

// ALU-use
// Defined as RISC-V funct3
`define ALU_ADD  3'd0
`define ALU_XOR  3'd4
`define ALU_OR   3'd6
`define ALU_AND  3'd7
`define ALU_SLL  3'd1
`define ALU_SRL  3'd5
`define ALU_SRA  3'd5
`define ALU_SLT  3'd2
`define ALU_SLTU 3'd3

// Decoder-use
// First bit:
// 0 = ADD, 1 = SUB
// 0 = SRL, 1 = SRA
// Remaining 3 bits are RISC-V funct3
`define RV_ADD  {1'b0, ALU_ADD}
`define RV_SUB  {1'b1, ALU_ADD}
`define RV_XOR  {1'b0, ALU_XOR}
`define RV_OR   {1'b0, ALU_OR}
`define RV_AND  {1'b0, ALU_AND}
`define RV_SLL  {1'b0, ALU_SLL}
`define RV_SRL  {1'b0, ALU_SRL}
`define RV_SRA  {1'b1, ALU_SRL}
`define RV_SLT  {1'b0, ALU_SLT}
`define RV_SLTU {1'b0, ALU_SLTU}

