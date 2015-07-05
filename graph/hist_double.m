function hist_double(series1,series2)
% function hist_double(series1,series2)
% makes a overlay histogram of gray bars 
% overlayed with black lines 
[N,center]=hist([series1;series2],40);
hist(series1,center);
h=get(gca,'Children');
hold on;
hist(series2,center);
hold off;
h=get(gca,'Children');
set(h(2),'FaceAlpha',1);
set(h(2),'FaceColor',[0.8 0.8 0.8]);
set(h(2),'EdgeColor',[0.8 0.8 0.8]);
set(h(1),'FaceAlpha',1);
set(h(1),'EdgeColor',[0 0 0]);
set(h(1),'FaceColor',[1 1 1]);