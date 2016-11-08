function TauFit(obj,~)
global UserValues
h.TauFit = findobj('Tag','TauFit');
LSUserValues(0);
%%% If called from command line, close
if nargin < 1 && isempty(gcbo)
    Close_TauFit
    disp('Call TauFit from Pam or BurstBrowser instead of command line!');
    return;
    %TauFitData.Who = 'External';
end

if ~isempty(h.TauFit)
    % Close TauFit cause it might be called from somewhere else than before
    Close_TauFit
end
global TauFitData BurstData
if ~isempty(findobj('Tag','Pam'))
    ph = guidata(findobj('Tag','Pam'));
end
if ~isempty(findobj('Tag','BurstBrowser'))
    bh = guidata(findobj('Tag','BurstBrowser'));
end
addpath(genpath(['.' filesep 'functions']));
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
    'OuterPosition',[0.075 0.05 0.85 0.85],...
    'CloseRequestFcn',@Close_TauFit,...
    'KeyPressFcn',@TauFit_KeyPress,...
    'Visible','on');
%%% Sets background of axes and other things
whitebg(Look.Axes);
%%% Changes background; must be called after whitebg
h.TauFit.Color=Look.Back;
%%% Remove unneeded items from toolbar
toolbar = findall(h.TauFit,'Type','uitoolbar');
toolbar_items = findall(toolbar);
delete(toolbar_items([2:7 9 13:17]));
    
%%% menu
h.Menu.File = uimenu(h.TauFit,'Label','File');
h.Menu.OpenDecayData = uimenu(h.Menu.File,'Label','Load decay data (*.dec)',...
    'Callback',@Load_Data);
h.Menu.Export_Menu = uimenu(h.TauFit,'Label','Export...');
h.Menu.Save_To_Txt = uimenu(h.Menu.Export_Menu,'Label','Save Data to *.txt',...
    'Callback',@Export);
h.Compare_Result = uimenu(h.Menu.Export_Menu,'Label','Compare Data...',...
    'Separator','off',...
    'Callback',@Export);
h.Menu.Export_To_Clipboard = uimenu(h.Menu.Export_Menu,'Label','Copy Data to Clipboard',...
    'Callback',@Export,...
    'Separator','on');
h.Menu.Export_MIPattern = uimenu(h.Menu.Export_Menu,'Label','Export fitted microtime pattern',...
    'Callback',@Export);
    


%% Main Fluorescence Decay Plot
%%% Panel containing decay plot and information
h.TauFit_Panel = uibuttongroup(...
    'Parent',h.TauFit,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0.15 0.7 0.85],...
    'Tag','TauFit_Panel');

%%% Right-click menu for plot changes
h.Microtime_Plot_Menu_MIPlot = uicontextmenu;
h.Microtime_Plot_ChangeYScaleMenu_MIPlot = uimenu(...
    h.Microtime_Plot_Menu_MIPlot,...
    'Label','Logscale',...
    'Checked', UserValues.TauFit.YScaleLog,...
    'Tag','Plot_Logscale_MIPlot',...
    'Callback',@ChangeYScale);
h.Microtime_Plot_Export = uimenu(...
    h.Microtime_Plot_Menu_MIPlot,...
    'Label','Export Plot',...
    'Tag','Microtime_Plot_Export',...
    'Callback',@ExportGraph);

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
    'Position',[0.075 0.075 0.9 0.775],...
    'Tag','Microtime_Plot',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'Box','on',...
    'UIContextMenu',h.Microtime_Plot_Menu_MIPlot);

%%% Create Graphs
hold on;
h.Plots.Scat_Par = plot([0 1],[0 0],'LineStyle',':','Color',[0.5 0.5 0.5],'LineWidth',1,'DisplayName','Scatter (par)');
h.Plots.Scat_Per = plot([0 1],[0 0],'LineStyle',':','Color',[0.3 0.3 0.3],'LineWidth',1,'DisplayName','Scatter (perp)');
h.Plots.Decay_Sum = plot([0 1],[0 0],'-k','LineWidth',1,'DisplayName','Decay (sum)');
h.Plots.Decay_Par = plot([0 1],[0 0],'-r','LineWidth',1,'DisplayName','Decay (par)');
h.Plots.Decay_Per = plot([0 1],[0 0],'-b','LineWidth',1,'DisplayName','Decay (perp)');
h.Plots.IRF_Par = plot([0 1],[0 0],'.r','MarkerSize',5,'DisplayName','IRF (par)');
h.Plots.IRF_Per = plot([0 1],[0 0],'.b','MarkerSize',5,'DisplayName','IRF (perp)');
h.Plots.FitPreview = plot([0 1],[0 0],'k','LineWidth',1);
h.Ignore_Plot = plot([0 0],[1e-6 1],'Color','k','Visible','off','LineWidth',1,'DisplayName','Decay (ignore)');
h.Microtime_Plot.XLim = [0 1];
h.Microtime_Plot.YLim = [0 1];
h.Microtime_Plot.XLabel.Color = Look.Fore;
h.Microtime_Plot.XLabel.String = 'Time [ns]';
h.Microtime_Plot.YLabel.Color = Look.Fore;
h.Microtime_Plot.YLabel.String = 'Intensity [counts]';
h.Microtime_Plot.XGrid = 'on';
h.Microtime_Plot.YGrid = 'on';

%%% Residuals Plot
h.Residuals_Plot = axes(...
    'Parent',h.TauFit_Panel,...
    'Units','normalized',...
    'Position',[0.075 0.85 0.9 0.12],...
    'Tag','Residuals_Plot',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'XTickLabel',[],...
    'Box','on');
hold on;
h.Plots.Residuals = plot([0 1],[0 0],'-k','LineWidth',2);
h.Plots.Residuals_ignore = plot([0 1],[0 0],'LineStyle','--','Color',[0.4 0.4 0.4],'Visible','off','LineWidth',2);
h.Plots.Residuals_Perp = plot([0 1],[0 0],'-b','Visible','off','LineWidth',2);
h.Plots.Residuals_Perp_ignore = plot([0 1],[0 0],'LineStyle','--','Color',[0 0 0.4],'Visible','off','LineWidth',2);

h.Plots.Residuals_ZeroLine = plot([0 1],[0 0],'-k','Visible','off','LineWidth',2);
h.Residuals_Plot.YLabel.Color = Look.Fore;
h.Residuals_Plot.YLabel.String = 'w_{res}';
h.Residuals_Plot.XGrid = 'on';
h.Residuals_Plot.YGrid = 'on';

%%% Result Plot (Replaces Microtime Plot after fit is done)
h.Result_Plot = axes(...
    'Parent',h.TauFit_Panel,...
    'Units','normalized',...
    'Position',[0.075 0.075 0.9 0.775],...
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
    'Color',Look.AxesFore,...
    'VerticalAlignment','top','HorizontalAlignment','left');

h.Result_Plot.XLim = [0 1];
h.Result_Plot.YLim = [0 1];
h.Result_Plot.XLabel.Color = Look.Fore;
h.Result_Plot.XLabel.String = 'Time [ns]';
h.Result_Plot.YLabel.Color = Look.Fore;
h.Result_Plot.YLabel.String = 'Intensity [counts]';
h.Result_Plot.XGrid = 'on';
h.Result_Plot.YGrid = 'on';
h.Result_Plot_Text.Position = [0.8 0.9];
hold on;
h.Plots.IRFResult = plot([0 1],[0 0],'LineStyle','none','Marker','.','Color',[0.6 0.6 0.6],'LineWidth',2,'MarkerSize',10,'DisplayName','IRF');
h.Plots.IRFResult_Perp = plot([0 1],[0 0],'LineStyle','none','Marker','.','Color',[0 0 0.6],'Visible','off','LineWidth',2,'MarkerSize',10,'DisplayName','IRF (perp)');
h.Plots.DecayResult = plot([0 1],[0 0],'-k','LineWidth',2,'DisplayName','Decay');
h.Plots.DecayResult_ignore = plot([0 1],[0 0],'LineStyle','--','Color',[0.4 0.4 0.4],'Visible','off','LineWidth',2,'DisplayName','Decay (ignore)');
h.Plots.DecayResult_Perp = plot([0 1],[0 0],'LineStyle','-','Color',[0 0.4471 0.7412],'Visible','off','LineWidth',2,'DisplayName','Decay (perp)');
h.Plots.DecayResult_Perp_ignore = plot([0 1],[0 0],'LineStyle','--','Color',[0 0.2 0.375],'Visible','off','LineWidth',2,'DisplayName','Decay (ignore perp)');
h.Plots.FitResult = plot([0 1],[0 0],'r','LineWidth',2,'DisplayName','Fit');
h.Plots.FitResult_ignore = plot([0 1],[0 0],'--r','Visible','off','LineWidth',2,'DisplayName','Fit (ignore)');
h.Plots.FitResult_Perp = plot([0 1],[0 0],'b','LineWidth',2,'Visible','off','DisplayName','Fit (perp)');
h.Plots.FitResult_Perp_ignore = plot([0 1],[0 0],'--b','Visible','off','LineWidth',2,'DisplayName','Fit (ignore perp)');

%%% Result Plot (Replaces Microtime Plot after fit is done)
h.Result_Plot_Aniso = axes(...
    'Parent',h.TauFit_Panel,...
    'Units','normalized',...
    'Position',[0.075 0.075 0.9 0.775],...
    'Tag','Result_Plot_Aniso',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'Box','on',...
    'Visible','on');

h.Result_Plot_Aniso.XLim = [0 1];
h.Result_Plot_Aniso.YLim = [0 1];
h.Result_Plot_Aniso.XLabel.Color = Look.Fore;
h.Result_Plot_Aniso.XLabel.String = 'Time [ns]';
h.Result_Plot_Aniso.YLabel.Color = Look.Fore;
h.Result_Plot_Aniso.YLabel.String = 'Anisotropy';
h.Result_Plot_Aniso.XGrid = 'on';
h.Result_Plot_Aniso.YGrid = 'on';
hold on;
h.Plots.AnisoResult = plot([0 1],[0 0],'-k','LineWidth',2,'DisplayName','Anisotropy');
h.Plots.AnisoResult_ignore = plot([0 1],[0 0],'LineStyle','--','Color',[0.4 0.4 0.4],'LineWidth',2,'DisplayName','Anisotropy (ignore)');
h.Plots.FitAnisoResult = plot([0 1],[0 0],'-r','LineWidth',2,'DisplayName','Fit');
h.Plots.FitAnisoResult_ignore = plot([0 1],[0 0],'--r','LineWidth',2,'DisplayName','Fit (ignore)');

linkaxes([h.Result_Plot, h.Residuals_Plot],'x');

%%% dummy panel to hide plots
h.HidePanel = uibuttongroup(...
    'Visible','off',...
    'Parent',h.TauFit_Panel,...
    'Tag','HidePanel');

%%% Hide Result Plot and Result Aniso Plot
h.Result_Plot.Parent = h.HidePanel;
h.Result_Plot_Aniso.Parent = h.HidePanel;

if strcmp(h.Microtime_Plot_ChangeYScaleMenu_MIPlot.Checked,'on')
    h.Microtime_Plot.YScale = 'log';
    h.Result_Plot.YScale = 'log';
    h.Result_Plot_Aniso.YScale = 'log';
end
%% Sliders
%%% Define the container
h.Slider_Panel = uibuttongroup(...
    'Parent',h.TauFit,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 0.7 0.15],...
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
    'Position',[0.17 0.825 0.32 0.125],...
    'Tag','StartPar_Slider',...
    'Callback',@Update_Plots);

h.StartPar_Edit = uicontrol(...
    'Parent',h.Slider_Panel,...
    'Style','edit',...
    'Tag','StartPar_Edit',...
    'Units','normalized',...
    'Position',[0.11 0.825 0.05 0.15],...
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
    'String','Start',...
    'TooltipString','Start Value for the Parallel Channel',...
    'Position',[0.01 0.825 0.1 0.15],...
    'Tag','StartPar_Text');

%%% Slider for Selection of Length
h.Length_Slider = uicontrol(...
    'Style','slider',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.17 0.625 0.32 0.125],...
    'Tag','Length_Slider',...
    'Callback',@Update_Plots);

h.Length_Edit = uicontrol(...
    'Parent',h.Slider_Panel,...
    'Style','edit',...
    'Tag','Length_Edit',...
    'Units','normalized',...
    'Position',[0.11 0.625 0.05 0.15],...
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
    'Position',[0.01 0.625 0.1 0.15],...
    'Tag','Length_Text');

%%% Slider for Selection of IRF Length
h.IRFLength_Slider = uicontrol(...
    'Style','slider',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.17 0.425 0.32 0.125],...
    'Tag','IRFLength_Slider',...
    'Callback',@Update_Plots);

h.IRFLength_Edit = uicontrol(...
    'Parent',h.Slider_Panel,...
    'Style','edit',...
    'Tag','IRFLength_Edit',...
    'Units','normalized',...
    'Position',[0.11 0.425 0.05 0.15],...
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
    'Position',[0.01 0.425 0.1 0.15],...
    'Tag','IRFLength_Text');

%%% Slider for Selection of IRF Shift
h.IRFShift_Slider = uicontrol(...
    'Style','slider',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.17 0.225 0.32 0.125],...
    'Tag','IRFShift_Slider',...
    'Callback',@Update_Plots);

h.IRFShift_Edit = uicontrol(...
    'Parent',h.Slider_Panel,...
    'Style','edit',...
    'Tag','IRFShift_Edit',...
    'Units','normalized',...
    'Position',[0.11 0.225 0.05 0.15],...
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
    'Position',[0.01 0.225 0.1 0.15],...
    'Tag','IRFShift_Text');

%%% Slider for Selection of Scat Shift
h.ScatShift_Slider = uicontrol(...
    'Style','slider',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.17 0.025 0.32 0.125],...
    'Tag','ScatShift_Slider',...
    'Callback',@Update_Plots);

h.ScatShift_Edit = uicontrol(...
    'Parent',h.Slider_Panel,...
    'Style','edit',...
    'Tag','ScatShift_Edit',...
    'Units','normalized',...
    'Position',[0.11 0.025 0.05 0.15],...
    'String','0',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'FontSize',10,...
    'Callback',@Update_Plots);

h.ScatShift_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',12,...
    'String','Scat Shift',...
    'TooltipString','Shift of the Scat',...
    'Position',[0.01 0.025 0.1 0.15],...
    'Tag','ScatShift_Text');

%%% Slider for Selection of Perpendicular Shift
h.ShiftPer_Slider = uicontrol(...
    'Style','slider',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.67 0.825 0.32 0.125],...
    'Tag','ShiftPer_Slider',...
    'Callback',@Update_Plots);

h.ShiftPer_Edit = uicontrol(...
    'Parent',h.Slider_Panel,...
    'Style','edit',...
    'Tag','ShiftPer_Edit',...
    'Units','normalized',...
    'Position',[0.61 0.825 0.05 0.15],...
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
    'String','Perp Shift',...
    'TooltipString','Shift of the Perpendicular Channel',...
    'Position',[0.51 0.825 0.1 0.15],...
    'Tag','ShiftPer_Text');

%%% RIGHT SLIDERS %%%
%%% Slider for Selection of Ignore Region in the Beginning
h.Ignore_Slider = uicontrol(...
    'Style','slider',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.67 0.625 0.32 0.125],...
    'Tag','Ignore_Slider',...
    'Callback',@Update_Plots);

h.Ignore_Edit = uicontrol(...
    'Parent',h.Slider_Panel,...
    'Style','edit',...
    'Tag','Ignore_Edit',...
    'Units','normalized',...
    'Position',[0.61 0.625 0.05 0.15],...
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
    'Position',[0.51 0.625 0.1 0.15],...
    'Tag','Ignore_Text');

%%% Slider for Selection of relative IRF Shift
h.IRFrelShift_Slider = uicontrol(...
    'Style','slider',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.67 0.225 0.32 0.125],...
    'Tag','IRFrelShift_Slider',...
    'Callback',@Update_Plots);

h.IRFrelShift_Edit = uicontrol(...
    'Parent',h.Slider_Panel,...
    'Style','edit',...
    'Tag','IRFrelShift_Edit',...
    'Units','normalized',...
    'Position',[0.61 0.225 0.05 0.15],...
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
    'String','Perp IRF Shift',...
    'TooltipString','Shift of the IRF perpendicular with respect to the parallel IRF',...
    'Position',[0.51 0.225 0.1 0.15],...
    'Tag','IRFrelShift_Text');

%%% Slider for Selection of relative Scat Shift
h.ScatrelShift_Slider = uicontrol(...
    'Style','slider',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.67 0.025 0.32 0.125],...
    'Tag','ScatrelShift_Slider',...
    'Callback',@Update_Plots);

h.ScatrelShift_Edit = uicontrol(...
    'Parent',h.Slider_Panel,...
    'Style','edit',...
    'Tag','ScatrelShift_Edit',...
    'Units','normalized',...
    'Position',[0.61 0.025 0.05 0.15],...
    'String','0',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'FontSize',10,...
    'Callback',@Update_Plots);

h.ScatrelShift_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',12,...
    'String','Perp Scat Shift',...
    'TooltipString','Shift of the Scat perpendicular with respect to the parallel Scat',...
    'Position',[0.51 0.025 0.1 0.15],...
    'Tag','ScatrelShift_Text');
%% PIE Channel Selection and general Buttons
h.PIEChannel_Panel = uibuttongroup(...
    'Parent',h.TauFit,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.7 0.7 0.30 0.27],...
    'Tag','PIEChannel_Panel');
%%% Button to determine G-factor
h.Determine_GFactor_Button = uicontrol(...
    'Parent',h.PIEChannel_Panel,...
    'Style','pushbutton',...
    'Tag','Determine_GFactor_Button',...
    'Units','normalized',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.65 0.05 0.29 0.12],...
    'String','Determine G factor',...
    'Callback',@DetermineGFactor);
if exist('ph','var')
    if isobject(obj)
        switch obj
            case ph.Menu.OpenTauFit
                TauFitData.Who = 'TauFit';
                % user called TauFit from Pam
                % fit a lifetime from data in a PIE channel
                %%% Popup menus for PIE Channel Selection
                h.PIEChannelPar_Popupmenu = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'Style','Popupmenu',...
                    'Tag','PIEChannelPar_Popupmenu',...
                    'Units','normalized',...
                    'Position',[0.5 0.85 0.4 0.1],...
                    'String',UserValues.PIE.Name,...
                    'Callback',@Channel_Selection);
                h.PIEChannelPar_Text = uicontrol(...switch
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
                'Distribution','Distribution plus Donor only','Fit Anisotropy',...
                'Fit Anisotropy (2 exp lifetime)','Fit Anisotropy (2 exp rot)',...
                'Fit Anisotropy (2 exp lifetime, 2 exp rot)'};
                %%% Button for loading the selected PIE Channels
                h.LoadData_Button = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'Style','pushbutton',...
                    'Tag','LoadData_Button',...
                    'Units','normalized',...
                    'BackgroundColor', Look.Control,...
                    'ForegroundColor', Look.Fore,...
                    'Position',[0.05 0.55 0.4 0.12],...
                    'String','Import Data from PAM',...
                    'Callback',@Load_Data);
                %%% Button to start fitting
                h.Fit_Button = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'Style','pushbutton',...
                    'Tag','Fit_Button',...
                    'Units','normalized',...
                    'BackgroundColor', Look.Control,...
                    'ForegroundColor', Look.Fore,...
                    'Position',[0.3 0.25 0.6 0.12],...
                    'String','Start reconvolution fit',...
                    'Callback',@Start_Fit);
                %%% Button to start tail fitting
                h.Fit_Tail_Button = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'Style','pushbutton',...
                    'Tag','Fit_Tail_Button',...
                    'Units','normalized',...
                    'BackgroundColor', Look.Control,...
                    'ForegroundColor', Look.Fore,...
                    'Position',[0.05 0.05 0.29 0.12],...
                    'String','Start tail fit',...
                    'Callback',@Start_Fit);
                h.Fit_Tail_Menu = uicontextmenu;
                h.Fit_Tail_2exp = uimenu('Parent',h.Fit_Tail_Menu,...
                    'Label','2 exponentials',...
                    'Checked','off',...
                    'Callback',@Start_Fit);
                h.Fit_Tail_3exp = uimenu('Parent',h.Fit_Tail_Menu,...
                    'Label','3 exponentials',...
                    'Checked','off',...
                    'Callback',@Start_Fit);
                h.Fit_Tail_Button.UIContextMenu = h.Fit_Tail_Menu;
                %%% Button to fit Time resolved anisotropy
                h.Fit_Aniso_Button = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'Style','pushbutton',...
                    'Tag','Fit_Button',...
                    'Units','normalized',...
                    'BackgroundColor', Look.Control,...
                    'ForegroundColor', Look.Fore,...
                    'Position',[0.35 0.05 0.29 0.12],...
                    'String','Fit anisotropy',...
                    'Callback',@Start_Fit);
                h.Fit_Aniso_Menu = uicontextmenu;
                h.Fit_Aniso_2exp = uimenu('Parent',h.Fit_Aniso_Menu,...
                    'Label','2 exponentials',...
                    'Checked','off',...
                    'Callback',@Start_Fit);
                h.Fit_Aniso_Button.UIContextMenu = h.Fit_Aniso_Menu;
            case {ph.Burst.BurstLifetime_Button, ph.Burst.Button}
                TauFitData.Who = 'Burstwise';
                %%% User Clicks Burstwise Lifetime button in Pam, Burst 
                %%% Analysis button in Pam with lifetime checkbox checked or 
                %%% Burst Analysis on database tab in Pam, with lifetime
                %%% checkbox checked
                h.ChannelSelect_Text = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'Style','Text',...
                    'Tag','ChannelSelect_Text',...
                    'Units','normalized',...
                    'Position',[0.05 0.85 0.4 0.1],...
                    'BackgroundColor', Look.Back,...
                    'ForegroundColor', Look.Fore,...
                    'HorizontalAlignment','left',...
                    'FontSize',12,...
                    'String','Select Channel',...
                    'ToolTipString','Selection of Channel');%%% Popup menus for PIE Channel Selection
                switch BurstData.BAMethod
                    case {1,2,5}
                        Channel_String = {'GG','RR'};
                    case {3,4}
                        Channel_String = {'BB','GG','RR'};
                end
                h.ChannelSelect_Popupmenu = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'Style','Popupmenu',...
                    'Tag','ChannelSelect_Popupmenu',...
                    'Units','normalized',...
                    'Position',[0.5 0.85 0.4 0.1],...
                    'String',Channel_String,...
                    'Value', 1,...
                    'Callback',@Update_Plots);
                %%% Popup Menu for Fit Method Selection
                h.FitMethods = {'Single Exponential','Biexponential'};
                %%% checkbox for background estimate inclusion
                h.BackgroundInclusion_checkbox = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'Style','checkbox',...
                    'Tag','BackgroundInclusion_checkbox',...
                    'Units','normalized',...
                    'BackgroundColor', Look.Back,...
                    'ForegroundColor', Look.Fore,...
                    'Position',[0.05 0.6 0.75 0.1],...
                    'String','Use background estimation',...
                    'ToolTipString','Includes a static scatter contribution into the fit. The contribution is estimated from background countrate and burst duration.',...
                    'Value',1,...
                    'Callback',[]);
                %%% checkbox to include the channel in lifetime fitting
                h.IncludeChannel_checkbox = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'Style','checkbox',...
                    'Tag','IncludeChannel_checkbox',...
                    'Units','normalized',...
                    'BackgroundColor', Look.Back,...
                    'ForegroundColor', Look.Fore,...
                    'Position',[0.55 0.6 0.75 0.1],...
                    'String','fit channel',...
                    'ToolTipString','Include the channel during burstwise fitting.',...
                    'Value',UserValues.TauFit.IncludeChannel(1),...
                    'Callback',@IncludeChannel);
                %%% Button tostart fitting
                h.BurstWiseFit_Button = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'Style','pushbutton',...
                    'Tag','BurstWiseFit_Button',...
                    'Units','normalized',...
                    'BackgroundColor', Look.Control,...
                    'ForegroundColor', Look.Fore,...
                    'Position',[0.05 0.05 0.5 0.12],...
                    'String','Burstwise Fit',...
                    'ToolTipString','Start the burstwise fitting (sliders should be correct!',...
                    'Callback',@BurstWise_Fit);
                %%% Button to start fitting
                h.Fit_Button = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'Style','pushbutton',...
                    'Tag','Fit_Button',...
                    'Units','normalized',...
                    'BackgroundColor', Look.Control,...
                    'ForegroundColor', Look.Fore,...
                    'Position',[0.05 0.2 0.5 0.12],...
                    'String','Pre-Fit',...
                    'Callback',@Start_Fit);
                %%% hide the ignore slider, we don't need it for burstwise fitting
                set([h.Ignore_Slider,h.Ignore_Edit,h.Ignore_Text],'Visible','off');
                for i = 1:3
                    UserValues.TauFit.Ignore{i} = 1;
                end
                set(h.Determine_GFactor_Button,'Visible','off');
                %%% add checkbox for saving images of fit arrangement
                h.Save_Figures = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'style','checkbox',...
                    'units','normalized',...
                    'BackgroundColor', Look.Back,...
                    'ForegroundColor', Look.Fore,...
                    'Callback',@UpdateOptions,...
                    'String','Auto-save images of plots',...
                    'Value',UserValues.BurstSearch.BurstwiseLifetime_SaveImages,...
                    'Position',[0.55,0.05,0.5,0.12]);
        end
    end
end
if exist('bh','var')
    if bh.SendToTauFit.equals(obj) || obj == bh.Send_to_TauFit_Button
        TauFitData.Who = 'BurstBrowser';
        global BurstMeta
        % User clicked Send Species to TauFit in BurstBrowser
        % fit a lifetime to the bulk data from selected bursts
        %%% display which species user transferred to TauFit
        h.ChannelSelect_Text = uicontrol(...
            'Parent',h.PIEChannel_Panel,...
            'Style','Text',...
            'Tag','ChannelSelect_Text',...
            'Units','normalized',...
            'Position',[0.05 0.85 0.4 0.1],...
            'BackgroundColor', Look.Back,...
            'ForegroundColor', Look.Fore,...
            'HorizontalAlignment','left',...
            'FontSize',12,...
            'String','Select Channel',...
            'ToolTipString','Selection of Channel');%%% Popup menus for PIE Channel Selection
        switch BurstData{BurstMeta.SelectedFile}.BAMethod
            case {1,2,5}
                Channel_String = {'GG','RR','GR'};
            case {3,4}
                Channel_String = {'BB','GG','RR'};
        end
        h.ChannelSelect_Popupmenu = uicontrol(...
            'Parent',h.PIEChannel_Panel,...
            'Style','Popupmenu',...
            'Tag','ChannelSelect_Popupmenu',...
            'Units','normalized',...
            'Position',[0.5 0.85 0.4 0.1],...
            'String',Channel_String,...
            'Value', 1,...
            'Callback',@Update_Plots);
        
        str = ['Selected File: ' BurstData{BurstMeta.SelectedFile}.FileName(1:end-4)];
        if BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1) ~= 0
            TauFitData.SpeciesName = BurstData{BurstMeta.SelectedFile}.SpeciesNames{BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1),1};
            if BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) > 1 %%% subspecies selected
                TauFitData.SpeciesName = [TauFitData.SpeciesName ' - ' BurstData{BurstMeta.SelectedFile}.SpeciesNames{BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1),BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2)}];
            end
            str = [str, '\nSelected Species: ' TauFitData.SpeciesName];
        else
            TauFitData.SpeciesName = BurstData{BurstMeta.SelectedFile}.FileName(1:end-4);
        end
        h.SpeciesSelect_Text = uicontrol('Style','text',...
            'Tag','TauFit_SpeciesSelect_text',...
            'Parent',h.PIEChannel_Panel,...
            'Units','normalized',...
            'Position',[0.05 0.55 0.8 0.25],...
            'HorizontalAlignment','left',...
            'String',sprintf(str),...
            'BackgroundColor',Look.Back,...
            'ForegroundColor',Look.Fore,...
            'FontSize',12);
        %%% Popup Menu for Fit Method Selection
        h.FitMethods = {'Single Exponential','Biexponential','Three Exponentials',...
            'Distribution','Distribution plus Donor only','Fit Anisotropy',...
            'Fit Anisotropy (2 exp lifetime)','Fit Anisotropy (2 exp rot)',...
            'Fit Anisotropy (2 exp lifetime, 2 exp rot)'};
        %%% Button to start fitting
        h.Fit_Button = uicontrol(...
            'Parent',h.PIEChannel_Panel,...
            'Style','pushbutton',...
            'Tag','Fit_Button',...
            'Units','normalized',...
            'BackgroundColor', Look.Control,...
            'ForegroundColor', Look.Fore,...
            'Position',[0.3 0.25 0.6 0.12],...
            'String','Start reconvolution fit',...
            'Callback',@Start_Fit);
        %%% Button to start tail fitting
        h.Fit_Tail_Button = uicontrol(...
            'Parent',h.PIEChannel_Panel,...
            'Style','pushbutton',...
            'Tag','Fit_Tail_Button',...
            'Units','normalized',...
            'BackgroundColor', Look.Control,...
            'ForegroundColor', Look.Fore,...
            'Position',[0.05 0.05 0.29 0.12],...
            'String','Start tail fit',...
            'Callback',@Start_Fit);
        h.Fit_Tail_Menu = uicontextmenu;
        h.Fit_Tail_2exp = uimenu('Parent',h.Fit_Tail_Menu,...
            'Label','2 exponentials',...
            'Checked','off',...
            'Callback',@Start_Fit);
        h.Fit_Tail_3exp = uimenu('Parent',h.Fit_Tail_Menu,...
            'Label','3 exponentials',...
            'Checked','off',...
            'Callback',@Start_Fit);
        h.Fit_Tail_Button.UIContextMenu = h.Fit_Tail_Menu;
        %%% Button to fit Time resolved anisotropy
        h.Fit_Aniso_Button = uicontrol(...
            'Parent',h.PIEChannel_Panel,...
            'Style','pushbutton',...
            'Tag','Fit_Button',...
            'Units','normalized',...
            'BackgroundColor', Look.Control,...
            'ForegroundColor', Look.Fore,...
            'Position',[0.35 0.05 0.35 0.12],...
            'String','Fit anisotropy',...
            'Callback',@Start_Fit);
        h.Fit_Aniso_Menu = uicontextmenu;
        h.Fit_Aniso_2exp = uimenu('Parent',h.Fit_Aniso_Menu,...
            'Label','2 exponentials',...
            'Checked','off',...
            'Callback',@Start_Fit);
        h.Fit_Aniso_Button.UIContextMenu = h.Fit_Aniso_Menu;
        
        set(h.Determine_GFactor_Button,'Visible','off');
        
        if any(TauFitData.BAMethod == [1,2])
            %%% Add menu for Kappa2 simulation
            h.Menu.Extra_Menu = uimenu(h.TauFit,'Label','Extra...');
            h.Menu.Sim_Kappa2_Menu = uimenu(h.Menu.Extra_Menu,'Label','Simulate Kappa2 distribution','Callback',@Kappa2_Sim);
        end
    end
end
h.FitMethod_Popupmenu = uicontrol(...
    'Parent',h.PIEChannel_Panel,...
    'Style','Popupmenu',...
    'Tag','FitMethod_Popupmenu',...
    'Units','normalized',...
    'Position',[0.3 0.4 0.6 0.095],...
    'String',h.FitMethods,...
    'Callback',@Method_Selection);

h.FitMethod_Text = uicontrol(...
    'Parent',h.PIEChannel_Panel,...
    'Style','Text',...
    'Tag','FitMethod_Text',...
    'Units','normalized',...
    'Position',[0.05 0.4 0.2 0.095],...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',12,...
    'String','Fit Method',...
    'ToolTipString','Select the Fit Method');

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
    'Position',[0.7 0.97 0.3 0.03]);
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
    'Position',[0.7 0 0.3 0.7]);

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
    'Position',[0 0.2 1 0.8],...
    'ColumnName',{'Value','LB','UB','Fixed'},...
    'ColumnFormat',{'numeric','numeric','numeric','logical'},...
    'RowName',{'Test'},...
    'ColumnEditable',[true true true true],...
    'ColumnWidth',{50,50,50,40},...
    'Tag','FitPar_Table',...
    'CellEditCallBack',@Update_Plots,...
    'BackgroundColor', [Look.Table1;Look.Table2],...
    'ForegroundColor', Look.TableFore);
%%% Get the values of the table and the RowNames from UserValues
[h.FitPar_Table.Data, h.FitPar_Table.RowName] = GetTableData(1, 1);

%%% Edit Boxes for Correction Factors
h.G_factor_text = uicontrol(...
    'Parent',h.FitPar_Panel,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.01 0.125 0.15 0.03],...
    'String','G Factor',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Tag','G_factor_text');

h.G_factor_edit = uicontrol(...
    'Parent',h.FitPar_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.17 0.125 0.2 0.03],...
    'String','1',...
    'FontSize',12,...
    'Tag','G_factor_edit',...
    'Callback',@UpdateOptions);

if any(strcmp(TauFitData.Who,{'Burstwise','BurstBrowser'}))
    h.G_factor_edit.String = num2str(UserValues.TauFit.G{1});
end

h.l1_text = uicontrol(...
    'Parent',h.FitPar_Panel,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.01 0.075 0.15 0.03],...
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
    'Position',[0.17 0.075 0.2 0.03],...
    'String',num2str(UserValues.TauFit.l1),...
    'FontSize',12,...
    'Tag','l1_edit',...
    'Callback',@UpdateOptions);

h.l2_text = uicontrol(...
    'Parent',h.FitPar_Panel,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.01 0.025 0.15 0.03],...
    'String','l2',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Tag','l2_text',...
    'Callback',@UpdateOptions);

h.l2_edit = uicontrol(...
    'Parent',h.FitPar_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.17 0.025 0.2 0.03],...
    'String',num2str(UserValues.TauFit.l2),...
    'FontSize',12,...
    'Tag','l2_edit');

h.Output_Panel = uibuttongroup(...
    'Parent',h.FitPar_Panel,...
    'Units','normalized',...
    'Position',[0.4 0 0.6 0.195],...
    'Title','Status message',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Tag','Output_Panel');

h.Output_Text = uicontrol(...
    'Parent',h.Output_Panel,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'String','',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Tag','Output_Text');
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
    'Position',[0.4 0.9 0.5 0.07],...
    'String',{'linear','circular'},...
    'Value',find(strcmp({'linear','circular'},UserValues.TauFit.ConvolutionType)),...
    'Tag','ConvolutionType_Menu');
h.AutoFit_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.05 0.7 0.7 0.05],...
    'String','Automatic fit',...
    'FontSize',12,...
    'Tag','AutoFit_Menu',...
    'Callback',@Update_Plots);
h.NormalizeScatter_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.05 0.5 0.65 0.05],...
    'String','Scatter offset = 0',...
    'FontSize',12,...
    'Tag','NormalizeScatter_Menu',...
    'Callback',@Update_Plots);

h.UseWeightedResiduals_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.05 0.3 0.6 0.05],...
    'String','Use weighted residuals',...
    'Value',UserValues.TauFit.use_weighted_residuals,...
    'FontSize',12,...
    'Tag','UseWeightedResiduals_Menu',...
    'Callback',@UpdateOptions);
%% Special case for Burstwise and noMFD
if any(strcmp(TauFitData.Who,{'Burstwise','BurstBrowser'}))
    switch TauFitData.Who
        case 'Burstwise'
            BAMethod = BurstData.BAMethod;
        case 'BurstBrowser'
            BAMethod = BurstData{BurstMeta.SelectedFile}.BAMethod;
    end
    if BAMethod == 5 %noMFD, hide respective GUI elements
        set([h.ShiftPer_Edit,h.ShiftPer_Slider,h.ShiftPer_Text,...
            h.IRFrelShift_Edit,h.IRFrelShift_Slider,h.IRFrelShift_Text,...
            h.ScatrelShift_Edit,h.ScatrelShift_Slider,h.ScatrelShift_Text,...
            h.Determine_GFactor_Button,h.l1_edit, h.l1_text,h.l2_edit,h.l2_text,...
            h.G_factor_edit, h.G_factor_text],...
            'Visible','off');
        %%% also set shift values ins UserValues of polarization sliders to 0
        %%% and G factor to 1, l1 and l2 to 0
        for i = 1:3
            UserValues.TauFit.ShiftPer{i} = 0;
            UserValues.TauFit.IRFrelShift{i} = 0;
            UserValues.TauFit.ScatrelShift{i} = 0;
            UserValues.TauFit.Ignore{i} = 1;
            UserValues.TauFit.G{i} = 1;
        end
        UserValues.TauFit.l1 = 0;
        UserValues.TauFit.l2 = 0;
    end
end
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
%% Initialize values
for i = 1:3 %max number of pairs for fitting
    TauFitData.Length{i} = UserValues.TauFit.Length{i};
    TauFitData.StartPar{i} = UserValues.TauFit.StartPar{i};
    TauFitData.ShiftPer{i} = UserValues.TauFit.ShiftPer{i};
    TauFitData.IRFLength{i} = UserValues.TauFit.IRFLength{i};
    TauFitData.IRFShift{i} = UserValues.TauFit.IRFShift{i};
    TauFitData.IRFrelShift{i} = UserValues.TauFit.IRFrelShift{i};
    TauFitData.ScatShift{i} = UserValues.TauFit.ScatShift{i};
    TauFitData.ScatrelShift{i} = UserValues.TauFit.ScatrelShift{i};
    TauFitData.Ignore{i} = UserValues.TauFit.Ignore{i};
end
TauFitData.FitType = h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value};
TauFitData.FitMethods = h.FitMethods;

guidata(gcf,h);

% If data is ready to be displayed, display it
% (user sent data from burstbrowser or wants to do a burstwise fitting)
if ~strcmp(TauFitData.Who, 'TauFit') && ~strcmp(TauFitData.Who, 'External')
    Update_Plots(obj)
end

if strcmp(TauFitData.Who,'BurstBrowser')
    h.Menu.File.Visible = 'off';
end
% If burstwise fitting is performed, we don't need the export menu
if strcmp(TauFitData.Who,'Burstwise')
    h.Menu.Export_Menu.Visible = 'off';
    h.Menu.File.Visible = 'off';
else
    % set method to stored method
    h.FitMethod_Popupmenu.Value = UserValues.TauFit.FitMethod;
    Method_Selection(h.FitMethod_Popupmenu,[]);
end

%%% User clicked 'Burst Analysis' button on the Burst or Batch analysis tab 
%%% when 'Fit Lifetime' checkbox was checked.
if exist('ph','var')
    if isobject(obj)
        switch obj
            case ph.Burst.Button 
                BurstWise_Fit(ph.Burst.Button,[])
                close(h.TauFit);
        end
    end
end

function ChangeYScale(obj,~)
global UserValues
h = guidata(obj);
if strcmp(obj.Checked,'off')
    %%% Set Checked
    h.Microtime_Plot_ChangeYScaleMenu_MIPlot.Checked = 'on';
    h.Microtime_Plot_ChangeYScaleMenu_ResultPlot.Checked = 'on';
    %%% Change Scale to Log
    h.Microtime_Plot.YScale = 'log';
    h.Result_Plot.YScale = 'log';
    UserValues.TauFit.YScaleLog = 'on';
elseif strcmp(obj.Checked,'on')
    %%% Set Unchecked
    h.Microtime_Plot_ChangeYScaleMenu_MIPlot.Checked = 'off';
    h.Microtime_Plot_ChangeYScaleMenu_ResultPlot.Checked = 'off';
    %%% Change Scale to Lin
    h.Microtime_Plot.YScale = 'lin';
    h.Result_Plot.YScale = 'lin';
    UserValues.TauFit.YScaleLog = 'off';
end

if strcmp(h.Microtime_Plot.YScale,'log')
    ydat = [h.Plots.IRF_Par.YData,h.Plots.IRF_Per.YData,...
        h.Plots.Scat_Par.YData, h.Plots.Scat_Per.YData,...
        h.Plots.Decay_Par.YData,h.Plots.Decay_Per.YData];
    ydat = ydat(ydat > 0);
    h.Ignore_Plot.YData = [...
        min(ydat),...
        h.Microtime_Plot.YLim(2)];
else
    h.Ignore_Plot.YData = [...
        0,...
        h.Microtime_Plot.YLim(2)];
end
LSUserValues(1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Load Data Button (TauFit raw PIE channel data) %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Data(obj,~)
global UserValues TauFitData FileInfo TcspcData PamMeta
h = guidata(findobj('Tag','TauFit'));

%%% check how we got here
if obj == h.Menu.OpenDecayData || strcmp(TauFitData.Who, 'External')
    if obj == h.Menu.OpenDecayData
        %%% called upon loading of text-based *.dec file
        %%% load file
        [FileName, PathName, FilterIndex] = uigetfile({'*.dec','PAM decay file'},'Choose data file...',UserValues.File.TauFitPath,'Multiselect','off');
        if FilterIndex == 0
            return;
        end
        UserValues.File.TauFitPath = PathName;
        
        decay_data = dlmread(fullfile(PathName,FileName),'\t',6,0);
        %%% read other data
        fid = fopen(fullfile(PathName,FileName),'r');
        TAC = textscan(fid,'TAC range [ns]:\t%f\n'); TauFitData.TACRange = TAC{1}*1E-9;
        MI_Bins = textscan(fid,'Microtime Bins:\t%f\n'); TauFitData.MI_Bins = MI_Bins{1};
        TACChannelWidth = textscan(fid,'Resolution [ps]:\t%f\n'); TauFitData.TACChannelWidth = TACChannelWidth{1}*1E-3;
        fid = fopen(fullfile(PathName,FileName),'r');
        for i = 1:5
            line = fgetl(fid);
        end
        PIEchans = strsplit(line,'\t');
        PIEchans(cellfun(@isempty,PIEchans)) = [];
        %%% sort data into TauFitData structure (MI,IRF,Scat)
        for i = 1:(size(decay_data,2)/3)
            TauFitData.External.MI_Hist{i} = decay_data(:,3*(i-1)+1);
            TauFitData.External.IRF{i} = decay_data(:,3*(i-1)+2);
            TauFitData.External.Scat{i} = decay_data(:,3*(i-1)+3);
        end
        %%% update PIE channel selection with available PIE channels
        h.PIEChannelPar_Popupmenu.String = PIEchans;
        h.PIEChannelPer_Popupmenu.String = PIEchans;
        %%% show file name in GUI

        %%% mark TauFit mode as external
        TauFitData.Who = 'External';

        if numel(PIEchans) == 1
            PIEChannel_Par = 1; PIEChannel_Per = 1;
        else
            PIEChannel_Par = 1; PIEChannel_Per = 2;
        end
        h.PIEChannelPar_Popupmenu.Value = PIEChannel_Par;
        h.PIEChannelPer_Popupmenu.Value = PIEChannel_Per;
    elseif obj == h.LoadData_Button
        PIEChannel_Par = h.PIEChannelPar_Popupmenu.Value;
        PIEChannel_Per = h.PIEChannelPer_Popupmenu.Value;
    end
    %%% set the channel variable
    chan = 4; TauFitData.chan = chan;
    
    %%% Microtime Histograms
    TauFitData.hMI_Par{chan} = TauFitData.External.MI_Hist{PIEChannel_Par};
    TauFitData.hMI_Per{chan} = TauFitData.External.MI_Hist{PIEChannel_Per};
    
    ToFromPar = find(TauFitData.hMI_Par{chan}>0,1,'first'):find(TauFitData.hMI_Par{chan}>0,1,'last');
    ToFromPer = find(TauFitData.hMI_Per{chan}>0,1,'first'):find(TauFitData.hMI_Per{chan}>0,1,'last');
    TauFitData.hMI_Par{chan} = TauFitData.hMI_Par{chan}(ToFromPar);
    TauFitData.hMI_Per{chan} = TauFitData.hMI_Per{chan}(ToFromPer);
    %%% Read out the Microtime Histograms of the IRF for the two channels
    TauFitData.hIRF_Par{chan} = TauFitData.External.IRF{PIEChannel_Par}(ToFromPar)';
    TauFitData.hIRF_Per{chan} = TauFitData.External.IRF{PIEChannel_Per}(ToFromPer)';
    %%% Normalize IRF for better Visibility
    TauFitData.hIRF_Par{chan} = (TauFitData.hIRF_Par{chan}./max(TauFitData.hIRF_Par{chan})).*max(TauFitData.hMI_Par{chan});
    TauFitData.hIRF_Per{chan} = (TauFitData.hIRF_Per{chan}./max(TauFitData.hIRF_Per{chan})).*max(TauFitData.hMI_Per{chan});
    %%% Read out the Microtime Histograms of the Scatter Measurement for the two channels
    TauFitData.hScat_Par{chan} = TauFitData.External.Scat{PIEChannel_Par}(ToFromPar);
    TauFitData.hScat_Per{chan} = TauFitData.External.Scat{PIEChannel_Per}(ToFromPer);
    %%% Normalize Scatter for better Visibility
    if ~(sum(TauFitData.hScat_Par{chan})==0)
        TauFitData.hScat_Par{chan} = (TauFitData.hScat_Par{chan}./max(TauFitData.hScat_Par{chan})).*max(TauFitData.hMI_Par{chan});
    end
    if ~(sum(TauFitData.hScat_Per{chan})==0)
        TauFitData.hScat_Per{chan} = (TauFitData.hScat_Per{chan}./max(TauFitData.hScat_Per{chan})).*max(TauFitData.hMI_Per{chan});
    end
    %%% Generate XData
    TauFitData.XData_Par{chan} = ToFromPar - ToFromPar(1);
    TauFitData.XData_Per{chan} = ToFromPer - ToFromPer(1);
    
    %%% Update PIEchannelSelection
    UserValues.TauFit.PIEChannelSelection{1} = h.PIEChannelPar_Popupmenu.String{h.PIEChannelPar_Popupmenu.Value};
    UserValues.TauFit.PIEChannelSelection{2} = h.PIEChannelPer_Popupmenu.String{h.PIEChannelPer_Popupmenu.Value};
    
    h.LoadData_Button.String = 'Plot Selection';
else %%% clicked Load Data button, load from PAM
    % Load Data button was pressed
    % User called TauFit from Pam
    try
    TauFitData.TACRange = FileInfo.TACRange; % in seconds
    catch %%% This occurs when user loads Fabsurf file from Waldi
       % ask for TACrange, default is 40
       TauFitData.TACRange = str2double(inputdlg({'TAC Range in ns:'},'Please provide the TAC Range',1,{'40'}));
    end
    TauFitData.MI_Bins = FileInfo.MI_Bins;
    if ~isfield(FileInfo,'Resolution')
        % in nanoseconds/microtime bin
        TauFitData.TACChannelWidth = TauFitData.TACRange*1E9/TauFitData.MI_Bins;
    elseif isfield(FileInfo,'Resolution') %%% HydraHarp Data
        TauFitData.TACChannelWidth = FileInfo.Resolution/1000;
    end

    TauFitData.FileName = fullfile(FileInfo.Path, FileInfo.FileName{1}); %only the first filename is stored!

    %%% Cases to consider:
    %%% obj is empty or is Button for LoadData/LoadIRF
    %%% Data has been changed (PIE Channel changed, IRF loaded...)
    if isempty(obj) || obj == h.LoadData_Button
        %%% find the number of the selected PIE channels
        PIEChannel_Par = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{1}));
        PIEChannel_Per = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{2}));
        % compare PIE channel selection to burst search selections for
        % consistency between burstwise/ensemble
        % (String comparison does not require correct ordering of PIE channels)
        if any(UserValues.BurstSearch.Method == [1,2]) %2color MFD
            if (strcmp(UserValues.TauFit.PIEChannelSelection{1},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(1,1)) &&...
                    strcmp(UserValues.TauFit.PIEChannelSelection{2},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(1,2)))
                chan = 1;
            elseif (strcmp(UserValues.TauFit.PIEChannelSelection{1},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(3,1)) &&...
                    strcmp(UserValues.TauFit.PIEChannelSelection{2},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(3,2)))
                chan = 2;
            elseif strcmp(UserValues.TauFit.PIEChannelSelection{1},UserValues.TauFit.PIEChannelSelection{2})
                %%% identical channels selected
                chan = 5;
            else %%% Set channel to 4 if no MFD channel was selected
                chan = 4;
            end
        elseif any(UserValues.BurstSearch.Method== [3,4]) %3color MFD
            if (strcmp(UserValues.TauFit.PIEChannelSelection{1},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(1,1)) &&...
                    strcmp(UserValues.TauFit.PIEChannelSelection{2},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(1,2)))
                chan = 1;
            elseif (strcmp(UserValues.TauFit.PIEChannelSelection{1},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(4,1)) &&...
                    strcmp(UserValues.TauFit.PIEChannelSelection{2},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(4,2)))
                chan = 2;
            elseif (strcmp(UserValues.TauFit.PIEChannelSelection{1},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(6,1)) &&...
                    strcmp(UserValues.TauFit.PIEChannelSelection{2},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(6,2)))
                chan = 3;
            elseif strcmp(UserValues.TauFit.PIEChannelSelection{1},UserValues.TauFit.PIEChannelSelection{2})
                %%% identical channels selected
                chan = 5;
            else %%% Set channel to 4 if no MFD channel was selected
                chan = 4;
            end
        end
        % old method:
    %     % PIE Channels have to be ordered correctly 
    %     if any(UserValues.BurstSearch.Method == [1,2]) %2color MFD
    %         if PIEChannel_Par+PIEChannel_Per == 3
    %             chan = 1;
    %         elseif PIEChannel_Par+PIEChannel_Per == 11
    %             chan = 2;
    %         else %%% Set channel to 4 if no MFD channel was selected
    %             chan = 4;
    %         end
    %     elseif any(UserValues.BurstSearch.Method== [3,4]) %3color MFD
    %         if PIEChannel_Par+PIEChannel_Per == 3
    %             chan = 1;
    %         elseif PIEChannel_Par+PIEChannel_Per == 15
    %             chan = 2;
    %         elseif PIEChannel_Par+PIEChannel_Per == 23
    %             chan = 3;
    %         else %%% Set channel to 4 if no MFD channel was selected
    %             chan = 4;
    %         end
    %     end
        TauFitData.chan = chan;
        %%% Read out Photons and Histogram
    %     MI_Par = histc( TcspcData.MI{UserValues.PIE.Detector(PIEChannel_Par),UserValues.PIE.Router(PIEChannel_Par)},...
    %         0:(TauFitData.MI_Bins-1));
    %     MI_Per = histc( TcspcData.MI{UserValues.PIE.Detector(PIEChannel_Per),UserValues.PIE.Router(PIEChannel_Per)},...
    %         0:(TauFitData.MI_Bins-1));
    %     %%% Compute the Microtime Histograms
    %     % the data will be assigned to the appropriate channel, such that the
    %     % slider values are universal between TauFit, Burstwise Taufit and Bulk Burst Taufit
    %     TauFitData.hMI_Par{chan} = MI_Par(UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]));
    %     TauFitData.hMI_Per{chan} = MI_Per(UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]));

        %%% find the detector of the parallel PIE channel (PamMeta.MI_Hist is defined using the "detectors" defined in PAM, so we need to map back)
        detPar = find( (UserValues.Detector.Det == UserValues.PIE.Detector(PIEChannel_Par)) & (UserValues.Detector.Rout == UserValues.PIE.Router(PIEChannel_Par)));
        detPer = find( (UserValues.Detector.Det == UserValues.PIE.Detector(PIEChannel_Per)) & (UserValues.Detector.Rout == UserValues.PIE.Router(PIEChannel_Per)));
        %%% Microtime Histogram of Parallel Channel
        TauFitData.hMI_Par{chan} = PamMeta.MI_Hist{detPar(1)}(...
            UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]) );
        %%% Microtime Histogram of Perpendicular Channel
        TauFitData.hMI_Per{chan} = PamMeta.MI_Hist{detPer(1)}(...
            UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]) );

        %%% Read out the Microtime Histograms of the IRF for the two channels
        TauFitData.hIRF_Par{chan} = UserValues.PIE.IRF{PIEChannel_Par}(UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]));
        TauFitData.hIRF_Per{chan} = UserValues.PIE.IRF{PIEChannel_Per}(UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]));
        %%% Normalize IRF for better Visibility
        TauFitData.hIRF_Par{chan} = (TauFitData.hIRF_Par{chan}./max(TauFitData.hIRF_Par{chan})).*max(TauFitData.hMI_Par{chan});
        TauFitData.hIRF_Per{chan} = (TauFitData.hIRF_Per{chan}./max(TauFitData.hIRF_Per{chan})).*max(TauFitData.hMI_Per{chan});
        %%% Read out the Microtime Histograms of the Scatter Measurement for the two channels
        TauFitData.hScat_Par{chan} = UserValues.PIE.ScatterPattern{PIEChannel_Par}(UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]));
        TauFitData.hScat_Per{chan} = UserValues.PIE.ScatterPattern{PIEChannel_Per}(UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]));
        %%% Normalize Scatter for better Visibility
        TauFitData.hScat_Par{chan} = (TauFitData.hScat_Par{chan}./max(TauFitData.hScat_Par{chan})).*max(TauFitData.hMI_Par{chan});
        TauFitData.hScat_Per{chan} = (TauFitData.hScat_Per{chan}./max(TauFitData.hScat_Per{chan})).*max(TauFitData.hMI_Per{chan});
        %%% Generate XData
        TauFitData.XData_Par{chan} = (UserValues.PIE.From(PIEChannel_Par):UserValues.PIE.To(PIEChannel_Par)) - UserValues.PIE.From(PIEChannel_Par);
        TauFitData.XData_Per{chan} = (UserValues.PIE.From(PIEChannel_Per):UserValues.PIE.To(PIEChannel_Per)) - UserValues.PIE.From(PIEChannel_Per);
    end 
end
%%% disable some GUI elements of the same channel is used twice, i.e. no
%%% polarized detection
if strcmp(UserValues.TauFit.PIEChannelSelection{1},UserValues.TauFit.PIEChannelSelection{2})
    set([h.ShiftPer_Edit,h.ShiftPer_Text,h.ShiftPer_Slider,...%%% perp sliders
        h.ScatrelShift_Edit,h.ScatrelShift_Text,h.ScatrelShift_Slider,...
        h.IRFrelShift_Edit,h.IRFrelShift_Text,h.IRFrelShift_Slider,...
        h.Fit_Aniso_Button,h.Determine_GFactor_Button,...%%% anisotropy related buttons
        h.G_factor_edit,h.G_factor_text,...
        h.l1_edit,h.l1_text,...
        h.l2_edit,h.l2_text],'Visible','off'); 
    %%% set l1 and l2 to zero
    h.l1_edit.String = '0';
    h.l2_edit.String = '0';
    %%% set G to 1
    UserValues.TauFit.G{chan} = 1;
    h.G_factor_edit.String = '1';
    %%% set perp sliders/edit to zero
    UserValues.TauFit.ShiftPer{chan} = 0;
    TauFitData.ShiftPer{chan} = 0;
    h.ShiftPer_Edit.String = '0';
    h.ShiftPer_Slider.Value = 0;
    UserValues.TauFit.IRFrelShift{chan} = 0;
    TauFitData.IRFrelShift{chan} = 0;
    h.IRFrelShift_Edit.String = '0';
    h.IRFrelShift_Slider.Value = 0;
    UserValues.TauFit.ScatrelShift{chan} = 0;
    TauFitData.ScatrelShift{chan} = 0;
    h.ScatrelShift_Edit.String = '0';
    h.ScatrelShift_Slider.Value = 0;
    %%% disable anisotropy fit methods
    if h.FitMethod_Popupmenu.Value > 5
        h.FitMethod_Popupmenu.Value = 1;
    end
    h.FitMethod_Popupmenu.String = h.FitMethods(1:5);
else
    set([h.ShiftPer_Edit,h.ShiftPer_Text,h.ShiftPer_Slider,...%%% perp sliders
        h.ScatrelShift_Edit,h.ScatrelShift_Text,h.ScatrelShift_Slider,...
        h.IRFrelShift_Edit,h.IRFrelShift_Text,h.IRFrelShift_Slider,...
        h.Fit_Aniso_Button,h.Determine_GFactor_Button,...%%% anisotropy related buttons
        h.G_factor_edit,h.G_factor_text,...
        h.l1_edit,h.l1_text,...
        h.l2_edit,h.l2_text],'Visible','on'); 
    %%% reenable polarization correction factors
    h.l1_edit.String = num2str(UserValues.TauFit.l1);
    h.l2_edit.String = num2str(UserValues.TauFit.l2);
    h.G_factor_edit.String = num2str(UserValues.TauFit.G{chan});
    %%% set perp sliders/edit to zero
    TauFitData.ShiftPer{chan} = UserValues.TauFit.ShiftPer{chan};
    h.ShiftPer_Edit.String = num2str(UserValues.TauFit.ShiftPer{chan});
    h.ShiftPer_Slider.Value = UserValues.TauFit.ShiftPer{chan};
    TauFitData.IRFrelShift{chan} = UserValues.TauFit.IRFrelShift{chan};
    h.IRFrelShift_Edit.String = num2str(UserValues.TauFit.IRFrelShift{chan});
    h.IRFrelShift_Slider.Value = UserValues.TauFit.IRFrelShift{chan};
    TauFitData.ScatrelShift{chan} = UserValues.TauFit.ScatrelShift{chan};
    h.ScatrelShift_Edit.String = num2str(UserValues.TauFit.ScatrelShift{chan});
    h.ScatrelShift_Slider.Value = UserValues.TauFit.ScatrelShift{chan};
    %%% reenable anisotropy fit methods
    h.FitMethod_Popupmenu.String = h.FitMethods;
end
Update_Plots(obj)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  General Function to Update Plots when something changed %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(obj,~)
global UserValues TauFitData
h = guidata(findobj('Tag','TauFit'));

if strcmp(TauFitData.Who, 'Burstwise')
    % if burstwise fitting is done, user is not allowed to normalize the
    % constant offset of the scatter pattern
    h.NormalizeScatter_Menu.Value = 0;
    h.IncludeChannel_checkbox.Value = UserValues.TauFit.IncludeChannel(h.ChannelSelect_Popupmenu.Value);
end

% How did we get here?
if ~strcmp(TauFitData.Who, 'TauFit') && ~strcmp(TauFitData.Who, 'External')
    % Burstwise lifetime and Burstbrowser subensembe TCSPC
    chan = h.ChannelSelect_Popupmenu.Value;
else
    chan = TauFitData.chan;
end

if ~isprop(obj, 'Style')
    dummy = '';
else
    dummy = obj.Style;
end

if obj == h.FitPar_Table
    dummy = 'table';
    
end
% nanoseconds per microtime bin
TACtoTime = 1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;

if isempty(obj) || strcmp(dummy,'pushbutton') || strcmp(dummy,'popupmenu') || isempty(dummy)
    %LoadData button or Burstwise lifetime button was pressed
    %%% Plot the Data
    % anders, Should data be plotted at this point?
    h.Plots.Decay_Par.XData = TauFitData.XData_Par{chan}*TACtoTime;
    h.Plots.Decay_Per.XData = TauFitData.XData_Per{chan}*TACtoTime;
    h.Plots.IRF_Par.XData = TauFitData.XData_Par{chan}*TACtoTime;
    h.Plots.IRF_Per.XData = TauFitData.XData_Per{chan}*TACtoTime;
    h.Plots.Scat_Par.XData = TauFitData.XData_Par{chan}*TACtoTime;
    h.Plots.Scat_Per.XData = TauFitData.XData_Per{chan}*TACtoTime;
    h.Plots.Decay_Par.YData = TauFitData.hMI_Par{chan};
    h.Plots.Decay_Per.YData = TauFitData.hMI_Per{chan};
    h.Plots.IRF_Par.YData = TauFitData.hIRF_Par{chan};
    h.Plots.IRF_Per.YData = TauFitData.hIRF_Per{chan};
    h.Plots.Scat_Par.YData = TauFitData.hScat_Par{chan};
    h.Plots.Scat_Per.YData = TauFitData.hScat_Per{chan};
    h.Microtime_Plot.XLim = [min([TauFitData.XData_Par{chan}*TACtoTime TauFitData.XData_Per{chan}*TACtoTime]) max([TauFitData.XData_Par{chan}*TACtoTime TauFitData.XData_Per{chan}*TACtoTime])];
    try
        h.Microtime_Plot.YLim = [min([TauFitData.hMI_Par{chan}; TauFitData.hMI_Per{chan}]) 10/9*max([TauFitData.hMI_Par{chan}; TauFitData.hMI_Per{chan}])];
    catch
        % if there is no data, disable channel and stop
        h.IncludeChannel_checkbox.Value = 0;
        UserValues.TauFit.IncludeChannel(h.ChannelSelect_Popupmenu.Value) = 0;
        LSUserValues(1);
        return
    end
    %%% Define the Slider properties
    %%% Values to consider:
    %%% The length of the shortest PIE channel
    TauFitData.MaxLength{chan} = min([numel(TauFitData.hMI_Par{chan}) numel(TauFitData.hMI_Per{chan})]);
    
    %%% The Length Slider defaults to the length of the shortest PIE
    %%% channel and should not assume larger values
    h.Length_Slider.Min = 1;
    h.Length_Slider.Max = TauFitData.MaxLength{chan};
    if UserValues.TauFit.Length{chan} > 0 && UserValues.TauFit.Length{chan} < TauFitData.MaxLength{chan}+1
        tmp = UserValues.TauFit.Length{chan};
    else
        tmp = TauFitData.MaxLength{chan};
    end
    h.Length_Slider.Value = tmp;
    TauFitData.Length{chan} = tmp;
    h.Length_Edit.String = num2str(tmp);
    
    %%% Start Parallel Slider can assume values from 0 (no shift) up to the
    %%% length of the shortest PIE channel minus the set length
    h.StartPar_Slider.Min = 0;
    h.StartPar_Slider.Max = floor(TauFitData.MaxLength{chan}/5);
    if UserValues.TauFit.StartPar{chan} >= 0 && UserValues.TauFit.StartPar{chan} <= floor(TauFitData.MaxLength{chan}/5)
        tmp = UserValues.TauFit.StartPar{chan};
    else
        tmp = 0;
    end
    h.StartPar_Slider.Value = tmp;
    TauFitData.StartPar{chan} = tmp;
    h.StartPar_Edit.String = num2str(tmp);
    
    %%% Shift Perpendicular Slider can assume values from the difference in
    %%% start point between parallel and perpendicular up to the difference
    %%% between the end point of the parallel channel and the start point
    %%% of the perpendicular channel
    h.ShiftPer_Slider.Min = -floor(TauFitData.MaxLength{chan}/20);
    h.ShiftPer_Slider.Max = floor(TauFitData.MaxLength{chan}/20);
    if UserValues.TauFit.ShiftPer{chan} >= -floor(TauFitData.MaxLength{chan}/20)...
            && UserValues.TauFit.ShiftPer{chan} <= floor(TauFitData.MaxLength{chan}/20)
        tmp = UserValues.TauFit.ShiftPer{chan};
    else
        tmp = 0;
    end
    h.ShiftPer_Slider.Value = tmp;
    TauFitData.ShiftPer{chan} = tmp;
    h.ShiftPer_Edit.String = num2str(tmp);
    
    %%% IRF Length has the same limits as the Length property
    h.IRFLength_Slider.Min = 1;
    h.IRFLength_Slider.Max = TauFitData.MaxLength{chan};
    if UserValues.TauFit.IRFLength{chan} >= 0 && UserValues.TauFit.IRFLength{chan} <= TauFitData.MaxLength{chan}
        tmp = UserValues.TauFit.IRFLength{chan};
    else
        tmp = TauFitData.MaxLength{chan};
    end
    h.IRFLength_Slider.Value = tmp;
    TauFitData.IRFLength{chan} = tmp;
    h.IRFLength_Edit.String = num2str(tmp);
    
    %%% IRF Shift has the same limits as the perp shift property
    h.IRFShift_Slider.Min = -floor(TauFitData.MaxLength{chan}/20);
    h.IRFShift_Slider.Max = floor(TauFitData.MaxLength{chan}/20);
    if UserValues.TauFit.IRFShift{chan} >= -floor(TauFitData.MaxLength{chan}/20)...
            && UserValues.TauFit.IRFShift{chan} <= floor(TauFitData.MaxLength{chan}/20)
        tmp = UserValues.TauFit.IRFShift{chan};
    else
        tmp = 0;
    end
    h.IRFShift_Slider.Value = tmp;
    TauFitData.IRFShift{chan} = tmp;
    h.IRFShift_Edit.String = num2str(tmp);
    
    %%% IRF rel. Shift has the same limits as the perp shift property
    h.IRFrelShift_Slider.Min = -floor(TauFitData.MaxLength{chan}/20);
    h.IRFrelShift_Slider.Max = floor(TauFitData.MaxLength{chan}/20);
    if UserValues.TauFit.IRFrelShift{chan} >= -floor(TauFitData.MaxLength{chan}/20)...
            && UserValues.TauFit.IRFrelShift{chan} <= floor(TauFitData.MaxLength{chan}/20)
        tmp = UserValues.TauFit.IRFrelShift{chan};
    else
        tmp = 0;
    end
    h.IRFrelShift_Slider.Value = tmp;
    TauFitData.IRFrelShift{chan} = tmp;
    h.IRFrelShift_Edit.String = num2str(tmp);
    
    %%% Scat Shift has the same limits as the perp shift property
    h.ScatShift_Slider.Min = -floor(TauFitData.MaxLength{chan}/20);
    h.ScatShift_Slider.Max = floor(TauFitData.MaxLength{chan}/20);
    if UserValues.TauFit.ScatShift{chan} >= -floor(TauFitData.MaxLength{chan}/20)...
            && UserValues.TauFit.ScatShift{chan} <= floor(TauFitData.MaxLength{chan}/20)
        tmp = UserValues.TauFit.ScatShift{chan};
    else
        tmp = 0;
    end
    h.ScatShift_Slider.Value = tmp;
    TauFitData.ScatShift{chan} = tmp;
    h.ScatShift_Edit.String = num2str(tmp);
    
    %%% Scat rel. Shift has the same limits as the perp shift property
    h.ScatrelShift_Slider.Min = -floor(TauFitData.MaxLength{chan}/20);
    h.ScatrelShift_Slider.Max = floor(TauFitData.MaxLength{chan}/20);
    if UserValues.TauFit.ScatrelShift{chan} >= -floor(TauFitData.MaxLength{chan}/20)...
            && UserValues.TauFit.ScatrelShift{chan} <= floor(TauFitData.MaxLength{chan}/20)
        tmp = UserValues.TauFit.ScatrelShift{chan};
    else
        tmp = 0;
    end
    h.ScatrelShift_Slider.Value = tmp;
    TauFitData.ScatrelShift{chan} = tmp;
    h.ScatrelShift_Edit.String = num2str(tmp);
    
    %%% Ignore Slider reaches from 1 to maximum length
    h.Ignore_Slider.Min = 1;
    h.Ignore_Slider.Max = floor(TauFitData.MaxLength{chan}/10);
    if UserValues.TauFit.Ignore{chan} >= 1 && UserValues.TauFit.Ignore{chan} <= floor(TauFitData.MaxLength{chan}/10)
        tmp = UserValues.TauFit.Ignore{chan};
    else
        tmp = 1;
    end
    h.Ignore_Slider.Value = tmp;
    TauFitData.Ignore{chan} = tmp;
    h.Ignore_Edit.String = num2str(tmp);
    
    % when the popup has changed, the table has to be updated with the
    % UserValues data
    h.FitPar_Table.Data = GetTableData(h.FitMethod_Popupmenu.Value, chan);
    % G factor is channel specific
    h.G_factor_edit.String = UserValues.TauFit.G{chan};
end

%%% Update Slider Values
if isobject(obj) % check if matlab object
    switch obj
        case {h.StartPar_Slider, h.StartPar_Edit}
            if obj == h.StartPar_Slider
                TauFitData.StartPar{chan} = floor(obj.Value);
            elseif obj == h.StartPar_Edit
                TauFitData.StartPar{chan} = str2double(obj.String);
            end
        case {h.Length_Slider, h.Length_Edit}
            %%% Update Value
            if obj == h.Length_Slider
                TauFitData.Length{chan} = floor(obj.Value);
            elseif obj == h.Length_Edit
                TauFitData.Length{chan} = str2double(obj.String);
            end
            %%% Correct if IRFLength exceeds the Length
            if TauFitData.IRFLength{chan} > TauFitData.Length{chan}
                TauFitData.IRFLength{chan} = TauFitData.Length{chan};
            end
        case {h.ShiftPer_Slider, h.ShiftPer_Edit}
            %%% Update Value
            if obj == h.ShiftPer_Slider
                TauFitData.ShiftPer{chan} = floor(obj.Value);
            elseif obj == h.ShiftPer_Edit
                TauFitData.ShiftPer{chan} = str2double(obj.String);
            end
        case {h.IRFLength_Slider, h.IRFLength_Edit}
            %%% Update Value
            if obj == h.IRFLength_Slider
                TauFitData.IRFLength{chan} = floor(obj.Value);
            elseif obj == h.IRFLength_Edit
                TauFitData.IRFLength{chan} = str2double(obj.String);
            end
            %%% Correct if IRFLength exceeds the Length
            if TauFitData.IRFLength{chan} > TauFitData.Length{chan}
                TauFitData.IRFLength{chan} = TauFitData.Length{chan};
            end
        case {h.IRFShift_Slider, h.IRFShift_Edit}
            %%% Update Value
            if obj == h.IRFShift_Slider
                TauFitData.IRFShift{chan} = floor(obj.Value);
            elseif obj == h.IRFShift_Edit
                TauFitData.IRFShift{chan} = str2double(obj.String);
            end
        case {h.IRFrelShift_Slider, h.IRFrelShift_Edit}
            %%% Update Value
            if obj == h.IRFrelShift_Slider
                TauFitData.IRFrelShift{chan} = floor(obj.Value);
            elseif obj == h.IRFrelShift_Edit
                TauFitData.IRFrelShift{chan} = str2double(obj.String);
            end
        case {h.ScatShift_Slider, h.ScatShift_Edit}
            %%% Update Value
            if obj == h.ScatShift_Slider
                TauFitData.ScatShift{chan} = floor(obj.Value);
            elseif obj == h.ScatShift_Edit
                TauFitData.ScatShift{chan} = str2double(obj.String);
            end
        case {h.ScatrelShift_Slider, h.ScatrelShift_Edit}
            %%% Update Value
            if obj == h.ScatrelShift_Slider
                TauFitData.ScatrelShift{chan} = floor(obj.Value);
            elseif obj == h.ScatrelShift_Edit
                TauFitData.ScatrelShift{chan} = str2double(obj.String);
            end
        case {h.Ignore_Slider,h.Ignore_Edit}%%% Update Value
            if obj == h.Ignore_Slider
                TauFitData.Ignore{chan} = floor(obj.Value);
            elseif obj == h.Ignore_Edit
                if obj.Value <  1
                    TauFitData.Ignore{chan} = 1;
                    obj.String = '1';
                else
                    TauFitData.Ignore{chan} = str2double(obj.String);
                end
            end
        case {h.FitPar_Table}
            TauFitData.IRFShift{chan} = obj.Data{end,1};
            %%% Update Edit Box and Slider when user changes value in the table
            h.IRFShift_Edit.String = num2str(TauFitData.IRFShift{chan});
            h.IRFShift_Slider.Value = TauFitData.IRFShift{chan}; 
    end
end
%%% Update Edit Boxes if Slider was used and Sliders if Edit Box was used
if isprop(obj,'Style')
    switch obj.Style
        case 'slider'
            h.StartPar_Edit.String = num2str(TauFitData.StartPar{chan});
            h.Length_Edit.String = num2str(TauFitData.Length{chan});
            h.ShiftPer_Edit.String = num2str(TauFitData.ShiftPer{chan});
            h.IRFLength_Edit.String = num2str(TauFitData.IRFLength{chan});
            h.IRFShift_Edit.String = num2str(TauFitData.IRFShift{chan});
            h.IRFrelShift_Edit.String = num2str(TauFitData.IRFrelShift{chan});
            h.ScatShift_Edit.String = num2str(TauFitData.ScatShift{chan});
            h.ScatrelShift_Edit.String = num2str(TauFitData.ScatrelShift{chan});
            h.FitPar_Table.Data{end,1} = TauFitData.IRFShift{chan};
            h.Ignore_Edit.String = num2str(TauFitData.Ignore{chan});
        case 'edit'
            h.StartPar_Slider.Value = TauFitData.StartPar{chan};
            h.Length_Slider.Value = TauFitData.Length{chan};
            h.ShiftPer_Slider.Value = TauFitData.ShiftPer{chan};
            h.IRFLength_Slider.Value = TauFitData.IRFLength{chan};
            h.IRFShift_Slider.Value = TauFitData.IRFShift{chan};
            h.IRFrelShift_Slider.Value = TauFitData.IRFrelShift{chan};
            h.ScatShift_Slider.Value = TauFitData.ScatShift{chan};
            h.ScatrelShift_Slider.Value = TauFitData.ScatrelShift{chan};
            h.FitPar_Table.Data{end,1} = TauFitData.IRFShift{chan};
            h.Ignore_Slider.Value = TauFitData.Ignore{chan};
    end
    UserValues.TauFit.StartPar{chan} = TauFitData.StartPar{chan};
    UserValues.TauFit.Length{chan} = TauFitData.Length{chan};
    UserValues.TauFit.ShiftPer{chan} = TauFitData.ShiftPer{chan};
    UserValues.TauFit.IRFLength{chan} = TauFitData.IRFLength{chan};
    UserValues.TauFit.IRFShift{chan} = TauFitData.IRFShift{chan};
    UserValues.TauFit.IRFrelShift{chan} = TauFitData.IRFrelShift{chan};
    UserValues.TauFit.ScatShift{chan} = TauFitData.ScatShift{chan};
    UserValues.TauFit.ScatrelShift{chan} = TauFitData.ScatrelShift{chan};
    UserValues.TauFit.Ignore{chan} = TauFitData.Ignore{chan};
    LSUserValues(1);
end
%%% Update Plot
%%% Make the Microtime Adjustment Plot Visible, hide Result
h.Microtime_Plot.Parent = h.TauFit_Panel;
h.Result_Plot.Parent = h.HidePanel;
h.Result_Plot_Aniso.Parent = h.HidePanel;

%%% hide wres plot
set([h.Plots.Residuals,h.Plots.Residuals_ignore,h.Plots.Residuals_Perp,h.Plots.Residuals_Perp_ignore],'Visible','off');
%%% Apply the shift to the parallel channel
% if you change something here, change it too in Start_BurstWise Fit!
h.Plots.Decay_Par.XData = ((TauFitData.StartPar{chan}:(TauFitData.Length{chan}-1)) - TauFitData.StartPar{chan})*TACtoTime;
h.Plots.Decay_Par.YData = TauFitData.hMI_Par{chan}((TauFitData.StartPar{chan}+1):TauFitData.Length{chan})';
%%% Apply the shift to the perpendicular channel
h.Plots.Decay_Per.XData = ((TauFitData.StartPar{chan}:(TauFitData.Length{chan}-1)) - TauFitData.StartPar{chan})*TACtoTime;
tmp = circshift(TauFitData.hMI_Per{chan},[TauFitData.ShiftPer{chan},0])';
h.Plots.Decay_Per.YData = tmp((TauFitData.StartPar{chan}+1):TauFitData.Length{chan});
%%% Apply the shift to the parallel IRF channel
h.Plots.IRF_Par.XData = ((TauFitData.StartPar{chan}:(TauFitData.IRFLength{chan}-1)) - TauFitData.StartPar{chan})*TACtoTime;
tmp = circshift(TauFitData.hIRF_Par{chan},[0,TauFitData.IRFShift{chan}])';
h.Plots.IRF_Par.YData = tmp((TauFitData.StartPar{chan}+1):TauFitData.IRFLength{chan});
%%% Apply the shift to the perpendicular IRF channel
h.Plots.IRF_Per.XData = ((TauFitData.StartPar{chan}:(TauFitData.IRFLength{chan}-1)) - TauFitData.StartPar{chan})*TACtoTime;
tmp = circshift(TauFitData.hIRF_Per{chan},[0,TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan}])';
h.Plots.IRF_Per.YData = tmp((TauFitData.StartPar{chan}+1):TauFitData.IRFLength{chan});
%%% Apply the shift to the parallel Scat channel
h.Plots.Scat_Par.XData = ((TauFitData.StartPar{chan}:(TauFitData.Length{chan}-1)) - TauFitData.StartPar{chan})*TACtoTime;
tmp = circshift(TauFitData.hScat_Par{chan},[0,TauFitData.ScatShift{chan}])';
if h.NormalizeScatter_Menu.Value
    % since the scatter pattern should not contain background, we subtract the constant offset
    maxscat = max(tmp);
    %subtract the constant offset and renormalize the amplitude to what it was
    tmp = (tmp-mean(tmp(end-floor(TauFitData.MI_Bins/50):end)));
    tmp = tmp/max(tmp)*maxscat;
    %tmp(tmp < 0) = 0;
end
h.Plots.Scat_Par.YData = tmp((TauFitData.StartPar{chan}+1):TauFitData.Length{chan});
%%% Apply the shift to the perpendicular Scat channel
h.Plots.Scat_Per.XData = ((TauFitData.StartPar{chan}:(TauFitData.Length{chan}-1)) - TauFitData.StartPar{chan})*TACtoTime;
tmp = circshift(TauFitData.hScat_Per{chan},[0,TauFitData.ScatShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.ScatrelShift{chan}])';
tmp = tmp((TauFitData.StartPar{chan}+1):TauFitData.Length{chan});
if h.NormalizeScatter_Menu.Value
    % since the scatter pattern should not contain background, we subtract the constant offset
    maxscat = max(tmp);
    tmp = tmp-mean(tmp(end-floor(TauFitData.MI_Bins/50):end));
    tmp = tmp/max(tmp)*maxscat;
    %tmp(tmp < 0) = 0;
end
h.Plots.Scat_Per.YData = tmp;
axes(h.Microtime_Plot);xlim([h.Plots.Decay_Par.XData(1),h.Plots.Decay_Par.XData(end)]);
%%% Update Ignore Plot
if TauFitData.Ignore{chan} > 1
    %%% Make plot visible
    h.Ignore_Plot.Visible = 'on';
    h.Ignore_Plot.XData = [TauFitData.Ignore{chan}*TACtoTime TauFitData.Ignore{chan}*TACtoTime];
    if strcmp(h.Microtime_Plot.YScale,'log')
        ydat = [h.Plots.IRF_Par.YData,h.Plots.IRF_Per.YData,...
            h.Plots.Scat_Par.YData, h.Plots.Scat_Per.YData,...
            h.Plots.Decay_Par.YData,h.Plots.Decay_Per.YData];
        ydat = ydat(ydat > 0);
        h.Ignore_Plot.YData = [...
            min(ydat),...
            h.Microtime_Plot.YLim(2)];
    else
        h.Ignore_Plot.YData = [...
            0,...
            h.Microtime_Plot.YLim(2)];
    end
elseif TauFitData.Ignore{chan} == 1
    %%% Hide Plot Again
    h.Ignore_Plot.Visible = 'off';
end
if h.AutoFit_Menu.Value
    Start_Fit(h.Fit_Button)
end
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Saves the changed PIEChannel Selection to UserValues %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Channel_Selection(obj,~)
global UserValues TauFitData
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
LSUserValues(1);
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
delete(findobj('Tag','TauFit'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Executes on Method selection change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Method_Selection(obj,~)
global TauFitData UserValues
TauFitData.FitType = obj.String{obj.Value};
%%% Update FitTable
h = guidata(obj);
if ~strcmp(TauFitData.Who, 'TauFit') && ~strcmp(TauFitData.Who, 'External')
    % Burstwise lifetime and Burstbrowser subensembe TCSPC
    chan = h.ChannelSelect_Popupmenu.Value;
else
    if isfield(TauFitData,'chan')
        chan = TauFitData.chan;
    else %default to 1
        chan = 1;
    end 
end
[h.FitPar_Table.Data, h.FitPar_Table.RowName] = GetTableData(obj.Value, chan);

%%% Update UserValues
if ~strcmp(TauFitData.Who,'Burstwise')
    UserValues.TauFit.FitMethod = obj.Value;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Fit the PIE Channel data or Subensemble (Burst) TCSPC %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Start_Fit(obj,~)
global TauFitData UserValues
h = guidata(findobj('Tag','TauFit'));
if ~strcmp(TauFitData.Who, 'TauFit') && ~strcmp(TauFitData.Who, 'External')
    % Burstwise lifetime and Burstbrowser subensembe TCSPC
    chan = h.ChannelSelect_Popupmenu.Value;
else
    chan = TauFitData.chan;
end
h.Result_Plot_Text.Visible = 'off';
h.Output_Text.String = '';
h.Plots.Residuals.Visible = 'on';
%% Prepare FitData
TauFitData.FitData.Decay_Par = h.Plots.Decay_Par.YData;
TauFitData.FitData.Decay_Per = h.Plots.Decay_Per.YData;

G = str2double(h.G_factor_edit.String);%UserValues.TauFit.G{chan};
l1 = str2double(h.l1_edit.String);
l2 = str2double(h.l2_edit.String);
Conv_Type = h.ConvolutionType_Menu.String{h.ConvolutionType_Menu.Value};
%TauFitData.FitData.IRF_Par = h.Plots.IRF_Par.YData;
%TauFitData.FitData.IRF_Per = h.Plots.IRF_Per.YData;

%%% Read out the shifted scatter pattern
% anders, why don't we just take the YData of the Scatter plot and avoid having to put the shifts in here again?
% anders, does the order of the circshift operation matter?
% anders, also, why does the fit function have to include the range
% selection for the scatter
% ScatterPar = TauFitData.hScat_Par{chan}(1:TauFitData.Length{chan});
% ScatterPar = circshift(ScatterPar,[0,TauFitData.ScatShift{chan}]);
% ScatterPer = TauFitData.hScat_Per{chan}(1:TauFitData.Length{chan});
% ScatterPer = circshift(ScatterPer,[0,TauFitData.ScatShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.ScatrelShift{chan}]);
% ScatterPattern = ScatterPar + 2*ScatterPer;
ScatterPattern = h.Plots.Scat_Par.YData + 2*h.Plots.Scat_Per.YData;
if ~(sum(ScatterPattern) == 0)
    ScatterPattern = ScatterPattern'./sum(ScatterPattern);
else
    ScatterPattern = ScatterPattern';
end
%%% Don't Apply the IRF Shift here, it is done in the FitRoutine using the
%%% total Scatter Pattern to avoid Edge Effects when using circshift!
IRFPer = circshift(TauFitData.hIRF_Per{chan},[0,TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan}]);
IRFPattern = TauFitData.hIRF_Par{chan}(1:TauFitData.Length{chan}) + 2*IRFPer(1:TauFitData.Length{chan});
IRFPattern = IRFPattern'./sum(IRFPattern);

%%% additional processing of the IRF to remove constant background
IRFPattern = IRFPattern - mean(IRFPattern(end-round(numel(IRFPattern)/10):end)); IRFPattern(IRFPattern<0) = 0;
%%% The IRF is also adjusted in the Fit dynamically from the total scatter
%%% pattern and start,length, and shift values stored in ShiftParams -
%%% anders, please update the above statements to what they really is
%%% ShiftParams(1)  :   StartPar
%%% ShiftParams(2)  :   IRFShift
%%% ShiftParams(3)  :   IRFLength
ShiftParams(1) = TauFitData.StartPar{chan};
ShiftParams(2) = TauFitData.IRFShift{chan};
ShiftParams(3) = TauFitData.Length{chan};
ShiftParams(4) = TauFitData.IRFLength{chan};
%ShiftParams(5) = TauFitData.ScatShift{chan}; %anders, please see if I correctly introduced the scatshift in the models

%%% initialize inputs for fit
Decay = G*(1-3*l2)*TauFitData.FitData.Decay_Par+(2-3*l1)*TauFitData.FitData.Decay_Per;
Length = numel(Decay);
%%% Check if IRFshift is fixed or not
if h.FitPar_Table.Data{end,4} == 0
    %%% IRF is not fixed
    irf_lb = h.FitPar_Table.Data{end,2};
    irf_ub = h.FitPar_Table.Data{end,3};
    shift_range = floor(TauFitData.IRFShift{chan} + irf_lb):ceil(TauFitData.IRFShift{chan} + irf_ub);%irf_lb:irf_ub; 
elseif h.FitPar_Table.Data{end,4} == 1
    shift_range = TauFitData.IRFShift{chan};
end
ignore = TauFitData.Ignore{chan};
%% Start Fit
%%% Update Progressbar
h.Progress_Text.String = 'Fitting...';
MI_Bins = TauFitData.MI_Bins;
switch obj
    case h.Fit_Button
        %%% Read out parameters
        x0 = cell2mat(h.FitPar_Table.Data(1:end-1,1))';
        lb = cell2mat(h.FitPar_Table.Data(1:end-1,2))';
        ub = cell2mat(h.FitPar_Table.Data(1:end-1,3))';
        fixed = cell2mat(h.FitPar_Table.Data(1:end-1,4));
        if all(fixed) %%% all parameters fixed, instead just plot the current values
            fit = 0;
        else
            fit = 1;
        end
        
        switch TauFitData.FitType
            case 'Single Exponential'
                %%% Parameter:
                %%% taus    - Lifetimes
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                x0(1) = round(x0(1)/TauFitData.TACChannelWidth);
                lb(1) = round(lb(1)/TauFitData.TACChannelWidth);
                ub(1) = round(ub(1)/TauFitData.TACChannelWidth);
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay(ignore:end));sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay(ignore:end)));
                end
                if fit
                    %%% fit for different IRF offsets and compare the results
                    count = 1;
                    x = cell(numel(shift_range,1));
                    residuals = cell(numel(shift_range,1));
                    for i = shift_range
                        %%% Update Progressbar
                        Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                        xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                        [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_1exp(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est,lb(~fixed),ub(~fixed));
                        x{count} = interlace(x0,x{count},fixed);
                        count = count +1;
                    end
                    chi2 = cellfun(@(x) sum(x.^2)/(numel(Decay(ignore:end))-numel(x0)),residuals);
                    [~,best_fit] = min(chi2);   
                else % plot only
                    x = {x0};
                    best_fit = 1;
                end
                
                FitFun = fitfun_1exp(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun);
                if UserValues.TauFit.use_weighted_residuals
                    wres = wres./sqrt(Decay);
                end
                
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(ignore:end);
                wres_ignore = wres(1:ignore);
                wres = wres(ignore:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(ignore:end);
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                FitResult{1} = FitResult{1}.*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult;
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                UserValues.TauFit.FitFix{chan}(1) = fix(1);
                UserValues.TauFit.FitFix{chan}(6) = fix(2);
                UserValues.TauFit.FitFix{chan}(8) = fix(3);
                UserValues.TauFit.FitFix{chan}(10) = fix(4);
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{3};
                UserValues.TauFit.IRFShift{chan} = FitResult{4};
            case 'Biexponential'
                %%% Parameter:
                %%% taus    - Lifetimes
                %%% A       - Amplitude of first lifetime
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                x0(1:2) = round(x0(1:2)/TauFitData.TACChannelWidth);
                lb(1:2) = round(lb(1:2)/TauFitData.TACChannelWidth);
                ub(1:2) = round(ub(1:2)/TauFitData.TACChannelWidth);
                
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay(ignore:end));sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay(ignore:end)));
                end
                if fit
                    %%% fit for different IRF offsets and compare the results
                    x = cell(numel(shift_range,1));
                    residuals = cell(numel(shift_range,1));
                    count = 1;
                    for i = shift_range
                        %%% Update Progressbar
                        Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                        xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                        [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_2exp(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est,lb(~fixed),ub(~fixed));
                        x{count} = interlace(x0,x{count},fixed);
                        count = count +1;
                    end
                    chi2 = cellfun(@(x) sum(x.^2)/(numel(Decay(ignore:end))-numel(x0)),residuals);
                    [~,best_fit] = min(chi2);
                else % plot only
                    x = {x0};
                    best_fit = 1;
                end
                
                FitFun = fitfun_2exp(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun);
                if UserValues.TauFit.use_weighted_residuals
                    wres = wres./sqrt(Decay);
                end
                
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(ignore:end);
                wres_ignore = wres(1:ignore);
                wres = wres(ignore:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(ignore:end);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*TauFitData.TACChannelWidth;
                FitResult{2} = FitResult{2}.*TauFitData.TACChannelWidth;
                
                %%% Convert Fraction from Amplitude (species) fraction to Intensity fraction
                %%% (i.e. correct for brightness)
                %%% Intensity is proportional to tau*amplitude
                amp1 = FitResult{3}*FitResult{1}; amp2 = (1-FitResult{3})*FitResult{2};
                f1 = amp1./(amp1+amp2);
                f2 = amp2./(amp1+amp2);
                meanTau = FitResult{1}*f1+FitResult{2}*f2;
                
                % Also update status text
                h.Output_Text.String = {sprintf('Mean Lifetime: %.2f ns',meanTau),['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'],...
                    ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.']};
                
                h.FitPar_Table.Data(:,1) = FitResult;
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                UserValues.TauFit.FitFix{chan}(1) = fix(1);
                UserValues.TauFit.FitFix{chan}(2) = fix(2);
                UserValues.TauFit.FitFix{chan}(4) = fix(3);
                UserValues.TauFit.FitFix{chan}(6) = fix(4);
                UserValues.TauFit.FitFix{chan}(8) = fix(5);
                UserValues.TauFit.FitFix{chan}(10) = fix(6);
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(2) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(4) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{5};
                UserValues.TauFit.IRFShift{chan} = FitResult{6};
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
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay(ignore:end));sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay(ignore:end)));
                end
                
                if fit
                    %%% fit for different IRF offsets and compare the results
                    x = cell(numel(shift_range,1));
                    residuals = cell(numel(shift_range,1));
                    count = 1;
                    for i = shift_range
                        %%% Update Progressbar
                        Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                        xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                        [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_3exp(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est,lb(~fixed),ub(~fixed));
                        x{count} = interlace(x0,x{count},fixed);
                        count = count +1;
                    end
                    chi2 = cellfun(@(x) sum(x.^2)/(numel(Decay(ignore:end))-numel(x0)),residuals);
                    [~,best_fit] = min(chi2);
                else % plot only
                    x = {x0};
                    best_fit = 1;
                end
                
                FitFun = fitfun_3exp(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun);
                if UserValues.TauFit.use_weighted_residuals
                    wres = wres./sqrt(Decay);
                end
                
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(ignore:end);
                wres_ignore = wres(1:ignore);
                wres = wres(ignore:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(ignore:end);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*TauFitData.TACChannelWidth;
                FitResult{2} = FitResult{2}.*TauFitData.TACChannelWidth;
                FitResult{3} = FitResult{3}.*TauFitData.TACChannelWidth;
                %%% fix amplitudes the same way it is done in the fit
                %%% function
                if (FitResult{4} + FitResult{5}) > 1
                    a1 = FitResult{4}./(FitResult{4}+ FitResult{5});
                    a2 = FitResult{5}./(FitResult{4}+ FitResult{5});
                    FitResult{4} = a1;
                    FitResult{5} = a2;
                end
                %%% Convert Fraction from Amplitude (species) fraction to Intensity fraction
                %%% (i.e. correct for brightness)
                %%% Intensity is proportional to tau*amplitude
                amp1 = FitResult{4}*FitResult{1}; amp2 = FitResult{5}*FitResult{2}; amp3 = (1-FitResult{4}-FitResult{5})*FitResult{3};
                f1 = amp1./(amp1+amp2+amp3);
                f2 = amp2./(amp1+amp2+amp3);
                f3 = amp3./(amp1+amp2+amp3);
                
                meanTau = FitResult{1}*f1+FitResult{2}*f2+FitResult{3}*f3;
                % FitResult{4} = amp1;
                % FitResult{5} = amp2;
                h.Output_Text.String = {sprintf('Mean Lifetime: %.2f ns',meanTau), ['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'], ...
                    ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.'],...
                    ['Intensity fraction of Tau3: ' sprintf('%2.2f',100*f3) ' %.']};
                
                h.FitPar_Table.Data(:,1) = FitResult;
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                UserValues.TauFit.FitFix{chan}(1) = fix(1);
                UserValues.TauFit.FitFix{chan}(2) = fix(2);
                UserValues.TauFit.FitFix{chan}(3) = fix(3);
                UserValues.TauFit.FitFix{chan}(4) = fix(4);
                UserValues.TauFit.FitFix{chan}(5) = fix(5);
                UserValues.TauFit.FitFix{chan}(6) = fix(6);
                UserValues.TauFit.FitFix{chan}(8) = fix(7);
                UserValues.TauFit.FitFix{chan}(10) = fix(8);
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(2) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(3) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(4) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(5) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{7};
                UserValues.TauFit.IRFShift{chan} = FitResult{8};
            case 'Distribution'
                %%% Parameter:
                %%% Center R
                %%% sigmaR
                %%% Scatter
                %%% Background
                %%% R0
                %%% Donor only lifetime
                %%% Convert Lifetimes
                x0(6) = round(x0(6)/TauFitData.TACChannelWidth);
                lb(6) = round(lb(6)/TauFitData.TACChannelWidth);
                ub(6) = round(ub(6)/TauFitData.TACChannelWidth);
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay(ignore:end));sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay(ignore:end)));
                end
                
                if fit
                    %%% fit for different IRF offsets and compare the results
                    x = cell(numel(shift_range,1));
                    residuals = cell(numel(shift_range,1));
                    count = 1;
                    for i = shift_range
                        %%% Update Progressbar
                        Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                        xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                        [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_dist(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est,lb(~fixed),ub(~fixed));
                        x{count} = interlace(x0,x{count},fixed);
                        count = count +1;
                    end
                    chi2 = cellfun(@(x) sum(x.^2)/(numel(Decay(ignore:end))-numel(x0)),residuals);
                    [~,best_fit] = min(chi2);
                else % plot only
                    x = {x0};
                    best_fit = 1;
                end
                
                FitFun = fitfun_dist(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun);
                if UserValues.TauFit.use_weighted_residuals
                    wres = wres./sqrt(Decay);
                end
                
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(ignore:end);
                wres_ignore = wres(1:ignore);
                wres = wres(ignore:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(ignore:end);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{6} = FitResult{6}.*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult;
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                UserValues.TauFit.FitFix{chan}(19) = fix(1);
                UserValues.TauFit.FitFix{chan}(20) = fix(2);
                UserValues.TauFit.FitFix{chan}(6) = fix(3);
                UserValues.TauFit.FitFix{chan}(8) = fix(4);
                UserValues.TauFit.FitFix{chan}(11) = fix(5);
                UserValues.TauFit.FitFix{chan}(12) = fix(6);
                UserValues.TauFit.FitFix{chan}(10) = fix(7);
                UserValues.TauFit.FitParams{chan}(19) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(20) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(11) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(12) = FitResult{6};
                UserValues.TauFit.IRFShift{chan} = FitResult{7};
            case 'Distribution plus Donor only'
                %%% Parameter:
                %%% Center R
                %%% sigmaR
                %%% Fraction D only
                %%% Scatter
                %%% Background
                %%% R0
                %%% Donor only lifetime
                
                %%% Convert Lifetimes
                x0(7) = round(x0(7)/TauFitData.TACChannelWidth);
                lb(7) = round(lb(7)/TauFitData.TACChannelWidth);
                ub(7) = round(ub(7)/TauFitData.TACChannelWidth);
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay(ignore:end));sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay(ignore:end)));
                end
                if fit
                    %%% fit for different IRF offsets and compare the results
                    x = cell(numel(shift_range,1));
                    residuals = cell(numel(shift_range,1));
                    count = 1;
                    for i = shift_range
                        %%% Update Progressbar
                        Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                        xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                        [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_dist_donly(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est,lb(~fixed),ub(~fixed));
                        x{count} = interlace(x0,x{count},fixed);
                        count = count +1;
                    end
                    chi2 = cellfun(@(x) sum(x.^2)/(numel(Decay(ignore:end))-numel(x0)),residuals);
                    [~,best_fit] = min(chi2);
                else % plot only
                    x = {x0};
                    best_fit = 1;
                end
                
                FitFun = fitfun_dist_donly(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun);
                if UserValues.TauFit.use_weighted_residuals
                    wres = wres./sqrt(Decay);
                end
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(ignore:end);
                wres_ignore = wres(1:ignore);
                wres = wres(ignore:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(ignore:end);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{7} = FitResult{7}.*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult;
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                UserValues.TauFit.FitFix{chan}(19) = fix(1);
                UserValues.TauFit.FitFix{chan}(20) = fix(2);
                UserValues.TauFit.FitFix{chan}(21) = fix(3);
                UserValues.TauFit.FitFix{chan}(6) = fix(4);
                UserValues.TauFit.FitFix{chan}(8) = fix(5);
                UserValues.TauFit.FitFix{chan}(11) = fix(6);
                UserValues.TauFit.FitFix{chan}(12) = fix(7);
                UserValues.TauFit.FitFix{chan}(10) = fix(8);
                UserValues.TauFit.FitParams{chan}(19) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(20) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(21) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(11) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(12) = FitResult{7};
                UserValues.TauFit.IRFShift{chan} = FitResult{8};
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
                IRFPattern{1} = TauFitData.hIRF_Par{chan}(1:TauFitData.Length{chan})';IRFPattern{1} = IRFPattern{1}./sum(IRFPattern{1});
                IRFPattern{2} = IRFPer(1:TauFitData.Length{chan})';IRFPattern{2} = IRFPattern{2}./sum(IRFPattern{2});
                for i = 1:2
                    IRFPattern{i} = IRFPattern{i} - mean(IRFPattern{i}(end-round(numel(IRFPattern{i})/10):end)); IRFPattern{i}(IRFPattern{i}<0) = 0;
                end
                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = h.Plots.Scat_Par.YData';%TauFitData.hScat_Par{chan}(1:TauFitData.Length{chan})';
                ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                ScatterPattern{2} = h.Plots.Scat_Per.YData'; %ScatterPer(1:TauFitData.Length{chan})';
                ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});
                
                %%% Convert Lifetimes
                x0(1:2) = round(x0(1:2)/TauFitData.TACChannelWidth);
                lb(1:2) = round(lb(1:2)/TauFitData.TACChannelWidth);
                ub(1:2) = round(ub(1:2)/TauFitData.TACChannelWidth);
                
                %%% Prepare data as vector
                Decay =  [TauFitData.FitData.Decay_Par(ignore:end); TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_stacked = [TauFitData.FitData.Decay_Par(ignore:end) TauFitData.FitData.Decay_Per(ignore:end)];
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay_stacked);sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay_stacked));
                end
                
                if fit
                    %%% fit for different IRF offsets and compare the results
                    x = cell(numel(shift_range,1));
                    residuals = cell(numel(shift_range,1));
                    count = 1;
                    for i = shift_range
                        %%% Update Progressbar
                        Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                        xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,i,ignore,Conv_Type};
                        [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_aniso(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay_stacked./sigma_est,lb(~fixed),ub(~fixed));
                        x{count} = interlace(x0,x{count},fixed);
                        count = count +1;
                    end
                    chi2 = cellfun(@(x) sum(x.^2)/(numel(Decay_stacked)-numel(x0)),residuals);
                    [~,best_fit] = min(chi2);
                else % plot only
                    x = {x0};
                    best_fit = 1;
                end
                
                %%% remove ignore range from decay
                Decay = [TauFitData.FitData.Decay_Par; TauFitData.FitData.Decay_Per];
                Decay_stacked = [TauFitData.FitData.Decay_Par TauFitData.FitData.Decay_Per];
                FitFun = fitfun_aniso(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,shift_range(best_fit),1,Conv_Type});
                wres = (Decay_stacked-FitFun); Decay = Decay_stacked;
                if UserValues.TauFit.use_weighted_residuals
                    wres = wres./sqrt(Decay_stacked);
                end
                %%% ignore plotting is not implemented here yet!
                FitFun_ignore = FitFun;
                wres_ignore = wres;
                Decay_ignore = Decay;
                Length = numel(Decay);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*TauFitData.TACChannelWidth;
                FitResult{2} = FitResult{2}.*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult;
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                UserValues.TauFit.FitFix{chan}(1) = fix(1);
                UserValues.TauFit.FitFix{chan}(15) = fix(2);
                UserValues.TauFit.FitFix{chan}(17) = fix(3);
                UserValues.TauFit.FitFix{chan}(18) = fix(4);
                UserValues.TauFit.FitFix{chan}(6) = fix(5);
                UserValues.TauFit.FitFix{chan}(7) = fix(6);
                UserValues.TauFit.FitFix{chan}(8) = fix(7);
                UserValues.TauFit.FitFix{chan}(9) = fix(8);
                UserValues.TauFit.FitFix{chan}(13) = fix(9);
                UserValues.TauFit.FitFix{chan}(14) = fix(10);
                UserValues.TauFit.FitFix{chan}(10) = fix(11);
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(15) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(17) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(18) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(7) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{7};
                UserValues.TauFit.FitParams{chan}(9) = FitResult{8};
                UserValues.TauFit.FitParams{chan}(13) = FitResult{9};
                UserValues.TauFit.FitParams{chan}(14) = FitResult{10};
                UserValues.TauFit.IRFShift{chan} = FitResult{11};
                h.l1_edit.String = num2str(FitResult{9});
                h.l2_edit.String = num2str(FitResult{10});
            case 'Fit Anisotropy (2 exp lifetime)'
                %%% Parameter
                %%% Lifetime 1 and 2
                %%% Fraction 1
                %%% Rotational Correlation Time
                %%% r0 - Initial Anisotropy
                %%% r_infinity - Residual Anisotropy
                %%% Background par
                %%% Background per
                
                %%% Define separate IRF Patterns
                IRFPattern = cell(2,1);
                IRFPattern{1} = TauFitData.hIRF_Par{chan}(1:TauFitData.Length{chan})';IRFPattern{1} = IRFPattern{1}./sum(IRFPattern{1});
                IRFPattern{2} = IRFPer(1:TauFitData.Length{chan})';IRFPattern{2} = IRFPattern{2}./sum(IRFPattern{2});
                for i = 1:2
                    IRFPattern{i} = IRFPattern{i} - mean(IRFPattern{i}(end-round(numel(IRFPattern{i})/10):end)); IRFPattern{i}(IRFPattern{i}<0) = 0;
                end
                
                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = h.Plots.Scat_Par.YData';%TauFitData.hScat_Par{chan}(1:TauFitData.Length{chan})';
                ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                ScatterPattern{2} = h.Plots.Scat_Per.YData'; %ScatterPer(1:TauFitData.Length{chan})';
                ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});
                
                %%% Convert Lifetimes
                x0([1,2,4]) = round(x0([1,2,4])/TauFitData.TACChannelWidth);
                lb([1,2,4]) = round(lb([1,2,4])/TauFitData.TACChannelWidth);
                ub([1,2,4]) = round(ub([1,2,4])/TauFitData.TACChannelWidth);
                
                %%% Prepare data as vector
                Decay =  [TauFitData.FitData.Decay_Par(ignore:end); TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_stacked = [TauFitData.FitData.Decay_Par(ignore:end) TauFitData.FitData.Decay_Per(ignore:end)];
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay_stacked);sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay_stacked));
                end
                
                if fit
                    %%% fit for different IRF offsets and compare the results
                    x = cell(numel(shift_range,1));
                    residuals = cell(numel(shift_range,1));
                    count = 1;
                    for i = shift_range
                        %%% Update Progressbar
                        Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                        xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,i,ignore,Conv_Type};
                        [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_2lt_aniso(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay_stacked./sigma_est,lb(~fixed),ub(~fixed));
                        x{count} = interlace(x0,x{count},fixed);
                        count = count +1;
                    end
                    chi2 = cellfun(@(x) sum(x.^2)/(numel(Decay_stacked)-numel(x0)),residuals);
                    [~,best_fit] = min(chi2);
                else % plot only
                    x = {x0};
                    best_fit = 1;
                end
                
                %%% remove ignore range from decay
                Decay = [TauFitData.FitData.Decay_Par; TauFitData.FitData.Decay_Per];
                Decay_stacked = [TauFitData.FitData.Decay_Par TauFitData.FitData.Decay_Per];
                FitFun = fitfun_2lt_aniso(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,shift_range(best_fit),1,Conv_Type});
                wres = (Decay_stacked-FitFun); Decay = Decay_stacked;
                if UserValues.TauFit.use_weighted_residuals
                    wres = wres./sqrt(Decay_stacked);
                end
                %%% ignore plotting is not implemented here yet!
                FitFun_ignore = FitFun;
                wres_ignore = wres;
                Decay_ignore = Decay;
                Length = numel(Decay);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*TauFitData.TACChannelWidth;
                FitResult{2} = FitResult{2}.*TauFitData.TACChannelWidth;
                FitResult{4} = FitResult{4}.*TauFitData.TACChannelWidth;
                
                %%% Convert Fraction from Amplitude (species) fraction to Intensity fraction
                %%% (i.e. correct for brightness)
                %%% Intensity is proportional to tau*amplitude
                amp1 = FitResult{3}*FitResult{1}; amp2 = (1-FitResult{3})*FitResult{2};
                f1 = amp1./(amp1+amp2);
                f2 = amp2./(amp1+amp2);
                meanTau = FitResult{1}*f1+FitResult{2}*f2;
               
                % Also update status text
                h.Output_Text.String = {sprintf('Mean Lifetime: %.2f ns',meanTau),['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'],...
                    ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.']};
                
                h.FitPar_Table.Data(:,1) = FitResult;
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                UserValues.TauFit.FitFix{chan}(1) = fix(1);
                UserValues.TauFit.FitFix{chan}(2) = fix(2);
                UserValues.TauFit.FitFix{chan}(4) = fix(3);
                UserValues.TauFit.FitFix{chan}(15) = fix(4);
                UserValues.TauFit.FitFix{chan}(17) = fix(5);
                UserValues.TauFit.FitFix{chan}(18) = fix(6);
                UserValues.TauFit.FitFix{chan}(6) = fix(7);
                UserValues.TauFit.FitFix{chan}(7) = fix(8);
                UserValues.TauFit.FitFix{chan}(8) = fix(9);
                UserValues.TauFit.FitFix{chan}(9) = fix(10);
                UserValues.TauFit.FitFix{chan}(13) = fix(11);
                UserValues.TauFit.FitFix{chan}(14) = fix(12);
                UserValues.TauFit.FitFix{chan}(10) = fix(13);
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(2) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(4) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(15) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(17) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(18) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{7};
                UserValues.TauFit.FitParams{chan}(7) = FitResult{8};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{9};
                UserValues.TauFit.FitParams{chan}(9) = FitResult{10};
                UserValues.TauFit.FitParams{chan}(13) = FitResult{11};
                UserValues.TauFit.FitParams{chan}(14) = FitResult{12};
                UserValues.TauFit.IRFShift{chan} = FitResult{13};
                h.l1_edit.String = num2str(FitResult{11});
                h.l2_edit.String = num2str(FitResult{12});
            case 'Fit Anisotropy (2 exp rot)'
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
                IRFPattern{1} = TauFitData.hIRF_Par{chan}(1:TauFitData.Length{chan})';IRFPattern{1} = IRFPattern{1}./sum(IRFPattern{1});
                IRFPattern{2} = IRFPer(1:TauFitData.Length{chan})';IRFPattern{2} = IRFPattern{2}./sum(IRFPattern{2});
                for i = 1:2
                    IRFPattern{i} = IRFPattern{i} - mean(IRFPattern{i}(end-round(numel(IRFPattern{i})/10):end)); IRFPattern{i}(IRFPattern{i}<0) = 0;
                end
                
                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = h.Plots.Scat_Par.YData';%TauFitData.hScat_Par{chan}(1:TauFitData.Length{chan})';
                ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                ScatterPattern{2} = h.Plots.Scat_Per.YData'; %ScatterPer(1:TauFitData.Length{chan})';
                ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});
                 
                %%% Convert Lifetimes
                x0(1:3) = round(x0(1:3)/TauFitData.TACChannelWidth);
                lb(1:3) = round(lb(1:3)/TauFitData.TACChannelWidth);
                ub(1:3) = round(ub(1:3)/TauFitData.TACChannelWidth);
                
                %%% Prepare data as vector
                Decay =  [TauFitData.FitData.Decay_Par(ignore:end); TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_stacked = [TauFitData.FitData.Decay_Par(ignore:end) TauFitData.FitData.Decay_Per(ignore:end)];
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay_stacked);sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay_stacked));
                end
                
                if fit
                    %%% fit for different IRF offsets and compare the results
                    x = cell(numel(shift_range,1));
                    residuals = cell(numel(shift_range,1));
                    count = 1;
                    for i = shift_range
                        %%% Update Progressbar
                        Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                        xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,i,ignore,Conv_Type};
                        [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_aniso_2rot(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay_stacked./sigma_est,lb(~fixed),ub(~fixed));
                        x{count} = interlace(x0,x{count},fixed);
                        count = count +1;
                    end
                    chi2 = cellfun(@(x) sum(x.^2)/(numel(Decay_stacked)-numel(x0)),residuals);
                    [~,best_fit] = min(chi2);
                else % plot only
                    x = {x0};
                    best_fit = 1;
                end
                
                %%% remove ignore range from decay
                Decay = [TauFitData.FitData.Decay_Par; TauFitData.FitData.Decay_Per];
                Decay_stacked = [TauFitData.FitData.Decay_Par TauFitData.FitData.Decay_Per];
                FitFun = fitfun_aniso_2rot(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,shift_range(best_fit),1,Conv_Type});
                wres = (Decay_stacked-FitFun); Decay = Decay_stacked;
                if UserValues.TauFit.use_weighted_residuals
                    wres = wres./sqrt(Decay_stacked);
                end
                
                %%% ignore plotting is not implemented here yet!
                FitFun_ignore = FitFun;
                wres_ignore = wres;
                Decay_ignore = Decay;
                Length = numel(Decay);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*TauFitData.TACChannelWidth;
                FitResult{2} = FitResult{2}.*TauFitData.TACChannelWidth;
                FitResult{3} = FitResult{3}.*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult;
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                UserValues.TauFit.FitFix{chan}(1) = fix(1);
                UserValues.TauFit.FitFix{chan}(15) = fix(2);
                UserValues.TauFit.FitFix{chan}(16) = fix(3);
                UserValues.TauFit.FitFix{chan}(17) = fix(4);
                UserValues.TauFit.FitFix{chan}(18) = fix(5);
                UserValues.TauFit.FitFix{chan}(6) = fix(6);
                UserValues.TauFit.FitFix{chan}(7) = fix(7);
                UserValues.TauFit.FitFix{chan}(8) = fix(8);
                UserValues.TauFit.FitFix{chan}(9) = fix(9);
                UserValues.TauFit.FitFix{chan}(13) = fix(10);
                UserValues.TauFit.FitFix{chan}(14) = fix(11);
                UserValues.TauFit.FitFix{chan}(10) = fix(12);
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(15) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(16) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(17) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(18) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(7) = FitResult{7};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{8};
                UserValues.TauFit.FitParams{chan}(9) = FitResult{9};
                UserValues.TauFit.FitParams{chan}(13) = FitResult{10};
                UserValues.TauFit.FitParams{chan}(14) = FitResult{11};
                UserValues.TauFit.IRFShift{chan} = FitResult{12};
                h.l1_edit.String = num2str(FitResult{10});
                h.l2_edit.String = num2str(FitResult{11});
            case 'Fit Anisotropy (2 exp lifetime, 2 exp rot)'
                %%% Parameter
                %%% Lifetime 1 and 2
                %%% Fraction 1
                %%% Rotational Correlation Time 1
                %%% Rotational Correlation Time 2
                %%% r0 - Initial Anisotropy
                %%% r_infinity - Residual Anisotropy
                %%% Background par
                %%% Background per
                
                %%% Define separate IRF Patterns
                IRFPattern = cell(2,1);
                IRFPattern{1} = TauFitData.hIRF_Par{chan}(1:TauFitData.Length{chan})';IRFPattern{1} = IRFPattern{1}./sum(IRFPattern{1});
                IRFPattern{2} = IRFPer(1:TauFitData.Length{chan})';IRFPattern{2} = IRFPattern{2}./sum(IRFPattern{2});
                for i = 1:2
                    IRFPattern{i} = IRFPattern{i} - mean(IRFPattern{i}(end-round(numel(IRFPattern{i})/10):end)); IRFPattern{i}(IRFPattern{i}<0) = 0;
                end
                
                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = h.Plots.Scat_Par.YData';%TauFitData.hScat_Par{chan}(1:TauFitData.Length{chan})';
                ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                ScatterPattern{2} = h.Plots.Scat_Per.YData'; %ScatterPer(1:TauFitData.Length{chan})';
                ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});
                 
                %%% Convert Lifetimes
                x0([1,2,4,5]) = round(x0([1,2,4,5])/TauFitData.TACChannelWidth);
                lb([1,2,4,5]) = round(lb([1,2,4,5])/TauFitData.TACChannelWidth);
                ub([1,2,4,5]) = round(ub([1,2,4,5])/TauFitData.TACChannelWidth);
                
                %%% Prepare data as vector
                Decay =  [TauFitData.FitData.Decay_Par(ignore:end); TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_stacked = [TauFitData.FitData.Decay_Par(ignore:end) TauFitData.FitData.Decay_Per(ignore:end)];
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay_stacked);sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay_stacked));
                end
                
                if fit
                    %%% fit for different IRF offsets and compare the results
                    x = cell(numel(shift_range,1));
                    residuals = cell(numel(shift_range,1));
                    count = 1;
                    for i = shift_range
                        %%% Update Progressbar
                        Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                        xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,i,ignore,Conv_Type};
                        [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_2lt_aniso_2rot(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay_stacked./sigma_est,lb(~fixed),ub(~fixed));
                        x{count} = interlace(x0,x{count},fixed);
                        count = count +1;
                    end
                    chi2 = cellfun(@(x) sum(x.^2)/(numel(Decay_stacked)-numel(x0)),residuals);
                    [~,best_fit] = min(chi2);
                else % plot only
                    x = {x0};
                    best_fit = 1;
                end
                
                %%% remove ignore range from decay
                Decay = [TauFitData.FitData.Decay_Par; TauFitData.FitData.Decay_Per];
                Decay_stacked = [TauFitData.FitData.Decay_Par TauFitData.FitData.Decay_Per];
                FitFun = fitfun_2lt_aniso_2rot(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,shift_range(best_fit),1,Conv_Type});
                wres = (Decay_stacked-FitFun); Decay = Decay_stacked;
                if UserValues.TauFit.use_weighted_residuals
                    wres = wres./sqrt(Decay_stacked);
                end
                
                %%% ignore plotting is not implemented here yet!
                FitFun_ignore = FitFun;
                wres_ignore = wres;
                Decay_ignore = Decay;
                Length = numel(Decay);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*TauFitData.TACChannelWidth;
                FitResult{2} = FitResult{2}.*TauFitData.TACChannelWidth;
                FitResult{4} = FitResult{4}.*TauFitData.TACChannelWidth;
                FitResult{5} = FitResult{5}.*TauFitData.TACChannelWidth;
                
                %%% Convert Fraction from Amplitude (species) fraction to Intensity fraction
                %%% (i.e. correct for brightness)
                %%% Intensity is proportional to tau*amplitude
                amp1 = FitResult{3}*FitResult{1}; amp2 = (1-FitResult{3})*FitResult{2};
                f1 = amp1./(amp1+amp2);
                f2 = amp2./(amp1+amp2);
                meanTau = FitResult{1}*f1+FitResult{2}*f2;
                
                % Also update status text
                h.Output_Text.String = {sprintf('Mean Lifetime: %.2f ns',meanTau), ['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'],...
                    ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.']};
                
                h.FitPar_Table.Data(:,1) = FitResult;
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                UserValues.TauFit.FitFix{chan}(1) = fix(1);
                UserValues.TauFit.FitFix{chan}(2) = fix(2);
                UserValues.TauFit.FitFix{chan}(4) = fix(3);
                UserValues.TauFit.FitFix{chan}(15) = fix(4);
                UserValues.TauFit.FitFix{chan}(16) = fix(5);
                UserValues.TauFit.FitFix{chan}(17) = fix(6);
                UserValues.TauFit.FitFix{chan}(18) = fix(7);
                UserValues.TauFit.FitFix{chan}(6) = fix(8);
                UserValues.TauFit.FitFix{chan}(7) = fix(9);
                UserValues.TauFit.FitFix{chan}(8) = fix(10);
                UserValues.TauFit.FitFix{chan}(9) = fix(11);
                UserValues.TauFit.FitFix{chan}(13) = fix(12);
                UserValues.TauFit.FitFix{chan}(14) = fix(13);
                UserValues.TauFit.FitFix{chan}(10) = fix(14);
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(2) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(4) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(15) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(16) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(17) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(18) = FitResult{7};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{8};
                UserValues.TauFit.FitParams{chan}(7) = FitResult{9};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{10};
                UserValues.TauFit.FitParams{chan}(9) = FitResult{11};
                UserValues.TauFit.FitParams{chan}(13) = FitResult{12};
                UserValues.TauFit.FitParams{chan}(14) = FitResult{13};
                UserValues.TauFit.IRFShift{chan} = FitResult{14};
                h.l1_edit.String = num2str(FitResult{12});
                h.l2_edit.String = num2str(FitResult{13});
        end
        LSUserValues(1)
        %%% Update IRFShift in Slider and Edit Box
        h.IRFShift_Slider.Value = shift_range(best_fit);
        h.IRFShift_Edit.String = num2str(shift_range(best_fit));
        TauFitData.IRFShift{chan} = shift_range(best_fit);
        
        %%% Update Plot
        h.Microtime_Plot.Parent = h.HidePanel;
        h.Result_Plot.Parent = h.TauFit_Panel;
        h.Plots.IRFResult.Visible = 'on';

        % plot chi^2 on graph
        if ~fit % plot only, chi2 was not calculated yet
            chi2 = sum(wres(~isinf(wres)).^2)./(numel(wres)-numel(x0));
        end
        h.Result_Plot_Text.Visible = 'on';
        if UserValues.TauFit.use_weighted_residuals
            h.Result_Plot_Text.String = ['\' sprintf('chi^2_{red.} = %.2f', chi2(best_fit))];
        else
            h.Result_Plot_Text.String = [sprintf('res^2 = %.2f', chi2(best_fit))];
        end
        %h.Result_Plot_Text.Position = [0.8*h.Result_Plot.XLim(2) 0.9*h.Result_Plot.YLim(2)];
        h.Result_Plot_Text.Position = [0.8 0.95];
        
        % nanoseconds per microtime bin
        TACtoTime = 1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
        
        %%% Update plots
        if ignore > 1
            h.Plots.DecayResult_ignore.Visible = 'on';
            h.Plots.Residuals_ignore.Visible = 'on';
            h.Plots.FitResult_ignore.Visible = 'on';
        else
            h.Plots.DecayResult_ignore.Visible = 'off';
            h.Plots.Residuals_ignore.Visible = 'off';
            h.Plots.FitResult_ignore.Visible = 'off';
        end
        if any(strcmp(TauFitData.FitType,{'Fit Anisotropy','Fit Anisotropy (2 exp rot)','Fit Anisotropy (2 exp lifetime)','Fit Anisotropy (2 exp lifetime, 2 exp rot)'}))
            % Unhide plots
            h.Plots.IRFResult_Perp.Visible = 'on';
            h.Plots.FitResult_Perp.Visible = 'on';
            h.Plots.FitResult_Perp_ignore.Visible = 'on';
            h.Plots.DecayResult_Perp.Visible = 'on';
            h.Plots.DecayResult_Perp_ignore.Visible = 'on';
            h.Plots.Residuals_Perp.Visible = 'on';
            h.Plots.Residuals_Perp_ignore.Visible = 'on';
            
            % change colors
            h.Plots.IRFResult.Color = [1 0 0];
            h.Plots.DecayResult.Color = [0.6000 0.2000 0];
            h.Plots.Residuals.Color = [1 0 0];
            h.Plots.Residuals_ignore.Color = [1 0 0];
            
            %%% Split Decay_Result in Par and Per
            Decay_par = Decay(1:numel(Decay)/2);
            Decay_per = Decay(numel(Decay)/2+1:end);
            Fit_par = FitFun(1:numel(Decay)/2);
            Fit_per = FitFun(numel(Decay)/2+1:end);
            wres_par = wres(1:numel(Decay)/2);
            wres_per = wres(numel(Decay)/2+1:end);
            
            IRFPat_Par = circshift(IRFPattern{1},[UserValues.TauFit.IRFShift{chan},0]);
            IRFPat_Par = IRFPat_Par((ShiftParams(1)+1):ShiftParams(4));
            IRFPat_Par = IRFPat_Par./max(IRFPat_Par).*max(Decay_par);
            h.Plots.IRFResult.XData = (1:numel(IRFPat_Par))*TACtoTime;
            h.Plots.IRFResult.YData = IRFPat_Par;
            
            IRFPat_Perp = circshift(IRFPattern{2},[UserValues.TauFit.IRFShift{chan},0]);
            IRFPat_Perp = IRFPat_Perp((ShiftParams(1)+1):ShiftParams(4));
            IRFPat_Perp = IRFPat_Perp./max(IRFPat_Perp).*max(Decay_per);
            h.Plots.IRFResult_Perp.XData = (1:numel(IRFPat_Perp))*TACtoTime;
            h.Plots.IRFResult_Perp.YData = IRFPat_Perp;
            
            %%% plot anisotropy data also
            % unhide Result Aniso Plot
            h.Result_Plot_Aniso.Parent = h.TauFit_Panel;
            % change axes positions
            h.Result_Plot.Position = [0.075 0.3 0.9 0.55];
            h.Result_Plot_Aniso.Position = [0.075 0.075 0.9 0.15];
            
            r_meas = (G*Decay_par-Decay_per)./(G*Decay_par+2*Decay_per);
            r_fit = (G*Fit_par-Fit_per)./(G*Fit_par+2*Fit_per);
            x = (1:numel(Decay)/2).*TACtoTime;
            % update plots
            h.Plots.AnisoResult.XData = x(ignore:end);
            h.Plots.AnisoResult.YData = r_meas(ignore:end);
            h.Plots.AnisoResult_ignore.XData = x(1:ignore);
            h.Plots.AnisoResult_ignore.YData = r_meas(1:ignore);
            h.Plots.FitAnisoResult.XData = x(ignore:end);
            h.Plots.FitAnisoResult.YData = r_fit(ignore:end);
            h.Plots.FitAnisoResult_ignore.XData = x(1:ignore);
            h.Plots.FitAnisoResult_ignore.YData = r_fit(1:ignore);
            axis(h.Result_Plot_Aniso,'tight');
            h.Result_Plot_Aniso.YLim(1) = min([min(r_meas(ignore:end)) min(r_fit(ignore:end))]);
            h.Result_Plot_Aniso.YLim(1) = h.Result_Plot_Aniso.YLim(1) - 0.05*abs(h.Result_Plot_Aniso.YLim(1));
            h.Result_Plot_Aniso.YLim(2) = 1.05*max([max(r_meas(ignore:end)) max(r_fit(ignore:end))]);
            % store FitResult TauFitData also for use in export
            TauFitData.FitResult = [Fit_par; Fit_per];
            
            h.Plots.DecayResult.XData = (ignore:numel(Decay_par))*TACtoTime;
            h.Plots.DecayResult.YData = Decay_par(ignore:end);
            h.Plots.FitResult.XData = (ignore:numel(Fit_par))*TACtoTime;
            h.Plots.FitResult.YData = Fit_par(ignore:end);

            h.Plots.DecayResult_ignore.XData = (1:ignore)*TACtoTime;
            h.Plots.DecayResult_ignore.YData = Decay_par(1:ignore);
            h.Plots.FitResult_ignore.XData = (1:ignore)*TACtoTime;
            h.Plots.FitResult_ignore.YData = Fit_par(1:ignore);
            
            h.Plots.DecayResult_Perp.XData = (ignore:numel(Decay_per))*TACtoTime;
            h.Plots.DecayResult_Perp.YData = Decay_per(ignore:end);
            h.Plots.FitResult_Perp.XData = (ignore:numel(Fit_per))*TACtoTime;
            h.Plots.FitResult_Perp.YData = Fit_per(ignore:end);

            h.Plots.DecayResult_Perp_ignore.XData = (1:ignore)*TACtoTime;
            h.Plots.DecayResult_Perp_ignore.YData = Decay_per(1:ignore);
            h.Plots.FitResult_Perp_ignore.XData = (1:ignore)*TACtoTime;
            h.Plots.FitResult_Perp_ignore.YData = Fit_per(1:ignore);
            
            axis(h.Result_Plot,'tight');
            h.Result_Plot.YLim(1) = min([min(Decay_par(ignore:end)) min(Decay_per(ignore:end))]);
            h.Result_Plot.YLim(2) = 1.1*max([max(Decay_par(ignore:end)) max(Decay_per(ignore:end))]);
            
            h.Plots.Residuals.XData = (ignore:numel(wres_par))*TACtoTime;
            h.Plots.Residuals.YData = wres_par(ignore:end);
            h.Plots.Residuals_ignore.XData = (1:ignore)*TACtoTime;
            h.Plots.Residuals_ignore.YData = wres_par(1:ignore);
            
            h.Plots.Residuals_Perp.XData = (ignore:numel(wres_per))*TACtoTime;
            h.Plots.Residuals_Perp.YData = wres_per(ignore:end);
            h.Plots.Residuals_Perp_ignore.XData = (1:ignore)*TACtoTime;
            h.Plots.Residuals_Perp_ignore.YData = wres_per(1:ignore);
            
            h.Plots.Residuals_ZeroLine.XData = (1:Length)*TACtoTime;
            h.Plots.Residuals_ZeroLine.YData = zeros(1,Length);
            
            h.Residuals_Plot.YLim = [min([min(wres_par(ignore:end)) min(wres_per(ignore:end))]) max([max(wres_par(ignore:end)) max(wres_per(ignore:end))])];
        else
            % hide plots
            h.Plots.IRFResult_Perp.Visible = 'off';
            h.Plots.FitResult_Perp.Visible = 'off';
            h.Plots.FitResult_Perp_ignore.Visible = 'off';
            h.Plots.DecayResult_Perp.Visible = 'off';
            h.Plots.DecayResult_Perp_ignore.Visible = 'off';
            h.Plots.Residuals_Perp.Visible = 'off';
            h.Plots.Residuals_Perp_ignore.Visible = 'off';
            
            % change colors
            h.Plots.IRFResult.Color = [0.6 0.6 0.6];
            h.Plots.DecayResult.Color = [0 0 0];
            h.Plots.Residuals.Color = [0 0 0];
            h.Plots.Residuals_ignore.Color = [0.6 0.6 0.6];
            
            %%% hide aniso plots
            h.Result_Plot.Position = [0.075 0.075 0.9 0.775];
            h.Result_Plot_Aniso.Parent = h.HidePanel;
            
            IRFPat = circshift(IRFPattern,[UserValues.TauFit.IRFShift{chan},0]);
            IRFPat = IRFPat((ShiftParams(1)+1):ShiftParams(4));
            IRFPat = IRFPat./max(IRFPat).*max(Decay);
            h.Plots.IRFResult.XData = (1:numel(IRFPat))*TACtoTime;
            h.Plots.IRFResult.YData = IRFPat;
            % store FitResult TauFitData also for use in export
            if ignore > 1
                TauFitData.FitResult = [FitFun_ignore, FitFun];
            else
                TauFitData.FitResult = FitFun;
            end
            
            h.Plots.DecayResult.XData = (ignore:Length)*TACtoTime;
            h.Plots.DecayResult.YData = Decay;
            h.Plots.FitResult.XData = (ignore:Length)*TACtoTime;
            h.Plots.FitResult.YData = FitFun;

            h.Plots.DecayResult_ignore.XData = (1:ignore)*TACtoTime;
            h.Plots.DecayResult_ignore.YData = Decay_ignore;
            h.Plots.FitResult_ignore.XData = (1:ignore)*TACtoTime;
            h.Plots.FitResult_ignore.YData = FitFun_ignore;
            axis(h.Result_Plot,'tight');
            h.Result_Plot.YLim = [min([min(Decay) min(Decay_ignore)]) 1.05*max(Decay)];
            
            h.Plots.Residuals.XData = (ignore:Length)*TACtoTime;
            h.Plots.Residuals.YData = wres;
            h.Plots.Residuals_ZeroLine.XData = (1:Length)*TACtoTime;
            h.Plots.Residuals_ZeroLine.YData = zeros(1,Length);
            h.Plots.Residuals_ignore.XData = (1:ignore)*TACtoTime;
            h.Plots.Residuals_ignore.YData = wres_ignore;
            h.Residuals_Plot.YLim = [min(wres) max(wres)];
        end

        h.Result_Plot.XLim(1) = 0;
        h.Result_Plot.YLabel.String = 'Intensity [counts]';
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
            param0 = [1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 0.4,0];
            param = lsqcurvefit(tres_aniso,param0,x,Aniso_fit,[0 0 -1],[Inf,1,1]);
        elseif number_of_exponentials == 2
            tres_aniso = @(x,xdata) ((x(2)-x(4)).*exp(-xdata./x(1)) + x(4)).*exp(-xdata./x(3));
            param0 = [1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 0.4,8/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins,0.1];
            param = lsqcurvefit(tres_aniso,param0,x,Aniso_fit,[0 -0.4 0 -0.4],[Inf,1,Inf,1]);
        end
        
        x_fitres = ignore:numel(Aniso);
        fitres = tres_aniso(param,x);fitres = fitres(1:(numel(Aniso)-ignore+1));
        res = Aniso_fit-fitres;
        
        Aniso_ignore = Aniso(1:ignore);
        
        TACtoTime = 1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
        %%% Update Plot
        h.Microtime_Plot.Parent = h.HidePanel;
        h.Result_Plot.Parent = h.TauFit_Panel;
        h.Plots.IRFResult.Visible = 'off';
        
        if ignore > 1
            h.Plots.DecayResult_ignore.Visible = 'on';
            h.Plots.Residuals_ignore.Visible = 'off';
            h.Plots.FitResult_ignore.Visible = 'off';
        else
            h.Plots.DecayResult_ignore.Visible = 'off';
            h.Plots.Residuals_ignore.Visible = 'off';
            h.Plots.FitResult_ignore.Visible = 'off';
        end
        
        h.Plots.DecayResult.XData = (ignore:numel(Aniso))*TACtoTime;
        h.Plots.DecayResult.YData = Aniso_fit;
        h.Plots.DecayResult_ignore.XData = (1:ignore)*TACtoTime;
        h.Plots.DecayResult_ignore.YData = Aniso_ignore;
        h.Plots.FitResult.XData = x_fitres*TACtoTime;
        h.Plots.FitResult.YData = fitres;
        axis(h.Result_Plot,'tight');
        h.Result_Plot_Text.Visible = 'on';
        if number_of_exponentials == 1
            str = sprintf('rho = %1.2f ns\nr_0 = %2.4f\nr_{inf} = %3.4f',param(1)*TACtoTime,param(2),param(3));
        elseif number_of_exponentials == 2
            str = sprintf('rho_f = %1.2f ns\nrho_p = %1.2f ns\nr_0 = %2.4f\nr_{p} = %3.4f',param(1)*TACtoTime,param(3)*TACtoTime,param(2),param(4));
        end
        h.Result_Plot_Text.String = str;
        h.Result_Plot_Text.Position = [0.8 0.9];
        
        h.Plots.Residuals.XData = x_fitres*TACtoTime;
        h.Plots.Residuals.YData = res;
        h.Plots.Residuals_ZeroLine.XData = x*TACtoTime;
        h.Plots.Residuals_ZeroLine.YData = zeros(1,numel(x));
        h.Residuals_Plot.YLim = [min(res) max(res)];
        h.Result_Plot.XLim(1) = 0;
        h.Result_Plot.YLabel.String = 'Anisotropy';
        
        %%% hide aniso plots
        h.Result_Plot.Position = [0.075 0.075 0.9 0.775];
        h.Result_Plot_Aniso.Parent = h.HidePanel;
        
        % hide plots
        h.Plots.IRFResult_Perp.Visible = 'off';
        h.Plots.FitResult_Perp.Visible = 'off';
        h.Plots.FitResult_Perp_ignore.Visible = 'off';
        h.Plots.DecayResult_Perp.Visible = 'off';
        h.Plots.DecayResult_Perp_ignore.Visible = 'off';
        h.Plots.Residuals_Perp.Visible = 'off';
        h.Plots.Residuals_Perp_ignore.Visible = 'off';

        % change colors
        h.Plots.IRFResult.Color = [0.6 0.6 0.6];
        h.Plots.DecayResult.Color = [0 0 0];
        h.Plots.Residuals.Color = [0 0 0];
        h.Plots.Residuals_ignore.Color = [0.6 0.6 0.6];
    case {h.Fit_Tail_Button,h.Fit_Tail_2exp,h.Fit_Tail_3exp}
        if obj == h.Fit_Tail_2exp
            number_of_exponentials = 2;
        elseif obj == h.Fit_Tail_3exp
            number_of_exponentials = 3;
        else
            number_of_exponentials = 1;
        end
        
        %%% construct x axis
        Decay_fit = Decay(ignore:end);
        x_fit = 1:numel(Decay_fit);
        %%% Fit function
        if number_of_exponentials == 1
            %%% param is
            %%% I0, tau, offset
            model = @(x,xdata) (x(1)*exp(-xdata./x(2))+x(3));
            param0 = [Decay_fit(1) 1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 0];
            if h.UseWeightedResiduals_Menu.Value
                weights = sqrt(Decay_fit); weights(weights==0) = 1;
                [param,~,res] = lsqcurvefit(@(x,xdata) model(x,xdata)./weights,param0,x_fit,Decay_fit./weights,[0 0 0],[Inf,Inf,Inf]);
            else
                [param,~,res] = lsqcurvefit(model,param0,x_fit,Decay_fit,[0 0 0],[Inf,Inf,Inf]);
            end
        elseif number_of_exponentials == 2
            %%% param is
            %%% I0, tau1, tau2, Fraction1, offset
            model = @(x,xdata) x(1)*(x(4)*exp(-xdata./x(2))+(1-x(4))*exp(-xdata./x(3)))+x(5);
            param0 = [Decay_fit(1) 1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 0.5,0];
            if h.UseWeightedResiduals_Menu.Value
                weights = sqrt(Decay_fit); weights(weights==0) = 1;
                [param,~,res] = lsqcurvefit(@(x,xdata) model(x,xdata)./weights,param0,x_fit,Decay_fit./weights,[0 0 0,0,0],[Inf,Inf,Inf,1,Inf]);
            else
                [param,~,res] = lsqcurvefit(model,param0,x_fit,Decay_fit,[0 0 0,0,0],[Inf,Inf,Inf,1,Inf]);
            end
        elseif number_of_exponentials == 3
            %%% param is
            %%% I0, tau1, tau2, tau3, Fraction1, Fraction2, offset
            model = @(x,xdata) x(1)*(x(5)*exp(-xdata./x(2))+x(6)*exp(-xdata./x(3))+max([0 (1-x(5)-x(6))])*exp(-xdata./x(4)))+x(7);
            param0 = [Decay_fit(1) 1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 2/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 3/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins,...
                0.3,0.3,0];
            options = optimoptions('lsqcurvefit','MaxFunctionEvaluations',1E5,'MaxIterations',1E4);
            if h.UseWeightedResiduals_Menu.Value
                weights = sqrt(Decay_fit); weights(weights==0) = 1;
                [param,~,res] = lsqcurvefit(@(x,xdata) model(x,xdata)./weights,param0,x_fit,Decay_fit./weights,[0,0,0,0,0,0,0],[Inf,Inf,Inf,Inf,1,1,Inf],options);
            else
                [param,~,res] = lsqcurvefit(model,param0,x_fit,Decay_fit,[0,0,0,0,0,0,0],[Inf,Inf,Inf,Inf,1,1,Inf],options);
            end
        end
        
        x_fitres = ignore:numel(Decay);
        fitres = model(param,x_fit);fitres = fitres(1:(numel(Decay)-ignore+1));
        
        Decay_ignore = Decay(1:ignore);
        
        TACtoTime = 1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
        %%% Update Plot
        h.Microtime_Plot.Parent = h.HidePanel;
        h.Result_Plot.Parent = h.TauFit_Panel;
        h.Plots.IRFResult.Visible = 'off';
        
        if ignore > 1
            h.Plots.DecayResult_ignore.Visible = 'on';
            h.Plots.Residuals_ignore.Visible = 'off';
            h.Plots.FitResult_ignore.Visible = 'off';
        else
            h.Plots.DecayResult_ignore.Visible = 'off';
            h.Plots.Residuals_ignore.Visible = 'off';
            h.Plots.FitResult_ignore.Visible = 'off';
        end
        
        h.Plots.DecayResult.XData = (ignore:numel(Decay))*TACtoTime;
        h.Plots.DecayResult.YData = Decay_fit;
        h.Plots.DecayResult_ignore.XData = (1:ignore)*TACtoTime;
        h.Plots.DecayResult_ignore.YData = Decay_ignore;
        h.Plots.FitResult.XData = x_fitres*TACtoTime;
        h.Plots.FitResult.YData = fitres;
        axis(h.Result_Plot,'tight');
        h.Result_Plot_Text.Visible = 'on';
        
        %%% update output text
        if number_of_exponentials > 1
            %%% Convert Fraction from Amplitude (species) fraction to Intensity fraction
            %%% (i.e. correct for brightness)
            %%% Intensity is proportional to tau*amplitude
            switch number_of_exponentials
                case 2
                    amp1 = param(2)*TACtoTime*param(4); amp2 = (1-param(4))*param(3)*TACtoTime;
                    f1 = amp1./(amp1+amp2);
                    f2 = amp2./(amp1+amp2);
                    meanTau = TACtoTime*(param(2)*f1+param(3)*f2);

                    % update status text
                    h.Output_Text.String = {sprintf('Mean Lifetime: %.2f ns',meanTau), ['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'],...
                    ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.']};
                case 3
                    amp1 = param(2)*TACtoTime*param(5); amp2 = param(3)*TACtoTime*param(6); amp3 = param(4)*TACtoTime*(1-param(5)-param(6));
                    f1 = amp1./(amp1+amp2+amp3);
                    f2 = amp2./(amp1+amp2+amp3);
                    f3 = amp3./(amp1+amp2+amp3);
                    meanTau = TACtoTime*(param(2)*f1+param(3)*f2+param(4)*f3);

                    % update status text
                    h.Output_Text.String = {sprintf('Mean Lifetime: %.2f ns',meanTau), ['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'],...
                    ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.'],['Intensity fraction of Tau3: ' sprintf('%2.2f',100*f3) ' %.']};
            end
        end
        
        if h.UseWeightedResiduals_Menu.Value
            chi2 = sum(res.^2)./(numel(res)-numel(param)-1);
            str_gof = sprintf('\\chi^2_{red.} = %.2f\n',chi2);
        else
            str_gof = sprintf('norm of residuals = %2.3d\n',sum(res.^2));
        end
        if number_of_exponentials == 1
            str = sprintf('I_0 = %1.2f \n\\tau = %2.2f ns\noffset = %3.2f',param(1),param(2)*TACtoTime,param(3));
        elseif number_of_exponentials == 2
            str = sprintf('I_0 = %1.2f \n\\tau_1 = %1.2f ns\n\\tau_2 = %2.2f ns\namplitude 1 = %3.2f\namplitude 2 = %3.2f\noffset = %3.2f\nmean \\tau = %2.2f ns',...
                param(1),param(2)*TACtoTime,param(3)*TACtoTime,param(4),1-param(4),param(5),meanTau);
        elseif number_of_exponentials == 3
            str = sprintf('I_0 = %1.2f \n\\tau_1 = %1.2f ns\n\\tau_2 = %2.2f ns\n\\tau_3 = %2.2f ns\namplitude 1 = %3.2f\namplitude 2 = %3.2f\namplitude 3 = %3.2f\noffset = %3.2f\nmean \\tau = %2.2f ns',...
                param(1),param(2)*TACtoTime,param(3)*TACtoTime,param(4)*TACtoTime,param(5),param(6),1-param(5)-param(6),param(7),meanTau);
        end
        h.Result_Plot_Text.String = [str_gof,str];
        h.Result_Plot_Text.Position = [0.85 0.99];
        
        x = 1:numel(Decay);
        h.Plots.Residuals.XData = x_fitres*TACtoTime;
        h.Plots.Residuals.YData = res;
        h.Plots.Residuals_ZeroLine.XData = x*TACtoTime;
        h.Plots.Residuals_ZeroLine.YData = zeros(1,numel(x));
        h.Residuals_Plot.YLim = [min(res) max(res)];
        h.Result_Plot.XLim(1) = 0;
        h.Result_Plot.YLabel.String = 'Intensity [counts]';
        
        %%% hide aniso plots
        h.Result_Plot.Position = [0.075 0.075 0.9 0.775];
        h.Result_Plot_Aniso.Parent = h.HidePanel;
        
        % hide plots
        h.Plots.IRFResult_Perp.Visible = 'off';
        h.Plots.FitResult_Perp.Visible = 'off';
        h.Plots.FitResult_Perp_ignore.Visible = 'off';
        h.Plots.DecayResult_Perp.Visible = 'off';
        h.Plots.DecayResult_Perp_ignore.Visible = 'off';
        h.Plots.Residuals_Perp.Visible = 'off';
        h.Plots.Residuals_Perp_ignore.Visible = 'off';

        % change colors
        h.Plots.IRFResult.Color = [0.6 0.6 0.6];
        h.Plots.DecayResult.Color = [0 0 0];
        h.Plots.Residuals.Color = [0 0 0];
        h.Plots.Residuals_ignore.Color = [0.6 0.6 0.6];
end

%%% Reset Progressbar
Progress(1,h.Progress_Axes,h.Progress_Text,'Fit done');
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Plots Anisotropy and Fit Single Exponential %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineGFactor(obj,~)
global TauFitData UserValues
h = guidata(findobj('Tag','TauFit'));
if ~strcmp(TauFitData.Who, 'TauFit') && ~strcmp(TauFitData.Who, 'External')
    % Burstwise lifetime and Burstbrowser subensembe TCSPC
    chan = h.ChannelSelect_Popupmenu.Value;
else
    chan = TauFitData.chan;
end
%%% Read out the data from the plots
ignore = TauFitData.Ignore{chan};
MI = h.Plots.Decay_Par.XData;
Decay_Par = h.Plots.Decay_Par.YData;
Decay_Per = h.Plots.Decay_Per.YData;
%%% Calculate Anisotropy
l1 = UserValues.TauFit.l1;
l2 = UserValues.TauFit.l2;
Anisotropy = (Decay_Par-Decay_Per)./((1-3*l2).*Decay_Par + (2-3*l1)*Decay_Per);
Anisotropy(isnan(Anisotropy)) = 0;
Anisotropy_fit = Anisotropy(ignore:end);
x_ax = 1:numel(Anisotropy_fit);
%%% Define FitFunction
Fit_Exp = @(p,x) (p(1)-p(3)).*exp(-x./p(2)) + p(3);
%%% perform fit
if obj == h.G_factor_edit %user edited the G factor editbox
    offset=(1-UserValues.TauFit.G{chan})/(2*UserValues.TauFit.G{chan}+1);
    x0 = [0.4,round(1/TauFitData.TACChannelWidth),offset];
    lb = [0,0,0.99*offset];
    ub = [0.4,Inf,1.01*offset];
    if ub(3) == 0;
        ub(3) = 0.01;
    end
else %user pressed Get G
    x0 = [0.4,round(1/TauFitData.TACChannelWidth),0];
    lb = [0,0,-0.4];
    ub = [0.4,Inf,0.4];
end
[x,~,res] = lsqcurvefit(Fit_Exp,x0,x_ax,Anisotropy_fit,lb,ub);

FitFun = Fit_Exp(x,x_ax);


%%% Update Plots
h.Microtime_Plot.Parent = h.HidePanel;
h.Result_Plot.Parent = h.TauFit_Panel;
h.Plots.IRFResult.Visible = 'off';
%TACtoTime = 1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
h.Plots.DecayResult.XData = MI(ignore:end);%*TACtoTime;
h.Plots.DecayResult.YData = Anisotropy_fit;
h.Plots.FitResult.XData = MI(ignore:end);%*TACtoTime;
h.Plots.FitResult.YData = FitFun;
h.Plots.DecayResult_ignore.XData = MI(1:ignore);
h.Plots.DecayResult_ignore.YData = Anisotropy(1:ignore);
axis(h.Result_Plot,'tight');
h.Plots.Residuals.XData = MI(ignore:end);%*TACtoTime;
h.Plots.Residuals.YData = res;
h.Plots.Residuals_ZeroLine.XData = MI;%*TACtoTime;
h.Plots.Residuals_ZeroLine.YData = zeros(1,numel(MI));

%%% calculate G
G = (1-x(3))./(1+2*x(3));
h.Result_Plot_Text.Visible = 'on';
TACtoTime = 1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
h.Result_Plot_Text.String = sprintf(['rho = ' num2str(x(2)*TACtoTime) ' ns \nr_0 = ' num2str(x(1))...
    '\nr_i_n_f = ' num2str(x(3))]);
h.Result_Plot_Text.Position = [0.8*h.Result_Plot.XLim(2)*TACtoTime 0.9*h.Result_Plot.YLim(2)];
h.G_factor_edit.String = num2str(G);
UserValues.TauFit.G{chan} = G;
%%% assign G factor to correct burst channel (donor/acceptor)
switch UserValues.BurstSearch.Method
    case {1,2} % 2 color MFD
        switch chan
            case 1 %%% green donor
                UserValues.BurstBrowser.Corrections.GfactorGreen = G;
            case 2 %%% red acceptor 
                UserValues.BurstBrowser.Corrections.GfactorRed = G;
        end
    case {3,4}
        switch chan
            case 1 %%% blue donor
                UserValues.BurstBrowser.Corrections.GfactorBlue = G;
            case 2 %%% green acceptor/donor
                UserValues.BurstBrowser.Corrections.GfactorGreen = G;
            case 3 %%% red acceptor
                UserValues.BurstBrowser.Corrections.GfactorRed = G;
        end
end
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Executes on key press on main axis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TauFit_KeyPress(obj,eventdata)
global TauFitData
h = guidata(obj);

if strcmp(eventdata.Key,'f')
    %%% Start reconvolution fit
    Start_Fit(h.Fit_Button,[]);
end
if ~isempty(TauFitData) %~strcmp(TauFitData.Who, 'Burstwise') %%% for burstwise, only start fit is relevant
    if isempty(eventdata.Modifier)
        if strcmp(eventdata.Key,'a')
            %%% fit anisotropy
            Start_Fit(h.Fit_Aniso_Button,[])
        elseif strcmp(eventdata.Key,'t')
            %%% tailfit
            Start_Fit(h.Fit_Tail_Button,[]);
        end
    elseif strcmp(eventdata.Modifier,'shift')
        if strcmp(eventdata.Key,'a')
            %%% fit anisotropy
            Start_Fit(h.Fit_Aniso_2exp,[])
        elseif strcmp(eventdata.Key,'t')
            %%% tailfit
            Start_Fit(h.Fit_Tail_2exp,[]);
        end
    end
end
if strcmp(TauFitData.Who,'TauFit')
    if strcmp(eventdata.Key,'g')
    %%% determine the g factor
    Start_Fit(h.Determine_GFactor_Button,[])
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Export Graph to figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = ExportGraph(obj,~)
global TauFitData
% anders, in Burstbrowser there was code to plot fit parameters on graph.
h = guidata(findobj('tag','TauFit'));
f = figure('Position',[100,100,700,500],'color',[1 1 1]);
panel_copy = copyobj(h.TauFit_Panel,f);
panel_copy.Position = [0 0 1 1];
panel_copy.ShadowColor = [1 1 1];
%%% set Background Color to white
panel_copy.BackgroundColor = [1 1 1];
panel_copy.HighlightColor = [1 1 1];
ax = panel_copy.Children;
delete(ax(1));ax = ax(2:end);

for i = 1:numel(ax)
    ax(i).Color = [1 1 1];
    ax(i).XColor = [0 0 0];
    ax(i).YColor = [0 0 0];
    ax(i).LineWidth = 3;
    ax(i).FontSize = 18;
    ax(i).XLabel.Color = [0,0,0];
    ax(i).YLabel.Color = [0,0,0];
    ax(i).Layer = 'top';
    for j = 1:numel(ax(i).Children)
        if strcmp(ax(i).Children(j).Type,'line')
            ax(i).Children(j).LineWidth = 2;
        end
    end
end

if ~any(strcmp(TauFitData.FitType,{'Fit Anisotropy','Fit Anisotropy (2 exp rot)','Fit Anisotropy (2 exp lifetime)','Fit Anisotropy (2 exp lifetime, 2 exp rot)'}))
    %%% no anisotropy fit
    for i = 1:numel(ax)
        switch ax(i).Tag
            case 'Microtime_Plot'
                ax(i).Position = [0.1 0.15 0.875 0.70];
                if ~isequal(obj, h.Microtime_Plot_Export)
                    ax(i).Children(end).FontSize = 20; %resize the chi^2 thing
                    ax(i).Children(end).Position(2) = 0.9;
                end
                if strcmp(h.Microtime_Plot.YScale,'log')
                    ax(i).YScale = 'log';
                end
            case 'Residuals_Plot'
                ax(i).Position = [0.1 0.85 0.875 .12];
        end
    end
else
    for i = 1:numel(ax)
        switch ax(i).Tag
            case 'Result_Plot_Aniso'
                ax(i).Position = [0.1 0.13 0.875 0.15];
                if strcmp(h.Microtime_Plot.YScale,'log')
                    ax(i).YScale = 'log';
                end
            case 'Microtime_Plot'
                ax(i).Position = [0.1 0.28 0.875 0.58];
                ax(i).XTickLabels = [];
                ax(i).XLabel.String = '';
                if ~isequal(obj, h.Microtime_Plot_Export)
                    ax(i).Children(end).FontSize = 20; %resize the chi^2 thing
                    ax(i).Children(end).Position(2) = 0.9;
                end
                if strcmp(h.Microtime_Plot.YScale,'log')
                    ax(i).YScale = 'log';
                end
            case 'Residuals_Plot'
                ax(i).Position = [0.1 0.86 0.875 .13];
                ax(i).YTickLabelMode = 'auto';
        end
    end
end

if strcmp(TauFitData.Who, 'TauFit')
    a = ['_Decay_' h.PIEChannelPar_Popupmenu.String{h.PIEChannelPar_Popupmenu.Value}...
        '_x_' h.PIEChannelPer_Popupmenu.String{h.PIEChannelPer_Popupmenu.Value}];
else% if strcmp(TauFitData.Who, 'Burstwise') or strcmp(TauFitData.Who, 'BurstBrowser')
    a = ['_Decay_' h.ChannelSelect_Popupmenu.String{h.ChannelSelect_Popupmenu.Value}];
end

if isequal(obj,  h.Microtime_Plot_Export)
    b = '_data.tif';
else
    b = '_fit.tif';
end
if strcmp(TauFitData.Who,'BurstBrowser')
    Species = strsplit(h.SpeciesSelect_Text.String(2,:),': ');
    c  =  ['_' strjoin(strsplit(Species{2},' '),'')];
else
    c = '';
end
f.PaperPositionMode = 'auto';
print(f, '-dtiff', '-r150', GenerateName([TauFitData.FileName(1:end-4) a c b],1))

if ~isequal(obj,  h.Microtime_Plot_Export) %%% Exporting fit result
    %%% get name of file
    %%% Make table from fittable and save as txt
    tab = cell2table(h.FitPar_Table.Data(:,1),'RowNames',h.FitPar_Table.RowName,'VariableNames',{'Result'});
    writetable(tab,GenerateName([TauFitData.FileName(1:end-4) a c '.txt'],1),'WriteRowNames',true,'Delimiter','\t');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Simulate Kappa2 distribution based on residual anisotropies %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Kappa2_Sim(obj,~)
global UserValues TauFitData
val = inputdlg({'r0(Donor)','residual donor anisotropy','r0(Acceptor)','residual acceptor anisotropy','residual transfer anisotropy'},...
    'Please specify the anisotropy values',1,{num2str(UserValues.BurstBrowser.Corrections.r0_green),'0.1',num2str(UserValues.BurstBrowser.Corrections.r0_red),'0.1','0'});

r0d = str2double(val{1});
rinfd = str2double(val{2});
r0a = str2double(val{3});
rinfa = str2double(val{4});
rinfad = str2double(val{5});
%% kappa2 calculation

%%%
% Calculation is based on the following papers:
% 1. Ivanov, V., Li, M. & Mizuuchi, K. Impact of emission anisotropy on fluorescence spectroscopy and FRET distance measurements. Biophys J 97, 922?929 (2009).
% 2. Sindbert, S. et al. Accurate Distance Determination of Nucleic Acids via F?rster Resonance Energy Transfer: Implications of Dye Linker Length and Rigidity. J. Am. Chem. Soc. 133, 2463?2480 (2011).
%%%
%%% calculate depolarizations
SD = sqrt(rinfd/r0d);
SA = sqrt(rinfa/r0a);

%%% estimate the mean angle between the dipoles
% Equation 20 from (1)
try
    cos_thetaDA = sqrt((1+2*(rinfad/SA/SD/r0a))/3);
   
catch
    % division by zero occured, default to 1/3
    cos_thetaDA= sqrt(1/3);
end
thetaDA = acos(cos_thetaDA);

%%% draw angles uniformly
%sampling = 1E6;
%thetaD = pi/2*(rand(sampling,1));
%thetaA = pi/2*(rand(sampling,1));

%%% systematic sampling of the space
% requires linear sampling because of how the angles are defined
% see Figure 3 from (1)
[thetaD,thetaA] = meshgrid(linspace(0,pi/2,1000),linspace(0,pi/2,1000));
thetaD = thetaD(:);
thetaA = thetaA(:);

%%% remove invalid angle combinations
% Equation 17 from (1)
valid = (cos(thetaD+thetaA) <= cos_thetaDA) & (cos(thetaD-thetaA) >= cos_thetaDA);

%%% calculation of kappa2
% Equation 21-22 from (1)
kappa2_0 = (3*cos(thetaA).*cos(thetaD)-cos(thetaDA)).^2;
kappa2 = SD*SA*kappa2_0+(1-SA).*(SD.*(cos(thetaD)).^2+1/3)+(1-SD).*(SA*(cos(thetaA)).^2+1/3);
kappa2 = kappa2(valid);

%%% we can define accuracy and prediction values of distances determined
%%% with the "wrong" kappa2 assumption of 2/3 based on the information
% Equation S17A-B in (2)
accuracy = (mean((kappa2/(2/3)).^(-1/6))-1)*100;
precision = (sqrt(var((kappa2/(2/3)).^(-1/6))))*100;

%%% These are absolute worst case boundaries for when NO transfer
%%% anisotropy is known
kappa2_min = (2/3)*(1-(sqrt(rinfd/r0d)+sqrt(rinfa/r0a))/2);
kappa2_max = (2/3)*(1+sqrt(rinfd/r0d)+sqrt(rinfa/r0a)+3*sqrt(rinfd/r0d)*sqrt(rinfa/r0a));


%%% Make a nice figure to show the results
hfig = figure('Color',[1,1,1]);hhist = histogram(kappa2,'Normalization','probability');
hhist.EdgeColor = 'none';
ax = gca;
ax.XLim(1) = 0;
ax.Color = [1,1,1];
ax.FontSize = 24;
xlabel('\kappa^2');
ylabel('probability');
ax.Units = 'Pixels';
ht = text(ax.XLim(2)*0.55,ax.YLim(2)*0.85,sprintf(['\\langle\\kappa^2\\rangle =  %.2f' char(177) '%.2f\nAccuracy: %.1f%%\nPrecision: %.1f%%'],mean(kappa2),std(kappa2),accuracy,precision));
ht.FontSize = 24;
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

% Anders, I deleted the Pre-fit thing, I didn't see a use for it any longer

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Burstwise Lifetime Fit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BurstWise_Fit(obj,~)
global BurstData UserValues TauFitData
h = guidata(findobj('Tag','TauFit'));

if ~isempty(findobj('Tag','Pam'))
    ph = guidata(findobj('Tag','Pam'));
end

h.Progress_Text.String = 'Opening Parallel Pool ...';
StartParPool();

h.Progress_Text.String = 'Preparing Lifetime Fit...';
drawnow;

switch TauFitData.BAMethod
    case {1,2,5}
        %% 2 color MFD
        %% Read out corrections
        G = UserValues.TauFit.G; %is a cell, contains all G factors
        l1 = UserValues.TauFit.l1;
        l2 = UserValues.TauFit.l2;
        
        %%% Rename variables
        Microtime = TauFitData.Microtime;
        Channel = TauFitData.Channel;
        %%% Determine bin width for coarse binning
        new_bin_width = floor(0.1/TauFitData.TACChannelWidth);
        
        %%% Read out burst duration
        duration = BurstData.DataArray(:,strcmp(BurstData.NameArray,'Duration [ms]'));
        %%% Read out Background Countrates per Chan
        background{1} = G{1}*(1-3*l2)*BurstData.Background.Background_GGpar + (2-3*l1)*BurstData.Background.Background_GGperp;
        background{2} = G{2}*(1-3*l2)*BurstData.Background.Background_RRpar + (2-3*l1)*BurstData.Background.Background_RRperp;
        
        Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting Data...');
        %%% Process in Chunk
        %%% Prepare Chunks:
        parts = (floor(linspace(1,numel(Microtime),21)));
        parts(1) = 0;
        %%% Preallocate lifetime array
        lifetime{1} = cell(numel(parts)-1,1);
        lifetime{2} = cell(numel(parts)-1,1);
        %%% Prepare Fit Model
        mean_tau = 5;
        range_tau = 9.98;
        steps_tau = 2111;
        range = mean_tau-range_tau/2:range_tau/steps_tau:mean_tau+range_tau/2;
        %% Prepare the data
        for chan = 1:2
            if UserValues.TauFit.IncludeChannel(chan)
                h.ChannelSelect_Popupmenu.Value = chan;
                Update_Plots(obj);
                %%% User clicked 'Burst Analysis' button on the Burst or
                %%% Batch analysis tab in Pam when 'Fit Lifetime' checkbox was checked.
                if obj == ph.Burst.Button
                    %%% User right-clicked the 'Fit Lifetime' checkbox in
                    %%% Pam and enabled 'automatic IRF shift'.
                    if strcmp(UserValues.BurstSearch.AutoIRFShift,'on')
                        h.FitPar_Table.Data{end,4} = false; %free the IRFshift
                        h.FitPar_Table.Data{end,2} = -20; %LB
                        h.FitPar_Table.Data{end,3} = 20; %UB
                        Start_Fit(h.Fit_Button,[]) % Callback Pre-Fit
                    end
                end
                if UserValues.BurstSearch.BurstwiseLifetime_SaveImages
                    %%% Save image of the individual decays
                    Update_Plots(obj)
                    f = ExportGraph(h.Microtime_Plot_Export);
                    close(f)
                    %%% Save image of the fit
                    h.FitPar_Table.Data{end,4} = true; %fix the IRF shift
                    Start_Fit(h.Fit_Button,[]) % Callback Pre-Fit
                    f = ExportGraph(h.Export_Result);
                    close(f)
                end
  
                % I just read the data from the plots to avoid confusion.
                %Irf = G{chan}*(1-3*l2)*h.Plots.IRF_Par.YData+(2-3*l1)*h.Plots.IRF_Per.YData;
                %%% Changed this back so a better correction of the IRF can be
                %%% performed, for which the total IRF pattern is needed!
                %%% Apply the shift to the parallel IRF channel
                hIRF_par = circshift(TauFitData.hIRF_Par{chan},[0,TauFitData.IRFShift{chan}])';
                %%% Apply the shift to the perpendicular IRF channel
                hIRF_per = circshift(TauFitData.hIRF_Per{chan},[0,TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan}])';
                IRFPattern = G{chan}*(1-3*l2)*hIRF_par(1:TauFitData.Length{chan}) + (2-3*l1)*hIRF_per(1:TauFitData.Length{chan});
                IRFPattern = IRFPattern'./sum(IRFPattern);
                %%% additional processing of the IRF to remove constant background
                IRFPattern = IRFPattern - mean(IRFPattern(end-round(numel(IRFPattern)/10):end)); IRFPattern(IRFPattern<0) = 0;
                Irf =  IRFPattern((TauFitData.StartPar{chan}+1):TauFitData.IRFLength{chan});
                
                %Irf = Irf-min(Irf(Irf~=0));
                Irf = Irf./sum(Irf);
                IRF{chan} = [Irf zeros(1,TauFitData.Length{chan}-numel(Irf))];
                %%% Scatter is still read from plots
                Scatter = G{chan}*(1-3*l2)*h.Plots.Scat_Par.YData + (2-3*l1)*h.Plots.Scat_Per.YData;
                SCATTER{chan} = Scatter./sum(Scatter);
                Length{chan} = numel(Scatter)-1;
                
                [tau, i] = meshgrid(mean_tau-range_tau/2:range_tau/steps_tau:mean_tau+range_tau/2, 0:Length{chan});
                T = TauFitData.TACChannelWidth*Length{chan};
                GAMMA = T./tau;
                p = exp(-i.*GAMMA/Length{chan}).*(exp(GAMMA/Length{chan})-1)./(1-exp(-GAMMA));
                %p = p(1:length+1,:);
                c = convnfft(p,IRF{chan}(ones(steps_tau+1,1),:)', 'full', 1);   %%% Linear Convolution!
                c(c<0) = 0;
                z = sum(c,1);
                c = c./z(ones(size(c,1),1),:);
                c = c(1:Length{chan}+1,:);
                %         model = (1-background{chan})*c + background{chan};
                %         z = sum(model,1);
                %         model = model./z(ones(size(model,1),1),:);
                %         model = (1-scatter{chan})*model + scatter{chan}*SCATTER{chan}(ones(steps_tau+1,1),:)';
                model = c;
                z = sum(model,1);
                model = model./z(ones(size(model,1),1),:);
                %%% Rebin to improve speed
                model_dummy = zeros(floor(size(model,1)/new_bin_width),size(model,2));
                for i = 1:size(model,2)
                    model_dummy(:,i) = downsamplebin(model(:,i),new_bin_width);
                end
                model = model_dummy;
                z = sum(model,1);model = model./z(ones(size(model,1),1),:);
                MODEL{chan} = model;
                %%% Rebin SCATTER pattern
                SCATTER{chan} = downsamplebin(SCATTER{chan},new_bin_width);
                SCATTER{chan} = SCATTER{chan}./sum(SCATTER{chan});
            end
        end
        % put channel back to 1
        h.ChannelSelect_Popupmenu.Value = 1;
        Update_Plots(obj)
        h.Progress_Text.String = 'Fitting Data...';
        for j = 1:(numel(parts)-1)
            MI = Microtime((parts(j)+1):parts(j+1));
            CH = Channel((parts(j)+1):parts(j+1));
            DUR = duration((parts(j)+1):parts(j+1));
            if UserValues.TauFit.IncludeChannel(1)
                %%% Create array of histogrammed microtimes
                switch TauFitData.BAMethod
                    case {1,2}
                        Par1 = zeros(numel(MI),numel(BurstData.PIE.From(1):BurstData.PIE.To(1)));
                        Per1 = zeros(numel(MI),numel(BurstData.PIE.From(2):BurstData.PIE.To(2)));
                        parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                            Par1(i,:) = histc(MI{i}(CH{i} == 1),(BurstData.PIE.From(1):BurstData.PIE.To(1)))';
                            Per1(i,:) = histc(MI{i}(CH{i} == 2),(BurstData.PIE.From(2):BurstData.PIE.To(2)))';
                        end                
                    case 5
                        Par1 = zeros(numel(MI),numel(BurstData.PIE.From(1):BurstData.PIE.To(1)));
                        Per1 = Par1;
                        parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                            Par1(i,:) = histc(MI{i}(CH{i} == 1),(BurstData.PIE.From(1):BurstData.PIE.To(1)))';
                            Per1(i,:) = Par1(i,:);
                        end                
                end
                Mic{1} = zeros(numel(MI),numel((TauFitData.StartPar{1}+1):TauFitData.Length{1}));
                %%% Shift Microtimes
                Par1 = Par1(:,(TauFitData.StartPar{1}+1):TauFitData.Length{1});
                Per1 = circshift(Per1,[0,TauFitData.ShiftPer{1}]);
                Per1 = Per1(:,(TauFitData.StartPar{1}+1):TauFitData.Length{1});                
                Mic{1} = (1-3*l2)*G{1}*Par1+(2-3*l1)*Per1;
                clear Par1 Per1
                
                %%% Rebin to improve speed
                Mic1 = zeros(numel(MI),floor(size(Mic{1},2)/new_bin_width));
                parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                    Mic1(i,:) = downsamplebin(Mic{1}(i,:),new_bin_width);
                end
                Mic{1} = Mic1'; clear Mic1;
            end
            if UserValues.TauFit.IncludeChannel(2)
                %%% Create array of histogrammed microtimes
                switch TauFitData.BAMethod
                    case {1,2}
                        Par2 = zeros(numel(MI),numel(BurstData.PIE.From(5):BurstData.PIE.To(5)));
                        Per2 = zeros(numel(MI),numel(BurstData.PIE.From(6):BurstData.PIE.To(6)));
                        parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                            Par2(i,:) = histc(MI{i}(CH{i} == 5),(BurstData.PIE.From(5):BurstData.PIE.To(5)))';
                            Per2(i,:) = histc(MI{i}(CH{i} == 6),(BurstData.PIE.From(6):BurstData.PIE.To(6)))';
                        end
                    case 5
                        Par2 = zeros(numel(MI),numel(BurstData.PIE.From(3):BurstData.PIE.To(3)));
                        Per2 = Par2;
                        parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                            Par2(i,:) = histc(MI{i}(CH{i} == 3),(BurstData.PIE.From(3):BurstData.PIE.To(3)))';
                            Per2(i,:) = Par2(i,:);
                        end
                end
                Mic{2} = zeros(numel(MI),numel((TauFitData.StartPar{2}+1):TauFitData.Length{2}));
                
                %%% Shift Microtimes
                Par2 = Par2(:,(TauFitData.StartPar{2}+1):TauFitData.Length{2});
                Per2 = circshift(Per2,[0,TauFitData.ShiftPer{2}]);
                Per2 = Per2(:,(TauFitData.StartPar{2}+1):TauFitData.Length{2});
                Mic{2} = (1-3*l2)*G{2}*Par2+(2-3*l1)*Per2;
                clear Par2 Per2
                
                %%% Rebin to improve speed
                Mic2 = zeros(numel(MI),floor(size(Mic{2},2)/new_bin_width));
                
                parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                    Mic2(i,:) = downsamplebin(Mic{2}(i,:),new_bin_width);
                end
                Mic{2} = Mic2'; clear Mic2;
            end
            
            %% Fitting...
            %%% Prepare the fit inputs
            lt = zeros(numel(MI),2);
            for chan = 1:2
                if UserValues.TauFit.IncludeChannel(chan)
                    %%% Calculate Background fraction
                    bg = DUR.*background{chan};
                    signal = sum(Mic{chan},1)';
                    
                    use_bg = h.BackgroundInclusion_checkbox.Value;
                    if use_bg == 1
                        fraction_bg = bg./signal;
                        fraction_bg(fraction_bg>1) = 1;
                    else
                        fraction_bg = zeros(size(bg,1),size(bg,2));
                    end
                    
                    model = MODEL{chan}; 
                    scat = SCATTER{chan}(:,ones(steps_tau+1,1));
                    microTimes = Mic{chan};
                    
                    lt(:,chan) = LifetimeFitMLE_array(microTimes(:),model(:),range,size(model,2),size(model,1),size(microTimes,2),scat,fraction_bg);
                    %%% set lifetime to NaN if no signal was present
                    lt(fraction_bg == 1,chan) = NaN;
                    
                    %parfor (i = 1:size(Mic{chan},2),UserValues.Settings.Pam.ParallelProcessing)
                    %    
                    %    if fraction_bg(i) == 1
                    %        lt(i,chan) = NaN;
                    %    else
                    %        %%% Implementation of burst-wise background correction
                    %        %%% Calculate Fractions of Background and Signal
                    %        % if 50% of signal is background, fraction_bg in the following model will be approximately 0.5
                    %        if use_bg
                    %            modelfun = (1-fraction_bg(i)).*model + fraction_bg(i).*scat;
                    %        else
                    %            modelfun = model;
                    %        end
                    %        %[lt(i,chan),~] = LifetimeFitMLE(Mic{chan}(:,i),modelfun,range);
                    %        lt(i,chan) = LifetimeFitMLE_c(microTimes(:,i)./sum(microTimes(:,i)),modelfun(:),range,size(modelfun,2),size(modelfun,1));
                    %     end
                    %end
                end
            end
            lifetime{j} = lt;
            Progress(j/(numel(parts)-1),h.Progress_Axes,h.Progress_Text,'Fitting Data...');
        end
        lifetime = vertcat(lifetime{:});
        %% Save the result
        Progress(1,h.Progress_Axes,h.Progress_Text,'Saving...');
        idx_tauGG = strcmp('Lifetime GG [ns]',BurstData.NameArray);
        idx_tauRR = strcmp('Lifetime RR [ns]',BurstData.NameArray);
        % will be zeros if lifetime is not included
        if UserValues.TauFit.IncludeChannel(1)
            BurstData.DataArray(:,idx_tauGG) = lifetime(:,1);
        end
        if UserValues.TauFit.IncludeChannel(2)
            BurstData.DataArray(:,idx_tauRR) = lifetime(:,2);
        end
    case {3,4}
        %% Three-Color MFD
        %% Read out corrections
        G = UserValues.TauFit.G;
        l1 = UserValues.TauFit.l1;
        l2 = UserValues.TauFit.l2;
        
        %%% Rename variables
        Microtime = TauFitData.Microtime;
        Channel = TauFitData.Channel;
        %%% Determine bin width for coarse binning
        new_bin_width = floor(0.1/TauFitData.TACChannelWidth);
        
        %%% Read out burst duration
        duration = BurstData.DataArray(:,strcmp(BurstData.NameArray,'Duration [ms]'));
        %%% Read out Background Countrates per Chan
        %anders
        %         background{1} = UserValues.BurstBrowser.Corrections.Background_BBpar + UserValues.BurstBrowser.Corrections.Background_BBperp;
        %         background{2} = UserValues.BurstBrowser.Corrections.Background_GGpar + UserValues.BurstBrowser.Corrections.Background_GGperp;
        %         background{3} = UserValues.BurstBrowser.Corrections.Background_RRpar + UserValues.BurstBrowser.Corrections.Background_RRperp;
        background{1} = G{1}*(1-3*l2)*BurstData.Background.Background_BBpar + (2-3*l1)*BurstData.Background.Background_BBperp;
        background{2} = G{2}*(1-3*l2)*BurstData.Background.Background_GGpar + (2-3*l1)*BurstData.Background.Background_GGperp;
        background{3} = G{3}*(1-3*l2)*BurstData.Background.Background_RRpar + (2-3*l1)*BurstData.Background.Background_RRperp;
        
        Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting Data...');
        %%% Process in Chunk
        %%% Prepare Chunks:
        parts = (floor(linspace(1,numel(Microtime),21)));
        parts(1) = 0;
        %%% Preallocate lifetime array
        lifetime{1} = cell(numel(parts)-1,1);
        lifetime{2} = cell(numel(parts)-1,1);
        lifetime{3} = cell(numel(parts)-1,1);
        %%% Prepare Fit Model
        mean_tau = 5;
        range_tau = 9.98;
        steps_tau = 2111;
        range = mean_tau-range_tau/2:range_tau/steps_tau:mean_tau+range_tau/2;
        %% Prepare the data
        for chan = 1:3
            if UserValues.TauFit.IncludeChannel(chan)
                % call Update_plots to get the correctly shifted Scatter and IRF directly from the plot
                h.ChannelSelect_Popupmenu.Value = chan;
                Update_Plots(obj)
                %%% User clicked 'Burst Analysis' button on the Burst or
                %%% Batch analysis tab in Pam when 'Fit Lifetime' checkbox was checked.
                if obj == ph.Burst.Button
                    %%% User right-clicked the 'Fit Lifetime' checkbox in
                    %%% Pam and enabled 'automatic IRF shift'.
                    if strcmp(UserValues.BurstSearch.AutoIRFShift,'on')
                        h.FitPar_Table.Data{end,4} = false; %free the IRFshift
                        h.FitPar_Table.Data{end,2} = -20; %LB
                        h.FitPar_Table.Data{end,3} = 20; %UB
                        Start_Fit(h.Fit_Button,[]) % Callback Pre-Fit
                    end
                end
                if UserValues.BurstSearch.BurstwiseLifetime_SaveImages
                    %%% Save image of the individual decays
                    Update_Plots(obj)
                    f = ExportGraph(h.Microtime_Plot_Export);
                    close(f)
                    %%% Save image of the fit
                    h.FitPar_Table.Data{end,4} = true; %fix the IRF shift
                    Start_Fit(h.Fit_Button,[]) % Callback Pre-Fit
                    f = ExportGraph(h.Export_Result);
                    close(f)
                end
                %Irf = G{chan}*(1-3*l2)*h.Plots.IRF_Par.YData+(2-3*l1)*h.Plots.IRF_Per.YData;
                %%% Changed this back so a better correction of the IRF can be
                %%% performed, for which the total IRF pattern is needed!
                %%% Apply the shift to the parallel IRF channel
                hIRF_par = circshift(TauFitData.hIRF_Par{chan},[0,TauFitData.IRFShift{chan}])';
                %%% Apply the shift to the perpendicular IRF channel
                hIRF_per = circshift(TauFitData.hIRF_Per{chan},[0,TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan}])';
                IRFPattern = G{chan}*(1-3*l2)*hIRF_par(1:TauFitData.Length{chan}) + (2-3*l1)*hIRF_per(1:TauFitData.Length{chan});
                IRFPattern = IRFPattern'./sum(IRFPattern);
                %%% additional processing of the IRF to remove constant background
                IRFPattern = IRFPattern - mean(IRFPattern(end-round(numel(IRFPattern)/10):end)); IRFPattern(IRFPattern<0) = 0;
                Irf =  IRFPattern((TauFitData.StartPar{chan}+1):TauFitData.IRFLength{chan});
                
                %Irf = Irf-min(Irf(Irf~=0));
                Irf = Irf./sum(Irf);
                IRF{chan} = [Irf zeros(1,TauFitData.Length{chan}-numel(Irf))];
                %%% Scatter is still read from the plots
                Scatter = G{chan}*(1-3*l2)*h.Plots.Scat_Par.YData + (2-3*l1)*h.Plots.Scat_Per.YData;
                SCATTER{chan} = Scatter./sum(Scatter);
                Length{chan} = numel(Scatter)-1;
                
                [tau, i] = meshgrid(mean_tau-range_tau/2:range_tau/steps_tau:mean_tau+range_tau/2, 0:Length{chan});
                T = TauFitData.TACChannelWidth*Length{chan};
                GAMMA = T./tau;
                p = exp(-i.*GAMMA/Length{chan}).*(exp(GAMMA/Length{chan})-1)./(1-exp(-GAMMA));
                %p = p(1:length+1,:);
                c = convnfft(p,IRF{chan}(ones(steps_tau+1,1),:)', 'full', 1); %%% Linear Convolution!
                c(c<0) = 0;
                z = sum(c,1);
                c = c./z(ones(size(c,1),1),:);
                c = c(1:Length{chan}+1,:);
                %         model = (1-background{chan})*c + background{chan};
                %         z = sum(model,1);
                %         model = model./z(ones(size(model,1),1),:);
                %         model = (1-scatter{chan})*model + scatter{chan}*SCATTER{chan}(ones(steps_tau+1,1),:)';
                model = c;
                z = sum(model,1);
                model = model./z(ones(size(model,1),1),:);
                %%% Rebin to improve speed
                model_dummy = zeros(floor(size(model,1)/new_bin_width),size(model,2));
                for i = 1:size(model,2)
                    model_dummy(:,i) = downsamplebin(model(:,i),new_bin_width);
                end
                model = model_dummy;
                z = sum(model,1);model = model./z(ones(size(model,1),1),:);
                MODEL{chan} = model;
                %%% Rebin SCATTER pattern
                SCATTER{chan} = downsamplebin(SCATTER{chan},new_bin_width);SCATTER{chan} = SCATTER{chan}./sum(SCATTER{chan});
            end
        end
        % put channel back to 1
        h.ChannelSelect_Popupmenu.Value = 1;
        Update_Plots(obj)
        h.Progress_Text.String = 'Fitting Data...';
        for j = 1:(numel(parts)-1)
            MI = Microtime((parts(j)+1):parts(j+1));
            CH = Channel((parts(j)+1):parts(j+1));
            DUR = duration((parts(j)+1):parts(j+1));
            if UserValues.TauFit.IncludeChannel(1)
                %%% Create array of histogrammed microtimes
                Par1 = zeros(numel(MI),numel(BurstData.PIE.From(1):BurstData.PIE.To(1)));
                Per1 = zeros(numel(MI),numel(BurstData.PIE.From(2):BurstData.PIE.To(2)));
                parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                    Par1(i,:) = histc(MI{i}(CH{i} == 1),(BurstData.PIE.From(1):BurstData.PIE.To(1)))';
                    Per1(i,:) = histc(MI{i}(CH{i} == 2),(BurstData.PIE.From(2):BurstData.PIE.To(2)))';
                end
                Mic{1} = zeros(numel(MI),numel((TauFitData.StartPar{1}+1):TauFitData.Length{1}));
                %%% Shift Microtimes
                Par1 = Par1(:,(TauFitData.StartPar{1}+1):TauFitData.Length{1});
                Per1 = circshift(Per1,[0,TauFitData.ShiftPer{1}]);
                Per1 = Per1(:,(TauFitData.StartPar{1}+1):TauFitData.Length{1});
                
                Mic{1} = (1-3*l2)*G{1}*Par1+(2-3*l1)*Per1;
                clear Par1 Per
                
                %%% Rebin to improve speed
                Mic1 = zeros(numel(MI),floor(size(Mic{1},2)/new_bin_width));
                parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                    Mic1(i,:) = downsamplebin(Mic{1}(i,:),new_bin_width);
                end
                Mic{1} = Mic1'; clear Mic1;
            end
            if UserValues.TauFit.IncludeChannel(2)
                %%% Create array of histogrammed microtimes
                Par2 = zeros(numel(MI),numel(BurstData.PIE.From(7):BurstData.PIE.To(7)));
                Per2 = zeros(numel(MI),numel(BurstData.PIE.From(8):BurstData.PIE.To(8)));
                parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                    Par2(i,:) = histc(MI{i}(CH{i} == 7),(BurstData.PIE.From(7):BurstData.PIE.To(7)))';
                    Per2(i,:) = histc(MI{i}(CH{i} == 8),(BurstData.PIE.From(8):BurstData.PIE.To(8)))';
                end
                Mic{2} = zeros(numel(MI),numel((TauFitData.StartPar{2}+1):TauFitData.Length{2}));
                %%% Shift Microtimes
                Par2 = Par2(:,(TauFitData.StartPar{2}+1):TauFitData.Length{2});
                Per2 = circshift(Per2,[0,TauFitData.ShiftPer{2}]);
                Per2 = Per2(:,(TauFitData.StartPar{2}+1):TauFitData.Length{2});
                
                Mic{2} = (1-3*l2)*G{2}*Par2+(2-3*l1)*Per2;
                clear Par2 Per2
                %%% Rebin to improve speed
                Mic2 = zeros(numel(MI),floor(size(Mic{2},2)/new_bin_width));
                parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                    Mic2(i,:) = downsamplebin(Mic{2}(i,:),new_bin_width);
                end
                Mic{2} = Mic2'; clear Mic2;
            end
            if UserValues.TauFit.IncludeChannel(3)
                %%% Create array of histogrammed microtimes
                Par3 = zeros(numel(MI),numel(BurstData.PIE.From(11):BurstData.PIE.To(11)));
                Per3 = zeros(numel(MI),numel(BurstData.PIE.From(12):BurstData.PIE.To(12)));
                parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                    Par3(i,:) = histc(MI{i}(CH{i} == 11),(BurstData.PIE.From(11):BurstData.PIE.To(11)))';
                    Per3(i,:) = histc(MI{i}(CH{i} == 12),(BurstData.PIE.From(12):BurstData.PIE.To(12)))';
                end
                Mic{3} = zeros(numel(MI),numel((TauFitData.StartPar{3}+1):TauFitData.Length{3}));
                
                %%% Shift Microtimes
                Par3 = Par3(:,(TauFitData.StartPar{3}+1):TauFitData.Length{3});
                Per3 = circshift(Per3,[0,TauFitData.ShiftPer{3}]);
                Per3 = Per3(:,(TauFitData.StartPar{3}+1):TauFitData.Length{3});
                
                Mic{3} = (1-3*l2)*G{3}*Par3+(2-3*l1)*Per3;
                clear Par3 Per3
                
                %%% Rebin to improve speed
                
                Mic3 = zeros(numel(MI),floor(size(Mic{3},2)/new_bin_width));
                parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                    Mic3(i,:) = downsamplebin(Mic{3}(i,:),new_bin_width);
                end
                Mic{3} = Mic3'; clear Mic3;
            end
            %% Fit
            %%% Preallocate fit outputs
            lt = zeros(numel(MI),3);
            for chan = 1:3
                if UserValues.TauFit.IncludeChannel(chan)
                    %%% Calculate Background fraction
                    bg = DUR.*background{chan};
                    signal = sum(Mic{chan},1)';
                    
                    use_bg = h.BackgroundInclusion_checkbox.Value;
                    if use_bg == 1
                        fraction_bg = bg./signal;fraction_bg(fraction_bg>1) = 1;
                    else
                        fraction_bg = zeros(size(bg,1),size(bg,2));
                    end
                    
                    model = MODEL{chan};
                    scat = SCATTER{chan}(:,ones(steps_tau+1,1));
                    microTimes = Mic{chan};
                    
                    lt(:,chan) = LifetimeFitMLE_array(microTimes(:),model(:),range,size(model,2),size(model,1),size(microTimes,2),scat,fraction_bg);
                    %%% set lifetime to NaN if no signal was present
                    lt(fraction_bg == 1,chan) = NaN;
                    
                    %parfor (i = 1:size(Mic{chan},2),UserValues.Settings.Pam.ParallelProcessing)
                    %    if fraction_bg(i) == 1
                    %        lt(i,chan) = NaN;
                    %    else
                    %        %%% Implementation of burst-wise background correction
                    %        %%% Calculate Fractions of Background and Signal
                    %        if use_bg
                    %            modelfun = (1-fraction_bg(i)).*model + fraction_bg(i).*scat;
                    %        else
                    %            modelfun = model;
                    %        end
                    %        %[lt(i,chan),~] = LifetimeFitMLE(Mic{chan}(:,i),modelfun,range);
                    %        lt(i,chan) = LifetimeFitMLE_c(microTimes(:,i)./sum(microTimes(:,i)),modelfun(:),range,size(modelfun,2),size(modelfun,1));
                    %    end
                    %end
                end
            end
            lifetime{j} = lt;
            Progress(j/(numel(parts)-1),h.Progress_Axes,h.Progress_Text,'Fitting Data...');
        end
        lifetime = vertcat(lifetime{:});
        %% Save the result
        Progress(1,h.Progress_Axes,h.Progress_Text,'Saving...');
        idx_tauBB = strcmp('Lifetime BB [ns]',BurstData.NameArray);
        idx_tauGG = strcmp('Lifetime GG [ns]',BurstData.NameArray);
        idx_tauRR = strcmp('Lifetime RR [ns]',BurstData.NameArray);
        % will be zeros if lifetime is not included
        if UserValues.TauFit.IncludeChannel(1)
            BurstData.DataArray(:,idx_tauBB) = lifetime(:,1);
        end
        if UserValues.TauFit.IncludeChannel(2)
            BurstData.DataArray(:,idx_tauGG) = lifetime(:,2);
        end
        if UserValues.TauFit.IncludeChannel(3)
            BurstData.DataArray(:,idx_tauRR) = lifetime(:,3);
        end
end
save(TauFitData.FileName,'BurstData');
Progress(1,h.Progress_Axes,h.Progress_Text,'Done');
%%% Change the Color of the Button in Pam
hPam = findobj('Tag','Pam');
handlesPam = guidata(hPam);
handlesPam.Burst.BurstLifetime_Button.ForegroundColor = [0 0.8 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Here are functions used for the fits  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tau,Istar] = LifetimeFitMLE(SIG,model,range)
%%% Inputs:
%%% SIG:    The Microtime Histogram of the Burst
%%% model:  Array containing the pre-convoluted model functions
%%% range:  vector containing the associated lifetime values

%%% Note: Usage of bsxfun makes this code very fast

k=numel(SIG);
SIG = SIG/sum(SIG);
div=100;
MIN=1;
for i=1:3
    
    Range=range(MIN:div:(MIN+20*div));
    Model=model(:,MIN:div:(MIN+20*div));
    temp=bsxfun(@times,log(bsxfun(@ldivide,Model,SIG)),SIG);
    temp(isnan(temp))=0;
    temp(~isfinite(temp)) = 0;
    KL = (1/(k-1-2))*sum(temp,1);
    if sum(KL) == 0
        mean_tau = 0;
        MIN=1;
    else
        mean_tau = Range(KL == min(KL));
        if numel(mean_tau)>1
            mean_tau = mean_tau(1);
        end
        MIN=(find(range==mean_tau,1,'first'))-div;
        if MIN<1
            MIN=1;
        end
    end
    div=div/10;
    
end

tau=mean_tau;
model = model/sum(model);
temp = SIG.*log(SIG./model);
Istar = (2/(numel(SIG)-1-2))*sum(temp(~isnan(temp)));

function [outv] = downsamplebin(invec,newbin)
%%% treat case where mod(numel/newbin) =/= 0
if mod(numel(invec),newbin) ~= 0
    %%% Discard the last bin
    invec = invec(1:(floor(numel(invec)/newbin)*newbin));
end
outv = sum(reshape(invec,newbin,numel(invec)/newbin),1)';

function y = convol(irf, x)
% convol(irf, x) performs a convolution of the instrumental response
% function irf with the decay function x. Periodicity (=length(x)) is assumed.

mm = mean(irf(end-10:end));
if size(x,1)==1 | size(x,2)==1
    irf = irf(:);
    x = x(:);
end
p = size(x,1);
n = length(irf);
if p>n
    irf = [irf; mm*ones(p-n,1)];
else
    irf = irf(1:p);
end
y = real(ifft((fft(irf)*ones(1,size(x,2))).*fft(x)));
t = rem(rem(0:n-1,p)+p,p)+1;
y = y(t,:);

function [z] = lsfit(param, xdata)
%	LSFIT(param, irf, y, p) returns the Least-Squares deviation between the data y
%	and the computed values.
%	LSFIT assumes a function of the form:
%
%	  y =  yoffset + A(1)*convol(irf,exp(-t/tau(1)/(1-exp(-p/tau(1)))) + ...
%
%	param(1) is the color shift value between irf and y.
%	param(2) is the irf offset.
%	param(3:...) are the decay times.
%	irf is the measured Instrumental Response Function.
%	y is the measured fluorescence decay curve.
%	p is the time between to laser excitations (in number of TCSPC channels).
irf = xdata{1};
bg = xdata{2};
p = xdata{3};
y = xdata{4};
c = xdata{5};

n = length(irf);
t = 1:n;
tp = (1:p)';
gamma = param(1);
scatter = param(2);
if numel(param) == 3
    tau = param(3);
elseif numel(param) == 5
    tau = param(3:end-1); tau = tau(:)';
    a1 = param(end);
end

x = exp(-(tp-1)*(1./tau))*diag(1./(1-exp(-p./tau)));
if size(x,2) > 1
    x = a1*x(:,1) + (1-a1)*x(:,2);
end
%irs = irf(rem(rem(t-floor(c)-1, n)+n,n)+1);
irs = circshift(irf,[0 c]);
bg = circshift(bg,[0 c]);
z = convol(irs, x);
z = z./sum(z);
z = (1-scatter).*z + scatter*bg';
z = (1-gamma).*z+gamma;
z = z.*sum(y);
z=z';

function [startpar, names] = GetTableData(model, chan)
% model is the selected fit model in the popupmenu
% chan is the selected (burst or PIE pair) channel
global UserValues
Parameters = cell(7,1);
Parameters{1} = {'Tau [ns]','Scatter','Background','IRF Shift'};
Parameters{2} = {'Tau1 [ns]','Tau2 [ns]','Fraction 1','Scatter','Background','IRF Shift'};
Parameters{3} = {'Tau1 [ns]','Tau2 [ns]','Tau3 [ns]','Fraction 1','Fraction 2','Scatter','Background','IRF Shift'};
Parameters{4} = {'Center R [A]','Sigma R [A]','Scatter','Background','R0 [A]','TauD0 [ns]','IRF Shift'};
Parameters{5} = {'Center R [A]','Sigma R [A]','Fraction Donly','Scatter','Background','R0 [A]','TauD0 [ns]','IRF Shift'};
Parameters{6} = {'Tau [ns]','Rho [ns]','r0','r_infinity','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};
Parameters{7} = {'Tau1 [ns]','Tau2 [ns]','Fraction 1','Rho [ns]','r0','r_infinity','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};
Parameters{8} = {'Tau [ns]','Rho1 [ns]','Rho2 [ns]','r0','r_infinity','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};
Parameters{9} = {'Tau1 [ns]','Tau2 [ns]','Fraction 1','Rho1 [ns]','Rho2 [ns]','r0','r_infinity','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};
%%% Initial Data - Store the StartValues as well as LB and UB
tau1 = UserValues.TauFit.FitParams{chan}(1);
tau2 = UserValues.TauFit.FitParams{chan}(2);
tau3 = UserValues.TauFit.FitParams{chan}(3);
F1 = UserValues.TauFit.FitParams{chan}(4);
F2 = UserValues.TauFit.FitParams{chan}(5);
ScatPar = UserValues.TauFit.FitParams{chan}(6);
ScatPer = UserValues.TauFit.FitParams{chan}(7);
BackPar = UserValues.TauFit.FitParams{chan}(8);
BackPer = UserValues.TauFit.FitParams{chan}(9);

IRF = UserValues.TauFit.IRFShift{chan};

R0 = UserValues.TauFit.FitParams{chan}(11);
tauD0 = UserValues.TauFit.FitParams{chan}(12);
l1 = UserValues.TauFit.FitParams{chan}(13);
l2 = UserValues.TauFit.FitParams{chan}(14);
Rho1 = UserValues.TauFit.FitParams{chan}(15);
Rho2 = UserValues.TauFit.FitParams{chan}(16);
r0 = UserValues.TauFit.FitParams{chan}(17);
rinf = UserValues.TauFit.FitParams{chan}(18);
R = UserValues.TauFit.FitParams{chan}(19);
sigR = UserValues.TauFit.FitParams{chan}(20);
FD0 = UserValues.TauFit.FitParams{chan}(21);

tau1f = UserValues.TauFit.FitFix{chan}(1);
tau2f = UserValues.TauFit.FitFix{chan}(2);
tau3f = UserValues.TauFit.FitFix{chan}(3);
F1f = UserValues.TauFit.FitFix{chan}(4);
F2f = UserValues.TauFit.FitFix{chan}(5);
ScatParf = UserValues.TauFit.FitFix{chan}(6);
ScatPerf = UserValues.TauFit.FitFix{chan}(7);
BackParf = UserValues.TauFit.FitFix{chan}(8);
BackPerf = UserValues.TauFit.FitFix{chan}(9);
IRFf = UserValues.TauFit.FitFix{chan}(10);
R0f = UserValues.TauFit.FitFix{chan}(11);
tauD0f = UserValues.TauFit.FitFix{chan}(12);
l1f = UserValues.TauFit.FitFix{chan}(13);
l2f = UserValues.TauFit.FitFix{chan}(14);
Rho1f = UserValues.TauFit.FitFix{chan}(15);
Rho2f = UserValues.TauFit.FitFix{chan}(16);
r0f = UserValues.TauFit.FitFix{chan}(17);
rinff = UserValues.TauFit.FitFix{chan}(18);
Rf = UserValues.TauFit.FitFix{chan}(19);
sigRf = UserValues.TauFit.FitFix{chan}(20);
FD0f = UserValues.TauFit.FitFix{chan}(21);

StartPar = cell(7,1);
StartPar{1} = {tau1,0,Inf,tau1f;ScatPar,0,1,ScatParf;BackPar,0,1,BackParf;IRF,0,0,IRFf};
StartPar{2} = {tau1,0,Inf,tau1f;tau2,0,Inf,tau2f;F1,0,1,F1f;ScatPar,0,1,ScatParf;BackPar,0,1,BackParf;IRF,0,0,IRFf};
StartPar{3} = {tau1,0,Inf,tau1f;tau2,0,Inf,tau2f;tau3,0,Inf,tau3f;F1,0,1,F1f;F2,0,1,F2f;ScatPar,0,1,ScatParf;BackPar,0,1,BackParf;IRF,0,0,IRFf};
StartPar{4} = {R,0,Inf,Rf;sigR,0,Inf,sigRf;ScatPar,0,1,ScatParf;BackPar,0,1,BackParf;R0,0,Inf,R0f;tauD0,0,Inf,tauD0f;IRF,0,0,IRFf};
StartPar{5} = {R,0,Inf,Rf;sigR,0,Inf,sigRf;FD0,0,1,FD0f;ScatPar,0,1,ScatParf;BackPar,0,1,BackParf;R0,0,Inf,R0f;tauD0,0,Inf,tauD0f;IRF,0,0,IRFf};
StartPar{6} = {tau1,0,Inf,tau1f;Rho1,0,Inf,Rho1f;r0,0,0.4,r0f;rinf,0,0.4,rinff;ScatPar,0,1,ScatParf;ScatPer,0,1,ScatPerf...
    ;BackPar,0,1,BackParf;BackPer,0,1,BackPerf;l1,0,1,l1f;l2,0,1,l2f;IRF,0,0,IRFf};
StartPar{7} = {tau1,0,Inf,tau1f;tau2,0,Inf,tau2f;F1,0,1,F1f;Rho1,0,Inf,Rho1f;r0,0,0.4,r0f;rinf,0,0.4,rinff;ScatPar,0,1,ScatParf;ScatPer,0,1,ScatPerf...
    ;BackPar,0,1,BackParf;BackPer,0,1,BackPerf;l1,0,1,l1f;l2,0,1,l2f;IRF,0,0,IRFf};
StartPar{8} = {tau1,0,Inf,tau1f;Rho1,0,Inf,Rho1f;Rho2,0,Inf,Rho2f;r0,0,0.4,r0f;rinf,0,0.4,rinff;ScatPar,0,1,ScatParf;ScatPer,0,1,ScatPerf...
    ;BackPar,0,1,BackParf;BackPer,0,1,BackPerf;l1,0,1,l1f;l2,0,1,l2f;IRF,0,0,IRFf};
StartPar{9} = {tau1,0,Inf,tau1f;tau2,0,Inf,tau2f;F1,0,1,F1f;Rho1,0,Inf,Rho1f;Rho2,0,Inf,Rho2f;r0,0,0.4,r0f;rinf,0,0.4,rinff;ScatPar,0,1,ScatParf;ScatPer,0,1,ScatPerf...
    ;BackPar,0,1,BackParf;BackPer,0,1,BackPerf;l1,0,1,l1f;l2,0,1,l2f;IRF,0,0,IRFf};

startpar = StartPar{model};
names = Parameters{model};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Updates UserValues on settings change  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateOptions(obj,~)
h = guidata(obj);
global UserValues TauFitData
%%% only store G if TauFit was used in BurstFramework, since only here the
%%% assignment of channels is valid
if any(strcmp(TauFitData.Who,{'Burstwise','BurstBrowser'}))
    chan = h.ChannelSelect_Popupmenu.Value;
else
    if isfield(TauFitData,'chan')
        chan = TauFitData.chan;
    else
        chan = 4;
    end
end
UserValues.TauFit.G{chan} = str2double(h.G_factor_edit.String);
UserValues.TauFit.l1 = str2double(h.l1_edit.String);
UserValues.TauFit.l2 = str2double(h.l2_edit.String);
UserValues.TauFit.use_weighted_residuals = h.UseWeightedResiduals_Menu.Value;
LSUserValues(1)
if obj == h.G_factor_edit
    %DetermineGFactor(obj)
end
if strcmp(TauFitData.Who,'Burstwise') && obj == h.Save_Figures
    UserValues.BurstSearch.BurstwiseLifetime_SaveImages = obj.Value;
    LSUserValues(1);
end

function IncludeChannel(obj,~)
global UserValues
h = guidata(findobj('Tag','TauFit'));
LSUserValues(0)
UserValues.TauFit.IncludeChannel(h.ChannelSelect_Popupmenu.Value) = h.IncludeChannel_checkbox.Value;
LSUserValues(1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Export function for various export requests %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export(obj,~)
global UserValues TauFitData FileInfo BurstData
h = guidata(findobj('Tag','TauFit'));
switch obj
    case h.Menu.Export_MIPattern
        %%% export the fitted microtime pattern for use in fFCS filter
        %%% generation
        
        %%% update the plot by evaluating the model with current parameter
        %%% values
        % fix all parameters and store fixed state
        fixed_old = h.FitPar_Table.Data(1:end-1,4);
        h.FitPar_Table.Data(1:end-1,4) = num2cell(true(size(h.FitPar_Table.Data,1)-1,1));
        % evaluate
        Start_Fit(h.Fit_Button,[]);
        % reset table
        h.FitPar_Table.Data(1:end-1,4) = fixed_old;
        
        %%% read out selected PIE channels
        if strcmp(TauFitData.Who,'TauFit')
            % we came here from Pam
            
            % two cases to consider:
            % - identical channels selected (only single PIE channel fit)
            % - two channels selected (then only works for anisotropy fit)
            if (h.PIEChannelPar_Popupmenu.String{h.PIEChannelPar_Popupmenu.Value} == h.PIEChannelPer_Popupmenu.String{h.PIEChannelPer_Popupmenu.Value})
                % check that no anisotropy model is selected
                if ~isempty(strfind(TauFitData.FitType,'Anisotropy'))
                    disp('Select another model (no anisotropy).');
                    return;
                end
                % single PIE channel selected
                PIEchannel = h.PIEChannelPar_Popupmenu.String{h.PIEChannelPar_Popupmenu.Value};
                PIEchannel = find(strcmp(UserValues.PIE.Name,PIEchannel)); % convert name to number

                % reconstruct mi pattern
                mi_pattern = zeros(FileInfo.MI_Bins,1);
                mi_pattern(UserValues.PIE.From(PIEchannel) + ((TauFitData.StartPar{TauFitData.chan}+1):TauFitData.Length{TauFitData.chan})) = TauFitData.FitResult;

                % define output
                MIPattern = cell(0);
                MIPattern{UserValues.PIE.Detector(PIEchannel),UserValues.PIE.Router(PIEchannel)}=mi_pattern;

            else % two different channels selected
                % check if anisotropy model is selected 
                if isempty(strfind(TauFitData.FitType,'Anisotropy'))
                    disp('Select an anisotropy model.');
                    return;
                end
                % two PIE channels selected
                PIEchannel1 = h.PIEChannelPar_Popupmenu.String{h.PIEChannelPar_Popupmenu.Value};
                PIEchannel1 = find(strcmp(UserValues.PIE.Name,PIEchannel1)); % convert name to number
                PIEchannel2 = h.PIEChannelPer_Popupmenu.String{h.PIEChannelPer_Popupmenu.Value};
                PIEchannel2 = find(strcmp(UserValues.PIE.Name,PIEchannel2)); % convert name to number

                % reconstruct mi patterns
                mi_pattern1 = zeros(FileInfo.MI_Bins,1);
                mi_pattern1(UserValues.PIE.From(PIEchannel1) + ((TauFitData.StartPar{TauFitData.chan}+1):TauFitData.Length{TauFitData.chan})) = TauFitData.FitResult(1,:);
                mi_pattern2 = zeros(FileInfo.MI_Bins,1);
                mi_pattern2(UserValues.PIE.From(PIEchannel2) - TauFitData.ShiftPer{TauFitData.chan} + ((TauFitData.StartPar{TauFitData.chan}+1):TauFitData.Length{TauFitData.chan})) = TauFitData.FitResult(2,:);

                % define output
                MIPattern = cell(0);
                MIPattern{UserValues.PIE.Detector(PIEchannel1),UserValues.PIE.Router(PIEchannel1)}=mi_pattern1;
                MIPattern{UserValues.PIE.Detector(PIEchannel2),UserValues.PIE.Router(PIEchannel2)}=mi_pattern2;
            end
            FileName = FileInfo.FileName{1};
            Path = FileInfo.Path;
        elseif strcmp(TauFitData.Who,'BurstBrowser')
            % we came here from BurstBrowser
            
            % the only option to consider here is an anisotropy fit
            % (maybe implement later to only fit par or per channel)
            
            % check if anisotropy model is selected 
            if isempty(strfind(TauFitData.FitType,'Anisotropy'))
                disp('Select an anisotropy model.');
                return;
            end
            
            chan = h.ChannelSelect_Popupmenu.Value;
            switch BurstData.BAMethod
                case {1,2}
                    switch chan
                        case 1 % GG
                            Par = 1; Per = 2;
                        case 2 % RR
                            Par = 5; Per = 6;
                    end
                case {3,4}
                    switch chan
                        case 1 % BB
                            Par = 1; Per = 2;
                        case 2 % GG
                            Par = 7; Per = 8;
                        case 3 % RR
                            Par = 11; Per = 12;
                    end
            end
            
            % reconstruct mi pattern
            mi_pattern1 = zeros(BurstData.FileInfo.MI_Bins,1);
            mi_pattern1(BurstData.PIE.From(Par) + ((TauFitData.StartPar{chan}+1):TauFitData.Length{chan})) = TauFitData.FitResult(1,:);
            mi_pattern2 = zeros(BurstData.FileInfo.MI_Bins,1);
            mi_pattern2(BurstData.PIE.From(Per) - TauFitData.ShiftPer{chan} + ((TauFitData.StartPar{chan}+1):TauFitData.Length{chan})) = TauFitData.FitResult(2,:);
           
            % define output
            MIPattern = cell(0);
            MIPattern{BurstData.PIE.Detector(Par),BurstData.PIE.Router(Par)}=mi_pattern1;
            MIPattern{BurstData.PIE.Detector(Per),BurstData.PIE.Router(Per)}=mi_pattern2;
            
            FileName = BurstData.SpeciesNames{BurstData.SelectedSpecies};
            Path = fileparts(BurstData.FileName);
        end
        % save
        [~, FileName, ~] = fileparts(FileName);
        [File, Path] = uiputfile('*.mi', 'Save Microtime Pattern', fullfile(Path,FileName));
        if all(File==0)
            return
        end
        save(fullfile(Path,File),'MIPattern');
    case h.Menu.Export_To_Clipboard
        %%% Copy current plot data to clipboard
        if strcmp(h.Result_Plot.Visible, 'on')
            ax = h.Result_Plot;
        else
            ax = h.Microtime_Plot;
        end
        plot_to_txt(ax,1);
    case h.Menu.Save_To_Txt
        %%% Saves data to txt file (csv), containing:
        %%%
        %%% time axis
        %%% data
        %%% fit function
        %%%
        %%% Considers only the valid region outside of ignore
        
        if h.Result_Plot.Parent == h.HidePanel % no fit has been performed
            disp('Fit the data first');
            return;
        end
       
        if (h.Result_Plot_Aniso.Parent == h.HidePanel) %%% no anistropy reconvolution fit
            time = h.Plots.DecayResult.XData; time = time-time(1);
            data = h.Plots.DecayResult.YData;
            fit =  h.Plots.FitResult.YData;
            res = h.Plots.Residuals.YData;
            if strcmp(h.Result_Plot.YLabel.String,'Anisotropy')
                names = {'time_ns','anisotropy','fit','wres'};
                ext = '_aniso';
            else
                names = {'time_ns','intensity','fit','wres'};
                ext = '_tau';
            end
            tab = table(time',data',fit',res','VariableNames',names);
        else
            %%% anisotropy reconvolution fit
            time = h.Plots.DecayResult.XData; time = time-time(1);
            data_par = h.Plots.DecayResult.YData;
            data_per = h.Plots.DecayResult_Perp.YData;
            fit_par =  h.Plots.FitResult.YData;
            fit_per =  h.Plots.FitResult_Perp.YData;
            res_par = h.Plots.Residuals.YData;
            res_per = h.Plots.Residuals_Perp.YData;
            aniso_data = h.Plots.AnisoResult.YData;
            aniso_fit = h.Plots.FitAnisoResult.YData;
            names = {'time_ns','intensity_par','intensity_per','fit_par','fit_per','wres_par','wres_per','anisotropy','anisotropy_fit'};
            tab= table(time',data_par',data_per',fit_par',fit_per',res_par',res_per',aniso_data',aniso_fit','VariableNames',names);
            ext = '_tau_aniso';
        end
        %%% get path
        [path,filename,~] = fileparts(TauFitData.FileName);
        if isfield(TauFitData,'SpeciesName')
            filename = [filename '_' TauFitData.SpeciesName];
        end
        filename = strrep(filename,' - ','-');
        filename = strrep(filename,' ','_');
        [filename, pathname, FilterIndex] = uiputfile('*.txt','Save *.txt file',[path filesep filename ext '.txt']);
        if FilterIndex == 0
            return;
        end
        %%% check that the extension has not been deleted by the user!
        %%% if it has, readd
        if isempty(strfind(filename,ext))
            filename = [filename(1:end-4) ext '.txt'];
        end
        writetable(tab,fullfile(pathname,filename));
    case h.Compare_Result
        %%% load data and make comparison plot
        try
            [pathname,~,~] = fileparts(TauFitData.FileName);
        catch
            pathname = UserValues.File.Path;
        end
        [filename, pathname, FilterIndex] = uigetfile('*.txt','Load lifetime data...',pathname,...
            'MultiSelect','on');
        if FilterIndex == 0
            return;
        end
        
        if ~iscell(filename)
            filename = {filename};
        end
        %%% ensure that same type of data is loaded, remove the rest
        %%% type defined by first selected file
        % anisotropy reconvolution fit is not supported, check for it
        if ~isempty(strfind(filename{1},'tau_aniso'))
            disp('Anisotropy reconvolution data not supported.');
            return;
        end
        if iscell(filename)
            valid = ones(numel(filename),1);
            type = strfind(filename{1},'tau');
            if isempty(type)
                type = 'aniso';
            else
                type = 'tau';
            end
            for i = 1:numel(filename)
                if isempty(strfind(filename{i},type))
                    valid(i) = 0;
                end
            end
            filename = filename(logical(valid));
        end
        
        %%% load data
        %%% raw data is saved in second column
        data = {};
        for i = 1:numel(filename)
            dummy = dlmread(fullfile(pathname,filename{i}),',',1,0);
            data{i} = dummy(:,2);
        end
        dT = mean(diff(dummy(:,1)));  
        %%% if different lengths have been loaded, truncate to shortest
        minLength = min(cellfun(@numel,data));
        for i = 1:numel(data)
            data{i} = data{i}(1:minLength);
        end
        t = (1:minLength)*dT;
        
        if strcmp(type,'tau') %%% normalize and shift if tau data
            for i = 1:numel(data)
                data{i} = data{i}./max(smooth(data{i}));
            end
            
            %%% for shift, take first measurement as reference
            [~,peakPosition] = max(smooth(data{1}));
            shift_left = 0;
            shift_right = 0;
            for i = 2:numel(data)
                [~,peakPos] = max(smooth(data{i},10));
                shift_left = min([shift_left, peakPosition-peakPos]);
                shift_right = max([shift_right, peakPosition-peakPos]);
                data{i} = circshift(data{i},[peakPosition-peakPos,0]);
            end
            %%% adjust range
            range = (shift_right+1):(minLength+shift_left);
            t = (1:numel(range))*dT;
            for i = 1:numel(data)
                data{i} = data{i}(range);
            end
        elseif strcmp(type,'aniso') %%% modify start point if anisotropy data
            for i = 1:numel(data)
                [~,peakPos(i)] = max(smooth(data{i},10));
            end
            range = min(peakPos):minLength;
            t = (1:numel(range))*dT;
            for i = 1:numel(data)
                data{i} = data{i}(range);
            end
        end
        
        
        %%% find max and min data
        minV = min(cellfun(@min,data));
        maxV = max(cellfun(@max,data));
        
        %%% plot data
        hfig = figure('Units','pixels','Position',[100,100,600,400],'Color',[1,1,1]);
        ax = axes('Color',[1,1,1],'LineWidth',2,'Box','on','XGrid','on','YGrid','on','FontSize',20);
        hold on;
        for i = 1:numel(data)
            plot(t,data{i},'LineWidth',2);
        end 
        ax.YLim = [minV-0.1*(maxV-minV) maxV+0.1*(maxV-minV)];
        ax.XLim = [t(1) t(end)];
        xlabel('Time [ns]');
        if strcmp(type,'tau')
            ylabel('Intensity [a.u.]');
            ax.YScale = 'log';
        else
            ylabel('Anisotropy');
        end
        for i = 1:numel(filename)
            % remove extension
            filename{i} = filename{i}(1:end-4);
            % replace underscore with space
            filename{i} = strrep(filename{i},'_',' ');
        end
        l = legend(filename);
        ax.Layer = 'top';
        ax.Units = 'pixels';
        l.Units = 'pixels';
end