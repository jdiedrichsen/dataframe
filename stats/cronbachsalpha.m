function alpha=cronbachsalpha(y,subj,split,varargin); 
% function alpha=cronbachsalpha(y,sn,split,varargin); 
%   Cronbach's alpha (1951) is a measure of internal consistency of a measure. 
% Suppose you want to test how reliable a behavioral measure is to
% determine the difference between differnt subjects. 
% The final measure X_i for each subject is the mean over x_i,k, i.e. k
% independent splits of the data. Each measure is compose of the true value
% (a) with variance sigma_a over sibjects and the error (e) with variance
% sigma_e per measure. Then the expected vale of cronbach's alpha is: 
% 
% alpha = sigma_a / (sigma_a + sigma_e/K) 
% 
% Importance: If you have two measures with a certain cronbach's alpha,
% then the expected maximum correlation between those two variables (if
% they measure the same thing), is r_max = sqrt(alpha_1 * alpha_2) 
% 
% INPUTS:
%   y: dependent data vector (Nx1)
%   subj: subjects or condition variable that needs to be measure consitently (Nx1)
%   split: Independent repetitions or splits of the data  
% ALTERNATIVELY: 
%   y is already a matric of subj x split   
% VARARGIN
%   'subset',indx: Take only subset of the data
% OUTPUTS:
%    alpha: Cronbach's alpha 
% ---------------------------------------------------------------
% 
% j.diedrichsen@ucl.ac.uk

subset=[];
vararginoptions(varargin,{'subset'});
if (isempty(subset)) 
   subset = (y==y);
end; 
if (size(y,2)>1 & isempty(split) & isempty(subj))
    X=y; 
elseif (size(y,2)==1 & ~isempty(split) & ~isempty(subj))
    X = pivottable(subj,split,y,'nanmean','subset',subset); 
else
    error('Usage: cronbachsalpha(y,subj,split) OR cronbachsalpha(Y,[],[]');
end;
C = nancov(X);   % Get covariances across all splits
K = size(X,2); 
varM = trace(C)/K;
covM = (C.*(1-eye(K))); 
covM = sum(covM(:))/(K*(K-1));
alpha=K*covM/(varM+(K-1)*covM);

