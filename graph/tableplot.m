function tableplot(varargin)
% Function plots the data as a table in the figure
% ------------------------------------------------
% History
% 06/02/13 - Function created (Naveed Ejaz)

ColumnWidth = 'auto';
Precision = '%0.3f';
Position = [74 30 435 100];
RowName = [];
ColumnName = [];
vararginoptions(varargin,{'Data','ColumnName','Position','ColumnWidth','Precision','RowName'}); 


[r,c] = size(Data);
DataStr = cell(r,c);
for i = 1:r
    for j = 1:c
        DataStr{i,j} = sprintf(Precision,Data(i,j));
    end;
end;
uitable('Data', DataStr, 'ColumnName', ColumnName, 'RowName', RowName, 'Position', Position,'ColumnWidth',ColumnWidth);

