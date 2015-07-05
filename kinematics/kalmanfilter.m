function [x,yp,P,K,xm,Pm]=kalmanfilter(y,M);
% Implentation of Kalman filter 
% y=oxT observables 
% M=structure: 
%  M.A:transtion 
%  M.C:Observation 
%  M.Q:state Noise 
%  M.R:Observation noise 
%  M.x0: guess in beginning 
%  M.P0: Uncertainty in beginning 

Pm=M.P0;
xm=M.x0;
for n=1:size(y,2)
    % Deal with time-dependent stuff 
    try 
        C=M.C(:,:,n); 
    catch 
        C=M.C; 
    end; 
    
    % Predict 
    yp(:,n)=C*xm; 
    K(:,:,n)=Pm*C' * inv(C*Pm*C'+M.R);
    
    % Measurement update 
    if ~any(isnan(y(:,n)))
        x(:,n)=xm+K(:,:,n)*(y(:,n)-C*xm);
        P(:,:,n)=Pm-K(:,:,n)*C*Pm;
    else 
        x(:,n)=xm; 
        P(:,:,n)=Pm;
    end; 
    
    % Time update 
    xm=M.A*x(:,n);
    Pm=M.A*P(:,:,n)*M.A'+M.Q;
end
