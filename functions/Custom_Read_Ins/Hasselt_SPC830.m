function [Suffix, Description] = Hasselt_SPC830(FileName, Path, Type,h)

%%% Outputs Suffix and Description for file selection querry
if nargin == 0
    Suffix ='*.spc';
    Description ='B&H SPC830 files recorded Hasselt LSM510_Meta';
    return;
end

%%% Starts Read-In
global UserValues TcspcData FileInfo
%%% Usually, here no Imaging Information is needed
FileInfo.FileType = 'SPC';
%%% General FileInfo
FileInfo.NumberOfFiles = numel(FileName);
FileInfo.Type = Type;
FileInfo.MeasurementTime = [];
FileInfo.ImageTimes = [];
FileInfo.ImageStops = [];
FileInfo.SyncPeriod = []; %ns per period
FileInfo.ClockPeriod = [];
FileInfo.TACRange = []; %in seconds
FileInfo.Lines = [];
FileInfo.LineTimes = [];
FileInfo.LineStops = [];
FileInfo.Pixels = [];
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
MI_Bins = 4096;
Card = 'SPC-830';
TACRange = [];
TACGain = [];
Corrupt = false;
MaxMT = 0;
card = 1;
Pixelduration = [];
%%% Reads all selected files
for i=1:numel(FileName)
    %%% there are a number of *_m(i).spc files associated with the
    %%% *_m1.spc file
    
    %%% Read .set file
    fid = fopen(fullfile(Path, [FileName{1}(1:end-3) 'set']), 'r');
    if fid~=-1 %%% .set file exists
        Collection_Time=[];
        %%% Reads file line by line till all parameters are found
        while (isempty(TACRange) || isempty(TACGain)) && ~Corrupt
            Line = fgetl(fid);
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
            %%% Stops, if end of file is reached
            if ~isempty(Line) && all(Line==-1)
                Corrupt = true;
            end
        end
        fclose(fid);
        if ~Corrupt %%% .set file was complete
            FileInfo.TACRange = TACRange/TACGain;
        else %%% No .set file was found; use standard settings
            h = msgbox('Setup (.set) file not found!');
            TACRange = [];
            pause(1)
            close(h)
        end
        
    else %if there is no set file, the B&H software was likely not used
        h_msg = msgbox('Setup (.set) file not found!');
        TACRange = [];
        pause(1)
        close(h_msg)
    end

    Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,'Loading:');
    
    %%% if multiple files are loaded, consecutive files need to
    %%% be offset in time with respect to the previous file
    %%% Reads data for each tcspc card
    for j = card
        %%% Update Progress
        Progress((i-1)/numel(FileName)+(j-1)/numel(card)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str((i-1)*numel(card)+j) ' of ' num2str(numel(FileName)*numel(card))]);
        %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
        
        [MT, MI, Header] = Read_BH(fullfile(Path,FileName{i}), Inf, Card);
        
        %%% extracts SyncPeriod and ClockPeriod from Data
        if isempty(FileInfo.SyncPeriod)
            FileInfo.SyncPeriod = 12.5e-9; %hardcoded
        end
        if isempty(FileInfo.ClockPeriod)
            FileInfo.ClockPeriod = Header.ClockRate^-1;
        end
        
        %%% Extracts frame starts and number of frames from frame-syncs
        FileInfo.ImageTimes = [FileInfo.ImageTimes Header.FrameMarker*FileInfo.ClockPeriod];
        NoF=numel(Header.FrameMarker);
        %%% Extracts line starts and number of lines from line syncs
        FileInfo.LineTimes = [FileInfo.LineTimes; MaxMT+permute(reshape(Header.LineMarker*FileInfo.ClockPeriod,[],NoF),[2 1])];
        FileInfo.Lines = size(FileInfo.LineTimes,2);
        FileInfo.Pixels = FileInfo.Lines;
        %%% Extracts number of pixels and pixel duration from pixel syncs
        Pixelduration = mean(diff(Header.PixelMarker));
        
        %%% Shifts line and frame start by a certain number of pixels
        %%% 43 for 512 Lines => 43/512*Lines
        FileInfo.LineTimes((end+1-NoF):end,:) = FileInfo.LineTimes((end+1-NoF):end,:) + round(FileInfo.Lines*43/512)*Pixelduration*FileInfo.ClockPeriod;
        FileInfo.ImageTimes((end+1-NoF):end,1) = FileInfo.ImageTimes((end+1-NoF):end) + round(FileInfo.Lines*43/512)*Pixelduration*FileInfo.ClockPeriod;
        %%% Sets line and frame stops
        FileInfo.LineStops((end+1):(end+NoF),:) = FileInfo.LineTimes((end+1-NoF):end,:) + FileInfo.Pixels*Pixelduration*FileInfo.ClockPeriod;
        FileInfo.ImageStops((end+1):(end+NoF),1) = FileInfo.LineStops((end+1-NoF):end,end);
        
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
    
    %%% Sets 
    MaxMT = MaxMT + max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))));

    
end

FileInfo.MeasurementTime = MaxMT*FileInfo.ClockPeriod;

if ~isempty(MI_Bins) && MI_Bins>1 %%% Sets number of MI bins to value from .set file (or fixed)
    FileInfo.MI_Bins = MI_Bins;
else %%% Reads highest used MI and usen 2^n bins
    usedMI = max(cellfun(@numel,cellfun(@unique,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)),'UniformOutput',false)));
    FileInfo.MI_Bins = 2^(ceil(log2(usedMI)));
end

if isempty(FileInfo.TACRange)
    %%% try to read the TACrange from SyncPeriod and number of used
    %%% MIBins
    usedMI = max(cellfun(@numel,cellfun(@unique,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)),'UniformOutput',false)));
    FileInfo.TACRange = (FileInfo.SyncPeriod/usedMI)*FileInfo.MI_Bins;
end
FileInfo.Card = Card;