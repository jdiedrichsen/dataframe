function imagesc_rectangle(varargin)
%  function imagesc_rectangle(A,varargin);
%  function imagesc_rectangle(x,y,A,varargin);
% INPUT:
%   A: Matrix to be displayed as an image consiting of rectangles
%   x,y: X and y coordiante at which to plot these
%   VARARGIN:
%   'scale', [min max]  : Force the scaling of the current color map
%   'MAP',colormap : change color map from default
%   'YDir','normal' / 'reverse: Direction of the y-axis 
%   'overlap',1.03: 3% overlap of rectangles to ensure no gaps 

cla;
if (length(varargin)==1 || ischar(varargin{2}))
    A=varargin{1};
    x=[1:size(A(:,:,1),2)]';
    y=[1:size(A(:,:,1),1)]';
    options={varargin{2:end}};
else
    x=varargin{1};
    y=varargin{2};
    A=varargin{3};
    options={varargin{4:end}};
end;

%----check if a RGB map should be printed
if (size (A,3)== 3)
    isRGB = 1;
else
    isRGB = 0;
end

% Set defaults
MAP=colormap;
scale(1)=min(A(:));
scale(2)=max(A(:));
gray_rec= 0; %defines which rectangles are gray
overlap = 3;  % 3% overlap 
YDir='normal';

vararginoptions(options,{'scale','MAP', 'gray_rec','YDir','overlap'});


%----if a RGB map should be printed make a RGB color trandformation and call imagesc_rectangle again

addGray = 0;
%----handle the underlay image
if sum(gray_rec(:))>0 & size(A,1)==size(gray_rec,1) & size(A,2)==size(gray_rec,2)
    %----init variables
    addGray = 1;
    grayMAP= gray(128);
    maxgray=size(MAP,1);
    maxcol=size(MAP,1);
    %----recalulate scale for color rectangle
    if (scale(1)==min(A(:)) & scale(2)==max(A(:)))%----recalulate scale only if it has the default values
        scale(1)=min(min(A(~gray_rec)));
        scale(2)=max(max(A(~gray_rec)));
    end
    Asc=round((A-scale(1))./(scale(2)-scale(1))*(maxcol-1)+1);
    Asc(Asc<1)=1;
    Asc(Asc>maxcol)=maxcol;
    %----calulate scale for gray rectangle
    scale_gray(1)=min(min(A(gray_rec)));
    scale_gray(2)=max(max(A(gray_rec)));
    Asc_gray=round((A-scale_gray(1))./(scale_gray(2)-scale_gray(1))*(maxcol-1)+1);
    Asc_gray(Asc_gray<1)=1;
    Asc_gray(Asc_gray>maxgray)=maxgray;
else
    %----this is the original imagesc_rectangle function
    maxcol=size(MAP,1);
    
    Asc=round((A-scale(1))./(scale(2)-scale(1))*(maxcol-1)+1);
    Asc(Asc<1)=1;
    Asc(Asc>maxcol)=maxcol;
end
if (length(x)>1)
    dx=(x(2)-x(1))*(1+overlap/100);    % One percent for ensuring overlap
else
    dx=1;
end;
if (length(y)>1)
    dy=(y(2)-y(1))*(1+overlap/100);
else
    dy=1;
end;

for i=1:size(A,1)
    for j=1:size(A,2)
        if (isRGB)
            h=rectangle('Position',[x(j) - dx/2 y(i) - dy/2 dx dy]...
                ,'Curvature',[0 0],'LineStyle','none','FaceColor',squeeze(A(i,j,:)));
        else if ( addGray == 1 && gray_rec(i,j) == 1)
                h=rectangle('Position',[x(j) - dx/2 y(i) - dy/2 dx dy]...
                    ,'Curvature',[0 0],'LineStyle','none','FaceColor',grayMAP(Asc_gray(i,j),:));
            else
                h=rectangle('Position',[x(j)-dx/2 y(i)-dy/2 dx dy]...
                    ,'Curvature',[0 0],'LineStyle','none','FaceColor',MAP(Asc(i,j),:));
            end
        end;
    end;
    
end
set(gca,'XLim',[x(1)-dx/2 x(end)+dx/2],'YLim',[y(1)-dy/2 y(end)+dy/2],'Box','off','YDir',YDir);
