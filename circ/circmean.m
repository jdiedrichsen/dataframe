function cm=circmean(ph)
% Synopsis
% cm=circmean(ph)
% Desription:
% cm is the circular mean or mean direction of the phase data in 
% ph (angular data) in radians
% ignores NaN
% for ma matrix, calculates the mean for every column
[rows,cols]=size(ph);
if(rows==1 & cols>1) 
    ph=ph';
    [rows,cols]=size(ph);
end;    
for(c=1:cols)
    C=nansum(cos(ph(:,c)));
    S=nansum(sin(ph(:,c)));
    t=atan(S/C);
    if (C<0)
        cm(c)=t+pi;
    else
        if (S<0)
            cm(c)=t+2*pi;
        else
            cm(c)=t;
        end;
    end;
end;