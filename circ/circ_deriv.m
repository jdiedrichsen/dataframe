function dy=circ_deriv(y)
dy=y(2:end)-y(1:end-1);
above=find(dy>pi);
below=find(dy<-pi);
dy(above)=dy(above)-2*pi;
dy(below)=dy(below)+2*pi;
