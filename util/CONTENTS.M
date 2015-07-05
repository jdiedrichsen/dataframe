% Utility toolbox
% Contains function for basic data manipulations in data structures 
% and other utility functions
% Version 2.0 29/08/07
% Joern Diedrichsen (jdiedric@jhu.edu)
% --------------------------------------------------------------
% 1. Data Structure functions 
%  dload            - Loads data file into data structure (field or variable names are given my first row)
%  dsave            - Save a data structure as a data file with headers (ASCII) 
%  dprint           - Prints data structure on screen 
%  dsort            - Sorts a data structure according to some fields
%  dshuffel         - Randomizes the rows of a data structure
%  addstruct        - Adds a data structure to another - field by field
%  getrow           - Returns rows x from a data structure 
%  setrow           - Sets rows x in a data structure
%  insertrow        - Insert row(s) at position x into a data structure
%  field_matrix2vector - Changes a matrix into fields of column vectors, called var1,var2,...
%  field_vector2matrix - Changes vectors var1,var,... back into matrix var
% 2. Other Data manipulations 
%  findrow          - Finds a row of certain values in a Matrix
%  findIdx          - Finds indices based on several criteria combined by and/or
%  minmax           - Finds absolute minimum/maximum
%  nancount         - Returns number of nans in a vector
%  fisherz          - Fisher-z transformation of correlation
%  fisherinv        - Inverse of fisher-z
%  split_data       - Splits ordinal data into p categories
%  isincluded       - test whether each element of a vector is in a set
%  RemoveTails      - Given a vector containing only 0's and 1's, removes any tails which has a consecutive sequences of 1's
%  SetMatrixValues  - performs a set of functions on a matrix to set specified values
% 3. Input/output functions
%  get_response     - Waits for a user-key press
%  vararginoptions  - Deals with argument lists passed to functions 
%  fcneval          - Evaluates a function argument with eval or feval
%  struct2list      - Makes a structure into a argument list 