function A = spikefilter(A,thres);
% function A = spikefilter(A,thres);
% SPIKEFILTER attempts to remove spikes from the data 
% It employs a local median filter and removes all points 
% that are median +- threshold from the mesurement. 
% It replaces these values by smooth interpolation from the surrounding 
% measurements 
window=4;
threshold=0.2; 
replace=1; 

[I,J]=size(A); 
for j=1:J; 
    for i=1:I; 
        a=nanmedian(A(max(1,i-window):min(I,i+window),j));
        if abs(A(i,j)-a)>threshold
            A(i,j)=NaN; 
        end; 
    end; 
    if (replace)
        good=find(~isnan(A(:,j)));
        bad=find(isnan(A(:,j)));
        x=[1:I]';
        if (length(good)>2 && length(bad)>0)
            A(bad,j)=interp1(x(good),A(good,j),x(bad),'nearest','extrap'); 
        end; 
    end; 
end; 