function b=linslope(X);
% function b=linslope([x y]);
% slope from linear regression with intercept 
% utility function for pivottables 
b=linregress(X(:,2),X(:,1));
b=b(2);