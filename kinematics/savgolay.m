function [c] = savgolay( order, halfwidth, reverse )

%  SAVGOLAY:	Implements Savitsky-Golay smoothing.  This smoothing technique fits a polynomial
%		to a moving window of data using linear least-squares fitting.  Derivatives, as
%		well as the function value, can be determined at the center point.  Since the
%		coefficients of the fitted polynomial are linear in the data values, we can
%		precompute the filters.
%
%  Inputs:	- order of the filter (the highest polynomial power used in the fit) 
%		- half-width of the filter (note: if halfwidth is given in the form [ NL, NR ], 
%		  where NL and NR are the number of points to the right and left of the zero
%		  point, a non-symmetric filter will be generated;  otherwise, symmetry is 
%		  assumed and the total width of the filter will be 2*halfwidth+1.
%		- OPTIONAL: if a third parameter is given (e.g., 'true' or 'yes' or 'reverse'),
%		  then the filters will be reversed on output.  This is to allow them to be
%		  used directly with the MATLAB 'filter' command which expects the filter to
%		  be arranged from the future to the past.
%
%  Outputs:	- the coefficients of the filter.  Each row represents the coefficients
%		  used to calculate the corresponding derivative at the zero point.  I.e.,
%		  this matrix has dimensions order+1 x N, where N is the total width of the
%		  filter.  To compute the smoothed estimate of the value at the zero point,
%		  take the dot product of the first row of c with the data around the zero
%		  point.  Similarily, for the first derivative, use the second row of c, etc.
%
%  ***********	When using the Savitsky-Golay filter to compute derivatives, remember to
%  ** NOTE: **	divide by the sampling interval raised to the power of the desired
%  ***********	derivative.

if length( halfwidth ) == 2
	NL = halfwidth(1);
	NR = halfwidth(2);
else
	NL = halfwidth;
	NR = halfwidth;
end

%  Set up the basic matrices:
N = NL + NR + 1;
F = eye( N );
A = zeros( N, order+1 );
for i = 1:N,
	for j = 1:order+1,
		A(i,j) = (i-NL-1)^(j-1);
	end
end

%  Now do a simple computation of the filters:
a = (A'*A)\(A'*F);

%  each row of c must be multiplied by its row number factorial
c = a;
for i = 2:order
	for j = i:order
		c(j+1,:) = i * c(j+1,:);
	end
end

if nargin == 3   % if third argument is specified, reverse order for filtering
	[rows,cols] = size(c);
	c = c(:,cols:-1:1);
end