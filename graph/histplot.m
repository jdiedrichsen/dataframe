function [N,catX]=histplot(y,varargin)
% histplot(y,varargin)
% Combines funtionality of a hist_pivot and hist_double
%  y:           Data to be plotted (one vector)
%  VARARGIN:
%   Splitting data
%       'split'                : Splits the data in differnet overlays
%       'splitrow'             : Makes X subplot in the rows
%       'splitcol'             : make X subplot in colums (all same scale)
%   Data processing options
%       'subset',logical      : Only prints subset
%       'numcat'                : number of bins 
%       'catX'                  : Category centers for bars 
%       'percent',[0/1]         : Percent or raw numbers (default 0) 
%   Format options for boxes
%       in general: 'formating_option', value,...
%       If a single value is give, the formatting option is applied to all
%       split-categories. If a cell array of values is given, the first value
%       is for the first split category etc.
%       'barwidth',size       : barwidth
%   Distribution overlay
%       'fit',{'Xcdf',[P1 P2 .... ]}: overlays distribution function to the
%                                     data 
%    Predetermined styles
%       'style_bar1'          : Overlapping histogram outlines 
% -------------------------------------------------------------------------
% Fixes
% v1.1: if all data is nan for one category, it leaves box open 01/25/06
% v1.2: if group is not given, it sets them all to one 03/18/06
% v1.3: flag 'xtickoff' leaves X-axis labels free 25/01/09
% v1.4: Legend implemented 
% v1.5: Basic distribution overlay implemented (fixed parameters)


% Determine Matlab version number - determine whether I need to use new
% graphics system 
versionNum = sscanf (version, '%d.%d.%d') ;
versionNum = 10.^(0:-1:-(length(versionNum)-1)) * versionNum ;

F.facecolor={[0.5 0.5 0.5],[1 1 1],[0 0 0],[1 1 0],[0 1 1],[1 0 1]};
F.facealpha=1;
F.linecolor=[0 0 0];
F.linewidth=1;
F.barwidth=1;


F.fillcolor=[0.8 0.8 0.8];
F.marker = 'none';
F.markerfacecolor=[0 0 0];
F.markeredgecolor=[0 0 0];
F.linestyle='-';
F.markersize=4;

fit={};
percent=0;
style='bar';
split=[];
splitSP={[],[]};
leg=[];
leglocation='NorthWest';
numcat=[];
force_yLim=1;

c=1;
while(c<=length(varargin))
    if (~ischar(varargin{c}))
        error('options need to be denoted by strings');
    end;
    switch(varargin{c})
        case 'splitrow'
            splitSP{1}=varargin{c+1};
            c=c+2;
        case 'splitcol'
            splitSP{2}=varargin{c+1};
            c=c+2;
        case {'style','gap','split','subset','leg','leglocation','split','numcat','percent','catX','fit'}
            eval([varargin{c} '=varargin{c+1};']);c=c+2;
        case {'facecolor','facealpha','linecolor','linewidth',...
                'fillcolor','markersize','markertype',...
                'markercolor','markerfill','barwidth'};
            eval(['F.',varargin{c} '=varargin{c+1};']);c=c+2;
        case 'style_bar1'
            style='bar';
            F.facecolor={[0 0 1],[1 0 0],[0 1 0],[1 1 0],[0 1 1],[1 0 1]};
            F.linecolor={[0 0 1],[1 0 0],[0 1 0],[1 1 0],[0 1 1],[1 0 1]};
            F.facealpha=0.3;
            F.edgecolor=[0 0 0];
            F.linestyle='outline';
            F.linewidth=3;
            
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
%Deal with selection (subset) variable
[split,split_conv]=fac2int(split);
for i=1:2
    [splitSP{i},splitSP_conv{i}]=fac2int(splitSP{i});
end;

if (exist('subset','var'))
    goodindx=find(subset);
else
    goodindx=[1:size(y,1)]';
end;
y=y(goodindx,:);
if (~isempty(split))
    split=split(goodindx,:);
else
    split=ones(size(y,1),1);
end;
for i=1:2
    if (~isempty(splitSP{i}))
        splitSP{i}=splitSP{i}(goodindx,:);
    else
        splitSP{i}=ones(size(y,1),1);
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deal with y-variables which have more than one column
[Ny p] = size(y);
if (Ny==1)
    error('data must come in a column vector');
end;
if (p>1)
    split=repmat(split,size(y,2),1);
    y=reshape(y,prod(size(y)),1);
    splitSP{1}=[];
    for i=1:p
        splitSP{1}=[splitSP{1};ones(Ny,1)*i];
    end;
    splitSP{2}=ones(size(y,1),1);
    numsplitvars=1;
end
Ny = size(y,1);

% register the variables that can be used for splitting
splitcat=unique(split,'rows');
numsplitcat=length(splitcat);
for i=1:2
    splitcatSP{i}=unique(splitSP{i},'rows');
    numsplitcatSP{i}=length(splitcatSP{i});
end;


% Make the bins standard over all subcategories:
if ~exist('catX') & isempty(numcat)
    [N,catX] = hist(y);
elseif ~exist('catX') & ~isempty(numcat)
    [N,catX] = hist(y,numcat);
end;
maxN=[];
% Now loop over all the subplots
for row=1:numsplitcatSP{1}
    for col=1:numsplitcatSP{2}
        if (numsplitcatSP{1}>1 || numsplitcatSP{2}>1)
            subplot(numsplitcatSP{1},numsplitcatSP{2},(row-1)*(numsplitcatSP{2})+col);
        end;
        i=findrow([splitSP{1} splitSP{2}],[splitcatSP{1}(row,:)  splitcatSP{2}(col,:)]);
        if (~isempty(i))
            Y=y(i,:);
            Split=split(i,:);
            D=pidata(Split,Y);
            
            
            % Scale axis for vertical or horizontal boxes.
            cla
            set(gca,'NextPlot','add','Box','off');
            
            form=fieldnames(F);
            
            % Now format the x-size depending on the grouping structure
            num_cat=size(D,1);
            for cat=1:num_cat
                [N(cat,:),X]=hist(D{cat,2},catX);
                if (percent==1)
                    N(cat,:)=N(cat,:)./sum(N(cat,:))*100;
                end;
                maxN(end+1)=max(N(cat,:));
                
                % Copy over style to
                fm=F;
                for f=1:length(form)
                    fiel=getfield(F,form{f});
                    if (iscell(fiel));
                        formcat=mod(cat-1,length(fiel))+1;
                        if (cat>length(fiel))
                            warning('Too many splits: reusing format');
                        end;
                        fm=setfield(fm,form{f},fiel{formcat}); % set formating structure for this category
                    end;
                end;
                
                
                switch (style)
                    case 'bar'
                        h(cat)=bar(X,N(cat,:),fm.barwidth);
%                         if versionNum<8.5 % Use the old graphics system  
%                             h(cat)=get(h(cat),'Children');
%                         end; 
                        % Draw the outline
                        if (strcmp(fm.linestyle,'outline'))
                            dx=min(diff(X));
                            XX=[];YY=[];n_last=0;
                            for j=1:size(N,2)
                                if (N(cat,j)>0)
                                    XX=[XX;X(j)-dx/2 X(j)-dx/2];
                                    YY=[YY;n_last N(cat,j)];
                                    XX=[XX;X(j)-dx/2 X(j)+dx/2];
                                    YY=[YY;N(cat,j) N(cat,j)];
                                end;
                                % Closing off
                                if ((j==size(N,2) || N(cat,j+1)==0) && N(cat,j)>0)
                                    XX=[XX;X(j)+dx/2 X(j)+dx/2];
                                    YY=[YY;N(cat,j) 0];
                                end;
                                n_last=N(cat,j);
                            end;
                            li=line(XX',YY','LineWidth',fm.linewidth,'Color',fm.linecolor);
                            fm.linestyle='none';
                        end;
                        %
                        if (versionNum<8.4) 
                            set(h(cat),'EdgeColor',fm.linecolor,'linestyle',fm.linestyle,'FaceColor',fm.facecolor,'LineWidth',fm.linewidth,'FaceAlpha',fm.facealpha);
                        else
                            set(h(cat),'EdgeColor',fm.linecolor,'linestyle',fm.linestyle,'FaceColor','none','LineWidth',fm.linewidth);
                        end; 
                    case 'line'
                        h(cat)=plot(X,N(cat,:));
                        set(h(cat),'Color',fm.linecolor,'LineStyle',fm.linestyle,'MarkerFaceColor',fm.markerfacecolor,'LineWidth',fm.linewidth,'Marker',fm.marker,'MarkerSize',fm.markersize);
                        % b(cat)=h(cat);
                end;
                if (~isempty(fit))
                    Xcdf=fit{1}; 
                    param={fit{2:end}};
                    % if Xpdf==@normpdf && isnan(param(1))... 
                    % Fit parameters 
                    
                    % Get the boundaries: 
                    dx=X(2)-X(1);  
                    b=[X(1)-dx/2 X+dx/2];
                    cdf=feval(Xcdf,b,param{:}); 
                    pdf=diff(cdf); 
                    predN(cat,:)=pdf*sum(N(cat,:));
                    if (percent==1)
                        predN(cat,:)=predN(cat,:)./sum(N(cat,:))*100;
                    end; 
                    h=plot(X,predN,'k'); 
                end;
            end;
            
            if (numsplitcatSP{1}+numsplitcatSP{2}>2)
                title(sprintf('%d ',[splitcatSP{1}(row,:)  splitcatSP{2}(col,:)]));
            end;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Do legend 
            if (~isempty(split))
                plotlegend(h(1:numsplitcat),leg,splitcat,split_conv,leglocation);
            else 
                legend(gca,'off');
            end;
            set(gca,'NextPlot','replace');
        end;
    end;
end;

% Now make the the Y_limiter equal for all
YLim=[0 max(maxN)+0.05*max(maxN)];
for row=1:numsplitcatSP{1}
    for col=1:numsplitcatSP{2}
        if (numsplitcatSP{1}>1 || numsplitcatSP{2}>1)
            subplot(numsplitcatSP{1},numsplitcatSP{2},(row-1)*(numsplitcatSP{2})+col);
        end;
        set(gca,'YLim',YLim);
    end;
end;