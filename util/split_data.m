function [I,M,b]=split_data(X,varargin)
% functions [I,M,borders]=split_data(X,varargin):
% splits the data into x quantiles and
% OUTPUT:
%   I: number of quantiles for each data point
%   M: center of each bin for each observation 
% VARARGIN:
% 'subset': only use a certain subset
% 'split': calculate the quantiles after splitting the data into different
%           categories
% 'borders': give borders of prefixed categories 
% 'numquant': Number of quatiles 
% v1.0 01/06/06: subset option introduced
%  1.1 18/3/08: split version introduced
%  1.2 3/7/10: Number of quatiles is varargin 
subset=[];
split=[];
borders=[];
numquant=10; 
vararginoptions(varargin,{'subset','split','borders','numquant'});
if (isempty(subset));
    subset=ones(size(X,1),1); 
end;
if (isempty(split))
    split=ones(size(X,1),1);
end;

if (~isempty(borders))
    numquant=length(borders); 
end; 

cat=unique(split(find(subset),:),'rows');

% Define the quantiles 
quant=[0:numquant-1]./numquant;
I=X*NaN; 
M=X*NaN; 
for i=1:size(cat,1);
    indx=findrow([split subset],[cat(i,:) 1]);
    if (isempty(borders))
        b=prctile(X(indx,:),quant*100);
    else 
        b=borders; 
    end;
    for j=1:numquant
        k=find(X(indx)>=b(j));
        I(indx(k),1)=j;
    end;
    for j=1:numquant
        k=find(I(indx)==j);
        M(indx(k),1)=mean(X(indx(k)));
    end;
end;
