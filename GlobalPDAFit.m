function GlobalPDAFit(~,~)
% GlobalPDAFit Global Analysis of PDA data
%
%      This is a beta version!
%
%      To use the program, simply call GlobalPDAFit at command line.
%
%      The PDAData structure contains original experimental data and a
%      number of parameters exported from BurstBrowser (gamma,
%      crosstalk, direct excitation, background, lifetime, anisotropy...).
%
%      Saving PDA project saves the above back into the PDA file.
%      When data is saved in the global PDA program, the fit parameters obtained
%      after fitting are also saved back into the file.
%
%      The h structure contains the user interface.
%
%      The PDAMeta structure contains all metadata generated during program usage
%
%   2015 - FAB Lab Munich - Don C. Lamb

global UserValues PDAMeta PDAData

h.GlobalPDAFit=findobj('Tag','GlobalPDAFit');

LSUserValues(0);
Look=UserValues.Look;

addpath([pwd filesep 'tcPDA C-Code']);

%h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value} = 'Histogram Library'; % {'Histogram Library','MLE','MonteCarlo'}
%h.SettingsTab.FitMethod_Popupmenu.String{h.SettingsTab.FitMethod_Popupmenu.Value} = 'Simplex'; % {'Simplex','Gradient-Based','Patternsearch'}
if isempty(h.GlobalPDAFit)
    %% Disables uitabgroup warning
    warning('off','MATLAB:uitabgroup:OldVersion');
    %% Define main window
    h.GlobalPDAFit = figure(...
        'Units','normalized',...
        'Name','GlobalPDAFit',...
        'NumberTitle','off',...
        'MenuBar','none',...
        'defaultUicontrolFontName','Times',...
        'defaultAxesFontName','Times',...
        'defaultTextFontName','Times',...
        'OuterPosition',[0.01 0.05 0.78 0.9],...
        'UserData',[],...
        'Visible','on',...
        'Tag','GlobalPDAFit',...
        'Toolbar','figure',...
        'CloseRequestFcn',@Close_PDA);
    
    whitebg(h.GlobalPDAFit, Look.Axes);
    set(h.GlobalPDAFit,'Color',Look.Back);
    
    %% Menubar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % File Menu
    h.Menu.File = uimenu(...
        'Parent',h.GlobalPDAFit,...
        'Label','File',...
        'Tag','File',...
        'Enable','on');
    h.Menu.Load = uimenu(...
        'Parent',h.Menu.File,...
        'Label','Load File(s)...',...
        'Callback',{@Load_PDA, 1},...
        'Tag','Load');
    h.Menu.Add = uimenu(...
        'Parent',h.Menu.File,...
        'Label','Add File(s)...',...
        'Callback',{@Load_PDA, 2},...
        'Tag','Add');
    h.Menu.Save = uimenu(...
        'Parent',h.Menu.File,...
        'Label','Save to File(s)',...
        'Callback',@Save_PDA,...
        'Tag','Save');
    h.Menu.Export = uimenu(...
        'Parent',h.Menu.File,...
        'Label','Export Figure(s)',...
        'Callback',@Export_Figure,...
        'Tag','Export');
    h.Menu.Params = uimenu(...
        'Parent',h.Menu.File,...
        'Label','Reload Parameters',...
        'Callback',{@Update_ParamTable, 2},...
        'Tag','Params');
    h.Menu.FitParams = uimenu(...
        'Parent',h.Menu.File,...
        'Label','Reload Fit Parameters',...
        'Callback',{@Update_FitTable, 2},...
        'Tag','Params');
    %%% Fit Menu
    h.Menu.Fit = uimenu(...
        'Parent',h.GlobalPDAFit,...
        'Label','Fit');
    h.Menu.ViewFit = uimenu(...
        'Parent',h.Menu.Fit,...
        'Tag','ViewFit',...
        'Label','View',...
        'Callback',@Start_PDA_Fit);
    h.Menu.StartFit = uimenu(...
        'Parent',h.Menu.Fit,...
        'Tag','StartFit',...
        'Label','Start',...
        'Callback',@Start_PDA_Fit);
    h.Menu.StopFit = uimenu(...
        'Parent',h.Menu.Fit,...
        'Tag','StopFit',...
        'Label','Stop',...
        'Callback',@Stop_PDA_Fit);
    %%% Info Menu
    h.Menu.Info = uimenu(...
        'Parent',h.GlobalPDAFit,...
        'Label','Info');
    h.Menu.Todo = uimenu(...
        'Parent',h.Menu.Info,...
        'Tag','Todo',...
        'Label','To do',...
        'Callback', @Todolist);
    h.Menu.Manual = uimenu(...
        'Parent',h.Menu.Info,...
        'Tag','Manual',...
        'Label','Manual',...
        'Callback', @Manual);
    
    %% Upper tabgroup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.Tabgroup_Up = uitabgroup(...
        'Parent',h.GlobalPDAFit,...
        'Tag','MainPlotTab',...
        'Units','normalized',...
        'Position',[0 0.2 1 0.8]);
    
    %% All tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.AllTab.Tab = uitab(...
        'Parent',h.Tabgroup_Up,...
        'Tag','Tab_All',...
        'Title','All');
    
    % Main Axes
    h.AllTab.Main_Panel = uibuttongroup(...
        'Parent',h.AllTab.Tab,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','Main_Panel_All');
    h.AllTab.Main_Axes = axes(...
        'Parent',h.AllTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.04 0.075 0.72 0.75],...
        'Box','on',...
        'Tag','Main_Axes_All',...
        'FontSize',18,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XLim',[0 1],...
        'LineWidth',2,...
        'YLimMode','auto');
    xlabel('Proximity Ratio','Color',Look.Fore);
    ylabel('#','Color',Look.Fore);
    h.AllTab.Res_Axes = axes(...
        'Parent',h.AllTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.04 0.85 0.72 0.13],...
        'Box','on',...
        'Tag','Residuals_Axes_All',...
        'FontSize',18,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XTickLabel','',...
        'XLim',[0 1],...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',2,...
        'YLimMode','auto');
    ylabel('w_{res}','Color',Look.Fore);
    linkaxes([h.AllTab.Main_Axes,h.AllTab.Res_Axes],'x');
    
    %%% Progress Bar
    h.AllTab.Progress.Panel = uibuttongroup(...
        'Parent',h.AllTab.Main_Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0.78 0.94 0.21 0.04],...
        'Tag','Progress_Panel_All');
    h.AllTab.Progress.Axes = axes(...
        'Parent',h.AllTab.Progress.Panel,...
        'Tag','Progress_Axes_All',...
        'Units','normalized',...
        'Color',Look.Control,...
        'Position',[0 0 1 1]);
    h.AllTab.Progress.Axes.XTick=[];
    h.AllTab.Progress.Axes.YTick=[];
    h.AllTab.Progress.Text=text(...
        'Parent',h.AllTab.Progress.Axes,...
        'Tag','Progress_Text_All',...
        'Units','normalized',...
        'FontSize',12,...
        'FontWeight','bold',...
        'String','Nothing loaded',...
        'Interpreter','none',...
        'HorizontalAlignment','center',...
        'BackgroundColor','none',...
        'Color',Look.Fore,...
        'Position',[0.5 0.5]);
    
    %%% Burst Size Distribution Plot
    h.AllTab.BSD_Axes = axes(...
        'Parent',h.AllTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.8 0.55 0.185 0.35],...
        'Box','on',...
        'Tag','BSD_Axes_All',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',2,...
        'YLimMode','auto',...
        'XLimMode','auto');
    xlabel('# Photons per Bin','Color',Look.Fore);
    ylabel('Occurence','Color',Look.Fore);
    
    %%% distance Plot
    h.AllTab.Gauss_Axes = axes(...
        'Parent',h.AllTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.8 0.13 0.185 0.35],...
        'Box','on',...
        'Tag','Gauss_Axes_All',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',2,...
        'YLimMode','auto',...
        'XLimMode','auto');
    xlabel('Distance [A]','Color',Look.Fore);
    ylabel('Probability','Color',Look.Fore);
    
    
    %% Single tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% main plot
    h.SingleTab.Tab = uitab(...
        'Parent',h.Tabgroup_Up,...
        'Tag','Tab_Single',...
        'Title','Single');
    h.SingleTab.Main_Panel = uibuttongroup(...
        'Parent',h.SingleTab.Tab,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','Main_Panel_Single');
    h.SingleTab.Main_Axes = axes(...
        'Parent',h.SingleTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.04 0.075 0.72 0.75],...
        'Box','on',...
        'Tag','Main_Axes_Single',...
        'FontSize',18,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XLim',[0 1],...
        'LineWidth',2,...
        'YLimMode','auto');
    xlabel('Proximity Ratio','Color',Look.Fore);
    ylabel('#','Color',Look.Fore);
    h.SingleTab.Res_Axes = axes(...
        'Parent',h.SingleTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.04 0.85 0.72 0.13],...
        'Box','on',...
        'Tag','Residuals_Axes_Single',...
        'FontSize',18,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XTickLabel','',...
        'XLim',[0 1],...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',2,...
        'YLimMode','auto');
    ylabel('w_{res}','Color',Look.Fore);
    linkaxes([h.SingleTab.Main_Axes,h.SingleTab.Res_Axes],'x');
    
    %%% Progress Bar
    h.SingleTab.Progress.Panel = uibuttongroup(...
        'Parent',h.SingleTab.Main_Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0.78 0.94 0.21 0.04],...
        'Tag','Progress_Panel_Single');
    h.SingleTab.Progress.Axes = axes(...
        'Parent',h.SingleTab.Progress.Panel,...
        'Tag','Progress_Axes_Single',...
        'Units','normalized',...
        'Color',Look.Control,...
        'Position',[0 0 1 1]);
    h.SingleTab.Progress.Axes.XTick=[]; h.SingleTab.Progress.Axes.YTick=[];
    h.SingleTab.Progress.Text=text(...
        'Parent',h.SingleTab.Progress.Axes,...
        'Tag','Progress_Text_Single',...
        'Units','normalized',...
        'FontSize',12,...
        'FontWeight','bold',...
        'String','Nothing loaded',...
        'Interpreter','none',...
        'HorizontalAlignment','center',...
        'BackgroundColor','none',...
        'Color',Look.Fore,...
        'Position',[0.5 0.5]);
    
    %%% Burst Size Distribution Plot
    h.SingleTab.BSD_Axes = axes(...
        'Parent',h.SingleTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.8 0.55 0.185 0.35],...
        'Box','on',...
        'Tag','BSD_Axes_Single',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',2,...
        'YLimMode','auto',...
        'XLimMode','auto');
    xlabel('# Photons per Bin','Color',Look.Fore);
    ylabel('Occurence','Color',Look.Fore);
    
    %%% distance Plot
    h.SingleTab.Gauss_Axes = axes(...
        'Parent',h.SingleTab.Main_Panel,...
        'Units','normalized',...
        'Position',[0.8 0.13 0.185 0.35],...
        'Box','on',...
        'Tag','Gauss_Axes_Single',...
        'FontSize',12,...
        'nextplot','add',...
        'UIContextMenu',[],...
        'Color',Look.Axes,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'LineWidth',2,...
        'YLimMode','auto',...
        'XLimMode','auto');
    xlabel('Distance [A]','Color',Look.Fore);
    ylabel('Probability','Color',Look.Fore);
    
    %%% Determines, which file to plot
    h.SingleTab.Popup = uicontrol(...
        'Parent',h.SingleTab.Main_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', [1 1 1],...
        'ForegroundColor', [0 0 0],...
        'Style','popupmenu',...
        'String',{'Nothing selected'},...
        'Value',1,...
        'Callback',{@Update_Plots,2},...
        'Position',[0.775 -0.05 0.22 0.1],...
        'Tag','Popup_Single');
    
  
    
    %% Bottom tabgroup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.Tabgroup_Down = uitabgroup(...
        'Parent',h.GlobalPDAFit,...
        'Tag','Params_Tab',...
        'Units','normalized',...
        'Position',[0 0 1 0.2]);
    
    %% Database tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     h.PDADatabase.Tab= uitab(...
        'Parent',h.Tabgroup_Down,...
        'Tag','PDADatabase_Tab',...
        'Title','Database');    
    %%% Database panel
    h.PDADatabase.Panel = uibuttongroup(...
        'Parent',h.PDADatabase.Tab,...
        'Tag','PDADatabase_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);    
    %%% Database list
    h.PDADatabase.List = uicontrol(...
        'Parent',h.PDADatabase.Panel,...
        'Tag','PDADatabase_List',...
        'Style','listbox',...
        'Units','normalized',...
        'FontSize',14,...
        'Max',2,...
        'String',[],...
        'BackgroundColor', Look.List,...
        'ForegroundColor', Look.ListFore,...
        'KeyPressFcn',{@Database,0},...
        'Tooltipstring', ['<html>'...
                          'List of files in database <br>',...
                          '<i>"return"</i>: Loads selected files <br>',...
                          '<I>"delete"</i>: Removes selected files from list </b>'],...
        'Position',[0.01 0.01 0.9 0.98]);   
    %%% Button to add files to the database
    h.PDADatabase.Load = uicontrol(...
        'Parent',h.PDADatabase.Panel,...
        'Tag','PDADatabase_Load_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Load',...
        'Callback',{@Database,2},...
        'Position',[0.93 0.55 0.05 0.15],...
        'Tooltipstring', 'Load database from file');
    %%% Button to add files to the database
    h.PDADatabase.Save = uicontrol(...
        'Parent',h.PDADatabase.Panel,...
        'Tag','PDADatabase_Save_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Save',...
        'Callback',{@Database,3},...
        'Position',[0.93 0.35 0.05 0.15],...
        'enable', 'off',...
        'Tooltipstring', 'Save database to a file');
    
    %% Fit tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.FitTab.Tab = uitab(...
        'Parent',h.Tabgroup_Down,...
        'Tag','Fit_Tab',...
        'Title','Fit');
    h.FitTab.Panel = uibuttongroup(...
        'Parent',h.FitTab.Tab,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','Fit_Panel');
    h.FitTab.Table = uitable(...
        'Parent',h.FitTab.Panel,...
        'Tag','Fit_Table',...
        'Units','normalized',...
        'ForegroundColor',Look.TableFore,...
        'BackgroundColor',[Look.Table1;Look.Table2],...
        'FontSize',12,...
        'Position',[0 0 1 1],...
        'CellEditCallback',{@Update_FitTable,3},...
        'CellSelectionCallback',{@Update_FitTable,3});
    
    %% Parameters tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.ParametersTab.Tab = uitab(...
        'Parent',h.Tabgroup_Down,...
        'Tag','Parameters_Tab',...
        'Title','Parameters');
    h.ParametersTab.Panel = uibuttongroup(...
        'Parent',h.ParametersTab.Tab,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','Parameters_Panel');
    h.ParametersTab.Table = uitable(...
        'Parent',h.ParametersTab.Panel,...
        'Tag','Parameters_Panel',...
        'Units','normalized',...
        'ForegroundColor',Look.TableFore,...
        'BackgroundColor',[Look.Table1;Look.Table2],...
        'FontSize',12,...
        'Position',[0 0 1 1],...
        'CellEditCallback',{@Update_ParamTable,3},...
        'CellSelectionCallback',{@Update_ParamTable,3});
    
    %% Settings tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.SettingsTab.Tab = uitab(...
        'Parent',h.Tabgroup_Down,...
        'Tag','Settings_Tab',...
        'Title','Settings');
    h.SettingsTab.Panel = uibuttongroup(...
        'Parent',h.SettingsTab.Tab,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','SettingsPanel');
    % First column
    h.SettingsTab.NumberOfBins_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','Number of Bins',...
        'Position',[0.02 0.75 0.175 0.2],...
        'HorizontalAlignment','right',...
        'Tag','NumberOfBins_Text');
    h.SettingsTab.NumberOfBins_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','100',...
        'Position',[0.2 0.775 0.05 0.2],...
        'Callback',{@Update_Plots,3,1},...
        'Tag','NumberOfBins_Edit');
    h.SettingsTab.NumberOfPhotMin_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','Minimum Number of Photons per Burst',...
        'Position',[0.02 0.50 0.175 0.2],...
        'HorizontalAlignment','right',...
        'Tag','NumberOfPhotMin_Text');
    h.SettingsTab.NumberOfPhotMin_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','0',...
        'Callback',{@Update_Plots,3,1},...
        'Position',[0.2 0.525 0.05 0.2],...
        'Tag','NumberOfPhotMin_Edit');
    h.SettingsTab.NumberOfPhotMax_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','Maximum Number of Photons per Burst',...
        'Position',[0.02 0.25 0.175 0.2],...
        'HorizontalAlignment','right',...
        'Tag','NumberOfPhotMax_Text');
    h.SettingsTab.NumberOfPhotMax_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','Inf',...
        'Callback',{@Update_Plots,3,1},...
        'Position',[0.2 0.275 0.05 0.2],...
        'Tag','NumberOfPhotMax_Edit');
    h.SettingsTab.NumberOfBinsE_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String','Grid resolution for E',...
        'TooltipString','Higher increases fit accuracy, but makes it slower.',...
        'Position',[0.02 0 0.175 0.2],...
        'HorizontalAlignment','right',...
        'Tag','NumberOfBinsE_Text');
    h.SettingsTab.NumberOfBinsE_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'String','100',...
        'TooltipString','Higher increases fit accuracy, but makes it slower.',...
        'FontSize',12,...
        'Callback',{@Update_Plots,0,1},...
        'Position',[0.2 0.025 0.05 0.2],...
        'Tag','NumberOfBinsE_Edit');
    
    % third column
    h.SettingsTab.PDAMethod_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'String','PDA Method',...
        'FontSize',12,...
        'Position',[0.4 0.75 0.1 0.2],...
        'HorizontalAlignment','left',...
        'Tag','PDAMethod_Text');
    h.SettingsTab.PDAMethod_Popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor',[1 1 1],...
        'ForegroundColor',[0 0 0],...
        'Units','normalized',...
        'String',{'Histogram Library','MLE','MonteCarlo'},...
        'Value',1,...
        'FontSize',12,...
        'Position',[0.5 0.775 0.1 0.2],...
        'Tag','PDAMethod_Popupmenu');
    h.SettingsTab.FitMethod_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'String','Fit Method',...
        'FontSize',12,...
        'Position',[0.4 0.50 0.1 0.2],...
        'HorizontalAlignment','left',...
        'Tag','FitMethod_Text');
    h.SettingsTab.FitMethod_Popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', [1 1 1],...
        'ForegroundColor', [0 0 0],...
        'Units','normalized',...
        'String',{'Simplex','Gradient-Based','Patternsearch','Gradient-Based (global)'},...
        'Value',1,...
        'FontSize',12,...
        'Position',[0.5 0.525 0.1 0.2],...
        'Tag','FitMethod_Popupmenu');
    h.SettingsTab.OverSampling_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'String',sprintf('MonteCarlo Oversampling'),...
        'Position',[0.4 0.25 0.1 0.2],...
        'HorizontalAlignment','left',...
        'Tag','OverSampling_Text');
    h.SettingsTab.OverSampling_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'String','10',...
        'FontSize',12,...
        'Callback',[],...
        'Position',[0.505 0.275 0.05 0.2],...
        'Tag','OverSampling_Edit');
    h.SettingsTab.LiveUpdate = uicontrol(...
        'Parent',h.SettingsTab.Panel,...
        'Tag','LiveUpdate',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Live plot update',...
        'Value',0,...
        'Position',[0.4 0.025 0.1 0.2]);
    h.SettingsTab.FixSigmaAtFractionOfR = uicontrol(...
        'Parent',h.SettingsTab.Panel,...
        'Tag','FixSigmaAtFractionOfR',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Fix Sigma at Fraction of R:',...
        'Value',0,...
        'Callback',@Update_GUI,...
        'Position',[0.65 0.75 0.2 0.2]);
    h.SettingsTab.SigmaAtFractionOfR_edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'String','0.08',...
        'FontSize',12,...
        'Callback',[],...
        'Position',[0.76 0.75 0.05 0.2],...
        'Enable','off',...
        'Tag','SigmaAtFractionOfR_edit');
    h.SettingsTab.FixSigmaAtFractionOfR_Fix = uicontrol(...
        'Style','checkbox',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Value',0,...
        'FontSize',12,...
        'String','Fix?',...
        'Callback',[],...
        'Position',[0.82 0.75 0.05 0.2],...
        'Enable','off',...
        'Tag','FixSigmaAtFractionOfR_Fix');
    h.SettingsTab.OuterBins_Fix = uicontrol(...
        'Style','checkbox',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Value',0,...
        'FontSize',12,...
        'String','w_res limits?',...
        'Tooltipstring', 'do not take the first and last Epr bin into account when calculating the chi^2 and thus when fitting. Only works for Histogram Library!!!',...
        'Callback',[],...
        'Position',[0.65 0.5 0.2 0.2],...
        'Tag','OuterBins_Fix');
    
    h.SettingsTab.Use_Brightness_Corr = uicontrol(...
        'Style','checkbox',...
        'Parent',h.SettingsTab.Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Value',0,...
        'FontSize',12,...
        'String','Brightness Correction',...
        'Tooltipstring', '',...
        'Callback',{@Load_Brightness_Reference,1},...
        'ButtonDownFcn',{@Load_Brightness_Reference,2},...
        'Position',[0.65 0.3 0.2 0.2],...
        'Tag','Use_Brightness_Corr');

    %% Other stuff
    %%% Re-enable menu
    h.Menu.File.Enable = 'on';
    %% Initializes global variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PDAData=[];
    PDAData.Data=[];
    PDAData.FileName=[];
    PDAData.FitTable = [];
    PDAMeta=[];
    PDAData.Corrections = [];
    PDAData.Background = [];
    PDAMeta.Confidence_Intervals = cell(1,1);
    PDAMeta.Plots=cell(0);
    PDAMeta.Model=[];
    PDAMeta.Fits=[];
    PDAMeta.FitInProgress = 0;
    PDAMeta.LiveUpdate = 0;
    
    %% store handles structure
    guidata(h.GlobalPDAFit,h);
    SampleData
    Update_FitTable([],[],0);
    Update_ParamTable([],[],0);
    
else
    figure(h.GlobalPDAFit); % Gives focus to GlobalPDAFit figure
end

function Close_PDA(~,~)
clearvars -global PDAData PDAMeta
delete(findobj('Tag','GlobalPDAFit'));

% Load data that was exported in BurstBrowser
function Load_PDA(~,~,mode)
global PDAData UserValues
h = guidata(findobj('Tag','GlobalPDAFit'));

if mode ~= 3
    %% Load or Add data
    [FileName,p] = uigetfile({'*.pda','*.pda file'},'Select *.pda file',...
        UserValues.File.BurstBrowserPath,'Multiselect','on');
    %%% Transforms to cell array, if only one file was selected
    if ~iscell(FileName)
        FileName = {FileName};
    end
    %%% Only executes, if at least one file was selected
    if all(FileName{1}==0)
        return
    end
    PathName = cell(numel(FileName),1);
    PathName(:) = {p};
else
    %% Database loading
    FileName = PDAData.FileName;
    PathName = PDAData.PathName;
end

UserValues.File.BurstBrowserPath = PathName{1};

LSUserValues(1);

if mode==1 || mode ==3 % new files are loaded or database is loaded
    PDAData.FileName = [];
    PDAData.PathName = [];
    PDAData.Data = [];
    PDAData.timebin = [];
    PDAData.Corrections = [];
    PDAData.Background = [];
    PDAData.OriginalFitParams = [];
    PDAData.FitTable = [];
    PDAData.BrightnessReference = [];
    h.FitTab.Table.RowName(1:end-3)=[];
    h.FitTab.Table.Data(1:end-3,:)=[];
    h.ParametersTab.Table.RowName(1:end-1)=[];
    h.ParametersTab.Table.Data(1:end-1,:)=[];
    h.PDADatabase.List.String = [];
    h.PDADatabase.Save.Enable = 'off';

end
errorstr = cell(0,1);
a = 1;
for i = 1:numel(FileName)
    Progress(i/numel(FileName),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Loading file(s)...');
    Progress(i/numel(FileName),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Loading file(s)...');
    if exist(fullfile(PathName{i},FileName{i}), 'file') == 2
        load('-mat',fullfile(PathName{i},FileName{i}));
        PDAData.FileName{end+1} = FileName{i};
        PDAData.PathName{end+1} = PathName{i};
        if exist('PDA','var') % file has not been saved before in GlobalPDAFit
            % PDA %structure
            % .NGP
            % ....
            % .NR
            % .Corrections %structure
            %       .CrossTalk_GR
            %       .DirectExcitation_GR
            %       .Gamma_GR
            %       .Beta_GR
            %       .GfactorGreen
            %       .GfactorRed
            %       .DonorLifetime
            %       .AcceptorLifetime
            %       .FoersterRadius
            %       .LinkerLength
            %       .r0_green
            %       .r0_red
            %       ... maybe more in future
            % .Background %structure
            %       .Background_GGpar
            %       .Background_GGperp
            %       .Background_GRpar
            %       .Background_GRperp
            %       ... maybe more in future
            % NOTE: direct excitation correction in Burst analysis is NOT the
            % same as PDA, therefore we put it to zero. In PDA, this factor
            % is either the extcoeffA/(extcoeffA+extcoeffD) at donor laser,
            % or the ratio of Int(A)/(Int(A)+Int(D)) for a crosstalk, gamma
            % corrected double labeled molecule having no FRET at all.
            PDAData.Data{end+1} = PDA;
            PDAData.Data{end} = rmfield(PDAData.Data{end}, 'Corrections');
            PDAData.Data{end} = rmfield(PDAData.Data{end}, 'Background');
            PDAData.timebin(end+1) = timebin;
            PDAData.Corrections{end+1} = PDA.Corrections; %contains everything that was saved in BurstBrowser
            PDAData.Background{end+1} = PDA.Background; %contains everything that was saved in BurstBrowser
            if isfield(PDA,'BrightnessReference')
                PDAData.BrightnessReference = PDA.BrightnessReference;
            end
            clear PDA timebin
            PDAData.FitTable{end+1} = h.FitTab.Table.Data(end-2,:);
        elseif exist('SavedData','var') % file has been saved before in GlobalPDAFit and contains PDAData (named SavedData)
            % SavedData %structure
            %   .Data %cell
            %       .NGP
            %       ....
            %       .NR
            %   .Corrections %structure
            %           see above
            %   .Background %structure
            %           see above
            %   .FitParams %1 x 47 cell
            PDAData.Data{end+1} = SavedData.Data;
            PDAData.timebin(end+1) = SavedData.timebin;
            PDAData.Corrections{end+1} = SavedData.Corrections;
            PDAData.Background{end+1} = SavedData.Background;
            PDAData.BrightnessReference = SavedData.BrightnessReference;
            % load fit table data from files
            PDAData.FitTable{end+1} = SavedData.FitTable;
        elseif exist('PDAstruct','var')
            %%% File is probably from old PDAFit
            PDAData.Data{end+1} = PDAstruct.Data;
            PDAData.timebin(end+1) = PDAstruct.timebin;
            PDAData.Corrections{end+1} = PDAstruct.Corrections; %contains everything that was saved in BurstBrowser
            PDAData.Background{end+1}.Background_GGpar = PDAstruct.Corrections.BackgroundDonor/2;
            PDAData.Background{end}.Background_GGperp = PDAstruct.Corrections.BackgroundDonor/2;
            PDAData.Background{end}.Background_GRpar = PDAstruct.Corrections.BackgroundAcceptor/2;
            PDAData.Background{end}.Background_GRperp = PDAstruct.Corrections.BackgroundAcceptor/2;
            PDAData.FitTable{end+1} = h.FitTab.Table.Data(end-2,:);
        end
        % add files to database table
        h.PDADatabase.List.String{end+1} = [FileName{i} ' (path:' PathName{i} ')'];
        h.PDADatabase.Save.Enable = 'on';
    else
        errorstr{a} = ['File ' FileName{i} ' on path ' PathName{i} ' could not be found. File omitted from database.'];
        a = a+1;
    end
end
PDAData.OriginalFitParams = PDAData.FitTable; %contains the fit table as it was originally displayed when opening the data
if a > 1
    msgbox(errorstr)
end
% data cannot be directly plotted here, since other functions (bin size,...)
% might change the appearance of the data

Update_Plots([],[],3);
Update_FitTable([],[],1);
Update_ParamTable([],[],1);

% Save data and fit table back into each individual file 
function Save_PDA(~,~)
global PDAData
h = guidata(findobj('Tag','GlobalPDAFit'));
for i = 1:numel(PDAData.FileName)
    Progress(i/numel(PDAData.FileName),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Saving file(s)...');
    Progress(i/numel(PDAData.FileName),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Saving file(s)...');
    SavedData.Data = PDAData.Data{i};
    SavedData.timebin = PDAData.timebin(i);
    SavedData.Corrections = PDAData.Corrections{i};
    SavedData.Background = PDAData.Background{i};
    % for each dataset, all info from the table is saved (including active, global, fixed)
    SavedData.FitTable = h.FitTab.Table.Data(i,:);
    save(fullfile(PDAData.PathName{i},PDAData.FileName{i}),'SavedData');
end

% Function that groups things that concern the plots
function Update_Plots(~,~,mode,reset)
% function creates and/or updates the plots after:
% mode = 1: after fitting
% mode = 2: changing the popup value on single tab + called in UpdatePlot
% mode = 3: loading or adding data, n.o. bins, min/max
% mode = 4: after updateparam table
% mode = 5: LiveUpdate plots during fitting

global PDAData PDAMeta
h = guidata(findobj('Tag','GlobalPDAFit'));

if nargin < 4
    reset = 0;
end
%%% reset resets the PDAMeta.PreparationDone variable
if reset == 1
    PDAMeta.PreparationDone = 0;
end

% check if plot is active
Active = cell2mat(h.FitTab.Table.Data(1:end-3,1));

if all(~Active) %% Clears 2D plot, if all are inactive
    %     h.Plots.Main.ZData = zeros(2);
    %     h.Plots.Main.CData = zeros(2,2,3);
    %     h.Plots.Fit.ZData = zeros(2);
    %     h.Plots.Fit.CData = zeros(2,2,3);
    h.SingleTab.Popup.String = {'Nothing selected'};
else %% Updates 2D plot selection string
    h.SingleTab.Popup.String = PDAData.FileName(Active);
    if h.SingleTab.Popup.Value>numel(h.SingleTab.Popup.String)
        h.SingleTab.Popup.Value = 1;
    end
end

switch mode
    case 3
        %% Update the All tab
        color = lines(100);
        n = size(PDAData.Data,2);
        % after loading data or changing settings tab
        % predefine handle cells
        PDAMeta.Plots.Data_All = cell(n,1);
        PDAMeta.Plots.Res_All = cell(n,1);
        PDAMeta.Plots.Fit_All = cell(n,6);
        PDAMeta.Plots.BSD_All = cell(n,1);
        PDAMeta.Plots.Gauss_All = cell(n,6);
        PDAMeta.hProx = cell(n,1); %hProx has to be global cause it's used for error calculation during fitting
        cla(h.AllTab.Main_Axes)
        cla(h.AllTab.Res_Axes)
        cla(h.AllTab.BSD_Axes)
        cla(h.AllTab.Gauss_Axes)
        PDAMeta.Chi2_All = text('Parent',h.AllTab.Main_Axes,...
            'Units','normalized',...
            'Position',[0.87,0.95],...
            'String',['avg. \chi^2_{red.} = ' sprintf('%1.2f',randn(1))],...
            'FontWeight','bold',...
            'FontSize',18,...
            'FontSmoothing','on',...
            'Visible','off');
        for i = 1:n
            %colors
            normal = color(i,:);
            light = (normal+1)./2;
            dark = normal./2;
            %%% find valid bins (chosen by thresholds min/max)
            valid = ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) > str2double(h.SettingsTab.NumberOfPhotMin_Edit.String)) & ...
                ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) < str2double(h.SettingsTab.NumberOfPhotMax_Edit.String));
            %%% Calculate proximity ratio histogram
            Prox = PDAData.Data{i}.NF(valid)./(PDAData.Data{i}.NG(valid)+PDAData.Data{i}.NF(valid));
            BSD = PDAData.Data{i}.NF(valid)+PDAData.Data{i}.NG(valid);
            PDAMeta.BSD{i} = BSD;
            PDAMeta.hProx{i} = histcounts(Prox, linspace(0,1,str2double(h.SettingsTab.NumberOfBins_Edit.String)+1));
            xProx = linspace(0,1,str2double(h.SettingsTab.NumberOfBins_Edit.String)+1)+1/str2double(h.SettingsTab.NumberOfBins_Edit.String)/2;
            xProx = xProx(1:end-1);
            hBSD = histcounts(BSD,1:(max(BSD)+1));
            xBSD = 1:max(BSD);
            
            % make 'stairs' appear similar to 'bar'
            xProx = xProx-mean(diff(xProx))/2;
            
            % slightly modify x-axis for each following dataset, to
            % allow better visualization of the different datasets.
            if i ~= 1
                % i = 1: do nothing
                % i = 2: shift each x value +5% of the x bin size
                % i = 3: shift each x value -5% of the x bin size
                % i = 4: shift each x value +10% of the x bin size
                % i = 5: shift each x value -10% of the x bin size
                % ...
                diffx = mean(diff(xProx))/20;
                if mod(i,2) == 0 %i = 2, 4, 6...
                    xProx = xProx + diffx*i/2;
                else %i = 3, 5, 7...
                    xProx = xProx - diffx*(i-1)/2;
                end
            end
            % data plot
            PDAMeta.Plots.Data_All{i} = stairs(h.AllTab.Main_Axes,...
                xProx,...
                PDAMeta.hProx{i},...
                'Color',normal,...
                'LineWidth',1);
            % residuals plot
            PDAMeta.Plots.Res_All{i} = stairs(h.AllTab.Res_Axes,...
                xProx,...
                zeros(numel(xProx),1),...
                'Color',normal,...
                'LineWidth',1,...
                'Visible', 'off');
            % plots for individual fits
            for j = 2:6
                PDAMeta.Plots.Fit_All{i,j} = stairs(h.AllTab.Main_Axes,...
                    xProx,...
                    zeros(numel(xProx),1),...
                    'Color',light,...
                    'LineWidth',2,...
                    'Linestyle','--',...
                    'Visible','off');
            end
            % fit plots
            PDAMeta.Plots.Fit_All{i,1} = stairs(h.AllTab.Main_Axes,...
                xProx,...
                zeros(numel(xProx),1),...
                'Color',dark,...
                'LineWidth',2,...
                'Linestyle','--',...
                'Visible','off');
            % burst size distribution plot
            if isempty(PDAData.BrightnessReference)
                PDAMeta.Plots.BSD_Reference = plot(h.AllTab.BSD_Axes,...
                    xBSD,...
                    hBSD,...
                    'Color','m',...
                    'LineStyle','--',...
                    'Visible','off',...
                    'LineWidth',2);
            else
                PDAMeta.Plots.BSD_Reference = plot(h.AllTab.BSD_Axes,...
                    xBSD,...
                    PDAData.BrightnessReference.PN(xBSD),...
                    'Color','m',...
                    'LineStyle','--',...
                    'LineWidth',2,...
                    'Visible','off');
            end
            if h.SettingsTab.Use_Brightness_Corr.Value
                PDAMeta.Plots.BSD_Reference.Visible = 'on';
            end
            PDAMeta.Plots.BSD_All{i} = plot(h.AllTab.BSD_Axes,...
                xBSD,...
                hBSD,...
                'Color',normal,...
                'LineWidth',2);
            % generate exemplary distance plots
            x = 0:0.1:150;
            g = zeros(5,150*10+1);
            for j = 1:5
                g(j,:) = normpdf(x,40+10*j,j);
            end;
            % summed distance plot
            PDAMeta.Plots.Gauss_All{i,1} = plot(h.AllTab.Gauss_Axes,...
                x,sum(g,1),...
                'Color',dark,...
                'LineWidth',2,...
                'Visible', 'off');
            %individual distance plots
            for j = 2:6
                PDAMeta.Plots.Gauss_All{i,j} = plot(h.AllTab.Gauss_Axes,...
                    x,g(j-1,:),...
                    'Color',light,...
                    'LineWidth',1,...
                    'Visible', 'off');
            end
            xlim(h.AllTab.Gauss_Axes,[40 120]);
        end
end
switch mode
    case {2,3}
        %% Update the 'Single' tab plots
        % after load data
        % after popup change
        % during fitting, when the tab is changed to single
        i = h.SingleTab.Popup.Value;
        % predefine cells
        PDAMeta.Plots.Fit_Single = cell(1,6);
        PDAMeta.Plots.Gauss_Single = cell(1,6);
        % clear axes
        cla(h.SingleTab.Main_Axes)
        cla(h.SingleTab.Res_Axes)
        cla(h.SingleTab.BSD_Axes)
        cla(h.SingleTab.Gauss_Axes)
        PDAMeta.Chi2_Single = copyobj(PDAMeta.Chi2_All, h.SingleTab.Main_Axes);
        PDAMeta.Chi2_Single.Position = [0.9,0.95];
        try
            % if fit is performed, this will work
            PDAMeta.Chi2_Single.String = ['\chi^2_{red.} = ' sprintf('%1.2f',PDAMeta.chi2(i))];
        end
        %%% Re-Calculate proximity ratio histogram
        valid = ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) > str2double(h.SettingsTab.NumberOfPhotMin_Edit.String)) & ...
            ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) < str2double(h.SettingsTab.NumberOfPhotMax_Edit.String));
        Prox = PDAData.Data{i}.NF(valid)./(PDAData.Data{i}.NG(valid)+PDAData.Data{i}.NF(valid));
        hProx = histcounts(Prox, linspace(0,1,str2double(h.SettingsTab.NumberOfBins_Edit.String)+1));
        xProx = linspace(0,1,str2double(h.SettingsTab.NumberOfBins_Edit.String)+1)+1/str2double(h.SettingsTab.NumberOfBins_Edit.String)/2;
        xProx = xProx(1:end-1);
        % data plot
        PDAMeta.Plots.Data_Single = bar(h.SingleTab.Main_Axes,...
            xProx,...
            hProx,...
            'FaceColor',[0.4 0.4 0.4],...
            'EdgeColor','none',...
            'BarWidth',1);
        % residuals
        PDAMeta.Plots.Res_Single = copyobj(PDAMeta.Plots.Res_All{i}, h.SingleTab.Res_Axes);
        set(PDAMeta.Plots.Res_Single,...
            'LineWidth',2,...
            'Color','k') %only define those properties that are different to the all tab
        % fit
        for j = 2:6
            PDAMeta.Plots.Fit_Single{1,j} = copyobj(PDAMeta.Plots.Fit_All{i,j}, h.SingleTab.Main_Axes);
            PDAMeta.Plots.Fit_Single{1,j}.Color = [0.2 0.2 0.2];%only define those properties that are different to the all tab
        end
        % summed fit
        PDAMeta.Plots.Fit_Single{1,1} = copyobj(PDAMeta.Plots.Fit_All{i,1}, h.SingleTab.Main_Axes);
        PDAMeta.Plots.Fit_Single{1,1}.Color = 'k';%only define those properties that are different to the all tab
        % bsd
        PDAMeta.Plots.BSD_Single = copyobj(PDAMeta.Plots.BSD_All{i}, h.SingleTab.BSD_Axes);
        PDAMeta.Plots.BSD_Single.Color = 'k';%only define those properties that are different to the all tab
        % gaussians
        for j = 1:6
            PDAMeta.Plots.Gauss_Single{1,j} = copyobj(PDAMeta.Plots.Gauss_All{i,j}, h.SingleTab.Gauss_Axes);
            PDAMeta.Plots.Gauss_Single{1,j}.Color = [0.4 0.4 0.4]; %only define those properties that are different to the all tab
        end
        PDAMeta.Plots.Gauss_Single{1,1}.Color = 'k';
    case 4
        %% change active checkbox
        for i = 1:numel(PDAData.FileName)
            if cell2mat(h.FitTab.Table.Data(i,1))
                tex = 'on';
            else
                tex = 'off';
            end
            PDAMeta.Plots.Data_All{i}.Visible = tex;
            if sum(PDAMeta.Plots.Res_All{i}.YData) ~= 0
                % data has been fitted before
                PDAMeta.Plots.Res_All{i}.Visible = tex;
            end
            PDAMeta.Plots.BSD_All{i}.Visible = tex;
            for j = 1:6
                if sum(PDAMeta.Plots.Fit_All{i,j}.YData) ~= 0;
                    % data has been fitted before and component exists
                    PDAMeta.Plots.Fit_All{i,j}.Visible = tex;
                    PDAMeta.Plots.Gauss_All{i,j}.Visible = tex;
                end
                
            end
            % Update the 'Single' tab plots
            if i == h.SingleTab.Popup.Value
                PDAMeta.Plots.Data_Single.Visible = tex;
                if sum(PDAMeta.Plots.Res_Single.YData) ~= 0
                    % data has been fitted before
                    PDAMeta.Plots.Res_Single.Visible = tex;
                end
                PDAMeta.Plots.BSD_Single.Visible = tex;
                for j = 1:6
                    if sum(PDAMeta.Plots.Fit_Single{1,j}.YData) ~= 0;
                        % data has been fitted before and component exists
                        PDAMeta.Plots.Fit_Single{1,j}.Visible = tex;
                        PDAMeta.Plots.Gauss_Single{1,j}.Visible = tex;
                    end
                end
            end
        end
    case 1
        %% Update plots post fitting
        FitTable = cellfun(@str2double,h.FitTab.Table.Data);
        for i = find(PDAMeta.Active)'
            fitpar = FitTable(i,2:3:end-1);
            %%% Calculate Gaussian Distance Distributions
            for c = PDAMeta.Comp{i}
                Gauss{c} = fitpar(3*c-2).*...
                    normpdf(PDAMeta.Plots.Gauss_All{i,1}.XData,fitpar(3*c-1),fitpar(3*c));
            end
            
            %%% Update All Plot
            set(PDAMeta.Plots.Fit_All{i,1},...
                'Visible', 'on',...
                'YData', PDAMeta.hFit{i});
            set(PDAMeta.Plots.Res_All{i},...
                'Visible', 'on',...
                'YData', PDAMeta.w_res{i});
            for c = PDAMeta.Comp{i}
                set(PDAMeta.Plots.Fit_All{i,c+1},...
                    'Visible', 'on',...
                    'YData', PDAMeta.hFit_Ind{i,c});
            end
            set(PDAMeta.Chi2_All,...
                'Visible','on',...
                'String', ['\chi^2_{red.} = ' sprintf('%1.2f',mean(PDAMeta.chi2))]);
            set(PDAMeta.Plots.Gauss_All{i,1},...
                'Visible', 'on',...
                'YData', sum(vertcat(Gauss{:}),1));
            for c = PDAMeta.Comp{i}
                set(PDAMeta.Plots.Gauss_All{i,c+1},...
                    'Visible', 'on',...
                    'YData', Gauss{c});
            end
            
            %%% Update Single Plot
            if i == h.SingleTab.Popup.Value
                set(PDAMeta.Plots.Fit_Single{1,1},...
                    'Visible', 'on',...
                    'YData', PDAMeta.hFit{i});
                set(PDAMeta.Plots.Res_Single,...
                    'Visible', 'on',...
                    'YData', PDAMeta.w_res{i});
                for c = PDAMeta.Comp{i}
                    set(PDAMeta.Plots.Fit_Single{1,c+1},...
                        'Visible', 'on',...
                        'YData',PDAMeta.hFit_Ind{i,c});
                end
                set(PDAMeta.Chi2_Single,...
                    'Visible','on',...
                    'String', ['\chi^2_{red.} = ' sprintf('%1.2f',PDAMeta.chi2(i))]);
                % file is shown on the 'Single' tab
                set(PDAMeta.Plots.Gauss_Single{1,1},...
                    'Visible', 'on',...
                    'YData', sum(vertcat(Gauss{:}),1));
                for c = PDAMeta.Comp{i}
                    set(PDAMeta.Plots.Gauss_Single{1,c+1},...
                        'Visible', 'on',...
                        'YData', Gauss{c});
                end
                % Single tab Gauss Axis x limit
                xlim(h.SingleTab.Gauss_Axes,[min(fitpar(2:3:end-2)-3*fitpar(3:3:end-1)),...
                    max(fitpar(2:3:end-2)+3*fitpar(3:3:end-1))]);
            end
        end
        %%% Set All Tab Gauss Axis X limit
        % get fit parameters
        FitTable = FitTable(1:end-3,2:3:end-1);
        % get all active files and components
        Mini = []; Maxi = [];
        for i = find(PDAMeta.Active)'
            for c = PDAMeta.Comp{i}
                Mini = [Mini FitTable(i,3*c-1)-3*FitTable(i,3*c)];
                Maxi = [Maxi FitTable(i,3*c-1)+3*FitTable(i,3*c)];
            end
        end
        xlim(h.AllTab.Gauss_Axes,[min(Mini), max(Maxi)]);
    case 5 %% Live Plot update
        i = PDAMeta.file;
        % PDAMeta.Comp{i} = index of the gaussian component that is used
        set(PDAMeta.Plots.Res_All{i},...
            'Visible', 'on',...
            'YData', PDAMeta.w_res{i});
        for c = PDAMeta.Comp{i}
            set(PDAMeta.Plots.Fit_All{i,c+1},...
                'Visible', 'on',...
                'YData', PDAMeta.hFit_Ind{i,c});
        end
        set(PDAMeta.Plots.Fit_All{i,1},...
            'Visible', 'on',...
            'YData', PDAMeta.hFit{i});
        if i == h.SingleTab.Popup.Value
            set(PDAMeta.Plots.Res_Single,...
                'Visible', 'on',...
                'YData', PDAMeta.w_res{i});
            for c = PDAMeta.Comp{i}
                set(PDAMeta.Plots.Fit_Single{1,c+1},...
                    'Visible', 'on',...
                    'YData', PDAMeta.hFit_Ind{i,c});
            end
            set(PDAMeta.Plots.Fit_Single{1,1},...
                'Visible', 'on',...
                'YData', PDAMeta.hFit{i});
        end
end

% File menu - view/start fitting
function Start_PDA_Fit(obj,~)
global PDAData PDAMeta
h = guidata(findobj('Tag','GlobalPDAFit'));
%%% disable Fit Menu and Fit parameters table
%h.Menu.Fit.Enable = 'off';
%h.FitTab.Table.Enable='off';
%%% Indicates fit in progress
PDAMeta.FitInProgress = 1;

%% Store parameters globally for easy access during fitting
try
    PDAMeta = rmfield(PDAMeta, 'BGdonor');
    PDAMeta = rmfield(PDAMeta, 'BGacc');
    PDAMeta = rmfield(PDAMeta, 'crosstalk');
    PDAMeta = rmfield(PDAMeta, 'R0');
    PDAMeta = rmfield(PDAMeta, 'directexc');
    PDAMeta = rmfield(PDAMeta, 'gamma');
end
allsame = 1;
calc = 1;
for i = 1:numel(PDAData.FileName)
    % if all files have the same parameters as the ALL row some things will only be calculated once
    if ~isequal(cell2mat(h.ParametersTab.Table.Data(i,:)),cell2mat(h.ParametersTab.Table.Data(end,:)))
        allsame = 0;
    end
    PDAMeta.BGdonor(i) = cell2mat(h.ParametersTab.Table.Data(i,4));
    PDAMeta.BGacc(i) = cell2mat(h.ParametersTab.Table.Data(i,5));
    PDAMeta.crosstalk(i) = cell2mat(h.ParametersTab.Table.Data(i,3));
    PDAMeta.R0(i) = cell2mat(h.ParametersTab.Table.Data(i,6));
    PDAMeta.directexc(i) = cell2mat(h.ParametersTab.Table.Data(i,2));
    PDAMeta.gamma(i) = cell2mat(h.ParametersTab.Table.Data(i,1));
    % Make Plots invisible
    for c = 1:6
        PDAMeta.Plots.Fit_All{i,c}.Visible = 'off';
        PDAMeta.Plots.Gauss_All{i,c}.Visible = 'off';
    end
    PDAMeta.Plots.Res_All{i}.Visible = 'off';
    
    if i == h.SingleTab.Popup.Value
        for c = 1:6
            PDAMeta.Plots.Fit_Single{1,c}.Visible = 'off';
            PDAMeta.Plots.Gauss_Single{1,c}.Visible = 'off';
        end
        PDAMeta.Plots.Res_Single.Visible = 'off';
    end
end
Nobins = str2double(h.SettingsTab.NumberOfBins_Edit.String);
NobinsE = str2double(h.SettingsTab.NumberOfBinsE_Edit.String);

PDAMeta.Active = cell2mat(h.FitTab.Table.Data(1:end-3,1));

%%% Read fit settings and store in UserValues
%% Prepare Fit Inputs
if (PDAMeta.PreparationDone == 0) || ~isfield(PDAMeta,'epsEgrid')
    PDAMeta.P = cell(numel(PDAData.FileName),NobinsE+1);
    counter = 1;
    maxN = 0;
    for i  = find(PDAMeta.Active)'
        %%% find valid bins (chosen by thresholds min/max)
        valid{i} = ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) > str2double(h.SettingsTab.NumberOfPhotMin_Edit.String)) & ...
            ((PDAData.Data{i}.NF+PDAData.Data{i}.NG) < str2double(h.SettingsTab.NumberOfPhotMax_Edit.String));
        %%% find the maxN of all data
        maxN = max(maxN, max((PDAData.Data{i}.NF(valid{i})+PDAData.Data{i}.NG(valid{i}))));
    end

    for i  = find(PDAMeta.Active)'
        if ~PDAMeta.FitInProgress
            break;
        end
        if counter > 1
            if allsame
                %calculate some things only once
                calc = 0;
            end
        end
        if calc
            %%% evaluate the background probabilities
            BGgg = poisspdf(0:1:maxN,PDAMeta.BGdonor(i)*PDAData.timebin(i)*1E3);
            BGgr = poisspdf(0:1:maxN,PDAMeta.BGacc(i)*PDAData.timebin(i)*1E3);
            
            method = 'cdf';
            switch method
                case 'pdf'
                    %determine boundaries for background inclusion
                    BGgg(BGgg<1E-2) = [];
                    BGgr(BGgr<1E-2) = [];
                case 'cdf'
                    %%% evaluate the background probabilities
                    CDF_BGgg = poisscdf(0:1:maxN,PDAMeta.BGdonor(i))*PDAData.timebin(i)*1E3;
                    CDF_BGgr = poisscdf(0:1:maxN,PDAMeta.BGacc(i))*PDAData.timebin(i)*1E3;
                    %determine boundaries for background inclusion
                    threshold = 0.95;
                    BGgg((find(CDF_BGgg>threshold,1,'first')+1):end) = [];
                    BGgr((find(CDF_BGgr>threshold,1,'first')+1):end) = [];
            end
            PBG = BGgg./sum(BGgg);
            PBR = BGgr./sum(BGgr);
            NBG = numel(BGgg)-1;
            NBR = numel(BGgr)-1;
        end
        % assign current file to global cell
        PDAMeta.PBG{i} = PBG;
        PDAMeta.PBR{i} = PBR;
        PDAMeta.NBG{i} = NBG;
        PDAMeta.NBR{i} = NBR;
        
        if strcmp(h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value},'Histogram Library')
            if calc
                %%% prepare epsilon grid
                Progress(0,h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Preparing Epsilon Grid...');
                Progress(0,h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Preparing Epsilon Grid...');
                
                E_grid = linspace(0,1,NobinsE+1);
                R_grid = linspace(0,5*PDAMeta.R0(i),100000)';
                epsEgrid = 1-(1+PDAMeta.crosstalk(i)+PDAMeta.gamma(i)*((E_grid+PDAMeta.directexc(i)/(1-PDAMeta.directexc(i)))./(1-E_grid))).^(-1);
                epsRgrid = 1-(1+PDAMeta.crosstalk(i)+PDAMeta.gamma(i)*(((PDAMeta.directexc(i)/(1-PDAMeta.directexc(i)))+(1./(1+(R_grid./PDAMeta.R0(i)).^6)))./(1-(1./(1+(R_grid./PDAMeta.R0(i)).^6))))).^(-1);
                [NF, N, eps] = meshgrid(0:maxN,1:maxN,epsEgrid);
                Progress((i-1)/sum(PDAMeta.Active),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Preparing Probability Library...');
                Progress((i-1)/sum(PDAMeta.Active),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Preparing Probability Library...');
                PNF = binopdf(NF, N, eps);
            end
            PN = histcounts((PDAData.Data{i}.NF(valid{i})+PDAData.Data{i}.NG(valid{i})),1:(maxN+1));
            % assign current file to global cell
            PDAMeta.E_grid{i} = E_grid;
            PDAMeta.R_grid{i} = R_grid;
            PDAMeta.epsEgrid{i} = epsEgrid;
            PDAMeta.epsRgrid{i} = epsRgrid;
            PDAMeta.PN{i} = PN;
            PDAMeta.PNF{i} = PNF;
            PDAMeta.Grid.NF{i} = NF;
            PDAMeta.Grid.N{i} = N;
            PDAMeta.Grid.eps{i} = eps;
            PDAMeta.maxN{i} = maxN;
            
            %% Calculate Histogram Library (CalcHistLib)
            Progress(0,h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Calculating Histogram Library...');
            Progress(0,h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Calculating Histogram Library...');
            PDAMeta.HistLib = [];
            P = cell(1,numel(E_grid));
            PN_dummy = PN';
            %case 1, no bacNFground in either channel
            if NBG == 0 && NBR == 0
                for j = 1:numel(E_grid)
                    P_temp = PNF(:,:,j);
                    E_temp = NF(:,:,j)./N(:,:,j);
                    [~,~,bin] = histcounts(E_temp(:),linspace(0,1,Nobins+1));
                    valid = (bin ~= 0);
                    P_temp = P_temp(:);
                    bin = bin(valid);
                    P_temp = P_temp(valid);
                    Progress(j/numel(E_grid),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Calculating Histogram Library...');
                    Progress(j/numel(E_grid),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Calculating Histogram Library...');
                    %%% Store bin,valid and P_temp variables for brightness
                    %%% correction
                    PDAMeta.HistLib.bin{i}{j} = bin;
                    PDAMeta.HistLib.P_array{i}{j} = P_temp;
                    PDAMeta.HistLib.valid{i}{j} = valid;

                    PN_trans = repmat(PN_dummy,1,maxN+1);
                    PN_trans = PN_trans(:);
                    PN_trans = PN_trans(PDAMeta.HistLib.valid{i}{j});
                    P{1,j} = accumarray(PDAMeta.HistLib.bin{i}{j},PDAMeta.HistLib.P_array{i}{j}.*PN_trans);
                end
            else
                for j = 1:numel(E_grid)
                    bin = cell((NBG+1)*(NBR+1),1);
                    P_array = cell((NBG+1)*(NBR+1),1);
                    valid = cell((NBG+1)*(NBG+1),1);
                    count = 1;
                    for g = 0:NBG
                        for r = 0:NBR
                            P_temp = PBG(g+1)*PBR(r+1)*PNF(1:end-g-r,:,j); %+1 since also zero is included
                            E_temp = (NF(1:end-g-r,:,j)+r)./(N(1:end-g-r,:,j)+g+r);
                            [~,~,bin{count}] = histcounts(E_temp(:),linspace(0,1,Nobins+1));
                            valid{count} = (bin{count} ~= 0);
                            P_temp = P_temp(:);
                            bin{count} = bin{count}(valid{count});
                            P_temp = P_temp(valid{count});
                            P_array{count} = P_temp;
                            count = count+1;
                        end
                    end
                    
                    %%% Store bin,valid and P_array variables for brightness
                    %%% correction
                    PDAMeta.HistLib.bin{i}{j} = bin;
                    PDAMeta.HistLib.P_array{i}{j} = P_array;
                    PDAMeta.HistLib.valid{i}{j} = valid;
                            
                    P{1,j} = zeros(Nobins,1);
                    count = 1;
                    for g = 0:NBG
                        for r = 0:NBR
                            PN_trans = repmat(PN_dummy(1+g+r:end),1,maxN+1);%the total number of fluorescence photons is reduced
                            PN_trans = PN_trans(:);
                            PN_trans = PN_trans(valid{count});
                            P{1,j} = P{1,j} + accumarray(bin{count},P_array{count}.*PN_trans);
                            count = count+1;
                        end
                    end
                    Progress(j/numel(E_grid),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Calculating Histogram Library...');
                    Progress(j/numel(E_grid),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Calculating Histogram Library...');
                end
            end
            % different files = different rows
            % different Ps = different columns
            PDAMeta.P(i,:) = P;
            PDAMeta.PreparationDone = 1;
        end
        counter = counter + 1;
    end
end

%% Store fit parameters globally
PDAMeta.Fixed = cell2mat(h.FitTab.Table.Data(1:end-3,3:3:end-1));
PDAMeta.Global = cell2mat(h.FitTab.Table.Data(end-2,4:3:end-1));
LB = h.FitTab.Table.Data(end-1,2:3:end-1);
PDAMeta.LB = cellfun(@str2double,LB);
UB = h.FitTab.Table.Data(end  ,2:3:end-1);
PDAMeta.UB = cellfun(@str2double,UB);
FitTable = cellfun(@str2double,h.FitTab.Table.Data);
PDAMeta.FitParams = FitTable(1:end-3,2:3:end-1);
        
clear LB UB FitTable

if any(isnan(PDAMeta.FitParams(:)))
    disp('There were NaNs in the fit parameters. Aborting');
    h.Menu.Fit.Enable = 'on';
    return;
end

% generate a cell array, with each cell a file, and the contents of the
% cell is the gaussian components that are used per file during fitting.
Comp = cell(numel(PDAData.FileName));
for i = find(PDAMeta.Active)'
    comp = [];
    % the used gaussian fit components
    for c = 1:5
        if PDAMeta.Fixed(i,3*c-2)==false || PDAMeta.FitParams(i,3*c-2)~=0
            % Amp ~= fixed || Amp ~= 0
            comp = [comp c];
        end
    end
    Comp{i} = comp;
end
PDAMeta.Comp = Comp;


%%
% In general, 3 ways can used for fixing parameters
% passing them into the fit function, but fixing them again to their initial value in the fit function (least elegant)
% passing them into the fit function and fixing their UB&LB to their initial value (used in PDAFit)
% not passing them into the fit function, but just calling their values inside the fit function (used in FCSFit and global PDAFit)

if sum(PDAMeta.Global) == 0
    %% One-curve-at-a-time fitting
    for i = find(PDAMeta.Active)'
        LB = PDAMeta.LB;
        UB = PDAMeta.UB;
        h.SingleTab.Popup.Value = i;
        Update_Plots([],[],2); %to ensure the correct data is plotted on single tab during fitting
        PDAMeta.file = i;
        fitpar = PDAMeta.FitParams(i,:);
        fixed = PDAMeta.Fixed(i,:);
        LB(fixed) = fitpar(fixed);
        UB(fixed) = fitpar(fixed);
        
        %%% If sigma is fixed at fraction of R, add the parameter here
        if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
            fitpar(end+1) = str2double(h.SettingsTab.SigmaAtFractionOfR_edit.String);
            fixed(end+1) = h.SettingsTab.FixSigmaAtFractionOfR_Fix.Value;
            LB(end+1) = 0;
            UB(end+1) = 1;
        end 
        % Fixed for Patternsearch and fmincon
        if sum(fixed) == 0 %nothing is Fixed
            A = [];
            b = [];
        elseif sum(fixed(:)) > 0
            A = zeros(numel(fixed)); %NxN matrix with zeros
            b = zeros(numel(fixed),1);
            for j = 1:numel(fixed)
                if fixed(j) == 1 %set diagonal to 1 and b to value --> 1*x = b
                    A(j,j) = 1;
                    b(j) = fitpar(j);
                end
            end
        end
        
        if obj == h.Menu.ViewFit
            %% Check if View_Curve was pressed
            %%% Only Update Plot and break
            Progress((i-1)/sum(PDAMeta.Active),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Simulating Histograms...');
            Progress((i-1)/sum(PDAMeta.Active),h.SingleTab.Progress.Axes,h.AllTab.Progress.Text,'Simulating Histograms...');
            switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
                case {'MLE','MonteCarlo'}
                    %%% For Updating the Result Plot, use MC sampling
                    PDAMonteCarloFit_Single(fitpar);
                case 'Histogram Library'
                    PDAHistogramFit_Single(fitpar);
            end
        else
            %% Do Fit
            Progress((i-1)/sum(PDAMeta.Active),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Fitting Histograms...');
            Progress((i-1)/sum(PDAMeta.Active),h.SingleTab.Progress.Axes,h.AllTab.Progress.Text,'Fitting Histograms...');
            switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
                case 'Histogram Library'
                    fitfun = @(x) PDAHistogramFit_Single(x);
                case 'MLE'
                    %msgbox('doesnt work yet')
                    %return
                    fitfun = @(x) PDA_MLE_Fit_Single(x);
                case 'MonteCarlo'
                    %msgbox('doesnt work yet')
                    %return
                    fitfun = @(x) PDAMonteCarloFit_Single(x);
            end
            
            switch h.SettingsTab.FitMethod_Popupmenu.String{h.SettingsTab.FitMethod_Popupmenu.Value}
                case 'Simplex'
                    fitopts = optimset('MaxFunEvals', 1E4,'Display','iter','TolFun',1E-6,'TolX',1E-3);%,'PlotFcns',@optimplotfvalPDA);
                    fitpar = fminsearchbnd(fitfun, fitpar, LB, UB, fitopts);
                case 'Gradient-Based'
                    %msgbox('doesnt work yet')
                    %return
                    fitopts = optimoptions('fmincon','MaxFunEvals',1E4,'Display','iter');%,'PlotFcns',@optimplotfvalPDA);
                    fitpar = fmincon(fitfun, fitpar,[],[],A,b,LB,UB,[],fitopts);
                case 'Patternsearch'
                    %msgbox('doesnt work yet')
                    %return
                    opts = psoptimset('Cache','on','Display','iter','PlotFcns',@psplotbestf);%,'UseParallel','always');
                    fitpar = patternsearch(fitfun, fitpar, [],[],A,b,LB,UB,[],opts);
                case 'Gradient-Based (global)'
                    %msgbox('doesnt work yet')
                    %return
                    opts = optimoptions(@fmincon,'Algorithm','interior-point','Display','iter');%,'PlotFcns',@optimplotfvalPDA);
                    problem = createOptimProblem('fmincon','objective',fitfun,'x0',fitpar,'Aeq',A,'beq',b,'lb',LB,'ub',UB,'options',opts);
                    gs = GlobalSearch;
                    fitpar = run(gs,problem);
            end
        end
        %Calculate chi^2
        switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
            case 'Histogram Library'
                %PDAMeta.chi2 = PDAHistogramFit_Single(fitpar);
            case 'MLE'
                %%% For Updating the Result Plot, use MC sampling
                PDAMeta.chi2 = PDAMonteCarloFit_Single(fitpar);
                %%% Update Plots
                h.FitTab.Bar.YData = PDAMeta.hFit;
                h.Res_Bar.YData = PDAMeta.w_res;
                for c = comp
                    h.FitTab.BarInd{i}.YData = PDAMeta.hFit_Ind{c};
                end
                if isfield(PDAMeta,'Last_logL')
                    PDAMeta = rmfield(PDAMeta,'Last_logL');
                end
            case 'MonteCarlo'
                %PDAMeta.chi2 = PDAMonteCarloFit_Single(fitpar);
            otherwise
                PDAMeta.chi2 = 0;
        end
        
        % display final mean chi^2
        set(PDAMeta.Chi2_All, 'Visible','on','String', ['avg. \chi^2_{red.} = ' sprintf('%1.2f',mean(PDAMeta.chi2))]);
        
        %%% If sigma was fixed at fraction of R, update edit box here and
        %%% remove from fitpar array
        %%% if sigma is fixed at fraction of, read value here before reshape
        if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
             h.SettingsTab.SigmaAtFractionOfR_edit.String = num2str(fitpar(end));
             fitpar(end) = [];
        end
        % Convert amplitudes to fractions
        fitpar(3*PDAMeta.Comp{i}-2) = fitpar(3*PDAMeta.Comp{i}-2)./sum(fitpar(3*PDAMeta.Comp{i}-2));
        %%% if sigma is fixed at fraction of, change its value here
        if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
            fraction = str2double(h.SettingsTab.SigmaAtFractionOfR_edit.String);
            fitpar(3:3:end) = fraction.*fitpar(2:3:end);
        end
        % put optimized values back in table
        h.FitTab.Table.Data(i,2:3:end) = cellfun(@num2str, num2cell([fitpar PDAMeta.chi2(i)]),'Uniformoutput',false);
    end
else
    %% Global fitting
    %%% Sets initial value and bounds for global parameters
    % PDAMeta.Global    = 1     x 15 logical
    % PDAMeta.Fixed     = files x 15 logical
    % PDAMeta.FitParams = files x 15 double
    % PDAMeta.UB/LB     = 1     x 15 double
    
    %%% If sigma is fixed at fraction of R, add the parameter here
    if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
        PDAMeta.FitParams(:,end+1) = str2double(h.SettingsTab.SigmaAtFractionOfR_edit.String);
        %%% Set either not fixed and global, or fixed and not global
        PDAMeta.Global(:,end+1) = 1-h.SettingsTab.FixSigmaAtFractionOfR_Fix.Value;
        PDAMeta.Fixed(:,end+1) = h.SettingsTab.FixSigmaAtFractionOfR_Fix.Value;
        PDAMeta.LB(:,end+1) = 0;
        PDAMeta.UB(:,end+1) = 1;
    end 
    
    fitpar = PDAMeta.FitParams(1,PDAMeta.Global);
    LB = PDAMeta.LB(PDAMeta.Global);
    UB = PDAMeta.UB(PDAMeta.Global);
    PDAMeta.hProxGlobal = [];
    for i=find(PDAMeta.Active)'
        %%% Concatenates y data of all active datasets
        PDAMeta.hProxGlobal = [PDAMeta.hProxGlobal PDAMeta.hProx{i}];
        %%% Concatenates initial values and bounds for non fixed parameters
        fitpar = [fitpar PDAMeta.FitParams(i, ~PDAMeta.Fixed(i,:)& ~PDAMeta.Global)];
        LB=[LB PDAMeta.LB(~PDAMeta.Fixed(i,:) & ~PDAMeta.Global)];
        UB=[UB PDAMeta.UB(~PDAMeta.Fixed(i,:) & ~PDAMeta.Global)];
    end

    %% Check if View_Curve was pressed
    if obj == h.Menu.ViewFit
         %%% Only Update Plot and break
        Progress((i-1)/sum(PDAMeta.Active),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Simulating Histograms...');
        Progress((i-1)/sum(PDAMeta.Active),h.SingleTab.Progress.Axes,h.AllTab.Progress.Text,'Simulating Histograms...');
        switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
            case {'MLE','MonteCarlo'}
                %%% For Updating the Result Plot, use MC sampling
                PDAMonteCarloFit_Global(fitpar);
            case 'Histogram Library'
                PDAHistogramFit_Global(fitpar);
        end
    else
        %% Do Fit
        switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
            case 'Histogram Library'
                fitfun = @(x) PDAHistogramFit_Global(x);
            case 'MLE'
                fitfun = @(x) PDAMLEFit_Global(x);
            otherwise
                msgbox('Use Histogram Library, others dont work yet for global')
                return
        end
        switch h.SettingsTab.FitMethod_Popupmenu.String{h.SettingsTab.FitMethod_Popupmenu.Value}
            case 'Simplex'
                fitopts = optimset('MaxFunEvals', 1E4,'Display','iter','TolFun',1E-6,'TolX',1E-3);%,'PlotFcns',@optimplotfvalPDA);
                fitpar = fminsearchbnd(fitfun, fitpar, LB, UB, fitopts);
            case 'Gradient-Based'
                fitopts = optimoptions('fmincon','MaxFunEvals',1E4,'Display','iter');%,'PlotFcns',@optimplotfvalPDA);
                fitpar = fmincon(fitfun, fitpar,[],[],[],[],LB,UB,[],fitopts);
            case 'Patternsearch'
                opts = psoptimset('Cache','on','Display','iter','PlotFcns',@psplotbestf);%,'UseParallel','always');
                fitpar = patternsearch(fitfun, fitpar, [],[],[],[],LB,UB,[],opts);
            case 'Gradient-Based (global)'
                opts = optimoptions(@fmincon,'Algorithm','interior-point','Display','iter');%,'PlotFcns',@optimplotfvalPDA);
                problem = createOptimProblem('fmincon','objective',fitfun,'x0',fitpar,'Aeq',[],'beq',[],'lb',LB,'ub',UB,'options',opts);
                gs = GlobalSearch;
                fitpar = run(gs,problem);
        end
        
        %Calculate chi^2
        switch h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value}
            case 'Histogram Library'
                %PDAMeta.chi2 = PDAHistogramFit_Single(fitpar);
            case 'MLE'
                %%% For Updating the Result Plot, use MC sampling
                PDAMeta.FitInProgress = 1;
                PDAMonteCarloFit_Global(fitpar);
                PDAMeta.FitInProgress = 0;
                if isfield(PDAMeta,'Last_logL')
                    PDAMeta = rmfield(PDAMeta,'Last_logL');
                end
            case 'MonteCarlo'
                %PDAMeta.chi2 = PDAMonteCarloFit_Single(fitpar);
            otherwise
                PDAMeta.chi2 = 0;
        end
        

        %%% Sort optimized fit parameters back into table
        PDAMeta.FitParams(:,PDAMeta.Global)=repmat(fitpar(1:sum(PDAMeta.Global)),[size(PDAMeta.FitParams,1) 1]) ;
        fitpar(1:sum(PDAMeta.Global))=[];
        for i=find(PDAMeta.Active)'
            PDAMeta.FitParams(i, ~PDAMeta.Fixed(i,:) & ~PDAMeta.Global) = fitpar(1:sum(~PDAMeta.Fixed(i,:) & ~PDAMeta.Global));
            fitpar(1:sum(~PDAMeta.Fixed(i,:)& ~PDAMeta.Global))=[];
        end
        
        %%% If sigma was fixed at fraction of R, update edit box here and
        %%% remove from fitpar array
        %%% if sigma is fixed at fraction of, read value here before reshape
        if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
             fraction = PDAMeta.FitParams(1,end);
             h.SettingsTab.SigmaAtFractionOfR_edit.String = num2str(fraction);
             PDAMeta.FitParams(:,end) = [];
             PDAMeta.Global(:,end) = [];
             PDAMeta.Fixed(:,end) = [];
        end
        
        for i = find(PDAMeta.Active)'
            %%% if sigma is fixed at fraction of, change its value here
            if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
                PDAMeta.FitParams(i,3:3:end) = fraction.*PDAMeta.FitParams(i,2:3:end);
            end
            % Convert amplitudes to fractions
            PDAMeta.FitParams(i,3*PDAMeta.Comp{i}-2) = PDAMeta.FitParams(i,3*PDAMeta.Comp{i}-2)./sum(PDAMeta.FitParams(i,1:3:end));
            h.FitTab.Table.Data(i,2:3:end) = cellfun(@num2str,num2cell([PDAMeta.FitParams(i,:) PDAMeta.chi2(i)]),'UniformOutput',false);
        end
    end
end
Progress(1, h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Done');
Progress(1, h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Done');
Update_Plots([],[],1)
%%% re-enable Fit Menu
h.Menu.Fit.Enable = 'on';
PDAMeta.FitInProgress = 0;

% File menu - stop fitting
function Stop_PDA_Fit(~,~)
global PDAMeta
h = guidata(findobj('Tag','GlobalPDAFit'));
PDAMeta.FitInProgress = 0;
h.FitTab.Table.Enable = 'on';

% model for normal histogram library fitting (not global)
function [chi2] = PDAHistogramFit_Single(fitpar)
global PDAMeta PDAData
h = guidata(findobj('Tag','GlobalPDAFit'));
i = PDAMeta.file;

%%% Aborts Fit
drawnow;
if ~PDAMeta.FitInProgress
    chi2 = 0;
    return;
end

%%% if sigma is fixed at fraction of, change its value here, and remove the
%%% amplitude fit parameter so it does not mess up further uses of fitpar
if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
    fraction = fitpar(end); fitpar(end) = [];
    fitpar(3:3:end) = fraction.*fitpar(2:3:end);
end

%%% normalize Amplitudes
fitpar(3*PDAMeta.Comp{i}-2) = fitpar(3*PDAMeta.Comp{i}-2)./sum(fitpar(3*PDAMeta.Comp{i}-2));

%%% create individual histograms
hFit_Ind = cell(5,1);
for c = PDAMeta.Comp{i}
    if h.SettingsTab.Use_Brightness_Corr.Value
        %%% If brightness correction is to be performed, determine the relative
        %%% brightness based on current distance and correction factors
        Qr = calc_relative_brightness(fitpar(3*c-1),i);
        %%% Rescale the PN;
        PN_scaled = scalePN(PDAData.BrightnessReference.PN,Qr);  
        %%% fit PN_scaled to match PN of file
        PN_scaled = PN_scaled(1:numel(PDAMeta.PN{i}));
        PN_scaled = PN_scaled./sum(PN_scaled).*sum(PDAMeta.PN{i});
        %%% Recalculate the P array of this file
        PDAMeta.P(i,:) = recalculate_P(PN_scaled,i);
    end
    [Pe] = Generate_P_of_eps(fitpar(3*c-1), fitpar(3*c), i);
    P_eps = fitpar(3*c-2).*Pe;
    hFit_Ind{c} = zeros(str2double(h.SettingsTab.NumberOfBins_Edit.String),1);
    for k = 1:str2double(h.SettingsTab.NumberOfBinsE_Edit.String)+1
        hFit_Ind{c} = hFit_Ind{c} + P_eps(k).*PDAMeta.P{i,k};
    end
end
hFit = sum(horzcat(hFit_Ind{:}),2)';

%%% Calculate Chi2
error = sqrt(PDAMeta.hProx{i});
error(error == 0) = 1;
w_res = (PDAMeta.hProx{i}-hFit)./error;
if ~h.SettingsTab.OuterBins_Fix.Value
    chi2 = sum((w_res.^2))/(str2double(h.SettingsTab.NumberOfBins_Edit.String)-sum(~PDAMeta.Fixed(i,:))-1);
else
    chi2 = sum(((w_res(2:end-1)).^2))/(str2double(h.SettingsTab.NumberOfBins_Edit.String)-sum(~PDAMeta.Fixed(i,:))-1);
    w_res(1) = 0;
    w_res(end) = 0;
end
PDAMeta.w_res{i} = w_res;
PDAMeta.hFit{i} = hFit;
PDAMeta.chi2(i) = chi2;
for c = PDAMeta.Comp{i};
    PDAMeta.hFit_Ind{i,c} = hFit_Ind{c};
end
set(PDAMeta.Chi2_All, 'Visible','on','String', ['\chi^2_{red.} = ' sprintf('%1.2f',chi2)]);
set(PDAMeta.Chi2_Single, 'Visible', 'on','String', ['\chi^2_{red.} = ' sprintf('%1.2f',chi2)]);

if h.SettingsTab.LiveUpdate.Value
    Update_Plots([],[],5)
end
tex = ['Fitting Histogram ' num2str(i) ' of ' num2str(sum(PDAMeta.Active))];
Progress(1/chi2, h.AllTab.Progress.Axes, h.AllTab.Progress.Text, tex);
Progress(1/chi2, h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text, tex);

% model for normal histogram library fitting (global)
function [mean_chi2] = PDAHistogramFit_Global(fitpar)
global PDAMeta
h = guidata(findobj('Tag','GlobalPDAFit'));

%%% Aborts Fit
drawnow;
if ~PDAMeta.FitInProgress
    mean_chi2 = 0;
    return;
end


FitParams = PDAMeta.FitParams;
Global = PDAMeta.Global;
Fixed = PDAMeta.Fixed;

% define degrees of freedom here since we will loose fitpar
DOF = numel(fitpar);

P=zeros(numel(Global),1);

%%% Assigns global parameters
P(Global)=fitpar(1:sum(Global));
fitpar(1:sum(Global))=[];
    
for i=find(PDAMeta.Active)'
    PDAMeta.file = i;
    %%% Sets non-fixed parameters
    P(~Fixed(i,:) & ~Global)=fitpar(1:sum(~Fixed(i,:) & ~Global));
    fitpar(1:sum(~Fixed(i,:)& ~Global))=[];
    %%% Sets fixed parameters
    P(Fixed(i,:) & ~Global) = FitParams(i, (Fixed(i,:) & ~Global));
    %%% Calculates function for current file
    
    %%% normalize Amplitudes
    P(3*PDAMeta.Comp{i}-2) = P(3*PDAMeta.Comp{i}-2)./sum(P(3*PDAMeta.Comp{i}-2));
    
    %%% if sigma is fixed at fraction of, change its value here
    if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
        P(3:3:end) = P(end).*P(2:3:end);
    end

    %%% create individual histograms
    hFit_Ind = cell(5,1);
    for c = PDAMeta.Comp{i}
        [Pe] = Generate_P_of_eps(P(3*c-1), P(3*c), i);
        P_eps = P(3*c-2).*Pe;
        hFit_Ind{c} = zeros(str2double(h.SettingsTab.NumberOfBins_Edit.String),1);
        for k = 1:str2double(h.SettingsTab.NumberOfBinsE_Edit.String)+1
            hFit_Ind{c} = hFit_Ind{c} + P_eps(k).*PDAMeta.P{i,k};
        end
    end
    hFit = sum(horzcat(hFit_Ind{:}),2)';
    
    %%% Calculate Chi2
    error = sqrt(PDAMeta.hProx{i});
    error(error == 0) = 1;
    PDAMeta.w_res{i} = (PDAMeta.hProx{i}-hFit)./error;
    PDAMeta.hFit{i} = hFit;
    if ~h.SettingsTab.OuterBins_Fix.Value
        PDAMeta.chi2(i) = sum(((PDAMeta.w_res{i}).^2))/(str2double(h.SettingsTab.NumberOfBins_Edit.String)-DOF-1);
    else
        % disregard last bins
        PDAMeta.chi2(i) = sum(((PDAMeta.w_res{i}(2:end-1)).^2))/(str2double(h.SettingsTab.NumberOfBins_Edit.String)-2-DOF-1);
        PDAMeta.w_res{i}(1) = 0;
        PDAMeta.w_res{i}(end) = 0;
    end
    if i == h.SingleTab.Popup.Value
        set(PDAMeta.Chi2_Single, 'Visible', 'on','String', ['\chi^2_{red.} = ' sprintf('%1.2f',PDAMeta.chi2(i))]);
    end
    for c = PDAMeta.Comp{i};
        PDAMeta.hFit_Ind{i,c} = hFit_Ind{c};
    end
    if h.SettingsTab.LiveUpdate.Value
        Update_Plots([],[],5)
    end 
end
mean_chi2 = mean(PDAMeta.chi2);
Progress(1/mean_chi2, h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Fitting Histograms...');
Progress(1/mean_chi2, h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Fitting Histograms...');
set(PDAMeta.Chi2_All, 'Visible','on','String', ['avg. \chi^2_{red.} = ' sprintf('%1.2f',mean_chi2)]);

% function that generates Equation 10 from Antonik 2006 J Phys Chem B
function [Pe] = Generate_P_of_eps(RDA, sigma, i)
global PDAMeta
eps = PDAMeta.epsEgrid{i};
if PDAMeta.directexc(i) == 0
    % generate gaussian distributions of PDA.epsilon weights
    % Eq 10 in Antonik 2006 c Phys Chem B
    Pe = PDAMeta.R0(i)/(6*sqrt(2*pi)*sigma)*...
        (PDAMeta.gamma(i))^(1/6)*...
        1./(1-eps).^2 .* ...
        (1./(1-eps) - (1+PDAMeta.crosstalk(i))).^(-7/6) .* ...
        exp(...
        -1/(2*sigma^2)*...
        (PDAMeta.R0(i).*...
        (PDAMeta.gamma(i))^(1/6).*...
        (1./(1-eps)-(1+PDAMeta.crosstalk(i))).^(-1/6)- ...
        RDA).^2);
elseif PDAMeta.directexc(i) ~= 0
    dRdeps = -((PDAMeta.R0(i)^6*PDAMeta.gamma(i))./(PDAMeta.crosstalk(i)...
        - eps - PDAMeta.crosstalk(i)*PDAMeta.directexc(i) - PDAMeta.crosstalk(i)*eps...
        + PDAMeta.directexc(i)*eps + PDAMeta.directexc(i)*PDAMeta.gamma(i)...
        + PDAMeta.crosstalk(i)*PDAMeta.directexc(i)*eps - PDAMeta.directexc(i)*eps*PDAMeta.gamma(i))...
        - ((PDAMeta.R0(i)^6*PDAMeta.gamma(i) - PDAMeta.R0(i)^6*eps*PDAMeta.gamma(i))*(PDAMeta.crosstalk(i)...
        - PDAMeta.directexc(i) - PDAMeta.crosstalk(i)*PDAMeta.directexc(i) + PDAMeta.directexc(i)*PDAMeta.gamma(i) + 1))./...
        (PDAMeta.crosstalk(i) - eps - PDAMeta.crosstalk(i)*PDAMeta.directexc(i)...
        - PDAMeta.crosstalk(i)*eps + PDAMeta.directexc(i)*eps + PDAMeta.directexc(i)*PDAMeta.gamma(i)...
        + PDAMeta.crosstalk(i)*PDAMeta.directexc(i)*eps - PDAMeta.directexc(i)*eps*PDAMeta.gamma(i)).^2)./...
        (6*(-(PDAMeta.R0(i)^6*PDAMeta.gamma(i) - PDAMeta.R0(i)^6*eps*PDAMeta.gamma(i))./(PDAMeta.crosstalk(i)...
        - eps - PDAMeta.crosstalk(i)*PDAMeta.directexc(i) - PDAMeta.crosstalk(i)*eps + PDAMeta.directexc(i)*eps...
        + PDAMeta.directexc(i)*PDAMeta.gamma(i) + PDAMeta.crosstalk(i)*PDAMeta.directexc(i)*eps -...
        PDAMeta.directexc(i)*eps*PDAMeta.gamma(i))).^(5/6));
    P_Rofeps = (1/(sqrt(2*pi)*sigma)).*...
        exp(-(RDA - (-(PDAMeta.R0(i)^6*PDAMeta.gamma(i) - PDAMeta.R0(i)^6*eps*PDAMeta.gamma(i))./...
        (PDAMeta.crosstalk(i) - eps - PDAMeta.crosstalk(i)*PDAMeta.directexc(i) - PDAMeta.crosstalk(i)*eps...
        + PDAMeta.directexc(i)*eps + PDAMeta.directexc(i)*PDAMeta.gamma(i) +...
        PDAMeta.crosstalk(i)*PDAMeta.directexc(i)*eps - PDAMeta.directexc(i)*eps*PDAMeta.gamma(i))).^(1/6)).^2./(2*sigma^2));
    Pe = dRdeps.*P_Rofeps;
end
Pe(~isfinite(Pe)) = 0;
Pe = Pe./sum(Pe);

% model for MLE fitting (not global)
function logL = PDA_MLE_Fit_Single(fitpar)
global PDAMeta PDAData

%%% Aborts Fit
drawnow;
if ~PDAMeta.FitInProgress
    logL = 0;
    return;
end

h = guidata(findobj('Tag','GlobalPDAFit'));

%%% if sigma is fixed at fraction of, read value here before reshape
if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
    fraction = fitpar(end);fitpar(end) = [];
end

fitpar = reshape(fitpar',[3,numel(fitpar)/3]); fitpar = fitpar';

%%% if sigma is fixed at fraction of, change its value here
if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
    fitpar(:,3) = fraction.*fitpar(:,2);
end

file = PDAMeta.file;
% Parameters
cr = PDAMeta.crosstalk(file);
R0 = PDAMeta.R0(file);
de = PDAMeta.directexc(file);
gamma = PDAMeta.gamma(file);

if h.SettingsTab.Use_Brightness_Corr.Value
        %%% If brightness correction is to be performed, determine the relative
        %%% brightness based on current distance and correction factors
        PN_scaled = cell(5,1);
        for c = PDAMeta.Comp{file}
            Qr = calc_relative_brightness(fitpar(c,2),file);
            %%% Rescale the PN;
            PN_scaled{c} = scalePN(PDAData.BrightnessReference.PN,Qr);
            PN_scaled{c} = smooth(PN_scaled{c},10);
            PN_scaled{c} = PN_scaled{c}./sum(PN_scaled{c});
        end
        %%% calculate the relative probabilty
        P_norm = sum(horzcat(PN_scaled{:}),2);
        for c = PDAMeta.Comp{file}
            PN_scaled{c}(P_norm~=0) = PN_scaled{c}(P_norm~=0)./P_norm(P_norm~=0);
            %%% We don't want zero probabilities here!
            PN_scaled{c}(PN_scaled{c} == 0) = eps;
        end
end
    
steps = 5;
L = cell(5,1); %%% Likelihood per Gauss
for j = PDAMeta.Comp{file}
    %%% define Gaussian distribution of distances
    xR = (fitpar(j,2)-3*fitpar(j,3)):(6*fitpar(j,3)/steps):(fitpar(j,2)+3*fitpar(j,3));
    PR = normpdf(xR,fitpar(j,2),fitpar(j,3));
    PR = PR'./sum(PR);
    %%% Calculate E values for R grid
    E = 1./(1+(xR./R0).^6);
    epsGR = 1-(1+cr+(((de/(1-de)) + E) * gamma)./(1-E)).^(-1);
    
    %%% Calculate the vector of likelihood values
    P = eval_prob_2c_bg(PDAData.Data{file}.NG,PDAData.Data{file}.NF,...
        PDAMeta.NBG{file},PDAMeta.NBR{file},...
        PDAMeta.PBG{file}',PDAMeta.PBR{file}',...
        epsGR');
    P = log(P) + repmat(log(PR'),numel(PDAData.Data{file}.NG),1);
    Lmax = max(P,[],2);
    P = Lmax + log(sum(exp(P-repmat(Lmax,1,numel(PR))),2));
    
    if h.SettingsTab.Use_Brightness_Corr.Value
        %%% Add Brightness Correction Probabilty here
        P = P + log(PN_scaled{j}(PDAData.Data{file}.NG + PDAData.Data{file}.NF));
    end
    %%% Treat case when all burst produced zero probability
    P(isnan(P)) = -Inf;
    L{j} = P;
end

%%% normalize amplitudes
fitpar(PDAMeta.Comp{file},1) = fitpar(PDAMeta.Comp{file},1)./sum(fitpar(PDAMeta.Comp{file},1));
PA = fitpar(PDAMeta.Comp{file},1);


L = horzcat(L{:});
L = L + repmat(log(PA'),numel(PDAData.Data{file}.NG),1);
Lmax = max(L,[],2);
L = Lmax + log(sum(exp(L-repmat(Lmax,1,numel(PA))),2));
%%% P_res has NaN values if Lmax was -Inf (i.e. total of zero probability)!
%%% Reset these values to -Inf
L(isnan(L)) = -Inf;
logL = sum(L);
%%% since the algorithm minimizes, it is important to minimize the negative
%%% log likelihood, i.e. maximize the likelihood
logL = -logL;

% model for MLE fitting (global)
function [mean_logL] = PDAMLEFit_Global(fitpar)
global PDAMeta
h = guidata(findobj('Tag','GlobalPDAFit'));

%%% Aborts Fit
drawnow;
if ~PDAMeta.FitInProgress
    mean_logL = 0;
    return;
end


FitParams = PDAMeta.FitParams;
Global = PDAMeta.Global;
Fixed = PDAMeta.Fixed;
% define degrees of freedom here since we will loose fitpar
DOF = numel(fitpar);

P=zeros(numel(Global),1);

%%% Assigns global parameters
P(Global)=fitpar(1:sum(Global));
fitpar(1:sum(Global))=[];

for i=find(PDAMeta.Active)'
    PDAMeta.file = i;
    %%% Sets non-fixed parameters
    P(~Fixed(i,:) & ~Global)=fitpar(1:sum(~Fixed(i,:) & ~Global));
    fitpar(1:sum(~Fixed(i,:)& ~Global))=[];
    %%% Sets fixed parameters
    P(Fixed(i,:) & ~Global) = FitParams(i, (Fixed(i,:) & ~Global));
    
    %%% normalize Amplitudes
    P(3*PDAMeta.Comp{i}-2) = P(3*PDAMeta.Comp{i}-2)./sum(P(1:3:end));
    
    %%% calculate individual likelihoods
    PDAMeta.chi2(i) = PDA_MLE_Fit_Single(P);   
end
mean_logL = mean(PDAMeta.chi2);

%%% if second iteration or more, update Progress Bar
if isfield(PDAMeta,'Last_logL')
    progress = exp(mean_logL-PDAMeta.Last_logL);
    if progress > 1
        progress = 0.99;
    end
    Progress(progress, h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Fitting Histograms...');
    Progress(progress, h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Fitting Histograms...');
end
set(PDAMeta.Chi2_All, 'Visible','on','String', ['avg. logL = ' sprintf('%1.2f',mean_logL)]);
%%% store logL in PDAMeta
PDAMeta.Last_logL = mean_logL;

% Model for Monte Carle based fitting (not global) 
function [chi2] = PDAMonteCarloFit_Single(fitpar)
global PDAMeta PDAData
h = guidata(findobj('Tag','GlobalPDAFit'));

%%% Aborts Fit
drawnow;
if ~PDAMeta.FitInProgress
    if ~strcmp(h.SettingsTab.PDAMethod_Popupmenu.String{h.SettingsTab.PDAMethod_Popupmenu.Value},'MLE')
        chi2 = 0;
        return;
    end
    %%% else continue
end

file = PDAMeta.file;

%%% if sigma is fixed at fraction of, read value here before reshape
if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
    fraction = fitpar(end);fitpar(end) = [];
end
%%% fitpar vector is linearized by fminsearch, restructure
fitpar = reshape(fitpar',[3,numel(fitpar)/3]); fitpar = fitpar';

%%% normalize Amplitudes
fitpar(PDAMeta.Comp{file},1) = fitpar(PDAMeta.Comp{file},1)./sum(fitpar(PDAMeta.Comp{file},1));
A = fitpar(:,1);

%%% if sigma is fixed at fraction of, change its value here
if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1
    fitpar(:,3) = fraction.*fitpar(:,2);
end

%Parameters
mBG_gg = PDAMeta.BGdonor(file);
mBG_gr = PDAMeta.BGacc(file);
dur = PDAData.timebin(file)*1E3;
cr = PDAMeta.crosstalk(file);
R0 = PDAMeta.R0(file);
de = PDAMeta.directexc(file);
gamma = PDAMeta.gamma(file);
Nobins = str2double(h.SettingsTab.NumberOfBins_Edit.String);
sampling =str2double(h.SettingsTab.OverSampling_Edit.String);

if h.SettingsTab.Use_Brightness_Corr.Value
        %%% If brightness correction is to be performed, determine the relative
        %%% brightness based on current distance and correction factors
        BSD_scaled = cell(5,1);
        for c = PDAMeta.Comp{file}
            Qr = calc_relative_brightness(fitpar(c,2),file);
            %%% Rescale the PN;
            PN_scaled = scalePN(PDAData.BrightnessReference.PN,Qr);
            %%% fit PN_scaled to match PN of file
            PN_scaled = PN_scaled(1:numel(PDAMeta.PN{file}));
            PN_scaled = PN_scaled./sum(PN_scaled).*sum(PDAMeta.PN{file});
            
            PN_scaled = ceil(PN_scaled); % round to integer
            BSD_scaled{c} = zeros(sum(PN_scaled),1);
            count = 0;
            for i = 1:numel(PN_scaled)
                BSD_scaled{c}(count+1:count+PN_scaled(i)) = i;
                count = count+PN_scaled(i);
            end
            %%% BSD_scaled contains too many bursts now, remove randomly
            BSD_scaled{c} = BSD_scaled{c}(randperm(numel(BSD_scaled{c})));
            BSD_scaled{c} = BSD_scaled{c}(1:numel(PDAMeta.BSD{file}));
        end  
end

BSD = PDAMeta.BSD{file};
H_meas = PDAMeta.hProx{file}';
%pool = gcp;
%sampling = pool.NumWorkers;
PRH = cell(sampling,5);
for j = PDAMeta.Comp{file}
    if h.SettingsTab.Use_Brightness_Corr.Value
        BSD = BSD_scaled{j};
    end
    for k = 1:sampling
        r = normrnd(fitpar(j,2),fitpar(j,3),numel(BSD),1);
        E = 1./(1+(r./R0).^6);
        eps = 1-(1+cr+(((de/(1-de)) + E) * gamma)./(1-E)).^(-1);
        BG_gg = poissrnd(mBG_gg.*dur,numel(BSD),1);
        BG_gr = poissrnd(mBG_gr.*dur,numel(BSD),1);
        BSD_bg = BSD-BG_gg-BG_gr;
        PRH{k,j} = (binornd(BSD_bg,eps)+BG_gr)./BSD;
    end
end
H_res_dummy = zeros(numel(PDAMeta.hProx{file}),5);
for j = PDAMeta.Comp{file}
    H_res_dummy(:,j) = histcounts(vertcat(PRH{:,j}),linspace(0,1,Nobins+1));
end
hFit = zeros(numel(PDAMeta.hProx{file}),1);
for j = PDAMeta.Comp{file}
    hFit = hFit + A(j).*H_res_dummy(:,j);
end
hFit = sum(H_meas)*hFit./sum(hFit);
%calculate chi2
error = sqrt(H_meas);
error(error == 0) = 1;
w_res = (H_meas-hFit)./error;
chi2 = sum((w_res.^2))/(Nobins-numel(fitpar)-1);
hFit_Ind = cell(5,1);
for j = PDAMeta.Comp{file}
    hFit_Ind{j} = sum(H_meas).*A(j).*H_res_dummy(:,j)./sum(H_res_dummy(:,1));
end

PDAMeta.w_res{file} = w_res;
PDAMeta.hFit{file} = hFit;
PDAMeta.chi2(file) = chi2;
for c = PDAMeta.Comp{file};
    PDAMeta.hFit_Ind{file,c} = hFit_Ind{c};
end
set(PDAMeta.Chi2_All, 'Visible','on','String', ['\chi^2_{red.} = ' sprintf('%1.2f',chi2)]);
set(PDAMeta.Chi2_Single, 'Visible', 'on','String', ['\chi^2_{red.} = ' sprintf('%1.2f',chi2)]);

if h.SettingsTab.LiveUpdate.Value
    Update_Plots([],[],5)
end
tex = ['Fitting Histogram ' num2str(file) ' of ' num2str(sum(PDAMeta.Active))];
Progress(1/chi2, h.AllTab.Progress.Axes, h.AllTab.Progress.Text, tex);
Progress(1/chi2, h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text, tex);

% Model for Monte Carle based fitting (global) 
function [mean_chi2] = PDAMonteCarloFit_Global(fitpar)
global PDAMeta
h = guidata(findobj('Tag','GlobalPDAFit'));

%%% Aborts Fit
drawnow;
if ~PDAMeta.FitInProgress
    mean_chi2 = 0;
    return;
end

FitParams = PDAMeta.FitParams;
Global = PDAMeta.Global;
Fixed = PDAMeta.Fixed;
% define degrees of freedom here since we will loose fitpar
DOF = numel(fitpar);

P=zeros(numel(Global),1);

%%% Assigns global parameters
P(Global)=fitpar(1:sum(Global));
fitpar(1:sum(Global))=[];

for i=find(PDAMeta.Active)'
    PDAMeta.file = i;
    %%% Sets non-fixed parameters
    P(~Fixed(i,:) & ~Global)=fitpar(1:sum(~Fixed(i,:) & ~Global));
    fitpar(1:sum(~Fixed(i,:)& ~Global))=[];
    %%% Sets fixed parameters
    P(Fixed(i,:) & ~Global) = FitParams(i, (Fixed(i,:) & ~Global));
    %%% Calculates function for current file
    
    %%% normalize Amplitudes
    P(3*PDAMeta.Comp{i}-2) = P(3*PDAMeta.Comp{i}-2)./sum(P(1:3:end));

    %%% create individual histograms
    [PDAMeta.chi2(i)] = PDAMonteCarloFit_Single(P);
end
mean_chi2 = mean(PDAMeta.chi2);
Progress(1/mean_chi2, h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Fitting Histograms...');
Progress(1/mean_chi2, h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Fitting Histograms...');
set(PDAMeta.Chi2_All, 'Visible','on','String', ['avg. \chi^2_{red.} = ' sprintf('%1.2f',mean_chi2)]);

% Function to export the figures
function Export_Figure(~,~)
global PDAData UserValues
h = guidata(findobj('Tag','GlobalPDAFit'));

% use uiputfile to generate a folder name in a specified location
[File, Path] = uiputfile({'*.*', 'Folder name'},...
    'Specify directory name',...
    fullfile(UserValues.File.BurstBrowserPath, [datestr(now,'yymmdd') ' GlobalPDAFit']));
Path = GenerateName(fullfile(Path, File),2);

if isempty(File)
    return
else
    clear File
    for i = 1:(numel(PDAData.FileName)+1)
        fig = figure('Position',[100 ,100 ,900, 425],...
            'Color',[1 1 1],...
            'Resize','off');
        if i == 1 %generate figure for All Tab
            main_ax = copyobj(h.AllTab.Main_Axes,fig);
            res_ax = copyobj(h.AllTab.Res_Axes,fig);
            gauss_ax = copyobj(h.AllTab.Gauss_Axes,fig);
        else %generate figure per Single Tab plot
            h.SingleTab.Popup.Value = i-1;
            Update_Plots([],[],2)
            main_ax = copyobj(h.SingleTab.Main_Axes,fig);
            res_ax = copyobj(h.SingleTab.Res_Axes,fig);
            gauss_ax = copyobj(h.SingleTab.Gauss_Axes,fig);
        end
        main_ax.Children(end).Position = [1.3,1.09];
        %main_ax.Children(end).String = main_ax.Children(1:end-1);
        %main_ax.Children(end).String = ''; 
        main_ax.Color = [1 1 1];
        res_ax.Color = [1 1 1];
        main_ax.XColor = [0 0 0];
        main_ax.YColor = [0 0 0];
        res_ax.XColor = [0 0 0];
        res_ax.YColor = [0 0 0];
        main_ax.XLabel.Color = [0 0 0];
        main_ax.YLabel.Color = [0 0 0];
        res_ax.XLabel.Color = [0 0 0];
        res_ax.YLabel.Color = [0 0 0];
        main_ax.Units = 'pixel';
        res_ax.Units = 'pixel';
        main_ax.Position = [75 70 475 290];
        res_ax.Position = [75 360 475 50];
        main_ax.YTickLabel = main_ax.YTickLabel(1:end-1);
        
        gauss_ax.Color = [1 1 1];
        gauss_ax.XColor = [0 0 0];
        gauss_ax.YColor = [0 0 0];
        gauss_ax.XLabel.Color = [0 0 0];
        gauss_ax.YLabel.Color = [0 0 0];
        gauss_ax.Units = 'pixel';
        gauss_ax.Position = [650 70 225 290];
        gauss_ax.GridAlpha = 0.1;
        res_ax.GridAlpha = 0.1;
        gauss_ax.FontSize = 15;
        %set(fig,'PaperPositionMode','auto');
        if i == 1
            print(fig,'-dtiff','-r150',GenerateName(fullfile(Path, 'All.tif'),1))
        else
            print(fig,'-dtiff','-r150',GenerateName(fullfile(Path, [PDAData.FileName{i-1}(1:end-4) '.tif']),1))
        end
        close(fig)
    end
end

% Update the Fit Tab
function Update_FitTable(~,e,mode)
h = guidata(findobj('Tag','GlobalPDAFit'));
global PDAMeta PDAData
switch mode
    case 0 %%% Updates whole table (Open UI)
        %%% Disables cell callbacks, to prohibit double callback
        h.FitTab.Table.CellEditCallback=[];
        %%% Column names & widths
        Columns=cell(47,1);
        Columns{1}='Active';
        for i=1:5
            Columns{9*i-7}=['<HTML><b> Amp' num2str(i) '</b>'];
            Columns{9*i-6}='F';
            Columns{9*i-5}='G';
            Columns{9*i-4}=['<HTML><b> RDA' num2str(i) ' [A] </b>'];
            Columns{9*i-3}='F';
            Columns{9*i-2}='G';
            Columns{9*i-1}=['<HTML><b> sigDA' num2str(i) ' [A] </b>'];
            Columns{9*i}='F';
            Columns{9*i+1}='G';
        end
        Columns{end}='chi2';
        ColumnWidth=zeros(numel(Columns),1);
        ColumnWidth(2:3:end-3)=70;
        ColumnWidth(3:3:end-2)=20;
        ColumnWidth(4:3:end-1)=20;
        ColumnWidth(1)=40;
        ColumnWidth(end)=60;
        h.FitTab.Table.ColumnName=Columns;
        h.FitTab.Table.ColumnWidth=num2cell(ColumnWidth');
        %%% Sets row names to file names
        Rows=cell(numel(PDAData.Data)+3,1);
        Rows(1:numel(PDAData.Data))=deal(PDAData.FileName);
        Rows{end-2}='ALL';
        Rows{end-1}='Lower bound';
        Rows{end}='Upper bound';
        h.FitTab.Table.RowName=Rows;
        
        %%% Create table data:
        %%% 1           = Active
        %%% 2:3:end-3   = Parameter value
        %%% 3:3:end-2   = Checkbox to fix parameter
        %%% 4:3:end-1   = Checkbox to fit parameter globally
        %%% 47          = chi^2
        Data=num2cell(zeros(numel(Rows),numel(Columns)));
        % put in data if it exists
        %Data(1:end-3,9:3:end)=deal(num2cell(PDAData.FitTable)');
        % fill in the all row
        tmp = [1; 50; 5; 1; 50; 5; 0; 50; 5; 0; 50; 5; 0; 50; 5];
        Data(end-2,2:3:end-3)=deal(num2cell(tmp)');
        % fill in boundaries
        Data(end-1,2:3:end)=deal({0});
        Data(end,2:3:end)=deal({inf});
        Data=cellfun(@num2str,Data,'UniformOutput',false);
        % active checkbox
        Data(:,1)=deal({true});
        Data(2:end,1)=deal({[]});
        % fix checkboxes
        Data(1,3:3:end)=deal({false});
        Data(2:end,3:3:end)=deal({[]});
        % put the last three gaussians to fixed and zero amplitude
        Data(1,21:3:end)=deal({true});
        Data(1,20:9:end)=deal({'0'});
        % global checkboxes
        Data(1,4:3:end)=deal({false});
        Data(2:end,4:3:end)=deal({[]});
        h.FitTab.Table.Data=Data;
        h.FitTab.Table.ColumnEditable=[true(1,numel(Columns)-1),false];
        %%% Enables cell callback again
        h.FitTab.Table.CellEditCallback={@Update_FitTable,3};
    case 1 %%% Updates tables when new data is loaded
        h.FitTab.Table.CellEditCallback=[];
        %%% Sets row names to file names
        Rows=cell(numel(PDAData.Data)+3,1);
        Rows(1:numel(PDAData.Data))=deal(PDAData.FileName);
        Rows{end-2}='ALL';
        Rows{end-1}='Lower bound';
        Rows{end}='Upper bound';
        h.FitTab.Table.RowName=Rows;
        Data=cell(numel(Rows),size(h.FitTab.Table.Data,2));
        %%% Sets previously loaded files
        Data(1:(size(h.FitTab.Table.Data,1)-3),:)=h.FitTab.Table.Data(1:end-3,:);
        %%% Set last 3 row to ALL, lb and ub
        Data(end-2:end,:)=h.FitTab.Table.Data(end-2:end,:);
        %%% Add FitTable data of new files in between old data and ALL row
        a = size(h.FitTab.Table.Data,1)-2; %if open data had 3 sets, new data has 3+2 sets, then a = 4
        for i = a:(size(Data,1)-3) % i = 4:5
            Data(i,:) = PDAData.FitTable{i};
        end
        for i = 1:15 % all fittable parameters
            if all(cell2mat(Data(1:end-3,3*i+1)))
                % this parameter is global for all files
                % so make the ALL row also global
                Data(end-2,3*i+1) = {true};
                % make the fix checkbox false
                Data(end-2,3*i) = {false};
                % make the ALL row the mean of all values for that parameter
                Data(end-2,3*i-1) = {num2str(mean(cellfun(@str2double,Data(1:end-3,3*i-1))))};
            else
                % this parameter is not global for all files
                % so make it not global for all files
                Data(1:end-2,3*i+1) = {false};
            end
            if all(cell2mat(Data(1:end-3,3*i)))
                % all of the fix checkboxes are true
                % make the ALL fix checkbox true
                Data(end-2,3*i) = {true};
            else
                Data(end-2,3*i) = {false};
            end           
        end
        h.FitTab.Table.Data=Data;
        %%% Enables cell callback again
        h.FitTab.Table.CellEditCallback={@Update_FitTable,3};
        PDAMeta.PreparationDone = 0;
    case 2 %%% Re-loads table from loaded data upon File menu - load fit parameters
        for i = 1:numel(PDAData.FileName)
            h.FitTab.Table.Data(i,:) = PDAData.FitTable{i};
        end
    case 3 %%% Individual cells callbacks
        %%% Disables cell callbacks, to prohibit double callback
        % when user touches the all row, value is applied to all cells
        h.FitTab.Table.CellEditCallback=[];
        if strcmp(e.EventName,'CellSelection') %%% No change in Value, only selected
            if isempty(e.Indices) || (e.Indices(1)~=(size(h.FitTab.Table.Data,1)-2) && e.Indices(2)~=1)
                h.FitTab.Table.CellEditCallback={@Update_FitTable,3};
                return;
            end
            NewData = h.FitTab.Table.Data{e.Indices(1),e.Indices(2)};
        end
        if isprop(e,'NewData')
            NewData = e.NewData;
        end
        if e.Indices(1)==size(h.FitTab.Table.Data,1)-2
            %% ALL row was used => Applies to all files
            h.FitTab.Table.Data(1:end-2,e.Indices(2))=deal({NewData});
            if mod(e.Indices(2)-2,3)==0 && e.Indices(2)>=1
                %% Value was changed => Apply value to global variables
            elseif mod(e.Indices(2)-3,3)==0 && e.Indices(2)>=2 && NewData==1
                %% Value was fixed => Uncheck global
            elseif mod(e.Indices(2)-4,3)==0 && e.Indices(2)>=3 && NewData==1
                %% Global was change
                %%% Apply value to all files
                h.FitTab.Table.Data(1:end-2,e.Indices(2)-2)=h.FitTab.Table.Data(e.Indices(1),e.Indices(2)-2);
                %%% Unfixes all files to prohibit fixed and global
                h.FitTab.Table.Data(1:end-2,e.Indices(2)-1)=deal({false});
            end
        elseif mod(e.Indices(2)-4,3)==0 && e.Indices(2)>=4 && e.Indices(1)<size(h.FitTab.Table.Data,1)-1
            %% Global was changed => Applies to all files
            h.FitTab.Table.Data(1:end-2,e.Indices(2))=deal({NewData});
            if NewData
                %%% Apply value to all files
                h.FitTab.Table.Data(1:end-2,e.Indices(2)-2)=h.FitTab.Table.Data(e.Indices(1),e.Indices(2)-2);
                %%% Unfixes all file to prohibit fixed and global
                h.FitTab.Table.Data(1:end-2,e.Indices(2)-1)=deal({false});
            end
        elseif mod(e.Indices(2)-3,3)==0 && e.Indices(2)>=3 && e.Indices(1)<size(h.FitTab.Table.Data,1)-1
            %% Value was fixed
            %%% Updates ALL row
            if all(cell2mat(h.FitTab.Table.Data(1:end-3,e.Indices(2))))
                h.FitTab.Table.Data{end-2,e.Indices(2)}=true;
            else
                h.FitTab.Table.Data{end-2,e.Indices(2)}=false;
            end
            %%% Unchecks global to prohibit fixed and global
            h.FitTab.Table.Data(1:end-2,e.Indices(2)+1)=deal({false;});
        elseif mod(e.Indices(2)-2,3)==0 && e.Indices(2)>=2 && e.Indices(1)<size(h.FitTab.Table.Data,1)-1
            %% Value was changed
            if h.FitTab.Table.Data{e.Indices(1),e.Indices(2)+2}
                %% Global => changes value of all files
                h.FitTab.Table.Data(1:end-2,e.Indices(2))=deal({NewData});
            else
                %% Not global => only changes value
            end
        elseif e.Indices(2)==1
            %% Active was changed
            PDAMeta.Active(e.Indices(1)) = NewData;
            Update_Plots([],[],4)
        end
        %%% Mirror the table in PDAData.FitTable
        %PDAData.FitTable = h.FitTab.Table.Data(1:end-3,:);
        %%% Enables cell callback again
        h.FitTab.Table.CellEditCallback={@Update_FitTable,3};
        %PDAMeta.PreparationDone = 0;
end

if h.SettingsTab.FixSigmaAtFractionOfR.Value == 1 %%% Fix Sigma at Fraction of R
    %%% Disables cell callbacks, to prohibit double callback
    h.FitTab.Table.CellEditCallback=[];
    %%% Get Table Data
    Data = h.FitTab.Table.Data;
    %%% Read out fraction
    fraction = str2double(h.SettingsTab.SigmaAtFractionOfR_edit.String);
    for i = 1:(size(Data,1)-2)
        %%% Fix all sigmas
        Data(i,9:9:end) = deal({true});
        %%% set to fraction times distance
        Data(i,8:9:end) = cellfun(@(x) num2str(fraction.*str2double(x)),Data(i,5:9:end),'UniformOutput',false);
    end
    %%% Set Table Data
    h.FitTab.Table.Data = Data;
    %%% Enables cell callback again
    h.FitTab.Table.CellEditCallback={@Update_FitTable,3};
end

% Update the Parameters Tab
function Update_ParamTable(~,e,mode)
h = guidata(findobj('Tag','GlobalPDAFit'));
global PDAMeta PDAData
switch mode
    case 0 %%% Updates whole table - when calling GlobalPDAFit
        %%% Disables cell callbacks, to prohibit double callback
        h.ParametersTab.Table.CellEditCallback=[];
        %%% Column names & widths
        Columns=cell(6,1);
        Columns{1}='<HTML> Gamma';
        Columns{2}='<HTML> Direct Exc';
        Columns{3}='<HTML> Crosstalk';
        Columns{4}='<HTML> BGD [kHz]';
        Columns{5}='<HTML> BGA [kHz]';
        Columns{6}='<HTML> R0 [A]';
        ColumnWidth=zeros(numel(Columns),1);
        ColumnWidth(:) = 80;
        h.ParametersTab.Table.ColumnName=Columns;
        h.ParametersTab.Table.ColumnWidth=num2cell(ColumnWidth');
        %%% Sets row names to file names
        %Rows=cell(numel(PDAData.Data)+1,1);
        Rows = cell(1);
        %Rows(1:numel(PDAData.Data))=deal(PDAData.FileName);
        Rows{1}='ALL';
        h.ParametersTab.Table.RowName=Rows;
        %%% Create table data:
        % fill in the all row
        tmp = [1; 0; 0.02; 0; 0; 50];
        Data=deal(num2cell(tmp)');
        %Data=cellfun(@num2str,Data,'UniformOutput',false);
        h.ParametersTab.Table.Data=Data;
        h.ParametersTab.Table.ColumnEditable = true(1,numel(Columns));
    case 1 %%% Updates tables when new data is loaded
        h.ParametersTab.Table.CellEditCallback=[];
        %%% Sets row names to file names
        Rows=cell(numel(PDAData.Data)+1,1);
        Rows(1:numel(PDAData.Data))=deal(PDAData.FileName);
        Rows{end}='ALL';
        h.ParametersTab.Table.RowName=Rows;
        Data = cell(numel(Rows),size(h.ParametersTab.Table.Data,2));
        %%% Sets previous files
        Data(1:(size(h.ParametersTab.Table.Data,1)-1),:) = h.ParametersTab.Table.Data(1:end-1,:);
        %%% Set last row to ALL
        Data(end,:) = h.ParametersTab.Table.Data(end,:);
        %%% Add parameters of new files in between old data and ALL row
        for i = 1:numel(PDAData.FileName)
            tmp(i,1) = PDAData.Corrections{i}.Gamma_GR;
            % direct excitation correction in Burst analysis is NOT the
            % same as PDA, therefore we put it to zero. In PDA, this factor
            % is either the extcoeffA/(extcoeffA+extcoeffD) at donor laser,
            % or the ratio of Int(A)/(Int(A)+Int(D)) for a crosstalk, gamma
            % corrected double labeled molecule having no FRET at all.
            tmp(i,2) = 0; %PDAData.Corrections{i}.DirectExcitation_GR;
            tmp(i,3) = PDAData.Corrections{i}.CrossTalk_GR;
            tmp(i,4) = PDAData.Background{i}.Background_GGpar + PDAData.Background{i}.Background_GGperp;
            tmp(i,5) = PDAData.Background{i}.Background_GRpar + PDAData.Background{i}.Background_GRperp;
            tmp(i,6) = PDAData.Corrections{i}.FoersterRadius;
        end
        Data(size(h.ParametersTab.Table.Data,1):(end-1),:) = num2cell(tmp(size(h.ParametersTab.Table.Data,1):end,:));
        % put the ALL row to the mean of the loaded data 
        Data(end,:) = num2cell(mean(cell2mat(Data(1:end-1,:)),1));
        %%% Adds new files
        h.ParametersTab.Table.Data = Data;
        PDAMeta.PreparationDone = 0;
    case 2 %%% Loading params again from data
        h.ParametersTab.Table.CellEditCallback=[];
        for i = 1:numel(PDAData.FileName)
            tmp(i,1) = PDAData.Corrections{i}.Gamma_GR;
            tmp(i,2) = 0; %see above for explanation! PDAData.Corrections{i}.DirectExcitation_GR;
            tmp(i,3) = PDAData.Corrections{i}.CrossTalk_GR;
            tmp(i,4) = PDAData.Background{i}.Background_GGpar + PDAData.Background{i}.Background_GGperp;
            tmp(i,5) = PDAData.Background{i}.Background_GRpar + PDAData.Background{i}.Background_GRperp;
            tmp(i,6) = PDAData.Corrections{i}.FoersterRadius;
        end
        h.ParametersTab.Table.Data(1:end-1,:) = num2cell(tmp);
        PDAMeta.PreparationDone = 0;
    case 3 %%% Individual cells callbacks
        %%% Disables cell callbacks, to prohibit double callback
        % touching a ALL value cell applies that value everywhere
        h.ParametersTab.Table.CellEditCallback=[];
        if strcmp(e.EventName,'CellSelection') %%% No change in Value, only selected
            if isempty(e.Indices) || (e.Indices(1)~=size(h.ParametersTab.Table.Data,1) && e.Indices(2)~=1)
                h.ParametersTab.Table.CellEditCallback={@Update_ParamTable,3};
                return;
            end
            NewData = h.ParametersTab.Table.Data{e.Indices(1),e.Indices(2)};
        end
        if isprop(e,'NewData')
            NewData = e.NewData;
        end
        if e.Indices(1)==size(h.ParametersTab.Table.Data,1)
            %% ALL row was used => Applies to all files
            h.ParametersTab.Table.Data(:,e.Indices(2))=deal({NewData});
        end
        PDAMeta.PreparationDone = 0;
end

%%% Enables cell callback again
h.ParametersTab.Table.CellEditCallback={@Update_ParamTable,3};

% Function that generates random data when there is nothing to show
function SampleData
global PDAMeta
h = guidata(findobj('Tag','GlobalPDAFit'));

% generate data
% main plot
x = linspace(0,1,51);
y{1} = abs(sum(peaks(51),1));
f{1} = y{1}.*(1 + 0.15*randn(1,51));
r{1} = (y{1}-f{1})./sqrt(y{1});
y{2} = y{1}(end:-1:1);
f{2} = f{1}(end:-1:1);
r{2} = r{1}(end:-1:1);

color = lines(5);
% results plot
gauss_dummy{1} = zeros(5,150*10+1);
for i = 1:5
    gauss_dummy{1}(i,:) = normpdf(0:0.1:150,40+10*i,i);
end

for i = 1:5
    gauss_dummy{2}(i,:) = gauss_dummy{1}(i,end:-1:1);
end
% BSD plot
expon{1} = exp(-(0:200)/50)*1000;
expon{2} = exp(-(0:200)/100)*1000;

% fill plots
PDAMeta.Plots.Data_Single = bar(h.SingleTab.Main_Axes,...
    x,...
    y{1},...
    'EdgeColor','none',...
    'FaceColor',[0.4 0.4 0.4],...
    'BarWidth',1);
PDAMeta.Plots.Res_Single = bar(h.SingleTab.Res_Axes,...
    x,...
    r{1},...
    'FaceColor','none',...
    'EdgeColor',[0 0 0],...
    'BarWidth',1,...
    'LineWidth',2);
PDAMeta.Plots.Fit_Single = bar(h.SingleTab.Main_Axes,...
    x,f{1},...
    'EdgeColor',[0 0 0],...
    'FaceColor','none',...
    'BarWidth',1,...
    'LineWidth',2);
PDAMeta.Plots.BSD_Single = plot(h.SingleTab.BSD_Axes,...
    0:200,...
    expon{1},...
    'Color','k',...
    'LineWidth',2);
axis('tight');
PDAMeta.Plots.Gauss_Single{1} = plot(h.SingleTab.Gauss_Axes,...
    0:0.1:150,...
    sum(gauss_dummy{1},1),...
    'Color','k',...
    'LineWidth',2);
axis('tight');
for i = 2:6
    PDAMeta.Plots.Gauss_Single{i} = plot(h.SingleTab.Gauss_Axes,...
        0:0.1:150,...
        gauss_dummy{1}(i-1,:),...
        'Color',color(i-1,:),...
        'LineWidth',2);
end
xlim(h.SingleTab.Gauss_Axes,[40 120]);

x = x-mean(diff(x))/2; %to make the stairs graph appear similar to the bar graph

%All Data
hold on
for i = 1:2
    PDAMeta.Plots.Data_All = cell(2,1);
    PDAMeta.Plots.Res_All = cell(2,1);
    PDAMeta.Plots.Fit_All = cell(2,1);
    PDAMeta.Plots.Data_All{i} = stairs(h.AllTab.Main_Axes,...
        x, y{i},...
        'Color',(3.*color(i,:)+1)./4,...
        'LineWidth', 1);
    PDAMeta.Plots.Res_All{i} = stairs(h.AllTab.Res_Axes,...
        x, r{i},...
        'Color',color(i,:),...
        'LineWidth', 1);
    PDAMeta.Plots.Fit_All{i} = stairs(h.AllTab.Main_Axes,...
        x, f{i},...
        'Color',color(i,:),...
        'LineWidth', 2,...
        'LineStyle', '--');
end
for i = 1:2
    PDAMeta.Plots.BSD_All{i} = plot(h.AllTab.BSD_Axes,...
        0:200,...
        expon{i},...
        'Color',color(i,:),...
        'LineWidth',2);
    axis('tight');
end
for i = 1:2
    c = color(i,:);
    PDAMeta.Plots.Gauss_All{i,1} = plot(h.AllTab.Gauss_Axes,...
        0:0.1:150,...
        sum(gauss_dummy{i},1),...
        'Color',color(i,:),...
        'LineWidth',2);
    for j = 2:6
        c = (3.*c + 1)./4;
        PDAMeta.Plots.Gauss_All{i,j} = plot(h.AllTab.Gauss_Axes,...
            0:0.1:150,...
            gauss_dummy{i}(j-1,:),...
            'Color',c,...
            'LineWidth',2);
    end
    
end
axis('tight');
xlim(h.AllTab.Gauss_Axes,[40 120]);

% Info menu - To do list
function Todolist(~,~)
msgbox({...
    'allow to set Epr limits for plotting and analysis';...
    'remove everything from global that is not needed in global';...
    'add a legend in the plots';...
    'sigma cannot be zero or a very small number';...
    'the chi^2 definition is not ok';...
    'possibility to plot the actual E instead of Epr';...
    'dynamic PDA fit';...
    'brightness corrected PDA';...
    'when you press determine gamma, take the actual DA molecules instead of a rough S selection';...
    'put the optimplotfval into the gauss plot, so fitting can be evaluated per iteration, rather than per function sampling';...
    '';...
    ''} ,'To do list','modal');

% Info menu - Manual callback
function Manual(~,~)
if ismac
    inp = '/Global PDA Fitting.docx';
    %MACOPEN Open a file or directory using the OPEN terminal utility on the MAC.
    %   MACOPEN FILENAME opens the file or directory FILENAME using the
    %   the OPEN terminal command.
    %
    %   Examples:
    %
    %     If you have Microsoft Word installed, then
    %     macopen('/myDoc.docx')
    %     opens that file in Microsoft Word if the file exists, and errors if
    %     it doesn't.
    %
    %     macopen('/Applications')
    %     opens a new Finder window, showing the contents of your /Applications
    %     folder.
    %
    %   See also WINOPEN, OPEN, DOS, WEB.
    
    % Copyright 2012 - 2013 The MathWorks, Inc.
    % Written: 16-Apr-2012, Varun Gandhi
    if strcmpi('.',inp)
        inp = pwd;
    end
    syscmd = ['open ', inp, ' &'];
    %disp(['Running the following in the Terminal: "', syscmd,'"']);
    system(syscmd);
else
    winopen('Global PDA Fitting.docx')
end

% Database management
function Database(~,e,mode)
global UserValues PDAData
LSUserValues(0);
h = guidata(findobj('Tag','GlobalPDAFit'));

if mode == 0
    switch e.Key
        case 'delete'
            mode = 1;
    end
end

switch mode
    case 1 
        %% Delete files from database
        %remove rows from list
        h.PDADatabase.List.String(h.PDADatabase.List.Value) = [];
        %remove data from PDAData
        PDAData.FileName(h.PDADatabase.List.Value) = [];
        PDAData.PathName(h.PDADatabase.List.Value) = [];
        PDAData.Data(h.PDADatabase.List.Value) = [];
        PDAData.timebin(h.PDADatabase.List.Value) = [];
        PDAData.Corrections(h.PDADatabase.List.Value) = [];
        PDAData.Background(h.PDADatabase.List.Value) = [];
        PDAData.FitTable(h.PDADatabase.List.Value) = [];
        PDAData.OriginalFitParams = PDAData.FitTable;
        h.FitTab.Table.RowName(h.PDADatabase.List.Value)=[];
        h.FitTab.Table.Data(h.PDADatabase.List.Value,:)=[];
        h.ParametersTab.Table.RowName(h.PDADatabase.List.Value)=[];
        h.ParametersTab.Table.Data(h.PDADatabase.List.Value,:)=[];
        
        h.PDADatabase.List.Value = 1;
        if size(h.PDADatabase.List.String, 1) < 1
            % no files are left
            h.PDADatabase.Save.Enable = 'off';
            SampleData
        else
            Update_Plots([],[],3);
            Update_FitTable([],[],1);
            Update_ParamTable([],[],1);
        end
    case 2 
        %% Load database
        [FileName, Path] = uigetfile({'*.pab', 'PDA Database file'}, 'Choose PDA database to load',UserValues.File.BurstBrowserPath,'MultiSelect', 'off');
        load('-mat',fullfile(Path,FileName));
        PDAData.FileName = s.file;
        PDAData.PathName = s.path;
        Load_PDA([],[],3);
        %h.PDADatabase.List.String = s.str;
        clear s;
        if size(h.PDADatabase.List.String, 1) > 0
            % files are left
            h.PDADatabase.Save.Enable = 'on';
        else
            SampleData
        end
    case 3 
        %% Save complete database
        [File, Path] = uiputfile({'*.pab', 'PDA Database file'}, 'Save PDA database', UserValues.File.BurstBrowserPath);
        s = struct;
        s.file = PDAData.FileName;
        s.path = PDAData.PathName;
        %s.str = h.PDADatabase.List.String;
        save(fullfile(Path,File),'s');
end

% Updates GUI elements
function Update_GUI(obj,~)
h = guidata(obj);

if obj == h.SettingsTab.FixSigmaAtFractionOfR
    switch obj.Value
        case 1
            %%% Enable Check Box
            h.SettingsTab.SigmaAtFractionOfR_edit.Enable = 'on';
            h.SettingsTab.FixSigmaAtFractionOfR_Fix.Enable = 'on';
            %%% Update FitParameter Table (fix all sigmas, set to value
            %%% according to number in edit box)
            Update_FitTable([],[],4);
            %%% Disable Columns
            h.FitTab.Table.ColumnEditable(8:9:end) = deal(false);
            h.FitTab.Table.ColumnEditable(9:9:end) = deal(false);
            h.FitTab.Table.ColumnEditable(10:9:end) = deal(false);
        case 0
            h.SettingsTab.SigmaAtFractionOfR_edit.Enable = 'off';
            h.SettingsTab.FixSigmaAtFractionOfR_Fix.Enable = 'off';
            %%% Reset the fixed status of the fit table
            Data = h.FitTab.Table.Data;
            for i = 1:(size(Data,1)-2)
                %%% Fix all sigmas
                Data(i,9:9:end) = deal({false});
            end
            h.FitTab.Table.Data = Data;
            %%% Reenable Columns
            h.FitTab.Table.ColumnEditable(8:9:end) = deal(true);
            h.FitTab.Table.ColumnEditable(9:9:end) = deal(true);
            h.FitTab.Table.ColumnEditable(10:9:end) = deal(true);
    end
end

% functio for loading of brightness reference, i.e. donor only sample
function Load_Brightness_Reference(obj,~,mode)
global PDAData UserValues PDAMeta

load_file = 0;

switch mode
    case 1
        if obj.Value == 1
            if isempty(PDAData.BrightnessReference)
                load_file = 1;
            end
            PDAMeta.Plots.BSD_Reference.Visible = 'on';
        else
            PDAMeta.Plots.BSD_Reference.Visible = 'off';
        end
    case 2
        load_file = 1;
end
            
            
if load_file
    %%% Load data
    [FileName,p] = uigetfile({'*.pda','*.pda file'},'Select *.pda file containing a Donor only measurement',...
        UserValues.File.BurstBrowserPath,'Multiselect','off');
    
    if all(FileName==0)
        return
    end
    
    load(fullfile(p,FileName),'-mat');
    PDAData.BrightnessReference.N = PDA.NG;
    PDAData.BrightnessReference.PN = histcounts(PDAData.BrightnessReference.N,1:(max(PDAData.BrightnessReference.N)+1));
    
    %%% Update Plot
    PDAMeta.Plots.BSD_Reference.XData = 1:max(PDAData.BrightnessReference.N);
    PDAMeta.Plots.BSD_Reference.YData = PDAData.BrightnessReference.PN;
end

%%% Scale Photon Count Distribution to lower brightness (linear scaling,
%%% approximately correct)
function [ PN_scaled ] = scalePN(PN, scale_factor)
PN_scaled = interp1(scale_factor*[1:1:numel(PN)],PN,[1:1:numel(PN)]);
PN_scaled(isnan(PN_scaled)) = 0;

%%% Calculate the relative brightness based on FRET value
function Qr = calc_relative_brightness(R,file)
global PDAMeta
de = PDAMeta.directexc(file);
ct = PDAMeta.crosstalk(file);
gamma = PDAMeta.gamma(file);
E = 1/(1+(R/PDAMeta.R0(file)).^6);
Qr = (1-de)*(1-E) + (gamma/(1+ct))*(de+E*(1-de));
%%% Re-calculate the P array based on changed PN (brightness correction)
function P = recalculate_P(PN_scaled,file)
global PDAMeta
h = guidata(findobj('Tag','GlobalPDAFit'));
Nobins = str2double(h.SettingsTab.NumberOfBins_Edit.String);
NobinsE = str2double(h.SettingsTab.NumberOfBinsE_Edit.String);

PN  = PN_scaled';
P = cell(1,NobinsE);
if PDAMeta.NBG{file} == 0 && PDAMeta.NBR{file} == 0
    for j = 1:NobinsE+1
        PN_trans = repmat(PN,1,PDAMeta.maxN{file}+1);
        PN_trans = PN_trans(:);
        PN_trans = PN_trans(PDAMeta.HistLib.valid{file}{j});
        P{1,j} = accumarray(PDAMeta.HistLib.bin{file}{j},PDAMeta.HistLib.P_array{file}{j}.*PN_trans);
    end
else
    for j = 1:NobinsE+1
        P{1,j} = zeros(Nobins,1);
        count = 1;
        for g = 0:PDAMeta.NBG{file}
            for r = 0:PDAMeta.NBR{file}
                PN_trans = repmat(PN(1+g+r:end),1,PDAMeta.maxN{file}+1);%the total number of fluorescence photons is reduced
                PN_trans = PN_trans(:);
                PN_trans = PN_trans(PDAMeta.HistLib.valid{file}{j}{count});
                P{1,j} = P{1,j} + accumarray(PDAMeta.HistLib.bin{file}{j}{count},PDAMeta.HistLib.P_array{file}{j}{count}.*PN_trans);
                count = count+1;
            end
        end
    end
end
                    