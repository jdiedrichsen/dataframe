function [sy,v]=smooth_kernel(y,sigma);
% function [y,kernel]=smooth_kernel(y,sigma);
% runs a gaussian smoothing kernel over the data
% Does not introduce a time shift
% FWHM = 2 * sqrt(2*log(2)) * sigma
N=round(sigma*5)*2;
x=[1:N]';
v=normpdf(x,(N)/2,sigma);
[rows,cols]=size(y);
for c=1:cols
    pb(1:length(v)-1)=y(1,c);
    pe(1:length(v)-1)=y(end,c);
    x=[pb';y(:,c);pe'];
    sy(:,c)=conv(x,v);
end;
cut=round(1.5*N);
sy=sy(cut-1:end-cut+1,:);
