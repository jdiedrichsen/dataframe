function mu=logistic_resp_func(xi)
% returns the logistic response function
% function l= logistic_liklihood(Y,mu)
% Y is a N*(K-1) matrix, where is last row 1=sum(other rows is left out)
% mu is a N*(K-1) matrix, where last row = 1-sum(other is left out)
% make matrix full
mu=exp(xi)./(1+exp(xi));