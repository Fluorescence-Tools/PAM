%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Normal Correlation of Burst Photon Streams %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Correlate_Bursts(obj,~)
global BurstData BurstTCSPCData PhotonStream UserValues BurstMeta
h = guidata(obj);
%%% Set Up Progress Bar
Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
file = BurstMeta.SelectedFile;
UpdateCuts();
%%% Read out the species name
if (BurstData{file}.SelectedSpecies(1) == 0)
    species = 'total';
elseif (BurstData{file}.SelectedSpecies(1) >= 1)
    species = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),1};
    if (BurstData{file}.SelectedSpecies(2) > 1)
        species = [species '-' BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)}];
    end
end
species = strrep(species,' ','_');
%%% define channels
switch BurstData{file}.BAMethod
    case {1,2}
        Chan = {    1,    2,    3,    4,    5,    6,[1 2],[3 4],[1 2 3 4],[1 3],[2 4],[5 6]};
    case {3,4}
        Chan = {1,2,3,4,5,6,7,8,9,10,11,12,[1 3 5],[2 4 6],[7 9],[8 10], [1 2],[3 4],[5 6],[7 8],[9 10],[11 12],[1 2 3 4 5 6],[7 8 9 10]};
    case {5} %%% 2 color no polarization
        Chan = {   1,  2,  3,  [1,2]};
end
%Name = {'GG1','GG2','GR1','GR2','RR1','RR2', 'GG', 'GR','GX','GX1','GX2', 'RR'};
Name = h.Correlation_Table.RowName;
CorrMat = h.Correlation_Table.Data;
NumChans = size(CorrMat,1);
NCor = sum(sum(CorrMat));

switch obj
    case {h.Correlate_Button, h.Burstwise_nsFCS_linear_Menu,h.FullCorrelation_Menu}
        %%% Load associated .bps file, containing Macrotime, Microtime and Channel
        Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
        if isempty(BurstTCSPCData{file})
            Load_Photons();
        end
        Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
        %%% find selected bursts
        MT = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
        CH = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);
        
        for k = 1:numel(MT)
            MT{k} = MT{k}-MT{k}(1) +1;
        end
        
        % add microtime for nsFCS
        if any(obj == [h.Burstwise_nsFCS_linear_Menu,h.FullCorrelation_Menu])
            MI = BurstTCSPCData{file}.Microtime(BurstData{file}.Selected);
            for k = 1:numel(MT)
                MT{k} = MT{k}*BurstData{file}.FileInfo.MI_Bins + ...
                    uint64(MI{k});
            end
        end
    case {h.CorrelateWindow_Button, h.BurstwiseDiffusionTime_Menu}
        if isempty(PhotonStream{file})
            success = Load_Photons('aps');
            if ~success
                Progress(1,h.Progress_Axes,h.Progress_Text);
                return;
            end
        end
        % use selected only
        start = PhotonStream{file}.start(BurstData{file}.Selected);
        stop = PhotonStream{file}.stop(BurstData{file}.Selected);

        
        use_time = 1; %%% use time or photon window
        if use_time
            %%% histogram the Macrotimes in bins of 1 ms
            bw = ceil(1E-3./BurstData{file}.ClockPeriod);
            bins_time = bw.*(0:1:ceil(PhotonStream{file}.Macrotime(end)./bw));
            if ~isfield(PhotonStream{file},'MT_bin')
                %%% find the first photon belonging to a time window
                Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
                [~, PhotonStream{file}.MT_bin] = histc(PhotonStream{file}.Macrotime,bins_time);
                [PhotonStream{file}.unique,PhotonStream{file}.first_idx,~] = unique(PhotonStream{file}.MT_bin);
                %%% store starting macrotime for populated time windows
                used_tw = zeros(numel(bins_time),1);
                used_tw(PhotonStream{file}.unique) = PhotonStream{file}.first_idx;
                %%% some time windows are emtpy
                %%% if the last time window is empty, use the maximum macrotime
                if used_tw(end) == 0
                    last_non_empty = find(used_tw > 0,1,'last');
                    used_tw((last_non_empty+1):end) = numel(PhotonStream{file}.Macrotime);
                end
                %%% fill the rest with start from next non-empty time window
                while sum(used_tw == 0) > 0
                    used_tw(used_tw == 0) = used_tw(find(used_tw == 0)+1);
                end
                PhotonStream{file}.first_idx = used_tw;
            end
            [~, start_bin] = histc(PhotonStream{file}.Macrotime(start),bins_time);
            [~, stop_bin] = histc(PhotonStream{file}.Macrotime(stop),bins_time);
            [~, start_all_bin] = histc(PhotonStream{file}.Macrotime(PhotonStream{file}.start),bins_time);
            [~, stop_all_bin] = histc(PhotonStream{file}.Macrotime(PhotonStream{file}.stop),bins_time);
            
            use = ones(numel(start),1);
            %%% loop over selected bursts
            Progress(0,h.Progress_Axes,h.Progress_Text,'Including Time Window...');
            
            tw = UserValues.BurstBrowser.Settings.Corr_TimeWindowSize; %%% photon window of (2*tw+1)*10ms
            
            if tw > 0
                start_tw = start_bin - tw;start_tw(start_tw < 1) = 1;
                stop_tw = stop_bin + tw;stop_tw(stop_tw > (numel(bins_time) -1)) = numel(bins_time)-1;

                for i = 1:numel(start_tw)
                    %%% Check if ANY burst falls into the time window
                    val = (start_all_bin < stop_tw(i)) & (stop_all_bin > start_tw(i));
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
                MT = cell(sum(use),1);
                CH = cell(sum(use),1);
                k=1;
                for i = 1:numel(start_tw)
                    if use(i)
                        range = PhotonStream{file}.first_idx(start_tw(i)):(PhotonStream{file}.first_idx(stop_tw(i)+1)-1);
                        MT{k} = PhotonStream{file}.Macrotime(range);
                        MT{k} = MT{k}-MT{k}(1) +1;
                        CH{k} = PhotonStream{file}.Channel(range);
                        %val = (PhotonStream{file}.MT_bin > start_tw(i)) & (PhotonStream{file}.MT_bin < stop_tw(i) );
                        %MT{k} = PhotonStream{file}.Macrotime(val);
                        %MT{k} = MT{k}-MT{k}(1) +1;
                        %CH{k} = PhotonStream{file}.Channel(val);
                        k = k+1;
                    end
                    %Progress(i/numel(start_tw),h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
                end
            else
                % default to burst-wise
                if isempty(BurstTCSPCData{file})
                    Load_Photons();
                end
                Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
                %%% find selected bursts
                MT = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
                CH = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);

                for k = 1:numel(MT)
                    MT{k} = MT{k}-MT{k}(1) +1;
                end
            end
        else
            use = ones(numel(start),1);
            %%% loop over selected bursts
            Progress(0,h.Progress_Axes,h.Progress_Text,'Including Time Window...');
            tw = 50; %%% photon window of 100 photons
            
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
            MT = cell(sum(use),1);
            CH = cell(sum(use),1);
            k=1;
            for i = 1:numel(start_tw)
                if use(i)
                    MT{k} = PhotonStream{file}.Macrotime(start_tw(i):stop_tw(i));MT{k} = MT{k}-MT{k}(1) +1;
                    CH{k} = PhotonStream{file}.Channel(start_tw(i):stop_tw(i));
                    k = k+1;
                end
                Progress(i/numel(start_tw),h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
            end
        end
end

if obj == h.BurstwiseDiffusionTime_Menu
    %%% use all channels for the correlation function
    NumChans = 1;
    CorrMat = 1;
    switch BurstData{file}.BAMethod
        case {1,2}
            Chan = {[1 2 3 4 5 6]};
        case {3,4}
            Chan = {[1 2 3 4 5 6 7 8 9 10 11 12]};
    end
end
%%% Apply different correlation algorithm
%%% (Burstwise correlation with correct summation and normalization)
Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
count = 0;
for i=1:NumChans
    for j=1:NumChans
        if CorrMat(i,j)
            MT1 = cell(numel(MT),1);
            MT2 = cell(numel(MT),1);
            for k = 1:numel(MT)
                MT1{k} = MT{k}(ismember(CH{k},Chan{i}));
                MT2{k} = MT{k}(ismember(CH{k},Chan{j}));
            end
            %%% find empty bursts
            inval = cellfun(@isempty,MT1) | cellfun(@isempty,MT2);
            %%% exclude empty bursts
            MT1 = MT1(~inval); MT2 = MT2(~inval);            
            %%% Applies divider to data
            if UserValues.Settings.Pam.Cor_Divider > 1
                for k=1:numel(MT1)
                    MT1{k}=floor(MT1{k}/UserValues.Settings.Pam.Cor_Divider);
                    MT2{k}=floor(MT2{k}/UserValues.Settings.Pam.Cor_Divider);
                end
            end
            %%% Calculates the maximum inter-photon time in clock ticks
            Maxtime=cellfun(@(x,y) max([x(end) y(end)]),MT1,MT2);
            switch obj
                case {h.Correlate_Button,h.CorrelateWindow_Button,h.Burstwise_nsFCS_linear_Menu,h.FullCorrelation_Menu}
                    switch obj
                        case {h.Correlate_Button,h.CorrelateWindow_Button,h.FullCorrelation_Menu}
                            %%% Do Correlation
                            [Cor_Array,Cor_Times]=CrossCorrelation(MT1,MT2,Maxtime,[],[],2);
                            if obj == h.FullCorrelation_Menu % resolution is micerotime resolution
                                Cor_Times = Cor_Times*(BurstData{file}.FileInfo.TACRange/BurstData{file}.FileInfo.MI_Bins)*UserValues.Settings.Pam.Cor_Divider;
                            else
                                Cor_Times = Cor_Times*BurstData{file}.ClockPeriod*UserValues.Settings.Pam.Cor_Divider;
                            end
                            %%% Calculates average and standard error of mean (without tinv_table yet
                            if size(Cor_Array,2)>1
                                Cor_Average=mean(Cor_Array,2);
                                Cor_SEM=std(Cor_Array,0,2);
                            else
                                Cor_Average=Cor_Array{1};
                                Cor_SEM=Cor_Array{1};
                            end
                        case h.Burstwise_nsFCS_linear_Menu
                            [Cor_Array, Cor_Times] = nsFCS_burstwise(MT1,MT2);
                            % no error estimate for now
                            Cor_Average = Cor_Array;
                            Cor_SEM = ones(size(Cor_Average));
                    end

                    %%% Save the correlation file
                    %%% Generates filename
                    filename = fullfile(BurstData{file}.PathName,BurstData{file}.FileName);
                    species = strrep(species,':','');
                    species = strrep(species,'/','-');
                    switch obj 
                        case h.CorrelateWindow_Button
                            Current_FileName=[filename(1:end-4) '_' species '_' Name{i} '_x_' Name{j} '_tw' num2str(UserValues.BurstBrowser.Settings.Corr_TimeWindowSize) 'ms' '.mcor'];
                        case h.Correlate_Button
                            Current_FileName=[filename(1:end-4) '_' species '_' Name{i} '_x_' Name{j} '_bw' '.mcor'];
                        case h.Burstwise_nsFCS_linear_Menu
                            Current_FileName=[filename(1:end-4) '_' species '_' Name{i} '_x_' Name{j} '_bw_nsFCS' '.mcor'];
                        case h.FullCorrelation_Menu
                            Current_FileName=[filename(1:end-4) '_' species '_' Name{i} '_x_' Name{j} '_bw_fullFCS' '.mcor'];
                    end
                    %%% Checks, if file already exists
                    if  exist(Current_FileName,'file')
                        k=1;
                        %%% Adds 1 to filename
                        Current_FileName=[Current_FileName(1:end-5) '_' num2str(k) '.mcor'];
                        %%% Increases counter, until no file is found
                        while exist(Current_FileName,'file')
                            k=k+1;
                            Current_FileName=[Current_FileName(1:end-(5+numel(num2str(k-1)))) num2str(k) '.mcor'];
                        end
                    end

                    Header = ['Correlation file for: ' strrep(filename,'\','\\') ' of Channels ' Name{i} ' cross ' Name{j}];
                    counts_per_channel = [sum(cellfun(@numel,MT1)) sum(cellfun(@numel,MT2))];
                    duration = sum((cellfun(@(x,y) max(x(end),y(end)),MT1,MT2) - cellfun(@(x,y) min(x(1),y(1)),MT1,MT2))).*BurstData{file}.ClockPeriod;
                    Counts = counts_per_channel./duration/1000; % average countrate in kHz
                    Valid = 1:size(Cor_Array,2);
                    save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
                    count = count+1;
                case h.BurstwiseDiffusionTime_Menu
                    %%% Do Correlation
                    [Cor_Array,Cor_Times]=CrossCorrelation(MT1,MT2,Maxtime,[],[],3);
                    Cor_Times = Cor_Times*BurstData{file}.ClockPeriod*UserValues.Settings.Pam.Cor_Divider;
                    %%% remove everything below 1E-6 s
                    threshold_low = 1E-5;
                    threshold_high = Cor_Times(end)/10; %%% only consider up to 10%
                    Cor_Array = cellfun(@(x) x(Cor_Times>threshold_low & Cor_Times<threshold_high),Cor_Array,'Uniformoutput',false);
                    Cor_Times = Cor_Times(Cor_Times>threshold_low & Cor_Times<threshold_high);
                    %%% estimate G0 from first 10 time bins
                    G0 = cellfun(@(x) mean(x(x~=-1)),cellfun(@(x) x(1:10),Cor_Array,'Uniformoutput',false),'Uniformoutput',false);
                    %%% get valid time bins, i.e. finite and not equal -1
                    % needs to be done before normalizing
                    valid = cellfun(@(x) isfinite(x) & (x > -1),Cor_Array,'Uniformoutput',false);
                    %%% divide by G0
                    Cor_Array = cellfun(@(x,y) x./y,Cor_Array,G0,'Uniformoutput',false);
                    %%% define model
                    model = @(x,xdata) 1./(1+xdata./x(1));
                    %%% fit the diffusion time
                    tauD = NaN(numel(Cor_Array),1);
                    options = optimoptions('lsqcurvefit','Display','none','FunctionTolerance',1E-3);
                    for i = 1:numel(Cor_Array)
                        y = Cor_Array{i};
                        if sum(valid{i}) > 10 %%% require at least 10 data points
                            res = lsqcurvefit(model,[2e-3],Cor_Times(valid{i}),y(valid{i}),[1E-4],[Inf],options);
                            tauD(i) = res(1);
                        end
                        if mod(i,floor(numel(Cor_Array)/20)) == 0
                            Progress(i/numel(Cor_Array),h.Progress_Axes,h.Progress_Text,'Fitting diffusion time...');
                        end
                    end

                    %%% store in BurstData as extra field
                    if ~isfield(BurstData{file},'AdditionalParameters')
                        BurstData{file}.AdditionalParameters = [];
                    end
                    if ~isfield(BurstData{file}.AdditionalParameters,'tauD')
                        BurstData{file}.AdditionalParameters.tauD = NaN(size(BurstData{file}.DataArray,1),1);
                    end
                    %%% assign back to bursts
                    tauD_temp = NaN(size(use,1),1); 
                    tauD_temp(logical(use)) = tauD;
                    BurstData{file}.AdditionalParameters.tauD(BurstData{file}.Selected) = tauD_temp;
                    %%% ask for omega_r
                    omega_r = inputdlg('Specify focus size in nm:','Focus size?',1,{num2str(UserValues.BurstBrowser.Settings.FocusSize)});
                    if isempty(omega_r)
                        omega_r{1} = num2str(UserValues.BurstBrowser.Settings.FocusSize);
                        disp('Setting default value omega_r from UserValues.');
                    end
                    omega_r = str2num(omega_r{1});
                    if isnan(omega_r)
                        omega_r = UserValues.BurstBrowser.Settings.FocusSize;
                        disp('Setting default value omega_r from UserValues.');
                    end
                    UserValues.BurstBrowser.Settings.FocusSize = omega_r;
                    D = (omega_r./1000).^2./4./(tauD);
                    if ~isfield(BurstData{file}.AdditionalParameters,'DiffusionCoefficient')
                        BurstData{file}.AdditionalParameters.DiffusionCoefficient = NaN(size(BurstData{file}.DataArray,1),1);
                    end
                    %%% assign back to bursts
                    D_temp = NaN(size(use,1),1); 
                    D_temp(logical(use)) = D;
                    BurstData{file}.AdditionalParameters.DiffusionCoefficient(BurstData{file}.Selected) = D_temp;
                    %%% Add parameters to list
                    AddDerivedParameters([],[],h);
                    set(h.ParameterListX, 'String', BurstData{file}.NameArray);
                    set(h.ParameterListY, 'String', BurstData{file}.NameArray);
                    UpdateCuts();
                    UpdatePlot([],[],h);
            end
            Progress(count/NCor,h.Progress_Axes,h.Progress_Text,'Correlating...');
        end
    end
end

%%% Update FCSFit Path
UserValues.File.FCSPath = UserValues.File.BurstBrowserPath;
LSUserValues(1);

Progress(1,h.Progress_Axes,h.Progress_Text);

function [G_norm, G_timeaxis] = nsFCS_burstwise(MT1,MT2)
global BurstData BurstMeta UserValues
file = BurstMeta.SelectedFile;
% set parameters
time_unit = BurstData{file}.ClockPeriod*UserValues.Settings.Pam.Cor_Divider/BurstData{file}.FileInfo.MI_Bins;
limit = round(10E-6/time_unit); %%% only calculate from -10mus to 10mus
resolution = ceil(100E-12/time_unit); %%% set to 100 ps                    
% concatenate
MT1 = cellfun(@double,MT1,'UniformOutput',false);
MT2 = cellfun(@double,MT2,'UniformOutput',false);

bins = (-limit:resolution:limit)';
nphot = 0;
maxtime = 0;
G_raw = zeros(numel(bins),1);
for k = 1:numel(MT1)
    maxtime = maxtime + max(max([MT1{k};MT2{k}]));

    channel = [ones(numel(MT1{k}),1); 2*ones(numel(MT2{k}),1)];
    ArrivalTime = [MT1{k}; MT2{k}];

    [ArrivalTime, idx] = sort(ArrivalTime);
    channel = channel(idx);

    dc = diff(channel);
    dt = diff(ArrivalTime);
    dt = dt.*dc;
    dt = dt(dt ~= 0);

    G_raw = G_raw + histc(dt,bins);
    nphot = nphot+numel(dt);
end
%normalization
Nav = nphot^2*resolution/maxtime;
G_norm = G_raw/Nav;
G_timeaxis = bins*time_unit;

%%% pileup correction
% function for fitting of pileup, including one antibunching term and one
% bunching term
fun = @(A,B,C,t_offset,t_pileup,t_lifetime,t_bunching,x) A.*exp(-(abs(x-t_offset)/t_pileup)).*(1-B*exp(-(abs(x-t_offset)/t_lifetime))).*(1+C*exp(-(abs(x-t_offset)/t_bunching)));
fun_pileup = @(tau,t_offset,x) exp(-(abs(x-t_offset)/tau));
start_point = [1 1 1 0 round(10E-6/time_unit) round(1e-9/time_unit) round(100e-9/time_unit)];
lb = [0 0 0 -Inf round(1E-6/time_unit) 0 round(10E-9/time_unit)];
ub = [Inf Inf Inf Inf Inf round(10E-9/time_unit) round(1E-6/time_unit)];
% total histogram
hnorm = sum(G_norm,2);
fit1 = fit(bins,hnorm,fun,'StartPoint',start_point,'Lower',lb,'Upper',ub);
coeff = coeffvalues(fit1);
pileup = fun_pileup(coeff(5),coeff(4),bins);
% correction for pileup
G_norm = G_norm./pileup-1;