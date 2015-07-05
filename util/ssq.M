function SS=ssq(X)
% Sum of squares of X
% function SS=ssq(X)
% X has to be a vector
% ignores NAN
X=X-nanmean(X);
SS=nansum(X.^2);
