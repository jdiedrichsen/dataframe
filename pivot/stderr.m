function err=stderr(x)
% Returns standard error of the mean of x 
err=nanstd(x,[],1)./sqrt(sum(~isnan(x),1));