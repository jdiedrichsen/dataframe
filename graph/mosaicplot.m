function varargout = mosaicplot(row , col, data, varargin);
%%  varargout = mosaicplot(varargin);
%  Draws a mosaic plot.
% 
% INPUTS:
%   row :    An Nx1 vector specifying row-categories.
%   col :    An Nx1 vector specifying column-categories.
%   data :   An Nx1 vector of count data.
% 
% OPTIONS:
%	'subset' :  Additional logical mask (e.g., mosaicplot(..., 'subset', col<5) ).
%	'facecolor' : A cell array of RGB color for row-categories (e.g., {'r', [0,0,0], 'g'}).
%	'gapwidth' : A length-2 vector of gap width between rows and columns (e.g., [0.01, 0.01]).
%	'edgecolor' : An 'edgecolor' option for patch object (default : 'k').
%	'pivotfcn' : Field command for pivottable (defeult : 'nansum').
%	'rowlabel' : A cell array of labels for row-categories.
%	'columnlabel' : A cell array of labels for column-categories.
%	'columnlabelrotation' : A scaler value specifying rotation angle of colum-labels.
% 
% EXAMPLE:
%	row=randsample(4,100,1);
%	col=kron([1:10]',ones(10,1));
%	data = rand(100,1)>0.5;
%	figure;
%	mosaicplot(row, col, data);
%         
% a-yokoi (at.yokoi.work@gmail.com) 
% 
% v1: Jan/2019
% 

% input check
assert( length(row)==length(col), 'input dimension missmatch.');
assert( length(data)==length(col), 'input dimension missmatch.');

% define/get options
subset = true(size(data));
facecolor = mat2cell(hsv(10), ones(10,1), 3);        
%facecolor = {'m','g','c','k','w'};
gapwidth = [0.01,0.01];
edgecolor = 'k';
pivotfcn = 'nansum';
rowlabel = [];
columnlabel = [];
columnlabelrotation = 90;
linewidth = 1;
drawcount = 1;
fontsize = get(0,'defaulttextfontsize');
textcolor = [0,0,0];
leg = [];
leglocation = 'northoutside';
vararginoptions(varargin, {'subset','facecolor','gapwidth',...
    'edgecolor','pivotfcn','rowlabel','columnlabel','columnlabelrotation','linewidth',...
    'drawcount','fontsize','textcolor','leg','leglocation'});

% use pivottable 
[M,Rheader,Cheader] = pivottable(row, col, data, pivotfcn, 'subset', subset);
M(isnan(M)) = 0;
[Nrow,Ncol] = size(M);

% draw chart 
% adjust values (rows summs to 1, cols are proportional to sum of counts)
totals = sum(M,1);
total = sum(totals);
xprev = gapwidth(2);
xrange = [0,0];
for c=1:Ncol    
    if totals(c)<=eps
        warning('No data counts for category %d', c);
        width = sqrt(2)/total+eps;
        x = [0, width, width, 0] + xprev;
        xcenter(c) = mean(x(1:2));        
    else
        width = sqrt(2)*totals(c)/total+eps;
        x = [0, width, width, 0] + xprev;
        xcenter(c) = mean(x(1:2));
        yprev = gapwidth(1);
        cc=0;
        for r=1:Nrow
            if cc>numel(facecolor)
                warning('Insufficient color specified. Reusing.');
                cc=1;
            else
                cc=cc+1;
            end;
            color = facecolor{cc};
            height = min([(M(r,c)+eps)/totals(c), 1+Nrow*gapwidth(1)]);
            y = [0, 0, height, height] + yprev;
            if c==1 % for the first column
                ycenter(r) = mean(y(2:3));
                xrange(1) = x(1);
            end
                        
            % draw patch
            h = patch(x,y,color); hold on;
            set(h, 'edgecolor', edgecolor, 'linewidth', linewidth);
            
            % draw count if required
            if drawcount&&M(r,c)>1
                text(mean(x),mean(y),sprintf('%d',M(r,c)),...
                    'horizontalalignment','center',...
                    'verticalalignment','middle',...
                    'fontsize',fontsize,...
                    'color',textcolor);
            end
            
            yprev = y(3) + gapwidth(1);
        end
    end
    
    xprev = x(2)+gapwidth(2); 
end;
xrange(2)=x(2);
axis off;
set(gca, 'xlim', [-10*gapwidth(2), max(x)],...
    'ylim', [-5*gapwidth(1), max(y)]);

% draw label if specified
if ~isempty(rowlabel)
    %     for r=1:Nrow
    %         rowlabel{r} = sprintf('row%d',r);
    %     end
    for r=1:Nrow
        text(0, ycenter(r), rowlabel{r},...
            'horizontalalignment', 'right', ...
            'rotation', 0,...
            'color', facecolor{r});
    end
end
if ~isempty(columnlabel)
    %     for c=1:Ncol
    %         columnlabel{c} = sprintf('col%d',c);
    %     end
    switch columnlabelrotation
        case 90
            halign = 'right';
            valign = 'middle';
        otherwise
            halign = 'center';
            valign = 'top';
    end
    for c=1:Ncol
        text(xcenter(c), 0, columnlabel{c},...
            'horizontalalignment', halign, ...
            'verticalalignment', valign, ...
            'rotation', columnlabelrotation);
    end
end

% add legend if required
if ~isempty(leg);
    if ~isempty(strfind(leglocation,'north'))||~isempty(strfind(leglocation,'south'))
        orientation = 'horizontal';
    else
        orientation = 'vertical';
    end
    legend(leg,'location',leglocation,...
        'edgecolor','none',...
        'color', get(gcf,'color'),...
        'orientation',orientation);
    tmp = get(gcf,'children');
    for i=1%:length(tmp)
        if isa(tmp(i), 'matlab.graphics.illustration.Legend');
            set(tmp(i), 'textcolor', get(gca,'xcolor'));
        end
    end
end

varargout = {M,Rheader,Cheader,xcenter,xrange};
end