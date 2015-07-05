function [outlier,handle]=myboxutil(x,lb,F)
%MYBOXUTIL Produces a single box plot.
%   MYBOXUTIL(X) is a utility function for BOXPLOT, which calls
%   MYBOXUTIL once for each column of its first argument. 
%   notch: 1 with a notch
%   lb: x-position
%   F.w: boxwidth
%   F.lf: barwidth
%   F.outliersymbol: symbol for outliers/datapoints
%   F.flip: vertical
%   F.whiskerlength: whisker length
%   F.whissw: 
%   F.plotall: 0: none 1: plots all ouliers 2:plots all 
%   F.linecolor
%   F.mediancolor
%   F.fillcolor
%   Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 2.17 $  $Date: 2002/01/17 21:30:05 $

% Make sure X is a vector.
if min(size(x)) ~= 1, 
    error('First argument has to be a vector.'); 
end


% define the median and the quantiles if more data than 4 
pctiles = prctile(x,[25;50;75]);
q1 = pctiles(1,:);
med = pctiles(2,:);
q3 = pctiles(3,:);

% find the extreme values (to determine where whiskers appear)
vhi = q3+F.whiskerlength*(q3-q1);
upadj = max(x(x<=vhi));
if (isempty(upadj)), upadj = q3; end

vlo = q1-F.whiskerlength*(q3-q1);
loadj = min(x(x>=vlo));
if (isempty(loadj)), loadj = q1; end

x1 = lb*ones(1,2);
x2 = x1+[-0.25*F.w,0.25*F.w];

% determine which symbols to plot 
outlier = x<loadj | x > upadj;
switch (F.plotall) 
    case 0
        xx=[];yy=[];
    case 1
        yy = x(outlier);
    case 2
        yy=x;
end;

%if isempty(yy)
%   yy = loadj;
%   [a1 a2 a3 a4] = colstyle(sym);
%   sym = [a2 '.'];
%end

xx = lb*ones(1,length(yy));
    lbp = lb + 0.5*F.w;
    lbm = lb - 0.5*F.w;

if F.whissw == 0
   upadj = max(upadj,q3);
   loadj = min(loadj,q1);
end

% Set up (X,Y) data for notches if desired.
if ~F.notch
    xx2 = [lbm lbp lbp lbm lbm];
    yy2 = [q3 q3 q1 q1 q3];
    xx3 = [lbm lbp];
else
    n1 = med + 1.57*(q3-q1)/sqrt(length(x));
    n2 = med - 1.57*(q3-q1)/sqrt(length(x));
    if n1>q3, n1 = q3; end
    if n2<q1, n2 = q1; end
    lnm = lb-0.25*F.w;
    lnp = lb+0.25*F.w;
    xx2 = [lnm lbm lbm lbp lbp lnp lbp lbp lbm lbm lnm];
    yy2 = [med n1 q3 q3 n1 med n2 q1 q1 n2 med];
    xx3 = [lnm lnp];
end
yy3 = [med med];

% Determine if the boxes are vertical or horizontal.
% The difference is the choice of x and y in the plot command.
if ~F.flip
    handle=patch(xx2,yy2,F.fillcolor);
    set(plot(x1,[q3 upadj],'k-',x1,[loadj q1],'k-'),'Color',F.linecolor,'LineWidth',F.whiskerwidth);             % whiskers
    set(plot(x2,[loadj loadj],'k-',x2,[upadj upadj],'k-'),'Color',F.linecolor,'LineWidth',F.whiskerwidth);        % upper / lower line  
    set(plot(xx2,yy2,'k-'),'Color',F.linecolor,'LineWidth',F.linewidth);                                        % box
    set(plot(xx3,yy3,'k-'),'Color',F.mediancolor,'LineWidth',F.medianwidth);                                          % median line
    if (length(yy)>0)
        set(plot(xx,yy,'k.'),'Marker',F.markertype,'MarkerSize',F.markersize,'MarkerEdgeColor',F.markercolor,'MarkerFaceColor',F.markerfill);                                    % symbols
    end;
else
    handle=patch(yy2,xx2,F.fillcolor);
    set(plot([q3 upadj],x1,'k-',[loadj q1],x1,'k-'),'Color',F.linecolor,'LineWidth',F.whiskerwidth);             % whiskers
    set(plot([loadj loadj],x2,'k-',[upadj upadj],x2,'k-'),'Color',F.linecolor,'LineWidth',F.whiskerwidth);        % upper / lower line  
    set(plot(yy2,xx2,'k-'),'Color',F.linecolor,'LineWidth',F.linewidth);                                        % box
    set(plot(yy3,xx3,'k-'),'Color',F.mediancolor,'LineWidth',F.medianwidth);                                          % median line
    if (length(yy)>0)
        set(plot(yy,xx,'k.'),'Marker',F.markertype,'MarkerSize',F.markersize,'MarkerEdgeColor',F.markercolor,'MarkerFaceColor',F.markerfill);                                    % symbols
    end;
end;

