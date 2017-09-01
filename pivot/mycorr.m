function [r,rlo,rup]=mycorr(X)
% correlation coefficient 
% function r=corr(X)
% X is a 2-column data vector
% ignores NaN's in one of the vectors
% For easy use with pivottables
% Edited by Maedbh King (28/02/17) 

i=find(~isnan(X(:,1)) & ~isnan(X(:,2)));
if size(i,1)<3
    r=NaN;
    rlo=NaN; % MK 
    rup=NaN; % MK 
else
    [A,P,RL,RU]=corrcoef(X(i,:));  
    if (~isnan(A))
        r=A(2,1);
        rlo=RL(2,1);
        rup=RU(2,1);
    else 
        r=NaN;
    end;
end;
