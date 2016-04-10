/*
Author: Ian Gilman
Title: 32x32 File Register HW Tester
Summary: Create test stimulus for 32x32 file register, prints out logic results
*/

module file_register_tester(
         read0_data, 
         read1_data,
         clk, 
         we, 
         rst_all, 
         read0_addr, 
         read1_addr, 
         write_addr, 
         write_data
       );
   input wire [31:0] read0_data,  // data to be read from read0 address
                     read1_data;  // data to be read from read1 address
   output reg clk, we, rst_all;  // clock, write enable, low reset
   output reg [4:0] read0_addr,  // read0 register address selection
                    read1_addr,  // read1 register address selection
                    write_addr;  // write register address selection
   output reg [31:0] write_data;  // data to be written to write address
   
   // print out test results
   initial begin
         $display("\tRA0\tRD0     \tRA1\tRD1     \tWrA\tWrD     \twe \trst\tclk\ttime");
         $monitor("\t%h \t%h\t%h \t%h\t%h \t%h\t%b  \t%b  \t%b  \t%g",
                  read0_addr, read0_data, read01addr, read1_data, write_addr,
                  write_data, we, rst_all, clk, $time);
   end
   
   // create stimulus signals
   parameter delay = 1;
   integer i;
   initial begin
   
      // initial file register state
      clk = 1'b1;
      we = 1'b0;
      read0_addr = 5'b0;
      read1_addr = 5'b0;
      write_addr = 5'b0;
      write_data = 32'h0;
      rst_all = 1'b1;   #delay;
      rst_all = 1'b0;   #delay;
      rst_all = 1'b1;   #delay;
      for(i=0; i<2; i=i+1) begin
         clk = ~clk;    #delay;
      end
      
      // write data to register
      write_addr = 5'b1;
      write_data = 32'h5ADFACED;
      for(i=0; i<4; i=i+1) begin
         clk = ~clk;    #delay;
      end
      we = 1'b1;
      for(i=0; i<4; i=i+1) begin
         clk = ~clk;    #delay;
      end
      we = 1'b0;
      
      // second write
      write_addr = 5'b10101;
      write_data = 32'hEA770A57;
      for(i=0; i<4; i=i+1) begin
         clk = ~clk;    #delay;
      end
      we = 1'b1;
      for(i=0; i<4; i=i+1) begin
         clk = ~clk;    #delay;
      end
      we = 1'b0;
      
      // read both in read0 and read1
      read0_addr = 5'b1;
      for(i=0; i<4; i=i+1) begin
         clk = ~clk;    #delay;
      end
      read1_addr = 5'b10101;
      for(i=0; i<4; i=i+1) begin
         clk = ~clk;    #delay;
      end
      
      $finish;
   end
endmodule