// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Sat Jan  8 23:28:04 2022
// Host        : DESKTOP-JT8UKI2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub c:/amiv4/fpga/fpga.srcs/sources_1/ip/clk_gen/clk_gen_stub.v
// Design      : clk_gen
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_gen(clk_out1, clk_out2, clk_out3, resetn, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,clk_out2,clk_out3,resetn,clk_in1" */;
  output clk_out1;
  output clk_out2;
  output clk_out3;
  input resetn;
  input clk_in1;
endmodule
