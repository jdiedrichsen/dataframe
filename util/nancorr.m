function [R,RL,RU]=nancorr(X)
% returns the correlation matrix of X (by column), if X has sparse 
% observation. For each correlation it excludes rows in which 
% observations are missing on either side 

[N,Q]=size(X); 
R=nan(Q,Q); 
RL=nan(Q,Q); 
RU=nan(Q,Q); 
for i=1:Q 
    for j=1:Q 
        indx=find(~isnan(X(:,i)) & ~isnan(X(:,j)));
        if ~isempty(indx)
            [R(i,j),RL(i,j),RU(i,j)]=mycorr([X(indx,[i j])]); 
            R(j,i)  = R(i,j);
            RL(j,i) = RL(i,j);
            RU(j,i) = RU(i,j);
        end; 
    end; 
end; 
