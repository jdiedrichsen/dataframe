function Y=acceleration_discr(A,sigma)
% VELOCITY: calculates the velocity for one axis
% Synopsis
%		v=acceleration_discr(A,sigma)
% Description
%		A is a vector of position data (one or multi-dimensional)
%		(use cleandata first!)
%		if sigma is given, the data will be smoothed with
%		a gaussian kernel (SD=sigma) 
%		Y is a Vector of the acceleration
Y=[A(1,:)-2*A(2,:)+A(3,:);...
        A(1:end-2,:)-2*A(2:end-1,:)+A(3:end,:);...
        A(end-2,:)-2*A(end-1,:)+A(end,:)];
if (nargin>1 & sigma>0)
    Y=smooth_kernel(Y,sigma);
end;