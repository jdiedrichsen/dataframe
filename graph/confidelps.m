function [Centroid]=confidelps(x,y,p,c,ls)
% draws Confidence-ellipse over the x,y sample
% [Centroid]=confidelps(x,y,p)
% x is the col-vector of x data, y is the col-vector of y data
% p is the probablility of the confidience ellipse, assuming multivarinormal dist'n
% c is color
% ls is line strength
% centroid is the x and y coordinate of the centroid
if(nargin<5)
   ls='-';
end;
if(nargin<4)
   c=[0 0 0];
end;
covm=cov([x y]);
Centroid=mean([x y]);
[v,d]=eig(covm);
v1=v(:,1);v2=v(:,2);
z=norminv(1-((1-p)/2));
sd1=sqrt(d(1,1))*z;sd2=sqrt(d(2,2))*z;
theta=0:(2*pi)/40:2*pi;
C=v1*cos(theta)*sd1+v2*sin(theta)*sd2;
C(1,:)=C(1,:)+Centroid(1);
C(2,:)=C(2,:)+Centroid(2);
pa=patch(C(1,:),C(2,:),'k');
set(pa,'FaceColor','none');
set(pa,'LineWidth',1);
set(pa,'EdgeColor',c);
set(pa,'LineStyle',ls);
X(1,1)=C(1,1);
X(2,1)=C(1,21);
X(1,2)=C(1,11);
X(2,2)=C(1,31);
Y(1,1)=C(2,1);
Y(2,1)=C(2,21);
Y(1,2)=C(2,11);
Y(2,2)=C(2,31);
l=line(X,Y,'LineWidth',1,'Color',c,'LineStyle',ls);

