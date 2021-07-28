function [start,stop] = get_changepoints(Photons,threshold)
global FileInfo PathToApp UserValues
%%% Wrapper function to run the changepoint detection algorithm
%%% The C code outputs text files with the result into a temp directory
%%% This functions passes the arguments to the C code and reads the data
%%% from the temporary files, then deletes them.
%%% Threshold is given in kHz
SyncPeriod = FileInfo.SyncPeriod;
Nstates = 5; % the number of intensity levels
alpha = 0.01; % Type-I error rate alpha
ci = 0.69; % selection confidence interval of 69%
include_sigma = UserValues.BurstSearch.ChangePointIncludeSigma; % extend the burst range to include the confidence interval

temp_dir = fullfile(PathToApp,'functions','temp');
if ~exist(temp_dir,'dir')
    mkdir(temp_dir);
end
temp_filename = fullfile(temp_dir,'temp');
temp_filename = [temp_filename '.dat'];
% define temp file name
file_ext = {'cp','ah','bic'};
for i = 2:Nstates
    file_ext{end+1} = sprintf('em.%i',i);
end
if ispc %%% different version on windows, generates additional files
    file_ext = [file_ext {'cp0','asc'}];
end
% get exe location
if ispc
    exe_loc = [PathToApp filesep 'functions' filesep 'C_Files' filesep 'ChangePoint-Poisson' filesep 'changepoint_win.exe'];
elseif isunix
    if ismac
        exe_loc = [PathToApp filesep 'functions' filesep 'C_Files' filesep 'ChangePoint-Poisson' filesep 'changepoint_mac.exe'];
    else
        disp('Linux currently not supported. Please compile the executable yourself and contact suppport.');
        return;
    end
end

if ~exist(exe_loc,'file')
    disp('Executable not found.');
end
% get logfile location
logfile_loc = [PathToApp filesep 'functions' filesep 'temp' filesep 'logfile.txt'];
if exist(logfile_loc,'file')
    % delete if exists
    delete(logfile_loc);
end

% run analysis
dt = diff(Photons);
% remove zero time lags
dt(dt == 0) = 1;
split_photons = 25000;
N_splits = ceil(numel(dt)./split_photons);
result = cell(N_splits,1);
pid = cell(N_splits,1);
fprintf('Detecting change points...\n'); b = 0;
for i = 1:N_splits
    if i == N_splits % last bin, go up to end
        dt_temp = dt((i-1)*split_photons+1 : end);
    else
        dt_temp = dt((i-1)*split_photons+1 : i*split_photons);
    end
    if 0
        % use the mex function (sometimes crashes, which is not
        % recoverable)
        get_changepoints_mex(dt_temp,...
            SyncPeriod,alpha,ci,Nstates,temp_filename);
    else
        % call the function through the command line instead
        % first, write the temporarily to the disc
        temp_filename_unique = [temp_filename(1:end-4) '_' num2str(i) temp_filename(end-3:end)];
        dlmwrite(temp_filename_unique,dt_temp,'precision','%i');
        %%% we use different version of the program between mac and windows
        if ispc
            [~,cmd_out] = system(['"' exe_loc '"' sprintf(' -d=%d --alpha=%.2f --beta=%.2f --ngmax=%i',SyncPeriod,alpha,ci,Nstates) ' "' temp_filename_unique '" ' ' >> "' logfile_loc '" & echo $!']);
        elseif ismac
            [~,cmd_out] = system([exe_loc ' ' temp_filename_unique sprintf(' %d %.2f %.2f %i',SyncPeriod,alpha,ci,Nstates) ' >> ' logfile_loc ' & echo $!']);
        end
        delete(temp_filename_unique);
        % store the process ID to kill it later
        id = strsplit(cmd_out,'\n');
        pid{i} = id{end-1};
    end
    %%% update progress bar
    p = floor(100*i/N_splits); % the progress in %
    fprintf(repmat('\b',1,b));
    text = sprintf(['|' repmat('-',1,p) repmat(' ',1,100-p) '| %i%%\n'],p);
    fprintf(['|' repmat('-',1,p) repmat(' ',1,100-p) '| %i%%\n'],p);
    b = numel(text);
end

tic;
if ispc
    while ~all(cellfun(@isempty,pid)) % some processes still run
        %%% loop through all processes and check status
        for i = 1:numel(pid)
            if ~isempty(pid{i})
                if toc > 10 %%% more than 10 seconds passed, kill
                    [status,~] = system(['taskkill /F /PID ' pid{i}]);
                     if status == 0
                        fprintf('Killed process with id %s before completion.\n',pid{i});
                        pid{i} = [];
                     elseif isempty(cmdout) %%% process not active anymore
                        pid{i} = [];
                     end     
                else %%% check and update status
                    [~,cmdout] = system(['tasklist | find /i "' pid{i} '"']);
                    if isempty(cmdout) %%% process not active anymore
                        pid{i} = [];
                    end
                end
            end
        end        
    end
elseif isunix
    while ~all(cellfun(@isempty,pid)) % some processes still run
        %%% loop through all processes and check status
        for i = 1:numel(pid)
            if ~isempty(pid{i})
                if toc > 10 %%% more than 10 seconds passed, kill
                    [status,~] = system(['kill ' pid{i}]);
                     if status == 0
                        fprintf('Killed process with id %s before completion.\n',pid{i});
                        pid{i} = [];
                     elseif contains(cmdout,'no such process') %%% process not active anymore
                        pid{i} = [];
                     end   
                else %%% check and update status
                    [~,cmdout] = system(['kill -0 ' pid{i}]);
                    if contains(cmdout,'no such process') %%% process not active anymore
                        pid{i} = [];
                    end
                end
            end
        end
    end
end
fprintf('Done.\n');

for i = 1:N_splits
    try
        r = struct;
        for f = 1:numel(file_ext)
            fn = [temp_filename(1:end-4)  '_' num2str(i) temp_filename(end-3:end) '.' file_ext{f}];
            % read file into struct
            r.(strrep(file_ext{f},'.','')) = dlmread(fn);
            % delete file
            delete(fn);
        end
    catch % if no file was written
        r = [];
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
        if N_splits == 1
            %%% inform about detected intensity levels
            disp('Intensity levels: [kHz]'); fprintf('%f\n',levels);
        end
        if any(levels > threshold)
            % find all start/stop of levels above threshold
            valid_regions = intensities > threshold;
            d = diff(valid_regions);
            start_idx = (d == 1);
            stop_idx = (d == -1);
            %%% Note: +1 is added to move from interphoton time to photon index
            if ~include_sigma
                start{i} = result{i}.cp(start_idx,1)+(i-1)*split_photons+1;
                stop{i} = result{i}.cp(stop_idx,1)+(i-1)*split_photons+1;
            else % extend range to include the sigma boundaries
                start{i} = result{i}.cp(start_idx,2)+(i-1)*split_photons+1;
                stop{i} = result{i}.cp(stop_idx,3)+(i-1)*split_photons+1;
            end
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