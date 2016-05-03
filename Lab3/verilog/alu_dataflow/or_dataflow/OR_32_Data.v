/*
Author  : Adolfo Pineda
Title   : 32-bit OR module
Summary : Uses an OR gate to OR together two 32-bit numbers. 
*/

module OR_32_Data(a, b, sum, zero, overflow, carryOut, negative);

	input wire [31:0] a, b; // input values
	output wire [31:0] sum; // output result
	output wire zero, overflow, carryOut, negative; 
	
	// Dataflow logic
	assign sum = a | b;
	assign zero = 0;
	assign overflow = 0;
	assign carryOut = 0;
	assign negative = 0;
	
endmodule