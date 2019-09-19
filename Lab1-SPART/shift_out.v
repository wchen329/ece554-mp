module shift_out(input clk, input rst, input en, input baud_en, input [7:0]data, output out, output tbr);
	reg [9:0] buffer;
	reg [3:0] bit_counter;
	reg [3:0] counter;
	reg r_tbr;
	reg r_out;
	
	assign out = r_out;
	assign tbr = r_tbr;
	
	always @(posedge clk) begin
		if (rst) begin
			buffer <= 10'b0;
			counter <= 4'b0;
			bit_counter <= 4'b0;
			r_tbr <= 1'b1;
			r_out <= 1'b1;
		end
		else if (en) begin
			buffer <= {1'b1, data, 1'b0};
			bit_counter <= 4'd10;
			counter <= 4'd15;
			r_tbr <= 1'b0;
		end
		else if (bit_counter > 4'b0) begin
			if (baud_en) begin
				if (counter > 4'd0) begin
					counter <= counter - 4'd1;
				end
				else begin
					bit_counter <= bit_counter - 4'd1;
					counter <= 4'd15;
					r_out <= buffer[0];
					buffer <= {buffer[0], buffer[9:1]};
				end
			end
		end
		else begin
			r_out <= 1'b1;
			r_tbr <= 1'b1;
		end
	end
	
endmodule
