# PiFive

A RISC-V microcontroller core. Updated documentation and build instructions coming soon.

To run a build on ULX3S FPGA: Run `make ecppack` in directory `fpga/final-test-ulx3s/`. The bitstream will be generated in `fpga/final-test-ulx3s/build/`

To run a generic build: Run `make build/top.v` in directory `soc-final/`.

To run the RISC-V test suite: Run `make test` in directory `cpu/`.

# License

[Apache](LICENSE)
