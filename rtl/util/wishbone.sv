`default_nettype none

// Point-to-point connection for wishbone
// Non-pipelined interface, but must always wait for ack before making new request
interface Wishbone();
    localparam N = 32;

`ifdef VERIFICATION
    initial if (N % 8 != 0) $error("Invalid bus width");
`endif
    localparam NUM_BYTES = N / 8;

    // Controller -> Peripheral
    logic cyc;
    logic stb;
    logic we;
    logic [(NUM_BYTES-1):0] sel;
    logic [(N-1):0] addr;
    logic [(N-1):0] data_wr;

    // Peripheral -> Controller
    logic ack;
    logic err;
    logic [(N-1):0] data_rd;

    modport Controller (
        output cyc,
        output stb,
        output we,
        output sel,
        output addr,
        output data_wr,

        input ack,
        input err,
        input data_rd
    );

    modport Peripheral (
        input cyc,
        input stb,
        input we,
        input sel,
        input addr,
        input data_wr,

        output ack,
        output err,
        output data_rd
    );

endinterface : Wishbone
