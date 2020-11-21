module ICache(
  input         clock,
  input         reset,
  input         io_flush_all,
  input         io_bus_cyc,
  input         io_bus_stb,
  input         io_bus_we,
  input  [31:0] io_bus_addr,
  output        io_bus_ack,
  output [31:0] io_bus_data_rd,
  output [31:0] io_cache_mem_addr,
  input  [31:0] io_cache_mem_rd_d,
  output        io_cache_mem_we,
  output [31:0] io_cache_mem_wr_d,
  output        io_main_mem_rd_req,
  output [31:0] io_main_mem_addr,
  input  [31:0] io_main_mem_rd_d,
  input         io_main_mem_rd_rdy,
  input         io_main_mem_busy
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
`endif // RANDOMIZE_REG_INIT
  reg  valids_0; // @[ICache.scala 32:25]
  reg  valids_1; // @[ICache.scala 32:25]
  reg  valids_2; // @[ICache.scala 32:25]
  reg  valids_3; // @[ICache.scala 32:25]
  reg  valids_4; // @[ICache.scala 32:25]
  reg  valids_5; // @[ICache.scala 32:25]
  reg  valids_6; // @[ICache.scala 32:25]
  reg  valids_7; // @[ICache.scala 32:25]
  reg [23:0] tags_0; // @[ICache.scala 33:23]
  reg [23:0] tags_1; // @[ICache.scala 33:23]
  reg [23:0] tags_2; // @[ICache.scala 33:23]
  reg [23:0] tags_3; // @[ICache.scala 33:23]
  reg [23:0] tags_4; // @[ICache.scala 33:23]
  reg [23:0] tags_5; // @[ICache.scala 33:23]
  reg [23:0] tags_6; // @[ICache.scala 33:23]
  reg [23:0] tags_7; // @[ICache.scala 33:23]
  wire  _GEN_0 = io_flush_all ? 1'h0 : valids_0; // @[ICache.scala 37:25]
  wire  _GEN_1 = io_flush_all ? 1'h0 : valids_1; // @[ICache.scala 37:25]
  wire  _GEN_2 = io_flush_all ? 1'h0 : valids_2; // @[ICache.scala 37:25]
  wire  _GEN_3 = io_flush_all ? 1'h0 : valids_3; // @[ICache.scala 37:25]
  wire  _GEN_4 = io_flush_all ? 1'h0 : valids_4; // @[ICache.scala 37:25]
  wire  _GEN_5 = io_flush_all ? 1'h0 : valids_5; // @[ICache.scala 37:25]
  wire  _GEN_6 = io_flush_all ? 1'h0 : valids_6; // @[ICache.scala 37:25]
  wire  _GEN_7 = io_flush_all ? 1'h0 : valids_7; // @[ICache.scala 37:25]
  reg [1:0] state; // @[ICache.scala 38:24]
  wire  _T_10 = state == 2'h0; // @[ICache.scala 76:17]
  wire  _T_11 = _T_10 & io_bus_stb; // @[ICache.scala 76:32]
  wire  _T_12 = _T_11 & io_bus_cyc; // @[ICache.scala 76:46]
  wire  _T_13 = ~io_bus_ack; // @[ICache.scala 76:63]
  wire  _T_14 = _T_12 & _T_13; // @[ICache.scala 76:60]
  wire  _T_17 = ~io_flush_all; // @[ICache.scala 86:27]
  wire [2:0] addr_set_index = io_bus_addr[7:5]; // @[ICache.scala 71:37]
  wire  _GEN_9 = 3'h1 == addr_set_index ? valids_1 : valids_0; // @[ICache.scala 86:42]
  wire  _GEN_10 = 3'h2 == addr_set_index ? valids_2 : _GEN_9; // @[ICache.scala 86:42]
  wire  _GEN_11 = 3'h3 == addr_set_index ? valids_3 : _GEN_10; // @[ICache.scala 86:42]
  wire  _GEN_12 = 3'h4 == addr_set_index ? valids_4 : _GEN_11; // @[ICache.scala 86:42]
  wire  _GEN_13 = 3'h5 == addr_set_index ? valids_5 : _GEN_12; // @[ICache.scala 86:42]
  wire  _GEN_14 = 3'h6 == addr_set_index ? valids_6 : _GEN_13; // @[ICache.scala 86:42]
  wire  _GEN_15 = 3'h7 == addr_set_index ? valids_7 : _GEN_14; // @[ICache.scala 86:42]
  wire  _T_18 = _T_17 & _GEN_15; // @[ICache.scala 86:42]
  wire [23:0] _GEN_17 = 3'h1 == addr_set_index ? tags_1 : tags_0; // @[ICache.scala 86:93]
  wire [23:0] _GEN_18 = 3'h2 == addr_set_index ? tags_2 : _GEN_17; // @[ICache.scala 86:93]
  wire [23:0] _GEN_19 = 3'h3 == addr_set_index ? tags_3 : _GEN_18; // @[ICache.scala 86:93]
  wire [23:0] _GEN_20 = 3'h4 == addr_set_index ? tags_4 : _GEN_19; // @[ICache.scala 86:93]
  wire [23:0] _GEN_21 = 3'h5 == addr_set_index ? tags_5 : _GEN_20; // @[ICache.scala 86:93]
  wire [23:0] _GEN_22 = 3'h6 == addr_set_index ? tags_6 : _GEN_21; // @[ICache.scala 86:93]
  wire [23:0] _GEN_23 = 3'h7 == addr_set_index ? tags_7 : _GEN_22; // @[ICache.scala 86:93]
  wire [23:0] addr_tag_bits = io_bus_addr[31:8]; // @[ICache.scala 70:36]
  wire  _T_19 = _GEN_23 == addr_tag_bits; // @[ICache.scala 86:93]
  wire  _T_20 = _T_18 & _T_19; // @[ICache.scala 86:68]
  wire  _T_23 = state == 2'h1; // @[ICache.scala 106:24]
  wire  _T_24 = ~io_main_mem_busy; // @[ICache.scala 107:15]
  wire  _T_27 = state == 2'h2; // @[ICache.scala 114:25]
  wire  _T_28 = _T_27 & io_main_mem_rd_rdy; // @[ICache.scala 114:46]
  reg [2:0] word_ctr; // @[ICache.scala 64:27]
  wire [3:0] _T_34 = 4'h8 - 4'h1; // @[ICache.scala 120:45]
  wire [3:0] _GEN_173 = {{1'd0}, word_ctr}; // @[ICache.scala 120:24]
  wire  _T_35 = _GEN_173 == _T_34; // @[ICache.scala 120:24]
  wire  _T_36 = state == 2'h3; // @[ICache.scala 124:24]
  reg  _T_6; // @[ICache.scala 45:26]
  reg [23:0] pending_tag_bits; // @[ICache.scala 65:35]
  reg [2:0] pending_set_index; // @[ICache.scala 66:36]
  reg [2:0] pending_block_offset; // @[ICache.scala 67:39]
  wire [2:0] addr_block_offset_word = io_bus_addr[4:2]; // @[ICache.scala 73:45]
  wire [5:0] _T_15 = {addr_set_index,addr_block_offset_word}; // @[Cat.scala 29:58]
  wire [29:0] _T_22 = {addr_tag_bits,addr_set_index,3'h0}; // @[Cat.scala 29:58]
  wire  _GEN_28 = io_main_mem_busy ? 1'h0 : 1'h1; // @[ICache.scala 89:44]
  wire [31:0] _GEN_29 = io_main_mem_busy ? 32'h0 : {{2'd0}, _T_22}; // @[ICache.scala 89:44]
  wire  _GEN_36 = _T_20 ? 1'h0 : _GEN_28; // @[ICache.scala 86:113]
  wire [31:0] _GEN_37 = _T_20 ? 32'h0 : _GEN_29; // @[ICache.scala 86:113]
  wire  _GEN_48 = io_bus_we | _T_20; // @[ICache.scala 77:26]
  wire [5:0] _GEN_49 = io_bus_we ? 6'h0 : _T_15; // @[ICache.scala 77:26]
  wire  _GEN_55 = io_bus_we ? 1'h0 : _GEN_36; // @[ICache.scala 77:26]
  wire [31:0] _GEN_56 = io_bus_we ? 32'h0 : _GEN_37; // @[ICache.scala 77:26]
  wire [29:0] _T_26 = {pending_tag_bits,pending_set_index,3'h0}; // @[Cat.scala 29:58]
  wire [31:0] _GEN_60 = _T_24 ? {{2'd0}, _T_26} : 32'h0; // @[ICache.scala 107:34]
  wire [5:0] _T_30 = {pending_set_index,word_ctr}; // @[Cat.scala 29:58]
  wire [2:0] _T_32 = word_ctr + 3'h1; // @[ICache.scala 119:30]
  wire  _GEN_174 = 3'h0 == pending_set_index; // @[ICache.scala 125:35]
  wire  _GEN_64 = _GEN_174 | _GEN_0; // @[ICache.scala 125:35]
  wire  _GEN_175 = 3'h1 == pending_set_index; // @[ICache.scala 125:35]
  wire  _GEN_65 = _GEN_175 | _GEN_1; // @[ICache.scala 125:35]
  wire  _GEN_176 = 3'h2 == pending_set_index; // @[ICache.scala 125:35]
  wire  _GEN_66 = _GEN_176 | _GEN_2; // @[ICache.scala 125:35]
  wire  _GEN_177 = 3'h3 == pending_set_index; // @[ICache.scala 125:35]
  wire  _GEN_67 = _GEN_177 | _GEN_3; // @[ICache.scala 125:35]
  wire  _GEN_178 = 3'h4 == pending_set_index; // @[ICache.scala 125:35]
  wire  _GEN_68 = _GEN_178 | _GEN_4; // @[ICache.scala 125:35]
  wire  _GEN_179 = 3'h5 == pending_set_index; // @[ICache.scala 125:35]
  wire  _GEN_69 = _GEN_179 | _GEN_5; // @[ICache.scala 125:35]
  wire  _GEN_180 = 3'h6 == pending_set_index; // @[ICache.scala 125:35]
  wire  _GEN_70 = _GEN_180 | _GEN_6; // @[ICache.scala 125:35]
  wire  _GEN_181 = 3'h7 == pending_set_index; // @[ICache.scala 125:35]
  wire  _GEN_71 = _GEN_181 | _GEN_7; // @[ICache.scala 125:35]
  wire [5:0] _T_37 = {pending_set_index,pending_block_offset}; // @[Cat.scala 29:58]
  wire [5:0] _GEN_98 = _T_36 ? _T_37 : 6'h0; // @[ICache.scala 124:47]
  wire [31:0] _GEN_100 = _T_28 ? io_main_mem_rd_d : 32'h0; // @[ICache.scala 114:69]
  wire [5:0] _GEN_101 = _T_28 ? _T_30 : _GEN_98; // @[ICache.scala 114:69]
  wire  _GEN_122 = _T_23 & _T_24; // @[ICache.scala 106:43]
  wire [31:0] _GEN_123 = _T_23 ? _GEN_60 : 32'h0; // @[ICache.scala 106:43]
  wire  _GEN_125 = _T_23 ? 1'h0 : _T_28; // @[ICache.scala 106:43]
  wire [31:0] _GEN_126 = _T_23 ? 32'h0 : _GEN_100; // @[ICache.scala 106:43]
  wire [5:0] _GEN_127 = _T_23 ? 6'h0 : _GEN_101; // @[ICache.scala 106:43]
  wire [5:0] _GEN_146 = _T_14 ? _GEN_49 : _GEN_127; // @[ICache.scala 76:76]
  assign io_bus_ack = _T_6; // @[ICache.scala 45:16]
  assign io_bus_data_rd = io_cache_mem_rd_d; // @[ICache.scala 53:20]
  assign io_cache_mem_addr = {{26'd0}, _GEN_146}; // @[ICache.scala 52:23 ICache.scala 81:31 ICache.scala 117:27 ICache.scala 129:27]
  assign io_cache_mem_we = _T_14 ? 1'h0 : _GEN_125; // @[ICache.scala 49:21 ICache.scala 115:25]
  assign io_cache_mem_wr_d = _T_14 ? 32'h0 : _GEN_126; // @[ICache.scala 51:23 ICache.scala 116:27]
  assign io_main_mem_rd_req = _T_14 ? _GEN_55 : _GEN_122; // @[ICache.scala 61:24 ICache.scala 98:36 ICache.scala 110:32]
  assign io_main_mem_addr = _T_14 ? _GEN_56 : _GEN_123; // @[ICache.scala 62:22 ICache.scala 99:34 ICache.scala 111:30]
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
  valids_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  valids_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  valids_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  valids_3 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  valids_4 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  valids_5 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  valids_6 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  valids_7 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  tags_0 = _RAND_8[23:0];
  _RAND_9 = {1{`RANDOM}};
  tags_1 = _RAND_9[23:0];
  _RAND_10 = {1{`RANDOM}};
  tags_2 = _RAND_10[23:0];
  _RAND_11 = {1{`RANDOM}};
  tags_3 = _RAND_11[23:0];
  _RAND_12 = {1{`RANDOM}};
  tags_4 = _RAND_12[23:0];
  _RAND_13 = {1{`RANDOM}};
  tags_5 = _RAND_13[23:0];
  _RAND_14 = {1{`RANDOM}};
  tags_6 = _RAND_14[23:0];
  _RAND_15 = {1{`RANDOM}};
  tags_7 = _RAND_15[23:0];
  _RAND_16 = {1{`RANDOM}};
  state = _RAND_16[1:0];
  _RAND_17 = {1{`RANDOM}};
  word_ctr = _RAND_17[2:0];
  _RAND_18 = {1{`RANDOM}};
  _T_6 = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  pending_tag_bits = _RAND_19[23:0];
  _RAND_20 = {1{`RANDOM}};
  pending_set_index = _RAND_20[2:0];
  _RAND_21 = {1{`RANDOM}};
  pending_block_offset = _RAND_21[2:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    if (reset) begin
      valids_0 <= 1'h0;
    end else if (_T_14) begin
      if (io_flush_all) begin
        valids_0 <= 1'h0;
      end
    end else if (_T_23) begin
      if (io_flush_all) begin
        valids_0 <= 1'h0;
      end
    end else if (_T_28) begin
      if (io_flush_all) begin
        valids_0 <= 1'h0;
      end
    end else if (_T_36) begin
      valids_0 <= _GEN_64;
    end else if (io_flush_all) begin
      valids_0 <= 1'h0;
    end
    if (reset) begin
      valids_1 <= 1'h0;
    end else if (_T_14) begin
      if (io_flush_all) begin
        valids_1 <= 1'h0;
      end
    end else if (_T_23) begin
      if (io_flush_all) begin
        valids_1 <= 1'h0;
      end
    end else if (_T_28) begin
      if (io_flush_all) begin
        valids_1 <= 1'h0;
      end
    end else if (_T_36) begin
      valids_1 <= _GEN_65;
    end else if (io_flush_all) begin
      valids_1 <= 1'h0;
    end
    if (reset) begin
      valids_2 <= 1'h0;
    end else if (_T_14) begin
      if (io_flush_all) begin
        valids_2 <= 1'h0;
      end
    end else if (_T_23) begin
      if (io_flush_all) begin
        valids_2 <= 1'h0;
      end
    end else if (_T_28) begin
      if (io_flush_all) begin
        valids_2 <= 1'h0;
      end
    end else if (_T_36) begin
      valids_2 <= _GEN_66;
    end else if (io_flush_all) begin
      valids_2 <= 1'h0;
    end
    if (reset) begin
      valids_3 <= 1'h0;
    end else if (_T_14) begin
      if (io_flush_all) begin
        valids_3 <= 1'h0;
      end
    end else if (_T_23) begin
      if (io_flush_all) begin
        valids_3 <= 1'h0;
      end
    end else if (_T_28) begin
      if (io_flush_all) begin
        valids_3 <= 1'h0;
      end
    end else if (_T_36) begin
      valids_3 <= _GEN_67;
    end else if (io_flush_all) begin
      valids_3 <= 1'h0;
    end
    if (reset) begin
      valids_4 <= 1'h0;
    end else if (_T_14) begin
      if (io_flush_all) begin
        valids_4 <= 1'h0;
      end
    end else if (_T_23) begin
      if (io_flush_all) begin
        valids_4 <= 1'h0;
      end
    end else if (_T_28) begin
      if (io_flush_all) begin
        valids_4 <= 1'h0;
      end
    end else if (_T_36) begin
      valids_4 <= _GEN_68;
    end else if (io_flush_all) begin
      valids_4 <= 1'h0;
    end
    if (reset) begin
      valids_5 <= 1'h0;
    end else if (_T_14) begin
      if (io_flush_all) begin
        valids_5 <= 1'h0;
      end
    end else if (_T_23) begin
      if (io_flush_all) begin
        valids_5 <= 1'h0;
      end
    end else if (_T_28) begin
      if (io_flush_all) begin
        valids_5 <= 1'h0;
      end
    end else if (_T_36) begin
      valids_5 <= _GEN_69;
    end else if (io_flush_all) begin
      valids_5 <= 1'h0;
    end
    if (reset) begin
      valids_6 <= 1'h0;
    end else if (_T_14) begin
      if (io_flush_all) begin
        valids_6 <= 1'h0;
      end
    end else if (_T_23) begin
      if (io_flush_all) begin
        valids_6 <= 1'h0;
      end
    end else if (_T_28) begin
      if (io_flush_all) begin
        valids_6 <= 1'h0;
      end
    end else if (_T_36) begin
      valids_6 <= _GEN_70;
    end else if (io_flush_all) begin
      valids_6 <= 1'h0;
    end
    if (reset) begin
      valids_7 <= 1'h0;
    end else if (_T_14) begin
      if (io_flush_all) begin
        valids_7 <= 1'h0;
      end
    end else if (_T_23) begin
      if (io_flush_all) begin
        valids_7 <= 1'h0;
      end
    end else if (_T_28) begin
      if (io_flush_all) begin
        valids_7 <= 1'h0;
      end
    end else if (_T_36) begin
      valids_7 <= _GEN_71;
    end else if (io_flush_all) begin
      valids_7 <= 1'h0;
    end
    if (reset) begin
      tags_0 <= 24'h0;
    end else if (!(_T_14)) begin
      if (!(_T_23)) begin
        if (!(_T_28)) begin
          if (_T_36) begin
            if (3'h0 == pending_set_index) begin
              tags_0 <= pending_tag_bits;
            end
          end
        end
      end
    end
    if (reset) begin
      tags_1 <= 24'h0;
    end else if (!(_T_14)) begin
      if (!(_T_23)) begin
        if (!(_T_28)) begin
          if (_T_36) begin
            if (3'h1 == pending_set_index) begin
              tags_1 <= pending_tag_bits;
            end
          end
        end
      end
    end
    if (reset) begin
      tags_2 <= 24'h0;
    end else if (!(_T_14)) begin
      if (!(_T_23)) begin
        if (!(_T_28)) begin
          if (_T_36) begin
            if (3'h2 == pending_set_index) begin
              tags_2 <= pending_tag_bits;
            end
          end
        end
      end
    end
    if (reset) begin
      tags_3 <= 24'h0;
    end else if (!(_T_14)) begin
      if (!(_T_23)) begin
        if (!(_T_28)) begin
          if (_T_36) begin
            if (3'h3 == pending_set_index) begin
              tags_3 <= pending_tag_bits;
            end
          end
        end
      end
    end
    if (reset) begin
      tags_4 <= 24'h0;
    end else if (!(_T_14)) begin
      if (!(_T_23)) begin
        if (!(_T_28)) begin
          if (_T_36) begin
            if (3'h4 == pending_set_index) begin
              tags_4 <= pending_tag_bits;
            end
          end
        end
      end
    end
    if (reset) begin
      tags_5 <= 24'h0;
    end else if (!(_T_14)) begin
      if (!(_T_23)) begin
        if (!(_T_28)) begin
          if (_T_36) begin
            if (3'h5 == pending_set_index) begin
              tags_5 <= pending_tag_bits;
            end
          end
        end
      end
    end
    if (reset) begin
      tags_6 <= 24'h0;
    end else if (!(_T_14)) begin
      if (!(_T_23)) begin
        if (!(_T_28)) begin
          if (_T_36) begin
            if (3'h6 == pending_set_index) begin
              tags_6 <= pending_tag_bits;
            end
          end
        end
      end
    end
    if (reset) begin
      tags_7 <= 24'h0;
    end else if (!(_T_14)) begin
      if (!(_T_23)) begin
        if (!(_T_28)) begin
          if (_T_36) begin
            if (3'h7 == pending_set_index) begin
              tags_7 <= pending_tag_bits;
            end
          end
        end
      end
    end
    if (reset) begin
      state <= 2'h0;
    end else if (_T_14) begin
      if (!(io_bus_we)) begin
        if (!(_T_20)) begin
          if (io_main_mem_busy) begin
            state <= 2'h1;
          end else begin
            state <= 2'h2;
          end
        end
      end
    end else if (_T_23) begin
      if (_T_24) begin
        state <= 2'h2;
      end
    end else if (_T_28) begin
      if (_T_35) begin
        state <= 2'h3;
      end
    end else if (_T_36) begin
      state <= 2'h0;
    end
    if (reset) begin
      word_ctr <= 3'h0;
    end else if (_T_14) begin
      if (!(io_bus_we)) begin
        if (!(_T_20)) begin
          if (!(io_main_mem_busy)) begin
            word_ctr <= 3'h0;
          end
        end
      end
    end else if (_T_23) begin
      if (_T_24) begin
        word_ctr <= 3'h0;
      end
    end else if (_T_28) begin
      if (_T_35) begin
        word_ctr <= 3'h0;
      end else begin
        word_ctr <= _T_32;
      end
    end
    if (_T_14) begin
      _T_6 <= _GEN_48;
    end else if (_T_23) begin
      _T_6 <= 1'h0;
    end else if (_T_28) begin
      _T_6 <= 1'h0;
    end else begin
      _T_6 <= _T_36;
    end
    if (reset) begin
      pending_tag_bits <= 24'h0;
    end else if (_T_14) begin
      if (!(io_bus_we)) begin
        if (!(_T_20)) begin
          pending_tag_bits <= addr_tag_bits;
        end
      end
    end
    if (reset) begin
      pending_set_index <= 3'h0;
    end else if (_T_14) begin
      if (!(io_bus_we)) begin
        if (!(_T_20)) begin
          pending_set_index <= addr_set_index;
        end
      end
    end
    if (reset) begin
      pending_block_offset <= 3'h0;
    end else if (_T_14) begin
      if (!(io_bus_we)) begin
        if (!(_T_20)) begin
          pending_block_offset <= addr_block_offset_word;
        end
      end
    end
  end
endmodule
module WishboneMemoryBridge(
  input         clock,
  input         reset,
  input         io_bus_cyc,
  input         io_bus_stb,
  input         io_bus_we,
  input  [3:0]  io_bus_sel,
  input  [31:0] io_bus_addr,
  input  [31:0] io_bus_data_wr,
  output        io_bus_ack,
  output [31:0] io_bus_data_rd,
  output        io_mem_rd_req,
  output        io_mem_wr_req,
  output        io_mem_mem_or_reg,
  output [3:0]  io_mem_wr_byte_en,
  output [31:0] io_mem_addr,
  output [31:0] io_mem_wr_d,
  input  [31:0] io_mem_rd_d,
  input         io_mem_rd_rdy,
  input         io_mem_busy,
  input         io_mem_burst_wr_rdy
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
`endif // RANDOMIZE_REG_INIT
  reg  ack; // @[WishboneMemoryBridge.scala 16:22]
  reg [31:0] ack_data; // @[WishboneMemoryBridge.scala 17:23]
  reg  txn_queued; // @[WishboneMemoryBridge.scala 19:29]
  reg  txn_active; // @[WishboneMemoryBridge.scala 20:29]
  reg  txn_we; // @[WishboneMemoryBridge.scala 21:25]
  wire  _T = ~txn_active; // @[WishboneMemoryBridge.scala 23:24]
  wire  _T_1 = _T & io_bus_stb; // @[WishboneMemoryBridge.scala 23:36]
  wire  _T_2 = _T_1 & io_bus_cyc; // @[WishboneMemoryBridge.scala 23:50]
  wire  _T_3 = ~io_bus_ack; // @[WishboneMemoryBridge.scala 23:67]
  wire  _T_4 = _T_2 & _T_3; // @[WishboneMemoryBridge.scala 23:64]
  wire  _T_5 = ~ack; // @[WishboneMemoryBridge.scala 23:82]
  wire  wb_txn_valid = _T_4 & _T_5; // @[WishboneMemoryBridge.scala 23:79]
  reg [31:0] _T_6; // @[PseudoLatch.scala 13:22]
  wire [31:0] _GEN_0 = wb_txn_valid ? io_bus_addr : _T_6; // @[PseudoLatch.scala 14:21]
  reg [3:0] _T_7; // @[PseudoLatch.scala 13:22]
  reg [31:0] _T_8; // @[PseudoLatch.scala 13:22]
  reg  _T_9; // @[PseudoLatch.scala 13:22]
  wire  _GEN_3 = wb_txn_valid ? io_bus_we : _T_9; // @[PseudoLatch.scala 14:21]
  wire  _T_12 = ~io_mem_busy; // @[WishboneMemoryBridge.scala 50:27]
  wire  _T_13 = txn_we ? _T_12 : io_mem_rd_rdy; // @[WishboneMemoryBridge.scala 50:18]
  wire  _GEN_4 = _T_13 | ack; // @[WishboneMemoryBridge.scala 50:58]
  wire  _GEN_6 = _T_13 ? 1'h0 : txn_active; // @[WishboneMemoryBridge.scala 50:58]
  wire  _T_15 = ~io_mem_burst_wr_rdy; // @[WishboneMemoryBridge.scala 56:39]
  wire  _T_16 = _T_12 & _T_15; // @[WishboneMemoryBridge.scala 56:36]
  wire  _T_18 = _GEN_3 ? _T_16 : _T_12; // @[WishboneMemoryBridge.scala 56:18]
  wire  _T_19 = ~_GEN_3; // @[WishboneMemoryBridge.scala 57:30]
  wire  _GEN_7 = _T_18 & _T_19; // @[WishboneMemoryBridge.scala 56:76]
  wire  _GEN_8 = _T_18 & _GEN_3; // @[WishboneMemoryBridge.scala 56:76]
  wire  _GEN_10 = _T_18 | txn_active; // @[WishboneMemoryBridge.scala 56:76]
  wire  _GEN_12 = txn_queued & _GEN_7; // @[WishboneMemoryBridge.scala 55:30]
  wire  _GEN_13 = txn_queued & _GEN_8; // @[WishboneMemoryBridge.scala 55:30]
  wire  _GEN_15 = txn_queued ? _GEN_10 : txn_active; // @[WishboneMemoryBridge.scala 55:30]
  wire  _GEN_19 = txn_active ? _GEN_6 : _GEN_15; // @[WishboneMemoryBridge.scala 49:30]
  wire  _GEN_20 = txn_active ? 1'h0 : _GEN_12; // @[WishboneMemoryBridge.scala 49:30]
  wire  _GEN_21 = txn_active ? 1'h0 : _GEN_13; // @[WishboneMemoryBridge.scala 49:30]
  wire  _GEN_28 = ack ? txn_active : _GEN_19; // @[WishboneMemoryBridge.scala 44:16]
  wire  _GEN_29 = ack ? 1'h0 : _GEN_20; // @[WishboneMemoryBridge.scala 44:16]
  wire  _GEN_30 = ack ? 1'h0 : _GEN_21; // @[WishboneMemoryBridge.scala 44:16]
  wire  _GEN_33 = _T_18 ? _T_19 : _GEN_29; // @[WishboneMemoryBridge.scala 66:76]
  wire  _GEN_34 = _T_18 ? _GEN_3 : _GEN_30; // @[WishboneMemoryBridge.scala 66:76]
  wire  _GEN_36 = _T_18 | _GEN_28; // @[WishboneMemoryBridge.scala 66:76]
  assign io_bus_ack = ack; // @[WishboneMemoryBridge.scala 39:16 WishboneMemoryBridge.scala 46:20]
  assign io_bus_data_rd = ack ? ack_data : 32'h0; // @[WishboneMemoryBridge.scala 40:20 WishboneMemoryBridge.scala 47:24]
  assign io_mem_rd_req = wb_txn_valid ? _GEN_33 : _GEN_29; // @[WishboneMemoryBridge.scala 29:19 WishboneMemoryBridge.scala 57:27 WishboneMemoryBridge.scala 67:27]
  assign io_mem_wr_req = wb_txn_valid ? _GEN_34 : _GEN_30; // @[WishboneMemoryBridge.scala 30:19 WishboneMemoryBridge.scala 58:27 WishboneMemoryBridge.scala 68:27]
  assign io_mem_mem_or_reg = _GEN_0[27]; // @[WishboneMemoryBridge.scala 32:23]
  assign io_mem_wr_byte_en = wb_txn_valid ? io_bus_sel : _T_7; // @[WishboneMemoryBridge.scala 33:23]
  assign io_mem_addr = {{7'd0}, _GEN_0[26:2]}; // @[WishboneMemoryBridge.scala 35:17]
  assign io_mem_wr_d = wb_txn_valid ? io_bus_data_wr : _T_8; // @[WishboneMemoryBridge.scala 36:17]
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
  ack = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  ack_data = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  txn_queued = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  txn_active = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  txn_we = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  _T_6 = _RAND_5[31:0];
  _RAND_6 = {1{`RANDOM}};
  _T_7 = _RAND_6[3:0];
  _RAND_7 = {1{`RANDOM}};
  _T_8 = _RAND_7[31:0];
  _RAND_8 = {1{`RANDOM}};
  _T_9 = _RAND_8[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    if (reset) begin
      ack <= 1'h0;
    end else if (ack) begin
      ack <= 1'h0;
    end else if (txn_active) begin
      ack <= _GEN_4;
    end
    if (!(ack)) begin
      if (txn_active) begin
        if (_T_13) begin
          ack_data <= io_mem_rd_d;
        end
      end
    end
    if (reset) begin
      txn_queued <= 1'h0;
    end else if (wb_txn_valid) begin
      if (_T_18) begin
        txn_queued <= 1'h0;
      end else begin
        txn_queued <= 1'h1;
      end
    end else if (!(ack)) begin
      if (!(txn_active)) begin
        if (txn_queued) begin
          if (_T_18) begin
            txn_queued <= 1'h0;
          end
        end
      end
    end
    if (reset) begin
      txn_active <= 1'h0;
    end else if (wb_txn_valid) begin
      txn_active <= _GEN_36;
    end else if (!(ack)) begin
      if (txn_active) begin
        if (_T_13) begin
          txn_active <= 1'h0;
        end
      end else if (txn_queued) begin
        txn_active <= _GEN_10;
      end
    end
    if (reset) begin
      txn_we <= 1'h0;
    end else if (wb_txn_valid) begin
      if (_T_18) begin
        if (wb_txn_valid) begin
          txn_we <= io_bus_we;
        end else begin
          txn_we <= _T_9;
        end
      end else if (!(ack)) begin
        if (!(txn_active)) begin
          if (txn_queued) begin
            if (_T_18) begin
              if (wb_txn_valid) begin
                txn_we <= io_bus_we;
              end else begin
                txn_we <= _T_9;
              end
            end
          end
        end
      end
    end else if (!(ack)) begin
      if (!(txn_active)) begin
        if (txn_queued) begin
          if (_T_18) begin
            if (wb_txn_valid) begin
              txn_we <= io_bus_we;
            end else begin
              txn_we <= _T_9;
            end
          end
        end
      end
    end
    if (wb_txn_valid) begin
      _T_6 <= io_bus_addr;
    end
    if (wb_txn_valid) begin
      _T_7 <= io_bus_sel;
    end
    if (wb_txn_valid) begin
      _T_8 <= io_bus_data_wr;
    end
    if (wb_txn_valid) begin
      _T_9 <= io_bus_we;
    end
  end
endmodule
module MemoryArbiter(
  input         clock,
  input         reset,
  input         io_in0_rd_req,
  input  [31:0] io_in0_addr,
  output [31:0] io_in0_rd_d,
  output        io_in0_rd_rdy,
  output        io_in0_busy,
  input         io_in1_rd_req,
  input         io_in1_wr_req,
  input         io_in1_mem_or_reg,
  input  [3:0]  io_in1_wr_byte_en,
  input  [31:0] io_in1_addr,
  input  [31:0] io_in1_wr_d,
  output [31:0] io_in1_rd_d,
  output        io_in1_rd_rdy,
  output        io_in1_busy,
  output        io_in1_burst_wr_rdy,
  output        io_out_rd_req,
  output        io_out_wr_req,
  output        io_out_mem_or_reg,
  output [3:0]  io_out_wr_byte_en,
  output [5:0]  io_out_rd_num_dwords,
  output [31:0] io_out_addr,
  output [31:0] io_out_wr_d,
  input  [31:0] io_out_rd_d,
  input         io_out_rd_rdy,
  input         io_out_busy,
  input         io_out_burst_wr_rdy
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  reg  grant; // @[MemoryArbiter.scala 17:24]
  wire  _T = ~grant; // @[MemoryArbiter.scala 20:17]
  wire  _T_1 = ~io_out_busy; // @[MemoryArbiter.scala 37:11]
  wire  _T_2 = ~io_out_burst_wr_rdy; // @[MemoryArbiter.scala 37:27]
  wire  _T_3 = _T_1 & _T_2; // @[MemoryArbiter.scala 37:24]
  wire  _T_4 = ~io_out_rd_req; // @[MemoryArbiter.scala 38:11]
  wire  _T_5 = _T_3 & _T_4; // @[MemoryArbiter.scala 37:48]
  wire  _T_6 = ~io_out_wr_req; // @[MemoryArbiter.scala 38:29]
  wire  _T_7 = _T_5 & _T_6; // @[MemoryArbiter.scala 38:26]
  reg  _T_8; // @[MemoryArbiter.scala 39:19]
  wire  _T_9 = ~_T_8; // @[MemoryArbiter.scala 39:11]
  wire  _T_10 = _T_7 & _T_9; // @[MemoryArbiter.scala 38:44]
  reg  _T_11; // @[MemoryArbiter.scala 39:44]
  wire  _T_12 = ~_T_11; // @[MemoryArbiter.scala 39:36]
  wire  _T_13 = _T_10 & _T_12; // @[MemoryArbiter.scala 39:33]
  reg  _T_14; // @[MemoryArbiter.scala 40:19]
  wire  _T_15 = ~_T_14; // @[MemoryArbiter.scala 40:11]
  wire  _T_16 = _T_13 & _T_15; // @[MemoryArbiter.scala 39:66]
  reg  _T_17; // @[MemoryArbiter.scala 40:46]
  wire  _T_18 = ~_T_17; // @[MemoryArbiter.scala 40:38]
  wire  _T_19 = _T_16 & _T_18; // @[MemoryArbiter.scala 40:35]
  assign io_in0_rd_d = _T ? io_out_rd_d : 32'h0; // @[MemoryArbiter.scala 21:16 MemoryArbiter.scala 28:21]
  assign io_in0_rd_rdy = _T & io_out_rd_rdy; // @[MemoryArbiter.scala 21:16 MemoryArbiter.scala 29:23]
  assign io_in0_busy = _T ? io_out_busy : 1'h1; // @[MemoryArbiter.scala 21:16 MemoryArbiter.scala 30:21]
  assign io_in1_rd_d = _T ? 32'h0 : io_out_rd_d; // @[MemoryArbiter.scala 22:21 MemoryArbiter.scala 27:16]
  assign io_in1_rd_rdy = _T ? 1'h0 : io_out_rd_rdy; // @[MemoryArbiter.scala 23:23 MemoryArbiter.scala 27:16]
  assign io_in1_busy = _T | io_out_busy; // @[MemoryArbiter.scala 24:21 MemoryArbiter.scala 27:16]
  assign io_in1_burst_wr_rdy = _T ? 1'h0 : io_out_burst_wr_rdy; // @[MemoryArbiter.scala 25:29 MemoryArbiter.scala 27:16]
  assign io_out_rd_req = _T ? io_in0_rd_req : io_in1_rd_req; // @[MemoryArbiter.scala 21:16 MemoryArbiter.scala 27:16]
  assign io_out_wr_req = _T ? 1'h0 : io_in1_wr_req; // @[MemoryArbiter.scala 21:16 MemoryArbiter.scala 27:16]
  assign io_out_mem_or_reg = _T ? 1'h0 : io_in1_mem_or_reg; // @[MemoryArbiter.scala 21:16 MemoryArbiter.scala 27:16]
  assign io_out_wr_byte_en = _T ? 4'h0 : io_in1_wr_byte_en; // @[MemoryArbiter.scala 21:16 MemoryArbiter.scala 27:16]
  assign io_out_rd_num_dwords = _T ? 6'h8 : 6'h1; // @[MemoryArbiter.scala 21:16 MemoryArbiter.scala 27:16]
  assign io_out_addr = _T ? io_in0_addr : io_in1_addr; // @[MemoryArbiter.scala 21:16 MemoryArbiter.scala 27:16]
  assign io_out_wr_d = _T ? 32'h0 : io_in1_wr_d; // @[MemoryArbiter.scala 21:16 MemoryArbiter.scala 27:16]
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
  grant = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  _T_8 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  _T_11 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  _T_14 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  _T_17 = _RAND_4[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    if (reset) begin
      grant <= 1'h0;
    end else if (_T_19) begin
      grant <= _T;
    end
    _T_8 <= io_out_busy;
    _T_11 <= io_out_burst_wr_rdy;
    _T_14 <= io_out_rd_req;
    _T_17 <= io_out_wr_req;
  end
endmodule
module SimpleRAM(
  input         clock,
  input  [31:0] io_bus_addr,
  output [31:0] io_bus_rd_d,
  input         io_bus_we,
  input  [31:0] io_bus_wr_d
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_9;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] ram_0 [0:63]; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_0__T_12_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_0__T_12_addr; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_0__T_17_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_0__T_17_addr; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_0__T_10_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_0__T_10_addr; // @[SimpleRAM.scala 22:26]
  wire  ram_0__T_10_mask; // @[SimpleRAM.scala 22:26]
  wire  ram_0__T_10_en; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_0__T_27_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_0__T_27_addr; // @[SimpleRAM.scala 22:26]
  wire  ram_0__T_27_mask; // @[SimpleRAM.scala 22:26]
  wire  ram_0__T_27_en; // @[SimpleRAM.scala 22:26]
  reg  ram_0__T_12_en_pipe_0;
  reg [5:0] ram_0__T_12_addr_pipe_0;
  reg [7:0] ram_1 [0:63]; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_1__T_12_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_1__T_12_addr; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_1__T_17_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_1__T_17_addr; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_1__T_10_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_1__T_10_addr; // @[SimpleRAM.scala 22:26]
  wire  ram_1__T_10_mask; // @[SimpleRAM.scala 22:26]
  wire  ram_1__T_10_en; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_1__T_27_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_1__T_27_addr; // @[SimpleRAM.scala 22:26]
  wire  ram_1__T_27_mask; // @[SimpleRAM.scala 22:26]
  wire  ram_1__T_27_en; // @[SimpleRAM.scala 22:26]
  reg  ram_1__T_12_en_pipe_0;
  reg [5:0] ram_1__T_12_addr_pipe_0;
  reg [7:0] ram_2 [0:63]; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_2__T_12_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_2__T_12_addr; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_2__T_17_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_2__T_17_addr; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_2__T_10_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_2__T_10_addr; // @[SimpleRAM.scala 22:26]
  wire  ram_2__T_10_mask; // @[SimpleRAM.scala 22:26]
  wire  ram_2__T_10_en; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_2__T_27_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_2__T_27_addr; // @[SimpleRAM.scala 22:26]
  wire  ram_2__T_27_mask; // @[SimpleRAM.scala 22:26]
  wire  ram_2__T_27_en; // @[SimpleRAM.scala 22:26]
  reg  ram_2__T_12_en_pipe_0;
  reg [5:0] ram_2__T_12_addr_pipe_0;
  reg [7:0] ram_3 [0:63]; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_3__T_12_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_3__T_12_addr; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_3__T_17_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_3__T_17_addr; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_3__T_10_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_3__T_10_addr; // @[SimpleRAM.scala 22:26]
  wire  ram_3__T_10_mask; // @[SimpleRAM.scala 22:26]
  wire  ram_3__T_10_en; // @[SimpleRAM.scala 22:26]
  wire [7:0] ram_3__T_27_data; // @[SimpleRAM.scala 22:26]
  wire [5:0] ram_3__T_27_addr; // @[SimpleRAM.scala 22:26]
  wire  ram_3__T_27_mask; // @[SimpleRAM.scala 22:26]
  wire  ram_3__T_27_en; // @[SimpleRAM.scala 22:26]
  reg  ram_3__T_12_en_pipe_0;
  reg [5:0] ram_3__T_12_addr_pipe_0;
  wire [31:0] _T_15 = {ram_3__T_12_data,ram_2__T_12_data,ram_1__T_12_data,ram_0__T_12_data}; // @[SimpleRAM.scala 32:46]
  assign ram_0__T_12_addr = ram_0__T_12_addr_pipe_0;
  assign ram_0__T_12_data = ram_0[ram_0__T_12_addr]; // @[SimpleRAM.scala 22:26]
  assign ram_0__T_17_addr = 6'h0;
  assign ram_0__T_17_data = ram_0[ram_0__T_17_addr]; // @[SimpleRAM.scala 22:26]
  assign ram_0__T_10_data = io_bus_wr_d[7:0];
  assign ram_0__T_10_addr = io_bus_addr[5:0];
  assign ram_0__T_10_mask = 1'h1;
  assign ram_0__T_10_en = io_bus_we;
  assign ram_0__T_27_data = 8'h0;
  assign ram_0__T_27_addr = 6'h0;
  assign ram_0__T_27_mask = 1'h1;
  assign ram_0__T_27_en = 1'h0;
  assign ram_1__T_12_addr = ram_1__T_12_addr_pipe_0;
  assign ram_1__T_12_data = ram_1[ram_1__T_12_addr]; // @[SimpleRAM.scala 22:26]
  assign ram_1__T_17_addr = 6'h0;
  assign ram_1__T_17_data = ram_1[ram_1__T_17_addr]; // @[SimpleRAM.scala 22:26]
  assign ram_1__T_10_data = io_bus_wr_d[15:8];
  assign ram_1__T_10_addr = io_bus_addr[5:0];
  assign ram_1__T_10_mask = 1'h1;
  assign ram_1__T_10_en = io_bus_we;
  assign ram_1__T_27_data = 8'h0;
  assign ram_1__T_27_addr = 6'h0;
  assign ram_1__T_27_mask = 1'h1;
  assign ram_1__T_27_en = 1'h0;
  assign ram_2__T_12_addr = ram_2__T_12_addr_pipe_0;
  assign ram_2__T_12_data = ram_2[ram_2__T_12_addr]; // @[SimpleRAM.scala 22:26]
  assign ram_2__T_17_addr = 6'h0;
  assign ram_2__T_17_data = ram_2[ram_2__T_17_addr]; // @[SimpleRAM.scala 22:26]
  assign ram_2__T_10_data = io_bus_wr_d[23:16];
  assign ram_2__T_10_addr = io_bus_addr[5:0];
  assign ram_2__T_10_mask = 1'h1;
  assign ram_2__T_10_en = io_bus_we;
  assign ram_2__T_27_data = 8'h0;
  assign ram_2__T_27_addr = 6'h0;
  assign ram_2__T_27_mask = 1'h1;
  assign ram_2__T_27_en = 1'h0;
  assign ram_3__T_12_addr = ram_3__T_12_addr_pipe_0;
  assign ram_3__T_12_data = ram_3[ram_3__T_12_addr]; // @[SimpleRAM.scala 22:26]
  assign ram_3__T_17_addr = 6'h0;
  assign ram_3__T_17_data = ram_3[ram_3__T_17_addr]; // @[SimpleRAM.scala 22:26]
  assign ram_3__T_10_data = io_bus_wr_d[31:24];
  assign ram_3__T_10_addr = io_bus_addr[5:0];
  assign ram_3__T_10_mask = 1'h1;
  assign ram_3__T_10_en = io_bus_we;
  assign ram_3__T_27_data = 8'h0;
  assign ram_3__T_27_addr = 6'h0;
  assign ram_3__T_27_mask = 1'h1;
  assign ram_3__T_27_en = 1'h0;
  assign io_bus_rd_d = io_bus_we ? 32'h0 : _T_15; // @[SimpleRAM.scala 28:17 SimpleRAM.scala 32:21]
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
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 64; initvar = initvar+1)
    ram_0[initvar] = _RAND_0[7:0];
  _RAND_3 = {1{`RANDOM}};
  for (initvar = 0; initvar < 64; initvar = initvar+1)
    ram_1[initvar] = _RAND_3[7:0];
  _RAND_6 = {1{`RANDOM}};
  for (initvar = 0; initvar < 64; initvar = initvar+1)
    ram_2[initvar] = _RAND_6[7:0];
  _RAND_9 = {1{`RANDOM}};
  for (initvar = 0; initvar < 64; initvar = initvar+1)
    ram_3[initvar] = _RAND_9[7:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  ram_0__T_12_en_pipe_0 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  ram_0__T_12_addr_pipe_0 = _RAND_2[5:0];
  _RAND_4 = {1{`RANDOM}};
  ram_1__T_12_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  ram_1__T_12_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  ram_2__T_12_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  ram_2__T_12_addr_pipe_0 = _RAND_8[5:0];
  _RAND_10 = {1{`RANDOM}};
  ram_3__T_12_en_pipe_0 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  ram_3__T_12_addr_pipe_0 = _RAND_11[5:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
  always @(posedge clock) begin
    if(ram_0__T_10_en & ram_0__T_10_mask) begin
      ram_0[ram_0__T_10_addr] <= ram_0__T_10_data; // @[SimpleRAM.scala 22:26]
    end
    if(ram_0__T_27_en & ram_0__T_27_mask) begin
      ram_0[ram_0__T_27_addr] <= ram_0__T_27_data; // @[SimpleRAM.scala 22:26]
    end
    if (io_bus_we) begin
      ram_0__T_12_en_pipe_0 <= 1'h0;
    end else begin
      ram_0__T_12_en_pipe_0 <= 1'h1;
    end
    if (io_bus_we ? 1'h0 : 1'h1) begin
      ram_0__T_12_addr_pipe_0 <= io_bus_addr[5:0];
    end
    if(ram_1__T_10_en & ram_1__T_10_mask) begin
      ram_1[ram_1__T_10_addr] <= ram_1__T_10_data; // @[SimpleRAM.scala 22:26]
    end
    if(ram_1__T_27_en & ram_1__T_27_mask) begin
      ram_1[ram_1__T_27_addr] <= ram_1__T_27_data; // @[SimpleRAM.scala 22:26]
    end
    if (io_bus_we) begin
      ram_1__T_12_en_pipe_0 <= 1'h0;
    end else begin
      ram_1__T_12_en_pipe_0 <= 1'h1;
    end
    if (io_bus_we ? 1'h0 : 1'h1) begin
      ram_1__T_12_addr_pipe_0 <= io_bus_addr[5:0];
    end
    if(ram_2__T_10_en & ram_2__T_10_mask) begin
      ram_2[ram_2__T_10_addr] <= ram_2__T_10_data; // @[SimpleRAM.scala 22:26]
    end
    if(ram_2__T_27_en & ram_2__T_27_mask) begin
      ram_2[ram_2__T_27_addr] <= ram_2__T_27_data; // @[SimpleRAM.scala 22:26]
    end
    if (io_bus_we) begin
      ram_2__T_12_en_pipe_0 <= 1'h0;
    end else begin
      ram_2__T_12_en_pipe_0 <= 1'h1;
    end
    if (io_bus_we ? 1'h0 : 1'h1) begin
      ram_2__T_12_addr_pipe_0 <= io_bus_addr[5:0];
    end
    if(ram_3__T_10_en & ram_3__T_10_mask) begin
      ram_3[ram_3__T_10_addr] <= ram_3__T_10_data; // @[SimpleRAM.scala 22:26]
    end
    if(ram_3__T_27_en & ram_3__T_27_mask) begin
      ram_3[ram_3__T_27_addr] <= ram_3__T_27_data; // @[SimpleRAM.scala 22:26]
    end
    if (io_bus_we) begin
      ram_3__T_12_en_pipe_0 <= 1'h0;
    end else begin
      ram_3__T_12_en_pipe_0 <= 1'h1;
    end
    if (io_bus_we ? 1'h0 : 1'h1) begin
      ram_3__T_12_addr_pipe_0 <= io_bus_addr[5:0];
    end
  end
endmodule
module MemorySubsystem(
  input         clock,
  input         reset,
  input         io_flush_all,
  input         io_bus_cached_cyc,
  input         io_bus_cached_stb,
  input         io_bus_cached_we,
  input  [3:0]  io_bus_cached_sel,
  input  [31:0] io_bus_cached_addr,
  input  [31:0] io_bus_cached_data_wr,
  output        io_bus_cached_ack,
  output        io_bus_cached_err,
  output [31:0] io_bus_cached_data_rd,
  input         io_bus_uncached_cyc,
  input         io_bus_uncached_stb,
  input         io_bus_uncached_we,
  input  [3:0]  io_bus_uncached_sel,
  input  [31:0] io_bus_uncached_addr,
  input  [31:0] io_bus_uncached_data_wr,
  output        io_bus_uncached_ack,
  output        io_bus_uncached_err,
  output [31:0] io_bus_uncached_data_rd,
  output [31:0] io_cache_mem_addr,
  input  [31:0] io_cache_mem_rd_d,
  output        io_cache_mem_we,
  output [3:0]  io_cache_mem_we_sel,
  output [31:0] io_cache_mem_wr_d,
  output        io_main_mem_rd_req,
  output        io_main_mem_wr_req,
  output        io_main_mem_mem_or_reg,
  output [3:0]  io_main_mem_wr_byte_en,
  output [5:0]  io_main_mem_rd_num_dwords,
  output [31:0] io_main_mem_addr,
  output [31:0] io_main_mem_wr_d,
  input  [31:0] io_main_mem_rd_d,
  input         io_main_mem_rd_rdy,
  input         io_main_mem_busy,
  input         io_main_mem_burst_wr_rdy
);
  wire  cache_clock; // @[MemorySubsystem.scala 22:23]
  wire  cache_reset; // @[MemorySubsystem.scala 22:23]
  wire  cache_io_flush_all; // @[MemorySubsystem.scala 22:23]
  wire  cache_io_bus_cyc; // @[MemorySubsystem.scala 22:23]
  wire  cache_io_bus_stb; // @[MemorySubsystem.scala 22:23]
  wire  cache_io_bus_we; // @[MemorySubsystem.scala 22:23]
  wire [31:0] cache_io_bus_addr; // @[MemorySubsystem.scala 22:23]
  wire  cache_io_bus_ack; // @[MemorySubsystem.scala 22:23]
  wire [31:0] cache_io_bus_data_rd; // @[MemorySubsystem.scala 22:23]
  wire [31:0] cache_io_cache_mem_addr; // @[MemorySubsystem.scala 22:23]
  wire [31:0] cache_io_cache_mem_rd_d; // @[MemorySubsystem.scala 22:23]
  wire  cache_io_cache_mem_we; // @[MemorySubsystem.scala 22:23]
  wire [31:0] cache_io_cache_mem_wr_d; // @[MemorySubsystem.scala 22:23]
  wire  cache_io_main_mem_rd_req; // @[MemorySubsystem.scala 22:23]
  wire [31:0] cache_io_main_mem_addr; // @[MemorySubsystem.scala 22:23]
  wire [31:0] cache_io_main_mem_rd_d; // @[MemorySubsystem.scala 22:23]
  wire  cache_io_main_mem_rd_rdy; // @[MemorySubsystem.scala 22:23]
  wire  cache_io_main_mem_busy; // @[MemorySubsystem.scala 22:23]
  wire  direct_clock; // @[MemorySubsystem.scala 26:24]
  wire  direct_reset; // @[MemorySubsystem.scala 26:24]
  wire  direct_io_bus_cyc; // @[MemorySubsystem.scala 26:24]
  wire  direct_io_bus_stb; // @[MemorySubsystem.scala 26:24]
  wire  direct_io_bus_we; // @[MemorySubsystem.scala 26:24]
  wire [3:0] direct_io_bus_sel; // @[MemorySubsystem.scala 26:24]
  wire [31:0] direct_io_bus_addr; // @[MemorySubsystem.scala 26:24]
  wire [31:0] direct_io_bus_data_wr; // @[MemorySubsystem.scala 26:24]
  wire  direct_io_bus_ack; // @[MemorySubsystem.scala 26:24]
  wire [31:0] direct_io_bus_data_rd; // @[MemorySubsystem.scala 26:24]
  wire  direct_io_mem_rd_req; // @[MemorySubsystem.scala 26:24]
  wire  direct_io_mem_wr_req; // @[MemorySubsystem.scala 26:24]
  wire  direct_io_mem_mem_or_reg; // @[MemorySubsystem.scala 26:24]
  wire [3:0] direct_io_mem_wr_byte_en; // @[MemorySubsystem.scala 26:24]
  wire [31:0] direct_io_mem_addr; // @[MemorySubsystem.scala 26:24]
  wire [31:0] direct_io_mem_wr_d; // @[MemorySubsystem.scala 26:24]
  wire [31:0] direct_io_mem_rd_d; // @[MemorySubsystem.scala 26:24]
  wire  direct_io_mem_rd_rdy; // @[MemorySubsystem.scala 26:24]
  wire  direct_io_mem_busy; // @[MemorySubsystem.scala 26:24]
  wire  direct_io_mem_burst_wr_rdy; // @[MemorySubsystem.scala 26:24]
  wire  arbiter_clock; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_reset; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_in0_rd_req; // @[MemorySubsystem.scala 29:25]
  wire [31:0] arbiter_io_in0_addr; // @[MemorySubsystem.scala 29:25]
  wire [31:0] arbiter_io_in0_rd_d; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_in0_rd_rdy; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_in0_busy; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_in1_rd_req; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_in1_wr_req; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_in1_mem_or_reg; // @[MemorySubsystem.scala 29:25]
  wire [3:0] arbiter_io_in1_wr_byte_en; // @[MemorySubsystem.scala 29:25]
  wire [31:0] arbiter_io_in1_addr; // @[MemorySubsystem.scala 29:25]
  wire [31:0] arbiter_io_in1_wr_d; // @[MemorySubsystem.scala 29:25]
  wire [31:0] arbiter_io_in1_rd_d; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_in1_rd_rdy; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_in1_busy; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_in1_burst_wr_rdy; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_out_rd_req; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_out_wr_req; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_out_mem_or_reg; // @[MemorySubsystem.scala 29:25]
  wire [3:0] arbiter_io_out_wr_byte_en; // @[MemorySubsystem.scala 29:25]
  wire [5:0] arbiter_io_out_rd_num_dwords; // @[MemorySubsystem.scala 29:25]
  wire [31:0] arbiter_io_out_addr; // @[MemorySubsystem.scala 29:25]
  wire [31:0] arbiter_io_out_wr_d; // @[MemorySubsystem.scala 29:25]
  wire [31:0] arbiter_io_out_rd_d; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_out_rd_rdy; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_out_busy; // @[MemorySubsystem.scala 29:25]
  wire  arbiter_io_out_burst_wr_rdy; // @[MemorySubsystem.scala 29:25]
  wire  SimpleRAM_clock; // @[MemorySubsystem.scala 35:31]
  wire [31:0] SimpleRAM_io_bus_addr; // @[MemorySubsystem.scala 35:31]
  wire [31:0] SimpleRAM_io_bus_rd_d; // @[MemorySubsystem.scala 35:31]
  wire  SimpleRAM_io_bus_we; // @[MemorySubsystem.scala 35:31]
  wire [31:0] SimpleRAM_io_bus_wr_d; // @[MemorySubsystem.scala 35:31]
  ICache cache ( // @[MemorySubsystem.scala 22:23]
    .clock(cache_clock),
    .reset(cache_reset),
    .io_flush_all(cache_io_flush_all),
    .io_bus_cyc(cache_io_bus_cyc),
    .io_bus_stb(cache_io_bus_stb),
    .io_bus_we(cache_io_bus_we),
    .io_bus_addr(cache_io_bus_addr),
    .io_bus_ack(cache_io_bus_ack),
    .io_bus_data_rd(cache_io_bus_data_rd),
    .io_cache_mem_addr(cache_io_cache_mem_addr),
    .io_cache_mem_rd_d(cache_io_cache_mem_rd_d),
    .io_cache_mem_we(cache_io_cache_mem_we),
    .io_cache_mem_wr_d(cache_io_cache_mem_wr_d),
    .io_main_mem_rd_req(cache_io_main_mem_rd_req),
    .io_main_mem_addr(cache_io_main_mem_addr),
    .io_main_mem_rd_d(cache_io_main_mem_rd_d),
    .io_main_mem_rd_rdy(cache_io_main_mem_rd_rdy),
    .io_main_mem_busy(cache_io_main_mem_busy)
  );
  WishboneMemoryBridge direct ( // @[MemorySubsystem.scala 26:24]
    .clock(direct_clock),
    .reset(direct_reset),
    .io_bus_cyc(direct_io_bus_cyc),
    .io_bus_stb(direct_io_bus_stb),
    .io_bus_we(direct_io_bus_we),
    .io_bus_sel(direct_io_bus_sel),
    .io_bus_addr(direct_io_bus_addr),
    .io_bus_data_wr(direct_io_bus_data_wr),
    .io_bus_ack(direct_io_bus_ack),
    .io_bus_data_rd(direct_io_bus_data_rd),
    .io_mem_rd_req(direct_io_mem_rd_req),
    .io_mem_wr_req(direct_io_mem_wr_req),
    .io_mem_mem_or_reg(direct_io_mem_mem_or_reg),
    .io_mem_wr_byte_en(direct_io_mem_wr_byte_en),
    .io_mem_addr(direct_io_mem_addr),
    .io_mem_wr_d(direct_io_mem_wr_d),
    .io_mem_rd_d(direct_io_mem_rd_d),
    .io_mem_rd_rdy(direct_io_mem_rd_rdy),
    .io_mem_busy(direct_io_mem_busy),
    .io_mem_burst_wr_rdy(direct_io_mem_burst_wr_rdy)
  );
  MemoryArbiter arbiter ( // @[MemorySubsystem.scala 29:25]
    .clock(arbiter_clock),
    .reset(arbiter_reset),
    .io_in0_rd_req(arbiter_io_in0_rd_req),
    .io_in0_addr(arbiter_io_in0_addr),
    .io_in0_rd_d(arbiter_io_in0_rd_d),
    .io_in0_rd_rdy(arbiter_io_in0_rd_rdy),
    .io_in0_busy(arbiter_io_in0_busy),
    .io_in1_rd_req(arbiter_io_in1_rd_req),
    .io_in1_wr_req(arbiter_io_in1_wr_req),
    .io_in1_mem_or_reg(arbiter_io_in1_mem_or_reg),
    .io_in1_wr_byte_en(arbiter_io_in1_wr_byte_en),
    .io_in1_addr(arbiter_io_in1_addr),
    .io_in1_wr_d(arbiter_io_in1_wr_d),
    .io_in1_rd_d(arbiter_io_in1_rd_d),
    .io_in1_rd_rdy(arbiter_io_in1_rd_rdy),
    .io_in1_busy(arbiter_io_in1_busy),
    .io_in1_burst_wr_rdy(arbiter_io_in1_burst_wr_rdy),
    .io_out_rd_req(arbiter_io_out_rd_req),
    .io_out_wr_req(arbiter_io_out_wr_req),
    .io_out_mem_or_reg(arbiter_io_out_mem_or_reg),
    .io_out_wr_byte_en(arbiter_io_out_wr_byte_en),
    .io_out_rd_num_dwords(arbiter_io_out_rd_num_dwords),
    .io_out_addr(arbiter_io_out_addr),
    .io_out_wr_d(arbiter_io_out_wr_d),
    .io_out_rd_d(arbiter_io_out_rd_d),
    .io_out_rd_rdy(arbiter_io_out_rd_rdy),
    .io_out_busy(arbiter_io_out_busy),
    .io_out_burst_wr_rdy(arbiter_io_out_burst_wr_rdy)
  );
  SimpleRAM SimpleRAM ( // @[MemorySubsystem.scala 35:31]
    .clock(SimpleRAM_clock),
    .io_bus_addr(SimpleRAM_io_bus_addr),
    .io_bus_rd_d(SimpleRAM_io_bus_rd_d),
    .io_bus_we(SimpleRAM_io_bus_we),
    .io_bus_wr_d(SimpleRAM_io_bus_wr_d)
  );
  assign io_bus_cached_ack = cache_io_bus_ack; // @[MemorySubsystem.scala 23:18]
  assign io_bus_cached_err = 1'h0; // @[MemorySubsystem.scala 23:18]
  assign io_bus_cached_data_rd = cache_io_bus_data_rd; // @[MemorySubsystem.scala 23:18]
  assign io_bus_uncached_ack = direct_io_bus_ack; // @[MemorySubsystem.scala 27:19]
  assign io_bus_uncached_err = 1'h0; // @[MemorySubsystem.scala 27:19]
  assign io_bus_uncached_data_rd = direct_io_bus_data_rd; // @[MemorySubsystem.scala 27:19]
  assign io_cache_mem_addr = 32'h0;
  assign io_cache_mem_we = 1'h0;
  assign io_cache_mem_we_sel = 4'h0;
  assign io_cache_mem_wr_d = 32'h0;
  assign io_main_mem_rd_req = arbiter_io_out_rd_req; // @[MemorySubsystem.scala 32:20]
  assign io_main_mem_wr_req = arbiter_io_out_wr_req; // @[MemorySubsystem.scala 32:20]
  assign io_main_mem_mem_or_reg = arbiter_io_out_mem_or_reg; // @[MemorySubsystem.scala 32:20]
  assign io_main_mem_wr_byte_en = arbiter_io_out_wr_byte_en; // @[MemorySubsystem.scala 32:20]
  assign io_main_mem_rd_num_dwords = arbiter_io_out_rd_num_dwords; // @[MemorySubsystem.scala 32:20]
  assign io_main_mem_addr = arbiter_io_out_addr; // @[MemorySubsystem.scala 32:20]
  assign io_main_mem_wr_d = arbiter_io_out_wr_d; // @[MemorySubsystem.scala 32:20]
  assign cache_clock = clock;
  assign cache_reset = reset;
  assign cache_io_flush_all = io_flush_all; // @[MemorySubsystem.scala 24:24]
  assign cache_io_bus_cyc = io_bus_cached_cyc; // @[MemorySubsystem.scala 23:18]
  assign cache_io_bus_stb = io_bus_cached_stb; // @[MemorySubsystem.scala 23:18]
  assign cache_io_bus_we = io_bus_cached_we; // @[MemorySubsystem.scala 23:18]
  assign cache_io_bus_addr = io_bus_cached_addr; // @[MemorySubsystem.scala 23:18]
  assign cache_io_cache_mem_rd_d = SimpleRAM_io_bus_rd_d; // @[MemorySubsystem.scala 36:28 MemorySubsystem.scala 37:26]
  assign cache_io_main_mem_rd_d = arbiter_io_in0_rd_d; // @[MemorySubsystem.scala 30:20]
  assign cache_io_main_mem_rd_rdy = arbiter_io_in0_rd_rdy; // @[MemorySubsystem.scala 30:20]
  assign cache_io_main_mem_busy = arbiter_io_in0_busy; // @[MemorySubsystem.scala 30:20]
  assign direct_clock = clock;
  assign direct_reset = reset;
  assign direct_io_bus_cyc = io_bus_uncached_cyc; // @[MemorySubsystem.scala 27:19]
  assign direct_io_bus_stb = io_bus_uncached_stb; // @[MemorySubsystem.scala 27:19]
  assign direct_io_bus_we = io_bus_uncached_we; // @[MemorySubsystem.scala 27:19]
  assign direct_io_bus_sel = io_bus_uncached_sel; // @[MemorySubsystem.scala 27:19]
  assign direct_io_bus_addr = io_bus_uncached_addr; // @[MemorySubsystem.scala 27:19]
  assign direct_io_bus_data_wr = io_bus_uncached_data_wr; // @[MemorySubsystem.scala 27:19]
  assign direct_io_mem_rd_d = arbiter_io_in1_rd_d; // @[MemorySubsystem.scala 31:20]
  assign direct_io_mem_rd_rdy = arbiter_io_in1_rd_rdy; // @[MemorySubsystem.scala 31:20]
  assign direct_io_mem_busy = arbiter_io_in1_busy; // @[MemorySubsystem.scala 31:20]
  assign direct_io_mem_burst_wr_rdy = arbiter_io_in1_burst_wr_rdy; // @[MemorySubsystem.scala 31:20]
  assign arbiter_clock = clock;
  assign arbiter_reset = reset;
  assign arbiter_io_in0_rd_req = cache_io_main_mem_rd_req; // @[MemorySubsystem.scala 30:20]
  assign arbiter_io_in0_addr = cache_io_main_mem_addr; // @[MemorySubsystem.scala 30:20]
  assign arbiter_io_in1_rd_req = direct_io_mem_rd_req; // @[MemorySubsystem.scala 31:20]
  assign arbiter_io_in1_wr_req = direct_io_mem_wr_req; // @[MemorySubsystem.scala 31:20]
  assign arbiter_io_in1_mem_or_reg = direct_io_mem_mem_or_reg; // @[MemorySubsystem.scala 31:20]
  assign arbiter_io_in1_wr_byte_en = direct_io_mem_wr_byte_en; // @[MemorySubsystem.scala 31:20]
  assign arbiter_io_in1_addr = direct_io_mem_addr; // @[MemorySubsystem.scala 31:20]
  assign arbiter_io_in1_wr_d = direct_io_mem_wr_d; // @[MemorySubsystem.scala 31:20]
  assign arbiter_io_out_rd_d = io_main_mem_rd_d; // @[MemorySubsystem.scala 32:20]
  assign arbiter_io_out_rd_rdy = io_main_mem_rd_rdy; // @[MemorySubsystem.scala 32:20]
  assign arbiter_io_out_busy = io_main_mem_busy; // @[MemorySubsystem.scala 32:20]
  assign arbiter_io_out_burst_wr_rdy = io_main_mem_burst_wr_rdy; // @[MemorySubsystem.scala 32:20]
  assign SimpleRAM_clock = clock;
  assign SimpleRAM_io_bus_addr = cache_io_cache_mem_addr; // @[MemorySubsystem.scala 36:28 MemorySubsystem.scala 37:26]
  assign SimpleRAM_io_bus_we = cache_io_cache_mem_we; // @[MemorySubsystem.scala 36:28 MemorySubsystem.scala 37:26]
  assign SimpleRAM_io_bus_wr_d = cache_io_cache_mem_wr_d; // @[MemorySubsystem.scala 36:28 MemorySubsystem.scala 37:26]
endmodule
