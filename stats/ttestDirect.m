function [T,P,cat]=ttestDirect(Y,X,tails,kind,varargin)
% [t,p]=ttestDirect(Y,groupingVar,tails,kind,varargin)
% INPUT:
%   y:        data vector (Nx1)
%   x:        grouping variable (Nx1) (and subject variable)
%   tails:    1 or 2 tails
%   kind:     'paired': for paired t-test, give a subject variable as
%               second column of x
%             'independent': independent t-test
%             'onesample': omesample t-test
% VARGIN:
% 'subset',indicator: logical variable that determines if included
% EXAMPLES:
% ttestDirect(D.y,[D.group D.SN],2,'independent','subset'...)
% ttestDirect(D.y,[D.group D.SN],2,'independent','subset'...)
% ttestDirect(D.y,[D.SN],2,'onesample','subset'...)


subset=[];
split=[];
% -----------------------------
% check sizes
N=size(Y,1);
n=size(X,1);
if (N~=n)
    error('y and x need to be Nx1 vectors');
end;

% -------------------------------
% deal with vararingins & subjects
vararginoptions(varargin,{'subset','split'});

if (isempty(split))
    split=ones(N,1);
    cat=NaN;
end; 

if ~isempty(subset)
    Y=Y(subset,:);
    X=X(subset,:);
    split=split(subset,:);
end;

[cat,~,split]=unique(split,'rows');

for i=1:max(split);
    y=Y(split==i,:); 
    x=X(split==i,:);
    if (max(split)>1)
        fprintf('Gr: %d\t',cat(i,1)); 
    end; 
    switch (kind)
        case 'paired'
            % Check size
            k=size(x,2);
            if (k~=2)
                error('for paired t-test x should be Nx2: [groupingVar subjectVar]');
            end;
            
            % Group the data and compute state
            XX     = pivottable(x(:,2),x(:,1),y,'mean');
            groupA = XX(:,1);
            groupB = XX(:,2);
            indx   = find(~isnan(groupA) & ~isnan(groupB));
            N      = length(indx);
            df     = N-1;
            M      = mean(groupA(indx)-groupB(indx));
            SE     = sqrt(var(groupA(indx)-groupB(indx))/N);
            t      = M/SE;
            if tails==2
                p=2*(1-tcdf(abs(t),df));
            else
                p=1-tcdf(t,df);
            end;
            
            % If no return argument, print means and SE's on the screen
            fprintf('C1: %2.3f (%2.3f)\tC2: %2.3f (%2.3f)\tDiff: %2.3f (%2.3f)\t',...
                nanmean(groupA(indx)),nanstd(groupA(indx))/sqrt(N),...
                nanmean(groupB(indx)),nanstd(groupB(indx))/sqrt(N),...
                M,SE);
            fprintf('t(%i) = %2.3f\tp = %2.3f\n',df,t,p);
        case 'independent'
            % check size & Number of conditions
            k=size(x,2);
            if (k==2)
                [y,x]  = pivottable(x,[],y,'mean');
                x      = x(:,1);
            end;
            
            a=unique(x(:,1));
            if (length(a)~=2)
                error('x should only include 2 groups');
            end;
            groupA = y(x==a(1),:);
            groupB = y(x==a(2),:);
            indxA  = find(~isnan(groupA));
            indxB  = find(~isnan(groupB));
            Na     = length(indxA);
            Nb     = length(indxB);
            N      = Na+Nb;
            df     = Na+Nb-2;
            wa     = (Na-1)/(N-2);wb=(Nb-1)/(N-2);
            M      = (nanmean(groupA(indxA))-nanmean(groupB(indxB)));
            SE     = sqrt((wa*var(groupA(indxA))+wb*var(groupB(indxB)))*(1/Na+1/Nb));
            t      = M/SE;
            if tails==2
                p=2*(1-tcdf(abs(t),df));
            else
                p=1-tcdf(t,df);
            end;
            fprintf('G1: %2.3f (%2.3f)\tG2: %2.3f (%2.3f)\tDiff: %2.3f (%2.3f)\t',...
                nanmean(groupA(indxA)),nanstd(groupA(indxA))/sqrt(Na),...
                nanmean(groupB(indxB)),nanstd(groupB(indxB))/sqrt(Nb),...
                M,SE);
            fprintf('t(%i) = %2.3f\tp = %2.3f\n',df,t,p);
        case 'onesample'
            k=size(x,2);
            if (k>1)
                error('for onesample t-test we need only the subject variable');
            end;
            groupA  = pivottable(x,[],y,'nanmean'); % Get means for each subject
            indx    = find(~isnan(groupA));
            N       = length(indx);
            df      = N-1;
            M       = mean(groupA(indx));
            SE      = sqrt(var(groupA(indx))/N);
            t       = M/SE;
            if tails==2
                p=2*(1-tcdf(abs(t),df));
            else
                p=1-tcdf(t,df);
            end;
            fprintf('G1: %2.2f (%2.3f)\t',nanmean(groupA(indx)),SE);
            fprintf('t(%i) = %2.3f\tp = %2.3f\n',df,t,p);
    end;
    T(i,1)=t; 
    P(i,1)=p; 
    
end;