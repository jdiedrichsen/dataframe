function [yr,covariate]=covCorr(y,c,X,obs,varargin)
% function covCorr(y,X,varargin)
% Correction of data for a covariate
% Like on an Ancova, it assumes same slope and different intercepts
% For all grouping values of X
% INPUTS:
%   y: dependent data vector (Nx1)
%   c: covariate (Nx1)
%   X: independent (grouping) variable (NxQ)
%   obs: observation vector [Nx1] (for example SN, data is first combined
%                               for each observation variable, then
%                               corrected)
% VARARGIN
% 'subset',indx: Take only subset of the data
% 'fig',0/1    : Use this variable as a covariate
% 'sep'        : Seperation variable 
% OUTPUTS:
%   yr: Corrected values of the y-variable. These are the values of the dependent variable.
%        assuming that the covariate was exactly at the mean value -
%        ANCOVA is IN ESSENCE an ANOVA on these values with the difference
%        that the error df are adjusted for extra estimation
%  The algorithm first gets mean values for the group (i), seperation (j),
%  and observation (k). 
% 
% IN essence what the alogorithm is doing, is for each seperator j, is does
% a normal ANOCOVA correction for differences in the covariate between the
% groups (and between observations): 
% y_i,j,k = b * (c_i,j,k - mean(c_j)) + a_i,j + noise 
% y_corrected = y_i,j,k - b *  (c_i,j,k - mean(c_j))
% 
% This amounts to the same thing as running an ANCOVA sperately for each
% seperator, EXCEPT that the b is forced to have the same value across
% seperators. 
% In essence, the seperator is like a group variable - but differences in
% the covariate between seperators will not be removed. 
% 
% EXAMPLE: You have a study with different subjects, doing different
% sequences (8 in total) with different sequence types (4 trained vs.
% 4 untrained) 
% You want to remove possible PRETEST difference between the 8 sequences 
% assigned to the two sequence types between different subjects,
% but you do NOT want to remove inter-subject differences. 
% 
% Then you would get corrected values by calling: 
% MTcorr = covCorr(MT_post,MT_pre,seqType,sequence,'sep',SN);
% 
% If you also want to remove intersubject differences between certain
% groups of subjects, you would do a 2-stage procedure
% MTcorr = covCorr(MT_post,MT_pre,group,SN);  % removes inter-subejct
%                                               difference 
% MTcorr2 = covCorr(MTcorr,MT_pre,seqType,sequence,'sep',[SN hand]);
% ---------------------------------------------------------------
% 
% j.diedrichsen@ucl.ac.uk

subset=[];
split=[]; % To be implemented!!!! 
sep=[];   % Seperate correction for all values of the variable: but same slope! 
fig=0;
vararginoptions(varargin,{'subset','fig','split','sep'});

if (isempty(sep))
    sep=ones(size(y,1),1);
end; 

if (~isempty(subset))
    y=y(subset,:);
    X=X(subset,:);
    c=c(subset,:);
    obs=obs(subset,:); 
end;

[N,~]=size(X);

% Make unique classes out of the x and data points 
[class,~,x]=unique(X,'rows');       % Group variable 
[class,~,s]=unique(sep,'rows');     % Seperation variable    
[class,~,p]=unique(obs,'rows');     % Observation variable 

% Get the mean of the dependent variable and covariate for each combination
% of the independent variable, the observation variable, and seperation
% variable 
[Yn,Xn]=pivottable([x s p],[],y,'nanmean');
[Cn,Xn]=pivottable([x s p],[],c,'nanmean');

% Make the design matrix 
xX=indicatorMatrix('hierarchicalI',[Xn(:,2) Xn(:,1)]); 

% Now remove the effect of the seperate classes from the mean of the
% covariate (in general, this is only the mean)
xS=indicatorMatrix('identity',Xn(:,2)); 

bC=inv(xS'*xS)*xS'*Cn;
C=Cn-xS*bC;
X=[xX C]; 
b=pinv(X)*Yn;
b

% Now generate the corrected values: 
for i=1:size(Xn,1)
    a=findrow([x s p],Xn(i,:));
    cm(a,1)=C(i,1);   
end;

yr=y-cm*b(end);

cm 

% Plot covariate Figure if requested
if (fig==1)
    color={[0 0 0],[1 0 0],[0 0 1],[0 0 0],[1 0 0],[0 0 1]};
    scatterplot(Cn,Yn,'split',Xn(:,1:2),'leg','auto');
    [classes,~,ci]=unique(Xn(:,1:2),'rows');
    for i=1:size(classes,1)  % Loop over the classes / seperators 
        j=find(ci==i); 
        x0=[min(Cn(j,:)) max(Cn(j,:))];
        X0=[xX(j(1),:) min(C(j,:));xX(j(1),:) max(C(j,:))];
        yp=X0*b;
        h=line(x0',yp);
        set(h,'Color',color{mod(i-1,6)+1});
    end;
end;
