%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates the Gamma Factor using the lifetime information %%%%%%%%
%%%%%%% by minimizing the deviation from the static FRET line      %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineGammaLifetime(obj,~)
global BurstData UserValues BurstMeta
h = guidata(obj);
LSUserValues(0);
h.Main_Tab.SelectedTab = h.Main_Tab_Corrections;
file = BurstMeta.SelectedFile;
%% 2cMFD
%%% Prepare photon counts
indDur = (strcmp(BurstData{file}.NameArray,'Duration [ms]'));
indNGG = (strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'));
indNGR = (strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'));
indNRR = (strcmp(BurstData{file}.NameArray,'Number of Photons (AA)'));
indTauGG = (strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'));

data_for_corrections = BurstData{file}.DataArray;

%%% Read out corrections
if ~(BurstData{file}.BAMethod == 5) % MFD
    Background_GR = BurstData{file}.Background.Background_GRpar + BurstData{file}.Background.Background_GRperp;
    Background_GG = BurstData{file}.Background.Background_GGpar + BurstData{file}.Background.Background_GGperp;
    Background_RR = BurstData{file}.Background.Background_RRpar + BurstData{file}.Background.Background_RRperp;
elseif BurstData{file}.BAMethod == 5 % noMFD
    Background_GR = BurstData{file}.Background.Background_GRpar;
    Background_GG = BurstData{file}.Background.Background_GGpar;
    Background_RR = BurstData{file}.Background.Background_RRpar;
end

%%% use selected species
S_threshold = UpdateCuts();
%%% Calculate "raw" E and S with gamma = 1, but still apply direct
%%% excitation,crosstalk, and background corrections!
NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;

if obj == h.DetermineGammaLifetimeTwoColorButton
    %%% Calculate static FRET line in presence of linker fluctuations
    [FRETline, statFRETfun,tau] = conversion_tau(BurstData{file}.Corrections.DonorLifetime,...
        BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength);
    %staticFRETline = @(x) 1 - (coeff(1).*x.^3 + coeff(2).*x.^2 + coeff(3).*x + coeff(4))./BurstData{file}.Corrections.DonorLifetime;
    %%% minimize deviation from static FRET line as a function of gamma
    tauGG = data_for_corrections(S_threshold,indTauGG);
    valid = (tauGG < BurstData{file}.Corrections.DonorLifetime) & (tauGG > 0.01) & ~isnan(tauGG) & ~isnan(statFRETfun(tauGG));
    %dev = @(gamma) sum( ( ( NGR(valid)./(gamma.*NGG(valid)+NGR(valid)) ) - statFRETfun( tauGG(valid) ) ).^2 );
    %gamma_fit = fmincon(dev,1,[],[],[],[],0,10);
    gamma_fit = fit([NGR(valid),NGG(valid)],statFRETfun(tauGG(valid)), @(gamma,x,y) (x./(gamma.*y+x) ),'StartPoint',1,'Robust','bisquare');
    gamma_fit = coeffvalues(gamma_fit);
    E =  NGR./(gamma_fit.*NGG+NGR);
    %%% plot E versus tau with static FRET line
    [H,xbins,ybins] = calc2dhist(data_for_corrections(S_threshold,indTauGG),E,[51 51],[0 min([max(tauGG) BurstData{file}.Corrections.DonorLifetime+1.5])],[-0.1 1.1]);
    BurstMeta.Plots.gamma_lifetime(1).XData= xbins;
    BurstMeta.Plots.gamma_lifetime(1).YData= ybins;
    BurstMeta.Plots.gamma_lifetime(1).CData= H;
    BurstMeta.Plots.gamma_lifetime(1).AlphaData= (H>0);
    BurstMeta.Plots.gamma_lifetime(2).XData= xbins;
    BurstMeta.Plots.gamma_lifetime(2).YData= ybins;
    BurstMeta.Plots.gamma_lifetime(2).ZData= H/max(max(H));
    BurstMeta.Plots.gamma_lifetime(2).LevelList= linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    %%% add static FRET line
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.Visible = 'on';
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.XData = tau;
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.YData = FRETline;
    ylim(h.Corrections.TwoCMFD.axes_gamma_lifetime,[-0.1,1.1]);
    %%% Update UserValues
    UserValues.BurstBrowser.Corrections.Gamma_GR =gamma_fit;
    BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
end
%% 3cMFD - Fit E1A vs. TauBlue
if obj == h.DetermineGammaLifetimeThreeColorButton
    if any(BurstData{file}.BAMethod == [3,4])
        %%% Prepare photon counts
        indNBB = (strcmp(BurstData{file}.NameArray,'Number of Photons (BB)'));
        indNBG = (strcmp(BurstData{file}.NameArray,'Number of Photons (BG)'));
        indNBR = (strcmp(BurstData{file}.NameArray,'Number of Photons (BR)'));
        indTauBB = (strcmp(BurstData{file}.NameArray,'Lifetime BB [ns]'));
        indSBG = (strcmp(BurstData{file}.NameArray,'Stoichiometry BG'));
        indSBR = (strcmp(BurstData{file}.NameArray,'Stoichiometry BR'));
        
        data_for_corrections = BurstData{file}.DataArray;
        
        %%% Read out corrections
        Background_BB = BurstData{file}.Background.Background_BBpar + BurstData{file}.Background.Background_BBperp;
        Background_BG = BurstData{file}.Background.Background_BGpar + BurstData{file}.Background.Background_BGperp;
        Background_BR = BurstData{file}.Background.Background_BRpar + BurstData{file}.Background.Background_BRperp;
        
        %%% use selected species
        S_threshold = UpdateCuts();
        %%% also use Lifetime Threshold
        S_threshold = S_threshold & (data_for_corrections(:,indTauBB) > 0.05);
        %%% Calculate "raw" E1A and with gamma_br = 1, but still apply direct
        %%% excitation,crosstalk, and background corrections!
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBG = data_for_corrections(S_threshold,indNBG) - Background_BG.*data_for_corrections(S_threshold,indDur);
        NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
        NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
        NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
        NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
        NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
        gamma_gr = BurstData{file}.Corrections.Gamma_GR;
        EGR = NGR./(gamma_gr.*NGG+NGR);
        NBR = NBR - BurstData{file}.Corrections.DirectExcitation_BR.*NRR - BurstData{file}.Corrections.CrossTalk_BR.*NBB -...
            BurstData{file}.Corrections.CrossTalk_GR.*(NBG-BurstData{file}.Corrections.CrossTalk_BG.*NBB) -...
            BurstData{file}.Corrections.DirectExcitation_BG*(EGR./(1-EGR)).*NGG;
        NBG = NBG - BurstData{file}.Corrections.DirectExcitation_BG.*NGG - BurstData{file}.Corrections.CrossTalk_BG.*NBB;
        %%% Calculate static FRET line in presence of linker fluctuations
        [statFRETline, statFRETfun,tau] = conversion_tau_3C(BurstData{file}.Corrections.DonorLifetimeBlue,...
            BurstData{file}.Corrections.FoersterRadiusBG,BurstData{file}.Corrections.FoersterRadiusBR,...
            BurstData{file}.Corrections.LinkerLengthBG,BurstData{file}.Corrections.LinkerLengthBR);
        %staticFRETline = @(x) 1 - (coeff(1).*x.^3 + coeff(2).*x.^2 + coeff(3).*x + coeff(4))./BurstData{file}.Corrections.DonorLifetimeBlue;
        tauBB = data_for_corrections(S_threshold,indTauBB);
        valid = (tauBB < BurstData{file}.Corrections.DonorLifetimeBlue) & (tauBB > 0.01) & ~isnan(tauBB);
        valid = find(valid);
        valid = valid(~isnan(statFRETfun( tauBB(valid))));
        %%% minimize deviation from static FRET line as a function of gamma_br!
        dev = @(gamma) sum( ( ( (gamma_gr.*NBG(valid)+NBR(valid))./(gamma.*NBB(valid) + gamma_gr.*NBG(valid) + NBR(valid)) ) - statFRETfun( tauBB(valid) ) ).^2 );
        gamma_fit = fmincon(dev,1,[],[],[],[],0,10);
        E1A =  (gamma_gr.*NBG+NBR)./(gamma_fit.*NBB + gamma_gr.*NBG + NBR);
        %%% plot E versus tau with static FRET line
        [H,xbins,ybins] = calc2dhist(data_for_corrections(S_threshold,indTauBB),E1A,[51 51],[0 min([max(tauBB) BurstData{file}.Corrections.DonorLifetimeBlue+1.5])],[-0.1 1.1]);
        BurstMeta.Plots.gamma_threecolor_lifetime(1).XData= xbins;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).YData= ybins;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).CData= H;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).AlphaData= (H>0);
        BurstMeta.Plots.gamma_threecolor_lifetime(2).XData= xbins;
        BurstMeta.Plots.gamma_threecolor_lifetime(2).YData= ybins;
        BurstMeta.Plots.gamma_threecolor_lifetime(2).ZData= H/max(max(H));
        BurstMeta.Plots.gamma_threecolor_lifetime(2).LevelList= linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
        %%% add static FRET line
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.Visible = 'on';
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.XData = tau;
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.YData = statFRETline;%statFRETfun(tau);
        ylim(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,[-0.1 1.1]);
        %%% Update UserValues
        UserValues.BurstBrowser.Corrections.Gamma_BR =gamma_fit;
        UserValues.BurstBrowser.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BR./UserValues.BurstBrowser.Corrections.Gamma_GR;
        BurstData{file}.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
        BurstData{file}.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
    end
end
%%% Save UserValues
LSUserValues(1);
%%% Update Correction Table Data
UpdateCorrections([],[],h);
%%% Apply Corrections
ApplyCorrections(obj,[]);