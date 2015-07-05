function varargout=mixed_model_example
% Example of a unbalanced mixed model 
% This shows how to estimate and plot fixed effects and 
% To make predictions about future data 

% The exmaple is data from 4 subjects at 3 measurement points. 
% One subejct (S3) is only measured at time point 2 and 3, another subject
% (S4) is only measured at measurement times 1 and 2. 
% We have only one measure for subject number 5 

T.SN   = [1 1 1 2 2 2 3 3 4 4 5 6]'; % Subejct number of observations 
T.Sess = [1 2 3 1 2 3 2 3 1 2 1 2]'; % Session number 
T.data = [1 3 5 3 6 8 1 4 6 9 5.5 0.5]'; % This is data 

T.SN = [1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6]'; 
T.Sess = [1 2 1 2 3 1 2 3 2 3 4 2 3 4 3 4]'; 
ranE = [6 5 4 3 2 1]'; 
fixE = [1 2 3 4]'; 
X1=indicatorMatrix('identity',T.SN); 
X2=indicatorMatrix('identity',T.Sess); 
T.data = X1*ranE + X2*fixE+normrnd(0,0.2,length(T.SN),1); 


% First make a simple plot of the data 
% This plot look like there is very little recovery: 
% The reason for this is that subject 3 is very bad, whereas S4 is very
% good 
figure(1); 
subplot(4,1,1); 
lineplot(T.Sess,T.data,'split',T.SN,'style_thickline'); 
set(gca,'YLim',[0 10]); 
title('Subject data'); 

subplot(4,1,2); 
lineplot(T.Sess,T.data,'style_thickline'); 
set(gca,'YLim',[0 11]); 
title('Subject data'); 

% Now generate the design matrices at setup the general mixed model: 
% No interaction of session with subject number, as this would be identical
% to the overall noise term. This would be different if we had multiple
% measures per session per subect (of the same variable) 
M=mixed_model('make_repeatedMeasures',T.SN,{T.Sess,'reduced',0});  

% Now estimate the hyperparamters of the model 
M=mixed_model('estimate_EM',M,T.data); 

% And replot the estimate of the fixed effect (recovery)
sess=[1:max(T.Sess)]'; 
[m,varm]=mixed_model('meanResponse',sess,M); 

subplot(4,1,3); 
lineplot(sess,m,'style_thickline','errorval',sqrt(varm)); 
set(gca,'YLim',[0 11]); 
title('Corrected estimate'); 

% Now do the prediction of the values for Session 2 and 3 for subject 5 
sess= [3 4]'; 
sn  = [1 1]'; 
[mp,varm]=mixed_model('predict',sn,sess,M); 
subplot(4,1,4); 

% Now plot the measured data with prediction 
lineplot([1;2;sess],[T.data(T.SN==1);mp],'style_shade','errorval',[0;0;sqrt(varm)]); 
hold on; 
plot(1,T.data(end),'r.');
hold off; 
set(gca,'YLim',[0 12]); 
title('Prediction (Subject 5)'); 

varargout={T,m}; 
