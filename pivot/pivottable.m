function [FA,RA,CA]  = pivottable(R,C,f,fieldcommand,varargin) 
% gives a pivot table with (Rows-signifier, column-signifier, )
% [FA,RA,CA]  = pivottable(R,C,F,fieldcommand,varargin) 
% input:
%   R,C: row and columns of the pivottable.  These are vectors/ mtaices of size (N*numrow_variables) and N*numcolumn_variables)
%        total number of categories should be lower than 500
%   F: Data Field
%   fieldcommand: function-name to plug in example:
%      (mean,median,corr,robustmean etc....)
%   VARARGIN: 
%       'datafilename',filename: saves pivottable as a formated text file
%       'numformat',format: makes pivottprint print it out in specified
%               number format
%       'subset',indicator: selects a subset of the data, indicated by 
%               the 1's in the indicator 
%       'forcerow',values: Forces the rows to have the entries values 
%       'forcecol',values: Forces the rows to have the entries values 
% output :
%   FA: the field of the pivot table
%   RA: row-headers
%   CA: column-headers
%  If no output varaibles are given, pivottable prints the table on the
%  screen
% 
% EXAMPLES: 
% D=dload('alldata.txt');
%
% Only gives row,column, and field back:
% [f,r,c]=pivottable(D.SN,D.Cond,D.RT,'robustmean','subset',D.c==1);
% 
% prints it on the screen & saves it as a formatted file:
% pivottable([D.Group D.SN],[D.Cond D.subcond],D.angle,'circstddeg','save','myresultfile');
% 
% calculates the correlation within each subject (no column category)
% pivottable(D.SN,[],[D.x D.y],'corr');
% 
% Field commands can also be whole strings of expressions. The dependent 
% variable is marked as an x. The following command calculates the RMSE:
% pivottable(D.SN,D.condition,D.error,'sqrt(mean(x.^2))');
%
% written by Joern Diedrichsen (jdiedric@jhu.edu)
% v.1: 2001
% v.2: Fixed a couple of bugs in utility routines pidata and pivrecurs: 
%       Now treats NaN's in the data sheet correctly
%       can accomodate fieldcommands that are returning a scalar on a multi-column variable 
%       (for example: correlations)
%       Support for writing text files
% v.3: done varargin arguments for subset 
% v.4: Allows for complex field commands 
% v.5: added the feature of forcerow and forcecol
FA=[];RA=[];CA=[];
[C,Cconv]=fac2int(C);
[R,Rconv]=fac2int(R);
[Cr,Cc]=size(C);
[Rr,Rc]=size(R);

[Fr,Fc]=size(f);
numformat='%6.2f';
% check for empty matrixes
if(Fr==0) 
    fprintf('Pivottable error: Pivottable empty\n');
    return;
end;

if (nargin<4) 
    fprintf('Pivottable error: You need to specify field command (e.g. "mean")\n');
    return;
end;

datafilename=[];
subset=ones(size(f,1),1);
vararginoptions(varargin,{'datafilename','subset','numformat','forcecol','forcerow'});
if (~isempty(R)) 
    R=R(find(subset),:);
end;
if (~isempty(C)) 
    C=C(find(subset),:);
end;
f=f(find(subset),:);
if (isempty(f))
    return;
end;
A=pidata([R C],f); % get the columns-oriented version
[numCat,Ac]=size(A);

% compress A into a matrix of row-categories, column-catgories and results
R_temp=[];C_temp=[];F_temp=[];
for r=1:numCat
    R_temp=[R_temp;A{r,1}(1:Rc)];
    C_temp=[C_temp;A{r,1}(Rc+1:end)];
    F_temp=[F_temp;fcneval(fieldcommand,A{r,2})];
end;

% put them into final matrix form
[RA,ri,rj]=unique(R_temp,'rows');
[CA,ci,cj]=unique(C_temp,'rows');
FA=ones(size(RA,1),size(CA,1))*NaN;
for i=1:numCat
    FA(rj(i),cj(i))=F_temp(i);
end;
% now sort the entrees
if length(RA)>1
    [RA,Index]=sortrows(RA);
    FA=FA(Index,:);
end;
if length(CA)>1
    [CA,Index]=sortrows(CA);
    FA=FA(:,Index);
end;

% Now check if we need to do forcecol or forcerow
if (exist('forcecol','var'))
    if (size(CA,2)~=size(forcecol,2))
        error('forcecol argument must have same size as column argument');
    end;
    F_new=ones(size(FA,1),size(forcecol,1))*NaN;
    for i=1:size(forcecol,1)
        j=findrow(CA,forcecol(i,:));
        if (~isempty(j))
            F_new(:,i)=FA(:,j);
        end;
    end;
    CA=forcecol;
    FA=F_new;
end;
if (exist('forcerow','var'))
    if (size(RA,2)~=size(forcerow,2))
        error('forcerow argument must have same size as column argument');
    end;
    F_new=ones(size(forcerow,1),size(FA,2))*NaN;
    for i=1:size(forcerow,1)
        if (iscell(forcerow))
            tag=find(strcmp(forcerow{i},Rconv.names{1}));
            if (isempty(tag))
                j=[];
            else
                j=find(RA==tag);
            end;
        else
            j=findrow(RA,forcerow(i,:));
        end; 
        if (~isempty(j))
            F_new(i,:)=FA(j,:);
        end;
    end;
    RA=forcerow;
    FA=F_new;
end;
if (~iscell(RA))
    RA=int2fac(RA,Rconv);
end; 
CA=int2fac(CA,Cconv);
if (nargout==0)
    print_pivot(RA,CA,FA,numformat);
end;
if (~isempty(datafilename)) 
    [Cr,Cc]=size(CA);
    [Rr,Rc]=size(RA);

    F=[zeros(Cc,Rc)*NaN CA';RA FA];
    dlmwrite(datafilename,F,'\t'); 
end;