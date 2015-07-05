function [FA,RA]  = pivottablerow(R,f,fieldcommand,varargin) 
% gives a pivot table for whole rows of data
% [FA,RA,CA]  = pivottable(R,F,fieldcommand,varargin) 
% input:
%   R: rows of the pivottable.  Thus are vectors/ mtaices of size (N*numrow_variables) )
%   F: Data: (N x Q). The different variables will be
%            end up as different Q columns of the pivottable 
%   fieldcommand: function-name to plug in example. On a NxQ data, the
%               function should return a 1 x Q output 
%      (mean,median,corr,robustmean etc....)
%   VARARGIN: 
%       'datafilename',filename: saves pivottable as a formated text file
%       'numformat',format: makes pivottprint print it out in specified
%               number format
%       'subset',indicator: selects a subset of the data, indicated by 
%               the 1's in the indicator 
%       'forcerow',values: Forces the rows to have the entries values 
% output :
%   FA: the field of the pivot table, it's a category x Q Matrix 
%   RA: row-headers
%  If no output varaibles are given, pivottable prints the table on the
%  screen
% 
%
% written by Joern Diedrichsen (j.diedrichsen@ucl.ac.uk)
% v.1.0: 2012, based on pivottable; 
FA=[];RA=[];
[R,Rconv]=fac2int(R);
[Rr,Rc]=size(R);
[Fr,Fc]=size(f);
numformat='%6.2f';
% check for empty matrixes
if(Fr==0) 
    fprintf('Pivottable error: Pivottable empty\n');
    return;
end;

if (nargin<3) 
    fprintf('Pivottable error: You need to specify field command (e.g. "mean")\n');
    return;
end;

datafilename=[];
subset=true(size(f,1),1);

vararginoptions(varargin,{'datafilename','subset','numformat','forcerow'});
if (~isempty(R)) 
    R=R(subset,:);
end;
f=f(subset,:);
if (isempty(f))
    return;
end;

A=pidata([R],f); % get the columns-oriented version
[numCat,Ac]=size(A);

% compress A into a matrix of row-categories, column-catgories and results
RA=[];FA=[];
for r=1:numCat
    RA=[RA;A{r,1}];
    FA=[FA;fcneval(fieldcommand,A{r,2})];
end;

% now sort the entries
if length(RA)>1
    [RA,Index]=sortrows(RA);
    FA=FA(Index,:);
end;

% Now check if we need to do forcerow: NOT TESTED YET! 
if (exist('forcerow','var'))
    if (size(RA,2)~=size(forcerow,2))
        error('forcerow argument must have same size as column argument');
    end;
    F_new=ones(size(forcerow,1),size(FA,2))*NaN;
    for i=1:size(forcerow,1)
        j=findrow(RA,forcerow(i,:));
        if (~isempty(j))
            F_new(i,:)=FA(j,:);
        end;
    end;
    RA=forcerow;
    FA=F_new;
end;

RA=int2fac(RA,Rconv);

if (nargout==0)
    print_pivot(RA,[1:size(FA,2)]',FA,numformat);
end;
if (~isempty(datafilename)) 
    [Rr,Rc]=size(RA);
    dlmwrite(datafilename,[RA FA],'\t'); 
end;