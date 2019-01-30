%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates fFCS filter and updates plots %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Calc_fFCS_Filters(obj,~)
global BurstMeta BurstData UserValues
h = guidata(obj);
file = BurstMeta.SelectedFile;
%%% Concatenate Decay Patterns
Decay_par = [BurstMeta.fFCS.hist_MIpar_Species{1},...
    BurstMeta.fFCS.hist_MIpar_Species{2}];
if isfield(BurstData{file},'ScatterPattern') && UserValues.BurstBrowser.Settings.fFCS_UseIRF %%% include scatter pattern
    if isfield(BurstMeta.fFCS,'hScat_par')
        Decay_par = [Decay_par, BurstMeta.fFCS.hScat_par(1:size(Decay_par,1))'];
    end
end

if UserValues.BurstBrowser.Settings.fFCS_Mode == 4 %%% include DOnly pattern
    if isfield(BurstMeta.fFCS,'hDOnly_par')
        Decay_par = [Decay_par, BurstMeta.fFCS.hDOnly_par(1:size(Decay_par,1))];
    end
end
Decay_par = Decay_par./repmat(sum(Decay_par,1),size(Decay_par,1),1);
Decay_total_par = BurstMeta.fFCS.hist_MItotal_par;
Decay_total_par(Decay_total_par == 0) = 1; %%% fill zeros with eps
Decay_perp = [BurstMeta.fFCS.hist_MIperp_Species{1},...
    BurstMeta.fFCS.hist_MIperp_Species{2}];
if isfield(BurstData{file},'ScatterPattern') && UserValues.BurstBrowser.Settings.fFCS_UseIRF %%% include scatter pattern
    if isfield(BurstMeta.fFCS,'hScat_perp')
        Decay_perp = [Decay_perp, BurstMeta.fFCS.hScat_perp(1:size(Decay_perp,1))'];
    end
end
if UserValues.BurstBrowser.Settings.fFCS_Mode == 4 %%% include DOnly pattern
    if isfield(BurstMeta.fFCS,'hDOnly_perp')
        Decay_perp = [Decay_perp, BurstMeta.fFCS.hDOnly_perp(1:size(Decay_perp,1))];
    end
end
Decay_perp = Decay_perp./repmat(sum(Decay_perp,1),size(Decay_perp,1),1);
Decay_total_perp = BurstMeta.fFCS.hist_MItotal_perp;
Decay_total_perp(Decay_total_perp == 0) = 1; %%% fill zeros with 1
%%% calculate the diagonal over the Decay_total
diag_Decay_total_par = zeros(numel(Decay_total_par));
for i = 1:numel(Decay_total_par)
    diag_Decay_total_par(i,i) = 1/Decay_total_par(i);
end
diag_Decay_total_perp = zeros(numel(Decay_total_perp));
for i = 1:numel(Decay_total_perp)
    diag_Decay_total_perp(i,i) = 1/Decay_total_perp(i);
end

BurstMeta.fFCS.filters_par = (Decay_par'*diag_Decay_total_par*Decay_par)^(-1)*Decay_par'*diag_Decay_total_par;
BurstMeta.fFCS.reconstruction_par = sum((Decay_par'*diag_Decay_total_par*Decay_par)^(-1)*Decay_par',1);
BurstMeta.fFCS.weighted_residuals_par = (Decay_total_par'-BurstMeta.fFCS.reconstruction_par)./(sqrt(Decay_total_par'));
BurstMeta.fFCS.filters_perp = (Decay_perp'*diag_Decay_total_perp*Decay_perp)^(-1)*Decay_perp'*diag_Decay_total_perp;
BurstMeta.fFCS.reconstruction_perp = sum((Decay_perp'*diag_Decay_total_perp*Decay_perp)^(-1)*Decay_perp',1);
BurstMeta.fFCS.weighted_residuals_perp = (Decay_total_perp'-BurstMeta.fFCS.reconstruction_perp)./(sqrt(Decay_total_perp'));

%%% Update plots
BurstMeta.Plots.fFCS.FilterPar_Species1.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.FilterPar_Species1.YData = BurstMeta.fFCS.filters_par(1,:);
BurstMeta.Plots.fFCS.FilterPar_Species2.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.FilterPar_Species2.YData = BurstMeta.fFCS.filters_par(2,:);
if size(BurstMeta.fFCS.filters_par,1) > 2
    BurstMeta.Plots.fFCS.FilterPar_IRF.Visible = 'on';
    BurstMeta.Plots.fFCS.FilterPar_IRF.XData = BurstMeta.fFCS.TAC_par;
    BurstMeta.Plots.fFCS.FilterPar_IRF.YData = BurstMeta.fFCS.filters_par(3,:);
else
    BurstMeta.Plots.fFCS.FilterPar_IRF.Visible = 'off';
end
if size(BurstMeta.fFCS.filters_par,1) > 3
    BurstMeta.Plots.fFCS.FilterPar_DOnly.Visible = 'on';
    BurstMeta.Plots.fFCS.FilterPar_DOnly.XData = BurstMeta.fFCS.TAC_par;
    BurstMeta.Plots.fFCS.FilterPar_DOnly.YData = BurstMeta.fFCS.filters_par(4,:);
else
    BurstMeta.Plots.fFCS.FilterPar_DOnly.Visible = 'off';
end
BurstMeta.Plots.fFCS.Reconstruction_Decay_Par.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.Reconstruction_Decay_Par.YData = BurstMeta.fFCS.hist_MItotal_par;
BurstMeta.Plots.fFCS.Reconstruction_Par.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.Reconstruction_Par.YData = BurstMeta.fFCS.reconstruction_par;
BurstMeta.Plots.fFCS.Weighted_Residuals_Par.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.Weighted_Residuals_Par.YData = BurstMeta.fFCS.weighted_residuals_par;

BurstMeta.Plots.fFCS.FilterPerp_Species1.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.FilterPerp_Species1.YData = BurstMeta.fFCS.filters_perp(1,:);
BurstMeta.Plots.fFCS.FilterPerp_Species2.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.FilterPerp_Species2.YData = BurstMeta.fFCS.filters_perp(2,:);
if size(BurstMeta.fFCS.filters_perp,1) > 2
    BurstMeta.Plots.fFCS.FilterPerp_IRF.Visible = 'on';
    BurstMeta.Plots.fFCS.FilterPerp_IRF.XData = BurstMeta.fFCS.TAC_perp;
    BurstMeta.Plots.fFCS.FilterPerp_IRF.YData = BurstMeta.fFCS.filters_perp(3,:);
else
    BurstMeta.Plots.fFCS.FilterPerp_IRF.Visible = 'off';
end
if size(BurstMeta.fFCS.filters_perp,1) > 3
    BurstMeta.Plots.fFCS.FilterPerp_DOnly.Visible = 'on';
    BurstMeta.Plots.fFCS.FilterPerp_DOnly.XData = BurstMeta.fFCS.TAC_perp;
    BurstMeta.Plots.fFCS.FilterPerp_DOnly.YData = BurstMeta.fFCS.filters_perp(4,:);
else
    BurstMeta.Plots.fFCS.FilterPerp_DOnly.Visible = 'off';
end
BurstMeta.Plots.fFCS.Reconstruction_Decay_Perp.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.Reconstruction_Decay_Perp.YData = BurstMeta.fFCS.hist_MItotal_perp;
BurstMeta.Plots.fFCS.Reconstruction_Perp.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.Reconstruction_Perp.YData = BurstMeta.fFCS.reconstruction_perp;
BurstMeta.Plots.fFCS.Weighted_Residuals_Perp.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.Weighted_Residuals_Perp.YData = BurstMeta.fFCS.weighted_residuals_perp;

uistack(BurstMeta.Plots.fFCS.Reconstruction_Par,'top')
uistack(BurstMeta.Plots.fFCS.Reconstruction_Perp,'top')
axis(h.axes_fFCS_FilterPar,'tight');
axis(h.axes_fFCS_FilterPerp,'tight');
axis(h.axes_fFCS_ReconstructionPar,'tight');h.axes_fFCS_ReconstructionPar.YScale = 'log';
axis(h.axes_fFCS_ReconstructionPerp,'tight');h.axes_fFCS_ReconstructionPerp.YScale = 'log';
axis(h.axes_fFCS_ReconstructionParResiduals,'tight');
axis(h.axes_fFCS_ReconstructionPerpResiduals,'tight');
uistack(BurstMeta.Plots.fFCS.Reconstruction_Par,'top');
uistack(BurstMeta.Plots.fFCS.Reconstruction_Perp,'top');
h.Do_fFCS_button.Enable = 'on';