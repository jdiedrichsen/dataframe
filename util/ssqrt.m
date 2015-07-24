function A=ssqrt(A,c)
% function A=ssqrt(A,c)
% Signed square-root transform 
% Returns sqrt(A) for positive values 
% and     -sqrt(-A) for negative values 
% If the offset c is given, then the function returns 
% sqrt(A+c)-sqrt(c) for positive values 
% -sqrt(-A-c)+sqrt(c) for negative values 
if (nargin<2 | isempty(c))
    c=0; 
end; 
A(A>=0) = sqrt(A(A>=0)+c)-sqrt(c); 
A(A<0)  =-sqrt(-A(A<0)+c)+sqrt(c); 

