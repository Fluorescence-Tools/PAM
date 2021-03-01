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

    
%%% figure and plot parameters
fwidth = 700;
fheight = 700;
ffontsize = 24;
if ~ismac
    ffontsize = ffontsize*0.72;
end
fcenterPlotPos = [0.1 0.11 0.6 0.6];
%%% Burst per bin threshold
min_bursts_per_bin = UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA;
n = UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA;
Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating...');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Get Model 1 parameters %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                rate_matrix_static = [                                          NaN,    str2double(h.state2st_amplitude_edit.String);
                                       str2double(h.state1st_amplitude_edit.String),                                             NaN]...
                                       *1000; %%% rates in Hz
                R_states_static = [str2double(h.Rstate1st_edit.String),str2double(h.Rstate2st_edit.String)];
                sigmaR_states_static = [str2double(h.Rsigma1st_edit.String),str2double(h.Rsigma2st_edit.String)];
            case 3
                rate_matrix_static = [                                          NaN, str2double(h.state2st_amplitude_edit.String), str2double(h.state3st_amplitude_edit.String);
                                       str2double(h.state1st_amplitude_edit.String),                                          NaN, str2double(h.state3st_amplitude_edit.String);
                                       str2double(h.state1st_amplitude_edit.String), str2double(h.state2st_amplitude_edit.String),                                         NaN]...
                                       *1000; %%% rates in Hz
                R_states_static = [str2double(h.Rstate1st_edit.String),str2double(h.Rstate2st_edit.String),str2double(h.Rstate3st_edit.String)];
                sigmaR_states_static = [str2double(h.Rsigma1st_edit.String),str2double(h.Rsigma2st_edit.String),str2double(h.Rsigma3st_edit.String)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Get Model 2 parameters %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch UserValues.BurstBrowser.Settings.BVA_DynamicStates_Model2
            case 2
                rate_matrix_Model2 = 1000*cell2mat(h.KineticRates_table2_Model2.Data); %%% rates in Hz
                R_states_Model2 = [str2double(h.Rstate1_edit_Model2.String),str2double(h.Rstate2_edit_Model2.String)];
                sigmaR_states_Model2 = [str2double(h.Rsigma1_edit_Model2.String),str2double(h.Rsigma2_edit_Model2.String)];
            case 3
                rate_matrix_Model2 = 1000*cell2mat(h.KineticRates_table3_Model2.Data); %%% rates in Hz
                R_states_Model2 = [str2double(h.Rstate1_edit_Model2.String),str2double(h.Rstate2_edit_Model2.String),str2double(h.Rstate3_edit_Model2.String)];
                sigmaR_states_Model2 = [str2double(h.Rsigma1_edit_Model2.String),str2double(h.Rsigma2_edit_Model2.String),str2double(h.Rsigma3_edit_Model2.String)];
end
                
switch UserValues.BurstBrowser.Settings.BVA_StaticStates_Model2
            case 2
                rate_matrix_static_Model2 = [                                          NaN,    str2double(h.state2st_amplitude_edit_Model2.String);
                                       str2double(h.state1st_amplitude_edit_Model2.String),                                             NaN]...
                                       *1000; %%% rates in Hz
                R_states_static_Model2 = [str2double(h.Rstate1st_edit_Model2.String),str2double(h.Rstate2st_edit_Model2.String)];
                sigmaR_states_static_Model2 = [str2double(h.Rsigma1st_edit_Model2.String),str2double(h.Rsigma2st_edit_Model2.String)];
            case 3
                rate_matrix_static_Model2 = [                                          NaN, str2double(h.state2st_amplitude_edit_Model2.String), str2double(h.state3st_amplitude_edit_Model2.String);
                                       str2double(h.state1st_amplitude_edit_Model2.String),                                          NaN, str2double(h.state3st_amplitude_edit_Model2.String);
                                       str2double(h.state1st_amplitude_edit_Model2.String), str2double(h.state2st_amplitude_edit_Model2.String),                                         NaN]...
                                       *1000; %%% rates in Hz
                R_states_static_Model2 = [str2double(h.Rstate1st_edit_Model2.String),str2double(h.Rstate2st_edit_Model2.String),str2double(h.Rstate3st_edit_Model2.String)];
                sigmaR_states_static_Model2 = [str2double(h.Rsigma1st_edit_Model2.String),str2double(h.Rsigma2st_edit_Model2.String),str2double(h.Rsigma3st_edit_Model2.String)];
end

rate_matrix(isnan(rate_matrix)) = 0;
rate_matrix_Model2(isnan(rate_matrix_Model2)) = 0;
% rate_matrix_static(rate_matrix_static < 0.001) = 0.001;

%%%%%%%%%%%%%%%%%%%%%%
%%% Start Analysis %%%
%%%%%%%%%%%%%%%%%%%%%%
switch UserValues.BurstBrowser.Settings.Dynamic_Analysis_Method
    case 1
        %%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%% BVA %%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%
        [E,sSelected,sPerBin,BinCenters] = BVA_expData();
        
        Progress(0.5,h.Progress_Axes,h.Progress_Text,'Simulating Model 1...');
        %kinetic_consistency_check_2species_test
        %%% Simulate Model 1 %%%
        [E_sim,sSelected_sim,sPerBin_sim] = ...
            kinetic_consistency_check_2species('BVA',...
            UserValues.BurstBrowser.Settings.BVA_DynamicStates,...
            UserValues.BurstBrowser.Settings.BVA_StaticStates,...
            rate_matrix,R_states,sigmaR_states,...
            rate_matrix_static,R_states_static,sigmaR_states_static);

        % data for contour patches
        [H_real,x_real,y_real] = ...
            histcounts2(E,sSelected,...
            UserValues.BurstBrowser.Display.NumberOfBinsX); 
        [H_sim,x_sim,y_sim] = ...
            histcounts2(E_sim,sSelected_sim,...
            UserValues.BurstBrowser.Display.NumberOfBinsX);
        
        %% Calculate sum squared residuals (Model 1)
        sPerBin(sPerBin == 0) = NaN;
        sPerBin_sim(sPerBin_sim == 0) = NaN;
        w_res_dyn = (sPerBin-sPerBin_sim);
        w_res_dyn(isnan(w_res_dyn)) = 0;

        SSR_Model1_legend = ['Model 1' newline 'SSR:' ' ' sprintf('%.0e',round(sum(w_res_dyn.^2),1,'significant'))];
        switch UserValues.BurstBrowser.Settings.BVA_ModelComparison
            case 1            
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%% Compare two models to experimental data %%%%%%%
                %%%%%%%            and plot separately          %%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % simulate second model
                Progress(0.75,h.Progress_Axes,h.Progress_Text,'Simulating Model 2...');
                
                [E_sim_Model2,sSelected_sim_Model2,sPerBin_sim_Model2] = ...
                    kinetic_consistency_check_2species_test('BVA',...
                    UserValues.BurstBrowser.Settings.BVA_DynamicStates_Model2,...
                    UserValues.BurstBrowser.Settings.BVA_StaticStates_Model2,...
                    rate_matrix_Model2,R_states_Model2,sigmaR_states_Model2,...
                    rate_matrix_static_Model2,R_states_static_Model2,sigmaR_states_static_Model2);
            
                % data for contour patches
                [H_sim_Model2,x_sim_Model2,y_sim_Model2] = ...
                    histcounts2(E_sim_Model2,sSelected_sim_Model2,...
                    UserValues.BurstBrowser.Display.NumberOfBinsX);
                
                %% Calculate sum squared residuals (Model 2)
                sPerBin_sim_Model2(sPerBin_sim_Model2 == 0) = NaN;
                w_res_stat = (sPerBin-sPerBin_sim_Model2);
                w_res_stat(isnan(w_res_stat)) = 0;
                Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
                SSR_Model2_legend = ['Model 2' newline 'SSR:' ' ' sprintf('%.0e',round(sum(w_res_stat.^2),1,'significant'))];
                if UserValues.BurstBrowser.Settings.BVA_SeperatePlots % plot separately
                    legends = {{['EXP' newline 'Data'], ['Expected' newline 'STDEV']},...
                        {['SIM' newline 'Model 1'], ['Expected' newline 'STDEV']},...
                        {['SIM' newline 'Model 2'], ['Expected' newline 'STDEV']}};
                    maxYLim = [0 max([sSelected;sSelected_sim;sSelected_sim_Model2])+0.01];
                    for i=1:3 % loop over models for plotting
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
                            case 2 % simulated data Model 1
                                x_data = x_sim;
                                y_data = y_sim;
                                H_data = H_sim;
                                E_data = E_sim;
                                sSelected_data = sSelected_sim;
                                color = UserValues.BurstBrowser.Display.ColorLine2;
                            case 3 % simulated data Model 2
                                x_data = x_sim_Model2;
                                y_data = y_sim_Model2;
                                H_data = H_sim_Model2;
                                E_data = E_sim_Model2;
                                sSelected_data = sSelected_sim_Model2;
                                color = UserValues.BurstBrowser.Display.ColorLine3;
                        end
                        plot_main(hfig,x_data,y_data,H_data,E_data,sSelected_data,color)
                        ax.NextPlot = 'add';
                        ax.XLabel.String = 'Proximity Ratio, E*';
                        ax.YLabel.String = 'STDEV of E*, s';
                        ax.YLim = maxYLim;
                        ax.XLim = [0 1];
                        ax.YLim = [0 0.5];
                        ax.Layer = 'bottom';
                        grid(ax,'on');
                        ax.FontSize = ffontsize;
                        ax.Box = on;
                        ax.FontName = 'Arial';
                        ax.LineWidth = 2;
                        ax.Color = [1 1 1];
                        ax.YColor = [0 0 0];
                        ax.XColor = [0 0 0];
                        
                        % Expected standard deviation
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
                        
                        % plot marginal histograms 
                        face_alpha = 1;
                        plot_marignal_1D_hist(ax,E_data,sSelected_data,face_alpha,color,ffontsize,0)
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
                else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%% Plot two models & exp data in one figure %%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
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
                    ax.YLim = [0 0.5];
%                     ax.GridAlpha = 0.35;
                    grid(ax,'on');
                    ax.FontSize = ffontsize;
                    ax.Box = on;
                    ax.FontName = 'Arial';
                    ax.Color = [1 1 1];
                    ax.LineWidth = 2;
                    ax.YColor = [0 0 0];
                    ax.XColor = [0 0 0];
                    
                    plot_ContourPatches(ax,H_real,x_real,y_real,UserValues.BurstBrowser.Display.ColorLine1)
                    plot_ContourPatches(ax,H_sim,x_sim,y_sim,UserValues.BurstBrowser.Display.ColorLine2)
                    plot_ContourPatches(ax,H_sim_Model2,x_sim_Model2,y_sim_Model2,UserValues.BurstBrowser.Display.ColorLine3)
                    patch(ax,[0.01 0.99 0.99 0.01],[0.01 0.01 ax.YLim(2)-0.01 ax.YLim(2)-0.01],'w','FaceAlpha',0.5,'edgecolor','none','HandleVisibility','off');
                    plot(BinCenters',sPerBin,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
                    plot(BinCenters',sPerBin_sim,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
                    plot(BinCenters',sPerBin_sim_Model2,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine3);
                    
                    lgd = legend(ax,'EXP Data',SSR_Model1_legend,SSR_Model2_legend,'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                    lgd.FontSize = ffontsize*0.95;
                    face_alpha = 0.8;
                    plot_marignal_1D_hist(ax,E,sSelected,face_alpha,UserValues.BurstBrowser.Display.ColorLine1,ffontsize,0)
                    plot_marignal_1D_hist(ax,E_sim,sSelected_sim,face_alpha,UserValues.BurstBrowser.Display.ColorLine2,ffontsize,1)
                    plot_marignal_1D_hist(ax,E_sim_Model2,sSelected_sim_Model2,face_alpha,UserValues.BurstBrowser.Display.ColorLine3,ffontsize,1)
                    
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
            case 0
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%% Only compare dynamic model to experimental data %%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
                if UserValues.BurstBrowser.Settings.BVA_SeperatePlots
                   legends = {{['EXP' newline 'Data'], ['Expected' newline 'STDEV']},...
                        {['SIM' newline 'Model 1'], ['Expected' newline 'STDEV']}};
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
                        ax.YLim = [0 0.5];
                        ax.Layer = 'bottom';
                        grid(ax,'on');
                        ax.FontSize = ffontsize;
                        ax.Box = on;
                        ax.FontName = 'Arial';
                        ax.LineWidth = 2;
                        ax.Color = [1 1 1];
                        ax.YColor = [0 0 0];
                        ax.XColor = [0 0 0];
                        
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
                        plot_marignal_1D_hist(ax,E_data,sSelected_data,face_alpha,color,ffontsize,0);
                        
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
                else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%% Plot model 1 & exp Data in one figure  %%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                    ax.YLim = [0 0.5];
                    ax.GridAlpha = 0.35;
                    grid(ax,'on');
                    ax.FontSize = ffontsize;
                    ax.Box = on;
                    ax.FontName = 'Arial';
                    ax.Color = [1 1 1];
                    ax.LineWidth = 2;
                    ax.YColor = [0 0 0];
                    ax.XColor = [0 0 0];

                    plot_ContourPatches(ax,H_real,x_real,y_real,UserValues.BurstBrowser.Display.ColorLine1)
                    plot_ContourPatches(ax,H_sim,x_sim,y_sim,UserValues.BurstBrowser.Display.ColorLine2)
                    patch(ax,[0.01 0.99 0.99 0.01],[0.01 0.01 ax.YLim(2)-0.01 ax.YLim(2)-0.01],'w','FaceAlpha',0.5,'edgecolor','none','HandleVisibility','off');
                    plot(BinCenters',sPerBin,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
                    plot(BinCenters',sPerBin_sim,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
                    
                    
                    face_alpha = 0.8;
                    plot_marignal_1D_hist(ax,E,sSelected,face_alpha,UserValues.BurstBrowser.Display.ColorLine1,ffontsize,0)
                    plot_marignal_1D_hist(ax,E_sim,sSelected_sim,face_alpha,UserValues.BurstBrowser.Display.ColorLine2,ffontsize,1)
                    %plot_BVA(E,sSelected,BinCenters,sPerBin)
                    % plot of expected STD
                    X_expectedSD = linspace(0,1,1000);
                    sigm = sqrt(X_expectedSD.*(1-X_expectedSD)./UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA);
                    plot(ax,X_expectedSD,sigm,'k','LineWidth',3);
                    lgd = legend(ax,['Binned' newline 'EXP Data'],SSR_Model1_legend,['Expected SD'],'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                    lgd.FontSize = ffontsize*0.8;
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
        [E,tauD,mean_tauD,BinCenters] = ETau_consistency();
        
        Progress(0.5,h.Progress_Axes,h.Progress_Text,'Simulating Model 1...');
        
        %%% Simulate Model 1 %%%
        [E_sim,tauD_sim,mean_tauD_sim] = ...
            kinetic_consistency_check_2species('Lifetime',...
            UserValues.BurstBrowser.Settings.BVA_DynamicStates,...
            UserValues.BurstBrowser.Settings.BVA_StaticStates,...
            rate_matrix,R_states,sigmaR_states,...
            rate_matrix_static,R_states_static,sigmaR_states_static);

        
        % data for contour patches
        [H_real,x_real,y_real] = ...
            histcounts2(tauD,E,...
            UserValues.BurstBrowser.Display.NumberOfBinsX,...
            'XBinLimits',[-0.1,1.1],'YBinLimits',[-0.1,1.1]);
        H_real = H_real./max(H_real(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;

        [H_sim,x_sim,y_sim] = ...
            histcounts2(tauD_sim,E_sim,...
            UserValues.BurstBrowser.Display.NumberOfBinsX,...
            'XBinLimits',[-0.1,1.1],'YBinLimits',[-0.1,1.1]);
        H_sim = H_sim./max(H_sim(:));
        %% Calculate sum squared residuals (Model 1)
        w_res_dyn = (mean_tauD-mean_tauD_sim);
        w_res_dyn(isnan(w_res_dyn)) = 0;
        
        SSR_Model1_legend = ['Model 1' newline 'SSR:' ' ' sprintf('%.0e',round(sum(w_res_dyn.^2),1,'significant'))];
%         maxXLim = [0 max([tauD;tauD_sim'])+0.01];
        switch UserValues.BurstBrowser.Settings.BVA_ModelComparison
            case 1
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%s%%%%%%%%%%%%%
                %%%%%%% Compare two models to experimental data %%%%%%%
                %%%%%%% and plot separately                     %%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % simulate second model
                Progress(0.75,h.Progress_Axes,h.Progress_Text,'Simulating Model 2...');

                [E_sim_Model2,tauD_sim_Model2,mean_tauD_sim_Model2,~] = ...
                    kinetic_consistency_check_2species('Lifetime',...
                    UserValues.BurstBrowser.Settings.BVA_DynamicStates_Model2,...
                    UserValues.BurstBrowser.Settings.BVA_StaticStates_Model2,...
                    rate_matrix_Model2,R_states_Model2,sigmaR_states_Model2,...
                    rate_matrix_static_Model2,R_states_static_Model2,sigmaR_states_static_Model2);

                [H_sim_Model2,x_sim_Model2,y_sim_Model2] = ...
                    histcounts2(tauD_sim_Model2,E_sim_Model2,...
                    UserValues.BurstBrowser.Display.NumberOfBinsX,...
                    'XBinLimits',[-0.1,1.1],'YBinLimits',[-0.1,1.1]);
                H_sim_Model2 = H_sim_Model2./max(H_sim_Model2(:));
                Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
                %% Calculate sum squared residuals (static)
                w_res_stat = (mean_tauD-mean_tauD_sim_Model2);
                w_res_stat(isnan(w_res_stat)) = 0;
                mean_tauD_sim_Model2(mean_tauD_sim_Model2 == 0) = NaN;
                SSR_Model2_legend = ['Model 2' newline 'SSR:' ' ' sprintf('%.0e',round(sum(w_res_stat.^2),1,'significant'))];
                if UserValues.BurstBrowser.Settings.BVA_SeperatePlots
                    legends = {{['EXP Data'],['Static' newline 'FRET line'],['Dynamic' newline 'FRET line']},...
                        {['Model 1'],['Static' newline 'FRET line'],['Dynamic' newline 'FRET line']},...
                        {'Model 2',['Static' newline 'FRET line'],['Dynamic' newline 'FRET line']}};
%                     maxXLim = [0 max([tauD;tauD_sim';tauD_static'])+0.01];
                    for i=1:3 % loop over models for plotting
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
                            case 2 % Model 1
                                x_data = x_sim; 
                                y_data = y_sim;
                                H_data = H_sim;
                                E_data = E_sim';
                                tauD_data = tauD_sim';
                                color = UserValues.BurstBrowser.Display.ColorLine2;
                            case 3 % Model 2
                                x_data = x_sim_Model2;
                                y_data = y_sim_Model2;
                                H_data = H_sim_Model2;
                                E_data = E_sim_Model2';
                                tauD_data = tauD_sim_Model2';
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
                        ax.FontSize = ffontsize;
                        ax.Box = on;
                        ax.FontName = 'Arial';
                        ax.Color = [1 1 1];
                        ax.LineWidth = 2;
                        
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
                        face_alpha = 0.8;
                        plot_marignal_1D_hist(ax,tauD_data,E_data,face_alpha,color,ffontsize,0)
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
                    grid(ax,'on');
                    ax.FontSize = ffontsize;
                    ax.Box = on;
                    ax.FontName = 'Arial';
                    ax.Color = [1 1 1];
                    ax.LineWidth = 2;
                    ax.YColor = [0 0 0];
                    ax.XColor = [0 0 0];
                    
                    plot_ContourPatches(ax,H_real,x_real,y_real,UserValues.BurstBrowser.Display.ColorLine1)
                    plot_ContourPatches(ax,H_sim,x_sim,y_sim,UserValues.BurstBrowser.Display.ColorLine2)
                    plot_ContourPatches(ax,H_sim_Model2,x_sim_Model2,y_sim_Model2,UserValues.BurstBrowser.Display.ColorLine3)
                    patch(ax,[-0.099 1.09 1.09 -0.099],[-0.099 -0.099 max(tauD)-0.01 max(tauD)-0.01],'w','FaceAlpha',0.5,'edgecolor','none','HandleVisibility','off');
                    plot(mean_tauD,BinCenters,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
                    plot(mean_tauD_sim,BinCenters,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
                    plot(mean_tauD_sim_Model2,BinCenters,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine3);
                    
                    %%% add FRET lines
                    plot(ax,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData,'-','LineWidth',3,'Color','k','HandleVisibility','on');
                    if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
                        plot(ax,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData,'--','LineWidth',3,'Color',UserValues.BurstBrowser.Display.ColorLine1,'HandleVisibility','on');
                    end
                    lgd = legend(ax,'EXP Data',SSR_Model1_legend,SSR_Model2_legend,'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                    lgd.FontSize = ffontsize * 0.95;
                    face_alpha = 0.8;
                    plot_marignal_1D_hist(ax,tauD,E,face_alpha,UserValues.BurstBrowser.Display.ColorLine1,ffontsize,0)
                    plot_marignal_1D_hist(ax,tauD_sim,E_sim,face_alpha,UserValues.BurstBrowser.Display.ColorLine2,ffontsize,1)
                    plot_marignal_1D_hist(ax,tauD_sim_Model2,E_sim_Model2,face_alpha,UserValues.BurstBrowser.Display.ColorLine3,ffontsize,1)
                end
            case 0 % compare only dynamic model to experimental data
                Progress(0.9,h.Progress_Axes,h.Progress_Text,'Plotting...');
                if UserValues.BurstBrowser.Settings.BVA_SeperatePlots
                   legends = {{['EXP Data'],['Static' newline 'FRET line'],['Dynamic' newline 'FRET line']},...
                        {['Model 1'],['Static' newline 'FRET line'],['Dynamic' newline 'FRET line']}};
                    for i=1:2 % loop over models for plotting
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
                            case 2 % Model 1
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
                        ax.FontSize = ffontsize;
                        ax.Box = on;
                        ax.FontName = 'Arial';
                        ax.LineWidth = 2;
                        ax.Color = [1 1 1];
                        ax.YColor = [0 0 0];
                        ax.XColor = [0 0 0];
                        
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
                        plot_marignal_1D_hist(ax,tauD_data,E_data,face_alpha,color,ffontsize,0);
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
                    grid(ax,'on');
                    ax.FontSize = ffontsize;
                    ax.Box = on;
                    ax.FontName = 'Arial';
                    ax.Color = [1 1 1];
                    ax.LineWidth = 2;
                    ax.YColor = [0 0 0];
                    ax.XColor = [0 0 0];
                    
                    plot_ContourPatches(ax,H_real,x_real,y_real,UserValues.BurstBrowser.Display.ColorLine1)
                    plot_ContourPatches(ax,H_sim,x_sim,y_sim,UserValues.BurstBrowser.Display.ColorLine2)
                    patch(ax,[-0.099 1.09 1.09 -0.099],[-0.099 -0.099 max(tauD)-0.01 max(tauD)-0.01],'w','FaceAlpha',0.5,'edgecolor','none','HandleVisibility','off');
                    plot(mean_tauD,BinCenters,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
                    plot(mean_tauD_sim,BinCenters,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                        'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
                   
                    %%% add FRET lines
                    plot(ax,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData,'-','LineWidth',3,'Color','k','HandleVisibility','on');
                    if UserValues.BurstBrowser.Settings.BVAdynFRETline == true
                        plot(ax,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData,'--','LineWidth',3,'Color',UserValues.BurstBrowser.Display.ColorLine1,'HandleVisibility','on');
                    end
                    
                    lgd = legend(ax,['EXP Data'],SSR_Model1_legend,'Position',[0.705 0.715 0.235 0.23535],'Box','on');
                    lgd.FontSize = ffontsize*0.95;
                    face_alpha = .8;
                    plot_marignal_1D_hist(ax,tauD,E,face_alpha,UserValues.BurstBrowser.Display.ColorLine1,ffontsize,0)
                    plot_marignal_1D_hist(ax,tauD_sim,E_sim,face_alpha,UserValues.BurstBrowser.Display.ColorLine2,ffontsize,1)
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
        bin_edges = linspace(0,1,bin_number+1); 
%         bin_centers = bin_edges(1:end-1) + min(diff(bin_edges))/2;
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
        [~,mean_g_dyn,mean_s_dyn,mi] = kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_DynamicStates,rate_matrix,R_states,sigmaR_states,1);
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
            [~,mean_g_static,mean_s_static,mi_static] = kinetic_consistency_check('Lifetime',UserValues.BurstBrowser.Settings.BVA_StaticStates,rate_matrix_static,R_states_static,sigmaR_states_static,0);
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
            plot(mean_g,mean_s,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(mean_g_dyn,mean_s_dyn,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
            plot(mean_g_static,mean_s_static,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine3);
            %% Calculate sum squared residuals
            w_res_dyn = (mean_s-mean_s_dyn);
            w_res_dyn(isnan(w_res_dyn)) = 0;
            SSR_dyn_legend = ['Dynamic SSR =' ' ' sprintf('%1.0e',round(sum(w_res_dyn.^2),1,'significant'))];
            w_res_stat = (mean_s-mean_s_static);
            w_res_stat(isnan(w_res_stat)) = 0;
            SSR_stat_legend = ['Static SSR =' ' ' sprintf('%1.0e',round(sum(w_res_stat.^2),1,'significant'))];
            
            add_universal_circle(ax,1);
            legend('EXP Data',SSR_dyn_legend,SSR_stat_legend,'Location','northeast');
        else
            patch(ax,[xlim(1),xlim(2),xlim(2),xlim(1)],[ylim(1),ylim(1),ylim(2),ylim(2)],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none','HandleVisibility','off');
            plot(mean_g,mean_s,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(mean_g_dyn,mean_s_dyn,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
            add_universal_circle(ax,1);
            legend('EXP Data','SIM Data','Location','northeast');
        end
%         g_circle = linspace(0,1,1000);
%         s_circle = sqrt(0.25-(g_circle-0.5).^2);
%         plot(ax,g_circle,s_circle,'-','LineWidth',2,'Color',[0,0,0],'Handlevisibility','off');
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
        [E_sim,FRET_2CDE_sim,mean_FRET_2CDE_sim] = kinetic_consistency_check('FRET_2CDE',UserValues.BurstBrowser.Settings.BVA_DynamicStates,rate_matrix,R_states,sigmaR_states,1);
        [H,x,y] = histcounts2(FRET_2CDE,E,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[0,75],'YBinLimits',[-0.1,1.2]);
        H = H./max(H(:));
        Progress(0.5,h.Progress_Axes,h.Progress_Text,'Simulating FRET 2CDE...');
        [H_sim,x_sim,y_sim] = histcounts2(FRET_2CDE_sim,E_sim',UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[0,75],'YBinLimits',[-0.1,1.2]);
        H_sim = H_sim./max(H_sim(:));
        if UserValues.BurstBrowser.Settings.BVA_ModelComparison == true
            [E_static,FRET_2CDE_static,mean_FRET_2CDE_static] = kinetic_consistency_check('FRET_2CDE',UserValues.BurstBrowser.Settings.BVA_StaticStates,rate_matrix_static,R_states_static,sigmaR_states_static,0);
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
            plot(bin_centers',mean_FRET_2CDE_naive,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(bin_centers',mean_FRET_2CDE_sim,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
            plot(bin_centers',mean_FRET_2CDE_static,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine3);
            %% Calculate sum squared residuals
            w_res_dyn = (mean_FRET_2CDE_naive-mean_FRET_2CDE_sim);
            w_res_dyn(isnan(w_res_dyn)) = 0;
            SSR_dyn_legend = ['Dynamic SSR =' ' ' sprintf('%1.0e',round(sum(w_res_dyn.^2),1,'significant'))];
            w_res_stat = (mean_FRET_2CDE_naive-mean_FRET_2CDE_static);
            w_res_stat(isnan(w_res_stat)) = 0;
            SSR_stat_legend = ['Static SSR =' ' ' sprintf('%1.0e',round(sum(w_res_stat.^2),1,'significant'))];
            legend('EXP Data',SSR_dyn_legend,SSR_stat_legend,'Location','northeast');
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
            plot(bin_centers',mean_FRET_2CDE_naive,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
            plot(bin_centers',mean_FRET_2CDE_sim,'d','MarkerSize',12,'MarkerEdgeColor','none',...
                'MarkerFaceColor',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine2);
        end
end
Progress(1,h.Progress_Axes,h.Progress_Text,'Done');
if ~isempty(BurstMeta.ReportFile)
    %%% a report file exists, add figure to it
    report_generator([],[],2,h);
end
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



function plot_marignal_1D_hist(axmain,x_data,y_data,face_alpha,color,ffontsize, isfit)
global UserValues
% histcounts2(,sSelected,UserValues.BurstBrowser.Display.NumberOfBinsX);
% marginal 1D histograms
face_alpha = 1;
subplot('Position',[0.705 0.11 0.235 0.6])
axright = gca;
subplot('Position',[0.1 0.715 0.6 0.235])
axtop = gca;
% view(axright,90,-90)
switch UserValues.BurstBrowser.Settings.Dynamic_Analysis_Method
    case 1
        if ~isfit
            histogram(axright,y_data,linspace(0,0.5,UserValues.BurstBrowser.Display.NumberOfBinsY+1),...
                'EdgeColor','none','FaceColor',color,'FaceAlpha',face_alpha,'LineWidth',1);
            view(axright,90,-90)
            axright.XLim = axmain.YLim;
            axright.XTick = linspace(axright.XLim(1),axright.XLim(2),6);
        else
            [ycounts, yedges] = histcounts(y_data, linspace(0,0.5,UserValues.BurstBrowser.Display.NumberOfBinsY+1));
            stairs(axright,yedges,[ycounts ycounts(end)], 'Color',color,'LineStyle','-','LineWidth',3);
        end
    case 2
        if ~isfit
            histogram(axright,y_data,linspace(-0.1,1.1,UserValues.BurstBrowser.Display.NumberOfBinsY+1),...
                'EdgeColor','none','FaceColor',color,'FaceAlpha',face_alpha,'LineWidth',1);
            view(axright,90,-90)
            axright.XLim = axmain.YLim;
            axright.XTick = linspace(0,1,6);
        else
            [ycounts, yedges] = histcounts(y_data, linspace(-0.1,1.1,UserValues.BurstBrowser.Display.NumberOfBinsY+1));
            stairs(axright,yedges,[ycounts ycounts(end)], 'Color',color,'LineStyle','-','LineWidth',3);
        end
end
axright.NextPlot = 'add';
% axright.YLim = axright.YLim / max(axright.YLim);
axright.YTick = linspace(axright.YLim(1),axright.YLim(2),9);
% axright.XTick(:,[1:2,4:6,8:9]) = [];
axright.YTick(:,[1:2,4:6,8:9]) = [];
axright.XTickLabel = [];
axright.YTickLabel = [];
axright.LineWidth = 2;
axright.Box = 'on';
% axright.Layer = 'top';
axright.Color = [1 1 1];
grid(axright,'on');

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
axformat.LineWidth = 2;
axformat.YColor = [0 0 0];
axformat.XColor = [0 0 0];
axformat.Layer = 'top';

% top margin 1D histogram
switch UserValues.BurstBrowser.Settings.Dynamic_Analysis_Method
    case 1
        if ~isfit
            histogram(axtop,x_data,linspace(0,1,UserValues.BurstBrowser.Display.NumberOfBinsX+1),...
                'EdgeColor','none','FaceColor',color,'FaceAlpha',face_alpha,'LineWidth',1);
        else
            [xcounts, xedges] = histcounts(x_data, linspace(0,1,UserValues.BurstBrowser.Display.NumberOfBinsX+1));
            stairs(axtop,xedges,[xcounts xcounts(end)], 'Color',color,'LineStyle','-','LineWidth',3);
        end
    case 2
        if ~isfit
            histogram(axtop,x_data,linspace(0,1.1,UserValues.BurstBrowser.Display.NumberOfBinsX+1),...
                'EdgeColor','none','FaceColor',color,'FaceAlpha',face_alpha,'LineWidth',1);
        else
            [xcounts, xedges] = histcounts(x_data, linspace(0,1.1,UserValues.BurstBrowser.Display.NumberOfBinsX+1));
            stairs(axtop,xedges,[xcounts xcounts(end)], 'Color',color,'LineStyle','-','LineWidth',3);
        end
end
axtop.NextPlot = 'add';
axtop.XLim = axmain.XLim;
axtop.YTick = linspace(axtop.YLim(1),axtop.YLim(2),9);
axtop.YTick(:,[1:2,4:6,8:9]) = [];
axtop.YTickLabel = [];
if length(axtop.XTick) > 10
    axtop.XTick(:,[2,4,6,8,10]) = [];
end
axtop.XTickLabel = [];
axtop.LineWidth = 2;
axtop.Box = 'on';
% axtop.Layer = 'top';
axtop.Color = [1 1 1];
grid(axtop,'on')

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
axformat.LineWidth = 2;
axformat.YColor = [0 0 0];
axformat.XColor = [0 0 0];
axformat.Layer = 'top';
end