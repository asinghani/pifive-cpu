`default_nettype none

// Memory controller for both instruction
// and data memories, as well as peripherals

// 0x1000_0000 - Bootloader ROM
// 0x2000_0000 - Instruction RAM
// 0x4000_0000 - Data RAM
// 0x8000_0000 - Peripherals
//   - 0x8000_0000 - GPIO Output
//   - 0x8000_0004 - GPIO Input
//   - 0x8000_0010 - {30'b0, uart_rx_valid, uart_tx_ready}
//   - 0x8000_0014 - uart_rx_in
//   - 0x8000_0018 - uart_tx_out
//   - 0x8000_0020 - millis since boot

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
    parameter DMEM_INIT = "",

    parameter CLK_FREQ = 25000000,
    parameter UART_BAUD = 115200,
    parameter UART_FIFO_DEPTH = 128
)(
    input wire [31:0] i_inst_addr,
    output reg [31:0] o_inst_data,

    input wire [31:0] i_data_addr,
    output reg [31:0] o_data_data,
    input wire [31:0] i_data_data,
    input wire [1:0] i_data_width,
    input wire i_data_we,
    input wire i_data_read_en,
    input wire i_data_zeroextend,

    output wire [31:0] o_gpio_out,
    input wire [31:0] i_gpio_in,

    output wire o_tx,
    input wire i_rx,

    input wire i_clk,
    input wire i_rst
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
    .i_addr((i_data_read_en || i_data_we) ? i_data_addr[($clog2(DMEM_SIZE * 4) - 1):2] : r_data_addr[($clog2(DMEM_SIZE * 4) - 1):2]),
    .i_data(i_data_data),
    .i_we(i_data_we && (i_data_addr[31:28] == DMEM_BASE)),
    .i_wr_subaddr(wr_subaddr),
    .i_clk(i_clk)
);

reg [31:0] mmio_wdata;
wire [31:0] mmio_rdata;
reg [3:0] mmio_byte_we;

mmio #(
    .UART_BAUD(UART_BAUD),
    .CLK_FREQ(CLK_FREQ),
    .UART_FIFO_DEPTH(UART_FIFO_DEPTH)
) mmio (
    .i_addr(i_data_addr[27:2]),
    .i_data(mmio_wdata),
    .i_byte_we(mmio_byte_we),
    .i_read_en(i_data_read_en),
    .o_data(mmio_rdata),
    .o_gpio_out(o_gpio_out),
    .i_gpio_in(i_gpio_in),
    .o_tx(o_tx),
    .i_rx(i_rx),
    .i_clk(i_clk),
    .i_rst(i_rst)
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
        PERI_BASE: data_data = mmio_rdata;
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
    ext = 0;

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
    if (i_data_read_en) begin
        r_data_addr <= i_data_addr;
        r_data_width <= i_data_width;
        r_data_zeroextend <= i_data_zeroextend;
    end
    r_inst_addr <= i_inst_addr;

    valid <= 1;
end

always_comb begin
    mmio_wdata = 32'b0;
    mmio_byte_we = 4'b0000;
    if (i_data_addr[31:28] == PERI_BASE) begin
        if (i_data_we) begin
            case (i_data_width)
                // Byte
                1: begin
                    if(i_data_addr[1:0] == 2'b00) begin
                        mmio_wdata = {24'b0, i_data_data[7:0]};
                        mmio_byte_we = 4'b0001;
                    end
                    else if(i_data_addr[1:0] == 2'b01) begin
                        mmio_wdata = {16'b0, i_data_data[7:0], 8'b0};
                        mmio_byte_we = 4'b0010;
                    end
                    else if(i_data_addr[1:0] == 2'b10) begin
                        mmio_wdata = {8'b0, i_data_data[7:0], 16'b0};
                        mmio_byte_we = 4'b0100;
                    end
                    else begin
                        mmio_wdata = {i_data_data[7:0], 24'b0};
                        mmio_byte_we = 4'b1000;
                    end
                end

                // Half-Word
                2: begin
                    if(i_data_addr[1] == 0) begin
                        mmio_wdata = {16'b0, i_data_data[15:0]};
                        mmio_byte_we = 4'b0011;
                    end
                    else begin
                        mmio_wdata = {i_data_data[15:0], 16'b0};
                        mmio_byte_we = 4'b1100;
                    end
                end

                // Word
                default: begin
                    mmio_wdata = i_data_data[31:0];
                    mmio_byte_we = 4'b1111;
                end
            endcase
        end
    end
end

endmodule
