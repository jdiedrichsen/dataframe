function cvar=circvar(ph)
% Synopsis
% cm=circvar(ph)
% Desription:
% cm is the circular variance of the phase data in 
% ph (angular data) in radians
C=nansum(cos(ph));
S=nansum(sin(ph));
R=sqrt(S^2+C^2);
l=find(not(isnan(ph)));
if(length(l)>0);
   cvar=1-R/length(l);
else
   cvar=NaN;
end;