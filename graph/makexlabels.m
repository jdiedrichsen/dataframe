function glabels=makexlabels(C,catconv)
% function glabels=makexlabels(C,catlabels)
% makes group labels from a column-signifier (from pivottable) 
% For line-plot and bar-plot 
% numbers into strings 
[numcat,numxvar]=size(C);
for c=1:numcat
    glabels{c}='';
    for gv=1:numxvar
        if (nargin<2 | catconv.isnum(gv))
            if (mod(C(c,gv),1)==0)
                s=sprintf('%d',C(c,gv));
            elseif (mod(C(c,gv),0.1)==0)
                s=sprintf('%2.1f',C(c,gv));
            elseif (mod(C(c,gv),0.01)==0)
                s=sprintf('%2.2f',C(c,gv));
            elseif (mod(C(c,gv),0.001)==0)
                s=sprintf('%2.3f',C(c,gv));
            else 
                s=sprintf('%f',C(c,gv));
            end;    
        else
            s=catconv.names{1}{C(c,gv)};
        end;
        if gv==numxvar 
            glabels{c}=[glabels{c} s];  
        else
            glabels{c}=[glabels{c} s '/'];  
        end;            
    end;
end;
