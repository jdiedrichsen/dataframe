% Stats toolbox
% Functions for modeling and analysis of statistical data 
% Version 2.0 07/08/2009 
% Joern Diedrichsen 
% --------------------------------------------------------------
% Random numbers 
%  sample_wr           - Sample with replacement 
%  sample_wor          - Sample without replacement 
%  choose_rnd          - Draws from a multinomial random variable
% 
%  kernel_est          - One-dimensional Kernel estimate (density and function) 
%  kernel_est2D        - Two-dimensional Kernel estimate (density and function)
% Fitting and sampling fuctions 
%  EM_run              - Run Expectation maximization algorithm 
%  mcmc_sample         - Markov chain monte carlo sampling 
% Linear Models 
%  linregress          - Linear regression
%  linintercept        - Intercept of linear regression (wraper) 
%  linslope            - Slope of linear regression (wraper) 
%  linregress_ll       - logliklihood of linear regression
%  ttest               - paired, independent and one-sample t-test
%  robustmean          - Calculates the robust mean of a vector 
%  MANOVArp            - Manova for repeated Measures 
%  wilks_lambda        - Calculates Wilk's Lambda for multivariate ANOVA
% Other models 
%  softmax             - Softmax Function
%  mises_pdf           - vanMises distribution
%  gaussian_mixture    - Gaussian mixture model 
%  mises_mixture       - vanMises mixture model on sphere 
%  spectral_clustering - Spectral clustering 
%  logistic_liklihood  - Likelihood of logistic function 
%  logistic_regress    - Logistic regression implemented over IRLS
%  logistic_resp_func  - Logistic response function
%  gp_regression       - Gaussian proces regression 