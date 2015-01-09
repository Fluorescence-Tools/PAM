function TauFitBurst
global UserValues TauFitBurstData
h.TauFitBurst = findobj('Tag','TauFitBurst');

if isempty(h.TauFitBurst) % Creates new figure, if none exists
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
    h.Microtime_Plot.XLabel.String = 'Microtime [ns]';
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
        'Visible','off');
    
    h.Result_Plot.XLim = [0 1];
    h.Result_Plot.YLim = [0 1];
    h.Result_Plot.XLabel.Color = Look.Fore;
    h.Result_Plot.XLabel.String = 'Microtime [ns]';
    h.Result_Plot.YLabel.Color = Look.Fore;
    h.Result_Plot.YLabel.String = 'Intensity [Counts]';
    h.Result_Plot.XGrid = 'on';
    h.Result_Plot.YGrid = 'on';
    linkaxes([h.Result_Plot, h.Residuals_Plot],'x');
    
    hold on;
    h.Plots.DecayResult = plot([0 1],[0 0],'--k');
    h.Plots.FitResult = plot([0 1],[0 0],'k');
    
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
     switch TauFitBurstData.BAMethod
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
        'Callback',@Update_Plots);
    
    h.ChannelSelect_Text = uicontrol(...
        'Parent',h.PIEChannel_Panel,...
        'Style','Text',...
        'Tag','PIEChannelPar_Text',...
        'Units','normalized',...
        'Position',[0.05 0.85 0.4 0.1],...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','Select Channel',...
        'ToolTipString','Selection of Channel');
    
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
    
    %%%% Correction Factors
    uicontrol(...
        'Style','text',...
        'Parent',h.Settings_Panel,...
        'Units','normalized',...
        'Position',[0 0.9 0.6 0.05],...
        'String','G factor green',...
        'Tag','Ggreen_Text',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'FontSize',14);
    
    h.Ggreen_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.Settings_Panel,...
        'Units','normalized',...
        'Position',[0.6 0.9 0.4 0.05],...
        'String',num2str(UserValues.TauFit.Ggreen),...
        'Tag','Ggreen_Edit',...
        'Callback',@ParameterChange);
    
    uicontrol(...
        'Style','text',...
        'Parent',h.Settings_Panel,...
        'Units','normalized',...
        'Position',[0 0.8 0.6 0.05],...
        'String','G factor red',...
        'Tag','Gred_Text',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'FontSize',14);
    
    h.Gred_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.Settings_Panel,...
        'Units','normalized',...
        'Position',[0.6 0.8 0.4 0.05],...
        'String',num2str(UserValues.TauFit.Gred),...
        'Tag','Gred_Edit',...
        'Callback',@ParameterChange);
    
    uicontrol(...
        'Style','text',...
        'Parent',h.Settings_Panel,...
        'Units','normalized',...
        'Position',[0 0.7 0.6 0.05],...
        'String','l1',...
        'Tag','l1_Text',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'FontSize',14);
    
    h.l1_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.Settings_Panel,...
        'Units','normalized',...
        'Position',[0.6 0.7 0.4 0.05],...
        'String',num2str(UserValues.TauFit.l1),...
        'Tag','l1_Edit',...
        'Callback',@ParameterChange);
    
    uicontrol(...
        'Style','text',...
        'Parent',h.Settings_Panel,...
        'Units','normalized',...
        'Position',[0 0.6 0.6 0.05],...
        'String','l2',...
        'Tag','l2_Text',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'FontSize',14);
    
    h.l2_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.Settings_Panel,...
        'Units','normalized',...
        'Position',[0.6 0.6 0.4 0.05],...
        'String',num2str(UserValues.TauFit.l2),...
        'Tag','l2_Edit',...
        'Callback',@ParameterChange);
    
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
for i = 1:2
    TauFitBurstData.Length{i} = 1;
    TauFitBurstData.StartPar{i} = 0;
    TauFitBurstData.ShiftPer{i} = 0;
    TauFitBurstData.IRFLength{i} = 1;
    TauFitBurstData.IRFShift{i} = 0;
end

%%% Define the Slider properties
%%% Values to consider:
%%% The length of the shortest PIE channel
for i = 1:2
TauFitBurstData.MaxLength{i} = min([numel(TauFitBurstData.hMI_Par{i}) numel(TauFitBurstData.hMI_Per{i})]);
end
%%% The Length Slider defaults to the length of the shortest PIE
%%% channel and should not assume larger values
h.Length_Slider.Min = 1;
h.Length_Slider.Max = TauFitBurstData.MaxLength{1};
h.Length_Slider.Value = TauFitBurstData.MaxLength{1};
TauFitBurstData.Length{1} = TauFitBurstData.MaxLength{1};
TauFitBurstData.Length{2} = TauFitBurstData.MaxLength{2};
h.Length_Edit.String = num2str(TauFitBurstData.Length{1});
%%% Start Parallel Slider can assume values from 0 (no shift) up to the
%%% length of the shortest PIE channel minus the set length
h.StartPar_Slider.Min = 0;
h.StartPar_Slider.Max = TauFitBurstData.MaxLength{1};
h.StartPar_Slider.Value = 0;
TauFitBurstData.StartPar{1} = 0;
TauFitBurstData.StartPar{2} = 0;
h.StartPar_Edit.String = num2str(TauFitBurstData.StartPar{1});
%%% Shift Perpendicular Slider can assume values from the difference in
%%% start point between parallel and perpendicular up to the difference
%%% between the end point of the parallel channel and the start point
%%% of the perpendicular channel
%h.ShiftPer_Slider.Min = (-1)*max([0 TauFitBurstData.XData_Per(1)-TauFitBurstData.XData_Par(1)]);
%h.ShiftPer_Slider.Max = max([0 TauFitBurstData.XData_Par(end)-TauFitBurstData.XData_Per(1)]);
h.ShiftPer_Slider.Min = -floor(TauFitBurstData.MaxLength{1}/10);
h.ShiftPer_Slider.Max = floor(TauFitBurstData.MaxLength{1}/10);
h.ShiftPer_Slider.Value = 0;
TauFitBurstData.ShiftPer{1} = 0;
TauFitBurstData.ShiftPer{2} = 0;
h.ShiftPer_Edit.String = num2str(TauFitBurstData.ShiftPer{1});

%%% IRF Length has the same limits as the Length property
h.IRFLength_Slider.Min = 1;
h.IRFLength_Slider.Max = TauFitBurstData.MaxLength{1};
h.IRFLength_Slider.Value = TauFitBurstData.MaxLength{1};
TauFitBurstData.IRFLength{1} = TauFitBurstData.MaxLength{1};
TauFitBurstData.IRFLength{2} = TauFitBurstData.MaxLength{2};
h.IRFLength_Edit.String = num2str(TauFitBurstData.IRFLength{1});
%%% IRF Shift has the same limits as the perp shift property
%h.IRFShift_Slider.Min = (-1)*max([0 TauFitBurstData.XData_IRFPar(1)-TauFitBurstData.XData_Par(1)]);
%h.IRFShift_Slider.Max = max([0 TauFitBurstData.XData_Par(end)-TauFitBurstData.XData_IRFPar(1)]);
h.IRFShift_Slider.Min = -floor(TauFitBurstData.MaxLength{1}/10);
h.IRFShift_Slider.Max = floor(TauFitBurstData.MaxLength{1}/10);
h.IRFShift_Slider.Value = 0;
TauFitBurstData.IRFShift{1} = 0;
TauFitBurstData.IRFShift{2} = 0;
h.IRFShift_Edit.String = num2str(TauFitBurstData.IRFShift{1});
    
guidata(gcf,h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  General Function to Update Plots when something changed %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(obj,~)
global UserValues TauFitBurstData PamMeta
h = guidata(gcf);
chan = h.ChannelSelect_Popupmenu.Value;
%%% Cases to consider:
%%% obj is empty or is Button for LoadData/LoadIRF
%%% Data has been changed (PIE Channel changed, IRF loaded...)
if obj == h.ChannelSelect_Popupmenu
    %%% Plot the selected Channel
    h.Plots.Decay_Par.XData = TauFitBurstData.XData_Par{chan};
    h.Plots.Decay_Per.XData = TauFitBurstData.XData_Per{chan};
    h.Plots.IRF_Par.XData = TauFitBurstData.XData_Par{chan};
    h.Plots.IRF_Per.XData = TauFitBurstData.XData_Per{chan};
    h.Plots.Decay_Par.YData = TauFitBurstData.hMI_Par{chan};
    h.Plots.Decay_Per.YData = TauFitBurstData.hMI_Per{chan};
    h.Plots.IRF_Par.YData = TauFitBurstData.hIRF_Par{chan};
    h.Plots.IRF_Per.YData = TauFitBurstData.hIRF_Per{chan};
    h.Microtime_Plot.XLim = [min([TauFitBurstData.XData_Par{chan} TauFitBurstData.XData_Per{chan}]) max([TauFitBurstData.XData_Par{chan} TauFitBurstData.XData_Per{chan}])];
    h.Microtime_Plot.YLimMode = 'auto';
    
    %%% Change Sliders
    %%% The Length Slider defaults to the length of the shortest PIE
    %%% channel and should not assume larger values

    h.Length_Slider.Max = TauFitBurstData.Length{chan};
    h.Length_Slider.Value = TauFitBurstData.Length{chan};
    h.Length_Edit.String = num2str(TauFitBurstData.Length{chan});
    %%% Start Parallel Slider can assume values from 0 (no shift) up to the
    %%% length of the shortest PIE channel minus the set length
    h.StartPar_Slider.Max = TauFitBurstData.MaxLength{chan};
    h.StartPar_Slider.Value = TauFitBurstData.StartPar{chan};
    h.StartPar_Edit.String = num2str(TauFitBurstData.StartPar{chan});
    %%% Shift Perpendicular Slider can assume values from the difference in
    %%% start point between parallel and perpendicular up to the difference
    %%% between the end point of the parallel channel and the start point
    %%% of the perpendicular channel
    %h.ShiftPer_Slider.Min = (-1)*max([0 TauFitBurstData.XData_Per(1)-TauFitBurstData.XData_Par(1)]);
    %h.ShiftPer_Slider.Max = max([0 TauFitBurstData.XData_Par(end)-TauFitBurstData.XData_Per(1)]);
    h.ShiftPer_Slider.Min = -floor(TauFitBurstData.MaxLength{chan}/10);
    h.ShiftPer_Slider.Max = floor(TauFitBurstData.MaxLength{chan}/10);
    h.ShiftPer_Slider.Value = TauFitBurstData.ShiftPer{chan};
    h.ShiftPer_Edit.String = num2str(TauFitBurstData.ShiftPer{chan});

    %%% IRF Length has the same limits as the Length property
    h.IRFLength_Slider.Max = TauFitBurstData.MaxLength{chan};
    h.IRFLength_Slider.Value = TauFitBurstData.IRFLength{chan};
    h.IRFLength_Edit.String = num2str(TauFitBurstData.IRFLength{chan});
    %%% IRF Shift has the same limits as the perp shift property
    %h.IRFShift_Slider.Min = (-1)*max([0 TauFitBurstData.XData_IRFPar(1)-TauFitBurstData.XData_Par(1)]);
    %h.IRFShift_Slider.Max = max([0 TauFitBurstData.XData_Par(end)-TauFitBurstData.XData_IRFPar(1)]);
    h.IRFShift_Slider.Min = -floor(TauFitBurstData.MaxLength{chan}/10);
    h.IRFShift_Slider.Max = floor(TauFitBurstData.MaxLength{chan}/10);
    h.IRFShift_Slider.Value = TauFitBurstData.IRFShift{chan};
    h.IRFShift_Edit.String = num2str(TauFitBurstData.IRFShift{chan});
end

%%% Update Values
switch obj
    case {h.StartPar_Slider, h.StartPar_Edit}
        if obj == h.StartPar_Slider
            TauFitBurstData.StartPar{chan} = floor(obj.Value);
        elseif obj == h.StartPar_Edit
            TauFitBurstData.StartPar{chan} = str2double(obj.String);
        end
    case {h.Length_Slider, h.Length_Edit}
        %%% Update Value
        if obj == h.Length_Slider
            TauFitBurstData.Length{chan} = floor(obj.Value);
        elseif obj == h.Length_Edit
            TauFitBurstData.Length{chan} = str2double(obj.String);
        end
        %%% Correct if IRFLength exceeds the Length
        if TauFitBurstData.IRFLength{chan} > TauFitBurstData.Length{chan}
            TauFitBurstData.IRFLength{chan} = TauFitBurstData.Length{chan};
        end
    case {h.ShiftPer_Slider, h.ShiftPer_Edit}
        %%% Update Value
        if obj == h.ShiftPer_Slider
            TauFitBurstData.ShiftPer{chan} = floor(obj.Value);
        elseif obj == h.ShiftPer_Edit
            TauFitBurstData.ShiftPer{chan} = str2double(obj.String);
        end
    case {h.IRFLength_Slider, h.IRFLength_Edit}
        %%% Update Value
        if obj == h.IRFLength_Slider
            TauFitBurstData.IRFLength{chan} = floor(obj.Value);
        elseif obj == h.IRFLength_Edit
            TauFitBurstData.IRFLength{chan} = str2double(obj.String);
        end
        %%% Correct if IRFLength exceeds the Length
        if TauFitBurstData.IRFLength{chan} > TauFitBurstData.Length{chan}
            TauFitBurstData.IRFLength{chan} = TauFitBurstData.Length{chan};
        end
    case {h.IRFShift_Slider, h.IRFShift_Edit}
        %%% Update Value
        if obj == h.IRFShift_Slider
            TauFitBurstData.IRFShift{chan} = floor(obj.Value);
        elseif obj == h.IRFShift_Edit
            TauFitBurstData.IRFShift{chan} = str2double(obj.String);
        end
end
%%% Update Edit Boxes if Slider was used and Sliders if Edit Box was used
switch obj.Style
    case 'slider'
        h.StartPar_Edit.String = num2str(TauFitBurstData.StartPar{chan});
        h.Length_Edit.String = num2str(TauFitBurstData.Length{chan});
        h.ShiftPer_Edit.String = num2str(TauFitBurstData.ShiftPer{chan});
        h.IRFLength_Edit.String = num2str(TauFitBurstData.IRFLength{chan});
        h.IRFShift_Edit.String = num2str(TauFitBurstData.IRFShift{chan});
    case 'edit'
        h.StartPar_Slider.Value = TauFitBurstData.StartPar{chan};
        h.Length_Slider.Value = TauFitBurstData.Length{chan};
        h.ShiftPer_Slider.Value = TauFitBurstData.ShiftPer{chan};
        h.IRFLength_Slider.Value = TauFitBurstData.IRFLength{chan};
        h.IRFShift_Slider.Value = TauFitBurstData.IRFShift{chan};
end
%%% Update Plot
% %%% Apply the shift to the parallel channel
% h.Plots.Decay_Par.XData = TauFitBurstData.XData_Par(1:TauFitBurstData.Length)-TauFitBurstData.StartPar;
% h.Plots.Decay_Par.YData = TauFitBurstData.hMI_Par(1:TauFitBurstData.Length);
% %%% Apply the shift to the perpendicular channel
% h.Plots.Decay_Per.XData = TauFitBurstData.XData_Per((1+max([0 TauFitBurstData.ShiftPer])):min([TauFitBurstData.MaxLength (TauFitBurstData.Length+TauFitBurstData.ShiftPer)]))-(TauFitBurstData.StartPar+TauFitBurstData.ShiftPer);
% h.Plots.Decay_Per.YData = TauFitBurstData.hMI_Per((1+max([0 TauFitBurstData.ShiftPer])):min([TauFitBurstData.MaxLength (TauFitBurstData.Length+TauFitBurstData.ShiftPer)]));
% %%% Apply the shift to the parallel IRF channel
% h.Plots.IRF_Par.XData = TauFitBurstData.XData_Par((1+max([0 TauFitBurstData.IRFShift])):min([TauFitBurstData.MaxLength (TauFitBurstData.IRFLength+TauFitBurstData.IRFShift)]))-(TauFitBurstData.StartPar+TauFitBurstData.IRFShift);
% h.Plots.IRF_Par.YData = TauFitBurstData.hIRF_Par((1+max([0 TauFitBurstData.IRFShift])):min([TauFitBurstData.MaxLength (TauFitBurstData.IRFLength+TauFitBurstData.IRFShift)]));
% %%% Apply the shift to the perpendicular IRF channel
% h.Plots.IRF_Per.XData = TauFitBurstData.XData_Per((1+max([0 (TauFitBurstData.ShiftPer + TauFitBurstData.IRFShift)])):min([TauFitBurstData.MaxLength (TauFitBurstData.IRFLength+TauFitBurstData.IRFShift+TauFitBurstData.ShiftPer)]))-(TauFitBurstData.StartPar+TauFitBurstData.IRFShift+TauFitBurstData.ShiftPer);
% h.Plots.IRF_Per.YData = TauFitBurstData.hIRF_Per((1+max([0 (TauFitBurstData.IRFShift + TauFitBurstData.ShiftPer)])):min([TauFitBurstData.MaxLength (TauFitBurstData.IRFLength+TauFitBurstData.IRFShift+TauFitBurstData.ShiftPer)]));

%%% Make the Microtime Adjustment Plot Visible, hide Result
h.Microtime_Plot.Visible = 'on';
h.Result_Plot.Visible = 'off';
%%% Apply the shift to the parallel channel
h.Plots.Decay_Par.XData = (TauFitBurstData.StartPar{chan}:(TauFitBurstData.Length{chan}-1)) - TauFitBurstData.StartPar{chan};
h.Plots.Decay_Par.YData = TauFitBurstData.hMI_Par{chan}((TauFitBurstData.StartPar{chan}+1):TauFitBurstData.Length{chan})';
%%% Apply the shift to the perpendicular channel
h.Plots.Decay_Per.XData = (TauFitBurstData.StartPar{chan}:(TauFitBurstData.Length{chan}-1)) - TauFitBurstData.StartPar{chan};
hMI_Per_Shifted = circshift(TauFitBurstData.hMI_Per{chan},[TauFitBurstData.ShiftPer{chan},0])';
h.Plots.Decay_Per.YData = hMI_Per_Shifted((TauFitBurstData.StartPar{chan}+1):TauFitBurstData.Length{chan});
%%% Apply the shift to the parallel IRF channel
h.Plots.IRF_Par.XData = (TauFitBurstData.StartPar{chan}:(TauFitBurstData.IRFLength{chan}-1)) - TauFitBurstData.StartPar{chan};
hIRF_Par_Shifted = circshift(TauFitBurstData.hIRF_Par{chan},[0,TauFitBurstData.IRFShift{chan}])';
h.Plots.IRF_Par.YData = hIRF_Par_Shifted((TauFitBurstData.StartPar{chan}+1):TauFitBurstData.IRFLength{chan});
%%% Apply the shift to the perpendicular IRF channel
h.Plots.IRF_Per.XData = (TauFitBurstData.StartPar{chan}:(TauFitBurstData.IRFLength{chan}-1)) - TauFitBurstData.StartPar{chan};
hIRF_Per_Shifted = circshift(TauFitBurstData.hIRF_Per{chan},[0,TauFitBurstData.IRFShift{chan}+TauFitBurstData.ShiftPer{chan}])';
h.Plots.IRF_Per.YData = hIRF_Per_Shifted((TauFitBurstData.StartPar{chan}+1):TauFitBurstData.IRFLength{chan});

axis('tight');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Update UserValues on Correction Parameter Change %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ParameterChange(obj,~)
global UserValues
h = guidata(obj);
LSUserValues(0);
UserValues.TauFit.Ggreen = num2str(h.Ggreen_Edit.String);
UserValues.TauFit.Gred = num2str(h.Gred_Edit.String);
UserValues.TauFit.l1 = num2str(h.l1_Edit.String);
UserValues.TauFit.l2 = num2str(h.l2_Edit.String);
LSUserValues(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Closes TauFit and deletes global variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_TauFit(~,~)
%clear global -regexp TauFitBurstData
Pam=findobj('Tag','Pam');
FCSFit=findobj('Tag','FCSFit');
if isempty(Pam) && isempty(FCSFit)
    clear global -regexp UserValues
end
delete(gcf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Fit the Data with selected Model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Start_Fit(~,~)
global TauFitBurstData FileInfo
h = guidata(gcf);
%% Read out the data from the plots
% xmin_decay = max([1 h.Plots.Decay_Par.XData(1) h.Plots.Decay_Per.XData(1)]);
% xmax_decay = min([h.Plots.Decay_Par.XData(end) h.Plots.Decay_Per.XData(end)]);
% TauFitBurstData.FitData.Decay_Par = h.Plots.Decay_Par.YData((h.Plots.Decay_Par.XData >= xmin_decay) & (h.Plots.Decay_Par.XData <= xmax_decay));
% TauFitBurstData.FitData.Decay_Per = h.Plots.Decay_Per.YData((h.Plots.Decay_Per.XData >= xmin_decay) & (h.Plots.Decay_Per.XData <= xmax_decay));
% %%% read out the scatter pattern (i.e. the total IRF without
% %%% restricting the IRF length)
% TauFitBurstData.FitData.Scatter_Par = circshift(TauFitBurstData.hIRF_Par,[0, -TauFitBurstData.IRFShift]);
% TauFitBurstData.FitData.Scatter_Par = TauFitBurstData.FitData.Scatter_Par((h.Plots.Decay_Par.XData >= xmin_decay) & (h.Plots.Decay_Par.XData <= xmax_decay));
% TauFitBurstData.FitData.Scatter_Per = circshift(TauFitBurstData.hIRF_Per,[0, -(TauFitBurstData.IRFShift + TauFitBurstData.ShiftPer)]);
% TauFitBurstData.FitData.Scatter_Per = TauFitBurstData.FitData.Scatter_Per((h.Plots.Decay_Per.XData >= xmin_decay) & (h.Plots.Decay_Per.XData <= xmax_decay));
% 
% xmin_irf = max([1 h.Plots.IRF_Par.XData(1) h.Plots.IRF_Per.XData(1)]);
% xmax_irf = min([h.Plots.IRF_Par.XData(end) h.Plots.IRF_Per.XData(end)]);
% TauFitBurstData.FitData.IRF_Par = zeros(1,numel(TauFitBurstData.FitData.Scatter_Par));
% TauFitBurstData.FitData.IRF_Par((xmin_irf-xmin_decay+1):(xmax_irf-xmin_decay+1)) = h.Plots.IRF_Par.YData((h.Plots.IRF_Par.XData >= xmin_irf & h.Plots.IRF_Par.XData <= xmax_irf & h.Plots.IRF_Par.XData >= xmin_decay & h.Plots.IRF_Par.XData <= xmax_decay));
% TauFitBurstData.FitData.IRF_Per = zeros(1,numel(TauFitBurstData.FitData.Scatter_Per));
% TauFitBurstData.FitData.IRF_Per((xmin_irf-xmin_decay+1):(xmax_irf-xmin_decay)) = h.Plots.IRF_Per.YData((h.Plots.IRF_Per.XData >= xmin_irf & h.Plots.IRF_Per.XData <= xmax_irf & h.Plots.IRF_Per.XData >= xmin_decay & h.Plots.IRF_Per.XData <= xmax_decay));
TauFitBurstData.FitData.Decay_Par = h.Plots.Decay_Par.YData;
TauFitBurstData.FitData.Decay_Per = h.Plots.Decay_Par.YData;
TauFitBurstData.FitData.IRF_Par = h.Plots.IRF_Par.YData;
TauFitBurstData.FitData.IRF_Per = h.Plots.IRF_Per.YData;
%%% Read out the shifted scatter pattern
Scatter_Par_Shifted = circshift(TauFitBurstData.hIRF_Par,[0,TauFitBurstData.IRFShift])';
TauFitBurstData.FitData.Scatter_Par = Scatter_Par_Shifted((TauFitBurstData.StartPar+1):TauFitBurstData.Length)';
Scatter_Per_Shifted = circshift(TauFitBurstData.hIRF_Per,[0,TauFitBurstData.IRFShift + TauFitBurstData.ShiftPer])';
TauFitBurstData.FitData.Scatter_Per = Scatter_Per_Shifted((TauFitBurstData.StartPar+1):TauFitBurstData.Length)';
%%% initialize inputs for fit
Decay = TauFitBurstData.FitData.Decay_Par+2*TauFitBurstData.FitData.Decay_Per;
Irf = TauFitBurstData.FitData.IRF_Par+2*TauFitBurstData.FitData.IRF_Per;
Irf = Irf-min(Irf(Irf~=0));
Irf = Irf./sum(Irf);
Irf = [Irf zeros(1,numel(Decay)-numel(Irf))];
TauFitBurstData.TACRange = FileInfo.SyncPeriod*1E9;
TauFitBurstData.TACChannelWidth = FileInfo.SyncPeriod*1E9/FileInfo.MI_Bins;
Scatter = TauFitBurstData.FitData.Scatter_Par + 2*TauFitBurstData.FitData.Scatter_Per;
Scatter = Scatter./sum(Scatter);

%%% Update Progressbar
h.Progress_Text.String = 'Fitting...';
switch TauFitBurstData.FitType
    case 'Single Exponential'
        %%% Parameter:
        %%% gamma   - Constant Background
        %%% scatter - Scatter Background (IRF pattern)
        %%% taus    - Lifetimes
        x0 = [0.1,0.1,round(4/TauFitBurstData.TACChannelWidth)];
        shift_range = -20:20;
        %%% fit for different IRF offsets and compare the results
        count = 1;
        for i = shift_range
            %%% Update Progressbar
            Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
            [x{count}, res(count), residuals{count}] = lsqcurvefit(@lsfit,x0,{Irf,Scatter,4096,Decay,i},Decay);
            count = count +1;
        end
        ignore = 200;
        chi2 = cellfun(@(x) sum(x((1+ignore):end).^2./Decay((1+ignore):end))/(numel(Decay)-numel(x0)-ignore),residuals);
        [~,best_fit] = min(chi2);
        FitFun = lsfit(x{best_fit},{Irf,Scatter,4096,Decay,shift_range(best_fit)});
%         figure;
%         subplot(4,1,[1 2 3]);
%         semilogy(Decay);hold on;semilogy(FitFun);
%         subplot(4,1,4);
%         plot((Decay-FitFun)./sqrt(Decay));
        wres = (Decay-FitFun)./sqrt(Decay);
end

%%% Reset Progressbar
h.Progress_Text.String = 'Fit done';
%%% Update Plot
h.Microtime_Plot.Visible = 'off';
h.Result_Plot.Visible = 'on';
h.Plots.DecayResult.XData = h.Plots.Decay_Par.XData;
h.Plots.DecayResult.YData = Decay;
h.Plots.FitResult.XData = h.Plots.Decay_Par.XData;
h.Plots.FitResult.YData = FitFun;
axis('tight');
h.Plots.Residuals.XData = h.Plots.Decay_Par.XData;
h.Plots.Residuals.YData = wres;
h.Plots.Residuals_ZeroLine.XData = h.Plots.Decay_Par.XData;
h.Plots.Residuals_ZeroLine.YData = zeros(1,numel(h.Plots.Decay_Par.XData));

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
tau = param(3:length(param)); tau = tau(:)';
x = exp(-(tp-1)*(1./tau))*diag(1./(1-exp(-p./tau)));
%irs = irf(rem(rem(t-floor(c)-1, n)+n,n)+1);
irs = circshift(irf,[0 c]);
scatter = circshift(scatter,[0 c]);
z = convol(irs, x);
z = z./sum(z);
z = (1-scatter).*z + scatter*bg';
z = (1-gamma).*z+gamma;
z = z.*sum(y);
z=z';