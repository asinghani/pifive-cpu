`ifdef VERILATOR
`default_nettype none
`endif

`include "instruction_types.sv"

module decode (
    input wire [31:0] i_instr,
    input wire [31:0] i_pc,

    // Decoded instruction
    output instruction_t o_out,

    input wire i_clk
);

`ifdef FORMAL
    assign o_out.inst_raw = {1'b1, i_instr};
`endif

wire opcode = i_instr[6:0];
wire [6:0] funct7 = i_instr[31:25];
wire [2:0] funct3 = i_instr[14:12];

reg invalid_opcode;
assign o_out.inst_invalid = invalid_opcode;

always_comb begin
    o_out.rs1_pc = ((opcode == `OPCODE_BRANCH) | (opcode == `OPCODE_JAL) |
        (opcode == `OPCODE_JALR) | (opcode == `OPCODE_AUIPC));
    o_out.rs2_imm = ((opcode != `OPCODE_ALU));

    o_out.branch = (opcode == `OPCODE_BRANCH);
    o_out.branch_type = funct3;
    o_out.jump = ((opcode == `OPCODE_JAL) | (opcode == `OPCODE_JALR));

    o_out.load_zeroextend = funct3[2];
    
    if ((opcode == `OPCODE_LOAD) | (opcode == `OPCODE_STORE)) begin
        o_out.loadstore = funct3[1:0] + 1;
    end
    else begin
        o_out.loadstore = 0;
    end

    o_out.rd_addr = ((opcode == `OPCODE_STORE) | (opcode == `OPCODE_BRANCH)) ? 0 : i_instr[11:7];
    o_out.rs1_addr = (opcode == `OPCODE_LUI) ? 0 : i_instr[19:15];
    o_out.rs2_addr = i_instr[24:20];

    o_out.pc = i_pc;

    o_out.alu_op = 0;
    o_out.imm = 0;

    case (i_instr[6:0])
        `OPCODE_ALU: o_out.alu_op = {funct7[30], funct3};
        `OPCODE_ALUIMM: o_out.imm = {{20{i_instr[31]}}, i_instr[31:20]};
        `OPCODE_LOAD: o_out.imm = {{20{i_instr[31]}}, i_instr[31:20]};
        `OPCODE_STORE: o_out.imm = {{20{i_instr[31]}}, i_instr[31:25], i_instr[11:7]};
        `OPCODE_BRANCH: o_out.imm = {{19{i_instr[31]}}, i_instr[31], i_instr[7], i_instr[30:25], i_instr[11:6], 1'b0};
        `OPCODE_JAL: o_out.imm = {{12{i_instr[31]}}, i_instr[31], i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0};
        `OPCODE_JALR: o_out.imm = {{20{i_instr[31]}}, i_instr[31:20]};
        `OPCODE_LUI: o_out.imm = {i_instr[31:12], 12'b0};
        `OPCODE_AUIPC: o_out.imm = {i_instr[31:12], 12'b0};
        default: invalid_opcode = 1;
    endcase
end


endmodule
