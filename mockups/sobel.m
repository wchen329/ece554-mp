% Simple non-interactive
% reference implementation of Sobel algorithm
% wchen329
%
x = [1 2 3; 4 5 6; 7 8 9];
h_vert = [-1 0 1; -2 0 2; 1 0 1];
h_horz = [-1 -2 -1; 0 0 0; 1 2 1];

y_h_all = conv2(x, h_horz);
y_v_all = conv2(x, h_vert);

% What we're really testing among all three impls is just the convolution
% of the middle, so just print these
y_h_mid = y_h_all(3,3);
y_v_mid = y_v_all(3,3);

fprintf(1, "Value of Sobel (Horizontal 0s): %d\n", y_h_mid);
fprintf(1, "Value of Sobel (Vertical 0s): %d\n", y_v_mid);