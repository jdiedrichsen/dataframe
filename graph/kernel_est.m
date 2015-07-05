function Y=kernel_est(x,y,X);
% smoothing with a gaussian kernel over neighborhood
sigma=W/sqrt(8*log(2));
[num_nodes,num_cols]=size(z);
Kernel=normpdf([0:0.05:3.5],0,1)';
for n=1:num_nodes
    d=coord-repmat(coord(n,:),num_nodes,1);
    dn=sqrt(sum(d.^2,2))./sigma;
    indx=find(dn<=3.5);
    din=floor(dn(indx)./0.05)+1;
    w=Kernel(repmat(din,1,num_cols));
    s(n,:)=sum(z(indx,:).*w)./sum(w);
    if(mod(n,100)==0)
        fprintf('smooth:%d\n',n);
    end;
end;