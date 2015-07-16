function [x_coord,PLOT,ERROR]=lineplot(xvar,y,varargin)
% Synopsis
%  [xcoord,PLOT,ERROR]=lineplot(xvar,y,varargin)
% Description
%  xvar: independent variables [N*c], with c>1 a hierarchical grouping is used
%  Y: dependent variable [N*1]
%     if Y is a N*p varaible, then different lines are plotted for
%     different variables (like split). In this case, split can't be used anymore
%
%  varargin:
%   Format options 
%       in general: 'formating_option', value,... 
%       If a single value is give, the formatting option is applied to all
%       split-categories. If a cell array of values is given, the first value
%       is for the first split category etc. 
%       'markersize',size    : Size of the marker symbols
%       'markertype',type    : Type ('o','s','v','^') of the marker
%       'markercolor',[r g b]: Color of the marker edge
%       'markerfill',[r g b] : Color of the marker fill
%       'linecolor',[r g b]  : Color of the Line
%       'linewidth',width    : Width of the Line
%       'errorbars',{'plusminus','','shade'} determines style of errorbars
%       'errorcolor',[r g b] : Color of error bars
%       'errorcap'           : Width of the cap of error bars
%       'errorwidth',width   : Width of error bars
%       'CAT', CAT           : Structure of formating options 
%   Other options 
%       'leg'                : Legend, either cell with names or 'auto'
%       'leglocation','north': Legend location
%       'gap'                : For multiple x-categories, it determines the
%                              extra spacing of each category. Gap [1 0.5] means
%                              that the gap introduced by the 2nd x-variable
%                              (lower category) is 0.5, and a split in the
%                              1st x-variable (higher category) introduces a gap
%                              gap of 1. 
%       'xcat',xlabel        : Displays x-label to differentiate multiple X-categories plotted
%                              if xlabel={}, only category values are plotted 
%                              if xlabel={'label1','label2'}, text labels are used.  
%    Predetermined styles
%       'style_symbols4*2'   : Square, circle,Triangle (up/down), in white and
%                              black
%       'style_thickline'    : Thick lines in different colors, square symbols, and error
%                              bars,different colors
%       'style_thickline2x3  : Dashed / nodashed in 3 different colors 
%       'style_shade'        : line with shades
%   Data processing options
%       'plotfcn'      : function over data of what should be plotted: default 'mean'
%       'errorfcn'     : function over data to determine size of error bars: default 'stderr'
%                        if just one error function is given, we assume
%                        symmetric error bars
%       'errorfcn_up'  : If given, error bars can be asymmetric
%       'errorfcn_down':
%       'errorval'     : Forces the error bars to a specific numerical
%                        height. For each point, lineplot determines the
%                        mean of errorval and then uses this value. Usually
%                        you use this, if you are passing one value per
%                        category.
%       'errorval_up'  : Forces the upper error bar to a specific numerical
%                        height.
%       'errorval_down': Forces the lower error bar to a specific numerical
%                        height.
%       'transformfcn' : All plots-elements (including error bars are
%                        transformed before plotting
%       'split',var    : Variable to split the data by. Seperate lines are
%                        drawn per value of the split-var
%       'group',var:     Draw line only within group, but not between groups
%       'subset'       : Plots only a subset of the data
%  EXAMPLE: for averaging of correlation after fisher-z transformation and
%       concurrently inverse fisher-z trasnform + correct standard errors:
%       lineplot(CORR,X,'plotfcn','mean(fisherz(x))',
%                       'errorfcn','stderr(fisherz(x))'
%                       'transformfcn','fisherinv';
%                         .....
%                       SHORTCUT: 'avrgcorr'
% v1.1: 12/14/05: Support for data with variation (constant data) is added
%       12/22/05: Warning instead of error when number of categories
%       exceeds the number of formats, recycling formats
% v1.2: 3/19/08: Olivier White added x-category labels 
% v1.3: 6/30/08: multiple category formating implemented 

if (nargin==1 & length(y(:))==1 & ishandle(y)), resizefcn(y); return; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set defaults values
F.linecolor=[0.8 0.8 0.8];
F.linewidth=1;
F.linestyle='-';
F.fillcolor=[0.8 0.8 0.8];
F.markertype={'o','o','^','^','s','s','v','v'};
F.markerfill={[0 0 0],[1 1 1],[0 0 0],[1 1 1],[0 0 0],[1 1 1],[0 0 0],[1 1 1]};
F.markercolor=[0 0 0];
F.markersize=4;
F.errorwidth=1;
F.errorcolor=[0.8 0.8 0.8];
F.errorbars='plusminus';
F.transp=0.3;
F.errorcap=[]; 

gap=[1 0.7 0.5 0.5];
leg=[];
catcol=[]; 
xcat=[];
flip=0;
leglocation='SouthEast';
plotfcn='mean';
errorfcn='stderr';
numxvars=size(xvar,2);
XTickLabel=0;
XCoord='auto';
split=[];numsplitvars=0;
goodindx=[1:size(y,1)]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deal with the varargin's
c=1;
while(c<=length(varargin))
    switch(varargin{c})
        case {'gap','XTickLabel','XCoord','plotfcn','errorfcn','errorfcn_up','errorfcn_down',...
                'errorval','errorval_up','errorval_down','leg','leglocation','xcat','flip','catcol'}
            eval([varargin{c} '=varargin{c+1};']);
            c=c+2;
        % Style tabs: single value sets it for all values, cell array puts
        % in the cat structure 
        case {'markertype','markerfill','linecolor','linewidth','linestyle',...
                'markercolor','markertype','markersize','errorcolor','errorwidth','errorbars','errorcap','shadecolor'}
            v=varargin{c+1}; 
            eval(['F.' varargin{c} '=v;']);  
            c=c+2;
        case 'subset'
            goodindx=find(varargin{c+1});
            c=c+2;
        case 'split'
            split=varargin{c+1};c=c+2;
            [dummy,numsplitvars]=size(split);
        case 'avrgcorr'
            plotfcn='mean(fisherz(x))';
            errorfcn='stderr(fisherz(x))';
            transformfcn='fisherinv(x)';
            type='avrgcorr';
            c=c+1;
        case 'transformfcn'
            transformfcn=varargin{c+1};c=c+2;
        case 'style_shade'
            F.linecolor={[0 0 1],[1 0 0],[0 1 0],[1 0 1],[0 1 1],[0.7 0.7 0.7],[1 1 0]};
            F.markercolor={[0 0 1],[1 0 0],[0 1 0],[1 0 1],[0 1 1],[0.7 0.7 0.7],[1 1 0]};
            F.errorcolor={[0 0  1],[1 0 0],[0 1 0],[1 0 1],[0 1 1],[0.7 0.7 0.7],[1 1 0]};
            F.markertype='none';
            F.markersize=1;
            F.linewidth=2;
            F.shadecolor={[0 0  1],[1 0 0],[0 1 0],[1 0 1],[0 1 1],[0.7 0.7 0.7],[1 1 0]};
            F.errorbars='shade';
            c=c+1;
        case 'style_symbols4*2'
            F.markertype={'o','o','^','^','s','s','v','v'};
            F.markerfill={[0 0 0],[1 1 1],[0 0 0],[1 1 1],[0 0 0],[1 1 1],[0 0 0],[1 1 1]};c=c+1;
        case 'style_thickline'
            F.linecolor={[0 0 1],[1 0 0],[0 1 0],[1 0 1],[0 1 1],[0.7 0.7 0.7],[1 1 0]};
            F.markercolor={[0 0 1],[1 0 0],[0 1 0],[1 0 1],[0 1 1],[0.7 0.7 0.7],[1 1 0]};
            F.errorcolor={[0 0  1],[1 0 0],[0 1 0],[1 0 1],[0 1 1],[0.7 0.7 0.7],[1 1 0]};
            F.markertype='s';
            F.markersize=2.5;
            F.linewidth=2.5;
            F.errorwidth=1;
            F.shadecolor={[0 0  1],[1 0 0],[0 1 0],[1 0 1],[0 1 1],[0.7 0.7 0.7],[1 1 0]};
            c=c+1;
        case 'style_thickline2x3'
            F.linecolor={[0 0 1],[0 0 1],[1 0 0],[1 0 0],[0 1 0],[0 1 0]};
            F.markercolor={[0 0 1],[0 0 1],[1 0 0],[1 0 0],[0 1 0],[0 1 0]};
            F.errorcolor={[0 0 1],[0 0 1],[1 0 0],[1 0 0],[0 1 0],[0 1 0]};
            F.linestyle={'-','--','-','--','-','--'};
            F.markertype='s';
            F.markersize=2.5;
            F.linewidth=2.5;
            F.errorwidth=1;
            c=c+1;
        case 'style_thickline3x3'
            F.linecolor={[0 0 1],[0 0 1],[0 0 1],[1 0 0],[1 0 0],[1 0 0],[0 1 0],[0 1 0],[0 1 0]};
            F.markercolor={[0 0 1],[0 0 1],[0 0 1],[1 0 0],[1 0 0],[1 0 0],[0 1 0],[0 1 0],[0 1 0]};
            F.errorcolor={[0 0 1],[0 0 1],[0 0 1],[1 0 0],[1 0 0],[1 0 0],[0 1 0],[0 1 0],[0 1 0]};
            F.linestyle={'-','--',':','-','--',':','-','--',':'};
            F.markertype={'s','v','o','s','v','o','s','v','o'};
            F.markersize=2.5;
            F.linewidth=2.5;
            F.errorwidth=1;
            c=c+1;
        case 'style_thicklinegray'
            C=[0:0.2:1]';C=repmat(C,1,3);
            F.linecolor={C(1,:),C(2,:),C(3,:),C(4,:),C(5,:),C(6,:)};
            F.markercolor={C(1,:),C(2,:),C(3,:),C(4,:),C(5,:),C(6,:)};
            F.errorcolor={C(1,:),C(2,:),C(3,:),C(4,:),C(5,:),C(6,:)};
            F.markertype='s';
            F.markersize=2.5;
            F.linewidth=2.5;
            F.errorwidth=1;
            c=c+1;
        case 'style_shadeline'
            F.linecolor={[0.2 0.2 0.2],[0.3 0.3 0.3],[0.4 0.4 0.4],[0.5 0.5 0.5],[0.6 0.6 0.6],[0.7 0.7 0.7],[0.8 0.8 0.8]};
            F.markertype='none';
            F.linewidth=2;
            F.errorwidth=3;
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
% check if size information is congruent 
[N,p]=size(y); 
[Nx,px]=size(xvar);
if (N~=Nx) 
    error('x and y arguments have to have the same number of rows');
end; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% re-code cell array
[xvar,xvar_conv]=fac2int(xvar);
if ~isempty(split)
    [split,split_conv]=fac2int(split);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deal with selection (subset) variable
y=y(goodindx,:);
xvar=xvar(goodindx,:);
if (~isempty(split))
    split=split(goodindx,:);
end;
if (isempty(y))
    return;
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
    [split,split_conv]=fac2int(split);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  calculate the mean plot and errorbar size for each category
[PLOT,R,C]=pivottable(split,xvar,y,plotfcn);
if (all(isnan(PLOT(:))))
    error('no data to plot - all is nan');
end;

if (exist('errorval'))
    errorval=errorval(goodindx,:); 
    [ERROR,R,C]=pivottable(split,xvar,errorval,'mean');
    ERROR_UP=ERROR;
    ERROR_DOWN=ERROR;
else
    if (exist('errorval_up'))
        errorval_up=errorval_up(goodindx,:);
        errorval_up=reshape(errorval_up,prod(size(errorval_up)),1);
        [ERROR_UP,R,C]=pivottable(split,xvar,errorval_up,'mean');
    end
    if (exist('errorval_down'))
        errorval_down=errorval_down(goodindx,:);
        errorval_down=reshape(errorval_down,prod(size(errorval_down)),1);
        [ERROR_DOWN,R,C]=pivottable(split,xvar,errorval_down,'mean');
    end
    if (exist('errorfcn_up'))
        [ERROR_UP,R,C]=pivottable(split,xvar,y,errorfcn_up);
    end; 
    if (exist('errorfcn_down'))
        [ERROR_DOWN,R,C]=pivottable(split,xvar,y,errorfcn_down);
    end;
    if (~isempty(errorfcn) & ~exist('ERROR_UP') & ~ exist('ERROR_DOWN'))
        [ERROR,R,C]=pivottable(split,xvar,y,errorfcn);
        ERROR_UP=ERROR;
        ERROR_DOWN=ERROR;
    end;
end; 


if (exist('transformfcn'))
    x=PLOT;
    TPLOT=eval(transformfcn);
    x=PLOT+ERROR;
    ERROR_UP=eval(transformfcn)-TPLOT;
    x=PLOT-ERROR;
    ERROR_DOWN=-(eval(transformfcn)-TPLOT);
    PLOT=TPLOT;
end;

[numxcat,numxvars]=size(C);
[numsplitcat,numsplitvars]=size(R);
%numlvars=size(D{1,1},2);
glabels=makexlabels(C,xvar_conv);



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now format the x-size depending on the grouping structure
l_from=1;
l_to=[];
if (numxvars==1)
    x_coord=C;
else
    x_coord=1;
    for c=2:numxcat
        for gv=1:numxvars
            if(C(c,gv)~=C(c-1,gv))
                x_coord(c,1)=x_coord(c-1)+gap(gv);
                if (gv~=numxvars)
                    l_to(end+1)=c-1;
                    l_from(end+1)=c;
                end;
                break;
            end;
        end;
    end;
    if (strcmp(XCoord,'last'))
        x_coord=C(end,:)';
    end;
end;
l_to(end+1)=numxcat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate scale
xmin = min(x_coord);
xmax = max(x_coord);
dx = (xmax-xmin)/20;if (dx==0) dx=xmax/10;end;
xlims = [(xmin-dx) (xmax+dx)];
if (exist('ERROR_UP','var'))
    ymin = min(min(PLOT-ERROR_DOWN));
    ymax = max(max(PLOT+ERROR_UP));
else 
    ymin = min(min(PLOT));
    ymax = max(max(PLOT));
end;

dy = (ymax-ymin)/20;
if (dy==0) dy=abs(ymax)/10;end;
ylims = [(ymin-dy) (ymax+dy)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scale axis for vertical or horizontal boxes.
% deal with hold on option.
holding=get(gca,'NextPlot');
if (strcmp(holding,'add'))
    xlim_old=get(gca,'XLim');
    ylim_old=get(gca,'YLim');
    xlims=[min(xlims(1),xlim_old(1)) max(xlims(2),xlim_old(2))];
    ylims=[min(ylims(1),ylim_old(1)) max(ylims(2),ylim_old(2))];
else
    cla
    set(gca,'NextPlot','add');
end;
set(gca,'Box','off');
if ~flip
    if ~(ylims(2)==ylims(1))
        axis([xlims ylims]);
    end;
    set(gca,'XTick',x_coord);
    set(gca,'YLabel',text(0,0,'Values'));
    %if (isempty(g)), set(gca,'XLabel',text(0,0,'Column Number')); end
else
    axis([ylims xlims]);
    set(gca,'YTick',lb);
    set(gca,'XLabel',text(0,0,'Values'));
    %if (isempty(g)), set(gca,'YLabel',text(0,0,'Column Number')); end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the split color on relevant 
if (isempty(catcol))
    catnum=[1:numsplitcat]; % Every split category in a different color 
else 
    [~,~,catnum]=unique(R(:,catcol),'rows');
end; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Line properties for each segment

form=fieldnames(F);
forms = {};
for c=1:numsplitcat
    fm=F;
    for f=1:length(form)
        fiel=getfield(F,form{f}); 
        if (iscell(fiel)); 
		fm=setfield(fm,form{f},fiel{mod(catnum(c)-1,length(fiel))+1}); % set formating structure for this category
        end;
    end;
    forms{c} = fm;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform plotting
for c=1:numsplitcat
    fm=forms{c};
    for seg=1:length(l_from)
        x=x_coord(l_from(seg):l_to(seg));
        y=PLOT(c,l_from(seg):l_to(seg));
        h(c)=plot(x,y);
        set(h(c),'Color',fm.linecolor,'LineWidth',fm.linewidth,'LineStyle',fm.linestyle,'Marker',fm.markertype,'MarkerSize',fm.markersize,'MarkerEdgeColor',fm.markercolor,'MarkerFaceColor',fm.markerfill);
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do legend
if (~isempty(split))
    plotlegend(h,leg,R,split_conv,leglocation);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error bars
if (~isempty(errorfcn))
    for c = 1:numsplitcat
        fm=forms{c};
        for seg = 1:length(l_from)
            x=x_coord(l_from(seg):l_to(seg));
            y=PLOT(c,l_from(seg):l_to(seg));
            EU=ERROR_UP(c,l_from(seg):l_to(seg));
            ED=ERROR_DOWN(c,l_from(seg):l_to(seg));
            if (strcmp(fm.errorbars,'plusminus'))
                errorbars(x,y',[ED' EU'],'linecolor',fm.errorcolor,'linewidth',fm.errorwidth,'error_dir','both','cap',fm.errorcap);
            elseif (strcmp(fm.errorbars,'shade'))
                i=find(~isnan(y+EU)); 
                Y=[y(i)+EU(i) fliplr(y(i)-ED(i))];
                X=[x(i)' fliplr(x(i)')];
                h=patch(squeeze(X), squeeze(Y), fm.linecolor);
                set (h, 'FaceColor',fm.shadecolor,'EdgeColor','none','Facealpha',fm.transp);
            end;
        end
    end
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X-axis labels

%Turn off tick labels and axis label
if (numxvars>1 & XTickLabel==1)
    set(gca, 'XTickLabel','','UserData',numxvars);
    xlabel('');
    ylim = get(gca, 'YLim');

    % Place multi-line text approximately where tick labels belong
    for j=1:numxcat
        ht = text(x_coord(j),ylim(1),glabels{j,1},'HorizontalAlignment','center',...
            'VerticalAlignment','top', 'UserData','xtick');
    end

    % Resize function will position text more accurately
    set(gcf, 'ResizeFcn', sprintf('lineplot(%d)', gcf), ...
        'Interruptible','off', 'PaperPositionMode','auto');
    resizefcn(gcf);
    %set(gca, 'XTickLabel',glabels);


    % Store information for gname: this might be cool!
    % set(gca, 'UserData', {'boxplot' xvisible gorig vert});
elseif (numxvars>1 & XTickLabel==0)

	glabels=makexlabels(C(:,end));
    set(gca,'XTickLabel',glabels);
end;
set(gca,'NextPlot',holding);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X-axis categories

xcat_exist=0;
c=1;
while(c<=length(varargin))
	if (strcmp (varargin(c), 'xcat'))
		xcat_exist = 1;
	end
	c=c+1;
end

% plot text symbols + values
if (xcat_exist)
	% find categories
	for i=1:numxvars-1
		uniq{i} = sort(unique (xvar(:,i)));
	end

	% create matrix of combinations
	comb = [];
	for i=1:numxvars-1
		left_size = 1;
		right_size = 1;
		for j=1:i-1
			left_size = left_size*size(uniq{j},1);
		end
		for j=i+1:numxvars-1
			right_size = right_size*size(uniq{j},1);
		end
  		comb(:,i) = repliq (uniq{i},left_size,right_size);
	end
end

if (~isempty(xcat))
	labels_str = xcat;
  	nlabels = size(xcat,2);

	% generates strings ready to be plotted on the graph
	for i=1:size(comb,1);
		xstr{i} = '';
		for j=1:size(comb,2);
			xstr{i} = sprintf ('%s%s=%1.1f\n ',xstr{i},labels_str{j},comb(i,j));
		end
	end
end

% plot only values for a quick view
if (isempty(xcat) & xcat_exist)
	% generates strings ready to be plotted on the graph
	for i=1:size(comb,1);
		xstr{i} = '';
		for j=1:size(comb,2);
			xstr{i} = sprintf ('%s\n%1.2f',xstr{i},comb(i,j));
		end
	end
end

if (xcat_exist)
% deals with plotting text in function of Y scale
	posY = get(gca,'YLim');
	shift = (posY(2)-posY(1))/10;

	for i=1:size(comb,1)
		posX = x_coord(l_from(i));
		text(posX,posY(2)-shift,xstr{i});
	end

	if (~isempty(xcat))
		text(mean(x_coord),posY(1)-0.75*shift,labels_str(nlabels));
	end
end

figure(gcf);    % Bring figure to front on Mac platform

function vect = repliq (v,l,r)
	v_tmp = repmat (v,1,r)';
	v_tmp = v_tmp(:);
	vect = repmat (v_tmp,l,1);

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

