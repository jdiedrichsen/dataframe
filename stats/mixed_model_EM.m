function varargout=mixed_model(what,varargin);
% function [theta,q,l,n]=mixed_model('EM',y,X,Z,'Gc',Gc);
% Estimates the fixed and random model coefficients
% for the following mixed model in compact Notation
%
% y_n = X b + Z u_n + e
% K: numbers of observations per experimental unit
% N: numbers of experimental units
% P: number of fixed effects
% Q: number of random effects
%
% COMPACT NOTATION
% y: K x N observations
% X: K x P fixed effects matrix
% Z: K x Q random effects matrix
%
% VARARGINS:
%   'num_iter': Number of iterations
%   'h': starting values of hyper-parameters
%   'Gstructure':
%       'iid': One hyperparameter for iid distributed U's
%       'diagonal': independent, but each u with own variance
%       'diagonal_constraint': independent, but u's are grouped by Gc's
%                              into groups with same variance
%       'full': full QxQ matrix is estimated
%       'arbitrary'         G is modeled as G=sum_i(h_i * Gc{i})
%                           because no closed form, M-step is iterative
%   'Gc':                   Components of variance covariance structure of G
%   'method','ML','REML':   Maximum-likelihood or restricted ML estimation
%   'TolH':                 Tolerance of the hyperparameters max(abs(h-h'))
% OUTPUT:
%   b: Px1 estimate of fixed effects
%   u: Qx1 estimate of random effects
%   h: H+1x1 estimate of hyperparameters
%   G: QxQ estimate of varaince-covariance matrix of random effects
%   l: likelihood
% Implementation as outlined in Laird & Lange & Stram (1987)

persistent c;

switch (what)
    case 'EM'
        y=varargin{1};
        X=varargin{2};
        Z=varargin{3};
        num_iter=600;
        method='ML';        % Method for parameter estimation: ML / REML
        Gstructure='diagonal';  % Structure of matrix G: full / diagonal / diagonalconstrained
        Gc=[];
        h=1;
        TolH=0.0001;              % Tolerance on hyperparameters
        TolL=0.000001;            % Tolerance on Likelihood
        numiter=50;
        
        vararginoptions({varargin{4:end}},{'h','num_iter','Gstructure','method','Gc','TolH','TolL'});
        theta.method=method;
        theta.Gc=Gc;
        
        theta.Gstructure=Gstructure;
        theta.h=h(1:end-1);
        theta.sigma2=h(end);
        mixed_model_EM('init',y,X,Z);
        theta=mixed_model_EM('theta0',theta);
        
        % Number of hyperparameters and starting values
        lA=[inf inf inf inf inf];  % Forecasted max
        l=[-inf -inf]';
        n=1;
        diffL=inf;
        % Iterate
        while (n<num_iter && diffL>TolL)
            theta=mixed_model_EM('makeG',theta);
            [q,l(n)]=mixed_model_EM('estep',theta);
            [theta]=mixed_model_EM('mstep',q,theta);
            % prepare next iteration
            if (n>10)
                Rdl(n)=(l(n)-l(n-1))/(l(n-1)-l(n-2));   % Ratio of slowing down
                lA(n)=l(n-1)+1./(1-Rdl(n))*(l(n)-l(n-1));       % Predicted max
                diffL=lA(n)-l(n);
            end;
            n=n+1;
        end;
        q.res=q.r-Z*q.u;
        varargout={theta,q,l,n};
    case 'init'
        c.y=varargin{1};
        c.X=varargin{2};
        c.Z=varargin{3};
        [c.K,c.N]=size(c.y);
        [c.K,c.P]=size(c.X);
        [c.K,c.Q]=size(c.Z);
    case 'theta0'
        t=varargin{1};
        switch (t.Gstructure)
            case 'full'
                t.G=eye(c.Q);
                t.h=[t.G(:)];
                t.H=c.Q*c.Q;
            case 'iid'
                t.H=1;
            case 'diagonal'
                t.H=c.Q;
                for i=1:c.Q
                    t.Gc{i}=i;
                end;
            case 'diagonalconstrained'
                t.H=length(t.Gc);
            case 'arbitrary'
                t.H=length(t.Gc);
        end;
        if (isempty(t.h))
            t.h=ones(t.H,1);
        end;
        if (~isfield(t,'sigma2'))
            t.sigma2=1;
        end;
        varargout={t};
        
        % -------------------------------------------
    case 'theta2vec'
        % Build G-matrix from current hyperparameters
        t=varargin{1};
        vec=[t.h;t.sigma];
        varargout={vec};
        
        % -------------------------------------------
    case 'vec2theta'
        % Build G-matrix from current hyperparameters
        vec=varargin{1};
        t=varargin{2};
        t.h=vec(1:end-1);
        t.sigma2=vec(end);
        t=mixed_model_EM('makeG',t);
        vararout={t};
        
        % -------------------------------------------
    case 'makeG'
        % Build G-matrix from current hyperparameters
        t=varargin{1};
        switch (t.Gstructure)
            case 'iid'
                t.G=eye(c.Q)*t.h(1);
            case 'diagonal'
                t.G=diag(t.h);
            case 'diagonalconstrained'
                t.G=zeros(t.Q);
                for i=1:t.H
                    for j=1:length(t.Gc{i})
                        G(t.Gc{i}(j),t.Gc{i}(j))=t.h(i);
                    end;
                end;
            case 'full'
                t.G=reshape(t.h,c.Q,c.Q);                   % unconstrained, open G matrix
            case 'arbitrary'
                t.G=zeros(c.Q);
                for i=1:length(t.Gc)
                    t.G=t.G+t.Gc{i}*t.h(i);
                end;
        end;
        varargout={t};
        
        % -------------------------------------------
    case 'estep'
        % Estep
        t=varargin{1};
        % Make estimate of V and W, equations (3.2-3)
        q.V=t.sigma2*eye(c.K)+c.Z*t.G*c.Z';
        q.W=inv(q.V);
        
        % Estimate current fixed effects + random effects
        q.b=pinv(c.X'*q.W*c.X*c.N)*sum(c.X'*q.W*c.y,2); % equation (3.1)
        q.r=c.y-repmat(c.X*q.b,1,c.N); % equation (3.5)
        q.u=t.G*c.Z'*q.W*q.r;  % equation (3.4)
        q.rr=q.r*q.r';          %
        q.res=q.r-c.Z*q.u;       % Final residuals
        
        % <u uT> sufficient statistics
        switch (t.method)
            case 'ML'
                q.uu=(q.u*q.u')/c.N+t.G*(eye(c.Q)-c.Z'*q.W*c.Z*t.G); % equation (3.7)
                l=c.N/2*log(det(q.W))-1/2*trace(q.rr*q.W);  % log-likelihood
            case 'REML'
                q.P=q.W*(eye(c.K)-c.X*inv(c.N*c.X'*q.W*c.X)*c.X'*q.W); % equation (3.10)
                q.uu=(q.u*q.u')/c.N+t.G*(eye(c.Q)-c.Z'*q.P*c.Z*t.G); % replacing W by P, equation (3.9)
                l=c.N/2*log(det(q.W))-1/2*trace(q.rr*q.W)-1/2*log(det(c.N*c.X'*q.W*c.X));
        end;
        varargout={q,l};
        
        
        % -------------------------------------------
    case 'mstep'
        % M-step: update the variance parameters
        q=varargin{1};
        t=varargin{2};
        switch (t.Gstructure)
            case 'iid'
                t.h=mean(diag(q.uu));
            case 'diagonal'
                t.h=diag(q.uu); % Diagonal elements of uu
            case 'diagonalconstrained'
                for i=1:t.H
                    m=t.Gc{i};
                    t.h(i,1)=sum(diag(q.uu(m,m)))/length(m);
                end;
            case 'full'
                t.h(:,1)=q.uu(:);
            case 'arbitrary' % using fminsearch to find maximum
                % t.h=fminsearch(@(x)mixed_model_EMm('llscore',x,q,t),t.h);
                for i=1:t.H
                    t.h(i,1)=sum(sum(t.Gc{i}.*q.uu))./sum(sum(t.Gc{i}));
                end;
                
        end;
        switch(t.method)            
            case 'ML'  % equation (3.6)
                t.sigma2=sum(sum(q.res.*q.res))/(c.N*c.K)+t.sigma2*trace(eye(c.K)-t.sigma2*q.W)/c.K;  % Devision by K on last term, because we don't sum over observations
            case 'REML'  % equation (3.7)
                t.sigma2=sum(sum(q.res.*q.res))/(c.N*c.K)+t.sigma2*trace(eye(c.K)-t.sigma2*q.P)/c.K;
        end;
        varargout={t};
        % -------------------------------------------
    case 'llscore'
        % M-step: update the variance parameters
        x=varargin{1};
        q=varargin{2};
        t=varargin{3};
        
        t.G=zeros(size(t.Gc{1}));
        for i=1:length(t.Gc)
            t.G=t.G+t.Gc{i}*x(i);
        end;
        if (rcond(t.G)<1e-10)
            l=inf;
            varargout={l};
            return;
        end;
        Gi=inv(t.G);
        % l=-(N/2*log(det(Gi))-N/2*trace(uu*Gi));
        l=-(c.N/2*log(det(Gi))-c.N/2*(sum(sum(q.uu.*Gi',2))));
        varargout={l};
end;

