function ROT=rotationMatrix(angle)
% returns a affine transformation matrix, which 
% rotates a 2-dimensional coordinates by angle degrees 
% Positve is in clockwise direction
a=angle/180*pi;
ROT=[cos(a) sin(a);-sin(a) cos(a)];
