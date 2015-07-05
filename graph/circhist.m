function hpol=circhist(v,varargin)
% does a phase histogram between -180 and 180
% first unwrap the data
% function circhist(v,option1,option2,...)
% includes a number of variable options 
% 'numcat',x,         : set number of bins, (default 36)
% 'balls'             : Default: draws circles 
% 'polar'             : Standard polar plot
% 'line'              :  Line plot 
% 'fill'              :  Filled line plot
% 'smooth'            : Oversamples the histogram, 
%                       to make the places where it's zero to lie on the circumference
%                       kernel-smoothing still has to be programmd
% COMMENT: The Polygon is not defined well enough, so there is a problem importing to AI and 
%           one connecting line is visible.
% 'arrow',kind        1:arrow of constantlength
% 					  2:arrow of variable length, reflecting the 1-variance
% 					  0:no arrow
% 'color',c           : color of arrow and plot
% 'scale',p           : maximal percentage on the radial axis
% 			            if not given it scales the max category to max=80%
% Written December 2001, joern Diedrichsen jdiedri@socrates.berkeley.edu

% define the default constants
plotlength=1;
num_circ=20;
circ_size=plotlength/num_circ;

% defaults 
line_style = 'auto';
style='balls';
arrow=1;color='k';percent=-1;
i=1;numcat=36;
while (i<=length(varargin))
    switch varargin{i}
    case 'numcat'
        numcat=varargin{i+1};
        i=i+2;
    case {'balls','polar','line','fill','smooth'}
        style=varargin{i};
        i=i+1;
    case 'arrow'
        arrow=varargin{i+1};
        i=i+2;
    case 'color'
        color=varargin{i+1};
        i=i+2;
    case 'scale'
        percent=varargin{i+1};
        i=i+2;
    otherwise
        fprintf('Unknown Option: %s\n',varargin{i});
        return;
    end;
end;

over=find(v>180);
under=find(v<-180);
v(over)=v(over)-360;
v(under)=v(under)-360;
binwidth=360/numcat;
Edges=[-180-(binwidth/2):binwidth:180-(binwidth/2)];
BinMid=[-180:binwidth:180-binwidth]';

% count the occuances in the bins
N=histc(v,Edges);
rho=N(1:end-1);
rho(1)=rho(1)+N(end); % leftovers
theta=BinMid./180*pi;

% transform data to Cartesian coordinates.
% collect the number of circles
theta=-theta+pi/2;
tot_count=sum(rho);
if percent==-1;
   percent=max(rho./tot_count*130);
end;
rhoScale=tot_count/100*percent;
one_circ=rhoScale/num_circ;
barh=round(rho./one_circ); 

if(strcmp(style,'polar'));
    polar(theta,rho);
    return;
end;

% now calculate the arrow in length and angle

cmean=circmean(v./180*pi);
cmean=-cmean+pi/2; % align with general zero-up +clockwise
if (arrow==1)
	arrowlength=0.6;
end;
if (arrow==2)
	arrowlength=(1-circvar(v/180*pi))*.8;
end;   
arrowhead=arrowlength*.83;

% get hold state
cax = newplot;
next = lower(get(cax,'NextPlot'));
hold_state = ishold;

% get x-axis text color so grid is in same color
tc = get(cax,'xcolor');
ls = get(cax,'gridlinestyle');

% Hold on to current Text defaults, reset them to the
% Axes' font attributes so tick marks use them.
fAngle  = get(cax, 'DefaultTextFontAngle');
fName   = get(cax, 'DefaultTextFontName');
fSize   = get(cax, 'DefaultTextFontSize');
fWeight = get(cax, 'DefaultTextFontWeight');
fUnits  = get(cax, 'DefaultTextUnits');
set(cax, 'DefaultTextFontAngle',  get(cax, 'FontAngle'), ...
    'DefaultTextFontName',   get(cax, 'FontName'), ...
    'DefaultTextFontSize',   get(cax, 'FontSize'), ...
    'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
    'DefaultTextUnits','data')

% only do grids if hold is off
if ~hold_state

% make a radial grid
    hold on;
    maxrho = 1+plotlength;
    
    hhh=plot([-maxrho -maxrho maxrho maxrho],[-maxrho maxrho maxrho -maxrho]);
    set(gca,'dataaspectratio',[1 1 1],'plotboxaspectratiomode','auto')
    v1 = [get(cax,'xlim') get(cax,'ylim')];
    ticks = sum(get(cax,'ytick')>=0);
    delete(hhh);
% check radial limits and ticks
    rmin = 0; rmax = v1(4); rticks = max(ticks-1,2);
    if rticks > 5   % see if we can reduce the number
        if rem(rticks,2) == 0
            rticks = rticks/2;
        elseif rem(rticks,3) == 0
            rticks = rticks/3;
        end
    end

% define a circle
    th = -pi:pi/50:pi;
    th =-th+pi/2;
    xunit = cos(th);
    yunit = sin(th);
% now really force points on x/y axes to lie on them exactly
    inds = 1:(length(th)-1)/4:length(th);
    yunit(inds(2:2:4)) = zeros(2,1);
    xunit(inds(1:2:5)) = zeros(3,1);
% plot background if necessary
    if ~isstr(get(cax,'color')),
       patch('xdata',xunit*rmax,'ydata',yunit*rmax, ...
             'edgecolor',tc,'facecolor',get(gca,'color'),...
             'handlevisibility','off');
    end

% draw radial circles
    c82 = cos(82*pi/180);
    s82 = sin(82*pi/180);
    for (i=1:plotlength:1+plotlength)
    	hhh = plot(xunit*i,yunit*i,ls,'color',tc,'linewidth',1,...
                   'handlevisibility','off');
                
    	set(hhh,'linestyle','-') % Make outer circle solid
	 end;
% plot spokes
    th_sp = [4*pi/12:-2*pi/12:-pi/2]; % start up and go around
    cst = cos(th_sp); snt = sin(th_sp);
    cs = [-cst; cst];
    sn = [-snt; snt];
    %plot(rmax*cs,rmax*sn,ls,'color',tc,'linewidth',1,...
    %     'handlevisibility','off')

% annotate spokes in degrees
    rt = 0.85;%1.1*rmax;
    for i = 1:length(th_sp)
        text(rt*cst(i),rt*snt(i),int2str(i*30),...
             'horizontalalignment','center',...
             'handlevisibility','off');
        if i == length(th_sp)
            loc = int2str(0);
        else
            loc = int2str(i*30-180);
        end
        text(-rt*cst(i),-rt*snt(i),loc,'horizontalalignment','center',...
             'handlevisibility','off')
    end

% set view to 2-D
    view(2);
% set axis limits
    axis(rmax*[-1 1 -1.15 1.15]);
end

% Reset defaults.
set(cax, 'DefaultTextFontAngle', fAngle , ...
    'DefaultTextFontName',   fName , ...
    'DefaultTextFontSize',   fSize, ...
    'DefaultTextFontWeight', fWeight, ...
    'DefaultTextUnits',fUnits );

% calculate circles
if(strcmp(style,'balls'))
    xx=[];
    yy=[];
    for (bar=1:length(theta))
        if(barh(bar)>0)
            for(circ=1:barh(bar))
                radi=1+circ_size*circ-circ_size/2;
                xx(end+1)=radi*cos(theta(bar));
                yy(end+1)=radi*sin(theta(bar));
            end;
        end;
    end;
    % draw the circles
    q=[];
    for (circ=1:length(xx))
        posi=[xx(circ)-circ_size/2 yy(circ)-circ_size/2 circ_size circ_size];
        q(end+1)=rectangle('Position',posi,'Curvature',[1 1],'EdgeColor',color);
    end;
end;

rho(end+1)=rho(1);
theta(end+1)=-pi/2;
% draw line 
% plot data on top of grid
if (strcmp(style,'smooth'))
    rho=interp1(theta,rho,th','linear');
    theta=th';
end;    
if(strcmp(style,'line') | strcmp(style,'fill') | strcmp(style,'smooth'))
    xx = (1+rho/rhoScale).*cos(theta);
    yy = (1+rho/rhoScale).*sin(theta);
    q = plot(xx,yy,color);
end;
if(strcmp(style,'fill')| strcmp(style,'smooth'))
    patch([xx;xunit'],[yy;yunit'],color);
end;



% draw the mean vector
if arrow>0
	arrow=line([0 arrowlength*cos(cmean)],[0 arrowlength*sin(cmean)]);
	set(arrow,'Color',color);
	% arrowhead
	p=patch([arrowlength*cos(cmean) arrowhead*cos(cmean-0.1) arrowhead*cos(cmean+0.1)],[arrowlength*sin(cmean) arrowhead*sin(cmean-0.1) arrowhead*sin(cmean+0.1)],color);
	set(p,'EdgeColor',color);
end;

if nargout > 0
    hpol = q;
end
if ~hold_state
    set(gca,'dataaspectratio',[1 1 1]), axis off; set(cax,'NextPlot',next);
end
set(get(gca,'xlabel'),'visible','on')
set(get(gca,'ylabel'),'visible','on')
