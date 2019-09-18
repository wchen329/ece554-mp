module shifter(input nxt_bit, input clk, input rst, input en, output [7:0]data, output has_data);
	reg [7:0] shifter_data;
	reg [7:0] buffer;
	reg [3:0] count;
	reg full;
	
	assign data = buffer;
	assign has_data = full;
	
	always @(posedge clk) begin
		if (rst) begin
			shifter_data <= 8'b0;
			buffer <= 8'b0;
			full <= 1'b0;
			count <= 4'b0;
		end
		else if (en) begin
			if (count < 4'd8 && full == 1'b0) begin
				count <= count + 4'd1;
				shifter_data <= {shifter_data[6:0], nxt_bit};
			end
			else begin
				buffer <= shifter_data;
				full <= 1'b1;
			end
		end
	end

endmodule