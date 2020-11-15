`default_nettype none

module imembus (
    Wishbone.Controller wb,

    input wire [31:0] i_addr,
    output wire [31:0] o_data,
    output wire [31:0] o_read_addr,
    input wire i_re,
    output wire o_stall = 0,
    output wire o_error,
    output reg o_unaligned = 0,

    input wire i_clk,
    input wire i_rst
);

assign wb.we = 0;
assign wb.sel = 4'b1111;
assign wb.data_wr = 0;

reg started;
wire in_progress = started && ~(wb.ack || wb.err);
assign o_stall = in_progress;

reg [31:0] r_addr;
always_ff @(posedge i_clk) if (i_re) r_addr <= i_addr;
wire [31:0] l_addr = i_re ? i_addr : r_addr;

assign wb.addr = l_addr;

reg [31:0] r_data;
always_ff @(posedge i_clk) if (wb.ack) r_data <= wb.data_rd;
wire [31:0] l_data = wb.ack ? wb.data_rd : r_data;
assign o_data = l_data;

reg [31:0] r_read_addr;
always_ff @(posedge i_clk) if (wb.ack) r_read_addr <= r_addr;
wire [31:0] l_read_addr = wb.ack ? r_addr : r_read_addr;
assign o_read_addr = l_read_addr;

reg r_err;
always_ff @(posedge i_clk) begin 
    if (wb.err) r_err <= 1;
    if (i_re) r_err <= 0;
    if (i_rst) r_err <= 0;
end
wire l_err = wb.err ? 1 : r_err;
assign o_error = l_err;

wire unaligned = i_re && i_addr[1:0] != 0;

assign wb.cyc = wb.stb || in_progress;
assign wb.stb = ~unaligned && (i_re && ~in_progress) && ~i_rst;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        started <= 0;
        o_unaligned <= 0;
    end
    else begin
        o_unaligned <= unaligned;
        if (wb.ack || wb.err) begin
            started <= 0;
        end
        if (wb.stb) begin
            started <= 1;
        end
    end
end

`ifdef VERIFICATION
    always_ff @(posedge i_clk) begin
        if (o_stall && i_re) $error("Stall and read-req must be mutually exclusive");
    end
`endif

endmodule
