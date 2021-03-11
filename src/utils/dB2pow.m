function [y] = dB2pow(x)
% x - in dB
% y - in linear
y = 10.^(x./10);
