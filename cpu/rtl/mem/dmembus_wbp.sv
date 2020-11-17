`default_nettype none

module dmembus_wbp (
    Wishbone.Controller wb,

    // Can be used by wishbone controller or ignored
    // Only width_hint bytes are required to be read,
    // other bytes will be ignored
    output wire [1:0] o_bus_width_hint, 

    input wire [31:0] i_addr,
    output wire [31:0] o_data,
    input wire [31:0] i_data,
    input wire [1:0] i_width,
    input wire i_we,
    input wire i_re,
    input wire i_zeroextend,
    output wire o_stall,
    output wire o_error,

    input wire i_clk,
    input wire i_rst
);

reg started;
wire in_progress = started && ~(wb.ack || wb.err);
assign o_stall = in_progress;

wire i_req = i_we || i_re;

reg [31:0] r_addr;
always_ff @(posedge i_clk) if (i_req) r_addr <= i_addr;
wire [31:0] l_addr = i_req ? i_addr : r_addr;
assign wb.addr = l_addr;

reg [2:0] r_width; // {zeroextend[0:0], width[1:0]}
always_ff @(posedge i_clk) if (i_req) r_width <= {i_zeroextend, i_width};
wire [2:0] l_width = i_req ? {i_zeroextend, i_width} : r_width;
assign o_bus_width_hint = l_width[1:0];

reg [31:0] r_data_wr;
always_ff @(posedge i_clk) if (i_req) r_data_wr <= i_data;
wire [31:0] l_data_wr = i_req ? i_data : r_data_wr;
assign wb.data_wr = l_data_wr;

reg r_we;
always_ff @(posedge i_clk) if (i_req) r_we <= i_we;
wire l_we = i_req ? i_we : r_we;
assign wb.we = l_we;

reg [31:0] aligned_recv_data;
reg [31:0] r_data_rd;
always_ff @(posedge i_clk) if (wb.ack) r_data_rd <= aligned_recv_data;
wire [31:0] l_data_rd = wb.ack ? aligned_recv_data : r_data_rd;
assign o_data = l_data_rd;

wire stb = (i_req && ~in_progress) && ~i_rst;
assign wb.cyc = stb || in_progress;
assign wb.stb = stb;

reg r_err;
always_ff @(posedge i_clk) begin 
    if (wb.err) r_err <= 1;
    if (i_req) r_err <= 0;
    if (i_rst) r_err <= 0;
end
wire l_err = wb.err ? 1 : r_err;
assign o_error = l_err;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        started <= 0;
    end
    else begin
        if (wb.ack || wb.err) begin
            started <= 0;
        end
        if (wb.stb) begin
            started <= 1;
        end
    end
end

always_comb begin
    case(l_width[1:0])
        2'd1: wb.sel = 4'b0001;
        2'd2: wb.sel = 4'b0011;
        default: wb.sel = 4'b1111;
    endcase

    // Use registered width because there may be new req on response cycle
    aligned_recv_data = wb.data_rd;
    case(r_width)
        // Zero-extend, Width
        {1'b0, 2'd1}: aligned_recv_data = {{24{wb.data_rd[7]}}, wb.data_rd[7:0]};
        {1'b1, 2'd1}: aligned_recv_data = {24'b0, wb.data_rd[7:0]};
        {1'b0, 2'd2}: aligned_recv_data = {{16{wb.data_rd[15]}}, wb.data_rd[15:0]};
        {1'b1, 2'd2}: aligned_recv_data = {16'b0, wb.data_rd[15:0]};

        default: aligned_recv_data = wb.data_rd[31:0];
    endcase
end

`ifdef VERIFICATION
    always_ff @(posedge i_clk) begin
        if (o_stall && i_req) $error("Stall and read/write-req must be mutually exclusive");
    end
`endif

endmodule
