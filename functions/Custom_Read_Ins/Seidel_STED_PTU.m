function [Suffix, Description] = Seidel_STED_PTU(FileName, Path, Type,h)

%%% Outputs Suffix and Description for file selection querry
if nargin == 0
    Suffix ='*.ptu';
    Description ='PQ Hydraharp PTU Seidel-STED custom scanning format';
    return;
end

%%% Starts Read-In
global UserValues TcspcData FileInfo

%%% Usually, here no Imaging Information is needed
FileInfo.FileType = 'HydraHarp';
%%% General FileInfo
FileInfo.NumberOfFiles=numel(FileName);
FileInfo.Type=Type;
FileInfo.MI_Bins=[];
FileInfo.MeasurementTime=[];

FileInfo.SyncPeriod = [];
FileInfo.ClockPeriod = [];
FileInfo.TACRange = [];
FileInfo.ScanFreq=1000;
FileInfo.FileName=FileName;
FileInfo.Path=Path;

% Initializes line and frame markers
FileInfo.LineTimes = [];
FileInfo.ImageTimes = [];
FileInfo.LineStops = [];
FileInfo.ImageStops = [];

FileInfo.Frames = 0;
FileInfo.Lines = [];
FileInfo.Pixels = [];
FileInfo.PixTime = [];

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
    [MT, MI, Header] = Read_PTU(fullfile(Path,FileName{i}),Inf,h.Progress.Axes,h.Progress.Text,i,numel(FileName));
    
    
    if isempty(FileInfo.SyncPeriod)
        FileInfo.SyncPeriod = 1/Header.SyncRate;
    end
    if isempty(FileInfo.ClockPeriod)
        FileInfo.ClockPeriod = 1/Header.SyncRate;
    end
    %%% Finds, which routing bits to use
    if strcmp(UserValues.Detector.Auto,'off')
        Rout=unique(UserValues.Detector.Rout(UserValues.Detector.Det))';
    else
        Rout = 1:10;
    end
    Rout(Rout>size(MI,2))=[];
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
        % cumulative n.o. frames
        % Header.Frames might contain NoF already
        f = size(Header.FrameStart,2);
        FileInfo.Frames = FileInfo.Frames + f;
        
        %%% create actual image and line times
        % framestarts and -stops are both written on bit 1 in the 6-bit CH entry of the PTU files
        FileInfo.ImageTimes=[FileInfo.ImageTimes; (Header.FrameStart+MaxMT)'*FileInfo.ClockPeriod];
        % FileInfo.ImageStops=[FileInfo.ImageStops; (Header.FrameStart(2:2:end)+MaxMT)'*FileInfo.ClockPeriod]; % not used anyway
        % linestarts and -stops are both written on bit 1 in the 6-bit CH entry of the PTU files
        lstart = reshape((Header.LineStart+MaxMT),[],f)';
        lstop = reshape((Header.LineStop+MaxMT),[],f)';
  
        FileInfo.LineTimes=[FileInfo.LineTimes; lstart*FileInfo.ClockPeriod];
        FileInfo.LineStops=[FileInfo.LineStops; lstop*FileInfo.ClockPeriod];
        %%% image info
        if i == 1
            FileInfo.Lines = size(lstart,2);
            FileInfo.Pixels = Header.PixX;
            FileInfo.PixTime = mean(mean(lstop-lstart))./FileInfo.Pixels*FileInfo.ClockPeriod;
        else
            if ~isequal(FileInfo.Lines, size(lstart,2))
                msgbox('Image files are not equally sized!'), return;
            end
        end
        
        transform = true;
        if transform
            Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Converting File ' num2str(i) ' of ' num2str(numel(FileName))]);
            % ask the user for the excitation period.
            % Assuming only the last scan is red.
            period = str2double(inputdlg({'Period length'},'Specify the period length',1,{'4'}));
            lines = FileInfo.Pixels*period;
            % transform the raw MT data to split up into duty cycle periods.
            % Currently, for each line the setup performs 3 scans with green
            % excitation and one scan with red excitation.
            % -> separate into 2 routing bits and use only first lines start/stop.
            % -> Re-scale the macrotime of consecutive lines to match the first line.
            for j = card % assuming there is no actual routing being used
                if ~isempty(TcspcData.MT{j,1})
                    [Image,Bin] = CalculateImage(TcspcData.MT{j,1}*FileInfo.ClockPeriod, 4);
                    Bin = double(Bin);
                    Frame = floor(Bin/(250*lines))+1;
                    valid = Bin ~= 0;       
                    Line = mod(ceil(Bin/250),lines);Line(Line == 0) = lines;
                    %Line = floor(mod(Bin,250*1000)/250)+1;
                    Cycle = mod(Line-1,period);
                    for f = 1:size(lstart,1)
                        validd = valid & Frame == f;
                        % MT = MT - linestart_of_line + linestart_of_cycle;
                        TcspcData.MT{j,1}(validd) = TcspcData.MT{j,1}(validd) - lstart(f,Line(validd))' + lstart(f,Line(validd)-Cycle(validd))';
                    end
                    red = (Cycle == (period-1));
                    green = (Cycle < period);                    
                    TcspcData.MT{j,2} = TcspcData.MT{j,1}(red);
                    TcspcData.MI{j,2} = TcspcData.MI{j,1}(red);
                    TcspcData.MT{j,1} = TcspcData.MT{j,1}(green);
                    TcspcData.MI{j,1} = TcspcData.MI{j,1}(green);
                    % Macrotime has to be resorted
                    [TcspcData.MT{j,1},idx] = sort(TcspcData.MT{j,1});
                    TcspcData.MI{j,1} = TcspcData.MI{j,1}(idx);
                    [TcspcData.MT{j,2},idx] = sort(TcspcData.MT{j,2});
                    TcspcData.MI{j,2} = TcspcData.MI{j,2}(idx);
                end
            end
            FileInfo.LineTimes = FileInfo.LineTimes(:,1:period:end);
            FileInfo.LineStops = FileInfo.LineStops(:,1:period:end);
            FileInfo.Lines = 250;
            FileInfo.Pixels = 250;
        end
        
        %%% Enables image plotting
        h.MT.Use_Image.Value = 1;
        h.MT.Use_Lifetime.Value = 1;
        UserValues.Settings.Pam.Use_Image = 1;
    else % point PTU data
        %FileInfo.ImageTimes = [FileInfo.ImageTimes MaxMT*FileInfo.ClockPeriod];
        %%% Disables image plotting
        h.MT.Use_Image.Value = 0;
        h.MT.Use_Lifetime.Value = 0;
        UserValues.Settings.Pam.Use_Lifetime = 0;
        UserValues.Settings.Pam.Use_Image = 0;
        h.Image.Tab.Parent = [];
        FileInfo.Lines = 1; %Leave here
    end
end

FileInfo.TACRange = FileInfo.SyncPeriod;
FileInfo.MI_Bins = double(max(cellfun(@max,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)))));
FileInfo.MeasurementTime = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))))*FileInfo.ClockPeriod;

LSUserValues(1);
% Calculate_Settings = PAM ('Calculate_Settings');
% Calculate_Settings(h.MT.Use_Image,[]);
