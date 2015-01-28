function LoadTcspc(~,~,Update_Data,Calibrate_Detector,Caller,FileName,Type)
global UserValues TcspcData FileInfo

if nargin<6 %%% Opens Dialog box for selecting new files to be loaded
    [FileName, Path, Type] = uigetfile({'*0.spc','B&H SPC files recorded with FabSurf (*0.spc)';...
                                        '*_m1.spc','Multi-card B&H SPC files recorded with B&H-Software (*_m1.spc)';...
                                        '*.spc','Single card B&H SPC files recorded with B&H-Software (*.spc)'}, 'Choose a TCSPC data file',UserValues.File.Path,'MultiSelect', 'on');
else %%% Loads predifined Files
    Path = UserValues.File.Path;
end
%%% Only execues if any file was selected
if iscell(FileName) || ~all(FileName==0)    
    %%% Transforms FileName into cell, if it is not already
    %%%(e.g. when only one file was selected)
    if ~iscell(FileName)
        FileName = {FileName};
    end
    %%% Saves Path
    UserValues.File.Path = Path;
    LSUserValues(1);
    %%% Sorts FileName by alphabetical order
    FileName=sort(FileName);
    %%% Clears previously loaded data
    FileInfo=[];
    TcspcData.MT=cell(1,1);
    TcspcData.MI=cell(1,1);
    
    %%% Findes handles for progress axes and text
    h=guidata(Caller);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Checks which file type was selected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch (Type)        
        case 1 
            %% 1: .spc Files generated with Fabsurf    
            FileInfo.FileType = 'FabsurfSPC';
            %%% Reads info file generated by Fabsurf
            FileInfo.Fabsurf=FabsurfInfo(fullfile(Path,FileName{1}));
            %%% General FileInfo
            FileInfo.NumberOfFiles=numel(FileName);
            FileInfo.Type=Type;
            FileInfo.MI_Bins=4096;
            FileInfo.MeasurementTime=FileInfo.Fabsurf.Imagetime/1000;
            FileInfo.ClockPeriod=FileInfo.Fabsurf.RepRate/1000;
            FileInfo.Lines=FileInfo.Fabsurf.Imagelines;
            FileInfo.LineTimes=zeros(FileInfo.Lines+1,numel(FileName));
            FileInfo.Pixels=FileInfo.Fabsurf.Imagelines^2;   
            FileInfo.ScanFreq=FileInfo.Fabsurf.ScanFreqCorrected;
            FileInfo.FileName=FileName;
            FileInfo.Path=Path;
            %%% Initializes microtime and macotime arrays
            TcspcData.MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            TcspcData.MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));  
            
            Totaltime=0;
            %%% Reads all selected files
            for i=1:numel(FileName)               
                %%% Calculates Imagetime in clock ticks for concaternating
                %%% files                
                Info=FabsurfInfo(fullfile(Path,FileName{i}),1);
                Imagetime=round(Info.Imagetime/1000/FileInfo.ClockPeriod);
                %%% Checks, which cards to load
                card = unique(UserValues.Detector.Det);
                
                %%% Checks, which and how many card exist for each file
                    for j=card;
                        if ~exist(fullfile(Path,[FileName{i}(1:end-5) num2str(j-1) '.spc']),'file')
                            card(card==j)=[];
                        end
                    end
                
                Linetimes=[];
                %%% Reads data for each tcspc card
                for j = card
                    %%% Update Progress
                    Progress((i-1)/numel(FileName)+(j-1)/numel(card)/numel(FileName),h.Progress_Axes, h.Progress_Text,['Loading File ' num2str((i-1)*numel(card)+j) ' of ' num2str(numel(FileName)*numel(card))]);
                    %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
                    [MT, MI, PLF,~] = Read_BH(fullfile(Path, FileName{i}),Inf,[0 0 0]);
                    %%% Finds, which routing bits to use
                    Rout = unique(UserValues.Detector.Rout(UserValues.Detector.Det==j))';
                    Rout(Rout>numel(MI)) = [];
                    %%% Concatenates data to previous files and adds Imagetime
                    %%% to consecutive files
                    if any(~cellfun(@isempty,MI))
                        for k = Rout
                            %%% Removes photons detected after "official"
                            %%% end of file are discarded
                            MI{k}(MT{k}>Imagetime)=[];
                            MT{k}(MT{k}>Imagetime)=[];
                            TcspcData.MT{j,k}=[TcspcData.MT{j,k}; Totaltime + MT{k}];   MT{k}=[];
                            TcspcData.MI{j,k}=[TcspcData.MI{j,k}; MI{k}];   MI{k}=[];
                        end
                    end
                    %%% Determines last photon for each file
                    for k=find(~cellfun(@isempty,TcspcData.MT(j,:)));
                        FileInfo.LastPhoton{j,k}(i)=numel(TcspcData.MT{j,k});
                    end
                    
                    %%% Determines, if linesync was used
                    if isempty(Linetimes) && ~isempty(PLF{1})
                        Linetimes=[0 PLF{1}];
                    elseif isempty(Linetimes) && ~isempty(PLF{2})
                        Linetimes=[0 PLF{2}];
                    elseif isempty(Linetimes) && ~isempty(PLF{3})
                        Linetimes=[0 PLF{3}];
                    end
                end
                %%% Creates linebreak entries
                if isempty(Linetimes)
                    FileInfo.LineTimes(:,i)=linspace(0,FileInfo.MeasurementTime/FileInfo.ClockPeriod,FileInfo.Lines+1)+Totaltime;
                elseif numel(Linetimes)==FileInfo.Lines+1
                    FileInfo.LineTimes(:,i)=Linetimes+Totaltime;
                elseif numel(Linetimes)<FileInfo.Lines+1
                    %%% I was to lazy to program this case out yet
                end
                %%% Calculates total time to get one trace from several
                %%% files
                Totaltime=Totaltime + Imagetime;
                
            end
        case {2, 3}
            %% 2: '*_m1.spc', 'Multi-card B&H SPC files recorded with B&H-Software (*_m1.spc)'
            %  3: '*.spc',    'Single card B&H SPC files recorded with B&H-Software (*.spc)'
            %%% Usually, here no Imaging Information is needed
            FileInfo.FileType = 'SPC';
            %%% General FileInfo
            FileInfo.NumberOfFiles = numel(FileName);
            FileInfo.Type = Type;
            
            % Read .set file
            setfile = fullfile(Path, [FileName{1}(1:end-3) 'set']);
            try
                fid = fopen(setfile, 'r');
                
                % no. TAC or ADC channels
                c = [];
                while isempty(c)
                    a = fgetl(fid);
                    c = strfind(a, 'SP_ADC_RE');
                end
                if strcmp(a(20:end-1), '256')
                    MI_Bins = 256;
                elseif strcmp(a(20:end-1), '4096')
                    MI_Bins = 4096;
                end
                frewind(fid);

                % spc module name
                c = [];
                while isempty(c)
                    a = fgetl(fid);
                    c = strfind(a, 'with module SPC-');
                end
                if strcmp(a(18:20), '630')
                    if MI_Bins == 256
                        Card = 'SPC-630 256chs';
                    elseif MI_Bins == 4096
                        Card = 'SPC-630 4096chs';
                    end
                else % SPC140/150 card
                    Card = 'SPC-140/150';
                end
                frewind(fid);
                
                % TAC range in seconds
                c = [];
                while isempty(c)
                    a = fgetl(fid);
                    c = strfind(a, 'SP_TAC_R,');
                end
                TACRange = str2double(a(19:end-1));
                fclose(fid);
            catch %if there is no set file, the B&H software was likely not used
                h = msgbox('Setup (.set) file not found!');
                Card = 'SPC-140/150';
                MI_Bins = 4096;
                TACRange = [];
                pause(1)
                close(h)
            end
            
            FileInfo.Card = Card;
            FileInfo.MI_Bins = MI_Bins;
            FileInfo.MeasurementTime = [];
            FileInfo.ClockPeriod = [];
            FileInfo.TACRange = TACRange; %in seconds
            FileInfo.Lines = 1;
            FileInfo.LineTimes = [];
            FileInfo.Pixels = 1;
            FileInfo.ScanFreq = 1000;
            FileInfo.FileName = FileName;
            FileInfo.Path = Path;
            
            %%% Initializes microtime and macotime arrays
            TcspcData.MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            TcspcData.MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            
            %%% Reads all selected files
            for i=1:numel(FileName)
                %%% there are a number of *_m(i).spc files associated with the
                %%% *_m1.spc file
                
                %%% Checks, which cards to load
                card = unique(UserValues.Detector.Det);
                
                %%% Checks, which and how many card exist for each file
                if Type == 2
                    for j = card;
                        if ~exist(fullfile(Path,[FileName{i}(1:end-5) num2str(j) '.spc']),'file')
                            card(card==j)=[];
                        end
                    end
                else
                    card = 1;
                end
                
                Progress((i-1)/numel(FileName),h.Progress_Axes, h.Progress_Text,'Loading:');           
                
                %%% if multiple files are loaded, consecutive files need to
                %%% be offset in time with respect to the previous file
                MaxMT = 0;
                if any(~cellfun(@isempty,TcspcData.MT))
                    MaxMT = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))));
                end
                %%% Reads data for each tcspc card
                for j = card    
                    %%% Update Progress
                    Progress((i-1)/numel(FileName)+(j-1)/numel(card)/numel(FileName),h.Progress_Axes, h.Progress_Text,['Loading File ' num2str((i-1)*numel(card)+j) ' of ' num2str(numel(FileName)*numel(card))]);
                    %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
                    if Type == 2
                        FileName{i} = [FileName{i}(1:end-5) num2str(j) '.spc'];
                    end
                    [MT, MI, ~, ClockRate] = Read_BH(fullfile(Path,FileName{i}), Inf, [0 0 0], FileInfo.Card, FileInfo.MI_Bins);
                    if isempty(FileInfo.ClockPeriod)
                        FileInfo.ClockPeriod = 1/ClockRate;
                    end
                    %%% Finds, which routing bits to use
                    Rout=unique(UserValues.Detector.Rout(UserValues.Detector.Det==j))';
                    Rout(Rout>numel(MI))=[];
                    %%% Concaternates data to previous files and adds Imagetime
                    %%% to consecutive files
                    if any(~cellfun(@isempty,MI))
                        for k=Rout'
                            TcspcData.MT{j,k}=[TcspcData.MT{j,k}; MaxMT + MT{k}];   MT{k}=[];
                            TcspcData.MI{j,k}=[TcspcData.MI{j,k}; MI{k}];   MI{k}=[];
                        end
                    end
                    %%% Determines last photon for each file
                    for k=find(~cellfun(@isempty,TcspcData.MT(j,:)));
                        FileInfo.LastPhoton{j,k}(i)=numel(TcspcData.MT{j,k});
                    end
                end
            end
            FileInfo.MeasurementTime = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))))*FileInfo.ClockPeriod;
            FileInfo.LineTimes = [0 FileInfo.MeasurementTime];
%             try 
%                 %%% try to read the TACRange from the *_m1.set file
%                 FileInfo.TACRange = GetTACrange(fullfile(FileInfo.Path,[FileInfo.FileName{1}(1:end-3) 'set']));
%             catch 
%                 %%% instead, approximate the TAC range from the microtime
%                 %%% range and Repetition Rate
%                 MicrotimeRange = double(max(cellfun(@(x) max(x)-min(x),TcspcData.MI(~cellfun(@isempty,TcspcData.MI)))));
%                 FileInfo.TACRange = (FileInfo.MI_Bins/MicrotimeRange)*FileInfo.ClockPeriod;
%             end
    end
Progress(1,h.Progress_Axes, h.Progress_Text);
%%% Applies detector shift immediately after loading data    
Calibrate_Detector([],[],0) 
%%% Updates the Pam meta Data; needs inputs 3 and 4 to be zero
Update_Data([],[],0,0);  
end

function [TACrange] = GetTACrange(FileName)
%%% This functions reads out the set TAC range from the *.set file
%%% generated by the B&H software

%read data into array
TextArray = importdata(FileName);

%find the cells with TAC range and gain

%TAC range is given by 'SP_TAC_R'
idx_range = find(~cellfun(@isempty, (strfind(TextArray, 'SP_TAC_R'))));
dummy = strsplit(TextArray{idx_range},',');
%now the last element contains the value
range = dummy{end};
%last character is a ']'
range = str2double(range(1:end-1));
%TAC gain is given by 'SP_TAC_G'
idx_gain = find(~cellfun(@isempty, (strfind(TextArray, 'SP_TAC_G'))));
dummy = strsplit(TextArray{idx_gain},',');
gain = dummy{end};
gain = str2double(gain(1:end-1));

%calculate the TACrange
TACrange = range/gain;


