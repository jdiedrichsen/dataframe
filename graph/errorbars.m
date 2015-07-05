function e=errorbars(x,y,E,varargin)
% ERRORBARS: adds errobars (+/-) to a plot
% Synopsis
%   errorbars(x,y,E,varargin)
% Description
%   x,y vectors of x,y location
%   E is vector of the amount of error
%       if it has 2 columns, the first is downward, the second upward error
%  varagin:
%    'linestyle','-'    : default: '-'
%    'linewidth',width  : default: 1
%    'linecolor',[r g b]: default: [0 0 0]
%    'cap',capwidth     : default: (max(x)-min(x))/100
%    'error_dir',{'both','away'}: away is away from zero (for barplots)
%    'orientation',{'vert','horz'}: horizontal or vertical error bars,
%                         default: 'vert'
% Joern Diedrichsen 10/1/05
% v.2.0 13/7/07
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deal with the varargin's
c=1;
linestyle='-';
error_dir='away';
linecolor=[0 0 0];
cap=[];
orientation='vert';
linewidth=1;
vararginoptions(varargin,{'linestyle','error_dir','linecolor','cap','linewidth','orientation'});

% deal with inputvars
if size(x,1)~=size(y,1) | size(x,1)~=size(E,1)
    error('x,y, and E have to have the same number of rows');
end;
if (size(E,2)==1)
    E=[E E];
end;

% Make line matrices for all bars
X=[];Y=[];
for p=1:length(x)
    switch orientation
        case 'vert'
            if (isempty(cap))
                cap=(max(x)-min(x))/100;
            end;
            switch(error_dir)
                case 'both'
                    if (cap==0)
                        X=[X [x(p);x(p)]];
                        Y=[Y [y(p)-E(p,1);y(p)+E(p,2)]];
                    else
                        X=[X [x(p);x(p)] [x(p)-cap;x(p)+cap] [x(p)-cap;x(p)+cap]];
                        Y=[Y [y(p)-E(p,1);y(p)+E(p,2)] [y(p)-E(p,1);y(p)-E(p,1)] [y(p)+E(p,2);y(p)+E(p,2)]];
                    end;
                case 'away'
                    if (y(p)>0)
                        err=E(p,2);
                    else
                        err=-E(p,1);
                    end;
                    if (cap==0)
                        X=[X [x(p);x(p)]];
                        Y=[Y [y(p);y(p)+err]];
                    else
                        X=[X [x(p);x(p)] [x(p)-cap;x(p)+cap]];
                        Y=[Y [y(p);y(p)+err] [y(p)+err;y(p)+err]];
                    end;
            end;
        case 'horz'
            if (isempty(cap))
                cap=(max(y)-min(y))/100;
            end;
            switch(error_dir)
                case 'both'
                    if (cap==0)
                        Y=[Y [y(p);y(p)]];
                        X=[X [x(p)-E(p,1);x(p)+E(p,2)]];
                    else
                        Y=[Y [y(p);y(p)] [y(p)-cap;y(p)+cap] [y(p)-cap;y(p)+cap]];
                        X=[X [x(p)-E(p,1);x(p)+E(p,2)] [x(p)-E(p,1);x(p)-E(p,1)] [x(p)+E(p,2);x(p)+E(p,2)]];
                    end;
                case 'away'
                    if (x(p)>0)
                        err=E(p,2);
                    else
                        err=-E(p,1);
                    end;
                    if (cap==0)
                        Y=[Y [y(p);y(p)]];
                        X=[X [x(p);x(p)+err]];
                    else
                        Y=[Y [y(p);y(p)] [y(p)-cap;y(p)+cap]];
                        X=[X [x(p);x(p)+err] [x(p)+err;x(p)+err]];
                    end;
            end;
    end;
end;

% And plot
line(X,Y,'Color',linecolor,'LineWidth',linewidth,'LineStyle',linestyle);  % 'EraseMode','background',

