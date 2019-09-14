//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input clk,
    input rst,
    input iocs,
    input iorw,
    output rda,
    output tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    output txd,
    input rxd
    );

	wire data;
	wire sample_en, bit_en;
	
	parameter IDLE = 2'b00, ACTIVE = 2'b01;
	reg rx_state;
	reg [15:0] rx_state_count;
	reg rx_nxt_state;
	
	reg shifter;
	wire nxt_bit;
	
	assign databus = (iocs & ~iorw) ? data : 8'bZ;
	
	always @* begin
		if (ioaddr == 2'b01 && iorw == 1'b1)
			data = // TODO
			
	
	end
	
	always@(posedge clk) begin
		if (rst)
			rx_state <= IDLE; 
		else
			rx_state <= rx_nxt_state;
			
	always@(posedge clk) begin
		if (rst)
			shifter <= 8'b0;
		else
			shifter <= nxt_bit;
	
	always@(posedge clk)
		if (sample_en) begin
			case(rx_state)
				IDLE:
					if (rxd == 1'b0) begin
						rx_state_count <= rx_state_count + 1;
					end
					else begin
						rx_state_count <= (rx_state_count == 16'b0) ? 16'b0 : (rx_state_count - 1);
					end
					if (rx_state_count > 16'd8)
						rx_nxt_state <= ACTIVE;
					else
						rx_nxt_state <= IDLE;
				ACTIVE:
					if (rxd == 1'b0) begin
						
					end
			endcase
		end
	
	//Counter
	

endmodule
