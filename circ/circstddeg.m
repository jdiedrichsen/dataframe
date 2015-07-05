function cstd=circstddeg(ph)
% Synopsis
% cstd=circstd(ph)
% Desription:
% cstd is the circular standarddeviation of the phase data in 
% in degrees (input also in degrees)
cstd=sqrt(-2*log(1-circvar(ph./180*pi)))/(2*pi)*360;