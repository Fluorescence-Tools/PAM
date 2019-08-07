%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Applies Corrections to data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ApplyCorrections(obj,~,h,display_update)
global BurstData UserValues BurstMeta
if nargin == 2
    h = guidata(obj);
end
if nargin < 4
    display_update = 1; %%% default to true
end
if nargin > 0
    if obj == h.UseBetaCheckbox
        UserValues.BurstBrowser.Corrections.UseBeta = obj.Value;
        LSUserValues(1);
        %%% assign obj to h.ApplyCorrectionsAll_Menu to trigger update of
        %%% all data sets
        obj = h.ApplyCorrectionsAll_Menu;
    end
end
if obj == h.ApplyCorrectionsAll_Menu
    %%% Set all files Corrections to values for current file
    BAMethod = BurstData{BurstMeta.SelectedFile}.BAMethod;
    switch BAMethod
        case {1,2,5}
            validBAMethods = [1,2,5];
        case {3,4}
            validBAMethods = [3,4];
    end
    Corrections = BurstData{BurstMeta.SelectedFile}.Corrections;

    %if ~h.MultiselectOnCheckbox.UserData
        files = 1:numel(BurstData);
    %else %%% only loop over selected foles
    %    files = get_multiselection(h);
    %    files = unique(files);
    %end
    for i = files
        if any(BurstData{i}.BAMethod == validBAMethods)
            %%% don't replace donor-only lifetimes
            DonorLifetime = BurstData{i}.Corrections.DonorLifetime;
            AcceptorLifetime = BurstData{i}.Corrections.AcceptorLifetime;

            BurstData{i}.Corrections = Corrections;

            BurstData{i}.Corrections.DonorLifetime = DonorLifetime;
            BurstData{i}.Corrections.AcceptorLifetime = AcceptorLifetime;
        end
    end
    %%% Apply Corrections
    sel_file = BurstMeta.SelectedFile;
    for i = files
        BurstMeta.SelectedFile = i;
        ApplyCorrections([],[],h,0); %%% Apply without display update
    end
    BurstMeta.SelectedFile = sel_file;
    
    %%% Update Cuts
    UpdateCuts;
    %%% Update Display
    UpdatePlot([],[],h);
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
    return;
end
if (obj == h.ApplyCorrectionsButton) & h.MultiselectOnCheckbox.UserData
    %%% disable callback and disable checkbox
    h.MultiselectOnCheckbox.Callback = [];
    h.MultiselectOnCheckbox.UserData = 0;
    
    %%% apply corrections to all selected files
    sel_file = BurstMeta.SelectedFile;
    files = get_multiselection(h); files = unique(files);
    for file = files
        BurstMeta.SelectedFile = file;
        ApplyCorrections([],[],h,0); %%% Apply without display update
    end
    BurstMeta.SelectedFile = sel_file;

    %%% reenable callback and checkbox
    h.MultiselectOnCheckbox.Callback = @UpdateOptions;
    h.MultiselectOnCheckbox.UserData = 1;
    
    %%% Update Cuts
    UpdateCuts;
    %%% Update Display
    UpdatePlot([],[],h);
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
    
    return;
end
file = BurstMeta.SelectedFile;
%% 2colorMFD
%% FRET and Stoichiometry Corrections
%%% Read out indices of parameters
switch BurstData{file}.BAMethod
    case {1,2,5} %2color
        indS = find(strcmp(BurstData{file}.NameArray,'Stoichiometry'));
        indE = find(strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
        indEPR = find(strcmp(BurstData{file}.NameArray,'Proximity Ratio'));
        indNGG = strcmp(BurstData{file}.NameArray,'Number of Photons (DD)');
        indNGR = strcmp(BurstData{file}.NameArray,'Number of Photons (DA)');
        indNRR = strcmp(BurstData{file}.NameArray,'Number of Photons (AA)');
    case {3,4} %3color
        indS = find(strcmp(BurstData{file}.NameArray,'Stoichiometry GR'));
        indE = find(strcmp(BurstData{file}.NameArray,'FRET Efficiency GR'));
        indEPR = find(strcmp(BurstData{file}.NameArray,'Proximity Ratio GR'));
        indNGG = strcmp(BurstData{file}.NameArray,'Number of Photons (GG)');
        indNGR = strcmp(BurstData{file}.NameArray,'Number of Photons (GR)');
        indNRR = strcmp(BurstData{file}.NameArray,'Number of Photons (RR)');
end
indDur = strcmp(BurstData{file}.NameArray,'Duration [ms]');


%%% Read out photons counts and duration
NGG = BurstData{file}.DataArray(:,indNGG);
NGR = BurstData{file}.DataArray(:,indNGR);
NRR = BurstData{file}.DataArray(:,indNRR);
Dur = BurstData{file}.DataArray(:,indDur);

%%% Read out corrections
gamma_gr = BurstData{file}.Corrections.Gamma_GR;
beta_gr = BurstData{file}.Corrections.Beta_GR;
ct_gr = BurstData{file}.Corrections.CrossTalk_GR;
de_gr = BurstData{file}.Corrections.DirectExcitation_GR;
if ~(BurstData{file}.BAMethod == 5) % MFD
    BG_GG = BurstData{file}.Background.Background_GGpar + BurstData{file}.Background.Background_GGperp;
    BG_GR = BurstData{file}.Background.Background_GRpar + BurstData{file}.Background.Background_GRperp;
    BG_RR = BurstData{file}.Background.Background_RRpar + BurstData{file}.Background.Background_RRperp;
elseif BurstData{file}.BAMethod == 5 % noMFD
    BG_GG = BurstData{file}.Background.Background_GGpar;
    BG_GR = BurstData{file}.Background.Background_GRpar;
    BG_RR = BurstData{file}.Background.Background_RRpar;
end

%%% Apply Background corrections
NGG = NGG - Dur.*BG_GG;
NGR = NGR - Dur.*BG_GR;
NRR = NRR - Dur.*BG_RR;

%%% recalculate proximity ratio (only background corrected)
% EPR = NGR./(NGR+NGG);

%%% Apply CrossTalk and DirectExcitation Corrections
NGR = NGR - de_gr.*NRR - ct_gr.*NGG;

%%% Recalculate FRET Efficiency and Stoichiometry
E = NGR./(NGR + gamma_gr.*NGG);
if UserValues.BurstBrowser.Corrections.UseBeta == 1
    S = (NGR + gamma_gr.*NGG)./(NGR + gamma_gr.*NGG + NRR./beta_gr);
elseif UserValues.BurstBrowser.Corrections.UseBeta == 0
    S = (NGR + gamma_gr.*NGG)./(NGR + gamma_gr.*NGG + NRR);
end

%%% Update Values in the DataArray
BurstData{file}.DataArray(:,indE) = E;
BurstData{file}.DataArray(:,indS) = S;
%BurstData{file}.DataArray(:,indEPR) = EPR;
if any(BurstData{file}.BAMethod == [1,2,5])
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET efficiency (sens. Acc. Em.)')) = beta_gr*NGR./NRR;
    FDFA = gamma_gr.*NGG./NGR; FDFA(FDFA<=0) = NaN;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'log(FD/FA)')) = log(FDFA);
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'M1-M2')) = (1-E).*(1-BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'))./BurstData{file}.Corrections.DonorLifetime);   
elseif any(BurstData{file}.BAMethod == [3,4])
    FDFA = gamma_gr.*NGG./NGR; FDFA(FDFA<=0) = NaN;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'log(FGG/FGR)')) = log(FDFA);
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'M1-M2 GR')) = (1-E).*(1-BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime GG [ns]'))./BurstData{file}.Corrections.DonorLifetime);   
end
if BurstData{file}.BAMethod ~= 5 % ensure that polarized detection was used
    %% Anisotropy Corrections
    %%% Read out indices of parameters
    switch BurstData{file}.BAMethod
        case {1,2}
            ind_rGG = strcmp(BurstData{file}.NameArray,'Anisotropy D');
            ind_rRR = strcmp(BurstData{file}.NameArray,'Anisotropy A');
            indNGGpar = strcmp(BurstData{file}.NameArray,'Number of Photons (DD par)');
            indNGGperp = strcmp(BurstData{file}.NameArray,'Number of Photons (DD perp)');
            indNRRpar = strcmp(BurstData{file}.NameArray,'Number of Photons (AA par)');
            indNRRperp = strcmp(BurstData{file}.NameArray,'Number of Photons (AA perp)');
        case {3,4}
            ind_rGG = strcmp(BurstData{file}.NameArray,'Anisotropy GG');
            ind_rRR = strcmp(BurstData{file}.NameArray,'Anisotropy RR');
            indNGGpar = strcmp(BurstData{file}.NameArray,'Number of Photons (GG par)');
            indNGGperp = strcmp(BurstData{file}.NameArray,'Number of Photons (GG perp)');
            indNRRpar = strcmp(BurstData{file}.NameArray,'Number of Photons (RR par)');
            indNRRperp = strcmp(BurstData{file}.NameArray,'Number of Photons (RR perp)');
    end

    %%% Read out photons counts and duration
    NGGpar = BurstData{file}.DataArray(:,indNGGpar);
    NGGperp = BurstData{file}.DataArray(:,indNGGperp);
    NRRpar = BurstData{file}.DataArray(:,indNRRpar);
    NRRperp = BurstData{file}.DataArray(:,indNRRperp);

    %%% Read out corrections
    Ggreen = BurstData{file}.Corrections.GfactorGreen;
    Gred = BurstData{file}.Corrections.GfactorRed;
    l1 = UserValues.BurstBrowser.Corrections.l1;
    l2 = UserValues.BurstBrowser.Corrections.l2;
    BG_GGpar = BurstData{file}.Background.Background_GGpar;
    BG_GGperp = BurstData{file}.Background.Background_GGperp;
    BG_RRpar = BurstData{file}.Background.Background_RRpar;
    BG_RRperp = BurstData{file}.Background.Background_RRperp;

    %%% Apply Background corrections
    NGGpar = NGGpar - Dur.*BG_GGpar;
    NGGperp = NGGperp - Dur.*BG_GGperp;
    NRRpar = NRRpar - Dur.*BG_RRpar;
    NRRperp = NRRperp - Dur.*BG_RRperp;

    %%% Recalculate Anisotropies
    rGG = (Ggreen.*NGGpar - NGGperp)./( (1-3*l2).*Ggreen.*NGGpar + (2-3*l1).*NGGperp);
    rRR = (Gred.*NRRpar - NRRperp)./( (1-3*l2).*Gred.*NRRpar + (2-3*l1).*NRRperp);

    %%% Update Values in the DataArray
    BurstData{file}.DataArray(:,ind_rGG) = rGG;
    BurstData{file}.DataArray(:,ind_rRR) = rRR;
end
%% 3colorMFD
if any(BurstData{file}.BAMethod == [3,4])
    %% FRET Efficiencies and Stoichiometries
    %%% Read out indices of parameters
    indE1A = strcmp(BurstData{file}.NameArray,'FRET Efficiency B->G+R');
    indEBG = strcmp(BurstData{file}.NameArray,'FRET Efficiency BG');
    indEBR = strcmp(BurstData{file}.NameArray,'FRET Efficiency BR');
    indSBG = strcmp(BurstData{file}.NameArray,'Stoichiometry BG');
    indSBR = strcmp(BurstData{file}.NameArray,'Stoichiometry BR');
    indPrGR = strcmp(BurstData{file}.NameArray,'Proximity Ratio GR');
    indPrBG = strcmp(BurstData{file}.NameArray,'Proximity Ratio BG');
    indPrBR = strcmp(BurstData{file}.NameArray,'Proximity Ratio BR');
    indPrBtoGR = strcmp(BurstData{file}.NameArray,'Proximity Ratio B->G+R');
    indNBB = strcmp(BurstData{file}.NameArray,'Number of Photons (BB)');
    indNBG = strcmp(BurstData{file}.NameArray,'Number of Photons (BG)');
    indNBR= strcmp(BurstData{file}.NameArray,'Number of Photons (BR)');
    
    %%% Read out photons counts and duration
    NBB= BurstData{file}.DataArray(:,indNBB);
    NBG = BurstData{file}.DataArray(:,indNBG);
    NBR = BurstData{file}.DataArray(:,indNBR);
    
    %%% Read out corrections
    gamma_bg = BurstData{file}.Corrections.Gamma_BG;
    beta_bg = BurstData{file}.Corrections.Beta_BG;
    gamma_br = BurstData{file}.Corrections.Gamma_BR;
    beta_br = BurstData{file}.Corrections.Beta_BR;
    ct_bg = BurstData{file}.Corrections.CrossTalk_BG;
    de_bg = BurstData{file}.Corrections.DirectExcitation_BG;
    ct_br = BurstData{file}.Corrections.CrossTalk_BR;
    de_br = BurstData{file}.Corrections.DirectExcitation_BR;
    BG_BB = BurstData{file}.Background.Background_BBpar + BurstData{file}.Background.Background_BBperp;
    BG_BG = BurstData{file}.Background.Background_BGpar + BurstData{file}.Background.Background_BGperp;
    BG_BR = BurstData{file}.Background.Background_BRpar + BurstData{file}.Background.Background_BRperp;
    
    %%% Apply Background corrections
    NBB = NBB - Dur.*BG_BB;
    NBG = NBG - Dur.*BG_BG;
    NBR = NBR - Dur.*BG_BR;
    
    %%% change name of variable E to EGR
    EGR = E;
    %%% Apply CrossTalk and DirectExcitation Corrections
    NBR = NBR - de_br.*NRR - ct_br.*NBB - ct_gr.*(NBG-ct_bg.*NBB) - de_bg*(EGR./(1-EGR)).*NGG;
    NBG = NBG - de_bg.*NGG - ct_bg.*NBB;
    %%% Recalculate FRET Efficiency and Stoichiometry
    E1A = (gamma_gr.*NBG + NBR)./(gamma_br.*NBB + gamma_gr.*NBG + NBR);
    EBG = (gamma_gr.*NBG)./(gamma_br.*NBB.*(1-EGR)+ gamma_gr.*NBG);
    EBR = (NBR - EGR.*(gamma_gr.*NBG+NBR))./(gamma_br.*NBB + NBR - EGR.*(gamma_br.*NBB + gamma_gr.*NBG + NBR));
    if UserValues.BurstBrowser.Corrections.UseBeta == 1
        SBG = (gamma_br.*NBB + gamma_gr.*NBG + NBR)./(gamma_br.*NBB + gamma_gr.*NBG + NBR + (gamma_gr.*NGG + NGR)./beta_bg);
        SBR = (gamma_br.*NBB + gamma_gr.*NBG + NBR)./(gamma_br.*NBB + gamma_gr.*NBG + NBR + NRR./beta_br);
    elseif UserValues.BurstBrowser.Corrections.UseBeta == 0
        SBG = (gamma_br.*NBB + gamma_gr.*NBG + NBR)./(gamma_br.*NBB + gamma_gr.*NBG + NBR + gamma_gr.*NGG + NGR);
        SBR = (gamma_br.*NBB + gamma_gr.*NBG + NBR)./(gamma_br.*NBB + gamma_gr.*NBG + NBR + NRR);
    end
    %%% Recalculate proximity ratios (these are corrected, but not directly
    %%% related to distance. They can be converted to distances, however,
    %%% using correct formulas.) 
    PrGR = EGR; % no change for GR
    PrBG = gamma_gr.*NBG./(gamma_br.*NBB+gamma_gr.*NBG+NBR);
    PrBR = NBR./(gamma_br.*NBB+gamma_gr.*NBG+NBR);
    PrBtoGR = gamma_br.*NBB./(gamma_br.*NBB+gamma_gr.*NBG+NBR);
    %%% Update Values in the DataArray
    BurstData{file}.DataArray(:,indE1A) = E1A;
    BurstData{file}.DataArray(:,indEBG) = EBG;
    BurstData{file}.DataArray(:,indEBR) = EBR;
    BurstData{file}.DataArray(:,indSBG) = SBG;
    BurstData{file}.DataArray(:,indSBR) = SBR;
    BurstData{file}.DataArray(:,indPrGR) = PrGR;
    BurstData{file}.DataArray(:,indPrBG) = PrBG;
    BurstData{file}.DataArray(:,indPrBR) = PrBR;
    BurstData{file}.DataArray(:,indPrBtoGR) = PrBtoGR;  
   
    %% Anisotropy Correction of blue channel
    %%% Read out indices of parameters
    ind_rBB = strcmp(BurstData{file}.NameArray,'Anisotropy BB');
    indNBBpar = strcmp(BurstData{file}.NameArray,'Number of Photons (BB par)');
    indNBBperp = strcmp(BurstData{file}.NameArray,'Number of Photons (BB perp)');
    
    %%% Read out photons counts and duration
    NBBpar = BurstData{file}.DataArray(:,indNBBpar);
    NBBperp = BurstData{file}.DataArray(:,indNBBperp);
    
    %%% Read out corrections
    Gblue = BurstData{file}.Corrections.GfactorBlue;
    BG_BBpar = BurstData{file}.Background.Background_BBpar;
    BG_BBperp = BurstData{file}.Background.Background_BBperp;
    
    %%% Apply Background corrections
    NBBpar = NBBpar - Dur.*BG_BBpar;
    NBBperp = NBBperp - Dur.*BG_BBperp;
    
    %%% Recalculate Anisotropies
    rBB = (Gblue.*NBBpar - NBBperp)./( (1-3*l2).*Gblue.*NBBpar + (2-3*l1).*NBBperp);
    
    %%% Update Value in the DataArray
    BurstData{file}.DataArray(:,ind_rBB) = rBB;
    
    %% Update derived parameters
    FBB_to_FBGFBR = gamma_br.*NBB./(gamma_gr.*NBG+NBR); FBB_to_FBGFBR(FBB_to_FBGFBR<=0) = NaN;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'log(FBB/(FBG+FBR))')) = log(FBB_to_FBGFBR);
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'M1-M2 B->G+R')) = (1-E1A).*(1-BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime BB [ns]'))./BurstData{file}.Corrections.DonorLifetimeBlue);   
end

%% Update to derived distances from intensity and lifetime
if any(BurstData{file}.BAMethod == [1,2,5]) % 2-color MFD
    %%% Distance from intensity
    E(E<0 | E>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadius;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance (from intensity) [A]')) = ((1./E-1).*R0^6).^(1/6);
    %%% Efficiency from lifetime
    tauDA = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'));
    tauD = BurstData{file}.Corrections.DonorLifetime;
    El = 1-tauDA./tauD;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET efficiency (from lifetime)')) = El;
    %%% Distance from efficiency from lifetime
    El(El<0 | El>1) = NaN;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance (from lifetime) [A]')) = ((1./El-1).*R0^6).^(1/6);
elseif any(BurstData{file}.BAMethod == [3,4]) % 3-color MFD
    %%% Distance from intensity GR
    EGR(EGR<0 | EGR>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadius;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance GR (from intensity) [A]')) = ((1./EGR-1).*R0^6).^(1/6);
    %%% Efficiency from lifetime GR
    tauDA = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime GG [ns]'));
    tauD = BurstData{file}.Corrections.DonorLifetime;
    El = 1-tauDA./tauD;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET efficiency GR (from lifetime)')) = El;
    %%% Distance from efficiency from lifetime
    El(El<0 | El>1) = NaN;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance GR (from lifetime) [A]')) = ((1./El-1).*R0^6).^(1/6);
    %%% Distance from intensity BG
    EBG(EBG<0 | EBG>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadiusBG;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance BG (from intensity) [A]')) = ((1./EBG-1).*R0^6).^(1/6);
     %%% Distance from intensity BG
    EBR(EBR<0 | EBR>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadiusBR;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance BR (from intensity) [A]')) = ((1./EBR-1).*R0^6).^(1/6);
    %%% Lifetime-Efficiency relation does not hold true for 3 color!
end

h.ApplyCorrectionsButton.ForegroundColor = UserValues.Look.Fore;

if display_update
    UpdateCuts;
    %%% Update Display
    UpdatePlot([],[],h);
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
end