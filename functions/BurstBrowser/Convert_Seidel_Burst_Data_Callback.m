function Convert_Seidel_Burst_Data_Callback(obj,~,filenames)
global UserValues
h = guidata(obj);
PathName = uigetdir(UserValues.File.BurstBrowserPath,'Select folder');

%%% load the data from subfolder:
% 'bg4','bi4_bur','br4','info'

% get files in bg4 folder
bg4_files = dir([PathName filesep 'bg4']);
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
        data = dlmread([bg4_files(i).folder filesep bg4_files(i).name],'\t',1,0);
        % for some reasone, every second data point is empty
        data(sum(data,2)==0,:) = [];
        data_bg4{end+1} = data;
    end
    disp(sprintf('Loading file %i of %i (%.1f)',i,numel(bg4_files),(100*i/numel(bg4_files))));
end
data_bg4 = vertcat(data_bg4{:});

% get files in bi4_bur folder
bi4_bur_files = dir([PathName filesep 'bi4_bur']);
params_bi4_bur = [];
data_bi4_bur = cell(0);
formatSpec = [repmat('%f',[1,6]),'%s%s',repmat('%f',[1,8]) '[^\n\r]'];
for i = 1:numel(bi4_bur_files)
    if ~bi4_bur_files(i).isdir
        if isempty(params_bi4_bur) %%% read names
            fid = fopen([bi4_bur_files(i).folder filesep bi4_bur_files(i).name],'r');
            params_bi4_bur = strsplit(fgetl(fid),'\t');
            params_bi4_bur(cellfun(@isempty,params_bi4_bur)) = [];
            params_bi4_bur(7:8) = [];% remove the first-file-last-file parameters
            fclose(fid);
        end
        data = import_bi4_bur([bi4_bur_files(i).folder filesep bi4_bur_files(i).name]);
        % remove the first-file-last-file columns
        data(:,7:8) = []; data = cell2mat(data);
        %%% separate file name
        % for some reasone, every second data point is empty
        data(sum(data,2)==0,:) = [];
        data_bi4_bur{end+1} = data;
    end
    disp(sprintf('Loading file %i of %i (%.1f)',i,numel(bi4_bur_files),(100*i/numel(bi4_bur_files))));
end
data_bi4_bur = vertcat(data_bi4_bur{:});

% get files in br4 folder
if exist([PathName filesep 'br4'],'dir')
    br4_files = dir([PathName filesep 'br4']);
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
            data = dlmread([br4_files(i).folder filesep br4_files(i).name],'\t',1,0);
            % for some reasone, every second data point is empty
            data(sum(data,2)==0,:) = [];
            data_br4{end+1} = data;
        end
        disp(sprintf('Loading file %i of %i (%.1f)',i,numel(br4_files),(100*i/numel(br4_files))));
    end
    data_br4 = vertcat(data_br4{:});
end

% read info
fid = fopen([PathName filesep 'info' filesep 'Paris_x64 info.txt']);
info = {};
indic = 1;
while 1
     tline = fgetl(fid);
     if ~ischar(tline), 
         break
     end
     info{indic}=tline; 
     indic = indic + 1;
end
fclose(fid);
info = info';

% combine data
ParameterNames = [params_bi4_bur,params_bg4];
Data = [data_bi4_bur,data_bg4];
if exist('params_br4','var')
    ParameterNames = [ParameterNames, params_br4];
    if size(data_br4,1) < size(Data,1)
        data_br4(end+1:size(Data,1),:) = 0;
    elseif size(data_br4,1) > size(Data,1)
         data_br4 = data_br4(1:size(Data,1),:);
    end
    Data = [Data,data_br4];
end

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
    Data(:,end+1) = (Data(:,strcmp(ParameterNames,'Number of Photons (DA par)')) + Data(:,strcmp(ParameterNames,'Number of Photons (DA perp)')))./...
        (Data(:,strcmp(ParameterNames,'Number of Photons (DD par)')) + Data(:,strcmp(ParameterNames,'Number of Photons (DD perp)')) +...
         Data(:,strcmp(ParameterNames,'Number of Photons (DA par)')) + Data(:,strcmp(ParameterNames,'Number of Photons (DA perp)')));
end

if sum(strcmp(ParameterNames,'Proximity Ratio')) == 0
    ParameterNames{end+1} = 'Proximity Ratio';
    Data(:,end+1) = (Data(:,strcmp(ParameterNames,'Number of Photons (DA par)')) + Data(:,strcmp(ParameterNames,'Number of Photons (DA perp)')))./...
        (Data(:,strcmp(ParameterNames,'Number of Photons (DD par)')) + Data(:,strcmp(ParameterNames,'Number of Photons (DD perp)')) +...
         Data(:,strcmp(ParameterNames,'Number of Photons (DA par)')) + Data(:,strcmp(ParameterNames,'Number of Photons (DA perp)')));
end

% add missing acceptor information
if all(strcmp(ParameterNames,'Stoichiometry') == 0)
    ParameterNames{end+1} = 'Stoichiometry';
    ParameterNames{end+1} = 'Lifetime A [ns]';
    ParameterNames{end+1} = 'Anisotropy A';
    ParameterNames{end+1} = 'Number of Photons (AA)';
    ParameterNames{end+1} = 'Number of Photons (AA par)';
    ParameterNames{end+1} = 'Number of Photons (AA perp)';
    Data = [Data, zeros(size(Data,1),6)];
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
save([PathName filesep burst_data.FileName '.bur'],'BurstData');


function data = import_bi4_bur(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as a matrix.
%   data = IMPORTFILE(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   data = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows
%   STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   data = importfile('m997_0.bur', 2, 71);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2019/02/01 14:32:49

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end


%% Create output variable
data = raw;
