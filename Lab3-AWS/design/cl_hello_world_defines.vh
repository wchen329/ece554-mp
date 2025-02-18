// Amazon FPGA Hardware Development Kit
//
// Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License"). You may not use
// this file except in compliance with the License. A copy of the License is
// located at
//
//    http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
// implied. See the License for the specific language governing permissions and
// limitations under the License.

`ifndef CL_HELLO_WORLD_DEFINES
`define CL_HELLO_WORLD_DEFINES

// Registers for our new "Hello World" Convolution
`define CONV_IN_0_REG_ADDR    32'h0000_0508
`define CONV_IN_1_REG_ADDR    32'h0000_050C
`define CONV_IN_2_REG_ADDR    32'h0000_0510
`define CONV_IN_3_REG_ADDR    32'h0000_0514
`define CONV_IN_4_REG_ADDR    32'h0000_0518
`define CONV_IN_5_REG_ADDR    32'h0000_051C
`define CONV_IN_6_REG_ADDR    32'h0000_0520
`define CONV_IN_7_REG_ADDR    32'h0000_0524
`define CONV_IN_8_REG_ADDR    32'h0000_0528
`define CONV_MODE_REG_ADDR    32'h0000_052C

//Put module name of the CL design here.  This is used to instantiate in top.sv
`define CL_NAME cl_hello_world

//Highly recommeneded.  For lib FIFO block, uses less async reset (take advantage of
// FPGA flop init capability).  This will help with routing resources.
`define FPGA_LESS_RST

// Uncomment to disable Virtual JTAG
//`define DISABLE_VJTAG_DEBUG



`endif
