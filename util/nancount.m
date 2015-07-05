function n=nancount(Y)
% function n=nancount(Y)
n=length(find(~isnan(Y)==1));
