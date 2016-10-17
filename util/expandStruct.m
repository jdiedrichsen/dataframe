function T=expandStruct(D,matrixfields,columnfield)
% function D=expandStruct(D,matrixfields,columnfield)
% Expands a structure, so that a one of multiple fields with multiple 
% columns become a vector, 
% INPUT: 
%       D: structure 
%       matrix field: cell array of names (or signle name) of the field to  
%                     expand 
%       columnfield: vector which will contain the column number 
% OUTPUT: 
%       T : new, expanded struture 
% For example: 
% D.var: N x P matrix 
% T=expandStruct(D,'var','col); 
% Makes T.var an N*P structure 
% and T.col a variable that indicates the column 
% -------------------------------------------------------

if (ischar(matrixfields)) 
    matrixfields={matrixfields}; 
end; 

names=fieldnames(D);

for i=1:length(matrixfields)
    [N,P(i)]=size(D.(matrixfields{i})); 
    A=D.(matrixfields{i})'; 
    T.(matrixfields{i})=A(:); 
end; 
if std(P)>0 
    error('all matrixfields to expand must have the same number of columns'); 
end; 
T.(columnfield) = kron(ones(N,1),[1:P]'); 

for i=1:length(names)
    if isempty(find(strcmp(names{i},matrixfields))) && (~iscell(D.(names{i}))) && (size(D.(names{i}),2)==1)
        T.(names{i})=kron(D.(names{i}),ones(P(1),1)); 
    end; 
end; 
