function [ang,rad]=polcoord(x,y,zerox,zeroy)
% Calculates the ploar coordinates of a point, relative to zero
if nargin<4
   zeroy=0;
end;
if nargin<3
   zerox=0;
end;
ang=(angle(complex(x-zerox,y-zeroy)))/(2*pi)*360;
rad=sqrt((x-zerox).^2+(y-zeroy).^2);



