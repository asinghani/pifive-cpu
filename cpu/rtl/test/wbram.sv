`default_nettype none

module wbram
#(
    parameter BASE_ADDR = 32'h00000000,
    parameter DEPTH_WORDS = 512,
    parameter [1023:0] INIT_FILE = "",
    localparam ADDR_WIDTH = $clog2(DEPTH_WORDS),

    parameter LATENCY = 0,

    parameter WIDTH_OVERRIDE = 32
)
(
    Wishbone.Peripheral wb,

    input wire i_clk,
    input wire i_rst
);

// Infer the RAM object
reg [(WIDTH_OVERRIDE - 1):0] ram[0:(DEPTH_WORDS - 1)];

// Initialization
initial begin
    if (|INIT_FILE) begin
        $readmemb(INIT_FILE, ram);
    end
end

wire [31:0] addr = (wb.addr - BASE_ADDR) >> 2;

wire valid_addr = (wb.addr >= BASE_ADDR && wb.addr < (BASE_ADDR + (4 * DEPTH_WORDS)));
wire aligned = (wb.addr[1:0] == 0);

reg [31:0] r_addr;

reg [$clog2(LATENCY):0] ctr = 0;

// Clocked read/write
always_ff @(posedge i_clk) begin
    wb.ack <= 0;
    wb.err <= 0;

    if (i_rst) ctr <= 0;

    if (wb.cyc && wb.stb) begin
        if (valid_addr && aligned) begin
            if (wb.we) begin
                if (wb.sel[0]) ram[addr][7:0] <= wb.data_wr[7:0];
                if (wb.sel[1]) ram[addr][15:8] <= wb.data_wr[15:8];
                if (wb.sel[2]) ram[addr][23:16] <= wb.data_wr[23:16];
                if (wb.sel[3]) ram[addr][31:24] <= wb.data_wr[31:24];

                if (LATENCY == 0) wb.ack <= 1;
                else ctr <= LATENCY[$clog2(LATENCY):0];
            end
            else begin
                r_addr <= addr;
                if (LATENCY == 0) begin
                    wb.data_rd <= ram[addr];
                    wb.ack <= 1;
                end
                else begin
                    ctr <= LATENCY[$clog2(LATENCY):0];
                end
            end
        end
        else begin
            $display("INVALID MEMORY ACCESS");
            wb.err <= 1;
        end
    end

    if (ctr > 0) begin
        ctr <= ctr - 1;
        if ((ctr - 1) == 0) begin
            ctr <= 0;
            wb.data_rd <= ram[r_addr];
            wb.ack <= 1;
        end
    end
end

endmodule
