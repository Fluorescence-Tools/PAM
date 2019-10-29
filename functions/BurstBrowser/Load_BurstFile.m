function Load_BurstFile(PathName,FileName,FilterIndex,append)
global BurstData BurstMeta BurstTCSPCData PhotonStream
if ischar(FileName)
    FileName = {FileName};
end
if nargin < 4
    append = 0;
end
if append == 0
    %%% clear global variables
    BurstData = [];
    BurstTCSPCData = [];
    PhotonStream = [];
end
h = guidata(findobj('Tag','BurstBrowser'));
for i = 1:numel(FileName)
    Progress((i-1)/numel(FileName),h.Progress_Axes,h.Progress_Text,['Loading File ' num2str(i) ' of ' num2str(numel(FileName))]);
    if ~exist(fullfile(PathName{i},FileName{i}),'file')
        disp(['File ' fullfile(PathName{i},FileName{i}) ' does not exist.']);
        h.Progress_Text.String = 'Error - File not found.';
        uiwait(h.BurstBrowser,1);
        return;
    end
    S = load('-mat',fullfile(PathName{i},FileName{i}));
    
    %%% Convert old File Format to new
    if FilterIndex == 2 % KBA file was loaded
        if ~isfield(S,'Data') % no variable named Data exists (very old)
            %%% find out the BurstSearch Type from filename
            if ~isempty(strfind(FileName{i},'ACBS_2C'))
                S.Data.BAMethod = 1;
            elseif ~isempty(strfind(FileName{i},'DCBS_2C'))
                S.Data.BAMethod = 2;
            elseif ~isempty(strfind(FileName{i},'ACBS_3C'))
                S.Data.BAMethod = 3;
            elseif ~isempty(strfind(FileName{i},'TCBS_3C'))
                S.Data.BAMethod = 4;
            end
        end
        switch S.Data.BAMethod
            case {1,2} %%% 2 Color MFD
                %%% Convert NameArray
                S.NameArray{strcmp(S.NameArray,'TFRET - TR')} = '|TDX-TAA| Filter';
                S.NameArray{strcmp(S.NameArray,'Stochiometry')} = 'Stoichiometry';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (green)')} = 'Number of Photons (DD)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (fret)')} = 'Number of Photons (DA)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (red)')} = 'Number of Photons (AA)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (green, parallel)')} = 'Number of Photons (DD par)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (green, perpendicular)')} = 'Number of Photons (DD perp)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (fret, parallel)')} = 'Number of Photons (DA par)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (fret, perpendicular)')} = 'Number of Photons (DA perp)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (red, parallel)')} = 'Number of Photons (AA par)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (red, perpendicular)')} = 'Number of Photons (AA perp)';
                if sum(strcmp(S.NameArray,'tau(green)')) > 0
                    S.NameArray{strcmp(S.NameArray,'tau(green)')} = 'Lifetime D [ns]';
                    S.NameArray{strcmp(S.NameArray,'tau(red)')} = 'Lifetime A [ns]';
                    S.DataArray(:,strcmp(S.NameArray,'Lifetime D [ns]')) = S.DataArray(:,strcmp(S.NameArray,'Lifetime D [ns]'))*1E9;
                    S.DataArray(:,strcmp(S.NameArray,'Lifetime A [ns]')) = S.DataArray(:,strcmp(S.NameArray,'Lifetime A [ns]'))*1E9;
                else %%% create zero value arrays
                    S.NameArray{end+1} = 'Lifetime D [ns]';
                    S.NameArray{end+1} = 'Lifetime A [ns]';
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                end
                S.NameArray{end+1} = 'Anisotropy D';
                S.NameArray{end+1} = 'Anisotropy A';
                %%% Calculate Anisotropies
                S.DataArray(:,end+1) = (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DD par)')) - S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DD perp)')))./...
                    (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DD par)')) + 2.*S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DD perp)')));
                S.DataArray(:,end+1) = (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (AA par)')) - S.DataArray(:,strcmp(S.NameArray,'Number of Photons (AA perp)')))./...
                    (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (AA par)')) + 2*S.DataArray(:,strcmp(S.NameArray,'Number of Photons (AA perp)')));
                
                if sum(strcmp(S.NameArray,'Proximity Ratio')) == 0
                    S.NameArray{end+1} = 'Proximity Ratio';
                    S.DataArray(:,end+1) = (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DA par)')) + S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DA perp)')))./...
                        (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DD par)')) + S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DD perp)')) +...
                         S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DA par)')) + S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DA perp)')));
                end
                S.BurstData.NameArray = S.NameArray;
                S.BurstData.DataArray = S.DataArray;
                S.BurstData.BAMethod = S.Data.BAMethod;
                if isfield(S.Data,'Filetype')
                    S.BurstData.FileType = S.Data.Filetype;
                else
                    S.BurstData.FileType = 'SPC';
                end
                if ~isfield(S.Data,'SyncRate')
                    S.Data.SyncRate = round(1/37.5E-9);
                end
                if isfield(S.Data,'TACrange')
                    S.BurstData.TACRange = S.Data.TACrange;
                else
                    S.BurstData.TACRange = 1E9./S.Data.SyncRate; %kba file from old Pam
                    % this will not work when the syncrate and clock rate are
                    % different
                end
                S.BurstData.SyncPeriod = 1./S.Data.SyncRate;
                S.BurstData.ClockPeriod = S.BurstData.SyncPeriod;
                S.BurstData.FileInfo.MI_Bins = 4096;
                S.BurstData.FileInfo.TACRange = S.BurstData.TACRange;
                if isfield(S.Data,'PIEChannels')
                    S.BurstData.PIE.From = [S.Data.PIEChannels.fromGG1, S.Data.PIEChannels.fromGG2,...
                        S.Data.PIEChannels.fromGR1, S.Data.PIEChannels.fromGR2,...
                        S.Data.PIEChannels.fromRR1, S.Data.PIEChannels.fromRR2];
                    S.BurstData.PIE.To = [S.Data.PIEChannels.toGG1, S.Data.PIEChannels.toGG2,...
                        S.Data.PIEChannels.toGR1, S.Data.PIEChannels.toGR2,...
                        S.Data.PIEChannels.toRR1, S.Data.PIEChannels.toRR2];
                elseif isfield(S.Data,'fFCS')
                    S.BurstData.PIE.From = S.Data.fFCS.lower;
                    S.BurstData.PIE.To = S.Data.fFCS.upper;
                end

                %%% Calculate IRF microtime histogram
                if isfield(S.Data,'IRFmicrotime')
                    for j = 1:6
                        S.BurstData.IRF{j} = histc(S.Data.IRFmicrotime{j}, 0:(S.BurstData.FileInfo.MI_Bins-1));
                    end
                    S.BurstData.ScatterPattern = S.BurstData.IRF;
                end
                if isfield(S.Data,'Macrotime')
                    S.BurstTCSPCData.Macrotime = S.Data.Macrotime;
                    S.BurstTCSPCData.Microtime = S.Data.Microtime;
                    S.BurstTCSPCData.Channel = S.Data.Channel;
                    S.BurstTCSPCData.Macrotime = cellfun(@(x) x',S.BurstTCSPCData.Macrotime,'UniformOutput',false);
                    S.BurstTCSPCData.Microtime = cellfun(@(x) x',S.BurstTCSPCData.Microtime,'UniformOutput',false);
                    S.BurstTCSPCData.Channel = cellfun(@(x) x',S.BurstTCSPCData.Channel,'UniformOutput',false);
                end
            case {3,4} %%% 3Color MFD
                %%% Convert NameArray
                S.NameArray{strcmp(S.NameArray,'TG - TR (PIE)')} = '|TGX-TRR| Filter';
                S.NameArray{strcmp(S.NameArray,'TB - TR (PIE)')} = '|TBX-TRR| Filter';
                S.NameArray{strcmp(S.NameArray,'TB - TG (PIE)')} = '|TBX-TGX| Filter';
                S.NameArray{strcmp(S.NameArray,'Efficiency* (G -> R)')} = 'FRET Efficiency GR';
                S.NameArray{strcmp(S.NameArray,'Efficiency* (B -> R)')} = 'FRET Efficiency BR';
                S.NameArray{strcmp(S.NameArray,'Efficiency* (B -> G)')} = 'FRET Efficiency BG';
                S.NameArray{strcmp(S.NameArray,'Efficiency* (B -> G+R)')} = 'FRET Efficiency B->G+R';
                S.NameArray{strcmp(S.NameArray,'Stochiometry (GR)')} = 'Stoichiometry GR';
                S.NameArray{strcmp(S.NameArray,'Stochiometry (BG)')} = 'Stoichiometry BG';
                S.NameArray{strcmp(S.NameArray,'Stochiometry (BR)')} = 'Stoichiometry BR';
                if sum(strcmp(S.NameArray,'tau(green)')) > 0
                    S.NameArray{strcmp(S.NameArray,'tau(blue)')} = 'Lifetime BB [ns]';
                    S.NameArray{strcmp(S.NameArray,'tau(green)')} = 'Lifetime GG [ns]';
                    S.NameArray{strcmp(S.NameArray,'tau(red)')} = 'Lifetime RR [ns]';
                    S.DataArray(:,strcmp(S.NameArray,'Lifetime BB [ns]')) = S.DataArray(:,strcmp(S.NameArray,'Lifetime BB [ns]'))*1E9;
                    S.DataArray(:,strcmp(S.NameArray,'Lifetime GG [ns]')) = S.DataArray(:,strcmp(S.NameArray,'Lifetime GG [ns]'))*1E9;
                    S.DataArray(:,strcmp(S.NameArray,'Lifetime RR [ns]')) = S.DataArray(:,strcmp(S.NameArray,'Lifetime RR [ns]'))*1E9;
                else %%% create zero value arrays
                    S.NameArray{end+1} = 'Lifetime BB [ns]';
                    S.NameArray{end+1} = 'Lifetime GG [ns]';
                    S.NameArray{end+1} = 'Lifetime RR [ns]';
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                end
                if sum(strcmp(S.NameArray,'Proximity Ratio B->G+R'))==0
                    S.NameArray{end+1} = 'Proximity Ratio B->G+R';
                    S.DataArray(:,end+1) = S.DataArray(:,strcmp(S.NameArray,'FRET Efficiency B->G+R'));
                end
                %%% Calculate Anisotropies
                S.NameArray{end+1} = 'Anisotropy BB';
                S.NameArray{end+1} = 'Anisotropy GG';
                S.NameArray{end+1} = 'Anisotropy RR';
                if sum(strcmp(S.NameArray,'Number of Photons (BB par)'))
                    S.DataArray(:,end+1) = (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (BB par)')) - S.DataArray(:,strcmp(S.NameArray,'Number of Photons (BB perp)')))./...
                        (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (BB par)')) + 2.*S.DataArray(:,strcmp(S.NameArray,'Number of Photons (BB perp)')));
                    S.DataArray(:,end+1) = (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (GG par)')) - S.DataArray(:,strcmp(S.NameArray,'Number of Photons (GG perp)')))./...
                        (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (GG par)')) + 2.*S.DataArray(:,strcmp(S.NameArray,'Number of Photons (GG perp)')));
                    S.DataArray(:,end+1) = (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (RR par)')) - S.DataArray(:,strcmp(S.NameArray,'Number of Photons (RR perp)')))./...
                        (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (RR par)')) + 2*S.DataArray(:,strcmp(S.NameArray,'Number of Photons (RR perp)')));
                else
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                end
                S.BurstData.NameArray = S.NameArray;
                S.BurstData.DataArray = S.DataArray;
                S.BurstData.BAMethod = S.Data.BAMethod;
                if isfield(S.Data,'Filetype')
                    S.BurstData.FileType = S.Data.Filetype;
                end
                if ~isfield(S.Data,'SyncRate')
                    S.Data.SyncRate = round(1/37.5E-9);
                end
                if isfield(S.Data,'TACrange')
                    S.BurstData.TACRange = S.Data.TACrange;
                    S.BurstData.FileInfo.TACRange = S.Data.TACrange;
                else
                    S.BurstData.TACRange =  1E9./S.Data.SyncRate;
                    S.BurstData.FileInfo.TACRange =  1E9./S.Data.SyncRate;
                    % this will not work if the syncrate and clockrate are
                    % different
                end
                S.BurstData.SyncPeriod = 1./S.Data.SyncRate;
                S.BurstData.ClockPeriod = S.BurstData.SyncPeriod;  %kba file from old pam
                S.BurstData.FileInfo.MI_Bins = 4096;

                if isfield(S.Data,'PIEChannels')
                    S.BurstData.PIE.From = [S.Data.PIEChannels.fromBB1, S.Data.PIEChannels.fromBB2,...
                        S.Data.PIEChannels.fromBG1, S.Data.PIEChannels.fromBG2,...
                        S.Data.PIEChannels.fromBR1, S.Data.PIEChannels.fromBR2,...
                        S.Data.PIEChannels.fromGG1, S.Data.PIEChannels.fromGG2,...
                        S.Data.PIEChannels.fromGR1, S.Data.PIEChannels.fromGR2,...
                        S.Data.PIEChannels.fromRR1, S.Data.PIEChannels.fromRR2];
                    S.BurstData.PIE.To = [S.Data.PIEChannels.toBB1, S.Data.PIEChannels.toBB2,...
                        S.Data.PIEChannels.toBG1, S.Data.PIEChannels.toBG2,...
                        S.Data.PIEChannels.toBR1, S.Data.PIEChannels.toBR2,...
                        S.Data.PIEChannels.toGG1, S.Data.PIEChannels.toGG2,...
                        S.Data.PIEChannels.toGR1, S.Data.PIEChannels.toGR2,...
                        S.Data.PIEChannels.toRR1, S.Data.PIEChannels.toRR2];
                elseif isfield(S.Data,'fFCS')
                    S.BurstData.PIE.From = S.Data.fFCS.lower;
                    S.BurstData.PIE.To = S.Data.fFCS.upper;
                end

                %%% Calculate IRF microtime histogram
                if isfield(S.Data,'IRFmicrotime')
                    for j = 1:12
                        S.BurstData.IRF{j} = histc(S.Data.IRFmicrotime{j}, 0:(S.BurstData.FileInfo.MI_Bins-1));
                    end
                    S.BurstData.ScatterPattern = S.BurstData.IRF;
                end
                if isfield(S.Data,'Macrotime')
                    S.BurstTCSPCData.Macrotime = S.Data.Macrotime;
                    S.BurstTCSPCData.Microtime = S.Data.Microtime;
                    S.BurstTCSPCData.Channel = S.Data.Channel;
                    S.BurstTCSPCData.Macrotime = cellfun(@(x) x',S.BurstTCSPCData.Macrotime,'UniformOutput',false);
                    S.BurstTCSPCData.Microtime = cellfun(@(x) x',S.BurstTCSPCData.Microtime,'UniformOutput',false);
                    S.BurstTCSPCData.Channel = cellfun(@(x) x',S.BurstTCSPCData.Channel,'UniformOutput',false);
                end
        end
    end
    
    %%% Check if newly loaded file is compatible with currently loaded file
    if ~isempty(BurstData) %%% make sure the was a file loaded before
        switch BurstData{1}.BAMethod
            case {1,2,5} %%% loaded files are 2color
                if ~any(S.BurstData.BAMethod == [1,2,5]) %%% loaded file is not of same type
                    fprintf('Error loading file %s\nSkipping file %i because it is not of same type as loaded files.\nLoaded files are 2 color type.\nFile %i is 3 color type.\n',FileName{i},i,i);
                    Progress(1,h.Progress_Axes,h.Progress_Text);
                    return; %%% Skip file
                end
            case {3,4} %%% loaded files are 2color
                if ~any(S.BurstData.BAMethod == [3,4]) %%% loaded file is not of same type
                    fprintf('Error loading file %s\nSkipping file %i because it is not of same type as loaded files.\nLoaded files are 3 color type.\nFile %i is 2 color type.\n',FileName{i},i,i);
                    Progress(1,h.Progress_Axes,h.Progress_Text);
                    return; %%% Skip file
                end
        end
    end
    
    %%% Determine if an APBS or DCBS file was loaded
    %%% This is important because for APBS, the donor only lifetime can be
    %%% determined from the measurement!
    %%% Check for DCBS/TCBS
    if isfield(S.BurstData,'BAMethod')
        if ~any(S.BurstData.BAMethod == [2,4]);
            %%% Crosstalk/direct excitation can be determined!
            %%% set flag:
            S.BurstData.APBS = 1;
        else
            S.BurstData.APBS = 0;
        end
    end
    %%% New: Cuts stored in Additional Variable when it was already saved
    %%% once in BurstBrowser
    %%% overwrite BurstData subfields with separately saved variables
    if isfield(S,'Cut')
        S.BurstData.Cut = S.Cut;
    end
    
    %%% Add corrected proximity ratios (== signal fractions) for three-colorMFD
    if any(S.BurstData.BAMethod == [3,4])
        if ~any(strcmp(S.BurstData.NameArray,'Proximity Ratio GR (raw)'))
            NameArray_dummy = cell(1,size(S.BurstData.NameArray,2)+4);
            DataArray_dummy = zeros(size(S.BurstData.DataArray,1),size(S.BurstData.DataArray,2)+4);
            %%% Insert corrected proximity ratios into namearray
            NameArray_dummy(1:11) = S.BurstData.NameArray(1:11);
            NameArray_dummy(12:15) = {'Proximity Ratio GR (raw)','Proximity Ratio BG (raw)','Proximity Ratio BR (raw)','Proximity Ratio B->G+R (raw)'};
            NameArray_dummy(16:end) = S.BurstData.NameArray(12:end);
            %%% duplicate proximity ratios into data array
            DataArray_dummy(:,1:11) = S.BurstData.DataArray(:,1:11);
            DataArray_dummy(:,12:15) = S.BurstData.DataArray(:,8:11);
            DataArray_dummy(:,16:end) = S.BurstData.DataArray(:,12:end);
            %%% replace arrays
            S.BurstData.NameArray = NameArray_dummy;
            S.BurstData.DataArray = DataArray_dummy;
        end
    end

    %% Fix missing "FRET" in Efficiency naming (NameArray) and update old GG/RR naming scheme to D/A
    try
        if any(S.BurstData.BAMethod == [1,2,5])
            S.BurstData.NameArray{strcmp(S.BurstData.NameArray,'Efficiency')} = 'FRET Efficiency';
            %%% also fix Cuts
            if isfield(S.BurstData,'Cut')
                for k = 1:numel(S.BurstData.Cut) %%% loop over species
                    for l = 1:numel(S.BurstData.Cut{k}) %%% loop over cuts in species
                        if strcmp(S.BurstData.Cut{k}{l}{1},'Efficiency')
                            S.BurstData.Cut{k}{l}{1} = 'FRET Efficiency';
                        end
                    end
                end
            end
        elseif any(S.BurstData.BAMethod == [3,4])
            S.BurstData.NameArray{strcmp(S.BurstData.NameArray,'Efficiency GR')} = 'FRET Efficiency GR';
            S.BurstData.NameArray{strcmp(S.BurstData.NameArray,'Efficiency BG')} = 'FRET Efficiency BG';
            S.BurstData.NameArray{strcmp(S.BurstData.NameArray,'Efficiency BR')} = 'FRET Efficiency BR';
            S.BurstData.NameArray{strcmp(S.BurstData.NameArray,'Efficiency B->G+R')} = 'FRET Efficiency B->G+R';
            %%% also fix Cuts
            if isfield(S.BurstData,'Cut')
                for k = 1:numel(S.BurstData.Cut) %%% loop over species
                    for j = 1:numel(S.BurstData.Cut{k}) %%% loop over cuts in species
                        if strcmp(S.BurstData.Cut{k}{j}{1},'Efficiency GR')
                            S.BurstData.Cut{k}{j}{1} = 'FRET Efficiency GR';
                        end
                        if strcmp(S.BurstData.Cut{k}{j}{1},'Efficiency BG')
                            S.BurstData.Cut{k}{j}{1} = 'FRET Efficiency BG';
                        end
                        if strcmp(S.BurstData.Cut{k}{j}{1},'Efficiency BR')
                            S.BurstData.Cut{k}{j}{1} = 'FRET Efficiency BR';
                        end
                        if strcmp(S.BurstData.Cut{k}{j}{1},'Efficiency B->G+R')
                            S.BurstData.Cut{k}{j}{1} = 'FRET Efficiency B->G+R';
                        end
                    end
                end
            end
        end
    end
	if any(S.BurstData.BAMethod == [1,2,5])
        oldNames = {'Lifetime GG [ns]','Lifetime RR [ns]','Anisotropy GG','Anisotropy RR','|TGX-TRR| Filter','|TGG-TGR| Filter','Countrate [kHz]'...
            'Count rate (GG) [kHz]','Count rate (GR) [kHz]','Count rate (RR) [kHz]','Count rate (GG par) [kHz]','Count rate (GG per) [kHz]','Count rate (GR par) [kHz]','Count rate (GR per) [kHz]','Count rate (RR par) [kHz]','Count rate (RR per) [kHz]',...
            'Countrate (GG) [kHz]','Countrate (GR) [kHz]','Countrate (RR) [kHz]','Countrate (GG par) [kHz]','Countrate (GG per) [kHz]','Countrate (GR par) [kHz]','Countrate (GR per) [kHz]','Countrate (RR par) [kHz]','Countrate (RR per) [kHz]',...
            'Number of Photons (GG)','Number of Photons (GR)','Number of Photons (RR)','Number of Photons (GG par)','Number of Photons (GG perp)','Number of Photons (GR par)','Number of Photons (GR perp)','Number of Photons (RR par)','Number of Photons (RR perp)'};
        newNames = {'Lifetime D [ns]','Lifetime A [ns]','Anisotropy D','Anisotropy A','|TDX-TAA| Filter','|TDD-TDA| Filter','Count rate [kHz]'...
            'Count rate (DD) [kHz]','Count rate (DA) [kHz]','Count rate (AA) [kHz]','Count rate (DD par) [kHz]','Count rate (DD perp) [kHz]','Count rate (DA par) [kHz]','Count rate (DA perp) [kHz]','Count rate (AA par) [kHz]','Count rate (AA perp) [kHz]',...
            'Count rate (DD) [kHz]','Count rate (DA) [kHz]','Count rate (AA) [kHz]','Count rate (DD par) [kHz]','Count rate (DD perp) [kHz]','Count rate (DA par) [kHz]','Count rate (DA perp) [kHz]','Count rate (AA par) [kHz]','Count rate (AA perp) [kHz]',...
            'Number of Photons (DD)','Number of Photons (DA)','Number of Photons (AA)','Number of Photons (DD par)','Number of Photons (DD perp)','Number of Photons (DA par)','Number of Photons (DA perp)','Number of Photons (AA par)','Number of Photons (AA perp)'};
        oldName_exists = false(size(oldNames));
        for m = 1:numel(oldNames)
            if sum(strcmp(S.BurstData.NameArray,oldNames{m})) > 0
                S.BurstData.NameArray{strcmp(S.BurstData.NameArray,oldNames{m})} = newNames{m};
                oldName_exists(m) = true;
            end
        end
        %%% also fix Cuts for corrected parameters
        if isfield(S.BurstData,'Cut')
            for k = 1:numel(S.BurstData.Cut) %%% loop over species
                for l = 1:numel(S.BurstData.Cut{k}) %%% loop over cuts in species
                    for m = 1:numel(oldNames)
                        if oldName_exists(m)
                            if strcmp(S.BurstData.Cut{k}{l}{1},oldNames{m})
                                S.BurstData.Cut{k}{l}{1} = newNames{m};
                            end
                        end
                    end
                end
            end
        end
    end
    %% Fix naming of ClockPeriod/SyncPeriod
    % burst analysis before December 16, 2015
    if ~isfield(S.BurstData, 'ClockPeriod')
        S.BurstData.ClockPeriod = S.BurstData.SyncPeriod;
        if isfield(S.BurstData,'FileInfo')
            if isfield(S.BurstData.FileInfo,'SyncPeriod')
                S.BurstData.FileInfo.ClockPeriod = S.BurstData.FileInfo.SyncPeriod;
            end
        else
            S.BurstData.FileInfo.SyncPeriod = S.BurstData.SyncPeriod;
            S.BurstData.FileInfo.ClockPeriod = S.BurstData.SyncPeriod;
        end
        if isfield(S.BurstData.FileInfo,'Card')
            if ~strcmp(S.BurstData.FileInfo.Card, 'SPC-140/150/830/130')
                %if SPC-630 is used, set the SyncPeriod to what it really is
                S.BurstData.SyncPeriod = 1/8E7*3;
                S.BurstData.FileInfo.SyncPeriod = 1/8E7*3;
                if rand < 0.05
                    msgbox('Be aware that the SyncPeriod is hardcoded. This message appears 1 out of 20 times.')
                end
            end
        end
    end
    
    %%
    S.BurstData.FileName = FileName{i};
    S.BurstData.PathName = PathName{i};
    %%% check for existing Cuts
    if ~isfield(S.BurstData,'Cut') %%% no cuts existed
        %initialize Cut Cell Array with standard cuts
        switch S.BurstData.BAMethod
            case {1,2,5,6}
                %%% FRET efficiency and stoichiometry basic cuts
                Cut = {{'FRET Efficiency',-0.1,1.1,true,false},{'Stoichiometry',-0.1,1.1,true,false}};
            case {3,4}
                %%% 3color, only do FRET GR and Stoichiometry cuts
                Cut = {{'FRET Efficiency GR',-0.1,1.1,true,false},{'Stoichiometry GR',-0.1,1.1,true,false},...
                    {'Stoichiometry BG',-0.1,1.1,true,false},{'Stoichiometry BR',-0.1,1.1,true,false}};
        end
        S.BurstData.Cut{1} = Cut;
        S.BurstData.Cut{2} = Cut;
        S.BurstData.Cut{3} = Cut;
        %add species to list
        S.BurstData.SpeciesNames{1} = 'Global Cuts';
        % also add two species for convenience
        S.BurstData.SpeciesNames{2} = 'Subspecies 1';
        S.BurstData.SpeciesNames{3} = 'Subspecies 2';
        S.BurstData.SelectedSpecies = [1,1];
    elseif isfield(S.BurstData,'Cut') %%% cuts existed, change to new format with uitree
        if isfield(S.BurstData,'SelectedSpecies')
            if numel(S.BurstData.SelectedSpecies) == 1
                S.BurstData.SelectedSpecies = [1,1];
            end
        end
    end
    
    if isfield(S,'SpeciesNames')
        S.BurstData.SpeciesNames = S.SpeciesNames;
    end
    if isfield(S,'SelectedSpecies')
        S.BurstData.SelectedSpecies = S.SelectedSpecies;
    end
    if isfield(S,'Background')
        S.BurstData.Background = S.Background;
    end
    if isfield(S,'Corrections')
        S.BurstData.Corrections = S.Corrections;
    end
    if isfield(S,'FitCut')
        S.BurstData.FitCut = S.FitCut;
    end
    if isfield(S,'ArbitraryCut')
        S.BurstData.ArbitraryCut = S.ArbitraryCut;
    end
    if isfield(S,'AdditionalParameters')
        S.BurstData.AdditionalParameters = S.AdditionalParameters;
    end
    %%% initialize DataCut
    S.BurstData.DataCut = S.BurstData.DataArray;
    %%% transfer to Global BurstData Structure holding all loaded files
    if append
        BurstData{end+1} = S.BurstData;
        if ~isfield(S,'BurstTCSPCData')
            BurstTCSPCData{end+1} = [];
        elseif isfield(S,'BurstTCSPCData')
            BurstTCSPCData{end+1} = S.BurstTCSPCData;
        end
        PhotonStream{end+1} = [];
    else
        BurstData{i} = S.BurstData;
        if ~isfield(S,'BurstTCSPCData')
            BurstTCSPCData{i} = [];
        elseif isfield(S,'BurstTCSPCData')
            BurstTCSPCData{i} = S.BurstTCSPCData;
        end
        PhotonStream{i} = [];
    end
end

BurstMeta.SelectedFile = 1;
Progress(1,h.Progress_Axes,h.Progress_Text);