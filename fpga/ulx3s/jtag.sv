module CaptureUpdateChain(
  input        clock,
  input        io_chainIn_shift,
  input        io_chainIn_data,
  input        io_chainIn_capture,
  input        io_chainIn_update,
  output       io_chainOut_data,
  input  [7:0] io_capture_bits,
  output       io_update_valid,
  output [7:0] io_update_bits
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
`endif // RANDOMIZE_REG_INIT
  reg  regs_0; // @[JtagShifter.scala 147:39]
  reg  regs_1; // @[JtagShifter.scala 147:39]
  reg  regs_2; // @[JtagShifter.scala 147:39]
  reg  regs_3; // @[JtagShifter.scala 147:39]
  reg  regs_4; // @[JtagShifter.scala 147:39]
  reg  regs_5; // @[JtagShifter.scala 147:39]
  reg  regs_6; // @[JtagShifter.scala 147:39]
  reg  regs_7; // @[JtagShifter.scala 147:39]
  wire [3:0] _T_2 = {regs_3,regs_2,regs_1,regs_0}; // @[Cat.scala 29:58]
  wire [3:0] _T_5 = {regs_7,regs_6,regs_5,regs_4}; // @[Cat.scala 29:58]
  assign io_chainOut_data = regs_0; // @[JtagShifter.scala 149:20]
  assign io_update_valid = io_chainIn_capture ? 1'h0 : io_chainIn_update; // @[JtagShifter.scala 164:21 JtagShifter.scala 167:21 JtagShifter.scala 172:21 JtagShifter.scala 175:21]
  assign io_update_bits = {_T_5,_T_2}; // @[JtagShifter.scala 153:20]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  regs_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  regs_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  regs_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  regs_3 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  regs_4 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  regs_5 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  regs_6 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  regs_7 = _RAND_7[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    if (io_chainIn_capture) begin
      regs_0 <= io_capture_bits[0];
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_0 <= regs_1;
      end
    end
    if (io_chainIn_capture) begin
      regs_1 <= io_capture_bits[1];
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_1 <= regs_2;
      end
    end
    if (io_chainIn_capture) begin
      regs_2 <= io_capture_bits[2];
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_2 <= regs_3;
      end
    end
    if (io_chainIn_capture) begin
      regs_3 <= io_capture_bits[3];
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_3 <= regs_4;
      end
    end
    if (io_chainIn_capture) begin
      regs_4 <= io_capture_bits[4];
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_4 <= regs_5;
      end
    end
    if (io_chainIn_capture) begin
      regs_5 <= io_capture_bits[5];
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_5 <= regs_6;
      end
    end
    if (io_chainIn_capture) begin
      regs_6 <= io_capture_bits[6];
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_6 <= regs_7;
      end
    end
    if (io_chainIn_capture) begin
      regs_7 <= io_capture_bits[7];
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_7 <= io_chainIn_data;
      end
    end
  end
endmodule
module CaptureUpdateChain_1(
  input        clock,
  input        io_chainIn_shift,
  input        io_chainIn_data,
  input        io_chainIn_capture,
  input        io_chainIn_update,
  output       io_chainOut_data,
  input  [2:0] io_capture_bits,
  output       io_update_valid,
  output [2:0] io_update_bits
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg  regs_0; // @[JtagShifter.scala 147:39]
  reg  regs_1; // @[JtagShifter.scala 147:39]
  reg  regs_2; // @[JtagShifter.scala 147:39]
  wire [1:0] _T = {regs_2,regs_1}; // @[Cat.scala 29:58]
  assign io_chainOut_data = regs_0; // @[JtagShifter.scala 149:20]
  assign io_update_valid = io_chainIn_capture ? 1'h0 : io_chainIn_update; // @[JtagShifter.scala 164:21 JtagShifter.scala 167:21 JtagShifter.scala 172:21 JtagShifter.scala 175:21]
  assign io_update_bits = {_T,regs_0}; // @[JtagShifter.scala 153:20]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  regs_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  regs_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  regs_2 = _RAND_2[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    if (io_chainIn_capture) begin
      regs_0 <= io_capture_bits[0];
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_0 <= regs_1;
      end
    end
    if (io_chainIn_capture) begin
      regs_1 <= io_capture_bits[1];
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_1 <= regs_2;
      end
    end
    if (io_chainIn_capture) begin
      regs_2 <= io_capture_bits[2];
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_2 <= io_chainIn_data;
      end
    end
  end
endmodule
module CaptureChain(
  input   clock,
  input   io_chainIn_shift,
  input   io_chainIn_data,
  input   io_chainIn_capture,
  output  io_chainOut_data
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
  reg [31:0] _RAND_24;
  reg [31:0] _RAND_25;
  reg [31:0] _RAND_26;
  reg [31:0] _RAND_27;
  reg [31:0] _RAND_28;
  reg [31:0] _RAND_29;
  reg [31:0] _RAND_30;
  reg [31:0] _RAND_31;
`endif // RANDOMIZE_REG_INIT
  reg  regs_0; // @[JtagShifter.scala 96:39]
  reg  regs_1; // @[JtagShifter.scala 96:39]
  reg  regs_2; // @[JtagShifter.scala 96:39]
  reg  regs_3; // @[JtagShifter.scala 96:39]
  reg  regs_4; // @[JtagShifter.scala 96:39]
  reg  regs_5; // @[JtagShifter.scala 96:39]
  reg  regs_6; // @[JtagShifter.scala 96:39]
  reg  regs_7; // @[JtagShifter.scala 96:39]
  reg  regs_8; // @[JtagShifter.scala 96:39]
  reg  regs_9; // @[JtagShifter.scala 96:39]
  reg  regs_10; // @[JtagShifter.scala 96:39]
  reg  regs_11; // @[JtagShifter.scala 96:39]
  reg  regs_12; // @[JtagShifter.scala 96:39]
  reg  regs_13; // @[JtagShifter.scala 96:39]
  reg  regs_14; // @[JtagShifter.scala 96:39]
  reg  regs_15; // @[JtagShifter.scala 96:39]
  reg  regs_16; // @[JtagShifter.scala 96:39]
  reg  regs_17; // @[JtagShifter.scala 96:39]
  reg  regs_18; // @[JtagShifter.scala 96:39]
  reg  regs_19; // @[JtagShifter.scala 96:39]
  reg  regs_20; // @[JtagShifter.scala 96:39]
  reg  regs_21; // @[JtagShifter.scala 96:39]
  reg  regs_22; // @[JtagShifter.scala 96:39]
  reg  regs_23; // @[JtagShifter.scala 96:39]
  reg  regs_24; // @[JtagShifter.scala 96:39]
  reg  regs_25; // @[JtagShifter.scala 96:39]
  reg  regs_26; // @[JtagShifter.scala 96:39]
  reg  regs_27; // @[JtagShifter.scala 96:39]
  reg  regs_28; // @[JtagShifter.scala 96:39]
  reg  regs_29; // @[JtagShifter.scala 96:39]
  reg  regs_30; // @[JtagShifter.scala 96:39]
  reg  regs_31; // @[JtagShifter.scala 96:39]
  wire  _GEN_0 = io_chainIn_shift ? io_chainIn_data : regs_31; // @[JtagShifter.scala 103:34]
  wire  _GEN_1 = io_chainIn_shift ? regs_1 : regs_0; // @[JtagShifter.scala 103:34]
  wire  _GEN_3 = io_chainIn_shift ? regs_3 : regs_2; // @[JtagShifter.scala 103:34]
  wire  _GEN_8 = io_chainIn_shift ? regs_8 : regs_7; // @[JtagShifter.scala 103:34]
  wire  _GEN_13 = io_chainIn_shift ? regs_13 : regs_12; // @[JtagShifter.scala 103:34]
  wire  _GEN_14 = io_chainIn_shift ? regs_14 : regs_13; // @[JtagShifter.scala 103:34]
  wire  _GEN_18 = io_chainIn_shift ? regs_18 : regs_17; // @[JtagShifter.scala 103:34]
  wire  _GEN_21 = io_chainIn_shift ? regs_21 : regs_20; // @[JtagShifter.scala 103:34]
  wire  _GEN_30 = io_chainIn_shift ? regs_30 : regs_29; // @[JtagShifter.scala 103:34]
  assign io_chainOut_data = regs_0; // @[JtagShifter.scala 98:20]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  regs_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  regs_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  regs_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  regs_3 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  regs_4 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  regs_5 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  regs_6 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  regs_7 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  regs_8 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  regs_9 = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  regs_10 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  regs_11 = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  regs_12 = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  regs_13 = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  regs_14 = _RAND_14[0:0];
  _RAND_15 = {1{`RANDOM}};
  regs_15 = _RAND_15[0:0];
  _RAND_16 = {1{`RANDOM}};
  regs_16 = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  regs_17 = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  regs_18 = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  regs_19 = _RAND_19[0:0];
  _RAND_20 = {1{`RANDOM}};
  regs_20 = _RAND_20[0:0];
  _RAND_21 = {1{`RANDOM}};
  regs_21 = _RAND_21[0:0];
  _RAND_22 = {1{`RANDOM}};
  regs_22 = _RAND_22[0:0];
  _RAND_23 = {1{`RANDOM}};
  regs_23 = _RAND_23[0:0];
  _RAND_24 = {1{`RANDOM}};
  regs_24 = _RAND_24[0:0];
  _RAND_25 = {1{`RANDOM}};
  regs_25 = _RAND_25[0:0];
  _RAND_26 = {1{`RANDOM}};
  regs_26 = _RAND_26[0:0];
  _RAND_27 = {1{`RANDOM}};
  regs_27 = _RAND_27[0:0];
  _RAND_28 = {1{`RANDOM}};
  regs_28 = _RAND_28[0:0];
  _RAND_29 = {1{`RANDOM}};
  regs_29 = _RAND_29[0:0];
  _RAND_30 = {1{`RANDOM}};
  regs_30 = _RAND_30[0:0];
  _RAND_31 = {1{`RANDOM}};
  regs_31 = _RAND_31[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    regs_0 <= io_chainIn_capture | _GEN_1;
    if (io_chainIn_capture) begin
      regs_1 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_1 <= regs_2;
    end
    regs_2 <= io_chainIn_capture | _GEN_3;
    if (io_chainIn_capture) begin
      regs_3 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_3 <= regs_4;
    end
    if (io_chainIn_capture) begin
      regs_4 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_4 <= regs_5;
    end
    if (io_chainIn_capture) begin
      regs_5 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_5 <= regs_6;
    end
    if (io_chainIn_capture) begin
      regs_6 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_6 <= regs_7;
    end
    regs_7 <= io_chainIn_capture | _GEN_8;
    if (io_chainIn_capture) begin
      regs_8 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_8 <= regs_9;
    end
    if (io_chainIn_capture) begin
      regs_9 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_9 <= regs_10;
    end
    if (io_chainIn_capture) begin
      regs_10 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_10 <= regs_11;
    end
    if (io_chainIn_capture) begin
      regs_11 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_11 <= regs_12;
    end
    regs_12 <= io_chainIn_capture | _GEN_13;
    regs_13 <= io_chainIn_capture | _GEN_14;
    if (io_chainIn_capture) begin
      regs_14 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_14 <= regs_15;
    end
    if (io_chainIn_capture) begin
      regs_15 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_15 <= regs_16;
    end
    if (io_chainIn_capture) begin
      regs_16 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_16 <= regs_17;
    end
    regs_17 <= io_chainIn_capture | _GEN_18;
    if (io_chainIn_capture) begin
      regs_18 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_18 <= regs_19;
    end
    if (io_chainIn_capture) begin
      regs_19 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_19 <= regs_20;
    end
    regs_20 <= io_chainIn_capture | _GEN_21;
    if (io_chainIn_capture) begin
      regs_21 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_21 <= regs_22;
    end
    if (io_chainIn_capture) begin
      regs_22 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_22 <= regs_23;
    end
    if (io_chainIn_capture) begin
      regs_23 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_23 <= regs_24;
    end
    if (io_chainIn_capture) begin
      regs_24 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_24 <= regs_25;
    end
    if (io_chainIn_capture) begin
      regs_25 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_25 <= regs_26;
    end
    if (io_chainIn_capture) begin
      regs_26 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_26 <= regs_27;
    end
    if (io_chainIn_capture) begin
      regs_27 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_27 <= regs_28;
    end
    if (io_chainIn_capture) begin
      regs_28 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_28 <= regs_29;
    end
    regs_29 <= io_chainIn_capture | _GEN_30;
    if (io_chainIn_capture) begin
      regs_30 <= 1'h0;
    end else if (io_chainIn_shift) begin
      regs_30 <= regs_31;
    end
    regs_31 <= io_chainIn_capture | _GEN_0;
  end
endmodule
module NegativeEdgeLatch(
  input   clock,
  input   io_next,
  output  io_output
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg  reg_; // @[Utils.scala 23:16]
  assign io_output = reg_; // @[Utils.scala 27:13]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  reg_ = _RAND_0[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    reg_ <= io_next;
  end
endmodule
module JtagStateMachine(
  input        clock,
  input        io_tms,
  output [3:0] io_currState
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg  tms; // @[JtagStateMachine.scala 79:20]
  reg [3:0] _T_1; // @[JtagStateMachine.scala 84:28]
  wire  _T_2 = 4'hf == _T_1; // @[Conditional.scala 37:30]
  wire [3:0] _T_3 = tms ? 4'hf : 4'hc; // @[JtagStateMachine.scala 88:25]
  wire  _T_4 = 4'hc == _T_1; // @[Conditional.scala 37:30]
  wire [3:0] _T_5 = tms ? 4'h7 : 4'hc; // @[JtagStateMachine.scala 91:25]
  wire  _T_6 = 4'h7 == _T_1; // @[Conditional.scala 37:30]
  wire [3:0] _T_7 = tms ? 4'h4 : 4'h6; // @[JtagStateMachine.scala 94:25]
  wire  _T_8 = 4'h6 == _T_1; // @[Conditional.scala 37:30]
  wire [3:0] _T_9 = tms ? 4'h1 : 4'h2; // @[JtagStateMachine.scala 97:25]
  wire  _T_10 = 4'h2 == _T_1; // @[Conditional.scala 37:30]
  wire  _T_12 = 4'h1 == _T_1; // @[Conditional.scala 37:30]
  wire [3:0] _T_13 = tms ? 4'h5 : 4'h3; // @[JtagStateMachine.scala 103:25]
  wire  _T_14 = 4'h3 == _T_1; // @[Conditional.scala 37:30]
  wire [3:0] _T_15 = tms ? 4'h0 : 4'h3; // @[JtagStateMachine.scala 106:25]
  wire  _T_16 = 4'h0 == _T_1; // @[Conditional.scala 37:30]
  wire [3:0] _T_17 = tms ? 4'h5 : 4'h2; // @[JtagStateMachine.scala 109:25]
  wire  _T_18 = 4'h5 == _T_1; // @[Conditional.scala 37:30]
  wire  _T_20 = 4'h4 == _T_1; // @[Conditional.scala 37:30]
  wire [3:0] _T_21 = tms ? 4'hf : 4'he; // @[JtagStateMachine.scala 115:25]
  wire  _T_22 = 4'he == _T_1; // @[Conditional.scala 37:30]
  wire [3:0] _T_23 = tms ? 4'h9 : 4'ha; // @[JtagStateMachine.scala 118:25]
  wire  _T_24 = 4'ha == _T_1; // @[Conditional.scala 37:30]
  wire  _T_26 = 4'h9 == _T_1; // @[Conditional.scala 37:30]
  wire [3:0] _T_27 = tms ? 4'hd : 4'hb; // @[JtagStateMachine.scala 124:25]
  wire  _T_28 = 4'hb == _T_1; // @[Conditional.scala 37:30]
  wire [3:0] _T_29 = tms ? 4'h8 : 4'hb; // @[JtagStateMachine.scala 127:25]
  wire  _T_30 = 4'h8 == _T_1; // @[Conditional.scala 37:30]
  wire [3:0] _T_31 = tms ? 4'hd : 4'ha; // @[JtagStateMachine.scala 130:25]
  wire [3:0] _GEN_1 = _T_30 ? _T_31 : _T_5; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_2 = _T_28 ? _T_29 : _GEN_1; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_3 = _T_26 ? _T_27 : _GEN_2; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_4 = _T_24 ? _T_23 : _GEN_3; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_5 = _T_22 ? _T_23 : _GEN_4; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_6 = _T_20 ? _T_21 : _GEN_5; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_7 = _T_18 ? _T_5 : _GEN_6; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_8 = _T_16 ? _T_17 : _GEN_7; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_9 = _T_14 ? _T_15 : _GEN_8; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_10 = _T_12 ? _T_13 : _GEN_9; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_11 = _T_10 ? _T_9 : _GEN_10; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_12 = _T_8 ? _T_9 : _GEN_11; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_13 = _T_6 ? _T_7 : _GEN_12; // @[Conditional.scala 39:67]
  wire [3:0] _GEN_14 = _T_4 ? _T_5 : _GEN_13; // @[Conditional.scala 39:67]
  assign io_currState = _T_2 ? _T_3 : _GEN_14; // @[JtagStateMachine.scala 137:18]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  tms = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  _T_1 = _RAND_1[3:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    tms <= io_tms;
    if (_T_2) begin
      if (tms) begin
        _T_1 <= 4'hf;
      end else begin
        _T_1 <= 4'hc;
      end
    end else if (_T_4) begin
      if (tms) begin
        _T_1 <= 4'h7;
      end else begin
        _T_1 <= 4'hc;
      end
    end else if (_T_6) begin
      if (tms) begin
        _T_1 <= 4'h4;
      end else begin
        _T_1 <= 4'h6;
      end
    end else if (_T_8) begin
      if (tms) begin
        _T_1 <= 4'h1;
      end else begin
        _T_1 <= 4'h2;
      end
    end else if (_T_10) begin
      if (tms) begin
        _T_1 <= 4'h1;
      end else begin
        _T_1 <= 4'h2;
      end
    end else if (_T_12) begin
      if (tms) begin
        _T_1 <= 4'h5;
      end else begin
        _T_1 <= 4'h3;
      end
    end else if (_T_14) begin
      if (tms) begin
        _T_1 <= 4'h0;
      end else begin
        _T_1 <= 4'h3;
      end
    end else if (_T_16) begin
      if (tms) begin
        _T_1 <= 4'h5;
      end else begin
        _T_1 <= 4'h2;
      end
    end else if (_T_18) begin
      if (tms) begin
        _T_1 <= 4'h7;
      end else begin
        _T_1 <= 4'hc;
      end
    end else if (_T_20) begin
      if (tms) begin
        _T_1 <= 4'hf;
      end else begin
        _T_1 <= 4'he;
      end
    end else if (_T_22) begin
      if (tms) begin
        _T_1 <= 4'h9;
      end else begin
        _T_1 <= 4'ha;
      end
    end else if (_T_24) begin
      if (tms) begin
        _T_1 <= 4'h9;
      end else begin
        _T_1 <= 4'ha;
      end
    end else if (_T_26) begin
      if (tms) begin
        _T_1 <= 4'hd;
      end else begin
        _T_1 <= 4'hb;
      end
    end else if (_T_28) begin
      if (tms) begin
        _T_1 <= 4'h8;
      end else begin
        _T_1 <= 4'hb;
      end
    end else if (_T_30) begin
      if (tms) begin
        _T_1 <= 4'hd;
      end else begin
        _T_1 <= 4'ha;
      end
    end else if (tms) begin
      _T_1 <= 4'h7;
    end else begin
      _T_1 <= 4'hc;
    end
  end
endmodule
module CaptureUpdateChain_3(
  input        clock,
  input        io_chainIn_shift,
  input        io_chainIn_data,
  input        io_chainIn_capture,
  input        io_chainIn_update,
  output       io_chainOut_data,
  output [3:0] io_update_bits
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg  regs_0; // @[JtagShifter.scala 147:39]
  reg  regs_1; // @[JtagShifter.scala 147:39]
  reg  regs_2; // @[JtagShifter.scala 147:39]
  reg  regs_3; // @[JtagShifter.scala 147:39]
  wire [1:0] _T = {regs_1,regs_0}; // @[Cat.scala 29:58]
  wire [1:0] _T_1 = {regs_3,regs_2}; // @[Cat.scala 29:58]
  wire  _GEN_1 = io_chainIn_shift ? regs_1 : regs_0; // @[JtagShifter.scala 168:34]
  wire  _GEN_8 = io_chainIn_update ? regs_0 : _GEN_1; // @[JtagShifter.scala 165:35]
  assign io_chainOut_data = regs_0; // @[JtagShifter.scala 149:20]
  assign io_update_bits = {_T_1,_T}; // @[JtagShifter.scala 153:20]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  regs_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  regs_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  regs_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  regs_3 = _RAND_3[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    regs_0 <= io_chainIn_capture | _GEN_8;
    if (io_chainIn_capture) begin
      regs_1 <= 1'h0;
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_1 <= regs_2;
      end
    end
    if (io_chainIn_capture) begin
      regs_2 <= 1'h0;
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_2 <= regs_3;
      end
    end
    if (io_chainIn_capture) begin
      regs_3 <= 1'h0;
    end else if (!(io_chainIn_update)) begin
      if (io_chainIn_shift) begin
        regs_3 <= io_chainIn_data;
      end
    end
  end
endmodule
module NegativeEdgeLatch_2(
  input        clock,
  input  [3:0] io_next,
  input        io_enable,
  output [3:0] io_output
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] reg_; // @[Utils.scala 23:16]
  assign io_output = reg_; // @[Utils.scala 27:13]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  reg_ = _RAND_0[3:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    if (io_enable) begin
      reg_ <= io_next;
    end
  end
endmodule
module JtagTapController(
  input        clock,
  input        reset,
  input        io_jtag_TMS,
  input        io_jtag_TDI,
  output       io_jtag_TDO_data,
  output       io_jtag_TDO_driven,
  output [3:0] io_output_instruction,
  output       io_output_reset,
  output       io_dataChainOut_shift,
  output       io_dataChainOut_data,
  output       io_dataChainOut_capture,
  output       io_dataChainOut_update,
  input        io_dataChainIn_data
);
  wire  NegativeEdgeLatch_clock; // @[Utils.scala 37:13]
  wire  NegativeEdgeLatch_io_next; // @[Utils.scala 37:13]
  wire  NegativeEdgeLatch_io_output; // @[Utils.scala 37:13]
  wire  NegativeEdgeLatch_1_clock; // @[Utils.scala 37:13]
  wire  NegativeEdgeLatch_1_io_next; // @[Utils.scala 37:13]
  wire  NegativeEdgeLatch_1_io_output; // @[Utils.scala 37:13]
  wire  stateMachine_clock; // @[JtagTap.scala 68:28]
  wire  stateMachine_io_tms; // @[JtagTap.scala 68:28]
  wire [3:0] stateMachine_io_currState; // @[JtagTap.scala 68:28]
  wire  irShifter_clock; // @[JtagTap.scala 80:25]
  wire  irShifter_io_chainIn_shift; // @[JtagTap.scala 80:25]
  wire  irShifter_io_chainIn_data; // @[JtagTap.scala 80:25]
  wire  irShifter_io_chainIn_capture; // @[JtagTap.scala 80:25]
  wire  irShifter_io_chainIn_update; // @[JtagTap.scala 80:25]
  wire  irShifter_io_chainOut_data; // @[JtagTap.scala 80:25]
  wire [3:0] irShifter_io_update_bits; // @[JtagTap.scala 80:25]
  wire  NegativeEdgeLatch_2_clock; // @[Utils.scala 37:13]
  wire [3:0] NegativeEdgeLatch_2_io_next; // @[Utils.scala 37:13]
  wire  NegativeEdgeLatch_2_io_enable; // @[Utils.scala 37:13]
  wire [3:0] NegativeEdgeLatch_2_io_output; // @[Utils.scala 37:13]
  wire  _T_6 = stateMachine_io_currState == 4'ha; // @[JtagTap.scala 81:43]
  wire  _T_8 = stateMachine_io_currState == 4'hd; // @[JtagTap.scala 84:44]
  wire [3:0] _GEN_0 = irShifter_io_update_bits; // @[JtagTap.scala 98:52]
  wire  _T_15 = stateMachine_io_currState == 4'h2; // @[JtagTap.scala 111:38]
  wire  _GEN_4 = irShifter_io_chainOut_data; // @[JtagTap.scala 122:51]
  NegativeEdgeLatch NegativeEdgeLatch ( // @[Utils.scala 37:13]
    .clock(NegativeEdgeLatch_clock),
    .io_next(NegativeEdgeLatch_io_next),
    .io_output(NegativeEdgeLatch_io_output)
  );
  NegativeEdgeLatch NegativeEdgeLatch_1 ( // @[Utils.scala 37:13]
    .clock(NegativeEdgeLatch_1_clock),
    .io_next(NegativeEdgeLatch_1_io_next),
    .io_output(NegativeEdgeLatch_1_io_output)
  );
  JtagStateMachine stateMachine ( // @[JtagTap.scala 68:28]
    .clock(stateMachine_clock),
    .io_tms(stateMachine_io_tms),
    .io_currState(stateMachine_io_currState)
  );
  CaptureUpdateChain_3 irShifter ( // @[JtagTap.scala 80:25]
    .clock(irShifter_clock),
    .io_chainIn_shift(irShifter_io_chainIn_shift),
    .io_chainIn_data(irShifter_io_chainIn_data),
    .io_chainIn_capture(irShifter_io_chainIn_capture),
    .io_chainIn_update(irShifter_io_chainIn_update),
    .io_chainOut_data(irShifter_io_chainOut_data),
    .io_update_bits(irShifter_io_update_bits)
  );
  NegativeEdgeLatch_2 NegativeEdgeLatch_2 ( // @[Utils.scala 37:13]
    .clock(NegativeEdgeLatch_2_clock),
    .io_next(NegativeEdgeLatch_2_io_next),
    .io_enable(NegativeEdgeLatch_2_io_enable),
    .io_output(NegativeEdgeLatch_2_io_output)
  );
  assign io_jtag_TDO_data = NegativeEdgeLatch_io_output; // @[JtagTap.scala 61:20]
  assign io_jtag_TDO_driven = NegativeEdgeLatch_1_io_output; // @[JtagTap.scala 62:22]
  assign io_output_instruction = NegativeEdgeLatch_2_io_output; // @[JtagTap.scala 104:25]
  assign io_output_reset = stateMachine_io_currState == 4'hf; // @[JtagTap.scala 106:19]
  assign io_dataChainOut_shift = stateMachine_io_currState == 4'h2; // @[JtagTap.scala 111:25]
  assign io_dataChainOut_data = io_jtag_TDI; // @[JtagTap.scala 112:24]
  assign io_dataChainOut_capture = stateMachine_io_currState == 4'h6; // @[JtagTap.scala 113:27]
  assign io_dataChainOut_update = stateMachine_io_currState == 4'h5; // @[JtagTap.scala 114:26]
  assign NegativeEdgeLatch_clock = ~clock;
  assign NegativeEdgeLatch_io_next = _T_15 ? io_dataChainIn_data : _GEN_4; // @[Utils.scala 39:26]
  assign NegativeEdgeLatch_1_clock = ~clock;
  assign NegativeEdgeLatch_1_io_next = _T_15 | _T_6; // @[Utils.scala 39:26]
  assign stateMachine_clock = clock;
  assign stateMachine_io_tms = io_jtag_TMS; // @[JtagTap.scala 69:23]
  assign irShifter_clock = clock;
  assign irShifter_io_chainIn_shift = stateMachine_io_currState == 4'ha; // @[JtagTap.scala 81:30]
  assign irShifter_io_chainIn_data = io_jtag_TDI; // @[JtagTap.scala 82:29]
  assign irShifter_io_chainIn_capture = stateMachine_io_currState == 4'he; // @[JtagTap.scala 83:32]
  assign irShifter_io_chainIn_update = stateMachine_io_currState == 4'hd; // @[JtagTap.scala 84:31]
  assign NegativeEdgeLatch_2_clock = ~clock;
  assign NegativeEdgeLatch_2_io_next = reset ? 4'he : _GEN_0; // @[Utils.scala 39:26]
  assign NegativeEdgeLatch_2_io_enable = reset | _T_8; // @[Utils.scala 40:28]
endmodule
module JtagBypassChain(
  input   clock,
  input   io_chainIn_shift,
  input   io_chainIn_data,
  input   io_chainIn_capture,
  output  io_chainOut_data
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg  reg_; // @[JtagShifter.scala 58:16]
  assign io_chainOut_data = reg_; // @[JtagShifter.scala 60:20]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  reg_ = _RAND_0[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    if (io_chainIn_capture) begin
      reg_ <= 1'h0;
    end else if (io_chainIn_shift) begin
      reg_ <= io_chainIn_data;
    end
  end
endmodule
module JtagTapClocked(
  input        io_jtag_TCK,
  input        io_jtag_TMS,
  input        io_jtag_TDI,
  output       io_jtag_TDO_data,
  output       io_jtag_TDO_driven,
  output       io_output_reset,
  output [7:0] io_reg0,
  output [2:0] io_reg1,
  output [2:0] io_reg2,
  input        io_reset
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  wire  CaptureUpdateChain_clock; // @[JtagTest.scala 33:32]
  wire  CaptureUpdateChain_io_chainIn_shift; // @[JtagTest.scala 33:32]
  wire  CaptureUpdateChain_io_chainIn_data; // @[JtagTest.scala 33:32]
  wire  CaptureUpdateChain_io_chainIn_capture; // @[JtagTest.scala 33:32]
  wire  CaptureUpdateChain_io_chainIn_update; // @[JtagTest.scala 33:32]
  wire  CaptureUpdateChain_io_chainOut_data; // @[JtagTest.scala 33:32]
  wire [7:0] CaptureUpdateChain_io_capture_bits; // @[JtagTest.scala 33:32]
  wire  CaptureUpdateChain_io_update_valid; // @[JtagTest.scala 33:32]
  wire [7:0] CaptureUpdateChain_io_update_bits; // @[JtagTest.scala 33:32]
  wire  CaptureUpdateChain_1_clock; // @[JtagTest.scala 37:32]
  wire  CaptureUpdateChain_1_io_chainIn_shift; // @[JtagTest.scala 37:32]
  wire  CaptureUpdateChain_1_io_chainIn_data; // @[JtagTest.scala 37:32]
  wire  CaptureUpdateChain_1_io_chainIn_capture; // @[JtagTest.scala 37:32]
  wire  CaptureUpdateChain_1_io_chainIn_update; // @[JtagTest.scala 37:32]
  wire  CaptureUpdateChain_1_io_chainOut_data; // @[JtagTest.scala 37:32]
  wire [2:0] CaptureUpdateChain_1_io_capture_bits; // @[JtagTest.scala 37:32]
  wire  CaptureUpdateChain_1_io_update_valid; // @[JtagTest.scala 37:32]
  wire [2:0] CaptureUpdateChain_1_io_update_bits; // @[JtagTest.scala 37:32]
  wire  CaptureUpdateChain_2_clock; // @[JtagTest.scala 41:32]
  wire  CaptureUpdateChain_2_io_chainIn_shift; // @[JtagTest.scala 41:32]
  wire  CaptureUpdateChain_2_io_chainIn_data; // @[JtagTest.scala 41:32]
  wire  CaptureUpdateChain_2_io_chainIn_capture; // @[JtagTest.scala 41:32]
  wire  CaptureUpdateChain_2_io_chainIn_update; // @[JtagTest.scala 41:32]
  wire  CaptureUpdateChain_2_io_chainOut_data; // @[JtagTest.scala 41:32]
  wire [2:0] CaptureUpdateChain_2_io_capture_bits; // @[JtagTest.scala 41:32]
  wire  CaptureUpdateChain_2_io_update_valid; // @[JtagTest.scala 41:32]
  wire [2:0] CaptureUpdateChain_2_io_update_bits; // @[JtagTest.scala 41:32]
  wire  CaptureChain_clock; // @[JtagTap.scala 159:34]
  wire  CaptureChain_io_chainIn_shift; // @[JtagTap.scala 159:34]
  wire  CaptureChain_io_chainIn_data; // @[JtagTap.scala 159:34]
  wire  CaptureChain_io_chainIn_capture; // @[JtagTap.scala 159:34]
  wire  CaptureChain_io_chainOut_data; // @[JtagTap.scala 159:34]
  wire  JtagTapController_clock; // @[JtagTap.scala 177:36]
  wire  JtagTapController_reset; // @[JtagTap.scala 177:36]
  wire  JtagTapController_io_jtag_TMS; // @[JtagTap.scala 177:36]
  wire  JtagTapController_io_jtag_TDI; // @[JtagTap.scala 177:36]
  wire  JtagTapController_io_jtag_TDO_data; // @[JtagTap.scala 177:36]
  wire  JtagTapController_io_jtag_TDO_driven; // @[JtagTap.scala 177:36]
  wire [3:0] JtagTapController_io_output_instruction; // @[JtagTap.scala 177:36]
  wire  JtagTapController_io_output_reset; // @[JtagTap.scala 177:36]
  wire  JtagTapController_io_dataChainOut_shift; // @[JtagTap.scala 177:36]
  wire  JtagTapController_io_dataChainOut_data; // @[JtagTap.scala 177:36]
  wire  JtagTapController_io_dataChainOut_capture; // @[JtagTap.scala 177:36]
  wire  JtagTapController_io_dataChainOut_update; // @[JtagTap.scala 177:36]
  wire  JtagTapController_io_dataChainIn_data; // @[JtagTap.scala 177:36]
  wire  JtagBypassChain_clock; // @[JtagTap.scala 185:29]
  wire  JtagBypassChain_io_chainIn_shift; // @[JtagTap.scala 185:29]
  wire  JtagBypassChain_io_chainIn_data; // @[JtagTap.scala 185:29]
  wire  JtagBypassChain_io_chainIn_capture; // @[JtagTap.scala 185:29]
  wire  JtagBypassChain_io_chainOut_data; // @[JtagTap.scala 185:29]
  reg [7:0] _T_1; // @[Reg.scala 27:20]
  reg [2:0] _T_2; // @[Reg.scala 27:20]
  reg [2:0] _T_3; // @[Reg.scala 27:20]
  wire  _T_5 = JtagTapController_io_output_instruction == 4'h0; // @[JtagTap.scala 198:82]
  wire  _T_6 = JtagTapController_io_output_instruction == 4'h1; // @[JtagTap.scala 198:82]
  wire  _T_7 = _T_5 | _T_6; // @[JtagTap.scala 199:43]
  wire  _T_8 = JtagTapController_io_output_instruction == 4'h2; // @[JtagTap.scala 198:82]
  wire  _T_9 = JtagTapController_io_output_instruction == 4'he; // @[JtagTap.scala 198:82]
  wire  _T_10 = JtagTapController_io_output_instruction == 4'h3; // @[JtagTap.scala 198:82]
  wire  _GEN_5 = _T_10 ? CaptureUpdateChain_2_io_chainOut_data : JtagBypassChain_io_chainOut_data; // @[JtagTap.scala 206:28]
  wire  _GEN_9 = _T_9 ? CaptureChain_io_chainOut_data : _GEN_5; // @[JtagTap.scala 206:28]
  wire  _GEN_13 = _T_8 ? CaptureUpdateChain_1_io_chainOut_data : _GEN_9; // @[JtagTap.scala 206:28]
  CaptureUpdateChain CaptureUpdateChain ( // @[JtagTest.scala 33:32]
    .clock(CaptureUpdateChain_clock),
    .io_chainIn_shift(CaptureUpdateChain_io_chainIn_shift),
    .io_chainIn_data(CaptureUpdateChain_io_chainIn_data),
    .io_chainIn_capture(CaptureUpdateChain_io_chainIn_capture),
    .io_chainIn_update(CaptureUpdateChain_io_chainIn_update),
    .io_chainOut_data(CaptureUpdateChain_io_chainOut_data),
    .io_capture_bits(CaptureUpdateChain_io_capture_bits),
    .io_update_valid(CaptureUpdateChain_io_update_valid),
    .io_update_bits(CaptureUpdateChain_io_update_bits)
  );
  CaptureUpdateChain_1 CaptureUpdateChain_1 ( // @[JtagTest.scala 37:32]
    .clock(CaptureUpdateChain_1_clock),
    .io_chainIn_shift(CaptureUpdateChain_1_io_chainIn_shift),
    .io_chainIn_data(CaptureUpdateChain_1_io_chainIn_data),
    .io_chainIn_capture(CaptureUpdateChain_1_io_chainIn_capture),
    .io_chainIn_update(CaptureUpdateChain_1_io_chainIn_update),
    .io_chainOut_data(CaptureUpdateChain_1_io_chainOut_data),
    .io_capture_bits(CaptureUpdateChain_1_io_capture_bits),
    .io_update_valid(CaptureUpdateChain_1_io_update_valid),
    .io_update_bits(CaptureUpdateChain_1_io_update_bits)
  );
  CaptureUpdateChain_1 CaptureUpdateChain_2 ( // @[JtagTest.scala 41:32]
    .clock(CaptureUpdateChain_2_clock),
    .io_chainIn_shift(CaptureUpdateChain_2_io_chainIn_shift),
    .io_chainIn_data(CaptureUpdateChain_2_io_chainIn_data),
    .io_chainIn_capture(CaptureUpdateChain_2_io_chainIn_capture),
    .io_chainIn_update(CaptureUpdateChain_2_io_chainIn_update),
    .io_chainOut_data(CaptureUpdateChain_2_io_chainOut_data),
    .io_capture_bits(CaptureUpdateChain_2_io_capture_bits),
    .io_update_valid(CaptureUpdateChain_2_io_update_valid),
    .io_update_bits(CaptureUpdateChain_2_io_update_bits)
  );
  CaptureChain CaptureChain ( // @[JtagTap.scala 159:34]
    .clock(CaptureChain_clock),
    .io_chainIn_shift(CaptureChain_io_chainIn_shift),
    .io_chainIn_data(CaptureChain_io_chainIn_data),
    .io_chainIn_capture(CaptureChain_io_chainIn_capture),
    .io_chainOut_data(CaptureChain_io_chainOut_data)
  );
  JtagTapController JtagTapController ( // @[JtagTap.scala 177:36]
    .clock(JtagTapController_clock),
    .reset(JtagTapController_reset),
    .io_jtag_TMS(JtagTapController_io_jtag_TMS),
    .io_jtag_TDI(JtagTapController_io_jtag_TDI),
    .io_jtag_TDO_data(JtagTapController_io_jtag_TDO_data),
    .io_jtag_TDO_driven(JtagTapController_io_jtag_TDO_driven),
    .io_output_instruction(JtagTapController_io_output_instruction),
    .io_output_reset(JtagTapController_io_output_reset),
    .io_dataChainOut_shift(JtagTapController_io_dataChainOut_shift),
    .io_dataChainOut_data(JtagTapController_io_dataChainOut_data),
    .io_dataChainOut_capture(JtagTapController_io_dataChainOut_capture),
    .io_dataChainOut_update(JtagTapController_io_dataChainOut_update),
    .io_dataChainIn_data(JtagTapController_io_dataChainIn_data)
  );
  JtagBypassChain JtagBypassChain ( // @[JtagTap.scala 185:29]
    .clock(JtagBypassChain_clock),
    .io_chainIn_shift(JtagBypassChain_io_chainIn_shift),
    .io_chainIn_data(JtagBypassChain_io_chainIn_data),
    .io_chainIn_capture(JtagBypassChain_io_chainIn_capture),
    .io_chainOut_data(JtagBypassChain_io_chainOut_data)
  );
  assign io_jtag_TDO_data = JtagTapController_io_jtag_TDO_data; // @[JtagTest.scala 54:21]
  assign io_jtag_TDO_driven = JtagTapController_io_jtag_TDO_driven; // @[JtagTest.scala 54:21]
  assign io_output_reset = JtagTapController_io_output_reset; // @[JtagTest.scala 55:23]
  assign io_reg0 = _T_1; // @[JtagTest.scala 57:21]
  assign io_reg1 = _T_2; // @[JtagTest.scala 58:21]
  assign io_reg2 = _T_3; // @[JtagTest.scala 59:21]
  assign CaptureUpdateChain_clock = io_jtag_TCK;
  assign CaptureUpdateChain_io_chainIn_shift = _T_7 & JtagTapController_io_dataChainOut_shift; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureUpdateChain_io_chainIn_data = _T_7 & JtagTapController_io_dataChainOut_data; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureUpdateChain_io_chainIn_capture = _T_7 & JtagTapController_io_dataChainOut_capture; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureUpdateChain_io_chainIn_update = _T_7 & JtagTapController_io_dataChainOut_update; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureUpdateChain_io_capture_bits = _T_1; // @[JtagTest.scala 35:36]
  assign CaptureUpdateChain_1_clock = io_jtag_TCK;
  assign CaptureUpdateChain_1_io_chainIn_shift = _T_8 & JtagTapController_io_dataChainOut_shift; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureUpdateChain_1_io_chainIn_data = _T_8 & JtagTapController_io_dataChainOut_data; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureUpdateChain_1_io_chainIn_capture = _T_8 & JtagTapController_io_dataChainOut_capture; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureUpdateChain_1_io_chainIn_update = _T_8 & JtagTapController_io_dataChainOut_update; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureUpdateChain_1_io_capture_bits = _T_2; // @[JtagTest.scala 39:36]
  assign CaptureUpdateChain_2_clock = io_jtag_TCK;
  assign CaptureUpdateChain_2_io_chainIn_shift = _T_10 & JtagTapController_io_dataChainOut_shift; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureUpdateChain_2_io_chainIn_data = _T_10 & JtagTapController_io_dataChainOut_data; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureUpdateChain_2_io_chainIn_capture = _T_10 & JtagTapController_io_dataChainOut_capture; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureUpdateChain_2_io_chainIn_update = _T_10 & JtagTapController_io_dataChainOut_update; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureUpdateChain_2_io_capture_bits = _T_3; // @[JtagTest.scala 43:36]
  assign CaptureChain_clock = io_jtag_TCK;
  assign CaptureChain_io_chainIn_shift = _T_9 & JtagTapController_io_dataChainOut_shift; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureChain_io_chainIn_data = _T_9 & JtagTapController_io_dataChainOut_data; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign CaptureChain_io_chainIn_capture = _T_9 & JtagTapController_io_dataChainOut_capture; // @[JtagTap.scala 220:26 JtagTap.scala 222:26]
  assign JtagTapController_clock = io_jtag_TCK;
  assign JtagTapController_reset = io_reset;
  assign JtagTapController_io_jtag_TMS = io_jtag_TMS; // @[JtagTap.scala 231:32]
  assign JtagTapController_io_jtag_TDI = io_jtag_TDI; // @[JtagTap.scala 231:32]
  assign JtagTapController_io_dataChainIn_data = _T_7 ? CaptureUpdateChain_io_chainOut_data : _GEN_13; // @[JtagTap.scala 207:43 JtagTap.scala 207:43 JtagTap.scala 207:43 JtagTap.scala 207:43 JtagTap.scala 214:41]
  assign JtagBypassChain_clock = io_jtag_TCK;
  assign JtagBypassChain_io_chainIn_shift = JtagTapController_io_dataChainOut_shift; // @[JtagTap.scala 188:28]
  assign JtagBypassChain_io_chainIn_data = JtagTapController_io_dataChainOut_data; // @[JtagTap.scala 188:28]
  assign JtagBypassChain_io_chainIn_capture = JtagTapController_io_dataChainOut_capture; // @[JtagTap.scala 188:28]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  _T_1 = _RAND_0[7:0];
  _RAND_1 = {1{`RANDOM}};
  _T_2 = _RAND_1[2:0];
  _RAND_2 = {1{`RANDOM}};
  _T_3 = _RAND_2[2:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge io_jtag_TCK) begin
    if (io_reset) begin
      _T_1 <= 8'h0;
    end else if (CaptureUpdateChain_io_update_valid) begin
      _T_1 <= CaptureUpdateChain_io_update_bits;
    end
    if (io_reset) begin
      _T_2 <= 3'h1;
    end else if (CaptureUpdateChain_1_io_update_valid) begin
      _T_2 <= CaptureUpdateChain_1_io_update_bits;
    end
    if (io_reset) begin
      _T_3 <= 3'h0;
    end else if (CaptureUpdateChain_2_io_update_valid) begin
      _T_3 <= CaptureUpdateChain_2_io_update_bits;
    end
  end
endmodule
module JtagTest(
  input        io_jtag_TCK,
  input        io_jtag_TMS,
  input        io_jtag_TDI,
  output       io_jtag_TDO_data,
  output       io_jtag_TDO_driven,
  output [7:0] io_out0,
  output [2:0] io_out1,
  output [2:0] io_out2
);
  wire  tap_io_jtag_TCK; // @[JtagTest.scala 64:21]
  wire  tap_io_jtag_TMS; // @[JtagTest.scala 64:21]
  wire  tap_io_jtag_TDI; // @[JtagTest.scala 64:21]
  wire  tap_io_jtag_TDO_data; // @[JtagTest.scala 64:21]
  wire  tap_io_jtag_TDO_driven; // @[JtagTest.scala 64:21]
  wire  tap_io_output_reset; // @[JtagTest.scala 64:21]
  wire [7:0] tap_io_reg0; // @[JtagTest.scala 64:21]
  wire [2:0] tap_io_reg1; // @[JtagTest.scala 64:21]
  wire [2:0] tap_io_reg2; // @[JtagTest.scala 64:21]
  wire  tap_io_reset; // @[JtagTest.scala 64:21]
  JtagTapClocked tap ( // @[JtagTest.scala 64:21]
    .io_jtag_TCK(tap_io_jtag_TCK),
    .io_jtag_TMS(tap_io_jtag_TMS),
    .io_jtag_TDI(tap_io_jtag_TDI),
    .io_jtag_TDO_data(tap_io_jtag_TDO_data),
    .io_jtag_TDO_driven(tap_io_jtag_TDO_driven),
    .io_output_reset(tap_io_output_reset),
    .io_reg0(tap_io_reg0),
    .io_reg1(tap_io_reg1),
    .io_reg2(tap_io_reg2),
    .io_reset(tap_io_reset)
  );
  assign io_jtag_TDO_data = tap_io_jtag_TDO_data; // @[JtagTest.scala 69:17]
  assign io_jtag_TDO_driven = tap_io_jtag_TDO_driven; // @[JtagTest.scala 69:17]
  assign io_out0 = tap_io_reg0; // @[JtagTest.scala 75:13]
  assign io_out1 = tap_io_reg1; // @[JtagTest.scala 76:13]
  assign io_out2 = tap_io_reg2; // @[JtagTest.scala 77:13]
  assign tap_io_jtag_TCK = io_jtag_TCK; // @[JtagTest.scala 66:21]
  assign tap_io_jtag_TMS = io_jtag_TMS; // @[JtagTest.scala 67:21]
  assign tap_io_jtag_TDI = io_jtag_TDI; // @[JtagTest.scala 68:21]
  assign tap_io_reset = tap_io_output_reset; // @[JtagTest.scala 65:18]
endmodule

