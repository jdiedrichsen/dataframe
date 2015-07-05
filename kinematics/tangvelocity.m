function [v,V]=tangvelocity(A,sigma)
% TANGVELOCITY: calculates the tangential velocity from position data
% Synopsis
%		[v,V]=tangvelocity(A,sigma)
% Description
%		A is a two (x,y) or three-column (x,y,z) matrix of position data
%		if sigma is given, the data will be smoothed with
%		a gaussian kernel (SD=sigma) 
%		v is a Vector of the tangential velocity
%       V is a A-sizedmatrix of signed component velocity
%       uses velocity_discr 
% Joern Diedrichsen (jdiedric@jhu.edu)
% v.1.0 09/13/05

[N,col]=size(A);
if(nargin==1)
    for c=1:col
	    V(:,c)=velocity_discr(A(:,c));
    end;
else
    for c=1:col
	    V(:,c)=velocity_discr(A(:,c),sigma);
    end;
end;
v=sqrt(sum((V.^2)')'); 

