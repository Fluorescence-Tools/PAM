%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Manual gamma determination by selecting the mid-points %%%%%%%%%%%%
%%%%%%% of two populations                                     %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineGammaManually(obj,~)
global UserValues BurstMeta BurstData
file = BurstMeta.SelectedFile;
if isempty(obj)
    h = guidata(findobj('Tag','BurstBrowser'));
else
    h = guidata(obj);
end
h.Main_Tab.SelectedTab = h.Main_Tab_Corrections;
indDur = find(strcmp(BurstData{file}.NameArray,'Duration [ms]'));
switch BurstData{file}.BAMethod
    case {1,2,5}
        indNGG = find(strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'));
        indNGR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'));
        indNRR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (AA)'));
    case {3,4}
        indNGG = find(strcmp(BurstData{file}.NameArray,'Number of Photons (GG)'));
        indNGR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (GR)'));
        indNRR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (RR)'));
end
%%% Read out corrections
if ~(BurstData{file}.BAMethod == 5) %%% MFD
    Background_GR = BurstData{file}.Background.Background_GRpar + BurstData{file}.Background.Background_GRperp;
    Background_GG = BurstData{file}.Background.Background_GGpar + BurstData{file}.Background.Background_GGperp;
    Background_RR = BurstData{file}.Background.Background_RRpar + BurstData{file}.Background.Background_RRperp;
elseif BurstData{file}.BAMethod == 5
    Background_GR = BurstData{file}.Background.Background_GRpar;
    Background_GG = BurstData{file}.Background.Background_GGpar;
    Background_RR = BurstData{file}.Background.Background_RRpar;
end

%%% change the plot in axes_gamma to S vs E (instead of default 1/S vs. E)
S_threshold = UpdateCuts();
%%% Calculate "raw" E and S with gamma = 1, but still apply direct
%%% excitation,crosstalk, and background corrections!
NGR = BurstData{file}.DataArray(S_threshold,indNGR) - Background_GR.*BurstData{file}.DataArray(S_threshold,indDur);
NGG = BurstData{file}.DataArray(S_threshold,indNGG) - Background_GG.*BurstData{file}.DataArray(S_threshold,indDur);
NRR = BurstData{file}.DataArray(S_threshold,indNRR) - Background_RR.*BurstData{file}.DataArray(S_threshold,indDur);
NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
E_raw = NGR./(NGR+NGG);
S_raw = (NGG+NGR)./(NGG+NGR+NRR);
[H,xbins,ybins] = calc2dhist(E_raw,S_raw,[51 51],[0 1], [min(S_raw) max(S_raw)]);
%[H, xbins, ybins] = calc2dhist(BurstMeta.Data.E_raw,BurstMeta.Data.S_raw,[51 51], [0 1], [0 1]);
BurstMeta.Plots.gamma_fit(1).XData = xbins;
BurstMeta.Plots.gamma_fit(1).YData = ybins;
BurstMeta.Plots.gamma_fit(1).CData = H;
BurstMeta.Plots.gamma_fit(1).AlphaData = (H>0);
BurstMeta.Plots.gamma_fit(2).XData = xbins;
BurstMeta.Plots.gamma_fit(2).YData = ybins;
BurstMeta.Plots.gamma_fit(2).ZData = H/max(max(H));
BurstMeta.Plots.gamma_fit(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
axis(h.Corrections.TwoCMFD.axes_gamma,'tight');

%%% Update Axis Labels
xlabel(h.Corrections.TwoCMFD.axes_gamma,'FRET Efficiency','Color',UserValues.Look.Fore);
ylabel(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry','Color',UserValues.Look.Fore);
title(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry vs. FRET Efficiency for gamma = 1','Color',UserValues.Look.Fore);
%%% Hide Fit
BurstMeta.Plots.Fits.gamma.Visible = 'off';
if verLessThan('MATLAB','9.5')
    [e, s] = ginput(2);
else % 2018b onwards
    [e, s] = my_ginput(2);
end
BurstMeta.Plots.Fits.gamma_manual.XData = e;
BurstMeta.Plots.Fits.gamma_manual.YData = s;
BurstMeta.Plots.Fits.gamma_manual.Visible = 'on';
s = 1./s;
m = (s(2)-s(1))./(e(2)-e(1));
b = s(2) - m.*e(2);

UserValues.BurstBrowser.Corrections.Gamma_GR = (b - 1)/(b + m - 1);
BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;

UserValues.BurstBrowser.Corrections.Beta_GR = b+m-1;
BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;

%%% Save UserValues
LSUserValues(1);
%%% Update Correction Table Data
UpdateCorrections([],[],h);
%%% Apply Corrections
ApplyCorrections([],[],h);
