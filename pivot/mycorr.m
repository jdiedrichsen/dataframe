function r=mycorr(X)
% correlation coefficient 
% function r=corr(X)
% X is a 2-column data vector
% ignores NaN's in one of the vectors
% For easy use with pivottables
i=find(~isnan(X(:,1)) & ~isnan(X(:,2)));
if size(i,1)<3
    r=NaN;
else
    A=corrcoef(X(i,:));  
    if (~isnan(A))
        r=A(2,1);
    else 
        r=NaN;
    end;
end;
