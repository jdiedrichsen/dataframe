function A  = pidata(R,F) 
% gives the data sorted ready for a  pivot table in a cell array 
% 
% function A  = pidata(R,F)
% A is a N*2 cell array 
% A{:,1} is a vector which describes the combination of R-factors 
% A{:,2} hold a vector of field data 
% Bug-fix 7/25/03: if there is a NaN in one of the Row-data, the old
% version automatically crashed. Bug is fixed.
% Extension: data can be two or more column
% 7/12/04: Rewrote function to avoid recursion and expensive matrix-resizing, 
% uses 
B={};
  [rr,rc]=size(R);
  [fr,fc]=size(F);
  if (rr~=fr) 
      error('Rows, Column and Field vector must have same length');
  end;
  B=unique(R,'rows');
  for i=1:size(B,1);
      A{i,1}=B(i,:);
      indx=findrow(R,B(i,:));
      A{i,2}=F(indx,:);
  end;
