function [MT, MI, Header] = Read_PTU(FileName,NoE,ProgressAxes,ProgressText,FileNumber,NumFiles)

%%% Input parameters:
%%% Filename: Full filename
%%% NoE: Maximal number of entries to load
fid=fopen(FileName,'r');

Progress(0/NumFiles,ProgressAxes,ProgressText,['Processing Header of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ASCII file header processing
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% some constants
tyEmpty8      = hex2dec('FFFF0008');
tyBool8       = hex2dec('00000008');
tyInt8        = hex2dec('10000008');
tyBitSet64    = hex2dec('11000008');
tyColor8      = hex2dec('12000008');
tyFloat8      = hex2dec('20000008');
tyTDateTime   = hex2dec('21000008');
tyFloat8Array = hex2dec('2001FFFF');
tyAnsiString  = hex2dec('4001FFFF');
tyWideString  = hex2dec('4002FFFF');
tyBinaryBlob  = hex2dec('FFFFFFFF');
% RecordTypes
rtPicoHarpT3     = hex2dec('00010303');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $03 (T3), HW: $03 (PicoHarp)
rtPicoHarpT2     = hex2dec('00010203');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $02 (T2), HW: $03 (PicoHarp)
rtHydraHarpT3    = hex2dec('00010304');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $03 (T3), HW: $04 (HydraHarp)
rtHydraHarpT2    = hex2dec('00010204');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $02 (T2), HW: $04 (HydraHarp)
rtHydraHarp2T3   = hex2dec('01010304');% (SubID = $01 ,RecFmt: $01) (V2), T-Mode: $03 (T3), HW: $04 (HydraHarp)
rtHydraHarp2T2   = hex2dec('01010204');% (SubID = $01 ,RecFmt: $01) (V2), T-Mode: $02 (T2), HW: $04 (HydraHarp)
rtTimeHarp260NT3 = hex2dec('00010305');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $03 (T3), HW: $05 (TimeHarp260N)
rtTimeHarp260NT2 = hex2dec('00010205');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $02 (T2), HW: $05 (TimeHarp260N)
rtTimeHarp260PT3 = hex2dec('00010306');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $03 (T3), HW: $06 (TimeHarp260P)
rtTimeHarp260PT2 = hex2dec('00010206');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $02 (T2), HW: $06 (TimeHarp260P)

% Globals for subroutines
TTResultFormat_TTTRRecType = 0;
TTResult_NumberOfRecords = 0;
%Create a structure called Header to store all the outputs of Read_PTU
%function
Header = struct;
Header.MeasDesc_Resolution = 0;
Header.MeasDesc_GlobalResolution = 0;

Magic = fread(fid, 8, '*char');
if not(strcmp(Magic(Magic~=0)','PQTTTR'))
    error('Magic invalid, this is not an PTU file.');
    return;
end
Version = fread(fid, 8, '*char');

%%% Following code reads out all values from header

% there is no repeat.. until (or do..while) construct in matlab so we use
% while 1 ... if (expr) break; end; end;
while 1
    % read Tag Head
    TagIdent = fread(fid, 32, '*char'); % TagHead.Ident
    TagIdent = (TagIdent(TagIdent ~= 0))'; % remove #0 and more more readable
    TagIdx = fread(fid, 1, 'int32');    % TagHead.Idx
    TagTyp = fread(fid, 1, 'uint32');   % TagHead.Typ
    % TagHead.Value will be read in the
    % right type function
    if TagIdx > -1
        EvalName = [TagIdent '(' int2str(TagIdx + 1) ')'];
    else
        EvalName = TagIdent;
    end
    %fprintf(1,'\n   %-40s', EvalName);
    % check Typ of Header
    switch TagTyp
        case tyEmpty8
            fread(fid, 1, 'int64');
            %fprintf(1,'<Empty>');
        case tyBool8
            TagInt = fread(fid, 1, 'int64');
            if TagInt==0
                %fprintf(1,'FALSE');
                eval([EvalName '=false;']);
            else
                %fprintf(1,'TRUE');
                eval([EvalName '=true;']);
            end
        case tyInt8
            TagInt = fread(fid, 1, 'int64');
            %fprintf(1,'%d', TagInt);
            eval([EvalName '=TagInt;']);
        case tyBitSet64
            TagInt = fread(fid, 1, 'int64');
            %fprintf(1,'%X', TagInt);
            eval([EvalName '=TagInt;']);
        case tyColor8
            TagInt = fread(fid, 1, 'int64');
            %fprintf(1,'%X', TagInt);
            eval([EvalName '=TagInt;']);
        case tyFloat8
            TagFloat = fread(fid, 1, 'double');
            %fprintf(1, '%e', TagFloat);
            eval([EvalName '=TagFloat;']);
        case tyFloat8Array
            TagInt = fread(fid, 1, 'int64');
            %fprintf(1,'<Float array with %d Entries>', TagInt / 8);
            fseek(fid, TagInt, 'cof');
        case tyTDateTime
            TagFloat = fread(fid, 1, 'double');
            %fprintf(1, '%s', datestr(datenum(1899,12,30)+TagFloat)); % display as Matlab Date String
            eval([EvalName '=datenum(1899,12,30)+TagFloat;']); % but keep in memory as Matlab Date Number
        case tyAnsiString
            TagInt = fread(fid, 1, 'int64');
            TagString = fread(fid, TagInt, '*char');
            TagString = (TagString(TagString ~= 0))';
            %fprintf(1, '%s', TagString);
            if TagIdx > -1
                EvalName = [TagIdent '(' int2str(TagIdx + 1) ',:)'];
            end;
            if strcmp(TagIdent,'UsrHeadName') && exist('UsrHeadName','var')
                %%% Catch case where length of TagString exceeds length of
                %%% UsrHeadName character array
                if eval(['size(' TagIdent ',2) < numel(TagString)'])
                    eval([TagIdent '(:,end:numel(TagString)) = '' '''])
                end
            end
            eval([EvalName '=TagString;']);
        case tyWideString
            % Matlab does not support Widestrings at all, just read and
            % remove the 0's (up to current (2012))
            TagInt = fread(fid, 1, 'int64');
            TagString = fread(fid, TagInt, '*char');
            TagString = (TagString(TagString ~= 0))';
            %fprintf(1, '%s', TagString);
            if TagIdx > -1
                EvalName = [TagIdent '(' int2str(TagIdx + 1) ',:)'];
            end;
            eval([EvalName '=TagString;']);
        case tyBinaryBlob
            TagInt = fread(fid, 1, 'int64');
            %fprintf(1,'<Binary Blob with %d Bytes>', TagInt);
            fseek(fid, TagInt, 'cof');
        otherwise
            error('Illegal Type identifier found! Broken file?');
    end;
    if strcmp(TagIdent, 'Header_End')
        break
    end
end

%%% Assign values from header to output variables
Header.SyncRate = 1/MeasDesc_GlobalResolution;
Header.Resolution = MeasDesc_Resolution./HW_BaseResolution;
nRecords = TTResult_NumberOfRecords;
%%% check for file type

switch TTResultFormat_TTTRRecType
    case {rtHydraHarpT3,rtHydraHarp2T3}
        if TTResultFormat_TTTRRecType == rtHydraHarpT3
            %%% HydraHarp T3 V1 file format
            Version = 1;
        elseif TTResultFormat_TTTRRecType == rtHydraHarp2T3
            %%% HydraHarp T3 V2 file format
            Version = 2;
        else
            disp('Only HydraHarp T3 V1 or V2 file format supported at the moment.');
            return;
        end
        
        %Header.Measurement_SubMode = Measurement_SubMode;
        
        %{
        Measurement_Submode
        -------------------
        Can take the values OSC, INT, TRES, IMG (enumerated starting with 0):
        0: OSC means "oscillator mode" (a special online measurement mode, rarely used)
        1: INT means "integrating", (standard mode, also for point measurements)
        2: TRES means "Time Resolved Emission Spectra" (one histogram per wavelength step)
        3: IMG means image
        
        Normally the above should be correctly in the PTU file; in practice
        it is not, so we use the presence of linestart info etc. to check
        whether imaging was done
        %}

        Header.PixX = 0;
        Header.PixY = 0;
        Header.bidir = 0;
        Header.FrameStartMarker = 0;
        Header.LineMarker = 0;
        Header.NoF = 1;
        
        if exist ('ImgHdr_PixX', 'var') % Number of pixels in the x direction
            Header.PixX = ImgHdr_PixX; end
        if exist ('ImgHdr_PixY' , 'var') % Number of pixels in the y direction
            Header.PixY =  ImgHdr_PixY; end
        if exist ('ImgHdr_BiDirect', 'var') % Bidirectional image
            Header.bidir = ImgHdr_BiDirect; end
        if exist ('ImgHdr_Frame', 'var') % frame bit. should be 4.
            Header.FrameStartMarker = ImgHdr_Frame; end
        if exist ('ImgHdr_LineStart', 'var')
            Header.LineMarker = ImgHdr_LineStart;  end
        if exist ('NumberOfFrames', 'var')
            Header.NoF = NumberOfFrames; end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  This reads the T3 mode event records
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%% File format:
        %%%% Bit/Byte 1      2      3      4      5      6      7      8
        %%%%       1  MT1    MT2    MT3    MT4    MT5    MT6    MT7    MT8
        %%%%       2  MT9    MT10   MI1    MI2    MI3    MI4    MI5    MI6
        %%%%       3  MI7    MI8    MI9    MI10   MI11   MI12   MI13   MI14
        %%%%       4  MI15   CH1    CH2    CH3    CH4    CH5    CH6    SPEC
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % SPECIAL:
        %    0: regular input channel
        %    1: special record (line, frame)
        % CHANNEL:
        %   if Special = 0:
        %    63: macrotime overflow (nsync) occured
        %    0-15: these are TCSPC detector channel identifiers
        %   if Special = 1:
        %    >=1, <=15: these are imaging markers
        % NSYNC:
        %    0: old style single overflow
        
        
        T3WRAPAROUND=1024;
        
        Progress(0.1/NumFiles,ProgressAxes,ProgressText,['Reading Byte Record of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        T3Record = fread(fid, NoE, 'ubit32');     % all 32 bits
        
        Progress(0.2/NumFiles,ProgressAxes,ProgressText,['Reading Macrotime of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        % macrotime, MT
        nsync = int16(bitand(T3Record,1023));       % the lowest 10 bits
        
        Progress(0.3/NumFiles,ProgressAxes,ProgressText,['Reading Microtime of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        % microtime, MI
        dtime = uint16(bitand(bitshift(T3Record,-10),32767));   % the next 15 bits
        %   the dtime unit depends on "Resolution" that can be obtained from header
        
        Progress(0.4/NumFiles,ProgressAxes,ProgressText,['Reading Channel of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        % see CHANNEL
        channel = int8(bitand(bitshift(T3Record,-25),63));   % the next 6 bits
        
        Progress(0.5/NumFiles,ProgressAxes,ProgressText,['Reading Special Records of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        special = logical(bitand(bitshift(T3Record,-31),1));   % the last bit:
        
        clear T3Record
        
        Progress(0.6/NumFiles,ProgressAxes,ProgressText,['Processing Overflows of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        OverflowCorrection = zeros(1,nRecords);
        OverflowCorrection( (special == 1) & (channel == 63) & (nsync == 0) ) = 1; %%% this generally only applies for version 1, but may apply to version 2 also
        if Version == 2 %%% this is NEW in version 2, not applicable to version 1
            OverflowCorrection( (special == 1) & (channel == 63) & (nsync ~= 0) ) = nsync( (special == 1) & (channel == 63) & (nsync ~= 0) );
        end
        OverflowCorrection = T3WRAPAROUND.*cumsum(OverflowCorrection);
        
        %Calculates the frame and line marker indices from the total timetag
        TimeTag = double(nsync)'+OverflowCorrection;
        FrameMarkerIndices = find(special & (channel == 1));
        NoOfFrames = nnz(FrameMarkerIndices);
        Header.NoF= floor(NoOfFrames);
        Header.FrameIndices = TimeTag(FrameMarkerIndices);
        Header.LineIndices = TimeTag(find(special & (channel == 2)));
        
        % calculate actual timetag of photons
        ValidIndices = ( (special == 0) & (channel >=0) & (channel<=15) );
        TimeTag = double(nsync(ValidIndices))' + OverflowCorrection(ValidIndices);
        channel = channel(ValidIndices);
        dtime = dtime(ValidIndices);

    case rtPicoHarpT3
        
        T3WRAPAROUND=65536;
        
        Progress(0.1/NumFiles,ProgressAxes,ProgressText,['Reading Byte Record of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        T3Record = fread(fid, NoE, 'ubit32');
        
        Progress(0.2/NumFiles,ProgressAxes,ProgressText,['Reading Macrotime of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        nsync = int16(bitand(T3Record,65535));
        
        Progress(0.3/NumFiles,ProgressAxes,ProgressText,['Reading Microtime of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        dtime = uint16(bitand(bitshift(T3Record,-16),4095));
        Progress(0.4/NumFiles,ProgressAxes,ProgressText,['Reading Channel of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        channel = int8(bitand(bitshift(T3Record,-28),15));
        
        Progress(0.5/NumFiles,ProgressAxes,ProgressText,['Reading Special Records of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        special = (bitand(bitshift(T3Record,-16),15));   % the last bit:
        
        clear T3Record
        
        Progress(0.6/NumFiles,ProgressAxes,ProgressText,['Processing Overflows of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);
        
        OverflowCorrection = zeros(1,nRecords);
        OverflowCorrection( (special == 0) & (channel == 15)) = 1;
        OverflowCorrection = T3WRAPAROUND.*cumsum(OverflowCorrection);
        
        ValidIndices = ((channel >= 1) & (channel <= 4));
        TimeTag = double(nsync(ValidIndices))' + OverflowCorrection(ValidIndices);
        channel = channel(ValidIndices);
        dtime = dtime(ValidIndices);
end

Progress(0.9/NumFiles,ProgressAxes,ProgressText,['Finishing up of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);

% channel is 0-15, so assign between 1-16
MT = cell(10,1);
MI = cell(10,1);
for i=unique(channel)'
    MT{i+1} = TimeTag(channel==i)';
    MI{i+1} = dtime(channel==i);
end

Progress(1/NumFiles,ProgressAxes,ProgressText, ['File ' num2str(FileNumber) ' of ' num2str(NumFiles) ' loaded']);

fclose(fid);
end
