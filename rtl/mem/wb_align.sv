/*`default_nettype none


// TODO: incomplete

// Takes an unaligned wishbone request and converts it to 1 or 2 aligned
// requests
// Requires `sel` always be one of the following: 0000, 0001, 0011, 1111
module wb_align (
    Wishbone.Peripheral wb_in,
    Wishbone.Controller wb_out,

    input wire [1:0] i_bus_width_hint, // 1->1, 2->2, default->4
    output wire [1:0] o_bus_width_hint, 

    input wire i_clk,
    input wire i_rst
);

wire wb_in_req = wb_in.cyc && wb_in.stb;

reg [31:0] r_addr;
always_ff @(posedge i_clk) if (wb_in_req) r_addr <= wb.addr;
wire [31:0] l_addr = wb_in_req ? wb.addr : r_addr;

reg [3:0] r_sel;
always_ff @(posedge i_clk) if (wb_in_req) r_sel <= wb.sel;
wire [3:0] l_sel = wb_in_req ? wb.sel : r_sel;

reg r_we;
always_ff @(posedge i_clk) if (wb_in_req) r_we <= wb.we;
wire l_we = wb_in_req ? wb.we : r_we;

reg [1:0] r_width;
always_ff @(posedge i_clk) if (wb_in_req) r_width <= i_bus_width_hint;
wire [1:0] l_width = wb_in_req ? i_bus_width_hint : r_width;

reg [31:0] data_out;
assign wb_in.data_rd = data_out;

// To prevent extraneous reads
reg [31:0] last_data = 0;
reg [31:0] last_addr = 0;
reg last_valid = 0;

reg started = 0;

wire [31:0] req1_addr = {l_addr[31:2], 2'b00};
wire [31:0] req2_addr = {(l_addr[31:2]+1)[29:0], 2'b00};

// Mask applied AFTER shift
reg [31:0] resp1_mask;
reg [1:0] resp1_shift;
reg [31:0] resp2_mask;
reg [1:0] resp2_shift;
reg req2_needed;

reg [31:0] req1_data;
reg [3:0] req1_sel;
reg [31:0] req2_data;
reg [3:0] req2_sel;

// Set up request alignment
always_comb begin
    // Based on registered address, to prevent combinational loop with
    // acknowledgement
    resp1_mask = 0;
    resp1_shift = 0;
    resp2_mask = 0;
    resp2_shift = 0;
    req2_needed = 0;

    // Based on latched address, to allow immediate passthrough of requests
    req1_data = 0;
    req1_sel = 0;
    req2_data = 0;
    req2_sel = 0;

    case ({r_addr[1:0], r_width}) inside
        {2'b00, 2'b??}: begin
            // Addr offset 0, any width
            req2_needed = 0;

            resp1_mask = 32'hFFFFFFFF;
            resp1_shift = 0;
        end

        {2'b01, 2'b01}, {2'b01, 2'b10}: begin
            // Addr offset 1, width = (1, 2)
            req2_needed = 0;

            resp1_mask = 32'hFFFFFFFF;
            resp1_shift = 1;
        end

        {2'b01, 2'b00}, {2'b01, 2'b11}: begin
            // Addr offset 1, width = 4
            req2_needed = 1;

            req1_data = {l_data[23:0], 8'b0};
            req1_sel = {l_sel[2:0], 1'b0};

            req2_data = {24'b0, l_data[31:24]};
            req2_sel = {3'b0, l_sel[3]};
        end

        {2'b10, 2'b01}, {2'b10, 2'b10}: begin
            // Addr offset 2, width = (1, 2)
            req2_needed = 0;

            req1_data = {l_data[15:0], 16'b0};
            req1_sel = {l_sel[1:0], 2'b0};
        end

        {2'b10, 2'b00}, {2'b10, 2'b11}: begin
            // Addr offset 2, width = 4
            req2_needed = 1;

            req1_data = {l_data[15:0], 16'b0};
            req1_sel = {l_sel[1:0], 2'b0};

            req2_data = {16'b0, l_data[31:16]};
            req2_sel = {2'b0, l_sel[3:2]};
        end

        {2'b11, 2'b01}: begin
            // Addr offset 3, width = 1
            req2_needed = 0;

            req1_data = {l_data[7:0], 24'b0};
            req1_sel = {l_sel[0], 3'b0};
        end

        {2'b11, 2'b10}, {2'b10, 2'b00}, {2'b10, 2'b11}: begin
            // Addr offset 3, width = (2, 4)
            req2_needed = 1;

            req1_data = {l_data[7:0], 24'b0};
            req1_sel = {l_sel[0], 3'b0};

            req2_data = {8'b0, l_data[31:8]};
            req2_sel = {1'b0, l_sel[3:1]};
        end

        default: begin
`ifdef VERIFICATION
            $error("INVALID ACCESS");
`endif
        end
    endcase

    case ({l_addr[1:0], l_width}) inside
        {2'b00, 2'b??}: begin
            // Addr offset 0, any width
            req1_data = l_data;
            req1_sel = l_sel;
        end

        {2'b01, 2'b01}, {2'b01, 2'b10}: begin
            // Addr offset 1, width = (1, 2)
            req1_data = {l_data[23:0], 8'b0};
            req1_sel = {l_sel[2:0], 1'b0};
        end

        {2'b01, 2'b00}, {2'b01, 2'b11}: begin
            // Addr offset 1, width = 4
            req1_data = {l_data[23:0], 8'b0};
            req1_sel = {l_sel[2:0], 1'b0};

            req2_data = {24'b0, l_data[31:24]};
            req2_sel = {3'b0, l_sel[3]};
        end

        {2'b10, 2'b01}, {2'b10, 2'b10}: begin
            // Addr offset 2, width = (1, 2)
            req1_data = {l_data[15:0], 16'b0};
            req1_sel = {l_sel[1:0], 2'b0};
        end

        {2'b10, 2'b00}, {2'b10, 2'b11}: begin
            // Addr offset 2, width = 4
            req1_data = {l_data[15:0], 16'b0};
            req1_sel = {l_sel[1:0], 2'b0};

            req2_data = {16'b0, l_data[31:16]};
            req2_sel = {2'b0, l_sel[3:2]};
        end

        {2'b11, 2'b01}: begin
            // Addr offset 3, width = 1
            req1_data = {l_data[7:0], 24'b0};
            req1_sel = {l_sel[0], 3'b0};
        end

        {2'b11, 2'b10}, {2'b10, 2'b00}, {2'b10, 2'b11}: begin
            // Addr offset 3, width = (2, 4)
            req1_data = {l_data[7:0], 24'b0};
            req1_sel = {l_sel[0], 3'b0};

            req2_data = {8'b0, l_data[31:8]};
            req2_sel = {1'b0, l_sel[3:1]};
        end

        default: begin
`ifdef VERIFICATION
            $error("INVALID ACCESS");
`endif
        end
    endcase
end

`ifdef VERIFICATION
    always_ff @(posedge i_clk) begin
        case (l_sel) inside
            4'b0000, 4'b0001, 4'b0011, 4'b1111: begin end
            default: $error("Invalid value for sel");
        endcase
    end
`endif

endmodule*/
