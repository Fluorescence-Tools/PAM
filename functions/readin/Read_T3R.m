function [Macrotime, Microtime, MT1, MT2, MT3, SyncRate, ClockRate, Resolution] = Read_T3R(FullFileName)
Macrotime = cell(10);
Microtime = cell(10);
FabSurf = false;

FileID = fopen(FullFileName,'r');

Header.Ident = fread(FileID, 16, 'uchar=>char')';
Header.FormatVersion = fread(FileID, 6, 'uchar=>char')';
if strncmp(Header.FormatVersion, '5.0', 3)
    Header.HardwareVersion = fread(FileID, 6, 'uchar=>char')';
elseif strncmp(Header.FormatVersion, '6.0', 3)
    Header.CreatorName = fread(FileID, 18, 'uchar=>char')';
    Header.CreatorVersion = fread(FileID, 12, 'uchar=>char')';
elseif strncmp(Header.FormatVersion, '5.3', 3)
    Header.HardwareVersion = fread(FileID, 6, 'uchar=>char')';
else
    %%% we have FabSurf data, start over again
    fclose(FileID);
    FileID = fopen(FullFileName, 'r');
    FabSurf = true;
end
if ~FabSurf %%% recorded with PQ software, header is in file
    Header.FileTime = fread(FileID, 18, 'uchar=>char')';
    dump = fread(FileID, 2, 'uchar=>char')';
    Header.Comment = fread(FileID, 256, 'uchar=>char')';
    Header.NumberOfChannels = fread(FileID, 1, 'int32=>int32');
    Header.NumberOfCurves = fread(FileID, 1, 'int32=>int32');
    Header.BitsPerChannel = fread(FileID, 1, 'int32=>int32');
    Header.RoutingChannels = fread(FileID, 1, 'int32=>int32');
    Header.NumberOfBoards = fread(FileID, 1, 'int32=>int32');
    Header.ActiveCurve = fread(FileID, 1, 'int32=>int32');
    Header.MeasurementMode = fread(FileID, 1, 'int32=>int32');
    Header.SubMode = fread(FileID, 1, 'int32=>int32');
    Header.RangeNo = fread(FileID, 1, 'int32=>int32');
    Header.Offset = fread(FileID, 1, 'int32=>int32');
    Header.AcquisitionTime = fread(FileID, 1, 'int32=>int32');
    Header.StopAt = fread(FileID, 1, 'int32=>int32');
    Header.StopOnOvfl = fread(FileID, 1, 'int32=>int32');
    Header.Restart = fread(FileID, 1, 'int32=>int32');
    Header.DisplayLinLog = fread(FileID, 1, 'int32=>int32');
    Header.DisplayTimeAxisFrom = fread(FileID, 1, 'int32=>int32');
    Header.DisplayTimeAxisTo = fread(FileID, 1, 'int32=>int32');
    Header.DisplayCountAxisFrom = fread(FileID, 1, 'int32=>int32');
    Header.DisplayCountAxisTo = fread(FileID, 1, 'int32=>int32');
    for i = 1:8
        Header.DisplayCurve(i).MapTo = fread(FileID, 1, 'int32=>int32');
        Header.DisplayCurve(i).Show = fread(FileID, 1, 'int32=>int32');
    end
    if strncmp(Header.FormatVersion, '5.0', 3)
        for i = 1:3
            Header.Param(i).Start = fread(FileID, 1, 'int32=>int32');
            Header.Param(i).Step = fread(FileID, 1, 'int32=>int32');
            Header.Param(i).End = fread(FileID, 1, 'int32=>int32');
        end
    elseif strncmp(Header.FormatVersion, '6.0', 3)
        for i = 1:3
            Header.Param(i).Start = fread(FileID, 1, 'float32=>float32');
            Header.Param(i).Step = fread(FileID, 1, 'float32=>float32');
            Header.Param(i).End = fread(FileID, 1, 'float32=>float32');
        end
    elseif strncmp(Header.FormatVersion, '5.3', 3)
        for i = 1:3
            Header.Param(i).Start = fread(FileID, 1, 'int32=>int32');
            Header.Param(i).Step = fread(FileID, 1, 'int32=>int32');
            Header.Param(i).End = fread(FileID, 1, 'int32=>int32');
        end
    end
    Header.RepeatMode = fread(FileID, 1, 'int32=>int32');
    Header.RepeatsPerCurve = fread(FileID, 1, 'int32=>int32');
    Header.RepeatTime = fread(FileID, 1, 'int32=>int32');
    Header.RepeatWaitTime = fread(FileID, 1, 'int32=>int32');
    Header.ScriptName = fread(FileID, 20, 'uchar=>char')';
    for i = 1:Header.NumberOfBoards
        if strncmp(Header.FormatVersion, '6.0', 3)
            Header.HardwareIdent = fread(FileID, 16, 'uchar=>char')';
            Header.HardwareVersion = fread(FileID, 8, 'uchar=>char')';
        end
        Header.Board(i).BoardSerial = fread(FileID, 1, 'int32=>int32');
        Header.Board(i).CFDZeroCross = fread(FileID, 1, 'int32=>int32');
        Header.Board(i).CFDDiscriminatorMin = fread(FileID, 1, 'int32=>int32');
        Header.Board(i).SYNCLevel = fread(FileID, 1, 'int32=>int32');
        Header.Board(i).CurveOffset = fread(FileID, 1, 'int32=>int32');
        Header.Board(i).Resolution = fread(FileID, 1, 'float32=>float32');
        Resolution = double(Header.Board(i).Resolution*1000); % in ps
    end
    % From here, the format is different from *.thd files
    Header.TTTRGlobclock = fread(FileID, 1, 'int32=>int32');
    Header.Reserved1 = fread(FileID, 1, 'int32=>int32');
    Header.Reserved2 = fread(FileID, 1, 'int32=>int32');
    Header.Reserved3 = fread(FileID, 1, 'int32=>int32');
    Header.Reserved4 = fread(FileID, 1, 'int32=>int32');
    Header.Reserved5 = fread(FileID, 1, 'int32=>int32');
    Header.Reserved6 = fread(FileID, 1, 'int32=>int32');
    Header.SyncRate = double(fread(FileID, 1, 'int32=>int32'));
    Header.AverageCFDRate = fread(FileID, 1, 'int32=>int32');
    Header.StopAfter = fread(FileID, 1, 'int32=>int32');
    Header.StopReason = fread(FileID, 1, 'int32=>int32');
    Header.NumberOfRecords = fread(FileID, 1, 'int32=>int32');
    Header.SpecHeaderLength = fread(FileID, 1, 'int32=>int32');
    if Header.SpecHeaderLength > 0
        Header.Reserved = fread(FileID, double(Header.SpecHeaderLength), 'int32=>int32')';
    else
        Header.Reserved = [];
    end

    Header.ClockRate = 10000000; % This value is always constant for TimeHarp 200 measurement card

    SyncRate = Header.SyncRate;
    ClockRate = Header.ClockRate;
elseif FabSurf %%% recorded with FabSurf
    %%% First Record is SyncRate, which is the laser repetition rate
    SyncRate = double(1E10/fread(FileID, 1, 'uint32=>uint32'));
    %%% ClockRate is always 10000000 (100ns)
    ClockRate = 10000000;
    Resolution = 1E12/SyncRate/4096;
    Header.NumberOfRecords = Inf;
end

%===== Process TTTRRecord =====

TTTRRecord = fread(FileID, double(Header.NumberOfRecords), 'uint32=>uint32');

fclose(FileID);
clear FileID;

%
% Byte 32 is not used at the moment, although documented.
%
% Reserved = bitget(TTTRRecord, 32);
Valid = bitget(TTTRRecord, 31);
Overflow = bitget(TTTRRecord, 28);
Marker = bitand(bitshift(TTTRRecord, -16),7);
M1 = find((Valid == 0) & (Marker == 1));
M2 = find((Valid == 0) & (Marker == 2));
M3 = find((Valid == 0) & (Marker == 7));


RouteTemp(:, 2) = bitget(TTTRRecord, 30);
RouteTemp(:, 1) = bitget(TTTRRecord, 29);
Route = 2*RouteTemp(:, 2) + 1*RouteTemp(:, 1);
clear RouteTemp;

ValidIndices = find(Valid == 1);
TimeTag(ValidIndices) = double(mod(TTTRRecord(ValidIndices), 65536));
TimeTag(M1) = double(mod(TTTRRecord(M1), 65536));
TimeTag(M2) = double(mod(TTTRRecord(M2), 65536));
TimeTag(M3) = double(mod(TTTRRecord(M3), 65536));

%%% old:
%InvalidIndices = find(Valid == 0);
% for i = 1:numel(InvalidIndices)-1
%      TimeTag(InvalidIndices(i)+1:InvalidIndices(i+1)-1) = TimeTag(InvalidIndices(i)+1:InvalidIndices(i+1)-1) + i*65536;
% end
% i = i+1;
% TimeTag(InvalidIndices(i)+1:end) = TimeTag(InvalidIndices(i)+1:end) + i*65536;

%%% better not use a for loop:
OverflowCorrection = cumsum((Valid == 0) & Overflow == 1)';
TimeTag(ValidIndices) = TimeTag(ValidIndices) + 65536*OverflowCorrection(ValidIndices);
TimeTag(M1) = TimeTag(M1) + 65536*OverflowCorrection(M1);
TimeTag(M2) = TimeTag(M2) + 65536*OverflowCorrection(M2);
TimeTag(M3) = TimeTag(M3) + 65536*OverflowCorrection(M3);
clear ValidIndices;
clear InvalidIndices;

ValidIndicesChannel0 = find((Route == 0) & (Valid == 1));
ValidIndicesChannel1 = find((Route == 1) & (Valid == 1));
ValidIndicesChannel2 = find((Route == 2) & (Valid == 1));
ValidIndicesChannel3 = find((Route == 3) & (Valid == 1));
clear Route Valid;

Microtime{1,1} = bitand(bitshift(TTTRRecord(ValidIndicesChannel0), -16),4095);%double(bitshift(TTTRRecord(ValidIndicesChannel0), -16, 12));
Microtime{1,1} = 4095 - Microtime{1};
Macrotime{1,1} = TimeTag(ValidIndicesChannel0)';
clear ValidIndicesChannel0;

Microtime{2,1} = double(bitand(bitshift(TTTRRecord(ValidIndicesChannel1), -16), 12));
Microtime{2,1} = 4095 - Microtime{2};
Macrotime{2,1} = TimeTag(ValidIndicesChannel1)';
clear ValidIndicesChannel1;
 
Microtime{3,1} = double(bitand(bitshift(TTTRRecord(ValidIndicesChannel2), -16), 12));
Microtime{3,1} = 4095 - Microtime{3};
Macrotime{3,1} = TimeTag(ValidIndicesChannel2)';
clear ValidIndicesChannel2;
 
 
Microtime{4,1} = double(bitand(bitshift(TTTRRecord(ValidIndicesChannel3), -16), 12));
Microtime{4,1} = 4095 - Microtime{4};
Macrotime{4,1} = TimeTag(ValidIndicesChannel3)';
clear ValidIndicesChannel3;

MT1 = TimeTag(M1)';
clear M1;

MT2 = TimeTag(M2)';
clear M2;

MT3 = TimeTag(M3)';
clear M3;
