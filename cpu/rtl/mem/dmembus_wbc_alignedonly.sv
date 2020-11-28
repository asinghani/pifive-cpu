`default_nettype none

// Membus, only supports aligned accesses (word-access to 4-byte,
// halfword access to 2-byte, byte-access anywhere)
module dmembus_wbc_alignedonly (
    Wishbone.Controller wb,

    // Can be used by wishbone controller or ignored
    // Only width_hint bytes are required to be read,
    // other bytes will be ignored
    output reg [1:0] o_bus_width_hint, 

    input wire [31:0] i_addr,
    output reg [31:0] o_data,
    input wire [31:0] i_data,
    input wire [1:0] i_width,
    input wire i_we,
    input wire i_re,
    input wire i_zeroextend,
    output reg o_stall,
    output reg o_error,
    output reg o_unaligned = 0,

    input wire i_clk,
    input wire i_rst
);

assign wb.cyc = wb.stb;
wire i_req = i_we || i_re;
reg [4:0] r_width; // {zeroextend[0:0], width[1:0], addr[1:0]}

reg addr_unaligned;
wire unaligned = i_req && addr_unaligned;

reg [3:0] sel;
reg [31:0] aligned_send_data;
reg [31:0] aligned_recv_data;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        o_error <= 0;
        o_stall <= 0;
        o_unaligned <= 0;
        wb.stb <= 0;
    end
    else begin
        o_unaligned <= unaligned;

        if (wb.ack || wb.err) begin
            if (wb.err) o_error <= 1;
            
            wb.stb <= 0;
            o_stall <= 0;
            o_data <= aligned_recv_data;
        end
        if (i_req && ~unaligned) begin
            r_width <= {i_zeroextend, i_width, i_addr[1:0]};
            wb.stb <= 1;
            wb.addr <= {i_addr[31:2], 2'b00};
            wb.we <= i_we;
            wb.sel <= sel;
            wb.data_wr <= aligned_send_data;
            o_stall <= 1;
            o_error <= 0;
            
        end
    end
end

reg ext;
always_comb begin
    case({i_width[1:0], i_addr[1:0]}) inside
        {2'b01, 2'b00}: begin
            sel = 4'b0001;
            aligned_send_data = {24'b0, i_data[7:0]};
        end

        {2'b01, 2'b01}: begin
            sel = 4'b0010;
            aligned_send_data = {16'b0, i_data[7:0], 8'b0};
        end

        {2'b01, 2'b10}: begin
            sel = 4'b0100;
            aligned_send_data = {8'b0, i_data[7:0], 16'b0};
        end

        {2'b01, 2'b11}: begin
            sel = 4'b1000;
            aligned_send_data = {i_data[7:0], 24'b0};
        end

        {2'b10, 2'b00}: begin
            sel = 4'b0011;
            aligned_send_data = {16'b0, i_data[15:0]};
        end

        {2'b10, 2'b10}: begin
            sel = 4'b1100;
            aligned_send_data = {i_data[15:0], 16'b0};
        end

        default: begin
            sel = 4'b1111;
            aligned_send_data = i_data;
        end
    endcase

    // Use registered width because there may be new req on response cycle
    ext = 0;
    aligned_recv_data = wb.data_rd;
    case(r_width[3:0]) inside
        // Width, Addr
        // zero-extend = r_width[4]

        {2'b01, 2'b00}: begin
            ext = r_width[4] ? 0 : wb.data_rd[7];
            aligned_recv_data = {{24{ext}}, wb.data_rd[7:0]};
        end

        {2'b01, 2'b01}: begin
            ext = r_width[4] ? 0 : wb.data_rd[15];
            aligned_recv_data = {{24{ext}}, wb.data_rd[15:8]};
        end

        {2'b01, 2'b10}: begin
            ext = r_width[4] ? 0 : wb.data_rd[23];
            aligned_recv_data = {{24{ext}}, wb.data_rd[23:16]};
        end

        {2'b01, 2'b11}: begin
            ext = r_width[4] ? 0 : wb.data_rd[31];
            aligned_recv_data = {{24{ext}}, wb.data_rd[31:24]};
        end

        {2'b10, 2'b00}: begin
            ext = r_width[4] ? 0 : wb.data_rd[15];
            aligned_recv_data = {{16{ext}}, wb.data_rd[15:0]};
        end

        {2'b10, 2'b10}: begin
            ext = r_width[4] ? 0 : wb.data_rd[31];
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
