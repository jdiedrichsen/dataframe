function varargout = setMatrixValues ( M, funcStr, varargin )
% Function sets the specified values in the matrix to the given 
% Example:
% -------
%       SetMatrixValues(M,'trace');     % sets the trace of the matrix to nan
%       SetMatrixValues(M,'trace',0);   % sets the trace of the matrix to 0

% if no value is specified, then use nan

switch(funcStr)
    
    case 'trace'
        if nargin < 3
            value = nan;
        else 
            value = varargin{1};
        end;

        m = M;
        I = eye(size(m));
        m(I==1) = value;
        varargout = {m};
        
        
    case 'remove_nan'      % remove any row/column which has a nan value in any column
        vararginoptions(varargin,{'dim'});      % remove along rows or columns
        
        if strcmp(dim,'row')            
            s = sum(isnan(M),2);
        else
            s = sum(isnan(M),1);
        end;
        
        indx_to_keep = find(s==0);       % indexes that have no nans along the specified dimension
        m = SetMatrixValues(M,'keep','dim',dim,'ind',indx_to_keep);
        varargout = {m,indx_to_keep};

        
    case 'keep'           % remove any row/col which doesnt have the specified indexes
        vararginoptions(varargin,{'dim','ind'});      
        
        if strcmp(dim,'row')            
            m = M(ind,:);
        else
            m = M(:,ind);
        end;
        varargout = {m};
end;