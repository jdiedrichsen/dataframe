function A=movload(fname)
% movload: loads a mov file, parsed into single trials 
%           checks for consequtive numbering of the trials 
%           and warns if trials are missing or out of order 
% Synopsis
%		M=movload(fname)
% Description
%		fname: filename 
fid=fopen(fname,'rt');
if (fid==-1)
    error(sprintf('Could not open %s',fname));
end;
trial=0;
while ~feof(fid)
    line=fgetl(fid);
    if line(1)=='T'
        a=sscanf(line,'Trial %d');
        trial=trial+1;
        if (a~=trial)
            warning('Trials out of sequence');
            trial=d;
        end;
        A{trial}=[];
    else 
        a=sscanf(line,'%f');
       A{trial}=[A{trial};a'];
    end;
end;
fclose(fid);

