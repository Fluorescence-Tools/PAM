function [Suffix, Description] = Hasselt_SPC830(FileName, Path, Type,h)

%%% Outputs Suffix and Description for file selection querry
if nargin == 0
    Suffix ='*.spc';
    Description ='B&H SPC830 files recorded Hasselt LSM510_Meta';
    return;
end

%%% Starts Read-In
global UserValues TcspcData FileInfo
FileInfo.ImageStops = [];
FileInfo.LineStops = [];
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
MI_Bins = 4096; %hardcoded
Card = [];
TACRange = [];
TACGain = [];
Corrupt = false;
Pixel = [];
Lines = [];
MaxMT = 0;
card = 1;
%%% Reads all selected files
for i=1:numel(FileName)
    %%% Read .set file
    fid = fopen(fullfile(Path, [FileName{1}(1:end-3) 'set']), 'r');
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
%             %%% Determines number of microtime bin
%             if isempty(MI_Bins)
%                 MI_Bins = strfind(Line, 'SP_ADC_RE');
%                 if ~isempty(MI_Bins)
%                     MI_Bins = str2double(Line(20:end-1));
%                 end
%             end
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
        if isempty(MI_Bins)
            msgbox('check code')
            %for the old LSM510, the set file did not contain the
            %MI_Bins
            return
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
        h_msg = msgbox('Setup (.set) file not found!');
        Card = 'SPC-140/150/130';
        MI_Bins = [];
        TACRange = [];
        Collection_Time = NaN;
        pause(1)
        close(h_msg)
        Pixel = NaN;
        Lines = NaN;
    end
    
    % Change Pixels and Lines here if needed; sometimes writting wrong in
    % SPC file
    Lines = Lines;
    Pixel = Pixel;
    
    Progress((i-1)/numel(FileName),h.Progress.Axes, h.Progress.Text,'Loading:');
    
    %%% if multiple files are loaded, consecutive files need to
    %%% be offset in time with respect to the previous file
    %%% Reads data for each tcspc card
    for j = card
        %%% Update Progress
        Progress((i-1)/numel(FileName)+(j-1)/numel(card)/numel(FileName),h.Progress.Axes, h.Progress.Text,['Loading File ' num2str((i-1)*numel(card)+j) ' of ' num2str(numel(FileName)*numel(card))]);
        %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
        
        [MT, MI, Header] = Read_BH(fullfile(Path,FileName{i}), Inf, Card);
        
        %% Extract SyncPeriod and ClockPeriod from Data
        if isempty(FileInfo.SyncPeriod)
            % SPC card does not use laser rep rate as sync, we have to hardcode!
            %FileInfo.SyncPeriod = 12.5e-9; %MaiTai
            FileInfo.SyncPeriod = 5e-8; %488 pulsed
        end
        if isempty(FileInfo.ClockPeriod)
            FileInfo.ClockPeriod = Header.ClockRate^-1;
        end
        
        if ~isempty(Header.LineMarker) % Point data
            %% Remove markers outside of complete frames
            NoF = numel(Header.FrameMarker);
            % remove markers before the first frame marker
            Header.LineMarker(Header.LineMarker < Header.FrameMarker(1)) = [];
            Header.PixelMarker(Header.PixelMarker < Header.FrameMarker(1)) = [];
            % remove line markers after the last full frame
            NoLineMarkers = Lines*NoF;
            if NoLineMarkers > numel(Header.LineMarker)
                while NoLineMarkers > numel(Header.LineMarker)
                    NoF = NoF-1;
                    NoLineMarkers = Lines*NoF;
                end
                % linemarker after the last good one
                AfterLastLine = Header.LineMarker(Lines*NoF+1);
                % delete nonsense pixelmarkers
                Header.PixelMarker(Header.PixelMarker > AfterLastLine) = [];
                Header.PixelMarker(Header.PixelMarker < Header.LineMarker(1)) = [];
                % now there are approximately (xsize+44/256*xsize)*ysize*frames pixel markers
            end
            % delete nonsense markers
            Header.LineMarker = Header.LineMarker(1:Lines*NoF);
            Header.FrameMarker = Header.FrameMarker(1:NoF);
            
            %% Let all Markers start at 1
            FirstLineMarker = Header.LineMarker(1);
            Header.LineMarker = Header.LineMarker-FirstLineMarker+1;
            Header.FrameMarker = Header.FrameMarker-FirstLineMarker+1;
            Header.PixelMarker = Header.PixelMarker-FirstLineMarker+1;
            
            %% Remove photons outside of complete frames
            for i = 1:numel(MT)
                MT{i} = MT{i}-FirstLineMarker+1;
                LastTime = Header.LineMarker(end)+Pixel*mean(diff(Header.PixelMarker));
                mt = MT{i};
                mi = MI{i};
                % remove photons after the last pixel
                mt(mt>LastTime) = [];
                mi(mt>LastTime) = [];
                % remove photons before the first pixel
                mt = mt(mt>0);
                mi = mi(mt>0);
                MT{i} = mt;
                MI{i} = mi;
            end
            clear mt mi
            
            %% Extract Pixel, Frame and Line times
            %%% Extracts frame starts and number of frames from frame-syncs
            FileInfo.ImageTimes = [FileInfo.ImageTimes Header.FrameMarker*FileInfo.ClockPeriod];
            
            %%% Extracts line starts and number of lines from line syncs
            FileInfo.LineTimes = [FileInfo.LineTimes; MaxMT+permute(reshape(Header.LineMarker*FileInfo.ClockPeriod,[],NoF),[2 1])];
            FileInfo.Lines = size(FileInfo.LineTimes,2);
            
            %%% Extracts number of pixels and pixel duration from pixel syncs
            FileInfo.Pixels = Pixel;
            Pixelduration = round(mean(diff(Header.PixelMarker)));
            FileInfo.PixTime = Pixelduration*FileInfo.ClockPeriod;
            
            %% check if image is bidirectional
            % On a Zeiss system:
            % - the 'forward + backward scanning time' is the same on a Zeiss system whether you scan uni or bidir.
            % - that's why bidirectional scanning is exactly twice faster (although it totally shouldn't have to be)
            
            % - if bidirectional, line starts are written left and right (cause the next line starts from the right):
            % start>O0001234567891234567890000000000O
            %       000000000009876543219876543210000<start
            % start>O0001234567891234567890000000000O
            %       000000000009876543219876543210000<start
            % (1234... = pixel bit written and photons recorded,
            %      0/O = pixel bit written and no photons recorded,
            %        O = first and last pixel marker written between two line markers
            %        > = forward (< = backward) scan direction
            %    start = line marker)
            
            % - if unidirectional, line starts are written only left
            % start>O00012345678912345678900000000000
            %       O00000000000000000000000000000000<
            % start>O00012345678912345678900000000000
            %       O00000000000000000000000000000000<
            % start>O00012345678912345678900000000000
            %       O00000000000000000000000000000000<
            
            % check if the n.o. pixel markers between two line starts:
            % index of closest pixel marker to line marker 1
            [~, ind] = min(abs(Header.PixelMarker - Header.LineMarker(1)));
            % index of closest pixel marker to line marker 2
            [~, ind2] = min(abs(Header.PixelMarker - Header.LineMarker(2)));
            BiDir = [];
            if ind2-ind == (1+44/256)*Pixel % for a 256 pixel image, 300 pixel markers between two liner markers
                BiDir = 1; % bidirectional image
            elseif ind2-ind == (1+44/256)*Pixel*2 % for a 256 pixel image, 600 pixel markers between two liner markers
                BiDir = 0; % unidirectional image
            else
                msgbox('check code')
                return
            end
            clear ind ind2
            FileInfo.BiDir = BiDir;
            
            %% Image shift
            % On a Zeiss system:
            % - the first round(16.5*Pixel/512) pixels do not contain photons
            % - the last round((88-17)*xsize/512) pixels do not contain phtons
            % F.e. for a 256 pixel image, the recorded image is 300 pixels, with 8 dark, 256 bright and 36 dark per line.
            % So, we shift the LineTimes such that relevant photons start at
            % pixel 1 per line. Using the pixtime*imsizex, we can calculate
            % like everyone else does (without needing the PixelMarker).
            shift = round(16.5*Pixel/512)*Pixelduration;
            
            %% flip every second line if image is bidrectional
            % we do this at MT/MI level, so the image calculation stays the same
            if BiDir
                pixticks = round(Pixelduration); %1314 ticks
                % loop through all routers and detectors
                for i = 1:numel(MT)
                    mt = MT{i};
                    if numel(mt) > 100000
                        % to which even LineMarker is each photon closest
                        l_even = [1; Header.LineMarker(2:2:end)];
                        if max(mt) > l_even(end)
                            l_even = [l_even; max(mt)];
                        end
                        [~,~,inde] = histcounts(mt,l_even);
                        % indl is the index of the Line Marker closest to the photon
                        % l_even(indl) is the even LineMarker macrotime closest to that of the photon
                        MTe = l_even(inde);
                        
                        % to which uneven LineMarker is each photon closest
                        l_uneven = Header.LineMarker(1:2:end);
                        if max(mt) > l_uneven(end)
                            l_uneven = [l_uneven; max(mt)];
                        end
                        [~,~,indu] = histcounts(mt,l_uneven);
                        % indl is the index of the Line Marker closest to the photon
                        % l_uneven(indlu) is the uneven LineMarker macrotime closest to that of the photon
                        MTu = l_uneven(indu);
                        
                        % photons (indicated xxxx) whose time difference to the next
                        % forward START (indicated StArT) is smaller than the time difference
                        % to the next backward line marker (indicated START) are
                        % on a backward scanning line:
                        % start>O0001234567891234567890000000000O
                        %       00000000000xxxxxxxxxxxxxxxxxx0000<start
                        % StArT>O0001234567891234567890000000000O
                        %       000000000001234567891234567890000<START
                        mtt = mt(MTu < MTe);
                        mi = MI{i};
                        mii = mi(MTu < MTe);
                        
                        % delete all other photons, we sort them later again anyway
                        indu = indu(MTu < MTe);
                        inde = inde(MTu < MTe);
                        
                        % mt is the rest of the photons
                        mt = mt(MTu >= MTe);
                        mi = mi(MTu >= MTe);
                        
                        % flip all backward photons between the linemarkers
                        % f.e. 1200-1190+900-zeiss_shift = 910; the photon goes from the
                        % beginning of the line to the end.
                        mtt = l_uneven(indu) - mtt + l_even(inde)-shift;
                        
                        mt = [mt ; mtt];
                        mi = [mi ; mii];
                        mt(mt<0) = 0;
                        % sort mt again from low to high
                        [mt,I] = sort(mt);
                        %sort MI according to MT
                        mi = mi(I);
                        MT{i} = mt;
                        MI{i} = mi;
                    end
                end
            end
            
            %% Shift the Line and Frame Times (don't know why)
            FileInfo.LineTimes((end+1-NoF):end,:) = FileInfo.LineTimes((end+1-NoF):end,:) + shift*FileInfo.ClockPeriod;
            FileInfo.ImageTimes((end+1-NoF):end,1) = FileInfo.ImageTimes((end+1-NoF):end) + shift*FileInfo.ClockPeriod;        %%% Sets line and frame stops
            FileInfo.LineStops = FileInfo.LineTimes + (Pixel+1)*Pixelduration*FileInfo.ClockPeriod;
            FileInfo.Frames = NoF;
        else % point data
            %FileInfo.ImageTimes = [FileInfo.ImageTimes MaxMT*FileInfo.ClockPeriod];
            %%% Disables image plotting
            h.MT.Use_Image.Value = 0;
            h.MT.Use_Lifetime.Value = 0;
            UserValues.Settings.Pam.Use_Lifetime = 0;
            UserValues.Settings.Pam.Use_Image = 0;
            h.Image.Tab.Parent = [];
            FileInfo.Lines = 1; %Leave here
        end
    
        %% Finds, which routing bits to use
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
        
        %% Concatenates data to previous files and adds ImageTimes
        %%% to consecutive files
        if any(~cellfun(@isempty,MI(:)))
            for k=Rout
                TcspcData.MT{j,k}=[TcspcData.MT{j,k}; MaxMT + MT{k}];   MT{k}=[];
                TcspcData.MI{j,k}=[TcspcData.MI{j,k}; MI{k}];   MI{k}=[];
            end
        end
        %%% Determines last photon for each file
        for k=find(~cellfun(@isempty,TcspcData.MT(j,:)))
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