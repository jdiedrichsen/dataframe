function r=corrN(X,Y)
% function r=corrN(X,Y)
% Correlation without intercept subtracted, 
% resulting in a normalised cross product  
if (nargin==1) 
    COV=X'*X;
    r=corrcov(COV); 
else 
    ssX=sum(X.*X,1);
    ssY=sum(Y.*Y,1); 
    r=X'*Y./(sqrt(ssX')*sqrt(ssY));
end; 