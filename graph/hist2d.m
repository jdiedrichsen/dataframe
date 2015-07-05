function [N,catX,catY]=hist2d(X,Y,varargin);
% function [N,catX,catY]=hist2d(X,Y,varargin);
%   Make 2d histogram or density estimation plots 
% INPUT:
%   X: vector of X-values
%   Y: vector of Y-values
%   OPTIONAL INPUTS:
%   'contour': Contour plot (Default)
%   'image': Diagram as Image 
%   'catX',catX: bin centers for X / scalar:number of bins 
%   'catY',catY: bin centers for Y / scalar: number of bins 
%   'subset',indicator: subset of data for indicator==1
%   'xnorm': Normalizes X-bins to percent 
%   'ynorm': Normalizes Y-bins to percent 
%   'colormap',c: Sets colormap to c;
%   'clabel': Adds cLabels to lines (contour only)
%   'colorbar': Adds colorbar
%   'scalefcn': employs scaling function before plotting the data
%               e.g. (@(x)(log(x+1)) 
% OUTPUT:
%   N: Counts in bins length(catX)*length(catY) Matrix
%   catX: bin centers for X
%   catY: bin centers for Y

style='contour';
cmap=1-gray;
c=1;
isClabel=0;
isColorbar=0;
isXnorm=0;
isYnorm=0;
scalefcn=[]; 
while(c<=length(varargin))
    switch(varargin{c})
    case 'catX'
        catX=varargin{c+1};c=c+2;
    case 'catY'
        catY=varargin{c+1};c=c+2;
    case 'subset'
        goodindx=find(varargin{c+1});
        c=c+2;
        X=X(goodindx,:);
        Y=Y(goodindx,:);
    case {'contour','image'}
        style=varargin{c};
        c=c+1;
    case {'colormap'}
        cmap=varargin{c+1};c=c+2;
    case 'clabel'
        isClabel=1;c=c+1;
    case 'colorbar'
        isColorbar=1;c=c+1;
    case 'xnorm'
        isXnorm=1;c=c+1;
    case 'ynorm'
        isYnorm=1;c=c+1;
    case 'scalefcn'
        scalefcn=varargin{c+1}; 
        c=c+2; 
    otherwise
        error('Unknown option\n');
    end;
end;
if ~exist('catX')
    [N,catX]=hist(X);
elseif (length(catX)==1) 
    [N,catX]=hist(X,catX);
end;
if ~exist('catY')
    [N,catY]=hist(Y);
elseif (length(catY)==1) 
    [N,catY]=hist(Y,catY);
end; 
N=zeros(length(catY),length(catX));
for(i=1:length(X))
    [minval,indX]=min(abs(catX-X(i)));
    [minval,indY]=min(abs(catY-Y(i)));
    N(indY,indX)=N(indY,indX)+1;
end;
% Optional normalization: 
if (isXnorm)
    N=N./repmat(sum(N),size(N,1),1);
end;
if (~isempty(scalefcn)) 
    N=feval(scalefcn,N); 
end; 


[MX,MY]=meshgrid(catX,catY);
switch(style)
    case 'contour'
        [c,h] = contourf(MX,MY,N); 
        if (isClabel)
            clabel(c,h);
        end;
        if (isColorbar)
            colorbar;
        end;
        
    case 'image'
        imagesc(catX,catY,N);
        set(gca,'YDir','normal');
end;
colormap(cmap);
set(gca,'Box','Off');