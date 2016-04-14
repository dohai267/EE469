/*
Author: Adolfo Pineda
Title: 16-bit Parallel In/Out Register
Summary: 16 synchronous d flip-flops configured to operate as a parallel in/out,
   register with write enable and reset.
*/

// Module Dependencies:
//`include "../../shared_modules/d_flipflop/d_flipflop.v"

module register_16bit(clk, we, rst, D, Q);
   input wire clk, we, rst;  // clock, write enabled, active-low reset register
   input wire [15:0] D;  // parallel data to write
   output wire [15:0] Q;  // parallel data from register
   wire [15:0] parallel_write_data;  // parallel data to register
   
   // write new data to register if write is enabled, else keep same data
   assign parallel_write_data = we ? D : Q;
   
   // register of 16 d flip-flops
   genvar i;
   generate for(i=0; i<16; i=i+1) begin: REGISTER
      d_flipflop FF(.q(Q[i]), .qBar(), .D(parallel_write_data[i]), .clk(clk), .rst(rst));
   end
   endgenerate
endmodule