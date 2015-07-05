function V=circvelocity(Y,sigma)
% calculates the circular velocity
% while taking care of flips 
% between 0 and 360 degrees 
% this is in radians
% see circ_velocity_deg for degrees
A=unwrap(Y);
V=[A(2)-A(1);...
        (A(3:end)-A(1:end-2))/2;...
        A(end)-A(end-1)];
if (nargin>1 & sigma>0)
    V=smooth_kernel(V,sigma);
end;
