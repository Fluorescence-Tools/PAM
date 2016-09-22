function MIAFit(~,~)
global UserValues MIAFitData MIAFitMeta

h.MIAFit=findobj('Tag','MIAFit');

if ~isempty(h.MIAFit) % Creates new figure, if none exists
    figure(h.MIAFit);
    return;
end

addpath(genpath(['.' filesep 'functions']));

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
h.MIAFit = figure(...
    'Units','normalized',...
    'Tag','MIAFit',...
    'Name','MIAFit',...
    'NumberTitle','off',...
    'Menu','none',...
    'defaultUicontrolFontName',Look.Font,...
    'defaultAxesFontName',Look.Font,...
    'defaultTextFontName',Look.Font,...
    'Toolbar','figure',...
    'UserData',[],...
    'OuterPosition',[0.01 0.1 0.98 0.9],...
    'CloseRequestFcn',@Close_MIAFit,...
    'Visible','on');

%%% Sets background of axes and other things
whitebg(Look.Axes);
%%% Changes Pam background; must be called after whitebg
h.MIAFit.Color=Look.Back;
%%% Remove unneeded items from toolbar
toolbar = findall(h.MIAFit,'Type','uitoolbar');
toolbar_items = findall(toolbar);
delete(toolbar_items([2:7 13:17]));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Menubar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% File menu with loading, saving and exporting functions
h.File = uimenu(...
    'Parent',h.MIAFit,...
    'Tag','File',...
    'Label','File');
%%% Menu to load new Cor file
h.LoadCor = uimenu(h.File,...
    'Tag','LoadCor',...
    'Label','Load New Cor Files',...
    'Callback',{@Load_Cor,1});
%%% Menu to add Cor files to existing
h.AddCor = uimenu(h.File,...
    'Tag','AddCor',...
    'Label','Add Cor Files',...
    'Callback',{@Load_Cor,2});
%%% Menu to load fit function
h.LoadFit = uimenu(h.File,...
    'Tag','LoadFit',...
    'Label','Load Fit Function',...
    'Callback',{@Load_Fit,1});
%%% File menu to stop fitting
h.AbortFit = uimenu(...
    'Parent',h.MIAFit,...
    'Tag','AbortFit',...
    'Label',' Stop....');
h.StopFit = uimenu(...
    'Parent',h.AbortFit,...
    'Tag','StopFit',...
    'Label','...Fit',...
    'Callback',@Stop_MIAFit);
%%% File menu for fitting
h.StartFit = uimenu(...
    'Parent',h.MIAFit,...
    'Tag','StartFit',...
    'Label','Start...');
%%% File menu for fitting
h.DoFit = uimenu(...
    'Parent',h.StartFit,...
    'Tag','Fit',...
    'Label','...Fit',...
    'Callback',@Do_MIAFit);

 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fitting parameters Tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Microtime tabs container
h.FitParams_Tab = uitabgroup(...
    'Parent',h.MIAFit,...
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
    'FontSize',8,...
    'Position',[0 0 1 1],...
    'CellEditCallback',{@Update_Table,3},...
    'CellSelectionCallback',{@Update_Table,3});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    'String','Size in X\Y [px]:',...
    'Position',[0.002 0.88 0.09 0.1]);
%%% Minimum and maximum for fitting and plotting
h.Fit_X = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Tag','Setting_Panel',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String',num2str(UserValues.MIAFit.Fit_X),...
    'Callback',@Update_Plots,...
    'Position',[0.096 0.88 0.04 0.1]);
h.Fit_Y = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Tag','Setting_Panel',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String',num2str(UserValues.MIAFit.Fit_Y),...
    'Callback',@Update_Plots,...
    'Position',[0.141 0.88 0.04 0.1]);
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
    'Value',UserValues.MIAFit.Use_Weights,...
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
    'Value',UserValues.MIAFit.Plot_Errorbars,...
    'Callback',@Update_Plots,...
    'Position',[0.002 0.64 0.1 0.1]);
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
    'String',{'None';'Fit N 3D';'Fit G(0)';'Fit N 2D'; 'Point X\Y'},...
    'Value',UserValues.MIAFit.NormalizationMethod,...
    'Callback',@Update_Plots,...
    'Position',[0.082 0.52 0.06 0.1]);
if ismac
    h.Normalize.ForegroundColor = [0 0 0];
    h.Normalize.BackgroundColor = [1 1 1];
end
%%% Editbox to set X point used for normalization
h.Norm_X = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Tag','Normalize',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String','1',...
    'Visible','off',...
    'Callback',@Update_Plots,...
    'Position',[0.145 0.51 0.04 0.1]);
%%% Editbox to set Y point used for normalization
h.Norm_Y = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Tag','Normalize',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String','0',...
    'Visible','off',...
    'Callback',@Update_Plots,...
    'Position',[0.19 0.51 0.04 0.1]);
%%% Checkbox to omit center point
h.Omit_Center = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Tag','Omit_Center',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Style','checkbox',...
    'Value',UserValues.MIAFit.Omit,...
    'String','Omit center',...
    'Callback',@Update_Plots,...
    'Position',[0.002 0.37 0.1 0.1]);
%%% Checkbox to omit middle line
h.Omit_Center_Line = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Tag','Omit_Center_Line',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Style','checkbox',...
    'Value',UserValues.MIAFit.Omit_Center_Line,...
    'String','Omit center line',...
    'Callback',@Update_Plots,...
    'Position',[0.002 0.23 0.1 0.1]);
%%% Checkbox to hide legend
h.Hide_Legend = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Tag','Normalize',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Style','checkbox',...
    'Value',UserValues.MIAFit.Hide_Legend,...
    'String','Hide Legend',...
    'Callback',@Update_Plots,...
    'Position',[0.002 0.09 0.1 0.1]);
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
    'String',num2str(UserValues.MIAFit.Max_Iterations),...
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
    'String',num2str(UserValues.MIAFit.Fit_Tolerance),...
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
    'Position',[0.35 0.01 0.13 0.98]);

%%% Text for export size
uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Style','text',...
    'String','Export size [pixels]:',...
    'Position',[0.5 0.88 0.11 0.1]);

%%% Editbox for export size
h.Export_Size = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String','150',...
    'Position',[0.61 0.88 0.04 0.1]);

%%% Text for number of export plots
uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Style','text',...
    'String','Number of plots:',...
    'Position',[0.655 0.88 0.1 0.1]);

%%% Editbox for number of horizontal plots
h.Export_NumX = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String','3',...
    'Callback',{@Plot_Menu_Callback,3},...
    'Position',[0.755 0.88 0.04 0.1]);

%%% Editbox for number of vertical plots
h.Export_NumY = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String','1',...
    'Callback',{@Plot_Menu_Callback,3},...
    'Position',[0.80 0.88 0.04 0.1]);

%%% Text for rotation of surface plots
uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Style','text',...
    'String','Rotation:',...
    'Position',[0.845 0.88 0.05 0.1]);

%%% Editbox for horizontal rotation
h.Export_RotX = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String','135',...
    'Position',[0.9 0.88 0.04 0.1]);

%%% Editbox for vertical rotation
h.Export_RotY = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String','35',...
    'Position',[0.945 0.88 0.04 0.1]);

%%% Text for font name
uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Style','text',...
    'String','Font name:',...
    'Position',[0.5 0.75 0.06 0.1]);

%%% Editbox for font name
h.Export_FontName = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Style','edit',...
    'String','Arial',...
    'Position',[0.56 0.75 0.13 0.1]);
%%% Text for font size
uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Style','text',...
    'String','Font size:',...
    'Position',[0.695 0.75 0.06 0.1]);
%%% Editbox for font size
h.Export_FontSize = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String','10',...
    'Position',[0.755 0.75 0.04 0.1]);

%%% Text for error limits
uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Style','text',...
    'String','Error limits:',...
    'Position',[0.8 0.75 0.06 0.1]);
%%% Editbox for font size
h.Export_ErrorLim = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String','5',...
    'Position',[0.86 0.75 0.035 0.1]);

%%% Text for transparency
uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Style','text',...
    'String','Alpha:',...
    'Position',[0.9 0.75 0.04 0.1]);
%%% Editbox for font size
h.Export_Alpha = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String','1',...
    'Position',[0.945 0.75 0.04 0.1]);


%%% Names for export plot types
h.Export_Types = {'Nothing',...
                  'On-Axis X All',...
                  'On-Axis X Ind',...
                  'On-Axis Y All',...
                  'On-Axis Y Ind',...
                  'On-Axis XY Ind',...
                  '2D Data Image',...
                  '2D Fit Image',...
                  '2D Res Image',...
                  '2D Data Surf',...
                  '2D Fit Surf',...
                  '2D Res Surf',...
                  '2D Data/Res Surf'};

h.Export_Table = uitable(...
    'Parent',h.Setting_Panel,...
    'Tag','Fit_Table',...
    'Units','normalized',...
    'ForegroundColor',Look.TableFore,...
    'BackgroundColor',[Look.Table1;Look.Table2],...
    'FontSize',8,...
    'ColumnName', {'1','1','2','2','3','3'},...
    'ColumnEditable', [true,true,true,true,true,true],...
    'ColumnWidth',{105,60,105,60,105,60,},...
    'Data', {h.Export_Types{6},'File 1',h.Export_Types{10},'File 1',h.Export_Types{13},'File 1'},...
    'ColumnFormat', {h.Export_Types,{'File 1'},h.Export_Types,{'File 1'}, h.Export_Types,{'File 1'}},...                      
    'Position',[0.5 0.01 0.495 0.7]);

h.Export_Table.ColumnEditable = true;
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
h.Style_Table = uitable(...
    'Parent',h.Style_Panel,...
    'Tag','Fit_Table',...
    'Units','normalized',...
    'ForegroundColor',Look.TableFore,...
    'BackgroundColor',[Look.Table1;Look.Table2],...
    'FontSize',8,...
    'Position',[0 0 1 1],...
    'CellEditCallback',{@Update_Style,2});
%% Main Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Main plots tab container
h.Main_Tab = uitabgroup(...
    'Parent',h.MIAFit,...
    'Units','normalized',...
    'Position',[0.005 0.26 0.99 0.73]);

    %%% Context menu for FCS plots 
    h.MIAFit_Plot_Menu = uicontextmenu;
    h.MIAFit_Plot_Export2Fig = uimenu(...
        'Parent',h.MIAFit_Plot_Menu,...
        'Label','Export to figure',...
        'Checked','off',...
        'Tag','MIAFit__Plot_Export2Fig',...
        'Callback',{@Plot_Menu_Callback,1});
    h.MIAFit_Plot_Export2Base = uimenu(...
        'Parent',h.MIAFit_Plot_Menu,...
        'Label','Export to workspace',...
        'Checked','off',...
        'Tag','MIAFit_Plot_Export2Base',...
        'Callback',{@Plot_Menu_Callback,2});
    h.MIAFit_Plot_Export2Clip = uimenu(...
        'Parent',h.MIAFit_Plot_Menu,...
        'Label','Export to clipboard',...
        'Checked','off',...
        'Tag','MIAFit_Plot_Export2Clip',...
        'Callback',{@Plot_Menu_Callback,4});
    
    %% On axis plots
%%% On axis plots tab
h.On_Axis_Tab= uitab(...
    'Parent',h.Main_Tab,...
    'Title','On axis');

%%% Panel for on axis plots
h.On_Axis_Panel = uibuttongroup(...
    'Parent',h.On_Axis_Tab,...
    'Tag','Fit_Plots_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Axes for on Chi axis plot
h.X_Axes = axes(...
    'Parent',h.On_Axis_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
        'XLim',[10^-6,1],...
    'Position',[0.06 0.28 0.43 0.7],...
    'UIContextMenu',h.MIAFit_Plot_Menu,...
    'Box','off');
h.X_Axes.XLabel.String = 'Pixel Lag {\it\xi{}} [pixels]';
h.X_Axes.XLabel.Color = Look.Fore;
h.X_Axes.YLabel.String = 'G({\it\xi{}},0)';
h.X_Axes.YLabel.Color = Look.Fore;

%%% Axes for chi residuals
h.XRes_Axes = axes(...
    'Parent',h.On_Axis_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
        'XAxisLocation','top',....
    'Position',[0.06 0.02 0.43 0.18],...
    'Box','off',...
    'YGrid','on',...
    'UIContextMenu',h.MIAFit_Plot_Menu,...
    'XGrid','on');
h.XRes_Axes.GridColorMode = 'manual';
h.XRes_Axes.GridColor = [0 0 0];
h.XRes_Axes.XTickLabel=[];
h.XRes_Axes.YLabel.String = 'Weighted residuals';
h.XRes_Axes.YLabel.Color = Look.Fore;
linkaxes([h.X_Axes h.XRes_Axes],'x');

%%% Axes for on Psi axis plot
h.Y_Axes = axes(...
    'Parent',h.On_Axis_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
        'XLim',[10^-6,1],...
    'Position',[0.56 0.28 0.43 0.7],...
    'UIContextMenu',h.MIAFit_Plot_Menu,...
    'Box','off');
h.Y_Axes.XLabel.String = 'Pixel Lag {\it\psi{}} [pixels]';
h.Y_Axes.XLabel.Color = Look.Fore;
h.Y_Axes.YLabel.String = 'G({0,\it\psi{}})';
h.Y_Axes.YLabel.Color = Look.Fore;

%%% Axes for chi residuals
h.YRes_Axes = axes(...
    'Parent',h.On_Axis_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
        'XAxisLocation','top',...
    'Position',[0.56 0.02 0.43 0.18],...
    'Box','off',...
    'YGrid','on',...
    'UIContextMenu',h.MIAFit_Plot_Menu,...
    'XGrid','on');
h.YRes_Axes.GridColorMode = 'manual';
h.YRes_Axes.GridColor = [0 0 0];
h.YRes_Axes.XTickLabel=[];
h.YRes_Axes.YLabel.String = 'Weighted residuals';
h.YRes_Axes.YLabel.Color = Look.Fore;
linkaxes([h.Y_Axes h.YRes_Axes],'x');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Individual 2D Plots
%%% 2D plots tab
h.Full_Plot_Tab= uitab(...
    'Parent',h.Main_Tab,...
    'Title','2D Plots');

%%% Panel for on axis plots
h.Full_Plot_Panel = uibuttongroup(...
    'Parent',h.Full_Plot_Tab,...
    'Tag','Fit_Plots_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% 2D main plot axis
h.Full_Main_Axes = axes(...
    'Parent',h.Full_Plot_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'ZColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
        'View',[145,25],...
    'Position',[0.06 0.2 0.43 0.78],...
    'UIContextMenu',h.MIAFit_Plot_Menu,...
    'Box','off');
h.Full_Main_Axes.XLabel.String = 'Pixel Lag {\it\xi{}} [pixels]';
h.Full_Main_Axes.XLabel.Color = Look.Fore;
h.Full_Main_Axes.YLabel.String = 'Pixel Lag {\it\psi{}} [pixels]';
h.Full_Main_Axes.YLabel.Color = Look.Fore;
h.Full_Main_Axes.ZLabel.String = 'G({\it\xi{}},{\it\psi{}})';
h.Full_Main_Axes.ZLabel.Color = Look.Fore;
%%% Surface plot for 2D data
h.Plots.Main=surf(zeros(2),zeros(2,2,3),...
    'Parent',h.Full_Main_Axes,...
    'FaceColor','Flat');
%%% 2D fit plot
h.Full_Fit_Axes = axes(...
    'Parent',h.Full_Plot_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'ZColor',Look.Fore,...
    'LineWidth', Look.AxWidth,...
        'View',[0,25],...
    'Position',[0.56 0.2 0.43 0.78],...
    'UIContextMenu',h.MIAFit_Plot_Menu,...
    'Box','off');
h.Full_Fit_Axes.XLabel.String = 'Pixel Lag {\it\xi{}} [pixels]';
h.Full_Fit_Axes.XLabel.Color = Look.Fore;
h.Full_Fit_Axes.YLabel.String = 'Pixel Lag {\it\psi{}} [pixels]';
h.Full_Fit_Axes.YLabel.Color = Look.Fore;
h.Full_Fit_Axes.ZLabel.String = 'G({\it\xi{}},{\it\psi{}})';
h.Full_Fit_Axes.ZLabel.Color = Look.Fore;
%%% Surface plot for 2D fit
h.Plots.Fit=surf(zeros(2),zeros(2,2,3),...
    'Parent',h.Full_Fit_Axes,...
    'FaceColor','Flat');
%%% Links plots together
h.Full_Link = linkprop([h.Full_Main_Axes,h.Full_Fit_Axes],...
    {'View','XLim','YLim','ZLim','DataAspectRatio'});
h.Full_Listener = addlistener(h.Full_Main_Axes,'View','PostSet',@(src,event) Plot_Menu_Callback(src,event,5));
h.Full_Rot = uicontrol(...
    'Parent',h.Full_Plot_Panel,...
    'Units','normalized',...
    'FontSize',10,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Style','text',...
    'String','145, 25',...
    'Position',[0.002 0.96 0.04 0.02]);

%%% Determines, which file to plot
h.Plot2D = uicontrol(...
    'Parent',h.Full_Plot_Panel,...
    'Units','normalized',...
    'FontSize',10,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','popupmenu',...
    'String',{'Nothing selected'},...
    'Value',1,...
    'Callback',@Update_Plots,...
    'Position',[0.005 0.02 0.15 0.04]);
if ismac
    h.Plot2D.ForegroundColor = [0 0 0];
    h.Plot2D.BackgroundColor = [1 1 1];
end
%%% Determines, how to plot second graph
h.Plot2DStyle = uicontrol(...
    'Parent',h.Full_Plot_Panel,...
    'Units','normalized',...
    'FontSize',10,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','popupmenu',...
    'String',{'Fit','Residuals','Fit\Residuals'},...
    'Value',1,...
    'Callback',@Update_Plots,...
    'Position',[0.005 0.065 0.15 0.04]);
if ismac
    h.Plot2DStyle.ForegroundColor = [0 0 0];
    h.Plot2DStyle.BackgroundColor = [1 1 1];
end
%% Initializes global variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MIAFitData=[];
MIAFitData.Data=cell(0);
MIAFitData.FileName=cell(0);
MIAFitData.Counts=cell(0);
MIAFitMeta=[];
MIAFitMeta.Data=[];
MIAFitMeta.Params=[];
MIAFitMeta.Confidence_Intervals = cell(1,1);
MIAFitMeta.Plots=cell(0);
MIAFitMeta.Model=[];
MIAFitMeta.Fits=[];
MIAFitMeta.Color=[1 1 0; 0 0 1; 1 0 0; 0 0.5 0; 1 0 1; 0 1 1];
MIAFitMeta.FitInProgress = 0;

guidata(h.MIAFit,h);
Load_Fit([],[],0);
Update_Style([],[],0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to close figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_MIAFit(Obj,~)
clear global -regexp MIAFitData MIAFitMeta
Phasor=findobj('Tag','Phasor');
FCSFit=findobj('Tag','FCSFit');
Pam=findobj('Tag','Pam');
Mia=findobj('Tag','Mia');
Sim=findobj('Tag','Sim');
PCF=findobj('Tag','PCF');
BurstBrowser=findobj('Tag','BurstBrowser');
TauFit=findobj('Tag','TauFit');
PhasorTIFF = findobj('Tag','PhasorTIFF');
if isempty(Phasor) && isempty(FCSFit) && isempty(Pam) && isempty(PCF) && isempty(Mia) && isempty(Sim) && isempty(TauFit) && isempty(BurstBrowser) && isempty(PhasorTIFF)
    clear global -regexp UserValues
end
delete(Obj);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to load .cor files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Cor(~,~,mode)
global UserValues MIAFitData MIAFitMeta
h = guidata(findobj('Tag','MIAFit'));

%%% Choose files to load
[FileName,PathName,Type] = uigetfile({'*.miacor', 'MIA 2D correlation file'; '*.tif', 'TIFFs generated with MIA';'*.tif','General TIFFs';'*.stcor', 'MIA 3D correlation file';}, 'Choose an image data file', UserValues.File.MIAFitPath, 'MultiSelect', 'on');
%%% Tranforms to cell array, if only one file was selected
if ~iscell(FileName)
    FileName = {FileName};
end

%%% Stops, if no file was selected
if all(FileName{1}==0)  
    return;
end
%%% Only allows one STICS file at a time
if Type==4
    FileName = FileName(1);
end

%%% Saves pathname to uservalues
UserValues.File.MIAFitPath=PathName;
LSUserValues(1);
%%% Deletes loaded data
if mode==1 || Type == 4
    MIAFitData=[];
    MIAFitData.Data=cell(0);
    MIAFitData.FileName=cell(0);
    MIAFitData.Counts=cell(0);
    cellfun(@delete,MIAFitMeta.Plots);
    MIAFitMeta.Data=[];
    MIAFitMeta.Params=[];
    MIAFitMeta.Plots=cell(0);
    h.Fit_Table.RowName(1:end-3)=[];
    h.Fit_Table.Data(1:end-3,:)=[];
    h.Style_Table.RowName(1:end-1,:)=[];
    h.Style_Table.Data(1:end-1,:)=[];
end
for i=1:numel(FileName)
    switch Type
        case 1 %% MIA correlation file based on .mat file
            MIAFitData.FileName{end+1} = FileName{i};
            load([PathName FileName{i}],'-mat','Data');
            MIAFitData.Data{end+1,1} = Data{1}; %#ok<USENS>
            MIAFitData.Data{end,2} = Data{2};
            clear Data;
            load([PathName FileName{i}],'-mat','Info');
            MIAFitData.Counts{end+1} = Info.Counts/Info.Times(1)*1000;
        case 2 %% MIA correlation file based on .tif + info file
            MIAFitData.FileName{end+1} = FileName{i};
            FileInfo=imfinfo(fullfile(PathName,FileName{i}));
            if numel(FileInfo)==2
                Info = str2num(FileInfo(1).ImageDescription); %#ok<ST2NM>
                MIAFitData.Data{end+1,1} = double(imread(fullfile(PathName,FileName{i}),'TIFF','Index',1));
                MIAFitData.Data{end,1} = MIAFitData.Data{end,1}/Info(1)+Info(2);
                MIAFitData.Counts{end+1} = Info(3)/Info(4)*1000;
                Info = str2num(FileInfo(2).ImageDescription); %#ok<ST2NM>
                MIAFitData.Data{end,2} = double(imread(fullfile(PathName,FileName{i}),'TIFF','Index',2));
                MIAFitData.Data{end,2} = MIAFitData.Data{end,2}/Info(1)+Info(2);
            end  
        case 4 %% MIA stics correlation file based on .mat file   
            load([PathName FileName{i}],'-mat','Data');
            load([PathName FileName{i}],'-mat','Info');
            for j=1:size(Data{1},3)
                MIAFitData.Data{end+1,1} = Data{1}(:,:,j);
                MIAFitData.Data{end,2} = Data{2}(:,:,j);
                MIAFitData.FileName{end+1} = FileName{i};
                MIAFitData.Counts{end+1} = Info.Counts/Info.Times(1)*1000;
            end
    end
    switch Type
        case {1 2 3} %%% Single plots per file (ICS and RICS)
            %% Creates new plots
            Center = ceil((size(MIAFitData.Data{end,1})+1)/2);
            %%% On Axis X plot
            MIAFitMeta.Plots{end+1,1} = errorbar(...
                0,...
                MIAFitData.Data{end,1}(Center(1), Center(2)),...
                MIAFitData.Data{end,2}(Center(1), Center(2)),...
                'Parent',h.X_Axes);
            %%% On Axis X fit
            MIAFitMeta.Plots{end,2} = line(...
                'Parent',h.X_Axes,...
                'XData',0,...
                'YData',zeros(1));
            %%% On Axis X residuals
            MIAFitMeta.Plots{end,3} = line(...
                'Parent',h.XRes_Axes,...
                'XData',0,...
                'YData',zeros(1));
            %%% On Axis Y plot
            MIAFitMeta.Plots{end,4} = errorbar(...
                0,...
                MIAFitData.Data{end,1}(Center(1),Center(2)),...
                MIAFitData.Data{end,2}(Center(1),Center(2)),...
                'Parent',h.Y_Axes);
            %%% On Axis Y fit
            MIAFitMeta.Plots{end,5} = line(...
                'Parent',h.Y_Axes,...
                'XData',0,...
                'YData',zeros(1));
            %%% On Axis Y residuals
            MIAFitMeta.Plots{end,6} = line(...
                'Parent',h.YRes_Axes,...
                'XData',0,...
                'YData',zeros(1));
            MIAFitMeta.Params(:,end+1)=cellfun(@str2double,h.Fit_Table.Data(end-2,4:3:end-1));
        case 4 %%% Multiple plots per file (STICS/iMSD)
            for j=1:size(Data{1},3)
                %% Creates new plots
                Center = ceil((size(MIAFitData.Data{end,1})+1)/2);
                %%% On Axis X plot
                MIAFitMeta.Plots{end+1,1} = errorbar(...
                    0,...
                    MIAFitData.Data{end,1}(Center(1), Center(2)),...
                    MIAFitData.Data{end,2}(Center(1), Center(2)),...
                    'Parent',h.X_Axes);
                %%% On Axis X fit
                MIAFitMeta.Plots{end,2} = line(...
                    'Parent',h.X_Axes,...
                    'XData',0,...
                    'YData',zeros(1));
                %%% On Axis X residuals
                MIAFitMeta.Plots{end,3} = line(...
                    'Parent',h.XRes_Axes,...
                    'XData',0,...
                    'YData',zeros(1));
                %%% On Axis Y plot
                MIAFitMeta.Plots{end,4} = errorbar(...
                    0,...
                    MIAFitData.Data{end,1}(Center(1),Center(2)),...
                    MIAFitData.Data{end,2}(Center(1),Center(2)),...
                    'Parent',h.Y_Axes);
                %%% On Axis Y fit
                MIAFitMeta.Plots{end,5} = line(...
                    'Parent',h.Y_Axes,...
                    'XData',0,...
                    'YData',zeros(1));
                %%% On Axis Y residuals
                MIAFitMeta.Plots{end,6} = line(...
                    'Parent',h.YRes_Axes,...
                    'XData',0,...
                    'YData',zeros(1));
                MIAFitMeta.Params(:,end+1)=cellfun(@str2double,h.Fit_Table.Data(end-2,4:3:end-1));
            end
    end
end
%%% Updates table and plot data and style to new size
h.Export_Table.Data(:,2:2:end)={'File 1'};
Files={};
for i=1:numel(MIAFitData.FileName);
    Files{i}=['File ' num2str(i)];
end
h.Export_Table.ColumnFormat(2:2:end)={Files};

Update_Style([],[],1);
Update_Table([],[],1); %contains UpdatePlots, where the 2D plot is updated


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes fit function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Fit(~,~,mode)
global MIAFitMeta MIAFitData UserValues

FileName=[];
if mode %% Select a new model to load
    [FileName,PathName]= uigetfile('.miafit', 'Choose a fit model', [pwd filesep 'Models']);
    FileName=fullfile(PathName,FileName);
elseif isempty(UserValues.File.MIAFit_Standard) || ~exist(UserValues.File.MIAFit_Standard,'file') 
    %% Opens the first model in the folder at the start of the program
    Models=dir([pwd filesep 'Models']);
    Models=Models(~cell2mat({Models.isdir}));
    while isempty(FileName) && ~isempty(Models)
       if strcmp(Models(1).name(end-6:end),'.miafit')
           FileName=[pwd filesep 'Models' filesep Models(1).name];
           UserValues.File.MIAFit_Standard=FileName;
       else
           Models(1)=[];
       end
    end
else
    %% Opens last model used before closing program
    FileName=UserValues.File.MIAFit_Standard;
end

if ~isempty(FileName)
    UserValues.File.MIAFit_Standard=FileName;
    LSUserValues(1);
    
    %%% Reads in the selected fit function file
    fid = fopen(FileName);
    Text=textscan(fid,'%s', 'delimiter', '\n','whitespace', '');
    fclose(fid);
    Text=Text{1};
    
    %%% Finds line, at which parameter definition starts
    Param_Start=find(~cellfun(@isempty,strfind(Text,'-PARAMETER DEFINITION-')),1);
    %%% Finds line, at which function definition starts
    Fun_Start=find(~cellfun(@isempty,strfind(Text,'-FIT FUNCTION-')),1);
    B_Start=find(~cellfun(@isempty,strfind(Text,'-BRIGHTNESS DEFINITION-')),1);
    %%% Defines the number of parameters
    NParams=B_Start-Param_Start-1;
    MIAFitMeta.Model=[];
    MIAFitMeta.Model.Name=FileName;
    MIAFitMeta.Model.Brightness=Text{B_Start+1};
    %%% Concaternates the function string
    MIAFitMeta.Model.Function=[];
    for i=Fun_Start+1:numel(Text)
        MIAFitMeta.Model.Function=[MIAFitMeta.Model.Function Text(i)];
    end
    MIAFitMeta.Model.Function=cell2mat(MIAFitMeta.Model.Function);
    %%% Convert to function handle
    FunctionStart = strfind(MIAFitMeta.Model.Function,'=');
    eval(['MIAFitMeta.Model.Function = @(P,x,y,i) ' MIAFitMeta.Model.Function((FunctionStart(1)+1):end)]);
    %%% Extracts parameter names, initial values and bounds
    MIAFitMeta.Model.Params=cell(NParams,1);
    MIAFitMeta.Model.Value=zeros(NParams,1);
    MIAFitMeta.Model.LowerBoundaries = zeros(NParams,1);
    MIAFitMeta.Model.UpperBoundaries = zeros(NParams,1);
    MIAFitMeta.Model.State = zeros(NParams,1);
    %%% Reads parameters and values from file
    for i=1:NParams
        %%% Reads parameter name
        Param_Pos=strfind(Text{i+Param_Start},' ');
        MIAFitMeta.Model.Params{i}=Text{i+Param_Start}((Param_Pos(1)+1):(Param_Pos(2)-1));
        
        Start = strfind(Text{i+Param_Start},'=');
        Stop = strfind(Text{i+Param_Start},';');
        
        %%% Reads starting value    
        MIAFitMeta.Model.Value(i) = str2double(Text{i+Param_Start}(Start(1)+1:Stop(1)-1));
        MIAFitMeta.Model.LowerBoundaries(i) = str2double(Text{i+Param_Start}(Start(2)+1:Stop(2)-1));   
        MIAFitMeta.Model.UpperBoundaries(i) = str2double(Text{i+Param_Start}(Start(3)+1:Stop(3)-1));
        if numel(Text{i+Param_Start})>Stop(3) && any(strfind(Text{i+Param_Start}(Stop(3):end),'g'))
            MIAFitMeta.Model.State(i) = 2;
        elseif numel(Text{i+Param_Start})>Stop(3) && any(strfind(Text{i+Param_Start}(Stop(3):end),'f'))
            MIAFitMeta.Model.State(i) = 1;
        end
    end    
    MIAFitMeta.Params=repmat(MIAFitMeta.Model.Value,[1,size(MIAFitData.Data,1)]);
    
    %%% Updates table to new model
    Update_Table([],[],0);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Context menu callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1: Export to figure
%%% 2: Export to Workspace
%%% 3: Change number of export plots
%%% 4: Copy parameters to clipboard
%%% 5: Rotate 2D Axes
function Plot_Menu_Callback(Obj,~,mode)
h = guidata(findobj('Tag','MIAFit'));
global MIAFitData MIAFitMeta
if isempty(MIAFitData.FileName) && any(mode==[1,4])
    return;
end

switch mode
    case 1 %%% Export plots to figure
        Size = str2double(h.Export_Size.String);
        FontSize = str2double(h.Export_FontSize.String);
        Font = h.Export_FontName.String;
        NoP = size(h.Export_Table.Data);  
        View = [str2double(h.Export_RotX.String),str2double(h.Export_RotY.String)];
        Alpha = str2double(h.Export_Alpha.String);

        %%% Creates Figure
        H.Fig = figure(...
            'Units','points',...
            'defaultUicontrolFontName',Font,...
            'defaultAxesFontName',Font,...
            'defaultTextFontName',Font,...
            'Position',[50 150 NoP(2)/2*(Size+8*FontSize+40) NoP(1)*(Size+4*FontSize+5)]);
        whitebg([1 1 1]); 
        %%% Goes through all axes
        for i=1:NoP(2)/2
            for j=1:NoP(1)                
                %% Creates axes
                H.Axes{i,j}=axes(...
                    'Parent',H.Fig,...
                    'FontSize', FontSize,...
                    'Units','points',...
                    'NextPlot','add',...
                    'Position',[10+3.5*FontSize+(i-1)*(Size+8*FontSize+35), 3.5*FontSize+(j-1)*(Size+4*FontSize), Size+4*FontSize+15, Size]);                
                %% Determines X and Y Scale and Limits
                x = str2double(h.Fit_X.String);
                y = str2double(h.Fit_Y.String);
                [x,y] = meshgrid(1:x,1:y);
                x = x - ceil(max(max(x))/2);
                y = y - ceil(max(max(y))/2);
                %% Determines Valid Points and Normalization
                File = str2double(h.Export_Table.Data{j,2*i}(6:end));
                Center = ceil((size(MIAFitData.Data{File,1})+1)/2);
                switch h.Normalize.Value
                    case 1 %% No normalization
                        B =1 ;
                    case 2 %% Normalizes to number of particles 3D (defined in model)
                        P = MIAFitMeta.Params(:,File); %#ok<NASGU>
                        eval(MIAFitMeta.Model.Brightness);
                        B = B/sqrt(8);
                        if isnan(B) || B==0 || isinf(B)
                            B = 1;
                        end
                    case 3 %% Normalizes to G(0) of the fit
                        P = MIAFitMeta.Params(:,File); x = 0; y = 0;
                        B = feval(MIAFitMeta.Model.Function,P,x,y,i);
                        if isnan(B) || B==0 || isinf(B)
                            B = 1;
                        end
                        x = str2double(h.Fit_X.String);
                        %%% Has to reset x and y parameters again;
                        y = str2double(h.Fit_Y.String);
                        [x,y] = meshgrid(1:x,1:y);
                        x = x - ceil(max(max(x))/2);
                        y = y - ceil(max(max(y))/2);
                    case 4 %% Normalizes to number of particles 2D (defined in model)
                        P = MIAFitMeta.Params(:,File); %#ok<NASGU>
                        eval(MIAFitMeta.Model.Brightness);
                        B = B/sqrt(4);
                        if isnan(B) || B==0 || isinf(B)
                            B = 1;
                        end
                    case 5 %% Normalizes to selected pixel
                        h.Norm_X.Visible='on';
                        h.Norm_Y.Visible='on';
                        B = MIAFitData.Data{File,1}(Center(1)+(str2double(h.Norm_Y.String)), Center(2)+(str2double(h.Norm_X.String)));
                end               
                %% Determins plot type
                for Type = 1:14
                    if strcmp(h.Export_Types{Type}, h.Export_Table.Data{j,(2*i-1)})
                        break;
                    end
                end
                %% Plots data
                switch Type
                    case 1 %%% Nothing plotted 
                        delete (H.Axes{i,j});                        
                    case {2 3} %%% On-Axes X Plots
                        %%% Shrinks Axes
                        H.Axes{i,j}.Position(4) = 0.7*Size;
                        %%% Adds residual axes
                        H.Res{i,j} =axes(...
                            'Parent',H.Fig,...
                            'FontSize', FontSize,...
                            'Units','points',...
                            'NextPlot','add',...
                            'XTick',[],...
                            'Position',[H.Axes{i,j}.Position(1),H.Axes{i,j}.Position(2)+H.Axes{i,j}.Position(4)+FontSize,H.Axes{i,j}.Position(3),0.2*Size]);
                        %%% Loads all active files if selected
                        if Type == 2
                           File = find(cell2mat(h.Fit_Table.Data(1:end-3,1)))';                             
                        end
                        
                        %%% Copies curves
                        H.Plots{i,j} = {};
                        for k = File
                            H.Plots{i,j}{1,end+1} = copyobj(MIAFitMeta.Plots{k,1},H.Axes{i,j});
                            H.Plots{i,j}{2,end} = copyobj(MIAFitMeta.Plots{k,2},H.Axes{i,j});
                            H.Plots{i,j}{3,end} = copyobj(MIAFitMeta.Plots{k,3},H.Res{i,j});
                        end
                        %%% Sets axes label and limits
                        H.Axes{i,j}.XLim = [x(1) x(end)];
                        H.Axes{i,j}.XLabel.String = 'Pixel Lag {\it\xi{}}';
                        H.Axes{i,j}.YLabel.String = 'G({\it\xi{}},0)';
                        H.Res{i,j}.XLim = [x(1) x(end)];
                        
                        if h.Fit_Weights.Value
                            H.Res{i,j}.YLabel.String = 'W. Res.';
                        else
                            H.Res{i,j}.YLabel.String = 'Res.';
                        end
                        H.Res{i,j}.Position([1 3]) = H.Axes{i,j}.Position([1 3]);                        
                    case {4 5} %%% On-Axes Y Plots
                        %%% Shrinks Axes
                        H.Axes{i,j}.Position(4) = 0.7*Size;
                        %%% Adds residual axes
                        H.Res{i,j} =axes(...
                            'Parent',H.Fig,...
                            'FontSize', FontSize,...
                            'Units','points',...
                            'NextPlot','add',...
                            'XTick',[],...
                            'Position',[H.Axes{i,j}.Position(1),H.Axes{i,j}.Position(2)+H.Axes{i,j}.Position(4)+FontSize,H.Axes{i,j}.Position(3),0.2*Size]);
                        %%% Loads all active files if selected
                        if Type == 4
                           File = find(cell2mat(h.Fit_Table.Data(1:end-3,1)))';                             
                        end
                        
                        %%% Copies curves
                        H.Plots{i,j} = {};
                        for k = File
                            H.Plots{i,j}{1,end+1} = copyobj(MIAFitMeta.Plots{k,4},H.Axes{i,j});
                            H.Plots{i,j}{2,end} = copyobj(MIAFitMeta.Plots{k,5},H.Axes{i,j});
                            H.Plots{i,j}{3,end} = copyobj(MIAFitMeta.Plots{k,6},H.Res{i,j});
                        end
                        %%% Sets axes label and limits
                        H.Axes{i,j}.XLim = [y(1) y(end)];
                        H.Axes{i,j}.XLabel.String = 'Pixel Lag {\it\psi{}}';
                        H.Axes{i,j}.YLabel.String = 'G(0,{\it\psi{}})';
                        H.Res{i,j}.XLim = [y(1) y(end)];
                        if h.Fit_Weights.Value
                            H.Res{i,j}.YLabel.String = 'W. Res.';
                        else
                            H.Res{i,j}.YLabel.String = 'Res.';
                        end
                        H.Res{i,j}.Position([1 3]) = H.Axes{i,j}.Position([1 3]);
                    case 6 %%% On Axes Plots for X and Y for one File 
                        %%% Shrinks Axes
                        H.Axes{i,j}.Position(4) = 0.7*Size;
                        %%% Adds residual axes
                        H.Res{i,j} =axes(...
                            'Parent',H.Fig,...
                            'FontSize', FontSize,...
                            'Units','points',...
                            'NextPlot','add',...
                            'XTick',[],...
                            'Position',[H.Axes{i,j}.Position(1),H.Axes{i,j}.Position(2)+H.Axes{i,j}.Position(4)+FontSize,H.Axes{i,j}.Position(3),0.2*Size]);
                        
                        %%% Copies X curves
                        H.Plots{i,j} = {};
                        H.Plots{i,j}{1,end+1} = copyobj(MIAFitMeta.Plots{File,1},H.Axes{i,j});
                        H.Plots{i,j}{2,end} = copyobj(MIAFitMeta.Plots{File,2},H.Axes{i,j});
                        H.Plots{i,j}{3,end} = copyobj(MIAFitMeta.Plots{File,3},H.Res{i,j});
                        %%% Copies Y curves and shifts color
                        H.Plots{i,j}{1,end+1} = copyobj(MIAFitMeta.Plots{File,4},H.Axes{i,j});
                        H.Plots{i,j}{1,end}.Color = circshift(H.Plots{i,j}{1,end}.Color,[1 1]);
                        H.Plots{i,j}{2,end} = copyobj(MIAFitMeta.Plots{File,5},H.Axes{i,j});
                        H.Plots{i,j}{2,end}.Color = circshift(H.Plots{i,j}{2,end}.Color,[1 1]);
                        H.Plots{i,j}{3,end} = copyobj(MIAFitMeta.Plots{File,6},H.Res{i,j});   
                        H.Plots{i,j}{3,end}.Color = circshift(H.Plots{i,j}{3,end}.Color,[1 1]);
                        
                        %%% Sets axes label and limits
                        H.Axes{i,j}.XLim = [min([y(1),x(1)]), max([x(end),y(end)])];
                        H.Axes{i,j}.XLabel.String = 'Pixel Lag {\it\xi{}}, {\it\psi{}}';
                        H.Axes{i,j}.YLabel.String = 'G({\it\xi{}},0), G(0,{\it\psi{}})';
                        H.Res{i,j}.XLim = [min([y(1),x(1)]), max([x(end),y(end)])];
                        if h.Fit_Weights.Value
                            H.Res{i,j}.YLabel.String = 'W. Res.';
                        else
                            H.Res{i,j}.YLabel.String = 'Res.';
                        end 
                    case {7,8,9} %%% Image plots
                        %%% Shrinks Axes
                        H.Axes{i,j}.Position(3) = Size;
                        %%% Extracts Data
                        switch Type
                            case 7 %%% Correlation image
                                Data = MIAFitData.Data{File,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))/B;
                                if h.Omit_Center_Line.Value
                                    Data(floor((size(Data,1)+1)/2),:) = (Data(floor((size(Data,1)+1)/2)-1,:)+Data(floor((size(Data,1)+1)/2)+1,:))/2;
                                end
                            case 8 %%% Fit image
                                P=MIAFitMeta.Params(:,File);
                                OUT = feval(MIAFitMeta.Model.Function,P,x,y,i);
                                if h.Omit_Center.Value
                                    OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)) =...
                                        (OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)+1) + ...
                                        OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)-1))/2; %#ok<AGROW>
                                elseif h.Omit_Center_Line.Value
                                    OUT(floor((size(OUT,1)+1)/2),:) =...
                                        (OUT(floor((size(OUT,1)+1)/2-1),:) + ...
                                        OUT(floor((size(OUT,1)+1)/2)+1,:))/2;
                                end
                                Data = real(OUT)/B;
                            case 9 %%% Residuals image
                                P=MIAFitMeta.Params(:,File);
                                OUT = feval(MIAFitMeta.Model.Function,P,x,y,i);
                                Out = real(OUT)/B;
                                if h.Omit_Center.Value
                                    OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)) =...
                                        (OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)+1) + ...
                                        OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)-1))/2;
                                elseif h.Omit_Center_Line.Value
                                    OUT(floor((size(OUT,1)+1)/2),:) =...
                                        (OUT(floor((size(OUT,1)+1)/2-1),:) + ...
                                        OUT(floor((size(OUT,1)+1)/2)+1,:))/2;
                                end
                                Data = MIAFitData.Data{File,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))/B;
                                Weights = MIAFitData.Data{File,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))/B;
                                if h.Omit_Center_Line.Value
                                    Data(floor((size(Data,1)+1)/2),:) = (Data(floor((size(Data,1)+1)/2)-1,:)+Data(floor((size(Data,1)+1)/2)+1,:))/2;
                                    Weights(floor((size(Weights,1)+1)/2),:) = inf;
                                elseif h.Omit_Center.Value
                                    Data(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)) =...
                                        (Data(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)+1) + ...
                                         Data(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)-1))/2;
                                    Weights(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)) =inf;
                                end
                                if h.Fit_Weights.Value
                                    Data = ((Data-Out)./Weights)^2;
                                else
                                    Data = (Data-Out)^2;
                                end                                   
                        end
                        
                        H.Plot{i,j}=imagesc(...
                            'Parent',H.Axes{i,j},...
                            'XData',x(1,:),...
                            'YData',y(:,1),...
                            'CData',Data);
                        H.Axes{i,j}.XLim = [x(1)-0.5 x(end)+0.5];
                        H.Axes{i,j}.YLim = [y(1)-0.5 x(end)+0.5];       
                        
                        %%% Sets axes label and limits
                        H.Axes{i,j}.XLim = [x(1) x(end)];
                        H.Axes{i,j}.YLim = [y(1) y(end)];
                        H.Axes{i,j}.XLabel.String = 'Pixel Lag {\it\xi{}}';
                        H.Axes{i,j}.YLabel.String = 'Pixel Lag {\it\psi{}}';
                        
                        colormap (H.Axes{i,j},jet);
                        H.Colorbar{i,j} = colorbar(...
                            'peer',H.Axes{i,j},...
                            'FontSize',FontSize,...
                            'Units','points',...
                            'Position', [H.Axes{i,j}.Position(1)+Size+5 H.Axes{i,j}.Position(2) 10 H.Axes{i,j}.Position(3)],...
                            'Location','eastoutside');
                        if Type == 9
                            if h.Fit_Weights.Value
                                H.Colorbar{i,j}.Label.String = 'W. Res';
                            else
                                H.Colorbar{i,j}.Label.String = 'Residuals';
                            end
                        else
                            H.Colorbar{i,j}.Label.String = 'G({\it\xi{}},{\it\psi{}})';
                        end
                    case {10,11,12} %%% Correlation surf
                        %%% Resize Axes
                        H.Axes{i,j}.Position(2) = H.Axes{i,j}.Position(2)-2*FontSize;
                        H.Axes{i,j}.Position(4) = H.Axes{i,j}.Position(4)+3.5*FontSize;
                        %%% Extracts Data
                        switch Type
                            case 10 %%% Correlation surf
                                Data = MIAFitData.Data{File,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))/B;
                                if h.Omit_Center_Line.Value
                                    Data(floor((size(Data,1)+1)/2),:) = (Data(floor((size(Data,1)+1)/2)-1,:)+Data(floor((size(Data,1)+1)/2)+1,:))/2;
                                end
                            case 11 %%% Fit surf
                                P=MIAFitMeta.Params(:,File);
                                OUT = feval(MIAFitMeta.Model.Function,P,x,y,i);
                                if h.Omit_Center.Value
                                    OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)) =...
                                        (OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)+1) + ...
                                        OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)-1))/2; %#ok<AGROW>
                                elseif h.Omit_Center_Line.Value
                                    OUT(floor((size(OUT,1)+1)/2),:) =...
                                        (OUT(floor((size(OUT,1)+1)/2-1),:) + ...
                                        OUT(floor((size(OUT,1)+1)/2)+1,:))/2;
                                end
                                Data = real(OUT)/B;
                            case 12 %%% Residuals surf
                                P=MIAFitMeta.Params(:,File); %#ok<NASGU>
                                OUT = feval(MIAFitMeta.Model.Function,P,x,y,i);
                                Out = real(OUT)/B;
                                if h.Omit_Center.Value
                                    OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)) =...
                                        (OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)+1) + ...
                                        OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)-1))/2; %#ok<AGROW>
                                elseif h.Omit_Center_Line.Value
                                    OUT(floor((size(OUT,1)+1)/2),:) =...
                                        (OUT(floor((size(OUT,1)+1)/2-1),:) + ...
                                        OUT(floor((size(OUT,1)+1)/2)+1,:))/2;
                                end
                                Data = MIAFitData.Data{File,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))/B;
                                Weights = MIAFitData.Data{File,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))/B;
                                if h.Omit_Center_Line.Value
                                    Data(floor((size(Data,1)+1)/2),:) = (Data(floor((size(Data,1)+1)/2)-1,:)+Data(floor((size(Data,1)+1)/2)+1,:))/2;
                                    Weights(floor((size(Weights,1)+1)/2),:) = inf;
                                elseif h.Omit_Center.Value
                                    Data(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)) =...
                                        (Data(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)+1) + ...
                                        Data(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)-1))/2;
                                    Weights(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)) =inf;
                                end
                                if h.Fit_Weights.Value
                                    Data = ((Data-Out)./Weights)^2;
                                else
                                    Data = (Data-Out)^2;
                                end                                   
                        end
                        Data2 = (Data + circshift(Data,[0 -1]) + circshift(Data,[-1 0]) + circshift(Data,[-1 -1]))/4;
                        Data2 = ceil(63*(Data2-min(min(Data2)))/(max(max(Data2))-min(min(Data2)))+1);
                        Color = jet(64);
                        Data2 = Color(Data2(:),:);
                        Data2 = reshape(Data2,[size(x,1),size(x,2),3]);
                        
                        H.Plot{i,j}=surf(...
                            'Parent',H.Axes{i,j},...
                            'FaceColor','Flat',...
                            'XData',x(1,:),...
                            'YData',y(:,1),...
                            'ZData',Data,...
                            'CData',Data2,...
                            'FaceAlpha', Alpha);
                        H.Axes{i,j}.XLim = [x(1) x(end)];
                        H.Axes{i,j}.YLim = [y(1) x(end)]; 
                        H.Axes{i,j}.View = View; %[45 25];
                        ZScale = max(max(Data)) - min(min(Data));
                        H.Axes{i,j}.ZLim = [min(min(Data))-0.1*ZScale max(max(Data))+0.1*ZScale+0.00000001]; 
                        H.Axes{i,j}.XLabel.String = '{\it\xi{}}';    
                        H.Axes{i,j}.XLabel.Units = 'Points';
                        H.Axes{i,j}.XLabel.Position(2) = H.Axes{i,j}.XLabel.Position(2)+0.07*Size;
                        H.Axes{i,j}.YLabel.String = '{\it\psi{}}';
                        H.Axes{i,j}.YLabel.Units = 'Points';
                        H.Axes{i,j}.YLabel.Position(2) = H.Axes{i,j}.YLabel.Position(2)+0.07*Size;
                        H.Axes{i,j}.ZLabel.String = 'G({\it\xi{}},{\it\psi{}})';
                    case 13 %%% Correlation + Residuals    
                        %%% Resize Axes
                        H.Axes{i,j}.Position(2) = H.Axes{i,j}.Position(2)-2*FontSize;
                        H.Axes{i,j}.Position(4) = H.Axes{i,j}.Position(4)+3.5*FontSize;
                        %%% Extract Data
                        Data = MIAFitData.Data{File,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))/B;
                        Error = MIAFitData.Data{File,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))/B;
                        if h.Omit_Center_Line.Value
                            Data(floor((size(Data,1)+1)/2),:) = (Data(floor((size(Data,1)+1)/2)-1,:)+Data(floor((size(Data,1)+1)/2)+1,:))/2;
                            Error(floor((size(Error,1)+1)/2),:) = inf;
                        elseif h.Omit_Center.Value
                            Data(floor((size(Data,1)+1)/2),floor((size(Data,2)+1)/2)) =...
                                (Data(floor((size(Data,1)+1)/2),floor((size(Data,2)+1)/2)+1) + ...
                                 Data(floor((size(Data,1)+1)/2),floor((size(Data,2)+1)/2)-1))/2;
                            Error(floor((size(Error,1)+1)/2),floor((size(Error,2)+1)/2)) =inf;
                        end
                                               
                        P=MIAFitMeta.Params(:,File);
                        OUT = feval(MIAFitMeta.Model.Function,P,x,y,i);
                        if h.Omit_Center.Value
                            OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)) =...
                                (OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)+1) + ...
                                OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)-1))/2;
                        elseif h.Omit_Center_Line.Value
                            OUT(floor((size(OUT,1)+1)/2),:) =...
                                (OUT(floor((size(OUT,1)+1)/2-1),:) + ...
                                OUT(floor((size(OUT,1)+1)/2)+1,:))/2;
                        end                        
                        Data2 = ((Data-OUT/B)./Error);
                        Data2 = (Data2 + circshift(Data2,[0 -1]) + circshift(Data2,[-1 0]) + circshift(Data2,[-1 -1]))/4;
                        ErrorLim = str2double(h.Export_ErrorLim.String);
                        Data2 = round(64*(Data2+ErrorLim)/(2*ErrorLim));
                        Data2(Data2<1) = 1; Data2(Data2>64) = 64;
                        Color=zeros(64,3);
                        Color(:,1)=[linspace(0,0.8,32), repmat(0.8,[1,32])];
                        Color(:,2)=[linspace(0,0.8,32), linspace(0.8,0,32)];
                        Color(:,3)=[repmat(0.8,[1,32]), linspace(0.8,0,32)];
                        Data2 = Color(Data2(:),:);
                        Data2 = reshape(Data2,[size(x,1),size(x,2),3]);
                        H.Plot{i,j}=surf(...
                            'Parent',H.Axes{i,j},...
                            'FaceColor','Flat',...
                            'XData',x(1,:),...
                            'YData',y(:,1),...
                            'ZData',OUT,...
                            'CData',Data2,...
                            'FaceAlpha', Alpha);
                        colormap(H.Axes{i,j},Color);
                        H.Colorbar{i,j} = colorbar(...
                            'peer',H.Axes{i,j},...
                            'FontSize',FontSize,...
                            'Units','points',...
                            'YTick', [-ErrorLim ErrorLim],...
                            'Position', [H.Axes{i,j}.Position(1)+Size+2*FontSize, H.Axes{i,j}.Position(2)+Size*0.65 10 H.Axes{i,j}.Position(3)/3],...
                            'Location','eastoutside');                        
                        H.Axes{i,j}.XLim = [x(1) x(end)];
                        H.Axes{i,j}.YLim = [y(1) x(end)]; 
                        H.Axes{i,j}.CLim = [-ErrorLim ErrorLim];
                        H.Axes{i,j}.View = View;
                        ZScale = max(max(Data)) - min(min(Data));
                        H.Axes{i,j}.ZLim = [min(min(Data))-0.1*ZScale max(max(Data))+0.1*ZScale+0.00000001]; 
                        H.Axes{i,j}.XLabel.String = '{\it\xi{}}';    
                        H.Axes{i,j}.XLabel.Units = 'Points';
                        H.Axes{i,j}.XLabel.Position(2) = H.Axes{i,j}.XLabel.Position(2)+0.07*Size;
                        H.Axes{i,j}.YLabel.String = '{\it\psi{}}';
                        H.Axes{i,j}.YLabel.Units = 'Points';
                        H.Axes{i,j}.YLabel.Position(2) = H.Axes{i,j}.YLabel.Position(2)+0.07*Size;
                        H.Axes{i,j}.ZLabel.String = 'G({\it\xi{}},{\it\psi{}})';
                        
                        H.Colorbar{i,j}.Label.String = 'W.Res.';
                        H.Colorbar{i,j}.Label.Units = 'points';
                        H.Colorbar{i,j}.Label.Position(1) = H.Colorbar{i,j}.Label.Position(1)-FontSize;
                        
                end           
            end            
        end
    case 2
    case 3 %%% Change number of plots
       if Obj == h.Export_NumX
           NumX = str2double(h.Export_NumX.String);
           if size(h.Export_Table.Data,2)>2*NumX
               h.Export_Table.Data = h.Export_Table.Data(:,1:2*NumX);
               h.Export_Table.ColumnFormat = h.Export_Table.ColumnFormat(1:2*NumX);
               h.Export_Table.ColumnName = h.Export_Table.ColumnName(1:2*NumX);
               h.Export_Table.ColumnWidth = h.Export_Table.ColumnWidth(1:2*NumX);
           elseif size(h.Export_Table.Data,2)<2*NumX
               while size(h.Export_Table.Data,2)<2*NumX
                   h.Export_Table.Data(:,(end+1:end+2))=h.Export_Table.Data(:,(end-1:end));
                   h.Export_Table.ColumnFormat((end+1:end+2))= h.Export_Table.ColumnFormat((end-1:end));
                   h.Export_Table.ColumnName((end+1:end+2))= {num2str(size(h.Export_Table.Data,2)/2)};
                   h.Export_Table.ColumnWidth((end+1:end+2))= h.Export_Table.ColumnWidth((end-1:end));
               end
           end
       elseif Obj == h.Export_NumY
           NumY = str2double(h.Export_NumY.String);
           if size(h.Export_Table.Data,1)>NumY
               h.Export_Table.Data = h.Export_Table.Data(1:NumY,:);
           elseif size(h.Export_Table.Data,1)<NumY
               while size(h.Export_Table.Data,1)<NumY
                 h.Export_Table.Data(end+1,:)=h.Export_Table.Data(end,:);
               end
           end
       end
    case 4 %%% Exports Fit Result to Clipboard
        FitResult = cell(numel(MIAFitData.FileName),1);
        for i = 1:numel(MIAFitData.FileName)
            FitResult{i} = cell(size(MIAFitMeta.Params,1)+2,1);
            FitResult{i}{1} = MIAFitData.FileName{i};
            FitResult{i}{2} = str2double(h.Fit_Table.Data{i,end});
            for j = 3:(size(MIAFitMeta.Params,1)+2)
                FitResult{i}{j} = MIAFitMeta.Params(j-2,i);
            end
        end
        [~,ModelName,~] = fileparts(MIAFitMeta.Model.Name);
        Params = vertcat({ModelName;'Chi2'},MIAFitMeta.Model.Params);
%         if h.Conf_Interval.Value
%             for i = 1:numel(MIAFitData.FileName)
%                 FitResult{i} = horzcat(FitResult{i},vertcat({'lower','upper';'',''},num2cell(MIAFitMeta.Confidence_Intervals{i})));
%             end
%         end
        FitResult = horzcat(Params,horzcat(FitResult{:}));
        Mat2clip(FitResult);
    case 5 %%% Updata view display
        h.Full_Rot.String = num2str(h.Full_Main_Axes.View);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that updates plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(obj,~)
h = guidata(findobj('Tag','MIAFit'));
global MIAFitMeta MIAFitData UserValues

X = str2double(h.Fit_X.String);
Y = str2double(h.Fit_Y.String);
[x,y] = meshgrid(1:X,1:Y);
x = x - ceil(max(max(x))/2);
y = y - ceil(max(max(y))/2);
Plot_Errorbars = h.Fit_Errorbars.Value;
Normalization_Method = h.Normalize.Value;

%%% take care that only either omit center OR omit center line is checked
if ~isempty(obj)
    if obj == h.Omit_Center
        if h.Omit_Center.Value == 1
            h.Omit_Center_Line.Value = 0;
        end
    elseif obj == h.Omit_Center_Line
        if h.Omit_Center_Line.Value == 1
            h.Omit_Center.Value = 0;
        end
    end
end
%%% store in UserValues
UserValues.MIAFit.Fit_X = str2double(h.Fit_X.String);
UserValues.MIAFit.Fit_Y = str2double(h.Fit_Y.String);
UserValues.MIAFit.Plot_Errorbars = Plot_Errorbars;
UserValues.MIAFit.NormalizationMethod = Normalization_Method;
UserValues.MIAFit.Omit = h.Omit_Center.Value;
UserValues.MIAFit.Omit_Center_Line = h.Omit_Center_Line.Value;
UserValues.MIAFit.Hide_Legend = h.Hide_Legend.Value;
LSUserValues(1);

Active = cell2mat(h.Fit_Table.Data(1:end-3,1));

if all(~Active) %% Clears 2D plot, if all are inactive    
    h.Plots.Main.ZData = zeros(2);
    h.Plots.Main.CData = zeros(2,2,3);
    h.Plots.Fit.ZData = zeros(2);
    h.Plots.Fit.CData = zeros(2,2,3);  
    h.Plot2D.String = {'Nothing selected'};
else %% Updates 2D plot selection string
   h.Plot2D.String = MIAFitData.FileName(Active);
   if h.Plot2D.Value>numel(h.Plot2D.String)
       h.Plot2D.Value = 1;
   end
end
%%% Does the plotting and the calculations
for i=1:size(MIAFitMeta.Plots,1)
    if Active(i)
        Center = ceil((size(MIAFitData.Data{i,1})+1)/2);
        %% Calculates normalization parameter B
        h.Norm_X.Visible='off';
        h.Norm_Y.Visible='off';
        switch Normalization_Method
            case 1 %% No normalization
                B =1 ;
            case 2 %% Normalizes to number of particles 3D (defined in model)
                P = MIAFitMeta.Params(:,i); %#ok<NASGU>
                eval(MIAFitMeta.Model.Brightness);
                B = B/sqrt(8);
                if isnan(B) || B==0 || isinf(B)
                    B = 1;
                end
            case 3 %% Normalizes to G(0) of the fit
                P = MIAFitMeta.Params(:,i); x = 0; y = 0;
                B = feval(MIAFitMeta.Model.Function,P,x,y,i);
                if isnan(B) || B==0 || isinf(B)
                    B = 1;
                end
                x = str2double(h.Fit_X.String);
                %%% Has to reset x and y parameters again;
                y = str2double(h.Fit_Y.String);
                [x,y] = meshgrid(1:x,1:y);
                x = x - ceil(max(max(x))/2);
                y = y - ceil(max(max(y))/2);
            case 4 %% Normalizes to number of particles 2D (defined in model)
                P = MIAFitMeta.Params(:,i); %#ok<NASGU>
                eval(MIAFitMeta.Model.Brightness);
                B = B/sqrt(4);
                if isnan(B) || B==0 || isinf(B)
                    B = 1;
                end
            case 5 %% Normalizes to selected pixel
                h.Norm_X.Visible='on';
                h.Norm_Y.Visible='on';
                B = MIAFitData.Data{i,1}(Center(1)+(str2double(h.Norm_Y.String)), Center(2)+(str2double(h.Norm_X.String)));
        end      
        %% Updates on axis data plot y values 
        MIAFitMeta.Plots{i,1}.XData = x(1,:);    
        MIAFitMeta.Plots{i,1}.YData = MIAFitData.Data{i,1}(Center(1), Center(2)+x(1,:))/B;         
        MIAFitMeta.Plots{i,4}.XData = y(:,1);
        MIAFitMeta.Plots{i,4}.YData = MIAFitData.Data{i,1}(Center(1)+y(:,1), Center(2))/B;  
        if h.Omit_Center.Value
            MIAFitMeta.Plots{i,1}.YData(floor((X+1)/2)) = (MIAFitMeta.Plots{i,1}.YData(floor((X+1)/2)-1)+MIAFitMeta.Plots{i,1}.YData(floor((X+1)/2)+1))/2;  
            MIAFitMeta.Plots{i,4}.YData(floor((Y+1)/2)) = (MIAFitMeta.Plots{i,4}.YData(floor((Y+1)/2)-1)+MIAFitMeta.Plots{i,4}.YData(floor((Y+1)/2)+1))/2;  
        elseif h.Omit_Center_Line.Value
            MIAFitMeta.Plots{i,1}.YData = (MIAFitData.Data{i,1}(Center(1)-1, Center(2)+x(1,:))+MIAFitData.Data{i,1}(Center(1)+1, Center(2)+x(1,:)))/B/2;
            MIAFitMeta.Plots{i,4}.YData(floor((Y+1)/2)) = (MIAFitMeta.Plots{i,4}.YData(floor((Y+1)/2)-1)+MIAFitMeta.Plots{i,4}.YData(floor((Y+1)/2)+1))/2;  
        end
        %% Updates data errorbars/ turns them off
        if Plot_Errorbars
            MIAFitMeta.Plots{i,1}.LData = MIAFitData.Data{i,2}(Center(1), Center(2)+x(1,:))/B;   
            MIAFitMeta.Plots{i,1}.UData = MIAFitData.Data{i,2}(Center(1), Center(2)+x(1,:))/B;   
            MIAFitMeta.Plots{i,4}.LData = MIAFitData.Data{i,2}(Center(1)+y(:,1), Center(2))/B; 
            MIAFitMeta.Plots{i,4}.UData = MIAFitData.Data{i,2}(Center(1)+y(:,1), Center(2))/B; 
        else
            MIAFitMeta.Plots{i,1}.LData=0;
            MIAFitMeta.Plots{i,1}.UData=0;
            MIAFitMeta.Plots{i,4}.LData=0;
            MIAFitMeta.Plots{i,4}.UData=0;
        end
        %% Calculates fit y data and updates fit plot
        P=MIAFitMeta.Params(:,i);
        OUT = feval(MIAFitMeta.Model.Function,P,x,y,i);
        OUT=real(OUT);
        if h.Omit_Center.Value
           OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)) =...
               (OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)+1) + ...
               OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,2)+1)/2)-1))/2; 
        elseif h.Omit_Center_Line.Value
           OUT(floor((size(OUT,1)+1)/2),:) =...
               (OUT(floor((size(OUT,1)+1)/2)-1,:) + ...
               OUT(floor((size(OUT,1)+1)/2)+1,:))/2; 
        end
        MIAFitMeta.Plots{i,2}.XData=x(1,:);        
        MIAFitMeta.Plots{i,2}.YData=OUT(1-min(min(y)),:)/B;     
        MIAFitMeta.Plots{i,5}.XData=y(:,1);
        MIAFitMeta.Plots{i,5}.YData=OUT(:,1-min(min(x)))/B;
        %% Calculates weighted residuals and plots them
        if h.Fit_Weights.Value
            ResidualsX = (MIAFitMeta.Plots{i,1}.YData-MIAFitMeta.Plots{i,2}.YData)./MIAFitData.Data{i,2}(Center(1), Center(2)+x(1,:))/B;   
            ResidualsY = (MIAFitMeta.Plots{i,4}.YData-MIAFitMeta.Plots{i,5}.YData)./MIAFitData.Data{i,2}(Center(1)+y(:,1), Center(2))'/B;
            if h.Omit_Center.Value
                ResidualsX((floor((X+1)/2))) = 0;
                ResidualsY((floor((Y+1)/2))) = 0;
                Chisqr = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))) - OUT;
                Chisqr((floor((Y+1)/2)),(floor((X+1)/2))) = 0;
                Chisqr = sum(sum((Chisqr./MIAFitData.Data{i,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))).^2));
            elseif h.Omit_Center_Line.Value
                ResidualsX((floor((X+1)/2))) = 0;
                ResidualsY((floor((Y+1)/2))) = 0;
                Chisqr = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))) - OUT;
                Chisqr((floor((Y+1)/2)),:) = 0;
                Chisqr = sum(sum((Chisqr./MIAFitData.Data{i,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))).^2));
            else
                Chisqr = sum(sum(((MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))) - OUT)...
                    ./MIAFitData.Data{i,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))).^2));
            end
        else
            ResidualsX = (MIAFitMeta.Plots{i,1}.YData-MIAFitMeta.Plots{i,2}.YData)*B;
            ResidualsY = (MIAFitMeta.Plots{i,4}.YData-MIAFitMeta.Plots{i,5}.YData)*B;
            
            if h.Omit_Center.Value
                ResidualsX((floor((X+1)/2))) = 0;
                ResidualsY((floor((Y+1)/2))) = 0;
                Chisqr = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))) - OUT;
                Chisqr((floor((Y+1)/2)),(floor((X+1)/2))) = 0;
                Chisqr = sum(sum(Chisqr));
            elseif h.Omit_Center_Line.Value
                ResidualsX((floor((X+1)/2))) = 0;
                ResidualsY((floor((Y+1)/2))) = 0;
                Chisqr = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))) - OUT;
                Chisqr((floor((Y+1)/2)),:) = 0;
                Chisqr = sum(sum(Chisqr));
            else
                Chisqr = sum(sum((MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))-OUT).^2));
            end
        end
        ResidualsX(ResidualsX==inf | isnan(ResidualsX)) = 0;
        ResidualsY(ResidualsY==inf | isnan(ResidualsY)) = 0;
        MIAFitMeta.Plots{i,3}.XData=x(1,:); 
        MIAFitMeta.Plots{i,3}.YData=ResidualsX; 
        MIAFitMeta.Plots{i,6}.XData=y(:,1); 
        MIAFitMeta.Plots{i,6}.YData=ResidualsY;      
        %% Calculates Chi^2 and updates table
        h.Fit_Table.CellEditCallback = [];
        if h.Omit_Center.Value
            Chisqr = Chisqr/(numel(x)-2-sum(~cell2mat(h.Fit_Table.Data(i,5:3:end-1))));
        elseif h.Omit_Center_Line.Value
            Chisqr = Chisqr/(numel(x)-1-X-sum(~cell2mat(h.Fit_Table.Data(i,5:3:end-1))));
        else
            Chisqr = Chisqr/(numel(x)-1-sum(~cell2mat(h.Fit_Table.Data(i,5:3:end-1))));
        end
        h.Fit_Table.Data{i,end}=num2str(Chisqr);
        h.Fit_Table.CellEditCallback={@Update_Table,3};
        %% Makes plot visible, if it is active
        MIAFitMeta.Plots{i,1}.Visible='on';
        MIAFitMeta.Plots{i,2}.Visible='on';
        MIAFitMeta.Plots{i,3}.Visible='on';
        MIAFitMeta.Plots{i,4}.Visible='on';
        MIAFitMeta.Plots{i,5}.Visible='on';
        MIAFitMeta.Plots{i,6}.Visible='on';        
        %% Updates 2D plot
        if i == h.Plot2D.Value
            Color = jet(64);
            %% Plots main 2D plot surface
            h.Plots.Main.XData = x(1,:);
            h.Plots.Main.YData = y(:,1);
            ZData = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))./B;
            if h.Omit_Center_Line.Value
                ZData(floor((size(ZData,1)+1)/2),:) = (ZData(floor((size(ZData,1)+1)/2)-1,:)+ZData(floor((size(ZData,1)+1)/2)+1,:))/2;
            end
            h.Plots.Main.ZData = ZData;
            %%% Calculates color for main plot faces            
            Data = ZData;
            Data = (Data + circshift(Data,[0 -1]) + circshift(Data,[-1 0]) + circshift(Data,[-1 -1]))/4;
            Data = ceil(63*(Data-min(min(Data)))/(max(max(Data))-min(min(Data)))+1);
            Data(isnan(Data))=1;
            Data = Color(Data(:),:);
            Data = reshape(Data,[size(x,1),size(x,2),3]);
            h.Plots.Main.CData = Data;
            %%% Rescales plot
            Range = [min(min(h.Plots.Main.ZData)), max(max(h.Plots.Main.ZData))+1e-30];
            h.Full_Main_Axes.XLim = [min(min(x)) max(max(x))+1e-30];
            h.Full_Main_Axes.YLim = [min(min(y)) max(max(y))+1e-30];
            h.Full_Main_Axes.ZLim = [Range(1)-0.1*diff(Range), Range(2)+0.1*diff(Range)];
            h.Full_Main_Axes.DataAspectRatio = [1 1 1.5*diff(Range)/max(size(x))];            
            %% Plots fit 2D plot surface
            switch h.Plot2DStyle.Value
                case 1 %%% Plots fit
                    addprop(h.Full_Link,'DataAspectRatio');
                    addprop(h.Full_Link,'ZLim');
                    Data = OUT./B;
                    h.Plots.Fit.XData = x(1,:);
                    h.Plots.Fit.YData = y(:,1);
                    h.Plots.Fit.ZData = Data;
                    %%% Calculates color for fit plot faces
                    Data = (Data + circshift(Data,[0 -1]) + circshift(Data,[-1 0]) + circshift(Data,[-1 -1]))/4;
                    Data = ceil(63*(Data-min(min(Data)))/(max(max(Data))-min(min(Data)))+1);
                    Data = Color(Data(:),:);
                    Data = reshape(Data,[size(x,1),size(x,2),3]);
                    h.Plots.Fit.CData = Data;
                case 2 %%% Plots residuals
                    removeprop(h.Full_Link,'DataAspectRatio');
                    removeprop(h.Full_Link,'ZLim');
                    Data = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))) - OUT;
                    if h.Omit_Center.Value
                        Data((floor((Y+1)/2)),(floor((X+1)/2))) = 0;
                    elseif h.Omit_Center_Line.Value
                        Data(floor((Y+1)/2),:) = 0;
                    end
                    if h.Fit_Weights.Value
                       Data = (Data./MIAFitData.Data{i,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))));                    
                    end
                    Data(Data==inf | isnan(Data)) = 0;
                    h.Plots.Fit.XData = x(1,:);
                    h.Plots.Fit.YData = y(:,1);
                    h.Plots.Fit.ZData = Data;
                    %%% Calculates color for fit plot faces
                    Data = (Data + circshift(Data,[0 -1]) + circshift(Data,[-1 0]) + circshift(Data,[-1 -1]))/4;
                    Data = ceil(63*(Data-min(min(Data)))/(max(max(Data))-min(min(Data)))+1);
                    Data = Color(Data(:),:);
                    Data = reshape(Data,[size(x,1),size(x,2),3]);
                    h.Plots.Fit.CData = Data; 
                    %%% Rescales residuals plot
                    Range = [min(min(h.Plots.Fit.ZData)), max(max(h.Plots.Fit.ZData))];
                    h.Full_Fit_Axes.ZLim = [Range(1)-0.1*diff(Range), Range(2)+0.1*diff(Range)];
                    h.Full_Fit_Axes.DataAspectRatio = [1 1 1.5*diff(Range)/max(size(x))];
                case 3 %%% Plots fit with residuals in blue (neg) and red (pos)
                    addprop(h.Full_Link,'ZLim');
                    addprop(h.Full_Link,'DataAspectRatio');
                    Color=zeros(64,3);
                    Color(:,1)=[linspace(0,0.8,32), repmat(0.8,[1,32])];
                    Color(:,2)=[linspace(0,0.8,32), linspace(0.8,0,32)];
                    Color(:,3)=[repmat(0.8,[1,32]), linspace(0.8,0,32)];
                    Data = OUT./B;
                    h.Plots.Fit.XData = x(1,:);
                    h.Plots.Fit.YData = y(:,1);
                    h.Plots.Fit.ZData = Data;
                    %%% Calculates color for fit plot faces
                    Data = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))) - OUT;
                    if h.Omit_Center.Value
                        Data((floor((Y+1)/2)),(floor((X+1)/2))) = 0;
                    elseif h.Omit_Center_Line.Value
                        Data((floor((Y+1)/2)),:) = 0;
                    end
                    if h.Fit_Weights.Value
                       Data = (Data./MIAFitData.Data{i,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))))^2;                    
                    else
                       Data = Data^2;
                    end
                    Data = (Data + circshift(Data,[0 -1]) + circshift(Data,[-1 0]) + circshift(Data,[-1 -1]))/4;
                    Data = ceil(63*(Data-min(min(Data)))/(max(max(Data))-min(min(Data)))+1);
                    Data = Color(Data(:),:);
                    Data = reshape(Data,[size(x,1),size(x,2),3]);
                    h.Plots.Fit.CData = Data;
            end                    
        end        
    else
        %% Hides plots
        MIAFitMeta.Plots{i,1}.Visible='off';
        MIAFitMeta.Plots{i,2}.Visible='off';
        MIAFitMeta.Plots{i,3}.Visible='off';
        MIAFitMeta.Plots{i,4}.Visible='off';
        MIAFitMeta.Plots{i,5}.Visible='off';
        MIAFitMeta.Plots{i,6}.Visible='off';
    end
end

%%% Generates figure legend entries
Active=find(Active);
LegendString=cell(numel(Active)*2,1);
LegendUse=h.X_Axes.Children(1:numel(Active)*2);
for i=1:numel(Active)
    LegendString{2*i-1}=['Data: ' MIAFitData.FileName{Active(i)}];
    LegendString{2*i}  =['Fit:  ' MIAFitData.FileName{Active(i)}];
    LegendUse(2*i-1)=MIAFitMeta.Plots{Active(i),1};
    LegendUse(2*i)=MIAFitMeta.Plots{Active(i),2};
end
if ~isempty(LegendString) && h.Hide_Legend.Value == 0
    %% Active legend    
    h.MIAFit_Legend(1)=legend(h.X_Axes,LegendUse,LegendString,'Interpreter','none');
    h.MIAFit_Legend(2)=legend(h.Y_Axes,LegendUse,LegendString,'Interpreter','none');
    guidata(h.MIAFit,h);
else
    %% Hides legend for empty plot
    h.MIAFit_Legend(1).Visible='off';
    h.MIAFit_Legend(2).Visible='off';
end
drawnow;

%%% Updates axes limits
h.X_Axes.XLim = [min(min(x)), max(max(x))]; h.X_Axes.YLimMode ='Auto';
h.Y_Axes.XLim = [min(min(y)), max(max(y))]; h.Y_Axes.YLimMode ='Auto';
h.XRes_Axes.XLim = [min(min(x)), max(max(x))]; h.XRes_Axes.YLimMode ='Auto';
h.YRes_Axes.XLim = [min(min(y)), max(max(y))]; h.YRes_Axes.YLimMode ='Auto';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that updates fit table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Table(~,e,mode)
h = guidata(findobj('Tag','MIAFit'));
global MIAFitData MIAFitMeta

switch mode
    case 0 %% Updates whole table (Load Fit etc.)
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        %%% Generates column names and resized them
        Columns=cell(3*numel(MIAFitMeta.Model.Params)+4,1);
        Columns{1}='Active';
        Columns{2}='<HTML><b> Counts [khz] </b>';
        Columns{3}='<HTML><b> Brightness [khz]</b>';
        for i=1:numel(MIAFitMeta.Model.Params)
            Columns{3*i+1}=['<HTML><b>' MIAFitMeta.Model.Params{i} '</b>'];
            Columns{3*i+2}='F';
            Columns{3*i+3}='G';
        end
        Columns{end}='Chi?';
        ColumnWidth=zeros(numel(Columns),1);
        ColumnWidth(4:3:end-1) = 80;
        ColumnWidth(5:3:end-1)=20;
        ColumnWidth(6:3:end-1)=20;
        ColumnWidth(1)=40;
        ColumnWidth(2)=80;
        ColumnWidth(3)=100;
        ColumnWidth(end)=40;
        h.Fit_Table.ColumnName=Columns;
        h.Fit_Table.ColumnWidth=num2cell(ColumnWidth');
        %%% Sets row names to file names
        Rows=cell(size(MIAFitData.Data,1)+3,1);
        Rows(1:size(MIAFitData.Data,1))=deal(MIAFitData.FileName);
        Rows{end-2}='ALL';
        Rows{end-1}='Lower bound';
        Rows{end}='Upper bound';
        h.Fit_Table.RowName=Rows;
        %%% Creates table data:
        %%% 1: Checkbox to activate/deactivate files
        %%% 2: Countrate of file
        %%% 3: Brightness if file
        %%% 4:3:end: Parameter value
        %%% 5:3:end: Checkbox to fix parameter
        %%% 6:3:end: Checkbox to fit parameter globaly
        Data=num2cell(zeros(numel(Rows),numel(Columns)));
        for i=1:(numel(Rows)-3)
            Data{i,2}=mean(MIAFitData.Counts{i});
        end
        Data(1:end-3,4:3:end-1)=deal(num2cell(MIAFitMeta.Params)');
        Data(end-2,4:3:end-1)=deal(num2cell(MIAFitMeta.Model.Value)');
        Data(end-1,4:3:end-1)=deal(num2cell(MIAFitMeta.Model.LowerBoundaries)');
        Data(end,4:3:end-1)=deal(num2cell(MIAFitMeta.Model.UpperBoundaries)');
        Data=cellfun(@num2str,Data,'UniformOutput',false);
        Data(:,1)=deal({true});
%         Data(:,5:3:end-1)=deal({false});
%         Data(:,6:3:end-1)=deal({false});
        Data(:,5:3:end-1) = repmat(num2cell(MIAFitMeta.Model.State==1)',size(Data,1),1);
        Data(:,6:3:end-1) = repmat(num2cell(MIAFitMeta.Model.State==2)',size(Data,1),1);
        Data(:,1)=deal({true});
        Data(:,end)=deal({'0'});
        h.Fit_Table.Data=Data;
        h.Fit_Table.ColumnEditable=[true,false,false,true(1,numel(Columns)-4),false];
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 1 %% Updates tables when new data is loaded
        h.Fit_Table.CellEditCallback=[];
        %%% Sets row names to file names
        Rows=cell(size(MIAFitData.Data,1)+3,1);
        Rows(1:size(MIAFitData.Data,1))=deal(MIAFitData.FileName);
        Rows{end-2}='ALL';
        Rows{end-1}='Lower bound';
        Rows{end}='Upper bound';
        h.Fit_Table.RowName=Rows;
        
        Data=cell(numel(Rows),size(h.Fit_Table.Data,2));
        %%% Set last 3 row to ALL, lb and ub
        Data(1:(size(h.Fit_Table.Data,1)-3),:)=h.Fit_Table.Data(1:end-3,:);
        %%% Sets previous files
        Data(end-2:end,:)=h.Fit_Table.Data(end-2:end,:);
        %%% Adds new files
        Data((size(h.Fit_Table.Data,1)-2):(end-3),:)=repmat(h.Fit_Table.Data(end-2,:),[numel(Rows)-(size(h.Fit_Table.Data,1)),1]);
        %%% Calculates countrate
        for i=1:numel(MIAFitData.Counts)
            Data{i,2}=num2str(mean(MIAFitData.Counts{i}));
        end
        h.Fit_Table.Data=Data;
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 2 %% Updates table after fit
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        %%% Updates parameter values in table
        h.Fit_Table.Data(1:end-3,4:3:end-1)=cellfun(@num2str,num2cell(MIAFitMeta.Params)','UniformOutput',false);
        %%% Updates plots
        Update_Plots([],[]);
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 3 %% Individual cells calbacks
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        if strcmp(e.EventName,'CellSelection') %%% No change in Value, only selected
            if isempty(e.Indices) || (e.Indices(2) == size(h.Fit_Table.Data,2))
                return;
            end
            NewData = h.Fit_Table.Data{e.Indices(1),e.Indices(2)};
        end
        if isprop(e,'NewData')
            NewData = e.NewData;
        end
        if e.Indices(1)==size(h.Fit_Table.Data,1)-2
            %% ALL row wase used => Applies to all files
            h.Fit_Table.Data(1:end-2,e.Indices(2))=deal({NewData});
            if mod(e.Indices(2)-4,3)==0 && e.Indices(2)>=4
                %% Value was changed => Apply value to global variables
                MIAFitMeta.Params((e.Indices(2)-1)/3,:)=str2double(NewData);
            elseif mod(e.Indices(2)-5,3)==0 && e.Indices(2)>=6 && NewData==1
                %% Value was fixed => Uncheck global
                h.Fit_Table.Data(1:end-2,e.Indices(2)+1)=deal({false});
            elseif mod(e.Indices(2)-6,3)==0 && e.Indices(2)>=6 && NewData==1
                %% Global was change
                %%% Apply value to all files
                h.Fit_Table.Data(1:end-2,e.Indices(2)-2)=h.Fit_Table.Data(e.Indices(1),e.Indices(2)-2);
                %%% Apply value to global variables
                MIAFitMeta.Params((e.Indices(2)-3)/3,:)=str2double(h.Fit_Table.Data{e.Indices(1),e.Indices(2)-2});
                %%% Unfixes all files to prohibit fixed and global
                h.Fit_Table.Data(:,e.Indices(2)-1)=deal({false});
            end
        elseif mod(e.Indices(2)-6,3)==0 && e.Indices(2)>=6 && e.Indices(1)<size(h.Fit_Table.Data,1)-1
            %% Global was changed => Applies to all files
            h.Fit_Table.Data(1:end-2,e.Indices(2))=deal({NewData});
            if NewData
                %%% Apply value to all files
                h.Fit_Table.Data(1:end-2,e.Indices(2)-2)=h.Fit_Table.Data(e.Indices(1),e.Indices(2)-2);
                %%% Apply value to global variables
                MIAFitMeta.Params((e.Indices(2)-3)/3,:)=str2double(h.Fit_Table.Data{e.Indices(1),e.Indices(2)-2});
                %%% Unfixes all file to prohibit fixed and global
                h.Fit_Table.Data(1:end-2,e.Indices(2)-1)=deal({false});
            end
        elseif mod(e.Indices(2)-5,3)==0 && e.Indices(2)>=5 && e.Indices(1)<size(h.Fit_Table.Data,1)-1
            %% Value was fixed
            %%% Updates ALL row
            if all(cell2mat(h.Fit_Table.Data(1:end-3,e.Indices(2))))
                h.Fit_Table.Data{end-2,e.Indices(2)}=true;
            else
                h.Fit_Table.Data{end-2,e.Indices(2)}=false;
            end
            %%% Unchecks global to prohibit fixed and global
            h.Fit_Table.Data(1:end-2,e.Indices(2)+1)=deal({false;});
        elseif mod(e.Indices(2)-4,3)==0 && e.Indices(2)>=4 && e.Indices(1)<size(h.Fit_Table.Data,1)-1
            %% Value was changed
            if h.Fit_Table.Data{e.Indices(1),e.Indices(2)+2}
                %% Global => changes value of all files
                h.Fit_Table.Data(1:end-2,e.Indices(2))=deal({NewData});
                MIAFitMeta.Params((e.Indices(2)-1)/3,:)=str2double(NewData);
            else
                %% Not global => only changes value
                MIAFitMeta.Params((e.Indices(2)-1)/3,e.Indices(1))=str2double(NewData);
                
            end
        elseif e.Indices(2)==1
            %% Active was changed
        end
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
end

%%% Calculates brightness for all files
for i=1:size(MIAFitMeta.Params,2)
    P=MIAFitMeta.Params(:,i); %#ok<NASGU>
    eval(MIAFitMeta.Model.Brightness);
    h.Fit_Table.Data{i,3}=num2str(mean(MIAFitData.Counts{i})*B);
end

Update_Plots([],[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes plotting style %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Style(~,e,mode) 
global MIAFitMeta MIAFitData UserValues
h = guidata(findobj('Tag','MIAFit'));
switch mode
    case 0 %% Called at the figure initialization
        %%% Generates the table column and cell names
        Columns=cell(9,1);
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
        h.Style_Table.ColumnName=Columns;
        h.Style_Table.RowName={'ALL'};
        
        %%% Generates the initial cell inputs
        h.Style_Table.ColumnEditable=true;
        h.Style_Table.ColumnFormat={'char',{'none','-','-.','--',':'},'char',{'none','.','+','o','*','square','diamond','v','^','<','>'},'char',...
                                           {'none','-','-.','--',':'},'char',{'none','.','+','o','*','square','diamond','v','^','<','>'},'char','logical'};
        h.Style_Table.Data=UserValues.MIAFit.PlotStyleAll;        
    case 1 %% Called, when new file is loaded
        %%% Sets row names to file names 
        Rows=cell(size(MIAFitData.Data,1)+1,1);
        Rows(1:size(MIAFitData.Data,1))=deal(MIAFitData.FileName);
        Rows{end}='ALL';
        h.Style_Table.RowName=Rows;
        Data=cell(numel(Rows),size(h.Style_Table.Data,2));
        %%% Sets ALL style to last row
        Data(end,:)=UserValues.MIAFit.PlotStyleAll;
        %%% Sets previous styles to first rows
        if size(MIAFitData.Data,1) <= size(UserValues.MIAFit.PlotStyles,1)
            Data(1:size(MIAFitData.Data,1),:) = UserValues.MIAFit.PlotStyles(1:size(MIAFitData.Data,1),:);
        else
            Data(1:size(UserValues.MIAFit.PlotStyles,1),:) = UserValues.MIAFit.PlotStyles;
            for i=size(UserValues.MIAFit.PlotStyles,1)+1:size(MIAFitData.Data,1)
               Data(i,:) = UserValues.MIAFit.PlotStyleAll; 
            end
        end
        %%% Updates new plots to style
        for i=1:numel(MIAFitData.FileName)
           MIAFitMeta.Plots{i,1}.Color=num2str(Data{i,1});
           MIAFitMeta.Plots{i,2}.Color=num2str(Data{i,1});
           MIAFitMeta.Plots{i,3}.Color=num2str(Data{i,1});
           MIAFitMeta.Plots{i,4}.Color=num2str(Data{i,1});
           MIAFitMeta.Plots{i,5}.Color=num2str(Data{i,1});
           MIAFitMeta.Plots{i,6}.Color=num2str(Data{i,1});
           MIAFitMeta.Plots{i,1}.LineStyle=Data{i,2};
           MIAFitMeta.Plots{i,4}.LineStyle=Data{i,2};
           MIAFitMeta.Plots{i,1}.LineWidth=str2double(Data{i,3});
           MIAFitMeta.Plots{i,4}.LineWidth=str2double(Data{i,3});
           MIAFitMeta.Plots{i,1}.Marker=Data{i,4};
           MIAFitMeta.Plots{i,4}.Marker=Data{i,4};
           MIAFitMeta.Plots{i,1}.MarkerSize=str2double(Data{i,5});
           MIAFitMeta.Plots{i,4}.MarkerSize=str2double(Data{i,5});
           MIAFitMeta.Plots{i,2}.LineStyle=Data{i,6};
           MIAFitMeta.Plots{i,5}.LineStyle=Data{i,6};
           MIAFitMeta.Plots{i,3}.LineStyle=Data{i,6};
           MIAFitMeta.Plots{i,6}.LineStyle=Data{i,6};
           MIAFitMeta.Plots{i,2}.LineWidth=str2double(Data{i,7});
           MIAFitMeta.Plots{i,5}.LineWidth=str2double(Data{i,7});
           MIAFitMeta.Plots{i,3}.LineWidth=str2double(Data{i,7});
           MIAFitMeta.Plots{i,6}.LineWidth=str2double(Data{i,7});
           MIAFitMeta.Plots{i,2}.Marker=Data{i,8};
           MIAFitMeta.Plots{i,5}.Marker=Data{i,8};
           MIAFitMeta.Plots{i,3}.Marker=Data{i,8};
           MIAFitMeta.Plots{i,6}.Marker=Data{i,8};
           MIAFitMeta.Plots{i,2}.MarkerSize=str2double(Data{i,7});
           MIAFitMeta.Plots{i,5}.MarkerSize=str2double(Data{i,7});
           MIAFitMeta.Plots{i,3}.MarkerSize=str2double(Data{i,7});
           MIAFitMeta.Plots{i,6}.MarkerSize=str2double(Data{i,7});
        end
        h.Style_Table.Data=Data;
    case 2 %% Cell callback
        %%% Applies to all files if ALL row was used
        if e.Indices(1)==size(h.Style_Table.Data,1)
            File=1:(size(h.Style_Table.Data,1)-1);
            h.Style_Table.Data(:,e.Indices(2))=deal({e.NewData});
        else
            File=e.Indices(1);
        end
        switch e.Indices(2)
            case 1 %% Changes file color
                for i = File
                    NewColor = str2num(e.NewData); %#ok<ST2NM>
                    MIAFitMeta.Plots{i,1}.Color=NewColor;
                    MIAFitMeta.Plots{i,2}.Color=NewColor;
                    MIAFitMeta.Plots{i,3}.Color=NewColor;
                    MIAFitMeta.Plots{i,4}.Color=NewColor;
                    MIAFitMeta.Plots{i,5}.Color=NewColor;
                    MIAFitMeta.Plots{i,6}.Color=NewColor;
                end
            case 2 %% Changes data line style
                for i = File
                    MIAFitMeta.Plots{i,1}.LineStyle=e.NewData;
                    MIAFitMeta.Plots{i,4}.LineStyle=e.NewData;
                end
            case 3 %% Changes data line width
                for i=File
                    MIAFitMeta.Plots{i,1}.LineWidth=str2double(e.NewData);
                    MIAFitMeta.Plots{i,4}.LineWidth=str2double(e.NewData);
                end
            case 4 %% Changes data marker style
                for i=File
                    MIAFitMeta.Plots{i,1}.Marker=e.NewData;
                    MIAFitMeta.Plots{i,4}.Marker=e.NewData;
                end
            case 5 %% Changes data marker size
                for i=File
                    MIAFitMeta.Plots{i,1}.MarkerSize=str2double(e.NewData);
                    MIAFitMeta.Plots{i,4}.MarkerSize=str2double(e.NewData);
                end
            case 6 %% Changes fit line style
                for i=File
                    MIAFitMeta.Plots{i,2}.LineStyle=e.NewData;
                    MIAFitMeta.Plots{i,3}.LineStyle=e.NewData;
                    MIAFitMeta.Plots{i,5}.LineStyle=e.NewData;
                    MIAFitMeta.Plots{i,6}.LineStyle=e.NewData;
                end
            case 7 %% Changes fit line width
                for i=File
                    MIAFitMeta.Plots{i,2}.LineWidth=str2double(e.NewData);
                    MIAFitMeta.Plots{i,3}.LineWidth=str2double(e.NewData);
                    MIAFitMeta.Plots{i,5}.LineWidth=str2double(e.NewData);
                    MIAFitMeta.Plots{i,6}.LineWidth=str2double(e.NewData);
                end
            case 8 %% Changes fit marker style
                for i=File
                    MIAFitMeta.Plots{i,2}.Marker=e.NewData;
                    MIAFitMeta.Plots{i,3}.Marker=e.NewData;
                    MIAFitMeta.Plots{i,5}.Marker=e.NewData;
                    MIAFitMeta.Plots{i,6}.Marker=e.NewData;
                end
            case 9 %% Changes fit marker size
                for i=File
                    MIAFitMeta.Plots{i,2}.MarkerSize=str2double(e.NewData);
                    MIAFitMeta.Plots{i,3}.MarkerSize=str2double(e.NewData);
                    MIAFitMeta.Plots{i,5}.MarkerSize=str2double(e.NewData);
                    MIAFitMeta.Plots{i,6}.MarkerSize=str2double(e.NewData);
                end
            case 10 %% Removes files
                File=flip(File,2);
                for i=File
                    MIAFitData.Data(i,:)=[];
                    MIAFitData.FileName(i)=[];
                    MIAFitData.Counts(i)=[];
                    cellfun(@delete,MIAFitMeta.Plots(i,:));
                    MIAFitMeta.Params(:,i)=[];
                    MIAFitMeta.Plots(i,:)=[];
                    h.Fit_Table.RowName(i)=[];
                    h.Fit_Table.Data(i,:)=[];
                    h.Style_Table.RowName(i)=[];
                    h.Style_Table.Data(i,:)=[];
                end
        end
end
%%% Save Updated UiTableData to UserValues.MIAFit.PlotStyles
UserValues.MIAFit.PlotStyles(1:(size(h.Style_Table.Data,1)-1),:) = h.Style_Table.Data(1:(end-1),:);
UserValues.MIAFit.PlotStyleAll = h.Style_Table.Data(end,:);
LSUserValues(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Stops fitting routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Stop_MIAFit(~,~)
global MIAFitMeta
h = guidata(findobj('Tag','MIAFit'));
MIAFitMeta.FitInProgress = 0;
h.Fit_Table.Enable='on';
h.MIAFit.Name='MIA Fit';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Executes fitting routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_MIAFit(~,~)
global MIAFitMeta MIAFitData UserValues
h = guidata(findobj('Tag','MIAFit'));
%%% Indicates fit in progress
h.MIAFit.Name = 'MIA Fit  FITTING';
h.Fit_Table.Enable = 'off';
MIAFitMeta.FitInProgress = 1;
drawnow;
%%% Reads parameters from table
Fixed = cell2mat(h.Fit_Table.Data(1:end-1,5:3:end-1));
Global = cell2mat(h.Fit_Table.Data(end-2,6:3:end-1));
Active = cell2mat(h.Fit_Table.Data(1:end-3,1));
lb = h.Fit_Table.Data(end-1,4:3:end-1);
lb = cellfun(@str2double,lb);
ub = h.Fit_Table.Data(end  ,4:3:end-1);
ub = cellfun(@str2double,ub);
%%% Read fit settings and store in UserValues
MaxIter = str2double(h.Iterations.String);
TolFun = str2double(h.Tolerance.String);
UserValues.MIAFit.Max_Iterations = MaxIter;
UserValues.MIAFit.Fit_Tolerance = TolFun;
Use_Weights = h.Fit_Weights.Value;
UserValues.MIAFit.Use_Weights = Use_Weights;
LSUserValues(1);
%%% Optimization settings
opts=optimset('Display','off','TolFun',TolFun,'MaxIter',MaxIter);

%%% Determines x and y data
x = str2double(h.Fit_X.String);
y = str2double(h.Fit_Y.String);
[x,y] = meshgrid(1:x,1:y);
x = x - ceil(max(max(x))/2);
y = y - ceil(max(max(y))/2);

%%% Performs fit
if sum(Global)==0
    %% Individual fits, not global
    for i = find(Active)';
        %%% Reads in parameters
        Center = ceil((size(MIAFitData.Data{i,1})+1)/2);        
        ZData = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))));
        EData = MIAFitData.Data{i,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))));
        if h.Omit_Center.Value
            Omit = MIAFitData.Data{i,1}(Center(1), Center(2));
        elseif h.Omit_Center_Line.Value
            Omit = MIAFitData.Data{i,1}(Center(1), Center(2)+(min(min(x)):max(max(x))));
        else
            Omit = [];
        end
        %%% Disables weights
        if ~Use_Weights
            EData(:)=1;
        end
        %%% Sets initial values and bounds for non fixed parameters
        Fit_Params=MIAFitMeta.Params(~Fixed(i,:),i);
        Lb=lb(~Fixed(i,:));
        Ub=ub(~Fixed(i,:));        
        %%% Performs fit
        tic;
        [Fitted_Params,~,~,Flag,~,~,~]=lsqcurvefit(@Fit_Single,Fit_Params,{x,y,EData,Omit,i,h},ZData./EData,Lb,Ub,opts);
        toc;
        %%% Updates parameters
        MIAFitMeta.Params(~Fixed(i,:),i)=Fitted_Params;
    end  
else
    %% Global fits
    ZData = []; EData = [];
    X = []; Y = [];
    Points = []; Omit = [];
    %%% Sets initial value and bounds for global parameters
    Fit_Params=MIAFitMeta.Params(Global,1);
    Lb=lb(Global);
    Ub=ub(Global);
    for  i=find(Active)' 
        %%% Reads in parameters of current file   
        Center = ceil((size(MIAFitData.Data{i,1})+1)/2);  
        zdata=MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))));
        edata=MIAFitData.Data{i,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))));
        %%% Disables weights
        if ~Use_Weights
            edata(:)=1;
        end
        ZData = [ZData;zdata(:)];
        EData = [EData;edata(:)];
        X = [X; x(:)];
        Y = [Y; y(:)];
        if h.Omit_Center.Value
            Omit = [Omit; MIAFitData.Data{i,1}(Center(1), Center(2))];
        elseif h.Omit_Center_Line.Value
            Omit = [Omit; MIAFitData.Data{i,1}(Center(1),Center(2)+(min(min(x)):max(max(x))))];
        else
            Omit = [];
        end
        Points(end+1) = numel(x);
        %%% Concaternates initial values and bounds for non fixed parameters
        Fit_Params=[Fit_Params; MIAFitMeta.Params(~Fixed(i,:)& ~Global,i)];
        Lb=[Lb lb(~Fixed(i,:) & ~Global)];
        Ub=[Ub ub(~Fixed(i,:) & ~Global)];
    end
    %%% Performs fit
    [Fitted_Params,~,~,Flag,~,~,~]=lsqcurvefit(@Fit_Global,Fit_Params,{X,Y,EData,Omit,Points,h},ZData./EData,Lb,Ub,opts);
    %%% Updates parameters
    MIAFitMeta.Params(Global,:)=repmat(Fitted_Params(1:sum(Global)),[1 size(MIAFitMeta.Params,2)]) ;
    Fitted_Params(1:sum(Global))=[];
    for i=find(Active)'
        MIAFitMeta.Params(~Fixed(i,:) & ~Global,i)=Fitted_Params(1:sum(~Fixed(i,:) & ~Global)); 
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
h.MIAFit.Name='MIA Fit';
MIAFitMeta.FitInProgress = 0;
%%% Updates table values and plots
Update_Table([],[],2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Actual fitting function for individual fits %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Out] = Fit_Single(Fit_Params,Data)
%%% Fit_Params: Non fixed parameters of current file
%%% Data{1}:    x values of current file
%%% Data{2}:    y values of current file
%%% Data{3}:    Weights of current file
%%% Data{4}:    Indentifier of current file
global MIAFitMeta
%%% Aborts Fit
drawnow;
if ~MIAFitMeta.FitInProgress
    Out = zeros(size(Data{2}));
    return;
end

x = Data{1};
y = Data{2};
Weights = Data{3};
Omit = Data{4};
i = Data{5};
h = Data{6};
Fixed = cell2mat(h.Fit_Table.Data(i,5:3:end-1));

P = zeros(numel(Fixed),1);
%%% Assigns fitting parameters to unfixed parameters of fit
P(~Fixed) = Fit_Params;
%%% Assigns parameters from table to fixed parameters
P(Fixed) = MIAFitMeta.Params(Fixed,i);
%%% Applies function on parameters
OUT = feval(MIAFitMeta.Model.Function,P,x,y,i);
if h.Omit_Center.Value
    OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,1)+1)/2)) = Omit;
elseif h.Omit_Center_Line.Value
    OUT(floor((size(OUT,1)+1)/2),:) = Omit;
end
%%% Applies weights
Out=OUT./Weights;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Actual fitting function for global fits %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Out] = Fit_Global(Fit_Params,Data)
%%% Fit_Params: [Global parameters, Non fixed parameters of all files]
%%% Data{1}:    x values of current file
%%% Data{2}:    y values of current file
%%% Data{3}:    Weights of current file
%%% Data{4}:    Length indentifier for X and Weights data of each file
global MIAFitMeta

%%% Aborts Fit
if ~MIAFitMeta.FitInProgress
    Out = zeros(size(Data{2}));
    return;
end

X=Data{1};
Y=Data{2};
Weights=Data{3};
Omit = Data{4};
Points=Data{5};
h = Data{6};

%%% Determines, which parameters are fixed, global and which files to use
Fixed = cell2mat(h.Fit_Table.Data(1:end-3,5:3:end));
Global = cell2mat(h.Fit_Table.Data(end-2,6:3:end));
Active = cell2mat(h.Fit_Table.Data(1:end-3,1));
P = zeros(numel(Global),1);

%%% Asignes global parameters
P(Global) = Fit_Params(1:sum(Global));
Fit_Params(1:sum(Global)) = [];

Out=[];k=1;
for i=find(Active)'
  %%% Sets non-fixed parameters
  P(~Fixed(i,:) & ~Global) = Fit_Params(1:sum(~Fixed(i,:) & ~Global)); 
  Fit_Params(1:sum(~Fixed(i,:)& ~Global)) = [];  
  %%% Sets fixed parameters
  P(Fixed(i,:) & ~Global) = MIAFitMeta.Params((Fixed(i,:)& ~Global),i);
  %%% Defines XData and YData for the file
  x = X(1:Points(k)); y = Y(1:Points(k));
  X(1:Points(k))=[]; Y(1:Points(k)) = []; 
  %%% Calculates function for current file
  OUT = feval(MIAFitMeta.Model.Function,P,x,y,i);
  if h.Omit_Center.Value
      OUT(x==0 & y==0) = Omit(k);
  elseif h.Omit_Center_Line.Value
      OUT(y==0) = Omit(k,:);
  end
  Out=[Out;OUT]; 
  k=k+1;
end
Out=Out./Weights;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Mat2Clip copies contents of numeric or cell array to clipboard %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mat2clip(a, delim)

%MAT2CLIP  Copies matrix to system clipboard.
%
% MAT2CLIP(A) copies the contents of 2-D matrix A to the system clipboard.
% A can be a numeric array (floats, integers, logicals), character array,
% or a cell array. The cell array can have mixture of data types.
%
% Each element of the matrix will be separated by tabs, and each row will
% be separated by a NEWLINE character. For numeric elements, it tries to
% preserve the current FORMAT. The copied matrix can be pasted into
% spreadsheets.
%
% OUT = MAT2CLIP(A) returns the actual string that was copied to the
% clipboard.
%
% MAT2CLIP(A, DELIM) uses DELIM as the delimiter between columns. The
% default is tab (\t).
%
% Example:
%   format long g
%   a = {'hello', 123;pi, 'bye'}
%   mat2clip(a);
%   % paste into a spreadsheet
%
%   format short
%   data = {
%     'YPL-320', 'Male',   38, true,  uint8(176);
%     'GLI-532', 'Male',   43, false, uint8(163);
%     'PNI-258', 'Female', 38, true,  uint8(131);
%     'MIJ-579', 'Female', 40, false, uint8(133) }
%   mat2clip(data);
%   % paste into a spreadsheet
%
%   mat2clip(data, '|');   % using | as delimiter
%
% See also CLIPBOARD.

% VERSIONS:
%   v1.0 - First version
%   v1.1 - Now works with all numeric data types. Added option to specify
%          delimiter character.
%
% Copyright 2009 The MathWorks, Inc.
%
% Inspired by NUM2CLIP by Grigor Browning (File ID: 8472) Matlab FEX.

narginchk(1, 2);

if ~ismatrix(a)
 error('Mat2clip:Only2D', 'Only 2-D matrices are allowed.');
end

% each element is separated by tabs and each row is separated by a NEWLINE
% character.
sep = {'\t', '\n', ''};

if nargin == 2
    if ischar(delim)
        sep{1} = delim;
    else
        error('Mat2clip:CharacterDelimiter', ...
            'Only character array for delimiters');
    end
end

% try to determine the format of the numeric elements.
switch get(0, 'Format')
    case 'short'
        fmt = {'%s', '%0.5f' , '%d'};
    case 'shortE'
        fmt = {'%s', '%0.5e' , '%d'};
    case 'shortG'
        fmt = {'%s', '%0.5g' , '%d'};
    case 'long'
        fmt = {'%s', '%0.15f', '%d'};
    case 'longE'
        fmt = {'%s', '%0.15e', '%d'};
    case 'longG'
        fmt = {'%s', '%0.15g', '%d'};
    otherwise
        fmt = {'%s', '%0.5f' , '%d'};
end

if iscell(a)  % cell array
   a = a';

   floattypes = cellfun(@isfloat, a);
   inttypes = cellfun(@isinteger, a);
   logicaltypes = cellfun(@islogical, a);
   strtypes = cellfun(@ischar, a);

   classType = zeros(size(a));
   classType(strtypes) = 1;
   classType(floattypes) = 2;
   classType(inttypes) = 3;
   classType(logicaltypes) = 3;
   if any(~classType(:))
     error('mat2clip:InvalidDataTypeInCell', ...
       ['Invalid data type in the cell array. ', ...
       'Only strings and numeric data types are allowed.']);
   end
   sepType = ones(size(a));
   sepType(end, :) = 2; sepType(end) = 3;
   tmp = [fmt(classType(:));sep(sepType(:))];

   b=sprintf(sprintf('%s%s', tmp{:}), a{:});

elseif isfloat(a)  % floating point number
   a = a';

   classType = repmat(2, size(a));
   sepType = ones(size(a));
   sepType(end, :) = 2; sepType(end) = 3;
   tmp = [fmt(classType(:));sep(sepType(:))];

   b=sprintf(sprintf('%s%s', tmp{:}), a(:));

elseif isinteger(a) || islogical(a)  % integer types and logical
   a = a';

   classType = repmat(3, size(a));
   sepType = ones(size(a));
   sepType(end, :) = 2; sepType(end) = 3;
   tmp = [fmt(classType(:));sep(sepType(:))];

   b=sprintf(sprintf('%s%s', tmp{:}), a(:));

elseif ischar(a)  % character array
    % if multiple rows, convert to a single line with line breaks
    if size(a, 1) > 1
        b = cellstr(a);
        b = [sprintf('%s\n', b{1:end-1}), b{end}];
    else
        b = a;
    end
    
else
   error('Mat2clip:InvalidDataType', ...
     ['Invalid data type. ', ...
     'Only cells, strings, and numeric data types are allowed.']);

end

clipboard('copy', b);

if nargout
 out = b;
end



















