function b=lengthstandard(a,x)
% function b=lengthstandard(A,x)
% standardizes the length of each vector
% input:
%   A:vector or matrix to be standardized
%     if A is an matrix, it standardizes each column-vector in the matrix
%     NaN are taken out of the matrix-coumns and not standardized
%   x:if x is scalar: length of the new resampled vector
%     x can also be a [0:1] vector, then A is resampled at these places

% get the temporal vecotr in the right direction
xs=size(x);
if (length(x)==1)
    x=[0:1/(x-1):1];
end;
if (length(xs)==1 | xs(1)==1)
    x=x';
end;

s=size(a);
if(length(s)==3)            % three dimensional matrix
    [rows,cols,slice]=size(a);
    b=zeros(length(x),cols,slice)*NaN;
    for i=1:slice
        for c=1:cols
            idx=find(~isnan(a(:,c,i)));
            if (length(idx)>2)
                v=a(idx,c,i);
                xi=[0:1/(length(v)-1):1];
                b(:,c,i)=interp1(xi',v,x);
            end;
        end;
    end;
    return;
end;

if (length(s)==1 | s(1)==1) % two dimensional Matrix or vector
    a=a';
end;
[rows,cols]=size(a);
b=zeros(length(x),cols)*NaN;
for c=1:cols
    idx=find(~isnan(a(:,c)));
    if (length(idx)>2)
        v=a(idx,c);
        xi=[0:1/(length(v)-1):1];
        b(:,c)=interp1(xi',v,x);
    end;
end;






