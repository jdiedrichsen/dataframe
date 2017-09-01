function A=joinframes(A,B,varargin)
% function A=joinframes(A,B,varargin)
% Joins two data frames in two modes: 
% If A and B have the same number of rows, it just adds the fields of B 
% to the fields of A. If these fields already exist in A, it uses the
% fields in A 
% If B has a single line, it simply multiplies this line N-times to fill A 
% -------------------------------------------------------
Anames=fieldnames(A);
Bnames=fieldnames(B); 
Na = size(A.(Anames{1}),1); 
Nb = size(B.(Bnames{1}),1); 

% Same size 
if (Na==Nb) 
    for i=1:length(Bnames)
        a=strcmp(Anames,Bnames{i}); 
        if (~any(a)) 
            A.(Bnames{i})=B.(Bnames{i}); 
        end; 
    end; 
elseif (Nb==1) % Nb =1: multiplex B 
    for i=1:length(Bnames)
        a=strcmp(Anames,Bnames{i}); 
        if (~any(a)) 
            A.(Bnames{i})=repmat(B.(Bnames{i}),Na,1); 
        end; 
    end; 
else 
    error('struct sizes need to be either the same, or the second one needs to be of size 1'); 
end; 