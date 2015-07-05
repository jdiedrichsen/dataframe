function drawline(x,varargin)
% Drawline(x,varargin)
% VARARGIN:
%   'dir','vert'        ('horz' gives horizontal lines)
%   'color',[0 0 0]     (default black)
%   'lim',[min max]     (default: existing axis limits)
%   'linestyle',spec    (default: solid, '-')
%   'linewidth',width   (default: 1)
% Joern Diedrichsen (j.diedrichsen@bangor.ac.uk)
% Olivier White
% v.1.1 2/24/2009: Support for linestyle and linewidth

color=[0 0 0];
lim=[];
dir='vert';
linestyle='-';
linewidth=1;

[r,c]=size(x);
if(r>c)
   x=x';
end;

vararginoptions(varargin,{'dir','color','lim','linestyle','linewidth'});

if (isempty(lim))
    if (strcmp(dir,'vert'))
        lim=get(gca,'YLim');
    else
        lim=get(gca,'XLim');
    end;
end;

x1=[x;x];
y=[ones(1,length(x));ones(1,length(x))];
y(1,:)=y(1,:).*lim(1);
y(2,:)=y(2,:).*lim(2);

if (strcmp(dir,'vert'))
    l=line(x1,y,'Color',color);
else
    l=line(y,x1,'Color',color);
end;

set(l,'linewidth',linewidth,'linestyle',linestyle);
