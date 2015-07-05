function [Fn,yr]=ancova(y,SN,X,varargin)
% function ancova(y,SN,X,varargin)
% One-way analysis of (co-)variance (ANCOVA).
% INPUTS:
%   y: dependent data vector (Nx1)
%  SN: Subject or grouping factor: data will be condensed over this factor
%       first
%   X: independent (grouping) variable (NxQ)
% VARARGIN
% 'subset'   ,indx   : Take only subset of the data
% 'covariate',c      : Use this variable as a covariate
% 'fig',0/1          : Plot Figure
% 'names',{'f1',..}  : Factor names for table
% OUTPUTS:
%   F: Factor structure that has the information for the printed
%           Prints an ANCOVA-table
%   yr: Corrected values of the y-variable. These are the values of the dependent variable.
%        assuming that the covariate was exactly at the mean value -
%        ANCOVA is IN ESSENCE an ANOVA on these values with the difference
%        that the error df are adjusted for extra estimation
% COMMENTS:
%   N-factor AN(C)OVA
%   Use this routine only for between-subjects ANCOVA. For designs with
%   between and within subject factors, first eliminate the within subejct
%   factors by taking the appropriate contrast for each participant, and
%   then use this routine to test the between subjects effects.
%
%  Should work for unbalanced designs (i.e. designs with different numbers
%  per group). We are using here the most conservative Type III Sums of Squares.
% see: http://mcfromnz.wordpress.com/2011/03/02/anova-type-iiiiii-ss-explained/
% or
% http://goanna.cs.rmit.edu.au/~fscholer/anova.php
% 
% Note of warning: Intercept may not be exactly right in unblanced designs 
% j.diedrichsen@ucl.ac.uk


covariate=[];
subset=[];
names={'Factor1','Factor2','Factor3'};
fig=0;
vararginoptions(varargin,{'subset','covariate','fig','names'});

if (~isempty(subset))
    y=y(subset,:);
    X=X(subset,:);
    SN=SN(subset,:);
    if (~isempty(covariate))
        covariate=covariate(subset,:);
    end;
end;

% condense the observations, so only one measure per subject
if (~isempty(covariate))
    covariate=pivottable([X SN],[],covariate,'mean');
end;
[y,R]=pivottable([X SN],[],y,'mean');
X=R(:,1:end-1);
[N,Q]=size(X);

% Get intercept
F.X=ones(N,1);
F(1).name='intercept';

% Get Simple main Factors
for q=1:Q
    [F(q+1).X,F(q+1).levels]=convertFactor(X(:,q));
    F(q+1).raw=X;
    F(q+1).name=names{q};
end;

% Get 2-way interactions if necessary
if Q>1
    for q=1:Q
        for k=q+1:Q
            j=length(F)+1;
            [F(j).X,F(q+1).levels]=indicatorMatrix('interaction_reduced',X(:,[q k]));
            F(j).name=[names{q} '*' names{k}];
            F(j).X=bsxfun(@minus,F(j).X,mean(F(j).X)); % Remove the mean
        end;
    end;
end;

% Build the full design matrix 
xX=[];
for i=1:length(F)
    xX=[xX F(i).X];
end;

% Deal with possible covariate
if (~isempty(covariate))
    if (size(covariate,2)~=1)
        error('currently only a single covariate');
    end;
    FC.X=[covariate-mean(covariate)];
    FC.df=1;
    pX=[xX FC.X];
    FC.b=inv(pX'*pX)*pX'*y;
    yr=y-FC.X*FC.b(end); % Subtract the prediction of covariate
else
    yr=y;
    FC.df=0;
end;

% Evaluate the full model:
r=yr-xX*(xX\yr);
FE.SSR=r'*r;
FE.df=N-size(xX,2)-FC.df;
FE.name='Error';

% Now calculate the SS and stats for each of the factors, using Type III SS
% Using always all other factors as the alternative model
for f=1:length(F)
    xXr=[];
    for i=1:length(F)
        if (i~=f)
            xXr=[xXr F(i).X];
        end;
    end;
    r=yr-xXr*(xXr\yr);
    F(f).SSR=r'*r;
    F(f).SS=F(f).SSR-FE.SSR;         % Sum of squares in the drop in fit when factor is left out
    F(f).df=size(F(i).X,2);          %
end;

% Plot covariate Figure if requested
if (fig==1 & ~isempty(covariate))
    color={[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1]};
    scatterplot(covariate,y,'split',X,'leg','auto');
    x0=[min(covariate) max(covariate)];
    [~,~,k]=unique(X,'rows'); 
    for i=1:max(k)
        j=find(k==i);
        X0=[xX(j(1),:) min(FC.X);xX(j(1),:) max(FC.X)];
        yp=X0*FC.b;
        h=line(x0',yp);
%         set(h,'Color',color{i});
    end;
    hold off;
end;
y=yr;

% T.SN = R(:,3);
% T.BN = R(:,1);
% T.digit = R(:,2);
% T.y = y;
% lineplot(T.digit,T.y,'split',T.BN,'style_thickline','leg','auto');



fprintf('---------------------------------------------------------\n');
fprintf('Name              p        F       df1       df2\n');
fprintf('---------------------------------------------------------\n');

for i=1:length(F)
    Fn(i)=evaluate(F(i),FE);
end;
evaluate([],FE);

fprintf('---------------------------------------------------------\n');



function [X,levels]=convertFactor(rawFactor)

if isempty(rawFactor)
    X=[];
    return;
end
N=size(rawFactor,1);
levels=sort(unique(rawFactor));
X=zeros(N,length(levels)-1);
for j=1:length(levels)-1
    X(rawFactor==levels(j),j)=1;
    X(rawFactor==levels(end),j)=-1;
end;
X=bsxfun(@minus,X,mean(X));

function F=evaluate(F,FE)
if (isempty(F)) % Error
    fprintf('%12s                    %d\n',FE.name,FE.df);
elseif (isempty(FE)) % No test
    fprintf('%12s                    %d\n',F.name,F.df);
else
    F.df2=FE.df;
    F.F=(F.SS/F.df)/(FE.SSR/FE.df);
    F.p=1-fcdf(F.F,F.df,FE.df);
    fprintf('%12s %10.3f %10.3f     %d     %d\n',F.name,F.p,F.F,F.df,FE.df);
end;