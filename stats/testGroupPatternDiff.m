function p = testGroupPatternDiff(Y,g,varargin);
% function p = testGroupPatternDiff(Y,g,varargin);
% This function test for distributed differences between two groups of
% observations, very similar to an between-subejcts MANOVA. However, it
% uses permutation or randomisation statistiscs and cab therefore use different
% distance metrics between the group mean patterns, which by default is the
% simple Eucledian distance between the patterns.
% INPUT
%   Y: NxP matrix of observations coming from N subejcts and P variables
%      (or voxels)
%   g: Nx1 group membership of the g subjects to group 1 and 2
% VARARGIN:
%   'metric',name:
%       'Euclidean':    Eucledian distance
%       'Mahalanobis':  Mahalanobis distance - using regularised Sigma estimate
%   permMethod, name:   Method used for permutation
%       'permute'       Exhaustive permutatation
%       'randomise'     Randomisation with Nsampels
%       'auto':         Decides automatically between permuation and
%                       randomisation
%   standardize,true    Standardization of each locus its standard devation?  
metric = 'Euclidean';
permMethod = 'auto';
numSamples = 100000; 
standardize = true; 
vararginoptions(varargin,{'metric','permMethod','standardize'});

% Data size
goodIndex=~any(Y==0 | isnan(Y),1); 
Y=Y(:,goodIndex);

[N,P]=size(Y);

% Group counts
if length(unique(g))~=2
    error('currently can deal only with 2 groups');
end;
if (size(g,1)~=N)
    error('g needs to be an Nx1 group vector');
end;
numGroup(1)=sum(g==1);
numGroup(2)=sum(g==2);

% Subtracting the mean of the data 
Y=bsxfun(@minus,Y,mean(Y)); 
if (standardize) 
    Y=bsxfun(@rdivide,Y,std(Y)); 
end; 

% Lossless Compression of the data using SVD
[U,S]=svd(Y,0);
Y = U*S(1:N,1:N);

% Get the distance metric
distData = feval(metric,Y,g);

% decide whether to do permutation of randomisation stats
if strcmp(permMethod,'auto')
    Nperm = nchoosek(N,numGroup(1));
    if Nperm<100000
        permMethod = 'permute';
    else
        permMethod = 'randomise';
    end;
end;

switch (permMethod)
    case 'permute' % Do exhaustive permutation
        GR1 = nchoosek([1:N],numGroup(1));
        numSamples = size(GR1,1);
        distRand = zeros(numSamples,1);
        for n=1:numSamples
            gRand = ones(N,1)*2; 
            gRand(GR1(n,:))=1; 
            distRand(n,1)=feval(metric,Y,gRand); 
            if mod(n,1000)==0
                fprintf('.'); 
            end; 
        end;
        fprintf('\n'); 
    case 'randomise'
        distRand = zeros(numSamples,1);
        for n=1:numSamples
            gRand = ones(N,1)*2; 
            indx = randperm(N); 
            gRand(indx(1:numGroup(1)))=1; 
            distRand(n,1)=feval(metric,Y,gRand); 
            if mod(n,1000)==0
                fprintf('.'); 
            end; 
        end;
        fprintf('\n'); 
end;

% How many of the bootstrap or random samples exceed the measured distance?
p=sum(distRand>distData)/numSamples; 

function dist=Euclidean(Y,g);
    [N,P]=size(Y); 
    meanPattern=zeros(2,P);
    for i=1:2 
        index = g==i; 
        meanPattern(i,:)=sum(Y(index,:))/sum(index); 
    end; 
    diffPattern = meanPattern(2,:)-meanPattern(1,:); 
    dist = sqrt(diffPattern*diffPattern'); 

function dist=Mahalanobis(Y,g);
    [N,P]=size(Y); 
    lambda=0.01; % 1% on the diagonal 
    meanPattern=zeros(2,P); 
    for i=1:2 
        index = g==i; 
        meanPattern(i,:)=sum(Y(index,:))/sum(index); 
    end; 
    resid=Y-meanPattern(g,:);
    Sigma = (resid'*resid/N)+eye(P)*lambda; 
    diffPattern = meanPattern(2,:)-meanPattern(1,:); 
    dist = sqrt(diffPattern*(Sigma\(diffPattern)')); 



