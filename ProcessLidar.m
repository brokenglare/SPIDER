function [angle_rad distance] = ProcessLidar(angle, xvec)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
angle_rad = angle*pi/180;



distance = bitor( xvec(1) , (bitshift(bitand(xvec(2) , hex2dec('1f')),8)));
end
