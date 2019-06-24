function LoadTcspc(~,~,Update_Data,Update_Display,Shift_Detector,Update_Detector_Channels,Caller,FileName,Type)
global UserValues TcspcData FileInfo PamMeta PathToApp
if isempty(PathToApp)
    GetAppFolder();
end
if nargin<9 %%% Opens Dialog box for selecting new files to be loaded
    %%% following code is for remembering the last used FileType
    LSUserValues(0);    
    %%% Loads all possible file types
    Filetypes = UserValues.File.SPC_FileTypes;
    
    if strcmp(Caller.Name(1:3),'PAM')
        h=guidata(Caller);
        if h.Profiles.Filetype.Value>1
            Custom = str2func(h.Profiles.Filetype.String{h.Profiles.Filetype.Value});
            [Custom_Suffix, Custom_Description] = feval(Custom);
            Filetypes{end+1,1} = Custom_Suffix;
            Filetypes{end,2} = Custom_Description;
        end
    end
    
    
    
    %%% Finds last used file type
    Lastfile = UserValues.File.OpenTCSPC_FilterIndex;
    if isempty(Lastfile) || numel(Lastfile)~=1 || ~isnumeric(Lastfile) || isnan(Lastfile) ||  Lastfile <1  || Lastfile > size(Filetypes,1)
        Lastfile = 1;
    end
    %%% Puts last uses file type to front
    Fileorder = 1:size(Filetypes,1);
    Fileorder = [Lastfile, Fileorder(Fileorder~=Lastfile)];
    Filetypes = Filetypes(Fileorder,:);   
    %%% Choose file to be loaded
    [FileName, Path, Type] = uigetfile(Filetypes, 'Choose a TCSPC data file',UserValues.File.Path,'MultiSelect', 'on');   
    %%% Determines actually selected file type
    if Type~=0
        Type = Fileorder(Type);
    end

else %%% Loads predefined Files
    Path = UserValues.File.Path;
end
%%% Only execues if any file was selected
if ~iscell(FileName) && all(FileName==0)
    return
end
%%% Save the selected file type
UserValues.File.OpenTCSPC_FilterIndex = Type;
%%% Transforms FileName into cell, if it is not already
%%%(e.g. when only one file was selected)
if ~iscell(FileName)
    FileName = {FileName};
end
%%% Saves Path
UserValues.File.Path = Path;
LSUserValues(1);

%%% Sorts '*0.spc' files (Fabsurf) by chronological order
if all(~cellfun('isempty', regexp(FileName, '_0.spc$')))
    for i = 1 : numel(FileName)
        FileProperty(i) = dir(strcat(Path, FileName{i}));
    end
    %%% Sorts based on date and time modified
    [datenum, index] = sort([FileProperty.datenum]);
    FileName = FileName(index);
else
%%% Sorts files of other types by alphabetical order
    FileName=sort(FileName);
end

%%% Clears previously loaded data
FileInfo=[];
TcspcData.MT=cell(1,1);
TcspcData.MI=cell(1,1);

%%% Findes handles for progress axes and text
if strcmp(Caller.Tag, 'Pam')
    h=guidata(Caller);
    %%% Add files to database
    if ~isfield(PamMeta, 'Database')
        %create database
        PamMeta.Database = cell(0,3);
    end
    %%% add new files to database
    
    %%% check if file already exists in database, if yes, remove
    if ~isempty(PamMeta.Database)
        for i = 1:numel(FileName)
            if (sum(strcmp(FileName{i},PamMeta.Database(:,1))) > 0) && (sum(strcmp(Path,PamMeta.Database(:,2))) > 0) %%% same filename/path
                pos = find(strcmp(FileName{i},PamMeta.Database(:,1)) & strcmp(Path,PamMeta.Database(:,2)));
                del = false(size(pos));
                for p = 1:numel(pos)
                    % check if filetype is also the same
                    if Type == PamMeta.Database{pos(p),3}
                        del(pos(p)) = true;
                    end
                end
                PamMeta.Database(del,:) = []; % remove old file listing
            end
        end
    end
    for i = 1:numel(FileName) %%% update global variable
        PamMeta.Database = [{FileName{i},Path,Type}; PamMeta.Database];
    end
    h.Database.List.String = [];
    for i = 1:size(PamMeta.Database,1) %%% update file list
        h.Database.List.String = [{[PamMeta.Database{size(PamMeta.Database,1)-i+1,1} ' (path:' PamMeta.Database{size(PamMeta.Database,1)-i+1,2} ')']}; h.Database.List.String];
    end
    if size(PamMeta.Database,1) > 20
        PamMeta.Database = PamMeta.Database(1:20,:);
        h.Database.List.String = h.Database.List.String(1:20);
    end
    % store file history in UserValues
    UserValues.File.FileHistory.PAM = PamMeta.Database;
else %%% Creates empty struct, if it was called outside of PAM
    h.Progress.Axes = [];
    h.Progress.Text = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Checks which file type was selected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch (Type)
    case {1, 2} %%% .spc Files generated with native B&H program
        %%% 1: '*_m1.spc', 'Multi-card B&H SPC files recorded with B&H-Software (*_m1.spc)'
        %%% 2: '*.spc',    'Single card B&H SPC files recorded with B&H-Software (*.spc)'
        %%% Usually, here no Imaging Information is needed
        FileInfo.FileType = 'SPC';
        %%% General FileInfo
        FileInfo.NumberOfFiles = numel(FileName);
        FileInfo.Type = Type;
        FileInfo.MeasurementTime = [];
        FileInfo.ImageTimes = [];
        FileInfo.SyncPeriod = [];
        FileInfo.ClockPeriod = [];
        FileInfo.TACRange = []; %in seconds
        FileInfo.Lines = [];
        FileInfo.LineTimes = [];
        FileInfo.Pixels = [];
        FileInfo.PixTime = [];
        FileInfo.ScanFreq = 1000;
        FileInfo.FileName = FileName;
        FileInfo.Path = Path;
        
        %%% Initializes microtime and macotime arrays
        if strcmp(UserValues.Detector.Auto,'off')
            TcspcData.MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            TcspcData.MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
        else
            TcspcData.MT=cell(10,10); %%% default to 10 channels
            TcspcData.MI=cell(10,10); %%% default to 10 channels
        end
        
        %%% Initialize .set file parameters
        MI_Bins = [];
        Card = [];
        TACRange = [];
        TACGain = [];
        Corrupt = false;
        Pixel = [];
        Lines = [];
        MaxMT = 0;
        %%% Reads all selected files
        for i=1:numel(FileName)
            %%% there are a number of *_m(i).spc files associated with the
            %%% *_m1.spc file
            
            %%% Read .set file
            fid = fopen(fullfile(Path, [FileName{1}(1:end-3) 'set']), 'r');
            ask_syncrate = false;
            if fid~=-1 %%% .set file exists
                Collection_Time=[];
                %%% Reads file line by line till all parameters are found
                while (isempty(MI_Bins) || isempty(Card) || isempty(TACRange) || isempty(TACGain) || isempty(Collection_Time) || isempty(Pixel) || isempty(Lines)) && ~Corrupt
                    Line = fgetl(fid);
                    %%% Determines SPC card type
                    if isempty(Card)
                        Card = strfind(Line, 'with module SPC-');
                        if ~isempty(Card)
                            Card = Line(18:20);
                        end
                    end
                    %%% Determines number of microtime bin
                    if isempty(MI_Bins)
                        MI_Bins = strfind(Line, 'SP_ADC_RE');
                        if ~isempty(MI_Bins)
                            MI_Bins = str2double(Line(20:end-1));
                        end
                    end
                    %%% Determines TAC range
                    if isempty(TACRange)
                        TACRange = strfind(Line, 'SP_TAC_R');
                        if ~isempty(TACRange)
                            TACRange = str2double(Line(19:end-1));
                        end
                    end
                    %%% Determines TAC gain
                    if isempty(TACGain)
                        TACGain = strfind(Line, 'SP_TAC_G');
                        if ~isempty(TACGain)
                            TACGain = str2double(Line(19:end-1));
                        end
                    end
                    %%% Determines Measurement Length
                    if isempty(Collection_Time)
                        Collection_Time = strfind(Line, 'SP_COL_T');
                        if ~isempty(Collection_Time)
                            Collection_Time = str2double(Line(19:end-1));
                        end
                    end
                    %%% Determines Lines and Pixels
                    if isempty(Pixel)
                        Pixel = strfind(Line, 'SP_IMG_X');
                        if ~isempty(Pixel)
                            Pixel = str2double(Line(19:end-1));
                        end
                    end
                    if isempty(Lines)
                        Lines = strfind(Line, 'SP_IMG_Y');
                        if ~isempty(Lines)
                            Lines = str2double(Line(19:end-1));
                        end
                    end
                    %%% Stops, if end of file is reached
                    if ~isempty(Line) && all(Line==-1)
                        Corrupt = true;
                    end
                end
                fclose(fid);
                if ~Corrupt %%% .set file was complete
                    %%% Determines exact .spc filetype to read
                    if (strcmp(Card,'140') || strcmp(Card,'150') || strcmp(Card,'130'))
                        Card = 'SPC-140/150/130';
                    elseif strcmp(Card,'630')
                        if MI_Bins == 256
                            Card = 'SPC-630 256chs';
                        elseif MI_Bins == 4096
                            Card = 'SPC-630 4096chs';
                        end
                    elseif strcmp(Card,'830')
                        Card = 'SPC-830';
                    end
                    %%% Determines real TAC range
                    FileInfo.TACRange = TACRange/TACGain;
                else %%% No .set file was found; use standard settings
                    h = msgbox('Setup (.set) file not found!');
                    Scanner = [0 0 0];
                    Card = 'SPC-140/150/130';
                    MI_Bins = [];
                    TACRange = [];
                    Collection_Time = NaN;
                    pause(1)
                    close(h)
                    Lines = NaN;
                    Pixel = NaN;
                end
                
            else %if there is no set file, the B&H software was likely not used
                disp(sprintf('Setup (.set) file not found for file %d of %d!',i,numel(FileName)));
                Card = 'SPC-140/150/130';
                MI_Bins = [];
                TACRange = [];
                Collection_Time = NaN;
                Pixel = NaN;
                Lines = NaN;
                ask_syncrate = true;
                if i == numel(FileName) && isempty(TACRange)
                    %%% ask for TAC range in nanoseconds
                    TACRange = inputdlg('Please specify the TAC range in nanoseconds:',...
                        'Setup (.set) file not found!',...
                        1,{num2str(UserValues.Settings.Pam.DefaultTACRange*1E9)},'on');
                    if isempty(TACRange)
                        disp(sprintf('No answer given. Setting previous TAC range of %.2f ns.',1E9*UserValues.Settings.Pam.DefaultTACRange));
                        TACRange = {num2str(UserValues.Settings.Pam.DefaultTACRange*1E9)};
                    end
                    TACRange = 1E-9*str2num(TACRange{1});
                    if ~isfinite(TACRange) | isempty(TACRange)
                        disp('Invalid answer given. Setting default TAC range of 40 ns.');
                        TACRange = 40E-9;
                    end
                    UserValues.Settings.Pam.DefaultTACRange = TACRange;
                    FileInfo.TACRange = TACRange;
                end
            end
            
            
            %%% Checks, which cards to load
            if strcmp(UserValues.Detector.Auto,'off')
                card = unique(UserValues.Detector.Det);
            else
                card = 1:10; %%% consider up to 10 detection channels
            end
            %%% check for disabled detectors
            for j = card
                if sum(UserValues.Detector.Det==j) > 0
                    if all(strcmp(UserValues.Detector.enabled(UserValues.Detector.Det==j),'off'))
                        card(card==j) = [];
                    end
                end
            end
            %%% Checks, which and how many card exist for each file
            if Type == 1
                for j = card;
                    if ~exist(fullfile(Path,[FileName{i}(1:end-5) num2str(j) '.spc']),'file')
                        card(card==j)=[];
                    end
                end
            else
                card = 1;
            end
            
            Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,'Loading:');
            
            %%% if multiple files are loaded, consecutive files need to
            %%% be offset in time with respect to the previous file
            %%% Reads data for each tcspc card
            for j = card
                %%% Update Progress
                Progress((i-1)/numel(FileName)+(j-1)/numel(card)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str((i-1)*numel(card)+j) ' of ' num2str(numel(FileName)*numel(card))]);
                %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
                if Type == 1
                    FileName{i} = [FileName{i}(1:end-5) num2str(j) '.spc'];
                end
                
                [MT, MI, Header] = Read_BH(fullfile(Path,FileName{i}), Inf, Card);
                
                %%% extracts SyncPeriod and ClockPeriod from Data
                if isempty(FileInfo.SyncPeriod)
                    FileInfo.SyncPeriod = Header.SyncRate^-1;
                end
                if isempty(FileInfo.ClockPeriod)
                    FileInfo.ClockPeriod = Header.ClockRate^-1;
                end
                
                %%% Extracts frame starts from frame-syncs or makes a single frame
                if ~isempty(Header.FrameMarker) %%% Use FrameMarkers
                    FileInfo.ImageTimes = [FileInfo.ImageTimes Header.FrameMarker*FileInfo.ClockPeriod];
                    NoF=numel(Header.FrameMarker);
                else
                    NoF=1;
                end
                %%% Extracts line starts from frame-syncs
                if ~isempty(Header.LineMarker) %%% Use LineMarkers
                    FileInfo.LineTimes = [FileInfo.LineTimes; MaxMT+permute(reshape(Header.LineMarker*FileInfo.ClockPeriod,[],NoF),[2 1])];
                end
                %%% Extracts number of pixels per line 
                if ~isempty(Header.PixelMarker) %%% Use PixelsMarkers for the numper of Pixels
                    if mode(numel(Header.PixelMarker)/numel(Header.LineMarker),1)==0 %%% Divide pixels evenly to lines
                       FileInfo.Pixels = numel(Header.PixelMarker)/numel(Header.LineMarker);
                    else %%% Approximate pixels by average dwell time
                       FileInfo.Pixels = round(mean(diff(Header.LineMarker))/mean(diff(Header.PixelMarker)));
                    end
                elseif ~isnan(Pixel) %%% Use Pixels given in .set file
                    FileInfo.Pixels = Pixel;
                else %%% Set number of  pixels to number of lines after readin
                    FileInfo.Pixels = NaN;
                end
                
                
                %%% Finds, which routing bits to use
                if strcmp(UserValues.Detector.Auto,'off')
                    Rout = unique(UserValues.Detector.Rout(UserValues.Detector.Det==j));
                else
                    Rout = 1:10; %%% consider up to 10 routing channels
                end
                Rout(Rout>numel(MI))=[];
                
                %%% check for disabled routing bits
                for r = Rout
                    if sum((UserValues.Detector.Det==j)&(UserValues.Detector.Rout == r)) > 0
                        if all(strcmp(UserValues.Detector.enabled((UserValues.Detector.Det==j)&(UserValues.Detector.Rout == r)),'off'))
                            Rout(Rout==r) = [];
                        end
                    end
                end
                
                %%% Concaternates data to previous files and adds ImageTimes
                %%% to consecutive files
                if any(~cellfun(@isempty,MI(:)))
                    for k=Rout
                        TcspcData.MT{j,k}=[TcspcData.MT{j,k}; MaxMT + MT{k}];   MT{k}=[];
                        TcspcData.MI{j,k}=[TcspcData.MI{j,k}; MI{k}];   MI{k}=[];
                    end
                end
                %%% Determines last photon for each file
                for k=find(~cellfun(@isempty,TcspcData.MT(j,:)));
                    FileInfo.LastPhoton{j,k}(i)=numel(TcspcData.MT{j,k});
                end
            end
            
            if numel(FileInfo.ImageTimes)<i %%% Adds a new frame entry, if none was set
                FileInfo.ImageTimes(end+1) = MaxMT*FileInfo.ClockPeriod;
            end
            %%% Reads the measurement time from .set file or uses the
            %%% last Photon of the file
            if isempty(Collection_Time) || isnan(Collection_Time) || isinf (Collection_Time) || Collection_Time==0 ||...
                strcmp(Card,'SPC-630 256chs') || strcmp(Card,'SPC-630 4096chs') %%% Collection_Time was not set properly or SPC-630 was used (cannot write measurement time) 
                if  ~isempty(FileInfo.LineTimes) %%% Extrapolate frame end from lines markers
                    MaxMT = MaxMT + (mean2(diff(FileInfo.LineTimes,2))+FileInfo.LineTimes(end))/FileInfo.ClockPeriod;
                elseif any(~cellfun(@isempty,TcspcData.MT(:))) %%% use last photon as fram stop
                    MaxMT = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))));
                end
            elseif (numel(FileInfo.ImageTimes) > 1) && ((FileInfo.ImageTimes(end)> Collection_Time) || (Collection_Time > 1.05*(max(diff(FileInfo.ImageTimes)))))
                %%% Collection_Time was set, but it is obviously wrong
                MaxMT = MaxMT + (mean2(diff(FileInfo.ImageTimes))+FileInfo.ImageTimes(end))/FileInfo.ClockPeriod;
            else %%% Collection_Time is correct
                %%% check if the user canceled before end of measurement
                %   determine collection time as calculated from last photon
                Collection_Time_SPC = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT)))); 
                if (Collection_Time_SPC*FileInfo.ClockPeriod./Collection_Time) < 0.95 % User canceled earlier than 95% of the measurement time
                    MaxMT = MaxMT + Collection_Time_SPC;
                else % take the saved collection time from B&H software
                    MaxMT = MaxMT +ceil(Collection_Time/FileInfo.ClockPeriod);
                end
            end

        end
        %%% check for case where the first record was NOT the sync period
        %%% (i.e. for Seidel simulated spc data)
        %%% if there was no set file, this is likely the case
        if ask_syncrate
            %%% if the sync period was less than 1 MHz, this is probably
            %%% the case
            %%% ask for TAC range in nanoseconds
            syncrate = inputdlg('Please specify the laser frequency in MHz:',...
                'No set file found.',...
                1,{num2str(UserValues.Settings.Pam.DefaultSyncRate*1E-6)},'on');
            if isempty(syncrate)
                disp(sprintf('No answer given. Keeping the previously read-out rate of %.2f MHz.',1E-6*UserValues.Settings.Pam.DefaultSyncRate));
                syncrate = {num2str(1E-6*UserValues.Settings.Pam.DefaultSyncRate)};
            end
            syncrate = 1E6*str2num(syncrate{1});
            if ~isfinite(syncrate) || isempty(syncrate)
                disp(sprintf('Invalid answer given. Keeping the read-out rate of %.2f MHz.',1./FileInfo.SyncPeriod));
            else
                FileInfo.SyncPeriod = 1./syncrate;
                FileInfo.ClockPeriod = FileInfo.SyncPeriod;
                UserValues.Settings.Pam.DefaultSyncRate = syncrate;
            end        
        end
        
        
        FileInfo.MeasurementTime = MaxMT*FileInfo.ClockPeriod;
        FileInfo.ImageTimes(end+1) = FileInfo.MeasurementTime;
        
        if isempty(FileInfo.LineTimes) && ~isnan(Lines) && Lines>1 %%% Use Lines from .set file
            for i=1:(numel(FileInfo.ImageTimes)-1)
                FileInfo.LineTimes(i,:) = linspace(FileInfo.ImageTimes(i),FileInfo.ImageTimes(i+1),Lines+1);
            end
            FileInfo.Lines = Lines;
            if isnan(Pixel) || Pixel<2
               FileInfo.Pixels =  Lines;
            end
            
        elseif isempty(FileInfo.LineTimes) && (isnan(Lines) || Lines<2)
            for i=1:(numel(FileInfo.ImageTimes)-1)
                FileInfo.LineTimes(i,:) = linspace(FileInfo.ImageTimes(i),FileInfo.ImageTimes(i+1),11);
            end
            FileInfo.Lines = 10;
            FileInfo.Pixels = 10;
        else
           
            % There are different schemes possible:
            
            % 1. Start for each line = linetimes
            % => end of the last line is the frame start of the following
            % frame
            FileInfo.LineTimes(:,(end+1)) = FileInfo.ImageTimes(2:end);
            
            % 2. Start of each line = famestart and linetimes
            % => first linestart is the frame start
            % FileInfo.LineTimes = [FileInfo.ImageTimes(1:(end-1))
            %                       FileInfo.LineTimes
            %                       FileInfo.ImageTimes(2:end)]
            
            % 3. End of each line = lineend
            % FileInfo.LineTimes = [FileInfo.ImageTimes(1:(end-1))
            %                       FileInfo.LineTimes]
            
            FileInfo.Lines = size(FileInfo.LineTimes,2)-1;
            if isnan(FileInfo.Pixels)
                FileInfo.Pixels = FileInfo.Lines;
            end
        end
        
        if ~isempty(FileInfo.ImageTimes) && ~isempty(FileInfo.Lines)
            FileInfo.PixTime = mean(diff(FileInfo.ImageTimes))./FileInfo.Lines^2;
            FileInfo.Frames = size(FileInfo.ImageTimes,1);
        end
        
        if ~isempty(MI_Bins) && MI_Bins>1 %%% Sets number of MI bins to value from .set file (or fixed)
            FileInfo.MI_Bins = MI_Bins;
        else %%% Reads highest used MI and usen 2^n bins
            usedMI = double(max(cellfun(@max,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)))));
            FileInfo.MI_Bins = 2^(ceil(log2(usedMI)));
        end
        
        if isempty(FileInfo.TACRange)
            %%% try to read the TACrange from SyncPeriod and number of used
            %%% MIBins
            usedMI = max(cellfun(@numel,cellfun(@unique,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)),'UniformOutput',false)));
            FileInfo.TACRange = (FileInfo.SyncPeriod/usedMI)*FileInfo.MI_Bins;
        end
        FileInfo.Card = Card;
    case {3} %%3 : *.ht3 files from HydraHarp400
        %%% Usually, here no Imaging Information is needed
        FileInfo.FileType = 'HydraHarp';
        %%% General FileInfo
        FileInfo.NumberOfFiles=numel(FileName);
        FileInfo.Type=Type;
        FileInfo.MI_Bins=[];
        FileInfo.MeasurementTime=[];
        FileInfo.ImageTimes = [];
        FileInfo.SyncPeriod= [];
        FileInfo.ClockPeriod= [];
        FileInfo.Resolution = [];
        FileInfo.TACRange = [];
        FileInfo.Lines=10;
        FileInfo.LineTimes=[];
        FileInfo.Pixels=10;
        FileInfo.ScanFreq=1000;
        FileInfo.FileName=FileName;
        FileInfo.Path=Path;
        
        %%% Initializes microtime and macotime arrays
        if strcmp(UserValues.Detector.Auto,'off')
            TcspcData.MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            TcspcData.MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
        else
            TcspcData.MT=cell(10,10); %%% default to 10 channels
            TcspcData.MI=cell(10,10); %%% default to 10 channels
        end
        
        %%% Checks, which detectors to load
        if strcmp(UserValues.Detector.Auto,'off')
            card = unique(UserValues.Detector.Det);
        else
            card = 1:10; %%% consider up to 10 detection channels
        end
        %%% check for disabled detectors
        for j = card
            if sum(UserValues.Detector.Det==j) > 0
                if all(strcmp(UserValues.Detector.enabled(UserValues.Detector.Det==j),'off'))
                    card(card==j) = [];
                end
            end
        end
        
        %%% Reads all selected files
        for i=1:numel(FileName)
            Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str(i) ' of ' num2str(numel(FileName))]);
            
            %%% if multiple files are loaded, consecutive files need to
            %%% be offset in time with respect to the previous file
            MaxMT = 0;
            if any(~cellfun(@isempty,TcspcData.MT(:)))
                MaxMT = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))));
            end
            
            %%% Update Progress
            Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str(i-1) ' of ' num2str(numel(FileName))]);
            %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
            [MT, MI, SyncRate, Resolution] = Read_HT3(fullfile(Path,FileName{i}),Inf,h.Progress.Axes,h.Progress.Text,i,numel(FileName),1,h.MT.Use_Chunkwise_Read_In.Value);
            
            if isempty(FileInfo.SyncPeriod)
                FileInfo.SyncPeriod = 1/SyncRate;
            end
            if isempty(FileInfo.ClockPeriod)
                FileInfo.ClockPeriod = 1/SyncRate;
            end
            if isempty(FileInfo.Resolution)
                FileInfo.Resolution = Resolution;
            end
   
            %%% Concatenates data to previous files and adds ImageTimes
            %%% to consecutive files
            if any(~cellfun(@isempty,MI(:)))
                for j = card
                    %%% Finds, which routing bits to use
                    if strcmp(UserValues.Detector.Auto,'off')
                        Rout = unique(UserValues.Detector.Rout(UserValues.Detector.Det==j));
                    else
                        Rout = 1:10; %%% consider up to 10 routing channels
                    end
                    Rout(Rout>size(MI,2))=[];
                    
                    %%% check for disabled routing bits
                    for r = Rout
                        if sum((UserValues.Detector.Det==j)&(UserValues.Detector.Rout == r)) > 0
                            if all(strcmp(UserValues.Detector.enabled((UserValues.Detector.Det==j)&(UserValues.Detector.Rout == r)),'off'))
                                Rout(Rout==r) = [];
                            end
                        end
                    end
            
                    for k=Rout
                        TcspcData.MT{j,k}=[TcspcData.MT{j,k}; MaxMT + MT{j,k}];   MT{j,k}=[];
                        TcspcData.MI{j,k}=[TcspcData.MI{j,k}; MI{j,k}];   MI{j,k}=[];
                    end
                end
            end
            %%% Determines last photon for each file
            for k=find(~cellfun(@isempty,TcspcData.MT(j,:)));
                FileInfo.LastPhoton{j,k}(i)=numel(TcspcData.MT{j,k});
            end
            
        end
        FileInfo.MeasurementTime = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))))*FileInfo.ClockPeriod;
        FileInfo.LineTimes = linspace(0, FileInfo.MeasurementTime,i+1);
        FileInfo.ImageTimes = linspace(0,FileInfo.MeasurementTime,i+1);
        FileInfo.LineTimes  = repmat(reshape(linspace(0,FileInfo.ImageTimes(2),11),1,[]),[numel(FileInfo.ImageTimes)-1,1]);
        for i=2:size(FileInfo.LineTimes,1)
            FileInfo.LineTimes(i,:)=FileInfo.LineTimes(i,:)+FileInfo.ImageTimes(i);
        end
        FileInfo.MI_Bins = double(max(cellfun(@max,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)))));
        FileInfo.TACRange = FileInfo.SyncPeriod;
    case 4 %%% Pam Simulation Files
        FileInfo.FileType = 'Simulation';
        %%% Reads info file generated by Fabsurf
        FileInfo.Fabsurf=[];
        %%% General FileInfo
        FileInfo.NumberOfFiles=numel(FileName);
        FileInfo.Type=Type;
        FileInfo.FileName=FileName;
        FileInfo.Path=Path;   
        %%% Initializes microtime and macotime arrays
        if strcmp(UserValues.Detector.Auto,'off')
            TcspcData.MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            TcspcData.MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            Det = UserValues.Detector.Det;
            Rout = UserValues.Detector.Rout;
        else
            TcspcData.MT=cell(10,10); %%% default to 10 channels
            TcspcData.MI=cell(10,10); %%% default to 10 channels
            Det = 1:10;
            Rout = ones(10,1);
        end
        FileInfo.LineTimes = [];
        Totaltime=0;
        %%% Reads all selected files
        for i=1:numel(FileName)
            load(fullfile(Path,FileName{i}),'-mat','Header');
            FileInfo.SyncPeriod = 1/Header.Freq;
            FileInfo.ClockPeriod = 1/Header.Freq;
            FileInfo.ImageTimes = (0:Header.FrameTime:(Header.Frames*Header.FrameTime))/Header.Freq;
            FileInfo.Lines = Header.Lines;
            FileInfo.Pixels = FileInfo.Lines;
            FileInfo.ScanFreq = FileInfo.Lines/min(diff(FileInfo.ImageTimes));
            FileInfo.TACRange = Header.Info.General.MIRange*1E-9;
            FileInfo.MI_Bins = Header.MI_Bins;
            load(fullfile(Path,FileName{i}),'-mat','Sim_Photons');
            
            %%% if multiple files are loaded, consecutive files need to
            %%% be offset in time with respect to the previous file
            MaxMT = 0;
            if any(sum(~cellfun(@isempty,TcspcData.MT),2))
                MaxMT = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))));
            end
            
            for j = 1:size(Sim_Photons,1)               
                if any(Rout(Det == j) == 1)
                    %if (i == 1 && j == 5) || (i == 2 && j == 1) % this option can be used to load file 1 in the parallel channel and file 2 in the perpendicular channel, for when you simulated data with 2 IRF widths.
                        TcspcData.MT{j,1} = [TcspcData.MT{j,1}; MaxMT + double(Sim_Photons{j,1})];
                        Sim_Photons{j,1} = []; %%% Removes photons to reduce data duplication
                        TcspcData.MI{j,1} = [TcspcData.MI{j,1}; Sim_Photons{j,2}];
                        Sim_Photons{j,2} = []; %%% Removes photons to reduce data duplication
                    %end
               end
            end            
            for j = 1:Header.Frames
                FileInfo.LineTimes(end+1,:)=linspace(0,Header.FrameTime,FileInfo.Lines+1)+Totaltime;
                Totaltime = Totaltime + Header.FrameTime;
            end            
        end  
        FileInfo.MeasurementTime = Totaltime/Header.Freq;
        FileInfo.LineTimes = FileInfo.LineTimes/Header.Freq;
        FileInfo.HeaderSim = Header;
    case 5 %%% Pam Photon File
        if strcmp(UserValues.Detector.Auto,'off')
            TcspcData.MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            TcspcData.MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
        else
            TcspcData.MT=cell(10,10); %%% default to 10 channels
            TcspcData.MI=cell(10,10); %%% default to 10 channels
        end
        Loaded = load(fullfile(Path,FileName{1}),'-mat');
        FileInfo = Loaded.Info;
        if isempty(FileInfo.ClockPeriod)
            FileInfo.ClockPeriod = FileInfo.SyncPeriod;
        end
        FileInfo.Path = Path;
        TcspcData.MT(1:size(Loaded.MT,1),1:size(Loaded.MT,2)) = Loaded.MT;
        TcspcData.MI(1:size(Loaded.MT,1),1:size(Loaded.MT,2)) = Loaded.MI;
        for i = 2:numel(FileName)
            Loaded = load(fullfile(Path,FileName{i}),'-mat');
            for j=1:size(Loaded.MT,1)
                for k=1:size(Loaded.MT,2)
                    TcspcData.MT{j,k} = [TcspcData.MT{j,k}; (Loaded.MT{j,k} + FileInfo.MeasurementTime/FileInfo.ClockPeriod)];
                    TcspcData.MI{j,k} = [TcspcData.MI{j,k}; Loaded.MI{j,k}];
                end
            end
            FileInfo.LineTimes(end+(1:size(Loaded.Info.LineTimes,1)),end+(1:size(Loaded.Info.LineTimes,2))) = Loaded.Info.LineTimes + FileInfo.MeasurementTime/FileInfo.ClockPeriod;
            FileInfo.MeasurementTime = FileInfo.MeasurementTime + Loaded.Info.MeasurementTime;
            FileInfo.NumberOfFiles = FileInfo.NumberOfFiles + Loaded.Info.NumberOfFiles;
        end
        FileInfo.FileName = FileName;
    case 6 %%% .PTU files from HydraHarp Software V3.0
        %%% Usually, here no Imaging Information is needed
        FileInfo.FileType = 'HydraHarp';
        %%% General FileInfo
        FileInfo.NumberOfFiles=numel(FileName);
        FileInfo.Type=Type;
        FileInfo.MI_Bins=[];
        FileInfo.MeasurementTime=[];
        FileInfo.ImageTimes = [];
        FileInfo.SyncPeriod = [];
        FileInfo.ClockPeriod = [];
        FileInfo.Resolution = [];
        FileInfo.TACRange = [];
        FileInfo.Lines=10;
        FileInfo.Pixels=10;
        FileInfo.LineTimes=[];
        FileInfo.LineStops=[];
        FileInfo.ScanFreq=1000;
        FileInfo.FileName=FileName;
        FileInfo.Path=Path;
        FileInfo.Frames=0;
        
        %%% Initializes microtime and macotime arrays
        if strcmp(UserValues.Detector.Auto,'off')
           TcspcData.MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
           TcspcData.MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
        else
            TcspcData.MT=cell(10,10); %%% default to 10 channels
            TcspcData.MI=cell(10,10); %%% default to 10 channels
        end
        %%% Checks, which detectors to load
        if strcmp(UserValues.Detector.Auto,'off')
            card = unique(UserValues.Detector.Det);
        else
            card = 1:10; %%% consider up to 10 detection channels
        end
        %%% check for disabled detectors
        for j = card
            if sum(UserValues.Detector.Det==j) > 0
                if all(strcmp(UserValues.Detector.enabled(UserValues.Detector.Det==j),'off'))
                    card(card==j) = [];
                end
            end
        end
        %%% Reads all selected files
        for i=1:numel(FileName)
            MaxMT = 0;
            if any(~cellfun(@isempty,TcspcData.MT(:)))
                MaxMT = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))));
            end
            Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str(i) ' of ' num2str(numel(FileName))]);
            
            %%% Update Progress
            Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str(i-1) ' of ' num2str(numel(FileName))]);
            %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
            
            [MT, MI, Header] = Read_PTU(fullfile(Path,FileName{i}),5E8,h.Progress.Axes,h.Progress.Text,i,numel(FileName),h.MT.Use_Chunkwise_Read_In.Value);
            
            if isempty(FileInfo.SyncPeriod)
                FileInfo.SyncPeriod = 1/Header.SyncRate;
            end
            if isempty(FileInfo.ClockPeriod)
                FileInfo.ClockPeriod = 1/Header.SyncRate;
            end
            if isempty(FileInfo.Resolution)
                FileInfo.Resolution = Header.Resolution;
            end
            if isfield(Header,'MI_Bins') % only returned for TimeHarp260 T3 data
                if isempty(FileInfo.MI_Bins)
                    FileInfo.MI_Bins = Header.MI_Bins;
                end
            end
            %%% Concaternates data to previous files and adds ImageTimes
            %%% to consecutive files
            if any(~cellfun(@isempty,MI(:)))
                for j = card
                    %%% Finds, which routing bits to use
                    if strcmp(UserValues.Detector.Auto,'off')
                        Rout=unique(UserValues.Detector.Rout(UserValues.Detector.Det))';
                    else
                        Rout = 1:10; %%% consider up to 10 routing channels
                    end
                    Rout(Rout>size(MI,2))=[];
                    
                    %%% check for disabled routing bits
                    for r = Rout
                        if sum((UserValues.Detector.Det==j)&(UserValues.Detector.Rout == r)) > 0
                            if all(strcmp(UserValues.Detector.enabled((UserValues.Detector.Det==j)&(UserValues.Detector.Rout == r)),'off'))
                                Rout(Rout==r) = [];
                            end
                        end
                    end
                    for k=Rout
                        TcspcData.MT{j,k}=[TcspcData.MT{j,k}; MaxMT + MT{j,k}];
                        MT{j,k}=[];
                        TcspcData.MI{j,k}=[TcspcData.MI{j,k}; MI{j,k}];
                        MI{j,k}=[];
                    end
                end
            end
            %%% Determines last photon for each file
            for k=find(~cellfun(@isempty,TcspcData.MT(j,:)))
                FileInfo.LastPhoton{j,k}(i)=numel(TcspcData.MT{j,k});
            end
            
            if ~isempty(Header.LineStart) % Image PTU data
                %%% remove the last incomplete frame
                %Header.LineStart(Header.LineStart>Header.FrameStart(end))=[];
                
                % cumulative n.o. frames
                f = size(Header.FrameStart,2);
                FileInfo.Frames = FileInfo.Frames + f;
                
                %%% create actual image and line times
                FileInfo.ImageTimes=[FileInfo.ImageTimes; (Header.FrameStart+MaxMT)'*FileInfo.ClockPeriod];
                lstart = reshape((Header.LineStart+MaxMT),[],f)'*FileInfo.ClockPeriod;
                lstop = reshape((Header.LineStop+MaxMT),[],f)'*FileInfo.ClockPeriod;
                FileInfo.LineTimes=[FileInfo.LineTimes; lstart];
                FileInfo.LineStops=[FileInfo.LineStops; lstop];
                
                %%% image info
                if i == 1
                    FileInfo.Lines = size(lstart,2);
                    FileInfo.Pixels = FileInfo.Lines;
                    FileInfo.PixTime = mean(mean(lstop-lstart))./FileInfo.Lines;
                else
                    if ~isequal(FileInfo.Lines, size(lstart,2))
                        msgbox('Image files are not equally sized!'), return;
                    end
                end
                
                %%% Enables image plotting
                h.MT.Use_Image.Value = 1;
                h.MT.Use_Lifetime.Value = 1;
                UserValues.Settings.Pam.Use_Image = 1;
            else % point PTU data
                FileInfo.ImageTimes = [FileInfo.ImageTimes MaxMT*FileInfo.ClockPeriod];
                FileInfo.Lines = 1;
            end
        end
        FileInfo.TACRange = FileInfo.SyncPeriod;
        if isempty(FileInfo.MI_Bins)
            FileInfo.MI_Bins = double(max(cellfun(@max,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)))));
        end
        FileInfo.MeasurementTime = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))))*FileInfo.SyncPeriod;
        
    case 7 %%% .h5 files in PhotonHDF5 file format
        FileInfo.FileType = 'PhotonHDF5';
        %%% General FileInfo
        FileInfo.NumberOfFiles=numel(FileName);
        FileInfo.Type=Type;
        FileInfo.MI_Bins=[];
        FileInfo.MeasurementTime=[];
        FileInfo.ImageTimes = [];
        FileInfo.SyncPeriod= [];
        FileInfo.ClockPeriod= [];
        FileInfo.Resolution = [];
        FileInfo.TACRange = [];
        FileInfo.Lines=1;
        FileInfo.LineTimes=[];
        FileInfo.Pixels=1;
        FileInfo.ScanFreq=1000;
        FileInfo.FileName=FileName;
        FileInfo.Path=Path;
        
        %%% Initializes microtime and macotime arrays
        if strcmp(UserValues.Detector.Auto,'off')
            %TcspcData.MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            %TcspcData.MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            TcspcData.MT=cell(10,10); %%% default to 10 channels
            TcspcData.MI=cell(10,10); %%% default to 10 channels
        else
            TcspcData.MT=cell(10,10); %%% default to 10 channels
            TcspcData.MI=cell(10,10); %%% default to 10 channels
        end
        
        %%% Reads all selected files
        for i=1:numel(FileName)
            Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str(i) ' of ' num2str(numel(FileName))]);
            
            %%% if multiple files are loaded, consecutive files need to
            %%% be offset in time with respect to the previous file
            MaxMT = 0;
            if any(~cellfun(@isempty,TcspcData.MT(:)))
                MaxMT = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))));
            end
            
            %%% read out information from the PhotonHDF5 file
            
            %%% Update Progress
            Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str(i-1) ' of ' num2str(numel(FileName))]);
            
            %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .h5 file
            [MT,MI, PhotonHDF5_Data] = Read_PhotonHDF5(fullfile(Path,FileName{i}));
            
            FileInfo.PhotonHDF5_Data = PhotonHDF5_Data;
            if isempty(FileInfo.SyncPeriod)
                FileInfo.SyncPeriod = PhotonHDF5_Data.photon_data.timestamps_specs.timestamps_unit;
            end
            if isempty(FileInfo.ClockPeriod)
                FileInfo.ClockPeriod = PhotonHDF5_Data.photon_data.timestamps_specs.timestamps_unit;
            end
            if isempty(FileInfo.Resolution)
                if isfield(PhotonHDF5_Data.photon_data, 'nanotimes_specs')
                    %%% TCSPC data
                    FileInfo.Resolution = PhotonHDF5_Data.photon_data.nanotimes_specs.tcspc_unit*1E12;
                else
                    %%% usALEX data
                    FileInfo.Resolution = PhotonHDF5_Data.photon_data.timestamps_specs.timestamps_unit*1E12;
                end
            end
            
            %%% Finds, which routing bits to use
            Rout = 1:10; %%% consider up to 10 routing channels
            Rout(Rout>size(MI,2))=[];
            
            %%% Concatenates data to previous files and adds ImageTimes
            %%% to consecutive files
            if any(~cellfun(@isempty,MI(:)))
                for j = 1:size(MT,1)
                    for k=Rout
                        TcspcData.MT{j,k}=[TcspcData.MT{j,k}; MaxMT + MT{j,k}];   MT{j,k}=[];
                        TcspcData.MI{j,k}=[TcspcData.MI{j,k}; MI{j,k}];   MI{j,k}=[];
                    end
                end
            end
            %%% Determines last photon for each file
            for k=find(~cellfun(@isempty,TcspcData.MT(j,:)))
                FileInfo.LastPhoton{j,k}(i)=numel(TcspcData.MT{j,k});
            end
            
        end
        FileInfo.MeasurementTime = double(PhotonHDF5_Data.acquisiton_duration); %max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))))*FileInfo.ClockPeriod;
        FileInfo.LineTimes = [0 FileInfo.MeasurementTime];
        FileInfo.ImageTimes =  [0 FileInfo.MeasurementTime];
        if isfield(PhotonHDF5_Data.photon_data,'nanotimes_specs')
            %%% TCSPC data
            FileInfo.MI_Bins = double(PhotonHDF5_Data.photon_data.nanotimes_specs.tcspc_num_bins); %double(max(cellfun(@max,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)))));
            FileInfo.TACRange =PhotonHDF5_Data.photon_data.nanotimes_specs.tcspc_range;
        else 
            %%% usALEX data
            FileInfo.MI_Bins = double(PhotonHDF5_Data.photon_data.measurement_specs.alex_period);
            FileInfo.TACRange = double(PhotonHDF5_Data.photon_data.measurement_specs.alex_period) * PhotonHDF5_Data.photon_data.timestamps_specs.timestamps_unit;
        end
        
    case 8 %%% *.t3r TTTR files from TimeHarp 200
        %%% Usually, here no Imaging Information is needed
        FileInfo.FileType = 'TimeHarp200';
        %%% General FileInfo
        FileInfo.NumberOfFiles=numel(FileName);
        FileInfo.Type=Type;
        FileInfo.MI_Bins=[];
        FileInfo.MeasurementTime=[];
        FileInfo.ImageTimes = [];
        FileInfo.SyncPeriod= [];
        FileInfo.ClockPeriod= [];
        FileInfo.Resolution = [];
        FileInfo.TACRange = [];
        FileInfo.Lines=1;
        FileInfo.LineTimes=[];
        FileInfo.Pixels=1;
        FileInfo.ScanFreq=1000;
        FileInfo.FileName=FileName;
        FileInfo.Path=Path;
        
        %%% Initializes microtime and macotime arrays
        if strcmp(UserValues.Detector.Auto,'off')
            TcspcData.MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            TcspcData.MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
        else
            TcspcData.MT=cell(10,10); %%% default to 10 channels
            TcspcData.MI=cell(10,10); %%% default to 10 channels
        end
        
        %%% Checks, which detectors to load
        if strcmp(UserValues.Detector.Auto,'off')
            card = unique(UserValues.Detector.Det);
        else
            card = 1:10; %%% consider up to 10 detection channels
        end
        %%% check for disabled detectors
        for j = card
            if sum(UserValues.Detector.Det==j) > 0
                if all(strcmp(UserValues.Detector.enabled(UserValues.Detector.Det==j),'off'))
                    card(card==j) = [];
                end
            end
        end
        
        %%% Reads all selected files
        for i=1:numel(FileName)
            Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str(i) ' of ' num2str(numel(FileName))]);
            
            %%% if multiple files are loaded, consecutive files need to
            %%% be offset in time with respect to the previous file
            MaxMT = 0;
            if any(~cellfun(@isempty,TcspcData.MT(:)))
                MaxMT = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))));
            end
            
            %%% Update Progress
            Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str(i-1) ' of ' num2str(numel(FileName))]);
            %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
            [MT, MI, ~, ~, ~, SyncRate, ClockRate, Resolution] = Read_T3R(fullfile(Path,FileName{i}));
            
            if isempty(FileInfo.SyncPeriod)
                FileInfo.SyncPeriod = 1/SyncRate;
            end
            if isempty(FileInfo.ClockPeriod)
                FileInfo.ClockPeriod = 1/ClockRate;
            end
            if isempty(FileInfo.Resolution)
                FileInfo.Resolution = Resolution;
            end
   
            %%% Concatenates data to previous files and adds ImageTimes
            %%% to consecutive files
            if any(~cellfun(@isempty,MI(:)))
                for j = card
                    %%% Finds, which routing bits to use
                    if strcmp(UserValues.Detector.Auto,'off')
                        Rout = unique(UserValues.Detector.Rout(UserValues.Detector.Det==j));
                    else
                        Rout = 1:10; %%% consider up to 10 routing channels
                    end
                    Rout(Rout>size(MI,2))=[];
                    
                    %%% check for disabled routing bits
                    for r = Rout
                        if sum((UserValues.Detector.Det==j)&(UserValues.Detector.Rout == r)) > 0
                            if all(strcmp(UserValues.Detector.enabled((UserValues.Detector.Det==j)&(UserValues.Detector.Rout == r)),'off'))
                                Rout(Rout==r) = [];
                            end
                        end
                    end
            
                    for k=Rout
                        TcspcData.MT{j,k}=[TcspcData.MT{j,k}; MaxMT + MT{j,k}];   MT{j,k}=[];
                        TcspcData.MI{j,k}=[TcspcData.MI{j,k}; MI{j,k}];   MI{j,k}=[];
                    end
                end
            end
            %%% Determines last photon for each file
            for k=find(~cellfun(@isempty,TcspcData.MT(j,:)))
                FileInfo.LastPhoton{j,k}(i)=numel(TcspcData.MT{j,k});
            end
            
        end
        %%% correct microtime offset
        mi_offset = min(cellfun(@min,TcspcData.MI(~cellfun(@isempty,TcspcData.MI))));
        TcspcData.MI(~cellfun(@isempty,TcspcData.MI)) =cellfun(@(x) x-mi_offset+1,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)),'UniformOutput',false);
        
        FileInfo.MeasurementTime = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))))*FileInfo.ClockPeriod;
        FileInfo.LineTimes = [0 FileInfo.MeasurementTime];
        FileInfo.ImageTimes =  [0 FileInfo.MeasurementTime];
        FileInfo.MI_Bins = double(max(cellfun(@max,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)))));
        FileInfo.TACRange = FileInfo.SyncPeriod;
    case 9 %%% Confocor3 raw data files (*.raw)
        %%% Usually, here no Imaging Information is needed
        FileInfo.FileType = 'Confocor3';
        %%% General FileInfo
        FileInfo.NumberOfFiles=numel(FileName);
        FileInfo.Type=Type;
        FileInfo.MI_Bins=[];
        FileInfo.MeasurementTime=[];
        FileInfo.ImageTimes = [];
        FileInfo.SyncPeriod = [];
        FileInfo.ClockPeriod = [];
        FileInfo.Resolution = [];
        FileInfo.TACRange = [];
        FileInfo.Lines=10;
        FileInfo.Pixels=10;
        FileInfo.LineTimes=[];
        FileInfo.ScanFreq=1000;
        FileInfo.FileName=FileName;
        FileInfo.Path=Path;
        
        %%% Initializes microtime and macotime arrays
        if strcmp(UserValues.Detector.Auto,'off')
           TcspcData.MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
           TcspcData.MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
        else
            TcspcData.MT=cell(10,10); %%% default to 10 channels
            TcspcData.MI=cell(10,10); %%% default to 10 channels
        end
        %%% Checks, which detectors to load
        if strcmp(UserValues.Detector.Auto,'off')
            card = unique(UserValues.Detector.Det);
        else
            card = 1:10; %%% consider up to 10 detection channels
        end
        %%% check for disabled detectors
        for j = card
            if sum(UserValues.Detector.Det==j) > 0
                if all(strcmp(UserValues.Detector.enabled(UserValues.Detector.Det==j),'off'))
                    card(card==j) = [];
                end
            end
        end
        %%% Reads all selected files
        for i=1:numel(FileName)
            Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str(i) ' of ' num2str(numel(FileName))]);
            
            %%% if multiple files are loaded, consecutive files need to
            %%% be offset in time with respect to the previous file
            MaxMT = 0;
            if any(~cellfun(@isempty,TcspcData.MT(:)))
                MaxMT = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))));
            end
            
            %%% Update Progress
            Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str(i-1) ' of ' num2str(numel(FileName))]);
            %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
            [MT, MI, SyncRate, Resolution, FileInfo.Header{i}] = Read_ConfoCor3_Raw(fullfile(Path,FileName{i}),Inf,h.Progress.Axes,h.Progress.Text,i,numel(FileName));
            
            if isempty(FileInfo.SyncPeriod)
                FileInfo.SyncPeriod = 1/SyncRate;
            end
            if isempty(FileInfo.ClockPeriod)
                FileInfo.ClockPeriod = 1/SyncRate;
            end
            if isempty(FileInfo.Resolution)
                FileInfo.Resolution = Resolution;
            end
            %%% Concaternates data to previous files and adds ImageTimes
            %%% to consecutive files
            if any(~cellfun(@isempty,MI(:)))
                for j = card
                    %%% Finds, which routing bits to use
                    if strcmp(UserValues.Detector.Auto,'off')
                        Rout=unique(UserValues.Detector.Rout(UserValues.Detector.Det))';
                    else
                        Rout = 1:10; %%% consider up to 10 routing channels
                    end
                    Rout(Rout>size(MI,2))=[];
                    
                    %%% check for disabled routing bits
                    for r = Rout
                        if sum((UserValues.Detector.Det==j)&(UserValues.Detector.Rout == r)) > 0
                            if all(strcmp(UserValues.Detector.enabled((UserValues.Detector.Det==j)&(UserValues.Detector.Rout == r)),'off'))
                                Rout(Rout==r) = [];
                            end
                        end
                    end
                    for k=Rout
                        %%% here, separate detector are saved in separate
                        %%% files, so we need to read out the maximum
                        %%% macrotime individually
                        maxMTind = 0;
                        if ~isempty(TcspcData.MT{j,k})
                            maxMTind = max(TcspcData.MT{j,k});
                        end
                        TcspcData.MT{j,k}=[TcspcData.MT{j,k}; maxMTind + MT{j,k}];
                        MT{j,k}=[];
                        TcspcData.MI{j,k}=[TcspcData.MI{j,k}; MI{j,k}];
                        MI{j,k}=[];
                    end
                end
            end
            %%% Determines last photon for each file
            for k=find(~cellfun(@isempty,TcspcData.MT(j,:)))
                FileInfo.LastPhoton{j,k}(i)=numel(TcspcData.MT{j,k});
            end
            
            FileInfo.ImageTimes = [FileInfo.ImageTimes MaxMT*FileInfo.ClockPeriod];
        end
        FileInfo.TACRange = FileInfo.SyncPeriod;
        FileInfo.MI_Bins = double(max(cellfun(@max,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)))));
        FileInfo.MeasurementTime = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))))*FileInfo.SyncPeriod;
        
        FileInfo.ImageTimes = linspace(0,FileInfo.MeasurementTime,i+1);
        FileInfo.LineTimes  = repmat(reshape(linspace(0,FileInfo.ImageTimes(2),11),1,[]),[numel(FileInfo.ImageTimes)-1,1]);
        for i=2:size(FileInfo.LineTimes,1)
            FileInfo.LineTimes(i,:)=FileInfo.LineTimes(i,:)+FileInfo.ImageTimes(i);
        end

        FileInfo.Lines=size(FileInfo.LineTimes,2)-1;
        FileInfo.Pixels=FileInfo.Lines;
    case 10 %%% Custom Read-In types
        %%% The User can select which Read-Ins to display an use
        %%% This will allow easier, modular implementation of custom file types (esp. for scanning) 
        if ~exist('Custom','var') %%% If it was called from the database etc.
            if ~isdeployed
                Customdir = [PathToApp filesep 'functions' filesep 'Custom_Read_Ins'];
                %%% Finds all matlab files in custom file types directory
                Custom_Methods = what(Customdir);
                Custom_Methods = Custom_Methods.m(:);
                for i=1:numel(Custom_Methods)
                    if strcmp(UserValues.File.Custom_Filetype, Custom_Methods{i}(1:end-2))
                        Custom = str2func(UserValues.File.Custom_Filetype);
                    end
                end
                if ~exist('Custom','var') %%% Aborts if file does not exist anymore
                    return;
                end
            else
                %%% compiled application
                Custom = str2func(UserValues.File.Custom_Filetype);
            end
        end  
        feval(Custom, FileName,Path,Type,h);
end
%%% close all open file handles
fclose('all');
Progress(1,h.Progress.Axes, h.Progress.Text);

if strcmp(UserValues.Detector.Auto,'on')
    %%% Auto-detection of used Detection and Routing channels
    %%% Check which ones have been defined already
    %%% Add missing ones
    [used_det,used_rout] = find(cellfun(@(x) ~isempty(x),TcspcData.MT));
    for i = 1:numel(used_det)
        defined = false;
        for j = 1:numel(UserValues.Detector.Det)
            if (UserValues.Detector.Det(j) == used_det(i) && UserValues.Detector.Rout(j) == used_rout(i))
                defined = true;
            end
        end
        if ~defined
            %%% add to UserValues.Detector list
            UserValues.Detector.Det(end+1) = used_det(i);
            UserValues.Detector.Rout(end+1) = used_rout(i);
            UserValues.Detector.Color(end+1,:) = [1,0,0];
            UserValues.Detector.Shift(end+1) = {zeros(400,1)};
            UserValues.Detector.Name{end+1} = sprintf('Det: %i, Rout: %i',used_det(i),used_rout(i));
            UserValues.Detector.Filter{end+1} = '500/50';
            UserValues.Detector.Pol{end+1} = 'none';
            UserValues.Detector.BS{end+1} = 'none';
            UserValues.Detector.enabled{end+1} = 'on';
        end
    end
    LSUserValues(1);
    Update_Detector_Channels([],[],0:2)
end
if strcmp(Caller.Tag, 'Pam')
    %%% Applies detector shift immediately after loading data
    Shift_Detector([],[],'load')
    %%% Updates the Pam meta Data; needs inputs 3 and 4 to be zero
    %%% this needs not be done if database is used for batch processing
    if ~any(gcbo==[h.Export.Correlate h.Export.Burst])
        Update_Data([],[],0,0);
        Update_Display([],[],0);
    end
    %%% Resets GUI Elements of BurstSearch
    h.BurstLifetime_Button.Enable = 'off';
    h.BurstLifetime_Button.ForegroundColor = [1 1 1];
    h.NirFilter_Button.Enable = 'off';
    h.NirFilter_Button.ForegroundColor = [1 1 1];
    %%% get TCSPC resolution
    if isfield(FileInfo,'Resolution')
        TCSPCResolution = FileInfo.Resolution;
    else
        TCSPCResolution = 1E12*FileInfo.TACRange/FileInfo.MI_Bins; % in ps
    end
    %%% Update FileInfo Table
    h.PIE.FileInfoTable.Data(:,2) = {...
        sprintf('%.0f',FileInfo.MeasurementTime);...
        sprintf('%.2f',1E9*FileInfo.ClockPeriod);...
        sprintf('%.2f',1E-6/FileInfo.SyncPeriod);...
        sprintf('%.2f',1E9*FileInfo.TACRange);...
        sprintf('%d',FileInfo.MI_Bins);...
        sprintf('%.2f',TCSPCResolution);
        sprintf('%d',FileInfo.NumberOfFiles);...        
        get_date_modified(FileInfo.Path,FileInfo.FileName{1})};
    
    %%% Updates MI Range in Phasor
    h.MI.Phasor_TAC.String = num2str(FileInfo.TACRange*10^9);

    %%% Fix situation where the PIE channel range is larger than the number
    %%% of microtime bins
    UserValues.PIE.To(UserValues.PIE.To > FileInfo.MI_Bins) = FileInfo.MI_Bins;
end