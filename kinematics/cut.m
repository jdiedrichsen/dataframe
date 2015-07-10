function y=cut(X,pre,at,post,varargin);
% function y=cut(X,pre,at,post,varargin);
%   at: at which frame will be cut
%   pre: how many frames before
%   post: How many frames after
%  varargin:
%   'padding': padding when time that is not available
%         'nan': pad with nans
%         'zero': pad with zero
%         'last': pad with first or last entry (DEFAULT)
% OUTPUT
%   y cut kinematic trajectory
%   if at is NaN or empty, a vector with NaN;s returned
% Joern Diedrichsen
% jdiedric@jhu.edu
padding='last';
c=1;
while c<=length(varargin)
    switch (varargin{c})
        case 'padding'
            padding=varargin{c+1};
            c=c+2;
        otherwise
            error('cut:unknown option');
    end;
end;

[rows,cols]=size(X);
if (isempty(at))
    at=NaN;
end;
if (isnan(at))
    y=ones(pre+post+1,cols)*NaN;
else
    y0=X(max(1,at-pre):min(at+post,rows),:);
    if (isempty(y0))
        y=nan(pre+post+1,cols);
    else
        switch (padding)
            case 'nan'
                y=[nan(1-at+pre,cols);y0;nan(at+post-length(X),cols)];
            case 'last'
                y=[ones(1-at+pre,cols).*repmat(y0(1,:),1-at+pre,1);y0;ones(at+post-rows,cols).*repmat(y0(end,:),at+post-rows,1)];
            case 'zero'
                y=[zeros(1-at+pre,cols);y0;zeros(at+post-length(X),cols)];
            otherwise
                error('padding:unknown option - use: nan, last, zero');
        end;
    end;
end;
