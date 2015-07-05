function varargout=mixed_model(what,varargin);
% function varargout=mixed_model(what,random,{fixed1,'type',randominteract},...);
%
% Multi-utility function for a mixed linear model
% y=Xb + Zu + e
%
% Functions for generation of X and Z matrix (factorial design),
% estimation, testing and prediction
% CASES: 
% 'make_repeatedMeasures': 
%         Makes a X and Z matrix + the X and Z components
%         for a repeated measures design (usually unbalanced) 
%         INPUT: 
%               random: effects (like subject number)
%               fixed: effect {variable,'type',randominteract}
%                      variable: numbers for fixed effect 
%                      type can be: 'identity': full encoding 
%                                   'reduced': reduced encoding 
%                      randominteract:whether to include interaction with random factor
%         OUTPUT: Model structure
%  'estimate_EM'
%         Estimates the hyperparameters and parameters using EM 
%         INPUT: y: Nx1 data 
%         OUTPUT: Estimated model structure
%  'estimate_reml'
%         Estimates the hyperparameters and parameters using
%         Newton-Raphson
%         INPUT: y: Nx1 data 
%         OUTPUT: Estimated model structure
%  'meanResponse'
%         Estimates the mean response 
%         INPUT: FF: MxQ values of M points for the Q fixed factors 
%         OUTPUT: 
%                 m: Expected value of mean response 
%                 varm: variability (uncertainty) of mean response 
%  'predict'
%         predicts values for some subject with prediction uncertainty
%         INPUT: 
%               rf: Mx1 random effects 
%               FF: MxQ values of the Q fixed factors 
%         OUTPUT: 
%               m: Expected value of mean response 
%               varm: variability (uncertainty) of mean response 
%              
%         mixed_model('make_repeatedMeasures',T.SN,{T.fixedFactor,'indidicator',1},...)
%         first argument is the random factor
%  'ANOVA' 
%         run the anova of the fixed factors 
switch (what)
    case 'make_repeatedMeasures'              % Generates repeated measures design with on random factor
        rF=varargin{1};                      % Random factor (SN or similar)
        row=size(rF,1);
        
        % Extract fixed factors and options 
        FF={}; 
        options={}; 
        for i=2:length(varargin) 
            if iscell(varargin{i})
                FF{end+1}=varargin{i}; 
            else 
                options{end+1}=varargin{i}; 
            end; 
        end; 
        
        % Build design matrices and store the parcellation into factors
        T.X=[];
        T.Z=[];
        
        % First fixed factor is the intercept
        T.fixedFactor(1).name='intercept';
        T.fixedFactor(1).X=ones(row,1);
        T.fixedFactor(1).cat=1;
        T.fixedFactor(1).cols=1;
        T.fixedFactor(1).coding='intercept'; 
        T.fixedFactor(1).randInter=0;               % No random interaction 
        T.X=T.fixedFactor(1).X;
        
        % First random factor is the subject's main effect
        [T.randomFactor(1).Z,T.randomFactor(1).cat]=indicatorMatrix('identity',rF);   % Random effects: Subject
        T.randomFactor(1).name='subject';
        T.Z=[T.randomFactor(1).Z];
        T.randomFactor(1).cols=[1:size(T.Z,2)];
        
        % Loop over the number of fixed Factors 
        j=1;        
        for i=1:length(FF)
            T.fixedFactor(i+1).name=sprintf('factor%d',i);
            [T.fixedFactor(i+1).X,T.fixedFactor(i+1).cat] = indicatorMatrix(FF{i}{2},FF{i}{1}); % Paretic hand main effect
            T.fixedFactor(i+1).coding = FF{i}{2}; 
            if (FF{i}{3}==1)                                    % include interaction with random factor
                j=j+1;
                T.fixedFactor(i+1).randInter=j;
                T.randomFactor(j).name=sprintf('factor%d*subject',i);
                for n=1:row
                    T.randomFactor(j).Z(n,:) = kron(T.fixedFactor(i+1).X(n,:),T.randomFactor(1).Z(n,:));
                    T.randomFactor(j).cat    = [T.fixedFactor(i+1).cat T.randomFactor(1).cat];
                end;
                col1=size(T.Z,2);
                T.Z=[T.Z T.randomFactor(j).Z];
                T.randomFactor(j).cols=[col1+1:size(T.Z,2)];
            else 
                T.fixedFactor(i+1).randInter=0;
            end;
            col1=size(T.X,2);
            T.X=[T.X T.fixedFactor(i+1).X];
            T.fixedFactor(i+1).cols=[col1+1:size(T.X,2)];
        end;
        
        % Now build the components of G, the variance-covariance Matrix of u
        T.Q=size(T.Z,2);            % Number of random effects
        k=0;
        for i=1:length(T.randomFactor)
            q=size(T.randomFactor(i).Z,2);
            T.Gc{i}=blockdiag(zeros(k,k),eye(q),zeros(T.Q-q-k,T.Q-q-k));
            k=k+q;
        end;
        varargout={T};
    case 'estimate_EM'                 % Estimates the coefficicents using EM
        T=varargin{1};
        y=varargin{2};
        [t,q,l,n]=mixed_model_EM('EM',y,T.X,T.Z,'Gc',T.Gc,'Gstructure','arbitrary');
        % Enter data and estimates into the model structure 
        T.y=y; 
        T.V=q.V; 
        T.W=q.W;
        T.b=q.b; 
        T.u=q.u; 
        T.h=t.h; 
        T.sigma2=t.sigma2; 
        T.G=t.G; 
        varargout={T};      
    case 'estimate_reml'                 % Estimates the coefficicents using EM
        T=varargin{1};
        y=varargin{2};
        N=size(y,1); 
        
        T.Cc={}; 
        for i=1:length(T.Gc)
            T.Cc{i}=T.Z*T.Gc{i}*T.Z';         % Put variance component in observation space 
        end; 
        T.Cc{end+1}=speye(N);                 % Add observation noise  
        
        [V,h,Ph,F,Fa,Fc] = spm_reml_sc(y*y',T.X,T.Cc,1);
        % [t,q,l,n]=mixed_model_EM('EM',y,T.X,T.Z,'Gc',T.Gc,'Gstructure','arbitrary');
        % Enter data and estimates into the model structure 
        T.y=y; 
        T.V=V; 
        T.W=inv(T.V);
        T.b=pinv(T.X'*T.W*T.X)*T.X'*T.W*T.y;        % equation (3.1)
       
                % rebuild the matrix G 
        T.G=zeros(size(T.Z,2)); 
        for i=1:length(T.Gc) 
            T.G=T.G+h(i)*T.Gc{i}; 
        end; 
        
        % Estimate current fixed effects + random effects
        r=y-T.X*T.b;                                % equation (3.5)
        T.u=T.G*T.Z'*T.W*r;                         % equation (3.4)
        T.h=h(1:end-1)'; 
        T.sigma2=h(end); 
        varargout={T}; 
    case 'meanResponse'             % Returns mean response and it's estimation uncertainty
        ff=varargin{1};
        T=varargin{2};
        
        % Now build the new X_test matrix
        rows=size(ff,1);
        X=[]; 
        for i=1:length(T.fixedFactor)
            switch(T.fixedFactor(i).coding) 
                case 'intercept' 
                    X=[X ones(rows,1)]; 
                case 'identity'
                    for j=1:length(T.fixedFactor(i).cat)
                        X(:,T.fixedFactor(i).cols(j))=T.fixedFactor(i).cat(j)==ff(:,i-1);
                    end; 
                    X(:,T.fixedFactor(i).cols)=indicatorMatrix('identity',ff(:,i-1));
                case {'reduced','reduced_p'}
                    for j=1:length(T.fixedFactor(i).cat)-1
                        X(:,T.fixedFactor(i).cols(j))=T.fixedFactor(i).cat(j)==ff(:,i-1);
                    end; 
                    X(T.fixedFactor(i).cat(end)==ff(:,i-1),T.fixedFactor(i).cols)=-1;
                otherwise 
                    error('unknown coding type'); 
            end; 
        end; 
        yp=X*T.b;
        yvar=X*inv(T.X'*T.W*T.X)*X';
        varargout={yp,diag(yvar),yvar,X};
    case 'ANOVA' 
        % this is to be considered with caution - I am using simply 
        % sums of squares on the estimated effects 
    case 'predict'
        RF=varargin{1}; % Random factor 
        FF=varargin{2}; % Fixed factor 
        T=varargin{3};  % Estimated model 
        
        % Now build the new Z_test matrix 
        rows=size(FF,1);
        Z=[]; 
        for j=1:length(T.randomFactor(1).cat)
            Z(:,T.randomFactor(1).cols(j))=T.randomFactor(1).cat(j)==RF;
        end; 
        
        % Now build the new X_test matrix 
        X=[];         
        for i=1:length(T.fixedFactor)
            switch(T.fixedFactor(i).coding) 
                case 'intercept' 
                    X=[X ones(rows,1)]; 
                case 'identity'
                    for j=1:length(T.fixedFactor(i).cat)
                        X(:,T.fixedFactor(i).cols(j))=T.fixedFactor(i).cat(j) == FF(:,i-1);
                    end; 
                    X(:,T.fixedFactor(i).cols)=indicatorMatrix('identity',FF(:,i-1));
                case {'reduced','reduced_p'}
                    for j=1:length(T.fixedFactor(i).cat)-1
                        X(:,T.fixedFactor(i).cols(j))=T.fixedFactor(i).cat(j) == FF(:,i-1);
                    end; 
                    X(T.fixedFactor(i).cat(end) == FF(:,i-1),T.fixedFactor(i).cols)=-1;
                otherwise 
                    error('unknown coding type'); 
            end; 
            
            % Now use the random Interaction to complete the Z matrix 
            j = T.fixedFactor(i).randInter;
            if (j>0)                % Includes random interaction 
                x=X(:,T.fixedFactor(i).cols);
                z=Z(:,T.randomFactor(1).cols);
                for k=1:size(Z,2)
                    Z(k,T.randomFactor(j).cols) = kron(x,z);
                end; 
            end; 
        end; 

        % Now calculate the predicted values and their variances 
        yp=X*T.b+Z*T.u;
        varb=inv(T.X'*T.W*T.X);                 % Variability of the b^hats 
        varu=T.G-T.G*T.Z'*T.W*T.Z*T.G;        % Posterior varaibility of u
        yvar=X*varb*X'+Z*varu*Z';
        varargout={yp,diag(yvar),yvar,X,Z};
        
end;

