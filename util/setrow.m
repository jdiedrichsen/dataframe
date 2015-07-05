function D=setrow(D,numrow,ROW)
% function D=setrow(D,numrow,ROW)
% sets a row at the position numrow in the data-structure D to ROW 
% Joern Diedrichsen 
% Version 1.0 9/18/03
field=fieldnames(ROW);
for f=1:length(field)
    if (isfield(D,field{f}))
        F=getfield(D,field{f});
    else 
        F=[];
    end;
    G=getfield(ROW,field{f});
    if (length(numrow)~=size(G,1))
        error('Number of rows in numrow needs to match the number of rows in ROW structure for every field'); 
    end; 
    F(numrow,:)=G;
    D=setfield(D,field{f},F);
end;
