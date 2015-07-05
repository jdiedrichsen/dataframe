function histdistn_plot(X,distn,varargin)
% makes a nice histogram with 
% overlayed distribution
i=1;
num_cat=round(max(X))+1;
color=[0.7 0.7 0.7];
ax=[0 30 0 200];
while (i<=length(varargin))
    switch varargin{i}
    case 'num_cat'
        numcat=varargin{i+1};
        i=i+2;
    case 'param'
        param=varargin{i+1};
        i=i+2;
    case 'color'
        color=varargin{i+1};
        i=i+2;
    case 'axis'
        ax=varargin{i+1};
        i=i+2;
    otherwise
        fprintf('Unknown Option: %s\n',varargin{i});
        return;
    end;
end;


[n,m]=hist(X,num_cat);
N=sum(n);
hist(X,num_cat);
h=get(gca,'Children');
set(h,'FaceColor',color);
set(h,'EdgeColor',color);
hold on;
x=eval([distn '(m,' int2str(param{1}) ')']);
plot(m,x*N,'k');
axis(ax);
hold off;
ylabel('Count');
