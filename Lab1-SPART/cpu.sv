/* CPU
 * A "fake" CPU
 * That just holds an 8-bits of data (a.k.a. a BYTE) and sends them out on a data bus
 * wchen329 
 *
 * DATABUS - used to transfer data between processor and SPART
 * IOADDR - specific register number address
 */
module cpu(input clk, input rst, output iocs, input rda, tbr, iorw, output [1:0] ioaddr, inout[7:0] databus);

	// Helper Wires

	// Register Names
	typedef enum
	{
		ZERO,
		ONE,
		TWO,
		THREE

	} register_name;

	// Read or Write
	typedef enum
	{
		READ = 1'b1,
		WRITE = 1'b0
	} IOMode;

	// SPART Buffer
	logic[7:0] buffer;
	logic write_read_op;

	always @(posedge clk) begin
		
		if(rst) begin
			write_read_op <= READ;
			buffer <= 8'd0;
		end
		
		else begin
			// Only do more work if IO/CS is enabled. Otherwise, do nothing
			if(iorw) begin
			
				// If RDA is available, then read the value into the buffer
				if(rda) begin
					buffer <= databus;
					write_read_op <= READ; 
				end

				else if(tbr) begin
					write_read_op <= WRITE;
				end
			end
		end
	end

	// Static assignments

	// If reading, then CPU shouldn't be driving the bus.
	// If writing, then CPU should be driving the bus
	assign databus =	rda ? {8{1'bz}} : // Read Ready
				tbr ? buffer :	// Write Ready
				{8{1'bz}};

	// Tie chip select to one
	assign iocs = 1'b1;
	assign iorw = write_read_op;

endmodule
