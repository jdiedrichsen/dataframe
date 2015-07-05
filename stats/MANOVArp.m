function T = MANOVArp(R,F,y,varargin)
% One factorial repeated measures MANOVA
% Only for balanced designs
% function Table = MANOVArp(R,F,y)
% INPUT: 
%   R: Random factor 
%   F: Fixed factor(s)
%   y: N*P data series 
% OUTPUT 
%   Result Table 

subset=[]; 
vararginoptions(varargin,{'subset'}); 

if (~isempty(subset))
    R=R(subset,:); 
    F=F(subset,:); 
    y=y(subset,:); 
end; 



% 1. Compute sum of squares and predicted effects 
% a. Mean 
T=[];
yp1=repmat(mean(y),size(y,1),1); 
D1=yp1'*yp1; 
[D2,yp2,v2]=sumofsquares(R,y); % b. Random effects 
[D3,yp3,v3]=sumofsquares(F,y); % c. Fixed effects 
[D4,yp4,v4]=sumofsquares([R F],y); % d. Interaction
D5=y'*y;                    % e. Total 

n=size(y,1); 
p=size(y,2); 
if n <= p,
   error('Warning: requires that sample-size (n) must be greater than the number of variables (p).');
   return;
else  
      fprintf('-----------------------------------------------------------------------------\n');
      disp(' Effect     tr(SS)     df      lambda    chi2       df       P           ')
      fprintf('-----------------------------------------------------------------------------\n');
      S=evaluate('Constant',D1,D2-D1,1,v2-1);S.effect=1;T=addstruct(T,S);
      S=evaluate('Random',D2-D1,D5-D4,v2-1,n-v4);S.effect=2;T=addstruct(T,S);
      S=evaluate('Fixed',D3-D1,D4-D3-D2+D1,v3-1,v4-v3-v2+1);S.effect=3;T=addstruct(T,S);
      S=evaluate('Interact',D4-D3-D2+D1,D5-D4,v4-v3-v2+1,n-v4);S.effect=4;T=addstruct(T,S);
      S=evaluate('Error',D5-D4,[],n-v4,[]);S.effect=5;T=addstruct(T,S);
      S=evaluate('Total',D5,[],n,[]);S.effect=6;T=addstruct(T,S);
end; 

function T=evaluate(name,QT,QE,dfT,dfE);     % Evaluates a hypothesis term
    if isempty(dfE) | dfE==0
        T.lambda=NaN; T.chi2stats=NaN;T.df=NaN;T.p=NaN;
        fprintf('%10s%8.2f%6.0f\n',name,trace(QT),dfT);
    else 
        [T.lambda,T.chi2stats,T.df,T.p]=wilks_lambda(QT,QE,dfT,dfE); 
        fprintf('%10s%8.2f%6.0f%10.2f%10.2f%6.0f%10.3f\n',name,trace(QT),dfT,T.lambda,T.chi2stats,T.df,T.p);
    end;

function [D,yp,v]=sumofsquares(X,y); 
r=unique(X,'rows'); 
for i=1:size(r,1)
    indx=findrow(X,r(i,:));
    yp(indx,:)=repmat(mean(y(indx,:),1),length(indx),1); 
end; 
D=yp'*yp; 
v=size(r,1);


