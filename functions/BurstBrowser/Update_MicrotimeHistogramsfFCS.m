%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Microtime Histograms in fFCS tab %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_MicrotimeHistogramsfFCS(obj,~)
global BurstData BurstMeta BurstTCSPCData UserValues PhotonStream
h = guidata(obj);
Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
%%% Load associated *.bps data if it doesn't exist yet
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
file = BurstMeta.SelectedFile;
h.Calc_fFCS_Filter_button.Enable = 'off';
h.Do_fFCS_button.Enable = 'off';

%%% check if a synthetic pattern has been chosen
if isfield(BurstMeta,'fFCS') && isfield(BurstMeta.fFCS,'syntheticpatterns')
    synthetic_species1 = find(strcmp(h.fFCS_Species1_popupmenu.String{h.fFCS_Species1_popupmenu.Value},BurstMeta.fFCS.syntheticpatterns_names));
    if isempty(synthetic_species1); synthetic_species1 = false;end;
    synthetic_species2 = find(strcmp(h.fFCS_Species2_popupmenu.String{h.fFCS_Species2_popupmenu.Value},BurstMeta.fFCS.syntheticpatterns_names));
    if isempty(synthetic_species2); synthetic_species2 = false;end;
    synthetic_species3 = find(strcmp(h.fFCS_Species3_popupmenu.String{h.fFCS_Species3_popupmenu.Value},BurstMeta.fFCS.syntheticpatterns_names));
    if isempty(synthetic_species3); synthetic_species3 = false;end;
    use_FRET = false;
    downsample = false;
else
    synthetic_species1 = false;
    synthetic_species2 = false;
    synthetic_species3 = false;
    use_FRET = UserValues.BurstBrowser.Settings.fFCS_UseFRET;
    downsample = UserValues.BurstBrowser.Settings.Downsample_fFCS;
end

%%% Read out the bursts contained in the different species selections
valid_total = UpdateCuts([BurstData{file}.SelectedSpecies(1),1],file);
if ~synthetic_species1
    species1 = [BurstData{file}.SelectedSpecies(1),h.fFCS_Species1_popupmenu.Value + 1];
    valid_species1 = UpdateCuts(species1,file);
end
if ~synthetic_species2
    species2 = [BurstData{file}.SelectedSpecies(1),h.fFCS_Species2_popupmenu.Value + 1];
    valid_species2 = UpdateCuts(species2,file);
end
% check for third species
if strcmp(h.fFCS_Species3_popupmenu.Enable,'on') && ~(h.fFCS_Species3_popupmenu.Value == 1) % 1 is disabled ('-')
    if ~synthetic_species3
        species3 = [BurstData{file}.SelectedSpecies(1),h.fFCS_Species3_popupmenu.Value];
        valid_species3 = UpdateCuts(species3,file);
    end
    use_species3 = true;
else
    use_species3 = false;
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data ...');
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
tw = UserValues.BurstBrowser.Settings.Corr_TimeWindowSize; %%% photon window of (2*tw+1)*10ms
if UserValues.BurstBrowser.Settings.fFCS_Mode == 2 %include timewindow
    if isempty(PhotonStream{file})
        success = Load_Photons('aps');
        if ~success
            Progress(1,h.Progress_Axes,h.Progress_Text);
            return;
        end
    end
    start = PhotonStream{file}.start(valid_total);
    stop = PhotonStream{file}.stop(valid_total);
    
    use_time = 1; %%% use time or photon window
    if use_time
        %%% histogram the Macrotimes in bins of 10 ms
        bw = ceil(1E-3./BurstData{file}.ClockPeriod);
        bins_time = bw.*(0:1:ceil(PhotonStream{file}.Macrotime(end)./bw));
        if ~isfield(PhotonStream,'MT_bin')
            %%% finds the PHOTON index of the first photon in each
            %%% time bin
            [~, PhotonStream{file}.MT_bin] = histc(PhotonStream{file}.Macrotime,bins_time);
            Progress(0.2,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
            [PhotonStream{file}.unique,PhotonStream{file}.first_idx,~] = unique(PhotonStream{file}.MT_bin);
            Progress(0.4,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
            used_tw = zeros(numel(bins_time),1);
            used_tw(PhotonStream{file}.unique) = PhotonStream{file}.first_idx;
            %%% fill empty time windows with starting index from next non-empty
            %%% if the last time window is empty, use the maximum macrotime
            if used_tw(end) == 0
                last_non_empty = find(used_tw > 0,1,'last');
                used_tw((last_non_empty+1):end) = numel(PhotonStream{file}.Macrotime);
            end
            %%% fill the rest with start from next non-empty time window
            while sum(used_tw == 0) > 0
                used_tw(used_tw == 0) = used_tw(find(used_tw == 0)+1);
            end
            Progress(0.6,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
            PhotonStream{file}.first_idx = used_tw;
        end
        [~, start_bin] = histc(PhotonStream{file}.Macrotime(start),bins_time);
        [~, stop_bin] = histc(PhotonStream{file}.Macrotime(stop),bins_time);
        
        Progress(0.8,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
        
        [~, start_all_bin] = histc(PhotonStream{file}.Macrotime(PhotonStream{file}.start),bins_time);
        [~, stop_all_bin] = histc(PhotonStream{file}.Macrotime(PhotonStream{file}.stop),bins_time);
        
        Progress(1,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
        use = ones(numel(start),1);
        %%% loop over selected bursts
        Progress(0,h.Progress_Axes,h.Progress_Text,'Including Time Window...');
        
        start_tw = start_bin - tw;start_tw(start_tw < 1) = 1;
        stop_tw = stop_bin + tw;stop_tw(stop_tw > (numel(bins_time) -1)) = numel(bins_time)-1;
        
        for i = 1:numel(start_tw)
            %%% Check if ANY burst falls into the time window
            val = (start_all_bin < stop_tw(i)) & (stop_all_bin > start_tw(i));
            %%% Check if they are of the same species
            inval = val & (~valid_total);
            %%% if there are bursts of another species in the timewindow,
            %%% --> remove it
            if sum(inval) > 0
                use(i) = 0;
            end
            %Progress(i/numel(start),h.Progress_Axes,h.Progress_Text,'Including Time Window...');
        end
        
        %%% Construct reduced Macrotime and Channel vector
        Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
        MT_total = cell(sum(use),1);
        CH_total = cell(sum(use),1);
        MI_total = cell(sum(use),1);
        k=1;
        for i = 1:numel(start_tw)
            if use(i)
                range = PhotonStream{file}.first_idx(start_tw(i)):(PhotonStream{file}.first_idx(stop_tw(i)+1)-1);
                MT_total{k} = PhotonStream{file}.Macrotime(range);
                MT_total{k} = MT_total{k}-MT_total{k}(1) +1;
                CH_total{k} = PhotonStream{file}.Channel(range);
                MI_total{k} = PhotonStream{file}.Microtime(range);
                %val = (PhotonStream{file}.MT_bin > start_tw(i)) & (PhotonStream{file}.MT_bin < stop_tw(i) );
                %MT{k} = PhotonStream{file}.Macrotime(val);
                %MT{k} = MT{k}-MT{k}(1) +1;
                %CH{k} = PhotonStream{file}.Channel(val);
                k = k+1;
            end
            %Progress(i/numel(start_tw),h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
        end
    else
        use = ones(numel(start),1);
        %%% loop over selected bursts
        Progress(0,h.Progress_Axes,h.Progress_Text,'Including Time Window...');
        tw = 100; %%% photon window of 100 photons
        
        start_tw = start - tw;
        stop_tw = stop + tw;
        
        for i = 1:numel(start_tw)
            %%% Check if ANY burst falls into the time window
            val = (PhotonStream{file}.start < stop_tw(i)) & (PhotonStream{file}.stop > start_tw(i));
            %%% Check if they are of the same species
            inval = val & (~BurstData{file}.Selected);
            %%% if there are bursts of another species in the timewindow,
            %%% --> remove it
            if sum(inval) > 0
                use(i) = 0;
            end
            %Progress(i/numel(start),h.Progress_Axes,h.Progress_Text,'Including Time Window...');
        end
        
        %%% Construct reduced Macrotime and Channel vector
        Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
        MT_total = cell(sum(use),1);
        CH_total = cell(sum(use),1);
        MI_total = cell(sum(use),1);
        k=1;
        for i = 1:numel(start_tw)
            if use(i)
                MT_total{k} = PhotonStream{file}.Macrotime(start_tw(i):stop_tw(i));MT_total{k} = MT_total{k}-MT_total{k}(1) +1;
                CH_total{k} = PhotonStream{file}.Channel(start_tw(i):stop_tw(i));
                MI_total{k} = PhotonStream{file}.Microtime(start_tw(i):stop_tw(i));
                k = k+1;
            end
            %Progress(i/numel(start_tw),h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
        end
    end
    
    %%% Store burstwise photon stream
    BurstMeta.fFCS.Photons.MT_total = MT_total;
    BurstMeta.fFCS.Photons.MI_total = MI_total;
    BurstMeta.fFCS.Photons.CH_total = CH_total;
elseif any(UserValues.BurstBrowser.Settings.fFCS_Mode == [3,4])
    %%% Load total stream and also include a donor only species
    %%% later (automatically)
    if isempty(PhotonStream{file})
        success=Load_Photons('aps');
        if ~success
            Progress(1,h.Progress_Axes,h.Progress_Text);
            return;
        end
    end
    MT_total = PhotonStream{file}.Macrotime;
    MI_total = PhotonStream{file}.Microtime;
    CH_total = PhotonStream{file}.Channel;
    %BurstMeta.fFCS.Photons.MT_total = MT_total;
    %BurstMeta.fFCS.Photons.MI_total = MI_total;
    %BurstMeta.fFCS.Photons.CH_total = CH_total;
elseif UserValues.BurstBrowser.Settings.fFCS_Mode == 1
    % Burstwise only
    %%% find selected bursts
    MI_total = BurstTCSPCData{file}.Microtime(valid_total);
    CH_total = BurstTCSPCData{file}.Channel(valid_total);
    MT_total = BurstTCSPCData{file}.Macrotime(valid_total);
    for k = 1:numel(MT_total)
        MT_total{k} = MT_total{k}-MT_total{k}(1) +1;
    end
    BurstMeta.fFCS.Photons.MT_total = MT_total;
    BurstMeta.fFCS.Photons.MI_total = MI_total;
    BurstMeta.fFCS.Photons.CH_total = CH_total;
end

Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Microtime Histograms...');
if any(UserValues.BurstBrowser.Settings.fFCS_Mode == [1,2])
    MI_total = vertcat(MI_total{:});
    CH_total = vertcat(CH_total{:});
    MT_total = vertcat(MT_total{:});
end
if ~synthetic_species1
    MI_species{1} = BurstTCSPCData{file}.Microtime(valid_species1);MI_species{1} = vertcat(MI_species{1}{:});
    CH_species{1} = BurstTCSPCData{file}.Channel(valid_species1);CH_species{1} = vertcat(CH_species{1}{:});
else
    switch BurstData{file}.BAMethod
        case {1,2} %%% 2ColorMFD
            %%% assert that pattern has information for donor channel par
            MIPattern = BurstMeta.fFCS.syntheticpatterns{synthetic_species1}.MIPattern;
            if isempty(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}(BurstData{file}.PIE.From(1):BurstData{file}.PIE.To(1))) == 0)
                disp('Loaded pattern does not contain the required information for parallel channel.');
                return;
            end
            if isempty(MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)}(BurstData{file}.PIE.From(2):BurstData{file}.PIE.To(2))) == 0)
                disp('Loaded pattern does not contain the required information for perpendicual channel.');
                return;
            end
            MIPatternPar = MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)};
            MIPatternPer = MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)};
            %%% create dummy variable representing the synthetic decay pattern as photon stamps
            MIPatternPar = round(1E5*MIPatternPar./sum(MIPatternPar)); %%% 1E5 photons
            MIPatternPer = round(1E5*MIPatternPer./sum(MIPatternPer)); %%% 1E5 photons
            MI_species{1} = [];
            CH_species{1} = [1*ones(sum(MIPatternPar),1);2*ones(sum(MIPatternPer),1)];
            for i = 1:numel(MIPatternPar)
                MI_species{1} = [MI_species{1}; i*ones(MIPatternPar(i),1)];
            end
            for i = 1:numel(MIPatternPer)
                MI_species{1} = [MI_species{1}; i*ones(MIPatternPer(i),1)];
            end
        case {3,4}
            disp('Only implemented for 2color measurements.');
            return;
        case {5,6} % 2color noMFD
            %%% assert that pattern has information for donor channel par
            MIPattern = BurstMeta.fFCS.syntheticpatterns{synthetic_species1}.MIPattern;
            if isempty(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}(BurstData{file}.PIE.From(1):BurstData{file}.PIE.To(1))) == 0)
                disp('Loaded pattern does not contain the required information.');
                return;
            end
            MIPatternPar = MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)};
            %%% create dummy variable representing the synthetic decay pattern as photon stamps
            MIPatternPar = round(1E5*MIPatternPar./sum(MIPatternPar)); %%% 1E5 photons
            MI_species{1} = [];
            CH_species{1} = [1*ones(sum(MIPatternPar),1)];
            for i = 1:numel(MIPatternPar)
                MI_species{1} = [MI_species{1}; i*ones(MIPatternPar(i),1)];
            end         
    end
end
if ~synthetic_species2
    MI_species{2} = BurstTCSPCData{file}.Microtime(valid_species2);MI_species{2} = vertcat(MI_species{2}{:});
    CH_species{2} = BurstTCSPCData{file}.Channel(valid_species2);CH_species{2} = vertcat(CH_species{2}{:});
else
    switch BurstData{file}.BAMethod
        case {1,2} %%% 2ColorMFD
            %%% assert that pattern has information for donor channel par
            MIPattern = BurstMeta.fFCS.syntheticpatterns{synthetic_species2}.MIPattern;
            if isempty(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}(BurstData{file}.PIE.From(1):BurstData{file}.PIE.To(1))) == 0)
                disp('Loaded pattern does not contain the required information for parallel channel.');
                return;
            end
            if isempty(MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)}(BurstData{file}.PIE.From(2):BurstData{file}.PIE.To(2))) == 0)
                disp('Loaded pattern does not contain the required information for perpendicual channel.');
                return;
            end
            MIPatternPar = MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)};
            MIPatternPer = MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)};
            %%% create dummy variable representing the synthetic decay pattern as photon stamps
            MIPatternPar = round(1E5*MIPatternPar./sum(MIPatternPar)); %%% 1E5 photons
            MIPatternPer = round(1E5*MIPatternPer./sum(MIPatternPer)); %%% 1E5 photons
            MI_species{2} = [];
            CH_species{2} = [1*ones(sum(MIPatternPar),1);2*ones(sum(MIPatternPer),1)];
            for i = 1:numel(MIPatternPar)
                MI_species{2} = [MI_species{2}; i*ones(MIPatternPar(i),1)];
            end
            for i = 1:numel(MIPatternPer)
                MI_species{2} = [MI_species{2}; i*ones(MIPatternPer(i),1)];
            end
        case {3,4}
            disp('Only implemented for 2color measurements.');
            return;
        case {5,6} % 2color noMFD
            %%% assert that pattern has information for donor channel par
            MIPattern = BurstMeta.fFCS.syntheticpatterns{synthetic_species2}.MIPattern;
            if isempty(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}(BurstData{file}.PIE.From(1):BurstData{file}.PIE.To(1))) == 0)
                disp('Loaded pattern does not contain the required information.');
                return;
            end
            MIPatternPar = MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)};
            %%% create dummy variable representing the synthetic decay pattern as photon stamps
            MIPatternPar = round(1E5*MIPatternPar./sum(MIPatternPar)); %%% 1E5 photons
            MI_species{2} = [];
            CH_species{2} = [1*ones(sum(MIPatternPar),1)];
            for i = 1:numel(MIPatternPar)
                MI_species{2} = [MI_species{2}; i*ones(MIPatternPar(i),1)];
            end     
    end
end
if use_species3
    if ~synthetic_species3
        MI_species{3} = BurstTCSPCData{file}.Microtime(valid_species3);MI_species{3} = vertcat(MI_species{3}{:});
        CH_species{3} = BurstTCSPCData{file}.Channel(valid_species3);CH_species{3} = vertcat(CH_species{3}{:});
    else
        switch BurstData{file}.BAMethod
            case {1,2} %%% 2ColorMFD
                %%% assert that pattern has information for donor channel par
                MIPattern = BurstMeta.fFCS.syntheticpatterns{synthetic_species3}.MIPattern;
                if isempty(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}(BurstData{file}.PIE.From(1):BurstData{file}.PIE.To(1))) == 0)
                    disp('Loaded pattern does not contain the required information for parallel channel.');
                    return;
                end
                if isempty(MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)}(BurstData{file}.PIE.From(2):BurstData{file}.PIE.To(2))) == 0)
                    disp('Loaded pattern does not contain the required information for perpendicual channel.');
                    return;
                end
                MIPatternPar = MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)};
                MIPatternPer = MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)};
                %%% create dummy variable representing the synthetic decay pattern as photon stamps
                MIPatternPar = round(1E5*MIPatternPar./sum(MIPatternPar)); %%% 1E5 photons
                MIPatternPer = round(1E5*MIPatternPer./sum(MIPatternPer)); %%% 1E5 photons
                MI_species{3} = [];
                CH_species{3} = [1*ones(sum(MIPatternPar),1);2*ones(sum(MIPatternPer),1)];
                for i = 1:numel(MIPatternPar)
                    MI_species{3} = [MI_species{3}; i*ones(MIPatternPar(i),1)];
                end
                for i = 1:numel(MIPatternPer)
                    MI_species{3} = [MI_species{3}; i*ones(MIPatternPer(i),1)];
                end
            case {3,4}
                disp('Only implemented for 2color measurements.');
                return;
            case {5,6} % 2color noMFD
                %%% assert that pattern has information for donor channel par
                MIPattern = BurstMeta.fFCS.syntheticpatterns{synthetic_species3}.MIPattern;
                if isempty(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}(BurstData{file}.PIE.From(1):BurstData{file}.PIE.To(1))) == 0)
                    disp('Loaded pattern does not contain the required information.');
                    return;
                end
                MIPatternPar = MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)};
                %%% create dummy variable representing the synthetic decay pattern as photon stamps
                MIPatternPar = round(1E5*MIPatternPar./sum(MIPatternPar)); %%% 1E5 photons
                MI_species{3} = [];
                CH_species{3} = [1*ones(sum(MIPatternPar),1)];
                for i = 1:numel(MIPatternPar)
                    MI_species{3} = [MI_species{3}; i*ones(MIPatternPar(i),1)];
                end   
        end
    end
end

switch BurstData{file}.BAMethod
    case {1,2} %%% 2ColorMFD
        if use_FRET
            ParChans = [1,3]; %% GG1 and GR1
            PerpChans = [2,4]; %% GR2 and GR2
        else
            ParChans = [1]; %% GG1
            PerpChans = [2]; %% GG2
        end
    case {3,4} %%% 3ColorMFD
        if use_FRET
            ParChans = [1 3 5 7 9]; %% BB1, BG1, BR1, GG1, GR1
            PerpChans = [2 4 6 8 10]; %% BB2, BG2, BR2, GG2, GR2
        else
            ParChans = [1 7]; %% BB1, BG1, BR1, GG1, GR1
            PerpChans = [2 8]; %% BB2, BG2, BR2, GG2, GR2
        end
    case {5,6} %%% 2ColorNoMFD
        if use_FRET
            ParChans = [1,2]; %% GG, GR
        else
            ParChans = [1]; %% GG
        end
        PerpChans = []; %% none
end
%%% is the setup equipped with polarization=
isMFD = BurstData{file}.BAMethod < 5;
if isMFD
    h.axes_fFCS_DecayPerp.Visible = 'on';
    set(h.axes_fFCS_DecayPerp.Children,'Visible','on');
    h.axes_fFCS_DecayPar.Position(3) = 0.42;
    h.fFCS_SubTabPerp.Parent = h.MainTabfFCSPanel;
    h.fFCS_SubTabPar.Position(3) = 0.5;
else
    h.axes_fFCS_DecayPerp.Visible = 'off';
    set(h.axes_fFCS_DecayPerp.Children,'Visible','off');
    h.axes_fFCS_DecayPar.Position(3) = 0.9;
    h.fFCS_SubTabPerp.Parent = h.Hide_Stuff;
    h.fFCS_SubTabPar.Position(3) = 1;
end
%%% Construct Stacked Microtime Channels
%%% ___| MT1 |___| MT2 + max(MT1) |___
MI_par{1} = [];MI_par{2} = [];
if use_species3
    MI_par{3} = [];
end
if isMFD
    MI_perp{1} = [];MI_perp{2} = [];
    if use_species3
        MI_perp{3} = [];
    end
end
%%% read out the limits of the PIE channels
limit_low_par = [0, BurstData{file}.PIE.From(ParChans)];
limit_high_par = [0, BurstData{file}.PIE.To(ParChans)];
dif_par = cumsum(limit_high_par)-cumsum(limit_low_par);
if isMFD
    limit_low_perp = [0,BurstData{file}.PIE.From(PerpChans)];
    limit_high_perp = [0, BurstData{file}.PIE.To(PerpChans)];
    dif_perp = cumsum(limit_high_perp)-cumsum(limit_low_perp);
end

for i = 1:(2+use_species3) %%% loop over species
    for j = 1:numel(ParChans) %%% loop over channels to consider for par/perp
        MI_par{i} = vertcat(MI_par{i},...
            MI_species{i}(CH_species{i} == ParChans(j)) -...
            limit_low_par(j+1) + 1 +...
            dif_par(j));
        if isMFD
            MI_perp{i} = vertcat(MI_perp{i},...
                MI_species{i}(CH_species{i} == PerpChans(j)) -...
                limit_low_perp(j+1) + 1 +...
                dif_perp(j));
        end
        %         MI_par{i} = vertcat(MI_par{i},...
        %             MI_species{i}(CH_species{i} == ParChans(j)) -...
        %             limit_low_par(j+1) + 1 +...
        %             limit_high_par(j)-limit_low_par(j));
        %         MI_perp{i} = vertcat(MI_perp{i},...
        %             MI_species{i}(CH_species{i} == PerpChans(j)) -...
        %             limit_low_perp(j+1) + 1 +...
        %             limit_high_perp(j)-limit_low_perp(j));
    end
end

if UserValues.BurstBrowser.Settings.fFCS_Mode == 4 %%% add donor only species
    valid_donly = BurstData{file}.DataArray(:,2) > 0.95; %%% Stoichiometry threshold
    MI_donly = BurstTCSPCData{file}.Microtime(valid_donly);MI_donly = vertcat(MI_donly{:});
    CH_donly = BurstTCSPCData{file}.Channel(valid_donly);CH_donly = vertcat(CH_donly{:});
    MI_donly_par = [];MI_donly_perp = [];
    for j = 1:numel(ParChans) %%% loop over channels to consider for par/perp
        MI_donly_par = vertcat(MI_donly_par,...
            MI_donly(CH_donly == ParChans(j)) -...
            limit_low_par(j+1) + 1 +...
            dif_par(j));
        if isMFD
            MI_donly_perp = vertcat(MI_donly_perp,...
                MI_donly(CH_donly == PerpChans(j)) -...
                limit_low_perp(j+1) + 1 +...
                dif_perp(j));
        end
    end
end
MI_total_par = [];
MI_total_perp = [];
MT_total_par = [];
MT_total_perp = [];
for i = 1:numel(ParChans)
    MI_total_par = vertcat(MI_total_par,...
        MI_total(CH_total == ParChans(i)) -...
        limit_low_par(i+1) + 1 +...
        dif_par(i));
    %     MI_total_par = vertcat(MI_total_par,...
    %         MI_total(CH_total == ParChans(i)) -...
    %         limit_low_par(i+1) + 1 +...
    %         limit_high_par(i)-limit_low_par(i));
    MT_total_par = vertcat(MT_total_par,...
        MT_total(CH_total == ParChans(i)));
    if isMFD
        MI_total_perp = vertcat(MI_total_perp,...
            MI_total(CH_total == PerpChans(i)) -...
            limit_low_perp(i+1) + 1 +...
            dif_perp(i));
        %     MI_total_perp = vertcat(MI_total_perp,...
        %         MI_total(CH_total == PerpChans(i)) -...
        %         limit_low_perp(i+1) + 1 +...
        %         limit_high_perp(i)-limit_low_perp(i));
        MT_total_perp = vertcat(MT_total_perp,...
            MT_total(CH_total == PerpChans(i)));
    end
end

%%% sort photons
[MT_total_par,idx] = sort(MT_total_par);
MI_total_par = MI_total_par(idx);
if isMFD
    [MT_total_perp,idx] = sort(MT_total_perp);
    MI_total_perp = MI_total_perp(idx);
end
%%% Burstwise treatment if using time window or burst photons only
if any(UserValues.BurstBrowser.Settings.fFCS_Mode == [1,2])
    BurstMeta.fFCS.Photons.MI_total_par = cell(numel(BurstMeta.fFCS.Photons.MT_total),1);
    BurstMeta.fFCS.Photons.MI_total_perp = cell(numel(BurstMeta.fFCS.Photons.MT_total),1);
    BurstMeta.fFCS.Photons.MT_total_par = cell(numel(BurstMeta.fFCS.Photons.MT_total),1);
    BurstMeta.fFCS.Photons.MT_total_perp = cell(numel(BurstMeta.fFCS.Photons.MT_total),1);
    for k = 1:numel(BurstMeta.fFCS.Photons.MT_total)
        for i = 1:numel(ParChans)
            BurstMeta.fFCS.Photons.MI_total_par{k} = vertcat(BurstMeta.fFCS.Photons.MI_total_par{k},...
                BurstMeta.fFCS.Photons.MI_total{k}(BurstMeta.fFCS.Photons.CH_total{k} == ParChans(i)) -...
                limit_low_par(i+1) + 1 +...
                dif_par(i));
            BurstMeta.fFCS.Photons.MT_total_par{k} = vertcat(BurstMeta.fFCS.Photons.MT_total_par{k},...
                BurstMeta.fFCS.Photons.MT_total{k}(BurstMeta.fFCS.Photons.CH_total{k} == ParChans(i)));
            if isMFD
                BurstMeta.fFCS.Photons.MI_total_perp{k} = vertcat(BurstMeta.fFCS.Photons.MI_total_perp{k},...
                    BurstMeta.fFCS.Photons.MI_total{k}(BurstMeta.fFCS.Photons.CH_total{k} == PerpChans(i)) -...
                    limit_low_perp(i+1) + 1 +...
                    dif_perp(i));
                BurstMeta.fFCS.Photons.MT_total_perp{k} = vertcat(BurstMeta.fFCS.Photons.MT_total_perp{k},...
                    BurstMeta.fFCS.Photons.MT_total{k}(BurstMeta.fFCS.Photons.CH_total{k} == PerpChans(i)));
            end
        end
        
        %%% sort photons
        [BurstMeta.fFCS.Photons.MT_total_par{k},idx] = sort(BurstMeta.fFCS.Photons.MT_total_par{k});
        BurstMeta.fFCS.Photons.MI_total_par{k} = BurstMeta.fFCS.Photons.MI_total_par{k}(idx);
        if isMFD
            [BurstMeta.fFCS.Photons.MT_total_perp{k},idx] = sort(BurstMeta.fFCS.Photons.MT_total_perp{k});
            BurstMeta.fFCS.Photons.MI_total_perp{k} = BurstMeta.fFCS.Photons.MI_total_perp{k}(idx);
        end
    end
elseif any(UserValues.BurstBrowser.Settings.fFCS_Mode == [3,4]) % use sorted photon stream
    BurstMeta.fFCS.Photons.MT_total_par = MT_total_par;
    BurstMeta.fFCS.Photons.MI_total_par = MI_total_par;
    if isMFD
        BurstMeta.fFCS.Photons.MT_total_perp = MT_total_perp;
        BurstMeta.fFCS.Photons.MI_total_perp = MI_total_perp;
    end
end
%%% Downsampling if checked
%%% New binwidth in picoseconds
if downsample
    if ~isfield(BurstData{file}.FileInfo,'Resolution')
        TACChannelWidth = BurstData{file}.FileInfo.ClockPeriod*1E9/BurstData{file}.FileInfo.MI_Bins;
    elseif isfield(BurstData{file}.FileInfo,'Resolution') %%% HydraHarp Data
        TACChannelWidth = BurstData{file}.FileInfo.Resolution/1000;
    end
    new_bin_width = floor(UserValues.BurstBrowser.Settings.Downsample_fFCS_Time/(1000*TACChannelWidth));
    MI_total_par = ceil(double(MI_total_par)/new_bin_width);
    MI_total_perp = ceil(double(MI_total_perp)/new_bin_width);
    for i = 1:(2+use_species3)
        MI_par{i} = ceil(double(MI_par{i})/new_bin_width);
        if isMFD
            MI_perp{i} = ceil(double(MI_perp{i})/new_bin_width);
        end
    end
    switch UserValues.BurstBrowser.Settings.fFCS_Mode
        case {3,4}
            BurstMeta.fFCS.Photons.MI_total_par = MI_total_par;
            BurstMeta.fFCS.Photons.MI_total_perp = MI_total_perp;
        case {1,2}
            BurstMeta.fFCS.Photons.MI_total_par = cellfun(@(x) ceil(double(x)/new_bin_width),BurstMeta.fFCS.Photons.MI_total_par,'UniformOutput',false);
            BurstMeta.fFCS.Photons.MI_total_perp = cellfun(@(x) ceil(double(x)/new_bin_width),BurstMeta.fFCS.Photons.MI_total_perp,'UniformOutput',false);     
        case {5,6}
            BurstMeta.fFCS.Photons.MI_total_par = cellfun(@(x) ceil(double(x)/new_bin_width),BurstMeta.fFCS.Photons.MI_total_par,'UniformOutput',false);
    end
end

%%% Calculate the histograms
maxTAC_par = max(MI_total_par);
maxTAC_perp = max(MI_total_perp);
BurstMeta.fFCS.TAC_par = 1:1:(maxTAC_par);
BurstMeta.fFCS.TAC_perp = 1:1:(maxTAC_perp);
BurstMeta.fFCS.hist_MIpar_Species = [];
if isMFD;BurstMeta.fFCS.hist_MIperp_Species = [];end;
for i = 1:(2+use_species3)
    BurstMeta.fFCS.hist_MIpar_Species{i} = histc(MI_par{i},BurstMeta.fFCS.TAC_par);
    if isMFD
        BurstMeta.fFCS.hist_MIperp_Species{i} = histc(MI_perp{i},BurstMeta.fFCS.TAC_perp);
    end
end
BurstMeta.fFCS.hist_MItotal_par = histc(MI_total_par,BurstMeta.fFCS.TAC_par);
if isMFD
    BurstMeta.fFCS.hist_MItotal_perp = histc(MI_total_perp,BurstMeta.fFCS.TAC_perp);
end
%%% restrict species microtime histograms to valid region if synthetic species is selected
valid_par = true(numel(BurstMeta.fFCS.TAC_par),1);
valid_perp = true(numel(BurstMeta.fFCS.TAC_perp),1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This was the previous code, I don't recall why it was there. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if synthetic_species1 || synthetic_species2
%     %%% range for par channel
%     valid_range = [1,numel(BurstMeta.fFCS.TAC_par)];
%     if synthetic_species1
%         valid_range(1) = max(valid_range(1),find(BurstMeta.fFCS.hist_MIpar_Species{1} > 0,1,'first'));
%         valid_range(2) = min(valid_range(2),find(BurstMeta.fFCS.hist_MIpar_Species{1} > 0,1,'last')+1);
%     end
%     if synthetic_species2
%         valid_range(1) = max(valid_range(1),find(BurstMeta.fFCS.hist_MIpar_Species{2} > 0,1,'first'));
%         valid_range(2) = min(valid_range(2),find(BurstMeta.fFCS.hist_MIpar_Species{2} > 0,1,'last')+1);
%     end
%     valid_par = false(numel(BurstMeta.fFCS.TAC_par),1);
%     valid_par(valid_range(1):valid_range(2)) = true;
%     %%% range for perp channel
%     valid_range = [1,numel(BurstMeta.fFCS.TAC_perp)];
%     if synthetic_species1
%         valid_range(1) = max(valid_range(1),find(BurstMeta.fFCS.hist_MIperp_Species{1} > 0,1,'first'));
%         valid_range(2) = min(valid_range(2),find(BurstMeta.fFCS.hist_MIperp_Species{1} > 0,1,'last')+1);
%     end
%     if synthetic_species2
%         valid_range(1) = max(valid_range(1),find(BurstMeta.fFCS.hist_MIperp_Species{2} > 0,1,'first'));
%         valid_range(2) = min(valid_range(2),find(BurstMeta.fFCS.hist_MIperp_Species{2} > 0,1,'last')+1);
%     end
%     valid_perp = false(numel(BurstMeta.fFCS.TAC_perp),1);
%     valid_perp(valid_range(1):valid_range(2)) = true;
%     %%% set invalid region to zero
%     for i = 1:2
%         BurstMeta.fFCS.hist_MIpar_Species{i}(~valid_par) = 0;
%         BurstMeta.fFCS.hist_MIperp_Species{i}(~valid_perp) = 0;
%     end
% end

%%% Plot the Microtime histograms
BurstMeta.Plots.fFCS.Microtime_Total_par.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.Microtime_Total_par.YData = BurstMeta.fFCS.hist_MItotal_par./sum(BurstMeta.fFCS.hist_MItotal_par);
BurstMeta.Plots.fFCS.Microtime_Species1_par.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.Microtime_Species1_par.YData = BurstMeta.fFCS.hist_MIpar_Species{1}./sum( BurstMeta.fFCS.hist_MIpar_Species{1});
BurstMeta.Plots.fFCS.Microtime_Species2_par.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.Microtime_Species2_par.YData = BurstMeta.fFCS.hist_MIpar_Species{2}./sum(BurstMeta.fFCS.hist_MIpar_Species{2});

if isMFD
    BurstMeta.Plots.fFCS.Microtime_Total_perp.XData = BurstMeta.fFCS.TAC_perp;
    BurstMeta.Plots.fFCS.Microtime_Total_perp.YData = BurstMeta.fFCS.hist_MItotal_perp./sum(BurstMeta.fFCS.hist_MItotal_perp);
    BurstMeta.Plots.fFCS.Microtime_Species1_perp.XData = BurstMeta.fFCS.TAC_perp;
    BurstMeta.Plots.fFCS.Microtime_Species1_perp.YData = BurstMeta.fFCS.hist_MIperp_Species{1}./sum(BurstMeta.fFCS.hist_MIperp_Species{1});
    BurstMeta.Plots.fFCS.Microtime_Species2_perp.XData = BurstMeta.fFCS.TAC_perp;
    BurstMeta.Plots.fFCS.Microtime_Species2_perp.YData = BurstMeta.fFCS.hist_MIperp_Species{2}./sum(BurstMeta.fFCS.hist_MIperp_Species{2});
end
if use_species3
    BurstMeta.Plots.fFCS.Microtime_Species3_par.Visible = 'on';
    BurstMeta.Plots.fFCS.Microtime_Species3_par.XData = BurstMeta.fFCS.TAC_par;
    BurstMeta.Plots.fFCS.Microtime_Species3_par.YData = BurstMeta.fFCS.hist_MIpar_Species{3}./sum(BurstMeta.fFCS.hist_MIpar_Species{3});
    if isMFD
        BurstMeta.Plots.fFCS.Microtime_Species3_perp.Visible = 'on';
        BurstMeta.Plots.fFCS.Microtime_Species3_perp.XData = BurstMeta.fFCS.TAC_perp;
        BurstMeta.Plots.fFCS.Microtime_Species3_perp.YData = BurstMeta.fFCS.hist_MIperp_Species{3}./sum(BurstMeta.fFCS.hist_MIperp_Species{3});
    end
else
    BurstMeta.Plots.fFCS.Microtime_Species3_par.Visible = 'off';
    BurstMeta.Plots.fFCS.Microtime_Species3_perp.Visible = 'off';
end
%%% Add IRF Pattern if existent
if isfield(BurstData{file},'ScatterPattern') && UserValues.BurstBrowser.Settings.fFCS_UseIRF
    BurstMeta.Plots.fFCS.IRF_par.Visible = 'on';
    BurstMeta.Plots.fFCS.IRF_perp.Visible = 'on';
    
    hScat_par = [];
    hScat_perp = [];
    for i = 1:numel(ParChans)
        hScat_par = [hScat_par, BurstData{file}.ScatterPattern{ParChans(i)}(limit_low_par(i+1):limit_high_par(i+1))];
        if isMFD
            hScat_perp = [hScat_perp, BurstData{file}.ScatterPattern{PerpChans(i)}(limit_low_perp(i+1):limit_high_perp(i+1))];
        end
    end
    
    if downsample
        %%% Downsampling if checked
        hScat_par = downsamplebin(hScat_par,new_bin_width);hScat_par = hScat_par';
        if isMFD
            hScat_perp = downsamplebin(hScat_perp,new_bin_width);hScat_perp = hScat_perp';
        end
    end
    
    %%% normaize with respect to the total decay histogram
    hScat_par = hScat_par./max(hScat_par).*max(BurstMeta.fFCS.hist_MItotal_par./sum(BurstMeta.fFCS.hist_MItotal_par));
    if isMFD
        hScat_perp = hScat_perp./max(hScat_perp).*max(BurstMeta.fFCS.hist_MItotal_perp./sum(BurstMeta.fFCS.hist_MItotal_perp));
    end
    %%% restrict scatter microtime histograms to valid region if synthetic species is selected
    if synthetic_species1 || synthetic_species2
        hScat_par(~valid_par) = 0;
        if isMFD
            hScat_perp(~valid_perp) = 0;
        end
    end
    %%% store in BurstMeta
    BurstMeta.fFCS.hScat_par = hScat_par(1:numel(BurstMeta.fFCS.TAC_par));
    if isMFD
        BurstMeta.fFCS.hScat_perp = hScat_perp(1:numel(BurstMeta.fFCS.TAC_perp));
    end
    %%% Update Plots
    BurstMeta.Plots.fFCS.IRF_par.XData = BurstMeta.fFCS.TAC_par;
    BurstMeta.Plots.fFCS.IRF_par.YData = BurstMeta.fFCS.hScat_par;
    if isMFD
        BurstMeta.Plots.fFCS.IRF_perp.XData = BurstMeta.fFCS.TAC_perp;
        BurstMeta.Plots.fFCS.IRF_perp.YData = BurstMeta.fFCS.hScat_perp;
    end
elseif ~isfield(BurstData{file},'ScatterPattern') || ~UserValues.BurstBrowser.Settings.fFCS_UseIRF
    %%% Hide IRF plots
    BurstMeta.Plots.fFCS.IRF_par.Visible = 'off';
    BurstMeta.Plots.fFCS.IRF_perp.Visible = 'off';
end
%%% Add Donly pattern if checked
if UserValues.BurstBrowser.Settings.fFCS_Mode == 4
    BurstMeta.Plots.fFCS.Microtime_DOnly_par.Visible = 'on';
    if isMFD
        BurstMeta.Plots.fFCS.Microtime_DOnly_perp.Visible = 'on';
    end
    if UserValues.BurstBrowser.Settings.Downsample_fFCS
        MI_donly_par = ceil(double(MI_donly_par)/new_bin_width);
        if isMFD
            MI_donly_perp = ceil(double(MI_donly_perp)/new_bin_width);
        end
        %%% Downsampling if checked
        %hDOnly_par = downsamplebin(hDOnly_par,new_bin_width);hDOnly_par = hDOnly_par';
        %hDOnly_perp = downsamplebin(hDOnly_perp,new_bin_width);hDOnly_perp = hDOnly_perp';
    end
    
    hDOnly_par = histc(MI_donly_par,BurstMeta.fFCS.TAC_par);
    if isMFD
        hDOnly_perp = histc(MI_donly_perp,BurstMeta.fFCS.TAC_perp);
    end
    %%% normaize with respect to the total decay histogram
    hDOnly_par = hDOnly_par./sum(hDOnly_par);
    if isMFD
        hDOnly_perp = hDOnly_perp./sum(hDOnly_perp);
    end
    %%% store in BurstMeta
    BurstMeta.fFCS.hDOnly_par = hDOnly_par(1:numel(BurstMeta.fFCS.TAC_par));
    if isMFD
        BurstMeta.fFCS.hDOnly_perp = hDOnly_perp(1:numel(BurstMeta.fFCS.TAC_perp));
    end
    %%% Update Plots
    BurstMeta.Plots.fFCS.Microtime_DOnly_par.XData = BurstMeta.fFCS.TAC_par;
    BurstMeta.Plots.fFCS.Microtime_DOnly_par.YData = BurstMeta.fFCS.hDOnly_par;
    if isMFD
        BurstMeta.Plots.fFCS.Microtime_DOnly_perp.XData = BurstMeta.fFCS.TAC_perp;
        BurstMeta.Plots.fFCS.Microtime_DOnly_perp.YData = BurstMeta.fFCS.hDOnly_perp;
    end
else
    BurstMeta.Plots.fFCS.Microtime_DOnly_par.Visible = 'off';
    BurstMeta.Plots.fFCS.Microtime_DOnly_perp.Visible = 'off';
end
legend_string = {'Total',...
    h.fFCS_Species1_popupmenu.String{h.fFCS_Species1_popupmenu.Value},...
    h.fFCS_Species2_popupmenu.String{h.fFCS_Species2_popupmenu.Value},...
    h.fFCS_Species3_popupmenu.String{h.fFCS_Species3_popupmenu.Value},...
    'Scatter','Donor only'};
plots = [...
    BurstMeta.Plots.fFCS.Microtime_Total_par,...
    BurstMeta.Plots.fFCS.Microtime_Species1_par,...
    BurstMeta.Plots.fFCS.Microtime_Species2_par,...
    BurstMeta.Plots.fFCS.Microtime_Species3_par,...
    BurstMeta.Plots.fFCS.IRF_par,...
    BurstMeta.Plots.fFCS.Microtime_DOnly_par...
    ];
active = strcmp(get(plots,'Visible'),'on');
legend(plots(active),legend_string(active),'Interpreter','none');

%%% store the analysis settings so that they can be saved with the data
%%% later
BurstMeta.fFCS.MetaData = [];
BurstMeta.fFCS.MetaData.TimeWindow = tw;
[~,species] = get_multiselection(h);
BurstMeta.fFCS.MetaData.TotalSpecies.Name = BurstData{file}.SpeciesNames{species(1)};
Cut = BurstData{file}.Cut{species(1),1};
BurstMeta.fFCS.MetaData.TotalSpecies.Cut = cell2table(vertcat(Cut{:}),'VariableNames',{'Parameter','LB','UB','Active','Delete'});
% get current selection
if synthetic_species1
    BurstMeta.fFCS.MetaData.Species1 = ['Synthetic: ' BurstMeta.fFCS.syntheticpatterns_names{synthetic_species1}];
else
    BurstMeta.fFCS.MetaData.Species1.Name = [BurstData{file}.SpeciesNames{species1(1)} ' - ' BurstData{file}.SpeciesNames{species1(2)}];
    Cut = BurstData{file}.Cut{species1(1),species1(2)};
    BurstMeta.fFCS.MetaData.Species1.Cut = cell2table(vertcat(Cut{:}),'VariableNames',{'Parameter','LB','UB','Active','Delete'})
end

if synthetic_species2
    BurstMeta.fFCS.MetaData.Species2 = ['Synthetic: ' BurstMeta.fFCS.syntheticpatterns_names{synthetic_species2}];
else
    BurstMeta.fFCS.MetaData.Species2.Name = [BurstData{file}.SpeciesNames{species2(1)} ' - ' BurstData{file}.SpeciesNames{species2(2)}];
    Cut = BurstData{file}.Cut{species2(1),species2(2)};
    BurstMeta.fFCS.MetaData.Species2.Cut = cell2table(vertcat(Cut{:}),'VariableNames',{'Parameter','LB','UB','Active','Delete'})
end

if use_species3
    if synthetic_species3
        BurstMeta.fFCS.Result.MetaData.Species3 = ['Synthetic: ' BurstMeta.fFCS.syntheticpatterns_names{synthetic_species3}];
    else
        BurstMeta.fFCS.MetaData.Species3.Name = [BurstData{file}.SpeciesNames{species3(1)} ' - ' BurstData{file}.SpeciesNames{species3(2)}];
        Cut = BurstData{file}.Cut{species3(1),species3(2)};
        BurstMeta.fFCS.MetaData.Species3.Cut = cell2table(vertcat(Cut{:}),'VariableNames',{'Parameter','LB','UB','Active','Delete'})
    end
end

h.Calc_fFCS_Filter_button.Enable = 'on';
axis(h.axes_fFCS_DecayPar,'tight');
axis(h.axes_fFCS_DecayPerp,'tight');
h.fFCS_axes_tab.SelectedTab = h.fFCS_axes_decay_tab;
Progress(1,h.Progress_Axes,h.Progress_Text);
