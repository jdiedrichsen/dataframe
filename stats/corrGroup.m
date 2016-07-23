function [Corr_within,Corr_between,Indicator] = corrGroup(In1,In2,varargin)
%% function [Corr_within,Corr_between] = corrGroup(In1,In2,varargin)
% calculates within- and between-group correlation given data matrices of two different groups.
% 
% Inputs:
%     In1: data (Na by M matrix).
%     In2: data (Nb by M matrix). column size should be equal between In1 and In2.
%     
% corrGroup first calculates (Na+Nb) by (Na+Nb) pairwise correlation matrix, then split it into
%  within- and between-group parts.
%         
% Options:
%     type: correlation function ('Pearson', 'Spearman', 'Kendall', 'corrN'). Default is 'Pearson'
%           'corrN' calculates correlation withoug intercept (normalised cross product).
% Outputs:
%     Corr_within: vector of within-group correlation. each element is pairwise correlation excluding the same observations
%     Corr_between: vector of between-group correlation. each element is pairwise correlation excluding the same observations
%     Indicator: 1/2 indicator vector for [C_within;C_between]. 1 for within, 2 for between.
% 
% Example:
%   [Corr_within,Corr_between] = corrGroup(In1,In2,'type','Pearson');
% 
%   [Corr_within,Corr_between,Indicator] = corrGroup(In1,In2,'type','Pearson');
%   barplot(Indicator,[Corr_whithin;Corr_between]);
% 
% see also: corrN.m
% 
% ayokoi (2015/Dec)

%%

% Handle input option
type = 'Pearson';
if nargin>3
   switch (varargin{1})
       case 'type'
           type = varargin{2};
       otherwise
           warning('option not implemented.');
   end
end

% Get indices
[Na,N1] = size(In1);
[Nb,N2] = size(In2);
if N1~=N2
    error('input data must have the same number of features (data points).');
end

Idx = true(Na+Nb);
Idx(diag(diag(Idx)))=false;
Idx = triu(Idx);

Idx_within = Idx;
Idx_within(1:Na,(Na+1):end) = false;

Idx_between = false(Na+Nb);
Idx_between(1:Na,(Na+1):end) = true;

% Get overall pairwise correlation matrix using built-in corr function or corrN
switch (type)
    case 'corrN'
        C = corrN([In1;In2]');
    otherwise
        C = corr([In1;In2]','type',type);
end

% Split pairwise correlations
Corr_within = C(Idx_within);
Corr_between = C(Idx_between);

% Return indicator
if nargout>2
    Indicator = [ones(size(Corr_within));2*ones(size(Corr_between))];
end

end