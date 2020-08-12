%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Determine Corrections (alpha, beta, gamma from intensity) %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineCorrections(obj,~)
global BurstData BurstMeta UserValues
LSUserValues(0);
h = guidata(obj);

file = BurstMeta.SelectedFile;

switch BurstData{file}.BAMethod
    case {1,2,5}
        h.Main_Tab.SelectedTab = h.Main_Tab_Corrections;
    case {3,4}
        switch obj
            case {h.DetermineCorrectionsButton,h.DetermineGammaLifetimeTwoColorButton,h.DetermineGammaManuallyButton}
                h.Main_Tab.SelectedTab = h.Main_Tab_Corrections;
            case {h.FitGammaButton,h.DetermineGammaLifetimeThreeColorButton}
                h.Main_Tab.SelectedTab = h.Main_Tab_Corrections_ThreeCMFD;
        end
end
%%% Change focus to CorrectionsTab
switch BurstData{file}.BAMethod
    case {1,2,5}
        indS = find(strcmp(BurstData{file}.NameArray,'Stoichiometry (raw)'));
        indE = find(strcmp(BurstData{file}.NameArray,'Proximity Ratio'));
        indNGG = find(strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'));
        indNGR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'));
        indNRR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (AA)'));
    case {3,4}
        indS = find(strcmp(BurstData{file}.NameArray,'Stoichiometry GR'));
        indE = find(strcmp(BurstData{file}.NameArray,'Proximity Ratio GR'));
        indNGG = find(strcmp(BurstData{file}.NameArray,'Number of Photons (GG)'));
        indNGR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (GR)'));
        indNRR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (RR)'));
end
%indE = find(strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
indDur = find(strcmp(BurstData{file}.NameArray,'Duration [ms]'));


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

%% 2cMFD Corrections
use_countrate = false;
%% Crosstalk and direct excitation
if any(obj == [h.DetermineCorrectionsButton, h.DetermineCorrectionsFromPhotonCounts])
    %%% read raw data
    if ~h.MultiselectOnCheckbox.UserData
        data_for_corrections = BurstData{file}.DataArray;
    else
        Files = get_multiselection(h);
        Files = unique(Files);
        data_for_corrections = cell(numel(Files),1);
        n_param = size(BurstData{Files(1)}.DataArray,2); % truncate all arrays to number of elements in first file
        for i = 1:numel(Files)
            data_for_corrections{i} = BurstData{Files(i)}.DataArray(:,1:n_param);
        end
        data_for_corrections = vertcat(data_for_corrections{:});
    end
    %% plot raw FRET Efficiency for S>0.9
    Emin = UserValues.BurstBrowser.Settings.E_Donly_Min;
    Emax = UserValues.BurstBrowser.Settings.E_Donly_Max;
    x_axis = linspace(Emin,Emax,120);
    Smin = UserValues.BurstBrowser.Settings.S_Donly_Min;
    Smax = UserValues.BurstBrowser.Settings.S_Donly_Max;
    S_threshold = (data_for_corrections(:,indS)>Smin) & (data_for_corrections(:,indS)<Smax);
    dur = data_for_corrections(S_threshold,indDur);
    NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*dur;
    NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*dur;
    
    switch obj 
        case h.DetermineCorrectionsButton
            E_raw = NGR./(NGR+NGG);
            histE_donly = histc(E_raw,x_axis);
            x_axis = x_axis(1:end-1);
            histE_donly(end-1) = histE_donly(end-1)+histE_donly(end);
            histE_donly(end) = [];
            BurstMeta.Plots.histE_donly.XData = x_axis;
            BurstMeta.Plots.histE_donly.YData = histE_donly;
            axis(h.Corrections.TwoCMFD.axes_crosstalk,'tight');
            h.Corrections.TwoCMFD.axes_crosstalk.XLabel.String = 'Proximity Ratio';
            h.Corrections.TwoCMFD.axes_crosstalk.Title.String = 'Proximity Ratio of Donor only';
            %fit single gaussian
            [mean_ct, GaussFit] = GaussianFit(x_axis',histE_donly);
            BurstMeta.Plots.Fits.histE_donly(1).XData = x_axis;
            BurstMeta.Plots.Fits.histE_donly(1).YData = GaussFit;
            ct = mean_ct/(1-mean_ct);
        case h.DetermineCorrectionsFromPhotonCounts
            %%% instead of gaussian fit, use the proportionality
            %%% relationship between the photon counts NGR = alpha*NGG
            if use_countrate % use countrate: normalize by duration
                NGG = NGG./dur;
                NGR = NGR./dur;
            end
            lm = fitlm(NGG,NGR,'Intercept',false,'RobustOpts','on');
            ct = table2array(lm.Coefficients('x1',1));
            ct_ci = table2array(lm.Coefficients('x1',2));
            figure('Color',[1,1,1],'Position',[100,100,1000,400]);
            subplot(1,2,1);
            plot(lm);
            set(gca,'Color',[1,1,1],'Layer','Top','FontSize',16,'LineWidth',2,'Box','on');
            title(sprintf('Crosstalk \\alpha = %.4f \\pm %.4f',ct,ct_ci),'Interpreter','tex');
            xlabel('Photon counts N_{GG}','Interpreter','tex');
            ylabel('Photon counts N_{GR}','Interpreter','tex');
            xlim([0,prctile(NGG,99)]);
            ylim([0,prctile(NGR,99)]);
            legend('off');
    end
    if ~isnan(ct) && (ct > 0)
        UserValues.BurstBrowser.Corrections.CrossTalk_GR = ct;
    end

    if ~h.MultiselectOnCheckbox.UserData
        BurstData{file}.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
    else %%% Update for all files contributing
        Files = get_multiselection(h);
        for i = 1:numel(Files)
            BurstData{Files(i)}.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
        end
    end

    %% plot raw data for S < 0.25 for direct excitation
    Smin = UserValues.BurstBrowser.Settings.S_Aonly_Min;
    Smax = UserValues.BurstBrowser.Settings.S_Aonly_Max;
    Emin = UserValues.BurstBrowser.Settings.E_Aonly_Min;
    Emax = UserValues.BurstBrowser.Settings.E_Aonly_Max;
    x_axis = linspace(Smin,Smax,100);
    S_threshold = (data_for_corrections(:,indS)<Smax) & (data_for_corrections(:,indS)>Smin) & ...
        (data_for_corrections(:,indE)>Emin) & ...
        (data_for_corrections(:,indE)<Emax);
    dur = data_for_corrections(S_threshold,indDur);
    NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*dur;
    NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*dur;
    NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*dur;
    switch obj 
        case h.DetermineCorrectionsButton
            S_raw = (NGG+NGR)./(NGG+NGR+NRR);
            histS_aonly = histc(S_raw,x_axis);
            x_axis = x_axis(1:end-1);
            histS_aonly(end-1) = histS_aonly(end-1)+histS_aonly(end);
            histS_aonly(end) = [];
            BurstMeta.Plots.histS_aonly.XData = x_axis;
            BurstMeta.Plots.histS_aonly.YData = histS_aonly;
            axis(h.Corrections.TwoCMFD.axes_direct_excitation,'tight');
            h.Corrections.TwoCMFD.axes_direct_excitation.XLabel.String = 'Stoichiometry (raw)';
            h.Corrections.TwoCMFD.axes_direct_excitation.Title.String = 'Raw Stoichiometry of Acceptor only';
            %fit single gaussian
            [mean_de, GaussFit] = GaussianFit(x_axis',histS_aonly);
            BurstMeta.Plots.Fits.histS_aonly(1).XData = x_axis;
            BurstMeta.Plots.Fits.histS_aonly(1).YData = GaussFit;
            de = mean_de/(1-mean_de);
        case h.DetermineCorrectionsFromPhotonCounts
            %%% instead of gaussian fit, use the proportionality
            %%% relationship between the photon counts NGR = alpha*NGG
            if use_countrate % use countrate: normalize by duration
                NRR = NRR./dur;
                NGR = NGR./dur;
            end
            lm = fitlm(NRR,NGR,'Intercept',false,'RobustOpts','on');
            de = table2array(lm.Coefficients('x1',1));
            de_ci = table2array(lm.Coefficients('x1',2));
            subplot(1,2,2);
            plot(lm);
            set(gca,'Color',[1,1,1],'Layer','Top','FontSize',16,'LineWidth',2,'Box','on');
            title(sprintf('Direct excitation \\delta = %.4f \\pm %.4f',de,de_ci),'Interpreter','tex');
            xlabel('Photon counts N_{RR}','Interpreter','tex');
            ylabel('Photon counts N_{GR}','Interpreter','tex');
            xlim([0,prctile(NRR,99)]);
            ylim([0,prctile(NGR,99)]);
            legend('off');
    end
    
    if ~isnan(de) && (de > 0)
        UserValues.BurstBrowser.Corrections.DirectExcitation_GR = de;
    end
    if ~h.MultiselectOnCheckbox.UserData
        BurstData{file}.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
    else %%% Update for all files contributing
        Files = get_multiselection(h);
        for i = 1:numel(Files)
            BurstData{Files(i)}.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
        end
    end
end
if any(obj == [h.FitGammaButton, h.DetermineGammaManuallyButton, h.FitGammaFromStoichiometryDistribution, h.FitGammaFromPhotonCounts, h.FitGammaFromPhotonCountsBetaFixed])
    %% plot gamma plot for two populations (or lifetime versus E)
    % use the user selected species
    if ~h.MultiselectOnCheckbox.UserData
        Valid = UpdateCuts();
        %%% Calculate "raw" E and S with gamma = 1, but still apply direct
        %%% excitation,crosstalk, and background corrections!
        dur = BurstData{file}.DataArray(Valid,indDur);
        NGR = BurstData{file}.DataArray(Valid,indNGR) - Background_GR.*dur;
        NGG = BurstData{file}.DataArray(Valid,indNGG) - Background_GG.*dur;
        NRR = BurstData{file}.DataArray(Valid,indNRR) - Background_RR.*dur;
        NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
    else
        switch BurstData{file}.BAMethod
            case {1,2,5}
                NGR = get_multiselection_data(h,'Number of Photons (DA)');
                NGG = get_multiselection_data(h,'Number of Photons (DD)');
                NRR = get_multiselection_data(h,'Number of Photons (AA)');
            case {3,4}
                NGR = get_multiselection_data(h,'Number of Photons (GR)');
                NGG = get_multiselection_data(h,'Number of Photons (GG)');
                NRR = get_multiselection_data(h,'Number of Photons (RR)');
        end
        dur = get_multiselection_data(h,'Duration [ms]');
        NGR = NGR - Background_GR.*dur;
        NGG = NGG - Background_GG.*dur;
        NRR = NRR - Background_RR.*dur;
        NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
    end
    E_raw = NGR./(NGR+NGG);
    S_raw = (NGG+NGR)./(NGG+NGR+NRR);
    % switch obj
    %     case h.FitGammaButton
    %         [H,xbins,ybins] = calc2dhist(E_raw,1./S_raw,[51 51],[0 1], [1 quantile(1./S_raw,0.99)]);
    %     case h.DetermineGammaManuallyButton
    %         [H,xbins,ybins] = calc2dhist(E_raw,S_raw,[51 51],[0 1], [min(S_raw) max(S_raw)]);
    % end
    [H,xbins,ybins] = calc2dhist(E_raw,S_raw,[51 51],[-0.1 1], [min(S_raw) max(S_raw)]);
    
    BurstMeta.Plots.gamma_fit(1).XData= xbins;
    BurstMeta.Plots.gamma_fit(1).YData= ybins;
    BurstMeta.Plots.gamma_fit(1).CData= H;
    BurstMeta.Plots.gamma_fit(1).AlphaData= (H>0);
    BurstMeta.Plots.gamma_fit(2).XData= xbins;
    BurstMeta.Plots.gamma_fit(2).YData= ybins;
    BurstMeta.Plots.gamma_fit(2).ZData= H/max(max(H));
    BurstMeta.Plots.gamma_fit(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    switch obj
        case {h.FitGammaButton, h.FitGammaFromPhotonCounts, h.FitGammaFromPhotonCountsBetaFixed}
            %%% Update/Reset Axis Labels
            xlabel(h.Corrections.TwoCMFD.axes_gamma,'FRET Efficiency','Color',UserValues.Look.Fore);
            ylabel(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry','Color',UserValues.Look.Fore);
            title(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry vs. FRET Efficiency for gamma = 1','Color',UserValues.Look.Fore);
            %%% store for later use
            BurstMeta.Data.E_raw = E_raw;
            BurstMeta.Data.S_raw = S_raw;
            
            xdata = linspace(-0.1,1,1100);
            funS = @(b,g,x) (1+g*b+(1-g)*b*x).^(-1);
            
            if any(obj == [h.FitGammaFromPhotonCounts,h.FitGammaFromPhotonCountsBetaFixed])
                if use_countrate % use countrate: normalize by duration
                    NGG = NGG./dur;
                    NGR = NGR./dur;
                    NRR = NRR./dur;
                end
                switch obj
                    case h.FitGammaFromPhotonCounts
                        % Fit plane into photon counts directly, according to:
                        % Coullomb, A. et al. QuanTI-FRET: a framework for quantitative FRET measurements in living cells. Scientific Reports 10, (2020).
                
                        % using linear regression
                        fitGamma = fitlm([NGG,NGR],NRR,'Intercept',false,'RobustOpts','on');
                        x1 = table2array(fitGamma.Coefficients('x1',1));
                        x1_ci = table2array(fitGamma.Coefficients('x1',2));
                        x2 = table2array(fitGamma.Coefficients('x2',1));
                        x2_ci = table2array(fitGamma.Coefficients('x2',2));
                        beta = x2;
                        gamma = x1./beta;
                        beta_ci = x2_ci;
                        gamma_ci = gamma.*sqrt(x1_ci.^2+x2_ci.^2);
                        %model = @(b,g,x,y) b.*g.*x+b.*y;
                        %fitGamma = fit([NGG,NGR],NRR,model,'StartPoint',[1,1],'Lower',[0,0],'Robust','LAR');
                        %coeff = coeffvalues(fitGamma);
                        %beta = coeff(1); gamma = coeff(2);
                        ydata = funS(beta,gamma,xdata);

                        % plot the regression result
                        figure('Color',[1,1,1],'Position',[100,100,600,550]); hold on;
                        [x,y] = meshgrid(linspace(min(NGG),max(NGG),100),linspace(min(NGR),max(NGR),100));
                        z = gamma.*beta.*x+beta.*y;
                        surf(x,y,z,'EdgeColor','none','Facecolor','interp','FaceLighting','gouraud','FaceAlpha',0.5);
                        scatter3(NGG,NGR,NRR,'.k');
                        xlim([0,prctile(NGG,99)]);
                        ylim([0,prctile(NGR,99)]);
                        zlim([0,prctile(NRR,99)]);
                        set(gca,'Color',[1,1,1],'Box','on','LineWidth',1.5,'XGrid','on','YGrid','on','FontSize',16,'View',[40,50]);
                        xlabel('N_{GG}','Interpreter','tex'); ylabel('N_{GR}','Interpreter','tex'); zlabel('N_{RR}','Interpreter','tex');
                        title(sprintf('\\gamma = %.4f \\pm %.4f\n\\beta = %.4f \\pm %.4f\nAdj. R^2 = %.4f',gamma,gamma_ci,beta,beta_ci,fitGamma.Rsquared.Adjusted),'Interpreter','tex');
                    case h.FitGammaFromPhotonCountsBetaFixed
                        %%% only fit gamma by linear regression
                        %%% NRR/beta-NGR = gamma*NGG
                        
                        % read out beta
                        beta = BurstData{file}.Corrections.Beta_GR;
                        lm = fitlm(NGG,NRR./beta-NGR,'Intercept',false,'RobustOpts','on');
                        figure('Color',[1,1,1]);
                        gamma = table2array(lm.Coefficients('x1',1));
                        gamma_ci = table2array(lm.Coefficients('x1',2));
                        plot(lm);
                        set(gca,'Color',[1,1,1],'Layer','Top','FontSize',16,'LineWidth',2,'Box','on');
                        title(sprintf('\\gamma = %.4f \\pm %.4f',gamma,gamma_ci),'Interpreter','tex');
                        xlabel('N_{GG}','Interpreter','tex');
                        ylabel('N_{RR}/\beta - N_{GR}','Interpreter','tex');                        
                        xlim([0,prctile(NRR./beta-NGR,99)]);
                        ylim([0,prctile(NGG,99)]);
                        legend('off');
                        
                        ydata = funS(beta,gamma,xdata);
                end
            else
                %%% Fit using E S relation (x is E)

                %fitGamma = fit(E_raw,1./S_raw,@(m,b,x) m*x+b,'StartPoint',[1,1],'Robust','LAR');
                fitGamma = fit(E_raw,S_raw,funS,'StartPoint',[1,1],'Robust','LAR');
                ydata = fitGamma(xdata);
                
                coeff = coeffvalues(fitGamma);
                beta = coeff(1); gamma = coeff(2);
            end
            BurstMeta.Plots.Fits.gamma.Visible = 'on';
            BurstMeta.Plots.Fits.gamma_manual.Visible = 'off';
            BurstMeta.Plots.Fits.gamma.XData = xdata;
            BurstMeta.Plots.Fits.gamma.YData = ydata;
            axis(h.Corrections.TwoCMFD.axes_gamma,'tight');
            xlim(h.Corrections.TwoCMFD.axes_gamma,[-0.1,1]);
            %ylim(h.Corrections.TwoCMFD.axes_gamma,[1,quantile(1./S_raw,0.99)]);

        case h.DetermineGammaManuallyButton
            axis(h.Corrections.TwoCMFD.axes_gamma,'tight');
            %%% Update Axis Labels
            xlabel(h.Corrections.TwoCMFD.axes_gamma,'FRET Efficiency','Color',UserValues.Look.Fore);
            ylabel(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry','Color',UserValues.Look.Fore);
            title(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry vs. FRET Efficiency for gamma = 1','Color',UserValues.Look.Fore);
            %%% Hide Fit
            BurstMeta.Plots.Fits.gamma.Visible = 'off';
            if verLessThan('MATLAB','9.5')
                [e, s] = ginput(2);
            else %2018b onwards
                [e, s] = my_ginput(2);
            end
            BurstMeta.Plots.Fits.gamma_manual.XData = e;
            BurstMeta.Plots.Fits.gamma_manual.YData = s;
            BurstMeta.Plots.Fits.gamma_manual.Visible = 'on';
            BurstMeta.Plots.Fits.gamma_manual.MarkerEdgeColor = UserValues.BurstBrowser.Display.ColorLine1;
            
            s = 1./s;
            m = (s(2)-s(1))./(e(2)-e(1));
            b = s(2) - m.*e(2);
            
            gamma = (b - 1)/(b + m - 1);
            beta = b+m-1;
        case h.FitGammaFromStoichiometryDistribution
            % read data from the selected species
            file_n = get_multiselection(h);
            if numel(file_n) < 2
                disp('Select more than one species.');
                return;
            end
            switch BurstData{1}.BAMethod
                case {1,2,5}
                    [~,NGR] = get_multiselection_data(h,'Number of Photons (DA)');
                    [~,NGG] = get_multiselection_data(h,'Number of Photons (DD)');
                    [~,NRR] = get_multiselection_data(h,'Number of Photons (AA)');
                case {3,4}
                    [~,NGR] = get_multiselection_data(h,'Number of Photons (GR)');
                    [~,NGG] = get_multiselection_data(h,'Number of Photons (GG)');
                    [~,NRR] = get_multiselection_data(h,'Number of Photons (RR)');                    
            end
            [~,dur] = get_multiselection_data(h,'Duration [ms]');
            % correct photon counts
            for i = 1:numel(file_n)
                %%% Read out background counts
                if ~(BurstData{file_n(i)}.BAMethod == 5) %%% MFD
                    Background_GR = BurstData{file_n(i)}.Background.Background_GRpar + BurstData{file_n(i)}.Background.Background_GRperp;
                    Background_GG = BurstData{file_n(i)}.Background.Background_GGpar + BurstData{file_n(i)}.Background.Background_GGperp;
                    Background_RR = BurstData{file_n(i)}.Background.Background_RRpar + BurstData{file_n(i)}.Background.Background_RRperp;
                elseif BurstData{file_n(i)}.BAMethod == 5
                    Background_GR = BurstData{file_n(i)}.Background.Background_GRpar;
                    Background_GG = BurstData{file_n(i)}.Background.Background_GGpar;
                    Background_RR = BurstData{file_n(i)}.Background.Background_RRpar;
                end
                % correct photon counts
                NGR{i} = NGR{i} - Background_GR.*dur{i};
                NGG{i} = NGG{i} - Background_GG.*dur{i};
                NRR{i} = NRR{i} - Background_RR.*dur{i};
                NGR{i} = NGR{i} - BurstData{file_n(i)}.Corrections.DirectExcitation_GR.*NRR{i} - BurstData{file_n(i)}.Corrections.CrossTalk_GR.*NGG{i};
            end
            % Calculate the Kullback-Leibler divergence between the S
            % distributions of the two datasets.
            [fitGamma,KBL_min,~,~,~,~,hessian] = fmincon(@(x) KBL(x,1,[NGG{1},NGR{1},NRR{1}],[NGG{2},NGR{2},NRR{2}]),1,[],[],[],[],0.01,10);
            % estimate 95% confidence intervals from the hessian
            %ci = sqrt(1./hessian)*1.96;            
            % calculate the KBL around the minimum
            range = [max(0.01,fitGamma-0.1),min(10,fitGamma+0.1)];
            g = range(1):0.0005:range(2); k = zeros(numel(g),1);
            for i = 1:numel(g);
                % set beta to 1 as we are not interested in it here
                k(i) = KBL(g(i),1,[NGG{1},NGR{1},NRR{1}],[NGG{2},NGR{2},NRR{2}]);
            end
            k = smooth(k,10);
            % find the minimum of k
            [min_k,idx] = min(k);
            fitGamma = g(idx);
            % plot the result
            figure('Color',[1,1,1]); hold on;
            %patch([fitGamma-ci,fitGamma+ci,fitGamma+ci,fitGamma-ci],[0,0,max(k),max(k)],[0.5,0.5,0.5],'FaceAlpha',0.25);
            plot(g,k,'LineWidth',2);
            plot([fitGamma,fitGamma],[0,max(k)],'LineWidth',2);
            xlabel('\gamma factor');
            ylabel('Kullback-Leibler divergence');
            ylim([min_k-(max(k)-min_k)/10,max(k)]);
            xlim(range);
            title(sprintf('\\gamma = %.4f',fitGamma));
            %title('Kullback-Leibler divergence of the stoichiometry distributions vs. \gamma-factor');
            set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',20,'Layer','top');
            gamma = fitGamma;
            beta = UserValues.BurstBrowser.Corrections.Beta_GR; %unchanged
    end
    
    UserValues.BurstBrowser.Corrections.Gamma_GR = gamma;
    UserValues.BurstBrowser.Corrections.Beta_GR = beta;
            
    if ~h.MultiselectOnCheckbox.UserData
        BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
        BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
    else %%% Update for all files contributing
        sel_file = BurstMeta.SelectedFile;
        Files = get_multiselection(h);
        for i = 1:numel(Files)
            BurstMeta.SelectedFile = Files(i);
            BurstData{Files(i)}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
            BurstData{Files(i)}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
            ApplyCorrections([],[],h,0);
        end
        BurstMeta.SelectedFile = sel_file;
    end
end
if obj == h.DetermineGammaLifetimeTwoColorButton
    % use the user selected species
    if ~h.MultiselectOnCheckbox.UserData
        Valid = UpdateCuts();
        switch BurstData{file}.BAMethod
            case {1,2,5}
                indTauGG = (strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'));
            case {3,4}
                indTauGG = (strcmp(BurstData{file}.NameArray,'Lifetime GG [ns]'));
        end
        tauGG = BurstData{file}.DataArray(Valid,indTauGG);
        
        %%% Calculate "raw" E and S with gamma = 1, but still apply direct
        %%% excitation,crosstalk, and background corrections!
        NGR = BurstData{file}.DataArray(Valid,indNGR) - Background_GR.*BurstData{file}.DataArray(Valid,indDur);
        NGG = BurstData{file}.DataArray(Valid,indNGG) - Background_GG.*BurstData{file}.DataArray(Valid,indDur);
        NRR = BurstData{file}.DataArray(Valid,indNRR) - Background_RR.*BurstData{file}.DataArray(Valid,indDur);
        NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
    else
        switch BurstData{file}.BAMethod
            case {1,2,5} 
                NGR = get_multiselection_data(h,'Number of Photons (DA)');
                NGG = get_multiselection_data(h,'Number of Photons (DD)');
                NRR = get_multiselection_data(h,'Number of Photons (AA)');
            case {3,4}
                NGR = get_multiselection_data(h,'Number of Photons (GR)');
                NGG = get_multiselection_data(h,'Number of Photons (GG)');
                NRR = get_multiselection_data(h,'Number of Photons (RR)');
        end
        dur = get_multiselection_data(h,'Duration [ms]');
        switch BurstData{file}.BAMethod
            case {1,2,5}
                tauGG = get_multiselection_data(h,'Lifetime D [ns]');
            case {3,4}
                tauGG = get_multiselection_data(h,'Lifetime GG [ns]');
        end
        NGR = NGR - Background_GR.*dur;
        NGG = NGG - Background_GG.*dur;
        NRR = NRR - Background_RR.*dur;
        NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
    end
    %%% Calculate static FRET line in presence of linker fluctuations
    [FRETline, statFRETfun,tau] = conversion_tau(BurstData{file}.Corrections.DonorLifetime,...
        BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength);
    %%% minimize deviation from static FRET line as a function of gamma
    valid = (tauGG < BurstData{file}.Corrections.DonorLifetime) & (tauGG > 0.01) & ~isnan(tauGG) & ~isnan(statFRETfun(tauGG));
    gamma_fit = fit([NGR(valid),NGG(valid)],statFRETfun(tauGG(valid)), @(gamma,x,y) (x./(gamma.*y+x) ),'StartPoint',BurstData{file}.Corrections.Gamma_GR,'Robust','bisquare');
    gamma_fit = coeffvalues(gamma_fit);
    E =  NGR./(gamma_fit.*NGG+NGR);
    %%% plot E versus tau with static FRET line
    [H,xbins,ybins] = calc2dhist(tauGG,E,[51 51],[0 min([max(tauGG) BurstData{file}.Corrections.DonorLifetime+1.5])],[-0.1 1.1]);
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
    ylim(h.Corrections.TwoCMFD.axes_gamma_lifetime,[-0.1 1.1]);
    %%% Update UserValues
    UserValues.BurstBrowser.Corrections.Gamma_GR =gamma_fit;
    if ~h.MultiselectOnCheckbox.UserData
        BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
    else %%% Update for all files contributing
        Files = get_multiselection(h);
        for i = 1:numel(Files)
            BurstData{Files(i)}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
        end
    end
end
if any(BurstData{file}.BAMethod == [3,4])
    %% 3cMFD corrections
    %%% Read out parameter positions
    indS = find(strcmp(BurstData{file}.NameArray,'Stoichiometry GR (raw)'));
    indSBG = find(strcmp(BurstData{file}.NameArray,'Stoichiometry BG (raw)'));
    indSBR = find(strcmp(BurstData{file}.NameArray,'Stoichiometry BR (raw)'));
    %%% Read out photon counts
    indNBB = find(strcmp(BurstData{file}.NameArray,'Number of Photons (BB)'));
    indNBG = find(strcmp(BurstData{file}.NameArray,'Number of Photons (BG)'));
    indNBR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (BR)'));
    %%% Read out corrections
    Background_BB = BurstData{file}.Background.Background_BBpar + BurstData{file}.Background.Background_BBperp;
    Background_BG = BurstData{file}.Background.Background_BGpar + BurstData{file}.Background.Background_BGperp;
    Background_BR = BurstData{file}.Background.Background_BRpar + BurstData{file}.Background.Background_BRperp;
    
    if ~h.MultiselectOnCheckbox.UserData
        indTauBB = (strcmp(BurstData{file}.NameArray,'Lifetime BB [ns]'));        
        %%% use selected species
        Valid = UpdateCuts();
        data_for_corrections = BurstData{file}.DataArray;
        tauBB = data_for_corrections(Valid,indTauBB);
        %%% Calculate "raw" E1A and with gamma_br = 1, but still apply direct
        %%% excitation,crosstalk, and background corrections!
        NBB = data_for_corrections(Valid,indNBB) - Background_BB.*data_for_corrections(Valid,indDur);
        NBG = data_for_corrections(Valid,indNBG) - Background_BG.*data_for_corrections(Valid,indDur);
        NBR = data_for_corrections(Valid,indNBR) - Background_BR.*data_for_corrections(Valid,indDur);
        NGG = data_for_corrections(Valid,indNGG) - Background_GG.*data_for_corrections(Valid,indDur);
        NGR = data_for_corrections(Valid,indNGR) - Background_GR.*data_for_corrections(Valid,indDur);
        NRR = data_for_corrections(Valid,indNRR) - Background_RR.*data_for_corrections(Valid,indDur);        
    else
        NBB = get_multiselection_data(h,'Number of Photons (BB)');
        NBG = get_multiselection_data(h,'Number of Photons (BG)');
        NBR = get_multiselection_data(h,'Number of Photons (BR)');
        NGR = get_multiselection_data(h,'Number of Photons (GR)');
        NGG = get_multiselection_data(h,'Number of Photons (GG)');
        NRR = get_multiselection_data(h,'Number of Photons (RR)');
        dur = get_multiselection_data(h,'Duration [ms]');
        tauBB = get_multiselection_data(h,'Lifetime BB [ns]');

        NBB = NBB - Background_BB.*dur;
        NBG = NBG - Background_BG.*dur;
        NBR = NBR - Background_BR.*dur;
        NGR = NGR - Background_GR.*dur;
        NGG = NGG - Background_GG.*dur;
        NRR = NRR - Background_RR.*dur;
        
        Files = get_multiselection(h);
        Files = unique(Files);
        data_for_corrections = cell(numel(Files),1);
        for i = 1:numel(Files)
            data_for_corrections{i} = BurstData{Files(i)}.DataArray;
        end
        data_for_corrections = vertcat(data_for_corrections{:});
        %%% (Note for the future: We are assuming here that all files have the
        %%% same order of parameters in NameArray...)
    end
    
    if obj == h.DetermineCorrectionsButton
        %% Blue dye only
        Smin = UserValues.BurstBrowser.Settings.S_Donly_Min;
        Smax = UserValues.BurstBrowser.Settings.S_Donly_Max;
        S_threshold = (data_for_corrections(:,indSBG) > Smin) & (data_for_corrections(:,indSBG) < Smax) &...
            (data_for_corrections(:,indSBR) > Smin) & (data_for_corrections(:,indSBR) < Smax) ;
        x_axis = linspace(-0.05,0.3,50);
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBG = data_for_corrections(S_threshold,indNBG) - Background_BG.*data_for_corrections(S_threshold,indDur);
        NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
        %%% Crosstalk B->G
        EBG_raw = NBG./(NBG+NBB);
        histEBG_blueonly = histc(EBG_raw,x_axis);
        x_axis = x_axis(1:end-1);
        histEBG_blueonly(end-1) = histEBG_blueonly(end-1)+histEBG_blueonly(end);
        histEBG_blueonly(end) = [];
        BurstMeta.Plots.histEBG_blueonly.XData = x_axis;
        BurstMeta.Plots.histEBG_blueonly.YData = histEBG_blueonly;
        axis(h.Corrections.ThreeCMFD.axes_crosstalk_BG,'tight');
        %fit single gaussian
        [mean_ct, GaussFit] = GaussianFit(x_axis',histEBG_blueonly);
        BurstMeta.Plots.Fits.histEBG_blueonly(1).XData = x_axis;
        BurstMeta.Plots.Fits.histEBG_blueonly(1).YData = GaussFit;
        ct = mean_ct/(1-mean_ct);
        if ~isnan(ct) && (ct > 0)
            UserValues.BurstBrowser.Corrections.CrossTalk_BG = ct;
        end
        if ~h.MultiselectOnCheckbox.UserData
            BurstData{file}.Corrections.CrossTalk_BG = UserValues.BurstBrowser.Corrections.CrossTalk_BG;
        else %%% Update for all files contributing
            Files = get_multiselection(h);
            for i = 1:numel(Files)
                BurstData{Files(i)}.Corrections.CrossTalk_BG = UserValues.BurstBrowser.Corrections.CrossTalk_BG;
            end
        end
        
        %%% Crosstalk B->R
        x_axis = linspace(-0.05,0.25,50);
        EBR_raw = NBR./(NBR+NBB);
        histEBR_blueonly = histc(EBR_raw,x_axis);
        x_axis = x_axis(1:end-1);
        histEBR_blueonly(end-1) = histEBR_blueonly(end-1)+histEBR_blueonly(end);
        histEBR_blueonly(end) = [];
        BurstMeta.Plots.histEBR_blueonly.XData = x_axis;
        BurstMeta.Plots.histEBR_blueonly.YData = histEBR_blueonly;
        axis(h.Corrections.ThreeCMFD.axes_crosstalk_BR,'tight');
        %fit single gaussian
        [mean_ct, GaussFit] = GaussianFit(x_axis',histEBR_blueonly);
        BurstMeta.Plots.Fits.histEBR_blueonly(1).XData = x_axis;
        BurstMeta.Plots.Fits.histEBR_blueonly(1).YData = GaussFit;
        ct = mean_ct/(1-mean_ct);
        if ~isnan(ct) && (ct > 0)
            UserValues.BurstBrowser.Corrections.CrossTalk_BR = ct;
        end
        if ~h.MultiselectOnCheckbox.UserData
            BurstData{file}.Corrections.CrossTalk_BR = UserValues.BurstBrowser.Corrections.CrossTalk_BR;
        else %%% Update for all files contributing
            Files = get_multiselection(h);
            for i = 1:numel(Files)
                BurstData{Files(i)}.Corrections.CrossTalk_BR = UserValues.BurstBrowser.Corrections.CrossTalk_BR;
            end
        end
        %% Green dye only
        S_threshold =  (data_for_corrections(:,indSBG) < UserValues.BurstBrowser.Settings.S_Aonly_Max) & (data_for_corrections(:,indSBG) > UserValues.BurstBrowser.Settings.S_Aonly_Min) &...
            (data_for_corrections(:,indS) > UserValues.BurstBrowser.Settings.S_Donly_Min) & (data_for_corrections(:,indS) < UserValues.BurstBrowser.Settings.S_Donly_Max) ;
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBG = data_for_corrections(S_threshold,indNBG) - Background_BG.*data_for_corrections(S_threshold,indDur);
        NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
        
        x_axis = linspace(UserValues.BurstBrowser.Settings.S_Aonly_Min,UserValues.BurstBrowser.Settings.S_Aonly_Max,25);
        SBG_raw = (NBB+NBG)./(NBB+NBG+NGG);
        histSBG_greenonly = histc(SBG_raw,x_axis);
        x_axis = x_axis(1:end-1);
        histSBG_greenonly(end-1) = histSBG_greenonly(end-1)+histSBG_greenonly(end);
        histSBG_greenonly(end) = [];
        BurstMeta.Plots.histSBG_greenonly.XData = x_axis;
        BurstMeta.Plots.histSBG_greenonly.YData = histSBG_greenonly;
        axis(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,'tight');
        %fit single gaussian
        [mean_de, GaussFit] = GaussianFit(x_axis',histSBG_greenonly);
        BurstMeta.Plots.Fits.histSBG_greenonly(1).XData = x_axis;
        BurstMeta.Plots.Fits.histSBG_greenonly(1).YData = GaussFit;
        de =  mean_de/(1-mean_de);
        if ~isnan(de) && (de > 0)
            UserValues.BurstBrowser.Corrections.DirectExcitation_BG = de;
        end
        if ~h.MultiselectOnCheckbox.UserData
            BurstData{file}.Corrections.DirectExcitation_BG = UserValues.BurstBrowser.Corrections.DirectExcitation_BG;
        else %%% Update for all files contributing
            Files = get_multiselection(h);
            for i = 1:numel(Files)
                BurstData{Files(i)}.Corrections.DirectExcitation_BG = UserValues.BurstBrowser.Corrections.DirectExcitation_BG;
            end
        end
        %% Red dye only
        S_threshold = (data_for_corrections(:,indS) < UserValues.BurstBrowser.Settings.S_Aonly_Max) & (data_for_corrections(:,indS) > UserValues.BurstBrowser.Settings.S_Aonly_Min) &...
            (data_for_corrections(:,indSBR) < UserValues.BurstBrowser.Settings.S_Aonly_Max) & (data_for_corrections(:,indSBR) > UserValues.BurstBrowser.Settings.S_Aonly_Min);
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
        NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
        
        x_axis = linspace(UserValues.BurstBrowser.Settings.S_Aonly_Min,UserValues.BurstBrowser.Settings.S_Aonly_Max,25);
        SBR_raw = (NBB+NBR)./(NBB+NBR+NRR);
        histSBR_redonly = histc(SBR_raw,x_axis);
        x_axis = x_axis(1:end-1);
        histSBR_redonly(end-1) = histSBR_redonly(end-1)+histSBR_redonly(end);
        histSBR_redonly(end) = [];
        BurstMeta.Plots.histSBR_redonly.XData = x_axis;
        BurstMeta.Plots.histSBR_redonly.YData = histSBR_redonly;
        axis(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,'tight');
        %fit single gaussian
        [mean_de, GaussFit] = GaussianFit(x_axis',histSBR_redonly);
        BurstMeta.Plots.Fits.histSBR_redonly(1).XData = x_axis;
        BurstMeta.Plots.Fits.histSBR_redonly(1).YData = GaussFit;
        de = mean_de/(1-mean_de);
        if ~isnan(de) && (de > 0)
            UserValues.BurstBrowser.Corrections.DirectExcitation_BR = de;
        end
        if ~h.MultiselectOnCheckbox.UserData
            BurstData{file}.Corrections.DirectExcitation_BR = UserValues.BurstBrowser.Corrections.DirectExcitation_BR;
        else %%% Update for all files contributing
            Files = get_multiselection(h);
            for i = 1:numel(Files)
                BurstData{Files(i)}.Corrections.DirectExcitation_BR = UserValues.BurstBrowser.Corrections.DirectExcitation_BR;
            end
        end
    end
    if obj == h.FitGammaButton
        %m = msgbox('Using double labeled populations for three-color.');
        %m = msgbox('Not implemented for 3 color. Use 2 color standards to determine 3 color gamma factors instead.');
        %pause(1);
        %delete(m);
               
        if 0
            %%% Gamma factor determination based on triple labeled population
            %%% using currently selected bursts
            S_threshold = UpdateCuts();
            %%% Read out corrections
            ct_gr = BurstData{file}.Corrections.CrossTalk_GR;
            de_gr = BurstData{file}.Corrections.DirectExcitation_GR;
            ct_bg = BurstData{file}.Corrections.CrossTalk_BG;
            de_bg = BurstData{file}.Corrections.DirectExcitation_BG;
            ct_br = BurstData{file}.Corrections.CrossTalk_BR;
            de_br = BurstData{file}.Corrections.DirectExcitation_BR;
            gamma_gr = BurstData{file}.Corrections.Gamma_GR;
            %%% Calculate correct EGR
            %%% excitation,crosstalk, and background corrections!
            NGR = BurstData{file}.DataArray(S_threshold,indNGR) - Background_GR.*BurstData{file}.DataArray(S_threshold,indDur);
            NGG = BurstData{file}.DataArray(S_threshold,indNGG) - Background_GG.*BurstData{file}.DataArray(S_threshold,indDur);
            NRR = BurstData{file}.DataArray(S_threshold,indNRR) - Background_RR.*BurstData{file}.DataArray(S_threshold,indDur);
            NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
            EGR = NGR./(NGR+gamma_gr*NGG);
            %%% correct three-color photon counts for background
            NBB = BurstData{file}.DataArray(S_threshold,indNBB) - Background_BB.*BurstData{file}.DataArray(S_threshold,indDur);
            NBG = BurstData{file}.DataArray(S_threshold,indNBG) - Background_BG.*BurstData{file}.DataArray(S_threshold,indDur);
            NBR = BurstData{file}.DataArray(S_threshold,indNBR) - Background_BR.*BurstData{file}.DataArray(S_threshold,indDur);
            
            %%% Apply CrossTalk and DirectExcitation Corrections
            NBR = NBR - de_br.*NRR - ct_br.*NBB - ct_gr.*(NBG-ct_bg.*NBB) - de_bg*(EGR./(1-EGR)).*NGG;
            NBG = NBG - de_bg.*NGG - ct_bg.*NBB;
            %%% calculate corrected photon counts by adding FRET photons back
            NBGcor = NBG./(1-EGR);
            NBRcor = NBR-(EGR./(1-EGR)).*gamma_gr.*NBG;
            %%% Calculate FRET efficiencies for gamma_br = 1 and stoichiometries
            gamma_br = 1; gamma_bg = 1;
            EBG = NBGcor./(gamma_bg.*NBB+NBGcor);
            EBR = NBRcor./(gamma_br.*NBB+NBRcor);
            SBG = (gamma_bg.*NBB+NBG+NBR)./(gamma_bg.*NBB+NBG+NBR+NGG+(NGR./gamma_gr));
            SBR = (gamma_br.*NBB+NBR+gamma_gr.*NBG)./(gamma_br.*NBB+NBR+gamma_gr.*NBG+NRR);

            fitGamma = fit(EBG,1./SBG,@(m,b,x) m*x+b,'StartPoint',[1,1],'Robust','LAR');
            coeff = coeffvalues(fitGamma); m = coeff(1); b = coeff(2);
            gamma_bg = (b - 1)/(b + m - 1);
            beta_bg = b+m-1;
            
            fitGamma = fit(EBR,1./SBR,@(m,b,x) m*x+b,'StartPoint',[1,1],'Robust','LAR');
            coeff = coeffvalues(fitGamma); m = coeff(1); b = coeff(2);
            gamma_br = (b - 1)/(b + m - 1);
            beta_br = b+m-1;
        end
        if 1
        %% Gamma factor determination based on double-labeled species
        %%% BG labeled
        S_threshold = ( (data_for_corrections(:,indS) > 0.9) &...
            (data_for_corrections(:,indSBG) > 0.3) & (data_for_corrections(:,indSBG) < 0.7) &...
            (data_for_corrections(:,indSBR) > 0.9) );
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBG = data_for_corrections(S_threshold,indNBG) - Background_BG.*data_for_corrections(S_threshold,indDur);
        NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
        NBG = NBG - BurstData{file}.Corrections.DirectExcitation_BG.*NGG - BurstData{file}.Corrections.CrossTalk_BG.*NBB;
        EBG_raw = NBG./(NBG+NBB);
        SBG_raw = (NBB+NBG)./(NBB+NBG+NGG);
        %%% Calculate 2D-Hist and Fit
        [H,xbins,ybins] = calc2dhist(EBG_raw,SBG_raw,[51 51],[-0.1 1], [min(SBG_raw) max(SBG_raw)]);
        BurstMeta.Plots.gamma_BG_fit(1).XData= xbins;
        BurstMeta.Plots.gamma_BG_fit(1).YData= ybins;
        BurstMeta.Plots.gamma_BG_fit(1).CData= H;
        BurstMeta.Plots.gamma_BG_fit(1).AlphaData= (H>0);
        BurstMeta.Plots.gamma_BG_fit(2).XData= xbins;
        BurstMeta.Plots.gamma_BG_fit(2).YData= ybins;
        BurstMeta.Plots.gamma_BG_fit(2).ZData= H/max(max(H));
        BurstMeta.Plots.gamma_BG_fit(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
        %%% Update/Reset Axis Labels
        xlabel(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'FRET Efficiency BG','Color',UserValues.Look.Fore);
        ylabel(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'Stoichiometry BG','Color',UserValues.Look.Fore);
        title(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'Stoichiometry BG vs. FRET Efficiency BG for gammaBG = 1','Color',UserValues.Look.Fore);
        %%% store for later use
        BurstMeta.Data.EBG_raw = EBG_raw;
        BurstMeta.Data.SBG_raw = SBG_raw;
        %%% Fit using E S relation (x is E)
        funS = @(b,g,x) (1+g*b+(1-g)*b*x).^(-1);
        fitGamma = fit(EBG_raw,SBG_raw,funS,'StartPoint',[1,1],'Robust','LAR');
        %%% Fit linearly
        BurstMeta.Plots.Fits.gamma_BG.Visible = 'on';
        BurstMeta.Plots.Fits.gamma_BG_manual.Visible = 'off';
        BurstMeta.Plots.Fits.gamma_BG.XData = linspace(-0.1,1,1000);
        BurstMeta.Plots.Fits.gamma_BG.YData = fitGamma(linspace(-0.1,1,1000));
        axis(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'tight');
        %%% Determine Gamma and Beta
        coeff = coeffvalues(fitGamma); b = coeff(1); g = coeff(2);
        UserValues.BurstBrowser.Corrections.Gamma_BG = g;
        BurstData{file}.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
        UserValues.BurstBrowser.Corrections.Beta_BG = b;
        BurstData{file}.Corrections.Beta_BG = UserValues.BurstBrowser.Corrections.Beta_BG;
        
        S_threshold = ( (data_for_corrections(:,indS) < 0.2) &...
            (data_for_corrections(:,indSBG) > 0.9) &...
            (data_for_corrections(:,indSBR) > 0.2) & (data_for_corrections(:,indSBR) < 0.8) );
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
        NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
        NBR = NBR - BurstData{file}.Corrections.DirectExcitation_BR.*NRR - BurstData{file}.Corrections.CrossTalk_BR.*NBB;
        EBR_raw = NBR./(NBR+NBB);
        SBR_raw = (NBB+NBR)./(NBB+NBR+NRR);
        %%% Calculate 2D-Hist and Fit
        [H,xbins,ybins] = calc2dhist(EBR_raw,SBR_raw,[51 51],[-0.1 1], [min(SBR_raw) max(SBR_raw)]);
        BurstMeta.Plots.gamma_BR_fit(1).XData= xbins;
        BurstMeta.Plots.gamma_BR_fit(1).YData= ybins;
        BurstMeta.Plots.gamma_BR_fit(1).CData= H;
        BurstMeta.Plots.gamma_BR_fit(1).AlphaData= (H>0);
        BurstMeta.Plots.gamma_BR_fit(2).XData= xbins;
        BurstMeta.Plots.gamma_BR_fit(2).YData= ybins;
        BurstMeta.Plots.gamma_BR_fit(2).ZData= H/max(max(H));
        BurstMeta.Plots.gamma_BR_fit(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
        %%% Update/Reset Axis Labels
        xlabel(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'FRET Efficiency BR','Color',UserValues.Look.Fore);
        ylabel(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'Stoichiometry BR','Color',UserValues.Look.Fore);
        title(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'Stoichiometry BR vs. FRET Efficiency BR for gammaBR = 1','Color',UserValues.Look.Fore);
        %%% store for later use
        BurstMeta.Data.EBR_raw = EBR_raw;
        BurstMeta.Data.SBR_raw = SBR_raw;
        %%% Fit linearly
        funS = @(b,g,x) (1+g*b+(1-g)*b*x).^(-1);
        fitGamma = fit(EBR_raw,SBR_raw,funS,'StartPoint',[1,1],'Robust','LAR');
        BurstMeta.Plots.Fits.gamma_BR.Visible = 'on';
        BurstMeta.Plots.Fits.gamma_BR_manual.Visible = 'off';
        BurstMeta.Plots.Fits.gamma_BR.XData = linspace(-0.1,1,1000);
        BurstMeta.Plots.Fits.gamma_BR.YData = fitGamma(linspace(-0.1,1,1000));
        axis(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'tight');
        %%% Determine Gamma and Beta
        coeff = coeffvalues(fitGamma); b = coeff(1); g = coeff(2);
        UserValues.BurstBrowser.Corrections.Gamma_BR = g;
        BurstData{file}.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
        UserValues.BurstBrowser.Corrections.Beta_BR = b;
        BurstData{file}.Corrections.Beta_BR = UserValues.BurstBrowser.Corrections.Beta_BR;
        end
    end
    if obj == h.DetermineGammaLifetimeThreeColorButton
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
        valid = (tauBB < BurstData{file}.Corrections.DonorLifetimeBlue) & (tauBB > 0.01) & ~isnan(tauBB);
        valid = find(valid);
        valid = valid(~isnan(statFRETfun( tauBB(valid))));
        %%% minimize deviation from static FRET line as a function of gamma_br!
        dev = @(gamma) sum( ( ( (gamma_gr.*NBG(valid)+NBR(valid))./(gamma.*NBB(valid) + gamma_gr.*NBG(valid) + NBR(valid)) ) - statFRETfun( tauBB(valid) ) ).^2 );
        gamma_fit = fmincon(dev,BurstData{file}.Corrections.Gamma_BR,[],[],[],[],0,10);
        %E_fun = @(gamma,NBB,NBG,NBR) (gamma_gr.*NBG+NBR)./(gamma.*NBB + gamma_gr.*NBG + NBR);
        %gamma_fit = fit([NBB(valid),NBG(valid),NBR(valid)],statFRETfun(tauBB(valid)),E_fun,'StartPoint',BurstData{file}.Corrections.Gamma_BR,'Robust','bisquare');
        %gamma_fit = coeffvalues(gamma_fit);
        E1A =  (gamma_gr.*NBG+NBR)./(gamma_fit.*NBB + gamma_gr.*NBG + NBR);
        %%% plot E versus tau with static FRET line
        [H,xbins,ybins] = calc2dhist(tauBB,E1A,[51 51],[0 min([max(tauBB) BurstData{file}.Corrections.DonorLifetimeBlue+1.5])],[-0.1 1.1]);
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
        
        if ~h.MultiselectOnCheckbox.UserData
            BurstData{file}.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
            BurstData{file}.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
        else %%% Update for all files contributing
            Files = get_multiselection(h);
            for i = 1:numel(Files)
                BurstData{Files(i)}.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
                BurstData{Files(i)}.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
            end
        end
    end
end
%%% Save and Update GUI
% Save UserValues
LSUserValues(1);
% Update Correction Table Data
UpdateCorrections([],[],h);
% Apply Corrections
ApplyCorrections(gcbo,[]);

% define the objective function as the kullback leibler divergence
function k = KBL(g,b,D1,D2)
% D1 and D2 are vectors of the photon counts NGG, NGR, NRR
% convert to beta and gamma corrected stoichiometries
S1 = (g*D1(:,1)+D1(:,2))./(g*D1(:,1)+D1(:,2)+b.*D1(:,3));
S2 = (g*D2(:,1)+D2(:,2))./(g*D2(:,1)+D2(:,2)+b.*D2(:,3));
% approximate distributions by kernel density estimation
% the default bandwidth is optimal for estimating normally distributed
% data.
P = ksdensity(S1,linspace(0,1,100));
P = P./sum(P);
Q = ksdensity(S2,linspace(0,1,100));
Q = Q./sum(Q);
% calculate KBL
k_PQ = P.*log(P./Q);
k_PQ(~isfinite(k_PQ)) = 0;
k_PQ = sum(k_PQ);
k_QP = Q.*log(Q./P);
k_QP(~isfinite(k_QP)) = 0;
k_QP = sum(k_QP);
% KBL is not symmetric, so take the average of KBL(P|Q) and KBL(Q|P)
k = (1/2).*(k_PQ+k_QP);