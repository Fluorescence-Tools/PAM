function [MT, MI,SyncRate,Resolution,PLF] = Read_HT3(FileName,NoE,ProgressAxes,ProgressText,FileNumber,NumFiles,mode,Chunkwise)
% Read-in routine for *.ht3 files recorded with HydraHarp400
%
% Args:
%   * Filename: Full path to file
%   * NoE: Number of photon entries to load
%   * ProgressAxes: Handle to the progress axis
%   * ProgressText: Handle to the progress text field
%   * FileNumber: Number of the file to be loaded
%   * Numfiles: Total number of files to be read
%   * mode: Filetype: mode=1 for *.ht3 files recorded with PicoQuant software, mode=2 for *.ht3 files recorded with Fabsurf software
%   * Chunkwise: Chunkwise data read-in with maximium file size (so far
%                hard coded but to be implemented into GUI)
%
% Returns:
%   * MT: Cell array of macrotimes in the file for every detector
%   * MI: Cell array of microtimes in the file for every detector
%   * SyncRate: Repetition rate/TAC range
%   * Resolution: Microtime resolution in picoseconds
%   * PLF: Linesyncs

fid=fopen(FileName,'r');
fseek(fid,0,1);
filesize = ftell(fid);
fseek(fid,0,-1);
switch mode
    case {1,3} %%% .ht3 file from HydraHarp Software, read whole header etc...
        Progress(0/NumFiles,ProgressAxes,ProgressText,['Processing Header of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % ASCII file header
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        Ident = char(fread(fid, 16, 'char'));
        FormatVersion = deblank(char(fread(fid, 6, 'char')'));
        
        if strcmp(FormatVersion,'1.0')
            Version = 1;
        elseif strcmp(FormatVersion,'2.0')
            Version = 2;
        end;
        
        CreatorName = char(fread(fid, 18, 'char'));
        CreatorVersion = char(fread(fid, 12, 'char'));
        FileTime = char(fread(fid, 18, 'char'));
        CRLF = char(fread(fid, 2, 'char'));
        Comment = char(fread(fid, 256, 'char'));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % Binary file header
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % The binary file header information is indentical to that in HHD files.
        % Note that some items are not meaningful in the time tagging modes
        % therefore we do not output them.
        
        NumberOfCurves = fread(fid, 1, 'int32');
        BitsPerRecord = fread(fid, 1, 'int32');
        ActiveCurve = fread(fid, 1, 'int32');
        MeasurementMode = fread(fid, 1, 'int32');
        SubMode = fread(fid, 1, 'int32');
        Binning = fread(fid, 1, 'int32');
        Resolution = fread(fid, 1, 'double');
        
        Header.Resolution = Resolution;
        
        Offset = fread(fid, 1, 'int32');
        Tacq = fread(fid, 1, 'int32');
        
        StopAt = fread(fid, 1, 'uint32');
        StopOnOvfl = fread(fid, 1, 'int32');
        Restart = fread(fid, 1, 'int32');
        DispLinLog = fread(fid, 1, 'int32');
        DispTimeAxisFrom = fread(fid, 1, 'int32');
        DispTimeAxisTo = fread(fid, 1, 'int32');
        DispCountAxisFrom = fread(fid, 1, 'int32');
        DispCountAxisTo = fread(fid, 1, 'int32');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        for i = 1:8
            DispCurveMapTo(i) = fread(fid, 1, 'int32');
            DispCurveShow(i) = fread(fid, 1, 'int32');
        end;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        for i = 1:3
            ParamStart(i) = fread(fid, 1, 'float');
            ParamStep(i) = fread(fid, 1, 'float');
            ParamEnd(i) = fread(fid, 1, 'float');
        end;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        RepeatMode = fread(fid, 1, 'int32');
        RepeatsPerCurve = fread(fid, 1, 'int32');
        RepatTime = fread(fid, 1, 'int32');
        RepeatWaitTime = fread(fid, 1, 'int32');
        ScriptName = char(fread(fid, 20, 'char'));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %          Hardware information header
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        HardwareIdent = char(fread(fid, 16, 'char'));
        HardwarePartNo = char(fread(fid, 8, 'char'));
        HardwareSerial = fread(fid, 1, 'int32');
        nModulesPresent = fread(fid, 1, 'int32');
        
        for i=1:10
            ModelCode(i) = fread(fid, 1, 'int32');
            VersionCode(i) = fread(fid, 1, 'int32');
        end;
        
        BaseResolution = fread(fid, 1, 'double');
        InputsEnabled = fread(fid, 1, 'ubit64');
        InpChansPresent  = fread(fid, 1, 'int32');
        RefClockSource  = fread(fid, 1, 'int32');
        ExtDevices  = fread(fid, 1, 'int32');
        MarkerSettings  = fread(fid, 1, 'int32');
        
        SyncDivider = fread(fid, 1, 'int32');
        SyncCFDLevel = fread(fid, 1, 'int32');
        SyncCFDZeroCross = fread(fid, 1, 'int32');
        SyncOffset = fread(fid, 1, 'int32');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %          Channels' information header
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        for i=1:InpChansPresent
            InputModuleIndex(i) = fread(fid, 1, 'int32');
            InputCFDLevel(i) = fread(fid, 1, 'int32');
            InputCFDZeroCross(i) = fread(fid, 1, 'int32');
            InputOffset(i) = fread(fid, 1, 'int32');
        end;
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %                Time tagging mode specific header
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        for i=1:InpChansPresent
            InputRate(i) = fread(fid, 1, 'int32');
        end;
        
        SyncRate = fread(fid, 1, 'int32');
        
        Header.SyncRate = double(SyncRate);
        Header.ClockRate = Header.SyncRate; % the MT clock is the syncrate
        
        StopAfter = fread(fid, 1, 'int32');
        
        StopReason = fread(fid, 1, 'int32');
        
        ImgHdrSize = fread(fid, 1, 'int32');
        
        nRecords = fread(fid, 1, 'uint64');
        
        % Special header for imaging. How many of the following ImgHdr array elements
        % are actually present in the file is indicated by ImgHdrSize above.
        % Storage must be allocated dynamically if ImgHdrSize other than 0 is found.
        
        ImgHdr = fread(fid, ImgHdrSize, 'int32');  % You have to properly interpret ImgHdr if you want to generate an image
        
        
        % The header section end after ImgHdr. Following in the file are only event records.
        % How many of them actually are in the file is indicated by nRecords in above.
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  This reads the T3 mode event records
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % The macrotime clock rate is the syncrate.
        syncperiod = 1E9/SyncRate;      % in nanoseconds
        
        OverflowCorrection = 0;
        T3WRAPAROUND=1024;
        
        Progress(0.1/NumFiles,ProgressAxes,ProgressText,['Reading Byte Record of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        if Chunkwise
            if filesize > 2E9
                filesize = 2E9;
                msgbox('Maximum filesize reached. Loading ~2 GB...', 'Warning','warn');
                T3Record = zeros(filesize/4,1);
                fileChunks = ceil(filesize/NoE);
                for i = 1:fileChunks
                    T3Record((i-1)*NoE/4+1:i*(NoE/4)) = fread(fid, NoE/4, 'ubit32');     % all 32 bits:
                end
            else
                T3Record = zeros(filesize/4,1);
                fileChunks = ceil(filesize/NoE);
                for i = 1:fileChunks-1
                    T3Record((i-1)*NoE/4+1:i*(NoE/4)) = fread(fid, NoE/4, 'ubit32');     % all 32 bits:
                end
                T3Record(end-mod(filesize/4,NoE/4)+1:end) = fread(fid, NoE/4, 'ubit32');
            end
        else
            T3Record = fread(fid, Inf, 'ubit32');
        end
        
        Progress(0.2/NumFiles,ProgressAxes,ProgressText,['Reading Macrotime of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        nsync = int16(bitand(T3Record,1023));       % the lowest 10 bits:
        
        Progress(0.3/NumFiles,ProgressAxes,ProgressText,['Reading Microtime of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        dtime = uint16(bitand(bitshift(T3Record,-10),32767));   % the next 15 bits:
        %   the dtime unit depends on "Resolution" that can be obtained from header
        
        Progress(0.4/NumFiles,ProgressAxes,ProgressText,['Reading Channel of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        channel = int8(bitand(bitshift(T3Record,-25),63));   % the next 6 bits:
        
        Progress(0.5/NumFiles,ProgressAxes,ProgressText,['Reading Special Records of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        special = logical(bitand(bitshift(T3Record,-31),1));   % the last bit:
        
        clear T3Record
        
        Progress(0.6/NumFiles,ProgressAxes,ProgressText,['Processing Overflows of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        if Version == 1
            
            %waitbar(0.6,h,'Extracting Eventtimes according to Data Format Version 1 Scheme')
            
            TimeTag = zeros(1,nRecords);
            
            TimeTag(special == 1 & channel == 63) = double(T3WRAPAROUND);
            TimeTag = cumsum(TimeTag);
            TimeTag = double(nsync)+TimeTag';
            if mode == 3
                % Seidel-CLSM, read out line start stop and frame start
                LineStartMarker = 1;
                LineStopMarker = 2;
                FrameStartMarker = 3;
                % imaging marker timetags
                FrameStart = TimeTag(special == 1 & channel < 15 & bitget(channel,FrameStartMarker))';
                LineStart = TimeTag(special == 1 & channel < 15 & bitget(channel,LineStartMarker))';
                LineStop = TimeTag(special == 1 & channel < 15 & bitget(channel,LineStopMarker))';
                PLF = {FrameStart, LineStart, LineStop};
            end
            
            ValidIndices = find(special == 0 | ((channel>=1)&(channel<=15))); % these are photons
            %TimeTag(ValidIndices) = double(nsync(ValidIndices))+TimeTag(ValidIndices)';
            TimeTag = TimeTag(ValidIndices);
            channel = channel(ValidIndices);
            dtime = dtime(ValidIndices);
            
        elseif Version == 2
            
            %waitbar(0.6,h,'Extracting Eventtimes according to Data Format Version 2 Scheme')
            
            %     TimeTag = zeros(1,nRecords);
            %     TimeTag(special == 1 & channel == 63 & nsync ~= 0) = double(T3WRAPAROUND.*nsync(special == 1 & channel == 63));
            %     waitbar(0.7,h)
            %     TimeTag(special == 1 & channel == 63 & nsync == 0) = double(T3WRAPAROUND);
            %     TimeTag = cumsum(TimeTag);
            %     waitbar(0.8,h)
            %     ValidIndices = find(special == 0 | ((channel>=1)&(channel<=15)));
            %     TimeTag(ValidIndices) = double(nsync(ValidIndices))+TimeTag(ValidIndices)';
            %     waitbar(0.9,h)
            %     TimeTag = TimeTag(ValidIndices);
            %     channel = channel(ValidIndices);
            %     dtime = dtime(ValidIndices);
            
            
            OverflowCorrection = zeros(1,nRecords);
            OverflowCorrection( (special == 1) & (channel == 63) & (nsync == 0) ) = 1;
            OverflowCorrection( (special == 1) & (channel == 63) & (nsync ~= 0) ) = nsync( (special == 1) & (channel == 63) & (nsync ~= 0) );
            OverflowCorrection = T3WRAPAROUND.*cumsum(OverflowCorrection);
            
            ValidIndices = ( (special == 0) & (channel >=0) & (channel<=15) );
            %OverflowCorrection(ValidIndices) = dtime(ValidIndices) + OverflowCorrection(ValidIndices);
            TimeTag = double(nsync(ValidIndices))' + OverflowCorrection(ValidIndices);
            channel = channel(ValidIndices);
            dtime = dtime(ValidIndices);
        else
            fprintf(1,'\n\n      Warning: This program is for File version 1.0 and 2.0 only. The process has been aborted please check sourcode to add compatibility for other fleversions.');
            STOP;
        end
    case 2 %%% FabSurf HydraHarp File
        %%% First Byte contains SyncRate
        %%% Rest containst Photon Information
        Resolution = 16;
        T3WRAPAROUND=1024;
        if Chunkwise
            if filesize > 1E9
                filesize = 1E9;
                warn = msgbox('Maximum filesize reached. Loading ~2 GB...', 'Warning','warn');
%                 T3Record = zeros(filesize/4,1);
                nsync = zeros(filesize/4-1,1);
                dtime = zeros(filesize/4-1,1);
                channel = zeros(filesize/4-1,1);
                special = zeros(filesize/4-1,1);
                fileChunks = ceil(filesize/NoE);
                for i = 1:fileChunks
                    Progress(i/fileChunks*(0.5/NumFiles),ProgressAxes,ProgressText,['Reading Data of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
                    T3Record = fread(fid, NoE/4, 'ubit32');
                    if i == 1
                        SyncRate = 1E10/T3Record(1);T3Record(1) = [];
                        nsync(1:i*(NoE/4)-1) = int16(bitand(T3Record,1023));       % the lowest 10 bits:
                        dtime(1:i*(NoE/4)-1) = uint16(bitand(bitshift(T3Record,-10),32767));   % the next 15 bits:
                        %   the dtime unit depends on "Resolution" that can be obtained from header
                        channel(1:i*(NoE/4)-1) = int8(bitand(bitshift(T3Record,-25),63));   % the next 6 bits:
                        special(1:i*(NoE/4)-1) = logical(bitand(bitshift(T3Record,-31),1));   % the last bit:
                    else
                        nsync((i-1)*NoE/4+1:i*(NoE/4)) = int16(bitand(T3Record,1023));       % the lowest 10 bits:
                        dtime((i-1)*NoE/4+1:i*(NoE/4)) = uint16(bitand(bitshift(T3Record,-10),32767));   % the next 15 bits:
                        %   the dtime unit depends on "Resolution" that can be obtained from header
                        channel((i-1)*NoE/4+1:i*(NoE/4)) = int8(bitand(bitshift(T3Record,-25),63));   % the next 6 bits:
                        special((i-1)*NoE/4+1:i*(NoE/4)) = logical(bitand(bitshift(T3Record,-31),1));   % the last bit:
                    end
                    clear T3Record     % all 32 bits:
                end
                delete(warn);
            else
                nsync = zeros(filesize/4-1,1);
                dtime = zeros(filesize/4-1,1);
                channel = zeros(filesize/4-1,1);
                special = zeros(filesize/4-1,1);
                fileChunks = ceil(filesize/NoE);
                for i = 1:fileChunks-1
                    Progress(i/fileChunks*(0.5/NumFiles),ProgressAxes,ProgressText,['Reading Data of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
                    T3Record = fread(fid, NoE/4, 'ubit32');
                    if i == 1
                        SyncRate = 1E10/T3Record(1);T3Record(1) = [];
                        nsync(1:i*(NoE/4)-1) = int16(bitand(T3Record,1023));       % the lowest 10 bits:
                        dtime(1:i*(NoE/4)-1) = uint16(bitand(bitshift(T3Record,-10),32767));   % the next 15 bits:
                        %   the dtime unit depends on "Resolution" that can be obtained from header
                        channel(1:i*(NoE/4)-1) = int8(bitand(bitshift(T3Record,-25),63));   % the next 6 bits:
                        special(1:i*(NoE/4)-1) = logical(bitand(bitshift(T3Record,-31),1));   % the last bit:
                    else
                        nsync((i-1)*NoE/4+1:i*(NoE/4)) = int16(bitand(T3Record,1023));       % the lowest 10 bits:
                        dtime((i-1)*NoE/4+1:i*(NoE/4)) = uint16(bitand(bitshift(T3Record,-10),32767));   % the next 15 bits:
                        %   the dtime unit depends on "Resolution" that can be obtained from header
                        channel((i-1)*NoE/4+1:i*(NoE/4)) = int8(bitand(bitshift(T3Record,-25),63));   % the next 6 bits:
                        special((i-1)*NoE/4+1:i*(NoE/4)) = logical(bitand(bitshift(T3Record,-31),1));   % the last bit:
                    end
                end
                T3Record = fread(fid, NoE/4, 'ubit32');
                Progress(0.5/NumFiles,ProgressAxes,ProgressText,['Reading Data of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
                nsync(end-mod(filesize/4-1,NoE/4)+1:end)= int16(bitand(T3Record,1023));       % the lowest 10 bits:
                dtime(end-mod(filesize/4-1,NoE/4)+1:end) = uint16(bitand(bitshift(T3Record,-10),32767));   % the next 15 bits:
                %   the dtime unit depends on "Resolution" that can be obtained from header
                channel(end-mod(filesize/4-1,NoE/4)+1:end) = int8(bitand(bitshift(T3Record,-25),63));   % the next 6 bits:
                special(end-mod(filesize/4-1,NoE/4)+1:end) = logical(bitand(bitshift(T3Record,-31),1));   % the last bit:
                clear T3Record
            end
        else
            Progress(0.1/NumFiles,ProgressAxes,ProgressText,['Reading Byte Record of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
            T3Record = fread(fid, Inf, 'ubit32');
            % end
            SyncRate = 1E10/T3Record(1);T3Record(1) = [];
            % nRecords = numel(T3Record);
            
            Progress(0.2/NumFiles,ProgressAxes,ProgressText,['Reading Macrotime of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
            
            nsync = int16(bitand(T3Record,1023));       % the lowest 10 bits:
            
            Progress(0.3/NumFiles,ProgressAxes,ProgressText,['Reading Microtime of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
            
            dtime = uint16(bitand(bitshift(T3Record,-10),32767));   % the next 15 bits:
            %   the dtime unit depends on "Resolution" that can be obtained from header
            
            Progress(0.4/NumFiles,ProgressAxes,ProgressText,['Reading Channel of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
            
            channel = int8(bitand(bitshift(T3Record,-25),63));   % the next 6 bits:
            
            Progress(0.5/NumFiles,ProgressAxes,ProgressText,['Reading Special Records of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
            
            special = logical(bitand(bitshift(T3Record,-31),1));   % the last bit:
            
            clear T3Record
        end
        nRecords = length(nsync);
        
        Progress(0.6/NumFiles,ProgressAxes,ProgressText,['Processing Overflows of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        OverflowCorrection = zeros(1,nRecords);
        OverflowCorrection( (special == 1) & (channel == 63) & (nsync == 0) ) = 1;
        OverflowCorrection( (special == 1) & (channel == 63) & (nsync ~= 0) ) = nsync( (special == 1) & (channel == 63) & (nsync ~= 0) );
        OverflowCorrection = T3WRAPAROUND.*cumsum(OverflowCorrection);
        
        %%Read out LineTimes
        PLF=cell(3,1);
        LB = (special == 1) & (channel == 1);
        PLF{2} = double(nsync(LB))' + OverflowCorrection(LB); 
        
        ValidIndices = ( (special == 0) & (channel >=0) & (channel<=15) );
        %OverflowCorrection(ValidIndices) = dtime(ValidIndices) + OverflowCorrection(ValidIndices);
        TimeTag = double(nsync(ValidIndices))' + OverflowCorrection(ValidIndices);
        channel = channel(ValidIndices);
        dtime = dtime(ValidIndices);
end
Progress(0.9/NumFiles,ProgressAxes,ProgressText,['Finishing up of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);

MT = cell(10,1);
MI = cell(10,1);
for i=unique(channel)'
    MT{i+1} = TimeTag(channel==i)';
    MI{i+1} = dtime(channel==i);
end

Progress(1/NumFiles,ProgressAxes,ProgressText, ['File ' num2str(FileNumber) ' of ' num2str(NumFiles) ' loaded']);

end
