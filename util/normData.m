function [varargout] = normData(D, dataField, varargin)
% function [varargout] = normData(D, dataField, varargin);
%
% Function that takes as input any dataframe structure (D) and normalizes its
% data either by subtracting the subject mean and adding the grand mean
% ('sub' option), or by dividing by the subject mean and multiplying by the
% grand mean ('div' option). Default is 'sub'. D must have (at least) a field
% 'SN' and a field specified by the input 'dataField' (e.g. 'MT' for movement times).
%
% This function is useful in order to plot data with within-subject standard error 
% of the mean as errorbars.
%
% Inputs
%   D           : dataframe structure with fields 'SN' and 'dataField' (minimum requirements)
%   dataField   : string that identifies the data field to be normalized (e.g. 'MT', 'RT', etc.)
%   varargin    : (optional) string that specifies the data normalization option. Can be either 'sub' (default), or 'div'
%
% Output
%   D           : the same dataframe structure as input with the addition of the 'norm[dataField]' field 
%                 (e.g. 'normMT', 'normRT', etc.) that contains the newly normalized data
% 
% Usage example : D = normData(D, 'MT', 'div');
%
% --
% gariani@uwo.ca - 2018.03.15

%% make sure the input structure meets the requirements
if isfield(D,'SN')
    %find how many subjects in this data structure
    subvec = unique(D.SN);
    ns = numel(subvec);
    SN = D.SN;
else
    error('Input dataframe structure must cointain SN field (subject number)!');
end

% select the correct data field
if isfield(D,dataField)
    data = eval(sprintf('D.%s', dataField));
    normData = zeros(size(data));
else
    error('Incorrect data field name! Make sure dataField is a field of D');
end

%% choose normalization option
if nargin == 3
    % use the specified normalization option
    normOption = varargin{1};
elseif nargin == 2
    % use default option (subtraction)
    normOption = 'sub';
else
    error('Not enough (or too many) input arguments!');
end

%% apply the chosen norm option
switch normOption
    
    case 'sub' % subtraction option
        for i = 1:ns
            normData(SN==subvec(i),1) = (data(SN==subvec(i)) - nanmean(data(SN==subvec(i)))) + nanmean(data);
        end
        
    case 'div' % division option
        for i = 1:ns
            normData(SN==subvec(i),1) = (data(SN==subvec(i)) / nanmean(data(SN==subvec(i)))) * nanmean(data);
        end
        
    otherwise
        error('Unknown normalization option! Try with "sub" or "div"');
end

%% return data structure with normalized data
eval(sprintf('D.norm%s = normData;', dataField));
varargout={D};

end