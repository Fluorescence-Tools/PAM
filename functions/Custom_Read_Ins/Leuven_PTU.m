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
        %%% remove the last incomplete frame 
        if mod(numel(Header.FrameStart),2)==1
            Header.FrameStart(end)=[];
        end
        Header.LineStart(Header.LineStart>Header.FrameStart(end))=[];
        
        % cumulative n.o. frames
        % Header.Frames might contain NoF already
        f = size(Header.FrameStart(1:2:end),2);
        FileInfo.Frames = FileInfo.Frames + f;
        
        %%% create actual image and line times
        % framestarts and -stops are both written on bit 1 in the 6-bit CH entry of the PTU files
        FileInfo.ImageTimes=[FileInfo.ImageTimes; (Header.FrameStart(1:2:end)+MaxMT)'*FileInfo.ClockPeriod];
        % FileInfo.ImageStops=[FileInfo.ImageStops; (Header.FrameStart(2:2:end)+MaxMT)'*FileInfo.ClockPeriod]; % not used anyway
        % linestarts and -stops are both written on bit 1 in the 6-bit CH entry of the PTU files
        lstart = reshape((Header.LineStart(1:2:end)+MaxMT),[],f)'*FileInfo.ClockPeriod;
        lstop = reshape((Header.LineStart(2:2:end)+MaxMT),[],f)'*FileInfo.ClockPeriod;
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
        %FileInfo.ImageTimes = [FileInfo.ImageTimes MaxMT*FileInfo.ClockPeriod];
        %%% Disables image plotting
        h.MT.Use_Image.Value = 0;
        h.MT.Use_Lifetime.Value = 0;
        UserValues.Settings.Pam.Use_Lifetime = 0;
        UserValues.Settings.Pam.Use_Image = 0;
        FileInfo.Lines = 1; %Leave here
    end
end

FileInfo.TACRange = FileInfo.SyncPeriod;
FileInfo.MI_Bins = double(max(cellfun(@max,TcspcData.MI(~cellfun(@isempty,TcspcData.MI)))));
FileInfo.MeasurementTime = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))))*FileInfo.SyncPeriod;

if ~isempty(Header.LineStart) % Image PTU data
    % correct for delay of bits with respect to photons
    FileInfo.ImageTimes = FileInfo.ImageTimes+0.00095;
    %FileInfo.ImageStops = FileInfo.ImageStops+0.00095;
    FileInfo.LineStops = FileInfo.LineStops+0.00095;
    FileInfo.LineTimes = FileInfo.LineTimes+0.00095;
end

%% Thresholding or histogramming function 
thresh = 0;
histog = 0;

% FileInfo.ClockPeriod is the macrotime clock in seconds
det = 3;% det is the detector ID in pam
rout = 1;% rout is the routing ID in pam
binsize = 100;% binsize is the number of adjacent photons between which the average count rate is calculated

if thresh == 1 % do intensity thresholding of the data prior to loading it
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
        elseif (TcspcData.MT{det,rout}(i*binsize)-TcspcData.MT{det,rout}((i-1)*binsize+1))/binsize < high
            % time difference between photons is smaller than the lower intensity threshold
            index = [index ((i-1)*binsize+1:(i*binsize))];
        end
    end
    
    TcspcData.MI{det,rout}(index) = [];
    TcspcData.MT{det,rout}(index) = [];
end

if histog == 1 % make a count rate vs lifetime plot
    IRFoffset = 0; % offset of the IRF from zero in units of TAC channels
    TACres = 1E12*FileInfo.TACRange/FileInfo.MI_Bins; %ps/TAC channel
    histogramwidth = 50;
    
    bins = floor(size(TcspcData.MT{det,rout},1)/binsize);
    CR = zeros(bins,0); %mean count rate per bin
    LT = zeros(bins,0); %mean lifetime per bin
    for i = 1:bins
        CR(i) = binsize/((TcspcData.MT{det,rout}(i*binsize)-TcspcData.MT{det,rout}((i-1)*binsize+1))*FileInfo.ClockPeriod)/1000; %average count rate between 'binsize' photons in kHz
        LT(i) = (mean(TcspcData.MI{det,rout}(i*binsize)-TcspcData.MI{det,rout}((i-1)*binsize+1))-IRFoffset)*TACres/1000; %average foton arrival in ns between 'binsize' photons
    end
    
    
    histoCR = (max(CR)/histogramwidth:max(CR)/histogramwidth:max(CR))-max(CR)/histogramwidth/2;
    histo = cell(numel(histoCR),1);
    for i = 1:numel(CR)
        [mini, index] = min(abs(histoCR-CR(i))); %find in which count rate bin the current element belongs
        histo{index} = [histo{index} LT(i)];
    end
    histoLT = zeros(numel(histoCR),1);
    errLT = zeros(numel(histoCR),1);
    j = [];
    for i = 1:numel(histoCR)
        histoLT(i) = mean(histo{i});
        errLT(i) = std(histo{i})/sqrt(numel(histo{i}));
        if numel(histo{i})<5
            j = [j i];
        end
    end
    histoCR(j)=[]; %remove all entries that are not good anyway
    histoLT(j)=[];
    errLT(j)=[];
    hfig = figure;
    hax = axes(hfig);
    errorbar(hax, histoCR, histoLT,errLT,'bo')  %errLT is the standard error of the mean
    xlabel('local count rate [kHz]')
    ylabel('mean foton arrival time [ns]')
end

LSUserValues(1);
Calculate_Settings = PAM ('Calculate_Settings');
Calculate_Settings(h.MT.Use_Image,[]);
