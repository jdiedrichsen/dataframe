function [varargout] = normData(D, dataFields, varargin)
% function [varargout] = normData(D, dataFields, varargin);
%
% Function that takes as input any dataframe structure (D) and normalizes its
% data either by subtracting the subject mean and adding the grand mean
% ('sub' option), or by dividing by the subject mean and multiplying by the
% grand mean ('div' option). Default is 'sub'. D must have (at least) a
% subject number field 'SN' (or 'sn') and a field/fields specified by the
% input 'dataFields' (e.g. {'MT'} for movement times).
%
% This function is useful in order to plot data with within-subject standard error
% of the mean as errorbars.
%
% Inputs
%   D           : dataframe structure with fields 'SN' and 'dataFields' (minimum requirements)
%   dataFields  : cell array that contains strings identifying the data fields to be normalized (e.g. {'MT'}, {'MT','RT'}, etc.)
%   varargin    : (optional) string that specifies the data normalization option. Can be either 'sub' (default), or 'div'
%
% Output
%   D           : the same dataframe structure as input with the addition of the 'norm[dataFields]' fields
%                 (e.g. 'normMT', 'normRT', etc.) that contain the newly normalized data
%
% Usage example : D = normData(D, {'MT'}, 'div');
%
% -- Latest updates
% v1.0: gariani@uwo.ca - 2018.03.15: function created
% v1.1: gariani@uwo.ca - 2018.03.22: now supports subject number field as
%       either 'SN' or 'sn', and loops throught the normalization of
%       multiple data fields within the same call to normData

%% make sure the input structure meets the requirements
if isfield(D,'SN')
    %find how many subjects in this data structure
    subvec = unique(D.SN);
    ns = numel(subvec);
    SN = D.SN;
elseif isfield(D,'sn')
    %find how many subjects in this data structure
    subvec = unique(D.sn);
    ns = numel(subvec);
    SN = D.sn;
else
    error('Input dataframe structure must cointain SN (or sn) subject number field!');
end

%% loop through all input data fields
for idf = 1:numel(dataFields)
    
    if isfield(D,dataFields{idf})
        data = eval(sprintf('D.%s', dataFields{idf}));
        normData = zeros(size(data));
    else
        error('Incorrect data field name! Make sure dataFields is a field of D');
    end
    
    % choose normalization option
    if nargin == 3
        % use the specified normalization option
        normOption = varargin{1};
    elseif nargin == 2
        % use default option (subtraction)
        normOption = 'sub';
    else
        error('Not enough (or too many) input arguments!');
    end
    
    % apply the chosen norm option
    switch normOption
        
        case 'sub' % subtraction option
            for is = 1:ns
                normData(SN==subvec(is),1) = (data(SN==subvec(is)) - nanmean(data(SN==subvec(is)))) + nanmean(data);
            end
            
        case 'div' % division option
            for is = 1:ns
                normData(SN==subvec(is),1) = (data(SN==subvec(is)) / nanmean(data(SN==subvec(is)))) * nanmean(data);
            end
            
        otherwise
            error('Unknown normalization option! Try with "sub" or "div"');
    end
    
    % store normalized data in a new field of the same structure
    eval(sprintf('D.norm%s = normData;', dataFields{idf}));
    
end

%% return data structure with normalized fields
varargout={D};

end