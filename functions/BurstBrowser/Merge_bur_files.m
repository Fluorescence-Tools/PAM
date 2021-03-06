%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Merge multiple *.bur file  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Merge_bur_files(~,~)
h = guidata(gcbo);
global UserValues

%%% Select files
Files = GetMultipleFiles({'*.bur','*.bur file'}, 'Choose a file', UserValues.File.BurstBrowserPath);

if size(Files,1) < 2
    m = msgbox('Select more than one file!');
    pause(1);
    delete(m);
    return;
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Merging files...');
%%% Load Files in CellArray
MergeData = cell(size(Files,1),1);
for i = 1:size(Files,1)
    MergeData{i} = load(fullfile(Files{i,2},Files{i,1}),'-mat');
    % burst analysis before December 16, 2015
    if ~isfield(MergeData{i}.BurstData, 'ClockPeriod')
        MergeData{i}.BurstData.ClockPeriod = MergeData{i}.BurstData.SyncPeriod;
        MergeData{i}.FileInfo.ClockPeriod = MergeData{i}.BurstData.FileInfo.SyncPeriod;
        if isfield(MergeData{i}.BurstData.FileInfo,'Card')
            if ~strcmp(MergeData{i}.BurstData.FileInfo.Card, 'SPC-140/150/830/130')
                %if SPC-630 is used, set the SyncPeriod to what it really is
                MergeData{i}.BurstData.SyncPeriod = 1/8E7*3;
                MergeData{i}.BurstData.FileInfo.SyncPeriod = 1/8E7*3;
                if rand < 0.05
                    msgbox('Be aware that the SyncPeriod is hardcoded. This message appears 1 out of 20 times.')
                end
            end
        end
    end
end

Progress(0.2,h.Progress_Axes,h.Progress_Text,'Merging files...');

%%% Create Arrays of Parameters
for i=1:numel(MergeData)
    MergedParameters.NameArray{i} = MergeData{i}.BurstData.NameArray;
    try
        MergedParameters.TACRange{i} = MergeData{i}.BurstData.TACRange;
    catch
        MergedParameters.TACRange{i} = MergeData{i}.BurstData.TACrange;
    end
    MergedParameters.BAMethod{i} = MergeData{i}.BurstData.BAMethod;
    MergedParameters.Filetype{i} = MergeData{i}.BurstData.Filetype;
    MergedParameters.SyncPeriod{i} = MergeData{i}.BurstData.SyncPeriod;
    MergedParameters.ClockPeriod{i} = MergeData{i}.BurstData.ClockPeriod;
    MergedParameters.FileInfo{i} = MergeData{i}.BurstData.FileInfo;
    MergedParameters.PIE{i} = MergeData{i}.BurstData.PIE;
    MergedParameters.IRF{i} = MergeData{i}.BurstData.IRF;
    MergedParameters.ScatterPattern{i} = MergeData{i}.BurstData.ScatterPattern;
    MergedParameters.Background{i} = MergeData{i}.BurstData.Background;
    MergedParameters.FileNameSPC{i} = MergeData{i}.BurstData.FileNameSPC;
    %%% use update path information
    MergedParameters.PathName{i} = fileparts(Files{i,1});
    MergedParameters.FileName{i} = Files{i,1};
    %MergedParameters.PathName{i} = MergeData{i}.BurstData.PathName;
    %MergedParameters.FileName{i} = MergeData{i}.BurstData.FileName;
    if isfield(MergeData{i}.BurstData,'Cut')
        MergedParameters.Cut{i} = MergeData{i}.BurstData.Cut;
    end
    if isfield(MergeData{i}.BurstData,'SpeciesNames')
        MergedParameters.SpeciesNames{i} = MergeData{i}.BurstData.SpeciesNames;
    end
    if isfield(MergeData{i}.BurstData,'SelectedSpecies')
        MergedParameters.SelectedSpecies{i} = MergeData{i}.BurstData.SelectedSpecies;
    end
    if isfield(MergeData{i}.BurstData,'Corrections')
        MergedParameters.Corrections{i} = MergeData{i}.BurstData.Corrections;
    end
end
%%% Use first file for general variables
Merged = MergeData{1}.BurstData;

Progress(0.2,h.Progress_Axes,h.Progress_Text,'Merging files...');

%%% Concatenate DataArray
for i =2:numel(MergeData)
    Merged.DataArray = [Merged.DataArray;MergeData{i}.BurstData.DataArray];
end

%%% Add a new parameter (file number);
Merged.NameArray{end+1} = 'File Number';
filenumber = [];
for i = 1:numel(MergeData)
    filenumber = [filenumber; i*ones(size(MergeData{i}.BurstData.DataArray,1),1)];
end
Merged.DataArray(:,end+1) = filenumber;

BurstData = Merged;
BurstData.MergedParameters = MergedParameters;

Progress(0.3,h.Progress_Axes,h.Progress_Text,'Merging files...');

%%% Also Load *.bps files and concatenate
MergeData = cell(size(Files,1),1);
for i = 1:size(Files,1)
    file = fullfile(Files{i,2},Files{i,1});
    MergeData{i} = load([file(1:end-3) 'bps'],'-mat');
end

Progress(0.4,h.Progress_Axes,h.Progress_Text,'Merging files...');

Macrotime = MergeData{1}.Macrotime;
Microtime = MergeData{1}.Microtime;
Channel = MergeData{1}.Channel;
for i = 2:numel(MergeData)
    Macrotime = vertcat(Macrotime,MergeData{i}.Macrotime);
    Microtime = vertcat(Microtime,MergeData{i}.Microtime);
    Channel = vertcat(Channel,MergeData{i}.Channel);
end

Progress(0.6,h.Progress_Axes,h.Progress_Text,'Saving merged file...');

%%% Save merged data
[FileName,PathName] = uiputfile({'*.bur','*.bur file'},'Choose a filename for the merged file',fileparts(Files{1,1}));
if FileName == 0
    m = msgbox('No valid filepath specified... Canceling');
    pause(1);
    delete(m);
    return;
end
BurstData.PathName = PathName;
BurstData.FileName = FileName;

filename = fullfile(BurstData.PathName,BurstData.FileName);
save(filename,'BurstData');
Progress(0.8,h.Progress_Axes,h.Progress_Text,'Saving merged file...');
save([filename(1:end-3) 'bps'],'Macrotime','Microtime','Channel');

Progress(1,h.Progress_Axes,h.Progress_Text);