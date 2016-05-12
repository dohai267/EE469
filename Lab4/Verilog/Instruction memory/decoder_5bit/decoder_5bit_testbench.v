
// Module Dependencies:
`include "../shared_modules/mux_2to1/mux_2to1.v"
`include "decoder_5bit.v"
`include "decoder_5bit_tester.v"

/*
Author: Ian Gilman
Title: testbench for 5-bit decoder
Summary: Test module for 5-bit decoder 
*/

module decoder_5bit_testbench();
   wire [4:0] code;
   wire [31:0] selection;
   
   // DUT & Tester
   decoder_5bit decoder(.code(code), .selection(selection));
   decoder_5bit_tester tester(.selection(selection), .code(code));

   // create wave data file
   initial begin
      $dumpfile("decoder_5bit.vcd");
      $dumpvars(1, decoder);
   end
endmodule