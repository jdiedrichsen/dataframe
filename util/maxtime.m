function [x,t]=maxtime(v)
% returns the maximum of a vector
%function [x,t]=maxtime(v)
% x is the max of the vector
% t is the time of occurance of this value (when it occurs multiple time, the first
% occurance)
if(isempty(v) | length(v)<2)
    x=NaN;
    t=NaN;
    return;
end;
x=max(v);
f=find(x==v);
t=f(1);