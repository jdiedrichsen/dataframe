% Graph toolbox for custom graphs from raw data
%       author: Joern Diedrichsen
%       email: j.diedrichsen@bangor.ac.uk
% V.2.1 
% --------------------------------------------------------------------
% 1. Single plot-operations / Utility functions 
%   drawline             - draws vertical or horizontal reference lines 
%   drawpatch            - draws a patch of certain shape
%   confidelps           - draws Confidence-ellipse over the x,y sample
%   makexlabels          - Makes labels for the x-axis of Grouped graphs
%   makeglabels          - Makes group labels for boxplots, etc.
%   errorbars            - Adds errorbars to bargraphs
% 2. Standard plots from raw data, many formating options 
%   barplot              - Barplots from raw data
%   lineplot             - Lineplots from raw data 
%   myboxplot            - Boxplots with formating options 
%   xyplot               - XY-plot with error bars in both directions
%   scatterplot          - Scatterplot with formating/splitting options 
%   trialscatter         - Scatter of a time series of experimental trials with block boundaries 
%   traj_plot            - Plots trajectories in 2D
%   traceplot            - Plotting of multiple time series with formating options 
%   scattermatrix        - Matrix of scatterplots to access dependency of variables 
%   plotshade            - Plots times series with +-SD as transparent underlay
%   hist_double          - Overlays the histograms for two variables
%   hist_pivot           - Makes M*N subplots with histograms, depending on categorial variabels
%   histdistn_plot       - Overlays a histogram with a distribution function (Scaled) 
%   circhist             - Circular histogram (see circ toolbox)
% 3. Multivariate surface plots 
%   hist2d               - Two dimensional histogram presented as a image
%   contour_pivot        - Makes a contour plot from a pivot-table
%   contour_kernel       - Makes a contour plot from a kernel estimate (density or function)
% 4. Formating 
%   figure_scalesubplots  - Scales all subplots to the same axis-limits 
%   figure_scalexsubplots - Scales all subplots to the same axis-limits 
%   figure_scaleysubplots - Scales all subplots to the same axis-limits 
%   wysiwyg               - Present Figure on Screen as it is printed 
