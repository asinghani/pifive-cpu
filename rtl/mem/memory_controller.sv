`default_nettype none

// Memory controller for both instruction
// and data memories, as well as peripherals

// 0x1000_0000 - Bootloader ROM
// 0x2000_0000 - Instruction RAM
// 0x4000_0000 - Data RAM
// 0x8000_0000 - Peripherals
//   - 0x8000_0000 - GPIO Output
//   - 0x8000_0004 - GPIO Input

module memory_controller
# (
    // Num words
    parameter BROM_SIZE = 512,
    parameter IMEM_SIZE = 512,
    parameter DMEM_SIZE = 512,

    // Top 4 bits
    parameter BROM_BASE = 4'h1,
    parameter IMEM_BASE = 4'h2,
    parameter DMEM_BASE = 4'h4,
    parameter PERI_BASE = 4'h8,

    parameter BROM_INIT = "",
    parameter IMEM_INIT = "",
    parameter DMEM_INIT = ""
)(
    input wire [31:0] i_inst_addr,
    output reg [31:0] o_inst_data,

    input wire [31:0] i_data_addr,
    output reg [31:0] o_data_data,
    input wire [31:0] i_data_data,
    input wire [1:0] i_data_width,
    input wire i_data_we,
    input wire i_data_zeroextend,

    output reg [31:0] o_gpio_out = 0,
    input wire [31:0] i_gpio_in,

    input wire i_clk
);

reg valid = 0;

reg [31:0] r_inst_addr = {BROM_BASE, 28'b0};
reg [31:0] r_data_addr = 0;

reg [1:0] r_data_width = 0;
reg r_data_zeroextend = 0;

wire [31:0] brom_data;
rom32 # (
    .DEPTH(BROM_SIZE),
    .INIT_FILE(BROM_INIT)
) bootloader_rom (
    .o_data(brom_data),
    .i_addr(i_inst_addr[($clog2(BROM_SIZE * 4) - 1):2]),
    .i_clk(i_clk)
);

reg [2:0] wr_subaddr;

wire [31:0] imem_data;
wire [31:0] imem_addr = (i_inst_addr[31:28] == BROM_BASE) ? i_data_addr : i_inst_addr;
bram32 # (
    .DEPTH(IMEM_SIZE),
    .INIT_FILE(IMEM_INIT)
) instruction_ram (
    .o_data(imem_data),
    .i_addr(imem_addr[($clog2(IMEM_SIZE * 4) - 1):2]),
    .i_data(i_data_data),
    .i_we(i_data_we && (i_data_addr[31:28] == IMEM_BASE) && (i_inst_addr[31:28] == BROM_BASE)),
    .i_wr_subaddr(wr_subaddr),
    .i_clk(i_clk)
);

wire [31:0] dmem_data;
bram32 # (
    .DEPTH(DMEM_SIZE),
    .INIT_FILE(DMEM_INIT)
) data_ram (
    .o_data(dmem_data),
    .i_addr(i_data_addr[($clog2(DMEM_SIZE * 4) - 1):2]),
    .i_data(i_data_data),
    .i_we(i_data_we && (i_data_addr[31:28] == DMEM_BASE)),
    .i_wr_subaddr(wr_subaddr),
    .i_clk(i_clk)
);

reg [31:0] data_data;

always_comb begin
    if (valid) begin
        case (r_inst_addr[31:28])
            BROM_BASE: o_inst_data = brom_data;
            IMEM_BASE: o_inst_data = imem_data;
            default: o_inst_data = 0;
        endcase
    end
    else begin
        o_inst_data = 32'h33; // RISC-V no-op
    end

    case (r_data_addr[31:28])
        IMEM_BASE: data_data = (r_inst_addr[31:28] == BROM_BASE) ? imem_data : 0;
        DMEM_BASE: data_data = dmem_data;
        PERI_BASE: begin
            if (r_data_addr[27:2] == 0) begin
                data_data = o_gpio_out;
            end
            else if (r_data_addr[27:2] == 1) begin
                data_data = i_gpio_in;
            end
            else begin
                data_data = 0;
            end
        end
        default: data_data = 0;
    endcase
end

reg ext;

always_comb begin
    case (i_data_width)
        // Byte
        1: begin
            if(i_data_addr[1:0] == 2'b00) begin
                wr_subaddr = 4;
            end
            else if(i_data_addr[1:0] == 2'b01) begin
                wr_subaddr = 5;
            end
            else if(i_data_addr[1:0] == 2'b10) begin
                wr_subaddr = 6;
            end
            else begin
                wr_subaddr = 7;
            end
        end

        // Half-Word
        2: begin
            if(i_data_addr[1] == 0) begin
                wr_subaddr = 2;
            end
            else begin
                wr_subaddr = 3;
            end
        end

        // Word
        default: begin
            wr_subaddr = 1;
        end
    endcase
end

always_comb begin
    case (r_data_width)
        // Byte
        1: begin
            if(r_data_addr[1:0] == 2'b00) begin
                ext = r_data_zeroextend ? 0 : data_data[7];
                o_data_data = {{24{ext}}, data_data[7:0]};
            end
            else if(r_data_addr[1:0] == 2'b01) begin
                ext = r_data_zeroextend ? 0 : data_data[15];
                o_data_data = {{24{ext}}, data_data[15:8]};
            end
            else if(r_data_addr[1:0] == 2'b10) begin
                ext = r_data_zeroextend ? 0 : data_data[23];
                o_data_data = {{24{ext}}, data_data[23:16]};
            end
            else begin
                ext = r_data_zeroextend ? 0 : data_data[31];
                o_data_data = {{24{ext}}, data_data[31:24]};
            end
        end

        // Half-Word
        2: begin
            if(r_data_addr[1] == 0) begin
                ext = r_data_zeroextend ? 0 : data_data[15];
                o_data_data = {{16{ext}}, data_data[15:0]};
            end
            else begin
                ext = r_data_zeroextend ? 0 : data_data[31];
                o_data_data = {{16{ext}}, data_data[31:16]};
            end
        end

        // Word
        default: begin
            o_data_data = data_data;
        end
    endcase
end

always_ff @(posedge i_clk) begin 
    r_data_addr <= i_data_addr;
    r_data_width <= i_data_width;
    r_data_zeroextend <= i_data_zeroextend;
    r_inst_addr <= i_inst_addr;

    valid <= 1;

    if (i_data_addr[31:28] == PERI_BASE) begin
        if (i_data_we && (i_data_addr[27:2] == 0)) begin
            case (i_data_width)
                // Byte
                1: begin
                    if(i_data_addr[1:0] == 2'b00) begin
                        o_gpio_out[7:0] <= i_data_data[7:0];
                    end
                    else if(i_data_addr[1:0] == 2'b01) begin
                        o_gpio_out[15:8] <= i_data_data[7:0];
                    end
                    else if(i_data_addr[1:0] == 2'b10) begin
                        o_gpio_out[23:16] <= i_data_data[7:0];
                    end
                    else begin
                        o_gpio_out[31:24] <= i_data_data[7:0];
                    end
                end

                // Half-Word
                2: begin
                    if(i_data_addr[1] == 0) begin
                        o_gpio_out[15:0] <= i_data_data[15:0];
                    end
                    else begin
                        o_gpio_out[31:16] <= i_data_data[15:0];
                    end
                end

                // Word
                default: begin
                    o_gpio_out <= i_data_data;
                end
            endcase
        end
    end
end

endmodule
