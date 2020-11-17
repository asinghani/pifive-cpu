`default_nettype none

module imembus_wbc (
    Wishbone.Controller wb,

    input wire [31:0] i_addr,
    output reg [31:0] o_data,
    output reg [31:0] o_read_addr,
    input wire i_re,
    output reg o_stall,
    output reg o_valid,
    output reg o_error,
    output reg o_unaligned = 0,

    input wire i_clk,
    input wire i_rst
);

assign wb.we = 0;
assign wb.sel = 4'b1111;
assign wb.data_wr = 0;
assign wb.cyc = wb.stb;

wire unaligned = i_re && i_addr[1:0] != 0;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        o_error <= 0;
        o_valid <= 0;
        o_stall <= 0;
        o_unaligned <= 0;
        wb.stb <= 0;
    end
    else begin
        o_unaligned <= unaligned;
        if (wb.ack || wb.err) begin
            if (wb.err) o_error <= 1;

            wb.stb <= 0;
            o_valid <= 1;
            o_stall <= 0;
            o_data <= wb.data_rd;
            o_read_addr <= wb.addr;
        end

        if (i_re && ~unaligned) begin
            wb.stb <= 1;
            wb.addr <= i_addr;
            o_stall <= 1;
            o_error <= 0;
        end
    end
end

`ifdef VERIFICATION
    always_ff @(posedge i_clk) begin
        if (o_stall && i_re) $error("Stall and read-req must be mutually exclusive");
    end
`endif

endmodule
