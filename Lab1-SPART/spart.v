/* SPART
 * a.k.a. Serial Port
 * This module encapsulates the SPART implementation.
 */
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

	wire [7:0] rx_data;
	wire [7:0] tx_data;
	wire [7:0] div_in;
	wire brg_rst;
	wire [7:0] data;
	wire rx_rst;
	
	assign brg_rst = (rst == 1'b1 || (iocs == 1'b1 && iorw == 1'b0 && ioaddr[1] == 1'b1)) ? 1'b1 : 1'b0;
	
	parameter IDLE = 2'b00, ACTIVE = 2'b01;
	
	wire baud_en;
	wire tx_en;
	
	assign data = (ioaddr[0] == 1'b1) ? {6'b0, tbr, rda} : rx_data;
	
	assign databus = (iocs & iorw) ? data : 8'bZ;
	
	assign div_hword = (ioaddr == 2'b11) ? 1'b1 : 1'b0;
	
	assign div_in = databus;
	
	assign tx_en = ((iocs & ~iorw) && (ioaddr == 2'b00)) ? 1'b1 : 1'b0;
	
	assign rx_rst = rst | (iocs & iorw & (ioaddr == 2'b00));
	
	assign tx_data = (iocs & ~iorw) ? databus : 8'b0;
	
	shifter rx_shifter(rxd, clk, rx_rst, baud_en, rx_data, rda);
	
	shift_out tx_shifter(clk, rst, tx_en, baud_en, tx_data, txd, tbr);
	
	// Baud rate generator
	BRG brg(clk, brg_rst, div_hword, div_in, baud_en);

endmodule
