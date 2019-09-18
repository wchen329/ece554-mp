module BRG(input clk, start, input[31:0] bbase, output enable);

	localparam HZ_PER_TERAHERTZ = 64'd1000000000000;

	// Frequency Counter
	reg[31:0] down_counter;
	reg[31:0] br;

	// Phase Setting
	always @(posedge clk) begin
		
		// Reset the counter state to 0 (i.e. accept a new counter)
		if(start) begin		
			down_counter = 0;

			///////////////////
			// BASE REGISTER //
			///////////////////
			br = bbase;
		end

		// Otherwise, go set the down counter register and the base register
		else begin		

			///////////////////////////
			// DOWN COUNTER REGISTER //
			///////////////////////////

			// Set it to the maximum value if currently 0
			if(down_counter == 0) begin
				down_counter <= (((HZ_PER_TERAHERTZ/clk) / ((1 << 4) * br)) + 1);
			end

			// Otherwise, decrement
			else begin
				down_counter <= (down_counter - 1); 
			end
		end
	end

	// Static asignments
	assign enable = down_counter == 0 ? 1'b1 : 1'b0; // enabled to count down again, any time the counter is 0.

endmodule
