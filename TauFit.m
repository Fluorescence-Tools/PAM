function TauFit(obj,~)
global UserValues TauFitData PamMeta
h.TauFit = findobj('Tag','TauFit');
addpath(genpath(['.' filesep 'functions']));
LSUserValues(0);
method = '';
%%% If called from command line, or from Launcher
if (nargin < 1 && isempty(gcbo)) || (nargin < 1 && strcmp(get(gcbo,'Tag'),'TauFit_Launcher'))
    if ~isempty(findobj('Tag','TauFit'))
        CloseWindow(findobj('Tag','TauFit'))
    end
    %disp('Call TauFit from Pam or BurstBrowser instead of command line!');
    %return;
    TauFitData.Who = 'External';
    method = 'ensemble';
    obj = false;
end

if ~isempty(h.TauFit)
    % Close TauFit cause it might be called from somewhere else than before
    CloseWindow(h.TauFit);
end
if ~isempty(findobj('Tag','Pam'))
    ph = guidata(findobj('Tag','Pam'));
end
if ~isempty(findobj('Tag','BurstBrowser'))
    bh = guidata(findobj('Tag','BurstBrowser'));
end
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
    'CloseRequestFcn',@CloseWindow,...
    'KeyPressFcn',@TauFit_KeyPress,...
    'Visible','off');
%%% Sets background of axes and other things
whitebg(Look.Axes);
%%% Changes background; must be called after whitebg
h.TauFit.Color=Look.Back;
%%% Remove unneeded items from toolbar
toolbar = findall(h.TauFit,'Type','uitoolbar');
toolbar_items = findall(toolbar);
if verLessThan('matlab','9.5') %%% toolbar behavior changed in MATLAB 2018b
    delete(toolbar_items([2:7 9 14:17]));
else %%% 2018b and upward
    %%% just remove the tool bar since the options are now in the axis
    %%% (e.g. axis zoom etc)
    delete(toolbar_items);
end

%%% menu
h.Menu.File = uimenu(h.TauFit,'Label','File');
h.Menu.OpenDecayData = uimenu(h.Menu.File,'Label','Load decay data (*.dec)',...
    'Callback',@Load_Data);
h.Menu.SaveDecayData = uimenu(h.Menu.File,'Label','Save decay data (*.dec)',...
    'Callback',@Save_Data);
h.Menu.OpenDecayData_PQ = uimenu(h.Menu.File,'Label','Load decay data from text file',...
    'Callback',@Load_Data,'Separator','on');
h.Menu.OpenIRFData_PQ = uimenu(h.Menu.File,'Label','Load IRF data from text file',...
    'Callback',@Load_Data,'Enable','off');
h.Menu.OpenDecayDOnlyData_PQ = uimenu(h.Menu.File,'Label','Load DOnly data from text file',...
    'Callback',@Load_Data,'Enable','off');
h.Menu.Export_Menu = uimenu(h.TauFit,'Label','Export...');
h.Menu.Save_To_Txt = uimenu(h.Menu.Export_Menu,'Label','Save Plots to *.csv',...
    'Callback',@Export);
h.Compare_Result = uimenu(h.Menu.Export_Menu,'Label','Compare Data...',...
    'Separator','off',...
    'Callback',@Export);
h.Menu.Export_To_Clipboard = uimenu(h.Menu.Export_Menu,'Label','Copy Data to Clipboard',...
    'Callback',@Export,...
    'Separator','on');
h.Menu.Export_for_fFCS = uimenu(h.Menu.Export_Menu,'Label','Export for fFCS...',...
    'Callback',[]);
h.Menu.Export_MIPattern_Fit = uimenu(h.Menu.Export_for_fFCS,'Label','... fitted microtime pattern',...
    'Callback',@Export);
h.Menu.Export_MIPattern_Data = uimenu(h.Menu.Export_for_fFCS,'Label','... raw microtime pattern',...
    'Callback',@Export);
h.Menu.Save_To_Dec = uimenu(h.Menu.Export_Menu,'Label','Save to *.dec file',...
    'Callback',@Export,'Separator','on');


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
    'Label','Y Logscale',...
    'Checked', UserValues.TauFit.YScaleLog,...
    'Tag','Plot_YLogscale_MIPlot',...
    'Callback',@ChangeScale);
h.Microtime_Plot_ChangeXScaleMenu_MIPlot = uimenu(...
    h.Microtime_Plot_Menu_MIPlot,...
    'Label','X Logscale',...
    'Checked', UserValues.TauFit.XScaleLog,...
    'Tag','Plot_XLogscale_MIPlot',...
    'Callback',@ChangeScale);

h.Microtime_Plot_Export = uimenu(...
    h.Microtime_Plot_Menu_MIPlot,...
    'Label','Export Plot',...
    'Tag','Microtime_Plot_Export',...
    'Callback',@ExportGraph);

h.Microtime_Plot_Menu_ResultPlot = uicontextmenu;
h.Microtime_Plot_ChangeYScaleMenu_ResultPlot = uimenu(...
    h.Microtime_Plot_Menu_ResultPlot,...
    'Label','Y Logscale',...
    'Tag','Plot_YLogscale_ResultPlot',...
    'Callback',@ChangeScale);
h.Microtime_Plot_ChangeXScaleMenu_ResultPlot = uimenu(...
    h.Microtime_Plot_Menu_ResultPlot,...
    'Label','X Logscale',...
    'Tag','Plot_XLogscale_ResultPlot',...
    'Callback',@ChangeScale);
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
h.Plots.Scat_Sum = plot([0 1],[0 0],'.r','Color',[0.5 0.5 0.5],'MarkerSize',5,'DisplayName','Scatter (sum)');
h.Plots.Scat_Par = plot([0 1],[0 0],'LineStyle',':','Color',[0.5 0.5 0.5],'LineWidth',1,'DisplayName','Scatter (par)');
h.Plots.Scat_Per = plot([0 1],[0 0],'LineStyle',':','Color',[0.3 0.3 0.3],'LineWidth',1,'DisplayName','Scatter (perp)');
h.Plots.Decay_Sum = plot([0 1],[0 0],'-k','LineWidth',1,'DisplayName','Decay (sum)');
h.Plots.Decay_Par = plot([0 1],[0 0],'Color',[0.8510,0.3294,0.1020],'LineWidth',1,'DisplayName','Decay (par)');
h.Plots.Decay_Per = plot([0 1],[0 0],'Color',[0,0.4510,0.7412],'LineWidth',1,'DisplayName','Decay (perp)');
h.Plots.IRF_Sum = plot([0 1],[0 0],'.r','Color',[0,0.4510,0.7412],'MarkerSize',5,'DisplayName','IRF (sum)');
h.Plots.IRF_Par = plot([0 1],[0 0],'.r','MarkerSize',5,'DisplayName','IRF (par)');
h.Plots.IRF_Per = plot([0 1],[0 0],'.b','MarkerSize',5,'DisplayName','IRF (perp)');
h.Ignore_Plot = patch([0 0 0 0],[1e-6 1e-6 1 1],[0,0,0],'FaceAlpha',0.25,'Visible','off','LineWidth',1,'EdgeColor','none','DisplayName','Decay (ignore)');
h.Plots.Aniso_Preview = plot([0 1],[0 0],'-k','LineWidth',1,'DisplayName','Anisotropy');
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
h.Plots.Residuals = plot([0 1],[0 0],'-k','LineWidth',1);
h.Plots.Residuals_ignore = plot([0 1],[0 0],'LineStyle','--','Color',[0.4 0.4 0.4],'Visible','off','LineWidth',1);
h.Plots.Residuals_Perp = plot([0 1],[0 0],'-b','Visible','off','LineWidth',1);
h.Plots.Residuals_Perp_ignore = plot([0 1],[0 0],'LineStyle','--','Color',[0 0 0.4],'Visible','off','LineWidth',1);

h.Plots.Residuals_ZeroLine = plot([0 1],[0 0],'-k','Visible','off','LineWidth',1);
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
    'FontSize',10,...
    'FontWeight','bold',...
    'BackgroundColor','none',...
    'Units','normalized',...
    'Color',Look.AxesFore,...
    'BackgroundColor',Look.Axes,...
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
h.Plots.IRFResult = plot([0 1],[0 0],'LineStyle','none','Marker','.','Color',[0.6 0.6 0.6],'LineWidth',1,'MarkerSize',8,'DisplayName','IRF');
h.Plots.IRFResult_Perp = plot([0 1],[0 0],'LineStyle','none','Marker','.','Color',[0 0 0.6],'Visible','off','LineWidth',1,'MarkerSize',5,'DisplayName','IRF (perp)');
h.Plots.DecayResult = plot([0 1],[0 0],'-k','LineWidth',1,'DisplayName','Decay','MarkerSize',8);
h.Plots.DecayResult_ignore = plot([0 1],[0 0],'LineStyle','--','Color',[0.4 0.4 0.4],'Visible','off','LineWidth',1,'DisplayName','Decay (ignore)','MarkerSize',8);
h.Plots.DecayResult_Perp = plot([0 1],[0 0],'LineStyle','-','Color',[0 0.4471 0.7412],'Visible','off','LineWidth',1,'DisplayName','Decay (perp)','MarkerSize',8);
h.Plots.DecayResult_Perp_ignore = plot([0 1],[0 0],'LineStyle','--','Color',[0 0.2 0.375],'Visible','off','LineWidth',1,'DisplayName','Decay (ignore perp)','MarkerSize',8);
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
h.Plots.AnisoResult = plot([0 1],[0 0],'-k','LineWidth',1,'DisplayName','Anisotropy','MarkerSize',10);
h.Plots.AnisoResult_ignore = plot([0 1],[0 0],'LineStyle','--','Color',[0.4 0.4 0.4],'LineWidth',1,'DisplayName','Anisotropy (ignore)','MarkerSize',10);
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
    %h.Result_Plot_Aniso.YScale = 'log';
end
if strcmp(h.Microtime_Plot_ChangeXScaleMenu_MIPlot.Checked,'on')
    h.Microtime_Plot.XScale = 'log';
    h.Result_Plot.XScale = 'log';
    %h.Result_Plot_Aniso.YScale = 'log';
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
    'FontSize',10,...
    'String','Start',...
    'TooltipString','Start Value for the Parallel Channel',...
    'Position',[0.01 0.825 0.1 0.175],...
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
    'FontSize',10,...
    'String','Length',...
    'TooltipString','Length of the Microtime Histogram',...
    'Position',[0.01 0.625 0.1 0.175],...
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
    'FontSize',10,...
    'String','IRF Length',...
    'TooltipString','Length of the IRF',...
    'Position',[0.01 0.425 0.1 0.175],...
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
    'FontSize',10,...
    'String','IRF Shift',...
    'TooltipString','Shift of the IRF',...
    'Position',[0.01 0.225 0.1 0.175],...
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
    'FontSize',10,...
    'String','Scat Shift',...
    'TooltipString','Shift of the Scat',...
    'Position',[0.01 0.025 0.1 0.175],...
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
    'FontSize',10,...
    'String','Perp Shift',...
    'TooltipString','Shift of the Perpendicular Channel',...
    'Position',[0.51 0.825 0.1 0.175],...
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
    'FontSize',10,...
    'String','Ignore Length',...
    'TooltipString','Length of the Ignore Region in the Beginning',...
    'Position',[0.51 0.625 0.1 0.175],...
    'Tag','Ignore_Text');

%%% Slider for Selection of IRF Length
h.IRFBackground_Slider = uicontrol(...
    'Style','slider',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.67 0.425 0.32 0.125],...
    'Tag','IRFBackground_Slider',...
    'Callback',@Update_Plots);

h.IRFBackground_Edit = uicontrol(...
    'Parent',h.Slider_Panel,...
    'Style','edit',...
    'Tag','IRFBackground_Edit',...
    'Units','normalized',...
    'Position',[0.61 0.425 0.05 0.15],...
    'String','0',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'FontSize',10,...
    'Callback',@Update_Plots);

h.IRFBackground_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',10,...
    'String','IRF Background',...
    'TooltipString','Background cut-off for the IRF',...
    'Position',[0.51 0.425 0.1 0.175],...
    'Tag','IRFBackground_Text');

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
    'FontSize',10,...
    'String','Perp IRF Shift',...
    'TooltipString','Shift of the IRF perpendicular with respect to the parallel IRF',...
    'Position',[0.51 0.225 0.1 0.175],...
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
    'FontSize',10,...
    'String','Perp Scat Shift',...
    'TooltipString','Shift of the Scat perpendicular with respect to the parallel Scat',...
    'Position',[0.51 0.025 0.1 0.175],...
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

%%% Popup Menu for Fit Method Selection
h.FitMethods = {'Single Exponential','Biexponential','Three Exponentials','Four Exponentials','Stretched Exponential',...
    'Distribution','Distribution plus Donor only','Two Distributions plus Donor only','Distribution Fit - Global Model'...
    'Fit Anisotropy',...
    'Fit Anisotropy (2 exp lifetime)','Fit Anisotropy (2 exp rot)',...
    'Fit Anisotropy (2 exp lifetime, 2 exp rot)',...
    'Fit Anisotropy (2 exp lifetime with independent anisotropy)'...
    };
if exist('ph','var')
    if isobject(obj)
        switch obj
            case ph.Menu.OpenTauFit
                TauFitData.Who = 'TauFit';
                % user called TauFit from Pam
                % fit a lifetime from data in a PIE channel
                method = 'ensemble';
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
                    'FontSize',10,...
                    'String','Select Channel',...
                    'ToolTipString','Selection of Channel');%%% Popup menus for PIE Channel Selection
                switch PamMeta.BurstData.BAMethod
                    case {1,2,5}
                        Channel_String = {'DD','AA'};
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
                %h.FitMethods = {'Single Exponential','Biexponential'};
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
                    'ToolTipString','Perform the burstwise fitting (sliders should be correct!',...
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
                    'Position',[0.57,0.02,0.4,0.12]);
                %%% add checkbox for burstwise phasor calculation
                h.Calc_Burstwise_Phasor = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'style','checkbox',...
                    'units','normalized',...
                    'BackgroundColor', Look.Back,...
                    'ForegroundColor', Look.Fore,...
                    'Callback',@UpdateOptions,...
                    'String','Burst-wise Phasor',...
                    'Value',UserValues.BurstSearch.CalculateBurstwisePhasor,...
                    'Position',[0.57,0.28,0.4,0.12]);
                %%% add popupmenu for selecting the reference for burstwise
                %%% phasor
                h.Select_Burstwise_Phasor_Reference = uicontrol(...
                    'Parent',h.PIEChannel_Panel,...
                    'style','popupmenu',...
                    'units','normalized',...
                    'Callback',@UpdateOptions,...
                    'Visible','off',...
                    'String',{'IRF reference','Lifetime reference'},...
                    'Value',UserValues.BurstSearch.PhasorReference,...
                    'Position',[0.57,0.15,0.4,0.12]);
                if UserValues.BurstSearch.CalculateBurstwisePhasor
                    h.Select_Burstwise_Phasor_Reference.Visible = 'on';
                end
                %%% radio buttons to select the plotted data (decay or
                %%% anisotropy)
                h.ShowDecay_radiobutton = uicontrol('Style','radiobutton',...
                    'Parent',h.PIEChannel_Panel,...
                    'String','Decay',...
                    'Units','normalized',...
                    'Value',1,...
                    'Callback',@Update_Plots,...
                    'ForegroundColor',UserValues.Look.Fore,...
                    'BackgroundColor',UserValues.Look.Back,...
                    'Position',[0.01 0.32 0.27 0.07],...
                    'Visible','off');
                h.ShowDecaySum_radiobutton = uicontrol('Style','radiobutton',...
                    'Parent',h.PIEChannel_Panel,...
                    'String','Decay (Sum)',...
                    'Units','normalized',...
                    'Value',0,...
                    'Callback',@Update_Plots,...
                    'ForegroundColor',UserValues.Look.Fore,...
                    'BackgroundColor',UserValues.Look.Back,...
                    'Position',[0.01 0.25 0.27 0.07],...
                    'Visible','off');
                h.ShowAniso_radiobutton = uicontrol('Style','radiobutton',...
                    'Parent',h.PIEChannel_Panel,...
                    'String','Anisotropy',...
                    'Units','normalized',...
                    'Value',0,...
                    'ForegroundColor',UserValues.Look.Fore,...
                    'BackgroundColor',UserValues.Look.Back,...
                    'Callback',@Update_Plots,...
                    'Position',[0.01 0.18 0.27 0.07],...
                    'Visible','off');
        end
    end
end
if strcmp(method,'ensemble')
    %%% this occurs if we either called from PAM or directly from
    %%% command-line (i.e. operating on processed data *.dec files)
    
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
        'FontSize',10,...
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
        'FontSize',10,...
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
    % = {'Single Exponential','Biexponential','Three Exponentials','Four Exponentials','Stretched Exponential',...
    %'Distribution','Distribution plus Donor only','Two Distributions plus Donor only',...
    %'Fit Anisotropy','Fit Anisotropy (2 exp lifetime)','Fit Anisotropy (2 exp rot)',...
    %'Fit Anisotropy (2 exp lifetime, 2 exp rot)','Fit Anisotropy (2 exp lifetime with independent anisotropy)'};
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
        'Position',[0.35 0.25 0.5 0.12],...
        'String','Perform reconvolution fit',...
        'Callback',@Start_Fit);
    h.Fit_Button_Menu = uicontextmenu;
    %%% Button for Maximum Entropy Method (MEM) analysis
    h.Fit_Button_MEM_tau = uimenu('Parent',h.Fit_Button_Menu,...
        'Label','MEM analysis (Lifetime Distribution)',...
        'Checked','off',...
        'Callback',@Start_Fit);
    h.Fit_Button_MEM_dist = uimenu('Parent',h.Fit_Button_Menu,...
        'Label','MEM analysis (Distance Distribution)',...
        'Checked','off',...
        'Callback',@Start_Fit);
    h.Fit_Button.UIContextMenu = h.Fit_Button_Menu;
    h.Fit_Button_MEM_tau.Visible = 'off'; h.Fit_Button_MEM_dist.Visible = 'off';% only turn visible after a fit has been performed
    %%% Button to start tail fitting
    h.Fit_Tail_Button = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','pushbutton',...
        'Tag','Fit_Tail_Button',...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.05 0.05 0.29 0.12],...
        'String','Perform tail fit',...
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
    h.Fit_DipAndRise = uimenu('Parent',h.Fit_Aniso_Menu,...
        'Label','Fit Anisotropy (2 exp lifetime with independent anisotropy)',...
        'Checked','off',...
        'Callback',@Start_Fit);
    h.Fit_Aniso_Button.UIContextMenu = h.Fit_Aniso_Menu;
    
    %%% radio buttons to select the plotted data (decay or
    %%% anisotropy)
    h.ShowDecay_radiobutton = uicontrol('Style','radiobutton',...
        'Parent',h.PIEChannel_Panel,...
        'String','Decay',...
        'Units','normalized',...
        'Value',1,...
        'Callback',@Update_Plots,...
        'ForegroundColor',UserValues.Look.Fore,...
        'BackgroundColor',UserValues.Look.Back,...
        'Position',[0.01 0.32 0.27 0.07]);
    h.ShowDecaySum_radiobutton = uicontrol('Style','radiobutton',...
        'Parent',h.PIEChannel_Panel,...
        'String','Decay (Sum)',...
        'Units','normalized',...
        'Value',0,...
        'Callback',@Update_Plots,...
        'ForegroundColor',UserValues.Look.Fore,...
        'BackgroundColor',UserValues.Look.Back,...
        'Position',[0.01 0.25 0.27 0.07]);
    h.ShowAniso_radiobutton = uicontrol('Style','radiobutton',...
        'Parent',h.PIEChannel_Panel,...
        'String','Anisotropy',...
        'Units','normalized',...
        'Value',0,...
        'ForegroundColor',UserValues.Look.Fore,...
        'BackgroundColor',UserValues.Look.Back,...
        'Callback',@Update_Plots,...
        'Position',[0.01 0.18 0.27 0.07]);
    
    if strcmp(TauFitData.Who,'External')
        %%% hide buttons that relate to loading data from PAM
        h.PIEChannelPar_Popupmenu.Value = 1;
        h.PIEChannelPer_Popupmenu.Value = 1;
        h.PIEChannelPar_Popupmenu.String = {''};
        h.PIEChannelPer_Popupmenu.String = {''};
        h.LoadData_Button.String = 'Plot Selection';
        h.LoadData_Button.Enable = 'off';
        h.Menu.Save_To_Dec.Visible = 'off';
    end
end
if exist('bh','var')
    if bh.SendToTauFit.equals(obj) || obj == bh.Send_to_TauFit_Button
        TauFitData.Who = 'BurstBrowser';
        global BurstMeta BurstData
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
            'FontSize',10,...
            'String','Select Channel',...
            'ToolTipString','Selection of Channel');%%% Popup menus for PIE Channel Selection
        switch BurstData{BurstMeta.SelectedFile}.BAMethod
            case {1,2,5}
                Channel_String = {'DD','AA','DA','Donor only'};
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
            'Position',[0.025 0.55 0.95 0.28],...
            'HorizontalAlignment','left',...
            'String',sprintf(str),...
            'TooltipString',sprintf(str),...
            'BackgroundColor',Look.Back,...
            'ForegroundColor',Look.Fore,...
            'FontSize',10);
        %%% Button to start fitting
        h.Fit_Button = uicontrol(...
            'Parent',h.PIEChannel_Panel,...
            'Style','pushbutton',...
            'Tag','Fit_Button',...
            'Units','normalized',...
            'BackgroundColor', Look.Control,...
            'ForegroundColor', Look.Fore,...
            'Position',[0.38 0.25 0.5 0.12],...
            'String','Perform reconvolution fit',...
            'Callback',@Start_Fit);
        h.Fit_Button_Menu = uicontextmenu;
        %%% Button for Maximum Entropy Method (MEM) analysis
        h.Fit_Button_MEM_tau = uimenu('Parent',h.Fit_Button_Menu,...
            'Label','MEM analysis (Lifetime Distribution)',...
            'Checked','off',...
            'Callback',@Start_Fit);
        h.Fit_Button_MEM_dist = uimenu('Parent',h.Fit_Button_Menu,...
            'Label','MEM analysis (Distance Distribution)',...
            'Checked','off',...
            'Callback',@Start_Fit);
        h.Fit_Button.UIContextMenu = h.Fit_Button_Menu;
        h.Fit_Button_MEM_tau.Visible = 'off'; h.Fit_Button_MEM_dist.Visible = 'off'; % only turn visible after a fit has been performed
        %%% Button to start tail fitting
        h.Fit_Tail_Button = uicontrol(...
            'Parent',h.PIEChannel_Panel,...
            'Style','pushbutton',...
            'Tag','Fit_Tail_Button',...
            'Units','normalized',...
            'BackgroundColor', Look.Control,...
            'ForegroundColor', Look.Fore,...
            'Position',[0.05 0.05 0.29 0.12],...
            'String','Perform tail fit',...
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
        h.Fit_DipAndRise = uimenu('Parent',h.Fit_Aniso_Menu,...
            'Label','Fit Anisotropy (2 exp lifetime with independent anisotropy)',...
            'Checked','off',...
            'Callback',@Start_Fit);
        h.Fit_Aniso_Button.UIContextMenu = h.Fit_Aniso_Menu;
        
        %%% Dropdown menu to select source of donor-only reference
        %%% (either from stored reference or taken from the burst data)
        h.DonorOnlyReference_Text = uicontrol('Style','text',...
            'Tag','TauFit_SpeciesSelect_text',...
            'Parent',h.PIEChannel_Panel,...
            'Units','normalized',...
            'Position',[0.65 0.15 0.35 0.1],...
            'HorizontalAlignment','left',...
            'String','Donor-only reference:',...
            'BackgroundColor',Look.Back,...
            'ForegroundColor',Look.Fore,...
            'Visible','off',...
            'FontSize',8);
        h.DonorOnlyReference_Popupmenu = uicontrol(...
            'Parent',h.PIEChannel_Panel,...
            'Style','Popupmenu',...
            'Tag','DonorOnlyReference_Popupmenu',...
            'Units','normalized',...
            'Position',[0.65 0.1 0.35 0.05],...
            'String',{'DOnly population','Stored reference'},...
            'Value', UserValues.TauFit.DonorOnlyReferenceSource,...
            'Visible','off',...
            'FontSize',10,...
            'Callback',@UpdateOptions);
        
        %%% radio buttons to select the plotted data (decay or
        %%% anisotropy)
        h.ShowDecay_radiobutton = uicontrol('Style','radiobutton',...
            'Parent',h.PIEChannel_Panel,...
            'String','Decay',...
            'Units','normalized',...
            'Value',1,...
            'Callback',@Update_Plots,...
            'ForegroundColor',UserValues.Look.Fore,...
            'BackgroundColor',UserValues.Look.Back,...
            'Position',[0.01 0.32 0.27 0.07]);
        h.ShowDecaySum_radiobutton = uicontrol('Style','radiobutton',...
            'Parent',h.PIEChannel_Panel,...
            'String','Decay (Sum)',...
            'Units','normalized',...
            'Value',0,...
            'Callback',@Update_Plots,...
            'ForegroundColor',UserValues.Look.Fore,...
            'BackgroundColor',UserValues.Look.Back,...
            'Position',[0.01 0.25 0.27 0.07]);
        h.ShowAniso_radiobutton = uicontrol('Style','radiobutton',...
            'Parent',h.PIEChannel_Panel,...
            'String','Anisotropy',...
            'Units','normalized',...
            'Value',0,...
            'ForegroundColor',UserValues.Look.Fore,...
            'BackgroundColor',UserValues.Look.Back,...
            'Callback',@Update_Plots,...
            'Position',[0.01 0.18 0.27 0.07]);
        
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
    'Position',[0.27 0.4 0.72 0.095],...
    'String',h.FitMethods,...
    'Callback',@Method_Selection);

h.FitMethod_Text = uicontrol(...
    'Parent',h.PIEChannel_Panel,...
    'Style','Text',...
    'Tag','FitMethod_Text',...
    'Units','normalized',...
    'Position',[0.01 0.4 0.25 0.095],...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',10,...
    'String','Model Function:',...
    'ToolTipString','Select the Model Function');

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
    'FontSize',10,...
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
    'ColumnWidth',{100,50,50,40},...
    'Tag','FitPar_Table',...
    'CellEditCallBack',@Update_Plots,...
    'BackgroundColor', [Look.Table1;Look.Table2],...
    'ForegroundColor', Look.TableFore);
%%% Get the values of the table and the RowNames from UserValues
[h.FitPar_Table.Data, h.FitPar_Table.RowName, Tooltip] = GetTableData(1, 1);
try
    h.FitPar_Table.TooltipString = Tooltip;
catch %%% in newer version, this is now just called "Tooltip"
    h.FitPar_Table.Tooltip = Tooltip;
end
h.FitResultToClip_Menu = uicontextmenu;
h.FitResultToClip = uimenu(...
    'Parent',h.FitResultToClip_Menu,...
    'Label','Copy Fit Result to Clipboard',...
    'Callback',@Export);
h.FitPar_Table.UIContextMenu = h.FitResultToClip_Menu;
%%% use single or biexponential fitted lifetime as donor only
h.SetDonorOnlyLifetime_Menu = uimenu(...
    'Parent',h.FitResultToClip_Menu,...
    'Label','Use fitted lifetime for donor only',...
    'Callback',@SetDonorOnlyLifetime,...
    'Separator','on');
%%% Get tau values and plot dynamic FRET line in Burst Browser
h.PlotDynamicFRETLine = uimenu(...
    'Parent',h.FitPar_Table.UIContextMenu,...
    'Label','Plot dynamic FRET line',...
    'Visible','off',...
    'Callback',@Export,...
    'Separator','on');
h.PlotDynamicFRETLine_Sigma = uimenu(...
    'Parent',h.FitPar_Table.UIContextMenu,...
    'Label','Plot dynamic FRET line (with sigma)',...
    'Visible','off',...
    'Callback',@Export);
%%% Edit Boxes for Correction Factors
h.G_factor_text = uicontrol(...
    'Parent',h.FitPar_Panel,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.01 0.125 0.15 0.05],...
    'String','G Factor',...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Tag','G_factor_text');

h.G_factor_edit = uicontrol(...
    'Parent',h.FitPar_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.17 0.125 0.2 0.04],...
    'String','1',...
    'FontSize',10,...
    'Tag','G_factor_edit',...
    'Callback',@UpdateOptions);

if any(strcmp(TauFitData.Who,{'Burstwise','BurstBrowser'}))
    h.G_factor_edit.String = num2str(UserValues.TauFit.G{1});
end

h.l1_text = uicontrol(...
    'Parent',h.FitPar_Panel,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.01 0.075 0.15 0.05],...
    'String','l1',...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Tag','l1_text');

h.l1_edit = uicontrol(...
    'Parent',h.FitPar_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.17 0.075 0.2 0.04],...
    'String',num2str(UserValues.TauFit.l1),...
    'FontSize',10,...
    'Tag','l1_edit',...
    'Callback',@UpdateOptions);

h.l2_text = uicontrol(...
    'Parent',h.FitPar_Panel,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.01 0.025 0.15 0.05],...
    'String','l2',...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Tag','l2_text');

h.l2_edit = uicontrol(...
    'Parent',h.FitPar_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.17 0.025 0.2 0.04],...
    'String',num2str(UserValues.TauFit.l2),...
    'FontSize',10,...
    'Tag','l2_edit',...
    'Callback',@UpdateOptions);

h.Output_Panel = uibuttongroup(...
    'Parent',h.FitPar_Panel,...
    'Units','normalized',...
    'Position',[0.4 0 0.6 0.195],...
    'Title','Status message',...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Tag','Output_Panel');

ToolTip_average_lifetime = '<html><b>Mean Lifetime Fraction</b> is the amplitude-weighted average lifetime, given by:<br>&lt;&tau;&gt;<sub>amp</sub> = &Sigma;&alpha;<sub>i</sub>&tau;<sub>i</sub>, where &alpha; is the amplitude.<br><b>Mean Lifetime Int</b> is the intensity-weighted average lifetime.<br>Every lifetime species is weighted by the intensity fraction given by:<br>f<sub>i</sub>= &alpha;<sub>i</sub>&tau;<sub>i</sub>/&Sigma;&alpha;<sub>j</sub>&tau;<sub>j</sub><br>i.e.&lt;&tau;&gt;<sub>int</sub> = &Sigma;f<sub>i</sub>&tau;<sub>i</sub></html>';
h.Output_Text = uicontrol(...
    'Parent',h.Output_Panel,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'String','',...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',ToolTip_average_lifetime,...
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
    'Position',[0 0.5 1 0.5],...
    'Tag','Settings_Panel');

h.IRF_Cleanup_Panel = uibuttongroup(...
    'Parent',h.Settings_Tab,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'HighlightColor',Look.Control,...
    'ShadowColor',Look.Shadow,...
    'Position',[0 0 1 0.5],...
    'FontSize',12,...
    'Tag','IRF_Cleanup_Panel',...
    'Title','IRF cleanup');

h.ConvolutionType_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.05 0.9 0.35 0.07],...
    'String','Convolution Type',...
    'FontSize',10,...
    'Tag','ConvolutionType_Text');

h.ConvolutionType_Menu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'Position',[0.4 0.9 0.5 0.07],...
    'String',{'linear','circular'},...
    'Value',find(strcmp({'linear','circular'},UserValues.TauFit.ConvolutionType)),...
    'Tag','ConvolutionType_Menu');

h.LineStyle_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.05 0.8 0.35 0.07],...
    'String','Line Style (Result)',...
    'FontSize',10,...
    'Tag','LineStyle_Text');
h.LineStyle_Menu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'Position',[0.4 0.8 0.5 0.07],...
    'String',{'line','dots'},...
    'Value',find(strcmp({'line','dots'},UserValues.TauFit.LineStyle)),...
    'Callback',@UpdateOptions,...
    'Tag','LineStyle_Menu');

h.AutoFit_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.05 0.7 0.7 0.05],...
    'String','Automatic fit',...
    'FontSize',10,...
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
    'FontSize',10,...
    'Tag','NormalizeScatter_Menu',...
    'Callback',@Update_Plots);

h.UseWeightedResiduals_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.05 0.6 0.425 0.05],...
    'String','Use weighted residuals',...
    'Value',UserValues.TauFit.use_weighted_residuals,...
    'FontSize',10,...
    'Tag','UseWeightedResiduals_Menu',...
    'Callback',@UpdateOptions);
h.WeightedResidualsType_Menu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'Position',[0.525 0.61 0.425 0.05],...
    'String',{'Gaussian','Poissonian'},...
    'Value',find(strcmp({'Gaussian','Poissonian'},UserValues.TauFit.WeightedResidualsType)),...
    'Tag','WeightedResidualsType_Menu',...
    'Callback',@UpdateOptions);
h.MCMC_Error_Estimation_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.05 0.5 0.65 0.05],...
    'String','Perform MCMC error estimation?',...
    'FontSize',10,...
    'TooltipString',sprintf('Performs Markov Chain Monte Carlo sampling using the Metropolis-Hasting algorithm\nto estimate the posterior distribution of the model parameters.'),...
    'Tag','NormalizeScatter_Menu',...
    'Callback',[]);
h.Rebin_Histogram_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.05 0.4 0.7 0.075],...
    'String','Increase Histogram Binwidth (Faktor):',...
    'FontSize',10,...
    'Tag','Rebin_Histogram_Text',...
    'Visible','on');
h.Rebin_Histogram_Edit = uicontrol(...
    'Parent',h.Settings_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.8 0.4 0.15 0.075],...
    'String',num2str(UserValues.TauFit.RebinFactor),...
    'FontSize',10,...
    'Tag','Rebin_Histogram_Edit',...
    'Callback',@UpdateOptions,...
    'Visible','on');
h.Cleanup_IRF_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.05 0.05 0.95 0.05],...
    'String','Clean up IRF by fitting to Gamma distribution',...
    'Value',UserValues.TauFit.cleanup_IRF,...
    'FontSize',10,...
    'Tag','Cleanup_IRF_Menu',...
    'Callback',@UpdateOptions);

h.Cleanup_IRF_axes = axes('Parent',h.IRF_Cleanup_Panel,...
    'Position',[0.125,0.2,0.83,0.77],'Units','normalized','FontSize',10,'XColor',Look.Fore,'YColor',Look.Fore);
normaldist = 1./(sqrt(2*pi)*2).*exp(-((1:100)-20).^2./(2*2^2));
h.Plots.IRF_cleanup.IRF_data = plot(h.Cleanup_IRF_axes,1:1:100,normaldist,'LineStyle','none','Marker','.','MarkerSize',10);
hold on;
normaldist = 1./(sqrt(2*pi)*2).*exp(-((1:0.1:100)-20).^2./(2*2^2));
h.Plots.IRF_cleanup.IRF_fit = plot(h.Cleanup_IRF_axes,1:0.1:100,normaldist,'LineStyle','-','Marker','none','MarkerSize',10,'LineWidth',2);
h.Cleanup_IRF_axes.XLabel.String = 'Time [ns]';
h.Cleanup_IRF_axes.YLabel.String = 'PDF';
h.Cleanup_IRF_axes.XColor = Look.Fore;
h.Cleanup_IRF_axes.YColor = Look.Fore;
h.Cleanup_IRF_axes.XLabel.Color = Look.Fore;
h.Cleanup_IRF_axes.YLabel.Color = Look.Fore;

h.Restrict_Gauss_Width_Checkbox = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.01 0.125 0.75 0.075],...
    'String','Restrict distribution fit by FRET-averaged distance',...
    'FontSize',10,...
    'Tag','Rebin_Histogram_Text');
h.Restrict_Gauss_Width_Edit = uicontrol(...
    'Parent',h.Settings_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.8 0.125 0.175 0.075],...
    'String','50',...
    'FontSize',10,...
    'Tag','Restrict_Gauss_Width_Edit',...
    'Callback',@UpdateOptions);
%% Special case for Burstwise and noMFD
if any(strcmp(TauFitData.Who,{'Burstwise','BurstBrowser'}))
    switch TauFitData.Who
        case 'Burstwise'
            BAMethod = PamMeta.BurstData.BAMethod;
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
% Set the FontSize to 12
fields = fieldnames(h); %%% loop through h structure
for i = 1:numel(fields)
    if isprop(h.(fields{i}),'FontSize')
        h.(fields{i}).FontSize = 10;
    end
end
h.SpeciesSelect_Text.FontSize = 10;
%% Mac upscaling of Font Sizes
if ismac
    scale_factor = 1.3;
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
    TauFitData.IRFBackground{i} = UserValues.TauFit.IRFBackground{i};
    TauFitData.IRFShift{i} = UserValues.TauFit.IRFShift{i};
    TauFitData.IRFrelShift{i} = UserValues.TauFit.IRFrelShift{i};
    TauFitData.ScatShift{i} = UserValues.TauFit.ScatShift{i};
    TauFitData.ScatrelShift{i} = UserValues.TauFit.ScatrelShift{i};
    TauFitData.Ignore{i} = UserValues.TauFit.Ignore{i};
end
TauFitData.FitType = h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value};
TauFitData.FitMethods = h.FitMethods;
h.subresolution = 10;
guidata(gcf,h);

ChangeLineStyle(h);
% If data is ready to be displayed, display it
% (user sent data from burstbrowser or wants to do a burstwise fitting)
if ~strcmp(TauFitData.Who, 'TauFit') && ~strcmp(TauFitData.Who, 'External')
    Update_Plots(obj);
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
end
Method_Selection(h.FitMethod_Popupmenu,[]);
%%% User clicked 'Burst Analysis' button on the Burst or Batch analysis tab
%%% when 'Fit Lifetime' checkbox was checked.
if exist('ph','var') && isobject(obj) && obj == ph.Burst.Button
    h.TauFit.Visible = 'off'; % hide figure
    % reassign progress bar to PAM progress bar
    h.Progress_Text = ph.Progress.Text;
    h.Progress_Axes = ph.Progress.Axes;
    % do burstwise fit with preset parameters
    BurstWise_Fit(ph.Burst.Button,[])
    close(h.TauFit);
else
    h.TauFit.Visible = 'on';
end

function ChangeScale(obj,~)
global UserValues TauFitData
h = guidata(obj);
switch obj.Tag
    case {'Plot_YLogscale_MIPlot','Plot_YLogscale_ResultPlot'}
        if strcmp(obj.Checked,'off')
            %%% Set Checked
            h.Microtime_Plot_ChangeYScaleMenu_MIPlot.Checked = 'on';
            h.Microtime_Plot_ChangeYScaleMenu_ResultPlot.Checked = 'on';
            %%% Change Scale to Log
            h.Microtime_Plot.YScale = 'log';
            h.Result_Plot.YScale = 'log';
            if h.Cleanup_IRF_Menu.Value
                h.Result_Plot.YLim(1) = min(h.Plots.DecayResult.YData(h.Plots.DecayResult.YData > 0));
            end
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
            %ydat = [h.Plots.IRF_Par.YData,h.Plots.IRF_Per.YData,...
            %    h.Plots.Scat_Par.YData, h.Plots.Scat_Per.YData,...
            %    h.Plots.Decay_Par.YData,h.Plots.Decay_Per.YData];
            ydat = [h.Plots.Decay_Par.YData,h.Plots.Decay_Per.YData];
            ydat = ydat(ydat > 0);
            h.Ignore_Plot.YData = [...
                min(ydat),min(ydat)...
                h.Microtime_Plot.YLim(2),h.Microtime_Plot.YLim(2)];
        else
            h.Ignore_Plot.YData = [...
                0,0,...
                h.Microtime_Plot.YLim(2),h.Microtime_Plot.YLim(2)];
        end
    case {'Plot_XLogscale_MIPlot','Plot_XLogscale_ResultPlot'}
        if strcmp(obj.Checked,'off')
            %%% Set Checked
            h.Microtime_Plot_ChangeXScaleMenu_MIPlot.Checked = 'on';
            h.Microtime_Plot_ChangeXScaleMenu_ResultPlot.Checked = 'on';
            %%% Change Scale to Log
            h.Microtime_Plot.XScale = 'log';
            h.Result_Plot.XScale = 'log';
            UserValues.TauFit.XScaleLog = 'on';
        elseif strcmp(obj.Checked,'on')
            %%% Set Unchecked
            h.Microtime_Plot_ChangeXScaleMenu_MIPlot.Checked = 'off';
            h.Microtime_Plot_ChangeXScaleMenu_ResultPlot.Checked = 'off';
            %%% Change Scale to Lin
            h.Microtime_Plot.XScale = 'lin';
            h.Result_Plot.XScale = 'lin';
            UserValues.TauFit.XScaleLog = 'off';
        end
end

LSUserValues(1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Load Data Button (TauFit raw PIE channel data) %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Data(obj,~)
global UserValues TauFitData FileInfo PamMeta
h = guidata(findobj('Tag','TauFit'));

%%% check how we got here
if obj == h.Menu.OpenDecayData || strcmp(TauFitData.Who, 'External')
    switch obj
        case {h.Menu.OpenDecayData,h.Menu.OpenDecayDOnlyData_PQ,h.Menu.OpenIRFData_PQ,h.Menu.OpenDecayData_PQ}
            switch obj
                case h.Menu.OpenDecayData
                    %%% called upon loading of text-based *.dec file
                    %%% load file
                    [FileName, PathName, FilterIndex] = uigetfile({'*.dec','PAM decay file'},'Choose data file...',UserValues.File.TauFitPath,'Multiselect','on');
                    if FilterIndex == 0
                        return;
                    end
                    UserValues.File.TauFitPath = PathName;
                    if ~iscell(FileName)
                        FileName = {FileName};
                    end
                    TauFitData.External = struct;
                    TauFitData.External.MI_Hist = {};
                    TauFitData.External.IRF = {};
                    TauFitData.External.Scat = {};
                    if isfield(TauFitData,'OriginalHistograms')
                        TauFitData = rmfield(TauFitData,'OriginalHistograms');
                    end
                    for j = 1:numel(FileName) %%% assumes that all loaded files have shared parameters! (i.e. TAC range, donor only etc etc)
                        decay_data = dlmread(fullfile(PathName,FileName{j}),'\t',6,0);
                        %%% read other data
                        fid = fopen(fullfile(PathName,FileName{j}),'r');
                        TAC = textscan(fid,'TAC range [ns]:\t%f\n'); TauFitData.TACRange = TAC{1}*1E-9;
                        MI_Bins = textscan(fid,'Microtime Bins:\t%f\n'); TauFitData.MI_Bins = MI_Bins{1};
                        TACChannelWidth = textscan(fid,'Resolution [ps]:\t%f\n'); TauFitData.TACChannelWidth = TACChannelWidth{1}*1E-3;
                        fid = fopen(fullfile(PathName,FileName{j}),'r');
                        for i = 1:5
                            line = fgetl(fid);
                        end
                        PIEchans{j} = strsplit(line,'\t');
                        PIEchans{j}(cellfun(@isempty,PIEchans{j})) = [];
                        PIEchans{j} = PIEchans{j}(1:(size(decay_data,2)/3)); % remove empty channels at the end (DOnly)
                        if numel(FileName) > 1 %%% multiple files loaded, append the file name to avoid confusion of identically named PIE channels
                            for i = 1:numel(PIEchans{j})
                                PIEchans{j}{i} = [PIEchans{j}{i} ' - ' FileName{j}(1:end-4)];
                            end
                        end
                        %%% sort data into TauFitData structure (MI,IRF,Scat)
                        for i = 1:(size(decay_data,2)/3)
                            TauFitData.External.MI_Hist{end+1} = decay_data(:,3*(i-1)+1);
                            TauFitData.External.IRF{end+1} = decay_data(:,3*(i-1)+2);
                            TauFitData.External.Scat{end+1} = decay_data(:,3*(i-1)+3);
                        end
                        TauFitData.External.Donly = cell(size(TauFitData.External.MI_Hist));
                        %%% assign donor only if existent
                        if any(startsWith(PIEchans{j},'DOnly'))
                            %%% check whether polarization data or not
                            %%% and assign donor only
                            if any(strcmp(PIEchans{j},'DOnly1'))
                                donly_idx_par = strcmp(PIEchans{j},'DOnly1');
                                donly_idx_per = strcmp(PIEchans{j},'DOnly2');
                                dd_idx_par = strcmp(PIEchans{j},'DD1');
                                dd_idx_per = strcmp(PIEchans{j},'DD2');
                                TauFitData.External.Donly{dd_idx_par} = TauFitData.External.MI_Hist{donly_idx_par};
                                TauFitData.External.Donly{dd_idx_per} = TauFitData.External.MI_Hist{donly_idx_per};
                            else
                                donly_idx = strcmp(PIEchans{j},'DOnly');
                                dd_idx = strcmp(PIEchans{j},'DD');
                                TauFitData.External.Donly{dd_idx} = TauFitData.External.MI_Hist{donly_idx};
                            end
                        end
                    end
                    PIEchans = horzcat(PIEchans{:});
                    %%% update PIE channel selection with available PIE channels
                    h.PIEChannelPar_Popupmenu.String = PIEchans;
                    h.PIEChannelPer_Popupmenu.String = PIEchans;
                    %%% mark TauFit mode as external
                    TauFitData.Who = 'External';
                    TauFitData.FileName = fullfile(PathName,FileName{1});
                    if numel(PIEchans) == 1
                        PIEChannel_Par = 1; PIEChannel_Per = 1;
                    else
                        PIEChannel_Par = 1; PIEChannel_Per = 2;
                    end
                    h.PIEChannelPar_Popupmenu.Value = PIEChannel_Par;
                    h.PIEChannelPer_Popupmenu.Value = PIEChannel_Per;
                    
                    %%% Update title to reflect the filename
                    h.TauFit.Name = ['TauFit - Loaded file: ' FileName{1}];
                case {h.Menu.OpenDecayDOnlyData_PQ,h.Menu.OpenIRFData_PQ,h.Menu.OpenDecayData_PQ}
                    %%% loading PQ data
                    filetypes = {'*.dat','PQ decay file (*.dat)';'*.txt;*.csv;*.dat','Tab-separated text file (*.txt;*.csv;*.dat)'};
                    if UserValues.TauFit.FileTypeTXT == 2
                        filetypes = flipud(filetypes);
                    end
                    [FileName, PathName, FilterIndex] = uigetfile_with_preview(filetypes,'Choose data file...',UserValues.File.TauFitPath);
                    if isempty(FileName)
                        return;
                    end
                    if FilterIndex == 0
                        return;
                    end
                    if UserValues.TauFit.FileTypeTXT == 2
                        %%% switch again
                        FilterIndex = 3-FilterIndex; % 1->2, 2->1
                    end
                    UserValues.TauFit.FileTypeTXT  = FilterIndex;
                    UserValues.File.TauFitPath = PathName;
                    if ~iscell(FileName)
                        FileName = {FileName};
                    end
                    %%% only load one file for now
                    switch FilterIndex
                        case 1 %%% pq data
                            [time,decay,header] = load_PQ_decay(fullfile(PathName,FileName{1}));
                            % read data from header
                            sync = textscan(header.Sync_Frequency,'%d Hz');
                            TAC = (1./double(sync{1}));
                            res = textscan(header.Meas_BinWidth,'%d ps');
                            TACChannelWidth = double(res{1})*1E-3;
                        case 2
                            data = dlmread(fullfile(PathName,FileName{1}))';
                            if size(data,1) < size(data,2) % flip if needed
                                data = data';
                            end
                            if size(data,2) > 1 % time and intensity is saved
                                time = data(:,1); time = time-time(1);
                                decay = data(:,2);
                                TAC = max(time)*1E-9;
                                TACChannelWidth = time(2);
                            elseif size(data,2) == 1 % only intensity is saved
                                decay = data;
                                if obj == h.Menu.OpenDecayData_PQ % loading first file
                                    %%% check if time bin width is specified in file name
                                    %expr = '([0-9]+)ps';
                                    %m = regexp(FileName{1},expr,'tokens');
                                    %if ~isempty(m)
                                    %    TACChannelWidth = str2double(m{1})/1000;
                                    %else
                                    %    disp('Please specify the time resolution in the filename as e.g. "_2ps".');
                                    %end
                                    
                                    %%% ask for TAC channel width
                                    TACChannelWidth = inputdlg({'Specify TCSPC channel width in ps:'},'TCSPC channel width?',[1,40],{'32'});
                                    TACChannelWidth = str2double(TACChannelWidth{1})/1000;
                                    TAC = size(data,1).*TACChannelWidth*1E-9;
                                else
                                    TACChannelWidth = TauFitData.TACChannelWidth;
                                    TAC = TauFitData.TACRange;
                                end
                                time = (1:size(data,1)).*TACChannelWidth;
                            end
                    end
                    
                    switch obj
                        case h.Menu.OpenDecayData_PQ
                            set([h.Menu.OpenDecayDOnlyData_PQ,h.Menu.OpenIRFData_PQ],'Enable','on');
                            
                            TauFitData.TACRange = TAC;
                            MI_Bins = numel(time); TauFitData.MI_Bins = MI_Bins;
                            
                            TauFitData.TACChannelWidth = TACChannelWidth;
                            if ~isfield(TauFitData,'External') % first time
                                TauFitData.External = struct;
                                TauFitData.External.MI_Hist = {};
                                TauFitData.External.IRF = {};
                                TauFitData.External.Scat = {};
                                TauFitData.External.Donly = {};
                                PIEchans = [];
                            else
                                PIEchans = h.PIEChannelPar_Popupmenu.String;
                            end
                            TauFitData.External.MI_Hist{end+1} = decay;
                            if numel(TauFitData.External.MI_Hist) == 1 % first data, there is no IRF
                                TauFitData.External.IRF{end+1} = zeros(size(decay));
                                TauFitData.External.Scat{end+1} = zeros(size(decay));
                                TauFitData.External.Donly{end+1} = zeros(size(decay));
                            else %%% take previous datasets IRF
                                TauFitData.External.IRF{end+1} = TauFitData.External.IRF{end};
                                TauFitData.External.Scat{end+1} =TauFitData.External.Scat{end};
                                TauFitData.External.Donly{end+1} = TauFitData.External.Donly{end};
                            end
                            PIEchans{end+1} = FileName{1};
                            h.PIEChannelPar_Popupmenu.String = PIEchans;
                            h.PIEChannelPer_Popupmenu.String = PIEchans;
                            TauFitData.Who = 'External';
                            TauFitData.FileName = fullfile(PathName,FileName{1});
                            PIEChannel_Par = 1; PIEChannel_Per = 1;
                            h.PIEChannelPar_Popupmenu.Value = PIEChannel_Par;
                            h.PIEChannelPer_Popupmenu.Value = PIEChannel_Per;
                        case h.Menu.OpenIRFData_PQ
                            %%% only update the IRF information
                            %%% only for the currently selected first (parallel) channel
                            TauFitData.External.IRF{h.PIEChannelPar_Popupmenu.Value} = decay;
                            TauFitData.External.Scat{h.PIEChannelPar_Popupmenu.Value} = decay;
                            PIEChannel_Par = h.PIEChannelPar_Popupmenu.Value;
                            PIEChannel_Per = h.PIEChannelPer_Popupmenu.Value;
                        case h.Menu.OpenDecayDOnlyData_PQ
                            %%% only for the currently selected first (parallel) channel
                            TauFitData.External.Donly{h.PIEChannelPar_Popupmenu.Value} = decay;
                            PIEChannel_Par = h.PIEChannelPar_Popupmenu.Value;
                            PIEChannel_Per = h.PIEChannelPer_Popupmenu.Value;
                    end
            end
        case h.LoadData_Button
            PIEChannel_Par = h.PIEChannelPar_Popupmenu.Value;
            PIEChannel_Per = h.PIEChannelPer_Popupmenu.Value;           
    end
    
    %%% set the channel variable
    chan = 4; TauFitData.chan = chan;
    
    %%% Microtime Histograms
    TauFitData.hMI_Par{chan} = TauFitData.External.MI_Hist{PIEChannel_Par};
    TauFitData.hMI_Per{chan} = TauFitData.External.MI_Hist{PIEChannel_Per};
        
    %%% Read out the Microtime Histograms of the IRF for the two channels
    TauFitData.hIRF_Par{chan} = TauFitData.External.IRF{PIEChannel_Par}';
    TauFitData.hIRF_Per{chan} = TauFitData.External.IRF{PIEChannel_Per}';
    %%% Normalize IRF for better Visibility
    TauFitData.hIRF_Par{chan} = (TauFitData.hIRF_Par{chan}./max(TauFitData.hIRF_Par{chan})).*max(TauFitData.hMI_Par{chan});
    TauFitData.hIRF_Per{chan} = (TauFitData.hIRF_Per{chan}./max(TauFitData.hIRF_Per{chan})).*max(TauFitData.hMI_Per{chan});
    %%% Read out the Microtime Histograms of the Scatter Measurement for the two channels
    TauFitData.hScat_Par{chan} = TauFitData.External.Scat{PIEChannel_Par}';
    TauFitData.hScat_Per{chan} = TauFitData.External.Scat{PIEChannel_Per}';
    %%% Normalize Scatter for better Visibility
    if ~(sum(TauFitData.hScat_Par{chan})==0)
        TauFitData.hScat_Par{chan} = (TauFitData.hScat_Par{chan}./max(TauFitData.hScat_Par{chan})).*max(TauFitData.hMI_Par{chan});
    end
    if ~(sum(TauFitData.hScat_Per{chan})==0)
        TauFitData.hScat_Per{chan} = (TauFitData.hScat_Per{chan}./max(TauFitData.hScat_Per{chan})).*max(TauFitData.hMI_Per{chan});
    end
    %%% Generate XData
    TauFitData.XData_Par{chan} = 1:numel(TauFitData.hMI_Par{chan});%ToFromPar - ToFromPar(1);
    TauFitData.XData_Per{chan} = 1:numel(TauFitData.hMI_Per{chan});%ToFromPer - ToFromPer(1);
    
    %%% if rebinning is performed, store as original data
    if isfield(TauFitData,'OriginalHistograms')
        TauFitData.OriginalHistograms.hMI_Par{chan} = TauFitData.hMI_Par{chan};
        TauFitData.OriginalHistograms.hMI_Per{chan} = TauFitData.hMI_Per{chan};
        TauFitData.OriginalHistograms.hIRF_Par{chan} = TauFitData.hIRF_Par{chan};
        TauFitData.OriginalHistograms.hIRF_Per{chan} = TauFitData.hIRF_Per{chan};
        TauFitData.OriginalHistograms.hScat_Par{chan} = TauFitData.hScat_Par{chan};
        TauFitData.OriginalHistograms.hScat_Per{chan} = TauFitData.hScat_Per{chan};
    end
    
    %%% Update PIEchannelSelection
    UserValues.TauFit.PIEChannelSelection{1} = h.PIEChannelPar_Popupmenu.String{h.PIEChannelPar_Popupmenu.Value};
    UserValues.TauFit.PIEChannelSelection{2} = h.PIEChannelPer_Popupmenu.String{h.PIEChannelPer_Popupmenu.Value};
    
    h.LoadData_Button.String = 'Plot Selection';
    h.LoadData_Button.Enable = 'on';
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
    
    %%% Update PIEchannelSelection
    UserValues.TauFit.PIEChannelSelection{1} = h.PIEChannelPar_Popupmenu.String{h.PIEChannelPar_Popupmenu.Value};
    UserValues.TauFit.PIEChannelSelection{2} = h.PIEChannelPer_Popupmenu.String{h.PIEChannelPer_Popupmenu.Value};
    
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
        elseif any(UserValues.BurstSearch.Method == [5,6])
            chan = 4;
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
%%% disable reconvolution fitting if no IRF is defined
if all(isnan(TauFitData.hIRF_Par{chan})) || all(isnan(TauFitData.hIRF_Per{chan}))
    disp('IRF undefined, disabling reconvolution fitting.');
    h.Fit_Button.Enable = 'off';
elseif all(isnan(TauFitData.hScat_Par{chan})) || all(isnan(TauFitData.hScat_Per{chan}))
    disp('Scatter pattern undefined, using IRF instead.');
    TauFitData.hScat_Par{chan} = TauFitData.hIRF_Par{chan};
    TauFitData.hScat_Per{chan} = TauFitData.hIRF_Per{chan};
else
    h.Fit_Button.Enable = 'on';
end
%%% fix wrong length of IRF or Scatter pattern
len = numel(TauFitData.hMI_Par{chan});
if numel(TauFitData.hIRF_Par{chan}) < len
    TauFitData.hIRF_Par{chan} = [TauFitData.hIRF_Par{chan},zeros(1,len-numel(TauFitData.hIRF_Par{chan}))];
elseif numel(TauFitData.hIRF_Par{chan}) > len
    TauFitData.hIRF_Par{chan} = TauFitData.hIRF_Par{chan}(1:len);
end
if numel(TauFitData.hIRF_Per{chan}) < len
    TauFitData.hIRF_Per{chan} = [TauFitData.hIRF_Per{chan},zeros(1,len-numel(TauFitData.hIRF_Per{chan}))];
elseif numel(TauFitData.hIRF_Per{chan}) > len
    TauFitData.hIRF_Per{chan} = TauFitData.hIRF_Per{chan}(1:len);
end
if numel(TauFitData.hScat_Par{chan}) < len
    TauFitData.hScat_Par{chan} = [TauFitData.hScat_Par{chan},zeros(1,len-numel(TauFitData.hScat_Par{chan}))];
elseif numel(TauFitData.hScat_Par{chan}) > len
    TauFitData.hScat_Par{chan} = TauFitData.hScat_Par{chan}(1:len);
end
if numel(TauFitData.hScat_Per{chan}) < len
    TauFitData.hScat_Per{chan} = [TauFitData.hScat_Per{chan},zeros(1,len-numel(TauFitData.hScat_Per{chan}))];
elseif numel(TauFitData.hScat_Per{chan}) > len
    TauFitData.hScat_Per{chan} = TauFitData.hScat_Per{chan}(1:len);
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
        h.l2_edit,h.l2_text,...
        h.ShowAniso_radiobutton,h.ShowDecay_radiobutton,h.ShowDecaySum_radiobutton],'Visible','off');
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
    if h.FitMethod_Popupmenu.Value > 9
        h.FitMethod_Popupmenu.Value = 1;
    end
    h.FitMethod_Popupmenu.String = h.FitMethods(1:9);
    [h.FitPar_Table.Data, h.FitPar_Table.RowName, Tooltip] = GetTableData(h.FitMethod_Popupmenu.Value, chan);
    try
        h.FitPar_Table.TooltipString = Tooltip;
    catch %%% in newer version, this is now just called "Tooltip"
        h.FitPar_Table.Tooltip = Tooltip;
    end
else
    set([h.ShiftPer_Edit,h.ShiftPer_Text,h.ShiftPer_Slider,...%%% perp sliders
        h.ScatrelShift_Edit,h.ScatrelShift_Text,h.ScatrelShift_Slider,...
        h.IRFrelShift_Edit,h.IRFrelShift_Text,h.IRFrelShift_Slider,...
        h.Fit_Aniso_Button,h.Determine_GFactor_Button,...%%% anisotropy related buttons
        h.G_factor_edit,h.G_factor_text,...
        h.l1_edit,h.l1_text,...
        h.l2_edit,h.l2_text,...
        h.ShowAniso_radiobutton,h.ShowDecay_radiobutton,h.ShowDecaySum_radiobutton],'Visible','on');
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

if UserValues.TauFit.RebinFactor > 1
    UpdateOptions(h.Rebin_Histogram_Edit);
else
    Update_Plots(obj);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Save Data to decay (*.dec) file format %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Save_Data(obj,~)
global UserValues TauFitData FileInfo TcspcData PamMeta
h = guidata(findobj('Tag','TauFit'));

% read the channel names
if (h.PIEChannelPar_Popupmenu.Value ~= h.PIEChannelPer_Popupmenu.Value)
    channel_names = {h.PIEChannelPar_Popupmenu.String{h.PIEChannelPar_Popupmenu.Value},...
        h.PIEChannelPer_Popupmenu.String{h.PIEChannelPer_Popupmenu.Value}};
else
    channel_names = {h.PIEChannelPar_Popupmenu.String{h.PIEChannelPar_Popupmenu.Value}};
end
fn = [strjoin(channel_names,'_') '.dec'];
% get filename
[FileName, PathName] = uiputfile('*.dec','Choose file location...',fullfile(UserValues.File.TauFitPath,fn));
FileName = fullfile(PathName,FileName);
% get the data
microtimeHistograms = [];
switch TauFitData.Who
    case 'External'
        microtimeHistograms = [TauFitData.External.MI_Hist{h.PIEChannelPar_Popupmenu.Value},...
            TauFitData.External.IRF{h.PIEChannelPar_Popupmenu.Value},...
            TauFitData.External.Scat{h.PIEChannelPar_Popupmenu.Value}];
        if (h.PIEChannelPar_Popupmenu.Value ~= h.PIEChannelPer_Popupmenu.Value)
            microtimeHistograms = [microtimeHistograms,...
                TauFitData.External.MI_Hist{h.PIEChannelPer_Popupmenu.Value},...
                TauFitData.External.IRF{h.PIEChannelPer_Popupmenu.Value},...
                TauFitData.External.Scat{h.PIEChannelPer_Popupmenu.Value}];
        end
end
%%% write to *.dec file
fid = fopen(FileName,'w');
%%% write header
%%% general info
fprintf(fid,'TAC range [ns]:\t\t %.2f\nMicrotime Bins:\t\t %d\nResolution [ps]:\t %.2f\n\n',...
    1E9*TauFitData.TACRange,...
    TauFitData.MI_Bins,...
    1E12*TauFitData.TACRange/TauFitData.MI_Bins);
%%% PIE channel names
for i = 1:numel(channel_names)
    fprintf(fid,'%s\t\t\t',channel_names{i});
end
fprintf(fid,'\n');
for i = 1:numel(channel_names)
    fprintf(fid,'%s\t%s\t%s\t','Decay','IRF','Scatter');
end
fprintf(fid,'\n');
fclose(fid);
dlmwrite(FileName,microtimeHistograms,'-append','delimiter','\t');

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
    TauFitData.chan = chan;
else
    if isfield(TauFitData,'chan')
        chan = TauFitData.chan;
    else
        return;
    end
end

G = str2double(h.G_factor_edit.String);
l1 = str2double(h.l1_edit.String);
l2 = str2double(h.l2_edit.String);

if ~isprop(obj, 'Style')
    dummy = '';
else
    dummy = obj.Style;
end

if obj == h.FitPar_Table
    dummy = 'table';
    
end
% nanoseconds per microtime bin
TACtoTime = TauFitData.TACChannelWidth;%1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;

if isempty(obj) || strcmp(dummy,'pushbutton') || strcmp(dummy,'popupmenu') || isempty(dummy) || obj == h.Rebin_Histogram_Edit
    %LoadData button or Burstwise lifetime button was pressed
    %%% Plot the Data
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
        %h.IncludeChannel_checkbox.Value = 0;
        %UserValues.TauFit.IncludeChannel(h.ChannelSelect_Popupmenu.Value) = 0;
        %LSUserValues(1);
        %return
    end
    %%% Define the Slider properties
    %%% Values to consider:
    %%% The length of the shortest PIE channel
    TauFitData.MaxLength{chan} = min([numel(TauFitData.hMI_Par{chan}) numel(TauFitData.hMI_Per{chan})]);
    
    %%% The Length Slider defaults to the length of the shortest PIE
    %%% channel and should not assume larger values
    h.Length_Slider.Min = 1;
    h.Length_Slider.Max = TauFitData.MaxLength{chan};
    h.Length_Slider.SliderStep =[1, 10]*(1/(h.Length_Slider.Max-h.Length_Slider.Min));
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
    h.StartPar_Slider.SliderStep =[1, 10]*(1/(h.StartPar_Slider.Max-h.StartPar_Slider.Min));
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
    %%% Note: (!)
    %%% While shift of < 1 (e.g. 0.1) are in principle possible, they
    %%% change the noise characteristics and thus the obtained chi2 is
    %%% wrong!
    h.ShiftPer_Slider.SliderStep = [1, 10]*(1/(h.ShiftPer_Slider.Max-h.ShiftPer_Slider.Min));%[0.1, 1]*(1/(h.ShiftPer_Slider.Max-h.ShiftPer_Slider.Min));
    if UserValues.TauFit.ShiftPer{chan} >= -floor(TauFitData.MaxLength{chan}/20)...
            && UserValues.TauFit.ShiftPer{chan} <= floor(TauFitData.MaxLength{chan}/20)
        tmp = round(UserValues.TauFit.ShiftPer{chan});
    else
        tmp = 0;
    end
    h.ShiftPer_Slider.Value = tmp;
    TauFitData.ShiftPer{chan} = tmp;
    h.ShiftPer_Edit.String = num2str(tmp);
    
    %%% IRF Length has the same limits as the Length property
    h.IRFLength_Slider.Min = 1;
    h.IRFLength_Slider.Max = TauFitData.MaxLength{chan};
    h.IRFLength_Slider.SliderStep =[1, 10]*(1/(h.IRFLength_Slider.Max-h.IRFLength_Slider.Min));
    if UserValues.TauFit.IRFLength{chan} >= 0 && UserValues.TauFit.IRFLength{chan} <= TauFitData.MaxLength{chan}
        tmp = UserValues.TauFit.IRFLength{chan};
    else
        tmp = TauFitData.MaxLength{chan};
    end
    h.IRFLength_Slider.Value = tmp;
    TauFitData.IRFLength{chan} = tmp;
    h.IRFLength_Edit.String = num2str(tmp);
    
    %%% IRF Background is between 0 and 1
    h.IRFBackground_Slider.Min = 0;
    h.IRFBackground_Slider.Max = 1;
    h.IRFBackground_Slider.SliderStep =[.01, .1];
    if UserValues.TauFit.IRFBackground{chan} >= 0 && UserValues.TauFit.IRFBackground{chan} <= 1
        tmp = UserValues.TauFit.IRFBackground{chan};
    else
        tmp = 0;
    end
    h.IRFBackground_Slider.Value = tmp;
    TauFitData.IRFBackground{chan} = tmp;
    h.IRFBackground_Edit.String = num2str(tmp);
    
    %%% IRF Shift has the same limits as the perp shift property
    h.IRFShift_Slider.Min = -floor(TauFitData.MaxLength{chan}/20);
    h.IRFShift_Slider.Max = floor(TauFitData.MaxLength{chan}/20);
    h.IRFShift_Slider.SliderStep =[0.1, 1]*(1/(h.IRFShift_Slider.Max-h.IRFShift_Slider.Min));
    tmp = UserValues.TauFit.IRFShift{chan};
    
    limit_IRF_range = false; % reset to 0 if IRFshift does not make sense
    if limit_IRF_range
        if UserValues.TauFit.IRFShift{chan} >= -floor(TauFitData.MaxLength{chan}/20)...
                && UserValues.TauFit.IRFShift{chan} <= floor(TauFitData.MaxLength{chan}/20)
            tmp = UserValues.TauFit.IRFShift{chan};
        else
            tmp = 0;
        end
    end
    
    h.IRFShift_Slider.Value = tmp;
    TauFitData.IRFShift{chan} = tmp;
    h.IRFShift_Edit.String = num2str(tmp);
    
    %%% IRF rel. Shift has the same limits as the perp shift property
    h.IRFrelShift_Slider.Min = -floor(TauFitData.MaxLength{chan}/20);
    h.IRFrelShift_Slider.Max = floor(TauFitData.MaxLength{chan}/20);
    h.IRFrelShift_Slider.SliderStep =[0.1, 1]*(1/(h.IRFrelShift_Slider.Max-h.IRFrelShift_Slider.Min));
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
    h.ScatShift_Slider.SliderStep =[0.1, 1]*(1/(h.ScatShift_Slider.Max-h.ScatShift_Slider.Min));
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
    h.ScatrelShift_Slider.SliderStep =[0.1, 1]*(1/(h.ScatrelShift_Slider.Max-h.ScatrelShift_Slider.Min));
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
    h.Ignore_Slider.Max = floor(TauFitData.MaxLength{chan}/5);
    h.Ignore_Slider.SliderStep =[1, 10]*(1/(h.Ignore_Slider.Max-h.Ignore_Slider.Min));
    if UserValues.TauFit.Ignore{chan} >= 1 && UserValues.TauFit.Ignore{chan} <= floor(TauFitData.MaxLength{chan}/5)
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
                TauFitData.StartPar{chan} = floor(str2double(obj.String));
                obj.String = num2str(TauFitData.StartPar{chan});
            end
        case {h.Length_Slider, h.Length_Edit}
            %%% Update Value
            if obj == h.Length_Slider
                TauFitData.Length{chan} = floor(obj.Value);
            elseif obj == h.Length_Edit
                TauFitData.Length{chan} = floor(str2double(obj.String));
                obj.String = num2str(TauFitData.Length{chan});
            end
            %%% Correct if IRFLength exceeds the Length
            if TauFitData.IRFLength{chan} > TauFitData.Length{chan}
                TauFitData.IRFLength{chan} = TauFitData.Length{chan};
                h.IRFLength_Edit.String = num2str(TauFitData.IRFLength{chan});
                h.IRFLength_Slider.Value = TauFitData.IRFLength{chan};
            end
        case {h.ShiftPer_Slider, h.ShiftPer_Edit}
            %%% Update Value
            %%% Note: (!)
            %%% While shifts of < 1 (e.g. 0.1) are in principle possible, they
            %%% change the noise characteristics and thus the obtained chi2 is
            %%% wrong!
            if obj == h.ShiftPer_Slider
                TauFitData.ShiftPer{chan} = floor(obj.Value);%round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.ShiftPer_Edit
                TauFitData.ShiftPer{chan} = floor(str2double(obj.String));%round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(TauFitData.ShiftPer{chan});
            end
        case {h.IRFLength_Slider, h.IRFLength_Edit}
            %%% Update Value
            if obj == h.IRFLength_Slider
                TauFitData.IRFLength{chan} = floor(obj.Value);
            elseif obj == h.IRFLength_Edit
                TauFitData.IRFLength{chan} = floor(str2double(obj.String));
                obj.String = num2str(TauFitData.IRFLength{chan});
            end
            %%% Correct if IRFLength exceeds the Length
            if TauFitData.IRFLength{chan} > TauFitData.Length{chan}
                TauFitData.IRFLength{chan} = TauFitData.Length{chan};
            end
        case {h.IRFBackground_Slider, h.IRFBackground_Edit}
            if obj == h.IRFBackground_Slider
                TauFitData.IRFBackground{chan} = obj.Value;
            elseif obj == h.IRFBackground_Edit
                TauFitData.IRFBackground{chan} = str2double(obj.String);
                obj.String = num2str(TauFitData.IRFBackground{chan});
            end
        case {h.IRFShift_Slider, h.IRFShift_Edit}
            %%% Update Value
            if obj == h.IRFShift_Slider
                TauFitData.IRFShift{chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.IRFShift_Edit
                TauFitData.IRFShift{chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(TauFitData.IRFShift{chan});
            end
        case {h.IRFrelShift_Slider, h.IRFrelShift_Edit}
            %%% Update Value
            if obj == h.IRFrelShift_Slider
                TauFitData.IRFrelShift{chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.IRFrelShift_Edit
                TauFitData.IRFrelShift{chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(TauFitData.IRFrelShift{chan});
            end
        case {h.ScatShift_Slider, h.ScatShift_Edit}
            %%% Update Value
            if obj == h.ScatShift_Slider
                TauFitData.ScatShift{chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.ScatShift_Edit
                TauFitData.ScatShift{chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(TauFitData.ScatShift{chan});
            end
        case {h.ScatrelShift_Slider, h.ScatrelShift_Edit}
            %%% Update Value
            if obj == h.ScatrelShift_Slider
                TauFitData.ScatrelShift{chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.ScatrelShift_Edit
                TauFitData.ScatrelShift{chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(TauFitData.ScatrelShift{chan});
            end
        case {h.Ignore_Slider,h.Ignore_Edit}%%% Update Value
            if obj == h.Ignore_Slider
                TauFitData.Ignore{chan} = floor(obj.Value);
            elseif obj == h.Ignore_Edit
                if str2double(obj.String) <  1
                    TauFitData.Ignore{chan} = 1;
                    obj.String = '1';
                else
                    TauFitData.Ignore{chan} = floor(str2double(obj.String));
                    obj.String = num2str(TauFitData.Ignore{chan});
                end
            end
        case {h.FitPar_Table}
            TauFitData.IRFShift{chan} = round(obj.Data{end,1}*h.subresolution)/h.subresolution;
            %%% Update Edit Box and Slider when user changes value in the table
            h.IRFShift_Edit.String = num2str(TauFitData.IRFShift{chan});
            h.IRFShift_Slider.Value = TauFitData.IRFShift{chan};
        case {h.ShowDecay_radiobutton,h.ShowDecaySum_radiobutton,h.ShowAniso_radiobutton}
            if obj == h.ShowDecay_radiobutton
                if obj.Value == 1 %%% switched on
                    h.ShowAniso_radiobutton.Value = 0;
                    h.ShowDecaySum_radiobutton.Value = 0;
                end
            elseif obj == h.ShowAniso_radiobutton
                if obj.Value == 1 %%% switched on
                    h.ShowDecay_radiobutton.Value = 0;
                    h.ShowDecaySum_radiobutton.Value = 0;
                end
            elseif obj == h.ShowDecaySum_radiobutton
                if obj.Value == 1 %%% switched on
                    h.ShowDecay_radiobutton.Value = 0;
                    h.ShowAniso_radiobutton.Value = 0;
                end
            end
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
            h.IRFBackground_Edit.String = num2str(TauFitData.IRFBackground{chan});
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
            h.IRFBackground_Slider.Value = TauFitData.IRFBackground{chan};
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
    UserValues.TauFit.IRFBackground{chan} = TauFitData.IRFBackground{chan};
    UserValues.TauFit.IRFShift{chan} = TauFitData.IRFShift{chan};
    UserValues.TauFit.IRFrelShift{chan} = TauFitData.IRFrelShift{chan};
    UserValues.TauFit.ScatShift{chan} = TauFitData.ScatShift{chan};
    UserValues.TauFit.ScatrelShift{chan} = TauFitData.ScatrelShift{chan};
    UserValues.TauFit.Ignore{chan} = TauFitData.Ignore{chan};
    LSUserValues(1);
end

%%% if BurstData
if strcmp(TauFitData.Who,'BurstBrowser')
    %%% if two-color MFD data is loaded
    if any(TauFitData.BAMethod == [1,2])
        %%% if donor or donor-only was selected in dropdown menu
        if any(chan == [1,4])
            %%% if Donor only is available
            if numel(TauFitData.hMI_Par) == 4 % DD, AA, DA, DOnly
                if chan == 1
                    %%% if DD is modified, copy settings to DOnly
                    chan_copy = 4;
                elseif chan == 4
                    %%% if DONLY is modified, copy settings to DD
                    chan_copy = 1;
                end
                UserValues.TauFit.StartPar{chan_copy} = TauFitData.StartPar{chan};
                UserValues.TauFit.Length{chan_copy} = TauFitData.Length{chan};
                UserValues.TauFit.ShiftPer{chan_copy} = TauFitData.ShiftPer{chan};
                UserValues.TauFit.IRFLength{chan_copy} = TauFitData.IRFLength{chan};
                UserValues.TauFit.IRFBackground{chan_copy} = TauFitData.IRFBackground{chan};
                UserValues.TauFit.IRFShift{chan_copy} = TauFitData.IRFShift{chan};
                UserValues.TauFit.IRFrelShift{chan_copy} = TauFitData.IRFrelShift{chan};
                UserValues.TauFit.ScatShift{chan_copy} = TauFitData.ScatShift{chan};
                UserValues.TauFit.ScatrelShift{chan_copy} = TauFitData.ScatrelShift{chan};
                UserValues.TauFit.Ignore{chan_copy} = TauFitData.Ignore{chan};
            end
        end
    end
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
%tmp = circshift(TauFitData.hMI_Per{chan},[TauFitData.ShiftPer{chan},0])';
tmp = shift_by_fraction(TauFitData.hMI_Per{chan}, TauFitData.ShiftPer{chan});
h.Plots.Decay_Per.YData = tmp((TauFitData.StartPar{chan}+1):TauFitData.Length{chan});
%%% Apply the shift to the parallel IRF channel
h.Plots.IRF_Par.XData = ((TauFitData.StartPar{chan}:(TauFitData.IRFLength{chan}-1)) - TauFitData.StartPar{chan})*TACtoTime;
%tmp = circshift(TauFitData.hIRF_Par{chan},[0,TauFitData.IRFShift{chan}])';
tmp = shift_by_fraction(TauFitData.hIRF_Par{chan},TauFitData.IRFShift{chan});
if TauFitData.IRFBackground{chan} == 0 % do standard background correction
    %%% additional processing of the IRF to remove constant background
    tmp = tmp - mean(TauFitData.hIRF_Par{chan}(end-round(numel(TauFitData.hIRF_Par{chan})/10):end));
else % do baseline correction
    %tmp = tmp - max(tmp).*TauFitData.IRFBackground{chan};
    tmp(tmp<max(tmp).*TauFitData.IRFBackground{chan}) = NaN;
end
tmp(tmp<0) = NaN;
h.Plots.IRF_Par.YData = tmp((TauFitData.StartPar{chan}+1):TauFitData.IRFLength{chan});
%%% Apply the shift to the perpendicular IRF channel
h.Plots.IRF_Per.XData = ((TauFitData.StartPar{chan}:(TauFitData.IRFLength{chan}-1)) - TauFitData.StartPar{chan})*TACtoTime;
%tmp = circshift(TauFitData.hIRF_Per{chan},[0,TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan}])';
tmp = shift_by_fraction(TauFitData.hIRF_Per{chan},TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan});
if TauFitData.IRFBackground{chan} == 0 % do standard background correction
    %%% additional processing of the IRF to remove constant background
    tmp = tmp - mean(TauFitData.hIRF_Per{chan}(end-round(numel(TauFitData.hIRF_Per{chan})/10):end));
else % do baseline correction
    %tmp = tmp - max(tmp).*TauFitData.IRFBackground{chan};
    tmp(tmp<max(tmp).*TauFitData.IRFBackground{chan}) = NaN;
end
tmp(tmp<0) = NaN;
%tmp = tmp./max(tmp).*max(h.Plots.Decay_Per.YData);
h.Plots.IRF_Per.YData = tmp((TauFitData.StartPar{chan}+1):TauFitData.IRFLength{chan});
%%% Apply the shift to the parallel Scat channel
h.Plots.Scat_Par.XData = ((TauFitData.StartPar{chan}:(TauFitData.Length{chan}-1)) - TauFitData.StartPar{chan})*TACtoTime;
%tmp = circshift(TauFitData.hScat_Par{chan},[0,TauFitData.ScatShift{chan}])';
tmp = shift_by_fraction(TauFitData.hScat_Par{chan},TauFitData.ScatShift{chan});
if h.NormalizeScatter_Menu.Value
    % since the scatter pattern should not contain background, we subtract the constant offset
    maxscat = max(tmp);
    %subtract the constant offset and renormalize the amplitude to what it was
    tmp = (tmp-mean(tmp(end-floor(TauFitData.MI_Bins/50):end)));
    tmp = tmp/max(tmp)*maxscat;
    %tmp(tmp < 0) = 0;
    tmp(isnan(tmp)) = 0;
end
h.Plots.Scat_Par.YData = tmp((TauFitData.StartPar{chan}+1):TauFitData.Length{chan});
%%% Apply the shift to the perpendicular Scat channel
h.Plots.Scat_Per.XData = ((TauFitData.StartPar{chan}:(TauFitData.Length{chan}-1)) - TauFitData.StartPar{chan})*TACtoTime;
%tmp = circshift(TauFitData.hScat_Per{chan},[0,TauFitData.ScatShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.ScatrelShift{chan}])';
tmp = shift_by_fraction(TauFitData.hScat_Per{chan},TauFitData.ScatShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.ScatrelShift{chan});
tmp = tmp((TauFitData.StartPar{chan}+1):TauFitData.Length{chan});
if h.NormalizeScatter_Menu.Value
    % since the scatter pattern should not contain background, we subtract the constant offset
    maxscat = max(tmp);
    tmp = tmp-mean(tmp(end-floor(TauFitData.MI_Bins/50):end));
    tmp = tmp/max(tmp)*maxscat;
    tmp(isnan(tmp)) = 0;
    %tmp(tmp < 0) = 0;
end
h.Plots.Scat_Per.YData = tmp;
h.Ignore_Plot.Visible = 'off';
%%% check if anisotropy plot is selected
legend(h.Microtime_Plot,'off');
if h.ShowAniso_radiobutton.Value == 1
    %%% hide all IRF and Scatter plots
    set([h.Plots.IRF_Par, h.Plots.IRF_Per,h.Plots.Scat_Par,h.Plots.Scat_Per,h.Plots.Decay_Par,h.Plots.Decay_Per],'Visible','off');
    set([h.Plots.Decay_Sum,h.Plots.Aniso_Preview,h.Plots.IRF_Sum,h.Plots.Scat_Sum],'Visible','off');
    h.Plots.Aniso_Preview.Visible = 'on';
    %%% set parallel channel plot to anisotropy
    Decay = G*(1-3*l2)*h.Plots.Decay_Par.YData+(2-3*l1)*h.Plots.Decay_Per.YData;
    Aniso = (G*h.Plots.Decay_Par.YData - h.Plots.Decay_Per.YData)./Decay;
    h.Plots.Aniso_Preview.XData = h.Plots.Decay_Par.XData;
    h.Plots.Aniso_Preview.YData = Aniso;
    ylim(h.Microtime_Plot,[min([0,min(Aniso)-0.02]),max(Aniso)+0.02]);
    h.Microtime_Plot.YLabel.String = 'Anisotropy';
elseif h.ShowDecay_radiobutton.Value == 1
    %%% unihde all IRF and Scatter plots
    set([h.Plots.IRF_Par, h.Plots.IRF_Per,h.Plots.Scat_Par,h.Plots.Scat_Per,h.Plots.Decay_Par,h.Plots.Decay_Per],'Visible','on');
    set([h.Plots.Decay_Sum,h.Plots.Aniso_Preview,h.Plots.IRF_Sum,h.Plots.Scat_Sum],'Visible','off');
    h.Plots.Decay_Par.Color = [0.8510    0.3294    0.1020];
    h.Microtime_Plot.YLimMode = 'auto';
    h.Microtime_Plot.YLim(1) = 0;
    h.Microtime_Plot.YLabel.String = 'Intensity [counts]';
    if ~any(strcmp(TauFitData.Who,{'BurstBrowser','Burstwise'}))
        if h.PIEChannelPar_Popupmenu.Value ~= h.PIEChannelPer_Popupmenu.Value
            %%% show legend
            l = legend([h.Plots.Decay_Par,h.Plots.Decay_Per], {'I_{||}','I_\perp'});
            l.Box = 'off';
        end
    else
        %%% show legend
        l = legend([h.Plots.Decay_Par,h.Plots.Decay_Per], {'I_{||}','I_\perp'});
        l.Box = 'off';
    end
elseif h.ShowDecaySum_radiobutton.Value == 1
    %%% unihde all IRF and Scatter plots
    set([h.Plots.Aniso_Preview,h.Plots.IRF_Par, h.Plots.IRF_Per,h.Plots.Scat_Par,h.Plots.Scat_Per,h.Plots.Decay_Per,h.Plots.Decay_Par],'Visible','off');
    set([h.Plots.Decay_Sum,h.Plots.IRF_Sum,h.Plots.Scat_Sum],'Visible','on');
    Decay = G*(1-3*l2)*h.Plots.Decay_Par.YData+(2-3*l1)*h.Plots.Decay_Per.YData;
    IRF = G*(1-3*l2)*h.Plots.IRF_Par.YData+(2-3*l1)*h.Plots.IRF_Per.YData;
    Scat = G*(1-3*l2)*h.Plots.Scat_Par.YData+(2-3*l1)*h.Plots.Scat_Per.YData;
    set([h.Plots.Decay_Sum,h.Plots.Scat_Sum],'XData',h.Plots.Decay_Par.XData);
    h.Plots.IRF_Sum.XData = h.Plots.IRF_Per.XData;
    h.Plots.Decay_Sum.YData = Decay;
    h.Plots.IRF_Sum.YData = IRF;
    h.Plots.Scat_Sum.YData = Scat;
    h.Microtime_Plot.YLimMode = 'auto';
    h.Microtime_Plot.YLim(1) = 0;
    h.Microtime_Plot.YLabel.String = 'Intensity [counts]';
end
set(h.TauFit,'CurrentAxes',h.Microtime_Plot); %axes(h.Microtime_Plot);
xlim([h.Plots.Decay_Par.XData(1),h.Plots.Decay_Par.XData(end)]);

%%% Update Ignore Plot
if TauFitData.Ignore{chan} > 1
    %%% Make plot visible
    h.Ignore_Plot.Visible = 'on';
    h.Ignore_Plot.XData = [h.Microtime_Plot.XLim(1),TauFitData.Ignore{chan}*TACtoTime TauFitData.Ignore{chan}*TACtoTime,h.Microtime_Plot.XLim(1)];
    if strcmp(h.Microtime_Plot.YScale,'log')
        if h.ShowDecay_radiobutton.Value == 1
            ydat = [h.Plots.IRF_Par.YData,h.Plots.IRF_Per.YData,...
                h.Plots.Scat_Par.YData, h.Plots.Scat_Per.YData,...
                h.Plots.Decay_Par.YData,h.Plots.Decay_Per.YData];
        elseif h.ShowDecaySum_radiobutton.Value == 1
            ydat = [h.Plots.IRF_Sum.YData,h.Plots.Scat_Sum.YData,h.Plots.Decay_Sum.YData];
        elseif h.ShowAniso_radiobutton.Value == 1
            ydat = h.Plots.Aniso_Preview.YData;
        end
        ydat = ydat(ydat > 0);
        h.Ignore_Plot.YData = [...
            min(ydat),min(ydat),...
            h.Microtime_Plot.YLim(2),h.Microtime_Plot.YLim(2)];
    else
        h.Ignore_Plot.YData = [...
            h.Microtime_Plot.YLim(1),h.Microtime_Plot.YLim(1)...
            h.Microtime_Plot.YLim(2),h.Microtime_Plot.YLim(2)];
    end
elseif TauFitData.Ignore{chan} == 1
    %%% Hide Plot Again
    h.Ignore_Plot.Visible = 'off';
end

if h.AutoFit_Menu.Value
    Start_Fit(h.Fit_Button)
end
% hide MEM button
h.Fit_Button_MEM_tau.Visible = 'off';
h.Fit_Button_MEM_dist.Visible = 'off';

drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Saves the changed PIEChannel Selection to UserValues %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Channel_Selection(obj,~)
global UserValues TauFitData
h = guidata(findobj('Tag','TauFit'));
if ~strcmp(TauFitData.Who,'External')
    %%% Update the Channel Selection in UserValues
    UserValues.TauFit.PIEChannelSelection{1} = UserValues.PIE.Name{h.PIEChannelPar_Popupmenu.Value};
    UserValues.TauFit.PIEChannelSelection{2} = UserValues.PIE.Name{h.PIEChannelPer_Popupmenu.Value};
    LSUserValues(1);
end
%%% For recalculation, mark which channel was changed
switch obj
    case h.PIEChannelPar_Popupmenu
        TauFitData.ChannelChanged(1) = 1;
    case h.PIEChannelPar_Popupmenu
        TauFitData.ChannelChanged(2) = 1;
end



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
[h.FitPar_Table.Data, h.FitPar_Table.RowName, Tooltip] = GetTableData(obj.Value, chan);
try
    h.FitPar_Table.TooltipString = Tooltip;
catch %%% in newer version, this is now just called "Tooltip"
    h.FitPar_Table.Tooltip = Tooltip;
end

if strcmp(TauFitData.Who, 'BurstBrowser')
    if strcmp(obj.String{obj.Value},'Distribution Fit - Global Model')
        %%% show donor only reference selection
        set([h.DonorOnlyReference_Text,h.DonorOnlyReference_Popupmenu],'Visible','on');
    else
        %%% hide donor only reference selection
        set([h.DonorOnlyReference_Text,h.DonorOnlyReference_Popupmenu],'Visible','off');
    end
end

% if distribution model is selected, enable GUI options to restrict the
% gaussian width based on the FRET averaged distance
if strcmp(TauFitData.FitType,'Distribution')
    h.Restrict_Gauss_Width_Checkbox.Visible = 'on';
    h.Restrict_Gauss_Width_Edit.Visible = 'on';
else
    h.Restrict_Gauss_Width_Checkbox.Visible = 'off';
    h.Restrict_Gauss_Width_Edit.Visible = 'off';
end

%%% Update UserValues
if ~strcmp(TauFitData.Who,'Burstwise')
    UserValues.TauFit.FitMethod = obj.Value;
end


function sigma_est = get_error_combined_decay(Decay_Par,Decay_Per,G,l1,l2)
%%% Get the correct error estimation for a combined decay par+per.
%%% The variances do not simply sum up because the per decay is used twice.
%%% var(vv+2*vh) = var(vv)+2^2*var(vh) = vv+4*vh
%%%
%%% Here, we also account for the G-factor and anisotropy correction
%%% factors:
%%% VM = G*(1-3*l2)*VV + 2*(1-3*l1)*VH
%%% var(VM) = G*(1-3*l2)^2 * VV+ (2*(1-3*l1))^2 * VH

sigma_est = sqrt( ((G*(1-3*l2))^2) * Decay_Par + ((2*(1-3*l1))^2) * Decay_Per);
sigma_est(sigma_est == 0) = 1;


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
    if isfield(TauFitData,'chan')
        chan = TauFitData.chan;
    else
        return;
    end
end
if gcbo == h.Menu.Export_MIPattern_Fit
    save_fix = false; %%% do not store fix state in UserValues, since it is set to fix all
else
    save_fix = true;
end
h.Result_Plot_Text.Visible = 'off';
h.Output_Text.String = '';
h.Plots.Residuals.Visible = 'on';
h.PlotDynamicFRETLine.Visible = 'off';
h.PlotDynamicFRETLine_Sigma.Visible = 'off';
h.SetDonorOnlyLifetime_Menu.Visible = 'off';
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
%IRFPer = circshift(TauFitData.hIRF_Per{chan},[0,TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan}]);
IRFPer = shift_by_fraction(TauFitData.hIRF_Per{chan},TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan});
IRFPattern = TauFitData.hIRF_Par{chan}(1:TauFitData.Length{chan}) + 2*IRFPer(1:TauFitData.Length{chan});
IRFPattern = IRFPattern'./sum(IRFPattern);

if TauFitData.IRFBackground{chan} == 0 % do standard background correction
    %%% additional processing of the IRF to remove constant background
    IRFPattern = IRFPattern - mean(IRFPattern(end-round(numel(IRFPattern)/10):end));
else % do baseline correction
    IRFPattern = IRFPattern - max(IRFPattern).*TauFitData.IRFBackground{chan};
end
IRFPattern(IRFPattern<0) = 0;
IRFPattern = IRFPattern./sum(IRFPattern);

cleanup_IRF = UserValues.TauFit.cleanup_IRF;
if cleanup_IRF
    IRFPattern = fix_IRF_gamma_dist(IRFPattern,chan);
end

%%% The IRF is also adjusted in the Fit dynamically from the total scatter
%%% pattern and start,length, and shift values stored in ShiftParams -
%%% ShiftParams(1)  :   StartPar
%%% ShiftParams(2)  :   IRFShift
%%% ShiftParams(3)  :   IRFLength
%%%
%%% Update 11/2019!
%%% The IRFShift stored in ShiftParams is not used anymore and is ignored
%%% in the following. Instead, the IRFshift is always the last parameter in
%%% the parameter array and optimized as all other parameters by the fit
%%% routine.
%%% This should be cleaned up in the future.
ShiftParams(1) = TauFitData.StartPar{chan};
ShiftParams(2) = TauFitData.IRFShift{chan}; % not used anymore
ShiftParams(3) = TauFitData.Length{chan};
if ~cleanup_IRF
    ShiftParams(4) = TauFitData.IRFLength{chan};
else
    ShiftParams(4) = TauFitData.Length{chan};
end
%ShiftParams(5) = TauFitData.ScatShift{chan}; %anders, please see if I correctly introduced the scatshift in the models

%%% initialize inputs for fit
if ~any(strcmp(TauFitData.Who,{'BurstBrowser','Burstwise'}))
    if h.PIEChannelPar_Popupmenu.Value ~= h.PIEChannelPer_Popupmenu.Value
        Decay = G*(1-3*l2)*TauFitData.FitData.Decay_Par+(2-3*l1)*TauFitData.FitData.Decay_Per;
        sigma_est = get_error_combined_decay(TauFitData.FitData.Decay_Par,TauFitData.FitData.Decay_Per,G,l1,l2);
    else
        Decay = TauFitData.FitData.Decay_Par;
        sigma_est = sqrt(Decay); sigma_est(sigma_est==0) = 1;
    end
else
    switch TauFitData.BAMethod
        case {1,2,3,4}
            Decay = G*(1-3*l2)*TauFitData.FitData.Decay_Par+(2-3*l1)*TauFitData.FitData.Decay_Per;
            sigma_est = get_error_combined_decay(TauFitData.FitData.Decay_Par,TauFitData.FitData.Decay_Per,G,l1,l2);
        case {5}
            Decay = TauFitData.FitData.Decay_Par;
            sigma_est = sqrt(Decay); sigma_est(sigma_est==0) = 1;
    end
end
Length = numel(Decay);
ignore = TauFitData.Ignore{chan};
%% Start Fit
%%% Update Progressbar
h.Progress_Text.String = 'Fitting...';drawnow;
MI_Bins = TauFitData.MI_Bins;
poissonian_chi2 = UserValues.TauFit.use_weighted_residuals && (h.WeightedResidualsType_Menu.Value == 2); % 1 for Gaussian error, 2 for Poissonian statistics
try
    opts.lsqcurvefit = optimoptions(@lsqcurvefit,'MaxFunctionEvaluations',1E4,'MaxIteration',1E4,'Display','final');
    opts.lsqnonlin = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',1E4,'MaxIteration',1E4,'Display','final');
catch
    %%% naming of options changed in newer MATLAB releases
    %%% This is the naming of older releases.
    opts.lsqcurvefit = optimoptions(@lsqcurvefit,'MaxFunEvals',1E4,'MaxIter',1E4,'Display','final');
    opts.lsqnonlin = optimoptions(@lsqnonlin,'MaxFunEvals',1E4,'MaxIter',1E4,'Display','final');
end
switch obj
    case {h.Fit_Button}
        %%% get fit type
        TauFitData.FitType = h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value};
        %%% Read out parameters
        x0 = cell2mat(h.FitPar_Table.Data(:,1))';
        lb = cell2mat(h.FitPar_Table.Data(:,2))';
        ub = cell2mat(h.FitPar_Table.Data(:,3))';
        fixed = cell2mat(h.FitPar_Table.Data(:,4))';
        %%% Add I0 parameter (Initial fluorescence intensity)
        I0 = 2*max(Decay);
        x0(end+1) = I0;
        lb(end+1) = 0;
        ub(end+1) = Inf;
        fixed(end+1) = false;
        if all(fixed) %%% all parameters fixed, instead just plot the current values
            fit = 0;
        else
            fit = 1;
        end
        alpha = 0.05; %95% confidence interval
        TauFitData.ConfInt = NaN(numel(x0),2);
        
        switch TauFitData.FitType
            case 'Single Exponential'
                %%% Parameter:
                %%% taus    - Lifetimes
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                lifetimes = [1];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                %%% define model function
                ModelFun = @(x,xdata) fitfun_1exp(interlace(x0,x,fixed),xdata);
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est_fit = sigma_est(ignore:end);
                else
                    sigma_est_fit = ones(1,numel(Decay(ignore:end)));
                end
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),0,ignore,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_1exp(interlace(x0,x,fixed),xdata)./sigma_est_fit,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est_fit,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_1exp(interlace(x0,x,fixed),xdata),Decay(ignore:end)),x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 =sum(residuals.^2)/(numel(Decay(ignore:end))-sum(~fixed));
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                FitFun = fitfun_1exp(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,1,Conv_Type});
                if ~poissonian_chi2
                    wres = (Decay-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sigma_est;
                    end
                else
                    wres = MLE_w_res(FitFun,Decay).*sign(Decay-FitFun);
                end
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(ignore:end);
                wres_ignore = wres(1:ignore);
                wres = wres(ignore:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(ignore:end);
                %%% Update FitResult
                FitResult = num2cell(x');
                FitResult{lifetimes} = FitResult{lifetimes}.*TauFitData.TACChannelWidth;
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                TauFitData.I0 = FitResult{end};
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(1) = fix(1);
                    UserValues.TauFit.FitFix{chan}(8) = fix(2);
                    UserValues.TauFit.FitFix{chan}(10) = fix(3);
                    UserValues.TauFit.FitFix{chan}(12) = fix(4);
                end
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{3};
                UserValues.TauFit.IRFShift{chan} = FitResult{4};
                
                % Also update status text
                h.Output_Text.String = {sprintf('I0: %.2f',FitResult{end})};
                
                h.SetDonorOnlyLifetime_Menu.Visible = 'on';
            case 'Biexponential'
                %%% Parameter:
                %%% taus    - Lifetimes
                %%% A       - Amplitude of first lifetime
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                lifetimes = [1,2];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                %%% define model function
                ModelFun = @(x,xdata) fitfun_2exp(interlace(x0,x,fixed),xdata);
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est_fit = sigma_est(ignore:end);
                else
                    sigma_est_fit = ones(1,numel(Decay(ignore:end)));
                end
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),0,ignore,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_2exp(interlace(x0,x,fixed),xdata)./sigma_est_fit,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est_fit,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_2exp(interlace(x0,x,fixed),xdata),Decay(ignore:end)),...
                            x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 = sum(residuals.^2)/(numel(Decay(ignore:end))-sum(~fixed));
                    
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                FitFun = fitfun_2exp(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),0,1,Conv_Type});
                if ~poissonian_chi2
                    wres = (Decay-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sigma_est;
                    end
                else
                    wres = MLE_w_res(FitFun,Decay).*sign(Decay-FitFun);
                end
                
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(ignore:end);
                wres_ignore = wres(1:ignore);
                wres = wres(ignore:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(ignore:end);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{lifetimes(1)} = FitResult{lifetimes(1)}.*TauFitData.TACChannelWidth;
                FitResult{lifetimes(2)} = FitResult{lifetimes(2)}.*TauFitData.TACChannelWidth;
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                %%% Convert Fraction from Amplitude (species) fraction to Intensity fraction
                %%% (i.e. correct for brightness)
                %%% Intensity is proportional to tau*amplitude
                amp1 = FitResult{3}*FitResult{1}; amp2 = (1-FitResult{3})*FitResult{2};
                f1 = amp1./(amp1+amp2);
                f2 = amp2./(amp1+amp2);
                meanTau = FitResult{1}*f1+FitResult{2}*f2;
                meanTau_Fraction = FitResult{1}*FitResult{3} + FitResult{2}*(1-FitResult{3});
                % Also update status text
                h.Output_Text.String = {sprintf('I0: %.2f',FitResult{end}),....
                    sprintf('Mean Lifetime Fraction: %.2f ns',meanTau_Fraction),sprintf('Mean Lifetime Int: %.2f ns',meanTau),...
                    ['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'],...
                    ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.']};
                
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                TauFitData.I0 = FitResult{end};
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(1) = fix(1);
                    UserValues.TauFit.FitFix{chan}(2) = fix(2);
                    UserValues.TauFit.FitFix{chan}(5) = fix(3);
                    UserValues.TauFit.FitFix{chan}(8) = fix(4);
                    UserValues.TauFit.FitFix{chan}(10) = fix(5);
                    UserValues.TauFit.FitFix{chan}(12) = fix(6);
                end
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(2) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(5) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{5};
                UserValues.TauFit.IRFShift{chan} = FitResult{6};
                h.PlotDynamicFRETLine.Visible = 'on';
                h.PlotDynamicFRETLine_Sigma.Visible = 'off';
                h.SetDonorOnlyLifetime_Menu.Visible = 'on';
            case 'Three Exponentials'
                %%% Parameter:
                %%% taus    - Lifetimes
                %%% A1      - Amplitude of first lifetime
                %%% A2      - Amplitude of second lifetime
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                lifetimes = [1:3];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                %%% define model function
                ModelFun = @(x,xdata) fitfun_3exp(interlace(x0,x,fixed),xdata);
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est_fit = sigma_est(ignore:end);
                else
                    sigma_est_fit = ones(1,numel(Decay(ignore:end)));
                end
                
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),0,ignore,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_3exp(interlace(x0,x,fixed),xdata)./sigma_est_fit,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est_fit,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_3exp(interlace(x0,x,fixed),xdata),Decay(ignore:end)),...
                            x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 = sum(residuals.^2)/(numel(Decay(ignore:end))-sum(~fixed));
                    
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                FitFun = fitfun_3exp(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),0,1,Conv_Type});
                
                if ~poissonian_chi2
                    wres = (Decay-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sigma_est;
                    end
                else
                    wres = MLE_w_res(FitFun,Decay).*sign(Decay-FitFun);
                end
                
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(ignore:end);
                wres_ignore = wres(1:ignore);
                wres = wres(ignore:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(ignore:end);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                %%% Convert Lifetimes to Nanoseconds
                for i = 1:numel(lifetimes)
                    FitResult{lifetimes(i)} = FitResult{lifetimes(i)}.*TauFitData.TACChannelWidth;
                end
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
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
                meanTau_Fraction = FitResult{1}*FitResult{4} + FitResult{2}*FitResult{5} + (1-FitResult{4}-FitResult{5})*FitResult{3};
                % FitResult{4} = amp1;
                % FitResult{5} = amp2;
                h.Output_Text.String = {sprintf('I0: %.2f',FitResult{end}),...
                    sprintf('Mean Lifetime Fraction: %.2f ns',meanTau_Fraction),...
                    sprintf('Mean Lifetime Int: %.2f ns',meanTau), ...
                    ['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'], ...
                    ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.'],...
                    ['Intensity fraction of Tau3: ' sprintf('%2.2f',100*f3) ' %.']};
                
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                TauFitData.I0 = FitResult{end};
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(1) = fix(1);
                    UserValues.TauFit.FitFix{chan}(2) = fix(2);
                    UserValues.TauFit.FitFix{chan}(3) = fix(3);
                    UserValues.TauFit.FitFix{chan}(5) = fix(4);
                    UserValues.TauFit.FitFix{chan}(6) = fix(5);
                    UserValues.TauFit.FitFix{chan}(8) = fix(6);
                    UserValues.TauFit.FitFix{chan}(10) = fix(7);
                    UserValues.TauFit.FitFix{chan}(12) = fix(8);
                end
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(2) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(3) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(5) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{7};
                UserValues.TauFit.IRFShift{chan} = FitResult{8};
            case 'Four Exponentials'
                %%% Parameter:
                %%% taus    - Lifetimes
                %%% A1      - Amplitude of first lifetime
                %%% A2      - Amplitude of second lifetime
                %%% A3      - Amplitude of third lifetime
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                lifetimes = [1:4];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                %%% define model function
                ModelFun = @(x,xdata) fitfun_4exp(interlace(x0,x,fixed),xdata);
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est_fit = sigma_est(ignore:end);
                else
                    sigma_est_fit = ones(1,numel(Decay(ignore:end)));
                end
                
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),0,ignore,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_4exp(interlace(x0,x,fixed),xdata)./sigma_est_fit,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est_fit,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_4exp(interlace(x0,x,fixed),xdata),Decay(ignore:end)),...
                            x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 = sum(residuals.^2)/(numel(Decay(ignore:end))-sum(~fixed));
                    
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                FitFun = fitfun_4exp(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),0,1,Conv_Type});
                
                if ~poissonian_chi2
                    wres = (Decay-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sigma_est;
                    end
                else
                    wres = MLE_w_res(FitFun,Decay).*sign(Decay-FitFun);
                end
                
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(ignore:end);
                wres_ignore = wres(1:ignore);
                wres = wres(ignore:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(ignore:end);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                %%% Convert Lifetimes to Nanoseconds
                for i = 1:numel(lifetimes)
                    FitResult{lifetimes(i)} = FitResult{lifetimes(i)}.*TauFitData.TACChannelWidth;
                end
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                %%% fix amplitudes the same way it is done in the fit
                %%% function
                if (FitResult{5} + FitResult{6} + FitResult{7}) > 1
                    a1 = FitResult{5}./(FitResult{5} + FitResult{6} + FitResult{7});
                    a2 = FitResult{6}./(FitResult{5} + FitResult{6} + FitResult{7});
                    a3 = FitResult{7}./(FitResult{5} + FitResult{6} + FitResult{7});
                    FitResult{5} = a1;
                    FitResult{6} = a2;
                    FitResult{7} = a3;
                end
                %%% Convert Fraction from Amplitude (species) fraction to Intensity fraction
                %%% (i.e. correct for brightness)
                %%% Intensity is proportional to tau*amplitude
                amp1 = FitResult{5}*FitResult{1}; amp2 = FitResult{6}*FitResult{2}; amp3 = FitResult{7}*FitResult{3}; amp4 = (1-FitResult{5}-FitResult{6}-FitResult{7})*FitResult{4};
                f1 = amp1./(amp1+amp2+amp3+amp4);
                f2 = amp2./(amp1+amp2+amp3+amp4);
                f3 = amp3./(amp1+amp2+amp3+amp4);
                f4 = amp4./(amp1+amp2+amp3+amp4);
                
                meanTau = FitResult{1}*f1+FitResult{2}*f2+FitResult{3}*f3+FitResult{4}*f4;
                meanTau_Fraction = FitResult{1}*FitResult{5} + FitResult{2}*FitResult{6} + FitResult{3}*FitResult{7} + (1-FitResult{5}-FitResult{6}-FitResult{7})*FitResult{7};
                % FitResult{4} = amp1;
                % FitResult{5} = amp2;
                h.Output_Text.String = {sprintf('I0: %.2f',FitResult{end}),...
                    sprintf('Mean Lifetime Fraction: %.2f ns',meanTau_Fraction),...
                    sprintf('Mean Lifetime Int: %.2f ns',meanTau), ...
                    ['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'], ...
                    ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.'],...
                    ['Intensity fraction of Tau3: ' sprintf('%2.2f',100*f3) ' %.'],...
                    ['Intensity fraction of Tau4: ' sprintf('%2.2f',100*f4) ' %.']};
                
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                TauFitData.I0 = FitResult{end};
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(1) = fix(1);
                    UserValues.TauFit.FitFix{chan}(2) = fix(2);
                    UserValues.TauFit.FitFix{chan}(3) = fix(3);
                    UserValues.TauFit.FitFix{chan}(4) = fix(4);
                    UserValues.TauFit.FitFix{chan}(5) = fix(5);
                    UserValues.TauFit.FitFix{chan}(6) = fix(6);
                    UserValues.TauFit.FitFix{chan}(7) = fix(7);
                    UserValues.TauFit.FitFix{chan}(8) = fix(8);
                    UserValues.TauFit.FitFix{chan}(10) = fix(9);
                    UserValues.TauFit.FitFix{chan}(12) = fix(10);
                    
                end
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(2) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(3) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(4) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(5) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(7) = FitResult{7};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{8};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{9};
                UserValues.TauFit.IRFShift{chan} = FitResult{10};
            case 'Stretched Exponential'
                %%% Parameter:
                %%% tau    - Lifetime
                %%% beta    - distribution parameter
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                lifetimes = [1];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                %%% define model function
                ModelFun = @(x,xdata) fitfun_stretched_exp(interlace(x0,x,fixed),xdata);
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est_fit = sigma_est(ignore:end);
                else
                    sigma_est_fit = ones(1,numel(Decay(ignore:end)));
                end
                
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),0,ignore,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_stretched_exp(interlace(x0,x,fixed),xdata)./sigma_est_fit,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est_fit,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_stretched_exp(interlace(x0,x,fixed),xdata),Decay(ignore:end)),...
                            x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 = sum(residuals.^2)/(numel(Decay(ignore:end))-sum(~fixed));
                    
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                FitFun = fitfun_stretched_exp(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),0,1,Conv_Type});
                if ~poissonian_chi2
                    wres = (Decay-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sigma_est;
                    end
                else
                    wres = MLE_w_res(FitFun,Decay).*sign(Decay-FitFun);
                end
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(ignore:end);
                wres_ignore = wres(1:ignore);
                wres = wres(ignore:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(ignore:end);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                %%% Convert Lifetimes to Nanoseconds
                for i = 1:numel(lifetimes)
                    FitResult{lifetimes(i)} = FitResult{lifetimes(i)}.*TauFitData.TACChannelWidth;
                end
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                TauFitData.I0 = FitResult{end};
                
                % species-weighted meanTau = tau/beta*gammafunction(1/beta)
                meanTau_Fraction = (FitResult{1}/FitResult{2})*gamma(1/FitResult{2});
                % intensity-weighted meanTau =  tau*gamma(2/beta)/gamma(1/beta)
                meanTau = FitResult{1}*gamma(2/FitResult{2})/gamma(1/FitResult{2});
                h.Output_Text.String = {sprintf('I0: %.2f',FitResult{end}),...
                    sprintf('Mean Lifetime Fraction: %.2f ns',meanTau_Fraction),sprintf('Mean Lifetime Int: %.2f ns',meanTau)};
                
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(1) = fix(1);
                    UserValues.TauFit.FitFix{chan}(25) = fix(2);
                    UserValues.TauFit.FitFix{chan}(8) = fix(3);
                    UserValues.TauFit.FitFix{chan}(10) = fix(4);
                    UserValues.TauFit.FitFix{chan}(12) = fix(5);
                end
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(25) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{4};
                UserValues.TauFit.IRFShift{chan} = FitResult{5};
            case 'Distribution'
                %%% Parameter:
                %%% Center R
                %%% sigmaR
                %%% Scatter
                %%% Background
                %%% R0
                %%% Donor only lifetime
                %%% Convert Lifetimes
                lifetimes = [6];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                %%% define model function
                ModelFun = @(x,xdata) fitfun_dist(interlace(x0,x,fixed),xdata);
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est_fit = sigma_est(ignore:end);
                else
                    sigma_est_fit = ones(1,numel(Decay(ignore:end)));
                end
                
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),0,ignore,Conv_Type};
                    
                    if h.Restrict_Gauss_Width_Checkbox.Value
                        %%% restrict width to match provided FRET-averaged distance
                        % read out the FRET-averaged distance
                        R_E_exp = str2double(h.Restrict_Gauss_Width_Edit.String);
                        if ~isfinite(R_E_exp)
                            disp('Please check the provided FRET averaged distance. Aborting...');
                            return;
                        end
                        % define weighted least squares
                        wls = @(x) sum(((fitfun_dist(interlace(x0,x,fixed),xdata)-Decay(ignore:end))./sigma_est_fit).^2);                               
                        [x,fval,~,~,~,~,hessian] = fmincon(wls,x0(~fixed),[],[],[],[],lb(~fixed),ub(~fixed),@(x) nonlcon_gausswidth(interlace(x0,x,fixed),R_E_exp));
                        
                        % code for support plane analsis of sigma
                        % simply set a break point here to run SPA
                        do_SPA = false;
                        if do_SPA
                            % fix sigma
                            fixed(2) = true;
                            %define range
                            s = x(2)*linspace(0.9,1.1,10);
                            x(2) = [];
                            % run optimization
                            fval = zeros(size(s));
                            for i = 1:numel(s)
                                x0(2) = s(i);
                                wls = @(x) sum(((fitfun_dist(interlace(x0,x,fixed),xdata)-Decay(ignore:end))./sigma_est_fit).^2);  
                                [x,fval(i)] = fmincon(wls,x0(~fixed),[],[],[],[],lb(~fixed),ub(~fixed),@(x) nonlcon_gausswidth(interlace(x0,x,fixed),R_E_exp));                   
                            end
                            fval = fval./(numel(Decay(ignore:end))-sum(~fixed));
                            figure;plot(s,fval);
                        end
                        x = interlace(x0,x,fixed)';
                        chi2 = fval/(numel(Decay(ignore:end))-sum(~fixed));
                        err = sqrt(diag(inv(hessian)));
                        TauFitData.ConfInt(~fixed,:) = x(~fixed) + [-err, err];
                    else
                        if ~poissonian_chi2
                            [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_dist(interlace(x0,x,fixed),xdata)./sigma_est_fit,...
                                x0(~fixed),xdata,Decay(ignore:end)./sigma_est_fit,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                        else
                            [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_dist(interlace(x0,x,fixed),xdata),Decay(ignore:end)),...
                                x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                        end
                        x = interlace(x0,x,fixed);
                        chi2 = sum(residuals.^2)/(numel(Decay(ignore:end))-sum(~fixed));
                        TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                    end
                else % plot only
                    x = {x0};
                end
                
                FitFun = fitfun_dist(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),0,1,Conv_Type});
                if ~poissonian_chi2
                    wres = (Decay-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sigma_est;
                    end
                else
                    wres = MLE_w_res(FitFun,Decay).*sign(Decay-FitFun);
                end
                
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(1:end);
                wres_ignore = wres(1:ignore);
                wres = wres(1:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(1:end);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                %%% Convert Lifetimes to Nanoseconds
                for i = 1:numel(lifetimes)
                    FitResult{lifetimes(i)} = FitResult{lifetimes(i)}.*TauFitData.TACChannelWidth;
                end
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                TauFitData.I0 = FitResult{end};
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(21) = fix(1);
                    UserValues.TauFit.FitFix{chan}(22) = fix(2);
                    UserValues.TauFit.FitFix{chan}(8) = fix(3);
                    UserValues.TauFit.FitFix{chan}(10) = fix(4);
                    UserValues.TauFit.FitFix{chan}(13) = fix(5);
                    UserValues.TauFit.FitFix{chan}(14) = fix(6);
                    UserValues.TauFit.FitFix{chan}(12) = fix(7);
                end
                UserValues.TauFit.FitParams{chan}(21) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(22) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(13) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(14) = FitResult{6};
                UserValues.TauFit.IRFShift{chan} = FitResult{7};
                
                [R_mE, mE] = calc_RDA_E(x(1),x(2),x(5));
                tauF = calc_tauf(x(1),x(2),x(5),FitResult{6});
                % Also update status text
                h.Output_Text.String = {sprintf('I0: %.2f',FitResult{end});...
                    sprintf('<E> = %.4f',mE);...
                    sprintf('R(<E>) = %.2f A',R_mE);...
                    sprintf('<tauD(A)>F = %.2f ns',tauF)};
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
                lifetimes = [7];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                %%% define model function
                ModelFun = @(x,xdata) fitfun_dist_donly(interlace(x0,x,fixed),xdata);
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est_fit = sigma_est(ignore:end);
                else
                    sigma_est_fit = ones(1,numel(Decay(ignore:end)));
                end
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),0,ignore,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_dist_donly(interlace(x0,x,fixed),xdata)./sigma_est_fit,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est_fit,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_dist_donly(interlace(x0,x,fixed),xdata),Decay(ignore:end)),...
                            x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 = sum(residuals.^2)/(numel(Decay(ignore:end))-sum(~fixed));
                    
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                FitFun = fitfun_dist_donly(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),0,1,Conv_Type});
                if ~poissonian_chi2
                    wres = (Decay-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sigma_est;
                    end
                else
                    wres = MLE_w_res(FitFun,Decay).*sign(Decay-FitFun);
                end
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(1:end);
                wres_ignore = wres(1:ignore);
                wres = wres(1:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(1:end);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                %%% Convert Lifetimes to Nanoseconds
                for i = 1:numel(lifetimes)
                    FitResult{lifetimes(i)} = FitResult{lifetimes(i)}.*TauFitData.TACChannelWidth;
                end
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                TauFitData.I0 = FitResult{end};
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(21) = fix(1);
                    UserValues.TauFit.FitFix{chan}(22) = fix(2);
                    UserValues.TauFit.FitFix{chan}(23) = fix(3);
                    UserValues.TauFit.FitFix{chan}(8) = fix(4);
                    UserValues.TauFit.FitFix{chan}(10) = fix(5);
                    UserValues.TauFit.FitFix{chan}(13) = fix(6);
                    UserValues.TauFit.FitFix{chan}(14) = fix(7);
                    UserValues.TauFit.FitFix{chan}(12) = fix(8);
                end
                UserValues.TauFit.FitParams{chan}(21) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(22) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(23) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(13) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(14) = FitResult{7};
                UserValues.TauFit.IRFShift{chan} = FitResult{8};
                
                [R_mE, mE] = calc_RDA_E(x(1),x(2),x(6));
                tauF = calc_tauf(x(1),x(2),x(6),FitResult{7});
                % Also update status text
                h.Output_Text.String = {sprintf('I0: %.2f',FitResult{end});...
                    sprintf('<E> = %.4f',mE);...
                    sprintf('R(<E>) = %.2f A',R_mE);...
                    sprintf('<tauD(A)>F = %.2f ns',tauF)};
            case 'Two Distributions plus Donor only'
                %%% Parameter:
                %%% Center R1
                %%% sigmaR1
                %%% Center R2
                %%% sigmaR2
                %%% Fraction 1
                %%% Fraction D only
                %%% Scatter
                %%% Background
                %%% R0
                %%% Donor lifetime used for R0 determination
                %%% Donor only lifetime 1
                %%% Donor only lifetime 2
                %%% Fraction of Donor only lifetime 1
                
                %%% define model function
                ModelFun = @(x,xdata) fitfun_2dist_donly(interlace(x0,x,fixed),xdata);
                
                %%% Convert Lifetimes
                lifetimes = [10,11,12];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est_fit = sigma_est(ignore:end);
                else
                    sigma_est_fit = ones(1,numel(Decay(ignore:end)));
                end
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),0,ignore,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_2dist_donly(interlace(x0,x,fixed),xdata)./sigma_est_fit,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est_fit,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_2dist_donly(interlace(x0,x,fixed),xdata),Decay(ignore:end)),...
                            x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 = sum(residuals.^2)/(numel(Decay(ignore:end))-sum(~fixed));
                    
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                FitFun = fitfun_2dist_donly(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),0,1,Conv_Type});
                if ~poissonian_chi2
                    wres = (Decay-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sigma_est;
                    end
                else
                    wres = MLE_w_res(FitFun,Decay).*sign(Decay-FitFun);
                end
                %%% split by ignore region
                FitFun_ignore = FitFun(1:ignore);
                FitFun = FitFun(1:end);
                wres_ignore = wres(1:ignore);
                wres = wres(1:end);
                Decay_ignore = Decay(1:ignore);
                Decay = Decay(1:end);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                %%% Convert Lifetimes to Nanoseconds
                for i = 1:numel(lifetimes)
                    FitResult{lifetimes(i)} = FitResult{lifetimes(i)}.*TauFitData.TACChannelWidth;
                end
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                TauFitData.I0 = FitResult{end};
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(21) = fix(1);
                    UserValues.TauFit.FitFix{chan}(22) = fix(2);
                    UserValues.TauFit.FitFix{chan}(26) = fix(3);
                    UserValues.TauFit.FitFix{chan}(27) = fix(4);
                    UserValues.TauFit.FitFix{chan}(5) = fix(5);
                    UserValues.TauFit.FitFix{chan}(23) = fix(6);
                    UserValues.TauFit.FitFix{chan}(8) = fix(7);
                    UserValues.TauFit.FitFix{chan}(10) = fix(8);
                    UserValues.TauFit.FitFix{chan}(13) = fix(9);
                    UserValues.TauFit.FitFix{chan}(28) = fix(10); % TauD(R0)
                    UserValues.TauFit.FitFix{chan}(14) = fix(11);
                    UserValues.TauFit.FitFix{chan}(2) = fix(12);  % TauD02   -> Tau2
                    UserValues.TauFit.FitFix{chan}(6) = fix(13);  % F_TauD01 -> F2
                    UserValues.TauFit.FitFix{chan}(12) = fix(14);
                end
                UserValues.TauFit.FitParams{chan}(21) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(22) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(26) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(27) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(5) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(23) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{7};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{8};
                UserValues.TauFit.FitParams{chan}(13) = FitResult{9};
                UserValues.TauFit.FitParams{chan}(28) = FitResult{10};
                UserValues.TauFit.FitParams{chan}(14) = FitResult{11};
                UserValues.TauFit.FitParams{chan}(2) = FitResult{12};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{13};
                UserValues.TauFit.IRFShift{chan} = FitResult{14};
                
                h.PlotDynamicFRETLine.Visible = 'on';
                h.PlotDynamicFRETLine_Sigma.Visible = 'on';
                
                [R_mE1, mE1] = calc_RDA_E(x(1),x(2),FitResult{9});
                [R_mE2, mE2] = calc_RDA_E(x(3),x(4),FitResult{9});
                tauF1 = calc_tauf(x(1),x(2),FitResult{9},[FitResult{11},FitResult{12},x(13),FitResult{10}]);
                tauF2 = calc_tauf(x(3),x(4),FitResult{9},[FitResult{11},FitResult{12},x(13),FitResult{10}]);
                % Also update status text
                h.Output_Text.String = {sprintf('I0: %.2f',FitResult{end});...
                    sprintf('<E> = %.4f\t/\t%.4f',mE1,mE2);...
                    sprintf('R(<E>) = %.2f\t/\t%.2f A',R_mE1,R_mE2);...
                    sprintf('<tauD(A)>F = %.2f\t/\t%.2f ns',tauF1,tauF2)};
            case 'Distribution Fit - Global Model' %%% currently only enabled for burstwise data
                switch TauFitData.Who
                    case {'BurstBrowser','Burstwise'}
                        switch TauFitData.BAMethod
                            case {3,4,5}
                                disp('Not implemented for this data type yet.');
                                return;
                        end
                        switch h.DonorOnlyReference_Popupmenu.Value
                            %%% origin of donor-only reference
                            case 1 %%% from donor-only population of burst data
                                %%% read out the donor-only pattern, which should be chan == 4
                                donly_par = TauFitData.hMI_Par{4};
                                donly_per = TauFitData.hMI_Per{4};
                            case 2 %%% use stored reference from BurstData
                                donor_chan = [1,2];
                                donly_par = TauFitData.DonorOnlyReference{donor_chan(1)}';
                                donly_per = TauFitData.DonorOnlyReference{donor_chan(2)}';
                                if isempty(donly_par) || isempty(donly_per)
                                    disp('No donor-only reference found.');
                                    return;
                                end
                        end
                        %%% since we can't just read the plots, we have to shift the data here
                        %%% using the shift applied to the DA sample
                        donly_par = donly_par((TauFitData.StartPar{1}+1):TauFitData.Length{1})';
                        tmp = shift_by_fraction(donly_per, TauFitData.ShiftPer{1});
                        donly_per = tmp((TauFitData.StartPar{1}+1):TauFitData.Length{1})';
                        %%% combine to summed decay
                        Decay_donly = G*(1-3*l2)*donly_par+(2-3*l1)*donly_per;
                        sigma_est_donly = get_error_combined_decay(donly_par,donly_per,G,l1,l2);
                    case {'TauFit','External'}                           
                        PIE_1 = h.PIEChannelPar_Popupmenu.Value;
                        PIE_2 = h.PIEChannelPer_Popupmenu.Value;
                        switch TauFitData.Who
                            case 'External'
                                %%% check if donly is defined and read out
                                if ~isempty(TauFitData.External.Donly{PIE_1})
                                    donly_par = TauFitData.External.Donly{PIE_1}';
                                    donly_per = TauFitData.External.Donly{PIE_2}';                                   
                                else
                                    disp('No Donor only sample loaded.');
                                    return;
                                end
                            case 'TauFit'
                                %%% read donor only from UserValues
                                donly_par = UserValues.PIE.DonorOnlyReference{PIE_1}';
                                donly_per = UserValues.PIE.DonorOnlyReference{PIE_2}';
                                if isempty(donly_par) || isempty(donly_per)
                                    disp('No donor only reference defined.');
                                    return;
                                end
                        end
                        %%% since we can't just read the plots, we have to shift the data here
                        %%% using the shift applied to the DA sample
                        donly_par = donly_par((TauFitData.StartPar{chan}+1):TauFitData.Length{chan})';
                        tmp = shift_by_fraction(donly_per, TauFitData.ShiftPer{chan});
                        donly_per = tmp((TauFitData.StartPar{chan}+1):TauFitData.Length{chan})';

                        if PIE_1 == PIE_2
                            Decay_donly = donly_par;
                            sigma_est_donly = sqrt(Decay_donly); sigma_est_donly(sigma_est_donly==0) = 1;
                        else
                            %%% combine to summed decay
                            Decay_donly = G*(1-3*l2)*donly_par+(2-3*l1)*donly_per;
                            sigma_est_donly = get_error_combined_decay(donly_par,donly_per,G,l1,l2);
                        end
                end
                if size(Decay_donly,1) > size(Decay_donly,2)
                    Decay_donly = Decay_donly';
                    sigma_est_donly = sigma_est_donly';                    
                end
                
                I0_donly = 2*max(Decay_donly);
                x0(end+1) = I0_donly;
                lb(end+1) = 0;
                ub(end+1) = Inf;
                fixed(end+1) = false;
                %%% Parameter:
                %%% Center R1
                %%% sigmaR1
                %%% Center R2
                %%% sigmaR2
                %%% Fraction 1
                %%% Fraction D only
                %%% Scatter
                %%% Background
                %%% R0
                %%% Donor lifetime used for R0 determination
                %%% Donor only lifetime1
                %%% Donor only lifetime2
                %%% Fraction Donor only lifetime1
                %%% Scatter Donly
                %%% Background Donly
                %%% IRF shift
                %%% I0(DA)
                %%% I0(DOnly)
                
                
                %%% Convert Lifetimes
                lifetimes = [10,11,12];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                
                %%% define model function
                ModelFun = @(x,xdata) fitfun_2dist_donly_global(interlace(x0,x,fixed),xdata);
                
                %%% Prepare data as vector
                Decay_DA = Decay;                
                Decay =  [Decay_DA(ignore:end); Decay_donly(ignore:end)];
                Decay_stacked = [Decay_DA(ignore:end) Decay_donly(ignore:end)];
                Decay_FitRange = Decay_stacked;
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est_fit = [sigma_est(ignore:end) sigma_est_donly(ignore:end)];
                else
                    sigma_est_fit = ones(1,numel(Decay_stacked));
                end
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,ignore,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_2dist_donly_global(interlace(x0,x,fixed),xdata)./sigma_est_fit,...
                            x0(~fixed),xdata,Decay_stacked./sigma_est_fit,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_2dist_donly_global(interlace(x0,x,fixed),xdata),Decay_stacked),...
                            x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 = sum(residuals.^2)/(numel(Decay(:,ignore:end))-sum(~fixed));
                    %%% calculate separate chi2 for DA and DO decays
                    chi2_DA = sum(residuals(1:(numel(residuals)/2)).^2)/(numel(Decay(1,ignore:end))-sum(~fixed));
                    chi2_D0 = sum(residuals((numel(residuals)/2+1):end).^2)/(numel(Decay(1,ignore:end))-sum(~fixed));
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                %%% remove ignore range from decay
                Decay = [Decay_DA; Decay_donly];
                Decay_stacked = [Decay_DA Decay_donly];
                FitFun = fitfun_2dist_donly_global(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,1,G,Conv_Type});
                Decay = Decay_stacked;
                if ~poissonian_chi2
                    wres = (Decay_stacked-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./[sigma_est sigma_est_donly];
                    end
                else
                    wres = MLE_w_res(FitFun,Decay_stacked).*sign(Decay_stacked-FitFun);
                end
                %%% ignore plotting is not implemented here yet!
                FitFun_ignore = FitFun;
                wres_ignore = wres;
                Decay_ignore = Decay;
                Length = numel(Decay);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                %%% Convert Lifetimes to Nanoseconds
                for i = 1:numel(lifetimes)
                    FitResult{lifetimes(i)} = FitResult{lifetimes(i)}.*TauFitData.TACChannelWidth;
                end
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult(1:end-2);
                TauFitData.I0 = FitResult{end-1};
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(21) = fix(1);
                    UserValues.TauFit.FitFix{chan}(22) = fix(2);
                    UserValues.TauFit.FitFix{chan}(26) = fix(3);
                    UserValues.TauFit.FitFix{chan}(27) = fix(4);
                    UserValues.TauFit.FitFix{chan}(5) = fix(5);
                    UserValues.TauFit.FitFix{chan}(23) = fix(6);
                    UserValues.TauFit.FitFix{chan}(8) = fix(7);
                    UserValues.TauFit.FitFix{chan}(10) = fix(8);
                    UserValues.TauFit.FitFix{chan}(13) = fix(9);
                    UserValues.TauFit.FitFix{chan}(28) = fix(10); % TauD(R0)
                    UserValues.TauFit.FitFix{chan}(14) = fix(11);
                    UserValues.TauFit.FitFix{chan}(2) = fix(12); %TauD02->Tau2
                    UserValues.TauFit.FitFix{chan}(6) = fix(13); %F_TauD01->F2
                    UserValues.TauFit.FitFix{chan}(9) = fix(14); %Sc_Donly->Sc_Per
                    UserValues.TauFit.FitFix{chan}(11) = fix(15); %BG_Donly->Bg_Per
                    UserValues.TauFit.FitFix{chan}(12) = fix(16);
                end
                UserValues.TauFit.FitParams{chan}(21) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(22) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(26) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(27) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(5) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(23) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{7};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{8};
                UserValues.TauFit.FitParams{chan}(13) = FitResult{9};
                UserValues.TauFit.FitParams{chan}(28) = FitResult{10};
                UserValues.TauFit.FitParams{chan}(14) = FitResult{11};
                UserValues.TauFit.FitParams{chan}(2) = FitResult{12};
                UserValues.TauFit.FitParams{chan}(6) = FitResult{13};
                UserValues.TauFit.FitParams{chan}(9) = FitResult{14};
                UserValues.TauFit.FitParams{chan}(11) = FitResult{15};
                UserValues.TauFit.IRFShift{chan} = FitResult{16};
                
                h.PlotDynamicFRETLine.Visible = 'on';
                h.PlotDynamicFRETLine_Sigma.Visible = 'on';
                
                [R_mE1, mE1] = calc_RDA_E(x(1),x(2),FitResult{9});
                [R_mE2, mE2] = calc_RDA_E(x(3),x(4),FitResult{9});
                tauF1 = calc_tauf(x(1),x(2),FitResult{9},[FitResult{11},FitResult{12},x(13),FitResult{10}]);
                tauF2 = calc_tauf(x(3),x(4),FitResult{9},[FitResult{11},FitResult{12},x(13),FitResult{10}]);
                % Also update status text
                h.Output_Text.String = {sprintf('I0: %.2f',FitResult{end});...
                    sprintf('<E> = %.4f\t/\t%.4f',mE1,mE2);...
                    sprintf('R(<E>) = %.2f\t/\t%.2f A',R_mE1,R_mE2);...
                    sprintf('<tauD(A)>F = %.2f\t/\t%.2f ns',tauF1,tauF2)};
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
                    if TauFitData.IRFBackground{chan} == 0 % do standard background correction
                        %%% additional processing of the IRF to remove constant background
                        IRFPattern{i} = IRFPattern{i} - mean(IRFPattern{i}(end-round(numel(IRFPattern{i})/10):end));
                    else % do baseline correction
                        IRFPattern{i} = IRFPattern{i} - max(IRFPattern{i}).*TauFitData.IRFBackground{chan};
                    end
                    IRFPattern{i}(IRFPattern{i}<0) = 0;
                    IRFPattern{i} = IRFPattern{i}./sum(IRFPattern{i});
                end
                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = h.Plots.Scat_Par.YData';%TauFitData.hScat_Par{chan}(1:TauFitData.Length{chan})';
                ScatterPattern{2} = h.Plots.Scat_Per.YData'; %ScatterPer(1:TauFitData.Length{chan})';
                if ~(sum(ScatterPattern{1}) == 0)
                    ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                end
                if ~(sum(ScatterPattern{2}) == 0)
                    ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});
                end
                %%% Convert Lifetimes
                lifetimes = [1:2];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                
                %%% Prepare data as vector
                Decay =  [TauFitData.FitData.Decay_Par(ignore:end); TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_stacked = [TauFitData.FitData.Decay_Par(ignore:end) TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_FitRange = Decay_stacked;
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay_stacked);sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay_stacked));
                end
                
                %%% update I0
                I0 = max(Decay_stacked);
                x0(end) = I0;
                
                %%% define model function
                ModelFun = @(x,xdata) fitfun_aniso(interlace(x0,x,fixed),xdata);
                
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,ignore,G,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_aniso(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay_stacked./sigma_est,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_aniso(interlace(x0,x,fixed),xdata),Decay_stacked),...
                            x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 = sum(residuals.^2)/(numel(Decay_stacked)-sum(~fixed));
                    
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                %%% remove ignore range from decay
                Decay = [TauFitData.FitData.Decay_Par; TauFitData.FitData.Decay_Per];
                Decay_stacked = [TauFitData.FitData.Decay_Par TauFitData.FitData.Decay_Per];
                FitFun = fitfun_aniso(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,1,G,Conv_Type});
                Decay = Decay_stacked;
                if ~poissonian_chi2
                    wres = (Decay_stacked-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sqrt(Decay_stacked);
                    end
                else
                    wres = MLE_w_res(FitFun,Decay_stacked).*sign(Decay_stacked-FitFun);
                end
                %%% ignore plotting is not implemented here yet!
                FitFun_ignore = FitFun;
                wres_ignore = wres;
                Decay_ignore = Decay;
                Length = numel(Decay);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                disp(sprintf('I0 = %.2i\n',x(end)));
                %%% Convert Lifetimes to Nanoseconds
                for i = 1:numel(lifetimes)
                    FitResult{lifetimes(i)} = FitResult{lifetimes(i)}.*TauFitData.TACChannelWidth;
                end
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(1) = fix(1);
                    UserValues.TauFit.FitFix{chan}(17) = fix(2);
                    UserValues.TauFit.FitFix{chan}(19) = fix(3);
                    UserValues.TauFit.FitFix{chan}(20) = fix(4);
                    UserValues.TauFit.FitFix{chan}(8) = fix(5);
                    UserValues.TauFit.FitFix{chan}(9) = fix(6);
                    UserValues.TauFit.FitFix{chan}(10) = fix(7);
                    UserValues.TauFit.FitFix{chan}(11) = fix(8);
                    UserValues.TauFit.FitFix{chan}(15) = fix(9);
                    UserValues.TauFit.FitFix{chan}(16) = fix(10);
                    UserValues.TauFit.FitFix{chan}(12) = fix(11);
                end
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(17) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(19) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(20) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(9) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{7};
                UserValues.TauFit.FitParams{chan}(11) = FitResult{8};
                UserValues.TauFit.FitParams{chan}(15) = FitResult{9};
                UserValues.TauFit.FitParams{chan}(16) = FitResult{10};
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
                    if TauFitData.IRFBackground{chan} == 0 % do standard background correction
                        %%% additional processing of the IRF to remove constant background
                        IRFPattern{i} = IRFPattern{i} - mean(IRFPattern{i}(end-round(numel(IRFPattern{i})/10):end));
                    else % do baseline correction
                        IRFPattern{i} = IRFPattern{i} - max(IRFPattern{i}).*TauFitData.IRFBackground{chan};
                    end
                    IRFPattern{i}(IRFPattern{i}<0) = 0;
                    IRFPattern{i} = IRFPattern{i}./sum(IRFPattern{i});
                end
                
                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = h.Plots.Scat_Par.YData';%TauFitData.hScat_Par{chan}(1:TauFitData.Length{chan})';
                ScatterPattern{2} = h.Plots.Scat_Per.YData'; %ScatterPer(1:TauFitData.Length{chan})';
                if ~(sum(ScatterPattern{1}) == 0)
                    ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                end
                if ~(sum(ScatterPattern{2}) == 0)
                    ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});
                end
                
                %%% Convert Lifetimes
                lifetimes = [1,2,4];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                %%% Prepare data as vector
                Decay =  [TauFitData.FitData.Decay_Par(ignore:end); TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_stacked = [TauFitData.FitData.Decay_Par(ignore:end) TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_FitRange = Decay_stacked;
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay_stacked);sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay_stacked));
                end
                
                %%% update I0
                I0 = max(Decay_stacked);
                x0(end) = I0;
                
                %%% define model function
                ModelFun = @(x,xdata) fitfun_2lt_aniso(interlace(x0,x,fixed),xdata);
                
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,ignore,G,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_2lt_aniso(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay_stacked./sigma_est,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_2lt_aniso(interlace(x0,x,fixed),xdata),Decay_stacked),...
                            x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 = sum(residuals.^2)/(numel(Decay_stacked)-sum(~fixed));
                    
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                %%% remove ignore range from decay
                Decay = [TauFitData.FitData.Decay_Par; TauFitData.FitData.Decay_Per];
                Decay_stacked = [TauFitData.FitData.Decay_Par TauFitData.FitData.Decay_Per];
                FitFun = fitfun_2lt_aniso(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,1,G,Conv_Type});
                Decay = Decay_stacked;
                if ~poissonian_chi2
                    wres = (Decay_stacked-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sqrt(Decay_stacked);
                    end
                else
                    wres = MLE_w_res(FitFun,Decay_stacked).*sign(Decay_stacked-FitFun);
                end
                %%% ignore plotting is not implemented here yet!
                FitFun_ignore = FitFun;
                wres_ignore = wres;
                Decay_ignore = Decay;
                Length = numel(Decay);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                disp(sprintf('I0 = %.2i\n',x(end)));
                %%% Convert Lifetimes to Nanoseconds
                for i = 1:numel(lifetimes)
                    FitResult{lifetimes(i)} = FitResult{lifetimes(i)}.*TauFitData.TACChannelWidth;
                end
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                %%% Convert Fraction from Amplitude (species) fraction to Intensity fraction
                %%% (i.e. correct for brightness)
                %%% Intensity is proportional to tau*amplitude
                amp1 = FitResult{3}*FitResult{1}; amp2 = (1-FitResult{3})*FitResult{2};
                f1 = amp1./(amp1+amp2);
                f2 = amp2./(amp1+amp2);
                meanTau = FitResult{1}*f1+FitResult{2}*f2;
                meanTau_Fraction = FitResult{3}*FitResult{1} + (1-FitResult{3})*FitResult{2};
                % Also update status text
                h.Output_Text.String = {sprintf('Mean Lifetime Fraction: %.2f ns',meanTau_Fraction),...
                    sprintf('Mean Lifetime Int: %.2f ns',meanTau),...
                    ['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'],...
                    ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.']};
                
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(1) = fix(1);
                    UserValues.TauFit.FitFix{chan}(2) = fix(2);
                    UserValues.TauFit.FitFix{chan}(5) = fix(3);
                    UserValues.TauFit.FitFix{chan}(17) = fix(4);
                    UserValues.TauFit.FitFix{chan}(19) = fix(5);
                    UserValues.TauFit.FitFix{chan}(20) = fix(6);
                    UserValues.TauFit.FitFix{chan}(8) = fix(7);
                    UserValues.TauFit.FitFix{chan}(9) = fix(8);
                    UserValues.TauFit.FitFix{chan}(10) = fix(9);
                    UserValues.TauFit.FitFix{chan}(11) = fix(10);
                    UserValues.TauFit.FitFix{chan}(15) = fix(11);
                    UserValues.TauFit.FitFix{chan}(16) = fix(12);
                    UserValues.TauFit.FitFix{chan}(12) = fix(13);
                end
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(2) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(5) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(17) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(19) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(20) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{7};
                UserValues.TauFit.FitParams{chan}(9) = FitResult{8};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{9};
                UserValues.TauFit.FitParams{chan}(11) = FitResult{10};
                UserValues.TauFit.FitParams{chan}(15) = FitResult{11};
                UserValues.TauFit.FitParams{chan}(16) = FitResult{12};
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
                    if TauFitData.IRFBackground{chan} == 0 % do standard background correction
                        %%% additional processing of the IRF to remove constant background
                        IRFPattern{i} = IRFPattern{i} - mean(IRFPattern{i}(end-round(numel(IRFPattern{i})/10):end));
                    else % do baseline correction
                        IRFPattern{i} = IRFPattern{i} - max(IRFPattern{i}).*TauFitData.IRFBackground{chan};
                    end
                    IRFPattern{i}(IRFPattern{i}<0) = 0;
                    IRFPattern{i} = IRFPattern{i}./sum(IRFPattern{i});
                end
                
                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = h.Plots.Scat_Par.YData';%TauFitData.hScat_Par{chan}(1:TauFitData.Length{chan})';
                ScatterPattern{2} = h.Plots.Scat_Per.YData'; %ScatterPer(1:TauFitData.Length{chan})';
                if ~(sum(ScatterPattern{1}) == 0)
                    ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                end
                if ~(sum(ScatterPattern{2}) == 0)
                    ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});
                end
                
                %%% Convert Lifetimes
                lifetimes = [1:3];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                
                %%% Prepare data as vector
                Decay =  [TauFitData.FitData.Decay_Par(ignore:end); TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_stacked = [TauFitData.FitData.Decay_Par(ignore:end) TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_FitRange = Decay_stacked;
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay_stacked);sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay_stacked));
                end
                
                %%% update I0
                I0 = max(Decay_stacked);
                x0(end) = I0;
                
                %%% define model function
                ModelFun = @(x,xdata) fitfun_aniso_2rot(interlace(x0,x,fixed),xdata);
                
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,ignore,G,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_aniso_2rot(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay_stacked./sigma_est,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_aniso_2rot(interlace(x0,x,fixed),xdata),Decay_stacked),...
                            x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    
                    chi2 = sum(residuals.^2)/(numel(Decay_stacked)-sum(~fixed));
                    
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                %%% remove ignore range from decay
                Decay = [TauFitData.FitData.Decay_Par; TauFitData.FitData.Decay_Per];
                Decay_stacked = [TauFitData.FitData.Decay_Par TauFitData.FitData.Decay_Per];
                FitFun = fitfun_aniso_2rot(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,1,G,Conv_Type});
                Decay = Decay_stacked;
                if ~poissonian_chi2
                    wres = (Decay_stacked-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sqrt(Decay_stacked);
                    end
                else
                    wres = MLE_w_res(FitFun,Decay_stacked).*sign(Decay_stacked-FitFun);
                end
                
                %%% ignore plotting is not implemented here yet!
                FitFun_ignore = FitFun;
                wres_ignore = wres;
                Decay_ignore = Decay;
                Length = numel(Decay);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                disp(sprintf('I0 = %.2i\n',x(end)));
                %%% Convert Lifetimes to Nanoseconds
                for i = 1:numel(lifetimes)
                    FitResult{lifetimes(i)} = FitResult{lifetimes(i)}.*TauFitData.TACChannelWidth;
                end
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(1) = fix(1);
                    UserValues.TauFit.FitFix{chan}(17) = fix(2);
                    UserValues.TauFit.FitFix{chan}(18) = fix(3);
                    UserValues.TauFit.FitFix{chan}(19) = fix(4);
                    UserValues.TauFit.FitFix{chan}(20) = fix(5);
                    UserValues.TauFit.FitFix{chan}(8) = fix(6);
                    UserValues.TauFit.FitFix{chan}(9) = fix(7);
                    UserValues.TauFit.FitFix{chan}(10) = fix(8);
                    UserValues.TauFit.FitFix{chan}(11) = fix(9);
                    UserValues.TauFit.FitFix{chan}(15) = fix(10);
                    UserValues.TauFit.FitFix{chan}(16) = fix(11);
                    UserValues.TauFit.FitFix{chan}(12) = fix(12);
                end
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(17) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(18) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(19) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(20) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(9) = FitResult{7};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{8};
                UserValues.TauFit.FitParams{chan}(11) = FitResult{9};
                UserValues.TauFit.FitParams{chan}(15) = FitResult{10};
                UserValues.TauFit.FitParams{chan}(16) = FitResult{11};
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
                    if TauFitData.IRFBackground{chan} == 0 % do standard background correction
                        %%% additional processing of the IRF to remove constant background
                        IRFPattern{i} = IRFPattern{i} - mean(IRFPattern{i}(end-round(numel(IRFPattern{i})/10):end));
                    else % do baseline correction
                        IRFPattern{i} = IRFPattern{i} - max(IRFPattern{i}).*TauFitData.IRFBackground{chan};
                    end
                    IRFPattern{i}(IRFPattern{i}<0) = 0;
                    IRFPattern{i} = IRFPattern{i}./sum(IRFPattern{i});
                end
                
                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = h.Plots.Scat_Par.YData';%TauFitData.hScat_Par{chan}(1:TauFitData.Length{chan})';
                ScatterPattern{2} = h.Plots.Scat_Per.YData'; %ScatterPer(1:TauFitData.Length{chan})';
                if ~(sum(ScatterPattern{1}) == 0)
                    ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                end
                if ~(sum(ScatterPattern{2}) == 0)
                    ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});
                end
                %%% Convert Lifetimes
                lifetimes = [1,2,4,5];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                %%% Prepare data as vector
                Decay =  [TauFitData.FitData.Decay_Par(ignore:end); TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_stacked = [TauFitData.FitData.Decay_Par(ignore:end) TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_FitRange = Decay_stacked;
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay_stacked);sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay_stacked));
                end
                
                %%% update I0
                I0 = max(Decay_stacked);
                x0(end) = I0;
                
                %%% define model function
                ModelFun = @(x,xdata) fitfun_2lt_aniso_2rot(interlace(x0,x,fixed),xdata);
                
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,ignore,G,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_2lt_aniso_2rot(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay_stacked./sigma_est,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_2lt_aniso_2rot(interlace(x0,x,fixed),xdata),Decay_stacked),...
                            x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 = sum(residuals.^2)/(numel(Decay_stacked)-sum(~fixed));
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                %%% remove ignore range from decay
                Decay = [TauFitData.FitData.Decay_Par; TauFitData.FitData.Decay_Per];
                Decay_stacked = [TauFitData.FitData.Decay_Par TauFitData.FitData.Decay_Per];
                FitFun = fitfun_2lt_aniso_2rot(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,1,G,Conv_Type});
                Decay = Decay_stacked;
                if ~poissonian_chi2
                    wres = (Decay_stacked-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sqrt(Decay_stacked);
                    end
                else
                    wres = MLE_w_res(FitFun,Decay_stacked).*sign(Decay_stacked-FitFun);
                end
                
                %%% ignore plotting is not implemented here yet!
                FitFun_ignore = FitFun;
                wres_ignore = wres;
                Decay_ignore = Decay;
                Length = numel(Decay);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                disp(sprintf('I0 = %.2i\n',x(end)));
                %%% Convert Lifetimes to Nanoseconds
                for i = 1:numel(lifetimes)
                    FitResult{lifetimes(i)} = FitResult{lifetimes(i)}.*TauFitData.TACChannelWidth;
                end
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                %%% Convert Fraction from Amplitude (species) fraction to Intensity fraction
                %%% (i.e. correct for brightness)
                %%% Intensity is proportional to tau*amplitude
                amp1 = FitResult{3}*FitResult{1}; amp2 = (1-FitResult{3})*FitResult{2};
                f1 = amp1./(amp1+amp2);
                f2 = amp2./(amp1+amp2);
                meanTau = FitResult{1}*f1+FitResult{2}*f2;
                meanTau_Fraction = FitResult{3}*FitResult{1} + (1-FitResult{3})*FitResult{2};
                % Also update status text
                h.Output_Text.String = {sprintf('Mean Lifetime Fraction: %.2f ns',meanTau_Fraction),...
                    sprintf('Mean Lifetime Int: %.2f ns',meanTau),...
                    ['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'],...
                    ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.']};
                
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(1) = fix(1);
                    UserValues.TauFit.FitFix{chan}(2) = fix(2);
                    UserValues.TauFit.FitFix{chan}(5) = fix(3);
                    UserValues.TauFit.FitFix{chan}(17) = fix(4);
                    UserValues.TauFit.FitFix{chan}(18) = fix(5);
                    UserValues.TauFit.FitFix{chan}(19) = fix(6);
                    UserValues.TauFit.FitFix{chan}(20) = fix(7);
                    UserValues.TauFit.FitFix{chan}(8) = fix(8);
                    UserValues.TauFit.FitFix{chan}(9) = fix(9);
                    UserValues.TauFit.FitFix{chan}(10) = fix(10);
                    UserValues.TauFit.FitFix{chan}(11) = fix(11);
                    UserValues.TauFit.FitFix{chan}(15) = fix(12);
                    UserValues.TauFit.FitFix{chan}(16) = fix(13);
                    UserValues.TauFit.FitFix{chan}(12) = fix(14);
                end
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(2) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(5) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(17) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(18) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(19) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(20) = FitResult{7};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{8};
                UserValues.TauFit.FitParams{chan}(9) = FitResult{9};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{10};
                UserValues.TauFit.FitParams{chan}(11) = FitResult{11};
                UserValues.TauFit.FitParams{chan}(15) = FitResult{12};
                UserValues.TauFit.FitParams{chan}(16) = FitResult{13};
                UserValues.TauFit.IRFShift{chan} = FitResult{14};
                h.l1_edit.String = num2str(FitResult{12});
                h.l2_edit.String = num2str(FitResult{13});
            case 'Fit Anisotropy (2 exp lifetime with independent anisotropy)'
                %%% Parameter
                %%% Lifetime 1 and 2
                %%% Fraction 1
                %%% Rotational Correlation Time 1
                %%% Rotational Correlation Time 2
                %%% r0 - Initial Anisotropy
                %%% r_infinity1 - Residual Anisotropy
                %%% r_infinity2 - Residual Anisotropy
                %%% Background par
                %%% Background per
                
                %%% Define separate IRF Patterns
                IRFPattern = cell(2,1);
                IRFPattern{1} = TauFitData.hIRF_Par{chan}(1:TauFitData.Length{chan})';IRFPattern{1} = IRFPattern{1}./sum(IRFPattern{1});
                IRFPattern{2} = IRFPer(1:TauFitData.Length{chan})';IRFPattern{2} = IRFPattern{2}./sum(IRFPattern{2});
                for i = 1:2
                    if TauFitData.IRFBackground{chan} == 0 % do standard background correction
                        %%% additional processing of the IRF to remove constant background
                        IRFPattern{i} = IRFPattern{i} - mean(IRFPattern{i}(end-round(numel(IRFPattern{i})/10):end));
                    else % do baseline correction
                        IRFPattern{i} = IRFPattern{i} - max(IRFPattern{i}).*TauFitData.IRFBackground{chan};
                    end
                    IRFPattern{i}(IRFPattern{i}<0) = 0;
                    IRFPattern{i} = IRFPattern{i}./sum(IRFPattern{i});
                end
                
                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = h.Plots.Scat_Par.YData';%TauFitData.hScat_Par{chan}(1:TauFitData.Length{chan})';
                ScatterPattern{2} = h.Plots.Scat_Per.YData'; %ScatterPer(1:TauFitData.Length{chan})';
                if ~(sum(ScatterPattern{1}) == 0)
                    ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                end
                if ~(sum(ScatterPattern{2}) == 0)
                    ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});
                end
                %%% Convert Lifetimes
                lifetimes = [1,2,4,5];
                x0(lifetimes) = x0(lifetimes)/TauFitData.TACChannelWidth;
                lb(lifetimes) = lb(lifetimes)/TauFitData.TACChannelWidth;
                ub(lifetimes) = ub(lifetimes)/TauFitData.TACChannelWidth;
                %%% Prepare data as vector
                Decay =  [TauFitData.FitData.Decay_Par(ignore:end); TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_stacked = [TauFitData.FitData.Decay_Par(ignore:end) TauFitData.FitData.Decay_Per(ignore:end)];
                Decay_FitRange = Decay_stacked;
                %%% estimate error assuming Poissonian statistics
                if UserValues.TauFit.use_weighted_residuals
                    sigma_est = sqrt(Decay_stacked);sigma_est(sigma_est == 0) = 1;
                else
                    sigma_est = ones(1,numel(Decay_stacked));
                end
                
                %%% update I0
                I0 = max(Decay_stacked);
                x0(end) = I0;
                
                %%% define model function
                ModelFun = @(x,xdata) fitfun_2lt_2aniso_independent(interlace(x0,x,fixed),xdata);
                
                if fit
                    %%% Update Progressbar
                    Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,ignore,G,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) fitfun_2lt_2aniso_independent(interlace(x0,x,fixed),xdata)./sigma_est,...
                            x0(~fixed),xdata,Decay_stacked./sigma_est,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                        [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(fitfun_2lt_2aniso_independent(interlace(x0,x,fixed),xdata),Decay_stacked),...
                            x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 = sum(residuals.^2)/(numel(Decay_stacked)-sum(~fixed));
                    
                    TauFitData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                %%% remove ignore range from decay
                Decay = [TauFitData.FitData.Decay_Par; TauFitData.FitData.Decay_Per];
                Decay_stacked = [TauFitData.FitData.Decay_Par TauFitData.FitData.Decay_Per];
                FitFun = fitfun_2lt_2aniso_independent(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,1,G,Conv_Type});
                Decay = Decay_stacked;
                if ~poissonian_chi2
                    wres = (Decay_stacked-FitFun);
                    if UserValues.TauFit.use_weighted_residuals
                        wres = wres./sqrt(Decay_stacked);
                    end
                else
                    wres = MLE_w_res(FitFun,Decay_stacked).*sign(Decay_stacked-FitFun);
                end
                
                %%% ignore plotting is not implemented here yet!
                FitFun_ignore = FitFun;
                wres_ignore = wres;
                Decay_ignore = Decay;
                Length = numel(Decay);
                
                %%% Update FitResult
                FitResult = num2cell(x');
                disp(sprintf('I0 = %.2i\n',x(end)));
                %%% Convert Lifetimes to Nanoseconds
                for i = 1:numel(lifetimes)
                    FitResult{lifetimes(i)} = FitResult{lifetimes(i)}.*TauFitData.TACChannelWidth;
                end
                TauFitData.ConfInt(lifetimes,:) = TauFitData.ConfInt(lifetimes,:).*TauFitData.TACChannelWidth;
                %%% Convert Fraction from Amplitude (species) fraction to Intensity fraction
                %%% (i.e. correct for brightness)
                %%% Intensity is proportional to tau*amplitude
                amp1 = FitResult{3}*FitResult{1}; amp2 = (1-FitResult{3})*FitResult{2};
                f1 = amp1./(amp1+amp2);
                f2 = amp2./(amp1+amp2);
                meanTau = FitResult{1}*f1+FitResult{2}*f2;
                meanTau_Fraction = FitResult{3}*FitResult{1} + (1-FitResult{3})*FitResult{2};
                % Also update status text
                h.Output_Text.String = {sprintf('Mean Lifetime Fraction: %.2f ns',meanTau_Fraction),...
                    sprintf('Mean Lifetime Int: %.2f ns',meanTau),...
                    ['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'],...
                    ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.']};
                
                h.FitPar_Table.Data(:,1) = FitResult(1:end-1);
                fix = cell2mat(h.FitPar_Table.Data(1:end,4));
                if save_fix
                    UserValues.TauFit.FitFix{chan}(1) = fix(1);
                    UserValues.TauFit.FitFix{chan}(2) = fix(2);
                    UserValues.TauFit.FitFix{chan}(5) = fix(3);
                    UserValues.TauFit.FitFix{chan}(17) = fix(4);
                    UserValues.TauFit.FitFix{chan}(18) = fix(5);
                    UserValues.TauFit.FitFix{chan}(19) = fix(6);
                    UserValues.TauFit.FitFix{chan}(20) = fix(7);
                    UserValues.TauFit.FitFix{chan}(24) = fix(8);
                    UserValues.TauFit.FitFix{chan}(8) = fix(9);
                    UserValues.TauFit.FitFix{chan}(9) = fix(10);
                    UserValues.TauFit.FitFix{chan}(10) = fix(11);
                    UserValues.TauFit.FitFix{chan}(11) = fix(12);
                    UserValues.TauFit.FitFix{chan}(15) = fix(13);
                    UserValues.TauFit.FitFix{chan}(16) = fix(14);
                    UserValues.TauFit.FitFix{chan}(12) = fix(15);
                end
                UserValues.TauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.TauFit.FitParams{chan}(2) = FitResult{2};
                UserValues.TauFit.FitParams{chan}(5) = FitResult{3};
                UserValues.TauFit.FitParams{chan}(17) = FitResult{4};
                UserValues.TauFit.FitParams{chan}(18) = FitResult{5};
                UserValues.TauFit.FitParams{chan}(19) = FitResult{6};
                UserValues.TauFit.FitParams{chan}(20) = FitResult{7};
                UserValues.TauFit.FitParams{chan}(24) = FitResult{8};
                UserValues.TauFit.FitParams{chan}(8) = FitResult{9};
                UserValues.TauFit.FitParams{chan}(9) = FitResult{10};
                UserValues.TauFit.FitParams{chan}(10) = FitResult{11};
                UserValues.TauFit.FitParams{chan}(11) = FitResult{12};
                UserValues.TauFit.FitParams{chan}(15) = FitResult{13};
                UserValues.TauFit.FitParams{chan}(16) = FitResult{14};
                UserValues.TauFit.IRFShift{chan} = FitResult{15};
                h.l1_edit.String = num2str(FitResult{13});
                h.l2_edit.String = num2str(FitResult{14});
        end
        LSUserValues(1)
        %%% Update IRFShift in Slider and Edit Box
        h.IRFShift_Slider.Value = UserValues.TauFit.IRFShift{chan};
        h.IRFShift_Edit.String = num2str(round(UserValues.TauFit.IRFShift{chan},2));
        TauFitData.IRFShift{chan} = UserValues.TauFit.IRFShift{chan};
        
        %%% Update Plot
        h.Microtime_Plot.Parent = h.HidePanel;
        h.Result_Plot.Parent = h.TauFit_Panel;
        h.Plots.IRFResult.Visible = 'on';
        
        % plot chi^2 on graph
        if ~fit % plot only, chi2 was not calculated yet
            chi2 = sum(wres(~isinf(wres)).^2)./(numel(wres)-sum(~fixed));
        end
        h.Result_Plot_Text.Visible = 'on';
        if UserValues.TauFit.use_weighted_residuals
            h.Result_Plot_Text.String = ['\' sprintf('chi^2_{red.} = %.2f', chi2)];
        else
            h.Result_Plot_Text.String = [sprintf('res^2 = %.2f', chi2)];
        end
        TauFitData.Chi2 = chi2;
        %h.Result_Plot_Text.Position = [0.8*h.Result_Plot.XLim(2) 0.9*h.Result_Plot.YLim(2)];
        h.Result_Plot_Text.Position = [0.8 0.95];
        
        % nanoseconds per microtime bin
        TACtoTime = TauFitData.TACChannelWidth; %1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
        
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
        if contains(TauFitData.FitType,'Anisotropy') || contains(TauFitData.FitType,'Distribution') %any(strcmp(TauFitData.FitType,{'Fit Anisotropy','Fit Anisotropy (2 exp rot)','Fit Anisotropy (2 exp lifetime)','Fit Anisotropy (2 exp lifetime, 2 exp rot)','Fit Anisotropy (2 exp lifetime with independent anisotropy)','Distribution Fit - Global Model'}))
            if contains(TauFitData.FitType,'Anisotropy') || strcmp(TauFitData.FitType,'Distribution Fit - Global Model')
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
                
                
                % store FitResult TauFitData also for use in export
                TauFitData.FitResult = [Fit_par; Fit_per];
            else
                % change colors
                h.Plots.IRFResult.Color = [0.6 0.6 0.6];
                h.Plots.DecayResult.Color = [0 0 0];
                h.Plots.Residuals.Color = [0 0 0];
                h.Plots.Residuals_ignore.Color = [0.6 0.6 0.6];
                % hide plots
                h.Plots.IRFResult_Perp.Visible = 'off';
                h.Plots.FitResult_Perp.Visible = 'off';
                h.Plots.FitResult_Perp_ignore.Visible = 'off';
                h.Plots.DecayResult_Perp.Visible = 'off';
                h.Plots.DecayResult_Perp_ignore.Visible = 'off';
                h.Plots.Residuals_Perp.Visible = 'off';
                h.Plots.Residuals_Perp_ignore.Visible = 'off';
                
                Decay_par = Decay;
                Decay_per = Decay;
                Fit_par = FitFun;
                Fit_per = FitFun;
                wres_par = wres;
                wres_per = wres;
            end
            
            if contains(TauFitData.FitType,'Anisotropy') %~strcmp(TauFitData.FitType,'Distribution Fit - Global Model');
                IRFPat_Par = shift_by_fraction(IRFPattern{1},UserValues.TauFit.IRFShift{chan});
                IRFPat_Par = IRFPat_Par((ShiftParams(1)+1):ShiftParams(4));
                IRFPat_Par = IRFPat_Par./max(IRFPat_Par).*max(Decay_par);
                h.Plots.IRFResult.XData = (1:numel(IRFPat_Par))*TACtoTime;
                h.Plots.IRFResult.YData = IRFPat_Par;
                
                %IRFPat_Perp = circshift(IRFPattern{2},[UserValues.TauFit.IRFShift{chan},0]);
                IRFPat_Perp = shift_by_fraction(IRFPattern{2},UserValues.TauFit.IRFShift{chan});
                IRFPat_Perp = IRFPat_Perp((ShiftParams(1)+1):ShiftParams(4));
                IRFPat_Perp = IRFPat_Perp./max(IRFPat_Perp).*max(Decay_per);
                h.Plots.IRFResult_Perp.XData = (1:numel(IRFPat_Perp))*TACtoTime;
                h.Plots.IRFResult_Perp.YData = IRFPat_Perp;
            elseif strcmp(TauFitData.FitType,'Distribution Fit - Global Model')
                %%% global fit of DO and DA, only one IRF
                %%% normalize decays for better joint display
                max_par = max(Fit_par); max_per = max(Fit_per);
                mean_int = mean([max_par,max_per]);
                Decay_par = max_par*Decay_par./max_par;
                Fit_par = max_par*Fit_par./max_par;
                Decay_per = max_par*Decay_per./max_per;
                Fit_per = max_par*Fit_per./max_per;
                
                IRFPat = shift_by_fraction(IRFPattern,UserValues.TauFit.IRFShift{chan});
                IRFPat = IRFPat((ShiftParams(1)+1):ShiftParams(4));
                IRFPat = IRFPat./max(IRFPat).*max(Decay_par);
                h.Plots.IRFResult.XData = (1:numel(IRFPat))*TACtoTime;
                h.Plots.IRFResult.YData = IRFPat;
                h.Plots.IRFResult.Color = [0.6 0.6 0.6];
                h.Plots.IRFResult_Perp.Visible = 'off';
            else
                IRFPat = shift_by_fraction(IRFPattern,UserValues.TauFit.IRFShift{chan});
                IRFPat = IRFPat((ShiftParams(1)+1):ShiftParams(4));
                IRFPat = IRFPat./max(IRFPat).*max(Decay_par);
                h.Plots.IRFResult.XData = (1:numel(IRFPat))*TACtoTime;
                h.Plots.IRFResult.YData = IRFPat;
                h.Plots.IRFResult.Color = [0.6 0.6 0.6];
                h.Plots.IRFResult_Perp.Visible = 'off';
            end
            
            %%% plot anisotropy data also
            % unhide Result Aniso Plot
            h.Result_Plot_Aniso.Parent = h.TauFit_Panel;
            % change axes positions
            h.Result_Plot.Position = [0.075 0.3 0.9 0.55];
            h.Result_Plot_Aniso.Position = [0.075 0.075 0.9 0.15];
            
            if contains(TauFitData.FitType,'Anisotropy')
                %%% calculate anisotropy decays for data and model
                % perform background correction (constant background and
                % scatter)
                sc_par = ScatterPattern{1}'*UserValues.TauFit.FitParams{chan}(8)*sum(Decay_par);
                sc_per = ScatterPattern{2}'*UserValues.TauFit.FitParams{chan}(9)*sum(Decay_per);
                dpar = Decay_par - UserValues.TauFit.FitParams{chan}(10) - sc_par;
                dper = Decay_per - UserValues.TauFit.FitParams{chan}(11) - sc_per;
                fpar = Fit_par - UserValues.TauFit.FitParams{chan}(10) - sc_par;
                fper = Fit_per - UserValues.TauFit.FitParams{chan}(11) - sc_per;
                r_meas = (G*dpar-dper)./(G*dpar+2*dper);
                r_fit = (G*fpar-fper)./(G*fpar+2*fper);
                x_r = (1:numel(Decay)/2).*TACtoTime;
                
                % update plots
                h.Plots.AnisoResult.XData = x_r(ignore:end);
                h.Plots.AnisoResult.YData = r_meas(ignore:end);
                h.Plots.AnisoResult_ignore.XData = x_r(1:ignore);
                h.Plots.AnisoResult_ignore.YData = r_meas(1:ignore);
                h.Plots.FitAnisoResult.XData = x_r(ignore:end);
                h.Plots.FitAnisoResult.YData = r_fit(ignore:end);
                h.Plots.FitAnisoResult_ignore.XData = x_r(1:ignore);
                h.Plots.FitAnisoResult_ignore.YData = r_fit(1:ignore);
                axis(h.Result_Plot_Aniso,'tight');
                h.Result_Plot_Aniso.YLim(1) = max([-0.2,h.Result_Plot_Aniso.YLim(1)]);
                h.Result_Plot_Aniso.YLim(2) = min([0.6,h.Result_Plot_Aniso.YLim(2)]);
                %h.Result_Plot_Aniso.YLim(1) = min([min(r_meas(ignore:end)) min(r_fit(ignore:end))]);
                %h.Result_Plot_Aniso.YLim(1) = h.Result_Plot_Aniso.YLim(1) - 0.05*abs(h.Result_Plot_Aniso.YLim(1));
                %h.Result_Plot_Aniso.YLim(2) = 1.05*max([max(r_meas(ignore:end)) max(r_fit(ignore:end))]);
                h.Result_Plot_Aniso.XTick = h.Result_Plot.XTick;
                h.Result_Plot_Aniso.XTickLabelMode = 'auto';
                % change axis labels
                h.Result_Plot_Aniso.XLabel.String = 'Time [ns]';
                h.Result_Plot_Aniso.YLabel.String = 'Anisotropy';
                h.Result_Plot_Aniso.YTickLabelMode = 'auto';
                h.Plots.FitAnisoResult.Color = [1,0,0];
                h.Plots.AnisoResult.Visible = 'on';
                h.Plots.AnisoResult_ignore.Visible = 'on';
                h.Plots.FitAnisoResult_ignore.Visible = 'on';
            elseif contains(TauFitData.FitType,'Distribution') %%% show distance distribution
                xR = 0:0.01:150;
                if any(strcmp(TauFitData.FitType,{'Distribution','Distribution plus Donor only'}))
                    pR = 1./(sqrt(2*pi())*x(2)).*exp(-(xR-x(1)).^2./(2*x(2).^2));
                    pR = pR./sum(pR);
                elseif any(strcmp(TauFitData.FitType,{'Two Distributions plus Donor only','Distribution Fit - Global Model'}))
                    Gauss1 = 1./(sqrt(2*pi())*x(2)).*exp(-(xR-x(1)).^2./(2*x(2).^2));
                    Gauss1 = Gauss1./sum(Gauss1);
                    Gauss2 = 1./(sqrt(2*pi())*x(4)).*exp(-(xR-x(3)).^2./(2*x(4).^2));
                    Gauss2 = Gauss2./sum(Gauss2);
                    pR = x(5)*Gauss1 + (1-x(5))*Gauss2;
                end
                
                % update plots
                h.Plots.AnisoResult.Visible = 'off';
                h.Plots.AnisoResult_ignore.Visible = 'off';
                h.Plots.FitAnisoResult.XData = xR;
                h.Plots.FitAnisoResult.YData = pR;
                h.Plots.FitAnisoResult.Color = [0,0,0];
                h.Plots.FitAnisoResult_ignore.Visible = 'off';
                axis(h.Result_Plot_Aniso,'tight');
                h.Result_Plot_Aniso.YLim(2) = 1.05*h.Result_Plot_Aniso.YLim(2);
                % change axis labels
                h.Result_Plot_Aniso.XLabel.String = 'Distance [A]';
                h.Result_Plot_Aniso.YLabel.String = 'Probability';
                h.Result_Plot_Aniso.YTickLabels = [];
                if strcmp(TauFitData,'Distribution Fit - Global Model')
                    %%% assign only the chi2 of the DA decay
                    TauFitData.Chi2 = chi2_DA;
                end
            end
            
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
            h.Result_Plot.YLim(1) = min([min(Decay_par(1:end)) min(Decay_per(1:end))]);
            h.Result_Plot.YLim(2) = h.Result_Plot.YLim(2)*1.05;
            if contains(TauFitData.FitType,'Anisotropy') %~strcmp(TauFitData.FitType,'Distribution Fit - Global Model')
                h.Result_Plot_Aniso.XLim = [0, h.Result_Plot.XLim(2)];
            end
            
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
            % add legend
            if contains(TauFitData.FitType,'Anisotropy')
                legend_str = {'I_{||}','I_\perp'};
                l = legend([h.Plots.FitResult,h.Plots.FitResult_Perp],legend_str);
                l.Box = 'off';
            elseif strcmp(TauFitData.FitType,'Distribution Fit - Global Model')
                legend_str = {'I_{DA}','I_{D0}'};
                l = legend([h.Plots.FitResult,h.Plots.FitResult_Perp],legend_str);
                l.Box = 'off';
            else
                legend(h.Result_Plot,'off');
            end
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
            
            %IRFPat = circshift(IRFPattern,[UserValues.TauFit.IRFShift{chan},0]);
            IRFPat = shift_by_fraction(IRFPattern,UserValues.TauFit.IRFShift{chan});
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
            h.Result_Plot.YLim(1) = min([min(Decay) min(Decay_ignore)]);
            h.Result_Plot.YLim(2) = h.Result_Plot.YLim(2)*1.05;
            
            h.Plots.Residuals.XData = (ignore:Length)*TACtoTime;
            h.Plots.Residuals.YData = wres;
            h.Plots.Residuals_ZeroLine.XData = (1:Length)*TACtoTime;
            h.Plots.Residuals_ZeroLine.YData = zeros(1,Length);
            h.Plots.Residuals_ignore.XData = (1:ignore)*TACtoTime;
            h.Plots.Residuals_ignore.YData = wres_ignore;
            h.Residuals_Plot.YLim = [min(wres) max(wres)];
            legend(h.Result_Plot,'off');
        end
        
        h.Result_Plot.XLim(1) = 0;
        if strcmp(h.Result_Plot.YScale,'log')
            ydat = h.Plots.DecayResult.YData;
            ydat = ydat(ydat > 0);
            h.Result_Plot.YLim(1) = min(ydat);
        end
        
        h.Result_Plot.YLabel.String = 'Intensity [counts]';
        h.Fit_Button_MEM_tau.Visible = 'on';
        h.Fit_Button_MEM_dist.Visible = 'on';
        
        if h.MCMC_Error_Estimation_Menu.Value
            alpha = 0.05; %95% confidence interval
            disp('Running MCMC... This could take a minute.');tic;
            confint = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
            proposal = (confint(:,2)-confint(:,1))/2; proposal = (proposal/10)';
            if any(isnan(proposal))
                %%% nlparci may return NaN values. Set to 1% of the fit value
                Fitted_Params = x(~fixed);
                proposal(isnan(proposal)) = Fitted_Params(isnan(proposal))/10;
            end
            if ~exist('Decay_FitRange','var')
                Decay_FitRange = Decay;
            end
            
            %%% define log-likelihood function, which is just the negative of the chi2 divided by two! (do not use reduced chi2!!!)
            if contains(TauFitData.FitType,'Anisotropy') || strcmp(TauFitData.FitType,'Distribution Fit - Global Model')
                if strcmp(TauFitData.FitType,'Distribution Fit - Global Model')
                    sigma_est = sigma_est_fit;
                end
                loglikelihood = @(x) (-1/2)*sum((ModelFun(x,xdata)./sigma_est-Decay_FitRange./sigma_est).^2);
            else
                loglikelihood = @(x) (-1/2)*sum((ModelFun(x,xdata)./sigma_est(ignore:end)-Decay_FitRange(ignore:end)./sigma_est(ignore:end)).^2);
            end
            %%% Sample
            nsamples = 1E4; spacing = 1E2;
            [samples,prob,acceptance] =  MHsample(nsamples,loglikelihood,@(x) 1,proposal,lb(~fixed),ub(~fixed),x(~fixed)',zeros(1,numel(x(~fixed))));
            if acceptance < 0.01
                disp(sprintf('Acceptance was too low at %.4f!',acceptance));
                disp('Running again with more narrow proposal distribution.');
                [samples,prob,acceptance] =  MHsample(nsamples,loglikelihood,@(x) 1,proposal/10,lb(~fixed),ub(~fixed),x(~fixed)',zeros(1,numel(x(~fixed))));
            end
            %%% convert lifetimes
            lt = false(size(fixed)); lt(lifetimes) = true;
            samples(:,lt(~fixed)) = samples(:,lt(~fixed)).*TauFitData.TACChannelWidth;
            confint_mcmc = prctile(samples(1:spacing:end,:),100*[alpha/2,1-alpha/2],1)';
            disp(sprintf('Done. Performed %d steps in %.2f seconds.\nAcceptance was %.2f.\nSpacing used was %d.',nsamples,toc,acceptance,spacing));
            % print variables to workspace
            assignin('base',['Samples'],samples(1:spacing:end,:));
            assignin('base',['acceptance'],acceptance);
            assignin('base',['LogLikelihood'],prob(1:spacing:end));
            assignin('base',['ConfInt_MCMC'],confint_mcmc);
            disp(table(confint_mcmc));
        end
    case {h.Fit_Button_MEM_tau,h.Fit_Button_MEM_dist}
        TauFitData.FitType = 'MEM';
        TauFitData.WeightedResidualsType = h.WeightedResidualsType_Menu.String{h.WeightedResidualsType_Menu.Value};
        % initialize fit parameters
        xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),0,ignore,Conv_Type};
        
        % get fit parameters (scatter,background, irfshift)
        x0 = [ UserValues.TauFit.FitParams{chan}([8,10]) UserValues.TauFit.IRFShift{chan}];
        switch obj
            case h.Fit_Button_MEM_tau
                mode = 'tau';
            case h.Fit_Button_MEM_dist
                mode = 'dist';
                %%% append F?rster distance and donor-only lifetime
                x0(end+1) = UserValues.TauFit.FitParams{chan}(13);
                x0(end+1) = UserValues.TauFit.FitParams{chan}(14);
        end
        [tau_dist, tau, FitFun, chi2] = taufit_mem(Decay,sigma_est,x0,xdata,mode);
        
        % plot the result
        switch TauFitData.WeightedResidualsType
            case 'Gaussian'
                wres = (Decay(ignore:end)-FitFun)./sigma_est(ignore:end);
            case 'Poissonian'
                wres = MLE_w_res(FitFun,Decay(ignore:end)).*sign(Decay(ignore:end)-FitFun);
        end
        
        %%% define ignore region
        FitFun_ignore = NaN(1,ignore);
        wres_ignore = NaN(1,ignore);
        Decay_ignore = Decay(1:ignore);
        
        %%% Update Plot
        h.Microtime_Plot.Parent = h.HidePanel;
        h.Result_Plot.Parent = h.TauFit_Panel;
        h.Plots.IRFResult.Visible = 'on';
        
        % plot chi^2 on graph
        h.Result_Plot_Text.Visible = 'on';
        h.Result_Plot_Text.String = ['\' sprintf('chi^2_{red.} = %.2f', chi2)];
        h.Result_Plot_Text.Position = [0.8 0.95];
        
        % nanoseconds per microtime bin
        TACtoTime = TauFitData.TACChannelWidth;
        
        h.Plots.DecayResult_ignore.Visible = 'on';
        h.Plots.Residuals_ignore.Visible = 'off';
        h.Plots.FitResult_ignore.Visible = 'off';
        
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
        
        IRFPat = shift_by_fraction(IRFPattern,UserValues.TauFit.IRFShift{chan});
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
        h.Plots.DecayResult.YData = Decay(ignore:end);
        h.Plots.FitResult.XData = (ignore:Length)*TACtoTime;
        h.Plots.FitResult.YData = FitFun;
        
        h.Plots.DecayResult_ignore.XData = (1:ignore)*TACtoTime;
        h.Plots.DecayResult_ignore.YData = Decay_ignore;
        h.Plots.FitResult_ignore.XData = (1:ignore)*TACtoTime;
        h.Plots.FitResult_ignore.YData = FitFun_ignore;
        axis(h.Result_Plot,'tight');
        h.Result_Plot.YLim(1) = min([min(Decay) min(Decay_ignore)]);
        h.Result_Plot.YLim(2) = h.Result_Plot.YLim(2)*1.05;
        
        h.Plots.Residuals.XData = (ignore:Length)*TACtoTime;
        h.Plots.Residuals.YData = wres;
        h.Plots.Residuals_ZeroLine.XData = (1:Length)*TACtoTime;
        h.Plots.Residuals_ZeroLine.YData = zeros(1,Length);
        h.Plots.Residuals_ignore.XData = (1:ignore)*TACtoTime;
        h.Plots.Residuals_ignore.YData = wres_ignore;
        h.Residuals_Plot.YLim = [min(wres) max(wres)];
        
        % use anisotropy plot below axis to visualize the lifetime distribution
        % unhide Result "Aniso" Plot
        h.Result_Plot_Aniso.Parent = h.TauFit_Panel;
        % change axes positions
        h.Result_Plot.Position = [0.075 0.3 0.9 0.55];
        h.Result_Plot_Aniso.Position = [0.075 0.075 0.9 0.15];
        % set all unneeded plots to empty data
        h.Plots.AnisoResult.XData = [];
        h.Plots.AnisoResult.YData = [];
        h.Plots.AnisoResult_ignore.XData = [];
        h.Plots.AnisoResult_ignore.YData = [];
        h.Plots.FitAnisoResult_ignore.XData = [];
        h.Plots.FitAnisoResult_ignore.YData = [];
        
        % update plots
        h.Plots.FitAnisoResult.XData = tau;
        h.Plots.FitAnisoResult.YData = tau_dist;
        h.Result_Plot_Aniso.XLim = [tau(1),tau(end)];
        h.Result_Plot_Aniso.YLim = [0,max(tau_dist)*1.05];
        switch obj
            case h.Fit_Button_MEM_tau
                h.Result_Plot_Aniso.XLabel.String = 'Lifetime [ns]';
            case h.Fit_Button_MEM_dist
                h.Result_Plot_Aniso.XLabel.String = 'Distance [A]';
        end
        h.Result_Plot_Aniso.YLabel.String = 'Probability';
        h.Result_Plot_Aniso.XTickLabelMode = 'auto';
        
        h.Result_Plot.XLim = [0, Length*TACtoTime];
        if strcmp(h.Result_Plot.YScale,'log')
            ydat = h.Plots.DecayResult.YData;
            ydat = ydat(ydat > 0);
            h.Result_Plot.YLim(1) = min(ydat);
        end
        h.Result_Plot.YLabel.String = 'Intensity [counts]';
        legend(h.Result_Plot,'off');
    case {h.Fit_Aniso_Button,h.Fit_Aniso_2exp,h.Fit_DipAndRise}
        if obj == h.Fit_Aniso_2exp
            number_of_exponentials = 2;
        elseif obj == h.Fit_Aniso_Button
            number_of_exponentials = 1;
        elseif obj == h.Fit_DipAndRise
            number_of_exponentials = 0;
        end
        %%% construct Anisotropy
        Aniso = (G*TauFitData.FitData.Decay_Par - TauFitData.FitData.Decay_Per)./Decay;
        Aniso(isnan(Aniso)) = 0;
        Aniso_fit = Aniso(ignore:end); x = 1:numel(Aniso_fit);
        %%% Fit function
        if number_of_exponentials == 1
            tres_aniso = @(x,xdata) (x(2)-x(3))*exp(-xdata./x(1)) + x(3);
            param0 = [1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 0.4,0];
            [param,~,res,~,~,~,jacobian] = lsqcurvefit(tres_aniso,param0,x,Aniso_fit,[0 0 -1],[Inf,1,1]);
            parameter_names = {'rho','r0','r_inf'};
        elseif number_of_exponentials == 2
            tres_aniso = @(x,xdata) ((x(2)-x(4)).*exp(-xdata./x(1)) + x(4)).*exp(-xdata./x(3));
            param0 = [1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 0.4,8/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins,0.1];
            [param,~,res,~,~,~,jacobian] = lsqcurvefit(tres_aniso,param0,x,Aniso_fit,[0 -0.4 0 -0.4],[Inf,1,Inf,1]);
            parameter_names = {'rho1','r0','rho2','r_p'};
        elseif number_of_exponentials == 0
            %%% ask to fix the lifetimes
            lifetimes = [UserValues.TauFit.FitParams{chan}(1),UserValues.TauFit.FitParams{chan}(2)];
            [lifetimes,order] = sort(lifetimes);
            fraction = UserValues.TauFit.FitParams{chan}(5);
            if order(1)==2 %%% tau2 is shorter lifetime, i.e. free species
                fraction = 1-fraction;
            end
            answer = inputdlg({'Lifetime free [ns]:','Lifetime stuck [ns]:','Fraction free:'},'Fix lifetimes?',3,{num2str(lifetimes(1)),num2str(lifetimes(2)),num2str(fraction)});
            %%% "Fit Anisotropy (2 exp lifetime with independent anisotropy) model" with two components of different lifetimes
            tres_aniso = @(x,xdata) (1./(1+(x(1).*exp(-xdata.*(1/x(3)-1/x(2)))))).*((x(4)-x(5)).*exp(-xdata./x(6))+x(5))+(1-1./(1+(x(1).*exp(-xdata.*(1/x(3)-1/x(2)))))).*((x(4)-x(7)).*exp(-xdata./x(8))+x(7));
            lb = [0,0,0,0,0,0,0,0];ub = [Inf,Inf,Inf,0.4,0.4,Inf,0.4,Inf];
            if ~isempty(answer)
                lb(1) = 1/str2double(answer{3})-1; ub(1) = lb(1);
                lb(2) = str2double(answer{1})/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins; ub(2) = lb(2);
                lb(3) = str2double(answer{2})/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins; ub(3) = lb(3);
            end
            opt = optimoptions('lsqcurvefit','MaxFunctionEvaluations',1E4);
            param0 = [0.5,1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins,2/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins,0.4,0.1,1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins,0.1,3/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins];
            [param,~,res,~,~,~,jacobian] = lsqcurvefit(tres_aniso,param0,x,Aniso_fit,lb,ub,opt);
            parameter_names = {'Ampl. Ratio','tau1','tau2','r0,1','r_inf,1','rho1','r_inf,2','rho2'};
        end
        
        x_fitres = ignore:numel(Aniso);
        fitres = tres_aniso(param,x);fitres = fitres(1:(numel(Aniso)-ignore+1));
        res = Aniso_fit-fitres;
        
        Aniso_ignore = Aniso(1:ignore);
        
        TACtoTime = TauFitData.TACChannelWidth;%1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
        
        %%% calculate confidence intervals
        alpha = 0.05; %95% confidence interval
        ConfInt = nlparci(param,res,'jacobian',jacobian,'alpha',alpha);
        %%% convert lifetimes
        param_ns = param;
        switch number_of_exponentials
            case 1
                lt = 1;
            case 2
                lt = [1,3];
            case 0
                lt = [2,3,6,8];
        end
        param_ns(lt) = TACtoTime*param_ns(lt);
        ConfInt(lt,:) = TACtoTime*ConfInt(lt,:);
        %%% print confidence intervals to command line and clipboard
        tab = table(param_ns',ConfInt(:,1),ConfInt(:,2),'VariableNames',{'Value','LB','UB'},...
            'RowName',parameter_names);
        disp(tab);
        
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
        h.Result_Plot.YLim = [min([0,min(Aniso)-0.02]),min([0.8,max(Aniso)+0.02])];
        h.Result_Plot_Text.Visible = 'on';
        if number_of_exponentials == 1
            str = sprintf('rho = %1.2f ns\nr_0 = %2.4f\nr_{inf} = %3.4f',param(1)*TACtoTime,param(2),param(3));
        elseif number_of_exponentials == 2
            str = sprintf('rho_f = %1.2f ns\nrho_p = %1.2f ns\nr_0 = %2.4f\nr_{p} = %3.4f',param(1)*TACtoTime,param(3)*TACtoTime,param(2),param(4));
        elseif number_of_exponentials == 0
            str = sprintf('F_1 = %1.2f\ntau_1 = %1.2f ns\ntau_2 = %1.2f ns\nrho_1 = %1.2f ns\nrho_2= %1.2f ns\nr_0 = %2.4f\nr_{inf,1} = %3.4f\nr_{inf,2} = %3.4f',...
                1/(1+param(1)),param(2)*TACtoTime,param(3)*TACtoTime,param(6)*TACtoTime,param(8)*TACtoTime,param(4),param(5),param(7));
        end
        str = strrep(strrep(str,'rho','\rho'),'tau','\tau');
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
                if ~poissonian_chi2
                    weights = sqrt(Decay_fit); weights(weights==0) = 1;
                    [param,~,res,~,~,~,jacobian] = lsqcurvefit(@(x,xdata) model(x,xdata)./weights,param0,x_fit,Decay_fit./weights,[0 0 0],[Inf,Inf,Inf]);
                else
                    [param,~,res,~,~,~,jacobian] = lsqnonlin(@(x) MLE_w_res(model(x,x_fit),Decay_fit),param0,[0 0 0],[Inf,Inf,Inf]);
                end
            else
                [param,~,res,~,~,~,jacobian] = lsqcurvefit(model,param0,x_fit,Decay_fit,[0 0 0],[Inf,Inf,Inf]);
            end
            parameter_names = {'I0','tau','offset'};
        elseif number_of_exponentials == 2
            %%% param is
            %%% I0, tau1, tau2, Fraction1, offset
            model = @(x,xdata) x(1)*(x(4)*exp(-xdata./x(2))+(1-x(4))*exp(-xdata./x(3)))+x(5);
            param0 = [Decay_fit(1) 1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 0.5,0];
            if h.UseWeightedResiduals_Menu.Value
                if ~poissonian_chi2
                    weights = sqrt(Decay_fit); weights(weights==0) = 1;
                    [param,~,res,~,~,~,jacobian] = lsqcurvefit(@(x,xdata) model(x,xdata)./weights,param0,x_fit,Decay_fit./weights,[0, 0, 0,0,0],[Inf,Inf,Inf,1,Inf]);
                else
                    [param,~,res,~,~,~,jacobian] = lsqnonlin(@(x) MLE_w_res(model(x,x_fit),Decay_fit),param0,[0, 0, 0,0,0],[Inf,Inf,Inf,1,Inf]);
                end
            else
                [param,~,res,~,~,~,jacobian] = lsqcurvefit(model,param0,x_fit,Decay_fit,[0 0 0,0,0],[Inf,Inf,Inf,1,Inf]);
            end
            parameter_names = {'I0','tau1','tau2','Fraction1','offset'};
        elseif number_of_exponentials == 3
            %%% param is
            %%% I0, tau1, tau2, tau3, Fraction1, Fraction2, offset
            %model = @(x,xdata) x(1)*(x(5)*exp(-xdata./x(2))+x(6)*exp(-xdata./x(3))+max([0 (1-x(5)-x(6))])*exp(-xdata./x(4)))+x(7);
            model = @tailfit_3exp;
            param0 = [Decay_fit(1) 1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 2/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 3/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins,...
                0.3,0.3,0];
            options = optimoptions('lsqcurvefit','MaxFunctionEvaluations',1E5,'MaxIterations',1E4);
            if h.UseWeightedResiduals_Menu.Value
                if ~poissonian_chi2
                    weights = sqrt(Decay_fit); weights(weights==0) = 1;
                    [param,~,res,~,~,~,jacobian] = lsqcurvefit(@(x,xdata) model(x,xdata)./weights,param0,x_fit,Decay_fit./weights,[0,0,0,0,0,0,0],[Inf,Inf,Inf,Inf,1,1,Inf],options);
                else
                    [param,~,res,~,~,~,jacobian] = lsqnonlin(@(x) MLE_w_res(model(x,x_fit),Decay_fit),param0,[0,0,0,0,0,0,0],[Inf,Inf,Inf,Inf,1,1,Inf],options);
                end
            else
                [param,~,res,~,~,~,jacobian] = lsqcurvefit(model,param0,x_fit,Decay_fit,[0,0,0,0,0,0,0],[Inf,Inf,Inf,Inf,1,1,Inf],options);
            end
            parameter_names = {'I0','tau1','tau2','tau3','Fraction1','Fraction2','offset'};
            % fix amplitudes same way as done in fit function
            if (param(5)+param(6)) > 1
                norm = param(5)+param(6);
                param(5) = param(5)./norm;
                param(6) = param(6)./norm;
            end
        end
        
        x_fitres = ignore:numel(Decay);
        fitres = model(param,x_fit);fitres = fitres(1:(numel(Decay)-ignore+1));
        
        Decay_ignore = Decay(1:ignore);
        if poissonian_chi2
            res = res.*sign(Decay_fit-fitres);
        end
        TACtoTime = TauFitData.TACChannelWidth;%TauFitData.MI_Bins*TauFitData.TACRange*1e9;
        
        %%% calculate confidence intervals
        alpha = 0.05; %95% confidence interval
        ConfInt = nlparci(param,res,'jacobian',jacobian,'alpha',alpha);
        %%% convert lifetimes
        param_ns = param;
        param_ns(1+(1:number_of_exponentials)) = TACtoTime*param_ns(1+(1:number_of_exponentials));
        ConfInt(1+(1:number_of_exponentials),:) = TACtoTime*ConfInt(1+(1:number_of_exponentials),:);
        %%% print confidence intervals to command line and clipboard
        tab = table(param_ns',ConfInt(:,1),ConfInt(:,2),'VariableNames',{'Value','LB','UB'},...
            'RowName',parameter_names);
        disp(tab);
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
        h.Result_Plot.YLim(2) = h.Result_Plot.YLim(2)*1.05;
        h.Result_Plot_Text.Visible = 'on';
        
        %%% update output text
        if number_of_exponentials > 1
            %%% Convert Fraction from Amplitude (species) fraction to Intensity fraction
            %%% (i.e. correct for brightness)
            %%% Intensity is proportional to tau*amplitude
            switch number_of_exponentials
                case 2
                    amp1 = param(2)*TACtoTime*param(4); amp2 = (1-param(4))*param(3)*TACtoTime;
                    amp_sum = amp1+amp2;
                    f1 = amp1./amp_sum;
                    f2 = amp2./amp_sum;
                    meanTau = TACtoTime*(param(2)*f1+param(3)*f2);
                    meanTau_Fraction = param(2)*TACtoTime*param(4) + (1-param(4))*param(3)*TACtoTime;
                    % update status text
                    h.Output_Text.String = {sprintf('Mean Lifetime Fraction: %.2f ns',meanTau_Fraction),...
                        sprintf('Mean Lifetime Int: %.2f ns',meanTau),...
                        ['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'],...
                        ['Intensity fraction of Tau2: ' sprintf('%2.2f',100*f2) ' %.']};
                case 3
                    amp1 = param(2)*TACtoTime*param(5); amp2 = param(3)*TACtoTime*param(6); amp3 = param(4)*TACtoTime*(1-param(5)-param(6));
                    amp_sum = amp1+amp2+amp3;
                    f1 = amp1./amp_sum;
                    f2 = amp2./amp_sum;
                    f3 = amp3./amp_sum;
                    meanTau = TACtoTime*(param(2)*f1+param(3)*f2+param(4)*f3);
                    meanTau_Fraction = param(2)*TACtoTime*param(5)+ param(3)*TACtoTime*param(6)+ param(4)*TACtoTime*(1-param(5)-param(6));
                    % update status text
                    h.Output_Text.String = {sprintf('Mean Lifetime Fraction: %.2f ns',meanTau_Fraction),...
                        sprintf('Mean Lifetime Int: %.2f ns',meanTau),...
                        ['Intensity fraction of Tau1: ' sprintf('%2.2f',100*f1) '%.'],...
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
            str = sprintf('I_0 = %1.2f \n\\tau_1 = %1.2f ns\n\\tau_2 = %2.2f ns\namplitude 1 = %3.2f\namplitude 2 = %3.2f\noffset = %3.2f',...
                param(1),param(2)*TACtoTime,param(3)*TACtoTime,param(4),1-param(4),param(5));
        elseif number_of_exponentials == 3
            str = sprintf('I_0 = %1.2f \n\\tau_1 = %1.2f ns\n\\tau_2 = %2.2f ns\n\\tau_3 = %2.2f ns\namplitude 1 = %3.2f\namplitude 2 = %3.2f\namplitude 3 = %3.2f\noffset = %3.2f',...
                param(1),param(2)*TACtoTime,param(3)*TACtoTime,param(4)*TACtoTime,param(5),param(6),1-param(5)-param(6),param(7));
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
h.Plots.FitResult_ignore.Visible = 'off';
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
TACtoTime = TauFitData.TACChannelWidth;%1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
h.Result_Plot_Text.String = sprintf(['rho = ' num2str(x(2)*TACtoTime) ' ns \nr_0 = ' num2str(x(1))...
    '\nr_i_n_f = ' num2str(x(3))]);
h.Result_Plot_Text.Position = [0.8,0.9];%[0.8*h.Result_Plot.XLim(2) 0.9*h.Result_Plot.YLim(2)];
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
f = figure('Position',[100,100,800,550],'color',[1 1 1]);
panel_copy = copyobj(h.TauFit_Panel,f);
panel_copy.Position = [0 0 1 1];
panel_copy.ShadowColor = [1 1 1];
%%% set Background Color to white
panel_copy.BackgroundColor = [1 1 1];
panel_copy.HighlightColor = [1 1 1];
ax = panel_copy.Children;
delete(ax(1));ax = ax(2:end); % remove buttongroup
ax = ax(strcmp(get(ax,'Type'),'axes')); % remove legend


for i = 1:numel(ax)
    ax(i).Color = [1 1 1];
    ax(i).XColor = [0 0 0];
    ax(i).YColor = [0 0 0];
    ax(i).LineWidth = 1.5;
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

if ~any(strcmp(TauFitData.FitType,{'Fit Anisotropy','Fit Anisotropy (2 exp rot)','Fit Anisotropy (2 exp lifetime)','Fit Anisotropy (2 exp lifetime, 2 exp rot)','Fit Anisotropy (2 exp lifetime with independent anisotropy)','MEM','Distribution Fit - Global Model'})) && (h.Result_Plot_Aniso.Parent == h.HidePanel)
    %%% no anisotropy fit
    for i = 1:numel(ax)
        switch ax(i).Tag
            case 'Microtime_Plot'
                ax(i).Position = [0.1 0.15 0.875 0.70];
                if ~isequal(obj, h.Microtime_Plot_Export)
                    ax(i).Children(end).FontSize = 16; %resize the chi^2 thing
                    ax(i).Children(end).Position(2) = 0.9;
                    ax(i).Children(end).BackgroundColor = 'none';
                end
                if strcmp(h.Microtime_Plot.YScale,'log')
                    ax(i).YScale = 'log';
                    ax(i).YLim(2) = ax(i).YLim(2)*1.25;
                end
            case 'Residuals_Plot'
                ax(i).Position = [0.1 0.85 0.875 .12];
        end
    end
else
    for i = 1:numel(ax)
        switch ax(i).Tag
            case 'Result_Plot_Aniso'
                if strcmp(TauFitData.FitType,'MEM') && ~strcmp(TauFitData.FitType,'Distribution Fit - Global Model')
                    ax(i).Position = [0.125 0.13 0.845 0.15];
                    if strcmp(h.Microtime_Plot.YScale,'log')
                        %ax(i).YScale = 'log';
                    end
                else % MEM fit
                    ax(i).Position = [0.125 0.10 0.845 0.14];
                end
                aniso_plot = i;
            case 'Microtime_Plot'
                if ~strcmp(TauFitData.FitType,'MEM') && ~strcmp(TauFitData.FitType,'Distribution Fit - Global Model')
                    ax(i).Position = [0.125 0.28 0.845 0.58];
                    ax(i).XTickLabels = [];
                    ax(i).XLabel.String = '';
                else % MEM fit
                    ax(i).Position = [0.125 0.35 0.845 0.51];
                end
                if ~isequal(obj, h.Microtime_Plot_Export)
                    ax(i).Children(end).FontSize = 16; %resize the chi^2 thing
                    ax(i).Children(end).Position(2) = 0.9;
                    ax(i).Children(end).BackgroundColor = 'none';
                end
                if strcmp(h.Microtime_Plot.YScale,'log')
                    ax(i).YScale = 'log';
                    ax(i).YLim(2) = ax(i).YLim(2)*1.25;
                end
                ax(i).YTickLabelMode = 'auto';
                ax(i).YTickLabels{1} = '';
                %%% move text so it does not overlap with legend
                txt = ax(i).Children(strcmp('text',get(ax(i).Children,'Type')));
                txt.Position(1) = 0.75;
                txt.Position(2) = 0.93;
            case 'Residuals_Plot'
                ax(i).Position = [0.125 0.86 0.845 .13];
                ax(i).YTickLabelMode = 'auto';
        end
    end
end
for i = 1:numel(ax)
    ax(i).Units = 'pixels';
    if ispc
        ax(i).FontSize =  ax(i).FontSize/1.4;
    end
end
if strcmp(TauFitData.Who,'TauFit') || strcmp(TauFitData.Who,'External')
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
    FileName = fullfile(TauFitData.Path,TauFitData.FileName);
else
    c = '';
    FileName = TauFitData.FileName;
end
f.PaperPositionMode = 'auto';
print(f, '-dtiff', '-r150', GenerateName([FileName(1:end-4) a c b],1))

if ~isequal(obj,  h.Microtime_Plot_Export) %%% Exporting fit result
    %%% get name of file
    %%% Make table from fittable and save as txt
    res = h.FitPar_Table.Data(:,1);
    if ~all(isnan(TauFitData.ConfInt(:)))
        if ~(size(TauFitData.ConfInt,1) == size(res,1))
            ci = TauFitData.ConfInt(1:size(res,1),:);
        else
            ci = TauFitData.ConfInt;
        end
        res = [res, num2cell(ci)];
    end
    tab = cell2table(res,'RowNames',h.FitPar_Table.RowName,'VariableNames',{'Result','CI_lower','CI_upper'});
    writetable(tab,GenerateName([FileName(1:end-4) a c '.txt'],1),'WriteRowNames',true,'Delimiter','\t');
end

%%% also make an extra anisotropy plot if anisotropy model was fit
if any(strfind(TauFitData.FitType,'Anisotropy')) && ~(h.Result_Plot_Aniso.Parent == h.HidePanel)
    f2 = figure('Position',[200,100,450,275],'color',[1 1 1], 'Name', 'Anisotropy');
    axes_copy = copyobj(ax(aniso_plot),f2);
    axes_copy.Position = [75,55,350,200];
    if ispc
        axes_copy.FontSize = axes_copy.FontSize/1.4;
    end
    f2.PaperPositionMode = 'auto';
    print(f2, '-dtiff', '-r150', GenerateName([FileName(1:end-4) a c '_aniso' b],1))
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
if ~( (SD == 0)||(SA == 0) )
    cos_thetaDA = sqrt(abs((1+2*(rinfad/SA/SD/r0a))/3));
else
    % division by zero, default to 1/3
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
function a = interlace( a, x, fix )
a(~fix) = x;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Burstwise Lifetime Fit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BurstWise_Fit(obj,~)
global UserValues TauFitData PamMeta
h = guidata(findobj('Tag','TauFit'));
%%% get BurstData from PamMeta
BurstData = PamMeta.BurstData;
if ~isempty(findobj('Tag','Pam'))
    ph = guidata(findobj('Tag','Pam'));
end

h.Progress_Text.String = 'Opening Parallel Pool ...';
StartParPool();

h.Progress_Text.String = 'Preparing Lifetime Fit...';
drawnow;

%%% downsampling of microtime histograms to improve speed
downsample = true;

%%% also calculate the phasor?
%%% this comes cheap since it is just a calculation on the microtime
%%% histograms which are computed anyway
do_phasor = (UserValues.BurstSearch.CalculateBurstwisePhasor == 1);
use_irf_as_phasor_reference = (UserValues.BurstSearch.PhasorReference == 1);
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
        if do_phasor
            phasor{1} = cell(numel(parts)-1,1);
            phasor{2} = cell(numel(parts)-1,1);
        end
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
                %hIRF_par = circshift(TauFitData.hIRF_Par{chan},[0,TauFitData.IRFShift{chan}])';
                hIRF_par = shift_by_fraction(TauFitData.hIRF_Par{chan},TauFitData.IRFShift{chan});
                %%% Apply the shift to the perpendicular IRF channel
                %hIRF_per = circshift(TauFitData.hIRF_Per{chan},[0,TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan}])';
                hIRF_per = shift_by_fraction(TauFitData.hIRF_Per{chan},TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan});
                IRFPattern = G{chan}*(1-3*l2)*hIRF_par(1:TauFitData.Length{chan}) + (2-3*l1)*hIRF_per(1:TauFitData.Length{chan});
                IRFPattern = IRFPattern./sum(IRFPattern);
                %%% additional processing of the IRF to remove constant background
                if TauFitData.IRFBackground{chan} == 0 % do standard background correction
                    %%% additional processing of the IRF to remove constant background
                    IRFPattern = IRFPattern - mean(IRFPattern(end-round(numel(IRFPattern)/10):end));
                else % do baseline correction
                    IRFPattern = IRFPattern - max(IRFPattern).*TauFitData.IRFBackground{chan};
                end
                IRFPattern(IRFPattern<0) = 0;
                IRFPattern = IRFPattern./sum(IRFPattern);
                % clean up by fitting to gamma distribution
                if UserValues.TauFit.cleanup_IRF
                    IRFPattern = fix_IRF_gamma_dist(IRFPattern',chan)';
                    Irf =  IRFPattern((TauFitData.StartPar{chan}+1):TauFitData.Length{chan}); % use full length then
                else
                    Irf =  IRFPattern((TauFitData.StartPar{chan}+1):TauFitData.IRFLength{chan});
                end

                Irf = Irf./sum(Irf);
                IRF{chan} = [Irf zeros(1,TauFitData.Length{chan}-TauFitData.StartPar{chan}-numel(Irf))];
                %%% Scatter is still read from plots
                Scatter = G{chan}*(1-3*l2)*h.Plots.Scat_Par.YData + (2-3*l1)*h.Plots.Scat_Per.YData;
                SCATTER{chan} = Scatter./sum(Scatter);
                Length{chan} = numel(Scatter)-1;
                
                %%% for phasor, read reference for the respective channels
                if do_phasor
                    if use_irf_as_phasor_reference
                        PhasorRef{chan} = IRF{chan};
                        PhasorReferenceLifetime(chan) = 0;
                        %%% update the values in BurstData
                        BurstData.Phasor.PhasorReference{chan} = PhasorRef{chan};
                        BurstData.Phasor.PhasorReferenceLifetime(chan) = PhasorReferenceLifetime(chan);
                    else
                        PhasorRef_par = TauFitData.PhasorReference_Par{chan}((TauFitData.StartPar{chan}+1):TauFitData.Length{chan});
                        %%% Apply the shift to the perpendicular IRF channel
                        PhasorRef_per = circshift(TauFitData.PhasorReference_Per{chan},[0,TauFitData.ShiftPer{chan}]);
                        PhasorRef_per = PhasorRef_per((TauFitData.StartPar{chan}+1):TauFitData.Length{chan});
                        PhasorRef{chan} = G{chan}*(1-3*l2)*PhasorRef_par + (2-3*l1)*PhasorRef_per;
                        PhasorReferenceLifetime(chan) = TauFitData.PhasorReferenceLifetime(chan);
                    end
                    PhasorScat{chan} = SCATTER{chan};
                    %%% store the length of the microtime range used for
                    %%% fitting (needed to obtain the frequency omegae at a
                    %%% later stage)
                    BurstData.Phasor.PhasorRange(chan) = TauFitData.Length{chan}-TauFitData.StartPar{chan};
                end
                
                [tau, i] = meshgrid(mean_tau-range_tau/2:range_tau/steps_tau:mean_tau+range_tau/2, 0:Length{chan});
                T = TauFitData.TACChannelWidth*Length{chan};
                GAMMA = T./tau;
                p = exp(-i.*GAMMA/Length{chan}).*(exp(GAMMA/Length{chan})-1)./(1-exp(-GAMMA));
                %p = p(1:length+1,:);
                if verLessThan('MATLAB','9.4') %%% before 2018a
                    c = convnfft(p,IRF{chan}(ones(steps_tau+1,1),:)', 'full', 1);   %%% Linear Convolution!
                else %%% convnfft function does not work in 2018a
                    c = zeros(2*size(p,1)-1,size(p,2));
                    for k = 1:size(p,2)
                        c(:,k) = conv(p(:,k),IRF{chan}');
                    end
                end
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
                if downsample
                    %%% Rebin to improve speed
                    model_dummy = zeros(floor(size(model,1)/new_bin_width),size(model,2));
                    for i = 1:size(model,2)
                        model_dummy(:,i) = downsamplebin(model(:,i),new_bin_width);
                    end
                    model = model_dummy;
                end
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
                Per1 = circshift(Per1,[0,round(TauFitData.ShiftPer{1})]); %%% note: for burst-wise fitting, do not consider fractional shifting of decays
                Per1 = Per1(:,(TauFitData.StartPar{1}+1):TauFitData.Length{1});
                Mic{1} = (1-3*l2)*G{1}*Par1+(2-3*l1)*Per1;
                clear Par1 Per1
                if do_phasor
                    Mic_Phasor{1} = Mic{1};
                end
                %%% Rebin to improve speed
                if downsample
                    Mic1 = zeros(numel(MI),floor(size(Mic{1},2)/new_bin_width));
                    parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                        Mic1(i,:) = downsamplebin(Mic{1}(i,:),new_bin_width);
                    end
                    Mic{1} = Mic1'; clear Mic1;
                else
                    Mic{1} = Mic{1}';
                end
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
                Per2 = circshift(Per2,[0,round(TauFitData.ShiftPer{2})]);%%% note: for burst-wise fitting, do not consider fractional shifting of decays
                Per2 = Per2(:,(TauFitData.StartPar{2}+1):TauFitData.Length{2});
                Mic{2} = (1-3*l2)*G{2}*Par2+(2-3*l1)*Per2;
                clear Par2 Per2
                if do_phasor
                    Mic_Phasor{2} = Mic{2};
                end
                if downsample
                    %%% Rebin to improve speed
                    Mic2 = zeros(numel(MI),floor(size(Mic{2},2)/new_bin_width));
                    parfor (i = 1:numel(MI),UserValues.Settings.Pam.ParallelProcessing)
                        Mic2(i,:) = downsamplebin(Mic{2}(i,:),new_bin_width);
                    end
                    Mic{2} = Mic2'; clear Mic2;
                else
                    Mic{2} = Mic{2}';
                end
            end
            
            %% Fitting...
            %%% Prepare the fit inputs
            lt = zeros(numel(MI),2);
            if do_phasor
                ph = zeros(numel(MI),10);
            end
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
                    
                    if do_phasor
                        if ~use_bg % no background correction
                            ph(:,5*(chan-1)+1:5*chan) = BurstWise_Phasor(Mic_Phasor{chan},PhasorRef{chan},PhasorReferenceLifetime(chan));
                        else
                            ph(:,5*(chan-1)+1:5*chan) = BurstWise_Phasor(Mic_Phasor{chan},PhasorRef{chan},PhasorReferenceLifetime(chan),fraction_bg,PhasorScat{chan});
                        end
                        phasor{j} = ph;
                    end
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
        if do_phasor; phasor = vertcat(phasor{:}); end
        %% Save the result
        Progress(1,h.Progress_Axes,h.Progress_Text,'Saving...');
        idx_tauGG = strcmp('Lifetime D [ns]',BurstData.NameArray);
        idx_tauRR = strcmp('Lifetime A [ns]',BurstData.NameArray);
        if (sum(idx_tauGG)==0)
            idx_tauGG = strcmp('Lifetime GG [ns]',BurstData.NameArray);
            idx_tauRR = strcmp('Lifetime RR [ns]',BurstData.NameArray);
        end
        % will be zeros if lifetime is not included
        if UserValues.TauFit.IncludeChannel(1)
            BurstData.DataArray(:,idx_tauGG) = lifetime(:,1);
        end
        if UserValues.TauFit.IncludeChannel(2)
            BurstData.DataArray(:,idx_tauRR) = lifetime(:,2);
        end
        if do_phasor
            %%% was phasor saved before?
            if ~all(strcmp('Phasor: gD',BurstData.NameArray) == 0)
                %%% phasor was stored, overwrite
                idx_gD = find(strcmp('Phasor: gD',BurstData.NameArray));
                BurstData.DataArray(:,idx_gD:(idx_gD+size(phasor,2)-1)) = phasor;
            else %%% no phasor stored, append to array
                BurstData.NameArray = [BurstData.NameArray,...
                    {'Phasor: gD','Phasor: sD','Phasor: TauP(D) [ns]','Phasor: TauM(D) [ns]','Phasor: TauMean(D) [ns]',...
                    'Phasor: gA','Phasor: sA','Phasor: TauP(A) [ns]','Phasor: TauM(A) [ns]','Phasor: TauMean(A) [ns]'}];
                BurstData.DataArray = [BurstData.DataArray, phasor];
            end
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
                %hIRF_par = circshift(TauFitData.hIRF_Par{chan},[0,TauFitData.IRFShift{chan}])';
                hIRF_par = shift_by_fraction(TauFitData.hIRF_Par{chan},TauFitData.IRFShift{chan});
                %%% Apply the shift to the perpendicular IRF channel
                %hIRF_per = circshift(TauFitData.hIRF_Per{chan},[0,TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan}])';
                hIRF_per = shift_by_fraction(TauFitData.hIRF_Per{chan},TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan});
                IRFPattern = G{chan}*(1-3*l2)*hIRF_par(1:TauFitData.Length{chan}) + (2-3*l1)*hIRF_per(1:TauFitData.Length{chan});
                IRFPattern = IRFPattern./sum(IRFPattern);
                
                %%% additional processing of the IRF to remove constant background
                if TauFitData.IRFBackground{chan} == 0 % do standard background correction
                    %%% additional processing of the IRF to remove constant background
                    IRFPattern = IRFPattern - mean(IRFPattern(end-round(numel(IRFPattern)/10):end));
                else % do baseline correction
                    IRFPattern = IRFPattern - max(IRFPattern).*TauFitData.IRFBackground{chan};
                end
                IRFPattern(IRFPattern<0) = 0;
                IRFPattern = IRFPattern./sum(IRFPattern);
                
                % clean up by fitting to gamma distribution
                if UserValues.TauFit.cleanup_IRF
                    IRFPattern = fix_IRF_gamma_dist(IRFPattern',chan)';
                    Irf =  IRFPattern((TauFitData.StartPar{chan}+1):TauFitData.Length{chan}); % use full length then
                else
                    Irf =  IRFPattern((TauFitData.StartPar{chan}+1):TauFitData.IRFLength{chan});
                end
                
                %Irf = Irf-min(Irf(Irf~=0));
                Irf = Irf./sum(Irf);
                IRF{chan} = [Irf zeros(1,TauFitData.Length{chan}-TauFitData.StartPar{chan}-numel(Irf))];
                %%% Scatter is still read from the plots
                Scatter = G{chan}*(1-3*l2)*h.Plots.Scat_Par.YData + (2-3*l1)*h.Plots.Scat_Per.YData;
                SCATTER{chan} = Scatter./sum(Scatter);
                Length{chan} = numel(Scatter)-1;
                
                [tau, i] = meshgrid(mean_tau-range_tau/2:range_tau/steps_tau:mean_tau+range_tau/2, 0:Length{chan});
                T = TauFitData.TACChannelWidth*Length{chan};
                GAMMA = T./tau;
                p = exp(-i.*GAMMA/Length{chan}).*(exp(GAMMA/Length{chan})-1)./(1-exp(-GAMMA));
                %p = p(1:length+1,:);
                if verLessThan('MATLAB','9.4') %%% before 2018a
                    c = convnfft(p,IRF{chan}(ones(steps_tau+1,1),:)', 'full', 1); %%% Linear Convolution!
                else %%% convnfft function does not work in 2018a
                    c = zeros(2*size(p,1)-1,size(p,2));
                    for k = 1:size(p,2)
                        c(:,k) = conv(p(:,k),IRF{chan}');
                    end
                end
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
                Per1 = circshift(Per1,[0,round(TauFitData.ShiftPer{1})]);%%% note: for burst-wise fitting, do not consider fractional shifting of decays
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
                Per2 = circshift(Per2,[0,round(TauFitData.ShiftPer{2})]);%%% note: for burst-wise fitting, do not consider fractional shifting of decays
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
                Per3 = circshift(Per3,[0,round(TauFitData.ShiftPer{3})]);%%% note: for burst-wise fitting, do not consider fractional shifting of decays
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
save(TauFitData.FileName,'BurstData','-append');
%%% update BurstData in PamMeta
PamMeta.BurstData = BurstData;
Progress(1,h.Progress_Axes,h.Progress_Text,'Done');
%%% Change the Color of the Button in Pam
hPam = findobj('Tag','Pam');
handlesPam = guidata(hPam);
handlesPam.Burst.BurstLifetime_Button.ForegroundColor = [0 0.8 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Burstwise Phasor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [phasor] = BurstWise_Phasor(Mic,Ref,Ref_LT,fraction_bg,Scat)
%%% Calculates the burstwise phasor components g and s,
%%% as well as the lifetimes from phase (TauP) and modulation (TauM)
%%% The average lifetime TauMean = (TauP+TauM)/2 is also returned.
%%%
%%% Input: Mic - N_bursts X MI_Bins array of the burstwise microtime histograms
%%%        Ref - 1 x Mi_Bins microtime hisogram of the reference
%%%              Can be the IRF (Ref_LT = 0) or a reference sample such as
%%%              donor only.
%%%        Ref_LT - Lifetime of the reference sample in nanoseconds
%%%        fraction_bg - The background intensity fraction estimated from
%%%                      the background count rate and the measured
%%%                      signal.
%%%        Scat - the backgorund microtime pattern (i.e. buffer
%%%               measurement)
global TauFitData

if nargin == 3 % no bg correction
    correct_background = false;
else
    correct_background = true;
end

MI_Bins = size(Mic,2); % Total number of MI bins of file
From=1; % First MI bin to used
To=MI_Bins; % Last MI bin to be used
Ref_MI_Bins = size(Ref,2);
Ref_TAC = TauFitData.TACRange * 1E9 .* Ref_MI_Bins/TauFitData.MI_Bins; % in ns
TAC= TauFitData.TACRange * 1E9  .* MI_Bins/TauFitData.MI_Bins; % Length of full MI range in ns

%%% for now, we assume the background etc to be zero (can be added at a
%%% later time)
Background_ref = 0;
Background = 0;
Afterpulsing = 0;
Shift = 0; % Shift between reference and file in MI bins

%%% Calculates theoretical phase and modulation for reference
Fi_ref = atan(2*pi*Ref_LT/Ref_TAC);
M_ref  = 1/sqrt(1+(2*pi*Ref_LT/Ref_TAC)^2);

%%% Normalizes reference data
Ref = Ref-sum(Ref)*Afterpulsing/Ref_MI_Bins - Background_ref;
Ref_Mean=sum(Ref(1:Ref_MI_Bins).*(1:Ref_MI_Bins))/sum(Ref)*Ref_TAC/Ref_MI_Bins-Ref_LT;
Ref = Ref./sum(Ref);

%%% Calculates phase and modulation of the instrument
G_inst=cos((2*pi./Ref_MI_Bins)*(1:Ref_MI_Bins)-Fi_ref)/M_ref;
S_inst=sin((2*pi./Ref_MI_Bins)*(1:Ref_MI_Bins)-Fi_ref)/M_ref;
g_inst=sum(Ref(1:Ref_MI_Bins).*G_inst);
s_inst=sum(Ref(1:Ref_MI_Bins).*S_inst);
Fi_inst=atan(s_inst/g_inst);
M_inst=sqrt(s_inst^2+g_inst^2);
if (g_inst<0 || s_inst<0)
    Fi_inst=Fi_inst+pi;
end

%%% these are the instrument corrected phasor components
G = cos((2*pi/MI_Bins).*(1:MI_Bins)-Fi_inst)/M_inst;
S = sin((2*pi/MI_Bins).*(1:MI_Bins)-Fi_inst)/M_inst;

%%%% calculate phasor for every burst
g = sum(Mic.*repmat(G,size(Mic,1),1),2)./sum(Mic,2);
s = sum(Mic.*repmat(S,size(Mic,1),1),2)./sum(Mic,2);
%%% project values
neg=find(g<0 & s<0);
g(neg)=-g(neg);
s(neg)=-s(neg);

%%% correct background
if correct_background
    %%% calculate the phasor of the background microtime pattern
    g_background = sum(Scat.*G)./sum(Scat);
    s_background = sum(Scat.*S)./sum(Scat);
    %%% correct g and s for background
    g = (g - fraction_bg.*g_background)./(1-fraction_bg);
    s = (s - fraction_bg.*s_background)./(1-fraction_bg);
end

%%% calculate lifetime values
Fi=atan(s./g); Fi(isnan(Fi))=0;
M=sqrt(s.^2+g.^2);M(isnan(M))=0;
TauP=real(tan(Fi)./(2*pi/TAC));TauP(isnan(TauP))=0;
TauM=real(sqrt((1./(s.^2+g.^2))-1)/(2*pi/TAC));TauM(isnan(TauM))=0;
TauMean = (TauP+TauM)/2;

phasor = [g,s,TauP,TauM,TauMean];

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

function [startpar, names, tooltipstring] = GetTableData(model, chan)
% model is the selected fit model in the popupmenu
% chan is the selected (burst or PIE pair) channel
global UserValues
Parameters = cell(14,1);
Parameters{1} = {'Tau [ns]','Scatter','Background','IRF Shift'};
Parameters{2} = {'Tau1 [ns]','Tau2 [ns]','Fraction 1','Scatter','Background','IRF Shift'};
Parameters{3} = {'Tau1 [ns]','Tau2 [ns]','Tau3 [ns]','Fraction 1','Fraction 2','Scatter','Background','IRF Shift'};
Parameters{4} = {'Tau1 [ns]','Tau2 [ns]','Tau3 [ns]','Tau4 [ns]','Fraction 1','Fraction 2','Fraction 3','Scatter','Background','IRF Shift'};
Parameters{5} = {'Tau [ns]','beta','Scatter','Background','IRF Shift'};
Parameters{6} = {'Center R [A]','Sigma R [A]','Scatter','Background','R0 [A]','TauD0 [ns]','IRF Shift'};
Parameters{7} = {'Center R [A]','Sigma R [A]','Fraction Donly','Scatter','Background','R0 [A]','TauD0 [ns]','IRF Shift'};
Parameters{8} = {'Center R1 [A]','Sigma R1 [A]','Center R2 [A]','Sigma R2 [A]','Fraction 1','Fraction Donly','Scatter','Background','R0 [A]','TauD(R0) [ns]','TauD01 [ns]','TauD02 [ns]','Fraction TauD01','IRF Shift'};
Parameters{9} = {'Center R1 [A]','Sigma R1 [A]','Center R2 [A]','Sigma R2 [A]','Fraction 1','Fraction Donly','Scatter','Background','R0 [A]','TauD(R0) [ns]','TauD01 [ns]','TauD02 [ns]','Fraction TauD01','Scatter Donly','Background Donly','IRF Shift'};
Parameters{10} = {'Tau [ns]','Rho [ns]','r0','r_infinity','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};
Parameters{11} = {'Tau1 [ns]','Tau2 [ns]','Fraction 1','Rho [ns]','r0','r_infinity','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};
Parameters{12} = {'Tau [ns]','Rho1 [ns]','Rho2 [ns]','r0','r2','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};
Parameters{13} = {'Tau1 [ns]','Tau2 [ns]','Fraction 1','Rho1 [ns]','Rho2 [ns]','r0','r2','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};
Parameters{14} = {'Tau1 [ns]','Tau2 [ns]','Fraction 1','Rho1 [ns]','Rho2 [ns]','r0','r_infinity1','r_infinity2','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};

%%% ToolTipString
ToolTip = cell(14,1);
ToolTip{1} = '';
ToolTip{2} = '';
ToolTip{3} = '';
ToolTip{4} = '';
ToolTip{5} = '';
ToolTip{6} = '';
ToolTip{7} = '';
ToolTip{8} = '';
ToolTip{9} = sprintf('Global fit of DA and DO samples.\nTauD0(R0) is the donor lifetime of the sample used to determine the given R0.');
ToolTip{10} = '';
ToolTip{11} = '';
ToolTip{12} = '';
ToolTip{13} = '';
ToolTip{14} = '';
%%% Initial Data - Store the StartValues as well as LB and UB
tau1 = UserValues.TauFit.FitParams{chan}(1);
tau2 = UserValues.TauFit.FitParams{chan}(2);
tau3 = UserValues.TauFit.FitParams{chan}(3);
tau4 = UserValues.TauFit.FitParams{chan}(4);
F1 = UserValues.TauFit.FitParams{chan}(5);
F2 = UserValues.TauFit.FitParams{chan}(6);
F3 = UserValues.TauFit.FitParams{chan}(7);
ScatPar = UserValues.TauFit.FitParams{chan}(8);
ScatPer = UserValues.TauFit.FitParams{chan}(9);
BackPar = UserValues.TauFit.FitParams{chan}(10);
BackPer = UserValues.TauFit.FitParams{chan}(11);

IRF = UserValues.TauFit.IRFShift{chan};

R0 = UserValues.TauFit.FitParams{chan}(13);
tauD0 = UserValues.TauFit.FitParams{chan}(14);
l1 = UserValues.TauFit.FitParams{chan}(15);
l2 = UserValues.TauFit.FitParams{chan}(16);
Rho1 = UserValues.TauFit.FitParams{chan}(17);
Rho2 = UserValues.TauFit.FitParams{chan}(18);
r0 = UserValues.TauFit.FitParams{chan}(19);
rinf = UserValues.TauFit.FitParams{chan}(20);
R = UserValues.TauFit.FitParams{chan}(21);
sigR = UserValues.TauFit.FitParams{chan}(22);
FD0 = UserValues.TauFit.FitParams{chan}(23);
rinf2 = UserValues.TauFit.FitParams{chan}(24);
beta = UserValues.TauFit.FitParams{chan}(25);
R2 = UserValues.TauFit.FitParams{chan}(26);
sigR2 = UserValues.TauFit.FitParams{chan}(27);
tauD_R0 = UserValues.TauFit.FitParams{chan}(28);

tau1f = UserValues.TauFit.FitFix{chan}(1);
tau2f = UserValues.TauFit.FitFix{chan}(2);
tau3f = UserValues.TauFit.FitFix{chan}(3);
tau4f = UserValues.TauFit.FitFix{chan}(4);
F1f = UserValues.TauFit.FitFix{chan}(5);
F2f = UserValues.TauFit.FitFix{chan}(6);
F3f = UserValues.TauFit.FitFix{chan}(7);
ScatParf = UserValues.TauFit.FitFix{chan}(8);
ScatPerf = UserValues.TauFit.FitFix{chan}(9);
BackParf = UserValues.TauFit.FitFix{chan}(10);
BackPerf = UserValues.TauFit.FitFix{chan}(11);
IRFf = UserValues.TauFit.FitFix{chan}(12);
R0f = UserValues.TauFit.FitFix{chan}(13);
tauD0f = UserValues.TauFit.FitFix{chan}(14);
l1f = UserValues.TauFit.FitFix{chan}(15);
l2f = UserValues.TauFit.FitFix{chan}(16);
Rho1f = UserValues.TauFit.FitFix{chan}(17);
Rho2f = UserValues.TauFit.FitFix{chan}(18);
r0f = UserValues.TauFit.FitFix{chan}(19);
rinff = UserValues.TauFit.FitFix{chan}(20);
Rf = UserValues.TauFit.FitFix{chan}(21);
sigRf = UserValues.TauFit.FitFix{chan}(22);
FD0f = UserValues.TauFit.FitFix{chan}(23);
rinf2f = UserValues.TauFit.FitFix{chan}(24);
betaf = UserValues.TauFit.FitFix{chan}(25);
R2f = UserValues.TauFit.FitFix{chan}(26);
sigR2f = UserValues.TauFit.FitFix{chan}(27);
tauD_R0f = UserValues.TauFit.FitFix{chan}(28);

StartPar = cell(7,1);
StartPar{1} = {tau1,0,Inf,tau1f;ScatPar,0,Inf,ScatParf;BackPar,0,Inf,BackParf;IRF,-Inf,Inf,IRFf};
StartPar{2} = {tau1,0,Inf,tau1f;tau2,0,Inf,tau2f;F1,0,1,F1f;ScatPar,0,Inf,ScatParf;BackPar,0,Inf,BackParf;IRF,-Inf,Inf,IRFf};
StartPar{3} = {tau1,0,Inf,tau1f;tau2,0,Inf,tau2f;tau3,0,Inf,tau3f;F1,0,1,F1f;F2,0,1,F2f;ScatPar,0,Inf,ScatParf;BackPar,0,Inf,BackParf;IRF,-Inf,Inf,IRFf};
StartPar{4} = {tau1,0,Inf,tau1f;tau2,0,Inf,tau2f;tau3,0,Inf,tau3f;tau4,0,Inf,tau4f;F1,0,1,F1f;F2,0,1,F2f;F3,0,1,F3f;ScatPar,0,Inf,ScatParf;BackPar,0,Inf,BackParf;IRF,-Inf,Inf,IRFf};
StartPar{5} = {tau1,0,Inf,tau1f;beta,0,Inf,betaf;ScatPar,0,Inf,ScatParf;BackPar,0,Inf,BackParf;IRF,-Inf,Inf,IRFf};
StartPar{6} = {R,0,Inf,Rf;sigR,0,Inf,sigRf;ScatPar,0,Inf,ScatParf;BackPar,0,Inf,BackParf;R0,0,Inf,R0f;tauD0,0,Inf,tauD0f;IRF,-Inf,Inf,IRFf};
StartPar{7} = {R,0,Inf,Rf;sigR,0,Inf,sigRf;FD0,0,1,FD0f;ScatPar,0,Inf,ScatParf;BackPar,0,Inf,BackParf;R0,0,Inf,R0f;tauD0,0,Inf,tauD0f;IRF,-Inf,Inf,IRFf};
StartPar{8} = {R,0,Inf,Rf;sigR,0,Inf,sigRf;R2,0,Inf,R2f;sigR2,0,Inf,sigR2f;F1,0,1,F1f;FD0,0,1,FD0f;ScatPar,0,Inf,ScatParf;BackPar,0,Inf,BackParf;R0,0,Inf,R0f;tauD_R0,0,Inf,tauD_R0f;tauD0,0,Inf,tauD0f;tau2,0,Inf,tau2f;F2,0,1,F2f;IRF,-Inf,Inf,IRFf};
StartPar{9} = {R,0,Inf,Rf;sigR,0,Inf,sigRf;R2,0,Inf,R2f;sigR2,0,Inf,sigR2f;F1,0,1,F1f;FD0,0,1,FD0f;ScatPar,0,Inf,ScatParf;BackPar,0,Inf,BackParf;R0,0,Inf,R0f;tauD_R0,0,Inf,tauD_R0f;tauD0,0,Inf,tauD0f;tau2,0,Inf,tau2f;F2,0,1,F2f;ScatPer,0,Inf,ScatPerf;BackPer,0,Inf,BackPerf;IRF,-Inf,Inf,IRFf};
StartPar{10} = {tau1,0,Inf,tau1f;Rho1,0,Inf,Rho1f;r0,0,0.4,r0f;rinf,0,0.4,rinff;ScatPar,0,Inf,ScatParf;ScatPer,0,Inf,ScatPerf...
    ;BackPar,0,Inf,BackParf;BackPer,0,Inf,BackPerf;l1,0,1,l1f;l2,0,1,l2f;IRF,-Inf,Inf,IRFf};
StartPar{11} = {tau1,0,Inf,tau1f;tau2,0,Inf,tau2f;F1,0,1,F1f;Rho1,0,Inf,Rho1f;r0,0,0.4,r0f;rinf,0,0.4,rinff;ScatPar,0,Inf,ScatParf;ScatPer,0,Inf,ScatPerf...
    ;BackPar,0,Inf,BackParf;BackPer,0,Inf,BackPerf;l1,0,1,l1f;l2,0,1,l2f;IRF,-Inf,Inf,IRFf};
StartPar{12} = {tau1,0,Inf,tau1f;Rho1,0,Inf,Rho1f;Rho2,0,Inf,Rho2f;r0,0,0.4,r0f;rinf,0,0.4,rinff;ScatPar,0,Inf,ScatParf;ScatPer,0,Inf,ScatPerf...
    ;BackPar,0,Inf,BackParf;BackPer,0,Inf,BackPerf;l1,0,1,l1f;l2,0,1,l2f;IRF,-Inf,Inf,IRFf};
StartPar{13} = {tau1,0,Inf,tau1f;tau2,0,Inf,tau2f;F1,0,1,F1f;Rho1,0,Inf,Rho1f;Rho2,0,Inf,Rho2f;r0,0,0.4,r0f;rinf,0,0.4,rinff;ScatPar,0,Inf,ScatParf;ScatPer,0,Inf,ScatPerf...
    ;BackPar,0,Inf,BackParf;BackPer,0,Inf,BackPerf;l1,0,1,l1f;l2,0,1,l2f;IRF,-Inf,Inf,IRFf};
StartPar{14} = {tau1,0,Inf,tau1f;tau2,0,Inf,tau2f;F1,0,1,F1f;Rho1,0,Inf,Rho1f;Rho2,0,Inf,Rho2f;r0,0,0.4,r0f;rinf,0,0.4,rinff;rinf2,0,0.4,rinf2f;ScatPar,0,Inf,ScatParf;ScatPer,0,Inf,ScatPerf...
    ;BackPar,0,Inf,BackParf;BackPer,0,Inf,BackPerf;l1,0,1,l1f;l2,0,1,l2f;IRF,-Inf,Inf,IRFf};

startpar = StartPar{model};
names = Parameters{model};
tooltipstring = ToolTip{model};

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
UserValues.TauFit.WeightedResidualsType = h.WeightedResidualsType_Menu.String{h.WeightedResidualsType_Menu.Value};

if obj == h.G_factor_edit
    %DetermineGFactor(obj)
end
if strcmp(TauFitData.Who,'Burstwise') && obj == h.Save_Figures
    UserValues.BurstSearch.BurstwiseLifetime_SaveImages = obj.Value;
    LSUserValues(1);
end
UserValues.TauFit.ConvolutionType = h.ConvolutionType_Menu.String{h.ConvolutionType_Menu.Value};
UserValues.TauFit.LineStyle = h.LineStyle_Menu.String{h.LineStyle_Menu.Value};

if strcmp(TauFitData.Who,'Burstwise') && obj ==  h.Calc_Burstwise_Phasor
    UserValues.BurstSearch.CalculateBurstwisePhasor = obj.Value;
    if UserValues.BurstSearch.CalculateBurstwisePhasor == 1
        h.Select_Burstwise_Phasor_Reference.Visible = 'on';
    else
        h.Select_Burstwise_Phasor_Reference.Visible = 'off';
    end
end
if strcmp(TauFitData.Who,'Burstwise') && obj == h.Select_Burstwise_Phasor_Reference
    UserValues.BurstSearch.PhasorReference = obj.Value;
end
if obj == h.LineStyle_Menu
    ChangeLineStyle(h);
end
if h.ShowAniso_radiobutton.Value == 1
    Update_Plots(h.ShowAniso_radiobutton,[]);
elseif h.ShowDecaySum_radiobutton.Value == 1
    Update_Plots(h.ShowDecaySum_radiobutton,[]);
end
switch obj
    case h.Cleanup_IRF_Menu
        UserValues.TauFit.cleanup_IRF = obj.Value;
    case h.UseWeightedResiduals_Menu
        UserValues.TauFit.use_weighted_residuals = obj.Value;
end
if isfield(h,'DonorOnlyReference_Popupmenu')
    if obj == h.DonorOnlyReference_Popupmenu
        UserValues.TauFit.DonorOnlyReferenceSource = obj.Value;
    end
end
if obj == h.Rebin_Histogram_Edit
    %%% round value
    new_res = str2double(h.Rebin_Histogram_Edit.String);
    if ~isfinite(new_res)
        new_res = 1;
    end
    if new_res < 1
        new_res = 1;
    end
    h.Rebin_Histogram_Edit.String = num2str(new_res);
    if ~isfield(TauFitData,'OriginalHistograms')
        % first, copy original data so it is not lost
        TauFitData.OriginalHistograms.hMI_Par= TauFitData.hMI_Par;
        TauFitData.OriginalHistograms.hMI_Per= TauFitData.hMI_Per;
        TauFitData.OriginalHistograms.hIRF_Par = TauFitData.hIRF_Par;
        TauFitData.OriginalHistograms.hIRF_Per = TauFitData.hIRF_Per;
        TauFitData.OriginalHistograms.hScat_Par = TauFitData.hScat_Par;
        TauFitData.OriginalHistograms.hScat_Per = TauFitData.hScat_Per;
        TauFitData.OriginalHistograms.TACChannelWidth = TauFitData.TACChannelWidth;
        %%% also apply to donor only
        if strcmp(TauFitData.Who,'External')
            if isfield(TauFitData.External,'Donly')
               TauFitData.OriginalHistograms.Donly = TauFitData.External.Donly;
            end
        end
    end
    if new_res > 1
        %%% Rebin histogram in TauFitData
        for i = 1:numel(TauFitData.OriginalHistograms.hMI_Par) % loop over all channels
            TauFitData.hMI_Par{i} = downsamplebin(TauFitData.OriginalHistograms.hMI_Par{i},new_res);
            TauFitData.hMI_Per{i} = downsamplebin(TauFitData.OriginalHistograms.hMI_Per{i},new_res);
            TauFitData.hIRF_Par{i} = downsamplebin(TauFitData.OriginalHistograms.hIRF_Par{i},new_res)';
            TauFitData.hIRF_Per{i} = downsamplebin(TauFitData.OriginalHistograms.hIRF_Per{i},new_res)';
            TauFitData.hScat_Par{i} = downsamplebin(TauFitData.OriginalHistograms.hScat_Par{i},new_res)';
            TauFitData.hScat_Per{i} = downsamplebin(TauFitData.OriginalHistograms.hScat_Per{i},new_res)';
            TauFitData.XData_Par{i} = 1:numel(TauFitData.hMI_Par{i});
            TauFitData.XData_Per{i} = 1:numel(TauFitData.hMI_Per{i});
            %%% also apply to donor only
            if strcmp(TauFitData.Who,'External')
                if isfield(TauFitData.External,'Donly')
                    if ~isempty(TauFitData.External.Donly{i})
                        TauFitData.External.Donly{i} = downsamplebin(TauFitData.OriginalHistograms.Donly{i},new_res)';
                    end
                end
            end
        end
        TauFitData.TACChannelWidth = new_res*TauFitData.OriginalHistograms.TACChannelWidth;
    elseif new_res == 1
        % copy old data back
        for i = 1:numel(TauFitData.OriginalHistograms.hMI_Par) % loop over all channels
            TauFitData.hMI_Par{i} = TauFitData.OriginalHistograms.hMI_Par{i};
            TauFitData.hMI_Per{i} = TauFitData.OriginalHistograms.hMI_Per{i};
            TauFitData.hIRF_Par{i} = TauFitData.OriginalHistograms.hIRF_Par{i};
            TauFitData.hIRF_Per{i} = TauFitData.OriginalHistograms.hIRF_Per{i};
            TauFitData.hScat_Par{i} = TauFitData.OriginalHistograms.hScat_Par{i};
            TauFitData.hScat_Per{i} = TauFitData.OriginalHistograms.hScat_Per{i};
            TauFitData.XData_Par{i} = 1:numel(TauFitData.hMI_Par{i});
            TauFitData.XData_Per{i} = 1:numel(TauFitData.hMI_Per{i});
            %%% also apply to donor only
            if strcmp(TauFitData.Who,'External')
                if isfield(TauFitData.External,'Donly')
                    if ~isempty(TauFitData.External.Donly{i})
                        TauFitData.External.Donly{i} = TauFitData.OriginalHistograms.Donly{i};
                    end
                end
            end
        end
        TauFitData.TACChannelWidth = TauFitData.OriginalHistograms.TACChannelWidth;
    end
    %%% Update Plots
    Update_Plots(h.Rebin_Histogram_Edit,[]);
    %%% Update UserValues
    UserValues.TauFit.RebinFactor = new_res;
end
LSUserValues(1);



function ChangeLineStyle(h)
global UserValues
switch UserValues.TauFit.LineStyle
    case 'line'
        set([h.Plots.DecayResult,h.Plots.DecayResult_ignore,h.Plots.DecayResult_Perp,h.Plots.DecayResult_Perp_ignore,h.Plots.AnisoResult,h.Plots.AnisoResult_ignore,h.Plots.IRFResult,h.Plots.IRFResult_Perp],...
            'Marker','none','LineStyle','-');
    case 'dots'
        set([h.Plots.DecayResult,h.Plots.DecayResult_ignore,h.Plots.DecayResult_Perp,h.Plots.DecayResult_Perp_ignore,h.Plots.AnisoResult,h.Plots.AnisoResult_ignore,h.Plots.IRFResult,h.Plots.IRFResult_Perp],...
            'Marker','.','LineStyle','none');
end

function IncludeChannel(obj,~)
global UserValues
h = guidata(findobj('Tag','TauFit'));
LSUserValues(0);
UserValues.TauFit.IncludeChannel(h.ChannelSelect_Popupmenu.Value) = h.IncludeChannel_checkbox.Value;
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Export function for various export requests %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export(obj,~)
global UserValues TauFitData FileInfo BurstData BurstMeta
h = guidata(findobj('Tag','TauFit'));
switch obj
    case {h.Menu.Export_MIPattern_Fit, h.Menu.Export_MIPattern_Data}
        %%% export the fitted microtime pattern for use in fFCS filter
        %%% generation
        
        %%% update the plot by evaluating the model with current parameter
        %%% values
        % fix all parameters and store fixed state
        %fixed_old = h.FitPar_Table.Data(1:end-1,4);
        %h.FitPar_Table.Data(1:end-1,4) = num2cell(true(size(h.FitPar_Table.Data,1)-1,1));
        % evaluate
        %Start_Fit(h.Fit_Button,[]);
        % reset table
        %h.FitPar_Table.Data(1:end-1,4) = fixed_old;
        
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
                switch obj
                    case h.Menu.Export_MIPattern_Fit
                        mi_pattern(UserValues.PIE.From(PIEchannel) + ((TauFitData.StartPar{TauFitData.chan}+1):TauFitData.Length{TauFitData.chan})) = TauFitData.FitResult;
                    case h.Menu.Export_MIPattern_Data
                        mi_pattern(UserValues.PIE.From(PIEchannel) + ((TauFitData.StartPar{TauFitData.chan}+1):TauFitData.Length{TauFitData.chan})) = TauFitData.FitData.Decay_Par;
                end
                % define output
                MIPattern = cell(0);
                MIPattern{UserValues.PIE.Detector(PIEchannel),UserValues.PIE.Router(PIEchannel)}=mi_pattern;
                
            else % two different channels selected
                if obj == h.Menu.Export_MIPattern_Fit
                    % check if anisotropy model is selected
                    if isempty(strfind(TauFitData.FitType,'Anisotropy'))
                        disp('Select an anisotropy model.');
                        return;
                    end
                end
                % two PIE channels selected
                PIEchannel1 = h.PIEChannelPar_Popupmenu.String{h.PIEChannelPar_Popupmenu.Value};
                PIEchannel1 = find(strcmp(UserValues.PIE.Name,PIEchannel1)); % convert name to number
                PIEchannel2 = h.PIEChannelPer_Popupmenu.String{h.PIEChannelPer_Popupmenu.Value};
                PIEchannel2 = find(strcmp(UserValues.PIE.Name,PIEchannel2)); % convert name to number
                
                % reconstruct mi patterns
                mi_pattern1 = zeros(FileInfo.MI_Bins,1);
                mi_pattern2 = zeros(FileInfo.MI_Bins,1);
                switch obj
                    case h.Menu.Export_MIPattern_Fit
                        mi_pattern1(UserValues.PIE.From(PIEchannel1) + ((TauFitData.StartPar{TauFitData.chan}+1):TauFitData.Length{TauFitData.chan})) = TauFitData.FitResult(1,:);
                        mi_pattern2(UserValues.PIE.From(PIEchannel2) - TauFitData.ShiftPer{TauFitData.chan} + ((TauFitData.StartPar{TauFitData.chan}+1):TauFitData.Length{TauFitData.chan})) = TauFitData.FitResult(2,:);
                    case h.Menu.Export_MIPattern_Data
                        mi_pattern1(UserValues.PIE.From(PIEchannel1) + ((TauFitData.StartPar{TauFitData.chan}+1):TauFitData.Length{TauFitData.chan})) = TauFitData.FitData.Decay_Par;
                        mi_pattern2(UserValues.PIE.From(PIEchannel2) - TauFitData.ShiftPer{TauFitData.chan} + ((TauFitData.StartPar{TauFitData.chan}+1):TauFitData.Length{TauFitData.chan})) = TauFitData.FitData.Decay_Per;
                end
                % define output
                MIPattern = cell(0);
                MIPattern{UserValues.PIE.Detector(PIEchannel1),UserValues.PIE.Router(PIEchannel1)}=mi_pattern1;
                MIPattern{UserValues.PIE.Detector(PIEchannel2),UserValues.PIE.Router(PIEchannel2)}=mi_pattern2;
                
                PIEchannel = PIEchannel1;
            end
            FileName = FileInfo.FileName{1};
            [~, FileName, ~] = fileparts(FileName);
            if obj == h.Menu.Export_MIPattern_Fit
                FileName = [FileName '_fit'];
            end
            Path = FileInfo.Path;
            % save
            [File, Path] = uiputfile('*.mi', 'Save Microtime Pattern', fullfile(Path,FileName));
            if all(File==0)
                return
            end
            %%% previously, the microtime pattern was stored as MATLAB file
            % save(fullfile(Path,File),'MIPattern');
            %%% Now,it is saved as a text file for easier readability
            %%% write header
            fid = fopen(fullfile(Path,File),'w');
            fprintf(fid,'Microtime patterns of measurement: %s\n',FileName);
            %%% write detector - routing assigment
            fprintf(fid,'Channel %i: Detector %i and Routing %i\n',1,UserValues.PIE.Detector(PIEchannel),UserValues.PIE.Router(PIEchannel));
            if exist('PIEchannel2','var')
                fprintf(fid,'Channel %i: Detector %i and Routing %i\n',2,UserValues.PIE.Detector(PIEchannel2),UserValues.PIE.Router(PIEchannel2));
            end
            fclose(fid);
            dlmwrite(fullfile(Path,File),horzcat(MIPattern{:}),'-append','delimiter',',');
        elseif strcmp(TauFitData.Who,'BurstBrowser')
            % we came here from BurstBrowser
            
            % the only option to consider here is an anisotropy fit
            % (maybe implement later to only fit par or per channel)
            
            % check if anisotropy model is selected
            if TauFitData.BAMethod ~= 5
                if isempty(strfind(TauFitData.FitType,'Anisotropy'))
                    disp('Select an anisotropy model.');
                    return;
                end
            end
            
            chan = h.ChannelSelect_Popupmenu.Value;
            switch TauFitData.BAMethod
                case {1,2}
                    switch chan
                        case 1 % GG
                            Par = 1; Per = 2;
                        case 2 % RR
                            Par = 5; Per = 6;
                    end
                    chan_names = {'GG','RR'};
                case {3,4}
                    switch chan
                        case 1 % BB
                            Par = 1; Per = 2;
                        case 2 % GG
                            Par = 7; Per = 8;
                        case 3 % RR
                            Par = 11; Per = 12;
                    end
                    chan_names = {'BB','GG','RR'};
                case 5
                    switch chan
                        case 1 %GG
                            Par = 1;
                        case 2 %RR
                            Par = 3;
                    end
                    chan_names = {'GG','RR'};
            end
            
            % reconstruct mi pattern
            mi_pattern1 = zeros(TauFitData.FileInfo.MI_Bins,1);
            switch obj
                case h.Menu.Export_MIPattern_Fit
                    mi_pattern1(TauFitData.PIE.From(Par) + ((TauFitData.StartPar{chan}+1):TauFitData.Length{chan})) = TauFitData.FitResult(1,:);
                    if TauFitData.BAMethod ~= 5
                        mi_pattern2 = zeros(TauFitData.FileInfo.MI_Bins,1);
                        mi_pattern2(TauFitData.PIE.From(Per) + ((TauFitData.StartPar{chan}+1):TauFitData.Length{chan})) = TauFitData.FitResult(2,:);
                        mi_pattern2 = shift_by_fraction(mi_pattern2,-TauFitData.ShiftPer{chan});
                    end
                case h.Menu.Export_MIPattern_Data
                    mi_pattern1(TauFitData.PIE.From(Par) + ((TauFitData.StartPar{chan}+1):TauFitData.Length{chan})) = TauFitData.FitData.Decay_Par;
                    if TauFitData.BAMethod ~= 5
                        mi_pattern2 = zeros(TauFitData.FileInfo.MI_Bins,1);
                        mi_pattern2(TauFitData.PIE.From(Per) + ((TauFitData.StartPar{chan}+1):TauFitData.Length{chan})) = TauFitData.FitData.Decay_Per;
                        mi_pattern2 = shift_by_fraction(mi_pattern2,-TauFitData.ShiftPer{chan});
                    end
            end
            % define output
            MIPattern = cell(0);
            MIPattern{TauFitData.PIE.Detector(Par),TauFitData.PIE.Router(Par)}=mi_pattern1;
            if TauFitData.BAMethod ~= 5
                MIPattern{TauFitData.PIE.Detector(Per),TauFitData.PIE.Router(Per)}=mi_pattern2;
            end
            
            FileName = matlab.lang.makeValidName(TauFitData.SpeciesName);
            Path = TauFitData.Path;
            if obj == h.Menu.Export_MIPattern_Fit
                FileName = [FileName '_fit'];
            end
            % save
            [File, Path] = uiputfile('*.mi', 'Save Microtime Pattern', fullfile(Path,FileName));
            if all(File==0)
                return
            end
            %%% previously, the microtime pattern was stored as MATLAB file
            % save(fullfile(Path,File),'MIPattern');
            %%% Now,it is saved as a text file for easier readability
            %%% write header
            fid = fopen(fullfile(Path,File),'w');
            fprintf(fid,'Microtime patterns of measurement: %s\n',FileName);
            %%% write detector - routing assigment
            fprintf(fid,'Channel %i: Detector %i and Routing %i\n',1,TauFitData.PIE.Detector(Par),TauFitData.PIE.Router(Par));
            if TauFitData.BAMethod ~= 5
                fprintf(fid,'Channel %i: Detector %i and Routing %i\n',2,TauFitData.PIE.Detector(Per),TauFitData.PIE.Router(Per));
            end
            fclose(fid);
            dlmwrite(fullfile(Path,File),horzcat(MIPattern{:}),'-append','delimiter',',');
        end
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
        %%% Exports the total region of the data, but only the non-ignore
        %%% region of the fit
        if h.Result_Plot.Parent == h.HidePanel % no fit has been performed
            disp('Fit the data first');
            return;
        end
        
        if (h.Result_Plot_Aniso.Parent == h.HidePanel) %%% no anisotropy reconvolution fit
            time = [h.Plots.DecayResult_ignore.XData, h.Plots.DecayResult.XData]; %time = time-time(1);
            data = [h.Plots.DecayResult_ignore.YData,h.Plots.DecayResult.YData];
            fit =  [NaN(1,numel(h.Plots.DecayResult_ignore.XData)),h.Plots.FitResult.YData];
            res = [NaN(1,numel(h.Plots.DecayResult_ignore.XData)),h.Plots.Residuals.YData];
            if strcmp(h.Result_Plot.YLabel.String,'Anisotropy')
                names = {'time_ns','anisotropy','fit','wres'};
                ext = '_aniso';
            else
                names = {'time_ns','intensity','fit','wres'};
                ext = '_tau';
            end
            tab = table(time',data',fit',res','VariableNames',names);
        else
            if ~strfind(h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value},'Distribution')
                %%% anisotropy reconvolution fit
                time = h.Plots.DecayResult.XData; %time = time-time(1);
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
            else
                %%% anisotropy reconvolution fit
                time = h.Plots.DecayResult.XData; %time = time-time(1);
                data_par = h.Plots.DecayResult.YData;
                data_per = h.Plots.DecayResult_Perp.YData;
                fit_par =  h.Plots.FitResult.YData;
                fit_per =  h.Plots.FitResult_Perp.YData;
                res_par = h.Plots.Residuals.YData;
                res_per = h.Plots.Residuals_Perp.YData;
                r = h.Plots.FitAnisoResult.XData;
                dist = h.Plots.FitAnisoResult.YData;
                % interpolate distance distribution to same number as time axis
                ri = linspace(r(1),r(end),numel(time));
                dist_i = interp1(r,dist,ri);
                names = {'time_ns','intensity_par','intensity_per','fit_par','fit_per','wres_par','wres_per','distance','prob_distance'};
                tab = table(time',data_par',data_per',fit_par',fit_per',res_par',res_per',ri',dist_i','VariableNames',names);
                ext = '_tau_dist';
            end
        end
        %%% get path
        if ~strcmp(TauFitData.Who,'BurstBrowser')
            [path,filename,~] = fileparts(TauFitData.FileName);
        else
            path = fullfile(TauFitData.Path,'..');
            filename = strsplit(TauFitData.FileName,'.'); filename = filename{1};
        end
        if isfield(TauFitData,'SpeciesName')
            filename = [filename '_' TauFitData.SpeciesName];
        end
        if strcmp(TauFitData.Who,'BurstBrowser')
            filename = [filename '_' h.ChannelSelect_Popupmenu.String{h.ChannelSelect_Popupmenu.Value}];
        else
            %%% add PIE channel names
            filename = [filename '_' h.PIEChannelPar_Popupmenu.String{h.PIEChannelPar_Popupmenu.Value} '-' h.PIEChannelPer_Popupmenu.String{h.PIEChannelPer_Popupmenu.Value}];
        end
        filename = strrep(filename,' - ','-');
        filename = strrep(filename,' ','_');
        [filename, pathname, FilterIndex] = uiputfile('*.csv','Save *.csv file',[path filesep filename ext '.csv']);
        if FilterIndex == 0
            return;
        end
        %%% check that the extension has not been deleted by the user!
        %%% if it has, readd
        if ~contains(filename,ext)
            filename = [filename(1:end-4) ext '.txt'];
        end
        writetable(tab,fullfile(pathname,filename));
        UserValues.File.TauFitPath = pathname;
    case h.Menu.Save_To_Dec
        %%% saves data to *.dec file which can be loaded again into TauFit
        %%%
        %%% format:
        %%% header
        %%% channel
        %%% Decay IRF scatter
        if strcmp(TauFitData.Who,'External')
            disp('Already using external data, no need to save it again.');
            return;
        end
        %%% get path and filename
        if ~strcmp(TauFitData.Who,'BurstBrowser')
            [path,filename,~] = fileparts(TauFitData.FileName);
        else
            path = fullfile(TauFitData.Path,'..');
            filename = strsplit(TauFitData.FileName,'.'); filename = filename{1};
        end
        if isfield(TauFitData,'SpeciesName')
            filename = [filename '_' TauFitData.SpeciesName];
        end
        if strcmp(TauFitData.Who,'BurstBrowser')
            %%% channel names
            switch TauFitData.BAMethod
                case {1,2} % 2color MFD
                    chan_names = {'DD1','DD2','AA1','AA2','DA1','DA2'};
                case {3,4} % 3color MFD
                    chan_names = {'BB1','BB2','GG1','GG2','RR1','RR2'};
                case 5 % 2color noMFD
                    chan_names = {'DD','AA','DA'};
            end
        else
            %%% PIE channel names
            chan_names = h.PIEChannelPar_Popupmenu.String;
        end
        filename = strrep(filename,' - ','-');
        filename = strrep(filename,' ','_');
        [filename, pathname, FilterIndex] = uiputfile('*.dec','Save *.dec file',[path filesep filename '.dec']);
        if FilterIndex == 0
            return;
        end
        %%% assemble microtime histograms
        microtimeHistograms = zeros(TauFitData.FileInfo.MI_Bins,3*numel(chan_names));
        if strcmp(TauFitData.Who,'BurstBrowser')
            switch TauFitData.BAMethod
                case {1,2,3,4}
                    switch TauFitData.BAMethod
                        case {1,2}
                            from = TauFitData.PIE.From([1,2,5,6,3,4]);
                            to = TauFitData.PIE.To([1,2,5,6,3,4]);
                            if numel(TauFitData.hMI_Par) == 4
                                % donor only is defined, add also
                                from = [from TauFitData.PIE.From([1,2])];
                                to = [to TauFitData.PIE.To([1,2])];
                                chan_names(end+1:end+2) = {'DOnly1','DOnly2'};
                                microtimeHistograms = [microtimeHistograms, zeros(TauFitData.FileInfo.MI_Bins,3)];
                            end
                        case {3,4}
                            from = TauFitData.PIE.From([1,2,7,8,11,12]);
                            to = TauFitData.PIE.To([1,2,7,8,11,12]);
                    end
                    c = 1;
                    for i = 1:2:numel(chan_names)
                        range = from(i):to(i);
                        microtimeHistograms(range,3*(i-1)+1) = TauFitData.hMI_Par{c};
                        microtimeHistograms(range,3*(i-1)+2) = TauFitData.hIRF_Par{c};
                        microtimeHistograms(range,3*(i-1)+3) = TauFitData.hScat_Par{c};
                        range = from(i+1):to(i+1);
                        microtimeHistograms(range,3*(i)+1) = TauFitData.hMI_Per{c};
                        microtimeHistograms(range,3*(i)+2) = TauFitData.hIRF_Per{c};
                        microtimeHistograms(range,3*(i)+3) = TauFitData.hScat_Per{c};
                        c = c+1;
                    end
                case 5
            end
        else
            for i = 1:numel(chan_names)
                range = TauFitData.PIE.From(i):TauFitData.PIE.To(i);
                microtimeHistograms(range,3*(i-1)+1) = TauFitData.hMI{i};
                microtimeHistograms(range,3*(i-1)+2) = TauFitData.hIRF{i};
                microtimeHistograms(range,3*(i-1)+3) = TauFitData.hScat{i};
            end
        end
        %filename = [filename '.dec'];
        fid = fopen(fullfile(pathname,filename),'w');
        %%% write header
        %%% general info
        fprintf(fid,'TAC range [ns]:\t\t %.2f\nMicrotime Bins:\t\t %d\nResolution [ps]:\t %.2f\n\n',...
            1E9*TauFitData.FileInfo.TACRange,TauFitData.FileInfo.MI_Bins,1E12*TauFitData.FileInfo.TACRange/TauFitData.FileInfo.MI_Bins);
        %%% PIE channel names
        for i = 1:numel(chan_names)
            fprintf(fid,'%s\t\t\t',chan_names{i});
        end
        fprintf(fid,'\n');
        for i = 1:numel(chan_names)
            fprintf(fid,'%s\t%s\t%s\t','Decay','IRF','Scatter');
        end
        fprintf(fid,'\n');
        fclose(fid);
        dlmwrite(fullfile(pathname,filename),microtimeHistograms,'-append','delimiter','\t');
    case h.Compare_Result
        %%% load data and make comparison plot
        try
            if ~strcmp(TauFitData.Who,'BurstBrowser')
                [pathname,~,~] = fileparts(TauFitData.FileName);
            else
                pathname = fullfile(TauFitData.Path,'..');
            end
        catch
            pathname = UserValues.File.TauFitPath;
        end
        
        [filename, pathname, FilterIndex] = uigetfile('*.csv','Load lifetime data...',pathname,...
            'MultiSelect','on');
        if FilterIndex == 0
            return;
        end
        UserValues.File.TauFitPath = pathname;
        if ~iscell(filename)
            filename = {filename};
        end
        %%% ensure that same type of data is loaded, remove the rest
        %%% type defined by first selected file
        if iscell(filename)
            valid = ones(numel(filename),1);
            type = strfind(filename{1},'tau');
            if isempty(type)
                type = 'aniso';
            else
                type = strfind(filename{1},'aniso');
                if isempty(type)
                    type = 'tau';
                else
                    type = 'tau_aniso';
                end
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
            switch type
                case {'tau','aniso'}
                    data{i} = dummy(:,2);
                    fit{i} = dummy(:,3);
                case 'tau_aniso'
                    data{i} = dummy(:,8);
                    fit{i} = dummy(:,9);
            end
        end
        dT = mean(diff(dummy(:,1)));
        %%% if different lengths have been loaded, truncate to shortest
        minLength = min(cellfun(@numel,data));
        for i = 1:numel(data)
            data{i} = data{i}(1:minLength);
            fit{i} = fit{i}(1:minLength);
        end
        t = (1:minLength)*dT;
        
        switch type
            case 'tau' %%% normalize and shift if tau data
                for i = 1:numel(data)
                    norm = max(smooth(data{i},10));
                    data{i} = data{i}./norm;
                    fit{i} = fit{i}./norm;
                end
                
                %%% for shift, take first measurement as reference
                [~,peakPosition] = max(smooth(data{1},10));
                shift_left = 0;
                shift_right = 0;
                for i = 2:numel(data)
                    [~,peakPos] = max(smooth(data{i},10));
                    shift_left = min([shift_left, peakPosition-peakPos]);
                    shift_right = max([shift_right, peakPosition-peakPos]);
                    data{i} = circshift(data{i},[peakPosition-peakPos,0]);
                    fit{i} = circshift(fit{i},[peakPosition-peakPos,0]);
                end
                %%% adjust range
                range = (shift_right+1):(minLength+shift_left);
                t = (0:numel(range)-1)*dT;
                for i = 1:numel(data)
                    data{i} = data{i}(range);
                    fit{i} = fit{i}(range);
                end
            case {'aniso','tau_aniso'} %%% modify start point if anisotropy data
                for i = 1:numel(data)
                    [~,peakPos(i)] = max(smooth(data{i}(1:floor(numel(data{i})/4)),20));
                end
                range = max([1,min(peakPos)-10]):minLength;
                t = (0:numel(range)-1)*dT;
                for i = 1:numel(data)
                    data{i} = data{i}(range);
                    fit{i} = fit{i}(range);
                end
        end
        
        
        %%% find max and min data
        minV = min(cellfun(@min,data));
        maxV = max(cellfun(@max,data));
        
        %%% plot data
        hfig = figure('Units','pixels','Position',[100,100,600,400],'Color',[1,1,1]);
        ax = axes('Color',[1,1,1],'LineWidth',1,'Box','on','XGrid','on','YGrid','on','FontSize',20);
        colors = lines(numel(data));
        hold on;
        for i = 1:numel(data)
            plot(t,fit{i},'LineWidth',2,'Color',colors(i,:));
        end
        for i = 1:numel(data)
            plot(t,data{i},'LineStyle','none','Marker','.','Color',colors(i,:));
        end
        for i = 1:numel(filename)
            % remove extension
            filename{i} = filename{i}(1:end-4);
            % replace underscore with space
            filename{i} = strrep(filename{i},'_',' ');
        end
        l = legend(filename);
        
        ax.YLim = [minV-0.1*(maxV-minV) maxV+0.1*(maxV-minV)];
        ax.XLim = [t(1) t(end)];
        xlabel('Time [ns]');
        switch type
            case 'tau'
                ylabel('Intensity [a.u.]');
                ax.YScale = 'log';
            case {'aniso','tau_aniso'}
                ylabel('Anisotropy');
        end
        
        ax.Layer = 'top';
        ax.Units = 'pixels';
        l.Units = 'pixels';
    case h.FitResultToClip
        %%% get fit result from table, concatenate with parameter names and
        %%% copy to clipboard using Mat2clip function
        res = [h.FitPar_Table.RowName,h.FitPar_Table.Data(:,1)];
        if ~all(isnan(TauFitData.ConfInt(:)))
            if size(TauFitData.ConfInt,1) == size(res,1)
                res = [res, num2cell(TauFitData.ConfInt)];
            elseif size(TauFitData.ConfInt,1) > size(res,1)
                res = [res, num2cell(TauFitData.ConfInt(1:size(res,1),:))];
            elseif size(TauFitData.ConfInt,1) < size(res,1)
                res = [res, [num2cell(TauFitData.ConfInt);{NaN,NaN}]];
            end
        end
        %%% add chi2
        res(end+1,:) = {'red. Chi2',TauFitData.Chi2,'',''};
        Mat2clip(res);
    case {h.PlotDynamicFRETLine, h.PlotDynamicFRETLine_Sigma}
        %%% get tau values and plot dynamic FRET line in Burst Browser
        BBgui = guidata(findobj('Tag','BurstBrowser'));
        file = BurstMeta.SelectedFile;
        %%% get lifetimes
        switch TauFitData.FitType
            case 'Biexponential' % biexponential fit
                tau1 = cell2mat(h.FitPar_Table.Data(1,1));
                tau2 = cell2mat(h.FitPar_Table.Data(2,1));
            case {'Two Distributions plus Donor only','Distribution Fit - Global Model'} % two distribution fit
                R1 = cell2mat(h.FitPar_Table.Data(1,1));
                s1 = cell2mat(h.FitPar_Table.Data(2,1));
                R2 = cell2mat(h.FitPar_Table.Data(3,1));
                s2 = cell2mat(h.FitPar_Table.Data(4,1));
               
                R0 = cell2mat(h.FitPar_Table.Data(9,1));
                tau0 = cell2mat(h.FitPar_Table.Data(10,1));
                tauD01 = cell2mat(h.FitPar_Table.Data(11,1));
                tauD02 = cell2mat(h.FitPar_Table.Data(12,1));
                x_tauD01 = cell2mat(h.FitPar_Table.Data(13,1));
                
                tau1 = calc_tauf(R1,s1,R0,[tauD01,tauD02,x_tauD01,tau0]);
                tau2 = calc_tauf(R2,s2,R0,[tauD01,tauD02,x_tauD01,tau0]);
%                 R = 1:1:200;
%                 pR1 = normpdf(R,R1,s1); pR1 = pR1./sum(pR1);
%                 pR2 = normpdf(R,R2,s2); pR2 = pR2./sum(pR2);
%                 k_RET = (1./tau0).*((R0./R).^6); % k_RET as a function of R
%                 t1 = ((1./tauD01) + k_RET).^(-1);
%                 t2 = ((1./tauD02) + k_RET).^(-1);
%                 tau1 = (x_tauD01.*sum(pR1.*t1.^2)+(1-x_tauD01).*sum(pR1.*t2.^2))./...
%                     (x_tauD01.*sum(pR1.*t1)+(1-x_tauD01).*sum(pR1.*t2));
%                 tau2 = (x_tauD01.*sum(pR2.*t1.^2)+(1-x_tauD01).*sum(pR2.*t2.^2))./...
%                     (x_tauD01.*sum(pR2.*t1)+(1-x_tauD01).*sum(pR2.*t2));
            otherwise
                return;
        end
        switch obj
            case h.PlotDynamicFRETLine
                %%% Query using edit box
                data = inputdlg({'Line #','tau1 [ns]','tau2 [ns]'},'Enter State Lifetimes',1,...
                    {num2str(UserValues.BurstBrowser.Settings.DynFRETLine_Line),...
                    num2str(tau1),num2str(tau2)});
            case h.PlotDynamicFRETLine_Sigma
                data = inputdlg({'Line #','R1 [A]','R2 [A]','sigma1 [A]','sigma2 [A]'},'Enter State Distances and Widths',1,...
                    {num2str(UserValues.BurstBrowser.Settings.DynFRETLine_Line),...
                    num2str(R1),num2str(R2)...
                    num2str(s1),num2str(s2)});
        end
        data = cellfun(@str2double,data);
        if any(isnan(data)) || isempty(data)
            return;
        end
        x = data(2:end);
        line = data(1);
        if line < 1 || line > 3
            return;
        end
        % Update UserValues
        UserValues.BurstBrowser.Settings.DynFRETLine_Line = line;
        switch obj
            case h.PlotDynamicFRETLine
                UserValues.BurstBrowser.Settings.DynFRETLineTau1 = x(1);
                UserValues.BurstBrowser.Settings.DynFRETLineTau2 = x(2);
            case h.PlotDynamicFRETLine_Sigma
                UserValues.BurstBrowser.Settings.DynFRETLineR1 = x(1);
                UserValues.BurstBrowser.Settings.DynFRETLineR2 = x(2);
                UserValues.BurstBrowser.Settings.DynFRETLineS1 = x(3);
                UserValues.BurstBrowser.Settings.DynFRETLineS2 = x(4);
        end
        
        switch BBgui.lifetime_ind_popupmenu.Value
            case {5,6} % Phasor plots
                % get channel (donor or acceptor)
                chan = h.lifetime_ind_popupmenu.Value-4;
                % Calculate frequency
                Freq = 1./(BurstData{BurstMeta.SelectedFile}.Phasor.PhasorRange(chan)/BurstData{BurstMeta.SelectedFile}.FileInfo.MI_Bins*BurstData{BurstMeta.SelectedFile}.TACRange*1E9);
                % convert lifetimes to phasor coordinates
                g = 1./(1+(2*pi*Freq*x).^2);
                s = (2*pi*Freq*x).*g;
                x = g; y = s;
                % draw a line through the universal circles
                m = (y(2)-y(1))/(x(2)-x(1)); b = (y(1)*x(2)-y(2)*x(1))/(x(2)-x(1));
                % use p-q formula
                p = (2*m*b-1)/(m^2+1); q = b^2/(m^2+1);
                xp1 = -p/2 - sqrt(p^2/4-q); xp2 =  -p/2 + sqrt(p^2/4-q);
                xp = xp1:0.01:xp2; yp = m*xp+b;
                plot(xp,yp,'--','LineWidth',3,'Color',UserValues.BurstBrowser.Display.ColorLine2,'Parent',BBgui.axes_lifetime_ind_2d);
                BBgui.axes_lifetime_ind_2d.UIContextMenu = BBgui.axes_lifetime_ind_1d_x.UIContextMenu; set(BBgui.axes_lifetime_ind_2d.Children,'UIContextMenu',BBgui.axes_lifetime_ind_1d_x.UIContextMenu);
                return;
        end
        if numel(x) == 2 % binary line with global sigma
            [E, ~,tau] = dynamicFRETline(BurstData{file}.Corrections.DonorLifetime,...
                x(1),x(2),BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength);
        elseif numel(x) == 4 % binary line with individual sigma
            [E, ~,tau] = dynamicFRETline(BurstData{file}.Corrections.DonorLifetime,...
                x(1),x(2),BurstData{file}.Corrections.FoersterRadius,[x(3),x(4)]);
        end
        BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(line).Visible = 'on';
        BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(line).XData = tau;
        BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(line).YData = E;
        PlotLifetimeInd(BBgui.BurstBrowser,[],BBgui);
end


%%% function to fit the selected range of the IRF to a gamma distribution
%%% and extrapolate the IRFpattern from this.
%%% Useful if the IRF contains fluorescent contamination
function IRF_fixed = fix_IRF_gamma_dist(IRF,chan)
global TauFitData
IRF_selected = IRF(1:TauFitData.IRFLength{chan});
x_irf = (1:numel(IRF_selected))';

% the fit model is given by a gamma distribution with an additional
% amplitude (amp) and an associated time-shift (shift)
x0 = [10,10,max(IRF_selected),0];
f = fit(x_irf,IRF_selected,@(a,b,amp,shift,x) amp*gampdf(x+shift,a,b),'StartPoint',x0,'Lower',[0,0,0,-Inf],'Upper',[Inf,Inf,Inf,Inf]);
IRF_fixed = f(1:numel(IRF));

%%% perform display update in settings tab as well, so the user can see
%%% what has been fitted
h = guidata(gcbo);
h.Plots.IRF_cleanup.IRF_data.XData = (1:TauFitData.IRFLength{chan}).*TauFitData.TACChannelWidth;
h.Plots.IRF_cleanup.IRF_data.YData = IRF_selected;
h.Plots.IRF_cleanup.IRF_fit.XData = (1:numel(IRF)).*TauFitData.TACChannelWidth;
h.Plots.IRF_cleanup.IRF_fit.YData = IRF_fixed;
h.Cleanup_IRF_axes.XLim = [0,2*TauFitData.IRFLength{chan}.*TauFitData.TACChannelWidth];


function [tau_dist, tau, model, chi2] = taufit_mem(decay,error,params,static_fit_params,mode,resolution)
global TauFitData UserValues
h = guidata(gcbo);
%%% Maximum Entropy analysis to obtain model-free lifetime distribtion
if nargin < 6
    resolution = 200;
end
I_decay = sum(decay); % store full decay counts for scatter
% remove ignore region from decay
decay = decay(static_fit_params{7}:end);
error = error(static_fit_params{7}:end);
x = 1:1:numel(decay);
Scatter = static_fit_params{3}(static_fit_params{7}:end)';

include_donor_only = false;
biexp_donor_only = false;
switch mode
    case 'tau' % fit lifetime distribution
        %%% vector of lifetimes to consider (up to 10 ns)
        tau = linspace(0,ceil(7.5/TauFitData.TACChannelWidth),resolution);
    case 'dist' % fit distance distribution
        fraction_donly =  UserValues.TauFit.FitParams{TauFitData.chan}(23);
        include_donor_only = strcmp(mode,'dist') && fraction_donly > 0 && (contains(h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value},'plus Donor only') || strcmp(h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value},'Distribution Fit - Global Model'));
        biexp_donor_only = strcmp(h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value},'Distribution Fit - Global Model') || strcmp(h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value},'Two Distributions plus Donor only');
        %%% get F?rster distance and donor-only lifetime
        R0 = params(end-1);
        tauD = params(end)/TauFitData.TACChannelWidth;
        params(end-1:end) = [];
        linear_R = true; % linear R spacing or not
        if linear_R
            R = linspace(10,150,resolution);
        else
            %%% vector of distances to consider (evaluated based on equal spacing in FRET efficiency space)
            R = R0.*(1./linspace(1,0,resolution)-1).^(1/6);
            R = R(1:end-1);
        end
        if ~biexp_donor_only
            %%% calculate respective lifetime vector
            tau = tauD.*(1+(R0./R).^6).^(-1);
        else
            %%% fitting with two donor lifetimes
            % get donor lifetime that belongs to R0
            tau0 = UserValues.TauFit.FitParams{TauFitData.chan}(28)/TauFitData.TACChannelWidth;
            % get second donor-only lifetime and fraction of first lifetime
            tauD2 = UserValues.TauFit.FitParams{TauFitData.chan}(2)/TauFitData.TACChannelWidth; %h.FitPar_Table.Data{12,1}/TauFitData.TACChannelWidth;
            fraction_tauD1 = UserValues.TauFit.FitParams{TauFitData.chan}(6); %h.FitPar_Table.Data{13,1};

            % determine FRET rate
            k_RET = (1./tau0).*(R0./R).^6;
            % determine lifetimes
            tau = (1./tauD+k_RET).^(-1);
            tau2 = (1./tauD2+k_RET).^(-1);
        end
end

%%% remove lifetimes of less than 1 bin
tau_range = tau > 0;
tau = tau(tau_range);
if strcmp(mode,'dist')
    R = R(tau_range);
end
% set background and scatter to zero here and re-add to the
% kernel functions later
bg = params(2); params(2) = 0;
sc = params(1); params(1) = 0;

%%% Establish library of single exponential decays, convoluted with IRF
%%% These should not be area normalized to maintain the correct species
%%% fractions in the MEM analysis!
decay_ind = zeros(numel(tau),numel(x));
if ~(strcmp(mode,'dist') && biexp_donor_only)
    for i = 1:numel(tau)
        decay_ind(i,:) = fitfun_1exp([tau(i),params,TauFitData.I0],static_fit_params);
    end
else
    for i = 1:numel(tau)
        %%% add second donor only lifetime component
        decay_ind(i,:) = fitfun_2exp([tau(i), tau2(i),fraction_tauD1,params,TauFitData.I0],static_fit_params);
    end
end

decay_offset = sc*I_decay*Scatter + bg;
%%% add donor only if parameter of model
if include_donor_only
    if contains(h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value},'plus Donor only')
        %%% consider donor only fraction in model
        decay_donly = fitfun_1exp([tauD,params,TauFitData.I0],static_fit_params);
    elseif strcmp(h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value},'Distribution Fit - Global Model')
        % consider biexponential donor only (without scatter or background of the donor only fit, only lifetimes)
        params_donly = [0,0,params(3)];
        decay_donly = fitfun_2exp([tauD, tauD2, fraction_tauD1,params_donly,TauFitData.I0],static_fit_params);
    end
    % for Tikhonov/MEM
    decay_ind = (1-fraction_donly).*decay_ind;
    decay_offset = decay_offset + fraction_donly.*decay_donly;
end
decay = decay-decay_offset;

%%% initialize p
p0 = ones(numel(tau),1)./numel(tau);
% p0 = p0 + normrnd(0,1,size(p0))*0.01; p0 = p0./sum(p0);
p=p0;

%%% initialize boundaries
Aieq = -eye(numel(p0)); bieq = zeros(numel(p0),1);
lb = zeros(numel(p0),1); ub = inf(numel(p0),1);
%%% boundary condition that sum(p) = 1
Aeq = zeros(numel(p0)); Aeq(1,:) = 1;
beq = zeros(size(p0)); beq(1) = 1;

%%% Use Kalinin MEM algorithm (works and is tested)
MEM_mode = 'Kalinin';%'brute-force' 'Oleg', 'Kalinin'
switch MEM_mode
    case 'Kalinin'
        %%% Algorithm based on the legendary "MATLAB scripts" from
        %%% Stanislav Kalinin used in the Seidel lab
        % Fi: Normalized array of kernel decays (i.e. divided by sigma) - Fi(:,j) is j-th decay
        % sigma: The error estimate assumed to be sqrt(decay) (! This is not true for polarization-combined data !)
        % y: The data (decay)
        
        %%% assign parameters
        y = decay';
        Fi = (decay_ind./repmat(error,length(tau),1))';
        sigma = error';
        
        % parameters
        n = length(tau);
        
        %%% take flat prior
        p =  ones(1,n);
        
        %%% take fitted distribution as prior
        %p = interp1(h.Plots.FitAnisoResult.XData,h.Plots.FitAnisoResult.YData,R);%% initial parameters
        %p(isnan(p)) = 1e-12;
        
        %%% take informative prior from structural ensemble
        %R_ens = [0.394648829431438,0.789297658862876,1.18394648829431,1.57859531772575,1.97324414715719,2.36789297658863,2.76254180602007,3.15719063545151,3.55183946488294,3.94648829431438,4.34113712374582,4.73578595317726,5.13043478260870,5.52508361204013,5.91973244147157,6.31438127090301,6.70903010033445,7.10367892976589,7.49832775919732,7.89297658862876,8.28762541806020,8.68227424749164,9.07692307692308,9.47157190635452,9.86622073578595,10.2608695652174,10.6555183946488,11.0501672240803,11.4448160535117,11.8394648829431,12.2341137123746,12.6287625418060,13.0234113712375,13.4180602006689,13.8127090301003,14.2073578595318,14.6020066889632,14.9966555183946,15.3913043478261,15.7859531772575,16.1806020066890,16.5752508361204,16.9698996655518,17.3645484949833,17.7591973244147,18.1538461538462,18.5484949832776,18.9431438127090,19.3377926421405,19.7324414715719,20.1270903010033,20.5217391304348,20.9163879598662,21.3110367892977,21.7056856187291,22.1003344481605,22.4949832775920,22.8896321070234,23.2842809364549,23.6789297658863,24.0735785953177,24.4682274247492,24.8628762541806,25.2575250836120,25.6521739130435,26.0468227424749,26.4414715719064,26.8361204013378,27.2307692307692,27.6254180602007,28.0200668896321,28.4147157190635,28.8093645484950,29.2040133779264,29.5986622073579,29.9933110367893,30.3879598662207,30.7826086956522,31.1772575250836,31.5719063545151,31.9665551839465,32.3612040133779,32.7558528428094,33.1505016722408,33.5451505016722,33.9397993311037,34.3344481605351,34.7290969899666,35.1237458193980,35.5183946488294,35.9130434782609,36.3076923076923,36.7023411371237,37.0969899665552,37.4916387959866,37.8862876254181,38.2809364548495,38.6755852842809,39.0702341137124,39.4648829431438,39.8595317725753,40.2541806020067,40.6488294314381,41.0434782608696,41.4381270903010,41.8327759197324,42.2274247491639,42.6220735785953,43.0167224080268,43.4113712374582,43.8060200668896,44.2006688963211,44.5953177257525,44.9899665551840,45.3846153846154,45.7792642140468,46.1739130434783,46.5685618729097,46.9632107023411,47.3578595317726,47.7525083612040,48.1471571906355,48.5418060200669,48.9364548494983,49.3311036789298,49.7257525083612,50.1204013377926,50.5150501672241,50.9096989966555,51.3043478260870,51.6989966555184,52.0936454849498,52.4882943143813,52.8829431438127,53.2775919732442,53.6722408026756,54.0668896321070,54.4615384615385,54.8561872909699,55.2508361204013,55.6454849498328,56.0401337792642,56.4347826086957,56.8294314381271,57.2240802675585,57.6187290969900,58.0133779264214,58.4080267558528,58.8026755852843,59.1973244147157,59.5919732441472,59.9866220735786,60.3812709030100,60.7759197324415,61.1705685618729,61.5652173913044,61.9598662207358,62.3545150501672,62.7491638795987,63.1438127090301,63.5384615384615,63.9331103678930,64.3277591973244,64.7224080267559,65.1170568561873,65.5117056856187,65.9063545150502,66.3010033444816,66.6956521739131,67.0903010033445,67.4849498327759,67.8795986622074,68.2742474916388,68.6688963210702,69.0635451505017,69.4581939799331,69.8528428093646,70.2474916387960,70.6421404682274,71.0367892976589,71.4314381270903,71.8260869565217,72.2207357859532,72.6153846153846,73.0100334448161,73.4046822742475,73.7993311036789,74.1939799331104,74.5886287625418,74.9832775919733,75.3779264214047,75.7725752508361,76.1672240802676,76.5618729096990,76.9565217391304,77.3511705685619,77.7458193979933,78.1404682274248,78.5351170568562,78.9297658862876,79.3244147157191,79.7190635451505,80.1137123745819,80.5083612040134,80.9030100334448,81.2976588628763,81.6923076923077,82.0869565217391,82.4816053511706,82.8762541806020,83.2709030100335,83.6655518394649,84.0602006688963,84.4548494983278,84.8494983277592,85.2441471571906,85.6387959866221,86.0334448160535,86.4280936454850,86.8227424749164,87.2173913043478,87.6120401337793,88.0066889632107,88.4013377926421,88.7959866220736,89.1906354515050,89.5852842809365,89.9799331103679,90.3745819397993,90.7692307692308,91.1638795986622,91.5585284280937,91.9531772575251,92.3478260869565,92.7424749163880,93.1371237458194,93.5317725752508,93.9264214046823,94.3210702341137,94.7157190635452,95.1103678929766,95.5050167224080,95.8996655518395,96.2943143812709,96.6889632107023,97.0836120401338,97.4782608695652,97.8729096989967,98.2675585284281,98.6622073578595,99.0568561872910,99.4515050167224,99.8461538461538,100.240802675585,100.635451505017,101.030100334448,101.424749163880,101.819397993311,102.214046822742,102.608695652174,103.003344481605,103.397993311037,103.792642140468,104.187290969900,104.581939799331,104.976588628763,105.371237458194,105.765886287625,106.160535117057,106.555183946488,106.949832775920,107.344481605351,107.739130434783,108.133779264214,108.528428093645,108.923076923077,109.317725752508,109.712374581940,110.107023411371,110.501672240803,110.896321070234,111.290969899666,111.685618729097,112.080267558528,112.474916387960,112.869565217391,113.264214046823,113.658862876254,114.053511705686,114.448160535117,114.842809364549,115.237458193980,115.632107023411,116.026755852843,116.421404682274,116.816053511706,117.210702341137,117.605351170569,118];
        %pR_ens = [0,0,0,0,0,0,0,1.53522204586511e-06,1.94559583251667e-06,2.35596961916822e-06,2.76634340581978e-06,3.36948470841295e-06,4.06927057551340e-06,4.76905644261385e-06,5.60995593446387e-06,6.74789198041905e-06,7.88582802637424e-06,9.02376407232942e-06,1.07663892218278e-05,1.25225739856641e-05,1.42787587495005e-05,1.65519449849244e-05,1.91235012462562e-05,2.16950575075880e-05,2.45733027901776e-05,2.82021539575999e-05,3.18310051250222e-05,3.54598562924445e-05,4.01483212667442e-05,4.48971882229824e-05,4.96460551792205e-05,5.52580637500871e-05,6.14405509195292e-05,6.76230380889714e-05,7.42217500209218e-05,8.20170599892869e-05,8.98123699576521e-05,9.76076799260173e-05,0.000106959129908005,0.000116456863820481,0.000125954597732957,0.000136729315519879,0.000148467081015487,0.000160204846511094,0.000172611079844117,0.000187305687029457,0.000202000294214798,0.000216694901400139,0.000235025123673770,0.000253841388972072,0.000272657654270374,0.000294896996899415,0.000320074951893809,0.000345252906888204,0.000371804640561263,0.000404061095602774,0.000436317550644285,0.000468574005685797,0.000511493996574526,0.000556294628237151,0.000601095259899775,0.000652244242079230,0.000709589050607390,0.000766933859135549,0.000827037962991898,0.000901407011551854,0.000975776060111810,0.00105014510867177,0.00113917438052606,0.00123146368175107,0.00132375298297607,0.00142581230760544,0.00153870989939525,0.00165160749118506,0.00176706931703799,0.00189967918776420,0.00203228905849041,0.00216489892921662,0.00231300430567070,0.00246532645332362,0.00261764860097654,0.00277710079463388,0.00294555116968535,0.00311400154473681,0.00328438541461466,0.00347254806759768,0.00366071072058070,0.00384887337356372,0.00403703602654675,0.00422519867952976,0.00441336133251278,0.00460887285919268,0.00481495576484075,0.00502103867048882,0.00522652941477158,0.00542365219558081,0.00562077497639004,0.00581789775719928,0.00600855052429074,0.00619671317727377,0.00638487583025679,0.00657303848323981,0.00676120113622283,0.00694936378920585,0.00713661005657772,0.00729789233056316,0.00745917460454861,0.00762045687853406,0.00776937252688249,0.00791273454820289,0.00805609656952328,0.00819325651597547,0.00831869828463082,0.00844414005328617,0.00856954429784383,0.00867706581464886,0.00878458733145390,0.00889210884825894,0.00897604391162835,0.00904772492228855,0.00911940593294875,0.00918827260576849,0.00925099349009616,0.00931371437442384,0.00937643525875151,0.00942177176550203,0.00946657239716465,0.00951137302882727,0.00955056374708572,0.00958640425241582,0.00962224475774592,0.00965302998707478,0.00967095023987562,0.00968887049267646,0.00970679074547730,0.00971630550895582,0.00972526563528835,0.00973422576162087,0.00973253946033233,0.00972357933399981,0.00971461920766728,0.00970117720448250,0.00967429682548493,0.00964741644648735,0.00962053606748978,0.00956929932036946,0.00951553856237431,0.00946177780437916,0.00939794401840432,0.00932626300774412,0.00925458199708393,0.00917508403182426,0.00906756251501922,0.00896004099821419,0.00885251948140915,0.00872933378575507,0.00860389201709973,0.00847845024844438,0.00834825866539283,0.00821385677040496,0.00807945487541708,0.00794005036339382,0.00777876808940838,0.00761748581542293,0.00745620354143748,0.00730246665741195,0.00715014450975903,0.00699782236210611,0.00684550021445319,0.00669317806680027,0.00654085591914734,0.00638991461051812,0.00624655258811141,0.00610319056570469,0.00595982854329797,0.00583824259287011,0.00572176095054729,0.00560527930822446,0.00549297408088351,0.00538545256489321,0.00527793104890291,0.00517369195170501,0.00509305081471229,0.00501240967771957,0.00493176854072684,0.00485809939427971,0.00478641838361951,0.00471473737295931,0.00464694607746029,0.00458422519313262,0.00452150430880494,0.00445959086421734,0.00440583010581482,0.00435206934741230,0.00429830858900978,0.00424454783091121,0.00419078707291606,0.00413702631492091,0.00407966254135823,0.00401694165703055,0.00395422077270288,0.00389097914819207,0.00381929813753187,0.00374761712687167,0.00367593611621147,0.00359785651442002,0.00351721537742730,0.00343657424043457,0.00335261678769500,0.00326301552436975,0.00317341426104450,0.00308378959366510,0.00299329231702086,0.00290279504037662,0.00281229776373238,0.00271935573094085,0.00262527440444934,0.00253119307795783,0.00243771767469696,0.00234542837347195,0.00225313907224695,0.00216084977102194,0.00207390495005773,0.00198699172463224,0.00190007849920675,0.00181840794632649,0.00173955883460027,0.00166070972287405,0.00158570069385956,0.00151939575849645,0.00145309082313335,0.00138678588777024,0.00133168795065052,0.00127703118002212,0.00122237440939371,0.00117491767852558,0.00113190907212946,0.00108890046573334,0.00104883931942387,0.00101658286462678,0.000984326409829692,0.000952069955032602,0.000927314161153811,0.000903121820055993,0.000878929478958177,0.000857363034011657,0.000837650756080102,0.000817938478148548,0.000798660103567752,0.000780739850766913,0.000762819597966073,0.000744899345165234,0.000726979092608309,0.000709058840079048,0.000691138587549788,0.000672721825460069,0.000653905559734029,0.000635089294007988,0.000616084746499806,0.000596372468120145,0.000576660189740484,0.000556947911360823,0.000535683500475650,0.000514179198418225,0.000492674896360799,0.000472106271960674,0.000452393993581013,0.000432681715201352,0.000413129048598410,0.000394312782872369,0.000375496517146330,0.000356680251420289,0.000340106177572668,0.000323977951029599,0.000307849724486530,0.000293522091263839,0.000281067515378507,0.000268612939493176,0.000256590471453114,0.000247092737324733,0.000237595003196350,0.000228097269067968,0.000220611970392810,0.000213623071694567,0.000206634172996323,0.000200425223475067,0.000195138749219284,0.000189852274963500,0.000184668072427863,0.000180277610425120,0.000175887148422378,0.000171496686419635,0.000167175230111108,0.000162874369373727,0.000158573508636347,0.000154043550376312,0.000149205082413391,0.000144366614450470,0.000139491345577210];
        %p = interp1(R_ens,pR_ens,R); p(isnan(p)) = min(p(p>0));
        
        p = p./sum(p);
        m = p;
        M = length(y);
        
        sigma_sqrt_y = false;
        if sigma_sqrt_y
            %%% these calculation assume that sigma = sqrt(y)!
            H = 2/M*(Fi'*Fi);
            g0 = 2/M*sigma'*Fi;
            const_chi2 = sum(y)/M;
        else
            %%% here, we take arbitrary sigma and account for it correctly
            H = 2/M*(Fi'*Fi);
            g0 = 2/M*(y./sigma)'*Fi;
            const_chi2 = sum((y./sigma).^2)/M;
        end
        
        
        
        chis = [];
        ps = [];
        Ss = [];
        
        options = optimoptions(@quadprog,'Display','none');
        do_mem = true;
        if do_mem
            nus = logspace(-2,2,100);
        else
            nus = logspace(-1,4,250);
        end
        for i=1:numel(nus)
            nu = nus(i);
            if do_mem %%% perform MEM analysis
                %chisq = 0.5*p*H*p' - g0*p' + const_chi2;
                L = log(p./m); %S = (-L+1)*p'-sum(m);
                %fprintf('\nmax S   \tchi2 = %.6f S = %.4f\n', chisq, S);
                
                % Optimization
                dgrad = 1;
                % p >= 0:
                A = -diag(ones(n,1)); B = -1e-12*ones(1,n);
                p_esm = quadprog(H + diag(diag(H)*1e-12),-g0,A,B,[],[],[],[],[],options)';
                chisq = 0.5*p_esm*H*p_esm' - g0*p_esm' + const_chi2;
                
                S = (-log(p_esm./m)+1)*p_esm'-sum(m);
                
                %Q = chisq-0.5*nu*S;
                %fprintf('min chi2 \tchi2 = %.6f  S = %.4f  Q = %.6f\n\n', chisq, S, Q);
                
                niter = 1;
                p = m;
                while ((dgrad > 0.001) && (niter < 50))
                    
                    Delta = diag(0.5./p,0);
                    p = quadprog(H+nu*Delta,-g0+0.5*nu*(L-1),A,B,[],[],[],[],[],options)';
                    chisq = 0.5*p*H*p' - g0*p' + const_chi2;
                    L = log(p./m); S = (-L+1)*p'-sum(m);
                    %Q = chisq-0.5*nu*S;
                    
                    grad_chi2 = (p>-1.1*B)'.*(H*p'-g0'); norm_chi2 = sqrt(grad_chi2'*grad_chi2);
                    grad_S = (p>-1.1*B)'.*(-L)'; norm_S = sqrt(grad_S'*grad_S);
                    dgrad = 0.5*sqrt((grad_chi2./norm_chi2-grad_S./norm_S)'* ...
                        (grad_chi2./norm_chi2-grad_S./norm_S));
                    %fprintf('iter #%d \tchi2 = %.6f  S = %.4f  Q = %.6f dgrad = %.6f\n', niter, chisq, S, Q, dgrad);
                    
                    niter = niter+1;
                end
            else %%% do Tikhonov analysis
                p = quadprog(H+2*nu*eye(numel(p)),-g0,Aieq,bieq,[],[],[],[],[],options)';
                chisq = 0.5*p*H*p' - g0*p' + const_chi2;
                S = -norm(p); %%% this is the solution norm
            end
            chis = [chis, chisq];
            ps = [ps; [p]];
            Ss = [Ss, S];
            Progress(i/numel(nus),h.Progress_Axes,h.Progress_Text);
        end
        
        % define corner as point of maxiumum curvature
        if any(Ss >= 0) %%% algorithm uses log(-Ss), rescale to make sure that log is defined
            Ss = Ss-max(Ss)-0.01; %%% make sure all entropies are negative so that log10(-S) is defined
        end
        
        find_corner = true;
        if find_corner
            %%% geometrically find the corner in the L-curve
            % ix_corner= find_corner_of_curve(log10(chis),log10(-Ss));
            
            %%% find instead the corner of the chi2 vs. mu plot
            ix = l_curve_corner(-nus(end:-1:1),chis(end:-1:1),nus(end:-1:1));
            ix_corner = numel(nus) - ix + 1;
            
            %%% Find corner of discrete L-curve via adaptive pruning algorithm.
            %%% Inputs have to be reordered in order of decreasing
            %%% regularization parameter.
            %%% Take the negative entropy (ensured that all S < 0) so that
            %%% log10(S) is defined.
            %%% 4th input means that the first corner is selected.
            %%% 5th input means that a plot is shown:
            %ix_corner = l_curve_corner(chis(end:-1:1),-Ss(end:-1:1),nus(end:-1:1));
            %ix_corner = numel(nus) - ix_corner + 1;
            
            %%% alternative algorithm
            % define corner as closest point to origin
            % -> overweights regularization, leading to bad chi2
            %indexOfMin = find_corner(chis,-Ss,nus,true);
        else %%% choose regularization parameter such that chi2 is equal to the chi2 of the model-based fit
            ix_corner = find(chis>TauFitData.Chi2,1,'first');
        end
        %plot_L_curve(chis,-Ss,nus,ix_corner);
        
        tau_dist = ps(ix_corner,:);
        model =  (decay_ind'*tau_dist')'+decay_offset;
        decay = decay + decay_offset;
        
        model_all = zeros(size(ps,1),numel(decay));
        for i = 1:size(ps,1)
            model_all(i,:) = (decay_ind'*ps(i,:)')'+decay_offset;
        end
        if strcmp(mode,'dist') && ~linear_R
            %%% reweight the distribution for R binning
            w = gradient(tau)./gradient(R); % binning correction
            norm_ps = sum(ps,2); % area
            
            %%% reweight for binning
            ps = ps.*repmat(w,size(ps,1),1);
            %%% rescale to original area
            ps = ps.*repmat(norm_ps,1,size(ps,2))./repmat(sum(ps,2),1,size(ps,2));
            
            tau_dist = ps(ix_corner,:);
        end
        
        if strcmp(mode,'dist') && ~verLessThan('matlab','9.7') %%% function uses tiledlayout introduced in R2019b
            compare_L_curve([-1,0,ix_corner],{'Input','Fit','MEM'},chis,-Ss,nus,R,ps,model_all,decay,error,false);
        end
    case 'brute-force'
        %%% this is the old "straight-forward" algorithm that I implemented
        %%% using fmincon. It uses boundary constraints and the mem functional
        %%% to optimize the distribution of lifetimes. It seems to work,
        %%% although it also prefers "smooth" options even if the
        %%% regularization is set to 0.
        
        %%% scaling parameter for the entropy term
        v = 1E-5;
        % this value is taken from:
        % Vinogradov and Wilson, "Recursive Maximum Entropy Algorithm and Its Application to the Luminescence Lifetime Distribution Recovery."
        % where it is suggested as an "optimal" value
        
        %%% generate linear combination decay
        decay_lincomb = @(p) sum(decay_ind.*repmat(p,1,numel(decay),1));
        
        %%% define functional
        switch TauFitData.WeightedResidualsType
            case 'Gaussian'
                mem = @(p) -(v*sum(p-p.*log(p)) - sum( (decay-decay_lincomb(p)).^2./error.^2)./(numel(decay)));
            case 'Poissonian'
                mem = @(p) -(v*sum(p-p.*log(p)) - sum(MLE_w_res(decay_lincomb(p),decay).^2)./(numel(decay)));
        end
        %%% specify fit options
        opts = optimoptions(@fmincon,'MaxFunEvals',1E5,'Display','iter','TolFun',1E-3);
        tau_dist = fmincon(mem,p,Aieq,bieq,[],[],lb,ub,@nonlcon,opts);
        model = decay_lincomb(tau_dist); %sum(decay_ind.*repmat(tau_dist,1,numel(decay),1));
    case 'Oleg'
        %%% These are advanced implementations of the regularization based on
        %%% matrix algebra and quadratic programming. The problem is
        %%% reformulated and the regularization.
        do_mem = false;
        %%% prepare vector and matrices
        % minimize ||Ax-b||^2 + lambda||x||^2 subject to sum(x) = 1
        % equivalent to:
        % xT(AT*A+lambda I)x - 2bTAx + bTb
        % quadprog solves system of tpye: 0.5*xTHx + fTx
        % so: H = 2(AT*A+lambda I)
        %     fT = -2bTA
        decay_ind_norm = decay_ind./repmat(error,size(decay_ind,1),1);
        decay_norm = decay./error;
        c = decay_norm*decay_norm'./numel(decay);
        H = 2*(decay_ind_norm*decay_ind_norm')./numel(decay);
        f = -2*decay_ind_norm*decay_norm'./numel(decay);
        options = optimoptions(@quadprog,'Display','none');
        if ~do_mem
            %%% Tikhonov
            mu_range = logspace(-2,4,300);
            tau_dist_tik = zeros(numel(mu_range),numel(p0));
            model = zeros(numel(mu_range),numel(decay));
            chi2 = zeros(numel(mu_range),1);
            n = zeros(numel(mu_range),1);
            for i = 1:numel(mu_range)
                dist = quadprog(H+2*mu_range(i)*eye(numel(p)),f,Aieq,bieq,[],[],[],[],[],options);
                n(i) = norm(dist);
                model(i,:) = decay_ind'*dist;
                chi2(i) = getchi2(dist,c,f,H);
                tau_dist_tik(i,:) = dist;
            end
            %%% find the point of maximum curvature
            ix_c = l_curve_corner(flipud(chi2),flipud(n),flipud(mu_range),0,1); % chi2 and n need to be ordered in decreasing amount of regularization
            % (Note: chi2 and n are taken to power of ten to search for the
            % corner in the non-log space)
            ix_c = numel(chi2)+1-ix_c;
            tau_dist = tau_dist_tik(ix_c,:);
            model = model(ix_c,:) + decay_offset;
        elseif do_mem
            %%% MEM: Algorithm according to Vinogradov-Wilson (2000), based
            %%% on the implementation of Oleg Opanasyuk
            %%% The algorithm performs equivalent to the Kalinin algorithm,
            %%% but the latter is used for historical reasons.
            %%% (This algorithm does not converge when the normalization is enforced by the equality condition.)
            niter = 20;
            d_iter = zeros(numel(mu_range),niter);
            model = zeros(numel(mu_range),numel(decay));
            chi2_mem = zeros(numel(mu_range),1);
            S = zeros(numel(mu_range),1); % entropy
            tau_dist_mem = zeros(numel(mu_range),numel(p0));
            for i = 1:numel(mu_range)
                j = 1;
                
                D = diag(1./p0);%diag(zeros(numel(p0),1));
                l = zeros(size(p0));
                p_mem = p0;
                d = memdelta(p_mem,l,f,H);
                while (d > 0.01) && j<=niter
                    d_iter(i,j) = d;
                    %%% Different prefactors for the expansion were used
                    %%% Stas-Vinogradov formula
                    p_mem = quadprog(H+mu_range(i)*0.5*D,f+0.5*mu_range(i)*(l-1),Aieq,bieq,[],[],[],[],[],options);
                    %%% Olegs formula:
                    %p_mem = quadprog(H+2*mu_range(i)*D,f+mu_range(i)*(l-1),Aieq,bieq,[],[],[],[],[],options);
                    p_mem(p_mem<1E-12) = 1E-12;
                    l = log(p_mem./p0);
                    D = diag(1./p_mem);
                    d = memdelta(p_mem,l,f,H);
                    j = j+1;
                end
                model(i,:) = decay_ind'*p_mem;
                chi2_mem(i) = getchi2(p_mem,c,f,H);
                S(i) = -p_mem'*l;
                tau_dist_mem(i,:) = p_mem;
            end
            %%% find the point of maximum curvature
            ix_c = l_curve_corner(10.^flipud(chi2_mem),10.^flipud(-S-min(-S)+0.01),flipud(mu_range),2); % chi2 and n need to be ordered in decreasing amount of regularization
            ylabel('neg. Entropy, -S');
            ix_c = numel(chi2_mem)+1-ix_c;
            tau_dist = tau_dist_mem(ix_c,:) + decay_offset;
            model = model(ix_c,:);
        end
        decay = decay + decay_offset;
end

compare_all = false;
if compare_all
    %%% How to choose L-curve?
    %%% Compare the effect of selecting the regularization parameter
    %%% from the L curve
    method = cell(0);
    ix_corner = [];
    
    % a flat distribution
    method{end+1} = 'Prior';
    ix_corner(end+1) = -1;
    % the previous fit
    method{end+1} = 'Fit - 2 Gaussian';
    ix_corner(end+1) = 0;
    
    % maximum curvature
    method{end+1} = 'Max. curv. (\chi^2_r vs. -S)';%'Maximum curvature (\chi^2_r vs. -S) - global';
    ix = l_curve_corner(chis(end:-1:1),-Ss(end:-1:1),nus(end:-1:1));
    ix_corner(end+1) = numel(nus) - ix + 1;
    
    %     method{end+1} = 'Maximum curvature (\chi^2_r vs. -S) - leftmost';
    %     ix = l_curve_corner(chis(end:-1:1),-Ss(end:-1:1),nus(end:-1:1),1);
    %     ix_corner(end+1) = numel(nus) - ix + 1;
    
    
    ix = find(chis>TauFitData.Chi2,1,'first');
    if ~isempty(ix)
        method{end+1} = '\chi^2_r equal to fit';
        ix_corner(end+1) = ix;
    end
    method{end+1} = 'Max. curv. (\mu vs. \chi^2_r)';%'Maximum curvature (\mu vs. \chi^2_r)';
    ix = l_curve_corner(-nus(end:-1:1),chis(end:-1:1),nus(end:-1:1));
    ix_corner(end+1) = numel(nus) - ix + 1;
    
    method{end+1} = 'Geometric (\chi^2_r vs. -S)';
    ix_corner(end+1) = find_corner_of_curve(log10(chis),log10(-Ss));
    
    method{end+1} = 'Geometric (\mu vs. \chi^2_r)';
    ix_corner(end+1) = find_corner_of_curve(log10(nus),chis);
    
    compare_L_curve(ix_corner,method,chis,-Ss,nus,R,ps,model_all,decay,error,true);
end

switch TauFitData.WeightedResidualsType
    case 'Gaussian'
        chi2 = sum( (decay-model).^2./error.^2)./(numel(decay));
    case 'Poissonian'
        chi2 = sum(MLE_w_res(model,decay).^2)./(numel(decay));
end

switch mode
    case 'tau'
        tau = tau*TauFitData.TACChannelWidth;
    case 'dist'
        tau = R;
end

function compare_L_curve(index,method_names,chi,negS,nu,tau,tau_dist,model_all,decay,error,plot_decay)
global TauFitData
% make a plot with four panel

% 11 - L-curve -Ss vs. chi2
% 12 - L-curve chi2 vs. reg-param
% 21 - decay and w_res at choice
% 22 - tau_dist
color = lines(numel(index));
if index(1) == -1 % plot inital distribution also in gray
    color = [0,0,0;color];
end
figure('Color',[1,1,1],'Position',[100,100,1000,1000]); hold on;
tiledlayout(2,2);
for i = 1:numel(index)
%     if i == 1 %%% plot the input ensemble
%         x = [0.394648829431438,0.789297658862876,1.18394648829431,1.57859531772575,1.97324414715719,2.36789297658863,2.76254180602007,3.15719063545151,3.55183946488294,3.94648829431438,4.34113712374582,4.73578595317726,5.13043478260870,5.52508361204013,5.91973244147157,6.31438127090301,6.70903010033445,7.10367892976589,7.49832775919732,7.89297658862876,8.28762541806020,8.68227424749164,9.07692307692308,9.47157190635452,9.86622073578595,10.2608695652174,10.6555183946488,11.0501672240803,11.4448160535117,11.8394648829431,12.2341137123746,12.6287625418060,13.0234113712375,13.4180602006689,13.8127090301003,14.2073578595318,14.6020066889632,14.9966555183946,15.3913043478261,15.7859531772575,16.1806020066890,16.5752508361204,16.9698996655518,17.3645484949833,17.7591973244147,18.1538461538462,18.5484949832776,18.9431438127090,19.3377926421405,19.7324414715719,20.1270903010033,20.5217391304348,20.9163879598662,21.3110367892977,21.7056856187291,22.1003344481605,22.4949832775920,22.8896321070234,23.2842809364549,23.6789297658863,24.0735785953177,24.4682274247492,24.8628762541806,25.2575250836120,25.6521739130435,26.0468227424749,26.4414715719064,26.8361204013378,27.2307692307692,27.6254180602007,28.0200668896321,28.4147157190635,28.8093645484950,29.2040133779264,29.5986622073579,29.9933110367893,30.3879598662207,30.7826086956522,31.1772575250836,31.5719063545151,31.9665551839465,32.3612040133779,32.7558528428094,33.1505016722408,33.5451505016722,33.9397993311037,34.3344481605351,34.7290969899666,35.1237458193980,35.5183946488294,35.9130434782609,36.3076923076923,36.7023411371237,37.0969899665552,37.4916387959866,37.8862876254181,38.2809364548495,38.6755852842809,39.0702341137124,39.4648829431438,39.8595317725753,40.2541806020067,40.6488294314381,41.0434782608696,41.4381270903010,41.8327759197324,42.2274247491639,42.6220735785953,43.0167224080268,43.4113712374582,43.8060200668896,44.2006688963211,44.5953177257525,44.9899665551840,45.3846153846154,45.7792642140468,46.1739130434783,46.5685618729097,46.9632107023411,47.3578595317726,47.7525083612040,48.1471571906355,48.5418060200669,48.9364548494983,49.3311036789298,49.7257525083612,50.1204013377926,50.5150501672241,50.9096989966555,51.3043478260870,51.6989966555184,52.0936454849498,52.4882943143813,52.8829431438127,53.2775919732442,53.6722408026756,54.0668896321070,54.4615384615385,54.8561872909699,55.2508361204013,55.6454849498328,56.0401337792642,56.4347826086957,56.8294314381271,57.2240802675585,57.6187290969900,58.0133779264214,58.4080267558528,58.8026755852843,59.1973244147157,59.5919732441472,59.9866220735786,60.3812709030100,60.7759197324415,61.1705685618729,61.5652173913044,61.9598662207358,62.3545150501672,62.7491638795987,63.1438127090301,63.5384615384615,63.9331103678930,64.3277591973244,64.7224080267559,65.1170568561873,65.5117056856187,65.9063545150502,66.3010033444816,66.6956521739131,67.0903010033445,67.4849498327759,67.8795986622074,68.2742474916388,68.6688963210702,69.0635451505017,69.4581939799331,69.8528428093646,70.2474916387960,70.6421404682274,71.0367892976589,71.4314381270903,71.8260869565217,72.2207357859532,72.6153846153846,73.0100334448161,73.4046822742475,73.7993311036789,74.1939799331104,74.5886287625418,74.9832775919733,75.3779264214047,75.7725752508361,76.1672240802676,76.5618729096990,76.9565217391304,77.3511705685619,77.7458193979933,78.1404682274248,78.5351170568562,78.9297658862876,79.3244147157191,79.7190635451505,80.1137123745819,80.5083612040134,80.9030100334448,81.2976588628763,81.6923076923077,82.0869565217391,82.4816053511706,82.8762541806020,83.2709030100335,83.6655518394649,84.0602006688963,84.4548494983278,84.8494983277592,85.2441471571906,85.6387959866221,86.0334448160535,86.4280936454850,86.8227424749164,87.2173913043478,87.6120401337793,88.0066889632107,88.4013377926421,88.7959866220736,89.1906354515050,89.5852842809365,89.9799331103679,90.3745819397993,90.7692307692308,91.1638795986622,91.5585284280937,91.9531772575251,92.3478260869565,92.7424749163880,93.1371237458194,93.5317725752508,93.9264214046823,94.3210702341137,94.7157190635452,95.1103678929766,95.5050167224080,95.8996655518395,96.2943143812709,96.6889632107023,97.0836120401338,97.4782608695652,97.8729096989967,98.2675585284281,98.6622073578595,99.0568561872910,99.4515050167224,99.8461538461538,100.240802675585,100.635451505017,101.030100334448,101.424749163880,101.819397993311,102.214046822742,102.608695652174,103.003344481605,103.397993311037,103.792642140468,104.187290969900,104.581939799331,104.976588628763,105.371237458194,105.765886287625,106.160535117057,106.555183946488,106.949832775920,107.344481605351,107.739130434783,108.133779264214,108.528428093645,108.923076923077,109.317725752508,109.712374581940,110.107023411371,110.501672240803,110.896321070234,111.290969899666,111.685618729097,112.080267558528,112.474916387960,112.869565217391,113.264214046823,113.658862876254,114.053511705686,114.448160535117,114.842809364549,115.237458193980,115.632107023411,116.026755852843,116.421404682274,116.816053511706,117.210702341137,117.605351170569,118];
%         y = [0,0,0,0,0,0,0,1.53522204586511e-06,1.94559583251667e-06,2.35596961916822e-06,2.76634340581978e-06,3.36948470841295e-06,4.06927057551340e-06,4.76905644261385e-06,5.60995593446387e-06,6.74789198041905e-06,7.88582802637424e-06,9.02376407232942e-06,1.07663892218278e-05,1.25225739856641e-05,1.42787587495005e-05,1.65519449849244e-05,1.91235012462562e-05,2.16950575075880e-05,2.45733027901776e-05,2.82021539575999e-05,3.18310051250222e-05,3.54598562924445e-05,4.01483212667442e-05,4.48971882229824e-05,4.96460551792205e-05,5.52580637500871e-05,6.14405509195292e-05,6.76230380889714e-05,7.42217500209218e-05,8.20170599892869e-05,8.98123699576521e-05,9.76076799260173e-05,0.000106959129908005,0.000116456863820481,0.000125954597732957,0.000136729315519879,0.000148467081015487,0.000160204846511094,0.000172611079844117,0.000187305687029457,0.000202000294214798,0.000216694901400139,0.000235025123673770,0.000253841388972072,0.000272657654270374,0.000294896996899415,0.000320074951893809,0.000345252906888204,0.000371804640561263,0.000404061095602774,0.000436317550644285,0.000468574005685797,0.000511493996574526,0.000556294628237151,0.000601095259899775,0.000652244242079230,0.000709589050607390,0.000766933859135549,0.000827037962991898,0.000901407011551854,0.000975776060111810,0.00105014510867177,0.00113917438052606,0.00123146368175107,0.00132375298297607,0.00142581230760544,0.00153870989939525,0.00165160749118506,0.00176706931703799,0.00189967918776420,0.00203228905849041,0.00216489892921662,0.00231300430567070,0.00246532645332362,0.00261764860097654,0.00277710079463388,0.00294555116968535,0.00311400154473681,0.00328438541461466,0.00347254806759768,0.00366071072058070,0.00384887337356372,0.00403703602654675,0.00422519867952976,0.00441336133251278,0.00460887285919268,0.00481495576484075,0.00502103867048882,0.00522652941477158,0.00542365219558081,0.00562077497639004,0.00581789775719928,0.00600855052429074,0.00619671317727377,0.00638487583025679,0.00657303848323981,0.00676120113622283,0.00694936378920585,0.00713661005657772,0.00729789233056316,0.00745917460454861,0.00762045687853406,0.00776937252688249,0.00791273454820289,0.00805609656952328,0.00819325651597547,0.00831869828463082,0.00844414005328617,0.00856954429784383,0.00867706581464886,0.00878458733145390,0.00889210884825894,0.00897604391162835,0.00904772492228855,0.00911940593294875,0.00918827260576849,0.00925099349009616,0.00931371437442384,0.00937643525875151,0.00942177176550203,0.00946657239716465,0.00951137302882727,0.00955056374708572,0.00958640425241582,0.00962224475774592,0.00965302998707478,0.00967095023987562,0.00968887049267646,0.00970679074547730,0.00971630550895582,0.00972526563528835,0.00973422576162087,0.00973253946033233,0.00972357933399981,0.00971461920766728,0.00970117720448250,0.00967429682548493,0.00964741644648735,0.00962053606748978,0.00956929932036946,0.00951553856237431,0.00946177780437916,0.00939794401840432,0.00932626300774412,0.00925458199708393,0.00917508403182426,0.00906756251501922,0.00896004099821419,0.00885251948140915,0.00872933378575507,0.00860389201709973,0.00847845024844438,0.00834825866539283,0.00821385677040496,0.00807945487541708,0.00794005036339382,0.00777876808940838,0.00761748581542293,0.00745620354143748,0.00730246665741195,0.00715014450975903,0.00699782236210611,0.00684550021445319,0.00669317806680027,0.00654085591914734,0.00638991461051812,0.00624655258811141,0.00610319056570469,0.00595982854329797,0.00583824259287011,0.00572176095054729,0.00560527930822446,0.00549297408088351,0.00538545256489321,0.00527793104890291,0.00517369195170501,0.00509305081471229,0.00501240967771957,0.00493176854072684,0.00485809939427971,0.00478641838361951,0.00471473737295931,0.00464694607746029,0.00458422519313262,0.00452150430880494,0.00445959086421734,0.00440583010581482,0.00435206934741230,0.00429830858900978,0.00424454783091121,0.00419078707291606,0.00413702631492091,0.00407966254135823,0.00401694165703055,0.00395422077270288,0.00389097914819207,0.00381929813753187,0.00374761712687167,0.00367593611621147,0.00359785651442002,0.00351721537742730,0.00343657424043457,0.00335261678769500,0.00326301552436975,0.00317341426104450,0.00308378959366510,0.00299329231702086,0.00290279504037662,0.00281229776373238,0.00271935573094085,0.00262527440444934,0.00253119307795783,0.00243771767469696,0.00234542837347195,0.00225313907224695,0.00216084977102194,0.00207390495005773,0.00198699172463224,0.00190007849920675,0.00181840794632649,0.00173955883460027,0.00166070972287405,0.00158570069385956,0.00151939575849645,0.00145309082313335,0.00138678588777024,0.00133168795065052,0.00127703118002212,0.00122237440939371,0.00117491767852558,0.00113190907212946,0.00108890046573334,0.00104883931942387,0.00101658286462678,0.000984326409829692,0.000952069955032602,0.000927314161153811,0.000903121820055993,0.000878929478958177,0.000857363034011657,0.000837650756080102,0.000817938478148548,0.000798660103567752,0.000780739850766913,0.000762819597966073,0.000744899345165234,0.000726979092608309,0.000709058840079048,0.000691138587549788,0.000672721825460069,0.000653905559734029,0.000635089294007988,0.000616084746499806,0.000596372468120145,0.000576660189740484,0.000556947911360823,0.000535683500475650,0.000514179198418225,0.000492674896360799,0.000472106271960674,0.000452393993581013,0.000432681715201352,0.000413129048598410,0.000394312782872369,0.000375496517146330,0.000356680251420289,0.000340106177572668,0.000323977951029599,0.000307849724486530,0.000293522091263839,0.000281067515378507,0.000268612939493176,0.000256590471453114,0.000247092737324733,0.000237595003196350,0.000228097269067968,0.000220611970392810,0.000213623071694567,0.000206634172996323,0.000200425223475067,0.000195138749219284,0.000189852274963500,0.000184668072427863,0.000180277610425120,0.000175887148422378,0.000171496686419635,0.000167175230111108,0.000162874369373727,0.000158573508636347,0.000154043550376312,0.000149205082413391,0.000144366614450470,0.000139491345577210];
%         y = interp1(x,y,tau); y(isnan(y)) = 0; y = y./sum(y);
%         nexttile(3);hold on;
%         area(tau,y,'FaceColor',[0.85,0.85,0.85],'EdgeColor','none');
%         nexttile(4);hold on;
%         plot(tau,cumsum(y),'LineWidth',3,'Color',[0.85,0.85,0.85]);
%     end
    if index(i) > 0 %%% plot the data
        dist{i} = tau_dist(index(i),:);
        model{i} =  model_all(i,:);%(decay_ind'*dist{i}')' + decay_offset;
        dist{i}= dist{i}./sum(dist{i});
        w_res{i} = (decay-model{i})./error;
        
        nexttile(1);hold on;
        if i == 1
            loglog(chi, negS, 'k-','LineWidth',3,'DisplayName','L-curve');
            axis square;
        end
        % Mark the corner.
        %loglog([min(chi)/100,chi(index(i))],[negS(index(i)),negS(index(i))],':',...
        %    [chi(index(i)),chi(index(i))],[min(negS)/100,negS(index(i))],':','LineWidth',2,'Color',color(i,:));
        scatter(chi(index(i)),negS(index(i)),200,'o','filled','MarkerFaceColor',color(i,:),'DisplayName',[method_names{i}, sprintf('(\\mu = %.2f)', nu(index(i)))]);
        %text(chi(index(i))*1.01,1.01*negS(index(i)),sprintf('\\mu = %.2f', nu(index(i))),'FontSize',18);
        set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',18,'Layer','Top','Box','on','TickDir','out','XGrid','on','YGrid','on',...
            'XMinorGrid','off','YMinorGrid','off');
        xlabel('\chi^2_r')
        ylabel('neg. Entropy, -S');
        %title('L-curve - neg. Entropy vs. Chi2');
        %xlim([max([0.95,0.95*min(chi)]),min([1.5,1.05*max(chi)])]); ylim([0.95*min(negS(chi<1.5)),max(negS)]);
        set(gca,'XScale','log','YScale','log');
        legend('FontSize',12);
        axis('tight');
        
        nexttile(2);hold on;
        if i == 1
            semilogx(nu, chi, 'k--','LineWidth',3);
            axis square;
        end
        scatter(nu(index(i)),chi(index(i)),200,'o','filled','MarkerFaceColor',color(i,:));
        set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',18,'Layer','Top','Box','on','TickDir','out','XGrid','on','YGrid','on');
        set(gca,'XScale','log');
        xlabel('\mu');
        ylabel('\chi^2_r');
        ylim([min([1,0.95*min(chi)]),min([max(chi),2])]);
    elseif index(i) == 0
        %%% get the distribution and decay from the GUI
        try
            h = guidata(findobj('Tag','TauFit'));
            model{i} = h.Plots.FitResult.YData;
            w_res{i} = (decay-model{i})./error;
            dist{i} = interp1(h.Plots.FitAnisoResult.XData,h.Plots.FitAnisoResult.YData,tau);
            dist{i}= dist{i}./sum(dist{i});
        catch
            model{i} = zeros(size(tau));
            w_res{i} = zeros(size(tau));
            dist{i} = zeros(size(tau));
        end
        
        nexttile(1);hold on;
        if i == 1
            loglog(chi, negS, 'k-','LineWidth',3,'DisplayName','L-curve');
            axis square;
        end
        plot([TauFitData.Chi2,TauFitData.Chi2],[min(negS),max(negS)],'--','Color',color(i,:),'LineWidth',3,'DisplayName',method_names{i});
        
        nexttile(2);hold on;
        if i == 1
            plot(nu, chi, 'k--','LineWidth',3);
            axis square;
        end
    elseif index(i) == -1 %%% plot the input flat distribution
        dist{i} = ones(size(tau))./numel(tau);
        model{i} = model_all(i,:); %(decay_ind'*dist{i}')' + decay_offset;
        dist{i}= dist{i}./sum(dist{i});
        w_res{i} = (decay-model{i})./error;
        chi2_initial = sum(w_res{i}.^2)./numel(tau);
        
        nexttile(1);hold on;
        if i == 1
            loglog(chi, negS, 'k-','LineWidth',3,'DisplayName','L-curve');
            axis square;
        end
        %plot([chi2_initial,chi2_initial],[min(negS),max(negS)],'--','Color',[0.5,0.5,0.5],'LineWidth',3,'DisplayName',method_names{i});
        
        nexttile(2);hold on;
        if i == 1
            plot(nu, chi, 'k--','LineWidth',3);
            axis square;
        end
    end
    
    nexttile(3);hold on;
    plot(tau,dist{i},'LineWidth',3,'Color',color(i,:));
    axis('square');
    axis('tight');
    set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',18,'Layer','Top','Box','on','TickDir','out','XGrid','on','YGrid','on');
    xlabel('R_{DA} [A]')
    ylabel('PDF');
    
    nexttile(4);hold on;
    plot(tau,cumsum(dist{i}),'LineWidth',3,'Color',color(i,:));
    axis('square');
    axis('tight');
    set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',18,'Layer','Top','Box','on','TickDir','out','XGrid','on','YGrid','on');
    xlabel('R_{DA} [A]')
    ylabel('CDF');
end

if plot_decay
    %%% second figure, decays
    figure('Color',[1,1,1],'Position',[100,100,800,600]); hold on;
    tiledlayout(4,1);
    
    t = TauFitData.TACChannelWidth*(1:numel(decay));
    for i = 1:numel(index)
        nexttile(1);hold on;
        plot(t, w_res{i},'LineWidth',2,'Color',color(i,:));
        axis('tight');
        ylim([-3,3]);
        set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',18,'Layer','Top','Box','on','TickDir','out','XGrid','on','YGrid','on');
        %set(gca,'XScale','log');
        set(gca,'XTickLabel',[]);
        nexttile(2,[3,1]);hold on;
        if i == 1
            plot(t, decay, 'k','LineWidth',2,'DisplayName','Decay');
        end
        if index(i) == 0
            chi2 = TauFitData.Chi2;
        else
            chi2 = sum(w_res{i}.^2./numel(w_res{i}));
        end
        plot(t,model{i},'LineWidth',3,'DisplayName',[method_names{i} ' - ' sprintf('\\chi^2_r = %.2f',chi2)],'Color',color(i,:));
        
        xlabel('time [ns]')
        ylabel('Intensity');
        set(gca,'YScale','log');
        axis('tight');
        legend('Color',[1,1,1],'Location','NorthEast','FontSize',12);
        set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',18,'Layer','Top','Box','on','TickDir','out','XGrid','on','YGrid','on');
    end
end

function plot_L_curve(rho,eta,reg,index)
figure; clf
lrho = log10(rho); leta = log10(eta);
diffrho2 = (max(lrho)-min(lrho))/2;
diffeta2 = (max(leta)-min(leta))/2;

loglog(rho, eta, 'k--o','LineWidth',2); hold on; axis square;
% Mark the corner.
loglog([min(rho)/100,rho(index)],[eta(index),eta(index)],':r',...
    [rho(index),rho(index)],[min(eta)/100,eta(index)],':r','LineWidth',2)
% Scale axes to same number of decades.
if abs(diffrho2)>abs(diffeta2)
    ax(1) = min(lrho); ax(2) = max(lrho);
    mid = min(leta) + (max(leta)-min(leta))/2;
    ax(3) = mid-diffrho2; ax(4) = mid+diffrho2;
else
    ax(3) = min(leta); ax(4) = max(leta);
    mid = min(lrho) + (max(lrho)-min(lrho))/2;
    ax(1) = mid-diffeta2; ax(2) = mid+diffeta2;
end

ax = 10.^ax;

ax(1) = ax(1)/2; axis(ax);
xlabel('\chi^2_r')
ylabel('neg. Entropy, -S');
title(sprintf('L-curve, corner at \\mu = %.2d', reg(index)));
set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',18,'Layer','Top');
set(gcf,'Color',[1,1,1]);
xlim([0.95*min(rho),min([1.5,1.05*max(rho)])]); ylim([0.95*min(eta(rho<1.5)),1.05*max(eta)]);

function [p,chi2,S] = solve_mem(H,g0,p,const_chi2,nu,niter_max)
chisq = 0.5*p*H*p' - g0*p' + const_chi2;
L = log(p./m); S = (-L+1)*p'-sum(m);
%fprintf('\nmax S   \tchi2 = %.6f S = %.4f\n', chisq, S);

% Optimization
dgrad = 1;
% p >= 0:
A = -diag(ones(n,1)); B = -1e-12*ones(1,n);
p_esm = quadprog(H + diag(diag(H)*1e-12),-g0,A,B,[],[],[],[],[],options)';
chisq = 0.5*p_esm*H*p_esm' - g0*p_esm' + const_chi2;

S = (-log(p_esm./m)+1)*p_esm'-sum(m);

Q = chisq-0.5*nu*S;
%fprintf('min chi2 \tchi2 = %.6f  S = %.4f  Q = %.6f\n\n', chisq, S, Q);

niter = 1;
p = m;
while ((dgrad > 0.0001) && (niter < niter_max))
    
    Delta = diag(0.5./p,0);
    p = quadprog(H+nu*Delta,-g0+0.5*nu*(L-1),A,B,[],[],[],[],[],options)';
    chisq = 0.5*p*H*p' - g0*p' + const_chi2;
    L = log(p./m); S = (-L+1)*p'-sum(m);
    Q = chisq-0.5*nu*S;
    
    grad_chi2 = (p>-1.1*B)'.*(H*p'-g0'); norm_chi2 = sqrt(grad_chi2'*grad_chi2);
    grad_S = (p>-1.1*B)'.*(-L)'; norm_S = sqrt(grad_S'*grad_S);
    dgrad = 0.5*sqrt((grad_chi2./norm_chi2-grad_S./norm_S)'* ...
        (grad_chi2./norm_chi2-grad_S./norm_S));
    %fprintf('iter #%d \tchi2 = %.6f  S = %.4f  Q = %.6f dgrad = %.6f\n', niter, chisq, S, Q, dgrad);
    
    niter = niter+1;
end


function indexOfMin = find_corner_of_curve(rho,eta)
%%% finds the point closest to corner in a plot of chi2 vs. nu

%%% rescale to 0-1 range
rho_sc = (rho-min(rho))./(max(rho)-min(rho));
eta_sc = (eta-min(eta))./(max(eta)-min(eta));
if all(diff(eta) >= 0)
    %%% monotonic increasing, corner to the bottom right
    cornerX = 1;
    cornerY = 0;
elseif all(diff(eta) <= 0)
    %%% monotonic decreasing, corner to the bottom left
    cornerX = 0;
    cornerY = 0;
end
distancesFromCorner = sqrt((rho_sc - cornerX) .^ 2 + (eta_sc - cornerY) .^ 2);
% Find min distance
[~, indexOfMin] = min(distancesFromCorner);

function d = memdelta(p,l,q,H)
%%% the delta for MEM optimization
Q = q+H*p;
if any(l>0)
    d = 0.5*norm(Q/norm(Q)+(l+1)/norm(l+1));
else
    d = 0.5*norm(Q/norm(Q));
end

function chi2 = getchi2(p,c,q,H)
chi2 = c + (q' + 0.5*p'*H)*p;

function [c,ceq] = nonlcon(x)
%%% nonlinear constraint for deconvolution
c = [];
ceq = sum(x) - 1;

function w_res_MLE = MLE_w_res(model,data)
%%% Returns the weighted residuals based on Poissonian counting statistics,
%%% as described in Laurence TA, Chromy BA (2010) Efficient maximum likelihood estimator fitting of histograms. Nat Meth 7(5):338?339.
%%%
%%% The sum of the weighted residuals is then analogous to a chi2 goodness-of-fit estimator.

valid = true(size(data));

% filter zero bins in data to avoid divsion by zero and in model to avoid log(0)
valid = valid & (data ~= 0) & (model ~= 0);

% compute MLE residuals:
%
% chi2_MLE = 2 sum(data-model) -2*sum(data*log(model/data))
%
% For invalid bins, only compute the first summand.

log_summand = zeros(size(data));
log_summand(valid) = data(valid).*log(model(valid)./data(valid));
w_res_MLE = 2*(model - data) - 2*log_summand; %squared residuals
% avoid complex numbers
w_res_MLE(w_res_MLE < 0) = 0;
w_res_MLE = sqrt(w_res_MLE);


function SetDonorOnlyLifetime(obj,~)
global UserValues TauFitData
h = guidata(obj);
if ~strcmp(TauFitData.Who,'BurstBrowser')
    chan_D = TauFitData.chan;
    chan_Donly = TauFitData.chan;
else %%% we fit the donor only channel (=4), but need to set the values for the donor channel
    chan_D = 1; %%% donor channel is always 1
    chan_Donly = TauFitData.chan;
end
%%% set fitted lifetimes for use as donor-only species in distance
%%% distribution fit
switch h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value}
    case 'Single Exponential'
        %%% only take the lifetime, set as donor only
        UserValues.TauFit.FitParams{chan_D}(14) = UserValues.TauFit.FitParams{chan_Donly}(1);
        %%% set fraction to zero
        UserValues.TauFit.FitParams{chan_D}(6) = 1;
    case 'Biexponential'
        %%% set lifetimes 1 and fraction
        UserValues.TauFit.FitParams{chan_D}(14) = UserValues.TauFit.FitParams{chan_Donly}(1);
        % we use fraction 2 as fraction 1 is used for the two distance distributions
        UserValues.TauFit.FitParams{chan_D}(6) = UserValues.TauFit.FitParams{chan_Donly}(5);
end
%%% fix all donor only parameters
UserValues.TauFit.FitFix{chan_D}(14) = true;
UserValues.TauFit.FitFix{chan_D}(2) = true;
UserValues.TauFit.FitFix{chan_D}(6) = true;
LSUserValues(1);

function [R_mE,mE] = calc_RDA_E(R,s,R0)
% calculate the average FRET efficiency and the FRET-averaged distance
r = linspace(max([R-3*s,0]),R+3*s,1000);
pR = normpdf(r,R,s); pR = pR./sum(pR);
E = (1+(r/R0).^6).^(-1);
mE = sum(pR.*E);
R_mE = R0.*(1./mE-1)^(1/6);

function tauF = calc_tauf(RDA,s,R0,tauD0)
% calculate the intensity-averaged donor fluorescence lifetime

% distance distribution
R = 0:1:200;%linspace(max([0,RDA-4*s]),RDA+4*s,1000);
pR = normpdf(R,RDA,s); pR = pR./sum(pR);

if numel(tauD0) == 1
    % single-exponential donor
    t = (1+(R0./R).^6).^(-1)*tauD0;
    tauF = sum(pR.*t.^2)./sum(pR.*t);
else
    % multi-exponential donor
    % first two elements of tauD0 are lifetime
    % third is fraction of first lifetime
    % fourth is the lifetime that belongs to R0        
    tau0 = tauD0(4);
    tauD01 = tauD0(1);
    tauD02 = tauD0(2);
    x_tauD01 = tauD0(3);
    k_RET = (1./tau0).*((R0./R).^6); % k_RET as a function of R
    t1 = ((1./tauD01) + k_RET).^(-1);
    t2 = ((1./tauD02) + k_RET).^(-1);
    tauF = (x_tauD01.*sum(pR.*t1.^2)+(1-x_tauD01).*sum(pR.*t2.^2))./...
        (x_tauD01.*sum(pR.*t1)+(1-x_tauD01).*sum(pR.*t2));
end