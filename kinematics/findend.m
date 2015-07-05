function ende=findend(indicator,time,start)
% generic funcion to find the end in a trace
% SYNOPSIS 
%   function start=findend(indicator,time,start)
% DESCRIPTION
%   indicator: a logical vector if the measurement is above threshold or not.
%   time number of times, that the indicator has to be below threshold, has
%           to be at least 1 to give valid results 
%   start: index from which the vector is searched 
%   function return NaN if Start could not be found
%   function return length(indicator)+1 when the movement never stopped 
if nargin<3
    start=1;
end;
if (isnan(start))
    ende=NaN;
    return;
end;
ind=find(indicator(start:end)>0);

if (isempty(ind))
    ende=NaN;
    return;
end;
i=1;
ende=-1;
while (length(ind)-i>0)
    if (ind(i+1)-ind(i)>time)
        ende=ind(i)+start;
        break;
    end;
    i=i+1;
end;
% two reasons for exiting: Still moving or ended without any new start 
if (ende==-1)
    ende=ind(i)+start;
end;
if (ende>length(indicator))
    ende=length(indicator);
end;