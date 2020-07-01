`default_nettype none

// Wrapper for memory-mapped peripherals
//   - 0x8000_0000 (0) - GPIO Output
//   - 0x8000_0004 (1) - GPIO Input
//   - 0x8000_0010 (4) - {30'b0, uart_rx_ready, uart_tx_ready}
//   - 0x8000_0014 (5) - uart_rx_in
//   - 0x8000_0018 (6) - uart_tx_out

module mmio # (
    parameter UART_BAUD = 115200,
    parameter CLK_FREQ = 25000000,
    parameter UART_FIFO_DEPTH = 128
) (
    input wire [25:0] i_addr,
    input wire [31:0] i_data,
    input wire [3:0] i_byte_we,
    input wire i_read_en,
    output reg [31:0] o_data,

    output reg [31:0] o_gpio_out = 0,
    input wire [31:0] i_gpio_in,

    output wire o_tx,
    input wire i_rx,

    input wire i_clk,
    input wire i_rst
);

wire uart_tx_ready;
wire [8:0] uart_tx_data;
wire uart_tx_valid;
uart_tx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD(UART_BAUD)
) tx (
    .o_ready(uart_tx_ready),
    .o_out(o_tx),
    .i_data(uart_tx_data[7:0]),
    .i_valid(uart_tx_valid),
    .i_clk(i_clk)
);

wire uart_tx_fifo_empty;
wire uart_tx_fifo_full;
wire uart_tx_write_en = (i_addr == 26'h6) && (~uart_tx_fifo_full) && (i_byte_we[0] == 1);
uart_fifo #(
    .WIDTH(9),
    .DEPTH(UART_FIFO_DEPTH)
) tx_fifo (
    .i_rd_en(uart_tx_ready && (~uart_tx_fifo_empty) && (~uart_tx_valid)),
    .o_rd_data(uart_tx_data),
    .o_rd_valid(uart_tx_valid),

    .i_wr_en(uart_tx_write_en),
    .i_wr_data({1'b0, i_data[7:0]}),

    .o_empty(uart_tx_fifo_empty),
    .o_full(uart_tx_fifo_full),

    .i_clk(i_clk),
    .i_rst(i_rst)
);



wire [7:0] uart_rx_data;
wire uart_rx_valid;
uart_rx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD(UART_BAUD)
) rx (
    .o_data(uart_rx_data),
    .o_valid(uart_rx_valid),
    .i_in(i_rx),
    .i_clk(i_clk)
);

wire uart_rx_fifo_empty;
wire uart_rx_fifo_full;
wire uart_rx_read_en = (i_addr == 26'h5) && (~uart_rx_fifo_empty) && i_read_en;
wire [8:0] uart_rx_fifo_data;
wire uart_rx_fifo_valid;
uart_fifo #(
    .WIDTH(9),
    .DEPTH(UART_FIFO_DEPTH)
) rx_fifo (
    .i_rd_en(uart_rx_read_en),
    .o_rd_data(uart_rx_fifo_data),
    .o_rd_valid(uart_rx_fifo_valid),

    .i_wr_en(uart_rx_valid & (~uart_rx_fifo_full)),
    .i_wr_data({1'b0, uart_rx_data[7:0]}),

    .o_empty(uart_rx_fifo_empty),
    .o_full(uart_rx_fifo_full),

    .i_clk(i_clk),
    .i_rst(i_rst)
);

reg [25:0] r_addr;
reg [31:0] r_data;

// Read
always_ff @(posedge i_clk) begin
    r_addr <= i_addr;
    r_data <= 0;
    if (i_addr == 0) begin
        r_data <= o_gpio_out;
    end
    else if (i_addr == 1) begin
        r_data <= i_gpio_in;
    end
    else if (i_addr == 26'h4) begin
        r_data <= {30'b0, (~uart_rx_fifo_empty), (~uart_tx_fifo_full)};
    end
end

always_comb begin
    if (uart_rx_fifo_valid) begin
        o_data = {24'b0, uart_rx_fifo_data[7:0]};
    end
    else begin
        o_data = r_data;
    end
end

// Write
always_ff @(posedge i_clk) begin
    if (i_addr == 0) begin
        if (i_byte_we[3])
            o_gpio_out[31:24] <= i_data[31:24];

        if (i_byte_we[2])
            o_gpio_out[23:16] <= i_data[23:16];

        if (i_byte_we[1])
            o_gpio_out[15:8] <= i_data[15:8];

        if (i_byte_we[0])
            o_gpio_out[7:0] <= i_data[7:0];
    end
end

endmodule
