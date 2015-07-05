function plotlegend(h,leg,R,split_conv,leglocation);
% function plotlegend(h,leg,R,split_conv);
% Helper function to generate legend with the option to have leg='auto'
% Joern Diedrichsen 
if (nargin<5) 
    leglocation='NorthEast';
end;
if (~isempty(leg))
    if (iscell(leg))
        legend(h,leg,'Location',leglocation);
    elseif (ischar(leg))
        if (strcmp(leg,'auto'))
            for r=1:size(R,1)
                for v=1:size(R,2)
                    if (~exist('split_conv') | isempty(split_conv) | split_conv.isnum(v)==1)
                        if v==1 
                            L{r}=[num2str(R(r,v))];
                        else 
                            L{r}=[L{r} '/' num2str(R(r,v))];
                        end;
                    else 
                        if v==1 
                            L{r}=[split_conv.names{v}{R(r,v)}]; 
                        else 
                            L{r}=[L{r} '/' split_conv.names{v}{R(r,v)}];
                        end;                        
                    end;
                end;
            end;
            legend(h,L,'Location',leglocation);
        elseif (strcmp(leg,'off'))
            legend(gca,'off');
        end;
    end;
    legend(gca,'boxoff');
end;  
