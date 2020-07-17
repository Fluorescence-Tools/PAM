function [E,E_sim,tauD,tauD_sim,H_real,x_real,y_real,mean_tauD,...
    H_sim,x_sim,y_sim,mean_tauD_sim,w_res_dyn,BinCenters] = ...
    ETau_consistency(rate_matrix, R_states, sigmaR_states,...
    rate_matrix_static, R_states_static, sigmaR_states_static)
        

global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;
if isempty(BurstData)
    msgbox('No data selected', 'Error','error');
    return
end
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData{file})
    Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photons...');
    Load_Photons();
end
min_bursts_per_bin = UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA;
Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating...');

%% get data
E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
tauD = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'));
N_phot_D = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'));
selected = BurstData{file}.Selected;
E = E(selected);
tauD0 = BurstData{file}.Corrections.DonorLifetime;
tauD = tauD(selected)./tauD0;
%R0 = BurstData{file}.Corrections.FoersterRadius;
%sigmaR = BurstData{file}.Corrections.LinkerLength;
N_phot_D = N_phot_D(selected);
%% average lifetime in FRET efficiency bins
bin_number = UserValues.BurstBrowser.Settings.NumberOfBins_BVA; % bins for range 0-1
bin_edges = linspace(0,1,bin_number+1); 
BinCenters = bin_edges(1:end-1) + min(diff(bin_edges))/2;
[~,~,bin] = histcounts(E,bin_edges);
mean_tauD = NaN(1,numel(bin_edges)-1);  
for i = 1:numel(BinCenters)
    %%% compute bin-wise intensity-averaged lifetime for donor
    if sum(bin == i) > min_bursts_per_bin
        mean_tauD(i) = sum(N_phot_D(bin==i).*tauD(bin==i))./sum(N_phot_D(bin==i));
    end
end
%% smoothed dynamic FRET line
[H_real,x_real,y_real] = histcounts2(tauD,E,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[-0.1,1.1]);
H_real = H_real./max(H_real(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;
%% Simulation for PDA comparison
Progress(0.25,h.Progress_Axes,h.Progress_Text,'Calculating...');
%         if UserValues.BurstBrowser.Settings.BVA_ModelComparison
    % simulate dynamic and static models separately
    Progress(0.25,h.Progress_Axes,h.Progress_Text,'Simulating dynamic Model...');
    [E_sim,tauD_sim,mean_tauD_sim,~] = kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_DynamicStates...
        ,rate_matrix,R_states,sigmaR_states,1);

    Progress(0.5,h.Progress_Axes,h.Progress_Text,'Simulating static Model...');
%         else
%             % simulate dynamic and static species at in one model
%             Progress(0.25,h.Progress_Axes,h.Progress_Text,'Simulating all species...');
%             [E_sim,tauD_sim,mean_tauD_sim,~] = ...
%                 kinetic_consistency_check_2models('Lifetime',UserValues.BurstBrowser.Settings.BVA_DynamicStates,...
%                 UserValues.BurstBrowser.Settings.BVA_StaticStates,...
%                 rate_matrix,R_states,sigmaR_states,...
%                 rate_matrix_static,R_states_static,sigmaR_states_static);
%         end
%         [E_sim,tauD_sim,mean_tauD_sim,~] = kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_DynamicStates,rate_matrix,R_states,sigmaR_states,1);

[H_sim,x_sim,y_sim] = histcounts2(tauD_sim,E_sim,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[-0.1,1.1]);
H_sim = H_sim./max(H_sim(:));
Progress(0.5,h.Progress_Axes,h.Progress_Text,'Calculating...');
%% Calculate sum squared residuals (dynamic)
w_res_dyn = (mean_tauD-mean_tauD_sim);
w_res_dyn(isnan(w_res_dyn)) = 0;