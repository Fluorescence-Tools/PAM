function ConsistencyAnalysis(~,~)

global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;
if isempty(BurstData)
    msgbox('No data selected', 'Error','error');
    return
end
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData{file})
    Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photons...');
    Load_Photons();
end
min_bursts_per_bin = UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA;
Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating...');
switch UserValues.BurstBrowser.Settings.BVA_DynamicStates
            case 2
                rate_matrix = 1000*cell2mat(h.KineticRates_table2.Data); %%% rates in Hz
                R_states = [str2double(h.Rstate1_edit.String),str2double(h.Rstate2_edit.String)];
                sigmaR_states = [str2double(h.Rsigma1_edit.String),str2double(h.Rsigma2_edit.String)];
            case 3
                rate_matrix = 1000*cell2mat(h.KineticRates_table3.Data); %%% rates in Hz
                R_states = [str2double(h.Rstate1_edit.String),str2double(h.Rstate2_edit.String),str2double(h.Rstate3_edit.String)];
                sigmaR_states = [str2double(h.Rsigma1_edit.String),str2double(h.Rsigma2_edit.String),str2double(h.Rsigma3_edit.String)];
end
                
switch UserValues.BurstBrowser.Settings.BVA_StaticStates
            case 2
                rate_matrix_static = [ 0,    0.1;
                                       0.1,    0]; %%% rates in Hz
                R_states_static = [str2double(h.Rstate1st_edit.String),str2double(h.Rstate2st_edit.String)];
                sigmaR_states_static = [str2double(h.Rsigma1st_edit.String),str2double(h.Rsigma2st_edit.String)];
            case 3
                rate_matrix_static = [ 0,    0.1, 0.1;
                                       0.1,    0, 0.1;
                                       0.1, 0.1,    0]; %%% rates in Hz
                R_states_static = [str2double(h.Rstate1st_edit.String),str2double(h.Rstate2st_edit.String),str2double(h.Rstate3st_edit.String)];
                sigmaR_states_static = [str2double(h.Rsigma1st_edit.String),str2double(h.Rsigma2st_edit.String),str2double(h.Rsigma3st_edit.String)];
end
rate_matrix(isnan(rate_matrix)) = 0;

% figure and plot parameters
fwidth = 700;
fheight = 700;
ffontsize = 24;
if ~ismac
    ffontsize = ffontsize*0.8;
end
fcenterPlotPos = [0.1 0.11 0.6 0.6];
faculty = get(0,'default');
set(0,'defaultaxesfontsize',ffontsize,'defaultaxesfontname','Arial','defaultaxeslinewidth',2.0,...
    'defaultaxesygrid','on','defaultaxesxgrid','on','defaultaxesbox','on','defaultaxescolor',[1 1 1],...
    'defaultlinelinewidth',2,'defaultaxesxcolor',[0 0 0],'defaultaxesycolor',[0 0 0])
switch UserValues.BurstBrowser.Settings.Dynamic_Analysis_Method % BVA
    case 1
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
        BinCenters = BinEdges(1:end-1)+min(diff(BinEdges))/2;
        sPerBin = zeros(numel(BinEdges)-1,1);
%         sampling = UserValues.BurstBrowser.Settings.ConfidenceSampling_BVA;
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
                if numel(BurstsPerBin)>min_bursts_per_bin
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
        Progress(0.25,h.Progress_Axes,h.Progress_Text,'Calculating...');
        [E_sim,sSelected_sim,sPerBin_sim] = kinetic_consistency_check('BVA',UserValues.BurstBrowser.Settings.BVA_DynamicStates,rate_matrix,R_states,sigmaR_states);
        %% Generate plots
        sPerBin(sPerBin == 0) = NaN;
        sPerBin_sim(sPerBin_sim == 0) = NaN;
        Progress(0.5,h.Progress_Axes,h.Progress_Text,'Calculating...');
        % contour patches
        [H_real,x_real,y_real] = histcounts2(E,sSelected,UserValues.BurstBrowser.Display.NumberOfBinsX); 
        [H_sim,x_sim,y_sim] = histcounts2(E_sim,sSelected_sim,UserValues.BurstBrowser.Display.NumberOfBinsX);
        %% Calculate sum squared residuals (dynamic)
        w_res_dyn = (sPerBin-sPerBin_sim);
        w_res_dyn(isnan(w_res_dyn)) = 0;
        SSR_dyn_legend = ['Dynamic' newline 'SSR:' ' ' sprintf('%.0e',round(sum(w_res_dyn.^2),1,'significant'))];
        switch UserValues.BurstBrowser.Settings.BVA_ModelComparison
            case 1 % compare dynamic and static model to experimental data
                Progress(0.75,h.Progress_Axes,h.Progress_Text,'Calculating...');
                [E_static,sSelected_static,sPerBin_static] = kinetic_consistency_check('BVA',UserValues.BurstBrowser.Settings.BVA_StaticStates,...
                    rate_matrix_static,R_states_static,sigmaR_states_static);
                Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
                [H_static,x_static,y_static] = histcounts2(E_static,sSelected_static,UserValues.BurstBrowser.Display.NumberOfBinsX);
                %% Calculate sum squared residuals (static)
                sPerBin_static(sPerBin_static == 0) = NaN;
                w_res_stat = (sPerBin-sPerBin_static);
                w_res_stat(isnan(w_res_stat)) = 0;
                SSR_stat_legend = ['Static' newline 'SSR:' ' ' sprintf('%.0e',round(sum(w_res_stat.^2),1,'significant'))];
                if UserValues.BurstBrowser.Settings.BVA_SeperatePlots
                    legends = {{['EXP' newline 'Data'], ['Expected' newline 'STDEV']},...
                        {['SIM Data' newline 'Dynamic'], ['Expected' newline 'STDEV']},...
                        {['SIM Data' newline 'Static'], ['Expected' newline 'STDEV']}};
                    maxYLim = [0 max([sSelected;sSelected_sim;sSelected_static])+0.01];
                    for i=1:3
                        hfig = figure('color',[1 1 1],'Position',[0+(i-1)*fwidth 100 fwidth fheight]);
                        subplot('Position',fcenterPlotPos)
                        ax = gca;
                        switch i
                            case 1 % experimental data
                                x_data = x_real;
                                y_data = y_real;
                                H_data = H_real;
                                E_data = E;
                                sSelected_data = sSelected;
                                color = UserValues.BurstBrowser.Display.ColorLine1;
                            case 2 % dynamic simulation data
                                x_data = x_sim; 
                                y_data = y_sim;
                                H_data = H_sim;
                                E_data = E_sim;
                                sSelected_data = sSelected_sim;
                                color = UserValues.BurstBrowser.Display.ColorLine2;
                            case 3 % static simulation data
                                x_data = x_static;
                                y_data = y_static;
                                H_data = H_static;
                                E_data = E_static;
                                sSelected_data = sSelected_static;
                                color = UserValues.BurstBrowser.Display.ColorLine3;
                        end
                        plot_main(hfig,x_data,y_data,H_data,E_data,sSelected_data,color)
                        ax.NextPlot = 'add';
                        ax.XLabel.String = 'Proximity Ratio, E*';
                        ax.YLabel.String = 'STDEV of E*, s';
                        ax.YLim = maxYLim;
                        ax.XLim = [0 1];
                        ax.YLim = [0 0.55];
                        ax.Layer = 'bottom';
                        grid(ax,'on');
                        
                        % plot of expected STD
                        X_expectedSD = linspace(0,1,1000);
                        sigm = sqrt(X_expectedSD.*(1-X_expectedSD)./UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA);
                        plot(ax,X_expectedSD,sigm,'k','LineWidth',3);
                        
                        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') == true
                            lgd = legend(ax,legends{i},'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                        elseif strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter') == false
                            hidden_h = surf(ax,uint8([1 1;1 1]),colormap(ax), 'EdgeColor', 'none');
                            uistack(hidden_h, 'bottom');
                            lgd = legend(ax,legends{i},'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                            cb = colorbar(ax,'Location','east');
                            cb.Ticks = [];
                            cb.Position = [0.72 0.88 0.04 0.06];
                        else
                            lgd = legend(ax,legends{i},'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                        end
                        lgd.FontSize = ffontsize*0.95;
                        
                        face_alpha = 1;
                        plot_marignal_1D_hist(ax,E_data,sSelected_data,face_alpha,color,ffontsize)
                        if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
                            E1 = 1/(1+(R_states(1,1)/BurstData{file}.Corrections.FoersterRadius)^6);
                            E2 = 1./(1+(R_states(1,2)/BurstData{file}.Corrections.FoersterRadius)^6);
                            hold on
                            BVA_dynamic_FRET(ax,E1,E2,n);
                            lgd.String(end) = {['THEO DYN' newline 'FRET line']};
                            lgd.Position = [0.705 0.715 0.235 0.23535];
                            cb.Position = [0.72 0.88 0.04 0.06];
                            lgd.FontSize = ffontsize*0.9;
                        end
                    end
                else % plot all in one figure
                    figure('color',[1 1 1],'Position',[fwidth 100 fwidth fheight]);
                    %X_expectedSD = linspace(0,1,1000);
                    xlabel('Proximity Ratio, E*'); 
                    ylabel('SD of E*, s');
                    subplot('Position',fcenterPlotPos)
                    ax = gca;
                    ax.NextPlot = 'add';
                    ax.XLabel.String = 'Proximity Ratio, E*';
                    ax.YLabel.String = 'STDEV of E*, s';
                    ax.XLim = [0 1];
                    ax.YLim = [0 0.55];
                    ax.GridAlpha = 0.35;
                    
                    plot_ContourPatches(ax,H_real,x_real,y_real,UserValues.BurstBrowser.Display.ColorLine1)
                    plot_ContourPatches(ax,H_sim,x_sim,y_sim,UserValues.BurstBrowser.Display.ColorLine2)
                    plot_ContourPatches(ax,H_static,x_static,y_static,UserValues.BurstBrowser.Display.ColorLine3)
                    patch(ax,[-0.1 1.1 1.1 -0.1],[0 0 max(sSelected) max(sSelected)],'w','FaceAlpha',0.5,'edgecolor','none','HandleVisibility','off');
                    plot(BinCenters',sPerBin,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
                    plot(BinCenters',sPerBin_sim,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
                    plot(BinCenters',sPerBin_static,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine3);
                    
                    lgd = legend(ax,'EXP Data',SSR_dyn_legend,SSR_stat_legend,'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                    lgd.FontSize = ffontsize*0.95;
                    
                    plot_marignal_1D_hist(ax,E,sSelected,0.6,UserValues.BurstBrowser.Display.ColorLine1,ffontsize)
                    plot_marignal_1D_hist(ax,E_sim,sSelected_sim,0.6,UserValues.BurstBrowser.Display.ColorLine2,ffontsize)
                    plot_marignal_1D_hist(ax,E_static,sSelected_static,0.6,UserValues.BurstBrowser.Display.ColorLine3,ffontsize)
                    
                    if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
                        E1 = 1/(1+(R_states(1,1)/BurstData{file}.Corrections.FoersterRadius)^6);
                        E2 = 1./(1+(R_states(1,2)/BurstData{file}.Corrections.FoersterRadius)^6);
                        hold on
                        BVA_dynamic_FRET(ax,E1,E2,n);
                        lgd.String(end) = {['THEO DYN' newline 'FRET line']};
                        lgd.Position = [0.71 0.73 0.235 0.23535];
                        lgd.FontSize = ffontsize*0.9;
                    end
                end
            case 0 % compare only dynamic model to experimental data
                Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
                if UserValues.BurstBrowser.Settings.BVA_SeperatePlots
                   legends = {{['EXP' newline 'Data'], ['Expected' newline 'STDEV']},...
                        {['SIM Data' newline 'Dynamic'], ['Expected' newline 'STDEV']},...
                        {['SIM Data' newline 'Static'], ['Expected' newline 'STDEV']}};
                    maxYLim = [0 max([sSelected;sSelected_sim])+0.01];
                    for i=1:2
                        hfig = figure('color',[1 1 1],'Position',[0+(i-1)*fwidth 100 fwidth fheight]);
                        subplot('Position',fcenterPlotPos)
                        switch i
                            case 1 % experimental data
                                x_data = x_real;
                                y_data = y_real;
                                H_data = H_real;
                                E_data = E;
                                sSelected_data = sSelected;
                                color = UserValues.BurstBrowser.Display.ColorLine1;
                            case 2 % dynamic simulation data
                                x_data = x_sim; 
                                y_data = y_sim;
                                H_data = H_sim;
                                E_data = E_sim;
                                sSelected_data = sSelected_sim;
                                color = UserValues.BurstBrowser.Display.ColorLine2;
                        end
                        plot_main(hfig,x_data,y_data,H_data,E_data,sSelected_data,color)
                        ax = gca;
                        ax.NextPlot = 'add';
                        ax.XLabel.String = 'Proximity Ratio, E*';
                        ax.YLabel.String = 'STDEV of E*, s';
                        ax.YLim = maxYLim;
                        ax.XLim = [0 1];
                        ax.YLim = [0 0.55];
                        ax.Layer = 'bottom';
                        grid(ax,'on');
                        
                        % plot of expected STD
                        X_expectedSD = linspace(0,1,1000);
                        sigm = sqrt(X_expectedSD.*(1-X_expectedSD)./UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA);
                        plot(ax,X_expectedSD,sigm,'k','LineWidth',3);
                        
                        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') == true
                            lgd = legend(ax,legends{i},'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                        elseif strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter') == false
                            hidden_h = surf(ax,uint8([1 1;1 1]),colormap(ax), 'EdgeColor', 'none');
                            uistack(hidden_h, 'bottom');
                            lgd = legend(ax,legends{i},'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                            cb = colorbar(ax,'Location','east');
                            cb.Ticks = [];
                            cb.Position = [0.73 0.857 0.04 0.065];
                        else
                            lgd = legend(ax,legends{i},'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                        end
                        lgd.FontSize = ffontsize*0.95;
                        face_alpha = 1;
                        plot_marignal_1D_hist(ax,E_data,sSelected_data,face_alpha,color,ffontsize);
                        
                        if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
                            E1 = 1/(1+(R_states(1,1)/BurstData{file}.Corrections.FoersterRadius)^6);
                            E2 = 1./(1+(R_states(1,2)/BurstData{file}.Corrections.FoersterRadius)^6);
                            hold on
                            BVA_dynamic_FRET(ax,E1,E2,n);
                            lgd.String(end) = {['THEO DYN' newline 'FRET line']};
                            lgd.Position = [0.705 0.715 0.235 0.23535];
                            cb.Position = [0.72 0.88 0.04 0.06];
                            lgd.FontSize = ffontsize*0.9;
                        end
                    end
                else % plot all in one figure
                    figure('color',[1 1 1],'Position',[fwidth 100 fwidth fheight]);
                    %X_expectedSD = linspace(0,1,1000);
                    xlabel('Proximity Ratio, E*'); 
                    ylabel('SD of E*, s');
                    subplot('Position',fcenterPlotPos)
                    ax = gca;
                    ax.NextPlot = 'add';
                    ax.XLabel.String = 'Proximity Ratio, E*';
                    ax.YLabel.String = 'STDEV of E*, s';
                    ax.XLim = [0 1];
                    ax.YLim = [0 0.55];
                    ax.GridAlpha = 0.35;
                    
                    plot_ContourPatches(ax,H_real,x_real,y_real,UserValues.BurstBrowser.Display.ColorLine1)
                    plot_ContourPatches(ax,H_sim,x_sim,y_sim,UserValues.BurstBrowser.Display.ColorLine2)
                    patch(ax,[-0.1 1.1 1.1 -0.1],[0 0 max(sSelected) max(sSelected)],'w','FaceAlpha',0.5,'edgecolor','none','HandleVisibility','off');
                    plot(BinCenters',sPerBin,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
                    plot(BinCenters',sPerBin_sim,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
                    
                    lgd = legend(ax,['Binned' newline 'EXP Data'],SSR_dyn_legend,'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                    lgd.FontSize = ffontsize*0.95;
                   
                    plot_marignal_1D_hist(ax,E,sSelected,0.6,UserValues.BurstBrowser.Display.ColorLine1,ffontsize)
                    plot_marignal_1D_hist(ax,E_sim,sSelected_sim,0.6,UserValues.BurstBrowser.Display.ColorLine2,ffontsize)
                    
                    %plot_BVA(E,sSelected,BinCenters,sPerBin)
                    if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
                        E1 = 1/(1+(R_states(1,1)/BurstData{file}.Corrections.FoersterRadius)^6);
                        E2 = 1./(1+(R_states(1,2)/BurstData{file}.Corrections.FoersterRadius)^6);
                        hold on
                        BVA_dynamic_FRET(ax,E1,E2,n);
                        lgd.String(end) = {['THEO DYN' newline 'FRET line']};
                        lgd.Position = [0.705 0.715 0.235 0.23535];
                        lgd.FontSize = ffontsize*0.9;
                    end
                end
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
        %% average lifetime in FRET efficiency bins
        bin_number = UserValues.BurstBrowser.Settings.NumberOfBins_BVA; % bins for range 0-1
        bin_edges = linspace(0,1,bin_number+1); BinCenters = bin_edges(1:end-1) + min(diff(bin_edges))/2;
        [~,~,bin] = histcounts(E,bin_edges);
        mean_tauD = NaN(1,numel(bin_edges)-1);  
        for i = 1:numel(BinCenters)
            %%% compute bin-wise intensity-averaged lifetime for donor
            if sum(bin == i) > min_bursts_per_bin
                mean_tauD(i) = sum(N_phot_D(bin==i).*tauD(bin==i))./sum(N_phot_D(bin==i));
            end
        end
        %% smoothed dynamic FRET line
        [H_real,x_real,y_real] = histcounts2(tauD,E,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[-0.1,1.1]);
        H_real = H_real./max(H_real(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;
        %% Simulation for PDA comparison
        Progress(0.25,h.Progress_Axes,h.Progress_Text,'Calculating...');
        [E_sim,tauD_sim,mean_tauD_sim,~] = kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_DynamicStates,rate_matrix,R_states,sigmaR_states);
        [H_sim,x_sim,y_sim] = histcounts2(tauD_sim,E_sim,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[-0.1,1.1]);
        H_sim = H_sim./max(H_sim(:));
        Progress(0.5,h.Progress_Axes,h.Progress_Text,'Calculating...');
        %% Calculate sum squared residuals (dynamic)
        w_res_dyn = (mean_tauD-mean_tauD_sim);
        w_res_dyn(isnan(w_res_dyn)) = 0;
        SSR_dyn_legend = ['Dynamic' newline 'SSR:' ' ' sprintf('%.0e',round(sum(w_res_dyn.^2),1,'significant'))];
%         maxXLim = [0 max([tauD;tauD_sim'])+0.01];
        switch UserValues.BurstBrowser.Settings.BVA_ModelComparison
            case 1
                Progress(0.75,h.Progress_Axes,h.Progress_Text,'Calculating...');
                [E_static,tauD_static,mean_tauD_static,~] = kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_StaticStates,...
                    rate_matrix_static,R_states_static,sigmaR_states_static);
                Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
                [H_static,x_static,y_static] = histcounts2(tauD_static,E_static,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[-0.1,1.1]);
                H_static = H_static./max(H_static(:));
                %% Calculate sum squared residuals (static)
                w_res_stat = (mean_tauD-mean_tauD_static);
                w_res_stat(isnan(w_res_stat)) = 0;
                mean_tauD_static(mean_tauD_static == 0) = NaN;
                SSR_stat_legend = ['Static' newline 'SSR:' ' ' sprintf('%.0e',round(sum(w_res_stat.^2),1,'significant'))];
                if UserValues.BurstBrowser.Settings.BVA_SeperatePlots
                    legends = {{['EXP Data'],['Static' newline 'FRET line'],['Dynamic' newline 'FRET line']},...
                        {['SIM Data'],['Static' newline 'FRET line'],['Dynamic' newline 'FRET line']},...
                        {'SIM Data',['Static' newline 'FRET line'],['Dynamic' newline 'FRET line']}};
%                     maxXLim = [0 max([tauD;tauD_sim';tauD_static'])+0.01];
                    for i=1:3
                        hfig = figure('color',[1 1 1],'Position',[0+(i-1)*fwidth 100 fwidth fheight]);
                        subplot('Position',fcenterPlotPos)
                        ax = gca;
                        switch i
                            case 1 % experimental data
                                x_data = x_real;
                                y_data = y_real;
                                H_data = H_real;
                                E_data = E;
                                tauD_data = tauD;
                                color = UserValues.BurstBrowser.Display.ColorLine1;
                            case 2 % dynamic simulation data
                                x_data = x_sim; 
                                y_data = y_sim;
                                H_data = H_sim;
                                E_data = E_sim';
                                tauD_data = tauD_sim';
                                color = UserValues.BurstBrowser.Display.ColorLine2;
                            case 3 % static simulation data
                                x_data = x_static;
                                y_data = y_static;
                                H_data = H_static;
                                E_data = E_static';
                                tauD_data = tauD_static';
                                color = UserValues.BurstBrowser.Display.ColorLine3;
                        end
                        plot_main(hfig,x_data,y_data,H_data,E_data,tauD_data,color)
                        ax.NextPlot = 'add';
                        ax.XLabel.String = '\tau_{D,A}/\tau_{D,0}';
                        ax.YLabel.String = 'FRET Efficiency';
                        ax.YLim = [-0.1 1.1];
                        ax.XLim = [0 1.1];
                        ax.Layer = 'bottom';
                        grid(ax,'on');
                        
                        %%% add FRET lines
                        plot(ax,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData,'-','LineWidth',3,'Color','k','HandleVisibility','on');
                        if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
                            plot(ax,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData,'--','LineWidth',3,'Color',UserValues.BurstBrowser.Display.ColorLine1,'HandleVisibility','on');
                        else
                            legends{i}(end) = [];
                        end
                        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') == true
                            lgd = legend(ax,legends{i},'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                        elseif strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter') == false
                            hidden_h = surf(ax,uint8([1 1;1 1]),colormap(ax), 'EdgeColor', 'none');
                            uistack(hidden_h, 'bottom');
                            lgd = legend(ax,legends{i},'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                            cb = colorbar(ax,'Location','east');
                            cb.Ticks = [];
                            if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
                                cb.Position = [0.728 0.905 0.04 0.04];
                            else
                                cb.Position = [0.728 0.888 0.04 0.04];
                            end
                        else
                            lgd = legend(ax,legends{i},'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                        end
                        lgd.FontSize = ffontsize*0.95;
                        face_alpha = 1;
                        plot_marignal_1D_hist(ax,tauD_data,E_data,face_alpha,color,ffontsize)
                    end
                else % plot all in one figure
                    figure('color',[1 1 1],'Position',[fwidth 100 fwidth fheight]);
                    %X_expectedSD = linspace(0,1,1000);
                    xlabel('Proximity Ratio, E*'); 
                    ylabel('SD of E*, s');
                    subplot('Position',fcenterPlotPos)
                    ax = gca;
                    ax.NextPlot = 'add';
                    ax.XLabel.String = '\tau_{D,A}/\tau_{D,0}';
                    ax.YLabel.String = 'FRET Efficiency';
                    ax.XLim = [0 1.1];
                    ax.YLim = [-0.1 1.1];
                    ax.GridAlpha = 0.35;
                    
                    plot_ContourPatches(ax,H_real,x_real,y_real,UserValues.BurstBrowser.Display.ColorLine1)
                    plot_ContourPatches(ax,H_sim,x_sim,y_sim,UserValues.BurstBrowser.Display.ColorLine2)
                    plot_ContourPatches(ax,H_static,x_static,y_static,UserValues.BurstBrowser.Display.ColorLine3)
                    patch(ax,[-0.1 1.1 1.1 -0.1],[-0.1 -0.1 max(tauD) max(tauD)],'w','FaceAlpha',0.5,'edgecolor','none','HandleVisibility','off');
                    plot(mean_tauD,BinCenters,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
                    plot(mean_tauD_sim,BinCenters,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
                    plot(mean_tauD_static,BinCenters,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine3);
                    
                    %%% add FRET lines
                    plot(ax,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData,'-','LineWidth',3,'Color','k','HandleVisibility','on');
                    if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
                        plot(ax,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData,'--','LineWidth',3,'Color',UserValues.BurstBrowser.Display.ColorLine1,'HandleVisibility','on');
                    end
                    lgd = legend(ax,'EXP Data',SSR_dyn_legend,SSR_stat_legend,'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                    lgd.FontSize = ffontsize * 0.95;
                    
                    plot_marignal_1D_hist(ax,tauD,E,0.6,UserValues.BurstBrowser.Display.ColorLine1,ffontsize)
                    plot_marignal_1D_hist(ax,tauD_sim,E_sim,0.6,UserValues.BurstBrowser.Display.ColorLine2,ffontsize)
                    plot_marignal_1D_hist(ax,tauD_static,E_static,0.6,UserValues.BurstBrowser.Display.ColorLine3,ffontsize)
                end
            case 0 % compare only dynamic model to experimental data
                Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
                if UserValues.BurstBrowser.Settings.BVA_SeperatePlots
                   legends = {{['EXP Data'],['Static' newline 'FRET line'],['Dynamic' newline 'FRET line']},...
                        {['SIM Data'],['Static' newline 'FRET line'],['Dynamic' newline 'FRET line']},...
                        {'SIM Data',['Static' newline 'FRET line'],['Dynamic' newline 'FRET line']}};
                    for i=1:2
                        hfig = figure('color',[1 1 1],'Position',[0+(i-1)*fwidth 100 fwidth fheight]);
                        subplot('Position',fcenterPlotPos)
                        switch i
                            case 1 % experimental data
                                x_data = x_real;
                                y_data = y_real;
                                H_data = H_real;
                                E_data = E;
                                tauD_data = tauD;
                                color = UserValues.BurstBrowser.Display.ColorLine1;
                            case 2 % dynamic simulation data
                                x_data = x_sim; 
                                y_data = y_sim;
                                H_data = H_sim;
                                E_data = E_sim';
                                tauD_data = tauD_sim';
                                color = UserValues.BurstBrowser.Display.ColorLine2;
                        end
                        plot_main(hfig,x_data,y_data,H_data,E_data,tauD_data,color)
                        ax = gca;
                        ax.NextPlot = 'add';
                        ax.XLabel.String = '\tau_{D,A}/\tau_{D,0}';
                        ax.YLabel.String = 'FRET Efficiency';
                        ax.YLim = [-0.1 1.1];
                        ax.XLim = [0 1.1];
                        ax.Layer = 'bottom';
                        grid(ax,'on');
                        
                        %%% add FRET lines
                        plot(ax,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData,'-','LineWidth',3,'Color','k','HandleVisibility','on');
                        if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
                            plot(ax,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData,'--','LineWidth',3,'Color',UserValues.BurstBrowser.Display.ColorLine1,'HandleVisibility','on');
                        else
                            legends{i}(end) = [];
                        end
                        
                        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour') == true
                            lgd = legend(ax,legends{i},'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                        elseif strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter') == false
                            hidden_h = surf(ax,uint8([1 1;1 1]),colormap(ax), 'EdgeColor', 'none');
                            uistack(hidden_h, 'bottom');
                            lgd = legend(ax,legends{i},'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                            cb = colorbar(ax,'Location','east');
                            cb.Ticks = [];
                            if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
                                cb.Position = [0.728 0.905 0.04 0.04];
                            else
                                cb.Position = [0.728 0.888 0.04 0.04];
                            end
                        else
                            lgd = legend(ax,legends{i},'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                        end
                        lgd.FontSize = ffontsize*0.95;
                        face_alpha = 1;
                        plot_marignal_1D_hist(ax,tauD_data,E_data,face_alpha,color,ffontsize);
                    end
                else % plot all in one figure
                    figure('color',[1 1 1],'Position',[fwidth 100 fwidth fheight]);
                    %X_expectedSD = linspace(0,1,1000);
                    subplot('Position',fcenterPlotPos)
                    ax = gca;
                    ax.NextPlot = 'add';
                    ax.XLabel.String = '\tau_{D,A}/\tau_{D,0}';
                    ax.YLabel.String = 'FRET Efficiency';
                    ax.XLim = [0 1.1];
                    ax.YLim = [-0.1 1.1];
                    ax.GridAlpha = 0.35;
                    
                    plot_ContourPatches(ax,H_real,x_real,y_real,UserValues.BurstBrowser.Display.ColorLine1)
                    plot_ContourPatches(ax,H_sim,x_sim,y_sim,UserValues.BurstBrowser.Display.ColorLine2)
                    patch(ax,[-0.1 1.1 1.1 -0.1],[-0.1 -0.1 max(tauD) max(tauD)],'w','FaceAlpha',0.5,'edgecolor','none','HandleVisibility','off');
                    plot(mean_tauD,BinCenters,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
                    plot(mean_tauD_sim,BinCenters,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
                    
                    %%% add FRET lines
                    plot(ax,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData,'-','LineWidth',3,'Color','k','HandleVisibility','on');
                    if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
                        plot(ax,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData,'--','LineWidth',3,'Color',UserValues.BurstBrowser.Display.ColorLine1,'HandleVisibility','on');
                    end
                    
                    lgd = legend(ax,['Binned' newline 'EXP Data'],SSR_dyn_legend,'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                    lgd.FontSize = ffontsize*0.95;
                    
                    plot_marignal_1D_hist(ax,tauD,E,0.6,UserValues.BurstBrowser.Display.ColorLine1,ffontsize)
                    plot_marignal_1D_hist(ax,tauD_sim,E_sim,0.6,UserValues.BurstBrowser.Display.ColorLine2,ffontsize)
                end
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
        xlabel('g');
        ylabel('s');
        set(ax,'Color',[1,1,1],'FontSize',24,'LineWidth',2,'Box','on','XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');
        plot_ContourPatches(ax,H',y,x,UserValues.BurstBrowser.Display.ColorLine1);
        ax.XLim = xlim;
        ax.YLim = ylim;
        %% average lifetime in FRET efficiency bins
        bin_number = UserValues.BurstBrowser.Settings.NumberOfBins_BVA; % bins for range 0-1
        bin_edges = linspace(0,1,bin_number); bin_centers = bin_edges(1:end-1) + min(diff(bin_edges))/2;
        [~,~,bin] = histcounts(E,bin_edges);
        mean_g = NaN(1,numel(bin_edges)-1);
        mean_s = NaN(1,numel(bin_edges)-1);
        for i = 1:numel(bin_edges)-1
        %%% compute bin-wise intensity-averaged lifetime for donor
            if sum(bin == i) > min_bursts_per_bin
                g_bin = g_phasor(bin==i);
                s_bin = s_phasor(bin==i);
                valid = ~isnan(g_bin) & ~isnan(s_bin);
                N_phot_D_bin = N_phot_D(bin==i);
                mean_g(i) = sum(N_phot_D_bin(valid).*g_bin(valid))./sum(N_phot_D_bin(valid));
                mean_s(i) = sum(N_phot_D_bin(valid).*s_bin(valid))./sum(N_phot_D_bin(valid));
            end
        end
        [~,mean_g_dyn,mean_s_dyn,mi] = kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_DynamicStates,rate_matrix,R_states,sigmaR_states);
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
            [~,mean_g_static,mean_s_static,mi_static] = kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_StaticStates,rate_matrix_static,R_states_static,sigmaR_states_static);
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
            plot(mean_g,mean_s,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(mean_g_dyn,mean_s_dyn,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
            plot(mean_g_static,mean_s_static,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
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
            plot(mean_g,mean_s,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(mean_g_dyn,mean_s_dyn,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
            legend('Experimental Data','Simulation','Location','northeast');
        end
%         g_circle = linspace(0,1,1000);
%         s_circle = sqrt(0.25-(g_circle-0.5).^2);
%         plot(ax,g_circle,s_circle,'-','LineWidth',2,'Color',[0,0,0],'Handlevisibility','off');
        add_universal_circle(ax,1);
    case 4
        selected = BurstData{file}.Selected;
        E = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
%         PR = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'Proximity Ratio'));
        FRET_2CDE = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'FRET 2CDE Filter'));
        N_phot_D = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'));
        N_phot_A = BurstData{file}.DataArray(selected,strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'));
        E_D = BurstData{file}.NirFilter.E_D(selected)';
        E_A = BurstData{file}.NirFilter.E_A(selected)';
        %% average lifetime in FRET efficiency bins
        bin_edges = linspace(0,1,UserValues.BurstBrowser.Settings.NumberOfBins_BVA+1);
        [~,~,bin] = histcounts(E,bin_edges);
        bin_centers = bin_edges(1:end-1)+min(diff(bin_edges))/2;
        
%         bin_number = UserValues.BurstBrowser.Settings.NumberOfBins_BVA; % bins for range 0-1
%         bin_edges = linspace(0,1,bin_number); bin_centers = bin_edges(1:end-1) + min(diff(bin_edges))/2;
%         [~,~,bin] = histcounts(E,bin_edges);
        mean_FRET_2CDE = NaN(1,numel(bin_edges)-1);
        mean_FRET_2CDE_naive = NaN(1,numel(bin_edges)-1);
        for i = 1:numel(bin_edges)-1
            %%% compute bin-wise intensity-averaged FRET 2CDE
            if sum(bin == i) > UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA
                mean_FRET_2CDE(i) = 110 - 100*(sum(N_phot_D(bin==i).*E_D(bin==i))./sum(N_phot_D(bin==i)) +...
                    sum(N_phot_A(bin==i).*E_A(bin==i))./sum(N_phot_A(bin==i)));
                mean_FRET_2CDE_naive(i) = mean(FRET_2CDE(bin == i));
            end
        end
        Progress(0.1,h.Progress_Axes,h.Progress_Text,'Simulating FRET 2CDE...');
        [E_sim,FRET_2CDE_sim,mean_FRET_2CDE_sim] = kinetic_consistency_check('FRET_2CDE',UserValues.BurstBrowser.Settings.BVA_DynamicStates,rate_matrix,R_states,sigmaR_states);
        [H,x,y] = histcounts2(FRET_2CDE,E,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[0,75],'YBinLimits',[-0.1,1.2]);
        H = H./max(H(:));
        Progress(0.5,h.Progress_Axes,h.Progress_Text,'Simulating FRET 2CDE...');
        [H_sim,x_sim,y_sim] = histcounts2(FRET_2CDE_sim,E_sim',UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[0,75],'YBinLimits',[-0.1,1.2]);
        H_sim = H_sim./max(H_sim(:));
        if UserValues.BurstBrowser.Settings.BVA_ModelComparison == true
            [E_static,FRET_2CDE_static,mean_FRET_2CDE_static] = kinetic_consistency_check('FRET_2CDE',UserValues.BurstBrowser.Settings.BVA_StaticStates,rate_matrix_static,R_states_static,sigmaR_states_static);
            Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
            %% plot smoothed dynamic FRET line
            [H_static,x_static,y_static] = histcounts2(FRET_2CDE_static,E_static',UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[0,75],'YBinLimits',[-0.1,1.2]);
            H_static = H_static./max(H_static(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;
            figure('Color',[1,1,1],'Position',[100,100,600,600]); hold on;
            ax = gca;
            ax.CLimMode = 'auto';
            ax.CLim(1) = 0;
            ax.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;
            xlabel('FRET Efficiency');
            ylabel('FRET 2CDE');
            set(gca,'Color',[1,1,1],'FontSize',24,'LineWidth',2,'Box','on','XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');
            plot_ContourPatches(ax,H',y,x,UserValues.BurstBrowser.Display.ColorLine1);
            plot_ContourPatches(ax,H_sim',y_sim,x_sim,UserValues.BurstBrowser.Display.ColorLine2);
            plot_ContourPatches(ax,H_static',y_static,x_static,UserValues.BurstBrowser.Display.ColorLine3);
            %%% plot averaged FRET-2CDE
            ax.XLim = [-0.1,1.1];
            xlim = ax.XLim;
            ylim = ax.YLim;
            patch(ax,[xlim(1),xlim(2),xlim(2),xlim(1)],[ylim(1),ylim(1),ylim(2),ylim(2)],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none','HandleVisibility','off');
            plot([-0.1,1.1]',[10,10]','Color',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2);
            plot(bin_centers',mean_FRET_2CDE_naive,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(bin_centers',mean_FRET_2CDE_sim,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
            plot(bin_centers',mean_FRET_2CDE_static,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine3);
            %% Calculate sum squared residuals
            w_res_dyn = (mean_FRET_2CDE_naive-mean_FRET_2CDE_sim);
            w_res_dyn(isnan(w_res_dyn)) = 0;
            SSR_dyn_legend = ['Dynamic SSR =' ' ' sprintf('%1.0e',round(sum(w_res_dyn.^2),1,'significant'))];
            w_res_stat = (mean_FRET_2CDE_naive-mean_FRET_2CDE_static);
            w_res_stat(isnan(w_res_stat)) = 0;
            SSR_stat_legend = ['Static SSR =' ' ' sprintf('%1.0e',round(sum(w_res_stat.^2),1,'significant'))];
            legend('Experimental Data',SSR_dyn_legend,SSR_stat_legend,'Location','northeast');
%             scatter(bin_centers,mean_FRET_2CDE_naive,100,'^','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3);
%         scatter(bin_centers,mean_FRET_2CDE_static,100,'^','filled','MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1);
        else
            Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
            figure('Color',[1,1,1],'Position',[100,100,600,600]); hold on;
            ax = gca;
            ax.CLimMode = 'auto';
            ax.CLim(1) = 0;
            ax.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;
            ax.XLim = [-0.1,1.1];
            ax.YLim = [0,50];
            xlim = ax.XLim;
            ylim = ax.YLim;
            xlabel('FRET Efficiency');
            ylabel('FRET 2CDE');
            set(gca,'Color',[1,1,1],'FontSize',24,'LineWidth',2,'Box','on','XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');
            plot_ContourPatches(ax,H',x,y,UserValues.BurstBrowser.Display.ColorLine1);
            plot_ContourPatches(ax,H_sim',x_sim,y_sim,UserValues.BurstBrowser.Display.ColorLine2);
            patch(ax,[xlim(1),xlim(2),xlim(2),xlim(1)],[ylim(1),ylim(1),ylim(2),ylim(2)],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none','HandleVisibility','off');
            plot(bin_centers',mean_FRET_2CDE_naive,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(bin_centers',mean_FRET_2CDE_sim,'-d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
        end
end
Progress(1,h.Progress_Axes,h.Progress_Text,'Done');
set(0,faculty);
end

function plot_main(hfig,x_data,y_data,H_data,E_data,sSelected_data,color)
global UserValues
switch UserValues.BurstBrowser.Display.PlotType
    case 'Contour'
        contourf(x_data(1:end-1),y_data(1:end-1),H_data', ...
            'LevelList',max(H_data(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100, ...
            1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'EdgeColor','none');
        axis('xy')
        caxis([0 max(H_data(:))*UserValues.BurstBrowser.Display.PlotCutoff/100]);
    case 'Image'       
        Alpha = H_data./max(max(H_data)) > UserValues.BurstBrowser.Display.ImageOffset/100;
        imagesc(x_data(1:end-1),y_data(1:end-1),H_data','AlphaData',Alpha');
        axis('xy');
        caxis([UserValues.BurstBrowser.Display.ImageOffset/100 max(H_data(:))*UserValues.BurstBrowser.Display.PlotCutoff/100]);
    case 'Scatter'
        scatter(E_data,sSelected_data,'.','CData',color,'SizeData',UserValues.BurstBrowser.Display.MarkerSize,'HandleVisibility','on');
    case 'Hex'
        switch UserValues.BurstBrowser.Settings.Dynamic_Analysis_Method
            case 1 % BVA
                hexscatter(E_data,sSelected_data,'xlim',[0 1],'ylim',[0 0.55],...
                    'res',UserValues.BurstBrowser.Display.NumberOfBinsX);
            case 2 %EvsTau
                hexscatter(sSelected_data,E_data,'xlim',[0 1.1],'ylim',[-0.1 1.1],...
                    'res',UserValues.BurstBrowser.Display.NumberOfBinsX);
        end
end
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
end



function plot_marignal_1D_hist(axmain,x_data,y_data,face_alpha,color,ffontsize)
global UserValues
% histcounts2(,sSelected,UserValues.BurstBrowser.Display.NumberOfBinsX);
% marginal 1D histograms
subplot('Position',[0.7 0.11 0.24 0.6])
axright = gca;
subplot('Position',[0.1 0.71 0.6 0.24])
axtop = gca;

if UserValues.BurstBrowser.Settings.Dynamic_Analysis_Method == 1
    histogram(axright,y_data,linspace(0,0.55,UserValues.BurstBrowser.Display.NumberOfBinsY+1),'orientation','horizontal',...
        'EdgeColor',color,'FaceColor',color,'FaceAlpha',face_alpha,'LineWidth',1);
else
    histogram(axright,y_data,linspace(-0.1,1.1,UserValues.BurstBrowser.Display.NumberOfBinsY+1),'orientation','horizontal',...
        'EdgeColor',color,'FaceColor',color,'FaceAlpha',face_alpha,'LineWidth',1);
end
axright.NextPlot = 'add';
axtop.NextPlot = 'add';

axright.YLim = axmain.YLim;
axright.XTick = linspace(axright.XLim(1),axright.XLim(2),9);
axright.XTick(:,[1:2,4:6,8:9]) = [];
axright.XTickLabel = [];
axright.YTickLabel = [];

axformat = axes('Position',axright.Position,'Color','none');
axformat.XLim = axright.XLim;
axformat.YAxisLocation = 'Right';
axformat.YLim = axmain.YLim;
axformat.YTick = axmain.YTick;
axformat.YTickLabel = axmain.YTickLabel;
axformat.XTick = [];
grid(axformat,'off');
axformat.XLabel.String = 'counts';
axformat.FontSize = ffontsize;
axformat.FontName = 'Arial';

% top margin 1D histogram
if UserValues.BurstBrowser.Settings.Dynamic_Analysis_Method == 1
    histogram(axtop,x_data,linspace(0,1,UserValues.BurstBrowser.Display.NumberOfBinsX+1),...
        'EdgeColor',color,'FaceColor',color,'FaceAlpha',face_alpha,'LineWidth',1);
else
    histogram(axtop,x_data,linspace(0,1.1,UserValues.BurstBrowser.Display.NumberOfBinsX+1),...
        'EdgeColor',color,'FaceColor',color,'FaceAlpha',face_alpha,'LineWidth',1);
end
axtop.XLim = axmain.XLim;
axtop.YTick = linspace(axtop.YLim(1),axtop.YLim(2),9);
axtop.YTick(:,[1:2,4:6,8:9]) = [];
axtop.YTickLabel = [];
axtop.XTickLabel = [];

axformat = axes('Position',axtop.Position,'Color','none');
axformat.YLim = axright.YLim;
axformat.XAxisLocation = 'top';
axformat.XLim = axmain.XLim;
axformat.XTick = axmain.XTick;
axformat.XTickLabel = axmain.XTickLabel;
axformat.YTick = [];
grid(axformat,'off');
axformat.YLabel.String = 'counts';
axformat.FontSize = ffontsize;
axformat.FontName = 'Arial';
end