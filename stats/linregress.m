function [B,STATS]=linregress(y,X,varargin);
% function [B,STATS]=linregress(y,X,varargin);
% Linear or multiple regression
% OPTIONS:
%   'intercept',0,1     : Intercept
%   'subset',logical    : Subset
%   'drawline'          : Plots a line to the current axis
%   'contrast'          : Define the contrast (default: eye(Q))
% NOTE: p-values are one-sided! 

intercept=0;
drawline=0;
contrast=[];
subset=ones(size(y));

vararginoptions(varargin,{'intercept','subset','contrast'},{'drawline'});

y=y(find(subset),:);
X=X(find(subset),:);

if (intercept==1)
    X=[ones(size(y,1),1) X];
end;
B=inv(X'*X)*X'*y;

yp=X*B;
res=y-yp;
STATS.resSS=res'*res;
STATS.totSS=y'*y;


STATS.df=size(X,1)-size(X,2);

for i=1:size(contrast,1);
    c=contrast(i,:);
    
    SE=c*inv(X'*X)*c'*(STATS.resSS/STATS.df);
    STATS.t(i)=c*B./sqrt(SE);
    STATS.p(i)=1-tcdf(STATS.t(i),STATS.df);
end;

if (drawline & size(X,2)-intercept==1)
    XL=get(gca,'XLim');
    if (intercept)
        X=[ones(2,1) XL'];
    else
        X=XL';
    end;
    yp_line=X*B;
    hold on;plot(XL,yp_line,'k');hold off;
end;
