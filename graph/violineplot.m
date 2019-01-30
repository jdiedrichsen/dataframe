function [x_coord,MEAN,MEDIAN,Ndata]=violineplot(xvar,y,varargin)
% Synopsis
% [x_coord,MEAN,MEDIAN,Ndata]=violineplot(xvar,y,varargin)
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
%       'linewidth',size     : width of the lines on bars   
%       'facecolor',[r g b]  : Facecolor of the bars  
%       'edgecolor',[r g b]  : Edgecolor of the bars  
%       'CAT', CAT           : Structure of formating options 
%       'gapwidth', [w1 w2 w3..]: Width of gap (relative to bar) for
%                           different levels of grouping (default [0.5 0 0]
%       'XTickLabel', {}:   Labels for the X-axs
%    Predetermined styles 
%       'style_rainbow'      : Colorful style 
%       'sytle_bold'         : Bold bars and error bars 
%   Data processing options 
%       'meanfcn'       : function for mean
%       'medianfcn'     : function for calculating median
%                           varplot will use these numbers for the size of the error bars 
%       'split',var   : Variable to split the data by. Seperate lines are
%                        drawn per value of the split-var 
%       'subset'      : Plots only a subset of the data
%       'leg'         : Legend, either cell with names or 'auto'
%       'leglocation','north' : Legend location       
% 
% Example:
%   y1=randn(100,1);
%   y2=1+randn(100,1);
%   y3=2+randn(100,1)*1.5;
%   y4=5+randn(100,1)*0.5;
%   
%   x=kron([1:4]',ones(100,1));
%   
%   violineplot(x,[y1;y2;y3;y4],'edgecolor','none','meancolor','r');
% 
% 
% Based on: barplot.m in dataframe toolbox by Joern Diedrichsen
% 
% v1.0-beta: Uses ksdensity.m function
% 
% by a-yokoi (2017)
% 
if (nargin==1 & length(x(:))==1 & ishandle(x)), resizefcn(x); return; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set defaults for all plots 
F.facecolor={[0.5 0.5 0.5],[1 1 1],[0 0 0],[1 1 0],[0 1 1],[1 0 1]};
F.edgecolor=[0 0 0];
F.linewidth=1;
F.meancolor=[0 0 0];
F.mediancolor=[0 0 0];
flip=0;
barwidth=1;
gapwidth=[0.5 0 0 0];
leg=[];
leglocation='NorthWest';
meanfcn='nanmean';
medianfcn='nanmedian';
numxvars=size(xvar,2);
split=[];numsplitvars=0;
goodindx=[1:size(y,1)]';
npoints = 100;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deal with the varargin's 
c=1;
while(c<=length(varargin))
    switch(varargin{c})
         case {'gapwidth','XTickLabel','meanfcn','medianfcn','leg','leglocation','flip'}
            eval([varargin{c} '=varargin{c+1};']);
            c=c+2;
        case {'facecolor','edgecolor','linewidth','meancolor','mediancolor','barwidth'}
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
%  Get kernel density estimation for each category 
P = pidata([xvar split],y); N = size(P,1); 
R = []; ; ymin = []; ymax = []; MEAN = []; MEDIAN = [];
for n=1:N
    MEAN(n,1)   = feval(meanfcn,P{n,2});
    MEDIAN(n,1) = feval(medianfcn,P{n,2});
    R           = [R;P{n,1}];
    Ndata(n,1)  = length(P{n,2});
    
    if ~all(isnan(P{n,2}));
        [f,xi]      = ksdensity(P{n,2}(~isnan(P{n,2}))); % TODO: implement 'npoints','bandwidth' options
        Dens{n,1}   = f;
        Dens{n,2}   = xi;
        ymin        = min([ymin,min(xi)]);
        ymax        = max([ymax,max(xi)]);
    else
        Dens{n,1}   = [];
        Dens{n,2}   = [];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Deal with x-category 
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
xmin    = min(x_coord);
xmax    = max(x_coord);
dx      = (xmax-xmin)/(3*length(x_coord));
xlims   = [(xmin-0.3-barwidth/2) (xmax+0.3+barwidth/2)];
% ymin    = min(min(PLOT),0);
% ymax    = max(max(PLOT),0);
dy      = (ymax-ymin)/20;
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
    if (~isempty(Dens{i,1}))
        XX=dx*[Dens{i,1},-Dens{i,1}(end:-1:1)]+x_coord(i);
        YY=[Dens{i,2},Dens{i,2}(end:-1:1)];
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
        else
            h(i)=patch(YY,XX,fm.facecolor);
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
        
        % show mean and median
        K = Dens{i,2}; D = Dens{i,1};
        [~,idx] = min(abs(K-MEAN(i)));
        drawline(MEAN(i),'dir','horz','lim',x_coord(i)+[-D(idx),D(idx)]*dx,...
            'color',F.meancolor,'linewidth',F.linewidth);
        
        [~,idx] = min(abs(K-MEDIAN(i)));
        drawline(MEDIAN(i),'dir','horz','lim',x_coord(i)+[-D(idx),D(idx)]*dx,...
            'color',F.mediancolor,'linewidth',F.linewidth);
    end
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

