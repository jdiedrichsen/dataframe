function save_figs(varargin)
% function save_figs(varargin);
%
% Takes open figures and resizes them before saving to file. If there are no open figures, it asks
% for user input to call the function that produces them first, then proceeds as usual.
%
% Inputs
%   (optional)
%   varargin    : optional input variables
%
%
% Usage example : save_figs('pathtosave','../../../docs', 'whichf','all', 'width',17.6, 'height',20, 'units','centimeters', 'format','pdf', 'res','-r600');
%
% -- Latest updates
% v1.0: gariani@uwo.ca - 2022.03.28: function created
% --------------------------------------------------------------------------------------------------
pathtosave = '~/Documents/Figures'; % save figures in home directory if no save path is given
whichf = 'last'; % 'last'=current figure, 'all'=every open figure, or figure numer, e.g., whichf = 2
format = 'pdf'; % 'pdf', 'svg', 'png', 'jpeg', 'tiff', 'epsc'
resize = '-bestfit'; % '-bestfit', '-fillpage'
res = '-r0'; % '-r300', '-r600' % DPI; -r0 ensures that the output res is the same as display res
width = 11.6; % Width of figure, depends on units
height = 11.6; % Height of figure, depends on units
units = 'centimeters'; % 'centimeters', 'inches', 'normalized', 'pixels', 'points'
font = 'Helvetica'; % 'Arial', 'Helvetica', 'Courier', 'Verdana'
ms = 6; % MarkerSize
lw = 2; % LineWidth
lwa = 1; % AxesLineWidth
fs = 10; % Fontsize
fsl = 14; % FontSize legend and labels
axsty = 'normal'; % 'normal', 'equal', 'square', 'image' % axes ratio
paperposmode = 'auto'; % 'auto', 'manual'
vararginoptions(varargin, {'pathtosave', 'whichf', 'format', 'resize', 'res', ...
    'width', 'height', 'ms', 'lw', 'lwa', 'fs', 'fsl', 'axsty', 'units', 'font', ...
    'paperposmode'});

% check if save dir exists already
if ~exist(pathtosave, 'dir'); warning('Directory %s doesn''t exist. Creating now.\n', pathtosave); mkdir(pathtosave); end

% check if there are open figures, or open one
g = groot;
if isempty(g.Children) % there are no open figures
    % ask which figure to produce
    call = input('No open figures. Call function to create figures (e.g., D=wmp2_analyze(''RT_diff'');): ', 's');
    eval(sprintf('%s', call))
end

% set default figure paper position mode for this matlab session
% this ensures that the printed or saved figure size matches the displayed figure size.
set(g, 'defaultFigurePaperPositionMode',paperposmode);
% To generate output that has the same size and resolution (DPI) as the displayed figure, set the
% PaperPositionMode property of the figure to 'auto' and save the figure using print with the -r0
% option. The -r0 option ensures that the output resolution is the same as the display resolution.
% If the resolutions are different, then the generated output size matches the displayed figure size
% in measured units (inches, centimeters, points), but not in pixels. For example, if the display
% resolution is 100 DPI, then a 4-by-5 inch figure is 400-by-500 pixels. If the output resolution is
% 200 DPI, then the printed or saved figure is the same size in inches, but 800-by-1000 pixels.

% save current figure (last), a specific figure (fnum), or all open figures
if ~ischar(whichf); fnum = num2str(whichf); else; fnum = {}; end
switch whichf
    case fnum
        % find figures before setting final figure properties
        for ff = 1:numel(g.Children)
            if g.Children(ff).Number==str2double(whichf)
                f = g.Children(ff);
                break
            else
                continue
            end
        end
        
        % decide on final figure size (1 col, 2 cols, etc.)
        set(f, 'WindowStyle','normal', 'renderer','painters');
        set(f, 'Position',[0 0 width height], 'Units',units);
        % unlcear why, but needs to be set twice or it doesn't work
        set(f, 'Position',[0 0 width height], 'Units',units);
        
        % adjust line thickness and marker size
        hlines = findobj(f, 'Type','Line');
        set(hlines, 'LineWidth',lw, 'MarkerSize',ms);
        
        % for each subplot
        for aa = 1:numel(f.Children)
            % get the axes handle
            a = f.Children(aa);
            
            % check if it's a legend object
            if ~isempty(findobj(a, 'Type','Legend'))
                l = findobj(a, 'Type','Legend');
                set(l, 'FontSize',fs);
            else % axes object
                % adjust axes ratio and line thickness
                axis(a, axsty);
                set(a, 'LineWidth',lwa);
                
                % adjust font size for axes, legend, and ticks
                set(a, 'FontName',font, 'FontSize',fs);
                set(a.Title, 'FontSize',fsl);
                set(a.XLabel, 'FontSize',fsl);
                set(a.YLabel, 'FontSize',fsl);
            end
        end
        
        % set paper properties (only relevant if specific paper needs)
        set(f, 'PaperUnits',units, 'PaperSize',[width height]);
        
        % ask how to name the figure when saving it
        fname = input('Provide figure name (without extension): ', 's');
        if isempty(fname); warning('No name provided! Default given.'); fname='no_name'; end
        savename = fullfile(pathtosave, sprintf('%s', fname));
        
        % print out (save) the figure to file
        if any(strcmp(format, {'pdf','ps'}))
            % resize option only available for PDF and PS formats
            print(f, savename, sprintf('-d%s',format), resize, res);
        else
            print(f, savename, sprintf('-d%s',format), res);
        end
    case 'last'
        % find figures before setting final figure properties
        f = gcf;
        
        % decide on final figure size (1 col, 2 cols, etc.)
        set(f, 'WindowStyle','normal', 'renderer','painters');
        set(f, 'Position',[0 0 width height], 'Units',units);
        % unlcear why, but needs to be set twice or it doesn't work
        set(f, 'Position',[0 0 width height], 'Units',units);
        
        % adjust line thickness and marker size
        hlines = findobj(f, 'Type','Line');
        set(hlines, 'LineWidth',lw, 'MarkerSize',ms);
        
        % for each subplot
        for aa = 1:numel(f.Children)
            % get the axes handle
            a = f.Children(aa);
            
            % check if it's a legend object
            if ~isempty(findobj(a, 'Type','Legend'))
                l = findobj(a, 'Type','Legend');
                set(l, 'FontSize',fs);
            else % axes object
                % adjust axes ratio and line thickness
                axis(a, axsty);
                set(a, 'LineWidth',lwa);
                
                % adjust font size for axes, legend, and ticks
                set(a, 'FontName',font, 'FontSize',fs);
                set(a.Title, 'FontSize',fsl);
                set(a.XLabel, 'FontSize',fsl);
                set(a.YLabel, 'FontSize',fsl);
            end
        end
        
        % set paper properties (only relevant if specific paper needs)
        set(f, 'PaperUnits',units, 'PaperSize',[width height]);
        
        % ask how to name the figure when saving it
        fname = input('Provide figure name (without extension): ', 's');
        if isempty(fname); warning('No name provided! Default given.'); fname='no_name'; end
        savename = fullfile(pathtosave, sprintf('%s', fname));
        
        % print out (save) the figure to file
        if any(strcmp(format, {'pdf','ps'}))
            % resize option only available for PDF and PS formats
            print(f, savename, sprintf('-d%s',format), resize, res);
        else
            print(f, savename, sprintf('-d%s',format), res);
        end
    case 'all'
        % find figures before setting final figure properties
        for ff = 1:numel(g.Children)
            f = g.Children(ff);
            
            % decide on final figure size (1 col, 2 cols, etc.)
            set(f, 'WindowStyle','normal', 'renderer','painters');
            set(f, 'Position',[0 0 width height], 'Units',units);
            % unlcear why, but needs to be set twice or it doesn't work
            set(f, 'Position',[0 0 width height], 'Units',units);
            
            % adjust line thickness and marker size
            hlines = findobj(f, 'Type','Line');
            set(hlines, 'LineWidth',lw, 'MarkerSize',ms);
            
            % for each subplot
            for aa = 1:numel(f.Children)
                % get the axes handle
                a = f.Children(aa);
                
                % check if it's a legend object
                if ~isempty(findobj(a, 'Type','Legend'))
                    l = findobj(a, 'Type','Legend');
                    set(l, 'FontSize',fs);
                else % axes object
                    % adjust axes ratio and line thickness
                    axis(a, axsty);
                    set(a, 'LineWidth',lwa);
                    
                    % adjust font size for axes, legend, and ticks
                    set(a, 'FontName',font, 'FontSize',fs);
                    set(a.Title, 'FontSize',fsl);
                    set(a.XLabel, 'FontSize',fsl);
                    set(a.YLabel, 'FontSize',fsl);
                end
            end
            
            % set paper properties (only relevant if specific paper needs)
            set(f, 'PaperUnits',units, 'PaperSize',[width height]);
            
            % ask how to name the figure when saving it
            fname = input('Provide figure name (without extension): ', 's');
            if isempty(fname); warning('No name provided! Default given.'); fname='no_name'; end
            savename = fullfile(pathtosave, sprintf('%s', fname));
            
            % print out (save) the figure to file
            if any(strcmp(format, {'pdf','ps'}))
                % resize option only available for PDF and PS formats
                print(f, savename, sprintf('-d%s',format), resize, res);
            else
                print(f, savename, sprintf('-d%s',format), res);
            end
        end
    otherwise
        error('no such case!')
end