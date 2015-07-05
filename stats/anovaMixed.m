function results=anovaMixed(data,subjects,varargin); 
% results=anovaMixed(data,subjects,varargin); 
% Carry out an a Mixed (within / between) factor anova. 
% Only for balanced designs 
%
% INPUT: 
%        The way I construct the input data are similar to SPSS. Assuming
%        you have a dataset that works in SPSS anova, just stacking all
%        columns into a single column to form the data vector. What you need
%        to do is just group the within-subject factors and between-subject
%        factors separately. 
%        All inputs must have the same length (N=number of observations) 
%
%        data: data vector for anova, each value is one observation.
%              Size: Nx1
%
%        subjects: numerical vector, can be the subject id, corresponds to
%                  each value in data. size(subjects)=Nx1
%
% VARAGINS: 
%       'within',wtFactors,wtFactorNames
%            wtFactors: within-subject factors. size(wtFactors)= NxQ
%            wtFactorNames: cell array. each cell contains the Q name of the
%                       correspondent within-subject factor. For output
%                       purpose only.
%        'between',btFactors,btFactorNames 
%            btFactors: between subject factor. size(btFactors)= NxP 
%            btFactorNames: cell array. each cell contains the P name of the
%                   correspondent between-subject factor. For output
%                   purpose only.
%        'intercept',0/1: Add or exclude intercept to the ANOVA table 
%        'subset', i: Includes only data for which i>0
% Output: Structure with varies information. Feel free to extract information you want.
%
%
%
% Original Author: Zheng Hui (zhenghui.zhh@gmail.com)
% Thanks to Joshua Goh for the GLM codes. http://j-rand.blogspot.com/
% 
% Modifications, minor fixes, and wrapper for flexible input argument handling
% by Joern Diedrichsen, 2012 (j.diedrichsen@ucl.ac.uk) 
% and Alexandra Reichenbach (a.reichenbach@ucl.ac.uk). 
% Version 2: 
%   - Intercept added 
%   - Compression of data with tapply added 
%   - removed bug that gives wrong results when variable start with the
%           same word 

wtFactors=[];
wtFactorNames={};
btFactors=[];
btFactorNames={};
subset=[]; 
verbose=1; 
intercept=0;                % Include intercept as an explit factor?? 

% Parse Varargin: 
c=1; 
numargs=length(varargin); 
while (c<numargs)
    switch(varargin{c}) 
        case 'within'
            if (numargs<c+2)
                error('Provide both factor and factor names for within factors'); 
            end; 
            wtFactors=varargin{c+1}; 
            wtFactorNames=varargin{c+2};
            if (size(wtFactors,2)~=length(wtFactorNames)) 
                error('Provide as many factor names as variables for within'); 
            end; 
            c=c+3; 
        case 'between'
            if (numargs<c+2)
                error('Provide both factor and factor names for between factors'); 
            end; 
            btFactors=varargin{c+1}; 
            btFactorNames=varargin{c+2}; 
            if (size(btFactors,2)~=length(btFactorNames)) 
                error('Provide as many factor names as variables for between'); 
            end; 

            c=c+3; 
        case 'subset'
           subset=varargin{c+1}; 
           c=c+2; 
        case 'verbose'
           verbose=varargin{c+1}; 
           c=c+2; 
        case 'intercept'
           intercept=varargin{c+1}; 
           c=c+2; 
        otherwise
            if (ischar(varargin{c}))
                error(sprintf('unknown option: %s',varargin{1}));
            else 
                error(sprintf('option string required as %d. input argument',c+2));
            end; 
    end; 
end; 

% Check if all the sizes are consistent 
sizes=[size(data,1) size(wtFactors,1) size(btFactors,1)]; 
sizes(sizes==0)=[];
if (sum(abs(sizes-mean(sizes)))>0)
    error('data and factors must have the same number of rows'); 
end; 


if (~isempty(subset))
    if size(subset,1)~=size(data,1)
        error('subset must be Nx1 vector or logicals'); 
    end; 
    data=data(subset,:);   
    subjects=subjects(subset,:);   
    
    if (~isempty(wtFactors))
        wtFactors=wtFactors(subset,:);
    end; 
    if (~isempty(btFactors))
        btFactors=btFactors(subset,:);
    end; 
end; 

% Check if the variable names are all unique 
names={wtFactorNames{:} btFactorNames{:}}; 
for i=1:length(names) 
    for j=i+1:length(names)
        if ~isempty(strfind(names{i},names{j})); 
            error(sprintf('Variable name "%s" is contained in variable name "%s", please make unique!',names{j},names{i})); 
        end; 
        if ~isempty(strfind(names{j},names{i})); 
            error(sprintf('Variable name "%s" is contained in variable name "%s", please make unique!',names{i},names{j})); 
        end; 
        
    end;
end; 


% Condense the data to make sure that there is only one observation 
% Per subject per factor 
[data,R]=pivottable([wtFactors btFactors subjects],[],data,'mean'); 
wtFactors=R(:,1:size(wtFactors,2)); 
btFactors=R(:,size(wtFactors,2)+1:(size(wtFactors,2)+size(btFactors,2))); 
subjects=R(:,end); 


wtFactors=convertFactors(wtFactors);
btFactors=convertFactors(btFactors);
subjects=convertFactors(subjects);

nbWtFactors=length(wtFactors);
nbBtFactors=length(btFactors);

%All combinations of within-subjects effects
wtMatComb={};
for i=1:nbWtFactors
    wtMatComb{i}=nchoosek(1:nbWtFactors,i);
end

%All combinations of between-subjects effects
btMatComb={};
for i=1:nbBtFactors
    btMatComb{i}=nchoosek(1:nbBtFactors,i);
end

%All combinations of within X between-subjects effects
wtXbtMatComb={};
k=0;
for i=1:length(wtMatComb)
    for j=1:length(btMatComb)
        k=k+1;
        index=0;
        for bt=1:size(btMatComb{j},1)
            for wt=1:size(wtMatComb{i},1)
                index=index+1;
                wtXbtMatComb{k}(index,:)=[wtMatComb{i}(wt,:) btMatComb{j}(bt,:)+nbWtFactors];
            end
        end
    end
end

[xmatWt, pnameWt] = createX(wtFactors,wtFactorNames,wtMatComb);
[xmatBt, pnameBt] = createX(btFactors,btFactorNames,btMatComb);
[xmatWtXBt, pnameWtXBt] = createX([wtFactors btFactors],[wtFactorNames btFactorNames],wtXbtMatComb);


%All combinations of error terms-----
errMatComb={};
for i=1:length(wtMatComb)
    errMatComb{i}=wtMatComb{i};
    errMatComb{i}(:,end+1)=1+nbWtFactors;
end
[xmatErr, pnameErr] = createX([wtFactors subjects],[wtFactorNames {'(E)'}],errMatComb);


%Calling glm for anova----------------
if (intercept==1)   % intercept explicit 
    xmatI.p=ones(size(data,1),1);
    xmat=[xmatI xmatWt xmatWtXBt xmatBt];
    pname=[{'intercept'} pnameWt pnameWtXBt pnameBt];
else     
    xmat=[xmatWt xmatWtXBt xmatBt];
    pname=[pnameWt pnameWtXBt pnameBt];
end; 
results=callGLMForAnova(data,pname,xmat,pnameErr,xmatErr,subjects,intercept);

% Now do printout of ANOVA: 
if (verbose)
   % fprintf('reach/att x own/distr x exp (for tj & nb distr==4):\n');
        fprintf('%12s  %6s  %6s  %3s  %3s\n','Name','p','F','df1','df2'); 
        fprintf('-------------------------------------------------\n');

   for i=1:size(results.eff,2)
        fprintf('%12s  %6.4f  %6.3f  %3.0d  %3.0d\n',results.eff(1,i).Name,results.eff(1,i).p,results.eff(1,i).F,results.eff(1,i).DF,results.eff(1,i).errDF);
   end 
end; 


%-----------------------end of main function-------------------------------


%------------------------calling glm for anova-----------------------------
function results=callGLMForAnova(data,pname,xmat,pnameErr,xmatErr,subjects,intercept)

nbSubj=size(subjects{1},2)+1;

R = stats_glm_anova(pname,xmat,data,intercept);
RE = stats_glm_anova(pnameErr,xmatErr,R.full.Residual,0);   % For error term, make intercept implicit 

%Computing stats-----------------------
DFTO=0;
%create effect terms
nbEff=length(xmat);
for i=1:nbEff
    stats(i).Name=pname{i};
    stats(i).X=xmat(i).p;
    stats(i).SSE=R.red(i).SSE-R.full.SSE;
    stats(i).DF=R.red(i).DFE-R.full.DFE;
    stats(i).MSE=stats(i).SSE./stats(i).DF;
    stats(i).errName='';
    DFTO=DFTO+stats(i).DF;
end

%create error terms for the within-error 
nbErr=length(xmatErr);
errTerms=[]; 
for i=nbErr:-1:1
    errTerms(i).Name=pnameErr{i};
    errTerms(i).X=xmatErr(i).p;
    errTerms(i).SSE=RE.red(i).SSE-RE.full.SSE;
    effUsingThisErr=[];
    for j=1:nbEff
        if (isempty(stats(j).errName) & ~isempty(strfind(stats(j).Name,errTerms(i).Name(1:end-3))))  % Bug fix: was strfind 
            effUsingThisErr(end+1)=j;
            stats(j).errName=errTerms(i).Name;
            stats(j).errSSE=errTerms(i).SSE;
        end
    end
    errTerms(i).DF=stats(effUsingThisErr(1)).DF*nbSubj-sum([stats(effUsingThisErr).DF]);
    errTerms(i).MSE=errTerms(i).SSE./errTerms(i).DF;
    DFTO=DFTO+errTerms(i).DF;
    for j=1:length(effUsingThisErr)
        stats(effUsingThisErr(j)).errDF=errTerms(i).DF;
        stats(effUsingThisErr(j)).errMSE=errTerms(i).MSE;
    end
end

% For all fixed effects, using residual error 
errTerms(end+1).DF=size(data,1)-(1-intercept)-DFTO;
errTerms(end).SSE=RE.full.SSE;
errTerms(end).MSE=errTerms(end).SSE./errTerms(end).DF;
errTerms(end).Name='Residual';
errTerms(end).X=RE.full.Residual;
%finalize the F values
for i=1:nbEff
    if isempty(stats(i).errName)
        stats(i).errDF=errTerms(end).DF;
        stats(i).errSSE=errTerms(end).SSE;
        stats(i).errMSE=errTerms(end).MSE;
    end
    stats(i).F=stats(i).MSE./stats(i).errMSE;
    stats(i).p=1-cdf('F',stats(i).F,stats(i).DF,stats(i).errDF);
end

results.eff=stats;
results.err=errTerms;
%-----------------------end of callGLMForAnova-----------------------------


%-------------create design matrix using combination and factors-----------
function [xmat, pname] = createX(factors,factorNames,combinations)

if isempty(combinations)
    xmat=[];
    pname={};
    return
end
index=0;
for i=1:length(combinations)
    nWayX=size(combinations{i},1);
    for j=1:nWayX
        nWays=size(combinations{i},2);%n-way interactions(including main effects, one way)
        firstFactor=combinations{i}(j,1);
        index=index+1;
        xmat(index).p=factors{firstFactor};
        pname{index}=factorNames{firstFactor};
        for k=2:nWays
            thisFactor=combinations{i}(j,k);
            [xmat(index).p pname{index}]=createAXB(xmat(index).p,factors{thisFactor},pname{index},factorNames{thisFactor});
        end
    end
end

%--------------------------end of createX----------------------------------


%------------------create interaction matrix from two matrix---------------
function [xMat, pName]=createAXB(matA,matB,nameA,nameB)

lengthA=size(matA,2);
lengthB=size(matB,2);

xMat=zeros(size(matA,1),lengthA*lengthB);

k=0;
for i=1:lengthA
    for j=1:lengthB
        k=k+1;
        xMat(:,k)=matA(:,i).*matB(:,j);
    end
end
if strcmp(nameB,'(E)')
    pName=[nameA nameB];
else
    pName=[nameA '*' nameB];
end

%----------------------------end of createAXB------------------------------

%-----------------------transform factors to 1:N---------------------------
function transformedFactors=convertFactors(rawFactors)

if isempty(rawFactors)
    transformedFactors=[];
    return
end

[nbObs, nbFactors]=size(rawFactors);

for i=1:nbFactors
    
    thisFactor=rawFactors(:,i);
    
    %change value of predictors to values 1:N
    levels=sort(unique(thisFactor));
    for j=1:length(levels)
        thisFactor(thisFactor==levels(j))=j+1980;
        %1980 is just a random large number for test case when the value in
        %dummy variable is between 1:j (j<1980). Hopefully no one will do a
        %anova with more than 1980 levels. Well, I was born in 1980, so
        %maybe it is not so random in that sense.
    end
    thisFactor=thisFactor-1980;
    %change matrix to sigma-restricted design matrix
    nbLevels=max(thisFactor);
    thisMat=zeros(nbObs,nbLevels-1);
    for j=1:nbObs
        if thisFactor(j)==nbLevels
            thisMat(j,:)=-1;
        else
            thisMat(j,thisFactor(j))=1;
        end
    end
    transformedFactors{i}=thisMat;
    
end

%---------------------------end of convertFactors--------------------------


%-----------------------start of stats_glm_anova---------------------------
%**************************************************************************
% GENERAL LINEAR MODEL ANOVA - Function created by Josh Goh May 2006
%--------------------------------------------------------------------------
% Parameters:
%
% pname - name of each factor
% xmat  - design matrix as a structure with each factor at the higher level
%         (xmat), and each factor level (as individual predictor columns) in the
%         lower level (xmat.p)
% y     - data as a vector of values with same no. of rows as predictors in xmat
%**************************************************************************

function [R] = stats_glm_anova(pname,xmat,y,intercept)

xfull=[];

for p=1:length(xmat)
    
    R.pname(p)=pname(p);
    xfull=[xfull xmat(p).p];
    
    xplist=[1:1:length(xmat)];
    xplist(p)=[];
    
    xred(p).p=[];
    
    for pp=1:length(xplist)
        xred(p).p=[xred(p).p xmat(xplist(pp)).p];
    end
    
    R.red(p)=stats_glm_matrix(xred(p).p,y,intercept);
    
end

R.full=stats_glm_matrix(xfull,y,intercept);

for p=1:length(xmat)
    R.red(p).F=((R.red(p).SSE-R.full.SSE)/(R.red(p).DFE-R.full.DFE))/(R.full.SSE/R.full.DFE);
end

%------------------------end of stats_glm_anova----------------------------


%-----------------------start of stats_glm_matrix--------------------------
%**************************************************************************
% GENERAL LINEAR MODEL - Function created by Josh Goh January 2006
%--------------------------------------------------------------------------
% Fits given model (x) to data (y).
% Outputs - Regression parameter estimates and fit.
%--------------------------------------------------------------------------
% Parameters:
%
% format        - 1=data variables; 0=text file data
% xfile         - x data file (model)
% yfile         - y data file (response variable)
% basedirname   - base directory of data files
%
% E.g. >>stats_glm_matrix('/data/test/','xdata.txt','ydata.txt')
%**************************************************************************

function [s] = stats_glm_matrix(x,y,intercept)

n=size(y,1);           % Change from original: this fixes problem
npred=size(x,2);

if (intercept==0)    % Only add when intercept implict 
    x=[ones(n,1) x]; % Add one column of constants
end; 

b=inv(x'*x)*x'*y; % Betas


% Sums of Squares
%--------------------------------------------------------------------------
j=ones(size(y,1),size(y,1)); % Create J matrix

if (intercept==0) 
    SSTO=(y'*y)-(1/n)*y'*j*y;  % Account for intercept explicitly 
else 
    SSTO=(y'*y);               % Leave Intercept in 
end; 
SSE=(y'*y)-(b'*x'*y);
SSTO=diag(SSTO);
SSE=diag(SSE);
SSR=SSTO-SSE;

DFTO=n-1;
DFR=npred;
DFE=DFTO-DFR;

MSE=SSE/DFE;
MSR=SSR/DFR;

residual=y-x*b;

varb=MSE(1)*(inv(x'*x));

for i=1:npred+(1-intercept)
    varcovarb(i)=varb(i,i);
    tbeta(i)=b(i)/sqrt(varcovarb(i));
end

% Statistical test values
%--------------------------------------------------------------------------
F=MSR./MSE; Rsquare=SSR./SSTO; Rsquareadj=1-((n-1)/(n-npred))*(SSE/SSTO);


% Enter general regression into structure variable
%--------------------------------------------------------------------------
s = struct('N',n,...
    'NoofPred',npred+1,... % include constant
    'SSTO',SSTO,...
    'SSE',SSE,...
    'SSR',SSR,...
    'DFTO',DFTO,...
    'DFE',DFE,...
    'DFR',DFR,...
    'MSE',MSE,...
    'MSR',MSR,...
    'betas',b,...
    'betavarcovar',varcovarb',...
    'betat',tbeta',...
    'F',F,...
    'R2',Rsquare,...
    'R2adj',Rsquareadj,...
    'Residual',residual);


% Contrasts for main effects and interactions
%--------------------------------------------------------------------------
%-------------------------end of stats_glm_matrix--------------------------


