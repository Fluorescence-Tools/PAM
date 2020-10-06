function [time,intensity,header] = load_PQ_decay(fn)
%%% load data from picoquant .dat file
fid = fopen(fn);
if fid == -1
    disp('File not found.');
    return;
end

header = struct;
in_header = true;
i = 1;
while in_header
    line = fgetl(fid);
    %%% catch header information
    rx = '\s*(\w+)\s*:\s*(.+)\s*';
    d = regexp(line,rx,'tokens');
    if ~isempty(d)
        d = d{1};
        header.(d{1}) = d{2};
    end    
    i = i+1;
    if (numel(line) > numel('Time [ns]')) & strcmp(line(1:numel('Time [ns]')),'Time [ns]');
        in_header = false;
        data_start = i-1;
    end   
end
fclose(fid);

M = dlmread(fn,'\t',data_start,0);
time = M(:,1);
intensity = M(:,2);