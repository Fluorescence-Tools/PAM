function TauFit(~,~)
global UserValues TauFitData
h.TauFit = findobj('Tag','TauFit');
addpath([pwd filesep 'TauFit Models']);
if isempty(h.TauFit) % Creates new figure, if none exists
    %% Figure Generation
    %%% Load user profile
    LSUserValues(0);
    Look = UserValues.Look;
    %%% Generates the main figure
    h.TauFit = figure(...
        'Units','normalized',...
        'Tag','TauFit',...
        'Name','TauFit',...
        'NumberTitle','off',...
        'Menu','none',...
        'defaultUicontrolFontName',Look.Font,...
        'defaultAxesFontName',Look.Font,...
        'defaultTextFontName',Look.Font,...
        'defaultAxesYColor',Look.Fore,...
        'Toolbar','figure',...
        'UserData',[],...
        'BusyAction','cancel',...
        'OuterPosition',[0.01 0.1 0.68 0.8],...
        'CloseRequestFcn',@Close_TauFit,...
        'Visible','on');
    %%% Sets background of axes and other things
    whitebg(Look.Axes);
    %%% Changes background; must be called after whitebg
    h.TauFit.Color=Look.Back;
    %% Main Fluorescence Decay Plot
    %%% Panel containing decay plot and information
    h.TauFit_Panel = uibuttongroup(...
        'Parent',h.TauFit,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0.2 0.75 0.8],...
        'Tag','TauFit_Panel');
    
    %%% Right-click menu for plot changes
    h.Microtime_Plot_Menu_MIPlot = uicontextmenu;
    h.Microtime_Plot_ChangeYScaleMenu_MIPlot = uimenu(...
        h.Microtime_Plot_Menu_MIPlot,...
        'Label','Logscale',...
        'Tag','Plot_Logscale_MIPlot',...
        'Callback',@ChangeYScale);
    h.Microtime_Plot_Menu_ResultPlot = uicontextmenu;
    h.Microtime_Plot_ChangeYScaleMenu_ResultPlot = uimenu(...
        h.Microtime_Plot_Menu_ResultPlot,...
        'Label','Logscale',...
        'Tag','Plot_Logscale_ResultPlot',...
        'Callback',@ChangeYScale);
    h.Export_Result = uimenu(...
        h.Microtime_Plot_Menu_ResultPlot,...
        'Label','Export Plot',...
        'Tag','Export_Result',...
        'Callback',@ExportGraph);
    %%% Main Microtime Plot
    h.Microtime_Plot = axes(...
        'Parent',h.TauFit_Panel,...
        'Units','normalized',...
        'Position',[0.05 0.075 0.9 0.775],...
        'Tag','Microtime_Plot',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Box','on',...
        'UIContextMenu',h.Microtime_Plot_Menu_MIPlot);
    
    %%% Create Graphs
    hold on;
    h.Plots.Scatter_Par = plot([0 1],[0 0],'LineStyle',':','Color',[0.5 0.5 0.5]);
    h.Plots.Scatter_Per = plot([0 1],[0 0],'LineStyle',':','Color',[0.3 0.3 0.3]);
    h.Plots.Decay_Sum = plot([0 1],[0 0],'--k');
    h.Plots.Decay_Par = plot([0 1],[0 0],'--g');
    h.Plots.Decay_Per = plot([0 1],[0 0],'--r');
    h.Plots.IRF_Par = plot([0 1],[0 0],'.g');
    h.Plots.IRF_Per = plot([0 1],[0 0],'.r');
    h.Plots.FitPreview = plot([0 1],[0 0],'k');
    h.Ignore_Plot = plot([0 0],[0 1],'Color','k','Visible','off','LineWidth',2);
    h.Microtime_Plot.XLim = [0 1];
    h.Microtime_Plot.YLim = [0 1];
    h.Microtime_Plot.XLabel.Color = Look.Fore;
    h.Microtime_Plot.XLabel.String = 'time [ns]';
    h.Microtime_Plot.YLabel.Color = Look.Fore;
    h.Microtime_Plot.YLabel.String = 'intensity [counts]';
    h.Microtime_Plot.XGrid = 'on';
    h.Microtime_Plot.YGrid = 'on';
    
    %%% Residuals Plot
    h.Residuals_Plot = axes(...
        'Parent',h.TauFit_Panel,...
        'Units','normalized',...
        'Position',[0.05 0.85 0.9 0.12],...
        'Tag','Residuals_Plot',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XTickLabel',[],...
        'Box','on');
    hold on;
    h.Plots.Residuals = plot([0 1],[0 0],'-k');
    h.Plots.Residuals_ZeroLine = plot([0 1],[0 0],'-k','Visible','off');
    h.Residuals_Plot.YLabel.Color = Look.Fore;
    h.Residuals_Plot.YLabel.String = 'res_w';
    h.Residuals_Plot.XGrid = 'on';
    h.Residuals_Plot.YGrid = 'on';
    
    %%% Result Plot (Replaces Microtime Plot after fit is done)
    h.Result_Plot = axes(...
        'Parent',h.TauFit_Panel,...
        'Units','normalized',...
        'Position',[0.05 0.075 0.9 0.8],...
        'Tag','Microtime_Plot',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Box','on',...
        'Visible','on',...
        'UIContextMenu',h.Microtime_Plot_Menu_ResultPlot);
    h.Result_Plot_Text = text(...
        0,0,'',...
        'Parent',h.Result_Plot,...
        'FontSize',12,...
        'FontWeight','bold',...
        'BackgroundColor','none',...
        'Units','normalized',...
        'Color',Look.AxesFore);
    
    h.Result_Plot.XLim = [0 1];
    h.Result_Plot.YLim = [0 1];
    h.Result_Plot.XLabel.Color = Look.Fore;
    h.Result_Plot.XLabel.String = 'time [ns]';
    h.Result_Plot.YLabel.Color = Look.Fore;
    h.Result_Plot.YLabel.String = 'intensity [counts]';
    h.Result_Plot.XGrid = 'on';
    h.Result_Plot.YGrid = 'on';
    linkaxes([h.Result_Plot, h.Residuals_Plot],'x');
    %h.Result_Plot_Text.Position = [0.8*h.Result_Plot.XLim(2) 0.9*h.Result_Plot.YLim(2)];
    h.Result_Plot_Text.Position = [0.8 0.9];
    hold on;
    h.Plots.DecayResult = plot([0 1],[0 0],'--k');
    h.Plots.FitResult = plot([0 1],[0 0],'r','LineWidth',2);
    
    %%% dummy panel to hide plots
    h.HidePanel = uibuttongroup(...
        'Visible','off',...
        'Parent',h.TauFit_Panel,...
        'Tag','HidePanel');
    
    %%% Hide Result Plot
    h.Result_Plot.Parent = h.HidePanel;
    %% Sliders
    %%% Define the container
    h.Slider_Panel = uibuttongroup(...
        'Parent',h.TauFit,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 0.75 0.2],...
        'Tag','Slider_Panel');
    
    %%% Individual sliders for:
    %%% 1) Start
    %%% 2) Length
    %%% 3) Shift of perpendicular channel
    %%% 4) Shift of IRF
    %%% 5) IRF length to consider
    %%%
    %%% Slider for Selection of Start
    h.StartPar_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.835 0.8 0.125],...
        'Tag','StartPar_Slider',...
        'Callback',@Update_Plots);
    
    h.StartPar_Edit = uicontrol(...
        'Parent',h.Slider_Panel,...
        'Style','edit',...
        'Tag','StartPar_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.85 0.05 0.125],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_Plots);
    
    h.StartPar_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','Start Parallel',...
        'TooltipString','Start Value for the Parallel Channel',...
        'Position',[0.01 0.85 0.14 0.125],...
        'Tag','StartPar_Text');
    
    %%% Slider for Selection of Length
    h.Length_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.67 0.8 0.125],...
        'Tag','Length_Slider',...
        'Callback',@Update_Plots);
    
    h.Length_Edit = uicontrol(...
        'Parent',h.Slider_Panel,...
        'Style','edit',...
        'Tag','Length_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.685 0.05 0.125],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_Plots);
    
    h.Length_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','Length',...
        'TooltipString','Length of the Microtime Histogram',...
        'Position',[0.01 0.685 0.14 0.125],...
        'Tag','Length_Text');
    
    %%% Slider for Selection of Perpendicular Shift
    h.ShiftPer_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.505 0.8 0.125],...
        'Tag','ShiftPer_Slider',...
        'Callback',@Update_Plots);
    
    h.ShiftPer_Edit = uicontrol(...
        'Parent',h.Slider_Panel,...
        'Style','edit',...
        'Tag','ShiftPer_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.52 0.05 0.125],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_Plots);
    
    h.ShiftPer_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','Perpendicular Shift',...
        'TooltipString','Shift of the Perpendicular Channel',...
        'Position',[0.01 0.52 0.14 0.125],...
        'Tag','ShiftPer_Text');
    
    %%% Slider for Selection of IRF Shift
    h.IRFShift_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.375 0.8 0.125],...
        'Tag','IRFShift_Slider',...
        'Callback',@Update_Plots);
    
    h.IRFShift_Edit = uicontrol(...
        'Parent',h.Slider_Panel,...
        'Style','edit',...
        'Tag','IRFShift_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.385 0.05 0.125],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_Plots);
    
    h.IRFShift_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','IRF Shift',...
        'TooltipString','Shift of the IRF',...
        'Position',[0.01 0.385 0.14 0.125],...
        'Tag','IRFShift_Text');
    
    %%% Slider for Selection of relative IRF Shift
    h.IRFrelShift_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.245 0.8 0.125],...
        'Tag','IRFrelShift_Slider',...
        'Callback',@Update_Plots);
    
    h.IRFrelShift_Edit = uicontrol(...
        'Parent',h.Slider_Panel,...
        'Style','edit',...
        'Tag','IRFrelShift_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.255 0.05 0.125],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_Plots);
    
    h.IRFrelShift_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','IRF rel. Shift',...
        'TooltipString','Shift of the IRF perpendicular with respect to the parallel IRF',...
        'Position',[0.01 0.255 0.14 0.125],...
        'Tag','IRFrelShift_Text');
    
    %%% Slider for Selection of IRF Length
    h.IRFLength_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.125 0.8 0.125],...
        'Tag','IRFLength_Slider',...
        'Callback',@Update_Plots);
    
    h.IRFLength_Edit = uicontrol(...
        'Parent',h.Slider_Panel,...
        'Style','edit',...
        'Tag','IRFLength_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.135 0.05 0.125],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_Plots);
    
    h.IRFLength_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','IRF Length',...
        'TooltipString','Length of the IRF',...
        'Position',[0.01 0.135 0.14 0.125],...
        'Tag','IRFLength_Text');
    
    %%% Slider for Selection of Ignore Region in the Beginning
    h.Ignore_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0 0.8 0.125],...
        'Tag','Ignore_Slider',...
        'Callback',@Update_Plots);
    
    h.Ignore_Edit = uicontrol(...
        'Parent',h.Slider_Panel,...
        'Style','edit',...
        'Tag','Ignore_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.025 0.05 0.125],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_Plots);
    
    h.Ignore_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','Ignore Length',...
        'TooltipString','Length of the Ignore Region in the Beginning',...
        'Position',[0.01 0.025 0.14 0.125],...
        'Tag','Ignore_Text');
    
    %%% Add listeners to sliders for continuous update
    %addlistener(h.Start_Slider, 'Value', 'PostSet', @Update_Plots);
    %addlistener(h.Length_Slider, 'Value', 'PostSet', @Update_Plots);
    %addlistener(h.PerpShift_Slider, 'Value', 'PostSet', @Update_Plots);
    %addlistener(h.IRFShift_Slider, 'Value', 'PostSet', @Update_Plots);
    %addlistener(h.IRFLength_Slider, 'Value', 'PostSet', @Update_Plots);
    %% PIE Channel Selection and general Buttons
    h.PIEChannel_Panel = uibuttongroup(...
        'Parent',h.TauFit,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0.75 0.75 0.25 0.22],...
        'Tag','PIEChannel_Panel');
    
    %%% Popup menus for PIE Channel Selection
    h.PIEChannelPar_Popupmenu = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','Popupmenu',...
        'Tag','PIEChannelPar_Popupmenu',...
        'Units','normalized',...
        'Position',[0.5 0.85 0.4 0.1],...
        'String',UserValues.PIE.Name,...
        'Callback',@Channel_Selection);
    
    h.PIEChannelPar_Text = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','Text',...
        'Tag','PIEChannelPar_Text',...
        'Units','normalized',...
        'Position',[0.05 0.85 0.4 0.1],...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','Parallel Channel',...
        'ToolTipString','Selection for the Parallel Channel');
    
    h.PIEChannelPer_Popupmenu = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','Popupmenu',...
        'Tag','PIEChannelPer_Popupmenu',...
        'Units','normalized',...
        'Position',[0.5 0.7 0.4 0.1],...
        'String',UserValues.PIE.Name,...
        'Callback',@Channel_Selection);
    
    h.PIEChannelPer_Text = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','Text',...
        'Tag','PIEChannelPer_Text',...
        'Units','normalized',...
        'Position',[0.05 0.7 0.4 0.1],...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','Perpendicular Channel',...
        'ToolTipString','Selection for the Perpendicular Channel');
    
    %%% Set the Popupmenus according to UserValues
    h.PIEChannelPar_Popupmenu.Value = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{1}));
    h.PIEChannelPer_Popupmenu.Value = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{2}));
    if isempty(h.PIEChannelPar_Popupmenu.Value)
        h.PIEChannelPar_Popupmenu.Value = 1;
    end
    if isempty(h.PIEChannelPer_Popupmenu.Value)
        h.PIEChannelPer_Popupmenu.Value = 1;
    end
    %%% Popup Menu for Fit Method Selection
    h.FitMethods = {'Single Exponential','Biexponential','Three Exponentials',...
        'Distribution','Distribution plus Donor only','Fit Anisotropy','Fit Anisotropy (2 exp)'};
    h.FitMethod_Popupmenu = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','Popupmenu',...
        'Tag','FitMethod_Popupmenu',...
        'Units','normalized',...
        'Position',[0.35 0.25 0.6 0.1],...
        'String',h.FitMethods,...
        'Callback',@Method_Selection);
    
    h.FitMethod_Text = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','Text',...
        'Tag','FitMethod_Text',...
        'Units','normalized',...
        'Position',[0.05 0.25 0.25 0.1],...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','Fit Method',...
        'ToolTipString','Select the Fit Method');
    
    %%% Button for loading the selected PIE Channels
    h.LoadData_Button = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','pushbutton',...
        'Tag','LoadData_Button',...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.05 0.4 0.4 0.2],...
        'String','Load Data',...
        'Callback',@Update_Plots);
    %%% Button to start fitting
    h.Fit_Button = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','pushbutton',...
        'Tag','Fit_Button',...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.05 0.05 0.2 0.2],...
        'String','Start Fit',...
        'Callback',@Start_Fit);
    %%% Button to determine G-factor
    h.Determine_GFactor_Button = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','pushbutton',...
        'Tag','Determine_GFactor_Button',...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.55 0.4 0.4 0.2],...
        'String','Determine G-Factor',...
        'Callback',@DetermineGFactor);
    %%% Button to fit Time resolved anisotropy
    h.Fit_Aniso_Button = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','pushbutton',...
        'Tag','Fit_Button',...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.4 0.05 0.55 0.15],...
        'String','Fit time-resolved anisotropy',...
        'Callback',@Start_Fit);
    h.Fit_Aniso_Menu = uicontextmenu;
    h.Fit_Aniso_2exp = uimenu('Parent',h.Fit_Aniso_Menu,...
        'Label','2 exponentials',...
        'Checked','off',...
        'Callback',@Start_Fit);
    h.Fit_Aniso_Button.UIContextMenu = h.Fit_Aniso_Menu;
    %% Progressbar and file name %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Panel for progressbar
    h.Progress_Panel = uibuttongroup(...
        'Parent',h.TauFit,...
        'Tag','Progress_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0.75 0.97 0.25 0.03]);
    %%% Axes for progressbar
    h.Progress_Axes = axes(...
        'Parent',h.Progress_Panel,...
        'Tag','Progress_Axes',...
        'Units','normalized',...
        'Color',Look.Control,...
        'Position',[0 0 1 1]);
    h.Progress_Axes.XTick=[]; h.Progress_Axes.YTick=[];
    %%% Progress and filename text
    h.Progress_Text=text(...
        'Parent',h.Progress_Axes,...
        'Tag','Progress_Text',...
        'Units','normalized',...
        'FontSize',12,...
        'FontWeight','bold',...
        'String','Idle',...
        'Interpreter','none',...
        'HorizontalAlignment','center',...
        'BackgroundColor','none',...
        'Color',Look.Fore,...
        'Position',[0.5 0.5]); 
    %% Tabs for Fit Parameters and Settings
    %%% Tab containing a table for the fit parameters
    h.TauFit_Tabgroup = uitabgroup(...
        'Parent',h.TauFit,...
        'Tag','TauFit_Tabgroup',...
        'Units','normalized',...
        'Position',[0.75 0 0.25 0.75]);
    
    h.FitPar_Tab = uitab(...
        'Parent',h.TauFit_Tabgroup,...
        'Title','Fit',...
        'Tag','FitPar_Tab');
    
    h.FitPar_Panel = uibuttongroup(...
        'Parent',h.FitPar_Tab,...
        'Units','normalized',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'HighlightColor',Look.Control,...
        'ShadowColor',Look.Shadow,...
        'Position',[0 0 1 1],...
        'Tag','FitPar_Panel');
    
    %%% Fit Parameter Table
    h.FitPar_Table = uitable(...
        'Parent',h.FitPar_Panel,...
        'Units','normalized',...
        'Position',[0 0.5 1 0.5],...
        'ColumnName',{'Value','LB','UB','Fixed'},...
        'ColumnFormat',{'numeric','numeric','numeric','logical'},...
        'RowName',{'Test'},...
        'ColumnEditable',[true true true true],...
        'ColumnWidth',{50,50,50,40},...
        'Tag','FitPar_Table',...
        'CellEditCallBack',@Update_Plots,...
        'BackgroundColor', [Look.Table1;Look.Table2],...
        'ForegroundColor', Look.TableFore);
    %%% RowNames - Store the Parameter Names of different FitMethods
    h.Parameters = cell(numel(h.FitMethods),1);
    h.Parameters{1} = {'Tau [ns]','Scatter','Background','IRF Shift'};
    h.Parameters{2} = {'Tau1 [ns]','Tau2 [ns]','Fraction 1','Scatter','Background','IRF Shift'};
    h.Parameters{3} = {'Tau1 [ns]','Tau2 [ns]','Tau3 [ns]','Fraction 1','Fraction 2','Scatter','Background','IRF Shift'};
    h.Parameters{4} = {'Center R [A]','Sigma R [A]','Scatter','Background','R0 [A]','TauD0 [ns]','IRF Shift'};
    h.Parameters{5} = {'Center R [A]','Sigma R [A]','Fraction Donly','Scatter','Background','R0 [A]','TauD0 [ns]','IRF Shift'};
    h.Parameters{6} = {'Tau [ns]','Rho [ns]','r0','r_infinity','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};
    h.Parameters{7} = {'Tau [ns]','Rho1 [ns]','Rho2 [ns]','r0','r_infinity','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};
    h.FitPar_Table.RowName = h.Parameters{1};
    %%% Initial Data - Store the StartValues as well as LB and UB
    h.StartPar = cell(numel(h.FitMethods),1);
    h.StartPar{1} = {2,0,Inf,false;0,0,1,true;0,0,1,true;0,0,0,true};
    h.StartPar{2} = {2,0,Inf,false;2,0,Inf,false;0,0,1,false;0,0,1,true;0,0,1,true;0,0,0,true};
    h.StartPar{3} = {2,0,Inf,false;2,0,Inf,false;2,0,Inf,false;0,0,1,false;0,0,1,false;0,0,1,true;0,0,1,true;0,0,0,true};
    h.StartPar{4} = {50,0,Inf,false;5,0,Inf,false;0,0,1,true;0,0,1,true;50,0,Inf,true;4,0,Inf,true;0,0,0,true};
    h.StartPar{5} = {50,0,Inf,false;5,0,Inf,false;0,0,1,false;0,0,1,true;0,0,1,true;50,0,Inf,true;4,0,Inf,true;0,0,0,true};
    h.StartPar{6} = {2,0,Inf,false;1,0,Inf,false;0.4,0,0.4,false;0,0,0.4,false;0,0,1,true;0,0,1,true;0,0,1,true;0,0,1,true;0,0,1,true;0,0,1,true;0,0,0,true};
    h.StartPar{7} = {2,0,Inf,false;1,0,Inf,false;1,0,Inf,false;0.4,0,0.4,false;0,0,0.4,false;0,0,1,true;0,0,1,true;0,0,1,true;0,0,1,true;0,0,1,true;0,0,1,true;0,0,0,true};
    h.FitPar_Table.Data = h.StartPar{1};
    
    %%% Edit Boxes for Correction Factors
    h.G_factor_text = uicontrol(...
        'Parent',h.FitPar_Panel,...
        'Style','text',...
        'Units','normalized',...
        'Position',[0.05 0.45 0.3 0.03],...
        'String','G-Factor',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Tag','G_factor_text');
    
    h.G_factor_edit = uicontrol(...
        'Parent',h.FitPar_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.35 0.45 0.3 0.03],...
        'String','1',...
        'FontSize',12,...
        'Tag','G_factor_edit');
    
    h.l1_text = uicontrol(...
        'Parent',h.FitPar_Panel,...
        'Style','text',...
        'Units','normalized',...
        'Position',[0.05 0.4 0.3 0.03],...
        'String','l1',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Tag','l1_text');
    
    h.l1_edit = uicontrol(...
        'Parent',h.FitPar_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.35 0.4 0.3 0.03],...
        'String','0',...
        'FontSize',12,...
        'Tag','l1_edit');
    
    h.l2_text = uicontrol(...
        'Parent',h.FitPar_Panel,...
        'Style','text',...
        'Units','normalized',...
        'Position',[0.05 0.35 0.3 0.03],...
        'String','l2',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Tag','l2_text');
    
    h.l2_edit = uicontrol(...
        'Parent',h.FitPar_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.35 0.35 0.3 0.03],...
        'String','0',...
        'FontSize',12,...
        'Tag','l2_edit');
    
    %%% Tab containing settings
    h.Settings_Tab = uitab(...
        'Parent',h.TauFit_Tabgroup,...
        'Title','Settings',...
        'Tag','Settings_Tab');
    
    h.Settings_Panel = uibuttongroup(...
        'Parent',h.Settings_Tab,...
        'Units','normalized',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'HighlightColor',Look.Control,...
        'ShadowColor',Look.Shadow,...
        'Position',[0 0 1 1],...
        'Tag','Settings_Panel');
    
    uicontrol(...
        'Style','text',...
        'Parent',h.Settings_Panel,...
        'Units','normalized',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'Position',[0.05 0.9 0.35 0.07],...
        'String','Convolution Type',...
        'FontSize',12,...
        'Tag','ConvolutionType_Text');   
    
    h.ConvolutionType_Menu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.Settings_Panel,...
        'Units','normalized',...
        'BackgroundColor',Look.Axes,...
        'ForegroundColor',Look.Fore,...
        'Position',[0.4 0.9 0.5 0.07],...
        'String',{'linear','circular'},...
        'Value',find(strcmp({'linear','circular'},UserValues.TauFit.ConvolutionType)),...
        'Tag','ConvolutionType_Menu');   
    %% Set the FontSize to 12
    fields = fieldnames(h); %%% loop through h structure
    for i = 1:numel(fields)
        if isprop(h.(fields{i}),'FontSize')
            h.(fields{i}).FontSize = 12;
        end
    end
    %% Mac upscaling of Font Sizes
    if ismac
        scale_factor = 1.2;
        fields = fieldnames(h); %%% loop through h structure
        for i = 1:numel(fields)
            if isprop(h.(fields{i}),'FontSize')
                h.(fields{i}).FontSize = (h.(fields{i}).FontSize)*scale_factor;
            end
        end
    end
else
    figure(h.TauFit);
end
%% Initialize Parameters
TauFitData.Length = 1;
TauFitData.StartPar = 0;
TauFitData.ShiftPer = 0;
TauFitData.IRFLength = 1;
TauFitData.IRFShift = 0;
TauFitData.IRFrelShift = 0;
TauFitData.Ignore = 1;
TauFitData.FitType = h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value};
TauFitData.FitMethods = h.FitMethods;

guidata(gcf,h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Load the Microtime Histogram of selected PIE Channels %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function Load_Data(~,~)
% global UserValues TauFitData PamMeta FileInfo
% h = guidata(findobj('Tag','TauFit'));
% %%% find the number of the selected PIE channels
% PIEChannel_Par = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{1}));
% PIEChannel_Per = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{2}));
% 
% %%% Microtime Histogram of Parallel Channel
% TauFitData.hMI_Par = PamMeta.MI_Hist{UserValues.PIE.Detector(PIEChannel_Par),UserValues.PIE.Router(PIEChannel_Par)}(...
%     UserValues.PIE.From(PIEChannel_Par):UserValues.PIE.To(PIEChannel_Par) );
% %%% Microtime Histogram of Perpendicular Channel
% TauFitData.hMI_Per = PamMeta.MI_Hist{UserValues.PIE.Detector(PIEChannel_Per),UserValues.PIE.Router(PIEChannel_Per)}(...
%     UserValues.PIE.From(PIEChannel_Per):UserValues.PIE.To(PIEChannel_Per) );
% 
% TauFitData.XData_Par = (UserValues.PIE.From(PIEChannel_Par):UserValues.PIE.To(PIEChannel_Par))*FileInfo.SyncPeriod*1E9/FileInfo.MI_Bins;
% TauFitData.XData_Per = (UserValues.PIE.From(PIEChannel_Per):UserValues.PIE.To(PIEChannel_Per))*FileInfo.SyncPeriod*1E9/FileInfo.MI_Bins;
% %%% Plot the Data
% 
% h.Plots.Decay_Par.XData = TauFitData.XData_Par;
% h.Plots.Decay_Per.XData = TauFitData.XData_Per;
% h.Plots.Decay_Par.YData = TauFitData.hMI_Par;
% h.Plots.Decay_Per.YData = TauFitData.hMI_Per;
% h.Microtime_Plot.XLim = [min([TauFitData.XData_Par TauFitData.XData_Per]) max([TauFitData.XData_Par TauFitData.XData_Per])];

function ChangeYScale(obj,~)
h = guidata(obj);
if strcmp(obj.Checked,'off')
    %%% Set Checked
    h.Microtime_Plot_ChangeYScaleMenu_MIPlot.Checked = 'on';
    h.Microtime_Plot_ChangeYScaleMenu_ResultPlot.Checked = 'on';
    %%% Change Scale to Log
    h.Microtime_Plot.YScale = 'log';
    h.Result_Plot.YScale = 'log';
elseif strcmp(obj.Checked,'on')
    %%% Set Unchecked
    h.Microtime_Plot_ChangeYScaleMenu_MIPlot.Checked = 'off';
    h.Microtime_Plot_ChangeYScaleMenu_ResultPlot.Checked = 'off';
    %%% Change Scale to Lin
    h.Microtime_Plot.YScale = 'lin';
    h.Result_Plot.YScale = 'lin';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  General Function to Update Plots when something changed %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(obj,~)
global UserValues TauFitData FileInfo TcspcData
h = guidata(findobj('Tag','TauFit'));

%%% Cases to consider:
%%% obj is empty or is Button for LoadData/LoadIRF
%%% Data has been changed (PIE Channel changed, IRF loaded...)
if isempty(obj) || obj == h.LoadData_Button
    %%% find the number of the selected PIE channels
    PIEChannel_Par = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{1}));
    PIEChannel_Per = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{2}));
    %%% Read out Photons and Histogram
    MI_Par = histc( TcspcData.MI{UserValues.PIE.Detector(PIEChannel_Par),UserValues.PIE.Router(PIEChannel_Par)},...
        0:(FileInfo.MI_Bins-1));
    MI_Per = histc( TcspcData.MI{UserValues.PIE.Detector(PIEChannel_Per),UserValues.PIE.Router(PIEChannel_Per)},...
        0:(FileInfo.MI_Bins-1));
    %%% Compute the Microtime Histograms
    TauFitData.hMI_Par = MI_Par(UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]));
    TauFitData.hMI_Per = MI_Per(UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]));
    %%% Microtime Histogram of Parallel Channel
%     TauFitData.hMI_Par = PamMeta.MI_Hist{UserValues.PIE.Detector(PIEChannel_Par),UserValues.PIE.Router(PIEChannel_Par)}(...
%         UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]) );
%     %%% Microtime Histogram of Perpendicular Channel
%     TauFitData.hMI_Per = PamMeta.MI_Hist{UserValues.PIE.Detector(PIEChannel_Per),UserValues.PIE.Router(PIEChannel_Per)}(...
%         UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]) );

    %%% Read out the Microtime Histograms of the IRF for the two channels
    TauFitData.hIRF_Par = UserValues.PIE.IRF{PIEChannel_Par}(UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]));
    TauFitData.hIRF_Per = UserValues.PIE.IRF{PIEChannel_Per}(UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]));
    %%% Normalize IRF for better Visibility
    TauFitData.hIRF_Par = (TauFitData.hIRF_Par./max(TauFitData.hIRF_Par)).*max(TauFitData.hMI_Par);
    TauFitData.hIRF_Per = (TauFitData.hIRF_Per./max(TauFitData.hIRF_Per)).*max(TauFitData.hMI_Per);
    %%% Read out the Microtime Histograms of the Scatter Measurement for the two channels
    TauFitData.hScat_Par = UserValues.PIE.ScatterPattern{PIEChannel_Par}(UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]));
    TauFitData.hScat_Per = UserValues.PIE.ScatterPattern{PIEChannel_Per}(UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]));
    %%% Normalize IRF for better Visibility
    TauFitData.hScat_Par = (TauFitData.hScat_Par./max(TauFitData.hScat_Par)).*max(TauFitData.hMI_Par);
    TauFitData.hScat_Per = (TauFitData.hScat_Per./max(TauFitData.hScat_Per)).*max(TauFitData.hMI_Per);
    %%% Generate XData
    TauFitData.XData_Par = (UserValues.PIE.From(PIEChannel_Par):UserValues.PIE.To(PIEChannel_Par)) - UserValues.PIE.From(PIEChannel_Par);
    TauFitData.XData_Per = (UserValues.PIE.From(PIEChannel_Per):UserValues.PIE.To(PIEChannel_Per)) - UserValues.PIE.From(PIEChannel_Per);

    %%% Plot the Data
    TACtoTime = 1/FileInfo.MI_Bins*FileInfo.TACRange*1e9;
    h.Plots.Decay_Par.XData = TauFitData.XData_Par*TACtoTime;
    h.Plots.Decay_Per.XData = TauFitData.XData_Per*TACtoTime;
    h.Plots.IRF_Par.XData = TauFitData.XData_Par*TACtoTime;
    h.Plots.IRF_Per.XData = TauFitData.XData_Per*TACtoTime;
    h.Plots.Scatter_Par.XData = TauFitData.XData_Par*TACtoTime;
    h.Plots.Scatter_Per.XData = TauFitData.XData_Per*TACtoTime;
    h.Plots.Decay_Par.YData = TauFitData.hMI_Par;
    h.Plots.Decay_Per.YData = TauFitData.hMI_Per;
    h.Plots.IRF_Par.YData = TauFitData.hIRF_Par;
    h.Plots.IRF_Per.YData = TauFitData.hIRF_Per;
    h.Microtime_Plot.XLim = [min([TauFitData.XData_Par*TACtoTime TauFitData.XData_Per*TACtoTime]) max([TauFitData.XData_Par*TACtoTime TauFitData.XData_Per*TACtoTime])];
    h.Microtime_Plot.YLim = [min([TauFitData.hMI_Par; TauFitData.hMI_Per]) 10/9*max([TauFitData.hMI_Par; TauFitData.hMI_Per])];
    %%% Define the Slider properties
    %%% Values to consider:
    %%% The length of the shortest PIE channel
    TauFitData.MaxLength = min([numel(TauFitData.hMI_Par) numel(TauFitData.hMI_Per)]);
    %%% The Length Slider defaults to the length of the shortest PIE
    %%% channel and should not assume larger values
    h.Length_Slider.Min = 1;
    h.Length_Slider.Max = TauFitData.MaxLength;
    h.Length_Slider.Value = TauFitData.MaxLength;
    TauFitData.Length = TauFitData.MaxLength;
    h.Length_Edit.String = num2str(TauFitData.Length);
    %%% Start Parallel Slider can assume values from 0 (no shift) up to the
    %%% length of the shortest PIE channel minus the set length
    h.StartPar_Slider.Min = 0;
    h.StartPar_Slider.Max = TauFitData.MaxLength;
    h.StartPar_Slider.Value = 0;
    TauFitData.StartPar = 0;
    h.StartPar_Edit.String = num2str(TauFitData.StartPar);
    %%% Shift Perpendicular Slider can assume values from the difference in
    %%% start point between parallel and perpendicular up to the difference
    %%% between the end point of the parallel channel and the start point
    %%% of the perpendicular channel
    h.ShiftPer_Slider.Min = -floor(TauFitData.MaxLength/10);
    h.ShiftPer_Slider.Max = floor(TauFitData.MaxLength/10);
    h.ShiftPer_Slider.Value = 0;
    TauFitData.ShiftPer = 0;
    h.ShiftPer_Edit.String = num2str(TauFitData.ShiftPer);

    %%% IRF Length has the same limits as the Length property
    h.IRFLength_Slider.Min = 1;
    h.IRFLength_Slider.Max = TauFitData.MaxLength;
    h.IRFLength_Slider.Value = TauFitData.MaxLength;
    TauFitData.IRFLength = TauFitData.MaxLength;
    h.IRFLength_Edit.String = num2str(TauFitData.IRFLength);
    %%% IRF Shift has the same limits as the perp shift property
    h.IRFShift_Slider.Min = -floor(TauFitData.MaxLength/10);
    h.IRFShift_Slider.Max = floor(TauFitData.MaxLength/10);
    h.IRFShift_Slider.Value = 0;
    TauFitData.IRFShift = 0;
    h.IRFShift_Edit.String = num2str(TauFitData.IRFShift);
    
    %%% IRF rel. Shift has the same limits as the perp shift property
    h.IRFrelShift_Slider.Min = -floor(TauFitData.MaxLength/10);
    h.IRFrelShift_Slider.Max = floor(TauFitData.MaxLength/10);
    h.IRFrelShift_Slider.Value = 0;
    TauFitData.IRFrelShift = 0;
    h.IRFrelShift_Edit.String = num2str(TauFitData.IRFrelShift);
    
    %%% Ignore Slider reaches from 1 to maximum length
    h.Ignore_Slider.Value = 1;
    h.Ignore_Slider.Min = 1;
    h.Ignore_Slider.Max = TauFitData.MaxLength;
    TauFitData.Ignore = 1;
    h.Ignore_Edit.String = num2str(TauFitData.Ignore);
end

%%% Update Values
switch obj
    case {h.StartPar_Slider, h.StartPar_Edit}
        if obj == h.StartPar_Slider
            TauFitData.StartPar = floor(obj.Value);
        elseif obj == h.StartPar_Edit
            TauFitData.StartPar = str2double(obj.String);
        end
    case {h.Length_Slider, h.Length_Edit}
        %%% Update Value
        if obj == h.Length_Slider
            TauFitData.Length = floor(obj.Value);
        elseif obj == h.Length_Edit
            TauFitData.Length = str2double(obj.String);
        end
        %%% Correct if IRFLength exceeds the Length
        if TauFitData.IRFLength > TauFitData.Length
            TauFitData.IRFLength = TauFitData.Length;
        end
    case {h.ShiftPer_Slider, h.ShiftPer_Edit}
        %%% Update Value
        if obj == h.ShiftPer_Slider
            TauFitData.ShiftPer = floor(obj.Value);
        elseif obj == h.ShiftPer_Edit
            TauFitData.ShiftPer = str2double(obj.String);
        end
    case {h.IRFLength_Slider, h.IRFLength_Edit}
        %%% Update Value
        if obj == h.IRFLength_Slider
            TauFitData.IRFLength = floor(obj.Value);
        elseif obj == h.IRFLength_Edit
            TauFitData.IRFLength = str2double(obj.String);
        end
        %%% Correct if IRFLength exceeds the Length
        if TauFitData.IRFLength > TauFitData.Length
            TauFitData.IRFLength = TauFitData.Length;
        end
    case {h.IRFShift_Slider, h.IRFShift_Edit}
        %%% Update Value
        if obj == h.IRFShift_Slider
            TauFitData.IRFShift = floor(obj.Value);
        elseif obj == h.IRFShift_Edit
            TauFitData.IRFShift = str2double(obj.String);
        end
    case {h.IRFrelShift_Slider, h.IRFrelShift_Edit}
        %%% Update Value
        if obj == h.IRFrelShift_Slider
            TauFitData.IRFrelShift = floor(obj.Value);
        elseif obj == h.IRFrelShift_Edit
            TauFitData.IRFrelShift = str2double(obj.String);
        end
    case {h.Ignore_Slider,h.Ignore_Edit}%%% Update Value
        if obj == h.Ignore_Slider
            TauFitData.Ignore = floor(obj.Value);
        elseif obj == h.Ignore_Edit
            TauFitData.Ignore = str2double(obj.String);
        end
    case {h.FitPar_Table}
        TauFitData.IRFShift = obj.Data{end,1};
        %%% Update Edit Box and Slider
        h.IRFShift_Edit.String = num2str(TauFitData.IRFShift);
        h.IRFShift_Slider.Value = TauFitData.IRFShift;
end
%%% Update Edit Boxes if Slider was used and Sliders if Edit Box was used
if isprop(obj,'Style')
    switch obj.Style
        case 'slider'
            h.StartPar_Edit.String = num2str(TauFitData.StartPar);
            h.Length_Edit.String = num2str(TauFitData.Length);
            h.ShiftPer_Edit.String = num2str(TauFitData.ShiftPer);
            h.IRFLength_Edit.String = num2str(TauFitData.IRFLength);
            h.IRFShift_Edit.String = num2str(TauFitData.IRFShift);
            h.IRFrelShift_Edit.String = num2str(TauFitData.IRFrelShift);
            h.FitPar_Table.Data{end,1} = TauFitData.IRFShift;
            h.Ignore_Edit.String = num2str(TauFitData.Ignore);
        case 'edit'
            h.StartPar_Slider.Value = TauFitData.StartPar;
            h.Length_Slider.Value = TauFitData.Length;
            h.ShiftPer_Slider.Value = TauFitData.ShiftPer;
            h.IRFLength_Slider.Value = TauFitData.IRFLength;
            h.IRFShift_Slider.Value = TauFitData.IRFShift;
            h.IRFrelShift_Slider.Value = TauFitData.IRFrelShift;
            h.FitPar_Table.Data{end,1} = TauFitData.IRFShift;
            h.Ignore_Slider.Value = TauFitData.Ignore;
    end
end
%%% Update Plot

%%% Make the Microtime Adjustment Plot Visible, hide Result
h.Microtime_Plot.Parent = h.TauFit_Panel;
h.Result_Plot.Parent = h.HidePanel;

TACtoTime = 1/FileInfo.MI_Bins*FileInfo.TACRange*1e9;
%%% Apply the shift to the parallel channel
h.Plots.Decay_Par.XData = ((TauFitData.StartPar:(TauFitData.Length-1)) - TauFitData.StartPar)*TACtoTime;
h.Plots.Decay_Par.YData = TauFitData.hMI_Par((TauFitData.StartPar+1):TauFitData.Length)';
%%% Apply the shift to the perpendicular channel
h.Plots.Decay_Per.XData = ((TauFitData.StartPar:(TauFitData.Length-1)) - TauFitData.StartPar)*TACtoTime;
hMI_Per_Shifted = circshift(TauFitData.hMI_Per,[TauFitData.ShiftPer,0])';
h.Plots.Decay_Per.YData = hMI_Per_Shifted((TauFitData.StartPar+1):TauFitData.Length);
%%% Apply the shift to the parallel IRF channel
h.Plots.IRF_Par.XData = ((TauFitData.StartPar:(TauFitData.IRFLength-1)) - TauFitData.StartPar)*TACtoTime;
hIRF_Par_Shifted = circshift(TauFitData.hIRF_Par,[0,TauFitData.IRFShift])';
h.Plots.IRF_Par.YData = hIRF_Par_Shifted((TauFitData.StartPar+1):TauFitData.IRFLength);
%%% Apply the shift to the perpendicular IRF channel
h.Plots.IRF_Per.XData = ((TauFitData.StartPar:(TauFitData.IRFLength-1)) - TauFitData.StartPar)*TACtoTime;
hIRF_Per_Shifted = circshift(TauFitData.hIRF_Per,[0,TauFitData.IRFShift+TauFitData.ShiftPer+TauFitData.IRFrelShift])';
h.Plots.IRF_Per.YData = hIRF_Per_Shifted((TauFitData.StartPar+1):TauFitData.IRFLength);
%%% Scatter Pattern (only shift perp, don't apply IRF shift)
h.Plots.Scatter_Par.XData = ((TauFitData.StartPar:(TauFitData.Length-1)) - TauFitData.StartPar)*TACtoTime;
h.Plots.Scatter_Par.YData = TauFitData.hScat_Par((TauFitData.StartPar+1):TauFitData.Length)';

h.Plots.Scatter_Per.XData = ((TauFitData.StartPar:(TauFitData.Length-1)) - TauFitData.StartPar)*TACtoTime;
hScatter_Per_Shifted = circshift(TauFitData.hScat_Per,[0,TauFitData.ShiftPer+TauFitData.IRFrelShift])';
h.Plots.Scatter_Per.YData = hScatter_Per_Shifted((TauFitData.StartPar+1):TauFitData.Length);


axes(h.Microtime_Plot);xlim([h.Plots.Decay_Par.XData(1),h.Plots.Decay_Par.XData(end)]);
%%% Update Ignore Plot
if TauFitData.Ignore > 1
    %%% Make plot visible
    h.Ignore_Plot.Visible = 'on';
    h.Ignore_Plot.XData = [TauFitData.Ignore*TACtoTime TauFitData.Ignore*TACtoTime];
    h.Ignore_Plot.YData = h.Microtime_Plot.YLim;
elseif TauFitData.Ignore == 1
    %%% Hide Plot Again
    h.Ignore_Plot.Visible = 'off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Saves the changed PIEChannel Selection to UserValues %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Channel_Selection(obj,~)
global UserValues
h = guidata(findobj('Tag','TauFit'));
%%% Update the Channel Selection in UserValues
UserValues.TauFit.PIEChannelSelection{1} = UserValues.PIE.Name{h.PIEChannelPar_Popupmenu.Value};
UserValues.TauFit.PIEChannelSelection{2} = UserValues.PIE.Name{h.PIEChannelPer_Popupmenu.Value};
LSUserValues(1);
%%% For recalculation, mark which channel was changed
switch obj
    case h.PIEChannelPar_Popupmenu
        TauFitData.ChannelChanged(1) = 1;
    case h.PIEChannelPar_Popupmenu
        TauFitData.ChannelChanged(2) = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Closes TauFit and deletes global variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_TauFit(~,~)
clear global -regexp TauFitData
Pam = findobj('Tag','Pam');
Phasor=findobj('Tag','Phasor');
FCSFit=findobj('Tag','FCSFit');
MIAFit=findobj('Tag','MIAFit');
Mia=findobj('Tag','Mia');
Sim=findobj('Tag','Sim');
PCF=findobj('Tag','PCF');
BurstBrowser=findobj('Tag','BurstBrowser');
if isempty(Pam) && isempty(Phasor) && isempty(FCSFit) && isempty(MIAFit) && isempty(PCF) && isempty(Mia) && isempty(Sim) && isempty(BurstBrowser)
    clear global -regexp UserValues
end
delete(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Executes on Method selection change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Method_Selection(obj,~)
global TauFitData
TauFitData.FitType = obj.String{obj.Value};
%%% Update FitTable
h = guidata(obj);
h.FitPar_Table.RowName = h.Parameters{obj.Value};
h.FitPar_Table.Data = h.StartPar{obj.Value};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Fit the Data with selected Model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Start_Fit(obj,~)
global TauFitData FileInfo
h = guidata(obj);
h.Result_Plot_Text.Visible = 'off';
%% Prepare FitData
TauFitData.FitData.Decay_Par = h.Plots.Decay_Par.YData;
TauFitData.FitData.Decay_Per = h.Plots.Decay_Per.YData;

G = str2double(h.G_factor_edit.String);
l1 = str2double(h.l1_edit.String);
l2 = str2double(h.l2_edit.String);
Conv_Type = h.ConvolutionType_Menu.String{h.ConvolutionType_Menu.Value};
%TauFitData.FitData.IRF_Par = h.Plots.IRF_Par.YData;
%TauFitData.FitData.IRF_Per = h.Plots.IRF_Per.YData;
%%% Read out the shifted scatter pattern
%%% Don't Apply the IRF Shift here, it is done in the FitRoutine using the
%%% total Scatter Pattern to avoid Edge Effects when using circshift!
ScatterPer = circshift(TauFitData.hScat_Per,[0,TauFitData.ShiftPer+TauFitData.IRFrelShift]);
ScatterPattern = TauFitData.hScat_Par(1:TauFitData.Length) +...
    2*ScatterPer(1:TauFitData.Length);
ScatterPattern = ScatterPattern'./sum(ScatterPattern);
%%% (Scatter Pattern is not shifted any more during fitting)
IRFPer = circshift(TauFitData.hIRF_Per,[0,TauFitData.ShiftPer+TauFitData.IRFrelShift]);
IRFPattern = TauFitData.hIRF_Par(1:TauFitData.Length) +...
    2*IRFPer(1:TauFitData.Length);
IRFPattern = IRFPattern'./sum(IRFPattern);
%%% Old:
%Scatter_Par_Shifted = circshift(TauFitData.hIRF_Par,[0,TauFitData.IRFShift])';
%TauFitData.FitData.Scatter_Par = Scatter_Par_Shifted((TauFitData.StartPar+1):TauFitData.Length)';
%Scatter_Per_Shifted = circshift(TauFitData.hIRF_Per,[0,TauFitData.IRFShift + TauFitData.ShiftPer])';
%TauFitData.FitData.Scatter_Per = Scatter_Per_Shifted((TauFitData.StartPar+1):TauFitData.Length)';
%Scatter = TauFitData.FitData.Scatter_Par + 2*TauFitData.FitData.Scatter_Per;
%Scatter = Scatter./sum(Scatter);

%%% The IRF is also adjusted in the Fit dynamically from the total scatter
%%% pattern and start,length, and shift values stored in ShiftParams
%%% ShiftParams(1)  :   StartPar
%%% ShiftParams(2)  :   IRFShift
%%% ShiftParams(3)  :   IRFLength
ShiftParams(1) = TauFitData.StartPar;
ShiftParams(2) = TauFitData.IRFShift;
ShiftParams(3) = TauFitData.Length;
ShiftParams(4) = TauFitData.IRFLength;

%%% Old:
%Irf = TauFitData.FitData.IRF_Par+2*TauFitData.FitData.IRF_Per;
%Irf = Irf-min(Irf(Irf~=0));
%Irf = Irf./sum(Irf);
%Irf = [Irf zeros(1,numel(Decay)-numel(Irf))];

%%% initialize inputs for fit
Decay = G*(1-3*l1)*TauFitData.FitData.Decay_Par+(2-3*l2)*TauFitData.FitData.Decay_Per;
TauFitData.TACRange = FileInfo.TACRange*1E9;
if ~isfield(FileInfo,'Resolution')
    TauFitData.TACChannelWidth = FileInfo.TACRange*1E9/FileInfo.MI_Bins;
elseif isfield(FileInfo,'Resolution') %%% HydraHarp Data
    TauFitData.TACChannelWidth = FileInfo.Resolution/1000;
end
%%% Check if IRFshift is fixed or not
if h.FitPar_Table.Data{end,4} == 0
    %%% IRF is not fixed
    irf_lb = h.FitPar_Table.Data{end,2};
    irf_ub = h.FitPar_Table.Data{end,3};
    shift_range = floor(TauFitData.IRFShift + irf_lb):ceil(TauFitData.IRFShift + irf_ub);
elseif h.FitPar_Table.Data{end,4} == 1
    shift_range = TauFitData.IRFShift;
end
ignore = TauFitData.Ignore;
%% Start Fit
%%% Update Progressbar
h.Progress_Text.String = 'Fitting...';
MI_Bins = FileInfo.MI_Bins;
switch obj
    case h.Fit_Button
        %%% Read out parameters
        x0 = cell2mat(h.FitPar_Table.Data(1:end-1,1))';
        lb = cell2mat(h.FitPar_Table.Data(1:end-1,2))';
        ub = cell2mat(h.FitPar_Table.Data(1:end-1,3))';
        fixed = cell2mat(h.FitPar_Table.Data(1:end-1,4));
        switch TauFitData.FitType
            case 'Single Exponential'
                %%% Parameter:
                %%% taus    - Lifetimes
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                x0(1) = round(x0(1)/TauFitData.TACChannelWidth);
                lb(1) = round(lb(1)/TauFitData.TACChannelWidth);
                ub(1) = round(ub(1)/TauFitData.TACChannelWidth);  
                %%% fit for different IRF offsets and compare the results
                count = 1;
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                for i = shift_range
                    %%% Update Progressbar
                    Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_1exp(interlace(x0,x,fixed),xdata),...
                    x0(~fixed),xdata,Decay(ignore:end),lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay(ignore:end);sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum(x.^2./sigma_est)/(numel(Decay(ignore:end))-numel(x0)),residuals);
                [~,best_fit] = min(chi2);
                FitFun = fitfun_1exp(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun)./sqrt(Decay);

                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                FitResult{1} = FitResult{1}.*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult;        
            case 'Biexponential'
                %%% Parameter:
                %%% taus    - Lifetimes
                %%% A       - Amplitude of first lifetime
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                x0(1:2) = round(x0(1:2)/TauFitData.TACChannelWidth);
                lb(1:2) = round(lb(1:2)/TauFitData.TACChannelWidth);
                ub(1:2) = round(ub(1:2)/TauFitData.TACChannelWidth);  
                %%% fit for different IRF offsets and compare the results
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                count = 1;
                for i = shift_range
                    %%% Update Progressbar
                    Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_2exp(interlace(x0,x,fixed),xdata),...
                        x0(~fixed),xdata,Decay(ignore:end),lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay(ignore:end);sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum(x.^2./sigma_est)/(numel(Decay(ignore:end))-numel(x0)),residuals);
                [~,best_fit] = min(chi2);
                FitFun = fitfun_2exp(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun)./sqrt(Decay);

                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*TauFitData.TACChannelWidth;
                FitResult{2} = FitResult{2}.*TauFitData.TACChannelWidth;
                %%% Convert Fraction from Area Fraction to Amplitude Fraction
                %%% (i.e. correct for brightness)
                amp1 = FitResult{3}./FitResult{1}; amp2 = (1-FitResult{3})./FitResult{2};
                amp1 = amp1./(amp1+amp2);
                FitResult{3} = amp1;
                h.FitPar_Table.Data(:,1) = FitResult;
            case 'Three Exponentials'
                %%% Parameter:
                %%% taus    - Lifetimes
                %%% A1      - Amplitude of first lifetime
                %%% A2      - Amplitude of first lifetime
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                x0(1:3) = round(x0(1:3)/TauFitData.TACChannelWidth);
                lb(1:3) = round(lb(1:3)/TauFitData.TACChannelWidth);
                ub(1:3) = round(ub(1:3)/TauFitData.TACChannelWidth);  
                %%% fit for different IRF offsets and compare the results
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                count = 1;
                for i = shift_range
                    %%% Update Progressbar
                    Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_3exp(interlace(x0,x,fixed),xdata),...
                        x0(~fixed),xdata,Decay(ignore:end),lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay(ignore:end);sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum(x.^2./sigma_est)/(numel(Decay(ignore:end))-numel(x0)),residuals);
                [~,best_fit] = min(chi2);
                FitFun = fitfun_3exp(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun)./sqrt(Decay);

                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*TauFitData.TACChannelWidth;
                FitResult{2} = FitResult{2}.*TauFitData.TACChannelWidth;
                FitResult{3} = FitResult{3}.*TauFitData.TACChannelWidth;
                %%% Convert Fraction from Area Fraction to Amplitude Fraction
                %%% (i.e. correct for brightness)
                amp1 = FitResult{4}./FitResult{1}; amp2 = FitResult{5}./FitResult{2}; amp3 = (1-FitResult{4}-FitResult{5})./FitResult{3};
                amp1 = amp1./(amp1+amp2+amp3); amp2 = amp2./(amp1+amp2+amp3);
                FitResult{4} = amp1;
                FitResult{5} = amp2;
                h.FitPar_Table.Data(:,1) = FitResult;
            case 'Distribution'
                %%% Parameter:
                %%% Center R
                %%% sigmaR
                %%% Background
                %%% R0
                %%% Donor only lifetime
                %%% Convert Lifetimes
                x0(6) = round(x0(6)/TauFitData.TACChannelWidth);
                lb(6) = round(lb(6)/TauFitData.TACChannelWidth);
                ub(6) = round(ub(6)/TauFitData.TACChannelWidth);  
                %%% fit for different IRF offsets and compare the results
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                count = 1;
                for i = shift_range
                    %%% Update Progressbar
                    Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_dist(interlace(x0,x,fixed),xdata),...
                        x0(~fixed),xdata,Decay(ignore:end),lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay(ignore:end);sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum(x.^2./sigma_est)/(numel(Decay(ignore:end))-numel(x0)),residuals);
                [~,best_fit] = min(chi2);
                FitFun = fitfun_dist(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun)./sqrt(Decay);

                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{5} = FitResult{5}.*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult;
            case 'Distribution plus Donor only'
                %%% Parameter:
                %%% Center R
                %%% sigmaR
                %%% Fraction D only
                %%% Background
                %%% R0
                %%% Donor only lifetime

                %%% Convert Lifetimes
                x0(7) = round(x0(7)/TauFitData.TACChannelWidth);
                lb(7) = round(lb(7)/TauFitData.TACChannelWidth);
                ub(7) = round(ub(7)/TauFitData.TACChannelWidth);  
                %%% fit for different IRF offsets and compare the results
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                count = 1;
                for i = shift_range
                    %%% Update Progressbar
                    Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_dist_donly(interlace(x0,x,fixed),xdata),...
                        x0(~fixed),xdata,Decay(ignore:end),lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay(ignore:end);sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum(x.^2./sigma_est)/(numel(Decay(ignore:end))-numel(x0)),residuals);
                [~,best_fit] = min(chi2);
                FitFun = fitfun_dist_donly(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun)./sqrt(Decay);

                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{7} = FitResult{7}.*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult;
            case 'Fit Anisotropy'
                %%% Parameter
                %%% Lifetime
                %%% Rotational Correlation Time
                %%% r0 - Initial Anisotropy
                %%% r_infinity - Residual Anisotropy
                %%% Background par
                %%% Background per

                %%% Define separate IRF Patterns
                IRFPattern = cell(2,1);
                IRFPattern{1} = TauFitData.hIRF_Par(1:TauFitData.Length)';IRFPattern{1} = IRFPattern{1}./sum(IRFPattern{1});
                IRFPattern{2} = IRFPer(1:TauFitData.Length)';IRFPattern{2} = IRFPattern{2}./sum(IRFPattern{2});

                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = TauFitData.hScat_Par(1:TauFitData.Length)';ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                ScatterPattern{2} = ScatterPer(1:TauFitData.Length)';ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});

                %%% Convert Lifetimes
                x0(1:2) = round(x0(1:2)/TauFitData.TACChannelWidth);
                lb(1:2) = round(lb(1:2)/TauFitData.TACChannelWidth);
                ub(1:2) = round(ub(1:2)/TauFitData.TACChannelWidth);  

                %%% Prepare data as vector
                Decay =  [TauFitData.FitData.Decay_Par(ignore:end); TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_stacked = [TauFitData.FitData.Decay_Par(ignore:end) TauFitData.FitData.Decay_Per(ignore:end)];
                %%% fit for different IRF offsets and compare the results
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                count = 1;
                for i = shift_range
                    %%% Update Progressbar
                    Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_aniso(interlace(x0,x,fixed),xdata),...
                        x0(~fixed),xdata,Decay_stacked,lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay_stacked;sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum(x.^2./sigma_est)/(numel(Decay_stacked)-numel(x0)),residuals);
                [~,best_fit] = min(chi2);
                %%% remove ignore range from decay
                Decay = [TauFitData.FitData.Decay_Par; TauFitData.FitData.Decay_Per];
                Decay_stacked = [TauFitData.FitData.Decay_Par TauFitData.FitData.Decay_Per];
                FitFun = fitfun_aniso(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,shift_range(best_fit),1,Conv_Type});
                wres = (Decay_stacked-FitFun)./sqrt(Decay_stacked); Decay = Decay_stacked;

                 %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*TauFitData.TACChannelWidth;
                FitResult{2} = FitResult{2}.*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult;    
            case 'Fit Anisotropy (2 exp)'
                %%% Parameter
                %%% Lifetime
                %%% Rotational Correlation Time 1
                %%% Rotational Correlation Time 2
                %%% r0 - Initial Anisotropy
                %%% r_infinity - Residual Anisotropy
                %%% Background par
                %%% Background per

                %%% Define separate IRF Patterns
                IRFPattern = cell(2,1);
                IRFPattern{1} = TauFitData.hIRF_Par(1:TauFitData.Length)';IRFPattern{1} = IRFPattern{1}./sum(IRFPattern{1});
                IRFPattern{2} = IRFPer(1:TauFitData.Length)';IRFPattern{2} = IRFPattern{2}./sum(IRFPattern{2});

                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = TauFitData.hScat_Par(1:TauFitData.Length)';ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                ScatterPattern{2} = ScatterPer(1:TauFitData.Length)';ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});

                %%% Convert Lifetimes
                x0(1:3) = round(x0(1:3)/TauFitData.TACChannelWidth);
                lb(1:3) = round(lb(1:3)/TauFitData.TACChannelWidth);
                ub(1:3) = round(ub(1:3)/TauFitData.TACChannelWidth);  

                %%% Prepare data as vector
                Decay =  [TauFitData.FitData.Decay_Par(ignore:end); TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_stacked = [TauFitData.FitData.Decay_Par(ignore:end) TauFitData.FitData.Decay_Per(ignore:end)];
                %%% fit for different IRF offsets and compare the results
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                count = 1;
                for i = shift_range
                    %%% Update Progressbar
                    Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_aniso_2exp(interlace(x0,x,fixed),xdata),...
                        x0(~fixed),xdata,Decay_stacked,lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay_stacked;sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum(x.^2./sigma_est)/(numel(Decay_stacked)-numel(x0)),residuals);
                [~,best_fit] = min(chi2);
                %%% remove ignore range from decay
                Decay = [TauFitData.FitData.Decay_Par; TauFitData.FitData.Decay_Per];
                Decay_stacked = [TauFitData.FitData.Decay_Par TauFitData.FitData.Decay_Per];
                FitFun = fitfun_aniso_2exp(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,shift_range(best_fit),1,Conv_Type});
                wres = (Decay_stacked-FitFun)./sqrt(Decay_stacked); Decay = Decay_stacked;

                 %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*TauFitData.TACChannelWidth;
                FitResult{2} = FitResult{2}.*TauFitData.TACChannelWidth;
                FitResult{3} = FitResult{3}.*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult;  
        end

        %%% Update IRFShift in Slider and Edit Box
        h.IRFShift_Slider.Value = shift_range(best_fit);
        h.IRFShift_Edit.String = num2str(shift_range(best_fit));

        %%% Reset Progressbar
        Progress(1,h.Progress_Axes,h.Progress_Text,'Fit done');
        %h.Progress_Text.String = 'Fit done';
        %%% Update Plot
        h.Microtime_Plot.Parent = h.HidePanel;
        h.Result_Plot.Parent = h.TauFit_Panel;

        % plot chi^2 on graph
        h.Result_Plot_Text.Visible = 'on';
        h.Result_Plot_Text.String = ['\' sprintf('chi^2_{red.} = %.2f', chi2(best_fit))];
        %h.Result_Plot_Text.Position = [0.8*h.Result_Plot.XLim(2) 0.9*h.Result_Plot.YLim(2)];
        h.Result_Plot_Text.Position = [0.8 0.95];

        TACtoTime = 1/FileInfo.MI_Bins*FileInfo.TACRange*1e9;
        h.Plots.DecayResult.XData = (1:numel(Decay))*TACtoTime;
        h.Plots.DecayResult.YData = Decay;
        h.Plots.FitResult.XData = (1:numel(Decay))*TACtoTime;
        h.Plots.FitResult.YData = FitFun;
        axis(h.Result_Plot,'tight');

        h.Plots.Residuals.XData = (1:numel(Decay))*TACtoTime;
        h.Plots.Residuals.YData = wres;
        h.Plots.Residuals_ZeroLine.XData = (1:numel(Decay))*TACtoTime;
        h.Plots.Residuals_ZeroLine.YData = zeros(1,numel(Decay));

        h.Result_Plot.XLim(1) = 0;
    case {h.Fit_Aniso_Button,h.Fit_Aniso_2exp}
        if obj == h.Fit_Aniso_2exp
            number_of_exponentials = 2;
        else
            number_of_exponentials = 1;
        end
        %%% construct Anisotropy
        Aniso = (G*TauFitData.FitData.Decay_Par - TauFitData.FitData.Decay_Per)./Decay;
        Aniso(isnan(Aniso)) = 0;
        Aniso_fit = Aniso(ignore:end); x = 1:numel(Aniso_fit);
        %%% Fit function
        if number_of_exponentials == 1
            tres_aniso = @(x,xdata) (x(2)-x(3))*exp(-xdata./x(1)) + x(3);
            param0 = [1/(FileInfo.TACRange*1e9)*FileInfo.MI_Bins, 0.4,0];
            param = lsqcurvefit(tres_aniso,param0,x,Aniso_fit,[0 0 -1],[Inf,1,1]);
        elseif number_of_exponentials == 2
            tres_aniso = @(x,xdata) ((x(2)-x(4)).*exp(-xdata./x(1)) + x(4)).*exp(-xdata./x(3));
            param0 = [1/(FileInfo.TACRange*1e9)*FileInfo.MI_Bins, 0.4,3/(FileInfo.TACRange*1e9)*FileInfo.MI_Bins,0.1];
            param = lsqcurvefit(tres_aniso,param0,x,Aniso_fit,[0 -0.4 0 -0.4],[Inf,1,Inf,1]);
        end
        
        fitres = tres_aniso(param,x);
        res = Aniso_fit-fitres;
        
        TACtoTime = 1/FileInfo.MI_Bins*FileInfo.TACRange*1e9;
        %%% Update Plot
        h.Microtime_Plot.Parent = h.HidePanel;
        h.Result_Plot.Parent = h.TauFit_Panel;
        
        h.Plots.DecayResult.XData = x*TACtoTime;
        h.Plots.DecayResult.YData = Aniso_fit;
        h.Plots.FitResult.XData = x*TACtoTime;
        h.Plots.FitResult.YData = fitres;
        axis(h.Result_Plot,'tight');
        h.Result_Plot_Text.Visible = 'on';
        if number_of_exponentials == 1
            str = sprintf('rho = %1.2f ns\nr_0 = %2.2f\nr_{inf} = %3.2f',param(1)*TACtoTime,param(2),param(3));
        elseif number_of_exponentials == 2
            str = sprintf('rho_1 = %1.2f ns\nrho_2 = %1.2f ns\nr_0 = %2.2f\nr_1 = %3.2f',param(1)*TACtoTime,param(3)*TACtoTime,param(2),param(4));
        end
        h.Result_Plot_Text.String = str;
        h.Result_Plot_Text.Position = [0.8 0.9];
        
        h.Plots.Residuals.XData = x*TACtoTime;
        h.Plots.Residuals.YData = res;
        h.Plots.Residuals_ZeroLine.XData = x*TACtoTime;
        h.Plots.Residuals_ZeroLine.YData = zeros(1,numel(x));
        
        h.Result_Plot.XLim(1) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Plots Anisotropy and Fit Single Exponential %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineGFactor(obj,~)
global TauFitData FileInfo
h = guidata(obj);
TauFitData.TACRange = FileInfo.TACRange*1E9;
TauFitData.TACChannelWidth = FileInfo.TACRange*1E9/double(FileInfo.MI_Bins);
%%% Read out the data from the plots
MI = h.Plots.Decay_Par.XData;
Decay_Par = h.Plots.Decay_Par.YData;
Decay_Per = h.Plots.Decay_Per.YData;
%%% Calculate Anisotropy
l1 = 0.03;
l2 = 0.03;
Anisotropy = (Decay_Par-Decay_Per)./((1-3*l1).*Decay_Par + (2-3*l2)*Decay_Per);
%%% Define FitFunction
Fit_Exp = @(p,x) (p(1)-p(3)).*exp(-x./p(2)) + p(3);
%%% perform fit
x0 = [0.4,round(1/TauFitData.TACChannelWidth),0];
lb = [0,0,-0.4];
ub = [0.4,Inf,0.4];
[x,~,res] = lsqcurvefit(Fit_Exp,x0,MI,Anisotropy,lb,ub);
FitFun = Fit_Exp(x,MI);

%%% Update Plots
h.Microtime_Plot.Parent = h.HidePanel;
h.Result_Plot.Parent = h.TauFit_Panel;

%TACtoTime = 1/FileInfo.MI_Bins*FileInfo.TACRange*1e9;
h.Plots.DecayResult.XData = MI;%*TACtoTime;
h.Plots.DecayResult.YData = Anisotropy;
h.Plots.FitResult.XData = MI;%*TACtoTime;
h.Plots.FitResult.YData = FitFun;
axis(h.Result_Plot,'tight');
h.Plots.Residuals.XData = MI;%*TACtoTime;
h.Plots.Residuals.YData = res;
h.Plots.Residuals_ZeroLine.XData = MI;%*TACtoTime;
h.Plots.Residuals_ZeroLine.YData = zeros(1,numel(MI));

%%% calculate G
G = (1-x(3))./(1+2*x(3));
h.Result_Plot_Text.Visible = 'on';
h.Result_Plot_Text.String = sprintf(['rho = ' num2str(x(2)) ' ns \nr_0 = ' num2str(x(1))...
    '\nr_i_n_f = ' num2str(x(3))]);
h.Result_Plot_Text.Position = [0.8*h.Result_Plot.XLim(2) 0.9*h.Result_Plot.YLim(2)];
h.G_factor_edit.String = num2str(G);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Export Graph to figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExportGraph(~,~)
h = guidata(findobj('tag','TauFit'));
fig = figure('Position',[100,100,700,500],'color',[1 1 1]);
panel_copy = copyobj(h.TauFit_Panel,fig);
panel_copy.Position = [0 0 1 1];
panel_copy.ShadowColor = [1 1 1];
%%% set Background Color to white
panel_copy.BackgroundColor = [1 1 1];
ax = panel_copy.Children;
delete(ax(1));ax = ax(2:end);
ax(1).Position = [0.125 0.15 0.825 0.7];
ax(2).Position = [0.125 0.85 0.825 .12];

for i = 1:numel(ax)
    ax(i).Color = [1 1 1];
    ax(i).XColor = [0 0 0];
    ax(i).YColor = [0 0 0];
    ax(i).LineWidth = 3;
    ax(i).FontSize = 20;
end

ax(1).Children(3).FontSize = 20;
ax(1).Children(3).Position(2) = 0.9;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Below here, functions used for the fits start %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cx, tau, offset, csh, z, t, err] = DistFluofit(irf, y, p, dt, shift, flag, bild, N)
% The function DistFluofit performs a fit of a distributed decay curve.
% It is called by: 
% [cx, tau, offset, csh, z, t, err] = DistFluofit(irf, y, p, dt, shift).
% The function arguments are:
% irf 	= 	Instrumental Response Function
% y 	= 	Fluorescence decay data
% p 	= 	Time between laser exciation pulses (in nanoseconds)
% dt 	= 	Time width of one TCSPC channel (in nanoseconds)
% shift	=	boundaries of colorshift in channels
%
% The return parameters are:
% cx	    =	lifetime distribution
% tau       =   used lifetimes
% offset    =	Offset
% csh       =   Color Shift
% z 	    =	Fitted fluorecence curve
% t         =   time axis
% err       =   chi2 value
% 
% The program needs the following m-files: convol.m.
% (c) 2003 J?rg Enderlein

if nargin<6 || isempty(flag)
    flag = 0;
end
if nargin<7 || isempty(bild)
    bild = 1;
end
if bild == 1
    figure;
end
if isempty(irf)
    irf = zeros(size(y));
    irf(1) = 1;
end
irf = irf(:);
y = y(:);
n = length(irf); 
tp = dt*(1:p/dt)';
t = (1:n)';
if nargin<8 || isempty(N)
    N = 100;
end
shifton = 1;
if nargin>4 && ~isempty(shift)
    sh_min = shift(1);
    sh_max = shift(2);
else
    sh_min = -3;
    sh_max = 3;
end

%tau = (1/dt/10)./exp((0:N)/N*log(p/dt/10)); % distribution of decay times
tau = (1/dt)./exp((0:N)/N*log(p/dt)); % distribution of decay times
M0 = [ones(size(t)) convol(irf,exp(-tp*tau))];
M0 = M0./(ones(n,1)*sum(M0));
err = [];

if sh_max-sh_min>0
    for c=sh_min:sh_max
        M = (1-c+floor(c))*M0(rem(rem(t-floor(c)-1, n)+n,n)+1,:) + (c-floor(c))*M0(rem(rem(t-ceil(c)-1, n)+n,n)+1,:);
        ind = max([1,1+c]):min([n,n+c]);
        cx = lsqnonneg(M(ind,:),y(ind));
        z = M*cx;
        err = [err sum((z-y).^2./abs(z))/n];
        err(end);
    end
    
    shv = sh_min:0.1:sh_max;
    tmp = interp1(sh_min:sh_max, err, shv);
    [pos, pos] = min(tmp); 
    csh = shv(pos);
else
    csh = sh_min;
end

M = (1-csh+floor(csh))*M0(rem(rem(t-floor(csh)-1, n)+n,n)+1,:) + (csh-floor(csh))*M0(rem(rem(t-ceil(csh)-1, n)+n,n)+1,:);
c = ceil(abs(csh))*sign(csh);
ind = max([1,1+c]):min([n,n+c]);
cx = lsqnonneg(M(ind,:),y(ind));
z = M*cx;
err = sum((z-y).^2./abs(z))/n;

if bild
    t = dt*t;
    semilogy(t,y,'ob','linewidth',1);
    hold on
    semilogy(t,z,'r','linewidth',2);
    hold off
    
    v = axis;
    v(1) = min(t);
    v(2) = max(t);
    axis(v);
    xlabel('time [ns]');
    ylabel('lg count');
    figure;
    subplot(2,1,1);
    plot(t,(y-z)./sqrt(z)); 
    v = axis;
    v(1) = min(t);
    v(2) = max(t);
    axis(v);
    xlabel('time [ns]');
    ylabel('weighted residual');
    
    ind=1:length(cx)-2;
    len = length(ind);
    tau = 1./tau;
    fac = sqrt(tau(1:end-1)/tau(2:end));
    subplot(2,1,2)
    semilogx(reshape([fac*tau(ind);fac*tau(ind);tau(ind)/fac;tau(ind)/fac],4*len,1),reshape([0*tau(ind);cx(ind+1)';cx(ind+1)';0*tau(ind)],4*len,1));
    patch(reshape([fac*tau(ind);fac*tau(ind);tau(ind)/fac;tau(ind)/fac],4*len,1),reshape([0*tau(ind);cx(ind+1)';cx(ind+1)';0*tau(ind)],4*len,1),'b');

    xlabel('decay time [ns]');
    ylabel('distribution');
end

tau = tau';
offset = cx(1);
cx(1) = [];

if flag>0
    cx = cx';
    tmp = cx>0.1*max(cx);
    t = 1:length(tmp);
    t1 = t(tmp(2:end)>tmp(1:end-1)) + 1;
    t2 = t(tmp(1:end-1)>tmp(2:end));
    if t1(1)>t2(1)
        t2(1)=[];
    end
    if t1(end)>t2(end)
        t1(end)=[];
    end
    if length(t1)==length(t2)+1 
        t1(end)=[]; 
    end
    if length(t2)==length(t1)+1 
        t2(1)=[]; 
    end
    tmp = []; bla = [];
    for j=1:length(t1)
        tmp = [tmp cx(t1(j):t2(j))*tau(t1(j):t2(j))/sum(cx(t1(j):t2(j)))];
        bla = [bla sum(cx(t1(j):t2(j)))];
    end
    cx = bla./tmp;
    cx = cx/sum(cx);
    tau = tmp;
end

function [c, offset, A, tau, dc, dtau, irs, zz, t, chi] = Fluofit(irf, y, p, dt, tau, lim, init)
% The function FLUOFIT performs a fit of a multi-exponential decay curve.
% It is called by: 
% [c, offset, A, tau, dc, doffset, dtau, irs, z, t, chi] = fluofit(irf, y, p, dt, tau, limits, init).
% The function arguments are:
% irf 	= 	Instrumental Response Function
% y 	= 	Fluorescence decay data
% p 	= 	Time between laser exciation pulses (in nanoseconds)
% dt 	= 	Time width of one TCSPC channel (in nanoseconds)
% tau 	= 	Initial guess times
% lim   = 	limits for the lifetimes guess times
% init	=	Whether to use a initial guess routine or not 
%
% The return parameters are:
% c	=	Color Shift (time shift of the IRF with respect to the fluorescence curve)
% offset	=	Offset
% A	    =   Amplitudes of the different decay components
% tau	=	Decay times of the different decay components
% dc	=	Color shift error
% doffset	= 	Offset error
% dtau	=	Decay times error
% irs	=	IRF, shifted by the value of the colorshift
% zz	    Fitted fluorecence component curves
% t     =   time axis
% chi   =   chi2 value
% 
% The program needs the following m-files: simplex.m, lsfit.m, mlfit.m, and convol.m.
% (c) 1996 J?rg Enderlein


fitfun = 'lsfit';

irf = irf(:);
offset = 0;
y = y(:);
n = length(irf); 
if nargin>6
    if isempty(init)
        init = 1;
    end
elseif nargin>4 
    init = 0;
else
    init = 1;
end

if init>0 
    [cx, tau, c, c] = DistFluofit(irf, y, p, dt, [-3 3]);    
    cx = cx(:)';
    tmp = cx>0;
    t = 1:length(tmp);
    t1 = t(tmp(2:end)>tmp(1:end-1)) + 1;
    t2 = t(tmp(1:end-1)>tmp(2:end));
    if length(t1)==length(t2)+1 
        t1(end)=[]; 
    end
    if length(t2)==length(t1)+1 
        t2(1)=[]; 
    end
    if t1(1)>t2(1)
        t1(end)=[]; 
        t2(1)=[];
    end
    tmp = [];
    for j=1:length(t1)
        tmp = [tmp cx(t1(j):t2(j))*tau(t1(j):t2(j))/sum(cx(t1(j):t2(j)))];
    end
    tau = tmp;
else
    c = 0;
end

if (nargin<6)||isempty(lim)
    lim = [zeros(1,length(tau)) 100.*ones(1,length(tau))];
end;

p = p/dt;
tp = (1:p)';
tau = tau(:)'/dt; 
lim_min = lim(1:numel(tau))./dt;
lim_max = lim(numel(tau)+1:end)./dt;
t = 1:length(y);
m = length(tau);
x = exp(-(tp-1)*(1./tau))*diag(1./(1-exp(-p./tau)));
irs = (1-c+floor(c))*irf(rem(rem(t-floor(c)-1, n)+n,n)+1) + (c-floor(c))*irf(rem(rem(t-ceil(c)-1, n)+n,n)+1);
z = convol(irs, x);
z = [ones(size(z,1),1) z];
%A = z\y;
A = lsqnonneg(z,y);
z = z*A;

if init<2
    disp('Fit =                Parameters =');
    param = [c; tau'];
    % Decay times and Offset are assumed to be positive.
    paramin = [-1/dt lim_min];
    paramax = [ 1/dt lim_max];
    [param, dparam] = Simplex(fitfun, param, paramin, paramax, [], [], irf(:), y(:), p);
    c = param(1);
    dc = dparam(1);
    tau = param(2:length(param))';
    dtau = dparam(2:length(param));
    x = exp(-(tp-1)*(1./tau))*diag(1./(1-exp(-p./tau)));
    irs = (1-c+floor(c))*irf(rem(rem(t-floor(c)-1, n)+n,n)+1) + (c-floor(c))*irf(rem(rem(t-ceil(c)-1, n)+n,n)+1);
    z = convol(irs, x);
    z = [ones(size(z,1),1) z];
    z = z./(ones(n,1)*sum(z));
    %A = z\y;
    A = lsqnonneg(z,y);
    zz = z.*(ones(size(z,1),1)*A');
    z = z*A;
    dtau = dtau;
    dc = dt*dc;
else
    dtau = 0;
    dc = 0;
end
%chi = sum((y-z).^2./abs(z))/(n-m);
ignore = 100;
chi = sum((y(ignore:end)-z(ignore:end)).^2./abs(z(ignore:end)))/(n-m-ignore);
t = dt*t;
tau = dt*tau';
c = dt*c;
offset = zz(1,1); 
A(1) = [];
if 1
	hold off
    subplot('position',[0.1 0.4 0.8 0.5])
	plot(t,log10(y),t,log10(irs),t,log10(z));
	v = axis;
	v(1) = min(t);
	v(2) = max(t);
	axis(v);
	xlabel('Time in ns');
	ylabel('Log Count');
	s = sprintf('COF = %3.3f   %3.3f', c, offset);
	text(max(t)/2,v(4)-0.05*(v(4)-v(3)),s);
	s = ['AMP = '];
	for i=1:length(A)
		s = [s sprintf('%1.3f',A(i)/sum(A)) '   '];
	end
	text(max(t)/2,v(4)-0.12*(v(4)-v(3)),s);
	s = ['TAU = '];
	for i=1:length(tau)
		s = [s sprintf('%3.3f',tau(i)) '   '];
	end
	text(max(t)/2,v(4)-0.19*(v(4)-v(3)),s);
    subplot('position',[0.1 0.1 0.8 0.2])
	plot(t,(y-z)./sqrt(abs(z)));
	v = axis;
	v(1) = min(t);
	v(2) = max(t);

    axis(v);
	xlabel('Time in ns');
	ylabel('Residue');
	s = sprintf('%3.3f', chi);
	text(max(t)/2,v(4)-0.1*(v(4)-v(3)),['\chi^2 = ' s]);
    set(gcf,'units','normalized','position',[0.01 0.05 0.98 0.83])
end

function [x, dx, steps] = Simplex(fname, x, xmin, xmax, tol, steps, varargin)

%	[x, dx, steps] = Simplex('F', X0, XMIN, XMAX, TOL, STEPS, VARARGIN) 
%	attempts to return a vector x and its error dx, so that x minimzes the 
%	function F(x) near the starting vector X0 under the conditions that 
% 	xmin <= x <= xmax.
%	TOL is the relative termination tolerance dF/F; (default = 1e-10)
%	STEPS is the maximum number of steps; (default = 200*number of parameters).
%	The returned value of STEPS is the actual number of performed steps. 
%	Simplex allows for up to 10 additional arguments for the function F.
%	Simplex uses a Nelder-Mead simplex search method.

x = x(:);
if nargin<5
	tol = 1e-10;
if nargin<4
		xmax = Inf*ones(length(x),1);
		if nargin<3
			xmin = -Inf*ones(length(x),1);
		end
	end
elseif isempty(tol)
tol = 1e-5;
end
if nargin<6
	steps = [];
end
if isempty(xmin) 
    xmin = -Inf*ones(size(x)); 
end
if isempty(xmax) 
    xmax = Inf*ones(size(x)); 
end
xmin = xmin(:);
xmax = xmax(:);
xmax(xmax<xmin) = xmin(xmax<xmin);
x(x<xmin) = xmin(x<xmin);
x(x>xmax) = xmax(x>xmax);
xfix = zeros(size(x));
tmp = xmin==xmax;
xfix(tmp) = xmin(tmp);
mask = diag(~tmp);
mask(:, tmp) = [];
x(tmp) = [];
xmin(tmp) = [];
xmax(tmp) = [];

if isa(fname,'function_handle')
    fun = fname;
    evalstr = 'fun';
else
    evalstr = fname;
end
evalstr = [evalstr, '(mask*x+xfix'];
if nargin>6
    evalstr = [evalstr, ',varargin{:}'];
end
evalstr = [evalstr, ')'];

n = length(x);
if n==0 
	x = xfix;
	dx = zeros(size(xfix));
	steps = 0;
	return
end
if isempty(steps)
	steps = 200*n;
end

xin = x(:);
%v = 0.9*xin;
v = xin;
v(v<xmin) = xmin(v<xmin);
v(v>xmax) = xmax(v>xmax);
x(:) = v; fv = eval(evalstr); 
for j = 1:n
	y = xin;
    if y(j) ~= 0
        y(j) = (1 +.2*rand)*y(j);
    else
        y(j) = 0.2;
    end
    if y(j)>=xmax(j)
        y(j) = xmax(j);
    end
    if y(j)<=xmin(j)
        y(j) = xmin(j);
    end
    v = [v y];
	x(:) = y; f = eval(evalstr);
	fv = [fv f];
end
[fv, j] = sort(fv);
v = v(:,j);
count = n+1;

% Parameter settings for Nelder-Meade
alpha = 1; beta = 1/2; gamma = 2;

% Begin of Nelder-Meade simplex algorithm
while count < steps
	if 2*abs(fv(n+1)-fv(1))/(abs(fv(1))+abs(fv(n+1))) <= tol
		break
	end

	% Reflection:
	vmean = mean(v(:, 1:n),2);
	vr = (1 + alpha)*vmean - alpha*v(:, n+1);
	x(:) = vr;
	fr = eval(evalstr); 
	count = count + 1; 
	vk = vr; fk = fr;

	if fr < fv(1) && all(xmin<=vr) && all(vr<=xmax)
		% Expansion:
		ve = gamma*vr + (1-gamma)*vmean;
		x(:) = ve;
		fe = eval(evalstr);
		count = count + 1;
		if fe < fv(1) && all(xmin<=ve) && all(ve<=xmax)
			vk = ve; fk = fe;
		end
	else
		vtmp = v(:,n+1); ftmp = fv(n+1);
		if fr < ftmp && all(xmin<=vr) && all(vr<=xmax)
			vtmp = vr; ftmp = fr;
		end
		% Contraction:
		vc = beta*vtmp + (1-beta)*vmean;
		x(:) = vc;
		fc = eval(evalstr); 
		count = count + 1;
		if fc < fv(n) && all(xmin<=vc) && all(vc<=xmax)
			vk = vc; fk = fc;
		else
			% Shrinkage:
			for j = 2:n
				v(:, j) = (v(:, 1) + v(:, j))/2;
				x(:) = v(:, j);
				fv(j) = eval(evalstr); 
			end
			count = count + n-1;
			vk = (v(:, 1) + v(:, n+1))/2;
			x(:) = vk;
			fk = eval(evalstr); 
			count = count + 1;
		end
	end
	v(:, n+1) = vk;
	fv(n+1) = fk;
	[fv, j] = sort(fv);
	v = v(:,j);
end

x = v(:,1);
dx = abs(v(:,n+1)-v(:,1));
x = mask*x + xfix;
dx = mask*dx;
if count>=steps
	disp(['Warning: Maximum number of iterations (', int2str(steps),') has been exceeded']);
else
	steps = count;
end

function a = interlace( a, x, fix )
a(~fix) = x;