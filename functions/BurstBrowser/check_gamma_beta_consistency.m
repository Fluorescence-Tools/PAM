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
        RMSE_tau = sqrt(sum((E-staticFRETline(tau)).^2,'omitnan')/numel(E));
        fprintf('Root mean square error to static FRET-line:\t%.5f\n',RMSE_tau);
    end
end