`default_nettype none

module wbdbgbus #(
    parameter CLK_FREQ = 25000000,
    parameter UART_BAUD = 9600,

    // Time before dropping an unfinished instruction
    parameter DROP_CLKS = 2500000, // 0.1s at 25Mhz
    parameter FIFO_DEPTH = 128
) (
    // UART
    output wire o_tx,
    input wire i_rx,

    // Wishbone
    output wire o_wb_cyc,
    output wire o_wb_stb,
    output wire o_wb_we,
    output wire [31:0] o_wb_addr,
    output wire [31:0] o_wb_data,
    input wire i_wb_ack,
    input wire i_wb_err,
    input wire i_wb_stall,
    input wire [31:0] i_wb_data,

    // Interrupts
    input wire i_interrupt_1,
    input wire i_interrupt_2,
    input wire i_interrupt_3,
    input wire i_interrupt_4,

    input wire i_clk
);

localparam RESP_INT_1 = 4'b1000;
localparam RESP_INT_2 = 4'b1001;
localparam RESP_INT_3 = 4'b1010;
localparam RESP_INT_4 = 4'b1011;


// UART
wire [7:0] uart_rx_data;
wire uart_rx_valid;

reg [7:0] uart_tx_data;
wire uart_tx_ready;
reg uart_tx_valid = 0;

wbdbgbus_uart_rx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD(UART_BAUD)
) uart_rx (
    .o_data(uart_rx_data),
    .o_valid(uart_rx_valid),

    .i_in(i_rx),
    .i_clk(i_clk)
);

wbdbgbus_uart_tx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD(UART_BAUD)
) uart_tx (
    .o_ready(uart_tx_ready),
    .o_out(o_tx),

    .i_data(uart_tx_data),
    .i_valid(uart_tx_valid),
    .i_clk(i_clk)
);

// Wishbone Master
reg cmd_reset = 0;
reg cmd_valid = 0;
wire cmd_ready;
reg [35:0] cmd_data;

wire resp_valid;
wire [35:0] resp_data;

wbdbgbusmaster #(
    .TIMEOUT_CLKS(DROP_CLKS)
) wbdbgbusmaster (
    .i_cmd_reset(cmd_reset),
    .i_cmd_valid(cmd_valid),
    .o_cmd_ready(cmd_ready),
    .i_cmd_data(cmd_data),

    .o_resp_valid(resp_valid),
    .o_resp_data(resp_data),

    .o_wb_cyc(o_wb_cyc),
    .o_wb_stb(o_wb_stb),
    .o_wb_we(o_wb_we),
    .o_wb_addr(o_wb_addr),
    .o_wb_data(o_wb_data),
    .i_wb_ack(i_wb_ack),
    .i_wb_err(i_wb_err),
    .i_wb_stall(i_wb_stall),
    .i_wb_data(i_wb_data),

    .i_clk(i_clk)
);

// Command FIFO
reg cmd_fifo_rd_en = 0;
wire [35:0] cmd_fifo_rd_data;
wire cmd_fifo_rd_valid;
reg cmd_fifo_wr_en = 0;
reg [35:0] cmd_fifo_wr_data = 0;
wire cmd_fifo_empty;
wire cmd_fifo_full;

wbdbgbus_fifo #(
    .WIDTH(36),
    .DEPTH(FIFO_DEPTH)
) cmd_fifo (
    .i_rd_en(cmd_fifo_rd_en),
    .o_rd_data(cmd_fifo_rd_data),
    .o_rd_valid(cmd_fifo_rd_valid),
    .i_wr_en(cmd_fifo_wr_en),
    .i_wr_data(cmd_fifo_wr_data),
    .o_empty(cmd_fifo_empty),
    .o_full(cmd_fifo_full),
    .i_clk(i_clk),
    .i_rst(cmd_reset)
);

// Response FIFO
reg resp_fifo_rd_en = 0;
wire [35:0] resp_fifo_rd_data;
wire resp_fifo_rd_valid;
reg resp_fifo_wr_en = 0;
reg [35:0] resp_fifo_wr_data = 0;
wire resp_fifo_empty;
wire resp_fifo_full;

wbdbgbus_fifo #(
    .WIDTH(36),
    .DEPTH(FIFO_DEPTH)
) resp_fifo (
    .i_rd_en(resp_fifo_rd_en),
    .o_rd_data(resp_fifo_rd_data),
    .o_rd_valid(resp_fifo_rd_valid),
    .i_wr_en(resp_fifo_wr_en),
    .i_wr_data(resp_fifo_wr_data),
    .o_empty(resp_fifo_empty),
    .o_full(resp_fifo_full),
    .i_clk(i_clk),
    .i_rst(cmd_reset)
);


reg [39:0] transmit_data = 0;
reg [2:0] transmit_state = 0; // 0 = no tx, 1-5 = bytes

// Interrupt handling
reg interrupt_1_last = 0;
reg interrupt_2_last = 0;
reg interrupt_3_last = 0;
reg interrupt_4_last = 0;

reg interrupt_1_rising = 0;
reg interrupt_2_rising = 0;
reg interrupt_3_rising = 0;
reg interrupt_4_rising = 0;

always_ff @(posedge i_clk) begin
    interrupt_1_last <= i_interrupt_1;
    interrupt_2_last <= i_interrupt_2;
    interrupt_3_last <= i_interrupt_3;
    interrupt_4_last <= i_interrupt_4;
end

// Buffer debug bus output into FIFO
always_ff @(posedge i_clk) begin
    resp_fifo_wr_en <= 0;

    if (resp_valid && ~resp_fifo_full) begin
        resp_fifo_wr_data <= resp_data;
        resp_fifo_wr_en <= 1;
    end
end

// Transmit responses from FIFO
// Also handles interrupts in order to give them priority
always_ff @(posedge i_clk) begin
    uart_tx_valid <= 0;
    resp_fifo_rd_en <= 0;

    // This allows interrupts to be detected even if a transmission
    // is in progress. It is not designed, however, for interrupts
    // which happen very close together (closer than 40 UART-bits together).
    if (i_interrupt_1 && ~interrupt_1_last)
        interrupt_1_rising <= 1;

    if (i_interrupt_2 && ~interrupt_2_last)
        interrupt_2_rising <= 1;

    if (i_interrupt_3 && ~interrupt_3_last)
        interrupt_3_rising <= 1;

    if (i_interrupt_4 && ~interrupt_4_last)
        interrupt_4_rising <= 1;

    // Start FIFO read
    if ((transmit_state == 0) &&
        ~resp_fifo_empty &&
        ~resp_fifo_rd_valid &&
        ~resp_fifo_rd_en &&
        ~interrupt_1_rising &&
        ~interrupt_2_rising &&
        ~interrupt_3_rising &&
        ~interrupt_4_rising) begin

        resp_fifo_rd_en <= 1;
    end

    if (transmit_state == 0) begin
        // FIFO response, triggered by a FIFO read on previous cycle
        if (resp_fifo_rd_valid) begin
            transmit_data <= {4'b0000, resp_fifo_rd_data};
            transmit_state <= 1;
        end
        else if (resp_fifo_rd_en) begin
            // If currently reading from FIFO, don't allow interrupts
        end
        else if (interrupt_1_rising) begin
            transmit_data <= {4'b0000, RESP_INT_1, 32'b0};
            transmit_state <= 1;
            interrupt_1_rising <= 0;
        end
        else if (interrupt_2_rising) begin
            transmit_data <= {4'b0000, RESP_INT_2, 32'b0};
            transmit_state <= 1;
            interrupt_2_rising <= 0;
        end
        else if (interrupt_3_rising) begin
            transmit_data <= {4'b0000, RESP_INT_3, 32'b0};
            transmit_state <= 1;
            interrupt_3_rising <= 0;
        end
        else if (interrupt_4_rising) begin
            transmit_data <= {4'b0000, RESP_INT_4, 32'b0};
            transmit_state <= 1;
            interrupt_4_rising <= 0;
        end
    end
    else begin
        if (uart_tx_ready && ~uart_tx_valid) begin
            case (transmit_state)
                1: uart_tx_data <= transmit_data[39:32];
                2: uart_tx_data <= transmit_data[31:24];
                3: uart_tx_data <= transmit_data[23:16];
                4: uart_tx_data <= transmit_data[15:8];
                5: uart_tx_data <= transmit_data[7:0];
                default: uart_tx_data <= 0;
            endcase

            uart_tx_valid <= 1;

            transmit_state <= transmit_state + 1;

            if (transmit_state == 5) begin
                transmit_state <= 0;
            end
        end
    end
end

reg [39:0] recieve_data = 0;
reg [2:0] recieve_state = 0; // 0-4 = bytes, 5 = stalled

// Countdown to dropping un-finished instruction
/* verilator lint_off WIDTH */
reg [$clog2(DROP_CLKS):0] drop_timer = DROP_CLKS;
/* verilator lint_on WIDTH */

// Recieve commands and add to command FIFO
always_ff @(posedge i_clk) begin
    cmd_reset <= 0;
    cmd_fifo_wr_en <= 0;

    if (uart_rx_valid) begin
        case (recieve_state)
            0: recieve_data[39:32] <= uart_rx_data;
            1: recieve_data[31:24] <= uart_rx_data;
            2: recieve_data[23:16] <= uart_rx_data;
            3: recieve_data[15:8] <= uart_rx_data;
            4: recieve_data[7:0] <= uart_rx_data;
        endcase

        recieve_state <= recieve_state + 1;
        /* verilator lint_off WIDTH */
        drop_timer <= DROP_CLKS;
        /* verilator lint_on WIDTH */

        if (recieve_state == 4) begin
            // Reset
            if (recieve_data[35:32] == 4'b1111) begin
                cmd_reset <= 1;
                recieve_state <= 0;
            end
            else begin
                if (~cmd_fifo_full) begin
                    cmd_fifo_wr_en <= 1;
                    cmd_fifo_wr_data <= {recieve_data[35:8], uart_rx_data};
                end
                recieve_state <= 0;
            end
        end
    end
    else if (recieve_state > 0) begin
        drop_timer <= drop_timer - 1;

        if (drop_timer == 1) begin
            recieve_state <= 0;
        end
    end
end

// Read from command FIFO and forward to bus
always_ff @(posedge i_clk) begin
    cmd_valid <= 0;
    cmd_fifo_rd_en <= 0;

    if (~cmd_reset && cmd_ready && ~cmd_fifo_empty &&
        ~cmd_fifo_rd_en && ~cmd_fifo_rd_valid && ~cmd_valid) begin
        cmd_fifo_rd_en <= 1;
    end

    if (cmd_ready && cmd_fifo_rd_valid && ~cmd_reset) begin
        cmd_valid <= 1;
        cmd_data <= cmd_fifo_rd_data;
    end
end

endmodule

module wbdbgbusmaster #(
    parameter TIMEOUT_CLKS = 100000
) (
    // Debug port connection
    input wire i_cmd_reset,
    input wire i_cmd_valid,
    output wire o_cmd_ready,
    input wire [35:0] i_cmd_data,
    
    output reg o_resp_valid = 0,
    output reg [35:0] o_resp_data,

    // Wishbone bus connection
    output reg o_wb_cyc = 0,
    output reg o_wb_stb = 0,
    output reg o_wb_we = 0,
    output reg [31:0] o_wb_addr = 0,
    output reg [31:0] o_wb_data = 0,
    input wire i_wb_ack,
    input wire i_wb_err,
    input wire i_wb_stall,
    input wire [31:0] i_wb_data,

    input wire i_clk
);

localparam CMD_READ_REQ     = 4'b0001;
localparam CMD_WRITE_REQ    = 4'b0010;
localparam CMD_SET_ADDR     = 4'b0011;
localparam CMD_SET_ADDR_INC = 4'b0111;

localparam RESP_READ_RESP   = 4'b0001;
localparam RESP_WRITE_ACK   = 4'b0010;
localparam RESP_ADDR_ACK    = 4'b0011;
localparam RESP_BUS_ERROR   = 4'b0100;
localparam RESP_BUS_RESET   = 4'b0101;

/* verilator lint_off WIDTH */
reg [$clog2(TIMEOUT_CLKS):0] timeout_ctr = TIMEOUT_CLKS;
/* verilator lint_on WIDTH */

reg addr_inc = 0;

assign o_cmd_ready = (~o_wb_cyc);

wire cmd_recv = i_cmd_valid && o_cmd_ready;
wire [3:0] cmd_inst = i_cmd_data[35:32];
wire [31:0] cmd_data = i_cmd_data[31:0];

// Bus state
always_ff @(posedge i_clk) begin
    if (i_wb_err || i_cmd_reset || timeout_ctr == 1) begin
        timeout_ctr <= TIMEOUT_CLKS;
        // Reset on error, bus-reset, or timeout
        o_wb_cyc <= 0;
        o_wb_stb <= 0;
    end
    /*else if (o_wb_stb) begin
        timeout_ctr <= timeout_ctr - 1;
        // If not stalled, output is complete
        if (!i_wb_stall) begin
            o_wb_stb <= 0;
        end
    end*/
    else if (o_wb_cyc) begin
        timeout_ctr <= timeout_ctr - 1;
        // Once acknowledged, finish cycle
        if (i_wb_ack) begin
            o_wb_cyc <= 0;
            o_wb_stb <= 0;
        end
    end
    else begin
        timeout_ctr <= TIMEOUT_CLKS;
        if (cmd_recv && 
            ((cmd_inst == CMD_READ_REQ) || (cmd_inst == CMD_WRITE_REQ))) begin

            o_wb_cyc <= 1;
            o_wb_stb <= 1;
        end
    end
end

reg last_stb;

// Addressing
always_ff @(posedge i_clk) begin
    last_stb <= o_wb_stb;
    if (cmd_recv) begin
        if ((cmd_inst == CMD_SET_ADDR) || (cmd_inst == CMD_SET_ADDR_INC)) begin
            o_wb_addr <= cmd_data;
            addr_inc <= (cmd_inst == CMD_SET_ADDR_INC);
        end
    end
    else if (~o_wb_stb && last_stb) begin
        /* verilator lint_off WIDTH */
        o_wb_addr <= o_wb_addr + addr_inc;
        /* verilator lint_on WIDTH */
    end
end

// Write-Enable
always_ff @(posedge i_clk) begin
    // Allow for stalling
    if(~o_wb_cyc) begin
        o_wb_we <= cmd_recv && (cmd_inst == CMD_WRITE_REQ);
    end
end

// Write Data
always_ff @(posedge i_clk) begin
    // Update data when not stalled
    if (~o_wb_cyc) begin
        o_wb_data <= cmd_data;
    end
end

// Acknowledgement / response
always_ff @(posedge i_clk) begin
    o_resp_valid <= 0;

    if (i_cmd_reset) begin
        o_resp_valid <= 1;
        o_resp_data <= {RESP_BUS_RESET, 32'b0};
    end
    else if (i_wb_err || timeout_ctr == 1) begin
        o_resp_valid <= 1;
        o_resp_data <= {RESP_BUS_ERROR, 32'b0};
    end
    else if (o_wb_cyc && i_wb_ack) begin
        o_resp_valid <= 1;
        if (o_wb_we) begin
            o_resp_data <= {RESP_WRITE_ACK, 32'b0};
        end
        else begin
            o_resp_data <= {RESP_READ_RESP, i_wb_data};
        end
    end
    else if (cmd_recv && 
        ((cmd_inst == CMD_SET_ADDR) || (cmd_inst == CMD_SET_ADDR_INC))) begin
        o_resp_valid <= 1;
        o_resp_data <= {RESP_ADDR_ACK, 32'b0};
    end
end

endmodule



module wbdbgbus_fifo #(
    parameter WIDTH = 36,
    parameter DEPTH = 128
) (
    // Read port
    input wire i_rd_en,
    output reg [(WIDTH - 1):0] o_rd_data,
    output reg o_rd_valid = 0,

    // Write port
    input wire i_wr_en,
    input wire [(WIDTH - 1):0] i_wr_data,

    // Status
    output wire o_empty,
    output wire o_full,

    input wire i_clk,
    input wire i_rst
);

localparam ADDR_WIDTH = $clog2(DEPTH);

reg [(ADDR_WIDTH - 1):0] wr_ptr = 0;
reg [(ADDR_WIDTH - 1):0] rd_ptr = 0;
reg [ADDR_WIDTH:0] len = 0;

reg [(WIDTH - 1):0] ram[0:(DEPTH - 1)];

/* verilator lint_off WIDTH */
assign o_empty = (len == 0);
assign o_full = (len == DEPTH);
/* verilator lint_on WIDTH */

// Write
always_ff @(posedge i_clk) begin
    if (i_rst) begin
        wr_ptr <= 0;
    end
    else if (i_wr_en) begin
        wr_ptr <= wr_ptr + 1;
        ram[wr_ptr] <= i_wr_data;

        if (o_full) begin
            $display("ERROR: WROTE TO FULL FIFO");
        end
    end
end

// Read
always_ff @(posedge i_clk) begin
    o_rd_valid <= 0;

    if (i_rst) begin
        rd_ptr <= 0;
    end
    else if (i_rd_en) begin
        rd_ptr <= rd_ptr + 1;
        o_rd_data <= ram[rd_ptr];
        o_rd_valid <= ~o_empty;

        if (o_empty) begin
            $display("ERROR: READ FROM EMPTY FIFO");
        end
    end
end

// Track length
always_ff @(posedge i_clk) begin
    if (i_rst) begin
        len <= 0;
    end

    // Read, no write
    else if (i_rd_en && ~i_wr_en && ~o_empty) begin
        len <= len - 1;
    end

    // Write, no read
    else if (i_wr_en && ~i_rd_en && ~o_full) begin
        len <= len + 1;
    end

    // Otherwise, if read and write on same cycle, len remains same
end


`ifdef VERILATOR
    // Verify depth is power of 2 and greater than 1
    always_comb begin
        assert((DEPTH & (DEPTH - 1)) == 0);
        assert((1 << ADDR_WIDTH) == DEPTH);
        assert(DEPTH > 1);
    end
`endif

endmodule

// UART Reciever (8/N/1)
module wbdbgbus_uart_rx
#(
    parameter CLK_FREQ = 250000,
    parameter BAUD = 9600
)
(
    output reg [7:0] o_data,
    output reg o_valid,

    input wire i_in,
    input wire i_clk
); 

parameter CLKS_PER_BIT = CLK_FREQ / BAUD;
parameter CLKS_PER_1_5_BIT = 3 * CLKS_PER_BIT / 2;

reg[$clog2(CLKS_PER_BIT * 2):0] counter;
reg [3:0] state = 0; // 0 = idle, 1 = start bit, 2-9 = data bits

always_ff @(posedge i_clk) begin
    o_valid <= 0;
    counter <= 10; // Set counter to default value when idle

    if(state == 0) begin
        // Start bit
        if(i_in == 0) begin
            state <= 1;
            /* verilator lint_off WIDTH */
            counter <= CLKS_PER_1_5_BIT;
            /* verilator lint_on WIDTH */
        end

        // Else stay in idle
    end
    else if (counter == 0) begin
        // End bit
        if(state == 9) begin
            if (i_in == 1) begin
                o_valid <= 1;
                `ifdef DEBUG
                    $display("RECEIVED 0x%H (%B)", o_data, o_data);
                `endif
            end
            else begin
                `ifdef DEBUG
                    $display("INVALID END BIT");
                `endif
            end

            state <= 0;
        end

        // Data bits
        else begin
            state <= state + 1;
            o_data[state - 1] <= i_in;

            /* verilator lint_off WIDTH */
            counter <= CLKS_PER_BIT;
            /* verilator lint_on WIDTH */
        end
    end
    else begin
        counter <= counter - 1;
    end
end

endmodule

// UART Transmitter (8/N/1)
module wbdbgbus_uart_tx
#(
    parameter CLK_FREQ = 250000,
    parameter BAUD = 9600
)
(
    output wire o_ready,
    output reg o_out,

    input wire [7:0] i_data,
    input wire i_valid,
    input wire i_clk
); 

parameter CLKS_PER_BIT = CLK_FREQ / BAUD;

reg[($clog2(CLKS_PER_BIT) + 1):0] counter;
reg [3:0] state = 0; // 0 = idle, 1 = start bit, 2-9 = data bits, 10 = end bit

reg [7:0] data_send; // Buffer the data in case it changes while sending

assign o_ready = (state == 0);

always_ff @(posedge i_clk) begin
    counter <= 10; // Set counter to default value when idle

    if(state == 0) begin
        // Start transmission
        if(i_valid) begin
            state <= 1;
            data_send <= i_data;

            /* verilator lint_off WIDTH */
            counter <= CLKS_PER_BIT;
            /* verilator lint_on WIDTH */
        end

        // Else stay in idle
    end
    else if (counter == 0) begin
        // End bit
        if(state == 10) begin
            state <= 0;
            `ifdef DEBUG
                $display("TRANSMIT FINISHED");
            `endif
        end

        else begin
            state <= state + 1;
            /* verilator lint_off WIDTH */
            if (state == 10) begin
                counter <= CLKS_PER_BIT - 1;
            end
            else begin
                counter <= CLKS_PER_BIT;
            end
            /* verilator lint_on WIDTH */
        end
    end
    else begin
        counter <= counter - 1;
    end
end

always_comb begin
    if(state == 0) begin
        o_out = 1;
    end
    else if(state == 1) begin
        o_out = 0;
    end
    else if(state == 10) begin
        o_out = 1;
    end
    else begin
        o_out = data_send[state - 2];
    end
end

`ifdef VERILATOR
always @(*)
    assert(o_out || (state != 0));
`endif

endmodule

