function [F,G,Info,W,Err]=cnvSemiNonNegMatFac(X,k,varargin); 
% Convex semi-nonnegative matrix factorization 
% as in Ding & Jordan
% Joern Diedrichsen 
G0= []; 
threshold = 0.001;
maxIter = 5000; 
normaliseF=1; 
vararginoptions(varargin,{'G0','threshold','maxIter','normaliseF'}); 
if (isempty(G0))
    g=kmeans(X',k); 
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
    ApW = Ap*W; 
    AmW = Am*W; 
    GW  = G*W'; 
    Vg=(ApW+GW*AmW)./(AmW+GW*ApW);
    G=G.*sqrt(Vg); 
    GG=G'*G; 
    Vw=(Ap*G+Am*W*GG)./(Am*G+Ap*W*GG); 
    W=W.*sqrt(Vw); 
    R = X-X*W*G'; 
    n=n+1; 
    Err(n)=sum(sum(R.*R)); 
    df=Err(n-1)-Err(n); 
end; 

F=X*W; 

if (normaliseF) 
    f=sqrt(sum(F.^2)); % Factor for normalisation 
    F=bsxfun(@times,F,1./f); 
    G=bsxfun(@times,G,f);  % Normalise the group factor the other way
end; 

Info.numiter = n;  
Info.error=Err(end); 
