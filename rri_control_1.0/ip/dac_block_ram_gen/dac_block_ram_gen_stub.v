// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Fri Dec  2 11:16:50 2022
// Host        : damir-VivoBook-ASUSLaptop-X512DK-X512DK running 64-bit Ubuntu 22.04.1 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/damir/Downloads/RRI_Control/rri_control_1.0/ip/dac_block_ram_gen/dac_block_ram_gen_stub.v
// Design      : dac_block_ram_gen
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module dac_block_ram_gen(clka, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[15:0],dina[13:0],clkb,addrb[15:0],doutb[13:0]" */;
  input clka;
  input [0:0]wea;
  input [15:0]addra;
  input [13:0]dina;
  input clkb;
  input [15:0]addrb;
  output [13:0]doutb;
endmodule
