function TauFit(obj,~)
h.TauFit = findobj('Tag','TauFit');
%%% If called from command line, close
if nargin < 1
    Close_TauFit
    disp('Call TauFit from Pam or BurstBrowser instead of command line!');
    return;
end
if ~isempty(h.TauFit)
    % Close TauFit cause it might be called from somewhere else than before
    Close_TauFit
end
global UserValues TauFitData BurstData
if ~isempty(findobj('Tag','Pam'))
    ph = guidata(findobj('Tag','Pam'));
end
if ~isempty(findobj('Tag','BurstBrowser'))
    bh = guidata(findobj('Tag','BurstBrowser'));
end
addpath([pwd filesep 'TauFit Models']);

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
    'Position',[0 0.15 0.7 0.85],...
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
h.Plots.Scat_Par = plot([0 1],[0 0],'LineStyle',':','Color',[0.5 0.5 0.5]);
h.Plots.Scat_Per = plot([0 1],[0 0],'LineStyle',':','Color',[0.3 0.3 0.3]);
h.Plots.Decay_Sum = plot([0 1],[0 0],'-k');
h.Plots.Decay_Par = plot([0 1],[0 0],'-g');
h.Plots.Decay_Per = plot([0 1],[0 0],'-r');
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
h.Plots.Residuals_ignore = plot([0 1],[0 0],'Color',[0.4 0.4 0.4],'Visible','off');
h.Plots.Residuals_ZeroLine = plot([0 1],[0 0],'-k','Visible','off');
h.Residuals_Plot.YLabel.Color = Look.Fore;
h.Residuals_Plot.YLabel.String = 'res_w';
h.Residuals_Plot.XGrid = 'on';
h.Residuals_Plot.YGrid = 'on';

%%% Result Plot (Replaces Microtime Plot after fit is done)
h.Result_Plot = axes(...
    'Parent',h.TauFit_Panel,...
    'Units','normalized',...
    'Position',[0.05 0.075 0.9 0.775],...
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
h.Result_Plot.XLabel.String = 'Time [ns]';
h.Result_Plot.YLabel.Color = Look.Fore;
h.Result_Plot.YLabel.String = 'Intensity [counts]';
h.Result_Plot.XGrid = 'on';
h.Result_Plot.YGrid = 'on';
linkaxes([h.Result_Plot, h.Residuals_Plot],'x');
%h.Result_Plot_Text.Position = [0.8*h.Result_Plot.XLim(2) 0.9*h.Result_Plot.YLim(2)];
h.Result_Plot_Text.Position = [0.8 0.9];
hold on;
h.Plots.DecayResult = plot([0 1],[0 0],'-k');
h.Plots.DecayResult_ignore = plot([0 1],[0 0],'Color',[0.4 0.4 0.4],'Visible','off');
h.Plots.FitResult = plot([0 1],[0 0],'r','LineWidth',2);
h.Plots.FitResult_ignore = plot([0 1],[0 0],'--r','Visible','off');
h.Plots.IRFResult = plot([0 1],[0 0],'LineStyle','none','Marker','.','Color',[0.6 0.6 0.6]);
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
    'String','Para Start',...
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
    'Position',[0.7 0.75 0.30 0.22],...
    'Tag','PIEChannel_Panel');

if exist('ph','var')
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
                'Distribution','Distribution plus Donor only','Fit Anisotropy','Fit Anisotropy (2 exp)'};
            %%% Button for loading the selected PIE Channels
            h.LoadData_Button = uicontrol(...
                'Parent',h.PIEChannel_Panel,...
                'Style','pushbutton',...
                'Tag','LoadData_Button',...
                'Units','normalized',...
                'BackgroundColor', Look.Control,...
                'ForegroundColor', Look.Fore,...
                'Position',[0.05 0.45 0.3 0.15],...
                'String','Load Data',...
                'Callback',@Load_Data);
            %%% Button to start fitting
            h.Fit_Button = uicontrol(...
                'Parent',h.PIEChannel_Panel,...
                'Style','pushbutton',...
                'Tag','Fit_Button',...
                'Units','normalized',...
                'BackgroundColor', Look.Control,...
                'ForegroundColor', Look.Fore,...
                'Position',[0.05 0.05 0.2 0.15],...
                'String','Fit',...
                'Callback',@Start_Fit);
            %%% Button to fit Time resolved anisotropy
            h.Fit_Aniso_Button = uicontrol(...
                'Parent',h.PIEChannel_Panel,...
                'Style','pushbutton',...
                'Tag','Fit_Button',...
                'Units','normalized',...
                'BackgroundColor', Look.Control,...
                'ForegroundColor', Look.Fore,...
                'Position',[0.3 0.05 0.35 0.15],...
                'String','Fit anisotropy',...
                'Callback',@Start_Fit);
            h.Fit_Aniso_Menu = uicontextmenu;
            h.Fit_Aniso_2exp = uimenu('Parent',h.Fit_Aniso_Menu,...
                'Label','2 exponentials',...
                'Checked','off',...
                'Callback',@Start_Fit);
            h.Fit_Aniso_Button.UIContextMenu = h.Fit_Aniso_Menu;
        case ph.Burst.BurstLifetime_Button
            TauFitData.Who = 'Burstwise';
            %%%?User Clicks Burstwise Lifetime button in Pam
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
                case {1,2}
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
                'Tag','PreFit_Button',...
                'Units','normalized',...
                'BackgroundColor', Look.Back,...
                'ForegroundColor', Look.Fore,...
                'Position',[0.05 0.6 0.75 0.1],...
                'String','Use background estimation',...
                'ToolTipString','Includes a static scatter contribution into the fit. The contribution is estimated from background countrate and burst duration.',...
                'Value',1,...
                'Callback',[]);
            %%% Button tostart fitting
            h.BurstWiseFit_Button = uicontrol(...
                'Parent',h.PIEChannel_Panel,...
                'Style','pushbutton',...
                'Tag','StartFit_Button',...
                'Units','normalized',...
                'BackgroundColor', Look.Control,...
                'ForegroundColor', Look.Fore,...
                'Position',[0.3 0.05 0.4 0.15],...
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
                'Position',[0.05 0.05 0.2 0.15],...
                'String','Pre-Fit',...
                'Callback',@Start_Fit);
    end
end
if exist('bh','var')
    if isequal(obj, bh.SendToTauFit)
        TauFitData.Who = 'BurstBrowser';
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
        switch BurstData.BAMethod
            case {1,2}
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
        h.SpeciesSelect_Text = uicontrol('Style','text',...
            'Tag','TauFit_SpeciesSelect_text',...
            'Parent',h.PIEChannel_Panel,...
            'Units','normalized',...
            'Position',[0.05 0.65 0.8 0.1],...
            'HorizontalAlignment','left',...
            'String',['Selected Species: ' BurstData.SpeciesNames{bh.SpeciesList.Value}],...
            'BackgroundColor',Look.Back,...
            'ForegroundColor',Look.Fore,...
            'FontSize',12);
        %%% Popup Menu for Fit Method Selection
        h.FitMethods = {'Single Exponential','Biexponential','Three Exponentials',...
            'Distribution','Distribution plus Donor only','Fit Anisotropy','Fit Anisotropy (2 exp)'};
        %%% Button to start fitting
        h.Fit_Button = uicontrol(...
            'Parent',h.PIEChannel_Panel,...
            'Style','pushbutton',...
            'Tag','Fit_Button',...
            'Units','normalized',...
            'BackgroundColor', Look.Control,...
            'ForegroundColor', Look.Fore,...
            'Position',[0.05 0.05 0.2 0.15],...
            'String','Fit',...
            'Callback',@Start_Fit);
        %%% Button to fit Time resolved anisotropy
        h.Fit_Aniso_Button = uicontrol(...
            'Parent',h.PIEChannel_Panel,...
            'Style','pushbutton',...
            'Tag','Fit_Button',...
            'Units','normalized',...
            'BackgroundColor', Look.Control,...
            'ForegroundColor', Look.Fore,...
            'Position',[0.3 0.05 0.35 0.15],...
            'String','Fit anisotropy',...
            'Callback',@Start_Fit);
        h.Fit_Aniso_Menu = uicontextmenu;
        h.Fit_Aniso_2exp = uimenu('Parent',h.Fit_Aniso_Menu,...
            'Label','2 exponentials',...
            'Checked','off',...
            'Callback',@Start_Fit);
        h.Fit_Aniso_Button.UIContextMenu = h.Fit_Aniso_Menu;
    end
end
h.FitMethod_Popupmenu = uicontrol(...
    'Parent',h.PIEChannel_Panel,...
    'Style','Popupmenu',...
    'Tag','FitMethod_Popupmenu',...
    'Units','normalized',...
    'Position',[0.3 0.3 0.6 0.1],...
    'String',h.FitMethods,...
    'Callback',@Method_Selection);

h.FitMethod_Text = uicontrol(...
    'Parent',h.PIEChannel_Panel,...
    'Style','Text',...
    'Tag','FitMethod_Text',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.2 0.1],...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',12,...
    'String','Fit Method',...
    'ToolTipString','Select the Fit Method');

%%% Button to determine G-factor
h.Determine_GFactor_Button = uicontrol(...
    'Parent',h.PIEChannel_Panel,...
    'Style','pushbutton',...
    'Tag','Determine_GFactor_Button',...
    'Units','normalized',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.75 0.05 0.15 0.15],...
    'String','Get G',...
    'Callback',@DetermineGFactor);

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
    'Position',[0.7 0 0.3 0.75]);

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
    'Position',[0.05 0.125 0.3 0.03],...
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
    'Position',[0.35 0.125 0.3 0.03],...
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
    'Position',[0.05 0.075 0.3 0.03],...
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
    'Position',[0.35 0.075 0.3 0.03],...
    'String',num2str(UserValues.TauFit.l1),...
    'FontSize',12,...
    'Tag','l1_edit',...
    'Callback',@UpdateOptions);

h.l2_text = uicontrol(...
    'Parent',h.FitPar_Panel,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.05 0.025 0.3 0.03],...
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
    'Position',[0.35 0.025 0.3 0.03],...
    'String',num2str(UserValues.TauFit.l2),...
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
h.AutoFit_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.05 0.7 0.7 0.07],...
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
    'Position',[0.05 0.5 0.7 0.07],...
    'String','Scatter offset = 0',...
    'FontSize',12,...
    'Tag','NormalizeScatter_Menu',...
    'Callback',@Update_Plots);
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

%% Initialize sliders
for i = 1:3 %max number of pairs for fitting
    TauFitData.Length{i} = UserValues.TauFit.Length{i};
    TauFitData.StartPar{i} = UserValues.TauFit.StartPar{i};
    TauFitData.ShiftPer{i} = UserValues.TauFit.ShiftPer{i};
    TauFitData.IRFLength{i} = UserValues.TauFit.IRFLength{i};
    TauFitData.IRFShift{i} = UserValues.TauFit.IRFShift{i};
    TauFitData.IRFrelShift{i} = UserValues.TauFit.IRFrelShift{i};
    TauFitData.ScatShift{i} = UserValues.TauFit.ScatShift{i};
    TauFitData.ScatrelShift{i} = UserValues.TauFit.ScatrelShift{i};
    TauFitData.Ignore{i} = UserValues.TauFit.IRFShift{i};
end
TauFitData.FitType = h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value};
TauFitData.FitMethods = h.FitMethods;

guidata(gcf,h);

% If data is ready to be displayed, display it
% (user sent data from burstbrowser or wants to do a burstwise fitting)
if ~strcmp(TauFitData.Who, 'TauFit')
    Update_Plots(obj)
end

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
%%%  Load Data Button (TauFit raw PIE channel data) %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Data(obj,~)
global UserValues TauFitData FileInfo TcspcData
h = guidata(findobj('Tag','TauFit'));
% Load Data button was pressed
% User called TauFit from Pam

TauFitData.TACRange = FileInfo.TACRange; % in seconds
TauFitData.MI_Bins = FileInfo.MI_Bins;
if ~isfield(FileInfo,'Resolution')
    % in nanoseconds/microtime bin
    TauFitData.TACChannelWidth = TauFitData.TACRange*1E9/TauFitData.MI_Bins;
elseif isfield(FileInfo,'Resolution') %%% HydraHarp Data
    TauFitData.TACChannelWidth = FileInfo.Resolution/1000;
end

%%% Cases to consider:
%%% obj is empty or is Button for LoadData/LoadIRF
%%% Data has been changed (PIE Channel changed, IRF loaded...)
if isempty(obj) || obj == h.LoadData_Button
    %%% find the number of the selected PIE channels
    PIEChannel_Par = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{1}));
    PIEChannel_Per = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{2}));
    % PIE Channels have to be ordered correctly
    if UserValues.BurstSearch.Method == any(1,2) %2color MFD
        if PIEChannel_Par+PIEChannel_Per == 3
            chan = 1;
        elseif PIEChannel_Par+PIEChannel_Per == 11
            chan = 2;
        end
    elseif UserValues.BurstSearch.Method == any(3,4) %3color MFD
        if PIEChannel_Par+PIEChannel_Per == 3
            chan = 1;
        elseif PIEChannel_Par+PIEChannel_Per == 15
            chan = 2;
        elseif PIEChannel_Par+PIEChannel_Per == 23
            chan = 3;
        end
    else
        % Set channel to 4 if no MFD color channel is selected
        chan = 4;
        %msgbox('problem with the order of the PIE channels. see manual')
        %return
    end
    TauFitData.chan = chan;
    %%% Read out Photons and Histogram
    MI_Par = histc( TcspcData.MI{UserValues.PIE.Detector(PIEChannel_Par),UserValues.PIE.Router(PIEChannel_Par)},...
        0:(TauFitData.MI_Bins-1));
    MI_Per = histc( TcspcData.MI{UserValues.PIE.Detector(PIEChannel_Per),UserValues.PIE.Router(PIEChannel_Per)},...
        0:(TauFitData.MI_Bins-1));
    %%% Compute the Microtime Histograms
    % the data will be assigned to the appropriate channel, such that the
    % slider values are universal between TauFit, Burstwise Taufit and Bulk Burst Taufit
    TauFitData.hMI_Par{chan} = MI_Par(UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]));
    TauFitData.hMI_Per{chan} = MI_Per(UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]));
    %%% Microtime Histogram of Parallel Channel
    %     TauFitData.hMI_Par = PamMeta.MI_Hist{UserValues.PIE.Detector(PIEChannel_Par),UserValues.PIE.Router(PIEChannel_Par)}(...
    %         UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]) );
    %     %%% Microtime Histogram of Perpendicular Channel
    %     TauFitData.hMI_Per = PamMeta.MI_Hist{UserValues.PIE.Detector(PIEChannel_Per),UserValues.PIE.Router(PIEChannel_Per)}(...
    %         UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]) );
    
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
Update_Plots(obj)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  General Function to Update Plots when something changed %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(obj,~)
global UserValues TauFitData
h = guidata(findobj('Tag','TauFit'));

if strcmp(TauFitData.Who, 'BurstWise')
    % if burstwise fitting is done, user is not allowed to normalize the
    % constant offset of the scatter pattern
    h.NormalizeScatter_Menu.Value = 0;
end

% How did we get here?
if ~strcmp(TauFitData.Who, 'TauFit')
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
    h.Microtime_Plot.YLim = [min([TauFitData.hMI_Par{chan}; TauFitData.hMI_Per{chan}]) 10/9*max([TauFitData.hMI_Par{chan}; TauFitData.hMI_Per{chan}])];
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
    h.StartPar_Slider.Max = TauFitData.MaxLength{chan};
    if UserValues.TauFit.StartPar{chan} >= 0 && UserValues.TauFit.StartPar{chan} <= TauFitData.MaxLength{chan}
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
    h.ShiftPer_Slider.Min = -floor(TauFitData.MaxLength{chan}/10);
    h.ShiftPer_Slider.Max = floor(TauFitData.MaxLength{chan}/10);
    if UserValues.TauFit.ShiftPer{chan} >= -floor(TauFitData.MaxLength{chan}/10)...
            && UserValues.TauFit.ShiftPer{chan} <= floor(TauFitData.MaxLength{chan}/10)
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
    h.IRFShift_Slider.Min = -floor(TauFitData.MaxLength{chan}/10);
    h.IRFShift_Slider.Max = floor(TauFitData.MaxLength{chan}/10);
    if UserValues.TauFit.IRFShift{chan} >= -floor(TauFitData.MaxLength{chan}/10)...
            && UserValues.TauFit.IRFShift{chan} <= floor(TauFitData.MaxLength{chan}/10)
        tmp = UserValues.TauFit.IRFShift{chan};
    else
        tmp = 0;
    end
    h.IRFShift_Slider.Value = tmp;
    TauFitData.IRFShift{chan} = tmp;
    h.IRFShift_Edit.String = num2str(tmp);
    
    %%% IRF rel. Shift has the same limits as the perp shift property
    h.IRFrelShift_Slider.Min = -floor(TauFitData.MaxLength{chan}/10);
    h.IRFrelShift_Slider.Max = floor(TauFitData.MaxLength{chan}/10);
    if UserValues.TauFit.IRFrelShift{chan} >= -floor(TauFitData.MaxLength{chan}/10)...
            && UserValues.TauFit.IRFrelShift{chan} <= floor(TauFitData.MaxLength{chan}/10)
        tmp = UserValues.TauFit.IRFrelShift{chan};
    else
        tmp = 0;
    end
    h.IRFrelShift_Slider.Value = tmp;
    TauFitData.IRFrelShift{chan} = tmp;
    h.IRFrelShift_Edit.String = num2str(tmp);
    
    %%% Scat Shift has the same limits as the perp shift property
    h.ScatShift_Slider.Min = -floor(TauFitData.MaxLength{chan}/10);
    h.ScatShift_Slider.Max = floor(TauFitData.MaxLength{chan}/10);
    if UserValues.TauFit.ScatShift{chan} >= -floor(TauFitData.MaxLength{chan}/10)...
            && UserValues.TauFit.ScatShift{chan} <= floor(TauFitData.MaxLength{chan}/10)
        tmp = UserValues.TauFit.ScatShift{chan};
    else
        tmp = 0;
    end
    h.ScatShift_Slider.Value = tmp;
    TauFitData.ScatShift{chan} = tmp;
    h.ScatShift_Edit.String = num2str(tmp);
    
    %%% Scat rel. Shift has the same limits as the perp shift property
    h.ScatrelShift_Slider.Min = -floor(TauFitData.MaxLength{chan}/10);
    h.ScatrelShift_Slider.Max = floor(TauFitData.MaxLength{chan}/10);
    if UserValues.TauFit.ScatrelShift{chan} >= -floor(TauFitData.MaxLength{chan}/10)...
            && UserValues.TauFit.ScatrelShift{chan} <= floor(TauFitData.MaxLength{chan}/10)
        tmp = UserValues.TauFit.ScatrelShift{chan};
    else
        tmp = 0;
    end
    h.ScatrelShift_Slider.Value = tmp;
    TauFitData.ScatrelShift{chan} = tmp;
    h.ScatrelShift_Edit.String = num2str(tmp);
    
    %%% Ignore Slider reaches from 1 to maximum length
    h.Ignore_Slider.Min = 1;
    h.Ignore_Slider.Max = TauFitData.MaxLength{chan};
    if UserValues.TauFit.Ignore{chan} >= 1 && UserValues.TauFit.Ignore{chan} <= TauFitData.MaxLength{chan}
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
            TauFitData.Ignore{chan} = str2double(obj.String);
        end
    case {h.FitPar_Table}
        TauFitData.IRFShift{chan} = obj.Data{end,1};
        %%% Update Edit Box and Slider when user changes value in the table
        h.IRFShift_Edit.String = num2str(TauFitData.IRFShift{chan});
        h.IRFShift_Slider.Value = TauFitData.IRFShift{chan};
        
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
    h.Ignore_Plot.YData = h.Microtime_Plot.YLim;
elseif TauFitData.Ignore{chan} == 1
    %%% Hide Plot Again
    h.Ignore_Plot.Visible = 'off';
end
if h.AutoFit_Menu.Value
    Start_Fit(h.Fit_Button)
end

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
global TauFitData
TauFitData.FitType = obj.String{obj.Value};
%%% Update FitTable
h = guidata(findobj('Tag','TauFit'));
if ~strcmp(TauFitData.Who, 'TauFit')
    % Burstwise lifetime and Burstbrowser subensembe TCSPC
    chan = h.ChannelSelect_Popupmenu.Value;
else
    chan = TauFitData.chan;
end
[h.FitPar_Table.Data, h.FitPar_Table.RowName] = GetTableData(obj.Value, chan);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Fit the PIE Channel data or Subensemble (Burst) TCSPC %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Start_Fit(obj,~)
global TauFitData UserValues
h = guidata(findobj('Tag','TauFit'));
if ~strcmp(TauFitData.Who, 'TauFit')
    % Burstwise lifetime and Burstbrowser subensembe TCSPC
    chan = h.ChannelSelect_Popupmenu.Value;
else
    chan = TauFitData.chan;
end
h.Result_Plot_Text.Visible = 'off';
%% Prepare FitData
TauFitData.FitData.Decay_Par = h.Plots.Decay_Par.YData;
TauFitData.FitData.Decay_Per = h.Plots.Decay_Per.YData;

G = UserValues.TauFit.G{chan};
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
ScatterPattern = ScatterPattern'./sum(ScatterPattern);

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
Decay = G*(1-3*l1)*TauFitData.FitData.Decay_Par+(2-3*l2)*TauFitData.FitData.Decay_Per;
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
                %%% Convert Fraction from Area Fraction to Amplitude Fraction
                %%% (i.e. correct for brightness)
                amp1 = FitResult{3}./FitResult{1}; amp2 = (1-FitResult{3})./FitResult{2};
                amp1 = amp1./(amp1+amp2);
                FitResult{3} = amp1;
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
                %%% Convert Fraction from Area Fraction to Amplitude Fraction
                %%% (i.e. correct for brightness)
                amp1 = FitResult{4}./FitResult{1}; amp2 = FitResult{5}./FitResult{2}; amp3 = (1-FitResult{4}-FitResult{5})./FitResult{3};
                amp1 = amp1./(amp1+amp2+amp3); amp2 = amp2./(amp1+amp2+amp3);
                FitResult{4} = amp1;
                FitResult{5} = amp2;
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
                
                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = h.Plots.Scat_Par.YData';%TauFitData.hScat_Par{chan}(1:TauFitData.Length{chan})';ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                ScatterPattern{2} = h.Plots.Scat_Per.YData'; %ScatterPer(1:TauFitData.Length{chan})';ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});
                
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
                IRFPattern{1} = TauFitData.hIRF_Par(1:TauFitData.Length{chan})';IRFPattern{1} = IRFPattern{1}./sum(IRFPattern{1});
                IRFPattern{2} = IRFPer(1:TauFitData.Length{chan})';IRFPattern{2} = IRFPattern{2}./sum(IRFPattern{2});
                
                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = TauFitData.hScat_Par(1:TauFitData.Length{chan})';ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                ScatterPattern{2} = ScatterPer(1:TauFitData.Length{chan})';ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});
                
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
        end
        LSUserValues(1)
        %%% Update IRFShift in Slider and Edit Box
        h.IRFShift_Slider.Value = shift_range(best_fit);
        h.IRFShift_Edit.String = num2str(shift_range(best_fit));
        TauFitData.IRFShift{chan} = shift_range(best_fit);
        
        %%% Reset Progressbar
        Progress(1,h.Progress_Axes,h.Progress_Text,'Fit done');
        %h.Progress_Text.String = 'Fit done';
        %%% Update Plot
        h.Microtime_Plot.Parent = h.HidePanel;
        h.Result_Plot.Parent = h.TauFit_Panel;
        h.Plots.IRFResult.Visible = 'on';
        
        % plot chi^2 on graph
        h.Result_Plot_Text.Visible = 'on';
        h.Result_Plot_Text.String = ['\' sprintf('chi^2_{red.} = %.2f', chi2(best_fit))];
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
        if any(strcmp(TauFitData.FitType,{'Fit Anisotropy','Fit Anisotropy (2 exp)'}))
            h.Plots.DecayResult_ignore.Visible = 'off';
            h.Plots.Residuals_ignore.Visible = 'off';
            h.Plots.FitResult_ignore.Visible = 'off';
            h.Plots.IRFResult.Visible = 'off';
            ignore = 1;
        else
            IRFPat = circshift(IRFPattern,[UserValues.TauFit.IRFShift{chan},0]);
            IRFPat = IRFPat((ShiftParams(1)+1):ShiftParams(4));
            IRFPat = IRFPat./max(IRFPat).*max(Decay);
            h.Plots.IRFResult.XData = (1:numel(IRFPat))*TACtoTime;
            h.Plots.IRFResult.YData = IRFPat;
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
        
        h.Plots.Residuals.XData = (ignore:Length)*TACtoTime;
        h.Plots.Residuals.YData = wres;
        h.Plots.Residuals_ZeroLine.XData = (1:Length)*TACtoTime;
        h.Plots.Residuals_ZeroLine.YData = zeros(1,Length);
        h.Plots.Residuals_ignore.XData = (1:ignore)*TACtoTime;
        h.Plots.Residuals_ignore.YData = wres_ignore;
        h.Residuals_Plot.YLim = [min(wres) max(wres)];
        
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
            param0 = [1/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins, 0.4,3/(TauFitData.TACRange*1e9)*TauFitData.MI_Bins,0.1];
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
            str = sprintf('rho = %1.2f ns\nr_0 = %2.2f\nr_{inf} = %3.2f',param(1)*TACtoTime,param(2),param(3));
        elseif number_of_exponentials == 2
            str = sprintf('rho_1 = %1.2f ns\nrho_2 = %1.2f ns\nr_0 = %2.2f\nr_1 = %3.2f',param(1)*TACtoTime,param(3)*TACtoTime,param(2),param(4));
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
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Plots Anisotropy and Fit Single Exponential %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineGFactor(~,~)
global TauFitData UserValues
h = guidata(findobj('Tag','TauFit'));
if ~strcmp(TauFitData.Who, 'TauFit')
    % Burstwise lifetime and Burstbrowser subensembe TCSPC
    chan = h.ChannelSelect_Popupmenu.Value;
else
    chan = TauFitData.chan;
end
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

%TACtoTime = 1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
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
TACtoTime = 1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
h.Result_Plot_Text.String = sprintf(['rho = ' num2str(x(2)) ' ns \nr_0 = ' num2str(x(1))...
    '\nr_i_n_f = ' num2str(x(3))]);
h.Result_Plot_Text.Position = [0.8*h.Result_Plot.XLim(2)*TACtoTime 0.9*h.Result_Plot.YLim(2)];
h.G_factor_edit.String = num2str(G);
UserValues.TauFit.G{chan} = G;
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Export Graph to figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExportGraph(~,~)
% anders, in Burstbrowser there was code to plot fit parameters on graph.
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

ax(1).Children(end).FontSize = 20;
ax(1).Children(end).Position(2) = 0.9;

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

h.Progress_Text.String = 'Preparing Lifetime Fit...';
drawnow;

switch TauFitData.BAMethod
    case {1,2}
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
        % Anders, shouldn't the program read the background from the
        % burstdata structure instead of UserValues?
        %background{1} = UserValues.BurstBrowser.Corrections.Background_GGpar + UserValues.BurstBrowser.Corrections.Background_GGperp;
        %background{2} = UserValues.BurstBrowser.Corrections.Background_RRpar + UserValues.BurstBrowser.Corrections.Background_RRperp;
        background{1} = BurstData.Background.Background_GGpar + BurstData.Background.Background_GGperp;
        background{2} = BurstData.Background.Background_RRpar + BurstData.Background.Background_RRperp;
        
        %% Prepare the data
        for chan = 1:2
            % Anders, I just read the data from the plots to avoid confusion.
            h.ChannelSelect_Popupmenu.Value = chan;
            %Update_Plots(obj)
            %Irf = G{chan}*(1-3*l2)*h.Plots.IRF_Par.YData+(2-3*l1)*h.Plots.IRF_Per.YData;
            %%% Changed this back so a better correction of the IRF can be
            %%% performed, for which the total IRF pattern is needed!
            %%% Apply the shift to the parallel IRF channel
            hIRF_par = circshift(TauFitData.hIRF_Par{chan},[0,TauFitData.IRFShift{chan}])';
            %%% Apply the shift to the perpendicular IRF channel
            hIRF_per = circshift(TauFitData.hIRF_Per{chan},[0,TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan}])';
            IRFPattern = G{chan}+(1-3*l2)*hIRF_par(1:TauFitData.Length{chan}) + (2-3*l1)*hIRF_per(1:TauFitData.Length{chan});
            IRFPattern = IRFPattern'./sum(IRFPattern);
            %%% additional processing of the IRF to remove constant background
            IRFPattern = IRFPattern - mean(IRFPattern(end-round(numel(IRFPattern)/10):end)); IRFPattern(IRFPattern<0) = 0;
            Irf =  IRFPattern((TauFitData.StartPar{chan}+1):TauFitData.IRFLength{chan});
            
            %Irf = Irf-min(Irf(Irf~=0));
            Irf = Irf./sum(Irf);
            IRF{chan} = [Irf zeros(1,TauFitData.Length{chan}-numel(Irf))];
            Scatter = G{chan}*(1-3*l2)*h.Plots.Scat_Par.YData + (2-3*l1)*h.Plots.Scat_Per.YData;
            SCATTER{chan} = Scatter./sum(Scatter);
            Length{chan} = numel(Scatter)-1;
        end
        
        Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting Data...');
        %%% Process in Chunk
        %%% Prepare Chunks:
        parts = (floor(linspace(1,numel(Microtime),21)));parts(1) = 0;
        %%% Preallocate lifetime array
        lifetime{1} = cell(numel(parts)-1,1);
        lifetime{2} = cell(numel(parts)-1,1);
        %%% Prepare Fit Model
        mean_tau = 5;
        range_tau = 9.98;
        steps_tau = 2111;
        range = mean_tau-range_tau/2:range_tau/steps_tau:mean_tau+range_tau/2;
        for chan = 1:2
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
        for j = 1:(numel(parts)-1)
            MI = Microtime((parts(j)+1):parts(j+1));
            CH = Channel((parts(j)+1):parts(j+1));
            DUR = duration((parts(j)+1):parts(j+1));
            %%% Create array of histogrammed microtimes
            Par1 = zeros(numel(MI),numel(BurstData.PIE.From(1):BurstData.PIE.To(1)));
            Per1 = zeros(numel(MI),numel(BurstData.PIE.From(2):BurstData.PIE.To(2)));
            Par2 = zeros(numel(MI),numel(BurstData.PIE.From(5):BurstData.PIE.To(5)));
            Per2 = zeros(numel(MI),numel(BurstData.PIE.From(6):BurstData.PIE.To(6)));
            parfor i = 1:numel(MI)
                Par1(i,:) = histc(MI{i}(CH{i} == 1),(BurstData.PIE.From(1):BurstData.PIE.To(1)))';
                Per1(i,:) = histc(MI{i}(CH{i} == 2),(BurstData.PIE.From(2):BurstData.PIE.To(2)))';
                Par2(i,:) = histc(MI{i}(CH{i} == 5),(BurstData.PIE.From(5):BurstData.PIE.To(5)))';
                Per2(i,:) = histc(MI{i}(CH{i} == 6),(BurstData.PIE.From(6):BurstData.PIE.To(6)))';
            end
            
            Mic{1} = zeros(numel(MI),numel((TauFitData.StartPar{1}+1):TauFitData.Length{1}));
            Mic{2} = zeros(numel(MI),numel((TauFitData.StartPar{2}+1):TauFitData.Length{2}));
            
            %%% Shift Microtimes
            Par1 = Par1(:,(TauFitData.StartPar{1}+1):TauFitData.Length{1});
            Per1 = circshift(Per1,[0,TauFitData.ShiftPer{1}]);
            Per1 = Per1(:,(TauFitData.StartPar{1}+1):TauFitData.Length{1});
            
            Mic{1} = (1-3*l2)*G{1}*Par1+(2-3*l1)*Per1;
            clear Par1 Per1
            
            Par2 = Par2(:,(TauFitData.StartPar{2}+1):TauFitData.Length{2});
            Per2 = circshift(Per2,[0,TauFitData.ShiftPer{2}]);
            Per2 = Per2(:,(TauFitData.StartPar{2}+1):TauFitData.Length{2});
            
            Mic{2} = (1-3*l2)*G{2}*Par2+(2-3*l1)*Per2;
            clear Par2 Per2
            
            %%% Rebin to improve speed
            Mic1 = zeros(numel(MI),floor(size(Mic{1},2)/new_bin_width));
            Mic2 = zeros(numel(MI),floor(size(Mic{2},2)/new_bin_width));
            
            parfor i = 1:numel(MI)
                Mic1(i,:) = downsamplebin(Mic{1}(i,:),new_bin_width);
                Mic2(i,:) = downsamplebin(Mic{2}(i,:),new_bin_width);
            end
            
            Mic{1} = Mic1'; clear Mic1;
            Mic{2} = Mic2'; clear Mic2;
            
            %% Fitting...
            %%% Prepare the fit inputs
            lt = zeros(numel(MI),2);
            for chan = 1:2
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
                
                scat = SCATTER{chan};
                model = MODEL{chan};
                parfor i = 1:size(Mic{chan},2)
                    if fraction_bg(i) == 1
                        lt(i,chan) = NaN;
                    else
                        %%% Implementation of burst-wise background correction
                        %%% Calculate Fractions of Background and Signal
                        % if 50% of signal is background, fraction_bg in the following model will be approximately 0.5
                        modelfun = (1-fraction_bg(i)).*model + fraction_bg(i).*scat(:,ones(steps_tau+1,1));
                        [lt(i,chan),~] = LifetimeFitMLE(Mic{chan}(:,i),modelfun,range);
                    end
                end
                lifetime{j} = lt;
            end
            Progress(j/(numel(parts)-1),h.Progress_Axes,h.Progress_Text,'Fitting Data...');
        end
        lifetime = vertcat(lifetime{:});
        %% Save the result
        Progress(1,h.Progress_Axes,h.Progress_Text,'Saving...');
        idx_tauGG = strcmp('Lifetime GG [ns]',BurstData.NameArray);
        idx_tauRR = strcmp('Lifetime RR [ns]',BurstData.NameArray);
        BurstData.DataArray(:,idx_tauGG) = lifetime(:,1);
        BurstData.DataArray(:,idx_tauRR) = lifetime(:,2);
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
        background{1} = BurstData.Background.Background_BBpar + BurstData.Background.Background_BBperp;
        background{2} = BurstData.Background.Background_GGpar + BurstData.Background.Background_GGperp;
        background{3} = BurstData.Background.Background_RRpar + BurstData.Background.Background_RRperp;
        %% Prepare the data
        for chan = 1:3
            % call Update_plots to get the correctly shifted Scatter and IRF directly from the plot
            %h.ChannelSelect_Popupmenu.Value = chan;
            %Update_Plots(obj)
            %Irf = G{chan}*(1-3*l2)*h.Plots.IRF_Par.YData+(2-3*l1)*h.Plots.IRF_Per.YData;
            %%% Changed this back so a better correction of the IRF can be
            %%% performed, for which the total IRF pattern is needed!
            %%% Apply the shift to the parallel IRF channel
            hIRF_par = circshift(TauFitData.hIRF_Par{chan},[0,TauFitData.IRFShift{chan}])';
            %%% Apply the shift to the perpendicular IRF channel
            hIRF_per = circshift(TauFitData.hIRF_Per{chan},[0,TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan}])';
            IRFPattern = G{chan}+(1-3*l2)*hIRF_par(1:TauFitData.Length{chan}) + (2-3*l1)*hIRF_per(1:TauFitData.Length{chan});
            IRFPattern = IRFPattern'./sum(IRFPattern);
            %%% additional processing of the IRF to remove constant background
            IRFPattern = IRFPattern - mean(IRFPattern(end-round(numel(IRFPattern)/10):end)); IRFPattern(IRFPattern<0) = 0;
            Irf =  IRFPattern((TauFitData.StartPar{chan}+1):TauFitData.IRFLength{chan});
            
            %Irf = Irf-min(Irf(Irf~=0));
            Irf = Irf./sum(Irf);
            IRF{chan} = [Irf zeros(1,TauFitData.Length{chan}-numel(Irf))];
            Scatter = G{chan}*(1-3*l2)*h.Plots.Scat_Par.YData + (2-3*l1)*h.Plots.Scat_Per.YData;
            SCATTER{chan} = Scatter./sum(Scatter);
            Length{chan} = numel(Scatter)-1;
        end
        
        Progress(0,h.Progress_Axes,h.Progress_Text,'Fitting Data...');
        %%% Process in Chunk
        %%% Prepare Chunks:
        parts = (floor(linspace(1,numel(Microtime),21)));parts(1) = 0;
        %%% Preallocate lifetime array
        lifetime{1} = cell(numel(parts)-1,1);
        lifetime{2} = cell(numel(parts)-1,1);
        lifetime{3} = cell(numel(parts)-1,1);
        %%% Prepare Fit Model
        mean_tau = 5;
        range_tau = 9.98;
        steps_tau = 2111;
        range = mean_tau-range_tau/2:range_tau/steps_tau:mean_tau+range_tau/2;
        for chan = 1:3
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
        
        for j = 1:(numel(parts)-1)
            MI = Microtime((parts(j)+1):parts(j+1));
            CH = Channel((parts(j)+1):parts(j+1));
            DUR = duration((parts(j)+1):parts(j+1));
            %%% Create array of histogrammed microtimes
            Par1 = zeros(numel(MI),numel(BurstData.PIE.From(1):BurstData.PIE.To(1)));
            Per1 = zeros(numel(MI),numel(BurstData.PIE.From(2):BurstData.PIE.To(2)));
            Par2 = zeros(numel(MI),numel(BurstData.PIE.From(7):BurstData.PIE.To(7)));
            Per2 = zeros(numel(MI),numel(BurstData.PIE.From(8):BurstData.PIE.To(8)));
            Par3 = zeros(numel(MI),numel(BurstData.PIE.From(11):BurstData.PIE.To(11)));
            Per3 = zeros(numel(MI),numel(BurstData.PIE.From(12):BurstData.PIE.To(12)));
            
            parfor i = 1:numel(MI)
                Par1(i,:) = histc(MI{i}(CH{i} == 1),(BurstData.PIE.From(1):BurstData.PIE.To(1)))';
                Per1(i,:) = histc(MI{i}(CH{i} == 2),(BurstData.PIE.From(2):BurstData.PIE.To(2)))';
                Par2(i,:) = histc(MI{i}(CH{i} == 7),(BurstData.PIE.From(7):BurstData.PIE.To(7)))';
                Per2(i,:) = histc(MI{i}(CH{i} == 8),(BurstData.PIE.From(8):BurstData.PIE.To(8)))';
                Par3(i,:) = histc(MI{i}(CH{i} == 11),(BurstData.PIE.From(11):BurstData.PIE.To(11)))';
                Per3(i,:) = histc(MI{i}(CH{i} == 12),(BurstData.PIE.From(12):BurstData.PIE.To(12)))';
            end
            
            Mic{1} = zeros(numel(MI),numel((TauFitData.StartPar{1}+1):TauFitData.Length{1}));
            Mic{2} = zeros(numel(MI),numel((TauFitData.StartPar{2}+1):TauFitData.Length{2}));
            Mic{3} = zeros(numel(MI),numel((TauFitData.StartPar{3}+1):TauFitData.Length{3}));
            
            %%% Shift Microtimes
            Par1 = Par1(:,(TauFitData.StartPar{1}+1):TauFitData.Length{1});
            Per1 = circshift(Per1,[0,TauFitData.ShiftPer{1}]);
            Per1 = Per1(:,(TauFitData.StartPar{1}+1):TauFitData.Length{1});
            
            Mic{1} = (1-3*l2)*G{1}*Par1+(2-3*l1)*Per1;
            clear Par1 Per
            
            Par2 = Par2(:,(TauFitData.StartPar{2}+1):TauFitData.Length{2});
            Per2 = circshift(Per2,[0,TauFitData.ShiftPer{2}]);
            Per2 = Per2(:,(TauFitData.StartPar{2}+1):TauFitData.Length{2});
            
            Mic{2} = (1-3*l2)*G{2}*Par2+(2-3*l1)*Per2;
            clear Par2 Per2
            
            Par3 = Par3(:,(TauFitData.StartPar{3}+1):TauFitData.Length{3});
            Per3 = circshift(Per3,[0,TauFitData.ShiftPer{3}]);
            Per3 = Per3(:,(TauFitData.StartPar{3}+1):TauFitData.Length{3});
            
            Mic{3} = (1-3*l2)*G{3}*Par3+(2-3*l1)*Per3;
            clear Par3 Per3
            
            %%% Rebin to improve speed
            Mic1 = zeros(numel(MI),floor(size(Mic{1},2)/new_bin_width));
            Mic2 = zeros(numel(MI),floor(size(Mic{2},2)/new_bin_width));
            Mic3 = zeros(numel(MI),floor(size(Mic{3},2)/new_bin_width));
            parfor i = 1:numel(MI)
                Mic1(i,:) = downsamplebin(Mic{1}(i,:),new_bin_width);
                Mic2(i,:) = downsamplebin(Mic{2}(i,:),new_bin_width);
                Mic3(i,:) = downsamplebin(Mic{3}(i,:),new_bin_width);
            end
            Mic{1} = Mic1'; clear Mic1;
            Mic{2} = Mic2'; clear Mic2;
            Mic{3} = Mic3'; clear Mic3;
            
            %% Fit
            %%% Preallocate fit outputs
            lt = zeros(numel(MI),3);
            for chan = 1:3
                %%% Calculate Background fraction
                bg = DUR.*background{chan};
                signal = sum(Mic{chan},1)';
                
                use_bg = h.BackgroundInclusion_checkbox.Value;
                if use_bg == 1
                    fraction_bg = bg./signal;fraction_bg(fraction_bg>1) = 1;
                else
                    fraction_bg = zeros(size(bg,1),size(bg,2));
                end
                
                scat = SCATTER{chan};
                model = MODEL{chan};
                parfor i = 1:size(Mic{chan},2)
                    if fraction_bg(i) == 1
                        lt(i,chan) = NaN;
                    else
                        %%% Implementation of burst-wise background correction
                        %%% Calculate Fractions of Background and Signal
                        modelfun = (1-fraction_bg(i)).*model + fraction_bg(i).*scat(:,ones(steps_tau+1,1));
                        [lt(i,chan),~] = LifetimeFitMLE(Mic{chan}(:,i),modelfun,range);
                    end
                end
                lifetime{j} = lt;
            end
            Progress(j/(numel(parts)-1),h.Progress_Axes,h.Progress_Text,'Fitting Data...');
        end
        lifetime = vertcat(lifetime{:});
        %% Save the result
        Progress(1,h.Progress_Axes,h.Progress_Text,'Saving...');
        idx_tauBB = strcmp('Lifetime BB [ns]',BurstData.NameArray);
        idx_tauGG = strcmp('Lifetime GG [ns]',BurstData.NameArray);
        idx_tauRR = strcmp('Lifetime RR [ns]',BurstData.NameArray);
        BurstData.DataArray(:,idx_tauBB) = lifetime(:,1);
        BurstData.DataArray(:,idx_tauGG) = lifetime(:,2);
        BurstData.DataArray(:,idx_tauRR) = lifetime(:,3);
end
save(TauFitData.FileName,'BurstData');
Progress(1,h.Progress_Axes,h.Progress_Text,'Done');
%%% Change the Color of the Button in Pam
hPam = findobj('Tag','Pam');
handlesPam = guidata(hPam);
handlesPam.Burst.BurstLifetime_Button.ForegroundColor = [0 0.8 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Below here, functions used for the fits start %%%%%%%%%%%%%%%%%%%%%%%%
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
Parameters{7} = {'Tau [ns]','Rho1 [ns]','Rho2 [ns]','r0','r_infinity','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};

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
StartPar{7} = {tau1,0,Inf,tau1f;Rho1,0,Inf,Rho1f;Rho2,0,Inf,Rho2f;r0,0,0.4,r0f;rinf,0,0.4,rinff;ScatPar,0,1,ScatParf;ScatPer,0,1,ScatPerf...
    ;BackPar,0,1,BackParf;BackPer,0,1,BackPerf;l1,0,1,l1f;l2,0,1,l2f;IRF,0,0,IRFf};

startpar = StartPar{model};
names = Parameters{model};

function UpdateOptions(obj,~)
h = guidata(obj);
global UserValues TauFitData
%%% only store G if TauFit was used in BurstFramework, since only here the
%%% assignment of channels is valid
if any(strcmp(TauFitData.Who,{'Burstwise','BurstBrowser'}))
    chan = h.ChannelSelect_Popupmenu.Value;
else
    chan = TauFitData.chan;
end
UserValues.TauFit.G{chan} = str2double(h.G_factor_edit.String);
UserValues.TauFit.l1 = str2double(h.l1_edit.String);
UserValues.TauFit.l2 = str2double(h.l2_edit.String);