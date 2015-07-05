function V=circvelocitydeg(Y,sigma)
V=circvelocity(Y/360*(2*pi),sigma)/(2*pi)*360;
