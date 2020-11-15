function l= logistic_liklihood(C,mu)
% returns the logistic likelihood 
l=sum(C.*log(mu)+(1-C).*log(1-mu));