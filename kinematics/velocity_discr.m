function V=velocity_discr(A,sigma)
% VELOCITY: calculates the velocity for one axis, without time-shift
% Synopsis
%		v=velocity_discr(A,sigma)
% Description
%		A is a vector of position data (one dimensional)
%		if sigma is given, the data will be smoothed with
%		a gaussian kernel (SD=sigma) 
%		v is a Vector of the velocity
V=[A(2,:)-A(1,:);...
        (A(3:end,:)-A(1:end-2,:))/2;...
        A(end,:)-A(end-1,:)];
if (nargin>1 & sigma>0)
    V=smooth_kernel(V,sigma);
end;
