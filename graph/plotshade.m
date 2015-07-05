function h=plotshade(x,PLOT,ERR,varargin)
% function h=plotshade(x,PLOT,ERR,option1,option2,....)
% plots the mean y-data with shaded area errorbars 
% x is a ROW vector of times
% PLOT is the mean of the data 
% ERR is the width of the error area 
%   'patchcolor',[r g b] : color of patch
%   'transp',alpha    :transp transparency of the patch, Default 0.3
%   'flip',(1/0)      : exchange x and y-axis? Default:0
%   'ERRD',err        : takes the first as error up, the second as error
%                       down
% returns a handle 
% Joern Diedrichsen 10/1/05 (jdiedric@jhu.edu)
linecolor='r';
patchcolor='r';
transp=0.3;
flip=0;
ERRD=ERR;
vararginoptions(varargin,{'patchcolor','transp','flip','ERRD'});
i=find(~isnan(PLOT+ERR)); 
Y=[PLOT(i)+ERR(i) fliplr(PLOT(i)-ERRD(i))];
X=[x(i) fliplr(x(i))];
if flip==0
    h=patch(squeeze(X), squeeze(Y),'k');
else 
    h=patch(squeeze(Y), squeeze(X),'k');
end;    
set (h, 'FaceColor',patchcolor);
set(h,'FaceAlpha',transp);
set (h, 'EdgeColor','none');
