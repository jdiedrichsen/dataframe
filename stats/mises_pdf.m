function p=mises_pdf(x,mu,s)
% function p=mises_pdf(x,mu,s)
% van Mises distribution pdf
% x: N*p matrix of data vectors (rows) 
% mu: K*p matrix of 
% s: 
[N,D]=size(x); 
C=s.^(D/2-1)./((2*pi).^(D/2)*besseli(D/2-1,s));
p=C*exp(s*(x*mu')); 