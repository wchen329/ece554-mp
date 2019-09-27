/* Small auto testbench for Convolution Filter
 * Conv. Filter
 */
module Convolution_Filter_tb();

	wire[11:0] out;

	// Test Inputs
	reg inp;
	reg clk;
	reg[11:0]X_INS [8:0];
	always #10 assign clk = ~clk;
	
	// DUT
	Convolution_Filter DUT(clk, inp, X_INS[0], X_INS[1], X_INS[2], X_INS[3], X_INS[4], X_INS[5], X_INS[6], X_INS[7], X_INS[8], out);

	/* Execution
	 */
	initial begin

		// Set clock signal
		clk = 1'b0;
		inp = 1'b0;

		// Set inputs
		X_INS[0] = 12'd1;
		X_INS[1] = 12'd2;
		X_INS[2] = 12'd3;
		X_INS[3] = 12'd4;
		X_INS[4] = 12'd5;
		X_INS[5] = 12'd6;
		X_INS[6] = 12'd7;
		X_INS[7] = 12'd8;
		X_INS[8] = 12'd9;

		// Change to horizontal
		@(posedge clk) inp = 1'b1;
		@(posedge clk);
		$stop;
	end

endmodule
