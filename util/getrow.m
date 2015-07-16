function ROW=getrow(D,numrow)
% function ROW=get(D,numrow)
% extracts the structure ROW at the position numrow from 
% the data-structure D
% Joern Diedrichsen 
% Version 1.0 9/18/03
% Version 1.1 5/12/15 modified to allow dynamic multidimensional operation
% SEE also: insertrow,setrow
if (~isstruct(D))
    error('D must be a struct'); 
end; 

field=fieldnames(D);
ROW=[];
for f=1:length(field)
    F=getfield(D,field{f});
    access_str = 'F(numrow';
    for i=1:(ndims(F)-1)
         access_str = strcat(access_str,',:');
    end
    access_str = [access_str ')'];
    eval(['ROW=setfield(ROW,field{f},' access_str ');']);
end;
