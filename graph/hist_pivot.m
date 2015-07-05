function hist_pivottable(R,C,F,varargin) 
% function hist_pivottable(R,C,F,varargin) 
% makes a multipanel histogram
% with same x-scaling for all of them
% input:
%   R,C: row and columns of the pivottable.  These are vectors/ matrices 
%   F: Data Field
% VARARGIN 
%   VARIABLES: 
%   'catX',catX: X-category bins
%   'subset',logical expression
%   FLAGS: 
%   'rownames' : Presents rownames 
%   'forceYscale': Forces the y-scale to be the same across all
%   'percent' : 
% History: 
% v 1.0 August 2003: Joern Diedrichsen (jdiedric@bme.jhu.edu)
%   by default forces the x-axis to be the same on all subplot
FA=[];RA=[];CA=[];
colnames=0;rownames=0;forceYscale=0;percent=0;
subset=[];

vararginoptions(varargin,{'subset','catX'},{'rownames','forceYscale','percent','colnames'});
if (~isempty(subset))
    index=find(subset);
    if (~isempty(R)) R=R(index,:);end;
    if (~isempty(C)) C=C(index,:);end;
    F=F(index,:);
end;
[Rr,Rc]=size(R);
[Cr,Cc]=size(C);
[Fr,Fc]=size(F);

if(Cc>1 | Rc>1)
    fprintf('Categorial variables only one-dimensinal\n');
    return;
end;    
% check for empty matrixes
if(Fr==0) 
    fprintf('Pivottable error: Pivottable empty\n');
    return;
end;

% Make the bins standard over all subcategories: 
if ~exist('catX')
    [N,catX] = hist(F);
end;

A=pidata([R C],F); % get the columns-oriented version
[numCat,Ac]=size(A);

% compress A into a matrix of row-categories, column-catgories and results
R_temp=[];C_temp=[];
for r=1:numCat
    R_temp=[R_temp;A{r,1}(1:Rc)];
    C_temp=[C_temp;A{r,1}(Rc+1:end)];
end;

% put them into final matrix form
RA=[];CA=[];FA={};
[RA,ri,rj]=unique(R_temp,'rows');
[CA,ci,cj]=unique(C_temp,'rows');
for i=1:numCat
    FA{rj(i),cj(i)}=A{i,2};
end;
% now sort the entrees
% if length(RA)>1
%     [RA,Index]=sortrows(RA);
%     FA=FA{Index,:};
% end;
% if length(CA)>1
%     [CA,Index]=sortrows(CA);
%     FA=FA{:,Index};
% end;

[row,dummy]=size(RA);
[col,dummy]=size(CA);
subp=1;
for r=1:row
    for c=1:col
        subplot(row,col,subp);
        [N,X]=hist(FA{r,c},catX);
        if (percent) 
            N=N./sum(N)*100;    
        end;
        maxN(r,c)=max(N);
        bar(X,N);
        if (c==1 & rownames)
            ylabel(sprintf('%d',RA(r,:)));
        end;
        if (r==1 & colnames)
            title(sprintf('%d',CA(c,:)));
        end;
        width=catX(2)-catX(1);
        set(gca,'XLim',[min(catX)-width*2 max(catX)+width*2]);
        subp=subp+1;
    end;
end;
subp=1;
if (forceYscale==1)
    maxY=max(max(maxN))*1.05;
    for r=1:row
        for c=1:col
            subplot(row,col,subp);
            set(gca,'YLim',[0 maxY]);   
            subp=subp+1;
        end;
    end;
end;