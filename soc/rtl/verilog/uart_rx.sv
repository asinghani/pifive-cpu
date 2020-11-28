`default_nettype none

// UART Reciever (8/N/1)
module uart_rx (
    output reg [7:0] o_data,
    output reg o_valid,

    // Clock divider - should be equal to 0.5 * clock frequency / baud rate
    input wire [15:0] i_divider,

    input wire i_in,
    input wire i_clk,
    input wire i_rst
); 

reg [16:0] counter;
reg [3:0] state = 0; // 0 = idle, 1 = start bit, 2-9 = data bits

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        counter <= 10;
        state <= 0;
        o_valid <= 0;
    end
    else begin
        o_valid <= 0;
        counter <= 10; // Set counter to default value when idle

        if(state == 0) begin
            // Start bit
            if(i_in == 0) begin
                state <= 1;
                counter <= 3 * i_divider;
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

                counter <= 2 * i_divider;
            end
        end
        else begin
            counter <= counter - 1;
        end
    end
end

endmodule

