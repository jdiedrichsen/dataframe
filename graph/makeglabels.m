function glabels=makeglabels(D,numlvar,catlabels)
% function glables=makeglabels(D,numlvar,catlabels)
% makes group labels from a column-signifier (fgrom pivottable) 
% For line-plot and bar-plot 
% numbers into strings 
[numcat,dummy]=size(D);
[dummy,numgvar]=size(D{1,1});
if nargin<2
    numlvar=numgvar;
end;

for c=1:numcat
    glabels{c,1}='';
    for gv=numlvar:-1:1
        if (c==1 | D{c,1}(gv)~=D{c-1,1}(gv))
            s=sprintf('%d\n',D{c,1}(gv));
        else
            s=sprintf('\n');
        end;
        glabels{c,1}=[glabels{c,1} s];  
    end;
    % get rid of the last one 
    glabels{c,1}=glabels{c,1}(1:end-1);
end;
