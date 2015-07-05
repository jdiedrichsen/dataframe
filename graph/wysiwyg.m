function wysiwyg
% WYSIWYG -- this function is called with no args and merely
%       changes the size of the figure on the screen to equal
%       the size of the figure that would be printed,
%       according to the papersize attribute.  Use this function
%       to give a more accurate picture of what will be
%       printed.
%       Dan(K) Braithwaite, Dept. of Hydrology U.of.A  11/93

unis = get(gcf,'units');
old_punits = get(gcf, 'PaperUnits');
set(gcf, 'Units', 'inches', 'PaperUnits', 'inches');
ppos = get(gcf,'paperposition');
set(gcf, 'PaperUnits', old_punits);
pos = [0 0 ppos(3:4)];
set(gcf,'position',pos);
set(gcf,'units',unis);
