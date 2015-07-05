function drawpatch(x,p,color,range)
% drawpatch(x,p,color,range)
%   x:vector of the x-axis
%   p:indexes at which one want to draw the area
%   color: color of area
%   range is a ymin-ymax vector (set to [0 0.1] by default
if (nargin<4)
   range=get(gca,'YLim');
end;
p(p>length(x))=[];
[r,c]=size(x);
if(r>c)
   x=x';
end;
w=x(2)-x(1);
if length(p)>0
st=p(1);
for (i=1:length(p)-1)
   if p(i+1)-p(i)>1
      dopatch([x(st:p(i))],color,range,w); 
      st=p(i+1);
   end;
end;
dopatch([x(st:p(end))],color,range,w); 
hold off;
end;

function dopatch(x,color,range,w)
if length(x)>0
X=[x(1)-w/2;x(end)+w/2;x(end)+w/2;x(1)-w/2];
Y=[range(1);range(1);range(2);range(2)];
h=fill(X,Y,color);
set(h,'EdgeColor','none');
hold on;
end;
