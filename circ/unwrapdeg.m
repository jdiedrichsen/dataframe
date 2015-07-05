function z=unwrapdeg(y)
% unwrap for 0-360 deg data 
z=unwrap(y/360*(2*pi))/(2*pi)*360;