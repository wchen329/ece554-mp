/* Convolution Sobel Filter
 * -
 * Sobel filter for convolution, takes 
 * in x values
 * puts out y values
 */
module Convolution_Filter(	input clk,
				input isHorz,
				input signed [11:0] X_p0,	//input[11:0] X_INn1n1,
				input signed [11:0] X_p1, //input[11:0] X_INz0n1,
				input signed [11:0] X_p2, //input[11:0] X_INp1n1,
				input signed [11:0] X_p3, //input[11:0] X_INn1z0,
				input signed [11:0] X_p4, //input[11:0] X_INz0z0,
				input signed [11:0] X_p5, //input[11:0] X_INp1z0,
				input signed [11:0] X_p6, //input[11:0] X_INn1p1,
				input signed [11:0] X_p7, //input[11:0] X_INz0p1,
				input signed [11:0] X_p8, //input[11:0] X_INp1p1,
				output signed [11:0] y
			);

	/* Convolution coefficients. The exact coefficients can be selected through
	 * the HorzSel signal.
	 *
	 * The coefficients are arranged in the array as
	 * 0, 1, 2
	 * 3, 4, 5
	 * 6, 7, 8
	 * isHorz - HIGH output horizonal filter, LOW output vertical filter
	 */
	
	// Wire declarations
	wire signed[11:0] COEFF_0;
	wire signed[11:0] COEFF_1;
	wire signed[11:0] COEFF_2;
	wire signed[11:0] COEFF_3;
	wire signed[11:0] COEFF_4;
	wire signed[11:0] COEFF_5;
	wire signed[11:0] COEFF_6;
	wire signed[11:0] COEFF_7;
	wire signed[11:0] COEFF_8;
	
	// Coeffficient 0
	assign COEFF_0 =	-12'd1;

	// Coefficient 1
	assign COEFF_1 =	isHorz ? -12'd2 : 12'd0;

	// Coefficient 2
	assign COEFF_2 =	isHorz ? -12'd1 : 12'd1;

	// Coefficient 3
	assign COEFF_3 =	isHorz ? 12'd0 : -12'd2;

	// Coefficient 4
	assign COEFF_4 =	12'd0;

	// Coefficient 5
	assign COEFF_5 =	isHorz ? 12'd0 : 12'd2;

	// Coefficient 6
	assign COEFF_6 =	12'd1;

	// Coefficient 7
	assign COEFF_7 =	isHorz ? 12'd2 : 12'd0;
	
	// Coefficient 8
	assign COEFF_8 =	12'd1;

	/* The actual convolution
	 * This convolution is completely combinational
	 */
	assign y =	X_p8 * COEFF_0 +
			X_p5 * COEFF_3 +
			X_p2 * COEFF_6 +
			X_p7 * COEFF_1 +
			X_p4 * COEFF_4 +
			X_p1 * COEFF_7 +
			X_p6 * COEFF_2 +
			X_p3 * COEFF_5 +
			X_p0 * COEFF_8;

endmodule
