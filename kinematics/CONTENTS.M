% Basic functions for the analysis of kinematic data 
% Joern Diedrichsen 
% V.1.0 09/13/05 (jdiedric@jhu.edu)
% -----------------------------------------------------------------
% 1. Calculating numerical derivatives and smoothing 
%   velocity_discr      - Numerical first derivative (with filter option)
%   acceleration_discr  - Numerical second derivative (with filter option)
%   tangvelocity        - Tangential and vector velocity
%   smooth_kernel       - Gaussian kernel smoothing (1-dim)
% 2. Landmarking, cutting and stretching 
%   findstart           - Finds start of movement, excludes false starts
%   findend             - Finds end of movement, including/excluding submovement 
%   cut                 - Cuts out a kinematic trajectory for placement in matrix 
%   lengthstandard      - Stretches kinematic data to a certain length
