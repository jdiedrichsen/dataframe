function hh = mypie(data,varargin)
%PIE    Modified Pie chart.
%   PIE(X) draws a pie plot of the data in the vector X.  The values in X
%   are normalized via X/SUM(X) to determine the area of each slice of pie.
%   If SUM(X) <= 1.0, the values in X directly specify the area of the pie
%   slices.  Only a partial pie will be drawn if SUM(X) < 1.
%
%   PIE(X,EXPLODE) is used to specify slices that should be pulled out from
%   the pie.  The vector EXPLODE must be the same size as X. The slices
%   where EXPLODE is non-zero will be pulled out.
%
%   PIE(...,LABELS) is used to label each pie slice with cell array LABELS.
%   LABELS must be the same size as X and can only contain strings.
%
%   PIE(AX,...) plots into AX instead of GCA.
%
%   H = PIE(...) returns a vector containing patch and text handles.
%
%   Example

% Parse possible Axes input
x = data(:); % Make sure it is a vector
scale = 1;
explode = [];
labels = {};
fontsize = 12;
style_bold = 0;
style_noedge = 0;
cmap = [];

vararginoptions(varargin,{'scale','explode','labels','style_bold','style_noedge','fontsize','cmap'})

% Check scale
if ((scale>1)||(scale<=0))
    scale=1;
end

% Plot options
options = {};
if style_bold
    options = {'linewidth',4};
end
if style_noedge
    options = {'edgecolor','non'};
end

% Color
if isempty(cmap)
    cmap = jet(length(x(:)));
else
    cmap = eval(sprintf('%s(length(x(:)))',cmap));
end

% Check non positive data
nonpositive = (x <= 0);
if all(nonpositive)
    error(message('mypie:NoPositiveData'));
end
if any(nonpositive)
  warning(message('mypie:NonPositiveData found, forced to zero.'));
  x(nonpositive) = 0;
end

% Get sum(x) and normalize data
xsum = sum(x);
x = x/xsum;

% Look for labels (to be updated)
for i=1:length(x)
    if x(i)<.01,
        txtlabels{i} = '< 1%';
    else
        txtlabels{i} = sprintf('%d%%',round(x(i)*100));
    end
end
if ~isempty(txtlabels) && length(x)~=length(txtlabels),
  error(message('mypie:StringLengthMismatch'));
end

% Look for explode
if isempty(explode),
   explode = zeros(size(x)); 
else
   if any(nonpositive)
     explode(nonpositive) = [];
   end
end
explode = explode(:); % Make sure it is a vector
if length(x) ~= length(explode),
  error(message('mypie:ExploreLengthMismatch'));
end

% Get axes
cax = newplot();
next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

theta0 = pi/2;
maxpts = 100;
inside = 0;
radius = 1;

h = [];
for i=1:length(x)
  n = max(1,ceil(maxpts*x(i)));
  r = [0;ones(n+1,1);0]*scale;
  theta = theta0 + [0;x(i)*(0:n)'/n;0]*2*pi;
  if inside,
    [xtext,ytext] = pol2cart(theta0 + x(i)*pi,.5);
  else
    [xtext,ytext] = pol2cart(theta0 + x(i)*pi,max(0.4,1.2*scale));    
  end
  [xx,yy] = pol2cart(theta,radius*r);
  if explode(i),
    [xexplode,yexplode] = pol2cart(theta0 + x(i)*pi,.1);
    xtext = xtext + xexplode;
    ytext = ytext + yexplode;
    xx = xx + xexplode;
    yy = yy + yexplode;
  end
  theta0 = max(theta);
  h = [h,patch('XData',xx,'YData',yy,'CData',i*ones(size(xx)), ...
               'FaceColor',cmap(i,:),'parent',cax,options{:}), ...
         text(xtext,ytext,txtlabels{i},...
              'HorizontalAlignment','center','parent',cax,...
              'fontsize',fontsize,'color',cmap(i,:))];
end

if ~hold_state, 
  view(cax,2); set(cax,'NextPlot',next); 
  axis(cax,'equal','off',[-1.2 1.2 -1.2 1.2])  
end

if nargout>0, hh = h; end

% % Register handles with m-code generator
% if ~isempty(h)
%   mcoderegister('Handles',h,'Target',h(1),'Name','pie');
% end


