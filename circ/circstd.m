function cstd=circstd(ph)
% Synopsis
% cstd=circstd(ph)
% Desription:
% cstd is the circular standarddeviation of the phase data in 
% ph (angular data in radians) in radians
cstd=sqrt(-2*log(1-circvar(ph)));