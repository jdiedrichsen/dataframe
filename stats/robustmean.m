function m=robustmean(y); 
% function m=robustmean(y); 
% Calculates the robust mean using robust fit with default parameter 
x=ones(size(y)); 
m=robustfit(x,y,[],[],'off'); 
