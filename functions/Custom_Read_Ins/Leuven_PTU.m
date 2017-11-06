function [Suffix, Description] = Leuven_PTU(FileName, Path, Type,h)

%%% Outputs Suffix and Description for file selection querry
if nargin == 0
    Suffix ='*.ptu';
    Description ='PQ Hydraharp PTU Leuven custom scanning format';
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
    
    if ~isempty(Header.LineIndices) % Image PTU data
        if ~isfield(FileInfo, 'LineStops')
            FileInfo.LineStops = [];
            FileInfo.ImageStops = [];
        end
        
        %%% Removes incomplete Frame Starts and Line Markers
        if mod(numel(Header.FrameIndices),2)==1
            Header.FrameIndices(end)=[];
        end
        Header.LineIndices(Header.LineIndices>Header.FrameIndices(end))=[];
        FileInfo.ImageTimes=[FileInfo.ImageTimes; (Header.FrameIndices(1:2:end)+MaxMT)*FileInfo.ClockPeriod];
        FileInfo.ImageStops=[FileInfo.ImageStops; (Header.FrameIndices(2:2:end)+MaxMT)*FileInfo.ClockPeriod];
        FileInfo.LineTimes=[FileInfo.LineTimes; reshape((Header.LineIndices(1:2:end)+MaxMT),[],Header.NoF)'*FileInfo.ClockPeriod];
        FileInfo.LineStops=[FileInfo.LineStops; reshape((Header.LineIndices(2:2:end)+MaxMT),[],Header.NoF)'*FileInfo.ClockPeriod];
        
        %%% Enables image plotting
        h.MT.Use_Image.Value = 1;
        h.MT.Use_Lifetime.Value = 1;
        UserValues.Settings.Pam.Use_Image = 1;
    else % point PTU data
        FileInfo.ImageTimes = [FileInfo.ImageTimes MaxMT*FileInfo.ClockPeriod];
        
        
        %%% Disables image plotting
        h.MT.Use_Image.Value = 0;
        h.MT.Use_Lifetime.Value = 0;
        UserValues.Settings.Pam.Use_Lifetime = 0;
        UserValues.Settings.Pam.Use_Image = 0;
    end
    
end
FileInfo.TACRange = FileInfo.SyncPeriod;
FileInfo.MI_Bins = double(max(cellfun(@max,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)))));
FileInfo.MeasurementTime = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))))*FileInfo.SyncPeriod;

if isempty(FileInfo.LineTimes) %%%Point Measurements
    FileInfo.ImageTimes = linspace(0,FileInfo.MeasurementTime,i+1);
    FileInfo.LineTimes  = repmat(reshape(linspace(0,FileInfo.ImageTimes(2),11),1,[]),[numel(FileInfo.ImageTimes)-1,1]);
    for i=2:size(FileInfo.LineTimes,1)
        FileInfo.LineTimes(i,:)=FileInfo.LineTimes(i,:)+FileInfo.ImageTimes(i);
    end   
    FileInfo.Lines=size(FileInfo.LineTimes,2)-1;
FileInfo.Pixels=FileInfo.Lines;
else
    FileInfo.ImageTimes = FileInfo.ImageTimes+0.00095;
    FileInfo.ImageStops = FileInfo.ImageStops+0.00095;
    FileInfo.LineStops = FileInfo.LineStops+0.00095;
    FileInfo.LineTimes = FileInfo.LineTimes+0.00095;
    FileInfo.Lines=size(FileInfo.LineTimes,2);
FileInfo.Pixels=FileInfo.Lines;
end

guillermo = 1;
thresh = 1;
histo = 1;

if guillermo == 1
    % FileInfo.ClockPeriod is the macrotime clock in seconds
    det = 3;% det is the detector ID in pam
    rout = 1;% rout is the routing ID in pam
    binsize = 100;% bin is the number of adjacent photons between which the average count rate is calculated
    
    if thresh == 1
        low = 0.5;% low is the lower intensity threshold in kHz
        high = 15;% high is the higher intensity threshold in kHz
        
        %% change units
        low = 1/(low*1000*FileInfo.ClockPeriod); %seconds between photons
        high = 1/(high*1000*FileInfo.ClockPeriod); %s
        
        index = [];
        
        for i = 1:(round(numel(TcspcData.MT{det,rout})/binsize)-1)
            if (TcspcData.MT{det,rout}(i*binsize)-TcspcData.MT{det,rout}((i-1)*binsize+1))/binsize > low
                % time difference between photons is larger than the lower intensity threshold
                index = [index ((i-1)*binsize+1:(i*binsize))];
            elseif (TcspcData.MT{det,rout}(i*bin)-TcspcData.MT{det,rout}((i-1)*binsize+1))/binsize < high
                % time difference between photons is smaller than the lower intensity threshold
                index = [index ((i-1)*binsize+1:(i*binsize))];
            end
        end
        
        TcspcData.MI{det,rout}(index) = [];
        TcspcData.MT{det,rout}(index) = [];
    end
    if histo == 1
        IRFoffset = 100; % offset of the IRF from zero in units of TAC channels
        TACres = 1024; %ps/TAC channel
        
        bins = floor(size(TcspcData.MT{det,rout},1)/binsize);
        CR = zeros(bins,0);
        LT = zeros(bins,0);
        for i = 1:bins
            CR = binsize/((TcspcData.MT{det,rout}(i*binsize)-TcspcData.MT{det,rout}((i-1)*binsize+1))*FileInfo.ClockPeriod)*1000; %average count rate between 'binsize' photons in kHz
            LT = (mean(TcspcData.MI{det,rout}(i*binsize)-TcspcData.MI{det,rout}((i-1)*binsize+1))-IRFoffset)*TACres/1000; %average foton arrival in ns between 'binsize' photons
        end
        
        hfig = figure;
        hax = axes(hfig);
        bar(hax, CR, LT)
        xlabel('count rate [kHz]')
        ylabel('mean foton arrival time [ns]') 
    end
end

LSUserValues(1);
Calculate_Settings = PAM ('Calculate_Settings');
Calculate_Settings(h.MT.Use_Image,[]);
