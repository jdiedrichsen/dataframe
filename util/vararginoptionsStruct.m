function D=vararginoptionsStruct(options,allowed_vars,D);
% function D=vararginoptionsStruct(options,allowed_vars,D);
% Deals with cell array of options strings (usually coming from varargin)
% to the correspondingly named fields of a structure
% INPUTS:
%   options: cell array of a argument list passed to a function
%   allowed_vars: Variables that can be set
%   vararginoptions assigns the value of the option to a field in the structure
%   with the same name.
% EXAMPLE:
%   the option-string 'var1',4,'var2',10
%   causes the field D.var1 and D. var2 to be set to 4 and 10.
% Joern Diedrichsen
% v1.0 26/06/2012

c=1;
while c<=length(options)
    a=[];
    if ~ischar(options{c})
        error(sprintf('Options must be strings on argument %d',c));
    end;
    a=strmatch(options{c},allowed_vars);
    if (isempty(a))
        error(['unknown option:' options{c}]);
    end;
    if (c==length(options))
        error(sprintf('Option %s must be followed by a argument',options{c}));
    end;
    D.(options{c})=options{c+1};
    c=c+2;
end;