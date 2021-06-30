function Output = PAM (SubFunction)
%   2017 - FAB Lab Munich - Don C. Lamb

global UserValues FileInfo PamMeta TcspcData PathToApp
h.Pam=findobj('Tag','Pam');
if nargout > 0
    Output = [];
end
if nargin>0 %%% Used to extract subfunctions from Pam
    if ischar(SubFunction) && (exist(SubFunction)==2) %#ok<EXIST>
        Output = str2func(SubFunction);
    else
        Output = [];
    end
    return;
end

if ~isempty(h.Pam) %%% Gives focus to Pam figure if it already exists
    figure(h.Pam); return;
end

addpath(genpath(['.' filesep 'functions']));

if isempty(PathToApp)
    GetAppFolder();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% start splash screen
s = SplashScreen( 'Splashscreen', [PathToApp filesep 'images' filesep 'PAM' filesep 'logo.png'], ...
    'ProgressBar', 'on', ...
    'ProgressPosition', 5, ...
    'ProgressRatio', 0 );
s.addText( 30, 50, 'PAM - PIE Analysis with MATLAB', 'FontSize', 30, 'Color', [1 1 1] );
s.addText( 30, 80, 'v1.3', 'FontSize', 20, 'Color', [1 1 1] );
s.addText( 375, 395, 'Loading...', 'FontSize', 25, 'Color', 'white' );

%%% Disables negative values for log plot warning
warning('off','MATLAB:Axes:NegativeDataInLogAxis');
warning('off','MATLAB:handle_graphics:exceptions:SceneNode');
warning('off','MATLAB:uigridcontainer:MigratingFunction');
warning('off','MATLAB:ui:javaframe:PropertyToBeRemoved');
warning('off','MATLAB:gui:array:InvalidArrayShape');
%%% Loads user profile
Profiles=LSUserValues(0);
for i = 1:numel(Profiles)
    [~, Profiles{i}, ~] = fileparts(Profiles{i});
end
%%% To save typing
Look=UserValues.Look;
%%% Generates the Pam figure

h.Pam = figure(...
    'Units','normalized',...
    'Tag','Pam',...
    'Name','PAM: PIE Analysis with Matlab',...
    'NumberTitle','off',...
    'Menu','none',...
    'defaultUicontrolFontName',Look.Font,...
    'defaultAxesFontName',Look.Font,...
    'defaultTextFontName',Look.Font,...
    'Toolbar','figure',...
    'UserData',[],...
    'OuterPosition',[0.01 0.1 0.98 0.9],...
    'CloseRequestFcn',@CloseWindow,...
    'Visible','off');
%h.Pam.Visible='off';

%%% Remove unneeded items from toolbar
toolbar = findall(h.Pam,'Type','uitoolbar');
toolbar_items = findall(toolbar);
if verLessThan('matlab','9.5') %%% toolbar behavior changed in MATLAB 2018b
    delete(toolbar_items([2:7 9 13:17]));
else %%% 2018b and upward
    %%% just remove the tool bar since the options are now in the axis
    %%% (e.g. axis zoom etc)
    delete(toolbar_items);
end

%%% Sets background of axes and other things
whitebg(Look.Axes);
%%% Changes Pam background; must be called after whitebg
h.Pam.Color=Look.Back;
%%% Initializes cell containing text objects (for changes between mac/pc
h.Text={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Menubar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% File menu with loading, saving and exporting functions
h.Menu.File = uimenu(...
    'Parent',h.Pam,...
    'Tag','File',...
    'Label','File');

h.Menu.Loadtcspc = uimenu(...
    'Parent', h.Menu.File,...
    'Tag','LoadTcspc',...
    'Label','Load TCSPC Data',...
    'Callback',{@LoadTcspc,@Update_Data,@Update_Display,@Shift_Detector,@Update_Detector_Channels,h.Pam});
h.Menu.Database = uimenu(...
    'Parent', h.Menu.File,...
    'Tag','DatabaseMenu',...
    'Label','Database...');
h.Export.Single = uimenu(...
    'Parent', h.Menu.Database,...
    'Tag','Export_Single',...
    'Label','Add Individual Tcspc Files to Database',...
    'Callback',{@Export_Database,1});
h.Export.Multi = uimenu(...
    'Parent', h.Menu.Database,...
    'Tag','Export_Multi',...
    'Label','Add Connected Tcspc Files to Database',...
    'Callback',{@Export_Database,1});
h.Menu.SaveIrf = uimenu(...
    'Parent', h.Menu.File,...
    'Separator','on',...
    'Tag','SaveIrf_Menu',...
    'Separator','on',...
    'Label','Store loaded data as IRF (for all PIE Channels)',...
    'Callback',@SaveLoadIrfScat);
h.Menu.SaveScatter = uimenu(...
    'Parent', h.Menu.File,...
    'Tag','SaveScatter_Menu',...
    'Label','Store loaded data as Scatter/Background',...
    'Callback',@SaveLoadIrfScat);
h.Menu.LoadSaveCalibrations = uimenu(...
    'Parent', h.Menu.File,...
    'Tag','DatabaseMenu',...
    'Label','Load/Save Calibrations...');
h.Menu.LoadIrf = uimenu(...
    'Parent', h.Menu.LoadSaveCalibrations,...
    'Tag','LoadIrf_Menu',...
    'Label','Load IRF',...
    'Callback',@SaveLoadIrfScat);
h.Menu.LoadScatter = uimenu(...
    'Parent', h.Menu.LoadSaveCalibrations,...
    'Tag','LoadScatter_Menu',...
    'Label','Load Scatter/Background',...
    'Callback',@SaveLoadIrfScat);
h.Menu.SaveIrfFile = uimenu(...
    'Parent', h.Menu.LoadSaveCalibrations,...
    'Tag','SaveIrfFile_Menu',...
    'Label','Save IRF to File',...
    'Callback',@SaveLoadIrfScat);
h.Menu.SaveScatterFile = uimenu(...
    'Parent', h.Menu.LoadSaveCalibrations,...
    'Tag','SaveScatterFile_Menu',...
    'Label','Save Scatter/Background to File',...
    'Callback',@SaveLoadIrfScat);

h.Menu.LoadShift = uimenu(...
    'Parent', h.Menu.LoadSaveCalibrations,...
    'Separator','on',...
    'Tag','LoadShift_Menu',...
    'Label','Load Detector Shifts',...
    'Callback',@SaveLoadShift);
h.Menu.SaveShiftFile = uimenu(...
    'Parent', h.Menu.LoadSaveCalibrations,...
    'Tag','SaveShiftFile_Menu',...
    'Label','Save Detector Shifts to File',...
    'Callback',@SaveLoadShift);
h.Menu.ExportFile = uimenu(...
    'Parent', h.Menu.File,...
    'Tag','ExportFile_Menu',...
    'Separator','on',...
    'Label','Export...');
h.Menu.ExportFile_PhotonHDF5 = uimenu(...
    'Parent', h.Menu.ExportFile,...
    'Tag','ExportFile_PhotonHDF5_Menu',...
    'Label','to PhotonHDF5 file',...
    'Callback',@write_photonHDF5);

h.Menu.AdvancedAnalysis = uimenu(...
    'Parent',h.Pam,...
    'Tag','AdvancedAnalysis',...
    'Label','Advanced Analysis');

h.Menu.OpenFCSFit = uimenu(...
    'Parent', h.Menu.AdvancedAnalysis,...
    'Tag','OpenFCSFit',...
    'Label','FCSFit',...
    'Callback',@FCSFit);

h.Menu.OpenMIAFit = uimenu(...
    'Parent', h.Menu.AdvancedAnalysis,...
    'Tag','OpenMIAFit',...
    'Label','MIAFit',...
    'Callback',@MIAFit);
h.Menu.OpenTauFit = uimenu(...
    'Parent', h.Menu.AdvancedAnalysis,...
    'Tag','OpenTauFit',...
    'Label','TauFit',...
    'Callback',@TauFit);
h.Menu.OpenBurstBrowser = uimenu(...
    'Parent', h.Menu.AdvancedAnalysis,...
    'Separator','on',...
    'Tag','OpenBurstBrowser',...
    'Label','BurstBrowser',...
    'Callback',@BurstBrowser);
h.Menu.OpenPDA = uimenu(...
    'Parent', h.Menu.AdvancedAnalysis,...
    'Tag','OpenPDA',...
    'Label','PDAFit',...
    'Callback',@PDAFit);
h.Menu.OpenMia = uimenu(...
    'Parent', h.Menu.AdvancedAnalysis,...
    'Tag','OpenMia',...
    'Label','MIA',...
    'Callback',@Mia);
h.Menu.PhasorMenu = uimenu(...
    'Parent', h.Menu.AdvancedAnalysis,...
    'Tag','PhasorMenu',...
    'Label','Phasor');
h.Menu.OpenPhasor = uimenu(...
    'Parent', h.Menu.PhasorMenu,...
    'Tag','OpenPhasor',...
    'Label','Phasor',...
    'Callback',@Phasor);
h.Menu.OpenParticleDetection = uimenu(...
    'Parent', h.Menu.PhasorMenu,...
    'Tag','OpenParticleDetection',...
    'Label','Particle Detection',...
    'Callback',@ParticleDetection);
h.Menu.OpenParticleViewer = uimenu(...
    'Parent', h.Menu.PhasorMenu,...
    'Tag','OpenParticleViewer',...
    'Label','Particle Viewer',...
    'Callback',@ParticleViewer);
h.Menu.OpenPhasorTIFF = uimenu(...
    'Parent', h.Menu.PhasorMenu,...
    'Tag','OpenPhasorTIFF',...
    'Label','Phasor for TIFF images',...
    'Callback',@PhasorTIFF);
h.Menu.OpenPCF = uimenu(...
    'Parent', h.Menu.AdvancedAnalysis,...
    'Tag','OpenPCF',...
    'Label','PCF Analysis',...
    'Callback',@PCFAnalysis);
if ~isdeployed
    if exist([PathToApp filesep 'tcPDA.m'],'file') ~= 0
        h.Menu.OpenTCPDA = uimenu(...
            'Parent', h.Menu.AdvancedAnalysis,...
            'Tag','OpenTCPDA',...
            'Label','tcPDA',...
            'Callback',@tcPDA);
    end
end

h.Menu.Extras = uimenu(...
    'Parent',h.Pam,...
    'Tag','Extras',...
    'Label','Extras');
h.Menu.ParallelProcessing = uimenu(...
    'Parent',h.Menu.Extras,...
    'Tag','ParallelProcessing',...
    'Label','Parallel Processing');
if UserValues.Settings.Pam.ParallelProcessing == 0
    checked = 'off';
end
if UserValues.Settings.Pam.ParallelProcessing == Inf
    checked = 'on';
end
h.Menu.UseParfor = uimenu(...
    'Parent',h.Menu.ParallelProcessing,...
    'Tag','UseParfor',...
    'Label','Enable Multicore',...
    'Checked', checked,...
    'Callback',@Calculate_Settings);
h.Menu.NumberOfCores = uimenu(...
    'Parent',h.Menu.ParallelProcessing,...
    'Tag','UseParfor',...
    'Label',['Number of Cores: ' num2str(UserValues.Settings.Pam.NumberOfCores)],...
    'Callback',@Calculate_Settings);
h.Menu.Sim = uimenu(...
    'Parent', h.Menu.Extras,...
    'Tag','Sim_Menu',...
    'Label','Simulate photon data',...
    'Callback',@Sim);
h.Menu.Look = uimenu(...
    'Parent', h.Menu.Extras,...
    'Tag','Look_Menu',...
    'Label','Adjust Pam Look',...
    'Separator','on',...
    'Callback',@LookSetup);
h.Menu.Manual = uimenu(...
    'Parent', h.Menu.Extras,...
    'Tag','Manual_Menu',...
    'Separator','on',...
    'Label','PAM Manual',...
    'Callback',@Open_Doc);
h.Menu.NotePad = uimenu(...
    'Parent',h.Menu.Extras,...
    'Label','Notepad',...
    'Separator','on',...
    'Callback',@Open_Notepad);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Progressbar and file name %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Panel for progressbar
h.Progress.Panel = uibuttongroup(...
    'Parent',h.Pam,...
    'Tag','Progress_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.01 0.96 0.485 0.03]);
%%% Axes for progressbar
h.Progress.Axes = axes(...
    'Parent',h.Progress.Panel,...
    'Tag','Progress_Axes',...
    'Units','normalized',...
    'Color',Look.Control,...
    'Position',[0 0 1 1]);
h.Progress.Axes.XTick=[]; h.Progress.Axes.YTick=[];
%%% Progress and filename text
h.Progress.Text=text(...
    'Parent',h.Progress.Axes,...
    'Tag','Progress_Text',...
    'Units','normalized',...
    'FontSize',12,...
    'FontWeight','bold',...
    'String','Nothing loaded',...
    'Interpreter','none',...
    'HorizontalAlignment','center',...
    'BackgroundColor','none',...
    'Color',Look.Fore,...
    'Position',[0.5 0.5]);
%% Detector tabs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s.ProgressRatio = 0.25;
%%% Microtime tabs container
h.Det_Tabs = uitabgroup(...
    'Parent',h.Pam,...
    'Tag','Det_Tabs',...
    'Units','normalized',...
    'Position',[0.505 0.01 0.485 0.98]);

%% Plot and functions for microtimes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Microtime tab
h.MI.Tab= uitab(...
    'Parent',h.Det_Tabs,...
    'Tag','MI_Tab',...
    'Title','Microtimes');
%%% Microtime tabs container
h.MI.Tabs = uitabgroup(...
    'Parent',h.MI.Tab,...
    'Tag','MI_Tabs',...
    'Units','normalized',...
    'Position',[0 0 1 1]);
%%% All microtime tab
h.MI.All_Tab= uitab(...
    'Parent',h.MI.Tabs,...
    'Tag','MI_All_Tab',...
    'Title','All');
%%% All microtime panel
h.MI.All_Panel = uibuttongroup(...
    'Parent',h.MI.All_Tab,...
    'Tag','MI_All_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%% Contexmenu for all microtime axes
h.MI.Menu = uicontextmenu;
%%% Menu for Log scale plotting
h.MI.Log = uimenu(...
    'Parent',h.MI.Menu,...
    'Label','Plot as log scale',...
    'Tag','MI_Log',...
    'Checked',UserValues.Settings.Pam.PlotLog,...
    'Callback',@Calculate_Settings);
%%% Contextmenu for individual microtime axes
h.MI.Menu_Individual = uicontextmenu;
%%% Menu for Log scale plotting
h.MI.Log_Ind = uimenu(...
    'Parent',h.MI.Menu_Individual,...
    'Label','Plot as log scale',...
    'Tag','MI_Log',...
    'Checked',UserValues.Settings.Pam.PlotLog,...
    'Callback',@Calculate_Settings);
%%% Menu for Enabling/Disabling IRF Plotting
h.MI.IRF = uimenu(...
    'Parent',h.MI.Menu_Individual,...
    'Label','Plot IRF',...
    'Separator','on',...
    'Tag','MI_IRF',...
    'Checked',UserValues.Settings.Pam.PlotIRF,...
    'Callback',@Calculate_Settings);
%%% Menu for Enabling/Disabling Scatter Pattern Plotting
h.MI.ScatterPattern = uimenu(...
    'Parent',h.MI.Menu_Individual,...
    'Label','Plot Scatter Pattern',...
    'Tag','MI_ScatterPattern',...
    'Checked',UserValues.Settings.Pam.PlotScat,...
    'Callback',@Calculate_Settings);
%%% All microtime axes
h.MI.All_Axes = axes(...
    'Parent',h.MI.All_Panel,...
    'Tag','MI_All_Axes',...
    'Units','normalized',...
    'NextPlot','add',...
    'UIContextMenu',h.MI.Menu,...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'Position',[0.09 0.075 0.89 0.90],...
    'TickDir','out',...
    'Box','off');
h.MI.All_Axes.XLabel.String='TCSPC channel';
h.MI.All_Axes.XLabel.Color=Look.Fore;
h.MI.All_Axes.YLabel.String='Counts';
h.MI.All_Axes.YLabel.Color=Look.Fore;
h.MI.All_Axes.XLim=[1 4096];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Correlations tab
h.Cor.Tab= uitab(...
    'Parent',h.Det_Tabs,...
    'Tag','Cor_Tab',...
    'BackgroundColor',Look.Back,...
    'Title','Correlate');
%%% Correlation panel
h.Cor.Panel = uibuttongroup(...
    'Parent',h.Cor.Tab,...
    'Tag','Cor_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0.52 1 0.48]);
%%% Contexmenu for correlation table
h.Cor.Menu = uicontextmenu;
%%% Resets the correlation table to  all zeros
h.Cor.Reset_Menu = uimenu(...
    'Parent',h.Cor.Menu,...
    'Label','Reset table',...
    'Tag','Cor_Reset_Menu',...
    'Callback',@Update_Cor_Table);
%%% Sets a divider for correlation
h.Cor.Divider_Menu = uimenu(...
    'Parent',h.Cor.Menu,...
    'Label',['Divider: ' num2str(UserValues.Settings.Pam.Cor_Divider)],...
    'Tag','Cor_Divider_Menu',...
    'Separator','on',...
    'Callback',@Calculate_Settings);
%%% Correlations table
h.Cor.Table = uitable(...
    'Parent',h.Cor.Panel,...
    'Tag','Cor_Table',...
    'Units','normalized',...
    'FontSize',8,...
    'Position',[0.005 0.11 0.99 0.88],...
    'ForegroundColor',Look.TableFore,...
    'BackgroundColor',[Look.Table1;Look.Table2],...
    'TooltipString',sprintf([...
    'Selection for cross correlations: \n'...
    '"Column"/"Row" (un)selects full column/row; \n'...
    'Bottom right checkbox (un)selects diagonal \n'...
    'Rightclick to open contextmenu with additional functions: \n'...
    'Divider: Divider for correlation time resolution for certain excitation schemes']),...
    'UIContextMenu',h.Cor.Menu,...
    'CellEditCallback',@Update_Cor_Table);
%%% Correlates current loaded data
h.Cor.Button = uicontrol(...
    'Parent',h.Cor.Panel,...
    'Tag','Cor_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'FontWeight','bold',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Correlate',...
    'Callback',{@Correlate,1},...
    'Position',[0.005 0.01 0.12 0.09],...
    'TooltipString',sprintf('Correlates loaded data for selected PIE channel pairs;'));
%%% Correlates multiple data sets
h.Cor.Multi_Button = uicontrol(...
    'Parent',h.Cor.Panel,...
    'Tag','Cor_Multi_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'FontWeight','bold',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Multiple',...
    'Callback',{@Correlate,2},...
    'Position',[0.13 0.01 0.12 0.09],...
    'TooltipString',sprintf('Load multiple files and individually correlates them'));
%%% Determines data format
h.Cor.Format = uicontrol(...
    'Parent',h.Cor.Panel,...
    'Tag','Cor_Format',...
    'Units','normalized',...
    'FontSize',10,...
    'FontWeight','bold',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'Matlab file (.mcor)';'Text file (.cor)'; 'both'},...
    'Position',[0.26 0 0.24 0.09],...
    'Style','popupmenu',...
    'TooltipString',sprintf('Select fileformat for saving correlation files'));
if ismac
    h.Cor.Format.ForegroundColor = [0 0 0];
    h.Cor.Format.BackgroundColor = [1 1 1];
end
%%% Determines correlation type
h.Cor.Type = uicontrol(...
    'Parent',h.Cor.Panel,...
    'Units','normalized',...
    'FontSize',10,...
    'FontWeight','bold',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'Point';'Pair (Line)';'Pair (Circular)';'Microtime';'Microtime (linear)'},...
    'Position',[0.5 0 0.17 0.09],...
    'Style','popupmenu',...
    'Callback',@Calculate_Settings,...
    'TooltipString',sprintf('Choose between point and pair correlation'));
if ismac
    h.Cor.Type.ForegroundColor = [0 0 0];
    h.Cor.Type.BackgroundColor = [1 1 1];
end

h.Cor.AggregateCorrection = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Cor.Panel,...
    'Units','normalized',...
    'FontSize',10,...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.67 0.05 0.3 0.05],...
    'Callback',@Calculate_Settings,...
    'String','Remove aggregates',...
    'Value',0,...
    'TooltipString','Removes aggregates. Set parameters in the tab below. Only works for autocorrelation.');

h.Cor.AfterPulsingCorrection = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Cor.Panel,...
    'Units','normalized',...
    'FontSize',10,...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.67 0 0.3 0.05],...
    'Callback',@Calculate_Settings,...
    'String','Correct for afterpulsing',...
    'Value',UserValues.Settings.Pam.AfterpulsingCorrection,...
    'TooltipString','Enables afterpulsing correction based on FLCS.');

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Cor.Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','#Bins:',...
    'HorizontalAlignment','left',...
    'Visible','off',...
    'Tag','PairCorBins',...
    'Position',[0.67 0 0.09 0.09]);
%%% Sets number of bins for pair correlation
h.Cor.Pair_Bins = uicontrol(...
    'Parent',h.Cor.Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','edit',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','50',...
    'Visible','off',...
    'Position',[0.76 0.01 0.06 0.09],...
    'TooltipString',sprintf('Select number of bins for pair correlation'));
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Cor.Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Distance:',...
    'Visible','off',...
    'Tag','PairCorDistance',...
    'HorizontalAlignment','left',...
    'Position',[0.83 0 0.10 0.09]);
%%% Sets bin distances to correlatie
h.Cor.Pair_Dist = uicontrol(...
    'Parent',h.Cor.Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','edit',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','1:50',...
    'Position',[0.93 0.01 0.06 0.09],...
    'Visible','off',...
    'TooltipString',sprintf('Select bin distances to calculate for pair correlation'));

%%% Tabgroup for ploting Correlations
h.Cor.Correlations_Tabs = uitabgroup(...
    'Parent',h.Cor.Tab,...
    'Tag','Cor_Tabs',...
    'Position',[0 0 1 0.52]);
h.Cor.Individual_Tab{1} = uitab(...
    'Parent',h.Cor.Correlations_Tabs,...
    'Tag','Cor_Ind_Tabs_1',...
    'BackgroundColor',Look.Back,...
    'Title','No data');
h.Cor.Individual_Axes{1} = axes(...
    'Parent',h.Cor.Individual_Tab{1},...
    'Tag','Cor_Individual_Axes',...
    'Units','normalized',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'XScale','Log',...
    'XLim',[3e-7,1],...
    'Position',[0.08 0.11 0.9 0.85],...
    'Box','on');
h.Cor.Individual_Axes{1}.XLabel.String='Lag Time [s]';
h.Cor.Individual_Axes{1}.XLabel.Color=Look.Fore;
h.Cor.Individual_Axes{1}.YLabel.String='G({\it\tau{}})';
h.Cor.Individual_Axes{1}.YLabel.Color=Look.Fore;

h.Cor.Individual_Menu = uicontextmenu;
%%% Menu for selecting all individual correlations
h.Cor.Individual_Select_All = uimenu(...
    'Parent',h.Cor.Individual_Menu,...
    'Label','Select All',...
    'Tag','Select All',...
    'Callback',{@Cor_Selection,2});
%%% Menu for unselecting all individual correlations
h.Cor.Individual_UnSelect_All = uimenu(...
    'Parent',h.Cor.Individual_Menu,...
    'Label','Unselect All',...
    'Tag','Unselect All',...
    'Callback',{@Cor_Selection,3});
%%% Menu for saving selected correlations
h.Cor.Individual_UnSelect_All = uimenu(...
    'Parent',h.Cor.Individual_Menu,...
    'Label','Save selected correlations',...
    'Tag','Save_Selected',...
    'Callback',{@Cor_Selection,4});

%%% Tab for the removal of aggregates
h.Cor.Remove_Aggregates_Tab = uitab(...
    'Parent',h.Cor.Correlations_Tabs,...
    'Tag','Cor_Remove_Aggregates_Tab',...
    'BackgroundColor',Look.Back,...
    'Title','Remove aggregates');

h.Cor.Remove_Aggregates_Axes = axes(...
    'Parent',h.Cor.Remove_Aggregates_Tab,...
    'Tag','Remove_Aggregates_Axes',...
    'Units','normalized',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'Position',[0.075 0.25 0.9 0.72],...
    'Box','on');
h.Cor.Remove_Aggregates_Axes.XLabel.String='Time [s]';
h.Cor.Remove_Aggregates_Axes.XLabel.Color=Look.Fore;
h.Cor.Remove_Aggregates_Axes.YLabel.String='Count rate [kHz]';
h.Cor.Remove_Aggregates_Axes.YLabel.Color=Look.Fore;
h.Cor.Remove_Aggregates_Axes_Menu = uicontextmenu;
h.Cor.Remove_Aggregates_Axes_Log = uimenu('Parent',h.Cor.Remove_Aggregates_Axes_Menu,...
    'Label','Y-scale log',...
    'Checked','off',...
    'Callback',@Calculate_Settings);
h.Cor.Remove_Aggregates_Axes.UIContextMenu = h.Cor.Remove_Aggregates_Axes_Menu;

h.Cor.Remove_Aggregates_FCS_Axes = axes(...
    'Parent',h.Cor.Remove_Aggregates_Tab,...
    'Tag','Remove_Aggregates_FCS_Axes',...
    'Units','normalized',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'XScale','log',...
    'LineWidth', Look.AxWidth,...
    'Position',[0.635 0.25 0.35 0.72],...
    'Box','on',...
    'Visible','off');
h.Cor.Remove_Aggregates_FCS_Axes.XLabel.String='Lag Time [s]';
h.Cor.Remove_Aggregates_FCS_Axes.XLabel.Color=Look.Fore;
h.Cor.Remove_Aggregates_FCS_Axes.YLabel.String='G(\tau) norm.';
h.Cor.Remove_Aggregates_FCS_Axes.YLabel.Color=Look.Fore;

h.Cor.Aggregate_GridContainer = uigridcontainer(...
    'Parent',h.Cor.Remove_Aggregates_Tab,...
    'GridSize',[2,5],...
    'Units','norm',...
    'Position',[0,0,1,0.125],...
    'BackgroundColor',Look.Back);

h.Cor.Remove_Aggregate_Block_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Cor.Aggregate_GridContainer,...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Macrotime block:',...
    'TooltipString','Select which macrotime block to use for preview.');
h.Cor.Remove_Aggregate_Nsigma_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Cor.Aggregate_GridContainer,...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Threshold [STDEV]:',...
    'TooltipString','Set the threshold in units of the signal standard deviation.');
h.Cor.Remove_Aggregate_Timewindow_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Cor.Aggregate_GridContainer,...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Time window [ms]:',...
    'TooltipString','Set the time window in units of milliseconds.');
h.Cor.Remove_Aggregate_TimeWindowAdd_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Cor.Aggregate_GridContainer,...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Add window:',...
    'TooltipString','Add a time frame around detected bursts in units of the selected time window.');
h.Cor.Replot_Aggregate_Plot_Button = uicontrol(...
    'Style','pushbutton',...
    'Parent',h.Cor.Aggregate_GridContainer,...
    'FontSize',10,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Plot preview',...
    'Callback',@Remove_Aggregates_Preview);

h.Cor.Remove_Aggregate_Block_Edit = uicontrol(...
    'Style','edit',...
    'Parent',h.Cor.Aggregate_GridContainer,...
    'FontSize',10,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','1',...
    'Callback',@Calculate_Settings,...
    'TooltipString','Select which macrotime block to use for preview.');
h.Cor.Remove_Aggregate_Nsigma_Edit = uicontrol(...
    'Style','edit',...
    'Parent',h.Cor.Aggregate_GridContainer,...
    'FontSize',10,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',num2str(UserValues.Settings.Pam.Cor_Aggregate_Threshold),...
    'Callback',@Calculate_Settings,...
    'TooltipString','Set the threshold in units of the signal standard deviation.');
h.Cor.Remove_Aggregate_Timewindow_Edit = uicontrol(...
    'Style','edit',...
    'Parent',h.Cor.Aggregate_GridContainer,...
    'FontSize',10,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',num2str(UserValues.Settings.Pam.Cor_Aggregate_Timewindow),...
    'Callback',@Calculate_Settings,...
    'TooltipString','Set the time window in units of milliseconds.');
h.Cor.Remove_Aggregate_TimeWindowAdd_Edit = uicontrol(...
    'Style','edit',...
    'Parent',h.Cor.Aggregate_GridContainer,...
    'FontSize',10,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'TooltipString','Add a time frame around detected bursts in units of the selected time window.',...
    'String',num2str(UserValues.Settings.Pam.Cor_Aggregate_TimewindowAdd),...
    'Callback',@Calculate_Settings);
h.Cor.Preview_Correlation_Checkbox = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Cor.Aggregate_GridContainer,...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','FCS preview',...
    'Callback',[],...
    'Value',0,...
    'Callback',@Calculate_Settings);
%% Burst tab
s.ProgressRatio = 0.5;

h.Burst.Tab = uitab(...
    'Parent',h.Det_Tabs,...
    'Tag','Burst_Tab',...
    'Title','Burst Analysis');
%%% Burst panel
h.Burst.MainPanel = uibuttongroup(...
    'Parent',h.Burst.Tab,...
    'Tag','Burst_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%% Sub Panels for easier ordering of stuff
h.Burst.SubPanel_Settings = uibuttongroup(...
    'Parent',h.Burst.MainPanel,...
    'Tag','Burst_SubPanel_Settings',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0.55 .3 .45]);
h.Burst.SubPanel_BurstSearch = uibuttongroup(...
    'Parent',h.Burst.MainPanel,...
    'Tag','Burst_SubPanel_BurstSearch',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.3 0.55 .45 .45]);
%%% uimenu to export burst preview
h.Burst.Export_Menu = uicontextmenu;
h.Burst.Export_Menu_Preview = uimenu(h.Burst.Export_Menu,...
    'Text','Export Preview Window',...
    'Callback',@export_burst_preview);
%%% Axes for preview of Burst Selection
h.Burst.Axes_Intensity = axes(...
    'Parent',h.Burst.MainPanel,...
    'Tag','Burst_Axes_Intensity',...
    'Position',[0.07 0.26 0.92 0.2],...
    'Units','normalized',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'UIContextMenu',h.Burst.Export_Menu,...
    'Box','on');
h.Burst.Axes_Intensity.XLabel.String='';
h.Burst.Axes_Intensity.XLabel.Color=Look.Fore;
h.Burst.Axes_Intensity.YLabel.String='Count rate [kHz]';
h.Burst.Axes_Intensity.YLabel.Color=Look.Fore;
h.Burst.Axes_Intensity.XLim = [0 1];
h.Burst.Axes_Intensity.YLim = [0 1];
h.Burst.Axes_Intensity.XAxisLocation = 'top';

h.Plots.BurstPreview.Channel1 = plot([0 1],[0 0],'g');
h.Plots.BurstPreview.Channel2 = plot([0 1],[0 0],'r');
h.Plots.BurstPreview.Channel3 = plot([0 1],[0 0],'b');
h.Plots.BurstPreview.Intensity_Threshold_ch1 = plot([0 1],[0 0],'--g','Visible','off');
h.Plots.BurstPreview.Intensity_Threshold_ch2 = plot([0 1],[0 0],'--r','Visible','off');
h.Plots.BurstPreview.Intensity_Threshold_ch3 = plot([0 1],[0 0],'--b','Visible','off');

h.Burst.Axes_Interphot = axes(...
    'Parent',h.Burst.MainPanel,...
    'Tag','Burst_Axes_Interphot',...
    'Position',[0.07 0.06 0.92 0.2],...
    'Units','normalized',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'YScale','log',...
    'UIContextMenu',h.Burst.Export_Menu,...
    'Box','on');
h.Burst.Axes_Interphot.XLabel.String='Time [s]';
h.Burst.Axes_Interphot.XLabel.Color=Look.Fore;
h.Burst.Axes_Interphot.YLabel.String='Interphoton time [\mus]';
h.Burst.Axes_Interphot.YLabel.Color=Look.Fore;
h.Burst.Axes_Interphot.XLim = [0 1];
h.Burst.Axes_Interphot.YLim = [0 1];

h.Plots.BurstPreview.Channel1_Interphot = plot([0 1],[0 0],'.g','MarkerSize',2);
h.Plots.BurstPreview.Channel1_Interphot_Smooth = plot([0 1],[0 0],'-g');
h.Plots.BurstPreview.Channel2_Interphot = plot([0 1],[0 0],'.r','Visible','off','MarkerSize',2);
h.Plots.BurstPreview.Channel2_Interphot_Smooth = plot([0 1],[0 0],'-r','Visible','off');
h.Plots.BurstPreview.Channel3_Interphot = plot([0 1],[0 0],'.b','Visible','off','MarkerSize',2);
h.Plots.BurstPreview.Channel3_Interphot_Smooth = plot([0 1],[0 0],'-b','Visible','off');
h.Plots.BurstPreview.Interphoton_Threshold_ch1 = plot([0 1],[0 0],'--g','Visible','off');
h.Plots.BurstPreview.Interphoton_Threshold_ch2 = plot([0 1],[0 0],'--r','Visible','off');
h.Plots.BurstPreview.Interphoton_Threshold_ch3 = plot([0 1],[0 0],'--b','Visible','off');

linkaxes([h.Burst.Axes_Interphot,h.Burst.Axes_Intensity],'x');
%%% Button to show a preview of the burst search
h.Burst.BurstSearchPreview_Button = uicontrol(...
    'Parent',h.Burst.MainPanel,...
    'Tag','BurstSearchPreview_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Preview',...
    'Callback',@BurstSearch_Preview,...
    'Position',[0.865 0.43 0.12 0.025],...
    'TooltipString',sprintf('Update the preview display.'));
%%%Buttons to shift the preview by one second forwards or backwards
h.Burst.BurstSearchPreview_Slider = uicontrol(...
    'Parent',h.Burst.MainPanel,...
    'Style','slider',...
    'Tag','BurstSearchPreview_Slider',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.865 0.405 0.12 0.025],...
    'Callback',@BurstSearch_Preview,...
    'Enable','off',...
    'TooltipString',sprintf(''));

%%% Button to start Burst Analysis
h.Burst.Button = uicontrol(...
    'Parent',h.Burst.SubPanel_Settings,...
    'Tag','Burst_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Do Burst Search',...
    'Callback',@Do_BurstAnalysis,...
    'Position',[0.05 0.9 0.9 0.08],...
    'TooltipString',sprintf('Start Burst Analysis'));
%%% Right-click menu for Burst_Button to allow loading of performed
%%% BurstSearches for posterior Lifetime (re-)fitting and NirFilter
%%% (re-)calculation
h.Burst.Button_Menu = uicontextmenu;
h.Burst.Button_Menu_LoadData = uimenu(h.Burst.Button_Menu,...
    'Label','Load performed BurstSearch',...
    'Callback',@Load_Performed_BurstSearch);
h.Burst.Button_Menu_fromBurstIDs = uimenu(h.Burst.Button_Menu,...
    'Label','Generate Burst File from BurstIDs',...
    'Callback',@Do_BurstAnalysis,...
    'Separator','on');
h.Burst.Button_Menu_LoadData = uimenu(h.Burst.Button_Menu,...
    'Label','Export total measurement to PDA',...
    'Callback',@Export_total_to_PDA,...
    'Separator','on');
h.Burst.Button_Menu_LoadData = uimenu(h.Burst.Button_Menu,...
    'Label','Estimate background count rates from burst experiment or bursty buffer',...
    'Callback',@Estimate_Background_From_Burst,...
    'Separator','on');
h.Burst.Button.UIContextMenu = h.Burst.Button_Menu;
%%% Right-click menu for BurstLifetime_Button to allow loading of
%%% IRF/Scatter AFTER performed burst search using stored PIE settings
h.Burst.BurstLifetime_Button_Menu = uicontextmenu;
h.Burst.BurstLifetime_Button_Menu_StoreIRF = uimenu(h.Burst.BurstLifetime_Button_Menu,...
    'Label','Store current IRF in *.bur file',...
    'Callback',{@Store_IRF_Scat_inBur,0});
h.Burst.BurstLifetime_Button_Menu_StoreScatter = uimenu(h.Burst.BurstLifetime_Button_Menu,...
    'Label','Store current Scatter and background measurement in *.bur file',...
    'Callback',{@Store_IRF_Scat_inBur,1});
h.Burst.BurstLifetime_Button_Menu_StorePhasorReference = uimenu(h.Burst.BurstLifetime_Button_Menu,...
    'Label','Store current Phasor Reference in *.bur file',...
    'Callback',{@Store_IRF_Scat_inBur,2});
h.Burst.BurstLifetime_Button_Menu_StoreDonorOnlyReference = uimenu(h.Burst.BurstLifetime_Button_Menu,...
    'Label','Store current Donor-only Reference in *.bur file',...
    'Callback',{@Store_IRF_Scat_inBur,3});

%%% Button to start burstwise Lifetime Fitting
h.Burst.BurstLifetime_Button = uicontrol(...
    'Parent',h.Burst.SubPanel_Settings,...
    'Tag','BurstLifetime_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Burstwise Lifetime',...
    'Callback',@BurstLifetime,...
    'Position',[0.05 0.5 0.9 0.08],...
    'TooltipString',sprintf('Perform Burstwise Lifetime Fit or set Burstwise Lifetime settings'),...
    'UIContextMenu',h.Burst.BurstLifetime_Button_Menu);
%%% Button to calculate 2CDE Filter
h.Burst.NirFilter_Button = uicontrol(...
    'Parent',h.Burst.SubPanel_Settings,...
    'Tag','NirFilter_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','2CDE',...
    'Callback',@NirFilter,...
    'Position',[0.05 0.4 0.5 0.08],...
    'TooltipString',sprintf('Calculate 2CDE Filter'));
%%% Checkbox to calculate 2CDE filter
h.Burst.NirFilter_Checkbox = uicontrol(...
    'Parent',h.Burst.SubPanel_Settings,...
    'Tag','NirFilter_Checkbox',...
    'Style', 'checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',UserValues.BurstSearch.NirFilter,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Calculate 2CDE',...
    'Position',[0.05 0.8 0.9 0.08],...
    'TooltipString',sprintf('Calculate 2CDE Filter when doing Burst Search'),...
    'Callback', @Calculate_Settings);
%%% Contextmenu to optimize the IRF shift automatically
h.Burst.BurstLifetime_Checkbox_Menu = uicontextmenu;
h.Burst.BurstLifetime_Checkbox_Menu_IRFshift = uimenu(h.Burst.BurstLifetime_Checkbox_Menu,...
    'Label','Automatically optimize IRF shift',...
    'Checked',UserValues.BurstSearch.AutoIRFShift,...
    'Callback', @Calculate_Settings);
%%% Checkbox to calculate lifetime automatically
h.Burst.BurstLifetime_Checkbox = uicontrol(...
    'Parent',h.Burst.SubPanel_Settings,...
    'Tag','BurstLifetime_Checkbox',...
    'Style', 'checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',UserValues.BurstSearch.FitLifetime,...
    'UIContextMenu',h.Burst.BurstLifetime_Checkbox_Menu,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Fit lifetime',...
    'Position',[0.05 0.7 0.9 0.08],...
    'TooltipString',sprintf('Calculate Burstwise Lifetime when doing Burst Search. All settings for lifetime analysis need to be set correctly beforehand! Right-click for automatic +20/-20 IRF Shift Prefit prior to Burstwise fit!'),...
    'Callback', @Calculate_Settings);
h.Burst.SaveTotalPhotonStream_Checkbox = uicontrol(...
    'Parent',h.Burst.SubPanel_Settings,...
    'Tag','SaveTotalPhotonStream_Checkbox',...
    'Style', 'checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',UserValues.BurstSearch.SaveTotalPhotonStream,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Save total photon stream',...
    'Position',[0.05 0.6 0.9 0.08],...
    'TooltipString',sprintf('Save total photons stream for correlation analysis with time window in BurstBrowser\nThis will take disk space comparable to the size of the raw data!'),...
    'Callback',@Calculate_Settings);
%%%Edit to change the time constant for the filter
h.Burst.NirFilter_Edit = uicontrol(...
    'Style','edit',...
    'Parent',h.Burst.SubPanel_Settings,...
    'Tag','NirFilter_Edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','100',...
    'Callback',[],...
    'Position',[0.6 0.4 0.2 0.08],...
    'TooltipString',sprintf('Specify the Time Constant for Filter Calculation in microseconds.'));  %(e.g. 100 or 100;200 or 100:100:1000)'
%%%text label to specify the unit of the edit values (mu s)
h.Burst.NirFilter_Text1 = uicontrol(...
    'Style','text',...
    'enable','inactive',...
    'Parent',h.Burst.SubPanel_Settings,...
    'Tag','NirFilter_Text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','us',...
    'Callback',[],...
    'Position',[0.82 0.4 0.18 0.07],...
    'TooltipString',sprintf('Specify the Time Constant for Filter Calculation (e.g. 100 or 100;200 or 100:100:1000)'));
h.Burst.ConstantDuration_Checkbox = uicontrol(...
    'Parent',h.Burst.SubPanel_Settings,...
    'Tag','ConstantDuration_Checkbox',...
    'Style', 'checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',1,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Total duration',...
    'Position',[0.05 0.3 0.9 0.08],...
    'TooltipString',sprintf('Instead of calculating PIE channel count rates by dividing number of photons\nby the duration in the PIE channel, the number of photons is divided by the APBS duration'),...
    'Callback',@Calculate_Settings);
% h.Burst.RescaleToBackground_Checkbox = uicontrol(...
%     'Parent',h.Burst.SubPanel_Settings,...
%     'Tag','RescaleToBackground_Checkbox',...
%     'Style', 'checkbox',...
%     'Units','normalized',...
%     'FontSize',12,...
%     'Value',0,...
%     'BackgroundColor', Look.Back,...
%     'ForegroundColor', Look.Fore,...
%     'String','Rescale to background',...
%     'Position',[0.05 0.2 0.9 0.08],...
%     'TooltipString',sprintf('If a background measurement was saved into PAM memory,\nthe burst search parameters are rescaled to stay above the background'),...
%     'Callback',@Calculate_Settings);
%%%Table for PIE channel assignment
h.Burst.BurstPIE_Table = uitable(...
    'Parent',h.Burst.MainPanel,...
    'Units','normalized',...
    'Tag','BurstPIE_Table',...
    'FontSize',12,...
    'Position',[0.75 0.55 0.25 0.45],...
    'CellEditCallback',@BurstSearchParameterUpdate,...
    'RowStriping','on');

%%% store the information for the BurstPIE_Table in the handles
%%% structure
%%% Labels for 2C-noMFD All-Photon Burst Search
h.Burst.BurstPIE_Table_Content.APBS_twocolornoMFD.RowName = {'DD','DA','AA'};
h.Burst.BurstPIE_Table_Content.APBS_twocolornoMFD.ColumnName = {'PIE Channel'};
%%% Labels for 2C-noMFD Dual-Channel Burst Search
h.Burst.BurstPIE_Table_Content.DCBS_twocolornoMFD.RowName = {'DD','DA','AA'};
h.Burst.BurstPIE_Table_Content.DCBS_twocolornoMFD.ColumnName = {'PIE Channel'};
%%% Labels for 2C-MFD All-Photon Burst Search
h.Burst.BurstPIE_Table_Content.APBS_twocolorMFD.RowName = {'DD','DA','AA'};
h.Burst.BurstPIE_Table_Content.APBS_twocolorMFD.ColumnName = {'Parallel','Perpendicular'};
%%% Labels for 2C-MFD Dual-Channel Burst Search
h.Burst.BurstPIE_Table_Content.DCBS_twocolorMFD.RowName = {'DD','DA','AA'};
h.Burst.BurstPIE_Table_Content.DCBS_twocolorMFD.ColumnName = {'Parallel','Perpendicular'};
%%% Labels for 3C-MFD All-Photon Burst Search
h.Burst.BurstPIE_Table_Content.APBS_threecolorMFD.RowName = {'BB','BG','BR','GG','GR','RR'};
h.Burst.BurstPIE_Table_Content.APBS_threecolorMFD.ColumnName = {'Parallel','Perpendicular'};
%%% Labels for 3C-MFD Triple-Channel Burst Search
h.Burst.BurstPIE_Table_Content.TCBS_threecolorMFD.RowName = {'BB','BG','BR','GG','GR','RR'};
h.Burst.BurstPIE_Table_Content.TCBS_threecolorMFD.ColumnName = {'Parallel','Perpendicular'};

h.Burst.BurstSearchMethods = {'APBS_twocolorMFD','DCBS_twocolorMFD','APBS_threecolorMFD','TCBS_threecolorMFD','APBS_twocolornoMFD','DCBS_twocolornoMFD'};
%%% Button to convert a measurement to a photon stream based on PIE
%%% channel  selection
h.Burst.PhotonstreamConvert_Button = uicontrol(...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','PhotonstreamConvert_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Convert Photonstream',...
    'Callback',@PhotonstreamConvert,...
    'Position',[0.75 0.6 0.24 0.07],...
    'TooltipString',sprintf('Convert Photonstream to channels based on PIE channel selection'),...
    'Visible','off',...
    'Enable','off');

%%% Textbox showing the currently loaded/analyzed BurstData (*.bur)
%%% file
h.Burst.LoadedFile_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Burst.MainPanel,...
    'Tag','BurstParameter1_Edit',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','no *.bur file loaded',...
    'Position',[0.01 0.49 0.98 0.05],...
    'TooltipString',sprintf(''));

%%%Popup Menu for Selection of Burst Search
h.Burst.BurstSearchSmoothing_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstSearchSmoothing_Text',...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Select Smoothing Method:',...
    'Position',[0.05 0.85 0.9 0.08],...
    'TooltipString',sprintf(''));
h.Burst.BurstSearchSmoothing_Popupmenu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstSearchSelection_Popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'Sliding Time Window','Interphoton Time with Lee Filter','CUSUM','Change Point Analysis'},...
    'Callback',@Update_BurstGUI,...
    'Position',[0.05 0.75 0.9 0.08],...
    'TooltipString',sprintf(''));

h.Burst.BurstSearchSelection_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstSearchSelection_Text',...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Select Burst Search Method:',...
    'Position',[0.05 0.65 0.9 0.08],...
    'TooltipString',sprintf('APBS: All Photon Burst Search\nDCBS: Double Channel Burst Search\nTCBS: Triple Channel Burst Search\n2C: Two-Color Experiment\n3C: Three-Color Experiment\nMFD: Multiparameter Fluorescence Detection, i.e. with polarized detection\nno-MFD: No polarized detection'));
h.Burst.BurstSearchSelection_Popupmenu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstSearchSelection_Popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'APBS 2C-MFD','DCBS 2C-MFD','APBS 3C-MFD','TCBS 3C-MFD','APBS 2C-noMFD','DCBS 2C-noMFD'},...
    'Callback',@Update_BurstGUI,...
    'Position',[0.05 0.55 0.9 0.08],...
    'TooltipString',sprintf('APBS: All Photon Burst Search\nDCBS: Double Channel Burst Search\nTCBS: Triple Channel Burst Search\n2C: Two-Color Experiment\n3C: Three-Color Experiment\nMFD: Multiparameter Fluorescence Detection, i.e. with polarized detection\nno-MFD: No polarized detection'));
h.Burst.BurstSearchSelection_ANDOR_Popupmenu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstSearchSelection_Popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'AND','OR (merge)','OR (no merge)','XOR'},...
    'Value',find(strcmp(UserValues.BurstSearch.LogicalGate,{'AND','OR (merge)','OR (no merge)','XOR'})),...
    'Callback',@Update_BurstGUI,...
    'Position',[0.55 0.55 0.44 0.08],...
    'Visible','off',...
    'TooltipString',sprintf('AND: only regions where all channels detect a burst are selected\nOR: all regions where either channels detects a burst are selected. merge/no merge decides whether overlapping bursts are merged or kept as separate events.\nXOR: exclusive OR - regions were only a single channel detected a burst are selected'));
if ismac
    h.Burst.BurstSearchSelection_Popupmenu.ForegroundColor = [0 0 0];
    h.Burst.BurstSearchSelection_Popupmenu.BackgroundColor = [1 1 1];
    h.Burst.BurstSearchSmoothing_Popupmenu.ForegroundColor = [0 0 0];
    h.Burst.BurstSearchSmoothing_Popupmenu.BackgroundColor = [1 1 1];
    h.Burst.BurstSearchSelection_ANDOR_Popupmenu.ForegroundColor = [0 0 0];
    h.Burst.BurstSearchSelection_ANDOR_Popupmenu.BackgroundColor = [1 1 1];
end
%%% Edit Box for Parameter1 (Number of Photons Threshold)
h.Burst.BurstParameter1_Edit = uicontrol(...
    'Style','edit',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstParameter1_Edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','100',...
    'Callback',@BurstSearchParameterUpdate,...
    'Position',[0.75 0.45 0.2 0.08],...
    'TooltipString',sprintf(''));
%%% Text Box for Parameter1 (Number of Photons Threshold)
h.Burst.BurstParameter1_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstParameter1_Text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Minimum Photons per Burst:',...
    'Callback',@BurstSearchParameterUpdate,...
    'Position',[0.05 0.45 0.65 0.08],...
    'TooltipString',sprintf(''));
%%% Edit Box for Parameter2 (Time Window)
h.Burst.BurstParameter2_Edit = uicontrol(...
    'Style','edit',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstParameter2_Edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','500',...
    'Callback',@BurstSearchParameterUpdate,...
    'Position',[0.75 0.35 0.2 0.08],...
    'TooltipString',sprintf(''));
%%% Text Box for Parameter2 (Number of Photons Threshold)
h.Burst.BurstParameter2_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstParameter2_Text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Time Window [us]:',...
    'Callback',@BurstSearchParameterUpdate,...
    'Position',[0.05 0.35 0.65 0.08],...
    'TooltipString',sprintf(''));
%%% Alternative checkbox for ChangePoint Algorithm to include the
%%% uncertainty of start/stop
%%% hidden by default
h.Burst.BurstParameter2_Checkbox = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstParameter2_Text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Value',UserValues.BurstSearch.ChangePointIncludeSigma,...
    'String','Include uncertainty region?',...
    'Callback',@BurstSearchParameterUpdate,...
    'Position',[0.05 0.35 0.85 0.08],...
    'Visible','off',...
    'TooltipString','<html>Extends burst to the lower boundary of the start estimate<br>and the upper boundary of the stop estimate.<br>By default, 1&sigma; is used.</html>');

%%% Edit Box for Parameter6 (Time Window for second channel)
%%% Note: This was added later. No text is needed.
h.Burst.BurstParameter6_Edit = uicontrol(...
    'Style','edit',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstParameter6_Edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','500',...
    'Callback',@BurstSearchParameterUpdate,...
    'Position',[0.85 0.35 0.1 0.08],...
    'TooltipString',sprintf(''),...
    'Visible','off');
%%% Edit Box for Parameter3 (Photons per Time Window Threshold 1)
h.Burst.BurstParameter3_Edit = uicontrol(...
    'Style','edit',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstParameter3_Edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','5',...
    'Callback',@BurstSearchParameterUpdate,...
    'Position',[0.75 0.25 0.2 0.08],...
    'TooltipString',sprintf(''));
%%% Text Box for Parameter3 (Photons per Time Window Threshold 1)
h.Burst.BurstParameter3_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstParameter3_Text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...'
    'ForegroundColor', Look.Fore,...
    'String','Photons per Time Window:',...
    'Callback',@BurstSearchParameterUpdate,...
    'Position',[0.05 0.25 0.65 0.08],...
    'TooltipString',sprintf(''));
%%% Edit Box for Parameter4 (Photons per Time Window Threshold 2)
h.Burst.BurstParameter4_Edit = uicontrol(...
    'Style','edit',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstParameter4_Edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','5',...
    'Callback',@BurstSearchParameterUpdate,...
    'Position',[0.75 0.15 0.2 0.08],...
    'TooltipString',sprintf(''));
%%% Text Box for Parameter4 (Photons per Time Window Threshold 2)
h.Burst.BurstParameter4_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstParameter4_Text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Photons per Time Window:',...
    'Callback',@BurstSearchParameterUpdate,...
    'Position',[0.05 0.15 0.65 0.08],...
    'TooltipString',sprintf(''));
%%% Edit Box for Parameter5 (Photons per Time Window Threshold 3)
h.Burst.BurstParameter5_Edit = uicontrol(...
    'Style','edit',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstParameter5_Edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','5',...
    'Callback',@BurstSearchParameterUpdate,...
    'Position',[0.75 0.05 0.20 0.08],...
    'TooltipString',sprintf(''));
%%% Text Box for Parameter5 (Photons per Time Window Threshold 3)
h.Burst.BurstParameter5_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Burst.SubPanel_BurstSearch,...
    'Tag','BurstParameter5_Text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Photons per Time Window:',...
    'Callback',@BurstSearchParameterUpdate,...
    'Position',[0.05 0.05 0.65 0.08],...
    'TooltipString',sprintf(''));

%%% Disable all further processing buttons of BurstSearch
h.Burst.NirFilter_Button.Enable = 'off';
h.Burst.BurstLifetime_Button.Enable = 'off';
%% fFCS/FLCS tab
h.Cor_fFCS.Tab= uitab(...
    'Parent',h.Det_Tabs,...
    'Tag','Cor_fFCS_Tab',...
    'BackgroundColor',Look.Back,...
    'Title','fFCS');
%%% Correlation panel
h.Cor_fFCS.Panel = uibuttongroup(...
    'Parent',h.Cor_fFCS.Tab,...
    'Tag','Cor_fFCS_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0.52 1 0.48]);
%%% button for saving current measurements microtime pattern
h.Cor_fFCS.Save_MIPattern_Button = uicontrol(...
    'Parent',h.Cor_fFCS.Panel,...
    'String','Save microtime pattern',...
    'Callback',@SaveLoadMIPattern,...
    'Units','normalized',...
    'Position',[0.01, 0.9, 0.28,0.08],...
    'Tag','Save_MIPattern_Button',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore);
%%% button for loading microtime patterns
h.Cor_fFCS.Load_MIPattern_Button = uicontrol(...
    'Parent',h.Cor_fFCS.Panel,...
    'String','Load microtime patterns',...
    'Callback',@SaveLoadMIPattern,...
    'Units','normalized',...
    'Position',[0.01, 0.8, 0.28,0.08],...
    'Tag','Load_MIPattern_Button',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore);
%%% button for plotting microtime patterns
h.Cor_fFCS.Prepare_Filter_Button  = uicontrol(...
    'Parent',h.Cor_fFCS.Panel,...
    'String','Calculate Filters',...
    'Callback',@Update_fFCS_GUI,...
    'Units','normalized',...
    'Position',[0.01, 0.7, 0.28,0.08],...
    'Tag','Plot_MIPattern_Button',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore);
%%% button for calculating filters
h.Cor_fFCS.Do_fFCS_Button  = uicontrol(...
    'Parent',h.Cor_fFCS.Panel,...
    'String','Correlation',...
    'Callback',@Update_fFCS_GUI,...
    'Units','normalized',...
    'Position',[0.01, 0.6, 0.14,0.08],...
    'Tag','Do_fFCS_Button',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore);
%%% Button to export RLICS TIFFs
h.Cor_fFCS.RLICS_TIFF= uicontrol(...
    'Parent',h.Cor_fFCS.Panel,...
    'String','RLICS',...
    'Callback',@Update_fFCS_GUI,...
    'Units','normalized',...
    'Position',[0.15, 0.6, 0.14,0.08],...
    'Tag','RLICS_fFCS_Button',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore);
%%% checkbox for enabling cross-correlation
h.Cor_fFCS.CrossCorr_Checkbox  = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Cor_fFCS.Panel,...
    'String','Enable independent channels',...
    'Callback',@Update_fFCS_GUI,...
    'Units','normalized',...
    'Position',[0.01, 0.5, 0.28,0.08],...
    'Tag','CrossCorr_Checkbox',...
    'FontSize',12,...
    'TooltipString',sprintf('Enables cross-correlation between independent channels \n with separate filter generation'),...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore);
%%% table of loaded microtime patterns
RowName = [];
ColumnFormat = {'char','logical'};
ColumnName = {'Species','active'};
Data = {'',false};
ColumnEditable = [false,true];
h.Cor_fFCS.MIPattern_Table = uitable(...
    'Parent',h.Cor_fFCS.Panel,...
    'Tag','MIPattern_Table',...
    'Units','normalized',...
    'Position',[0.3, 0.5, 0.35 ,0.5],...
    'Data',Data,...
    'ColumnName',ColumnName,...
    'RowName',RowName,...
    'ColumnEditable',ColumnEditable,...
    'ColumnFormat',ColumnFormat,...
    'CellEditCallback',@Update_fFCS_GUI...
    );
% format
h.Cor_fFCS.MIPattern_Table.Units = 'pixels';
x = h.Cor_fFCS.MIPattern_Table.Position(3);
h.Cor_fFCS.MIPattern_Table.ColumnWidth = {0.75*x,0.18*x};
h.Cor_fFCS.MIPattern_Table.Units = 'normalized';

%%% table of available PIE channels (determined from available
%%% information in loaded microtime patterns)
RowName = [];
ColumnFormat = {'char','logical'};
ColumnName = {'Channel','Use'};
Data = {'',false};
ColumnEditable = [false,true];
h.Cor_fFCS.PIEchan_Table = uitable(...
    'Parent',h.Cor_fFCS.Panel,...
    'Tag','PIEchan_Table',...
    'Units','normalized',...
    'Position',[0.65, 0.5, 0.35 ,0.5],...
    'Data',Data,...
    'ColumnName',ColumnName,...
    'RowName',RowName,...
    'ColumnEditable',ColumnEditable,...
    'ColumnFormat',ColumnFormat,...
    'CellEditCallback',@Update_fFCS_GUI...
    );
% format
h.Cor_fFCS.PIEchan_Table.Units = 'pixels';
x = h.Cor_fFCS.PIEchan_Table.Position(3);
h.Cor_fFCS.PIEchan_Table.ColumnWidth = {0.75*x,0.18*x};
h.Cor_fFCS.PIEchan_Table.Units = 'normalized';

%%% cross-correlation table of loaded species
RowName = {'Scatter'};
ColumnFormat = {'logical'};
ColumnName = {'Scatter'};
Data = {false};
ColumnEditable = [true];
h.Cor_fFCS.Cor_fFCS_Table = uitable(...
    'Parent',h.Cor_fFCS.Panel,...
    'Tag','Cor_fFCS_Table',...
    'Units','normalized',...
    'Position',[0, 0, 1 ,0.5],...
    'Data',Data,...
    'ColumnName',ColumnName,...
    'RowName',RowName,...
    'ColumnEditable',ColumnEditable,...
    'ColumnFormat',ColumnFormat...
    );
h.Cor_fFCS.MIPattern_Axis_Menu = uicontextmenu(...
    'Tag','MIPattern_Axis_Menu');
h.Cor_fFCS.MIPattern_Axis_Log = uimenu(h.Cor_fFCS.MIPattern_Axis_Menu,...
    'Callback',@Update_fFCS_GUI,...
    'Label','YScale log',...
    'Checked','off');

%%% plot for microtime patterns
h.Cor_fFCS.MIPattern_Axis = axes(...
    'Parent',h.Cor_fFCS.Tab,...
    'Tag','MIPattern_Axis',...
    'Units','normalized',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'Position',[0.06 0.275 0.925 0.22],...
    'UIContextMenu',h.Cor_fFCS.MIPattern_Axis_Menu,...
    'Box','on');
h.Cor_fFCS.MIPattern_Axis.XLabel.String='';
h.Cor_fFCS.MIPattern_Axis.XLabel.Color=Look.Fore;
h.Cor_fFCS.MIPattern_Axis.YLabel.String='PDF';
h.Cor_fFCS.MIPattern_Axis.YLabel.Color=Look.Fore;
h.Cor_fFCS.MIPattern_Axis.XLim=[1 4096];
h.Cor_fFCS.MIPattern_Axis.XTickLabel = [];
h.Plots.fFCS.MI_Plots{1} = handle(plot([0 1],[0 0],'b'));
%%% plot for filter
h.Cor_fFCS.Filter_Axis = axes(...
    'Parent',h.Cor_fFCS.Tab,...
    'Tag','Filter_Axis',...
    'Units','normalized',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'Position',[0.06 0.05 0.925 0.22],...
    'Box','on');
h.Cor_fFCS.Filter_Axis.XLabel.String='TCSPC channel';
h.Cor_fFCS.Filter_Axis.XLabel.Color=Look.Fore;
h.Cor_fFCS.Filter_Axis.YLabel.String='filter value';
h.Cor_fFCS.Filter_Axis.YLabel.Color=Look.Fore;
h.Cor_fFCS.Filter_Axis.XLim=[1 4096];
h.Plots.fFCS.Filter_Plots{1} = handle(plot([0 1],[0 0],'b'));

%%% plot for second set of microtime patterns when doing
%%% cross-correlation FLCS
h.Cor_fFCS.MIPattern_Axis2 = axes(...
    'Parent',h.Cor_fFCS.Tab,...
    'Tag','MIPattern_Axis2',...
    'Units','normalized',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'Position',[0.55 0.275 0.44 0.22],...
    'Box','on',...
    'Visible','off');
h.Cor_fFCS.MIPattern_Axis2.XLabel.String='';
h.Cor_fFCS.MIPattern_Axis2.XLabel.Color=Look.Fore;
h.Cor_fFCS.MIPattern_Axis2.YLabel.String='PDF';
h.Cor_fFCS.MIPattern_Axis2.YLabel.Color=Look.Fore;
h.Cor_fFCS.MIPattern_Axis2.XLim=[1 4096];
h.Cor_fFCS.MIPattern_Axis2.XTickLabel = [];
h.Plots.fFCS.MI_Plots2{1} = handle(plot([0 1],[0 0],'b'));
%%% plot for filter
h.Cor_fFCS.Filter_Axis2 = axes(...
    'Parent',h.Cor_fFCS.Tab,...
    'Tag','Filter_Axis2',...
    'Units','normalized',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'Position',[0.55 0.05 0.44 0.22],...
    'Box','on',...
    'Visible','off');
h.Cor_fFCS.Filter_Axis2.XLabel.String='TCSPC channel';
h.Cor_fFCS.Filter_Axis2.XLabel.Color=Look.Fore;
h.Cor_fFCS.Filter_Axis2.YLabel.String='filter value';
h.Cor_fFCS.Filter_Axis2.YLabel.Color=Look.Fore;
h.Cor_fFCS.Filter_Axis2.XLim=[1 4096];
h.Plots.fFCS.Filter_Plots2{1} = handle(plot([0 1],[0 0],'b'));
%% Additional detector functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Aditional detector functions tab
h.Additional.Tab= uitab(...
    'Parent',h.Det_Tabs,...
    'Tag','Additional_Tab',...
    'Title','Additional');
%%% Microtime tabs container
h.Additional.Tabs = uitabgroup(...
    'Parent',h.Additional.Tab,...
    'Tag','Additional_Tabs',...
    'Units','normalized',...
    'Position',[0 0 1 1]);
%% Plots and navigation for phasor referencing
%%% Phasor referencing tab
h.MI.Phasor_Tab= uitab(...
    'Parent',h.Additional.Tabs,...
    'Tag','MI_Phasor_Tab',...
    'Title','Phasor Referencing');
%%% Phasor referencing panel
h.MI.Phasor_Panel = uibuttongroup(...
    'Parent',h.MI.Phasor_Tab,...
    'Tag','MI_All_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'String','Shift:',...
    'Horizontalalignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.965 0.06 0.025]);
%%% Editbox for showing and setting shift
h.MI.Phasor_Shift = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_Shift',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'String','0',...
    'Callback',@Update_Phasor_Shift,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.08 0.965 0.08 0.025]);
%%% Shift slider
h.MI.Phasor_Slider = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_Slider',...
    'Style','Slider',...
    'SliderStep',[1 10]/1000,...
    'Min',-500,...
    'Max',500,...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',@Update_Phasor_Shift,...
    'BackgroundColor', Look.Axes,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.93 0.15 0.025]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'String','Range to use:',...
    'Horizontalalignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.18 0.965 0.15 0.025]);
%%% Phasor Range From
h.MI.Phasor_From = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_From',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'String','1',...
    'Callback',{@Update_Display;6},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.34 0.965 0.08 0.025]);
%%% Phasor Range To
h.MI.Phasor_To = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_To',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'String','4000',...
    'Callback',{@Update_Display;6},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.43 0.965 0.08 0.025]);
%%% Phasor detector channel
h.MI.Phasor_Det = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_Det',...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'String',{''},...
    'Callback',{@Update_Display;6},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.18 0.93 0.33 0.025]);
if ismac
    h.MI.Phasor_Det.ForegroundColor = [0 0 0];
    h.MI.Phasor_Det.BackgroundColor = [1 1 1];
end
%%% Phasor reference selection
h.MI.Phasor_UseRef = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_UseRef',...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',12,...
    'String','Use MI as reference',...
    'Callback',@Phasor_UseRef,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.52 0.965 0.25 0.025]);
%%% Phasor reference selection
h.MI.Calc_Phasor = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Calc_Phasor',...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',12,...
    'String','Calculate Phasor Data',...
    'Callback',@Phasor_Calc,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.52 0.93 0.25 0.025]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'String','Ref LT [ns]:',...
    'Horizontalalignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.78 0.965 0.13 0.025]);
%%% Editbox for the reference lifetime
h.MI.Phasor_Ref = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_Ref',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'String','4.1',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.91 0.965 0.08 0.025]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'String','TAC [ns]:',...
    'Horizontalalignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.78 0.93 0.13 0.025]);
%%% Editbox for the TAC range
h.MI.Phasor_TAC = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_TAC',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'String','40',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.91 0.93 0.08 0.025]);
%%% Particle Detection Selection
h.MI.Phasor_FramePopup = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_Particles',...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'String',{'Use Single Frame','Framewise Phasor'},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.885 0.30 0.025]);
if ismac
    h.MI.Phasor_FramePopup.ForegroundColor = [0 0 0];
    h.MI.Phasor_FramePopup.BackgroundColor = [1 1 1];
end

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'String','MI rebinning factor:',...
    'Horizontalalignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.84 0.17 0.025]);
%%% Editbox for rescaling TAC
h.MI.Phasor_Rebin = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_Rebin',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'String','1',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.19 0.84 0.08 0.025],...
    'Tooltipstring', 'e.g. a value of 16 rescales 4096 to 256 TAC bins',...
    'Callback',@Rebinmsg);

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'String','Ref. Background [Hz]:',...
    'Horizontalalignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.75 0.885 0.20 0.025]);
%%% Editbox for reference background correction
h.MI.Phasor_BG_Ref = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_BG_Ref',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'String','0',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.91 0.885 0.08 0.025]);

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'String','Background [Hz]:',...
    'Horizontalalignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.75 0.855 0.20 0.025]);
%%% Editbox for background correction
h.MI.Phasor_BG = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_BG',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'String','0',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.91 0.855 0.08 0.025]);

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'String','Afterpulsing [%]:',...
    'Horizontalalignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.75 0.825 0.20 0.025]);
%%% Editbox for afterpulsing correction
h.MI.Phasor_AP = uicontrol(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_AP',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'String','0',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.91 0.825 0.08 0.025]);


%%% Phasor referencing axes
h.MI.Phasor_Axes = axes(...
    'Parent',h.MI.Phasor_Panel,...
    'Tag','MI_Phasor_Axes',...
    'Units','normalized',...
    'NextPlot','add',...
    'UIContextMenu',h.MI.Menu,...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'Position',[0.09 0.05 0.89 0.73],...
    'Box','on');



h.MI.Phasor_Axes.XLabel.String='TCSPC channel';
h.MI.Phasor_Axes.XLabel.Color=Look.Fore;
h.MI.Phasor_Axes.YLabel.String='Counts';
h.MI.Phasor_Axes.YLabel.Color=Look.Fore;
h.MI.Phasor_Axes.XLim=[1 4096];
h.Plots.PhasorRef=handle(plot([0 1],[0 0],'b'));
h.Plots.Phasor=handle(plot([0 4000],[0 0],'r'));
%% Tab for calibrating Detectors
%%% Detector calibration tab
h.MI.Calib_Tab= uitab(...
    'Parent',h.Additional.Tabs,...
    'Tag','MI_Calib_Tab',...
    'Title','Detector Calibration');
%%% Detector calibration panel
h.MI.Calib_Panel = uibuttongroup(...
    'Parent',h.MI.Calib_Tab,...
    'Tag','MI_Calib_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%% Button to start calibration
h.MI.Calib_Calc = uicontrol(...
    'Parent',h.MI.Calib_Panel,...
    'Tag','MI_Calib_Calc',...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',12,...
    'String','Calculate correction',...
    'Callback',@Shift_Detector,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.965 0.25 0.025]);
%%% Text Maximum corrected ticks
h.Text{end+1} = uicontrol(...
    'Parent',h.MI.Calib_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','Left',...
    'String','Max',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.28 0.965 0.1 0.025]);
%%% Edit box maximum corrected ticks
h.MI.Calib_Single_Max = uicontrol(...
    'Parent',h.MI.Calib_Panel,...
    'Tag','MI_Calib_Single_Max',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'String','400',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.38 0.965 0.1 0.025]);

%%% Detector calibration channel
h.MI.Calib_Det = uicontrol(...
    'Parent',h.MI.Calib_Panel,...
    'Tag','MI_Calib_Det',...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'String',{''},...
    'Callback',{@Update_Display;7},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.93 0.25 0.025]);
if ismac
    h.MI.Calib_Det.ForegroundColor = [0 0 0];
    h.MI.Calib_Det.BackgroundColor = [1 1 1];
end
%%% Interphoton time selection
h.MI.Calib_Single = uicontrol(...
    'Parent',h.MI.Calib_Panel,...
    'Tag','MI_Calib_Single',...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',12,...
    'Min',1,...
    'Max',400,...
    'Value',1,...
    'SliderStep',[1 1]/399,...
    'Callback',{@Update_Display;7},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.965 0.25 0.025]);
%%% Show interphoton time
h.MI.Calib_Single_Text = uicontrol(...
    'Parent',h.MI.Calib_Panel,...
    'Tag','MI_Calib_Single_Text',...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'String','1',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.77 0.97 0.05 0.025]);
%%% TCSPC deadtime input field
h.Text{end+1} = uicontrol(...
    'Parent',h.MI.Calib_Panel,...
    'Tag','MI_Calib_Single_Text',...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'String','TCSPC Deadtime [ns]:',...
    'TooltipString',sprintf('Specifiy the deadtime of the TCSPC electronics in ns.\nThe algorithm will ignore macrotime intervals that fall within or overlap with the deadtime.'),...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.73 0.93 0.2 0.025]);
%%% Edit box for TCSPC deadtime
h.MI.TCSPC_DeadTime_Edit = uicontrol(...
    'Parent',h.MI.Calib_Panel,...
    'Tag','MI_TCSPC_DeadTime_Edit',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'String','100',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.93 0.93 0.05 0.025]);

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MI.Calib_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','Left',...
    'String','Smoothing:',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.28 0.93 0.1 0.025]);

%%% Sum interphoton time bins
h.MI.Calib_Single_Range = uicontrol(...
    'Parent',h.MI.Calib_Panel,...
    'Tag','MI_Calib_Single_Range',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'String','1',...
    'Callback',{@Update_Display;7},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.38 0.93 0.05 0.025]);
%%% Saves current shift
h.MI.Calib_Save = uicontrol(...
    'Parent',h.MI.Calib_Panel,...
    'Tag','MI_Calib_Save',...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',12,...
    'String','Save Shift',...
    'Callback',@Det_Calib_Save,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.45 0.93 0.12 0.025]);
%%% Clears current shift
h.MI.Calib_Clear = uicontrol(...
    'Parent',h.MI.Calib_Panel,...
    'Tag','MI_Calib_Clear',...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',12,...
    'String','Clear Shift',...
    'Callback',@Det_Calib_Clear,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.59 0.93 0.12 0.025]);
%%% Detector calibration axes
h.MI.Calib_Axes = axes(...
    'Parent',h.MI.Calib_Panel,...
    'Tag','MI_Calib_Axes',...
    'Units','normalized',...
    'NextPlot','add',...
    'UIContextMenu',h.MI.Menu,...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'Position',[0.09 0.4 0.89 0.48],...
    'Box','on');
h.MI.Calib_Axes.XLabel.String='TCSPC channel';
h.MI.Calib_Axes.XLabel.Color=Look.Fore;
h.MI.Calib_Axes.YLabel.String='Counts';
h.MI.Calib_Axes.YLabel.Color=Look.Fore;
h.MI.Calib_Axes.XLim=[1 4096];
% uncorrected MI histogram:
h.Plots.Calib_No=handle(plot([0 1], [0 0],'b'));
% corrected MI histogram:
h.Plots.Calib=handle(plot([0 1], [0 0],'r'));
% ?:
h.Plots.Calib_Cur=handle(plot([0 1], [0 0],'c'));
% selected interphoton time MI histogram:
h.Plots.Calib_Sel=handle(plot([0 1], [0 0],'g'));

%%% Detector calibration shift axes
h.MI.Calib_Axes_Shift = axes(...
    'Parent',h.MI.Calib_Panel,...
    'Tag','MI_Calib_Axes_Shift',...
    'Units','normalized',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'Position',[0.09 0.05 0.89 0.28],...
    'Box','on');
h.MI.Calib_Axes_Shift.XLabel.String='Interphoton time [macrotime ticks]';
h.MI.Calib_Axes_Shift.XLabel.Color=Look.Fore;
h.MI.Calib_Axes_Shift.YLabel.String='Shift [microtime ticks]';
h.MI.Calib_Axes_Shift.YLabel.Color=Look.Fore;
h.MI.Calib_Axes_Shift.XLim=[1 400];
h.Plots.Calib_Shift_New=handle(plot(1:400, zeros(400,1),'r'));
h.Plots.Calib_Shift_Smoothed = handle(plot(1:400, zeros(400,1),'b'));
%% Trace and Image tabs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s.ProgressRatio = 0.75;
%%% Macrotime tabs container
h.MT.Tab = uitabgroup(...
    'Parent',h.Pam,...
    'Tag','MT_Tab',...
    'Units','normalized',...
    'Position',[0.01 0.01 0.485 0.485]);

%% Plot and functions for intensity trace %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Intensity trace tab
h.Trace.Tab= uitab(...
    'Parent',h.MT.Tab,...
    'Tag','Trace_Tab',...
    'Title','Intensity Trace');

%%% Intensity trace panel
h.Trace.Panel = uibuttongroup(...
    'Parent',h.Trace.Tab,...
    'Tag','Trace_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Intensity trace axes
h.Trace.Axes = axes(...
    'Parent',h.Trace.Panel,...
    'Tag','Trace_Axes',...
    'Units','normalized',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
    'Position',[0.075 0.14 0.9 0.83],...
    'Box','off',...
    'TickDir','out');
h.Trace.Axes.XLabel.String='Time [s]';
h.Trace.Axes.XLabel.Color=Look.Fore;
h.Trace.Axes.YLabel.String='Count rate [kHz]';
h.Trace.Axes.YLabel.Color=Look.Fore;
h.Plots.Trace{1}=handle(plot([0 1],[0 0],'b'));

h.Trace.Menu = uicontextmenu;
h.Trace.Log = uimenu(...
    'Parent',h.Trace.Menu,...
    'Label','Plot as log scale',...
    'Checked',UserValues.Settings.Pam.PlotLogTrace,...
    'Callback',@Calculate_Settings);
h.Trace.Trace_Export_Menu = uimenu(...
    'Parent',h.Trace.Menu,...
    'Label','Export',...
    'Separator','on',...
    'Callback',{@Update_Display,2});
h.Trace.Trace_ExportFRETTrace_Menu = uimenu(...
    'Parent',h.Trace.Menu,...
    'Label','Extract FRET efficiency trace',...
    'Separator','on',...
    'Callback',{@Update_Display,2});
h.Trace.Trace_ExportAnisotropyTrace_Menu = uimenu(...
    'Parent',h.Trace.Menu,...
    'Label','Extract Anisotropy trace',...
    'Callback',{@Update_Display,2});
h.Trace.Axes.UIContextMenu = h.Trace.Menu;

if ~UserValues.Settings.Pam.Use_TimeTrace
    h.Trace.Tab.Parent = [];
end
%% Plot and functions for PCH trace %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Intensity trace tab
h.PCH.Tab= uitab(...
    'Parent',h.MT.Tab,...
    'Tag','Trace_Tab',...
    'Title','PCH');

%%% Intensity trace panel
h.PCH.Panel = uibuttongroup(...
    'Parent',h.PCH.Tab,...
    'Tag','PCH_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Intensity trace axes
h.PCH.Axes = axes(...
    'Parent',h.PCH.Panel,...
    'Tag','PCH_Axes',...
    'Units','normalized',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'YScale','log',...
    'LineWidth', Look.AxWidth,...
    'Position',[0.075 0.14 0.9 0.83],...
    'TickDir','out',...
    'Box','off');
h.PCH.Axes.XLabel.String='Counts per ms';
h.PCH.Axes.XLabel.Color=Look.Fore;
h.PCH.Axes.YLabel.String='Frequency';
h.PCH.Axes.YLabel.Color=Look.Fore;
h.Plots.PCH{1}=handle(plot([0 1],[0 0],'b'));

% add context menu
h.PCH.Menu = uicontextmenu;
h.PCH.PCH_2D_Menu = uimenu(...
    'Parent',h.PCH.Menu,...
    'Label','2D PCH',...
    'checked','off',...
    'Callback',{@Update_Display,10});
h.PCH.PCH_Export_Menu = uimenu(...
    'Parent',h.PCH.Menu,...
    'Label','Export to figure',...
    'Callback',{@Update_Display,10});
h.PCH.PCH_Export_CSV_Menu = uimenu(...
    'Parent',h.PCH.Menu,...
    'Label','Export to text file',...
    'Callback',{@Update_Display,10});
h.PCH.Axes.UIContextMenu = h.PCH.Menu;
h.PCH.Panel.UIContextMenu = h.PCH.Menu;
if UserValues.Settings.Pam.PCH_2D
    h.PCH.PCH_2D_Menu.Checked = 'on';
    h.PCH.PCH_Export_CSV_Menu.Visible = 'off';
end
if ~UserValues.Settings.Pam.Use_PCH
    h.PCH.Tab.Parent = [];
end
%% Plot and functions for image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Image tab
h.Image.Tab= uitab(...
    'Parent',h.MT.Tab,...
    'Tag','Image_Tab',...
    'Title','Image');
%%% Image panel
h.Image.Panel = uibuttongroup(...
    'Parent',h.Image.Tab,...
    'Tag','Image_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%% Image axes
h.Image.Axes = axes(...
    'Parent',h.Image.Panel,...
    'Tag','Image_Axes',...
    'Units','normalized',...
    'Position',[0.01 0.01 0.7 0.98],...
    'DataAspectRatio',[1,1,1]);
h.Plots.Image=imagesc(0);
h.Image.Axes.XTick=[]; h.Image.Axes.YTick=[];
h.Image.Colorbar=colorbar(h.Image.Axes);
h.Image.Colorbar.YLabel.String = 'Count rate [kHz]';
h.Image.Colorbar.YLabel.ButtonDownFcn = @Misc;
colormap(jet);
h.Image.Colorbar.Color=Look.Fore;

%%% Popupmenu to switch between intensity and mean arrival time images
h.Image.Type = uicontrol(...
    'Parent',h.Image.Panel,...
    'Tag','Image_Type',...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',{@Update_Display,3},...
    'String',{'Intensity';'Mean arrival time'},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.75 0.92 0.24 0.06]);
if ismac
    h.Image.Type.ForegroundColor = [0 0 0];
    h.Image.Type.BackgroundColor = [1 1 1];
end
%%% Checkbox that determins if autoscale is on
h.Image.Autoscale = uicontrol(...
    'Parent',h.Image.Panel,...
    'Tag','Image_Autoscale',...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',{@Update_Display,3},...
    'String','Use Autoscale',...
    'Value',1,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.75 0.84 0.24 0.06],...
    'Visible','off',...
    'Enable','off');

if ~UserValues.Settings.Pam.Use_Image && ~UserValues.Settings.Pam.Use_Lifetime
    h.Image.Tab.Parent = [];
end
%% Settings for trace and image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setting tab
h.MT.Settings_Tab= uitab(...
    'Parent',h.MT.Tab,...
    'Tag','MT_Settings_Tab',...
    'Title','Settings');
%%% Settings panel
h.MT.Settings_Panel = uibuttongroup(...
    'Parent',h.MT.Settings_Tab,...
    'Tag','MT_Settings_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'String','Bin size for trace [ms]:',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.92 0.34 0.06]);
%%% Mactotime binning
h.MT.Binning = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_Binning',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',@Calculate_Settings,...
    'String','10',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.28 0.92 0.1 0.06]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String', 'Bin size for PCH [ms]:',...
    'Position',[0.6 0.92 0.25 0.08]);
%%% Selects, how many microtime tabs to generate
h.MT.Binning_PCH = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String', '1',...
    'Callback',@Calculate_Settings,...
    'Position',[0.85 0.92 0.05 0.08]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'String','Macrotime sectioning type:',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.82 0.26 0.06]);
%%% Trace sectioning settings
h.MT.Trace_Sectioning = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_Trace_Sectioning',...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',@Calculate_Settings,...
    'String',{'Constant number';'Constant time'},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.28 0.83 0.28 0.06]);
if ismac
    h.MT.Trace_Sectioning.ForegroundColor = [0 0 0];
    h.MT.Trace_Sectioning.BackgroundColor = [1 1 1];
end
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'String','Sectioning time [s]:',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.72 0.26 0.06]);
%%% Time Sectioning
h.MT.Time_Section = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_Time_Section',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',@Calculate_Settings,...
    'String','5',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.28 0.72 0.1 0.06]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'String','Section number:',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.62 0.26 0.06]);
%%% Number Sectioning
h.MT.Number_Section = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_Number_Section',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',@Calculate_Settings,...
    'String','10',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.28 0.62 0.1 0.06]);
%%% Checkbox for chunk-wise TCSPC data read-in
h.MT.Use_Chunkwise_Read_In = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_Use_Chunk-wise read-in',...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',0,...
    'String','Chunkwise TCSPC data read-in',...
    'Callback',@Calculate_Settings,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.52 0.30 0.06]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'String','Images to export:',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.42 0.23 0.06]);
%%% Image exporting settings
h.MT.Image_Export = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_Image_Export',...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'String',{'Both';'Intensity';'Mean arrival time'},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Value',2,...
    'Position',[0.28 0.43 0.28 0.06]);
if ismac
    h.MT.Image_Export.ForegroundColor = [0 0 0];
    h.MT.Image_Export.BackgroundColor = [1 1 1];
end
%%% Scan offset text and fields
h.Text{end+1} = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String', 'Scan offset [us]:',...
    'Position',[0.6 0.4 0.25 0.08]);
h.MT.ScanOffsetStart = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_ScanOffsetStart',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',@Calculate_Settings,...
    'String','0',...
    'TooltipString', sprintf([...
    'Discards a portion of data at start \n'...
    'and end of scan to correct for line sync issues.'...
    '\nSet to 0 to disable.']),...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.8 0.4 0.08 0.08]);
h.MT.ScanOffsetEnd = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_ScanOffsetEnd',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',@Calculate_Settings,...
    'String','0',...
    'TooltipString', sprintf([...
    'Discards a portion of data at start and end\n'...
    'of scan to correct for line sync issues.'...
    '\nSet to 0 to disable.']),...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.9 0.4 0.08 0.08]);
%%% Checkbox to determine if time trace is calculated
h.MT.Use_TimeTrace = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_Use_TimeTrace',...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',UserValues.Settings.Pam.Use_TimeTrace,...
    'String','Calculate Time Trace',...
    'Callback',@Calculate_Settings,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.32 0.26 0.06]);
%%% Checkbox to determine if PCH is calculated
h.MT.Use_PCH = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_Use_PCH',...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',UserValues.Settings.Pam.Use_PCH,...
    'String','Calculate PCH',...
    'Callback',@Calculate_Settings,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.26 0.26 0.06]);
%%% Checkbox to determine if image is calculated
h.MT.Use_Image = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_Use_Image',...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',UserValues.Settings.Pam.Use_Image,...
    'String','Calculate image',...
    'Callback',@Calculate_Settings,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.20 0.26 0.06]);
%%% Checkbox to determine if mean arrival time image is calculated
h.MT.Use_Lifetime = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_Use_Lifetime',...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',UserValues.Settings.Pam.Use_Lifetime,...
    'String','Calculate lifetime image',...
    'Callback',@Calculate_Settings,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.14 0.38 0.06]);
%%% Median Filter lifetime image
h.MT.Lifetime_Median = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT.Lifetime_Median',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',@Calculate_Settings,...
    'String','3',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.22 0.07 0.05 0.06]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'String','smoothing radius:',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Tooltipstring', 'choose the radius of the median filter for smoothing the lifetime images',...
    'Position',[0.03 0.07 0.15 0.06]);

%%% Checkbox to determine if TCSPC channel or microtime is used for
%%% microtime plots
h.MT.ToggleTACTime = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Tag','MT_Use_Lifetime',...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',UserValues.Settings.Pam.ToggleTACTime,...
    'String','Use time in [ns]',...
    'Callback',@Calculate_Settings,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.41 0.14 0.38 0.06]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String', 'Microtime tabs:',...
    'Position',[0.6 0.72 0.25 0.08]);
%%% Selects, how many microtime tabs to generate
h.MI.NTabs = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String', '1',...
    'Callback',{@Update_Detector_Channels, [0,1]},...
    'Position',[0.85 0.72 0.05 0.08]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.MT.Settings_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String', 'Plots per tab:',...
    'Position',[0.6 0.62 0.25 0.08]);
%%% Selects, how many plots per microtime tabs to generate
h.MI.NPlots = uicontrol(...
    'Parent', h.MT.Settings_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String', '1',...
    'Callback',{@Update_Detector_Channels, [0,1]},...
    'Position',[0.85 0.62 0.05 0.08]);
%% Various tabs (PIE Channels, general information, settings etc.) %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Macrotime tabs container
h.Var_Tab = uitabgroup(...
    'Parent',h.Pam,...
    'Tag','Var_Tab',...
    'Units','normalized',...
    'Position',[0.01 0.505 0.485 0.442]);
%% PIE Channels and general information tab
h.PIE.Tab= uitab(...
    'Parent',h.Var_Tab,...
    'Tag','PIE_Tab',...
    'Title','PIE');
%%% PIE Channels and general information panel
h.PIE.Panel = uibuttongroup(...
    'Parent',h.PIE.Tab,...
    'Tag','PIE_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 0.65 1]);
%%% Contexmenu for PIE Channel list
h.PIE.List_Menu = uicontextmenu;
%%% Menu for PIE channel navigation
h.PIE.Channels = uimenu(...
    'Parent',h.PIE.List_Menu,...
    'Label','PIE channel',...
    'Tag','PIE_Channels');
%%% Adds new PIE Channel
h.PIE.Add = uimenu(...
    'Parent',h.PIE.Channels,...
    'Label','Add new PIE channel',...
    'Tag','PIE_Add',...
    'Callback',@PIE_List_Functions);
%%% Deletes selected PIE Channels
h.PIE.Delete = uimenu(...
    'Parent',h.PIE.Channels,...
    'Label','Delete selected channels',...
    'Tag','PIE_Delete',...
    'Callback',@PIE_List_Functions);
%%% Creates Combined Channel
h.PIE.Combine = uimenu(...
    'Parent',h.PIE.Channels,...
    'Label','Create combined channel',...
    'Tag','PIE_Combine',...
    'Callback',@PIE_List_Functions);
%%% Manually select microtime
h.PIE.Select = uimenu(...
    'Parent',h.PIE.Channels,...
    'Label','Manually select microtime',...
    'Tag','PIE_Select',...
    'Callback',@PIE_List_Functions);
%%% Changes Channel Color
h.PIE.Color = uimenu(...
    'Parent',h.PIE.Channels,...
    'Label','Change channel colors',...
    'Tag','PIE_Color',...
    'Callback',@PIE_List_Functions);
%%% Export main
h.PIE.Export = uimenu(...
    'Parent',h.PIE.List_Menu,...
    'Label','Export...',...
    'Tag','PIE_Export');
%%% Exports MI and MT as one vector each
h.PIE.Export_Raw_Total = uimenu(...
    'Parent',h.PIE.Export,...
    'Label','...Raw data (total)',...
    'Tag','PIE_Export_Raw_Total',...
    'Callback',@PIE_List_Functions);
%%% Exports MI and MT for each file
h.PIE.Export_Raw_File = uimenu(...
    'Parent',h.PIE.Export,...
    'Label','...Raw data (per file)',...
    'Tag','PIE_Export_Raw_File',...
    'Callback',@PIE_List_Functions);
%%% Exports and plots and image of the PIE channel
h.PIE.Export_Image_Total = uimenu(...
    'Parent',h.PIE.Export,...
    'Label','...image (total)',...
    'Tag','PIE_Export_Image_Total',...
    'Callback',@PIE_List_Functions);
%%% Exports all frames of the PIE channel
h.PIE.Export_Image_File = uimenu(...
    'Parent',h.PIE.Export,...
    'Label','...image (per frame)',...
    'Tag','PIE_Export_Image_File',...
    'Callback',@PIE_List_Functions);
h.PIE.Export_Image_Tiff = uimenu(...
    'Parent',h.PIE.Export,...
    'Label','...image (as .tiff)',...
    'Tag','PIE_Export_Image_Tiff',...
    'Callback',@PIE_List_Functions);
h.PIE.Export_MicrotimePattern = uimenu(...
    'Parent',h.PIE.Export,...
    'Label','...microtime pattern (as .dec)',...
    'Tag','PIE_Export_MicrotimePattern',...
    'Callback',@PIE_List_Functions);
%%% Saves the current Measurement as IRF for the Channel
h.PIE.IRF = uimenu(...
    'Parent',h.PIE.List_Menu,...
    'Label','Save IRF for selected PIE Channel',...
    'Tag','PIE_IRF',...
    'Callback',@SaveLoadIrfScat);
%%% Saves the current Measurement as Phasor reference for the Channel
h.PIE.PhasorReference = uimenu(...
    'Parent',h.PIE.List_Menu,...
    'Label','Save Phasor Reference for selected PIE Channel',...
    'Tag','PIE_Phasor_Ref',...
    'Callback',@SaveLoadIrfScat);
%%% Saves the current Measurement as Donor-only reference for the Channel
h.PIE.DonorOnlyReference = uimenu(...
    'Parent',h.PIE.List_Menu,...
    'Label','Save Donor-only Reference for selected PIE Channel',...
    'Tag','PIE_DonorOnly_Ref',...
    'Callback',@SaveLoadIrfScat);
%%% PIE Channel list
h.PIE.List = uicontrol(...
    'Parent',h.PIE.Panel,...
    'Tag','PIE_List',...
    'Style','listbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Max',2,...
    'String',UserValues.PIE.Name,...
    'TooltipString',sprintf([...
    'List of currently selected PIE Channels: \n'...
    '"+" adds channel; \n "-" or del deletes channel; \n'...
    '"leftarrow" moves channel up; \n'...
    '"rightarrow" moves channel down \n'...
    'Rightclick to open contextmenu with additional functions;']),...
    'UIContextMenu',h.PIE.List_Menu,...
    'Callback',{@Update_Display,[1:5,10]},...
    'KeyPressFcn',@PIE_List_Functions,...
    'BackgroundColor', Look.List,...
    'ForegroundColor', Look.ListFore,...
    'Position',[0.01 0.01 0.4 0.98]);

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.PIE.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'String','PIE channel name:',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.425 0.9 0.3 0.08]);

%%% Editbox for PIE channel name
h.PIE.Name = uicontrol(...
    'Parent',h.PIE.Panel,...
    'Tag','PIE_Name',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',@Update_PIE_Channels,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.74 0.9 0.24 0.08]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.PIE.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'String','Detection channel:',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.425 0.8 0.565 0.08]);
%%% Editbox for PIE channel detector
%     h.PIE.Detector = uicontrol(...
%         'Parent',h.PIE.Panel,...
%         'Tag','PIE_Detector',...
%         'Style','edit',...
%         'Units','normalized',...
%         'FontSize',12,...
%         'Callback',@Update_PIE_Channels,...
%         'BackgroundColor', Look.Control,...
%         'ForegroundColor', Look.Fore,...
%         'Position',[0.54 0.8 0.08 0.08]);
%%% Text
%     h.Text{end+1} = uicontrol(...
%         'Parent',h.PIE.Panel,...
%         'Style','text',...
%         'Units','normalized',...
%         'FontSize',12,...
%         'HorizontalAlignment','left',...
%         'String','Routing:',...
%         'BackgroundColor', Look.Back,...
%         'ForegroundColor', Look.Fore,...
%         'Position',[0.63 0.8 0.11 0.08]);
%%% Editbox for PIE channel routing
%     h.PIE.Routing = uicontrol(...
%         'Parent',h.PIE.Panel,...
%         'Tag','PIE_Routing',...
%         'Style','edit',...
%         'Units','normalized',...
%         'FontSize',12,...
%         'Callback',@Update_PIE_Channels,...
%         'BackgroundColor', Look.Control,...
%         'ForegroundColor', Look.Fore,...
%         'Position',[0.745 0.8 0.08 0.08]);
h.PIE.DetectionChannel = uicontrol(...
    'Parent',h.PIE.Panel,...
    'Tag','PIE_Routing',...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',@Update_PIE_Channels,...
    'BackgroundColor',[1 1 1],...
    'ForegroundColor', [0 0 0],...
    'Position',[0.415 0.72 0.585 0.08],...
    'String',color_string(UserValues.Detector.Name,UserValues.Detector.Color));
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.PIE.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'String','From:',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.425 0.6 0.11 0.08]);
%%% Editbox for microtime minimum of PIE channel
h.PIE.From = uicontrol(...
    'Parent',h.PIE.Panel,...
    'Tag','PIE_From',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',@Update_PIE_Channels,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.54 0.6 0.12 0.08]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.PIE.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'String','To:',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.71 0.6 0.12 0.08]);
%%% Editbox for mictotime maximum of PIE channel
h.PIE.To = uicontrol(...
    'Parent',h.PIE.Panel,...
    'Tag','PIE_To',...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',@Update_PIE_Channels,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.83 0.6 0.12 0.08]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.PIE.Panel,...
    'Tag','PIE_Info',...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'String',{'Total photons:';'Channel photons:'; 'Total count rate:'; 'Channel count rate:';'Channel background:'},...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.425 0 0.3 0.58]);
%%% Textfield for photon number and countrate
h.PIE.Info = uicontrol(...
    'Parent',h.PIE.Panel,...
    'Tag','PIE_Info',...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'String',{'Total photons:';'Channel photons:'; 'Total count rate:'; 'Channel count rate:';'Channel background:'},...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.76 0 0.24 0.58]);
%%% General file information table
ColumnNames = {'',''};
RowNames = [];
ToolTipStr = '';
ColumnFormat = {'char','char'};
DefaultData = {'<html><b>Duration [s]','';...
    '<html><b>Macrotime clock [ns]','';...
    '<html><b>Repetition rate [MHz]','';...
    '<html><b>TAC range [ns]','';...
    '<html><b># Microtime bins','';...
    '<html><b>TCSPC resolution [ps]','';...
    '<html><b>Number of Files','';...
    '<html><b>Recording date',''};
h.PIE.FileInfoTable = uitable(...
    'Parent',h.PIE.Tab,...
    'Units','normalized',...
    'Position',[0.65 0.0 0.35 1],...
    'Data',DefaultData,...
    'CellEditCallback',[],...
    'ColumnName',ColumnNames,...
    'RowName',RowNames,...
    'TooltipString',ToolTipStr,...
    'ColumnFormat',ColumnFormat,...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{'auto','auto'}...
    );
h.PIE.FileInfoTable.Units = 'pixels';
wid = h.PIE.FileInfoTable.Position(3);
h.PIE.FileInfoTable.Units = 'norm';
name_wid = 150;
h.PIE.FileInfoTable.ColumnWidth = {name_wid,wid-name_wid-5};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Database tab
h.Database.Tab= uitab(...
    'Parent',h.Var_Tab,...
    'Tag','Database_Tab',...
    'Title','Recent');
%%% Database panel
h.Database.Panel = uibuttongroup(...
    'Parent',h.Database.Tab,...
    'Tag','Database_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);    
%%% Database list
% generate string
dbstring = cell(size(UserValues.File.FileHistory.PAM,1),1);
for i = 1:size(UserValues.File.FileHistory.PAM,1)
    dbstring{i} = [UserValues.File.FileHistory.PAM{i,1} ' (path:' UserValues.File.FileHistory.PAM{i,2} ')'];
end
h.Database.List = uicontrol(...
    'Parent',h.Database.Panel,...
    'Tag','Database_List',...
    'Style','listbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Max',2,...
    'String',dbstring,...
    'BackgroundColor', Look.List,...
    'ForegroundColor', Look.ListFore,...
    'KeyPressFcn',{@Database,0},...
    'Callback',{@Database,0},...
    'Tooltipstring', ['<html>'...
    'List of recently loaded files<br>',...
    '<i>"return"</i>: Loads selected files<br>',...
    '<I>"delete"</i>: Removes selected files from list</b>'],...
    'Position',[0.01 0.01 0.98 0.98],...
    'UserData',[]); % UserData stores the selection order
%% Export tab
s.ProgressRatio = 0.9;
h.Export.Tab= uitab(...
    'Parent',h.Var_Tab,...
    'Tag','Export_Tab',...
    'Title','Database');
%%% Database panel
h.Export.Panel = uibuttongroup(...
    'Parent',h.Export.Tab,...
    'Tag','Export_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Database list
% generate string
dbstring = cell(size(UserValues.File.FileHistory.PAM_Export,1),1);
for i = 1:size(UserValues.File.FileHistory.PAM_Export,1)
    if numel(UserValues.File.FileHistory.PAM_Export{i,1}) == 1 % single file
        dbstring{i} = [UserValues.File.FileHistory.PAM_Export{i,1}{1} ' (path:' UserValues.File.FileHistory.PAM_Export{i,2} ')'];
    else % multipe files
        dbstring{i} = [num2str(numel(UserValues.File.FileHistory.PAM_Export{i,1})) ' Files: ' UserValues.File.FileHistory.PAM_Export{i,1}{1} ' (path:' UserValues.File.FileHistory.PAM_Export{i,2} ')'];
    end
end
h.Export.List = uicontrol(...
    'Parent',h.Export.Panel,...
    'Tag','Export_List',...
    'Style','listbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Max',2,...
    'String',dbstring,...
    'BackgroundColor', Look.List,...
    'ForegroundColor', Look.ListFore,...
    'KeyPressFcn',{@Export_Database,0},...
    'Callback',{@Export_Database,0},...
    'Tooltipstring', ['<html>'...
    'List of file groups in export database <br>'],...
    'Position',[0.01 0.01 0.68 0.98],...
    'UserData',[]); % UserData stores the selection order
%%% Table containig the PIE channels to export
h.Export.PIE = uitable(...
    'Parent',h.Export.Panel,...
    'Tag','Export_PIE',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', [Look.Table1;Look.Table2],...
    'ForegroundColor', Look.TableFore,...
    'RowName',[UserValues.PIE.Name,{'All'}],...
    'ColumnFormat',{'logical'},...
    'ColumnWidth',{15},...
    'ColumnEditable',true,...
    'Data',false(numel(UserValues.PIE.Name)+1,1),...
    'Position',[0.69 0.61 0.30 0.38]);
%%% Changes the size of the ROW names
drawnow
Export_PIE = findjobj(h.Export.PIE);
if ~isempty(Export_PIE)
    try
        Names = Export_PIE.getComponent(4);
    catch
        Names = Export_PIE.getComponent(0);
    end
    Names.setPreferredSize(java.awt.Dimension(175,100));
    Names = Names.getComponent(0);
    Names.setSize(175,100);
end

h.Export.Text = {};
h.Export.Text{end+1} = uicontrol(...
    'Parent',h.Export.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'String','Manage export:',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.70 0.52 0.29 0.07]);
h.Export.Load = uicontrol(...
    'Parent',h.Export.Panel,...
    'Tag','Export_Load_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Load DB',...
    'Callback',{@Export_Database,3},...
    'Position',[0.70 0.44 0.14 0.07],...
    'Tooltipstring', 'Load export database from file');
%%% Button to save the database
h.Export.Save = uicontrol(...
    'Parent',h.Export.Panel,...
    'Tag','Export_Save_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Save DB',...
    'Callback',{@Export_Database,4},...
    'Position',[0.85 0.44 0.14 0.07],...
    'enable', 'off',...
    'Tooltipstring', 'Save exportdatabase to a file');
%%% Button to export the database as tiff
h.Export.TIFF = uicontrol(...
    'Parent',h.Export.Panel,...
    'Tag','Export_TIFF_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Export TIFFs',...
    'Callback',{@Export_Database,5},...
    'Position',[0.70 0.34 0.19 0.07],...
    'enable', 'off',...
    'UserData',0,...
    'Tooltipstring', 'Exports selected files as TIFF!');
%%% Sets Z-Stack properties
h.Export.Z_Pos = uicontrol(...
    'Parent',h.Export.Panel,...
    'Tag','Export_TIFF_Z_Pos',...
    'Units','normalized',...
    'FontSize',12,...
    'Style','edit',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','1',...
    'Position',[0.90 0.34 0.04 0.07],...
    'Tooltipstring', ['<html>',...
    'Number of different TIFFs to create,<br>',...
    'e.g for different Z-Positions']);
h.Export.Z_Frames = uicontrol(...
    'Parent',h.Export.Panel,...
    'Tag','Export_TIFF_Z_Frames',...
    'Units','normalized',...
    'FontSize',12,...
    'Style','edit',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','1',...
    'Position',[0.95 0.34 0.04 0.07],...
    'Tooltipstring', ['<html>',...
    'Number of consecutive frames per slice,<br>',...
    'e.g 3 frames for each different Z-Position']);
%%% Button to Save Microtime Patterns
h.Export.MicrotimePattern = uicontrol(...
    'Parent',h.Export.Panel,...
    'Tag','Export_MicrotimePattern_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Export Microtime Histogram',...
    'Callback',{@Export_Database,6},...
    'Position',[0.70 0.26 0.29 0.07],...
    'enable', 'off',...
    'UserData',0,...
    'Tooltipstring', 'Export microtime pattern of selected PIE channels',...
    'Visible','on');

%%% Button to correlate files in the database
h.Export.Correlate = uicontrol(...
    'Parent',h.Export.Panel,...
    'Tag','Export_Correlate_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Correlate',...
    'Callback',{@Export_Database,7},...
    'Position',[0.70 0.18 0.29 0.07],...
    'enable', 'off',...
    'UserData',0,...
    'Tooltipstring', 'Make sure "Correlate" tab settings are correct!');
%%% Button to perform Burst analysis on the database
h.Export.Burst = uicontrol(...
    'Parent',h.Export.Panel,...
    'Tag','Export_Burst_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Burst analysis',...
    'Callback',{@Export_Database,8},...
    'Position',[0.70 0.10 0.29 0.07],...
    'enable', 'off',...
    'UserData',0,...
    'Tooltipstring', 'Make sure "Burst analysis" tab settings are correct');
%% Profiles tab
h.Profiles.Tab= uitab(...
    'Parent',h.Var_Tab,...
    'Tag','Profiles_Tab',...
    'Title','Profiles');
%%% Profiles panel
h.Profiles.Panel = uibuttongroup(...
    'Parent',h.Profiles.Tab,...
    'Tag','Profiles_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%% Contexmenu for Profiles list
h.Profiles.Menu = uicontextmenu;
%%% Selects profile
h.Profiles.Select = uimenu(...
    'Parent',h.Profiles.Menu,...
    'Label','Select profile',...
    'Tag','Profiles_Delete',...
    'Callback',@Update_Profiles);
%%% Deletes selected profile
h.Profiles.Duplicate = uimenu(...
    'Parent',h.Profiles.Menu,...
    'Label','Duplicate selected profile',...
    'Tag','Profiles_Duplicate',...
    'Separator','on',...
    'Callback',@Update_Profiles);
%%% Adds new Profile
h.Profiles.Add = uimenu(...
    'Parent',h.Profiles.Menu,...
    'Label','Add empty profile',...
    'Tag','Profiles_Add',...
    'Callback',@Update_Profiles);
%%% Deletes selected profile
h.Profiles.Delete = uimenu(...
    'Parent',h.Profiles.Menu,...
    'Label','Delete selected profile',...
    'Tag','Profiles_Delete',...
    'Callback',@Update_Profiles);
%%% Export profile to disk
h.Profiles.Export = uimenu(...
    'Parent',h.Profiles.Menu,...
    'Label','Export selected profile',...
    'Separator','on',...
    'Tag','Profiles_Export',...
    'Callback',@Update_Profiles);
%%% Load profile from disk
h.Profiles.Load = uimenu(...
    'Parent',h.Profiles.Menu,...
    'Label','Load profile from file',...
    'Tag','Profiles_Load',...
    'Callback',@Update_Profiles);
%%% Profiles list
h.Profiles.List = uicontrol(...
    'Parent',h.Profiles.Panel,...
    'Tag','Profiles_List',...
    'Style','listbox',...
    'Units','normalized',...
    'FontSize',12,...
    'String',Profiles,...
    'Uicontextmenu',h.Profiles.Menu,...
    'TooltipString',sprintf([...
    'List of available profiles: \n'...
    '"+" adds profile; \n'...
    '"-" or "del" deletes channel; \n'...
    '"return" changes current profile; \n'...
    'TSCPCData will not be updated; \n'...
    'To update all settings, a restart of Pam migth be required']),...
    'KeyPressFcn',@Update_Profiles,...
    'BackgroundColor', Look.List,...
    'ForegroundColor', Look.ListFore,...
    'Position',[0.01 0.51 0.3 0.48]);

%%% Contexmenu for MI Channels List
h.MI.Channels_Menu = uicontextmenu;
%%% Menu to add MI channels
h.MI.Add = uimenu(...
    'Parent',h.MI.Channels_Menu,...
    'Label','Add new microtime channel',...
    'Tag','MI_Add',...
    'Callback',@MI_Channels_Functions);
%%% Automatically detect used Detector and Routing numbers on load
h.MI.Auto = uimenu(...
    'Parent',h.MI.Channels_Menu,...
    'Label','Auto-detect used detectors and routing',...
    'Tag','MI_Auto',...
    'Separator','on',...
    'Checked',UserValues.Detector.Auto,...
    'Callback',@MI_Channels_Functions);
%%% Menu to delete MI channels
%     h.MI.Delete = uimenu(...
%         'Parent',h.MI.Channels_Menu,...
%         'Label','Delete selected microtime channels',...
%         'Tag','MI_Delete',...
%         'Callback',@MI_Channels_Functions);
%%% Menu to rename MI channels
%     h.MI.Name = uimenu(...
%         'Parent',h.MI.Channels_Menu,...
%         'Label','Rename microtime channels',...
%         'Tag','MI_Rename',...
%         'Callback',@MI_Channels_Functions);
%
%     %%% Menu to change MI channel color
%     h.MI.Color = uimenu(...
%         'Parent',h.MI.Channels_Menu,...
%         'Label','Change microtime channel color',...
%         'Tag','MI_Color',...
%         'Callback',@MI_Channels_Functions);
%%% List of detector/routing pairs to use
%     h.MI.Channels_List = uicontrol(...
%         'Parent',h.Profiles.Panel,...
%         'Tag','MI_Channels_List',...
%         'Style','listbox',...
%         'Units','normalized',...
%         'FontSize',12,...
%         'Max',2,...
%         'TooltipString',sprintf('List of detector/routing pairs to be loaded/displayed \n disabled denotes pairs that will be loaded but not displayed'),...
%         'Uicontextmenu',h.MI.Channels_Menu,...
%         'KeyPressFcn',@MI_Channels_Functions,...
%         'BackgroundColor', Look.List,...
%         'ForegroundColor', Look.ListFore,...
%         'Position',[0.01 0.01 0.49 0.48]);
%%% Following is alternate implementation using a table instead of a
%%% list
if ispc
    trash_image = ['<html><img src="file:/' PathToApp '/images/trash16p.png"/></html>'];
    trash_image = strrep(trash_image,'\','/');
else
    trash_image = ['<html><img src="file://' PathToApp '/images/trash16p.png"/></html>'];
end
TableData = {'Detector',1,1,'[1 0 0]','500/25','none','none','on',0};
ColumnNames = {'<html><font size=4><b>Name</b></font></html>','<html><font size=4><b>Det#</b></font></html>','<html><font size=4><b>Rout#</b></font></html>','<html><font size=4><b>Color</b></font></html>','<html><font size=4><b>Filter</b></font></html>','<html><font size=4><b>Pol</b></font></html>','<html><font size=4><b>BS</b></font></html>','<html><font size=4><b>Enabled</b></font></html>',trash_image};
ColumnEditable = [true,true,true,false,true,true,true,true,true];
ColumnFormat = {'char','numeric','numeric','char','char',{'none','Par','Per'},{'none','50:50'},{'on','off'},'logical'};
RowNames = [];

h.MI.Channels_List = uitable(...
    'Parent',h.Profiles.Panel,...
    'Tag','MI_Channels_List',...
    'Units','normalized',...
    'FontSize',12,...
    'TooltipString',sprintf('List of detection channels defined as detector/routing pairs to be loaded/displayed.\nDisabled denotes pairs that will be loaded but not displayed.\nDet#:\tDetector number\nRout#:\tRouting number\nColor:\t Display color\nFilter:\t Emission filter in the format "center wavelenght/range"\nPol:\t polarization\nBS:\tUse of 50:50 beam splitter'),...
    'Uicontextmenu',h.MI.Channels_Menu,...
    'CellEditCallback',@MI_Channels_Functions,...
    'CellSelectionCallback',@MI_Channels_Functions,...
    'Position',[0.01 0.01 0.98 0.48],...
    'Data',TableData,...
    'ColumnName',ColumnNames,...
    'RowName',RowNames,...
    'ColumnEditable',ColumnEditable,...
    'ColumnFormat',ColumnFormat,...
    'ColumnWidth',{200,50,50,50,75,75,75,60,20});
%%% adjust column width
h.MI.Channels_List.Units = 'pixels';
h.MI.Channels_List.ColumnWidth{1} = h.MI.Channels_List.Position(3) - sum(cell2mat(h.MI.Channels_List.ColumnWidth(2:end))) - 35;
h.MI.Channels_List.Units = 'normalized';
%%% Table to store additional meta data
ColumnNames = {'',''};
RowNames = [];
ToolTipStr = 'For multiple entries, please provide a comma-separated list.';
ColumnFormat = {'char','char','char','char','char'};
DefaultData = {'<html><b>Excitation Wavelenghts [nm]','532, 647';...
    '<html><b>Excitation Power [&mu;W]','100, 100';...
    '<html><b>Dye Names','Atto532, Atto647N';...
    '<html><b>Buffer Name','Sample Buffer';...
    '<html><b>Sample Name','Test Sample';...
    '<html><b>User','User';...
    '<html><b>Comment',''};
h.Profiles.MetaDataTable = uitable(...
    'Parent',h.Profiles.Panel,...
    'Units','normalized',...
    'Position',[0.54 0.5 0.45 0.49],...
    'Data',DefaultData,...
    'CellEditCallback',@Update_MetaData,...
    'ColumnName',ColumnNames,...
    'RowName',RowNames,...
    'TooltipString',ToolTipStr,...
    'ColumnFormat',ColumnFormat,...
    'ColumnEditable',[false,true],...
    'ColumnWidth',{'auto','auto'}...
    );
h.Profiles.MetaDataTable.Units = 'pixels';
wid = h.Profiles.MetaDataTable.Position(3);
h.Profiles.MetaDataTable.Units = 'norm';
name_wid = min([200,floor(0.5*wid)]);
h.Profiles.MetaDataTable.ColumnWidth = {name_wid,wid-name_wid-15};
%%% Button for export of meta data to txt file in the folder of the
%%% current file
h.Profiles.MetaDataExport_Button = uicontrol(...
    'Parent',h.Profiles.Panel,...
    'Tag','MetaDataExport_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Save metadata',...
    'Callback',@Save_MetaData,...
    'Position',[0.32 0.51 0.21 0.07],...
    'Tooltipstring', 'Saves Metadata to text file');

%%% Contexmenu for Save Profile button
h.Profiles.SaveProfile_Menu = uicontextmenu;
%%% Menu for automatically saving the profile in the folder of the
%%% currently opened TCSPC file
h.Profiles.SaveProfile_Auto = uimenu(...
    'Parent',h.Profiles.SaveProfile_Menu,...
    'Label','Automatically save the profile',...
    'Tag','Profiles.SaveProfile_Auto',...
    'Checked',UserValues.Settings.Pam.AutoSaveProfile,...
    'Callback',@SaveLoadProfile);
%%% Button for Saving the current profile in the folder of the
%%% currently opened TCSPC file
h.Profiles.SaveProfile_Button = uicontrol(...
    'Parent',h.Profiles.Panel,...
    'Tag','SaveProfile_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Backup profile',...
    'UIContextMenu',h.Profiles.SaveProfile_Menu,...
    'Callback',@SaveLoadProfile,...
    'Position',[0.32 0.92 0.21 0.07],...
    'Tooltipstring', 'Copies the current profile as "TCSPC filename".pro in the folder of the current TCSPC file');
%%% Button for Loading the profile from the folder of the
%%% currently opened TCSPC file
h.Profiles.LoadProfile_Button = uicontrol(...
    'Parent',h.Profiles.Panel,...
    'Tag','LoadProfile_Button',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Restore profile',...
    'Callback',@SaveLoadProfile,...
    'Position',[0.32 0.84 0.21 0.07],...
    'Tooltipstring', 'Copies "TCSPC filename".pro Pam profile to the profiles folder and selects it as the current profile');

%%% Allows default Filetype selection
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Profiles.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String', 'Default file type:',...
    'Position',[0.32 0.79 0.21 0.05]);
%%% Default filetype selection
h.Profiles.DefaultFiletype = uicontrol(...
    'Parent',h.Profiles.Panel,...
    'Style', 'popupmenu',...
    'Tag','Custom_Filetype',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', [1 1 1],...
    'ForegroundColor', [0 0 0],...
    'String',UserValues.File.SPC_FileTypes(:,2),...
    'Value',UserValues.File.OpenTCSPC_FilterIndex,...
    'Callback',@(src,event) LSUserValues(1,src,{'UserValues.File.OpenTCSPC_FilterIndex=Obj.Value;'}),...
    'Position',[0.32 0.725 0.21 0.06],...
    'Tooltipstring','Select a custom read-in option');

%%% Allows custom Filetype selection
if ~isdeployed
    Customdir = [PathToApp filesep 'functions' filesep 'Custom_Read_Ins'];
    if ~(exist(Customdir,'dir') == 7)
        mkdir(Customdir);
    end
    %%% Finds all matlab files in profiles directory
    Custom_Methods = what(Customdir);
    Custom_Methods = ['none'; Custom_Methods.m(:)];
    Custom_Value = 1;
    for i=2:numel(Custom_Methods)
        Custom_Methods{i}=Custom_Methods{i}(1:end-2);
        if strcmp(Custom_Methods{i},UserValues.File.Custom_Filetype)
            Custom_Value = i;
        end
    end
else
    %%% compiled application
    %%% custom file types are embedded
    %%% names are in associated text file
    fid = fopen([PathToApp filesep 'functions' filesep 'Custom_Read_Ins' filesep 'Custom_Read_Ins.txt'],'rt');
    if fid == -1
        disp('No Custom Read-In routines defined. Missing file Custom_Read_Ins.txt');
        Custom_Methods = {'none'};
        Custom_Value = 1;
    else % read file
        % skip the first three lines (header)
        for i = 1:3
            tline = fgetl(fid);
        end
        Custom_Methods = {'none'};
        Custom_Value = 1;
        while ischar(tline)
            tline = fgetl(fid);
            if ischar(tline)
                Custom_Methods{end+1,1} = tline;
            end
        end
        for i=2:numel(Custom_Methods)
            if strcmp(Custom_Methods{i},UserValues.File.Custom_Filetype)
                Custom_Value = i;
            end
        end
    end
end
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Profiles.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String', 'Custom file types:',...
    'Position',[0.32 0.67 0.21 0.05]);
%%% Custom filetype selection
h.Profiles.Filetype = uicontrol(...
    'Parent',h.Profiles.Panel,...
    'Style', 'popupmenu',...
    'Tag','Custom_Filetype',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', [1 1 1],...
    'ForegroundColor', [0 0 0],...
    'String', Custom_Methods,...
    'Value',Custom_Value,...
    'Callback',@(src,event) LSUserValues(1,src,{'UserValues.File.Custom_Filetype=Obj.String{Obj.Value};'}),...
    'Position',[0.32 0.60 0.21 0.06],...
    'Tooltipstring','Select a custom read-in option');
%% Mac upscaling of Font Sizes
if ismac
    scale_factor = 1.25;
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
    
    %%% loop through h.Text structure containing only static text boxes
    for i = 1:numel(h.Text)
        if isprop(h.Text{i},'FontSize')
            h.Text{i}.FontSize = (h.Text{i}.FontSize)*scale_factor;
        end
    end
end


%% Global variable initialization  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FileInfo=[];
FileInfo.MI_Bins=4096;
FileInfo.NumberOfFiles=1;
FileInfo.Type=1;
FileInfo.MeasurementTime=1;
FileInfo.SyncPeriod=1; %The laser sync period
FileInfo.ClockPeriod=1; %The macrotime clock period (not the same as sync period for SPC-630 cards or for non-sync MT clock)
FileInfo.Lines=1;
FileInfo.Pixels=1;
FileInfo.FileName={'Nothing loaded'};
FileInfo.TACRange = 40E-9;

PamMeta=[];
PamMeta.MI_Hist=repmat({zeros(4096,1)},numel(UserValues.Detector.Name),1);
PamMeta.Trace=repmat({0:0.01:FileInfo.MeasurementTime},numel(UserValues.PIE.Name),1);
PamMeta.Image=repmat({0},numel(UserValues.PIE.Name),1);
PamMeta.Lifetime=repmat({0},numel(UserValues.PIE.Name),1);
PamMeta.TimeBins=0:0.01:FileInfo.MeasurementTime;
PamMeta.BinsPCH = repmat({0:1:10},numel(UserValues.PIE.Name),1);
PamMeta.PCH = repmat({zeros(1,numel(0:1:10))},numel(UserValues.PIE.Name),1);
PamMeta.TracePCH = repmat({zeros(1,numel(0:1:10))},numel(UserValues.PIE.Name),1);
PamMeta.Info=repmat({zeros(4,1)},numel(UserValues.PIE.Name),1);
PamMeta.MI_Tabs=[];
PamMeta.Det_Calib=[];
PamMeta.Burst.Preview = [];
PamMeta.Database = UserValues.File.FileHistory.PAM;
PamMeta.BurstData = [];
%%% read previous database from UserValues into PamMeta structure
if isempty(UserValues.File.FileHistory.PAM_Export)
    %create export database
    PamMeta.Export = cell(0,3);
else
    PamMeta.Export = UserValues.File.FileHistory.PAM_Export;
end

TcspcData=[];
TcspcData.MI=cell(1);
TcspcData.MT=cell(1);

guidata(h.Pam,h);
%% Initializes to UserValues
Update_to_UserValues;
%%% Initializes Profiles List
Update_Profiles([],[])
%%% Initializes detector/routing list
Update_Detector_Channels([],[],[1,2]);
%%% Initializes plots
Update_Data([],[],0,0);
Update_Display([],[],0);
%%% Initializes fFCS GUI
Update_fFCS_GUI([],[]);

delete(s);
h.Pam.Visible='on';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Updates Pam Meta Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Data(~,~,Detector,PIE,mode)
global TcspcData FileInfo UserValues PamMeta
h = guidata(findobj('Tag','Pam'));
if nargin < 5
    %mode = [0,1,2,3];
    mode = 0;
    %%% check what plots are selected and calculate associated meta data
    if UserValues.Settings.Pam.Use_TimeTrace == 1
        mode = [mode, 1];
    end
    if UserValues.Settings.Pam.Use_PCH == 1
        mode = [mode, 2];
    end
    if UserValues.Settings.Pam.Use_Image == 1
            mode = [mode, 3];
    end
end

%%% mode determines what part of the metadata is to be calculated
%%% 0 is microtime histograms
%%% 1 is time trace
%%% 2 is PCH
%%% 3 is image
if any(mode==3)
    % if it's not imaging data, don't calculate the image
    if FileInfo.Lines < 2 || FileInfo.Pixels < 2
        mode(mode == 3) = [];
    end
end
h.Progress.Text.String = 'Updating meta data';
h.Progress.Axes.Color=[1 0 0];
drawnow;

if PIE==0
    PIE = find(UserValues.PIE.Detector>0);
    if any(mode == 3)
        PamMeta.Image=cell(numel(UserValues.PIE.Name),1);
    elseif any(mode == 1)
        PamMeta.Trace=cell(numel(UserValues.PIE.Name),1);
    elseif any(mode == 2)
        PamMeta.PCH=cell(numel(UserValues.PIE.Name),1);
    end
end

%% Creates a microtime histogram for each detector/routing pair
if any(mode == 0)
    if Detector==0
        Detector = 1:numel(UserValues.Detector.Name);
        PamMeta.MI_Hist=cell(numel(UserValues.Detector.Name),1);
    end
    if ~isempty(Detector)
        for i=Detector
            %%% Checks, if the appropriate channel is loaded
            if all(size(TcspcData.MI)>=[UserValues.Detector.Det(i),UserValues.Detector.Rout(i)]) && ~isempty(TcspcData.MI{UserValues.Detector.Det(i),UserValues.Detector.Rout(i)})
                PamMeta.MI_Hist{i}=histc(TcspcData.MI{UserValues.Detector.Det(i),UserValues.Detector.Rout(i)},1:FileInfo.MI_Bins);
            else
                PamMeta.MI_Hist{i}=zeros(FileInfo.MI_Bins,1);
            end
        end
    end
end

%% Creates trace and image plots
if any(mode == 0) || any(mode == 1) || any(mode == 2) || any(mode == 3)
    %%% Creates macrotime bins for traces
    PamMeta.TimeBins=0:str2double(h.MT.Binning.String)/1000:FileInfo.MeasurementTime;
    %%% Creates a intensity trace, PCH and image for each non-combined PIE channel
    if ~isempty(PIE)
        for i=PIE
            Det=UserValues.PIE.Detector(i);
            Rout=UserValues.PIE.Router(i);
            From=UserValues.PIE.From(i);
            To=UserValues.PIE.To(i);
            %%% Checks, if selected detector/routing pair exists/is not empty
            if all(~isempty([Det,Rout])) && all([Det Rout] <= size(TcspcData.MI)) && ~isempty(TcspcData.MT{Det,Rout})
                %% Calculates trace
                %%% Takes PIE channel macrotimes
                PIE_MT=TcspcData.MT{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To)*FileInfo.ClockPeriod;
                if mode == 1 % reset trace
                    PamMeta.Trace{i} = zeros(numel(PamMeta.TimeBins),1);
                elseif mode == 2 % reset PCH
                    PamMeta.BinsPCH{i} = 0:1:10;
                    PamMeta.PCH{i} = zeros(1,numel(PamMeta.BinsPCH{i}));
                    PamMeta.TracePCH{i} = zeros(numel(0:(UserValues.Settings.Pam.PCH_Binning/1000):FileInfo.MeasurementTime),1);
                end
                if any(mode == 1) || any(mode == 2)
                    if any(mode==1)
                        if h.MT.Use_TimeTrace.Value
                            %%% Calculate intensity trace for PIE channel
                            if ~isempty(PIE_MT)
                                PamMeta.Trace{i}=histc(PIE_MT,PamMeta.TimeBins)./str2double(h.MT.Binning.String);
                            end
                        end
                    end
                    if any(mode==2)
                        %%% Calculate PCH for PIE channel
                        if h.MT.Use_PCH.Value
                            TimeBinsPCH=0:(UserValues.Settings.Pam.PCH_Binning/1000):FileInfo.MeasurementTime;
                            if ~isempty(PIE_MT)
                                PamMeta.TracePCH{i} = histc(PIE_MT,TimeBinsPCH);
                                PamMeta.BinsPCH{i} = 0:1:max(PamMeta.TracePCH{i});
                                PamMeta.PCH{i}=histc(PamMeta.TracePCH{i},PamMeta.BinsPCH{i}); 
                            end
                        end
                    end
                end
                %% Calculates image
                PamMeta.Image{i}=zeros(FileInfo.Pixels,FileInfo.Lines);
                PamMeta.Lifetime{i} = zeros(FileInfo.Pixels,FileInfo.Lines);
                if any(mode == 3)
                    if h.MT.Use_Image.Value && ~isempty(PIE_MT)
                        [im, Bin] = CalculateImage(PIE_MT,2);
                        im = flipud(permute(reshape(double(im),FileInfo.Pixels,FileInfo.Lines),[2 1]));
                        if isfield(FileInfo,'PixTime') %%% convert to kHz countrate if PixTime is available
                            PamMeta.Image{i} = im/FileInfo.PixTime/FileInfo.Frames/1000;
                            h.Image.Colorbar.YLabel.String = 'Count rate [kHz]';
                        else
                            PamMeta.Image{i} = im;
                            h.Image.Colorbar.YLabel.String = 'Counts';
                        end                        
                    else
                        PamMeta.Image{i}=zeros(FileInfo.Pixels,FileInfo.Lines);
                    end
                    
                    %% Calculate mean arival time image
                    if h.MT.Use_Image.Value && h.MT.Use_Lifetime.Value && exist('Bin','var')
                        PIE_MI=TcspcData.MI{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To);
                        PIE_MI(Bin==0)=[];
                        Bin(Bin==0)=[];
                        if ~isempty(PIE_MI) && ~isempty(Bin) && numel(Bin) > 1
                            PamMeta.Lifetime{i} = accumarray(Bin,PIE_MI, [FileInfo.Pixels*FileInfo.Lines 1]);%,@mean);
                            clear PIE_MI Bin;
                            
                            %%% Reshapes pixel vector to image and normalizes to nomber of photons
                            PamMeta.Lifetime{i}=flipud(permute(reshape(PamMeta.Lifetime{i},FileInfo.Pixels,FileInfo.Lines),[2 1]))./im;
                            %%% Sets NaNs to 0 for empty pixels
                            PamMeta.Lifetime{i}(PamMeta.Image{i}==0)=0;
                            %%% Make the display of Lifetime a bit better
                            if UserValues.Settings.Pam.ToggleTACTime
                                rescale = (1E9*FileInfo.TACRange/FileInfo.MI_Bins);
                            else
                                rescale = 1;
                            end
                            tmp = histc(TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)},1:FileInfo.MI_Bins);
                            [Max, index] = max(tmp(max([From, 1]):min([To, end]))); %the TCSPC channel of the maximum within the PIE channel
                            tmp = PamMeta.Lifetime{i}-index-From-1; %offset of the IRF with respect to TCSPC channel zero
                            tmp(tmp<0)=0; tmp = round(tmp.*rescale); %rescale to time in ns
                            radius = str2double(h.MT.Lifetime_Median.String);
                            PamMeta.Lifetime{i} = medfilt2(tmp,[radius radius]); %median filter to remove nonsense
                        end
                        %%% Sets NaNs to 0 for empty pixels
                        PamMeta.Lifetime{i}(PamMeta.Image{i}==0)=0;
                    else
                        clear Bin;
                        PamMeta.Lifetime{i}=zeros(FileInfo.Pixels,FileInfo.Lines);
                    end
                end
                clear Image_Sum
                %% Calculates photons and countrate for PIE channel
                PamMeta.Info{i}(1,1)=numel(TcspcData.MT{Det,Rout});
                PamMeta.Info{i}(2,1)=numel(PIE_MT);%sum(PamMeta.Trace{i})*str2double(h.MT.Binning.String);
                clear PIE_MT
                PamMeta.Info{i}(3,1)=PamMeta.Info{i}(1)/FileInfo.MeasurementTime/1000;
                PamMeta.Info{i}(4,1)=PamMeta.Info{i}(2)/FileInfo.MeasurementTime/1000;
            else
                %%% Creates a 0 trace for empty/nonexistent detector/routing pairs
                PamMeta.Trace{i}=zeros(numel(PamMeta.TimeBins),1);
                PamMeta.BinsPCH{i} = 0:1:10;
                PamMeta.PCH{i} = zeros(numel(PamMeta.BinsPCH{i}),1);
                PamMeta.TracePCH{i} = zeros(numel(0:(UserValues.Settings.Pam.PCH_Binning/1000):FileInfo.MeasurementTime),1);
                %%% Creates a 1x1 zero image for empty/nonexistent detector/routing pairs
                PamMeta.Image{i}=zeros(FileInfo.Lines);
                PamMeta.Lifetime{i}=zeros(FileInfo.Lines);
                %%% Sets coutrate and photon info to 0
                PamMeta.Info{i}(1:4,1)=0;
            end
        end
    end
    %%% flip arrays if they came out wrong
    for i = 1:numel(PamMeta.Trace)
        if size(PamMeta.Trace{i},1) < size(PamMeta.Trace{i},2)
            PamMeta.Trace{i} = PamMeta.Trace{i}';
        end
    end
end
%%% Calculates trace, image, mean arrival time and info for combined
%%% channels
for i=find(UserValues.PIE.Detector==0)
    PamMeta.Image{i}=zeros(FileInfo.Lines);
    PamMeta.Trace{i}=zeros(numel(PamMeta.TimeBins),1);
    PamMeta.Lifetime{i}=zeros(FileInfo.Lines);
    PamMeta.PCH{i}=zeros(max(cellfun(@numel,PamMeta.BinsPCH(UserValues.PIE.Combined{i}))),1);
    PamMeta.BinsPCH{i} = PamMeta.BinsPCH{UserValues.PIE.Combined{i}(1)};
    PamMeta.TracePCH{i} = zeros(numel(PamMeta.TracePCH{UserValues.PIE.Combined{i}(1)}),1);
    PamMeta.Info{i}(1:4,1)=0;
    if UserValues.Settings.Pam.Use_PCH && any(mode == 2)
        TimeBinsPCH=0:(UserValues.Settings.Pam.PCH_Binning/1000):FileInfo.MeasurementTime;
        trace_ms = zeros(1,numel(TimeBinsPCH));
    end
    for j=UserValues.PIE.Combined{i}
        if UserValues.Settings.Pam.Use_Image && any(mode == 3)
            PamMeta.Image{i}=PamMeta.Image{i}+PamMeta.Image{j};
            if UserValues.Settings.Pam.Use_Lifetime
                PamMeta.Lifetime{i}=PamMeta.Lifetime{i}+PamMeta.Lifetime{j};
            end
        end
        if UserValues.Settings.Pam.Use_TimeTrace && any(mode == 1)
            PamMeta.Trace{i}=PamMeta.Trace{i}+PamMeta.Trace{j};
        end
        if UserValues.Settings.Pam.Use_PCH && any(mode == 2)
            PamMeta.TracePCH{i} = PamMeta.TracePCH{i} + PamMeta.TracePCH{j};
        end
        PamMeta.Info{i}=PamMeta.Info{i}+PamMeta.Info{j};
    end
    if UserValues.Settings.Pam.Use_Lifetime && any(mode == 3)
        PamMeta.Lifetime{i} =  PamMeta.Lifetime{i}./numel(UserValues.PIE.Combined{i});
    end
    if UserValues.Settings.Pam.Use_PCH && any(mode == 2)
        PamMeta.BinsPCH{i} = 0:1:max(PamMeta.TracePCH{i});
        PamMeta.PCH{i}=histc(PamMeta.TracePCH{i},PamMeta.BinsPCH{i});
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Determines settings for various things %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Calculate_Settings(obj,~)
global UserValues PamMeta FileInfo
h = guidata(findobj('Tag','Pam'));
Display=0;
%%% If Calculate image was clicked
if obj == h.MT.Use_Image
    UserValues.Settings.Pam.Use_Image=h.MT.Use_Image.Value;
    %%% If also deactivate lifetime calculation
    if h.MT.Use_Image.Value==0
        UserValues.Settings.Pam.Use_Lifetime=0;
        h.MT.Use_Lifetime.Value=0;
        h.Image.Type.Value = 1;
    end
    if UserValues.Settings.Pam.Use_Image
        h.MT.Settings_Tab.Parent = [];
        h.Image.Tab.Parent = h.MT.Tab;
        h.MT.Settings_Tab.Parent =  h.MT.Tab;
        h.MT.Tab.SelectedTab = h.Image.Tab;
    else
        h.Image.Tab.Parent = [];
    end
    Update_Data([],[],0,0,3);
    % define axis limits for image plot
    h.Image.Axes.DataAspectRatio = [1,1,1];
    h.Image.Axes.XLim = [0.5, FileInfo.Pixels+0.5];
    h.Image.Axes.YLim = [0.5, FileInfo.Pixels+0.5];  
    resetplotview(h.Image.Axes,'SaveCurrentView');
    Update_Display([],[],3);
    %%% If use_lifetime was clicked
elseif obj == h.MT.Use_Lifetime
    UserValues.Settings.Pam.Use_Lifetime=h.MT.Use_Lifetime.Value;
    %%% If also activate image calculation
    if h.MT.Use_Lifetime.Value
        h.MT.Use_Image.Value=1;
        UserValues.Settings.Pam.Use_Image=1;
    else
        h.Image.Type.Value = 1;
    end
    if UserValues.Settings.Pam.Use_Image
        h.MT.Settings_Tab.Parent =  [];
        h.Image.Tab.Parent = h.MT.Tab;
        h.MT.Settings_Tab.Parent =  h.MT.Tab;
        h.MT.Tab.SelectedTab = h.MT.Settings_Tab;
    else
        h.Image.Tab.Parent = [];
    end
    Update_Data([],[],0,0,3);
    Update_Display([],[],3);
    %%% If use_pch was clicked
elseif obj == h.MT.Use_PCH
    UserValues.Settings.Pam.Use_PCH=h.MT.Use_PCH.Value;
    if UserValues.Settings.Pam.Use_PCH
        h.MT.Settings_Tab.Parent =  [];
        h.PCH.Tab.Parent = h.MT.Tab;
        h.MT.Settings_Tab.Parent =  h.MT.Tab;
        h.MT.Tab.SelectedTab = h.MT.Settings_Tab;
    else
        h.PCH.Tab.Parent = [];
    end
    Update_Data([],[],0,0,2);
    Update_Display([],[],10);
elseif obj == h.MT.ScanOffsetStart || obj == h.MT.ScanOffsetEnd
    ScanOffsetStart = str2num(h.MT.ScanOffsetStart.String);
    ScanOffsetEnd = str2num(h.MT.ScanOffsetEnd.String);
    if ScanOffsetStart < 0
        ScanOffsetStart = 0;
    end
    if ScanOffsetEnd > 0
        ScanOffsetEnd = 0;
    end
    UserValues.Settings.Pam.ScanOffsetStart = ScanOffsetStart;
    UserValues.Settings.Pam.ScanOffsetEnd = ScanOffsetEnd;
    Update_Data([],[],0,0,3);
    Update_Display([],[],3);
elseif obj == h.MT.Use_TimeTrace
    UserValues.Settings.Pam.Use_TimeTrace=h.MT.Use_TimeTrace.Value;
    if UserValues.Settings.Pam.Use_TimeTrace
        h.MT.Settings_Tab.Parent =  [];
        h.Trace.Tab.Parent = h.MT.Tab;
        h.MT.Settings_Tab.Parent =  h.MT.Tab;
        h.MT.Tab.SelectedTab = h.MT.Settings_Tab;
    else
        h.Trace.Tab.Parent = [];
    end
    Update_Data([],[],0,0,1);
    Update_Display([],[],2);
    %%% change x axis of microtime plots between TCSPC channel and time in ns
elseif obj == h.MT.ToggleTACTime
    UserValues.Settings.Pam.ToggleTACTime=h.MT.ToggleTACTime.Value;
    Update_Data([],[],0,0,3);
    Update_Display([],[],3);
    Update_Display([],[],4);
elseif obj == h.MT.Lifetime_Median
    Update_Data([],[],0,0,3);
    Update_Display([],[],3);
    Update_Display([],[],4);
    %%% When changing trace bin size
elseif obj == h.MT.Binning
    UserValues.Settings.Pam.MT_Binning=str2double(h.MT.Binning.String);
    Update_Data([],[],0,0,1);
    Update_Display([],[],2);
    %%% When changing PCH bin size
elseif obj == h.MT.Binning_PCH
    UserValues.Settings.Pam.PCH_Binning=str2double(h.MT.Binning_PCH.String);
    Update_Data([],[],0,0,2);
    Update_Display([],[],10);
    %%% When changing trace sectioning type
elseif obj == h.MT.Trace_Sectioning
    UserValues.Settings.Pam.MT_Trace_Sectioning=h.MT.Trace_Sectioning.Value;
    Update_Display([],[],2);
    %%% When selection time was changed
elseif obj == h.MT.Time_Section
    UserValues.Settings.Pam.MT_Time_Section=str2double(h.MT.Time_Section.String);
    Update_Display([],[],2);
    %%% When number of sections was changed
elseif obj == h.MT.Number_Section
    UserValues.Settings.Pam.MT_Number_Section=str2double(h.MT.Number_Section.String);
    Update_Display([],[],2);
    %%% Sets new divider
elseif obj == h.Cor.Divider_Menu
    %%% Opens input dialog and gets value
    Divider=inputdlg('New divider:');
    if ~isempty(Divider)
        h.Cor.Divider_Menu.Label=['Divider: ' cell2mat(Divider)];
        UserValues.Settings.Pam.Cor_Divider=round(str2double(Divider));
    end
elseif obj == h.MI.Log_Ind || obj == h.MI.Log
    %%% Puts Y-axis in log scale
    if strcmp(h.MI.Log.Checked,'off')
        UserValues.Settings.Pam.PlotLog = 'on';
        h.MI.Log.Checked='on';
        h.MI.Log_Ind.Checked='on';
    else
        UserValues.Settings.Pam.PlotLog = 'off';
        h.MI.Log.Checked='off';
        h.MI.Log_Ind.Checked='off';
    end
    Update_Display([],[],9)
    Update_Display([],[],5)
elseif obj == h.Trace.Log
    %%% Puts Y-axis of Trace in log scale
    if strcmp(h.Trace.Log.Checked,'off')
        UserValues.Settings.Pam.PlotLogTrace = 'on';
        h.Trace.Log.Checked='on';
    else
        UserValues.Settings.Pam.PlotLogTrace = 'off';
        h.Trace.Log.Checked='off';
    end
    Update_Display([],[],11)
    Update_Display([],[],5)
    
    %%% Switches IRF Check Display
    if strcmp(h.MI.IRF.Checked,'on')
        h.MI.IRF.Checked = 'off';
        UserValues.Settings.Pam.PlotIRF = 'off';
    else
        h.MI.IRF.Checked = 'on';
        UserValues.Settings.Pam.PlotIRF = 'on';
    end
    Update_Display([],[],8);
elseif obj == h.MI.IRF
    %%% Switches IRF Check Display
    if strcmp(h.MI.IRF.Checked,'on')
        h.MI.IRF.Checked = 'off';
        UserValues.Settings.Pam.PlotIRF = 'off';
    else
        h.MI.IRF.Checked = 'on';
        UserValues.Settings.Pam.PlotIRF = 'on';
    end
    Update_Display([],[],8);
elseif obj == h.MI.ScatterPattern
    %%% Switches Scatter Pattern Check Display
    if strcmp(h.MI.ScatterPattern.Checked,'on')
        h.MI.ScatterPattern.Checked = 'off';
        UserValues.Settings.Pam.PlotScat = 'off';
    else
        h.MI.ScatterPattern.Checked = 'on';
        UserValues.Settings.Pam.PlotScat = 'on';
    end
    Update_Display([],[],8);
elseif obj == h.Menu.UseParfor
    %%% Sets number of workers used for parpool to 0 or Inf
    if strcmp(obj.Checked,'on')
        obj.Checked = 'off';
        UserValues.Settings.Pam.ParallelProcessing = 0;
    else
        obj.Checked = 'on';
        UserValues.Settings.Pam.ParallelProcessing = Inf;
    end
elseif obj == h.Menu.NumberOfCores
    %%% Opens input dialog and gets value
    NumberOfCores=inputdlg('New number of cores to use:','Specify the number of cores',1,{num2str(UserValues.Settings.Pam.NumberOfCores)});
    if ~isempty(NumberOfCores)
        NumberOfCores = round(str2double(cell2mat(NumberOfCores)));
        %%% compare with available cores
        maxCores = feature('numCores');
        NumberOfCores = min([maxCores,NumberOfCores]);
        %%% make minimum of 2
        if NumberOfCores < 2
            NumberOfCores = 2;
        end
        h.Menu.NumberOfCores.Label=['Number of Cores: ' num2str(NumberOfCores)];
        UserValues.Settings.Pam.NumberOfCores=NumberOfCores;
    end
elseif obj == h.Burst.BurstLifetime_Checkbox_Menu_IRFshift
    %%% function for the 'automatically optimize IRFshift checkbox'
    %%% (right-click on Fit Lifetime button to change the setting)
    if strcmp(h.Burst.BurstLifetime_Checkbox_Menu_IRFshift.Checked,'off')
        UserValues.BurstSearch.AutoIRFShift = 'on';
        h.Burst.BurstLifetime_Checkbox_Menu_IRFshift.Checked='on';
    else
        UserValues.BurstSearch.AutoIRFShift = 'off';
        h.Burst.BurstLifetime_Checkbox_Menu_IRFshift.Checked='off';
    end
elseif obj == h.Burst.SaveTotalPhotonStream_Checkbox
    UserValues.BurstSearch.SaveTotalPhotonStream = h.Burst.SaveTotalPhotonStream_Checkbox.Value;
elseif obj == h.Burst.NirFilter_Checkbox
    UserValues.BurstSearch.NirFilter = h.Burst.NirFilter_Checkbox.Value;
elseif obj == h.Burst.BurstLifetime_Checkbox
    UserValues.BurstSearch.FitLifetime = h.Burst.BurstLifetime_Checkbox.Value;
elseif obj == h.Cor.Type
    if any(h.Cor.Type.Value == [2,3]) %%% PairCorrelation was selected
        set([h.Cor.Pair_Bins,h.Cor.Pair_Dist,findobj('Tag','PairCorDistance'),findobj('Tag','PairCorBins')],'Visible','on');
    else %%% turn GUI elements off
        set([h.Cor.Pair_Bins,h.Cor.Pair_Dist,findobj('Tag','PairCorDistance'),findobj('Tag','PairCorBins')],'Visible','off');
    end
    if h.Cor.Type.Value == 1 %%% Point Correlation selected
        h.Cor.AfterPulsingCorrection.Visible = 'on';
        h.Cor.AggregateCorrection.Visible = 'on';
    else
        h.Cor.AfterPulsingCorrection.Visible = 'off';
        h.Cor.AggregateCorrection.Visible = 'off';
    end
elseif obj == h.Cor.Remove_Aggregates_Axes_Log
    switch obj.Checked
        case 'on'
            obj.Checked = 'off';
            h.Cor.Remove_Aggregates_Axes.YScale = 'lin';
        case 'off'
            obj.Checked = 'on';
            h.Cor.Remove_Aggregates_Axes.YScale = 'log';
    end
elseif obj == h.Cor.Preview_Correlation_Checkbox
    UserValues.Settings.Pam.Cor_Remove_Aggregates = obj.Value;
elseif obj == h.Cor.Remove_Aggregate_Block_Edit
    val = round(str2double(obj.String))
    if val < 1
        val = 1;
    end
    if val > (numel(PamMeta.MT_Patch_Times)-1)
        val = numel(PamMeta.MT_Patch_Times)-1;
    end
    obj.String = num2str(val);
elseif obj == h.Cor.Remove_Aggregate_Nsigma_Edit
    val = str2double(obj.String);
    if val < 1
        val = 1;
    end
    obj.String = num2str(val);
    UserValues.Settings.Pam.Cor_Aggregate_Threshold = val;
elseif obj == h.Cor.Remove_Aggregate_Timewindow_Edit
    val = str2double(obj.String);
    if val < 0
        val = 0.1;
    end
    obj.String = num2str(val);
    UserValues.Settings.Pam.Cor_Aggregate_Timewindow = val;
elseif obj == h.Cor.Remove_Aggregate_TimeWindowAdd_Edit
    val = str2double(obj.String);
    if val < 0
        val = 0;
    end
    obj.String = num2str(val);
    UserValues.Settings.Pam.Cor_Aggregate_TimewindowAdd = val;
elseif obj == h.Cor.AfterPulsingCorrection
    %%% disable aggregate removal
    if obj.Value == 1
        h.Cor.AggregateCorrection.Value = 0;
    end
    UserValues.Settings.Pam.AfterpulsingCorrection = h.Cor.AfterPulsingCorrection.Value;
    %%% check if BurstBrowser is open, if yes, change value there
    hBB = findobj('Tag','BurstBrowser');
    if ~isempty(hBB)
        hBB = guidata(hBB);
        if UserValues.Settings.Pam.AfterpulsingCorrection == 1
            hBB.Secondary_Tab_Correlation_Afterpulsing_Menu.Checked = 'on';
        else
            hBB.Secondary_Tab_Correlation_Afterpulsing_Menu.Checked = 'off';
        end
    end
elseif obj == h.Cor.AggregateCorrection
    %%% disable afterpulsing removal
    if obj.Value == 1
        h.Cor.AfterPulsingCorrection.Value = 0;
    end

end
%%% Saves UserValues
LSUserValues(1);
%%% Updates pam meta data, if Update_Data was not called
if Display
    Update_Data([],[],0,0);
    Update_Display([],[],0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Updates Pam plots  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Display(~,~,mode)
global UserValues PamMeta FileInfo
h = guidata(findobj('Tag','Pam'));

%%% Determines which parts are updated
%%% 1: PIE list and PIE info
%%% 2: Trace plot and sections
%%% 3: Image plot
%%% 4: Microtime histograms
%%% 5: PIE patches
%%% 6: Phasor Plot
%%% 7: Detector Calibration
%%% 8: Plot IRF or Scatter Pattern
%%% 9: Y-axis log
%%% 10: PCH plot
%%% 11: Y-axis log of Trace
if nargin<3 || any(mode==0)
    mode=[1:5, 6, 8, 9, 10];
end
if any(mode==3)
    % if it's not imaging data, don't calculate the image
    if isempty(FileInfo.Lines) || FileInfo.Lines < 2 || isempty(FileInfo.Pixels) || FileInfo.Pixels < 2 || ~h.MT.Use_Image.Value
        mode(mode == 3) = [];
        % clear image
        h.Plots.Image.CData = [];
    end
end

%% PIE List update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Uses HTML to set color of each channel to selected color
List=cell(numel(UserValues.PIE.Name),1);
for i=1:numel(List)
    Hex_color=dec2hex(round(UserValues.PIE.Color(i,:)*255))';
    List{i}=['<HTML><FONT color=#' Hex_color(:)' '>' UserValues.PIE.Name{i} '</Font></html>'];
end
%%% Updates PIE_List string
h.PIE.List.String=List;
%%% Removes nonexistent selected channels
h.PIE.List.Value(h.PIE.List.Value>numel(UserValues.PIE.Name))=[];
%%% Selects first channel, if none is selected
if isempty(h.PIE.List.Value)
    h.PIE.List.Value=1;
end
drawnow;
%%% Finds currently selected PIE channel
Sel=h.PIE.List.Value(1);

%%% Updates DetectectionChannel List
h.PIE.DetectionChannel.String = color_string(UserValues.Detector.Name,UserValues.Detector.Color);

%% PIE info update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==1)
    %%% Updates PIE channel settings to current PIE channel
    h.PIE.Name.String=UserValues.PIE.Name{Sel};
    if UserValues.PIE.Detector(Sel) ~= 0 %%% only if no combined channel is selected
        h.PIE.DetectionChannel.Value = find((UserValues.Detector.Det == UserValues.PIE.Detector(Sel)) &...
            (UserValues.Detector.Rout == UserValues.PIE.Router(Sel)),1);
        if isempty(h.PIE.DetectionChannel.Value) %%% catch case where default value was set to 1,1, but the setup has no detector channel one
            h.PIE.DetectionChannel.Value = 1;
            UserValues.PIE.Detector(Sel) = UserValues.Detector.Det(1);
            UserValues.PIE.Router(Sel) = UserValues.Detector.Rout(1);
        end
    end
    %h.PIE.Detector.String=num2str(UserValues.PIE.Detector(Sel));
    %h.PIE.Routing.String=num2str(UserValues.PIE.Router(Sel));
    h.PIE.From.String=num2str(UserValues.PIE.From(Sel));
    h.PIE.To.String=num2str(UserValues.PIE.To(Sel));
    
    %%% Updates PIE channel infos to current PIE channel
    h.PIE.Info.String{1}=num2str(PamMeta.Info{Sel}(1) );
    h.PIE.Info.String{2}=num2str(PamMeta.Info{Sel}(2));
    h.PIE.Info.String{3}=[num2str(PamMeta.Info{Sel}(3),'%6.2f' ) ' kHz'];
    h.PIE.Info.String{4}=[num2str(PamMeta.Info{Sel}(4),'%6.2f' ) ' kHz'];
    h.PIE.Info.String{5} = [num2str(UserValues.PIE.Background(Sel),'%6.2f' ) ' kHz'];
    %%% Disables PIE info controls for combined channels
    if UserValues.PIE.Detector(Sel)==0
        h.PIE.Name.Enable='inactive';
        %h.PIE.Detector.Enable='inactive';
        %h.PIE.Routing.Enable='inactive';
        h.PIE.DetectionChannel.Enable = 'inactive';
        h.PIE.DetectionChannel.Visible = 'off';
        h.PIE.From.Enable='inactive';
        h.PIE.To.Enable='inactive';
        
        %h.PIE.Name.BackgroundColor=UserValues.Look.Back;
        %h.PIE.Detector.BackgroundColor=UserValues.Look.Back;
        %h.PIE.Routing.BackgroundColor=UserValues.Look.Back;
        %h.PIE.DetectionChannel.BackgroundColor = UserValues.Look.Back;
        %h.PIE.From.BackgroundColor=UserValues.Look.Back;
        %h.PIE.To.BackgroundColor=UserValues.Look.Back;
        
        %h.PIE.Name.ForegroundColor=UserValues.Look.Disabled;
        %h.PIE.Detector.ForegroundColor=UserValues.Look.Disabled;
        %h.PIE.Routing.ForegroundColor=UserValues.Look.Disabled;
        %h.PIE.DetectionChannel.ForegroundColor = UserValues.Look.Disabled;
        %h.PIE.From.ForegroundColor=UserValues.Look.Disabled;
        %h.PIE.To.ForegroundColor=UserValues.Look.Disabled;
    else
        h.PIE.Name.Enable='on';
        %h.PIE.Detector.Enable='on';
        %h.PIE.Routing.Enable='on';
        h.PIE.DetectionChannel.Enable = 'on';
        h.PIE.DetectionChannel.Visible = 'on';
        h.PIE.From.Enable='on';
        h.PIE.To.Enable='on';
        
        %h.PIE.Name.BackgroundColor=UserValues.Look.Control;
        %h.PIE.Detector.BackgroundColor=UserValues.Look.Control;
        %h.PIE.Routing.BackgroundColor=UserValues.Look.Control;
        %h.PIE.DetectionChannel.BackgroundColor = [1 1 1];
        %h.PIE.From.BackgroundColor=UserValues.Look.Control;
        %h.PIE.To.BackgroundColor=UserValues.Look.Control;
        
        %h.PIE.Name.ForegroundColor=UserValues.Look.Fore;
        %h.PIE.Detector.ForegroundColor=UserValues.Look.Fore;
        %h.PIE.Routing.ForegroundColor=UserValues.Look.Fore;
        %h.PIE.DetectionChannel.ForegroundColor = [0 0 0];
        %h.PIE.From.ForegroundColor=UserValues.Look.Fore;
        %h.PIE.To.ForegroundColor=UserValues.Look.Fore;
    end
    
end

%% Patches minimization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Sets YLim of pie patches to [0 1] to enable autoscaling
if any(mode==4) || any(mode==5)
    if isfield(h.Plots,'PIE_Patches')
        for i=1:numel(h.Plots.PIE_Patches)
            if ishandle(h.Plots.PIE_Patches{i})
                h.Plots.PIE_Patches{i}.YData=[1 0 0 1];
            end
        end
    end
end
%%% Sets YLim of pie patches to [0 1] to enable autoscaling
if any(mode==2)
    if isfield(h.Plots,'MT_Patches')
        for i=1:numel(h.Plots.MT_Patches)
            h.Plots.MT_Patches{i}.YData=[1 0 0 1];
        end
    end
end

%% Trace plot update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Updates intensity trace plot with current channel
if any(mode==2)
    %%% reset plots
    cellfun(@delete,h.Plots.Trace);
    del = zeros(1,numel(h.Trace.Axes.Children));
    for k = 1:numel(h.Trace.Axes.Children)
        if strcmp(h.Trace.Axes.Children(k).Type,'line')
            del(k) = 1;
        end
    end
    delete(h.Trace.Axes.Children(logical(del)));
    h.Plots.Trace = {};
    for t = h.PIE.List.Value
        %%% create plot
        h.Plots.Trace{end+1} = plot(PamMeta.TimeBins(1:end-1)+min(diff(PamMeta.TimeBins))/2,PamMeta.Trace{t}(1:end-1),'Color',UserValues.PIE.Color(t,:),'Parent',h.Trace.Axes);
    end
    guidata(h.Pam,h);
    h.Trace.Axes.XLim = [0,PamMeta.TimeBins(end)];
    if ~isempty(gcbo)
        if any(gcbo == [h.Trace.Trace_Export_Menu,h.Trace.Trace_ExportFRETTrace_Menu,h.Trace.Trace_ExportAnisotropyTrace_Menu])
            hfig = figure('Visible','on','Units','pixel',...
                'Position',[100,100,600*h.Trace.Axes.Position(3),450*h.Trace.Axes.Position(4)],...
                'Name',FileInfo.FileName{1});
            switch gcbo
                case h.Trace.Trace_Export_Menu
                    ax = copyobj(h.Trace.Axes,hfig);
                    %%% delete patches
                    del = false(numel(ax.Children),1);
                    for i = 1:numel(ax.Children)
                        if strcmp(ax.Children(i).Type,'patch')
                            del(i) = true;
                        end
                    end
                    delete(ax.Children(del));
                case h.Trace.Trace_ExportFRETTrace_Menu
                    %%% get Donor/FRET channels
                    pie_chan_selection = UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method};
                    switch UserValues.BurstSearch.Method
                        case {1,2} % 2color MFD
                           donor = [find(strcmp(UserValues.PIE.Name,pie_chan_selection{1,1})),...
                                     find(strcmp(UserValues.PIE.Name,pie_chan_selection{1,2}))];
                           fret = [find(strcmp(UserValues.PIE.Name,pie_chan_selection{2,1})),...
                                     find(strcmp(UserValues.PIE.Name,pie_chan_selection{2,2}))];
                        case {3,4} % 3color MFD, take 2color sub-channels
                            donor = [find(strcmp(UserValues.PIE.Name,pie_chan_selection{4,1})),...
                                     find(strcmp(UserValues.PIE.Name,pie_chan_selection{4,2}))];
                            fret = [find(strcmp(UserValues.PIE.Name,pie_chan_selection{5,1})),...
                                     find(strcmp(UserValues.PIE.Name,pie_chan_selection{5,2}))];
                        case {5,6} % 2color no-MFD
                            donor = find(strcmp(UserValues.PIE.Name,pie_chan_selection{1,1}));
                            fret = find(strcmp(UserValues.PIE.Name,pie_chan_selection{2,1}));
                    end
                    %%% calculate FRET trace
                    don_trace = PamMeta.Trace{donor(1)};
                    if numel(donor) > 1
                        don_trace = don_trace + PamMeta.Trace{donor(2)};
                    end
                    fret_trace = PamMeta.Trace{fret(1)};
                    if numel(fret) > 1
                        fret_trace = fret_trace + PamMeta.Trace{fret(2)};
                    end
                    E_trace = fret_trace./(fret_trace+don_trace);
                    plot(PamMeta.TimeBins,E_trace,'LineWidth',1);
                    ax = gca;
                    ylabel('FRET Efficiency (uncorrected)');
                    xlabel('Time [s]');
            case h.Trace.Trace_ExportAnisotropyTrace_Menu
                    %%% get par/per channels as selected first and second
                    %%% PIE channel
                    sel = h.PIE.List.Value;
                    par_trace = PamMeta.Trace{sel(1)};
                    per_trace = PamMeta.Trace{sel(2)};
                    %%% calculate anisotropy
                    r_trace = (par_trace-per_trace)./(par_trace+2*per_trace);
                    plot(PamMeta.TimeBins,r_trace,'LineWidth',1);
                    ax = gca;
                    ylabel('Anisotropy r (uncorrected)');
                    xlabel('Time [s]');
            end
            hfig.Color = [1,1,1];
            set(ax,'Color',[1,1,1],'XColor',[0,0,0],'YColor',[0,0,0],'LineWidth',1.5,'Units','pixel',...
                'FontSize',h.Progress.Text.FontSize*1.5,'Layer','top');
            if ismac
                set(ax.Children,'LineWidth',1.5);
            else
                set(ax.Children,'LineWidth',1.25);
            end
            ax.Position(2) = ax.Position(2) + 20;
            ax.Position(4) = ax.Position(4) - 20;
            colormap(h.Pam.Colormap);
            ax.Position(1) = ax.Position(1)+50; hfig.Position(3) = hfig.Position(3)+50;
            hfig.Position(4) = hfig.Position(4)+25;
            switch gcbo
                case h.Trace.Trace_Export_Menu
                    ax.Title.String = FileInfo.FileName{1}; ax.Title.Interpreter = 'none';
                    legend(ax,UserValues.PIE.Name(h.PIE.List.Value),'EdgeColor','none','Color',[1,1,1]);
                case h.Trace.Trace_ExportFRETTrace_Menu
                    ax.Title.String = ['FRET efficiency trace (' FileInfo.FileName{1} ')']; ax.Title.Interpreter = 'none';                
                    ax.YLim = [0,1];
                case h.Trace.Trace_ExportAnisotropyTrace_Menu
                    ax.Title.String = ['Anisotropy trace (' FileInfo.FileName{1} ')']; ax.Title.Interpreter = 'none';    
                    ax.YLim = [-0.1,0.5];
            end
            ax.Title.FontSize = 0.75*ax.Title.FontSize;
        end
    end
end
%% PCH plot update
if any(mode == 10)
    %%% reset plots
    cellfun(@delete,h.Plots.PCH);
    del = zeros(1,numel(h.PCH.Axes.Children));
    for k = 1:numel(h.PCH.Axes.Children)
        if strcmp(h.PCH.Axes.Children(k).Type,'line')
            del(k) = 1;
        end
    end
    delete(h.PCH.Axes.Children(logical(del)));
    h.Plots.PCH = {};
    
    obj = gcbo;
    if obj == h.PCH.PCH_2D_Menu
        switch obj.Checked
            case 'on'
                obj.Checked = 'off';
                UserValues.Settings.Pam.PCH_2D = 0;
                h.PCH.PCH_Export_CSV_Menu.Visible = 'on';
            case 'off'
                obj.Checked = 'on';
                UserValues.Settings.Pam.PCH_2D = 1;
                h.PCH.PCH_Export_CSV_Menu.Visible = 'off';
        end
    end
    if UserValues.Settings.Pam.Use_PCH
        if ~UserValues.Settings.Pam.PCH_2D || numel(h.PIE.List.Value) == 1
            for t = h.PIE.List.Value
                %%% create plot
                h.Plots.PCH{end+1} = plot(PamMeta.BinsPCH{t},PamMeta.PCH{t},'Color',UserValues.PIE.Color(t,:),'Parent',h.PCH.Axes);
            end
            guidata(h.Pam,h);
            h.PCH.Axes.YLimMode = 'auto';
            h.PCH.Axes.XLim = [0,max([max(cell2mat(cellfun(@(x) find(x > 1,1,'last'),PamMeta.PCH(h.PIE.List.Value),'UniformOutput',false))),1])];
            h.PCH.Axes.XLabel.String = sprintf('Counts per %g ms',UserValues.Settings.Pam.PCH_Binning);
            h.PCH.Axes.YLabel.String = 'Frequency';
            h.PCH.Axes.YScale = 'log';
            h.PCH.Axes.DataAspectRatioMode = 'auto';
        else
            sel = h.PIE.List.Value;
            sel = sel(1:2);
            [H,x,y] = histcounts2(PamMeta.TracePCH{sel(1)},PamMeta.TracePCH{sel(2)},...
                0:1:max(PamMeta.TracePCH{sel(1)}),0:1:max(PamMeta.TracePCH{sel(2)}));
            h.Plots.PCH{end+1} = imagesc(y(1:end-1)+min(diff(y))/2,...
                x(1:end-1)+min(diff(x))/2,log10(H),'Parent',h.PCH.Axes);
            h.Plots.PCH{end}.UIContextMenu = h.PCH.Menu;
            guidata(h.Pam,h);
            h.PCH.Axes.YScale = 'lin';
            h.PCH.Axes.YLim = [x(1),max([find(PamMeta.PCH{sel(1)} > 1,1,'last'),1])];
            h.PCH.Axes.XLim = [y(1),max([find(PamMeta.PCH{sel(2)} > 1,1,'last'),1])];
            h.PCH.Axes.XLabel.String = sprintf(['Counts per %g ms (' UserValues.PIE.Name{sel(2)} ')'],UserValues.Settings.Pam.PCH_Binning);
            h.PCH.Axes.YLabel.String = sprintf(['Counts per %g ms (' UserValues.PIE.Name{sel(1)} ')'],UserValues.Settings.Pam.PCH_Binning);
            %h.PCH.Axes.DataAspectRatio(1:2) = [1,1];
        end
    end
    if obj == h.PCH.PCH_Export_Menu
        hfig = figure('Visible','on','Units','pixel',...
            'Position',[100,100,500*h.PCH.Axes.Position(3),500*h.PCH.Axes.Position(4)],...
            'Name',FileInfo.FileName{1});
        ax = copyobj(h.PCH.Axes,hfig);
        hfig.Color = [1,1,1];
        set(ax,'Color',[1,1,1],'XColor',[0,0,0],'YColor',[0,0,0],'LineWidth',1,'Units','pixel',...
            'FontSize',h.Progress.Text.FontSize,'Layer','top');
        colormap(h.Pam.Colormap);
        ax.Position(1) = ax.Position(1)+50; hfig.Position(3) = hfig.Position(3)+50;
        hfig.Position(4) = hfig.Position(4)+25;
        ax.Title.String = FileInfo.FileName{1}; ax.Title.Interpreter = 'none';
        if ~UserValues.Settings.Pam.PCH_2D
            legend(ax,UserValues.PIE.Name(h.PIE.List.Value),'EdgeColor','none','Color','none');
        end
    elseif obj == h.PCH.PCH_Export_CSV_Menu
        % Export the selected data to a comma-separated value file (*.csv)
        sel = h.PIE.List.Value;
        e.Key = 'Export_PCH';
        Pam_Export([],e,sel); % ToDo: move this to right-click menu of PIE channel and export tab in the future.
    end
end
%% Image plot update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Updates image
if any(mode==3)
    h.Image.Axes.DataAspectRatio=[1 1 1];
    h.Image.Axes.YDir = 'normal';
    switch h.Image.Type.Value        
        %%% Intensity image        
        case 1            
            h.Plots.Image.CData=PamMeta.Image{Sel};
            %%% Autoscales between min-max; +1 is for max=min
            if h.Image.Autoscale.Value
                h.Image.Axes.CLim=[min(min(PamMeta.Image{Sel})), max(max(PamMeta.Image{Sel}))+1];
            end
        %%% Mean arrival time image
        case 2
            h.Plots.Image.CData = PamMeta.Lifetime{Sel};
            %%% Autoscales between min-max of pixels with at least 10% intensity;
            if h.Image.Autoscale.Value
                Min = 0;%0.1*max(max(PamMeta.Lifetime{Sel}))-1; %%% -1 is for 0 intensity images
                if max(max(PamMeta.Image{Sel}))~=0
                    h.Image.Axes.CLim=[min(min(PamMeta.Lifetime{Sel}(PamMeta.Image{Sel}>Min))), max(max(PamMeta.Lifetime{Sel}(PamMeta.Image{Sel}>Min)))+1];
                end
            end
            %%% Lifetime from phase
        case 3
            phas = medfilt2(PamMeta.TauP);
            h.Plots.Image.CData=phas;
            %%% Autoscales between min-max of pixels with at least 10% intensity;
            if h.Image.Autoscale.Value
                Min=0.1*max(max(PamMeta.Phasor_Int))-1; %%% -1 is for 0 intensity images
                h.Image.Axes.CLim=[min(min(phas(PamMeta.Phasor_Int>Min))), max(max(phas(PamMeta.Phasor_Int>Min)))+1];
            end
            %%% Lifetime from modulation
        case 4
            phas = medfilt2(PamMeta.TauM);
            h.Plots.Image.CData=phas;
            %%% Autoscales between min-max of pixels with at least 10% intensity;
            if h.Image.Autoscale.Value
                Min=0.1*max(max(PamMeta.Phasor_Int))-1; %%% -1 is for 0 intensity images
                h.Image.Axes.CLim=[min(min(phas(PamMeta.Phasor_Int>Min))), max(max(phas(PamMeta.Phasor_Int>Min)))+1];
            end
            %%% g from phasor calculation
        case 5
            phas = medfilt2(PamMeta.g);
            h.Plots.Image.CData=phas;
            %%% Autoscales between min-max of pixels with at least 10% intensity;
            if h.Image.Autoscale.Value
                Min=0.1*max(max(PamMeta.Phasor_Int))-1; %%% -1 is for 0 intensity images
                h.Image.Axes.CLim=[min(min(phas(PamMeta.Phasor_Int>Min))), max(max(phas(PamMeta.Phasor_Int>Min)))+1];
            end
            %%% s from phasor calculation
        case 6
            phas = medfilt2(PamMeta.s);
            h.Plots.Image.CData=phas;
            %%% Autoscales between min-max of pixels with at least 10% intensity;
            if h.Image.Autoscale.Value
                Min=0.1*max(max(PamMeta.Phasor_Int))-1; %%% -1 is for 0 intensity images
                h.Image.Axes.CLim=[min(min(phas(PamMeta.Phasor_Int>Min))), max(max(phas(PamMeta.Phasor_Int>Min)))+1];
            end            
    end
    switch h.Image.Type.Value %label the colorbar correctly
        case 1
            h.Image.Colorbar.YLabel.String = 'Count rate [kHz]';
        case {2,3,4}
            if UserValues.Settings.Pam.ToggleTACTime
                h.Image.Colorbar.YLabel.String = 'Mean arrival time [ns]';
            else
                h.Image.Colorbar.YLabel.String = 'TCSPC channel';
            end
        otherwise
            h.Image.Colorbar.YLabel.String = 'Counts';
    end
    %%% Sets xy limits and aspectration ot 1
    h.Image.Axes.DataAspectRatio=[1 1 1];
    h.Image.Axes.XLim(1)= 0.5;
    h.Image.Axes.XLim(2)= size(PamMeta.Image{Sel},2)+0.5;
    h.Image.Axes.YLim(1)= 0.5;
    h.Image.Axes.YLim(2)= size(PamMeta.Image{Sel},1)+0.5;
end

%% All microtime plot update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==4)
    %%% Adjusts plots cell to right size
    if ~isfield(h.Plots,'MI_All') || (numel(h.Plots.MI_All) < numel(PamMeta.MI_Hist) )
        h.Plots.MI_All{numel(PamMeta.MI_Hist)}=[];
        %%% Deletes unused lineseries
    elseif numel(h.Plots.MI_All) > numel(PamMeta.MI_Hist)
        Unused=h.Plots.MI_All(numel(PamMeta.MI_Hist)+1:end);
        h.Plots.MI_All(numel(PamMeta.MI_Hist)+1:end)=[];
        cellfun(@delete,Unused)
    end
    if FileInfo.MI_Bins == 1 % T2 workaround
        h.MI.All_Axes.XLim = [0 FileInfo.MI_Bins];
    else
        h.MI.All_Axes.XLim = [1 FileInfo.MI_Bins]; 
    end
    for i=1:numel(PamMeta.MI_Hist)
        %%% Checks, if lineseries already exists
        if ~isempty(h.Plots.MI_All{i}) && isvalid(h.Plots.MI_All{i})
            %%% Only changes YData of plot to increase speed
            h.Plots.MI_All{i}.YData=PamMeta.MI_Hist{i};
        else
            %%% Plots new lineseries, if none exists
            h.Plots.MI_All{i}=handle(plot(h.MI.All_Axes,PamMeta.MI_Hist{i}));
        end
        %%% Sets color of lineseries (Divide by max to make 0 <= c <= 1
        h.Plots.MI_All{i}.Color= UserValues.Detector.Color(i,:);
    end
end

%% Individual microtime plots update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==4)
    %%% Plots individual microtime histograms
    if any(~cellfun(@ishandle,h.Plots.MI_Ind))
        %%% something went wrong, replot
        Update_Detector_Channels([],[],1);
        h = guidata(gcbo);
    end
    for i=1:numel(UserValues.Detector.Plots)
        if UserValues.Detector.Plots(i)<=numel(PamMeta.MI_Hist)
            h.Plots.MI_Ind{i}.XData=1:numel(PamMeta.MI_Hist{UserValues.Detector.Plots(i)});
            h.Plots.MI_Ind{i}.YData=PamMeta.MI_Hist{UserValues.Detector.Plots(i)};
            h.Plots.MI_Ind{i}.Color=UserValues.Detector.Color(UserValues.Detector.Plots(i),:);
            %%% Set XLim to Microtime Range
            if FileInfo.MI_Bins == 1 % T2 workaround
                h.Plots.MI_Ind{i}.Parent.XLim = [0 FileInfo.MI_Bins];
            else
                h.Plots.MI_Ind{i}.Parent.XLim = [1 FileInfo.MI_Bins];
            end
        end
    end
    %%% Resets PIE patch scale
    if isfield(h.Plots,'PIE_Patches')
        for i=1:numel(h.Plots.PIE_Patches)
            if ishandle(h.Plots.PIE_Patches{i})
                YData=h.Plots.PIE_Patches{i}.Parent.YLim;
                h.Plots.PIE_Patches{i}.YData=[YData(2), YData(1), YData(1), YData(2)];
                %%% Moves selected PIE patch to top (but below curve)
                if i==Sel
                    uistack(h.Plots.PIE_Patches{i},'top');
                    uistack(h.Plots.PIE_Patches{i},'down',3);
                end
            end
        end
    end
end
if any(mode == 4)
    %%% change xaxis units between TCSPC channel and time in ns
    if UserValues.Settings.Pam.ToggleTACTime
        TACtoTime = (1E9*FileInfo.TACRange/FileInfo.MI_Bins);
        %%% switch to time
        xlabels = h.MI.All_Axes.XTickLabels;
        maxtime = ceil(FileInfo.TACRange*1E9);
        times = 0:round(maxtime/(numel(xlabels)+1)):maxtime; times(1) = [];
        xticks = round(times/TACtoTime);
        xlabels = cellfun(@num2str,num2cell(times),'UniformOutput',false);
        h.MI.All_Axes.XTick = xticks;
        h.MI.All_Axes.XTickLabel = xlabels;
        h.MI.All_Axes.XLabel.String = 'Time [ns]';
        for i = 1:numel(h.MI.Individual)
            if strcmp(h.MI.Individual{i}.Type,'axes')
                h.MI.Individual{i}.XTick = xticks;
                h.MI.Individual{i}.XTickLabel = xlabels;
                h.MI.Individual{i}.XLabel.String = 'Time [ns]';
            end
        end
    else
        %%% switch back to TCSPC channels
        TimetoTAC = 1/(1E9*FileInfo.TACRange/FileInfo.MI_Bins);
        h.MI.All_Axes.XLabel.String = 'TCSPC channel';
        h.MI.All_Axes.XTickMode = 'auto';
        h.MI.All_Axes.XTickLabelMode = 'auto';
        for i = 1:numel(h.MI.Individual)
            if strcmp(h.MI.Individual{i}.Type,'axes')
                h.MI.Individual{i}.XLabel.String = 'TCSPC channel';
                h.MI.Individual{i}.XTickMode = 'auto';
                h.MI.Individual{i}.XTickLabelMode = 'auto';
            end
        end
    end
end

if any(mode==8)
    %% Plot IRFs on the individual microtime plots
    if strcmp(h.MI.IRF.Checked,'on')
        for i = 1:size(UserValues.Detector.Plots,1) %loop through microtime tabs
            for j = 1:size(UserValues.Detector.Plots,2) %loop through plots per microtime tab
                % remove everything which was plotted
                for k = 1:numel(UserValues.PIE.IRF)
                    if ~isempty(UserValues.PIE.IRF{k})
                        % combined channels will either not be in UserValues.PIE.IRF, or will be empty
                        h.Plots.MI_Ind_IRF{i,j}.YData = zeros(numel(UserValues.PIE.IRF{k}),1);
                    end
                end
                % find which detector is selected for the current individual microtime plot
                detector = h.MI.Individual{i, 2*j+2}.Value;
                % loop through PIE channels
                for k = 1:numel(UserValues.PIE.IRF)
                    if ~isempty(UserValues.PIE.IRF{k})
                        % combined channels will either not be in UserValues.PIE.IRF, or will be empty
                        From = max([UserValues.PIE.From(k) 1]);
                        To = min([UserValues.PIE.To(k) numel(UserValues.PIE.IRF{k}) FileInfo.MI_Bins]);
                        FromTo = From:To;
                        if (UserValues.PIE.Detector(k) == UserValues.Detector.Det(detector))...
                                && (UserValues.PIE.Router(k) == UserValues.Detector.Rout(detector))
                            %%% Plot IRF in PIE Channel range
                            h.Plots.MI_Ind_IRF{i,j}.Visible = 'on';
                            h.Plots.MI_Ind_IRF{i,j}.XData = 1:numel(UserValues.PIE.IRF{k});
                            if isequal(h.Plots.MI_Ind_IRF{i,j}.YData,[0 0])
                                % no IRF has been plotted yet on microtime plot (i,j)
                                h.Plots.MI_Ind_IRF{i,j}.YData = zeros(numel(UserValues.PIE.IRF{k}),1);
                            end
                            if isempty(PamMeta.MI_Hist{UserValues.Detector.Plots(i,j)}) || (max(PamMeta.MI_Hist{UserValues.Detector.Plots(i,j)}) == 0)
                                % there is no data, so just show the IRF
                                norm = 1;
                            else
                                norm = max(PamMeta.MI_Hist{UserValues.Detector.Plots(i,j)}(From:min([To end])));
                            end
                            h.Plots.MI_Ind_IRF{i,j}.YData(FromTo) = UserValues.PIE.IRF{k}(FromTo)./max(UserValues.PIE.IRF{k}(FromTo)).*norm;
                        end
                    end
                end
            end
        end
    else
        for i = 1:size(UserValues.Detector.Plots,1) %loop through microtime tabs
            for j = 1:size(UserValues.Detector.Plots,2) %loop through plots per microtime tab
                if ishandle(h.Plots.MI_Ind_IRF{i,j})
                    h.Plots.MI_Ind_IRF{i,j}.Visible = 'off';
                end
            end
        end
    end
    %% Plot Scatter Patterns on the individual microtime plots
    if strcmp(h.MI.ScatterPattern.Checked,'on')
        for i = 1:size(UserValues.Detector.Plots,1) %loop through microtime tabs
            for j = 1:size(UserValues.Detector.Plots,2) %loop through plots per microtime tab
                % remove everything which was plotted
                for k = 1:numel(UserValues.PIE.ScatterPattern)
                    if ~isempty(UserValues.PIE.ScatterPattern{k})
                        % combined channels will either not be in UserValues.PIE.ScatterPattern, or will be empty
                        h.Plots.MI_Ind_Scat{i,j}.YData = zeros(numel(UserValues.PIE.ScatterPattern{k}),1);
                    end
                end
                % find which detector is selected for the current individual microtime plot
                detector = h.MI.Individual{i, 2*j+2}.Value;
                % loop through PIE channels
                for k = 1:numel(UserValues.PIE.ScatterPattern)
                    if ~isempty(UserValues.PIE.ScatterPattern{k})
                        % combined channels will either not be in
                        % UserValues.PIE.ScatterPattern, or will be empty
                        FromTo = max([UserValues.PIE.From(k) 1]):min([UserValues.PIE.To(k) numel(UserValues.PIE.ScatterPattern{k}) FileInfo.MI_Bins min(cellfun(@numel,PamMeta.MI_Hist))]);
                        if (UserValues.PIE.Detector(k) == UserValues.Detector.Det(detector))...
                                && (UserValues.PIE.Router(k) == UserValues.Detector.Rout(detector))
                            %%% Plot scatter in PIE Channel range
                            h.Plots.MI_Ind_Scat{i,j}.Visible = 'on';
                            h.Plots.MI_Ind_Scat{i,j}.XData = 1:numel(UserValues.PIE.ScatterPattern{k});
                            if isequal(h.Plots.MI_Ind_Scat{i,j}.YData,[0 0])
                                % no scatter has been plotted yet on microtime plot (i,j)
                                h.Plots.MI_Ind_Scat{i,j}.YData = zeros(numel(UserValues.PIE.ScatterPattern{k}),1);
                            end
                            if max(PamMeta.MI_Hist{UserValues.Detector.Plots(i,j)}) == 0
                                % there is no data, so just show the scatter
                                norm = 1;
                            else
                                norm = max(PamMeta.MI_Hist{UserValues.Detector.Plots(i,j)}(FromTo));
                            end
                            h.Plots.MI_Ind_Scat{i,j}.YData(FromTo) = UserValues.PIE.ScatterPattern{k}(FromTo)./max(UserValues.PIE.ScatterPattern{k}(FromTo)).*norm;
                        end
                    end
                end
            end
        end
    else
        for i = 1:size(UserValues.Detector.Plots,1) %loop through microtime tabs
            for j = 1:size(UserValues.Detector.Plots,2) %loop through plots per microtime tab
                if ishandle(h.Plots.MI_Ind_Scat{i,j})
                    h.Plots.MI_Ind_Scat{i,j}.Visible = 'off';
                end
            end
        end
    end
    %%% Resets PIE patch scale
    if isfield(h.Plots,'PIE_Patches')
        for i=1:numel(h.Plots.PIE_Patches)
            if ishandle(h.Plots.PIE_Patches{i})
                YData=h.Plots.PIE_Patches{i}.Parent.YLim;
                h.Plots.PIE_Patches{i}.YData=[YData(2), YData(1), YData(1), YData(2)];
                %%% Moves selected PIE patch to top (but below curve)
                if i==Sel
                    uistack(h.Plots.PIE_Patches{i},'top');
                    uistack(h.Plots.PIE_Patches{i},'down',3);
                end
            end
        end
    end
end

%% Phasor microtime plot update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==6)
    From=str2double(h.MI.Phasor_From.String);
    To=str2double(h.MI.Phasor_To.String);
    Shift=str2double(h.MI.Phasor_Shift.String);
    Det=h.MI.Phasor_Det.Value;
    
    if From<1
        From=1;
        h.MI.Phasor_From.String=num2str(From);
    end
    if To>numel(PamMeta.MI_Hist{Det})
        To=numel(PamMeta.MI_Hist{Det});
        h.MI.Phasor_To.String=num2str(To);
    end
    
    if(size(UserValues.Phasor.Reference,2) < To)
        UserValues.Phasor.Reference(end,To) = 0;
    end
    %%% Plots Reference histogram
    Ref=circshift(UserValues.Phasor.Reference(Det,:),[0 round(Shift)]);Ref=Ref(From:To);
    h.Plots.PhasorRef.XData=From:To;
    %h.Plots.PhasorRef.YData=(Ref-min(Ref))/(max(Ref)-min(Ref));
    h.Plots.PhasorRef.YData=Ref/max(Ref);
    %%% Plots Phasor microtime
    h.Plots.Phasor.XData=From:To;
    Pha=PamMeta.MI_Hist{Det}(From:To);
    %h.Plots.Phasor.YData=(Pha-min(Pha))/(max(Pha)-min(Pha));
    h.Plots.Phasor.YData=Pha/max(Pha);
    if To == From % workaround for T2 data (TACRange = 0)
        To = To+1;
    end
    h.MI.Phasor_Axes.XLim=[From To];
end

%% Detector Calibration plot update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==7)
    if gcbo == h.MI.Calib_Det % detector selection was changed
        %%% hide plots (only show after calculation)
        h.Plots.Calib_No.Visible = 'off';
        h.Plots.Calib.Visible = 'off';
        h.Plots.Calib_Sel.Visible = 'off';
        h.Plots.Calib_Shift_Smoothed.Visible = 'off';
        %%% clear previous data
        PamMeta.Det_Calib.Hist = [];
        PamMeta.Det_Calib.Shift = [];
        %%% if there is a shift stored for the detector, plot it
        if (numel(UserValues.Detector.Shift) >= h.MI.Calib_Det.Value) && ~isempty(UserValues.Detector.Shift{h.MI.Calib_Det.Value})
            h.Plots.Calib_Shift_New.Visible = 'on';
            h.Plots.Calib_Shift_New.XData = 1:numel(UserValues.Detector.Shift{h.MI.Calib_Det.Value});
            h.Plots.Calib_Shift_New.YData = UserValues.Detector.Shift{h.MI.Calib_Det.Value};
            h.Plots.Calib_Shift_New.Parent.XLim(2) = numel(UserValues.Detector.Shift{h.MI.Calib_Det.Value});
        else
            h.Plots.Calib_Shift_New.Visible = 'off';
        end
    else
        %%% some of the sliders were changed
        if isfield(PamMeta.Det_Calib,'Hist') && ~isempty(PamMeta.Det_Calib.Shift)
            % uncorrected MI histogram (blue)
            h.Plots.Calib_No.YData=sum(PamMeta.Det_Calib.Hist,2)/max(smooth(sum(PamMeta.Det_Calib.Hist,2),5));
            h.Plots.Calib_No.XData=1:FileInfo.MI_Bins;

            % corrected MI histogram (red)
            Cor_Hist=zeros(size(PamMeta.Det_Calib.Hist));
            maxtick = str2double(h.MI.Calib_Single_Max.String);
            h.MI.Calib_Single.Max = maxtick;
            for i=1:maxtick
                Cor_Hist(:,i)=circshift(PamMeta.Det_Calib.Hist(:,i),[-PamMeta.Det_Calib.Shift(i),0]);
            end
            h.Plots.Calib.YData=sum(Cor_Hist,2)/max(smooth(sum(Cor_Hist,2),5));
            h.Plots.Calib.XData=1:FileInfo.MI_Bins;

            % slider
            h.MI.Calib_Single.Value=round(h.MI.Calib_Single.Value);
            MIN=max([1 h.MI.Calib_Single.Value]);
            MAX=min([maxtick, MIN]);%+str2double(h.MI.Calib_Single_Range.String)-1]);
            h.MI.Calib_Single_Text.String=num2str(MIN);

            % interphoton time selected MI histogram (green)
            h.Plots.Calib_Sel.YData=sum(PamMeta.Det_Calib.Hist(:,MIN:MAX),2)/max(smooth(sum(Cor_Hist(:,MIN:MAX),2),5));
            h.Plots.Calib_Sel.XData=1:FileInfo.MI_Bins;

            % smoothing
            smoothing = str2double(h.MI.Calib_Single_Range.String);
            if smoothing > 1
                h.Plots.Calib_Shift_Smoothed.Visible = 'on';
                h.Plots.Calib_Shift_Smoothed.XData = 1:1:numel(PamMeta.Det_Calib.Shift);
                h.Plots.Calib_Shift_Smoothed.YData = smooth(PamMeta.Det_Calib.Shift,smoothing,'rloess');
            else
                h.Plots.Calib_Shift_Smoothed.Visible = 'off';
            end
        end
    end
end

%% Plot Y-axis in log %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this has to be before mode == 5 PIE Patches!
if any(mode==9)
    if strcmp(h.MI.Log.Checked, 'on')
        for i=1:(size(h.MI.Individual,2)/2-1)
            for j=1:size(h.MI.Individual,1)
                h.MI.Individual{j,2*i+1}.YScale='Log';
            end
        end
        h.MI.All_Axes.YScale='Log';
        h.MI.Phasor_Axes.YScale='Log';
        h.MI.Calib_Axes.YScale='Log';
    else
        h.MI.All_Axes.YScale='Linear';
        for i=1:(size(h.MI.Individual,2)/2-1)
            for j=1:size(h.MI.Individual,1)
                h.MI.Individual{j,2*i+1}.YScale='Linear';
            end
        end
        h.MI.Phasor_Axes.YScale='Linear';
        h.MI.Calib_Axes.YScale='Linear';
    end
end

%% Plot Trace Y-axis in log %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this has to be before mode == 5 PIE Patches!
if any(mode==11)
    if strcmp(h.Trace.Log.Checked, 'on')
        h.Trace.Axes.YScale='Log';
        h.Trace.Axes.YLim=[1 h.Trace.Axes.YLim(1,2)];       
    else
        h.Trace.Axes.YScale='Linear';
    end
end

%% PIE Patches %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==5)
    %%% Deletes all PIE Patches
    if isfield(h.Plots,'PIE_Patches')
        for i=1:numel(h.Plots.PIE_Patches)
            if ishandle(h.Plots.PIE_Patches{i})
                delete(h.Plots.PIE_Patches{i})
            end
        end
    end
    h.Plots.PIE_Patches={};
    %%% Goes through every PIE channel
    for i=1:numel(List)
        %%% Reads in PIE setting to save typing
        From=UserValues.PIE.From(i);
        To=UserValues.PIE.To(i);
        Det=UserValues.PIE.Detector(i);
        Rout=UserValues.PIE.Router(i);
        %%% Reduces color saturation
        if i == Sel
            % make selected PIE channel patch a little darker
            Color=(UserValues.PIE.Color(i,:)+2.5*UserValues.Look.Axes)/4;
        else
            Color=(UserValues.PIE.Color(i,:)+3*UserValues.Look.Axes)/4;
        end
        
        %%% Finds detector channels containing PIE channel
        Channel1=find(UserValues.Detector.Det==Det);
        Channel2=find(UserValues.Detector.Rout==Rout);
        Channel=intersect(Channel1,Channel2);
        Valid=[];
        %%% Finds microtime plots containing PIE channel
        for j=Channel(:)'
            Valid=[Valid reshape(find(UserValues.Detector.Plots(:)==j),1,[])];
        end
        %%% For all microtime plots containing PIE channel
        for j=Valid(:)'
            x=mod(j-1,size(UserValues.Detector.Plots,1))+1;
            y=2+2*ceil(j/size(UserValues.Detector.Plots,1))-1;
            %%% Creates a new patch object
            YData=h.MI.Individual{x,y}.YLim;
            h.Plots.PIE_Patches{end+1}=patch([From From To To],[YData(2) YData(1) YData(1) YData(2)],Color,'Parent',h.MI.Individual{x,y},'UserData',i);
            h.Plots.PIE_Patches{end}.HitTest='off';
            uistack(h.Plots.PIE_Patches{end},'bottom');
            %%% Moves selected PIE patch to top (but below curve)
            if i==Sel
                uistack(h.Plots.PIE_Patches{end},'top');
                uistack(h.Plots.PIE_Patches{end},'down',3);
            end
        end
    end
end

%% Trace sections %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==2)
    %%% Calculates the borders of the trace patches
    if h.MT.Trace_Sectioning.Value==1
        
        PamMeta.MT_Patch_Times=linspace(0,FileInfo.MeasurementTime,UserValues.Settings.Pam.MT_Number_Section+1);
    else
        PamMeta.MT_Patch_Times=0:UserValues.Settings.Pam.MT_Time_Section:FileInfo.MeasurementTime;
    end
    %%% Adjusts trace patches number to needed number
    %%% Deletes all patches if none are needed
    if numel(PamMeta.MT_Patch_Times)==1
        if iscell(h.Plots.MT_Patches)
            cellfun(@delete,h.Plots.MT_Patches);
        end
        h.Plots.MT_Patches=[];
        %%% Creates empty entries for patches
    elseif ~isfield(h.Plots,'MT_Patches') || numel(h.Plots.MT_Patches)<(numel(PamMeta.MT_Patch_Times)-1)
        h.Plots.MT_Patches{numel(PamMeta.MT_Patch_Times)-1}=[];
        %%% Deletes unused patches
    elseif numel(h.Plots.MT_Patches)>(numel(PamMeta.MT_Patch_Times)-1)
        Unused=h.Plots.MT_Patches(numel(PamMeta.MT_Patch_Times)+1:end);
        cellfun(@delete,Unused);
        h.Plots.MT_Patches(numel(PamMeta.MT_Patch_Times):end)=[];
    end
    %%% Adjusts selected sections to right size
    if ~isfield(PamMeta,'Selected_MT_Patches') || numel(PamMeta.Selected_MT_Patches)~=(numel(PamMeta.MT_Patch_Times)-1)
        PamMeta.Selected_MT_Patches=ones(numel(PamMeta.MT_Patch_Times)-1,1);
    end
    %%% Creates one used section, if no patches were created
    if isempty(PamMeta.Selected_MT_Patches)
        PamMeta.Selected_MT_Patches=1;
    end
    %%% Reads Y limits of trace plots
    YData=h.Trace.Axes.YLim;
    YData=[YData(2) YData(1) YData(1) YData(2)];
    for i=1:numel(h.Plots.MT_Patches)
        %%% Creates new patch
        if isempty(h.Plots.MT_Patches{i})
            h.Plots.MT_Patches{i}=handle(patch([PamMeta.MT_Patch_Times(i) PamMeta.MT_Patch_Times(i) PamMeta.MT_Patch_Times(i+1) PamMeta.MT_Patch_Times(i+1)],YData,UserValues.Look.Axes,'Parent',h.Trace.Axes));
            h.Plots.MT_Patches{i}.ButtonDownFcn=@MT_Section;
            if UserValues.Settings.Pam.Use_TimeTrace
                h.Plots.MT_Patches{i}.UIContextMenu = h.Trace.Menu;
            end
            %%% Resets old patch
        else
            h.Plots.MT_Patches{i}.XData=[PamMeta.MT_Patch_Times(i) PamMeta.MT_Patch_Times(i) PamMeta.MT_Patch_Times(i+1) PamMeta.MT_Patch_Times(i+1)];
            h.Plots.MT_Patches{i}.YData=YData;
        end
        %%% Changes patch color according to selection
        if PamMeta.Selected_MT_Patches(i)
            h.Plots.MT_Patches{i}.FaceColor=UserValues.Look.Axes;
        else
            h.Plots.MT_Patches{i}.FaceColor=1-UserValues.Look.Axes;
        end
        uistack(h.Plots.MT_Patches{i},'bottom');
    end
end

%% Saves new plots in guidata
guidata(findobj('Tag','Pam'),h)
h.Progress.Text.String = FileInfo.FileName{1};
h.Progress.Axes.Color=UserValues.Look.Control;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Callback functions of PIE list and uicontextmenues  %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "+"-Key or Add menu: Generate new PIE channel
%%% "-"-Key, "del"-Key or Delete menu: Deletes first selected PIE channel
%%% "c"-Key or Color menu: Opend menu to choose channel color
%%% "leftarrow"-Key: Moves first selected channel up
%%% "rigtharrow"-Key: Moves first selected channel down
%%% Export_Raw_Total menu: Exports MI and MT as one vector each into workspace
%%% Export_Raw_File menu: Exports MI and MT for each file in a cell into workspace
%%% Export_Image_Total menu: Plots image and exports it into workspace
%%% Export_Image_File menu: Exports Pixels x Pixels x FileNumber into workspace
function PIE_List_Functions(obj,ed)
global UserValues FileInfo PamMeta
h = guidata(findobj('Tag','Pam'));

%% Determines which buttons was pressed, if function was not called via key press
if ~strcmp(ed.EventName,'KeyPress')
    if obj == h.PIE.Add
        e.Key='add';
    elseif obj == h.PIE.Delete
        e.Key='delete';
    elseif obj == h.PIE.Color;
        e.Key='c';
    elseif obj == h.PIE.Export_Raw_Total
        e.Key='Export_Raw_Total';
    elseif obj == h.PIE.Export_Raw_File
        e.Key='Export_Raw_File';
    elseif obj == h.PIE.Export_Image_Total
        e.Key='Export_Image_Total';
    elseif obj == h.PIE.Export_Image_File
        e.Key='Export_Image_File';
    elseif obj == h.PIE.Export_Image_Tiff
        e.Key='Export_Image_Tiff';
    elseif obj == h.PIE.Export_MicrotimePattern
        e.Key='Export_MicrotimePattern';
    elseif obj == h.PIE.Combine
        e.Key='Combine';
    elseif obj == h.PIE.Select
        e.Key='PIE_Select';
    else
        e.Key='';
    end
else
    e.Key=ed.Key;
end
%%% Find selected channels
Sel=h.PIE.List.Value;

%% Determines which Key/Button was pressed
switch e.Key
    case 'add' %%% Add button or "+"_Key
        %% Generates a new PIE channel with standard values
        UserValues.PIE.Color(end+1,:)=[0 0 1];
        UserValues.PIE.Combined{end+1}=[];
        UserValues.PIE.Detector(end+1)=1;
        UserValues.PIE.Router(end+1)=1;
        UserValues.PIE.From(end+1)=1;
        UserValues.PIE.To(end+1)=4096;
        UserValues.PIE.Name{end+1}='PIE Channel';
        UserValues.PIE.Duty_Cycle(end+1)=0;
        UserValues.PIE.IRF{end+1} = zeros(1,4096);
        UserValues.PIE.ScatterPattern{end+1} = zeros(1,4096);
        UserValues.PIE.Background(end+1)=0;
        UserValues.PIE.PhasorReference{end+1} = zeros(1,4096);
        UserValues.PIE.DonorOnlyReference{end+1} = zeros(1,4096);
        UserValues.PIE.PhasorReferenceLifetime(end+1) = 0;
        %%% Reset Correlation Table Data Matrix
        cor_sel = UserValues.Settings.Pam.Cor_Selection;
        cor_sel(end+1,:) = false; cor_sel(:,end+1) = false;
        UserValues.Settings.Pam.Cor_Selection = cor_sel;%false(numel(UserValues.PIE.Name)+1);
        %%% Updates Pam meta data; input 3 should be empty to improve speed
        %%% Input 4 is the new channel
        Update_to_UserValues
        Update_Data([],[],[],numel(UserValues.PIE.Name));
        Update_Display([],[],0);
        %%% Updates correlation table
        Update_Cor_Table(obj);
        %%% Add channel to Export table
        h.Export.PIE.RowName = [UserValues.PIE.Name, {'All'}];
        h.Export.PIE.Data(end+1) = h.Export.PIE.Data(end);
    case {'delete';'subtract'} %%% Delete button or "del"-Key or "-"-Key
        %% Deletes selected channels
        %%% in UserValues
        UserValues.PIE.Color(Sel,:)=[];
        UserValues.PIE.Combined(Sel)=[];
        UserValues.PIE.Detector(Sel)=[];
        UserValues.PIE.Router(Sel)=[];
        UserValues.PIE.From(Sel)=[];
        UserValues.PIE.To(Sel)=[];
        UserValues.PIE.Name(Sel)=[];
        UserValues.PIE.Duty_Cycle(Sel)=[];
        UserValues.PIE.IRF(Sel) = [];
        UserValues.PIE.ScatterPattern(Sel) = [];
        UserValues.PIE.Background(Sel) = [];
        %%% Reset Correlation Table Data Matrix
        cor_sel = UserValues.Settings.Pam.Cor_Selection;
        cor_sel(:,Sel) = []; cor_sel(Sel,:) = [];
        UserValues.Settings.Pam.Cor_Selection = cor_sel;%false(numel(UserValues.PIE.Name)+1);
        %%% in Pam meta data
        PamMeta.Trace(Sel)=[];
        PamMeta.Image(Sel)=[];
        PamMeta.Lifetime(Sel)=[];
        PamMeta.Info(Sel)=[];
        PamMeta.PCH(Sel) = [];
        PamMeta.BinsPCH(Sel) = [];
        PamMeta.TracePCH(Sel) = [];
        %%% Removes deleted PIE channel from all combined channels
        Combined=find(UserValues.PIE.Detector==0);
        new=0;
        for i=Combined
            if ~isempty(intersect(UserValues.PIE.Combined{i},Sel))
                UserValues.PIE.Combined{i}=setdiff(UserValues.PIE.Combined{i},Sel);
                new=1;
            end
            %%% Update reference to PIE channels
            for j = 1:numel(UserValues.PIE.Combined{i})
                if UserValues.PIE.Combined{i}(j) > Sel
                    UserValues.PIE.Combined{i}(j) = UserValues.PIE.Combined{i}(j) - 1;
                end
            end
            %%% update name
            UserValues.PIE.Name{i}='Comb.: ';
            for j=UserValues.PIE.Combined{i};
                UserValues.PIE.Name{i}=[UserValues.PIE.Name{i} UserValues.PIE.Name{j} '+'];
            end
            UserValues.PIE.Name{i}(end)=[];
        end
        Update_to_UserValues
        %%% Updates only combined channels, if any was changed
        if new
            Update_Data([],[],[],[]);
        end
        
        %%% Updates Plots
        Update_Display([],[],1:5)
        %%% Updates correlation table
        Update_Cor_Table(obj);
        %%% Remove channels in Export table
        h.Export.PIE.RowName = [UserValues.PIE.Name, {'All'}];
        h.Export.PIE.Data(Sel) = [];
    case 'c' %%% Changes color of selected channels
        if ~isdeployed
            %%% Opens menu to choose color
            color=uisetcolor;
        elseif isdeployed %%% uisetcolor dialog does not work in compiled application
            color = color_setter(mean(UserValues.PIE.Color(Sel,:),1)); % open dialog to input color
        end
         %%% Checks, if color was selected
        if numel(color)==3
            for i=Sel
                UserValues.PIE.Color(i,:)=color;
            end
        end
        %%% Updates Plots
        Update_Display([],[],1:5)
    case 'leftarrow' %%% Moves first selected channel up
        if Sel(1)>1
            %%% Shifts UserValues
            UserValues.PIE.Color([Sel(1)-1 Sel(1)],:)=UserValues.PIE.Color([Sel(1) Sel(1)-1],:);
            UserValues.PIE.Combined([Sel(1)-1 Sel(1)])=UserValues.PIE.Combined([Sel(1) Sel(1)-1]);
            UserValues.PIE.Detector([Sel(1)-1 Sel(1)])=UserValues.PIE.Detector([Sel(1) Sel(1)-1]);
            UserValues.PIE.Router([Sel(1)-1 Sel(1)])=UserValues.PIE.Router([Sel(1) Sel(1)-1]);
            UserValues.PIE.From([Sel(1)-1 Sel(1)])=UserValues.PIE.From([Sel(1) Sel(1)-1]);
            UserValues.PIE.To([Sel(1)-1 Sel(1)])=UserValues.PIE.To([Sel(1) Sel(1)-1]);
            UserValues.PIE.Name([Sel(1)-1 Sel(1)])=UserValues.PIE.Name([Sel(1) Sel(1)-1]);
            UserValues.PIE.Duty_Cycle([Sel(1)-1 Sel(1)])=UserValues.PIE.Duty_Cycle([Sel(1) Sel(1)-1]);
            %%% Reset Correlation Table Data Matrix
            UserValues.Settings.Pam.Cor_Selection = false(numel(UserValues.PIE.Name)+1);
            %%% Shifts Pam meta data
            PamMeta.Trace([Sel(1)-1 Sel(1)])=PamMeta.Trace([Sel(1) Sel(1)-1]);
            PamMeta.Image([Sel(1)-1 Sel(1)])=PamMeta.Image([Sel(1) Sel(1)-1]);
            PamMeta.Lifetime([Sel(1)-1 Sel(1)])=PamMeta.Lifetime([Sel(1) Sel(1)-1]);
            PamMeta.Info([Sel(1)-1 Sel(1)])=PamMeta.Info([Sel(1) Sel(1)-1]);
            PamMeta.PCH([Sel(1)-1 Sel(1)])=PamMeta.PCH([Sel(1) Sel(1)-1]);
            PamMeta.BinsPCH([Sel(1)-1 Sel(1)])=PamMeta.BinsPCH([Sel(1) Sel(1)-1]);
            PamMeta.TracePCH([Sel(1)-1 Sel(1)])=PamMeta.TracePCH([Sel(1) Sel(1)-1]);
            %%% Selects moved channel again
            h.PIE.List.Value(1)=h.PIE.List.Value(1)-1;
            
            %%% Updates combined channels to new position
            Combined=find(UserValues.PIE.Detector==0);
            for i=Combined
                A = UserValues.PIE.Combined{i} == Sel(1);
                B = UserValues.PIE.Combined{i} == Sel(1)-1;
                UserValues.PIE.Combined{i}(A) = Sel(1)-1;
                UserValues.PIE.Combined{i}(B) = Sel(1);
            end
            
            %%% Updates plots
            Update_Display([],[],1);
            %%% Updates correlation table
            Update_Cor_Table(obj);
            %%% Move channels in Export table
            h.Export.PIE.RowName = [UserValues.PIE.Name, {'All'}];
            h.Export.PIE.Data([Sel(1)-1 Sel(1)]) = h.Export.PIE.Data([Sel(1) Sel(1)-1]);
        end
    case 'rightarrow' %%% Moves first selected channel down
        if Sel(1)<numel(h.PIE.List.String);
            %%% Shifts UserValues
            UserValues.PIE.Color([Sel(1) Sel(1)+1],:)=UserValues.PIE.Color([Sel(1)+1 Sel(1)],:);
            UserValues.PIE.Combined([Sel(1) Sel(1)+1])=UserValues.PIE.Combined([Sel(1)+1 Sel(1)]);
            UserValues.PIE.Detector([Sel(1) Sel(1)+1])=UserValues.PIE.Detector([Sel(1)+1 Sel(1)]);
            UserValues.PIE.Router([Sel(1) Sel(1)+1])=UserValues.PIE.Router([Sel(1)+1 Sel(1)]);
            UserValues.PIE.From([Sel(1) Sel(1)+1])=UserValues.PIE.From([Sel(1)+1 Sel(1)]);
            UserValues.PIE.To([Sel(1) Sel(1)+1])=UserValues.PIE.To([Sel(1)+1 Sel(1)]);
            UserValues.PIE.Name([Sel(1) Sel(1)+1])=UserValues.PIE.Name([Sel(1)+1 Sel(1)]);
            UserValues.PIE.Duty_Cycle([Sel(1) Sel(1)+1])=UserValues.PIE.Duty_Cycle([Sel(1)+1 Sel(1)]);
            %%% Reset Correlation Table Data Matrix
            UserValues.Settings.Pam.Cor_Selection = false(numel(UserValues.PIE.Name)+1);
            %%% Shifts Pam meta data
            PamMeta.Trace([Sel(1) Sel(1)+1])=PamMeta.Trace([Sel(1)+1 Sel(1)]);
            PamMeta.Image([Sel(1) Sel(1)+1])=PamMeta.Image([Sel(1)+1 Sel(1)]);
            PamMeta.Lifetime([Sel(1) Sel(1)+1])=PamMeta.Lifetime([Sel(1)+1 Sel(1)]);
            PamMeta.Info([Sel(1) Sel(1)+1])=PamMeta.Info([Sel(1)+1 Sel(1)]);
            PamMeta.PCH([Sel(1) Sel(1)+1])=PamMeta.PCH([Sel(1)+1 Sel(1)]);
            PamMeta.BinsPCH([Sel(1) Sel(1)+1])=PamMeta.BinsPCH([Sel(1)+1 Sel(1)]);
            PamMeta.TracePCH([Sel(1) Sel(1)+1])=PamMeta.TracePCH([Sel(1)+1 Sel(1)]);
            %%% Selects moved channel again
            h.PIE.List.Value(1)=h.PIE.List.Value(1)+1;
            
            %%% Updates combined channels to new position
            Combined=find(UserValues.PIE.Detector==0);
            for i=Combined
                A = UserValues.PIE.Combined{i} == Sel(1);
                B = UserValues.PIE.Combined{i} == Sel(1)+1;
                UserValues.PIE.Combined{i}(A) = Sel(1)+1;
                UserValues.PIE.Combined{i}(B) = Sel(1);
            end
            
            %%% Updates plots
            Update_Display([],[],1);
            %%% Updates correlation table
            Update_Cor_Table(obj);
            %%% Move channels in Export table
            h.Export.PIE.RowName = [UserValues.PIE.Name, {'All'}];
            h.Export.PIE.Data([Sel(1) Sel(1)+1]) = h.Export.PIE.Data([Sel(1)+1 Sel(1)]);
        end
    case {'Export_Raw_Total',... %%% Exports macrotime and microtime as one vector for each PIE channel
            'Export_Raw_File',... %%% Exports macrotime and microtime as a cell for each PIE channelPam_Export([],e,Sel);
            'Export_Image_Total',... %%% Plots image and exports it into workspace
            'Export_Image_File',... %%% Exports image stack into workspace
            'Export_Image_Tiff',...
            'Export_MicrotimePattern'} %%% Exports image stack into workspace
        Pam_Export([],e,Sel);
    case 'Combine' %%% Generates a combined PIE channel from existing PIE channels
        %%% Does not combine single
        if numel(Sel)>1 && isempty(cell2mat(UserValues.PIE.Combined(Sel)))
            
            color = [0,0,0];
            for i = Sel;
                color = color + UserValues.PIE.Color(i,:);
            end
            UserValues.PIE.Color(end+1,:)=color./numel(Sel);
            UserValues.PIE.Combined{end+1}=Sel;
            UserValues.PIE.Detector(end+1)=0;
            UserValues.PIE.Router(end+1)=0;
            UserValues.PIE.From(end+1)=0;
            UserValues.PIE.To(end+1)=0;
            UserValues.PIE.Duty_Cycle(end+1)=0;
            UserValues.PIE.IRF{end+1} = [];
            UserValues.PIE.ScatterPattern{end+1} = [];
            UserValues.PIE.Background(end+1) = 0;
            UserValues.PIE.Name{end+1}='Comb.: ';
            for i=Sel;
                UserValues.PIE.Name{end}=[UserValues.PIE.Name{end} UserValues.PIE.Name{i} '+'];
            end
            UserValues.PIE.Name{end}(end)=[];
            UserValues.PIE.Duty_Cycle(end+1)=0;
            %%% Reset Correlation Table Data Matrix
            cor_sel = UserValues.Settings.Pam.Cor_Selection;
            cor_sel(end+1,:) = false; cor_sel(:,end+1) = false;
            UserValues.Settings.Pam.Cor_Selection = cor_sel;
            Update_to_UserValues;
            Update_Data([],[],[],[]);
            Update_Display([],[],0);
            %%% Updates correlation table
            Update_Cor_Table(obj);
            %%% Add channel to Export table
            h.Export.PIE.RowName = [UserValues.PIE.Name, {'All'}];
            h.Export.PIE.Data(end+1) = h.Export.PIE.Data(end);
        end
    case 'PIE_Select' %%% Enable manual selection
        [x,~] = ginput(2);
        x= sort(x);
        %%% Read out which Axis was clicked to get the Detector/Routing
        Clicked_Axis = gca;
        Axes_Handles = cell(size(UserValues.Detector.Plots,1),size(UserValues.Detector.Plots,2));
        for i = 1:size(UserValues.Detector.Plots,1)
            for j = 1:size(UserValues.Detector.Plots,2)
                Axes_Handles{i,j} = h.MI.Individual{i,2*j+1};
            end
        end
        Clicked_Plot = [];
        for i = 1:size(UserValues.Detector.Plots,1)
            for j = 1:size(UserValues.Detector.Plots,2)
                if  Axes_Handles{i,j} == Clicked_Axis
                    Clicked_Plot = UserValues.Detector.Plots(i,j);
                end
            end
        end
        
        %%% Update UserValues
        if ~isempty(Clicked_Plot)
            UserValues.PIE.Detector(Sel)=UserValues.Detector.Det(Clicked_Plot);
            UserValues.PIE.Router(Sel)=UserValues.Detector.Rout(Clicked_Plot);
            UserValues.PIE.From(Sel)=round(x(1));
            UserValues.PIE.To(Sel)=round(x(2));
            %%% Updates Pam meta data; input 3 should be empty to improve speed
            %%% Input 4 is the new channel
            Update_to_UserValues
            Update_Data([],[],[],numel(UserValues.PIE.Name));
            Update_Display([],[],0);
        end
    otherwise
        e.Key=[];
end
%% Only saves user values, if one of the function was used
if ~isempty(e.Key)
    h.Progress.Text.String = FileInfo.FileName{1};
    h.Progress.Axes.Color=UserValues.Look.Control;
    if ~strfind(e.Key,'Export')
        Update_to_UserValues; %%% Updates CorrTable and BurstGUI
    end
    LSUserValues(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes PIE channel settings and saves them in the profile %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_PIE_Channels(obj,~)
global UserValues FileInfo
h = guidata(findobj('Tag','Pam'));

Sel=h.PIE.List.Value(1);
if numel(Sel)==1 && isempty(UserValues.PIE.Combined{Sel})
    %%% Updates PIE Channel name
    if obj == h.PIE.Name
        UserValues.PIE.Name{Sel}=h.PIE.Name.String;
        %%% Updates correlation table
        Update_Cor_Table(obj);
        %%% Rename channels in Export table
        h.Export.PIE.RowName = [UserValues.PIE.Name, {'All'}];
        %%% Update names in combined channels
        Combined=find(UserValues.PIE.Detector==0);
        for i=Combined
            %%% update name
            UserValues.PIE.Name{i}='Comb.: ';
            for j=UserValues.PIE.Combined{i};
                UserValues.PIE.Name{i}=[UserValues.PIE.Name{i} UserValues.PIE.Name{j} '+'];
            end
            UserValues.PIE.Name{i}(end)=[];
        end
    elseif obj == h.PIE.DetectionChannel
        %%% Updates PIE detector and routing
        UserValues.PIE.Detector(Sel)=UserValues.Detector.Det(h.PIE.DetectionChannel.Value);
        UserValues.PIE.Router(Sel)=UserValues.Detector.Rout(h.PIE.DetectionChannel.Value);
        %%% Updates PIE detector
        %elseif obj == h.PIE.Detector
        %    UserValues.PIE.Detector(Sel)=str2double(h.PIE.Detector.String);
        %%% Updates PIE routing
        %elseif obj == h.PIE.Routing
        %    UserValues.PIE.Router(Sel)=str2double(h.PIE.Routing.String);
        %%% Updates PIE mictrotime minimum
    elseif obj == h.PIE.From
        UserValues.PIE.From(Sel)=max([str2double(h.PIE.From.String),1]);
        obj.String = num2str(UserValues.PIE.From(Sel));
        %%% Updates PIE microtime maximum
    elseif obj == h.PIE.To
        UserValues.PIE.To(Sel)=min([str2double(h.PIE.To.String),FileInfo.MI_Bins]);
        obj.String = num2str(UserValues.PIE.To(Sel));
    end
    LSUserValues(1);
    %%% Updates pam meta data; input 3 should be empty; input 4 is the
    %%% selected PIE channel
    if obj ~= h.PIE.Name
        Update_Data([],[],[],Sel);
        Update_Display([],[],0);
        %%% Only updates plots, if just the name was changed
    else
        Update_Display([],[],1);
    end
end
Update_to_UserValues; %%% Updates CorrTable and BurstGUI

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Selects/Unselects macrotime sections  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MT_Section(obj,eventData)
global PamMeta
h = guidata(findobj('Tag','Pam'));
if eventData.Button == 1 %%% only accept left-click
    for i=1:numel(h.Plots.MT_Patches)
        if obj==h.Plots.MT_Patches{i}
            break;
        end
    end
    PamMeta.Selected_MT_Patches(i)=abs(PamMeta.Selected_MT_Patches(i)-1);
    Update_Display([],[],2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Callback functions of metadata table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_MetaData(~,e)
global UserValues
MetaDataList = {'ExcitationWavelengths';'ExcitationPower';'DyeNames';'BufferName';'SampleName';'User';'Comment'};
UserValues.MetaData.(MetaDataList{e.Indices(1),1}) = e.NewData;
LSUserValues(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Callback functions of microtime channel list and UIContextmenues  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "+"-Key or Add menu: Generate new detection channel
%%% "-"-Key, "del"-Key or Delete menu: Deletes first selected detection channel
%%% "c"-Key or Color menu: Opens menu to choose channel color
%%% "n"-Key: Opens dialog menu to change Channel name
function MI_Channels_Functions(obj,ed)
global UserValues PamMeta
h = guidata(findobj('Tag','Pam'));


if obj == h.MI.Auto
    switch obj.Checked
        case 'off'
            obj.Checked = 'on';
        case 'on'
            obj.Checked = 'off';
    end
    UserValues.Detector.Auto = obj.Checked;
    LSUserValues(1);
    return;
end
%% Check what object called the function
Update = true;
action = '';
if obj == h.MI.Add
    action = 'add';
    UserValues.Detector.Det(end+1)=1;
    UserValues.Detector.Rout(end+1)=1;
    UserValues.Detector.Name{end+1}='New Channel';
    UserValues.Detector.Color(end+1,:)=[1 0 0];   %#ok<ST2NM>
    UserValues.Detector.Filter{end+1} = '500/25';
    UserValues.Detector.Pol{end+1} = 'none';
    UserValues.Detector.BS{end+1} = 'none';
    UserValues.Detector.enabled{end+1} = 'on';
    UserValues.Detector.Shift{end+1}=[];
    UserValues.Phasor.Reference(end+1,end)=0;
end

if obj == h.MI.Channels_List
    %%% disable callback
    h.MI.Channels_List.CellEditCallback = [];
    h.MI.Channels_List.CellSelectionCallback = [];
    if strcmp(ed.EventName,'CellEdit')
        Sel=ed.Indices(1);
        %%% Determine which cell was edited
        switch ed.Indices(2)
            case 1 %%% Name was clicked
                UserValues.Detector.Name{Sel} = ed.NewData;
            case 2 %%% Detector was changed
                UserValues.Detector.Det(Sel) = ed.NewData;
                for i=1:numel(UserValues.PIE.Detector)
                   if UserValues.PIE.Detector(i)==ed.PreviousData && UserValues.PIE.Router(i)==ed.Source.Data{Sel,3}
                       UserValues.PIE.Detector(i)=ed.NewData;
                   end
                end
                
                action = 'detector';
            case 3 %%% Rout was changed
                UserValues.Detector.Rout(Sel) = ed.NewData;
                for i=1:numel(UserValues.PIE.Detector)
                   if UserValues.PIE.Router(i)==ed.PreviousData && UserValues.PIE.Detector(i)==ed.Source.Data{Sel,2}
                       UserValues.PIE.Router(i)=ed.NewData;
                   end
                end
                action = 'detector';
            case 5 %%% Filter was changed
                UserValues.Detector.Filter{Sel} = ed.NewData;
            case 6 %%% Pol was changed
                UserValues.Detector.Pol{Sel} = ed.NewData;
            case 7 %%% BS was changed
                UserValues.Detector.BS{Sel} = ed.NewData;
            case 8 %%% enabled was changed
                UserValues.Detector.enabled{Sel} = ed.NewData;
            case 9 %%% Delete detector
                %%% check if any PIE channels used this detection channel
                if any( (UserValues.PIE.Detector == UserValues.Detector.Det(Sel)) & (UserValues.PIE.Router == UserValues.Detector.Rout(Sel)))
                    %%% reset to first detection channel
                    chans = find((UserValues.PIE.Detector == UserValues.Detector.Det(Sel)) & (UserValues.PIE.Router == UserValues.Detector.Rout(Sel)));
                    for p = chans
                        UserValues.PIE.Detector(p) = UserValues.Detector.Det(1);
                        UserValues.PIE.Router(p) = UserValues.Detector.Rout(1);
                    end
                    %%% update
                    Update_Display([],[],0)
                end
                
                h.MI.Channels_List.Data(Sel,:)=[];
                %% Deletes all selected microtimechannels
                UserValues.Detector.Det(Sel)=[];
                UserValues.Detector.Rout(Sel)=[];
                UserValues.Detector.Name(Sel)=[];
                UserValues.Detector.Color(Sel,:)=[];
                UserValues.Detector.Filter(Sel)=[];
                UserValues.Detector.Pol(Sel)=[];
                UserValues.Detector.BS(Sel)=[];
                UserValues.Detector.enabled(Sel)=[];
                try
                    UserValues.Detector.Shift(Sel)=[];
                end
                try
                    PamMeta.MI_Hist(Sel)=[];
                end
                %%% Saves new tabs in guidata
                guidata(h.Pam,h)
        end
    end
    
    if strcmp(ed.EventName,'CellSelection')
        if ~isempty(ed.Indices)
            Sel=ed.Indices(1);
            %%% Determine which cell was edited
            switch ed.Indices(2)
                
                case 4 %%% Color was clicked
                    if ~isdeployed
                        NewColor = uisetcolor;
                        if size(NewColor) == 1
                            return;
                        end
                    elseif isdeployed %%% uisetcolor dialog does not work in compiled application
                        NewColor = color_setter(UserValues.Detector.Color(Sel,:)); % open dialog to input color
                    end
                    UserValues.Detector.Color(Sel,:) = NewColor;
                    %%% Update Color of Name also
                    Hex_color = dec2hex(round(UserValues.Detector.Color(Sel,:)*255))';
                    h.MI.Channels_List.Data{Sel,4} = ['<HTML><FONT color=#' Hex_color(:)' '>' num2str(UserValues.Detector.Color(Sel,:)) '</Font></html>'];
                otherwise
                    Update = false;
            end
        end
    end
end
if Update
    %% Update
    LSUserValues(1);
    %%% Updates channels
    Update_Detector_Channels([],[],0:2)
    %%% Updates plots
    if strcmp(action,'add') || strcmp(action,'delete') || strcmp(action,'detector')
        Update_Data([],[],0,0);
    end
    %%% reenable callbacks
    Update_Display([],[],4:5);
    %%% update detection channels list
    h.PIE.DetectionChannel.String = color_string(UserValues.Detector.Name,UserValues.Detector.Color);
end
h.MI.Channels_List.CellEditCallback = @MI_Channels_Functions;
h.MI.Channels_List.CellSelectionCallback = @MI_Channels_Functions;




function MI_Channels_Functions_old(obj,ed)
global UserValues PamMeta
h = guidata(findobj('Tag','Pam'));
%% Determines which buttons was pressed, if function was not called via key press
if ~strcmp(ed.EventName,'KeyPress')
    if obj == h.MI.Add
        e.Key='add';
    elseif obj == h.MI.Delete
        e.Key='delete';
    elseif obj == h.MI.Color;
        e.Key='c';
    elseif obj == h.MI.Name;
        e.Key='n';
    else
        e.Key='';
    end
else
    e.Key=ed.Key;
end
Sel=h.MI.Channels_List.Value;
%% Determines which Key/Button was pressed
switch e.Key
    case 'add' %% Created a new microtime channel as specified in input dialog
        Input=inputdlg({'Enter detector:'; 'Enter routing:'; 'Enter Detector Name:'; 'Enter RGB color'},'Create new detector/routing pair',1,{'1'; '1'; '1';'1 1 1'});
        if ~isempty(Input)
            UserValues.Detector.Det(end+1)=str2double(Input{1});
            UserValues.Detector.Rout(end+1)=str2double(Input{2});
            UserValues.Detector.Name{end+1}=Input{3};
            UserValues.Detector.Color(end+1,:)=str2num(Input{4});   %#ok<ST2NM>
            UserValues.Detector.Shift{end+1}=[];
            UserValues.Phasor.Reference(end+1,end)=0;
        end
    case 'delete'
        %% Deletes all selected microtimechannels
        UserValues.Detector.Det(Sel)=[];
        UserValues.Detector.Rout(Sel)=[];
        UserValues.Detector.Name(Sel)=[];
        UserValues.Detector.Color(Sel,:)=[];
        try
            UserValues.Detector.Shift(Sel)=[];
        end
        PamMeta.MI_Hist(Sel)=[];
        %%% Updates List
        h.MI.Channels_List.String(Sel)=[];
        %%% Removes nonexistent selected channels
        h.MI.Channels_List.Value(h.MI.Channels_List.Value>numel(UserValues.Detector.Det))=[];
        %%% Selects first channel, if none is selected
        if isempty(h.MI.Channels_List.Value)
            h.MI.Channels_List.Value=1;
        end
        %%% Saves new tabs in guidata
        guidata(h.Pam,h)
    case 'c' %% Selects new color for microtime channel
        if ~isdeployed
            %%% Opens menu to choose color
            color=uisetcolor;
        elseif isdeployed %%% uisetcolor dialog does not work in compiled application
            color = color_setter(); % open dialog to input color
        end
        %%% Checks, if color was selected
        if numel(color)==3
            for i=Sel
                UserValues.Detector.Color(i,:)=color;
            end
        end
    case 'n' %% Renames detector channel
        UserValues.Detector.Name{Sel(1)}=cell2mat(inputdlg('Enter detector name:'));
    otherwise
        e.Key='';
end
%% Updates, if one of the function was used
if ~isempty(e.Key)
    LSUserValues(1);
    %%% Updates channels
    Update_Detector_Channels([],[],0:2)
    if strcmp(e.Key,'add') || strcmp(e.Key,'delete')
        Update_Data([],[],0,0);
    end
    %%% Updates plots
    Update_Display([],[],4:5);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for updating microtime channels list  %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Detector_Channels(~,~,mode)
global UserValues FileInfo

Look = UserValues.Look;
h = guidata(findobj('Tag','Pam'));

%% Updates number of microtime tabs and plots
if any(mode==0)
    NTabs=str2double(h.MI.NTabs.String);
    NPlots=str2double(h.MI.NPlots.String);
    %%% Updates plot selection lists
    for i=1:NTabs
        for j=1:NPlots
            try
                UserValues.Detector.Plots(i,j)=h.MI.Individual{i,2*(1+j)}.Value;
            catch
                UserValues.Detector.Plots(i,j)=1;
            end
            
        end
    end
    %%% Trims/Extends Microtimes plots to correct size
    if size(UserValues.Detector.Plots,1)<NTabs || size(UserValues.Detector.Plots,2)<NPlots
        UserValues.Detector.Plots(NTabs,NPlots)=1;
    end
    if size(UserValues.Detector.Plots,1)>NTabs
        UserValues.Detector.Plots=UserValues.Detector.Plots(1:NTabs,:);
    end
    if size(UserValues.Detector.Plots,2)>NPlots
        UserValues.Detector.Plots=UserValues.Detector.Plots(:,1:NPlots);
    end
    %%% Sets microtime plots to valid detectors
    UserValues.Detector.Plots(UserValues.Detector.Plots<0 | UserValues.Detector.Plots>numel(UserValues.Detector.Name))=1;
    %%% Save UserValues
    LSUserValues(1);
else
    NTabs=size(UserValues.Detector.Plots,1);
    NPlots=size(UserValues.Detector.Plots,2);
    h.MI.NTabs.String=num2str(NTabs);
    h.MI.NPlots.String=num2str(NPlots);
end
%% Creates individual microtime channels
if any(mode==1)
    %%% Deletes existing microtime tabs
    if isfield(h.MI, 'Individual')
        cellfun(@delete,h.MI.Individual(:,1))
    end
    h.MI.Individual=cell(NTabs,2*NPlots+2);
    h.Plots.MI_Ind=cell(NTabs,NPlots);
    for i=1:NTabs %%% Creates set number of tabs
        %%% Individual microtime tabs
        h.MI.Individual{i,1} = uitab(...
            'Parent',h.MI.Tabs,...
            'Title',[num2str(NPlots*(i-1)+1) '-' num2str(i*NPlots)]);
        %%% Individual microtime panels
        h.MI.Individual{i,2} = uibuttongroup(...
            'Parent',h.MI.Individual{i}(1),...
            'Units','normalized',...
            'BackgroundColor', UserValues.Look.Back,...
            'ForegroundColor', UserValues.Look.Fore,...
            'HighlightColor', UserValues.Look.Control,...
            'ShadowColor', UserValues.Look.Shadow,...
            'Position',[0 0 1 1]);
        for j=1:NPlots %%% Creates set number of plots per tab
            %%% Individual microtime plots
            h.MI.Individual{i,2*(1+j)-1} = axes(...
                'Parent',h.MI.Individual{i,2},...
                'Units','normalized',...
                'NextPlot','add',...
                'UIContextMenu',h.MI.Menu_Individual,...
                'XColor',UserValues.Look.Fore,...
                'YColor',UserValues.Look.Fore,...
                'LineWidth', Look.AxWidth,...
                'Position',[0.09 0.065+(j-1)*(0.98/NPlots) 0.89 0.98/NPlots-0.065],...
                'Box','off',...
                'TickDir','out');
            h.MI.Individual{i,2*(1+j)-1}.XLabel.String = 'TCSPC channel';
            h.MI.Individual{i,2*(1+j)-1}.YLabel.String = 'Counts';
            h.MI.Individual{i,2*(1+j)-1}.YLabel.Color = UserValues.Look.Fore;
            h.MI.Individual{i,2*(1+j)-1}.XLabel.Color = UserValues.Look.Fore;
            if FileInfo.MI_Bins == 1 % T2 workaround
                h.MI.Individual{i,2*(1+j)-1}.XLim=[0 FileInfo.MI_Bins];
            else
                h.MI.Individual{i,2*(1+j)-1}.XLim=[1 FileInfo.MI_Bins];
            end
            %%% Individual microtime popup for channel selection
            h.MI.Individual{i,2*(1+j)} = uicontrol(...
                'Parent',h.MI.Individual{i,2},...
                'Style','popupmenu',...
                'Units','normalized',...
                'FontSize',12,...
                'String',UserValues.Detector.Name,...
                'BackgroundColor', UserValues.Look.Control,...
                'ForegroundColor', UserValues.Look.Fore,...
                'Value',UserValues.Detector.Plots(i,j),...
                'Callback',{@Update_Detector_Channels,0},...
                'Position',[0.78 j*(0.98/NPlots)-0.03 0.2 0.03]);
            if ismac %%% Change colors for readability on Mac
                h.MI.Individual{i,2*(1+j)}.BackgroundColor = UserValues.Look.Fore;
                h.MI.Individual{i,2*(1+j)}.ForegroundColor = UserValues.Look.Back;
            end
            h.Plots.MI_Ind{i,j}=line(...
                'Parent',h.MI.Individual{i,2*(1+j)-1},...
                'Color',UserValues.Detector.Color(UserValues.Detector.Plots(i,j),:),...
                'XData',[0 1],...
                'YData',[0 0]);
            h.Plots.MI_Ind_Scat{i,j}=line(...
                'Parent',h.MI.Individual{i,2*(1+j)-1},...
                'Color',[0.5 0.5 0.5],...
                'LineStyle',':',...
                'XData',[0 1],...
                'YData',[0 0],...
                'Visible','off');
            h.Plots.MI_Ind_IRF{i,j}=line(...
                'Parent',h.MI.Individual{i,2*(1+j)-1},...
                'Color','k',...
                'LineStyle',':',...
                'XData',[0 1],...
                'YData',[0 0],...
                'Visible','off');
        end
    end
end
%% Updates detector list
if any(mode==2)
    %     List=cell(numel(UserValues.Detector.Name),1);
    %     for i=1:numel(List)
    %         %%% Calculates Hex code for detector color
    %         Hex_color=dec2hex(round(UserValues.Detector.Color(i,:)*255))';
    %         List{i}=['<HTML><FONT color=#' Hex_color(:)' '>'... Sets entry color in HTML
    %             UserValues.Detector.Name{i}... Detector Name
    %             ': Detector: ' num2str(UserValues.Detector.Det(i))... Detector Number
    %             ' / Routing: ' num2str(UserValues.Detector.Rout(i))... Routing Number
    %             ' enabled </Font></html>'];
    %     end
    %     h.MI.Channels_List.String=List;
    %%% Update Table
    Data = cell(numel(UserValues.Detector.Name),8);
    for i = 1:numel(UserValues.Detector.Name)
        Hex_color=dec2hex(round(UserValues.Detector.Color(i,:)*255))';
        Data{i,1} = UserValues.Detector.Name{i};
        Data{i,2} = UserValues.Detector.Det(i);
        Data{i,3} = UserValues.Detector.Rout(i);
        Data{i,4} = ['<HTML><FONT color=#' Hex_color(:)' '>' num2str(UserValues.Detector.Color(i,:)) '</Font></html>'];
        Data{i,5} = UserValues.Detector.Filter{i};
        Data{i,6} = UserValues.Detector.Pol{i};
        Data{i,7} = UserValues.Detector.BS{i};
        Data{i,8} = UserValues.Detector.enabled{i};
    end
    h.MI.Channels_List.Data = Data;
    h.MI.Phasor_Det.String = {Data{:,1}};
    if h.MI.Phasor_Det.Value>numel(h.MI.Phasor_Det.String)
            h.MI.Phasor_Det.Value=1;
    end
    h.MI.Calib_Det.String = {Data{:,1}};
    if h.MI.Calib_Det.Value > numel(h.MI.Calib_Det.String)
        h.MI.Calib_Det.Value=1;
    end
    %%% Updates plot selection lists
    for i=1:NTabs
        for j=1:NPlots
            h.MI.Individual{i,2*(1+j)}.String=UserValues.Detector.Name;
        end
    end
    h.MI.Auto.Checked = UserValues.Detector.Auto;
end
%% Saves new tabs in guidata
guidata(h.Pam,h)
Update_Display([],[],[1, 4, 5, 8]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for extracting Macro- and Microtimes of PIE channels  %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Photons_PIEchannel] = Get_Photons_from_PIEChannel(PIEchannel,type,block,chunk)
%%% PIEchannel: Specifies the PIE channel as name or as number
%%% type:       Specifies the type of Photons to be extracted
%%%             (can be 'Macrotime' or 'Microtime')
%%% block:      specifies the number of the Block for FCS ErrorBar Calcula-
%%%             tion
%%%             (leave empty for loading whole measurement)
%%% chunk:      defines the chunk size that is used for processing the data
%%%             in steps (in minutes)
%%%             (if chunk is specified, block specifies instead the chunk
%%%             number
global UserValues TcspcData PamMeta FileInfo
%%% convert the PIEchannel to a number if a string was specified
if ischar(PIEchannel)
    PIEchannel = find(strcmp(UserValues.PIE.Name,PIEchannel));
end

%%% define which photons to use
switch type
    case 'Macrotime'
        type = 'MT';
    case 'Microtime'
        type = 'MI';
end

Det = UserValues.PIE.Detector(PIEchannel);
Rout = UserValues.PIE.Router(PIEchannel);
From = UserValues.PIE.From(PIEchannel);
To = UserValues.PIE.To(PIEchannel);
Combined = ~isempty(UserValues.PIE.Combined{PIEchannel});
if ~Combined %%% read out normal PIE channel
    if ~isempty(TcspcData.(type){Det,Rout})
        if nargin == 2 %%% read whole photon stream

            Photons_PIEchannel = TcspcData.(type){Det,Rout}(...
                TcspcData.MI{Det,Rout} >= From &...
                TcspcData.MI{Det,Rout} <= To);

        elseif nargin == 3 %%% read only the specified block
            %%% Calculates the block start times in clock ticks
            Times=ceil(PamMeta.MT_Patch_Times/FileInfo.ClockPeriod);

            Photons_PIEchannel = TcspcData.(type){Det,Rout}(...
                TcspcData.MI{Det,Rout} >= From &...
                TcspcData.MI{Det,Rout} <= To &...
                TcspcData.MT{Det,Rout} >= Times(block) &...
                TcspcData.MT{Det,Rout} < Times(block+1));
            if strcmp(type,'MT')
                Photons_PIEchannel = Photons_PIEchannel - Times(block);
            end
        elseif nargin == 4 %%% read only the specified chunk
            %%% define the chunk start and stop time based on chunksize and measurement
            %%% time
            %%% Determine Macrotime Boundaries from ChunkNumber and ChunkSize
            %%% (defined in minutes)
            LimitLow = (block-1)*chunk*60/FileInfo.ClockPeriod+1;
            LimitHigh = block*chunk*60/FileInfo.ClockPeriod;

            Photons_PIEchannel = TcspcData.(type){Det,Rout}(...
                TcspcData.MI{Det,Rout} >= From &...
                TcspcData.MI{Det,Rout} <= To &...
                TcspcData.MT{Det,Rout} >= LimitLow &...
                TcspcData.MT{Det,Rout} < LimitHigh);
        end
    else %%% PIE channel contains no photons
        Photons_PIEchannel = [];
    end
elseif Combined
    PIEchannel =  UserValues.PIE.Combined{PIEchannel};
    Det = UserValues.PIE.Detector(PIEchannel);
    Rout = UserValues.PIE.Router(PIEchannel);
    From = UserValues.PIE.From(PIEchannel);
    To = UserValues.PIE.To(PIEchannel);

    %%% get MT and MI of both channels (read both for sorting by macrotime
    %%% later)
    MT = []; MI = [];
    for i = 1:numel(Det)
        switch nargin
            case 2 %%% read whole photon stream
                MT = [MT; TcspcData.MT{Det(i),Rout(i)}(...
                    TcspcData.MI{Det(i),Rout(i)} >= From(i) &...
                    TcspcData.MI{Det(i),Rout(i)} <= To(i))];
                if strcmp(type,'MI')
                    MI = [MI; TcspcData.MI{Det(i),Rout(i)}(...
                        TcspcData.MI{Det(i),Rout(i)} >= From &...
                        TcspcData.MI{Det(i),Rout(i)} <= To)];
                end
            case 3 %%% read only the specified block
                %%% Calculates the block start times in clock ticks
                Times=ceil(PamMeta.MT_Patch_Times/FileInfo.ClockPeriod);
                
                MT = [MT; TcspcData.MT{Det(i),Rout(i)}(...
                    TcspcData.MI{Det(i),Rout(i)} >= From(i) &...
                    TcspcData.MI{Det(i),Rout(i)} <= To(i) &...
                    TcspcData.MT{Det(i),Rout(i)} >= Times(block) &...
                    TcspcData.MT{Det(i),Rout(i)} < Times(block+1))];                
                MT = MT - Times(block);
                if strcmp(type,'MI')
                    MI = [MI; TcspcData.MI{Det(i),Rout(i)}(...
                        TcspcData.MI{Det(i),Rout(i)} >= From(i) &...
                        TcspcData.MI{Det(i),Rout(i)} <= To(i) &...
                        TcspcData.MT{Det(i),Rout(i)} >= Times(block) &...
                        TcspcData.MT{Det(i),Rout(i)} < Times(block+1))];
                end
            case 4 %% read only the specified chunk
                %%% define the chunk start and stop time based on chunksize and measurement
                %%% time
                %%% Determine Macrotime Boundaries from ChunkNumber and ChunkSize
                %%% (defined in minutes)
                LimitLow = (block-1)*chunk*60/FileInfo.ClockPeriod+1;
                LimitHigh = block*chunk*60/FileInfo.ClockPeriod;

                MT = [MT; TcspcData.MT{Det(i),Rout(i)}(...
                    TcspcData.MI{Det(i),Rout(i)} >= From(i) &...
                    TcspcData.MI{Det(i),Rout(i)} <= To(i) &...
                    TcspcData.MT{Det(i),Rout(i)} >= LimitLow &...
                    TcspcData.MT{Det(i),Rout(i)} < LimitHigh)];
                if strcmp(type,'MI')
                    MI = [MI; TcspcData.MI{Det(i),Rout(i)}(...
                        TcspcData.MI{Det(i),Rout(i)} >= From(i) &...
                        TcspcData.MI{Det(i),Rout(i)} <= To(i) &...
                        TcspcData.MT{Det(i),Rout(i)} >= LimitLow &...
                        TcspcData.MT{Det(i),Rout(i)} < LimitHigh)];
                end
        end
    end
    %%% sort combined micro- and macrotimes by macrotimes
    [~,idx] = sort(MT);
    %%% assign output
    switch type
        case 'MT'
            Photons_PIEchannel = MT(idx);
        case 'MI'
            Photons_PIEchannel = MI(idx);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function generating deleting and selecting profiles  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "+"-Key or Add menu: Generate new profile
%%% "-"-Key, "del"-Key or Delete menu: Deletes selected profile
%%% "enter"-Key or Select menu: Makes selected profile current profile
function Update_Profiles(obj,ed)
h=guidata(findobj('Tag','Pam'));
global UserValues PamMeta PathToApp
%% obj is empty, if function was called during initialization
if isempty(obj)
    %%% findes current profile
    load([PathToApp filesep 'profiles' filesep 'Profile.mat']);
    for i=1:numel(h.Profiles.List.String)
        %%% Looks for current profile in profiles list
        if strcmp([h.Profiles.List.String{i} '.mat'], Profile) %#ok<NODEF>
            %%% Changes color to indicate current profile
            h.Profiles.List.String{i}=['<HTML><FONT color=FF0000>' h.Profiles.List.String{i} '</Font></html>'];
            return
        end
    end
end
%% Determines which buttons was pressed, if function was not called via key press
if ~strcmp(ed.EventName,'KeyPress')
    if obj == h.Profiles.Add
        e.Key='add';
    elseif obj == h.Profiles.Delete
        e.Key='delete';
    elseif obj == h.Profiles.Select
        e.Key='return';
    elseif obj == h.Profiles.Duplicate
        e.Key = 'duplicate';
    elseif obj == h.Profiles.Export
        e.Key = 'export';
    elseif obj == h.Profiles.Load
        e.Key = 'load';
    else
        e.Key='';
    end
else
    e.Key=ed.Key;
end
%% Determines, which Key/Button was pressed
Sel=h.Profiles.List.Value;
switch e.Key
    case 'add'
        %% Adds a new profile
        %%% Get profile name
        Name=inputdlg('Enter profile name:');
        %%% Creates new file and list entry if input was not empty
        if ~isempty(Name)
            PIE=[];
            save([PathToApp filesep 'profiles' filesep Name{1} '.mat'],'PIE');
            h.Profiles.List.String{end+1} = Name{1};
        end
    case {'delete';'subtract'}
        %% Deletes selected profile
        if numel(h.Profiles.List.String)>1
            %%% If selected profile is not the current profile
            if isempty(strfind(h.Profiles.List.String{Sel},'<HTML><FONT color=FF0000>'))
                %%% Deletes profile file and list entry
                delete([PathToApp filesep 'profiles' filesep h.Profiles.List.String{Sel} '.mat'])
                h.Profiles.List.String(Sel)=[];
            else
                %%% Deletes profile file and list entry
                delete([PathToApp filesep 'profiles' filesep h.Profiles.List.String{Sel}(26:(end-14)) '.mat'])
                h.Profiles.List.String(Sel)=[];
                %%% Selects first profile as current profile
                Profile= [h.Profiles.List.String{1} '.mat'];
                save([PathToApp filesep 'profiles' filesep 'Profile.mat'],'Profile');
                %%% Updates UserValues
                LSUserValues(1);
                %%% Changes color to indicate current profile
                h.Profiles.List.String{1}=['<HTML><FONT color=FF0000>' h.Profiles.List.String{1} '</Font></html>'];
                Update_Detector_Channels([],[],[1,2]);
                Update_Data([],[],0,0);
                Update_Display([],[],0);
            end
            %%% Move selection to last entry
            if numel(h.Profiles.List.String) <Sel
                h.Profiles.List.Value=numel(h.Profiles.List.String);
            end
            
        end
    case 'return'
        %%% Only executes if
        if isempty(strfind(h.Profiles.List.String{Sel},'<HTML><FONT color=FF0000>'))
            for i=1:numel(h.Profiles.List.String)
                if ~isempty(strfind(h.Profiles.List.String{i},'<HTML><FONT color=FF0000>'))
                    h.Profiles.List.String{i}=h.Profiles.List.String{i}(26:(end-14));
                    break;
                end
            end
            %%% Makes selected profile the current profile
            Profile= [h.Profiles.List.String{Sel} '.mat'];
            save([PathToApp filesep 'profiles' filesep 'Profile.mat'],'Profile');
            %%% Updates UserValues
            LSUserValues(0);          
            %%% Changes color to indicate current profile
            h.Profiles.List.String{Sel}=['<HTML><FONT color=FF0000>' h.Profiles.List.String{Sel} '</Font></html>'];
            
            h.Profiles.Filetype.Value = 1;
            for i=2:numel(h.Profiles.Filetype.String)
                if strcmp(h.Profiles.Filetype.String{i},UserValues.File.Custom_Filetype)
                    h.Profiles.Filetype.Value = i;
                end
            end
            
            %%% Resets applied shift to zero; might lead to overcorrection
            Update_to_UserValues;
            Update_Data([],[],0,0);
            Update_Detector_Channels([],[],[1,2]);
            Update_Display([],[],0);
            %%% Update export table
            h.Export.PIE.RowName = [UserValues.PIE.Name, {'All'}];
            h.Export.PIE.Data = false(numel(UserValues.PIE.Name)+1,1);
            % update file history
            PamMeta.Database = UserValues.File.FileHistory.PAM;
            h.Database.List.String = [];
            for i = 1:size(PamMeta.Database,1)
                h.Database.List.String = [{[PamMeta.Database{i,1} ' (path:' PamMeta.Database{i,2} ')']}; h.Database.List.String];
            end
            m = warndlg('Please consider restarting PAM to ensure that all settings are updated.','Profile changed!','modal');
        end
    case 'duplicate'
        %% Duplicates selected profile
        %%% Get profile name
        Name=inputdlg('Enter profile name:');
        %%% Creates new file and list entry if input was not empty
        if ~isempty(Name)
            save([PathToApp filesep 'profiles' filesep Name{1} '.mat'],'-struct','UserValues');
            h.Profiles.List.String{end+1} = Name{1};
        end
    case 'export'
        %%% get the location
        Profile= [h.Profiles.List.String{Sel} '.mat'];        
        [File,Path,~] = uiputfile({'*.mat','PAM profile file'},...
           'Saving profile...',fullfile(UserValues.File.Path,Profile));
        if File == 0
            return;
        end
        %%% save profile
        save(fullfile(Path,File),'-struct','UserValues');
    case 'load'
        %%% get the profile
        [File,Path,~] = uigetfile({'*.mat','PAM profile file (*.mat)'},...
            'Choose profile to load...',UserValues.File.Path,'Multiselect','off');
        if File == 0
            return;
        end
        [~,Name,~] = fileparts(File);
        %%% check if profile name already exists
        if any(strcmp(h.Profiles.List.String,Name))
            Name = [Name '_1'];
        end
        %%% copy to profiles folder
        source = fullfile(Path,File);
        destination = [PathToApp filesep 'profiles' filesep Name '.mat'];        
        success = copyfile(source,destination);
        if success == 1
            %%% add it to the list            
            h.Profiles.List.String{end+1} = Name;
        else
            disp('Profile could not be copied');
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to adjust setting to UserValues if a new profile was loaded  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_to_UserValues
global UserValues
h=guidata(findobj('Tag','Pam'));

h.MT.Binning.String=UserValues.Settings.Pam.MT_Binning;
h.MT.Binning_PCH.String=UserValues.Settings.Pam.PCH_Binning;
h.MT.Time_Section.String=UserValues.Settings.Pam.MT_Time_Section;
h.MT.Number_Section.String=UserValues.Settings.Pam.MT_Number_Section;
h.MT.ScanOffsetStart.String = UserValues.Settings.Pam.ScanOffsetStart;
h.MT.ScanOffsetEnd.String = UserValues.Settings.Pam.ScanOffsetEnd;

%%% Sets Correlation table to UserValues
h.Cor.Table.RowName=[UserValues.PIE.Name 'Column'];
h.Cor.Table.ColumnName=[UserValues.PIE.Name 'Row'];
h.Cor.Table.Data=false(numel(UserValues.PIE.Name)+1);
h.Cor.Table.ColumnEditable=true(numel(UserValues.PIE.Name)+1,1)';
ColumnWidth=cellfun(@length,UserValues.PIE.Name).*6+16;
ColumnWidth(end+1)=37; %%% Row = 3*8+16;
h.Cor.Table.ColumnWidth=num2cell(ColumnWidth);
h.Cor.Table.Data = UserValues.Settings.Pam.Cor_Selection;
h.Cor.Divider_Menu.Label=['Divider: ' num2str(UserValues.Settings.Pam.Cor_Divider)];

%%% Updates Detector calibration and Phasor channel lists
List=UserValues.Detector.Name;
h.MI.Phasor_Det.String=List;
h.MI.Calib_Det.String=List;
h.MI.Phasor_Det.Value=1;
h.MI.Calib_Det.Value=1;

%%% Updates MetaData List
h.Profiles.MetaDataTable.Data(:,2) = ...
    {UserValues.MetaData.ExcitationWavelengths;UserValues.MetaData.ExcitationPower;...
    UserValues.MetaData.DyeNames;UserValues.MetaData.BufferName;...
    UserValues.MetaData.SampleName;UserValues.MetaData.User;UserValues.MetaData.Comment};
%%% Sets BurstSearch GUI according to UserValues
Update_BurstGUI([],[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for keeping correlation table updated  %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Cor_Table(obj,e)
global UserValues
h=guidata(findobj('Tag','Pam'));
%%% called to reset the table to all zeros
if obj == h.Cor.Reset_Menu
    h.Cor.Table.Data = false(size(h.Cor.Table.Data));
    %%% Store Selection Change in UserValues
    UserValues.Settings.Pam.Cor_Selection = h.Cor.Table.Data;
    return;
end
%%% Is executed, if one of the checkboxes was clicked
if obj == h.Cor.Table
    %%% Activate/deactivate column
    if e.Indices(1) == size(h.Cor.Table.Data,1) && e.Indices(2) < size(h.Cor.Table.Data,2)
        h.Cor.Table.Data(1:end-1,e.Indices(2))=e.NewData;
        %%% Activate/deactivate row
    elseif e.Indices(2) == size(h.Cor.Table.Data,2) && e.Indices(1) < size(h.Cor.Table.Data,1)
        h.Cor.Table.Data(e.Indices(1),1:end-1)=e.NewData;
        %%% Activate/deactivate diagonal
    elseif e.Indices(1) == size(h.Cor.Table.Data,1) && e.Indices(2) == size(h.Cor.Table.Data,2)
        for i=1:(size(h.Cor.Table.Data,2)-1)
            h.Cor.Table.Data(i,i)=e.NewData;
        end
        
    end
end

%%% Activates/deactivates column/row/diagonal checkboxes
%%% Is done here to update, if new PIE channel was created
for i=1:size(h.Cor.Table.Data,1)
    if any(~h.Cor.Table.Data(i,1:end-1))
        h.Cor.Table.Data(i,end)=false;
    else
        h.Cor.Table.Data(i,end)=true;
    end
    if any(~h.Cor.Table.Data(1:end-1,i))
        h.Cor.Table.Data(end,i)=false;
    else
        h.Cor.Table.Data(end,i)=true;
    end
end
if any(~diag(h.Cor.Table.Data(1:end-1,1:end-1)))
    h.Cor.Table.Data(end)=false;
else
    h.Cor.Table.Data(end)=true;
end

if obj == h.Cor.Table
    %%% Store Selection Change in UserValues
    UserValues.Settings.Pam.Cor_Selection = h.Cor.Table.Data;
end
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for correlating data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Correlate (~,~,mode)
h=guidata(findobj('Tag','Pam'));
global UserValues TcspcData FileInfo PamMeta

h.Progress.Text.String = 'Opening Parallel Pool ...';
StartParPool();

h.Progress.Text.String = 'Starting Correlation';
h.Progress.Axes.Color=[1 0 0];

if mode==2 %%% For Multiple Correlation
    %%% following code is for remembering the last used FileType
    LSUserValues(0);
    %%% Loads all possible file types
    Filetypes = UserValues.File.SPC_FileTypes;
    %%% Finds last used file type
    Lastfile = UserValues.File.OpenTCSPC_FilterIndex;
    
    %%% Adds the custum filetype to the filetype selection
    if h.Profiles.Filetype.Value>1
        Custom = str2func(h.Profiles.Filetype.String{h.Profiles.Filetype.Value});
        [Custom_Suffix, Custom_Description] = feval(Custom);
        Filetypes{end+1,1} = Custom_Suffix;
        Filetypes{end,2} = Custom_Description;
    end
    %%% Puts last uses file type to front
    Fileorder = 1:size(Filetypes,1);
    Fileorder = [Lastfile, Fileorder(Fileorder~=Lastfile)];
    Filetypes = Filetypes(Fileorder,:);
    %%% Select file to be loaded
    [File, Path, Type] = uigetfile(Filetypes,'Choose a TCSPC data file',UserValues.File.Path,'MultiSelect', 'on');
    %%% Determines actually selected file type
    if Type~=0
        Type = Fileorder(Type);
        %%% Save the selected file type
        UserValues.File.OpenTCSPC_FilterIndex = Type;
    end
    if ~iscell(File) && ~all(File==0) %%% If exactly one file was selected
        File={File};
        NCors=1;
        LSUserValues(1);
    elseif ~iscell(File) && all(File==0) %%% If no file was selected
        File=[];
        NCors=[];
    else %%% If several files were selected
        NCors=1:size(File,2);
        LSUserValues(1);
    end
else %%% Single File correlation
    File=[];
    NCors=1;
    Path=UserValues.File.Path;
end

if ~isempty(NCors)
    %%% Save path
    UserValues.File.Path=Path;
    LSUserValues(1);
end

for m=NCors %%% Goes through every File selected (multiple correlation) or just the one already loaded(single file correlation)
    if mode==2 %%% Loads new file
        h.Progress.Text.String='Loading new file';
        LoadTcspc([],[],@Update_Data,@Update_Display,@Shift_Detector,@Update_Detector_Channels,h.Pam,File{m},Type);
    end
    %%% Finds the right combinations to correlate
    [Cor_A,Cor_B]=find(h.Cor.Table.Data(1:end-1,1:end-1));
    %%% Calculates the maximum inter-photon time in clock ticks
    Maxtime=ceil(max(diff(PamMeta.MT_Patch_Times))/FileInfo.ClockPeriod)/UserValues.Settings.Pam.Cor_Divider;
    if any(h.Cor.Type.Value == [4,5]) %%% Microtime Correlation
        Maxtime = Maxtime.*FileInfo.MI_Bins;
    end
    %%% Calculates the photon start times in clock ticks
    Times=ceil(PamMeta.MT_Patch_Times/FileInfo.ClockPeriod);
    Valid = find(PamMeta.Selected_MT_Patches)';
    %%% Uses truncated Filename
    switch FileInfo.FileType
        case {'FabsurfSPC','SPC'}
            FileName = FileInfo.FileName{1}(1:end-5);
        case {'HydraHarp','FabSurf-HydraHarp','Simulation'}
            FileName = FileInfo.FileName{1}(1:end-4);
        otherwise
            FileName = FileInfo.FileName{1}(1:end-4);
    end
   
    
    if (gcbo ~= h.Export.Correlate) || (gcbo == h.Export.Correlate && ~strcmp(h.Cor.Individual_Tab{1}.Title,'No data'))
        drawnow;
        %%% Removes individual Correlation Tabs
        for i=2:numel(h.Cor.Individual_Tab)
            delete(h.Cor.Individual_Tab{i})
        end
        h.Cor.Individual_Tab = h.Cor.Individual_Tab(1);
        h.Cor.Individual_Axes = h.Cor.Individual_Axes(1);
        if ~isempty(h.Cor.Individual_Axes{1}.Children)
            delete(h.Cor.Individual_Axes{1}.Children);
        end
        %%% Creates plots for all macrotime patches
        for i=1:numel(Valid)
            line('Parent',h.Cor.Individual_Axes{1},...
                'X',[3e-7 1],...
                'Y',[0 0],...
                'Color',rand(3,1));
        end

        h.Cor.Individual_Tab{1}.Title = 'No data';
        drawnow;
    end
    Progress(0,h.Progress.Axes,h.Progress.Text,'Correlating :')
    h.Progress.Axes.Color=UserValues.Look.Control;
    
    %%% For every active combination
    for i=1:numel(Cor_A)
        %%% Findes all needed PIE channels
        if UserValues.PIE.Detector(Cor_A(i))==0
            Det1=UserValues.PIE.Detector(UserValues.PIE.Combined{Cor_A(i)});
            Rout1=UserValues.PIE.Router(UserValues.PIE.Combined{Cor_A(i)});
            To1=UserValues.PIE.To(UserValues.PIE.Combined{Cor_A(i)});
            From1=UserValues.PIE.From(UserValues.PIE.Combined{Cor_A(i)});
        else
            Det1=UserValues.PIE.Detector(Cor_A(i));
            Rout1=UserValues.PIE.Router(Cor_A(i));
            To1=UserValues.PIE.To(Cor_A(i));
            From1=UserValues.PIE.From(Cor_A(i));
        end
        if UserValues.PIE.Detector(Cor_B(i))==0
            Det2=UserValues.PIE.Detector(UserValues.PIE.Combined{Cor_B(i)});
            Rout2=UserValues.PIE.Router(UserValues.PIE.Combined{Cor_B(i)});
            To2=UserValues.PIE.To(UserValues.PIE.Combined{Cor_B(i)});
            From2=UserValues.PIE.From(UserValues.PIE.Combined{Cor_B(i)});
        else
            Det2=UserValues.PIE.Detector(Cor_B(i));
            Rout2=UserValues.PIE.Router(Cor_B(i));
            To2=UserValues.PIE.To(Cor_B(i));
            From2=UserValues.PIE.From(Cor_B(i));
        end

        Cor_Type = h.Cor.Type.Value;
        switch Cor_Type %%% Assigns photons and does correlation
            case {1,4,5} %%% Point correlation
                %%% Initializes data cells
                Data1=cell(sum(PamMeta.Selected_MT_Patches),1); MI1 = cell(sum(PamMeta.Selected_MT_Patches),1);
                Data2=cell(sum(PamMeta.Selected_MT_Patches),1); MI2 = cell(sum(PamMeta.Selected_MT_Patches),1);
                k=1;
                Counts1=0;
                Counts2=0;
                %%% Seperate calculation for each block
                for j=find(PamMeta.Selected_MT_Patches)'
                    Data1{k}=[]; MI1{k} = [];
                    %%% Combines all photons to one vector
                    for l=1:numel(Det1)
                        if ~isempty(TcspcData.MI{Det1(l),Rout1(l)})
                            if Cor_Type == 1
                                Data1{k}=[Data1{k};...
                                    TcspcData.MT{Det1(l),Rout1(l)}(...
                                    TcspcData.MI{Det1(l),Rout1(l)}>=From1(l) &...
                                    TcspcData.MI{Det1(l),Rout1(l)}<=To1(l) &...
                                    TcspcData.MT{Det1(l),Rout1(l)}>=Times(j) &...
                                    TcspcData.MT{Det1(l),Rout1(l)}<Times(j+1))-Times(j)];
                                if (h.Cor.AfterPulsingCorrection.Value && (Cor_A(i) == Cor_B(i))) %%% read out microtimes as well
                                    MI1{k}=[MI1{k};...
                                    TcspcData.MI{Det1(l),Rout1(l)}(...
                                    TcspcData.MI{Det1(l),Rout1(l)}>=From1(l) &...
                                    TcspcData.MI{Det1(l),Rout1(l)}<=To1(l) &...
                                    TcspcData.MT{Det1(l),Rout1(l)}>=Times(j) &...
                                    TcspcData.MT{Det1(l),Rout1(l)}<Times(j+1))];
                                end
                            elseif any(Cor_Type == [4,5]) %%% Microtime Correlation, add microtimes
                                Data_dummy = TcspcData.MT{Det1(l),Rout1(l)}(...
                                    TcspcData.MI{Det1(l),Rout1(l)}>=From1(l) &...
                                    TcspcData.MI{Det1(l),Rout1(l)}<=To1(l) &...
                                    TcspcData.MT{Det1(l),Rout1(l)}>=Times(j) &...
                                    TcspcData.MT{Det1(l),Rout1(l)}<Times(j+1))-Times(j);
                                Data_dummy = FileInfo.MI_Bins.*double(Data_dummy)+...
                                    double(TcspcData.MI{Det1(l),Rout1(l)}(...
                                    TcspcData.MI{Det1(l),Rout1(l)}>=From1(l) &...
                                    TcspcData.MI{Det1(l),Rout1(l)}<=To1(l) &...
                                    TcspcData.MT{Det1(l),Rout1(l)}>=Times(j) &...
                                    TcspcData.MT{Det1(l),Rout1(l)}<Times(j+1)));
                                Data1{k}=[Data1{k};...
                                    Data_dummy];
                            end
                        end
                    end
                    %%% Calculates total photons
                    Counts1=Counts1+numel(Data1{k});
                    
                    %%% Only executes if channel1 is not empty
                    if ~isempty(Data1{k})
                        Data2{k}=[]; MI2{k} = [];
                        %%% Combines all photons to one vector
                        for l=1:numel(Det2)
                            if ~isempty(TcspcData.MI{Det2(l),Rout2(l)})
                                if Cor_Type == 1
                                    Data2{k}=[Data2{k};...
                                        TcspcData.MT{Det2(l),Rout2(l)}(...
                                        TcspcData.MI{Det2(l),Rout2(l)}>=From2(l) &...
                                        TcspcData.MI{Det2(l),Rout2(l)}<=To2(l) &...
                                        TcspcData.MT{Det2(l),Rout2(l)}>=Times(j) &...
                                        TcspcData.MT{Det2(l),Rout2(l)}<Times(j+1))-Times(j)];
                                    if (h.Cor.AfterPulsingCorrection.Value && (Cor_A(i) == Cor_B(i))) %%% read out microtimes as well
                                        MI2{k}=[MI2{k};...
                                        TcspcData.MI{Det1(l),Rout1(l)}(...
                                        TcspcData.MI{Det1(l),Rout1(l)}>=From1(l) &...
                                        TcspcData.MI{Det1(l),Rout1(l)}<=To1(l) &...
                                        TcspcData.MT{Det1(l),Rout1(l)}>=Times(j) &...
                                        TcspcData.MT{Det1(l),Rout1(l)}<Times(j+1))];
                                    end
                                elseif any(Cor_Type == [4,5]) %%% Microtime Correlation, add microtimes
                                    Data_dummy = TcspcData.MT{Det2(l),Rout2(l)}(...
                                        TcspcData.MI{Det2(l),Rout2(l)}>=From2(l) &...
                                        TcspcData.MI{Det2(l),Rout2(l)}<=To2(l) &...
                                        TcspcData.MT{Det2(l),Rout2(l)}>=Times(j) &...
                                        TcspcData.MT{Det2(l),Rout2(l)}<Times(j+1))-Times(j);
                                    Data_dummy = FileInfo.MI_Bins.*double(Data_dummy)+...
                                        double(TcspcData.MI{Det2(l),Rout2(l)}(...
                                        TcspcData.MI{Det2(l),Rout2(l)}>=From2(l) &...
                                        TcspcData.MI{Det2(l),Rout2(l)}<=To2(l) &...
                                        TcspcData.MT{Det2(l),Rout2(l)}>=Times(j) &...
                                        TcspcData.MT{Det2(l),Rout2(l)}<Times(j+1)));
                                    Data2{k}=[Data2{k};...
                                        Data_dummy];
                                end
                            end
                        end
                        %%% Calculates total photons
                        Counts2=Counts2+numel(Data2{k});
                    end
                    
                    %%% Only takes non empty channels as valid
                    if ~isempty(Data2{k})
                        Data1{k}=sort(Data1{k});
                        Data2{k}=sort(Data2{k});
                        k=k+1;
                    else
                        Valid(k)=[];
                    end
                end
                %%% Deletes empty and invalid channels
                if k<=numel(Data1)
                    Data1(k:end)=[];
                    Data2(k:end)=[];
                end
                %%% Applies divider to data
                for j=1:numel(Data1)
                    Data1{j}=floor(Data1{j}/UserValues.Settings.Pam.Cor_Divider);
                    Data2{j}=floor(Data2{j}/UserValues.Settings.Pam.Cor_Divider);
                end
                
                %%% Actually calculates the crosscorrelation
                switch Cor_Type
                    case 1
                        if ~(h.Cor.AfterPulsingCorrection.Value && (Cor_A(i) == Cor_B(i))) && ~(h.Cor.AggregateCorrection.Value)
                            [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data2,Maxtime);
                        elseif (h.Cor.AfterPulsingCorrection.Value && (Cor_A(i) == Cor_B(i))) 
                            %%% do after pulse correction if same detector is selected
                            %%% suppress afterpulsing by FLCS
                            %%% get microtime hist of PIE channel
                            det = find( (UserValues.Detector.Det == UserValues.PIE.Detector(Cor_A(i))) & (UserValues.Detector.Rout == UserValues.PIE.Router(Cor_A(i))));
                            det = det(1);
                            Decay = PamMeta.MI_Hist{det}(UserValues.PIE.From(Cor_A(i)):UserValues.PIE.To(Cor_A(i)));
                            %%% avoid zeros in Decay
                            Decay(Decay==0) = 1;
                            %%% afterpulsing baseline taken as minimum value of microtime histogram
                            afterpulsing = min(smooth(Decay,ceil(250e-12/(FileInfo.TACRange/FileInfo.MI_Bins))));
                            Decay_pure = Decay-afterpulsing; %%% "pure" decay
                            %%% calculate FLCS filter
                            diag_Decay = zeros(numel(Decay));
                            for k = 1:numel(Decay)
                                diag_Decay(k,k) = 1./Decay(k);
                            end
                            MI_species = [Decay_pure./sum(Decay_pure), ones(numel(Decay),1)./numel(Decay)];
                            filters_temp = ((MI_species'*diag_Decay*MI_species)^(-1)*MI_species'*diag_Decay)';
                            filter = zeros(numel(PamMeta.MI_Hist{det}),1);
                            % we only need the filter for the "pure" decay
                            filter(UserValues.PIE.From(Cor_A(i)):UserValues.PIE.To(Cor_A(i)),1) = filters_temp(:,1);
                            % filters(UserValues.PIE.From(Cor_A(i)):UserValues.PIE.To(Cor_A(i)),2) = filters_temp(:,2);
                            %%% assign the weights
                            Weights1 = cell(numel(Data1),1); Weights2 = cell(numel(Data2),1);
                            for k = 1:numel(Data1)
                                Weights1{k} = filter(MI1{k},1);
                                Weights2{k} = filter(MI2{k},1);
                            end
                            %%% Do the autocorrelation with weights
                            [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data2,Maxtime,Weights1,Weights2);
                        elseif h.Cor.AggregateCorrection.Value
                            %%% do inverse burst search to remove aggrates
                            %%% simply erase regions of aggregates for now
                            
                            T = str2double(h.Cor.Remove_Aggregate_Timewindow_Edit.String)*1000; % time window in microseconds
                            timebin_add = str2double(h.Cor.Remove_Aggregate_TimeWindowAdd_Edit.String);
                            Nsigma = str2double(h.Cor.Remove_Aggregate_Nsigma_Edit.String);
                            correlating_signal = 0;
                            for k = 1:numel(Data1)
                                % get the average countrate of the block
                                cr = numel(Data1{k})./Data1{k}(end)./FileInfo.ClockPeriod;
                                M = T*1E-6*cr;% minimum number of photons in time window
                                M = round(M + Nsigma*sqrt(M)); %%% add N sigma
                                
                                [start, stop] = find_aggregates(Data1{k},T,M,timebin_add);
                                start_times = Data1{k}(start);
                                stop_times = Data1{k}(stop);
                                
                                inval = [];
                                for l = 1:numel(start)
                                    inval = [inval,start(l):stop(l)];
                                end
                                Data1{k}(inval) = [];
                                correlating_signal = correlating_signal + numel(Data1{k});
                                
                                valid_times = (start_times < Data1{k}(end)) & (start_times > Data1{k}(1));
                                start_times = start_times(valid_times);
                                stop_times = stop_times(valid_times);
                                stop_times(stop_times > Data1{k}(end)) = Data1{k}(end);
                                % determine the count rate over the filtered signal
                                cr = numel(Data1{k})./(Data1{k}(end)-sum(start_times-stop_times));
                                % fill with poisson noise
                                for l = 1:numel(start_times)
                                    %%% generate noise
                                    t = start_times(l);
                                    while t(end) < stop_times(l);
                                        t(end+1) = t(end) + exprnd(1/cr);
                                    end
                                    idx = find(Data1{k} < start_times(l),1,'last');
                                    Data1{k} = [Data1{k}(1:idx); t';Data1{k}((idx+1):end)];
                                end
                            end
                            if (Cor_A(i) == Cor_B(i)) %%% autocorrelation
                                [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data1,Maxtime);
                                %%% correct amplitude for addition of
                                %%% non-correlating signal
                                Cor_Array = Cor_Array.*(sum(cellfun(@numel,Data1))./correlating_signal)^2;
                            else %%% cross-correlation
                                %%% remove aggregates in second channel
                                correlating_signal2 = 0;
                                for k = 1:numel(Data2)
                                    % get the average countrate of the block
                                    cr = numel(Data2{k})./Data2{k}(end)./FileInfo.ClockPeriod;
                                    M = T*1E-6*cr;% minimum number of photons in time window
                                    M = round(M + Nsigma*sqrt(M)); %%% add N sigma
                                    
                                    [start, stop] = find_aggregates(Data2{k},T,M,timebin_add);
                                    start_times = Data2{k}(start);
                                    stop_times = Data2{k}(stop);
                                    
                                    inval = [];
                                    for l = 1:numel(start)
                                        inval = [inval,start(l):stop(l)];
                                    end
                                    Data2{k}(inval) = [];
                                    correlating_signal2 = correlating_signal2 + numel(Data2{k});
                                    
                                    valid_times = (start_times < Data2{k}(end)) & (start_times > Data2{k}(1));
                                    start_times = start_times(valid_times);
                                    stop_times = stop_times(valid_times);
                                    stop_times(stop_times > Data2{k}(end)) = Data2{k}(end);
                                    % determine the count rate over the filtered signal
                                    cr = numel(Data2{k})./(Data2{k}(end)-sum(start_times-stop_times));
                                    % fill with poisson noise
                                    for l = 1:numel(start_times)
                                        %%% generate noise
                                        t = start_times(l);
                                        while t(end) < stop_times(l);
                                            t(end+1) = t(end) + exprnd(1/cr);
                                        end
                                        idx = find(Data2{k} < start_times(l),1,'last');
                                        Data2{k} = [Data2{k}(1:idx); t';Data2{k}((idx+1):end)];
                                    end
                                end
                                [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data2,Maxtime);
                                %%% correct amplitude for addition of
                                %%% non-correlating signal
                                correction_factor  = (sum(cellfun(@numel,Data1)).*sum(cellfun(@numel,Data2)))./(correlating_signal.*correlating_signal2);
                                Cor_Array = Cor_Array.*correction_factor;
                            end
                        end
                    case 4
                        [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data2,Maxtime);
                    case 5
                        time_unit = FileInfo.ClockPeriod*UserValues.Settings.Pam.Cor_Divider/FileInfo.MI_Bins;
                        limit = round(10E-6/time_unit); %%% only calculate from -10mus to 10mus
                        resolution = ceil(100E-12/time_unit); %%% set to 100 ps
                        [~,Cor_Array,Cor_Times]=nanosecond_correlation(Data1,Data2,limit,resolution,time_unit);
                end
                if h.Cor.Type.Value == 1
                    Cor_Times=Cor_Times*FileInfo.ClockPeriod*UserValues.Settings.Pam.Cor_Divider;
                elseif any(h.Cor.Type.Value == [4,5])
                    Cor_Times=Cor_Times*FileInfo.ClockPeriod*UserValues.Settings.Pam.Cor_Divider/FileInfo.MI_Bins;
                end
                %%% Calculates average and standard error of mean (without
                %%% tinv_table yet)
                if size(Cor_Array,2)>1
                    Cor_Average=mean(Cor_Array,2);
                    %Cor_SEM=std(Cor_Array,0,2)/sqrt(size(Cor_Array,2));
                    %%% Averages files before saving to reduce errorbars
                    Amplitude=sum(Cor_Array,1);
                    Cor_Norm=Cor_Array./repmat(Amplitude,[size(Cor_Array,1),1])*mean(Amplitude);
                    Cor_SEM=std(Cor_Norm,0,2)/sqrt(size(Cor_Array,2));
                    % Code for adjusting the standord error of the mean
                    % with the student's t distribution
                    % p_value = normcdf(1)-normcdf(-1); % this is the probability to be within 1 sigma for a normal distribution (p = 0.68..)
                    % Cor_SEM = Cor_SEM * tinv(p_value+(1-p_value)/2,size(Cor_Array,2));
                else
                    Cor_Average=Cor_Array;
                    Cor_SEM=Cor_Array;
                end
                %% Saves data
                %%% Removes Comb.: from Name of combined channels
                PIE_Name1=UserValues.PIE.Name{Cor_A(i)};
                if ~isempty(strfind(PIE_Name1,'Comb'))
                    PIE_Name1=PIE_Name1(8:end);
                end
                PIE_Name2=UserValues.PIE.Name{Cor_B(i)};
                if ~isempty(strfind(PIE_Name2,'Comb'))
                    PIE_Name2=PIE_Name2(8:end);
                end
                Header = ['Correlation file for: ' strrep(fullfile(FileInfo.Path, FileName),'\','\\') ' of Channels ' UserValues.PIE.Name{Cor_A(i)} ' cross ' UserValues.PIE.Name{Cor_A(i)}]; %#ok<NASGU>
                Counts = [Counts1 Counts2]/FileInfo.MeasurementTime/1000*numel(PamMeta.Selected_MT_Patches)/numel(Valid);
                if any(h.Cor.Format.Value == [1 3])
                    %%% Generates filename
                    Current_FileName=fullfile(FileInfo.Path,[FileName '_' PIE_Name1 '_x_' PIE_Name2 '.mcor']);
                    if Cor_Type == 5 %%% linear microtime correlation
                        Current_FileName = [Current_FileName(1:end-5) '_nsFCS.mcor'];
                    end
                    %%% Checks, if file already exists
                    if  exist(Current_FileName,'file')
                        k=1;
                        %%% Adds 1 to filename
                        Current_FileName=[Current_FileName(1:end-5) num2str(k) '.mcor'];
                        %%% Increases counter, until no file is fount
                        while exist(Current_FileName,'file')
                            k=k+1;
                            Current_FileName=[Current_FileName(1:end-(5+numel(num2str(k-1)))) num2str(k) '.mcor'];
                        end
                    end
                    save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
                end
                if any(h.Cor.Format.Value == [2 3])
                    %%% Generates filename
                    Current_FileName=fullfile(FileInfo.Path,[FileName '_' PIE_Name1 '_x_' PIE_Name2 '.cor']);
                    %%% Checks, if file already exists
                    if  exist(Current_FileName,'file')
                        k=1;
                        %%% Adds 1 to filename
                        Current_FileName=[Current_FileName(1:end-4) num2str(k) '.cor'];
                        %%% Increases counter, until no file is fount
                        while exist(Current_FileName,'file')
                            k=k+1;
                            Current_FileName=[Current_FileName(1:end-(4+numel(num2str(k-1)))) num2str(k) '.cor'];
                        end
                    end
                    
                    Counts = [Counts1 Counts2]/FileInfo.MeasurementTime/1000*numel(PamMeta.Selected_MT_Patches)/numel(Valid);
                    
                    %%% Creates new correlation file
                    FileID=fopen(Current_FileName,'w');
                    
                    %%% Writes Header
                    fprintf(FileID, ['Correlation file for: ' strrep(fullfile(FileInfo.Path, FileName),'\','\\') ' of Channels ' UserValues.PIE.Name{Cor_A(i)} ' cross ' UserValues.PIE.Name{Cor_A(i)} '\n']);
                    fprintf(FileID, ['Count rate channel 1 [kHz]: ' num2str(Counts(1), '%12.2f') '\n']);
                    fprintf(FileID, ['Count rate channel 2 [kHz]: ' num2str(Counts(2), '%12.2f') '\n']);
                    fprintf(FileID, ['Valid bins: ' num2str(Valid) '\n']);
                    %%% Indicates start of data
                    fprintf(FileID, ['Data starts here: ' '\n']);
                    
                    %%% Writes data as columns: Time    Averaged    SEM     Individual bins
                    fprintf(FileID, ['%8.12f\t%8.8f\t%8.8f' repmat('\t%8.8f',1,numel(Valid)) '\n'], [Cor_Times Cor_Average Cor_SEM Cor_Array]');
                    fclose(FileID);                    
                end
                %% Plots Data
                if gcbo ~= h.Export.Correlate % skip plotting if using database
                    %%% Creates new Tab with axes
                    if numel(h.Cor.Individual_Tab)<i
                        h.Cor.Individual_Tab{i} = copyobj(h.Cor.Individual_Tab{i-1}, h.Cor.Correlations_Tabs);
                        h.Cor.Individual_Axes{i} = h.Cor.Individual_Tab{i}.Children(strcmp('axes',get(h.Cor.Individual_Tab{i}.Children,'Type')));
                    end
                    %%% make current tab this one
                    h.Cor.Correlations_Tabs.SelectedTab = h.Cor.Individual_Tab{i};
                    %%% Changes Tab Name
                    h.Cor.Individual_Tab{i}.Title = [PIE_Name1 '_x_' PIE_Name2];
                    lgd_str = cell(size(Cor_Array,2),1); % generate legend strings
                    for j = 1:size(Cor_Array,2)
                        h.Cor.Individual_Axes{i}.Children(j).XData = Cor_Times;
                        h.Cor.Individual_Axes{i}.Children(j).YData = Cor_Array(:,j);
                        h.Cor.Individual_Axes{i}.Children(j).ButtonDownFcn ={@Cor_Selection,1};
                        lgd_str{j} = ['Block #' num2str(j)];
                    end
                    %%% Enable legend
                    legend(h.Cor.Individual_Axes{i},lgd_str);
                    %%% Saves filename in axes
                    h.Cor.Individual_Axes{i}.UserData = {Current_FileName,Header,Counts,Valid,Cor_Times,Cor_Average,Cor_SEM,Cor_Array};
                    h.Cor.Individual_Axes{i}.UIContextMenu = h.Cor.Individual_Menu;
                end
                Progress((i)/numel(Cor_A),h.Progress.Axes,h.Progress.Text,'Correlating :')
            case {2,3} %%% Pair correlation
                Bins=str2double(h.Cor.Pair_Bins.String);
                Dist=[0,str2num(h.Cor.Pair_Dist.String)]; %#ok<ST2NM>
                Dist= Dist(Dist<Bins);
                Times = (Times*FileInfo.ClockPeriod*FileInfo.ScanFreq);
                Maxtime = max(diff(Times));
                h.Progress.Text.String='Assigning photons to bins';
                h.Progress.Axes.Color=[1 0 0];
                %% Channel 1 calculations
                Data = []; MI = [];
                %%% Combines all photons to one vector for channel 1
                for l=1:numel(Det1)
                    if ~isempty(TcspcData.MI{Det1(l),Rout1(l)})
                        %%% Extracts all macrotimes
                        Data = [Data TcspcData.MT{Det1(l),Rout1(l)}(...
                            TcspcData.MI{Det1(l),Rout1(l)}>=From1(l) &...
                            TcspcData.MI{Det1(l),Rout1(l)}<=To1(l))];
                        %%% Extracts all microtimes
                        MI = [MI TcspcData.MI{Det1(l),Rout1(l)}(...
                            TcspcData.MI{Det1(l),Rout1(l)}>=From1(l) &...
                            TcspcData.MI{Det1(l),Rout1(l)}<=To1(l))];
                    end
                end
                %%% Sorts data
                Data = Data*FileInfo.ClockPeriod*FileInfo.ScanFreq;
                [DataBin,Index] = sort(mod(Data,1));
                Data = Data(Index);
                MI = MI(Index);
                
                Borders = zeros(Bins+1,1);
                for j=1:(Bins-1)
                    Borders(j+1) =  find(DataBin>=j/Bins,1,'first')-1;
                end
                Borders(end)=numel(DataBin);
                Borders = diff(Borders);
                Data = mat2cell(Data,Borders,1);
                MI = mat2cell(MI,Borders,1);
                MI1=cell(Bins,1);
                for j=1:Bins
                    Data{j} = sort(Data{j});
                    MI{j} = sort(MI{j});
                    k = 1;
                    for m = Valid
                        Data1{j}{k} = Data{j}((Data{j}>=Times(m)) & (Data{j}<Times(m+1)))-Times(m);
                        MI1{j} = [MI1{j}; MI{j}((Data{j}>=Times(m)) & (Data{j}<Times(m+1)))];
                        k = k+1;
                    end
                end
                clear Data MI
                %% Channel 2 calculations
                if Cor_B(i) == Cor_A(i)
                    Data2 = Data1;
                    MI2 = MI1;
                else
                    Data=[];
                    %%% Combines all photons to one vector for channel 2
                    for l=1:numel(Det2)
                        if ~isempty(TcspcData.MI{Det2(l),Rout2(l)})
                            Data=[Data TcspcData.MT{Det2(l),Rout2(l)}(...
                                TcspcData.MI{Det2(l),Rout2(l)}>=From2(l) &...
                                TcspcData.MI{Det2(l),Rout2(l)}<=To2(l))];
                            %%% Extracts all microtimes
                            MI = [MI TcspcData.MI{Det2(l),Rout2(l)}(...
                                TcspcData.MI{Det2(l),Rout2(l)}>=From2(l) &...
                                TcspcData.MI{Det2(l),Rout2(l)}<=To2(l))];
                        end
                    end
                    %%% Sorts photons into spatial bins
                    Data = Data*FileInfo.ClockPeriod*FileInfo.ScanFreq;
                    [DataBin,Index] = sort(mod(Data,1));
                    Data = Data(Index);
                    MI = MI(Index);
                    
                    Borders = zeros(Bins+1,1);
                    for j=1:(Bins-1)
                        Borders(j+1) =  find(DataBin>=j/Bins,1,'first')-1;
                    end
                    Borders(end)=numel(DataBin);
                    Borders = diff(Borders);
                    Data = mat2cell(Data,Borders,1);
                    MI = mat2cell(MI,Borders,1);
                    for j=1:Bins
                        Data{j} = sort(Data{j});
                        MI{j} = sort(MI{j});
                        k = 1;
                        for m = Valid
                            Data2{j}{k} = Data{j}((Data{j}>=Times(m)) & (Data{j}<Times(m+1)))-Times(m);
                            MI2{j} = [MI1{j}; MI{j}((Data{j}==Times(m)) & (Data{j}<Times(m+1)))];
                            k = k+1;
                        end
                    end
                    clear Data MI
                end
                %% Actually calculates the crosscorrelation
                PairCor=cell(Bins,max(Dist),2);
                PairInfo.Time=[];
                Progress(0,h.Progress.Axes, h.Progress.Text,'Calculating PCF:');
                h.Progress.Axes.Color=UserValues.Look.Control;
                for j=1:Bins %%% Goes through every bin
                    for l=Dist %%% Goes through every selected bin distance
                        if (l+j)<=Bins %%% Checks if bin distance goes across the end of line
                            %%% Ch1xCh2
                            [Cor_Array,Cor_Times] = CrossCorrelation(Data1{j},Data2{j+l},Maxtime);
                            %%% Adjusts correlation times to longest
                            PairCor{j,l+1,1} = mean(Cor_Array,2);
                            if numel(PairInfo.Time) < numel(Cor_Times)
                                PairInfo.Time = Cor_Times;
                            end
                            if l == 0
                                PairCor{j,l+1,2} = PairCor{j,l+1,2};
                            else
                                %%% Ch2xCh1
                                [Cor_Array,Cor_Times] = CrossCorrelation(Data1{j+l},Data2{j},Maxtime);
                                %%% Adjusts correlation times to longest
                                PairCor{j,l+1,2} = mean(Cor_Array,2);
                                if numel(PairInfo.Time) < numel(Cor_Times)
                                    PairInfo.Time = Cor_Times;
                                end
                            end
                        elseif Cor_Type == 3 %%% Does all correlations for circular scans
                            %%% Ch1xCh2
                            [Cor_Array,Cor_Times] = CrossCorrelation(Data1{j},Data2{j+l-Bins},Maxtime);
                            %%% Adjusts correlation times to longest
                            PairCor{j,l+1,1} = mean(Cor_Array,2);
                            if numel(PairInfo.Time) < numel(Cor_Times)
                                PairInfo.Time = Cor_Times;
                            end
                            %%% Ch2xCh1
                            [Cor_Array,Cor_Times] = CrossCorrelation(Data1{j+l},Data2{j},Maxtime);
                            %%% Adjusts correlation times to longest
                            PairCor{j,l+1,2} = mean(Cor_Array,2);
                            if numel(PairInfo.Time) < numel(Cor_Times)
                                PairInfo.Time = Cor_Times;
                            end
                        end
                    end
                    Progress(j/Bins,h.Progress.Axes, h.Progress.Text,'Calculating PCF:');
                end
                %%% Fills all empty bins with zeros
                MaxLength=max(max(max(cellfun(@numel,PairCor))));
                for j=1:numel(PairCor)
                    if numel(PairCor{j})<MaxLength
                        PairCor{j}(MaxLength,1)=0;
                    end
                end
                %% Transforms Data and Saves
                %%% Transforms cell array to 4D matrix (Time,Bins,Dist,Dir)
                PairCor=reshape(cell2mat(PairCor),[MaxLength,size(PairCor)]); %#ok<NASGU>
                %%% Calculates Intensity traces
                for j=1:Bins
                    %%% Intensity tracefor channel 1
                    for k = 2:numel(Data1{j})
                        Data1{j}{k} = Data1{j}{k}+Times(k);
                        Data2{j}{k} = Data2{j}{k}+Times(k);
                    end
                    Data1{j} = cell2mat(Data1{j}');
                    Data2{j} = cell2mat(Data2{j}');
                    PairInt{1}(:,j)= histc(Data1{j},1:10:ceil(FileInfo.MeasurementTime*FileInfo.ScanFreq));
                    %%% Mean arrival time trace for channel 1
                    CumInt = cumsum(PairInt{1}(:,j));
                    CumInt(CumInt==0)=1;
                    CumMI = cumsum(double(MI1{j}));
                    CumMI = CumMI(CumInt);
                    CumMI = [CumMI(1); diff(CumMI)];
                    PairMI{1}(:,j) = CumMI./PairInt{1}(:,j);
                    %%% Intensity tracefor channel 2
                    PairInt{2}(:,j)=histc(Data2{j},1:10:ceil(FileInfo.MeasurementTime*FileInfo.ScanFreq));
                    %%% Mean arrival time trace for channel 2
                    CumInt = cumsum(PairInt{2}(:,j));
                    CumInt(CumInt==0)=1;
                    CumMI = cumsum(double(MI2{j}));
                    CumMI = CumMI(CumInt);
                    CumMI = [CumMI(2); diff(CumMI)];
                    PairMI{2}(:,j) = CumMI./PairInt{2}(:,j);
                end
                clear Data1 Data2 MI1 MI2
                PairInt{1} = PairInt{1}/10;
                PairInt{2} = PairInt{2}/10;
                PairMI{1}(isnan(PairMI{1}) | isinf(PairMI{1})) = 0;
                PairMI{2}(isnan(PairMI{2}) | isinf(PairMI{2})) = 0;
                %%% Combines information
                PairInfo.Dist=Dist;
                PairInfo.Bins=Bins;
                PairInfo.ScanFreq=FileInfo.ScanFreq;
                %%% Transforms time lag to real time
                PairInfo.Time=PairInfo.Time/FileInfo.ScanFreq;
                %% Save Data
                %%% Removes Comb.: from Name of combined channels
                PIE_Name1=UserValues.PIE.Name{Cor_A(i)};
                if ~isempty(strfind(PIE_Name1,'Comb'))
                    PIE_Name1=PIE_Name1(8:end);
                end
                PIE_Name2=UserValues.PIE.Name{Cor_B(i)};
                if ~isempty(strfind(PIE_Name2,'Comb'))
                    PIE_Name2=PIE_Name2(8:end);
                end
                %%% Generates filename
                Current_FileName=fullfile(FileInfo.Path,[FileName '_' PIE_Name1 '_x_' PIE_Name2 '.pcor']);
                %%% Checks, if file already exists
                if  exist(Current_FileName,'file')
                    k=1;
                    %%% Adds 1 to filename
                    Current_FileName=[Current_FileName(1:end-5) num2str(k) '.pcor'];
                    %%% Increases counter, until no file is fount
                    while exist(Current_FileName,'file')
                        k=k+1;
                        Current_FileName=[Current_FileName(1:end-(5+numel(num2str(k-1)))) num2str(k) '.pcor'];
                    end
                end
                %%% Saves File
                save(Current_FileName,'PairInfo','PairInt','PairMI','PairCor');
                UserValues.File.PCFPath = FileInfo.Path;
        end
    end
    guidata(h.Pam,h);
    Progress(1);
    Update_Display([],[],1);
end
%%% reorder tabs in correlation preview (move aggregate window to the back)
h.Cor.Correlations_Tabs.Children = h.Cor.Correlations_Tabs.Children([1, (2:numel(h.Cor.Correlations_Tabs.Children)-1)+1, 2]);

%%% Set FCSFit Path to FilePath
UserValues.File.FCSPath = FileInfo.Path;
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for linear nanosecond correlation (Schuler type) %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [G_raw, G_norm, G_timeaxis] = nanosecond_correlation(t1,t2,limit,resolution,time_unit)
global UserValues
bins = (-limit:resolution:limit)';
G_norm = cell(1,numel(t1));
G_raw = cell(1,numel(t1));
parfor (i = 1:numel(t1),UserValues.Settings.Pam.ParallelProcessing)
    maxtime = max(max([t1{i};t2{i}]));
    
    channel = [ones(numel(t1{i}),1); 2*ones(numel(t2{i}),1)];
    ArrivalTime = [t1{i}; t2{i}];
    
    [ArrivalTime, idx] = sort(ArrivalTime);
    channel = channel(idx);
    
    dc = diff(channel);
    dt = diff(ArrivalTime);
    dt = dt.*dc;
    dt = dt(dt ~= 0);
    
    G_raw{i} = histc(dt,bins);
    %normalization
    Nav = numel(dt)^2*resolution/maxtime;
    G_norm{i} = G_raw{i}/Nav;
end
G_timeaxis = bins;
G_raw = cell2mat(G_raw);
G_norm = cell2mat(G_norm);

%%% pileup correction
% function for fitting of pileup, including one antibunching term and one
% bunching term
fun = @(A,B,C,t_offset,t_pileup,t_lifetime,t_bunching,x) A.*exp(-(abs(x-t_offset)/t_pileup)).*(1-B*exp(-(abs(x-t_offset)/t_lifetime))).*(1+C*exp(-(abs(x-t_offset)/t_bunching)));
fun_pileup = @(tau,t_offset,x) exp(-(abs(x-t_offset)/tau));
start_point = [1 1 1 0 round(10E-6/time_unit) round(1e-9/time_unit) round(100e-9/time_unit)];
lb = [0 0 0 -Inf round(1E-6/time_unit) 0 round(10E-9/time_unit)];
ub = [Inf Inf Inf Inf Inf round(10E-9/time_unit) round(1E-6/time_unit)];
% total histogram
hnorm = sum(G_norm,2);
fit1 = fit(bins,hnorm,fun,'StartPoint',start_point,'Lower',lb,'Upper',ub);
coeff = coeffvalues(fit1);
pileup = fun_pileup(coeff(5),coeff(4),bins);
% correction for pileup
G_norm = G_norm./pileup-1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for lifetime correlation  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Correlate_fFCS(~,~)
h=guidata(findobj('Tag','Pam'));
global UserValues FileInfo PamMeta

h.Progress.Text.String = 'Opening Parallel Pool ...';
StartParPool();

h.Progress.Text.String = 'Starting Correlation';
h.Progress.Axes.Color=[1 0 0];

%%% Calculates the maximum inter-photon time in clock ticks
Maxtime=ceil(max(diff(PamMeta.MT_Patch_Times))/FileInfo.ClockPeriod)/UserValues.Settings.Pam.Cor_Divider;
%%% Calculates the photon start times in clock ticks
Times=ceil(PamMeta.MT_Patch_Times/FileInfo.ClockPeriod);
Valid = find(PamMeta.Selected_MT_Patches)';
%%% Uses truncated Filename
switch FileInfo.FileType
    case {'FabsurfSPC','SPC'}
        FileName = FileInfo.FileName{1}(1:end-5);
    case {'HydraHarp','FabSurf-HydraHarp','Simulation'}
        FileName = FileInfo.FileName{1}(1:end-4);
    otherwise
        FileName = FileInfo.FileName{1}(1:end-4);
end
drawnow;

Progress(0,h.Progress.Axes,h.Progress.Text,'Correlating :')
h.Progress.Axes.Color=UserValues.Look.Control;
drawnow;

%%% read out which correlations to perform and map species to filter number
[Cor_A, Cor_B] = find(cell2mat(h.Cor_fFCS.Cor_fFCS_Table.Data));
active_species = find(cell2mat(h.Cor_fFCS.MIPattern_Table.Data(:,2)));
Names = [PamMeta.fFCS.MIPattern_Name';{'Scatter'}];

filter = PamMeta.fFCS.filters;

%% Initializes data cells
Data1=cell(sum(PamMeta.Selected_MT_Patches),1);
Data2=cell(sum(PamMeta.Selected_MT_Patches),1);
Weights1=cell(sum(PamMeta.Selected_MT_Patches),1);
Weights2=cell(sum(PamMeta.Selected_MT_Patches),1);
MI1=cell(sum(PamMeta.Selected_MT_Patches),1);
MI2=cell(sum(PamMeta.Selected_MT_Patches),1);

k=1;
Counts1=0;
Counts2=0;
%%% Seperate calculation for each block
for j=find(PamMeta.Selected_MT_Patches)'
    Data1{k}=[];
    MI1{k} = [];
    
    %%% Combines all photons to one vector
    offset = 0;
    for l = PamMeta.fFCS.PIEseletion{1}
        Data1{k}=[Data1{k};Get_Photons_from_PIEChannel(l,'Macrotime',j)];
        MI1{k} = [MI1{k};Get_Photons_from_PIEChannel(l,'Microtime',j)+offset*FileInfo.MI_Bins];
        offset = offset + 1;
    end
    
    if ~isempty(Data1{k})
        Data2{k}=[];
        MI2{k} = [];
        offset = 0;
        for l = PamMeta.fFCS.PIEseletion{2}
            Data2{k}=[Data2{k};Get_Photons_from_PIEChannel(l,'Macrotime',j)];
            MI2{k} = [MI2{k};Get_Photons_from_PIEChannel(l,'Microtime',j)+offset*FileInfo.MI_Bins];
            offset = offset + 1;
        end
    end
    %%% Calculates total photons
    Counts1=Counts1+numel(Data1{k});
    Counts2=Counts2+numel(Data2{k});
    
    %%% sort
    if ~isempty(Data2{k})
        [Data1{k}, idx] =sort(Data1{k});
        MI1{k} = MI1{k}(idx);
        [Data2{k}, idx] =sort(Data2{k});
        MI2{k} = MI2{k}(idx);
        k=k+1;
    else
        Valid(k)=[];
    end
end
%%% Deletes empty and invalid channels
if k<=numel(Data1)
    Data1(k:end)=[];
    MI1(k:end)=[];
    Data2(k:end)=[];
    MI2(k:end)=[];
end
%%% Applies divider to data
for j=1:numel(Data1)
    Data1{j}=floor(Data1{j}/UserValues.Settings.Pam.Cor_Divider);
    Data2{j}=floor(Data2{j}/UserValues.Settings.Pam.Cor_Divider);
end

%%% loop over all filter combinations
for i = 1:numel(Cor_A)
    %%% construct weights
    for l = 1:numel(Data1)
        Weights1{l} = filter{1}{Cor_A(i)}(MI1{l});
        Weights2{l} = filter{2}{Cor_B(i)}(MI2{l});
    end
    %%% Actually calculates the crosscorrelation
    [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data2,Maxtime,Weights1,Weights2);
    Cor_Times=Cor_Times*FileInfo.ClockPeriod*UserValues.Settings.Pam.Cor_Divider;
    %%% Calculates average and standard error of mean (without tinv_table yet
    if size(Cor_Array,2)>1
        Cor_Average=mean(Cor_Array,2);
        %Cor_SEM=std(Cor_Array,0,2)/sqrt(size(Cor_Array,2));
        %%% Averages files before saving to reduce errorbars
        Amplitude=sum(Cor_Array,1);
        Cor_Norm=Cor_Array./repmat(Amplitude,[size(Cor_Array,1),1])*mean(Amplitude);
        Cor_SEM=std(Cor_Norm,0,2)/sqrt(size(Cor_Array,2));
        
    else
        Cor_Average=Cor_Array;
        Cor_SEM=Cor_Array;
    end
    %% Saves data
    Name1=Names{active_species(Cor_A(i))};
    Name2=Names{active_species(Cor_B(i))};
    %%% Generates filename
    Current_FileName=fullfile(FileInfo.Path,[FileName '_' Name1 '_x_' Name2 '.mcor']);
    %%% Checks, if file already exists
    if  exist(Current_FileName,'file')
        k=1;
        %%% Adds 1 to filename
        Current_FileName=[Current_FileName(1:end-5) num2str(k) '.mcor'];
        %%% Increases counter, until no file is fount
        while exist(Current_FileName,'file')
            k=k+1;
            Current_FileName=[Current_FileName(1:end-(5+numel(num2str(k-1)))) num2str(k) '.mcor'];
        end
    end
    
    Header = ['Correlation file for: ' strrep(fullfile(FileInfo.Path, FileName),'\','\\') ' of Channels ' UserValues.PIE.Name{Cor_A(i)} ' cross ' UserValues.PIE.Name{Cor_A(i)}]; %#ok<NASGU>
    Counts = [Counts1 Counts2]/FileInfo.MeasurementTime/1000*numel(PamMeta.Selected_MT_Patches)/numel(Valid);
    save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
    
    Progress(i/numel(Cor_A),h.Progress.Axes,h.Progress.Text,'Correlating :')
end
guidata(h.Pam,h);
Progress(1);
Update_Display([],[],1);


%%% Set FCSFit Path to FilePath
UserValues.File.FCSPath = FileInfo.Path;
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for (de)selecting individual correlation curves %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Cor_Selection (Obj,~,mode)
h=guidata(findobj('Tag','Pam'));
global UserValues

switch mode
    case 1 %%% (Un)select curves
        if strcmp(Obj.LineStyle,'none')
            Obj.LineStyle = '-';
            Obj.Marker = 'none';
        elseif strcmp(Obj.LineStyle,'-')
            Obj.LineStyle = 'none';
            Obj.Marker = '.';
        end
    case 2 %%% Select all curves
        Active_Axes = h.Cor.Correlations_Tabs.SelectedTab.Children;
        for i=1:numel(Active_Axes.Children)
            Active_Axes.Children(i).LineStyle = '-';
            Active_Axes.Children(i).Marker = 'none';
        end
    case 3 %%% Unselect all curves
        Active_Axes = h.Cor.Correlations_Tabs.SelectedTab.Children;
        for i=1:numel(Active_Axes.Children)
            Active_Axes.Children(i).LineStyle = 'none';
            Active_Axes.Children(i).Marker = '.';
        end
    case 4 %%% Save selected correlations
        Active_Axes = h.Cor.Correlations_Tabs.SelectedTab.Children(strcmp('axes',get(h.Cor.Correlations_Tabs.SelectedTab.Children,'Type')));
        Data = Active_Axes.UserData;
        Current_FileName = Data{1};
        Header = Data{2}; %#ok<NASGU>
        Counts = Data{3};
        Cor_Times = Data{5};
        Use = [];
        for i=1:numel(Active_Axes.Children)
            if strcmp(Active_Axes.Children(i).LineStyle,'-')
                Use(end+1)=i; %#ok<AGROW>
            end
        end
        Valid = Data{4}(Use);
        Cor_Array = Data{8}(:,Use);
        %%%Averages Cor Array
        if size(Cor_Array,2)>1
            Cor_Average = mean(Cor_Array,2);
            %Cor_SEM=std(Cor_Array,0,2)/sqrt(size(Cor_Array,2));
            %%% Averages files before saving to reduce errorbars
            Amplitude=sum(Cor_Array,1);
            Cor_Norm=Cor_Array./repmat(Amplitude,[size(Cor_Array,1),1])*mean(Amplitude);
            Cor_SEM=std(Cor_Norm,0,2)/sqrt(size(Cor_Array,2));
            
        elseif size(Cor_Array,2)==1
            Cor_Average = Cor_Array;
            Cor_SEM = Cor_Array;
        elseif isempty(Cor_Array)
            return;
        end
        
        
        if strcmp(Current_FileName(end-4:end),'.mcor')
            save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
        elseif strcmp(Current_FileName(end-3:end),'.cor')
            %%% Creates new correlation file
            FileID=fopen(Current_FileName,'w');
            
            %%% Writes Heater
            fprintf(FileID, ['Correlation file for: ' strrep(fullfile(FileInfo.Path, FileName),'\','\\') ' of Channels ' UserValues.PIE.Name{Cor_A(i)} ' cross ' UserValues.PIE.Name{Cor_A(i)} '\n']);
            fprintf(FileID, ['Count rate channel 1 [kHz]: ' num2str(Counts(1), '%12.2f') '\n']);
            fprintf(FileID, ['Count rate channel 2 [kHz]: ' num2str(Counts(2), '%12.2f') '\n']);
            fprintf(FileID, ['Valid bins: ' num2str(Valid) '\n']);
            %%% Indicates start of data
            fprintf(FileID, ['Data starts here: ' '\n']);
            %%% Writes data as columns: Time    Averaged    SEM     Individual bins
            fprintf(FileID, ['%8.12f\t%8.8f\t%8.8f' repmat('\t%8.8f',1,numel(Valid)) '\n'], [Cor_Times Cor_Average Cor_SEM Cor_Array]');
            fclose(FileID);
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to keep shift equal  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Phasor_Shift(obj,~)
h=guidata(findobj('Tag','Pam'));
if obj==h.MI.Phasor_Shift
    h.MI.Phasor_Slider.Value=str2double(h.MI.Phasor_Shift.String);
elseif obj==h.MI.Phasor_Slider
    h.MI.Phasor_Shift.String=num2str(h.MI.Phasor_Slider.Value);
end
Update_Display([],[],6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to assign histogram as Phasor reference %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Phasor_UseRef(~,~)
global UserValues PamMeta FileInfo
h=guidata(findobj('Tag','Pam'));
Det=h.MI.Phasor_Det.Value;
%%% Sets reference to 0 in case of shorter MI length
UserValues.Phasor.Reference(Det,:)=0;
% UserValues.Phasor.Reference = zeros(numel(UserValues.Detector.Det),4096);
%%% Assigns current MI histogram as reference
%%% rebin TCSPC data prior to phasor analysis (1 for no rebinning)
rebin = [1:str2double(h.MI.Phasor_Rebin.String):FileInfo.MI_Bins];
for i = 1:(numel(rebin)-1)
    UserValues.Phasor.ReferenceRebinned(Det,i) = sum(PamMeta.MI_Hist{Det}(rebin(i):rebin(i+1)-1));
end
UserValues.Phasor.ReferenceRebinned(Det,numel(rebin)) = sum(PamMeta.MI_Hist{Det}(rebin(end):size(PamMeta.MI_Hist{Det},1))); %bins all remaining values in the last bin
UserValues.Phasor.Reference(Det,1:numel(PamMeta.MI_Hist{Det}))=PamMeta.MI_Hist{Det};
UserValues.Phasor.Reference_Time(Det) = FileInfo.MeasurementTime;
UserValues.Phasor.Reference_MI_Bins = round(FileInfo.MI_Bins/str2double(h.MI.Phasor_Rebin.String));
UserValues.Phasor.Reference_TAC = FileInfo.TACRange;
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to calculate and save Phasor Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Phasor_Calc(~,~)

global UserValues TcspcData FileInfo PamMeta
h=guidata(findobj('Tag','Pam'));

if isempty(FileInfo.LineTimes)
    m = msgbox('Load imaging data to calculate phasor!');
    pause(2)
    close(m)
    return
end

if isfield(UserValues,'Phasor') && isfield(UserValues.Phasor,'Reference')
    
    %%% Determines correct detector and routing
    Det=UserValues.Detector.Det(h.MI.Phasor_Det.Value);
    Rout=UserValues.Detector.Rout(h.MI.Phasor_Det.Value);
    %%% Selects filename to save
    [~,fn,~] = fileparts(FileInfo.FileName{1});
    [FileName,PathName] = uiputfile('*.phr','Save Phasor Data',[FileInfo.Path filesep fn '.phr']);
    % Update PhasorPath
    UserValues.File.PhasorPath = PathName; 
    if ~all(FileName==0)
        Progress(0,h.Progress.Axes, h.Progress.Text,'Calculating Phasor Data (Reference):');
        
        %%% Saves pathname
        UserValues.File.PhasorPath=PathName;
        LSUserValues(1);
        
        %% Calculates reference
        Shift=round(h.MI.Phasor_Slider.Value/str2double(h.MI.Phasor_Rebin.String)); % Shift between reference and file in MI bins, rescaled 
        Ref_MI_Bins = UserValues.Phasor.Reference_MI_Bins;
        Ref_TAC = UserValues.Phasor.Reference_TAC*1e9;
        MI_Bins = round(FileInfo.MI_Bins/str2double(h.MI.Phasor_Rebin.String)); % Total number of MI bins of file
        TAC=str2double(h.MI.Phasor_TAC.String); % Length of full MI range in ns
        Ref_LT=str2double(h.MI.Phasor_Ref.String); % Reference lifetime in ns
        From=str2double(h.MI.Phasor_From.String); % First MI bin to used, rescaled
        To=str2double(h.MI.Phasor_To.String); % Last MI bin to be used, rescaled
        if h.MI.Phasor_FramePopup.Value == 2
            Frames = size(FileInfo.LineTimes,1);
        else
            Frames = 1;
        end
        
        %%% Extract Background and converts it to counts per pixel
        Background_ref = str2num(h.MI.Phasor_BG_Ref.String);
        Background_ref = Background_ref*UserValues.Phasor.Reference_Time(h.MI.Phasor_Det.Value)/Ref_MI_Bins;        
        Background = str2num(h.MI.Phasor_BG.String);
        Background = Background*(mean2(diff(FileInfo.LineTimes,1,2))/FileInfo.Pixels)*size(FileInfo.LineTimes,1);%%% Background is used differently and does not need to be divided by MI_Bins        
        Afterpulsing = str2num(h.MI.Phasor_AP.String)/100;

        
        %%% Calculates theoretical phase and modulation for reference
        Fi_ref = atan(2*pi*Ref_LT/Ref_TAC);
        M_ref  = 1/sqrt(1+(2*pi*Ref_LT/Ref_TAC)^2);
        
        %%% Normalizes reference data
        Ref=circshift(UserValues.Phasor.ReferenceRebinned(h.MI.Phasor_Det.Value,:),[0 round(Shift)]);
        Ref = Ref-sum(Ref)*Afterpulsing/Ref_MI_Bins - Background_ref;
        
        if round(From/str2double(h.MI.Phasor_Rebin.String))>1
            Ref(1:(round(From/str2double(h.MI.Phasor_Rebin.String))-1))=0;
        end
        if round(To/str2double(h.MI.Phasor_Rebin.String))<Ref_MI_Bins
            Ref(round(To/str2double(h.MI.Phasor_Rebin.String))+1:end)=0;
        end
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
        
        %% Pre-Calculations
        Progress(0.01,h.Progress.Axes, h.Progress.Text,'Calculating Phasor Data (Extracting Photons):');
        PIE_MT=TcspcData.MT{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To)*FileInfo.ClockPeriod;
        %%% Creates image and generates photon to pixel index
        Progress(0.15,h.Progress.Axes, h.Progress.Text,'Calculating Phasor Data (Calculating Image):');
        if h.MI.Phasor_FramePopup.Value == 2
            [Intensity, Bin] = CalculateImage(PIE_MT, 4);
        else
            [Intensity, Bin] = CalculateImage(PIE_MT, 2);
        end
        clear PIE_MT;
        Progress(0.55,h.Progress.Axes, h.Progress.Text,'Calculating Phasor Data (Sorting Photons):');
        %%% Extracts microtimes
        PIE_MI=TcspcData.MI{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To);
        %%% rebin TCSPC data prior to phasor analysis (1 for no rebinning)
        PIE_MI = round(PIE_MI/str2double(h.MI.Phasor_Rebin.String));
        %%% Removes invalid photons (usually laser retraction)
        PIE_MI=PIE_MI(Bin~=0);
        Bin=Bin(Bin~=0);
        Pixel= cumsum(Intensity(:));
        
        Intensity=double(reshape(Intensity,[FileInfo.Pixels,FileInfo.Lines,Frames]));
        Intensity=flip(permute(Intensity,[2 1 3]),1);
        
        % capital G and S are the phasor coordinates of the TCSPC channels
        G = cos((2*pi/MI_Bins).*(1:MI_Bins)-Fi_inst)/M_inst;
        S = sin((2*pi/MI_Bins).*(1:MI_Bins)-Fi_inst)/M_inst;
        Progress(0.75,h.Progress.Axes, h.Progress.Text,'Calculating Phasor Data (Calculating Phasor):');
        %% Actual Calculation

        %%% Actual calculation in C++
        % lowercase g and s are the mean phasor coordinates of each pixel
        % Mean_LT is the mean arrival time per pixel in TCSPC bins
        [Mean_LT, g,s] = DoPhasor(PIE_MI, (Bin-1), numel(PIE_MI), numel(Pixel), G, S, 0, [], []);
        
        %%% Reshapes data to images
        % g, s and Mean_LT are pixels x lines x frames
        g=reshape(g,FileInfo.Pixels,FileInfo.Lines,[]);
        s=reshape(s,FileInfo.Pixels,FileInfo.Lines,[]);
        Mean_LT=reshape(Mean_LT,FileInfo.Pixels,FileInfo.Lines,[]);
        g=flip(permute(g,[2 1 3]),1);s=flip(permute(s,[2 1 3]),1);
                   
        %%% Background and Afterpulsing correction
        Use = zeros(1,MI_Bins);
        Use(round(From/str2double(h.MI.Phasor_Rebin.String)):round(To/str2double(h.MI.Phasor_Rebin.String))) = 1/MI_Bins;
        G = sum(G.*Use);
        S = sum(S.*Use);
        g = (g - G*(Afterpulsing + Background./Intensity))./(1-(Afterpulsing+Background./Intensity).*sum(Use));
        g(isnan(g))=0;
        s = (s - S*(Afterpulsing + Background./Intensity))./(1-(Afterpulsing+Background./Intensity).*sum(Use));
        s(isnan(s))=0;
                       
        %% Data Formating
        neg=find(g<0 & s<0);
        g(neg)=-g(neg);
        s(neg)=-s(neg);
        Progress(0.90,h.Progress.Axes, h.Progress.Text,'Calculating Phasor Data (Saving Data):');
        %% Saves data
        %%% Calculates additional data
        PamMeta.g=squeeze(sum(g.*Intensity,3)./sum(Intensity,3));
        PamMeta.s=squeeze(sum(s.*Intensity,3)./sum(Intensity,3));
        PamMeta.Fi=atan(PamMeta.s./PamMeta.g); PamMeta.Fi(isnan(PamMeta.Fi))=0;
        PamMeta.M=sqrt(PamMeta.s.^2+PamMeta.g.^2);PamMeta.M(isnan(PamMeta.M))=0;
        PamMeta.TauP=real(tan(PamMeta.Fi)./(2*pi/TAC));PamMeta.TauP(isnan(PamMeta.TauP))=0;
        PamMeta.TauM=real(sqrt((1./(PamMeta.s.^2+PamMeta.g.^2))-1)/(2*pi/TAC));PamMeta.TauM(isnan(PamMeta.TauM))=0;
        PamMeta.Phasor_Int = mean(Intensity,3); %for displaying purposes in PAM, even for framewise phasor this needs to be a single image
        
        %%% Creates data to save and saves referenced file
        Freq=1/TAC*10^9;
        FileNames=FileInfo.FileName;
        Path=FileInfo.Path;
        Imagetime=mean(diff(FileInfo.ImageTimes));
        Frames=numel(FileInfo.ImageTimes)-1;
        Lines=FileInfo.Lines;
        Pixels=FileInfo.Pixels;
        Fi=PamMeta.Fi;
        M=PamMeta.M;
        TauP=PamMeta.TauP;
        TauM=PamMeta.TauM;
        Type = FileInfo.Type;
        
        if h.MI.Phasor_FramePopup.Value == 1
            g=squeeze(g); s=squeeze(s); Intensity =squeeze(Intensity);
            save(fullfile(PathName,FileName), 'g','s','Mean_LT','Fi','M','TauP','TauM','Intensity','Lines','Pixels','Freq','Imagetime','Frames','FileNames','Path','Type','-v7.3');
        else
            save(fullfile(PathName,[FileName(1:end-3) 'phf']), 'g','s','Mean_LT','Fi','M','TauP','TauM','Intensity','Lines','Pixels','Freq','Imagetime','Frames','FileNames','Path','Type','-v7.3');
            g = PamMeta.g; s= PamMeta.s; Intensity =squeeze(sum(Intensity,3));
            save(fullfile(PathName,FileName), 'g','s','Mean_LT','Fi','M','TauP','TauM','Intensity','Lines','Pixels','Freq','Imagetime','Frames','FileNames','Path','Type','-v7.3');
        end
        
        h.Image.Type.String={'Intensity';'Mean arrival time';'TauP';'TauM';'g';'s'};
    end
    
end
Progress(1,h.Progress.Axes, h.Progress.Text,FileInfo.FileName{1});
h.Progress.Text.String = FileInfo.FileName{1};
h.Progress.Axes.Color=UserValues.Look.Control;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for keeping Burst GUI updated  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_BurstGUI(obj,~)
global UserValues
h=guidata(findobj('Tag','Pam'));
if isempty(obj) || obj == h.Burst.BurstSearchSelection_Popupmenu
    if obj == h.Burst.BurstSearchSelection_Popupmenu %executed on change in Popupmenu
        %update the UserValues
        UserValues.BurstSearch.Method = obj.Value;
        BAMethod = h.Burst.BurstSearchMethods{UserValues.BurstSearch.Method};
        LSUserValues(1);
    else %executed on startup, set GUI according to stored BurstSearch Method in UserValues settings
        BAMethod = h.Burst.BurstSearchMethods{UserValues.BurstSearch.Method};
        h.Burst.BurstSearchSelection_Popupmenu.Value = UserValues.BurstSearch.Method;
        h.Burst.BurstSearchSmoothing_Popupmenu.Value = UserValues.BurstSearch.SmoothingMethod;
    end
    TableContent = h.Burst.BurstPIE_Table_Content.(BAMethod);
    h.Burst.BurstPIE_Table.RowName = TableContent.RowName;
    h.Burst.BurstPIE_Table.ColumnName = TableContent.ColumnName;
    h.Burst.BurstPIE_Table.ColumnEditable=true(numel(h.Burst.BurstPIE_Table.ColumnName),1)';
    
    BurstPIE_Table_Data = UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method};
    BurstPIE_Table_Format = cell(1,size(BurstPIE_Table_Data,2));
    BurstPIE_Table_Format(:) = {UserValues.PIE.Name};
    
    BurstPIE_Table_Data = UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method};
    h.Burst.BurstPIE_Table.Data = BurstPIE_Table_Data;
    h.Burst.BurstPIE_Table.ColumnFormat = BurstPIE_Table_Format;
    switch UserValues.BurstSearch.Method
        case {1,3,5}
            % APBS
            h.Burst.BurstSearchSelection_Popupmenu.Position(3) = 0.9;
            h.Burst.BurstSearchSelection_ANDOR_Popupmenu.Visible = 'off';
        case {2,4,6}
            % D/TCBS
            h.Burst.BurstSearchSelection_Popupmenu.Position(3) = 0.5;
            h.Burst.BurstSearchSelection_ANDOR_Popupmenu.Visible = 'on';
    end
elseif obj == h.Burst.BurstSearchSmoothing_Popupmenu
    UserValues.BurstSearch.SmoothingMethod = obj.Value;
    % if UserValues.BurstSearch.SmoothingMethod == 4
    %     UserValues.BurstSearch.SmoothingMethod = 1;
    % end
    LSUserValues(1);
    BAMethod = h.Burst.BurstSearchMethods{UserValues.BurstSearch.Method};
elseif obj == h.Burst.BurstSearchSelection_ANDOR_Popupmenu
    UserValues.BurstSearch.LogicalGate = obj.String{obj.Value};
    BAMethod = h.Burst.BurstSearchMethods{UserValues.BurstSearch.Method};
end
%set parameter for the edit boxes
h.Burst.BurstParameter1_Edit.String = num2str(UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.SmoothingMethod,UserValues.BurstSearch.Method}(1));
h.Burst.BurstParameter2_Edit.String = num2str(UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.SmoothingMethod,UserValues.BurstSearch.Method}(2));
h.Burst.BurstParameter3_Edit.String = num2str(UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.SmoothingMethod,UserValues.BurstSearch.Method}(3));
h.Burst.BurstParameter4_Edit.String = num2str(UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.SmoothingMethod,UserValues.BurstSearch.Method}(4));
h.Burst.BurstParameter5_Edit.String = num2str(UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.SmoothingMethod,UserValues.BurstSearch.Method}(5));
h.Burst.BurstParameter6_Edit.String = num2str(UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.SmoothingMethod,UserValues.BurstSearch.Method}(6));
BurstSearchParameterUpdate([],[]);
%%% Update Text based on BAMethod AND Smoothing Method
h.Burst.BurstParameter2_Text.Visible = 'on';
h.Burst.BurstParameter2_Edit.Visible = 'on';
h.Burst.BurstParameter6_Edit.Visible = 'off';
h.Burst.BurstParameter2_Checkbox.Visible = 'off';
h.Burst.BurstParameter2_Edit.Position(3) = 0.2;
switch UserValues.BurstSearch.SmoothingMethod
    case 1 %Sliding Time Window
        h.Burst.BurstParameter2_Text.String = 'Time Window [us]:';
        switch BAMethod %%% define which Burst Search Parameters are to be displayed
            case 'APBS_twocolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Photons per Time Window:';
                h.Burst.BurstParameter4_Text.Visible = 'off';
                h.Burst.BurstParameter4_Edit.Visible = 'off';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'DCBS_twocolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Photons per Time Window GX:';
                h.Burst.BurstParameter4_Text.Visible = 'on';
                h.Burst.BurstParameter4_Text.String = 'Photons per Time Window RR:';
                h.Burst.BurstParameter4_Edit.Visible = 'on';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
                h.Burst.BurstParameter6_Edit.Visible = 'on';
                h.Burst.BurstParameter2_Edit.Position(3) = 0.1;
            case 'APBS_threecolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Photons per Time Window:';
                h.Burst.BurstParameter4_Text.Visible = 'off';
                h.Burst.BurstParameter4_Edit.Visible = 'off';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'TCBS_threecolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Photons per Time Window BX:';
                h.Burst.BurstParameter4_Text.Visible = 'on';
                h.Burst.BurstParameter4_Text.String = 'Photons per Time Window GX.';
                h.Burst.BurstParameter4_Edit.Visible = 'on';
                h.Burst.BurstParameter5_Text.Visible = 'on';
                h.Burst.BurstParameter5_Text.String = 'Photons per Time Window RR:';
                h.Burst.BurstParameter5_Edit.Visible = 'on';
            case 'APBS_twocolornoMFD'
                h.Burst.BurstParameter3_Text.String = 'Photons per Time Window:';
                h.Burst.BurstParameter4_Text.Visible = 'off';
                h.Burst.BurstParameter4_Edit.Visible = 'off';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'DCBS_twocolornoMFD'
                h.Burst.BurstParameter3_Text.String = 'Photons per Time Window GX:';
                h.Burst.BurstParameter4_Text.Visible = 'on';
                h.Burst.BurstParameter4_Text.String = 'Photons per Time Window RR:';
                h.Burst.BurstParameter4_Edit.Visible = 'on';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
                h.Burst.BurstParameter6_Edit.Visible = 'on';
                h.Burst.BurstParameter2_Edit.Position(3) = 0.1;
        end
    case 2 % Interphoton time with Lee filter
        h.Burst.BurstParameter2_Text.String = 'Smoothing Window (2*N+1):';
        switch BAMethod %%% define which Burst Search Parameters are to be displayed
            case 'APBS_twocolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Interphoton Time [us]:';
                h.Burst.BurstParameter4_Text.Visible = 'off';
                h.Burst.BurstParameter4_Edit.Visible = 'off';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'DCBS_twocolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Interphoton Time GX [us]:';
                h.Burst.BurstParameter4_Text.Visible = 'on';
                h.Burst.BurstParameter4_Text.String = 'Interphoton Time RR [us]:';
                h.Burst.BurstParameter4_Edit.Visible = 'on';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
                h.Burst.BurstParameter6_Edit.Visible = 'on';
                h.Burst.BurstParameter2_Edit.Position(3) = 0.1;
            case 'APBS_threecolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Interphoton Time [us]:';
                h.Burst.BurstParameter4_Text.Visible = 'off';
                h.Burst.BurstParameter4_Edit.Visible = 'off';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'TCBS_threecolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Interphoton Time BX [us]:';
                h.Burst.BurstParameter4_Text.Visible = 'on';
                h.Burst.BurstParameter4_Text.String = 'Interphoton Time GX [us]:';
                h.Burst.BurstParameter4_Edit.Visible = 'on';
                h.Burst.BurstParameter5_Text.Visible = 'on';
                h.Burst.BurstParameter5_Text.String = 'Interphoton Time RR [us]:';
                h.Burst.BurstParameter5_Edit.Visible = 'on';
            case 'APBS_twocolornoMFD'
                h.Burst.BurstParameter3_Text.String = 'Interphoton Time [us]:';
                h.Burst.BurstParameter4_Text.Visible = 'off';
                h.Burst.BurstParameter4_Edit.Visible = 'off';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'DCBS_twocolornoMFD'
                h.Burst.BurstParameter3_Text.String = 'Interphoton Time GX [us]:';
                h.Burst.BurstParameter4_Text.Visible = 'on';
                h.Burst.BurstParameter4_Text.String = 'Interphoton Time RR [us]:';
                h.Burst.BurstParameter4_Edit.Visible = 'on';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
                h.Burst.BurstParameter6_Edit.Visible = 'on';
                h.Burst.BurstParameter2_Edit.Position(3) = 0.1;
        end
    case 3 % CUSUM burst search        
        h.Burst.BurstParameter2_Text.String = 'Background [kHz]:';
        switch BAMethod %%% define which Burst Search Parameters are to be displayed
            case 'APBS_twocolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Threshold [kHz]:';
                h.Burst.BurstParameter4_Text.Visible = 'off';
                h.Burst.BurstParameter4_Edit.Visible = 'off';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'DCBS_twocolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Threshold GX [kHz]:';
                h.Burst.BurstParameter4_Text.Visible = 'on';
                h.Burst.BurstParameter4_Text.String = 'Threshold RR [kHz]:';
                h.Burst.BurstParameter4_Edit.Visible = 'on';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
                h.Burst.BurstParameter6_Edit.Visible = 'on';
                h.Burst.BurstParameter2_Edit.Position(3) = 0.1;
            case 'APBS_threecolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Threshold [kHz]:';
                h.Burst.BurstParameter4_Text.Visible = 'off';
                h.Burst.BurstParameter4_Edit.Visible = 'off';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'TCBS_threecolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Threshold BX [kHz]:';
                h.Burst.BurstParameter4_Text.Visible = 'on';
                h.Burst.BurstParameter4_Text.String = 'Threshold GX [kHz]:';
                h.Burst.BurstParameter4_Edit.Visible = 'on';
                h.Burst.BurstParameter5_Text.Visible = 'on';
                h.Burst.BurstParameter5_Text.String = 'Threshold RR [kHz]:';
                h.Burst.BurstParameter5_Edit.Visible = 'on';
            case 'APBS_twocolornoMFD'
                h.Burst.BurstParameter3_Text.String = 'Threshold [kHz]:';
                h.Burst.BurstParameter4_Text.Visible = 'off';
                h.Burst.BurstParameter4_Edit.Visible = 'off';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'DCBS_twocolornoMFD'
                h.Burst.BurstParameter3_Text.String = 'Threshold GX [kHz]:';
                h.Burst.BurstParameter4_Text.Visible = 'on';
                h.Burst.BurstParameter4_Text.String = 'Threshold RR [kHz]:';
                h.Burst.BurstParameter4_Edit.Visible = 'on';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
                h.Burst.BurstParameter6_Edit.Visible = 'on';
                h.Burst.BurstParameter2_Edit.Position(3) = 0.1;
        end
    case 4 % changepoint burst search
        h.Burst.BurstParameter2_Text.Visible = 'off';
        h.Burst.BurstParameter2_Edit.Visible = 'off';
        h.Burst.BurstParameter2_Checkbox.Visible = 'on';
        switch BAMethod %%% define which Burst Search Parameters are to be displayed
            case 'APBS_twocolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Threshold [kHz]:';
                h.Burst.BurstParameter4_Text.Visible = 'off';
                h.Burst.BurstParameter4_Edit.Visible = 'off';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'DCBS_twocolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Threshold GX [kHz]:';
                h.Burst.BurstParameter4_Text.Visible = 'on';
                h.Burst.BurstParameter4_Text.String = 'Threshold RR [kHz]:';
                h.Burst.BurstParameter4_Edit.Visible = 'on';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'APBS_threecolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Threshold [kHz]:';
                h.Burst.BurstParameter4_Text.Visible = 'off';
                h.Burst.BurstParameter4_Edit.Visible = 'off';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'TCBS_threecolorMFD'
                h.Burst.BurstParameter3_Text.String = 'Threshold BX [kHz]:';
                h.Burst.BurstParameter4_Text.Visible = 'on';
                h.Burst.BurstParameter4_Text.String = 'Threshold GX [kHz]:';
                h.Burst.BurstParameter4_Edit.Visible = 'on';
                h.Burst.BurstParameter5_Text.Visible = 'on';
                h.Burst.BurstParameter5_Text.String = 'Threshold RR [kHz]:';
                h.Burst.BurstParameter5_Edit.Visible = 'on';
            case 'APBS_twocolornoMFD'
                h.Burst.BurstParameter3_Text.String = 'Threshold [kHz]:';
                h.Burst.BurstParameter4_Text.Visible = 'off';
                h.Burst.BurstParameter4_Edit.Visible = 'off';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';
            case 'DCBS_twocolornoMFD'
                h.Burst.BurstParameter3_Text.String = 'Threshold GX [kHz]:';
                h.Burst.BurstParameter4_Text.Visible = 'on';
                h.Burst.BurstParameter4_Text.String = 'Threshold RR [kHz]:';
                h.Burst.BurstParameter4_Edit.Visible = 'on';
                h.Burst.BurstParameter5_Text.Visible = 'off';
                h.Burst.BurstParameter5_Edit.Visible = 'off';               
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for updating BurstSearch Parameters in UserValues %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BurstSearchParameterUpdate(obj,~)
global UserValues
h=guidata(findobj('Tag','Pam'));
if obj == h.Burst.BurstPIE_Table %change in PIE channel selection
    UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method} = obj.Data;
elseif obj == h.Burst.BurstParameter2_Checkbox
    UserValues.BurstSearch.ChangePointIncludeSigma = h.Burst.BurstParameter2_Checkbox.Value;
else %change in edit boxes
    UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.SmoothingMethod,UserValues.BurstSearch.Method} = [str2double(h.Burst.BurstParameter1_Edit.String),...
        str2double(h.Burst.BurstParameter2_Edit.String), str2double(h.Burst.BurstParameter3_Edit.String), str2double(h.Burst.BurstParameter4_Edit.String),...
        str2double(h.Burst.BurstParameter5_Edit.String),str2double(h.Burst.BurstParameter6_Edit.String)];
end
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Exports the total measurement for PDA  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export_total_to_PDA(obj,~)
global FileInfo UserValues
h = guidata(obj);
%%% Only implemented for 2color FRET
BAMethod = UserValues.BurstSearch.Method;
if ~any(BAMethod == [1,2])
    disp('Only implemented for 2color FRET')
    return;
end

%%% read out photons
Photons{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Macrotime');
Photons{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2},'Macrotime');
Photons{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Macrotime');
Photons{4} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2},'Macrotime');
Photons{5} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Macrotime');
Photons{6} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2},'Macrotime');

timebin = 1E-3; %%% hardcoded
timebinMT = timebin/FileInfo.ClockPeriod;
maxMT = max(cell2mat(cellfun(@(x) x(end),Photons,'UniformOutput',false)));

PDA.NGP = histcounts(Photons{1},0:timebinMT:maxMT);
PDA.NGS = histcounts(Photons{2},0:timebinMT:maxMT);
PDA.NFP = histcounts(Photons{3},0:timebinMT:maxMT);
PDA.NFS = histcounts(Photons{4},0:timebinMT:maxMT);
PDA.NRP = histcounts(Photons{5},0:timebinMT:maxMT);
PDA.NRS = histcounts(Photons{6},0:timebinMT:maxMT);

PDA.NG = PDA.NGP+ PDA.NGS;
PDA.NF = PDA.NFP + PDA.NFS;
PDA.NR = PDA.NRP + PDA.NRS;

% Background for all burst channels
Background.Background_GGpar = ...
    UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1}));
Background.Background_GGperp = ...
    UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2}));
Background.Background_GRpar = ...
    UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1}));
Background.Background_GRperp = ...
    UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2}));
Background.Background_RRpar = ...
    UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1}));
Background.Background_RRperp = ...
    UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2}));

PDA.Background = Background;

PDA.Corrections = UserValues.BurstBrowser.Corrections;
PDA.Type = 'Total Measurement';

[pathstr, FileName, ~] = fileparts(fullfile(FileInfo.Path,FileInfo.FileName{1}));
FileName = fullfile(pathstr,[FileName '_' sprintf('%d',timebin*1E3) 'ms.pda']);
FileName = GenerateName(FileName, 1);
save(FileName, 'PDA', 'timebin')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Performs a Burst Analysis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_BurstAnalysis(obj,~)
global FileInfo UserValues PamMeta TcspcData
%% Initialization
h = guidata(findobj('Tag','Pam'));
%%% clear preview burst data still in workspace
PamMeta.BurstData = [];

%%% Set Progress Bar
h.Progress.Text.String = 'Performing Burst Search...';
drawnow;

%%% Reset BurstSearch Button Color
h.Burst.Button.ForegroundColor = UserValues.Look.Fore;
%% Burst Search
%%% The Burst Search Procedure outputs three vectors containing the
%%% Macrotime (AllPhotons), Microtime (AllPhotons_Microtime) and the
%%% Channel as a Number (Channel) of all Photons in the PIE channels used
%%% for the BurstSearch.
%%% The Bursts are defined via the start and stop vectors, containing the
%%% absolute photon number (NOT the macrotime) of the first and last photon
%%% in a burst. Additonally, the BurstSearch puts out the Number of Photons
%%% per Burst directly.

%%% The Channel Information is encoded as follows:

%%% 2color-MFD:
%%% 1   2   GG1 GG2
%%% 3   4   GR1 GR2
%%% 5   6   RR1 RR2

%%% 3color-MFD
%%% 1   2   BB1 BB2
%%% 3   4   BG1 BG2
%%% 5   6   BR1 BR2
%%% 7   8   GG1 GG2
%%% 9   10  GR1 GR2
%%% 11  12  RR1 RR2

%%% 2color-noMFD
%%% 1       GG
%%% 2       GR
%%% 3       RR

BAMethod = UserValues.BurstSearch.Method;
SmoothingMethod = UserValues.BurstSearch.SmoothingMethod;
DCBS_logical_gate = UserValues.BurstSearch.LogicalGate;
%achieve loading of less photons by using chunksize of preview and first
%chunk
if FileInfo.MeasurementTime > 600 % Measurement was less than 10 minutes
    Number_of_Chunks = numel(find(PamMeta.Selected_MT_Patches));
    chunks_to_use = find(PamMeta.Selected_MT_Patches)';
    ChunkSize = FileInfo.MeasurementTime/numel(PamMeta.Selected_MT_Patches)/60;
else % short measurement, only use one chunk
    Number_of_Chunks = 1;
    chunks_to_use = 1;
    ChunkSize = FileInfo.MeasurementTime; 
end
%%% Preallocation
Macrotime_dummy = cell(Number_of_Chunks,1);
Microtime_dummy = cell(Number_of_Chunks,1);
Channel_dummy = cell(Number_of_Chunks,1);
detected_channel_dummy = cell(Number_of_Chunks,1);

if UserValues.BurstSearch.SaveTotalPhotonStream
    start_all = cell(Number_of_Chunks,1);
    stop_all = cell(Number_of_Chunks,1);
    Macrotime_all = cell(Number_of_Chunks,1);
    Microtime_all = cell(Number_of_Chunks,1);
    Channel_all = cell(Number_of_Chunks,1);
end

save_BID = true; % save burst IDs
if save_BID
    %%% to determine the global photon number, we need the array of all
    %%% photons in the measurement
    GlobalMacrotime = sort(vertcat(TcspcData.MT{:}));
    BID_dummy = cell(Number_of_Chunks,1);
end

%%% do not do a burst search, but simply take the indices of the start/stop
%%% photons from a burst ID *.bst file obtained from the Seidel software
if obj == h.Burst.Button_Menu_fromBurstIDs
    from_BurstIDs = true;
    [FileName,PathName] = uigetfile({'*.bst'}, 'Choose a BurstID file (*.bst)', UserValues.File.Path, 'MultiSelect', 'off');
    BurstIDs = dlmread(fullfile(PathName,FileName),'\t');
    BID_path = PathName;
    BID_file = FileName;
else
    from_BurstIDs = false;
end

for i = chunks_to_use
    Progress((i-1)/Number_of_Chunks,h.Progress.Axes, h.Progress.Text,'Performing Burst Search...');
    if any(BAMethod == [1 2]) %ACBS 2 Color
        %prepare photons
        %read out macrotimes for all channels
        Photons{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Macrotime',i,ChunkSize);
        Photons{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2},'Macrotime',i,ChunkSize);
        Photons{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Macrotime',i,ChunkSize);
        Photons{4} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2},'Macrotime',i,ChunkSize);
        Photons{5} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Macrotime',i,ChunkSize);
        Photons{6} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2},'Macrotime',i,ChunkSize);
        AllPhotons_unsort = vertcat(Photons{:});
        %sort macrotime and use index to sort microtime and channel
        %information
        [AllPhotons, index] = sort(AllPhotons_unsort);
        clear AllPhotons_unsort
        %get colors of photons
        chan_temp = uint8([1*ones(1,numel(Photons{1})) 2*ones(1,numel(Photons{2})) 3*ones(1,numel(Photons{3}))...
            4*ones(1,numel(Photons{4})) 5*ones(1,numel(Photons{5})) 6*ones(1,numel(Photons{6}))]);
        Channel = chan_temp(index);
        Channel = Channel';
        clear chan_temp
        
        %%% read out microtimes for all channels
        MI{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Microtime',i,ChunkSize);
        MI{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2},'Microtime',i,ChunkSize);
        MI{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Microtime',i,ChunkSize);
        MI{4} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2},'Microtime',i,ChunkSize);
        MI{5} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Microtime',i,ChunkSize);
        MI{6} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2},'Microtime',i,ChunkSize);
        
        MI = vertcat(MI{:});
        AllPhotons_Microtime = MI(index);
        clear MI index
        
        if ~from_BurstIDs
            if BAMethod == 1
                T = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2);
                M = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3);
                L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
                [start, stop, Number_of_Photons] = Perform_BurstSearch(AllPhotons,[],'APBS',T,M,L);
            elseif BAMethod == 2
                T = [UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2),...
                    UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(6)];
                M = [UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3),...
                    UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(4)];
                L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
                [start, stop, Number_of_Photons,detected_channel_dummy{i}] = Perform_BurstSearch(AllPhotons,Channel,'DCBS',T,M,L,DCBS_logical_gate);
            end
        end
    elseif any(BAMethod == [3,4])
        Photons{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Macrotime',i,ChunkSize);
        Photons{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2},'Macrotime',i,ChunkSize);
        Photons{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Macrotime',i,ChunkSize);
        Photons{4} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2},'Macrotime',i,ChunkSize);
        Photons{5} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Macrotime',i,ChunkSize);
        Photons{6} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2},'Macrotime',i,ChunkSize);
        Photons{7} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,1},'Macrotime',i,ChunkSize);
        Photons{8} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,2},'Macrotime',i,ChunkSize);
        Photons{9} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{5,1},'Macrotime',i,ChunkSize);
        Photons{10} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{5,2},'Macrotime',i,ChunkSize);
        Photons{11} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,1},'Macrotime',i,ChunkSize);
        Photons{12} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,2},'Macrotime',i,ChunkSize);
        AllPhotons_unsort = vertcat(Photons{:});
        %sort
        [AllPhotons, index] = sort(AllPhotons_unsort);
        clear AllPhotons_unsort
        %get colors of photons
        chan_temp = uint8([1*ones(1,numel(Photons{1})) 2*ones(1,numel(Photons{2})) 3*ones(1,numel(Photons{3}))...
            4*ones(1,numel(Photons{4})) 5*ones(1,numel(Photons{5})) 6*ones(1,numel(Photons{6}))...
            7*ones(1,numel(Photons{7})) 8*ones(1,numel(Photons{8})) 9*ones(1,numel(Photons{9}))...
            10*ones(1,numel(Photons{10})) 11*ones(1,numel(Photons{11})) 12*ones(1,numel(Photons{12}))]);
        Channel = chan_temp(index);
        Channel = Channel';
        clear chan_temp
        
        %%% read out microtimes
        MI{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Microtime',i,ChunkSize);
        MI{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2},'Microtime',i,ChunkSize);
        MI{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Microtime',i,ChunkSize);
        MI{4} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2},'Microtime',i,ChunkSize);
        MI{5} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Microtime',i,ChunkSize);
        MI{6} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2},'Microtime',i,ChunkSize);
        MI{7} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,1},'Microtime',i,ChunkSize);
        MI{8} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,2},'Microtime',i,ChunkSize);
        MI{9} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{5,1},'Microtime',i,ChunkSize);
        MI{10} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{5,2},'Microtime',i,ChunkSize);
        MI{11} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,1},'Microtime',i,ChunkSize);
        MI{12} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,2},'Microtime',i,ChunkSize);
        
        MI = vertcat(MI{:});
        AllPhotons_Microtime = MI(index);
        clear MI index
        
        if ~from_BurstIDs
            if BAMethod == 3 %ACBS 3 Color
                T = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2);
                M = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3);
                L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
                [start, stop, Number_of_Photons] = Perform_BurstSearch(AllPhotons,[],'APBS',T,M,L);
            elseif BAMethod == 4 %TCBS
                T = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2);
                M = [UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3),...
                    UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(4),...
                    UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(5)];
                L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
                [start, stop, Number_of_Photons] = Perform_BurstSearch(AllPhotons,Channel,'TCBS',T,M,L,DCBS_logical_gate);
            end
        end
    elseif any(BAMethod == [5,6]) %2 color no MFD
        %prepare photons
        %read out macrotimes for all channels
        Photons{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Macrotime',i,ChunkSize);
        Photons{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Macrotime',i,ChunkSize);
        Photons{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Macrotime',i,ChunkSize);
        AllPhotons_unsort = vertcat(Photons{:});
        %sort
        [AllPhotons, index] = sort(AllPhotons_unsort);
        clear AllPhotons_unsort
        %get colors of photons
        chan_temp = uint8([1*ones(1,numel(Photons{1})) 2*ones(1,numel(Photons{2})) 3*ones(1,numel(Photons{3}))]);
        Channel = chan_temp(index);
        Channel = Channel';
        clear chan_temp
        
        %%%read out microtimes
        MI{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Microtime',i,ChunkSize);
        MI{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Microtime',i,ChunkSize);
        MI{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Microtime',i,ChunkSize);
        
        MI = vertcat(MI{:});
        AllPhotons_Microtime = MI(index);
        clear MI index
        
        if ~from_BurstIDs
            if BAMethod == 5 %ACBS 2 Color-noMFD
                T = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2);
                M = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3);
                L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
                [start, stop, Number_of_Photons] = Perform_BurstSearch(AllPhotons,[],'APBS',T,M,L);
            elseif BAMethod == 6 %DCBS 2 Color-noMFD
                T = [UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2),...
                    UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(6)];
                M = [UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3),...
                    UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(4)];
                L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
                [start, stop, Number_of_Photons,detected_channel_dummy{i}] = Perform_BurstSearch(AllPhotons,Channel,'DCBS-noMFD',T,M,L,DCBS_logical_gate);
            end
        end
    end
    
    if from_BurstIDs
        %%% map the global photon numbers ("burstIDs") to the AllPhotons array
        [~,start] = ismember(GlobalMacrotime(BurstIDs(:,1)),AllPhotons);
        [~,stop] = ismember(GlobalMacrotime(BurstIDs(:,2)),AllPhotons);
        valid = start > 0 & stop > 0;
        start = start(valid); stop = stop(valid);
        Number_of_Photons = stop-start+1;
    end
    
    %%% Process Data for this Chunk
    %%% Extract Macrotime, Microtime and Channel Information burstwise
    Macrotime_dummy{i} = cell(numel(Number_of_Photons),1);
    Microtime_dummy{i} = cell(numel(Number_of_Photons),1);
    Channel_dummy{i} = cell(numel(Number_of_Photons),1);
    for j = 1:numel(Number_of_Photons)
        Macrotime_dummy{i}{j} = AllPhotons(start(j):stop(j));
        Microtime_dummy{i}{j} = AllPhotons_Microtime(start(j):stop(j));
        Channel_dummy{i}{j} = Channel(start(j):stop(j));
    end
    if UserValues.BurstSearch.SaveTotalPhotonStream
        %%% Save start/stop
        start_all{i} = start; stop_all{i} = stop;
        %%% Save whole photon stream
        Macrotime_all{i} = AllPhotons;
        Microtime_all{i} = AllPhotons_Microtime;
        Channel_all{i} = Channel;
        % Macrotime_all{i} = uint64(AllPhotons);
        % Microtime_all{i} = uint16(AllPhotons_Microtime);
        % Channel_all{i} = uint8(Channel);
    end
    if save_BID
        % find the index of all starts and stops
        if ~isempty(start)
            [~,BID_dummy{i}(:,1)] = ismember(AllPhotons(start),GlobalMacrotime);
            [~,BID_dummy{i}(:,2)] = ismember(AllPhotons(stop),GlobalMacrotime);
        end
    end
end

%%% Concatenate data from chunks
Macrotime = vertcat(Macrotime_dummy{:});
Microtime = vertcat(Microtime_dummy{:});
Channel = vertcat(Channel_dummy{:});
detected_channel = vertcat(detected_channel_dummy{:});

if UserValues.BurstSearch.SaveTotalPhotonStream
    start = [];
    stop = [];
    count = 0;
    for i = 1:Number_of_Chunks
        start = [start; start_all{i}+count];
        stop = [stop; stop_all{i}+count];
        count = count + numel(Macrotime_all{i});
    end
    start_all = start;
    stop_all = stop;
    Macrotime_all = vertcat(Macrotime_all{:});
    Microtime_all = vertcat(Microtime_all{:});
    Channel_all = vertcat(Channel_all{:});
end
if save_BID
    BID = vertcat(BID_dummy{:});
end
clear Macrotime_dummy Microtime_dummy Channel_dummy BID_dummy
%% Parameter Calculation
Progress(0,h.Progress.Axes, h.Progress.Text, 'Calculating Burstwise Parameters...');

Number_of_Bursts = numel(Macrotime);
if Number_of_Bursts == 0 % no bursts were found
    disp('No bursts detected.');
    Progress(1,h.Progress.Axes, h.Progress.Text, 'Done');
    return;
end

Number_of_Photons = cellfun(@numel,Macrotime);
Mean_Macrotime = cellfun(@mean,Macrotime)*FileInfo.ClockPeriod;
Duration = cellfun(@(x) max(x)-min(x),Macrotime)*FileInfo.ClockPeriod/1E-3;

Progress(0.1,h.Progress.Axes, h.Progress.Text, 'Calculating Burstwise Parameters...');

if any(BAMethod == [1 2]) %total of 6 channels
    Number_of_Photons_per_Chan = zeros(Number_of_Bursts,6);
    for i = 1:6 %polarization resolved
        Number_of_Photons_per_Chan(:,i) = cellfun(@(x) sum(x==i),Channel);
    end
    
    %%% Calculate RAW Efficienyc and Stoichiometry
    E = sum(Number_of_Photons_per_Chan(:,[3 4]),2)./(sum(Number_of_Photons_per_Chan(:,[1 2]),2) + sum(Number_of_Photons_per_Chan(:,[3 4]),2));
    S = sum(Number_of_Photons_per_Chan(:,[1 2 3 4]),2)./Number_of_Photons;
    Proximity_Ratio = E;
    
    %%% Calculate RAW Anisotropies
    rGG = (Number_of_Photons_per_Chan(:,1)-Number_of_Photons_per_Chan(:,2))./(Number_of_Photons_per_Chan(:,1)+2*Number_of_Photons_per_Chan(:,2));
    rGR = (Number_of_Photons_per_Chan(:,3)-Number_of_Photons_per_Chan(:,4))./(Number_of_Photons_per_Chan(:,3)+2*Number_of_Photons_per_Chan(:,4));
    rRR = (Number_of_Photons_per_Chan(:,5)-Number_of_Photons_per_Chan(:,6))./(Number_of_Photons_per_Chan(:,5)+2*Number_of_Photons_per_Chan(:,6));
    
    %%% create placeholder arrays for lifetimes and 2CDE filter calculation
    tauGG = zeros(Number_of_Bursts,1);
    tauRR = zeros(Number_of_Bursts,1);
    ALEX_2CDE = zeros(Number_of_Bursts,1);
    FRET_2CDE = zeros(Number_of_Bursts,1);
    
    Progress(0.3,h.Progress.Axes, h.Progress.Text, 'Calculating Burstwise Parameters...');
    
    Number_of_Photons_per_Color = zeros(Number_of_Bursts,3);
    for i = 1:3
        Number_of_Photons_per_Color(:,i) = Number_of_Photons_per_Chan(:,2*i-1)+Number_of_Photons_per_Chan(:,2*i);
    end
    Mean_Macrotime_per_Chan = zeros(Number_of_Bursts,6);
    Duration_per_Chan = cell(Number_of_Bursts,6);
    for i = 1:6 %only calculate Mean Macrotime for combined channels GG, GR, RR
        Mean_Macrotime_per_Chan(:,i) = cellfun(@(x,y) mean(x(y == i)),Macrotime, Channel)*FileInfo.ClockPeriod;
        Duration_per_Chan(:,i) = cellfun(@(x,y) max(x(y == i))-min(x(y == i)),Macrotime,Channel,'UniformOutput',false);
    end
    
    Progress(0.5,h.Progress.Axes, h.Progress.Text, 'Calculating Burstwise Parameters...');
    
    Mean_Macrotime_per_Color = zeros(Number_of_Bursts,4);
    Duration_per_Color = cell(Number_of_Bursts,4);
    for i = 1:3 %only calculate Mean Macrotime for combined channels GG, GR, RR
        Mean_Macrotime_per_Color(:,i) = cellfun(@(x,y) mean(x(y == 2*i-1 | y == 2*i)),Macrotime, Channel)*FileInfo.ClockPeriod;
        Duration_per_Color(:,i) = cellfun(@(x,y) max(x(y == 2*i-1 | y == 2*i))-min(x(y == 2*i-1 | y == 2*i)),Macrotime,Channel,'UniformOutput',false);
    end
    
    Progress(0.6,h.Progress.Axes, h.Progress.Text, 'Calculating Burstwise Parameters...');
    %Also calculate GX
    Mean_Macrotime_per_Color(:,4) = cellfun(@(x,y) mean(x(y == 1 | y == 2 | y == 3 | y == 4)),Macrotime, Channel)*FileInfo.ClockPeriod;
    Duration_per_Color(:,4) = cellfun(@(x,y) max(x(y == 1 | y == 2 | y == 3 | y == 4))-min(x(y == 1 | y == 2 | y == 3 | y == 4)),Macrotime,Channel,'UniformOutput',false);
    
    %there are empty cells for Duration_per_Chan if Channels are empty
    ix=cellfun('isempty',Duration_per_Chan);
    Duration_per_Chan(ix)={nan};
    Duration_per_Chan = cell2mat(Duration_per_Chan)*FileInfo.ClockPeriod/1E-3;
    
    ix=cellfun('isempty',Duration_per_Color);
    Duration_per_Color(ix)={nan};
    Duration_per_Color = cell2mat(Duration_per_Color)*FileInfo.ClockPeriod/1E-3;
    
    %Determine TGG-TGR and TGX-TRR
    TGG_TGR = abs(Mean_Macrotime_per_Color(:,1)-Mean_Macrotime_per_Color(:,2));
    TGX_TRR = abs(Mean_Macrotime_per_Color(:,4)-Mean_Macrotime_per_Color(:,3));
    %also provide normalized quantities
    TGG_TGR(:,2) = TGG_TGR(:,1)./Duration;
    TGX_TRR(:,2) = TGX_TRR(:,1)./Duration;
    TGG_TGR(:,1) = TGG_TGR(:,1)./1E-3;
    TGX_TRR(:,1) = TGX_TRR(:,1)./1E-3;
    
    Progress(0.8,h.Progress.Axes, h.Progress.Text, 'Calculating Burstwise Parameters...');
    
    % take the APBS burst duration as the duration
    if h.Burst.ConstantDuration_Checkbox.Value
        for i = 1:6
            Duration_per_Chan(:,i) = Duration;
        end
        for i = 1:3
            Duration_per_Color(:,i) = Duration;
        end
    end
    
    %Countrate per chan
    Countrate_per_Chan = zeros(Number_of_Bursts,6);
    for i = 1:6
        Countrate_per_Chan(:,i) = Number_of_Photons_per_Chan(:,i)./Duration_per_Chan(:,i);
    end
    
    Countrate_per_Color = zeros(Number_of_Bursts,3);
    for i = 1:3
        Countrate_per_Color(:,i) = Number_of_Photons_per_Color(:,i)./Duration_per_Color(:,i);
    end
    
elseif any(BAMethod == [3 4]) %total of 12 channels
    Number_of_Photons_per_Chan = zeros(Number_of_Bursts,12);
    for i = 1:12
        Number_of_Photons_per_Chan(:,i) = cellfun(@(x) sum(x==i),Channel);
    end
    
    %%% Calculate RAW Efficiencies and Stoichiometries
    %%% Efficiencies
    EGR = sum(Number_of_Photons_per_Chan(:,[9,10]),2)./sum(Number_of_Photons_per_Chan(:,[7 8 9 10]),2);
    EBG = sum(Number_of_Photons_per_Chan(:,[3 4]),2)./...
        (sum(Number_of_Photons_per_Chan(:,[1 2]),2).*(1-EGR)+sum(Number_of_Photons_per_Chan(:,[3 4]),2));
    EBR = (sum(Number_of_Photons_per_Chan(:,[5 6]),2) - EGR.*(sum(Number_of_Photons_per_Chan(:,[3 4 5 6]),2)))./...
        (sum(Number_of_Photons_per_Chan(:,[1 2 5 6]),2) - EGR.*sum(Number_of_Photons_per_Chan(:,[1 2 3 4 5 6]),2));
    %%%Stoichiometries
    SGR = sum(Number_of_Photons_per_Chan(:,[7 8 9 10]),2)./sum(Number_of_Photons_per_Chan(:,[7 8 9 10 11 12]),2);
    SBG = sum(Number_of_Photons_per_Chan(:,[1 2 3 4 5 6]),2)./sum(Number_of_Photons_per_Chan(:,[1 2 3 4 5 6 7 8 9 10]),2);
    SBR = sum(Number_of_Photons_per_Chan(:,[1 2 3 4 5 6]),2)./sum(Number_of_Photons_per_Chan(:,[1 2 3 4 5 6 11 12]),2);
    %%% Efficiency-related quantities
    %%% Total FRET from the Blue to both Acceptors
    E1A = sum(Number_of_Photons_per_Chan(:,[3 4 5 6]),2)./sum(Number_of_Photons_per_Chan(:,[1 2 3 4 5 6]),2);
    %%% Proximity Ratios (Fractional Signal)
    PGR = EGR;
    PBG = sum(Number_of_Photons_per_Chan(:,[3 4]),2)./sum(Number_of_Photons_per_Chan(:,[1 2 3 4 5 6]),2);
    PBR = sum(Number_of_Photons_per_Chan(:,[5 6]),2)./sum(Number_of_Photons_per_Chan(:,[1 2 3 4 5 6]),2);
    
    
    %%% Calculate RAW Anisotropies
    rBB = (Number_of_Photons_per_Chan(:,1)-Number_of_Photons_per_Chan(:,2))./(Number_of_Photons_per_Chan(:,1)+2*Number_of_Photons_per_Chan(:,2));
    rBG = (Number_of_Photons_per_Chan(:,3)-Number_of_Photons_per_Chan(:,4))./(Number_of_Photons_per_Chan(:,3)+2*Number_of_Photons_per_Chan(:,4));
    rBR = (Number_of_Photons_per_Chan(:,5)-Number_of_Photons_per_Chan(:,6))./(Number_of_Photons_per_Chan(:,5)+2*Number_of_Photons_per_Chan(:,6));
    rGG = (Number_of_Photons_per_Chan(:,7)-Number_of_Photons_per_Chan(:,8))./(Number_of_Photons_per_Chan(:,7)+2*Number_of_Photons_per_Chan(:,8));
    rGR = (Number_of_Photons_per_Chan(:,9)-Number_of_Photons_per_Chan(:,10))./(Number_of_Photons_per_Chan(:,9)+2*Number_of_Photons_per_Chan(:,10));
    rRR = (Number_of_Photons_per_Chan(:,11)-Number_of_Photons_per_Chan(:,12))./(Number_of_Photons_per_Chan(:,11)+2*Number_of_Photons_per_Chan(:,12));
    
    %%% create placeholder arrays for lifetimes and 2CDE filter calculation
    tauBB = zeros(Number_of_Bursts,1);
    tauGG = zeros(Number_of_Bursts,1);
    tauRR = zeros(Number_of_Bursts,1);
    ALEX_2CDE_BG = zeros(Number_of_Bursts,1);
    ALEX_2CDE_BR = zeros(Number_of_Bursts,1);
    ALEX_2CDE_GR = zeros(Number_of_Bursts,1);
    FRET_2CDE_BG = zeros(Number_of_Bursts,1);
    FRET_2CDE_BR = zeros(Number_of_Bursts,1);
    FRET_2CDE_GR = zeros(Number_of_Bursts,1);
    
    Number_of_Photons_per_Color = zeros(Number_of_Bursts,6);
    for i = 1:6
        Number_of_Photons_per_Color(:,i) = Number_of_Photons_per_Chan(:,2*i-1)+Number_of_Photons_per_Chan(:,2*i);
    end
    
    for i = 1:12 %only calculate Mean Macrotime for combined channels
        Mean_Macrotime_per_Chan(:,i) = cellfun(@(x,y) mean(x(y == i)),Macrotime, Channel)*FileInfo.ClockPeriod;
        Duration_per_Chan(:,i) = cellfun(@(x,y) max(x(y == i))-min(x(y == i)),Macrotime,Channel,'UniformOutput',false);
    end
    
    Mean_Macrotime_per_Color = zeros(Number_of_Bursts,8);
    Duration_per_Color = cell(Number_of_Bursts,8);
    for i = 1:6 %only calculate Mean Macrotime for combined channels GG, GR, RR
        Mean_Macrotime_per_Color(:,i) = cellfun(@(x,y) mean(x(y == 2*i-1 | y == 2*i)),Macrotime, Channel)*FileInfo.ClockPeriod;
        Duration_per_Color(:,i) = cellfun(@(x,y) max(x(y == 2*i-1 | y == 2*i))-min(x(y == 2*i-1 | y == 2*i)),Macrotime,Channel,'UniformOutput',false);
    end
    
    %Also for BX and GX
    Mean_Macrotime_per_Color(:,7) = cellfun(@(x,y) mean(x(y == 1 | y == 2 | y == 3 | y == 4 | y == 5 | y == 6)),Macrotime, Channel)*FileInfo.ClockPeriod;
    Mean_Macrotime_per_Color(:,8) = cellfun(@(x,y) mean(x(y == 7 | y == 8 | y == 9 | y == 10)),Macrotime, Channel)*FileInfo.ClockPeriod;
    Duration_per_Color(:,7) = cellfun(@(x,y) max(x(y == 1 | y == 2 | y == 3 | y == 4 | y == 5 | y == 6)) - min(x(y == 1 | y == 2 | y == 3 | y == 4 | y == 5 | y == 6)),Macrotime,Channel,'UniformOutput',false);
    Duration_per_Color(:,8) = cellfun(@(x,y) max(x(y == 7 | y == 8 | y == 9 | y == 10)) - min(x(y == 7 | y == 8 | y == 9 | y == 10)),Macrotime,Channel,'UniformOutput',false);
    
    %there are empty cells for Duration_per_Chan if Channels are empty
    ix=cellfun('isempty',Duration_per_Chan);
    Duration_per_Chan(ix)={nan};
    Duration_per_Chan = cell2mat(Duration_per_Chan)*FileInfo.ClockPeriod/1E-3;
    
    ix=cellfun('isempty',Duration_per_Color);
    Duration_per_Color(ix)={nan};
    Duration_per_Color = cell2mat(Duration_per_Color)*FileInfo.ClockPeriod/1E-3;
    
    %Determine TGG-TGR and TGX-TRR
    TGG_TGR = abs(Mean_Macrotime_per_Color(:,4)-Mean_Macrotime_per_Color(:,5));
    TGX_TRR = abs(Mean_Macrotime_per_Color(:,8)-Mean_Macrotime_per_Color(:,6));
    TBB_TBG = abs(Mean_Macrotime_per_Color(:,1)-Mean_Macrotime_per_Color(:,2));
    TBB_TBR = abs(Mean_Macrotime_per_Color(:,1)-Mean_Macrotime_per_Color(:,3));
    TBX_TGX = abs(Mean_Macrotime_per_Color(:,7)-Mean_Macrotime_per_Color(:,8));
    TBX_TRR = abs(Mean_Macrotime_per_Color(:,7)-Mean_Macrotime_per_Color(:,6));
    %also provide normalized quantities
    TGG_TGR(:,2) = TGG_TGR(:,1)./Duration;
    TGX_TRR(:,2) = TGX_TRR(:,1)./Duration;
    TBB_TBG(:,2) = TBB_TBG(:,1)./Duration;
    TBB_TBR(:,2) = TBB_TBR(:,1)./Duration;
    TBX_TGX(:,2) = TBX_TGX(:,1)./Duration;
    TBX_TRR(:,2) = TBX_TRR(:,1)./Duration;
    %convert to ms
    TGG_TGR(:,1) = TGG_TGR(:,1)./1E-3;
    TGX_TRR(:,1) = TGX_TRR(:,1)./1E-3;
    TBB_TBG(:,1) = TBB_TBG(:,1)./1E-3;
    TBB_TBR(:,1) = TBB_TBR(:,1)./1E-3;
    TBX_TGX(:,1) = TBX_TGX(:,1)./1E-3;
    TBX_TRR(:,1) = TBX_TRR(:,1)./1E-3;
    
    % take the APBS burst duration as the duration
    if h.Burst.ConstantDuration_Checkbox.Value
        for i = 1:12
            Duration_per_Chan(:,i) = Duration;
        end
        for i = 1:6
            Duration_per_Color(:,i) = Duration;
        end
    end
    
    Countrate_per_Chan = zeros(Number_of_Bursts,12);
    for i = 1:12
        Countrate_per_Chan(:,i) = Number_of_Photons_per_Chan(:,i)./Duration_per_Chan(:,i);
    end
    
    Countrate_per_Color = zeros(Number_of_Bursts,3);
    for i = 1:6
        Countrate_per_Color(:,i) = Number_of_Photons_per_Color(:,i)./Duration_per_Color(:,i);
    end
elseif any(BAMethod == [5,6]) %only 3 channels
    
    Number_of_Photons_per_Color = zeros(Number_of_Bursts,3);
    for i = 1:3 %polarization resolved
        Number_of_Photons_per_Color(:,i) = cellfun(@(x) sum(x==i),Channel);
    end
    %%% Calculate RAW Efficiency and Stoichiometry
    E = Number_of_Photons_per_Color(:,2)./(Number_of_Photons_per_Color(:,1) + Number_of_Photons_per_Color(:,2));
    S = (Number_of_Photons_per_Color(:,1) + Number_of_Photons_per_Color(:,2))./Number_of_Photons;
    Proximity_Ratio = E;
    
    %%% create placeholder arrays for lifetimes and 2CDE filter calculation
    tauGG = zeros(Number_of_Bursts,1);
    tauRR = zeros(Number_of_Bursts,1);
    ALEX_2CDE = zeros(Number_of_Bursts,1);
    FRET_2CDE = zeros(Number_of_Bursts,1);
    
    Mean_Macrotime_per_Color = zeros(Number_of_Bursts,3);
    Duration_per_Color = cell(Number_of_Bursts,3);
    for i = 1:3 %only calculate Mean Macrotime for combined channels GG, GR, RR
        Mean_Macrotime_per_Color(:,i) = cellfun(@(x,y) mean(x(y == i)),Macrotime, Channel)*FileInfo.ClockPeriod;
        Duration_per_Color(:,i) = cellfun(@(x,y) max(x(y == i)) - min(x(y == i)),Macrotime,Channel,'UniformOutput',false);
    end
    
    %Also calculate GX
    Mean_Macrotime_per_Color(:,4) = cellfun(@(x,y) mean(x(y == 1 | y == 2)),Macrotime, Channel)*FileInfo.ClockPeriod;
    Duration_per_Color(:,4) = cellfun(@(x,y) max(x(y == 1 | y == 2)) - min(x(y == 1 | y == 2)),Macrotime,Channel,'UniformOutput',false);
    
    %there are empty cells for Duration_per_Chan if Channels are empty
    ix=cellfun('isempty',Duration_per_Color);
    Duration_per_Color(ix)={nan};
    Duration_per_Color = cell2mat(Duration_per_Color)*FileInfo.ClockPeriod/1E-3;
    
    %Determine TGG-TGR and TGX-TRR
    TGG_TGR = abs(Mean_Macrotime_per_Color(:,1)-Mean_Macrotime_per_Color(:,2));
    TGX_TRR = abs(Mean_Macrotime_per_Color(:,4)-Mean_Macrotime_per_Color(:,3));
    %also provide normalized quantities
    TGG_TGR(:,2) = TGG_TGR(:,1)./Duration;
    TGX_TRR(:,2) = TGX_TRR(:,1)./Duration;
    TGG_TGR(:,1) = TGG_TGR(:,1)./1E-3;
    TGX_TRR(:,1) = TGX_TRR(:,1)./1E-3;
    
    % take the APBS burst duration as the duration
    if h.Burst.ConstantDuration_Checkbox.Value
        for i = 1:4
            Duration_per_Color(:,i) = Duration;
        end
    end
    
    %Countrate per chan
    Countrate_per_Color = zeros(Number_of_Bursts,3);
    for i = 1:3
        Countrate_per_Color(:,i) = Number_of_Photons_per_Color(:,i)./Duration_per_Color(:,i);
    end
end

Countrate = Number_of_Photons./Duration;

Progress(0.95,h.Progress.Axes, h.Progress.Text, 'Saving...');
%% Save BurstSearch Results
%%% The result is saved in a simple data array with dimensions
%%% (NumberOfBurst x NumberOfParamters), DataArray. The column names are saved in a
%%% cell array of strings, NameArray.

%%% The Parameters are listed in the following order:
%%% (1) Efficiency and Stoichiometry (corrected values)
%%% (2) Efficiency and Stoichiometry (raw values)
%%% (3) Lifetimes
%%% (4) Ansiotropies (the relevant ones)
%%% (5) Parameters for cleanup/selection (TGX-TRR, ALEX_2CDE..)
%%% (6) Parameters for identifying dynamic events(TGG-TGR,FRET_2CDE...)
%%% (7) Other useful parameters (Duration, Time of Burst, Countrates..)
if any(BAMethod == [1 2])
    BurstData.DataArray = [...
        E...
        S...
        Proximity_Ratio...
        S...
        tauGG...
        tauRR...
        rGG...
        rRR...
        ALEX_2CDE...
        FRET_2CDE...
        TGX_TRR(:,1)...
        TGG_TGR(:,1)...
        Duration...
        Mean_Macrotime...
        Number_of_Photons...
        Countrate...
        Countrate_per_Color...
        Countrate_per_Chan...
        Number_of_Photons_per_Color...
        Number_of_Photons_per_Chan];
    
    BurstData.NameArray = {'FRET Efficiency',...
        'Stoichiometry',...
        'Proximity Ratio',...
        'Stoichiometry (raw)',...
        'Lifetime D [ns]',...
        'Lifetime A [ns]',...
        'Anisotropy D',...
        'Anisotropy A',...
        'ALEX 2CDE Filter',...
        'FRET 2CDE Filter',...
        '|TDX-TAA| Filter',...
        '|TDD-TDA| Filter',...
        'Duration [ms]',...
        'Mean Macrotime [s]',...
        'Number of Photons',...
        'Count rate [kHz]',...
        'Count rate (DD) [kHz]',...
        'Count rate (DA) [kHz]',...
        'Count rate (AA) [kHz]',...
        'Count rate (DD par) [kHz]',...
        'Count rate (DD perp) [kHz]',...
        'Count rate (DA par) [kHz]',...
        'Count rate (DA perp) [kHz]',...
        'Count rate (AA par) [kHz]',...
        'Count rate (AA perp) [kHz]',...
        'Number of Photons (DD)',...
        'Number of Photons (DA)',...
        'Number of Photons (AA)'...
        'Number of Photons (DD par)',...
        'Number of Photons (DD perp)',...
        'Number of Photons (DA par)',...
        'Number of Photons (DA perp)',...
        'Number of Photons (AA par)',...
        'Number of Photons (AA perp)',...
        };
elseif any(BAMethod == [3 4])
    BurstData.DataArray = [...
        EGR EBG EBR E1A SGR SBG SBR...
        PGR PBG PBR E1A SGR SBG SBR...
        tauBB tauGG tauRR...
        rBB rGG rRR...
        TBX_TGX(:,1) TBX_TRR(:,1) TGX_TRR(:,1)...
        ALEX_2CDE_BG ALEX_2CDE_BR ALEX_2CDE_GR...
        TBB_TBG(:,1) TBB_TBR(:,1) TGG_TGR(:,1)...
        FRET_2CDE_BG FRET_2CDE_BR FRET_2CDE_GR...
        Duration...
        Mean_Macrotime...
        Number_of_Photons...
        Countrate...
        Countrate_per_Color...
        Countrate_per_Chan...
        Number_of_Photons_per_Color...
        Number_of_Photons_per_Chan...
        ];
    BurstData.NameArray = {'FRET Efficiency GR','FRET Efficiency BG','FRET Efficiency BR','FRET Efficiency B->G+R'...
        'Stoichiometry GR','Stoichiometry BG','Stoichiometry BR',...
        'Proximity Ratio GR','Proximity Ratio BG','Proximity Ratio BR','Proximity Ratio B->G+R'...
        'Stoichiometry GR (raw)','Stoichiometry BG (raw)','Stoichiometry BR (raw)',...
        'Lifetime BB [ns]','Lifetime GG [ns]','Lifetime RR [ns]',...
        'Anisotropy BB','Anisotropy GG','Anisotropy RR',...
        '|TBX-TGX| Filter','|TBX-TRR| Filter','|TGX-TRR| Filter',...
        'ALEX 2CDE BG Filter','ALEX 2CDE BR Filter','ALEX 2CDE GR Filter',...
        '|TBB-TBG| Filter','|TBB-TBR| Filter','|TGG-TGR| Filter',...
        'FRET 2CDE BG Filter','FRET 2CDE BR Filter','FRET 2CDE GR Filter',...
        'Duration [ms]',...
        'Mean Macrotime [s]',...
        'Number of Photons',...
        'Count rate [kHz]',...
        'Count rate (BB) [kHz]',...
        'Count rate (BG) [kHz]',...
        'Count rate (BR) [kHz]',...
        'Count rate (GG) [kHz]',...
        'Count rate (GR) [kHz]',...
        'Count rate (RR) [kHz]',...
        'Count rate (BB par) [kHz]',...
        'Count rate (BB perp) [kHz]',...
        'Count rate (BG par) [kHz]',...
        'Count rate (BG perp) [kHz]',...
        'Count rate (BR par) [kHz]',...
        'Count rate (BR perp) [kHz]',...
        'Count rate (GG par) [kHz]',...
        'Count rate (GG perp) [kHz]',...
        'Count rate (GR par) [kHz]',...
        'Count rate (GR perp) [kHz]',...
        'Count rate (RR par) [kHz]',...
        'Count rate (RR perp) [kHz]',...
        'Number of Photons (BB)',...
        'Number of Photons (BG)',...
        'Number of Photons (BR)',...
        'Number of Photons (GG)',...
        'Number of Photons (GR)',...
        'Number of Photons (RR)',...
        'Number of Photons (BB par)',...
        'Number of Photons (BB perp)',...
        'Number of Photons (BG par)',...
        'Number of Photons (BG perp)',...
        'Number of Photons (BR par)',...
        'Number of Photons (BR perp)',...
        'Number of Photons (GG par)',...
        'Number of Photons (GG perp)',...
        'Number of Photons (GR par)',...
        'Number of Photons (GR perp)',...
        'Number of Photons (RR par)',...
        'Number of Photons (RR perp)'...
        };
elseif any (BAMethod == [5,6])
    BurstData.DataArray = [...
        E...
        S...
        Proximity_Ratio...
        S...
        tauGG...
        tauRR...
        TGX_TRR(:,1)...
        ALEX_2CDE...
        TGG_TGR(:,1)...
        FRET_2CDE...
        Duration...
        Mean_Macrotime...
        Countrate...
        Countrate_per_Color(:,1:3)...
        Number_of_Photons...
        Number_of_Photons_per_Color...
        ];
    
    BurstData.NameArray = {'FRET Efficiency',...
        'Stoichiometry',...
        'Proximity Ratio',...
        'Stoichiometry (raw)',...
        'Lifetime GG [ns]',...
        'Lifetime RR [ns]',...
        '|TGX-TRR| Filter',...
        'ALEX 2CDE Filter',...
        '|TGG-TGR| Filter',...
        'FRET 2CDE Filter',...
        'Duration [ms]',...
        'Mean Macrotime [s]',...
        'Count rate [kHz]',...
        'Count rate (GG) [kHz]',...
        'Count rate (GR) [kHz]',...
        'Count rate (RR) [kHz]',...
        'Number of Photons',...
        'Number of Photons (GG)',...
        'Number of Photons (GR)',...
        'Number of Photons (RR)'...
        };
end
%%% append information about detected channel if DCBS burst search is used
if any(BAMethod == [2,6]) && exist('detected_channel','var') % not implemented for TCBS yet
    BurstData.DataArray = [BurstData.DataArray, detected_channel];
    BurstData.NameArray{end+1} = 'Detected Channel';
end

%%% Append other important parameters/values to BurstData structure
BurstData.TACRange = FileInfo.TACRange;
BurstData.BAMethod = BAMethod;
if BurstData.BAMethod == 6
    %%% Set DCBS-noMFD to APBS-noMFD
    BurstData.BAMethod = 5;
    % also overwrite the PIE channel selections to read out the right data further on
    UserValues.BurstSearch.PIEChannelSelection{5} = UserValues.BurstSearch.PIEChannelSelection{6};
    LSUserValues(1);
end
BurstData.Filetype = FileInfo.FileType;
BurstData.SyncPeriod = FileInfo.SyncPeriod;
BurstData.ClockPeriod = FileInfo.ClockPeriod;
BurstData.TotalDuration = h.Burst.ConstantDuration_Checkbox.Value; %1 if all count rates are calculated with the total duration.
%%% Store also the FileInfo in BurstData
BurstData.FileInfo = FileInfo;
%%% Safe PIE channel information for loading of IRF later
%%% Read out the selected PIE Channels
PIEChannels = cellfun(@(x) find(strcmp(UserValues.PIE.Name,x)),UserValues.BurstSearch.PIEChannelSelection{BAMethod});
%%% The next two lines convert the Nx2 (2 for par/perp) into a lineal
%%% vector with the index corresponding to the Channel number as
%%% defined in the burst search
PIEChannels = PIEChannels';
PIEChannels = PIEChannels(:);
BurstData.PIE.Detector = UserValues.PIE.Detector(PIEChannels);
BurstData.PIE.Router = UserValues.PIE.Router(PIEChannels);
%%% Save the lower and upper boundaries of the PIE Channels for later fFCS calculations
BurstData.PIE.From = UserValues.PIE.From(PIEChannels);
BurstData.PIE.To = UserValues.PIE.To(PIEChannels);
%%% look for combined channels
iscombined = ~cellfun(@isempty,UserValues.PIE.Combined(PIEChannels)); % will be not empty for combined channels
if any(iscombined)
    for i = 1:numel(iscombined)
        if iscombined(i)
            chans = UserValues.PIE.Combined{PIEChannels(i)};
            Detector = []; Router = []; From = []; To = [];
            for j = 1:numel(chans)
                Detector(end+1) = UserValues.PIE.Detector(chans(j));
                Router(end+1) = UserValues.PIE.Router(chans(j));
                From(end+1) = UserValues.PIE.From(chans(j));
                To(end+1) = UserValues.PIE.To(chans(j));
            end
            BurstData.PIE.Detector(i) = Detector(1); % save only the first detector for now
            BurstData.PIE.Router(i) = Router(1);
            BurstData.PIE.From(i) = min(From); % save min From range
            BurstData.PIE.To(i) = max(To); % save max To range
        end
    end
end

% get the IRF, scatter decay and background from UserValues
BurstData = Store_IRF_Scat_inBur('nothing',BurstData,[0,1,2]);

% save the BIDs
if save_BID
    BurstData.BID = BID;
end
%%% get path from spc files, create folder
[pathstr, FileName, ~] = fileparts(fullfile(FileInfo.Path,FileInfo.FileName{1}));

BurstData.FileNameSPC = FileName; %%% The Name without extension
BurstData.PathName = FileInfo.Path;

%%% the burst search parameters
BurstSearchParameters = struct;
BurstSearchParameters.PIEchannelselection = h.Burst.BurstPIE_Table.Data;
if ~from_BurstIDs
    BurstSearchParameters.BurstMinimumLength = L;
    %%% the used burst search and smoothing method
    BurstSearchParameters.BurstSearch = h.Burst.BurstSearchSelection_Popupmenu.String{h.Burst.BurstSearchSelection_Popupmenu.Value};
    BurstSearchParameters.BurstSearchSmoothingMethod = h.Burst.BurstSearchSmoothing_Popupmenu.String{h.Burst.BurstSearchSmoothing_Popupmenu.Value};
    if any(BAMethod == [2,4,6])
        % DCBS was used, store the logical gating used
        BurstSearchParameters.DCBS_logical_gate = DCBS_logical_gate;
    end
    switch h.Burst.BurstSearchSmoothing_Popupmenu.Value
        case 1 %%% Sliding time window
            if numel(T) == 1
                BurstSearchParameters.TimeWindow = T;
            elseif numel(T) == 2
                BurstSearchParameters.TimeWindowGX = T(1);
                BurstSearchParameters.TimeWindowRR = T(2);
            elseif numel(T) == 3
                BurstSearchParameters.TimeWindowBX = T(1);
                BurstSearchParameters.TimeWindowGX = T(2);
                BurstSearchParameters.TimeWindowRR = T(2);
            end
            if numel(M) == 1
                BurstSearchParameters.PhotonsPerTimewindow = M;
            elseif numel(M) == 2
                BurstSearchParameters.PhotonsPerTimewindowGX = M(1);
                BurstSearchParameters.PhotonsPerTimewindowRR = M(2);
            elseif numel(M) == 3
                BurstSearchParameters.PhotonsPerTimewindowBX = M(1);
                BurstSearchParameters.PhotonsPerTimewindowGX = M(2);
                BurstSearchParameters.PhotonsPerTimewindowRR = M(3);
            end
        case 2 %%% Interphoton time with Lee filter
            if numel(T) == 1
                BurstSearchParameters.SmoothingWindow = T;
            elseif numel(T) == 2
                BurstSearchParameters.SmoothingWindowGX = T(1);
                BurstSearchParameters.SmoothingWindowRR = T(2);
            elseif numel(T) == 3
                BurstSearchParameters.SmoothingWindowBX = T(1);
                BurstSearchParameters.SmoothingWindowGX = T(2);
                BurstSearchParameters.SmoothingWindowRR = T(2);
            end
            if numel(M) == 1
                BurstSearchParameters.InterphotonTimeThreshold = M;
            elseif numel(M) == 2
                BurstSearchParameters.InterphotonTimeThresholdGX = M(1);
                BurstSearchParameters.InterphotonTimeThresholdRR = M(2);
            elseif numel(M) == 3
                BurstSearchParameters.InterphotonTimeThresholdBX = M(1);
                BurstSearchParameters.InterphotonTimeThresholdGX = M(2);
                BurstSearchParameters.InterphotonTimeThresholdRR = M(3);
            end
        case 3 % CUSUM burst search
            if numel(T) == 1
                BurstSearchParameters.BackgroundSignal = T;
            elseif numel(T) == 2
                BurstSearchParameters.BackgroundSignalGX = T(1);
                BurstSearchParameters.BackgroundSignalRR = T(2);
            elseif numel(T) == 3
                BurstSearchParameters.BackgroundSignalBX = T(1);
                BurstSearchParameters.BackgroundSignalGX = T(2);
                BurstSearchParameters.BackgroundSignalRR = T(2);
            end
            if numel(M) == 1
                BurstSearchParameters.IntensityThreshold = M;
            elseif numel(M) == 2
                BurstSearchParameters.IntensityThresholdGX = M(1);
                BurstSearchParameters.IntensityThresholdRR = M(2);
            elseif numel(M) == 3
                BurstSearchParameters.IntensityThresholdBX = M(1);
                BurstSearchParameters.IntensityThresholdGX = M(2);
                BurstSearchParameters.IntensityThresholdRR = M(3);
            end
        case 4 % Changepoint burst search
            if numel(M) == 1
                BurstSearchParameters.IntensityThreshold = M;
            elseif numel(M) == 2
                BurstSearchParameters.IntensityThresholdGX = M(1);
                BurstSearchParameters.IntensityThresholdRR = M(2);
            elseif numel(M) == 3
                BurstSearchParameters.IntensityThresholdBX = M(1);
                BurstSearchParameters.IntensityThresholdGX = M(2);
                BurstSearchParameters.IntensityThresholdRR = M(3);
            end
    end
else %%% generated from BurstIDs
    BurstSearchParameters.BurstSearch = 'from BurstIDs';
    BurstSearchParameters.BurstMinimumLength = 0;
    BurstSearchParameters.BurstSearchSmoothingMethod = 'N/A';
    BurstSearchParameters.BurstIDFile = BID_file;
    BurstSearchParameters.BurstIDPath = BID_path;
end
BurstData.BurstSearchParameters = BurstSearchParameters;

if ~exist([pathstr filesep FileName],'dir')
    mkdir(pathstr,FileName);
end
pathstr = [pathstr filesep FileName];

if ~from_BurstIDs
    %%% Add Burst Search Type
    %%% The Naming follows the Abbreviation for the BurstSearch Method.
    switch BAMethod
        case 1
            FullFileName = fullfile(pathstr, [FileName '_APBS_2CMFD']);
        case 2
            FullFileName = fullfile(pathstr, [FileName '_DCBS_2CMFD']);
        case 3
            FullFileName = fullfile(pathstr, [FileName '_APBS_3CMFD']);
        case 4
            FullFileName = fullfile(pathstr, [FileName '_TCBS_3CMFD']);
        case 5
            FullFileName = fullfile(pathstr, [FileName '_APBS_2CnoMFD']);
        case 6
            FullFileName = fullfile(pathstr, [FileName '_DCBS_2CnoMFD']);
    end
else
    BID_folder = strsplit(BID_path,filesep);
    if ~isempty(BID_folder{end})
        BID_folder = BID_folder{end};
    else
        BID_folder = BID_folder{end-1};
    end
    FullFileName = fullfile(pathstr, [FileName '_BID_' BID_folder]);
end
%%% add the used parameters also to the filename
% switch BAMethod
%     case {1,3,5} %APBS L,M,T
%         FullFileName = [FullFileName ...
%             num2str(L) '_' num2str(M)...
%             '_' num2str(T)];
%     case 2 %DCBS, now 2 M values; L,MD,MA,T
%         FullFileName = [FullFileName ...
%             num2str(L) '_' num2str(M(1))...
%             '_' num2str(M(2))...
%             '_' num2str(T)];
%     case 4 %TCBS
%         FullFileName = [FullFileName ...
%             num2str(L) '_' num2str(M(1))...
%             '_' num2str(M(2))...
%             '_' num2str(M(3))...
%             '_' num2str(T)];
% end

%%% Save the Burst Data
BurstFileName = [FullFileName '.bur'];
BurstFileName = GenerateName(BurstFileName, 1);
%%% Store the FileName of the *.bur file
BurstData.FileName = BurstFileName;
save(BurstFileName,'BurstData','-v7.3');

%%% save a text file with information about the burst analysis
save_burst_info(BurstData);

%%% Save the full Photon Information (for FCS/fFCS) in an external file
%%% that can be loaded at a later timepoint
PhotonsFileName = [BurstFileName(1:end-3) 'bps']; %%% .bps is burst-photon-stream
%PhotonsFileName = GenerateName(PhotonsFileName, 1);
Macrotime = cellfun(@uint64,Macrotime,'UniformOutput',false);
Microtime = cellfun(@uint16,Microtime,'UniformOutput',false);
Channel = cellfun(@uint8,Channel,'UniformOutput',false);

%%% set file size warning on saving to be an error so we can catch it
warning('error','MATLAB:save:sizeTooBigForMATFile');
try
    save(PhotonsFileName,'Macrotime','Microtime','Channel','-v7');
catch
    %%% error means the file size exceeds the 2GB limit of save -v7
    %%% we have to use -v7.3 version, which can save larger files
    %%% however, -v7.3 produces very large files out of cell arrays, so it
    %%% is really not an optimal solution...
    save(PhotonsFileName,'Macrotime','Microtime','Channel','-v7.3');
end
%%% change the warning back to NOT raise an error
warning('on','MATLAB:save:sizeTooBigForMATFile');

%%% Save the whole photon stream for fFCS with Donor-Only inclusion or
%%% purified FCS (inclusion of time window around burst)
if UserValues.BurstSearch.SaveTotalPhotonStream
    PhotonsFileName = [BurstFileName(1:end-3) 'aps']; %%% .aps is all-photon-stream
    PhotonStream.start = start_all;
    PhotonStream.stop = stop_all;
    PhotonStream.Macrotime = uint64(Macrotime_all);
    PhotonStream.Microtime = uint16(Microtime_all);
    PhotonStream.Channel = uint8(Channel_all);
    save(PhotonsFileName,'PhotonStream','-v7.3');
end

%%% Set BurstBrowserPath Path to FilePath
UserValues.File.BurstBrowserPath = FileInfo.Path;

LSUserValues(1);

%%% store burstdata in PamMeta structure
PamMeta.BurstData = BurstData;

Progress(1,h.Progress.Axes, h.Progress.Text, 'Done');
Update_Display([],[],1);
%%% set the text of the BurstSearch Button to green color to indicate that
%%% a burst search has been done
h.Burst.Button.ForegroundColor = [0 0.8 0];
%%% Enable Lifetime and 2CDE Button
h.Burst.BurstLifetime_Button.Enable = 'on';
h.Burst.BurstLifetime_Button.ForegroundColor = [1 0 0];
h.Burst.NirFilter_Button.Enable = 'on';
h.Burst.NirFilter_Button.ForegroundColor = [1 0 0];

[~,str,~] = fileparts(BurstData.FileName);
str = ['Loaded file: ' str];
h.Burst.LoadedFile_Text.String = str;
h.Burst.LoadedFile_Text.TooltipString = str;
% Perform 2CDE filter calculation directly after burst search
if h.Burst.NirFilter_Checkbox.Value
    NirFilter
end

% Perform burstwise lifetime fitting directly after burst search
if h.Burst.BurstLifetime_Checkbox.Value
    BurstLifetime(obj,[])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Saves information about the burst search in a .txt file  %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_burst_info(BurstData)

fid = fopen([BurstData.FileName(1:end-3) 'txt'],'w');
fprintf(fid,'Burst search settings:\n\n');
fprintf(fid,'Burst search method:\t\t%s\n',BurstData.BurstSearchParameters.BurstSearch);
if isfield(BurstData.BurstSearchParameters,'DCBS_logical_gate')
    fprintf(fid,'Logical gate:\t\t%s\n',BurstData.BurstSearchParameters.DCBS_logical_gate);
end
fprintf(fid,'Smoothing method:\t\t%s\n',BurstData.BurstSearchParameters.BurstSearchSmoothingMethod);
fprintf(fid,'Minimum burst size:\t\t%d photons\n',BurstData.BurstSearchParameters.BurstMinimumLength);
switch BurstData.BurstSearchParameters.BurstSearchSmoothingMethod
    case 'Sliding Time Window' %%% Sliding time window
        if isfield(BurstData.BurstSearchParameters,'TimeWindow')
            fprintf(fid,'Time window:\t\t%d\n',BurstData.BurstSearchParameters.TimeWindow);
        elseif ~isfield(BurstData.BurstSearchParameters,'TimeWindowBX')
            fprintf(fid,'Time window GX:\t%d\n',BurstData.BurstSearchParameters.TimeWindowGX);
            fprintf(fid,'Time window RR:\t%d\n',BurstData.BurstSearchParameters.TimeWindowRR);
        else
            fprintf(fid,'Time window BX:\t%d\n',BurstData.BurstSearchParameters.TimeWindowBX);
            fprintf(fid,'Time window GX:\t%d\n',BurstData.BurstSearchParameters.TimeWindowGX);
            fprintf(fid,'Time window RR:\t%d\n',BurstData.BurstSearchParameters.TimeWindowRR);
        end
        if isfield(BurstData.BurstSearchParameters,'PhotonsPerTimewindow')
            fprintf(fid,'Photons per time window:\t%d\n',BurstData.BurstSearchParameters.PhotonsPerTimewindow);
        elseif ~isfield(BurstData.BurstSearchParameters,'PhotonsPerTimewindowBX')
            fprintf(fid,'Photons per time window GX:\t%d\n',BurstData.BurstSearchParameters.PhotonsPerTimewindowGX);
            fprintf(fid,'Photons per time window RR:\t%d\n',BurstData.BurstSearchParameters.PhotonsPerTimewindowRR);
        else
            fprintf(fid,'Photons per time window BX:\t%d\n',BurstData.BurstSearchParameters.PhotonsPerTimewindowBX);
            fprintf(fid,'Photons per time window GX:\t%d\n',BurstData.BurstSearchParameters.PhotonsPerTimewindowGX);
            fprintf(fid,'Photons per time window RR:\t%d\n',BurstData.BurstSearchParameters.PhotonsPerTimewindowRR);
        end
    case 'Interphoton Time with Lee Filter' %%% Interphoton time with Lee filter
        if isfield(BurstData.BurstSearchParameters,'SmoothingWindow')
            fprintf(fid,'Smoothing window:\t\t%d\n',BurstData.BurstSearchParameters.SmoothingWindow);
        elseif ~isfield(BurstData.BurstSearchParameters,'SmoothingWindowBX')
            fprintf(fid,'Smoothing window GX:\t%d\n',BurstData.BurstSearchParameters.SmoothingWindowGX);
            fprintf(fid,'Smoothing window RR:\t%d\n',BurstData.BurstSearchParameters.SmoothingWindowRR);
        else
            fprintf(fid,'Smoothing window BX:\t%d\n',BurstData.BurstSearchParameters.SmoothingWindowBX);
            fprintf(fid,'Smoothing window GX:\t%d\n',BurstData.BurstSearchParameters.SmoothingWindowGX);
            fprintf(fid,'Smoothing window RR:\t%d\n',BurstData.BurstSearchParameters.SmoothingWindowRR);
        end
        if isfield(BurstData.BurstSearchParameters,'InterphotonTimeThreshold')
            fprintf(fid,'Interphoton time threshold [mus]:\t%d\n',BurstData.BurstSearchParameters.InterphotonTimeThreshold);
        elseif ~isfield(BurstData.BurstSearchParameters,'InterphotonTimeThresholdBX')
            fprintf(fid,'Interphoton time threshold GX [mus]:\t%d\n',BurstData.BurstSearchParameters.InterphotonTimeThresholdGX);
            fprintf(fid,'Interphoton time threshold RR [mus]:\t%d\n',BurstData.BurstSearchParameters.InterphotonTimeThresholdRR);
        else
            fprintf(fid,'Interphoton time threshold BX [mus]:\t%d\n',BurstData.BurstSearchParameters.InterphotonTimeThresholdBX);
            fprintf(fid,'Interphoton time threshold GX [mus]:\t%d\n',BurstData.BurstSearchParameters.InterphotonTimeThresholdGX);
            fprintf(fid,'Interphoton time threshold RR [mus]:\t%d\n',BurstData.BurstSearchParameters.InterphotonTimeThresholdRR);
        end
    case 'CUSUM'
        if isfield(BurstData.BurstSearchParameters,'BackgroundSignal')
            fprintf(fid,'Background signal [kHz]:\t\t%.2f\n',BurstData.BurstSearchParameters.BackgroundSignal);
        elseif ~isfield(BurstData.BurstSearchParameters,'BackgroundSignalBX')
            fprintf(fid,'Background signal GX:\t%.2f\n',BurstData.BurstSearchParameters.BackgroundSignalGX);
            fprintf(fid,'Background signal RR:\t%.2f\n',BurstData.BurstSearchParameters.BackgroundSignalRR);
        else
            fprintf(fid,'Background signal BX:\t%.2f\n',BurstData.BurstSearchParameters.BackgroundSignalBX);
            fprintf(fid,'Background signal GX:\t%.2f\n',BurstData.BurstSearchParameters.BackgroundSignalGX);
            fprintf(fid,'Background signal RR:\t%.2f\n',BurstData.BurstSearchParameters.BackgroundSignalRR);
        end
        if isfield(BurstData.BurstSearchParameters,'IntensityThreshold')
            fprintf(fid,'Intensity threshold [kHz]:\t%d\n',BurstData.BurstSearchParameters.IntensityThreshold);
        elseif ~isfield(BurstData.BurstSearchParameters,'IntensityThresholdBX')
            fprintf(fid,'Intensity threshold GX [kHz]:\t%d\n',BurstData.BurstSearchParameters.IntensityThresholdGX);
            fprintf(fid,'Intensity threshold RR [kHz]:\t%d\n',BurstData.BurstSearchParameters.IntensityThresholdRR);
        else
            fprintf(fid,'Intensity threshold BX [kHz]:\t%d\n',BurstData.BurstSearchParameters.IntensityThresholdBX);
            fprintf(fid,'Intensity threshold GX [kHz]:\t%d\n',BurstData.BurstSearchParameters.IntensityThresholdGX);
            fprintf(fid,'Intensity threshold RR [kHz]:\t%d\n',BurstData.BurstSearchParameters.IntensityThresholdRR);
        end
    case 'Change Point Analysis'        
        if isfield(BurstData.BurstSearchParameters,'IntensityThreshold')
            fprintf(fid,'Intensity threshold [kHz]:\t%d\n',BurstData.BurstSearchParameters.IntensityThreshold);
        elseif ~isfield(BurstData.BurstSearchParameters,'IntensityThresholddBX')
            fprintf(fid,'Intensity threshold GX [kHz]:\t%d\n',BurstData.BurstSearchParameters.IntensityThresholdGX);
            fprintf(fid,'Intensity threshold RR [kHz]:\t%d\n',BurstData.BurstSearchParameters.IntensityThresholdRR);
        else
            fprintf(fid,'Intensity threshold BX [kHz]:\t%d\n',BurstData.BurstSearchParameters.IntensityThresholdBX);
            fprintf(fid,'Intensity threshold GX [kHz]:\t%d\n',BurstData.BurstSearchParameters.IntensityThresholdGX);
            fprintf(fid,'Intensity threshold RR [kHz]:\t%d\n',BurstData.BurstSearchParameters.IntensityThresholdRR);
        end
end

%%% PIE Channel selection
fprintf(fid,'\n');
PIEchans = BurstData.BurstSearchParameters.PIEchannelselection;
switch BurstData.BurstSearchParameters.BurstSearch
    case {'APBS 2C-MFD','DCBS 2C-MFD'}
        fprintf(fid,'Channel\tPar.\tPerp.\n');
        fprintf(fid,'DD\t%s\t%s\n',PIEchans{1,1},PIEchans{1,2});
        fprintf(fid,'DA\t%s\t%s\n',PIEchans{2,1},PIEchans{2,2});
        fprintf(fid,'AA\t%s\t%s\n',PIEchans{3,1},PIEchans{3,2});
    case {'APBS 3C-MFD','DCBS 3C-MFD'}
        fprintf(fid,'Channel\tPar.\tPerp.\nn');
        fprintf(fid,'BB\t%s\t%s\n',PIEchans{1,1},PIEchans{1,2});
        fprintf(fid,'BG\t%s\t%s\n',PIEchans{2,1},PIEchans{2,2});
        fprintf(fid,'BR\t%s\t%s\n',PIEchans{3,1},PIEchans{3,2});
        fprintf(fid,'GG\t%s\t%s\n',PIEchans{4,1},PIEchans{4,2});
        fprintf(fid,'GR\t%s\t%s\n',PIEchans{5,1},PIEchans{5,2});
        fprintf(fid,'GR\t%s\t%s\n',PIEchans{6,1},PIEchans{6,2});
    case {'APBS 2C-noMFD'}
        fprintf(fid,'Channel\tPIE channel\n');
        fprintf(fid,'DD\t%s\n',PIEchans{1,1});
        fprintf(fid,'DA\t%s\n',PIEchans{2,1});
        fprintf(fid,'AA\t%s\n',PIEchans{3,1});
end
fprintf(fid,'\n2CDE filter parameter:\t - mus\n'); %%% empty if not determined
fprintf(fid,'\n');
fprintf(fid,'Analysis date:\t%s\n',char(datetime));
fprintf(fid,'\n\nMeta Data:\n\n');
Save_MetaData([],[],fid); %%% append meta data (automatically closes the fid)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculates the 2CDE Filter for the BurstSearch Result  %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NirFilter(~,~)
global UserValues PamMeta
h = guidata(findobj('Tag','Pam'));
%%% get BurstData from PamMeta
BurstData = PamMeta.BurstData;
%%% Open Parpool
h.Progress.Text.String = 'Opening Parallel Pool...';
StartParPool();
% possibilites for tau_2CDE
% number eg. 100
% some numbers eg. 100;200
% range of numbers eg. 100:100:1000
tau_2CDE = str2num(h.Burst.NirFilter_Edit.String);
if numel(tau_2CDE) > 1
    disp('Mulitple 2CDE time windows not supported at the moment.');
    return;
end

h.Progress.Text.String = 'Preparing Data...';drawnow;
if isnan(tau_2CDE)
    h.Burst.NirFilter_Edit.String =  '100';
    tau_2CDE = 100;
end
BAMethod = BurstData.BAMethod;
BurstData.nir_filter_parameter = tau_2CDE;
%%% Load associated Macro- and Microtimes from *.bps file
[Path,File,~] = fileparts(BurstData.FileName);
% Initialize variables as dummies
Macrotime = cell(0); Channel = cell(0);
load(fullfile(Path,[File '.bps']),'-mat');
%Macrotime = cellfun(@double,Macrotime,'UniformOutput',false);
%Channel = cellfun(@double,Channel,'UniformOutput',false);

h.Progress.Text.String = 'Calculating 2CDE Filter...'; drawnow;
tic
if numel(Macrotime) > 0
    for t=1:numel(tau_2CDE)
        tau = tau_2CDE(t)*1E-6/BurstData.ClockPeriod;
        if numel(tau_2CDE) == 1
            tex = 'Calculating 2CDE Filter...';
        else
            tex = ['Calculating 2CDE Filter ' num2str(t) ' of ' num2str(numel(tau_2CDE))];
        end
        if any(BurstData.BAMethod == [1,2,5,6]) %2 Color Data
            FRET_2CDE = zeros(numel(Macrotime),1); %#ok<USENS>
            ALEX_2CDE = zeros(numel(Macrotime),1);

            %%% Split into 10 parts to display progress
            parts = (floor(linspace(1,numel(Macrotime),11)));
            for j = 1:10
                Progress((j-1)/10,h.Progress.Axes, h.Progress.Text,tex);
                parfor (i = parts(j):parts(j+1),UserValues.Settings.Pam.ParallelProcessing)
                    if ~(numel(Macrotime{i}) > 1E5)
                        [FRET_2CDE(i), ALEX_2CDE(i), E_D(i), E_A(i)] = KDE(Macrotime{i}',Channel{i}',tau, BAMethod); %#ok<USENS,PFIIN>
                    else
                        ALEX_2CDE(i) = NaN;
                        FRET_2CDE(i) = NaN;
                        E_D(i) = NaN;
                        E_A(i) = NaN;
                    end
                end
            end
            idx_ALEX2CDE = strcmp('ALEX 2CDE Filter',BurstData.NameArray);
            idx_FRET2CDE = strcmp('FRET 2CDE Filter',BurstData.NameArray);
            BurstData.DataArray(:,idx_ALEX2CDE) = ALEX_2CDE;
            BurstData.DataArray(:,idx_FRET2CDE) = FRET_2CDE;
            %%% Add the intermediate quantities used to calculate FRET-2CDE as well
            BurstData.NirFilter.E_D = E_D;
            BurstData.NirFilter.E_A = E_A;
        elseif any(BurstData.BAMethod == [3,4]) %3 Color Data
            FRET_2CDE = zeros(numel(Macrotime),3);
            ALEX_2CDE = zeros(numel(Macrotime),3);
            %%% Split into 10 parts to display progress
            parts = (floor(linspace(1,numel(Macrotime),11)));
            for j = 1:10
                Progress((j-1)/10,h.Progress.Axes, h.Progress.Text,tex);
                parfor (i = parts(j):parts(j+1),UserValues.Settings.Pam.ParallelProcessing)
                    if ~(numel(Macrotime{i}) > 1E5)
                        [FRET_2CDE(i,:), ALEX_2CDE(i,:)] = KDE_3C(Macrotime{i}',Channel{i}',tau); %#ok<PFIIN>
                    else
                        FRET_2CDE(i,:) = NaN(1,3);
                        ALEX_2CDE(i,:) = NaN(1,3);
                    end
                end
            end
            idx_ALEX2CDE = find(strcmp('ALEX 2CDE BG Filter',BurstData.NameArray));
            idx_FRET2CDE = find(strcmp('FRET 2CDE BG Filter',BurstData.NameArray));
            BurstData.DataArray(:,idx_ALEX2CDE:(idx_ALEX2CDE+2)) = ALEX_2CDE;
            BurstData.DataArray(:,idx_FRET2CDE:(idx_FRET2CDE+2)) = FRET_2CDE;
        end
        %if numel(tau_2CDE) == 1
        save(BurstData.FileName,'BurstData');
        %else
        %   save([BurstData.FileName(1:end-4) '_TC' num2str(tau_2CDE(t)) '_.bur'],'BurstData');
        %end

        %%% update the info txt file
        filename = fullfile([BurstData.FileName(1:end-3) 'txt']);
        A = regexp( fileread(filename), '\n', 'split');
        row = find(cell2mat(cellfun(@(x) logical(strcmp(x(1:min([22,end])),'2CDE filter parameter:')),A,'UniformOutput',false)));
        A{row} = sprintf('2CDE filter parameter:\t%d mus',tau_2CDE);
        fid = fopen(filename, 'w');
        fprintf(fid, '%s\n', A{:});
        fclose(fid);
    end
else
    tex = 'Calculating 2CDE Filter...';
end
%%% update BurstData in PamMeta
PamMeta.BurstData = BurstData;

Progress(1,h.Progress.Axes, h.Progress.Text,tex);
toc
Update_Display([],[],1);
h.Burst.NirFilter_Button.ForegroundColor = [0 0.8 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loads a performed BurstSearch for further/re-analysis  %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Performed_BurstSearch(obj,~)
global PamMeta UserValues
%%% clear BurstData in PamMeta
PamMeta.BurstData = [];

h = guidata(obj);
[FileName,PathName] = uigetfile({'*.bur'}, 'Choose a file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');

if FileName == 0
    return;
end
UserValues.File.BurstBrowserPath=PathName;
LSUserValues(1);
load('-mat',fullfile(PathName,FileName)); %%% loads data as BurstData structure
%%% Update FileName (if it was previously analyzed on a different computer)
BurstData.FileName = fullfile(PathName,FileName);

% burst analysis before December 16, 2015
if ~isfield(BurstData, 'ClockPeriod')
    BurstData.ClockPeriod = BurstData.SyncPeriod;
    BurstData.FileInfo.ClockPeriod = BurstData.FileInfo.SyncPeriod;
    if isfield(BurstData.FileInfo,'Card')
        if ~strcmp(BurstData.FileInfo.Card, 'SPC-140/150/830/130')
            %if SPC-630 is used, set the SyncPeriod to what it really is
            BurstData.SyncPeriod = 1/8E7*3;
            BurstData.FileInfo.SyncPeriod = 1/8E7*3;
            if rand < 0.05
                msgbox('Be aware that the SyncPeriod is hardcoded. This message appears 1 out of 20 times.')
            end
        end
    end
end

Update_Display([],[],1);
%%% set the text of the BurstSearch Button to green color to indicate that
%%% a burst search has been done
h.Burst.Button.ForegroundColor = [0 0.8 0];
%%% Enable Lifetime and 2CDE Button
h.Burst.BurstLifetime_Button.Enable = 'on';
%%% Check if lifetime has been fit already
if any(BurstData.BAMethod == [1,2,5,6])
    if (sum(BurstData.DataArray(:,strcmp('Lifetime D [ns]',BurstData.NameArray))) == 0 )
        %%% no lifetime fit
        h.Burst.BurstLifetime_Button.ForegroundColor = [1 0 0];
    else
        %%% lifetime was fit
        h.Burst.BurstLifetime_Button.ForegroundColor = [0 0.8 0];
    end
elseif any(BurstData.BAMethod == [3,4])
    if (sum(BurstData.DataArray(:,strcmp('Lifetime BB [ns]',BurstData.NameArray))) == 0 )
        %%% no lifetime fit
        h.Burst.BurstLifetime_Button.ForegroundColor = [1 0 0];
    else
        %%% lifetime was fit
        h.Burst.BurstLifetime_Button.ForegroundColor = [0 0.8 0];
    end
end

h.Burst.NirFilter_Button.Enable = 'on';
%%% Check if NirFilter was calculated before
if any(BurstData.BAMethod == [1,2,5,6])
    if (sum(BurstData.DataArray(:,strcmp('ALEX 2CDE Filter',BurstData.NameArray))) == 0 )
        %%% no NirFilter
        h.Burst.NirFilter_Button.ForegroundColor = [1 0 0];
    else
        %%% NirFilter was calcuated
        h.Burst.NirFilter_Button.ForegroundColor = [0 0.8 0];
    end
elseif any(BurstData.BAMethod == [3,4])
    if (sum(BurstData.DataArray(:,strcmp('ALEX 2CDE GR Filter',BurstData.NameArray))) == 0 )
        %%% no NirFilter
        h.Burst.NirFilter_Button.ForegroundColor = [1 0 0];
    else
        %%% NirFilter was calculated
        h.Burst.NirFilter_Button.ForegroundColor = [0 0.8 0];
    end
end
[~,str,~] = fileparts(BurstData.FileName);
str = ['Loaded file: ' str];
h.Burst.LoadedFile_Text.String = str;
h.Burst.LoadedFile_Text.TooltipString = str;
%%% store in PamMeta
PamMeta.BurstData = BurstData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Performs a Burst Search with specified algorithm  %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [start, stop, Number_of_Photons, detected_channel] = Perform_BurstSearch(Photons,Channel,type,T,M,L,logical_gate)
% Input parameters:
% logical_gate - for DCBS, specifies if AND, OR or XOR is used
% Output parameters:
% detected_channel - encodes in which channel a burst was detected. "0" means the burst was detected in APBS or merged.
if nargin < 7
    logical_gate = 'AND';
end
detected_channel = [];
switch type
    case 'APBS'
        %All-Photon Burst Search
        [start, stop, Number_of_Photons] = APBS(Photons,T,M,L);
        detected_channel = zeros(size(start));
    case {'DCBS','DCBS-noMFD'}
        %Dual Channel Burst Search
        %Get GX and RR photon streams
        switch type
            case 'DCBS' % MFD
                %1,2 = GG12
                %3,4 = GR12
                %5,6 = RR12
                PhotonsD = Photons(Channel == 1 | Channel == 2 | Channel == 3 | Channel == 4);
                PhotonsA = Photons(Channel == 5 | Channel == 6);
                indexD = find((Channel == 1 | Channel == 2 | Channel == 3 | Channel == 4));
                indexA = find((Channel == 5 | Channel == 6));
            case 'DCBS-noMFD'
                %1 = GG
                %2 = GR
                %3 = RR
                PhotonsD = Photons((Channel == 1 | Channel == 2));
                PhotonsA = Photons(Channel == 3);
                indexD = find((Channel == 1 | Channel == 2));
                indexA = find(Channel == 3);
        end
        
        %do burst search on each channel
        MD = M(1);
        MA = M(2);
        TD = T(1);
        TA = T(2);
        %ACBS(Photons,T,M,L), don't specify L for no cutting!
        [startD, stopD, ~] = APBS(PhotonsD,TD,MD);
        [startA, stopA, ~] = APBS(PhotonsA,TA,MA);
        
        startD = indexD(startD);
        stopD = indexD(stopD);
        startA = indexA(startA);
        stopA = indexA(stopA);
        
        % AND, OR or XOR?
        switch logical_gate
            case 'AND'
                validA = zeros(1,numel(startA));
                for i = 1:numel(startA)
                    % find stop of closest burst in other channel
                    current = find(stopD-startA(i) > 0,1,'first');
                    if startD(current) < stopA(i)
                        % bursts are overlapping, truncate to overlapping region
                        startA(i) = max([startD(current) startA(i)]);
                        stopA(i) = min([stopD(current) stopA(i)]);
                        validA(i) = 1;
                    end
                end
                start = startA(validA == 1);
                stop = stopA(validA == 1);
                detected_channel = zeros(size(start)); % all bursts are detected in both channels
            case {'OR (merge)','OR (no merge)'}
                % combine start/stops
                start = [startD; startA];
                [start, ix] = sort(start);
                stop =  [stopD; stopA];
                stop = stop(ix);
                if strcmp(logical_gate,'OR (merge)')
                    % merge overlapping bursts
                    valid = true(1,numel(start));
                    for i = 1:numel(start)-1
                        if start(i+1) < stop(i)
                            % merge burst i+1 with i
                            % set start of merged burst at position i+1 to start of burst i
                            start(i+1) = start(i);
                            if stop(i) > stop(i+1)
                                % if stop of burst i is after burst i+1, overwrite
                                stop(i+1) = stop(i);
                            end
                            % mark burst i for deletion
                            valid(i) = false;
                        end
                    end
                    % bursts are either in channel 1 or 2
                    detected_channel = ismember(start,startD)+2*ismember(start,startA);
                    % or they have been merged ("0")
                    merged = find(~valid)+1; % every burst after is merged
                    detected_channel(merged) = 0;
                    
                    start = start(valid);
                    stop = stop(valid);
                    detected_channel = detected_channel(valid);
                else % no merging
                    detected_channel = ismember(start,startD)+2*ismember(start,startA); % all bursts are either in channel 1 or 2
                end                
            case 'XOR'
                % exclusive OR
                validA = true(size(startA));
                validD = true(size(startD));
                for i = 1:numel(startA)
                    % find start of next burst in other channel
                    current = find(stopD-startA(i) > 0,1,'first');
                    if startD(current) < stopA(i)
                        % bursts are overlapping, truncate to exclude overlapping region
                        if startD(current) < startA(i) && stopD(current) > stopA(i)
                            % burst in other channels starts before and ends after
                            validA(i) = false; % remove burst
                            % split burst in other channel
                            % add the second half as new burst
                            startD(end+1) = stopA(i);
                            stopD(end+1) = stopD(current);
                            validD(end+1) = true;
                            % truncate the first half
                            stopD(current) = startA(i);
                        elseif startD(current) < startA(i) && stopD(current) < stopA(i)
                            % burst in other channel starts before and ends during
                            stopD_current = stopD(current); % temporary storage
                            % truncate the burst in the other channel                            
                            stopD(current) = startA(i);
                            % shift start of burst
                            startA(i) = stopD_current;
                        elseif startD(current) > startA(i) && stopD(current) > stopA(i)
                            % burst in other channel starts during and ends after
                            stopAi = stopA(i); % temporary storage
                            % truncate burst in this channel
                            stopA(i) = startD(current);
                            % shift start of burst in other channel
                            startD(current) = stopAi;
                        elseif startD(current) > startA(i) && stopD(current) < stopA(i)
                            % burst in other channel starts during and ends during
                            validD(current) = false; % remove burst
                            % split burst in this channel
                            % add the second half as new burst
                            startA(end+1) = stopD(current);
                            stopA(end+1) = stopA(i);
                            validA(end+1) = true;
                            % truncate the first half
                            stopA(i) = startD(current);
                        end                        
                    end
                end
                % remove invalid bursts
                startA = startA(validA);
                stopA = stopA(validA);
                startD = startD(validD);
                stopD = stopD(validD);
                % combine start/stops
                start = [startD; startA];
                [start, ix] = sort(start);
                stop =  [stopD; stopA];
                stop = stop(ix);
                
                detected_channel = ismember(start,startD)+2*ismember(start,startA); % all bursts are either in channel 1 or 2
        end
        
        Number_of_Photons = stop-start+1;
        start(Number_of_Photons<L)=[];
        stop(Number_of_Photons<L)=[];
        detected_channel(Number_of_Photons<L)=[];
        Number_of_Photons(Number_of_Photons<L)=[];
    case 'TCBS'
        %Triple Channel Burst Search
        %Get BX, GX and RR photon streams
        %1,2 = BB12
        %3,4 = BG12
        %5,6 = BR12
        %7,8 = GG12
        %9,10 = GR12
        %11,12 = RR 12
        PhotonsB = Photons(Channel == 1 | Channel == 2 | Channel == 3 | Channel == 4| Channel == 5 | Channel == 6);
        PhotonsG = Photons(Channel == 7 | Channel == 8 | Channel == 9 | Channel == 10);
        PhotonsR = Photons(Channel == 11 | Channel == 12);
        indexB = find((Channel == 1 | Channel == 2 | Channel == 3 | Channel == 4| Channel == 5 | Channel == 6));
        indexG = find((Channel == 7 | Channel == 8 | Channel == 9 | Channel == 10));
        indexR = find((Channel == 11 | Channel == 12));
        
        %do burst search on each channel
        MB = M(1);
        MG = M(2);
        MR = M(3);
        %ACBS(Photons,T,M,L), don't specify L for no cutting!
        [startB, stopB, ~] = APBS(PhotonsB,T,MB);
        [startG, stopG, ~] = APBS(PhotonsG,T,MG);
        [startR, stopR, ~] = APBS(PhotonsR,T,MR);
        
        startR = indexR(startR);
        stopR = indexR(stopR);
        startG = indexG(startG);
        stopG = indexG(stopG);
        startB = indexB(startB);
        stopB = indexB(stopB);
        
        validR = zeros(numel(startR),1);
        
        for i = 1:numel(startR)
            current = find(stopG-startR(i) > 0,1,'first');
            if startG(current) < stopR(i)
                startR(i) = max([startG(current) startR(i)]);
                stopR(i) = min([stopG(current) stopR(i)]);
                validR(i) = 1;
            end
        end
        start = startR(validR == 1);
        stop = stopR(validR == 1);
        
        
        validB = zeros(numel(start),1);
        
        for i = 1:numel(start)
            current = find(stopB-start(i) > 0,1,'first');
            if startB(current) < stop(i)
                start(i) = max([startB(current) start(i)]);
                stop(i) = min([stopB(current) stop(i)]);
                validB(i) = 1;
            end
        end
        start = start(validB == 1);
        stop = stop(validB == 1);
        
        Number_of_Photons = stop-start+1;
        start(Number_of_Photons<L)=[];
        stop(Number_of_Photons<L)=[];
        Number_of_Photons(Number_of_Photons<L)=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Subroutine a for All-Photon BurstSearch  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [start, stop, Number_of_Photons] = APBS(Photons,T,M,L,BurstIdentification)
global FileInfo
if nargin < 5
    h = guidata(findobj('Tag','Pam'));
    BurstIdentification = h.Burst.BurstSearchSmoothing_Popupmenu.Value;
end
if BurstIdentification == 1
    %All-Photon Burst Search based on Nir Paper (2006)
    valid=(Photons(1+M:end)-Photons(1:end-M)) < T*1e-6/FileInfo.ClockPeriod;
    
    % and find start and stop of bursts
    start = find(valid(1:end-1)-valid(2:end)==-1) + 1 + floor(M/2); % +1 is necessary
    stop = find(valid(1:end-1)-valid(2:end)==1)+floor(M/2);
    
elseif BurstIdentification == 2
    % Seidel-Type burstsearch based on interphoton time and Lee Filter
    m = T;
    T = M;
    if M>1
        % Smooth the interphoton time trace
        dT =[Photons(1);diff(Photons)];
        dT_m = zeros(size(dT,1),size(dT,2));
        dT_s = zeros(size(dT,1),size(dT,2));
        % Apply Lee Filter with window 2m+1
        sig_0 = std(dT); %%% constant filter parameter is the noise variance, set to standard devitation of interphoton time
        dT_cumsum = cumsum(dT);
        dT_cumsum = [0; dT_cumsum];
        for i = m+1:numel(dT)-m
            dT_m(i) = (2*m+1)^(-1)*(dT_cumsum(i+m+1)-dT_cumsum(i-m));
        end
        dT_sq_cumsum = cumsum((dT-dT_m).^2);
        dT_sq_cumsum = [0;dT_sq_cumsum];
        for i = 2*m:numel(dT)-2*m
            dT_s(i) = (2*m+1)^(-1)*(dT_sq_cumsum(i+m+1)-dT_sq_cumsum(i-m));
        end
        
        %filtered data
        dT_f = dT_m + (dT-dT_m).*dT_s./(dT_s+sig_0.^2);
        
        % threshold
        valid = dT_f < T*1e-6/FileInfo.ClockPeriod;
        
    elseif M == 1
        % threshold
        valid = [Photons(1); diff(Photons)] < T*1e-6/FileInfo.ClockPeriod;
    end
    % and find start and stop of bursts
    start = find(valid(1:end-1)-valid(2:end)==-1);
    stop = find(valid(1:end-1)-valid(2:end)==1);
elseif BurstIdentification == 3
    IT = M; % threshold in kHz
    IB = T; % background in kHz
    [start, stop] = CUSUM_burstsearch(Photons,IB,IT);
elseif BurstIdentification == 4
    threshold = M; % in kHz
    [start,stop] = get_changepoints(Photons,threshold);
end
clear valid;

if numel(start) < numel(stop)
    stop(1) = [];
elseif numel(start) > numel(stop)
    start(end) = [];
end

if numel(start) ~= 0 && numel(stop) ~=0
    if start(1) > stop(1)
        stop(1)=[];
        start(end) = [];
    end
end
% and ignore bursts with less than L photons
% only cut if L is specified (it is not for DCBS sub-searches)
if ~isempty(stop) && ~isempty(start)
    Number_of_Photons = stop-start+1;
else
    Number_of_Photons = [];
end

if nargin > 3
    start(Number_of_Photons<L)=[];
    stop(Number_of_Photons<L)=[];
    Number_of_Photons(Number_of_Photons<L)=[];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for CUSUM based burst search                              %%%%
%%% Based on: Zhang, K. & Yang, H. Photon-by-photon determination of   %%%%
%%% emission bursts from diffusing single chromophores.                %%%%
%%% J Phys Chem B 109, 21930-21937 (2005).                             %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [START,STOP] = CUSUM_burstsearch(Photons,IB,IT)
global FileInfo
START = [];
STOP = [];
% convert photons to delay times
dt = diff(Photons);
if any(~isinteger(dt))
    disp('Warning: Non-integer macrotimes found. Interphoton times will be rounded.');
    dt = round(dt);
end
% parameters (all count rates are given in kHz and need to be converted to
% the used clock period)
IB = IB*1E3*FileInfo.ClockPeriod; % background count rate per clock period
IT = IT*1E3*FileInfo.ClockPeriod; % threshold intensity
% alternative parameterization based on molecular brightness to determine
% the threshold
% I0 = I0*1E3*FileInfo.ClockPeriod; % intensity of molecule at the center of PSF (molecular brightness)
% IT = I0*exp(-2)+IB; % threshold intensity at 1/e^2

% error rates
alpha = 1/numel(Photons);
beta = 0.05;
% calculate the expectation value of the log likelihood ratio
x = 0:1:max([max(dt), ceil(-log(1E-3)/IB)]);
fB = exp(-x*IB); fB = fB./sum(fB); fB(fB==0) = eps;
fT = exp(-x*IT); fT = fT./sum(fT); fT(fT==0) = eps;
lambda = log(fT)-log(fB);
%mlambdaB = sum(fB.*lambda);
mlambdaT = sum(fT.*lambda);
% define CUSUM threshold h
h = -log(alpha*log(alpha^(-1))/(3*(mlambdaT+1)^2)); % eq. 4
% define SPRT thresholds A and B
B = beta/(1-alpha);
A = (1-beta)/alpha;

start_next = 1; % of the next burst
stop = 1; % stop of the previous burst, start searching from here
while start_next < numel(dt) % we have not reached the end
    % find the first edge using CUSUM
    start = CUSUM(dt,h,fB,fT,stop);
    
    % estimate the end of burst using SPRT
    stop_est = SPRT(dt,A,B,fB,fT,start);
    if stop_est > start+5 % require an offest of at least 5 photons
        % find the next edge using CUSUM
        start_next = CUSUM(dt,h,fB,fT,stop_est);

        % do backwards CUSUM to refine the end of the previous burst
        stop = bCUSUM(dt,h,fB,fT,start,start_next,10);

        if stop < stop_est && stop > start
            if isempty(START) || START(end) ~= start
                START(end+1,1) = start;
                STOP(end+1,1) = stop;
            else % sometimes, the algorithm gets stuck
                % move on
                stop = start + 10;
                start_next = stop; % to trigger exit condition
            end
        end
    else % sometimes, the algorithm gets stuck
        % move on
        stop = start + 10;
        start_next = stop; % to trigger exit condition
    end
end

function ix = CUSUM(dt,h,fB,fT,ix_start)
% find the first edge using CUSUM
if nargin < 5
    ix_start = 1;
end
ix = ix_start-1; % go one back because we increase the counter in the while loop before evaluating the S function
S = 0;
while S < h && ix < numel(dt)
    ix = ix + 1;
    S = max([S+log(fT(dt(ix)+1))-log(fB(dt(ix)+1)),0]);
end

function ix = SPRT(dt,A,B,fB,fT,ix_start)
% estimate the burst end using SPRT
if nargin < 6
    ix_start = 1;
end
ix = ix_start;
LAMBDA = fT(dt(ix_start)+1)/fB(dt(ix_start)+1);
while LAMBDA > B && ix < numel(dt)
    ix = ix+1;
    LAMBDA = LAMBDA*fT(dt(ix)+1)/fB(dt(ix)+1);
    if LAMBDA >= A
        LAMBDA = A;
    elseif LAMBDA <= B
        LAMBDA = B;
    end
end

function ix = bCUSUM(dt,h,fB,fT,ix_start,ix_next,offset)
if nargin < 7
    offset = 10; % offset necessary because if we start in the burst, the threshold is crossed in the beginning already.
end
dt_b = dt(ix_next-offset:-1:ix_start);
ix = ix_next-offset-CUSUM(dt_b,h,fB,fT);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Updates or shifts the preview  window in BurstAnalysis %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BurstSearch_Preview(obj,~)
global FileInfo UserValues PamMeta
h = guidata(findobj('Tag','Pam'));

if obj ==  h.Burst.BurstSearchPreview_Button %%% recalculate the preview
    %%% Set Progress Bar
    h.Progress.Text.String = 'Calculating Burst Search Preview...';
    drawnow;
    %%% hide plots initially
    set([h.Plots.BurstPreview.Channel2_Interphot,h.Plots.BurstPreview.Channel2_Interphot_Smooth,...
        h.Plots.BurstPreview.Channel3_Interphot, h.Plots.BurstPreview.Channel3_Interphot_Smooth,],...
        'Visible','off');
    PamMeta.Burst.Preview.InterphotonTime_Smoothed = [];
    
    %bintime for display, based on the time window used for the burst analysis
    %Bin_Time = UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.Method}(2)*1E-6/FileInfo.ClockPeriod;
    bin_time_ms = 0.5;
    Bin_Time = bin_time_ms*1E-3/FileInfo.ClockPeriod;
    %perform burst analysis on first 60 seconds
    %achieve loading of less photons by using chunksize of preview and first
    %chunk
    ChunkSize = 2; % minutes
    T_preview = 60*ChunkSize/FileInfo.ClockPeriod;
    BAMethod = UserValues.BurstSearch.Method;
    SmoothingMethod =  UserValues.BurstSearch.SmoothingMethod;%h.Burst.BurstSearchSmoothing_Popupmenu.Value;
    DCBS_logical_gate = UserValues.BurstSearch.LogicalGate;
    
    if any(BAMethod == [1 2]) %ACBS 2 Color
        %prepare photons
        %read out macrotimes for all channels
        Photons{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Macrotime',1,ChunkSize);
        Photons{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2},'Macrotime',1,ChunkSize);
        Photons{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Macrotime',1,ChunkSize);
        Photons{4} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2},'Macrotime',1,ChunkSize);
        Photons{5} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Macrotime',1,ChunkSize);
        Photons{6} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2},'Macrotime',1,ChunkSize);
        AllPhotons_unsort = vertcat(Photons{:});
        %sort
        [AllPhotons, index] = sort(AllPhotons_unsort);
        clear AllPhotons_unsort
        %get colors of photons
        chan_temp = uint8([1*ones(1,numel(Photons{1})) 2*ones(1,numel(Photons{2})) 3*ones(1,numel(Photons{3}))...
            4*ones(1,numel(Photons{4})) 5*ones(1,numel(Photons{5})) 6*ones(1,numel(Photons{6}))])';
        Channel = chan_temp(index);
        clear index chan_temp
        
        if BAMethod == 1
            T = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2);
            M = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3);
            L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
            [start, stop, ~] = Perform_BurstSearch(AllPhotons,[],'APBS',T,M,L);
        elseif BAMethod == 2
            T = [UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2),...
                UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(6)];
            M = [UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3),...
                UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(4)];
            L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
            [start, stop, ~,detected_channel] = Perform_BurstSearch(AllPhotons,Channel,'DCBS',T,M,L,DCBS_logical_gate);
        end
    elseif any(BAMethod == [3,4])
        Photons{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Macrotime',1,ChunkSize);
        Photons{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2},'Macrotime',1,ChunkSize);
        Photons{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Macrotime',1,ChunkSize);
        Photons{4} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2},'Macrotime',1,ChunkSize);
        Photons{5} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Macrotime',1,ChunkSize);
        Photons{6} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2},'Macrotime',1,ChunkSize);
        Photons{7} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,1},'Macrotime',1,ChunkSize);
        Photons{8} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,2},'Macrotime',1,ChunkSize);
        Photons{9} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{5,1},'Macrotime',1,ChunkSize);
        Photons{10} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{5,2},'Macrotime',1,ChunkSize);
        Photons{11} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,1},'Macrotime',1,ChunkSize);
        Photons{12} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,2},'Macrotime',1,ChunkSize);
        AllPhotons_unsort = vertcat(Photons{:});
        %sort
        [AllPhotons, index] = sort(AllPhotons_unsort);
        clear AllPhotons_unsort
        %get colors of photons
        chan_temp = uint8([1*ones(1,numel(Photons{1})) 2*ones(1,numel(Photons{2})) 3*ones(1,numel(Photons{3}))...
            4*ones(1,numel(Photons{4})) 5*ones(1,numel(Photons{5})) 6*ones(1,numel(Photons{6}))...
            7*ones(1,numel(Photons{7})) 8*ones(1,numel(Photons{8})) 9*ones(1,numel(Photons{9}))...
            10*ones(1,numel(Photons{10})) 11*ones(1,numel(Photons{11})) 12*ones(1,numel(Photons{12}))])';
        Channel = chan_temp(index);
        clear index chan_temp
        
        if BAMethod == 3 %ACBS 3 Color
            T = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2);
            M = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3);
            L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
            [start, stop, ~] = Perform_BurstSearch(AllPhotons,[],'APBS',T,M,L);
        elseif BAMethod == 4 %TCBS
            T = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2);
            M = [UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3),...
                UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(4),...
                UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(5)];
            L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
            [start, stop, ~] = Perform_BurstSearch(AllPhotons,Channel,'TCBS',T,M,L,DCBS_logical_gate);
        end
        
    elseif any(BAMethod == [5,6]) %2 color no MFD
        %prepare photons
        %read out macrotimes for all channels
        Photons{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Macrotime',1,ChunkSize);
        Photons{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Macrotime',1,ChunkSize);
        Photons{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Macrotime',1,ChunkSize);
        AllPhotons_unsort = vertcat(Photons{:});
        %sort
        [AllPhotons, index] = sort(AllPhotons_unsort);
        clear AllPhotons_unsort
        %get colors of photons
        chan_temp = uint8([1*ones(1,numel(Photons{1})) 2*ones(1,numel(Photons{2})) 3*ones(1,numel(Photons{3}))])';
        Channel = chan_temp(index);
        %do search
        if BAMethod == 5 %ACBS 2 Color-noMFD
            T = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2);
            M = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3);
            L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
            [start, stop, ~] = Perform_BurstSearch(AllPhotons,[],'APBS',T,M,L);
        elseif BAMethod == 6 %DCBS 2 Color-noMFD
            T = [UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2),...
                UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(6)];
            M = [UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3),...
                UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(4)];
            L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
            [start, stop, ~,detected_channel] = Perform_BurstSearch(AllPhotons,Channel,'DCBS-noMFD',T,M,L,DCBS_logical_gate);
        end
    end
    
    %% prepare trace for display
    xout = 0:Bin_Time:T_preview;
    switch BAMethod %make histograms for lower display with binning T_classic
        case {1,2}    % 2 color, MFD
            [ch1] = hist([Photons{1}; Photons{2}; Photons{3}; Photons{4}], xout);
            [ch2] = hist([Photons{5}; Photons{6}], xout);
        case {3,4}    % 3 color, MFD
            [ch3] = hist([Photons{1}; Photons{2}; Photons{3}; Photons{4}; Photons{5}; Photons{6}], xout);
            [ch1] = hist([Photons{7}; Photons{8}; Photons{9}; Photons{10}], xout);
            [ch2] = hist([Photons{11}; Photons{12}], xout);
        case {5,6}
            [ch1] = hist([Photons{1}; Photons{2}], xout);
            [ch2] = hist([Photons{3}], xout);
    end
    %convert photon number to bin number
    starttime = max(floor(AllPhotons(start)/Bin_Time)+1,1); %+1 since matlab indexing
    stoptime = min(ceil(AllPhotons(stop)/Bin_Time),xout(end));
    
    %Update PamMeta
    PamMeta.Burst.Preview.x = xout*FileInfo.ClockPeriod;
    PamMeta.Burst.Preview.ch1 = ch1./bin_time_ms;
    PamMeta.Burst.Preview.ch2 = ch2./bin_time_ms;
    PamMeta.Burst.Preview.stop = stop;
    PamMeta.Burst.Preview.start = start;
    PamMeta.Burst.Preview.starttime = starttime;
    PamMeta.Burst.Preview.stoptime = stoptime;
    PamMeta.Burst.Preview.AllPhotons = AllPhotons;
    if any(BAMethod == [3 4])
        PamMeta.Burst.Preview.ch3 = ch3./bin_time_ms;
    end
    %%% set the second to be displayed (here first)
    if ~isfield(PamMeta.Burst.Preview,'Second')
        PamMeta.Burst.Preview.Second = 0;
    end
    
    %%% clear old data
    if isfield(h.Plots.BurstPreview,'SearchResult')
        for i = 1:numel(h.Plots.BurstPreview.SearchResult.Channel1)
            delete(h.Plots.BurstPreview.SearchResult.Channel1(i));
        end
        if isfield(h.Plots.BurstPreview.SearchResult,'Channel2')
            for i = 1:numel(h.Plots.BurstPreview.SearchResult.Channel2)
                delete(h.Plots.BurstPreview.SearchResult.Channel2(i));
            end
        end
        for i = 1:numel(h.Plots.BurstPreview.SearchResult.Interphot)
            delete(h.Plots.BurstPreview.SearchResult.Interphot(i));
        end
        if isfield(h.Plots.BurstPreview.SearchResult,'Channel3')
            for i = 1:numel(h.Plots.BurstPreview.SearchResult.Channel3)
                delete(h.Plots.BurstPreview.SearchResult.Channel3(i));
            end
        end
    end
    %%% get the channel colors from the PIE channels
    switch BAMethod
        case {1,2,5,6} % two color
            % take the parallel channel color for MFD setups
            channel_colors(1,:) = UserValues.PIE.Color(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1}),:);
            channel_colors(2,:) = UserValues.PIE.Color(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1}),:);
        case {3,4}
            channel_colors(1,:) = UserValues.PIE.Color(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,1}),:);
            channel_colors(2,:) = UserValues.PIE.Color(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,1}),:);
            channel_colors(3,:) = UserValues.PIE.Color(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1}),:);
    end    
    %%% Plot the data
    h.Plots.BurstPreview.Channel1.XData = PamMeta.Burst.Preview.x;
    h.Plots.BurstPreview.Channel1.YData = PamMeta.Burst.Preview.ch1;
    h.Plots.BurstPreview.Channel2.XData = PamMeta.Burst.Preview.x;
    h.Plots.BurstPreview.Channel2.YData = PamMeta.Burst.Preview.ch2;
    h.Plots.BurstPreview.Channel1.Color = channel_colors(1,:);%[0 0.8 0];
    h.Plots.BurstPreview.Channel2.Color = channel_colors(2,:);%[1 0 0];
    %%% hide third channel
    h.Plots.BurstPreview.Channel3.Visible = 'off';
    if any(BAMethod == [3,4])
        h.Plots.BurstPreview.Channel3.XData = PamMeta.Burst.Preview.x;
        h.Plots.BurstPreview.Channel3.YData = PamMeta.Burst.Preview.ch3;
        h.Plots.BurstPreview.Channel3.Color = channel_colors(3,:);%[0 0 1];
        h.Plots.BurstPreview.Channel3.Visible = 'on';
    end
    h.Burst.Axes_Intensity.XLim = [0 1];
    h.Burst.Axes_Intensity.YLimMode = 'auto';
    
    %%% plot threshold as well
    switch BAMethod
        case {1,3,5} %2or3color or noMFD, APBS
            h.Plots.BurstPreview.Intensity_Threshold_ch1.Visible = 'on';
            h.Plots.BurstPreview.Intensity_Threshold_ch1.Color = [0 0 0];
            h.Plots.BurstPreview.Intensity_Threshold_ch1.XData = PamMeta.Burst.Preview.x;
            if SmoothingMethod == 1
                h.Plots.BurstPreview.Intensity_Threshold_ch1.YData = 1000*M/T*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 2  %%% take the inverse of the interphoton time
                h.Plots.BurstPreview.Intensity_Threshold_ch1.YData = (1E3/M)*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif  any(SmoothingMethod == [3,4]) % parameter M is the count rate
                h.Plots.BurstPreview.Intensity_Threshold_ch1.YData = M*ones(1,numel(PamMeta.Burst.Preview.x));
            end
            h.Plots.BurstPreview.Intensity_Threshold_ch2.Visible = 'off';
            h.Plots.BurstPreview.Intensity_Threshold_ch3.Visible = 'off';
        case {2,6} %2color DCBS
            h.Plots.BurstPreview.Intensity_Threshold_ch1.Visible = 'on';
            h.Plots.BurstPreview.Intensity_Threshold_ch1.Color = channel_colors(1,:);%[0 0.8 0];
            h.Plots.BurstPreview.Intensity_Threshold_ch1.XData = PamMeta.Burst.Preview.x;
            if SmoothingMethod == 1
                h.Plots.BurstPreview.Intensity_Threshold_ch1.YData = 1000*M(1)/T(1)*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 2 %%% take the inverse of the interphoton time
                h.Plots.BurstPreview.Intensity_Threshold_ch1.YData = (1E3/M(1))*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif any(SmoothingMethod == [3,4]) % parameter M is the count rate
                h.Plots.BurstPreview.Intensity_Threshold_ch1.YData = M(1)*ones(1,numel(PamMeta.Burst.Preview.x));
            end
            h.Plots.BurstPreview.Intensity_Threshold_ch2.Visible = 'on';
            h.Plots.BurstPreview.Intensity_Threshold_ch2.Color = channel_colors(2,:);%[0.8 0 0];
            h.Plots.BurstPreview.Intensity_Threshold_ch2.XData = PamMeta.Burst.Preview.x;
            if SmoothingMethod == 1
                h.Plots.BurstPreview.Intensity_Threshold_ch2.YData = 1000*M(2)/T(2)*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 2 %%% take the inverse of the interphoton time
                h.Plots.BurstPreview.Intensity_Threshold_ch2.YData = (1E3/M(2))*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif any(SmoothingMethod == [3,4]) % parameter M is the count rate
                h.Plots.BurstPreview.Intensity_Threshold_ch2.YData = M(2)*ones(1,numel(PamMeta.Burst.Preview.x));
            end
            h.Plots.BurstPreview.Intensity_Threshold_ch3.Visible = 'off';
        case 4 %TCBS
            h.Plots.BurstPreview.Intensity_Threshold_ch1.Visible = 'on';
            h.Plots.BurstPreview.Intensity_Threshold_ch1.Color = channel_colors(1,:);%[0 0.8 0];
            h.Plots.BurstPreview.Intensity_Threshold_ch1.XData = PamMeta.Burst.Preview.x;
            if SmoothingMethod == 1
                h.Plots.BurstPreview.Intensity_Threshold_ch1.YData = 1000*M(1)/T*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 2 %%% take the inverse of the interphoton time
                h.Plots.BurstPreview.Intensity_Threshold_ch1.YData = (1E3/M(1))*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif any(SmoothingMethod == [3,4]) % parameter M is the count rate
                h.Plots.BurstPreview.Intensity_Threshold_ch1.YData = M(1)*ones(1,numel(PamMeta.Burst.Preview.x));
            end
            h.Plots.BurstPreview.Intensity_Threshold_ch2.Visible = 'on';
            h.Plots.BurstPreview.Intensity_Threshold_ch2.Color = channel_colors(2,:);%[0.8 0 0];
            h.Plots.BurstPreview.Intensity_Threshold_ch2.XData = PamMeta.Burst.Preview.x;
            if SmoothingMethod == 1
                h.Plots.BurstPreview.Intensity_Threshold_ch2.YData = 1000*M(2)/T*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 2 %%% take the inverse of the interphoton time
                h.Plots.BurstPreview.Intensity_Threshold_ch2.YData = (1E3/M(2))*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif any(SmoothingMethod == [3,4]) % parameter M is the count rate
                h.Plots.BurstPreview.Intensity_Threshold_ch2.YData = M(2)*ones(1,numel(PamMeta.Burst.Preview.x));
            end
            h.Plots.BurstPreview.Intensity_Threshold_ch3.Visible = 'on';
            h.Plots.BurstPreview.Intensity_Threshold_ch3.Color = channel_colors(3,:);%[0 0 0.8];
            h.Plots.BurstPreview.Intensity_Threshold_ch3.XData = PamMeta.Burst.Preview.x;
            if SmoothingMethod == 1
                h.Plots.BurstPreview.Intensity_Threshold_ch3.YData = 1000*M(3)/T*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 2 %%% take the inverse of the interphoton time
                h.Plots.BurstPreview.Intensity_Threshold_ch3.YData = (1E3/M(3))*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif any(SmoothingMethod == [3,4]) % parameter M is the count rate
                h.Plots.BurstPreview.Intensity_Threshold_ch3.YData = M(3)*ones(1,numel(PamMeta.Burst.Preview.x));
            end
    end
    %% Plot Interphoton time trace
    %%% read photons
    switch BAMethod
        case {1,3,5}    % APBS            
            % we just take all photons
            PhotonsChannel = {AllPhotons};
        case {2}    % DCBS MFD
            PhotonsChannel{1} = sort([Photons{1}; Photons{2}; Photons{3}; Photons{4}]);
            PhotonsChannel{2} = sort([Photons{5}; Photons{6}]);           
        case {6} % DCBS noMFD
            PhotonsChannel{1} =sort([Photons{1}; Photons{2}]);
            PhotonsChannel{2} = Photons{3};
        case {4} % TCBS MFD
            PhotonsChannel{1} = sort([Photons{1}; Photons{2}; Photons{3}; Photons{4}; Photons{5}; Photons{6}]);
            PhotonsChannel{2} = sort([Photons{7}; Photons{8}; Photons{9}; Photons{10}]);
            PhotonsChannel{3} = sort([Photons{11}; Photons{12}]);
    end

    %%% Smooth with Lee Filter
    if SmoothingMethod == 2
        m = T;
    else
        m = 30*ones(1,numel(PhotonsChannel));
    end
    
    dt_smoothed = cell(numel(m),1);
    dt = cell(numel(m),1);
    for i = 1:numel(m)
         [dt_smoothed{i}, dt{i}] = smooth_interphoton_time_trace(PhotonsChannel{i},m(i));
    end
    brightened_color = (channel_colors+1)./repmat(max(channel_colors+1,[],2),1,3);
    switch BAMethod
        case {1,3,5}    % APBS, gray plots       
            h.Plots.BurstPreview.Channel1_Interphot.Color = [0.4 0.4 0.4];
            h.Plots.BurstPreview.Channel1_Interphot.XData = PhotonsChannel{1}.*FileInfo.ClockPeriod;
            h.Plots.BurstPreview.Channel1_Interphot.YData = dt{1}.*FileInfo.ClockPeriod*1E6;
            h.Plots.BurstPreview.Channel1_Interphot_Smooth.Color = [0 0 0];
            h.Plots.BurstPreview.Channel1_Interphot_Smooth.XData = PhotonsChannel{1}.*FileInfo.ClockPeriod;
            h.Plots.BurstPreview.Channel1_Interphot_Smooth.YData = dt_smoothed{1}.*FileInfo.ClockPeriod*1E6;
        case {2,4,6} % D/TCBS, red and green (and blue)
            h.Plots.BurstPreview.Channel1_Interphot.Color = brightened_color(1,:);%[0.3922 0.8314 0.0745];
            h.Plots.BurstPreview.Channel1_Interphot.XData = PhotonsChannel{1}.*FileInfo.ClockPeriod;
            h.Plots.BurstPreview.Channel1_Interphot.YData = dt{1}.*FileInfo.ClockPeriod*1E6;
            h.Plots.BurstPreview.Channel1_Interphot_Smooth.Color = channel_colors(1,:);%[0 .8 0];
            h.Plots.BurstPreview.Channel1_Interphot_Smooth.XData = PhotonsChannel{1}.*FileInfo.ClockPeriod;
            h.Plots.BurstPreview.Channel1_Interphot_Smooth.YData = dt_smoothed{1}.*FileInfo.ClockPeriod*1E6;
            
            h.Plots.BurstPreview.Channel2_Interphot.Visible = 'on';
            h.Plots.BurstPreview.Channel2_Interphot.Color = brightened_color(2,:);%[0.6353 0.0784 0.1843];
            h.Plots.BurstPreview.Channel2_Interphot.XData = PhotonsChannel{2}.*FileInfo.ClockPeriod;
            h.Plots.BurstPreview.Channel2_Interphot.YData = dt{2}.*FileInfo.ClockPeriod*1E6;
            h.Plots.BurstPreview.Channel2_Interphot_Smooth.Visible = 'on';
            h.Plots.BurstPreview.Channel2_Interphot_Smooth.Color = channel_colors(2,:);%[1 0 0];
            h.Plots.BurstPreview.Channel2_Interphot_Smooth.XData = PhotonsChannel{2}.*FileInfo.ClockPeriod;
            h.Plots.BurstPreview.Channel2_Interphot_Smooth.YData = dt_smoothed{2}.*FileInfo.ClockPeriod*1E6;
            if BAMethod == 4
                h.Plots.BurstPreview.Channel3_Interphot.Visible = 'on';
                h.Plots.BurstPreview.Channel3_Interphot.Color = brightened_color(3,:);%[0.0745 0.6235 1.0000];
                h.Plots.BurstPreview.Channel3_Interphot.XData = PhotonsChannel{3}.*FileInfo.ClockPeriod;
                h.Plots.BurstPreview.Channel3_Interphot.YData = dt{3}.*FileInfo.ClockPeriod*1E6;
                h.Plots.BurstPreview.Channel3_Interphot_Smooth.Visible = 'on';
                h.Plots.BurstPreview.Channel3_Interphot_Smooth.Color = channel_colors(3,:);%[0 0 1];
                h.Plots.BurstPreview.Channel3_Interphot_Smooth.XData = PhotonsChannel{3}.*FileInfo.ClockPeriod;
                h.Plots.BurstPreview.Channel3_Interphot_Smooth.YData = dt_smoothed{3}.*FileInfo.ClockPeriod*1E6;
            end
    end
    
    %%% plot threshold as well
    switch BAMethod
        case {1,3,5} %2or3color or noMFD, APBS
            h.Plots.BurstPreview.Interphoton_Threshold_ch1.Visible = 'on';
            h.Plots.BurstPreview.Interphoton_Threshold_ch1.Color = [0 0 0];
            h.Plots.BurstPreview.Interphoton_Threshold_ch1.XData = PamMeta.Burst.Preview.x;
            if SmoothingMethod == 1 %%% take the inverse of the mean countrate
                h.Plots.BurstPreview.Interphoton_Threshold_ch1.YData = (T/M)*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 2
                h.Plots.BurstPreview.Interphoton_Threshold_ch1.YData = M*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 3 %%% take the inverse of the mean countrate
                h.Plots.BurstPreview.Interphoton_Threshold_ch1.YData = (1/M)*1000*ones(1,numel(PamMeta.Burst.Preview.x));
            end
            h.Plots.BurstPreview.Interphoton_Threshold_ch2.Visible = 'off';
            h.Plots.BurstPreview.Interphoton_Threshold_ch3.Visible = 'off';
        case {2,6} %2color DCBS
            h.Plots.BurstPreview.Interphoton_Threshold_ch1.Visible = 'on';
            h.Plots.BurstPreview.Interphoton_Threshold_ch1.Color = channel_colors(1,:);%[0 0.8 0];
            h.Plots.BurstPreview.Interphoton_Threshold_ch1.XData = PamMeta.Burst.Preview.x;
            if SmoothingMethod == 1 %%% take the inverse of the mean countrate
                h.Plots.BurstPreview.Interphoton_Threshold_ch1.YData = (T(1)/M(1))*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 2
                h.Plots.BurstPreview.Interphoton_Threshold_ch1.YData = M(1)*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 3 %%% take the inverse of the mean countrate
                h.Plots.BurstPreview.Interphoton_Threshold_ch1.YData = (1/M(1))*1000*ones(1,numel(PamMeta.Burst.Preview.x));
            end
            h.Plots.BurstPreview.Interphoton_Threshold_ch2.Visible = 'on';
            h.Plots.BurstPreview.Interphoton_Threshold_ch2.Color = channel_colors(2,:);%[0.8 0 0];
            h.Plots.BurstPreview.Interphoton_Threshold_ch2.XData = PamMeta.Burst.Preview.x;
            if SmoothingMethod == 1 %%% take the inverse of the mean countrate
                h.Plots.BurstPreview.Interphoton_Threshold_ch2.YData = (T(2)/M(2))*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 2
                h.Plots.BurstPreview.Interphoton_Threshold_ch2.YData = M(2)*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif any(SmoothingMethod == [3,4]) %%% take the inverse of the mean countrate
                h.Plots.BurstPreview.Interphoton_Threshold_ch2.YData = (1/M(2))*1000*ones(1,numel(PamMeta.Burst.Preview.x));
            end
            h.Plots.BurstPreview.Interphoton_Threshold_ch3.Visible = 'off';
        case 4 %TCBS
            h.Plots.BurstPreview.Interphoton_Threshold_ch1.Visible = 'on';
            h.Plots.BurstPreview.Interphoton_Threshold_ch1.Color = channel_colors(1,:);%[0 0.8 0];
            h.Plots.BurstPreview.Interphoton_Threshold_ch1.XData = PamMeta.Burst.Preview.x;
            if SmoothingMethod == 1 %%% take the inverse of the mean countrate
                h.Plots.BurstPreview.Interphoton_Threshold_ch1.YData = (T/M(1))*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 2
                h.Plots.BurstPreview.Interphoton_Threshold_ch1.YData = M(1)*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif any(SmoothingMethod == [3,4]) %%% take the inverse of the mean countrate
                h.Plots.BurstPreview.Interphoton_Threshold_ch1.YData = (1/M(1))*1000*ones(1,numel(PamMeta.Burst.Preview.x));
            end
            h.Plots.BurstPreview.Interphoton_Threshold_ch2.Visible = 'on';
            h.Plots.BurstPreview.Interphoton_Threshold_ch2.Color = channel_colors(2,:);%[0.8 0 0];
            h.Plots.BurstPreview.Interphoton_Threshold_ch2.XData = PamMeta.Burst.Preview.x;
            if SmoothingMethod == 1 %%% take the inverse of the mean countrate
                h.Plots.BurstPreview.Interphoton_Threshold_ch2.YData = (T/M(2))*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 2
                h.Plots.BurstPreview.Interphoton_Threshold_ch2.YData = M(2)*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif any(SmoothingMethod == [3,4]) %%% take the inverse of the mean countrate
                h.Plots.BurstPreview.Interphoton_Threshold_ch2.YData = (1/M(2))*1000*ones(1,numel(PamMeta.Burst.Preview.x));
            end
            h.Plots.BurstPreview.Interphoton_Threshold_ch3.Visible = 'on';
            h.Plots.BurstPreview.Interphoton_Threshold_ch3.Color = channel_colors(3,:);%[0 0 0.8];
            h.Plots.BurstPreview.Interphoton_Threshold_ch3.XData = PamMeta.Burst.Preview.x;
            if SmoothingMethod == 1 %%% take the inverse of the estimated countrate
                h.Plots.BurstPreview.Interphoton_Threshold_ch3.YData = (T/M(3))*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif SmoothingMethod == 2
                h.Plots.BurstPreview.Interphoton_Threshold_ch3.YData = M(3)*ones(1,numel(PamMeta.Burst.Preview.x));
            elseif any(SmoothingMethod == [3,4]) %%% take the inverse of the mean countrate
                h.Plots.BurstPreview.Interphoton_Threshold_ch3.YData = (1/M(3))*1000*ones(1,numel(PamMeta.Burst.Preview.x));
            end
    end
    
    %% plot selected regions
    region_plot = true;
    if region_plot
        %%% use area plot
        facealpha = 0.2;
        % special case for DCBS burst searches using "OR (no merge)", "OR (merge)" or "XOR"
        if ~(any(BAMethod == [2,4,6]) && ~any(strcmp(DCBS_logical_gate,{'AND'}))) || BAMethod == 4 % last entry added because TCBS not properly implemented yet
            % APBS-type burst searches (or DCBS with AND or merge)
            % no distinction between colors is made
            
            % convert start/stop to photon arrival times (i.e. burst range)
            x = [];
            y = [];
            for i = 1:numel(start)
                x = [x,AllPhotons(start(i)),AllPhotons(start(i)),...
                    AllPhotons(stop(i)),AllPhotons(stop(i))];
                y = [y,0,1,1,0];
            end
            % intensity plot
            max_int = 1.1*max([max(ch1) max(ch2)])./bin_time_ms;
            if any(BAMethod == [3,4])
                max_int = max([max_int,max(ch3)./bin_time_ms]);
            end
            h.Plots.BurstPreview.SearchResult.Channel1 = area(h.Burst.Axes_Intensity,x*FileInfo.ClockPeriod,y*max_int,'EdgeColor','none','FaceAlpha',facealpha,'FaceColor','k');
            % interphoton time plot
            y = y*max(cellfun(@max,dt(~cellfun(@isempty,dt))));
            y(y==0) = 1;
            y = y*FileInfo.ClockPeriod*1E6;
            h.Plots.BurstPreview.SearchResult.Interphot = area(h.Burst.Axes_Interphot,x*FileInfo.ClockPeriod,y,'BaseValue',min(y),'EdgeColor','none','FaceAlpha',facealpha,'FaceColor','k');
        else
            % bursts detected in different channels are kept separate (i.e. not merged)
            % applies to DCBS "OR (no merge)" and "XOR"   
            % --> plot the different selections in different colors
            %
            % convert start/stop to photon arrival times (i.e. burst range)
            %colors = {[0,0,0],[0 0.8 0], [0.8 0 0]};
            channel_colors = [[0,0,0];channel_colors];
            for k = 0:2
                if sum(detected_channel==k) > 0
                    x = [];
                    y = [];
                    start_channel = start(detected_channel==k);
                    stop_channel = stop(detected_channel==k);
                    for i = 1:numel(start_channel)
                        x = [x,AllPhotons(start_channel(i)),AllPhotons(start_channel(i)),...
                            AllPhotons(stop_channel(i)),AllPhotons(stop_channel(i))];
                        y = [y,0,1,1,0];
                    end
                    % intensity plot                    
                    max_int = max([max(ch1) max(ch2)])./bin_time_ms;
                    if any(BAMethod == [3,4])
                        max_int = max([max_int,max(ch3)./bin_time_ms]);
                    end
                    h.Plots.BurstPreview.SearchResult.Channel1(k+1) = area(h.Burst.Axes_Intensity,x*FileInfo.ClockPeriod,y*max_int,'EdgeColor','none','FaceAlpha',facealpha,'FaceColor',channel_colors(k+1,:));
                    % interphoton time plot
                    y = y*max(cellfun(@max,dt(~cellfun(@isempty,dt))));
                    y(y==0) = 1;
                    y = y*FileInfo.ClockPeriod*1E6;
                    h.Plots.BurstPreview.SearchResult.Interphot(k+1) = area(h.Burst.Axes_Interphot,x*FileInfo.ClockPeriod,y,'BaseValue',min(y),'EdgeColor','none','FaceAlpha',facealpha,'FaceColor',channel_colors(k+1,:));
                end
            end
        end
    else % old way of plotting as circles in the binned data
       % disadvantage: burst starts/stops are coarsened to the bin time
       %find first and last burst in second
        first = find(AllPhotons(start),1,'first');
        last = find(AllPhotons(stop),1,'last');

        x = cell(last-first+1,1);
        y1 = cell(last-first+1,1);
        y2 = cell(last-first+1,1);
        y3 = cell(last-first+1,1);
        for i=first:last
            x{i} = PamMeta.Burst.Preview.x(starttime(i):stoptime(i));
            y1{i} = ch1(starttime(i):stoptime(i));
            y2{i} = ch2(starttime(i):stoptime(i));
            if any(BAMethod == [3 4])
                y3{i} = ch3(starttime(i):stoptime(i));
            end
        end
        x = horzcat(x{:});
        y1 = horzcat(y1{:});
        y2 = horzcat(y2{:});
        h.Plots.BurstPreview.SearchResult.Channel1 = plot(h.Burst.Axes_Intensity, x,y1,'og');
        h.Plots.BurstPreview.SearchResult.Channel2 = plot(h.Burst.Axes_Intensity, x,y2,'or');
        if any(BAMethod == [3,4])
            y3 = horzcat(y3{:});
            h.Plots.BurstPreview.SearchResult.Channel3 = plot(h.Burst.Axes_Intensity, x,y3,'ob');
        end
        
        %%% Color selected regions in Interphoton time plot
        x = cell(numel(start),1);
        y = cell(numel(start),1);
        for i=1:numel(start)
            x{i} = AllPhotons(start(i):stop(i)).*FileInfo.ClockPeriod;
            y{i} = dT_f(start(i):stop(i)).*FileInfo.ClockPeriod*1E6;
        end
        h.Plots.BurstPreview.SearchResult.Interphot = plot(h.Burst.Axes_Interphot, vertcat(x{:}),vertcat(y{:}),'.r');
    end
    
    h.Burst.Axes_Interphot.YLimMode = 'auto';
    axis(h.Burst.Axes_Interphot,'tight');
    h.Burst.Axes_Interphot.XLim = [0 1];
    %%% Update the x-axis limits of Burst_Axes
    h.Burst.Axes_Intensity.XLim = [PamMeta.Burst.Preview.Second  PamMeta.Burst.Preview.Second+1];
    h.Burst.Axes_Interphot.XLim = [PamMeta.Burst.Preview.Second  PamMeta.Burst.Preview.Second+1];
    %%% store the maximum intensity
    PamMeta.Burst.Preview.max_int = max_int;
    %%% flip order to put area plots behind lines
    for i = 1:numel(h.Burst.Axes_Intensity.Children)
        if strcmp(h.Burst.Axes_Intensity.Children(i).Type,'area')
            % move to the bottom
            uistack(h.Burst.Axes_Intensity.Children(i),'bottom');
        end
    end
    for i = 1:numel(h.Burst.Axes_Interphot.Children)
        if strcmp(h.Burst.Axes_Interphot.Children(i).Type,'area')
            % move to the bottom
            uistack(h.Burst.Axes_Interphot.Children(i),'bottom');
        end
    end
    %%% enable slider
    h.Burst.BurstSearchPreview_Slider.Enable = 'on';
    h.Burst.BurstSearchPreview_Slider.Min = 0;
    h.Burst.BurstSearchPreview_Slider.Max = min([ChunkSize*60,ceil(FileInfo.MeasurementTime)])-1;
    h.Burst.BurstSearchPreview_Slider.Value = min([PamMeta.Burst.Preview.Second, h.Burst.BurstSearchPreview_Slider.Max]);
    h.Burst.BurstSearchPreview_Slider.SliderStep = [1,10]./max([1,h.Burst.BurstSearchPreview_Slider.Max]);
    PamMeta.Burst.Preview.Second = h.Burst.BurstSearchPreview_Slider.Value;
else %%% < or > was pressed
    obj.Value = floor(obj.Value);
    PamMeta.Burst.Preview.Second = obj.Value;
    %%% Update the x-axis limits of Burst_Axes
    h.Burst.Axes_Intensity.XLim = [PamMeta.Burst.Preview.Second  PamMeta.Burst.Preview.Second+1];
    h.Burst.Axes_Interphot.XLim = [PamMeta.Burst.Preview.Second  PamMeta.Burst.Preview.Second+1];
end
%%% set YLimits
h.Burst.Axes_Intensity.YLim(1) = 0;
c = h.Burst.Axes_Intensity.Children(strcmp(get(h.Burst.Axes_Intensity.Children,'Type'),'line'));
ylim2 = 0;
for i = 1:numel(c)
    ylim2 = max([ylim2,...
        max(c(i).YData(c(i).XData >= PamMeta.Burst.Preview.Second & c(i).XData <= PamMeta.Burst.Preview.Second+1))]);
end
h.Burst.Axes_Intensity.YLim(2) = 1.1*ylim2;
h.Burst.Axes_Interphot.YLimMode = 'auto';
% h.Burst.Axes_Interphot.YLim(1) = 0.9*min(h.Plots.BurstPreview.Channel1_Interphot.YData(h.Plots.BurstPreview.Channel1_Interphot.XData >= PamMeta.Burst.Preview.Second & h.Plots.BurstPreview.Channel1_Interphot.XData <= PamMeta.Burst.Preview.Second+1));
% h.Burst.Axes_Interphot.YLim(2) = 1.1*max(h.Plots .BurstPreview.Channel1_Interphot.YData(h.Plots.BurstPreview.Channel1_Interphot.XData >= PamMeta.Burst.Preview.Second & h.Plots.BurstPreview.Channel1_Interphot.XData <= PamMeta.Burst.Preview.Second+1));
if h.Burst.Axes_Intensity.YLim(2) > PamMeta.Burst.Preview.max_int % set to maximum intensity
    h.Burst.Axes_Intensity.YLim(2) = PamMeta.Burst.Preview.max_int;
end
if h.Burst.Axes_Interphot.YLim(1) < FileInfo.ClockPeriod*1E6  % set to minimum interphoton time
    h.Burst.Axes_Interphot.YLim(1) = FileInfo.ClockPeriod*1E6;
end
guidata(h.Pam,h);
%%% Update Display
Update_Display([],[],1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Smoothes interphoton time trace with Lee filter, used in Burst Preview %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dT_f, dT] = smooth_interphoton_time_trace(Photons,m)
if isempty(Photons)
    dT_f = [];
    dT = [];
    return;
end
% Smooth the interphoton time trace
dT =[Photons(1);diff(Photons)];
dT_m = zeros(size(dT,1),size(dT,2));
dT_s = zeros(size(dT,1),size(dT,2));
% Apply Lee Filter with window 2m+1
sig_0 = std(dT); %%% constant filter parameter is the noise variance, set to standard devitation of interphoton time
dT_cumsum = cumsum(dT);
dT_cumsum = [0; dT_cumsum];
for i = m+1:numel(dT)-m
    dT_m(i) = (2*m+1)^(-1)*(dT_cumsum(i+m+1)-dT_cumsum(i-m));
end
dT_sq_cumsum = cumsum((dT-dT_m).^2);
dT_sq_cumsum = [0;dT_sq_cumsum];
for i = 2*m:numel(dT)-2*m
    dT_s(i) = (2*m+1)^(-1)*(dT_sq_cumsum(i+m+1)-dT_sq_cumsum(i-m));
end

%filtered data
dT_f = dT_m + (dT-dT_m).*dT_s./(dT_s+sig_0.^2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function grouping operations concerning the IRF or Scatter pattern %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SaveLoadIrfScat(obj,~)
global UserValues PamMeta TcspcData FileInfo
h = guidata(findobj('Tag','Pam'));

switch obj
    case h.Menu.SaveIrf
        % Saves the current measurement as IRF pattern
        if strcmp(FileInfo.FileName{1},'Nothing loaded')
            errordlg('Load a measurement first!','No measurement loaded...');
            return;
        end
        h.Progress.Text.String = 'Saving IRF';
        h.Progress.Axes.Color=[1 0 0];
        %%% Update the IRF for ALL PIE channel
        for i=1:numel(UserValues.PIE.Name)
            if isempty(UserValues.PIE.Combined{i})
                det = find( (UserValues.Detector.Det == UserValues.PIE.Detector(i)) & (UserValues.Detector.Rout == UserValues.PIE.Router(i)) );
                UserValues.PIE.IRF{i} = PamMeta.MI_Hist{det(1)}';
                %UserValues.PIE.IRF{i} = (histc( TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}, 1:FileInfo.MI_Bins))';
            end
        end
        h.MI.IRF.Checked = 'on';
        UserValues.Settings.Pam.PlotIRF = 'on';
        LSUserValues(1);
        Update_Display([],[],8)
        h.Progress.Text.String = FileInfo.FileName{1};
        h.Progress.Axes.Color = UserValues.Look.Control;
    case h.PIE.IRF
        % Saves the current PIE channel as IRF pattern
        if strcmp(FileInfo.FileName{1},'Nothing loaded')
            errordlg('Load a measurement first!','No measurement loaded...');
            return;
        end
        h.Progress.Text.String = 'Saving IRF';
        h.Progress.Axes.Color=[1 0 0];
        %%% Find selected channels
        Sel=h.PIE.List.Value;
        for i = 1:numel(Sel)
            if isempty(UserValues.PIE.Combined{Sel(i)})
                %%% Update IRF of selected channel
                det = find( (UserValues.Detector.Det == UserValues.PIE.Detector(Sel(i))) & (UserValues.Detector.Rout == UserValues.PIE.Router(Sel(i))) );
                UserValues.PIE.IRF{Sel(i)} = PamMeta.MI_Hist{det(1)}';
                %UserValues.PIE.IRF{Sel} = (histc( TcspcData.MI{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}, 1:FileInfo.MI_Bins))';
            else
                uiwait(msgbox('IRF cannot be saved for combined channels!', 'Important', 'modal'))
                return
            end
        end
        h.MI.IRF.Checked = 'on';
        UserValues.Settings.Pam.PlotIRF = 'on';
        LSUserValues(1);
        Update_Display([],[],8)
        h.Progress.Text.String = FileInfo.FileName{1};
        h.Progress.Axes.Color = UserValues.Look.Control;
    case h.PIE.PhasorReference
        % Saves the current PIE channel as IRF pattern
        if strcmp(FileInfo.FileName{1},'Nothing loaded')
            errordlg('Load a measurement first!','No measurement loaded...');
            return;
        end
        h.Progress.Text.String = 'Saving Phasore Reference';
        h.Progress.Axes.Color=[1 0 0];
        %%% Find selected channels
        Sel=h.PIE.List.Value;
        %%% ask for the lifetime of the reference
        lt = inputdlg('Lifetime of Reference [ns]:','Phasor Referencing',1,{num2str(UserValues.PIE.PhasorReferenceLifetime(Sel(1)))});
        if isempty(lt)
            errordlg('No reference lifetime given.');
            return;
        end
        lt = str2num(lt{1});
        if ~isfinite(lt)
            errordlg('Invalid reference lifetime given.');
            return;
        end
        
        for i = 1:numel(Sel)
            if isempty(UserValues.PIE.Combined{Sel(i)})
                %%% Update Phasor Reference of selected channel
                det = find( (UserValues.Detector.Det == UserValues.PIE.Detector(Sel(i))) & (UserValues.Detector.Rout == UserValues.PIE.Router(Sel(i))) );
                UserValues.PIE.PhasorReference{Sel(i)} = PamMeta.MI_Hist{det(1)}';
                UserValues.PIE.PhasorReferenceLifetime(Sel(i)) = lt;
            else
                uiwait(msgbox('Phasor Reference cannot be saved for combined channels!', 'Important', 'modal'))
                return
            end
        end
        LSUserValues(1);
        h.Progress.Text.String = FileInfo.FileName{1};
        h.Progress.Axes.Color = UserValues.Look.Control;
    case h.PIE.DonorOnlyReference
        % Saves the current PIE channel as IRF pattern
        if strcmp(FileInfo.FileName{1},'Nothing loaded')
            errordlg('Load a measurement first!','No measurement loaded...');
            return;
        end
        h.Progress.Text.String = 'Saving Donor-Only Reference';
        h.Progress.Axes.Color=[1 0 0];
        %%% Find selected channels
        Sel=h.PIE.List.Value;       
        for i = 1:numel(Sel)
            if isempty(UserValues.PIE.Combined{Sel(i)})
                %%% Update Donor-Only reference of selected channel
                det = find( (UserValues.Detector.Det == UserValues.PIE.Detector(Sel(i))) & (UserValues.Detector.Rout == UserValues.PIE.Router(Sel(i))) );
                UserValues.PIE.DonorOnlyReference{Sel(i)} = PamMeta.MI_Hist{det(1)}';
            else
                uiwait(msgbox('Donor-Only Reference cannot be saved for combined channels!', 'Important', 'modal'))
                return
            end
        end
        LSUserValues(1);
        h.Progress.Text.String = FileInfo.FileName{1};
        h.Progress.Axes.Color = UserValues.Look.Control;
    case h.Menu.SaveScatter
        if strcmp(FileInfo.FileName{1},'Nothing loaded')
            errordlg('Load a measurement first!','No measurement loaded...');
            return;
        end
        %%% Saves the current measurement as Scatter pattern %%%%%%%%%%%%%%%%%%%%%%
        h.Progress.Text.String = 'Saving Scatter/Background';
        h.Progress.Axes.Color=[1 0 0];
        for i=1:numel(UserValues.PIE.Name)
            if isempty(UserValues.PIE.Combined{i})
                det = find( (UserValues.Detector.Det == UserValues.PIE.Detector(i)) & (UserValues.Detector.Rout == UserValues.PIE.Router(i)) );
                UserValues.PIE.ScatterPattern{i} = PamMeta.MI_Hist{det(1)}';
                %UserValues.PIE.ScatterPattern{i} = (histc( TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}, 1:FileInfo.MI_Bins))';
            end
        end
        
        %%% Store Background Counts in PIE subfield of UserValues structure (PIE.Background) in kHz
        for i=1:numel(UserValues.PIE.Name)
            if isempty(UserValues.PIE.Combined{i})
                UserValues.PIE.Background(i) = PamMeta.Info{i}(4);
            end
        end
        h.MI.ScatterPattern.Checked = 'on';
        UserValues.Settings.Pam.PlotScat = 'on';
        LSUserValues(1);
        Update_Display([],[],[1,8])
        h.SaveScatter_Button.ForegroundColor = [0 1 0];
        h.Progress.Text.String = FileInfo.FileName{1};
        h.Progress.Axes.Color = UserValues.Look.Control;
    case h.Menu.SaveIrfFile
        % Save IRF to .irf file
        [File, Path] = uiputfile([datestr(now,'yymmdd') '_irf.irf'], 'Save IRF', UserValues.File.Path);
        if all(File==0)
            return
        end
        s = struct;
        s.data = UserValues.PIE.IRF;
        s.name = UserValues.PIE.Name;
        save(fullfile(Path,File),'s');
    case h.Menu.SaveScatterFile
        % Save Scatter Pattern and Backgrond counts to .scat file
        [File, Path] = uiputfile([datestr(now,'yymmdd') '_scatter.scat'], 'Save Scatter Pattern', UserValues.File.Path);
        if all(File==0)
            return
        end
        s = struct;
        s.data = UserValues.PIE.ScatterPattern;
        s.data2 = UserValues.PIE.Background;
        s.name = UserValues.PIE.Name;
        save(fullfile(Path,File),'s');
    case h.Menu.LoadIrf
        % Load IRF from .irf file
        [FileName, Path] = uigetfile('*.irf', 'Choose IRF file',UserValues.File.Path,'MultiSelect', 'off');
        if all(FileName==0)
            return
        end
        load('-mat',fullfile(Path,FileName));
        mess = 'IRF of PIE channel(s) ';
        err = 0;
        for i = 1:numel(s.data)
            if strcmp(UserValues.PIE.Name{i}, s.name{i})
                UserValues.PIE.IRF{i} = s.data{i};
            else
                err = 1;
                mess = [mess num2str(i) ', '];
            end
        end
        if err
            msgbox([mess(1:end-2) ' not loaded because its name differed between current profile and loaded file.'])
        end
        clear s;
        h.MI.IRF.Checked = 'on';
        UserValues.Settings.Pam.PlotIRF = 'on';
        LSUserValues(1);
        Update_Display([],[],8)
    case h.Menu.LoadScatter
        % Load Scatter Pattern and Background counts from .scat file
        [FileName, Path] = uigetfile('*.scat', 'Choose Scatter Pattern',UserValues.File.Path,'MultiSelect', 'off');
        if all(FileName==0)
            return
        end
        load('-mat',fullfile(Path,FileName));
        mess = 'Scatter Pattern of PIE channel(s) ';
        err = 0;
        for i = 1:numel(s.data)
            if strcmp(UserValues.PIE.Name{i}, s.name{i})
                UserValues.PIE.ScatterPattern{i} = s.data{i};
                UserValues.PIE.Background(i) = s.data2(i);
            else
                err = 1;
                mess = [mess num2str(i) ', '];
            end
        end
        if err
            msgbox([mess(1:end-2) ' not loaded because its name differed between current profile and loaded file.'])
        end
        clear s;
        % test whether all is ok
        h.MI.ScatterPattern.Checked = 'on';
        UserValues.Settings.Pam.PlotScat = 'on';
        LSUserValues(1);
        Update_Display([],[],[1,8])
        h.SaveScatter_Button.ForegroundColor = [0 1 0];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function grouping operations concerning the Detector shift %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SaveLoadShift(obj,~)
global UserValues
h = guidata(findobj('Tag','Pam'));

switch obj
    case h.Menu.SaveShiftFile
        % Save the detector Shift to .sh file
        [File, Path] = uiputfile([datestr(now,'yymmdd') '_detectorshift.sh'], 'Save Detector Shifts', UserValues.File.Path);
        if all(File==0)
            return
        end
        
        shifts = cell(numel(UserValues.Detector.Det),1);
        shifts(1:numel(UserValues.Detector.Shift)) = UserValues.Detector.Shift;
        det = UserValues.Detector.Det;
        rout = UserValues.Detector.Rout;
        name = UserValues.Detector.Name;
        save(fullfile(Path,File),'shifts','det','rout','name');
        % old
        %s = struct;
        %s.data = UserValues.Detector.Shift;
        %s.name = UserValues.Detector.Name;
        %save(fullfile(Path,File),'s');
    case h.Menu.LoadShift
        % Load detector shifts from .sh file
        [FileName, Path] = uigetfile('*.sh', 'Choose Detector Shift file',UserValues.File.Path,'MultiSelect', 'off');
        if all(FileName==0)
            return
        end
        data = load('-mat',fullfile(Path,FileName));
        if isfield(data,'s') % legacy mode
            s = data.s;
            if size(UserValues.Detector.Name,2) ~= numel(s.data);
                disp('The number of detectors in the shift file is not the same as in your current profile!')
                disp(' ')
            end
            disp('Check whether everything is assigned correctly:')
            disp(' ')
            for i = 1:numel(s.data)
                % just loop through the number of detectors in the shift file
                if i <= size(UserValues.Detector.Name,2)
                    UserValues.Detector.Shift{i} = s.data{i};
                    disp(['Shift of detector "' s.name{i} '" from file copied to detector "' UserValues.Detector.Name{i} '" in your current profile!'])
                end
            end
        else
            for i = 1:numel(data.shifts)
                if ~isempty(data.shifts{i})
                    for j = 1:numel(UserValues.Detector.Det)
                        if (data.det(i) == UserValues.Detector.Det(j)) && (data.rout(i) == UserValues.Detector.Rout(j))
                            UserValues.Detector.Shift(j) = data.shifts(i);
                            disp(['Shift of detector "' data.name{i} '" from file copied to detector "' UserValues.Detector.Name{j} '" in your current profile!'])
                        end
                    end
                end
            end
        end
        disp(' ')
        disp('Load data again to apply changes!')
        LSUserValues(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Prepare Data for Burstwise Lifetime fitting in TauFit %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BurstLifetime(obj,~)
% Close existing TauFit because it might have been called from somewhere else
delete(findobj('Tag','TauFit'));
clear global TauFitData
global UserValues TauFitData PamMeta
h = guidata(findobj('Tag','Pam'));
%%% get BurstData from PamMeta
BurstData = PamMeta.BurstData;
%%% Check if IRF and Scatter exists
if any(isempty(BurstData.IRF)) || any(isempty(BurstData.ScatterPattern))
    warndlg('Define IRF and Scatter first.','No IRF found!');
    return;
end
%% Prepare the data for lifetime fitting
Progress(0,h.Progress.Axes,h.Progress.Text,'Loading Data for Lifetime Fit...');
%set(h.Pam, 'pointer', 'arrow'); drawnow;
%%% Load associated Macro- and Microtimes from *.bps file
[Path,File,~] = fileparts(BurstData.FileName);
if exist(fullfile(Path,[File '.bps']),'file') == 2
    %%% load if it exists
    TauFitData = load(fullfile(Path,[File '.bps']),'-mat');
    TauFitData.FileName = BurstData.FileName;
else
    %%% else ask for the file
    [FileName,PathName] = uigetfile({'*.bps'}, 'Choose the associated *.bps file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');
    if FileName == 0
        return;
    end
    TauFitData = load('-mat',fullfile(PathName,FileName));
    %%% Store the correct Path in TauFitData
    TauFitData.FileName = fullfile(PathName,[FileName(1:end-3) 'bur']);
end
Progress(0.5,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
TauFitData = rmfield(TauFitData,'Macrotime');
%TauFitData.Microtime = Microtime;%cellfun(@double,Microtime,'UniformOutput',false);
%TauFitData.Channel = Channel;%cellfun(@double,Channel,'UniformOutput',false);
%%% Get total vector of microtime and channel
Microtime = vertcat(TauFitData.Microtime{:});
Channel = vertcat(TauFitData.Channel{:});
%%% Calculate the total Microtime Histogram per Color from all bursts
switch BurstData.BAMethod
    case {1,2} %two color MFD
        %%% Read out the indices of the PIE channels
        idx_GGpar = 1;
        idx_GGperp = 2;
        idx_RRpar = 5;
        idx_RRperp = 6;
        
        max_MIBins_GGpar = min([numel(BurstData.IRF{idx_GGpar}) numel(BurstData.ScatterPattern{idx_GGpar})]);
        max_MIBins_GGperp = min([numel(BurstData.IRF{idx_GGperp}) numel(BurstData.ScatterPattern{idx_GGperp})]);
        max_MIBins_RRpar = min([numel(BurstData.IRF{idx_RRpar}) numel(BurstData.ScatterPattern{idx_RRpar})]);
        max_MIBins_RRperp = min([numel(BurstData.IRF{idx_RRperp}) numel(BurstData.ScatterPattern{idx_RRperp})]);
        
        %%% Calculate and store Histograms in TauFitData
        TauFitData.hMI_Par{1} = histc(Microtime(Channel == 1), (BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GGpar])));
        Progress(0.6,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
        TauFitData.hMI_Per{1} = histc(Microtime(Channel == 2), (BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_GGperp])));
        Progress(0.7,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
        TauFitData.hMI_Par{2} = histc(Microtime(Channel == 5), (BurstData.PIE.From(5):min([BurstData.PIE.To(5) max_MIBins_RRpar])));
        Progress(0.8,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
        TauFitData.hMI_Per{2} = histc(Microtime(Channel == 6), (BurstData.PIE.From(6):min([BurstData.PIE.To(6) max_MIBins_RRperp])));
        Progress(0.9,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
        %%% Read out the Microtime Histograms of the IRF for the two channels
        TauFitData.hIRF_Par{1} = BurstData.IRF{idx_GGpar}((BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GGpar])));
        TauFitData.hIRF_Par{2} = BurstData.IRF{idx_RRpar}((BurstData.PIE.From(5):min([BurstData.PIE.To(5) max_MIBins_RRpar])));
        TauFitData.hIRF_Per{1} = BurstData.IRF{idx_GGperp}((BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_GGperp])));
        TauFitData.hIRF_Per{2} = BurstData.IRF{idx_RRperp}((BurstData.PIE.From(6):min([BurstData.PIE.To(6) max_MIBins_RRperp])));
        %%% Normalize IRF for better Visibility
        for i = 1:2
            TauFitData.hIRF_Par{i} = (TauFitData.hIRF_Par{i}./max(TauFitData.hIRF_Par{i})).*max(TauFitData.hMI_Par{i});
            TauFitData.hIRF_Per{i} = (TauFitData.hIRF_Per{i}./max(TauFitData.hIRF_Per{i})).*max(TauFitData.hMI_Per{i});
        end
        
        %%% Read out the Microtime Histograms of the Scatter for the two channels
        TauFitData.hScat_Par{1} = BurstData.ScatterPattern{idx_GGpar}((BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GGpar])));
        TauFitData.hScat_Par{2} = BurstData.ScatterPattern{idx_RRpar}((BurstData.PIE.From(5):min([BurstData.PIE.To(5) max_MIBins_RRpar])));
        TauFitData.hScat_Per{1} = BurstData.ScatterPattern{idx_GGperp}((BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_GGperp])));
        TauFitData.hScat_Per{2} = BurstData.ScatterPattern{idx_RRperp}((BurstData.PIE.From(6):min([BurstData.PIE.To(6) max_MIBins_RRperp])));
        %%% Normalize Scatter Pattern for better Visibility
        for i = 1:2
            TauFitData.hScat_Par{i} = (TauFitData.hScat_Par{i}./max(TauFitData.hScat_Par{i})).*max(TauFitData.hMI_Par{i});
            TauFitData.hScat_Per{i} = (TauFitData.hScat_Per{i}./max(TauFitData.hScat_Per{i})).*max(TauFitData.hMI_Per{i});
        end
        
        %%% Read Out the Phasor Reference
        TauFitData.PhasorReference_Par = cell(2); TauFitData.PhasorReference_Per = cell(2);
        if isfield(BurstData,'Phasor') && isfield(BurstData.Phasor,'PhasorReference')
            try
                TauFitData.PhasorReference_Par{1} = BurstData.Phasor.PhasorReference{idx_GGpar}((BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GGpar])));
                TauFitData.PhasorReference_Par{2} = BurstData.Phasor.PhasorReference{idx_RRpar}((BurstData.PIE.From(5):min([BurstData.PIE.To(5) max_MIBins_RRpar])));
                TauFitData.PhasorReference_Per{1} = BurstData.Phasor.PhasorReference{idx_GGperp}((BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_GGperp])));
                TauFitData.PhasorReference_Per{2} = BurstData.Phasor.PhasorReference{idx_RRperp}((BurstData.PIE.From(6):min([BurstData.PIE.To(6) max_MIBins_RRperp])));
            end
        end
        
        TauFitData.PhasorReferenceLifetime = zeros(2,1);
        if isfield(BurstData,'Phasor') && isfield(BurstData.Phasor,'PhasorReferenceLifetime')
            try
                TauFitData.PhasorReferenceLifetime(1) = mean(BurstData.Phasor.PhasorReferenceLifetime([idx_GGpar,idx_GGperp]));
                TauFitData.PhasorReferenceLifetime(2) = mean(BurstData.Phasor.PhasorReferenceLifetime([idx_RRpar,idx_RRperp]));
            end
        end
        
        %%% Read Out the Donor-Only Reference
        TauFitData.DonorOnlyReference_Par = cell(1); TauFitData.DonorOnlyReference_Per = cell(1);
        try
            TauFitData.DonorOnlyReference_Par{1} = BurstData.DonorOnlyReference{idx_GGpar}((BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GGpar])));
            TauFitData.DonorOnlyReference_Per{1} = BurstData.DonorOnlyReference{idx_GGperp}((BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_GGperp])));
        end
        
        %%% Generate XData
        TauFitData.XData_Par{1} = (BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GGpar])) - BurstData.PIE.From(1);
        TauFitData.XData_Per{1} = (BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_GGperp])) - BurstData.PIE.From(2);
        TauFitData.XData_Par{2} = (BurstData.PIE.From(5):min([BurstData.PIE.To(5) max_MIBins_RRpar])) - BurstData.PIE.From(5);
        TauFitData.XData_Per{2} = (BurstData.PIE.From(6):min([BurstData.PIE.To(6) max_MIBins_RRperp])) - BurstData.PIE.From(6);
    case {3,4} %%% Three-color MFD
        %%% Read out the indices of the PIE channels
        idx_BBpar = 1;
        idx_BBperp = 2;
        idx_GGpar = 7;
        idx_GGperp = 8;
        idx_RRpar = 11;
        idx_RRperp = 12;
        
        max_MIBins_BBpar = min([numel(BurstData.IRF{idx_BBpar}) numel(BurstData.ScatterPattern{idx_BBpar})]);
        max_MIBins_BBperp = min([numel(BurstData.IRF{idx_BBperp}) numel(BurstData.ScatterPattern{idx_BBperp})]);
        max_MIBins_GGpar = min([numel(BurstData.IRF{idx_GGpar}) numel(BurstData.ScatterPattern{idx_GGpar})]);
        max_MIBins_GGperp = min([numel(BurstData.IRF{idx_GGperp}) numel(BurstData.ScatterPattern{idx_GGperp})]);
        max_MIBins_RRpar = min([numel(BurstData.IRF{idx_RRpar}) numel(BurstData.ScatterPattern{idx_RRpar})]);
        max_MIBins_RRperp = min([numel(BurstData.IRF{idx_RRperp}) numel(BurstData.ScatterPattern{idx_RRperp})]);
        
        %%% Calculate and store MI Histograms in TauFitData
        TauFitData.hMI_Par{1} = histc(Microtime(Channel == 1), (BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_BBpar])));
        Progress(0.57,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
        TauFitData.hMI_Per{1} = histc(Microtime(Channel == 2), (BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_BBperp])));
        Progress(0.64,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
        TauFitData.hMI_Par{2} = histc(Microtime(Channel == 7), (BurstData.PIE.From(7):min([BurstData.PIE.To(7) max_MIBins_GGpar])));
        Progress(0.71,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
        TauFitData.hMI_Per{2} = histc(Microtime(Channel == 8), (BurstData.PIE.From(8):min([BurstData.PIE.To(8) max_MIBins_GGperp])));
        Progress(0.78,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
        TauFitData.hMI_Par{3} = histc(Microtime(Channel == 11), (BurstData.PIE.From(11):min([BurstData.PIE.To(11) max_MIBins_RRpar])));
        Progress(0.85,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
        TauFitData.hMI_Per{3} = histc(Microtime(Channel == 12), (BurstData.PIE.From(12):min([BurstData.PIE.To(12) max_MIBins_RRperp])));
        Progress(0.92,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
        %%% Read out the Microtime Histograms of the IRF for the two channels
        TauFitData.hIRF_Par{1} = BurstData.IRF{idx_BBpar}(BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_BBpar]));
        TauFitData.hIRF_Par{2} = BurstData.IRF{idx_GGpar}(BurstData.PIE.From(7):min([BurstData.PIE.To(7) max_MIBins_GGpar]));
        TauFitData.hIRF_Par{3} = BurstData.IRF{idx_RRpar}(BurstData.PIE.From(11):min([BurstData.PIE.To(11) max_MIBins_RRpar]));
        TauFitData.hIRF_Per{1} = BurstData.IRF{idx_BBperp}(BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_BBperp]));
        TauFitData.hIRF_Per{2} = BurstData.IRF{idx_GGperp}(BurstData.PIE.From(8):min([BurstData.PIE.To(8) max_MIBins_GGperp]));
        TauFitData.hIRF_Per{3} = BurstData.IRF{idx_RRperp}(BurstData.PIE.From(12):min([BurstData.PIE.To(12) max_MIBins_RRperp]));
        %%% Normalize IRF for better Visibility
        for i = 1:3
            TauFitData.hIRF_Par{i} = (TauFitData.hIRF_Par{i}./max(TauFitData.hIRF_Par{i})).*max(TauFitData.hMI_Par{i});
            TauFitData.hIRF_Per{i} = (TauFitData.hIRF_Per{i}./max(TauFitData.hIRF_Per{i})).*max(TauFitData.hMI_Per{i});
        end
        
        %%% Read out the Microtime Histograms of the Scatter Pattern for the two channels
        TauFitData.hScat_Par{1} = BurstData.ScatterPattern{idx_BBpar}(BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_BBpar]));
        TauFitData.hScat_Par{2} = BurstData.ScatterPattern{idx_GGpar}(BurstData.PIE.From(7):min([BurstData.PIE.To(7) max_MIBins_GGpar]));
        TauFitData.hScat_Par{3} = BurstData.ScatterPattern{idx_RRpar}(BurstData.PIE.From(11):min([BurstData.PIE.To(11) max_MIBins_RRpar]));
        TauFitData.hScat_Per{1} = BurstData.ScatterPattern{idx_BBperp}(BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_BBperp]));
        TauFitData.hScat_Per{2} = BurstData.ScatterPattern{idx_GGperp}(BurstData.PIE.From(8):min([BurstData.PIE.To(8) max_MIBins_GGperp]));
        TauFitData.hScat_Per{3} = BurstData.ScatterPattern{idx_RRperp}(BurstData.PIE.From(12):min([BurstData.PIE.To(12) max_MIBins_RRperp]));
        %%% Normalize Scatter pattern for better Visibility
        for i = 1:3
            TauFitData.hScat_Par{i} = (TauFitData.hScat_Par{i}./max(TauFitData.hScat_Par{i})).*max(TauFitData.hMI_Par{i});
            TauFitData.hScat_Per{i} = (TauFitData.hScat_Per{i}./max(TauFitData.hScat_Per{i})).*max(TauFitData.hMI_Per{i});
        end
        
        %%% Generate XData
        TauFitData.XData_Par{1} = (BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_BBpar])) - BurstData.PIE.From(1);
        TauFitData.XData_Per{1} = (BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_BBperp])) - BurstData.PIE.From(2);
        TauFitData.XData_Par{2} = (BurstData.PIE.From(7):min([BurstData.PIE.To(7) max_MIBins_GGpar])) - BurstData.PIE.From(7);
        TauFitData.XData_Per{2} = (BurstData.PIE.From(8):min([BurstData.PIE.To(8) max_MIBins_GGperp])) - BurstData.PIE.From(8);
        TauFitData.XData_Par{3} = (BurstData.PIE.From(11):min([BurstData.PIE.To(11) max_MIBins_RRpar])) - BurstData.PIE.From(11);
        TauFitData.XData_Per{3} = (BurstData.PIE.From(12):min([BurstData.PIE.To(12) max_MIBins_RRperp])) - BurstData.PIE.From(12);
    case {5,6} %noMFD
        %%% Read out the indices of the PIE channels
        idx_GG = 1;
        idx_RR = 3;
        
        max_MIBins_GG = min([numel(BurstData.IRF{idx_GG}) numel(BurstData.ScatterPattern{idx_GG})]);
        max_MIBins_RR = min([numel(BurstData.IRF{idx_RR}) numel(BurstData.ScatterPattern{idx_RR})]);
        
        %%% Calculate and store Histograms in TauFitData
        TauFitData.hMI_Par{1} = histc(Microtime(Channel == 1), (BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GG])));
        Progress(0.7,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
        TauFitData.hMI_Par{2} = histc(Microtime(Channel == 3), (BurstData.PIE.From(3):min([BurstData.PIE.To(3) max_MIBins_RR])));
        Progress(0.9,h.Progress.Axes,h.Progress.Text,'Preparing Data for Lifetime Fit...');
        TauFitData.hMI_Per = TauFitData.hMI_Par;
        
        %%% Read out the Microtime Histograms of the IRF for the two channels
        TauFitData.hIRF_Par{1} = BurstData.IRF{idx_GG}((BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GG])));
        TauFitData.hIRF_Par{2} = BurstData.IRF{idx_RR}((BurstData.PIE.From(3):min([BurstData.PIE.To(3) max_MIBins_RR])));
        %%% Normalize IRF for better Visibility
        for i = 1:2
            TauFitData.hIRF_Par{i} = (TauFitData.hIRF_Par{i}./max(TauFitData.hIRF_Par{i})).*max(TauFitData.hMI_Par{i});
        end
        TauFitData.hIRF_Per = TauFitData.hIRF_Par;
        
        %%% Read out the Microtime Histograms of the Scatter for the two channels
        TauFitData.hScat_Par{1} = BurstData.ScatterPattern{idx_GG}((BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GG])));
        TauFitData.hScat_Par{2} = BurstData.ScatterPattern{idx_RR}((BurstData.PIE.From(3):min([BurstData.PIE.To(3) max_MIBins_RR])));
        %%% Normalize Scatter Pattern for better Visibility
        for i = 1:2
            TauFitData.hScat_Par{i} = (TauFitData.hScat_Par{i}./max(TauFitData.hScat_Par{i})).*max(TauFitData.hMI_Par{i});
        end
        TauFitData.hScat_Per = TauFitData.hScat_Par;
        
        %%% Generate XData
        TauFitData.XData_Par{1} = (BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GG])) - BurstData.PIE.From(1);
        TauFitData.XData_Par{2} = (BurstData.PIE.From(3):min([BurstData.PIE.To(3) max_MIBins_RR])) - BurstData.PIE.From(3);
        TauFitData.XData_Per = TauFitData.XData_Par;
end
%%% Read out relevant parameters
TauFitData.BAMethod = BurstData.BAMethod;
if BurstData.BAMethod == 6
    TauFitData.BAMethod = 5;
end
%TauFitData.ClockPeriod = BurstData.FileInfo.ClockPeriod;
TauFitData.TACRange = BurstData.FileInfo.TACRange; % in seconds
TauFitData.MI_Bins = double(BurstData.FileInfo.MI_Bins); %anders, why double?
if ~isfield(BurstData,'Resolution')
    % in nanoseconds/microtime bin
    TauFitData.TACChannelWidth = TauFitData.TACRange*1E9/TauFitData.MI_Bins;
elseif isfield(FileInfo,'Resolution') %%% HydraHarp Data
    TauFitData.TACChannelWidth = BurstData.Resolution/1000;
end
Progress(1,h.Progress.Axes,h.Progress.Text,'Fitting Lifetime in TauFit...');
TauFit(obj,[]);
Update_Display([],[],1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Store loaded IRF/Scatter Measurment in performed BurstSearch %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BurstData = Store_IRF_Scat_inBur(obj,e,mode)
global PamMeta UserValues FileInfo
LSUserValues(0);
h = guidata(findobj('Tag','Pam'));

if strcmp(obj,'nothing')
    % function is called during Burst Analysis, which means that
    % PamMeta.BurstData does not exist yet
    % instead, it was passed as second argument
    BurstData = e;
else
    % function is called from right clicking the Burstwise lifetime button
    h.Progress.Text.String = 'Saving changed MI pattern...';
    %%% get BurstData from PamMeta
    BurstData = PamMeta.BurstData;
end

if isempty(BurstData)
    disp('No Burst Data loaded...');
    return;
end

if any(mode==0)
    %% Save IRF (combine IRFS for combined channels)
    switch BurstData.BAMethod
        case {1,2}
            %%% Read out the Microtime Histograms of the IRF for the two channels
            % hIRF_GGpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
            % hIRF_GGperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2})};
            % hIRF_GRpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})};
            % hIRF_GRperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2})};
            % hIRF_RRpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})};
            % hIRF_RRperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2})};
            % BurstData.IRF = {hIRF_GGpar; hIRF_GGperp;...
            %     hIRF_GRpar; hIRF_GRperp;...
            %     hIRF_RRpar; hIRF_RRperp};

            %%% Read out the Microtime Histograms of the IRF for the two channels
            GGpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1}));
            GGperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2}));
            GRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1}));
            GRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2}));
            RRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1}));
            RRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2}));
            chan = [GGpar;GGperp;GRpar;GRperp;RRpar;RRperp];
            BurstData.IRF = cell(numel(chan),1);
            for i = 1:numel(chan)
                if isempty(UserValues.PIE.Combined{chan(i)}) %%% not a combined channel
                    BurstData.IRF{i} = UserValues.PIE.IRF{chan(i)};
                else %%% combine IRFs
                    PIEchannel = UserValues.PIE.Combined{chan(i)};
                    BurstData.IRF{i} =  UserValues.PIE.IRF{PIEchannel(1)};
                    for j = 2:numel(PIEchannel)
                        BurstData.IRF{i} = BurstData.IRF{i} + UserValues.PIE.IRF{PIEchannel(j)};
                    end
                end
            end
        case {3,4}
            %%% Read out the Microtime Histograms of the IRF for the two channels
            % hIRF_BBpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
            % hIRF_BBperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2})};
            % hIRF_BGpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})};
            % hIRF_BGperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2})};
            % hIRF_BRpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})};
            % hIRF_BRperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2})};
            % hIRF_GGpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,1})};
            % hIRF_GGperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,2})};
            % hIRF_GRpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,1})};
            % hIRF_GRperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,2})};
            % hIRF_RRpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,1})};
            % hIRF_RRperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,2})};
            % BurstData.IRF = {hIRF_BBpar; hIRF_BBperp;...
            %     hIRF_BGpar; hIRF_BGperp;...
            %     hIRF_BRpar; hIRF_BRperp;...
            %     hIRF_GGpar; hIRF_GGperp;...
            %     hIRF_GRpar; hIRF_GRperp;...
            %     hIRF_RRpar; hIRF_RRperp};
                
            %%% Read out the Microtime Histograms of the IRF for the two channels
            BBpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1}));
            BBperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2}));
            BGpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1}));
            BGperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2}));
            BRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1}));
            BRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2}));
            GGpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,1}));
            GGperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,2}));
            GRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,1}));
            GRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,2}));
            RRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,1}));
            RRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,2}));
            chan = [BBpar;BBperp;BGpar;BGperp;BRpar;BRperp;GGpar;GGperp;GRpar;GRperp;RRpar;RRperp];
            BurstData.IRF = cell(numel(chan),1);
            for i = 1:numel(chan)
                if isempty(UserValues.PIE.Combined{chan(i)}) %%% not a combined channel
                    BurstData.IRF{i} = UserValues.PIE.IRF{chan(i)};
                else %%% combine IRFs                        
                    PIEchannel = UserValues.PIE.Combined{chan(i)};
                    BurstData.IRF{i} =  UserValues.PIE.IRF{PIEchannel(1)};
                    for j = 2:numel(PIEchannel)
                        BurstData.IRF{i} = BurstData.IRF{i} + UserValues.PIE.IRF{PIEchannel(j)};
                    end
                end
            end
        case {5,6} %noMFD
            % hIRF_GG = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
            % hIRF_GR = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})};
            % hIRF_RR = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})};
            % BurstData.IRF = {hIRF_GG;...
            %     hIRF_GR;...
            %     hIRF_RR};

            %%% Read out the Microtime Histograms of the IRF for the two channels
            GG = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1}));
            GR = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1}));
            RR = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1}));                
            chan = [GG;GR;RR];
            BurstData.IRF = cell(numel(chan),1);
            for i = 1:numel(chan)
                if isempty(UserValues.PIE.Combined{chan(i)}) %%% not a combined channel
                    BurstData.IRF{i} = UserValues.PIE.IRF{chan(i)};
                else %%% combine IRFs
                    PIEchannel = UserValues.PIE.Combined{chan(i)};
                    BurstData.IRF{i} =  UserValues.PIE.IRF{PIEchannel(1)};
                    for j = 2:numel(PIEchannel)
                        BurstData.IRF{i} = BurstData.IRF{i} + UserValues.PIE.IRF{PIEchannel(j)};
                    end
                end
            end
    end
end
if any(mode==1)
    %% Save ScatterPattern, as well as background counts!
    switch BurstData.BAMethod
        case {1,2}
            % Scatter patterns for all burst channels
            % hScat_GGpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
            % hScat_GGperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2})};
            % hScat_GRpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})};
            % hScat_GRperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2})};
            % hScat_RRpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})};
            % hScat_RRperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2})};
            % BurstData.ScatterPattern = {hScat_GGpar; hScat_GGperp;...
            %     hScat_GRpar; hScat_GRperp;...
            %     hScat_RRpar; hScat_RRperp};

            %%% Read out the Microtime Histograms of the IRF for the two channels
            GGpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1}));
            GGperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2}));
            GRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1}));
            GRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2}));
            RRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1}));
            RRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2}));
            chan = [GGpar;GGperp;GRpar;GRperp;RRpar;RRperp];
            BurstData.ScatterPattern = cell(numel(chan),1);
            for i = 1:numel(chan)
                if isempty(UserValues.PIE.Combined{chan(i)}) %%% not a combined channel
                    BurstData.ScatterPattern{i} = UserValues.PIE.ScatterPattern{chan(i)};
                else %%% combine IRFs
                    PIEchannel = UserValues.PIE.Combined{chan(i)};
                    BurstData.ScatterPattern{i} =  UserValues.PIE.ScatterPattern{PIEchannel(1)};
                    for j = 2:numel(PIEchannel)
                        BurstData.ScatterPattern{i} = BurstData.ScatterPattern{i} + UserValues.PIE.ScatterPattern{PIEchannel(j)};
                    end
                end
            end
        case {3,4}
            % Scatter patterns for all burst channels
            % hScat_BBpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
            % hScat_BBperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2})};
            % hScat_BGpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})};
            % hScat_BGperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2})};
            % hScat_BRpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})};
            % hScat_BRperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2})};
            % hScat_GGpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,1})};
            % hScat_GGperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,2})};
            % hScat_GRpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,1})};
            % hScat_GRperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,2})};
            % hScat_RRpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,1})};
            % hScat_RRperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,2})};
            % BurstData.ScatterPattern = {hScat_BBpar; hScat_BBperp;...
            %     hScat_BGpar; hScat_BGperp;...
            %     hScat_BRpar; hScat_BRperp;...
            %     hScat_GGpar; hScat_GGperp;...
            %     hScat_GRpar; hScat_GRperp;...
            %     hScat_RRpar; hScat_RRperp};

            %%% Read out the Microtime Histograms of the IRF for the two channels
            BBpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1}));
            BBperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2}));
            BGpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1}));
            BGperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2}));
            BRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1}));
            BRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2}));
            GGpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,1}));
            GGperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,2}));
            GRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,1}));
            GRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,2}));
            RRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,1}));
            RRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,2}));
            chan = [BBpar;BBperp;BGpar;BGperp;BRpar;BRperp;GGpar;GGperp;GRpar;GRperp;RRpar;RRperp];
            BurstData.ScatterPattern = cell(numel(chan),1);
            for i = 1:numel(chan)
                if isempty(UserValues.PIE.Combined{chan(i)}) %%% not a combined channel
                    BurstData.ScatterPattern{i} = UserValues.PIE.ScatterPattern{chan(i)};
                else %%% combine IRFs
                    PIEchannel = UserValues.PIE.Combined{chan(i)};
                    BurstData.ScatterPattern{i} =  UserValues.PIE.ScatterPattern{PIEchannel(1)};
                    for j = 2:numel(PIEchannel)
                        BurstData.ScatterPattern{i} = BurstData.ScatterPattern{i} + UserValues.PIE.ScatterPattern{PIEchannel(j)};
                    end
                end
            end
        case {5,6} %noMFDtry
            % Scatter patterns for all burst channels
            % hScat_GG = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
            % hScat_GR = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})};
            % hScat_RR = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})};
            % BurstData.ScatterPattern = {hScat_GG;...
            %     hScat_GR;...
            %     hScat_RR};

            %%% Read out the Microtime Histograms of the IRF for the two channels
            GG = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1}));
            GR = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1}));
            RR = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1}));
            chan = [GG;GR;RR];
            BurstData.ScatterPattern = cell(numel(chan),1);
            for i = 1:numel(chan)
                if isempty(UserValues.PIE.Combined{chan(i)}) %%% not a combined channel
                    BurstData.ScatterPattern{i} = UserValues.PIE.ScatterPattern{chan(i)};
                else %%% combine IRFs
                    PIEchannel = UserValues.PIE.Combined{chan(i)};
                    BurstData.ScatterPattern{i} =  UserValues.PIE.ScatterPattern{PIEchannel(1)};
                    for j = 2:numel(PIEchannel)
                        BurstData.ScatterPattern{i} = BurstData.ScatterPattern{i} + UserValues.PIE.ScatterPattern{PIEchannel(j)};
                    end
                end
            end
    end
    %%% Background Counts
    BAMethod = BurstData.BAMethod;
    switch BAMethod
        case {1,2}
            % Background for all burst channels
            % BurstData.Background.Background_GGpar = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1}));
            % BurstData.Background.Background_GGperp = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2}));
            % BurstData.Background.Background_GRpar = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1}));
            % BurstData.Background.Background_GRperp = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2}));
            % BurstData.Background.Background_RRpar = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1}));
            % BurstData.Background.Background_RRperp = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2}));

            GGpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1}));
            GGperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2}));
            GRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1}));
            GRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2}));
            RRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1}));
            RRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2}));

            if isempty(UserValues.PIE.Combined{GGpar}) %%% not a combined channel
                BurstData.Background.Background_GGpar = UserValues.PIE.Background(GGpar);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{GGpar};
                BurstData.Background.Background_GGpar = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_GGpar = BurstData.Background.Background_GGpar + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{GGperp}) %%% not a combined channel
                BurstData.Background.Background_GGperp = UserValues.PIE.Background(GGperp);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{GGperp};
                BurstData.Background.Background_GGperp = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_GGperp = BurstData.Background.Background_GGperp + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{GRpar}) %%% not a combined channel
                BurstData.Background.Background_GRpar = UserValues.PIE.Background(GRpar);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{GRpar};
                BurstData.Background.Background_GRpar = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_GRpar = BurstData.Background.Background_GRpar + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{GRperp}) %%% not a combined channel
                BurstData.Background.Background_GRperp = UserValues.PIE.Background(GRperp);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{GRperp};
                BurstData.Background.Background_GRperp = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_GRperp = BurstData.Background.Background_GRperp + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{RRpar}) %%% not a combined channel
                BurstData.Background.Background_RRpar = UserValues.PIE.Background(RRpar);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{RRpar};
                BurstData.Background.Background_RRpar = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_RRpar = BurstData.Background.Background_RRpar + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{RRperp}) %%% not a combined channel
                BurstData.Background.Background_RRperp = UserValues.PIE.Background(RRperp);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{RRperp};
                BurstData.Background.Background_RRperp = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_RRperp = BurstData.Background.Background_RRperp + UserValues.PIE.Background(PIEchannel(j));
                end
            end
        case {3,4}
            % BurstData.Background.Background_BBpar = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1}));
            % BurstData.Background.Background_BBperp = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2}));
            % BurstData.Background.Background_BGpar = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1}));
            % BurstData.Background.Background_BGperp = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2}));
            % BurstData.Background.Background_BRpar = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1}));
            % BurstData.Background.Background_BRperp = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2}));
            % BurstData.Background.Background_GGpar = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,1}));
            % BurstData.Background.Background_GGperp = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,2}));
            % BurstData.Background.Background_GRpar = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{5,1}));
            % BurstData.Background.Background_GRperp = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{5,2}));
            % BurstData.Background.Background_RRpar = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,1}));
            % BurstData.Background.Background_RRperp = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,2}));

            %%% Read out the Microtime Histograms of the IRF for the two channels
            BBpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1}));
            BBperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2}));
            BGpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1}));
            BGperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2}));
            BRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1}));
            BRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2}));
            GGpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,1}));
            GGperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,2}));
            GRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,1}));
            GRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,2}));
            RRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,1}));
            RRperp = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,2}));

            if isempty(UserValues.PIE.Combined{BBpar}) %%% not a combined channel
                BurstData.Background.Background_BBpar = UserValues.PIE.Background(BBpar);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{BBpar};
                BurstData.Background.Background_BBpar = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_BBpar = BurstData.Background.Background_BBpar + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{BBperp}) %%% not a combined channel
                BurstData.Background.Background_BBperp = UserValues.PIE.Background(BBperp);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{BBperp};
                BurstData.Background.Background_BBperp = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_BBperp = BurstData.Background.Background_BBperp + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{BGpar}) %%% not a combined channel
                BurstData.Background.Background_BGpar = UserValues.PIE.Background(BGpar);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{BGpar};
                BurstData.Background.Background_BGpar = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_BGpar = BurstData.Background.Background_BGpar + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{BGperp}) %%% not a combined channel
                BurstData.Background.Background_BGperp = UserValues.PIE.Background(BGperp);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{BGperp};
                BurstData.Background.Background_BGperp = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_BGperp = BurstData.Background.Background_BGperp + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{BRpar}) %%% not a combined channel
                BurstData.Background.Background_BRpar = UserValues.PIE.Background(BRpar);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{BRpar};
                BurstData.Background.Background_BRpar = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_BRpar = BurstData.Background.Background_BRpar + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{BRperp}) %%% not a combined channel
                BurstData.Background.Background_BRperp = UserValues.PIE.Background(BRperp);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{BRperp};
                BurstData.Background.Background_BRperp = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_BRperp = BurstData.Background.Background_BRperp + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{GGpar}) %%% not a combined channel
                BurstData.Background.Background_GGpar = UserValues.PIE.Background(GGpar);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{GGpar};
                BurstData.Background.Background_GGpar = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_GGpar = BurstData.Background.Background_GGpar + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{GGperp}) %%% not a combined channel
                BurstData.Background.Background_GGperp = UserValues.PIE.Background(GGperp);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{GGperp};
                BurstData.Background.Background_GGperp = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_GGperp = BurstData.Background.Background_GGperp + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{GRpar}) %%% not a combined channel
                BurstData.Background.Background_GRpar = UserValues.PIE.Background(GRpar);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{GRpar};
                BurstData.Background.Background_GRpar = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_GRpar = BurstData.Background.Background_GRpar + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{GRperp}) %%% not a combined channel
                BurstData.Background.Background_GRperp = UserValues.PIE.Background(GRperp);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{GRperp};
                BurstData.Background.Background_GRperp = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_GRperp = BurstData.Background.Background_GRperp + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{RRpar}) %%% not a combined channel
                BurstData.Background.Background_RRpar = UserValues.PIE.Background(RRpar);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{RRpar};
                BurstData.Background.Background_RRpar = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_RRpar = BurstData.Background.Background_RRpar + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{RRperp}) %%% not a combined channel
                BurstData.Background.Background_RRperp = UserValues.PIE.Background(RRperp);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{RRperp};
                BurstData.Background.Background_RRperp = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_RRperp = BurstData.Background.Background_RRperp + UserValues.PIE.Background(PIEchannel(j));
                end
            end
        case {5,6}
            % Background for all burst channels
            % BurstData.Background.Background_GGpar = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1}));
            % BurstData.Background.Background_GGperp = BurstData.Background.Background_GGpar;
            % BurstData.Background.Background_GRpar = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1}));
            % BurstData.Background.Background_GRperp = BurstData.Background.Background_GRpar;
            % BurstData.Background.Background_RRpar = ...
            %     UserValues.PIE.Background(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1}));
            % BurstData.Background.Background_RRperp = BurstData.Background.Background_RRpar;

            GGpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1}));
            GRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1}));
            RRpar = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1}));

            if isempty(UserValues.PIE.Combined{GGpar}) %%% not a combined channel
                BurstData.Background.Background_GGpar = UserValues.PIE.Background(GGpar);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{GGpar};
                BurstData.Background.Background_GGpar = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_GGpar = BurstData.Background.Background_GGpar + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{GRpar}) %%% not a combined channel
                BurstData.Background.Background_GRpar = UserValues.PIE.Background(GRpar);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{GRpar};
                BurstData.Background.Background_GRpar = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_GRpar = BurstData.Background.Background_GRpar + UserValues.PIE.Background(PIEchannel(j));
                end
            end
            if isempty(UserValues.PIE.Combined{RRpar}) %%% not a combined channel
                BurstData.Background.Background_RRpar = UserValues.PIE.Background(RRpar);
            else %%% combine Background
                PIEchannel = UserValues.PIE.Combined{RRpar};
                BurstData.Background.Background_RRpar = 0;
                for j = 1:numel(PIEchannel)
                    BurstData.Background.Background_RRpar = BurstData.Background.Background_RRpar + UserValues.PIE.Background(PIEchannel(j));
                end
            end

            BurstData.Background.Background_GGperp = BurstData.Background.Background_GGpar;
            BurstData.Background.Background_GRperp = BurstData.Background.Background_GRpar;
            BurstData.Background.Background_RRperp = BurstData.Background.Background_RRpar;
    end
end

if any(mode==2)
    %% Save the Phasor Reference as well
    %%% Read out the Microtime Histograms of the Phasor References for the channels
    switch BurstData.BAMethod
        case {1,2}
            try
                PhasorReference_GGpar = UserValues.PIE.PhasorReference{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
                PhasorReference_GGperp = UserValues.PIE.PhasorReference{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2})};
                PhasorReference_GRpar = UserValues.PIE.PhasorReference{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})};
                PhasorReference_GRperp = UserValues.PIE.PhasorReference{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2})};
                PhasorReference_RRpar = UserValues.PIE.PhasorReference{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})};
                PhasorReference_RRperp = UserValues.PIE.PhasorReference{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2})};
                
                BurstData.Phasor.PhasorReference = {PhasorReference_GGpar; PhasorReference_GGperp;...
                    PhasorReference_GRpar; PhasorReference_GRperp;...
                    PhasorReference_RRpar; PhasorReference_RRperp};
                BurstData.Phasor.PhasorReferenceLifetime = [...
                    UserValues.PIE.PhasorReferenceLifetime(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})),...
                    UserValues.PIE.PhasorReferenceLifetime(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2})),...
                    UserValues.PIE.PhasorReferenceLifetime(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})),...
                    UserValues.PIE.PhasorReferenceLifetime(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2})),...
                    UserValues.PIE.PhasorReferenceLifetime(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})),...
                    UserValues.PIE.PhasorReferenceLifetime(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2}))];
            end
        case {5}
            try
                PhasorReference_GG = UserValues.PIE.PhasorReference{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
                PhasorReference_GR = UserValues.PIE.PhasorReference{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})};
                PhasorReference_RR = UserValues.PIE.PhasorReference{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})};
                BurstData.Phasor.PhasorReference = {PhasorReference_GG;...
                    PhasorReference_GR;...
                    PhasorReference_RR};
                BurstData.Phasor.PhasorReferenceLifetime = [...
                    UserValues.PIE.PhasorReferenceLifetime(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})),...
                    UserValues.PIE.PhasorReferenceLifetime(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})),...
                    UserValues.PIE.PhasorReferenceLifetime(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1}))]; 
            end
    end
end

if any(mode==3)
    %% Save the Donor-Only Reference
    %%% Read out the Microtime Histograms of the Donor-Only References for the donor channels
    switch BurstData.BAMethod
        case {1,2}
            try
                DonorOnlyReference_GGpar = UserValues.PIE.DonorOnlyReference{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
                DonorOnlyReference_GGperp = UserValues.PIE.DonorOnlyReference{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2})};

                BurstData.DonorOnlyReference = {DonorOnlyReference_GGpar; DonorOnlyReference_GGperp};
            end
        case {5}
            try
                DonorOnlyReference = UserValues.PIE.DonorOnlyReference{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
                BurstData.DonorOnlyReference = {DonorOnlyReference_GG};
            end
        end
end

if ~strcmp(obj,'nothing')
    % function is called from right clicking the Burstwise lifetime button
    save(BurstData.FileName,'BurstData','-append');
    Progress(1,h.Progress.Axes,h.Progress.Text);
    h.Progress.Text.String = FileInfo.FileName{1};
end
%%% update BurstData in PamMeta
PamMeta.BurstData = BurstData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function related to 2CDE filter calcula tion (Nir-Filter) %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [KDE]= kernel_density_estimate(A,B,tau) %KDE of B around A
%%% error checkup to catch empty arrays
if nargin == 2
    if isempty(A)
        KDE = [];
        return;
    end
elseif nargin == 3
    if isempty(A)
        KDE = [];
        return;
    elseif isempty(B)
        KDE = zeros(numel(A),1);
        return;
    end
end
mex = true;
if mex
    if nargin == 3
        KDE = KDE_mex(double(A),double(B),tau,numel(A),numel(B));
    elseif nargin == 2 %%% B is tau
        KDE = KDE_mex(double(A),double(A),B,numel(A),numel(A));
    end
    KDE = KDE';
else
    if nargin == 3
        M = abs(ones(numel(B),1)*A - B'*ones(1,numel(A)));
        M(M>5*tau) = 0;
        E = exp(-M./tau);
        E(M==0) = 0;
        KDE = sum(E,1)';
        %    KDE = KDE_mex(B,A,tau,numel(B),numel(A));
    elseif nargin == 2
        tau = B;
        M = abs(ones(numel(A),1)*A - A'*ones(1,numel(A)));
        M(M>5*tau) = 0;
        E = exp(-M./tau);
        E(M==0) = 0;
        KDE = sum(E,1)'+1;
    end
end

function [KDE]= nb_kernel_density_estimate(B,tau) %non biased KDE of B around B
%%% error checkup to catch empty arrays
if isempty(B)
    KDE = 0;
    return;
end
mex = true;
if mex
    KDE = KDE_mex(double(B),double(B),tau,numel(B),numel(B));
    KDE = KDE'-1; %%% need to subtract one because zero lag is counter here
else
    M = abs(ones(numel(B),1)*B - B'*ones(1,numel(B)));
    M(M>5*tau) = 0;
    E = exp(-M./tau);
    E(M==0) = 0;
    KDE = sum(E,1)';
end
KDE = (1+2/numel(B)).*KDE;

function [FRET_2CDE, ALEX_2CDE,E_D,E_A] = KDE(Trace,Chan_Trace,tau,BAMethod)
%%% Additional output:
%%% (E)_D = E_D - FRET efficiency estimated around donor photons
%%% (1-E)_A = E_A - 1-FRET efficiency estimated around
%%% acceptor photons
%%%
%%% These quantities are used to calculate FRET_2CDE by:
%%% FRET_2CDE = 110 - 100 x ( (E)_D + (1-E)_A )
%%%
%%% They are needed in BurstBrowser to perform correct averaging of the 
%%% FRET-2CDE filter over a set of bursts.
switch BAMethod
    case {1,2} %MFD
        T_GG = Trace(Chan_Trace == 1 | Chan_Trace == 2);
        T_GR = Trace(Chan_Trace == 3 | Chan_Trace == 4);
        T_RR = Trace(Chan_Trace == 5 | Chan_Trace == 6);
        T_GX = Trace(Chan_Trace == 1 | Chan_Trace == 2 | Chan_Trace == 3 | Chan_Trace == 4);
    case {5,6} %noMFD
        T_GG = Trace(Chan_Trace == 1);
        T_GR = Trace(Chan_Trace == 2);
        T_RR = Trace(Chan_Trace == 3);
        T_GX = Trace(Chan_Trace == 1 | Chan_Trace == 2);
end
%tau = 100E-6; standard value
%KDE calculation

%KDE of A(GR) around D (GG)
KDE_GR_GG = kernel_density_estimate(T_GG,T_GR,tau);
%KDE of D(GG) around D (GG)
KDE_GG_GG = nb_kernel_density_estimate(T_GG,tau);
%KDE of A(GR) around A (GR)
KDE_GR_GR = nb_kernel_density_estimate(T_GR,tau);
%KDE of D(GG) around A(GR)
KDE_GG_GR = kernel_density_estimate(T_GR,T_GG,tau);
%KDE of D(GX) around D (GX)
KDE_GX_GX = kernel_density_estimate(T_GX,tau);
%KDE of A(RR) around A(RR)
KDE_RR_RR = kernel_density_estimate(T_RR,tau);
%KDE of A(RR) around D (GX)
KDE_RR_GX = kernel_density_estimate(T_GX,T_RR,tau);
%KDE of D(GX) around A (RR)
KDE_GX_RR = kernel_density_estimate(T_RR,T_GX,tau);
%calculate FRET-2CDE
%(E)_D
%check for case of denominator == 0!
valid = (KDE_GR_GG+KDE_GG_GG) ~= 0;
E_D = (1/(numel(T_GG)-sum(~valid))).*sum(KDE_GR_GG(valid)./(KDE_GR_GG(valid)+KDE_GG_GG(valid)));
%(1-E)_A
%check for case of denominator == 0!
valid = (KDE_GG_GR+KDE_GR_GR) ~= 0;
E_A = (1/(numel(T_GR)-sum(~valid))).*sum(KDE_GG_GR(valid)./(KDE_GG_GR(valid)+KDE_GR_GR(valid)));
FRET_2CDE = 110 - 100*(E_D+E_A);

%calculate ALEX / PIE 2CDE
%Brightness ratio Dex
BR_D = (1/numel(T_RR)).*sum(KDE_RR_GX./KDE_GX_GX);
%Brightness ration Aex
BR_A =(1/numel(T_GX)).*sum(KDE_GX_RR./KDE_RR_RR);
ALEX_2CDE = 100-50*(BR_D+BR_A);

function [FRET_2CDE, ALEX_2CDE] = KDE_3C(Trace,Chan_Trace,tau)
%Trace(i) and Chan_Trace(i) are referring to the burstsearc
%internal sorting and not related to the channel mapping in the
%pam and Burstsearch GUI, they originate from the row th data is
%imported at hte begining of this function

T_BB = Trace(Chan_Trace == 1 | Chan_Trace == 2);
T_BG = Trace(Chan_Trace == 3 | Chan_Trace == 4);
T_BR = Trace(Chan_Trace == 5 | Chan_Trace == 6);
T_GG = Trace(Chan_Trace == 7 | Chan_Trace == 8);
T_GR = Trace(Chan_Trace == 9 | Chan_Trace == 10);
T_RR = Trace(Chan_Trace == 11 | Chan_Trace == 12);
T_BX = Trace(Chan_Trace == 1 | Chan_Trace == 2 | Chan_Trace == 3 | Chan_Trace == 4 | Chan_Trace == 5 | Chan_Trace == 6);
T_GX = Trace(Chan_Trace == 7 | Chan_Trace == 8 | Chan_Trace == 9 | Chan_Trace == 10);

%tau = 100E-6; fallback value

%KDE calculation for FRET_2CDE

%KDE of BB around BB
KDE_BB_BB = nb_kernel_density_estimate(T_BB,tau);
%KDE of BG around BG
KDE_BG_BG = nb_kernel_density_estimate(T_BG,tau);
%KDE of BR around BR
KDE_BR_BR = nb_kernel_density_estimate(T_BR,tau);
%KDE of BG around BB
KDE_BG_BB = kernel_density_estimate(T_BB,T_BG,tau);
%KDE of BR around BB
KDE_BR_BB = kernel_density_estimate(T_BB,T_BR,tau);
%KDE of BB around BG
KDE_BB_BG = kernel_density_estimate(T_BG,T_BB,tau);
%KDE of BB around BR
KDE_BB_BR = kernel_density_estimate(T_BR,T_BB,tau);
%KDE of A(GR) around D (GG)
KDE_GR_GG = kernel_density_estimate(T_GG,T_GR,tau);
%KDE of D(GG) around D (GG)
KDE_GG_GG = nb_kernel_density_estimate(T_GG,tau);
%KDE of A(GR) around A (GR)
KDE_GR_GR = nb_kernel_density_estimate(T_GR,tau);
%KDE of D(GG) around A(GR)
KDE_GG_GR = kernel_density_estimate(T_GR,T_GG,tau);

%KDE for ALEX_2CDE

%KDE of BX around BX
KDE_BX_BX = kernel_density_estimate(T_BX,tau);
%KDE of GX around BX
KDE_GX_BX = kernel_density_estimate(T_BX,T_GX,tau);
%KDE of BX around GX
KDE_BX_GX = kernel_density_estimate(T_GX,T_BX,tau);
%KDE of A(RR) around D (BX)
KDE_RR_BX = kernel_density_estimate(T_BX,T_RR,tau);
%KDE of BX around RR
KDE_BX_RR = kernel_density_estimate(T_RR,T_BX,tau);
%KDE of D(GX) around D (GX)
KDE_GX_GX = kernel_density_estimate(T_GX,tau);
%KDE of A(RR) around A(RR)
KDE_RR_RR = kernel_density_estimate(T_RR,tau);
%KDE of A(RR) around D (GX)
KDE_RR_GX = kernel_density_estimate(T_GX,T_RR,tau);
%KDE of D(GX) around A (RR)
KDE_GX_RR = kernel_density_estimate(T_RR,T_GX,tau);

%calculate FRET-2CDE based on proximity ratio for BG,BR

%BG
%(E)_D
%check for case of denominator == 0!
valid = (KDE_BG_BB+KDE_BB_BB) ~= 0;
E_D = (1/(numel(T_BB)-sum(~valid))).*sum(KDE_BG_BB(valid)./(KDE_BG_BB(valid)+KDE_BB_BB(valid)));
%(1-E)_A
valid = (KDE_BB_BG+KDE_BG_BG) ~= 0;
E_A = (1/(numel(T_BG)-sum(~valid))).*sum(KDE_BB_BG(valid)./(KDE_BB_BG(valid)+KDE_BG_BG(valid)));
FRET_2CDE(1,1) = 110 - 100*(E_D+E_A);
%BR
valid = (KDE_BR_BB+KDE_BB_BB) ~= 0;
E_D = (1/(numel(T_BB)-sum(~valid))).*sum(KDE_BR_BB(valid)./(KDE_BR_BB(valid)+KDE_BB_BB(valid)));
%(1-E)_A
valid = (KDE_BB_BR+KDE_BR_BR) ~= 0;
E_A = (1/(numel(T_BR)-sum(~valid))).*sum(KDE_BB_BR(valid)./(KDE_BB_BR(valid)+KDE_BR_BR(valid)));
FRET_2CDE(1,2) = 110 - 100*(E_D+E_A);
%GR
%(E)_D
valid = (KDE_GR_GG+KDE_GG_GG) ~= 0;
E_D = (1/(numel(T_GG)-sum(~valid))).*sum(KDE_GR_GG(valid)./(KDE_GR_GG(valid)+KDE_GG_GG(valid)));
%(1-E)_A
valid = (KDE_GG_GR+KDE_GR_GR) ~= 0;
E_A = (1/(numel(T_GR)-sum(~valid))).*sum(KDE_GG_GR(valid)./(KDE_GG_GR(valid)+KDE_GR_GR(valid)));
FRET_2CDE(1,3) = 110 - 100*(E_D+E_A);

%calculate ALEX / PIE 2CDE

%BG
%Brightness ratio Dex
BR_D = (1/numel(T_GX)).*sum(KDE_GX_BX./KDE_BX_BX);
%Brightness ration Aex
BR_A =(1/numel(T_BX)).*sum(KDE_BX_GX./KDE_GX_GX);
ALEX_2CDE(1,1) = 100-50*(BR_D+BR_A);

%BR
%Brightness ratio Dex
BR_D = (1/numel(T_RR)).*sum(KDE_RR_BX./KDE_BX_BX);
%Brightness ration Aex
BR_A =(1/numel(T_BX)).*sum(KDE_BX_RR./KDE_RR_RR);
ALEX_2CDE(1,2) = 100-50*(BR_D+BR_A);

%GR
%Brightness ratio Dex
BR_D = (1/numel(T_RR)).*sum(KDE_RR_GX./KDE_GX_GX);
%Brightness ration Aex
BR_A =(1/numel(T_GX)).*sum(KDE_GX_RR./KDE_RR_RR);
ALEX_2CDE(1,3) = 100-50*(BR_D+BR_A);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to apply microtime shift for detector correction %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Shift_Detector(~,~,info)
global UserValues TcspcData PamMeta FileInfo
h=guidata(findobj('Tag','Pam'));
h.Progress.Text.String = 'Calculating detector calibration';
h.Progress.Axes.Color=[1 0 0];

%drawnow;
if nargin<3 % calculate the shift
    if ~isempty(UserValues.Detector.Shift{h.MI.Calib_Det.Value})
        msgbox('A shift for this detector already exists in UserValues. Press the Clear shift button, Open data again in Pam, and press Calculate correction again!')
        h.Progress.Text.String = FileInfo.FileName{1};
        h.Progress.Axes.Color=UserValues.Look.Control;
        return
    else
        maxtick = str2double(h.MI.Calib_Single_Max.String);
        Det=UserValues.Detector.Det(h.MI.Calib_Det.Value);
        Rout=UserValues.Detector.Rout(h.MI.Calib_Det.Value);
        Dif=[maxtick; uint16(diff(TcspcData.MT{Det,Rout}))];
        Dif(Dif>maxtick)=maxtick;
        MI=TcspcData.MI{Det,Rout};
        
        % find the minimum macortime interval to use (exlude those that
        % fall within or overlap with the deadtime of the electronics)
        deadtime = str2double(h.MI.TCSPC_DeadTime_Edit.String);
        min_bin = ceil(deadtime/(FileInfo.TACRange*1E9));
        
        % make a 2D histogram of the interphoton time (0:maxtick) versus TAC bin
        PamMeta.Det_Calib.Hist=histc(double(Dif-1)*FileInfo.MI_Bins+double(MI),0:(maxtick*FileInfo.MI_Bins-1));
        PamMeta.Det_Calib.Hist=reshape(PamMeta.Det_Calib.Hist,FileInfo.MI_Bins,maxtick);
        % sort from low to high counts along the TAC axis:
        [Counts,Index]=sort(PamMeta.Det_Calib.Hist);
        % for each interphoton macrotime, take the average TAC position of the
        % 100 brightnest bins:
        PamMeta.Det_Calib.Shift=sum(Counts(end-100:end,:).*Index(end-100:end,:))./sum(Counts(end-100:end,:));
        PamMeta.Det_Calib.Shift=round(PamMeta.Det_Calib.Shift-PamMeta.Det_Calib.Shift(end));
        PamMeta.Det_Calib.Shift(isnan(PamMeta.Det_Calib.Shift))=0;
        PamMeta.Det_Calib.Shift(1:min_bin)=PamMeta.Det_Calib.Shift(min_bin+1);
        PamMeta.Det_Calib.Shift=PamMeta.Det_Calib.Shift-max(PamMeta.Det_Calib.Shift);
        if size(PamMeta.Det_Calib.Shift,1) > size(PamMeta.Det_Calib.Shift,2)
            PamMeta.Det_Calib.Shift = PamMeta.Det_Calib.Shift';
        end
        clear Counts Index
        
        % uncorrected MI histogram (blue)
        h.Plots.Calib_No.Visible = 'on';
        h.Plots.Calib_No.YData=sum(PamMeta.Det_Calib.Hist,2)/max(smooth(sum(PamMeta.Det_Calib.Hist,2),5));
        h.Plots.Calib_No.XData=1:FileInfo.MI_Bins;
        
        % corrected MI histogram (red)
        Cor_Hist=zeros(size(PamMeta.Det_Calib.Hist));
        for i=1:maxtick
            Cor_Hist(:,i)=circshift(PamMeta.Det_Calib.Hist(:,i),[-PamMeta.Det_Calib.Shift(i),0]);
        end
        h.Plots.Calib.Visible = 'on';
        h.Plots.Calib.YData=sum(Cor_Hist,2)/max(smooth(sum(Cor_Hist,2),5));
        h.Plots.Calib.XData=1:FileInfo.MI_Bins;
        
        % slider
        h.MI.Calib_Single.Value=round(h.MI.Calib_Single.Value);
        
        % interphoton time selected MI histogram (green)
        h.Plots.Calib_Sel.Visible = 'on';
        h.Plots.Calib_Sel.YData=PamMeta.Det_Calib.Hist(:,h.MI.Calib_Single.Value)/max(smooth(Cor_Hist(:,h.MI.Calib_Single.Value),5));
        h.Plots.Calib_Sel.XData=1:FileInfo.MI_Bins;
        
        % shift plot (red)
        h.MI.Calib_Axes_Shift.XLim = [1 maxtick];
        h.MI.Calib_Axes_Shift.YLimMode = 'auto';
        h.Plots.Calib_Shift_New.Visible = 'on';
        h.Plots.Calib_Shift_New.XData=1:maxtick;
        h.Plots.Calib_Shift_New.YData=PamMeta.Det_Calib.Shift;
        h.Plots.Calib_Shift_New.Visible = 'on';
        
        smoothing = str2double(h.MI.Calib_Single_Range.String);
        if smoothing > 1
            h.Plots.Calib_Shift_Smoothed.Visible = 'on';
            h.Plots.Calib_Shift_Smoothed.XData = 1:1:numel(PamMeta.Det_Calib.Shift);
            h.Plots.Calib_Shift_Smoothed.YData = smooth(PamMeta.Det_Calib.Shift,smoothing);
        else
            h.Plots.Calib_Shift_Smoothed.Visible = 'off';
        end
        legend([h.Plots.Calib_No,h.Plots.Calib,h.Plots.Calib_Sel],{'Uncorrected','Corrected','Current shift selection'});
    end
else % apply the shift
    if strcmp(info,'load')  %called from LoadTCSPC
        index = 1:numel(UserValues.Detector.Det);
    else %save shift of current channel
        index = h.MI.Calib_Det.Value;
    end
    Det=UserValues.Detector.Det;
    Rout=UserValues.Detector.Rout;
    for i = index
        if numel(UserValues.Detector.Shift)>=i &&  any(UserValues.Detector.Shift{i}) && ~isempty(TcspcData.MI{Det(i),Rout(i)})
            maxtick = numel(UserValues.Detector.Shift{i});
            %%% Calculates inter-photon time; first photon gets 0 shift
            Dif=[maxtick; uint16(diff(TcspcData.MT{Det(i),Rout(i)}))];
            Dif(Dif>maxtick)=maxtick;
            Dif(Dif<1)=1;
            %%% Applies shift to microtime; no shift for >=maxtick
            TcspcData.MI{Det(i),Rout(i)}(Dif<=maxtick)...
                =uint16(double(TcspcData.MI{Det(i),Rout(i)}(Dif<=maxtick))...
                -UserValues.Detector.Shift{i}(Dif(Dif<=maxtick))');
        end
    end
end
h.Progress.Text.String = FileInfo.FileName{1};
h.Progress.Axes.Color=UserValues.Look.Control;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Saves Shift to UserValues and applies it %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Det_Calib_Save(~,~)
global UserValues PamMeta
h=guidata(findobj('Tag','Pam'));
if isfield(PamMeta.Det_Calib, 'Shift')
    smoothing = str2double(h.MI.Calib_Single_Range.String);
    if smoothing > 1
        PamMeta.Det_Calib.Shift = smooth(PamMeta.Det_Calib.Shift,smoothing)';
    end
    UserValues.Detector.Shift{h.MI.Calib_Det.Value}=PamMeta.Det_Calib.Shift;
    Shift_Detector([],[],'save');
    m = msgbox('Load data again. Store IRFs or scatters only after loading data again!');
    pause(1)
    delete(m)
else
    msgbox('shift not calculated yet')
    return
end
PamMeta.Det_Calib = rmfield(PamMeta.Det_Calib, 'Shift');
PamMeta.Det_Calib = rmfield(PamMeta.Det_Calib, 'Hist');
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Clears Shift from UserValues %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Det_Calib_Clear(~,~)
global UserValues
h=guidata(findobj('Tag','Pam'));
if ~isempty(UserValues.Detector.Shift{h.MI.Calib_Det.Value})
    UserValues.Detector.Shift{h.MI.Calib_Det.Value} = [];
    m = msgbox('Load data again');
    pause(1)
    delete(m)
end
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions concerning database of quick access filenames %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Database(~,e,mode)
global UserValues PamMeta
h = guidata(findobj('Tag','Pam'));

if mode == 0 %%% Checks, which key was pressed
    switch e.EventName
        case 'KeyPress'
            switch e.Key
                case 'delete'
                    mode = 2;
                case 'return'
                    %%% If both Keypress and Callback are active, 'return'
                    %%% will call it twice!
                    %mode =7;
            end
        case 'Action' %%% mouse-click
            switch get(gcbf,'SelectionType')
                case 'open' %%% double click
                    mode = 7;
            end
            %%% store the order of clicks
            if numel(h.Database.List.Value) == 1
                %%% reset
                h.Database.List.UserData = h.Database.List.Value;
            elseif numel(h.Database.List.Value) > numel(h.Database.List.UserData)
                %%% additional elements selected, store in correct order
                h.Database.List.UserData = [h.Database.List.UserData,...
                    h.Database.List.Value(~ismember(h.Database.List.Value,h.Database.List.UserData))];
            elseif numel(h.Database.List.Value) < numel(h.Database.List.UserData)
                %%% objects were deselected, remove
                h.Database.List.UserData = h.Database.List.UserData(ismember(h.Database.List.UserData,h.Database.List.Value));
            end            
    end
end

switch mode
    case 1 %% Add files to database
        %%% following code is for remembering the last used FileType
        LSUserValues(0);
        %%% Loads all possible file types
        Filetypes = UserValues.File.SPC_FileTypes;
        if h.Profiles.Filetype.Value>1
            Custom = str2func(h.Profiles.Filetype.String{h.Profiles.Filetype.Value});
            [Custom_Suffix, Custom_Description] = feval(Custom);
            Filetypes{end+1,1} = Custom_Suffix;
            Filetypes{end,2} = Custom_Description;
        end
        
        
        %%% Finds last used file type
        Lastfile = UserValues.File.OpenTCSPC_FilterIndex;
        if isempty(Lastfile) || numel(Lastfile)~=1 || ~isnumeric(Lastfile) || isnan(Lastfile) ||  Lastfile <1 || Lastfile>size(Filetypes,1)
            Lastfile = 1;
        end
        %%% Puts last used file type to front
        Fileorder = 1:size(Filetypes,1);
        Fileorder = [Lastfile, Fileorder(Fileorder~=Lastfile)];
        Filetypes = Filetypes(Fileorder,:);
        %%% Choose file to be loaded
        [FileName, Path, Type] = uigetfile(Filetypes, 'Choose a TCSPC data file',UserValues.File.Path,'MultiSelect', 'on');
        %%% Determines actually selected file type
        if Type~=0
            Type = Fileorder(Type);
        end
        
        %%% Only execues if any file was selected
        if ~iscell(FileName) && all(FileName==0)
            return
        end
        %%% Save the selected file type
        UserValues.File.OpenTCSPC_FilterIndex = Type;
        %%% Transforms FileName into cell, if it is not already
        %%%(e.g. when only one file was selected)
        if ~iscell(FileName)
            FileName = {FileName};
        end
        %%% Saves Path
        UserValues.File.Path = Path;
        LSUserValues(1);
        %%% Sorts FileName by alphabetical order
        FileName=sort(FileName);
        %% Add files to database
        if ~isfield(PamMeta, 'Database')
            %create database
            PamMeta.Database = cell(0,3);
        end
        % add new files to database
        for i = 1:numel(FileName)
            PamMeta.Database = [{FileName{numel(FileName)-i+1},Path,Type}; PamMeta.Database];
            h.Database.List.String = [{[FileName{numel(FileName)-i+1} ' (path:' Path ')']}; h.Database.List.String];
        end
        if size(PamMeta.Database,1) > 20
            PamMeta.Database = PamMeta.Database(1:20,:);
            h.Database.List.String = h.Database.List.String(1:20);
        end
        % store file history in UserValues
        UserValues.File.FileHistory.PAM = PamMeta.Database;
    case 2 %% Delete files from database
        %remove rows from list
        h.Database.List.String(h.Database.List.Value) = [];
        %remove rows from database
        PamMeta.Database(h.Database.List.Value, :) = [];
        h.Database.List.Value = 1;
        % store file history in UserValues
        UserValues.File.FileHistory.PAM = PamMeta.Database;
    case 7 %% Loads selected files into Pam
        %%% Caution! Only works if Path and filetype are the same for all files!
        h.Progress.Text.String='Loading new file';
        % Path is unique per file in the database, so we have to store
        % it globally in UserValues each time
        UserValues.File.Path = PamMeta.Database{h.Database.List.Value(1),2};
        LSUserValues(1);
        LoadTcspc([],[],@Update_Data,@Update_Display,@Shift_Detector,@Update_Detector_Channels,h.Pam,...
            PamMeta.Database(h.Database.List.UserData,1),...   %file
            PamMeta.Database{h.Database.List.UserData(1),3});     %type
            %PamMeta.Database(h.Database.List.Value,1),...   %file
            %PamMeta.Database{h.Database.List.Value(1),3});     %type
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions concerning database for quick export %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export_Database(obj,e,mode)
global UserValues PamMeta FileInfo
h = guidata(findobj('Tag','Pam'));

if mode == 0 %%% Checks, which key was pressed
    switch e.EventName
        case 'KeyPress'
            switch e.Key
                case 'delete'
                    mode = 2;
                case 'return'
                    %mode =9;
                    %%% If both Keypress and Callback are active, 'return'
                    %%% will call it twice!
                    %mode =7;
            end
        case 'Action' %%% mouse-click
            switch get(gcbf,'SelectionType')
                case 'open' %%% double click
                    mode = 9;
            end
            %%% store the order of clicks
            if numel(h.Export.List.Value) == 1
                %%% reset
                h.Export.List.UserData = h.Export.List.Value;
            elseif numel(h.Export.List.Value) > numel(h.Export.List.UserData)
                %%% additional elements selected, store in correct order
                h.Export.List.UserData = [h.Export.List.UserData,...
                    h.Export.List.Value(~ismember(h.Export.List.Value,h.Export.List.UserData))];
            elseif numel(h.Export.List.Value) < numel(h.Export.List.UserData)
                %%% objects were deselected, remove
                h.Export.List.UserData = h.Export.List.UserData(ismember(h.Export.List.UserData,h.Export.List.Value));
            end            
    end
end

switch mode
    case 1 %% Add files to database
        LSUserValues(0);
        while true %%% Continuously askes for more files, till none was selected
            %%% following code is for remembering the last used FileType
            %%% Loads all possible file types
            Filetypes = UserValues.File.SPC_FileTypes;
            if h.Profiles.Filetype.Value>1
                Custom = str2func(h.Profiles.Filetype.String{h.Profiles.Filetype.Value});
                [Custom_Suffix, Custom_Description] = feval(Custom);
                Filetypes{end+1,1} = Custom_Suffix;
                Filetypes{end,2} = Custom_Description;
            end
            %%% Finds last used file type
            Lastfile = UserValues.File.OpenTCSPC_FilterIndex;
            if isempty(Lastfile) || numel(Lastfile)~=1 || ~isnumeric(Lastfile) || isnan(Lastfile) ||  Lastfile <1 || Lastfile>size(Filetypes,1)
                Lastfile = 1;
            end
            %%% Puts last used file type to front
            Fileorder = 1:size(Filetypes,1);
            Fileorder = [Lastfile, Fileorder(Fileorder~=Lastfile)];
            Filetypes = Filetypes(Fileorder,:);
            %%% Choose file to be loaded
            [FileName, Path, Type] = uigetfile(Filetypes, 'Choose a TCSPC data file',UserValues.File.Path,'MultiSelect', 'on');
            %%% Determines actually selected file type
            if Type~=0
                Type = Fileorder(Type);
            end
            
            %%% Only execues if any file was selected
            if ~iscell(FileName) && all(FileName==0)
                return;
            end
            %%% Save the selected file type
            UserValues.File.OpenTCSPC_FilterIndex = Type;
            %%% Transforms FileName into cell, if it is not already
            %%%(e.g. when only one file was selected)
            if ~iscell(FileName)
                FileName = {FileName};
            end
            %%% Saves Path
            UserValues.File.Path = Path;
            LSUserValues(1);
            %%% Sorts FileName by alphabetical order
            FileName=sort(FileName);
            %% Add files to export database
            if ~isfield(PamMeta, 'Export')
                %create export database
                PamMeta.Export = cell(0,3);
            end
            % add new files to database
            
            if strcmp(obj.Tag,'Export_Multi')
                PamMeta.Export{end+1,1} = FileName;
                PamMeta.Export{end,2} = Path;
                PamMeta.Export{end,3} = Type;
                h.Export.List.String{end+1} = [num2str(numel(FileName)) ' Files: ' FileName{1} ' (path:' Path ')'];
            else
                for i=1:numel(FileName)
                    PamMeta.Export{end+1,1} = FileName(i);
                    PamMeta.Export{end,2} = Path;
                    PamMeta.Export{end,3} = Type;
                    h.Export.List.String{end+1} = [FileName{i} ' (path:' Path ')'];
                end
            end
            
            h.Export.TIFF.Enable = 'on';
            h.Export.Save.Enable = 'on';
            h.Export.MicrotimePattern.Enable = 'on';
            h.Export.Correlate.Enable = 'on';
            h.Export.Burst.Enable = 'on';
        end
    case 2 %% Delete files from database
        %remove rows from list
        h.Export.List.String(h.Export.List.Value) = [];
        %remove rows from database
        PamMeta.Export(h.Export.List.Value, :) = [];
        h.Export.List.Value = 1;
        if numel(h.Export.List.String)<1
            h.Export.TIFF.Enable = 'off';
            h.Export.Save.Enable = 'off';
            h.Export.MicrotimePattern.Enable = 'off';
        end
    case 3 %% Load database
        [FileName, Path] = uigetfile({'*.edb', 'Export Database file'}, 'Choose export database to load',UserValues.File.Path,'MultiSelect', 'off');
        if all(FileName==0)
            return
        end
        load('-mat',fullfile(Path,FileName));
        PamMeta.Export = s.export;
        h.Export.List.String = s.str;
        clear s;
        h.Export.TIFF.Enable = 'on';
        h.Export.Save.Enable = 'on';
        h.Export.MicrotimePattern.Enable = 'on';
        h.Export.Correlate.Enable = 'on';
        h.Export.Burst.Enable = 'on';
    case 4 %% Save complete database
        [File, Path] = uiputfile({'*.edb', 'Database file'}, 'Save export database', UserValues.File.Path);
        if all(File==0)
            return
        end
        s = struct;
        s.export = PamMeta.Export;
        s.str = h.Export.List.String;
        save(fullfile(Path,File),'s');
    case 5 %% Export PIE channels as TIFF
        Sel = find(h.Export.PIE.Data);
        if numel(Sel)==0
            return;
        elseif size(Sel,1)>1
            Sel=Sel';
        end
        if h.Export.TIFF.UserData == 0
            h.Export.TIFF.UserData = 1;
            h.Export.TIFF.String = 'Stop';
        elseif h.Export.TIFF.UserData == 1
            h.Export.TIFF.UserData = 0;
        end
        event.Key = 'Export_Image_Tiff';
        for i = h.Export.List.Value
            pause(0.01)
            if h.Export.TIFF.UserData == 0
                h.Export.TIFF.String = 'Export TIFFs';
                h.Progress.Text.String = FileInfo.FileName{1};
                h.Progress.Axes.Color=UserValues.Look.Control;
                return
            end
            if ~iscell(PamMeta.Export{i,1}{1})
                num_files = 1;
            else
                num_files = numel(PamMeta.Export{i,1}{1});
            end
            try
                % Path is unique per file in the database, so we have to store
                % it globally in UserValues each time
                UserValues.File.Path = PamMeta.Export{i,2};
                LSUserValues(1);
                LoadTcspc([],[],@Update_Data,@Update_Display,@Shift_Detector,@Update_Detector_Channels,h.Pam,...
                    PamMeta.Export{i,1},...   %file
                    PamMeta.Export{i,3});     %type
                Pam_Export([],event,Sel,1)
                % set filename color to green
                h.Export.List.String{i} = ['<HTML><FONT color=64D413>' num2str(num_files) ' Files: ' PamMeta.Export{i,1}{1} ' (path:' PamMeta.Export{i,2} ')</Font></html>'];
            catch
                h.Export.List.String{i}=['<HTML><FONT color=FF0000>' num2str(num_files) ' Files: ' PamMeta.Export{i,1}{1} ' (path:' PamMeta.Export{i,2} ')</Font></html>'];
            end
            h.Progress.Text.String = FileInfo.FileName{1};
            h.Progress.Axes.Color = UserValues.Look.Control;
        end
        h.Export.TIFF.UserData = 0;
        h.Export.TIFF.String = 'Export TIFFs';
    case 6 %% Export PIE channels as microtime histograms to *.dec file
        Sel = find(h.Export.PIE.Data);
        if numel(Sel)==0
            return;
        elseif size(Sel,1)>1
            Sel=Sel';
        end
        if h.Export.MicrotimePattern.UserData == 0
            h.Export.MicrotimePattern.UserData = 1;
            h.Export.MicrotimePattern.String = 'Stop';
        elseif h.Export.MicrotimePattern.UserData == 1
            h.Export.MicrotimePattern.UserData = 0;
        end        
        event.Key = 'Export_MicrotimePattern';
        for i = h.Export.List.Value
            pause(0.01)
            if h.Export.MicrotimePattern.UserData == 0
                h.Export.MicrotimePattern.String = 'Export Microtime Histogram';
                h.Progress.Text.String = FileInfo.FileName{1};
                h.Progress.Axes.Color=UserValues.Look.Control;
                return
            end

            % Path is unique per file in the database, so we have to store
            % it globally in UserValues each time
            UserValues.File.Path = PamMeta.Export{i,2};
            LSUserValues(1);
            LoadTcspc([],[],@Update_Data,@Update_Display,@Shift_Detector,@Update_Detector_Channels,h.Pam,...
                PamMeta.Export{i,1},...   %file
                PamMeta.Export{i,3});     %type
            Pam_Export([],event,Sel,1)
            % set filename color to green
            if ~iscell(PamMeta.Export{i,1}{1})
                num_files = 1;
            else
                num_files = numel(PamMeta.Export{i,1}{1});
            end
            h.Export.List.String{i} = ['<HTML><FONT color=64D413>' num2str(num_files) ' Files: ' PamMeta.Export{i,1}{1} ' (path:' PamMeta.Export{i,2} ')</Font></html>'];

            h.Progress.Text.String = FileInfo.FileName{1};
            h.Progress.Axes.Color = UserValues.Look.Control;
        end
        h.Export.MicrotimePattern.UserData = 0;
        h.Export.MicrotimePattern.String = 'Export Microtime Histogram';
    case 7 %% Correlate active ones in database
        if h.Export.Correlate.UserData == 0
            h.Export.Correlate.UserData = 1;
            h.Export.Correlate.String = 'Stop';
        elseif h.Export.Correlate.UserData == 1
            h.Export.Correlate.UserData = 0;
        end
        for i = h.Export.List.Value
            pause(0.01)
            if h.Export.Correlate.UserData == 0
                h.Export.Correlate.String = 'Correlate';
                return
            end
            try
                % Path is unique per file in the database, so we have to store
                % it globally in UserValues each time
                UserValues.File.Path = PamMeta.Export{i,2};
                LSUserValues(1);
                LoadTcspc([],[],@Update_Data,@Update_Display,@Shift_Detector,@Update_Detector_Channels,h.Pam,...
                    PamMeta.Export{i,1},...   %file
                    PamMeta.Export{i,3});     %type
                Correlate ([],[],1)
                % set filename color to green
                String = h.Export.List.String{i};
                if size(String,2)<25 || ~strcmp(String(1:6),'<HTML>')
                    h.Export.List.String{i} = ['<HTML><FONT color=64D413>' String '</Font></html>'];
                else
                    String(19:24)='64D413';
                    h.Export.List.String{i} = String;
                end
            catch
                String = h.Export.List.String{i};
                if size(String,2)<25 || ~strcmp(String(1:6),'<HTML>')
                    h.Export.List.String{i} = ['<HTML><FONT color=FF0000>' String '</Font></html>'];
                else
                    String(19:24)='FF0000';
                    h.Export.List.String{i} = String;
                end
            end
        end
        h.Export.Correlate.UserData = 0;
        h.Export.Correlate.String = 'Correlate';
    case 8 %% Burst analyse active ones in database
        for i = h.Export.List.Value
            try
                % Path is unique per file in the database, so we have to store
                % it globally in UserValues each time
                UserValues.File.Path = PamMeta.Export{i,2};
                LSUserValues(1);
                LoadTcspc([],[],@Update_Data,@Update_Display,@Shift_Detector,@Update_Detector_Channels,h.Pam,...
                    PamMeta.Export{i,1},...   %file
                    PamMeta.Export{i,3});     %type
                Do_BurstAnalysis(h.Burst.Button,[])
                % depending on whether the '2CDE' and 'lifetime' checkboxes are
                % checked on the 'Burst analysis' tab, this might also be performed
                % set filename color to green
                % set filename color to green
                String = h.Export.List.String{i};
                if size(String,2)<25 || ~strcmp(String(1:6),'<HTML>')
                    h.Export.List.String{i} = ['<HTML><FONT color=64D413>' String '</Font></html>'];
                else
                    String(19:24)='64D413';
                    h.Export.List.String{i} = String;
                end
            catch exception
                String = h.Export.List.String{i};
                if size(String,2)<25 || ~strcmp(String(1:6),'<HTML>')
                    h.Export.List.String{i} = ['<HTML><FONT color=FF0000>' String '</Font></html>'];
                else
                    String(19:24)='FF0000';
                    h.Export.List.String{i} = String;
                    rethrow(exception);
                end
                
            end
        end
    case 9 %% Loads selected files into Pam
        %%% Caution! Only works if Path and filetype are the same for all files!
        h.Progress.Text.String='Loading new file';
        % Path is unique per file in the database, so we have to store
        % it globally in UserValues each time
        UserValues.File.Path = PamMeta.Export{h.Export.List.Value(1),2};
        LSUserValues(1);
        
        LoadTcspc([],[],@Update_Data,@Update_Display,@Shift_Detector,@Update_Detector_Channels,h.Pam,...
            [PamMeta.Export{h.Export.List.UserData,1}],...   %file
            PamMeta.Export{h.Export.List.UserData(1),3});     %type
            %[PamMeta.Export{h.Export.List.Value,1}],...   %file
            %PamMeta.Export{h.Export.List.Value(1),3});     %type
end
%%% store database in UserValues
UserValues.File.FileHistory.PAM_Export = PamMeta.Export;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions that actially export data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Pam_Export(~,e,Sel,mode)
global UserValues TcspcData FileInfo PamMeta
h = guidata(findobj('Tag','Pam'));
if nargin<4
    mode = 0;
end
switch e.Key
    case 'Export_Raw_Total'%%% Exports macrotime and microtime as one vector for each PIE channel
        h.Progress.Text.String = 'Exporting';
        h.Progress.Axes.Color=[1 0 0];
        drawnow;
        for i=Sel
            Det=UserValues.PIE.Detector(i);
            Rout=UserValues.PIE.Router(i);
            From=UserValues.PIE.From(i);
            To=UserValues.PIE.To(i);
            if Det>0 && all(size(TcspcData.MI)>=[Det Rout]) %%% Normal PIE channel
                MI=TcspcData.MI{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To);
                assignin('base',[matlab.lang.makeValidName(UserValues.PIE.Name{i}) '_MI'],MI); clear MI;
                MT=TcspcData.MT{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To);
                assignin('base',[matlab.lang.makeValidName(UserValues.PIE.Name{i}) '_MT'],MT); clear MT;
            elseif Det == 0 %%% Combined PIE channel
                MI =[];
                MT = [];
                Name = '';
                for j = UserValues.PIE.Combined{i}
                    Det=UserValues.PIE.Detector(j);
                    Rout=UserValues.PIE.Router(j);
                    From=UserValues.PIE.From(j);
                    To=UserValues.PIE.To(j);
                    if all (size(TcspcData.MI) >= [Det Rout]) && Det>0
                        MI=[MI; TcspcData.MI{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To)];
                        MT=[MT; TcspcData.MT{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To)];
                    end
                    Name = [Name UserValues.PIE.Name{j} '_'];
                end
                [MT,Index] = sort(MT);
                MI = MI(Index);
                assignin('base',[matlab.lang.makeValidName(Name) 'MI'],MI); clear MI;
                assignin('base',[matlab.lang.makeValidName(Name) 'MT'],MT); clear MT;
            end
        end
    case 'Export_Raw_File' %%% Exports macrotime and microtime as a cell for each PIE channel
        h.Progress.Text.String = 'Exporting';
        h.Progress.Axes.Color=[1 0 0];
        drawnow;
        for i=Sel
            Det=UserValues.PIE.Detector(i);
            Rout=UserValues.PIE.Router(i);
            From=UserValues.PIE.From(i);
            To=UserValues.PIE.To(i);
            
            if Det>0 && all(size(TcspcData.MI) >= [Det Rout])  %%% Normal PIE channel
                MI=cell(FileInfo.NumberOfFiles,1);
                MT=cell(FileInfo.NumberOfFiles,1);
                MT{1}=TcspcData.MT{Det,Rout}(1:FileInfo.LastPhoton{Det,Rout}(1));
                MI{1}=TcspcData.MI{Det,Rout}(1:FileInfo.LastPhoton{Det,Rout}(1));
                MT{1}=MT{1}(MI{1}>=From & MI{1}<=To);
                MI{1}=MI{1}(MI{1}>=From & MI{1}<=To);
                if FileInfo.NumberOfFiles>1
                    for j=2:(FileInfo.NumberOfFiles)
                        MI{j}=TcspcData.MI{Det,Rout}((FileInfo.LastPhoton{Det,Rout}(j-1)+1):FileInfo.LastPhoton{Det,Rout}(j));
                        MI{j}=MI{j}(MI{j}>=From & MI{j}<=To);
                        MT{j}=TcspcData.MT{Det,Rout}((FileInfo.LastPhoton{Det,Rout}(j-1)+1):FileInfo.LastPhoton{Det,Rout}(j));
                        MT{j}=MT{j}(MI{j}>=From & MI{j}<=To)-(j-1)*round(FileInfo.MeasurementTime/FileInfo.ClockPeriod);
                    end
                end
                assignin('base',[matlab.lang.makeValidName(UserValues.PIE.Name{i}) '_MI'],MI); clear MI;
                assignin('base',[matlab.lang.makeValidName(UserValues.PIE.Name{i}) '_MT'],MT); clear MT;
            elseif Det == 0 %%% Combined PIE channel
                MI=cell(FileInfo.NumberOfFiles,1);
                MT=cell(FileInfo.NumberOfFiles,1);
                Name = '';
                for j = UserValues.PIE.Combined{i}
                    Det=UserValues.PIE.Detector(j);
                    Rout=UserValues.PIE.Router(j);
                    From=UserValues.PIE.From(j);
                    To=UserValues.PIE.To(j);
                    if all (size(TcspcData.MI) >= [Det Rout]) && Det>0
                        mt=TcspcData.MT{Det,Rout}(1:FileInfo.LastPhoton{Det,Rout,1});
                        mi=TcspcData.MI{Det,Rout}(1:FileInfo.LastPhoton{Det,Rout,1});
                        mt=mt(mi>=From & mi<=To);
                        mi=mi(mi>=From & mi<=To);
                        MI{1}=[MI{1}; mi];
                        MT{1}=[MT{1}; mt];
                        if FileInfo.NumberOfFiles>1
                            for k=2:FileInfo.NumberOfFiles
                                mt=TcspcData.MT{Det,Rout}((FileInfo.LastPhoton{Det,Rout}(k-1)+1):FileInfo.LastPhoton{Det,Rout}(k));
                                mi=TcspcData.MI{Det,Rout}((FileInfo.LastPhoton{Det,Rout}(k-1)+1):FileInfo.LastPhoton{Det,Rout}(k));
                                mt=mt(mi>=From & mi<=To);
                                mi=mi(mi>=From & mi<=To);
                                MI{k}=[MI{k}; mi];
                                MT{k}=[MT{k}; mt];
                            end
                        end
                    end
                    Name = [Name UserValues.PIE.Name{j} '_'];
                end
                for k = 1:FileInfo.NumberOfFiles
                    [MT{k},Index] = sort(MT{k});
                    MI{k} = MI{k}(Index);
                end
                assignin('base',[matlab.lang.makeValidName(Name) 'MI'],MI); clear MI;
                assignin('base',[matlab.lang.makeValidName(Name) 'MT'],MT); clear MT;
            end
            
        end
    case 'Export_Image_Total'%%% Plots image and exports it into workspace
        h.Progress.Text.String = 'Exporting';
        h.Progress.Axes.Color=[1 0 0];
        drawnow;
        for i=Sel
            %%% Changes combined PIE channel name to make it compatible
            %%% with Matlab variable names
            if strfind(UserValues.PIE.Name{i},'Comb.:')
                Name = '';
                for j = UserValues.PIE.Combined{i}
                    Name = [Name UserValues.PIE.Name{j} '_'];
                end
            else
                Name = [UserValues.PIE.Name{i} '_'];
            end
            %%% Exports intensity image
            if h.MT.Image_Export.Value == 1 || h.MT.Image_Export.Value == 2
                assignin('base',[matlab.lang.makeValidName(Name) 'Image'],PamMeta.Image{i});
                figure('Name',[UserValues.PIE.Name{i} '_Image']);
                imagesc(PamMeta.Image{i});
            end
            %%% Exports mean arrival time image
            if h.MT.Image_Export.Value == 1 || h.MT.Image_Export.Value == 3
                assignin('base',[matlab.lang.makeValidName(Name) '_LT'],PamMeta.Lifetime{i});
                figure('Name',[UserValues.PIE.Name{i} '_LT']);
                imagesc(PamMeta.Lifetime{i});
            end
        end
        %%% gives focus back to Pam
        figure(h.Pam);
    case 'Export_Image_File' %%% Exports image stack into workspace
        h.Progress.Text.String = 'Exporting';
        h.Progress.Axes.Color=[1 0 0];
        drawnow;
        for i=Sel
            %%% Gets the photons
            if UserValues.PIE.Detector(i)~=0 %%% Normal PIE channel
                Stack=TcspcData.MT{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}(...
                    TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}>=UserValues.PIE.From(i) &...
                    TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}<=UserValues.PIE.To(i));
            else
                Stack = [];
                for j = UserValues.PIE.Combined{i} %%% Combined channel
                    Stack = [Stack; TcspcData.MT{UserValues.PIE.Detector(j),UserValues.PIE.Router(j)}(...
                        TcspcData.MI{UserValues.PIE.Detector(j),UserValues.PIE.Router(j)}>=UserValues.PIE.From(j) &...
                        TcspcData.MI{UserValues.PIE.Detector(j),UserValues.PIE.Router(j)}<=UserValues.PIE.To(j))];
                end
            end
            [Stack,~]=CalculateImage(Stack.*FileInfo.ClockPeriod,3);
            Stack=uint16(Stack);
            
            %%% Exports matrix to workspace
            if strfind(UserValues.PIE.Name{i},'Comb.:')
                Name = '';
                for j = UserValues.PIE.Combined{i}
                    Name = [Name UserValues.PIE.Name{j} '_'];
                end
                assignin('base',[matlab.lang.makeValidName(Name) 'Image'],Stack);
            else
                assignin('base',[matlab.lang.makeValidName(UserValues.PIE.Name{i}) '_Image'],Stack);
            end
        end
    case 'Export_Image_Tiff' %%% Exports image stack as TIFF
        if mode == 0
            Path=uigetdir(UserValues.File.ExportPath,'Select folder to save TIFFs');
        else
            Path = UserValues.File.Path;
        end
        if all(Path==0)
            return;
        end
        h.Progress.Text.String = 'Exporting';
        h.Progress.Axes.Color=[1 0 0];
        drawnow;
        UserValues.File.ExportPath=Path;
        LSUserValues(1);
        for i=Sel
            %%% Gets the photons
            if UserValues.PIE.Detector(i)~=0 %%% Normal PIE channel
                Stack=TcspcData.MT{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}(...
                    TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}>=UserValues.PIE.From(i) &...
                    TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}<=UserValues.PIE.To(i));
            else
                Stack = [];
                for j = UserValues.PIE.Combined{i} %%% Combined channel
                    Stack = [Stack; TcspcData.MT{UserValues.PIE.Detector(j),UserValues.PIE.Router(j)}(...
                        TcspcData.MI{UserValues.PIE.Detector(j),UserValues.PIE.Router(j)}>=UserValues.PIE.From(j) &...
                        TcspcData.MI{UserValues.PIE.Detector(j),UserValues.PIE.Router(j)}<=UserValues.PIE.To(j))];
                end
            end
            
            [Stack,~]=CalculateImage(Stack.*FileInfo.ClockPeriod,3);
            Stack=uint16(Stack);
            
            File=fullfile(Path,[FileInfo.FileName{1}(1:end-4) UserValues.PIE.Name{i} '.tif']);
            
            Tagstruct.ImageLength = FileInfo.Lines;
            Tagstruct.ImageWidth = FileInfo.Pixels;
            Tagstruct.Compression = 5; %1==None; 5==LZW
            Tagstruct.SampleFormat = 1; %UInt
            Tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
            Tagstruct.BitsPerSample =  16;                        %32= float data, 16= Andor standard sampling
            Tagstruct.SamplesPerPixel = 1;
            Tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            if isfield(FileInfo, 'Fabsurf') && ~isempty(FileInfo.Fabsurf)
                pixsize = num2str(FileInfo.Fabsurf.Imagesize/FileInfo.Lines*1000);
            else
                pixsize = num2str(50);
            end
            Tagstruct.ImageDescription = ['Type: ' FileInfo.FileType '\n',...
                'FrameTime [s]: ' num2str(mean(diff(FileInfo.ImageTimes))) '\n',...
                'LineTime [ms]: ' num2str(mean2(diff(FileInfo.LineTimes,1,2))*1000) '\n',...
                'PixelTime [us]: ' num2str(mean2(diff(FileInfo.LineTimes,1,2))/FileInfo.Pixels*1e6) '\n',...
                'PixelSize [nm]: ' pixsize '\n'];
            
            Z_Pos = str2double(h.Export.Z_Pos.String);
            Z_Frames = str2double(h.Export.Z_Frames.String);
            if mode == 0 || Z_Pos ==1 %%% Simple export of all frames
                TIFF_handle = Tiff(File, 'w');
                TIFF_handle.setTag(Tagstruct);
                
                for j=1:size(Stack,3)
                    TIFF_handle.write(Stack(:,:,j));
                    if j<size(Stack,3)
                        TIFF_handle.writeDirectory();
                        TIFF_handle.setTag(Tagstruct);
                    end
                end
                TIFF_handle.close()
            else %%% Splits Frames into different TIFFs (like for Z-Scans)
                File = File(1:end-4);
                for j = 1:Z_Pos
                    Frames = repmat((((j-1)*Z_Frames+1):(Z_Pos*Z_Frames):size(Stack,3)),Z_Frames,1);
                    Frames = Frames+repmat(permute((0:(Z_Frames-1)),[2 1]),1,size(Frames,2));
                    Frames = sort(Frames(:));
                    if ~isempty(Frames)
                        TIFF_handle = Tiff([File '_' num2str(j) '.tif'], 'w');
                        TIFF_handle.setTag(Tagstruct);
                        for k=Frames'
                            TIFF_handle.write(Stack(:,:,k));
                            if k<Frames(end)
                                TIFF_handle.writeDirectory();
                                TIFF_handle.setTag(Tagstruct);
                            end
                        end
                        TIFF_handle.close()
                    end
                end
            end
            Progress(1,h.Progress.Axes,h.Progress.Text,'Exporting:')
        end
        Progress(1,h.Progress.Axes,h.Progress.Text,'Exporting Finished')
    case 'Export_MicrotimePattern' %%% Export microtime pattern
        h.Progress.Text.String = 'Exporting';
        h.Progress.Axes.Color=[1 0 0];
        drawnow;
        %%% Read out Photons and Histogram
        %%% store in format:
        %%% channel
        %%% Decay IRF scatter
        
        if any(isempty(UserValues.PIE.IRF(Sel))) %%% check that IRF is not empty for selected PIE channels
            disp('IRF not defined for at least one selected PIE channel.');
            return;
        end
        if any(isempty(UserValues.PIE.ScatterPattern(Sel))) %%% check that ScatterPattern is not empty for selected PIE channels
            disp('Scatter pattern not defined for at least one selected PIE channel.');
            return;
        end
        microtimeHistograms = zeros(FileInfo.MI_Bins,3*numel(Sel));
        for i = 1:numel(Sel)
            MI = histc( TcspcData.MI{UserValues.PIE.Detector(Sel(i)),UserValues.PIE.Router(Sel(i))},...
                1:FileInfo.MI_Bins);
            PIErange = max([UserValues.PIE.From(Sel(i)),1]):min([UserValues.PIE.To(Sel(i)) numel(MI)]);
            microtimeHistograms(PIErange,3*(i-1)+1) = MI(PIErange);
            microtimeHistograms(:,3*(i-1)+2) = UserValues.PIE.IRF{Sel(i)}(1:FileInfo.MI_Bins);
            microtimeHistograms(:,3*(i-1)+3) = UserValues.PIE.ScatterPattern{Sel(i)}(1:FileInfo.MI_Bins);
            Progress((i-1)/numel(Sel),h.Progress.Axes,h.Progress.Text,'Exporting:')
        end
        %%% create filename
        [~,fileName,~] = fileparts(FileInfo.FileName{1});
        for i = 1:numel(Sel)
            fileName = [fileName '_' UserValues.PIE.Name{Sel(i)}];
        end
        fileName = [fileName '.dec'];
        fid = fopen(fullfile(FileInfo.Path,fileName),'w');
        %%% write header
        %%% general info
        fprintf(fid,'TAC range [ns]:\t\t %.2f\nMicrotime Bins:\t\t %d\nResolution [ps]:\t %.2f\n\n',1E9*FileInfo.TACRange,FileInfo.MI_Bins,1E12*FileInfo.TACRange/FileInfo.MI_Bins);
        %%% PIE channel names
        for i = 1:numel(Sel)
            fprintf(fid,'%s\t\t\t',UserValues.PIE.Name{Sel(i)});
        end
        fprintf(fid,'\n');
        for i = 1:numel(Sel)
            fprintf(fid,'%s\t%s\t%s\t','Decay','IRF','Scatter');
        end
        fprintf(fid,'\n');
        fclose(fid);
        dlmwrite(fullfile(FileInfo.Path,fileName),microtimeHistograms,'-append','delimiter','\t');
        UserValues.File.TauFitPath = FileInfo.Path;
        Progress(1,h.Progress.Axes,h.Progress.Text);
    case 'Export_PCH' %%% Export PCH
        h.Progress.Text.String = 'Exporting';
        h.Progress.Axes.Color=[1 0 0];
        drawnow;
        %%% Read out PCH
        %%% store in format:
        %%% channel1 channel2 ...
        %%% PCH1     PCH2     ...

        PCH = zeros(max(cellfun(@numel,PamMeta.PCH(Sel))),numel(Sel)+1);
        PCH(:,1) = 0:1:size(PCH,1)-1;
        for i = 1:numel(Sel)
            PCH(1:numel(PamMeta.PCH{Sel(i)}),i+1) = PamMeta.PCH{Sel(i)};
            Progress((i-1)/numel(Sel),h.Progress.Axes,h.Progress.Text,'Exporting:')
        end
        %%% create filename
        [~,fileName,~] = fileparts(FileInfo.FileName{1});
        for i = 1:numel(Sel)
            fileName = [fileName '_' UserValues.PIE.Name{Sel(i)}];
        end
        fileName = [fileName '.pch'];
        fid = fopen(fullfile(FileInfo.Path,fileName),'w');
        %%% write header
        %%% general info
        fprintf(fid,'# PCH data exported from PAM\n');
        fprintf(fid,'# Bin size [ms]:\t %g\n',UserValues.Settings.Pam.PCH_Binning);
        %%% PIE channel names
        fprintf(fid,'Counts,');
        for i = 1:numel(Sel)
            fprintf(fid,'%s,',UserValues.PIE.Name{Sel(i)});
        end
        fprintf(fid,'\n');
        fclose(fid);
        dlmwrite(fullfile(FileInfo.Path,fileName),PCH,'-append','delimiter',',','precision','%g');
        Progress(1,h.Progress.Axes,h.Progress.Text);
    case 'Eport_RLICS_TIFF' %%% Eports image stack as Lifetime Filtered TIFF
        
        if mode == 0
            Path=uigetdir(UserValues.File.ExportPath,'Select folder to save TIFFs');
        else
            Path = UserValues.File.Path;
        end
        if all(Path==0)
            return;
        end
        h.Progress.Text.String = 'Exporting';
        h.Progress.Axes.Color=[1 0 0];
        drawnow;
        UserValues.File.ExportPath=Path;
        LSUserValues(1);
        
        filter = PamMeta.fFCS.filters;
        
        for i=size(filter)
            %% Initializes data cells
            Data=[];
            MI=[];
            
            %%% Combines all photons to one vector
            offset = 0;
            for l = PamMeta.fFCS.PIEseletion{1}
                Data=[Data; Get_Photons_from_PIEChannel(l,'Macrotime')];
                MI = [MI; Get_Photons_from_PIEChannel(l,'Microtime')+offset*FileInfo.MI_Bins];
                offset = offset + 1;
            end
            %%% Weights photons by filter
            MI = filter{1}{i}(MI);
            
            [Data, Bin,] = CalculateImage(Data,4);
            Data = flip(permute(reshape(Data,FileInfo.Pixels,FileInfo.Lines,[]),[2 1 3]),1);
            
            MI(Bin==0)=[];
            Bin(Bin==0)=[];
            MI = accumarray(Bin,MI, [numel(Data) 1]);
            clear Bin;
            
            %%% Rescales and reshapes weighed stack
            Min = min(MI);
            Max = max(MI);
            MI=uint16((MI-Min)/(Max-Min)*2^16);
            MI=flip(permute(reshape(MI,FileInfo.Pixels,FileInfo.Lines,[]),[2 1 3]),1);
            
            File=fullfile(Path,[FileInfo.FileName{1}(1:end-4) 'Filter' num2str(i) '.tif']);
            
            Tagstruct.ImageLength = FileInfo.Lines;
            Tagstruct.ImageWidth = FileInfo.Lines;
            Tagstruct.Compression = 5; %1==None; 5==LZW
            Tagstruct.SampleFormat = 1; %UInt
            Tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
            Tagstruct.BitsPerSample =  16;                        %32= float data, 16= Andor standard sampling
            Tagstruct.SamplesPerPixel = 1;
            Tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            if isfield(FileInfo, 'Fabsurf') && ~isempty(FileInfo.Fabsurf)
                pixsize = num2str(FileInfo.Fabsurf.Imagesize/FileInfo.Lines*1000);
            else
                pixsize = num2str(50);
            end
            Tagstruct.ImageDescription = ['Type: ' FileInfo.FileType '\n',...
                'FrameTime [s]: ' num2str(mean(diff(FileInfo.ImageTimes))) '\n',...
                'LineTime [ms]: ' num2str(mean2(diff(FileInfo.LineTimes,1,2))*1000) '\n',...
                'PixelTime [us]: ' num2str(mean2(diff(FileInfo.LineTimes,1,2))/FileInfo.Pixels*1e6) '\n',...
                'PixelSize [nm]: ' pixsize '\n',...
                'RLICS_Scale: ' num2str(Max-Min) '\n',...
                'RLICS_Offset: ' num2str(Min) '\n'];
            TIFF_handle = Tiff(File, 'w');
            TIFF_handle.setTag(Tagstruct);
            
            for j=1:size(Data,3)
                TIFF_handle.write(Data(:,:,j));
                TIFF_handle.writeDirectory();
                TIFF_handle.setTag(Tagstruct);
            end
            for j=1:size(MI,3)
                TIFF_handle.write(MI(:,:,j));
                if j<size(MI,3)
                    TIFF_handle.writeDirectory();
                    TIFF_handle.setTag(Tagstruct);
                end
            end
            TIFF_handle.close()
        end
        Progress(1,h.Progress.Axes,h.Progress.Text,'Exporting:')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions that exports the microtime pattern of all detectors %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SaveLoadMIPattern(obj,~)
global UserValues PamMeta FileInfo
h = guidata(findobj('Tag','Pam'));

switch obj
    case h.Cor_fFCS.Save_MIPattern_Button
        %%% Save MI Pattern to *.mi file
        if strcmp(FileInfo.FileName{1},'Nothing loaded')
            errordlg('Load a measurement first!','No measurement loaded...');
            return;
        end
        
        MIPattern = cell(0);
        for i = 1:numel(UserValues.Detector.Det);
            MIPattern{end+1} = PamMeta.MI_Hist{i};
        end
        [~, FileName, ~] = fileparts(FileInfo.FileName{1});
        [File, Path] = uiputfile('*.mi', 'Save Microtime Pattern', fullfile(FileInfo.Path,FileName));
        if all(File==0)
            return
        end
        %save(fullfile(Path,File),'MIPattern');
        %%% Save as *.txt file instead
        %%% write header
        fid = fopen(fullfile(Path,File),'w');
        fprintf(fid,'Microtime patterns of measurement: %s\n',FileInfo.FileName{1});
        %%% write detector - routing assigment
        for i = 1:numel(MIPattern)
            fprintf(fid,'Channel %i: Detector %i and Routing %i\n',i,UserValues.Detector.Det(i),UserValues.Detector.Rout(i));
        end
        fclose(fid);
        dlmwrite(fullfile(Path,File),horzcat(MIPattern{:}),'-append','delimiter',',');
    case h.Cor_fFCS.Load_MIPattern_Button
        %%% Load MI Pattern from *.mi file
        [File,Path,FilterIndex] = uigetfile({'*.mi','PAM microtime pattern file (*_mi.dat)'},...
            'Choose microtime patterns to load...',UserValues.File.Path,'Multiselect','on');
        if FilterIndex == 0
            return;
        end
        if ~iscell(File)
            File = {File};
        end
        if ~isfield(PamMeta,'fFCS')
            PamMeta.fFCS = struct;
        end
        PamMeta.fFCS.MIPattern = cell(0);
        PamMeta.fFCS.MIPattern_Name = cell(0);
        for i = 1:numel(File)
            header_lines = 0;
            while 1
                try
                    data = dlmread(fullfile(Path,File{i}),',',header_lines,0);
                    break;
                catch
                    %%% read text as stringvbnm
                    header_lines = header_lines + 1;
                end
            end
            %%% process header information
            fid = fopen(fullfile(Path,File{i}),'r');
            line = fgetl(fid);
            filename = textscan(line,'Microtime patterns of measurement: %s\n');
            for j = 1:(header_lines-1)
                line = fgetl(fid);
                temp = textscan(line,['Channel ' num2str(j) ': Detector %d and Routing %d\n']);
                Det(j) = temp{1};
                Rout(j) = temp{2};
            end
            fclose(fid);
            MIPattern = cell(0);
            for j = 1:numel(Det)
                MIPattern{Det(j),Rout(j)} = data(:,j);
            end
            [~,PamMeta.fFCS.MIPattern_Name{i},~] = fileparts(filename{1}{1});
            PamMeta.fFCS.MIPattern{i} = MIPattern;
                
            % BurstBrowser exports mat files, use this code instead
            % dummy = load(fullfile(Path,File{i}),'-mat');
            % [~, FileName, ~] = fileparts(File{i});
            % PamMeta.fFCS.MIPattern_Name{i} = FileName;
            % PamMeta.fFCS.MIPattern{i} = dummy.MIPattern;
        end
        Update_fFCS_GUI(obj,[]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions that updates fFCS GUI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_fFCS_GUI(obj,e)
global UserValues PamMeta FileInfo
h = guidata(findobj('Tag','Pam'));

if isempty(obj)
    obj = 'initialize';
end

switch obj
    case 'initialize' % Called on PAM startup, initialize GUI
        %%% set species table to only contain scatter
        h.Cor_fFCS.MIPattern_Table.Data = {'Scatter',false};
    case h.Cor_fFCS.Load_MIPattern_Button
        %%% Update mipattern table (default is all species selected, no
        %%% scatter)
        h.Cor_fFCS.MIPattern_Table.Data = [[PamMeta.fFCS.MIPattern_Name',num2cell(true(numel(PamMeta.fFCS.MIPattern_Name),1))];...
            {'Scatter',false}];
        PamMeta.fFCS.filters = [];
        
        %%% Update cross-correlation table
        Names = PamMeta.fFCS.MIPattern_Name';
        h.Cor_fFCS.Cor_fFCS_Table.RowName = Names;
        h.Cor_fFCS.Cor_fFCS_Table.ColumnName = Names;
        h.Cor_fFCS.Cor_fFCS_Table.Data = num2cell(false(numel(Names)));
        
        %%% Update PIE channel table
        % find out what PIE channels are available in all loaded microtime patterns
        PIEexist = zeros(numel(UserValues.PIE.Name),numel(PamMeta.fFCS.MIPattern_Name)+1); % +1 for scatter pattern
        for i = 1:numel(UserValues.PIE.Name) % loop over PIE channels
            for j = 1:(numel(PamMeta.fFCS.MIPattern_Name)+1)
                if j < (numel(PamMeta.fFCS.MIPattern_Name)+1)
                    if isempty(UserValues.PIE.Combined{i}) %exclude combined channels
                        if (size(PamMeta.fFCS.MIPattern{j},1) >= UserValues.PIE.Detector(i)) && (size(PamMeta.fFCS.MIPattern{j},2) >= UserValues.PIE.Router(i))
                            if ~isempty(PamMeta.fFCS.MIPattern{j}{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)})
                                % there is data in the corresponding detector/router channel
                                if sum(PamMeta.fFCS.MIPattern{j}{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}(UserValues.PIE.From(i):UserValues.PIE.To(i))) > 0
                                    % there is data in the PIE channel range
                                    PIEexist(i,j) = 1;
                                end
                            end
                        end
                    end
                elseif j == (numel(PamMeta.fFCS.MIPattern_Name)+1) %scatter pattern
                    if ~isempty(UserValues.PIE.ScatterPattern{i})
                        PIEexist(i,j) = 1;
                    end
                end
            end
        end
        % find out what PIE channels are available in the loaded measurement!
        valid = zeros(numel(UserValues.PIE.Name),1);
        for i = 1:numel(UserValues.PIE.Name)
            if isempty(UserValues.PIE.Combined{i}) %exclude combined channels
                % map detector/rout to detector plot definition
                det = find((UserValues.Detector.Det == UserValues.PIE.Detector(i)) & (UserValues.Detector.Rout == UserValues.PIE.Router(i)));
                if ~isempty(PamMeta.MI_Hist{det})
                    % there is data in the corresponding detector/router channel
                    if sum(PamMeta.MI_Hist{det}(max([1,UserValues.PIE.From(i)]):min([UserValues.PIE.To(i),end]))) > 0
                        % there is data in the PIE channel range
                        valid(i) = 1;
                    end
                end
            end
        end
        % valid are all PIE channels that exist for all species AND have data for the loaded measurement
        PIEexist = (sum(PIEexist,2) > 1);
        PIEexist = logical(PIEexist.*valid);
        % update the PIEchannel table
        Names = [UserValues.PIE.Name';'Scatter'];
        h.Cor_fFCS.PIEchan_Table.Data = [Names(PIEexist),num2cell(false(sum(PIEexist),1))];
    case h.Cor_fFCS.Prepare_Filter_Button
        if strcmp(FileInfo.FileName{1},'Nothing loaded')
            errordlg('Load a measurement first!','No measurement loaded...');
            return;
        end
        
        % clear plots
        for i = 1:numel(h.Plots.fFCS.MI_Plots)
            delete(h.Plots.fFCS.MI_Plots{i});
        end
        h.Plots.fFCS.MI_Plots={};
        for i = 1:numel(h.Plots.fFCS.Filter_Plots)
            delete(h.Plots.fFCS.Filter_Plots{i});
        end
        h.Plots.fFCS.Filter_Plots={};
        for i = 1:numel(h.Plots.fFCS.MI_Plots2)
            delete(h.Plots.fFCS.MI_Plots2{i});
        end
        h.Plots.fFCS.MI_Plots2={};
        for i = 1:numel(h.Plots.fFCS.Filter_Plots2)
            delete(h.Plots.fFCS.Filter_Plots2{i});
        end
        h.Plots.fFCS.Filter_Plots2={};
        delete(h.Cor_fFCS.MIPattern_Axis.Children);
        delete(h.Cor_fFCS.Filter_Axis.Children);
        delete(h.Cor_fFCS.MIPattern_Axis2.Children);
        delete(h.Cor_fFCS.Filter_Axis2.Children);
        
        %%% hide/unhide plots as needed
        if h.Cor_fFCS.CrossCorr_Checkbox.Value == 0 %%% only use main plot
            h.Cor_fFCS.MIPattern_Axis2.Visible = 'off';
            h.Cor_fFCS.Filter_Axis2.Visible = 'off';
            %%% move main axeis back in position
            h.Cor_fFCS.MIPattern_Axis.Position([1,3]) = [0.06,0.925];
            h.Cor_fFCS.Filter_Axis.Position([1,3]) = [0.06,0.925];
        else
            h.Cor_fFCS.MIPattern_Axis2.Visible = 'on';
            h.Cor_fFCS.Filter_Axis2.Visible = 'on';
            %%% move main axis to left
            h.Cor_fFCS.MIPattern_Axis.Position([1,3]) = [0.05,0.44];
            h.Cor_fFCS.Filter_Axis.Position([1,3]) = [0.05,0.44];
        end
        PamMeta.fFCS.MI_Hist = {};
        PamMeta.fFCS.Decay_Hist = {};
        PamMeta.fFCS.filters = {};
        
        % different photon streams named "A" and "B" (1 and 2) for
        % independent filter generation
        % (if autocorrelation is selected, simply set the second photon
        % stream selection equal to the first one!)
        
        % read out PIE channel selection
        % read active PIE channels and map back to original PIE channel list
        % A
        sel_name = h.Cor_fFCS.PIEchan_Table.Data(cell2mat(h.Cor_fFCS.PIEchan_Table.Data(:,2)),1);
        if isempty(sel_name)
            %%% check that at least one population is selected!
            errordlg('Select PIE channels first!','PIE channel selection empty');
            return;
        end
        for i = 1:numel(sel_name)
            sel{1}(i) = find(strcmp(UserValues.PIE.Name,sel_name{i}));
        end
        % B
        if h.Cor_fFCS.CrossCorr_Checkbox.Value == 1
            sel_name = h.Cor_fFCS.PIEchan_Table.Data(cell2mat(h.Cor_fFCS.PIEchan_Table.Data(:,3)),1);
            if isempty(sel_name)
                %%% check that at least one population is selected!
                errordlg('Select PIE channels for second channel first!','PIE channel selection empty for second channel');
                return;
            end
            for i = 1:numel(sel_name)
                sel{2}(i) = find(strcmp(UserValues.PIE.Name,sel_name{i}));
            end
        else
            % autocorrelation, copy from previous selection
            sel{2} = sel{1};
        end
        PamMeta.fFCS.PIEseletion = sel;
        
        % read out avtive species
        active = find(cell2mat(h.Cor_fFCS.MIPattern_Table.Data(:,2)))';
        
        %%% define colors
        colors = lines(numel(active));
        %%% rational:
        %%% 1.) read out mi patterns
        %%% 2.) do checkup (length of loaded patterns need to be adjusted
        %%% to current measurement)
        %%% 3.) construct stacked channel
        %%% 4.) calculate filter
        
        %%% read mi pattern of loaded measurment and transfer loaded mi pattern data to new cell array
        % top-down:   species - i
        % left-right: PIE channel - sel
        for u = 1:2 %loop over A and B (photon streams 1 and 2)
            %%% we need to map the PIE channel detector/routing pair to the
            %%% detector number as used in PamMeta.MI_Hist to construct the
            %%% measured decay hist
            for j = sel{u}
                det = find((UserValues.Detector.Det == UserValues.PIE.Detector(j)) & (UserValues.Detector.Rout == UserValues.PIE.Router(j)));
                det = det(1); % in case there are redundant detector definitions
                %%% current data
                Decay_Hist{u}{1,j} = PamMeta.MI_Hist{det};
            end
            MI_Hist = {};
            for i = active
                for j = sel{u}
                    %%% loaded patterns
                    if i == numel(PamMeta.fFCS.MIPattern_Name)+1 %last entry, scatter pattern
                        MI_Hist{u}{i,j} = UserValues.PIE.ScatterPattern{j}';
                    else
                        MI_Hist{u}{i,j} = PamMeta.fFCS.MIPattern{i}{UserValues.PIE.Detector(j),UserValues.PIE.Router(j)};
                    end
                end
            end
            
            %%% checkup of lengths
            %%% it should be same lengths as of current measurement
            LEN = FileInfo.MI_Bins;
            len = cellfun(@numel,MI_Hist{u});
            for i = active % adjust all active MI_Hist channels
                for j = sel{u}
                    if len(i,j) > LEN %%% exceeds wanted lengths, shorten
                        MI_Hist{u}{i,j} = MI_Hist{u}{i,j}(1:LEN);
                    elseif len(i,j) < LEN %%% too short, add trailing zeros
                        MI_Hist{u}{i,j} = [MI_Hist{u}{i,j}; zeros(LEN-len(i,j),1)];
                    end
                end
            end
            
            %%% construct stacked channel
            PamMeta.fFCS.Decay_Hist{u} = vertcat(Decay_Hist{u}{:});
            for i = 1:size(MI_Hist{u},1)
                PamMeta.fFCS.MI_Hist{u}{i} = vertcat(MI_Hist{u}{i,:});
                PamMeta.fFCS.MI_Hist{u}{i} = PamMeta.fFCS.MI_Hist{u}{i}./sum(PamMeta.fFCS.MI_Hist{u}{i});
            end
            
            %%% plot
            % for plotting, only consider the PIE channel range! (although the
            % filter is still defined over the whole microtime range)
            % this is just for easier inspection/visibility
            plotrange = [];
            k = 0;
            for j = sel{u}
                plotrange = [plotrange, k*LEN+(UserValues.PIE.From(j):UserValues.PIE.To(j))];
                k = k+1;
            end
            if h.Cor_fFCS.CrossCorr_Checkbox.Value == 0 %%% only use main plot
                for i = active
                    h.Plots.fFCS.MI_Plots{end+1} = plot(h.Cor_fFCS.MIPattern_Axis,PamMeta.fFCS.MI_Hist{u}{i}(plotrange),'--','Color',colors(i,:));
                end
                h.Plots.fFCS.MI_Plots{end+1} = plot(h.Cor_fFCS.MIPattern_Axis,PamMeta.fFCS.Decay_Hist{u}(plotrange)./sum(PamMeta.fFCS.Decay_Hist{u}),'k');
                h.Cor_fFCS.MIPattern_Axis.XLim = [1,numel(plotrange)];
            else
                switch u
                    case 1
                        for i = active
                            h.Plots.fFCS.MI_Plots{end+1} = plot(h.Cor_fFCS.MIPattern_Axis,PamMeta.fFCS.MI_Hist{u}{i}(plotrange),'--','Color',colors(i,:));
                        end
                        h.Plots.fFCS.MI_Plots{end+1} = plot(h.Cor_fFCS.MIPattern_Axis,PamMeta.fFCS.Decay_Hist{u}(plotrange)./sum(PamMeta.fFCS.Decay_Hist{u}),'k');
                        h.Cor_fFCS.MIPattern_Axis.XLim = [1,numel(plotrange)];
                    case 2
                        for i = active
                            h.Plots.fFCS.MI_Plots2{end+1} = plot(h.Cor_fFCS.MIPattern_Axis2,PamMeta.fFCS.MI_Hist{u}{i}(plotrange),'--','Color',colors(i,:));
                        end
                        h.Plots.fFCS.MI_Plots2{end+1} = plot(h.Cor_fFCS.MIPattern_Axis2,PamMeta.fFCS.Decay_Hist{u}(plotrange)./sum(PamMeta.fFCS.Decay_Hist{u}),'k');
                        h.Cor_fFCS.MIPattern_Axis2.XLim = [1,numel(plotrange)];
                end
            end
            %%% calculate FLCS filters
            %%% problem: only those bins where Decay and all microtime patterns are
            %%% NOT zero are to be used!
            %%% all zero bins filter values should just be zero (so they don't
            %%% contribute to the correlation function)
            %%% solution: perform calculations only on "valid" bins
            valid = (PamMeta.fFCS.Decay_Hist{u} ~= 0);
            %for i = active
            %    valid = valid & (PamMeta.fFCS.MI_Hist{u}{i} ~= 0);
            %end
            Decay = PamMeta.fFCS.Decay_Hist{u}(valid);
            diag_Decay = zeros(numel(Decay));
            for i = 1:numel(Decay)
                diag_Decay(i,i) = 1./Decay(i);
            end
            MI_species = [];
            for i = active
                MI_species = [MI_species, PamMeta.fFCS.MI_Hist{u}{i}(valid)./sum(PamMeta.fFCS.MI_Hist{u}{i}(valid))]; % re-normalize here since not all bins are used!
            end
            filters_temp = ((MI_species'*diag_Decay*MI_species)^(-1)*MI_species'*diag_Decay)';
            % compute the reconstruction of the decay pattern based on species (used for evaluation of filter quality)
            reconstruction_temp = sum((MI_species'*diag_Decay*MI_species)^(-1)*MI_species',1);
            reconstruction{u} = zeros(numel(PamMeta.fFCS.Decay_Hist{u}),1);
            reconstruction{u}(valid) = reconstruction_temp;
            %%% rescale filters back to total microtime range (no cut with valid)
            filters = zeros(numel(PamMeta.fFCS.Decay_Hist{u}),numel(active));            
            for i = 1:numel(active)
                filters(valid,i) = filters_temp(:,i);
            end
            for i = 1:size(filters,2)
                PamMeta.fFCS.filters{u}{i} = filters(:,i);
            end
            
            %%% plot new filters
            if h.Cor_fFCS.CrossCorr_Checkbox.Value == 0 %%% only use main plot
                for i = 1:numel(active)
                    h.Plots.fFCS.Filter_Plots{end+1} = plot(h.Cor_fFCS.Filter_Axis,PamMeta.fFCS.filters{u}{i}(plotrange),'Color',colors(i,:));
                end
                h.Cor_fFCS.Filter_Axis.XLim = [1,numel(plotrange)];
            else
                switch u
                    case 1
                        for i = 1:numel(active)
                            h.Plots.fFCS.Filter_Plots{end+1} = plot(h.Cor_fFCS.Filter_Axis,PamMeta.fFCS.filters{u}{i}(plotrange),'Color',colors(i,:));
                        end
                        h.Cor_fFCS.Filter_Axis.XLim = [1,numel(plotrange)];
                    case 2
                        for i = 1:numel(active)
                            h.Plots.fFCS.Filter_Plots2{end+1} = plot(h.Cor_fFCS.Filter_Axis2,PamMeta.fFCS.filters{u}{i}(plotrange),'Color',colors(i,:));
                        end
                        h.Cor_fFCS.Filter_Axis2.XLim = [1,numel(plotrange)];
                end
            end
        end
        
        %%% update axes limits
        h.Cor_fFCS.MIPattern_Axis.XLim = [1,numel(plotrange)];
        %h.Cor_fFCS.MIPattern_Axis.YScale = 'log';
        h.Cor_fFCS.MIPattern_Axis.YLimMode = 'auto';
        
        h.Cor_fFCS.Filter_Axis.XLim = [1,numel(plotrange)];
        h.Cor_fFCS.Filter_Axis.YLimMode = 'auto';
        
        %%% add legends
        names = [PamMeta.fFCS.MIPattern_Name, {'Scatter'}];
        names = names(active); names{end+1} = 'total';
        names = cellfun(@(x) strrep(x,'_',' '),names,'UniformOutput',false);
        if h.Cor_fFCS.CrossCorr_Checkbox.Value == 0
            legend(h.Cor_fFCS.MIPattern_Axis2,'off');
            legend(h.Cor_fFCS.MIPattern_Axis,names);
        else
            legend(h.Cor_fFCS.MIPattern_Axis,'off');
            legend(h.Cor_fFCS.MIPattern_Axis2,names);
        end
        %%% save new plots in guidata
        guidata(findobj('Tag','Pam'),h)
        %%% plot reconstruction against data for quality evaluation
        f = figure('Color',[1,1,1]);f.Position(1) = 100;
        subplot(4,1,2:4);hold on;
        plot(PamMeta.fFCS.Decay_Hist{1},'LineWidth',2); plot(reconstruction{1},'LineWidth',2);        
        set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',16,'YScale','lin','Box','on');
        ylabel('Counts');
        xlabel('TCSPC channel');
        axis('tight');
        xlim([1,numel(plotrange)]);
        subplot(4,1,1);
        plot((PamMeta.fFCS.Decay_Hist{1}-reconstruction{1})./sqrt(PamMeta.fFCS.Decay_Hist{1}),'LineWidth',2);
        set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',16,'Box','on');
        xlim([1,numel(plotrange)]);
        ylabel('w-res');
        if h.Cor_fFCS.CrossCorr_Checkbox.Value == 1 %%% add second plot
            f = figure('Color',[1,1,1]);f.Position(1) = 300;
            subplot(4,1,2:4);hold on;
            plot(reconstruction{2}); plot(PamMeta.fFCS.Decay_Hist{2});
            set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',16,'YScale','lin','Box','on');
            xlim([1,numel(plotrange)]);
            
            subplot(4,1,1);
            plot((PamMeta.fFCS.Decay_Hist{2}-reconstruction{2})./sqrt(PamMeta.fFCS.Decay_Hist{2}));
            set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',16,'Box','on');
            xlim([1,numel(plotrange)]);
            ylabel('w-res');
        end
    case h.Cor_fFCS.Do_fFCS_Button
        %%% do actual correlation with stored filters
        if isempty(PamMeta.fFCS.filters)
            disp('Define filters first!');
            return;
        end
        Correlate_fFCS([],[]);
    case h.Cor_fFCS.MIPattern_Table
        %%% on change of active/inactive in MIPattern_Table, update the
        %%% species table
        if e.Indices(2) == 2 %%% active column was clicked
            active = cell2mat(h.Cor_fFCS.MIPattern_Table.Data(:,2));
            Names = [PamMeta.fFCS.MIPattern_Name';'Scatter'];
            Names = Names(active);
            h.Cor_fFCS.Cor_fFCS_Table.RowName = Names;
            h.Cor_fFCS.Cor_fFCS_Table.ColumnName = Names;
            h.Cor_fFCS.Cor_fFCS_Table.Data = num2cell(false(numel(Names)));
        end
    case h.Cor_fFCS.PIEchan_Table
        % on change of PIE channel selection, reset calculated
        % filters/plots
    case h.Cor_fFCS.CrossCorr_Checkbox
        if obj.Value == 1
            % add second channel to PIEchan_Table
            h.Cor_fFCS.PIEchan_Table.Data = [h.Cor_fFCS.PIEchan_Table.Data, num2cell(false(size(h.Cor_fFCS.PIEchan_Table.Data,1),1))];
            h.Cor_fFCS.PIEchan_Table.ColumnEditable = [false,true,true];
            % reformat
            h.Cor_fFCS.PIEchan_Table.Units = 'pixels';
            x = h.Cor_fFCS.PIEchan_Table.Position(3);
            h.Cor_fFCS.PIEchan_Table.ColumnWidth = {0.5*x,0.24*x,0.24*x};
            h.Cor_fFCS.PIEchan_Table.Units = 'normalized';
            h.Cor_fFCS.PIEchan_Table.ColumnName = {'Channel','Use for 1','Use for 2'};
        elseif obj.Value == 0
            h.Cor_fFCS.PIEchan_Table.Data = h.Cor_fFCS.PIEchan_Table.Data(:,1:2);
            h.Cor_fFCS.PIEchan_Table.Units = 'pixels';
            x = h.Cor_fFCS.PIEchan_Table.Position(3);
            h.Cor_fFCS.PIEchan_Table.ColumnWidth = {0.8*x,0.18*x};
            h.Cor_fFCS.PIEchan_Table.ColumnName = {'Channel','Use'};
            h.Cor_fFCS.PIEchan_Table.Units = 'normalized';
        end
    case h.Cor_fFCS.MIPattern_Axis_Log
        %%% set YScale to log
        switch obj.Checked
            case 'off'
                obj.Checked = 'on';
                h.Cor_fFCS.MIPattern_Axis.YScale = 'log';
                h.Cor_fFCS.MIPattern_Axis2.YScale = 'log';
            case 'on'
                obj.Checked = 'off';
                h.Cor_fFCS.MIPattern_Axis.YScale = 'lin';
                h.Cor_fFCS.MIPattern_Axis2.YScale = 'lin';
        end
    case h.Cor_fFCS.RLICS_TIFF
        evnt.Key='Eport_RLICS_TIFF';
        Pam_Export([],evnt,[],0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that exports MetaData to txt file %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Save_MetaData(~,~,fid)
global UserValues PamMeta FileInfo PathToApp
%h = guidata(findobj('Tag','Pam'));
if nargin < 3 %%% no file id given, create one
    if strcmp(FileInfo.FileName{1},'Nothing loaded')
        disp('No file loaded.');
        return;
    end    
    [~,FileName,~] = fileparts(FileInfo.FileName{1});
    FilePath = [FileInfo.Path filesep FileName '.txt'];    
    %%% open file
    [fid,err] = fopen(FilePath,'w');
    if fid == -1
        return;
    end
end

%%% write metadata
fprintf(fid,'Filename:\t%s\n',FileInfo.FileName{1});
fprintf(fid,'Recording date:\t%s\n',get_date_modified(FileInfo.Path,FileInfo.FileName{1}));
fprintf(fid,'User:\t\t%s\n',UserValues.MetaData.User);
fprintf(fid,'Comment:\t%s\n\n',UserValues.MetaData.Comment);

fprintf(fid,'Sample:\t\t%s\n',UserValues.MetaData.SampleName);
fprintf(fid,'Buffer:\t\t%s\n',UserValues.MetaData.BufferName);
fprintf(fid,'Exc.Wav.:\t%s\n',UserValues.MetaData.ExcitationWavelengths);
fprintf(fid,'Exc.Pow.[muW]:\t%s\n',UserValues.MetaData.ExcitationPower);
fprintf(fid,'Dyes:\t\t%s\n',UserValues.MetaData.DyeNames);
fprintf(fid,'Meas. Dur.:\t%.2f s\n\n',FileInfo.MeasurementTime);

%%% detector information
fprintf(fid,'Detector Information\n');
%find longest name
maxL = max(cellfun(@numel,UserValues.Detector.Name));
%round to next multiple of 4
maxL = 4*(floor(maxL/4)+1);
fprintf(fid,['Name:' blanks(maxL-5) 'Det#' blanks(1) 'Rout#' blanks(1) 'Filter' blanks(1) 'Pol' blanks(2) 'BS\n']);%header
for i = 1:numel(UserValues.Detector.Det)
    fprintf(fid,['%s' blanks(maxL-numel(UserValues.Detector.Name{i})) '%i' blanks(4) '%i' blanks(5) '%s' blanks(1) '%s' blanks(1) '%s\n'],...
        UserValues.Detector.Name{i},...
        UserValues.Detector.Det(i),...
        UserValues.Detector.Rout(i),...
        UserValues.Detector.Filter{i},...
        UserValues.Detector.Pol{i},...
        UserValues.Detector.BS{i});
end

fprintf(fid,'\n');
%%% profile name
s = load(fullfile(PathToApp,'profiles','Profile.mat'));
fprintf(fid,'Profile name:\t%s\n\n',s.Profile(1:end-4));
%%% PIE channel information
fprintf(fid,'PIE Channel Information\n');
%find longest name
maxL = max(cellfun(@numel,UserValues.PIE.Name));
%round to next multiple of 4
maxL = 4*(floor(maxL/4)+1);
fprintf(fid,['Name:' blanks(maxL-5) 'Det#' blanks(1) 'Rout#' blanks(1) 'From' blanks(1) 'To' blanks(3) 'Background [kHz]\n']);%header
for i = 1:numel(UserValues.PIE.Name)
    fprintf(fid,['%s' blanks(maxL-numel(UserValues.PIE.Name{i})) '%i' blanks(4) '%i' blanks(5) '%i' blanks(5-numel(num2str(UserValues.PIE.From(i)))) '%i' blanks(5-numel(num2str(UserValues.PIE.To(i)))) '%.2f\n'],...
        UserValues.PIE.Name{i},...
        UserValues.PIE.Detector(i),...
        UserValues.PIE.Router(i),...
        UserValues.PIE.From(i),...
        UserValues.PIE.To(i),...
        UserValues.PIE.Background(i));
end
fclose(fid);

function SaveLoadProfile(obj, ~)
global UserValues FileInfo PathToApp
h = guidata(findobj('Tag','Pam'));

if obj == h.Profiles.SaveProfile_Auto
    %%% contextmenu of the save button to automatically save the profile
    if strcmp(h.Profiles.SaveProfile_Auto.Checked,'off')
        UserValues.Settings.Pam.AutoSaveProfile = 'on';
        h.Profiles.SaveProfile_Auto.Checked='on';
    else
        UserValues.Settings.Pam.AutoSaveProfile = 'off';
        h.Profiles.SaveProfile_Auto.Checked='off';
    end
    LSUserValues(1)
    return
end

switch obj
    case h.Profiles.SaveProfile_Button
        if strcmp(FileInfo.FileName{1},'Nothing loaded')
            return;
        end
        % Copies the current profile as "TCSPC filename".pro in the folder of the current TCSPC file');
        [~,FileName,~] = fileparts(FileInfo.FileName{1});
        FullFileName = [FileInfo.Path filesep FileName '.pro'];
        if ~strcmp(FullFileName, GenerateName(FullFileName,1))
            %%% filename already existed
            tmp = dir(FullFileName);
            if datetime('today') == datetime(tmp.date(1:find(isspace(tmp.date))-1))
                %%% if date is the same, overwrite old file
                FullFileName = [FileInfo.Path filesep FileName '.pro'];
            end
        else
            %%% generate index to the filename
            FullFileName = GenerateName(FullFileName,1);
        end
        save(FullFileName,'-struct','UserValues');
    case h.Profiles.LoadProfile_Button
        [File,Path,~] = uigetfile({'*.pro','PAM profile file'},...
            'Choose profile to load...',UserValues.File.Path,'Multiselect','off');
        
        if all (File==0)
            return;
        end
        ProfileData = load(fullfile(Path,File),'-mat');
        ProfileData.MetaData.Comment = ['Source:' fullfile(Path,File)];
        save(fullfile([PathToApp filesep 'profiles'],'Current.mat'),'-struct','ProfileData');
        
        Current_Exists = 0;
        %%% Checks position of the "Current" profile in the list
        for i=1:numel(h.Profiles.List.String)
                if~isempty(strfind(h.Profiles.List.String{i},'<HTML><FONT color=FF0000>'))
                    Line = h.Profiles.List.String{i}(26:(end-14));
                else
                    Line = h.Profiles.List.String{i};
                end
                if strcmp(Line,'Current.mat')
                    Current_Exists = 1;
                    break;
                end
        end
        %%% Sets selected profile to "Current" or creates the "Current"
        %%% profile entry and selects it
        if Current_Exists
            h.Profiles.List.Value = i;
        else
            h.Profiles.List.String{end+1} = 'Current.mat';
            h.Profiles.List.Value = i+1;
        end
        ed.EventName ='KeyPress';
        ed.Key='return';
        Update_Profiles(h.Profiles.List,ed)
end
        
function Open_Doc(~,~)
global PathToApp
% if isunix
%     path = fullfile(PathToApp,'doc/build/html/index.html');
% elseif ispc
%     path = fullfile(PathToApp,'doc\build\html\index.html');
% end
path = 'http://pam.readthedocs.io';
if ~isdeployed
    web(path);
else
    %%% use system call to browser
    %if isunix
    %    % fix spaces in path
    %    path = strrep(path,' ','\ ');
    %end
    web(path,'-browser');
end

function colored_strings = color_string(strings,colors)
%%% takes a cell array of strings and formats them using html to appear as color
colored_strings = cell(numel(strings),1);
for i = 1:numel(strings)
    Hex_color=dec2hex(round(colors(i,:)*255))';
    colored_strings{i} = ['<HTML><FONT color=#' Hex_color(:)' '>' strings{i} '</Font></html>'];
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for various small callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Misc(obj,e,mode)
h=guidata(findobj('Tag','Pam'));
global UserValues FileInfo PamMeta

if nargin <3
    switch obj
        case h.Image.Colorbar.YLabel
            Pixeltime = mean2(diff(FileInfo.LineTimes,1,2))/FileInfo.Pixels*size(FileInfo.LineTimes,1);
            
            if strcmp(h.Image.Colorbar.YLabel.String, 'Counts')
                for i=1:numel(PamMeta.Image)
                    PamMeta.Image{i} = PamMeta.Image{i}/Pixeltime/1000;
                end
                h.Image.Colorbar.YLabel.String = 'Countrate [kHz]';
                h.Plots.Image.CData = h.Plots.Image.CData/Pixeltime/1000;
            else
                for i=1:numel(PamMeta.Image)
                    PamMeta.Image{i} = PamMeta.Image{i}*Pixeltime*1000;
                end
                h.Image.Colorbar.YLabel.String = 'Counts';
                h.Plots.Image.CData = h.Plots.Image.CData*Pixeltime*1000;
            end  
            h.Image.Axes.CLimMode = 'auto';
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to find aggregates in FCS measurement %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [start,stop] = find_aggregates(Data,T,M,A)
global FileInfo
% Data: photon time stamps
% T:    Time window in microseconds
% M:    Number of photons per time window
% A:    enlarge time window (in units of T)
% return: start/stop indices in Data

%%% perform burst search
%%% use minimum number of photons per time window also as minimum number of
%%% photons per burst total (i.e. L=M)
[start, stop] = APBS(Data,T,M,M,1);
inval = false(numel(start),1);
for l = 1:numel(start)
    start(l) = find(Data > (Data(start(l)) - A*T*1E-6/FileInfo.ClockPeriod),1,'first');
    stop(l) = find(Data < (Data(stop(l)) + A*T*1E-6/FileInfo.ClockPeriod),1,'last') + 1;
    if stop(l) >= numel(Data) % we reached the end
        stop(l) = numel(Data);
        if l < numel(start)
            stop((l+1):end) = [];
            start((l+1):end) = [];
            break;
        end
    end
    if l > 1
        if start(l) < stop(l-1)
            start(l) = stop(l-1)+1;
        end
    end
    if start(l) >= stop(l)
        inval(l) = true;
    end
end
start = start(~inval(1:numel(start)));
stop = stop(~inval(1:numel(stop)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Callback to plot preview of aggregate search %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Remove_Aggregates_Preview(obj,~)
global UserValues PamMeta FileInfo TcspcData
h = guidata(obj);
Progress(0,h.Progress.Axes, h.Progress.Text,'Calculating Aggregate Removal Preview...');

cla(h.Cor.Remove_Aggregates_Axes);
[Cor_A,Cor_B]=find(h.Cor.Table.Data(1:end-1,1:end-1));
%valid = Cor_A == Cor_B;
%Cor = Cor_A(valid);
% if isempty(Cor)
%     Progress(1,h.Progress.Axes, h.Progress.Text);
%     return;
% end
if numel(Cor_A) > 1
    Cor_A = Cor_A(1);
    Cor_B = Cor_B(1);
end

Times=ceil(PamMeta.MT_Patch_Times/FileInfo.ClockPeriod);

Det1=UserValues.PIE.Detector(Cor_A);
Rout1=UserValues.PIE.Router(Cor_A);
To1=UserValues.PIE.To(Cor_A);
From1=UserValues.PIE.From(Cor_A);
Name1 = UserValues.PIE.Name{Cor_A};

j = round(str2double(h.Cor.Remove_Aggregate_Block_Edit.String));

Data1=[TcspcData.MT{Det1,Rout1}(...
TcspcData.MI{Det1,Rout1}>=From1 &...
TcspcData.MI{Det1,Rout1}<=To1 &...
TcspcData.MT{Det1,Rout1}>=Times(j) &...
TcspcData.MT{Det1,Rout1}<Times(j+1))-Times(j)];

if Cor_B ~= Cor_A
    Det2=UserValues.PIE.Detector(Cor_B);
    Rout2=UserValues.PIE.Router(Cor_B);
    To2=UserValues.PIE.To(Cor_B);
    From2=UserValues.PIE.From(Cor_B);
    Name2 = UserValues.PIE.Name{Cor_B};
    
    Data2=[TcspcData.MT{Det2,Rout2}(...
    TcspcData.MI{Det2,Rout2}>=From2 &...
    TcspcData.MI{Det2,Rout2}<=To2 &...
    TcspcData.MT{Det2,Rout2}>=Times(j) &...
    TcspcData.MT{Det2,Rout2}<Times(j+1))-Times(j)];
end

T = str2double(h.Cor.Remove_Aggregate_Timewindow_Edit.String)*1000;%in mus
timebin_add = str2double(h.Cor.Remove_Aggregate_TimeWindowAdd_Edit.String);
Nsigma = str2double(h.Cor.Remove_Aggregate_Nsigma_Edit.String);

% get the average countrate of the block
cr = numel(Data1)./Data1(end)./FileInfo.ClockPeriod;
M = T*1E-6*cr;% minimum number of photons in time window
M = round(M + Nsigma*sqrt(M)); %%% add N sigma
                                
[start1, stop1] = find_aggregates(Data1,T,M,timebin_add);
start_times1 = Data1(start1);
stop_times1 = Data1(stop1);

% count rate trace in units of the time bin
[Trace,x] = histcounts(Data1*FileInfo.ClockPeriod,0:T*1E-6:(Data1(end)*FileInfo.ClockPeriod));
trace1 = plot(h.Cor.Remove_Aggregates_Axes,x(1:end-1),Trace,'-b');
%h.Cor.Remove_Aggregates_Axes.YLimMode = 'auto';
scale = h.Cor.Remove_Aggregates_Axes.YScale;
minY = min(Trace);
maxY = 10*max(Trace);
if strcmp(scale,'linear')
    minY = 0;
    h.Cor.Remove_Aggregates_Axes.YLim = [0,max(Trace)];
end
for i = 1:numel(start_times1)
    patch(h.Cor.Remove_Aggregates_Axes,FileInfo.ClockPeriod*[start_times1(i),stop_times1(i),stop_times1(i),start_times1(i)],...
        [minY,minY,maxY,maxY],'b','FaceAlpha',0.3,'EdgeColor','none');
end
%%% add threshold to plot
plot(h.Cor.Remove_Aggregates_Axes,x(1:end-1),(M./(1E-3*T)).*ones(size(x(1:end-1))),'--','Color',[0.3020 0.7490 0.9294]);
    
%%% plot second channel
if Cor_B ~= Cor_A
    % get the average countrate of the block
    cr = numel(Data2)./Data2(end)./FileInfo.ClockPeriod;
    M = T*1E-6*cr;% minimum number of photons in time window
    M = round(M + Nsigma*sqrt(M)); %%% add N sigma
    
    [start2, stop2] = find_aggregates(Data2,T,M,timebin_add);
    start_times2 = Data2(start2);
    stop_times2 = Data2(stop2);
    
    % count rate trace in units of the time bin
    [Trace,x] = histcounts(Data2*FileInfo.ClockPeriod,0:T*1E-6:(Data2(end)*FileInfo.ClockPeriod));
    trace2 = plot(h.Cor.Remove_Aggregates_Axes,x(1:end-1),Trace,'-r');
    %h.Cor.Remove_Aggregates_Axes.XLimMode = 'auto';
    scale = h.Cor.Remove_Aggregates_Axes.YScale;
    minY = min([min(Trace) minY]);
    maxY = 10*max(Trace);
    if strcmp(scale,'linear')
        minY = 0;
        h.Cor.Remove_Aggregates_Axes.YLim = [0,max(Trace)];
    end
    for i = 1:numel(start_times2)
        patch(h.Cor.Remove_Aggregates_Axes,FileInfo.ClockPeriod*[start_times2(i),stop_times2(i),stop_times2(i),start_times2(i)],...
            [minY,minY,maxY,maxY],'r','FaceAlpha',0.3,'EdgeColor','none');
    end
    %%% add threshold to plot
    plot(h.Cor.Remove_Aggregates_Axes,x(1:end-1),(M./(1E-3*T)).*ones(size(x(1:end-1))),'--','Color',[0.8510 0.3294 0.1020]);
end
if (Cor_B == Cor_A)
    legend(trace1,Name1);
else
    legend([trace1,trace2],{Name1,Name2});
end

if (Cor_B == Cor_A)
    Data2 = Data1;
end

if h.Cor.Preview_Correlation_Checkbox.Value
    Progress(0.5,h.Progress.Axes, h.Progress.Text,'Calculating Aggregate Removal Preview...');
    h.Cor.Remove_Aggregates_FCS_Axes.Visible = 'on';
    h.Cor.Remove_Aggregates_Axes.Position(3) = 0.5;
    cla(h.Cor.Remove_Aggregates_FCS_Axes);
    
    %%% do correlation before correction
    MaxTime = max([Data1(end),Data2(end)]);
    [Cor_Before,Cor_Times]=CrossCorrelation({Data1},{Data2},MaxTime);                                        
    
    %%% correct for aggregates
    inval = [];
    for l = 1:numel(start1)
        inval = [inval,start1(l):stop1(l)];
    end
    Data1(inval) = [];
    
    valid_times = (start_times1 < Data1(end)) & (start_times1 > Data1(1));
    start_times1 = start_times1(valid_times);
    stop_times1 = stop_times1(valid_times);
    stop_times1(stop_times1 > Data1(end)) = Data1(end);
    % determine the count rate over the filtered signal
    cr = numel(Data1)./(Data1(end)-sum(start_times1-stop_times1));
    % fill with poisson noise
    for l = 1:numel(start_times1)
        %%% generate noise
        t = start_times1(l);
        while t(end) < stop_times1(l);
            t(end+1) = t(end) + exprnd(1/cr);
        end
        idx = find(Data1 < start_times1(l),1,'last');
        Data1 = [Data1(1:idx); t';Data1((idx+1):end)];
    end
    
    if Cor_B == Cor_A
        Data2 = Data1;
    else %%% do correction for second channel as well
        inval = [];
        for l = 1:numel(start2)
            inval = [inval,start2(l):stop2(l)];
        end
        Data2(inval) = [];
        
        valid_times = (start_times2 < Data2(end)) & (start_times2 > Data2(1));
        start_times2 = start_times2(valid_times);
        stop_times2 = stop_times2(valid_times);
        stop_times2(stop_times2 > Data2(end)) = Data2(end);
        % determine the count rate over the filtered signal
        cr = numel(Data2)./(Data2(end)-sum(start_times2-stop_times2));
        % fill with poisson noise
        for l = 1:numel(start_times2)
            %%% generate noise
            t = start_times2(l);
            while t(end) < stop_times2(l);
                t(end+1) = t(end) + exprnd(1/cr);
            end
            idx = find(Data2 < start_times2(l),1,'last');
            Data2 = [Data2(1:idx); t';Data2((idx+1):end)];
        end
    end
    %%% do correlation after correction
    MaxTime = max([Data1(end),Data2(end)]);
    [Cor_After,Cor_Times]=CrossCorrelation({Data1},{Data2},MaxTime);                 
    Cor_Times = Cor_Times*FileInfo.ClockPeriod;
    average_window = find(Cor_Times > 1e-6,1,'first'); 
    average_window = max([1,(average_window-5)]):min([(average_window+10),numel(Cor_Times)]);
    semilogx(h.Cor.Remove_Aggregates_FCS_Axes,Cor_Times,Cor_Before./mean(Cor_Before(average_window)),'r');
    semilogx(h.Cor.Remove_Aggregates_FCS_Axes,Cor_Times,Cor_After./mean(Cor_After(average_window)),'b');
    legend(h.Cor.Remove_Aggregates_FCS_Axes,'before','after');
    axis(h.Cor.Remove_Aggregates_FCS_Axes,'tight');
    h.Cor.Remove_Aggregates_FCS_Axes.XLim = [1E-6,MaxTime*FileInfo.ClockPeriod/10];
else
    cla(h.Cor.Remove_Aggregates_FCS_Axes);
    h.Cor.Remove_Aggregates_FCS_Axes.Visible = 'off';
    h.Cor.Remove_Aggregates_Axes.Position(3) = 0.9;
    legend(h.Cor.Remove_Aggregates_FCS_Axes,'off');
end
Progress(1);
Update_Display([],[],1);

function Open_Notepad(~,~)
%%% Check whether notepad is open
notepad = findobj('Tag','PAM_Notepad');
if isempty(notepad)
    Notepad('PAM');
else
    figure(notepad);
end

function Rebinmsg(~,~)
b = msgbox('save reference again');
pause(2);
close(b);