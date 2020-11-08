function [start,stop] = get_changepoints(Photons,threshold)
global FileInfo PathToApp
%%% Wrapper function to run the changepoint detection algorithm
%%% The C code outputs text files with the result into a temp directory
%%% This functions passes the arguments to the C code and reads the data
%%% from the temporary files, then deletes them.
%%% Threshold is given in kHz
SyncPeriod = FileInfo.SyncPeriod;
Nstates = 5; % the number of intensity levels
alpha = 0.05; % Type-I error rate alpha
ci = 0.69; % selection confidence interval of 69%
temp_dir = fullfile(PathToApp,'functions','temp');
if ~exist(temp_dir,'dir')
    mkdir(temp_dir);
end
temp_filename = fullfile(temp_dir,'temp');
% define temp file name
file_ext = {'cp','ah','bic'};
for i = 2:Nstates
    file_ext{end+1} = sprintf('em.%i',i);
end
% run analysis
dt = diff(Photons);
split_photons = 20000;
N_splits = ceil(numel(dt)./split_photons);
result = cell(N_splits,1);
for i = 1:(N_splits-1)
    if i == N_splits-1 % combine the last two bins to avoid too small intervals
        dt_temp = dt((i-1)*split_photons+1 : end);
    else
        dt_temp = dt((i-1)*split_photons+1 : i*split_photons);
    end
    fprintf('Number of photons: %i (%i of %i)\n',numel(dt_temp),i,N_splits);
    get_changepoints_mex(dt_temp,...
        SyncPeriod,alpha,ci,Nstates,temp_filename);
    r = struct;
    for f = 1:numel(file_ext)
        fn = [temp_filename '.' file_ext{f}];
        % read file into struct
        r.(strrep(file_ext{f},'.','')) = dlmread(fn);
        % delete file
        delete(fn);
    end
    result{i} = r;
end

%%% find start/stop of spike regions
%   what level of clustering should be used?
start = cell(0); stop = cell(0);
for i = 1:numel(result)
    if ~isempty(result{i})
        intensities = result{i}.(sprintf('em%i',Nstates));
        intensities = intensities(:,2)/1000; % intenisites in kHz
        levels = unique(intensities);

        if any(levels > threshold)
            % find all start/stop of levels above threshold
            valid_regions = intensities > threshold;
            d = diff(valid_regions);
            start_idx = d == 1;
            stop_idx = d == -1;
            start{i} = result{i}.cp(start_idx,1)+(i-1)*split_photons;
            stop{i} = result{i}.cp(stop_idx,1)+(i-1)*split_photons;
        end
    end
end
% combine
start = vertcat(start{:});
stop = vertcat(stop{:});

while numel(start) ~= numel(stop)
    if numel(stop) < numel(start)
        % last stop missing
        start(end) = [];
    elseif numel(start) < numel(stop)
        % first start is missing
        stop(1) = [];
    end
end