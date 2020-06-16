function GTFit(obj,~)
global UserValues GlobalTauData GlobalTauMeta PathToApp
h.GlobalTauFit=findobj('Tag','GlobalTauFit');

addpath(genpath(['.' filesep 'functions']));
LSUserValues(0);
method = '';
if isempty(PathToApp)
    GetAppFolder();
end
%%% If called from command line, or from Launcher
if (nargin < 1 && isempty(gcbo)) || (nargin < 1 && strcmp(get(gcbo,'Tag'),'GlobalTauFit_Launcher'))
    if ~isempty(findobj('Tag','GlobalTauFit'))
        CloseWindow(findobj('Tag','GlobalTauFit'))
    end
    %disp('Call TauFit from Pam or BurstBrowser instead of command line!');
    %return;
    GlobalTauData.Who = 'External';
    method = 'ensemble';
    obj = false;
end

if ~isempty(findobj('Tag','Pam'))
    ph = guidata(findobj('Tag','Pam'));
end


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %%% Disables uitabgroup warning
    warning('off','MATLAB:uitabgroup:OldVersion');   
    %%% Loads user profile    
    [~,~]=LSUserValues(0);
    %%% To save typing
    Look=UserValues.Look;    
    %%% Generates the GlobalTauFit figure
    h.GlobalTauFit = figure(...
        'Units','normalized',...
        'Tag','GlobalTauFit',...
        'Name','GlobalTauFit',...
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
    %h.GlobalTauFit.Visible='off';
    %%% Remove unneeded items from toolbar
    toolbar = findall(h.GlobalTauFit,'Type','uitoolbar');
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
    h.GlobalTauFit.Color=Look.Back;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Menubar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    %%% File menu with loading, saving and exporting functions
    h.File = uimenu(...
        'Parent',h.GlobalTauFit,...
        'Tag','File',...
        'Label','File');
    %%% Menu to load new Cor file
    h.LoadCor = uimenu(h.File,...
        'Tag','LoadCor',...
        'Label','Load New Files',...
        'Callback',{@Load_Cor,1});
    %%% Menu to add Cor files to existing
    h.AddCor = uimenu(h.File,...
        'Tag','AddCor',...
        'Label','Add Files',...
        'Callback',{@Load_Cor,2});
    %%% Menu to load fit function
    h.LoadFit = uimenu(h.File,...
        'Tag','LoadFit',...
        'Label','Load Fit Function',...
        'Callback',{@Load_Fit,1});
    %%% Menu to load fit function
    h.LoadSession = uimenu(h.File,...
        'Tag','LoadSession',...
        'Label','Load GlobalTauFit Session',...
        'Separator','on',...
        'Callback',@LoadSave_Session);
     h.SaveSession = uimenu(h.File,...
        'Tag','SaveSession',...
        'Label','Save GlobalTauFit Session',...
        'Callback',@LoadSave_Session);
    %%% Menu to merge loaded Cor files
    h.MergeCor = uimenu(h.File,...
        'Tag','MergeCor',...
        'Label','Merge Loaded Cor Files',...
        'Separator','on',...
        'Callback',@Merge_Cor);
    
    %%% File menu to stop fitting
    h.AbortFit = uimenu(...
        'Parent',h.GlobalTauFit,...
        'Tag','AbortFit',...
        'Label',' Stop....'); 
    h.StopFit = uimenu(...
        'Parent',h.AbortFit,...
        'Tag','StopFit',...
        'Label','...Fit',...
        'Callback',@Stop_GlobalTauFit);   
    %%% File menu for fitting
    h.StartFit = uimenu(...
        'Parent',h.GlobalTauFit,...
        'Tag','StartFit',...
        'Label','Start...');
    h.DoFit = uimenu(...
        'Parent',h.StartFit,...
        'Tag','Fit',...
        'Label','...Fit',...
        'Callback',@Do_GlobalTauFit);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Fitting parameters Tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.FitParams_Tab = uitabgroup(...
        'Parent',h.GlobalTauFit,...
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
    'Position',[0 0.9 0.1 0.07],...
    'String','Convolution Type',...
    'FontSize',10,...
    'Tag','ConvolutionType_Text');

h.ConvolutionType_Menu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'Position',[0.15 0.9 0.15 0.07],...
    'String',{'linear','circular'},...
    'Value',find(strcmp({'linear','circular'},UserValues.TauFit.ConvolutionType)),...
    'Tag','ConvolutionType_Menu');

h.LineStyle_Text = uicontrol(...
    'Style','text',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.3 0.9 0.45 0.07],...
    'String','Line Style (Result)',...
    'FontSize',10,...
    'Tag','LineStyle_Text');
h.LineStyle_Menu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'Position',[0.60 0.9 0.15 0.07],...
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
    'Position',[0.03 0.75 0.7 0.07],...
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
    'Position',[0.10 0.75 0.45 0.07],...
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
    'Position',[0.495 0.75 0.45 0.07],...
    'String','Use weighted residuals',...
    'Value',UserValues.TauFit.use_weighted_residuals,...
    'FontSize',10,...
    'Tag','UseWeightedResiduals_Menu',...
    'Callback',@UpdateOptions);
h.WeightedResidualsType_Menu = uicontrol(...
    'Style','popupmenu',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'Position',[0.60 0.75 0.15 0.07],...
    'String',{'Gaussian','Poissonian'},...
    'Value',find(strcmp({'Gaussian','Poissonian'},UserValues.TauFit.WeightedResidualsType)),...
    'Tag','WeightedResidualsType_Menu');
h.MCMC_Error_Estimation_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.03 0.55 0.45 0.07],...
    'String','Perform MCMC error estimation?',...
    'FontSize',10,...
    'TooltipString',sprintf('Performs Markov Chain Monte Carlo sampling using the Metropolis-Hasting algorithm\nto estimate the posterior distribution of the model parameters.'),...
    'Tag','NormalizeScatter_Menu',...
    'Callback',[]);
h.Cleanup_IRF_Menu = uicontrol(...
    'Style','checkbox',...
    'Parent',h.Settings_Panel,...
    'Units','normalized',...
    'BackgroundColor',Look.Back,...
    'ForegroundColor',Look.Fore,...
    'Position',[0.495 0.55 0.45 0.07],...
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
%% Settings tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    'String',num2str(UserValues.TauFit.l1),...
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
    'String',num2str(UserValues.TauFit.l2),...
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
 
%% %% Main Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Panel for fit plots
    h.Fit_Plots_Panel = uibuttongroup(...
        'Parent',h.GlobalTauFit,...
        'Tag','Fit_Plots_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0.005 0.26 0.99 0.73]);
    
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
    GlobalTauData=[];
    GlobalTauData.Data=[];
    GlobalTauData.FileName=[];
    GlobalTauMeta=[];
    GlobalTauMeta.Data=[];
    GlobalTauMeta.Params=[];
    GlobalTauMeta.Confidence_Intervals = cell(1,1);
    GlobalTauMeta.Plots=cell(0);
    GlobalTauMeta.Model=[];
    GlobalTauMeta.Fits=[];
    GlobalTauMeta.Color=[1 1 0; 0 0 1; 1 0 0; 0 0.5 0; 1 0 1; 0 1 1];
    GlobalTauMeta.FitInProgress = 0;    
    GlobalTauMeta.DataType = 'GlobalTau averaged';
    
    h.CurrentGui = 'GlobalTau';
    guidata(h.GlobalTauFit,h); 
    Load_Fit([],[],0);
    Update_Style([],[],0) 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to load .cor files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Cor(~,~,mode,filenames)
global UserValues GlobalTauData GlobalTauMeta
h = guidata(findobj('Tag','GlobalTauFit'));

if nargin > 3 %%% called from file history
    %%% only implemented for loading of *.mcor files at the moment, remove
    %%% all other files
    Type = 1;
    %%% split filenames into FileName and pathname
    for i = 1:numel(filenames)
        [PathName{i},FileName{i},ext] = fileparts(filenames{i});
        FileName{i} = [FileName{i} ext];
    end
else
    %%% there is an issue with selecting multiple files on MacOS Catalina,
    %%% where only the first filter (.mcor) works, and no other file types 
    %%% can be selected.
    %%% As a workaround, we avoid using the system file selection for now.
    %%% 11/2019    
    if ~ismac | ~(ismac & strcmp(get_macos_version(),'10.15'))
        %%% Choose files to load
        [FileName,path,Type] = uigetfile({'*.dec','Pam decay file (*.dec)'},...
                                          'Choose GlobalTau data files',...
                                          UserValues.File.FCSPath,... 
                                          'MultiSelect', 'on');
    else
        %%% use workaround
        %%% Choose files to load
        [FileName, path, Type] = uigetfile_with_preview({'*.dec','Pam decay file (*.dec)'},...
                                          UserValues.File.FCSPath,... 
                                          '',... % empty callback
                                          true); % Multiselect on
    end
    %%% Tranforms to cell array, if only one file was selected
    if ~iscell(FileName)
        FileName = {FileName};
    end
    %%% assign path to each filename
    for i = 1:numel(FileName)
        PathName{i} = path;
    end
end


%%% Only esecutes, if at least one file was selected
if all(FileName{1}==0)
    return
end

%%% Saves pathname to uservalues
UserValues.File.GlobalTauPath=PathName{1};
LSUserValues(1);
%%% Deletes loaded data
if mode==1
    GlobalTauData=[];
    GlobalTauData.Data=[];
    GlobalTauData.FileName=[];
    cellfun(@delete,GlobalTauMeta.Plots);
    GlobalTauMeta.Data=[];
    GlobalTauMeta.Params=[];
    GlobalTauMeta.Plots=cell(0);
    %h.Fit_Table.RowName(1:end-3)=[];
    h.Fit_Table.Data(1:end-3,:)=[];
    h.Style_Table.RowName(1:end-1,:)=[];
    h.Style_Table.Data(1:end-1,:)=[];
end

switch Type
    case {1} %%% Pam decay files
        GlobalTauMeta.DataType = 'GlobalTau';
        for i=1:numel(FileName)
           
           %%% called upon loading of text-based *.dec file
                    %%% load file
                    %[FileName, PathName, FilterIndex] = uigetfile({'*.dec','PAM decay file'},'Choose data file...',UserValues.File.TauFitPath,'Multiselect','on');
             
                    GlobalTauData.External = struct;
                    GlobalTauData.External.MI_Hist = {};
                    GlobalTauData.External.IRF = {};
                    GlobalTauData.External.Scat = {};
                    for j = 1:numel(FileName) %%% assumes that all loaded files have shared parameters! (i.e. TAC range etc)
                        decay_data = dlmread(fullfile(path,FileName{j}),'\t',6,0);
                        %%% read other data
                        fid = fopen(fullfile(path,FileName{j}),'r');
                        TAC = textscan(fid,'TAC range [ns]:\t%f\n'); GlobalTauData.TACRange = TAC{1}*1E-9;
                        MI_Bins = textscan(fid,'Microtime Bins:\t%f\n'); GlobalTauData.MI_Bins = MI_Bins{1};
                        TACChannelWidth = textscan(fid,'Resolution [ps]:\t%f\n'); GlobalTauData.TACChannelWidth = TACChannelWidth{1}*1E-3;
                        fid = fopen(fullfile(path,FileName{j}),'r');
                        for i = 1:5
                            line = fgetl(fid);
                        end
                        PIEchans{j} = strsplit(line,'\t');
                        PIEchans{j}(cellfun(@isempty,PIEchans{j})) = [];
                        if numel(FileName) > 1 %%% multiple files loaded, append the file name to avoid confusion of identically named PIE channels
                            for i = 1:numel(PIEchans{j})
                                PIEchans{j}{i} = [PIEchans{j}{i} ' - ' FileName{j}(1:end-4)];
                            end
                        end
                        %%% sort data into TauFitData structure (MI,IRF,Scat)
                        for i = 1:(size(decay_data,2)/3)
                            GlobalTauData.External.MI_Hist{end+1} = decay_data(:,3*(i-1)+1);
                            GlobalTauData.External.IRF{end+1} = decay_data(:,3*(i-1)+2);
                            GlobalTauData.External.Scat{end+1} = decay_data(:,3*(i-1)+3);
                        end
                    end
                    PIEchans = horzcat(PIEchans{:});
                    %%% update PIE channel selection with available PIE channels
                    h.PIEChannelPar_Popupmenu.String = PIEchans;
                    h.PIEChannelPer_Popupmenu.String = PIEchans;
                    %%% mark TauFit mode as external
                    GlobalTauData.Who = 'External';
                    GlobalTauData.FileName = fullfile(path,FileName{1});
                    if numel(PIEchans) == 1
                        PIEChannel_Par = 1; PIEChannel_Per = 1;
                    else
                        PIEChannel_Par = 1; PIEChannel_Per = 2;
                    end
                    h.PIEChannelPar_Popupmenu.Value = PIEChannel_Par;
                    h.PIEChannelPer_Popupmenu.Value = PIEChannel_Per;
        end
        %%% change the gui
        SwitchGUI(h,'GlobalTau');

%%% Updates table and plot data and style to new size
Update_Style([],[],1);
Update_Table([],[],1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to switch GUI between FRET and GlobalTau %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SwitchGUI(handles,toType)
global UserValues
if isempty(handles)
    handles = guidata(gcf);
end
if strcmp(toType,handles.CurrentGui)
    return;
end
if strcmp(handles.CurrentGui,'GlobalTau') %%% switch to FRET
    %%% change the minmax boundaries for plot
    handles.Fit_Min.String = '-0.1';
    handles.Fit_Max.String = '1';
    %%% hide normalization box and set to none
    handles.Normalize.Visible = 'off';
    handles.Normalize.Value = 1;
    handles.Norm_Text.Visible = 'off';
    handles.Norm_Time.Visible = 'off';
    %%% disable XLOG menu point for main axis
    handles.GlobalTau_Plot_XLog.Visible = 'off';
    handles.GlobalTau_Plot_XLog.Checked = 'off';
    handles.GlobalTau_Axes.XScale='lin';
    handles.Residuals_Axes.XScale = 'lin';
    %%% Change axis labels
    handles.GlobalTau_Axes.XLabel.String = 'FRET efficiency';
    handles.GlobalTau_Axes.YLabel.String = 'PDF';
    %%% show FRET binning controls
    handles.FRETbin_Text.Visible = 'on';
    handles.FRETbin.Visible = 'on';
    
    handles.CurrentGui = 'FRET';
elseif strcmp(handles.CurrentGui,'FRET') %%% switch to GlobalTau
     %%% change the minmax boundaries for plot
    handles.Fit_Min.String = num2str(UserValues.GlobalTauFit.Fit_Min);
    handles.Fit_Max.String = num2str(UserValues.GlobalTauFit.Fit_Max);
    %%% hide normalization box and set to none
    handles.Normalize.Visible = 'on';
    handles.Normalize.Value = UserValues.GlobalTauFit.NormalizationMethod;
    handles.Norm_Text.Visible = 'on';
    handles.Norm_Time.Visible = 'on';
    %%% disable XLOG menu point for main axis
    handles.GlobalTau_Plot_XLog.Visible = 'on';
    handles.GlobalTau_Plot_XLog.Checked = 'on';
    handles.GlobalTau_Axes.XScale='log';
    handles.Residuals_Axes.XScale = 'log';
     %%% Change axis labels
    handles.GlobalTau_Axes.XLabel.String = 'time lag {\it\tau{}} [s]';
    handles.GlobalTau_Axes.YLabel.String = 'G({\it\tau{}})';
    %%% hide FRET binning controls
    handles.FRETbin_Text.Visible = 'off';
    handles.FRETbin.Visible = 'off';
    
    handles.CurrentGui = 'GlobalTau';
end

guidata(handles.GlobalTauFit,handles); 





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to save merged .cor file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Merge_Cor(~,~)
global UserValues GlobalTauData GlobalTauMeta
h = guidata(findobj('Tag','GlobalTauFit'));

%%% Merge only the active files
active = find(cell2mat(h.Fit_Table.Data(1:end-3,1)));
%%% check for length difference
len = zeros(1,numel(active));
k = 1;
for i = active'
    len(k) = numel(GlobalTauData.Data{i}.Cor_Times);
    k = k+1;
end
minlen = min(len);
minlen_ix = find(len == min(len));

Valid = [];
Cor_Array = [];
Header = cell(0);
Counts = [0,0];
switch GlobalTauMeta.DataType
    case 'GlobalTau averaged'
        % multiple averaged file were loaded
        Cor_Times = GlobalTauData.Data{active(minlen_ix(1))}.Cor_Times; % Take Cor_Times from first file, should be same for all.
        for i = active'
            Valid = [Valid, GlobalTauData.Data{i}.Valid];
            Cor_Array = [Cor_Array, GlobalTauData.Data{i}.Cor_Array(1:minlen,:)];
            Header{end+1} = GlobalTauData.Data{i}.Header;
            Counts = Counts + GlobalTauData.Data{i}.Counts;
        end
    case 'GlobalTau individual'
        % individual curves from 1 file were loaded
        Cor_Times = GlobalTauMeta.Data{active(minlen_ix(1)),1}; % Take Cor_Times from first file, should be same for all.
        for i = active'
            Valid = [Valid, 1];
            Cor_Array = [Cor_Array, GlobalTauMeta.Data{i,2}(1:minlen,:)];
            Header{end+1} = GlobalTauData.Data{i}.Header;
            Counts = Counts + GlobalTauData.Data{i}.Counts;
        end
end
Counts = Counts./numel(active);

%%% Recalculate Average and SEM
Cor_Average=mean(Cor_Array,2);
%%% Averages files before saving to reduce errorbars
Amplitude=sum(Cor_Array,1);
Cor_Norm=Cor_Array./repmat(Amplitude,[size(Cor_Array,1),1])*mean(Amplitude);
Cor_SEM=std(Cor_Norm,0,2)/sqrt(size(Cor_Array,2));
%%% Pick FileName
[FileName,PathName] = uiputfile({'*.mcor'},'Choose a filename for the merged file',fullfile(UserValues.File.GlobalTauPath,GlobalTauData.FileName{active(1)}));
if FileName == 0
    m = msgbox('No valid filepath specified... Canceling');
    pause(1);
    delete(m);
    return;
end
Current_FileName = fullfile(PathName,FileName);
%%% Save
save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes fit function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Fit(~,~,mode)
global GlobalTauMeta UserValues PathToApp
h = guidata(findobj('Tag','GlobalTauFit'));
FileName=[];
FilterIndex = 1;
if mode
    %% Select a new model to load
    [FileName,PathName,FilterIndex]= uigetfile('.txt', 'Choose a fit model', [PathToApp filesep 'Models']);
    FileName=fullfile(PathName,FileName);
elseif isempty(UserValues.File.FCS_Standard) || ~exist(UserValues.File.FCS_Standard,'file') 
    %% Opens the first model in the folder at the start of the program
    Models=dir([PathToApp filesep 'Models']);
    Models=Models(~cell2mat({Models.isdir}));
    while isempty(FileName) && ~isempty(Models)
       if strcmp(Models(1).name(end-3:end),'.txt') 
           FileName=[PathToApp filesep 'Models' filesep Models(1).name];
           UserValues.File.GlobalTau_Standard=FileName;
       else
           Models(1)=[];
       end
    end
else
    %% Opens last model used before closing program
    FileName=UserValues.File.FCS_Standard;
end

if ~isempty(FileName) && ~(FilterIndex == 0)
    UserValues.File.FCS_Standard=FileName;
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
    GlobalTauMeta.Model=[];
    GlobalTauMeta.Model.Name=FileName;
    GlobalTauMeta.Model.Description = description;
    GlobalTauMeta.Model.Brightness=Text{B_Start+1};
    %%% Concaternates the function string
    GlobalTauMeta.Model.Function=[];
    for i=Fun_Start+1:numel(Text)
        GlobalTauMeta.Model.Function=[GlobalTauMeta.Model.Function Text(i)];
    end
    GlobalTauMeta.Model.Function=cell2mat(GlobalTauMeta.Model.Function);
    %%% Convert to function handle
    FunctionStart = strfind(GlobalTauMeta.Model.Function,'=');
    eval(['GlobalTauMeta.Model.Function = @(P,x) ' GlobalTauMeta.Model.Function((FunctionStart(1)+1):end) ';']);
    %%% Extracts parameter names and initial values
    GlobalTauMeta.Model.Params=cell(NParams,1);
    GlobalTauMeta.Model.Value=zeros(NParams,1);
    GlobalTauMeta.Model.LowerBoundaries = zeros(NParams,1);
    GlobalTauMeta.Model.UpperBoundaries = zeros(NParams,1);
    GlobalTauMeta.Model.State = zeros(NParams,1);
    %%% Reads parameters and values from file
    for i=1:NParams
        Param_Pos=strfind(Text{i+Param_Start},' ');
        GlobalTauMeta.Model.Params{i}=Text{i+Param_Start}((Param_Pos(1)+1):(Param_Pos(2)-1));
        Start = strfind(Text{i+Param_Start},'=');
        %Stop = strfind(Text{i+Param_Start},';');
        % Filter more specifically (this enables the use of html greek
        % letters like &mu; etc.)
        [~, Stop] = regexp(Text{i+Param_Start},'(\d+;|Inf;)');
        GlobalTauMeta.Model.Value(i) = str2double(Text{i+Param_Start}(Start(1)+1:Stop(1)-1));
        GlobalTauMeta.Model.LowerBoundaries(i) = str2double(Text{i+Param_Start}(Start(2)+1:Stop(2)-1));   
        GlobalTauMeta.Model.UpperBoundaries(i) = str2double(Text{i+Param_Start}(Start(3)+1:Stop(3)-1));
        if numel(Text{i+Param_Start})>Stop(3) && any(strfind(Text{i+Param_Start}(Stop(3):end),'g'))
            GlobalTauMeta.Model.State(i) = 2;
        elseif numel(Text{i+Param_Start})>Stop(3) && any(strfind(Text{i+Param_Start}(Stop(3):end),'f'))
            GlobalTauMeta.Model.State(i) = 1;
        end
    end    
    GlobalTauMeta.Params=repmat(GlobalTauMeta.Model.Value,[1,size(GlobalTauMeta.Data,1)]);
    
    %%% Updates table to new model
    Update_Table([],[],0);
    %%% Updates model text
    [~,name,~] = fileparts(GlobalTauMeta.Model.Name);
    name_text = {'Loaded Fit Model:';name;};
    h.Loaded_Model_Name.String = sprintf('%s\n',name_text{:});
    h.Loaded_Model_Description.String = sprintf('%s\n',description{:});
    h.Loaded_Model_Description.TooltipString = sprintf('%s\n',description{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that updates fit table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Table(~,e,mode)
h = guidata(findobj('Tag','GlobalTauFit'));
global GlobalTauMeta GlobalTauData
switch mode
    case 0 %%% Updates whole table (Load Fit etc.)
        
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];        
        %%% Generates column names and resized them
        Columns=cell(3*numel(GlobalTauMeta.Model.Params)+5,1);
        Columns{1} = '<HTML><b>File</b>';
        Columns{2}='<HTML><b>Active</b>';
        Columns{3}='<HTML><b>Counts [kHz]</b>';
        Columns{4}='<HTML><b>Brightness [kHz]</b>';
        for i=1:numel(GlobalTauMeta.Model.Params)
            Columns{3*i+2}=['<HTML><b>' GlobalTauMeta.Model.Params{i} '</b>'];
            Columns{3*i+3}='<HTML><b>F</b>';
            Columns{3*i+4}='<HTML><b>G</b>';
        end
        Columns{end}='<HTML><b>Chi2</b>';
        ColumnWidth=cell(1,numel(Columns));
        %ColumnWidth(4:3:end-1)=cellfun('length',GlobalTauMeta.Model.Params).*7;
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
        Rows=cell(numel(GlobalTauData.Data)+3,1);
        tmp = GlobalTauData.FileName;
        for i = 1:numel(tmp)
            tmp{i} = ['<HTML><b>' tmp{i} '</b>'];
        end
        Rows(1:numel(GlobalTauData.Data))=deal(tmp);
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
            if GlobalTauData.Data{i}.Counts(1) == GlobalTauData.Data{i}.Counts(2)
                %%% Autocorrelation
                Data{i,2}=num2str(GlobalTauData.Data{i}.Counts(1));
            elseif GlobalTauData.Data{i}.Counts(1) ~= GlobalTauData.Data{i}.Counts(2)
                %%% Crosscorrelation
                Data{i,2}=num2str(sum(GlobalTauData.Data{i}.Counts));
            end
        end
        Data(1:end-3,4:3:end-1)=deal(num2cell(GlobalTauMeta.Params)');
        Data(end-2,4:3:end-1)=deal(num2cell(GlobalTauMeta.Model.Value)');
        Data(end-1,4:3:end-1)=deal(num2cell(GlobalTauMeta.Model.LowerBoundaries)');
        Data(end,4:3:end-1)=deal(num2cell(GlobalTauMeta.Model.UpperBoundaries)');
        Data=cellfun(@num2str,Data,'UniformOutput',false);
        Data(1:end-2,5:3:end-1) = repmat(num2cell(GlobalTauMeta.Model.State==1)',size(Data,1)-2,1);        
        Data(end-1:end,5:3:end-1)=deal({[]});
        Data(1:end-2,6:3:end-1) = repmat(num2cell(GlobalTauMeta.Model.State==2)',size(Data,1)-2,1);
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
        Rows=cell(numel(GlobalTauData.Data)+3,1);
        tmp = GlobalTauData.FileName;

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
        for i=1:numel(GlobalTauData.Data)
            %%% Distinguish between Autocorrelation (only take Counts of
            %%% Channel) and Crosscorrelation (take sum of Channels)
            if GlobalTauData.Data{i}.Counts(1) == GlobalTauData.Data{i}.Counts(2)
                %%% Autocorrelation
                Data{i,2}=num2str(GlobalTauData.Data{i}.Counts(1));
            elseif GlobalTauData.Data{i}.Counts(1) ~= GlobalTauData.Data{i}.Counts(2)
                %%% Crosscorrelation
                Data{i,2}=num2str(sum(GlobalTauData.Data{i}.Counts));
            end
        end
        h.Fit_Table.Data=[Rows,Data];
        h.Fit_Table.ColumnWidth(1) = {7*max(cellfun('prodofsize',Rows))};
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 2 %%% Updates table after fit
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        %%% Updates Brightness in Table
        for i=1:(size(h.Fit_Table.Data,1)-3)
            P=GlobalTauMeta.Params(:,i);
            eval(GlobalTauMeta.Model.Brightness);
            h.Fit_Table.Data{i,4}= num2str(str2double(h.Fit_Table.Data{i,3}).*B);
        end
        %%% Updates parameter values in table
        h.Fit_Table.Data(1:end-3,5:3:end-1)=cellfun(@num2str,num2cell(GlobalTauMeta.Params)','UniformOutput',false);
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
                    GlobalTauMeta.Params((e.Indices(2)-2)/3,:)=str2double(NewData);
                elseif mod(e.Indices(2)-6,3)==0 && e.Indices(2)>=6 && NewData==1
                    %% Value was fixed => Uncheck global
                    h.Fit_Table.Data(1:end-2,e.Indices(2)+1)=deal({false});
                elseif mod(e.Indices(2)-7,3)==0 && e.Indices(2)>=7 && NewData==1
                    %% Global was change
                    %%% Apply value to all files
                    h.Fit_Table.Data(1:end-2,e.Indices(2)-2)=h.Fit_Table.Data(e.Indices(1),e.Indices(2)-2);
                    %%% Apply value to global variables
                    GlobalTauMeta.Params((e.Indices(2)-4)/3,:)=str2double(h.Fit_Table.Data{e.Indices(1),e.Indices(2)-2});
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
                GlobalTauMeta.Params((e.Indices(2)-4)/3,:)=str2double(h.Fit_Table.Data{e.Indices(1),e.Indices(2)-2});
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
                GlobalTauMeta.Params((e.Indices(2)-2)/3,:)=str2double(NewData);
            else
                %% Not global => only changes value
                GlobalTauMeta.Params((e.Indices(2)-2)/3,e.Indices(1))=str2double(NewData);
                
            end
        elseif e.Indices(2)==1
            %% Active was changed
            a = 1;
        end       
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes plotting style %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Style(obj,e,mode) 
global GlobalTauMeta GlobalTauData UserValues
h = guidata(findobj('Tag','GlobalTauFit'));
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
        h.Style_Table.Data=UserValues.FCSFit.PlotStyleAll(1:8);        
    case 1 %%% Called, when new file is loaded
        %%% Sets row names to file names 
        Rows=cell(numel(GlobalTauData.Data)+1,1);
        %Rows(1:numel(GlobalTauData.Data))=deal(GlobalTauData.FileName);
        Rows{end}='ALL';
        h.Style_Table.RowName=Rows;
        Data=cell(numel(Rows),size(h.Style_Table.Data,2));
        %%% Sets ALL style to last row
        %Data(end,1:8)=UserValues.GlobalTauFit.PlotStyleAll(1:8);
        %%% Sets previous styles to first rows
        for i=1:numel(GlobalTauData.Data)
            if i<=size(UserValues.GlobalTauFit.PlotStyles,1)
                Data(i,1:8) = UserValues.GlobalTauFit.PlotStyles(i,1:8);
            else
                Data(i,:) = UserValues.GlobalTauFit.PlotStyles(end,1:8);
            end
        end
        %%% Updates new plots to style
        for i=1:numel(GlobalTauData.FileName)
           GlobalTauMeta.Plots{i,1}.Color=str2num(Data{i,1}); %#ok<*ST2NM>
           GlobalTauMeta.Plots{i,4}.Color=str2num(Data{i,1});
           GlobalTauMeta.Plots{i,2}.Color=str2num(Data{i,1});
           GlobalTauMeta.Plots{i,3}.Color=str2num(Data{i,1});
           GlobalTauMeta.Plots{i,1}.LineStyle=Data{i,2};
           GlobalTauMeta.Plots{i,1}.LineWidth=str2double(Data{i,3});
           GlobalTauMeta.Plots{i,1}.Marker=Data{i,4};
           GlobalTauMeta.Plots{i,1}.MarkerSize=str2double(Data{i,5});
           GlobalTauMeta.Plots{i,4}.LineStyle=Data{i,2};
           GlobalTauMeta.Plots{i,4}.LineWidth=str2double(Data{i,3});
           GlobalTauMeta.Plots{i,4}.Marker=Data{i,4};
           GlobalTauMeta.Plots{i,4}.MarkerSize=str2double(Data{i,5});
           GlobalTauMeta.Plots{i,2}.LineStyle=Data{i,6};
           GlobalTauMeta.Plots{i,3}.LineStyle=Data{i,6};
           GlobalTauMeta.Plots{i,2}.LineWidth=str2double(Data{i,7});
           GlobalTauMeta.Plots{i,3}.LineWidth=str2double(Data{i,7});
           GlobalTauMeta.Plots{i,2}.Marker=Data{i,8};
           GlobalTauMeta.Plots{i,3}.Marker=Data{i,8};
           GlobalTauMeta.Plots{i,2}.MarkerSize=str2double(Data{i,7});
           GlobalTauMeta.Plots{i,3}.MarkerSize=str2double(Data{i,7});
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
                    GlobalTauMeta.Plots{i,1}.Color=NewColor;
                    GlobalTauMeta.Plots{i,2}.Color=NewColor;
                    GlobalTauMeta.Plots{i,3}.Color=NewColor;
                    GlobalTauMeta.Plots{i,4}.Color=NewColor;
                end
                if numel(File)>1
                    h.Style_Table.Data{end,1} = num2str(NewColor);
                end
                
            case 2 %%% Changes data line style
                for i=File
                    GlobalTauMeta.Plots{i,1}.LineStyle=NewData;
                    GlobalTauMeta.Plots{i,4}.LineStyle=NewData;
                end
            case 3 %%% Changes data line width
                for i=File
                    GlobalTauMeta.Plots{i,1}.LineWidth=str2double(NewData);
                    GlobalTauMeta.Plots{i,4}.LineWidth=str2double(NewData);
                end
            case 4 %%% Changes data marker style
                for i=File
                    GlobalTauMeta.Plots{i,1}.Marker=NewData;
                    GlobalTauMeta.Plots{i,4}.Marker=NewData;
                end
            case 5 %%% Changes data marker size
                for i=File
                    GlobalTauMeta.Plots{i,1}.MarkerSize=str2double(NewData);
                    GlobalTauMeta.Plots{i,4}.MarkerSize=str2double(NewData);
                end
            case 6 %%% Changes fit line style
                for i=File
                    GlobalTauMeta.Plots{i,2}.LineStyle=NewData;
                    GlobalTauMeta.Plots{i,3}.LineStyle=NewData;
                end
            case 7 %%% Changes fit line width
                for i=File
                    GlobalTauMeta.Plots{i,2}.LineWidth=str2double(NewData);
                    GlobalTauMeta.Plots{i,3}.LineWidth=str2double(NewData);
                end
            case 8 %%% Changes fit marker style
                for i=File
                    GlobalTauMeta.Plots{i,2}.Marker=NewData;
                    GlobalTauMeta.Plots{i,3}.Marker=NewData;
                end
            case 9 %%% Changes fit marker size
                for i=File
                    GlobalTauMeta.Plots{i,2}.MarkerSize=str2double(NewData);
                    GlobalTauMeta.Plots{i,3}.MarkerSize=str2double(NewData);
                end
            case 10 %%% Removes files
                File=flip(File,2);
                for i=File
                    GlobalTauData.Data(i)=[];
                    GlobalTauData.FileName(i)=[];
                    cellfun(@delete,GlobalTauMeta.Plots(i,:));
                    GlobalTauMeta.Data(i,:)=[];
                    GlobalTauMeta.Params(:,i)=[];
                    GlobalTauMeta.Plots(i,:)=[];
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
                    GlobalTauData.FileName{File} = NewName{1};
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
            GlobalTauMeta.Plots{i,1}.Color=colors(i,:);
            GlobalTauMeta.Plots{i,2}.Color=colors(i,:);
            GlobalTauMeta.Plots{i,3}.Color=colors(i,:);
            GlobalTauMeta.Plots{i,4}.Color=colors(i,:);
        end
end
%%% Save Updated UiTableData to UserValues.GlobalTauFit.PlotStyles
UserValues.GlobalTauFit.PlotStyles(1:(size(h.Style_Table.Data,1)-1),1:8) = h.Style_Table.Data(1:(end-1),(1:8));
UserValues.GlobalTauFit.PlotStyleAll = h.Style_Table.Data(end,1:8);
LSUserValues(1);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  General Function to Update Plots when something changed %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(obj,~)
global UserValues GlobalTauData
h = guidata(findobj('Tag','GlobalTauFit'));



G = str2double(h.G_factor_edit.String);
l1 = str2double(h.l1_edit.String);
l2 = str2double(h.l2_edit.String);


% nanoseconds per microtime bin
TACtoTime = GlobalTauData.TACChannelWidth;%1/TauFitData.MI_Bins*TauFitData.TACRange*1e9;

if isempty(obj) || strcmp(dummy,'pushbutton') || strcmp(dummy,'popupmenu') || isempty(dummy)
    %LoadData button or Burstwise lifetime button was pressed
    %%% Plot the Data
    % anders, Should data be plotted at this point?
    h.Plots.Decay_Par.XData = GlobalTauData.XData_Par{chan}*TACtoTime;
    h.Plots.Decay_Per.XData = GlobalTauData.XData_Per{chan}*TACtoTime;
    h.Plots.IRF_Par.XData = GlobalTauData.XData_Par{chan}*TACtoTime;
    h.Plots.IRF_Per.XData = GlobalTauData.XData_Per{chan}*TACtoTime;
    h.Plots.Scat_Par.XData = GlobalTauData.XData_Par{chan}*TACtoTime;
    h.Plots.Scat_Per.XData = GlobalTauData.XData_Per{chan}*TACtoTime;
    h.Plots.Decay_Par.YData = GlobalTauData.hMI_Par{chan};
    h.Plots.Decay_Per.YData = GlobalTauData.hMI_Per{chan};
    h.Plots.IRF_Par.YData = GlobalTauData.hIRF_Par{chan};
    h.Plots.IRF_Per.YData = GlobalTauData.hIRF_Per{chan};
    h.Plots.Scat_Par.YData = GlobalTauData.hScat_Par{chan};
    h.Plots.Scat_Per.YData = GlobalTauData.hScat_Per{chan};
    h.Microtime_Plot.XLim = [min([GlobalTauData.XData_Par{chan}*TACtoTime GlobalTauData.XData_Per{chan}*TACtoTime]) max([GlobalTauData.XData_Par{chan}*TACtoTime GlobalTauData.XData_Per{chan}*TACtoTime])];
    try
        h.Microtime_Plot.YLim = [min([GlobalTauData.hMI_Par{chan}; GlobalTauData.hMI_Per{chan}]) 10/9*max([GlobalTauData.hMI_Par{chan}; GlobalTauData.hMI_Per{chan}])];
    catch
        % if there is no data, disable channel and stop
        h.IncludeChannel_checkbox.Value = 0;
        UserValues.GlobalTauFit.IncludeChannel(h.ChannelSelect_Popupmenu.Value) = 0;
        LSUserValues(1);
        return
    end
    %%% Define the Slider properties
    %%% Values to consider:
    %%% The length of the shortest PIE channel
    GlobalTauData.MaxLength{chan} = min([numel(GlobalTauData.hMI_Par{chan}) numel(GlobalTauData.hMI_Per{chan})]);
    
    %%% The Length Slider defaults to the length of the shortest PIE
    %%% channel and should not assume larger values
    h.Length_Slider.Min = 1;
    h.Length_Slider.Max = GlobalTauData.MaxLength{chan};
    h.Length_Slider.SliderStep =[1, 10]*(1/(h.Length_Slider.Max-h.Length_Slider.Min));
    if UserValues.GlobalTauFit.Length{chan} > 0 && UserValues.GlobalTauFit.Length{chan} < GlobalTauData.MaxLength{chan}+1
        tmp = UserValues.GlobalTauFit.Length{chan};
    else
        tmp = GlobalTauData.MaxLength{chan};
    end
    h.Length_Slider.Value = tmp;
    GlobalTauData.Length{chan} = tmp;
    h.Length_Edit.String = num2str(tmp);
    
    %%% Start Parallel Slider can assume values from 0 (no shift) up to the
    %%% length of the shortest PIE channel minus the set length
    h.StartPar_Slider.Min = 0;
    h.StartPar_Slider.Max = floor(GlobalTauData.MaxLength{chan}/5);
    h.StartPar_Slider.SliderStep =[1, 10]*(1/(h.StartPar_Slider.Max-h.StartPar_Slider.Min));
    if UserValues.TauFit.StartPar{chan} >= 0 && UserValues.TauFit.StartPar{chan} <= floor(GlobalTauData.MaxLength{chan}/5)
        tmp = UserValues.TauFit.StartPar{chan};
    else
        tmp = 0;
    end
    h.StartPar_Slider.Value = tmp;
    GlobalTauData.StartPar{chan} = tmp;
    h.StartPar_Edit.String = num2str(tmp);
    
    %%% Shift Perpendicular Slider can assume values from the difference in
    %%% start point between parallel and perpendicular up to the difference
    %%% between the end point of the parallel channel and the start point
    %%% of the perpendicular channel
    h.ShiftPer_Slider.Min = -floor(GlobalTauData.MaxLength{chan}/20);
    h.ShiftPer_Slider.Max = floor(GlobalTauData.MaxLength{chan}/20);
    h.ShiftPer_Slider.SliderStep =[0.1, 1]*(1/(h.ShiftPer_Slider.Max-h.ShiftPer_Slider.Min));
    if UserValues.TauFit.ShiftPer{chan} >= -floor(GlobalTauData.MaxLength{chan}/20)...
            && UserValues.TauFit.ShiftPer{chan} <= floor(GlobalTauData.MaxLength{chan}/20)
        tmp = UserValues.TauFit.ShiftPer{chan};
    else
        tmp = 0;
    end
    h.ShiftPer_Slider.Value = tmp;
    GlobalTauData.ShiftPer{chan} = tmp;
    h.ShiftPer_Edit.String = num2str(tmp);

    %%% IRF Length has the same limits as the Length property
    h.IRFLength_Slider.Min = 1;
    h.IRFLength_Slider.Max = GlobalTauData.MaxLength{chan};
    h.IRFLength_Slider.SliderStep =[1, 10]*(1/(h.IRFLength_Slider.Max-h.IRFLength_Slider.Min));
    if UserValues.TauFit.IRFLength{chan} >= 0 && UserValues.TauFit.IRFLength{chan} <= GlobalTauData.MaxLength{chan}
        tmp = UserValues.TauFit.IRFLength{chan};
    else
        tmp = GlobalTauData.MaxLength{chan};
    end
    h.IRFLength_Slider.Value = tmp;
    GlobalTauData.IRFLength{chan} = tmp;
    h.IRFLength_Edit.String = num2str(tmp);
    
    %%% IRF Shift has the same limits as the perp shift property
    h.IRFShift_Slider.Min = -floor(GlobalTauData.MaxLength{chan}/20);
    h.IRFShift_Slider.Max = floor(GlobalTauData.MaxLength{chan}/20);
    h.IRFShift_Slider.SliderStep =[0.1, 1]*(1/(h.IRFShift_Slider.Max-h.IRFShift_Slider.Min));
    tmp = UserValues.TauFit.IRFShift{chan};
    
    limit_IRF_range = false; % reset to 0 if IRFshift does not make sense
    if limit_IRF_range
        if UserValues.TauFit.IRFShift{chan} >= -floor(GlobalTauData.MaxLength{chan}/20)...
                && UserValues.TauFit.IRFShift{chan} <= floor(GlobalTauData.MaxLength{chan}/20)
            tmp = UserValues.TauFit.IRFShift{chan};
        else
            tmp = 0;
        end
    end
    
    h.IRFShift_Slider.Value = tmp;
    GlobalTauData.IRFShift{chan} = tmp;
    h.IRFShift_Edit.String = num2str(tmp);
    
    %%% IRF rel. Shift has the same limits as the perp shift property
    h.IRFrelShift_Slider.Min = -floor(GlobalTauData.MaxLength{chan}/20);
    h.IRFrelShift_Slider.Max = floor(GlobalTauData.MaxLength{chan}/20);
    h.IRFrelShift_Slider.SliderStep =[0.1, 1]*(1/(h.IRFrelShift_Slider.Max-h.IRFrelShift_Slider.Min));
    if UserValues.TauFit.IRFrelShift{chan} >= -floor(GlobalTauData.MaxLength{chan}/20)...
            && UserValues.TauFit.IRFrelShift{chan} <= floor(GlobalTauData.MaxLength{chan}/20)
        tmp = UserValues.TauFit.IRFrelShift{chan};
    else
        tmp = 0;
    end
    h.IRFrelShift_Slider.Value = tmp;
    GlobalTauData.IRFrelShift{chan} = tmp;
    h.IRFrelShift_Edit.String = num2str(tmp);
    
    %%% Scat Shift has the same limits as the perp shift property
    h.ScatShift_Slider.Min = -floor(GlobalTauData.MaxLength{chan}/20);
    h.ScatShift_Slider.Max = floor(GlobalTauData.MaxLength{chan}/20);
    h.ScatShift_Slider.SliderStep =[0.1, 1]*(1/(h.ScatShift_Slider.Max-h.ScatShift_Slider.Min));
    if UserValues.TauFit.ScatShift{chan} >= -floor(GlobalTauData.MaxLength{chan}/20)...
            && UserValues.TauFit.ScatShift{chan} <= floor(GlobalTauData.MaxLength{chan}/20)
        tmp = UserValues.TauFit.ScatShift{chan};
    else
        tmp = 0;
    end
    h.ScatShift_Slider.Value = tmp;
    GlobalTauData.ScatShift{chan} = tmp;
    h.ScatShift_Edit.String = num2str(tmp);
    
    %%% Scat rel. Shift has the same limits as the perp shift property
    h.ScatrelShift_Slider.Min = -floor(GlobalTauData.MaxLength{chan}/20);
    h.ScatrelShift_Slider.Max = floor(GlobalTauData.MaxLength{chan}/20);
    h.ScatrelShift_Slider.SliderStep =[0.1, 1]*(1/(h.ScatrelShift_Slider.Max-h.ScatrelShift_Slider.Min));
    if UserValues.TauFit.ScatrelShift{chan} >= -floor(GlobalTauData.MaxLength{chan}/20)...
            && UserValues.TauFit.ScatrelShift{chan} <= floor(GlobalTauData.MaxLength{chan}/20)
        tmp = UserValues.TauFit.ScatrelShift{chan};
    else
        tmp = 0;
    end
    h.ScatrelShift_Slider.Value = tmp;
    GlobalTauData.ScatrelShift{chan} = tmp;
    h.ScatrelShift_Edit.String = num2str(tmp);
    
    %%% Ignore Slider reaches from 1 to maximum length
    h.Ignore_Slider.Min = 1;
    h.Ignore_Slider.Max = floor(GlobalTauData.MaxLength{chan}/5);
    h.Ignore_Slider.SliderStep =[1, 10]*(1/(h.Ignore_Slider.Max-h.Ignore_Slider.Min));
    if UserValues.TauFit.Ignore{chan} >= 1 && UserValues.TauFit.Ignore{chan} <= floor(GlobalTauData.MaxLength{chan}/5)
        tmp = UserValues.TauFit.Ignore{chan};
    else
        tmp = 1;
    end
    h.Ignore_Slider.Value = tmp;
    GlobalTauData.Ignore{chan} = tmp;
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
                GlobalTauData.StartPar{chan} = floor(obj.Value);
            elseif obj == h.StartPar_Edit
                GlobalTauData.StartPar{chan} = floor(str2double(obj.String));
                obj.String = num2str(GlobalTauData.StartPar{chan});
            end
        case {h.Length_Slider, h.Length_Edit}
            %%% Update Value
            if obj == h.Length_Slider
                GlobalTauData.Length{chan} = floor(obj.Value);
            elseif obj == h.Length_Edit
                GlobalTauData.Length{chan} = floor(str2double(obj.String));
                obj.String = num2str(GlobalTauData.Length{chan});
            end
            %%% Correct if IRFLength exceeds the Length
            if GlobalTauData.IRFLength{chan} > GlobalTauData.Length{chan}
                GlobalTauData.IRFLength{chan} = GlobalTauData.Length{chan};
                h.IRFLength_Edit.String = num2str(GlobalTauData.IRFLength{chan});
                h.IRFLength_Slider.Value = GlobalTauData.IRFLength{chan};
            end
        case {h.ShiftPer_Slider, h.ShiftPer_Edit}
            %%% Update Value
            if obj == h.ShiftPer_Slider
                GlobalTauData.ShiftPer{chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.ShiftPer_Edit
                GlobalTauData.ShiftPer{chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(GlobalTauData.ShiftPer{chan});
            end
        case {h.IRFLength_Slider, h.IRFLength_Edit}
            %%% Update Value
            if obj == h.IRFLength_Slider
                GlobalTauData.IRFLength{chan} = floor(obj.Value);
            elseif obj == h.IRFLength_Edit
                GlobalTauData.IRFLength{chan} = floor(str2double(obj.String));
                obj.String = num2str(GlobalTauData.IRFLength{chan});
            end
            %%% Correct if IRFLength exceeds the Length
            if GlobalTauData.IRFLength{chan} > GlobalTauData.Length{chan}
                GlobalTauData.IRFLength{chan} = GlobalTauData.Length{chan};
            end
        case {h.IRFShift_Slider, h.IRFShift_Edit}
            %%% Update Value
            if obj == h.IRFShift_Slider
                GlobalTauData.IRFShift{chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.IRFShift_Edit
                GlobalTauData.IRFShift{chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(GlobalTauData.IRFShift{chan});
            end
        case {h.IRFrelShift_Slider, h.IRFrelShift_Edit}
            %%% Update Value
            if obj == h.IRFrelShift_Slider
                GlobalTauData.IRFrelShift{chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.IRFrelShift_Edit
                GlobalTauData.IRFrelShift{chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(GlobalTauData.IRFrelShift{chan});
            end
        case {h.ScatShift_Slider, h.ScatShift_Edit}
            %%% Update Value
            if obj == h.ScatShift_Slider
                GlobalTauData.ScatShift{chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.ScatShift_Edit
                GlobalTauData.ScatShift{chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(GlobalTauData.ScatShift{chan});
            end
        case {h.ScatrelShift_Slider, h.ScatrelShift_Edit}
            %%% Update Value
            if obj == h.ScatrelShift_Slider
                GlobalTauData.ScatrelShift{chan} = round(obj.Value*h.subresolution)/h.subresolution;
            elseif obj == h.ScatrelShift_Edit
                GlobalTauData.ScatrelShift{chan} = round(str2double(obj.String)*h.subresolution)/h.subresolution;
                obj.String = num2str(GlobalTauData.ScatrelShift{chan});
            end
        case {h.Ignore_Slider,h.Ignore_Edit}%%% Update Value
            if obj == h.Ignore_Slider
                GlobalTauData.Ignore{chan} = floor(obj.Value);
            elseif obj == h.Ignore_Edit
                if str2double(obj.String) <  1
                    GlobalTauData.Ignore{chan} = 1;
                    obj.String = '1';
                else
                    GlobalTauData.Ignore{chan} = floor(str2double(obj.String));
                    obj.String = num2str(GlobalTauData.Ignore{chan});
                end
            end
        case {h.FitPar_Table}
            GlobalTauData.IRFShift{chan} = round(obj.Data{end,1}*h.subresolution)/h.subresolution;
            %%% Update Edit Box and Slider when user changes value in the table
            h.IRFShift_Edit.String = num2str(GlobalTauData.IRFShift{chan});
            h.IRFShift_Slider.Value = GlobalTauData.IRFShift{chan}; 
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
            h.StartPar_Edit.String = num2str(GlobalTauData.StartPar{chan});
            h.Length_Edit.String = num2str(GlobalTauData.Length{chan});
            h.ShiftPer_Edit.String = num2str(GlobalTauData.ShiftPer{chan});
            h.IRFLength_Edit.String = num2str(GlobalTauData.IRFLength{chan});
            h.IRFShift_Edit.String = num2str(GlobalTauData.IRFShift{chan});
            h.IRFrelShift_Edit.String = num2str(GlobalTauData.IRFrelShift{chan});
            h.ScatShift_Edit.String = num2str(GlobalTauData.ScatShift{chan});
            h.ScatrelShift_Edit.String = num2str(GlobalTauData.ScatrelShift{chan});
            h.FitPar_Table.Data{:,end-3} = GlobalTauData.IRFShift{chan};
            h.Ignore_Edit.String = num2str(GlobalTauData.Ignore{chan});
        case 'edit'
            h.StartPar_Slider.Value = GlobalTauData.StartPar{chan};
            h.Length_Slider.Value = GlobalTauData.Length{chan};
            h.ShiftPer_Slider.Value = GlobalTauData.ShiftPer{chan};
            h.IRFLength_Slider.Value = GlobalTauData.IRFLength{chan};
            h.IRFShift_Slider.Value = GlobalTauData.IRFShift{chan};
            h.IRFrelShift_Slider.Value = GlobalTauData.IRFrelShift{chan};
            h.ScatShift_Slider.Value = GlobalTauData.ScatShift{chan};
            h.ScatrelShift_Slider.Value = GlobalTauData.ScatrelShift{chan};
            h.FitPar_Table.Data{:,end-3} = GlobalTauData.IRFShift{chan};
            h.Ignore_Slider.Value = GlobalTauData.Ignore{chan};
    end
    UserValues.TauFit.StartPar{chan} = GlobalTauData.StartPar{chan};
    UserValues.TauFit.Length{chan} = GlobalTauData.Length{chan};
    UserValues.TauFit.ShiftPer{chan} = GlobalTauData.ShiftPer{chan};
    UserValues.TauFit.IRFLength{chan} = GlobalTauData.IRFLength{chan};
    UserValues.TauFit.IRFShift{chan} = GlobalTauData.IRFShift{chan};
    UserValues.TauFit.IRFrelShift{chan} = GlobalTauData.IRFrelShift{chan};
    UserValues.TauFit.ScatShift{chan} = GlobalTauData.ScatShift{chan};
    UserValues.TauFit.ScatrelShift{chan} = GlobalTauData.ScatrelShift{chan};
    UserValues.TauFit.Ignore{chan} = GlobalTauData.Ignore{chan};
    LSUserValues(1);
end

%%% if BurstData
if strcmp(GlobalTauData.Who,'BurstBrowser')
    %%% if two-color MFD data is loaded
    if any(GlobalTauData.BAMethod == [1,2])
        %%% if donor or donor-only was selected in dropdown menu
        if any(chan == [1,4])
            %%% if Donor only is available
            if numel(GlobalTauData.hMI_Par) == 4 % DD, AA, DA, DOnly            
                if chan == 1
                    %%% if DD is modified, copy settings to DOnly
                    chan_copy = 4;
                elseif chan == 4
                    %%% if DONLY is modified, copy settings to DD
                    chan_copy = 1;
                end
                UserValues.TauFit.StartPar{chan_copy} = GlobalTauData.StartPar{chan};
                UserValues.TauFit.Length{chan_copy} = GlobalTauData.Length{chan};
                UserValues.TauFit.ShiftPer{chan_copy} = GlobalTauData.ShiftPer{chan};
                UserValues.TauFit.IRFLength{chan_copy} = GlobalTauData.IRFLength{chan};
                UserValues.TauFit.IRFShift{chan_copy} = GlobalTauData.IRFShift{chan};
                UserValues.TauFit.IRFrelShift{chan_copy} = GlobalTauData.IRFrelShift{chan};
                UserValues.TauFit.ScatShift{chan_copy} = GlobalTauData.ScatShift{chan};
                UserValues.TauFit.ScatrelShift{chan_copy} = GlobalTauData.ScatrelShift{chan};
                UserValues.TauFit.Ignore{chan_copy} = GlobalTauData.Ignore{chan};
            end
        end
    end
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
h.Plots.Decay_Par.XData = ((GlobalTauData.StartPar{chan}:(GlobalTauData.Length{chan}-1)) - GlobalTauData.StartPar{chan})*TACtoTime;
h.Plots.Decay_Par.YData = GlobalTauData.hMI_Par{chan}((GlobalTauData.StartPar{chan}+1):GlobalTauData.Length{chan})';
%%% Apply the shift to the perpendicular channel
h.Plots.Decay_Per.XData = ((GlobalTauData.StartPar{chan}:(GlobalTauData.Length{chan}-1)) - GlobalTauData.StartPar{chan})*TACtoTime;
%tmp = circshift(TauFitData.hMI_Per{chan},[TauFitData.ShiftPer{chan},0])';
tmp = shift_by_fraction(GlobalTauData.hMI_Per{chan}, GlobalTauData.ShiftPer{chan});
h.Plots.Decay_Per.YData = tmp((GlobalTauData.StartPar{chan}+1):GlobalTauData.Length{chan});
%%% Apply the shift to the parallel IRF channel
h.Plots.IRF_Par.XData = ((GlobalTauData.StartPar{chan}:(GlobalTauData.IRFLength{chan}-1)) - GlobalTauData.StartPar{chan})*TACtoTime;
%tmp = circshift(TauFitData.hIRF_Par{chan},[0,TauFitData.IRFShift{chan}])';
tmp = shift_by_fraction(GlobalTauData.hIRF_Par{chan},GlobalTauData.IRFShift{chan});
h.Plots.IRF_Par.YData = tmp((GlobalTauData.StartPar{chan}+1):GlobalTauData.IRFLength{chan});
%%% Apply the shift to the perpendicular IRF channel
h.Plots.IRF_Per.XData = ((GlobalTauData.StartPar{chan}:(GlobalTauData.IRFLength{chan}-1)) - GlobalTauData.StartPar{chan})*TACtoTime;
%tmp = circshift(TauFitData.hIRF_Per{chan},[0,TauFitData.IRFShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.IRFrelShift{chan}])';
tmp = shift_by_fraction(GlobalTauData.hIRF_Per{chan},GlobalTauData.IRFShift{chan}+GlobalTauData.ShiftPer{chan}+GlobalTauData.IRFrelShift{chan});
h.Plots.IRF_Per.YData = tmp((GlobalTauData.StartPar{chan}+1):GlobalTauData.IRFLength{chan});
%%% Apply the shift to the parallel Scat channel
h.Plots.Scat_Par.XData = ((GlobalTauData.StartPar{chan}:(GlobalTauData.Length{chan}-1)) - GlobalTauData.StartPar{chan})*TACtoTime;
%tmp = circshift(TauFitData.hScat_Par{chan},[0,TauFitData.ScatShift{chan}])';
tmp = shift_by_fraction(GlobalTauData.hScat_Par{chan},GlobalTauData.ScatShift{chan});
if h.NormalizeScatter_Menu.Value
    % since the scatter pattern should not contain background, we subtract the constant offset
    maxscat = max(tmp);
    %subtract the constant offset and renormalize the amplitude to what it was
    tmp = (tmp-mean(tmp(end-floor(GlobalTauData.MI_Bins/50):end)));
    tmp = tmp/max(tmp)*maxscat;
    %tmp(tmp < 0) = 0;
    tmp(isnan(tmp)) = 0;
end
h.Plots.Scat_Par.YData = tmp((GlobalTauData.StartPar{chan}+1):GlobalTauData.Length{chan});
%%% Apply the shift to the perpendicular Scat channel
h.Plots.Scat_Per.XData = ((GlobalTauData.StartPar{chan}:(GlobalTauData.Length{chan}-1)) - GlobalTauData.StartPar{chan})*TACtoTime;
%tmp = circshift(TauFitData.hScat_Per{chan},[0,TauFitData.ScatShift{chan}+TauFitData.ShiftPer{chan}+TauFitData.ScatrelShift{chan}])';
tmp = shift_by_fraction(GlobalTauData.hScat_Per{chan},GlobalTauData.ScatShift{chan}+GlobalTauData.ShiftPer{chan}+GlobalTauData.ScatrelShift{chan});
tmp = tmp((GlobalTauData.StartPar{chan}+1):GlobalTauData.Length{chan});
if h.NormalizeScatter_Menu.Value
    % since the scatter pattern should not contain background, we subtract the constant offset
    maxscat = max(tmp);
    tmp = tmp-mean(tmp(end-floor(GlobalTauData.MI_Bins/50):end));
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
    if ~any(strcmp(GlobalTauData.Who,{'BurstBrowser','Burstwise'}))
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
if GlobalTauData.Ignore{chan} > 1
    %%% Make plot visible
    h.Ignore_Plot.Visible = 'on';
    h.Ignore_Plot.XData = [GlobalTauData.Ignore{chan}*TACtoTime GlobalTauData.Ignore{chan}*TACtoTime];
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
elseif GlobalTauData.Ignore{chan} == 1
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
%%% Context menu callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1: Change X scaling
%%% 2: Export to figure
%%% 3: Export to Workspace
%%% 4: Export Params to Clipboard
function Plot_Menu_Callback(Obj,~,mode)
h = guidata(findobj('Tag','GlobalTauFit'));
global GlobalTauMeta GlobalTauData

switch mode
    case 1 %%% Change X scale
        if strcmp(Obj.Checked,'off')
            h.GlobalTau_Axes.XScale='log';
            h.Residuals_Axes.XScale = 'log';
            Obj.Checked='on';
        else
            h.GlobalTau_Axes.XScale='lin';
            h.Residuals_Axes.XScale = 'lin';
            Obj.Checked='off';
        end
    case 2 %%% Exports plots to new figure
        %% Sets parameters
        Size = [str2double(h.Export_XSize.String) str2double(h.Export_YSize.String) str2double(h.Export_YSizeRes.String)];
        FontSize = h.Export_Font.UserData.FontSize;
        
        if ~strcmp(GlobalTauMeta.DataType,'FRET')
            Scale = [floor(log10(max(h.GlobalTau_Axes.XLim(1),h.GlobalTau_Axes.Children(1).XData(1)))), ceil(h.GlobalTau_Axes.XLim(2))];
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
        if ~strcmp(GlobalTauMeta.DataType,'FRET')
            H.GlobalTau=axes(...
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
                H.GlobalTau.Position(4) = H.GlobalTau.Position(4)+Size(3)+1.5*FontSize;
            end
        else
            H.GlobalTau=axes(...
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
                H.GlobalTau.Position(4) = H.GlobalTau.Position(4)+Size(3)+1.5*FontSize;
            end
        end
            
        %% Copies objects to new figure
        Active = find(cell2mat(h.Fit_Table.Data(1:end-3,2)));
        % if h.Fit_Errorbars.Value
        %     UseCurves = sort(numel(h.GlobalTau_Axes.Children)+1-[3*Active-2; 3*Active-1]);
        % else
        %    UseCurves = reshape(flip(sort(numel(h.GlobalTau_Axes.Children)+1-[3*Active 3*Active-1;],1)',1),[],1);
        % end
        % UseCurves = sort(numel(h.GlobalTau_Axes.Children)+1-[3*Active-2; 3*Active-1; 3*Active]);
        % H.GlobalTau_Plots=copyobj(h.GlobalTau_Axes.Children(UseCurves),H.GlobalTau);
        
        if h.Fit_Errorbars.Value
            UseCurves = [1,2];
        else
            UseCurves = [4,2];
        end

        CopyCurves = GlobalTauMeta.Plots(Active,UseCurves);
        H.GlobalTau_Plots = [];
        for i = Active'
            for j = UseCurves
                H.GlobalTau_Plots(i,j) = copyobj(GlobalTauMeta.Plots{i,j},H.GlobalTau);
            end
        end

        if h.Export_FitsLegend.Value
               H.GlobalTau_Legend=legend(H.GlobalTau,h.GlobalTau_Legend.String,'Interpreter','none'); 
        else
            if isfield(h,'GlobalTau_Legend')
                if h.GlobalTau_Legend.isvalid
                    LegendString = h.GlobalTau_Legend.String(1:2:end-1);
                    for i=1:numel(LegendString)
                        LegendString{i} = LegendString{i}(7:end);
                    end
                    if h.Fit_Errorbars.Value
                        H.GlobalTau_Legend=legend(H.GlobalTau,H.GlobalTau_Plots(Active,UseCurves(1)),LegendString,'Interpreter','none');
                    else
                        H.GlobalTau_Legend=legend(H.GlobalTau,H.GlobalTau_Plots(Active,UseCurves(1)),LegendString,'Interpreter','none');
                    end

                end
            end
        end
        if strcmp(GlobalTauMeta.DataType,'FRET')
            %%% add invidividual plots
            UseCurves = [5:size(GlobalTauMeta.Plots,2)];
            N = numel(H.GlobalTau_Legend.String);
            for i = Active'
                for j = UseCurves
                    copyobj(GlobalTauMeta.Plots{i,j},H.GlobalTau);
                end
            end
            H.GlobalTau_Legend.String = H.GlobalTau_Legend.String(1:N);
        end
        if h.Export_Residuals.Value
            H.Residuals_Plots=copyobj(h.Residuals_Axes.Children(numel(h.Residuals_Axes.Children)+1-Active),H.Residuals);      
        end
        %% Sets axes parameters   
        set(H.GlobalTau.Children,'LineWidth',1.5);
        set(H.Residuals.Children,'LineWidth',1.5);
        if h.Export_Residuals.Value
            linkaxes([H.GlobalTau,H.Residuals],'x');
        end
        H.GlobalTau.XLim=[h.GlobalTau_Axes.XLim(1),h.GlobalTau_Axes.XLim(2)];
        H.GlobalTau.YLim=h.GlobalTau_Axes.YLim;
        switch GlobalTauMeta.DataType
            case {'GlobalTau','GlobalTau averaged'}
                H.GlobalTau.XLabel.String = 'time lag {\it\tau{}} [s]';
                H.GlobalTau.YLabel.String = 'G({\it\tau{}})'; 
            case 'FRET'
                H.GlobalTau.XLabel.String = 'FRET efficiency';
                H.GlobalTau.YLabel.String = 'PDF'; 
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
            grid(H.GlobalTau,'on');
            if h.Export_Residuals.Value
                grid(H.Residuals,'on');
            end
        end
        if h.Export_MinorGrid.Value
            grid(H.GlobalTau,'minor');
            if h.Export_Residuals.Value
                grid(H.Residuals,'minor');
            end
        else
            grid(H.GlobalTau,'minor');
            grid(H.GlobalTau,'minor');
            if h.Export_Residuals.Value
                grid(H.Residuals,'minor');
                grid(H.Residuals,'minor');
            end
        end
        if h.Export_Box.Value
            H.GlobalTau.Box = 'on';
            if h.Export_Residuals.Value
                H.Residuals.Box = 'on';
            end
        else
            H.GlobalTau.Box = 'off';
            if h.Export_Residuals.Value
                H.Residuals.Box = 'off';
            end
        end
        
        H.Fig.Color = [1 1 1];
        %%% Copies figure handles to workspace
        assignin('base','H',H);
    case 3 %%% Exports data to workspace
        Active = cell2mat(h.Fit_Table.Data(1:end-3,2));
        GlobalTau=[];
        GlobalTau.Model=GlobalTauMeta.Model.Function;
        GlobalTau.FileName=GlobalTauData.FileName(Active)';
        GlobalTau.Params=GlobalTauMeta.Params(:,Active)';        
        time=GlobalTauMeta.Data(Active,1);
        data=GlobalTauMeta.Data(Active,2);
        error=GlobalTauMeta.Data(Active,3);
        %Fit=cell(numel(GlobalTau.Time),1); 
        GlobalTau.Graphs=cell(numel(time)+1,1);
        GlobalTau.Graphs{1}={'time', 'data', 'error', 'fit', 'res'};
        %%% Calculates y data for fit
        for i=1:numel(time)
            P=GlobalTau.Params(i,:);
            %eval(GlobalTauMeta.Model.Function);
            OUT = feval(GlobalTauMeta.Model.Function,P,time{i});
            OUT=real(OUT);
            res=(data{i}-OUT)./error{i};
            GlobalTau.Graphs{i+1} = [time{i}, data{i}, error{i}, OUT, res];
        end
        %%% Copies data to workspace
        assignin('base','GlobalTau',GlobalTau);
    case 4 %%% Exports Fit Result to Clipboard
        FitResult = cell(numel(GlobalTauData.FileName),1);
        active = cell2mat(h.Fit_Table.Data(1:end-2,2));
        for i = 1:numel(GlobalTauData.FileName)
            if active(i)
                FitResult{i} = cell(size(GlobalTauMeta.Params,1)+2,1);
                FitResult{i}{1} = GlobalTauData.FileName{i};
                FitResult{i}{2} = str2double(h.Fit_Table.Data{i,end});
                for j = 3:(size(GlobalTauMeta.Params,1)+2)
                    FitResult{i}{j} = GlobalTauMeta.Params(j-2,i);
                end
            end
        end
        [~,ModelName,~] = fileparts(GlobalTauMeta.Model.Name);
        Params = vertcat({ModelName;'Chi2'},GlobalTauMeta.Model.Params);
        if h.Conf_Interval.Value
            if isfield(GlobalTauMeta,'Confidence_Intervals')
                for i = 1:numel(GlobalTauData.FileName)
                    if active(i)
                        FitResult{i} = horzcat(FitResult{i},vertcat({'lower','upper';'',''},num2cell([GlobalTauMeta.Confidence_Intervals{i}])));
                    end
                end
            end
        end
        FitResult = horzcat(Params,horzcat(FitResult{:}));
        Mat2clip(FitResult');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Stops fitting routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Stop_GlobalTauFit(~,~)
global GlobalTauMeta
h = guidata(findobj('Tag','GlobalTauFit'));
GlobalTauMeta.FitInProgress = 0;
h.Fit_Table.Enable='on';
h.GlobalTauFit.Name='GlobalTau Fit';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Executes fitting routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_GlobalTauFit(~,~)
global GlobalTauMeta UserValues
h = guidata(findobj('Tag','GlobalTauFit'));
%%% Indicates fit in progress
GlobalTauMeta.FitInProgress = 1;
h.GlobalTauFit.Name='GlobalTau Fit  FITTING';
h.Fit_Table.Enable='off';
drawnow;
%%% Reads parameters from table
Fixed = cell2mat(h.Fit_Table.Data(1:end-3,6:3:end-1));
Global = cell2mat(h.Fit_Table.Data(end-2,7:3:end-1));
Active = cell2mat(h.Fit_Table.Data(1:end-3,2));
lb = h.Fit_Table.Data(end-1,5:3:end-1);
lb = cellfun(@str2double,lb);
ub = h.Fit_Table.Data(end,5:3:end-1);
ub = cellfun(@str2double,ub);
%%% Read fit settings and store in UserValues
MaxIter = str2double(h.Iterations.String);
TolFun = str2double(h.Tolerance.String);
UserValues.GlobalTauFit.Max_Iterations = MaxIter;
UserValues.GlobalTauFit.Fit_Tolerance = TolFun;
Use_Weights = h.Fit_Weights.Value;
UserValues.GlobalTauFit.Use_Weights = Use_Weights;
LSUserValues(1);
%%% Optimization settings
opts=optimset('Display','off','TolFun',TolFun,'MaxIter',MaxIter);
%%% Performs fit
if sum(Global)==0
    %% Individual fits, not global
    for i=find(Active)'
        if ~GlobalTauMeta.FitInProgress
            break;
        end
        %%% Reads in parameters
        XData=GlobalTauMeta.Data{i,1};
        YData=GlobalTauMeta.Data{i,2};
        EData=GlobalTauMeta.Data{i,3};
        Min=find(XData>=str2double(h.Fit_Min.String),1,'first');
        Max=find(XData<=str2double(h.Fit_Max.String),1,'last');
        if ~isempty(Min) && ~isempty(Max)
            %%% Adjusts data to selected time region
            XData=XData(Min:Max);
            YData=YData(Min:Max);
            EData=EData(Min:Max);
            %%% Disables weights
            if ~Use_Weights
                EData(:)=1;
            end
            %%% Sets initial values and bounds for non fixed parameters
            Fit_Params=GlobalTauMeta.Params(~Fixed(i,:),i);
            Lb=lb(~Fixed(i,:));
            Ub=ub(~Fixed(i,:));                      
            %%% Performs fit
            [Fitted_Params,~,weighted_residuals,Flag,~,~,jacobian]=lsqcurvefit(@Fit_Single,Fit_Params,{XData,EData,i,Fixed(i,:)},YData./EData,Lb,Ub,opts);
            %%% calculate confidence intervals
            if h.Conf_Interval.Value
                ConfInt = zeros(size(GlobalTauMeta.Params,1),2);
                method = h.Conf_Interval_Method.Value;
                alpha = 0.05; %95% confidence interval
                if method == 1
                    %%% NOTE: nlparci confidence intervals are always
                    %%% symmetric, which can lead to non-sensical values
                    %%% for the error estimate (i.e. 10 +- 20).
                    %%% 
                    %%% One could also use nlinfit here to get access to
                    %%% the covariance matrix directly (instead of relying
                    %%% on the jacobian), but I found the two methods to be
                    %%% consistent.
                    ConfInt(~Fixed(i,:),:) = nlparci(Fitted_Params,weighted_residuals,'jacobian',jacobian,'alpha',alpha);
                elseif method == 2
                    disp('Running MCMC... This could take a minute.');tic;
                    confint = nlparci(Fitted_Params,weighted_residuals,'jacobian',jacobian,'alpha',alpha);
                    proposal = (confint(:,2)-confint(:,1))/2; proposal = (proposal/100)';
                    if any(isnan(proposal))
                        %%% nlparci may return NaN values. Set to 1% of the fit value
                        proposal(isnan(proposal)) = Fitted_Params(isnan(proposal))/100;
                    end
                    %%% define log-likelihood function, which is just the negative of the chi2 divided by two! (do not use reduced chi2!!!)
                    loglikelihood = @(x) (-1/2)*sum((Fit_Single(x,{XData,EData,i,Fixed(i,:)})-YData./EData).^2);
                    %%% Sample
                    nsamples = 1E4; spacing = 1E2;
                    [samples,prob,acceptance] =  MHsample(nsamples,loglikelihood,@(x) 1,proposal,Lb,Ub,Fitted_Params,zeros(1,numel(Fitted_Params)));
                    while acceptance < 0.01
                        disp(sprintf('Acceptance was too low! (%.4f)',acceptance));
                        disp('Running again with more narrow proposal distribution.');
                        proposal = proposal/10;
                        [samples,prob,acceptance] =  MHsample(nsamples,loglikelihood,@(x) 1,proposal,Lb,Ub,Fitted_Params,zeros(1,numel(Fitted_Params)));
                    end
                    %%% MCMC samples the posterior distribution, which can
                    %%% be asymmetric. In this case, the standard deviation
                    %%% is the wrong quantity, instead asymmetric
                    %%% confidence intervals can be reported based on the
                    %%% percentiles of the distribution!
                    
                    %%% New asymmetric confidence interval estimate
                    ConfInt(~Fixed(i,:),:) = prctile(samples(1:spacing:end,:),100*[alpha/2,1-alpha/2],1)';
                    
                    %%% This was the error estimate based on the standard
                    %%% deviation:
                    % v = numel(weighted_residuals)-numel(Fitted_Params); % number of degrees of freedom
                    % perc = tinv(1-alpha/2,v);
                    % ConfInt(~Fixed(i,:),:) = [(mean(samples(1:spacing:end,:))-perc*std(samples(1:spacing:end,:)))', (mean(samples(1:spacing:end,:))+perc*std(samples(1:spacing:end,:)))'];
                    
                    disp(sprintf('Done. Performed %d steps in %.2f seconds.',nsamples,toc));
                    % print variables to workspace
                    assignin('base',['Samples' num2str(i)],samples(1:spacing:end,:));
                    assignin('base',['acceptance' num2str(i)],acceptance);                    
                end
                GlobalTauMeta.Confidence_Intervals{i} = ConfInt;  
                %%% we can also make a prediction for the curve based on
                %%% the confidence intervals, using the following code:
                % [y,delta] = nlpredci(@(x,xdat) Fit_Single(x,{xdat,EData,i,Fixed(i,:)}).*EData,XData,Fitted_Params,weighted_residuals,'jacobian',full(jacobian));
                % figure;semilogx(XData,y-delta);hold on;semilogx(XData,y+delta);
            end
            %%% Updates parameters
            GlobalTauMeta.Params(~Fixed(i,:),i)=Fitted_Params;
        end
    end  
else
    %% Global fits
    XData=[];
    YData=[];
    EData=[];
    Points=[];
    %%% Sets initial value and bounds for global parameters
    Fit_Params=GlobalTauMeta.Params(Global,1);
    Lb=lb(Global);
    Ub=ub(Global);
    for  i=find(Active)'
        %%% Reads in parameters of current file
        xdata=GlobalTauMeta.Data{i,1};
        ydata=GlobalTauMeta.Data{i,2};
        edata=GlobalTauMeta.Data{i,3};
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
        Fit_Params=[Fit_Params; GlobalTauMeta.Params(~Fixed(i,:)& ~Global,i)];
        Lb=[Lb lb(~Fixed(i,:) & ~Global)];
        Ub=[Ub ub(~Fixed(i,:) & ~Global)];
    end
    %%% Puts current Data into global variable to be able to stop fitting
    %%% Performs fit
    [Fitted_Params,~,weighted_residuals,Flag,~,~,jacobian]=lsqcurvefit(@Fit_Global,Fit_Params,{XData,EData,Points,Fixed,Global,Active},YData./EData,Lb,Ub,opts);
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
            loglikelihood = @(x) (-1/2)*sum((Fit_Global(x,{XData,EData,Points,Fixed,Global,Active})-YData./EData).^2);
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
            GlobalTauMeta.Confidence_Intervals{i} = zeros(size(GlobalTauMeta.Params,1),2);
            GlobalTauMeta.Confidence_Intervals{i}(Global,:) = GlobConfInt;
            GlobalTauMeta.Confidence_Intervals{i}(~Fixed(i,:) & ~Global,:) = ConfInt(1:sum(~Fixed(i,:) & ~Global),:);
            ConfInt(1:sum(~Fixed(i,:)& ~Global),:)=[]; 
        end
    end
    %%% Updates parameters
    GlobalTauMeta.Params(Global,:)=repmat(Fitted_Params(1:sum(Global)),[1 size(GlobalTauMeta.Params,2)]) ;
    Fitted_Params(1:sum(Global))=[];
    for i=find(Active)'
        GlobalTauMeta.Params(~Fixed(i,:) & ~Global,i)=Fitted_Params(1:sum(~Fixed(i,:) & ~Global)); 
        Fitted_Params(1:sum(~Fixed(i,:)& ~Global))=[]; 
    end    
end
%%% Displays last exitflag
switch Flag
    case 1
        h.Termination.String='Function converged to a solution x.';
    case 2
        h.Termination.String='Change in x was less than the specified tolerance.';
    case 3
        h.Termination.String='Change in the residual was less than the specified tolerance.';
    case 4
        h.Termination.String='Magnitude of search direction smaller than the specified tolerance.';
    case 0
        h.Termination.String='Number of iterations exceeded options. MaxIter or number of function evaluations exceeded options.';
    case -1
        h.Termination.String='Algorithm was terminated by the output function.';
    case -2
        h.Termination.String='Problem is infeasible: the bounds lb and ub are inconsistent.';
    case -4
        h.Termination.String='Optimization could not make further progress.';
    otherwise
        h.Termination.String= ['Unknown exitflag: ' num2str(Flag)];
end
%%% Indicates end of fitting procedure
h.Fit_Table.Enable='on';
h.GlobalTauFit.Name='GlobalTau Fit';
GlobalTauMeta.FitInProgress = 0;
%%% Updates table values and plots
Update_Table([],[],2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Actual fitting function for individual fits %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Out] = Fit_Single(Fit_Params,Data)
%%% Fit_Params: Non fixed parameters of current file
%%% Data{1}:    X values of current file
%%% Data{2}:    Weights of current file
%%% Data{3}:    Indentifier of current file
global GlobalTauMeta

%%% Aborts Fit
%drawnow;
if ~GlobalTauMeta.FitInProgress
    Out = zeros(size(Data{2}));
    return;
end

x=Data{1};
Weights=Data{2};
file=Data{3};
Fixed = Data{4};
%%% Determines, which parameters are fixed
%Fixed = cell2mat(h.Fit_Table.Data(file,5:3:end-1));

P=zeros(numel(Fixed),1);
%%% Assigns fitting parameters to unfixed parameters of fit
P(~Fixed)=Fit_Params;
%%% Assigns parameters from table to fixed parameters
P(Fixed)=GlobalTauMeta.Params(Fixed,file);
%%% Applies function on parameters
%eval(GlobalTauMeta.Model.Function);
OUT = feval(GlobalTauMeta.Model.Function,P,x);
%%% Applies weights
Out=OUT./Weights;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Actual fitting function for global fits %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Out] = Fit_Global(Fit_Params,Data)
%%% Fit_Params: [Global parameters, Non fixed parameters of all files]
%%% Data{1}:    X values of all files
%%% Data{2}:    Weights of all files
%%% Data{3}:    Length indentifier for X and Weights data of each file
global GlobalTauMeta
%h = guidata(findobj('Tag','GlobalTauFit'));

%%% Aborts Fit
%drawnow;
if ~GlobalTauMeta.FitInProgress
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
  P(Fixed(i,:) & ~Global)= GlobalTauMeta.Params((Fixed(i,:)& ~Global),i);
  %%% Defines XData for the file
  x=X(1:Points(k));
  X(1:Points(k))=[]; 
  k=k+1;
  %%% Calculates function for current file
  %eval(GlobalTauMeta.Model.Function);
  OUT = feval(GlobalTauMeta.Model.Function,P,x);
  Out=[Out;OUT]; 
end
Out=Out./Weights;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to recalculate binning for FRET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rebinFRETdata(obj,~)
global UserValues GlobalTauData GlobalTauMeta
h = guidata(obj);
bin = str2double(obj.String);
%%% round to multiples of 0.005
bin = ceil(bin/0.005)*0.005;
x = (-0.1:bin:ceil(1.1/bin)*bin)';
UserValues.GlobalTauFit.FRETbin = bin;
obj.String = num2str(bin);
for i=1:numel(GlobalTauData.Data)
    %%% Reads data
    E = GlobalTauData.Data{i}.E;
    Data.E = E;
    his = histcounts(E,x)'; %his = [his'; his(end)];
    Data.Cor_Average = his./sum(his)./min(diff(x));
    error = sqrt(his)./sum(his)./min(diff(x));
    Data.Cor_SEM = error; Data.Cor_SEM(Data.Cor_SEM == 0) = 1;
    Data.Cor_Array = [];
    Data.Valid = [];
    Data.Counts = [numel(E), numel(E)];
    Data.Cor_Times = x(1:end-1)+bin/2;
    GlobalTauData.Data{i} = Data;

    %%% Updates global parameters
    GlobalTauMeta.Data{i,1} = GlobalTauData.Data{i}.Cor_Times;
    GlobalTauMeta.Data{i,2} = GlobalTauData.Data{i}.Cor_Average;
    GlobalTauMeta.Data{i,2}(isnan(GlobalTauMeta.Data{i,2})) = 0;
    GlobalTauMeta.Data{i,3} = GlobalTauData.Data{i}.Cor_SEM;
    GlobalTauMeta.Data{i,3}(isnan(GlobalTauMeta.Data{i,3})) = 1;
    
    %%% Update Plots
    GlobalTauMeta.Plots{i,1}.XData = GlobalTauMeta.Data{i,1};
    GlobalTauMeta.Plots{i,1}.YData = GlobalTauMeta.Data{i,2};
    if isfield(GlobalTauMeta.Plots{i,1},'YNegativeDelta')
        GlobalTauMeta.Plots{i,1}.YNegativeDelta = error;
        GlobalTauMeta.Plots{i,1}.YPOsitiveDelta = error;
    else
        GlobalTauMeta.Plots{i,1}.LData = error;
        GlobalTauMeta.Plots{i,1}.UData = error;
    end
    
    GlobalTauMeta.Plots{i,4}.XData = GlobalTauMeta.Data{i,1}-bin/2;
    GlobalTauMeta.Plots{i,4}.YData = GlobalTauMeta.Data{i,2};       
end
Update_Plots;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions to load and save the session %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadSave_Session(obj,e)
global UserValues GlobalTauData GlobalTauMeta
h = guidata(obj);
switch obj
    case h.LoadSession
        %%% get file
        [FileName,PathName] = uigetfile({'*.GlobalTau','GlobalTauFit Session (*.GlobalTau)'},'Load GlobalTauFit Session',UserValues.File.GlobalTauPath,'MultiSelect','off');
        if numel(FileName) == 1 && FileName == 0
            return;
        end
        %%% Saves pathname to uservalues
        UserValues.File.GlobalTauPath=PathName;
        LSUserValues(1);
        %%% Deletes loaded data
        GlobalTauData=[];
        GlobalTauData.Data=[];
        GlobalTauData.FileName=[];
        cellfun(@delete,GlobalTauMeta.Plots);
        GlobalTauMeta.Data=[];
        GlobalTauMeta.Params=[];
        GlobalTauMeta.Plots=cell(0);
        h.Fit_Table.Data(1:end-3,:)=[];
        h.Style_Table.RowName(1:end-1,:)=[];
        h.Style_Table.Data(1:end-1,:)=[];

        %%% load data
        data = load(fullfile(PathName,FileName),'-mat');
        %%% update global variables
        GlobalTauData = data.GlobalTauData;
        GlobalTauMeta = data.GlobalTauMeta;
        %%% update UserValues settings, with exception of export settings
        UserValues.GlobalTauFit.Fit_Min = data.Settings.Fit_Min;
        UserValues.GlobalTauFit.Fit_Max = data.Settings.Fit_Max;
        UserValues.GlobalTauFit.Plot_Errorbars = data.Settings.Plot_Errorbars;
        UserValues.GlobalTauFit.Fit_Tolerance = data.Settings.Fit_Tolerance;
        UserValues.GlobalTauFit.Use_Weights = data.Settings.Use_Weights;
        UserValues.GlobalTauFit.Max_Iterations = data.Settings.Max_Iterations;
        UserValues.GlobalTauFit.NormalizationMethod = data.Settings.NormalizationMethod;
        UserValues.GlobalTauFit.Hide_Legend = data.Settings.Hide_Legend;
        UserValues.GlobalTauFit.Conf_Interval = data.Settings.Conf_Interval;
        UserValues.GlobalTauFit.FRETbin = data.Settings.FRETbin;
        UserValues.GlobalTauFit.PlotStyles = data.Settings.PlotStyles;
        UserValues.GlobalTauFit.PlotStyleAll = data.Settings.PlotStyleAll;
        UserValues.File.GlobalTau_Standard = GlobalTauMeta.Model.Name;
        LSUserValues(1);
        %%% update GUI according to loaded settings
        h.Fit_Min.String = num2str(UserValues.GlobalTauFit.Fit_Min);
        h.Fit_Max.String = num2str(UserValues.GlobalTauFit.Fit_Max);
        h.Fit_Errorbars.Value = UserValues.GlobalTauFit.Plot_Errorbars;
        h.Tolerance.String = num2str(UserValues.GlobalTauFit.Fit_Tolerance);
        h.Fit_Weights.Value = UserValues.GlobalTauFit.Use_Weights;
        h.Iterations.String = num2str(UserValues.GlobalTauFit.Max_Iterations);
        h.Normalize.Value = UserValues.GlobalTauFit.NormalizationMethod;
        h.Conf_Interval.Value = UserValues.GlobalTauFit.Conf_Interval;
        h.Hide_Legend.Value = UserValues.GlobalTauFit.Hide_Legend;
        h.FRETbin.String = num2str(UserValues.GlobalTauFit.FRETbin);
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
        [~,name,~] = fileparts(GlobalTauMeta.Model.Name);
        name_text = {'Loaded Fit Model:';name;};
        h.Loaded_Model_Name.String = sprintf('%s\n',name_text{:});
        h.Loaded_Model_Description.String = sprintf('%s\n',GlobalTauMeta.Model.Description{:});
        h.Loaded_Model_Description.TooltipString = sprintf('%s\n',GlobalTauMeta.Model.Description{:});
    case h.SaveSession
        %%% get filename
        [FileName, PathName] = uiputfile({'*.GlobalTau','GlobalTauFit Session (*.GlobalTau)'},'Save Session as ...',fullfile(UserValues.File.GlobalTauPath,[GlobalTauData.FileName{1},'.GlobalTau']));
        %%% save all data
        data.GlobalTauMeta = GlobalTauMeta;
        data.GlobalTauMeta.Plots = cell(0);
        data.GlobalTauData = GlobalTauData;
        data.Settings = UserValues.GlobalTauFit;
        data.FixState = h.Fit_Table.Data(1:end-3,6:3:end);
        data.GlobalState = h.Fit_Table.Data(1:end-3,7:3:end);
        data.ActiveState = h.Fit_Table.Data(1:end-3,2);
        save(fullfile(PathName,FileName),'-struct','data');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions to create basic plots on data load %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Create_Plots(~,~)
global UserValues GlobalTauMeta GlobalTauData
h = guidata(findobj('Tag','GlobalTauFit'));
switch GlobalTauMeta.DataType
    case {'GlobalTau averaged','GlobalTau individual','GlobalTau'} %%% Correlation files
        for i=1:numel(GlobalTauData.FileName)
            %%% Creates new plots
            GlobalTauMeta.Plots{end+1,1} = errorbar(...
                GlobalTauMeta.Data{i,1},...
                GlobalTauMeta.Data{i,2},...
                GlobalTauMeta.Data{i,3},...
                'Parent',h.GlobalTau_Axes);
            GlobalTauMeta.Plots{end,2} = line(...
                'Parent',h.GlobalTau_Axes,...
                'XData',GlobalTauMeta.Data{i,1},...
                'YData',zeros(numel(GlobalTauMeta.Data{i,1}),1));
            GlobalTauMeta.Plots{end,3} = line(...
                'Parent',h.Residuals_Axes,...
                'XData',GlobalTauMeta.Data{i,1},...
                'YData',zeros(numel(GlobalTauMeta.Data{i,1}),1));
            GlobalTauMeta.Plots{end,4} = line(...
                'Parent',h.GlobalTau_Axes,...
                'XData',GlobalTauMeta.Data{i,1},...
                'YData',GlobalTauMeta.Data{i,2});
        end
        %%% change the gui
        SwitchGUI(h,'GlobalTau');
    case 'FRET'   %% 2color FRET data from BurstBrowser
        for i=1:numel(GlobalTauData.FileName)
            %%% Creates new plots
            GlobalTauMeta.Plots{end+1,1} = errorbar(...
                GlobalTauMeta.Data{i,1},...
                GlobalTauMeta.Data{i,2},...
                GlobalTauMeta.Data{i,3},...
                'Parent',h.GlobalTau_Axes);
            GlobalTauMeta.Plots{end,2} = line(...
                'Parent',h.GlobalTau_Axes,...
                'XData',GlobalTauMeta.Data{i,1},...
                'YData',zeros(numel(GlobalTauMeta.Data{i,1}),1));
            GlobalTauMeta.Plots{end,3} = line(...
                'Parent',h.Residuals_Axes,...
                'XData',GlobalTauMeta.Data{i,1},...
                'YData',zeros(numel(GlobalTauMeta.Data{i,1}),1));
            GlobalTauMeta.Plots{end,4} = stairs(...
                GlobalTauMeta.Data{i,1}-UserValues.GlobalTauFit.FRETbin/2,...
                GlobalTauMeta.Data{i,2},...
                'Parent',h.GlobalTau_Axes);            
        end
        %%% change the gui
        SwitchGUI(h,'FRET');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions for various small callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Misc (obj,e,mode)
global UserValues
h = guidata(findobj('Tag','GlobalTauFit'));

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
           UserValues.GlobalTauFit.Export_Font = f;
           LSUserValues(1);
   end
    
end

