function cm=circmeandeg(ph)
% Synopsis
% cm=circmean(ph)
% Desription:
% cm is the circular mean or mean direction of the phase data in 
% ph (angular data) in degrees ignores NaN
cm=circmean(ph./180*pi)/pi*180;