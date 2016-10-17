function drawasterisk(p,x,y,varargin)
%% plot asterisk mark in 2D plot if p is smaller than threshold
% drawasterisk(p,x,y,varargin)
% Inputs
% - p: statistical p-value
% - x: x-position for asterisk
% - y: y-position for asterisk
%
% Option
% - 'alpha': vector of significance levels.
% - 'horizontalalignment': property for text function
% - 'verticalalignment': property for text function
% - 'color': color of text
% - 'font': font name
% - 'size': font size
% - 'angle': angle of text
%
% see also: text.m
%
% a-yokoi (2016)

if length(p)==1
    
    alpha = [0.05,0.01,0.005,0.001];
    horizontalalignment = 'center';
    verticalalignment = 'middle';
    font = 'arial';
    size = 15;
    color = 'k';
    angle = [];
    vararginoptions(varargin,{'alpha','horizontalalignment','verticalalignment',...
        'font','size','color','angle'})
    
    asterisk = '';
    
    % check size of alpha
    alpha = vec(alpha); % stretch to vector
    alpha = sort(alpha,1,'descend'); % sort
    Nalpha = numel(alpha);
    
    % check p and make asterisk
    for i=1:Nalpha
        if p<alpha(i);
            asterisk = sprintf('%s*',asterisk);
        end
    end
    
    % plot asterisk
    h = text(x,y,asterisk,...
        'horizontalalignment', horizontalalignment,...
        'verticalalignment', verticalalignment,...
        'fontname',font,...
        'fontsize',size,...
        'color',color);
    
    % rotate text if angle has any value
    if ~isempty(angle)
        set(h,'rotation',angle);
    end
    
else
    for i=1:length(p)
        drawasterisk(p(i),x(i),y(i),varargin{:});
    end
end

end