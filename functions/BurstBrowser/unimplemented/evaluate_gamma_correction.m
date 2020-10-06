%%% this function evaluates the deviation of the 
function evaluate_gamma_correction()
global BurstData BurstMeta UserValues
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;

fontsize = 14;
if ispc
    fontsize= fontsize*0.72;
end

% use the user selected species
if ~h.MultiselectOnCheckbox.UserData
    Valid = UpdateCuts();
    S = BurstData{file}.DataArray(Valid,strcmp(BurstData{file}.NameArray,'Stoichiometry'));
    E = BurstData{file}.DataArray(Valid,strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
    tau = BurstData{file}.DataArray(Valid,strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'));
else
    S = get_multiselection_data(h,'Stoichiometry');
    E = get_multiselection_data(h,'FRET Efficiency');
    tau = get_multiselection_data(h,'Lifetime D [ns]');
end

% binwise or burstwise?
binwise = false;

% Threshold for burst number for a bin to be considered
N_burst_min = 100;

%%% for E-S+
Ebins = linspace(-0.2,1.2,1.4/0.025);
if binwise
    %%% bin along E axis
    [hE, bin_edges, binE] = histcounts(E,Ebins);
    %%% determine mean FRET efficiency/stoichiometry and standard deviation for every bin
    mE = nan(size(hE));
    sE = nan(size(hE));
    mS = nan(size(hE));
    sS = nan(size(hE));
    mTau = nan(size(hE));
    sTau = nan(size(hE));
    for i = unique(binE)'
        if sum(binE == i) >= N_burst_min
            mE(i) = mean(E(binE==i));
            sE(i) = std(E(binE==i))./sqrt(hE(i));
            mS(i) = mean(S(binE==i));
            sS(i) = std(S(binE==i))./sqrt(hE(i));
            mTau(i) = mean(tau(binE==i));
            sTau(i) = std(tau(binE==i))./sqrt(hE(i));
        end
    end

    %%% calculate deviation to S=0.5 line
    w_res_S = (mS-0.5)./sS;
    fprintf('red. Chi2 E-S: %.2f\n',sum(w_res_S(isfinite(w_res_S)).^2)./sum(isfinite(w_res_S)));
else
    w_res_S = (S-0.5);
    fprintf('RMSE E-S: %.4f\n',sqrt(sum(w_res_S(isfinite(w_res_S)).^2)./numel(w_res_S(isfinite(w_res_S)))));
end

colors = lines(3);
figure('Color',[1,1,1],'Position',[100,100,800,450]);
ax1 = subplot(2,2,1); hold on;
if binwise
    scatter(mE,w_res_S,'filled','MarkerFaceColor',colors(1,:));
else
    scatter(E,w_res_S,5,'filled','MarkerFaceColor','k');
end
plot([-0.2,1.2],[0,0],'--r','LineWidth',1.5);
ax2 = subplot(2,2,3);hold on;
[ES,xE,xS] = histcounts2(E,S,Ebins,linspace(0,1,50));
ES = ES';
imagesc(xE(1:end-1)+min(diff(xE))/2,xS(1:end-1)+min(diff(xS))/2,ES,'AlphaData',ES>0);
colormap(flipud(gray));
plot([-0.2,2.2],[0.5,0.5],'LineWidth',1.5,'Color','r');
%scatter(mE,mS,'filled');
if binwise
    errorbar(mE,mS,sS,'o','MarkerFaceColor',colors(1,:),'MarkerEdgeColor',colors(1,:),'Color',colors(1,:),'LineWidth',1.5);
end

set([ax1,ax2],'Box','on','LineWidth',1.5,'Units','normalized','FontSize',fontsize,'Layer','top','Color',[1,1,1]);
ax1.Position(1) = 0.08;
ax2.Position(1) = 0.08;
ax1.Position(3) = 0.4;
ax2.Position(3) = 0.4;
ax2.Position(4) = 0.65;
ax1.Position(4) = 0.15;
ax1.Position(2) = ax2.Position(2)+ax2.Position(4)+0.03;
linkaxes([ax1,ax2],'x');
xlim([-0.2,1.2]); ylim([0,1]);
set(ax2,'XTick',-0.2:0.2:1.2);
%ax2.YTick = ax2.YTick(1:end-1);
ax1.XTickLabel = [];
ylabel(ax1,'w. res.');
xlabel(ax2,'FRET efficiency');
ylabel(ax2,'Stoichiometry');

%%% for E-tau
% filter tau = 0
valid = tau > 0;
E = E(valid);
S = S(valid);
tau = tau(valid);
%%% bin along tau axis
tauNorm = tau./BurstData{file}.Corrections.DonorLifetime;

%%% rotate everything by 45° = pi/4;
deltaEtau = 2^(-1/2)*(tauNorm-E);
sigmaEtau = 2^(-1/2)*(tauNorm+E);
% overwrite variables
tau = deltaEtau;
E = sigmaEtau;

%%% get the static FRET line
[~,staticFRETline,~] = conversion_tau(BurstData{file}.Corrections.DonorLifetime,...
            BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength);
            
tau_bins = linspace(-1,1,50);
Ebins = linspace(0.5,1,50);
if binwise
    [hTau, ~, binTau] = histcounts(tau,tau_bins);
    %%% determine mean FRET efficiency/stoichiometry and standard deviation for every bin
    mE = nan(size(hTau));
    sE = nan(size(hTau));
    mTau = nan(size(hTau));
    sTau = nan(size(hTau));
    mTauNorm = nan(size(hTau));
    for i = unique(binTau)'
        if i~=0 && sum(binTau == i) >= N_burst_min
            mE(i) = mean(E(binTau==i));
            sE(i) = std(E(binTau==i)./sqrt(hTau(i)));
            mTau(i) = mean(tau(binTau==i));
            sTau(i) = std(tau(binTau==i))./sqrt(hTau(i));
            mTauNorm(i) = mean(tauNorm(binTau==i));
        end
    end

    E_model = staticFRETline(mTauNorm.*BurstData{file}.Corrections.DonorLifetime);
    %%% rotate static FRET line by 45° = pi/4;
    deltaEtau = 2^(-1/2)*(mTauNorm-E_model);
    sigmaEtau = 2^(-1/2)*(mTauNorm+E_model);
    mTauNorm = deltaEtau;
    E_model = sigmaEtau;
    %%%  calculate deviation to  static FRET line
    w_res_E = (mE-E_model)./sE;
    fprintf('red. Chi2 E-tau: %.2f\n',sum(w_res_E(isfinite(w_res_E)).^2)./sum(isfinite(w_res_E)));
else
    E_model = staticFRETline(tauNorm.*BurstData{file}.Corrections.DonorLifetime);
    %%% rotate static FRET line by 45° = pi/4;
    deltaEtau = 2^(-1/2)*(tauNorm-E_model);
    sigmaEtau = 2^(-1/2)*(tauNorm+E_model);
    tauNorm = deltaEtau;
    E_model = sigmaEtau;
    %%%  calculate deviation to  static FRET line
    w_res_E = (E-E_model);
    fprintf('RMSE E-tau: %.4f\n',sqrt(sum(w_res_E(isfinite(w_res_E)).^2)./numel(w_res_E(isfinite(w_res_E)))));
end
ax1 = subplot(2,2,2); hold on;
if binwise
    scatter(mTau,w_res_E,'filled','MarkerFaceColor',colors(1,:));
else
    scatter(tauNorm,w_res_E,5,'filled','MarkerFaceColor','k');
end
plot([-1,1],[0,0],'--r','LineWidth',1.5);
ax2 = subplot(2,2,4);hold on;
[Etau,xtau,xE] = histcounts2(tau,E,tau_bins,Ebins);
Etau = Etau';
imagesc(xtau(1:end-1)+min(diff(xtau))/2,xE(1:end-1)+min(diff(xE))/2,Etau,'AlphaData',Etau>0);
colormap(flipud(gray));
%scatter(tau,E); 
t = linspace(0,BurstData{file}.Corrections.DonorLifetime,1000);
sl = staticFRETline(t);
t = t./BurstData{file}.Corrections.DonorLifetime;
%%% rotate static FRET line by 45° = pi/4;
t_r = 2^(-1/2)*(t-sl);
sl_r = 2^(-1/2)*(t+sl);
plot(t_r,sl_r,'LineWidth',1.5,'Color','r');
%scatter(mTau,mE,'filled');
if binwise
    errorbar(mTau,mE,sE,'o','MarkerFaceColor',colors(1,:),'MarkerEdgeColor',colors(1,:),'Color',colors(1,:),'LineWidth',1.5);
end
set([ax1,ax2],'Box','on','LineWidth',1.5,'Units','normalized','FontSize',fontsize,'Layer','top','Color',[1,1,1]);
ax1.Position(1) = 0.58;
ax2.Position(1) = 0.58;
ax1.Position(3) = 0.4;
ax2.Position(3) = 0.4;
ax2.Position(4) = 0.65;
ax1.Position(4) = 0.15;
ax1.Position(2) = ax2.Position(2)+ax2.Position(4)+0.03;
linkaxes([ax1,ax2],'x');
axis(ax2,'tight');
xlim([-1,1]); ylim([0.5,1]);
ax1.XTickLabel = [];
ylabel(ax1,'w. res.');
ylabel(ax2,'(\langle\tau_{D(A)}\rangle_F/\tau_{D(0)} + E)/\surd 2','interpreter','tex');
xlabel(ax2,'(\langle\tau_{D(A)}\rangle_F/\tau_{D(0)} - E)/\surd 2','interpreter','tex');
