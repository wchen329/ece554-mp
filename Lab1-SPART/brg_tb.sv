/* Baud Rate Generator
 * Unit test bench.
 */
module brg_tb();

	logic clk;
	logic rst;
	wire en;
	reg[15:0] full_baud;
	wire[7:0] baud_rate_drive;

	reg as;
	always #100 clk = ~clk;

	BRG DUT(.clk(clk), .start(rst), .div_hword(as), .div_in(baud_rate_drive), .enable(en));

	initial begin
		clk = 0;
		rst = 1;
		as = 0;
		full_baud = 9600;
		repeat(2)@(posedge clk);
		as = 1;	
		@(posedge clk) rst = 0;
		repeat(100) @(posedge clk);
		$stop;
	end

	assign baud_rate_drive = as ? full_baud[15:8] : full_baud[7:0];

endmodule
