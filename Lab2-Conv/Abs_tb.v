module Abs_tb();

	reg clk; // "clock" signal, used to change testbench input
	reg[11:0] stimulus;
	wire[11:0] test;
	Abs DUT(.in(stimulus), .out(test));
	always #10 assign clk = ~clk;

	initial begin
		clk = 1'b0;
		stimulus = 12'd0;
		@(posedge clk);
		if(test != 12'd0) $display("Error: out value is incorrect");
		stimulus = 12'd100;
		@(posedge clk);
		if(test != 12'd100) $display("Error: out value is incorrect, got %d expected 100", test);
		stimulus = -12'd120;
		@(posedge clk);
		if(test != 12'd120) $display("Error: out value is incorrect, got %d expected 120", test);
		$stop;
	end

endmodule

