function [ar,ri,AR,RI]=RandIndexLocal(type,c1,c2,xyz,radius)
% function [ar,ri,AR,RI]=RandIndexLocal(type,c1,c2,xyz,radius)
% RandIndexLocal- calculates a local version of the adjusted rand index of
% three types.
%  INPUT:
%     type:
%       'voxelwise': returns for each voxel the proportion of pairs involving this voxel
%                    that are assigned to the same/different categories in both partitions.
%       'searchlight': Returns the normal randcoefficient within a
%                    spherical search light.
%       'searchlightvoxel': Returns the voxel-wise randcoefficient, restricted to a specific
%                    searchlight centered on this voxel
%     c1: First parcellation Nx1 vector
%     c2: Second parcellation Nx1 vector
%     xyz:  Nx3 matrix of coordinates (mm)
%           NxN matrix of distances (mm)
%     radius: Scalar radius of searchlight (mm)
%  OUTPUT:
%     ar: local rand coefficient Nx1 voxel.


% ---------------------------------------------------
% Deal with input arguments
if nargin < 2 | min(size(c1)) > 1 | min(size(c2)) > 1
    error('RandIndex: Requires two vector arguments')
    return
end

% Figure out clusterings
[catI,~,Ii]=unique(c1);
[catJ,~,Ij]=unique(c2);
I=length(catI);
J=length(catJ);

% preallocate arrays
RI=nan(I,J);
AR=nan(I,J);
ar=nan(size(c1));
ri=nan(size(c1));

% ------------------------------
% Deal with input argument: Either distance matrix or coordiantes
if (nargin>2)
    [P,Q]=size(xyz);
    if (Q==3)
        D=surfing_eucldist(xyz',xyz');        % Eucledian distance
    elseif (Q==P)
        D=xyz;
    else
        error('xyz needs to be either Nx3 or NxN distance matrix');
    end;
end;

% ------------------------------
% Now caluculate the different types of rand coefficients, as desired
switch(type)
    case 'voxelwise'
        % ------------------------------
        % Voxel-wise: Each voxel will be assigned a RandIndex, calculated on all
        % pairs involving this voxel. This means that each voxel with the same
        % pair of compartments (across the two parcellation) gets the same score.
        % ------------------------------
        % Build contingency table
        for i=1:I
            for j=1:J
                C(i,j)=sum(c1==catI(i) & c2==catJ(j));
            end;
        end;
        
        % Calculate sums
        N = sum(sum(C));
        Na = sum(C,2);
        Nb = sum(C,1);
        
        
        
        % Do Rand Index for each category pair
        for i=1:I
            for j=1:J
                if (C(i,j)>0)
                    K(1,1)=C(i,j)-1; % Number of other voxels with the same in both
                    K(1,2)=Na(i)-C(i,j); % Same in a, but different in b
                    K(2,1)=Nb(j)-C(i,j); % Same in b, but different in a
                    K(2,2)=N-Na(i)-Nb(j)+C(i,j); % Different in both
                    nm = K(1,1)+K(2,2); % Number of matches
                    RI(i,j)=nm/(N-1);
                    EK = sum(K,2)*sum(K,1)/(N-1);
                    nc = EK(1,1)+EK(2,2);
                    AR(i,j)=(nm-nc)/(N-1-nc);
                    
                    % Project back into vector
                    ri(c1==catI(i) & c2==catJ(j))=RI(i,j);
                    ar(c1==catI(i) & c2==catJ(j))=AR(i,j);
                end;
            end;
        end;
    case 'searchlight'
        % ------------------------------
        % Searchlight with spherical regions - within this
        % region it's the overall rand coefficient calculated on all pairs within
        % that sphere.
        % ------------------------------
        BIN = zeros(P,P,'uint8');  % Category label
        BIN(D<=radius)=1;
        clear D;
        for n=1:P % Loop over all voxels
            indx = BIN(n,:);
            [ar(n),ri(n)]=RandIndex(c1(indx>0),c2(indx>0));
            if (mod(n,100)==0)
                fprintf('.');
            end;
        end;
        fprintf('\n');
    case 'searchlightvoxel'
        % ------------------------------
        % Searchlight with spherical regions - within this
        % region it's the voxel-wise rand coefficient
        % ------------------------------
            % Now find all the
        BIN = zeros(P,P,'uint8');  % Category label
        BIN(D>0 & D<=radius)=1;
        clear D;
        for n=1:P % Loop over all voxels
            i=c1(n);
            j=c2(n);
            indx = BIN(n,:);
            a=c1(indx>0)==i;
            b=c2(indx>0)==j;
            K(1,1)=sum(a & b);
            K(1,2)=sum(a & ~b);
            K(2,1)=sum(~a & b);
            K(2,2)=sum(~a & ~b);
            N =sum(sum(K));
            nm = K(1,1)+K(2,2); % Number of matches
            ri(n)=nm/N;
            EK = sum(K,2)*sum(K,1)/N;
            nc = EK(1,1)+EK(2,2);
            ar(n)=(nm-nc)/(N-nc);
            if (mod(n,100)==0)
                fprintf('.');
            end;
        end;
        fprintf('\n');
end;

