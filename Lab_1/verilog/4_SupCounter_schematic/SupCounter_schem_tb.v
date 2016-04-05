// SupCounter.v
`include "SupCounter_schem.v"
`include "SupTester_schem.v"

module SupCounter_tb;
	// connect the two modules
	wire Q0, Q1, Q2, Q3, Clock, Reset;

// declare an instance of the module
	SupCounter sup (.Clock, .Reset, .Q0, .Q1, .Q2, .Q3);
	
// declare an instance of the testIt module
	supTester aTester (Clock, Reset, Q0, Q1, Q2, Q3);

// file for gtkwave
	initial begin
		$dumpfile("SupCounter.vcd");
		$dumpvars(1, sup);
		
	end
endmodule