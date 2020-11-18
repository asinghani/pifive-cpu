`default_nettype none

// UART accessible over wishbone
// All registers are 8 bits wide to accomodate use with 6502
// (spaced out at 32-bit intervals for convenience)
module wbuart #(
    parameter UART_BAUD = 115200,
    parameter CLK_FREQ = 25000000,
    parameter FIFO_DEPTH = 8,
    
    parameter ADDR_STATUS = 4'h0, // {4'b0, tx_fifo_full, tx_fifo_empty, rx_fifo_full, rx_fifo_empty}
    parameter ADDR_WRITE  = 4'h4, // tx write
    parameter ADDR_READ   = 4'h8, // rx read

    parameter USE_SYNC = 1 // Whether to syncronize the rx input with 2 FFs
) (
    input wire i_wb_cyc,
    input wire i_wb_stb,
    input wire i_wb_we,
    input wire [3:0] i_wb_addr,
    input wire [7:0] i_wb_data,
    output reg o_wb_ack = 0,
    output reg o_wb_err = 0,
    output reg [7:0] o_wb_data,

    output wire o_tx,
    input wire i_rx,

    input wire i_clk,
    input wire i_rst
);

wire uart_tx_ready;
wire [7:0] uart_tx_data;
wire uart_tx_valid;
uart_tx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD(UART_BAUD)
) tx_ctrl (
    .o_ready(uart_tx_ready),
    .o_out(o_tx),
    .i_data(uart_tx_data[7:0]),
    .i_valid(uart_tx_valid),
    .i_clk(i_clk),
    .i_rst(i_rst)
);

wire uart_tx_fifo_empty;
wire uart_tx_fifo_full;
wire uart_tx_write_en = (i_wb_addr == ADDR_WRITE) && (~uart_tx_fifo_full) && (i_wb_cyc && i_wb_stb && i_wb_we);
uart_fifo #(
    .WIDTH(8),
    .DEPTH(FIFO_DEPTH)
) tx_fifo (
    .i_rd_en(uart_tx_ready && (~uart_tx_fifo_empty) && (~uart_tx_valid)),
    .o_rd_data(uart_tx_data),
    .o_rd_valid(uart_tx_valid),

    .i_wr_en(uart_tx_write_en),
    .i_wr_data(i_wb_data),

    .o_empty(uart_tx_fifo_empty),
    .o_full(uart_tx_fifo_full),

    .i_clk(i_clk),
    .i_rst(i_rst)
);

wire rx;
sync_2ff #(
    .DEFAULT(1)
) rx_sync (
    .i_in(i_rx),
    .o_out(rx),
    .i_clk(i_clk),
    .i_rst(i_rst)
);

wire [7:0] uart_rx_data;
wire uart_rx_valid;
uart_rx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD(UART_BAUD)
) rx_ctrl (
    .o_data(uart_rx_data),
    .o_valid(uart_rx_valid),
    .i_in(USE_SYNC ? rx : i_rx),
    .i_clk(i_clk),
    .i_rst(i_rst)
);

wire uart_rx_fifo_empty;
wire uart_rx_fifo_full;
wire uart_rx_read_en = (i_wb_addr == ADDR_READ) && (~uart_rx_fifo_empty) && (i_wb_cyc && i_wb_stb);
wire [7:0] uart_rx_fifo_data;
wire uart_rx_fifo_valid;
uart_fifo #(
    .WIDTH(8),
    .DEPTH(FIFO_DEPTH)
) rx_fifo (
    .i_rd_en(uart_rx_read_en),
    .o_rd_data(uart_rx_fifo_data),
    .o_rd_valid(uart_rx_fifo_valid),

    .i_wr_en(uart_rx_valid & (~uart_rx_fifo_full)),
    .i_wr_data(uart_rx_data[7:0]),

    .o_empty(uart_rx_fifo_empty),
    .o_full(uart_rx_fifo_full),

    .i_clk(i_clk),
    .i_rst(i_rst)
);

always_ff @(posedge i_clk) begin
    o_wb_ack <= 0;
    o_wb_err <= 0;

    if (~i_rst) begin
        if (i_wb_cyc && i_wb_stb) begin
            if (i_wb_addr == ADDR_READ || i_wb_addr == ADDR_WRITE || i_wb_addr == ADDR_STATUS) begin
                o_wb_ack <= 1;
            end
            else begin
                o_wb_err <= 1;
            end
        end
    end
end

always_comb begin
    if (uart_rx_fifo_valid) begin
        o_wb_data = uart_rx_fifo_data;
    end
    else begin
       o_wb_data = {4'b0, uart_tx_fifo_full, uart_tx_fifo_empty, uart_rx_fifo_full, uart_rx_fifo_empty};
    end
end

endmodule
