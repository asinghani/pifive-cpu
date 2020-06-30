`default_nettype none

// 32-bit wide memory
module rom32
#(
    parameter DEPTH = 512,
    parameter INIT_FILE = "",
    localparam ADDR_WIDTH = $clog2(DEPTH)
)
(
    output wire [31:0] o_data,
    input wire [(ADDR_WIDTH - 1):0] i_addr,

    input wire i_clk
);

// RAM object
reg [35:0] ram[0:(DEPTH - 1)];

// Initialization
initial begin
    if (INIT_FILE) begin
        $readmemb(INIT_FILE, ram);
    end
end

reg [(ADDR_WIDTH - 1):0] r_addr;

// Clocked read
always_ff @(posedge i_clk) begin
    r_addr <= i_addr;
end

assign o_data = ram[r_addr][31:0];


endmodule
