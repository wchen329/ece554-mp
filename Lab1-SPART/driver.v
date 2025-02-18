/* Driver
 * The "driver" is a simple interface to the CPU-FSM module
 */
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
