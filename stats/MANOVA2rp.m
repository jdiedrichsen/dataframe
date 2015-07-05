function T = MANOVA2rp(R,F,y,varargin)
% Two-factorial repeated measures MANOVA
% Only for balanced designs
% function Table = MANOVArp(R,F,y)
% INPUT: 
%   R: Random factor 
%   F: Fixed factor (Nx2)
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

T=[];
yp1=repmat(mean(y),size(y,1),1); 
D1=yp1'*yp1; 
[D2,yp2,v2]=sumofsquares(R,y); % b. Random effects 
[D3a,yp3a,v3a]=sumofsquares(F(:,1),y); % c. Fixed effects 
[D3b,yp3b,v3b]=sumofsquares(F(:,2),y); % c. Fixed effects 
[D3c,yp3c,v3c]=sumofsquares(F,y); % c. Fixed effects 
[D4a,yp4a,v4a]=sumofsquares([R F(:,1)],y); % d. Interaction
[D4b,yp4b,v4b]=sumofsquares([R F(:,2)],y); % d. Interaction
[D4c,yp4c,v4c]=sumofsquares([R F],y); % d. Interaction
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
      S=evaluate('Random',D2-D1,D5-D4c,v2-1,n-v4c);S.effect=2;T=addstruct(T,S);
      S=evaluate('Fixed A',D3a-D1,D4a-D3a-D2+D1,v3a-1,v4a-v3a-v2+1);S.effect=3;T=addstruct(T,S);
      S=evaluate('Fixed B',D3b-D1,D4b-D3b-D2+D1,v3b-1,v4b-v3b-v2+1);S.effect=4;T=addstruct(T,S);
      A=D3c-D3a-D3b+D1;a=v3c-v3a-v3b+1; 
      B=D4c-D4a-D4b+D2;b=v4c-v4a-v4b+v2;
      S=evaluate('Fixed Int',A,B-A,a,b-a);S.effect=5;T=addstruct(T,S);
      % S=evaluate('Interact',D4-D3-D2+D1,D5-D4,v4-v3-v2+1,n-v4);S.effect=4;T=addstruct(T,S);
      S=evaluate('Error',D5-D4c,[],n-v4c,[]);S.effect=6;T=addstruct(T,S);
      S=evaluate('Total',D5,[],n,[]);S.effect=7;T=addstruct(T,S);
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


