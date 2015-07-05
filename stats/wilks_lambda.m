function [lambda,chistat,df,p]=wilks_lambda(QT,QE,dfT,dfE);
% function [lambda,X,df,p]=Wilks_lambda(QT,QE,n,m);
% Computes Wilks-lambda from 
% Treatment and Error VC-matrices
% INPUT: 
%   QT: Sum of squares for treatment effect 
%   QE: Sum of squares matrix for error term 
%   dfT: number of df for treatment
%   dfE: number of df for error term 
% Output: 
%   lambda: wilks lambda test stats 
%   chistat: Chi-square approximation 
%   df: df of X 
%   p: p-value of X 
p=size(QT,1); % number of variables 
L=eig(QT*inv(QE)); 
L=sort(L,1,'descend');
lambda=prod(1./(1+L(1:min(dfT,size(L,1)))));  % size(L,1) added post-hoc to be checked
chistat = -(dfE+dfT-(dfT+p+1)/2) .* log(lambda);
df = p*dfT; 
p = 1-chi2cdf(chistat, df);