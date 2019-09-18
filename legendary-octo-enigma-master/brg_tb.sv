module brg_tb();

	logic clk;
	logic rst;
	wire en;

	always #1000 clk = ~clk;

	BRG DUT(.clk(clk), .start(rst), .bbase(9600), .enable(en));

	initial begin
		clk = 0;
		rst = 1;
		repeat(2) @(posedge clk)
		rst = 0;
		repeat(100) @(posedge clk);
		$stop;
	end

endmodule
