%%% Quantify the consistency of the corrected data
%%% Agreement with E-tau plot
%%% Deviation from S=0.5 line
function check_gamma_beta_consistency(h,mode)
global UserValues BurstData BurstMeta
file = BurstMeta.SelectedFile;

if nargin < 2
    mode = [1,2];
end

if any(mode == 1) %%% S deviation
    %%% deviation of S from S = 0.5 line
    % only makes sense if beta correction is activated
    if UserValues.BurstBrowser.Corrections.UseBeta
        S = get_multiselection_data(h,'Stoichiometry');
        RMSE_S = sqrt(sum((S-0.5).^2,'omitnan')/numel(S));
        fprintf('Root mean square error to S=0.5 line:\t\t%.5f\n',RMSE_S);
    end
end

if any(mode == 2) %%% static FRET-line deviation
    E = get_multiselection_data(h,'FRET Efficiency');
    tau = get_multiselection_data(h,'Lifetime D [ns]');    
    %%% deviation from E-tau line
    % only makes sense if lifetime is available
    if ~all(tau==0)
        % get static FRET-line
        [~,staticFRETline,~] = conversion_tau(BurstData{file}.Corrections.DonorLifetime,...
            BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength);
        E_model = staticFRETline(tau);
        valid = E > 0 & E <1 & tau > 0 & tau <= BurstData{file}.Corrections.DonorLifetime & ~isnan(tau) & ~isnan(E_model);
        RMSE_tau = sqrt(sum((E(valid)-E_model(valid)).^2)/sum(valid));
        % convert to proximity ratio to have the correct noise characteristics
        %FRETtoPR = @(E) 1-(1-E)./(1+BurstData{file}.Corrections.CrossTalk_GR+BurstData{file}.Corrections.DirectExcitation_GR*BurstData{file}.Corrections.Gamma_GR*BurstData{file}.Corrections.Beta_GR-...
        %            (1+BurstData{file}.Corrections.CrossTalk_GR-BurstData{file}.Corrections.Gamma_GR).*E);
        %E = FRETtoPR(E);
        %E_model = FRETtoPR(E_model);
        %N_GX = get_multiselection_data(h,'Number of Photons (DD)') + get_multiselection_data(h,'Number of Photons (DA)');
        %sigma_E = sqrt(E.*(1-E)./N_GX);
        %valid = E > 0 & E <1 & tau > 0 & tau <= BurstData{file}.Corrections.DonorLifetime & ~isnan(tau) & ~isnan(E_model);
        %RMSE_tau = sqrt(sum(((E(valid)-E_model(valid))./sigma_E(valid)).^2)/sum(valid));
        fprintf('Root mean square error to static FRET-line:\t%.5f\n',RMSE_tau);
    end
end