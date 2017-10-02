function varargout=scatterplot3(x,y,z,varargin)
%  function scatterplot3(x,y,z,varargin)
% Description
%  varargin:
%   Format options (for all symbols)
%       'markertype',{o s v ^...}
%       'markercolor',[r g b]
%       'markerfill',[r g b]
%       'markersize',size
%               These can also be cell arrays for splitting
%   Other commands:
%       'CAT',cat        : Stucture with fields for a fix formating.
%                           if string, uses predifined style.
%       'subset',indx    : plots only a subset of the data
%       'split',splitby  : splits data by vaiable splitby
%       'color',x      : Uses current color map to shade the circle in
%                           color corresponding to the range.
%       'bubble',x    : Uses to x variable to determine markersize 
%       'label',label:    Label each point with a number or string
%       'labelcolor',x : color of text labels 
%       'labelsize',x : size of text labels 
%       'labelfont',x : font of labels. 
%       'labelformat','%d' : format string of labels  
%       'colormap', CM: sets colormap
%       'leg',{}/'auto'  : specified legend or auto
%       'draworig':       Draws origin into the graph
% Joern Diedrichsen (j.diedrichsen@bangor.ac.uk)
% First version 8/2014

[Nx nx] = size(x);
[Ny ny] = size(y); 
[Nz nz] = size(z); 
if (nx>1 || ny>1 || nz>1)
    error('data has to be a row-vector');
end

% Set defaults for all plots
colormap=hot;
markersize=4;
markertype= {'o','o','o','o','o','o','s','s','s','s','s','s','v','v','v','v','v','v'};
markercolor={[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1]};
markerfill={[0 0 0],[1 0 0],[0 0 1],[1 1 1],[1 1 1],[1 1 1],[0 0 0],[1 0 0],[0 0 1],[1 1 1],[1 1 1],[1 1 1],[0 0 0],[1 0 0],[0 0 1],[1 1 1],[1 1 1],[1 1 1]};
labelcolor = [0 0 0]; 
draworig=0;
identity=0; 
label=[];
labelformat='%d';
labelsize=10; 
labelfont='arial'; 
leg=[];
CAT=[];
leglocation='SouthEast';
% Deal with the varargin's
split=[];
subset=ones(size(y,1),1);
color=[];
bubble=[];
bubble_minsize=3;
bubble_maxsize=30;
variables={'markertype','markercolor','markerfill','markersize','CAT',...
    'subset','split','leg','leglocation','color',...
    'label','labelcolor','labelsize','labelfont',...
    'colormap',...
    'bubble','bubble_minsize','bubble_maxsize'};
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
F.labelcolor=labelcolor; 

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
if (dx<eps) dx=1;end;
xlims = [(xmin-dx) (xmax+dx)];

ymin = min(y);
ymax = max(y);
dy = (ymax-ymin)/20;
if (dy<eps) dy=1;end;
ylims = [(ymin-dy) (ymax+dy)];

zmin = min(z);
zmax = max(z);
dz = (zmax-zmin)/20;
if (dz<eps) dz=1;end;
zlims = [(zmin-dz) (zmax+dz)];

repl_state=get(gca,'NextPlot');
if (strcmp(repl_state,'replace'))
    cla;
else 
    xlims_old=get(gca,'XLim'); 
    ylims_old=get(gca,'YLim'); 
    zlims_old=get(gca,'ZLim'); 
    xlims=[min(xlims(1),xlims_old(1)) max(xlims(2),xlims_old(2))]; 
    ylims=[min(ylims(1),ylims_old(1)) max(ylims(2),ylims_old(2))]; 
    zlims=[min(zlims(1),zlims_old(1)) max(zlims(2),zlims_old(2))]; 
end;
set(gca,'NextPlot','add');
set(gca,'Box','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deal with split
form=fieldnames(F);
if (isempty(split))
    D{1,2}=[x y z];
    numsplitcat=1;
else
    D=pidata(split,[x y z]);
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
    h(c)=plot3(D{c,2}(:,1),D{c,2}(:,2),D{c,2}(:,3),'k.');
    if (isempty(color) & isempty(bubble))
        set(h(c),'Marker',fm.markertype,'MarkerSize',fm.markersize,...
                'MarkerEdgeColor',fm.markercolor,'MarkerFaceColor',fm.markerfill);
    elseif (~isempty(color))
        for i=1:length(x)
            set(plot3(x(i),y(i),z(i),'k.'),'Marker',fm.markertype,'MarkerSize',fm.markersize,...
                'MarkerEdgeColor',colormap(colorz(i),:),'MarkerFaceColor',colormap(colorz(i),:));hold on;
        end;
    elseif (~isempty(bubble))
        for i=1:length(x)
            set(plot3(x(i),y(i),z(i),'k.'),'Marker',fm.markertype,'MarkerSize',bubble(i)*(bubble_maxsize-bubble_minsize)+bubble_minsize,...
                'MarkerEdgeColor',fm.markercolor,'MarkerFaceColor',fm.markerfill);hold on;
        end;
    end;
end;

set(gca,'XLim',xlims,'YLim',ylims,'ZLim',zlims); 
set(gca,'ZGrid','on','XGrid','on','YGrid','on'); 

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
    xoffset=(xlims(2)-xlims(1))/40;
    yoffset=(ylims(2)-ylims(1))/40;
    zoffset=(zlims(2)-zlims(1))/40;
    if (iscell(label))
        label={label{find(subset)}};
        for i=1:length(x)
            th=text(x(i)+xoffset,y(i)+yoffset,z(i)+zoffset,label{i});
            set(th,'Color',labelcolor,'FontSize',labelsize,'FontName',labelfont); 
        end;
    else
        label=label(find(subset));
        for i=1:length(x)
            th=text(x(i)+xoffset,y(i)+yoffset,z(i)+zoffset,sprintf(labelformat,label(i)));
            set(th,'Color',labelcolor,'FontSize',labelsize,'FontName',labelfont); 
        end;
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do legend
% Add legend if necessary
if (~isempty(split))
    Split_groups=vertcat(D{:,1});
    plotlegend(h,leg,Split_groups,split_conv,leglocation);
end;
set(gca,'NextPlot',repl_state);
figure(gcf);    % Bring figure to front on Mac platform

