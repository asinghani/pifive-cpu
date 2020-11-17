`default_nettype none

// 32-bit wide memory with byte-level subword addressing
// Subword addressing is little-endian
module bram32
#(
    parameter DEPTH = 512,
    parameter INIT_FILE = "",
    localparam ADDR_WIDTH = $clog2(DEPTH)
)
(
    output wire [31:0] o_data,
    input wire [(ADDR_WIDTH - 1):0] i_addr,
    input wire [31:0] i_data,
    input wire i_we,

    // Write-subaddress
    // 1 = word
    // 2 = half0, 3 = half1
    // 4 = byte0, 5 = byte1, 6 = byte2, 7 = byte3
    // (byte0/half0 = LSB)
    input wire [2:0] i_wr_subaddr,

    input wire i_clk
);

// Infer the RAM object
reg [35:0] ram[0:(DEPTH - 1)];

// Initialization
initial begin
`ifdef VERIFICATION
    if ((DEPTH % 512) != 0) begin
        $error("Depth must be a multiple of 512");
    end
`endif

    if (|INIT_FILE) begin
        $readmemb(INIT_FILE, ram);
    end
end

reg [(ADDR_WIDTH - 1):0] r_addr;

// Clocked read/write
always_ff @(posedge i_clk) begin
    // Write
    if (i_we) begin
        case (i_wr_subaddr)
            1: ram[i_addr][31:0] <= i_data[31:0];

            2: ram[i_addr][15:0] <= i_data[15:0];
            3: ram[i_addr][31:16] <= i_data[15:0];

            4: ram[i_addr][7:0] <= i_data[7:0];
            5: ram[i_addr][15:8] <= i_data[7:0];
            6: ram[i_addr][23:16] <= i_data[7:0];
            7: ram[i_addr][31:24] <= i_data[7:0];
        endcase
    end

    // Read
    r_addr <= i_addr;
end

assign o_data = ram[r_addr][31:0];


endmodule
