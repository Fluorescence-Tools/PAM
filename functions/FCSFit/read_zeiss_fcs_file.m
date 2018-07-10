function [AC, mCountRate] = read_zeiss_fcs_file(fname)
% function mainly taken from:
% https://git.embl.de/grp-ellenberg/FCSAnalyze/blob/9bd8697b38846a6db99f510a3ac57a7cb5ee4a99/matlab/FCSFitM/classes/absFcsmodel.m
% check re-use rights!

 if nargin < 1
    return;
end
fileID = fopen(fname);
if fileID == -1
    return;
end   
% read whole file at once
C = textscan(fileID, '%s', 'delimiter','\n');
fclose(fileID);

% find repetion position and channel
RPC = []; % [Repetition_index Point_index Channel_index]
positionIdx = find(strncmp(C{1}, 'Position = ', 11));
repetitionIdx = find(strncmp(C{1}, 'Repetition = ', 13));
channelIdx = find(strncmp(C{1}, 'Channel = ', 10));
for i = 1:length(positionIdx)
    tmp = C{1}(positionIdx(i));
    [tokp] = regexp(tmp{:},'(-?\d+)',  'tokens');
    tmp = C{1}(repetitionIdx(i));
    [tokr] = regexp(tmp{:},'(-?\d+)',  'tokens');
    tmp = C{1}(channelIdx(i));
    [tokc] = regexp(tmp{:},'(-?\d+)',  'tokens');
    ip = str2double(char(tokp{:}));
    ir = str2double(char(tokr{:}));
    if isempty(tokc)
        continue
    end
    ich_in = str2double(char(tokc{1}));
    if (ip < 0 || ir < 0 || ich_in < 0)
        continue
    end

    % check if channel is cross-correlation
    isac = isempty(findstr('Cross-correlation', tmp{:}));
    % check if channel is apd or 
    isapd = isempty(findstr('Meta', tmp{:}));

    % invert channel for compability with FA for APD
    % keep same channels for ChS1 and ChS2
    if ~isac 
        ich = 3;
    else
      if isapd  
        if ich_in == 2
            ich = 1;
        elseif ich_in == 1
            ich = 2;
        end
      else
          ich = ich_in;
      end
    end
    RPC = [RPC; ir+1 ip+1 ich ];
end


% index for measurements is based on repetition or measured points
idxR = 2;
if max(RPC(:,1))>1
    idxR = 1;
end
if max(RPC(:,2))>1
    idxR = 2;
end


%%
%Index where correlation data starts
AC_idx = find(strncmp(C{1}, 'CorrelationArray =',18 )); %this reads all entries.
% contains auto and eventually cross-correlation data for each repetition/position
AC = cell(1,max(max(RPC(:,1:2))));
%In fcs file last index contains only fitting information.
%Therefore only process from 1:length(AC_idx)-1
for i=1:length(AC_idx)
    % get dimension
    dim = str2num(C{1}{AC_idx(i)}(19:end));
    if dim(1) == 0
        continue
    end
    %AC for current repetition/position
    ACl = cell2mat(cellfun(@str2num, C{1}(AC_idx(i)+1:AC_idx(i)+dim(1)), 'un', 0));
    idx = RPC(i, idxR);
    if isempty(AC{idx})
        %[time, AC1_1, AC1_1_std, AC2_2, AC2_1_std, CC_1, CC_1_std]
        % std are set to 1 as these are not computed in the
        % Zeiss module but only using fluctuationAnalyzer
        AC{idx} = zeros(size(ACl,1), 7);
    end
    % time is converted in us, AC base is set to 0
    AC{idx}(:,1) = ACl(:,1)*1e6;
    AC{idx}(:,RPC(i,3)*2:RPC(i,3)*2+1) = [ACl(:,2)-1 ones(size(ACl,1),1)];
end

% indexes where where CountRateArray start
CountRate_idx = find(strncmp(C{1}, 'CountRateArray =',16)); %this reads all entries for CountRate
% contains only mean of countrate rest is not needed 
mCountRate = cell(1,max(max(RPC(:,1:2))));
%last entry is fitting etc.
for i=1:length(CountRate_idx)
    dim = str2num(C{1}{CountRate_idx(i)}(17:end));
    if dim(1) > 0
        CountRatel = cell2mat(cellfun(@str2num, C{1}(CountRate_idx(i)+1:CountRate_idx(i)+dim(1)), 'un', 0));
        mCountRatel = mean(CountRatel(:,2));

        idx = RPC(i, idxR);
        if isempty(mCountRate{idx})
            mCountRate{idx} = zeros(1,3);
        end
        mCountRate{idx}(:,RPC(i,3)) = mCountRatel/1000;
    end
end
