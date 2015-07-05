function z = findzero(v,varargin)
% FINDZERO finds vector of zerocrossings in a velocity-vector
%  Synopsis
%  	out = findzero(v,threshold,window)
%  Description
%  findzero(v) takes a velocity vector and searches for all zerocrossings
%  If a movement stops (like in tapping, the zero-crossing is looked at as two:
%  a start and an end:
%  Column 1: Frame (float number) of zerocrossing
%      multiply by Sampledur to get ms
%  Column 2: Direction: 1: to pos velocity 2:form Plus to zero -1: to neg velocity -2: from negative to 0   
%  Default:
% Threshold is set by default to 0.0145, meaning 2 cm/s
% Window is set by deafult to 0 (so no screening)
% the window is applied to the minmal length of the movement in ms
threshold=1;
vararginoptions(varargin,{'window','threshold'});
a=sign(v);
a(abs(v)<threshold)=0;
old_a=0;old_frame=0;
z.frame=[];z.dir=[];
for s=1:length(v)
   if(abs(a(s))>0)
       if a(s)~=old_a;
          if (old_a~=0)
              x=[old_frame;s];
              y=v(x);
              z.frame(end+1,1)=interp1(y,x,0);
              z.dir(end+1,1)=a(s);
          end;
          old_a=a(s);
       end;
       old_frame=s;
   end;
end;
