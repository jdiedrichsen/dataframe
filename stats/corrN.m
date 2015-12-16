function r=corrN(X,Y)
% function r=corrN(X,Y)
% Correlation without intercept subtracted, 
% resulting in a normalised cross product  
if (nargin==1) 
    COV=X'*X;
    r=corrcov(COV); 
else 
    r=X'*Y./(sqrt(X'*X)*sqrt(Y'*Y));
end; 