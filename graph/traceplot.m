function PLOT=traceplot(t,data,varargin);
% function T=traceplot(time,rawtraces,varargin);
% makes a plot to compare the mean of temporal time series between conditions
% t: is a 1xT vector of times 
% data: is a NxT matrix of time series 
% VARARGIN:
%   'subset',index: restrict the plotting to a subset of the data 
%   'split',var: Plot different lines for each category of var 
%   'leg','auto'/{texts} : add a legend to the figure
%   'errorfcn','std'/'stderr': Add shapded error bar area behind trace
% formating options: 
%   in general: 'formating_option', value,... 
%   If a single value is give, the formatting option is applied to all
%   split-categories. If a cell array of values is given, the first value
%   is for the first split category etc. 
%   'linecolor',[r g b]     : Line color 
%   'linestyle',{'-',':',...}: Line Style option
%   'linewidth',x           : line width 
%   'patchcolor',[r g b]    : Color of the patch 
%   'CAT',CAT:              : A structure of formating options 
% v 1.1 Displaying one timeseries per category is possible now
%       recycling of format in split categories 
% v 1.2 cell arrays can be given for any formating option 
% v.1.3 Added support for leglocation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Defaults and deal with options 

F.linewidth=1;
F.linecolor={[0 0 1],[1 0 0],[0 1 0],[0 0 0],[1 1 0]};
F.patchcolor={[0 0 1],[1 0 0],[0 1 0],[0 0 0],[1 1 0]};
F.linestyle='-';
F.transp=0.3;
F.markertype={'none'};
F.markerfill={[0 0 1],[1 0 0],[0 1 0],[0 0 0],[1 1 0]};
F.markercolor=[0 0 0];
F.markersize=4;
leg={};
plotfcn='nanmean';
errorfcn='';
subset=[];
split=[];
XLim=[];
YLim=[];
leglocation='NorthEast';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deal with the varargin's
c=1;
while(c<=length(varargin))
    switch(varargin{c})
        case {'subset','split','leg','leglocation','plotfcn','errorfcn','XLim','YLim'};
            eval([varargin{c} '=varargin{c+1};']);
            c=c+2;
        % Style tabs: single value sets it for all values, cell array puts
        % in the cat structure 
        case {'linewidth','linecolor','patchcolor','linestyle','transp','markertype','markersize','markercolor','markerfill'}
            v=varargin{c+1}; 
            eval(['F.' varargin{c} '=v;']);  
            c=c+2;
        case 'style_3x3'
            F.linecolor={[0 0 1],[0 0 1],[0 0 1],[1 0 0],[1 0 0],[1 0 0],[0 1 0],[0 1 0],[0 1 0]};
            F.patchcolor={[0 0 1],[0 0 1],[0 0 1],[1 0 0],[1 0 0],[1 0 0],[0 1 0],[0 1 0],[0 1 0]};
            F.linestyle={'-',':','--','-',':','--','-',':','--'};
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check proper sizing of Input arguments 
[a,T]=size(t);
if (a>1) 
    t=t';
    [a,T]=size(t);
end;
if (a>1) error('Time vector must be a vector, not matrix'); end;
[N,T1]=size(data);
if (T~=T) error('Data must be a NxT matrix'); end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deal with subset and splitby arguments 
if (isempty(split))
    split=ones(N,1);
end;
[split,split_conv]=fac2int(split);
if (~isempty(subset))
    data=data(subset,:);
    split=split(subset,:);
end;
A=pidata(split,data);
numcats=size(A,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do the plotting 
holding=get(gca,'NextPlot');
form=fieldnames(F); 
for c=1:numcats
    fm=F;
    for f=1:length(form)
        fiel=getfield(F,form{f}); 
        if (iscell(fiel)); 
            fm=setfield(fm,form{f},fiel{mod(c-1,length(fiel))+1}); % set formating structure for this category
        end;
    end; 
    if (size(A{c,2},1)==1) 
        PLOT(c,:)=A{c,2};
    else
        PLOT(c,:)=fcneval(plotfcn,(A{c,2}));
    end;
    h(c)=plot(t,PLOT(c,:));hold on;
    set(h(c),'LineWidth',fm.linewidth,'Color',fm.linecolor,'LineStyle',fm.linestyle,'Marker',fm.markertype,'MarkerSize',fm.markersize,'MarkerEdgeColor',fm.markercolor,'MarkerFaceColor',fm.markerfill);
    if (~isempty(errorfcn) & size(A{c,2},1)>1)
        ERR(c,:)=fcneval(errorfcn,A{c,2});
        p(c)=plotshade(t,PLOT(c,:),ERR(c,:),'patchcolor',fm.patchcolor,'transp',fm.transp);hold on;
    end;
end;
set(gca,'Box','off','NextPlot',holding);
if (~isempty(XLim))
    set(gca,'XLim',XLim);
end;
if (~isempty(YLim))
    set(gca,'YLim',YLim);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do legend 
if (~isempty(split))
    R=vertcat(A{:,1});
    plotlegend(h,leg,R,split_conv,leglocation);
end;

figure(gcf);