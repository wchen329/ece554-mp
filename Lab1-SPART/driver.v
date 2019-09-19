//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    driver 
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
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output iocs,
    output iorw,
    input rda,
    input tbr,
    output [1:0] ioaddr,
    inout [7:0] databus
    );

	// Instantiate CPU to harness
	cpu CPU0(	.clk(clk),
			.rst(rst),
			.iocs(iocs),
			.iorw(iorw),
			.baud_sel(br_cfg),
			.rda(rda),
			.tbr(tbr),
			.ioaddr(ioaddr),
			.databus(databus));

endmodule
