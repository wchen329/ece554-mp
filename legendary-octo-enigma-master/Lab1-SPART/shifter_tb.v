module shifter_tb();

reg clk;
reg rst;
reg nxt_bit;
reg en;
reg [7:0] collected;

wire [7:0] data;
wire has_data;

initial begin
clk = 0;
rst = 1;
nxt_bit = 0;
en = 0;
collected = 8'b0;
end

always #5 clk = ~clk;

always #10 nxt_bit = $random;

always #30 en = ~en;

always @(posedge clk) begin
	if (has_data) begin
		collected <= data;
		rst <= 1;
		en <= 0;
	end
	else begin
		rst <= 0;
	end
end

shifter s1( nxt_bit,  clk,  rst,  en,  data,  has_data);

endmodule
