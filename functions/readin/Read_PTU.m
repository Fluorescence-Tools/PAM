function [MT, MI,SyncRate,Resolution] = Read_PTU(FileName,NoE,ProgressAxes,ProgressText,FileNumber,NumFiles)
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
MeasDesc_Resolution = 0;
MeasDesc_GlobalResolution = 0;

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
SyncRate = 1/MeasDesc_GlobalResolution;
Resolution = MeasDesc_Resolution./HW_BaseResolution;
nRecords = TTResult_NumberOfRecords;
%%% check for file type
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
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  This reads the T3 mode event records
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

T3WRAPAROUND=1024;

Progress(0.1/NumFiles,ProgressAxes,ProgressText,['Reading Byte Record of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);

T3Record = fread(fid, NoE, 'ubit32');     % all 32 bits:

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
    ValidIndices = find(special == 0 | ((channel>=1)&(channel<=15)));
    TimeTag(ValidIndices) = double(nsync(ValidIndices))+TimeTag(ValidIndices)';
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
    
Progress(0.9/NumFiles,ProgressAxes,ProgressText,['Finishing up of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);

MT = cell(max(channel)+1,1);
MI = cell(max(channel)+1,1);
for i=unique(channel)'
    MT{i+1} = TimeTag(channel==i)';
    MI{i+1} = dtime(channel==i);
end

Progress(1/NumFiles,ProgressAxes,ProgressText, ['File ' num2str(FileNumber) ' of ' num2str(NumFiles) ' loaded']);

end
