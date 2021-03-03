function [start,stop] = get_changepoints(Photons,threshold)
global FileInfo PathToApp
%%% Wrapper function to run the changepoint detection algorithm
%%% The C code outputs text files with the result into a temp directory
%%% This functions passes the arguments to the C code and reads the data
%%% from the temporary files, then deletes them.
%%% Threshold is given in kHz
SyncPeriod = FileInfo.SyncPeriod;
Nstates = 5; % the number of intensity levels
alpha = 0.01; % Type-I error rate alpha
ci = 0.69; % selection confidence interval of 69%
include_sigma = true; % extend the burst range to include the confidence interval

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
split_photons = 25000;
N_splits = ceil(numel(dt)./split_photons);
result = cell(N_splits,1);
pid = cell(N_splits,1);
fprintf('Detecting change points...\n'); b = 0;
for i = 1:(N_splits-1)
    if i == N_splits-1 % combine the last two bins to avoid too small intervals
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
        dlmwrite(temp_filename_unique,[0;dt_temp]);
        [~,cmd_out] = system([exe_loc ' ' temp_filename_unique sprintf(' %d %.2f %.2f %i',SyncPeriod,alpha,ci,Nstates) ' >> ' logfile_loc ' & echo $!']);
        delete(temp_filename_unique);
        % store the process ID to kill it later
        id = strsplit(cmd_out,'\n');
        pid{i} = id{end-1};
    end
    %%% update progress bar
    p = floor(100*i/(N_splits-1)); % the progress in %
    fprintf(repmat('\b',1,b));
    text = sprintf(['|' repmat('-',1,p) repmat(' ',1,100-p) '| %i%%\n'],p);
    fprintf(['|' repmat('-',1,p) repmat(' ',1,100-p) '| %i%%\n'],p);
    b = numel(text);
end

fprintf('Waiting 10 seconds for subprocesses to finish...\n');
pause(10); % wait for all processes to finish
% kill all processes (routine sometimes hangs)
for i = 1:numel(pid)
    if ~isempty(pid{i})
        [status,~] = system(['kill ' pid{i}]);
        if status == 0
            fprintf('Killed process with id %s before completion.\n',pid{i});
        end
    end
end
fprintf('Done.\n');

for i = 1:(N_splits-1)
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

        if any(levels > threshold)
            % find all start/stop of levels above threshold
            valid_regions = intensities > threshold;
            d = diff(valid_regions);
            start_idx = d == 1;
            stop_idx = d == -1;
            if ~include_sigma
                start{i} = result{i}.cp(start_idx,1)+(i-1)*split_photons;
                stop{i} = result{i}.cp(stop_idx,1)+(i-1)*split_photons;
            else % extend range to include the sigma boundaries
                start{i} = result{i}.cp(start_idx,2)+(i-1)*split_photons;
                stop{i} = result{i}.cp(stop_idx,3)+(i-1)*split_photons;
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