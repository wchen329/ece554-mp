/* BRG
 * also known as "Baud Rate Generator"
 */
module BRG(input clk, start, div_hword, input[7:0] div_in, output enable);

	localparam HZ_PER_TERAHERTZ = 64'd1000000000000;

	// Frequency Counter
	reg[31:0] down_counter;
	reg[15:0] br; // division buffer

	// Phase Setting
	always @(posedge clk) begin
		
		// Reset the counter state to 0 (i.e. accept a new counter)
		if(start) begin		
			down_counter = 0;

			///////////////////
			// BASE REGISTER //
			///////////////////
			if(div_hword) begin
				br[15:8] = div_in;
			end
			else begin
				br[7:0] = div_in;
			end
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
