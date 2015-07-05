function [N,Z]=kernel_est2D(x,y,z,X,Y,sigma);
% function [Z,N]=kernel_est2D(x,y,z,X,Y,sigma);
% Gives a kernel estimate of the underlying density and undlerlying function z 
% INPUT: 
%   x: x-value of observation (Px1 vector)
%   y: y-value of observation (Px1 vector)
%   z: z-value of observation (Px1 vector): if z is empty, only density is returned
%   X: Meshgrid representation of X-coordinates 
%   Y: Meshgrid representation of Y-coordinates 
%   sigma: [SDx SDy], standard deviation of gaussian kernel in units of x
%   and y
% OUTPUT:
%   Z Kernel estimate of unlerlying values Z
%   N density estimate of the process (x,y)
if (~isempty(z))
    [num_nodes,num_cols]=size(z);
else
    [num_nodes,num_cols]=size(x);
end;    

Kernel=normpdf([0:0.05:3.5],0,1)';
for i=1:length(X(:))
    d=[(x-X(i))/sigma(1) (y-Y(i))/sigma(2)];
    w=1/(2*pi).^(-2/2).*(sigma(1)*sigma(2)).^(-1/2).*exp(-1/2*sum(d.^2,2)); 
    N(i)=sum(w);
    if (~isempty(z) && N(i)>0)
        Z(i)=sum(z(indx,:).*w)./sum(w);
    else 
        Z(i)=NaN;
    end;
end;
if (~isempty(z))
    Z=reshape(Z,size(X));
end;
N=reshape(N,size(X));
