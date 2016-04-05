// Title:  4-bit Synchronous Up Counter
// Author: Adolfo Pineda
// This module is the 4-bit synchrounous up counter with active low reset

module SupCounter(q0, q1, q2, q3, clk, rst);
input clk, rst;
output wire q0, q1, q2, q3;
	
	// Counter Logic
	assign D0 = ~q0;
	assign D1 = q0 ^ q1;
	assign D2 = (q0 & q1) ^ q2;
	assign D3 = (q2 & q1 & q0) ^ q3;
		
	// Synchronized flip flops that do the counting	
	DFlipFlop d1(.q(q0), .qBar(), .D(D0), .clk(clk), .rst(rst));
	DFlipFlop d2(.q(q1), .qBar(), .D(D1), .clk(clk), .rst(rst));
	DFlipFlop d3(.q(q2), .qBar(), .D(D2), .clk(clk), .rst(rst));
	DFlipFlop d4(.q(q3), .qBar(), .D(D3), .clk(clk), .rst(rst));

endmodule 