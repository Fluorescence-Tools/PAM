function ConsistencyAnalysis(~,~)

global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;
if isempty(BurstData)
    msgbox('No data selected', 'Error','error');
    return
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating...');
switch h.ConsistencyMethod_Popupmenu.Value
    case 1
        %%% Load associated .bps file, containing Macrotime, Microtime and Channel
        if isempty(BurstTCSPCData{file})
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
        switch UserValues.BurstBrowser.Settings.Dynamic_Analysis_Method
            case {1} % BVA
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
                sSelected = sPerBurst.*BurstData{file}.Selected;
                sSelected(sSelected == 0) = NaN;
                % STD per Bin
                BinEdges = linspace(0,1,UserValues.BurstBrowser.Settings.NumberOfBins_BVA+1);
                [N,~,bin] = histcounts(E,BinEdges);
                BinCenters = BinEdges(1:end-1)+0.025;
                sPerBin = zeros(numel(BinEdges)-1,1);
                %sampling = UserValues.BurstBrowser.Settings.ConfidenceSampling_BVA;
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
                        % simulate P(sigma)
        %                 idx = [0 cumsum(cellfun('size',M,2))];
        %                 window_id = zeros(size(EPerBin));
        %                 for l = 1:numel(M)
        %                      window_id(idx(l)+1:idx(l+1)) = ones(1,size(M{l},2))*burst_id(l);
        %                 end
        %                 for m = 1:sampling
        %                     EperBin_simu = binornd(n,E(window_id))/n;
        %                     PsdPerBin(j,m) = std(EperBin_simu);
        %                     Progress(((j-1)*sampling+m)/(numel(N)*sampling),h.Progress_Axes,h.Progress_Text,'Calculating Confidence Interval...');
        %                 end
                    end
                end

                %%% Plots
                hfig = figure('color',[1 1 1]);a=gca;a.FontSize=14;a.LineWidth=1.0;a.Color =[1 1 1];
                hold on;
                X_expectedSD = linspace(0,1,1000);
                switch UserValues.BurstBrowser.Settings.BVA_X_axis
                    case 1
                        xlabel('Proximity Ratio, E*'); 
                        ylabel('SD of E*, s');
                        BinCenters = BinCenters';
                        sigm = sqrt(X_expectedSD.*(1-X_expectedSD)./UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA);
                    case 2
                        xlabel('FRET Efficiency'); 
                        ylabel('SD of FRET, s');
                        %%% conversion betweeen PR and E
                        PRtoFRET = @(PR) (1-(1+BurstData{file}.Corrections.CrossTalk_GR+BurstData{file}.Corrections.DirectExcitation_GR).*(1-PR))./ ...
                           (1-(1+BurstData{file}.Corrections.CrossTalk_GR-BurstData{file}.Corrections.Gamma_GR).*(1-PR));

                        BinCenters = PRtoFRET(BinCenters);
                        sigm = sqrt(X_expectedSD.*(1-X_expectedSD)./UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA);
                        X_expectedSD = PRtoFRET(X_expectedSD);
                        %X_burst = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
                end
                [H,x,y] = histcounts2(E,sSelected,UserValues.BurstBrowser.Display.NumberOfBinsX);

                switch UserValues.BurstBrowser.Display.PlotType
                    case 'Contour'
                    % contourplot of per-burst STD
                        contourf(x(1:end-1),y(1:end-1),H','LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'EdgeColor','none');
                        axis('xy')
                        caxis([0 max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100]);
                    case 'Image'       
                        Alpha = H./max(max(H)) > UserValues.BurstBrowser.Display.ImageOffset/100;
                        imagesc(x(1:end-1),y(1:end-1),H','AlphaData',Alpha');axis('xy');     
                        %imagesc(x(1:end-1),y(1:end-1),H','AlphaData',isfinite(H));axis('xy');
                        caxis([UserValues.BurstBrowser.Display.ImageOffset/100 max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100]);
                    case 'Scatter'
                        scatter(E,sSelected,'.','CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
                    case 'Hex'
                        hexscatter(E,sSelected,'xlim',[-0.1 1.1],'ylim',[0 max(sSelected)],'res',UserValues.BurstBrowser.Display.NumberOfBinsX);
                end        
                patch([-0.1 1.1 1.1 -0.1],[0 0 max(sSelected) max(sSelected)],'w','FaceAlpha',0.5,'edgecolor','none','HandleVisibility','off');

        %         % Plot confidence intervals
        %         alpha = UserValues.BurstBrowser.Settings.ConfidenceLevelAlpha_BVA/numel(BinCenters)/100;
        %         confint = mean(PsdPerBin,2) + std(PsdPerBin,0,2)*norminv(1-alpha);
                % confint2 = prctile(PsdPerBin,100-UserValues.BurstBrowser.Settings.ConfidenceLevelAlpha_BVA/numel(BinCenters),2);
        %         p2 = area(BinCenters,confint);
        %         p2.FaceColor = [0.5 0.5 0.5];
        %         p2.FaceAlpha = 0.5;
        %         p2.LineStyle = 'none';
        %         
                % plot of expected STD
                plot(X_expectedSD,sigm,'k','LineWidth',1);

                % Plot STD per Bin
                sPerBin(sPerBin == 0) = NaN;
                scatter(BinCenters,sPerBin,70,UserValues.BurstBrowser.Display.ColorLine1,'d','filled');

                        %% Update ColorMap
                if ischar(UserValues.BurstBrowser.Display.ColorMap)
                    if ~UserValues.BurstBrowser.Display.ColorMapFromWhite
                        colormap(hfig,UserValues.BurstBrowser.Display.ColorMap);
                    else
                        if ~strcmp(UserValues.BurstBrowser.Display.ColorMap,'jet')
                            colormap(hfig,colormap_from_white(UserValues.BurstBrowser.Display.ColorMap));
                        else %%% jet is a special case, use jetvar colormap
                            colormap(hfig,jetvar);
                        end
                    end
                else
                    colormap(hfig,UserValues.BurstBrowser.Display.ColorMap);
                end

                %% Simulate BVA plot based on PDA model
                switch UserValues.BurstBrowser.Settings.BVA_Nstates
                    case 2
                        rate_matrix = 1000*cell2mat(h.KineticRates_table2.Data); %%% rates in Hz %1000*[0,0.01;0.01,0];%
                        %E_states = [0.2,0.8];
                        R_states = [str2double(h.Rstate1_edit.String),str2double(h.Rstate2_edit.String)]; %[40,60];
                        sigmaR_states = [str2double(h.Rsigma1_edit.String),str2double(h.Rsigma2_edit.String)];
                    case 3
                        rate_matrix = 1000*cell2mat(h.KineticRates_table3.Data); %%% rates in Hz
                        R_states = [str2double(h.Rstate1_edit.String),str2double(h.Rstate2_edit.String),str2double(h.Rstate3_edit.String)];
                        sigmaR_states = [str2double(h.Rsigma1_edit.String),str2double(h.Rsigma2_edit.String),str2double(h.Rsigma3_edit.String)];
                end
                rate_matrix(isnan(rate_matrix)) = 0;
                kinetic_consistency_check('BVA',UserValues.BurstBrowser.Settings.BVA_Nstates,rate_matrix,R_states,sigmaR_states)


        end
    case 2
        %%% Prepares a plot of FRET efficiency vs. donor fluorescence liftime,
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
        mean_tau = NaN(1,numel(bin_edges)-1);  
        for i = 1:numel(bin_edges)-1
            %%% compute bin-wise intensity-averaged lifetime for donor
            if sum(bin == i) > threshold
                mean_tau(i) = sum(N_phot_D(bin==i).*tauD(bin==i))./sum(N_phot_D(bin==i));
            end
        end
        
        %% plot smoothed dynamic FRET line
        [H,x,y] = histcounts2(E,tauD,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[0,1.2]);
        H = H./max(H(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;
        fig = figure('Color',[1,1,1],'Position',[100,100,600,600]); hold on;
        contourf(y(1:end-1),x(1:end-1),H,'LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'EdgeColor','none');
        colormap(fig,colormap(h.BurstBrowser));
        ax = gca;
        ax.CLimMode = 'auto';
        ax.CLim(1) = 0;
        ax.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;
        % plot patch to phase contour plot out
        patch([0,1.2,1.2,0],[-0.1,-0.1,1.1,1.1],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none');
        %%% add static FRET line
        plot(BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData,'-','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
        plot(BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData,'--','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);

        scatter(mean_tau,bin_centers,100,'diamond','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1);
        set(gca,'Color',[1,1,1]);

        ax.XLim = [0,1.2];
        ax.YLim = [0,1];

        xlabel('\tau_{D,A}/\tau_{D,0}');
        ylabel('FRET Efficiency');
        set(gca,'FontSize',24,'LineWidth',2,'Box','on','DataAspectRatio',[1,1,1],'XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');

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
            plot(1-E_line,(1-E_line).*(tau_line-(1-E_line)),'-','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            tau_line = BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime;
            E_line = BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData; 
            plot(1-E_line,(1-E_line).*(tau_line-(1-E_line)),'--','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);

            scatter(data_mean_tauDA,data_mean_var_tauDA,100,'diamond','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1);
            scatter(mean_tauDA_static,mean_var_tauDA_static,100,'diamond','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2);

            patch([max(mean_tauDA_static(isfinite(upper_bound_var))),mean_tauDA_static(isfinite(upper_bound_var)),min(mean_tauDA_static(isfinite(upper_bound_var)))],[ylim(1),upper_bound_var(isfinite(upper_bound_var)),ylim(1)],0.25*[1,1,1],'FaceAlpha',0.25,'LineStyle','none');
            set(gca,'Color',[1,1,1]);

            xlabel('\tau_{D,A}/\tau_{D,0}');
            ylabel('var(\tau_{D,A})');
            set(gca,'FontSize',24,'LineWidth',2,'Box','on','XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');
        end

        %% Simulation for PDA comparison
        switch UserValues.BurstBrowser.Settings.BVA_Nstates
            case 2
                rate_matrix = 1000*cell2mat(h.KineticRates_table2.Data(1:2,1:2)); %%% rates in Hz %1000*[0,0.01;0.01,0];%
                %E_states = [0.2,0.8];
                R_states = [str2double(h.Rstate1_edit.String),str2double(h.Rstate2_edit.String)]; %[40,60];
                sigmaR_states = [str2double(h.Rsigma1_edit.String),str2double(h.Rsigma2_edit.String)];
            case 3
                rate_matrix = 1000*cell2mat(h.KineticRates_table3.Data); %%% rates in Hz
                R_states = [str2double(h.Rstate1_edit.String),str2double(h.Rstate2_edit.String),str2double(h.Rstate3_edit.String)];
                sigmaR_states = [str2double(h.Rsigma1_edit.String),str2double(h.Rsigma2_edit.String),str2double(h.Rsigma3_edit.String)];
        end
        rate_matrix(isnan(rate_matrix)) = 0;
        kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_Nstates,rate_matrix,R_states,sigmaR_states);
        Progress(1,h.Progress_Axes,h.Progress_Text,'Done');
    case 3
end
Progress(1,h.Progress_Axes,h.Progress_Text,'Done');
end