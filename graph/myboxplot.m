function myboxplot(group,y,varargin)
% myboxplot(group,y,varargin)
%  group:       one or more variables defining the x-axis
%  y:           Data to be plotted (one vector)
%  Plots a boxplot of the data 
%   The midline of the box is the median of the data 
%   The box itself spans from the 25th to 75th percentile (middle two quartiles) 
%   The whiskers show the range (min to max) of the data 
%   Outliers are determined by data points that are more than 
%   whiskerlength * size of box from the box. 
%   Outliers are plotted as single dots 
%  VARARGIN:
%   Format options for boxes
%       in general: 'formating_option', value,...
%       If a single value is give, the formatting option is applied to all
%       split-categories. If a cell array of values is given, the first value
%       is for the first split category etc.
%       'boxwidth',size       : boxwidth
%       'outliersymbol',sym  : symbol for outliers/datapoints
%       'whiskerlength',size    : whisker length relative to box
%       'whiskerwidth',size   : Width of the whisker lines
%       'linecolor'           : Color of line around boxes
%       'linewidth',size      : Width of the lines around boxes
%       'fillcolor'           : Fill color of the boxes
%       'mediancolor'         : Color of the line detemining the median
%       'medianwidth',size    : Width of the median line
%       'notch',value         : Present notch in box around median? (0/1)
%   Format options for data points
%       'plotall',value       : Plot individual data points? 0: none, 1: all ouliers, 2:all
%       'markersize',size     : Size of the marker symbols
%       'markertype',type     : Type ('o','s','v','^') of the marker
%       'markercolor',[r g b] : Color of the marker edge
%       'markerfill',[r g b]  : Color of the marker fill
%   Format options for whole graph
%       'gap',size            : Size of gap between bars
%       'linscale'            : Makes the scale of x not categorial, but linear
%       'xtickoff'            : Removes label
%       'flip'                : Makes horizontal instead of vertical bars
%       'CAT', CAT            : Structure with fields with one entry per category (split by)
%                               Field can be all of the above (see online doc)
%       'leg', {}             : Legend added to graph: either cell array of
%                             : strings or 'auto'
%       'leglocation','north' : Legend location
%    Predetermined styles
%       'style_twoblock'      : Square boxes in two categories
%       'style_block'         : Square boxes
%       'style_tukey'         : Tukey style box plots
%   Data processing options
%       'subset',logical      : Only prints subset
%       'split',var           : Variable to split data by
% -------------------------------------------------------------------------
% Fixes
% v1.1: if all data is nan for one category, it leaves box open 01/25/06
% v1.2: if group is not given, it sets them all to one 03/18/06
% v1.3: flag 'xtickoff' leaves X-axis labels free 25/01/09

if (nargin==1 & length(y(:))==1 & ishandle(y)), resizefcn(y); return; end
% Set defaults for all plots
F.plotall=2;
F.linecolor=[0.8 0.8 0.8];
F.linewidth=1;
F.fillcolor=[0.8 0.8 0.8];
F.mediancolor=[1 1 1];
F.medianwidth=1;
F.whiskerwidth=1;
F.whiskerlength = 1.5;
F.notch = 0;
F.whissw = 0; % don't plot whisker inside the box.
F.markertype = 'o';
F.markercolor=[0 0 0];
F.markerfill=[0 0 0];
F.markersize=4;
F.linscale=0;
F.boxwidth=0.75;
gap=[1 0.7 0.5 0.5];
F.xtickoff=0;
split=[];
leg=[];
F.flip = 0;
leglocation='SouthEast';
% Deal with the varargin's
c=1;
while(c<=length(varargin))
    switch(varargin{c})
    case {'gap','linscale','split','subset','leg','leglocation'}
        eval([varargin{c} '=varargin{c+1};']);c=c+2;
    case {'xtickoff'}
        F.xtickoff=1;c=c+1;
    case {'flip'}
        F.flip=1;c=c+1;
    case {'boxwidth','outliersymbol','whiskerlength','whiskerwidth','linecolor','linewidth',...
                'fillcolor','mediancolor','medianwidth','notch','markersize','markertype',...
                'markercolor','markerfill','plotall'};
        eval(['F.',varargin{c} '=varargin{c+1};']);c=c+2;
    case 'style_twoblock'
        F.plotall=2;
        F.linecolor=[0.8 0.8 0.8];
        F.mediancolor=[1 1 1];
        F.fillcolor=[0.8 0.8 0.8];
        F.whissw = 0; % don't plot whisker inside the box.
        F.notch = 0;
        F.whiskerlength = 1.5;
        F.whiskerwidth=2.5;
        F.markertype = 'o';
        F.markercolor=[0 0 0];
        F.markerfill=[0 0 0];
        F.markersize=4;
        F.mediancolor=[1 1 1];
        F.medianwidth=2;
        F.linewidth=0.2;
        % depending on the split-category membership
        F.fillcolor={[0.5 0.5 0.5],[0.8 0.8 0.8]};
        F.linecolor={[0.5 0.5 0.5],[0.8 0.8 0.8]};
        c=c+1;
    case 'style_block'
        F.plotall=2;
        F.linecolor=[0.8 0.8 0.8];
        F.mediancolor=[1 1 1];
        F.fillcolor=[0.8 0.8 0.8];
        F.notch = 0;
        F.whiskerlength = 0;
        F.markertype = 'o';
        F.markercolor=[0 0 0];
        F.markerfill=[0 0 0];
        F.markersize=5;
        % depending on the split-category membership
        F.fillcolor={[1 1 1],[0.6 0.6 0.6],[0 0 0]};
        F.linecolor={[0 0 0],[0.6 0.6 0.6],[1 1 1]};
        F.markerfill={[0.6 0.6 0.6],[0 0 0]};
        F.markercolor={[0.6 0.6 0.6],[0 0 0]};
        F.mediancolor={[0 0 0],[1 1 1],[1 1 1]};
        c=c+1;
    case 'style_tukey'
        F.plotall=1;
        F.linecolor=[0.8 0.8 0.8];
        F.mediancolor=[1 1 1];
        F.fillcolor=[0.8 0.8 0.8];
        F.whissw = 0; % don't plot whisker inside the box.
        F.notch = 1;
        F.whiskerlength = 1.5;
        F.markertype = 'o';
        F.markercolor=[0 0 0];
        F.markerfill=[0 0 0];
        F.markersize=4;
        F.fillcolor={[1 1 1],[0.6 0.6 0.6],[0 0 0]};
        F.linecolor={[0 0 0],[0.6 0.6 0.6],[0 0 0]};
        F.markerfill={[1 1 1],[0 0 0]};
        F.mediancolor={[0 0 0],[1 1 1],[1 1 1]};
        c=c+1;
    case 'CAT'
            CAT=varargin{c+1};
            if (~isstruct(CAT))
                error('CAT has to be a structure');
            end;
            fields=fieldnames(CAT);
            for f=1:length(fields)
                fiel=getfield(CAT,fields{f});
                F=setfield(F,fields{f},fiel);
            end;
            c=c+2;
    otherwise
        error(sprintf('Unknown option: %s',varargin{c}));
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deal with selection (subset) variable
if (isempty(group))
    group=ones(size(y,1),1);
end;
[split,split_conv]=fac2int(split);
[group,group_conv]=fac2int(group);
if (exist('subset','var'))
    goodindx=find(subset);
else
    goodindx=[1:size(y,1)]';
end;
y=y(goodindx,:);
group=group(goodindx,:);
if (~isempty(split))
    split=split(goodindx,:);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deal with y-variables which have more than one column
[Ny p] = size(y);
if (p>1)
    y=reshape(y,prod(size(y)),1);
    group=repmat(group,p,1);
    for i=1:p
        split=[split;ones(Ny,1)*i];
    end;
    numsplitvars=1;
end
[dummy,numlvars]=size(group);
[dummy,numsplitvars]=size(split);
% register the variables that can be used for splitting
splitcat=unique(split,'rows');
numsplitcat=length(splitcat);
g=[group split];
[Ny n] = size(y);
[Ng numgrvar]=size(g);

if (n>1)
    error('data has to be a vector');
end

% Deal with grouping variable
D=pidata(g,y);
%numlvars=size(D{1,1},2);
glabels=makeglabels(D,numlvars);

% Now format the x-size depending on the grouping structure
[num_cat,dummy]=size(D);
if (F.linscale ==0 )
    x_coord=1;
    for c=2:num_cat
        for gv=1:numgrvar
            if(D{c,1}(gv)~=D{c-1,1}(gv))
                x_coord(c)=x_coord(c-1)+gap(gv);
                break;
            end;
        end;
    end;
    xlims = [min(x_coord)-0.5 max(x_coord)+0.5];
    F.w=gap(2)*F.boxwidth; 
else
    x_coord=[D{:,1}];
    size_x=max(x_coord)-min(x_coord);
    xlims = [min(x_coord)-0.06*size_x max(x_coord)+0.06*size_x];
    F.w = size_x/length(x_coord)*0.4; %boxwidth

end;

% Calculate scale
k = find(~isnan(y));
ymin = min(min(y(k)));
ymax = max(max(y(k)));
dy = (ymax-ymin)/20;
ylims = [(ymin-dy) (ymax+dy)];

% Scale axis for vertical or horizontal boxes.
cla
set(gca,'NextPlot','add','Box','off');
if ~F.flip
    axis([xlims ylims]);
    set(gca,'XTick',x_coord);
    set(gca,'YLabel',text(0,0,'Values'));
    if (isempty(g)), set(gca,'XLabel',text(0,0,'Column Number')); end
    %Turn off tick labels and axis label
    set(gca, 'XTickLabel','','UserData',numlvars);
    xlabel('');
    ylim = get(gca, 'YLim');

else
    axis([ylims xlims]);
    set(gca,'YTick',x_coord);
    set(gca,'XLabel',text(0,0,'Values'));
    if (isempty(g)), set(gca,'YLabel',text(0,0,'Column Number')); end
    set(gca, 'YTickLabel','','UserData',numlvars);
    ylabel('');
    xlim = get(gca, 'XLim');
    set(gca,'YDir','reverse');
end

plotall=2;
form=fieldnames(F);
for c=1:num_cat
    % Figure out the splitting plot-varaibles
    spcat=D{c,1}(numlvars+1:end);
    indxspcat=findrow(splitcat,spcat);
    if (isempty(indxspcat))
        indxspcat=1; 
    end; 
    fm=F;
    for f=1:length(form)
        fiel=getfield(F,form{f});
        if (iscell(fiel));
            fm=setfield(fm,form{f},fiel{mod(indxspcat-1,length(fiel))+1}); % set formating structure for this category
        end;
    end;
    if (sum(~isnan(D{c,2}))>0)
        [dummy,h(c)]=myboxutil(D{c,2}(~isnan(D{c,2})),x_coord(c),fm);
    end;
end;

% Place multi-line text approximately where tick labels belong
if (~F.xtickoff)
    for j=1:num_cat
        if (~F.flip)
            ht = text(x_coord(j),ylim(1),glabels{j,1},'HorizontalAlignment','center',...
                'VerticalAlignment','top', 'UserData','xtick');
        else
              ht = text(xlim(1),x_coord(j),glabels{j,1},'HorizontalAlignment','center',...
                  'VerticalAlignment','top', 'UserData','ytick');
        end;
    end
end

% Add legend if necessary
if (~isempty(split))
    Split_groups=vertcat(D{:,1});
    Split_groups=Split_groups(:,numlvars+1:end);
    plotlegend(h(1:numsplitcat),leg,Split_groups(1:numsplitcat,:),split_conv,leglocation);
end;

set(gca,'NextPlot','replace');

% Store information for gname: this might be cool!
% set(gca, 'UserData', {'boxplot' xvisible gorig vert});

function resizefcn(f)
% Adjust figure layout to make sure labels remain visible
h = findobj(f, 'UserData','xtick');
if (isempty(h))
    set(f, 'ResizeFcn', '');
    return;
end
ax = get(f, 'CurrentAxes');
nlines = get(ax, 'UserData');

% Position the axes so that the fake X tick labels have room to display
set(ax, 'Units', 'characters');
p = get(ax, 'Position');
ptop = p(2) + p(4);
if (p(4) < nlines+1.5)
    p(2) = ptop/2;
else
    p(2) = nlines + 1;
end
p(4) = ptop - p(2);
set(ax, 'Position', p);
set(ax, 'Units', 'normalized');

% Position the labels at the proper place
xl = get(gca, 'XLabel');
set(xl, 'Units', 'data');
p = get(xl, 'Position');
ylim = get(gca, 'YLim');
p2 = (p(2)+ylim(1))/2;
for j=1:length(h)
    p = get(h(j), 'Position') ;
    p(2) = p2;
    set(h(j), 'Position', p);
end
