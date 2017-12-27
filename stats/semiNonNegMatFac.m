function [F,G,Err2]=semiNonNegMatFac(X,k,varargin); 
% Semi-nonnegative matrix factorization 
% as in Ding & Jordan
% Joern Diedrichsen 
G0= []; 
threshold = 0.01; 
maxIter = 5000; 
vararginoptions(varargin,{'G0','threshold','maxIter'}); 
if (isempty(G0))
    g=kmeans(X,k); 
    G0 = indicatorMatrix('identity',g); 
end; 
df = inf; 
G=G0;
G(G<0.2)=0.2; 
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