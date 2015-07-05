function A=ssqrt(A)
% function A=ssqrt(A)
% Signed square-root transform 
% Returns sqrt(A) for positive values 
% and     -sqrt(-A) for negative values 
A(A>=0)=sqrt(A(A>=0)); 
A(A<0)=-sqrt(-A(A<0)); 

