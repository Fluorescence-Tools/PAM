function PDAFit(~,~)
% PDAFit Global Analysis of PDA data
%
%      To use the program, simply call PDAFit at command line.
%
%      The PDAData structure contains original experimental data and a
%      number of parameters exported from BurstBrowser (gamma,
%      crosstalk, direct excitation, background, lifetime, anisotropy...).
%
%      Saving PDA project saves the above back into the PDA file.
%      When data is saved in the global PDA program, the fit parameters obtained
%      after fitting are also saved back into the file.
%
%      The h structure contains the user interface.
%
%      The PDAMeta structure contains all metadata generated during program usage
%
%   2019 - FAB Lab Munich - Don C. Lamb

%%% TO DO:
%%% Implement donor only for MLE and MC fitting

global UserValues PDAMeta PDAData

h.GlobalPDAFit=findobj('Tag','GlobalPDAFit');

addpath(genpath(['.' filesep 'functions']));

LSUserValues(0);
Look=UserValues.Look;

if isempty(h.GlobalPDAFit)
    %% Disables uitabgroup warning
    warning('off','MATLAB:uitabgroup:OldVersion');
    warning('off','MATLAB:ui:javaframe:PropertyToBeRemoved');
    %% Define main window
    h.GlobalPDAFit = figure(...
        'Units','normalized',...
        'Name','GlobalPDAFit',...
        'NumberTitle','off',...
        'MenuBar','none',...
        'defaultUicontrolFontName',Look.Font,...
        'defaultAxesFontName',Look.Font,...
        'defaultTextFontName',Look.Font,...
        'OuterPosition',[0.05 0.05 0.9 0.9],...
        'UserData',[],...
        'Visible','on',...
        'Tag','GlobalPDAFit',...
        'Toolbar','figure',...
        'CloseRequestFcn',@CloseWindow);
    
    whitebg(h.GlobalPDAFit, Look.Axes);
    set(h.GlobalPDAFit,'Color',Look.Back);
    %%% Remove unneeded items from toolbar
    toolbar = findall(h.GlobalPDAFit,'Type','uitoolbar');
    toolbar_items = findall(toolbar);
    if verLessThan('matlab','9.5') %%% toolbar behavior changed in MATLAB 2018b
        delete(toolbar_items([2:7 9 13:17]));
    else %%% 2018b and upward
        %%% just remove the tool bar since the options are now in the axis
        %%% (e.g. axis zoom etc)
        delete(toolbar_items);
    end
    %% Menubar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % File Menu
    h.Menu.File = uimenu(...
        'Parent',h.GlobalPDAFit,...
        'Label','File',...
        'Tag','File',...
        'Enable','on');
    h.Menu.Load = uimenu(...
        'Parent',h.Menu.File,...
        'Label','Load File(s)...',...
        'Callback',{@Load_PDA, 1},...
        'Tag','Load');
    h.Menu.Add = uimenu(...
        'Parent',h.Menu.File,...
        'Label','Add File(s)...',...
        'Callback',{@Load_PDA, 2},...
        'enable','off',...
        'Tag','Add');
    h.Menu.Save = uimenu(...
        'Parent',h.Menu.File,...
        'Label','Save to File(s)',...
        'Callback',@Save_PDA,...
        'enable','off',...
        'Tag','Save');
    h.Menu.Export = uimenu(...
        'Parent',h.Menu.File,...
        'Label','Export Figure(s), Figure and Table Data',...
        'Callback',@Export_Figure,...
        'Tag','Export'); 
    h.Menu.Params = uimenu(...
        'Parent',h.Menu.File,...
        'Label','Reload Parameters',...
        'Callback',{@Update_ParamTable, 2},...
        'Tag','Params');
    h.Menu.FitParams = uimenu(...
        'Parent',h.Menu.File,...
        'Label','Reload Fit Parameters',...
        'Callback',{@Update_FitTable, 2},...
        'Tag','Params');
    %%% Fit Menu
    h.Menu.Fit = uimenu(...
        'Parent',h.GlobalPDAFit,...
        'Label','Fit');
    h.Menu.ViewFit = uimenu(...
        'Parent',h.Menu.Fit,...
        'Tag','ViewFit',...
        'Label','View',...
        'Callback',@Start_PDA_Fit);
    h.Menu.StartFit = uimenu(...
        'Parent',h.Menu.Fit,...
        'Tag','StartFit',...
        'Label','Start',...
        'Callback',@Start_PDA_Fit);
    h.Menu.StopFit = uimenu(...
        'Parent',h.Menu.Fit,...
        'Tag','StopFit',...
        'Label','Stop',...
        'Callback',@Stop_PDA_Fit);
    h.Menu.EstimateError = uimenu(...
        'Parent',h.Menu.Fit,...
        'Label','Estimate Error',...
        'Tag','EstimateError');
    h.Menu.EstimateErrorHessian = uimenu(...
        'Parent',h.Menu.EstimateError,...
        'Label','Estimate Error from Jacobian at solution',...
        'Tag','EstimateErrorHessian',...
        'Callback',@Start_PDA_Fit);
    h.Menu.EstimateErrorMCMC = uimenu(...
        'Parent',h.Menu.EstimateError,...
        'Label','Estimate Error from Markov-chain Monte Carlo',...
        'Tag','EstimateErrorMCMC',...
        'Callback',@Start_PDA_Fit);
    %%% Info Menu
%     h.Menu.Info = uimenu(...
%         'Parent',h.GlobalPDAFit,...
%         'Label','Info');
%     h.Menu.Todo = uimenu(...
%         'Parent',h.Menu.Info,...
%         'Tag','Todo',...
%         'Label','To do',...
%         'Callback', @Todolist);
%     h.Menu.Manual = uimenu(...
%         'Parent',h.Menu.Info,...
%         'Tag','Manual',...
%         'Label','Manual',...
%         'Callback', @Manual);
    
    %% Upper tabgroup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.Tabgroup_Up = uitabgroup(...
        'Parent',h.GlobalPDAFit,...
        'Tag','MainPlotTab',...
        'Units','normalized',...
        'Position',[0 0.2 1 0.8]);
    
    %% All tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.AllTab.Tab = uitab(...
        'Parent',h.Tabgroup_Up,...
        'Tag','Tab_All',...
        'Title','All');
    
    % Main Axes
    h.AllTab.Main_Panel = uibuttongroup(...
        'Parent',h.AllTab.Tab,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','Main_Panel_All');
    h.AllTab.Main_Axes = axes(...
        'Parent',h.AllTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.045 0.08 0.715 0.745],...
        'Box','on',...
        'Tag','Main_Axes_All',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XLim',[0 1],...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',Look.AxWidth,...
        'YLimMode','auto');
    xlabel('Proximity Ratio','Color',Look.Fore);
    ylabel('#','Color',Look.Fore);
    h.AllTab.Res_Axes = axes(...
        'Parent',h.AllTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.045 0.85 0.715 0.13],...
        'Box','on',...
        'Tag','Residuals_Axes_All',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XTickLabel','',...
        'XLim',[0 1],...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',Look.AxWidth,...
        'YLimMode','auto');
    ylabel('w_{res}','Color',Look.Fore);
    linkaxes([h.AllTab.Main_Axes,h.AllTab.Res_Axes],'x');
    
    %%% Progress Bar
    h.AllTab.Progress.Panel = uibuttongroup(...
        'Parent',h.AllTab.Main_Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0.78 0.94 0.21 0.04],...
        'Tag','Progress_Panel_All');
    h.AllTab.Progress.Axes = axes(...
        'Parent',h.AllTab.Progress.Panel,...
        'Tag','Progress_Axes_All',...
        'Units','normalized',...
        'Color',Look.Control,...
        'Position',[0 0 1 1]);
    h.AllTab.Progress.Axes.XTick=[];
    h.AllTab.Progress.Axes.YTick=[];
    h.AllTab.Progress.Text=text(...
        'Parent',h.AllTab.Progress.Axes,...
        'Tag','Progress_Text_All',...
        'Units','normalized',...
        'FontSize',12,...
        'FontWeight','bold',...
        'String','Nothing loaded',...
        'Interpreter','none',...
        'HorizontalAlignment','center',...
        'BackgroundColor','none',...
        'Color',Look.Fore,...
        'Position',[0.5 0.5]);
    
    h.AllTab.PlotTab = uitabgroup(...
        'Parent',h.AllTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.765,0.45,0.235,0.475],...
        'Tag','PlotTab_All'...
        );
    h.AllTab.BSD_Tab = uitab(...
        h.AllTab.PlotTab,...
        'Title','Photon count distribution',...
        'BackgroundColor',Look.Back);
    %%% Burst Size Distribution Plot
    h.AllTab.BSD_Axes = axes(...
        'Parent',h.AllTab.BSD_Tab,...
        'Units','normalized',...
        'Position',[0.15 0.175 0.80 0.765],...
        'Box','on',...
        'Tag','BSD_Axes_All',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XGrid','on',...
        'YGrid','on',...
        'YScale','log',...
        'GridAlpha',0.5,...
        'LineWidth',Look.AxWidth,...
        'YLimMode','auto',...
        'XLimMode','auto');
    xlabel('# Photons per Bin','Color',Look.Fore);
    ylabel('Occurrence','Color',Look.Fore);
    
    h.AllTab.ES_Tab = uitab(...
        h.AllTab.PlotTab,...
        'Title','E-S plot',...
        'BackgroundColor',Look.Back);
    %%% E-S scatter plot
    h.AllTab.ES_Axes = axes(...
        'Parent',h.AllTab.ES_Tab,...
        'Units','normalized',...
        'Position',[0.15 0.175 0.80 0.765],...
        'Box','on',...
        'Tag','BSD_Axes_All',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',Look.AxWidth,...
        'YLimMode','auto',...
        'XLimMode','auto');
    xlabel('E','Color',Look.Fore);
    ylabel('S','Color',Look.Fore);
    
    %%% distance Plot
    h.AllTab.Gauss_Axes = axes(...
        'Parent',h.AllTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.8 0.08 0.185 0.35],...
        'Box','on',...
        'Tag','Gauss_Axes_All',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',Look.AxWidth,...
        'YLimMode','auto',...
        'XLimMode','auto');
    xlabel('Distance [A]','Color',Look.Fore);
    ylabel('Probability','Color',Look.Fore);
    
    
    %% Single tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% main plot
    h.SingleTab.Tab = uitab(...
        'Parent',h.Tabgroup_Up,...
        'Tag','Tab_Single',...
        'Title','Single');
    h.SingleTab.Main_Panel = uibuttongroup(...
        'Parent',h.SingleTab.Tab,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','Main_Panel_Single');
    h.SingleTab.Main_Axes = axes(...
        'Parent',h.SingleTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.04 0.075 0.72 0.75],...
        'Box','on',...
        'Tag','Main_Axes_Single',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
                       'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'XLim',[0 1],...
        'LineWidth',Look.AxWidth,...
        'YLimMode','auto');
    xlabel('Proximity Ratio','Color',Look.Fore);
    ylabel('#','Color',Look.Fore);
    h.SingleTab.Res_Axes = axes(...
        'Parent',h.SingleTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.04 0.85 0.72 0.13],...
        'Box','on',...
        'Tag','Residuals_Axes_Single',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XTickLabel','',...
        'XLim',[0 1],...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',Look.AxWidth,...
        'YLimMode','auto');
    ylabel('w_{res}','Color',Look.Fore);
    linkaxes([h.SingleTab.Main_Axes,h.SingleTab.Res_Axes],'x');
    
    %%% Progress Bar
    h.SingleTab.Progress.Panel = uibuttongroup(...
        'Parent',h.SingleTab.Main_Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0.78 0.94 0.21 0.04],...
        'Tag','Progress_Panel_Single');
    h.SingleTab.Progress.Axes = axes(...
        'Parent',h.SingleTab.Progress.Panel,...
        'Tag','Progress_Axes_Single',...
        'Units','normalized',...
        'Color',Look.Control,...
        'Position',[0 0 1 1]);
    h.SingleTab.Progress.Axes.XTick=[]; 
    h.SingleTab.Progress.Axes.YTick=[];
    h.SingleTab.Progress.Text=text(...
        'Parent',h.SingleTab.Progress.Axes,...
        'Tag','Progress_Text_Single',...
        'Units','normalized',...
        'FontSize',12,...
        'FontWeight','bold',...
        'String','Nothing loaded',...
        'Interpreter','none',...
        'HorizontalAlignment','center',...
        'BackgroundColor','none',...
        'Color',Look.Fore,...
        'Position',[0.5 0.5]);
    
    h.SingleTab.PlotTab = uitabgroup(...
        'Parent',h.SingleTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.765,0.45,0.235,0.475],...
        'Tag','PlotTab_All'...
        );
    h.SingleTab.BSD_Tab = uitab(...
        h.SingleTab.PlotTab,...
        'Title','Photon count distribution',...
        'BackgroundColor',Look.Back);
    %%% Burst Size Distribution Plot
    h.SingleTab.BSD_Axes = axes(...
        'Parent',h.SingleTab.BSD_Tab,...
        'Units','normalized',...
        'Position',[0.15 0.175 0.80 0.765],...
        'Box','on',...
        'Tag','BSD_Axes_Single',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',Look.AxWidth,...
        'YLimMode','auto',...
        'XLimMode','auto');
    xlabel('# Photons per Bin','Color',Look.Fore);
    ylabel('Occurrence','Color',Look.Fore);
    
    h.SingleTab.ES_Tab = uitab(...
        h.SingleTab.PlotTab,...
        'Title','E-S plot',...
        'BackgroundColor',Look.Back);
    %%% E-S scatter plot
    h.SingleTab.ES_Axes = axes(...
        'Parent',h.SingleTab.ES_Tab,...
        'Units','normalized',...
        'Position',[0.15 0.175 0.80 0.765],...
        'Box','on',...
        'Tag','BSD_Axes_All',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',Look.AxWidth,...
        'YLimMode','auto',...
        'XLimMode','auto');
    xlabel('E','Color',Look.Fore);
    ylabel('S','Color',Look.Fore);
    
    %%% distance Plot
    h.SingleTab.Gauss_Axes = axes(...
        'Parent',h.SingleTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.8 0.11 0.185 0.325],...
        'Box','on',...
        'Tag','Gauss_Axes_Single',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',Look.AxWidth,...
        'YLimMode','auto',...
        'XLimMode','auto');
    xlabel('Distance [A]','Color',Look.Fore);
    ylabel('Probability','Color',Look.Fore);
    
    %%% Determines, which file to plot
    h.SingleTab.Popup = uicontrol(...
        'Parent',h.SingleTab.Main_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', [1 1 1],...
        'ForegroundColor', [0 0 0],...
        'Style','popupmenu',...
        'String',{'Nothing selected'},...
        'Value',1,...
        'Callback',{@Update_Plots,2},...
        'Position',[0.775 -0.05 0.22 0.1],...
        'Tag','Popup_Single');
    
  
    
    %% Bottom tabgroup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.Tabgroup_Down = uitabgroup(...
        'Parent',h.GlobalPDAFit,...
        'Tag','Params_Tab',...
        'Units','normalized',...
        'Position',[0 0 1 0.2]);
    
    %% Fit tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.FitTab_Menu = uicontextmenu;
    h.FitTab.UIContextMenu = h.FitTab_Menu;
    h.FitTab.Tab = uitab(...
        'Parent',h.Tabgroup_Down,...
        'Tag','Fit_Tab',...
        'Title','Fit',...
        'UIContextMenu',h.FitTab_Menu);
    h.FitTab.Panel = uibuttongroup(...
        'Parent',h.FitTab.Tab,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','Fit_Panel',...
        'UIContextMenu',h.FitTab_Menu);
    h.FitTab.Table = uitable(...
        'Parent',h.FitTab.Panel,...
        'Tag','Fit_Table',...
        'Units','normalized',...
        'ForegroundColor',Look.TableFore,...
        'BackgroundColor',[Look.Table1;Look.Table2],...
        'FontSize',12,...
        'Position',[0 0 .8 1],...
        'CellEditCallback',{@Update_FitTable,3},...
        'CellSelectionCallback',{@Update_FitTable,3},...        
        'UIContextMenu',h.FitTab_Menu);

        initial_rates = {1,false,false,1,false,false,1,false,false,1,false,false,1,false,false,1,false,false};
        lb =  {0,[],[],0,[],[],0,[],[],0,[],[],0,[],[],0,[],[]};
        ub =  {10,[],[],10,[],[],10,[],[],10,[],[],10,[],[],10,[],[]};
        data = [initial_rates;lb;ub];
%         initial_rates(1,1) = NaN;
%         initial_rates(2,2) = NaN;
%         initial_rates(3,3) = NaN;
%         data = cell(size(initial_rates,1),2*size(initial_rates,2));
%         for i = 1:size(initial_rates,2)
%             data(:,2*i-1) = num2cell(initial_rates(:,i));
%             data(:,2*i) = num2cell(false(size(initial_rates,1),1));
%         end
        columnnames = {'<HTML><b>k<sub>12</sub></b>','F','G',...
            '<HTML><b>k<sub>13</sub></b>','F','G',...
            '<HTML><b>k<sub>21</sub></b>','F','G',...
            '<HTML><b>k<sub>23</sub></b>','F','G',...
            '<HTML><b>k<sub>31</sub></b>','F','G',...
            '<HTML><b>k<sub>32</sub></b>','F','G'};%{'<HTML> 1 &rarr;','F','<HTML> 2 &rarr;','F','<HTML> 3 &rarr;','F'};
        rownames = [];%{'1','2','3'};
        columnwidth = {35,20,20,35,20,20,35,20,20,35,20,20,35,20,20,35,20,20};
        %columnformat = {'numeric','logical','logical','numeric','logical','logical','numeric','logical','logical','numeric','logical','logical','numeric','logical','logical','numeric','logical','logical'};
    h.KineticRates_table = uitable(...
        'Data',data,'ColumnName',columnnames,'RowName',rownames,...
        'ColumnWidth',columnwidth,...%'ColumnFormat',columnformat,...
        'ColumnEditable',true,...
        'Parent',h.FitTab.Panel,...
        'Tag','KineticRates_table',...
        'Units','normalized',...
        'ForegroundColor',Look.TableFore,...
        'BackgroundColor',[Look.Table1;Look.Table2],...
        'FontSize',12,...
        'Visible','on',...
        'Position',[0.69 0 .31 1],...
        'CellEditCallback',{@Update_FitTable,3},...
        'CellSelectionCallback',{@Update_FitTable,3},...        
        'UIContextMenu',h.FitTab_Menu);
    %%% get jobj for tables to synchronize the vertical scroll behavior
    h.jobj.FitTable_JScrollPane = findjobj(h.FitTab.Table);
    h.jobj.KineticRatesTable_JScrollPane = findjobj(h.KineticRates_table);
    set(h.jobj.FitTable_JScrollPane,...
        'AdjustmentValueChangedCallback',{@table_vertical_scroll_listener,h.jobj},...
        'MouseWheelMovedCallback',{@table_vertical_scroll_listener,h.jobj});
    set(h.jobj.KineticRatesTable_JScrollPane,...
        'AdjustmentValueChangedCallback',{@table_vertical_scroll_listener,h.jobj},...
        'MouseWheelMovedCallback',{@table_vertical_scroll_listener,h.jobj});
   
    h.Export_Clipboard = uimenu(...
        'Parent',h.FitTab_Menu,...
        'Label','Copy Results to Clipboard',...
        'Callback',{@PDAFitMenuCallback,1});
    
    h.Export_BB = uimenu(...
        'Parent',h.FitTab_Menu,...
        'Label','Copy Results to BurstBrowser',...
        'Callback',{@PDAFitMenuCallback,2});

    %% Parameters tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.ParametersTab.Tab = uitab(...
        'Parent',h.Tabgroup_Down,...
        'Tag','Parameters_Tab',...
        'Title','Parameters');
    h.ParametersTab.Panel = uibuttongroup(...
        'Parent',h.ParametersTab.Tab,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','Parameters_Panel');
    h.ParametersTab.Table = uitable(...
        'Parent',h.ParametersTab.Panel,...
        'Tag','Parameters_Panel',...
        'Units','normalized',...
        'ForegroundColor',Look.TableFore,...
        'BackgroundColor',[Look.Table1;Look.Table2],...
        'FontSize',12,...
        'Position',[0 0 1 1],...
        'CellEditCallback',{@Update_ParamTable,3},...
        'CellSelectionCallback',{@Update_ParamTable,3});
    
    %% Settings tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.SettingsTab.Tab = uitab(...
        'Parent',h.Tabgroup_Down,...
        'Tag','Settings_Tab',...
        'Title','Settings');
    h.SettingsTab.Panel = uibuttongroup(...
        'Parent',h.SettingsTab.Tab,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','SettingsPanel');
    % First column
    h.SettingsTab.NumberOfBins_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','Number of Bins',...
        'Position',[0.02 0.775 0.175 0.2],...
        'HorizontalAlignment','right',...
        'Tag','NumberOfBins_Text');
    h.SettingsTab.NumberOfBins_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String',UserValues.PDA.NoBins,...
        'Position',[0.2 0.825 0.05 0.15],...
        'Callback',{@Update_Plots,3,1},...
        'Tag','NumberOfBins_Edit');
    h.SettingsTab.XAxisUnit_Menu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', [1,1,1],...
        'ForegroundColor', [0,0,0],...
        'Value',1,...
        'Units','normalized',...
        'String',{'Proximity Ratio','FRET efficiency','log(FD/FA)','Distance'},...
        'TooltipString','<html>Choose the quantity to be used for the x-axis.<br>Proximity Ratio: Apparent FRET efficiency from uncorrected photon counts.<br>log(FD/FA): Decadic logarithm of the ratio of the donor and acceptor (FRET) photons from uncorrected photon counts.<br>FRET efficiency: Corrected FRET efficiency.<br>Distance: Distance in Angstrom calculated from the corrected FRET efficiency.</html>',...
        'FontSize',12,...
        'Callback',{@Update_Plots,3,1},...
        'Position',[0.255 0.825 0.14 0.15],...
        'Tag','XAxisUnit_Menu');
    h.SettingsTab.NumberOfPhotMin_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','Minimum Number of Photons per Bin',...
        'Position',[0.02 0.575 0.175 0.2],...
        'HorizontalAlignment','right',...
        'Tag','NumberOfPhotMin_Text');
    h.SettingsTab.NumberOfPhotMin_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String',UserValues.PDA.MinPhotons,...
        'Callback',{@Update_Plots,3,1},...
        'Position',[0.2 0.625 0.05 0.15],...
        'Tag','NumberOfPhotMin_Edit');
    h.SettingsTab.NumberOfPhotMax_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','Maximum Number of Photons per Bin',...
        'Position',[0.02 0.375 0.175 0.2],...
        'HorizontalAlignment','right',...
        'Tag','NumberOfPhotMax_Text');
    h.SettingsTab.NumberOfPhotMax_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String',UserValues.PDA.MaxPhotons,...
        'Callback',{@Update_Plots,3,1},...
        'Position',[0.2 0.425 0.05 0.15],...
        'Tag','NumberOfPhotMax_Edit');
    h.SettingsTab.ScaleNumberOfPhotons_Checkbox = uicontrol(...
        'Style','checkbox',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Value',UserValues.PDA.ScaleNumberOfPhotons,...
        'Units','normalized',...
        'String','Scale number of photons',...
        'TooltipString','<html>Scale the minimum and maximum number of photons with the time window size.<br>The thresholds are multiplied with the respective time window in milliseconds.</html>',...
        'FontSize',12,...
        'Callback',{@Update_Plots,3,1},...
        'Position',[0.255 0.625 0.14 0.15],...
        'Tag','ScaleNumberOfPhotons_Checkbox');
    h.SettingsTab.MainAxisLimits_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','X-Axis limits:',...
        'Position',[0.255 0.375 0.08 0.2],...
        'HorizontalAlignment','center',...
        'Tag','MainAxisLimits_Text');
    h.SettingsTab.MainAxisLimtsLow_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String',0,...
        'Position',[0.335 0.425 0.03 0.15],...
        'Callback',{@Update_Plots,3,1},...
        'Tag','MainAxisLimtsLow_Edit');
    h.SettingsTab.MainAxisLimtsHigh_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String',1,...
        'Position',[0.365 0.425 0.03 0.15],...
        'Callback',{@Update_Plots,3,1},...
        'Tag','MainAxisLimtsHigh_Edit');
    h.SettingsTab.NumberOfBinsE_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','Grid resolution for E',...
        'TooltipString','Higher increases fit accuracy, but makes fitting slower.',...
        'Position',[0.02 0.175 0.175 0.2],...
        'HorizontalAlignment','right',...
        'Tag','NumberOfBinsE_Text');
    h.SettingsTab.NumberOfBinsE_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'String',UserValues.PDA.GridRes,...
        'TooltipString','Higher increases fit accuracy, but makes fitting slower.',...
        'FontSize',12,...
        'Callback',{@Update_Plots,0,1},...
        'Position',[0.2 0.225 0.05 0.15],...
        'Tag','NumberOfBinsE_Edit');
    h.SettingsTab.NumberOfBinsT_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','Grid res. for dynamics',...
        'TooltipString','<html>Resolution of the state occupancy distribution for the evaluation of dynamics.<br>Higher increases fit accuracy, but makes fitting slower.',...
        'Position',[0.255 0.175 0.1 0.2],...
        'HorizontalAlignment','left',...
        'Tag','NumberOfBinsT_Text');
    h.SettingsTab.NumberOfBinsT_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'String',UserValues.PDA.GridRes_PofT,...
        'TooltipString','<html>Resolution of the state occupancy distribution for the evaluation of dynamics.<br>Higher increases fit accuracy, but makes fitting slower.',...
        'FontSize',12,...
        'Callback',{@Update_Plots,0,1},...
        'Position',[0.355 0.225 0.04 0.15],...
        'Tag','NumberOfBinsT_Edit');
    h.SettingsTab.StoichiometryThreshold_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','Stoichiometry threshold',...
        'Position',[0.02 -0.025 0.175 0.2],...
        'HorizontalAlignment','right',...
        'Tag','StoichiometryThreshold_Text');
    h.SettingsTab.StoichiometryThresholdLow_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String',UserValues.PDA.Smin,...
        'Position',[0.2 0.025 0.025 0.15],...
        'Callback',{@Update_Plots,3,1},...
        'Tag','StoichiometryThresholdLow_Edit');
    h.SettingsTab.StoichiometryThresholdHigh_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String',UserValues.PDA.Smax,...
        'Position',[0.225 0.025 0.025 0.15],...
        'Callback',{@Update_Plots,3,1},...
        'Tag','StoichiometryThresholdHigh_Edit');
    
    % third column
    h.SettingsTab.PDAMethod_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'String','PDA Method',...
        'FontSize',12,...
        'Position',[0.4 0.75 0.1 0.2],...
        'HorizontalAlignment','left',...
        'Tag','PDAMethod_Text');
    h.SettingsTab.PDAMethod_Popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor',[1 1 1],...
        'ForegroundColor',[0 0 0],...
        'Units','normalized',...
        'String',{'Histogram Library','MLE','MonteCarlo'},...
        'Value',1,...
        'FontSize',12,...
        'Position',[0.5 0.775 0.1 0.2],...
        'Tag','PDAMethod_Popupmenu');
    h.SettingsTab.FitMethod_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'String','Fit Method',...
        'FontSize',12,...
        'Position',[0.4 0.50 0.1 0.2],...
        'HorizontalAlignment','left',...
        'Tag','FitMethod_Text');
    h.SettingsTab.FitMethod_Popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', [1 1 1],...
        'ForegroundColor', [0 0 0],...
        'Units','normalized',...
        'String',{'Simplex','Gradient-based (lsqnonlin)','Gradient-based (fmincon)','Patternsearch','Gradient-based (global)','Simulated Annealing','Genetic Algorithm','Particle Swarm','Surrogate Optimization'},...
        'Value',1,...
        'FontSize',12,...
        'Position',[0.5 0.525 0.1 0.2],...
        'Tag','FitMethod_Popupmenu');
    h.SettingsTab.OverSampling_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String',sprintf('MonteCarlo Oversampling'),...
        'Position',[0.4 0.25 0.155 0.2],...
        'HorizontalAlignment','left',...
        'Tag','OverSampling_Text');
    h.SettingsTab.OverSampling_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'String','10',...
        'FontSize',12,...
        'Callback',[],...
        'Position',[0.555 0.275 0.05 0.2],...
        'Tag','OverSampling_Edit');
    h.SettingsTab.Chi2Method_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String',sprintf('Chi2 method'),...
        'Position',[0.4 0.025 0.1 0.2],...
        'HorizontalAlignment','left',...
        'Tag','Chi2Method_Text');
    h.SettingsTab.Chi2Method_Popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', [1 1 1],...
        'ForegroundColor', [0 0 0],...
        'Units','normalized',...
        'String',{'Poissonian','Gaussian'},...
        'FontSize',12,...
        'Callback',[],...
        'Value',1,...
        'Position',[0.5 0.025 0.1 0.2],...
        'Tag','Chi2Method_Edit');
     h.SettingsTab.DynamicModel = uicontrol(...
        'Parent',h.SettingsTab.Panel,...
        'Tag','DynamicModel',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Dynamic Model',...
        'Value',UserValues.PDA.Dynamic,...
        'TooltipString',sprintf('Only works for Histogram Library and Monte Carlo Approach!\n For two-state system, species 3 and onward will be treated as static.\n For three-state system, species 4 and 5 and onward will be treated as static.'),...
        'Callback',@Update_GUI,...
        'Position',[0.65 0.55 0.075 0.15]);
    h.SettingsTab.DynamicSystem = uicontrol(...
        'Parent',h.SettingsTab.Panel,...
        'Tag','DynamicModel',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', [1,1,1],...
        'ForegroundColor', [0,0,0],...
        'Style','popupmenu',...
        'String',{'Two-state system','Three-state system'},...
        'Value',UserValues.PDA.DynamicSystem,...
        'Callback',@Update_GUI,...
        'Position',[0.725 0.55 0.075 0.15]);
    h.SettingsTab.FixSigmaAtFractionOfR = uicontrol(...
        'Parent',h.SettingsTab.Panel,...
        'Tag','FixSigmaAtFractionOfR',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Fix Sigma at Fraction of R:',...
        'Tooltipstring', 'This parameter is optimized globally if multiple datasets are loaded.',...
        'Value',UserValues.PDA.FixSigmaAtFraction,...
        'Callback',@Update_GUI,...
        'Position',[0.65 0.75 0.15 0.2]);
    h.SettingsTab.SigmaAtFractionOfR_edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'String',UserValues.PDA.SigmaAtFractionOfR,...
        'Tooltipstring', 'If you want this parameter globally, globally link some random parameter like Donly',...
        'FontSize',12,...
        'Callback',{@Update_Plots,0},...
        'Position',[0.8 0.75 0.05 0.2],...
        'Enable','off',...
        'Tag','SigmaAtFractionOfR_edit');
    h.SettingsTab.FixSigmaAtFractionOfR_Fix = uicontrol(...
        'Style','checkbox',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Value',UserValues.PDA.FixSigmaAtFractionFix,...
        'FontSize',12,...
        'String','Fix?',...
        'Callback',[],...
        'Position',[0.85 0.75 0.1 0.2],...
        'Enable','off',...
        'Tag','FixSigmaAtFractionOfR_Fix');
    h.SettingsTab.FixStaticToDynamicSpecies = uicontrol(...
        'Parent',h.SettingsTab.Panel,...
        'Tag','FixSigmaAtFractionOfR',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Static/dynamic mixture',...
        'Tooltipstring', sprintf('Assumes that static species have the same center distance and width as dynamic species.'),...
        'Value',UserValues.PDA.FixStaticToDynamicSpecies,...
        'Callback',@Update_GUI,...
        'Position',[0.9 0.75 0.15 0.2]);
    h.SettingsTab.OuterBins_Fix = uicontrol(...
        'Style','checkbox',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Value',UserValues.PDA.IgnoreOuterBins,...
        'FontSize',12,...
        'String','ignore outer bins?',...
        'Tooltipstring', 'Ugnore outer proximity ratio histogram bins during fitting. Does not work for MLE fitting!',...
        'Callback',{@Update_Plots,3},...
        'Position',[0.8 0.3 0.2 0.15],...
        'Tag','OuterBins_Fix');
    h.SettingsTab.GaussAmp_Fix = uicontrol(...
        'Style','checkbox',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Value',0,...
        'FontSize',12,...
        'String','gauss amplitude',...
        'Tooltipstring', '(Unchecked: area / checked: amplitude) of the gaussian is the fraction of molecules in that state',...
        'Callback',{@Update_Plots,1},...
        'Position',[0.8 0.05 0.1 0.15],...
        'Tag','OuterBins_Fix');
    h.SettingsTab.Use_Brightness_Corr = uicontrol(...
        'Style','checkbox',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Value',0,...
        'enable','off',...
        'FontSize',12,...
        'String','Brightness Correction',...
        'Tooltipstring', '',...
        'Callback',{@Load_Brightness_Reference,1},...
        'ButtonDownFcn',{@Load_Brightness_Reference,2},...
        'Position',[0.9 0.05 0.1 0.15],...
        'Tag','Use_Brightness_Corr');
    h.SettingsTab.Use_Lifetime = uicontrol(...
        'Style','checkbox',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Value',0,...
        'enable','off',...
        'FontSize',12,...
        'String','Use lifetime',...
        'Tooltipstring', '',...
        'Callback',[],...
        'ButtonDownFcn',[],...
        'Position',[0.9 0.55 0.1 0.15],...
        'Tag','Use_Lifetime');
     h.SettingsTab.LiveUpdate = uicontrol(...
        'Parent',h.SettingsTab.Panel,...
        'Tag','LiveUpdate',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Live plot update',...
        'Value',0,...
        'Position',[0.8 0.55 0.1 0.15]);
     h.SettingsTab.SampleGlobal = uicontrol(...
        'Parent',h.SettingsTab.Panel,...
        'Tag','SampleGlobal',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Sample-based Global',...
        'Tooltipstring', 'Check this if you want to globally link defined (check the code!) parameters within a set of time windows per file. Do not F that parameter but G it in the UI. Every loaded dataset needs to have the same number of TWs!',...
        'Value',UserValues.PDA.HalfGlobal,...
        'Callback', {@Update_Plots, 0},...
        'Position',[0.65 0.05 0.1 0.15]);
    h.SettingsTab.TW_edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'String',4,...
        'Tooltipstring', 'Enter the number of loaded time windows per file',...
        'FontSize',12,...
        'Position',[0.75 0.05 0.025 0.15],...
        'Enable','on',...
        'Tag','TW_edit');
    h.SettingsTab.DeconvoluteBackground = uicontrol(...
        'Parent',h.SettingsTab.Panel,...
        'Tag','DeconvoluteBackground',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'enable','on',...
        'String','Deconvolute background',...
        'TooltipString','Use at own risk, feature is not thoroughly tested.',...
        'Value',UserValues.PDA.DeconvoluteBackground,...
        'Callback', {@Update_Plots, 0},...
        'Position',[0.65 0.3 0.15 0.15]);
        %% Database tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     h.PDADatabase.Tab= uitab(...
        'Parent',h.Tabgroup_Down,...
        'Tag','PDADatabase_Tab',...
        'Title','Database');    
    %%% Database panel
    h.PDADatabase.Panel = uibuttongroup(...
        'Parent',h.PDADatabase.Tab,...
        'Tag','PDADatabase_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);    
    %%% Database list
    h.PDADatabase.List = uicontrol(...
        'Parent',h.PDADatabase.Panel,...
        'Tag','PDADatabase_List',...
        'Style','listbox',...
        'Units','normalized',...
        'FontSize',14,...
        'Max',2,...
        'String',[],...
        'BackgroundColor', Look.List,...
        'ForegroundColor', Look.ListFore,...
        'KeyPressFcn',{@Database,0},...
        'Tooltipstring', ['<html>'...
                          'List of files in database <br>',...
                          '<i>"return"</i>: Loads selected files <br>',...
                          '<I>"delete"</i>: Removes selected files from list </b>'],...
        'Position',[0.01 0.01 0.9 0.98]);   
    %%% Button to add files to the database
    h.PDADatabase.Load = uicontrol(...
        'Parent',h.PDADatabase.Panel,...
        'Tag','PDADatabase_Load_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Load',...
        'Callback',{@Database,2},...
        'Position',[0.93 0.55 0.05 0.15],...
        'Tooltipstring', 'Load database from file');
    %%% Button to add files to the database
    h.PDADatabase.Save = uicontrol(...
        'Parent',h.PDADatabase.Panel,...
        'Tag','PDADatabase_Save_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Save',...
        'Callback',{@Database,3},...
        'Position',[0.93 0.35 0.05 0.15],...
        'enable', 'off',...
        'Tooltipstring', 'Save database to a file');
    
    %% downscale fontsize on windows
    if ispc
        scale_factor = 1/1.25;
        fields = fieldnames(h); %%% loop through h structure
        for i = 1:numel(fields)
            if isstruct(h.(fields{i}))
                fields_sub = fieldnames(h.(fields{i}));
                for j = 1:numel(fields_sub)
                    if isprop(h.(fields{i}).(fields_sub{j}),'FontSize')
                        h.(fields{i}).(fields_sub{j}).FontSize = (h.(fields{i}).(fields_sub{j}).FontSize)*scale_factor;
                    end
                end
            else
                if isprop(h.(fields{i}),'FontSize')
                    h.(fields{i}).FontSize = (h.(fields{i}).FontSize)*scale_factor;
                end
            end
        end   
    end
    %% Other stuff
    %%% Re-enable menu
    h.Menu.File.Enable = 'on';
    %% Initializes global variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PDAData=[];
    PDAData.Data=[];
    PDAData.FileName=[];
    PDAData.FitTable = [];
    PDAMeta=[];
    PDAData.Corrections = [];
    PDAData.Background = [];
    PDAMeta.Confidence_Intervals = cell(1,1);
    PDAMeta.Plots=cell(0);
    PDAMeta.Model=[];
    PDAMeta.Fits=[];
    PDAMeta.FitInProgress = 0;
    PDAMeta.LiveUpdate = 0;
    
    %% store handles structure
    guidata(h.GlobalPDAFit,h);
    SampleData
    Update_FitTable([],[],0); %initialize
    Update_ParamTable([],[],0);    
    Update_GUI(h.SettingsTab.FixSigmaAtFractionOfR,[]);
    Update_FitTable([],[],0); %reset to standard
    Update_GUI(h.SettingsTab.DynamicModel,[]);
else
    figure(h.GlobalPDAFit); % Gives focus to GlobalPDAFit figure
end


% Load data that was exported in BurstBrowser
function Load_PDA(~,~,mode)
global PDAData UserValues
h = guidata(findobj('Tag','GlobalPDAFit'));

if mode ~= 3
    %% Load or Add data
    Files = GetMultipleFiles({'*.pda','*.pda file'},'Select *.pda file',UserValues.File.PDAPath);
    if isempty(Files)
        return;
    end
    FileName = Files(:,1);
    PathName = Files(:,2);
    %%% Only executes, if at least one file was selected
    if all(FileName{1}==0)
        return
    end
    %PathName = cell(numel(FileName),1);
    %PathName(:) = {p};
else
    %% Database loading
    FileName = PDAData.FileName;
    PathName = PDAData.PathName;
end

UserValues.File.PDAPath = PathName{1};

LSUserValues(1);

if mode==1 || mode ==3 % new files are loaded or database is loaded
    PDAData.FileName = [];
    PDAData.PathName = [];
    PDAData.Data = [];
    PDAData.timebin = [];
    PDAData.Type = [];
    PDAData.Corrections = [];
    PDAData.Background = [];
    PDAData.OriginalFitParams = [];
    PDAData.FitTable = [];
    PDAData.BrightnessReference = [];
    PDAData.MinN = [];
    PDAData.MaxN = [];
    PDAData.MinS = [];
    PDAData.MaxS = [];
    PDAData.KineticRatesTable = [];
    h.FitTab.Table.RowName(1:end-3)=[];
    h.FitTab.Table.Data(1:end-3,:)=[];
    h.KineticRates_table.Data(1:end-3,:)=[];
    h.ParametersTab.Table.RowName(1:end-1)=[];
    h.ParametersTab.Table.Data(1:end-1,:)=[];
    h.PDADatabase.List.String = [];
    h.PDADatabase.Save.Enable = 'off';
    h.Menu.Add.Enable = 'on';
    h.Menu.Save.Enable = 'on';
    h.SettingsTab.Use_Lifetime.Enable = 'off';
end
errorstr = cell(0,1);
a = 1;
for i = 1:numel(FileName)
    Progress(i/numel(FileName),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Loading file(s)...');
    Progress(i/numel(FileName),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Loading file(s)...');
    if exist(fullfile(PathName{i},FileName{i}), 'file') == 2
        load('-mat',fullfile(PathName{i},FileName{i}));
        PDAData.FileName{end+1} = FileName{i};
        PDAData.PathName{end+1} = PathName{i};
        if exist('PDA','var') % file has not been saved before in GlobalPDAFit
            % PDA %structure
            % .NGP
            % ....
            % .NR
            % .Corrections %structure
            %       .CrossTalk_GR
            %       .DirectExcitation_GR
            %       .Gamma_GR
            %       .Beta_GR
            %       .GfactorGreen
            %       .GfactorRed
            %       .DonorLifetime
            %       .AcceptorLifetime
            %       .FoersterRadius
            %       .LinkerLength
            %       .r0_green
            %       .r0_red
            %       ... maybe more in future
            % .Background %structure
            %       .Background_GGpar
            %       .Background_GGperp
            %       .Background_GRpar
            %       .Background_GRperp
            %       ... maybe more in future
            % NOTE: direct excitation correction in Burst analysis is NOT the
            % same as PDA, therefore we put it to zero. In PDA, this factor
            % is either the extcoeffA/(extcoeffA+extcoeffD) at donor laser,
            % or the ratio of Int(A)/(Int(A)+Int(D)) for a crosstalk, gamma
            % corrected double labeled molecule having no FRET at all.
            PDAData.Data{end+1} = PDA;
            PDAData.Data{end} = rmfield(PDAData.Data{end}, 'Corrections');
            PDAData.Data{end} = rmfield(PDAData.Data{end}, 'Background');
            PDAData.timebin(end+1) = timebin;
            PDAData.Corrections{end+1} = PDA.Corrections; %contains everything that was saved in BurstBrowser
            PDAData.Background{end+1} = PDA.Background; %contains everything that was saved in BurstBrowser
            if isfield(PDA,'BrightnessReference')
                if ~isempty(PDA.BrightnessReference.N)
                    PDAData.BrightnessReference = PDA.BrightnessReference;
                    PDAData.BrightnessReference.PN = histcounts(PDAData.BrightnessReference.N,1:(max(PDAData.BrightnessReference.N)+1));
                end
            end
            if isfield(PDA,'Type') %%% Type distinguishes between whole measurement and burstwise
                PDAData.Type{end+1} = PDA.Type;
            else
                PDAData.Type{end+1} = 'Burst';
            end
            if isfield(PDA,'MinN') %%% photon and stoichiometry thresholds have been saved
                PDAData.MinN{end+1} = PDA.MinN;
                PDAData.MaxN{end+1} = PDA.MaxN;
                PDAData.MinS{end+1} = PDA.MinS;
                PDAData.MaxS{end+1} = PDA.MaxS;
            else %%% read values from UserValues
                PDAData.MinN{end+1} = str2double(UserValues.PDA.MinPhotons);
                PDAData.MaxN{end+1} = str2double(UserValues.PDA.MaxPhotons);
                PDAData.MinS{end+1} = str2double(UserValues.PDA.Smin);
                PDAData.MaxS{end+1} = str2double(UserValues.PDA.Smax);
            end
            PDAData.KineticRatesTable{end+1} = [];
            clear PDA timebin
            PDAData.FitTable{end+1} = h.FitTab.Table.Data(end-2,:);
        elseif exist('SavedData','var') % file has been saved before in GlobalPDAFit and contains PDAData (named SavedData)
            % SavedData %structure
            %   .Data %cell
            %       .NGP
            %       ....
            %       .NR
            %   .Corrections %structure
            %           see above
            %   .Background %structure
            %           see above
            %   .FitParams %1 x 47 cell
            PDAData.Data{end+1} = SavedData.Data;
            PDAData.timebin(end+1) = SavedData.timebin;
            PDAData.Corrections{end+1} = SavedData.Corrections;
            PDAData.Background{end+1} = SavedData.Background;
            if isfield(SavedData,'BrightnessReference')
                PDAData.BrightnessReference = SavedData.BrightnessReference;
                PDAData.BrightnessReference.PN = histcounts(PDAData.BrightnessReference.N,1:(max(PDAData.BrightnessReference.N)+1));
            end
            if isfield(SavedData,'Sigma')
                try
                    h.SettingsTab.FixSigmaAtFractionOfR.Value = SavedData.Sigma(1);
                    h.SettingsTab.SigmaAtFractionOfR_edit.String = num2str(SavedData.Sigma(2));
                    h.SettingsTab.FixSigmaAtFractionOfR_Fix.Value = SavedData.Sigma(3);
                    UserValues.PDA.FixSigmaAtFraction = SavedData.Sigma(1);
                    UserValues.PDA.FixSigmaAtFractionFix = SavedData.Sigma(3);
                    LSUserValues(1)
                catch
                end
            end
            if isfield(SavedData,'LinkStaticAndDynamic');
                h.SettingsTab.FixStaticToDynamicSpecies.Value = SavedData.LinkStaticAndDynamic;
            end
            if isfield(SavedData,'Dynamic')
                h.SettingsTab.DynamicModel.Value = SavedData.Dynamic;
                UserValues.PDA.Dynamic = SavedData.Dynamic;
                LSUserValues(1)
            end
            if isfield(SavedData,'DynamicSystem')
                h.SettingsTab.DynamicSystem.Value = SavedData.DynamicSystem;
            end
            if isfield(SavedData,'KineticRatesTable')
                PDAData.KineticRatesTable{end+1} = SavedData.KineticRatesTable;
                %h.KineticRates_table.Data = SavedData.ThreeStateModel;
            else
                PDAData.KineticRatesTable{end+1} = [];
            end
            if isfield(SavedData,'Type') %%% Type distinguishes between whole measurement and burstwise
                PDAData.Type{end+1} = SavedData.Type;
            else
                PDAData.Type{end+1} = 'Burst';
            end
            if isfield(SavedData,'MinN') %%% photon and stoichiometry thresholds have been saved
                PDAData.MinN{end+1} = SavedData.MinN;
                PDAData.MaxN{end+1} = SavedData.MaxN;
                PDAData.MinS{end+1} = SavedData.MinS;
                PDAData.MaxS{end+1} = SavedData.MaxS;
            else %%% read values from UserValues
                PDAData.MinN{end+1} = str2double(UserValues.PDA.MinPhotons);
                PDAData.MaxN{end+1} = str2double(UserValues.PDA.MaxPhotons);
                PDAData.MinS{end+1} = str2double(UserValues.PDA.Smin);
                PDAData.MaxS{end+1} = str2double(UserValues.PDA.Smax);
            end
            if isfield(SavedData,'ScaleNumberOfPhotons')
                % Scale number of photon setting was saved
                if i == 1 % first file, use settings of this file for all
                    h.SettingsTab.ScaleNumberOfPhotons_Checkbox.Value = SavedData.ScaleNumberOfPhotons;
                end
            end
            if isfield(SavedData,'XAxisMethod')
                %%% XAxisMethod and limits have been saved
                if i == 1 % first file, use xAxisMethod and limits of this file
                    h.SettingsTab.XAxisUnit_Menu.Value = find(strcmp(SavedData.XAxisMethod,h.SettingsTab.XAxisUnit_Menu.String));
                    % set the limits
                    h.SettingsTab.MainAxisLimtsLow_Edit.String = num2str(SavedData.XAxisLimitLow);
                    h.SettingsTab.MainAxisLimtsHigh_Edit.String = num2str(SavedData.XAxisLimitHigh);
                end
            end
            if isfield(SavedData,'HalfGlobal')
                % HalfGlobal settings were saved
                if i == 1 % first file, use settings of this file for all
                    h.SettingsTab.SampleGlobal.Value = SavedData.HalfGlobal;
                    h.SettingsTab.TW_edit.String = num2str(SavedData.HalfGlobalSubsetSize);
                 end
            end            
            % load fit table data from files
            PDAData.FitTable{end+1} = SavedData.FitTable;
        elseif exist('PDAstruct','var')
            %%% File is probably from old PDAFit
            PDAData.Data{end+1} = PDAstruct.Data;
            PDAData.timebin(end+1) = PDAstruct.timebin;
            PDAData.Corrections{end+1} = PDAstruct.Corrections; %contains everything that was saved in BurstBrowser
            PDAData.Background{end+1}.Background_GGpar = PDAstruct.Corrections.BackgroundDonor/2;
            PDAData.Background{end}.Background_GGperp = PDAstruct.Corrections.BackgroundDonor/2;
            PDAData.Background{end}.Background_GRpar = PDAstruct.Corrections.BackgroundAcceptor/2;
            PDAData.Background{end}.Background_GRperp = PDAstruct.Corrections.BackgroundAcceptor/2;
            PDAData.FitTable{end+1} = h.FitTab.Table.Data(end-2,:);
            PDAData.Type{end+1} = 'Burst';
        end
        % add files to database table
        h.PDADatabase.List.String{end+1} = [FileName{i} ' (path:' PathName{i} ')'];
        h.PDADatabase.Save.Enable = 'on';
    else
        errorstr{a} = ['File ' FileName{i} ' on path ' PathName{i} ' could not be found. File omitted from database.'];
        a = a+1;
    end       
end
PDAData.OriginalFitParams = PDAData.FitTable; %contains the fit table as it was originally displayed when opening the data
if a > 1
    msgbox(errorstr)
end
%%% check if lifetime information is available
lifetime = false(numel(PDAData.Data),1);
for i = 1:numel(PDAData.Data)
    if isfield(PDAData.Data{i},'MI_G')
        lifetime(i) = true;
    end
end

if all(lifetime)
    h.SettingsTab.Use_Lifetime.Enable = 'on';
end

% data cannot be directly plotted here, since other functions (bin size,...)
% might change the appearance of the data

%update threshold for photon number and Stoichiometry
h.SettingsTab.NumberOfPhotMin_Edit.String = min(cell2mat(PDAData.MinN));
h.SettingsTab.NumberOfPhotMax_Edit.String = max(cell2mat(PDAData.MaxN));
h.SettingsTab.StoichiometryThresholdLow_Edit.String = min(cell2mat(PDAData.MinS));
h.SettingsTab.StoichiometryThresholdHigh_Edit.String = max(cell2mat(PDAData.MaxS));

Update_GUI(h.SettingsTab.DynamicModel,[]);
Update_GUI(h.SettingsTab.FixSigmaAtFractionOfR,[]);
Update_FitTable([],[],1);
Update_ParamTable([],[],1);
if h.SettingsTab.DynamicSystem.Value == 2 % three-state model
    Update_GUI(h.KineticRates_table,[]);
end
Update_Plots([],[],3);

% Save data and fit table back into each individual file 
function Save_PDA(~,~)
global PDAData
h = guidata(findobj('Tag','GlobalPDAFit'));
for i = 1:numel(PDAData.FileName)
    Progress(i/numel(PDAData.FileName),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Saving file(s)...');
    Progress(i/numel(PDAData.FileName),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Saving file(s)...');
    SavedData.Data = PDAData.Data{i};
    SavedData.timebin = PDAData.timebin(i);
    SavedData.Corrections = PDAData.Corrections{i};
    SavedData.Background = PDAData.Background{i};
    SavedData.Type = PDAData.Type{i};
    % for each dataset, all info from the table is saved (including active, global, fixed)
    SavedData.FitTable = h.FitTab.Table.Data(i,:);
    SavedData.FitTable{1} = true; %put file to active to avoid problems when reloading data
    SavedData.Sigma = [h.SettingsTab.FixSigmaAtFractionOfR.Value,...
        str2double(h.SettingsTab.SigmaAtFractionOfR_edit.String),...
        h.SettingsTab.FixSigmaAtFractionOfR_Fix.Value];
    SavedData.Dynamic = h.SettingsTab.DynamicModel.Value;
    SavedData.DynamicSystem = h.SettingsTab.DynamicSystem.Value;
    SavedData.KineticRatesTable = h.KineticRates_table.Data(i,:);
    SavedData.LinkStaticAndDynamic = h.SettingsTab.FixStaticToDynamicSpecies.Value;
    SavedData.MinN = str2double(h.SettingsTab.NumberOfPhotMin_Edit.String);
    SavedData.MaxN = str2double(h.SettingsTab.NumberOfPhotMax_Edit.String);
    SavedData.MinS = str2double(h.SettingsTab.StoichiometryThresholdLow_Edit.String);
    SavedData.MaxS = str2double(h.SettingsTab.StoichiometryThresholdHigh_Edit.String);
    SavedData.XAxisMethod = h.SettingsTab.XAxisUnit_Menu.String{h.SettingsTab.XAxisUnit_Menu.Value};
    SavedData.XAxisLimitLow = str2double(h.SettingsTab.MainAxisLimtsLow_Edit.String);
    SavedData.XAxisLimitHigh = str2double(h.SettingsTab.MainAxisLimtsHigh_Edit.String);
    SavedData.HalfGlobal = h.SettingsTab.SampleGlobal.Value;
    SavedData.HalfGlobalSubsetSize = str2double(h.SettingsTab.TW_edit.String);
    SavedData.ScaleNumberOfPhotons = h.SettingsTab.ScaleNumberOfPhotons_Checkbox.Value;
    save(fullfile(PDAData.PathName{i},PDAData.FileName{i}),'SavedData');
end

% Function that groups things that concern the plots
function Update_Plots(obj,~,mode,reset)
% function creates and/or updates the plots after:
% mode = 1: after fitting
% mode = 2: changing the popup value on single tab + called in UpdatePlot
% mode = 3: loading or adding data, n.o. bins, min/max, fix w_r...
% mode = 4: after updateparam table
% mode = 5: LiveUpdate plots during fitting

global PDAData PDAMeta UserValues
h = guidata(findobj('Tag','GlobalPDAFit'));

if nargin < 4
    reset = 0;
end
%%% reset resets the PDAMeta.PreparationDone variable
if reset == 1
    PDAMeta.PreparationDone(:) = 0;
end

% determine x-axis unit
PDAMeta.xAxisUnit = h.SettingsTab.XAxisUnit_Menu.String{h.SettingsTab.XAxisUnit_Menu.Value};

% check if plot is active
Active = find(cell2mat(h.FitTab.Table.Data(1:end-3,1)))';

if isempty(Active) %% Clears 2D plot, if all are inactive
    %     h.Plots.Main.ZData = zeros(2);
    %     h.Plots.Main.CData = zeros(2,2,3);
    %     h.Plots.Fit.ZData = zeros(2);
    %     h.Plots.Fit.CData = zeros(2,2,3);
    h.SingleTab.Popup.String = {'Nothing selected'};
else %% Updates 2D plot selection string
    h.SingleTab.Popup.String = PDAData.FileName(Active);
    if h.SingleTab.Popup.Value>numel(h.SingleTab.Popup.String)
        h.SingleTab.Popup.Value = 1;
    end
end

switch mode
    case 3
        %% Update the All tab        
        n = size(PDAData.Data,2);
        color = lines(n);
        % after loading data or changing settings tab
        % predefine handle cells
        PDAMeta.Plots.Data_All = cell(n,1);
        PDAMeta.Plots.Res_All = cell(n,1);
        PDAMeta.Plots.Fit_All = cell(n,8); 
        % 1 = all
        % 2:6 = substates
        % 7 = D only
        % 8 = all dynamic bursts
        PDAMeta.Plots.BSD_All = cell(n,1);
        PDAMeta.Plots.ES_All = cell(n,1);
        PDAMeta.Plots.Gauss_All = cell(n,8);
        % 1 = all
        % 2:6 = substates
        % 7 = D only
        % 8 = all dynamic bursts
        PDAMeta.hProx = cell(n,1); %hProx has to be global cause it's used for error calculation during fitting
        cla(h.AllTab.Main_Axes)
        cla(h.AllTab.Res_Axes)
        cla(h.AllTab.BSD_Axes)
        cla(h.AllTab.ES_Axes)
        cla(h.AllTab.Gauss_Axes)
        PDAMeta.Chi2_All = text('Parent',h.AllTab.Main_Axes,...
            'Units','normalized',...
            'Position',[0.77,0.95],...
            'String',['global \chi^2_{red.} = ' sprintf('%1.2f',randn(1))],...
            'FontWeight','bold',...
            'FontSize',18,...
            'FontSmoothing','on',...
            'Visible','off');
        for i = 1:n
            %%%read corretions
            PDAMeta.BGdonor(i) = cell2mat(h.ParametersTab.Table.Data(i,4));
            PDAMeta.BGacc(i) = cell2mat(h.ParametersTab.Table.Data(i,5));
            PDAMeta.crosstalk(i) = cell2mat(h.ParametersTab.Table.Data(i,3));
            PDAMeta.R0(i) = cell2mat(h.ParametersTab.Table.Data(i,6));
            PDAMeta.directexc(i) = cell2mat(h.ParametersTab.Table.Data(i,2));
            PDAMeta.gamma(i) = cell2mat(h.ParametersTab.Table.Data(i,1));
            %colors
            normal = color(i,:);
            light = (normal+1)./2;
            dark = normal./2;
            if strcmp(PDAData.Type{i},'Burst')
                %%% find valid bins (chosen by thresholds min/max and stoichiometry)
                StoAll = (PDAData.Data{i}.NF+PDAData.Data{i}.NG)./(PDAData.Data{i}.NG+PDAData.Data{i}.NF+PDAData.Data{i}.NR);
                valid = ((StoAll >= str2double(h.SettingsTab.StoichiometryThresholdLow_Edit.String))) & ... % Stoichiometry low
                        ((StoAll <= str2double(h.SettingsTab.StoichiometryThresholdHigh_Edit.String))); % Stoichiometry high
                if ~h.SettingsTab.ScaleNumberOfPhotons_Checkbox.Value % no scaling of the minimum number of photons
                    valid = valid & ...
                        ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) > str2double(h.SettingsTab.NumberOfPhotMin_Edit.String)) & ... % min photon number
                        ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) < str2double(h.SettingsTab.NumberOfPhotMax_Edit.String)); % max photon number   
                else % minimum number of photons scale with the time window size
                    % the minimum and maximum number of photons are multiplied
                    % by the time window in milliseconds, i.e. the 1 ms
                    % measurement is the reference
                    valid = valid & ...
                        ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) > PDAData.timebin(i)*1000*str2double(h.SettingsTab.NumberOfPhotMin_Edit.String)) & ... % min photon number
                        ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) < PDAData.timebin(i)*1000*str2double(h.SettingsTab.NumberOfPhotMax_Edit.String)); % max photon number   

                end
            else
                if ~h.SettingsTab.ScaleNumberOfPhotons_Checkbox.Value % no scaling of the minimum number of photons
                    valid = (PDAData.Data{i}.NF+PDAData.Data{i}.NG) < str2double(h.SettingsTab.NumberOfPhotMax_Edit.String);
                else % minimum number of photons scale with the time window size
                    % the minimum and maximum number of photons are multiplied
                    % by the time window in milliseconds, i.e. the 1 ms
                    % measurement is the reference
                     valid = (PDAData.Data{i}.NF+PDAData.Data{i}.NG) < PDAData.timebin(i)*1000*str2double(h.SettingsTab.NumberOfPhotMax_Edit.String);
                end
            end
            %%% Calculate proximity ratio histogram
            ProxRatio = PDAData.Data{i}.NF(valid)./(PDAData.Data{i}.NG(valid)+PDAData.Data{i}.NF(valid));
            Sto = (PDAData.Data{i}.NF(valid)+PDAData.Data{i}.NG(valid))./(PDAData.Data{i}.NG(valid)+PDAData.Data{i}.NF(valid)+PDAData.Data{i}.NR(valid));
            BSD = PDAData.Data{i}.NF(valid)+PDAData.Data{i}.NG(valid);
            % calculate derived quantities
            switch PDAMeta.xAxisUnit
                case 'Proximity Ratio'
                    Prox = ProxRatio;
                    minX = 0; maxX = 1;
                    h.AllTab.Main_Axes.XLabel.String = 'Proximity Ratio';
                case 'log(FD/FA)'
                    Prox = real(log10(PDAData.Data{i}.NG(valid)./PDAData.Data{i}.NF(valid)));
                    minX = min(Prox(isfinite(Prox))); maxX = max(Prox(isfinite(Prox)));
                    h.AllTab.Main_Axes.XLabel.String = 'log(FD/FA)';
                case {'FRET efficiency','Distance'}
                    NF_cor = PDAData.Data{i}.NF(valid) - PDAData.timebin(i)*PDAMeta.BGacc(i);
                    ND_cor = PDAData.Data{i}.NG(valid) - PDAData.timebin(i)*PDAMeta.BGdonor(i);
                    % Schuler-type correction of photon counts for direct excitation
                    NF_cor = NF_cor - PDAMeta.crosstalk(i)*ND_cor-PDAMeta.directexc(i)*(PDAMeta.gamma(i)*ND_cor+NF_cor);
                    Prox = NF_cor./(PDAMeta.gamma(i)*ND_cor+NF_cor);
                    h.AllTab.Main_Axes.XLabel.String = 'FRET efficiency';
                    if strcmp(PDAMeta.xAxisUnit,'Distance')
                        % convert to distance
                        valid = Prox >= 0;
                        Prox = real(PDAMeta.R0(i)*(1./Prox-1).^(1/6));
                        Prox = Prox(valid);
                        h.AllTab.Main_Axes.XLabel.String = 'Distance [A]';
                    end
                    minX = min(Prox); maxX = max(Prox);
            end
            
            if gco == h.SettingsTab.XAxisUnit_Menu
                %%% if we called from the XAxis popupmenu, update axis limit editboxes
                h.SettingsTab.MainAxisLimtsLow_Edit.String = num2str(minX);
                h.SettingsTab.MainAxisLimtsHigh_Edit.String = num2str(maxX);
            else %if any(gco == [h.SettingsTab.MainAxisLimtsLow_Edit,h.SettingsTab.MainAxisLimtsHigh_Edit])
                %%% if we called from the axis limit edit boxes (or somewhere else), overwrite limit here
                minX_edit = str2double(h.SettingsTab.MainAxisLimtsLow_Edit.String);
                maxX_edit = str2double(h.SettingsTab.MainAxisLimtsHigh_Edit.String);                
                if isfinite(minX_edit)
                    minX = minX_edit;
                end
                if isfinite(maxX_edit)
                    maxX = maxX_edit;
                end
                if maxX < minX
                    temp = maxX;
                    maxX = minX; minX = temp;
                    h.SettingsTab.MainAxisLimtsLow_Edit.String = num2str(minX);
                    h.SettingsTab.MainAxisLimtsHigh_Edit.String = num2str(maxX);
                end
            end
            
            PDAMeta.BSD{i} = BSD;
            PDAMeta.hProx{i} = histcounts(Prox, linspace(minX,maxX,str2double(h.SettingsTab.NumberOfBins_Edit.String)+1)); 
            % if NumberOfBins = 50, then the EDGES(1:51) array is 0 0.02 0.04... 1.00
            % histcounts bins as 0 <= N < 0.02
            xProx = linspace(minX,maxX,str2double(h.SettingsTab.NumberOfBins_Edit.String)+1)+1/str2double(h.SettingsTab.NumberOfBins_Edit.String)/2;
            % if NumberOfBins = 50, then xProx(1:51) = 0.01 0.03 .... 0.99 1.01
            % the last element is to allow proper display of the 50th bin
            
            hBSD = histcounts(BSD,1:(max(BSD)+1));
            xBSD = 1:max(BSD);
            
            % make 'stairs' appear similar to 'bar'
            xProx = xProx-mean(diff(xProx))/2;
            
            % slightly modify x-axis for each following dataset, to
            % allow better visualization of the different datasets.
            if i ~= 1
                % i = 1: do nothing
                % i = 2: shift each x value +5% of the x bin size
                % i = 3: shift each x value -5% of the x bin size
                % i = 4: shift each x value +10% of the x bin size
                % i = 5: shift each x value -10% of the x bin size
                % ...
                diffx = mean(diff(xProx))/20;
                if mod(i,2) == 0 %i = 2, 4, 6...
                    xProx = xProx + diffx*i/2;
                else %i = 3, 5, 7...
                    xProx = xProx - diffx*(i-1)/2;
                end
            end
            
            % data plot
            PDAMeta.Plots.Data_All{i} = stairs(h.AllTab.Main_Axes,...
                xProx,...
                [PDAMeta.hProx{i} PDAMeta.hProx{i}(end)],...
                'Color',normal,...
                'LineWidth',1);
            
            if h.SettingsTab.OuterBins_Fix.Value
                % do not display or take into account during fitting, the
                % outer bins of the histogram.
                lims = [xProx(2) xProx(end-1)];
                mini = PDAMeta.hProx{i}(2);
                maxi = PDAMeta.hProx{i}(end-1);
            else
                lims = [xProx(1) xProx(end)];
                mini = PDAMeta.hProx{i}(1);
                maxi = PDAMeta.hProx{i}(end);
            end
            PDAMeta.Plots.Data_All{i}.YData(1) = mini;
            PDAMeta.Plots.Data_All{i}.YData(end) = maxi;
            PDAMeta.Plots.Data_All{i}.YData = PDAMeta.Plots.Data_All{i}.YData./sum(PDAMeta.Plots.Data_All{i}.YData);
            set(h.AllTab.Main_Axes, 'XLim', [minX,maxX])
            set(h.AllTab.Res_Axes, 'XLim', [minX,maxX])
            % residuals plot
            PDAMeta.Plots.Res_All{i} = stairs(h.AllTab.Res_Axes,...
                xProx,...
                zeros(numel(xProx),1),...
                'Color',normal,...
                'LineWidth',1,...
                'Visible', 'off');
            
            % fit plots
            PDAMeta.Plots.Fit_All{i,1} = stairs(h.AllTab.Main_Axes,...
                xProx,...
                zeros(numel(xProx),1),...
                'Color',dark,...
                'LineWidth',2,...
                'Visible','off');
            
            % plots for individual fits
            for j = 2:8
                % 1 = all
                % 2:6 = substates
                % 7 = D only
                % 8 = all dynamic bursts
                PDAMeta.Plots.Fit_All{i,j} = stairs(h.AllTab.Main_Axes,...
                    xProx,...
                    zeros(numel(xProx),1),...
                    'Color',light,...
                    'LineWidth',2,...
                    'Linestyle','--',...
                    'Visible','off');
            end

            % burst size distribution plot
            if isempty(PDAData.BrightnessReference)
                PDAMeta.Plots.BSD_Reference = plot(h.AllTab.BSD_Axes,...
                    xBSD,...
                    hBSD,...
                    'Color','m',...
                    'LineStyle','--',...
                    'Visible','off',...
                    'LineWidth',2);
            else
                PDAMeta.Plots.BSD_Reference = plot(h.AllTab.BSD_Axes,...
                    xBSD(1:min([end numel(PDAData.BrightnessReference.PN)])),...
                    PDAData.BrightnessReference.PN(xBSD(1:min([end numel(PDAData.BrightnessReference.PN)]))),...
                    'Color','m',...
                    'LineStyle','--',...
                    'LineWidth',2,...
                    'Visible','off');
            end
            if h.SettingsTab.Use_Brightness_Corr.Value
                PDAMeta.Plots.BSD_Reference.Visible = 'on';
            end
            PDAMeta.Plots.BSD_All{i} = plot(h.AllTab.BSD_Axes,...
                xBSD,...
                hBSD,...
                'Color',normal,...
                'LineWidth',2);
            % ES scatter plots
            PDAMeta.Plots.ES_All{i} = plot(h.AllTab.ES_Axes,...
                ProxRatio,...
                Sto,...
                'Color',normal,...
                'MarkerSize',2,...
                'LineStyle','none',...
                'Marker','.');
            % generate exemplary distance plots
            x = 0:0.1:200;
            g = zeros(5,200*10+1);
            for j = 1:6
                g(j,:) = normpdf(x,40+10*j,j);
            end;
            % summed distance plot
            PDAMeta.Plots.Gauss_All{i,1} = plot(h.AllTab.Gauss_Axes,...
                x,sum(g,1),...
                'Color',dark,...
                'LineWidth',2,...
                'Visible', 'off');
            %individual distance plots
            for j = 2:7
                % 1 = all
                % 2:6 = substates
                % 7 = D only
                % 8 = all dynamic bursts
                PDAMeta.Plots.Gauss_All{i,j} = plot(h.AllTab.Gauss_Axes,...
                    x,g(j-1,:),...
                    'Color',light,...
                    'LineWidth',2,...
                    'LineStyle', '--',...
                    'Visible', 'off');
            end
            xlim(h.AllTab.Gauss_Axes,[40 120]);
        end
end
switch mode
    case {2,3}
        %% Update the 'Single' tab plots
        % after load data
        % after popup change
        % during fitting, when the tab is changed to single
        if ~isempty(Active)
            % check if plot is active
            i = Active(h.SingleTab.Popup.Value);
            % predefine cells
            PDAMeta.Plots.Fit_Single = cell(1,6);
            PDAMeta.Plots.Gauss_Single = cell(1,6);
            % clear axes
            cla(h.SingleTab.Main_Axes)
            cla(h.SingleTab.Res_Axes)
            cla(h.SingleTab.BSD_Axes)
            cla(h.SingleTab.Gauss_Axes)
            cla(h.SingleTab.ES_Axes);
            PDAMeta.Chi2_Single = copyobj(PDAMeta.Chi2_All, h.SingleTab.Main_Axes);
            PDAMeta.Chi2_Single.Position = [0.8,0.95];
            try
                % if fit is performed, this will work
                PDAMeta.Chi2_Single.String = ['\chi^2_{red.} = ' sprintf('%1.2f',PDAMeta.chi2(i))];
            end
            if strcmp(PDAData.Type{i},'Burst')
                %%% find valid bins (chosen by thresholds min/max and stoichiometry)
                StoAll = (PDAData.Data{i}.NF+PDAData.Data{i}.NG)./(PDAData.Data{i}.NG+PDAData.Data{i}.NF+PDAData.Data{i}.NR);
                valid = ((StoAll >= str2double(h.SettingsTab.StoichiometryThresholdLow_Edit.String))) & ... % Stoichiometry low
                        ((StoAll <= str2double(h.SettingsTab.StoichiometryThresholdHigh_Edit.String))); % Stoichiometry high
                if ~h.SettingsTab.ScaleNumberOfPhotons_Checkbox.Value % no scaling of the minimum number of photons
                    valid = valid & ...
                        ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) > str2double(h.SettingsTab.NumberOfPhotMin_Edit.String)) & ... % min photon number
                        ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) < str2double(h.SettingsTab.NumberOfPhotMax_Edit.String)); % max photon number   
                else % minimum number of photons scale with the time window size
                    % the minimum and maximum number of photons are multiplied
                    % by the time window in milliseconds, i.e. the 1 ms
                    % measurement is the reference
                    valid = valid & ...
                        ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) > PDAData.timebin(i)*1000*str2double(h.SettingsTab.NumberOfPhotMin_Edit.String)) & ... % min photon number
                        ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) < PDAData.timebin(i)*1000*str2double(h.SettingsTab.NumberOfPhotMax_Edit.String)); % max photon number   

                end
            else
                if ~h.SettingsTab.ScaleNumberOfPhotons_Checkbox.Value % no scaling of the minimum number of photons
                    valid = (PDAData.Data{i}.NF+PDAData.Data{i}.NG) < str2double(h.SettingsTab.NumberOfPhotMax_Edit.String);
                else % minimum number of photons scale with the time window size
                    % the minimum and maximum number of photons are multiplied
                    % by the time window in milliseconds, i.e. the 1 ms
                    % measurement is the reference
                     valid = (PDAData.Data{i}.NF+PDAData.Data{i}.NG) < PDAData.timebin(i)*1000*str2double(h.SettingsTab.NumberOfPhotMax_Edit.String);
                end
            end
            ProxRatio = PDAData.Data{i}.NF(valid)./(PDAData.Data{i}.NG(valid)+PDAData.Data{i}.NF(valid));
            % calculate derived quantities
            switch PDAMeta.xAxisUnit
                case 'Proximity Ratio'
                    Prox = ProxRatio;                    
                    h.AllTab.Main_Axes.XLabel.String = 'Proximity Ratio';
                case 'log(FD/FA)'
                    Prox = real(log10(PDAData.Data{i}.NG(valid)./PDAData.Data{i}.NF(valid)));
                    h.SingleTab.Main_Axes.XLabel.String = 'log(FD/FA)';
                case {'FRET efficiency','Distance'}
                    NF_cor = PDAData.Data{i}.NF(valid) - PDAData.timebin(i)*PDAMeta.BGacc(i);
                    ND_cor = PDAData.Data{i}.NG(valid) - PDAData.timebin(i)*PDAMeta.BGdonor(i);
                    % Schuler-type correction of photon counts for direct excitation
                    NF_cor = NF_cor - PDAMeta.crosstalk(i)*ND_cor-PDAMeta.directexc(i)*(PDAMeta.gamma(i)*ND_cor+NF_cor);
                    Prox = NF_cor./(PDAMeta.gamma(i)*ND_cor+NF_cor);
                    h.SingleTab.Main_Axes.XLabel.String = 'FRET efficiency';
                    if strcmp(PDAMeta.xAxisUnit,'Distance')
                        % convert to distance
                        Prox = real(PDAMeta.R0(i)*(1./Prox-1).^(1/6));
                        h.SingleTab.Main_Axes.XLabel.String = 'Distance [A]';
                    end
            end
            minX = str2double(h.SettingsTab.MainAxisLimtsLow_Edit.String);
            maxX = str2double(h.SettingsTab.MainAxisLimtsHigh_Edit.String);
            
            hProx = histcounts(Prox, linspace(minX,maxX,str2double(h.SettingsTab.NumberOfBins_Edit.String)+1));
            % if NumberOfBins = 50, then the EDGES(1:51) array is 0 0.02 0.04... 1.00
            % histcounts bins as 0 <= N < 0.02
            xProx = linspace(minX,maxX,str2double(h.SettingsTab.NumberOfBins_Edit.String)+1)+1/str2double(h.SettingsTab.NumberOfBins_Edit.String)/2;
            % if NumberOfBins = 50, then xProx(1:51) = 0.01 0.03 .... 0.99 1.01
            % the last element is to allow proper display of the 50th bin
            
            % data plot
            PDAMeta.Plots.Data_Single = bar(h.SingleTab.Main_Axes,...
                xProx,...
                [hProx hProx(end)],...
                'FaceColor',[0.4 0.4 0.4],...
                'EdgeColor','none',...
                'BarWidth',1);
            N_bins = sum([hProx hProx(end)]);
            % make 'stairs' appear similar to 'bar'
            xProx = xProx-mean(diff(xProx))/2;
            
            if h.SettingsTab.OuterBins_Fix.Value
                % do not display or take into account during fitting, the
                % outer bins of the histogram.
                lims = [xProx(2) xProx(end-1)];
                mini = hProx(2);
                maxi = hProx(end-1);
            else
                lims = [xProx(1) xProx(end)];
                mini = hProx(1);
                maxi = hProx(end);
            end
            PDAMeta.Plots.Data_Single.YData(1) = mini;
            PDAMeta.Plots.Data_Single.YData(end) = maxi;
            set(h.SingleTab.Main_Axes, 'XLim', lims)
            set(h.SingleTab.Res_Axes, 'XLim', lims)
            set(h.SingleTab.Main_Axes,'YLimMode','auto');
            % residuals
            PDAMeta.Plots.Res_Single = copyobj(PDAMeta.Plots.Res_All{i}, h.SingleTab.Res_Axes);
            set(PDAMeta.Plots.Res_Single,...
                'LineWidth',2,...
                'Color','k') %only define those properties that are different to the all tab
            PDAMeta.Plots.Res_Single.XData = xProx;
            
            % summed fit
            PDAMeta.Plots.Fit_Single{1,1} = copyobj(PDAMeta.Plots.Fit_All{i,1}, h.SingleTab.Main_Axes);
            PDAMeta.Plots.Fit_Single{1,1}.YData = PDAMeta.Plots.Fit_Single{1,1}.YData*N_bins;
            PDAMeta.Plots.Fit_Single{1,1}.Color = 'k';%only define those properties that are different to the all tab
            PDAMeta.Plots.Fit_Single{1,1}.XData = xProx;
            
            % individual fits
            for j = 2:8
                % 1 = all
                % 2:6 = substates
                % 7 = D only
                % 8 = all dynamic bursts
                PDAMeta.Plots.Fit_Single{1,j} = copyobj(PDAMeta.Plots.Fit_All{i,j}, h.SingleTab.Main_Axes);
                PDAMeta.Plots.Fit_Single{1,j}.YData = PDAMeta.Plots.Fit_Single{1,j}.YData*N_bins;
                PDAMeta.Plots.Fit_Single{1,j}.Color = [0.2 0.2 0.2];
                PDAMeta.Plots.Fit_Single{1,j}.XData = xProx;
            end
            
            if h.SettingsTab.DynamicModel.Value
                colors = lines(4);
                % state 1
                PDAMeta.Plots.Fit_Single{1,2}.Color = colors(1,:);%[1 0 1];
                % state 2
                PDAMeta.Plots.Fit_Single{1,3}.Color = colors(2,:);%[0 1 1];
                if h.SettingsTab.DynamicSystem.Value == 2
                    % state 3
                    PDAMeta.Plots.Fit_Single{1,4}.Color = colors(4,:);%[0.4706 0.6706 0.18821];
                end
                % in between 1 and 2
                PDAMeta.Plots.Fit_Single{1,8}.Color = colors(3,:);%[1 1 0];
            end

            % bsd
            PDAMeta.Plots.BSD_Single = copyobj(PDAMeta.Plots.BSD_All{i}, h.SingleTab.BSD_Axes);
            PDAMeta.Plots.BSD_Single.Color = 'k';%only define those properties that are different to the all tab
            % deconvoluted PofF
            PDAMeta.Plots.PF_Deconvolved_Single = plot(h.SingleTab.BSD_Axes,...
                    0,...
                    1,...
                    'Color','k',...
                    'LineWidth',2,...
                    'LineStyle','--',...
                    'Visible','off');
            if UserValues.PDA.DeconvoluteBackground
                if isfield(PDAMeta,'PN')
                    PDAMeta.Plots.PF_Deconvolved_Single.XData = 0:(numel(PDAMeta.PN{i})-1);
                    PDAMeta.Plots.PF_Deconvolved_Single.YData = PDAMeta.PN{i};
                    PDAMeta.Plots.PF_Deconvolved_Single.Visible = 'on';
                end
            end

            % ES
            PDAMeta.Plots.ES_Single = copyobj(PDAMeta.Plots.ES_All{i}, h.SingleTab.ES_Axes);
            PDAMeta.Plots.ES_Single.Color = 'k';%only define those properties that are different to the all tab
            % gaussians
            for j = 1:7
                PDAMeta.Plots.Gauss_Single{1,j} = copyobj(PDAMeta.Plots.Gauss_All{i,j}, h.SingleTab.Gauss_Axes);
                PDAMeta.Plots.Gauss_Single{1,j}.Color = [0.4 0.4 0.4]; %only define those properties that are different to the all tab
            end
            PDAMeta.Plots.Gauss_Single{1,7}.Visible = 'off'; % donor only population does not apply
            % set Ylim of the single plot Gauss
            ylim(h.SingleTab.Gauss_Axes,[min(PDAMeta.Plots.Gauss_Single{1,1}.YData), max(PDAMeta.Plots.Gauss_Single{1,1}.YData)*1.05]);
            PDAMeta.Plots.Gauss_Single{1,1}.Color = 'k';
        end
    case 4
    case 1
        %% Update plots post fitting
        FitTable = cellfun(@str2double,h.FitTab.Table.Data);
        minGaussSum = 0;
        maxGaussSum = 0;
        %%% if the single tab is selected, only fit this dataset!
        if h.Tabgroup_Up.SelectedTab == h.SingleTab.Tab
            Active(:) = false;
            %%% find which is selected
            selected = find(strcmp(PDAData.FileName,h.SingleTab.Popup.String{h.SingleTab.Popup.Value}));
            Active(selected) = true;
            Active = find(Active);
        end
        for i = Active
            try %%% see if histogram exists
                x = PDAMeta.hFit{i};
            catch
                continue;
            end
            
            fitpar = FitTable(i,2:3:end-1); %everything but chi^2
            if h.SettingsTab.DynamicModel.Value 
                if h.SettingsTab.DynamicSystem.Value == 1 % two-state system
                    % calculate the amplitude from the k12 [fitpar(1)] and k21 [fitpar(4)]
                    tmp = fitpar(4)/(fitpar(1)+fitpar(4));
                    tmp2 = fitpar(1)/(fitpar(1)+fitpar(4));
                    fitpar(1) = tmp;
                    fitpar(4) = tmp2;
                elseif h.SettingsTab.DynamicSystem.Value == 2 % three-state system
                    % the amplitudes in fitpar are already the equilibrium fractions
                end
            end
            % normalize the amplitudes to get a total area of 1
            % this is just for the normpdf plots
            fitpar(1:3:end) = fitpar(1:3:end)/sum(fitpar(1:3:end));
            
            comp = PDAMeta.Comp{i};
            if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
                % for three-state model, some rates may be fixed to zero,
                % but the states should still be plotted
                comp = [1,2,3,comp(comp > 3)];
            end
            
            %%% Calculate Gaussian Distance Distributions
            for c = comp
                pdf = normpdf(PDAMeta.Plots.Gauss_All{i,1}.XData,fitpar(3*c-1),fitpar(3*c));
                Gauss{c} = fitpar(3*c-2).*pdf;
                if h.SettingsTab.GaussAmp_Fix.Value
                    Gauss{c} = Gauss{c}./max(pdf);
                end
            end
            
            if h.SettingsTab.OuterBins_Fix.Value
                % do not display or take into account during fitting, the
                % outer bins of the histogram.
                ydatafit = [PDAMeta.hFit{i}(2) PDAMeta.hFit{i}(2:end-1) PDAMeta.hFit{i}(end-1) PDAMeta.hFit{i}(end-1)];
                ydatares = [PDAMeta.w_res{i}(2) PDAMeta.w_res{i}(2:end-1) PDAMeta.w_res{i}(end-1) PDAMeta.w_res{i}(end-1)];
            else
                ydatafit = [PDAMeta.hFit{i} PDAMeta.hFit{i}(end)];
                ydatares = [PDAMeta.w_res{i} PDAMeta.w_res{i}(end)];
            end

            %%% Update All Plot
            set(PDAMeta.Plots.Fit_All{i,1},...
                'Visible', 'on',...
                'YData', ydatafit./sum(ydatafit));
            set(PDAMeta.Plots.Res_All{i},...
                'Visible', 'on',...
                'YData', real(ydatares));            
          
            for c = comp
                if h.SettingsTab.OuterBins_Fix.Value
                    % do not display or take into account during fitting, the
                    % outer bins of the histogram.
                    ydatafitind = [PDAMeta.hFit_Ind{i,c}(2); PDAMeta.hFit_Ind{i,c}(2:end-1); PDAMeta.hFit_Ind{i,c}(end-1); PDAMeta.hFit_Ind{i,c}(end-1)];
                else
                    ydatafitind = [PDAMeta.hFit_Ind{i,c}; PDAMeta.hFit_Ind{i,c}(end)];
                end
                set(PDAMeta.Plots.Fit_All{i,c+1},...
                    'Visible', 'on',...
                    'YData', ydatafitind./sum(ydatafit));
            end
            %%% donor only plot (plot #7)
            if PDAMeta.FitParams(i,19) > 0 %%% donor only existent
                if h.SettingsTab.OuterBins_Fix.Value
                    % do not display or take into account during fitting, the
                    % outer bins of the histogram.
                    ydatafitind = [PDAMeta.hFit_Donly{i}(2); PDAMeta.hFit_Donly{i}(2:end-1); PDAMeta.hFit_Donly{i}(end-1); PDAMeta.hFit_Donly{i}(end-1)];
                else
                    ydatafitind = [PDAMeta.hFit_Donly{i}'; PDAMeta.hFit_Donly{i}(end)];
                end
                PDAMeta.Plots.Fit_All{i,7}.Visible = 'on';
                PDAMeta.Plots.Fit_All{i,7}.YData = ydatafitind./sum(ydatafit);
                PDAMeta.Plots.Gauss_All{i,7}.Visible = 'off'; % hide distance distribution as it does not apply
            else
                PDAMeta.Plots.Fit_All{i,7}.Visible = 'off';
            end
            
            if h.SettingsTab.DynamicModel.Value
                % plot the summed dynamic component
                if h.SettingsTab.OuterBins_Fix.Value
                    % do not display or take into account during fitting, the
                    % outer bins of the histogram.
                    ydatafitind = [PDAMeta.hFit_onlyDyn{i}(2); PDAMeta.hFit_onlyDyn{i}(2:end-1); PDAMeta.hFit_onlyDyn{i}(end-1); PDAMeta.hFit_onlyDyn{i}(end-1)];
                else
                    ydatafitind = [PDAMeta.hFit_onlyDyn{i}; PDAMeta.hFit_onlyDyn{i}(end)];
                end
                set(PDAMeta.Plots.Fit_All{i,8},...
                    'Visible', 'on',...
                    'YData', ydatafitind./sum(ydatafit));
            else
                set(PDAMeta.Plots.Fit_All{i,8},'Visible', 'off');
            end
            
            if ~PDAMeta.FittingGlobal
                set(PDAMeta.Chi2_All,...
                    'Visible','on',...
                    'String', ['avg. \chi^2_{red.} = ' sprintf('%1.2f',mean(PDAMeta.chi2))]);
            else
                set(PDAMeta.Chi2_All,...
                    'Visible','on',...
                    'String', ['global \chi^2_{red.} = ' sprintf('%1.2f',PDAMeta.global_chi2)]);
            end
            GaussSum = sum(vertcat(Gauss{:}),1);
            minGaussSum = min([minGaussSum, min(GaussSum)]);
            maxGaussSum = max([maxGaussSum, max(GaussSum)]);
            set(PDAMeta.Plots.Gauss_All{i,1},...
                'Visible', 'on',...
                'YData', GaussSum);
            for c = comp
                set(PDAMeta.Plots.Gauss_All{i,c+1},...
                    'Visible', 'on',...
                    'YData', Gauss{c});
            end
            
            %%% Update Single Plot
            if i == find(strcmp(PDAData.FileName,h.SingleTab.Popup.String{h.SingleTab.Popup.Value}))%Active(h.SingleTab.Popup.Value)
                set(PDAMeta.Plots.Fit_Single{1,1},...
                    'Visible', 'on',...
                    'YData', ydatafit);
                set(PDAMeta.Plots.Res_Single,...
                    'Visible', 'on',...
                    'YData', real(ydatares));
                for c = comp
                    if h.SettingsTab.OuterBins_Fix.Value
                        % do not display or take into account during fitting, the
                        % outer bins of the histogram.
                        ydatafitind = [PDAMeta.hFit_Ind{i,c}(2); PDAMeta.hFit_Ind{i,c}(2:end-1); PDAMeta.hFit_Ind{i,c}(end-1); PDAMeta.hFit_Ind{i,c}(end-1)];
                    else
                        ydatafitind = [PDAMeta.hFit_Ind{i,c}; PDAMeta.hFit_Ind{i,c}(end)];
                    end
                    set(PDAMeta.Plots.Fit_Single{1,c+1},...
                        'Visible', 'on',...
                        'YData', ydatafitind);
                end
                if h.SettingsTab.DynamicModel.Value
                    % plot the summed dynamic component
                    if h.SettingsTab.OuterBins_Fix.Value
                        % do not display or take into account during fitting, the
                        % outer bins of the histogram.
                        ydatafitind = [PDAMeta.hFit_onlyDyn{i}(2); PDAMeta.hFit_onlyDyn{i}(2:end-1); PDAMeta.hFit_onlyDyn{i}(end-1); PDAMeta.hFit_onlyDyn{i}(end-1)];
                    else
                        ydatafitind = [PDAMeta.hFit_onlyDyn{i}; PDAMeta.hFit_onlyDyn{i}(end)];
                    end
                    set(PDAMeta.Plots.Fit_Single{1,8},...
                        'Visible', 'on',...
                        'YData', ydatafitind);
                else
                    set(PDAMeta.Plots.Fit_Single{1,8},'Visible', 'off');
                end
                try
                    set(PDAMeta.Chi2_Single,...
                        'Visible','on',...
                        'String', ['\chi^2_{red.} = ' sprintf('%1.2f',PDAMeta.chi2(i))]);
                catch
                    set(PDAMeta.Chi2_Single,...
                        'Visible','on',...
                        'String', '\chi^2_{red.} = N/A');
                end
                % file is shown on the 'Single' tab
                set(PDAMeta.Plots.Gauss_Single{1,1},...
                    'Visible', 'on',...
                    'YData', sum(vertcat(Gauss{:}),1));
                for c = PDAMeta.Comp{i}
                    set(PDAMeta.Plots.Gauss_Single{1,c+1},...
                        'Visible', 'on',...
                        'YData', Gauss{c});
                end
                % set Ylim of the single plot Gauss
                ylim(h.SingleTab.Gauss_Axes,[min(GaussSum), max(GaussSum)*1.05]);
            end
            
            clear Gauss
        end
        %%% Set Gauss Axis X limit
        % get fit parameters
        FitTable = FitTable(1:end-3,2:3:end-1);
        % get all active files and components
        Mini = 40; Maxi = 60;
        for i = Active
            for c = comp
                Mini = min(Mini, FitTable(i,3*c-1)-3*FitTable(i,3*c));
                Maxi = max(Maxi, FitTable(i,3*c-1)+3*FitTable(i,3*c));
            end
        end
        Maxi = min(Maxi,150);
        xlim(h.AllTab.Gauss_Axes,[Mini, Maxi]);
        xlim(h.SingleTab.Gauss_Axes,[Mini, Maxi]);
        %xlim(h.AllTab.Gauss_Axes,[20 70]);
        %xlim(h.SingleTab.Gauss_Axes,[20 70]);
        
        %%% Set Gauss Axis Y limit
        ylim(h.AllTab.Gauss_Axes,[minGaussSum, maxGaussSum*1.05]);
    case 5 %% Live Plot update
        i = PDAMeta.file;
        % PDAMeta.Comp{i} = index of the gaussian component that is used
        set(PDAMeta.Plots.Res_All{i},...
            'Visible', 'on',...
            'YData', [PDAMeta.w_res{i} PDAMeta.w_res{i}(end)]);
        if h.SettingsTab.OuterBins_Fix.Value
            % do not display or take into account during fitting, the
            % outer bins of the histogram.
            ydatafit = [PDAMeta.hFit{i}(2) PDAMeta.hFit{i}(2:end-1) PDAMeta.hFit{i}(end-1) PDAMeta.hFit{i}(end-1)];
            ydatares = [PDAMeta.w_res{i}(2) PDAMeta.w_res{i}(2:end-1) PDAMeta.w_res{i}(end-1) PDAMeta.w_res{i}(end-1)];
        else
            ydatafit = [PDAMeta.hFit{i} PDAMeta.hFit{i}(end)];
            ydatares = [PDAMeta.w_res{i} PDAMeta.w_res{i}(end)];
        end
        for c = PDAMeta.Comp{i}
            if h.SettingsTab.OuterBins_Fix.Value
                % do not display or take into account during fitting, the
                % outer bins of the histogram.
                ydatafitind = [PDAMeta.hFit_Ind{i,c}(2); PDAMeta.hFit_Ind{i,c}(2:end-1); PDAMeta.hFit_Ind{i,c}(end-1); PDAMeta.hFit_Ind{i,c}(end-1)];
            else
                ydatafitind = [PDAMeta.hFit_Ind{i,c}; PDAMeta.hFit_Ind{i,c}(end)];
            end
            set(PDAMeta.Plots.Fit_All{i,c+1},...
                'Visible', 'on',...
                'YData', ydatafitind./sum(ydatafit));
        end
        if h.SettingsTab.DynamicModel.Value
            % plot the summed dynamic component
            if h.SettingsTab.OuterBins_Fix.Value
                % do not display or take into account during fitting, the
                % outer bins of the histogram.
                ydatafitind = [PDAMeta.hFit_onlyDyn{i}(2); PDAMeta.hFit_onlyDyn{i}(2:end-1); PDAMeta.hFit_onlyDyn{i}(end-1); PDAMeta.hFit_onlyDyn{i}(end-1)];
            else
                ydatafitind = [PDAMeta.hFit_onlyDyn{i}; PDAMeta.hFit_onlyDyn{i}(end)];
            end
            set(PDAMeta.Plots.Fit_All{i,8},...
                'Visible', 'on',...
                'YData', ydatafitind./sum(ydatafit));
        else
            set(PDAMeta.Plots.Fit_All{i,8},'Visible', 'off');
        end
        set(PDAMeta.Plots.Fit_All{i,1},...
            'Visible', 'on',...
            'YData', ydatafit./sum(ydatafit));
        
        if i == Active(h.SingleTab.Popup.Value)
            set(PDAMeta.Plots.Res_Single,...
                'Visible', 'on',...
                'YData', ydatares);
            for c = PDAMeta.Comp{i}
                if h.SettingsTab.OuterBins_Fix.Value
                    % do not display or take into account during fitting, the
                    % outer bins of the histogram.
                    ydatafitind = [PDAMeta.hFit_Ind{i,c}(2); PDAMeta.hFit_Ind{i,c}(2:end-1); PDAMeta.hFit_Ind{i,c}(end-1); PDAMeta.hFit_Ind{i,c}(end-1)];
                else
                    ydatafitind = [PDAMeta.hFit_Ind{i,c}; PDAMeta.hFit_Ind{i,c}(end)];
                end
                set(PDAMeta.Plots.Fit_Single{1,c+1},...
                    'Visible', 'on',...
                    'YData', ydatafitind);
                %%% donor only plot (plot #7)
                if PDAMeta.FitParams(i,19) > 0 %%% donor only existent
                    if h.SettingsTab.OuterBins_Fix.Value
                        % do not display or take into account during fitting, the
                        % outer bins of the histogram.
                        ydatafitind = [PDAMeta.hFit_Donly{i}(2); PDAMeta.hFit_Donly{i}(2:end-1); PDAMeta.hFit_Donly{i}(end-1); PDAMeta.hFit_Donly{i}(end-1)];
                    else
                        ydatafitind = [PDAMeta.hFit_Donly{i}'; PDAMeta.hFit_Donly{i}(end)];
                    end
                    PDAMeta.Plots.Fit_All{i,7}.Visible = 'on';
                    PDAMeta.Plots.Fit_All{i,7}.YData = ydatafitind./sum(ydatafit);
                    PDAMeta.Plots.Fit_Single{i,7}.Visible = 'on';
                    PDAMeta.Plots.Fit_Single{i,7}.YData = ydatafitind;
                    PDAMeta.Plots.Gauss_All{i,7}.Visible = 'off'; % hide distance distribution as it does not apply
                else
                    PDAMeta.Plots.Fit_All{i,7}.Visible = 'off';
                end
            end
            if h.SettingsTab.DynamicModel.Value
                % plot the summed dynamic component
                if h.SettingsTab.OuterBins_Fix.Value
                    % do not display or take into account during fitting, the
                    % outer bins of the histogram.
                    ydatafitind = [PDAMeta.hFit_onlyDyn{i}(2); PDAMeta.hFit_onlyDyn{i}(2:end-1); PDAMeta.hFit_onlyDyn{i}(end-1); PDAMeta.hFit_onlyDyn{i}(end-1)];
                else
                    ydatafitind = [PDAMeta.hFit_onlyDyn{i}; PDAMeta.hFit_onlyDyn{i}(end)];
                end
                set(PDAMeta.Plots.Fit_Single{1,8},...
                    'Visible', 'on',...
                    'YData', ydatafitind);
                colors = lines(4);
                % state 1
                PDAMeta.Plots.Fit_Single{1,2}.Color = colors(1,:);%[1 0 1];
                % state 2
                PDAMeta.Plots.Fit_Single{1,3}.Color = colors(2,:);%[0 1 1];
                if h.SettingsTab.DynamicSystem.Value == 2
                    % state 3
                    PDAMeta.Plots.Fit_Single{1,4}.Color = colors(4,:);%[0.4706 0.6706 0.18821];
                end
                % in between 1 and 2
                PDAMeta.Plots.Fit_Single{1,8}.Color = colors(3,:);%[1 1 0];
            else
                set(PDAMeta.Plots.Fit_Single{1,8},'Visible', 'off');
                PDAMeta.Plots.Fit_Single{1,2}.Color = [0.2 0.2 0.2];
                PDAMeta.Plots.Fit_Single{1,3}.Color = [0.2 0.2 0.2];
                PDAMeta.Plots.Fit_Single{1,8}.Color = [0.2 0.2 0.2];
            end
            
            set(PDAMeta.Plots.Fit_Single{1,1},...
                'Visible', 'on',...
                'YData', ydatafit);
        end
end

%% update active status 
%PDAMeta.PreparationDone = 0; %recalculate histogram (why?)
for i = 1:numel(PDAData.FileName)
    if cell2mat(h.FitTab.Table.Data(i,1))
        %active
        tex = 'on';
    else
        tex = 'off';
    end
    PDAMeta.Plots.Data_All{i}.Visible = tex;
    if sum(PDAMeta.Plots.Res_All{i}.YData) ~= 0
        % data has been fitted before
        PDAMeta.Plots.Res_All{i}.Visible = tex;
    end
    PDAMeta.Plots.BSD_All{i}.Visible = tex;
    for j = 1:7
        % 1 = all
        % 2:6 = substates
        % 7 = D only
        % 8 = all dynamic bursts
        if sum(PDAMeta.Plots.Fit_All{i,j}.YData) ~= 0
            % data has been fitted before and component exists
            PDAMeta.Plots.Fit_All{i,j}.Visible = tex;
            PDAMeta.Plots.Gauss_All{i,j}.Visible = tex;
        end  
    end
    % Update the 'Single' tab plots
    if isempty(Active)
        PDAMeta.Plots.Data_Single.Visible = 'off';
        if sum(PDAMeta.Plots.Res_Single.YData) ~= 0
            % data has been fitted before
            PDAMeta.Plots.Res_Single.Visible = 'off';
        end
        PDAMeta.Plots.BSD_Single.Visible = 'off';
        for j = 1:7
            % 1 = all
            % 2:6 = substates
            % 7 = D only
            % 8 = all dynamic bursts
            if sum(PDAMeta.Plots.Fit_Single{1,j}.YData) ~= 0
                % data has been fitted before and component exists
                PDAMeta.Plots.Fit_Single{1,j}.Visible = 'off';
                PDAMeta.Plots.Gauss_Single{1,j}.Visible = 'off';
            end
        end
    end
end
        
%% store settings in UserValues
UserValues.PDA.NoBins = h.SettingsTab.NumberOfBins_Edit.String;
UserValues.PDA.MinPhotons = h.SettingsTab.NumberOfPhotMin_Edit.String;
UserValues.PDA.MaxPhotons = h.SettingsTab.NumberOfPhotMax_Edit.String;
UserValues.PDA.GridRes = h.SettingsTab.NumberOfBinsE_Edit.String;
UserValues.PDA.GridRes_PofT = h.SettingsTab.NumberOfBinsT_Edit.String;
UserValues.PDA.Smin = h.SettingsTab.StoichiometryThresholdLow_Edit.String;
UserValues.PDA.Smax = h.SettingsTab.StoichiometryThresholdHigh_Edit.String;
UserValues.PDA.Dynamic = h.SettingsTab.DynamicModel.Value;
UserValues.PDA.FixSigmaAtFraction = h.SettingsTab.FixSigmaAtFractionOfR.Value;
UserValues.PDA.SigmaAtFractionOfR = h.SettingsTab.SigmaAtFractionOfR_edit.String;
UserValues.PDA.FixSigmaAtFractionFix = h.SettingsTab.FixSigmaAtFractionOfR_Fix.Value;
UserValues.PDA.IgnoreOuterBins = h.SettingsTab.OuterBins_Fix.Value;
UserValues.PDA.HalfGlobal = h.SettingsTab.SampleGlobal.Value;
UserValues.PDA.DeconvoluteBackground =  h.SettingsTab.DeconvoluteBackground.Value;
if obj == h.SettingsTab.DeconvoluteBackground
    PDAMeta.PreparationDone(:) = 0;
    
    if h.SettingsTab.DeconvoluteBackground.Value == 1 %%% disable other methods that are not supported
        h.SettingsTab.PDAMethod_Popupmenu.String = {'Histogram Library'};
        h.SettingsTab.PDAMethod_Popupmenu.Value = 1;
    else
        if ~h.SettingsTab.DynamicModel.Value
            h.SettingsTab.PDAMethod_Popupmenu.String = {'Histogram Library','MLE','MonteCarlo'};
        end
    end
end
LSUserValues(1)

% File menu - view/start fitting
function Start_PDA_Fit(obj,~)
global PDAData PDAMeta UserValues
h = guidata(findobj('Tag','GlobalPDAFit'));
%%% disable Fit Menu and Fit parameters table
h.FitTab.Table.Enable='off';
h.KineticRates_table.Enable = 'off';
%%% Indicates fit in progress
PDAMeta.FitInProgress = 1;
%%% Specify the update interval (used for interrupting of fit and updating
%%% of chi2 display)
%%% given in units of fit iterations (function evaluations)
PDAMeta.UpdateInterval = 1;
%%% Set the fit iteration (function evaluation) counter to 0
PDAMeta.Fit_Iter_Counter = 0;
Update_Plots(obj,[],3); % reset plots
%%% do lifetime pda
if h.SettingsTab.Use_Lifetime.Value == 1
    PDAMeta.lifetime_PDA = true;
else
    PDAMeta.lifetime_PDA = false;
end
PDAMeta.GridRes_PofT = str2double(UserValues.PDA.GridRes_PofT);
PDAMeta.xAxisUnit = h.SettingsTab.XAxisUnit_Menu.String{h.SettingsTab.XAxisUnit_Menu.Value};
PDAMeta.xAxisLimLow = str2double(h.SettingsTab.MainAxisLimtsLow_Edit.String);
PDAMeta.xAxisLimHigh = str2double(h.SettingsTab.MainAxisLimtsHigh_Edit.String);
%% Store parameters globally for easy access during fitting
try
    PDAMeta = rmfield(PDAMeta, 'BGdonor');
    PDAMeta = rmfield(PDAMeta, 'BGacc');
    PDAMeta = rmfield(PDAMeta, 'crosstalk');
    PDAMeta = rmfield(PDAMeta, 'R0');
    PDAMeta = rmfield(PDAMeta, 'directexc');
    PDAMeta = rmfield(PDAMeta, 'gamma');
    if isfield(PDAMeta,'ConfInt_Jac')
        PDAMeta = rmfield(PDAMeta, 'ConfInt_Jac');
    end
    if isfield(PDAMeta,'ConfInt_MCMC')
        PDAMeta = rmfield(PDAMeta, 'ConfInt_MCMC');
    end
    if isfield(PDAMeta,'MCMC_mean')
        PDAMeta = rmfield(PDAMeta, 'MCMC_mean');
    end
end
allsame = 1;
calc = 1;
for i = 1:numel(PDAData.FileName)
    % if all files have the same parameters as the ALL row some things will only be calculated once
    if ~isequal(cell2mat(h.ParametersTab.Table.Data(i,:)),cell2mat(h.ParametersTab.Table.Data(end,:)))
        if ~isequal(cell2mat(h.ParametersTab.Table.Data(i,1:end-1)),cell2mat(h.ParametersTab.Table.Data(end,1:end-1)))
            allsame = 0;
        end
    end
    PDAMeta.BGdonor(i) = cell2mat(h.ParametersTab.Table.Data(i,4));
    PDAMeta.BGacc(i) = cell2mat(h.ParametersTab.Table.Data(i,5));
    PDAMeta.crosstalk(i) = cell2mat(h.ParametersTab.Table.Data(i,3));
    PDAMeta.R0(i) = cell2mat(h.ParametersTab.Table.Data(i,6));
    PDAMeta.directexc(i) = cell2mat(h.ParametersTab.Table.Data(i,2));
    PDAMeta.gamma(i) = cell2mat(h.ParametersTab.Table.Data(i,1));
    % Make Plots invisible
    for c = 1:8
        PDAMeta.Plots.Fit_All{i,c}.Visible = 'off';
        PDAMeta.Plots.Gauss_All{i,c}.Visible = 'off';
    end
    PDAMeta.Plots.Res_All{i}.Visible = 'off';
    
    if i == h.SingleTab.Popup.Value
        for c = 1:8
            PDAMeta.Plots.Fit_Single{1,c}.Visible = 'off';
            PDAMeta.Plots.Gauss_Single{1,c}.Visible = 'off';
        end
        PDAMeta.Plots.Res_Single.Visible = 'off';
    end
end
Nobins = str2double(h.SettingsTab.NumberOfBins_Edit.String);
NobinsE = str2double(h.SettingsTab.NumberOfBinsE_Edit.String);

% Store active globally at this point. Do not access it globally from
% anywhere else to avoid confusion!
PDAMeta.Active = cell2mat(h.FitTab.Table.Data(1:end-3,1));
%%% if the single tab is selected, only fit this dataset!
if h.Tabgroup_Up.SelectedTab == h.SingleTab.Tab
    PDAMeta.Active(:) = false;
    %%% find which is selected
    selected = find(strcmp(PDAData.FileName,h.SingleTab.Popup.String{h.SingleTab.Popup.Value}));
    PDAMeta.Active(selected) = true;
end
    
%%% Read fit settings and store in UserValues
%% Prepare Fit Inputs
if (any(PDAMeta.PreparationDone(PDAMeta.Active) == 0)) || ~isfield(PDAMeta,'eps_grid')
    Progress(0,h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Preparing fit...');
    Progress(0,h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Preparing fit...');
    counter = 1;
    maxN = 0;
    for i  = find(PDAMeta.Active)'
        if strcmp(PDAData.Type{i},'Burst')
            %%% find valid bins (chosen by thresholds min/max and stoichiometry)
            StoAll = (PDAData.Data{i}.NF+PDAData.Data{i}.NG)./(PDAData.Data{i}.NG+PDAData.Data{i}.NF+PDAData.Data{i}.NR);
            PDAMeta.valid{i} = ((StoAll >= str2double(h.SettingsTab.StoichiometryThresholdLow_Edit.String))) & ... % Stoichiometry low
                    ((StoAll <= str2double(h.SettingsTab.StoichiometryThresholdHigh_Edit.String))); % Stoichiometry high
            if ~h.SettingsTab.ScaleNumberOfPhotons_Checkbox.Value % no scaling of the minimum number of photons
                PDAMeta.valid{i} = PDAMeta.valid{i} & ...
                    ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) > str2double(h.SettingsTab.NumberOfPhotMin_Edit.String)) & ... % min photon number
                    ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) < str2double(h.SettingsTab.NumberOfPhotMax_Edit.String)); % max photon number   
            else % minimum number of photons scale with the time window size
                % the minimum and maximum number of photons are multiplied
                % by the time window in milliseconds, i.e. the 1 ms
                % measurement is the reference
                PDAMeta.valid{i} = PDAMeta.valid{i} & ...
                    ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) > PDAData.timebin(i)*1000*str2double(h.SettingsTab.NumberOfPhotMin_Edit.String)) & ... % min photon number
                    ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) < PDAData.timebin(i)*1000*str2double(h.SettingsTab.NumberOfPhotMax_Edit.String)); % max photon number   

            end
        else
            if ~h.SettingsTab.ScaleNumberOfPhotons_Checkbox.Value % no scaling of the minimum number of photons
                PDAMeta.valid{i} = (PDAData.Data{i}.NF+PDAData.Data{i}.NG) < str2double(h.SettingsTab.NumberOfPhotMax_Edit.String);
            else % minimum number of photons scale with the time window size
                % the minimum and maximum number of photons are multiplied
                % by the time window in milliseconds, i.e. the 1 ms
                % measurement is the reference
                 PDAMeta.valid{i} = (PDAData.Data{i}.NF+PDAData.Data{i}.NG) < PDAData.timebin(i)*1000*str2double(h.SettingsTab.NumberOfPhotMax_Edit.String);
            end
        end
        %%% find the maxN of all data
        maxN = max(maxN, max((PDAData.Data{i}.NF(PDAMeta.valid{i})+PDAData.Data{i}.NG(PDAMeta.valid{i}))));
    end

    for i  = find(PDAMeta.Active)'
        Progress((i-1)./numel(PDAMeta.Active),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Preparing fit...');
        Progress((i-1)./numel(PDAMeta.Active),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Preparing fit...');
            
        if ~PDAMeta.FitInProgress
            break;
        end
        if PDAMeta.PreparationDone(i) == 1
            %disp(sprintf('skipping file %i',i));
            continue; %skip this file
        end
        if counter > 1
            if allsame
                %calculate some things only once
                calc = 0;
            end
        end
        PDAMeta.P(i,:) = cell(1,NobinsE+1);
        if calc
            %%% evaluate the background probabilities
            BGgg = poisspdf(0:1:maxN,PDAMeta.BGdonor(i)*PDAData.timebin(i)*1E3);
            BGgr = poisspdf(0:1:maxN,PDAMeta.BGacc(i)*PDAData.timebin(i)*1E3);
            
            method = 'cdf';
            switch method
                case 'pdf'
                    %determine boundaries for background inclusion
                    BGgg(BGgg<1E-2) = [];
                    BGgr(BGgr<1E-2) = [];
                case 'cdf'
                    %%% evaluate the background probabilities
                    CDF_BGgg = poisscdf(0:1:maxN,PDAMeta.BGdonor(i)*PDAData.timebin(i)*1E3);
                    CDF_BGgr = poisscdf(0:1:maxN,PDAMeta.BGacc(i)*PDAData.timebin(i)*1E3);
                    %determine boundaries for background inclusion
                    threshold = 0.95;
                    BGgg((find(CDF_BGgg>threshold,1,'first')+1):end) = [];
                    BGgr((find(CDF_BGgr>threshold,1,'first')+1):end) = [];
            end
            PBG = BGgg./sum(BGgg);
            PBR = BGgr./sum(BGgr);
            NBG = numel(BGgg)-1;
            NBR = numel(BGgr)-1;
        end
        % assign current file to global cell
        PDAMeta.PBG{i} = PBG;
        PDAMeta.PBR{i} = PBR;
        PDAMeta.NBG{i} = NBG;
        PDAMeta.NBR{i} = NBR;
        
        if any(strcmp(h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value},{'Histogram Library','MLE'}))
            if calc
                %%% prepare epsilon grid               
                
                % generate NobinsE+1 values for eps
                %E_grid = linspace(0,1,NobinsE+1);
                %R_grid = linspace(0,5*PDAMeta.R0(i),100000)';
                %epsEgrid = 1-(1+PDAMeta.crosstalk(i)+PDAMeta.gamma(i)*((E_grid+PDAMeta.directexc(i)/(1-PDAMeta.directexc(i)))./(1-E_grid))).^(-1);
                %epsRgrid = 1-(1+PDAMeta.crosstalk(i)+PDAMeta.gamma(i)*(((PDAMeta.directexc(i)/(1-PDAMeta.directexc(i)))+(1./(1+(R_grid./PDAMeta.R0(i)).^6)))./(1-(1./(1+(R_grid./PDAMeta.R0(i)).^6))))).^(-1);
                
                %%% new: use linear distribution of eps since the
                %%% conversion of P(R) to P(eps) returns a probability
                %%% density, that would have to be converted to a
                %%% probability by multiplying with the bin width.
                %%% Instead, usage of a linear grid of eps ensures that the
                %%% returned P(eps) is directly a probabilty
                eps_min = 1-(1+PDAMeta.crosstalk(i)+PDAMeta.gamma(i)*((0+PDAMeta.directexc(i)/(1-PDAMeta.directexc(i)))./(1-0))).^(-1);
                eps_grid = linspace(eps_min,1,NobinsE+1);
                [NF, N, eps] = meshgrid(0:maxN,1:maxN,eps_grid);
                % generates a grid cube:
                % NF all possible number of FRET photons
                % N all possible total number of photons
                % eps all possible FRET efficiencies
                % generate a P(NF) cube given fixed initial values of NF, N and given particular values of eps 
                PNF = calc_PNF(NF(:),N(:),eps(:),numel(NF));
                PNF = reshape(PNF,size(eps,1),size(eps,2),size(eps,3));
                %PNF = binopdf(NF, N, eps);
                % binopdf(X,N,P) returns the binomial probability density function with parameters N and P at the values in X.
                %%% Also calculate distribution for donor only
                PNF_donly = binopdf(NF(:,:,1),N(:,:,1),PDAMeta.crosstalk(i)/(1+PDAMeta.crosstalk(i)));
            end
            if ~UserValues.PDA.DeconvoluteBackground
                % histogram NF+NG into maxN+1 bins
                PN = histcounts((PDAData.Data{i}.NF(PDAMeta.valid{i})+PDAData.Data{i}.NG(PDAMeta.valid{i})),1:(maxN+1));
            else
                PN = deconvolute_PofF(PDAData.Data{i}.NF(PDAMeta.valid{i})+PDAData.Data{i}.NG(PDAMeta.valid{i}),(PDAMeta.BGdonor(i)+PDAMeta.BGacc(i))*PDAData.timebin(i)*1E3);
                PN = PN(1:maxN).*sum(PDAMeta.valid{i} &  ~((PDAData.Data{i}.NG == 0) & (PDAData.Data{i}.NF == 0)));
            end
            % assign current file to global cell
            %PDAMeta.E_grid{i} = E_grid;
            %PDAMeta.R_grid{i} = R_grid;
            PDAMeta.eps_grid{i} = eps_grid;
            %PDAMeta.epsRgrid{i} = epsRgrid;
            PDAMeta.PN{i} = PN;
            PDAMeta.PNF{i} = PNF;
            PDAMeta.PNF_donly{i} = PNF_donly;
            PDAMeta.Grid.NF{i} = NF;
            PDAMeta.Grid.N{i} = N;
            PDAMeta.Grid.eps{i} = eps;
            PDAMeta.maxN{i} = maxN;
            
            Progress((i-1+0.2)./numel(PDAMeta.Active),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Preparing fit...');
            Progress((i-1+0.2)./numel(PDAMeta.Active),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Preparing fit...');
            %% Calculate Histogram Library (CalcHistLib)            
            PDAMeta.HistLib = [];
            P = cell(1,numel(eps_grid));
            PN_dummy = PN';
            %% Calculate shot noise limited histogram
            % case 1, no background in either channel
            if NBG == 0 && NBR == 0
                for j = 1:numel(eps_grid)
                    %for a particular value of E
                    P_temp = PNF(:,:,j);
                    switch PDAMeta.xAxisUnit
                        case 'Proximity Ratio'
                            E_temp = NF(:,:,j)./N(:,:,j);
                            minE = 0; maxE = 1;
                        case 'log(FD/FA)'
                            E_temp = real(log10((N(:,:,j)-NF(:,:,j))./NF(:,:,j)));
                            %minE = min(E_temp(:)); maxE = max(E_temp(:));
                            minE = h.AllTab.Main_Axes.XLim(1);
                            maxE = h.AllTab.Main_Axes.XLim(2);
                        case {'FRET efficiency','Distance'}
                            % Background correction
                            NF_cor = NF(:,:,j);
                            ND_cor = N(:,:,j)-NF(:,:,j);
                            % crosstalk and direct excitation correction
                            % (direct excitation based on Schuler method
                            % using the corrected total number of photon
                            % and the direct excitation factor as defined
                            % for PDA as p_de =
                            % eps_A^lambdaD/(eps_A^lambdaD+eps_D^lambdaD),
                            % i.e. the probability that the acceptor is
                            % excited by the donor laser using the
                            % exctinction coefficients at the donor
                            % excitation wavelength.
                            % see: Nettels, D. et al. Excited-state annihilation reduces power dependence of single-molecule FRET experiments. Physical Chemistry Chemical Physics 17, 32304-32315 (2015).
                            NF_cor = NF_cor - PDAMeta.crosstalk(i)*ND_cor-PDAMeta.directexc(i)*(PDAMeta.gamma(i)*ND_cor+NF_cor);
                            E_temp = NF_cor./(PDAMeta.gamma(i)*ND_cor+NF_cor);                           
                            if strcmp(PDAMeta.xAxisUnit,'Distance')
                                valid_distance = E_temp > 0;
                                % convert to distance
                                E_temp = real(PDAMeta.R0(i)*(1./E_temp-1).^(1/6));
                                E_temp = E_temp(valid_distance);
                                P_temp = P_temp(valid_distance);
                            end
                            %minE = min(E_temp); maxE = max(E_temp);
                            minE = h.AllTab.Main_Axes.XLim(1);
                            maxE = h.AllTab.Main_Axes.XLim(2);
                    end
                    [~,~,bin] = histcounts(E_temp(:),linspace(minE,maxE,Nobins+1));
                    validd = (bin ~= 0);
                    P_temp = P_temp(:);
                    bin = bin(validd);
                    P_temp = P_temp(validd);
                    %%% Store bin,valid and P_temp variables for brightness correction
                    PDAMeta.HistLib.bin{i}{j} = bin;
                    PDAMeta.HistLib.P_array{i}{j} = P_temp;
                    PDAMeta.HistLib.valid{i}{j} = validd;

                    PN_trans = repmat(PN_dummy,1,maxN+1);
                    PN_trans = PN_trans(:);
                    PN_trans = PN_trans(PDAMeta.HistLib.valid{i}{j});
                    P{1,j} = accumarray(PDAMeta.HistLib.bin{i}{j},PDAMeta.HistLib.P_array{i}{j}.*PN_trans);
                end
            else
                for j = 1:numel(eps_grid)
                    bin = cell((NBG+1)*(NBR+1),1);
                    P_array = cell((NBG+1)*(NBR+1),1);
                    validd = cell((NBG+1)*(NBG+1),1);
                    count = 1;
                    for g = 0:NBG
                        for r = 0:NBR
                            P_temp = PBG(g+1)*PBR(r+1)*PNF(1:end-g-r,:,j); %+1 since also zero is included
                            switch PDAMeta.xAxisUnit
                                case 'Proximity Ratio'
                                    E_temp = (NF(1:end-g-r,:,j)+r)./(N(1:end-g-r,:,j)+g+r);
                                    minE = 0; maxE = 1; 
                                case 'log(FD/FA)'
                                    E_temp = real(log10((N(1:end-g-r,:,1)-NF(1:end-g-r,:,1)+g)./(NF(1:end-g-r,:,1)+r)));
                                    %minE = min(E_temp(:)); maxE = max(E_temp(:));
                                    minE = h.AllTab.Main_Axes.XLim(1);
                                    maxE = h.AllTab.Main_Axes.XLim(2);
                                case {'FRET efficiency','Distance'}
                                    % Background correction
                                    NF_cor = NF(1:end-g-r,:,j);
                                    ND_cor = N(1:end-g-r,:,j)-NF(1:end-g-r,:,j);
                                    % crosstalk and direct excitation correction
                                    % (direct excitation based on Schuler method
                                    % using the corrected total number of photon
                                    % and the direct excitation factor as defined
                                    % for PDA as p_de =
                                    % eps_A^lambdaD/(eps_A^lambdaD+eps_D^lambdaD),
                                    % i.e. the probability that the acceptor is
                                    % excited by the donor laser using the
                                    % exctinction coefficients at the donor
                                    % excitation wavelength.
                                    % see: Nettels, D. et al. Excited-state annihilation reduces power dependence of single-molecule FRET experiments. Physical Chemistry Chemical Physics 17, 32304-32315 (2015).
                                    NF_cor = NF_cor - PDAMeta.crosstalk(i)*ND_cor-PDAMeta.directexc(i)*(PDAMeta.gamma(i)*ND_cor+NF_cor);
                                    E_temp = NF_cor./(PDAMeta.gamma(i)*ND_cor+NF_cor);                           
                                    if strcmp(PDAMeta.xAxisUnit,'Distance')
                                        valid_distance = E_temp > 0;
                                        % convert to distance
                                        E_temp = real(PDAMeta.R0(i)*(1./E_temp-1).^(1/6));
                                        E_temp = E_temp(valid_distance);
                                        P_temp = P_temp(valid_distance);
                                    end
                                    %minE = min(E_temp(:)); maxE = max(E_temp(:));
                                    minE = h.AllTab.Main_Axes.XLim(1);
                                    maxE = h.AllTab.Main_Axes.XLim(2);
                            end
                            [~,~,bin{count}] = histcounts(E_temp(:),linspace(minE,maxE,Nobins+1));
                            validd{count} = (bin{count} ~= 0);
                            P_temp = P_temp(:);
                            bin{count} = bin{count}(validd{count});
                            P_temp = P_temp(validd{count});
                            P_array{count} = P_temp;
                            count = count+1;
                        end
                    end
                    
                    %%% Store bin,valid and P_array variables for brightness
                    %%% correction
                    PDAMeta.HistLib.bin{i}{j} = bin;
                    PDAMeta.HistLib.P_array{i}{j} = P_array;
                    PDAMeta.HistLib.valid{i}{j} = validd;
                            
                    P{1,j} = zeros(Nobins,1);
                    count = 1;
                    if ~UserValues.PDA.DeconvoluteBackground
                        for g = 0:NBG
                            for r = 0:NBR
                                %%% Approximation of P(F) ~= P(S), i.e. use
                                %%% P(S) with S = F + BG
                                PN_trans = repmat(PN_dummy(1+g+r:end),1,maxN+1);%the total number of fluorescence photons is reduced
                                PN_trans = PN_trans(:);
                                PN_trans = PN_trans(validd{count});
                                %P{1,j} = P{1,j} + [accumarray(bin{count},P_array{count}.*PN_trans); zeros(Nobins-max(bin{count}),1)];
                                P{1,j} = P{1,j} + [accumarray_c(bin{count},P_array{count}.*PN_trans,max(bin{count}),numel(bin{count}))'; zeros(Nobins-max(bin{count}),1)];
                                count = count+1;
                            end
                        end
                    else
                        for g = 0:NBG
                            for r = 0:NBR
                                %%% Use the deconvolved P(F)
                                PN_trans = repmat(PN_dummy(1:end-g-r),1,maxN+1);%the total number of fluorescence photons is reduced
                                PN_trans = PN_trans(:);
                                PN_trans = PN_trans(validd{count});
                                %P{1,j} = P{1,j} + [accumarray(bin{count},P_array{count}.*PN_trans); zeros(Nobins-max(bin{count}),1)];
                                P{1,j} = P{1,j} + [accumarray_c(bin{count},P_array{count}.*PN_trans,max(bin{count}),numel(bin{count}))'; zeros(Nobins-max(bin{count}),1)];
                                count = count+1;
                            end
                        end
                    end                   
                end
            end
            Progress((i-1+0.8)./numel(PDAMeta.Active),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Preparing fit...');
            Progress((i-1+0.8)./numel(PDAMeta.Active),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Preparing fit...');
            %% Caclulate shot noise limited histogram for Donly
            if NBG == 0 && NBR == 0
                %for a particular value of E
                P_temp = PNF_donly;
                switch PDAMeta.xAxisUnit
                    case 'Proximity Ratio'
                        E_temp = NF(:,:,1)./N(:,:,1);
                        minE = 0; maxE = 1; 
                    case 'log(FD/FA)'
                        E_temp = real(log10((N(:,:,1)-NF(:,:,1))./NF(:,:,1)));
                        %minE = min(E_temp(:)); maxE = max(E_temp(:));
                        minE = h.AllTab.Main_Axes.XLim(1);
                        maxE = h.AllTab.Main_Axes.XLim(2);
                    case {'FRET efficiency','Distance'}
                        NF_cor = NF(:,:,1);
                        ND_cor = N(:,:,1)-NF(:,:,1);
                        NF_cor = NF_cor - PDAMeta.crosstalk(i)*ND_cor-PDAMeta.directexc(i)*(PDAMeta.gamma(i)*ND_cor+NF_cor);
                        E_temp = NF_cor./(PDAMeta.gamma(i)*ND_cor+NF_cor);                           
                        if strcmp(PDAMeta.xAxisUnit,'Distance')
                            valid_distance = E_temp > 0;
                            % convert to distance
                            E_temp = real(PDAMeta.R0(i)*(1./E_temp-1).^(1/6));
                            E_temp = E_temp(valid_distance);
                            P_temp = P_temp(valid_distance);                         
                        end
                        %minE = min(E_temp(:)); maxE = max(E_temp(:));
                        minE = h.AllTab.Main_Axes.XLim(1);
                        maxE = h.AllTab.Main_Axes.XLim(2);
                end
                [~,~,bin] = histcounts(E_temp(:),linspace(minE,maxE,Nobins+1));
                validd = (bin ~= 0);
                P_temp = P_temp(:);
                bin = bin(validd);
                P_temp = P_temp(validd);

                PN_trans = repmat(PN_dummy,1,maxN+1);
                PN_trans = PN_trans(:);
                PN_trans = PN_trans(validd);
                P_donly = accumarray(bin,P_temp.*PN_trans);
            else
                bin = cell((NBG+1)*(NBR+1),1);
                P_array = cell((NBG+1)*(NBR+1),1);
                validd = cell((NBG+1)*(NBG+1),1);
                count = 1;
                for g = 0:NBG
                    for r = 0:NBR
                        P_temp = PBG(g+1)*PBR(r+1)*PNF_donly(1:end-g-r,:); %+1 since also zero is included
                        E_temp = (NF(1:end-g-r,:,1)+r)./(N(1:end-g-r,:,1)+g+r);
                        switch PDAMeta.xAxisUnit
                            case 'Proximity Ratio'
                                E_temp = (NF(1:end-g-r,:,1)+r)./(N(1:end-g-r,:,1)+g+r);
                                minE = 0; maxE = 1;
                            case 'log(FD/FA)'
                                E_temp = real(log10((N(1:end-g-r,:,1)-NF(1:end-g-r,:,1)+g)./(NF(1:end-g-r,:,1)+r)));
                                %minE = min(E_temp(:)); maxE = max(E_temp(:));
                                minE = h.AllTab.Main_Axes.XLim(1);
                                maxE = h.AllTab.Main_Axes.XLim(2);
                            case {'FRET efficiency','Distance'}
                                NF_cor = NF(1:end-g-r,:,1);
                                ND_cor = N(1:end-g-r,:,1)-NF(1:end-g-r,:,1);
                                NF_cor = NF_cor - PDAMeta.crosstalk(i)*ND_cor-PDAMeta.directexc(i)*(PDAMeta.gamma(i)*ND_cor+NF_cor);
                                E_temp = NF_cor./(PDAMeta.gamma(i)*ND_cor+NF_cor);                           
                                if strcmp(PDAMeta.xAxisUnit,'Distance')
                                    valid_distance = E_temp > 0;
                                    % convert to distance
                                    E_temp = real(PDAMeta.R0(i)*(1./E_temp-1).^(1/6));
                                    E_temp = E_temp(valid_distance);
                                    P_temp = P_temp(valid_distance);                           
                                end
                                %minE = min(E_temp); maxE = max(E_temp);
                                minE = h.AllTab.Main_Axes.XLim(1);
                                maxE = h.AllTab.Main_Axes.XLim(2);
                        end
                        [~,~,bin{count}] = histcounts(E_temp(:),linspace(minE,maxE,Nobins+1));
                        validd{count} = (bin{count} ~= 0);
                        P_temp = P_temp(:);
                        bin{count} = bin{count}(validd{count});
                        P_temp = P_temp(validd{count});
                        P_array{count} = P_temp;
                        count = count+1;
                    end
                end

                P_donly = zeros(Nobins,1);
                count = 1;
                if ~UserValues.PDA.DeconvoluteBackground
                    for g = 0:NBG
                        for r = 0:NBR
                            %%% Approximation of P(F) ~= P(S), i.e. use
                            %%% P(S) with S = F + BG
                            PN_trans = repmat(PN_dummy(1+g+r:end),1,maxN+1);%the total number of fluorescence photons is reduced
                            PN_trans = PN_trans(:);
                            PN_trans = PN_trans(validd{count});
                            P_donly = P_donly + [accumarray(bin{count},P_array{count}.*PN_trans); zeros(Nobins-max(bin{count}),1)];
                            count = count+1;
                        end
                    end
                else
                    for g = 0:NBG
                        for r = 0:NBR
                            %%% Use the deconvolved P(F)
                            PN_trans = repmat(PN_dummy(1:end-g-r),1,maxN+1);%the total number of fluorescence photons is reduced
                            PN_trans = PN_trans(:);
                            PN_trans = PN_trans(validd{count});
                            P_donly = P_donly + [accumarray(bin{count},P_array{count}.*PN_trans); zeros(Nobins-max(bin{count}),1)];
                            count = count+1;
                        end
                    end
                end
            end
            % different files = different rows
            % different Ps = different columns
            PDAMeta.P(i,:) = P;
            PDAMeta.P_donly{i} = P_donly;
            PDAMeta.PreparationDone(i) = 1;
        %elseif strcmp(h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value},'MLE')
            %% Calculate grid of probabilites for MLE PDA
            eps_min = 1-(1+PDAMeta.crosstalk(i)+PDAMeta.gamma(i)*((0+PDAMeta.directexc(i)/(1-PDAMeta.directexc(i)))./(1-0))).^(-1);
            PDAMeta.eps_grid{i} = linspace(eps_min,1,NobinsE+1);
            %%% Calculate the vector of likelihood values on the epsilon grid
            PDAMeta.P_grid{i} = eval_prob_2c_bg(PDAData.Data{i}.NG(PDAMeta.valid{i}),PDAData.Data{i}.NF(PDAMeta.valid{i}),...
                PDAMeta.NBG{i},PDAMeta.NBR{i},...
                PDAMeta.PBG{i}',PDAMeta.PBR{i}',...
                PDAMeta.eps_grid{i}');   
            PDAMeta.P_grid{i} = log(PDAMeta.P_grid{i});
            %% preparations related to lifetime-PDA
            if PDAMeta.lifetime_PDA
                % in principle, the following information is required:
                % first and second moments of IRF                
                IRF = PDAData.Data{i}.IRF_G;
                %%% subtract background from IRF
                IRF = IRF - mean(IRF(end-floor(numel(IRF)/10):end));
                IRF(IRF<0) = 0;         
                % consider only the PIE channel range
                range = [PDAData.Data{i}.PIE.From(1), PDAData.Data{i}.PIE.To(1)];
                IRF = IRF(range(1):range(2));
                % consider only part where IRF > 0.01 of max
                IRF = IRF./max(IRF);
                IRF(IRF < 0.01) = 0;
                IRF = IRF./sum(IRF);
                PDAMeta.IRF_moments{i}(1) = sum((1:numel(IRF)).*IRF);
                PDAMeta.IRF_moments{i}(2) = sum((1:numel(IRF)).^2.*IRF);
                PDAMeta.IRF{i} = IRF;
                %%% also, for simplicity we combine the parallel and
                %%% perpendicular decays and average the microtime
                PDAMeta.TauG{i} = double(cellfun(@mean,PDAData.Data{i}.MI_G));
                PDAMeta.TauG{i} = PDAMeta.TauG{i} - range(1) + 1;
            end
        end
        counter = counter + 1;
    end
end


%% Store fit parameters globally
PDAMeta.Fixed = cell2mat(h.FitTab.Table.Data(1:end-3,3:3:end-1));
PDAMeta.Global = cell2mat(h.FitTab.Table.Data(end-2,4:3:end-1));
LB = h.FitTab.Table.Data(end-1,2:3:end-1);
PDAMeta.LB = cellfun(@str2double,LB);
UB = h.FitTab.Table.Data(end  ,2:3:end-1);
PDAMeta.UB = cellfun(@str2double,UB);
FitTable = cellfun(@str2double,h.FitTab.Table.Data);
PDAMeta.FitParams = FitTable(1:end-3,2:3:end-1);
%%% If sigma is fixed at fraction of R, add the parameter here
if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
    PDAMeta.FitParams(:,end+1) = str2double(h.SettingsTab.SigmaAtFractionOfR_edit.String);
    %%% Set either not fixed and global, or fixed and not global
    PDAMeta.Global(:,end+1) = 1-h.SettingsTab.FixSigmaAtFractionOfR_Fix.Value;
    PDAMeta.Fixed(:,end+1) = h.SettingsTab.FixSigmaAtFractionOfR_Fix.Value;
    PDAMeta.LB(:,end+1) = 0;
    PDAMeta.UB(:,end+1) = 1;
end

%%% if three state dynamic system, read out and append the rates
if h.SettingsTab.DynamicModel.Value &&  h.SettingsTab.DynamicSystem.Value == 2
    FitTable = h.KineticRates_table.Data;
    Rates = cell2mat(FitTable(1:end-3,1:3:end));
    LB_rates = cell2mat(FitTable(end-1,1:3:end));
    UB_rates = cell2mat(FitTable(end,1:3:end));
    Fixed_rates = cell2mat(FitTable(1:end-3,2:3:end));
    Global_rates = cell2mat(FitTable(end-2,3:3:end));
    %%% sort the kinetic rates into the FitParams array in PDAMeta
    % The amplitudes of the first three species are the rates k12, k21, k31
    PDAMeta.FitParams(:,[1,4,7]) = Rates(:,[1,3,5]);
    PDAMeta.LB(:,[1,4,7]) = LB_rates(:,[1,3,5]);
    PDAMeta.UB(:,[1,4,7]) = UB_rates(:,[1,3,5]);
    PDAMeta.Fixed(:,[1,4,7]) = Fixed_rates(:,[1,3,5]);
    PDAMeta.Global(:,[1,4,7]) = Global_rates(:,[1,3,5]);
    % Append the rest to the end: fitpar = [...,k32,k13,k23]
    PDAMeta.FitParams(:,end+1:end+3) = Rates(:,[6,2,4]);
    PDAMeta.LB(:,end+1:end+3) = LB_rates(:,[6,2,4]);
    PDAMeta.UB(:,end+1:end+3) = UB_rates(:,[6,2,4]);
    PDAMeta.Fixed(:,end+1:end+3) = Fixed_rates(:,[6,2,4]);
    PDAMeta.Global(:,end+1:end+3) = Global_rates(:,[6,2,4]);
    
    % detect if the system is linear 1 <-> 2 <-> 3, i.e. k13=k31=0!
    % (for now, we only consider this case - i.e. not the general cases
    %  of 2 <-> 3 <-> 1 etc. - State 2 always is the middle state)
    if all(PDAMeta.FitParams(:,7)==0) && all(PDAMeta.FitParams(:,end-1)==0)
        PDAMeta.threestate_analytical = true;
        disp('Linear three-state model detected. Using analytical solution.');
    else
        PDAMeta.threestate_analytical = false;
        disp('General three-state model detected. Kinetics are evaluated using Monte Carlo simulations.');
    end
end
clear LB UB FitTable

if any(isnan(PDAMeta.FitParams(:)))
    disp('There were NaNs in the fit parameters. Aborting');
    h.Menu.Fit.Enable = 'on';
    return;
end

% generate a cell array, with each cell a file, and the contents of the
% cell is the gaussian components that are used per file during fitting.
Comp = cell(numel(PDAData.FileName));
for i = find(PDAMeta.Active)'
    comp = [];
    % the used gaussian fit components
    for c = 1:6
        if PDAMeta.Fixed(i,3*c-2)==false || PDAMeta.FitParams(i,3*c-2)~=0
            % Amp ~= fixed || Amp ~= 0
            comp = [comp c];
        end
    end
    Comp{i} = comp;
end
PDAMeta.Comp = Comp;

PDAMeta.chi2 = [];
PDAMeta.ConfInt = [];
PDAMeta.MCMC_mean = [];
%%
% In general, 3 ways can used for fixing parameters
% passing them into the fit function, but fixing them again to their initial value in the fit function (least elegant)
% passing them into the fit function and fixing their UB&LB to their initial value (used in PDAFit)
% not passing them into the fit function, but just calling their values inside the fit function (used in FCSFit and global PDAFit)

%%% check if global fitting should be performed
do_global = false;
if (sum(PDAMeta.Global) > 0) && (sum(PDAMeta.Active) > 1)
    do_global = true;
else %%% check if fix sigma at fraction of R option is enable
    if h.SettingsTab.FixSigmaAtFractionOfR.Value
        %%% if it is not fixed, optimize globally!
        if ~h.SettingsTab.FixSigmaAtFractionOfR_Fix.Value
            %%% but only if multiple files are fit at once
            if sum(PDAMeta.Active) > 1
                do_global = true;
            end
        end
    end
    %%% check if three-state model is used
    %if h.SettingsTab.DynamicModel.Value
    %    if sum(PDAMeta.Active) > 1 %%% more than one file active
    %        do_global = true;
    %    end
    %end
end
PDAMeta.FittingGlobal = do_global;
if do_global
    disp('Global fit');
else
    disp('Non-global fit');
end

if ~do_global
    %% One-curve-at-a-time fitting
    fit_counter = 0;
    for i = find(PDAMeta.Active)'
        fit_counter = fit_counter + 1;
        LB = PDAMeta.LB;
        UB = PDAMeta.UB;
        h.SingleTab.Popup.Value = i;
        Update_Plots([],[],2); %to ensure the correct data is plotted on single tab during fitting
        PDAMeta.file = i;
        fitpar = PDAMeta.FitParams(i,:);
        fixed = PDAMeta.Fixed(i,:);
        LB(fixed) = fitpar(fixed);
        UB(fixed) = fitpar(fixed);
        
        % Fixed for Patternsearch and fmincon
        if sum(fixed) == 0 %nothing is Fixed
            A = [];
            b = [];
        elseif sum(fixed(:)) > 0
            A = zeros(numel(fixed)); %NxN matrix with zeros
            b = zeros(numel(fixed),1);
            for j = 1:numel(fixed)
                if fixed(j) == 1 %set diagonal to 1 and b to value --> 1*x = b
                    A(j,j) = 1;
                    b(j) = fitpar(j);
                end
            end
        end
        
        switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
            case 'Histogram Library'
                fitfun = @(x) PDAHistogramFit_Single(x,h);
            case 'MLE'
                %msgbox('doesnt work yet')
                %return
                fitfun = @(x) PDA_MLE_Fit_Single(x,h);
                if strcmp(h.SettingsTab.FitMethod_Popupmenu.String{h.SettingsTab.FitMethod_Popupmenu.Value},'Gradient-based (lsqnonlin)')
                    disp('Gradient-based (lsqnonlin) does not work for MLE. Choose fmincon instead.');
                    Progress(1, h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Done');
                    Progress(1, h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Done');
                    %%% re-enable Fit Menu
                    h.FitTab.Table.Enable='on';
                    h.KineticRates_table.Enable = 'on';
                    PDAMeta.FitInProgress = 0;
                    return;
                end
            case 'MonteCarlo'
                %msgbox('doesnt work yet')
                %return
                fitfun = @(x) PDAMonteCarloFit_Single(x,h);
        end
                
        switch obj
            case h.Menu.ViewFit
                %% Check if View_Curve was pressed
                %%% Only Update Plot and break
                Progress((fit_counter-1)/sum(PDAMeta.Active),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Simulating Histograms...');
                Progress((fit_counter-1)/sum(PDAMeta.Active),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Simulating Histograms...');
                switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
                    case {'MonteCarlo'} % removed 'MLE' for now since MC is broken
                        %%% For Updating the Result Plot, use MC sampling
                        PDAMonteCarloFit_Single(fitpar,h);
                    case {'Histogram Library','MLE'}
                        PDAHistogramFit_Single(fitpar,h);
                end
            case h.Menu.StartFit
                %% evaluate once to make plots available
                switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
                    case {'MonteCarlo'} % removed 'MLE' for now since MC is broken
                        %%% For Updating the Result Plot, use MC sampling
                        PDAMonteCarloFit_Single(fitpar,h);
                    case 'Histogram Library'
                        PDAMeta.FitInProgress = 1;
                        PDAHistogramFit_Single(fitpar,h);
                    case 'MLE'
                        PDAMeta.FitInProgress = 1;
                        PDAHistogramFit_Single(fitpar,h);
                end
                %% Do Fit
                Progress((fit_counter-1)/sum(PDAMeta.Active),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Fitting Histograms...');
                Progress((fit_counter-1)/sum(PDAMeta.Active),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Fitting Histograms...');
                
                switch h.SettingsTab.FitMethod_Popupmenu.String{h.SettingsTab.FitMethod_Popupmenu.Value}
                    case 'Simplex'
                        fitopts = optimset('MaxFunEvals', 1E4,'Display','iter','TolFun',1E-6,'TolX',1E-3,'PlotFcns',@optimplotfval);
                        fitpar = fminsearchbnd(fitfun, fitpar, LB, UB, fitopts);
                    case 'Gradient-based (lsqnonlin)'
                        PDAMeta.FitInProgress = 2; % indicate that we want a vector of residuals, instead of chi2, and that we only pass non-fixed parameters
                        fitopts = optimoptions('lsqnonlin','MaxFunEvals', 1E4,'Display','iter');
                        fitpar(~fixed) = lsqnonlin(fitfun,fitpar(~fixed),LB(~fixed),UB(~fixed),fitopts);
                    case 'Gradient-based (fmincon)'
                        fitopts = optimoptions('fmincon','MaxFunEvals',1E4,'Display','iter');%,'PlotFcns',@optimplotfvalPDA);
                        fitpar = fmincon(fitfun, fitpar,[],[],A,b,LB,UB,[],fitopts);
                    case 'Patternsearch'
                        opts = optimoptions('patternsearch','Cache','off','Display','iter','PlotFcns',@psplotbestf);%,'UseParallel',true,'UseCompletePoll',true,'UseVectorized',false);
                        fitpar = patternsearch(fitfun, fitpar, [],[],A,b,LB,UB,[],opts);
                    case 'Gradient-based (global)'
                        opts = optimoptions(@fmincon,'Algorithm','interior-point','Display','iter');%,'PlotFcns',@optimplotfvalPDA);
                        problem = createOptimProblem('fmincon','objective',fitfun,'x0',fitpar,'Aeq',A,'beq',b,'lb',LB,'ub',UB,'options',opts);
                        gs = GlobalSearch;
                        fitpar = run(gs,problem);
                    case 'Simulated Annealing'
                        opts = optimoptions('simulannealbnd','Display','iter','InitialTemperature',100,'MaxTime',300);
                        fitpar = simulannealbnd(fitfun,fitpar,LB,UB,opts);
                    case 'Genetic Algorithm'
                        opts = optimoptions('ga','PlotFcn',@gaplotbestf,'Display','iter');
                        fitpar = ga(fitfun,numel(fitpar),[],[],[],[],LB,UB,[],opts);
                    case 'Particle Swarm'
                        opts = optimoptions('particleswarm','HybridFcn','patternsearch','Display','iter');
                        fitpar = particleswarm(fitfun,numel(fitpar),LB,UB,opts);
                    case 'Surrogate Optimization'
                        opts = optimoptions('surrogateopt','PlotFcn','surrogateoptplot','InitialPoints',fitpar,'MaxFunctionEvaluations',1E4);
                        fitpar = surrogateopt(fitfun,LB,UB,opts);
                end
            case {h.Menu.EstimateErrorHessian,h.Menu.EstimateErrorMCMC}
                alpha = 0.05; %95% confidence interval
                %%% get error bars from jacobian
                PDAMeta.FitInProgress = 2; % set to two to indicate error estimation based on gradient (only compute hessian with respect to non-fixed parameters)
                %call fminunc at final point with 1 iteration to get hessian
                %PDAMeta.Fixed = fixed;
                switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
                    case 'Histogram Library'
                        fitopts = optimoptions('lsqnonlin','MaxIter',1);
                        [~,~,residual,~,~,~,jacobian] = lsqnonlin(fitfun,fitpar(~fixed),LB(~fixed),UB(~fixed),fitopts);
                        ci = nlparci(fitpar(~fixed),residual,'jacobian',jacobian,'alpha',alpha);
                        ci = (ci(:,2)-ci(:,1))/2;
                        PDAMeta.ConfInt_Jac{i}= ci;
                    case 'MLE'
                        disp('Jacobian-based estimate is not available for MLE fit.');
                        PDAMeta.ConfInt_Jac = [];
                end
                
                
                %%% Alternative implementations using fminunc and fmincon to estimate the hessian
                % fitopts = optimoptions('fminunc','MaxIter',1,'Algorithm','quasi-newton');
                % [~,~,~,~,~,hessian] = fminunc(fitfun,fitpar(~fixed),fitopts);
                % fitopts = optimoptions('fmincon','MaxFunEvals',1E4,'Display','iter');%,'PlotFcns',@optimplotfvalPDA);
                % [~,~,~,~,~,~,hessian] = fmincon(fitfun, fitpar,[],[],A,b,LB,UB,[],fitopts);
                %err = sqrt(diag(inv(hessian)));
                if obj == h.Menu.EstimateErrorMCMC %%% refine by doing MCMC sampling
                        PDAMeta.FitInProgress = 3; %%% indicate that we need a loglikelihood instead of chi2 value
                        % use MCMC sampling to get errorbar estimates
                        %%% query sampling parameters
                        data = inputdlg({'Number of samples:','Spacing for statistical independence:'},'Specify MCMC sampling parameters',1,{'1000','10'});
                        data = cellfun(@str2double,data);
                        nsamples = data(1); spacing = data(2);
                        if strcmp(h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value},'Histogram Library') && ~(h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2)
                            proposal = ci'/10;
                        else
                            % estimate proposal based on fit values
                            proposal = fitpar(~fixed)*0.001;
                        end
                        
                        % get parameter names in correct order 
                        param_names = h.FitTab.Table.ColumnName(2:3:end-1)';                                              
                        % remove html tags
                        param_names = regexprep(param_names, '<.*?>','');
                        param_names = regexprep(param_names, '\[.*?\]','');
                        if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1   
                            param_names = [param_names {'sigmaF'}];
                        end
                        if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
                            param_names = [param_names {'k23','k31','k32'}];
                            param_names(strcmp(param_names,'F1')) = {'k12'};
                            param_names(strcmp(param_names,'F2')) = {'k21'};
                            param_names(strcmp(param_names,'F3')) = {'k31'};                            
                        end
                        proposal_dummy = zeros(size(fitpar)); proposal_dummy(~fixed) = proposal;
                        [samples,prob,acceptance] =  MHsample(nsamples,fitfun,@(x) 1,proposal_dummy,LB,UB,fitpar',fixed',~fixed',param_names,[],1);
                        if exist('residual','var')
                            v = numel(residual)-numel(fitpar(~fixed)); % number of degrees of freedom
                            perc = tinv(1-alpha/2,v);
                        else
                            perc = 1.96; % 95% CI
                        end
                        PDAMeta.ConfInt_MCMC{i} = perc*std(samples(1:spacing:end,~fixed))';
                        PDAMeta.MCMC_mean{i} = mean(samples(1:spacing:end,~fixed))';
                end
                PDAMeta.FitInProgress = 0; % disable fit
        end
        %Calculate chi^2
        switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
            case 'Histogram Library'
                %PDAMeta.chi2 = PDAHistogramFit_Single(fitpar);
            case 'MLE'
                %%% For Updating the Result Plot, use MC sampling
                PDAMeta.chi2(i) = PDAHistogramFit_Single(fitpar,h);
                %%% Update Plots
                h.FitTab.Bar.YData = PDAMeta.hFit;
                h.Res_Bar.YData = PDAMeta.w_res;
                for c = comp
                    h.FitTab.BarInd{i}.YData = PDAMeta.hFit_Ind{c};
                end
                if isfield(PDAMeta,'Last_logL')
                    PDAMeta = rmfield(PDAMeta,'Last_logL');
                end
            case 'MonteCarlo'
                %PDAMeta.chi2 = PDAMonteCarloFit_Single(fitpar);
            otherwise
                PDAMeta.chi2(i) = 0;
        end
        
        % display final mean chi^2
        set(PDAMeta.Chi2_All, 'Visible','on','String', ['avg. \chi^2_{red.} = ' sprintf('%1.2f',mean(PDAMeta.chi2))]);
        
        if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
            % [k12,k13,k21,k23,k31,k32]
            rates = [fitpar(1),fitpar(end-1),fitpar(4),fitpar(end),fitpar(7),fitpar(end-2)];
            h.KineticRates_table.Data(i,1:3:end) = num2cell(rates);
            %%% assign equilibrium fraction to the fitpar table
            %%% DynRates = [k11 k21 k31,
            %%%             k12 k22 k32,
            %%%             k13 k23 k33]
            DynRates = [0,rates(3),rates(5);rates(1),0,rates(6);rates(2),rates(4),0];
            for j = 1:3
                DynRates(j,j) = -sum(DynRates(:,j));
            end
            DynRates(end+1,:) = ones(1,3);
            b = zeros(3,1); b(end+1) = 1;
            p_eq = DynRates\b;
            fitpar(1) = p_eq(1);
            fitpar(4) = p_eq(2);
            fitpar(7) = p_eq(3);
            fitpar(end-2:end) = [];
        end
        
        %%% If sigma was fixed at fraction of R, update edit box here and
        %%% remove from fitpar array
        if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
            h.SettingsTab.SigmaAtFractionOfR_edit.String = num2str(fitpar(end));
            fitpar(end) = [];
            %%% if sigma is fixed at fraction of, change its value here
            fraction = str2double(h.SettingsTab.SigmaAtFractionOfR_edit.String);
            fitpar(3:3:end) = fraction.*fitpar(2:3:end);
        end
        if h.SettingsTab.FixStaticToDynamicSpecies.Value == 1
            %%% Overwrite values of static species with values of dynamic species
            fitpar([8,9,11,12]) = fitpar([2,3,5,6]);
        end
        % put optimized values back in table
        try
            h.FitTab.Table.Data(i,2:3:end) = cellfun(@num2str, num2cell([fitpar PDAMeta.chi2(i)]),'Uniformoutput',false);
        catch
            h.FitTab.Table.Data(i,2:3:end) = cellfun(@num2str, num2cell([fitpar NaN]),'Uniformoutput',false);
        end
    end
else
    %% Global fitting
    %%% Sets initial value and bounds for global parameters
    % PDAMeta.Global    = 1     x 22 logical
    % PDAMeta.Fixed     = files x 22 logical
    % PDAMeta.FitParams = files x 22 double
    % PDAMeta.UB/LB     = 1     x 22 double
    
    % check 'Sample-based Global' if you want to globally link a parameter 
    % within a set of time windows of one file. 
    % Do not F that parameter but G it in the UI.
    PDAMeta.SampleGlobal = false(1,numel(PDAMeta.Global)); 
    if UserValues.PDA.HalfGlobal
        % number of time windows per file
        PDAMeta.BlockSize = str2double(h.SettingsTab.TW_edit.String);        
        if h.SettingsTab.DynamicModel.Value          
            % hardcode here which parameters are global only within a set of time windows of one file
            % standard is to link the rates of the dynamic states for each block
            switch h.SettingsTab.DynamicSystem.Value
                case 1 % two state system
                    %PDAMeta.SampleGlobal(1) = true; %half globally link k12
                    %PDAMeta.SampleGlobal(4) = true; %half globally link k21
                    %PDAMeta.SampleGlobal(7) = true; %half globally link Area3
                    %PDAMeta.SampleGlobal(10) = true; %half globally link Area4
                    PDAMeta.SampleGlobal(2) = true; %half globally link R1
                    PDAMeta.SampleGlobal(5) = true; %half globally link R2
                    %PDAMeta.SampleGlobal(3) = true; %half globally link sigma1
                    %PDAMeta.SampleGlobal(6) = true; %half globally link sigma2
                    PDAMeta.SampleGlobal(13) = true; %half globally link Area5
                    PDAMeta.SampleGlobal(14) = true; %half globally link R5
                    PDAMeta.SampleGlobal(19) = true; %half globally link donor-only fraction
                case 2
                    PDAMeta.SampleGlobal(1) = true; %half globally link k12
                    PDAMeta.SampleGlobal(4) = true; %half globally link k21
                    PDAMeta.SampleGlobal(7) = true; %half globally link k31                
                    PDAMeta.SampleGlobal(end-2) = true; %half globally link k32
                    PDAMeta.SampleGlobal(end-1) = true; %half globally link k13
                    PDAMeta.SampleGlobal(end) = true; %half globally link k23
                    %PDAMeta.SampleGlobal(10) = true; %half globally link Area4
                    %PDAMeta.SampleGlobal(5) = true; %half globally link R2
                    %PDAMeta.SampleGlobal(3) = true; %half globally link sigma1
                    %PDAMeta.SampleGlobal(6) = true; %half globally link sigma2
            end
        else %static model
            PDAMeta.SampleGlobal(1) = true; %half globally link Area1
            PDAMeta.SampleGlobal(4) = true; %half globally link Area2
            PDAMeta.SampleGlobal(7) = true; %half globally link Area3
            PDAMeta.SampleGlobal(10) = true; %half globally link Area4
            %PDAMeta.SampleGlobal(2) = true; %half globally link R1
            %PDAMeta.SampleGlobal(5) = true; %half globally link R2
            %PDAMeta.SampleGlobal(3) = true; %half globally link sigma1
            %PDAMeta.SampleGlobal(6) = true; %half globally link sigma2
            %PDAMeta.SampleGlobal(13) = true; %half globally link Area5
            %PDAMeta.SampleGlobal(14) = true; %half globally link R5
            %PDAMeta.SampleGlobal(19) = true; %half globally link donor-only fraction
        end
        PDAMeta.Blocks = numel(PDAData.Data)/PDAMeta.BlockSize; %number of data blocks
        if ~isequal(round(PDAMeta.Blocks), PDAMeta.Blocks)
            msgbox(['The "Sample-based global" checkbox is checked; each loaded dataset needs to consist of exactly ' h.SettingsTab.TW_edit.String ' time windows!'])
            return
        end
        PDAMeta.Global = PDAMeta.Global | PDAMeta.SampleGlobal;
    end
    
    PDAMeta.chi2 = zeros(numel(PDAMeta.Active),1);
    
    fitpar = PDAMeta.FitParams(1,PDAMeta.Global);
    LB = PDAMeta.LB(PDAMeta.Global);
    UB = PDAMeta.UB(PDAMeta.Global);     
    
    PDAMeta.hProxGlobal = [];
    for i=find(PDAMeta.Active)'
        %%% Concatenates y data of all active datasets
        PDAMeta.hProxGlobal = [PDAMeta.hProxGlobal PDAMeta.hProx{i}];
        %%% Concatenates initial values and bounds for non fixed parameters
        fitpar = [fitpar PDAMeta.FitParams(i, ~PDAMeta.Fixed(i,:)& ~PDAMeta.Global)];
        LB=[LB PDAMeta.LB(~PDAMeta.Fixed(i,:) & ~PDAMeta.Global)];
        UB=[UB PDAMeta.UB(~PDAMeta.Fixed(i,:) & ~PDAMeta.Global)];
    end
    
    if UserValues.PDA.HalfGlobal
        % put the sample-globally linked parameters at the end
        for i = 2:PDAMeta.Blocks
            fitpar = [fitpar PDAMeta.FitParams((i-1)*PDAMeta.BlockSize+1, PDAMeta.SampleGlobal)];
            LB = [LB PDAMeta.LB(PDAMeta.SampleGlobal)];
            UB = [UB PDAMeta.UB(PDAMeta.SampleGlobal)];
        end
    end
    
    switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
        case 'Histogram Library'
            fitfun = @(x) PDAHistogramFit_Global(x,h);
        case 'MLE'
            fitfun = @(x) PDAMLEFit_Global(x,h);
        case 'MonteCarlo'
            fitfun = @(x) PDAMonteCarloFit_Global(x,h);
    end
    %% Check if View_Curve was pressed
    switch obj
        case h.Menu.ViewFit
             %%% Only Update Plot and break
            Progress(0,h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Simulating Histograms...');
            Progress(0,h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Simulating Histograms...');
            switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
                case {'MonteCarlo'}
                    %%% For Updating the Result Plot, use MC sampling
                    PDAMonteCarloFit_Global(fitpar,h);
                case {'Histogram Library','MLE'}
                    PDAHistogramFit_Global(fitpar,h);
            end
        case h.Menu.StartFit
            %% Do Fit
            switch h.SettingsTab.FitMethod_Popupmenu.String{h.SettingsTab.FitMethod_Popupmenu.Value}
                case 'Simplex'
                    fitopts = optimset('MaxFunEvals', 1E5,'Display','iter','TolFun',1E-6,'TolX',1E-3,'PlotFcns',@optimplotfval);
                    fitpar = fminsearchbnd(fitfun, fitpar, LB, UB, fitopts);
                case 'Gradient-based (lsqnonlin)'
                    PDAMeta.FitInProgress = 2; % indicate that we want a vector of residuals, instead of chi2, and that we only pass non-fixed parameters
                    fitopts = optimoptions('lsqnonlin','MaxFunEvals', 1E4,'Display','iter');
                    fitpar = lsqnonlin(fitfun,fitpar,LB,UB,fitopts);
                case 'Gradient-based (fmincon)'
                    fitopts = optimoptions('fmincon','MaxFunEvals',1E4,'Display','iter');%,'PlotFcns',@optimplotfvalPDA);
                    fitpar = fmincon(fitfun, fitpar,[],[],[],[],LB,UB,[],fitopts);
                case 'Patternsearch'
                    opts = psoptimset('Cache','on','Display','iter','PlotFcns',@psplotbestf);%,'UseParallel','always');
                    fitpar = patternsearch(fitfun, fitpar, [],[],[],[],LB,UB,[],opts);
                case 'Gradient-based (global)'
                    opts = optimoptions(@fmincon,'Algorithm','interior-point','Display','iter');%,'PlotFcns',@optimplotfvalPDA);
                    problem = createOptimProblem('fmincon','objective',fitfun,'x0',fitpar,'Aeq',[],'beq',[],'lb',LB,'ub',UB,'options',opts);
                    gs = GlobalSearch;
                    fitpar = run(gs,problem);
                case 'Simulated Annealing'
                    opts = optimoptions('simulannealbnd','Display','iter','InitialTemperature',100,'MaxTime',300);
                    fitpar = simulannealbnd(fitfun,fitpar,LB,UB,opts);
                case 'Genetic Algorithm'
                    opts = optimoptions('ga','PlotFcn',@gaplotbestf,'Display','iter');
                    fitpar = ga(fitfun,numel(fitpar),[],[],[],[],LB,UB,[],opts);
                case 'Particle Swarm'
                    opts = optimoptions('particleswarm','HybridFcn','patternsearch','Display','iter');
                    fitpar = particleswarm(fitfun,numel(fitpar),LB,UB,opts);
                case 'Surrogate Optimization'
                    opts = optimoptions('surrogateopt','PlotFcn','surrogateoptplot','InitialPoints',fitpar,'MaxFunctionEvaluations',1E4);
                    fitpar = surrogateopt(fitfun,LB,UB,opts);
            end

            %Calculate chi^2
            switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
                case 'Histogram Library'
                    PDAHistogramFit_Global(fitpar,h);
                case 'MLE'
                    %%% For Updating the Result Plot, use MC sampling
                    PDAMeta.FitInProgress = 1;
                    PDAHistogramFit_Global(fitpar,h);
                    PDAMeta.FitInProgress = 0;
                    if isfield(PDAMeta,'Last_logL')
                        PDAMeta = rmfield(PDAMeta,'Last_logL');
                    end
                case 'MonteCarlo'
%                     PDAMeta.chi2 = PDAMonteCarloFit_Single(fitpar,h);
                otherwise
                    PDAMeta.chi2 = 0;
            end


            %%% Sort optimized fit parameters back into table
            PDAMeta.FitParams(:,PDAMeta.Global)=repmat(fitpar(1:sum(PDAMeta.Global)),[size(PDAMeta.FitParams,1) 1]) ;
            fitpar(1:sum(PDAMeta.Global))=[];
            for i=find(PDAMeta.Active)'
                PDAMeta.FitParams(i, ~PDAMeta.Fixed(i,:) & ~PDAMeta.Global) = fitpar(1:sum(~PDAMeta.Fixed(i,:) & ~PDAMeta.Global));
                fitpar(1:sum(~PDAMeta.Fixed(i,:)& ~PDAMeta.Global))=[];
            end
            if UserValues.PDA.HalfGlobal
                for i = 2:PDAMeta.Blocks
                    PDAMeta.FitParams((i-1)*PDAMeta.BlockSize+1:i*PDAMeta.BlockSize,PDAMeta.SampleGlobal)=repmat(fitpar(1:sum(PDAMeta.SampleGlobal)),[PDAMeta.BlockSize 1]) ;
                    fitpar(1:sum(PDAMeta.SampleGlobal))=[];
                end
            end
            %%% if three-state dynamic model was used, update table and
            %%% remove from fitpar array
            if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
                for i=find(PDAMeta.Active)'
                    % [k12,k13,k21,k23,k31,k32]
                    rates = [PDAMeta.FitParams(i,1),PDAMeta.FitParams(i,end-1),PDAMeta.FitParams(i,4),...
                        PDAMeta.FitParams(i,end),PDAMeta.FitParams(i,7),PDAMeta.FitParams(i,end-2)];
                    h.KineticRates_table.Data(i,1:3:end) = num2cell(rates);                    
                    %%% assign equilibrium fraction to the fitpar table
                    %%% DynRates = [k11 k21 k31,
                    %%%             k12 k22 k32,
                    %%%             k13 k23 k33]
                    DynRates = [0,rates(3),rates(5);rates(1),0,rates(6);rates(2),rates(4),0];
                    for j = 1:3
                        DynRates(j,j) = -sum(DynRates(:,j));
                    end
                    DynRates(end+1,:) = ones(1,3);
                    b = zeros(3,1); b(end+1) = 1;
                    p_eq = DynRates\b;
                    fitpar(1) = p_eq(1);
                    fitpar(4) = p_eq(2);
                    fitpar(7) = p_eq(3); 
                    PDAMeta.FitParams(i,1) = p_eq(1);
                    PDAMeta.FitParams(i,4) = p_eq(2);
                    PDAMeta.FitParams(i,7) = p_eq(3);
                end
                PDAMeta.FitParams(:,end-2:end) = [];
                PDAMeta.Global(:,end-2:end) = [];
                PDAMeta.Fixed(:,end-2:end) = [];
            end
            
            %%% If sigma was fixed at fraction of R, update edit box here and
            %%% remove from fitpar array
            %%% if sigma is fixed at fraction of, read value here before reshape
            if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
                 fraction = PDAMeta.FitParams(1,end);
                 h.SettingsTab.SigmaAtFractionOfR_edit.String = num2str(fraction);
                 PDAMeta.FitParams(:,end) = [];
                 PDAMeta.Global(:,end) = [];
                 PDAMeta.Fixed(:,end) = [];
            end

            for i = find(PDAMeta.Active)'
                %%% if sigma is fixed at fraction of, change its value here
                if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
                    PDAMeta.FitParams(i,3:3:end) = fraction.*PDAMeta.FitParams(i,2:3:end);
                end
                if h.SettingsTab.FixStaticToDynamicSpecies.Value == 1
                    %%% Overwrite values of static species with values of dynamic species
                    PDAMeta.FitParams(i,[8,9,11,12]) = PDAMeta.FitParams(i,[2,3,5,6]);
                end
                h.FitTab.Table.Data(i,2:3:end) = cellfun(@num2str,num2cell([PDAMeta.FitParams(i,:) PDAMeta.chi2(i)]),'UniformOutput',false);
            end
        case {h.Menu.EstimateErrorHessian,h.Menu.EstimateErrorMCMC}
            alpha = 0.05; %95% confidence interval
            %%% get error bars from jacobian
            PDAMeta.FitInProgress = 2; % set to two to indicate error estimation based on gradient (only compute hessian with respect to non-fixed parameters)
            fitopts = optimoptions('lsqnonlin','MaxIter',1);
            if strcmp(h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value},'MLE')
                %%% switch fit function to Histogram Library temporarily to
                %%% obtain estimate of confidence intervals for MCMC
                %%% sampling
                fitfun = @(x) PDAHistogramFit_Global(x,h);
            end
            if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2 %%% three-state system               
                if obj ==  h.Menu.EstimateErrorHessian
                    % in three-state system, the kinetic scheme is evaluated by
                    % monte carlo simulation.
                    % As a consequence, the objective function is noisy and the
                    % gradient is not defined.
                    disp('Jacobian estimate of errors is not available for three-state kinetic analysis. Please use the MCMC method instead.');
                    return;
                end
                % provide a proposal for MCMC sampling, set to .1% of the
                % fitparameter value
                proposal = fitpar/100; ci = proposal;
            else
                % for static or two state systems, we can estimate the
                % error from the jacobain
                [~,~,residual,~,~,~,jacobian] = lsqnonlin(fitfun,fitpar,LB,UB,fitopts);
                ci = nlparci(fitpar,residual,'jacobian',jacobian,'alpha',alpha);
                ci = (ci(:,2)-ci(:,1))/2; ci = ci';
                proposal = ci/10;
            end
            if strcmp(h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value},'MLE')
                %%% switch fit function back
                fitfun = @(x) PDAMLEFit_Global(x,h);
            end
            if obj ==  h.Menu.EstimateErrorMCMC %%% additionally, refine by doing mcmc sampling
                PDAMeta.FitInProgress = 3; %%% indicate to get loglikelihood instead chi2
                % get parameter names in correct order
                param_names = repmat(h.FitTab.Table.ColumnName(2:3:end-1)',size(PDAMeta.FitParams,1),1);
                % remove html tags
                param_names = cellfun(@(x) regexprep(x, '<.*?>',''),param_names,'UniformOutput',false) ;
                param_names = cellfun(@(x) regexprep(x, '\[.*?\]',''),param_names,'UniformOutput',false);
                %param_names = cellfun(@(x) x(11:end-4),param_names,'UniformOutput',false);
                if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1   
                    param_names = [param_names repmat({'sigmaF'},size(param_names,1),1)];
                end
                if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
                    param_names = [param_names repmat({'k23','k31','k32'},size(param_names,1),1)];
                    param_names(cell2mat(cellfun(@(x) strcmp(x,'F1'),param_names,'UniformOutput',false))) = deal({'k12'});
                    param_names(cell2mat(cellfun(@(x) strcmp(x,'F2'),param_names,'UniformOutput',false))) = deal({'k21'});
                    param_names(cell2mat(cellfun(@(x) strcmp(x,'F3'),param_names,'UniformOutput',false))) = deal({'k31'});
                end
                names = param_names(1,PDAMeta.Global); 
                if UserValues.PDA.HalfGlobal
                    % put the half-globally linked parameter after the global ones
                    for i = 1:(PDAMeta.Blocks-1)
                        names = [names cellfun(@(x) [x sprintf(' (%i)',i)],param_names(i*PDAMeta.BlockSize+1, PDAMeta.SampleGlobal),'UniformOutput',false)];
                    end
                end
                for i=find(PDAMeta.Active)'
                    %%% Concatenates initial values and bounds for non fixed parameters
                    names = [names param_names(i, ~PDAMeta.Fixed(i,:)& ~PDAMeta.Global)];
                end               
                % use MCMC sampling to get errorbar estimates

                %%% Sample
                %%% query sampling parameters
                data = inputdlg({'Number of samples:','Spacing for statistical independence:'},'Specify MCMC sampling parameters',1,{'1000','10'});
                data = cellfun(@str2double,data);
                nsamples = data(1); spacing = data(2);
                fixed = fitpar == 0;
                [samples,prob,acceptance] =  MHsample(nsamples,fitfun,@(x) 1,proposal,LB,UB,fitpar',fixed,~fixed,names,[],1);
                v = numel(PDAMeta.hProx{1})-numel(fitpar); % number of degrees of freedom = number of E bins - number of fit parameters
                perc = tinv(1-alpha/2,v);
                ci_mc = perc*std(samples(1:spacing:end,:),[],1); m_mc = mean(samples(1:spacing:end,:),1);
            end
            %%% Sort confidence intervals back to fitparameters
            err(:,PDAMeta.Global)=repmat(ci(1:sum(PDAMeta.Global)),[size(PDAMeta.FitParams,1) 1]) ;
            ci(1:sum(PDAMeta.Global))=[];
            if UserValues.PDA.HalfGlobal
                for i = 1:(PDAMeta.Blocks-1)
                    err(i*PDAMeta.BlockSize+1:(i+1)*PDAMeta.BlockSize,PDAMeta.SampleGlobal)=repmat(ci(1:sum(PDAMeta.SampleGlobal)),[PDAMeta.BlockSize 1]) ;
                    ci(1:sum(PDAMeta.SampleGlobal))=[];
                end
            end
            count = 1;
            for i=find(PDAMeta.Active)'
                err(count, ~PDAMeta.Fixed(i,:) & ~PDAMeta.Global) = ci(1:sum(~PDAMeta.Fixed(i,:) & ~PDAMeta.Global));
                ci(1:sum(~PDAMeta.Fixed(i,:)& ~PDAMeta.Global))=[];
                PDAMeta.ConfInt_Jac{count} = err(count,~PDAMeta.Fixed(i,:));
                count = count + 1;
            end
            if obj == h.Menu.EstimateErrorMCMC
                %%% Sort MCMC_mean value back to fit parameters
                MCMC_mean(:,PDAMeta.Global)=repmat(m_mc(1:sum(PDAMeta.Global)),[size(PDAMeta.FitParams,1) 1]) ;
                m_mc(1:sum(PDAMeta.Global))=[];
                if UserValues.PDA.HalfGlobal
                    for i = 1:(PDAMeta.Blocks-1)
                        MCMC_mean(i*PDAMeta.BlockSize+1:(i+1)*PDAMeta.BlockSize,PDAMeta.SampleGlobal)=repmat(m_mc(1:sum(PDAMeta.SampleGlobal)),[PDAMeta.BlockSize 1]) ;
                        m_mc(1:sum(PDAMeta.SampleGlobal))=[];
                    end
                end
                count = 1;
                for i=find(PDAMeta.Active)'
                    MCMC_mean(i, ~PDAMeta.Fixed(i,:) & ~PDAMeta.Global) = m_mc(1:sum(~PDAMeta.Fixed(i,:) & ~PDAMeta.Global));
                    m_mc(1:sum(~PDAMeta.Fixed(i,:)& ~PDAMeta.Global))=[];
                    PDAMeta.MCMC_mean{count} = MCMC_mean(count,~PDAMeta.Fixed(i,:));
                    count = count + 1;
                end
                %%% Sort ci_mc back to fit parameters
                err_mc(:,PDAMeta.Global)=repmat(ci_mc(1:sum(PDAMeta.Global)),[size(PDAMeta.FitParams,1) 1]) ;
                ci_mc(1:sum(PDAMeta.Global))=[];
                if UserValues.PDA.HalfGlobal
                    for i = 1:(PDAMeta.Blocks-1)
                        err_mc(i*PDAMeta.BlockSize+1:(i+1)*PDAMeta.BlockSize,PDAMeta.SampleGlobal)=repmat(ci_mc(1:sum(PDAMeta.SampleGlobal)),[PDAMeta.BlockSize 1]) ;
                        ci_mc(1:sum(PDAMeta.SampleGlobal))=[];
                    end
                end
                count = 1;
                for i=find(PDAMeta.Active)'
                    err_mc(count, ~PDAMeta.Fixed(i,:) & ~PDAMeta.Global) = ci_mc(1:sum(~PDAMeta.Fixed(i,:) & ~PDAMeta.Global));
                    ci_mc(1:sum(~PDAMeta.Fixed(i,:)& ~PDAMeta.Global))=[];
                    PDAMeta.ConfInt_MCMC{count} = err_mc(count,~PDAMeta.Fixed(i,:));
                    count = count + 1;
                end
            end
            PDAMeta.FitInProgress = 0; % disable fit
    end
end
% make confidence intervals available in base workspace
if any(obj == [h.Menu.EstimateErrorHessian,h.Menu.EstimateErrorMCMC])
    %%% initialize names cell array
    if ~h.SettingsTab.DynamicModel.Value
        names = {'A1';'R1';'sigma1';'A2';'R2';'sigma2';'A3';'R3';'sigma3';...
            'A4';'R4';'sigma4';'A5';'R5';'sigma5';'A6';'R6';'sigma6';'Fraction D-only'};
    else
        if h.SettingsTab.DynamicSystem.Value == 1
            names = {'k12';'R1';'sigma1';'k21';'R2';'sigma2';'A3';'R3';'sigma3';...
                'A4';'R4';'sigma4';'A5';'R5';'sigma5';'A6';'R6';'sigma6';'Fraction D-only'};
        elseif  h.SettingsTab.DynamicSystem.Value == 2
            names = {'k12';'R1';'sigma1';'k21';'R2';'sigma2';'k31';'R3';'sigma3';...
                'A4';'R4';'sigma4';'A5';'R5';'sigma5';'A6';'R6';'sigma6';'Fraction D-only'};
        end
    end
    if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
        names{end+1} = 'sigma at fraction  of R';
    end
    if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
        names{end+1} = 'k32'; names{end+1} = 'k13'; names{end+1} = 'k23';
    end
    filenames = [];
    ConfInt_Jac = cell(sum(PDAMeta.Active),1);
    ConfInt_MCMC = cell(sum(PDAMeta.Active),1);
    count = 0;
    lim = 0;
    for i = find(PDAMeta.Active)' % loop over files
        count = count + 1;
        fitpar = PDAMeta.FitParams(i,:);
        fixed = PDAMeta.Fixed(i,:);
        if ~do_global
            if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
%                 fitpar(end+1) = fraction;
%                 if h.SettingsTab.FixSigmaAtFractionOfR_Fix.Value == 0
%                     fixed(end+1) = false;
%                 else
%                     fixed(end+1) = true;
%                 end
            end
        end
        lim = max(lim,find(~fixed,1,'last'));
        if ~isempty(PDAMeta.ConfInt_Jac{i})
            confint_jac = zeros(numel(fitpar),1);
            confint_jac(~fixed) = PDAMeta.ConfInt_Jac{i};
            ConfInt_Jac{count} = [fitpar' confint_jac];
        end
        if obj == h.Menu.EstimateErrorMCMC
            conf_int_mcmc = zeros(numel(fitpar),1);
            conf_int_mcmc(~fixed) = PDAMeta.ConfInt_MCMC{i};
            mcmc_mean = zeros(numel(fitpar),1);
            mcmc_mean(~fixed) = PDAMeta.MCMC_mean{i};
            ConfInt_MCMC{count} = [mcmc_mean conf_int_mcmc];
        end
        filenames{end+1} = matlab.lang.makeValidName(PDAData.FileName{i}(1:min(60,numel(PDAData.FileName{i}))));
        filenames{end+1} = ['CI_' num2str(i)];
    end
    % remove unused parameters
    for i = 1:numel(ConfInt_Jac)
        ConfInt_Jac{i} = ConfInt_Jac{i}(1:lim,:);
        if obj == h.Menu.EstimateErrorMCMC
            ConfInt_MCMC{i} = ConfInt_MCMC{i}(1:lim,:);
        end
    end
    filenames = matlab.lang.makeUniqueStrings(filenames);
    %%% assign to workspace
    if obj ==  h.Menu.EstimateErrorHessian
        assignin('base','ConfInt_Jac',ConfInt_Jac);
        tab_jac = cell2table(num2cell(horzcat(ConfInt_Jac{:})),'RowNames',names(1:lim),'VariableNames',filenames);
        assignin('base','tab_jac',tab_jac);
    end
    if obj == h.Menu.EstimateErrorMCMC
        assignin('base','ConfInt_MCMC',ConfInt_MCMC);
        tab_mcmc = cell2table(num2cell(horzcat(ConfInt_MCMC{:})),'RowNames',names(1:lim),'VariableNames',filenames);
        assignin('base','tab_mcmc',tab_mcmc);
        assignin('base','samples_mcmc',samples); % the mcmc samples
    end
end
    
Progress(1, h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Done');
Progress(1, h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Done');
Update_Plots([],[],1)
%%% re-enable Fit Menu
h.FitTab.Table.Enable='on';
h.KineticRates_table.Enable = 'on';
PDAMeta.FitInProgress = 0;

% File menu - stop fitting
function Stop_PDA_Fit(~,~)
global PDAMeta
h = guidata(findobj('Tag','GlobalPDAFit'));
PDAMeta.FitInProgress = 0;
h.FitTab.Table.Enable='on';
h.KineticRates_table.Enable = 'on';

% model for normal histogram library fitting (not global)
function [chi2] = PDAHistogramFit_Single(fitpar,h)
global PDAMeta PDAData
i = PDAMeta.file;

%%% iterate the counter
PDAMeta.Fit_Iter_Counter = PDAMeta.Fit_Iter_Counter + 1;
%%% Aborts Fit
if mod(PDAMeta.Fit_Iter_Counter,PDAMeta.UpdateInterval) == 0
    drawnow;
end
if ~PDAMeta.FitInProgress
    if strcmp('Gradient-based (lsqnonlin)',h.SettingsTab.FitMethod_Popupmenu.String{h.SettingsTab.FitMethod_Popupmenu.Value})
        % chi2 must be an array!
        chi2 = PDAMeta.w_res{i};%zeros(str2double(h.SettingsTab.NumberOfBins_Edit.String),1);
    else
        chi2 = PDAMeta.chi2(i);
    end
    return;
end


if (PDAMeta.FitInProgress == 2) && ((sum(PDAMeta.Global) == 0) || (sum(PDAMeta.Active) == 1)) %%% we are estimating errors based on hessian, so input parameters are only the non-fixed parameters
    % only the non-fixed parameters are passed, reconstruct total fitpar
    % array from dummy data
    fitpar_dummy = PDAMeta.FitParams(i,:);
    fixed_dummy = PDAMeta.Fixed(i,:);
    if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
        %%% add sigma fraction to end
        %fitpar_dummy = [fitpar_dummy, str2double(h.SettingsTab.SigmaAtFractionOfR_edit.String)];
        %fixed_dummy = [fixed_dummy, h.SettingsTab.FixSigmaAtFractionOfR_Fix.Value];
    end
    if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
        % Read the rates from the table
        %rates = cell2mat(h.KineticRates_table.Data(:,1:2:end));
        %rates = [rates(2,3),rates(3,1),rates(3,2)];
        %fixed_rates = cell2mat(h.KineticRates_table.Data(:,2:2:end));
        %fixed_rates = [fixed_rates(2,3),fixed_rates(3,1),fixed_rates(3,2)];
        %fitpar_dummy = [fitpar_dummy, rates];
        %fixed_dummy = [fixed_dummy, fixed_rates];
    end
    % overwrite free fit parameters
    fitpar_dummy(~fixed_dummy) = fitpar; 
    fitpar = fitpar_dummy;    
end

%%% if dynamic model, rates for third state are appended to fitpar array
if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
    rates_state3 = fitpar(end-2:end);
    fitpar(end-2:end) = [];
end
%%% if sigma is fixed at fraction of, change its value here, and remove the
%%% amplitude fit parameter so it does not mess up further uses of fitpar
if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
    fraction = fitpar(end); fitpar(end) = [];
    fitpar(3:3:end) = fraction.*fitpar(2:3:end);
end

%%% if dynamic and static species are linked, overwrite the distances and
%%% sigmas of the static species here
if h.SettingsTab.FixStaticToDynamicSpecies.Value == 1
    fitpar([8,9,11,12]) = fitpar([2,3,5,6]);
end
%%% create individual histograms
hFit_Ind = cell(6,1);
if ~h.SettingsTab.DynamicModel.Value %%% no dynamic model
    %%% do not normalize Amplitudes; user can do this himself if he wants
    % fitpar(3*PDAMeta.Comp{i}-2) = fitpar(3*PDAMeta.Comp{i}-2)./sum(fitpar(3*PDAMeta.Comp{i}-2));
    
    for c = PDAMeta.Comp{i}
        if h.SettingsTab.Use_Brightness_Corr.Value
            %%% If brightness correction is to be performed, determine the relative
            %%% brightness based on current distance and correction factors
            Qr = calc_relative_brightness(fitpar(3*c-1),i);
            %%% Rescale the PN;
            PN_scaled = scalePN(PDAData.BrightnessReference.PN,Qr);
            %%% fit PN_scaled to match PN of file
            PN_scaled = PN_scaled(1:numel(PDAMeta.PN{i}));
            PN_scaled = PN_scaled./sum(PN_scaled).*sum(PDAMeta.PN{i});
            %%% Recalculate the P array of this file
            PDAMeta.P(i,:) = recalculate_P(PN_scaled,i,str2double(h.SettingsTab.NumberOfBins_Edit.String),str2double(h.SettingsTab.NumberOfBinsE_Edit.String));
        end
        
        [Pe] = Generate_P_of_eps(fitpar(3*c-1), fitpar(3*c), i); %Pe is area-normalized
        P_eps = fitpar(3*c-2).*Pe;
        hFit_Ind{c} = zeros(str2double(h.SettingsTab.NumberOfBins_Edit.String),1);
        for k = 1:str2double(h.SettingsTab.NumberOfBinsE_Edit.String)+1
            hFit_Ind{c} = hFit_Ind{c} + P_eps(k).*PDAMeta.P{i,k};
        end
    end
    %%% Combine histograms
    hFit = sum(horzcat(hFit_Ind{:}),2)';
else %%% dynamic model
    %%% calculate PofT
    dT = PDAData.timebin(i)*1E3; % time bin in milliseconds
    switch h.SettingsTab.DynamicSystem.Value
        case 1
            %%% two-state system
            % solve analytically
            dyn_sim = 'analytic';
        case 2
            %%% three-state system
            % use monte carlo to evaluate kinetics
            dyn_sim = 'montecarlo';
    end
    switch dyn_sim
        case 'analytic'
            n_states = 2;
            N = 100;
            k1 = fitpar(3*1-2);
            k2 = fitpar(3*2-2);
            PofT = calc_dynamic_distribution(dT,N,k1,k2);
        case 'montecarlo'
            DynRates = [0, fitpar(3*2-2),fitpar(3*3-2); ...
                        fitpar(3*1-2), 0,rates_state3(1);... 
                        rates_state3(2),rates_state3(3),0];
            % rates in kHz
            % The DynRates matrix has the form:
            % ( 11 21 31 ... )
            % ( 12 22 32 ... )
            % ( 13 23 33 ... )
            % ( .. .. .. ... )
            n_states = size(DynRates,1);
            n_bins_T = PDAMeta.GridRes_PofT; % binning for 2d distribution of occupancys
            if PDAMeta.threestate_analytical % linear three-state scheme
                % use analytic solution
                PofT = linear_three_state(DynRates(2,1),DynRates(1,2),DynRates(3,2),DynRates(2,3),dT,n_bins_T);
                % PofT describes the joint probability to see T3 and T1 (T2=T is in the origin)
                % T2 ------- T1
                %  | . . . /
                %  | .  /
                %  | /
                % T3
            else
                % compute using gillespie algorithm
                change_prob = cumsum(DynRates);
                change_prob = change_prob ./ repmat(change_prob(end,:),3,1);
                dwell_mean = 1 ./ sum(DynRates);  
                for j = 1:n_states
                    DynRates(j,j) = -sum(DynRates(:,j));
                end
                DynRates(end+1,:) = ones(1,n_states);
                b = zeros(n_states,1); b(end+1) = 1;
                p_eq = DynRates\b;
                FracT = Gillespie_inf_states_PDA(dT,n_states,dwell_mean,1E5,p_eq,change_prob)./dT;
                % PofT describes the joint probability to see T3 and T1 (T2=T is in the origin)         
                PofT = histcounts2(FracT(:,3),FracT(:,1),linspace(0,1,n_bins_T+1),linspace(0,1,n_bins_T+1));
                PofT = PofT./sum(PofT(:));
            end
    end
    %%% generate P(eps) distribution for both components
    PE = cell(n_states,1);
    for c = 1:n_states
        PE{c} = Generate_P_of_eps(fitpar(3*c-1), fitpar(3*c), i);
    end
    %%% read out brightnesses of species
    Q = ones(n_states,1);
    for c = 1:n_states
        Q(c) = calc_relative_brightness(fitpar(3*c-1),i);
    end
    %%% calculate mixtures with brightness correction (always active!)
    if n_states == 2
        if ~verLessThan('matlab','8.4') && ispc
            % the old mex function, compiled in 2014b, does not work on
            % Windows for Matlab versions 2018a or newers
            Peps = mixPE_c_2018a(PDAMeta.eps_grid{i},PE{1},PE{2},numel(PofT),numel(PDAMeta.eps_grid{i}),Q(1),Q(2));
        else
            Peps = mixPE_c(PDAMeta.eps_grid{i},PE{1},PE{2},numel(PofT),numel(PDAMeta.eps_grid{i}),Q(1),Q(2));
        end
        Peps = reshape(Peps,numel(PDAMeta.eps_grid{i}),numel(PofT));
        %%% for some reason Peps becomes "ripply" at the extremes... Correct by replacing with ideal distributions
        Peps(:,end) = PE{1};
        Peps(:,1) = PE{2};
        
        %%% normalize
        Peps = Peps./repmat(sum(Peps,1),size(Peps,1),1);
        Peps(isnan(Peps)) = 0;
        %%% combine mixtures, weighted with PofT (probability to see a certain
        %%% combination)
        hFit_Ind_dyn = cell(numel(PofT),1);
        for t = 1:numel(PofT)
            hFit_Ind_dyn{t} = zeros(str2double(h.SettingsTab.NumberOfBins_Edit.String),1);
            for k =1:str2double(h.SettingsTab.NumberOfBinsE_Edit.String)+1
                %%% construct sum of histograms
                hFit_Ind_dyn{t} = hFit_Ind_dyn{t} + Peps(k,t).*PDAMeta.P{i,k};
            end
            %%% weight by probability of occurrence
            hFit_Ind_dyn{t} = PofT(t)*hFit_Ind_dyn{t};
        end
        hFit_Ind{1} = hFit_Ind_dyn{1};
        hFit_Ind{2} = hFit_Ind_dyn{end};
        hFit_Dyn = sum(horzcat(hFit_Ind_dyn{:}),2);
    elseif n_states > 2
        Peps = mixPE_3states_c(PDAMeta.eps_grid{i},PE{1},PE{2},PE{3},size(PofT,1),numel(PDAMeta.eps_grid{i}),Q(1),Q(2),Q(3));
        %%% as defined in the C code:
        %%% dimensions of Peps are eps,T2,T1
        Peps = reshape(Peps,numel(PDAMeta.eps_grid{i}),size(PofT,1),size(PofT,1));
        % that means: Peps(E,t2,t1) is the probability to see E when the
        % molecule was T1 = t1 in state 1, T2 = t2 in state 2 and T3 =
        % T-T1-T1 in state 3.
        
        %%% normalize Peps
        Peps = Peps./repmat(sum(Peps,1),size(Peps,1),1);
        Peps(isnan(Peps)) = 0;
        %%% combine mixtures, weighted with PofT (probability to see a certain
        %%% combination)
        %hFit_Ind_dyn = cell(size(PofT,1),size(PofT,1));
        hFit_Dyn = zeros(numel(PDAMeta.P{i,1}),1);
        nT = size(PofT,1);
        for t1 = 1:nT
            for t2 = 1:nT
                if (t1+t2) <= (nT+1) % maximum allowed value (in terms of indices): one is 1 (T=0), other is 100 (T=1)
                    t3 = nT-(t1-1)-(t2-1);
                    for k =1:numel(PDAMeta.eps_grid{i})
                        %%% construct sum of histograms
                        hFit_Dyn = hFit_Dyn + PofT(t3,t1)*Peps(k,t2,t1).*PDAMeta.P{i,k};
                        % note the indexing of Peps as described above
                        % Indexing of PofT is PofT(T3,T1) = PofT(T-T1-T2,T1)
                    end
                end
            end
        end
        % pure state histograms
        hFit_Ind{1} = zeros(numel(PDAMeta.P{i,1}),1);
        hFit_Ind{2} = zeros(numel(PDAMeta.P{i,1}),1);
        hFit_Ind{3} = zeros(numel(PDAMeta.P{i,1}),1);
        % only state 1
        t1 = size(PofT,1);
        t2 = 1;
        t3 = 1;
        for k = 1:numel(PDAMeta.eps_grid{i})
           hFit_Ind{1} = hFit_Ind{1} + Peps(k,t2,t1).*PDAMeta.P{i,k};       
        end
        hFit_Ind{1} = hFit_Ind{1} * PofT(t3,t1);   
        % only state 2
        t1 = 1;
        t2 = size(PofT,2);
        t3 = 1;
        for k = 1:numel(PDAMeta.eps_grid{i})
            hFit_Ind{2} = hFit_Ind{2} + Peps(k,t2,t1).*PDAMeta.P{i,k};        
        end
        hFit_Ind{2} = hFit_Ind{2} * PofT(t3,t1);
        % only state 3
        t1 = 1;
        t2 = 1;
        t3 = size(PofT,1);
        for k = 1:numel(PDAMeta.eps_grid{i})
            hFit_Ind{3} = hFit_Ind{3} + Peps(k,t2,t1).*PDAMeta.P{i,k};     
        end
        hFit_Ind{3} = hFit_Ind{3} * PofT(t3,t1);     
        hFit_Ind_dyn = cell(size(PofT,1),1);
        
        % also get the pure two-state dynamic exchange histograms
        % needs to be updated (10-2019)
        two_state_dynamics = false;
        if two_state_dynamics
            % only exchange between states 1-2
            h12 = zeros(numel(PDAMeta.P{i,1}),1);
            for t1 = 2:(size(PofT,1)-1)
                t2 = size(PofT,2)-t1+1;
                for k = 1:numel(PDAMeta.eps_grid{i})
                    h12 = h12 + PofT(t1,t2) * Peps(k,t2,t1).*PDAMeta.P{i,k};        
                end
            end
            % only exchange between states 1-3
            h13 = zeros(numel(PDAMeta.P{i,1}),1);
            for t1 = 2:(size(PofT,1)-1)
                t2 = 1;
                for k = 1:numel(PDAMeta.eps_grid{i})
                    h13 = h13 + PofT(t1,t2) * Peps(k,t2,t1).*PDAMeta.P{i,k};        
                end
            end
            % only exchange between states 2-3
            h23 = zeros(numel(PDAMeta.P{i,1}),1);
            for t2 = 2:(size(PofT,1)-1)
                t1 = 1;
                for k = 1:numel(PDAMeta.eps_grid{i})
                    h23 = h23 + PofT(t1,t2) * Peps(k,t2,t1).*PDAMeta.P{i,k};        
                end
            end
            % only exchange between 1-2-3
            h123 = zeros(numel(PDAMeta.P{i,1}),1);
            for t1 = 2:(size(PofT,1)-1)
                for t2 = 2:(size(PofT,2)-t1+1)
                    for k = 1:numel(PDAMeta.eps_grid{i})
                        h123 = h123 + PofT(t1,t2) * Peps(k,t2,t1).*PDAMeta.P{i,k};        
                    end
                end
            end
        end
    end
    
    %%% Add static models
    norm = 1;
    static_states = PDAMeta.Comp{i}(PDAMeta.Comp{i} > n_states);
    if ~isempty(static_states)
        %%% normalize Amplitudes
        % amplitudes of the static components are normalized to the total area 
        % 'norm' = area3 + area4 + area5 + k21/(k12+k21) + k12/(k12+k21) 
        % the k12 and k21 parameters are left untouched here so they will 
        % appear in the table. The area fractions are calculated in Update_Plots
        norm = (sum(fitpar(3*static_states-2))+1);
        fitpar(3*static_states-2) = fitpar(3*static_states-2)./norm;
        for c = static_states
            [Pe] = Generate_P_of_eps(fitpar(3*c-1), fitpar(3*c), i);
            P_eps = fitpar(3*c-2).*Pe;
            hFit_Ind{c} = zeros(str2double(h.SettingsTab.NumberOfBins_Edit.String),1);
            for k = 1:str2double(h.SettingsTab.NumberOfBinsE_Edit.String)+1
                hFit_Ind{c} = hFit_Ind{c} + P_eps(k).*PDAMeta.P{i,k};
            end
        end
        hFit_Dyn = hFit_Dyn./norm;
        for j = 1:numel(hFit_Ind)
            hFit_Ind{j} = hFit_Ind{j}./norm;
        end
    end
    hFit = sum(horzcat(hFit_Dyn,horzcat(hFit_Ind{n_states+1:end})),2)';
    
    if n_states == 2
        % only the dynamic bursts
        PDAMeta.hFit_onlyDyn{i} = sum(horzcat(hFit_Ind_dyn{2:end-1}),2)./norm;
    elseif n_states == 3
        PDAMeta.hFit_onlyDyn{i} = (hFit_Dyn - sum(horzcat(hFit_Ind{1:n_states}),2))./norm;
    end
end


if fitpar(end) > 0
    %%% Add donor only species
    PDAMeta.hFit_Donly{i} = fitpar(end)*PDAMeta.P_donly{i}';
    % the sum of areas will > 1 this way?
    hFit = (1-fitpar(end))*hFit + fitpar(end)*PDAMeta.P_donly{i}';
    for k = 1:numel(hFit_Ind)
        hFit_Ind{k} = hFit_Ind{k}*(1-fitpar(end));
    end
end

%%% correct for slight number deviations between hFit and hMeasured
%hFit = (hFit./sum(hFit)).*sum(PDAMeta.hProx{i});

%%% Calculate Chi2
switch h.SettingsTab.Chi2Method_Popupmenu.Value
    case 2 %%% Assume gaussian error on data, normal chi2
        error = sqrt(PDAMeta.hProx{i});
        error(error == 0) = 1;
        w_res = (PDAMeta.hProx{i}-hFit)./error;
    case 1 %%% Assume poissonian error on data, MLE poissonian
        %%%% see:
        %%% Laurence, T. A. & Chromy, B. A. Efficient maximum likelihood estimator fitting of histograms. Nat Meth 7, 338?339 (2010).
        log_term = -2*PDAMeta.hProx{i}.*log(hFit./PDAMeta.hProx{i});
        log_term(isnan(log_term)) = 0;
        log_term(~isfinite(log_term)) = 0;
        dev_mle = 2*(hFit-PDAMeta.hProx{i})+log_term; dev_mle(dev_mle<0) = 0;
        w_res = sign(hFit-PDAMeta.hProx{i}).*sqrt(dev_mle);
end
usedBins = sum(PDAMeta.hProx{i} ~= 0);
if ~h.SettingsTab.OuterBins_Fix.Value
    chi2 = sum((w_res.^2));
    if ~PDAMeta.FittingGlobal % return reduced chi2
        chi2 = chi2/(usedBins-sum(~PDAMeta.Fixed(i,:))-1);
    end
else
    chi2 = sum(((w_res(2:end-1)).^2));
    if ~PDAMeta.FittingGlobal % return reduced chi2
        chi2 = chi2/(usedBins-sum(~PDAMeta.Fixed(i,:))-1);
    end
    w_res(1) = 0;
    w_res(end) = 0;
end

PDAMeta.w_res{i} = w_res;
PDAMeta.hFit{i} = hFit;
PDAMeta.chi2(i) = chi2;
% this red. chi2 is for the single dataset,
% correct when global fitting
if PDAMeta.FittingGlobal % store reduced chi2
    PDAMeta.chi2(i) = PDAMeta.chi2(i)/(usedBins-sum(~PDAMeta.Fixed(i,:))-1);
end

comp = PDAMeta.Comp{i};
if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
    % for three-state model, some rates may be fixed to zero,
    % but the states should still be plotted
    comp = [1,2,3,comp(comp > 3)];
end
for c = comp
    PDAMeta.hFit_Ind{i,c} = hFit_Ind{c};
end
if sum(PDAMeta.Global) == 0
    set(PDAMeta.Chi2_All, 'Visible','on','String', ['\chi^2_{red.} = ' sprintf('%1.2f',chi2)]);
end
set(PDAMeta.Chi2_Single, 'Visible', 'on','String', ['\chi^2_{red.} = ' sprintf('%1.2f',chi2)]);

if h.SettingsTab.LiveUpdate.Value && ~PDAMeta.FittingGlobal %sum(PDAMeta.Global) == 0
    Update_Plots([],[],5)
end
tex = ['Fitting Histogram ' num2str(i) ' of ' num2str(sum(PDAMeta.Active))];
if PDAMeta.FitInProgress == 2 %%% return the residuals instead of chi2
    chi2 = w_res;
elseif PDAMeta.FitInProgress == 3 %%% return the loglikelihood
    switch h.SettingsTab.Chi2Method_Popupmenu.Value
        case 2 %%% Assume gaussian error on data, normal chi2
            loglikelihood = (-1/2)*sum(w_res.^2); %%% loglikelihood is the negative of chi2 divided by two
        case 1 %%% Assume poissonian error on data, MLE poissonian
            %%% compute loglikelihood without normalization to P(x|x)
            log_term = PDAMeta.hProx{i}.*log(hFit);
            log_term(isnan(log_term)) = 0;
            log_term(~isfinite(log_term)) = 0;
            loglikelihood = sum(log_term-hFit);
    end
    chi2 = loglikelihood;
    PDAMeta.chi2(i) = chi2;
end
%Progress(1/chi2, h.AllTab.Progress.Axes, h.AllTab.Progress.Text, tex);
%Progress(1/chi2, h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text, tex);

% model for normal histogram library fitting (global)
function [global_chi2] = PDAHistogramFit_Global(fitpar,h)
%fitpar is (in this order) the global, halfglobal, nonglobal parameters
global PDAMeta PDAData UserValues

%%% iterate the counter
PDAMeta.Fit_Iter_Counter = PDAMeta.Fit_Iter_Counter + 1;
%%% Aborts Fit
if mod(PDAMeta.Fit_Iter_Counter,PDAMeta.UpdateInterval) == 0
    drawnow;
end
if ~PDAMeta.FitInProgress
    if strcmp('Gradient-based (lsqnonlin)',h.SettingsTab.FitMethod_Popupmenu.String{h.SettingsTab.FitMethod_Popupmenu.Value})
        % chi2 must be an array!
        global_chi2 = zeros(1,sum(PDAMeta.Active)*str2double(h.SettingsTab.NumberOfBins_Edit.String));
    else
        global_chi2 = 0;
    end
    PDAMeta.global_chi2 = 0;
    return;
end


FitParams = PDAMeta.FitParams; %the whole fittable
Global = PDAMeta.Global; %1 if parameter is global or sample-global
Fixed = PDAMeta.Fixed;

P=zeros(numel(Global),1);

%%% Assigns global parameters
P(Global)=fitpar(1:sum(Global));
fitpar(1:sum(Global))=[];

if UserValues.PDA.HalfGlobal
    % extract out half-global parameters (stored at the end)
    fitpar_halfglobal = fitpar(end-sum(PDAMeta.SampleGlobal)*(PDAMeta.Blocks-1)+1:end);
end

Active = find(PDAMeta.Active)';
chi2 = cell(1,sum(PDAMeta.Active));
for j=1:sum(PDAMeta.Active)
    i = Active(j);
    PDAMeta.file = i;
    if UserValues.PDA.HalfGlobal
        if any((PDAMeta.BlockSize+1):PDAMeta.BlockSize:(PDAMeta.BlockSize*PDAMeta.Blocks)==j)
            % if arriving at the next block, replace sample-based global values and delete from fitpar
            P(PDAMeta.SampleGlobal)=fitpar_halfglobal(1:sum(PDAMeta.SampleGlobal));
            fitpar_halfglobal(1:sum(PDAMeta.SampleGlobal))=[];
        end
    end
    %%% Sets non-fixed parameters
    P(~Fixed(i,:) & ~Global)=fitpar(1:sum(~Fixed(i,:) & ~Global));
    fitpar(1:sum(~Fixed(i,:)& ~Global))=[];
    %%% Sets fixed parameters
    P(Fixed(i,:) & ~Global) = FitParams(i, (Fixed(i,:) & ~Global));
    %%% Calculates function for current file
    chi2{j} = PDAHistogramFit_Single(P,h);   
end
chi2 = horzcat(chi2{:});
if PDAMeta.FitInProgress == 2 % chi2 is actually array of w_res
    global_chi2 = sum(chi2.^2);
else
    global_chi2 = sum(chi2);
end
% normalize to return reduced chi2
% number of non-zero bins
usedBins = sum(horzcat(PDAMeta.hProx{Active}) ~= 0);
% number of free fit parameters (degrees of freedom)
% DOF = non-fixed
f = PDAMeta.Fixed(Active,:); g = PDAMeta.Global;
DOF = sum(f(:) == 0); 
if ~UserValues.PDA.HalfGlobal
    % DOF = non_fixed - global*(number_of_datasets-1);
    DOF = DOF - sum(g)*(numel(Active)-1);
else
    % separate global and half-global parameters
    g = g & ~PDAMeta.SampleGlobal;
    DOF = DOF - sum(g)*(numel(Active)-1);
    % half-global parameters account for 
    % (number_of_datasets/block_size)*(block_size-1)
    % lost degrees of freedom
    DOF = DOF - sum(PDAMeta.SampleGlobal & ~sum(f,1)).*(numel(Active)./PDAMeta.BlockSize)*(PDAMeta.BlockSize-1);
end
global_chi2 = global_chi2./(usedBins-DOF-1);
PDAMeta.global_chi2 = global_chi2;

set(PDAMeta.Chi2_All, 'Visible','on','String', ['global \chi^2_{red.} = ' sprintf('%1.2f',global_chi2)]);
if PDAMeta.FitInProgress == 2 %%% return concatenated array of w_res instead of chi2
    global_chi2 = [];
    for i = Active
        global_chi2 = [global_chi2, PDAMeta.w_res{i}];
    end 
    %mean_chi2 = horzcat(PDAMeta.w_res{:});
elseif PDAMeta.FitInProgress == 3 %%% return the correct loglikelihood instead
    global_chi2 = sum(PDAMeta.chi2);
end

if h.SettingsTab.LiveUpdate.Value
    for i = find(PDAMeta.Active)'
        PDAMeta.file = i;
        Update_Plots([],[],5);
    end
end 

% function that generates Equation 10 from Antonik 2006 J Phys Chem B
function [Pe] = Generate_P_of_eps(RDA, sigma, i)
global PDAMeta
eps = PDAMeta.eps_grid{i};
if PDAMeta.directexc(i) == 0
    % generate gaussian distributions of PDA.epsilon weights
    % Eq 10 in Antonik 2006 c Phys Chem B
    Pe = PDAMeta.R0(i)/(6*sqrt(2*pi)*sigma)*...
        (PDAMeta.gamma(i))^(1/6)*...
        1./(1-eps).^2 .* ...
        (1./(1-eps) - (1+PDAMeta.crosstalk(i))).^(-7/6) .* ...
        exp(...
        -1/(2*sigma^2)*...
        (PDAMeta.R0(i).*...
        (PDAMeta.gamma(i))^(1/6).*...
        (1./(1-eps)-(1+PDAMeta.crosstalk(i))).^(-1/6)- ...
        RDA).^2);
elseif PDAMeta.directexc(i) ~= 0
    old = 0;
    if old
        dRdeps = -((PDAMeta.R0(i)^6*PDAMeta.gamma(i))./(PDAMeta.crosstalk(i)...
            - eps - PDAMeta.crosstalk(i)*PDAMeta.directexc(i) - PDAMeta.crosstalk(i)*eps...
            + PDAMeta.directexc(i)*eps + PDAMeta.directexc(i)*PDAMeta.gamma(i)...
            + PDAMeta.crosstalk(i)*PDAMeta.directexc(i)*eps - PDAMeta.directexc(i)*eps*PDAMeta.gamma(i))...
            - ((PDAMeta.R0(i)^6*PDAMeta.gamma(i) - PDAMeta.R0(i)^6*eps*PDAMeta.gamma(i))*(PDAMeta.crosstalk(i)...
            - PDAMeta.directexc(i) - PDAMeta.crosstalk(i)*PDAMeta.directexc(i) + PDAMeta.directexc(i)*PDAMeta.gamma(i) + 1))./...
            (PDAMeta.crosstalk(i) - eps - PDAMeta.crosstalk(i)*PDAMeta.directexc(i)...
            - PDAMeta.crosstalk(i)*eps + PDAMeta.directexc(i)*eps + PDAMeta.directexc(i)*PDAMeta.gamma(i)...
            + PDAMeta.crosstalk(i)*PDAMeta.directexc(i)*eps - PDAMeta.directexc(i)*eps*PDAMeta.gamma(i)).^2)./...
            (6*(-(PDAMeta.R0(i)^6*PDAMeta.gamma(i) - PDAMeta.R0(i)^6*eps*PDAMeta.gamma(i))./(PDAMeta.crosstalk(i)...
            - eps - PDAMeta.crosstalk(i)*PDAMeta.directexc(i) - PDAMeta.crosstalk(i)*eps + PDAMeta.directexc(i)*eps...
            + PDAMeta.directexc(i)*PDAMeta.gamma(i) + PDAMeta.crosstalk(i)*PDAMeta.directexc(i)*eps -...
            PDAMeta.directexc(i)*eps*PDAMeta.gamma(i))).^(5/6));
        P_Rofeps = (1/(sqrt(2*pi)*sigma)).*...
            exp(-(RDA - (-(PDAMeta.R0(i)^6*PDAMeta.gamma(i) - PDAMeta.R0(i)^6*eps*PDAMeta.gamma(i))./...
            (PDAMeta.crosstalk(i) - eps - PDAMeta.crosstalk(i)*PDAMeta.directexc(i) - PDAMeta.crosstalk(i)*eps...
            + PDAMeta.directexc(i)*eps + PDAMeta.directexc(i)*PDAMeta.gamma(i) +...
            PDAMeta.crosstalk(i)*PDAMeta.directexc(i)*eps - PDAMeta.directexc(i)*eps*PDAMeta.gamma(i))).^(1/6)).^2./(2*sigma^2));
        Pe = dRdeps.*P_Rofeps;
    else
        %%% redone formula derivation by hand, easier to read
        R0 = PDAMeta.R0(i);
        d = PDAMeta.directexc(i)/(1-PDAMeta.directexc(i));
        ct = PDAMeta.crosstalk(i);
        gamma = PDAMeta.gamma(i);
        epsilon = eps;
        Rofeps = R0*( (gamma*(1+d)) ./ ( (1./(1-epsilon)) -1 -ct -gamma*d) ).^(1/6);
        dRdeps = (R0/6)*...
            ( (gamma*(1+d)) ./ ( (1./(1-epsilon)) -1 -ct -gamma*d) ).^(-5/6).*...
            gamma.*(1+d).*...
            ( (1./(1-epsilon)) -1 -ct -gamma*d).^(-2).*...
            (1-epsilon).^(-2);
        dRdeps(1) = 0;
        PRofeps = (1/(sqrt(2*pi)*sigma))*...
            exp((-1/(2*sigma^2)).*...
            (Rofeps-RDA).^2);
        Pe = dRdeps.*PRofeps;
    end
end
Pe(~isfinite(Pe)) = 0;
Pe = Pe./sum(Pe); %area-normalized Pe

% model for MLE fitting (not global)
function logL = PDA_MLE_Fit_Single(fitpar,h)
global PDAMeta PDAData
tic;
%%% iterate the counter
PDAMeta.Fit_Iter_Counter = PDAMeta.Fit_Iter_Counter + 1;
%%% Aborts Fit
if mod(PDAMeta.Fit_Iter_Counter,PDAMeta.UpdateInterval) == 0
    drawnow;
end
if ~PDAMeta.FitInProgress
    logL = 0;
    return;
end

file = PDAMeta.file;
if PDAMeta.FitInProgress == 2 %%% we are estimating errors based on hessian, so input parameters are only the non-fixed parameters
    % only the non-fixed parameters are passed, reconstruct total fitpar
    % array from dummy data
    fitpar_dummy = PDAMeta.FitParams(file,:);
    fitpar_dummy(~PDAMeta.Fixed(file,:)) = fitpar;
    fitpar = fitpar_dummy;
end
%%% if dynamic model, rates for third state are appended to fitpar array
if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
    rates_state3 = fitpar(end-2:end);
    fitpar(end-2:end) = [];
end
%%% if sigma is fixed at fraction of, read value here before reshape
if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
    fraction = fitpar(end);fitpar(end) = [];
end
%%% remove donor only fraction, not implemented here
fitpar= fitpar(1:end-1);
fitpar = reshape(fitpar',[3,numel(fitpar)/3]); fitpar = fitpar';
%%% if sigma is fixed at fraction of, change its value here
if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
    fitpar(:,3) = fraction.*fitpar(:,2);
end
%%% if dynamic and static species are linked, overwrite the distances and
%%% sigmas of the static species here
if h.SettingsTab.FixStaticToDynamicSpecies.Value == 1
    fitpar(3:4,2:3) = fitpar(1:2,2:3);
end

% Parameters
cr = PDAMeta.crosstalk(file);
R0 = PDAMeta.R0(file);
de = PDAMeta.directexc(file);
gamma = PDAMeta.gamma(file);

if h.SettingsTab.Use_Brightness_Corr.Value
        %%% If brightness correction is to be performed, determine the relative
        %%% brightness based on current distance and correction factors
        PN_scaled = cell(6,1);
        for c = PDAMeta.Comp{file}
            Qr = calc_relative_brightness(fitpar(c,2),file);
            %%% Rescale the PN;
            PN_scaled{c} = scalePN(PDAData.BrightnessReference.PN,Qr);
            PN_scaled{c} = smooth(PN_scaled{c},10);
            PN_scaled{c} = PN_scaled{c}./sum(PN_scaled{c});
        end
        %%% calculate the relative probabilty
        P_norm = sum(horzcat(PN_scaled{:}),2);
        for c = PDAMeta.Comp{file}
            PN_scaled{c}(P_norm~=0) = PN_scaled{c}(P_norm~=0)./P_norm(P_norm~=0);
            %%% We don't want zero probabilities here!
            PN_scaled{c}(PN_scaled{c} == 0) = eps;
        end
end
    
NG = PDAData.Data{file}.NG(PDAMeta.valid{file});
NF = PDAData.Data{file}.NF(PDAMeta.valid{file});

steps = 10;
n_sigma = 3; %%% how many sigma to sample distribution width?

anisotropy_correction = true; % correct anisotropy?
r0 = 0.38;
rho = 3.2;
tauD0 = 4;
if ~h.SettingsTab.DynamicModel.Value %%% no dynamic model
    L = cell(6,1); %%% Likelihood per Gauss
    for j = PDAMeta.Comp{file}
        %%% define Gaussian distribution of distances
        xR = (fitpar(j,2)-n_sigma*fitpar(j,3)):(2*n_sigma*fitpar(j,3)/steps):(fitpar(j,2)+n_sigma*fitpar(j,3));
        PR = normpdf(xR,fitpar(j,2),fitpar(j,3));
        PR = PR'./sum(PR);
        %%% Calculate E values for R grid
        E = 1./(1+(xR./R0).^6);
        epsGR = 1-(1+cr+(((de/(1-de)) + E) * gamma)./(1-E)).^(-1);

        %%% Calculate the vector of likelihood values
        intensity = true;
        if intensity
            P = eval_prob_2c_bg(NG,NF,...
                PDAMeta.NBG{file},PDAMeta.NBR{file},...
                PDAMeta.PBG{file}',PDAMeta.PBR{file}',...
                epsGR');
            P = log(P);
        else
            P = zeros(size(NG));
        end
        %%% lifetime-based likelihood
        %PDAMeta.lifetime_PDA = true;
        if PDAMeta.lifetime_PDA
            % get the lifetimes of the species in TAC units
            TACbin = PDAData.Data{file}.TACbin;  %in ns, i.e. 8 ps
            tau0 = tauD0/TACbin;
            tau = tau0*(1+(R0./fitpar(j,2)).^6).^(-1);            
            if anisotropy_correction
                % correct for anisotropy
                tau = lifetime_correction_anisotropy(tau,r0,rho/TACbin); % r0 and rho in TACbins
            end
            % correct for trunctation of exponential distribution
            [dt1,dt2] = lifetime_correction_truncation(tau,file);           
            % calculate mean and variance
            mean_t = dt1;        
            var_t = repmat((dt2-mean_t.^2),numel(NG),1)./NG; % variance scales with number of photons
            % calculate parameters of gamma dist
            alpha = repmat(mean_t.^2,numel(NG),1)./var_t;
            beta_inv = (repmat(mean_t,numel(NG),1)./var_t).^(-1);
            tauG = PDAMeta.TauG{file}(PDAMeta.valid{file}); % donor average delay time
            P = P + log_gampdf(tauG,alpha,beta_inv);%log(gampdf(tauG,alpha,beta_inv));        
        end
        
        P = P + repmat(log(PR'),numel(NG),1);
        Lmax = max(P,[],2);
        P = Lmax + log(sum(exp(P-repmat(Lmax,1,numel(PR))),2));
    
        if h.SettingsTab.Use_Brightness_Corr.Value
            %%% Add Brightness Correction Probabilty here
            P = P + log(PN_scaled{j}(NG + NF));
        end
        %%% Treat case when all burst produced zero probability
        P(isnan(P)) = -Inf;
        L{j} = P;
    end
    
    %%% normalize amplitudes
    fitpar(PDAMeta.Comp{file},1) = fitpar(PDAMeta.Comp{file},1)./sum(fitpar(PDAMeta.Comp{file},1));
    PA = fitpar(PDAMeta.Comp{file},1);


    L = horzcat(L{:});
    L = L + repmat(log(PA'),numel(NG),1);
    Lmax = max(L,[],2);
    L = Lmax + log(sum(exp(L-repmat(Lmax,1,numel(PA))),2));
    %%% P_res has NaN values if Lmax was -Inf (i.e. total of zero probability)!
    %%% Reset these values to -Inf
    L(isnan(L)) = 0; %-Inf;
    L(NG == 0) = 0; % zero donor photons produce -Inf, reset to zero;
    logL = sum(L);
    %%% since the algorithm minimizes, it is important to minimize the negative
    %%% log likelihood, i.e. maximize the likelihood
    logL = -logL;
else
    %%% dynamic model
    %%% calculate PofT
    dT = PDAData.timebin(file)*1E3; % time bin in milliseconds
    switch h.SettingsTab.DynamicSystem.Value
        case 1
            %%% two-state system
            % solve analytically
            dyn_sim = 'analytic';
        case 2
            %%% three-state system
            % use monte carlo to evaluate kinetics
            dyn_sim = 'montecarlo';
    end
    switch dyn_sim
        case 'analytic'
            n_states = 2;
            N = 100;
            k1 = fitpar(1,1);
            k2 = fitpar(2,1);
            PofT = calc_dynamic_distribution(dT,N,k1,k2);
        case 'montecarlo'
            DynRates = [0, fitpar(2,1),fitpar(3,1); ...
                        fitpar(1,1), 0,rates_state3(1);... 
                        rates_state3(2),rates_state3(3),0];
            % rates in Hz
            % The DynRates matrix has the form:
            % ( 11 21 31 ... )
            % ( 12 22 32 ... )
            % ( 13 23 33 ... )
            % ( .. .. .. ... )
            n_states = size(DynRates,1);
            n_bins_T = PDAMeta.GridRes_PofT;
            if PDAMeta.threestate_analytical % linear three-state scheme
                % use analytic solution
                PofT = linear_three_state(DynRates(2,1),DynRates(1,2),DynRates(3,2),DynRates(2,3),dT,n_bins_T);
                % PofT describes the joint probability to see T3 and T1 (T2=T is in the origin)
                % T2 ------- T1
                %  | . . . /
                %  | .  /
                %  | /
                % T3
            else
                change_prob = cumsum(DynRates);
                change_prob = change_prob ./ change_prob(end,:);
                dwell_mean = 1 ./ sum(DynRates);  
                for j = 1:n_states
                DynRates(j,j) = -sum(DynRates(:,j));
                end
                DynRates(end+1,:) = ones(1,n_states);
                b = zeros(n_states,1); b(end+1) = 1;
                p_eq = DynRates\b;
                FracT = Gillespie_inf_states(dT,n_states,dwell_mean,1E5,p_eq,change_prob)./dT;
                % PofT describes the joint probability to see T3 and T1 (T2=T is in the origin)               
                PofT = histcounts2(FracT(:,3),FracT(:,1),linspace(0,1,n_bins_T+1),linspace(0,1,n_bins_T+1));
                PofT = PofT./sum(PofT(:));
            end
    end
    %%% generate P(eps) distribution for both components
    PE = cell(n_states,1);
    for c = 1:n_states
        PE{c} = Generate_P_of_eps(fitpar(c,2), fitpar(c,3), file);
    end
    %%% read out brightnesses of species
    Q = ones(n_states,1);
    for c = 1:n_states
        Q(c) = calc_relative_brightness(fitpar(c,2),file);
    end
    if n_states == 2
        %%% calculate mixtures with brightness correction (always active!)
        if ~verLessThan('matlab','8.4') && ispc
            % the old mex function, compiled in 2014b, does not work on
            % Windows for Matlab versions 2018a or newers
            Peps = mixPE_c_2018a(PDAMeta.eps_grid{file},PE{1},PE{2},numel(PofT),numel(PDAMeta.eps_grid{file}),Q(1),Q(2));
        else
            Peps = mixPE_c(PDAMeta.eps_grid{file},PE{1},PE{2},numel(PofT),numel(PDAMeta.eps_grid{file}),Q(1),Q(2));
        end
        Peps = reshape(Peps,numel(PDAMeta.eps_grid{file}),numel(PofT));
        %%% for some reason Peps becomes "ripply" at the extremes... Correct by replacing with ideal distributions
        Peps(:,end) = PE{1};
        Peps(:,1) = PE{2};

        %%% normalize
        Peps = Peps./repmat(sum(Peps,1),size(Peps,1),1);
        Peps(isnan(Peps)) = 0;

        %%% intensity-based likelihood
        L = zeros(numel(NG),numel(PofT)); % log likelihood
        intensity = true;
        if intensity
            log_P_grid = PDAMeta.P_grid{file};
            log_Peps = log(Peps)';
            for i = 1:numel(PofT)
                P =  log_P_grid + repmat(log_Peps(i,:),numel(NG),1);
                Lmax = max(P,[],2);
                P = Lmax + log(sum(exp(P-repmat(Lmax,1,size(P,2))),2));
                L(:,i) = P;
            end
        end
        %%% lifetime-based likelihood
        if PDAMeta.lifetime_PDA
            % get the lifetimes of the species in TAC units
            TACbin = PDAData.Data{file}.TACbin;  %in ns, i.e. 8 ps
            tau0 = tauD0./TACbin;
            tau1 = tau0*(1+(R0./fitpar(1,2)).^6).^(-1);
            tau2 = tau0*(1+(R0./fitpar(2,2)).^6).^(-1); 
            % convert T1, fraction of time in state 1, to F1, i.e. the fractional intensity in state 1
            % (corresponding to number of donor photons)
            T1 = linspace(0,1,numel(PofT));
            F1 = T1.*tau1./(T1.*tau1+(1-T1).*tau2);
            if anisotropy_correction
                % correct for anisotropy
                tau1 = lifetime_correction_anisotropy(tau1,r0,rho/TACbin); % r0 and rho in TACbins
                tau2 = lifetime_correction_anisotropy(tau2,r0,rho/TACbin); % r0 and rho in TACbins
            end
            % correct for trunctation of exponential distribution
            [dt1_1,dt2_1] = lifetime_correction_truncation(tau1,file);  
            [dt1_2,dt2_2] = lifetime_correction_truncation(tau2,file);
            % calculate the moments, accounting for IRF
            %dt1_1 = tau1 + PDAMeta.IRF_moments{file}(1);
            %dt1_2 = tau2 + PDAMeta.IRF_moments{file}(1);
            % second moment is E[(X+Y)^2] = E[X^2]+E[Y^2]+2*E[X]*E[Y];
            % calculate parameters of the gamma distribution
            % E[X^2] of exponential is 2*tau
            %dt2_1 = 2*tau1.^2+PDAMeta.IRF_moments{file}(2)+2*tau1*PDAMeta.IRF_moments{file}(1);
            %dt2_2 = 2*tau2.^2+PDAMeta.IRF_moments{file}(2)+2*tau2*PDAMeta.IRF_moments{file}(1);
            % calculate mean and variance
            mean_t = F1.*dt1_1+(1-F1).*dt1_2;        
            var_t = repmat((F1.*dt2_1+(1-F1).*dt2_2-mean_t.^2),numel(NG),1)./repmat(NG,1,numel(F1)); % variance scales with number of photons
            % calculate parameters of gamma dist
            alpha = repmat(mean_t.^2,numel(NG),1)./var_t;
            beta_inv = (repmat(mean_t,numel(NG),1)./var_t).^(-1);
            tauG = repmat(PDAMeta.TauG{file}(PDAMeta.valid{file}),1,numel(PofT)); % donor average delay time
            L = L + log_gampdf(tauG,alpha,beta_inv);%log(gampdf(tauG,alpha,beta_inv));        
        end

        L = L + repmat(log(PofT),numel(NG),1);
        Lmax = max(L,[],2);
        L = Lmax + log(sum(exp(L-repmat(Lmax,1,numel(PofT))),2));
    elseif n_states == 3
        Peps = mixPE_3states_c(PDAMeta.eps_grid{file},PE{1},PE{2},PE{3},size(PofT,1),numel(PDAMeta.eps_grid{file}),Q(1),Q(2),Q(3));
        %%% as defined in the C code:
        %%% dimensions of Peps are eps,T2,T1
        Peps = reshape(Peps,numel(PDAMeta.eps_grid{file}),size(PofT,1),size(PofT,2));
        % that means: Peps(E,t2,t1) is the probability to see E when the
        % molecule was T1 = t1 in state 1, T2 = t2 in state 2 and T3 =
        % T-T1-T1 in state 3.

        %%% normalize Peps
        Peps = Peps./repmat(sum(Peps,1),size(Peps,1),1);
        Peps(isnan(Peps)) = 0;
        %%% combine mixtures, weighted with PofT (probability to see a certain
        %%% combination)
        
        %%% intensity-based likelihood
        L = NaN(numel(NG),size(PofT,1),size(PofT,2)); % log likelihood
        intensity = true;
        if intensity
            log_P_grid = PDAMeta.P_grid{file};
            log_Peps = log(Peps);
            parallel = false;
            nT = size(PofT,1);
            if ~parallel
                for t1 = 1:nT
                    for t2 = 1:(nT-t1+1)
                        t3 = nT - (t1-1) - (t2-1);
                        P =  log_P_grid + repmat(log_Peps(:,t2,t1)',numel(NG),1);
                        Lmax = max(P,[],2);
                        P = Lmax + log(sum(exp(P-repmat(Lmax,1,size(P,2))),2));
                        L(:,t3,t1) = P; % analogy to definition of PofT = PofT(t3,t1)
                    end
                end
            else
                parfor t3 = 1:nT
                    L_dummy = NaN(numel(NG),nT);
                    for t1 = 1:(nT-t3+1)
                        t2 = nT - (t3-1) - (t1-1);
                        P =  log_P_grid + repmat(log_Peps(:,t2,t1)',numel(NG),1);
                        Lmax = max(P,[],2);
                        P = Lmax + log(sum(exp(P-repmat(Lmax,1,size(P,2))),2));
                        L_dummy(:,t1) = P;
                    end
                    L(:,t3,:) = L_dummy; % analogy to definition of PofT = PofT(t3,t1)
                end
            end
        end
        %%% C function (also slow, additionally the indexing is not correct yet)
        %L = calculate_likelihood_3states(log_P_grid,log_Peps,size(PofT,1),size(PofT,2),numel(NG),size(log_Peps,1));
        %L = reshape(L,[numel(NG),size(PofT,1),size(PofT,2)]);
        %%% matrix implementation (even slower than loop)
        % L = repmat(log_P_grid,[1,1,20,20]) + repmat(shiftdim(permute(log_Peps,[1,3,2]),-1),numel(NG),1);
        % Lmax = max(L,[],2);
        % L = Lmax + log(sum(exp(L-repmat(Lmax,[1,size(L,2),1,1])),2));
        % L = squeeze(L);        
        %%% lifetime-based likelihood        
        if PDAMeta.lifetime_PDA
            % get the lifetimes of the species in TAC units
            TACbin = PDAData.Data{file}.TACbin; %in ns, i.e. 8 ps
            tau0 = tauD0./TACbin;
            tau1 = tau0*(1+(R0./fitpar(1,2)).^6).^(-1);
            tau2 = tau0*(1+(R0./fitpar(2,2)).^6).^(-1);
            tau3 = tau0*(1+(R0./fitpar(3,2)).^6).^(-1);            
            % convert T1, fraction of time in state 1, to F1, i.e. the fractional intensity in state 1
            % (corresponding to number of donor photons)
            [T1,T3] = meshgrid(linspace(0,1,size(PofT,1)),linspace(0,1,size(PofT,2)));
            % T3 in y-direction (down), T1 in x-direction (right) in PofT
            % remove invalid time combinations
            invalid = T1+T3 > 1;
            T1(invalid) = NaN;
            T3(invalid) = NaN;
            F1 = T1.*tau1./(T1.*tau1+(1-T1-T3).*tau2+T3.*tau3);
            F3 = T3.*tau3./(T1.*tau1+(1-T1-T3).*tau2+T3.*tau3);
            if anisotropy_correction
                % correct for anisotropy
                tau1 = lifetime_correction_anisotropy(tau1,r0,rho/TACbin); % r0 and rho in TACbins
                tau2 = lifetime_correction_anisotropy(tau2,r0,rho/TACbin); % r0 and rho in TACbins
                tau3 = lifetime_correction_anisotropy(tau3,r0,rho/TACbin); % r0 and rho in TACbins
            end
            % correct for trunctation of exponential distribution
            [dt1_1,dt2_1] = lifetime_correction_truncation(tau1,file);  
            [dt1_2,dt2_2] = lifetime_correction_truncation(tau2,file);
            [dt1_3,dt2_3] = lifetime_correction_truncation(tau3,file);
            % calculate the moments, accounting for IRF
            %dt1_1 = tau1 + PDAMeta.IRF_moments{file}(1);
            %dt1_2 = tau2 + PDAMeta.IRF_moments{file}(1);
            %dt1_3 = tau3 + PDAMeta.IRF_moments{file}(1);
            % second moment is E[(X+Y)^2] = E[X^2]+E[Y^2]+2*E[X]*E[Y];
            % calculate parameters of the gamma distribution
            % E[X^2] of exponential is 2*tau
            %dt2_1 = 2*tau1.^2+PDAMeta.IRF_moments{file}(2)+2*tau1*PDAMeta.IRF_moments{file}(1);
            %dt2_2 = 2*tau2.^2+PDAMeta.IRF_moments{file}(2)+2*tau2*PDAMeta.IRF_moments{file}(1);
            %dt2_3 = 2*tau3.^2+PDAMeta.IRF_moments{file}(2)+2*tau3*PDAMeta.IRF_moments{file}(1);
            % calculate mean and variance
            mean_t = F1.*dt1_1+(1-F1-F3).*dt1_2+F3.*dt1_3;
            v = (F1.*dt2_1+(1-F1-F3).*dt2_2+F3.*dt2_3-mean_t.^2);
            mean_t = reshape(mean_t,[1,size(mean_t,1),size(mean_t,2)]);
            v = reshape(v,[1,size(v,1),size(v,2)]);
            var_t = repmat(v,numel(NG),1,1)./repmat(NG,[1,size(F1,1),size(F1,2)]); % variance scales with number of photons
            % calculate parameters of gamma dist
            alpha = repmat(mean_t,numel(NG),1,1).^2./var_t;
            beta_inv = (repmat(mean_t,numel(NG),1,1)./var_t).^(-1);
            tauG = repmat(PDAMeta.TauG{file}(PDAMeta.valid{file}),[1,size(F1,1),size(F1,2)]); % donor average delay time
            L = L + log_gampdf(tauG,alpha,beta_inv);%log(gampdf(tauG,alpha,beta_inv));
        end
        %L = reshape(L,size(L,1),size(L,2)*size(L,3));
        % PofT(t3,t1) => PofT(n_burst,t3,t1)
        L = L + repmat(reshape(log(PofT),1,size(PofT,1),size(PofT,2)),numel(NG),1,1);
        L(isnan(L)) = -Inf; %%% NaNs produced for "impossible" combinations of T1 and T2 (i.e. T1+T2 > 1)
        L = reshape(L,size(L,1),size(L,2)*size(L,3));
        Lmax = max(L,[],2);
        L = Lmax + log(sum(exp(L-repmat(Lmax,1,numel(PofT))),2));
    end
    %%% Add static models
    if numel(PDAMeta.Comp{file}) > n_states
        %%% normalize Amplitudes
        % amplitudes of the static components are normalized to the total area 
        % 'norm' = area3 + area4 + area5 + k21/(k12+k21) + k12/(k12+k21) 
        % the k12 and k21 parameters are left untouched here so they will 
        % appear in the table. The area fractions are calculated in Update_Plots
        norm = (sum(fitpar(PDAMeta.Comp{file}(n_states+1:end),1))+1);
        %fitpar(PDAMeta.Comp{file}(n_states+1:end),1) = fitpar(PDAMeta.Comp{file}(n_states+1:end),1)./norm;
        
        L_static = cell(numel(PDAMeta.Comp{file}) - n_states);
        for c = PDAMeta.Comp{file}(n_states+1:end)
            %%% define Gaussian distribution of distances
            xR = (fitpar(c,2)-n_sigma*fitpar(c,3)):(2*n_sigma*fitpar(c,3)/steps):(fitpar(c,2)+n_sigma*fitpar(c,3));
            PR = normpdf(xR,fitpar(c,2),fitpar(c,3));
            PR = PR'./sum(PR);
            %%% Calculate E values for R grid
            E = 1./(1+(xR./R0).^6);
            epsGR = 1-(1+cr+(((de/(1-de)) + E) * gamma)./(1-E)).^(-1);

            %%% Calculate the vector of likelihood values
            P = eval_prob_2c_bg(NG,NF,...
                PDAMeta.NBG{file},PDAMeta.NBR{file},...
                PDAMeta.PBG{file}',PDAMeta.PBR{file}',...
                epsGR');
            P = log(P);
             %%% lifetime-based likelihood
            PDAMeta.lifetime_PDA = true;
            if PDAMeta.lifetime_PDA
                % get the lifetimes of the species in TAC units
                TACbin = PDAData.Data{file}.TACbin;  %in ns, i.e. 8 ps
                tau0 = tauD0./TACbin;
                tau = tau0*(1+(R0./fitpar(c,2)).^6).^(-1);
                if anisotropy_correction
                    % correct for anisotropy
                    tau = lifetime_correction_anisotropy(tau,r0,rho/TACbin); % r0 and rho in TACbins
                end
                % correct for trunctation of exponential distribution
                [dt1,dt2] = lifetime_correction_truncation(tau,file);
                % calculate the moments, accounting for IRF
                %dt1 = tau + PDAMeta.IRF_moments{file}(1);
                % second moment is E[(X+Y)^2] = E[X^2]+E[Y^2]+2*E[X]*E[Y];
                % calculate parameters of the gamma distribution
                % E[X^2] of exponential is 2*tau
                %dt2 = 2*tau.^2+PDAMeta.IRF_moments{file}(2)+2*tau*PDAMeta.IRF_moments{file}(1);
                % calculate mean and variance
                mean_t = dt1;        
                var_t = repmat((dt2-mean_t.^2),numel(NG),1)./NG; % variance scales with number of photons
                % calculate parameters of gamma dist
                alpha = repmat(mean_t.^2,numel(NG),1)./var_t;
                beta_inv = (repmat(mean_t,numel(NG),1)./var_t).^(-1);
                tauG = PDAMeta.TauG{file}(PDAMeta.valid{file}); % donor average delay time
                P = P + log_gampdf(tauG,alpha,beta_inv);%log(gampdf(tauG,alpha,beta_inv));        
            end
            P = P + repmat(log(PR'),numel(NG),1);
            Lmax = max(P,[],2);
            P = Lmax + log(sum(exp(P-repmat(Lmax,1,numel(PR))),2));
            %%% Treat case when all burst produced zero probability
            P(isnan(P)) = -Inf;
            L_static{c-n_states} = P;
        end
        %%% normalize amplitudes
        %fitpar(PDAMeta.Comp{file},1) = fitpar(PDAMeta.Comp{file},1)./sum(fitpar(PDAMeta.Comp{file},1));
        PA = [1,fitpar(PDAMeta.Comp{file}(n_states+1:end),1)']./norm;
        L = [L horzcat(L_static{:})];
        L = L + repmat(log(PA),numel(NG),1);
        Lmax = max(L,[],2);
        L = Lmax + log(sum(exp(L-repmat(Lmax,1,numel(PA))),2));
    end
    
    if h.SettingsTab.Use_Brightness_Corr.Value
        %%% Add Brightness Correction Probabilty here
        L = L + log(PN_scaled{j}(NG + NF));
    end
    %%% Treat case when all burst produced zero probability
    L(isnan(L)) = 0;
    L(NG == 0) = 0; % zero donor photons produce -Inf, reset to zero;
    logL = sum(L);
    %%% since the algorithm minimizes, it is important to minimize the negative
    %%% log likelihood, i.e. maximize the likelihood
    logL = -logL;
    % for extreme values, all elements are NaN and the likelihood evaluates
    % to 0, but should be Inf instead. Otherwise, the algorithm thinks this
    % is a good point.
    if logL == 0
        logL = Inf;
    end
end
fprintf('Likelihood calculation took %.2f s.\n',toc);

function L = log_gampdf(t,alpha,beta)
% returns the logarithm of the gamma distribution
% custom implementation that is faster than the MATLAB internal routine
%
% t, alpha, beta can be arrays of equal dimensions
L = -(alpha.*log(beta)+gammaln(alpha)) + (alpha-1).*log(t) - t./beta;

% MATLAB equivalent
% L = log(gampdf(tauG,alpha,beta));

% model for MLE fitting (global)
function [sum_logL] = PDAMLEFit_Global(fitpar,h)
global PDAMeta

%%% iterate the counter
PDAMeta.Fit_Iter_Counter = PDAMeta.Fit_Iter_Counter + 1;
%%% Aborts Fit
if mod(PDAMeta.Fit_Iter_Counter,PDAMeta.UpdateInterval) == 0
    drawnow;
end
if ~PDAMeta.FitInProgress
    sum_logL = 0;
    return;
end


FitParams = PDAMeta.FitParams;
Global = PDAMeta.Global;
Fixed = PDAMeta.Fixed;

P=zeros(numel(Global),1);

%%% Assigns global parameters
P(Global)=fitpar(1:sum(Global));
fitpar(1:sum(Global))=[];
PDAMeta.chi2 = zeros(numel(PDAMeta.Active),1);
for i=find(PDAMeta.Active)'
    PDAMeta.file = i;
    %%% Sets non-fixed parameters
    P(~Fixed(i,:) & ~Global)=fitpar(1:sum(~Fixed(i,:) & ~Global));
    fitpar(1:sum(~Fixed(i,:)& ~Global))=[];
    %%% Sets fixed parameters
    P(Fixed(i,:) & ~Global) = FitParams(i, (Fixed(i,:) & ~Global));  
    %%% calculate individual likelihoods
    PDAMeta.chi2(i) = PDA_MLE_Fit_Single(P,h);   
end
sum_logL = sum(PDAMeta.chi2);
PDAMeta.global_chi2 = sum_logL;

%%% if second iteration or more, update Progress Bar
if isfield(PDAMeta,'Last_logL')
    progress = exp(sum_logL-PDAMeta.Last_logL);
    if progress > 1
        progress = 0.99;
    end
    Progress(progress, h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Fitting Histograms...');
    Progress(progress, h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Fitting Histograms...');
end
set(PDAMeta.Chi2_All, 'Visible','on','String', ['sum logL = ' sprintf('%1.2f',sum_logL)]);
%%% store logL in PDAMeta
PDAMeta.Last_logL = sum_logL;

% Model for Monte Carlo based fitting (not global) 
function [chi2] = PDAMonteCarloFit_Single(fitpar,h)
global PDAMeta PDAData
%%% iterate the counter
PDAMeta.Fit_Iter_Counter = PDAMeta.Fit_Iter_Counter + 1;
%%% Aborts Fit
if mod(PDAMeta.Fit_Iter_Counter,PDAMeta.UpdateInterval) == 0
    drawnow;
end
if ~PDAMeta.FitInProgress
    if ~strcmp(h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value},'MLE')
        chi2 = 0;
        return;
    end
    %%% else continue
end

file = PDAMeta.file;
if PDAMeta.FitInProgress == 2 %%% we are estimating errors based on hessian, so input parameters are only the non-fixed parameters
    % only the non-fixed parameters are passed, reconstruct total fitpar
    % array from dummy data
    fitpar_dummy = PDAMeta.FitParams(file,:);
    fixed_dummy = PDAMeta.Fixed(file,:);
    if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
        %%% add sigma fraction to end
        fitpar_dummy = [fitpar_dummy, str2double(h.SettingsTab.SigmaAtFractionOfR_edit.String)];
        fixed_dummy = [fixed_dummy, h.SettingsTab.FixSigmaAtFractionOfR_Fix.Value];
    end
    if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
        %%% three-state system
        % Read the rates from the table
        rates = cell2mat(h.KineticRates_table.Data(:,1:2:end));
        rates = [rates(2,3),rates(3,1),rates(3,2)];
        fixed_rates = cell2mat(h.KineticRates_table.Data(:,2:2:end));
        fixed_rates = [fixed_rates(2,3),fixed_rates(3,1),fixed_rates(3,2)];
        fitpar_dummy = [fitpar_dummy, rates];
        fixed_dummy = [fixed_dummy, fixed_rates];
    end
    % overwrite free fit parameters
    fitpar_dummy(~fixed_dummy) = fitpar; 
    fitpar = fitpar_dummy;
end
%%% if dynamic model of three-state system, rates for third state are appended to fitpar array
if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
    rates_state3 = fitpar(end-2:end);
    fitpar(end-2:end) = [];
end
%%% if sigma is fixed at fraction of, read value here before reshape
if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
    fraction = fitpar(end);fitpar(end) = [];
end
%%% remove donor only fraction, not implemented here
fitpar= fitpar(1:end-1);

%%% fitpar vector is linearized by fminsearch, restructure
fitpar = reshape(fitpar',[3,numel(fitpar)/3]); fitpar = fitpar';

%%% if sigma is fixed at fraction of, change its value here
if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
    fitpar(:,3) = fraction.*fitpar(:,2);
end
%%% if dynamic and static species are linked, overwrite the distances and
%%% sigmas of the static species here
if h.SettingsTab.FixStaticToDynamicSpecies.Value == 1
    fitpar(3:4,2:3) = fitpar(1:2,2:3);
end

%Parameters
mBG_gg = PDAMeta.BGdonor(file);
mBG_gr = PDAMeta.BGacc(file);
dur = PDAData.timebin(file)*1E3;
if PDAData.timebin(file) == 0 %burstwise data was loaded
    dur = PDAData.Data{file}.Duration(PDAMeta.valid{file})*1E3;
end
cr = PDAMeta.crosstalk(file);
ct = PDAMeta.crosstalk(file);
R0 = PDAMeta.R0(file);
de = PDAMeta.directexc(file);
gamma = PDAMeta.gamma(file);
Nobins = str2double(h.SettingsTab.NumberOfBins_Edit.String);
sampling =str2double(h.SettingsTab.OverSampling_Edit.String);

if h.SettingsTab.Use_Brightness_Corr.Value
        %%% If brightness correction is to be performed, determine the relative
        %%% brightness based on current distance and correction factors
        BSD_scaled = cell(6,1);
        for c = PDAMeta.Comp{file}
            Qr = calc_relative_brightness(fitpar(c,2),file);
            %%% Rescale the PN;
            PN_scaled = scalePN(PDAData.BrightnessReference.PN,Qr);
            %%% fit PN_scaled to match PN of file
            PN_scaled = PN_scaled(1:numel(PDAMeta.PN{file}));
            PN_scaled = PN_scaled./sum(PN_scaled).*sum(PDAMeta.PN{file});
            
            PN_scaled = ceil(PN_scaled); % round to integer
            BSD_scaled{c} = zeros(sum(PN_scaled),1);
            count = 0;
            for i = 1:numel(PN_scaled)
                BSD_scaled{c}(count+1:count+PN_scaled(i)) = i;
                count = count+PN_scaled(i);
            end
            %%% BSD_scaled contains too many bursts now, remove randomly
            BSD_scaled{c} = BSD_scaled{c}(randperm(numel(BSD_scaled{c})));
            BSD_scaled{c} = BSD_scaled{c}(1:numel(PDAMeta.BSD{file}));
        end  
end

BSD = PDAMeta.BSD{file};

% H_meas = PDAMeta.hProx{file}';
%pool = gcp;
%sampling = pool.NumWorkers;

if ~h.SettingsTab.DynamicModel.Value %%% no dynamic model
    %%% normalize Amplitudes
    fitpar(PDAMeta.Comp{file},1) = fitpar(PDAMeta.Comp{file},1)./sum(fitpar(PDAMeta.Comp{file},1));
    A = fitpar(:,1);
    PRH = cell(sampling,5);
    for j = PDAMeta.Comp{file}
        if h.SettingsTab.Use_Brightness_Corr.Value
            BSD = BSD_scaled{j};
        end
        if size(BSD,2) > size(BSD,1)
            BSD = BSD';
        end
        for k = 1:sampling
            r = normrnd(fitpar(j,2),fitpar(j,3),numel(BSD),1);
            E = 1./(1+(r./R0).^6);
            eps = 1-(1+cr+(((de/(1-de)) + E) * gamma)./(1-E)).^(-1);
            BG_gg = poissrnd(mBG_gg.*dur,numel(BSD),1);
            BG_gr = poissrnd(mBG_gr.*dur,numel(BSD),1);
            BSD_bg = BSD-BG_gg-BG_gr;
            switch PDAMeta.xAxisUnit
                case 'Proximity Ratio'
                    PRH{k,j} = (binornd(BSD_bg,eps)+BG_gr)./BSD;
                case 'log(FD/FA)'
                    NF = binornd(BSD_bg,eps)+BG_gr;
                    PRH{k,j} = real(log10((BSD-NF)./NF));
                case {'FRET efficiency','Distance'}                    
                    NF = binornd(BSD_bg,eps);
                    ND = BSD-NF-BG_gg-BG_gr;
                    NF = NF-cr*ND-de*(gamma*ND+NF);
                    PRH{k,j} = NF./(gamma*ND+NF);
                    if strcmp(PDAMeta.xAxisUnit,'Distance')
                        PRH{k,j} = real(R0*(1./PRH{k,j}-1).^(1/6));
                    end
            end
        end
    end
    H_res_dummy = zeros(numel(PDAMeta.hProx{file}),5);
    for j = PDAMeta.Comp{file}
        H_res_dummy(:,j) = histcounts(vertcat(PRH{:,j}),linspace(PDAMeta.xAxisLimLow,PDAMeta.xAxisLimHigh,Nobins+1))./sampling;
    end
    hFit = zeros(numel(PDAMeta.hProx{file}),1);
    for j = PDAMeta.Comp{file}
        hFit = hFit + A(j).*H_res_dummy(:,j);
    end
else %%% dynamic model 
    % time bin in seconds
    %SimSteps = BSD; %
    % The DynRates matrix has the form:
    % ( 11 21 31 ... )
    % ( 12 22 32 ... )
    % ( 13 23 33 ... )
    % ( .. .. .. ... )
    switch h.SettingsTab.DynamicSystem.Value
        case 1
            %%% two-state system
            DynRates = 1000 * [0, fitpar(2,1); ...
                        fitpar(1,1), 0]; % rates in Hz
        case 2
            %%% three-state systme
            DynRates = 1000 * [0, fitpar(2,1),fitpar(3,1); ...
                        fitpar(1,1), 0,rates_state3(1);... 
                        rates_state3(2),rates_state3(3),0]; % rates in Hz
    end
    %%% obtain equlibrium distribution by solving K*p_eq = 0 and sum(p_eq) = 1
    n_states = size(DynRates,1);
    R = fitpar(:,2);%[fitpar(1,2),fitpar(2,2)];
    sigmaR = fitpar(:,3);%[fitpar(1,3),fitpar(2,3)];
    if n_states == 3
        change_prob = cumsum(DynRates);
        change_prob = change_prob ./ repmat(change_prob(end,:),3,1);
    end
    dwell_mean = 1 ./ sum(DynRates./1000);
    for i = 1:n_states
            DynRates(i,i) = -sum(DynRates(:,i));
    end
    DynRates(end+1,:) = ones(1,n_states);
    b = zeros(n_states,1); b(end+1) = 1;
    p_eq = DynRates\b;
    PRH = cell(1,sampling);
    if n_states == 3
        parfor k = 1:sampling
            PRH{1,k} = MonteCarlo_3states_oneSample(mBG_gg,mBG_gr,R,sigmaR,R0,cr,de,ct,gamma,numel(BSD),dur,BSD,dwell_mean,p_eq,change_prob);
        end
    else
        parfor k = 1:sampling
            PRH{1,k} = MonteCarlo_2states(mBG_gg,mBG_gr,R,sigmaR,R0,cr,de,ct,gamma,numel(BSD),dur,BSD,dwell_mean,p_eq,1);
        end
    end
    PRH = vertcat(PRH{:});
    switch PDAMeta.xAxisUnit
        case 'Proximity Ratio'
            % already PRH, do nothing
        case 'log(FD/FA)'
            NF = PRH.*repmat(BSD,[sampling,1]);
            PRH = real(log10((repmat(BSD,[sampling,1])-NF)./NF));
        case {'FRET efficiency','Distance'}                    
            NF = PRH.*repmat(BSD,[sampling,1]);
            ND = repmat(BSD,[sampling,1])-NF-BG_gg-BG_gr;
            NF = NF-cr*ND-de*(gamma*NG+NF);
            PRH = NF./(gamma*NG+NF);
            if strcmp(PDAMeta.xAxisUnit,'Distance')
                PRH = real(R0*(1./PRH-1).^(1/6));
            end
    end
    %%% Add static models
    if numel(PDAMeta.Comp{file}) > n_states
        fitpar(PDAMeta.Comp{file},1) = fitpar(PDAMeta.Comp{file},1)./sum(fitpar(PDAMeta.Comp{file},1));
        A = fitpar(:,1);
        PRH_stat = cell(sampling,5);
        for j = PDAMeta.Comp{file}(n_states+1:end)
            for k = 1:sampling
                r = normrnd(fitpar(j,2),fitpar(j,3),numel(BSD),1);
                E = 1./(1+(r./R0).^6);
                eps = 1-(1+cr+(((de/(1-de)) + E) * gamma)./(1-E)).^(-1);
                BG_gg = poissrnd(mBG_gg.*dur,numel(BSD),1);
                BG_gr = poissrnd(mBG_gr.*dur,numel(BSD),1);
                BSD_bg = BSD-BG_gg-BG_gr;
                switch PDAMeta.xAxisUnit
                    case 'Proximity Ratio'
                        PRH_stat{k,j} = (binornd(BSD_bg,eps)+BG_gr)./BSD;
                    case 'log(FD/FA)'
                        NF = binornd(BSD_bg,eps)+BG_gr;
                        PRH_stat{k,j} = real(log10((BSD-NF)./NF));
                    case {'FRET efficiency','Distance'}                    
                        NF = binornd(BSD_bg,eps);
                        ND = BSD-NF-BG_gg-BG_gr;
                        NF = NF-cr*ND-de*(gamma*ND+NF);
                        PRH_stat{k,j} = NF./(gamma*ND+NF);
                    if strcmp(PDAMeta.xAxisUnit,'Distance')
                        PRH_stat{k,j} = real(R0*(1./PRH_stat{k,j}-1).^(1/6));
                    end
                end
            end
        end
        PRH_dyn = histcounts(PRH,linspace(PDAMeta.xAxisLimLow,PDAMeta.xAxisLimHigh,Nobins+1))./sampling;
        if n_states == 2
            PRH_combined = [PRH_dyn; PRH_dyn; zeros(3,numel(PDAMeta.hProx{file}))];
        elseif n_states == 3
            PRH_combined = [PRH_dyn; PRH_dyn; PRH_dyn; zeros(2,numel(PDAMeta.hProx{file}))];
        end
        for j = PDAMeta.Comp{file}(n_states+1:end)
            PRH_combined(j,:) = histcounts(vertcat(PRH_stat{:,j}),linspace(PDAMeta.xAxisLimLow,PDAMeta.xAxisLimHigh,Nobins+1))./sampling;
        end
        hFit = zeros(1,numel(PDAMeta.hProx{file}));
        for j = PDAMeta.Comp{file}
            hFit = hFit + A(j).*PRH_combined(j,:);
        end
    else
        hFit = histcounts(PRH,linspace(PDAMeta.xAxisLimLow,PDAMeta.xAxisLimHigh,Nobins+1))./sampling;
    end
    PDAMeta.hFit_onlyDyn{file} = zeros(numel(PDAMeta.hProx{file}),1);
end
%%% Calculate Chi2
switch h.SettingsTab.Chi2Method_Popupmenu.Value
    case 2 %%% Assume gaussian error on data, normal chi2
        error = sqrt(PDAMeta.hProx{file});
        error(error == 0) = 1;
        w_res = (PDAMeta.hProx{file}-hFit)./error;
    case 1 %%% Assume poissonian error on data, MLE poissonian
        %%%% see:
        %%% Laurence, T. A. & Chromy, B. A. Efficient maximum likelihood estimator fitting of histograms. Nat Meth 7, 338?339 (2010).
        log_term = -2*PDAMeta.hProx{file}.*log(hFit./PDAMeta.hProx{file});
        log_term(isnan(log_term)) = 0;
        log_term(~isfinite(log_term)) = 0;
        dev_mle = 2*(hFit-PDAMeta.hProx{file})+log_term; dev_mle(dev_mle < 0) = 0;
        w_res = sign(hFit-PDAMeta.hProx{file}).*sqrt(dev_mle);
end
usedBins = sum(PDAMeta.hProx{file} ~= 0);
if ~h.SettingsTab.OuterBins_Fix.Value
    chi2 = sum((w_res.^2));
    if ~PDAMeta.FittingGlobal % return reduced chi2
        chi2 = chi2/(usedBins-numel(fitpar)-1);
    end
else
    % disregard outer bins
    chi2 = sum((w_res(2:end-1).^2));
    if ~PDAMeta.FittingGlobal % return reduced chi2
        chi2 = chi2/(usedBins-numel(fitpar)-3);
    end
    w_res(1) = 0;
    w_res(end) = 0;
end
hFit_Ind = cell(6,1);
for j = PDAMeta.Comp{file}
    if ~h.SettingsTab.DynamicModel.Value %%% no dynamic model
        hFit_Ind{j} = sum(PDAMeta.hProx{file}).*A(j).*H_res_dummy(:,j)./sum(H_res_dummy(:,1))';
    else
        hFit_Ind{j} = hFit'; 
    end        
end

PDAMeta.w_res{file} = w_res;
PDAMeta.hFit{file} = hFit;
PDAMeta.chi2(file) = chi2;
% this red. chi2 is for the single dataset,
% correct when global fitting
if PDAMeta.FittingGlobal % store reduced chi2
    PDAMeta.chi2(file) = PDAMeta.chi2(file)/(usedBins-numel(fitpar)-1);
end
comp = PDAMeta.Comp{file};
if h.SettingsTab.DynamicModel.Value && h.SettingsTab.DynamicSystem.Value == 2
    % for three-state model, some rates may be fixed to zero,
    % but the states should still be plotted
    comp = [1,2,3,comp(comp > 3)];
end
for c = comp
    PDAMeta.hFit_Ind{file,c} = hFit_Ind{c};
end
% PDAMeta.hFit_onlyDyn{file} = zeros(size(hFit));
if sum(PDAMeta.Global) == 0
    set(PDAMeta.Chi2_All, 'Visible','on','String', ['\chi^2_{red.} = ' sprintf('%1.2f',chi2)]);
end
set(PDAMeta.Chi2_Single, 'Visible', 'on','String', ['\chi^2_{red.} = ' sprintf('%1.2f',chi2)]);

if h.SettingsTab.LiveUpdate.Value && ~PDAMeta.FittingGlobal
    Update_Plots([],[],5)
end

% set(PDAMeta.Chi2_All, 'Visible','on','String', ['\chi^2_{red.} = ' sprintf('%1.2f',chi2)]);
% set(PDAMeta.Chi2_Single, 'Visible', 'on','String', ['\chi^2_{red.} = ' sprintf('%1.2f',chi2)]);
% 
% if h.SettingsTab.LiveUpdate.Value
%     Update_Plots([],[],5)
% end
tex = ['Fitting Histogram ' num2str(file) ' of ' num2str(sum(PDAMeta.Active))];

if PDAMeta.FitInProgress == 2 %%% return the residuals instead of chi2
    chi2 = w_res;
elseif PDAMeta.FitInProgress == 3 %%% return the loglikelihood
    switch h.SettingsTab.Chi2Method_Popupmenu.Value
        case 2 %%% Assume gaussian error on data, normal chi2
            loglikelihood = (-1/2)*sum(w_res.^2); %%% loglikelihood is the negative of chi2 divided by two
        case 1 %%% Assume poissonian error on data, MLE poissonian
            %%% compute loglikelihood without normalization to P(x|x)            
            log_term = PDAMeta.hProx{i}.*log(hFit');
            log_term(isnan(log_term)) = 0;
            log_term(~isfinite(log_term)) = 0;
            loglikelihood = sum(log_term-hFit');
    end
    chi2 = loglikelihood;
    PDAMeta.chi2(i) = chi2;
end

%Progress(1/chi2, h.AllTab.Progress.Axes, h.AllTab.Progress.Text, tex);
%Progress(1/chi2, h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text, tex);

% Model for Monte Carle based fitting (global) 
function [global_chi2] = PDAMonteCarloFit_Global(fitpar,h)
global PDAMeta UserValues
% h = guidata(findobj('Tag','GlobalPDAFit'));

%%% iterate the counter
PDAMeta.Fit_Iter_Counter = PDAMeta.Fit_Iter_Counter + 1;
%%% Aborts Fit
if mod(PDAMeta.Fit_Iter_Counter,PDAMeta.UpdateInterval) == 0
    drawnow;
end
if ~PDAMeta.FitInProgress
    global_chi2 = 0;
    return;
end

FitParams = PDAMeta.FitParams;
Global = PDAMeta.Global;
Fixed = PDAMeta.Fixed;

P=zeros(numel(Global),1);

%%% Assigns global parameters
P(Global)=fitpar(1:sum(Global));
fitpar(1:sum(Global))=[];
PDAMeta.chi2 = zeros(numel(PDAMeta.Active),1);

if UserValues.PDA.HalfGlobal
    % extract out half-global parameters (stored at the end)
    fitpar_halfglobal = fitpar(end-sum(PDAMeta.SampleGlobal)*(PDAMeta.Blocks-1)+1:end);
end
chi2 = {};
for i=find(PDAMeta.Active)'
    PDAMeta.file = i;
    if UserValues.PDA.HalfGlobal
        if any((PDAMeta.BlockSize+1):PDAMeta.BlockSize:(PDAMeta.BlockSize*PDAMeta.Blocks)==i)
            % if arriving at the next block, replace sample-based global values and delete from fitpar
            P(PDAMeta.SampleGlobal)=fitpar_halfglobal(1:sum(PDAMeta.SampleGlobal));
            fitpar_halfglobal(1:sum(PDAMeta.SampleGlobal))=[];
        end
    end
    %%% Sets non-fixed parameters
    P(~Fixed(i,:) & ~Global)=fitpar(1:sum(~Fixed(i,:) & ~Global));
    fitpar(1:sum(~Fixed(i,:)& ~Global))=[];
    %%% Sets fixed parameters
    P(Fixed(i,:) & ~Global) = FitParams(i, (Fixed(i,:) & ~Global));
    %%% Calculates function for current file
    chi2{end+1} = PDAMonteCarloFit_Single(P,h);
end
chi2 = vertcat(chi2{:});
if PDAMeta.FitInProgress == 2 % chi2 is actually array of w_res
    global_chi2 = sum(chi2.^2);
else
    global_chi2 = sum(chi2);
end

Active = find(PDAMeta.Active);
% normalize to return reduced chi2
% number of non-zero bins
usedBins = sum(horzcat(PDAMeta.hProx{Active}) ~= 0);
% number of free fit parameters (degrees of freedom)
% DOF = non-fixed
f = PDAMeta.Fixed(Active,:); g = PDAMeta.Global;
DOF = sum(f(:) == 0); 
if ~UserValues.PDA.HalfGlobal
    % DOF = non_fixed - global*(number_of_datasets-1);
    DOF = DOF - sum(g)*(numel(Active)-1);
else
    % separate global and half-global parameters
    g = g & ~PDAMeta.SampleGlobal;
    DOF = DOF - sum(g)*(numel(Active)-1);
    % half-global parameters account for 
    % (number_of_datasets/block_size)*(block_size-1)
    % lost degrees of freedom
    DOF = DOF - sum(PDAMeta.SampleGlobal & ~sum(f,1)).*(numel(Active)./PDAMeta.BlockSize)*(PDAMeta.BlockSize-1);
end
global_chi2 = global_chi2./(usedBins-DOF-1);
PDAMeta.global_chi2 = global_chi2;

Progress(1/global_chi2, h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Fitting Histograms...');
Progress(1/global_chi2, h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Fitting Histograms...');
set(PDAMeta.Chi2_All, 'Visible','on','String', ['global \chi^2_{red.} = ' sprintf('%1.2f',global_chi2)]);
if h.SettingsTab.LiveUpdate.Value
    for i = find(PDAMeta.Active)'
        PDAMeta.file = i;
        Update_Plots([],[],5);
    end
end

% Function to export the figures, figure data, and table data
function Export_Figure(~,~)
global PDAData UserValues PDAMeta
h = guidata(findobj('Tag','GlobalPDAFit'));

Path = uigetdir(fullfile(UserValues.File.PDAPath),...
    'Specify directory name');
fontsize = 16;
if ispc
    fontsize = fontsize/1.2;
end
linewidth = 1.5;
if Path == 0
    return
else
    Path = GenerateName(fullfile(Path, [datestr(now,'yymmdd') ' PDAFit']),2);
    % All tab
    fig = figure('Position',[100 ,100 ,900, 425],...
        'Color',[1 1 1],...
        'Resize','off');
    main_ax = copyobj(h.AllTab.Main_Axes,fig);
    res_ax = copyobj(h.AllTab.Res_Axes,fig);
    gauss_ax = copyobj(h.AllTab.Gauss_Axes,fig);
    main_ax.Children(end).Position = [1.35,1.09];
    main_ax.Color = [1 1 1];
    res_ax.Color = [1 1 1];
    main_ax.XColor = [0 0 0];
    main_ax.YColor = [0 0 0];
    res_ax.XColor = [0 0 0];
    res_ax.YColor = [0 0 0];
    main_ax.XLabel.Color = [0 0 0];
    main_ax.YLabel.Color = [0 0 0];
    res_ax.XLabel.Color = [0 0 0];
    res_ax.YLabel.Color = [0 0 0];
    main_ax.Units = 'pixel';
    res_ax.Units = 'pixel';
    main_ax.Position = [85 70 475 290];
    res_ax.Position = [85 360 475 50];
    main_ax.YTickLabel = main_ax.YTickLabel(1:end-1);
    main_ax.YTick(end) = [];
    gauss_ax.Color = [1 1 1];
    gauss_ax.XColor = [0 0 0];
    gauss_ax.YColor = [0 0 0];
    gauss_ax.XLabel.Color = [0 0 0];
    gauss_ax.YLabel.Color = [0 0 0];
    gauss_ax.Units = 'pixel';
    gauss_ax.Position = [660 70 225 290];
    %gauss_ax.GridAlpha = 0.1;
    %res_ax.GridAlpha = 0.1;
    gauss_ax.FontSize = fontsize;
    main_ax.FontSize = fontsize;
    res_ax.FontSize = fontsize;
    main_ax.Children(end).Units = 'pixel';
    
    set(fig,'PaperPositionMode','auto');
    print(fig,GenerateName(fullfile(Path, 'All.tif'),1),'-dtiff','-r150','-painters')
    %%% also save eps file
    print_eps(fig,GenerateName(fullfile(Path, 'All.eps'),1));
    %%% also save fig file
    savefig(fig,GenerateName(fullfile(Path, 'All.fig'),1));
    close(fig)
    
    % Active files
    Active = find(cell2mat(h.FitTab.Table.Data(1:end-3,1)))';
    
    for i = 1:numel(Active)
        fig = figure('Position',[100 ,100 ,900, 425],...
            'Color',[1 1 1],...
            'Resize','off');
        h.SingleTab.Popup.Value = i;
        Update_Plots([],[],2)
        main_ax = copyobj(h.SingleTab.Main_Axes,fig);
        res_ax = copyobj(h.SingleTab.Res_Axes,fig);
        gauss_ax = copyobj(h.SingleTab.Gauss_Axes,fig);
        % position of chi2
        main_ax.Children(end).Position = [1.35,1.09];
        main_ax.Children(end).FontSize =fontsize;
        
        main_ax.Color = [1 1 1];
        res_ax.Color = [1 1 1];
        main_ax.XColor = [0 0 0];
        main_ax.YColor = [0 0 0];
        res_ax.XColor = [0 0 0];
        res_ax.YColor = [0 0 0];
        main_ax.XLabel.Color = [0 0 0];
        main_ax.YLabel.Color = [0 0 0];
        res_ax.XLabel.Color = [0 0 0];
        res_ax.YLabel.Color = [0 0 0];
        main_ax.Units = 'pixel';
        res_ax.Units = 'pixel';
        main_ax.Position = [85 60 475 290];
        res_ax.Position = [85 350 475 50];
        main_ax.YTickLabel = main_ax.YTickLabel(1:end-1);
        main_ax.YTick(end) = [];
        gauss_ax.Color = [1 1 1];
        gauss_ax.XColor = [0 0 0];
        gauss_ax.YColor = [0 0 0];
        gauss_ax.XLabel.Color = [0 0 0];
        gauss_ax.YLabel.Color = [0 0 0];
        gauss_ax.Units = 'pixel';
        gauss_ax.Position = [660 60 225 290];
        %gauss_ax.GridAlpha = 0.1;
        %res_ax.GridAlpha = 0.1;
        gauss_ax.FontSize = fontsize;
        
        %%% more style updates
        main_ax.Layer = 'top';
        main_ax.XGrid = 'off';
        main_ax.YGrid = 'off';
        set(main_ax.Children(1:end-2),'LineStyle','-');
        set(main_ax.Children,'LineWidth',linewidth);
        main_ax.LineWidth = linewidth;
        main_ax.FontSize = fontsize;
        res_ax.FontSize = fontsize;
        res_ax.LineWidth = linewidth;
        main_ax.Children(end-1).FaceColor = [150,150,150]./255;
        res_ax.XGrid = 'off';
        res_ax.YGrid = 'off';
        res_ax.Children(1).LineWidth = linewidth;
        %main_ax.YLabel.Position(1) = -0.105;
        %res_ax.YLabel.Position(1) = -0.09;
        colors = lines(7); yellow = colors(3,:); colors(3,:) = [];
        for j = 2:7
            main_ax.Children(j).Color = colors(8-j,:);
        end
        main_ax.Children(1).Color = yellow; % dynamic mixing component
        uistack(main_ax.Children(8),'top')
        gauss_ax.Layer = 'top';
        gauss_ax.XGrid = 'off';
        gauss_ax.YGrid = 'off';
        gauss_ax.LineWidth = linewidth;
        gauss_ax.XLabel.String = 'Distance [A]';
        uistack(gauss_ax.Children(7),'top');
        set(gauss_ax.Children,'LineWidth',linewidth);
        
        %%% add filename
        fs = 14;
        if ispc
            fs = fs/1.2;
        end
        uicontrol(gcf,'Style','text',...
            'String',PDAData.FileName{Active(i)}(1:end-4),...
            'BackgroundColor',[1,1,1],'FontSize',fs,'FontWeight','bold',...            
            'Position',[85 405 800 20]);
        
        main_ax.Children(end).Units = 'pixel';
        set(fig,'PaperPositionMode','auto');
        print(fig,'-dtiff','-r150',GenerateName(fullfile(Path, [PDAData.FileName{Active(i)}(1:end-4) '.tif']),1),'-painters')
        %%% also save eps file
        print_eps(fig,GenerateName(fullfile(Path, [PDAData.FileName{Active(i)}(1:end-4) '.eps']),1));
        %%% also save fig file
        savefig(fig,GenerateName(fullfile(Path, [PDAData.FileName{Active(i)}(1:end-4) '.fig']),1));
        close(fig)
    end
    
    % Function to export all figure and table data to a structure (for external use)
    
    % save file info
    tmp = struct;
    tmp.file = PDAData.FileName;
    tmp.path = PDAData.PathName;
    tmp.active = Active;
    h = guidata(findobj('Tag','GlobalPDAFit'));
    
    % save the fit table
    tmp.fittable = cell(size(h.FitTab.Table.Data, 1)-2, size(h.FitTab.Table.Data(1,2:3:end), 2));
    tmp.fittable(1,:) = h.FitTab.Table.ColumnName(2:3:end);
    tmp.fittable(2:end,:) = h.FitTab.Table.Data(1:end-3,2:3:end);
    
    % save the parameters table
    tmp.parameterstable = cell(size(h.ParametersTab.Table.Data));
    tmp.parameterstable(1,:) = h.ParametersTab.Table.ColumnName;
    tmp.parameterstable(2:end,:) = h.ParametersTab.Table.Data(1:end-1,:);
    
    % save the Gauss plots
    datasize = size(PDAMeta.Plots.Gauss_All,1);
    gausx = size(PDAMeta.Plots.Gauss_All{1,1}.XData,2);
    data = [];
    header = cell(1,datasize*7);
    for i = 1:datasize
        %x
        data(1:gausx,7*i-6) = PDAMeta.Plots.Gauss_All{i,1}.XData;
        for j = 1:6
            %gauss
            data(1:gausx,7*i-6+j) = PDAMeta.Plots.Gauss_All{i,j}.YData;
        end
        header(7*i-6:7*i) = {'x','gauss_sum','gauss1','gauss2','gauss3','gauss4','gauss5'};
    end
    tmp.gauss = data;
    tmp.gaussheader = header;
    
    % save Epr histograms, fit and res
    datax = size(PDAMeta.Plots.Data_All{1,1}.XData,2);
    data = [];
    header = cell(1,datasize*9);
    for i = 1:datasize
        %x axis
        data(1:datax,11*i-10) = PDAMeta.Plots.Data_All{i,1}.XData;
        % data
        data(1:datax,11*i-9) = PDAMeta.Plots.Data_All{i,1}.YData;
        % res
        data(1:datax,11*i-8) = PDAMeta.Plots.Res_All{i,1}.YData;
        for j = 1:8
            %fit
            data(1:datax,11*i-8+j) = PDAMeta.Plots.Fit_All{i,j}.YData;
        end
        header(11*i-10:11*i) = {'x','data','res','fit_sum','fit1','fit2','fit3','fit4','fit5','Donly','dynamic'};
    end
    tmp.epr = data;
    tmp.eprheader = header;
    
    % save the settings
    tmp.settings = UserValues.PDA;
    assignin('base','DataTableStruct',tmp);
    save(GenerateName(fullfile(Path, 'figure_table_data.mat'),1), 'tmp')
    
    %%% save everything to an excel table
    fitResult = cell(size(tmp.fittable,1),size(tmp.fittable,2));
    fitResult{1,1} = 'FileNames';
    fitResult(2:numel(tmp.file)+1,1) = tmp.file';
    tmp.fittable(2:end,:) = num2cell(cellfun(@str2double,tmp.fittable(2:end,:)));
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,'<HTML><b> ',''),tmp.fittable(1,:),'UniformOutput',false);
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,'<HTML><b>',''),tmp.fittable(1,:),'UniformOutput',false);
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,'<b>',''),tmp.fittable(1,:),'UniformOutput',false);
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,'</b>',''),tmp.fittable(1,:),'UniformOutput',false);
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,'<sub>','_'),tmp.fittable(1,:),'UniformOutput',false);
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,'</sub>',''),tmp.fittable(1,:),'UniformOutput',false);
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,'&',''),tmp.fittable(1,:),'UniformOutput',false);
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,';',''),tmp.fittable(1,:),'UniformOutput',false);
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,'<html>',''),tmp.fittable(1,:),'UniformOutput',false);
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,'</html>',''),tmp.fittable(1,:),'UniformOutput',false);
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,'<sup>','^'),tmp.fittable(1,:),'UniformOutput',false);
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,'</sup>',''),tmp.fittable(1,:),'UniformOutput',false);
    tmp.fittable(1,:) = cellfun(@(x) strrep(x,'Aring','A'),tmp.fittable(1,:),'UniformOutput',false);    
    fitResult(1:size(tmp.fittable,1),2:size(tmp.fittable,2)+1) = tmp.fittable;
    %%% write to text file
    fID  = fopen(GenerateName(fullfile(Path, 'PDAresult.txt'),1),'w');
    fprintf(fID,[repmat('%s\t',1,size(fitResult,2)-1),'%s\n'],fitResult{1,:});
    for i = 2:size(fitResult,1)
        fprintf(fID,['%s' repmat('\t%.3f',1,size(fitResult,2)-1) '\n\n'],fitResult{i,:});
    end
    fprintf(fID,'Parameters:\n');
    fprintf(fID,[repmat('%s\t',1,6) '%s\n'],tmp.parameterstable{1,:});
    for i = 2:size(tmp.parameterstable,1)
        fprintf(fID,[repmat('%.3f\t',1,6) '%.3f\n'],tmp.parameterstable{i,:});
    end
    fprintf(fID,'\nSettings:\n');
    settings = [fieldnames(tmp.settings), struct2cell(tmp.settings)];
    for i = 1:size(settings,1)
        if ischar(settings{i,2})
            settings{i,2} = str2double(settings{i,2});
        end
    end
    for i = 1:size(settings,1)-2
        fprintf(fID,'%s\t%d\n',settings{i,:});
    end
    fprintf(fID,'%s\t%.3f\n',settings{end-1,:});
    fprintf(fID,'%s\t%.3f\n',settings{end,:});
    fclose(fID);
    %%% save plot data also
    fID  = fopen(GenerateName(fullfile(Path, 'Plots.txt'),1),'w');
    data = [tmp.eprheader; num2cell(tmp.epr)];
    fprintf(fID,[repmat('%s\t',1,size(data,2)-1) '%s\n'],data{1,:});
    formatSpec = [repmat('%.3f\t',1,size(data,2)-1) '%.3f\n'];
    for i = 2:size(data,1)
        fprintf(fID,formatSpec,data{i,:});
    end
    fclose(fID);
end

% Update the Fit Tab
function Update_FitTable(obj,e,mode)
h = guidata(findobj('Tag','GlobalPDAFit'));
global PDAMeta PDAData
if obj == h.FitTab.Table
    %%% read current scrollbar position
    pos_y = h.jobj.FitTable_JScrollPane.getVerticalScrollBar.getValue;
    pos_x = h.jobj.FitTable_JScrollPane.getHorizontalScrollBar.getValue;
end
switch mode
    case 0 %%% Updates whole table (Open UI)
        %%% Disables cell callbacks, to prohibit double callback
        h.FitTab.Table.CellEditCallback=[];
        %%% Column namges & widths
        Columns=cell(59,1);
        Columns{1}='Active';
        for i=1:6
            Columns{9*i-7}=['<HTML><b> A<sub>' num2str(i) '</sub></b>'];
            Columns{9*i-6}='F';
            Columns{9*i-5}='G';
            Columns{9*i-4}=['<HTML><b> R<sub>' num2str(i) '</sub> [&Aring;]</b>'];
            Columns{9*i-3}='F';
            Columns{9*i-2}='G';
            Columns{9*i-1}=['<HTML><b> &sigma;<sub>'  num2str(i) '</sub> [&Aring;]</b>'];
            Columns{9*i}='F';
            Columns{9*i+1}='G';
        end
        Columns{56} = '<HTML><b>D<sub>only</sub></b>';
        Columns{57} = 'F';
        Columns{58} = 'G';
        Columns{end}='<html><b>&chi;<sup>2</sup><sub>red.</sub></b></html>';
        ColumnWidth=zeros(numel(Columns),1);
        ColumnWidth(2:3:end-3)=40;
        ColumnWidth(2:9:end-12)=40;
        ColumnWidth(3:3:end-2)=15;
        ColumnWidth(4:3:end-1)=15;
        ColumnWidth(1)=40;
        ColumnWidth(end-1)=15;
        ColumnWidth(end)=40;
        h.FitTab.Table.ColumnName=Columns;
        h.FitTab.Table.ColumnWidth=num2cell(ColumnWidth');
        %%% Sets row names to file names
        Rows=cell(numel(PDAData.Data)+3,1);
        Rows(1:numel(PDAData.Data))=deal(PDAData.FileName);
        Rows{end-2}='ALL';
        Rows{end-1}='Lower bound';
        Rows{end}='Upper bound';
        h.FitTab.Table.RowName=Rows;
        %%% Create table data:
        %%% 1           = Active
        %%% 2:3:end-3   = Parameter value
        %%% 3:3:end-2   = Checkbox to fix parameter
        %%% 4:3:end-1   = Checkbox to fit parameter globally
        %%% 47          = chi^2
        Data=num2cell(zeros(numel(Rows),numel(Columns)));
        % put in data if it exists
        %Data(1:end-3,9:3:end)=deal(num2cell(PDAData.FitTable)');
        % fill in the all row
        tmp = [1; 50; 5; 1; 50; 5; 0; 50; 5; 0; 50; 5; 0; 50; 5; 0; 50; 5; 0];
        Data(end-2,2:3:end-3)=deal(num2cell(tmp)');
        % fill in boundaries
        Data(end-1,2:3:end)=deal({0});
        Data(end,2:3:end)=deal({inf});
        Data=cellfun(@num2str,Data,'UniformOutput',false);
        % active checkbox
        Data(:,1)=deal({true});
        Data(2:end,1)=deal({[]});
        % fix checkboxes
        Data(1,3:3:end)=deal({false});
        Data(2:end,3:3:end)=deal({[]});
        % put the last three gaussians to fixed and zero amplitude
        Data(1,21:3:end)=deal({true});
        Data(1,20:9:end)=deal({'0'});
        % global checkboxes
        Data(1,4:3:end)=deal({false});
        Data(2:end,4:3:end)=deal({[]});
        h.FitTab.Table.Data=Data;
        PDAMeta.Params = cellfun(@str2double,h.FitTab.Table.Data(end-2,2:3:end));
        h.FitTab.Table.ColumnEditable=[true(1,numel(Columns)-1),false];
        %%% Enables cell callback again
        h.FitTab.Table.CellEditCallback={@Update_FitTable,3};        
    case 1 %%% Updates tables when new data is loaded
            h.FitTab.Table.CellEditCallback=[];
            %%% Sets row names to file names
            Rows=cell(numel(PDAData.Data)+3,1);
            tmp = PDAData.FileName;
            %%% Cuts the filename up if too long
            for i = 1:numel(tmp)
               try 
                   tmp{i} = [tmp{i}(1:15) '...' tmp{i}(end-15:end)];
               end
            end
            Rows(1:numel(tmp))=deal(tmp);
            Rows{end-2}='ALL';
            Rows{end-1}='Lower bound';
            Rows{end}='Upper bound';
            h.FitTab.Table.RowName=Rows;
            Data=cell(numel(Rows),size(h.FitTab.Table.Data,2));
            %%% Sets previously loaded files
            Data(1:(size(h.FitTab.Table.Data,1)-3),:)=h.FitTab.Table.Data(1:end-3,:);
            %%% Set last 3 row to ALL, lb and ub
            Data(end-2:end,:)=h.FitTab.Table.Data(end-2:end,:);
            %%% Add FitTable data of new files in between old data and ALL row
            a = size(h.FitTab.Table.Data,1)-2; %if open data had 3 sets, new data has 3+2 sets, then a = 4
            for i = a:(size(Data,1)-3) % i = 4:5
                if ~(numel(PDAData.FitTable{i}) == 59) % should be 59 elements
                    %%% Added D only fraction, so check old data for compatibility
                    if (numel(PDAData.FitTable{i}) ~= 50)
                        dummy = cell(50,1);
                        dummy(1:46) = PDAData.FitTable{i}(1:46);
                        dummy(47:49) = {'0',true,false};
                        dummy(50) = PDAData.FitTable{i}(end);
                        PDAData.FitTable{i} = dummy;
                    end
                    if (numel(PDAData.FitTable{i}) ~= 59) %%% before addition of sixth species
                        dummy = cell(59,1);
                        dummy(1:46) = PDAData.FitTable{i}(1:46);
                        dummy(47:55) = {'0',true,false,'50',true,false,'5',true,false};
                        dummy(56:58) = PDAData.FitTable{i}(47:49);
                        dummy(59) = PDAData.FitTable{i}(end);
                        PDAData.FitTable{i} = dummy;
                    end
                end
                Data(i,:) = PDAData.FitTable{i};
            end
            for i = 1:19 % all fittable parameters
                if all(cell2mat(Data(1:end-3,3*(i-1)+4)))
                    % this parameter is global for all files
                    % so make the ALL row also global
                    Data(end-2,3*(i-1)+4) = {true};
                    % make the fix checkbox false
                    Data(end-2,3*(i-1)+3) = {false};
                    % make the ALL row the mean of all values for that parameter
                    Data(end-2,3*(i-1)+2) = {num2str(mean(cellfun(@str2double,Data(1:end-3,3*(i-1)+2))))};
                else
                    % this parameter is not global for all files
                    % so make it not global for all files
                    Data(1:end-2,3*(i-1)+4) = {false};
                end
                if all(cell2mat(Data(1:end-3,3*(i-1)+3)))
                    % all of the fix checkboxes are true
                    % make the ALL fix checkbox true
                    Data(end-2,3*(i-1)+3) = {true};
                else
                    Data(end-2,3*(i-1)+3) = {false};
                end           
            end
            h.FitTab.Table.Data=Data;
            %%% Enables cell callback again
            h.FitTab.Table.CellEditCallback={@Update_FitTable,3};
            PDAMeta.PreparationDone = zeros(numel(PDAData.Data),1);
            PDAMeta.Params = cellfun(@str2double,h.FitTab.Table.Data(end-2,2:3:end));
            
            %%% three state system
            h.KineticRates_table.CellEditCallback=[];
            Data=cell(size(h.FitTab.Table.Data,1),18);
            %%% Sets previously loaded files
            Data(1:(size(h.KineticRates_table.Data,1)-3),:)=h.KineticRates_table.Data(1:end-3,:);
            %%% Set last 3 row to ALL, lb and ub
            Data(end-2:end,:)=h.KineticRates_table.Data(end-2:end,:);
            %%% Add FitTable data of new files in between old data and ALL row
            a = size(h.KineticRates_table.Data,1)-2; %if open data had 3 sets, new data has 3+2 sets, then a = 4
            for i = a:(size(Data,1)-3) % i = 4:5
                if ~isempty(PDAData.KineticRatesTable{i})
                    % kinetic rates for three states exist
                    try
                        Data(i,:) = PDAData.KineticRatesTable{i};
                    catch 
                        Data(i,:) = repmat({1,false,false},1,6);
                    end
                else % fill in standard values
                    Data(i,:) = repmat({1,false,false},1,6);
                end
            end
            for i = 1:6 % all fittable parameters
                if all(cell2mat(Data(1:end-3,3*(i-1)+3)))
                    % this parameter is global for all files
                    % so make the ALL row also global
                    Data(end-2,3*(i-1)+3) = {true};
                    % make the fix checkbox false
                    Data(end-2,3*(i-1)+2) = {false};
                    % make the ALL row the mean of all values for that parameter
                    Data(end-2,3*(i-1)+1) = {mean(cellfun(@str2double,Data(1:end-3,3*(i-1)+1)))};
                else
                    % this parameter is not global for all files
                    % so make it not global for all files
                    Data(1:end-2,3*(i-1)+3) = {false};
                end
                if all(cell2mat(Data(1:end-3,3*(i-1)+2)))
                    % all of the fix checkboxes are true
                    % make the ALL fix checkbox true
                    Data(end-2,3*(i-1)+2) = {true};
                else
                    Data(end-2,3*(i-1)+2) = {false};
                end           
            end
            h.KineticRates_table.Data=Data;
            %%% Enables cell callback again
            h.KineticRates_table.CellEditCallback={@Update_FitTable,3};
            PDAMeta.Params_3States = cellfun(@str2double,h.KineticRates_table.Data(end-2,2:3:end));
    case 2 %%% Re-loads table from loaded data upon File menu - load fit parameters
        for i = 1:numel(PDAData.FileName)
            h.FitTab.Table.Data(i,:) = PDAData.FitTable{i};
        end
        PDAMeta.Params = cellfun(@str2double,h.FitTab.Table.Data(end-2,2:3:end));
    case 3 %%% Individual cells callbacks
        switch obj
            case h.FitTab.Table
                tab = h.FitTab.Table;
                %%% Disables cell callbacks, to prohibit double callback
                tab.CellEditCallback=[];
                %pause(0.25) %leave here, otherwise matlab will magically prohibit cell callback even before you click the cell
                if strcmp(e.EventName,'CellSelection') %%% No change in Value, only selected
                    if isempty(e.Indices) || (e.Indices(2)~=1) %%% (e.Indices(1)~=(size(tab.Data,1)-1) && e.Indices(2)~=1)
                        tab.CellEditCallback={@Update_FitTable,3};
                        return;
                    end
                    NewData = tab.Data{e.Indices(1),e.Indices(2)};
                end
                if isprop(e,'NewData')
                    NewData = e.NewData;
                end
                if e.Indices(1)==size(tab.Data,1)-2
                    %%% ALL row was used => Applies to all files
                    tab.Data(1:end-2,e.Indices(2))=deal({NewData});
                    if mod(e.Indices(2)-2,3)==0 && e.Indices(2)>=1
                        %%% Value was changed => Apply value to global variables
                    elseif mod(e.Indices(2)-3,3)==0 && e.Indices(2)>=2 && NewData==1
                        %%% Value was fixed => Uncheck global
                        %%% Uncheck global for all files to prohibit fixed and global
                        tab.Data(1:end-2,e.Indices(2)+1)=deal({false});
                    elseif mod(e.Indices(2)-4,3)==0 && e.Indices(2)>=3 && NewData==1
                        %%% Global was change
                        %%% Apply value to all files
                        tab.Data(1:end-2,e.Indices(2)-2)=tab.Data(e.Indices(1),e.Indices(2)-2);
                        %%% Unfixes all files to prohibit fixed and global
                        tab.Data(1:end-2,e.Indices(2)-1)=deal({false});
                    elseif e.Indices(2) == 1
                        %%% Active was changed
                        if strcmp(e.EventName,'CellSelection')
                            tab.Data(1:end-2,1) = deal({~NewData});
                        else
                            tab.Data(1:end-2,1) = deal({NewData});
                        end
                    end
                elseif mod(e.Indices(2)-4,3)==0 && e.Indices(2)>=4 && e.Indices(1)<size(tab.Data,1)-1
                    %%% Global was changed => Applies to all files
                    tab.Data(1:end-2,e.Indices(2))=deal({NewData});
                    if NewData
                        %%% Apply value to all files
                        tab.Data(1:end-2,e.Indices(2)-2)=tab.Data(e.Indices(1),e.Indices(2)-2);
                        %%% Unfixes all file to prohibit fixed and global
                        tab.Data(1:end-2,e.Indices(2)-1)=deal({false});
                    end
                elseif mod(e.Indices(2)-3,3)==0 && e.Indices(2)>=3 && e.Indices(1)<size(tab.Data,1)-1
                    %%% Value was fixed
                    %%% if an amplitude was clicked, check if it is zero
                    %%% -if it is zero and was disabled before, enable all related
                    %%% parameters
                    %%% -otherwise, disable all
                    if any(e.Indices(2) == 3:9:size(tab.Data,2)-11)
                        if strcmp(tab.Data(e.Indices(1),e.Indices(2)-1),'0')
                            if NewData == true
                                tab.Data(e.Indices(1),[e.Indices(2)+3,e.Indices(2)+6]) = deal({true});
                            elseif NewData == false
                                tab.Data(e.Indices(1),[e.Indices(2)+3,e.Indices(2)+6]) = deal({false});
                            end
                        end
                    end
                    %%% Updates ALL row
                    if all(cell2mat(tab.Data(1:end-3,e.Indices(2))))
                        tab.Data{end-2,e.Indices(2)}=true;
                    else
                        tab.Data{end-2,e.Indices(2)}=false;
                    end
                    %%% Unchecks global to prohibit fixed and global
                    tab.Data(1:end-2,e.Indices(2)+1)=deal({false;});
                elseif mod(e.Indices(2)-2,3)==0 && e.Indices(2)>=2 && e.Indices(1)<size(tab.Data,1)-1
                    %%% Value was changed
                    if tab.Data{e.Indices(1),e.Indices(2)+2}
                        %%% Global => changes value of all files
                        tab.Data(1:end-2,e.Indices(2))=deal({NewData});
                    else
                        %%% Not global => only changes value
                    end
                end
                if e.Indices(2)==1
                    %%% Active was changed
                    %%% check if at least one fit is still active
                    if sum(cell2mat(tab.Data(1:end-3,1))) >= 0
                        tab.Enable='off';
                        pause(0.2)
                        %Update_Plots([],[],4)
                        Update_Plots([],[],2) % to display the correct one on the single tab
                        tab.Enable='on';
                    else
                        %%% reset status
                        tab.Data{e.Indices(1),e.Indices(2)} = true;
                    end
                end
                %%% Enables cell callback again
                tab.CellEditCallback={@Update_FitTable,3};
               
            case h.KineticRates_table
                tab = h.KineticRates_table;
                %%% Disables cell callbacks, to prohibit double callback
                tab.CellEditCallback=[];
                %pause(0.25) %leave here, otherwise matlab will magically prohibit cell callback even before you click the cell
                if strcmp(e.EventName,'CellSelection') %%% No change in Value, only selected
                    if isempty(e.Indices) || (e.Indices(1)~=(size(tab.Data,1)-1))
                        tab.CellEditCallback={@Update_FitTable,3};
                        return;
                    end
                    NewData = tab.Data{e.Indices(1),e.Indices(2)};
                end
                if isprop(e,'NewData')
                    NewData = e.NewData;
                end
                if e.Indices(1)==size(tab.Data,1)-2
                    %%% ALL row was used => Applies to all files
                    tab.Data(1:end-2,e.Indices(2))=deal({NewData});
                    if mod(e.Indices(2)-1,3)==0
                        %%% Value was changed => Apply value to global variables
                    elseif mod(e.Indices(2)-2,3)==0 && e.Indices(2)>=1 && NewData==1
                        %%% Value was fixed => Uncheck global
                        %%% Uncheck global for all files to prohibit fixed and global
                        tab.Data(1:end-2,e.Indices(2)+1)=deal({false});
                    elseif mod(e.Indices(2)-4,3)==0 && e.Indices(2)>=3 && NewData==1
                        %%% Global was change
                        %%% Apply value to all files
                        tab.Data(1:end-2,e.Indices(2)-2)=tab.Data(e.Indices(1),e.Indices(2)-2);
                        %%% Unfixes all files to prohibit fixed and global
                        tab.Data(1:end-2,e.Indices(2)-1)=deal({false});                    
                    end
                elseif mod(e.Indices(2)-3,3)==0 && e.Indices(2)>=3 && e.Indices(1)<size(tab.Data,1)-1
                    %%% Global was changed => Applies to all files
                    tab.Data(1:end-2,e.Indices(2))=deal({NewData});
                    if NewData
                        %%% Apply value to all files
                        tab.Data(1:end-2,e.Indices(2)-2)=tab.Data(e.Indices(1),e.Indices(2)-2);
                        %%% Unfixes all file to prohibit fixed and global
                        tab.Data(1:end-2,e.Indices(2)-1)=deal({false});
                    end
                elseif mod(e.Indices(2)-2,3)==0 && e.Indices(2)>=2 && e.Indices(1)<size(tab.Data,1)-1
                    %%% Value was fixed
                    %%% Updates ALL row
                    if all(cell2mat(tab.Data(1:end-3,e.Indices(2))))
                        tab.Data{end-2,e.Indices(2)}=true;
                    else
                        tab.Data{end-2,e.Indices(2)}=false;
                    end
                    %%% Unchecks global to prohibit fixed and global
                    tab.Data(1:end-2,e.Indices(2)+1)=deal({false;});
                elseif mod(e.Indices(2)-2,3)==0 && e.Indices(2)>=2 && e.Indices(1)<size(tab.Data,1)-1
                    %%% Value was changed
                    if tab.Data{e.Indices(1),e.Indices(2)+2}
                        %%% Global => changes value of all files
                        tab.Data(1:end-2,e.Indices(2))=deal({NewData});
                    else
                        %%% Not global => only changes value
                    end
                end                
                %%% Enables cell callback again
                tab.CellEditCallback={@Update_FitTable,3};
        end 
end

if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1 %%% Fix Sigma at Fraction of R
    %%% Disables cell callbacks, to prohibit double callback
    h.FitTab.Table.CellEditCallback=[];
    %%% Get Table Data
    Data = h.FitTab.Table.Data;
    %%% Read out fraction
    fraction = str2double(h.SettingsTab.SigmaAtFractionOfR_edit.String);
    for i = 1:(size(Data,1)-2)
        %%% Fix all sigmas
        Data(i,9:9:end) = deal({true});
        %%% set to fraction times distance
        Data(i,8:9:end) = cellfun(@(x) num2str(fraction.*str2double(x)),Data(i,5:9:end-1),'UniformOutput',false);
    end
    %%% Set Table Data
    h.FitTab.Table.Data = Data;
    %%% Enables cell callback again
    h.FitTab.Table.CellEditCallback={@Update_FitTable,3};
end
if h.SettingsTab.FixStaticToDynamicSpecies.Value == 1 %%% Link distances of static and dynamic species
    %%% Disables cell callbacks, to prohibit double callback
    h.FitTab.Table.CellEditCallback=[];
    %%% Get Table Data
    Data = h.FitTab.Table.Data;
    %%% link distances and width of static to dynamic species
    for i = 1:(size(Data,1)-2)
        %%% Fix distances and width of static species
        Data(i,[24,27,33,36]) = deal({true});
        %%% set to values of dynamic species
        Data(i,[23,26,32,35]) = Data(i,[5,8,14,17]);
    end
    %%% Set Table Data
    h.FitTab.Table.Data = Data;
    %%% Enables cell callback again
    h.FitTab.Table.CellEditCallback={@Update_FitTable,3};
end

if obj == h.FitTab.Table
    drawnow;
    %%% reset scrollbar position
    h.jobj.FitTable_JScrollPane.getVerticalScrollBar.setValue(pos_y);
    h.jobj.FitTable_JScrollPane.getHorizontalScrollBar.setValue(pos_x);
end
% Update the Parameters Tab
function Update_ParamTable(~,e,mode)
h = guidata(findobj('Tag','GlobalPDAFit'));
global PDAMeta PDAData
switch mode
    case 0 %%% Updates whole table - when calling GlobalPDAFit
        %%% Disables cell callbacks, to prohibit double callback
        h.ParametersTab.Table.CellEditCallback=[];
        %%% Column names & widths
        Columns=cell(6,1);
        Columns{1}='Gamma';
        Columns{2}='Direct Exc';
        Columns{3}='Crosstalk';
        Columns{4}='BGD [kHz]';
        Columns{5}='BGA [kHz]';
        Columns{6}='R0 [A]';
        Columns{7}='Bin [ms]';
        ColumnWidth=zeros(numel(Columns),1);
        ColumnWidth(:) = 80;
        h.ParametersTab.Table.ColumnName=Columns;
        h.ParametersTab.Table.ColumnWidth=num2cell(ColumnWidth');
        %%% Sets row names to file names
        %Rows=cell(numel(PDAData.Data)+1,1);
        Rows = cell(1);
        %Rows(1:numel(PDAData.Data))=deal(PDAData.FileName);
        Rows{1}='ALL';
        h.ParametersTab.Table.RowName=Rows;
        %%% Create table data:
        % fill in the all row
        tmp = [1; 0; 0.02; 0; 0; 50; 1];
        Data=deal(num2cell(tmp)');
        Data{end} = [];
        %Data=cellfun(@num2str,Data,'UniformOutput',false);
        h.ParametersTab.Table.Data=Data;
        h.ParametersTab.Table.ColumnEditable = [true(1,numel(Columns)-1), false];
    case 1 %%% Updates tables when new data is loaded
        h.ParametersTab.Table.CellEditCallback=[];
        %%% Sets row names to file names
        Rows=cell(numel(PDAData.Data)+1,1);
        tmp = PDAData.FileName;
        %%% Cuts the filename up if too long
        for i = 1:numel(tmp)
           try 
               tmp{i} = [tmp{i}(1:10) '...' tmp{i}(end-10:end)];
           end
        end
        Rows(1:numel(tmp))=deal(tmp);
        Rows{end}='ALL';
        h.ParametersTab.Table.RowName=Rows;
        Data = cell(numel(Rows),size(h.ParametersTab.Table.Data,2));
        %%% Sets previous files
        Data(1:(size(h.ParametersTab.Table.Data,1)-1),:) = h.ParametersTab.Table.Data(1:end-1,:);
        %%% Set last row to ALL
        Data(end,:) = h.ParametersTab.Table.Data(end,:);
        %%% Add parameters of new files in between old data and ALL row
        tmp = zeros(numel(PDAData.FileName),7);
        for i = 1:numel(PDAData.FileName)
            tmp(i,1) = PDAData.Corrections{i}.Gamma_GR;
            % direct excitation correction in Burst analysis is NOT the
            % same as PDA, therefore we put it to zero. In PDA, this factor
            % is either the extcoeffA/(extcoeffA+extcoeffD) at donor laser,
            % or the ratio of Int(A)/(Int(A)+Int(D)) for a crosstalk, gamma
            % corrected double labeled molecule having no FRET at all.
            if isfield(PDAData.Corrections{i},'DirectExcitationProb')
                tmp(i,2) = PDAData.Corrections{i}.DirectExcitationProb;
            else
                tmp(i,2) = 0; %PDAData.Corrections{i}.DirectExcitation_GR;
            end
            tmp(i,3) = PDAData.Corrections{i}.CrossTalk_GR;
            tmp(i,4) = PDAData.Background{i}.Background_GGpar + PDAData.Background{i}.Background_GGperp;
            tmp(i,5) = PDAData.Background{i}.Background_GRpar + PDAData.Background{i}.Background_GRperp;
            tmp(i,6) = PDAData.Corrections{i}.FoersterRadius;
            tmp(i,7) = PDAData.timebin(i)*1000;
        end
        Data(size(h.ParametersTab.Table.Data,1):(end-1),:) = num2cell(tmp(size(h.ParametersTab.Table.Data,1):end,:));
        % put the ALL row to the mean of the loaded data 
        Data(end,1:end-1) = num2cell(mean(cell2mat(Data(1:end-1,1:end-1)),1));
        %%% Adds new files
        h.ParametersTab.Table.Data = Data;
        PDAMeta.PreparationDone = zeros(numel(PDAData.Data),1);
        PDAMeta.Params = cellfun(@str2double,h.FitTab.Table.Data(end-2,2:3:end));
    case 2 %%% Loading params again from data
        h.ParametersTab.Table.CellEditCallback=[];
        for i = 1:numel(PDAData.FileName)
            tmp(i,1) = PDAData.Corrections{i}.Gamma_GR;
            if ~isfield(PDAData.Corrections{i},'DirectExcitationProb') % value was not yet set in PDA
                tmp(i,2) = 0; %see above for explanation! PDAData.Corrections{i}.DirectExcitation_GR;
            else
                tmp(i,2) = PDAData.Corrections{i}.DirectExcitationProb;
            end
            tmp(i,3) = PDAData.Corrections{i}.CrossTalk_GR;
            tmp(i,4) = PDAData.Background{i}.Background_GGpar + PDAData.Background{i}.Background_GGperp;
            tmp(i,5) = PDAData.Background{i}.Background_GRpar + PDAData.Background{i}.Background_GRperp;
            tmp(i,6) = PDAData.Corrections{i}.FoersterRadius;
            tmp(i,7) = PDAData.timebin(i)*1000;
        end
        h.ParametersTab.Table.Data(1:end-1,:) = num2cell(tmp);
        PDAMeta.PreparationDone = zeros(numel(PDAData.FileName),1);
    case 3 %%% Individual cells callbacks
        %%% Disables cell callbacks, to prohibit double callback
        % Since R2018a touching an ALL value cell does not apply that
        % value everywhere
        
        h.ParametersTab.Table.CellEditCallback=[];
        if strcmp(e.EventName,'CellSelection') %%% No change in Value, only selected                                                                                            
            h.ParametersTab.Table.CellEditCallback={@Update_ParamTable,3};
            return;
        end

        NewData = h.ParametersTab.Table.Data{e.Indices(1),e.Indices(2)};
        if isprop(e,'NewData')
            if e.Indices(2) ~= 7
                NewData = e.NewData;
            else
                NewData = e.PreviousData; %used in the all row
                h.ParametersTab.Table.Data{e.Indices(1),e.Indices(2)} = e.PreviousData; % the bin column was touched
            end
        end
        if e.Indices(1)==size(h.ParametersTab.Table.Data,1)
            if e.Indices(2) ~= 7 % do not do for the Bin column
                %% ALL row was used => Applies to all files
                h.ParametersTab.Table.Data(:,e.Indices(2))=deal({NewData});
            end
            PDAMeta.PreparationDone(:) = 0;
        else
            PDAMeta.PreparationDone(e.Indices(1)) = 0;
        end
        
        
        %%% Values were changed, store this in PDAData structure so it is
        %%% saved with the files
        Data = h.ParametersTab.Table.Data;
        for i = 1:numel(PDAData.Corrections)
            PDAData.Corrections{i}.Gamma_GR = Data{i,1};
            PDAData.Corrections{i}.DirectExcitationProb = Data{i,2};
            PDAData.Corrections{i}.CrossTalk_GR = Data{i,3};
            % left out background countrates here because they should
            % barely ever change
            PDAData.Corrections{i}.FoersterRadius = Data{i,6};
        end
end

%%% Enables cell callback again
h.ParametersTab.Table.CellEditCallback={@Update_ParamTable,3};

% Function that generates random data when there is nothing to show
function SampleData
global PDAMeta
h = guidata(findobj('Tag','GlobalPDAFit'));

% generate data
% main plot
x = linspace(0,1,51);
y{1} = abs(sum(peaks(51),1));
f{1} = y{1}.*(1 + 0.15*randn(1,51));
r{1} = (y{1}-f{1})./sqrt(y{1});
y{2} = y{1}(end:-1:1);
f{2} = f{1}(end:-1:1);
r{2} = r{1}(end:-1:1);

color = lines(5);
% results plot
gauss_dummy{1} = zeros(5,150*10+1);
for i = 1:5
    gauss_dummy{1}(i,:) = normpdf(0:0.1:150,40+10*i,i);
end

for i = 1:5
    gauss_dummy{2}(i,:) = gauss_dummy{1}(i,end:-1:1);
end
% BSD plot
expon{1} = exp(-(0:200)/50)*1000;
expon{2} = exp(-(0:200)/100)*1000;

% fill plots
PDAMeta.Plots.Data_Single = bar(h.SingleTab.Main_Axes,...
    x,...
    y{1},...
    'EdgeColor','none',...
    'FaceColor',[0.4 0.4 0.4],...
    'BarWidth',1);
PDAMeta.Plots.Res_Single = bar(h.SingleTab.Res_Axes,...
    x,...
    r{1},...
    'FaceColor','none',...
    'EdgeColor',[0 0 0],...
    'BarWidth',1,...
    'LineWidth',2);
PDAMeta.Plots.Fit_Single = bar(h.SingleTab.Main_Axes,...
    x,f{1},...
    'EdgeColor',[0 0 0],...
    'FaceColor','none',...
    'BarWidth',1,...
    'LineWidth',2);
PDAMeta.Plots.BSD_Single = plot(h.SingleTab.BSD_Axes,...
    0:200,...
    expon{1},...
    'Color','k',...
    'LineWidth',2);
PDAMeta.Plots.PF_Deconvolved_Single = plot(h.SingleTab.BSD_Axes,...
    0:200,...
    expon{1},...
    'Color','k',...
    'LineWidth',2,...
    'LineStyle','--',...
    'Visible','off');
axis('tight');
PDAMeta.Plots.ES_Single = plot(h.SingleTab.ES_Axes,...
    0,...
    0,...
    'Color','k',...
    'LineStyle','none',...
    'Marker','.');
axis('tight');
PDAMeta.Plots.Gauss_Single{1} = plot(h.SingleTab.Gauss_Axes,...
    0:0.1:150,...
    sum(gauss_dummy{1},1),...
    'Color','k',...
    'LineWidth',2);
axis('tight');
for i = 2:6
    PDAMeta.Plots.Gauss_Single{i} = plot(h.SingleTab.Gauss_Axes,...
        0:0.1:150,...
        gauss_dummy{1}(i-1,:),...
        'Color',color(i-1,:),...
        'LineWidth',2,...
        'LineStyle', '-');
end
xlim(h.SingleTab.Gauss_Axes,[40 120]);

x = x-mean(diff(x))/2; %to make the stairs graph appear similar to the bar graph

%All Data
hold on
for i = 1:2
    PDAMeta.Plots.Data_All = cell(2,1);
    PDAMeta.Plots.Res_All = cell(2,1);
    PDAMeta.Plots.Fit_All = cell(2,1);
    PDAMeta.Plots.Data_All{i} = stairs(h.AllTab.Main_Axes,...
        x, y{i},...
        'Color',(3.*color(i,:)+1)./4,...
        'LineWidth', 1);
    PDAMeta.Plots.Res_All{i} = stairs(h.AllTab.Res_Axes,...
        x, r{i},...
        'Color',color(i,:),...
        'LineWidth', 1);
    PDAMeta.Plots.Fit_All{i} = stairs(h.AllTab.Main_Axes,...
        x, f{i},...
        'Color',color(i,:),...
        'LineWidth', 2,...
        'LineStyle', '--');
end
for i = 1:2
    PDAMeta.Plots.BSD_All{i} = plot(h.AllTab.BSD_Axes,...
        0:200,...
        expon{i},...
        'Color',color(i,:),...
        'LineWidth',2);
    axis('tight');
    PDAMeta.Plots.ES_All{i} = plot(h.AllTab.ES_Axes,...
    0,...
    0,...
    'Color','k',...
    'LineStyle','none',...
    'Marker','.');
end
for i = 1:2
    c = color(i,:);
    PDAMeta.Plots.Gauss_All{i,1} = plot(h.AllTab.Gauss_Axes,...
        0:0.1:150,...
        sum(gauss_dummy{i},1),...
        'Color',color(i,:),...
        'LineWidth',2);
    for j = 2:6
        c = (3.*c + 1)./4;
        PDAMeta.Plots.Gauss_All{i,j} = plot(h.AllTab.Gauss_Axes,...
            0:0.1:150,...
            gauss_dummy{i}(j-1,:),...
            'Color',c,...
            'LineWidth',2);
    end
    
end
axis('tight');
xlim(h.AllTab.Gauss_Axes,[40 120]);

% Info menu - To do list
function Todolist(~,~)
msgbox({...
    'allow to set Epr limits for plotting and analysis';...
    'remove everything from global that is not needed in global';...
    'add a legend in the plots';...
    'sigma cannot be zero or a very small number';...
    'possibility to plot the actual E instead of Epr';...
    'brightness corrected PDA';...
    'put the optimplotfval into the gauss plot, so fitting can be evaluated per iteration, rather than per function sampling';...
    'fix the ignore outer limits for MLE fitting';...
    '';...
    '';...
    ''} ,'To do list','modal');

% Info menu - Manual callback
function Manual(~,~)
if ismac
    inp = '/Global PDA Fitting.docx';
    %MACOPEN Open a file or directory using the OPEN terminal utility on the MAC.
    %   MACOPEN FILENAME opens the file or directory FILENAME using the
    %   the OPEN terminal command.
    %
    %   Examples:
    %
    %     If you have Microsoft Word installed, then
    %     macopen('/myDoc.docx')
    %     opens that file in Microsoft Word if the file exists, and errors if
    %     it doesn't.
    %
    %     macopen('/Applications')
    %     opens a new Finder window, showing the contents of your /Applications
    %     folder.
    %
    %   See also WINOPEN, OPEN, DOS, WEB.
    
    % Copyright 2012 - 2013 The MathWorks, Inc.
    % Written: 16-Apr-2012, Varun Gandhi
    if strcmpi('.',inp)
        inp = pwd;
    end
    syscmd = ['open ', inp, ' &'];
    %disp(['Running the following in the Terminal: "', syscmd,'"']);
    system(syscmd);
else
    winopen('Global PDA Fitting.docx')
end

% Database management
function Database(~,e,mode)
global UserValues PDAData
LSUserValues(0);
h = guidata(findobj('Tag','GlobalPDAFit'));

if mode == 0
    switch e.Key
        case 'delete'
            mode = 1;
    end
end

switch mode
    case 1 
        %% Delete files from database
        %remove rows from list
        h.PDADatabase.List.String(h.PDADatabase.List.Value) = [];
        %remove data from PDAData
        PDAData.FileName(h.PDADatabase.List.Value) = [];
        PDAData.PathName(h.PDADatabase.List.Value) = [];
        PDAData.Data(h.PDADatabase.List.Value) = [];
        PDAData.timebin(h.PDADatabase.List.Value) = [];
        PDAData.Corrections(h.PDADatabase.List.Value) = [];
        PDAData.Background(h.PDADatabase.List.Value) = [];
        PDAData.FitTable(h.PDADatabase.List.Value) = [];
        PDAData.OriginalFitParams = PDAData.FitTable;
        h.FitTab.Table.RowName(h.PDADatabase.List.Value)=[];
        h.FitTab.Table.Data(h.PDADatabase.List.Value,:)=[];
        h.ParametersTab.Table.RowName(h.PDADatabase.List.Value)=[];
        h.ParametersTab.Table.Data(h.PDADatabase.List.Value,:)=[];
        
        h.PDADatabase.List.Value = 1;
        if size(h.PDADatabase.List.String, 1) < 1
            % no files are left
            h.PDADatabase.Save.Enable = 'off';
            SampleData
        else
            Update_FitTable([],[],1);
            Update_ParamTable([],[],1);
            Update_Plots([],[],3);
        end
    case 2 
        %% Load database
        [FileName, Path] = uigetfile({'*.pab', 'PDA Database file (*.pab)'}, 'Choose PDA database to load',UserValues.File.PDAPath,'MultiSelect', 'off');
        load('-mat',fullfile(Path,FileName));
        if FileName ~= 0
            PDAData.FileName = s.file;
            PDAData.PathName = s.path;
            Load_PDA([],[],3);
            %h.PDADatabase.List.String = s.str;
            clear s;
            if size(h.PDADatabase.List.String, 1) > 0
                % files are left
                h.PDADatabase.Save.Enable = 'on';
            else
                SampleData
            end
        end
    case 3 
        %% Save complete database
        [File, Path] = uiputfile({'*.pab', 'PDA Database file (*.pab)'}, 'Save PDA database', UserValues.File.PDAPath);
        s = struct;
        s.file = PDAData.FileName;
        s.path = PDAData.PathName;
        %s.str = h.PDADatabase.List.String;
        save(fullfile(Path,File),'s');
        UserValues.File.PDAPath = Path;
end

% Updates GUI elements
function Update_GUI(obj,~)
global UserValues
h = guidata(obj);

if obj == h.SettingsTab.FixSigmaAtFractionOfR
    switch obj.Value
        case 1
            %%% Enable Check Box
            h.SettingsTab.SigmaAtFractionOfR_edit.Enable = 'on';
            h.SettingsTab.FixSigmaAtFractionOfR_Fix.Enable = 'on';
            %%% Update FitParameter Table (fix all sigmas, set to value
            %%% according to number in edit box)
            Update_FitTable([],[],4);
            %%% Disable Columns
            h.FitTab.Table.ColumnEditable(8:9:end) = deal(false);
            h.FitTab.Table.ColumnEditable(9:9:end) = deal(false);
            h.FitTab.Table.ColumnEditable(10:9:end) = deal(false);
        case 0
            h.SettingsTab.SigmaAtFractionOfR_edit.Enable = 'off';
            h.SettingsTab.FixSigmaAtFractionOfR_Fix.Enable = 'off';
            %%% Reset the fixed status of the fit table
            Data = h.FitTab.Table.Data;
            for i = 1:(size(Data,1)-2)
                %%% Un-Fix all sigmas
                Data(i,9:9:end) = deal({false});
            end
            h.FitTab.Table.Data = Data;
            %%% Reenable Columns
            h.FitTab.Table.ColumnEditable(8:9:end) = deal(true);
            h.FitTab.Table.ColumnEditable(9:9:end) = deal(true);
            h.FitTab.Table.ColumnEditable(10:9:end) = deal(true);
    end
    h.SettingsTab.SigmaAtFractionOfR_edit.ForegroundColor = [0,0,0];
    h.SettingsTab.SigmaAtFractionOfR_edit.BackgroundColor = [1,1,1];
    drawnow;
    UserValues.PDA.FixSigmaAtFraction = obj.Value;
elseif obj == h.SettingsTab.FixStaticToDynamicSpecies
    %%% Toggle fixing dynamic species distances to static species
    switch obj.Value
        case 1
            %%% Update FitParameter Table (fix all sigmas, set to value
            %%% according to number in edit box)
            Update_FitTable([],[],4);
            %%% Disable Columns
            %%% 2 state system, i.e. distances and sigma of the first two
            %%% static species need to be uneditable
            h.FitTab.Table.ColumnEditable(23:28) = deal(false);
            h.FitTab.Table.ColumnEditable(32:37) = deal(false);
        case 0
            %%% Reset the fixed status of the fit table
            % Data = h.FitTab.Table.Data;
            % for i = 1:(size(Data,1)-2)
            %     %%% Un-Fix all Distances and Sigmas
            %      Data(i,[24,27,33,36]) = deal({false});
            % end
            % h.FitTab.Table.Data = Data;
            %%% Reenable Columns
            h.FitTab.Table.ColumnEditable(23:28) = deal(true);
            h.FitTab.Table.ColumnEditable(32:37) = deal(true);
    end
    h.SettingsTab.SigmaAtFractionOfR_edit.ForegroundColor = [0,0,0];
    h.SettingsTab.SigmaAtFractionOfR_edit.BackgroundColor = [1,1,1];
    drawnow;
    UserValues.PDA.FixStaticToDynamicSpecies = obj.Value;
elseif obj == h.SettingsTab.DynamicModel || obj == h.SettingsTab.DynamicSystem
    switch h.SettingsTab.DynamicModel.Value
        case 1 %%% switched to dynamic            
                % two state sytem
                %%% Change label of Fit Parameter Table
                h.FitTab.Table.ColumnName{2} = '<HTML><b>k<sub>12</sub> [ms<sup>-1</sup>]</b>';
                h.FitTab.Table.ColumnName{11} = '<HTML><b>k<sub>21</sub> [ms<sup>-1</sup>]</b>';
                h.FitTab.Table.ColumnName{20} = '<HTML><b>A<sub>3</sub></b>';
                h.FitTab.Table.ColumnWidth{2} = 70;
                h.FitTab.Table.ColumnWidth{11} = 70;
                h.FitTab.Table.Position(3) = 1;
                h.KineticRates_table.Visible = 'off';
                h.FitTab.Table.ColumnEditable([2,3,4,11,12,13,20,21,22]) = deal(true);
                if h.SettingsTab.DynamicSystem.Value == 2 %%% three-state model
                    h.FitTab.Table.ColumnName{2} = '<HTML><b>F<sub>1</sub></b>';
                    h.FitTab.Table.ColumnName{11} = '<HTML><b>F<sub>2</sub></b>';
                    h.FitTab.Table.ColumnName{20} = '<HTML><b>F<sub>3</sub></b>';
                    h.FitTab.Table.ColumnWidth{20} = 40;
                    h.FitTab.Table.ColumnWidth{2} = 40;
                    h.FitTab.Table.ColumnWidth{11} = 40;
                    %%% disable columns for amplitudes of species 1,2 and 3
                    %%% use rate table instead
                    %%% Rates are always global, so disable global checkbox
                    %%% and global to false
                    h.FitTab.Table.ColumnEditable([2,3,4,11,12,13,20,21,22]) = deal(false);
                    h.FitTab.Table.Data(1:end-2,[4,13,22]) = deal({false});
                    %%% unfix third amplitude and set to one
                    h.FitTab.Table.Data(1:end-2,20) = deal({'1'});
                    h.FitTab.Table.Data(1:end-2,21) = deal({false});
                    %%% unhide rate table
                    h.KineticRates_table.Visible = 'on';
                    %%% change fit table width
                    h.FitTab.Table.Position(3) = 0.69;
                    %%% disable linking of distances between static and dynamic
                    h.SettingsTab.FixStaticToDynamicSpecies.Value = 0;
                    h.SettingsTab.FixStaticToDynamicSpecies.Enable = 'off';
                else
                    %%% enable linking of distances between static and dynamic
                    h.SettingsTab.FixStaticToDynamicSpecies.Enable = 'on';
                end                
        case 0 %%% switched back to static
            %%% Revert Label of Fit Parameter Table
            h.FitTab.Table.ColumnName{2} = '<HTML><b>A<sub>1</sub></b>';
            h.FitTab.Table.ColumnName{11} = '<HTML><b>A<sub>2</sub></b>';
            h.FitTab.Table.ColumnName{20} = '<HTML><b>A<sub>3</sub></b>';
            h.FitTab.Table.ColumnWidth{2} = 40;
            h.FitTab.Table.ColumnWidth{11} = 40;
            h.FitTab.Table.ColumnWidth{20} = 40;
            %%% re-enable columns for amplitudes of species 1,2 and 3 (used
            %%% for rates when dynamic model is seleceted)
            h.FitTab.Table.ColumnEditable([2,3,4,11,12,13,20,21,22]) = deal(true);
            %%% change fit table width
            h.FitTab.Table.Position(3) = 1;
             %%% hide rate table
            h.KineticRates_table.Visible = 'off';
            %%% disable linking of static and dynamic species
            h.SettingsTab.FixStaticToDynamicSpecies.Value = 0;
            h.SettingsTab.FixStaticToDynamicSpecies.Enable = 'off';
    end
    UserValues.PDA.DynamicSystem = h.SettingsTab.DynamicSystem.Value;
end
if obj == h.KineticRates_table
%   %%% Update the fields in the fit table for k12, k21 and k31 (value + fixed state)
%    h.FitTab.Table.Data(1:end-2,2) = deal({num2str(h.KineticRates_table.Data{2,1})});
%    h.FitTab.Table.Data(1:end-2,3) = deal({h.KineticRates_table.Data{2,2}});
%    h.FitTab.Table.Data(1:end-2,11) = deal({num2str(h.KineticRates_table.Data{1,3})});
%    h.FitTab.Table.Data(1:end-2,12) = deal({h.KineticRates_table.Data{1,4}});
%    h.FitTab.Table.Data(1:end-2,20) = deal({num2str(h.KineticRates_table.Data{1,5})});
%    h.FitTab.Table.Data(1:end-2,21) = deal({h.KineticRates_table.Data{1,6}});
%    %%% if diagonal elements were clicked, reset them to NaN to indicate
%    %%% that they are not used
%    h.KineticRates_table.Data(1,1) = {NaN};
%    h.KineticRates_table.Data(2,3) = {NaN};
%    h.KineticRates_table.Data(3,5) = {NaN};
%    %%% reset fixed to false for diagonal as well
%    h.KineticRates_table.Data(1,2) = {false};
%    h.KineticRates_table.Data(2,4) = {false};
%    h.KineticRates_table.Data(3,6) = {false};
end
% function for loading of brightness reference, i.e. donor only sample
function Load_Brightness_Reference(obj,~,mode)
global PDAData UserValues PDAMeta

load_file = 0;
if ~isempty(PDAData)
    switch mode
        case 1
            if obj.Value == 1
                if isempty(PDAData.BrightnessReference)
                    load_file = 1;
                end
                PDAMeta.Plots.BSD_Reference.Visible = 'on';
            else
                PDAMeta.Plots.BSD_Reference.Visible = 'off';
            end
        case 2
            load_file = 1;
    end
end         
            
if load_file
    %%% Load data
    [FileName,p] = uigetfile({'*.pda','*.pda file'},'Select *.pda file containing a Donor only measurement',...
        UserValues.File.PDAPath,'Multiselect','off');
    
    if all(FileName==0)
        return
    end
    
    load(fullfile(p,FileName),'-mat');
    PDAData.BrightnessReference.N = PDA.NG;
    PDAData.BrightnessReference.PN = histcounts(PDAData.BrightnessReference.N,1:(max(PDAData.BrightnessReference.N)+1));
    
    %%% Update Plot
    PDAMeta.Plots.BSD_Reference.XData = 1:max(PDAData.BrightnessReference.N);
    PDAMeta.Plots.BSD_Reference.YData = PDAData.BrightnessReference.PN;
end

%%% Scale Photon Count Distribution to lower brightness (linear scaling,
%%% approximately correct)
function [ PN_scaled ] = scalePN(PN, scale_factor)
PN_scaled = interp1(scale_factor*[1:1:numel(PN)],PN,[1:1:numel(PN)]);
PN_scaled(isnan(PN_scaled)) = 0;

%%% Calculate the relative brightness based on FRET value
function Qr = calc_relative_brightness(R,file)
global PDAMeta
de = PDAMeta.directexc(file);
ct = PDAMeta.crosstalk(file);
gamma = PDAMeta.gamma(file);
E = 1/(1+(R/PDAMeta.R0(file)).^6);
Qr = (1-de)*(1-E) + (gamma/(1+ct))*(de+E*(1-de));

%%% Re-calculate the P array based on changed PN (brightness correction)
function P = recalculate_P(PN_scaled,file, Nobins, NobinsE)
global PDAMeta

PN  = PN_scaled';
P = cell(1,NobinsE);
if PDAMeta.NBG{file} == 0 && PDAMeta.NBR{file} == 0
    for j = 1:NobinsE+1
        PN_trans = repmat(PN,1,PDAMeta.maxN{file}+1);
        PN_trans = PN_trans(:);
        PN_trans = PN_trans(PDAMeta.HistLib.valid{file}{j});
        P{1,j} = accumarray(PDAMeta.HistLib.bin{file}{j},PDAMeta.HistLib.P_array{file}{j}.*PN_trans);
    end
else
    for j = 1:NobinsE+1
        P{1,j} = zeros(Nobins,1);
        count = 1;
        for g = 0:PDAMeta.NBG{file}
            for r = 0:PDAMeta.NBR{file}
                PN_trans = repmat(PN(1+g+r:end),1,PDAMeta.maxN{file}+1);%the total number of fluorescence photons is reduced
                PN_trans = PN_trans(:);
                PN_trans = PN_trans(PDAMeta.HistLib.valid{file}{j}{count});
                %%% Now uses C-code
                P{1,j} = P{1,j} + accumarray_c(PDAMeta.HistLib.bin{file}{j}{count},PDAMeta.HistLib.P_array{file}{j}{count}.*PN_trans,max(PDAMeta.HistLib.bin{file}{j}{count}),numel(PDAMeta.HistLib.bin{file}{j}{count}))';
                % P{1,j} = P{1,j} + accumarray(PDAMeta.HistLib.bin{file}{j}{count},PDAMeta.HistLib.P_array{file}{j}{count}.*PN_trans);
                count = count+1;
            end
        end
    end
end
        
function PofT = calc_dynamic_distribution(dT,N,k1,k2)
%%% Calculates probability distribution of dynamic mixing of states for
%%% two-state kinetic scheme
%%% Inputs:
%%% dT  -   Bin time
%%% N   -   Number of time steps to compute
%%% k1  -   Rate from state 1 to state 2
%%% k2  -   Rate from state 2 to state 1

% Split in N+1 time bins
PofT = zeros(1,N+1);
dt = dT/N;

%%% catch special case where k1 = k2 = 0
if (k1 == 0) && (k2 == 0)
    %%% No dynamics, i.e. equal weights
    PofT(1) = 0.5;
    PofT(end) = 0.5;
    return;
end
%%% first and last bin are special cases
PofT(1) = k1/(k1+k2)*exp(-k2*dT) + calcPofT(k1,k2,dt/2,dT-dt/2,dt/2);
PofT(end) = k2/(k1+k2)*exp(-k1*dT) + calcPofT(k1,k2,dT-dt/2,dt/2,dt/2);

%%% rest is determined by formula (2d) in paper giving P(i*dt-dt/2 < T < i*dt+dt/2)
for i = 1:N-1
    T1 = i*dt;
    T2 = dT-T1;
    PofT(i+1) = calcPofT(k1,k2,T1,T2,dt); 
end
PofT = PofT./sum(PofT);


function PofT = calcPofT(k1,k2,T1,T2,dt)
%%% calculates probability for cumulative time spent in state 1(T1) to lie
%%% in range T1-dt, T1+dt based on formula from Seidel paper
%%% besseli is the MODIFIED bessel function of first kind
PofT = (...
       (2*k1*k2/(k1+k2))*besseli(0,2*sqrt(k1*k2*T1*T2)) + ...
       ((k2*T1+k1*T2)/(k1+k2))*(sqrt(k1*k2)/sqrt(T1*T2))*...
       besseli(1,2*sqrt(k1*k2*T1*T2)) ...
       ) * exp(-k1*T1-k2*T2)*dt;
     
function PofF = deconvolute_PofF(S,bg,resolution)
%%% deconvolutes input PofF using a sum of Poisson distributios as kernel
%%% to obtain background-free fluorescence signal distribution PofF
%%%
%%% See: Kalinin, S., Felekyan, S., Antonik, M. & Seidel, C. A. M. Probability Distribution Analysis of Single-Molecule Fluorescence Anisotropy and Resonance Energy Transfer. J. Phys. Chem. B 111, 10253?10262 (2007).

%%% Input parameter:
%%% S   -   the experimentally observed burst sizes
%%% bg  -   the total background
%%% resolution - resolution for brightness vector

if nargin < 3
    resolution = 200;
end
%%% Construct the histogram PF
xS = 0:1:max(S)+1;
PS= histcounts(S,xS);
xS = xS(1:end-1);
%%% vector of brightnesses to consider
b = linspace(0,max(S),resolution);

%%% Establish Poisson library based on brightness vector INCLUDING background
%%% convolution of model PofF with Poissonian background simplifies to
%%% using a modified brightness b' = b + bg
%%% This follows because the convolution of two Poissonian distributions
%%% equals again a Poissonian with sum of rate parameters.
%%% see equation 12 of reference
PS_ind = poisspdf(repmat(xS,numel(b),1),repmat(bg+b',1,numel(xS)));

%%% Calculate error estimate based on poissonian counting statistics
error = sqrt(PS); error(error == 0) = 1;

%%% equation 12 of reference to calculate PofS from library
% sum(PS_ind.*repmat(p,1,numel(xS),1)) = P(S)
%%% scaling parameter for the entropy term
v = 10;
mem = @(p) -(v*sum(p-p.*log(p)) - sum( (PS-sum(PS_ind.*repmat(p,1,numel(xS),1)).*numel(S)).^2./error.^2)./(numel(PS)));
%%% initialize p
p0 = ones(numel(b),1)./numel(b);
p=p0;

%%% initialize boundaries
Aieq = -eye(numel(p0)); bieq = zeros(numel(p0),1);
lb = zeros(numel(p0),1); ub = inf(numel(p0),1);

%%% specify fit options
opts = optimoptions(@fmincon,'MaxFunEvals',1E5,'Display','iter','TolFun',1E-4);
p = fmincon(mem,p,Aieq,bieq,[],[],lb,ub,@nonlcon,opts); 

%%% construct distribution PofF from distribution over brightnesses
%%% this time, we exculde background to obtain the "purified" fluorescence
%%% count distribution
PF_ind = poisspdf(repmat(xS,numel(b),1),repmat(b',1,numel(xS)));
PofF = sum(PF_ind.*repmat(p,1,numel(xS),1));
PofF = PofF./sum(PofF);

function [c,ceq] = nonlcon(x)
%%% nonlinear constraint for deconvolution
c = [];
ceq = sum(x) - 1;

function Files = GetMultipleFiles(FilterSpec,Title,PathName)
FileName = 1;
count = 0;
Files = [];
while FileName ~= 0
    [FileName,PathName] = uigetfile(FilterSpec,Title, PathName, 'MultiSelect', 'on');
    if ~iscell(FileName)
        if FileName ~= 0
            count = count+1;
            Files{count,1} = FileName;
            Files{count,2} = PathName;
        end
    elseif iscell(FileName)
        for i = 1:numel(FileName)
            if FileName{i} ~= 0
                count = count+1;
                Files{count,1} = FileName{i};
                Files{count,2} = PathName;
            end
        end
        FileName = FileName{end};
    end
    PathName= fullfile(PathName,'..',filesep);%%% go one layer above since .*pda files are nested
end

function PDAFitMenuCallback(~,~,mode)
h = guidata(findobj('Tag','GlobalPDAFit'));
global PDAData UserValues 
switch mode
    case 1 %%% Exports Fit Result to Clipboard
        PDAFitResult = cell(numel(PDAData.FileName),1);
        active = cell2mat(h.FitTab.Table.Data(1:end-3,1));
        Params = str2double(h.FitTab.Table.Data(1:end-3,2:3:end));
        ParamNames = [h.FitTab.Table.ColumnName(1);h.FitTab.Table.ColumnName(2:3:end,1)];
        for i = 1:numel(PDAData.FileName)
            if active(i)
                PDAFitResult{i} = cell(size(Params,1),1);
                PDAFitResult{i}{1} = PDAData.FileName{i};
                for j=2:size(Params,2)+1
                    PDAFitResult{i}{j} = Params(i,j-1);
                end
            end
        end
        ParamNames = regexprep(ParamNames, '<.*?>', '' ); % remove html tags
        PDAFitResult = vertcat(ParamNames',horzcat(PDAFitResult{:})');
        Mat2clip(PDAFitResult);
    case 2 %%% Exports Fit Result to BVA Tab
        if h.SettingsTab.DynamicModel.Value == 1 & (h.SettingsTab.DynamicSystem.Value > 1) % three-state system
%             UserValues.BurstBrowser.Settings.KineticRates_table3 = h.KineticRates_table.Data(:,1:3:end);
            UserValues.BurstBrowser.Settings.KineticRates_table3(2:3,1) = h.KineticRates_table.Data(1,1:3:4);
            UserValues.BurstBrowser.Settings.KineticRates_table3(1:2:3,2) = h.KineticRates_table.Data(1,7:3:10);
            UserValues.BurstBrowser.Settings.KineticRates_table3(1:2,3) = h.KineticRates_table.Data(1,13:3:16);
        end
        active = cell2mat(h.FitTab.Table.Data(1:end-3,1));
        params = str2double(h.FitTab.Table.Data(1:end-3,2:3:end));
        if isempty(findobj('Tag','BurstBrowser'))
            msgbox('BurstBrowser is not open.', 'Error','error');
            return
        end
        hb = guidata(findobj('Tag','BurstBrowser'));
        
        switch UserValues.PDA.Dynamic
            case 0 % static
                for i = 1:numel(PDAData.FileName)
                    if active(i)
                        UserValues.BurstBrowser.Settings.BVA_amplitude1_static = params(i,1);
                        UserValues.BurstBrowser.Settings.BVA_amplitude2_static = params(i,4);
                        UserValues.BurstBrowser.Settings.BVA_amplitude3_static = params(i,7);
                        UserValues.BurstBrowser.Settings.BVA_R1_st = params(i,2);
                        UserValues.BurstBrowser.Settings.BVA_R2_st = params(i,5);
                        UserValues.BurstBrowser.Settings.BVA_R3_st = params(i,8);
                        UserValues.BurstBrowser.Settings.BVA_Rsigma1_st = params(i,3);
                        UserValues.BurstBrowser.Settings.BVA_Rsigma2_st = params(i,6);
                        UserValues.BurstBrowser.Settings.BVA_Rsigma3_st = params(i,9);
                        hb.state1st_amplitude_edit.String = num2str(params(i,1));
                        hb.Rstate1st_edit.String = num2str(params(i,2));
                        hb.Rsigma1st_edit.String = num2str(params(i,3));
                        hb.state2st_amplitude_edit.String = num2str(params(i,4));
                        hb.Rstate2st_edit.String = num2str(params(i,5));
                        hb.Rsigma2st_edit.String = num2str(params(i,6));
                        hb.state3st_amplitude_edit.String = num2str(params(i,7));
                        hb.Rstate3st_edit.String = num2str(params(i,8));
                        hb.Rsigma3st_edit.String = num2str(params(i,9));
                        break
                    end
                end
            case 1 % dynamic
                for i = 1:numel(PDAData.FileName)
                    if active(i)
                        UserValues.BurstBrowser.Settings.BVA_R1 = params(i,2);
                        UserValues.BurstBrowser.Settings.BVA_R2 = params(i,5);
                        UserValues.BurstBrowser.Settings.BVA_R3 = params(i,8);
                        UserValues.BurstBrowser.Settings.BVA_Rsigma1 = params(i,3);
                        UserValues.BurstBrowser.Settings.BVA_Rsigma2 = params(i,6);
                        UserValues.BurstBrowser.Settings.BVA_Rsigma3 = params(i,9);
                        hb.KineticRates_table2.Data(2,1) = num2cell(params(i,1));
                        hb.KineticRates_table2.Data(1,2) = num2cell(params(i,4));
                        hb.KineticRates_table3.Data(2:3,1) = h.KineticRates_table.Data(1,1:3:4);
                        hb.KineticRates_table3.Data(1:2:3,2) = h.KineticRates_table.Data(1,7:3:10);
                        hb.KineticRates_table3.Data(1:2,3) = h.KineticRates_table.Data(1,13:3:16);
                        hb.Rstate1_edit.String = num2str(params(i,2));
                        hb.Rsigma1_edit.String = num2str(params(i,3));
                        hb.Rstate2_edit.String = num2str(params(i,5));
                        hb.Rsigma2_edit.String = num2str(params(i,6));
                        hb.Rstate3_edit.String = num2str(params(i,8));
                        hb.Rsigma3_edit.String = num2str(params(i,9));
                        break
                    end
                end
        end
        UpdateBVATab(hb.ConsistencyAnalysis_Button,[],hb);
end

function [P_analytic, P_gillespie] = linear_three_state(k21,k12,k32,k23,T,res)
% returns the analytic and gillespie distribution of occupation times in
% states 1 and 3
% kij: rates from state i to state j in kHz=ms^(-1)
% T:   integration time in milliseconds
% res: resolution of the distribution (number of bins per dimension)

K = [-k21,  k12,        0;
      k21, -(k12+k32), k23;
      0,    k32,      -k23];
  
% determine equlibrium fractions
Keq = [K; 1,1,1];
b = [0;0;0;1];
% Keq*peq = b
peq = Keq\b;


%% compute analytic solution (Oleg's formula)
k = -diag(K);
mu = peq;

P = cell(2,2,2); % store the results
x1 = linspace(0,1,res);
x3 = linspace(0,1,res);
[x1g,x3g] = meshgrid(x1,x3);

% single species
P{2,1,1} = mu(1)*exp(-T*k(1));
P{1,2,1} = mu(2)*exp(-T*k(2));
P{1,1,2} = mu(3)*exp(-T*k(3));
% binary exchange
P{2,2,1} = mu(1)*mu(2)*exp(-T*(k(2)+(k(1)-k(2)).*x1));
P{1,2,2} = mu(2)*mu(3)*exp(-T*(k(2)+(k(3)-k(2)).*x3));
% ternary exchange
P{2,2,2} = prod(mu)*exp(-T*(k(2)+(k(1)-k(2)).*x1g + (k(3)-k(2)).*x3g));

% Hypergeometric function
xm12 = mu(2)+ (mu(1)-mu(2))*x1;
xm23 = mu(2);
xm   = mu(2) + (mu(1)-mu(2)*x1g + (mu(3)-mu(2))*x3g);
xm2  = mu(2)*(1-x1g-x3g);

a12 = T*(K(2,1)+K(1,2))/(mu(1)+mu(2));
a23 = T*(K(3,2)+K(2,3))/(mu(2)+mu(3));
xx12_2 = mu(1)*mu(2)*x1.*(1-x1);
xx23_2 = mu(2)*mu(3)*x3.*(1-x3);
xx12_3 = mu(1)*mu(2)*x1g.*(1-(x1g+x3g));
xx23_3 = mu(2)*mu(3)*(1-(x1g+x3g)).*x3g;

F12_2 = F01(a12,xx12_2);
F23_2 = F01(a23,xx23_2);

F12_3 = F01(a12,xx12_3);
F23_3 = F01(a23,xx23_3);

% put it all together
P{2,2,1} = P{2,2,1}.*(2*F12_2{1}+xm12.*F12_2{2});
P{1,2,2} = P{1,2,2}.*(2*F23_2{1}+xm23.*F23_2{2});
P{2,2,2} = P{2,2,2}.*(2*F12_3{1}.*F23_3{1} + ...
                     2*xm2.*(F12_3{1}.*F23_3{2}+F12_3{2}.*F23_3{1}) + ...
                     xm2.*xm.*F12_3{2}.*F23_3{2} ...
                     );
% exclude non-physical values
P{2,2,2}(x1g+x3g > 1) = 0;

% combine the contributions
P_analytic = P{2,2,2}./(res^2);
P_analytic(1,:) = P_analytic(1,:) + P{2,2,1}./res;
P_analytic(:,1) = P_analytic(:,1) + P{1,2,2}'./res;
P_analytic(1,1) = P_analytic(1,1) + P{1,2,1};
P_analytic(end,1) = P_analytic(end,1) + P{1,1,2};
P_analytic(1,end) = P_analytic(1,end) + P{2,1,1};
% normalize to 1 (due to binning artifacts)
P_analytic = P_analytic./sum(P_analytic(:));
%% Gillespie (for comparison)
if nargout > 1
    DynRates = K; DynRates(logical(eye(size(DynRates,1)))) = 0;
    change_prob = cumsum(DynRates);
    change_prob = change_prob ./ repmat(change_prob(end,:),3,1);
    dwell_mean = 1 ./ sum(DynRates);
    FracT = zeros(1E5,size(DynRates,1));
    FracT = Gillespie_inf_states(T,size(DynRates,1),dwell_mean,1E6,peq,change_prob)./T;
    % PofT describes the joint probability to see T1 and T2
    n_bins_T = res;
    PofT = histcounts2(FracT(:,3),FracT(:,1),linspace(0,1,n_bins_T+1),linspace(0,1,n_bins_T+1));
    P_gillespie = PofT./sum(PofT(:));
end

function vecF0_F1 = F01(a,xx)
% computes the product of an amplitude and the (regularized) hypergeometric function 0_F_1
z = a*a*xx;
vecF0_F1{1} = a*reg_hypergeo(1,z);
vecF0_F1{2} = a*a*reg_hypergeo(2,z);

function res = reg_hypergeo(nu,z)
% regularized hypergeometric function of degree nu of argument z
% evaluated based on modfified bessel function of first kind
nu = nu-1;
res = z.^(-nu/2).*besseli(nu,2*sqrt(z));

% treat edge cases
res(z==0) = 1;