function b=linintercept(X);
% function b=linslope([y x]);
% slope from linear regression with intercept 
% utility function for pivottables 
b=linregress(X(:,1),X(:,2));
b=b(1);