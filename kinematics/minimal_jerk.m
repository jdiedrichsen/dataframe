function [x]=minimal_jerk(T,X,t)
% Makes a minimal Jerk trajectory that reaches the points X1,...XN at the 
% time point T1....TN. 
% t is the times at which the returned trajectory will be sampled 
% Trajectory is returned a x 
% ------------------------------------------------

% Do it piecewise for every segment: 
for n=1:length(T)-1
    indx=t>=T(n) & t<=T(n+1); % finds the segment in time 
    nt=(t(indx)-T(n))/(T(n+1)-T(n)); 
    nx=-(15*nt.^4-6*nt.^5-10*nt.^3); 
    x(indx,1)=nx*(X(n+1)-X(n))+X(n); 
end;