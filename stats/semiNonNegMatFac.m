function [F,G,Err]=semiNonNegMatFac(X,k,varargin); 
% Semi-nonnegative matrix factorization 
% as in Ding & Jordan
% Joern Diedrichsen 
G0= []; 
threshold = 0.01; 
vararginoptions(varargin,'G0'); 
if (isempty(G0))
    g=kmeans(X,k); 
    G0 = indicatorMatrix('identity',g); 
end; 
df = inf; 
G=G0; 
n=1; 
while df>threshold 
    F=X*pinv(G'); 
    res = X-F*G'; 
    Err1(n)=sum(sum(res.^2)); 
    A=X'*F; 
    B=F'*F;
    Ap = A; Ap(Ap<0)=0; 
    Am = A; Am(Am>0)=0; 
    Bp = B; Bp(Bp<0)=0; 
    Bm = B; Bm(Bm>0)=0; 
    G=G.*sqrt((Ap+G*Bm)./(Am+G*Bp));   % Update rule Eq. (8) 
    res = X-F*G'; 
    Err2(n)=sum(sum(res.^2)); 
    if (n>1) 
        df=Err2(n-1)-Err2(n); 
    end; 
    n=n+1; 
end; 
keyboard; 