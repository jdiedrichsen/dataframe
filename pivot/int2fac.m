function R=int2fac(INT,Convert)
% function [INT,Convert]=fac2int(R)
% fac2int deals with string entries in data matrices 
% for plots and pivottables
% R=either Matrix,Cell array of string elements, or Cell array of mixed elements
% INT: Integer representation of factor 
% Convert.isnum = [vector of falgs if the column was numeric]
% Convert.names{} = if string, it stores the names for the codes.
if all(Convert.isnum)
    R=INT;
else 
    [rows,cols]=size(INT);
    for i=1:cols
        if Convert.isnum(i)
            R{i}=INT(:,i);
        else 
            R{i}={Convert.names{i}{INT(:,i)}}';
        end;
    end;
    if cols==1
        R=R{1};
    end;
end;
