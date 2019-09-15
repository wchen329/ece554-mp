/* Mock CPU
 * A "fake" CPU
 * That just holds an 8-bits of data (a.k.a. a BYTE) and sends them out on a data bus
 * wchen329 
 */

module mock_cpu(input clk, input rst, input[7:0] bus_spart, input spart_data_ready, input out_ready, output[7:0] bus_out);

	// SPART Buffer
	logic[7:0] buffer;

	always @(posedge clk) begin
		if(rst) begin
			buffer <= 8'd0;
		end
			
		else begin
			if(spart_data_ready) begin
				buffer <= bus_spart;
			end
		end
	end

	// Static assignments
	assign bus_out = out_ready ? buffer : 8'd0;

endmodule
