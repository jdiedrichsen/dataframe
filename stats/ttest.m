function [t,p]=ttest(groupA,groupB,tails,kind)
% function [t,p]=ttest(groupA,groupB,tails,kind)
% Computes simple t-test on data from groupA and Group B
% tails: 1: one-sided test(tests for A>B) 2: two-sided test
% kind: 'paired'
%       'independent'
%       'onesample'
% Prints out the mean and +- SEM as information 
switch (kind)
    case 'paired'
        indx=find(~isnan(groupA) & ~isnan(groupB));
        N=length(indx);
        df=N-1;
        SE=sqrt(var(groupA(indx)-groupB(indx))/N);
        t=mean(groupA(indx)-groupB(indx))/SE;
        if tails==2
            p=2*(1-tcdf(abs(t),df));
        else 
            p=1-tcdf(t,df);
        end; 
        if (nargout==0)
            fprintf(['Condition 1: %2.3f (%2.3f)\n'...
                     'Condition 2: %2.3f (%2.3f)\n'...
                     'Difference:  %2.3f (%2.3f)\n'],...
                nanmean(groupA(indx)),nanstd(groupA(indx))/sqrt(N),...
                nanmean(groupB(indx)),nanstd(groupB(indx))/sqrt(N),...
                nanmean(groupA(indx)-groupB(indx)),std(groupA(indx)-groupB(indx))/sqrt(N));
            fprintf('t(%i) = %2.3f  p = %2.5f\n',df,t,p);
        end;
    case 'independent'
        indxA=find(~isnan(groupA));
        indxB=find(~isnan(groupB));
        Na=length(indxA);
        Nb=length(indxB);
        N=Na+Nb;df=Na+Nb-2;
        wa=(Na-1)/(N-2);wb=(Nb-1)/(N-2);
        SE=sqrt((wa*var(groupA(indxA))+wb*var(groupB(indxB)))*(1/Na+1/Nb));
        t=(nanmean(groupA(indxA))-nanmean(groupB(indxB)))/SE;
        if tails==2
            p=2*(1-tcdf(abs(t),df));
        else 
            p=1-tcdf(t,df);
        end; 
        if (nargout==0)
            fprintf(['Group 1: %2.3f (%2.3f)\n'...
                     'Group 2: %2.3f (%2.3f)\n'...
                     'Difference: %2.3f (%2.3f)\n'],...
                        nanmean(groupA(indxA)),nanstd(groupA(indxA))/sqrt(Na),...
                        nanmean(groupB(indxB)),nanstd(groupB(indxB))/sqrt(Nb),...
            nanmean(groupA(indxA))-nanmean(groupB(indxB)),SE); % THIS IS INCORRECT: nanstd(groupA(indxA)-groupB(indxB))); 
            fprintf('t(%i) = %2.3f  p = %2.3f\n',df,t,p);
        end;
    case 'onesample'
        indx=find(~isnan(groupA));
        N=length(indx);
        df=N-1;
        SE=sqrt(var(groupA(indx))/N);
        t=mean(groupA(indx))/SE;
        if tails==2
            p=2*(1-tcdf(abs(t),df));
        else 
            p=1-tcdf(t,df);
        end; 
        if (nargout==0)
            fprintf('Mean: %2.3f (%2.3f)\n',nanmean(groupA(indx)),nanstd(groupA(indx))/sqrt(N));
            fprintf('t(%i) = %2.3f  p = %2.5f\n',df,t,p);
        end;
end;