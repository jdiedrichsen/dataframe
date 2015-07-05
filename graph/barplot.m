function [x_coord,PLOT,ERROR]=barplot(xvar,y,varargin)
% Synopsis
%  [x_coord,PLOT,ERROR]=barplot(xvar,y,vararginy) 
% Description
%  Y: dependent variable [N*1]
%     if Y is a N*p varaible, then different lines are plotted for 
%     different varaibles (like split). Split can't be used anymore 
%  xvar: independent variables [N*c], with c>1 a hierarchical grouping is used 
%
%  varargin:
%   Format options 
%       in general: 'formating_option', value,... 
%       If a single value is give, the formatting option is applied to all
%       split-categories. If a cell array of values is given, the first value
%       is for the first split category etc. 
% 
%       'barwidth'           : Width of the bars 
%       'linewidth',size     : width of the lines on bars   
%       'facecolor',[r g b]  : Facecolor of the bars  
%       'edgecolor',[r g b]  : Edgecolor of the bars  
%       'errorwidth',size    : Width of the error bars 
%       'errorcolor',[r g b] : Color of the error bars 
%       'CAT', CAT           : Structure of formating options 
%       'gapwidth', [w1 w2 w3..]: Width of gap (relative to bar) for
%                           different levels of grouping (default [0.5 0 0]
%       'XTickLabel', {}:   Labels for the X-axs
%    Predetermined styles 
%       'style_rainbow'      : Colorful style 
%       'sytle_bold'         : Bold bars and error bars 
%   Data processing options 
%       'plotfcn'   : function over data of what should be plotted: default 'mean'
%       'errorfcn'  : function over data to determine size of error bars: default 'stderr'
%                     if just one error function is given, we assume
%                     symmetric error bars
%                     if errorfcn is a row vector of numbers (number of elements = number of categories)
%                     varplot will use these numbers for the size of the error bars 
%       'split',var   : Variable to split the data by. Seperate lines are
%                        drawn per value of the split-var 
%       'subset'      : Plots only a subset of the data
%       'leg'         : Legend, either cell with names or 'auto'
%       'leglocation','north' : Legend location       
% v.1.0 Joern Diedrichsen 10/1/2005 
% v.1.1 Support for leglocation added. Fixed bug in nameing of x-axis 
% v.1.2 Legend for splitting corrected 
% v.1.3 Gapwidth made usuable for different gaps depending on grouping
% order (again) 
% v.1.4 Make CAT option work properly like intended 
if (nargin==1 & length(x(:))==1 & ishandle(x)), resizefcn(x); return; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set defaults for all plots 
F.facecolor={[0.5 0.5 0.5],[1 1 1],[0 0 0],[1 1 0],[0 1 1],[1 0 1]};
F.edgecolor=[0 0 0];
F.linewidth=1;
F.errorwidth=1;
F.errorcolor=[0 0 0];
flip=0;
barwidth=1;
capwidth=0.2;
gapwidth=[0.5 0 0 0];
leg=[];
leglocation='NorthWest';
plotfcn='nanmean';
errorfcn='stderr';
numxvars=size(xvar,2);
split=[];numsplitvars=0;
goodindx=[1:size(y,1)]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deal with the varargin's 
c=1;
while(c<=length(varargin))
    switch(varargin{c})
         case {'gapwidth','XTickLabel','plotfcn','errorfcn','leg','leglocation','barwidth','flip','capwidth'}
            eval([varargin{c} '=varargin{c+1};']);
            c=c+2;
        case {'facecolor','edgecolor','linewidth','errorcolor','errorwidth'}
            eval(['F.' varargin{c} '=varargin{c+1};']);
            c=c+2;
        case 'split'
            split=varargin{c+1};c=c+2;
            [dummy,numsplitvars]=size(split);
        case 'subset'
            goodindx=find(varargin{c+1});
            c=c+2;
        case 'style_rainbow'
            F.facecolor={[1 0 0],[0 1 0],[0 0 1],[1 1 0],[0 1 1],[1 0 1]};
            F.edgecolor={[1 0 0],[0 1 0],[0 0 1],[1 1 0],[0 1 1],[1 0 1]};
            c=c+1;
        case 'style_bold'
            F.facecolor={[0 0 0],[1 1 1],[0.2 0.2 0.2],[0.8 0.8 0.8]};
            F.edgecolor=[0 0 0]; 
            F.errorcolor=[0 0 0]; 
            F.errorwidth=2;
            F.linewidth=2;
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
            error('Unknown option\n');
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% re-code cell array  
if (isempty(xvar))
    xvar=ones(size(y,1),1);
end;
[xvar,xvar_conv]=fac2int(xvar);
numxvars=size(xvar,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deal with selection (subset) variable 
y=y(goodindx,:);
xvar=xvar(goodindx,:);
if (~isempty(split))
    split=split(goodindx,:);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deal with y-variables which have more than one column 
[Nx p] = size(y);
if (p>1)  
    y=reshape(y,prod(size(y)),1);
    xvar=repmat(xvar,p,1);
    for i=1:p
        split=[split;ones(Nx,1)*i];
    end;
end
if ~isempty(split)
    [split,split_conv]=fac2int(split);
end;    
numsplitvars=size(split,2);
splitcat=unique(split,'rows');
numsplitcat=length(splitcat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  calculate the mean plot and errorbar size for each category 
[PLOT,R]=pivottable([xvar split],[],y,plotfcn);
if (ischar(errorfcn))
    [ERROR,R]=pivottable([xvar split],[],y,errorfcn);
elseif (~isempty(errorfcn))
    ERROR=errorfcn';
end;
[Xcategory,dummy,xcat]=unique(R,'rows');
if numsplitvars>0
    [Splitcategory,dummy,splitcat]=unique(R(:,numxvars+1:numxvars+numsplitvars),'rows');
else 
    splitcat=ones(size(R,1),1);
end;
glabels=makexlabels(Xcategory(:,1:numxvars),xvar_conv);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now format the x-size depending on the grouping structure: respect
% different gapwidth for different levels 
x_coord=1;
for i=2:size(R,1)
    diffxcat=find(R(i,:)~=R(i-1,:));
    x_coord(i)=x_coord(i-1)+1;
    if ~isempty(diffxcat)
        x_coord(i)=x_coord(i)+gapwidth(diffxcat(1)); 
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate scale 
xmin = min(x_coord);
xmax = max(x_coord);
xlims = [(xmin-0.3-barwidth/2) (xmax+0.3+barwidth/2)];
if (exist('ERROR','var'))
    ymin = min(min(PLOT-ERROR),0);
    ymax = max(max(PLOT+ERROR),0);
else 
    ymin = min(min(PLOT),0);
    ymax = max(max(PLOT),0);
end;    
dy=(ymax-ymin)/20;
if ymin<0 ymin=ymin-dy;end;
if ymax>0 ymax=ymax+dy;end;
ylims = [(ymin) (ymax)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scale axis for vertical or horizontal boxes.
% deal with hold on option.
cax = newplot;
holding=get(cax,'NextPlot');
if (strcmp(holding,'add'))
    xlim_old=get(cax,'XLim');
    ylim_old=get(cax,'YLim');
    xlims=[min(xlims(1),xlim_old(1)) max(xlims(2),xlim_old(2))];
    ylims=[min(ylims(1),ylim_old(1)) max(ylims(2),ylim_old(2))];
else
    % clf reset;
end;
set(gca,'Box','off');
if (ylims(2)-ylims(1))<0.0001
    ylims(1)=mean(ylims)-0.0001;
    ylims(2)=mean(ylims)+0.00015;
end;
if ~flip
    axis([xlims ylims]);
    set(gca,'XTick',x_coord);
    set(gca,'XTickLabel',glabels);
    set(gca,'YLabel',text(0,0,'Values'));
    %if (isempty(g)), set(gca,'XLabel',text(0,0,'Column Number')); end
else
    axis([ylims xlims]);
    set(gca,'YTick',x_coord);
    set(gca,'XLabel',text(0,0,'Values'));
    set(gca,'YDir','reverse');
    %if (isempty(g)), set(gca,'YLabel',text(0,0,'Column Number')); end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform plotting 
form=fieldnames(F); 
for i=1:length(x_coord)
    XX=[-barwidth/2 -barwidth/2 +barwidth/2 +barwidth/2]+x_coord(i);
    YY=[0 PLOT(i) PLOT(i) 0]; 
    fm=F;
    for f=1:length(form)
        fiel=getfield(F,form{f}); 
        if (iscell(fiel)); 
            formcat=mod(splitcat(i)-1,length(fiel))+1;
            if (splitcat(i)>length(fiel))
                warning('Too many splits: reusing format');
            end;
            fm=setfield(fm,form{f},fiel{formcat}); % set formating structure for this category
        end;
    end; 
   if (~flip) 
        h(i)=patch(XX,YY,fm.facecolor);
        errorbars(x_coord(i),PLOT(i),ERROR(i),'linecolor',fm.errorcolor,'linewidth',fm.errorwidth,'cap',capwidth);
   else 
        h(i)=patch(YY,XX,fm.facecolor);
        errorbars(PLOT(i),x_coord(i),ERROR(i),'linecolor',fm.errorcolor,'linewidth',fm.errorwidth,...
            'cap',capwidth,'orientation','horz');
   end; 
   if (isfield(F,'edgecolor'))
        set(h(i),'EdgeColor',fm.edgecolor);
    end;
    if (isfield(F,'facecolor'))
        set(h(i),'FaceColor',fm.facecolor);
    end;
    if (isfield(F,'linewidth'))
        set(h(i),'LineWidth',fm.linewidth);
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do legend 
if (~isempty(split))
    plotlegend(h(1:numsplitcat),leg,splitcat,split_conv,leglocation);
else 
    legend(gca,'off');
end;

set(gca,'NextPlot',holding);

figure(gcf);    % Bring figure to front on Mac platform

