`default_nettype none

// Wishbone-accessible UART module
// Registers can be spaced out at word-intervals
// Unaligned access is not supported
module wbuart #(
    parameter FIFO_DEPTH = 8,
    
    parameter ADDR_STATUS = 4'h0, // {28'b0, tx_fifo_full, tx_fifo_empty, rx_fifo_full, rx_fifo_empty}
    parameter ADDR_CONFIG = 4'h4, // {16'bX, divider}
    parameter ADDR_WRITE  = 4'h8, // tx write
    parameter ADDR_READ   = 4'hC, // rx read

    parameter DEFAULT_DIVIDER = 217, // 115200 @ 50Mhz 

    parameter USE_SYNC = 1 // Whether to synchronize the rx input with 2 FFs
) (
    input wire i_wb_cyc,
    input wire i_wb_stb,
    input wire i_wb_we,
    input wire [3:0] i_wb_addr,
    input wire [31:0] i_wb_data,
    output reg o_wb_ack = 0,
    output reg o_wb_err = 0,
    output reg [31:0] o_wb_data,

    output wire o_tx,
    input wire i_rx,

    input wire i_clk,
    input wire i_rst
);

reg [15:0] divider;

wire uart_tx_ready;
wire [7:0] uart_tx_data;
wire uart_tx_valid;
uart_tx tx_ctrl (
    .o_ready(uart_tx_ready),
    .o_out(o_tx),
    .i_data(uart_tx_data[7:0]),
    .i_valid(uart_tx_valid),
    .i_divider(divider),
    .i_clk(i_clk),
    .i_rst(i_rst)
);

wire uart_tx_fifo_empty;
wire uart_tx_fifo_full;
wire uart_tx_write_en = (i_wb_addr == ADDR_WRITE) && (~uart_tx_fifo_full) && (i_wb_cyc && i_wb_stb && i_wb_we && ~o_wb_ack && ~o_wb_err);
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
uart_rx rx_ctrl (
    .o_data(uart_rx_data),
    .o_valid(uart_rx_valid),
    .i_in(USE_SYNC ? rx : i_rx),
    .i_divider(divider),
    .i_clk(i_clk),
    .i_rst(i_rst)
);

wire uart_rx_fifo_empty;
wire uart_rx_fifo_full;
wire uart_rx_read_en = (i_wb_addr == ADDR_READ) && (~uart_rx_fifo_empty) && (i_wb_cyc && i_wb_stb && ~o_wb_ack && ~o_wb_err);
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

reg [31:0] last_addr;

always_ff @(posedge i_clk) begin
    o_wb_ack <= 0;
    o_wb_err <= 0;
    last_addr <= i_wb_addr;

    if (i_rst) begin
        divider <= DEFAULT_DIVIDER;
    end
    else begin
        if (i_wb_cyc && i_wb_stb && ~o_wb_ack && ~o_wb_err) begin
            if (i_wb_addr == ADDR_READ || i_wb_addr == ADDR_WRITE || i_wb_addr == ADDR_STATUS || i_wb_addr == ADDR_CONFIG) begin
                o_wb_ack <= 1;

                if (i_wb_we && i_wb_addr == ADDR_CONFIG) begin
                    divider <= i_wb_data[15:0];
                end
            end
            else begin
                o_wb_err <= 1;
            end
        end
    end
end

always_comb begin
    o_wb_data = 0;

    if (uart_rx_fifo_valid) begin
        o_wb_data = {23'b0, 1'b1, uart_rx_fifo_data};
    end
    else begin
        if (last_addr == ADDR_CONFIG) begin
           o_wb_data = {16'b0, divider};
        end
        else if (last_addr == ADDR_STATUS) begin
           o_wb_data = {28'b0, uart_tx_fifo_full, uart_tx_fifo_empty, uart_rx_fifo_full, uart_rx_fifo_empty};
        end
        else begin
            o_wb_data = 0;
        end
    end
end

endmodule
