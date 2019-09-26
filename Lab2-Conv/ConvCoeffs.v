/* ConvCoeffs
 * Convolution coefficients. The exact coefficients can be selected through
 * the HorzSel signal.
 *
 * The coefficients are arranged in the array as
 * 0, 1, 2
 * 3, 4, 5
 * 6, 7, 8
 * isHorz - HIGH output horizonal filter, LOW output vertical filter
 */
module ConvCoeffs(	input clk,
			input isHorz,
			output COEFF_0[11:0],
			output COEFF_1[11:0],
			output COEFF_2[11:0].
			output COEFF_3[11:0],
			output COEFF_4[11:0],
			output COEFF_5[11:0],
			output COEFF_6[11:0].
			output COEFF_7[11:0],
			output COEFF_8[11:0]
		):

	// Coeffficient 0
	assign COEFF_0 =	-12'd1;

	// Coefficient 1
	assign COEFF_1 =	isHorz ? -12'd2 : 12'd0;

	// Coefficient 2
	assign COEFF_2 =	isHorz ? -12'd1 : 12'd1;

	// Coefficient 3
	assign COEFF_3 =	isHorz ? 12'd0 : 12'd2;

	// Coefficient 4
	assign COEFF_4 =	0;

	// Coefficient 5
	assign COEFF_5 =	isHorz ? 12'd0 : 12'd2;

	// Coefficient 6
	assign COEFF_6 =	isHorz ? 12'd1 : 12'd1;

	// Coefficient 7
	assign COEFF_7 =	isHorz ? 12'd2 : 12'd0;
	
	// Coefficient 8
	assign COOEF_8 =	isHorz ? 12'd1 : 12'd1;

endmodule
