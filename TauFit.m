function TauFit
global UserValues TauFitData
h.TauFit = findobj('Tag','TauFit');

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
        'defaultUicontrolFontName','Times',...
        'defaultAxesFontName','Times',...
        'defaultTextFontName','Times',...
        'defaultAxesYColor',Look.Fore,...
        'Toolbar','figure',...
        'UserData',[],...
        'BusyAction','cancel',...
        'OuterPosition',[0.01 0.1 0.68 0.8],...
        'CloseRequestFcn',@Close_TauFit,...
        'Visible','on');
    %%% Sets background of axes and other things
    whitebg(Look.Fore);
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
    h.Microtime_Plot_Menu = uicontextmenu;
    
    %%% Main Microtime Plot
    h.Microtime_Plot = axes(...
        'Parent',h.TauFit_Panel,...
        'Units','normalized',...
        'Position',[0.05 0.05 0.9 0.8],...
        'Tag','Microtime_Plot',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Box','on');
    
    %%% Create Graphs
    hold on;
    h.Plots.Decay_Sum = plot([0 1],[0 0],'--k');
    h.Plots.Decay_Par = plot([0 1],[0 0],'--g');
    h.Plots.Decay_Per = plot([0 1],[0 0],'--r');
    h.Plots.IRF_Par = plot([0 1],[0 0],'.g');
    h.Plots.IRF_Per = plot([0 1],[0 0],'.r');
    h.Plots.FitPreview = plot([0 1],[0 0],'k');
    
    h.Microtime_Plot.XLim = [0 1];
    h.Microtime_Plot.YLim = [0 1];
    h.Microtime_Plot.XLabel.Color = Look.Fore;
    h.Microtime_Plot.XLabel.String = 'Microtime';
    h.Microtime_Plot.YLabel.Color = Look.Fore;
    h.Microtime_Plot.YLabel.String = 'Intensity [Counts]';
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
        'XTick',[],...
        'Box','on');
    hold on;
    h.Plots.Residuals = plot([0 1],[0 0],'-k');
    h.Plots.Residuals_ZeroLine = plot([0 1],[0 0],'-k');
    h.Residuals_Plot.YLabel.Color = Look.Fore;
    h.Residuals_Plot.YLabel.String = 'Weighted Residuals';
    h.Residuals_Plot.XGrid = 'on';
    h.Residuals_Plot.YGrid = 'on';
    
    %%% Result Plot (Replaces Microtime Plot after fit is done)
    h.Result_Plot = axes(...
        'Parent',h.TauFit_Panel,...
        'Units','normalized',...
        'Position',[0.05 0.05 0.9 0.8],...
        'Tag','Microtime_Plot',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Box','on',...
        'Visible','on');
    
    h.Result_Plot.XLim = [0 1];
    h.Result_Plot.YLim = [0 1];
    h.Result_Plot.XLabel.Color = Look.Fore;
    h.Result_Plot.XLabel.String = 'Microtime';
    h.Result_Plot.YLabel.Color = Look.Fore;
    h.Result_Plot.YLabel.String = 'Intensity [Counts]';
    h.Result_Plot.XGrid = 'on';
    h.Result_Plot.YGrid = 'on';
    linkaxes([h.Result_Plot, h.Residuals_Plot],'x');
    
    hold on;
    h.Plots.DecayResult = plot([0 1],[0 0],'--k');
    h.Plots.FitResult = plot([0 1],[0 0],'k');
    
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
        'Position',[0.2 0.84 0.8 0.1],...
        'Tag','StartPar_Slider',...
        'Callback',@Update_Plots);
    
    h.StartPar_Edit = uicontrol(...
        'Parent',h.Slider_Panel,...
        'Style','edit',...
        'Tag','StartPar_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.85 0.05 0.1],...
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
        'Position',[0.01 0.85 0.14 0.1],...
        'Tag','StartPar_Text');
    
    %%% Slider for Selection of Length
    h.Length_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.64 0.8 0.1],...
        'Tag','Length_Slider',...
        'Callback',@Update_Plots);
    
    h.Length_Edit = uicontrol(...
        'Parent',h.Slider_Panel,...
        'Style','edit',...
        'Tag','Length_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.65 0.05 0.1],...
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
        'Position',[0.01 0.65 0.14 0.1],...
        'Tag','Length_Text');
    
    %%% Slider for Selection of Perpendicular Shift
    h.ShiftPer_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.44 0.8 0.1],...
        'Tag','ShiftPer_Slider',...
        'Callback',@Update_Plots);
    
    h.ShiftPer_Edit = uicontrol(...
        'Parent',h.Slider_Panel,...
        'Style','edit',...
        'Tag','ShiftPer_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.45 0.05 0.1],...
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
        'Position',[0.01 0.45 0.14 0.1],...
        'Tag','ShiftPer_Text');
    
    %%% Slider for Selection of IRF Shift
    h.IRFShift_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.24 0.8 0.1],...
        'Tag','IRFShift_Slider',...
        'Callback',@Update_Plots);
    
    h.IRFShift_Edit = uicontrol(...
        'Parent',h.Slider_Panel,...
        'Style','edit',...
        'Tag','IRFShift_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.25 0.05 0.1],...
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
        'Position',[0.01 0.25 0.14 0.1],...
        'Tag','IRFShift_Text');
    
    %%% Slider for Selection of IRF Length
    h.IRFLength_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.04 0.8 0.1],...
        'Tag','IRFLength_Slider',...
        'Callback',@Update_Plots);
    
    h.IRFLength_Edit = uicontrol(...
        'Parent',h.Slider_Panel,...
        'Style','edit',...
        'Tag','IRFLength_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.05 0.05 0.1],...
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
        'Position',[0.01 0.05 0.14 0.1],...
        'Tag','IRFLength_Text');
    
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
    FitMethods = {'Single Exponential','Biexponential','Three Exponentials',...
        'Distribution','Distribution plus Donor only'};
    h.FitMethod_Popupmenu = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','Popupmenu',...
        'Tag','FitMethod_Popupmenu',...
        'Units','normalized',...
        'Position',[0.35 0.25 0.6 0.1],...
        'String',FitMethods,...
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
        'Position',[0.05 0.4 0.2 0.2],...
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
        'Position',[0 0 1 1],...
        'ColumnName',{'Value','LB','UB','Fixed'},...
        'ColumnFormat',{'numeric','numeric','numeric','logical'},...
        'RowName',{'Test'},...
        'ColumnEditable',[true true true true],...
        'ColumnWidth',{'auto',50,50,50},...
        'Tag','FitPar_Table');
    
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
end
%% Initialize Parameters
TauFitData.Length = 1;
TauFitData.StartPar = 0;
TauFitData.ShiftPer = 0;
TauFitData.IRFLength = 1;
TauFitData.IRFShift = 0;
TauFitData.FitType = h.FitMethod_Popupmenu.String{h.FitMethod_Popupmenu.Value};
TauFitData.FitMethods = FitMethods;

guidata(gcf,h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Load the Microtime Histogram of selected PIE Channels %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Data(~,~)
global UserValues TauFitData PamMeta FileInfo
h = guidata(findobj('Tag','TauFit'));
%%% find the number of the selected PIE channels
PIEChannel_Par = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{1}));
PIEChannel_Per = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{2}));

%%% Microtime Histogram of Parallel Channel
TauFitData.hMI_Par = PamMeta.MI_Hist{UserValues.PIE.Detector(PIEChannel_Par),UserValues.PIE.Router(PIEChannel_Par)}(...
    UserValues.PIE.From(PIEChannel_Par):UserValues.PIE.To(PIEChannel_Par) );
%%% Microtime Histogram of Perpendicular Channel
TauFitData.hMI_Per = PamMeta.MI_Hist{UserValues.PIE.Detector(PIEChannel_Per),UserValues.PIE.Router(PIEChannel_Per)}(...
    UserValues.PIE.From(PIEChannel_Per):UserValues.PIE.To(PIEChannel_Per) );

TauFitData.XData_Par = (UserValues.PIE.From(PIEChannel_Par):UserValues.PIE.To(PIEChannel_Par))*FileInfo.SyncPeriod*1E9/FileInfo.MI_Bins;
TauFitData.XData_Per = (UserValues.PIE.From(PIEChannel_Per):UserValues.PIE.To(PIEChannel_Per))*FileInfo.SyncPeriod*1E9/FileInfo.MI_Bins;
%%% Plot the Data

h.Plots.Decay_Par.XData = TauFitData.XData_Par;
h.Plots.Decay_Per.XData = TauFitData.XData_Per;
h.Plots.Decay_Par.YData = TauFitData.hMI_Par;
h.Plots.Decay_Per.YData = TauFitData.hMI_Per;
h.Microtime_Plot.XLim = [min([TauFitData.XData_Par TauFitData.XData_Per]) max([TauFitData.XData_Par TauFitData.XData_Per])];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  General Function to Update Plots when something changed %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(obj,~)
global UserValues TauFitData PamMeta FileInfo
h = guidata(findobj('Tag','TauFit'));

%%% Cases to consider:
%%% obj is empty or is Button for LoadData/LoadIRF
%%% Data has been changed (PIE Channel changed, IRF loaded...)
if isempty(obj) || obj == h.LoadData_Button
    %%% find the number of the selected PIE channels
    PIEChannel_Par = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{1}));
    PIEChannel_Per = find(strcmp(UserValues.PIE.Name,UserValues.TauFit.PIEChannelSelection{2}));
    
    %%% Microtime Histogram of Parallel Channel
    TauFitData.hMI_Par = PamMeta.MI_Hist{UserValues.PIE.Detector(PIEChannel_Par),UserValues.PIE.Router(PIEChannel_Par)}(...
        UserValues.PIE.From(PIEChannel_Par):UserValues.PIE.To(PIEChannel_Par) );
    %%% Microtime Histogram of Perpendicular Channel
    TauFitData.hMI_Per = PamMeta.MI_Hist{UserValues.PIE.Detector(PIEChannel_Per),UserValues.PIE.Router(PIEChannel_Per)}(...
        UserValues.PIE.From(PIEChannel_Per):UserValues.PIE.To(PIEChannel_Per) );
    %%% Read out the Microtime Histograms of the IRF for the two channels
    TauFitData.hIRF_Par = UserValues.TauFit.IRF(UserValues.PIE.Detector(PIEChannel_Par),UserValues.PIE.From(PIEChannel_Par):UserValues.PIE.To(PIEChannel_Par));
    TauFitData.hIRF_Per = UserValues.TauFit.IRF(UserValues.PIE.Detector(PIEChannel_Per),UserValues.PIE.From(PIEChannel_Per):UserValues.PIE.To(PIEChannel_Per));
    %%% Normalize IRF for better Visibility
    TauFitData.hIRF_Par = (TauFitData.hIRF_Par./max(TauFitData.hIRF_Par)).*max(TauFitData.hMI_Par);
    TauFitData.hIRF_Per = (TauFitData.hIRF_Per./max(TauFitData.hIRF_Per)).*max(TauFitData.hMI_Per);
    %%% Generate XData
    TauFitData.XData_Par = (UserValues.PIE.From(PIEChannel_Par):UserValues.PIE.To(PIEChannel_Par)) - UserValues.PIE.From(PIEChannel_Par);
    TauFitData.XData_Per = (UserValues.PIE.From(PIEChannel_Per):UserValues.PIE.To(PIEChannel_Per)) - UserValues.PIE.From(PIEChannel_Per);

    %%% Plot the Data
    h.Plots.Decay_Par.XData = TauFitData.XData_Par;
    h.Plots.Decay_Per.XData = TauFitData.XData_Per;
    h.Plots.IRF_Par.XData = TauFitData.XData_Par;
    h.Plots.IRF_Per.XData = TauFitData.XData_Per;
    h.Plots.Decay_Par.YData = TauFitData.hMI_Par;
    h.Plots.Decay_Per.YData = TauFitData.hMI_Per;
    h.Plots.IRF_Par.YData = TauFitData.hIRF_Par;
    h.Plots.IRF_Per.YData = TauFitData.hIRF_Per;
    h.Microtime_Plot.XLim = [min([TauFitData.XData_Par TauFitData.XData_Per]) max([TauFitData.XData_Par TauFitData.XData_Per])];
    h.Microtime_Plot.YLimMode = 'auto';
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
    %h.ShiftPer_Slider.Min = (-1)*max([0 TauFitData.XData_Per(1)-TauFitData.XData_Par(1)]);
    %h.ShiftPer_Slider.Max = max([0 TauFitData.XData_Par(end)-TauFitData.XData_Per(1)]);
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
    %h.IRFShift_Slider.Min = (-1)*max([0 TauFitData.XData_IRFPar(1)-TauFitData.XData_Par(1)]);
    %h.IRFShift_Slider.Max = max([0 TauFitData.XData_Par(end)-TauFitData.XData_IRFPar(1)]);
    h.IRFShift_Slider.Min = -floor(TauFitData.MaxLength/10);
    h.IRFShift_Slider.Max = floor(TauFitData.MaxLength/10);
    h.IRFShift_Slider.Value = 0;
    TauFitData.IRFShift = 0;
    h.IRFShift_Edit.String = num2str(TauFitData.IRFShift);
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
end
%%% Update Edit Boxes if Slider was used and Sliders if Edit Box was used
switch obj.Style
    case 'slider'
        h.StartPar_Edit.String = num2str(TauFitData.StartPar);
        h.Length_Edit.String = num2str(TauFitData.Length);
        h.ShiftPer_Edit.String = num2str(TauFitData.ShiftPer);
        h.IRFLength_Edit.String = num2str(TauFitData.IRFLength);
        h.IRFShift_Edit.String = num2str(TauFitData.IRFShift);
    case 'edit'
        h.StartPar_Slider.Value = TauFitData.StartPar;
        h.Length_Slider.Value = TauFitData.Length;
        h.ShiftPer_Slider.Value = TauFitData.ShiftPer;
        h.IRFLength_Slider.Value = TauFitData.IRFLength;
        h.IRFShift_Slider.Value = TauFitData.IRFShift;
end
%%% Update Plot
% %%% Apply the shift to the parallel channel
% h.Plots.Decay_Par.XData = TauFitData.XData_Par(1:TauFitData.Length)-TauFitData.StartPar;
% h.Plots.Decay_Par.YData = TauFitData.hMI_Par(1:TauFitData.Length);
% %%% Apply the shift to the perpendicular channel
% h.Plots.Decay_Per.XData = TauFitData.XData_Per((1+max([0 TauFitData.ShiftPer])):min([TauFitData.MaxLength (TauFitData.Length+TauFitData.ShiftPer)]))-(TauFitData.StartPar+TauFitData.ShiftPer);
% h.Plots.Decay_Per.YData = TauFitData.hMI_Per((1+max([0 TauFitData.ShiftPer])):min([TauFitData.MaxLength (TauFitData.Length+TauFitData.ShiftPer)]));
% %%% Apply the shift to the parallel IRF channel
% h.Plots.IRF_Par.XData = TauFitData.XData_Par((1+max([0 TauFitData.IRFShift])):min([TauFitData.MaxLength (TauFitData.IRFLength+TauFitData.IRFShift)]))-(TauFitData.StartPar+TauFitData.IRFShift);
% h.Plots.IRF_Par.YData = TauFitData.hIRF_Par((1+max([0 TauFitData.IRFShift])):min([TauFitData.MaxLength (TauFitData.IRFLength+TauFitData.IRFShift)]));
% %%% Apply the shift to the perpendicular IRF channel
% h.Plots.IRF_Per.XData = TauFitData.XData_Per((1+max([0 (TauFitData.ShiftPer + TauFitData.IRFShift)])):min([TauFitData.MaxLength (TauFitData.IRFLength+TauFitData.IRFShift+TauFitData.ShiftPer)]))-(TauFitData.StartPar+TauFitData.IRFShift+TauFitData.ShiftPer);
% h.Plots.IRF_Per.YData = TauFitData.hIRF_Per((1+max([0 (TauFitData.IRFShift + TauFitData.ShiftPer)])):min([TauFitData.MaxLength (TauFitData.IRFLength+TauFitData.IRFShift+TauFitData.ShiftPer)]));

%%% Make the Microtime Adjustment Plot Visible, hide Result
%h.Microtime_Plot.Visible = 'on';
%h.Result_Plot.Visible = 'off';
h.Microtime_Plot.Parent = h.TauFit_Panel;
h.Result_Plot.Parent = h.HidePanel;
%%% Apply the shift to the parallel channel
h.Plots.Decay_Par.XData = (TauFitData.StartPar:(TauFitData.Length-1)) - TauFitData.StartPar;
h.Plots.Decay_Par.YData = TauFitData.hMI_Par((TauFitData.StartPar+1):TauFitData.Length)';
%%% Apply the shift to the perpendicular channel
h.Plots.Decay_Per.XData = (TauFitData.StartPar:(TauFitData.Length-1)) - TauFitData.StartPar;
hMI_Per_Shifted = circshift(TauFitData.hMI_Per,[TauFitData.ShiftPer,0])';
h.Plots.Decay_Per.YData = hMI_Per_Shifted((TauFitData.StartPar+1):TauFitData.Length);
%%% Apply the shift to the parallel IRF channel
h.Plots.IRF_Par.XData = (TauFitData.StartPar:(TauFitData.IRFLength-1)) - TauFitData.StartPar;
hIRF_Par_Shifted = circshift(TauFitData.hIRF_Par,[0,TauFitData.IRFShift])';
h.Plots.IRF_Par.YData = hIRF_Par_Shifted((TauFitData.StartPar+1):TauFitData.IRFLength);
%%% Apply the shift to the perpendicular IRF channel
h.Plots.IRF_Per.XData = (TauFitData.StartPar:(TauFitData.IRFLength-1)) - TauFitData.StartPar;
hIRF_Per_Shifted = circshift(TauFitData.hIRF_Per,[0,TauFitData.IRFShift+TauFitData.ShiftPer])';
h.Plots.IRF_Per.YData = hIRF_Per_Shifted((TauFitData.StartPar+1):TauFitData.IRFLength);

axis('tight');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Function for loading the IRF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hIRF_Par,hIRF_Per] = Load_IRF(PIEChannel1,PIEChannel2)
global UserValues

%%% Dialog box for selecting files to be loaded
[FileName, Path, Type] = uigetfile({'*0.spc','B&H-SPC files recorded with FabSurf (*0.spc)';...
                                    '*_m1.spc','B&H-SPC files recorded with B&H-Software (*_m1.spc)'}, 'Choose a TCSPC data file for IRF',UserValues.File.Path,'MultiSelect', 'on');

%%% Only execues if any file was selected
if iscell(FileName) || ~all(FileName==0)    
    %%% Transforms FileName into cell, if it is not already
    %%%(e.g. when only one file was selected)
    if ~iscell(FileName)
        FileName={FileName};
    end
    %%% Sorts FileName by alphabetical order
    FileName=sort(FileName);
    %%% Clears previously loaded data
    FileInfo=[];
    MT=cell(1,1);
    MI=cell(1,1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Checks which file type was selected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch (Type)        
        case 1 
            %% 1: .spc Files generated with Fabsurf    
            FileType = 'FabsurfSPC';
            %%% Reads info file generated by Fabsurf
            Fabsurf=FabsurfInfo(fullfile(Path,FileName{1}));
            %%% General FileInfo
            NumberOfFiles=numel(FileName);
            Type=Type;
            MI_Bins=4096;
            MeasurementTime=Fabsurf.Imagetime/1000;
            SyncPeriod=Fabsurf.RepRate/1000;
            Lines=Fabsurf.Imagelines;
            LineTimes=zeros(Lines+1,numel(FileName));
            Pixels=Fabsurf.Imagelines^2;   
            FileName=FileName;
            Path=Path;
            %%% Initializes microtime and macotime arrays
            MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));  
            
            Totaltime=0;
            %%% Reads all selected files
            for i=1:numel(FileName)               
                %%% Calculates Imagetime in clock ticks for concaternating
                %%% files                
                Info=FabsurfInfo(fullfile(Path,FileName{i}),1);
                Imagetime=round(Info.Imagetime/1000/FileInfo.SyncPeriod);
                %%% Checks, which cards to load
                card=unique(UserValues.Detector.Det);
                %%% Checks, which and how many card exist for each file
                for j=card;
                    if ~exist(fullfile(Path,[FileName{i}(1:end-5) num2str(j-1) '.spc']),'file')
                        card(card==j)=[];
                    end
                end                
                
                Linetimes=[];
                %%% Reads data for each tcspc card
                for j=card
                    %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
                    [MT, MI, PLF,~] = Read_BH(fullfile(Path,[FileName{i}(1:end-5) num2str(j-1) '.spc']),Inf,[0 0 0]);
                    %%% Finds, which routing bits to use
                    Rout=unique(UserValues.Detector.Rout(UserValues.Detector.Det==j))';
                    Rout(Rout>numel(MI))=[];
                    %%% Concaternates data to previous files and adds Imagetime
                    %%% to consecutive files
                    if any(~cellfun(@isempty,MI))
                        for k=Rout
                            %%% Removes photons detected after "official"
                            %%% end of file are discarded
                            MI{k}(MT{k}>Imagetime)=[];
                            MT{k}(MT{k}>Imagetime)=[];
                            MT{j,k}=[MT{j,k}; Totaltime + MT{k}];   MT{k}=[];
                            MI{j,k}=[MI{j,k}; MI{k}];   MI{k}=[];
                        end
                    end
                    %%% Determines last photon for each file
                    for k=find(~cellfun(@isempty,MT(j,:)));
                        LastPhoton{j,k}(i)=numel(MT{j,k});
                    end
                    
                    %%% Determines, if linesync was used
                    if isempty(Linetimes) && ~isempty(PLF{1})
                        Linetimes=[0 PLF{1}];
                    elseif isempty(Linetimes) && ~isempty(PLF{2})
                        Linetimes=[0 PLF{2}];
                    elseif isempty(Linetimes) && ~isempty(PLF{3})
                        Linetimes=[0 PLF{3}];
                    end
                end 
                %%% Creates linebreak entries
                if isempty(Linetimes)
                    LineTimes(:,i)=linspace(0,FileInfo.MeasurementTime/FileInfo.SyncPeriod,FileInfo.Lines+1)+Totaltime;
                elseif numel(Linetimes)==FileInfo.Lines+1
                    LineTimes(:,i)=Linetimes+Totaltime;                    
                elseif numel(Linetimes)<FileInfo.Lines+1
                    %%% I was to lazy to program this case out yet
                end
                %%% Calculates total time to get one trace from several
                %%% files
                Totaltime=Totaltime + Imagetime;

            end
        case 2
            %% 2: .spc Files generated with B&H Software
            %%% Usually, here no Imaging Information is needed
            FileType = 'SPC';           
            %%% General FileInfo
            NumberOfFiles=numel(FileName);
            Type=Type;
            MI_Bins=4096;
            MeasurementTime=[];
            SyncPeriod= [];
            TACRange = [];
            Lines=1;
            LineTimes=[];
            Pixels=1;   
            FileName=FileName;
            Path=Path;
            
            %%% Initializes microtime and macotime arrays
            MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));  
            
            %%% Reads all selected files
            for i=1:numel(FileName)
                %%% there are a number of *_m(i).spc files associated with the
                %%% *_m1.spc file
                
                %%% Checks, which cards to load
                card=unique(UserValues.Detector.Det);
                %%% Checks, which and how many card exist for each file
                for j=card;
                    if ~exist(fullfile(Path,[FileName{i}(1:end-5) num2str(j) '.spc']),'file')
                        card(card==j)=[];
                    end
                end      
                %%% if multiple files are loaded, consecutive files need to
                %%% be offset in time with respect to the previous file
                MaxMT = 0;
                if any(~cellfun(@isempty,MT))
                    MaxMT = max(cellfun(@max,MT(~cellfun(@isempty,MT))));
                end
                %%% Reads data for each tcspc card
                for j=card    
                      %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
                    [MT_dummy, MI_dummy, ~, SyncRate] = Read_BH(fullfile(Path,[FileName{i}(1:end-5) num2str(j) '.spc']),Inf,[0 0 0]);
                    
                    if ~exist('SyncPeriod','var')
                        SyncPeriod = 1/SyncRate;
                    end
                    %%% Finds, which routing bits to use
                    Rout=unique(UserValues.Detector.Rout(UserValues.Detector.Det==j))';
                    Rout(Rout>numel(MI))=[];
                    %%% Concaternates data to previous files and adds Imagetime
                    %%% to consecutive files
                    if any(~cellfun(@isempty,MI_dummy))
                        for k=Rout
                            MT{j,k}=[MT{j,k}; MaxMT + MT_dummy{k}];   MT_dummy{k}=[];
                            MI{j,k}=[MI{j,k}; MI_dummy{k}];   MI_dummy{k}=[];
                        end
                    end
                    %%% Determines last photon for each file
                    for k=find(~cellfun(@isempty,MT(j,:)));
                        LastPhoton{j,k}(i)=numel(MT{j,k});
                    end
                end
            end
            MeasurementTime = max(cellfun(@max,MT(~cellfun(@isempty,MT))))*SyncPeriod;
            LineTimes = [0 MeasurementTime];
            try 
                %%% try to read the TACRange from the *_m1.set file
                TACRange = GetTACrange(fullfile(FileInfo.Path,[FileName{1}(1:end-3) 'set']));
            catch 
                %%% instead, approximate the TAC range from the microtime
                %%% range and Repetition Rate
                MicrotimeRange = double(max(cellfun(@(x) max(x)-min(x),MI(~cellfun(@isempty,MI)))));
                TACRange = (MI_Bins/MicrotimeRange)*SyncPeriod;
            end
    end
%%% Applies detector shift immediately after loading data    
%Calibrate_Detector([],[],0) 
end
%%% Prepare the histoograms
hIRF_Par = histc(MI{UserValues.PIE.Detector(PIEChannel1),UserValues.PIE.Router(PIEChannel1)},0:(MI_Bins-1));
hIRF_Par = hIRF_Par(UserValues.PIE.From(PIEChannel1):UserValues.PIE.To(PIEChannel1));

hIRF_Per = histc(MI{UserValues.PIE.Detector(PIEChannel2),UserValues.PIE.Router(PIEChannel2)},0:(MI_Bins-1));
hIRF_Per = hIRF_Per(UserValues.PIE.From(PIEChannel2):UserValues.PIE.To(PIEChannel2));

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
Pam=findobj('Tag','Pam');
FCSFit=findobj('Tag','FCSFit');
if isempty(Pam) && isempty(FCSFit)
    clear global -regexp UserValues
end
delete(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Executes on Method selection change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Method_Selection(obj,~)
global TauFitData
TauFitData.FitType = obj.String{obj.Value};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Fit the Data with selected Model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Start_Fit(obj,~)
global TauFitData FileInfo
h = guidata(obj);
%% Read out the data from the plots
% xmin_decay = max([1 h.Plots.Decay_Par.XData(1) h.Plots.Decay_Per.XData(1)]);
% xmax_decay = min([h.Plots.Decay_Par.XData(end) h.Plots.Decay_Per.XData(end)]);
% TauFitData.FitData.Decay_Par = h.Plots.Decay_Par.YData((h.Plots.Decay_Par.XData >= xmin_decay) & (h.Plots.Decay_Par.XData <= xmax_decay));
% TauFitData.FitData.Decay_Per = h.Plots.Decay_Per.YData((h.Plots.Decay_Per.XData >= xmin_decay) & (h.Plots.Decay_Per.XData <= xmax_decay));
% %%% read out the scatter pattern (i.e. the total IRF without
% %%% restricting the IRF length)
% TauFitData.FitData.Scatter_Par = circshift(TauFitData.hIRF_Par,[0, -TauFitData.IRFShift]);
% TauFitData.FitData.Scatter_Par = TauFitData.FitData.Scatter_Par((h.Plots.Decay_Par.XData >= xmin_decay) & (h.Plots.Decay_Par.XData <= xmax_decay));
% TauFitData.FitData.Scatter_Per = circshift(TauFitData.hIRF_Per,[0, -(TauFitData.IRFShift + TauFitData.ShiftPer)]);
% TauFitData.FitData.Scatter_Per = TauFitData.FitData.Scatter_Per((h.Plots.Decay_Per.XData >= xmin_decay) & (h.Plots.Decay_Per.XData <= xmax_decay));
% 
% xmin_irf = max([1 h.Plots.IRF_Par.XData(1) h.Plots.IRF_Per.XData(1)]);
% xmax_irf = min([h.Plots.IRF_Par.XData(end) h.Plots.IRF_Per.XData(end)]);
% TauFitData.FitData.IRF_Par = zeros(1,numel(TauFitData.FitData.Scatter_Par));
% TauFitData.FitData.IRF_Par((xmin_irf-xmin_decay+1):(xmax_irf-xmin_decay+1)) = h.Plots.IRF_Par.YData((h.Plots.IRF_Par.XData >= xmin_irf & h.Plots.IRF_Par.XData <= xmax_irf & h.Plots.IRF_Par.XData >= xmin_decay & h.Plots.IRF_Par.XData <= xmax_decay));
% TauFitData.FitData.IRF_Per = zeros(1,numel(TauFitData.FitData.Scatter_Per));
% TauFitData.FitData.IRF_Per((xmin_irf-xmin_decay+1):(xmax_irf-xmin_decay)) = h.Plots.IRF_Per.YData((h.Plots.IRF_Per.XData >= xmin_irf & h.Plots.IRF_Per.XData <= xmax_irf & h.Plots.IRF_Per.XData >= xmin_decay & h.Plots.IRF_Per.XData <= xmax_decay));
TauFitData.FitData.Decay_Par = h.Plots.Decay_Par.YData;
TauFitData.FitData.Decay_Per = h.Plots.Decay_Par.YData;
TauFitData.FitData.IRF_Par = h.Plots.IRF_Par.YData;
TauFitData.FitData.IRF_Per = h.Plots.IRF_Per.YData;
%%% Read out the shifted scatter pattern
Scatter_Par_Shifted = circshift(TauFitData.hIRF_Par,[0,TauFitData.IRFShift])';
TauFitData.FitData.Scatter_Par = Scatter_Par_Shifted((TauFitData.StartPar+1):TauFitData.Length)';
Scatter_Per_Shifted = circshift(TauFitData.hIRF_Per,[0,TauFitData.IRFShift + TauFitData.ShiftPer])';
TauFitData.FitData.Scatter_Per = Scatter_Per_Shifted((TauFitData.StartPar+1):TauFitData.Length)';
%%% initialize inputs for fit
Decay = TauFitData.FitData.Decay_Par+2*TauFitData.FitData.Decay_Per;
Irf = TauFitData.FitData.IRF_Par+2*TauFitData.FitData.IRF_Per;
Irf = Irf-min(Irf(Irf~=0));
Irf = Irf./sum(Irf);
Irf = [Irf zeros(1,numel(Decay)-numel(Irf))];
TauFitData.TACRange = FileInfo.SyncPeriod*1E9;
TauFitData.TACChannelWidth = FileInfo.SyncPeriod*1E9/FileInfo.MI_Bins;
Scatter = TauFitData.FitData.Scatter_Par + 2*TauFitData.FitData.Scatter_Per;
Scatter = Scatter./sum(Scatter);

%%% Update Progressbar
h.Progress_Text.String = 'Fitting...';
switch TauFitData.FitType
    case 'Single Exponential'
        %%% Parameter:
        %%% gamma   - Constant Background
        %%% scatter - Scatter Background (IRF pattern)
        %%% taus    - Lifetimes
        x0 = [0.1,0.1,round(4/TauFitData.TACChannelWidth)];
        lb = [0 0 0];
        ub = [1 1 Inf];
        shift_range = -5:5;
        ignore = 100;
        %%% fit for different IRF offsets and compare the results
        count = 1;
        for i = shift_range
            %%% Update Progressbar
            Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
            [x{count}, res(count), residuals{count}] = lsqcurvefit(@fitfun_1exp,x0,{Irf,Scatter,4096,Decay(ignore:end),i,ignore},Decay(ignore:end),lb,ub);
            count = count +1;
        end
        
        chi2 = cellfun(@(x) sum(x.^2./Decay(ignore:end))/(numel(Decay(ignore:end))-numel(x0)),residuals);
        [~,best_fit] = min(chi2);
        FitFun = fitfun_1exp(x{best_fit},{Irf,Scatter,4096,Decay,shift_range(best_fit),1});
        wres = (Decay-FitFun)./sqrt(Decay);
    case 'Biexponential'
        %%% Parameter:
        %%% A       - Amplitude of first lifetime
        %%% gamma   - Constant Background
        %%% scatter - Scatter Background (IRF pattern)
        %%% taus    - Lifetimes
        x0 = [0.5, 0.1,0.1,round(2/TauFitData.TACChannelWidth),round(4/TauFitData.TACChannelWidth)];
        lb = [0 0 0 round(0.5/TauFitData.TACChannelWidth) round(2/TauFitData.TACChannelWidth)];
        ub = [1 1 1 Inf Inf];
        shift_range = 0:0;
        ignore = 50;
        %%% fit for different IRF offsets and compare the results
        count = 1;
        options = optimoptions('lsqcurvefit','MaxFunEvals',1000);
        for i = shift_range
            %%% Update Progressbar
            Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
            [x{count}, res(count), residuals{count}] = lsqcurvefit(@fitfun_2exp,x0,{Irf,Scatter,4096,Decay(ignore:end),i,ignore},Decay(ignore:end),lb,ub,options);
            count = count +1;
        end
        chi2 = cellfun(@(x) sum(x.^2./Decay(ignore:end))/(numel(Decay(ignore:end))-numel(x0)),residuals);
        [~,best_fit] = min(chi2);
        FitFun = fitfun_2exp(x{best_fit},{Irf,Scatter,4096,Decay(1:end),shift_range(best_fit),1});
        wres = (Decay-FitFun)./sqrt(Decay);
        
end

%%% Reset Progressbar
h.Progress_Text.String = 'Fit done';
%%% Update Plot
h.Microtime_Plot.Parent = h.HidePanel;
h.Result_Plot.Parent = h.TauFit_Panel;

h.Plots.DecayResult.XData = h.Plots.Decay_Par.XData;
h.Plots.DecayResult.YData = Decay;
h.Plots.FitResult.XData = h.Plots.Decay_Par.XData;
h.Plots.FitResult.YData = FitFun;
axis(h.Result_Plot,'tight');
h.Plots.Residuals.XData = h.Plots.Decay_Par.XData;
h.Plots.Residuals.YData = wres;
h.Plots.Residuals_ZeroLine.XData = h.Plots.Decay_Par.XData;
h.Plots.Residuals_ZeroLine.YData = zeros(1,numel(h.Plots.Decay_Par.XData));
disp(['Tau1 = ' num2str(TauFitData.TACChannelWidth*x{best_fit}(3))]);

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
err = sum((z-y).^2./abs(z))/n

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

function y = convol(irf, x)
% convol(irf, x) performs a convolution of the instrumental response 
% function irf with the decay function x. Periodicity (=length(x)) is assumed.

mm = mean(irf(end-10:end));
if size(x,1)==1 || size(x,2)==1
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

function [z] = fitfun_1exp(param, xdata)
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
ignore = xdata{6};

n = length(irf);
t = 1:n;
tp = (1:p)';
gamma = param(1);
scatter = param(2);
tau = param(3:length(param)); tau = tau(:)';
x = exp(-(tp-1)*(1./tau))*diag(1./(1-exp(-p./tau)));
%irs = irf(rem(rem(t-floor(c)-1, n)+n,n)+1);
irs = circshift(irf,[0 c]);
bg = circshift(bg,[0 c]);
z = convol(irs, x);
z = z./sum(z);
z = (1-scatter).*z + scatter*bg';z = z./sum(z);
z = (1-gamma).*z+gamma/numel(z);z = z./sum(z);
z = z(ignore:end);z = z./sum(z);
z = z.*sum(y);
z=z';

function [z] = fitfun_2exp(param, xdata)
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
ignore = xdata{6};

n = length(irf);
t = 1:n;
tp = (1:p)';
A = param(1);
gamma = param(2);
scatter = param(3);
tau = param(4:length(param)); tau = tau(:)';
x = exp(-(tp-1)*(1./tau))*diag(1./(1-exp(-p./tau)));
%irs = irf(rem(rem(t-floor(c)-1, n)+n,n)+1);
irs = circshift(irf,[0 c]);
bg = circshift(bg,[0 c]);
z = convol(irs', x);
z = z./repmat(sum(z,1),size(z,1),1);
%%% combine the two exponentials
z = A*z(:,1) + (1-A)*z(:,2);
z = (1-scatter).*z + scatter*bg';
z = z./sum(z);
z = (1-gamma).*z+gamma/numel(z);
z = z./sum(z);
z = z(ignore:end);
z = z./sum(z);
z = z.*sum(y);
z=z';