function [theta,l]=logistic_regress(C,X)
% function [beta,l]=logistic_regress(c,X)
% INPUTS:
% c: vector of responces (0,1)
% X: design matrix 
% OUTPUT:
% beta: regression weights 
% l: likelihood 
[r,c]=size(X);
theta=zeros(c,1);
MAX_ITER=50;
% Put a stop on run-away theta<10
for it=1:MAX_ITER
    mu=logistic_resp_func(X*theta);
    l(it,1)=logistic_liklihood(C,mu);
    if (it>2 & (abs(l(it-1)-l(it))<0.001)) %  | max(abs(theta))>7)
        break;
    end;
    W=diag(mu.*(1-mu));
    z=(theta'*X')'+inv(W)*(C-mu);
    %theta=inv(X'*W*X)*X'*W*z;
    theta=theta+inv(X'*W*X)*X'*(C-mu);
end;
l=l(end);
if (it==MAX_ITER)
    fprintf('Warning: failed to converge in %d iterations\n',MAX_ITER);
end;