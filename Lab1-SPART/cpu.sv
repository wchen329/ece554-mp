/* CPU
 * A "fake" CPU
 * That just holds an 8-bits of data (a.k.a. a BYTE) and sends them out on a data bus
 * wchen329 
 *
 * DATABUS - used to transfer data between processor and SPART
 * IOADDR - specific register number address
 * BAUD_SEL - baud rate selection
 */
module cpu(input clk, input rst, output iocs, iorw, input[1:0] baud_sel, rda, tbr, output [1:0] ioaddr, inout[7:0] databus);

	// Baudrate Codes
	typedef enum {
		BR_4800 = 2'd0,
		BR_9600 = 2'd1,
		BR_19200 = 2'd2,
		BR_38400 = 2'd3
	} br_select_code;

	// Register Names
	typedef enum
	{
		TRANSMIT = 2'b00,
		STATUS = 2'b01,
		LOW_DIV_BUF = 2'b10,
		HI_DIV_BUF = 2'b11
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
	reg[15:0] bbr_buf; // this holds the base baud rate value. Set it by multiplexer.
	reg[1:0] ishhw;

	always @(posedge clk) begin
		
		if(rst) begin
			write_read_op <= READ;
			buffer <= 8'd0;
			ishhw <= 2'b00;
			
			bbr_buf <=	baud_sel == BR_4800 ? 4800 :
					baud_sel == BR_9600 ? 9600 :
					baud_sel == BR_19200 ? 19200 : 38400;
		end

		// Still setting up
		else if(ishhw < 2'b10) begin
			ishhw++;
		end

		else begin

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

	// Static assignments

	// If just reset, drive data bus with baud rate
	// Afterwards...
	// If reading, then CPU shouldn't be driving the bus.
	// If writing, then CPU should be driving the bus
	assign databus =	ishhw == 2'b00 ? baud_sel[7:0] : // Low Half Word first
				ishhw == 2'b01 ? baud_sel[15:8] : // Then High Half Word
				rda ? {8{1'bz}} : // Read Ready
				tbr ? buffer :	// Write Ready
				{8{1'bz}};

	// Tie chip select to one
	assign iocs = 1'b1;
	assign iorw = write_read_op;

	// Register selection
	assign ioaddr =  	ishhw == 2'b00 ? LOW_DIV_BUF :
				ishhw == 2'b01 ? HI_DIV_BUF : 
				tbr || rda ? TRANSMIT :
			 	~tbr & ~rda  ? STATUS : 2'd0;

endmodule
