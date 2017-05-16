function varargout=scatterplot(x,y,varargin)
% function scatterplot(x,y,varargin)
% Provides a scatterplot of the y-values against x-values 
% INPUT: 
%       x:  Nx1 vector of x-values 
%       y:  Nx1 vector of y-values 
% VARARGIN:
%   Format options (for all symbols)
%       'markertype',{o s v ^...}
%       'markercolor',[r g b]
%       'markerfill',[r g b]
%       'markersize',size
%               These can also be cell arrays for splitting
%   Other commands:
%       'CAT',cat        : Stucture with fields for a fix formating.
%                               if string, uses predifined style.
%       'subset',indx    : plots only a subset of the data
%       'split',splitby  : splits data by vaiable splitby
%       'color',x        : Uses current color map to shade the circle in
%                           color corresponding to the range.
%       'bubble',x       : Uses to x variable to determine markersize 
%       'label',label    : Label each point with a number or string
%       'colormap', CM   : Sets colormap
%       'leg',value      : specified legend string can be either a cell array of 
%                          strings or the value 'auto'
%       'regression'     : 'leastsquare/linear','robust'
%                           In this case the output arguments are
%                             r2: correlation coefficient^2
%                             b: regression coefficients
%                             t: t-value 
%                             p: probability 
%       'intercept',val  : Determines whether intercept is included in regression
%                            1:     have free intercept (default)
%                            0:     Set the intercept to (0,0)
%                            [x,y]: force the line to go through the point (x,y)
%        'wfun'          : Weighting function for robust regression. Can be 
%                           'bisquare', 'cauchy', 'fair',
%                           'huber', 'logistic', 'talwar', or 'welsch'
%       'polyorder',p    : Order of the polynomial of the regression (default 1)
%       'printcorr'      : Prints correlation onto the graph
%       'draworig'       : Draws origin into the graph
%       'identity'       : Adds identity line
%       'xaxisIncl'      : Points (min,max) on xaxis that need to be shown: XLim will
%                          be larger of the same 
%       'yaxisIncl'      : Points (min,max) on yaxis that need to be shown: YLim will
%                          be larger of the same 
% Joern Diedrichsen (joern.diedrichsen@googlemail.com)

[Nx n] = size(y);
if (n>1)
    error('data has to be a column-vector');
end

% Set defaults for all plots
colormap=hot;
markersize=4;
markertype= {'o','o','o','o','o','o','s','s','s','s','s','s','v','v','v','v','v','v'};
markercolor={[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1]};
markerfill={[1 1 1],[1 1 1],[1 1 1],[0 0 0],[1 0 0],[0 0 1],[1 1 1],[1 1 1],[1 1 1],[0 0 0],[1 0 0],[0 0 1],[1 1 1],[1 1 1],[1 1 1],[0 0 0],[1 0 0],[0 0 1]};
draworig=0;
identity=0; 
printcorr=0;
regression=[];
intercept=1;
polyorder=1;
label=[];
labelformat='%d';
wfun='bisquare';
leg=[];
r2=[];t=[];
b=[];p=[];
CAT=[];
leglocation='SouthEast';
% Deal with the varargin's
split=[];subset=ones(size(y,1),1);color=[];
bubble=[];
bubble_minsize=3;
bubble_maxsize=30;
yaxisIncl=[];
xaxisIncl=[];

variables={'markertype','markercolor','markerfill','markersize','CAT',...
    'subset','split','leg','leglocation','color','label',...
    'regression','polyorder','intercept',...
    'colormap',...
    'bubble','bubble_minsize','bubble_maxsize',...
    'xaxisIncl','yaxisIncl'};
flags={'draworig','printcorr','identity'};

vararginoptions(varargin,variables,flags);

if (ischar(CAT))
    switch (CAT)
        case '4x2x2'
            CAT.markertype= {'o','o','o','o','o','o','o','o','s','s','s','s','s','s','s','s'};
            CAT.markercolor={[0 0 0],[1 0 0],[0 1 0],[0 0 1],[0 0 0],[1 0 0],[0 1 0],[0 0 1],[0 0 0],[1 0 0],[0 1 0],[0 0 1],[0 0 0],[1 0 0],[0 1 0],[0 0 1]};
            CAT.markerfill={[1 1 1],[1 1 1],[1 1 1],[1 1 1],[0 0 0],[1 0 0],[0 1 0],[0 0 1],[1 1 1],[1 1 1],[1 1 1],[1 1 1],[0 0 0],[1 0 0],[0 1 0],[0 0 1]};
        case '3x2x2'
            CAT.markertype= {'o','o','o','o','o','o','s','s','s','s','s','s'};
            CAT.markercolor={[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1]};
            CAT.markerfill={[1 1 1],[1 1 1],[1 1 1],[0 0 0],[1 0 0],[0 0 1],[1 1 1],[1 1 1],[1 1 1],[0 0 0],[1 0 0],[0 0 1]};
        case '2x8'
            CAT.markertype= {'o','o','+','+','*','*','x','x','s','s','<','<','>','>','^','^'};
            CAT.markercolor={[1 0 0],[0 1 0],[1 0 0],[0 1 0],[1 0 0],[0 1 0],[1 0 0],[0 1 0],...
                    [1 0 0],[0 1 0],[1 0 0],[0 1 0],[1 0 0],[0 1 0],[1 0 0],[0 1 0]};
        otherwise
            error(['CAT: Undefined Map' CAT]);
    end;
end;

if (~isempty(CAT))
    fields=fieldnames(CAT);

    for i=1:length(fields)
        eval(sprintf('%s = CAT.%s;',fields{i},fields{i}));
     end;
end;

F.markersize=markersize;
F.markertype=markertype;
F.markercolor=markercolor;
F.markerfill=markerfill;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% re-code cell array
if ~isempty(split)
    [split,split_conv]=fac2int(split);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Apply goodindx-selection for subset
goodindx=find(subset);
y=y(goodindx,:);
x=x(goodindx,:);
if (~isempty(split))
    split=split(goodindx,:);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% color and bubble size 
if (~isempty(color))
    color=color(goodindx,:);
    colorrange=max(color)-min(color);
    if (colorrange==0) 
        warning('no variation in color varargin'); 
        color=[];
        colorz=[];
    else 
        colorz=round((size(colormap,1)-1)*(color-min(color))./colorrange+1);
    end;
end;
if (~isempty(bubble))
    bubble=bubble(goodindx,:);
    bubble=(bubble-min(bubble))./(max(bubble)-min(bubble));
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate scale
xmin = min(x);
xmax = max(x);
dx = (xmax-xmin)/20;
if (dx==0) dx=xmax/10;end;
xlims = [(xmin-dx) (xmax+dx)];
if (~isempty(xaxisIncl))
    xlims = [min(xlims(1),min(xaxisIncl)) max(xlims(2),max(xaxisIncl))];
end; 
ymin = min(y);
ymax = max(y);
dy = (ymax-ymin)/20;
if (dy==0) dy=abs(ymax)/10;end;
ylims = [(ymin-dy) (ymax+dy)];
if (~isempty(yaxisIncl))
    ylims = [min(ylims(1),min(yaxisIncl)) max(ylims(2),max(yaxisIncl))];
end; 

repl_state=get(gca,'NextPlot');
if (strcmp(repl_state,'replace'))
    cla;
else 
    xlims_old=get(gca,'XLim'); 
    ylims_old=get(gca,'YLim'); 
    xlims=[min(xlims(1),xlims_old(1)) max(xlims(2),xlims_old(2))]; 
    ylims=[min(ylims(1),ylims_old(1)) max(ylims(2),ylims_old(2))]; 
end;
set(gca,'NextPlot','add');
set(gca,'Box','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deal with split
form=fieldnames(F);
if (isempty(split))
    D{1,2}=[x y];
    numsplitcat=1;
else
    D=pidata(split,[x y]);
end;
[numsplitcat,dummy]=size(D);
for c=1:numsplitcat
    fm=F;
    for f=1:length(form)
        fiel=getfield(F,form{f});
        if (iscell(fiel));
            fm=setfield(fm,form{f},fiel{mod(c-1,length(fiel))+1}); % set formating structure for this category
        end;
    end;
    h(c)=plot(D{c,2}(:,1),D{c,2}(:,2),'ko');
    if (isempty(color) & isempty(bubble))
        set(h(c),'Marker',fm.markertype,'MarkerSize',fm.markersize,...
                'MarkerEdgeColor',fm.markercolor,'MarkerFaceColor',fm.markerfill);
    elseif (~isempty(color))
        for i=1:length(x)
            set(plot(x(i),y(i),'k.'),'Marker',fm.markertype,'MarkerSize',fm.markersize,...
                'MarkerEdgeColor',colormap(colorz(i),:),'MarkerFaceColor',colormap(colorz(i),:));hold on;
        end;
    elseif (~isempty(bubble))
        for i=1:length(x)
            set(plot(x(i),y(i),'k.'),'Marker',fm.markertype,'MarkerSize',bubble(i)*(bubble_maxsize-bubble_minsize)+bubble_minsize,...
                'MarkerEdgeColor',fm.markercolor,'MarkerFaceColor',fm.markerfill);hold on;
        end;
    end;
    
    if (~isempty(regression))
        if ~strcmp(regression,'none')
            [r2(c),b(:,c),t(:,c),p(:,c)] = doregress(D{c,2}(:,1),D{c,2}(:,2),fm.markercolor, regression, polyorder, intercept,wfun);
        end;
    end;
end;
if (ylims(1)==ylims(2))
    ylims=ylims+[-0.1 0.1];
end; 
if (xlims(1)==xlims(2))
    xlims=xlims+[-0.1 0.1];
end; 

axis([xlims ylims]);
if (draworig)
	line(xlims, [0 0]);
	line([0 0], ylims);
end;
if (identity)
    p1=max([xlims(1) ylims(1)]); 
    p2=min([xlims(2) ylims(2)]); 
	line([p1 p2],[p1 p2]);
end;     
hold off; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add labels to points
if (~isempty(label))
    if (iscell(label))
        label={label{find(subset)}};
        xoffset=(xlims(2)-xlims(1))/40;
        yoffset=(ylims(2)-ylims(1))/40;
        for i=1:length(x)
            text(x(i)+xoffset,y(i)+yoffset,label{i});
        end;
    else
        label=label(find(subset));
        xoffset=(xlims(2)-xlims(1))/40;
        yoffset=(ylims(2)-ylims(1))/40;
        for i=1:length(x)
            text(x(i)+xoffset,y(i)+yoffset,sprintf(labelformat,label(i)));
        end;
    end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deals with corr flag (assumes regression has been calculated)
if (printcorr)
	xoffset=0.05*(xmax-xmin);
	yoffset=0.05*(ymax-ymin);
	text(xmin+xoffset,ymax-yoffset,sprintf('R=%2.2f',sqrt(r2)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do legend
% Add legend if necessary
if (~isempty(split))
    Split_groups=vertcat(D{:,1});
    plotlegend(h,leg,Split_groups,split_conv,leglocation);
end;
set(gca,'NextPlot',repl_state);

varargout={r2,b,t,p};
figure(gcf);    % Bring figure to front on Mac platform


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform regression analysis 
function [r2,b,t,p]=doregress(x,y,color,type, polyorder, intercept,wfun)

offset = [0 0]; % Offset of data 

i = find(~isnan(x) & ~isnan(y));
X=[];

if (length(intercept)==2)
    x=x-intercept(1); 
    y=y-intercept(2); 
    offset = intercept; 
elseif(length(intercept)==1) 
    if (intercept==1)
        X=[ones(length(i),1)];
    end;
else
    error('Intercept needs to be either a logical (0 or 1), or a 1x2 vector'); 
end; 

% Add ploynomial order 
for j=1:polyorder
    X=[X x(i).^j];
end;

% Check if enough data points 
if (length(i)<size(X,2));
    r2=NaN;
    b=ones(size(X,2),1)*NaN;
    t=NaN;
    p=NaN;
    return;
end; 

% Run regression 
switch (type) 
    case {'linear','leastsquare'} 
        b=inv(X'*X)*X'*y(i);
    case 'robust'
        b = robustfit(X,y(i), wfun,[],'off');
    otherwise 
        error(sprintf('unknown regression type: %s',type)); 
end

% generate predicted values
y_est = X*b;
xlim=get(gca,'XLim'); 
xs=linspace(min(xlim),max(xlim),20)'; 
XS=[];
if (length(intercept)==1 && intercept==1)
    XS=[ones(length(xs),1)];
end;
for j=1:polyorder
    XS=[XS xs.^j];
end;

% Plot the regression line 
h=plot (xs+offset(1), XS*b+offset(2));
set(h,'Color',color);
RSS = sum((y(i) - y_est).^2);
TSS = sum((y(i) - mean(y(i))).^2);
r2 = 1-RSS/TSS;

% For linear regression, produce t and p-values 
if (strcmp(type, 'linear') ||  strcmp(type, 'leastsquare'))
    [N,Q]=size(X); 
    sig=RSS/(N-Q); 
    var_b=inv(X'*X)*sig; 
    t=b./sqrt(diag(var_b)); 
    p=2*tcdf(-abs(t),N-Q); 
else 
    t=[];
    p=[]; 
end; 

