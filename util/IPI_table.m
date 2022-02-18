function [S] = IPI_table(D, varargin)
% function [S] = IPI_table(D, varargin);
%
% Creates table of inter-press intervals (IPIs) from either individual
% press times (N trials * 1) or from IPI field (N trials * N IPIs).
%
% This function that takes as input a dataframe Matlab structure (D) with N
% rows (one per trial) and returns a new dataframe structure with N * N
% IPIs rows. It can work either starting from fields 'pressTime[n]' (e.g.,
% d.pressTime1) or from a field 'IPI' with size (N trials * N IPIs).
%
% Optional input 'addRT' includes the possibility of counting the reaction
% time (RT) as IPI_0.
%
% Inputs
%   D           : dataframe structure including either fields
%               'pressTime[n]' or 'IPI'
%   (optional)
%   varargin    : 'addRT' string that, if set to True (1), adds RT to the
%               IPI count as IPI_0 (default is addRT = 0)
% Output
%   S           : a new dataframe structure with N * N IPIs rows and new
%               fields 'IPI' and 'IPInum'. If the 'addRT' option is added,
%               this will also create a new field 'isRT' to distinguish
%               between IPIs that are RT (1) or not (0). Comes in handy for
%               plotting purposes
%
% Usage example : D2 = IPI_table(D1, 'addRT', 1);
%
% -- Latest updates
% v1.0: gariani@uwo.ca - 2022.02.17: function created

%% import eventual optional input arguments
addRT = 0;
vararginoptions(varargin, {'addRT'});

%% check if the required fields are present
if isfield(D, 'IPI')
    % add IPI info
    D.IPI(D.IPI<=0) = NaN;
elseif isfield(D, 'pressTime1')
    % add IPI info
    p = 1;
    all_pressTimes = zeros(size(D.pressTime1,1),1);
    while isfield(D, sprintf('pressTime%d',p))
        all_pressTimes(:,p) = eval(sprintf('D.pressTime%d',p));
        p = p+1;
    end
    D.IPI = diff(all_pressTimes, 1, 2);
    D.IPI(D.IPI<=0) = NaN;
else
    error('Input dataframe structure must cointain either fields ''pressTime[n]'' or ''IPI''!');
end

%% include RT as one of the IPIs?
if addRT==1
    if isfield(D, 'RT')
        D.IPI = [D.RT, D.IPI];
    else
        error('To add RT as an IPI, input dataframe structure must cointain field ''RT''!');
    end
end

%% create and populate new IPI structure
I = rmfield(D, 'IPI');
S = struct();
for i = 1:size(D.IPI, 2)
    I.IPI = D.IPI(:,i);
    if addRT==1
        I.IPInum = ones(size(D.IPI,1),1) * i-1;
        if i-1==0
            I.isRT =  ones(size(D.IPI,1),1);
        else
            I.isRT =  zeros(size(D.IPI,1),1);
        end
    else
        I.IPInum = ones(size(D.IPI,1),1) * i;
    end
    S = addstruct(S, I, 'row');
end
end