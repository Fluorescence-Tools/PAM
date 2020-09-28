function [E,tauD,mean_tauD,BinCenters] = ETau_consistency()
global BurstData BurstTCSPCData UserValues BurstMeta
file = BurstMeta.SelectedFile;
if isempty(BurstData)
    msgbox('No data selected', 'Error','error');
    return
end
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
min_bursts_per_bin = UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA;

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