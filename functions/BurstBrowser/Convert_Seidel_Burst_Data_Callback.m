function Convert_Seidel_Burst_Data_Callback(obj,~,filenames)
global UserValues
h = guidata(obj);
PathName = uigetdir(UserValues.File.BurstBrowserPath,'Select folder');

%%% load the data from subfolder:
% 'bg4','bi4_bur','br4','info'
Progress(0,h.Progress_Axes,h.Progress_Text,'Converting data...');

% check if conversion was already done
folder  = strsplit(PathName,filesep); folder = folder{end};
if exist([PathName filesep folder '.bur'],'file') == 2
    disp('File was already converted.')
    Progress(1,h.Progress_Axes,h.Progress_Text);
    return;
end
% get files in bg4 folder
bg4_files = dir([PathName filesep 'bg4']);
if isempty(bg4_files)
    % try tg4, i.e. time-window burst analysis
    bg4_files = dir([PathName filesep 'tg4']);
end
params_bg4 = [];
data_bg4 = cell(0);
for i = 1:numel(bg4_files)
    if ~bg4_files(i).isdir
        if isempty(params_bg4) %%% read names
            fid = fopen([bg4_files(i).folder filesep bg4_files(i).name],'r');
            params_bg4 = strsplit(fgetl(fid),'\t');
            params_bg4(cellfun(@isempty,params_bg4)) = [];
            fclose(fid);
        end
        data = dlmread([bg4_files(i).folder filesep bg4_files(i).name],'\t',2,0);
        data_bg4{end+1} = data;
    end
    Progress(i/numel(bg4_files),h.Progress_Axes,h.Progress_Text,'Converting bg4 files... (Step 1 of 3)');
end
%data_bg4 = vertcat(data_bg4{:});
% for some reasone, every second data point is empty
%data_bg4(sum(data_bg4,2)==0,:) = [];

% get files in bi4_bur folder
bi4_bur_files = dir([PathName filesep 'bi4_bur']);
if isempty(bi4_bur_files)
    % try tg4, i.e. time-window burst analysis
    bi4_bur_files = dir([PathName filesep 'ti4_bur']);
end
params_bi4_bur = [];
data_bi4_bur = cell(0);
for i = 1:numel(bi4_bur_files)
    if ~bi4_bur_files(i).isdir
        if isempty(params_bi4_bur) %%% read names
            fid = fopen([bi4_bur_files(i).folder filesep bi4_bur_files(i).name],'r');
            params_bi4_bur = strsplit(fgetl(fid),'\t');
            params_bi4_bur(cellfun(@isempty,params_bi4_bur)) = [];
            params_bi4_bur(7:8) = [];% remove the first-file-last-file parameters
            fclose(fid);
        end
        fid = fopen([bi4_bur_files(i).folder filesep bi4_bur_files(i).name],'r');
        fgetl(fid); % get one line to skip header
        data = textscan(fid,[repmat('%s\t',[1, numel(params_bi4_bur)+1]),'%s%[^\n\r]']);
        fclose(fid);
        % combine cell arrays
        data = horzcat(data{:});
        % remove head
        data(1,:) = [];
        % remove last row
        data(:,end) = [];
        % remove the first-file-last-file columns
        data(:,7:8) = [];
        % convert to matrix
        data = cellfun(@(x) str2double(x),data);
        % for some reason, every second data point is empty
        %data(sum(data,2)==0,:) = [];
        data_bi4_bur{end+1} = data;
    end
    Progress(i/numel(bi4_bur_files),h.Progress_Axes,h.Progress_Text,'Converting bi4_bur files... (Step 2 of 3)');   
end
%data_bi4_bur = vertcat(data_bi4_bur{:});
% for some reason, every second data point is empty
%data_bi4_bur(sum(data_bi4_bur,2)==0,:) = [];

% get files in br4 folder
if exist([PathName filesep 'br4'],'dir') || exist([PathName filesep 'tr4'],'dir')
    br4_files = dir([PathName filesep 'br4']);
    if isempty(br4_files)
        % try tg4, i.e. time-window burst analysis
        br4_files = dir([PathName filesep 'tr4']);
    end
    params_br4 = [];
    data_br4 = cell(0);
    for i = 1:numel(br4_files)
        if ~br4_files(i).isdir
            if isempty(params_br4) %%% read names
                fid = fopen([br4_files(i).folder filesep br4_files(i).name],'r');
                params_br4 = strsplit(fgetl(fid),'\t');
                params_br4(cellfun(@isempty,params_br4)) = [];
                fclose(fid);
            end
            data = dlmread([br4_files(i).folder filesep br4_files(i).name],'\t',2,0);
            data_br4{end+1} = data;
        end
        Progress(i/numel(br4_files),h.Progress_Axes,h.Progress_Text,'Converting br4 files... (Step 3 of 3)');
    end
    %data_br4 = vertcat(data_br4{:});
    % for some reasone, every second data point is empty
    %data_br4(sum(data_br4,2)==0,:) = [];
end

% get files in by4 folder
if exist([PathName filesep 'by4'],'dir') || exist([PathName filesep 'ty4'],'dir')
    by4_files = dir([PathName filesep 'by4']);
    if isempty(by4_files)
        % try ty4, i.e. time-window burst analysis
        by4_files = dir([PathName filesep 'ty4']);
    end
    params_by4 = [];
    data_by4 = cell(0);
    for i = 1:numel(br4_files)
        if ~by4_files(i).isdir
            if isempty(params_by4) %%% read names
                fid = fopen([by4_files(i).folder filesep by4_files(i).name],'r');
                params_by4 = strsplit(fgetl(fid),'\t');
                params_by4(cellfun(@isempty,params_by4)) = [];
                fclose(fid);
            end
            data = dlmread([by4_files(i).folder filesep by4_files(i).name],'\t',2,0);
            data_by4{end+1} = data;
        end
        Progress(i/numel(by4_files),h.Progress_Axes,h.Progress_Text,'Converting by4 files... (Step 3 of 3)');
    end
end

% read info
fid = fopen([PathName filesep 'info' filesep 'Paris_x64 info.txt']);
info = {};
indic = 1;
while 1
     tline = fgetl(fid);
     if ~ischar(tline)
         break
     end
     info{indic}=tline; 
     indic = indic + 1;
end
fclose(fid);
info = info';

% combine data
ParameterNames = [params_bi4_bur,params_bg4];
Data = [vertcat(data_bi4_bur{:}),vertcat(data_bg4{:})];
if exist('params_br4','var')
    ParameterNames = [ParameterNames, params_br4];
    Data = [Data,vertcat(data_br4{:})];
end
if exist('params_by4','var')
    ParameterNames = [ParameterNames, params_by4];
    Data = [Data,vertcat(data_by4{:})];
end
Data(sum(Data,2)==0,:) = [];

Progress(1,h.Progress_Axes,h.Progress_Text,'Saving converted data...');
% rename parameters
ParameterNames{strcmp(ParameterNames,'Duration (ms)')} = 'Duration [ms]';
ParameterNames{strcmp(ParameterNames,'Mean Macro Time (ms)')} = 'Mean Macrotime [ms]';
ParameterNames{strcmp(ParameterNames,'Count Rate (KHz)')} = 'Count rate [kHz]';
ParameterNames{strcmp(ParameterNames,'Number of Photons (green)')} = 'Number of Photons (DD)';
ParameterNames{strcmp(ParameterNames,'Green Count Rate (KHz)')} = 'Count rate (DD) [kHz]';
ParameterNames{strcmp(ParameterNames,'Number of Photons (red)')} = 'Number of Photons (DA)';
ParameterNames{strcmp(ParameterNames,'Red Count Rate (KHz)')} = 'Count rate (DA) [kHz]';
ParameterNames{strcmp(ParameterNames,'Ng-p-all')} = 'Number of Photons (DD par)';
ParameterNames{strcmp(ParameterNames,'Ng-s-all')} = 'Number of Photons (DD perp)';
ParameterNames{strcmp(ParameterNames,'Tau (green)')} = 'Lifetime D [ns]';
ParameterNames{strcmp(ParameterNames,'r Experimental (green)')} = 'Anisotropy D';
ParameterNames{strcmp(ParameterNames,'Nr-p-all')} = 'Number of Photons (DA par)';
ParameterNames{strcmp(ParameterNames,'Nr-s-all')} = 'Number of Photons (DA perp)';

if sum(strcmp(ParameterNames,'FRET Efficiency')) == 0
    ParameterNames{end+1} = 'FRET Efficiency';
    Data(:,end+1) = Data(:,strcmp(ParameterNames,'Number of Photons (DA)'))./...
        (Data(:,strcmp(ParameterNames,'Number of Photons (DD)')) + Data(:,strcmp(ParameterNames,'Number of Photons (DA)')));
end

if sum(strcmp(ParameterNames,'Proximity Ratio')) == 0
    ParameterNames{end+1} = 'Proximity Ratio';
    Data(:,end+1) = Data(:,strcmp(ParameterNames,'Number of Photons (DA)'))./...
        (Data(:,strcmp(ParameterNames,'Number of Photons (DD)')) + Data(:,strcmp(ParameterNames,'Number of Photons (DA)')));
end
if sum(strcmp(ParameterNames,'Stoichiometry')) == 0
    ParameterNames{end+1} = 'Stoichiometry';
    Data = [Data, zeros(size(Data,1),1)];
end
if sum(strcmp(ParameterNames,'Number of Photons (yellow)')) == 0 % no PIE information    
    ParameterNames{end+1} = 'Number of Photons (AA)';
    ParameterNames{end+1} = 'Number of Photons (AA par)';
    ParameterNames{end+1} = 'Number of Photons (AA perp)';
    Data = [Data, zeros(size(Data,1),3)];
end
if sum(strcmp(ParameterNames,'Tau (yellow)')) == 0 % no lifetime PIE information    
    ParameterNames{end+1} = 'Lifetime A [ns]';
    ParameterNames{end+1} = 'Anisotropy A';
    Data = [Data, zeros(size(Data,1),2)];
end

% rename acceptor parameters
ParameterNames{strcmp(ParameterNames,'Number of Photons (yellow)')} = 'Number of Photons (AA)';
ParameterNames{strcmp(ParameterNames,'Ny-p-all')} = 'Number of Photons (AA par)';
ParameterNames{strcmp(ParameterNames,'Ny-s-all')} = 'Number of Photons (AA perp)';
ParameterNames{strcmp(ParameterNames,'Tau (yellow)')} = 'Lifetime A [ns]';
ParameterNames{strcmp(ParameterNames,'r Experimental (yellow)')} = 'Anisotropy A';

% add raw Stoichiometry
if sum(strcmp(ParameterNames,'Stoichiometry (raw)')) == 0
    ParameterNames{end+1} = 'Stoichiometry (raw)';
    Data(:,end+1) = (Data(:,strcmp(ParameterNames,'Number of Photons (DD)'))+Data(:,strcmp(ParameterNames,'Number of Photons (DA)')))./...
        (Data(:,strcmp(ParameterNames,'Number of Photons (DD)')) + Data(:,strcmp(ParameterNames,'Number of Photons (DA)'))+ Data(:,strcmp(ParameterNames,'Number of Photons (AA)')));
end

% fill missing field in BurstData structure
burst_data = struct;

burst_data.NameArray = ParameterNames;
burst_data.DataArray = Data;
burst_data.BAMethod = 1;
burst_data.FileType = 'SPC';
burst_data.SyncRate = round(1/37.5E-9);
burst_data.TACRange = 1E9./burst_data.SyncRate; 
burst_data.SyncPeriod = 1./burst_data.SyncRate;
burst_data.ClockPeriod = burst_data.SyncPeriod;
burst_data.FileInfo.MI_Bins = 4096;
burst_data.FileInfo.TACRange = burst_data.TACRange;

s = strsplit(PathName,filesep);
burst_data.FileName = s{end};
burst_data.PathName = fullfile(s{1:end-1});
%%% check for existing Cuts
if ~isfield(burst_data,'Cut') %%% no cuts existed
    %initialize Cut Cell Array with standard cuts
    switch burst_data.BAMethod
        case {1,2,5}
            %%% FRET efficiency and stoichiometry basic cuts
            Cut = {{'FRET Efficiency',-0.1,1.1,true,false},{'Stoichiometry',-0.1,1.1,true,false}};
        case {3,4}
            %%% 3color, only do FRET GR and Stoichiometry cuts
            Cut = {{'FRET Efficiency GR',-0.1,1.1,true,false},{'Stoichiometry GR',-0.1,1.1,true,false},...
                {'Stoichiometry BG',-0.1,1.1,true,false},{'Stoichiometry BR',-0.1,1.1,true,false}};
    end
    burst_data.Cut{1} = Cut;
    burst_data.Cut{2} = Cut;
    burst_data.Cut{3} = Cut;
    %add species to list
    burst_data.SpeciesNames{1} = 'Global Cuts';
    % also add two species for convenience
    burst_data.SpeciesNames{2} = 'Subspecies 1';
    burst_data.SpeciesNames{3} = 'Subspecies 2';
    burst_data.SelectedSpecies = [1,1];
end
    
%%% initialize DataCut
burst_data.DataCut = burst_data.DataArray;

burst_data.FileInfo.ParisInfo = info;

%%% save as *.bur file
BurstData = burst_data;
[~,fn] = fileparts(fileparts(PathName));
save([fileparts(PathName) filesep fn '.bur'],'BurstData','-v7.3');
UserValues.File.BurstBrowserPath=fileparts(PathName);
Progress(1,h.Progress_Axes,h.Progress_Text);
LSUserValues(1);