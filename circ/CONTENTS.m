% Functions for the analysis of circular data 
% See Fisher, N. I., Statistical analysis of circular data 
% Joern Diedrichsen 
% Version 1.0 09/13/05 
% --------------------------------------------------
%  circmean         - mean of circular data (radians)
%  circmeandeg      - mean of circluar data (degrees)
%  circvar          - variance of circluar data
%  circstd          - SD of circluar data (radians)
%  circstddeg       - SD of circluar data (degrees)
%  circvelocity     - First Derivate (adjusts for wrapping, radians) 
%  circvelocitydeg  - First Derivate (adjusts for wrapping, degrees) 
%  diffang	        - subtracts two angles and keeps result in [-180,180]
%  unwrapdeg        - Unwrap for measures in degrees
%  circ_pipi        - keeps angles between -pi and pi
%  circ_cosinemodel - Circular distributionfunction
%  circ_cosinemodelcost - cost for fitting on circular data 