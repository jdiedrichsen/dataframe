function B=shift_matrix(A,r,c); 
% function B=shift_matrix(A,r,c); 
% Returns a matrix B, that has the same size as Matrix A 
% But in which A(r,c) is located at B(1,1)
% and the rest of the entries are shifted 
% The elements A(i,j) with i<r or j<c are wrapped around like on a torus 
[I,J]=size(A); 
B=zeros(I,J);
B(1:I-r+1,1:J-c+1)=A(r:I,c:J); 
B(I-r+2:I,1:J-c+1)=A(1:r-1,c:J); 
B(1:I-r+1,J-c+2:J)=A(r:I,1:c-1); 
B(I-r+2:I,J-c+2:J)=A(1:r-1,1:c-1); 

