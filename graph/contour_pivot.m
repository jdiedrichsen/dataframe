function [F,R,C]=contour_pivot(X,Y,Z,stats,varargin) 
% makes a countour plot of some statistics from a data-columns
% function contour_pivot(Y,X,Z,stats) 
% X: column vector of X values
% Y: column vector of Y values
% Z: column vector of Z values
% stats: name of the function applied to each collection of Z-values for a particular X,Y
c=1;PV={};
subset=ones(length(X),1);
contours=[];
fill=1; 
labels='auto';
vararginoptions(varargin,{'subset','contours','fill','labels'});

[F,R,C]=pivottable(Y,X,Z,stats,'subset',subset);
[x,y]=meshgrid(C,R);
if(strcmp(stats,'length'))
    F(isnan(F))=0;
end;
if (fill)
    if (isempty(contours)) 
        [c,h]=contourf(x,y,F);
    else 
        [c,h]=contourf(x,y,F,contours);
    end;    
else 
    if (isempty(contours)) 
        [c,h]=contour(x,y,F);
    else 
        [c,h]=contour(x,y,F,contours);
    end;    
end;    

% labeling of contours
if (~isempty(labels))
    if (strcmp(labels,'auto'))
        clabel(c,h);
    else
        clabel(c,h,labels);
    end;
end;