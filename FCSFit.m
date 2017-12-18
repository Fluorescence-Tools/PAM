function FCSFit(~,~)
global UserValues FCSData FCSMeta PathToApp
h.FCSFit=findobj('Tag','FCSFit');

addpath(genpath(['.' filesep 'functions']));

if isempty(PathToApp)
    GetAppFolder();
end

if isempty(h.FCSFit) % Creates new figure, if none exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %%% Disables uitabgroup warning
    warning('off','MATLAB:uitabgroup:OldVersion');   
    %%% Loads user profile    
    [~,~]=LSUserValues(0);
    %%% To save typing
    Look=UserValues.Look;    
    %%% Generates the FCSFit figure
    h.FCSFit = figure(...
        'Units','normalized',...
        'Tag','FCSFit',...
        'Name','FCSFit',...
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
    %h.FCSFit.Visible='off';
    %%% Remove unneeded items from toolbar
    toolbar = findall(h.FCSFit,'Type','uitoolbar');
    toolbar_items = findall(toolbar);
    delete(toolbar_items([2:7 9 13:17]))
    %%% Sets background of axes and other things
    whitebg(Look.Axes);
    %%% Changes Pam background; must be called after whitebg
    h.FCSFit.Color=Look.Back;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Menubar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    %%% File menu with loading, saving and exporting functions
    h.File = uimenu(...
        'Parent',h.FCSFit,...
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
        'Label','Load FCSFit Session',...
        'Separator','on',...
        'Callback',@LoadSave_Session);
     h.SaveSession = uimenu(h.File,...
        'Tag','SaveSession',...
        'Label','Save FCSFit Session',...
        'Callback',@LoadSave_Session);
    %%% Menu to merge loaded Cor files
    h.MergeCor = uimenu(h.File,...
        'Tag','MergeCor',...
        'Label','Merge Loaded Cor Files',...
        'Separator','on',...
        'Callback',@Merge_Cor);
    
    %%% File menu to stop fitting
    h.AbortFit = uimenu(...
        'Parent',h.FCSFit,...
        'Tag','AbortFit',...
        'Label',' Stop....'); 
    h.StopFit = uimenu(...
        'Parent',h.AbortFit,...
        'Tag','StopFit',...
        'Label','...Fit',...
        'Callback',@Stop_FCSFit);   
    %%% File menu for fitting
    h.StartFit = uimenu(...
        'Parent',h.FCSFit,...
        'Tag','StartFit',...
        'Label','Start...');
    h.DoFit = uimenu(...
        'Parent',h.StartFit,...
        'Tag','Fit',...
        'Label','...Fit',...
        'Callback',@Do_FCSFit);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Fitting parameters Tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.FitParams_Tab = uitabgroup(...
        'Parent',h.FCSFit,...
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
    %% Settings tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Tab for fit settings
    h.Setting_Tab= uitab(...
        'Parent',h.FitParams_Tab,...
        'Tag','Setting_Tab',...
        'Title','Settings');    
    %%% Panel for fit settings
    h.Setting_Panel = uibuttongroup(...
        'Parent',h.Setting_Tab,...
        'Tag','Setting_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    %%% Text
    uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Setting_Panel',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Borders [s]:',...
        'Position',[0.002 0.88 0.06 0.1]);
    %%% Minimum and maximum for fitting and plotting
    h.Fit_Min = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Setting_Panel',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String',num2str(UserValues.FCSFit.Fit_Min),...
        'Callback',@Update_Plots,...
        'Position',[0.066 0.88 0.04 0.1]);
    h.Fit_Max = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Setting_Panel',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String',num2str(UserValues.FCSFit.Fit_Max),...
        'Callback',@Update_Plots,...
        'Position',[0.11 0.88 0.04 0.1]);
    %%% Checkbox to toggle using weights
    h.Fit_Weights = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Fit_Weights',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Use weights',...
        'Value',UserValues.FCSFit.Use_Weights,...
        'Callback',@Update_Plots,...
        'Position',[0.002 0.76 0.1 0.1]);
    %%% Checkbox to toggle errorbar plotting
    h.Fit_Errorbars = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Fit_Errorbars',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Plot errorbars',...
        'Value',UserValues.FCSFit.Plot_Errorbars,...
        'Callback',@Update_Plots,...
        'Position',[0.002 0.64 0.1 0.1]); 
    %%% Text
    h.Norm_Text = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Setting_Panel',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Normalization:',...
        'Position',[0.002 0.51 0.08 0.1]);
    %%% Popupmenu to choose normalization method
    h.Normalize = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Normalize',...
        'Units','normalized',...
        'FontSize',10,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','popupmenu',...
        'String',{'None';'Fit N 3D';'Fit minus offset';'Fit G(0)';'Fit N 2D'; 'Time';'Fit N 3D minus offset';'Fit N 3D * brightness';'Time minus offset'},...
        'Value',UserValues.FCSFit.NormalizationMethod,...
        'Callback',@Update_Plots,...
        'Position',[0.082 0.52 0.06 0.1]); 
    %%% Editbox to set time used for normalization
    h.Norm_Time = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Normalize',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String','1e-6',...
        'Visible','off',...
        'Callback',@Update_Plots,...
        'Position',[0.145 0.51 0.04 0.1]);  
    %%% Editbox for binning for FRET histograms
    h.FRETbin_Text = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Setting_Panel',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','FRET bin width:',...
        'Position',[0.002 0.51 0.08 0.1],...
        'Visible','off');
    %%% Popupmenu to choose normalization method
    h.FRETbin = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Normalize',...
        'Units','normalized',...
        'FontSize',10,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String',num2str(UserValues.FCSFit.FRETbin),...
        'Callback',@rebinFRETdata,...
        'Position',[0.082 0.52 0.06 0.1],...
        'Visible','off'); 
    %%% Checkbox to toggle confidence interval calculation
    h.Conf_Interval = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Calculate confidence intervals',...
        'Value',UserValues.FCSFit.Conf_Interval,...
        'Callback',@Update_Plots,...
        'Position',[0.002 0.37 0.2 0.1]); 
    %%% Popupmenu to choose confidence interval determination method
    h.Conf_Interval_Method = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Conf_Interval_Method',...
        'Units','normalized',...
        'FontSize',10,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','popupmenu',...
        'String',{'Jacobian';'Metropolis-Hastings Sampling'},...
        'Value',1,...
        'Callback',[],...
        'Position',[0.082 0.23 0.06 0.1]); 
     %%% Text
    uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Setting_Panel',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Method:',...
        'Position',[0.002 0.22 0.08 0.1]);
    %%% Checkbox to toggle confidence interval calculation
    h.Hide_Legend = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Hide Legend',...
        'Value',UserValues.FCSFit.Hide_Legend,...
        'Callback',@Update_Plots,...
        'Position',[0.002 0.09 0.2 0.1]); 
    %%% Optimization settings
    uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Max interations:',...
        'Position',[0.2 0.88 0.08 0.1]);  
    h.Iterations = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Iterations',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String',num2str(UserValues.FCSFit.Max_Iterations),...
        'Position',[0.285 0.88 0.04 0.1]);
    uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Tolerance:',...
        'Position',[0.2 0.76 0.08 0.1]);  
    h.Tolerance = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Tolerance',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String',num2str(UserValues.FCSFit.Fit_Tolerance),...
        'Position',[0.285 0.76 0.04 0.1]);
    %%% Textbox containing optimization termination output
    h.Termination = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Termination',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','',...
        'Position',[0.2 0.01 0.14 0.75]);
    
    %%% Textbox containing the name of the current fit model
    h.Loaded_Model_Name = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Loaded_Model',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','',...
        'Position',[0.35 0.62 0.24 0.36]);    
    h.Loaded_Model_Description = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Loaded_Model',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','',...
        'Position',[0.35 0.01 0.65 0.61]);  
    
    %%% Text for export size
    uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Export size (X; Cor Y; Residuals Y) [pixels]:',...
        'Position',[0.6 0.88 0.23 0.1]);
    %%% Editbox for export size in X
    h.Export_XSize = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String',UserValues.FCSFit.Export_X,...
        'Callback', @(src,event) LSUserValues(1,src,{'String','FCSFit','Export_X'}),...
        'Position',[0.83 0.88 0.04 0.1]);
    %%% Editbox for export size in Y for correlation
    h.Export_YSize = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String',UserValues.FCSFit.Export_Y,...
        'Callback', @(src,event) LSUserValues(1,src,{'String','FCSFit','Export_Y'}),...
        'Position',[0.875 0.88 0.04 0.1]); 
    %%% Editbox for export size in Y for residuals
    h.Export_YSizeRes = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String',UserValues.FCSFit.Export_Res,...
        'Callback', @(src,event) LSUserValues(1,src,{'String','FCSFit','Export_Res'}),...
        'Position',[0.92 0.88 0.04 0.1]); 

    %%% Editbox for font name
    h.Export_Font = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...        
        'Style','push',...
        'Callback',@Misc,...
        'String',UserValues.FCSFit.Export_Font.FontString,...
        'UserData',UserValues.FCSFit.Export_Font,...
        'Position',[0.6 0.75 0.36 0.1]);
  
    %%% Checkbox for grid lines
    h.Export_Grid = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...   
        'Value',UserValues.FCSFit.Export_Grid,...
        'Callback', @(src,event) LSUserValues(1,src,{'Value','FCSFit','Export_Grid'}),...
        'Style','checkbox',...
        'String','Grid',...
        'Position',[0.6 0.62 0.04 0.1]);  
    %%% Checkbox for minor grid lines
    h.Export_MinorGrid = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Value',UserValues.FCSFit.Export_GridM,...
        'Callback', @(src,event) LSUserValues(1,src,{'Value','FCSFit','Export_GridM'}),...
        'Style','checkbox',...
        'String','Minor Grid',...
        'Position',[0.65 0.62 0.09 0.1]);
    %%% Checkbox for box
    h.Export_Box = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Value',UserValues.FCSFit.Export_Box,...
        'Callback', @(src,event) LSUserValues(1,src,{'Value','FCSFit','Export_Box'}),...
        'Style','checkbox',...
        'String','Box',...
        'Position',[0.735 0.62 0.04 0.1]);
    %%% Checkbox for fit legend entry
    h.Export_FitsLegend = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Value',UserValues.FCSFit.Export_Legend,...
        'Callback', @(src,event) LSUserValues(1,src,{'Value','FCSFit','Export_Legend'}),...
        'Style','checkbox',...
        'String','Fits in legend',...
        'Position',[0.78 0.62 0.15 0.1]);
    %%% Checkbox for show residuals entry
    h.Export_Residuals = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Value',UserValues.FCSFit.Export_Residuals,...
        'Callback', @(src,event) LSUserValues(1,src,{'Value','FCSFit','Export_Residuals'}),...
        'Style','checkbox',...
        'String','Plot residuals',...
        'Position',[0.88 0.62 0.15 0.1]);
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
    h.FileHistory = FileHistory(h.Fit_Function_Tab,'FCSFit',@(x) Load_Cor('FileHistory',[],1,x));
%% Main Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Panel for fit plots
    h.Fit_Plots_Panel = uibuttongroup(...
        'Parent',h.FCSFit,...
        'Tag','Fit_Plots_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0.005 0.26 0.99 0.73]);
    
    %%% Context menu for FCS plots 
    h.FCS_Plot_Menu = uicontextmenu;
    h.FCS_Plot_XLog = uimenu(...
        'Parent',h.FCS_Plot_Menu,...
        'Label','X Log',...
        'Tag','FCS_Plot_XLog',...
        'Checked','on',...
        'Callback',{@Plot_Menu_Callback,1});
    h.FCS_Plot_Export2Fig = uimenu(...
        'Parent',h.FCS_Plot_Menu,...
        'Label','Export to figure',...
        'Checked','off',...
        'Tag','FCS_Plot_Export2Fig',...
        'Callback',{@Plot_Menu_Callback,2});
    h.FCS_Plot_Export2Base = uimenu(...
        'Parent',h.FCS_Plot_Menu,...
        'Label','Export to workspace',...
        'Checked','off',...
        'Tag','FCS_Plot_Export2Base',...
        'Callback',{@Plot_Menu_Callback,3});
   
    %%% Main axes for fcs plots
    h.FCS_Axes = axes(...
        'Parent',h.Fit_Plots_Panel,...
        'Tag','Fit_Axes',...
        'Units','normalized',...
        'FontSize',12,...
        'NextPlot','add',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XScale','log',...
        'XLim',[10^-7,1],...
        'LineWidth', Look.AxWidth,...
        'YColor',Look.Fore,...
        'UIContextMenu',h.FCS_Plot_Menu,...
        'Position',[0.06 0.28 0.93 0.7],...
        'Box','off');
    h.FCS_Axes.XLabel.String = 'time lag {\it\tau{}} [s]';
    h.FCS_Axes.XLabel.Color = Look.Fore;
    h.FCS_Axes.YLabel.String = 'G({\it\tau{}})';
    h.FCS_Axes.YLabel.Color = Look.Fore;  

    %%% Axes for fcs residuals
    h.Residuals_Axes = axes(...
        'Parent',h.Fit_Plots_Panel,...
        'Tag','Residuals_Axes',...
        'Units','normalized',...
        'FontSize',12,...
        'NextPlot','add',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'XScale','log',...
        'XAxisLocation','top',...
        'YColor',Look.Fore,...
        'Position',[0.06 0.02 0.93 0.18],...
        'Box','off',...
        'YGrid','on',...
        'XGrid','on');
    h.Residuals_Axes.GridColorMode = 'manual';
    h.Residuals_Axes.GridColor = [0 0 0];
    h.Residuals_Axes.XTickLabel=[];
    h.Residuals_Axes.YLabel.String = 'weighted residuals';
    h.Residuals_Axes.YLabel.Color = Look.Fore;
    
    linkaxes([h.FCS_Axes h.Residuals_Axes],'x');
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
    FCSData=[];
    FCSData.Data=[];
    FCSData.FileName=[];
    FCSMeta=[];
    FCSMeta.Data=[];
    FCSMeta.Params=[];
    FCSMeta.Confidence_Intervals = cell(1,1);
    FCSMeta.Plots=cell(0);
    FCSMeta.Model=[];
    FCSMeta.Fits=[];
    FCSMeta.Color=[1 1 0; 0 0 1; 1 0 0; 0 0.5 0; 1 0 1; 0 1 1];
    FCSMeta.FitInProgress = 0;    
    FCSMeta.DataType = 'FCS';
    
    h.CurrentGui = 'FCS';
    guidata(h.FCSFit,h); 
    Load_Fit([],[],0);
    Update_Style([],[],0) 
else
    figure(h.FCSFit); % Gives focus to Pam figure  
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to load .cor files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Cor(~,~,mode,filenames)
global UserValues FCSData FCSMeta
h = guidata(findobj('Tag','FCSFit'));

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
    %%% Choose files to load
    [FileName,path,Type] = uigetfile({'*.mcor','Averaged correlation based on matlab filetype';...
                                          '*.cor','Averaged correlation based on .txt. filetype';...
                                          '*.mcor','Individual correlation curves based on matlab filetype';...
                                          '*.cor','Individual correlation curves based on .txt. filetype';...
                                          '*.his','FRET efficiency data from BurstBrowser (*.his)';},...
                                          'Choose a referenced data file',...
                                          UserValues.File.FCSPath,... 
                                          'MultiSelect', 'on');
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
UserValues.File.FCSPath=PathName{1};
LSUserValues(1);
%%% Deletes loaded data
if mode==1
    FCSData=[];
    FCSData.Data=[];
    FCSData.FileName=[];
    cellfun(@delete,FCSMeta.Plots);
    FCSMeta.Data=[];
    FCSMeta.Params=[];
    FCSMeta.Plots=cell(0);
    %h.Fit_Table.RowName(1:end-3)=[];
    h.Fit_Table.Data(1:end-3,:)=[];
    h.Style_Table.RowName(1:end-1,:)=[];
    h.Style_Table.Data(1:end-1,:)=[];
end

switch Type
    case {1,2} %%% Averaged correlation files
        FCSMeta.DataType = 'FCS averaged';
        for i=1:numel(FileName)
            %%% Reads files (1 == .mcor; 2 == .cor)
            if Type == 1
                FCSData.Data{end+1} = load(fullfile(PathName{i},FileName{i}),'-mat');
                %%% add file to file history
                h.FileHistory.add_file(fullfile(PathName{i},FileName{i}));
            else                
                FID = fopen(fullfile(PathName{i},FileName{i}));
                Text = textscan(FID,'%s', 'delimiter', '\n','whitespace', '');
                Text = Text{1};
                Data.Header = Text{1};
                Data.Valid = str2num(Text{find(~cellfun(@isempty,strfind(Text,'Valid bins:')),1)}(12:end)); %#ok<ST2NM>
                Data.Counts(1) = str2num(Text{find(~cellfun(@isempty,strfind(Text,'Countrate channel 1 [kHz]:')),1)}(27:end)); %#ok<ST2NM>
                Data.Counts(2) = str2num(Text{find(~cellfun(@isempty,strfind(Text,'Countrate channel 2 [kHz]:')),1)}(27:end)); %#ok<ST2NM>
                Start = find(~cellfun(@isempty,strfind(Text,'Data starts here:')),1);
                
                Values = zeros(numel(Text)-Start,numel(Data.Valid)+3);
                k=1;
                for j = Start+1:numel(Text)
                    Values(k,:) = str2num(Text{j});  %#ok<ST2NM>
                    k = k+1;
                end
                Data.Cor_Times = Values(:,1);
                Data.Cor_Average = Values(:,2);
                Data.Cor_SEM = Values(:,3);
                Data.Cor_Array = Values(:,4:end);
                FCSData.Data{end+1} = Data;
            end
            %%% Updates global parameters
            FCSData.FileName{end+1} = FileName{i}(1:end-5);
            FCSMeta.Data{end+1,1} = FCSData.Data{end}.Cor_Times;
            FCSMeta.Data{end,2} = FCSData.Data{end}.Cor_Average;
            FCSMeta.Data{end,2}(isnan(FCSMeta.Data{end,2})) = 0;
            FCSMeta.Data{end,3} = FCSData.Data{end}.Cor_SEM;
            FCSMeta.Data{end,3}(isnan(FCSMeta.Data{end,3})) = 1;
            %%% Creates new plots
            FCSMeta.Plots{end+1,1} = errorbar(...
                FCSMeta.Data{end,1},...
                FCSMeta.Data{end,2},...
                FCSMeta.Data{end,3},...
                'Parent',h.FCS_Axes);
            FCSMeta.Plots{end,2} = line(...
                'Parent',h.FCS_Axes,...
                'XData',FCSMeta.Data{end,1},...
                'YData',zeros(numel(FCSMeta.Data{end,1}),1));
            FCSMeta.Plots{end,3} = line(...
                'Parent',h.Residuals_Axes,...
                'XData',FCSMeta.Data{end,1},...
                'YData',zeros(numel(FCSMeta.Data{end,1}),1));
            FCSMeta.Plots{end,4} = line(...
                'Parent',h.FCS_Axes,...
                'XData',FCSMeta.Data{end,1},...
                'YData',FCSMeta.Data{end,2});
            FCSMeta.Params(:,end+1) = cellfun(@str2double,h.Fit_Table.Data(end-2,5:3:end-1));
        end
        %%% change the gui
        SwitchGUI(h,'FCS');
    case {3,4} %% Individual curves from correlation files
        FCSMeta.DataType = 'FCS individual';
        for i=1:numel(FileName)
            %%% Reads files (3 == .mcor; 4 == .cor)
            if Type == 3
                Data = load(fullfile(PathName{i},FileName{i}),'-mat');
            else
                FID = fopen(fullfile(PathName{i},FileName{i}));
                Text = textscan(FID,'%s', 'delimiter', '\n','whitespace', '');
                Text = Text{1};
                Data.Header = Text{1};
                Data.Valid = str2num(Text{find(~cellfun(@isempty,strfind(Text,'Valid bins:')),1)}(12:end)); %#ok<ST2NM>
                Data.Counts(1) = str2num(Text{find(~cellfun(@isempty,strfind(Text,'Countrate channel 1 [kHz]:')),1)}(27:end)); %#ok<ST2NM>
                Data.Counts(2) = str2num(Text{find(~cellfun(@isempty,strfind(Text,'Countrate channel 2 [kHz]:')),1)}(27:end)); %#ok<ST2NM>
                Start = find(~cellfun(@isempty,strfind(Text,'Data starts here:')),1);
                
                Values = zeros(numel(Text)-Start,numel(Data.Valid)+3);
                k=1;
                for j = Start+1:numel(Text)
                    Values(k,:) = str2num(Text{j});  %#ok<ST2NM>
                    k = k+1;
                end
                Data.Cor_Times = Values(:,1);
                Data.Cor_Average = Values(:,2);
                Data.Cor_SEM = Values(:,3);
                Data.Cor_Array = Values(:,4:end);
            end           
            %%% Creates entry for each individual curve
            for j=1:size(Data.Cor_Array,2)
                FCSData.Data{end+1} = Data;              
                FCSData.FileName{end+1} = [FileName{i}(1:end-5) ' Curve ' num2str(Data.Valid(j))];
                FCSMeta.Data{end+1,1} = FCSData.Data{end}.Cor_Times;
                FCSMeta.Data{end,2} = FCSData.Data{end}.Cor_Array(:,j);
                FCSMeta.Data{end,3} = FCSData.Data{end}.Cor_SEM;
                %%% Creates new plots
                FCSMeta.Plots{end+1,1} = errorbar(...
                    FCSMeta.Data{end,1},...
                    FCSMeta.Data{end,2},...
                    FCSMeta.Data{end,3},...
                    'Parent',h.FCS_Axes);
                FCSMeta.Plots{end,2} = line(...
                    'Parent',h.FCS_Axes,...
                    'XData',FCSMeta.Data{end,1},...
                    'YData',zeros(numel(FCSMeta.Data{end,1}),1));
                FCSMeta.Plots{end,3} = line(...
                    'Parent',h.Residuals_Axes,...
                    'XData',FCSMeta.Data{end,1},...
                    'YData',zeros(numel(FCSMeta.Data{end,1}),1));
                FCSMeta.Plots{end,4} = line(...
                    'Parent',h.FCS_Axes,...
                    'XData',FCSMeta.Data{end,1},...
                    'YData',FCSMeta.Data{end,2});
                FCSMeta.Params(:,end+1) = cellfun(@str2double,h.Fit_Table.Data(end-2,5:3:end-1));
            end
        end
        %%% change the gui
        SwitchGUI(h,'FCS');
    case {5}   %% 2color FRET data from BurstBrowser
        FCSMeta.DataType = 'FRET';
        bin = UserValues.FCSFit.FRETbin;
        x = (-0.1:bin:ceil(1.1/bin)*bin)';
        for i=1:numel(FileName)
            %%% Reads files
            E = load(fullfile(PathName{i},FileName{i}),'-mat'); 
            if isfield(E,'E')
                E = E.E;
            elseif isfield(E,'EGR') % three color data
                E = E.EGR;
            end
            Data.E = E;
            his = histcounts(E,x)';
            Data.Cor_Average = his./sum(his)./min(diff(x));
            error = sqrt(his)./sum(his)./min(diff(x));
            Data.Cor_SEM = error; Data.Cor_SEM(Data.Cor_SEM == 0) = 1;
            Data.Cor_Array = [];
            Data.Valid = [];
            Data.Counts = [numel(E), numel(E)];
            Data.Cor_Times = x(1:end-1)+bin/2;
            FCSData.Data{end+1} = Data;

            %%% Updates global parameters
            FCSData.FileName{end+1} = FileName{i}(1:end-5);
            FCSMeta.Data{end+1,1} = FCSData.Data{end}.Cor_Times;
            FCSMeta.Data{end,2} = FCSData.Data{end}.Cor_Average;
            FCSMeta.Data{end,2}(isnan(FCSMeta.Data{end,2})) = 0;
            FCSMeta.Data{end,3} = FCSData.Data{end}.Cor_SEM;
            FCSMeta.Data{end,3}(isnan(FCSMeta.Data{end,3})) = 1;
            %%% Creates new plots
            FCSMeta.Plots{end+1,1} = errorbar(...
                FCSMeta.Data{end,1},...
                FCSMeta.Data{end,2},...
                FCSMeta.Data{end,3},...
                'Parent',h.FCS_Axes);
            FCSMeta.Plots{end,2} = line(...
                'Parent',h.FCS_Axes,...
                'XData',FCSMeta.Data{end,1},...
                'YData',zeros(numel(FCSMeta.Data{end,1}),1));
            FCSMeta.Plots{end,3} = line(...
                'Parent',h.Residuals_Axes,...
                'XData',FCSMeta.Data{end,1},...
                'YData',zeros(numel(FCSMeta.Data{end,1}),1));
            FCSMeta.Plots{end,4} = stairs(...
                FCSMeta.Data{end,1}-bin/2,...
                FCSMeta.Data{end,2},...
                'Parent',h.FCS_Axes);
            FCSMeta.Params(:,end+1) = cellfun(@str2double,h.Fit_Table.Data(end-2,5:3:end-1));
        end
        %%% change the gui
        SwitchGUI(h,'FRET');
end

%%% Updates table and plot data and style to new size
Update_Style([],[],1);
Update_Table([],[],1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to switch GUI between FRET and FCS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SwitchGUI(handles,toType)
global UserValues
if isempty(handles)
    handles = guidata(gcf);
end
if strcmp(toType,handles.CurrentGui)
    return;
end
if strcmp(handles.CurrentGui,'FCS') %%% switch to FRET
    %%% change the minmax boundaries for plot
    handles.Fit_Min.String = '-0.1';
    handles.Fit_Max.String = '1';
    %%% hide normalization box and set to none
    handles.Normalize.Visible = 'off';
    handles.Normalize.Value = 1;
    handles.Norm_Text.Visible = 'off';
    handles.Norm_Time.Visible = 'off';
    %%% disable XLOG menu point for main axis
    handles.FCS_Plot_XLog.Visible = 'off';
    handles.FCS_Plot_XLog.Checked = 'off';
    handles.FCS_Axes.XScale='lin';
    handles.Residuals_Axes.XScale = 'lin';
    %%% Change axis labels
    handles.FCS_Axes.XLabel.String = 'FRET efficiency';
    handles.FCS_Axes.YLabel.String = 'PDF';
    %%% show FRET binning controls
    handles.FRETbin_Text.Visible = 'on';
    handles.FRETbin.Visible = 'on';
    
    handles.CurrentGui = 'FRET';
elseif strcmp(handles.CurrentGui,'FRET') %%% switch to FCS
     %%% change the minmax boundaries for plot
    handles.Fit_Min.String = num2str(UserValues.FCSFit.Fit_Min);
    handles.Fit_Max.String = num2str(UserValues.FCSFit.Fit_Max);
    %%% hide normalization box and set to none
    handles.Normalize.Visible = 'on';
    handles.Normalize.Value = UserValues.FCSFit.NormalizationMethod;
    handles.Norm_Text.Visible = 'on';
    handles.Norm_Time.Visible = 'on';
    %%% disable XLOG menu point for main axis
    handles.FCS_Plot_XLog.Visible = 'on';
    handles.FCS_Plot_XLog.Checked = 'on';
    handles.FCS_Axes.XScale='log';
    handles.Residuals_Axes.XScale = 'log';
     %%% Change axis labels
    handles.FCS_Axes.XLabel.String = 'time lag {\it\tau{}} [s]';
    handles.FCS_Axes.YLabel.String = 'G({\it\tau{}})';
    %%% hide FRET binning controls
    handles.FRETbin_Text.Visible = 'off';
    handles.FRETbin.Visible = 'off';
    
    handles.CurrentGui = 'FCS';
end

guidata(handles.FCSFit,handles); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to save merged .cor file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Merge_Cor(~,~)
global UserValues FCSData FCSMeta
h = guidata(findobj('Tag','FCSFit'));

%%% Merge only the active files
active = find(cell2mat(h.Fit_Table.Data(1:end-3,1)));
%%% check for length difference
len = zeros(1,numel(active));
k = 1;
for i = active'
    len(k) = numel(FCSData.Data{i}.Cor_Times);
    k = k+1;
end
minlen = min(len);
minlen_ix = find(len == min(len));

Valid = [];
Cor_Array = [];
Header = cell(0);
Counts = [0,0];
switch FCSMeta.DataType
    case 'FCS averaged'
        % multiple averaged file were loaded
        Cor_Times = FCSData.Data{active(minlen_ix(1))}.Cor_Times; % Take Cor_Times from first file, should be same for all.
        for i = active'
            Valid = [Valid, FCSData.Data{i}.Valid];
            Cor_Array = [Cor_Array, FCSData.Data{i}.Cor_Array(1:minlen,:)];
            Header{end+1} = FCSData.Data{i}.Header;
            Counts = Counts + FCSData.Data{i}.Counts;
        end
    case 'FCS individual'
        % individual curves from 1 file were loaded
        Cor_Times = FCSMeta.Data{active(minlen_ix(1)),1}; % Take Cor_Times from first file, should be same for all.
        for i = active'
            Valid = [Valid, 1];
            Cor_Array = [Cor_Array, FCSMeta.Data{i,2}(1:minlen,:)];
            Header{end+1} = FCSData.Data{i}.Header;
            Counts = Counts + FCSData.Data{i}.Counts;
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
[FileName,PathName] = uiputfile({'*.mcor'},'Choose a filename for the merged file',fullfile(UserValues.File.FCSPath,FCSData.FileName{active(1)}));
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
global FCSMeta UserValues PathToApp
h = guidata(findobj('Tag','FCSFit'));
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
           UserValues.File.FCS_Standard=FileName;
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
    FCSMeta.Model=[];
    FCSMeta.Model.Name=FileName;
    FCSMeta.Model.Description = description;
    FCSMeta.Model.Brightness=Text{B_Start+1};
    %%% Concaternates the function string
    FCSMeta.Model.Function=[];
    for i=Fun_Start+1:numel(Text)
        FCSMeta.Model.Function=[FCSMeta.Model.Function Text(i)];
    end
    FCSMeta.Model.Function=cell2mat(FCSMeta.Model.Function);
    %%% Convert to function handle
    FunctionStart = strfind(FCSMeta.Model.Function,'=');
    eval(['FCSMeta.Model.Function = @(P,x) ' FCSMeta.Model.Function((FunctionStart(1)+1):end) ';']);
    %%% Extracts parameter names and initial values
    FCSMeta.Model.Params=cell(NParams,1);
    FCSMeta.Model.Value=zeros(NParams,1);
    FCSMeta.Model.LowerBoundaries = zeros(NParams,1);
    FCSMeta.Model.UpperBoundaries = zeros(NParams,1);
    FCSMeta.Model.State = zeros(NParams,1);
    %%% Reads parameters and values from file
    for i=1:NParams
        Param_Pos=strfind(Text{i+Param_Start},' ');
        FCSMeta.Model.Params{i}=Text{i+Param_Start}((Param_Pos(1)+1):(Param_Pos(2)-1));
        Start = strfind(Text{i+Param_Start},'=');
        %Stop = strfind(Text{i+Param_Start},';');
        % Filter more specifically (this enables the use of html greek
        % letters like &mu; etc.)
        [~, Stop] = regexp(Text{i+Param_Start},'(\d+;|Inf;)');
        FCSMeta.Model.Value(i) = str2double(Text{i+Param_Start}(Start(1)+1:Stop(1)-1));
        FCSMeta.Model.LowerBoundaries(i) = str2double(Text{i+Param_Start}(Start(2)+1:Stop(2)-1));   
        FCSMeta.Model.UpperBoundaries(i) = str2double(Text{i+Param_Start}(Start(3)+1:Stop(3)-1));
        if numel(Text{i+Param_Start})>Stop(3) && any(strfind(Text{i+Param_Start}(Stop(3):end),'g'))
            FCSMeta.Model.State(i) = 2;
        elseif numel(Text{i+Param_Start})>Stop(3) && any(strfind(Text{i+Param_Start}(Stop(3):end),'f'))
            FCSMeta.Model.State(i) = 1;
        end
    end    
    FCSMeta.Params=repmat(FCSMeta.Model.Value,[1,size(FCSMeta.Data,1)]);
    
    %%% Updates table to new model
    Update_Table([],[],0);
    %%% Updates model text
    [~,name,~] = fileparts(FCSMeta.Model.Name);
    name_text = {'Loaded Fit Model:';name;};
    h.Loaded_Model_Name.String = sprintf('%s\n',name_text{:});
    h.Loaded_Model_Description.String = sprintf('%s\n',description{:});
    h.Loaded_Model_Description.TooltipString = sprintf('%s\n',description{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that updates fit table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Table(~,e,mode)
h = guidata(findobj('Tag','FCSFit'));
global FCSMeta FCSData
switch mode
    case 0 %%% Updates whole table (Load Fit etc.)
        
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];        
        %%% Generates column names and resized them
        Columns=cell(3*numel(FCSMeta.Model.Params)+5,1);
        Columns{1} = '<HTML><b>File</b>';
        Columns{2}='<HTML><b>Active</b>';
        Columns{3}='<HTML><b>Counts [khz]</b>';
        Columns{4}='<HTML><b>Brightness [khz]</b>';
        for i=1:numel(FCSMeta.Model.Params)
            Columns{3*i+2}=['<HTML><b>' FCSMeta.Model.Params{i} '</b>'];
            Columns{3*i+3}='<HTML><b>F</b>';
            Columns{3*i+4}='<HTML><b>G</b>';
        end
        Columns{end}='<HTML><b>Chi2</b>';
        ColumnWidth=cell(1,numel(Columns));
        %ColumnWidth(4:3:end-1)=cellfun('length',FCSMeta.Model.Params).*7;
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
        Rows=cell(numel(FCSData.Data)+3,1);
        tmp = FCSData.FileName;
        for i = 1:numel(tmp)
            tmp{i} = ['<HTML><b>' tmp{i} '</b>'];
        end
        Rows(1:numel(FCSData.Data))=deal(tmp);
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
            if FCSData.Data{i}.Counts(1) == FCSData.Data{i}.Counts(2)
                %%% Autocorrelation
                Data{i,2}=num2str(FCSData.Data{i}.Counts(1));
            elseif FCSData.Data{i}.Counts(1) ~= FCSData.Data{i}.Counts(2)
                %%% Crosscorrelation
                Data{i,2}=num2str(sum(FCSData.Data{i}.Counts));
            end
        end
        Data(1:end-3,4:3:end-1)=deal(num2cell(FCSMeta.Params)');
        Data(end-2,4:3:end-1)=deal(num2cell(FCSMeta.Model.Value)');
        Data(end-1,4:3:end-1)=deal(num2cell(FCSMeta.Model.LowerBoundaries)');
        Data(end,4:3:end-1)=deal(num2cell(FCSMeta.Model.UpperBoundaries)');
        Data=cellfun(@num2str,Data,'UniformOutput',false);
        Data(1:end-2,5:3:end-1) = repmat(num2cell(FCSMeta.Model.State==1)',size(Data,1)-2,1);        
        Data(end-1:end,5:3:end-1)=deal({[]});
        Data(1:end-2,6:3:end-1) = repmat(num2cell(FCSMeta.Model.State==2)',size(Data,1)-2,1);
        Data(end-1:end,6:3:end-1)=deal({[]});
        Data(1:end-2,1)=deal({true});
        Data(end-1:end,1)=deal({[]});
        Data(1:end-2,end)=deal({'0'});
        Data(end-1:end,end)=deal({[]});
        h.Fit_Table.Data=[Rows,Data];
        h.Fit_Table.ColumnEditable=[false,true,false,false,true(1,numel(Columns)-4),false];  
        h.Fit_Table.ColumnWidth(1) = {5*max(cellfun('prodofsize',Rows))};
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 1 %%% Updates tables when new data is loaded
        h.Fit_Table.CellEditCallback=[];
        %%% Sets row names to file names
        Rows=cell(numel(FCSData.Data)+3,1);
        tmp = FCSData.FileName;

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
        for i=1:numel(FCSData.Data)
            %%% Distinguish between Autocorrelation (only take Counts of
            %%% Channel) and Crosscorrelation (take sum of Channels)
            if FCSData.Data{i}.Counts(1) == FCSData.Data{i}.Counts(2)
                %%% Autocorrelation
                Data{i,2}=num2str(FCSData.Data{i}.Counts(1));
            elseif FCSData.Data{i}.Counts(1) ~= FCSData.Data{i}.Counts(2)
                %%% Crosscorrelation
                Data{i,2}=num2str(sum(FCSData.Data{i}.Counts));
            end
        end
        h.Fit_Table.Data=[Rows,Data];
        h.Fit_Table.ColumnWidth(1) = {5*max(cellfun('prodofsize',Rows))};
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 2 %%% Updates table after fit
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        %%% Updates Brightness in Table
        for i=1:(size(h.Fit_Table.Data,1)-3)
            P=FCSMeta.Params(:,i);
            eval(FCSMeta.Model.Brightness);
            h.Fit_Table.Data{i,4}= num2str(str2double(h.Fit_Table.Data{i,3}).*B);
        end
        %%% Updates parameter values in table
        h.Fit_Table.Data(1:end-3,5:3:end-1)=cellfun(@num2str,num2cell(FCSMeta.Params)','UniformOutput',false);
        %%% Updates plots
        %Update_Plots        
        %%% Enables cell callback again        
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 3 %%% Individual cells callbacks 
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        if strcmp(e.EventName,'CellSelection') %%% No change in Value, only selected
            if isempty(e.Indices) || (e.Indices(1)~=(size(h.Fit_Table.Data,1)-2) && e.Indices(2)~=1)
                h.Fit_Table.CellEditCallback={@Update_Table,3};
                return;
            end
            NewData = h.Fit_Table.Data{e.Indices(1),e.Indices(2)};
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
                    FCSMeta.Params((e.Indices(2)-2)/3,:)=str2double(NewData);
                elseif mod(e.Indices(2)-6,3)==0 && e.Indices(2)>=6 && NewData==1
                    %% Value was fixed => Uncheck global
                    h.Fit_Table.Data(1:end-2,e.Indices(2)+1)=deal({false});
                elseif mod(e.Indices(2)-7,3)==0 && e.Indices(2)>=7 && NewData==1
                    %% Global was change
                    %%% Apply value to all files
                    h.Fit_Table.Data(1:end-2,e.Indices(2)-2)=h.Fit_Table.Data(e.Indices(1),e.Indices(2)-2);
                    %%% Apply value to global variables
                    FCSMeta.Params((e.Indices(2)-4)/3,:)=str2double(h.Fit_Table.Data{e.Indices(1),e.Indices(2)-2});
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
                FCSMeta.Params((e.Indices(2)-4)/3,:)=str2double(h.Fit_Table.Data{e.Indices(1),e.Indices(2)-2});
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
                FCSMeta.Params((e.Indices(2)-2)/3,:)=str2double(NewData);
            else
                %% Not global => only changes value
                FCSMeta.Params((e.Indices(2)-2)/3,e.Indices(1))=str2double(NewData);
                
            end
        elseif e.Indices(2)==1
            %% Active was changed
            a = 1;
        end       
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
end

%%% Updates plots to changes models
Update_Plots;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes plotting style %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Style(obj,e,mode) 
global FCSMeta FCSData UserValues
h = guidata(findobj('Tag','FCSFit'));
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
        Rows=cell(numel(FCSData.Data)+1,1);
        Rows(1:numel(FCSData.Data))=deal(FCSData.FileName);
        Rows{end}='ALL';
        h.Style_Table.RowName=Rows;
        Data=cell(numel(Rows),size(h.Style_Table.Data,2));
        %%% Sets ALL style to last row
        Data(end,1:8)=UserValues.FCSFit.PlotStyleAll(1:8);
        %%% Sets previous styles to first rows
        for i=1:numel(FCSData.Data)
            if i<=size(UserValues.FCSFit.PlotStyles,1)
                Data(i,1:8) = UserValues.FCSFit.PlotStyles(i,1:8);
            else
                Data(i,:) = UserValues.FCSFit.PlotStyles(end,1:8);
            end
        end
        %%% Updates new plots to style
        for i=1:numel(FCSData.FileName)
           FCSMeta.Plots{i,1}.Color=str2num(Data{i,1}); %#ok<*ST2NM>
           FCSMeta.Plots{i,4}.Color=str2num(Data{i,1});
           FCSMeta.Plots{i,2}.Color=str2num(Data{i,1});
           FCSMeta.Plots{i,3}.Color=str2num(Data{i,1});
           FCSMeta.Plots{i,1}.LineStyle=Data{i,2};
           FCSMeta.Plots{i,1}.LineWidth=str2double(Data{i,3});
           FCSMeta.Plots{i,1}.Marker=Data{i,4};
           FCSMeta.Plots{i,1}.MarkerSize=str2double(Data{i,5});
           FCSMeta.Plots{i,4}.LineStyle=Data{i,2};
           FCSMeta.Plots{i,4}.LineWidth=str2double(Data{i,3});
           FCSMeta.Plots{i,4}.Marker=Data{i,4};
           FCSMeta.Plots{i,4}.MarkerSize=str2double(Data{i,5});
           FCSMeta.Plots{i,2}.LineStyle=Data{i,6};
           FCSMeta.Plots{i,3}.LineStyle=Data{i,6};
           FCSMeta.Plots{i,2}.LineWidth=str2double(Data{i,7});
           FCSMeta.Plots{i,3}.LineWidth=str2double(Data{i,7});
           FCSMeta.Plots{i,2}.Marker=Data{i,8};
           FCSMeta.Plots{i,3}.Marker=Data{i,8};
           FCSMeta.Plots{i,2}.MarkerSize=str2double(Data{i,7});
           FCSMeta.Plots{i,3}.MarkerSize=str2double(Data{i,7});
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
                NewColor = uisetcolor;
                if numel(NewColor) == 1%NewColor == 0
                    return;
                end
                for i=File
                    h.Style_Table.Data{i,1} = num2str(NewColor);
                    FCSMeta.Plots{i,1}.Color=NewColor;
                    FCSMeta.Plots{i,2}.Color=NewColor;
                    FCSMeta.Plots{i,3}.Color=NewColor;
                    FCSMeta.Plots{i,4}.Color=NewColor;
                end
                if numel(File)>1
                    h.Style_Table.Data{end,1} = num2str(NewColor);
                end
                
            case 2 %%% Changes data line style
                for i=File
                    FCSMeta.Plots{i,1}.LineStyle=NewData;
                    FCSMeta.Plots{i,4}.LineStyle=NewData;
                end
            case 3 %%% Changes data line width
                for i=File
                    FCSMeta.Plots{i,1}.LineWidth=str2double(NewData);
                    FCSMeta.Plots{i,4}.LineWidth=str2double(NewData);
                end
            case 4 %%% Changes data marker style
                for i=File
                    FCSMeta.Plots{i,1}.Marker=NewData;
                    FCSMeta.Plots{i,4}.Marker=NewData;
                end
            case 5 %%% Changes data marker size
                for i=File
                    FCSMeta.Plots{i,1}.MarkerSize=str2double(NewData);
                    FCSMeta.Plots{i,4}.MarkerSize=str2double(NewData);
                end
            case 6 %%% Changes fit line style
                for i=File
                    FCSMeta.Plots{i,2}.LineStyle=NewData;
                    FCSMeta.Plots{i,3}.LineStyle=NewData;
                end
            case 7 %%% Changes fit line width
                for i=File
                    FCSMeta.Plots{i,2}.LineWidth=str2double(NewData);
                    FCSMeta.Plots{i,3}.LineWidth=str2double(NewData);
                end
            case 8 %%% Changes fit marker style
                for i=File
                    FCSMeta.Plots{i,2}.Marker=NewData;
                    FCSMeta.Plots{i,3}.Marker=NewData;
                end
            case 9 %%% Changes fit marker size
                for i=File
                    FCSMeta.Plots{i,2}.MarkerSize=str2double(NewData);
                    FCSMeta.Plots{i,3}.MarkerSize=str2double(NewData);
                end
            case 10 %%% Removes files
                File=flip(File,2);
                for i=File
                    FCSData.Data(i)=[];
                    FCSData.FileName(i)=[];
                    cellfun(@delete,FCSMeta.Plots(i,:));
                    FCSMeta.Data(i,:)=[];
                    FCSMeta.Params(:,i)=[];
                    FCSMeta.Plots(i,:)=[];
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
                    FCSData.FileName{File} = NewName{1};
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
            FCSMeta.Plots{i,1}.Color=colors(i,:);
            FCSMeta.Plots{i,2}.Color=colors(i,:);
            FCSMeta.Plots{i,3}.Color=colors(i,:);
            FCSMeta.Plots{i,4}.Color=colors(i,:);
        end
end
%%% Save Updated UiTableData to UserValues.FCSFit.PlotStyles
UserValues.FCSFit.PlotStyles(1:(size(h.Style_Table.Data,1)-1),1:8) = h.Style_Table.Data(1:(end-1),(1:8));
UserValues.FCSFit.PlotStyleAll = h.Style_Table.Data(end,1:8);
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that updates plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(~,~)
h = guidata(findobj('Tag','FCSFit'));
global FCSMeta FCSData UserValues

Min=str2double(h.Fit_Min.String);
Max=str2double(h.Fit_Max.String);
%%% input check
if isnan(Min)
    Min = UserValues.FCSFit.Fit_Min;
    h.Fit_Min.String = num2str(UserValues.FCSFit.Fit_Min);
end
if isnan(Max)
    Max = UserValues.FCSFit.Fit_Max;
    h.Fit_Max.String = num2str(UserValues.FCSFit.Fit_Max);
end
if ~strcmp(FCSMeta.DataType,'FRET')
    if (Min < 0)
        Min = 0;
    end
else
    if (Min < -0.1)
        Min = -0.1;
    end
end
if (Max < 0)
    Max = 1;
end
if (Min > Max) || (Max < Min)
    a = Min; b = Max;
    Min = b;
    Max = a;
end
if (Min == Max)
    Max = Min+1;
end
if ~isempty(FCSData.Data) && ~strcmp(FCSMeta.DataType,'FRET')
    %%% get maximum x value
    maxTime = 0;
    for i = 1:numel(FCSData.Data)
        maxTime = max([maxTime,FCSData.Data{i}.Cor_Times(end)]);
    end
    if (Max > maxTime)
        Max = maxTime;
    end
end
h.Fit_Min.String = num2str(Min);
h.Fit_Max.String = num2str(Max);
UserValues.FCSFit.Fit_Min = Min;
UserValues.FCSFit.Fit_Max = Min;

Plot_Errorbars = h.Fit_Errorbars.Value;
Normalization_Method = h.Normalize.Value;
Conv_Interval = h.Conf_Interval.Value;
%%% store in UserValues
if ~strcmp(FCSMeta.DataType,'FRET') %%% only store for FCS data
    UserValues.FCSFit.Fit_Min = Min;
    UserValues.FCSFit.Fit_Max = Max;
end
UserValues.FCSFit.Plot_Errorbars = Plot_Errorbars;
UserValues.FCSFit.NormalizationMethod = Normalization_Method;
UserValues.FCSFit.Conf_Interval = Conv_Interval;
UserValues.FCSFit.Hide_Legend = h.Hide_Legend.Value;
LSUserValues(1);

YMax=0; YMin=0; RMax=0; RMin=0;
Active = cell2mat(h.Fit_Table.Data(1:end-3,2));
for i=1:size(FCSMeta.Plots,1)
    if Active(i)
        %% Calculates normalization parameter B
        h.Norm_Time.Visible='off';
        switch Normalization_Method
            case 1
                %% No normalization
                B=1;
            case {2,7,8}
                %% Normalizes to number of particles 3D (defined in model)
                P=FCSMeta.Params(:,i);
                eval(FCSMeta.Model.Brightness);
                B=B/sqrt(8);
                if isnan(B) || B==0 || isinf(B)
                    B=1;
                end
            case 3
                %% subtract the offset
                P=FCSMeta.Params(:,i);
                B=1;
            case 4
                %% Normalizes to G(0) of the fit
                P=FCSMeta.Params(:,i);x=0;
                %eval(FCSMeta.Model.Function);
                OUT = feval(FCSMeta.Model.Function,P,x);
                B=OUT;
                if isnan(B) || B==0 || isinf(B)
                    B=1;
                end               
            case 5
                %% Normalizes to number of particles 2D (defined in model)
                P=FCSMeta.Params(:,i);
                eval(FCSMeta.Model.Brightness);
                B=B/sqrt(4);
                if isnan(B) || B==0 || isinf(B)
                    B=1;
                end
            case {6,9}
                %% Normalizes to timepoint closest to set value
                h.Norm_Time.Visible='on';
                T=find(FCSMeta.Data{i,1}>=str2double(h.Norm_Time.String),1,'first');
                B=FCSMeta.Data{i,2}(T);
                if  Normalization_Method == 9
                    P = FCSMeta.Params(:,i);
                    B = B - P(end);
                end
            case 8
                
        end      
        %% Updates data plot y values
        if Normalization_Method ~= 7 && Normalization_Method ~= 3 && Normalization_Method ~= 9 
            FCSMeta.Plots{i,1}.YData=FCSMeta.Data{i,2}/B; 
            FCSMeta.Plots{i,4}.YData=FCSMeta.Data{i,2}/B;
        else % substract offset
            FCSMeta.Plots{i,1}.YData=(FCSMeta.Data{i,2}-P(end))/B;  
            FCSMeta.Plots{i,4}.YData=(FCSMeta.Data{i,2}-P(end))/B;  
        end
        %% Calculates fit y data and updates fit plot
        P=FCSMeta.Params(:,i);
        if ~strcmp(FCSMeta.DataType,'FRET')
            x = logspace(log10(FCSMeta.Data{i,1}(1)),log10(FCSMeta.Data{i,1}(end)),10000); %plot fit function in higher binning than data!
        else
            x = linspace(FCSMeta.Data{i,1}(1),FCSMeta.Data{i,1}(end),10000); %plot fit function in higher binning than data!
        end
        OUT = feval(FCSMeta.Model.Function,P,x);
        OUT=real(OUT);
        FCSMeta.Plots{i,2}.XData=x;
        if Normalization_Method ~= 7 && Normalization_Method ~= 3 && Normalization_Method ~= 9 
            FCSMeta.Plots{i,2}.YData=OUT/B;
        else % substract offset
            FCSMeta.Plots{i,2}.YData=(OUT-P(end))/B;
        end
        %% Calculates weighted residuals and plots them
        %%% recalculate fitfun at data
        x=FCSMeta.Data{i,1};
        %eval(FCSMeta.Model.Function);
        OUT = feval(FCSMeta.Model.Function,P,x);
        OUT=real(OUT);
        if h.Fit_Weights.Value
            Residuals=(FCSMeta.Data{i,2}-OUT)./FCSMeta.Data{i,3};
        else
            Residuals=(FCSMeta.Data{i,2}-OUT);
        end
        Residuals(Residuals==inf | isnan(Residuals))=0;
        FCSMeta.Plots{i,3}.YData=Residuals;                       
        %% Calculates limits to autoscale plot 
        XMin=find(FCSMeta.Data{i,1}>=str2double(h.Fit_Min.String),1,'first');
        XMax=find(FCSMeta.Data{i,1}<=str2double(h.Fit_Max.String),1,'last');
        if Normalization_Method ~= 7 && Normalization_Method ~= 3
            if Plot_Errorbars
                %max(data+error bar)
                YMax=max([YMax, max((FCSMeta.Data{i,2}(XMin:XMax)+FCSMeta.Data{i,3}(XMin:XMax)))/B]);
                %min(data-error bar)
                YMin=min([YMin, min((FCSMeta.Data{i,2}(XMin:XMax)-FCSMeta.Data{i,3}(XMin:XMax)))/B]);
            else
                %max(data)
                YMax=max([YMax, max(FCSMeta.Data{i,2}(XMin:XMax))/B]);
                %min(data)
                YMin=min([YMin, min(FCSMeta.Data{i,2}(XMin:XMax))/B]);
            end
        else % substract offset
            if Plot_Errorbars
                YMax=max([YMax, max((FCSMeta.Data{i,2}(XMin:XMax)-P(end)+FCSMeta.Data{i,3}(XMin:XMax)))/B]);
                YMin=min([YMin, min((FCSMeta.Data{i,2}(XMin:XMax)-P(end)-FCSMeta.Data{i,3}(XMin:XMax)))/B]);
            else
                YMax=max([YMax, max((FCSMeta.Data{i,2}(XMin:XMax)-P(end)))/B]);
                YMin=min([YMin, min((FCSMeta.Data{i,2}(XMin:XMax)-P(end)))/B]);
            end
        end
        RMax=max([RMax, max(Residuals(XMin:XMax))]);
        RMin=min([RMin, min(Residuals(XMin:XMax))]);        
        %% Calculates Chi^2 and updates table
        h.Fit_Table.CellEditCallback=[];
        Chisqr=sum(Residuals(XMin:XMax).^2)/(numel(Residuals(XMin:XMax))-sum(~cell2mat(h.Fit_Table.Data(i,6:3:end-1))));
        h.Fit_Table.Data{i,end}=num2str(Chisqr);
        h.Fit_Table.CellEditCallback={@Update_Table,3};
        %% Makes plot visible, if it is active
        FCSMeta.Plots{i,2}.Visible='on';
        FCSMeta.Plots{i,3}.Visible='on';
        %% Updates data errorbars/ turns them off
        if Plot_Errorbars
            if ~strcmp(FCSMeta.DataType,'FRET')
                if isfield(FCSMeta.Plots{i,1}, 'LNegativeDelta')
                    FCSMeta.Plots{i,1}.YNegativeDelta=FCSMeta.Data{i,3}/B;
                    FCSMeta.Plots{i,1}.YPositiveDelta=FCSMeta.Data{i,3}/B;
                else
                    FCSMeta.Plots{i,1}.LData=FCSMeta.Data{i,3}/B;
                    FCSMeta.Plots{i,1}.UData=FCSMeta.Data{i,3}/B;
                end
            else
                error = FCSMeta.Data{i,3}; error(FCSMeta.Data{i,2}==0) = 0;
                if isfield(FCSMeta.Plots{i,1}, 'LNegativeDelta')
                    FCSMeta.Plots{i,1}.YNegativeDelta=error/B;
                    FCSMeta.Plots{i,1}.YPositiveDelta=error/B;
                else
                    FCSMeta.Plots{i,1}.LData=error/B;
                    FCSMeta.Plots{i,1}.UData=error/B;
                end
            end
            FCSMeta.Plots{i,1}.Visible = 'on';
            FCSMeta.Plots{i,4}.Visible = 'off';
        else
            FCSMeta.Plots{i,1}.Visible = 'off';
            FCSMeta.Plots{i,4}.Visible = 'on';
        end
    else
        %% Hides plots
        FCSMeta.Plots{i,1}.Visible='off';
        FCSMeta.Plots{i,2}.Visible='off';
        FCSMeta.Plots{i,3}.Visible='off';
        FCSMeta.Plots{i,4}.Visible='off';
    end
end

%%% Generates figure legend entries
Active=find(Active);
LegendString=cell(numel(Active)*2,1);
LegendUse=h.FCS_Axes.Children(1:numel(Active)*2);
for i=1:numel(Active)
    LegendString{2*i-1}=['Data: ' FCSData.FileName{Active(i)}];
    LegendString{2*i}  =['Fit:  ' FCSData.FileName{Active(i)}];
    if Plot_Errorbars
        LegendUse(2*i-1)=FCSMeta.Plots{Active(i),1};
    else
        LegendUse(2*i-1)=FCSMeta.Plots{Active(i),4};
    end
    LegendUse(2*i)=FCSMeta.Plots{Active(i),2};
end
if ~isempty(LegendString) && ~h.Hide_Legend.Value
    %% Active legend    
    h.FCS_Legend=legend(h.FCS_Axes,LegendUse,LegendString,'Interpreter','none');
    guidata(h.FCSFit,h);
else
    %% Hides legend for empty plot
    h.FCS_Legend.Visible='off';
end
%%% Updates axes limits
h.FCS_Axes.XLim=[Min Max];
if ~strcmp(FCSMeta.DataType,'FRET')
    h.FCS_Axes.YLim=[YMin-0.1*abs(YMin) YMax+0.05*YMax+0.0001];
else
    h.FCS_Axes.YLim=[0 YMax+0.05*YMax+0.0001];
end
h.Residuals_Axes.YLim=[RMin-0.1*abs(RMin) RMax+0.05*RMax+0.0001];

if gcbo == h.Fit_Weights
    %%% change axis label
    if h.Fit_Weights.Value == 1
        h.Residuals_Axes.YLabel.String = 'weighted residuals';
    else
        h.Residuals_Axes.YLabel.String = 'residuals';
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Context menu callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1: Change X scaling
%%% 2: Export to figure
%%% 3: Export to Workspace
%%% 4: Export Params to Clipboard
function Plot_Menu_Callback(Obj,~,mode)
h = guidata(findobj('Tag','FCSFit'));
global FCSMeta FCSData

switch mode
    case 1 %%% Change X scale
        if strcmp(Obj.Checked,'off')
            h.FCS_Axes.XScale='log';
            h.Residuals_Axes.XScale = 'log';
            Obj.Checked='on';
        else
            h.FCS_Axes.XScale='lin';
            h.Residuals_Axes.XScale = 'lin';
            Obj.Checked='off';
        end
    case 2 %%% Exports plots to new figure
        %% Sets parameters
        Size = [str2double(h.Export_XSize.String) str2double(h.Export_YSize.String) str2double(h.Export_YSizeRes.String)];
        FontSize = h.Export_Font.UserData.FontSize;
        
        if ~strcmp(FCSMeta.DataType,'FRET')
            Scale = [floor(log10(max(h.FCS_Axes.XLim(1),h.FCS_Axes.Children(1).XData(1)))), ceil(h.FCS_Axes.XLim(2))];
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
        if ~strcmp(FCSMeta.DataType,'FRET')
            H.FCS=axes(...
                'Parent',H.Fig,...
                'XScale','log',...
                'FontSize', FontSize,...
                'XTick',XTicks,...
                'XTickLabel',XTickLabels,...
                'Layer','bottom',...
                'Units','points',...
                'Position',[15+4.2*FontSize 3.5*FontSize Size(1) Size(2)]);    
            if h.Export_Residuals.Value
                H.Residuals=axes(...
                    'Parent',H.Fig,...
                    'XScale','log',...
                    'FontSize', FontSize,...
                    'XTick',XTicks,...
                    'XTickLabel',[],...
                    'Layer','bottom',...
                    'Units','points',...
                    'Position',[15+4.2*FontSize 5*FontSize+Size(2) Size(1) Size(3)]);
            else
                H.FCS.Position(4) = H.FCS.Position(4)+Size(3)+1.5*FontSize;
            end
        else
            H.FCS=axes(...
                'Parent',H.Fig,...
                'XScale','lin',...
                'FontSize', FontSize,...
                'Layer','bottom',...
                'Units','points',...
                'Position',[15+4.2*FontSize 3.5*FontSize Size(1) Size(2)]);    
            if h.Export_Residuals.Value
                H.Residuals=axes(...
                    'Parent',H.Fig,...
                    'XScale','lin',...
                    'FontSize', FontSize,...
                    'XTickLabel',[],...
                    'Layer','bottom',...
                    'Units','points',...
                    'Position',[15+4.2*FontSize 5*FontSize+Size(2) Size(1) Size(3)]);
            else
                H.FCS.Position(4) = H.FCS.Position(4)+Size(3)+1.5*FontSize;
            end
        end
            
        
        %% Sets axes parameters
        if h.Export_Residuals.Value
            linkaxes([H.FCS,H.Residuals],'x');
        end
        H.FCS.XLim=[h.FCS_Axes.XLim(1),h.FCS_Axes.XLim(2)];
        H.FCS.YLim=h.FCS_Axes.YLim;
        switch FCSMeta.DataType
            case {'FCS','FCS averaged'}
                H.FCS.XLabel.String = 'time lag {\it\tau{}} [s]';
                H.FCS.YLabel.String = 'G({\it\tau{}})'; 
            case 'FRET'
                H.FCS.XLabel.String = 'FRET efficiency';
                H.FCS.YLabel.String = 'PDF'; 
        end
        if h.Export_Residuals.Value
            H.Residuals.YLim=h.Residuals_Axes.YLim;
            H.Residuals.YLabel.String = {'weighted'; 'residuals'};
        end
        %% Copies objects to new figure
        Active = find(cell2mat(h.Fit_Table.Data(1:end-3,2)));
        if h.Fit_Errorbars.Value
            UseCurves = sort(numel(h.FCS_Axes.Children)+1-[3*Active-2; 3*Active-1]);
        else
            UseCurves = reshape(flip(sort(numel(h.FCS_Axes.Children)+1-[3*Active 3*Active-1;],1)',1),[],1);
        end
        %UseCurves = sort(numel(h.FCS_Axes.Children)+1-[3*Active-2; 3*Active-1; 3*Active]);
        
        H.FCS_Plots=copyobj(h.FCS_Axes.Children(UseCurves),H.FCS);
        if h.Export_FitsLegend.Value
               H.FCS_Legend=legend(H.FCS,h.FCS_Legend.String,'Interpreter','none'); 
        else
            if isfield(h,'FCS_Legend')
                if h.FCS_Legend.isvalid
                    LegendString = h.FCS_Legend.String(1:2:end-1);
                    for i=1:numel(LegendString)
                        LegendString{i} = LegendString{i}(7:end);
                    end
                    if h.Fit_Errorbars.Value
                        H.FCS_Legend=legend(H.FCS,H.FCS_Plots(end-1:-2:1),LegendString,'Interpreter','none');
                    else
                        H.FCS_Legend=legend(H.FCS,H.FCS_Plots(end:-2:1),LegendString,'Interpreter','none');
                    end

                end
            end
        end
        if h.Export_Residuals.Value
            H.Residuals_Plots=copyobj(h.Residuals_Axes.Children(numel(h.Residuals_Axes.Children)+1-Active),H.Residuals);      
        end
        %% Toggles box and grid
        if h.Export_Grid.Value
            grid(H.FCS,'on');
            if h.Export_Residuals.Value
                grid(H.Residuals,'on');
            end
        end
        if h.Export_MinorGrid.Value
            grid(H.FCS,'minor');
            if h.Export_Residuals.Value
                grid(H.Residuals,'minor');
            end
        else
            grid(H.FCS,'minor');
            grid(H.FCS,'minor');
            if h.Export_Residuals.Value
                grid(H.Residuals,'minor');
                grid(H.Residuals,'minor');
            end
        end
        if h.Export_Box.Value
            H.FCS.Box = 'on';
            if h.Export_Residuals.Value
                H.Residuals.Box = 'on';
            end
        else
            H.FCS.Box = 'off';
            if h.Export_Residuals.Value
                H.Residuals.Box = 'off';
            end
        end
      
        H.Fig.Color = [1 1 1];
        %%% Copies figure handles to workspace
        assignin('base','H',H);
    case 3 %%% Exports data to workspace
        Active = cell2mat(h.Fit_Table.Data(1:end-3,2));
        FCS=[];
        FCS.Model=FCSMeta.Model.Function;
        FCS.FileName=FCSData.FileName(Active)';
        FCS.Params=FCSMeta.Params(:,Active)';        
        time=FCSMeta.Data(Active,1);
        data=FCSMeta.Data(Active,2);
        error=FCSMeta.Data(Active,3);
        %Fit=cell(numel(FCS.Time),1); 
        FCS.Graphs=cell(numel(time)+1,1);
        FCS.Graphs{1}={'time', 'data', 'error', 'fit', 'res'};
        %%% Calculates y data for fit
        for i=1:numel(time)
            P=FCS.Params(i,:);
            %eval(FCSMeta.Model.Function);
            OUT = feval(FCSMeta.Model.Function,P,time{i});
            OUT=real(OUT);
            res=(data{i}-OUT)./error{i};
            FCS.Graphs{i+1} = [time{i}, data{i}, error{i}, OUT, res];
        end
        %%% Copies data to workspace
        assignin('base','FCS',FCS);
    case 4 %%% Exports Fit Result to Clipboard
        FitResult = cell(numel(FCSData.FileName),1);
        active = cell2mat(h.Fit_Table.Data(1:end-2,2));
        for i = 1:numel(FCSData.FileName)
            if active(i)
                FitResult{i} = cell(size(FCSMeta.Params,1)+2,1);
                FitResult{i}{1} = FCSData.FileName{i};
                FitResult{i}{2} = str2double(h.Fit_Table.Data{i,end});
                for j = 3:(size(FCSMeta.Params,1)+2)
                    FitResult{i}{j} = FCSMeta.Params(j-2,i);
                end
            end
        end
        [~,ModelName,~] = fileparts(FCSMeta.Model.Name);
        Params = vertcat({ModelName;'Chi2'},FCSMeta.Model.Params);
        if h.Conf_Interval.Value
            if isfield(FCSMeta,'Confidence_Intervals')
                for i = 1:numel(FCSData.FileName)
                    if active(i)
                        FitResult{i} = horzcat(FitResult{i},vertcat({'lower','upper';'',''},num2cell([FCSMeta.Confidence_Intervals{i}])));
                    end
                end
            end
        end
        FitResult = horzcat(Params,horzcat(FitResult{:}));
        Mat2clip(FitResult);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Stops fitting routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Stop_FCSFit(~,~)
global FCSMeta
h = guidata(findobj('Tag','FCSFit'));
FCSMeta.FitInProgress = 0;
h.Fit_Table.Enable='on';
h.FCSFit.Name='FCS Fit';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Executes fitting routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_FCSFit(~,~)
global FCSMeta UserValues
h = guidata(findobj('Tag','FCSFit'));
%%% Indicates fit in progress
FCSMeta.FitInProgress = 1;
h.FCSFit.Name='FCS Fit  FITTING';
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
UserValues.FCSFit.Max_Iterations = MaxIter;
UserValues.FCSFit.Fit_Tolerance = TolFun;
Use_Weights = h.Fit_Weights.Value;
UserValues.FCSFit.Use_Weights = Use_Weights;
LSUserValues(1);
%%% Optimization settings
opts=optimset('Display','off','TolFun',TolFun,'MaxIter',MaxIter);
%%% Performs fit
if sum(Global)==0
    %% Individual fits, not global
    for i=find(Active)'
        if ~FCSMeta.FitInProgress
            break;
        end
        %%% Reads in parameters
        XData=FCSMeta.Data{i,1};
        YData=FCSMeta.Data{i,2};
        EData=FCSMeta.Data{i,3};
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
            Fit_Params=FCSMeta.Params(~Fixed(i,:),i);
            Lb=lb(~Fixed(i,:));
            Ub=ub(~Fixed(i,:));                      
            %%% Performs fit
            [Fitted_Params,~,weighted_residuals,Flag,~,~,jacobian]=lsqcurvefit(@Fit_Single,Fit_Params,{XData,EData,i,Fixed(i,:)},YData./EData,Lb,Ub,opts);
            %%% calculate confidence intervals
            if h.Conf_Interval.Value
                ConfInt = zeros(size(FCSMeta.Params,1),2);
                method = h.Conf_Interval_Method.Value;
                alpha = 0.05; %95% confidence interval
                if method == 1
                    ConfInt(~Fixed(i,:),:) = nlparci(Fitted_Params,weighted_residuals,'jacobian',jacobian,'alpha',alpha);
                elseif method == 2
                    confint = nlparci(Fitted_Params,weighted_residuals,'jacobian',jacobian,'alpha',alpha);
                    proposal = (confint(:,2)-confint(:,1))/2; proposal = (proposal/10)';
                    %%% define log-likelihood function, which is just the negative of the chi2 divided by two! (do not use reduced chi2!!!)
                    loglikelihood = @(x) (-1/2)*sum((Fit_Single(x,{XData,EData,i,Fixed(i,:)})-YData./EData).^2);
                    %%% Sample
                    nsamples = 1E4; spacing = 1E2;
                    [samples,prob,acceptance] =  MHsample(nsamples,loglikelihood,@(x) 1,proposal,Lb,Ub,Fitted_Params,zeros(1,numel(Fitted_Params)));
                    v = numel(weighted_residuals)-numel(Fitted_Params); % number of degrees of freedom
                    perc = tinv(1-alpha/2,v);
                    ConfInt(~Fixed(i,:),:) = [(mean(samples(1:spacing:end,:))-perc*std(samples(1:spacing:end,:)))', (mean(samples(1:spacing:end,:))+perc*std(samples(1:spacing:end,:)))'];
                end
                FCSMeta.Confidence_Intervals{i} = ConfInt;
            end
            %%% Updates parameters
            FCSMeta.Params(~Fixed(i,:),i)=Fitted_Params;
        end
    end  
else
    %% Global fits
    XData=[];
    YData=[];
    EData=[];
    Points=[];
    %%% Sets initial value and bounds for global parameters
    Fit_Params=FCSMeta.Params(Global,1);
    Lb=lb(Global);
    Ub=ub(Global);
    for  i=find(Active)'
        %%% Reads in parameters of current file
        xdata=FCSMeta.Data{i,1};
        ydata=FCSMeta.Data{i,2};
        edata=FCSMeta.Data{i,3};
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
        Fit_Params=[Fit_Params; FCSMeta.Params(~Fixed(i,:)& ~Global,i)];
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
            confint = nlparci(Fitted_Params,weighted_residuals,'jacobian',jacobian,'alpha',alpha);
            proposal = (confint(:,2)-confint(:,1))/2; proposal = (proposal/10)';
            %%% define log-likelihood function, which is just the negative of the chi2 divided by two! (do not use reduced chi2!!!)
            loglikelihood = @(x) (-1/2)*sum((Fit_Global(x,{XData,EData,Points,Fixed,Global,Active})-YData./EData).^2);
            %%% Sample
            nsamples = 1E4; spacing = 1E2;
            [samples,prob,acceptance] =  MHsample(nsamples,loglikelihood,@(x) 1,proposal,Lb,Ub,Fitted_Params,zeros(1,numel(Fitted_Params)));
            %v = numel(weighted_residuals)-numel(Fitted_Params); % number of degrees of freedom is equal to the number of samples
            perc = 1.96;%tinv(1-alpha/2,v);
            ConfInt = [(mean(samples(1:spacing:end,:))-perc*std(samples(1:spacing:end,:)))', (mean(samples(1:spacing:end,:))+perc*(samples(1:spacing:end,:)))'];
        end
        GlobConfInt = ConfInt(1:sum(Global),:);
        ConfInt(1:sum(Global),:) = [];
        for i = find(Active)'
            FCSMeta.Confidence_Intervals{i} = zeros(size(FCSMeta.Params,1),2);
            FCSMeta.Confidence_Intervals{i}(Global,:) = GlobConfInt;
            FCSMeta.Confidence_Intervals{i}(~Fixed(i,:) & ~Global,:) = ConfInt(1:sum(~Fixed(i,:) & ~Global),:);
            ConfInt(1:sum(~Fixed(i,:)& ~Global),:)=[]; 
        end
    end
    %%% Updates parameters
    FCSMeta.Params(Global,:)=repmat(Fitted_Params(1:sum(Global)),[1 size(FCSMeta.Params,2)]) ;
    Fitted_Params(1:sum(Global))=[];
    for i=find(Active)'
        FCSMeta.Params(~Fixed(i,:) & ~Global,i)=Fitted_Params(1:sum(~Fixed(i,:) & ~Global)); 
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
h.FCSFit.Name='FCS Fit';
FCSMeta.FitInProgress = 0;
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
global FCSMeta

%%% Aborts Fit
%drawnow;
if ~FCSMeta.FitInProgress
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
P(Fixed)=FCSMeta.Params(Fixed,file);
%%% Applies function on parameters
%eval(FCSMeta.Model.Function);
OUT = feval(FCSMeta.Model.Function,P,x);
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
global FCSMeta
%h = guidata(findobj('Tag','FCSFit'));

%%% Aborts Fit
%drawnow;
if ~FCSMeta.FitInProgress
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
  P(Fixed(i,:) & ~Global)= FCSMeta.Params((Fixed(i,:)& ~Global),i);
  %%% Defines XData for the file
  x=X(1:Points(k));
  X(1:Points(k))=[]; 
  k=k+1;
  %%% Calculates function for current file
  %eval(FCSMeta.Model.Function);
  OUT = feval(FCSMeta.Model.Function,P,x);
  Out=[Out;OUT]; 
end
Out=Out./Weights;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to recalculate binning for FRET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rebinFRETdata(obj,~)
global UserValues FCSData FCSMeta
h = guidata(obj);
bin = str2double(obj.String);
%%% round to multiples of 0.005
bin = ceil(bin/0.005)*0.005;
x = (-0.1:bin:ceil(1.1/bin)*bin)';
UserValues.FCSFit.FRETbin = bin;
obj.String = num2str(bin);
for i=1:numel(FCSData.Data)
    %%% Reads data
    E = FCSData.Data{i}.E;
    Data.E = E;
    his = histcounts(E,x)'; %his = [his'; his(end)];
    Data.Cor_Average = his./sum(his)./min(diff(x));
    error = sqrt(his)./sum(his)./min(diff(x));
    Data.Cor_SEM = error; Data.Cor_SEM(Data.Cor_SEM == 0) = 1;
    Data.Cor_Array = [];
    Data.Valid = [];
    Data.Counts = [numel(E), numel(E)];
    Data.Cor_Times = x(1:end-1)+bin/2;
    FCSData.Data{i} = Data;

    %%% Updates global parameters
    FCSMeta.Data{i,1} = FCSData.Data{i}.Cor_Times;
    FCSMeta.Data{i,2} = FCSData.Data{i}.Cor_Average;
    FCSMeta.Data{i,2}(isnan(FCSMeta.Data{i,2})) = 0;
    FCSMeta.Data{i,3} = FCSData.Data{i}.Cor_SEM;
    FCSMeta.Data{i,3}(isnan(FCSMeta.Data{i,3})) = 1;
    
    %%% Update Plots
    FCSMeta.Plots{i,1}.XData = FCSMeta.Data{i,1};
    FCSMeta.Plots{i,1}.YData = FCSMeta.Data{i,2};
    if isfield(FCSMeta.Plots{i,1},'YNegativeDelta')
        FCSMeta.Plots{i,1}.YNegativeDelta = error;
        FCSMeta.Plots{i,1}.YPOsitiveDelta = error;
    else
        FCSMeta.Plots{i,1}.LData = error;
        FCSMeta.Plots{i,1}.UData = error;
    end
    
    FCSMeta.Plots{i,4}.XData = FCSMeta.Data{i,1}-bin/2;
    FCSMeta.Plots{i,4}.YData = FCSMeta.Data{i,2};       
end
Update_Plots;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions to load and save the session %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LoadSave_Session(obj,e)
global UserValues FCSData FCSMeta
h = guidata(obj);
switch obj
    case h.LoadSession
        %%% get file
        [FileName,PathName] = uigetfile({'*.fcs','FCSFit Session (*.fcs)'},'Load FCSFit Session',UserValues.File.FCSPath,'MultiSelect','off');
        if FileName == 0
            return;
        end
        %%% Saves pathname to uservalues
        UserValues.File.FCSPath=PathName;
        LSUserValues(1);
        %%% Deletes loaded data
        FCSData=[];
        FCSData.Data=[];
        FCSData.FileName=[];
        cellfun(@delete,FCSMeta.Plots);
        FCSMeta.Data=[];
        FCSMeta.Params=[];
        FCSMeta.Plots=cell(0);
        h.Fit_Table.Data(1:end-3,:)=[];
        h.Style_Table.RowName(1:end-1,:)=[];
        h.Style_Table.Data(1:end-1,:)=[];

        %%% load data
        data = load(fullfile(PathName,FileName),'-mat');
        %%% update global variables
        FCSData = data.FCSData;
        FCSMeta = data.FCSMeta;
        %%% update UserValues settings, with exception of export settings
        UserValues.FCSFit.Fit_Min = data.Settings.Fit_Min;
        UserValues.FCSFit.Fit_Max = data.Settings.Fit_Max;
        UserValues.FCSFit.Plot_Errorbars = data.Settings.Plot_Errorbars;
        UserValues.FCSFit.Fit_Tolerance = data.Settings.Fit_Tolerance;
        UserValues.FCSFit.Use_Weights = data.Settings.Use_Weights;
        UserValues.FCSFit.Max_Iterations = data.Settings.Max_Iterations;
        UserValues.FCSFit.NormalizationMethod = data.Settings.NormalizationMethod;
        UserValues.FCSFit.Hide_Legend = data.Settings.Hide_Legend;
        UserValues.FCSFit.Conf_Interval = data.Settings.Conf_Interval;
        UserValues.FCSFit.FRETbin = data.Settings.FRETbin;
        UserValues.FCSFit.PlotStyles = data.Settings.PlotStyles;
        UserValues.FCSFit.PlotStyleAll = data.Settings.PlotStyleAll;
        UserValues.File.FCS_Standard = FCSMeta.Model.Name;
        LSUserValues(1);
        %%% update GUI according to loaded settings
        h.Fit_Min.String = num2str(UserValues.FCSFit.Fit_Min);
        h.Fit_Max.String = num2str(UserValues.FCSFit.Fit_Max);
        h.Fit_Errorbars.Value = UserValues.FCSFit.Plot_Errorbars;
        h.Tolerance.String = num2str(UserValues.FCSFit.Fit_Tolerance);
        h.Fit_Weights.Value = UserValues.FCSFit.Use_Weights;
        h.Iterations.String = num2str(UserValues.FCSFit.Max_Iterations);
        h.Normalize.Value = UserValues.FCSFit.NormalizationMethod;
        h.Conf_Interval.Value = UserValues.FCSFit.Conf_Interval;
        h.Hide_Legend.Value = UserValues.FCSFit.Hide_Legend;
        h.FRETbin.String = num2str(UserValues.FCSFit.FRETbin);
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
            h.Fit_Table.Data(1:end-3,2) = data.ActiveState;
            Update_Plots;
        end
        %%% Updates model text
        [~,name,~] = fileparts(FCSMeta.Model.Name);
        name_text = {'Loaded Fit Model:';name;};
        h.Loaded_Model_Name.String = sprintf('%s\n',name_text{:});
        h.Loaded_Model_Description.String = sprintf('%s\n',FCSMeta.Model.Description{:});
        h.Loaded_Model_Description.TooltipString = sprintf('%s\n',FCSMeta.Model.Description{:});
    case h.SaveSession
        %%% get filename
        [FileName, PathName] = uiputfile({'*.fcs','FCSFit Session (*.fcs)'},'Save Session as ...',fullfile(UserValues.File.FCSPath,[FCSData.FileName{1},'.fcs']));
        %%% save all data
        data.FCSMeta = FCSMeta;
        data.FCSMeta.Plots = cell(0);
        data.FCSData = FCSData;
        data.Settings = UserValues.FCSFit;
        data.FixState = h.Fit_Table.Data(1:end-3,6:3:end);
        data.GlobalState = h.Fit_Table.Data(1:end-3,7:3:end);
        data.ActiveState = h.Fit_Table.Data(1:end-3,2);
        save(fullfile(PathName,FileName),'-struct','data');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions to create basic plots on data load %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Create_Plots(~,~)
global UserValues FCSMeta FCSData
h = guidata(findobj('Tag','FCSFit'));
switch FCSMeta.DataType
    case {'FCS averaged','FCS individual'} %%% Correlation files
        for i=1:numel(FCSData.FileName)
            %%% Creates new plots
            FCSMeta.Plots{end+1,1} = errorbar(...
                FCSMeta.Data{i,1},...
                FCSMeta.Data{i,2},...
                FCSMeta.Data{i,3},...
                'Parent',h.FCS_Axes);
            FCSMeta.Plots{end,2} = line(...
                'Parent',h.FCS_Axes,...
                'XData',FCSMeta.Data{i,1},...
                'YData',zeros(numel(FCSMeta.Data{i,1}),1));
            FCSMeta.Plots{end,3} = line(...
                'Parent',h.Residuals_Axes,...
                'XData',FCSMeta.Data{i,1},...
                'YData',zeros(numel(FCSMeta.Data{i,1}),1));
            FCSMeta.Plots{end,4} = line(...
                'Parent',h.FCS_Axes,...
                'XData',FCSMeta.Data{i,1},...
                'YData',FCSMeta.Data{i,2});
        end
        %%% change the gui
        SwitchGUI(h,'FCS');
    case 'FRET'   %% 2color FRET data from BurstBrowser
        for i=1:numel(FCSData.FileName)
            %%% Creates new plots
            FCSMeta.Plots{end+1,1} = errorbar(...
                FCSMeta.Data{i,1},...
                FCSMeta.Data{i,2},...
                FCSMeta.Data{i,3},...
                'Parent',h.FCS_Axes);
            FCSMeta.Plots{end,2} = line(...
                'Parent',h.FCS_Axes,...
                'XData',FCSMeta.Data{i,1},...
                'YData',zeros(numel(FCSMeta.Data{i,1}),1));
            FCSMeta.Plots{end,3} = line(...
                'Parent',h.Residuals_Axes,...
                'XData',FCSMeta.Data{i,1},...
                'YData',zeros(numel(FCSMeta.Data{i,1}),1));
            FCSMeta.Plots{end,4} = stairs(...
                FCSMeta.Data{i,1}-UserValues.FCSFit.FRETbin/2,...
                FCSMeta.Data{i,2},...
                'Parent',h.FCS_Axes);            
        end
        %%% change the gui
        SwitchGUI(h,'FRET');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions for various small callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Misc (obj,e,mode)
global UserValues
h = guidata(findobj('Tag','FCSFit'));

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
           UserValues.FCSFit.Export_Font = f;
           LSUserValues(1);
   end
    
end

