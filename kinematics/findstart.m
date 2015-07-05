function start=findstart(indicator,time)
% generic funcion to find the start in a trace
% SYNOPSIS 
%   function start=findstart(indicator,time)
% DESCRIPTION
%   indicator: a logical vector if the measurement is above threshold or not.
%   time number of times, that the indicator has to be one
ind=find(indicator>0);
time=time-1;
start=NaN;
i=1;
if (isempty(ind))
    return;
end;
while (length(ind)-i>=time)
    if (ind(i)==ind(i+time)-time)
        start=ind(i);
        break;
    end;
    i=i+1;
end;

