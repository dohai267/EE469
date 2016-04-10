/*
Author: Ian Gilman
Title: Ripple Down Counter De1-SOC module
Summary: Connect down counter to the De1-SOC hardware
*/
module FourBitRC_de1soc_top(LEDR, CLOCK_50, SW);
	output [9:0] LEDR; // LEDs on board
	input CLOCK_50; // 50 Meg clock
	input [0:9] SW; // switches on board
	wire [31:0] clocks; // clocks divided from 50MHz
	parameter CLK_N = 5'd23; // individual clk to use as from 'clocks'
	
	// divide to get module system-clock
	clk_div frequency_divider(CLOCK_50, clocks);
	
	// Ripple down counter connected to Switch and LEDs
	FourBitRC down_count(
				.clk(clocks[CLK_N]), 
				.rst(SW[0]), 
				.q3(LEDR[3]), 
				.q2(LEDR[2]), 
				.q1(LEDR[1]),
				.q0(LEDR[0])
	);
endmodule



/*
Author: Ian Gilman
Title: Clock Divider
Summary: Provides a vector of 32, frequency-divided clocks based on an input clock
*/
module clk_div(orig_clk, div_clks);
	input wire orig_clk; // input clock
	output reg [31:0] div_clks; // divided clks:  f_divided_clks[n] = f_orig_clk * 2^(-n-1)

	// div_clk divided based on orig_clk positive pulse
	always @(posedge orig_clk) begin
		div_clks = div_clks + 1;
	end
endmodule