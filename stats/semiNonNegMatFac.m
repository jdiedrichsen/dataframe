function [F,G,Info]=semiNonNegMatFac(X,k,varargin); 
% Semi-nonnegative matrix factorization 
% as in Ding & Jordan
% X: NxP Matrix of P observations to be clustered over N variables 
% X = F *G' 
% k: number of clusters 
% Joern Diedrichsen 
G0= [];                 % Startibg value (otherwise uses Kmeans + 0.2)
threshold = 0.01;       % Threshold on reconstruction error 
maxIter = 5000;         % Maximal number of iterations 
normaliseF = 1;         % Normalise F to unit vectors afterwards?
vararginoptions(varargin,{'G0','threshold','maxIter','normaliseF'}); 
if (isempty(G0))
    g=kmeans(X',k); 
    G0 = indicatorMatrix('identity',g); 
end; 
df = inf; 
G=G0+0.2;       % Starting values of the floor 
n=1; 
while df>threshold 
    F=X*pinv(G'); 
    R = X-F*G'; 
    Err1(n)=sum(sum(R.*R)); 
    A=X'*F; 
    B=F'*F;
    Ap = (abs(A)+A)/2; 
    Am = (abs(A)-A)/2; 
    Bp = (abs(B)+B)/2; 
    Bm = (abs(B)-B)/2; 
    V=((Ap+G*Bm)./(Am+G*Bp));   % Update rule Eq. (8) 
    if (any(isnan(V(:))))
        keyboard;  % Check update stability....
    end; 
    if (any(V(:)<0)); 
        keyboard;
    end; 
    G= G.*sqrt(V); 
    R = X-F*G'; 
    Err2(n)=sum(sum(R.*R)); 
    if (n>1) 
        df=Err2(n-1)-Err2(n); 
    end; 
    n=n+1; 
end; 

% If necessary, normalize vectors in F to unity afterwards 
if (normaliseF) 
    f=sqrt(sum(F.^2)); % Factor for normalisation 
    F=bsxfun(@times,F,1./f); 
    G=bsxfun(@times,G,f);  % Normalise the group factor the other way
end; 

% Provide fitting info 
Info.numiter = n-1; 
Info.error   = Err2(end); 