#include <iostream>

short conv_in[3][3] = { 1, 2, 3, 4, 5, 6, 7, 8, 9 };
short coeffs_v[3][3];
short coeffs_h[3][3];

/* Convolution Algorith Reference Implementation
 * utilizing C++
 * wchen329
 */
int main()
{
	coeffs_v[0][0] = -1;
	coeffs_v[0][1] = 0;
	coeffs_v[0][2] = 1;
	coeffs_v[1][0] = -2;
	coeffs_v[1][1] = 0;
	coeffs_v[1][2] = 2;
	coeffs_v[2][0] = 1;
	coeffs_v[2][1] = 0;
	coeffs_v[2][2] = 1;

	coeffs_h[0][0] = -1;
	coeffs_h[0][1] = -2;
	coeffs_h[0][2] = -1;
	coeffs_h[1][0] = 0;
	coeffs_h[1][1] = 0;
	coeffs_h[1][2] = 0;
	coeffs_h[2][0] = 1;
	coeffs_h[2][1] = 2;
	coeffs_h[2][2] = 1;

	std::cout << "Performing convolution..." << std::endl;

	short y_v = 0; short y_h = 0;

	for(short m = 0; m < 3; m++)
	{
		for(short n = 0; n < 3; n++)
		{
			y_v += conv_in[2 - m][2 - n] * coeffs_v[m][n];
		}
	}

	for(short m = 0; m < 3; m++)
	{
		for(short n = 0; n < 3; n++)
		{
			y_h += conv_in[2 - m][2 - n] * coeffs_h[m][n];
		}
	}

	std::cout << "------------------------" << std::endl;
	std::cout << "--  REFERENCE VALUES  --" << std::endl;
	std::cout << "------------------------" << std::endl;
	std::cout << "y (vert.): " << y_v << std::endl;
	std::cout << "y (horz.): " << y_h << std::endl;
	std::cin.get();

	return 0;
}