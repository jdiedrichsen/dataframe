function [F,G,Info,W,Err]=cnvSemiNonNegMatFac(X,k,varargin); 
% Convex semi-nonnegative matrix factorization 
% as in Ding & Jordan
% Joern Diedrichsen 
F0= []; 
G0 = []; 
threshold = 0.001;
maxIter = 5000; 
normaliseF=1; 
vararginoptions(varargin,{'F0','G0','threshold','maxIter','normaliseF'}); 
if (isempty(F0) && isempty(G0))
    g=kmeans(X',k); 
    G0 = indicatorMatrix('identity',g); 
    G=G0+0.2;       % Starting values of the floor 
    W = G/(G'*G); 
    if (any(W(:)<0))
        keyboard; 
    end; 
elseif (~isempty(G0))
    scaleG = sum(abs(G0(:)))/sum(G0(:)>0);
    G=G0+0.2*scaleG; 
    W = G/(G'*G);
    W(W<0)=0; 
    scaleW = sum(abs(W(:)))/sum(W(:)>0);
    W = W +0.2*scaleW; 
else 
    error('F0 setting not supported yet'); 
end;

% Initialization 
n=1;
df = inf; 
Err(n)=sum(sum((X-X*W*G').^2)); 

% Initialize computation 
A  = single(X'*X); 
Ap = (abs(A)+A)/2; 
Am = (abs(A)-A)/2; 
clear A; 

while df>threshold && n<maxIter 
    ApW = Ap*W; 
    AmW = Am*W; 
    Vg=(ApW+G*(W'*AmW))./(AmW+G*(W'*ApW));
    G=G.*sqrt(Vg); 
    GG=G'*G; 
    Vw=(Ap*G+AmW*GG)./(Am*G+ApW*GG); 
    W=W.*sqrt(Vw); 
    R = X-X*W*G'; 
    n=n+1; 
    Err(n)=sum(sum(R.*R)); 
    df=Err(n-1)-Err(n); 
    if (mod(n,10)==0)
        fprintf('.'); 
    end; 
end; 
fprintf('.\n'); 

F=X*W; 

if (normaliseF) 
    f=sqrt(sum(F.^2)); % Factor for normalisation 
    F=bsxfun(@times,F,1./f); 
    G=bsxfun(@times,G,f);  % Normalise the group factor the other way
end; 

Info.numiter = n;  
Info.error=Err(end); 
