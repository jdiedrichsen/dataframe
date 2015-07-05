function T = MANOVA1(F,y)
% One factorial MANOVA
% Only for balanced designs
% function Table = MANOVA1(F,y)
% INPUT: 
%   F: Fixed factor
%   y: N*P data series 
% OUTPUT 
%   Result Table 

% 1. Compute sum of squares and predicted effects 
% a. Mean 
T=[];
yp1=repmat(mean(y),size(y,1),1); 
D1=yp1'*yp1; 
[D2,yp2,v2]=sumofsquares(F,y); % c. Fixed effects 
DT=y'*y;                    % e. Total 

n=size(y,1); 
p=size(y,2); 
if n <= p,
   error('Warning: requires that sample-size (n) must be greater than the number of variables (p).');
   return;
else  
      fprintf('-----------------------------------------------------------------------------\n');
      disp(' Effect     tr(SS)     df      lambda    chi2       df       P           ')
      fprintf('-----------------------------------------------------------------------------\n');
      S=evaluate('Constant',D1,DT-D2,1,n-v2);S.effect=1;T=addstruct(T,S);
      S=evaluate('Effect',D2-D1,DT-D2,v2-1,n-v2);S.effect=2;T=addstruct(T,S);
      S=evaluate('Error',DT-D2,[],n-v2,[]);S.effect=5;T=addstruct(T,S);
      S=evaluate('Total',DT,[],n,[]);S.effect=6;T=addstruct(T,S);
end; 

function T=evaluate(name,QT,QE,dfT,dfE);     % Evaluates a hypothesis term
    if isempty(dfE) | dfE==0
        T.lambda=NaN; T.chi2stats=NaN;T.df=NaN;T.p=NaN;
        fprintf('%10s%8.2f%6.0f\n',name,trace(QT),dfT);
    else 
        [T.lambda,T.chi2stats,T.df,T.p]=wilks_lambda(QT,QE,dfT,dfE); 
        fprintf('%10s%8.2f%6.0f%10.2f%10.2f%6.0f%10.3f\n',name,trace(QT),dfT,T.lambda,T.chi2stats,T.df,T.p);
    end;
    T.detQT=det(QT);
    T.detQE=det(QE);
    
function [D,yp,v]=sumofsquares(X,y); 
r=unique(X,'rows'); 
for i=1:size(r,1)
    indx=findrow(X,r(i,:));
    yp(indx,:)=repmat(mean(y(indx,:),1),length(indx),1); 
end; 
D=yp'*yp; 
v=size(r,1);


