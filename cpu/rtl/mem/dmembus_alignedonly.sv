`default_nettype none

// Membus, only supports aligned accesses (word-access to 4-byte,
// halfword access to 2-byte, byte-access anywhere)
module dmembus_alignedonly (
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
    output reg o_unaligned = 0,

    input wire i_clk,
    input wire i_rst
);

reg started;
wire in_progress = started && ~(wb.ack || wb.err);
assign o_stall = in_progress && ~(wb.ack || wb.err);

wire i_req = i_we || i_re;

reg addr_unaligned;
wire unaligned = i_req && addr_unaligned;

reg [31:0] r_addr;
always_ff @(posedge i_clk) if (i_req) r_addr <= i_addr;
wire [31:0] l_addr = i_req ? i_addr : r_addr;
assign wb.addr = {l_addr[31:2], 2'b00};

reg [2:0] r_width; // {zeroextend[0:0], width[1:0]}
always_ff @(posedge i_clk) if (i_req) r_width <= {i_zeroextend, i_width};
wire [2:0] l_width = i_req ? {i_zeroextend, i_width} : r_width;
assign o_bus_width_hint = l_width[1:0];

reg [31:0] r_data_wr;
always_ff @(posedge i_clk) if (i_req) r_data_wr <= i_data;
wire [31:0] l_data_wr = i_req ? i_data : r_data_wr;

reg r_we;
always_ff @(posedge i_clk) if (i_req) r_we <= i_we;
wire l_we = i_req ? i_we : r_we;
assign wb.we = l_we;

reg [31:0] aligned_recv_data;
reg [31:0] r_data_rd;
always_ff @(posedge i_clk) if (wb.ack) r_data_rd <= aligned_recv_data;
wire [31:0] l_data_rd = wb.ack ? aligned_recv_data : r_data_rd;
assign o_data = l_data_rd;

//assign wb.cyc = wb.stb || in_progress;
wire stb = ~unaligned && (i_req && ~in_progress) && ~i_rst;
assign wb.cyc = stb || in_progress;
assign wb.stb = wb.cyc;

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

reg ext;
always_comb begin
    case({l_width[1:0], l_addr[1:0]}) inside
        {2'b01, 2'b00}: begin
            wb.sel = 4'b0001;
            wb.data_wr = {24'b0, l_data_wr[7:0]};
        end

        {2'b01, 2'b01}: begin
            wb.sel = 4'b0010;
            wb.data_wr = {16'b0, l_data_wr[7:0], 8'b0};
        end

        {2'b01, 2'b10}: begin
            wb.sel = 4'b0100;
            wb.data_wr = {8'b0, l_data_wr[7:0], 16'b0};
        end

        {2'b01, 2'b11}: begin
            wb.sel = 4'b1000;
            wb.data_wr = {l_data_wr[7:0], 24'b0};
        end

        {2'b10, 2'b00}: begin
            wb.sel = 4'b0011;
            wb.data_wr = {16'b0, l_data_wr[15:0]};
        end

        {2'b10, 2'b10}: begin
            wb.sel = 4'b1100;
            wb.data_wr = {l_data_wr[15:0], 16'b0};
        end

        default: begin
            wb.sel = 4'b1111;
            wb.data_wr = l_data_wr;
        end
    endcase

    // Use registered width because there may be new req on response cycle
    ext = 0;
    aligned_recv_data = wb.data_rd;
    case({r_width[1:0], r_addr[1:0]}) inside
        // Width, Addr
        // zero-extend = r_width[2]

        {2'b01, 2'b00}: begin
            ext = r_width[2] ? 0 : wb.data_rd[7];
            aligned_recv_data = {{24{ext}}, wb.data_rd[7:0]};
        end

        {2'b01, 2'b01}: begin
            ext = r_width[2] ? 0 : wb.data_rd[15];
            aligned_recv_data = {{24{ext}}, wb.data_rd[15:8]};
        end

        {2'b01, 2'b10}: begin
            ext = r_width[2] ? 0 : wb.data_rd[23];
            aligned_recv_data = {{24{ext}}, wb.data_rd[23:16]};
        end

        {2'b01, 2'b11}: begin
            ext = r_width[2] ? 0 : wb.data_rd[31];
            aligned_recv_data = {{24{ext}}, wb.data_rd[31:24]};
        end

        {2'b10, 2'b00}: begin
            ext = r_width[2] ? 0 : wb.data_rd[15];
            aligned_recv_data = {{16{ext}}, wb.data_rd[15:0]};
        end

        {2'b10, 2'b10}: begin
            ext = r_width[2] ? 0 : wb.data_rd[31];
            aligned_recv_data = {{16{ext}}, wb.data_rd[31:16]};
        end

        {2'b11, 2'b00}, {2'b00, 2'b00}: begin
            aligned_recv_data = wb.data_rd[31:0];
        end
    endcase


    case ({i_width, i_addr[1:0]}) inside
        {2'b01, 2'b00}: addr_unaligned = 0;
        {2'b01, 2'b01}: addr_unaligned = 0;
        {2'b01, 2'b10}: addr_unaligned = 0;
        {2'b01, 2'b11}: addr_unaligned = 0;
        {2'b10, 2'b00}: addr_unaligned = 0;
        {2'b10, 2'b10}: addr_unaligned = 0;
        {2'b00, 2'b00}: addr_unaligned = 0;
        {2'b11, 2'b00}: addr_unaligned = 0;
        default: addr_unaligned = 1;
    endcase
end

`ifdef VERIFICATION
    always_ff @(posedge i_clk) begin
        if (o_stall && i_req) $error("Stall and read/write-req must be mutually exclusive");
    end
`endif

endmodule
