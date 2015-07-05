function hh = errorbar(x, y, l,u,symbol, xlower, xupper)
%ERRORBAR Error bar plot.
%   ERRORBAR(X,Y,L,U) plots the graph of vector X vs. vector Y with
%   error bars specified by the vectors L and U.  L and U contain the
%   lower and upper error ranges for each point in Y.  Each error bar
%   is L(i) + U(i) long and is drawn a distance of U(i) above and L(i)
%   below the points in (X,Y).  The vectors X,Y,L and U must all be
%   the same length.  If X,Y,L and U are matrices then each column
%   produces a separate line.
%
%   ERRORBAR(X,Y,E) or ERRORBAR(Y,E) plots Y with error bars [Y-E Y+E].
%   ERRORBAR(...,'LineSpec') uses the color and linestyle specified by
%   the string 'LineSpec'.  See PLOT for possibilities.
%
%   H = ERRORBAR(...) returns a vector of line handles.
%
%   For example,
%      x = 1:10;
%      y = sin(x);
%      e = std(y)*ones(size(x));
%      errorbar(x,y,e)
%   draws symmetric error bars of unit standard deviation.

%   L. Shure 5-17-88, 10-1-91 B.A. Jones 4-5-93
%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 5.18 $  $Date: 2001/04/15 12:03:51 $

if min(size(x))==1,
  npt = length(x);
  x = x(:);
  y = y(:);
    if nargin > 2,
        if ~isstr(l),  
            l = l(:);
        end
        if nargin > 3
            if ~isstr(u)
                u = u(:);
            end
        end
    end
else
  [npt,n] = size(x);
end

if nargin == 3
    if ~isstr(l)  
        u = l;
        symbol = '-';
    else
        symbol = l;
        l = y;
        u = y;
        y = x;
        [m,n] = size(y);
        x(:) = (1:npt)'*ones(1,n);;
    end
end

if nargin == 4
    if isstr(u),    
        symbol = u;
        u = l;
    else
        symbol = '-';
    end
end

if nargin == 5
    if isstr(u)
        if size(symbol,1) == 1
            symbol = symbol';
        end;
        xupper = symbol;
        xlower = symbol;
        symbol = u;
        u = l;
    end;
end;

if nargin == 2
    l = y;
    u = y;
    y = x;
    [m,n] = size(y);
    x(:) = (1:npt)'*ones(1,n);;
    symbol = '-';
end

u = abs(u);
l = abs(l);
    
if isstr(x) | isstr(y) | isstr(u) | isstr(l)
    error('Arguments must be numeric.')
end

if ~isequal(size(x),size(y)) | ~isequal(size(x),size(l)) | ~isequal(size(x),size(u)),
  error('The sizes of X, Y, L and U must be the same.');
end

tee = (max(x(:))-min(x(:)))/100;  % make tee .02 x-distance for error bars
xl = x - tee;
xr = x + tee;

ytop = y + u;
ybot = y - l;
if nargin > 4 & exist('xlower')
    tee2 = (max(y(:))-min(y(:)))/100;
    yu2 = y + tee2;
    yl2 = y - tee2;
    xl2 = x - xlower;
    xr2 = x + xupper;
end;
    
n = size(y,2);

% Plot graph and bars
hold_state = ishold;
cax = newplot;
next = lower(get(cax,'NextPlot'));

% build up nan-separated vector for bars
xb = zeros(npt*9,n);
xb(1:9:end,:) = x;
xb(2:9:end,:) = x;
xb(3:9:end,:) = NaN;
xb(4:9:end,:) = xl;
xb(5:9:end,:) = xr;
xb(6:9:end,:) = NaN;
xb(7:9:end,:) = xl;
xb(8:9:end,:) = xr;
xb(9:9:end,:) = NaN;

yb = zeros(npt*9,n);
yb(1:9:end,:) = ytop;
yb(2:9:end,:) = ybot;
yb(3:9:end,:) = NaN;
yb(4:9:end,:) = ytop;
yb(5:9:end,:) = ytop;
yb(6:9:end,:) = NaN;
yb(7:9:end,:) = ybot;
yb(8:9:end,:) = ybot;
yb(9:9:end,:) = NaN;

xb2 = zeros(npt*9,n);
% xb2(1:9:end,:) = x;
% xb2(2:9:end,:) = x;
% xb2(3:9:end,:) = NaN;
% xb2(4:9:end,:) = xl2;
% xb2(5:9:end,:) = xr2;
% xb2(6:9:end,:) = NaN;
% xb2(7:9:end,:) = xl2;
% xb2(8:9:end,:) = xr2;
% xb2(9:9:end,:) = NaN;
xb2(1:9:end,:) = xl2;
xb2(2:9:end,:) = xr2;
xb2(3:9:end,:) = NaN;
xb2(4:9:end,:) = xl2;
xb2(5:9:end,:) = xl2;
xb2(6:9:end,:) = NaN;
xb2(7:9:end,:) = xr2;
xb2(8:9:end,:) = xr2;
xb2(9:9:end,:) = NaN;

yb2 = zeros(npt*9,n);
% yb2(1:9:end,:) = yu2;
% yb2(2:9:end,:) = yl2;
% yb2(3:9:end,:) = NaN;
% yb2(4:9:end,:) = yu2;
% yb2(5:9:end,:) = yu2;
% yb2(6:9:end,:) = NaN;
% yb2(7:9:end,:) = yl2;
% yb2(8:9:end,:) = yl2;
% yb2(9:9:end,:) = NaN;
yb2(1:9:end,:) = y;
yb2(2:9:end,:) = y;
yb2(3:9:end,:) = NaN;
yb2(4:9:end,:) = yl2;
yb2(5:9:end,:) = yu2;
yb2(6:9:end,:) = NaN;
yb2(7:9:end,:) = yl2;
yb2(8:9:end,:) = yu2;
yb2(9:9:end,:) = NaN;

[ls,col,mark,msg] = colstyle(symbol); if ~isempty(msg), error(msg); end
symbol = [ls mark col]; % Use marker only on data part
esymbol = ['-' col]; % Make sure bars are solid

h = plot(xb,yb,esymbol, xb2, yb2, esymbol); hold on
h = [h;plot(x,y,symbol,xb2,yb2,symbol)]; 

if ~hold_state, hold off; end

if nargout>0, hh = h; end
