function BurstWise_To_TimeWindow(~,~)
global BurstData BurstTCSPCData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));

file = BurstMeta.SelectedFile;
Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
%%% take whole array of photons
MT = BurstTCSPCData{file}.Macrotime;
CH = BurstTCSPCData{file}.Channel;
MI = BurstTCSPCData{file}.Microtime;

Progress(0,h.Progress_Axes,h.Progress_Text,'Exporting...');
%%% slice
Timebin = str2num(h.TimeBinPDAEdit.String);
for t = 1:numel(Timebin)
    timebin = Timebin(t);
    duration = timebin.*1E-3./BurstData{file}.ClockPeriod;
    PDA_Data = Bursts_to_Timebins(MT,CH,duration,MI,true); % PDAdata contains CH,MI,MT in cell array

    %%% reprocess all data (copied from PAM)
    Data_TimeWindow = Process_Bursts(PDA_Data(:,3),PDA_Data(:,1),BurstData{file}.ClockPeriod,BurstData{file}.BAMethod);
    %%% reprocess ALEX-2CDE filter
    switch BurstData{file}.BAMethod
        case {1,2,5,6}
            calc_2CDE = ~all(BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'ALEX 2CDE Filter'))==0);
        case {3,4}
            calc_2CDE = ~all(BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'ALEX 2CDE BG Filter'))==0);
    end
    if calc_2CDE
        Progress((t-1+0.25)/numel(Timebin),h.Progress_Axes,h.Progress_Text,'Exporting...');
        [ALEX_2CDE, FRET_2CDE] = NirFilter(PDA_Data(:,3),PDA_Data(:,1),BurstData{file}.nir_filter_parameter,BurstData{file}.ClockPeriod,BurstData{file}.BAMethod);
        % sort into array
        if any(BurstData{file}.BAMethod == [1,2,5,6]) %2 Color Data
            idx_ALEX2CDE = strcmp('ALEX 2CDE Filter',Data_TimeWindow.NameArray);
            idx_FRET2CDE = strcmp('FRET 2CDE Filter',Data_TimeWindow.NameArray);
            Data_TimeWindow.DataArray(:,idx_ALEX2CDE) = ALEX_2CDE;
            Data_TimeWindow.DataArray(:,idx_FRET2CDE) = FRET_2CDE;
        elseif any(BurstData{file}.BAMethod == [3,4]) %3 Color Data
            idx_ALEX2CDE = find(strcmp('ALEX 2CDE BG Filter',Data_TimeWindow.NameArray));
            idx_FRET2CDE = find(strcmp('FRET 2CDE BG Filter',Data_TimeWindow.NameArray));
            Data_TimeWindow.DataArray(:,idx_ALEX2CDE:(idx_ALEX2CDE+2)) = ALEX_2CDE;
            Data_TimeWindow.DataArray(:,idx_FRET2CDE:(idx_FRET2CDE+2)) = FRET_2CDE;
        end
    end
    Progress((t-1+0.5)/numel(Timebin),h.Progress_Axes,h.Progress_Text,'Exporting...');
    %%% ToDo: Add refitting of lifetime
    %%% for now, this requires re-fitting the lifetime through PAM

    %%% copy all information from parent BurstData
    BurstData_TimeWindow = BurstData{file};
    % copy BurstData.DataArray, keeping original size of array in parent file
    BurstData_TimeWindow.DataArray = NaN(size(Data_TimeWindow.DataArray));
    for f = 1:numel(Data_TimeWindow.NameArray)
        ix = find(strcmp(BurstData_TimeWindow.NameArray,Data_TimeWindow.NameArray{f}));
        if ~isempty(ix)
            BurstData_TimeWindow.DataArray(:,ix) = Data_TimeWindow.DataArray(:,f);
        end
    end

    %% Re-save
    %%% BurstData
    fn = [BurstData{file}.FileName(1:end-4) '_' num2str(timebin) 'ms.bur'];
    BurstData_TimeWindow.FileName = fn;
    clear BurstData % clear BurstData from this function's workspace for the saving step
    BurstData = BurstData_TimeWindow;
    save(fullfile(BurstData.PathName,fn),'BurstData');

    % ToDo: copy info file as well
    Progress((t-1+0.75)/numel(Timebin),h.Progress_Axes,h.Progress_Text,'Exporting...');
    %%% Save the full Photon Information in an external file
    %%% that can be loaded at a later timepoint
    PhotonsFileName = [fn(1:end-3) 'bps']; %%% .bps is burst-photon-stream
    Macrotime = cellfun(@uint64,PDA_Data(:,3),'UniformOutput',false);
    Microtime = cellfun(@uint16,PDA_Data(:,2),'UniformOutput',false);
    Channel = cellfun(@uint8,PDA_Data(:,1),'UniformOutput',false);

    %%% set file size warning on saving to be an error so we can catch it
    warning('error','MATLAB:save:sizeTooBigForMATFile');
    try
        save(fullfile(BurstData.PathName,PhotonsFileName),'Macrotime','Microtime','Channel','-v7');
    catch
        %%% error means the file size exceeds the 2GB limit of save -v7
        %%% we have to use -v7.3 version, which can save larger files
        %%% however, -v7.3 produces very large files out of cell arrays, so it
        %%% is really not an optimal solution...
        save(fullfile(BurstData.PathName,PhotonsFileName),'Macrotime','Microtime','Channel','-v7.3');
    end
    %%% change the warning back to NOT raise an error
    warning('on','MATLAB:save:sizeTooBigForMATFile');
    clear BurstData % redeclare the global variable
    global BurstData  %#ok<TLEV>
    Progress(t/numel(Timebin),h.Progress_Axes,h.Progress_Text,'Exporting...');
end
Progress(1,h.Progress_Axes,h.Progress_Text);