function GTauFit(obj,~)
global UserValues GTauData GTauMeta PathToApp
h.GTauFit=findobj('Tag','GTauFit');

addpath(genpath(['.' filesep 'functions']));

if isempty(PathToApp)
    GetAppFolder();
end

addpath(genpath(['.' filesep 'functions']));
LSUserValues(0);
method = '';
%%% If called from command line, or from Launcher
if (nargin < 1 && isempty(gcbo)) || (nargin < 1 && strcmp(get(gcbo,'Tag'),'GTauFit_Launcher'))
    if ~isempty(findobj('Tag','GTauFit'))
        CloseWindow(findobj('Tag','GTauFit'))
    end
    %disp('Call TauFit from Pam or BurstBrowser instead of command line!');
    %return;
    GTauData.Who = 'External';
    method = 'ensemble';
    obj = false;
end

if ~isempty(h.GTauFit)
    % Close TauFit cause it might be called from somewhere else than before
    CloseWindow(h.GTauFit);
end
if ~isempty(findobj('Tag','Pam'))
    ph = guidata(findobj('Tag','Pam'));
end
if ~isempty(findobj('Tag','BurstBrowser'))
    bh = guidata(findobj('Tag','BurstBrowser'));
end

if isempty(h.GTauFit) % Creates new figure, if none exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %%% Disables uitabgroup warning
    warning('off','MATLAB:uitabgroup:OldVersion');   
    %%% Loads user profile    
    [~,~]=LSUserValues(0);
    %%% To save typing
    Look=UserValues.Look;    
    %%% Generates the GTauFit figure
    h.GTauFit = figure(...
        'Units','normalized',...
        'Tag','GTauFit',...
        'Name','Global Decay Analysis',...
        'NumberTitle','off',...
        'Menu','none',...
        'defaultUicontrolFontName',Look.Font,...
        'defaultAxesFontName',Look.Font,...
        'defaultTextFontName',Look.Font,...
        'Toolbar','figure',...
        'UserData',[],...
        'OuterPosition',[0.01 0.1 0.98 0.9],...
        'CloseRequestFcn',@CloseWindow,...
        'Visible','on');
    %h.GTauFit.Visible='off';
    %%% Remove unneeded items from toolbar
    toolbar = findall(h.GTauFit,'Type','uitoolbar');
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
    h.GTauFit.Color=Look.Back;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Menubar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    %%% File menu with loading, saving and exporting functions
    h.File = uimenu(...
        'Parent',h.GTauFit,...
        'Tag','File',...
        'Label','File');
    %%% Menu to load new Dec file
    h.LoadDec = uimenu(h.File,...
        'Tag','LoadDec',...
        'Label','Load New Files',...
        'Callback',{@Load_Dec,1});
    %%% Menu to add Dec files to existing
    h.AddDec = uimenu(h.File,...
        'Tag','AddDec',...
        'Label','Add Files',...
        'Callback',{@Load_Dec,2});
    %%% Menu to load fit function
    h.LoadFit = uimenu(h.File,...
        'Tag','LoadFit',...
        'Label','Load Fit Function',...
        'Callback',{@Load_Fit,1});
    %%% Menu to load fit function
    h.LoadSession = uimenu(h.File,...
        'Tag','LoadSession',...
        'Label','Load GTauFit Session',...
        'Separator','on',...
        'Callback',@LoadSave_Session);
     h.SaveSession = uimenu(h.File,...
        'Tag','SaveSession',...
        'Label','Save GTauFit Session',...
        'Callback',@LoadSave_Session);
    %%% Menu to merge loaded Dec files
    h.MergeDec = uimenu(h.File,...
        'Tag','MergeDec',...
        'Label','Merge Loaded Dec Files',...
        'Separator','on',...
        'Callback',@Merge_Dec);
    
    %%% File menu to stop fitting
    h.AbortFit = uimenu(...
        'Parent',h.GTauFit,...
        'Tag','AbortFit',...
        'Label',' Stop....'); 
    h.StopFit = uimenu(...
        'Parent',h.AbortFit,...
        'Tag','StopFit',...
        'Label','...Fit',...
        'Callback',@Stop_GTauFit);   
    %%% File menu for fitting
    h.StartFit = uimenu(...
        'Parent',h.GTauFit,...
        'Tag','StartFit',...
        'Label','Start...');
    h.DoFit = uimenu(...
        'Parent',h.StartFit,...
        'Tag','Fit',...
        'Label','...Fit',...
        'Callback',@Do_GTauFit);


%% Fitting parameters Tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.FitParams_Tab = uitabgroup(...
        'Parent',h.GTauFit,...
        'Tag','FitParams_Tab',...
        'Units','normalized',...
        'Position',[0.005 0.01 0.99 0.24]);
    %% Fit function tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Tab for fit function inputs
    h.Fit_Function_Tab= uitab(...
        'Parent',h.FitParams_Tab,...
        'Tag','Fit_Function_Tab',...
        'Title','Fit');    
    %%% Panel for fit function inputs
    h.Fit_Function_Panel = uibuttongroup(...
        'Parent',h.Fit_Function_Tab,...
        'Tag','Fit_Function_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    %%% Fitting table
    h.Fit_Table = uitable(...
        'Parent',h.Fit_Function_Panel,...
        'Tag','Fit_Table',...
        'Units','normalized',...
        'ForegroundColor',Look.TableFore,...
        'BackgroundColor',[Look.Table1;Look.Table2],...
        'FontSize',10,...
        'Position',[0 0 1 1],...
        'CellEditCallback',{@Update_Table,3},...
        'CellSelectionCallback',{@Update_Table,3});
    h.Fit_Table_Menu = uicontextmenu;
    h.Fit_Table.UIContextMenu = h.Fit_Table_Menu;
    %%% Button for exporting excel sheet of results
    h.Export_Clipboard = uimenu(...
        'Parent',h.Fit_Table_Menu,...
        'Label','Copy Results to Clipboard',...
        'Callback',{@Plot_Menu_Callback,4});  
    %% Tab containing settings
h.Settings_Tab = uitab(...
    'Parent',h.FitParams_Tab,...
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

h.IRF_Cleanup_Panel = uibuttongroup(...
    'Parent',h.Settings_Panel,...
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
    'Position',[0 0.9 0.1 0.12],...
    'String','Convolution Type',...
    'FontSize',10,...
    'Tag','ConvolutionType_Text');

h.ConvolutionType_Menu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'Position',[0.12 0.9 0.12 0.12],...
    'String',{'linear','circular'},...
    'Value',find(strcmp({'linear','circular'},UserValues.GTauFit.ConvolutionType)),...
    'Tag','ConvolutionType_Menu');

h.LineStyle_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.3 0.9 0.10 0.12],...
    'String','Line Style (Result)',...
    'FontSize',10,...
    'Tag','LineStyle_Text');
h.LineStyle_Menu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'Position',[0.40 0.9 0.10 0.12],...
    'String',{'line','dots'},...
    'Value',find(strcmp({'line','dots'},UserValues.GTauFit.LineStyle)),...
    'Callback',@UpdateOptions,...
    'Tag','LineStyle_Menu');

h.AutoFit_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.02 0.7 0.08 0.12],...
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
    'Position',[0.10 0.7 0.45 0.12],...
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
    'Position',[0.25 0.70 0.45 0.12],...
    'String','Use weighted residuals',...
    'Value',UserValues.GTauFit.use_weighted_residuals,...
    'FontSize',10,...
    'Tag','UseWeightedResiduals_Menu',...
    'Callback',@UpdateOptions);
h.WeightedResidualsType_Menu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'Position',[0.375 0.7 0.10 0.12],...
    'String',{'Gaussian','Poissonian'},...
    'Value',find(strcmp({'Gaussian','Poissonian'},UserValues.GTauFit.WeightedResidualsType)),...
    'Tag','WeightedResidualsType_Menu');
h.MCMC_Error_Estimation_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.02 0.525 0.45 0.12],...0.02 0.7 0.08 0.12
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
    'Position',[0.3 0.525 0.30 0.12],...0.25 0.70 0.45 0.12
    'String','Increase Histogram Binwidth (Faktor):',...
    'FontSize',10,...
    'Tag','Rebin_Histogram_Text');
h.Rebin_Histogram_Edit = uicontrol(...
    'Parent',h.Settings_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.55 0.525 0.15 0.12],...
    'String','1',...
    'FontSize',10,...
    'Tag','Rebin_Histogram_Edit',...
    'Callback',@UpdateOptions);
h.Cleanup_IRF_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.55 0.7 0.45 0.12],...
    'String','Clean up IRF by fitting to Gamma distribution',...
    'Value',UserValues.GTauFit.cleanup_IRF,...
    'FontSize',10,...
    'Tag','Cleanup_IRF_Menu',...
    'Callback',@UpdateOptions);


h.DataSet_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.55 0.9 0.1 0.12],...
    'String','Data Set Selection',...
    'FontSize',10,...
    'Tag','DataSet_Text');


h.DataSet_Menu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'Position',[0.65 0.9 0.12 0.12],...
    'String',{'Nothing selected'},...
    'CallBack',{@Update_Plots,2},...
    'Tag','DataSet_Menu');

h.CommonShift_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.85 0.9 0.45 0.12],...
    'String','Common Decay Shift',...
    'FontSize',10,...
    'Tag','CommonShift_Menu',...
    'Callback',[]);


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

%% %% Settings tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sliders
%%% Define the container
%%%%%%%% CHANGE SLIDER WIDTH AND MOVE TEXT TO MIDDLE OF SLIDER
h.Tau_Parameter_Tab= uitab(...
        'Parent',h.FitParams_Tab,...
        'Tag','Tau_Parameter_Tab',...
        'Title','Curve parameters');    
    
h.Slider_Panel = uibuttongroup(...
    'Parent',h.Tau_Parameter_Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1],...
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
    'FontSize',9,...
    'Callback',@Update_Plots);

h.StartPar_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',9,...
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
    'FontSize',9,...
    'Callback',@Update_Plots);

h.Length_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',9,...
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
    'FontSize',9,...
    'Callback',@Update_Plots);

h.IRFLength_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',9,...
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
    'FontSize',9,...
    'Callback',@Update_Plots);

h.IRFShift_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',9,...
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
    'FontSize',9,...
    'Callback',@Update_Plots);

h.ScatShift_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',9,...
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
    'FontSize',9,...
    'Callback',@Update_Plots);

h.ShiftPer_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',9,...
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
    'FontSize',9,...
    'Callback',@Update_Plots);

h.Ignore_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',9,...
    'String','Ignore Length',...
    'TooltipString','Length of the Ignore Region in the Beginning',...
    'Position',[0.51 0.625 0.1 0.175],...
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
    'FontSize',9,...
    'Callback',@Update_Plots);

h.IRFrelShift_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',9,...
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
    'FontSize',9,...
    'Callback',@Update_Plots);

h.ScatrelShift_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Slider_Panel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'FontSize',9,...
    'String','Perp Scat Shift',...
    'TooltipString','Shift of the Scat perpendicular with respect to the parallel Scat',...
    'Position',[0.51 0.025 0.1 0.175],...
    'Tag','ScatrelShift_Text');



 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% %% %% %% PIE Channel Selection and general Buttons
    
h.PIE_File_Select_Tab= uitab(...
    'Parent',h.FitParams_Tab,...
    'Tag','PIE_Channel_Tab',...
    'Title','Data from PAM');    
    
h.PIEChannel_Panel = uibuttongroup(...
    'Parent',h.PIE_File_Select_Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1],...
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
                GTauData.Who = 'GlobalTauFit';
                % user called TauFit from Pam
                % fit a lifetime from data in a PIE channel
                method = 'ensemble';
            case {ph.Burst.BurstLifetime_Button, ph.Burst.Button}
                GTauData.Who = 'Burstwise';
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
                    'Value',UserValues.GTauFit.IncludeChannel(1),...
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
               %%% hide the ignore slider, we don't need it for burstwise fitting
                set([h.Ignore_Slider,h.Ignore_Edit,h.Ignore_Text],'Visible','off');
                for i = 1:3
                    UserValues.GTauFit.Ignore{i} = 1;
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
%% if strcmp(method,'ensemble')
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
    h.PIEChannelPar_Popupmenu.Value = find(strcmp(UserValues.PIE.Name,UserValues.GTauFit.PIEChannelSelection{1}));
    h.PIEChannelPer_Popupmenu.Value = find(strcmp(UserValues.PIE.Name,UserValues.GTauFit.PIEChannelSelection{2}));
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
        'Position',[0.05 0.52 0.4 0.12],...
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
        'Position',[0.35 0.22 0.5 0.12],...
        'String','Perform reconvolution fit',...
        'Callback',@Start_Fit);
    h.Fit_Button_Menu = uicontextmenu;
    %%% Button for Maximum Entropy Method (MEM) analysis
    h.Fit_Button_MEM_Tau = uimenu('Parent',h.Fit_Button_Menu,...
        'Label','MEM analysis (Lifetime Distribution)',...
        'Checked','off',...
        'Callback',@Start_Fit);
        h.Fit_Button_MEM_dist = uimenu('Parent',h.Fit_Button_Menu,...
        'Label','MEM analysis (Distance Distribution)',...
        'Checked','off',...
        'Callback',@Start_Fit);
    h.Fit_Button.UIContextMenu = h.Fit_Button_Menu;
    h.Fit_Button_MEM_Tau.Visible = 'off'; h.Fit_Button_MEM_dist.Visible = 'off';% only turn visible after a fit has been performed
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
  
    if strcmp(GTauData.Who,'External')
        %%% hide buttons that relate to loading data from PAM
        h.PIEChannelPar_Popupmenu.Value = 1;
        h.PIEChannelPer_Popupmenu.Value = 1;
        h.PIEChannelPar_Popupmenu.String = {''};
        h.PIEChannelPer_Popupmenu.String = {''};
        h.LoadData_Button.String = 'Plot Selection';
        h.LoadData_Button.Enable = 'off';
        h.Menu.Save_To_Dec.Visible = 'off';
    end
if exist('bh','var')
    if bh.SendToTauFit.equals(obj) || obj == bh.Send_to_TauFit_Button
        GTauData.Who = 'BurstBrowser';
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
            case {1,2}
                Channel_String = {'DD','AA','DA','Donor only'};
            case {3,4}
                Channel_String = {'BB','GG','RR'};
            case {5}
                Channel_String = {'DD','AA','DA'};
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
            GTauData.SpeciesName = BurstData{BurstMeta.SelectedFile}.SpeciesNames{BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1),1};
            if BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) > 1 %%% subspecies selected
                GTauData.SpeciesName = [GTauData.SpeciesName ' - ' BurstData{BurstMeta.SelectedFile}.SpeciesNames{BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1),BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2)}];
            end
            str = [str, '\nSelected Species: ' GTauData.SpeciesName];
        else
            GTauData.SpeciesName = BurstData{BurstMeta.SelectedFile}.FileName(1:end-4);
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
            'Value', UserValues.GTauFit.DonorOnlyReferenceSource,...
            'Visible','off',...
            'FontSize',8,...
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
        
        if any(GTauData.BAMethod == [1,2])
            %%% Add menu for Kappa2 simulation
            h.Menu.Extra_Menu = uimenu(h.GTauFit,'Label','Extra...');
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


%% %% %% %%% Edit Boxes for Correction Factors

h.GFactor_Tab = uitab(...
    'Parent',h.FitParams_Tab,...
    'Title','G Factor',...
    'Tag','Settings_Tab');


h.GFactor_Panel = uibuttongroup(...
    'Parent',h.GFactor_Tab,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Back,...
    'HighlightColor',Look.Control,...
    'ShadowColor',Look.Shadow,...
    'Position',[0 0 1 1],...
    'Tag','FitPar_Panel');

h.G_factor_text = uicontrol(...
    'Parent',h.GFactor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.05 0.9 0.35 0.07],...
    'String','G Factor',...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Tag','G_factor_text');

h.G_factor_edit = uicontrol(...
    'Parent',h.GFactor_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.17 0.9 0.2 0.07],...
    'String','1',...
    'FontSize',10,...
    'Tag','G_factor_edit',...
    'Callback',@UpdateOptions);

h.l1_text = uicontrol(...
    'Parent',h.GFactor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.05 0.8 0.35 0.06],...
    'String','l1',...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Tag','l1_text');

h.l1_edit = uicontrol(...
    'Parent',h.GFactor_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.17 0.8 0.2 0.06],...
    'String',num2str(UserValues.GTauFit.l1),...
    'FontSize',10,...
    'Tag','l1_edit',...
    'Callback',@UpdateOptions);

h.l2_text = uicontrol(...
    'Parent',h.GFactor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.35 0.06],...
    'String','l2',...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Tag','l2_text');

h.l2_edit = uicontrol(...
    'Parent',h.GFactor_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.17 0.7 0.2 0.06],...
    'String',num2str(UserValues.GTauFit.l2),...
    'FontSize',10,...
    'Tag','l2_edit',...
    'Callback',@UpdateOptions);

h.Output_Panel = uibuttongroup(...
    'Parent',h.GFactor_Panel,...
    'Units','normalized',...
    'Position',[0.4 0 0.6 1],...
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
    'FontSize',9,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',ToolTip_average_lifetime,...
    'HorizontalAlignment','left',...
    'Tag','Output_Text');


%% Plotting style tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Tab for fit function inputs
    h.Style_Tab= uitab(...
        'Parent',h.FitParams_Tab,...
        'Tag','Style_Tab',...
        'Title','Plotting style');    
    %%% Panel for fit function inputs
    h.Style_Panel = uibuttongroup(...
        'Parent',h.Style_Tab,...
        'Tag','Style_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    
    %%% Fitting table
    h.Style_Table_Menu = uicontextmenu;
    h.Style_Table_Autocolor = uimenu('Parent',h.Style_Table_Menu,'Label','Autocolor',...
        'Callback',{@Update_Style,3});
    h.Style_Table_Rainbow = uimenu('Parent',h.Style_Table_Menu,'Label','Use Rainbow',...
        'Callback',{@Update_Style,3});
    h.Style_Table = uitable(...
        'Parent',h.Style_Panel,...
        'Tag','Fit_Table',...
        'Units','normalized',...
        'ForegroundColor',Look.TableFore,...
        'BackgroundColor',[Look.Table1;Look.Table2],...
        'FontSize',8,...
        'Position',[0 0 1 1],...
        'CellEditCallback',{@Update_Style,2},...
        'CellSelectionCallback',{@Update_Style,2},...
        'UIContextMenu',h.Style_Table_Menu);
    %% File History tab %%%%%%%%%%%%%%%%
    h.Fit_Function_Tab= uitab(...
        'Parent',h.FitParams_Tab,...
        'Tag','Fit_Function_Tab',...
        'Title','File History');
    h.FileHistory = FileHistory(h.Fit_Function_Tab,'GTauFit',@(x) Load_Dec('FileHistory',[],1,x));
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %% Upper tabgroup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.Tabgroup_Up = uitabgroup(...
        'Parent',h.GTauFit,...
        'Tag','MainPlotTab',...
        'Units','normalized',...
        'Position',[0.005 0.26 0.99 0.73]);

%% All tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.AllTab.Tab = uitab(...
        'Parent',h.Tabgroup_Up,...
        'Tag','Tab_All',...
        'Title','All');

%% %% Main Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Panel for fit plots
    h.Fit_Plots_Panel_Global = uibuttongroup(...
        'Parent',h.AllTab.Tab,...
        'Tag','Fit_Plots_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    
    %%% Right-click menu for plot changes
h.Microtime_Plot_Menu_MIPlot = uicontextmenu;
h.Microtime_Plot_ChangeYScaleMenu_MIPlot = uimenu(...
    h.Microtime_Plot_Menu_MIPlot,...
    'Label','Y Logscale',...
    'Checked', UserValues.GTauFit.YScaleLog,...
    'Tag','Plot_YLogscale_MIPlot',...
    'Callback',@ChangeScale);
h.Microtime_Plot_ChangeXScaleMenu_MIPlot = uimenu(...
    h.Microtime_Plot_Menu_MIPlot,...
    'Label','X Logscale',...
    'Checked', UserValues.GTauFit.XScaleLog,...
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
    'Parent',h.Fit_Plots_Panel_Global,...
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
h.Ignore_Plot = plot([0 0],[1e-6 1],'Color','k','Visible','off','LineWidth',1,'DisplayName','Decay (ignore)');
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
    'Parent',h.Fit_Plots_Panel_Global,...
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
    'Parent',h.Fit_Plots_Panel_Global,...
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
    'Parent',h.Fit_Plots_Panel_Global,...
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
    'Parent',h.Fit_Plots_Panel_Global,...
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
    
    
    
%% Single tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% main plot
    h.SingleTab.Tab = uitab(...
        'Parent',h.Tabgroup_Up,...
        'Tag','Tab_Single',...
        'Title','Single');
    
    %% %% Main Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Panel for fit plots
    h.Fit_Plots_Panel = uibuttongroup(...
        'Parent',h.SingleTab.Tab,...
        'Tag','Fit_Plots_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);      
    
    %%% Right-click menu for plot changes
h.Microtime_Plot_Menu_MIPlot = uicontextmenu;
h.Microtime_Plot_ChangeYScaleMenu_MIPlot = uimenu(...
    h.Microtime_Plot_Menu_MIPlot,...
    'Label','Y Logscale',...
    'Checked', UserValues.GTauFit.YScaleLog,...
    'Tag','Plot_YLogscale_MIPlot',...
    'Callback',@ChangeScale);
h.Microtime_Plot_ChangeXScaleMenu_MIPlot = uimenu(...
    h.Microtime_Plot_Menu_MIPlot,...
    'Label','X Logscale',...
    'Checked', UserValues.GTauFit.XScaleLog,...
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
    'Parent',h.Fit_Plots_Panel,...
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
h.Ignore_Plot = plot([0 0],[1e-6 1],'Color','k','Visible','off','LineWidth',1,'DisplayName','Decay (ignore)');
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
    'Parent',h.Fit_Plots_Panel,...
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
    'Parent',h.Fit_Plots_Panel,...
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
    'Parent',h.Fit_Plots_Panel,...
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
    'Parent',h.Fit_Plots_Panel,...
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
%% Mac upscaling of Font Sizes
if ismac
    scale_factor = 1.2;
    fields = fieldnames(h); %%% loop through h structure
    for i = 1:numel(fields)
        if isprop(h.(fields{i}),'FontSize')
            h.(fields{i}).FontSize = (h.(fields{i}).FontSize)*scale_factor;
        end
        if isprop(h.(fields{i}),'Style')
            if strcmp(h.(fields{i}).Style,'popupmenu')
                h.(fields{i}).BackgroundColor = [1 1 1];
                h.(fields{i}).ForegroundColor = [0 0 0];
            end
        end
    end   
end
    
%% Initializes global variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    GTauData=[];
    GTauData.Data=[];
    GTauData.FileName=[];
    GTauMeta=[];
    GTauMeta.Data=[];
    GTauMeta.Params=[];
    GTauMeta.Confidence_Intervals = cell(1,1);
    GTauMeta.Plots=cell(0);
    GTauMeta.Model=[];
    GTauMeta.Fits=[];
    GTauMeta.Color=[1 1 0; 0 0 1; 1 0 0; 0 0.5 0; 1 0 1; 0 1 1];
    GTauMeta.FitInProgress = 0;    
    GTauMeta.DataType = 'GTauFit averaged';
    
    h.CurrentGui = 'GTauFit';
    guidata(h.GTauFit,h); 
    Load_Fit([],[],0);
   
     
else
    figure(h.GTauFit); % Gives focus to Pam figure  
end

function ChangeScale(obj,~)
global UserValues GTauFitData
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
            UserValues.GTauFit.YScaleLog = 'on';
        elseif strcmp(obj.Checked,'on')
            %%% Set Unchecked
            h.Microtime_Plot_ChangeYScaleMenu_MIPlot.Checked = 'off';
            h.Microtime_Plot_ChangeYScaleMenu_ResultPlot.Checked = 'off';
            %%% Change Scale to Lin
            h.Microtime_Plot.YScale = 'lin';
            h.Result_Plot.YScale = 'lin';
            UserValues.GTauFit.YScaleLog = 'off';
        end
        if strcmp(h.Microtime_Plot.YScale,'log')
            %ydat = [h.Plots.IRF_Par.YData,h.Plots.IRF_Per.YData,...
            %    h.Plots.Scat_Par.YData, h.Plots.Scat_Per.YData,...
            %    h.Plots.Decay_Par.YData,h.Plots.Decay_Per.YData];
            ydat = [h.Plots.Decay_Par.YData,h.Plots.Decay_Per.YData];
            ydat = ydat(ydat > 0);
            h.Ignore_Plot.YData = [...
                min(ydat),...
                h.Microtime_Plot.YLim(2)];
        else
            h.Ignore_Plot.YData = [...
                0,...
                h.Microtime_Plot.YLim(2)];
        end
    case {'Plot_XLogscale_MIPlot','Plot_XLogscale_ResultPlot'}
        if strcmp(obj.Checked,'off')
            %%% Set Checked
            h.Microtime_Plot_ChangeXScaleMenu_MIPlot.Checked = 'on';
            h.Microtime_Plot_ChangeXScaleMenu_ResultPlot.Checked = 'on';
            %%% Change Scale to Log
            h.Microtime_Plot.XScale = 'log';
            h.Result_Plot.XScale = 'log';
            UserValues.GTauFit.XScaleLog = 'on';
        elseif strcmp(obj.Checked,'on')
            %%% Set Unchecked
            h.Microtime_Plot_ChangeXScaleMenu_MIPlot.Checked = 'off';
            h.Microtime_Plot_ChangeXScaleMenu_ResultPlot.Checked = 'off';
            %%% Change Scale to Lin
            h.Microtime_Plot.XScale = 'lin';
            h.Result_Plot.XScale = 'lin';
            UserValues.GTauFit.XScaleLog = 'off';
        end
end

LSUserValues(1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to load .Dec files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Dec(obj,~,~,mode,filenames)
global UserValues GTauData GTauMeta
h = guidata(findobj('Tag','GTauFit'));

if nargin > 3 %%% called from file history
    %%% only implemented for loading of *.dec files at the moment, remove
    %%% all other files
    Type = 1;
    %%% split filenames into FileName and pathname
    for j = 1:numel(filenames)
        [PathName{j},FileName{j},ext] = fileparts(filenames{j});
        FileName{j} = [FileName{j} ext];
    end
else
    %%% there is an issue with selecting multiple files on MacOS Catalina,
    %%% where only the first filter (.dec) works, and no other file types 
    %%% can be selected.
    %%% As a workaround, we avoid using the system file selection for now.
    %%% 11/2019    
    if ~ismac | ~(ismac & strcmp(get_macos_version(),'10.15'))
        %%% Choose files to load
        [FileName,path,Type] = uigetfile({'*.dec','Pam decay file (*.dec)'},...
                                          'Choose GlobalTau data files',...
                                          UserValues.File.GTauFitPath,... 
                                          'MultiSelect', 'on');
    else
        %%% use workaround
        %%% Choose files to load
        [FileName, path, Type] = uigetfile_with_preview({'*.dec','Pam decay file (*.dec)'},...
                                          'Choose GlobalTau data files',...
                                          UserValues.File.GTauFitPath,... 
                                          '',... % empty callback
                                          true); % Multiselect on
    end
    %%% Tranforms to cell array, if only one file was selected
    if ~iscell(FileName)
        FileName = {FileName};
    end
    %%% assign path to each filename
    for j = 1:numel(FileName)
        PathName{j} = path;
    end
end


%%% Only esecutes, if at least one file was selected
if all(FileName{1}==0)
    return
end

%%% Saves pathname to uservalues
UserValues.File.GTauFitPath=PathName{1};
LSUserValues(1);
%%% Deletes loaded data

    GTauData=[];
    GTauData.Data=[];
    GTauData.FileName=[];
    cellfun(@delete,GTauMeta.Plots);
    GTauMeta.Data=[];
    GTauMeta.Params=[];
    GTauMeta.Plots=cell(0);
    %h.Fit_Table.RowName(1:end-3)=[];
    h.Fit_Table.Data(1:end-3,:)=[];
    h.Style_Table.RowName(1:end-1,:)=[];
    h.Style_Table.Data(1:end-1,:)=[];

    GTauData.External = struct;
    GTauData.External.MI_Hist = {};
    GTauData.External.IRF = {};
    GTauData.External.Scat = {};



if obj == h.LoadDec
        for j=1:numel(FileName)              
                 %%% read other data
                 decay_data = dlmread(fullfile(path,FileName{j}),'\t',6,0);
                 fid = fopen(fullfile(path,FileName{j}),'r');
                 TAC = textscan(fid,'TAC range [ns]:\t%f\n'); GTauData.TACRange = TAC{1}*1E-9;
                 MI_Bins = textscan(fid,'Microtime Bins:\t%f\n'); GTauData.MI_Bins = MI_Bins{1};
                 TACChannelWidth = textscan(fid,'Resolution [ps]:\t%f\n'); GTauData.TACChannelWidth = TACChannelWidth{1}*1E-3;
                 fid = fopen(fullfile(path,FileName{j}),'r');
               for c = 1:5
                   line = fgetl(fid);
               end
               PIEchans{j} = strsplit(line,'\t');
               PIEchans{j}(cellfun(@isempty,PIEchans{j})) = [];
                if numel(FileName) > 1 %%% multiple files loaded, append the file name to avoid confusion of identically named PIE channels
                   for i = 1:numel(PIEchans{j})
                       PIEchans{j}{i} = [PIEchans{j}{i} ' - ' FileName{j}(1:end-4)];
                   end
               end
              %%% sort data into GTauData structure (MI,IRF,Scat)
              GTauData.External.MI_Hist = {};
              GTauData.External.IRF = {};
              GTauData.External.Scat = {};
               for i = 1:(size(decay_data,2)/3)
                   GTauData.External.MI_Hist{end+1} = decay_data(:,3*(i-1)+1);
                   GTauData.External.IRF{end+1} = decay_data(:,3*(i-1)+2);
                   GTauData.External.Scat{end+1} = decay_data(:,3*(i-1)+3);
               end
               PIEchans = horzcat(PIEchans{:});
               %%% update PIE channel selection with available PIE channels
               h.PIEChannelPar_Popupmenu.String = PIEchans;
               h.PIEChannelPer_Popupmenu.String = PIEchans;
               %%% mark TauFit mode as external
               GTauData.Who = 'External';
               GTauData.FileName{end+1} = FileName{j}(1:end-4);%fullfile(path,FileName{1});
                    if numel(PIEchans) == 1
                        PIEChannel_Par = 1; PIEChannel_Per = 1;
                    else
                        PIEChannel_Par = 1; PIEChannel_Per = 2;
                    end
                    h.PIEChannelPar_Popupmenu.Value = PIEChannel_Par;
                    h.PIEChannelPer_Popupmenu.Value = PIEChannel_Per;  
                    
            
         %%% Creates new plots
            
            GTauMeta.Params(:,end+1) = cellfun(@str2double,h.Fit_Table.Data(end-2,5:3:end-1));
        
        

        
%%% set the channel variable
    chan = 4; GTauData.chan = chan; 
    
            
%%% Microtime Histograms
    GTauData.hMI_Par{j*chan} = GTauData.External.MI_Hist{PIEChannel_Par};
    GTauData.hMI_Per{j*chan} = GTauData.External.MI_Hist{PIEChannel_Per};

%%% Read out the Microtime Histograms of the IRF for the two channels
    GTauData.hIRF_Par{j*chan} = GTauData.External.IRF{PIEChannel_Par}';
    GTauData.hIRF_Per{j*chan} = GTauData.External.IRF{PIEChannel_Per}';
%%% Normalize IRF for better Visibility
    GTauData.hIRF_Par{j*chan} = (GTauData.hIRF_Par{j*chan}./max(GTauData.hIRF_Par{j*chan})).*max(GTauData.hMI_Par{j*chan});
    GTauData.hIRF_Per{j*chan} = (GTauData.hIRF_Per{j*chan}./max(GTauData.hIRF_Per{j*chan})).*max(GTauData.hMI_Per{j*chan});
%%% Read out the Microtime Histograms of the Scatter Measurement for the two channels
    GTauData.hScat_Par{j*chan} = GTauData.External.Scat{PIEChannel_Par}';
    GTauData.hScat_Per{j*chan} = GTauData.External.Scat{PIEChannel_Per}';
%%% Normalize Scatter for better Visibility
    if ~(sum(GTauData.hScat_Par{j*chan})==0)
        GTauData.hScat_Par{j*chan} = (GTauData.hScat_Par{j*chan}./max(GTauData.hScat_Par{j*chan})).*max(GTauData.hMI_Par{j*chan});
    end
    if ~(sum(GTauData.hScat_Per{j*chan})==0)
        GTauData.hScat_Per{j*chan} = (GTauData.hScat_Per{j*chan}./max(GTauData.hScat_Per{j*chan})).*max(GTauData.hMI_Per{j*chan});
    end
%%% Generate XData
    GTauData.XData_Par{j*chan} = 1:numel(GTauData.hMI_Par{j*chan});%ToFromPar - ToFromPar(1);
    GTauData.XData_Per{j*chan} = 1:numel(GTauData.hMI_Per{j*chan});%ToFromPer - ToFromPer(1);
    
%%% Update PIEchannelSelection
    UserValues.GTauFit.PIEChannelSelection{1} = h.PIEChannelPar_Popupmenu.String{h.PIEChannelPar_Popupmenu.Value};
    UserValues.GTauFit.PIEChannelSelection{2} = h.PIEChannelPer_Popupmenu.String{h.PIEChannelPer_Popupmenu.Value};        

%%% Cases to consider:
    %%% obj is empty or is Button for LoadData/LoadIRF
    %%% Data has been changed (PIE Channel changed, IRF loaded...)
    if isempty(obj) || obj == h.LoadData_Button
        %%% find the number of the selected PIE channels
        PIEChannel_Par = find(strcmp(UserValues.PIE.Name,UserValues.GTauFit.PIEChannelSelection{1}));
        PIEChannel_Per = find(strcmp(UserValues.PIE.Name,UserValues.GTauFit.PIEChannelSelection{2}));
        % compare PIE channel selection to burst search selections for
        % consistency between burstwise/ensemble
        % (String comparison does not require correct ordering of PIE channels)
        if any(UserValues.BurstSearch.Method == [1,2]) %2color MFD
            if (strcmp(UserValues.GTauFit.PIEChannelSelection{1},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(1,1)) &&...
                    strcmp(UserValues.GTauFit.PIEChannelSelection{2},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(1,2)))
                chan = 1;
            elseif (strcmp(UserValues.GTauFit.PIEChannelSelection{1},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(3,1)) &&...
                    strcmp(UserValues.GTauFit.PIEChannelSelection{2},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(3,2)))
                chan = 2;
            elseif strcmp(UserValues.GTauFit.PIEChannelSelection{1},UserValues.TauFit.PIEChannelSelection{2})
                %%% identical channels selected
                chan = 5;
            else %%% Set channel to 4 if no MFD channel was selected
                chan = 4;
            end
        elseif any(UserValues.BurstSearch.Method== [3,4]) %3color MFD
            if (strcmp(UserValues.GTauFit.PIEChannelSelection{1},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(1,1)) &&...
                    strcmp(UserValues.GTauFit.PIEChannelSelection{2},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(1,2)))
                chan = 1;
            elseif (strcmp(UserValues.GTauFit.PIEChannelSelection{1},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(4,1)) &&...
                    strcmp(UserValues.GTauFit.PIEChannelSelection{2},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(4,2)))
                chan = 2;
            elseif (strcmp(UserValues.GTauFit.PIEChannelSelection{1},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(6,1)) &&...
                    strcmp(UserValues.GTauFit.PIEChannelSelection{2},UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(6,2)))
                chan = 3;
            elseif strcmp(UserValues.GTauFit.PIEChannelSelection{1},UserValues.GTauFit.PIEChannelSelection{2})
                %%% identical channels selected
                chan = 5;
            else %%% Set channel to 4 if no MFD channel was selected
                chan = 4;
            end
        elseif UserValues.BurstSearch.Method == 5
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
        GTauData.chan = chan;
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
        GTauData.hMI_Par{chan} = PamMeta.MI_Hist{detPar(1)}(...
            UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]) );
        %%% Microtime Histogram of Perpendicular Channel
        GTauData.hMI_Per{chan} = PamMeta.MI_Hist{detPer(1)}(...
            UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]) );

        %%% Read out the Microtime Histograms of the IRF for the two channels
        GTauData.hIRF_Par{chan} = UserValues.PIE.IRF{PIEChannel_Par}(UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]));
        GTauData.hIRF_Per{chan} = UserValues.PIE.IRF{PIEChannel_Per}(UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]));
        %%% Normalize IRF for better Visibility
        GTauData.hIRF_Par{chan} = (GTauData.hIRF_Par{chan}./max(GTauData.hIRF_Par{chan})).*max(GTauData.hMI_Par{chan});
        GTauData.hIRF_Per{chan} = (GTauData.hIRF_Per{chan}./max(GTauData.hIRF_Per{chan})).*max(GTauData.hMI_Per{chan});
        %%% Read out the Microtime Histograms of the Scatter Measurement for the two channels
        GTauData.hScat_Par{chan} = UserValues.PIE.ScatterPattern{PIEChannel_Par}(UserValues.PIE.From(PIEChannel_Par):min([UserValues.PIE.To(PIEChannel_Par) end]));
        GTauData.hScat_Per{chan} = UserValues.PIE.ScatterPattern{PIEChannel_Per}(UserValues.PIE.From(PIEChannel_Per):min([UserValues.PIE.To(PIEChannel_Per) end]));
        %%% Normalize Scatter for better Visibility
        GTauData.hScat_Par{chan} = (GTauData.hScat_Par{chan}./max(GTauData.hScat_Par{chan})).*max(GTauData.hMI_Par{chan});
        GTauData.hScat_Per{chan} = (GTauData.hScat_Per{chan}./max(GTauData.hScat_Per{chan})).*max(GTauData.hMI_Per{chan});
        %%% Generate XData
        GTauData.XData_Par{chan} = (UserValues.PIE.From(PIEChannel_Par):UserValues.PIE.To(PIEChannel_Par)) - UserValues.PIE.From(PIEChannel_Par);
        GTauData.XData_Per{chan} = (UserValues.PIE.From(PIEChannel_Per):UserValues.PIE.To(PIEChannel_Per)) - UserValues.PIE.From(PIEChannel_Per);
    end 

    end
end    
    
    
%%% disable reconvolution fitting if no IRF is defined
if all(isnan(GTauData.hIRF_Par{chan})) || all(isnan(GTauData.hIRF_Per{chan}))
    disp('IRF undefined, disabling reconvolution fitting.');
    h.Fit_Button.Enable = 'off';
elseif all(isnan(GTauData.hScat_Par{chan})) || all(isnan(GTauData.hScat_Per{chan}))
    disp('Scatter pattern undefined, using IRF instead.');
    GTauData.hScat_Par{chan} = GTauData.hIRF_Par{chan};
    GTauData.hScat_Per{chan} = GTauData.hIRF_Per{chan};
else
    h.Fit_Button.Enable = 'on';
end

%%% fix wrong length of IRF or Scatter pattern
len = numel(GTauData.hMI_Par{chan});
if numel(GTauData.hIRF_Par{chan}) < len
    GTauData.hIRF_Par{chan} = [GTauData.hIRF_Par{chan},zeros(1,len-numel(GTauData.hIRF_Par{chan}))];
elseif numel(GTauData.hIRF_Par{chan}) > len
    GTauData.hIRF_Par{chan} = GTauData.hIRF_Par{chan}(1:len);
end
if numel(GTauData.hIRF_Per{chan}) < len
    GTauData.hIRF_Per{chan} = [GTauData.hIRF_Per{chan},zeros(1,len-numel(GTauData.hIRF_Per{chan}))];
elseif numel(GTauData.hIRF_Per{chan}) > len
    GTauData.hIRF_Per{chan} = GTauData.hIRF_Per{chan}(1:len);
end
if numel(GTauData.hScat_Par{chan}) < len
    GTauData.hScat_Par{chan} = [GTauData.hScat_Par{chan},zeros(1,len-numel(GTauData.hScat_Par{chan}))];
elseif numel(GTauData.hScat_Par{chan}) > len
    GTauData.hScat_Par{chan} = GTauData.hScat_Par{chan}(1:len);
end
if numel(GTauData.hScat_Per{chan}) < len
    GTauData.hScat_Per{chan} = [GTauData.hScat_Per{chan},zeros(1,len-numel(GTauData.hScat_Per{chan}))];
elseif numel(GTauData.hScat_Per{chan}) > len
    GTauData.hScat_Per{chan} = GTauData.hScat_Per{chan}(1:len);
end



%%% Updates table and plot data and style to new size

Update_Table([],[],1);
Update_Plots(obj)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to save merged .Dec file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Merge_Dec(~,~)
global UserValues GTauData GTauMeta
h = guidata(findobj('Tag','GTauFit'));

%%% Merge only the active files
active = find(cell2mat(h.Fit_Table.Data(1:end-3,1)));
%%% check for length difference
len = zeros(1,numel(active));
k = 1;
for i = active'
    len(k) = numel(GTauData.Data{i}.Dec_Times);
    k = k+1;
end
minlen = min(len);
minlen_ix = find(len == min(len));

Valid = [];
Dec_Array = [];
Header = cell(0);
Counts = [0,0];
switch GTauMeta.DataType
    case 'GTauFit averaged'
        % multiple averaged file were loaded
        Dec_Times = GTauData.Data{active(minlen_ix(1))}.Dec_Times; % Take Dec_Times from first file, should be same for all.
        for i = active'
            Valid = [Valid, GTauData.Data{i}.Valid];
            Dec_Array = [Dec_Array, GTauData.Data{i}.Dec_Array(1:minlen,:)];
            Header{end+1} = GTauData.Data{i}.Header;
            Counts = Counts + GTauData.Data{i}.Counts;
        end
    case 'GTauFit individual'
        % individual curves from 1 file were loaded
        Dec_Times = GTauMeta.Data{active(minlen_ix(1)),1}; % Take Dec_Times from first file, should be same for all.
        for i = active'
            Valid = [Valid, 1];
            Dec_Array = [Dec_Array, GTauMeta.Data{i,2}(1:minlen,:)];
            Header{end+1} = GTauData.Data{i}.Header;
            Counts = Counts + GTauData.Data{i}.Counts;
        end
end
Counts = Counts./numel(active);

%%% Recalculate Average and SEM
Dec_Average=mean(Dec_Array,2);
%%% Averages files before saving to reduce errorbars
Amplitude=sum(Dec_Array,1);
Dec_Norm=Dec_Array./repmat(Amplitude,[size(Dec_Array,1),1])*mean(Amplitude);
Dec_SEM=std(Dec_Norm,0,2)/sqrt(size(Dec_Array,2));
%%% Pick FileName
[FileName,PathName] = uiputfile({'*.dec'},'Choose a filename for the merged file',fullfile(UserValues.File.GTauFitPath,GTauData.FileName{active(1)}));
if FileName == 0
    m = msgbox('No valid filepath specified... Canceling');
    pause(1);
    delete(m);
    return;
end
Current_FileName = fullfile(PathName,FileName);
%%% Save
save(Current_FileName,'Header','Counts','Valid','Dec_Times','Dec_Average','Dec_SEM','Dec_Array');  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes fit function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Fit(~,~,mode)
global GTauMeta UserValues PathToApp
h = guidata(findobj('Tag','GTauFit'));
FileName=[];
FilterIndex = 1;
if mode
    %% Select a new model to load
    [FileName,PathName,FilterIndex]= uigetfile('.txt', 'Choose a fit model', [PathToApp filesep 'Models']);
    FileName=fullfile(PathName,FileName);
elseif isempty(UserValues.File.GTauFit_Standard) || ~exist(UserValues.File.GTauFit_Standard,'file') 
    %% Opens the first model in the folder at the start of the program
    Models=dir([PathToApp filesep 'Models']);
    Models=Models(~cell2mat({Models.isdir}));
    while isempty(FileName) && ~isempty(Models)
       if strcmp(Models(1).name(end-3:end),'.txt') 
           FileName=[PathToApp filesep 'Models' filesep Models(1).name];
           UserValues.File.GTauFit_Standard=FileName;
       else
           Models(1)=[];
       end
    end
else
    %% Opens last model used before closing program
    FileName=UserValues.File.GTauFit_Standard;
end

if ~isempty(FileName) && ~(FilterIndex == 0)
    UserValues.File.GTauFit_Standard=FileName;
    LSUserValues(1);
    
    %%% change encoding on mac
    if ismac
        feature('DefaultCharacterSet', 'windows-1252');
    end
    %%% Reads in the selected fit function file
    fid = fopen(FileName);
    Text=textscan(fid,'%s', 'delimiter', '\n','whitespace', '');
    Text=Text{1};
    
    %%% Finds line, at which model description starts
    Desc_Start = find(~cellfun(@isempty,strfind(Text,'-MODEL DESCRIPTION-')),1);
    %%% Finds line, at which parameter definition starts
    Param_Start=find(~cellfun(@isempty,strfind(Text,'-PARAMETER DEFINITION-')),1);
    %%% Finds line, at which function definition starts
    Fun_Start=find(~cellfun(@isempty,strfind(Text,'-FIT FUNCTION-')),1);
    B_Start=find(~cellfun(@isempty,strfind(Text,'-BRIGHTNESS DEFINITION-')),1);
    %%% Read model description
    if Param_Start - Desc_Start > 1 %%% at least one line of description
        description = Text(Desc_Start+1:Param_Start-1);
    else
        description = {};
    end
    %%% Defines the number of parameters
    NParams=B_Start-Param_Start-1;
    GTauMeta.NParams = NParams;
    GTauMeta.Model=[];
    GTauMeta.Model.Name=FileName;
    GTauMeta.Model.Description = description;
    GTauMeta.Model.Brightness=Text{B_Start+1};
    %%% Concaternates the function string
    GTauMeta.Model.Function=[];
    for i=Fun_Start+1:numel(Text)
        GTauMeta.Model.Function=[GTauMeta.Model.Function Text(i)];
    end
    GTauMeta.Model.Function=cell2mat(GTauMeta.Model.Function);
    %%% Convert to function handle
    FunctionStart = strfind(GTauMeta.Model.Function,'=');
    eval(['GTauMeta.Model.Function = @(P,x) ' GTauMeta.Model.Function((FunctionStart(1)+1):end) ';']);
    %%% Extracts parameter names and initial values
    GTauMeta.Model.Params=cell(NParams,1);
    GTauMeta.Model.Value=zeros(NParams,1);
    GTauMeta.Model.LowerBoundaries = zeros(NParams,1);
    GTauMeta.Model.UpperBoundaries = zeros(NParams,1);
    GTauMeta.Model.State = zeros(NParams,1);
    %%% Reads parameters and values from file
    for i=1:NParams
        Param_Pos=strfind(Text{i+Param_Start},' ');
        GTauMeta.Model.Params{i}=Text{i+Param_Start}((Param_Pos(1)+1):(Param_Pos(2)-1));
        Start = strfind(Text{i+Param_Start},'=');
        %Stop = strfind(Text{i+Param_Start},';');
        % Filter more specifically (this enables the use of html greek
        % letters like &mu; etc.)
        [~, Stop] = regexp(Text{i+Param_Start},'(\d+;|Inf;)');
        GTauMeta.Model.Value(i) = str2double(Text{i+Param_Start}(Start(1)+1:Stop(1)-1));
        GTauMeta.Model.LowerBoundaries(i) = str2double(Text{i+Param_Start}(Start(2)+1:Stop(2)-1));   
        GTauMeta.Model.UpperBoundaries(i) = str2double(Text{i+Param_Start}(Start(3)+1:Stop(3)-1));
        if numel(Text{i+Param_Start})>Stop(3) && any(strfind(Text{i+Param_Start}(Stop(3):end),'g'))
            GTauMeta.Model.State(i) = 2;
        elseif numel(Text{i+Param_Start})>Stop(3) && any(strfind(Text{i+Param_Start}(Stop(3):end),'f'))
            GTauMeta.Model.State(i) = 1;
        end
    end    
    GTauMeta.Params=repmat(GTauMeta.Model.Value,[1,size(GTauMeta.Data,1)]);
    
    %%% Updates table to new model
    Update_Table([],[],0);
    %%% Updates model text
    [~,name,~] = fileparts(GTauMeta.Model.Name);
    name_text = {'Loaded Fit Model:';name;};
    h.Loaded_Model_Name.String = sprintf('%s\n',name_text{:});
    h.Loaded_Model_Description.String = sprintf('%s\n',description{:});
    h.Loaded_Model_Description.TooltipString = sprintf('%s\n',description{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that updates fit table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Table(~,e,mode)
h = guidata(findobj('Tag','GTauFit'));
global GTauMeta GTauData
switch mode
    case 0 %%% Updates whole table (Load Fit etc.)
        
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];        
        %%% Generates column names and resized them
        Columns=cell(3*numel(GTauMeta.Model.Params)+5,1);
        Columns{1} = '<HTML><b>File</b>';
        Columns{2}='<HTML><b>Active</b>';
        Columns{3}='<HTML><b>Counts [kHz]</b>';
        Columns{4}='<HTML><b>Brightness [kHz]</b>';
        for i=1:numel(GTauMeta.Model.Params)
            Columns{3*i+2}=['<HTML><b>' GTauMeta.Model.Params{i} '</b>'];
            Columns{3*i+3}='<HTML><b>F</b>';
            Columns{3*i+4}='<HTML><b>G</b>';
        end
        Columns{end}='<HTML><b>Chi2</b>';
        ColumnWidth=cell(1,numel(Columns));
        %ColumnWidth(4:3:end-1)=cellfun('length',GTauMeta.Model.Params).*7;
        ColumnWidth(5:3:end-1) = {80};
        %ColumnWidth(ColumnWidth>0 & ColumnWidth<30)=45;
        ColumnWidth(6:3:end-1)={20};
        ColumnWidth(7:3:end-1)={20};
        ColumnWidth(1) = {100};
        ColumnWidth(2)={40};
        ColumnWidth(3)={80};
        ColumnWidth(4)={100};
        ColumnWidth(end)={40};
        h.Fit_Table.ColumnName=Columns;
        h.Fit_Table.ColumnWidth = ColumnWidth;
        %h.Fit_Table.ColumnWidth=num2cell(ColumnWidth');        
        %%% Sets row names to file names 
        Rows=cell(numel(GTauData.Data)+3,1);
        tmp = GTauData.FileName;
        for i = 1:numel(tmp)
            tmp{i} = ['<HTML><b>' tmp{i} '</b>'];
        end
        Rows(1:numel(GTauData.Data))=deal(tmp);
        Rows{end-2}='<HTML><b>ALL</b>';
        Rows{end-1}='<HTML><b>Lower bound</b>';
        Rows{end}='<HTML><b>Upper bound</b>';
        h.Fit_Table.RowName=[];         
        %%% Creates table data:
        %%% 1: Checkbox to activate/deactivate files
        %%% 2: Countrate of file
        %%% 3: Brightness if file
        %%% 4:3:end: Parameter value
        %%% 5:3:end: Checkbox to fix parameter
        %%% 6:3:end: Checkbox to fit parameter globaly
        Data=num2cell(zeros(numel(Rows),numel(Columns)-1));
        for i=1:(numel(Rows)-3)
            %%% Distinguish between Autocorrelation (only take Counts of
            %%% Channel) and Crosscorrelation (take sum of Channels)
            if GTauData.Data{i}.Counts(1) == GTauData.Data{i}.Counts(2)
                %%% Autocorrelation
                Data{i,2}=num2str(GTauData.Data{i}.Counts(1));
            elseif GTauData.Data{i}.Counts(1) ~= GTauData.Data{i}.Counts(2)
                %%% Crosscorrelation
                Data{i,2}=num2str(sum(GTauData.Data{i}.Counts));
            end
        end
        Data(1:end-3,4:3:end-1)=deal(num2cell(GTauMeta.Params)');
        Data(end-2,4:3:end-1)=deal(num2cell(GTauMeta.Model.Value)');
        Data(end-1,4:3:end-1)=deal(num2cell(GTauMeta.Model.LowerBoundaries)');
        Data(end,4:3:end-1)=deal(num2cell(GTauMeta.Model.UpperBoundaries)');
        %Data=cellfun(@num2str,Data,'UniformOutput',false);
        Data(1:end-2,5:3:end-1) = repmat(num2cell(GTauMeta.Model.State==1)',size(Data,1)-2,1);        
        Data(end-1:end,5:3:end-1)=deal({[]});
        Data(1:end-2,6:3:end-1) = repmat(num2cell(GTauMeta.Model.State==2)',size(Data,1)-2,1);
        Data(end-1:end,6:3:end-1)=deal({[]});
        Data(1:end-2,1)=deal({true});
        Data(end-1:end,1)=deal({[]});
        Data(1:end-2,end)=deal({'0'});
        Data(end-1:end,end)=deal({[]});
        h.Fit_Table.Data=[Rows,Data];
        h.Fit_Table.ColumnEditable=[false,true,false,false,true(1,numel(Columns)-5),false];  
        h.Fit_Table.ColumnWidth(1) = {7*max(cellfun('prodofsize',Rows))};
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 1 %%% Updates tables when new data is loaded
        h.Fit_Table.CellEditCallback=[];
        %%% Sets row names to file names
        Rows=cell(numel(GTauData.FileName)+3,1);
        tmp = GTauData.FileName;

        Rows(1:numel(tmp))=deal(tmp);
        Rows{end-2}='ALL';
        Rows{end-1}='Lower bound';
        Rows{end}='Upper bound';
        %h.Fit_Table.RowName=Rows;
        
        Data=cell(numel(Rows),size(h.Fit_Table.Data,2)-1);
        %%% Set last 3 row to ALL, lb and ub
        Data(1:(size(h.Fit_Table.Data,1)-3),:)=h.Fit_Table.Data(1:end-3,2:end);
        
        %%% Sets previous files
        Data(end-2:end,:)=h.Fit_Table.Data(end-2:end,2:end);
        %%% Adds new files
        Data((size(h.Fit_Table.Data,1)-2):(end-3),:)=repmat(h.Fit_Table.Data(end-2,2:end),[numel(Rows)-(size(h.Fit_Table.Data,1)),1]);
        %%% Calculates countrate
        %for i=1:numel(GTauData)
            %%% Distinguish between Autocorrelation (only take Counts of
            %%% Channel) and Crosscorrelation (take sum of Channels)
            %if GTauData.Data{i}.Counts(1) == GTauData.Data{i}.Counts(2)
                %%% Autocorrelation
                %Data{i,2}=num2str(GTauData.Data{i}.Counts(1));
            %elseif GTauData.Data{i}.Counts(1) ~= GTauData.Data{i}.Counts(2)
                %%% Crosscorrelation
                %Data{i,2}=num2str(sum(GTauData.Data{i}.Counts));
            %end
        %end
        
        
        h.Fit_Table.Data=[Rows,Data];
        h.Fit_Table.ColumnWidth(1) = {7*max(cellfun('prodofsize',Rows))};
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 2 %%% Updates table after fit
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        %%% Updates Brightness in Table
        for i=1:(size(h.Fit_Table.Data,1)-3)
            P=GTauMeta.Params(:,i);
            eval(GTauMeta.Model.Brightness);
            h.Fit_Table.Data{i,4}= num2str(str2double(h.Fit_Table.Data{i,3}).*B);
        end
        %%% Updates parameter values in table
        h.Fit_Table.Data(1:end-3,5:3:end-1)=cellfun(@num2str,num2cell(GTauMeta.Params)','UniformOutput',false);
        %%% Updates plots
        %Update_Plots        
        %%% Enables cell callback again        
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 3 %%% Individual cells callbacks
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];        
        if strcmp(e.EventName,'CellSelection') %%% No change in Value, only selected
            %%% detect click of "All" row, in which case the callback
            %%% should finish to update the values
            %%% problem in 2018a: Updating the other values causes the cell
            %%% selection to drop, making it impossible to set another
            %%% value.
            %%% The "All" row thus only updates if the user types a
            %%% different value, causing the EditCallback to fire.
            if ~isempty(e.Indices) && e.Indices(1) == size(h.Fit_Table.Data,1)-2
                %NewData = h.Fit_Table.Data{e.Indices(1),e.Indices(2)};
                h.Fit_Table.CellEditCallback={@Update_Table,3};
                return;
            else
                if isempty(e.Indices) % sometime, indices is empty
                    h.Fit_Table.CellEditCallback={@Update_Table,3};
                    return;
                end
                %%% if a lower boundary/upperboundary field of a logical
                %%% quantity was clicked (i.e. active/fixed/global)
                %%% make sure to deselect the field to prevent the user
                %%% from typing a value
                deselect = 0;
                if e.Indices(1) > size(h.Fit_Table.Data,1)-2 %%% clicked lb/ub field
                    if e.Indices(2) == 2 %%% clicked the "active" column
                        deselect = 1;
                    elseif e.Indices(2) == size(h.Fit_Table.Data,2) % clicked chi2 field
                        deselect = 1;
                    elseif mod(e.Indices(2)-5,3) ~= 0 % clicked fixed or global field
                        deselect = 1;
                    end
                end
                if deselect
                    %%% deselection of field is only possible by assigning
                    %%% a dummy to the data and re-assigning the original
                    %%% data afterwards
                    temp = h.Fit_Table.Data;
                    h.Fit_Table.Data = repmat({'dummy'},size(h.Fit_Table.Data));
                    h.Fit_Table.Data = temp;
                end
                %%% re-assign callback and exit
                h.Fit_Table.CellEditCallback={@Update_Table,3};
                return;
            end
            % previously, the following code was called that caused the GUI to get stuck in version 2018a and upwards
            %if isempty(e.Indices) || (e.Indices(1)~=(size(h.Fit_Table.Data,1)-2) && e.Indices(2)~=1)
            %    h.Fit_Table.CellEditCallback={@Update_Table,3};
            %    return;
            %end
            %NewData = h.Fit_Table.Data{e.Indices(1),e.Indices(2)};
        end
        if isprop(e,'NewData')
            NewData = e.NewData;
        end

        if e.Indices(1)==size(h.Fit_Table.Data,1)-2
            %% ALL row wase used => Applies to all files
            if e.Indices(2) > 1 %%% don't execute for name column
                h.Fit_Table.Data(1:end-2,e.Indices(2))=deal({NewData});
                if mod(e.Indices(2)-5,3)==0 && e.Indices(2)>=5
                    %% Value was changed => Apply value to global variables
                    GTauMeta.Params((e.Indices(2)-2)/3,:)=str2double(NewData);
                elseif mod(e.Indices(2)-6,3)==0 && e.Indices(2)>=6 && NewData==1
                    %% Value was fixed => Uncheck global
                    h.Fit_Table.Data(1:end-2,e.Indices(2)+1)=deal({false});
                elseif mod(e.Indices(2)-7,3)==0 && e.Indices(2)>=7 && NewData==1
                    %% Global was change
                    %%% Apply value to all files
                    h.Fit_Table.Data(1:end-2,e.Indices(2)-2)=h.Fit_Table.Data(e.Indices(1),e.Indices(2)-2);
                    %%% Apply value to global variables
                    GTauMeta.Params((e.Indices(2)-4)/3,:)=str2double(h.Fit_Table.Data{e.Indices(1),e.Indices(2)-2});
                    %%% Unfixes all files to prohibit fixed and global
                    h.Fit_Table.Data(1:end-2,e.Indices(2)-1)=deal({false});
                end
            end
        elseif mod(e.Indices(2)-7,3)==0 && e.Indices(2)>=7 && e.Indices(1)<size(h.Fit_Table.Data,1)-1
            %% Global was changed => Applies to all files
            h.Fit_Table.Data(1:end-2,e.Indices(2))=deal({NewData});
            if NewData
                %%% Apply value to all files
                h.Fit_Table.Data(1:end-2,e.Indices(2)-2)=h.Fit_Table.Data(e.Indices(1),e.Indices(2)-2);
                %%% Apply value to global variables
                GTauMeta.Params((e.Indices(2)-4)/3,:)=str2double(h.Fit_Table.Data{e.Indices(1),e.Indices(2)-2});
                %%% Unfixes all file to prohibit fixed and global
                h.Fit_Table.Data(1:end-2,e.Indices(2)-1)=deal({false});
            end
        elseif mod(e.Indices(2)-6,3)==0 && e.Indices(2)>=6 && e.Indices(1)<size(h.Fit_Table.Data,1)-1
            %% Value was fixed
            %%% Updates ALL row
            if all(cell2mat(h.Fit_Table.Data(1:end-3,e.Indices(2))))
                h.Fit_Table.Data{end-2,e.Indices(2)}=true;
            else
                h.Fit_Table.Data{end-2,e.Indices(2)}=false;
            end
            %%% Unchecks global to prohibit fixed and global
            h.Fit_Table.Data(1:end-2,e.Indices(2)+1)=deal({false;});
        elseif mod(e.Indices(2)-5,3)==0 && e.Indices(2)>=5 && e.Indices(1)<size(h.Fit_Table.Data,1)-1
            %% Value was changed
            if h.Fit_Table.Data{e.Indices(1),e.Indices(2)+2}
                %% Global => changes value of all files
                h.Fit_Table.Data(1:end-2,e.Indices(2))=deal({NewData});
                GTauMeta.Params((e.Indices(2)-2)/3,:)=str2double(NewData);
            else
                %% Not global => only changes value
                GTauMeta.Params((e.Indices(2)-2)/3,e.Indices(1))=str2double(NewData);
                
            end
        elseif e.Indices(2)==1
            %% Active was changed
            a = 1;
        end       
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
end


Active = cell2mat(h.Fit_Table.Data(1:end-3,2));
if isempty(Active)
    Active = 0;
end

if Active == 0
    %% Clears 2D plot, if all are inactive
    %     h.Plots.Main.ZData = zeros(2);
    %     h.Plots.Main.CData = zeros(2,2,3);
    %     h.Plots.Fit.ZData = zeros(2);
    %     h.Plots.Fit.CData = zeros(2,2,3);
    h.DataSet_Menu.String = {'Nothing selected'};
else %% Updates 2D plot selection string
    h.DataSet_Menu.String = GTauData.FileName(Active);
    if h.DataSet_Menu.Value>numel(h.DataSet_Menu.String)
        h.DataSet_Menu.Value = 1;
    end
end    


%%% Updates plots to changes models

Update_Plots(mode)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  General Function to Update Plots when something changed %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(obj,~,mode)
global UserValues GTauData
h = guidata(findobj('Tag','GTauFit'));

h.subresolution = 10;
G = str2double(h.G_factor_edit.String);
l1 = str2double(h.l1_edit.String);
l2 = str2double(h.l2_edit.String);

if ~isprop(obj, 'Style')
    dummy = '';
else
    dummy = obj.Style;
end

if obj == h.FitParams_Tab
    dummy = 'table'; 
end



Active = cell2mat(h.Fit_Table.Data(1:end-3,2));
if Active == 1
if isempty(obj) || strcmp(dummy,'pushbutton') || strcmp(dummy,'popupmenu') || isempty(dummy) || obj == h.Rebin_Histogram_Edit
    %LoadData button or Burstwise lifetime button was pressed
    %%% Plot the Data
    % nanoseconds per microtime bin
    
    
    
    b = h.DataSet_Menu.Value;
    TACtoTime = GTauData.TACChannelWidth;%1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
    
    h.Plots.Decay_Par.XData = GTauData.XData_Par{b*GTauData.chan}*TACtoTime; 
    h.Plots.Decay_Per.XData = GTauData.XData_Per{b*GTauData.chan}*TACtoTime; 
    h.Plots.IRF_Par.XData = GTauData.XData_Par{b*GTauData.chan}*TACtoTime;
    h.Plots.IRF_Per.XData = GTauData.XData_Per{b*GTauData.chan}*TACtoTime;
    h.Plots.Scat_Par.XData = GTauData.XData_Par{b*GTauData.chan}*TACtoTime;
    h.Plots.Scat_Per.XData = GTauData.XData_Per{b*GTauData.chan}*TACtoTime;
    h.Plots.Decay_Par.YData = GTauData.hMI_Par{b*GTauData.chan};
    h.Plots.Decay_Per.YData = GTauData.hMI_Per{b*GTauData.chan};
    h.Plots.IRF_Par.YData = GTauData.hIRF_Par{b*GTauData.chan};
    h.Plots.IRF_Per.YData = GTauData.hIRF_Per{b*GTauData.chan};
    h.Plots.Scat_Par.YData = GTauData.hScat_Par{b*GTauData.chan};
    h.Plots.Scat_Per.YData = GTauData.hScat_Per{b*GTauData.chan};

    h.Microtime_Plot.XLim = [min([GTauData.XData_Par{b*GTauData.chan}*TACtoTime GTauData.XData_Per{b*GTauData.chan}*TACtoTime]) max([GTauData.XData_Par{b*GTauData.chan}*TACtoTime GTauData.XData_Per{b*GTauData.chan}*TACtoTime])];
    
    try
        h.Microtime_Plot.YLim = [min([GTauData.hMI_Par{b*GTauData.chan}; GTauData.hMI_Per{b*GTauData.chan}]) 10/9*max([GTauData.hMI_Par{b*GTauData.chan}; GTauData.hMI_Per{b*GTauData.chan}])];
    catch
        % if there is no data, disable channel and stop
        h.IncludeChannel_checkbox.Value = 0;
        UserValues.GTauFit.IncludeChannel(h.ChannelSelect_Popupmenu.Value) = 0;
        LSUserValues(1);
        return
    end
%%% Define the Slider properties
%%% Values to consider:
%%% The length of the shortest PIE channel
GTauData.MaxLength{b*GTauData.chan} = min([numel(GTauData.hMI_Par{b*GTauData.chan}) numel(GTauData.hMI_Per{b*GTauData.chan})]);
    
    %%% The Length Slider defaults to the length of the shortest PIE
    %%% channel and should not assume larger values
    h.Length_Slider.Min = 1;
    h.Length_Slider.Max = GTauData.MaxLength{b*GTauData.chan};
    h.Length_Slider.SliderStep =[1, 10]*(1/(h.Length_Slider.Max-h.Length_Slider.Min));
    if UserValues.GTauFit.Length{b*GTauData.chan} > 0 && UserValues.GTauFit.Length{b*GTauData.chan} < GTauData.MaxLength{b*GTauData.chan}+1
        tmp = UserValues.GTauFit.Length{b*GTauData.chan};
    else
        tmp = GTauData.MaxLength{b*GTauData.chan};
    end
    h.Length_Slider.Value = tmp;
    GTauData.Length{b*GTauData.chan} = tmp;
    h.Length_Edit.String = num2str(tmp);
    
    %%% Start Parallel Slider can assume values from 0 (no shift) up to the
    %%% length of the shortest PIE channel minus the set length
    h.StartPar_Slider.Min = 0;
    h.StartPar_Slider.Max = floor(GTauData.MaxLength{GTauData.chan}/5);
    h.StartPar_Slider.SliderStep =[1, 10]*(1/(h.StartPar_Slider.Max-h.StartPar_Slider.Min));
    if UserValues.GTauFit.StartPar{GTauData.chan} >= 0 && UserValues.GTauFit.StartPar{GTauData.chan} <= floor(GTauData.MaxLength{GTauData.chan}/5)
        tmp = UserValues.GTauFit.StartPar{GTauData.chan};
    else
        tmp = 0;
    end
    h.StartPar_Slider.Value = tmp;
    GTauData.StartPar{GTauData.chan} = tmp;
    h.StartPar_Edit.String = num2str(tmp);
    
    %%% Shift Perpendicular Slider can assume values from the difference in
    %%% start point between parallel and perpendicular up to the difference
    %%% between the end point of the parallel channel and the start point
    %%% of the perpendicular channel
    h.ShiftPer_Slider.Min = -floor(GTauData.MaxLength{GTauData.chan}/20);
    h.ShiftPer_Slider.Max = floor(GTauData.MaxLength{GTauData.chan}/20);
    %%% Note: (!)
    %%% While shift of < 1 (e.g. 0.1) are in principle possible, they
    %%% change the noise characteristics and thus the obtained chi2 is
    %%% wrong!
    h.ShiftPer_Slider.SliderStep = [1, 10]*(1/(h.ShiftPer_Slider.Max-h.ShiftPer_Slider.Min));%[0.1, 1]*(1/(h.ShiftPer_Slider.Max-h.ShiftPer_Slider.Min));
    if UserValues.GTauFit.ShiftPer{GTauData.chan} >= -floor(GTauData.MaxLength{GTauData.chan}/20)...
            && UserValues.GTauFit.ShiftPer{GTauData.chan} <= floor(GTauData.MaxLength{GTauData.chan}/20)
        tmp = round(UserValues.GTauFit.ShiftPer{GTauData.chan});
    else
        tmp = 0;
    end
    h.ShiftPer_Slider.Value = tmp;
    GTauData.ShiftPer{GTauData.chan} = tmp;
    h.ShiftPer_Edit.String = num2str(tmp);

    %%% IRF Length has the same limits as the Length property
    h.IRFLength_Slider.Min = 1;
    h.IRFLength_Slider.Max = GTauData.MaxLength{GTauData.chan};
    h.IRFLength_Slider.SliderStep =[1, 10]*(1/(h.IRFLength_Slider.Max-h.IRFLength_Slider.Min));
    if UserValues.GTauFit.IRFLength{GTauData.chan} >= 0 && UserValues.GTauFit.IRFLength{GTauData.chan} <= GTauData.MaxLength{GTauData.chan}
        tmp = UserValues.GTauFit.IRFLength{GTauData.chan};
    else
        tmp = GTauData.MaxLength{GTauData.chan};
    end
    h.IRFLength_Slider.Value = tmp;
    GTauData.IRFLength{GTauData.chan} = tmp;
    h.IRFLength_Edit.String = num2str(tmp);
    
    %%% IRF Shift has the same limits as the perp shift property
    h.IRFShift_Slider.Min = -floor(GTauData.MaxLength{GTauData.chan}/20);
    h.IRFShift_Slider.Max = floor(GTauData.MaxLength{GTauData.chan}/20);
    h.IRFShift_Slider.SliderStep =[0.1, 1]*(1/(h.IRFShift_Slider.Max-h.IRFShift_Slider.Min));
    tmp = UserValues.GTauFit.IRFShift{GTauData.chan};
    
    limit_IRF_range = false; % reset to 0 if IRFshift does not make sense
    if limit_IRF_range
        if UserValues.GTauFit.IRFShift{GTauData.chan} >= -floor(GTauData.MaxLength{GTauData.chan}/20)...
                && UserValues.GTauFit.IRFShift{GTauData.chan} <= floor(GTauData.MaxLength{GTauData.chan}/20)
            tmp = UserValues.GTauFit.IRFShift{GTauData.chan};
        else
            tmp = 0;
        end
    end
    
    h.IRFShift_Slider.Value = tmp;
    GTauData.IRFShift{GTauData.chan} = tmp;
    h.IRFShift_Edit.String = num2str(tmp);
    
    %%% IRF rel. Shift has the same limits as the perp shift property
    h.IRFrelShift_Slider.Min = -floor(GTauData.MaxLength{GTauData.chan}/20);
    h.IRFrelShift_Slider.Max = floor(GTauData.MaxLength{GTauData.chan}/20);
    h.IRFrelShift_Slider.SliderStep =[0.1, 1]*(1/(h.IRFrelShift_Slider.Max-h.IRFrelShift_Slider.Min));
    if UserValues.GTauFit.IRFrelShift{GTauData.chan} >= -floor(GTauData.MaxLength{GTauData.chan}/20)...
            && UserValues.GTauFit.IRFrelShift{GTauData.chan} <= floor(GTauData.MaxLength{GTauData.chan}/20)
        tmp = UserValues.GTauFit.IRFrelShift{GTauData.chan};
    else
        tmp = 0;
    end
    h.IRFrelShift_Slider.Value = tmp;
    GTauData.IRFrelShift{GTauData.chan} = tmp;
    h.IRFrelShift_Edit.String = num2str(tmp);
    
    %%% Scat Shift has the same limits as the perp shift property
    h.ScatShift_Slider.Min = -floor(GTauData.MaxLength{GTauData.chan}/20);
    h.ScatShift_Slider.Max = floor(GTauData.MaxLength{GTauData.chan}/20);
    h.ScatShift_Slider.SliderStep =[0.1, 1]*(1/(h.ScatShift_Slider.Max-h.ScatShift_Slider.Min));
    if UserValues.GTauFit.ScatShift{GTauData.chan} >= -floor(GTauData.MaxLength{GTauData.chan}/20)...
            && UserValues.GTauFit.ScatShift{GTauData.chan} <= floor(GTauData.MaxLength{GTauData.chan}/20)
        tmp = UserValues.GTauFit.ScatShift{GTauData.chan};
    else
        tmp = 0;
    end
    h.ScatShift_Slider.Value = tmp;
    GTauData.ScatShift{GTauData.chan} = tmp;
    h.ScatShift_Edit.String = num2str(tmp);
    
    %%% Scat rel. Shift has the same limits as the perp shift property
    h.ScatrelShift_Slider.Min = -floor(GTauData.MaxLength{GTauData.chan}/20);
    h.ScatrelShift_Slider.Max = floor(GTauData.MaxLength{GTauData.chan}/20);
    h.ScatrelShift_Slider.SliderStep =[0.1, 1]*(1/(h.ScatrelShift_Slider.Max-h.ScatrelShift_Slider.Min));
    if UserValues.GTauFit.ScatrelShift{GTauData.chan} >= -floor(GTauData.MaxLength{GTauData.chan}/20)...
            && UserValues.GTauFit.ScatrelShift{GTauData.chan} <= floor(GTauData.MaxLength{GTauData.chan}/20)
        tmp = UserValues.GTauFit.ScatrelShift{GTauData.chan};
    else
        tmp = 0;
    end
    h.ScatrelShift_Slider.Value = tmp;
    GTauData.ScatrelShift{GTauData.chan} = tmp;
    h.ScatrelShift_Edit.String = num2str(tmp);
    
    %%% Ignore Slider reaches from 1 to maximum length
    h.Ignore_Slider.Min = 1;
    h.Ignore_Slider.Max = floor(GTauData.MaxLength{GTauData.chan}/5);
    h.Ignore_Slider.SliderStep =[1, 10]*(1/(h.Ignore_Slider.Max-h.Ignore_Slider.Min));
    if UserValues.GTauFit.Ignore{GTauData.chan} >= 1 && UserValues.GTauFit.Ignore{GTauData.chan} <= floor(GTauData.MaxLength{GTauData.chan}/5)
        tmp = UserValues.GTauFit.Ignore{GTauData.chan};
    else
        tmp = 1;
    end
    h.Ignore_Slider.Value = tmp;
    GTauData.Ignore{GTauData.chan} = tmp;
    h.Ignore_Edit.String = num2str(tmp);
    
    % when the popup has changed, the table has to be updated with the
    % UserValues data
  % h.FitPar_Table.Data = GetTableData(h.FitMethod_Popupmenu.Value, chan);
    % G factor is channel specific
    h.G_factor_edit.String = UserValues.GTauFit.G{GTauData.chan};
else
    TACtoTime = GTauData.TACChannelWidth;%1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
end


%%% Update Slider Values
if isobject(obj) % check if matlab object
    switch obj
        case {h.StartPar_Slider, h.StartPar_Edit}
            if obj == h.StartPar_Slider
                GTauData.StartPar{GTauData.chan} = floor(obj.Value);
            elseif obj == h.StartPar_Edit
                GTauData.StartPar{GTauData.chan} = floor(str2double(obj.String));
                obj.String = num2str(GTauData.StartPar{GTauData.chan});
            end
        case {h.Length_Slider, h.Length_Edit}
            %%% Update Value
            if obj == h.Length_Slider
                GTauData.Length{GTauData.chan} = floor(obj.Value);
            elseif obj == h.Length_Edit
                GTauData.Length{GTauData.chan} = floor(str2double(obj.String));
                obj.String = num2str(GTauData.Length{GTauData.chan});
            end
            %%% Correct if IRFLength exceeds the Length
            if GTauData.IRFLength{GTauData.chan} > GTauData.Length{GTauData.chan}
                GTauData.IRFLength{GTauData.chan} = GTauData.Length{GTauData.chan};
                h.IRFLength_Edit.String = num2str(GTauData.IRFLength{GTauData.chan});
                h.IRFLength_Slider.Value = GTauData.IRFLength{GTauData.chan};
            end
        case {h.ShiftPer_Slider, h.ShiftPer_Edit}
            %%% Update Value
            %%% Note: (!)
            %%% While shifts of < 1 (e.g. 0.1) are in principle possible, they
            %%% change the noise characteristics and thus the obtained chi2 is
            %%% wrong!
            if obj == h.ShiftPer_Slider
                GTauData.ShiftPer{GTauData.chan} = floor(obj.Value);%round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.ShiftPer_Edit
                GTauData.ShiftPer{GTauData.chan} = floor(str2double(obj.String));%round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(GTauData.ShiftPer{GTauData.chan});
            end
        case {h.IRFLength_Slider, h.IRFLength_Edit}
            %%% Update Value
            if obj == h.IRFLength_Slider
                GTauData.IRFLength{GTauData.chan} = floor(obj.Value);
            elseif obj == h.IRFLength_Edit
                GTauData.IRFLength{GTauData.chan} = floor(str2double(obj.String));
                obj.String = num2str(GTauData.IRFLength{GTauData.chan});
            end
            %%% Correct if IRFLength exceeds the Length
            if GTauData.IRFLength{GTauData.chan} > GTauData.Length{GTauData.chan}
                GTauData.IRFLength{GTauData.chan} = GTauData.Length{GTauData.chan};
            end
        case {h.IRFShift_Slider, h.IRFShift_Edit}
            %%% Update Value
            if obj == h.IRFShift_Slider
                GTauData.IRFShift{GTauData.chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.IRFShift_Edit
                GTauData.IRFShift{GTauData.chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(GTauData.IRFShift{GTauData.chan});
            end
        case {h.IRFrelShift_Slider, h.IRFrelShift_Edit}
            %%% Update Value
            if obj == h.IRFrelShift_Slider
                GTauData.IRFrelShift{GTauData.chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.IRFrelShift_Edit
                GTauData.IRFrelShift{GTauData.chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(GTauData.IRFrelShift{GTauData.chan});
            end
        case {h.ScatShift_Slider, h.ScatShift_Edit}
            %%% Update Value
            if obj == h.ScatShift_Slider
                GTauData.ScatShift{GTauData.chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.ScatShift_Edit
                GTauData.ScatShift{GTauData.chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(GTauData.ScatShift{GTauData.chan});
            end
        case {h.ScatrelShift_Slider, h.ScatrelShift_Edit}
            %%% Update Value
            if obj == h.ScatrelShift_Slider
                GTauData.ScatrelShift{GTauData.chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.ScatrelShift_Edit
                GTauData.ScatrelShift{GTauData.chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(GTauData.ScatrelShift{GTauData.chan});
            end
        case {h.Ignore_Slider,h.Ignore_Edit}%%% Update Value
            if obj == h.Ignore_Slider
                GTauData.Ignore{GTauData.chan} = floor(obj.Value);
            elseif obj == h.Ignore_Edit
                if str2double(obj.String) <  1
                    GTauData.Ignore{GTauData.chan} = 1;
                    obj.String = '1';
                else
                    GTauData.Ignore{chan} = floor(str2double(obj.String));
                    obj.String = num2str(GTauData.Ignore{GTauData.chan});
                end
            end     
    end
end

Global = cell2mat(h.Fit_Table.Data(end-2,7:3:end-1));
Active = cell2mat(h.Fit_Table.Data(1:end-3,2));

%for i=find(Active)'
    %IRFTab = cell2mat(h.Fit_Table.Data(i,end-3));
    %h.IRFLength_Slider.Value = IRFTab;
    %h.IRFShift_Edit.String = num2str(IRFTab);
%end

%%% Update Edit Boxes if Slider was used and Sliders if Edit Box was used
if isprop(obj,'Style')
    switch obj.Style
        case 'slider'
            h.StartPar_Edit.String = num2str(GTauData.StartPar{GTauData.chan});
            h.Length_Edit.String = num2str(GTauData.Length{GTauData.chan});
            h.ShiftPer_Edit.String = num2str(GTauData.ShiftPer{GTauData.chan});
            h.IRFLength_Edit.String = num2str(GTauData.IRFLength{GTauData.chan});
            h.IRFShift_Edit.String = num2str(GTauData.IRFShift{GTauData.chan});
            h.IRFrelShift_Edit.String = num2str(GTauData.IRFrelShift{GTauData.chan});
            h.ScatShift_Edit.String = num2str(GTauData.ScatShift{GTauData.chan});
            h.ScatrelShift_Edit.String = num2str(GTauData.ScatrelShift{GTauData.chan});
            %h.Fit_Table.Data{end,1} = GTauData.IRFShift{GTauData.chan};
            h.Ignore_Edit.String = num2str(GTauData.Ignore{GTauData.chan});
            h.Fit_Table.Data(1:end-3,end-3) = num2cell(h.IRFShift_Slider.Value);
        case 'edit'
            h.StartPar_Slider.Value = GTauData.StartPar{GTauData.chan};
            h.Length_Slider.Value = GTauData.Length{GTauData.chan};
            h.ShiftPer_Slider.Value = GTauData.ShiftPer{GTauData.chan};
            h.IRFLength_Slider.Value = GTauData.IRFLength{GTauData.chan};
            h.IRFShift_Slider.Value = GTauData.IRFShift{GTauData.chan};
            h.IRFrelShift_Slider.Value = GTauData.IRFrelShift{GTauData.chan};
            h.ScatShift_Slider.Value = GTauData.ScatShift{GTauData.chan};
            h.ScatrelShift_Slider.Value = GTauData.ScatrelShift{GTauData.chan};
            %h.Fit_Table.Data{end,1} = GTauData.IRFShift{GTauData.chan};
            h.Ignore_Slider.Value = GTauData.Ignore{GTauData.chan};
            h.Fit_Table.Data(1:end-3,end-3) = num2cell(GTauData.IRFShift{GTauData.chan});
    end
    UserValues.GTauFit.StartPar{GTauData.chan} = GTauData.StartPar{GTauData.chan};
    UserValues.GTauFit.Length{GTauData.chan} = GTauData.Length{GTauData.chan};
    UserValues.GTauFit.ShiftPer{GTauData.chan} = GTauData.ShiftPer{GTauData.chan};
    UserValues.GTauFit.IRFLength{GTauData.chan} = GTauData.IRFLength{GTauData.chan};
    UserValues.GTauFit.IRFShift{GTauData.chan} = GTauData.IRFShift{GTauData.chan};
    UserValues.GTauFit.IRFrelShift{GTauData.chan} = GTauData.IRFrelShift{GTauData.chan};
    UserValues.GTauFit.ScatShift{GTauData.chan} = GTauData.ScatShift{GTauData.chan};
    UserValues.GTauFit.ScatrelShift{GTauData.chan} = GTauData.ScatrelShift{GTauData.chan};
    UserValues.GTauFit.Ignore{GTauData.chan} = GTauData.Ignore{GTauData.chan};
    LSUserValues(1);
end



%%% Update Plot
%%% Make the Microtime Adjustment Plot Visible, hide Result
h.Microtime_Plot.Parent = h.Fit_Plots_Panel;
h.Result_Plot.Parent = h.HidePanel;
h.Result_Plot_Aniso.Parent = h.HidePanel;
%%% hide wres plot
set([h.Plots.Residuals,h.Plots.Residuals_ignore,h.Plots.Residuals_Perp,h.Plots.Residuals_Perp_ignore],'Visible','off');
%%% Apply the shift to the parallel channel
% if you change something here, change it too in Start_BurstWise Fit!
h.Plots.Decay_Par.XData = ((GTauData.StartPar{GTauData.chan}:(GTauData.Length{GTauData.chan}-1)) - GTauData.StartPar{GTauData.chan})*TACtoTime;
h.Plots.Decay_Par.YData = GTauData.hMI_Par{GTauData.chan}((GTauData.StartPar{GTauData.chan}+1):GTauData.Length{GTauData.chan})';
%%% Apply the shift to the perpendicular channel
h.Plots.Decay_Per.XData = ((GTauData.StartPar{GTauData.chan}:(GTauData.Length{GTauData.chan}-1)) - GTauData.StartPar{GTauData.chan})*TACtoTime;
%tmp = circshift(TauFitData.hMI_Per{chan},[TauFitData.ShiftPer{chan},0])';
tmp = shift_by_fraction(GTauData.hMI_Per{GTauData.chan}, GTauData.ShiftPer{GTauData.chan});
h.Plots.Decay_Per.YData = tmp((GTauData.StartPar{GTauData.chan}+1):GTauData.Length{GTauData.chan});
%%% Apply the shift to the parallel IRF channel
h.Plots.IRF_Par.XData = ((GTauData.StartPar{GTauData.chan}:(GTauData.IRFLength{GTauData.chan}-1)) - GTauData.StartPar{GTauData.chan})*TACtoTime;
%tmp = circshift(TauFitData.hIRF_Par{chan},[0,TauFitData.IRFShift{chan}])';
tmp = shift_by_fraction(GTauData.hIRF_Par{GTauData.chan},GTauData.IRFShift{GTauData.chan});
h.Plots.IRF_Par.YData = tmp((GTauData.StartPar{GTauData.chan}+1):GTauData.IRFLength{GTauData.chan});
%%% Apply the shift to the perpendicular IRF channel
h.Plots.IRF_Per.XData = ((GTauData.StartPar{GTauData.chan}:(GTauData.IRFLength{GTauData.chan}-1)) - GTauData.StartPar{GTauData.chan})*TACtoTime;
%tmp = circshift(TauFitData.hIRF_Per{chan},[0,TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan}])';
tmp = shift_by_fraction(GTauData.hIRF_Per{GTauData.chan},GTauData.IRFShift{GTauData.chan}+GTauData.ShiftPer{GTauData.chan}+GTauData.IRFrelShift{GTauData.chan});
h.Plots.IRF_Per.YData = tmp((GTauData.StartPar{GTauData.chan}+1):GTauData.IRFLength{GTauData.chan});
%%% Apply the shift to the parallel Scat channel
h.Plots.Scat_Par.XData = ((GTauData.StartPar{GTauData.chan}:(GTauData.Length{GTauData.chan}-1)) - GTauData.StartPar{GTauData.chan})*TACtoTime;
%tmp = circshift(TauFitData.hScat_Par{chan},[0,TauFitData.ScatShift{chan}])';
tmp = shift_by_fraction(GTauData.hScat_Par{GTauData.chan},GTauData.ScatShift{GTauData.chan});
if h.NormalizeScatter_Menu.Value
    % since the scatter pattern should not contain background, we subtract the constant offset
    maxscat = max(tmp);
    %subtract the constant offset and renormalize the amplitude to what it was
    tmp = (tmp-mean(tmp(end-floor(GTauData.MI_Bins/50):end)));
    tmp = tmp/max(tmp)*maxscat;
    %tmp(tmp < 0) = 0;
    tmp(isnan(tmp)) = 0;
end
h.Plots.Scat_Par.YData = tmp((GTauData.StartPar{GTauData.chan}+1):GTauData.Length{GTauData.chan});
%%% Apply the shift to the perpendicular Scat channel
h.Plots.Scat_Per.XData = ((GTauData.StartPar{GTauData.chan}:(GTauData.Length{GTauData.chan}-1)) - GTauData.StartPar{GTauData.chan})*TACtoTime;
%tmp = circshift(TauFitData.hScat_Per{chan},[0,TauFitData.ScatShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.ScatrelShift{chan}])';
tmp = shift_by_fraction(GTauData.hScat_Per{GTauData.chan},GTauData.ScatShift{GTauData.chan}+GTauData.ShiftPer{GTauData.chan}+GTauData.ScatrelShift{GTauData.chan});
tmp = tmp((GTauData.StartPar{GTauData.chan}+1):GTauData.Length{GTauData.chan});
if h.NormalizeScatter_Menu.Value
    % since the scatter pattern should not contain background, we subtract the constant offset
    maxscat = max(tmp);
    tmp = tmp-mean(tmp(end-floor(GTauData.MI_Bins/50):end));
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
    if ~any(strcmp(GTauData.Who,{'BurstBrowser','Burstwise'}))
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
axes(h.Microtime_Plot);
xlim([h.Plots.Decay_Par.XData(1),h.Plots.Decay_Par.XData(end)]);

%%% Update Ignore Plot
if GTauData.Ignore{GTauData.chan} > 1
    %%% Make plot visible
    h.Ignore_Plot.Visible = 'on';
    h.Ignore_Plot.XData = [GTauData.Ignore{GTauData.chan}*TACtoTime GTauData.Ignore{GTauData.chan}*TACtoTime];
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
            min(ydat),...
            h.Microtime_Plot.YLim(2)];
    else
        h.Ignore_Plot.YData = [...
            h.Microtime_Plot.YLim(1),...
            h.Microtime_Plot.YLim(2)];
    end
elseif GTauData.Ignore{GTauData.chan} == 1
    %%% Hide Plot Again
    h.Ignore_Plot.Visible = 'off';
end


% hide MEM button
h.Fit_Button_MEM_tau.Visible = 'off';
h.Fit_Button_MEM_dist.Visible = 'off';
end



drawnow;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Context menu callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1: Change X scaling
%%% 2: Export to figure
%%% 3: Export to Workspace
%%% 4: Export Params to Clipboard
function Plot_Menu_Callback(Obj,~,mode)
h = guidata(findobj('Tag','GTauFit'));
global GTauMeta GTauData

switch mode
    case 1 %%% Change X scale
        if strcmp(Obj.Checked,'off')
            h.GTauFit_Axes.XScale='log';
            h.Residuals_Axes.XScale = 'log';
            Obj.Checked='on';
        else
            h.GTauFit_Axes.XScale='lin';
            h.Residuals_Axes.XScale = 'lin';
            Obj.Checked='off';
        end
    case 2 %%% Exports plots to new figure
        %% Sets parameters
        Size = [str2double(h.Export_XSize.String) str2double(h.Export_YSize.String) str2double(h.Export_YSizeRes.String)];
        FontSize = h.Export_Font.UserData.FontSize;
        
        if ~strcmp(GTauMeta.DataType,'FRET')
            Scale = [floor(log10(max(h.GTauFit_Axes.XLim(1),h.GTauFit_Axes.Children(1).XData(1)))), ceil(h.GTauFit_Axes.XLim(2))];
            XTicks = zeros(diff(Scale),1);
            XTickLabels = cell(diff(Scale),1);
            j=1;        
            for i=Scale(1):Scale(2)
                XTicks(j) = 10^i;
                XTickLabels{j} = ['10^{',num2str(i),'}'];
                j = j+1;
            end  
        end
        
        %% Creates new figure
        H.Fig=figure(...
            'Units','points',...
            'defaultUicontrolFontName',h.Export_Font.UserData.FontName,...
            'defaultAxesFontName',h.Export_Font.UserData.FontName,...
            'defaultTextFontName',h.Export_Font.UserData.FontName,...
            'defaultUicontrolFontSize',h.Export_Font.UserData.FontSize,...
            'defaultAxesFontSize',h.Export_Font.UserData.FontSize,...
            'defaultTextFontSize',h.Export_Font.UserData.FontSize,...
            'defaultUicontrolFontWeight',h.Export_Font.UserData.FontWeight,...
            'defaultAxesFontWeight',h.Export_Font.UserData.FontWeight,...
            'defaultTextFontWeight',h.Export_Font.UserData.FontWeight,...
            'defaultUicontrolFontAngle',h.Export_Font.UserData.FontAngle,...
            'defaultAxesFontAngle',h.Export_Font.UserData.FontAngle,...
            'defaultTextFontAngle',h.Export_Font.UserData.FontAngle,...
            'Position',[50 150 Size(1)+5*FontSize+25 Size(2)+Size(3)+6.5*FontSize]);
        whitebg([1 1 1]);   
        %% Creates axes for correlation and residuals
        if ~strcmp(GTauMeta.DataType,'FRET')
            H.GTauFit=axes(...
                'Parent',H.Fig,...
                'XScale','log',...
                'FontSize', FontSize,...
                'XTick',XTicks,...
                'XTickLabel',XTickLabels,...
                'Layer','bottom',...
                'Units','points',...
                'Position',[15+4.2*FontSize 3.5*FontSize Size(1) Size(2)],...
                'LineWidth',1.5);    
            if h.Export_Residuals.Value
                H.Residuals=axes(...
                    'Parent',H.Fig,...
                    'XScale','log',...
                    'FontSize', FontSize,...
                    'XTick',XTicks,...
                    'XTickLabel',[],...
                    'Layer','bottom',...
                    'Units','points',...
                    'Position',[15+4.2*FontSize 5*FontSize+Size(2) Size(1) Size(3)],...
                    'LineWidth',1.5);
            else
                H.GTauFit.Position(4) = H.GTauFit.Position(4)+Size(3)+1.5*FontSize;
            end
        else
            H.GTauFit=axes(...
                'Parent',H.Fig,...
                'XScale','lin',...
                'FontSize', FontSize,...
                'Layer','bottom',...
                'Units','points',...
                'Position',[15+4.2*FontSize 3.5*FontSize Size(1) Size(2)],...
                'LineWidth',1.5);    
            if h.Export_Residuals.Value
                H.Residuals=axes(...
                    'Parent',H.Fig,...
                    'XScale','lin',...
                    'FontSize', FontSize,...
                    'XTickLabel',[],...
                    'Layer','bottom',...
                    'Units','points',...
                    'Position',[15+4.2*FontSize 5*FontSize+Size(2) Size(1) Size(3)],...
                    'LineWidth',1.5);
            else
                H.GTauFit.Position(4) = H.GTauFit.Position(4)+Size(3)+1.5*FontSize;
            end
        end
            
        %% Copies objects to new figure
        Active = find(cell2mat(h.Fit_Table.Data(1:end-3,2)));
        % if h.Fit_Errorbars.Value
        %     UseCurves = sort(numel(h.GTauFit_Axes.Children)+1-[3*Active-2; 3*Active-1]);
        % else
        %    UseCurves = reshape(flip(sort(numel(h.GTauFit_Axes.Children)+1-[3*Active 3*Active-1;],1)',1),[],1);
        % end
        % UseCurves = sort(numel(h.GTauFit_Axes.Children)+1-[3*Active-2; 3*Active-1; 3*Active]);
        % H.GTauFit_Plots=copyobj(h.GTauFit_Axes.Children(UseCurves),H.GTauFit);
        
        if h.Fit_Errorbars.Value
            UseCurves = [1,2];
        else
            UseCurves = [4,2];
        end

        CopyCurves = GTauMeta.Plots(Active,UseCurves);
        H.GTauFit_Plots = [];
        for i = Active'
            for j = UseCurves
                H.GTauFit_Plots(i,j) = copyobj(GTauMeta.Plots{i,j},H.GTauFit);
            end
        end

        if h.Export_FitsLegend.Value
               H.GTauFit_Legend=legend(H.GTauFit,h.GTauFit_Legend.String,'Interpreter','none'); 
        else
            if isfield(h,'GTauFit_Legend')
                if h.GTauFit_Legend.isvalid
                    LegendString = h.GTauFit_Legend.String(1:2:end-1);
                    for i=1:numel(LegendString)
                        LegendString{i} = LegendString{i}(7:end);
                    end
                    if h.Fit_Errorbars.Value
                        H.GTauFit_Legend=legend(H.GTauFit,H.GTauFit_Plots(Active,UseCurves(1)),LegendString,'Interpreter','none');
                    else
                        H.GTauFit_Legend=legend(H.GTauFit,H.GTauFit_Plots(Active,UseCurves(1)),LegendString,'Interpreter','none');
                    end

                end
            end
        end
        if strcmp(GTauMeta.DataType,'FRET')
            %%% add invidividual plots
            UseCurves = [5:size(GTauMeta.Plots,2)];
            N = numel(H.GTauFit_Legend.String);
            for i = Active'
                for j = UseCurves
                    copyobj(GTauMeta.Plots{i,j},H.GTauFit);
                end
            end
            H.GTauFit_Legend.String = H.GTauFit_Legend.String(1:N);
        end
        if h.Export_Residuals.Value
            H.Residuals_Plots=copyobj(h.Residuals_Axes.Children(numel(h.Residuals_Axes.Children)+1-Active),H.Residuals);      
        end
        %% Sets axes parameters   
        set(H.GTauFit.Children,'LineWidth',1.5);
        if h.Export_Residuals.Value
            set(H.Residuals.Children,'LineWidth',1.5);
            linkaxes([H.GTauFit,H.Residuals],'x');
        end
        H.GTauFit.XLim=[h.GTauFit_Axes.XLim(1),h.GTauFit_Axes.XLim(2)];
        H.GTauFit.YLim=h.GTauFit_Axes.YLim;
        switch GTauMeta.DataType
            case {'GTauFit','GTauFit averaged'}
                H.GTauFit.XLabel.String = 'time lag {\it\tau{}} [s]';
                H.GTauFit.YLabel.String = 'G({\it\tau{}})'; 
            case 'FRET'
                H.GTauFit.XLabel.String = 'FRET efficiency';
                H.GTauFit.YLabel.String = 'PDF'; 
        end
        if h.Export_Residuals.Value
            H.Residuals.YLim=h.Residuals_Axes.YLim;
            switch h.Fit_Weights.Value
                case 1
                    H.Residuals.YLabel.String = {'weighted'; 'residuals'};
                case 0
                    H.Residuals.YLabel.String = {'residuals'};
            end
        end        
        %% Toggles box and grid
        if h.Export_Grid.Value
            grid(H.GTauFit,'on');
            if h.Export_Residuals.Value
                grid(H.Residuals,'on');
            end
        end
        if h.Export_MinorGrid.Value
            grid(H.GTauFit,'minor');
            if h.Export_Residuals.Value
                grid(H.Residuals,'minor');
            end
        else
            grid(H.GTauFit,'minor');
            grid(H.GTauFit,'minor');
            if h.Export_Residuals.Value
                grid(H.Residuals,'minor');
                grid(H.Residuals,'minor');
            end
        end
        if h.Export_Box.Value
            H.GTauFit.Box = 'on';
            if h.Export_Residuals.Value
                H.Residuals.Box = 'on';
            end
        else
            H.GTauFit.Box = 'off';
            if h.Export_Residuals.Value
                H.Residuals.Box = 'off';
            end
        end
        
        H.Fig.Color = [1 1 1];
        %%% Copies figure handles to workspace
        assignin('base','H',H);
    case 3 %%% Exports data to workspace
        Active = cell2mat(h.Fit_Table.Data(1:end-3,2));
        GTauFit=[];
        GTauFit.Model=GTauMeta.Model.Function;
        GTauFit.FileName=GTauData.FileName(Active)';
        GTauFit.Params=GTauMeta.Params(:,Active)';        
        time=GTauMeta.Data(Active,1);
        data=GTauMeta.Data(Active,2);
        error=GTauMeta.Data(Active,3);
        %Fit=cell(numel(GTauFit.Time),1); 
        GTauFit.Graphs=cell(numel(time)+1,1);
        GTauFit.Graphs{1}={'time', 'data', 'error', 'fit', 'res'};
        %%% Calculates y data for fit
        for i=1:numel(time)
            P=GTauFit.Params(i,:);
            %eval(GTauMeta.Model.Function);
            OUT = feval(GTauMeta.Model.Function,P,time{i});
            OUT=real(OUT);
            res=(data{i}-OUT)./error{i};
            GTauFit.Graphs{i+1} = [time{i}, data{i}, error{i}, OUT, res];
        end
        %%% Copies data to workspace
        assignin('base','GTauFit',GTauFit);
    case 4 %%% Exports Fit Result to Clipboard
        FitResult = cell(numel(GTauData.FileName),1);
        active = cell2mat(h.Fit_Table.Data(1:end-2,2));
        for i = 1:numel(GTauData.FileName)
            if active(i)
                FitResult{i} = cell(size(GTauMeta.Params,1)+2,1);
                FitResult{i}{1} = GTauData.FileName{i};
                FitResult{i}{2} = str2double(h.Fit_Table.Data{i,end});
                FitResult{i}{3} = str2double(h.Fit_Table.Data{i,4});
                for j = 4:(size(GTauMeta.Params,1)+3)
                    FitResult{i}{j} = GTauMeta.Params(j-3,i);
                end
            end
        end
        [~,ModelName,~] = fileparts(GTauMeta.Model.Name);
        Params = vertcat({ModelName;'Chi2';'Mol. Bright. [kHz]'},GTauMeta.Model.Params);
        if h.Conf_Interval.Value
            if isfield(GTauMeta,'Confidence_Intervals')
                for i = 1:numel(GTauData.FileName)
                    if active(i)
                        Nlow = GTauMeta.Confidence_Intervals{i}(1,1);
                        Nhigh = GTauMeta.Confidence_Intervals{i}(1,2);
                        N = FitResult{i}{4};
                        Blow = FitResult{i}{3}*Nlow/N;
                        Bhigh = FitResult{i}{3}*Nhigh/N;
                        FitResult{i} = horzcat(FitResult{i},vertcat({'lower','upper';'','';num2str(Blow),num2str(Bhigh)},num2cell([GTauMeta.Confidence_Intervals{i}])));
                    end
                end
            end
        end
        FitResult = horzcat(Params,horzcat(FitResult{:}));
        Mat2clip(FitResult');
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
%%% Stops fitting routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Stop_GTauFit(~,~)
global GTauMeta
h = guidata(findobj('Tag','GTauFit'));
GTauMeta.FitInProgress = 0;
h.Fit_Table.Enable='on';
h.GTauFit.Name='GTauFit Fit';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Executes fitting routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_GTauFit(obj,~,~)
global GTauMeta UserValues GTauData
h = guidata(findobj('Tag','GTauFit'));
%%% Indicates fit in progress
GTauMeta.FitInProgress = 1;
h.GTauFit.Name='GTau Fit  FITTING';
h.Fit_Table.Enable='off';
drawnow;
%%% Reads parameters from table
fixed = cell2mat(h.Fit_Table.Data(1:end-3,6:3:end-1));
Global = cell2mat(h.Fit_Table.Data(end-2,7:3:end-1));
Active = cell2mat(h.Fit_Table.Data(1:end-3,2));
%lb = h.Fit_Table.Data(end-1,5:3:end-1);
%lb = cellfun(@str2double,lb);
%ub = h.Fit_Table.Data(end,5:3:end-1);
%ub = cellfun(@str2double,ub);
%%% Read fit settings and store in UserValues
%MaxIter = str2double(h.Iterations.String);
%TolFun = str2double(h.Tolerance.String);
%UserValues.GTauFit.Max_Iterations = MaxIter;
%UserValues.GTauFit.Fit_Tolerance = TolFun;
%Use_Weights = h.Fit_Weights.Value;
%UserValues.GTauFit.Use_Weights = Use_Weights;
%LSUserValues(1);
%%% Optimization settings
%opts=optimset('Display','off','TolFun',TolFun,'MaxIter',MaxIter);
%%% Performs fit


if ~strcmp(GTauData.Who, 'GTauFit') && ~strcmp(GTauData.Who, 'External')
    % Burstwise lifetime and Burstbrowser subensembe TCSPC
    chan = h.ChannelSelect_Popupmenu.Value;
else
    if isfield(GTauData,'chan')
        chan = GTauData.chan;
    else
        return;
    end
end
%if gcbo == h.Menu.Export_MIPattern_Fit
    %save_fix = false; %%% do not store fix state in UserValues, since it is set to fix all
%else
    %save_fix = true;
%end
h.Result_Plot_Text.Visible = 'off';
h.Output_Text.String = '';
h.Plots.Residuals.Visible = 'on';
h.PlotDynamicFRETLine.Visible = 'off';
%% Prepare FitData
GTauData.FitData.Decay_Par = h.Plots.Decay_Par.YData;
GTauData.FitData.Decay_Per = h.Plots.Decay_Per.YData;

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
IRFPer = shift_by_fraction(GTauData.hIRF_Per{chan},GTauData.ShiftPer{chan}+GTauData.IRFrelShift{chan});
IRFPattern = GTauData.hIRF_Par{chan}(1:GTauData.Length{chan}) + 2*IRFPer(1:GTauData.Length{chan});
IRFPattern = IRFPattern'./sum(IRFPattern);

%%% additional processing of the IRF to remove constant background
IRFPattern = IRFPattern - mean(IRFPattern(end-round(numel(IRFPattern)/10):end)); IRFPattern(IRFPattern<0) = 0;

cleanup_IRF = UserValues.GTauFit.cleanup_IRF;
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
ShiftParams(1) = GTauData.StartPar{GTauData.chan};
ShiftParams(2) = GTauData.IRFShift{GTauData.chan}; % not used anymore
ShiftParams(3) = GTauData.Length{GTauData.chan};
if ~cleanup_IRF
    ShiftParams(4) = GTauData.IRFLength{GTauData.chan};
else
    ShiftParams(4) = GTauData.Length{GTauData.chan};
end

%ShiftParams(5) = TauFitData.ScatShift{chan}; %anders, please see if I correctly introduced the scatshift in the models

%%% initialize inputs for fit
if ~any(strcmp(GTauData.Who,{'BurstBrowser','Burstwise'}))
    if h.PIEChannelPar_Popupmenu.Value ~= h.PIEChannelPer_Popupmenu.Value
        Decay = G*(1-3*l2)*GTauData.FitData.Decay_Par+(2-3*l1)*GTauData.FitData.Decay_Per;
        sigma_est = get_error_combined_decay(GTauData.FitData.Decay_Par,GTauData.FitData.Decay_Per,G,l1,l2);
    else
        Decay = GTauData.FitData.Decay_Par;
        sigma_est = sqrt(Decay); sigma_est(sigma_est==0) = 1;
    end    
else
    switch GTauData.BAMethod
        case {1,2,3,4}
            Decay = G*(1-3*l2)*GTauData.FitData.Decay_Par+(2-3*l1)*GTauData.FitData.Decay_Per;
            sigma_est = get_error_combined_decay(GTauData.FitData.Decay_Par,GTauData.FitData.Decay_Per,G,l1,l2);
        case {5}
            Decay = GTauData.FitData.Decay_Par;
            sigma_est = sqrt(Decay); sigma_est(sigma_est==0) = 1;
    end
end
Length = numel(Decay);
ignore = GTauData.Ignore{chan};



%% Start Fit
%%% Update Progressbar
MI_Bins = GTauData.MI_Bins;
poissonian_chi2 = UserValues.GTauFit.use_weighted_residuals && (h.WeightedResidualsType_Menu.Value == 2); % 1 for Gaussian error, 2 for Poissonian statistics
try
    opts.lsqcurvefit = optimoptions(@lsqcurvefit,'MaxFunctionEvaluations',1E4,'MaxIteration',1E4,'Display','iter');
    opts.lsqnonlin = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',1E4,'MaxIteration',1E4,'Display','iter');
catch
    %%% naming of options changed in newer MATLAB releases
    %%% This is the naming of older releases.
    opts.lsqcurvefit = optimoptions(@lsqcurvefit,'MaxFunEvals',1E4,'MaxIter',1E4,'Display','iter');
    opts.lsqnonlin = optimoptions(@lsqnonlin,'MaxFunEvals',1E4,'MaxIter',1E4,'Display','iter');
end

if sum(Global)==0
    %% Individual fits, not global
    for i=find(Active)'
        if ~GTauMeta.FitInProgress
            break;
        end
        %%% Reads in parameters
        x0 = cell2mat(h.Fit_Table.Data(i,5:3:end-1));
        lb = cell2mat(h.Fit_Table.Data(end-1,5:3:end-1));
        ub = cell2mat(h.Fit_Table.Data(end,5:3:end-1));
        fixed = cell2mat(h.Fit_Table.Data(i,6:3:end-1));
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
        GTauData.ConfInt = NaN(numel(x0),2);
           
        if GTauMeta.NParams == 4
            lifetimes = GTauMeta.NParams - 3;
        elseif GTauMeta.NParams == 6
            lifetimes = GTauMeta.NParams - 4;
        end
            x0(lifetimes) = x0(lifetimes)/GTauData.TACChannelWidth;
            lb(lifetimes) = lb(lifetimes)/GTauData.TACChannelWidth;
            ub(lifetimes) = ub(lifetimes)/GTauData.TACChannelWidth;
        
            
            %%% define model function
            ModelFun = @(x,xdata) Fit_Single(interlace(x0,x,fixed),xdata);
            %%% estimate error assuming Poissonian statistics
            if UserValues.GTauFit.use_weighted_residuals
                sigma_est_fit = sigma_est(ignore:end);
            else
                sigma_est_fit = ones(1,numel(Decay(ignore:end)));
            end
            %%% Sets initial values and bounds for non fixed parameters
            IRFShi = str2double(h.Fit_Table.Data(i,end-3)); 
            
              
                if fit
                 %%% Update Progressbar
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),0,ignore,Conv_Type};
                    if ~poissonian_chi2
                        [x, ~, residuals, ~,~,~, jacobian] = lsqcurvefit(@(x,xdata) Fit_Single(interlace(x0,x,fixed),xdata)./sigma_est_fit,...
                            x0(~fixed),xdata,Decay(ignore:end)./sigma_est_fit,lb(~fixed),ub(~fixed),opts.lsqcurvefit);
                    else
                         [x, ~, residuals, ~,~,~, jacobian] = lsqnonlin(@(x) MLE_w_res(Fit_Single(interlace(x0,x,fixed),xdata),...
                             Decay(ignore:end)),x0(~fixed),lb(~fixed),ub(~fixed),opts.lsqnonlin);
                    end
                    x = interlace(x0,x,fixed);
                    chi2 =sum(residuals.^2)/(numel(Decay(ignore:end))-sum(~fixed));
                    GTauData.ConfInt(~fixed,:) = nlparci(x(~fixed),residuals,'jacobian',jacobian,'alpha',alpha);
                else % plot only
                    x = {x0};
                end
                
                FitFun = Fit_Single(x,{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,0,1,Conv_Type});
                if ~poissonian_chi2
                    wres = (Decay-FitFun);
                    if UserValues.GTauFit.use_weighted_residuals
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
                FitResult = num2cell(x);
                FitResult{lifetimes} = FitResult{lifetimes}.*GTauData.TACChannelWidth;
                GTauData.ConfInt(lifetimes,:) = GTauData.ConfInt(lifetimes,:).*GTauData.TACChannelWidth;
                h.Fit_Table.Data(i,5:3:end-1) = FitResult(1:end-1);
                h.Fit_Table.Data(i,end) = num2cell(chi2);
                GTauData.I0 = FitResult{end};
                fix = cell2mat(h.Fit_Table.Data(i,6:3:end-1));
                
                UserValues.GTauFit.FitParams{chan}(1) = FitResult{1};
                UserValues.GTauFit.FitParams{chan}(8) = FitResult{2};
                UserValues.GTauFit.FitParams{chan}(10) = FitResult{3};
                UserValues.GTauFit.IRFShift{chan} = FitResult{4};
                
                % Also update status text
                h.Output_Text.String = {sprintf('I0: %.2f',FitResult{end})};
    
    end  
else
    %% Global fits
    XData=[];
    YData=[];
    EData=[];
    Points=[];
    %%% Sets initial value and bounds for global parameters
    Fit_Params=GTauMeta.Params(Global,1);
    Lb=lb(Global);
    Ub=ub(Global);
    for  i=find(Active)'
        %%% Reads in parameters of current file
        xdata=GTauMeta.Data{i,1};
        ydata=GTauMeta.Data{i,2};
        edata=GTauMeta.Data{i,3};
        %%% Disables weights
        if ~Use_Weights
            edata(:)=1;
        end
        
        %%% Adjusts data to selected time region
        Min=find(xdata>=str2double(h.Fit_Min.String),1,'first');
        Max=find(xdata<=str2double(h.Fit_Max.String),1,'last');
        if ~isempty(Min) && ~isempty(Max)
            XData=[XData;xdata(Min:Max)];
            YData=[YData;ydata(Min:Max)];
            EData=[EData;edata(Min:Max)];
            Points(end+1)=numel(xdata(Min:Max));
        end
        %%% Concatenates initial values and bounds for non fixed parameters
        Fit_Params=[Fit_Params; GTauMeta.Params(~fixed(i,:)& ~Global,i)];
        Lb=[Lb lb(~fixed(i,:) & ~Global)];
        Ub=[Ub ub(~fixed(i,:) & ~Global)];
    end
    %%% Puts current Data into global variable to be able to stop fitting
    %%% Performs fit
    [Fitted_Params,~,weighted_residuals,Flag,~,~,jacobian]=lsqcurvefit(@Fit_Global,Fit_Params,{XData,EData,Points,fixed,Global,Active},YData./EData,Lb,Ub,opts);
    %%% calculate confidence intervals
    if h.Conf_Interval.Value
        method = h.Conf_Interval_Method.Value;
        alpha = 0.05; %95% confidence interval
        if method == 1
            ConfInt = nlparci(Fitted_Params,weighted_residuals,'jacobian',jacobian,'alpha',alpha);
        elseif method == 2
            disp('Running MCMC... This could take a minute.');tic;
            confint = nlparci(Fitted_Params,weighted_residuals,'jacobian',jacobian,'alpha',alpha);
            proposal = (confint(:,2)-confint(:,1))/2; proposal = (proposal/10)';
            if any(isnan(proposal))
                %%% nlparci may return NaN values. Set to 1% of the fit value
                proposal(isnan(proposal)) = Fitted_Params(isnan(proposal))/100;
            end
            %%% define log-likelihood function, which is just the negative of the chi2 divided by two! (do not use reduced chi2!!!)
            loglikelihood = @(x) (-1/2)*sum((Fit_Global(x,{XData,EData,Points,fixed,Global,Active})-YData./EData).^2);
            %%% Sample
            nsamples = 1E4; spacing = 1E2;
            [samples,prob,acceptance] =  MHsample(nsamples,loglikelihood,@(x) 1,proposal,Lb,Ub,Fitted_Params,zeros(1,numel(Fitted_Params)));
            while acceptance < 0.01
                    disp(sprintf('Acceptance was too low! (%.4f)',acceptance));
                    disp('Running again with more narrow proposal distribution.');
                    proposal = proposal/10;
                    [samples,prob,acceptance] =  MHsample(nsamples,loglikelihood,@(x) 1,proposal,Lb,Ub,Fitted_Params,zeros(1,numel(Fitted_Params)));
            end
            %%% New asymmetric confidence interval estimate
            ConfInt = prctile(samples(1:spacing:end,:),100*[alpha/2,1-alpha/2],1)';
            
            %v = numel(weighted_residuals)-numel(Fitted_Params); % number of degrees of freedom is equal to the number of samples
            % perc = 1.96;%tinv(1-alpha/2,v);
            % ConfInt = [(mean(samples(1:spacing:end,:))-perc*std(samples(1:spacing:end,:)))', (mean(samples(1:spacing:end,:))+perc*std(samples(1:spacing:end,:)))'];
            
            disp(sprintf('Done. Performed %d steps in %.2f seconds.',nsamples,toc));
            % print variables to workspace
            assignin('base','GlobalSamples',samples(1:spacing:end,1:sum(Global)));
            assignin('base','LocalSamples',samples(1:spacing:end,sum(Global)+1:end));        
            assignin('base','acceptance',acceptance);
            if acceptance < 0.01
                disp(sprintf('Acceptance was too low! (%.4f)',acceptance));
            end
        end
        GlobConfInt = ConfInt(1:sum(Global),:);
        ConfInt(1:sum(Global),:) = [];        
        for i = find(Active)'
            GTauMeta.Confidence_Intervals{i} = zeros(size(GTauMeta.Params,1),2);
            GTauMeta.Confidence_Intervals{i}(Global,:) = GlobConfInt;
            GTauMeta.Confidence_Intervals{i}(~fixed(i,:) & ~Global,:) = ConfInt(1:sum(~fixed(i,:) & ~Global),:);
            ConfInt(1:sum(~fixed(i,:)& ~Global),:)=[]; 
        end
    end
    %%% Updates parameters
    GTauMeta.Params(Global,:)=repmat(Fitted_Params(1:sum(Global)),[1 size(GTauMeta.Params,2)]) ;
    Fitted_Params(1:sum(Global))=[];
    for i=find(Active)'
        GTauMeta.Params(~fixed(i,:) & ~Global,i)=Fitted_Params(1:sum(~fixed(i,:) & ~Global)); 
        Fitted_Params(1:sum(~fixed(i,:)& ~Global))=[]; 
    end    
end

LSUserValues(1)
%%% Update IRFShift in Slider and Edit Box
h.IRFShift_Slider.Value = UserValues.GTauFit.IRFShift{chan};
h.IRFShift_Edit.String = num2str(round(UserValues.GTauFit.IRFShift{chan},2));
GTauData.IRFShift{chan} = UserValues.GTauFit.IRFShift{chan};
        
%%% Update Plot
h.Microtime_Plot.Parent = h.HidePanel;
h.Result_Plot.Parent = h.Fit_Plots_Panel;
h.Plots.IRFResult.Visible = 'on';
        
        
        
% nanoseconds per microtime bin
TACtoTime = GTauData.TACChannelWidth; %1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;
        
%%%%%%%%%%% Update plots%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ignore > 1
   h.Plots.DecayResult_ignore.Visible = 'on';
   h.Plots.Residuals_ignore.Visible = 'on';
   h.Plots.FitResult_ignore.Visible = 'on';
else
   h.Plots.DecayResult_ignore.Visible = 'off';
   h.Plots.Residuals_ignore.Visible = 'off';
   h.Plots.FitResult_ignore.Visible = 'off';
end
        
            
            
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
IRFPat = shift_by_fraction(IRFPattern,UserValues.GTauFit.IRFShift{chan});
IRFPat = IRFPat((ShiftParams(1)+1):ShiftParams(4));
IRFPat = IRFPat./max(IRFPat).*max(Decay);
h.Plots.IRFResult.XData = (1:numel(IRFPat))*TACtoTime;
h.Plots.IRFResult.YData = IRFPat;
% store FitResult GTauData also for use in export
if ignore > 1
   GTauData.FitResult = [FitFun_ignore, FitFun];
else
   GTauData.FitResult = FitFun;
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
            loglikelihood = @(x) (-1/2)*sum((ModelFun(x,xdata)./sigma_est-Decay_FitRange./sigma_est).^2);
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
            samples(:,lt(~fixed)) = samples(:,lt(~fixed)).*GTauData.TACChannelWidth;
            confint_mcmc = prctile(samples(1:spacing:end,:),100*[alpha/2,1-alpha/2],1)';
            disp(sprintf('Done. Performed %d steps in %.2f seconds.\nAcceptance was %.2f.\nSpacing used was %d.',nsamples,toc,acceptance,spacing));
            % print variables to workspace
            assignin('base',['Samples'],samples(1:spacing:end,:));
            assignin('base',['acceptance'],acceptance);
            assignin('base',['LogLikelihood'],prob(1:spacing:end));
            assignin('base',['ConfInt_MCMC'],confint_mcmc);
            disp(table(confint_mcmc));
        end
        
%%%%%%Update AllTab



%%% Indicates end of fitting procedure
h.Fit_Table.Enable='on';
%Update_Table([],[],2);
h.GTauFit.Name='GTau Fit';
GTauMeta.FitInProgress = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Actual fitting function for individual fits %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [z] = Fit_Single(param,xdata)
%%% Fit_Params: Non fixed parameters of current file
%%% Data{1}:    X values of current file
%%% Data{2}:    Weights of current file
%%% Data{3}:    Indentifier of current file
global GTauMeta UserValues

ShiftParams = xdata{1};
IRFPattern = xdata{2};
Scatter = xdata{3};

y = xdata{5};
c = param(end-1);%xdata{6}; %IRF shift
ignore = xdata{7};
conv_type = xdata{end}; %%% linear or circular convolution
%%% Define IRF and Scatter from ShiftParams and ScatterPattern!
%irf = circshift(IRFPattern,[c, 0]);
irf = shift_by_fraction(IRFPattern,c);
irf = irf( (ShiftParams(1)+1):ShiftParams(4) );
%irf(irf~=0) = irf(irf~=0)-min(irf(irf~=0));
irf = irf./sum(irf);
irf = [irf; zeros(numel(y)+ignore-1-numel(irf),1)];
%Scatter = circshift(ScatterPattern,[ShiftParams(5), 0]);
%A shift in the scatter is not needed in the model
%Scatter = Scatter( (ShiftParams(1)+1):ShiftParams(3) );

n = length(irf);
%t = 1:n;

P = param;
P(end+1) = xdata{4}; 
x = (1:P(end))'; %tp

x = feval(GTauMeta.Model.Function,P,x);
switch conv_type
    case 'linear'
        z = zeros(size(x,1)+size(irf,1)-1,size(x,2));
        for i = 1:size(x,2)
            z(:,i) = conv(irf, x(:,i));
        end
        z = z(1:n,:);
    case 'circular'
        z = convol(irf,x(1:n));
end
z = param(end)*z(ignore:end)+param(end-3)*sum(y)*Scatter(ignore:end)+param(end-2);
z = z';
%%% Applies weights
%Out=OUT./Weights;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Actual fitting function for global fits %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Out] = Fit_Global(Fit_Params,Data)
%%% Fit_Params: [Global parameters, Non fixed parameters of all files]
%%% Data{1}:    X values of all files
%%% Data{2}:    Weights of all files
%%% Data{3}:    Length indentifier for X and Weights data of each file
global GTauMeta
%h = guidata(findobj('Tag','GTauFit'));

%%% Aborts Fit
%drawnow;
if ~GTauMeta.FitInProgress
    Out = zeros(size(Data{2}));
    return;
end

X=Data{1};
Weights=Data{2};
Points=Data{3};
Fixed = Data{4};
Global = Data{5};
Active = Data{6};
%%% Determines, which parameters are fixed, global and which files to use
%Fixed = cell2mat(h.Fit_Table.Data(1:end-3,5:3:end));
%Global = cell2mat(h.Fit_Table.Data(end-2,6:3:end));
%Active = cell2mat(h.Fit_Table.Data(1:end-3,1));
P=zeros(numel(Global),1);

%%% Assigns global parameters
P(Global)=Fit_Params(1:sum(Global));
Fit_Params(1:sum(Global))=[];

Out=[];k=1;
for i=find(Active)'
  %%% Sets non-fixed parameters
  P(~Fixed(i,:) & ~Global)=Fit_Params(1:sum(~Fixed(i,:) & ~Global)); 
  Fit_Params(1:sum(~Fixed(i,:)& ~Global))=[];  
  %%% Sets fixed parameters
  P(Fixed(i,:) & ~Global)= GTauMeta.Params((Fixed(i,:)& ~Global),i);
  %%% Defines XData for the file
  x=X(1:Points(k));
  X(1:Points(k))=[]; 
  k=k+1;
  %%% Calculates function for current file
  %eval(GTauMeta.Model.Function);
  OUT = feval(GTauMeta.Model.Function,P,x);
  Out=[Out;OUT]; 
end
Out=Out./Weights;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to recalculate binning for FRET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rebinFRETdata(obj,~)
global UserValues GTauData GTauMeta
h = guidata(obj);
bin = str2double(obj.String);
%%% round to multiples of 0.005
bin = ceil(bin/0.005)*0.005;
x = (-0.1:bin:ceil(1.1/bin)*bin)';
UserValues.GTauFit.FRETbin = bin;
obj.String = num2str(bin);
for i=1:numel(GTauData.Data)
    %%% Reads data
    E = GTauData.Data{i}.E;
    Data.E = E;
    his = histcounts(E,x)'; %his = [his'; his(end)];
    Data.Dec_Average = his./sum(his)./min(diff(x));
    error = sqrt(his)./sum(his)./min(diff(x));
    Data.Dec_SEM = error; Data.Dec_SEM(Data.Dec_SEM == 0) = 1;
    Data.Dec_Array = [];
    Data.Valid = [];
    Data.Counts = [numel(E), numel(E)];
    Data.Dec_Times = x(1:end-1)+bin/2;
    GTauData.Data{i} = Data;

    %%% Updates global parameters
    GTauMeta.Data{i,1} = GTauData.Data{i}.Dec_Times;
    GTauMeta.Data{i,2} = GTauData.Data{i}.Dec_Average;
    GTauMeta.Data{i,2}(isnan(GTauMeta.Data{i,2})) = 0;
    GTauMeta.Data{i,3} = GTauData.Data{i}.Dec_SEM;
    GTauMeta.Data{i,3}(isnan(GTauMeta.Data{i,3})) = 1;
    
    %%% Update Plots
    GTauMeta.Plots{i,1}.XData = GTauMeta.Data{i,1};
    GTauMeta.Plots{i,1}.YData = GTauMeta.Data{i,2};
    if isfield(GTauMeta.Plots{i,1},'YNegativeDelta')
        GTauMeta.Plots{i,1}.YNegativeDelta = error;
        GTauMeta.Plots{i,1}.YPOsitiveDelta = error;
    else
        GTauMeta.Plots{i,1}.LData = error;
        GTauMeta.Plots{i,1}.UData = error;
    end
    
    GTauMeta.Plots{i,4}.XData = GTauMeta.Data{i,1}-bin/2;
    GTauMeta.Plots{i,4}.YData = GTauMeta.Data{i,2};       
end
Update_Plots;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes plotting style %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Style(obj,e,mode) 
global GTauMeta GTauData UserValues
h = guidata(findobj('Tag','GTauFit'));
LSUserValues(0);
switch mode
    case 0 %%% Called at the figure initialization
        %%% Generates the table column and cell names
        Columns=cell(11,1);
        Columns{1}='Color';
        Columns{2}='Data LineStyle';
        Columns{3}='Data LineWidth';
        Columns{4}='Data Marker';
        Columns{5}='Data MarkerSize';
        Columns{6}='Fit LineStyle';
        Columns{7}='Fit LineWidth';
        Columns{8}='Fit Marker';
        Columns{9}='Fit MarkerSize';   
        Columns{10}='Remove';
        Columns{11}='Rename';
        h.Style_Table.ColumnName=Columns;
        h.Style_Table.RowName={'ALL'};
        
        %%% Generates the initial cell inputs
        h.Style_Table.ColumnEditable=true;
        h.Style_Table.ColumnFormat={'char',{'none','-','-.','--',':'},'char',{'none','.','+','o','*','square','diamond','v','^','<','>'},'char',...
                                           {'none','-','-.','--',':'},'char',{'none','.','+','o','*','square','diamond','v','^','<','>'},'char','logical','logical'};
        h.Style_Table.Data=UserValues.GTauFit.PlotStyleAll(1:8);        
    case 1 %%% Called, when new file is loaded
        %%% Sets row names to file names 
        Rows=cell(numel(GTauData.FileName)+1,1);
        Rows(1:numel(GTauData.Data))=deal(GTauData.FileName);
        Rows{end}='ALL';
        h.Style_Table.RowName=Rows;
        Data=cell(numel(Rows),size(h.Style_Table.Data,2));
        %%% Sets ALL style to last row
        Data(end,1:8)=UserValues.GTauFit.PlotStyleAll(1:8);
        %%% Sets previous styles to first rows
        for i=1:numel(GTauData.FileName)
            if i<=size(UserValues.GTauFit.PlotStyles,1)
                Data(i,1:8) = UserValues.GTauFit.PlotStyles(i,1:8);
            else
                Data(i,:) = UserValues.GTauFit.PlotStyles(end,1:8);
            end
        end
        %%% Updates new plots to style
        for i=1:numel(GTauData.FileName)
           GTauMeta.Plots{i,1}.Color=str2num(Data{i,1}); %#ok<*ST2NM>
           GTauMeta.Plots{i,4}.Color=str2num(Data{i,1});
           GTauMeta.Plots{i,2}.Color=str2num(Data{i,1});
           GTauMeta.Plots{i,3}.Color=str2num(Data{i,1});
           GTauMeta.Plots{i,1}.LineStyle=Data{i,2};
           GTauMeta.Plots{i,1}.LineWidth=str2double(Data{i,3});
           GTauMeta.Plots{i,1}.Marker=Data{i,4};
           GTauMeta.Plots{i,1}.MarkerSize=str2double(Data{i,5});
           GTauMeta.Plots{i,4}.LineStyle=Data{i,2};
           GTauMeta.Plots{i,4}.LineWidth=str2double(Data{i,3});
           GTauMeta.Plots{i,4}.Marker=Data{i,4};
           GTauMeta.Plots{i,4}.MarkerSize=str2double(Data{i,5});
           GTauMeta.Plots{i,2}.LineStyle=Data{i,6};
           GTauMeta.Plots{i,3}.LineStyle=Data{i,6};
           GTauMeta.Plots{i,2}.LineWidth=str2double(Data{i,7});
           GTauMeta.Plots{i,3}.LineWidth=str2double(Data{i,7});
           GTauMeta.Plots{i,2}.Marker=Data{i,8};
           GTauMeta.Plots{i,3}.Marker=Data{i,8};
           GTauMeta.Plots{i,2}.MarkerSize=str2double(Data{i,7});
           GTauMeta.Plots{i,3}.MarkerSize=str2double(Data{i,7});
        end
        h.Style_Table.Data=Data;
    case 2 %%% Cell callback
        if strcmp(e.EventName,'CellSelection') %%% No change in Value, only selected
            if isempty(e.Indices) || (e.Indices(1)~=(size(h.Fit_Table.Data,1)) && e.Indices(2)~=1)
                return;
            end
            NewData = h.Style_Table.Data{e.Indices(1),e.Indices(2)};
        end
        if isprop(e,'NewData')
            NewData = e.NewData;
        end
        %%% Applies to all files if ALL row was used
        if e.Indices(1)==size(h.Style_Table.Data,1)
            File=1:(size(h.Style_Table.Data,1)-1);
            if e.Indices(2)~=1
                h.Style_Table.Data(:,e.Indices(2))=deal({NewData});
            end
        else
            File=e.Indices(1);
        end
        switch e.Indices(2)
            case 1 %%% Changes file color
                if ~isdeployed
                    NewColor = uisetcolor;
                    if size(NewColor) == 1
                        return;
                    end
                elseif isdeployed %%% uisetcolor dialog does not work in compiled application
                    NewColor = color_setter(); % open dialog to input color
                end
                for i=File
                    h.Style_Table.Data{i,1} = num2str(NewColor);
                    GTauMeta.Plots{i,1}.Color=NewColor;
                    GTauMeta.Plots{i,2}.Color=NewColor;
                    GTauMeta.Plots{i,3}.Color=NewColor;
                    GTauMeta.Plots{i,4}.Color=NewColor;
                end
                if numel(File)>1
                    h.Style_Table.Data{end,1} = num2str(NewColor);
                end
                
            case 2 %%% Changes data line style
                for i=File
                    GTauMeta.Plots{i,1}.LineStyle=NewData;
                    GTauMeta.Plots{i,4}.LineStyle=NewData;
                end
            case 3 %%% Changes data line width
                for i=File
                    GTauMeta.Plots{i,1}.LineWidth=str2double(NewData);
                    GTauMeta.Plots{i,4}.LineWidth=str2double(NewData);
                end
            case 4 %%% Changes data marker style
                for i=File
                    GTauMeta.Plots{i,1}.Marker=NewData;
                    GTauMeta.Plots{i,4}.Marker=NewData;
                end
            case 5 %%% Changes data marker size
                for i=File
                    GTauMeta.Plots{i,1}.MarkerSize=str2double(NewData);
                    GTauMeta.Plots{i,4}.MarkerSize=str2double(NewData);
                end
            case 6 %%% Changes fit line style
                for i=File
                    GTauMeta.Plots{i,2}.LineStyle=NewData;
                    GTauMeta.Plots{i,3}.LineStyle=NewData;
                end
            case 7 %%% Changes fit line width
                for i=File
                    GTauMeta.Plots{i,2}.LineWidth=str2double(NewData);
                    GTauMeta.Plots{i,3}.LineWidth=str2double(NewData);
                end
            case 8 %%% Changes fit marker style
                for i=File
                    GTauMeta.Plots{i,2}.Marker=NewData;
                    GTauMeta.Plots{i,3}.Marker=NewData;
                end
            case 9 %%% Changes fit marker size
                for i=File
                    GTauMeta.Plots{i,2}.MarkerSize=str2double(NewData);
                    GTauMeta.Plots{i,3}.MarkerSize=str2double(NewData);
                end
            case 10 %%% Removes files
                File=flip(File,2);
                for i=File
                    GTauData.Data(i)=[];
                    GTauData.FileName(i)=[];
                    cellfun(@delete,GTauMeta.Plots(i,:));
                    GTauMeta.Data(i,:)=[];
                    GTauMeta.Params(:,i)=[];
                    GTauMeta.Plots(i,:)=[];
                    %h.Fit_Table.RowName(i)=[];
                    h.Fit_Table.Data(i,:)=[];
                    h.Style_Table.RowName(i)=[];
                    h.Style_Table.Data(i,:)=[];
                end
            case 11 %%% Renames Files
                if numel(File)>1
                    return;
                end
                NewName = inputdlg('Enter new filename');
                if ~isempty(NewName)
                    h.Style_Table.RowName{File} = NewName{1};
                    h.Fit_Table.Data{File,1} = NewName{1};
                    GTauData.FileName{File} = NewName{1};
                    Update_Plots;
                end                  
        end
    case 3 %%% rainbow button
        %%% make rainbow for all plots
        if size(h.Style_Table.Data,1) == 1
            return;
        end
        num_plots = size(h.Style_Table.Data,1) -1;
        switch obj
            case h.Style_Table_Rainbow
                if num_plots < 7
                    colors = flipud(prism(num_plots));
                else
                    colors = jet(num_plots);
                end
            case h.Style_Table_Autocolor
                colors = lines(num_plots);
        end
        for i = 1:num_plots
            h.Style_Table.Data{i,1} = num2str(colors(i,:));
            GTauMeta.Plots{i,1}.Color=colors(i,:);
            GTauMeta.Plots{i,2}.Color=colors(i,:);
            GTauMeta.Plots{i,3}.Color=colors(i,:);
            GTauMeta.Plots{i,4}.Color=colors(i,:);
        end
end
%%% Save Updated UiTableData to UserValues.GTauFit.PlotStyles
UserValues.GTauFit.PlotStyles(1:(size(h.Style_Table.Data,1)-1),1:8) = h.Style_Table.Data(1:(end-1),(1:8));
UserValues.GTauFit.PlotStyleAll = h.Style_Table.Data(end,1:8);
LSUserValues(1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Updates UserValues on settings change  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateOptions(obj,~)
h = guidata(obj);
global UserValues GTauData


UserValues.GTauFit.G{chan} = str2double(h.G_factor_edit.String);
UserValues.GTauFit.l1 = str2double(h.l1_edit.String);
UserValues.GTauFit.l2 = str2double(h.l2_edit.String);
UserValues.GTauFit.use_weighted_residuals = h.UseWeightedResiduals_Menu.Value;
UserValues.GTauFit.WeightedResidualsType = h.WeightedResidualsType_Menu.String{h.WeightedResidualsType_Menu.Value};

if obj == h.G_factor_edit
    %DetermineGFactor(obj)
end

UserValues.GTauFit.ConvolutionType = h.ConvolutionType_Menu.String{h.ConvolutionType_Menu.Value};
UserValues.GTauFit.LineStyle = h.LineStyle_Menu.String{h.LineStyle_Menu.Value};


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
        UserValues.GTauFit.cleanup_IRF = obj.Value;
    case h.UseWeightedResiduals_Menu
        UserValues.GTauFit.use_weighted_residuals = obj.Value;
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
    if ~isfield(GTauData,'OriginalHistograms')
        % first, copy original data so it is not lost
        GTauData.OriginalHistograms.hMI_Par= GTauData.hMI_Par;
        GTauData.OriginalHistograms.hMI_Per= GTauData.hMI_Per;
        GTauData.OriginalHistograms.hIRF_Par = GTauData.hIRF_Par;
        GTauData.OriginalHistograms.hIRF_Per = GTauData.hIRF_Per;
        GTauData.OriginalHistograms.hScat_Par = GTauData.hScat_Par;
        GTauData.OriginalHistograms.hScat_Per = GTauData.hScat_Per;
        GTauData.OriginalHistograms.TACChannelWidth = GTauData.TACChannelWidth;
    end
    if new_res > 1
        %%% Rebin histogram in TauFitData
        for i = 1:numel(GTauData.OriginalHistograms.hMI_Par) % loop over all channels
            GTauData.hMI_Par{i} = downsamplebin(GTauData.OriginalHistograms.hMI_Par{i},new_res);
            GTauData.hMI_Per{i} = downsamplebin(GTauData.OriginalHistograms.hMI_Per{i},new_res);
            GTauData.hIRF_Par{i} = downsamplebin(GTauData.OriginalHistograms.hIRF_Par{i},new_res)';
            GTauData.hIRF_Per{i} = downsamplebin(GTauData.OriginalHistograms.hIRF_Per{i},new_res)';
            GTauData.hScat_Par{i} = downsamplebin(GTauData.OriginalHistograms.hScat_Par{i},new_res)';
            GTauData.hScat_Per{i} = downsamplebin(GTauData.OriginalHistograms.hScat_Per{i},new_res)';
            GTauData.XData_Par{i} = 1:numel(GTauData.hMI_Par{i});
            GTauData.XData_Per{i} = 1:numel(GTauData.hMI_Per{i});
        end
        GTauData.TACChannelWidth = new_res*GTauData.OriginalHistograms.TACChannelWidth;
    elseif new_res == 1
        % copy old data back
        for i = 1:numel(GTauData.OriginalHistograms.hMI_Par) % loop over all channels
            GTauData.hMI_Par{i} = GTauData.OriginalHistograms.hMI_Par{i};
            GTauData.hMI_Per{i} = GTauData.OriginalHistograms.hMI_Per{i};
            GTauData.hIRF_Par{i} = GTauData.OriginalHistograms.hIRF_Par{i};
            GTauData.hIRF_Per{i} = GTauData.OriginalHistograms.hIRF_Per{i};
            GTauData.hScat_Par{i} = GTauData.OriginalHistograms.hScat_Par{i};
            GTauData.hScat_Per{i} = GTauData.OriginalHistograms.hScat_Per{i};
            GTauData.XData_Par{i} = 1:numel(GTauData.hMI_Par{i});
            GTauData.XData_Per{i} = 1:numel(GTauData.hMI_Per{i});
        end
        GTauData.TACChannelWidth = GTauData.OriginalHistograms.TACChannelWidth;
    end
    %%% Update Plots
    Update_Plots(h.Rebin_Histogram_Edit,[]);
end
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Below here, functions used for the fits start %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = interlace( a, x, fix )
a(~fix) = x;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions to load and save the session %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadSave_Session(obj,e)
global UserValues GTauData GTauMeta
h = guidata(obj);
switch obj
    case h.LoadSession
        %%% get file
        [FileName,PathName] = uigetfile({'*.GTauFit','GTauFit Session (*.GTauFit)'},'Load GTauFit Session',UserValues.File.GTauFitPath,'MultiSelect','off');
        if numel(FileName) == 1 && FileName == 0
            return;
        end
        %%% Saves pathname to uservalues
        UserValues.File.GTauFitPath=PathName;
        LSUserValues(1);
        %%% Deletes loaded data
        GTauData=[];
        GTauData.Data=[];
        GTauData.FileName=[];
        cellfun(@delete,GTauMeta.Plots);
        GTauMeta.Data=[];
        GTauMeta.Params=[];
        GTauMeta.Plots=cell(0);
        h.Fit_Table.Data(1:end-3,:)=[];
        h.Style_Table.RowName(1:end-1,:)=[];
        h.Style_Table.Data(1:end-1,:)=[];

        %%% load data
        data = load(fullfile(PathName,FileName),'-mat');
        %%% update global variables
        GTauData = data.GTauData;
        GTauMeta = data.GTauMeta;
        %%% update UserValues settings, with exception of export settings
        UserValues.GTauFit.Fit_Min = data.Settings.Fit_Min;
        UserValues.GTauFit.Fit_Max = data.Settings.Fit_Max;
        UserValues.GTauFit.Plot_Errorbars = data.Settings.Plot_Errorbars;
        UserValues.GTauFit.Fit_Tolerance = data.Settings.Fit_Tolerance;
        UserValues.GTauFit.Use_Weights = data.Settings.Use_Weights;
        UserValues.GTauFit.Max_Iterations = data.Settings.Max_Iterations;
        UserValues.GTauFit.NormalizationMethod = data.Settings.NormalizationMethod;
        UserValues.GTauFit.Hide_Legend = data.Settings.Hide_Legend;
        UserValues.GTauFit.Conf_Interval = data.Settings.Conf_Interval;
        UserValues.GTauFit.FRETbin = data.Settings.FRETbin;
        UserValues.GTauFit.PlotStyles = data.Settings.PlotStyles;
        UserValues.GTauFit.PlotStyleAll = data.Settings.PlotStyleAll;
        UserValues.File.GTauFit_Standard = GTauMeta.Model.Name;
        LSUserValues(1);
        %%% update GUI according to loaded settings
        h.Fit_Min.String = num2str(UserValues.GTauFit.Fit_Min);
        h.Fit_Max.String = num2str(UserValues.GTauFit.Fit_Max);
        h.Fit_Errorbars.Value = UserValues.GTauFit.Plot_Errorbars;
        h.Tolerance.String = num2str(UserValues.GTauFit.Fit_Tolerance);
        h.Fit_Weights.Value = UserValues.GTauFit.Use_Weights;
        h.Iterations.String = num2str(UserValues.GTauFit.Max_Iterations);
        h.Normalize.Value = UserValues.GTauFit.NormalizationMethod;
        h.Conf_Interval.Value = UserValues.GTauFit.Conf_Interval;
        h.Hide_Legend.Value = UserValues.GTauFit.Hide_Legend;
        h.FRETbin.String = num2str(UserValues.GTauFit.FRETbin);
        %%% update visuals
        Create_Plots([],[]);
        %%% Updates table and plot data and style to new size
        Update_Style([],[],0);
        Update_Style([],[],1);
        Update_Table([],[],0);
        %%% fill in active, fixed and global state
        if isfield(data,'FixState') && isfield(data,'GlobalState') && isfield(data,'ActiveState')
            h.Fit_Table.Data(1:end-3,6:3:end) = data.FixState;
            h.Fit_Table.Data(1:end-3,7:3:end) = data.GlobalState;
            h.Fit_Table.Data(end-2,7:3:end) = num2cell(sum(cell2mat(data.GlobalState),1) > 0);
            h.Fit_Table.Data(1:end-3,2) = data.ActiveState;
            Update_Plots;
        end
        %%% Updates model text
        [~,name,~] = fileparts(GTauMeta.Model.Name);
        name_text = {'Loaded Fit Model:';name;};
        h.Loaded_Model_Name.String = sprintf('%s\n',name_text{:});
        h.Loaded_Model_Description.String = sprintf('%s\n',GTauMeta.Model.Description{:});
        h.Loaded_Model_Description.TooltipString = sprintf('%s\n',GTauMeta.Model.Description{:});
    case h.SaveSession
        %%% get filename
        [FileName, PathName] = uiputfile({'*.GTauFit','GTauFit Session (*.GTauFit)'},'Save Session as ...',fullfile(UserValues.File.GTauFitPath,[GTauData.FileName{1},'.GTauFit']));
        %%% save all data
        data.GTauMeta = GTauMeta;
        data.GTauMeta.Plots = cell(0);
        data.GTauData = GTauData;
        data.Settings = UserValues.GTauFit;
        data.FixState = h.Fit_Table.Data(1:end-3,6:3:end);
        data.GlobalState = h.Fit_Table.Data(1:end-3,7:3:end);
        data.ActiveState = h.Fit_Table.Data(1:end-3,2);
        save(fullfile(PathName,FileName),'-struct','data');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions to create basic plots on data load %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Create_Plots(~,~)
global UserValues GTauMeta GTauData
h = guidata(findobj('Tag','GTauFit'));
switch GTauMeta.DataType
    case {'GTauFit averaged','GTauFit individual','GTauFit'} %%% Correlation files
        for i=1:numel(GTauData.FileName)
            %%% Creates new plots
            GTauMeta.Plots{end+1,1} = errorbar(...
                GTauMeta.Data{i,1},...
                GTauMeta.Data{i,2},...
                GTauMeta.Data{i,3},...
                'Parent',h.GTauFit_Axes);
            GTauMeta.Plots{end,2} = line(...
                'Parent',h.GTauFit_Axes,...
                'XData',GTauMeta.Data{i,1},...
                'YData',zeros(numel(GTauMeta.Data{i,1}),1));
            GTauMeta.Plots{end,3} = line(...
                'Parent',h.Residuals_Axes,...
                'XData',GTauMeta.Data{i,1},...
                'YData',zeros(numel(GTauMeta.Data{i,1}),1));
            GTauMeta.Plots{end,4} = line(...
                'Parent',h.GTauFit_Axes,...
                'XData',GTauMeta.Data{i,1},...
                'YData',GTauMeta.Data{i,2});
        end
        %%% change the gui
        SwitchGUI(h,'GTauFit');
    case 'FRET'   %% 2color FRET data from BurstBrowser
        for i=1:numel(GTauData.FileName)
            %%% Creates new plots
            GTauMeta.Plots{end+1,1} = errorbar(...
                GTauMeta.Data{i,1},...
                GTauMeta.Data{i,2},...
                GTauMeta.Data{i,3},...
                'Parent',h.GTauFit_Axes);
            GTauMeta.Plots{end,2} = line(...
                'Parent',h.GTauFit_Axes,...
                'XData',GTauMeta.Data{i,1},...
                'YData',zeros(numel(GTauMeta.Data{i,1}),1));
            GTauMeta.Plots{end,3} = line(...
                'Parent',h.Residuals_Axes,...
                'XData',GTauMeta.Data{i,1},...
                'YData',zeros(numel(GTauMeta.Data{i,1}),1));
            GTauMeta.Plots{end,4} = stairs(...
                GTauMeta.Data{i,1}-UserValues.GTauFit.FRETbin/2,...
                GTauMeta.Data{i,2},...
                'Parent',h.GTauFit_Axes);            
        end
        %%% change the gui
        SwitchGUI(h,'FRET');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions for various small callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Misc (obj,e,mode)
global UserValues
h = guidata(findobj('Tag','GTauFit'));

if nargin<3
   switch obj %%% Export Font Selection
       case h.Export_Font
           f = uisetfont;
           if ~isstruct(f)
               return;
           end
           f.FontString = ['Export Font: ' f.FontName];
           if strcmp(f.FontWeight, 'bold')
               f.FontString = [f.FontString ', b'];
           end
           if strcmp(f.FontAngle, 'italic')
               f.FontString = [f.FontString ', i'];
           end
           f.FontString = [f.FontString ' ,' num2str(f.FontSize)];
           
           obj.UserData = f;
           obj.String = f.FontString;
           UserValues.GTauFit.Export_Font = f;
           LSUserValues(1);
   end
    
end

