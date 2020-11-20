`default_nettype none

// UART Transmitter (8/N/1)
module uart_tx (
    output wire o_ready,
    output reg o_out,

    // Clock divider - should be equal to 0.5 * clock frequency / baud rate
    input wire [15:0] i_divider,

    input wire [7:0] i_data,
    input wire i_valid,
    input wire i_clk,
    input wire i_rst
); 

reg [16:0] counter;
reg [3:0] state = 0; // 0 = idle, 1 = start bit, 2-9 = data bits, 10 = end bit

reg [7:0] data_send; // Buffer the data in case it changes while sending

assign o_ready = (state == 0) && ~i_rst;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        counter <= 10;
        state <= 0;
        data_send <= 0;
    end
    else begin
        counter <= 10; // Set counter to default value when idle

        if(state == 0) begin
            // Start transmission
            if(i_valid) begin
                state <= 1;
                data_send <= i_data;

                /* verilator lint_off WIDTH */
                counter <= 2 * i_divider;
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
                    counter <= (2 * i_divider) - 1;
                end
                else begin
                    counter <= 2 * i_divider;
                end
                /* verilator lint_on WIDTH */
            end
        end
        else begin
            counter <= counter - 1;
        end
    end
end

always_comb begin
    if (i_rst) begin
        o_out = 1;
    end
    else if (state == 0) begin
        o_out = 1;
    end
    else if (state == 1) begin
        o_out = 0;
    end
    else if (state == 10) begin
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

