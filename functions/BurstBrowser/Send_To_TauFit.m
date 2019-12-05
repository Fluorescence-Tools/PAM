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
        c{4} = [1,2];
    case {3,4}
        %%% 3color MFD
        c{1} = [1,2]; %% BB
        c{2} = [7,8]; %% GG
        c{3} = [11,12];%% RR
    case 5
        c{1} = [1,1];
        c{2} = [3,3];
end
for chan = 1:size(c,2)
    
    switch BurstData{file}.BAMethod
        case {1,2}
            if chan == 4
                %%% for donor-only species, update valid and overwrite
                %%% MI_total and CH_total
                [MI_total, CH_total] = donor_only_cuts();
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
TauFitData.DonorOnlyReference = BurstData{file}.DonorOnlyReference;
TauFit(obj,[]);
Progress(1,h.Progress_Axes,h.Progress_Text);

function [MI_total, CH_total] = donor_only_cuts()
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