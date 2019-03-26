function [F,G,Err,W]=cnvSemiNonNegMatFac(X,k,varargin); 
% Convex semi-nonnegative matrix factorization 
% as in Ding & Jordan
% Joern Diedrichsen 
G0= []; 
threshold = 0.001;
maxIter = 5000; 
vararginoptions(varargin,{'G0','threshold','maxIter'}); 
if (isempty(G0))
    g=kmeans(X,k); 
    G0 = indicatorMatrix('identity',g); 
end; 
df = inf; 
G=G0;

% Initialization 
G=G+0.2; 
n=1;
W = G/(G0'*G0); 
if (any(W<0))
    keyboard; 
end; 
Err(n)=sum(sum((X-X*W*G').^2)); 

% Initialize computation 
A=X'*X; 
Ap = (abs(A)+A)/2; 
Am = (abs(A)-A)/2; 
clear A; 

while df>threshold && n<maxIter 
    Vg=(Ap*W+G*W'*Am*W)./(Am*W+G*W'*Ap*W);
    G=G.*sqrt(Vg); 
    Vw=(Ap*G+Am*W*(G'*G))./(Am*G+Ap*W*(G'*G)); 
    W=W.*sqrt(Vw); 
    R = X-X*W*G'; 
    n=n+1; 
    Err(n)=sum(sum(R.*R)); 
    df=Err(n-1)-Err(n); 
end; 

F=X*W; 