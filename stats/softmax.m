function mu=softmax(x,flag)
% function mu=softmax(x,flag)
% returns softmax response function
% x is a K*N or (K-1)*N matrix 
% mu us a K*N matrix of probabilities 
% flag: 
% reduced / empty 
%       K-1 vector assumed with the last one set to one
% full (default)
%       K vector assumed 
% Ignores NaN's and sets these probabilities to NaN
if (nargin<2)
    flag='full';
end;
[K,N]=size(x);
if strcmp(flag,'reduced')
    K=K+1;
    x=[x;ones(1,N)];
end;
E=exp(x);
i=find(isnan(E));
E(i)=0;
if any(isinf(E))
    [a,i]=max(x);
    mu=ones(size(x,1),1)*10e-100;
    mu(i)=1;
else
    mu=E./repmat(sum(E),K,1);
end;
mu(i)=NaN;