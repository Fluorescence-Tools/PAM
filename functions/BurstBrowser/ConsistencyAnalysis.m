function ConsistencyAnalysis(~,~)

global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;
if isempty(BurstData)
    msgbox('No data selected', 'Error','error');
    return
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating...');
switch UserValues.BurstBrowser.Settings.BVA_Nstates
            case 2
                rate_matrix = 1000*cell2mat(h.KineticRates_table2.Data); %%% rates in Hz
                R_states = [str2double(h.Rstate1_edit.String),str2double(h.Rstate2_edit.String)];
                sigmaR_states = [str2double(h.Rsigma1_edit.String),str2double(h.Rsigma2_edit.String)];
                
                rate_matrix_static = [ 0,    0.1;
                                       0.1,    0]; %%% rates in Hz
                R_states_static = [str2double(h.Rstate1st_edit.String),str2double(h.Rstate2st_edit.String)];
                sigmaR_states_static = [str2double(h.Rsigma1st_edit.String),str2double(h.Rsigma2st_edit.String)];
            case 3
                rate_matrix = 1000*cell2mat(h.KineticRates_table3.Data); %%% rates in Hz
                R_states = [str2double(h.Rstate1_edit.String),str2double(h.Rstate2_edit.String),str2double(h.Rstate3_edit.String)];
                sigmaR_states = [str2double(h.Rsigma1_edit.String),str2double(h.Rsigma2_edit.String),str2double(h.Rsigma3_edit.String)];
                
                rate_matrix_static = [ 0,    0.1, 0.1;
                                       0.1,    0, 0.1;
                                       0.1, 0.1,    0]; %%% rates in Hz
                R_states_static = [str2double(h.Rsigma1st_edit.String),str2double(h.Rsigma2st_edit.String),str2double(h.Rsigma3st_edit.String)];
                sigmaR_states_static = [str2double(h.Rsigma1st_edit.String),str2double(h.Rsigma2st_edit.String),str2double(h.Rsigma3st_edit.String)];
end
rate_matrix(isnan(rate_matrix)) = 0;
switch UserValues.BurstBrowser.Settings.Dynamic_Analysis_Method % BVA
    case 1
        %%% Load associated .bps file, containing Macrotime, Microtime and Channel
        if isempty(BurstTCSPCData{file})
            Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photons...');
            Load_Photons();
        end
        switch BurstData{file}.BAMethod
            case {1,2,5}
            E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio'));
            case 3
                switch UserValues.BurstBrowser.Settings.FRETpair_BVA
                    case 1
                        E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio BG (raw)'));
                    case 2
                        E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio BR (raw)'));
                    case 3
                        E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio BG (raw)'))+ ...
                            BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio BR (raw)'));
                    case 4
                        E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio GR (raw)'));
                end
        end
        photons = BurstTCSPCData{file};
        % Remove ALEX photons &  calculate STD per Burst
        n = UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA;
        switch BurstData{file}.BAMethod
            case {1,2}
                % channel : 1,2 Donor Par Perp
                %           3,4 FRET Par Perp
                %           5,6 ALEX Par Parp
                channel = cellfun(@(x) x(x < 5),photons.Channel,'UniformOutput',false);
                sPerBurst=zeros(size(channel));
                for i = 1:numel(channel)
                    M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
                    sPerBurst(i,1) = std(sum(M==3|M==4)/n); % observed standard deviation of E for each burst
                end

            case 3
                % channel : 1,2   Donor blue Par Perp
                %           3,4   FRET blue/green Par Perp
                %           5,6   FRET blue/red Par Perp
                %           7,8   Donor/ALEX green Par Perp
                %           9,10  FRET green/red Par Perp
                %           11,12 ALEX red Par Perp
                switch UserValues.BurstBrowser.Settings.FRETpair_BVA % observed standard deviation of E for each burst
                    case 1
                        channel = cellfun(@(x) x(x<5),photons.Channel,'UniformOutput',false);
                        sPerBurst=zeros(size(channel));
                        for i = 1:numel(channel)
                            M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
                            sPerBurst(i,1) = std(sum(M==3|M==4)/n);
                        end
                    case 2
                        channel = cellfun(@(x) x(x>0 & x<3 | x>4 & x<7),photons.Channel,'UniformOutput',false);
                        sPerBurst=zeros(size(channel));
                        for i = 1:numel(channel)
                            M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
                            sPerBurst(i,1) = std(sum(M==5|M==6)/n);
                        end
                    case 3
                        channel = cellfun(@(x) x(x<7),photons.Channel,'UniformOutput',false);
                        sPerBurst=zeros(size(channel));
                        for i = 1:numel(channel)
                            M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
                            sPerBurst(i,1) = std(sum(M==3|M==4|M==5|M==6)/n);
                        end
                    case 4
                        channel = cellfun(@(x) x(x>6 & x<9 | x>8 & x<11),photons.Channel,'UniformOutput',false);
                        sPerBurst=zeros(size(channel));
                        for i = 1:numel(channel)
                            M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
                            sPerBurst(i,1) = std(sum(M==9|M==10)/n);
                        end
                end
            case 5
                % channel : 1 Donor
                %           2 FRET
                %           3 ALEX
                channel = cellfun(@(x) x(x < 3),photons.Channel,'UniformOutput',false);
                sPerBurst=zeros(size(channel));
                for i = 1:numel(channel)
                    M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % Create photon windows
                    sPerBurst(i,1) = std(sum(M==2)/n); % observed standard deviation of E for each burst
                end
        end
        Progress(0.25,h.Progress_Axes,h.Progress_Text,'Calculating...');
        sSelected = sPerBurst.*BurstData{file}.Selected;
        sSelected(sSelected == 0) = NaN;
        E = E.*BurstData{file}.Selected;
        E(E == 0) = NaN;
        %% STD per Bin
        BinEdges = linspace(0,1,UserValues.BurstBrowser.Settings.NumberOfBins_BVA+1);
        [N,~,bin] = histcounts(E,BinEdges);
        BinCenters = BinEdges(1:end-1)+0.025;
        sPerBin = zeros(numel(BinEdges)-1,1);
        sampling = UserValues.BurstBrowser.Settings.ConfidenceSampling_BVA;
        %PsdPerBin = zeros(numel(BinEdges)-1,sampling);
        for j = 1:numel(N) % 1 : number of bins
            burst_id = find(bin==j); % find indices of bursts in bin j
            if ~isempty(burst_id)
                BurstsPerBin = cell(size(burst_id'));
                for k = 1:numel(burst_id)
                    BurstsPerBin(k) = channel(burst_id(k)); % find all bursts in bin j
                end
                M = cellfun(@(x) reshape(x(1:fix(numel(x)/n)*n),n,[]),BurstsPerBin,'UniformOutput',false);
                MPerBin = cat(2,M{:});
                switch BurstData{file}.BAMethod
                    case {1,2}
                        EPerBin = sum(MPerBin==3|MPerBin==4)/n;
                    case 3
                        switch UserValues.BurstBrowser.Settings.FRETpair_BVA
                            case 1
                                EPerBin = sum(MPerBin==3|MPerBin==4)/n;
                            case 2
                                EPerBin = sum(MPerBin==5|MPerBin==6)/n;
                            case 3
                                EPerBin = sum(MPerBin==3|MPerBin==4|MPerBin==5|MPerBin==6)/n;
                            case 4
                                EPerBin = sum(MPerBin==9|MPerBin==10)/n;
                        end
                    case 5
                        EPerBin = sum(MPerBin==2)/n;
                end
                if numel(BurstsPerBin)>UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA
                    sPerBin(j,1) = std(EPerBin);
                end
%                 if sampling ~=0
%                     %% Monte Carlo Simulation P(sigma)
%                     idx = [0 cumsum(cellfun('size',M,2))];
%                     window_id = zeros(size(EPerBin));
%                     %alpha = UserValues.BurstBrowser.Settings.ConfidenceLevelAlpha_BVA/numel(BinCenters)/100;
%                     for l = 1:numel(M)
%                          window_id(idx(l)+1:idx(l+1)) = ones(1,size(M{l},2))*burst_id(l);
%                     end
%                     for m = 1:sampling
%                         EperBin_simu = binornd(n,E(window_id))/n;
%                         PsdPerBin(j,m) = std(EperBin_simu);
%                         Progress(((j-1)*sampling+m)/(numel(N)*sampling),h.Progress_Axes,h.Progress_Text,'Calculating Confidence Interval...');
%                     end
%                 end
            end
        end
        %% Simulate BVA plot based on PDA model
        Progress(0.5,h.Progress_Axes,h.Progress_Text,'Calculating...');
        [E_sim,sSelected_sim,sPerBin_sim] = kinetic_consistency_check('BVA',UserValues.BurstBrowser.Settings.BVA_Nstates,rate_matrix,R_states,sigmaR_states);
        figure('color',[1 1 1]);ax=gca;ax.FontSize=20;ax.LineWidth=2.0;ax.Color =[1 1 1];
        hold on;
        %X_expectedSD = linspace(0,1,1000);
        xlabel('Proximity Ratio, E*'); 
        ylabel('SD of E*, s');
        %% Generate plots
        sPerBin(sPerBin == 0) = NaN;
        sPerBin_sim(sPerBin_sim == 0) = NaN;
        % contour patches
        [H,x,y] = histcounts2(E,sSelected,UserValues.BurstBrowser.Display.NumberOfBinsX); 
        plot_ContourPatches(ax,H,x,y,UserValues.BurstBrowser.Display.ColorLine1)
        [H,x,y] = histcounts2(E_sim,sSelected_sim,UserValues.BurstBrowser.Display.NumberOfBinsX);
        plot_ContourPatches(ax,H,x,y,UserValues.BurstBrowser.Display.ColorLine2)
        if UserValues.BurstBrowser.Settings.BVA_ModelComparison == true
            Progress(0.7,h.Progress_Axes,h.Progress_Text,'Calculating...');
            [E_static,sSelected_static,sPerBin_static] = kinetic_consistency_check('BVA',UserValues.BurstBrowser.Settings.BVA_Nstates,...
                rate_matrix_static,R_states_static,sigmaR_states_static);
            Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
            [H,x,y] = histcounts2(E_static,sSelected_static,UserValues.BurstBrowser.Display.NumberOfBinsX);
            plot_ContourPatches(ax,H,x,y,UserValues.BurstBrowser.Display.ColorLine3)
            %patch(ax,[-0.1 1.1 1.1 -0.1],[0 0 max(sSelected) max(sSelected)],'w','FaceAlpha',0.3,'edgecolor','none','HandleVisibility','off');
            patch(ax,[-0.1 1.1 1.1 -0.1],[0 0 max(sSelected) max(sSelected)],'w','FaceAlpha',0.5,'edgecolor','none','HandleVisibility','off');
            %%% confidence intervals
%             alpha = UserValues.BurstBrowser.Settings.ConfidenceLevelAlpha_BVA/numel(BinCenters)/100;
%             confint = mean(PsdPerBin,2) + std(PsdPerBin,0,2)*norminv(1-alpha);
%             p2 = area(BinCenters,confint);
%             p2.FaceColor = [0.5 0.5 0.5];
%             p2.FaceAlpha = 0.3;
%             p2.LineStyle = 'none';
            %%% Plot STD per Bin
            sPerBin_static(sPerBin_static == 0) = NaN;
            %scatter(BinCenters,sPerBin,70,UserValues.BurstBrowser.Display.ColorLine3,'d','filled');
            plot(BinCenters',sPerBin,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine1,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',1,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(BinCenters',sPerBin_sim,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine2,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',1,'Color',UserValues.BurstBrowser.Display.ColorLine2);
            plot(BinCenters',sPerBin_static,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine3,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',1,'Color',UserValues.BurstBrowser.Display.ColorLine3);
            %% Calculate sum squared residuals
            w_res_dyn = (sPerBin-sPerBin_sim);
            w_res_dyn(isnan(w_res_dyn)) = 0;
            SSR_dyn_legend = ['Dynamic SSR =' ' ' sprintf('%1.0e',round(sum(w_res_dyn.^2),1,'significant'))];
            w_res_stat = (sPerBin-sPerBin_static);
            w_res_stat(isnan(w_res_stat)) = 0;
            SSR_stat_legend = ['Static SSR =' ' ' sprintf('%1.0e',round(sum(w_res_stat.^2),1,'significant'))];
            legend('Experimental Data',SSR_dyn_legend,SSR_stat_legend,'Location','northeast');
        else
        patch(ax,[-0.1 1.1 1.1 -0.1],[0 0 max(sSelected) max(sSelected)],'w','FaceAlpha',0.5,'edgecolor','none','HandleVisibility','off');
        plot(BinCenters',sPerBin,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine1,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',1,'Color',UserValues.BurstBrowser.Display.ColorLine1);
        plot(BinCenters',sPerBin_sim,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine2,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',1,'Color',UserValues.BurstBrowser.Display.ColorLine2);
        legend('Experimental Data','Simulation','Location','northeast');
        end
    case 2
        %%% Prepares a plot of FRET efficiency vs. donor fluorescence lifetime,
        %%% including bin-wise averaging with respect to the FRET efficiency.
        %%% (Similar to the procedure outlined in the Burst Variance Analysis
        %%% paper).
        %%% Additionally, confidence intervals for the static FRET line are
        %%% estimated.
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
        threshold = UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA;

        %% average lifetime in FRET efficiency bins
        bin_number = UserValues.BurstBrowser.Settings.NumberOfBins_BVA; % bins for range 0-1
        bin_edges = linspace(0,1,bin_number); bin_centers = bin_edges(1:end-1) + min(diff(bin_edges))/2;
        [~,~,bin] = histcounts(E,bin_edges);
        mean_tauD = NaN(1,numel(bin_edges)-1);  
        for i = 1:numel(bin_edges)-1
            %%% compute bin-wise intensity-averaged lifetime for donor
            if sum(bin == i) > threshold
                mean_tauD(i) = sum(N_phot_D(bin==i).*tauD(bin==i))./sum(N_phot_D(bin==i));
            end
        end
        
        %% plot smoothed dynamic FRET line
        [H,x,y] = histcounts2(tauD,E,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[0,1.2]);
        H = H./max(H(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;
        figure('Color',[1,1,1],'Position',[100,100,600,600]); hold on;
        ax = gca;
        ax.FontSize=20;ax.LineWidth=1.0;ax.Color =[1 1 1];
        plot_ContourPatches(ax,H,x,y,UserValues.BurstBrowser.Display.ColorLine1);
        %% Simulation for PDA comparison
        Progress(0.25,h.Progress_Axes,h.Progress_Text,'Calculating...');
%         kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_Nstates,rate_matrix,R_states,sigmaR_states);
        [Esim,tauD_sim,mean_tauD_sim,~] = kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_Nstates,rate_matrix,R_states,sigmaR_states);
        [H,x,y] = histcounts2(tauD_sim,Esim,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[0,1.2]);
        H = H./max(H(:));
        plot_ContourPatches(ax,H,x,y,UserValues.BurstBrowser.Display.ColorLine2);
        if UserValues.BurstBrowser.Settings.BVA_ModelComparison == true
            Progress(0.5,h.Progress_Axes,h.Progress_Text,'Calculating...');
            [E_static,tauD_static,mean_tauD_static,~] = kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_Nstates,...
                rate_matrix_static,R_states_static,sigmaR_states_static);
            Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
            [H,x,y] = histcounts2(E_static,tauD_static,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[0,1.2]);
            H = H./max(H(:));
            plot_ContourPatches(ax,H,x,y,UserValues.BurstBrowser.Display.ColorLine3);
            patch(ax,[0,1.2,1.2,0],[-0.1,-0.1,1.1,1.1],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none','HandleVisibility','off');
            mean_tauD_static(mean_tauD_static == 0) = NaN;
            %scatter(BinCenters,sPerBin,70,UserValues.BurstBrowser.Display.ColorLine3,'d','filled');
            plot(bin_centers',mean_tauD,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine1,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',1,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(bin_centers',mean_tauD_sim,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine2,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',1,'Color',UserValues.BurstBrowser.Display.ColorLine2);
            plot(bin_centers',mean_tauD_static,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine3,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',1,'Color',UserValues.BurstBrowser.Display.ColorLine3);
            %% Calculate sum squared residuals
            w_res_dyn = (mean_tauD-mean_tauD_sim);
            w_res_dyn(isnan(w_res_dyn)) = 0;
            SSR_dyn_legend = ['Dynamic SSR =' ' ' sprintf('%1.0e',round(sum(w_res_dyn.^2),1,'significant'))];
            w_res_stat = (mean_tauD-mean_tauD_static);
            w_res_stat(isnan(w_res_stat)) = 0;
            SSR_stat_legend = ['Static SSR =' ' ' sprintf('%1.0e',round(sum(w_res_stat.^2),1,'significant'))];
            legend('Experimental Data',SSR_dyn_legend,SSR_stat_legend,'Location','northeast');
        else
            % plot patch to phase contour plot out
            patch(ax,[0,1.2,1.2,0],[-0.1,-0.1,1.1,1.1],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none','HandleVisibility','off');
            %%% add static FRET line
            plot(bin_centers',mean_tauD,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine1,...
                    'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',1,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(bin_centers',mean_tauD_sim,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine2,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',1,'Color',UserValues.BurstBrowser.Display.ColorLine2);
            legend('Experimental Data','Simulation','Location','northeast');
        end
%         plot(ax,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData,'-','LineWidth',2,'Color','k','HandleVisibility','off');
%         plot(ax,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData,'--','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2,'HandleVisibility','off');
        set(gca,'Color',[1,1,1]);

        ax.XLim = [0,1.2];
        ax.YLim = [0,1];

        xlabel('\tau_{D,A}/\tau_{D,0}');
        ylabel('FRET Efficiency');
        set(gca,'FontSize',20,'LineWidth',2,'Box','on','DataAspectRatio',[1,1,1],'XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');

        %plot_E_tau(E_cor,tau_average);


        %% "transformed" FRET line so that static is horizontal
        transformed = false;
        if transformed    
            %%% transform quantities
            % species-weighted tau, normalized to tauD0
            tauDA = (1-E);
            % standard deviation of the species weighted tau, normalized to tauD0
            % estimated var can be < 0 due to shot noise
            var_tauDA =  (1-E).*( tauD - (1-E)) ;

            %%% do the same for all bins
            mean_tauDA_static = 1-mean_E_resampled;
            mean_var_tauDA_static = mean_tauDA_static.*( mean_tau_static_R - mean_tauDA_static);

            % and for the averaged values from the data
            data_mean_tauDA = 1-bin_centers;
            data_mean_var_tauDA = data_mean_tauDA.*( mean_tau - data_mean_tauDA);

            % for each draw sample, calculate the y value (i.e. var_tauDA)
            var_tauDA_static = (1-E_resampled).*(tau_int_R- (1-E_resampled));
            % get percentiles
            alpha = 0.001;  
            upper_bound_var = prctile(var_tauDA_static,100-alpha/(numel(bin_edges)-1),1);

            %%% plot
            [H,x,y] = histcounts2(var_tauDA,tauDA,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-.15,.5],'YBinLimits',[-0.1,1.1]);
            H = H./max(H(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;
            f2 = figure('Color',[1,1,1],'Position',[f.Position(1)+f.Position(3),100,600,600]); hold on;
            contourf(y(1:end-1),x(1:end-1),H,'LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'EdgeColor','none');
            colormap(f2,colormap(h.BurstBrowser));
            ax = gca;
            ax.CLimMode = 'auto';
            ax.CLim(1) = 0;
            ax.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;
            ax.XLim = [0,1];
            ax.YLim = [-.15,.3];

            % plot patch to phase contour plot out
            xlim = ax.XLim;
            ylim = ax.YLim;
            patch([xlim(1),xlim(2),xlim(2),xlim(1)],[ylim(1),ylim(1),ylim(2),ylim(2)],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none');
            %%% add static FRET line
            tau_line = BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime;
            E_line = BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData;    
            plot(1-E_line,(1-E_line).*(tau_line-(1-E_line)),'-','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine3);
            tau_line = BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime;
            E_line = BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData; 
            plot(1-E_line,(1-E_line).*(tau_line-(1-E_line)),'--','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);

            scatter(data_mean_tauDA,data_mean_var_tauDA,100,'diamond','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1);
            scatter(mean_tauDA_static,mean_var_tauDA_static,100,'diamond','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3);

            patch([max(mean_tauDA_static(isfinite(upper_bound_var))),mean_tauDA_static(isfinite(upper_bound_var)),min(mean_tauDA_static(isfinite(upper_bound_var)))],[ylim(1),upper_bound_var(isfinite(upper_bound_var)),ylim(1)],0.25*[1,1,1],'FaceAlpha',0.25,'LineStyle','none');
            set(gca,'Color',[1,1,1]);

            xlabel('\tau_{D,A}/\tau_{D,0}');
            ylabel('var(\tau_{D,A})');
            set(gca,'FontSize',20,'LineWidth',2,'Box','on','XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');
        end
    case 3 
        %% Phasor
        if ~isfield(BurstData{file},'Phasor')
            msgbox('Phasor not available', 'Error','error');
            return
        end
        E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
        selected = BurstData{file}.Selected;
        g_phasor = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'Phasor: gD'));
        s_phasor = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'Phasor: sD'));
        N_phot_D = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'));
        N_phot_D = N_phot_D(selected);
        E = E(selected);
        min_max = max(g_phasor)-min(g_phasor);
        xlim = [max([-0.1,min(g_phasor)-0.1*min_max]),min([1.1,max(g_phasor)+0.1*min_max])];
        min_max = max(s_phasor)-min(s_phasor);
        ylim = [max([0,min(s_phasor)-0.1*min_max]),min([0.75,max(s_phasor)+0.1*min_max])];
        [H,x,y] = histcounts2(s_phasor,g_phasor,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',ylim,'YBinLimits',xlim);
        H = H./max(H(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;
        f = figure('Color',[1,1,1],'Position',[100,100,600,600]); hold on;
        ax = gca;
%         ax.XLim = [-0.1,1.1];
%         ax.YLim = [0,0.75];
        xlabel('g');
        ylabel('s');
        set(ax,'Color',[1,1,1],'FontSize',20,'LineWidth',2,'Box','on','XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');
        
        plot_ContourPatches(ax,H',y,x,UserValues.BurstBrowser.Display.ColorLine1);
        ax.XLim = xlim;
        ax.YLim = ylim;
        %% average lifetime in FRET efficiency bins
        threshold = UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA;
        bin_number = UserValues.BurstBrowser.Settings.NumberOfBins_BVA; % bins for range 0-1
        bin_edges = linspace(0,1,bin_number); % bin_centers = bin_edges(1:end-1) + min(diff(bin_edges))/2;
        [~,~,bin] = histcounts(E,bin_edges);
        mean_g = NaN(1,numel(bin_edges)-1);
        mean_s = NaN(1,numel(bin_edges)-1);
        for i = 1:numel(bin_edges)-1
        %%% compute bin-wise intensity-averaged lifetime for donor
            if sum(bin == i) > threshold
                g_bin = g_phasor(bin==i);
                s_bin = s_phasor(bin==i);
                valid = ~isnan(g_bin) & ~isnan(s_bin);
                N_phot_D_bin = N_phot_D(bin==i);
                mean_g(i) = sum(N_phot_D_bin(valid).*g_bin(valid))./sum(N_phot_D_bin(valid));
                mean_s(i) = sum(N_phot_D_bin(valid).*s_bin(valid))./sum(N_phot_D_bin(valid));
            end
        end
        [~,mean_g_dyn,mean_s_dyn,mi] = kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_Nstates,rate_matrix,R_states,sigmaR_states);
        PIE_channel_width = BurstData{file}.TACRange*1E9*BurstData{file}.Phasor.PhasorRange(1)/BurstData{file}.FileInfo.MI_Bins;
        omega = 1/PIE_channel_width; % in ns^(-1)
        g = cell2mat(cellfun(@(x) sum(cos(2*pi*omega.*x))./numel(x),mi,'UniformOutput',false));
        s = cell2mat(cellfun(@(x) sum(sin(2*pi*omega.*x))./numel(x),mi,'UniformOutput',false));
        %%% project values
        neg=find(g<0 & s<0);
        g(neg)=-g(neg);
        s(neg)=-s(neg);
        [H,x,y] = histcounts2(g,s,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[0,0.75]);
        H = H./max(H(:));
        plot_ContourPatches(ax,H,x,y,UserValues.BurstBrowser.Display.ColorLine2)
        if UserValues.BurstBrowser.Settings.BVA_ModelComparison == true
            Progress(0.5,h.Progress_Axes,h.Progress_Text,'Calculating...');
            [~,mean_g_static,mean_s_static,mi_static] = kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_Nstates,rate_matrix_static,R_states_static,sigmaR_states_static);
            PIE_channel_width = BurstData{file}.TACRange*1E9*BurstData{file}.Phasor.PhasorRange(1)/BurstData{file}.FileInfo.MI_Bins;
            omega = 1/PIE_channel_width; % in ns^(-1)
            g = cell2mat(cellfun(@(x) sum(cos(2*pi*omega.*x))./numel(x),mi_static,'UniformOutput',false));
            s = cell2mat(cellfun(@(x) sum(sin(2*pi*omega.*x))./numel(x),mi_static,'UniformOutput',false));
            %%% project values
            neg=find(g<0 & s<0);
            g(neg)=-g(neg);
            s(neg)=-s(neg);
            [H,x,y] = histcounts2(g,s,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[0,0.75]);
            H = H./max(H(:));
            plot_ContourPatches(ax,H,x,y,UserValues.BurstBrowser.Display.ColorLine3)
            patch(ax,[xlim(1),xlim(2),xlim(2),xlim(1)],[ylim(1),ylim(1),ylim(2),ylim(2)],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none','HandleVisibility','off');
            plot(mean_g,mean_s,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine1,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(mean_g_dyn,mean_s_dyn,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine2,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
            plot(mean_g_static,mean_s_static,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine3,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine3);
            %% Calculate sum squared residuals
            w_res_dyn = (mean_s-mean_s_dyn);
            w_res_dyn(isnan(w_res_dyn)) = 0;
            SSR_dyn_legend = ['Dynamic SSR =' ' ' sprintf('%1.0e',round(sum(w_res_dyn.^2),1,'significant'))];
            w_res_stat = (mean_s-mean_s_static);
            w_res_stat(isnan(w_res_stat)) = 0;
            SSR_stat_legend = ['Static SSR =' ' ' sprintf('%1.0e',round(sum(w_res_stat.^2),1,'significant'))];
            
            legend('Experimental Data',SSR_dyn_legend,SSR_stat_legend,'Location','northeast');
        else
            patch(ax,[xlim(1),xlim(2),xlim(2),xlim(1)],[ylim(1),ylim(1),ylim(2),ylim(2)],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none','HandleVisibility','off');
            plot(mean_g,mean_s,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine1,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(mean_g_dyn,mean_s_dyn,'-d','MarkerSize',7,'MarkerEdgeColor',UserValues.BurstBrowser.Display.ColorLine2,...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
            legend('Experimental Data','Simulation','Location','northeast');
        end
         
        %%% add a second axis for the colorbar of the FRET efficiency
        ax_cbar = axes('Parent',f,'Units','pixel','Position',[ax.Position(1)+ax.Position(3)-100, ax.Position(2)+ax.Position(4)-30, 100, 30],...
            'Visible','off');
        colormap(ax_cbar,autumn);
        cbar = colorbar(ax_cbar,'NorthOutside','Units','pixel','LineWidth',2,'FontSize',16);
        cbar.Position = [421   446   109    18];
        cbar.Label.String = 'E';
%         g_circle = linspace(0,1,1000);
%         s_circle = sqrt(0.25-(g_circle-0.5).^2);
%         plot(ax,g_circle,s_circle,'-','LineWidth',2,'Color',[0,0,0],'Handlevisibility','off');
        add_universal_circle(ax,1);
end
Progress(1,h.Progress_Axes,h.Progress_Text,'Done');
end