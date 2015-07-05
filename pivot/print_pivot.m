function print_pivot(RA,CA,FA,numformat)
% function print_pivot(RA,CA,FA)
% provides formated output of a pivot table 
if nargin<4 
    numformat='%6.2f';
end;
if (iscell(RA) & size(RA,2)==1)
    RA={RA};
end;
if (iscell(CA) & size(CA,2)==1)
    CA={CA};
end;
rowvars=size(RA,2);
colvars=size(CA,2);
[r,c]=size(FA);
for (i=1:colvars)
    for (x=1:rowvars)
        fprintf('        \t');
    end;
    fprintf('|');
    if (iscell(CA))
        var=CA{i};
    else
        var=CA(:,i);
    end;
    if iscell(var)
        for j=1:c
            fprintf(['%6s\t'],var{j});
        end;
    else 
        fprintf([numformat '\t'],var);
    end;
    fprintf('\n');
end;
for (x=1:rowvars)
    fprintf('--------\t');
end;
fprintf('|');
for (x=1:c)
    fprintf('------\t');
end; 
fprintf('\n');
for (i=1:r)
    for j=1:rowvars
        if iscell(RA)
            fprintf(['%8s\t'],RA{j}{i,1});
        else
            fprintf([numformat '\t'],RA(i,j));
        end;
    end;
    fprintf('|');
    fprintf([numformat '\t'],FA(i,:));
    fprintf('\n');
end;