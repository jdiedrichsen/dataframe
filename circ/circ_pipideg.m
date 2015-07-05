function y=circ_pipideg(y,varargin)
if ~isempty(varargin)
    centreAngle=varargin{1};
else
    centreAngle=0;
end
if length(centreAngle)>1
    for k=1:length(centreAngle)
        above(:,k)=find(y(:,k)>centreAngle(k)+180);
        below(:,k)=find(y(:,k)<centreAngle(k)-180);
    end
else
    above=find(y>centreAngle+180);
    below=find(y<centreAngle-180);
end
y(above)=y(above)-360;
y(below)=y(below)+360;
