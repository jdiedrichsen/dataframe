function plot_ellipse(V,center,varargin);
% function plot_ellipse(V,center) 
% V = variance-covariance matrix 
% mean = location 
% VARARGIN
%   'p',0.95: Probability contour for ellipse 
%   'linewidth',1
%   'linestyle','-'
%   'facecolor',('none')
%   'edgecolor','k'
linewidth=1;
edgecolor='k'; 
linestyle='-'; 
facecolor='none';
p=0.95;
vararginoptions(varargin,{'p','linewidth','facecolor','edgecolor'});

[v,d]=eig(V);
v1=v(:,1);v2=v(:,2);
z=norminv(1-((1-p)/2));
sd1=sqrt(d(1,1))*z;sd2=sqrt(d(2,2))*z;
theta=0:(2*pi)/40:2*pi;
C=v1*cos(theta)*sd1+v2*sin(theta)*sd2;
C(1,:)=C(1,:)+center(1);
C(2,:)=C(2,:)+center(2);
pa=patch(C(1,:),C(2,:),'k');
set(pa,'FaceColor','none');
set(pa,'LineWidth',1);
set(pa,'EdgeColor',edgecolor);
set(pa,'LineStyle',linestyle);