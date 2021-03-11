function [y] = pow2dB(x)
% x - in linear
% y - in dB
y = 10.*log10(x);
