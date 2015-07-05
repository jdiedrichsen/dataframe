function scattermatrix(V,varargin);
% function scattermatrix(V,varargin);
% makes a matrix of scatterplots, one plot against another
% varagin: 
% 'CAT'
% 'split'
% 'varnames'
% 'hist'
% 'subset'

% Set defaults for all plots 
F.markertype = 'o';
F.markercolor=[0 0 0];
F.markerfill=[0 0 0];
F.markersize=4;
CAT=[];g=[];
% Deal with the varargin's 
c=1;
histogr=0;
varnames={'1','2','3','4','5','6','7','8','9'};
while(c<=length(varargin))
    switch(varargin{c})
        case 'CAT'
            CAT=varargin{c+1};c=c+2;
        case 'group'
            g=varargin{c+1};c=c+2;
        case 'varnames'
            varnames=varargin{c+1};c=c+2;
        case 'hist'
            histogr=1;c=c+1;
        case 'subset'
            flag=varargin{c+1};c=c+2;
            s=find(flag);
            V=V(s,:);
        otherwise
            error('Unknown option\n');
    end;
end;

% Deal with grouping variable
%if (~isempty(g)); 
%D=pidata(g,x); 
%numlvars=size(D{1,1},2);
%glabels=makeglabels(D,numlvars);

% Now format the x-size depending on the grouping structure
[n,numvars]=size(V);
if (histogr)
    rows=numvars;
    cols=numvars; 
else 
    rows=numvars-1;
    cols=numvars; 
end;
r=get(gcf,'Paperposition');
for v=1:numvars 
    if (histogr)
        subplot(rows,cols,v);
        hist(V(:,v));
        title(varnames{v});
        if (v~=1)
            set(gca,'YTickLabel',{});
            set(gca,'XTickLabel',{});
        end;
    end;
    for yv=1:v-1
        subplot(rows,cols,(yv-1+histogr)*cols+v);
        set(plot(V(:,v),V(:,yv),'k.'),...
            'Marker',F.markertype,...
            'MarkerEdgeColor',F.markercolor,...
            'MarkerFaceColor',F.markerfill,...
            'MarkerSize',F.markersize);
        if (yv==v-1)
            ylabel(varnames{yv});
        else 
           set(gca,'YTickLabel',{});
        end;
        if (yv==1 & histogr==0)
            title(varnames{v});
        end;        
        if (yv==v-1)
        else
            set(gca,'XTickLabel',{});
        end;            
    end;
end;