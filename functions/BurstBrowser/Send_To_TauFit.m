%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Prepare data for subensemble TCSPC fitting %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Send_To_TauFit(obj,~)
% Close TauFit cause it might be called from somewhere else than before
delete(findobj('Tag','TauFit'));
clear global TauFitData
global BurstData BurstTCSPCData UserValues TauFitData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');

file = BurstMeta.SelectedFile;
Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
% User clicks Send Species to TauFit
Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
if isempty(BurstTCSPCData{file})
    Load_Photons();
end

TauFitData.FileName = fullfile(BurstData{file}.PathName, BurstData{file}.FileName);
TauFitData.BAMethod = BurstData{file}.BAMethod;
TauFitData.FileInfo = BurstData{file}.FileInfo;
TauFitData.PIE = BurstData{file}.PIE;
TauFitData.SpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies};
TauFitData.FileName = BurstData{file}.FileName;
TauFitData.Path = BurstData{file}.PathName;
%%% Read out the bursts contained in the different species selections
valid = UpdateCuts([BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)],file);

%%% bootstrapping for selecting a random subset of bursts
%if 1
%    valid = find(valid);
%    valid = valid(randi(numel(valid),size(valid,1),size(valid,2)));
%    valid = valid(1:floor(numel(valid)/4));
%end

Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Microtime Histograms...');

%%% find selected bursts
MI_total = BurstTCSPCData{file}.Microtime(valid);
MI_total = vertcat(MI_total{:});
CH_total = BurstTCSPCData{file}.Channel(valid);
CH_total = vertcat(CH_total{:});
switch BurstData{file}.BAMethod
    case {1,2}
        %%% 2color MFD
        c{1} = [1,2]; %% GG
        c{2} = [5,6]; %% RR
        c{3} = [3,4];
        % check if donor only exists
        [MI_total_donor_only, CH_total_donor_only, valid_donly] = donor_only_cuts();
        if ~isempty(MI_total_donor_only)
            c{4} = [1,2];
        end
    case {3,4}
        %%% 3color MFD
        c{1} = [1,2]; %% BB
        c{2} = [7,8]; %% GG
        c{3} = [11,12];%% RR
    case 5
        c{1} = [1,1];
        c{2} = [3,3];
        c{3} = [2,2];
        % check if donor only exists
        [MI_total_donor_only, CH_total_donor_only, valid_donly] = donor_only_cuts();
        if ~isempty(MI_total_donor_only)
            c{4} = [1,1];
        end
end
for chan = 1:size(c,2)
    switch BurstData{file}.BAMethod
        case {1,2,5}
            if chan == 4
                %%% for donor-only species, update valid and overwrite
                %%% MI_total and CH_total
                %[MI_total, CH_total] = donor_only_cuts();
                MI_total = MI_total_donor_only;
                CH_total = CH_total_donor_only;
            end
    end
    MI_par = MI_total(CH_total == c{chan}(1));
    MI_perp = MI_total(CH_total == c{chan}(2));
    
    %%% Calculate the histograms
    MI_par = histc(MI_par,1:BurstData{file}.FileInfo.MI_Bins);
    MI_perp = histc(MI_perp,1:BurstData{file}.FileInfo.MI_Bins);
    TauFitData.hMI_Par{chan} = MI_par(BurstData{file}.PIE.From(c{chan}(1)):min([BurstData{file}.PIE.To(c{chan}(1)) end]));
    TauFitData.hMI_Per{chan} = MI_perp(BurstData{file}.PIE.From(c{chan}(2)):min([BurstData{file}.PIE.To(c{chan}(2)) end]));
    
    % IRF
    TauFitData.hIRF_Par{chan} = BurstData{file}.IRF{c{chan}(1)}(BurstData{file}.PIE.From(c{chan}(1)):min([BurstData{file}.PIE.To(c{chan}(1)) end]));
    TauFitData.hIRF_Per{chan} = BurstData{file}.IRF{c{chan}(2)}(BurstData{file}.PIE.From(c{chan}(2)):min([BurstData{file}.PIE.To(c{chan}(2)) end]));
    TauFitData.hIRF_Par{chan} = (TauFitData.hIRF_Par{chan}./max(TauFitData.hIRF_Par{chan})).*max(TauFitData.hMI_Par{chan});
    TauFitData.hIRF_Per{chan} = (TauFitData.hIRF_Per{chan}./max(TauFitData.hIRF_Per{chan})).*max(TauFitData.hMI_Per{chan});
    
    % Scatter Pattern
    TauFitData.hScat_Par{chan} = BurstData{file}.ScatterPattern{c{chan}(1)}(BurstData{file}.PIE.From(c{chan}(1)):min([BurstData{file}.PIE.To(c{chan}(1)) end]));
    TauFitData.hScat_Per{chan} = BurstData{file}.ScatterPattern{c{chan}(2)}(BurstData{file}.PIE.From(c{chan}(2)):min([BurstData{file}.PIE.To(c{chan}(2)) end]));
    TauFitData.hScat_Par{chan} = (TauFitData.hScat_Par{chan}./max(TauFitData.hScat_Par{chan})).*max(TauFitData.hMI_Par{chan});
    TauFitData.hScat_Per{chan} = (TauFitData.hScat_Per{chan}./max(TauFitData.hScat_Per{chan})).*max(TauFitData.hMI_Per{chan});
    
    %%% Generate XData
    TauFitData.XData_Par{chan} = (BurstData{file}.PIE.From(c{chan}(1)):BurstData{file}.PIE.To(c{chan}(1))) - BurstData{file}.PIE.From(c{chan}(1));
    TauFitData.XData_Per{chan} = (BurstData{file}.PIE.From(c{chan}(2)):BurstData{file}.PIE.To(c{chan}(2))) - BurstData{file}.PIE.From(c{chan}(2));
end
TauFitData.TACRange = BurstData{file}.FileInfo.TACRange; % in seconds
TauFitData.MI_Bins = double(BurstData{file}.FileInfo.MI_Bins); %Anders, why double
if ~isfield(BurstData{file}.FileInfo,'Resolution')
    % in nanoseconds/microtime bin
    TauFitData.TACChannelWidth = TauFitData.TACRange*1E9/TauFitData.MI_Bins;
elseif isfield(BurstData{file}.FileInfo,'Resolution') %%% HydraHarp Data
    TauFitData.TACChannelWidth = BurstData{file}.FileInfo.Resolution/1000;
end
if isfield(BurstData,'DonorOnlyReference')
    TauFitData.DonorOnlyReference = BurstData{file}.DonorOnlyReference;
else
    TauFitData.DonorOnlyReference = cell(size(BurstData{file}.IRF));
end

%%% calcualte the cumulative duration of all selected bursts
dur = BurstData{file}.DataArray(valid,strcmp('Duration [ms]',BurstData{file}.NameArray));
dur = sum(dur).*1E-3; % duration in seconds
fprintf('\nDuration of exported bursts: %.2f s\n',dur);
if exist('valid_donly','var')
    dur_donly = BurstData{file}.DataArray(valid_donly,strcmp('Duration [ms]',BurstData{file}.NameArray));
    dur_donly = sum(dur_donly).*1E-3; % duration in seconds
    fprintf('Duration of exported bursts (donly): %.2f s\n',dur_donly);
end
%%% estimate scatter fractionss
fprintf('\nEstimated scatter fractions:\n');
switch BurstData{file}.BAMethod
    case {1,2}
        %%% DD
        I_decay_par = sum(TauFitData.hMI_Par{1});
        I_decay_per = sum(TauFitData.hMI_Per{1});
        f_sc_par = dur.*1000.*BurstData{file}.Background.Background_GGpar./I_decay_par;
        f_sc_per = dur.*1000.*BurstData{file}.Background.Background_GGperp./I_decay_per;
        f_sc_combined = dur.*1000.*(BurstData{file}.Corrections.GfactorGreen.*BurstData{file}.Background.Background_GGpar+2*BurstData{file}.Background.Background_GGperp)./...
            (BurstData{file}.Corrections.GfactorGreen*I_decay_par+2*I_decay_per);
        fprintf('DD par: %.4f\t\tDD per: %.4f\t\tCombined: %.4f\n',f_sc_par,f_sc_per,f_sc_combined);
        %%% Update UserValues
        % scatter for parallel is set to the combined scatter, as this value is most commonly used
        UserValues.TauFit.FitParams{1}(8) = f_sc_combined;
        % scatter for perpendicular is set to the combined scatter of donor
        % only, as used in the global fit models (below)
        
        %%% AA
        I_decay_par = sum(TauFitData.hMI_Par{2});
        I_decay_per = sum(TauFitData.hMI_Per{2});
        f_sc_par = dur.*1000.*BurstData{file}.Background.Background_RRpar./I_decay_par;
        f_sc_per = dur.*1000.*BurstData{file}.Background.Background_RRperp./I_decay_per;
        f_sc_combined = dur.*1000.*(BurstData{file}.Corrections.GfactorRed.*BurstData{file}.Background.Background_RRpar+2*BurstData{file}.Background.Background_RRperp)./...
            (BurstData{file}.Corrections.GfactorRed*I_decay_par+2*I_decay_per);
        fprintf('AA par: %.4f\t\tAA per: %.4f\t\tCombined: %.4f\n',f_sc_par,f_sc_per,f_sc_combined);
        %%% Update UserValues
        % scatter for parallel is set to the combined scatter, as this value is most commonly used
        UserValues.TauFit.FitParams{2}(8) = f_sc_combined;
        UserValues.TauFit.FitParams{2}(9) = f_sc_per;
        
        if numel(TauFitData.hMI_Par) > 3
            %%% Donly
            %%% DD
            I_decay_par = sum(TauFitData.hMI_Par{4});
            I_decay_per = sum(TauFitData.hMI_Per{4});
            f_sc_par = dur_donly.*1000.*BurstData{file}.Background.Background_GGpar./I_decay_par;
            f_sc_per = dur_donly.*1000.*BurstData{file}.Background.Background_GGperp./I_decay_per;
            f_sc_combined = dur_donly.*1000.*(BurstData{file}.Corrections.GfactorGreen.*BurstData{file}.Background.Background_GGpar+2*BurstData{file}.Background.Background_GGperp)./...
                (BurstData{file}.Corrections.GfactorGreen*I_decay_par+2*I_decay_per);
            fprintf('Donly par: %.4f\tDonly per: %.4f\tCombined: %.4f\n',f_sc_par,f_sc_per,f_sc_combined);
            %%% Update UserValues
            % scatter for parallel is set to the combined scatter, as this value is most commonly used
            UserValues.TauFit.FitParams{4}(8) = f_sc_combined;
            UserValues.TauFit.FitParams{4}(9) = f_sc_per;
            UserValues.TauFit.FitParams{1}(9) = f_sc_combined;
        end
        LSUserValues(1);
    case {3,4}
    case {5}
        %%% DD
        I_decay = sum(TauFitData.hMI_Par{1});
        f_sc = dur.*1000.*BurstData{file}.Background.Background_GGpar./I_decay;        
        fprintf('DD: %.4f\n',f_sc);
        %%% Update UserValues
        % scatter for parallel is set to the combined scatter, as this value is most commonly used
        UserValues.TauFit.FitParams{1}(8) = f_sc;
        % scatter for perpendicular is set to the combined scatter of donor
        % only, as used in the global fit models (below)
        
        %%% AA
        I_decay = sum(TauFitData.hMI_Par{2});
        f_sc = dur.*1000.*BurstData{file}.Background.Background_RRpar./I_decay;
        fprintf('AA: %.4f\n',f_sc);
        %%% Update UserValues
        % scatter for parallel is set to the combined scatter, as this value is most commonly used
        UserValues.TauFit.FitParams{2}(8) = f_sc;
        
        if numel(TauFitData.hMI_Par) > 3
            %%% Donly
            %%% DD
            I_decay = sum(TauFitData.hMI_Par{4});
            f_sc = dur_donly.*1000.*BurstData{file}.Background.Background_GGpar./I_decay;
            fprintf('Donly: %.4f\n',f_sc);
            %%% Update UserValues
            % scatter for parallel is set to the combined scatter, as this value is most commonly used
            UserValues.TauFit.FitParams{4}(8) = f_sc;
            UserValues.TauFit.FitParams{1}(9) = f_sc;
        end
        LSUserValues(1);
end

TauFit(obj,[]);
Progress(1,h.Progress_Axes,h.Progress_Text);

function [MI_total, CH_total, valid] = donor_only_cuts()
%%%% perform donor-only species selection and return cut photons
global BurstData BurstTCSPCData BurstMeta UserValues
file = BurstMeta.SelectedFile;
indS = find(strcmp(BurstData{file}.NameArray,'Stoichiometry (raw)'));
Smin = UserValues.BurstBrowser.Settings.S_Donly_Min;
Smax = UserValues.BurstBrowser.Settings.S_Donly_Max;
% perform threshold based on raw stoichiometry, identical to crosstalk
% determination
valid = (BurstData{file}.DataArray(:,indS)>Smin) & (BurstData{file}.DataArray(:,indS)<Smax);
MI_total = BurstTCSPCData{file}.Microtime(valid);
MI_total = vertcat(MI_total{:});
CH_total = BurstTCSPCData{file}.Channel(valid);
CH_total = vertcat(CH_total{:});