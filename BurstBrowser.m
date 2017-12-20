function BurstBrowser(~,~)
%   2017 - FAB Lab Munich - Don C. Lamb

hfig=findobj('Tag','BurstBrowser');

addpath(genpath(['.' filesep 'functions']));

global UserValues BurstMeta PathToApp
LSUserValues(0);
Look=UserValues.Look;
if isempty(PathToApp)
    GetAppFolder();
end
if isempty(hfig)
    warning('off','MATLAB:uigridcontainer:MigratingFunction');
    warning('off','MATLAB:uiflowcontainer:MigratingFunction');
    
    %%% start splash screen
    s = SplashScreen( 'Splashscreen', [PathToApp filesep 'images' filesep 'BurstBrowser' filesep 'splash.jpg'], ...
                         'ProgressBar', 'on', ...
                         'ProgressPosition', 5, ...
                         'ProgressRatio', 0 );
     s.addText( 30, 50, 'BurstBrowser', 'FontSize', 30, 'Color', [1 1 1] );
     s.addText( 30, 80, 'v1.0', 'FontSize', 20, 'Color', [1 1 1] );
     s.addText( 385, 330, 'Loading...', 'FontSize', 20, 'Color', 'white' );
    %% Define main window
    h.BurstBrowser = figure(...
        'Units','normalized',...
        'Name','BurstBrowser',...
        'NumberTitle','off',...
        'MenuBar','none',...
        'defaultUicontrolFontName',Look.Font,...
        'defaultAxesFontName',Look.Font,...
        'defaultTextFontName',Look.Font,...
        'OuterPosition',[0.01 0.05 0.98 0.95],...
        'UserData',[],...
        'Visible','off',...
        'Tag','BurstBrowser',...
        'Toolbar','figure',...
        'CloseRequestFcn',@Close_BurstBrowser,...
        'KeyPressFcn',@BurstBrowser_KeyPress);
    %'WindowScrollWheelFcn',@Bowser_Wheel,...
    %'KeyPressFcn',@Bowser_KeyPressFcn,...
    whitebg(h.BurstBrowser,Look.Axes);
    set(h.BurstBrowser,'Color',Look.Back);
    %%% Remove unneeded items from toolbar
    toolbar = findall(h.BurstBrowser,'Type','uitoolbar');
    toolbar_items = findall(toolbar);
    delete(toolbar_items([2:7 9 13:17]));
    %%% get BurstBrowser size in pixels
    h.BurstBrowser.Units = 'pixels';
    h.figure_size = h.BurstBrowser.Position;
    %%% define menu items
    h.File_Menu = uimenu(...
        'Parent',h.BurstBrowser,...
        'Label','File',...
        'Tag','File_Menu',...
        'Enable','off');
    %%% Load Burst Data Callback
    h.Load_Bursts = uimenu(...
        'Parent',h.File_Menu,...
        'Label','<html>Load <b>New</b> Burst Data <b>(Crtl+N)</b><html>',...
        'Callback',@Load_Burst_Data_Callback,...
        'Tag','Load_Burst_Data');
    h.Load_Bursts_From_Folder = uimenu(...
        'Parent',h.File_Menu,...
        'Label','<html>Load <b>New</b> Burst Files from <b>Subfolders</b></html>',...
        'Callback',@Load_Burst_Data_Callback,...
        'Tag','Load_Bursts_From_Folder');
    h.Append_File = uimenu(...
        'Parent',h.File_Menu,...
        'Label','<html><b>Add</b> Burst Data<html>',...
        'Callback',@Load_Burst_Data_Callback,...
        'Tag','Load_Burst_Data',...
        'Separator','on',...
        'Enable','off');
    %h.Database.Add = uimenu(...
    %    'Parent', h.File_Menu,...
    %    'Tag','Database_Add',...
    %    'Label','Add Burst File to Database',...
    %    'enable', 'off',...
    %    'Callback',{@Database,1});
    
    %%% Save Analysis State
    h.Save_Bursts = uimenu(...
        'Parent',h.File_Menu,...
        'Label','<html><b>Save</b> Analysis State <b>(Ctrl+S)</b></html>',...
        'Callback',@Save_Analysis_State_Callback,...
        'Tag','Save_Analysis_State',...
        'Separator','on');
    %%% Merge *.bur files
    h.Merge_Files_Menu = uimenu(...
        'Parent',h.File_Menu,...
        'Label','<html><b>Merge</b> <i>*.bur</i>-files</html>',...
        'Callback',@Merge_bur_files,...
        'Tag','Merge_Files_Menu',...
        'Separator','on');
    
    %%% "Export" Menu    
    h.Export_Menu = uimenu(...
        'Parent',h.BurstBrowser,...
        'Label','Export',...
        'Tag','More_Export_Menu',...
        'Enable','on');
    %%% Export FRET histograms for all loaded measurements
    h.FRET_Export_Top_Menu = uimenu(...
        'Parent',h.Export_Menu,...
        'Label','<html>Export <b>FRET efficiency histograms</b>...</html>',...
        'Callback',[],...
        'Tag','FRET_Export_Top_Menu',...
        'Separator','off');
    h.FRET_Export_Sel_Menu = uimenu(...
        'Parent',h.FRET_Export_Top_Menu,...
        'Label','<html>for all selected species</html>',...
        'Callback',@Export_FRET_Hist,...
        'Tag','FRET_Export_Sel__Menu',...
        'Separator','off');
    h.FRET_Export_All_Menu = uimenu(...
        'Parent',h.FRET_Export_Top_Menu,...
        'Label','<html>for all loaded files</html>',...
        'Callback',@Export_FRET_Hist,...
        'Tag','FRET_Export_All_Menu',...
        'Separator','off');
    h.Export_PDA_Top_Menu = uimenu(...
        'Parent',h.Export_Menu,...
        'Label','<html>Export to <b>PDA</b>...</html>',...
        'Tag','Export_PDA_Top_Menu',...
        'Callback',[],...
        'Enable','on',...
        'Separator','off');
    h.Export_PDA_Sel_Menu = uimenu(...
        'Parent',h.Export_PDA_Top_Menu,...
        'Label','<html>for all selected species</html>',...
        'Tag','Export_PDA_Sel_Menu',...
        'Callback',@Export_To_PDA,...
        'Enable','on');
    h.Export_PDA_All_Menu = uimenu(...
        'Parent',h.Export_PDA_Top_Menu,...
        'Label','<html>for all loaded files</html>',...
        'Tag','Export_PDA_All_Menu',...
        'Callback',@Export_To_PDA,...
        'Enable','on');
    h.ExportAllGraphs_Menu = uimenu(...
        'Parent',h.Export_Menu,...
        'Label','<html>Export all graphs (E, E-S, lifetime...)</html>',...
        'Tag','ExportAllGraphs_Menu',...
        'Callback',@ExportAllGraphs,...
        'Enable','on',...
        'Separator','on');
    h.ExportAllInOneGraphs_Top_Menu = uimenu(...
        'Parent',h.Export_Menu,...
        'Label','<html>Export all-in-one graphs...</html>',...
        'Tag','ExportAllInOneGraphs_Top_Menu',...
        'Callback',[],...
        'Enable','on',...
        'Separator','off');
    h.ExportAllInOneGraphs_Top_Menu1 = uimenu(...
        'Parent',h.ExportAllInOneGraphs_Top_Menu,...
        'Label','<html>S-E plot attached</html>',...
        'Tag','ExportAllInOneGraphs_Menu1',...
        'Callback',{@ExportAllInOneGraphs,1},...
        'Enable','on',...
        'Separator','off');
    h.ExportAllInOneGraphs_Top_Menu2 = uimenu(...
        'Parent',h.ExportAllInOneGraphs_Top_Menu,...
        'Label','<html>S-E plot centered</html>',...
        'Tag','ExportAllInOneGraphs_Menu2',...
        'Callback',{@ExportAllInOneGraphs,2},...
        'Enable','on',...
        'Separator','off');
     %%% Choose print path
    h.Autoset_PrintPath_Menu = uimenu(...
        'Parent',h.Export_Menu,...
        'Label','<html>Export to <b>Current</b> File Path<html>',...
        'Callback',@Choose_PrintPath_Menu,...
        'Tag','Autoset_PrintPath_Menu',...
        'Separator','on');
    h.Choose_PrintPath_Menu = uimenu(...
        'Parent',h.Export_Menu,...
        'Label','<html><b>Change</b> Export Path<html>',...
        'Callback',@Choose_PrintPath_Menu,...
        'Tag','Choose_PrintPath_Menu',...
        'Separator','off');
    h.Current_PrintPath_Menu = uimenu(...
        'Parent',h.Export_Menu,...
        'Label','<html><i>Current Export Path:</i></html>',...
        'Callback',[],...
        'Tag','Current_PrintPath_Menu',...
        'Separator','off');
    h.Current_PrintPath_Text = uimenu(...
        'Parent',h.Current_PrintPath_Menu,...
        'Label',UserValues.BurstBrowser.PrintPath,...
        'Callback',[],...
        'Tag','Current_PrintPath_Text',...
        'Separator','off');
    if UserValues.BurstBrowser.Settings.UseFilePathForExport
        h.Autoset_PrintPath_Menu.Checked = 'on';
        h.Choose_PrintPath_Menu.Enable = 'off';
        h.Current_PrintPath_Menu.Enable = 'off';
    else
        h.Autoset_PrintPath_Menu.Checked = 'off';
        h.Choose_PrintPath_Menu.Enable = 'on';
        h.Current_PrintPath_Menu.Enable = 'on';
    end
    h.ExportToTracy = uimenu(...
        'Parent',h.Export_Menu,...
        'Label','Export burst-wise traces',...
        'Callback',@Export_to_Tracy,...
        'Tag','ExportToTracy',...
        'Separator','on');
    %%% "Parameter Comparison" Menu
    h.Parameter_Comparison_Menu = uimenu(....
        'Parent',h.BurstBrowser,...
        'Label','Compare',...
        'Tag','Parameter_Comparison_Menu');
    h.FRET_comp_selected_Menu = uimenu(...
        'Parent',h.Parameter_Comparison_Menu,...
        'Label','<html>Compare <b>FRET efficiency histograms</b> of selected species</html>',...
        'Callback',@Compare_FRET_Hist,...
        'Tag','FRET_comp_selected_Menu',...
        'Enable','off',...
        'Separator','off');
    h.Param_comp_selected_Menu = uimenu(...
        'Parent',h.Parameter_Comparison_Menu,...
        'Label','<html>Compare <b>current parameter</b> of selected species</html>',...
        'Callback',@Compare_FRET_Hist,...
        'Tag','Param_comp_selected_Menu',...
        'Enable','off',...
        'Separator','off');
    %%% FRET Comparions plot of loaded files
    h.FRET_comp_Loaded_Menu = uimenu(...
        'Parent',h.Parameter_Comparison_Menu,...
        'Label','<html>Compare <b>FRET efficiency histograms</b> of loaded files</html>',...
        'Callback',@Compare_FRET_Hist,...
        'Tag','FRET_comp_Loaded_Menu',...
        'Separator','on');
    %%% Parameter Comparions plot from loaded files
    h.Param_comp_Loaded_Menu = uimenu(...
        'Parent',h.Parameter_Comparison_Menu,...
        'Label','<html>Compare <b>current parameter</b> of loaded files</html>',...
        'Callback',@Compare_FRET_Hist,...
        'Tag','Param_comp_Loaded_Menu',...
        'Separator','off');
    
    %%% FRET Comparions plot from *.his files
    h.FRET_comp_File_Menu = uimenu(...
        'Parent',h.Parameter_Comparison_Menu,...
        'Label','<html>Compare <b>FRET efficiency histograms</b> from <i>*.his</i>-files</html>',...
        'Callback',@Compare_FRET_Hist,...
        'Tag','FRET_comp_File_Menu',...
        'Separator','on');
    
    %%% PCA Comparion between files
    h.PCA_comp_File_Menu = uimenu(...
        'Parent',h.Parameter_Comparison_Menu,...
        'Label','<html>PCA<b> anaylsis</html>',...
        'Callback',@PCA_analysis,...
        'Tag','PCA_comp',...
        'Separator','on');
    %%% Notepad Menu Item
    h.Notepad_Menu = uimenu(...
        'Parent',h.BurstBrowser,...
        'Label','Notepad',...
        'Callback',@Open_Notepad,...
        'Tag','Notepad_Menu',...
        'Separator','off');
    %define tabs
    %main tab
    h.Main_Tab = uitabgroup(...
        'Parent',h.BurstBrowser,...
        'Tag','Main_Tab',...
        'Units','normalized',...
        'Position',[0 0 0.65 1],...
        'SelectionChangedFcn',@TabSelectionChange);
    
    h.Main_Tab_General = uitab(h.Main_Tab,...
        'title','General',...
        'Tag','Main_Tab_General'...
        );
    
    h.MainTabGeneralPanel = uibuttongroup(...
        'Parent',h.Main_Tab_General,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabGeneralPanel');
    
    
    %%% Progress Bar
    %%% Panel for progressbar
    h.Progress_Panel = uibuttongroup(...
        'Parent',h.BurstBrowser,...
        'Tag','Progress_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0.65 0 0.35 0.03]);
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
        'String','Nothing loaded',...
        'Interpreter','none',...
        'HorizontalAlignment','center',...
        'BackgroundColor','none',...
        'Color',Look.Fore,...
        'Position',[0.5 0.5]);
    
    %%% Define hide uitabgroup
    h.Hide_Tab =  uitabgroup(...
        'Parent',h.BurstBrowser,...
        'Tag','Hide_Tab',...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Visible','off');
    h.Hide_Stuff = uitab(...
        'Parent',h.Hide_Tab,...
        'Tag','Hide_Stuff');
    
    h.Main_Tab_Lifetime= uitab(h.Main_Tab,...
        'title','Lifetime',...
        'Tag','Main_Tab_Lifetime'...
        );
    
    h.LifetimeTabgroup = uitabgroup(...
        'Parent',h.Main_Tab_Lifetime,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'SelectionChangedFcn',@TabSelectionChange);
    h.LifetimeTabAll = uitab('Parent',h.LifetimeTabgroup,...
        'title','All');
    h.LifetimePanelAll = uibuttongroup(...
        'Parent',h.LifetimeTabAll,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','LifetimePanelAll');%,...
        %'UIContextMenu',h.LifeTime_Menu);
    h.LifetimeTabInd = uitab('Parent',h.LifetimeTabgroup,'title','Individual');
    h.LifetimePanelInd = uibuttongroup(...
        'Parent',h.LifetimeTabInd,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','LifetimePanelInd');%,...
        %'UIContextMenu',h.LifeTime_Menu);
     
    %%% fFCS main tab
    h.Main_Tab_fFCS= uitab(h.Main_Tab,...
        'title','filtered FCS',...
        'Tag','Main_Tab_fFCS'...
        );
    
    h.MainTabfFCSPanel = uibuttongroup(...
        'Parent',h.Main_Tab_fFCS,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabfFCSPanel');
    
    h.Main_Tab_Corrections= uitab(h.Main_Tab,...
        'title','Corrections',...
        'Tag','Main_Tab_Corrections'...
        );
    
    h.MainTabCorrectionsPanel = uibuttongroup(...
        'Parent',h.Main_Tab_Corrections,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabCorrectionsPanel');
    h.Main_Tab_Corrections_ThreeCMFD= uitab(h.Hide_Tab,...
        'title','Corrections (3C)',...
        'Tag','Main_Tab_Corrections_ThreeCMFD'...
        );
    
    h.MainTabCorrectionsThreeCMFDPanel = uibuttongroup(...
        'Parent',h.Main_Tab_Corrections_ThreeCMFD,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabCorrectionsThreeCMFDPanel'...
        );
    
    
    %%% fFCS sub tabs for display of filter and filter matching
    h.fFCS_SubTabPar = uitabgroup(...
        'Parent',h.MainTabfFCSPanel,...
        'Tag','fFCS_SubTabPar',...
        'Units','normalized',...
        'Position',[0 0 0.5 0.45]);
    
    h.fFCS_SubTabParFilter = uitab(h.fFCS_SubTabPar,...
        'title','Filter Par',...
        'Tag','fFCS_SubTabParFilter');
    h.fFCS_SubTabParFilterPanel = uibuttongroup(...
        'Parent',h.fFCS_SubTabParFilter,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','fFCS_SubTabParFilterPanel');
    
    h.fFCS_SubTabParReconstruction = uitab(h.fFCS_SubTabPar,...
        'title','Reconstruction Par',...
        'Tag','fFCS_SubTabParReconstruction');
    h.fFCS_SubTabParReconstructionPanel = uibuttongroup(...
        'Parent',h.fFCS_SubTabParReconstruction,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','fFCS_SubTabParReconstructionPanel');
    
    h.fFCS_SubTabPerp = uitabgroup(...
        'Parent',h.MainTabfFCSPanel,...
        'Tag','fFCS_SubTabPerp',...
        'Units','normalized',...
        'Position',[0.5 0 0.5 0.45]);
    
    h.fFCS_SubTabPerpFilter = uitab(h.fFCS_SubTabPerp,...
        'title','Filter Perp',...
        'Tag','fFCS_SubTabPerpFilter');
    h.fFCS_SubTabPerpFilterPanel = uibuttongroup(...
        'Parent',h.fFCS_SubTabPerpFilter,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','fFCS_SubTabPerpFilterPanel');
    
    h.fFCS_SubTabPerpReconstruction = uitab(h.fFCS_SubTabPerp,...
        'title','Reconstruction Perp',...
        'Tag','fFCS_SubTabPerpReconstruction');
    h.fFCS_SubTabPerpReconstructionPanel = uibuttongroup(...
        'Parent',h.fFCS_SubTabPerpReconstruction,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','fFCS_SubTabPerpReconstructionPanel');
    %% Secondary tab selection gui
    h.Secondary_Tab = uitabgroup(...
        'Parent',h.BurstBrowser,...
        'Tag','Secondary_Tab',...
        'Units','normalized',...
        'Position',[0.65 0.25 0.35 0.75]);
    
    h.Secondary_Tab_Selection = uitab(h.Secondary_Tab,...
        'title','Selection',...
        'Tag','Secondary_Tab_Selection'...
        );
    
    h.SecondaryTabSelectionPanel = uibuttongroup(...
        'Parent',h.Secondary_Tab_Selection,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','SecondaryTabSelectionPanel');
    
    h.Secondary_Tab_Corrections= uitab(h.Secondary_Tab,...
        'title','Corrections/FCS',...
        'Tag','Secondary_Tab_Corrections'...
        );
    
    h.SecondaryTabCorrectionsPanel = uibuttongroup(...
        'Parent',h.Secondary_Tab_Corrections,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','SecondaryTabCorrectionsPanel');
    
    h.Secondary_Tab_Fitting= uitab(...
        'Parent',h.Secondary_Tab,...
        'title','Fitting',...
        'Tag','Secondary_Tab_Fitting'...
        );
    
    h.Secondary_Tab_Options= uitab(h.Secondary_Tab,...
        'title','Options',...
        'Tag','Secondary_Tab_DisplayOptions'...
        );
    
    h.SecondaryTabOptionsPanel = uibuttongroup(...
        'Parent',h.Secondary_Tab_Options,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','SecondaryTabOptionsPanel');
    h.Secondary_Tab_Database= uitab(h.Secondary_Tab,...
        'title','Database',...
        'Tag','Secondary_Tab_Database');
    
    h.DatabaseBB.Panel = uibuttongroup(...
        'Parent',h.Secondary_Tab_Database,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','SecondaryTabDatabasePanel');
    
    s.ProgressRatio = 0.25;
    
    %%% jave based right-click menu for uitree implementation
    %%% see http://undocumentedmatlab.com/blog/adding-context-menu-to-uitree
    % Prepare the context menu (can use HTML labels)
    h.AddSpeciesMenuItem = javax.swing.JMenuItem('Add Species');
    h.RemoveSpeciesMenuItem = javax.swing.JMenuItem('Remove Species');
    h.RenameSpeciesMenuItem = javax.swing.JMenuItem('Rename Species');
    h.RemoveFileMenuItem = javax.swing.JMenuItem('Remove File');
    h.ExportMenuItem = javax.swing.JMenu('Export...');
    h.ExportSpeciesToPDAMenuItem = javax.swing.JMenuItem('Export Species to PDA');
    h.ExportMicrotimePattern = javax.swing.JMenuItem('Export Microtime Pattern');
    h.DoTimeWindowAnalysis = javax.swing.JMenuItem('Time Window Analysis');
    h.Export_FRET_Hist_Menu = javax.swing.JMenuItem('Export FRET Efficiency Histogram');
    h.Export_FRET_Hist_Timeseries_Menu = javax.swing.JMenuItem('Export FRET Efficiency Histogram (Time Series)');
    h.SendToTauFit = javax.swing.JMenuItem('Send Selected Species to TauFit');
    h.DisplayFileInfo = javax.swing.JMenuItem('Display File Info');
    % set callbacks
    set(h.AddSpeciesMenuItem,'ActionPerformedCallback',@AddSpecies);
    set(h.RemoveSpeciesMenuItem,'ActionPerformedCallback',@RemoveSpecies);
    set(h.RenameSpeciesMenuItem,'ActionPerformedCallback',@RenameSpecies);
    set(h.RemoveFileMenuItem,'ActionPerformedCallback',@RemoveFile);
    set(h.ExportSpeciesToPDAMenuItem,'ActionPerformedCallback',@Export_To_PDA)
    set(h.ExportMicrotimePattern,'ActionPerformedCallback',@Export_Microtime_Pattern); 
    set(h.DoTimeWindowAnalysis,'ActionPerformedCallback',@Time_Window_Analysis);
    set(h.Export_FRET_Hist_Menu,'ActionPerformedCallback',@Export_FRET_Hist); 
    set(h.Export_FRET_Hist_Timeseries_Menu,'ActionPerformedCallback',@Export_FRET_Hist); 
    set(h.SendToTauFit,'ActionPerformedCallback',@Send_To_TauFit);
    set(h.DisplayFileInfo,'ActionPerformedCallback',@DisplayFileInfo);
    % construct contextmenu
    h.SpeciesListMenu = javax.swing.JPopupMenu;
    h.SpeciesListMenu.add(h.AddSpeciesMenuItem);
    h.SpeciesListMenu.add(h.RemoveSpeciesMenuItem);
    h.SpeciesListMenu.add(h.RenameSpeciesMenuItem);
    h.SpeciesListMenu.addSeparator;
    h.SpeciesListMenu.add(h.RemoveFileMenuItem);
    h.SpeciesListMenu.addSeparator;
    h.SpeciesListMenu.add(h.SendToTauFit);
    h.ExportMenuItem.add(h.Export_FRET_Hist_Menu);
    h.ExportMenuItem.add(h.ExportSpeciesToPDAMenuItem);
    h.ExportMenuItem.add(h.ExportMicrotimePattern);
    h.ExportMenuItem.add(h.Export_FRET_Hist_Timeseries_Menu);
    h.SpeciesListMenu.add(h.ExportMenuItem);
    h.SpeciesListMenu.add(h.DoTimeWindowAnalysis);
    h.SpeciesListMenu.addSeparator;
    h.SpeciesListMenu.add(h.DisplayFileInfo);
    %%% Define Species List
    % new: use uitreenode
    %%% read icons
    [iconBurst,map] = imread([PathToApp filesep 'images/BurstBrowser/plottype-hist.gif']);
    iconBurst = ind2rgb(iconBurst,map);
    h.icons.iconBurst = imresize(iconBurst,[16,16]);
    h.icons.iconFile = imresize(imread([PathToApp filesep 'images/BurstBrowser/folder.jpg']),[16,16]);
    h.icons.iconSpecies = imresize(imread([PathToApp filesep 'images/BurstBrowser/book_sim.jpg']),[16,16]);
    h.icons.iconSubspecies = imresize(imread([PathToApp filesep 'images/BurstBrowser/help_rn.jpg']),[16,16]);
    h.SpeciesList.Root = uitreenode('v0','internalHandle','Burst Data',[],false);
    h.SpeciesList.Root.setIcon(im2java(h.icons.iconBurst));
    [h.SpeciesList.Tree, h.SpeciesList.container] = uitree('v0','Root',h.SpeciesList.Root);
    set(h.SpeciesList.container,...% 'Parent', h.SecondaryTabSelectionPanel,...
        'Parent',h.BurstBrowser,...
        'Units','normalize',...
        'Position',[0.65 0.03 0.35 0.22]);  % fix the uitree Parent
    set(h.SpeciesList.Tree,'NodeSelectedCallback',@SpeciesList_ButtonDownFcn);
    h.SpeciesList.Tree.getTree.setBackground(java.awt.Color(0.9,0.9,0.9));
    % Set the tree mouse-click callback
    set(h.SpeciesList.Tree.getTree, 'MousePressedCallback', {@SpeciesListContextMenuCallback,h.SpeciesListMenu});
    
    buttonsize = 20;
    offset = 5;
    button_posX = (h.SpeciesList.container.Position(1)+0.5*h.SpeciesList.container.Position(3))*h.figure_size(3);
    button_posY = 0.2375*h.figure_size(4)-buttonsize;

    %%% add buttons to species list
    h.AddSpecies_Button = uicontrol(...
        'Parent',h.BurstBrowser,...
        'Units','pixels',...
        'BackgroundColor','white',...
        'ForegroundColor', Look.Fore,...
        'Position',[button_posX button_posY buttonsize buttonsize],...
        'Style','pushbutton',...
        'Tag','AddSpecies_Button',...
        'FontSize',12,...
        'TooltipString','Add Species...',...
        'Callback',@AddSpecies);
    iconbutton(h.AddSpecies_Button,[PathToApp filesep 'images/BurstBrowser/GreenPlus_12.jpg']);

    h.RemoveSpecies_Button = uicontrol(...
        'Parent',h.BurstBrowser,...
        'Units','pixels',...
        'BackgroundColor','white',...
        'ForegroundColor', Look.Fore,...
        'Position',[button_posX+buttonsize+offset button_posY buttonsize buttonsize],...
        'Style','pushbutton',...
        'Tag','RemoveSpecies_Button',...
        'FontSize',12,...
        'TooltipString','Remove Species...',...
        'Callback',@RemoveSpecies);
    iconbutton(h.RemoveSpecies_Button,[PathToApp filesep 'images/BurstBrowser/status_failed.jpg']);
    
    h.RenameSpecies_Button = uicontrol(...
        'Parent',h.BurstBrowser,...
        'Units','pixels',...
        'BackgroundColor','white',...
        'ForegroundColor', Look.Fore,...
        'Position',[button_posX+2*(buttonsize+offset) button_posY buttonsize buttonsize],...
        'Style','pushbutton',...
        'Tag','RenameSpecies_Button',...
        'FontSize',12,...
        'TooltipString','Rename Species...',...
        'Callback',@RenameSpecies);
    iconbutton(h.RenameSpecies_Button,[PathToApp filesep 'images/BurstBrowser/cc_sourcecodec.jpg']);
    
    h.Send_to_TauFit_Button = uicontrol(...
        'Parent',h.BurstBrowser,...
        'Units','pixels',...
        'BackgroundColor','black',...
        'ForegroundColor', Look.Fore,...
        'Position',[button_posX+3*(buttonsize+offset)+10 button_posY buttonsize buttonsize],...
        'Style','pushbutton',...
        'Tag','Send_to_TauFit_Button',...
        'FontSize',12,...
        'TooltipString','Send selected species to TauFit',...
        'Callback',@Send_To_TauFit);
    iconbutton(h.Send_to_TauFit_Button,[PathToApp filesep 'images/BurstBrowser/lifetime.jpg']);
    
    h.Export_To_PDA_Button = uicontrol(...
        'Parent',h.BurstBrowser,...
        'Units','pixels',...
        'BackgroundColor','white',...
        'ForegroundColor', Look.Fore,...
        'Position',[button_posX+4*(buttonsize+offset)+10 button_posY buttonsize buttonsize],...
        'Style','pushbutton',...
        'Tag','Export_To_PDA_Button',...
        'FontSize',12,...
        'TooltipString','Export selected species to PDA',...
        'Callback',@Export_To_PDA);
    iconbutton(h.Export_To_PDA_Button,[PathToApp filesep 'images/BurstBrowser/plottype-hist.jpg']);
    
    %%% Multiselect checkbox and multiplot button
    h.MultiPlotButtonMenu = uicontextmenu;
    h.MultiPlotButtonMenu_ToggleNormalize = uimenu(...
        h.MultiPlotButtonMenu,...
        'Tag','MultiPlotButtonMenu_ToggleNormalize',...
        'Label','Normalize populations',...
        'Callback',@UpdateOptions);
    if UserValues.BurstBrowser.Settings.Normalize_Multiplot
        h.MultiPlotButtonMenu_ToggleNormalize.Checked = 'on';
    else
        h.MultiPlotButtonMenu_ToggleNormalize.Checked = 'off';
    end
    h.MultiPlotButtonMenu_ToggleDisplayTotal = uimenu(...
        h.MultiPlotButtonMenu,...
        'Tag','MultiPlotButtonMenu_ToggleDisplayTotal',...
        'Label','Display sum of all populations',...
        'Callback',@UpdateOptions);
    if UserValues.BurstBrowser.Settings.Display_Total_Multiplot
        h.MultiPlotButtonMenu_ToggleDisplayTotal.Checked = 'on';
    else
        h.MultiPlotButtonMenu_ToggleDisplayTotal.Checked = 'off';
    end
    %%% Define MultiPlot Button
    h.MultiPlotButton = uicontrol(...
        'Parent',h.BurstBrowser,...
        'Units','pixels',...
        'BackgroundColor', 'white',...
        'ForegroundColor', Look.Fore,...
        'Position',[button_posX+3*(buttonsize+offset)+10 button_posY 2.5*buttonsize buttonsize],...
        'Style','pushbutton',...
        'Tag','MutliPlotButton',...
        'TooltipString','Plots multiple species using different colors. Support up to three species.',...
        'FontSize',12,...
        'Visible','off',...
        'Callback',@MultiPlot,...
        'Enable','on');
        %'String','Plot multiple species',...
    iconbutton(h.MultiPlotButton,[PathToApp filesep 'images/BurstBrowser/plot_multiple_icon.png']);
    
    h.MultiselectOnCheckbox = uicontrol(...
        'Parent',h.BurstBrowser,...
        'Units','pixels',...
        'BackgroundColor', 'white',...
        'ForegroundColor', Look.Fore,...
        'Position',[button_posX+6*(buttonsize+offset)+20 button_posY buttonsize buttonsize],...
        'Style','pushbutton',...
        'Tag','MultiselectOnCheckbox',...
        'FontSize',12,...
        'TooltipString','Enable multiselection for plotting',...
        'Callback',@UpdateOptions,...
        'UserData',0,...
        'UIContextMenu', h.MultiPlotButtonMenu);
    iconbutton(h.MultiselectOnCheckbox,[PathToApp filesep 'images/BurstBrowser/multiselection.png']);
    h.MultiselectOnCheckbox.CData(:,:,[2,3]) = 0;
    
    %%% Cut Table right click menu
    h.CutTable_Menu = uicontextmenu;
    h.StoreInCutDatabase_Menu = uimenu(...
        'Parent',h.CutTable_Menu,...
        'Tag','StoreInCutDatabase_Menu',...
        'Label','Store in cut database',...
        'Callback',@UpdateCutDatabase);
    h.ApplyCutsToLoaded_Menu = uimenu(...
        'Parent',h.CutTable_Menu,...
        'Tag','ApplyCutsToLoaded_Menu',...
        'Label','Apply current cuts to all loaded files',...
        'Separator','on',...
        'Callback',@ApplyCutsToLoaded);
    
    %define the cut table
    if ispc
        trash_image = ['<html><img src="file:/' PathToApp '/images/trash16p.png"/></html>'];
        trash_image = strrep(trash_image,'\','/');
        circle_image = ['<html><img src="file:/' PathToApp '/images/BurstBrowser/greencircleicon.gif"/></html>'];
        circle_image = strrep(circle_image,'\','/');
        zscale_image = ['<html><img src="file:/' PathToApp '/images/BurstBrowser/zscale_square.png"/></html>'];
        zscale_image = strrep(zscale_image,'\','/');
    else
        trash_image = ['<html><img src="file://' PathToApp '/images/trash16p.png"/></html>'];
        circle_image = ['<html><img src="file://' PathToApp '/images/BurstBrowser/greencircleicon.gif"/></html>'];
        zscale_image = ['<html><img src="file://' PathToApp '/images/BurstBrowser/zscale_square.png"/></html>'];
    end
    cname = {'<html><font size=4><b>Parameter</b></font></html>','<html><font size=4><b>min</b></font></html>','<html><font size=4><b>max</b></font></html>',circle_image,trash_image,zscale_image};
    cformat = {'char','numeric','numeric','logical','logical','logical'};
    ceditable = [false,true true true true true];
    table_dat = {'','','',false,false,false};
    cwidth = {225,80,80,25,25,25};
    
    h.CutTable = uitable(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'ForegroundColor',[0,0,0],...
        'Position',[0 0.04 1 0.345],...
        'BackgroundColor', [Look.Table1;Look.Table2],...
        'ForegroundColor', Look.TableFore,...
        'Tag','CutTable',...
        'RowName',[],...
        'ColumnName',cname,...
        'ColumnFormat',cformat,...
        'ColumnEditable',ceditable,...
        'Data',table_dat,...
        'ColumnWidth',cwidth,...
        'FontSize',12,...
        'CellEditCallback',@CutTableChange,...
        'UIContextMenu',h.CutTable_Menu);
    h.CutTable.Units = 'pixels';
    h.CutTable.ColumnWidth{1} = h.CutTable.Position(3)-2*80-2*25-56;
    h.CutTable.Units = 'normalized';
    
    %define the parameter selection listboxes
    h.ParameterListX = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.List,...
        'ForegroundColor', Look.ListFore,...
        'Max',1,...
        'Position',[0 0.385 0.5 0.615],...
        'Style','listbox',...
        'Tag','ParameterListX',...
        'Interruptible','off',...
        'Enable','on',...
        'FontSize',12,...
        'KeyPressFcn',@BurstBrowser_KeyPress);%,...
        %'Callback',{@ParameterList_ButtonDownFcn,'left'},...
        %'ButtonDownFcn',{@ParameterList_ButtonDownFcn,'right'});
    
    h.ParameterListY = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.List,...
        'ForegroundColor', Look.ListFore,...
        'Max',1,...
        'Position',[0.5 0.385 0.5 0.615],...
        'Style','listbox',...
        'Tag','ParameterListY',...
        'Interruptible','off',...
        'Enable','on',...
        'FontSize',12);%,...
        %'Callback',{@ParameterList_ButtonDownFcn,'left'},...
        %'ButtonDownFcn',{@ParameterList_ButtonDownFcn,'right'});
    
    % for right click selection to work, we need to access the underlying
    % java object
    %see: http://undocumentedmatlab.com/blog/setting-listbox-mouse-actions
    drawnow;
    jScrollPaneX = findjobj(h.ParameterListX);
    jScrollPaneY = findjobj(h.ParameterListY);
    jParameterListX = jScrollPaneX.getViewport.getComponent(0);
    jParameterListY = jScrollPaneY.getViewport.getComponent(0);
    jParameterListX = handle(jParameterListX, 'CallbackProperties');
    jParameterListY = handle(jParameterListY, 'CallbackProperties');
    set(jParameterListX, 'MousePressedCallback',{@ParameterList_ButtonDownFcn,h.ParameterListX});
    set(jParameterListY, 'MousePressedCallback',{@ParameterList_ButtonDownFcn,h.ParameterListY});
    
    %define manual cut button
    h.CutButton = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor','white',...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.0025 0.05 0.035],...
        'Style','pushbutton',...
        'Tag','CutButton',...
        'FontSize',12,...
        'TooltipString','Manual Cut (ctr+space)',...
        'Callback',@ManualCut);
    iconbutton(h.CutButton,[PathToApp filesep 'images/BurstBrowser/crop_tool.jpg']);
    %define arbitrary cut button
    h.ArbitraryCutButton = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor','white',...
        'ForegroundColor', Look.Fore,...
        'Position',[0.05 0.0025 0.05 0.035],...
        'Style','pushbutton',...
        'Tag','ArbitraryCutButton',...
        'FontSize',12,...
        'TooltipString','Arbitrary Cut (space)',...
        'Callback',@ManualCut);
    iconbutton(h.ArbitraryCutButton,[PathToApp filesep 'images/BurstBrowser/Freehand_24px.jpg']);
    h.ArbitraryCutButton_Menu = uicontextmenu;
    h.ArbitraryCutInvertCheckbox = uimenu(...
        'Parent',h.ArbitraryCutButton_Menu,...
        'Label','Invert Arbitrary Region Cut',...
        'Checked','off',...
        'Callback',@UpdateOptions);
    h.ArbitraryCutButton.UIContextMenu = h.ArbitraryCutButton_Menu;
    %h.ArbitraryCutInvertCheckbox = uicontrol(...
    %    'Parent',h.SecondaryTabSelectionPanel,...
    %    'Units','normalized',...
    %    'BackgroundColor', Look.Back,...
    %    'ForegroundColor', Look.Fore,...
    %    'Position',[0.86 0.0025 0.14 0.035],...
    %    'Style','checkbox',...
    %    'Tag','ArbitraryCutInvertCheckbox',...
    %    'String','Invert AR',...
    %    'Value',0,...
    %    'FontSize',12,...
    %    'TooltipString','Invert arbitrary cut',...
    %    'Callback',[]);
    cutdatabasetooltip = '<html>Cut Database:<br>Define Cuts and store in Database for frequent use.<br>Choose to add cuts to current species, or add a new species with the defined cuts.</html>';
    h.CutDatabaseText = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.1 0.0025 0.2 0.035],...
        'Style','text',...
        'Tag','CutDatabaseText',...
        'HorizontalAlignment','right',...
        'TooltipString',cutdatabasetooltip,...
        'String','Cut Database:',...
        'FontSize',12);
    %define cut selection popupmenu
    h.CutDatabase = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.3 0.0025 0.5 0.035],...
        'Style','popupmenu',...
        'Tag','CutDatabase',...
        'TooltipString',cutdatabasetooltip,...
        'String',{'-'},...
        'FontSize',12);
    %%% Update string if cuts have been stores
    if ~isempty(fieldnames(UserValues.BurstBrowser.CutDatabase{1}))
        h.CutDatabase.String = fieldnames(UserValues.BurstBrowser.CutDatabase{1});
    end
    %%% Button for applying cut from database
    h.ApplyCutDatabase = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor','white',...
        'ForegroundColor', Look.Fore,...
        'Position',[0.9 0.0025 0.05 0.035],...
        'Style','pushbutton',...
        'Tag','ApplyCutDatabase',...
        'FontSize',12,...
        'TooltipString','Applies cut from database.',...
        'Callback',@UpdateCutDatabase);
    iconbutton(h.ApplyCutDatabase,[PathToApp filesep 'images/BurstBrowser/Floodfill_24.jpg']);
    h.AddCutDatabase = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor','white',...
        'ForegroundColor', Look.Fore,...
        'Position',[0.95 0.0025 0.05 0.035],...
        'Style','pushbutton',...
        'Tag','AddCutDatabase',...
        'FontSize',12,...
        'TooltipString','Adds cut from database as species',...
        'Callback',@UpdateCutDatabase);
    iconbutton(h.AddCutDatabase,[PathToApp filesep 'images/BurstBrowser/GreenPlus_12.jpg']);
    %%% Right-click menu for removing cut from database
    h.ApplyCutDatabase_Menu = uicontextmenu;
    h.PrintDatabaseCut_Menu = uimenu(...
        'Parent',h.ApplyCutDatabase_Menu,...
        'Tag','PrintDatabaseCut_Menu',...
        'Label','Display Selected Cut from Database',...
        'Callback',@UpdateCutDatabase);
    h.RemoveCutDatabase_Menu = uimenu(...
        'Parent',h.ApplyCutDatabase_Menu,...
        'Tag','RemoveCutDatabase_Menu',...
        'Label','Remove Cut from Database',...
        'Callback',@UpdateCutDatabase);
    h.CutDatabase.UIContextMenu = h.ApplyCutDatabase_Menu;
    %% Secondary tab corrections
    s.ProgressRatio = 0.5;
    %%% Buttons
    %%% vertical layout for buttons
    h.CorrectionsButtonsContainer = uiflowcontainer(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','norm',...
        'Position',[0 0.6 0.5 0.4],...
        'FlowDirection','TopDown',...
        'Margin',10,...
        'BackgroundColor',Look.Back);
    %%% Button to determine CrossTalk and DirectExcitation
    h.DetermineCorrectionsButton = uicontrol(...
        'Parent',h.CorrectionsButtonsContainer,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.95 0.4 0.03],...
        'Style','pushbutton',...
        'Tag','DetermineCorrectionsButton',...
        'String','Fit ct/de',...
        'TooltipString',sprintf('Uses donor and acceptor only subpopulations\nto determine crosstalk (ct) and direct excitation (de).'),...
        'FontSize',12,...
        'Callback',@DetermineCorrections);
    
    %%% Layout container for edit box and text
%     h.CorrectionsFilterContainer = uigridcontainer(...
%         'GridSize',[1,2],...
%         'HorizontalWeight',[0.7,0.3],...
%         'Parent',h.CorrectionsButtonsContainer,...
%         'Units','norm',...
%         'Position',[.1,.1,.8,.8],...
%         'BackgroundColor',Look.Back);
%     h.TGX_TRR_text = uicontrol('Style','text',...
%         'Tag','T_Threshold_Text',...
%         'String','Threshold |TGX-TRR|',...
%         'FontSize',12,...
%         'Units','normalized',...
%         'Parent',h.CorrectionsFilterContainer,...
%         'Position',[0.45 0.96 0.35 0.02],...
%         'BackgroundColor',Look.Back,...
%         'ForegroundColor',Look.Fore);
%     
%     h.T_Threshold_Edit =  uicontrol('Style','edit',...
%         'Tag','T_Threshold_Edit',...
%         'String','0.1',...
%         'FontSize',12,...
%         'Units','normalized',...
%         'Parent',h.CorrectionsFilterContainer,...
%         'Position',[0.8 0.96 0.15 0.02],...
%         'BackgroundColor',Look.Control,...
%         'ForegroundColor',Look.Fore);
    h.Menu_gammadetermination = uicontextmenu;
    h.DetermineGammaManuallyButton = uimenu(...
        'Parent',h.Menu_gammadetermination,...
        'Label','<html>Determine gamma factor manually.<br>Select the midpoints of two different FRET species in S vs E plot.<br>Uses currently selected bursts.</html>',...
        'Tag','DetermineGammaManuallyButton',...
        'Callback',@DetermineCorrections);
    %%% Button to fit gamma
    h.FitGammaButton = uicontrol(...
        'Parent',h.CorrectionsButtonsContainer,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.91 0.4 0.03],...
        'Style','pushbutton',...
        'Tag','FitGammaButton',...
        'String','<html>Fit &gamma;-factor</html>',...
        'TooltipString','<html>Fit &gamma;-factor by linear interpolation of 1/S vs. E.<br>At least 2 FRET species are required.<br>Uses currently selected bursts.</html>',...
        'FontSize',12,...
        'UIContextMenu',h.Menu_gammadetermination,...
        'Callback',@DetermineCorrections);
    
    %%% Button for manual gamma determination
    h.CalculateGammaButton = uicontrol(...
        'Parent',h.CorrectionsButtonsContainer,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.86 0.4 0.03],...
        'Style','pushbutton',...
        'Tag','CalculateGammaButton',...
        'String','<html>Calculate &gamma;-factor</html>',...
        'TooltipString','<html>Calculates the &gamma;-factor from specified center values</html>',...
        'FontSize',12,...
        'Callback',@CalculateGammaGUI);
    
    %%% Button to determine gamma from lifetime
    h.DetermineGammaLifetimeTwoColorButton = uicontrol(...
        'Parent',h.CorrectionsButtonsContainer,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.91 0.5 0.03],...
        'Style','pushbutton',...
        'Tag','DetermineGammaLifetimeTwoColorButton',...
        'String','<html>Fit &gamma;-factor from lifetime</html>',...
        'TooltipString','<html>Determine &gamma;-factor from lifetime. <br>Minimizes deviation between data and static FRET line.<br>Uses currently selected bursts.</html>',...
        'FontSize',12,...
        'Callback',@DetermineCorrections);
    
    %     h.GetBackgroundTwoColorButton = uicontrol(...
    %         'Parent',h.SecondaryTabCorrectionsPanel,...
    %         'Units','normalized',...
    %         'BackgroundColor', Look.Control,...
    %         'ForegroundColor', Look.Fore,...
    %         'Position',[0.5 0.86 0.5 0.03],...
    %         'Style','pushbutton',...
    %         'Tag','GetBackgroundTwoColorButton',...
    %         'String','Get Background from data',...
    %         'FontSize',12,...
    %         'Callback',@GetBackground);
    
    h.DetermineGammaLifetimeThreeColorButton = uicontrol(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.86 0.5 0.03],...
        'Style','pushbutton',...
        'Tag','DetermineGammaLifetimeThreeColorButton',...
        'String','<html>Fit &gamma;-factor from lifetime (3C)</html>',...
        'TooltipString','<html>Determine &gamma;<sub>BG</sub> and &gamma;<sub>BR</sub> from lifetime (3C)<br>Minimizes the deviation between data and static FRET line for total FRET efficiency from B->G+R and blue lifetime.<br>Uses currently selected bursts and takes previously determined value for &gamma;<sub>GR</sub> for calculations.</html>',...
        'FontSize',12,...
        'Callback',@DetermineCorrections,...
        'Visible','off');
    
    %     h.GetBackgroundThreeColorButton = uicontrol(...
    %         'Parent',h.SecondaryTabCorrectionsPanel,...
    %         'Units','normalized',...
    %         'BackgroundColor', Look.Control,...
    %         'ForegroundColor', Look.Fore,...
    %         'Position',[0.5 0.81 0.5 0.03],...
    %         'Style','pushbutton',...
    %         'Tag','GetBackgroundThreeColorButton',...
    %         'String','Get Background from data',...
    %         'FontSize',12,...
    %         'Callback',@GetBackground,...
    %         'Visible','off');
    
    %%% Button to apply custom correction factors
    h.ApplyCorrectionsButton = uicontrol(...
        'Parent',h.CorrectionsButtonsContainer,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.81 0.4 0.03],...
        'Style','pushbutton',...
        'Tag','ApplyCorrectionsButton',...
        'String','Apply Corrections',...
        'TooltipString','Apply corrections to selected data',...
        'FontSize',12,...
        'Callback',@ApplyCorrections);
    h.ApplyCorrection_Menu = uicontextmenu;
    h.ApplyCorrectionsAll_Menu = uimenu(...
        'Parent',h.ApplyCorrection_Menu,...
        'Tag','ApplyCorrectionsAll_Menu',...
        'Label','Replace corrections of all files with current one',...
        'Callback',@ApplyCorrections);
    set(h.ApplyCorrectionsButton,'UIContextMenu',h.ApplyCorrection_Menu);
    %%% Checkbox to enabel/disable beta factor Stoichiometry corrections
    %%% (Corrects S to be 0.5 for double labeled)
    h.UseBetaCheckbox = uicontrol(...
        'Parent',h.CorrectionsButtonsContainer,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.76 0.4 0.03],...
        'Style','checkbox',...
        'Tag','UseBetaCheckbox',...
        'Value',UserValues.BurstBrowser.Corrections.UseBeta,...
        'String','<html>&beta - Correction of Stoichiometry</html>',...
        'TooltipString','<html>Applies &beta correction of Stoichiometry accounting for<br>different excitation efficiencies.</html>',...
        'FontSize',12,...
        'Callback',@ApplyCorrections);
    
    %%% Table for Corrections factors
    Corrections_Rownames = {'<html><b>&gamma</b></html>','<html><b>&beta</b></html>',...
        '<html><b>crosstalk</b></html>','<html><b>direct exc.</b></html>',...
        '<html><b>G(green)</b></html>','<html><b>G(red)</b></html>',...
        '<html><b>l1</b></html>','<html><b>l2</b></html>',...
        '<html><b>BG DD par</b></html>','<html><b>BG DD perp</b></html>','<html><b>BG DA par</b></html>',...
        '<html><b>BG DA perp</b></html>','<html><b>BG AA par</b></html>','<html><b>BG AA perp</b></html>'}';
    Corrections_Columnnames = {'<html><b>Parameter</b></html>','<html><b>Value</b></html>'};
    Corrections_Editable = [false,true];
    Corrections_Data = {1;1;0;0;1;1;0;0;0:0;0;0;0;0;0};
    Corrections_Columnformat = {'char','numeric'};
    Tooltip = ['<html>Correction factors:<br>',...
        '&gamma: Detection efficiency ratio red over green<br>',...
        '&beta: Excitation efficiency ratio red over green<br>',...
        'crosstalk: Spectral crosstalk as percentage of donor signal<br>',...
        'direct exc.: Direct acceptor excitation by donor laser as percentage of acceptor signal after direct acceptor probing<br>',...
        'G: Detection efficiency ratio perpendicular over parallel channel<br>',...
        'l1,l2: Anisotropy correction factors accounting for polarization mixing by high N.A. objective<br>',...
        'BG: Background counts per channel in kHz',...
        '</html>'];
    h.CorrectionsTable = uitable(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'Tag','CorrectionsTable',...
        'Position',[0.5 0.4 0.5 0.6],...
        'Data',horzcat(Corrections_Rownames,Corrections_Data),...
        'BackgroundColor', [Look.Table1;Look.Table2],...
        'ForegroundColor', Look.TableFore,...
        'RowName',[],...
        'ColumnName',Corrections_Columnnames,...
        'ColumnEditable',Corrections_Editable,...
        'ColumnFormat',Corrections_Columnformat,...
        'ColumnWidth',{100,50},...
        'TooltipString',Tooltip,...
        'CellEditCallback',@UpdateCorrections,...
        'ForegroundColor',[0,0,0]);
    
    %%% Uipanel for fitting lifetime-related quantities
    h.FitLifetimeRelatedPanel = uipanel(...
        'Parent',h.Secondary_Tab_Fitting,...
        'Units','normalized',...
        'Position',[0 0.5 1 0.5],...
        'Tag','DisplayOptionsPanel',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'Title','Lifetime Plots',...
        'HighlightColor',Look.Fore,...
        'FontSize',12);
    
    h.FitAnisotropyButton = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.05 0.89 0.4 0.1],...
        'Style','pushbutton',...
        'Tag','FitAnisotropyButton',...
        'String','Fit Anisotropy',...
        'FontSize',12,...
        'TooltipString','<html>Fit Perrin line to anisotropy plots.<br>r(&tau)=r<sub>0</sub>/(1+&tau/&rho)</html>',...
        'Callback',@UpdateLifetimeFits);
    
    h.ManualAnisotropyButton = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.05 0.79 0.4 0.1],...
        'Style','pushbutton',...
        'Tag','ManualAnisotropyButton',...
        'String','Manual Perrin line',...
        'TooltipString','<html>Add manual Perrin line to anisotropy plots by clicking species mid-point.<br>r(&tau)=r<sub>0</sub>/(1+&tau/&rho)<br>Left-click adds first line or resets if multiple lines were present.<br>Right-click adds new line (up to three).</html>',...
        'FontSize',12,...
        'Callback',@UpdateLifetimeFits);
    
    h.r0Green_text = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.92 0.2 0.07],...
        'Style','text',...
        'Tag','r0GG_text',...
        'String','r0 Donor',...
        'HorizontalAlignment','left',...
        'TooltipString','Fundamental anisotropy of green dye',...
        'FontSize',12);
    
    h.r0Green_edit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.75 0.92 0.2 0.07],...
        'Style','edit',...
        'Tag','r0Green_edit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.r0_green),...
        'TooltipString','Fundamental anisotropy of green dye',...
        'FontSize',12,...
        'Callback',@UpdateCorrections);
    
    h.r0Red_text = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.84 0.2 0.07],...
        'Style','text',...
        'HorizontalAlignment','left',...
        'Tag','r0RR_text',...
        'String','r0 Acceptor',...
        'TooltipString','Fundamental anisotropy of red dye',...
        'FontSize',12);
    
    h.r0Red_edit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.75 0.84 0.2 0.07],...
        'Style','edit',...
        'Tag','r0Red_edit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.r0_red),...
        'TooltipString','Fundamental anisotropy of red dye',...
        'FontSize',12,...
        'Callback',@UpdateCorrections);
    
    h.r0Blue_text = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.76 0.2 0.07],...
        'Style','text',...
        'Tag','r0BB_text',...
        'HorizontalAlignment','left',...
        'String','r0 Blue',...
        'TooltipString','Fundamental anisotropy of blue dye',...
        'FontSize',12,...
        'Visible','off');
    
    h.r0Blue_edit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.75 0.76 0.2 0.07],...
        'Style','edit',...
        'Tag','r0Blue_edit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.r0_blue),...
        'TooltipString','Fundamental anisotropy of blue dye',...
        'FontSize',12,...
        'Visible','off',...
        'Callback',@UpdateCorrections);
    
    h.PlotStaticFRETButton = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.05 0.55 0.4 0.1],...
        'Style','pushbutton',...
        'Tag','PlotStaticFRETButton',...
        'String','Plot static FRET line',...
        'TooltipString','<html>Add static FRET line: E=1-&tau<sub>D,A</sub>/&tau<sub>D,0</sub><br>Includes linker contributions given by F?rster radius and effective linker length.</html>',...
        'FontSize',12,...
        'Callback',@UpdateLifetimeFits);
    
    h.DynamicFRET_Menu = uicontextmenu;
    h.DynamicFRETManual_Menu = uimenu(...
        'Parent',h.DynamicFRET_Menu,...
        'Tag','DynamicFRETManual_Menu',...
        'Callback',@UpdateLifetimeFits,...
        'Label','Define States');
    h.DynamicFRETRemove_Menu = uimenu(...
        'Parent',h.DynamicFRET_Menu,...
        'Tag','DynamicFRETRemove_Menu',...
        'Callback',@UpdateLifetimeFits,...
        'Label','Remove Plot');
    
    h.PlotDynamicFRETButton = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.55 0.55 0.4 0.1],...
        'Style','pushbutton',...
        'Tag','PlotDynamicFRETButton',...
        'String','Dynamic FRET line',...
        'TooltipString','<html>Add dynamic FRET line by clicking start and end point donor lifetimes in Efficiency-&tau<sub>DA</sub> plot<br>Right-click: Open menu to enter state donor lifetimes manually or remove plots.<br>A total of three lines can be added.</html>',...
        'FontSize',12,...
        'UIContextMenu',h.DynamicFRET_Menu,...
        'Callback',@UpdateLifetimeFits);
    
    h.DonorLifetimeText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.05 0.45 0.35 0.07],...
        'HorizontalAlignment','left',...
        'Style','text',...
        'Tag','SelectDonorDyeText',...
        'String','Donor Lifetime (ns)',...
        'TooltipString','Lifetime of the donor dye in absence of the acceptor dye',...
        'FontSize',12);
    
    h.DonorLifetimeEdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.37 0.45 0.1 0.07],...
        'Style','edit',...
        'Tag','DonorLifetimeEdit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.DonorLifetime),...
        'TooltipString','Lifetime of the donor dye in absence of the acceptor dye',...
        'FontSize',12,...
        'Callback',@UpdateCorrections);
    
    h.AcceptorLifetimeText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.05 0.3 0.35 0.07],...
        'HorizontalAlignment','left',...
        'Style','text',...
        'Tag','SelectAcceptorDyeText',...
        'String','Acceptor Lifetime (ns)',...
        'TooltipString','Lifetime of the acceptor dye',...
        'FontSize',12);
    
    h.AcceptorLifetimeEdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.37 0.3 0.1 0.07],...
        'Style','edit',...
        'Tag','AcceptorLifetimeEdit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.AcceptorLifetime),...
        'TooltipString','Lifetime of the acceptor dye',...
        'FontSize',12,...
        'Callback',@UpdateCorrections);
    
    h.DonorLifetimeBlueText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.05 0.15 0.35 0.07],...
        'Style','text',...
        'Tag','DonorLifetimeBlueText',...
        'String','Donor Lifetime Blue (ns)',...
        'TooltipString','Lifetime of the blue dye in absence of the acceptor dyes',...
        'HorizontalAlignment','left',...
        'Visible','off',...
        'FontSize',12);
    
    h.DonorLifetimeBlueEdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.37 0.15 0.1 0.07],...
        'Style','edit',...
        'Tag','DonorLifetimeBlueEdit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.DonorLifetimeBlue),...
        'TooltipString','Lifetime of the blue dye in absence of the acceptor dyes',...
        'FontSize',12,...
        'Visible','off',...
        'Callback',@UpdateCorrections);
    
    h.DonorLifetimeFromDataCheckbox = uicontrol(....
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.05 0.05 0.4 0.1],...
        'Style','pushbutton',...
        'Tag','DonorLifetimeFromDataCheckbox',...
        'String','Get dye lifetimes from data',...
        'TooltipString','Extract dye lifetimes from single-labeled subpopulations using stoichiometry threshold.',...
        'enable','off',...
        'FontSize',12,...
        'Callback',@DonorOnlyLifetimeCallback);
    
    h.FoersterRadiusText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.45 0.35 0.07],...
        'Style','text',...
        'Tag','FoersterRadiusText',...
        'String','Foerster Radius [A]',...
        'HorizontalAlignment','left',...
        'FontSize',12);
    
    h.FoersterRadiusEdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.87 0.45 0.1 0.07],...
        'Style','edit',...
        'Tag','FoersterRadiusEdit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.FoersterRadius),...
        'FontSize',12,...
        'Callback',@UpdateCorrections);
    
    h.LinkerLengthText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.37 0.35 0.07],...
        'Style','text',...
        'Tag','LinkerLengthText',...
        'String','Linker Length [A]',...
        'HorizontalAlignment','left',...
        'FontSize',12);
    
    h.LinkerLengthEdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.87 0.37 0.1 0.07],...
        'Style','edit',...
        'Tag','LinkerLengthEdit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.LinkerLength),...
        'FontSize',12,...
        'Callback',@UpdateCorrections);
    
    h.FoersterRadiusBGText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.29 0.35 0.07],...
        'Style','text',...
        'Tag','FoersterRadiusBGText',...
        'HorizontalAlignment','left',...
        'String','Foerster Radius BG [A]',...
        'FontSize',12,...
        'Visible','off');
    
    h.FoersterRadiusBGEdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.87 0.29 0.1 0.07],...
        'Style','edit',...
        'Tag','FoersterRadiusBGEdit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.FoersterRadiusBG),...
        'FontSize',12,...
        'Visible','off',...
        'Callback',@UpdateCorrections);
    
    h.LinkerLengthBGText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.21 0.35 0.07],...
        'Style','text',...
        'Tag','LinkerLengthBGText',...
        'HorizontalAlignment','left',...
        'String','Linker Length BG [A]',...
        'Visible','off',...
        'FontSize',12);
    
    h.LinkerLengthBGEdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.87 0.21 0.1 0.07],...
        'Style','edit',...
        'Tag','F?rsterRadiusEdit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.LinkerLengthBG),...
        'FontSize',12,...
        'Visible','off',...
        'Callback',@UpdateCorrections);
    
    h.FoersterRadiusBRText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.13 0.35 0.07],...
        'Style','text',...
        'Tag','FoersterRadiusBRText',...
        'HorizontalAlignment','left',...
        'String','Foerster Radius BR [A]',...
        'Visible','off',...
        'FontSize',12);
    
    h.FoersterRadiusBREdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.87 0.13 0.1 0.07],...
        'Style','edit',...
        'Tag','FoersterRadiusBREdit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.FoersterRadiusBR),...
        'FontSize',12,...
        'Visible','off',...
        'Callback',@UpdateCorrections);
    
    h.LinkerLengthBRText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.05 0.35 0.07],...
        'Style','text',...
        'Tag','LinkerLengthBRText',...
        'HorizontalAlignment','left',...
        'Visible','off',...
        'String','Linker Length BR [A]',...
        'FontSize',12);
    
    h.LinkerLengthBREdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.87 0.05 0.1 0.07],...
        'Style','edit',...
        'Tag','FoersterRadiusBREdit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.LinkerLengthBR),...
        'FontSize',12,...
        'Visible','off',...
        'Callback',@UpdateCorrections);
    %% Secondary tab correlation
    h.Correlation_Panel = uipanel(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'Position',[0 0 1 0.4],...
        'Tag','DisplayOptionsPanel',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'Title','Burstwise FCS',...
        'HighlightColor',Look.Fore,...
        'FontSize',12);
    %%% Contexmenu for correlation table
    h.Secondary_Tab_Correlation_Menu = uicontextmenu;
    
    %%% Sets a divider for correlation
    h.Secondary_Tab_Correlation_Standard2CMFD_Menu = uimenu(...
        'Parent',h.Secondary_Tab_Correlation_Menu,...
        'Label','FRET FCCS selection',...
        'Tag','Secondary_Tab_Correlation_Standard2CMFD_Menu',...
        'Callback',@Calculate_Settings,...
        'Visible','off');
    h.Secondary_Tab_Correlation_Reset_Menu = uimenu(...
        'Parent',h.Secondary_Tab_Correlation_Menu,...
        'Label','Reset',...
        'Tag','Secondary_Tab_Correlation_Reset_Menu',...
        'Callback',@Calculate_Settings);
    h.Secondary_Tab_Correlation_Divider_Menu = uimenu(...
        'Parent',h.Secondary_Tab_Correlation_Menu,...
        'Label',['Divider: ' num2str(UserValues.Settings.Pam.Cor_Divider)],...
        'Tag','Secondary_Tab_Correlation_Divider_Menu',...
        'Callback',@Calculate_Settings,...
        'Separator','on');
    
    Names = {'DD1','DD2','DA1','DA2','AA1','AA2','DD','DA','DX','DX1','DX2','AA'};
    h.Correlation_Table = uitable(...
        'Parent',h.Correlation_Panel,...
        'Units','normalized',...
        'Position',[0 0.12 1 0.88],...
        'Tag','CorrelationTable',...
        'TooltipString',sprintf([...
        'Rightclick to open contextmenu with additional function: \n'...
        'Divider: Divider for correlation time resolution for certain excitation schemes']),...
        'UIContextMenu',h.Secondary_Tab_Correlation_Menu,...
        'ColumnWidth',{40},...
        'ColumnEditable',true,...
        'ColumnName',Names,...
        'BackgroundColor', [Look.Table1;Look.Table2],...
        'ForegroundColor', Look.TableFore,...
        'RowName',Names,...
        'Data',false(numel(Names)));
    
    h.Correlate_Button = uicontrol(...
        'Style','pushbutton',...
        'Parent',h.Correlation_Panel,...
        'Units','normalized',...
        'Position',[0.01 0.025 0.25 0.08],...
        'Tag','Correlate_Button',...
        'String','Correlate',...
        'ForegroundColor',Look.Fore,...
        'BackgroundColor',Look.Control,...
        'FontSize',12,...
        'Callback',@Correlate_Bursts);
    
%     h.LoadAllPhotons_Button = uicontrol(...
%         'Style','pushbutton',...
%         'Parent',h.SecondaryTabCorrelationPanel,...
%         'Units','normalized',...
%         'Position',[0 0.45 0.3 0.05],...
%         'ForegroundColor',Look.Fore,...
%         'BackgroundColor',Look.Control,...
%         'Tag','LoadAllPhotons_Button',...
%         'String','Load All Photons (*.aps)',...
%         'FontSize',12,...
%         'Callback',@Load_Photons);
    h.CorrelateWindow_Menu = uicontextmenu;
    h.BurstwiseDiffusionTime_Menu = uimenu(...
        'Parent',h.CorrelateWindow_Menu,...
        'Label','Fit burst wise diffusion time',...
        'Callback',@Correlate_Bursts);
    h.CorrelateWindow_Button = uicontrol(...
        'Style','pushbutton',...
        'Parent',h.Correlation_Panel,...
        'Units','normalized',...
        'Position',[0.27 0.025 0.33 0.08],...
        'Tag','CorrelateWindow_Button',...
        'String','Correlate with time window',...
        'ForegroundColor',Look.Fore,...
        'BackgroundColor',Look.Control,...
        'Callback',@Correlate_Bursts,...
        'FontSize',12,...
        'Enable','on',...
        'UIContextMenu',h.CorrelateWindow_Menu);
    
    h.CorrelateWindow_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.Correlation_Panel,...
        'Units','normalized',...
        'BackgroundColor',Look.Control,...
        'ForegroundColor',Look.Fore,...
        'Position',[0.87 0.025 0.12 0.08],...
        'Tag','CorrelateWindow_Edit',...
        'String',num2str(UserValues.BurstBrowser.Settings.Corr_TimeWindowSize),...
        'Callback',@UpdateOptions,...
        'FontSize',12,...
        'Enable','on');
    
    h.CorrelateWindow_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Correlation_Panel,...
        'Units','normalized',...
        'Position',[0.6 0.035 0.265 0.08],...
        'Tag','CorrelateWindow_Text',...
        'String','Time window [ms]:',...
        'Callback',@UpdateOptions,...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'HorizontalAlignment','right',...
        'FontSize',12,...
        'Enable','on');
    
    %%% Gaussian mixture fitting
    h.FitGaussian_Panel = uipanel(...
        'Parent',h.Secondary_Tab_Fitting,...
        'Units','normalized',...
        'Position',[0 0 1 0.5],...
        'Tag','FitGaussian_Panel',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'Title','Gaussian Mixture Fitting',...
        'HighlightColor',Look.Fore,...
        'FontSize',12);
    
    h.Fit_Gaussian_Button = uicontrol(...
        'Parent',h.FitGaussian_Panel,...
        'Callback',@UpdatePlot,...
        'Units','normalized',...
        'Position',[0.1,0.9,0.3,0.08],...
        'String','Fit Gaussian mixture',...
        'ForegroundColor',Look.Fore,...
        'BackgroundColor',Look.Control,...
        'FontSize',12,...
        'TooltipString','<html>Fits a Gaussian mixture model to current 2D plot using the gmdistfit function in Matlab.<br>To fit 1D only, select the same parameter for x and y.<br>Set number of Gaussian using the popupmenu.<br>Start points are guessed unless fixed when using LSQ.</html>');
    h.Fit_NGaussian_Popupmenu = uicontrol('Style','popup',...
        'Units','normalized',...
        'Callback',@UpdateOptions,...
        'Position',[0.4,0.9,0.2,0.08],...
        'String',{'1','2','3','4','5'},...
        'Parent',h.FitGaussian_Panel,...
        'FontSize',12,...
        'TooltipStr','Number of Gaussian components of the model.');
    h.Fit_Gaussian_Pick = uicontrol('Style','checkbox',...
        'Units','normalized',...
        'Callback',@UpdateOptions,...
        'Value',UserValues.BurstBrowser.Settings.FitGaussPick,...
        'Position',[0.6,0.9,0.4,0.08],...
        'String','Pick start points manually',...
        'Parent',h.FitGaussian_Panel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'FontSize',12,...
        'TooltipString','If selected, you are required to manually select the start point for the fit by clicking inside the 2D plot.');
    h.Fit_GaussianMethod_Popupmenu = uicontrol('Style','popup',...
        'Units','normalized',...
        'Callback',@UpdateOptions,...
        'Position',[0.4,0.8,0.2,0.08],...
        'String',{'MLE','LSQ'},...
        'Value',find(strcmp({'MLE','LSQ'},UserValues.BurstBrowser.Settings.GaussianFitMethod)),...
        'Parent',h.FitGaussian_Panel,...
        'FontSize',12,...
        'TooltipStr','Fit Method. LSQ allows fixing of parameters.');
    h.Fit_GaussianChi2_Text = uicontrol('Style','text',...
        'Units','normalized',...
        'Callback',@UpdateOptions,...
        'Position',[0.6,0.8,0.4,0.08],...
        'String','',...
        'HorizontalAlignment','center',...
        'Parent',h.FitGaussian_Panel,...
        'FontSize',12,...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'TooltipStr','red. Chi2 value');
    h.FitTable_ContextMenu = uicontextmenu;
    h.FitTable_SpeciesFromGaussFit = uimenu(h.FitTable_ContextMenu,'Label','Copy fit result to clipboard','Callback',@CopyFitresultToClipboard);
    h.FitTable_SpeciesFromGaussFit = uimenu(h.FitTable_ContextMenu,'Label','Define Species from Fit','Callback',@SpeciesFromGaussianFit,'Separator','on');
    h.GUIData.TableDataMLE = cell(8,6);
    h.GUIData.TableDataMLE(3,1:6) = {'<html><b>Fraction</b></html>','<html><b>Mean(X)</b></html>','<html><b>Mean(Y)</b></html>','<html><b>&sigma(XX)</b></html>','<html><b>&sigma(YY)</b></html>','<html><b>COV(XY)</b></html>'};
    h.GUIData.ColumnNameMLE = {'<html><b>Converged</b></html>','<html><b>-logL</b></html>','<html><b>BIC</b></html>'};
    h.GUIData.ColumnEditableMLE = false(1,6);
    h.GUIData.ColumnWidthMLE = {100,100,100,100,100,100,100};
    h.GUIData.ColumnFormatMLE = repmat({'numeric'},1,7);
    h.GUIData.TableDataLSQ = num2cell(repmat([1,0,1,false,0.5,0,Inf,false,0.5,0,Inf,false,0.05,0.01,Inf,false,0.05,0.01,Inf,false,0,-Inf,Inf,false],[5,1]));
    for i =1:5
        h.GUIData.TableDataLSQ(i,4:4:end) = {false,false,false,false,false,false};
    end
    h.GUIData.ColumnEditableLSQ = true(1,24);
    h.GUIData.ColumnNameLSQ = {'<html><b>Fraction</b></html>','LB','UB','F','<html><b>Mean(X)</b></html>','LB','UB','F','<html><b>Mean(Y)</b></html>','LB','UB','F','<html><b>&sigma(XX)</b></html>','LB','UB','F','<html><b>&sigma(YY)</b></html>','LB','UB','F','<html><b>COV(XY)</b></html>','LB','UB','F'};
    h.GUIData.ColumnWidthLSQ = repmat({60,25,25,20},[1,6]);
    h.GUIData.ColumnFormatLSQ = repmat({'numeric','numeric','numeric','logical'},[1,6]);
    switch UserValues.BurstBrowser.Settings.GaussianFitMethod
        case 'MLE'
            h.Fit_Gaussian_Text = uitable(...
                'Units','normalized',...
                'Position',[0,0,1,0.75],...
                'Parent',h.FitGaussian_Panel,...
                'FontSize',12,...
                'ColumnName',h.GUIData.ColumnNameMLE,...
                'RowName',[],...
                'ColumnEditable',h.GUIData.ColumnEditableMLE,...
                'Data',h.GUIData.TableDataMLE,...
                'ColumnWidth',h.GUIData.ColumnWidthMLE,...
                'ColumnFormat',h.GUIData.ColumnFormatMLE,...
                'UIContextMenu',h.FitTable_ContextMenu,...
                'TooltipString','<html>Result of the Gaussian mixture fit.<br>If "converged" is zero, the fit did not converge. <br>-logL: negative log-likelihood. <br>BIC: Bayesian information criterion. The model with the lowest value is preferred.<br>Distribution widths are given as &sigma=sqrt(&sigma<sup>2</sup>), while the covariance COV(XY) is given as actual variance.</html>');
        case 'LSQ'
            h.Fit_Gaussian_Text = uitable(...
                'Units','normalized',...
                'Position',[0,0,1,0.75],...
                'Parent',h.FitGaussian_Panel,...
                'FontSize',12,...
                'ColumnName',h.GUIData.ColumnNameLSQ,...
                'ColumnFormat',h.GUIData.ColumnFormatLSQ,...
                'RowName',[],...
                'ColumnEditable',h.GUIData.ColumnEditableLSQ,...
                'Data',h.GUIData.TableDataLSQ,...
                'ColumnWidth',h.GUIData.ColumnWidthLSQ,...
                'UIContextMenu',h.FitTable_ContextMenu,...
                'TooltipString','<html>Gaussian fit table</html>');
    end
    %% Secondary tab options
    s.ProgressRatio = 0.75;
    %%% Display Options Panel
    h.DisplayOptionsPanel = uipanel(...
        'Parent',h.SecondaryTabOptionsPanel,...
        'Units','normalized',...
        'Position',[0 0.5 1 0.5],...
        'Tag','DisplayOptionsPanel',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'HighlightColor', Look.Fore,...
        'Title','Display Options',...
        'FontSize',12);
    
    %%% Specify the Number of Bins
    h.NbinsXText = uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Number of Bins X',...
        'Tag','Text_Number_of_BinsX',...
        'Units','normalized',...
        'Position',[0 0.92 0.25 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    h.NumberOfBinsXEdit = uicontrol(...
        'Style','edit',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.3 0.92 0.2 0.07],...
        'FontSize',12,...
        'Tag','NumberOfBinsEdit',...
        'String',UserValues.BurstBrowser.Display.NumberOfBinsX,...
        'Callback',@UpdatePlot...
        );
    %%% log X option
    h.logX_checkbox = uicontrol(...
        'Style','checkbox',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.5 0.92 0.2 0.07],...
        'FontSize',12,...
        'Tag','logX_checkbox',...
        'Value',UserValues.BurstBrowser.Display.logX,...
        'String','logX',...
        'TooltipStr','Logarithmic X-axis',...
        'Callback',@UpdatePlot...
        );
    h.NBinsYText = uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Number of Bins Y',...
        'Tag','Text_Number_of_BinsY',...
        'Units','normalized',...
        'Position',[0 0.85 0.25 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    h.NumberOfBinsYEdit = uicontrol(...
        'Style','edit',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.3 0.85 0.2 0.07],...
        'FontSize',12,...
        'Tag','NumberOfBinsEdit',...
        'String',UserValues.BurstBrowser.Display.NumberOfBinsY,...
        'Callback',@UpdatePlot...
        );
    %%% log Y option
    h.logY_checkbox = uicontrol(...
        'Style','checkbox',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.5 0.85 0.2 0.07],...
        'FontSize',12,...
        'Tag','logY_checkbox',...
        'Value',UserValues.BurstBrowser.Display.logY,...
        'String','logY',...
        'TooltipStr','Logarithmic Y-axis',...
        'Callback',@UpdatePlot...
        );
    %%% Plot grid lines above data
    h.PlotGridAboveDataCheckbox = uicontrol(...
        'Style','checkbox',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.7 0.92 0.3 0.07],...
        'FontSize',12,...
        'Tag','PlotGridAboveDataCheckbox',...
        'Value',UserValues.BurstBrowser.Display.PlotGridAboveData,...
        'String','Plot grid on top of data',...
        'TooltipStr','Choose to overlay grid lines on data, or to plot grid lines behind data.',...
        'Callback',@UpdateGUIOptions...
        );
    %%% Plot grid lines above data
    h.Restrict_EandS_Range = uicontrol(...
        'Style','checkbox',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.7 0.85 0.3 0.07],...
        'FontSize',12,...
        'Tag','Restrict_EandS_Range',...
        'Value',UserValues.BurstBrowser.Display.Restrict_EandS_Range,...
        'String','Restrict E and S range',...
        'TooltipStr','Restrict Efficiency and Stoichiometry plot ranges to [-0.1,1.1].',...
        'Callback',@UpdatePlot...
        );
    
    %%% Specify the Plot Type
    h.PlotTypeText = uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Plot Type',...
        'Tag','Text_Plot_Type',...
        'Units','normalized',...
        'Position',[0 0.75 0.4 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    PlotType_String = {'Image','Contour','Scatter','Hex'};
    h.PlotTypePopumenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.4 0.75 0.2 0.07],...
        'FontSize',12,...
        'Tag','PlotTypePopupmenu',...
        'String',PlotType_String,...
        'Value',find(strcmp(PlotType_String,UserValues.BurstBrowser.Display.PlotType)),...
        'Callback',@ChangePlotType...
        );
    %%% Contour plot settings
    h.NumberOfContourLevels_text = uicontrol(...
        'Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.62 0.75 0.28 0.07],...
        'FontSize',12,...
        'Tag','NumberOfContourLevels_edit',...
        'String','# Contour Levels'...
        );
    
    h.NumberOfContourLevels_edit = uicontrol(...
        'Style','edit',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.9 0.75 0.1 0.07],...
        'FontSize',12,...
        'Tag','NumberOfContourLevels_edit',...
        'String',num2str(UserValues.BurstBrowser.Display.NumberOfContourLevels),...
        'Callback',@UpdatePlot...
        );
    
    h.PlotOffset_text = uicontrol(...
        'Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.62 0.65 0.28 0.07],...
        'FontSize',12,...
        'Tag','ContourOffset_text',...
        'String','Plot Offset [%]'...
        );
    
    h.PlotOffset_edit = uicontrol(...
        'Style','edit',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.9 0.65 0.1 0.07],...
        'FontSize',12,...
        'Tag','NumberOfContourLevels_edit',...
        'String',num2str(UserValues.BurstBrowser.Display.ContourOffset),...
        'Callback',@UpdatePlot...
        );
    
    %%% scatter plot settings
    h.MarkerColor_text = uicontrol(...
        'Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.62 0.75 0.28 0.07],...
        'FontSize',12,...
        'Tag','MarkerColor_text',...
        'String','Marker Color'...
        );
    h.MarkerColor_button = uicontrol('Style','pushbutton',...
        'Parent',h.DisplayOptionsPanel,...
        'String','',...
        'Tag','MarkerColor_button',...
        'Units','normalized',...
        'Position',[0.9 0.75 0.1 0.07],...
        'FontSize',12,...
        'BackgroundColor', UserValues.BurstBrowser.Display.MarkerColor,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateLineColor...
        );
    
    h.MarkerSize_text = uicontrol(...
        'Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.62 0.65 0.28 0.07],...
        'FontSize',12,...
        'Tag','MarkerSize_text',...
        'String','Marker Size'...
        );
    
    h.MarkerSize_edit = uicontrol(...
        'Style','edit',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.9 0.65 0.1 0.07],...
        'FontSize',12,...
        'Tag','NumberOfContourLevels_edit',...
        'String',num2str(UserValues.BurstBrowser.Display.MarkerSize),...
        'Callback',@UpdateGUIOptions...
        );
    %%% Specify the colormap
    h.ColormapText = uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Colormap',...
        'Tag','Text_ColorMap',...
        'Units','normalized',...
        'Position',[0 0.65 0.4 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    Colormaps_String = {'jet','jetvar','parula','hot','cool','spring','summer','autumn','winter','bone','gray','copper','pink','hsv'};
    if ischar(UserValues.BurstBrowser.Display.ColorMap)
        try
            colormap_val = find(strcmp(Colormaps_String,UserValues.BurstBrowser.Display.ColorMap));
        catch
            colormap_val = 1;
            UserValues.BurstBrowser.Display.ColorMap = Colormaps_String(1);
        end
    else
        colormap_val = 2;
    end
    h.ColorMapPopupmenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.4 0.65 0.2 0.07],...
        'FontSize',12,...
        'Tag','ColorMapPopupmenu',...
        'String',Colormaps_String,...
        'Value',colormap_val,...
        'Callback',@UpdatePlot...
        );
    
    h.ColorMapInvert = uicontrol(...
        'Style','checkbox',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.3 0.65 0.1 0.07],...
        'FontSize',12,...
        'Tag','ColorMapInvert',...
        'String','Invert',...
        'Value',UserValues.BurstBrowser.Display.ColorMapInvert,...
        'Callback',@UpdatePlot...
        );
    
    h.PlotContourLines = uicontrol('Style','checkbox',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Plot Contour Lines',...
        'Tag','PlotContourLines',...
        'Value', UserValues.BurstBrowser.Display.PlotContourLines,...
        'Units','normalized',...
        'Position',[0.52 0.55 0.48 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@ChangePlotType...
        );
    %%% Option to take log10 of 2D histogram
    h.Hist_log10 = uicontrol('Style','checkbox',...
        'Parent',h.DisplayOptionsPanel,...
        'String','take log10 of 2D histogram',...
        'Tag','Hist_log10',...
        'Value', 0,...
        'Units','normalized',...
        'Position',[0.02 0.55 0.4 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdatePlot...
        );
    %%% Option to display average values in 1d histograms
    h.DisplayAverage = uicontrol('Style','checkbox',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Display Average Value in 1D Histograms',...
        'Tag','DisplayAverage',...
        'Value', 0,...
        'Units','normalized',...
        'Position',[0.02 0.45 0.5 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdatePlot...
        );
    
    %%% Option to turn KDE estimate (data smoothing) on or off
    h.SmoothKDE = uicontrol('Style','checkbox',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Plot Kernel Density Estimate (Smoothing)',...
        'Tag','SmoothKDE',...
        'Value', UserValues.BurstBrowser.Display.KDE,...
        'Units','normalized',...
        'Position',[0.02 0.35 0.48 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdatePlot...
        );
    
    h.SaveFileExportFigure_Checkbox = uicontrol('Style','checkbox',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Save file when exporting figure',...
        'TooltipString','Save file when exporting figure',...
        'Tag','SaveFileExportFigure_Checkbox',...
        'Value', UserValues.BurstBrowser.Settings.SaveFileExportFigure,...
        'Units','normalized',...
        'Position',[0.02 0.25 0.48 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    
    %%% Option to  color-code a third parameter in 2d histograms using
    %%% colormap, while frequency is encoded in grayscale
    h.ZScale_Intensity = uicontrol('Style','checkbox',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Grayscale Intensity for ZScale',...
        'TooltipString','<html>Enable grayscale colormap for encoding frequency when using Z-Scale parameter to define colormap.<br>Affected by colormap brightening.</html>',...
        'Tag','ZScale_Intensity',...
        'Value', UserValues.BurstBrowser.Display.ZScale_Intensity,...
        'Units','normalized',...
        'Position',[0.52 0.45 0.48 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdatePlot...
        );
    %%% Option to brighten the grayscale colormap used for encoding
    %%% frequency information
    h.BrightenColorMap_text = uicontrol(...
        'Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'TooltipString','Brightens the colormap. Affects z-scaling and multiplot.',...
        'Position',[0.52 0.35 0.36 0.07],...
        'FontSize',12,...
        'Tag','BrightenColorMap_text',...
        'String','Brighten Colormap'...
        );
    
    h.BrightenColorMap_edit = uicontrol(...
        'Style','edit',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.88 0.35 0.1 0.07],...
        'FontSize',12,...
        'Tag','BrightenColorMap_edit',...
        'TooltipString','Brightens the colormap. Affects z-scaling and multiplot.',...
        'String',num2str(UserValues.BurstBrowser.Display.BrightenColorMap),...
        'Callback',@UpdatePlot...
        );
    %if ~UserValues.BurstBrowser.Display.ZScale_Intensity
    %    set([h.BrightenColorMap_text,h.BrightenColorMap_edit],'Visible','off');
    %end
    
    h.MultiPlot_PlotType = uicontrol('Style','checkbox',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Use black-to-white for multi plot',...
        'TooltipString','<html>Uses black-to-white color scaling for plotting multiple species,<br> instead of white-to-black RGB plot mode. <br> Affected by colormap brightening.</html>',...
        'Tag','SaveFileExportFigure_Checkbox',...
        'Value', UserValues.BurstBrowser.Display.MultiPlotMode,...
        'Units','normalized',...
        'Position',[0.52 0.25 0.48 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    
    h.ColorSettingContainer = uigridcontainer(h.DisplayOptionsPanel,...
        'GridSize',[2,6],...
        'Units','norm',...
        'Position',[0.02,0,0.96,.17],...
        'BackgroundColor',Look.Back);
    
    h.ColorLine1Text = uicontrol('Style','text',...
        'Parent',h.ColorSettingContainer,...
        'String','Line 1',...
        'Tag','ColorLine1Text',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    h.ColorLine2Text = uicontrol('Style','text',...
        'Parent',h.ColorSettingContainer,...
        'String','Line 2',...
        'Tag','ColorLine2Text',...
        'Units','normalized',...
        'Position',[0.21 0.1 0.12 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    h.ColorLine3Text = uicontrol('Style','text',...
        'Parent',h.ColorSettingContainer,...
        'String','Line 3',...
        'Tag','ColorLine3Text',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    h.ColorLine4Text = uicontrol('Style','text',...
        'Parent',h.ColorSettingContainer,...
        'String','Line 4',...
        'Tag','ColorLine4Text',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    h.ColorLine5Text = uicontrol('Style','text',...
        'Parent',h.ColorSettingContainer,...
        'String','Line 5',...
        'Tag','ColorLine5Text',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);

    h.ColorLine6Text = uicontrol('Style','text',...
        'Parent',h.ColorSettingContainer,...
        'String','Line 6',...
        'Tag','ColorLine6Text',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    h.ColorLine1 = uicontrol('Style','pushbutton',...
        'Parent',h.ColorSettingContainer,...
        'String','',...
        'Tag','ColorLine1',...
        'FontSize',12,...
        'BackgroundColor', UserValues.BurstBrowser.Display.ColorLine1,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateLineColor...
        );
    
    h.ColorLine2 = uicontrol('Style','pushbutton',...
        'Parent',h.ColorSettingContainer,...
        'String','',...
        'Tag','ColorLine2',...
        'FontSize',12,...
        'BackgroundColor', UserValues.BurstBrowser.Display.ColorLine2,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateLineColor...
        );
    
    h.ColorLine3 = uicontrol('Style','pushbutton',...
        'Parent',h.ColorSettingContainer,...
        'String','',...
        'Tag','ColorLine3',...
        'FontSize',12,...
        'BackgroundColor', UserValues.BurstBrowser.Display.ColorLine3,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateLineColor...
        );
    
    h.ColorLine4 = uicontrol('Style','pushbutton',...
        'Parent',h.ColorSettingContainer,...
        'String','',...
        'Tag','ColorLine4',...
        'FontSize',12,...
        'BackgroundColor', UserValues.BurstBrowser.Display.ColorLine4,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateLineColor...
        );
    
    h.ColorLine5 = uicontrol('Style','pushbutton',...
        'Parent',h.ColorSettingContainer,...
        'String','',...
        'Tag','ColorLine5',...
        'FontSize',12,...
        'BackgroundColor', UserValues.BurstBrowser.Display.ColorLine5,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateLineColor...
        );
    
    h.ColorLine6 = uicontrol('Style','pushbutton',...
        'Parent',h.ColorSettingContainer,...
        'String','',...
        'Tag','ColorLine6',...
        'FontSize',12,...
        'BackgroundColor', UserValues.BurstBrowser.Display.ColorLine6,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateLineColor...
        );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Data Processing Options Panel
    h.DataProcessingPanel = uipanel(...
        'Parent',h.SecondaryTabOptionsPanel,...
        'Units','normalized',...
        'Position',[0 0 1 0.5],...
        'Tag','DataProcessingPanel',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'Title','Data Processing Options',...
        'HighlightColor', Look.Fore,...
        'FontSize',12);
    
    %%% Option to enable/disable save dialog on closing
    h.SaveOnClose = uicontrol('Style','checkbox',...
        'Parent',h.DataProcessingPanel,...
        'String','Ask for saving when closing program',...
        'Tag','SaveOnClose',...
        'Value', UserValues.BurstBrowser.Settings.SaveOnClose,...
        'Units','normalized',...
        'Position',[0.1 0.88 0.8 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    
    h.TimeBinPDAText = uicontrol('Style','text',...
        'Parent',h.DataProcessingPanel,...
        'String','Timebin for PDA [ms]',...
        'Tag','TimeBinPDAText',...
        'Units','normalized',...
        'Position',[0.05 0.68 0.55 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    h.TimeBinPDAEdit = uicontrol(...
        'Style','edit',...
        'Parent',h.DataProcessingPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.6 0.68 0.2 0.07],...
        'FontSize',12,...
        'Tag','TimeBinPDAEdit',...
        'String',UserValues.BurstBrowser.Settings.PDATimeBin,...
        'Callback',@UpdateOptions,...
        'TooltipString', 'e.g. "1" or "0.2, 0.5, 0.75, 1"'...
        );
    
    h.ApplyCorrectionsOnLoad = uicontrol('Style','checkbox',...
        'Parent',h.DataProcessingPanel,...
        'String','Automatically apply default/stored corrections when loading a file',...
        'Tag','SaveOnClose',...
        'Value', UserValues.BurstBrowser.Settings.CorrectionOnLoad,...
        'Units','normalized',...
        'Position',[0.1 0.78 0.8 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    
    h.IsoLineGaussFit_Text = uicontrol('Style','text',...
        'Parent',h.DataProcessingPanel,...
        'String','Isoline height for Gaussian Fit Display',...
        'Tag','IsoLineGaussFit_Text',...
        'Units','normalized',...
        'Position',[0.05 0.58 0.55 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    h.IsoLineGaussFit_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.DataProcessingPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.6 0.58 0.2 0.07],...
        'FontSize',12,...
        'Tag','IsoLineGaussFit_Edit',...
        'String',num2str(UserValues.BurstBrowser.Settings.IsoLineGaussFit),...
        'Callback',@UpdateOptions...
        );
    
    h.CompareFRETHist_Waterfall = uicontrol('Style','checkbox',...
        'Parent',h.DataProcessingPanel,...
        'String','Make waterfall plot when comparing FRET histograms',...
        'Tag','CompareFRETHist_Waterfall',...
        'Value', UserValues.BurstBrowser.Settings.CompareFRETHist_Waterfall,...
        'Units','normalized',...
        'Position',[0.1 0.48 0.8 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    %%% Editboxes for S thresholds for species selection
    h.ThresholdsContainer = uigridcontainer(...
        'GridSize',[3,5],...
        'HorizontalWeight',[0.4,0.3,0.3,0.5,0.3],...
        'Parent',h.DataProcessingPanel,...
        'Units','norm',...
        'Position',[.02,.20,.7,.25],...
        'BackgroundColor',Look.Back);
    h.Threshold_Text = uicontrol('style','text',...
        'Parent',h.ThresholdsContainer,...
        'String','Thresholds:',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Threshold_MinText = uicontrol('style','text',...
        'Parent',h.ThresholdsContainer,...
        'String','Min',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Threshold_MaxText = uicontrol('style','text',...
        'Parent',h.ThresholdsContainer,...
        'String','Max',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Threshold_E1 = uicontrol('style','text',...
        'Parent',h.ThresholdsContainer,...
        'String','',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Threshold_E2 = uicontrol('style','text',...
        'Parent',h.ThresholdsContainer,...
        'String','',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Threshold_SDonlyText = uicontrol('style','text',...
        'Parent',h.ThresholdsContainer,...
        'String','S(D only)',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Threshold_S_Donly_Min_Edit = uicontrol('style','edit',...
        'Parent',h.ThresholdsContainer,...
        'String',num2str(UserValues.BurstBrowser.Settings.S_Donly_Min),...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@UpdateOptions);
    h.Threshold_S_Donly_Max_Edit = uicontrol('style','edit',...
        'Parent',h.ThresholdsContainer,...
        'String',num2str(UserValues.BurstBrowser.Settings.S_Donly_Max),...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@UpdateOptions);
    h.Threshold_EDonlyMaxText1 = uicontrol('style','text',...
        'Parent',h.ThresholdsContainer,...
        'String','',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Threshold_EDonlyMaxText2 = uicontrol('style','text',...
        'Parent',h.ThresholdsContainer,...
        'String','',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Threshold_SAonlyText = uicontrol('style','text',...
        'Parent',h.ThresholdsContainer,...
        'String','S(A only)',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Threshold_S_Aonly_Min_Edit = uicontrol('style','edit',...
        'Parent',h.ThresholdsContainer,...
        'String',num2str(UserValues.BurstBrowser.Settings.S_Aonly_Min),...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@UpdateOptions);
    h.Threshold_S_Aonly_Max_Edit = uicontrol('style','edit',...
        'Parent',h.ThresholdsContainer,...
        'String',num2str(UserValues.BurstBrowser.Settings.S_Aonly_Max),...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@UpdateOptions);
    h.Threshold_EAonlyMinText = uicontrol('style','text',...
        'Parent',h.ThresholdsContainer,...
        'String','EPR(A only) min',...
        'Units','normalized',...
        'TooltipStr','Minimum proximity ratio for Acceptor Only selection.',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Threshold_E_Aonly_Min_Edit = uicontrol('style','edit',...
        'Parent',h.ThresholdsContainer,...
        'String',num2str(UserValues.BurstBrowser.Settings.E_Aonly_Min),...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@UpdateOptions);
    %% Database tab   
    %%% Database list
    h.DatabaseBB.List = uicontrol(...
        'Parent',h.DatabaseBB.Panel,...
        'Tag','DatabaseBB_List',...
        'Style','listbox',...
        'Units','normalized',...
        'FontSize',12,...
        'Max',2,...
        'String',UserValues.BurstBrowser.DatabaseString,...
        'BackgroundColor', Look.List,...
        'ForegroundColor', Look.ListFore,...
        'KeyPressFcn',{@Database,0},...
        'Callback',{@Database,0},...
        'Tooltipstring', ['<html>'...
                          'List of files in database <br>',...
                          '<i>"return"</i>: Loads selected files<br>',...
                          '<I>"delete"</i>: Removes selected files from list </b>'],...
        'Position',[0.01 0.51 0.98 0.38]);
    h.DatabaseBB.Load = uicontrol(...
        'Parent',h.DatabaseBB.Panel,...
        'Tag','DatabaseBB_Load_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Load database',...
        'Callback',{@Database,3},...
        'Position',[0.05 0.95 0.25 0.035],...
        'Tooltipstring', 'Load database from file');
    %%% Button to add files to the database
    h.DatabaseBB.Save = uicontrol(...
        'Parent',h.DatabaseBB.Panel,...
        'Tag','DatabaseBB_Save_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Save Database',...
        'Callback',{@Database,4},...
        'Position',[0.05 0.91 0.25 0.035],...
        'enable', 'on',...
        'Tooltipstring', 'Save database to a file');
    %%% Button to add files to the database from dialog
    h.DatabaseBB.AddFiles = uicontrol(...
        'Parent',h.DatabaseBB.Panel,...
        'Tag','DatabaseBB_Correlate_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Add files to database',...
        'Callback',{@Database,1},...
        'Position',[0.35 0.95 0.3 0.035],...
        'enable', 'on',...
        'UserData',0,...
        'Tooltipstring', ''); 
    %%% Button to add all loaded files to the database
    h.DatabaseBB.AppendLoadedFiles = uicontrol(...
        'Parent',h.DatabaseBB.Panel,...
        'Tag','DatabaseBB_AppendLoadedFiles',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Append loaded files to database',...
        'Callback',{@Database,1},...
        'Position',[0.35 0.91 0.3 0.035],...
        'enable', 'off',...
        'UserData',0,...
        'Tooltipstring', '');  
    
    %%% Button to make database from selected folder
    h.DatabaseBB.DatabaseFromFolder = uicontrol(...
        'Parent',h.DatabaseBB.Panel,...
        'Tag','DatabaseBB_DatbaseFromFolder',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Create database from folder',...
        'Callback',{@Database,1},...
        'Position',[0.675 0.95 0.3 0.035],...
        'enable', 'on',...
        'UserData',0,...
        'Tooltipstring', '');  
    
     h.DatabaseBB.FileHistoryContainer = uibuttongroup(...
        'Parent',h.DatabaseBB.Panel,...
        'Tag','DatabaseBB_List',...
        'Units','normalized',...
        'FontSize',12,...
        'Title','File History',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.01 0.98 0.48]);
    h.DatabaseBB.FileHistory = FileHistory(h.DatabaseBB.FileHistoryContainer,'BurstBrowser',@(x) Load_Burst_Data_Callback([],[],x));
    %% Define axes in main_tab_general
    %%% Right-click menu for axes
    h.ExportGraph_Menu = uicontextmenu('Parent',h.BurstBrowser);
    
    h.Export1DX_Menu = uimenu(...
        'Parent',h.ExportGraph_Menu,...
        'Label','Export X 1D',...
        'Tag','Export1DX_Menu',...
        'Callback',@ExportGraphs);
    
    h.Export1DY_Menu = uimenu(...
        'Parent',h.ExportGraph_Menu,...
        'Label','Export Y 1D',...
        'Tag','Export1DY_Menu',...
        'Callback',@ExportGraphs);
    
    h.Export2D_Menu = uimenu(...
        'Parent',h.ExportGraph_Menu,...
        'Label','Export 2D',...
        'Tag','Export2D_Menu',...
        'Callback',@ExportGraphs);
    
    %define 2d axis
    h.axes_general =  axes(...
        'Parent',h.MainTabGeneralPanel,...
        'Units','normalized',...
        'Position',[0.07 0.06 0.71 0.73],...
        'Box','on',...
        'Tag','Axes_General',...
        'FontSize',12,...
        'View',[0 90],...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'nextplot','add',...
        'LineWidth', Look.AxWidth,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'Color',Look.Axes,...
        'UIContextMenu',h.ExportGraph_Menu);
    
    %display no. bursts
    h.text_nobursts = uicontrol(...
        'Style','text',...
        'Parent',h.MainTabGeneralPanel,...
        'Tag','Text_Burst',...
        'Units','normalized',...
        'FontSize',11,...
        'String','no bursts',...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.97 0.2 0.03]);
    
    %define 1d axes
    h.axes_1d_x =  axes(...
        'Parent',h.MainTabGeneralPanel,...
        'Units','normalized',...
        'Position',[0.07 0.79 0.71, 0.15],...
        'Box','on',...
        'Tag','Axes_1D_X',...
        'FontSize',12,...
        'XAxisLocation','top',...
        'nextplot','add',...
        'View',[0 90],...
        'LineWidth', Look.AxWidth,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Color',Look.Axes,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'UIContextMenu',h.ExportGraph_Menu);
    ylabel(h.axes_1d_x, 'counts','Color',Look.Fore);
    
    h.axes_1d_x_text =text(...
        'Parent',h.axes_1d_x,...
        'Tag','axes_1d_x_text',...
        'Units','normalized',...
        'FontSize',14,...
        'String','avg = ',...
        'Interpreter','none',...
        'HorizontalAlignment','left',...
        'BackgroundColor','none',...
        'Color', 'r',...
        'Position',[0.025 0.8],...
        'Visible','off');
    
    %%% Colorbar
    h.colorbar = colorbar(h.axes_general,'Location','north','Color',Look.Fore,'FontSize',12);
    h.colorbar.Position = [0.78,0.92,0.15,0.02];
    h.colorbar.Label.Color = Look.Fore;
    h.colorbar.Label.String = 'Occurrence';
    h.colorbar.Label.FontWeight = 'bold'; 
    h.colorbar.Label.Position(1) = 0.5;
    h.colorbar.Label.Position(2) = 2.5;
    h.colorbar.Label.Units = 'normalized';
    
    h.axes_1d_y =  axes(...
        'Parent',h.MainTabGeneralPanel,...
        'Units','normalized',...
        'Position',[0.78 0.06 0.15, 0.73],...
        'Tag','Main_Tab_General_Plot',...
        'Box','on',...
        'Tag','Axes_1D_Y',...
        'FontSize',12,...
        'XAxisLocation','top',...
        'nextplot','add',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'View',[90 90],...
        'Color',Look.Axes,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'XDir','reverse',...
        'UIContextMenu',h.ExportGraph_Menu);
    ylabel(h.axes_1d_y, 'counts','Color',Look.Fore);
    %     set(h.axes_1d_y.XLabel, 'String', '')
    %     p = get(h.axes_1d_y.XLabel, 'Pos');
    %     p(2) = p(2)*1.1;
    %     set(h.axes_1d_y.XLabel, 'Pos', p);
    
    h.axes_1d_y_text =text(...
        'Parent',h.axes_1d_y,...
        'Tag','axes_1d_y_text',...
        'Units','normalized',...
        'FontSize',14,...
        'String','avg = ',...
        'Interpreter','none',...
        'HorizontalAlignment','left',...
        'BackgroundColor','none',...
        'Color', 'r',...
        'Position',[0.1 0.95],...
        'Visible','off');
    %%% Axis for ZScale parameter, shows histogram of average values
    h.axes_ZScale =  axes(...
        'Parent',h.MainTabGeneralPanel,...
        'Units','normalized',...
        'Position',[0.78 0.79 0.15, 0.13],...
        'Tag','Main_Tab_General_Plot',...
        'Box','on',...
        'Tag','axes_ZScale',...
        'FontSize',12,...
        'LineWidth', Look.AxWidth,...
        'nextplot','add',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XTick',[],...
        'YTick',[],...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'UIContextMenu',h.ExportGraph_Menu,...
        'Color',Look.Axes,...
        'Visible','off');
    ylabel(h.axes_ZScale, [],'Color',Look.Fore);
    xlabel(h.axes_ZScale, [],'Color',Look.Fore);
    
    linkaxes([h.axes_general,h.axes_1d_x],'x');
    addlistener(h.axes_general,'YLim','PostSet',@linkaxes_y);
    addlistener(h.axes_1d_y,'XLim','PostSet',@linkaxes_y);
    %% Define axes in Corrections tab
    % defined context menu for corrections tab
    h.Corrections_Menu = uicontextmenu;
    h.ExportCorrections_Menu = uimenu(...
        'Parent',h.Corrections_Menu,...
        'Label','Export Correction Plots',...
        'Tag','ExportCorrections_Menu',...
        'Callback',@ExportGraphs);
    h.MainTabCorrectionsPanel.UIContextMenu = h.Corrections_Menu;
    %% Corrections - 2ColorMFD
    h.Corrections.TwoCMFD.axes_crosstalk =  axes(...
        'Parent',h.MainTabCorrectionsPanel,...
        'Units','normalized',...
        'Position',[0.05 0.55 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_crosstalk',...
        'Box','on',...
        'FontSize',12,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'nextplot','add',...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.Corrections_Menu);
    xlabel(h.Corrections.TwoCMFD.axes_crosstalk,'Proximity Ratio','Color',UserValues.Look.Fore);
    ylabel(h.Corrections.TwoCMFD.axes_crosstalk,'#','Color',UserValues.Look.Fore);
    title(h.Corrections.TwoCMFD.axes_crosstalk,'Proximity Ratio of Donor only','Color',UserValues.Look.Fore);
    
    h.Corrections.TwoCMFD.axes_direct_excitation =  axes(...
        'Parent',h.MainTabCorrectionsPanel,...
        'Units','normalized',...
        'Position',[0.55 0.55 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_direct_excitation',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.Corrections_Menu);
    xlabel(h.Corrections.TwoCMFD.axes_direct_excitation,'Stoichiometry (raw)','Color',UserValues.Look.Fore);
    ylabel(h.Corrections.TwoCMFD.axes_direct_excitation,'#','Color',UserValues.Look.Fore);
    title(h.Corrections.TwoCMFD.axes_direct_excitation,'Raw Stoichiometry of Acceptor only','Color',UserValues.Look.Fore);
    
    h.Corrections.TwoCMFD.axes_gamma=  axes(...
        'Parent',h.MainTabCorrectionsPanel,...
        'Units','normalized',...
        'Position',[0.05 0.05 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_gamma',...
        'Box','on',...
        'FontSize',12,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.Corrections_Menu);
    xlabel(h.Corrections.TwoCMFD.axes_gamma,'FRET Efficiency','Color',UserValues.Look.Fore);
    ylabel(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry','Color',UserValues.Look.Fore);
    title(h.Corrections.TwoCMFD.axes_gamma,'1/Stoichiometry vs. FRET Efficiency for \gamma = 1','Color',UserValues.Look.Fore);
    
    h.Corrections.TwoCMFD.axes_gamma_lifetime =  axes(...
        'Parent',h.MainTabCorrectionsPanel,...
        'Units','normalized',...
        'Position',[0.55 0.05 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_gamma_lifetime',...
        'Box','on',...
        'FontSize',12,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.Corrections_Menu);
    xlabel(h.Corrections.TwoCMFD.axes_gamma_lifetime,'Lifetime D [ns]','Color',UserValues.Look.Fore);
    ylabel(h.Corrections.TwoCMFD.axes_gamma_lifetime,'FRET Efficiency','Color',UserValues.Look.Fore);
    title(h.Corrections.TwoCMFD.axes_gamma_lifetime,'FRET Efficiency vs. Lifetime D','Color',UserValues.Look.Fore);

    %% Corrections - 3ColorMFD
    h.Corrections.ThreeCMFD.axes_crosstalk_BG =  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[0.05 0.7 0.2 0.25],...
        'Tag','Main_Tab_Corrections_Plot_crosstalk',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.Corrections_Menu);
    xlabel(h.Corrections.ThreeCMFD.axes_crosstalk_BG,'Proximity Ratio BG','Color',UserValues.Look.Fore);
    ylabel(h.Corrections.ThreeCMFD.axes_crosstalk_BG,'#','Color',UserValues.Look.Fore);
    title(h.Corrections.ThreeCMFD.axes_crosstalk_BG,'Blue dye only','Color',UserValues.Look.Fore);
    
    h.Corrections.ThreeCMFD.axes_crosstalk_BR =  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[(0.25+0.1/3) 0.7 0.2 0.25],...
        'Tag','Main_Tab_Corrections_Plot_crosstalk',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'FontSize',12,...
        'LineWidth', Look.AxWidth,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.Corrections_Menu);
    xlabel(h.Corrections.ThreeCMFD.axes_crosstalk_BR,'Proximity Ratio BR','Color',UserValues.Look.Fore);
    ylabel(h.Corrections.ThreeCMFD.axes_crosstalk_BR,'#','Color',UserValues.Look.Fore);
    title(h.Corrections.ThreeCMFD.axes_crosstalk_BR,'Blue dye only','Color',UserValues.Look.Fore);
    
    h.Corrections.ThreeCMFD.axes_direct_excitation_BG =  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[(0.45+0.2/3) 0.7 0.2 0.25],...
        'Tag','Main_Tab_Corrections_Plot_direct_excitation',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.Corrections_Menu);
    xlabel(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,'Stoichiometry BG (raw)','Color',UserValues.Look.Fore);
    ylabel(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,'#','Color',UserValues.Look.Fore);
    title(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,'Green dye only','Color',UserValues.Look.Fore);
    
    h.Corrections.ThreeCMFD.axes_direct_excitation_BR =  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[0.75 0.7 0.2 0.25],...
        'Tag','Main_Tab_Corrections_Plot_direct_excitation',...
        'Box','on',...
        'LineWidth', Look.AxWidth,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'FontSize',12,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.Corrections_Menu);
    xlabel(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,'Stoichiometry BR (raw)','Color',UserValues.Look.Fore);
    ylabel(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,'#','Color',UserValues.Look.Fore);
    title(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,'Red dye only','Color',UserValues.Look.Fore);
    
    h.Corrections.ThreeCMFD.axes_gammaBG_threecolor=  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[0.05 0.375 0.4 0.25],...
        'Tag','Main_Tab_Corrections_Plot_gammaBG_threecolor',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.Corrections_Menu);
    xlabel(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'FRET Efficiency* BG','Color',UserValues.Look.Fore);
    ylabel(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'1/Stoichiometry* BG','Color',UserValues.Look.Fore);
    title(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'1/Stoichiometry* BG vs. FRET Efficiency* BG for gammaBG = 1','Color',UserValues.Look.Fore);
    
    h.Corrections.ThreeCMFD.axes_gammaBR_threecolor=  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[0.05 0.05 0.4 0.25],...
        'Tag','Main_Tab_Corrections_Plot_gammaBG_threecolor',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.Corrections_Menu);
    xlabel(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'FRET Efficiency* BR','Color',UserValues.Look.Fore);
    ylabel(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'1/Stoichiometry* BR','Color',UserValues.Look.Fore);
    title(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'1/Stoichiometry* BR vs. FRET Efficiency* BR for gammaBR = 1','Color',UserValues.Look.Fore);
    
    %%% 07-2015 Disable Gamma from populations since it does not work
    h.Corrections.ThreeCMFD.axes_gammaBR_threecolor.Visible = 'off';
    h.Corrections.ThreeCMFD.axes_gammaBG_threecolor.Visible = 'off';
    
    h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime =  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[0.5 0.05 0.45 0.575],...
        'Tag','Main_Tab_Corrections_Plot_gamma_threecolor_lifetime',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.Corrections_Menu);
    xlabel(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,'Lifetime BB [ns]','Color',UserValues.Look.Fore);
    ylabel(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,'FRET Efficiency B->G+R','Color',UserValues.Look.Fore);
    title(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,'FRET Efficiency B->G+R vs. Lifetime BB','Color',UserValues.Look.Fore);
    %% Define Axes in Lifetime Tab
    s.ProgressRatio = 0.9;
    %%% Make Tabs for all plots and one for selecting individual plots for
    %%% inspection in detail
    % context menu for All tab lifetimes
    h.LifeTime_Menu = uicontextmenu;
    h.ExportLifetime_Menu = uimenu(...
        'Parent',h.LifeTime_Menu,...
        'Label','Export Lifetime Plots',...
        'Tag','ExportLifetime_Menu',...
        'Callback',@ExportGraphs);
%     h.ExportEvsTau_Menu = uimenu(...
%         'Parent',h.LifeTime_Menu,...
%         'Label','Export E vs TauGG Plot',...
%         'Tag','ExportEvsTau_Menu',...
%         'Callback',@ExportGraphs);
%     h.ExportEvsTauBB_Menu = uimenu(...
%         'Parent',h.LifeTime_Menu,...
%         'Label','Export E(B->G+R) vs TauBB Plot',...
%         'Tag','ExportEvsTauBB_Menu',...
%         'Callback',@ExportGraphs,...
%         'Visible','off');
    h.LifetimePanelAll.UIContextMenu = h.LifeTime_Menu;
    
    h.axes_EvsTauGG =  axes(...
        'Parent',h.LifetimePanelAll,...
        'Units','normalized',...
        'Position',[0.075 0.57 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_EvsTauGG',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.LifeTime_Menu);
    ylabel(h.axes_EvsTauGG,'FRET Efficiency','Color',UserValues.Look.Fore);
    xlabel(h.axes_EvsTauGG,'\tau_{D(A)} [ns]','Color',UserValues.Look.Fore);
    
    h.axes_EvsTauRR =  axes(...
        'Parent',h.LifetimePanelAll,...
        'Units','normalized',...
        'Position',[0.575 0.57 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_EvsTauRR',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
        'nextplot','add',...
                                   'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.LifeTime_Menu);
    ylabel(h.axes_EvsTauRR,'FRET Efficiency','Color',UserValues.Look.Fore);
    xlabel(h.axes_EvsTauRR,'\tau_{A} [ns]','Color',UserValues.Look.Fore);
    
    h.axes_rGGvsTauGG =  axes(...
        'Parent',h.LifetimePanelAll,...
        'Units','normalized',...
        'Position',[0.075 0.07 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_rGGvsTauGG',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.LifeTime_Menu);
    ylabel(h.axes_rGGvsTauGG,'r_{D}','Color',UserValues.Look.Fore,'Rotation',0,'Units', 'Normalized', 'Position', [-0.075, 0.5, 0]);
    xlabel(h.axes_rGGvsTauGG,'\tau_{D(A)} [ns]','Color',UserValues.Look.Fore);
    title(h.axes_rGGvsTauGG,'Anisotropy D vs. Lifetime D','Color',UserValues.Look.Fore);
    h.axes_rGGvsTauGG.YLabel.Position(1) = h.axes_rGGvsTauGG.YLabel.Position(1)-0.01;
    
    h.axes_rRRvsTauRR=  axes(...
        'Parent',h.LifetimePanelAll,...
        'Units','normalized',...
        'Position',[0.575 0.07 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_rRRvsTauRR',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.LifeTime_Menu);
    ylabel(h.axes_rRRvsTauRR,'r_{A}','Color',UserValues.Look.Fore,'Rotation',0,'Units', 'Normalized', 'Position', [-0.075, 0.5, 0]);
    xlabel(h.axes_rRRvsTauRR,'\tau_{A} [ns]','Color',UserValues.Look.Fore);
    title(h.axes_rRRvsTauRR,'Anisotropy A vs. Lifetime A','Color',UserValues.Look.Fore);
    
    %%% Define Axes for 3C
    %%% (For 3C, the four axes of 2C are shifted to the left and two
    %%% additional axes are made visible)
    h.axes_E_BtoGRvsTauBB =  axes(...
        'Parent',h.Hide_Stuff,...
        'Units','normalized',...
        'Position',[(0.15+0.8*2/3)+0.025 0.57 0.8/3 0.4],...
        'Tag','Main_Tab_Corrections_Plot_EBtoGRvsTauBB',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.LifeTime_Menu);
    ylabel(h.axes_E_BtoGRvsTauBB,'FRET Efficiency B->G+R','Color',UserValues.Look.Fore);
    xlabel(h.axes_E_BtoGRvsTauBB,'\tau_{BB} [ns]','Color',UserValues.Look.Fore);
    title(h.axes_E_BtoGRvsTauBB,'FRET Efficiency B->G+R vs. Lifetime BB','Color',UserValues.Look.Fore);
    
    h.axes_rBBvsTauBB=  axes(...
        'Parent',h.Hide_Stuff,...
        'Units','normalized',...
        'Position',[(0.15+0.8*2/3)+0.025 0.07 0.8/3 0.4],...
        'Tag','Main_Tab_Corrections_Plot_rBBvsTauBB',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
        'nextplot','add',...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[0 90],...
        'UIContextMenu', h.LifeTime_Menu);
    ylabel(h.axes_rBBvsTauBB,'r_{BB}','Color',UserValues.Look.Fore,'Rotation',0,'Units', 'Normalized', 'Position', [-0.12, 0.5, 0]);
    xlabel(h.axes_rBBvsTauBB,'\tau_{BB} [ns]','Color',UserValues.Look.Fore);
    title(h.axes_rBBvsTauBB,'Anisotropy BB vs. Lifetime BB','Color',UserValues.Look.Fore);
    
    %%% Axes in Lifetime Ind Tab
    %define uicontextmenu
    h.ExportGraphLifetime_Menu = uicontextmenu('Parent',h.BurstBrowser);

    h.Export2DLifetime_Menu = uimenu(...
        'Parent',h.ExportGraphLifetime_Menu,...
        'Label','Export Graph',...
        'Tag','Export2DLifetime_Menu',...
        'Callback',@ExportGraphs);
    h.LifetimePanelInd.UIContextMenu = h.ExportGraphLifetime_Menu;
    
    %define 2d axis
    h.axes_lifetime_ind_2d =  axes(...
        'Parent',h.LifetimePanelInd,...
        'Units','normalized',...
        'Position',[0.07 0.06 0.71 0.73],...
        'Box','on',...
        'Tag','axes_lifetime_ind_2d',...
        'FontSize',12,...
        'View',[0 90],...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'nextplot','add',...
        'Color',Look.Axes,...
        'UIContextMenu',h.ExportGraphLifetime_Menu);
    
    
    %display popupmenu for selection
    h.lifetime_ind_popupmenu = uicontrol(...
        'Style','listbox',...
        'Parent',h.LifetimePanelInd,...
        'Tag','lifetime_ind_popupmenu',...
        'Units','normalized',...
        'FontSize',12,...
        'String',{'<html>E vs &tau;<sub>D(A)</sub></html>','<html>E vs &tau;<sub>A</sub></html>','<html>r<sub>D</sub> vs &tau;<sub>D(A)</sub></html>','<html>r<sub>A</sub> vs &tau;<sub>A</sub></html>'},...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@PlotLifetimeInd,...
        'Position',[0.81 0.81 0.16 0.13],...
        'UIContextMenu',h.ExportGraphLifetime_Menu);
%     %%% export button
%     h.lifetime_ind_export_button = uicontrol(...
%         'Style','pushbutton',...
%         'Parent',h.LifetimePanelInd,...
%         'Tag','lifetime_ind_export_button',...
%         'Units','normalized',...
%         'FontSize',12,...
%         'String','Export Graph',...
%         'BackgroundColor', Look.Control,...
%         'ForegroundColor', Look.Fore,...
%         'Callback',@ExportGraphs,...
%         'Position',[0.81 0.96 0.16 0.025]);
    
    %define 1d axes
    h.axes_lifetime_ind_1d_x =  axes(...
        'Parent',h.LifetimePanelInd,...
        'Units','normalized',...
        'Position',[0.07 0.79 0.71, 0.15],...
        'Box','on',...
        'Tag','axes_lifetime_ind_1d_x',...
        'FontSize',12,...
        'XAxisLocation','top',...
        'nextplot','add',...
        'View',[0 90],...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'UIContextMenu',h.ExportGraphLifetime_Menu);
    ylabel(h.axes_lifetime_ind_1d_x, 'counts','Color',Look.Fore);
    
    h.axes_lifetime_ind_1d_y =  axes(...
        'Parent',h.LifetimePanelInd,...
        'Units','normalized',...
        'Position',[0.78 0.06 0.15, 0.73],...
        'Tag','axes_lifetime_ind_1d_y',...
        'Box','on',...
        'FontSize',12,...
        'XAxisLocation','top',...
        'nextplot','add',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'View',[90 90],...
        'XDir','reverse',...
        'UIContextMenu',h.ExportGraphLifetime_Menu);
    ylabel(h.axes_lifetime_ind_1d_y, 'counts','Color',Look.Fore);
    %% Define Axes in filtered FCS tab
    h.fFCS_axes_tab = uitabgroup(...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0 0.45 1 0.45],...
        'Tag','fFCS_axes_tab');
    
    h.fFCS_axes_decay_tab = uitab(...
        'Parent',h.fFCS_axes_tab,...
        'Units','normalized',...
        'Title','Microtime patterns',...
        'BackgroundColor', Look.Back,...
        'Tag','fFCS_axes_decay_tab');
    
    h.axes_fFCS_DecayPar =  axes(...
        'Parent',h.fFCS_axes_decay_tab,...
        'Units','normalized',...
        'Position',[0.06 0.12 0.42 0.83],...
        'Tag','Main_Tab_fFCS_Decays_Par',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'FontSize',12,...
        'nextplot','add');
    xlabel(h.axes_fFCS_DecayPar,'TCSPC bin','Color',UserValues.Look.Fore);
    ylabel(h.axes_fFCS_DecayPar,'Probability','Color',UserValues.Look.Fore);
    
    h.axes_fFCS_DecayPerp =  axes(...
        'Parent',h.fFCS_axes_decay_tab,...
        'Units','normalized',...
        'Position',[0.56 0.12 0.42 0.83],...
        'Tag','Main_Tab_fFCS_Decays_Perp',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'FontSize',12,...
        'nextplot','add');
    xlabel(h.axes_fFCS_DecayPerp,'TCSPC bin','Color',UserValues.Look.Fore);
    ylabel(h.axes_fFCS_DecayPerp,'Probability','Color',UserValues.Look.Fore);
    
    h.fFCS_axes_result_tab = uitab(...
        'Parent',h.fFCS_axes_tab,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'Title','fFCS result',...
        'Tag','fFCS_axes_decay_tab');
    
    h.axes_fFCS_Result =  axes(...
        'Parent',h.fFCS_axes_result_tab,...
        'Units','normalized',...
        'Position',[0.07 0.135 0.92 0.815],...
        'Tag','axes_fFCS_Result',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'FontSize',12,...
        'nextplot','add',...
        'XScale','log');
    xlabel(h.axes_fFCS_Result,'time lag \tau [s]','Color',UserValues.Look.Fore);
    ylabel(h.axes_fFCS_Result,'G(\tau)','Color',UserValues.Look.Fore);
    
     h.fFCS_save_result_button = uicontrol(...
        'Style','pushbutton',...
        'Tag','fFCS_save_result_button',...
        'Parent',h.fFCS_axes_result_tab,...
        'Units','normalized',...
        'Position',[0.85 0.825 0.125 0.1],...
        'String','Save result',...
        'ForegroundColor',Look.Fore,...
        'BackgroundColor',Look.Control,...
        'FontSize',12,...
        'Callback',@Save_fFCS);
    %%% settings panel
    h.fFCS_settings_panel = uibuttongroup(...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Fore,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0.9 1 0.1],...
        'Tag','fFCS_settings_panel');
    
    %%% Popupmenus for selection of species
    h.fFCS_Species1_text = uicontrol('Style','text',...
        'Parent',h.fFCS_settings_panel,...
        'Units','normalized',...
        'Position',[0.03 0.6 0.15 0.3],...
        'String','Species 1:',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'FontSize',12);
    
    h.fFCS_Species1_popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Tag','fFCS_Species1_popupmenu',...
        'Parent',h.fFCS_settings_panel,...
        'Units','normalized',...
        'ForegroundColor',Look.Fore,...
        'BackgroundColor',Look.Control,...
        'Position',[0.18 0.6 0.15 0.3],...
        'String',{'-'},...
        'Value',1,...
        'Callback',@Update_fFCS_GUI,...
        'FontSize',12);
    
    h.fFCS_Species2_text = uicontrol('Style','text',...
        'Parent',h.fFCS_settings_panel,...
        'Units','normalized',...
        'Position',[0.03 0.1 0.15 0.3],...
        'String','Species 2:',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'FontSize',12);
    
    h.fFCS_Species2_popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Tag','fFCS_Species2_popupmenu',...
        'Parent',h.fFCS_settings_panel,...
        'ForegroundColor',Look.Fore,...
        'BackgroundColor',Look.Control,...
        'Units','normalized',...
        'Position',[0.18 0.1 0.15 0.3],...
        'String',{'-'},...
        'Callback',@Update_fFCS_GUI,...
        'Value',1,...
        'FontSize',12);
    
    %%% Button to Update Microtime Histograms
    h.Plot_Microtimes_button = uicontrol(...
        'Style','pushbutton',...
        'Tag','Plot_Microtimes_button',...
        'Parent',h.fFCS_settings_panel,...
        'Units','normalized',...
        'Position',[0.725 0.675 0.25 0.25],...
        'String','Plot Microtimes',...
        'FontSize',12,...
        'ForegroundColor',Look.Fore,...
        'BackgroundColor',Look.Control,...
        'Callback',@Update_MicrotimeHistogramsfFCS);
    
    %%% Button to calculate filters
    h.Calc_fFCS_Filter_button = uicontrol(...
        'Style','pushbutton',...
        'Tag','Calc_fFCS_Filter_button',...
        'Parent',h.fFCS_settings_panel,...
        'Units','normalized',...
        'Position',[0.725 0.375 0.25 0.25],...
        'String','Calculate Filters',...
        'FontSize',12,...
        'Enable','off',...
        'ForegroundColor',Look.Fore,...
        'BackgroundColor',Look.Control,...
        'Callback',@Calc_fFCS_Filters);
    
    %%% Button to do correlation
    h.Do_fFCS_button = uicontrol(...
        'Style','pushbutton',...
        'Tag','Do_fFCS_button',...
        'Parent',h.fFCS_settings_panel,...
        'Units','normalized',...
        'Position',[0.725 0.075 0.25 0.25],...
        'String','Do fFCS',...
        'FontSize',12,...
        'Enable','off',...
        'ForegroundColor',Look.Fore,...
        'BackgroundColor',Look.Control,...
        'Callback',@Do_fFCS);
    
    %%% fFCS options
    %%% Option to check/uncheck downsampling for fFCS
    h.Downsample_fFCS = uicontrol('Style','checkbox',...
        'Parent',h.fFCS_settings_panel,...
        'String','Increase TCSPC bin width',...
        'Tag','Downsample_fFCS',...
        'Value', UserValues.BurstBrowser.Settings.Downsample_fFCS,...
        'Units','normalized',...
        'Position',[0.35 0.075 0.2 0.25],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    
    h.Downsample_fFCS_edit = uicontrol('Style','edit',...
        'Parent',h.fFCS_settings_panel,...
        'Tag','Downsample_fFCS',...
        'String', num2str(UserValues.BurstBrowser.Settings.Downsample_fFCS_Time),...
        'Units','normalized',...
        'Position',[0.55 0.075 0.1 0.25],...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    h.Downsample_fFCS_text = uicontrol('Style','text',...
        'Parent',h.fFCS_settings_panel,...
        'Tag','Downsample_fFCS',...
        'String','ps',...
        'Units','normalized',...
        'Position',[0.65 0.075 0.05 0.25],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore...
        );
    
    if UserValues.BurstBrowser.Settings.Downsample_fFCS
        h.Downsample_fFCS_edit.Enable = 'on';
    else
        h.Downsample_fFCS_edit.Enable = 'off';
    end
    h.fFCS_selectmode_text = uicontrol('Style','text',...
        'Parent',h.fFCS_settings_panel,...
        'Tag','fFCS_selectmode_text',...
        'String','fFCS mode:',...
        'Units','normalized',...
        'HorizontalAlignment','left',...
        'Position',[0.35 0.675 0.1 0.25],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore...
        );
    
    h.fFCS_selectmode_popupmenu = uicontrol('Style','popupmenu',...
        'Parent',h.fFCS_settings_panel,...
        'Tag','fFCS_selectmode_text',...
        'String',{'burstwise','burstwise with time window','continuous photon stream','continuous photon stream with donor only'},...
        'Units','normalized',...
        'Value',UserValues.BurstBrowser.Settings.fFCS_Mode,...
        'Position',[0.45 0.675 0.25 0.25],...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    
    h.fFCS_UseIRF = uicontrol('Style','checkbox',...
        'Parent',h.fFCS_settings_panel,...
        'String','Include Scatter Pattern',...
        'Tag','fFCS_UseIRF',...
        'Value', UserValues.BurstBrowser.Settings.fFCS_UseIRF,...
        'Units','normalized',...
        'Position',[0.35 0.375 0.175 0.25],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    
    h.fFCS_UseFRET = uicontrol('Style','checkbox',...
        'Parent',h.fFCS_settings_panel,...
        'String','Include FRET Channel',...
        'Tag','fFCS_UseFRET',...
        'Value', UserValues.BurstBrowser.Settings.fFCS_UseFRET,...
        'Units','normalized',...
        'Position',[0.4975 0.375 0.175 0.25],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    %     h.fFCS_UseTimeWindow = uicontrol('Style','checkbox',...
    %         'Parent',h.fFCS_settings_panel,...
    %         'String','Include Time Window for fFCS',...
    %         'Tag','fFCS_UseTimeWindow',...
    %         'Value', UserValues.BurstBrowser.Settings.fFCS_UseTimewindow,...
    %         'Units','normalized',...
    %         'Position',[0.1 0.58 0.5 0.07],...
    %         'FontSize',12,...
    %         'BackgroundColor', Look.Back,...
    %         'ForegroundColor', Look.Fore,...
    %         'Callback',@UpdateOptions...
    %         );
    
    %%% Axes for fFCS
    h.axes_fFCS_FilterPar =  axes(...
        'Parent',h.fFCS_SubTabParFilterPanel,...
        'Units','normalized',...
        'Position',[0.12 0.12 0.855 0.855],...
        'Tag','Sub_Tab_fFCS_Filter_Par',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'nextplot','add');
    ylabel(h.axes_fFCS_FilterPar,'Filter value','Color',UserValues.Look.Fore);
    xlabel(h.axes_fFCS_FilterPar,'TCSPC bin','Color',UserValues.Look.Fore);
    
    h.axes_fFCS_FilterPerp =  axes(...
        'Parent',h.fFCS_SubTabPerpFilterPanel,...
        'Units','normalized',...
        'Position',[0.12 0.12 0.855 0.855],...
        'Tag','Sub_Tab_fFCS_Filter_Perp',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'nextplot','add');
    ylabel(h.axes_fFCS_FilterPerp,'Filter value','Color',UserValues.Look.Fore);
    xlabel(h.axes_fFCS_FilterPerp,'TCSPC bin','Color',UserValues.Look.Fore);
    
    h.axes_fFCS_ReconstructionPar =  axes(...
        'Parent',h.fFCS_SubTabParReconstructionPanel,...
        'Units','normalized',...
        'Position',[0.12 0.12 0.855 0.705],...
        'Tag','Sub_Tab_fFCS_Reconstruction_Par',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'nextplot','add');
    ylabel(h.axes_fFCS_ReconstructionPar,'Counts','Color',UserValues.Look.Fore);
    xlabel(h.axes_fFCS_ReconstructionPar,'TCSPC bin','Color',UserValues.Look.Fore);
    
    h.axes_fFCS_ReconstructionParResiduals =  axes(...
        'Parent',h.fFCS_SubTabParReconstructionPanel,...
        'Units','normalized',...
        'Position',[0.12 0.825 0.855 0.15],...
        'Tag','Sub_Tab_fFCS_Reconstruction_Par_Residuals',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
        'FontSize',12,...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'nextplot','add',...
        'XTickLabel',[]);
    ylabel(h.axes_fFCS_ReconstructionParResiduals,'w_{res}','Color',UserValues.Look.Fore);
    
    h.axes_fFCS_ReconstructionPerp =  axes(...
        'Parent',h.fFCS_SubTabPerpReconstructionPanel,...
        'Units','normalized',...
        'Position',[0.12 0.12 0.855 0.705],...
        'Tag','Sub_Tab_fFCS_Reconstruction_Perp',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'FontSize',12,...
        'nextplot','add');
    ylabel(h.axes_fFCS_ReconstructionPerp,'Counts','Color',UserValues.Look.Fore);
    xlabel(h.axes_fFCS_ReconstructionPerp,'TCSPC bin','Color',UserValues.Look.Fore);
    
    h.axes_fFCS_ReconstructionPerpResiduals =  axes(...
        'Parent',h.fFCS_SubTabPerpReconstructionPanel,...
        'Units','normalized',...
        'Position',[0.12 0.825 0.855 0.15],...
        'Tag','Sub_Tab_fFCS_Reconstruction_Perp_Residuals',...
        'Box','on',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'LineWidth', Look.AxWidth,...
                           'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'FontSize',12,...
        'nextplot','add',...
        'XTickLabel',[]);
    ylabel(h.axes_fFCS_ReconstructionPerpResiduals,'w_{res}','Color',UserValues.Look.Fore);
    
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
    %% add keypress function to all gui elements
    fields = fieldnames(h); %%% loop through h structure
    for i = 1:numel(fields)
        if isprop(h.(fields{i}),'KeyPressFcn')
            if isempty(h.(fields{i}).KeyPressFcn)
                h.(fields{i}).KeyPressFcn = @BurstBrowser_KeyPress;
            end
        end
    end
    %% Store GUI data
    guidata(h.BurstBrowser,h);
    BurstMeta.SelectedFile = 1;
    BurstMeta.Database = UserValues.BurstBrowser.Database;
    %%% Clear BurstData if it still exists from editing in PAM
    global BurstData
    if isstruct(BurstData)
        BurstData = [];
    end
    %%% Initialize Plots
    Initialize_Plots(1);
    UpdateOptions(h.Fit_NGaussian_Popupmenu,[],h);
    UpdateGUIOptions(h.PlotGridAboveDataCheckbox,[],h);
    ChangePlotType([],[],h);
    %% set UserValues in GUI
    UpdateCorrections([],[],h);
    %%% Update ColorMap
    if ischar(UserValues.BurstBrowser.Display.ColorMap)
        eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);
    else
        colormap(UserValues.BurstBrowser.Display.ColorMap);
    end
    %%% Re-Enable Menu
    h.File_Menu.Enable = 'on';
    
    h.BurstBrowser.Visible = 'on';
    
    delete(s);
else
    figure(hfig);
end

clearvars -global BurstData BurstTCSPCData
if ~isempty(findobj('Tag','Pam'))
    h_pam = guidata(findobj('Tag','Pam'));
    %%% Reset loaded file textbox
    h_pam.Burst_LoadedFile_Text.String = '';
    h_pam.Burst_LoadedFile_Text.TooltipString = '';
    %%% Set Analysis Buttons in Pam
    %%% set the text of the BurstSearch Button to green color to indicate that
    %%% a burst search has been done
    h_pam.Burst_Button.ForegroundColor = Look.Fore;
    %%% Disable Lifetime and 2CDE Button
    h_pam.BurstLifetime_Button.Enable = 'off';
    h_pam.BurstLifetime_Button.ForegroundColor = Look.Fore;
    h_pam.NirFilter_Button.Enable = 'off';
    h_pam.NirFilter_Button.ForegroundColor = Look.Fore;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Initializes/Resets Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Initialize_Plots(mode)
global BurstMeta UserValues BurstData
h = guidata(findobj('Tag','BurstBrowser'));
%%% supress warning associated with constant Z data and contour plots
warning('off','MATLAB:contour:ConstantData');
warning('off','MATLAB:gui:array:InvalidArrayShape');
switch mode
    case 1
        %%% Initialize Plots in Global Variable
        %%% Enables easy Updating later on
        BurstMeta.Plots = [];
        %%% Main Tab
        BurstMeta.Plots.Main_histX(1) = bar(h.axes_1d_x,[0 1],[nan nan],'FaceColor',[0.6 0.6 0.6],'EdgeColor','none','BarWidth',1,'UIContextMenu',h.ExportGraph_Menu);
        BurstMeta.Plots.Main_histX(2) = stairs(h.axes_1d_x,[0 1],[nan nan],'Color',[0,0,0],'LineWidth',1);
        BurstMeta.Plots.Main_histY(1) = bar(h.axes_1d_y,[0 1],[nan nan],'FaceColor',[0.6 0.6 0.6],'EdgeColor','none','BarWidth',1,'UIContextMenu',h.ExportGraph_Menu);
        BurstMeta.Plots.Main_histY(2) = stairs(h.axes_1d_y,[0 1],[nan nan],'Color',[0,0,0],'LineWidth',1);
        BurstMeta.Plots.ZScale_hist(1)= bar(h.axes_ZScale,0.5,1,'FaceColor',[0.6 0.6 0.6],'BarWidth',1,'LineStyle','none','UIContextMenu',h.ExportGraph_Menu,'Visible','off');
        BurstMeta.Plots.ZScale_hist(2) = stairs(h.axes_ZScale,[0 1],[nan nan],'Color',[0,0,0],'LineWidth',1,'Visible','off');
        %%% Initialize both image AND contour plots in array
        BurstMeta.Plots.Main_Plot(1) = imagesc(linspace(0,1,10),linspace(0,1,10),zeros(10),'Parent',h.axes_general,'UIContextMenu',h.ExportGraph_Menu);axis(h.axes_general,'tight');
        [~,BurstMeta.Plots.Main_Plot(2)] = contourf(linspace(0,1,10),linspace(0,1,10),zeros(10),10,'Parent',h.axes_general,'Visible','off');BurstMeta.Plots.Main_Plot(2).UIContextMenu = h.ExportGraph_Menu;
        BurstMeta.HexPlot.MainPlot_hex = [];
        BurstMeta.Plots.Main_Plot(3) = scatter([0,1],[0,1],'.','Parent',h.axes_general,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        %%% Main Tab multiple species (consider up to three)
        BurstMeta.Plots.Multi.Main_Plot_multiple = imagesc(zeros(2),'Parent',h.axes_general,'Visible','off','UIContextMenu',h.ExportGraph_Menu);
        BurstMeta.Plots.Multi.Multi_histX(1) = stairs(h.axes_1d_x,0.5,1,'Color','b','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histX(2) = stairs(h.axes_1d_x,0.5,1,'Color','r','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histX(3) = stairs(h.axes_1d_x,0.5,1,'Color','g','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histY(1) = stairs(h.axes_1d_y,0.5,1,'Color','b','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histY(2) = stairs(h.axes_1d_y,0.5,1,'Color','r','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histY(3) = stairs(h.axes_1d_y,0.5,1,'Color','g','LineWidth',2,'Visible','off');
        BurstMeta.Plots.MultiScatter.h1dx = [];
        BurstMeta.Plots.MultiScatter.h1dy = [];
        %%% Plots for Gaussian mixture fitting
        [~,BurstMeta.Plots.Mixture.Main_Plot(2)] = contour(zeros(2),10,'Parent',h.axes_general,'Visible','off','LineWidth',2,'LineColor',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','--');BurstMeta.Plots.Mixture.Main_Plot(2).UIContextMenu = h.ExportGraph_Menu;
        [~,BurstMeta.Plots.Mixture.Main_Plot(3)] = contour(zeros(2),10,'Parent',h.axes_general,'Visible','off','LineWidth',2,'LineColor',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','--');BurstMeta.Plots.Mixture.Main_Plot(3).UIContextMenu = h.ExportGraph_Menu;
        [~,BurstMeta.Plots.Mixture.Main_Plot(4)] = contour(zeros(2),10,'Parent',h.axes_general,'Visible','off','LineWidth',2,'LineColor',UserValues.BurstBrowser.Display.ColorLine4,'LineStyle','--');BurstMeta.Plots.Mixture.Main_Plot(4).UIContextMenu = h.ExportGraph_Menu;
        [~,BurstMeta.Plots.Mixture.Main_Plot(5)] = contour(zeros(2),10,'Parent',h.axes_general,'Visible','off','LineWidth',2,'LineColor',UserValues.BurstBrowser.Display.ColorLine5,'LineStyle','--');BurstMeta.Plots.Mixture.Main_Plot(5).UIContextMenu = h.ExportGraph_Menu;
        [~,BurstMeta.Plots.Mixture.Main_Plot(6)] = contour(zeros(2),10,'Parent',h.axes_general,'Visible','off','LineWidth',2,'LineColor',UserValues.BurstBrowser.Display.ColorLine6,'LineStyle','--');BurstMeta.Plots.Mixture.Main_Plot(6).UIContextMenu = h.ExportGraph_Menu;
        [~,BurstMeta.Plots.Mixture.Main_Plot(1)] = contour(zeros(2),10,'Parent',h.axes_general,'Visible','off','LineWidth',2,'LineColor',UserValues.BurstBrowser.Display.ColorLine1);BurstMeta.Plots.Mixture.Main_Plot(1).UIContextMenu = h.ExportGraph_Menu;
        BurstMeta.Plots.Mixture.plotX(2) = plot(h.axes_1d_x,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotX(3) = plot(h.axes_1d_x,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotX(4) = plot(h.axes_1d_x,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine4,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotX(5) = plot(h.axes_1d_x,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine5,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotX(6) = plot(h.axes_1d_x,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine6,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotX(1) = plot(h.axes_1d_x,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Visible','off');
        BurstMeta.Plots.Mixture.plotY(2) = plot(h.axes_1d_y,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotY(3) = plot(h.axes_1d_y,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotY(4) = plot(h.axes_1d_y,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine4,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotY(5) = plot(h.axes_1d_y,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine5,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotY(6) = plot(h.axes_1d_y,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine6,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotY(1) = plot(h.axes_1d_y,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Visible','off');
        %%%Corrections Tab
        BurstMeta.Plots.histE_donly = bar(h.Corrections.TwoCMFD.axes_crosstalk,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
        %%%Consider fits also (three lines for 2 gauss fit)
        BurstMeta.Plots.Fits.histE_donly(1) = plot(h.Corrections.TwoCMFD.axes_crosstalk,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3);
        BurstMeta.Plots.Fits.histE_donly(2) = plot(h.Corrections.TwoCMFD.axes_crosstalk,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.histE_donly(3) = plot(h.Corrections.TwoCMFD.axes_crosstalk,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.histS_aonly = bar(h.Corrections.TwoCMFD.axes_direct_excitation,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
        %%%Consider fits also (three lines for 2 gauss fit)
        BurstMeta.Plots.Fits.histS_aonly(1) = plot(h.Corrections.TwoCMFD.axes_direct_excitation,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3);
        BurstMeta.Plots.Fits.histS_aonly(2) = plot(h.Corrections.TwoCMFD.axes_direct_excitation,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.histS_aonly(3) = plot(h.Corrections.TwoCMFD.axes_direct_excitation,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.gamma_fit(1) = imagesc(zeros(2),'Parent',h.Corrections.TwoCMFD.axes_gamma);axis(h.Corrections.TwoCMFD.axes_gamma,'tight');
        [~,BurstMeta.Plots.gamma_fit(2)] = contourf(zeros(2),10,'Parent',h.Corrections.TwoCMFD.axes_gamma,'Visible','off');
        BurstMeta.Plots.Fits.gamma = plot(h.Corrections.TwoCMFD.axes_gamma,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3);  %Fit
        BurstMeta.Plots.Fits.gamma_manual = scatter(h.Corrections.TwoCMFD.axes_gamma,[0 1],[0 1],1000,'+','LineWidth',4,'MarkerFaceColor','b','MarkerEdgeColor','b','Visible','off');  %Manual
        BurstMeta.Plots.gamma_lifetime(1) = imagesc(zeros(2),'Parent',h.Corrections.TwoCMFD.axes_gamma_lifetime);axis(h.Corrections.TwoCMFD.axes_gamma_lifetime,'tight');
        [~,BurstMeta.Plots.gamma_lifetime(2)] = contourf(zeros(2),'Parent',h.Corrections.TwoCMFD.axes_gamma_lifetime,'Visible','off');
        BurstMeta.Plots.Fits.staticFRET_gamma_lifetime = plot(h.Corrections.TwoCMFD.axes_gamma_lifetime,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        %%% Lifetime Tab
        BurstMeta.Plots.EvsTauGG(1) = imagesc(zeros(2),'Parent',h.axes_EvsTauGG);axis(h.axes_EvsTauGG,'tight');
        [~,BurstMeta.Plots.EvsTauGG(2)] = contourf(zeros(2),10,'Parent',h.axes_EvsTauGG,'Visible','off');
        BurstMeta.Plots.EvsTauGG(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.EvsTauGG(2).UIContextMenu = h.LifeTime_Menu;
        BurstMeta.HexPlot.EvsTauGG = [];
        BurstMeta.Plots.EvsTauGG(3) = scatter([0,1],[0,1],'.','Parent',h.axes_EvsTauGG,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        BurstMeta.Plots.Fits.staticFRET_EvsTauGG = plot(h.axes_EvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1) = plot(h.axes_EvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(2) = plot(h.axes_EvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(3) = plot(h.axes_EvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.EvsTauRR(1) = imagesc(zeros(2),'Parent',h.axes_EvsTauRR);axis(h.axes_EvsTauRR,'tight');
        [~,BurstMeta.Plots.EvsTauRR(2)] = contourf(zeros(2),10,'Parent',h.axes_EvsTauRR,'Visible','off');
        BurstMeta.Plots.EvsTauRR(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.EvsTauRR(2).UIContextMenu = h.LifeTime_Menu;
        BurstMeta.HexPlot.EvsTauRR = [];
        BurstMeta.Plots.EvsTauRR(3) = scatter([0,1],[0,1],'.','Parent',h.axes_EvsTauRR,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        BurstMeta.Plots.Fits.AcceptorLifetime_EvsTauRR = plot(h.axes_EvsTauGG,[0],[1],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.rGGvsTauGG(1) = imagesc(zeros(2),'Parent',h.axes_rGGvsTauGG);axis(h.axes_rGGvsTauGG,'tight');
        [~,BurstMeta.Plots.rGGvsTauGG(2)] = contourf(zeros(2),10,'Parent',h.axes_rGGvsTauGG,'Visible','off');
        BurstMeta.Plots.rGGvsTauGG(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.rGGvsTauGG(2).UIContextMenu = h.LifeTime_Menu;
        BurstMeta.HexPlot.rGGvsTauGG = [];
        BurstMeta.Plots.rGGvsTauGG(3) = scatter([0,1],[0,1],'.','Parent',h.axes_rGGvsTauGG,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        %%% Consider up to three Perrin lines
        BurstMeta.Plots.Fits.PerrinGG(1) = plot(h.axes_rGGvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinGG(2) = plot(h.axes_rGGvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinGG(3) = plot(h.axes_rGGvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.rRRvsTauRR(1) = imagesc(zeros(2),'Parent',h.axes_rRRvsTauRR);axis(h.axes_rRRvsTauRR,'tight');
        [~,BurstMeta.Plots.rRRvsTauRR(2)] = contourf(zeros(2),10,'Parent',h.axes_rRRvsTauRR,'Visible','off');axis(h.axes_rRRvsTauRR,'tight');
        BurstMeta.Plots.rRRvsTauRR(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.rRRvsTauRR(2).UIContextMenu = h.LifeTime_Menu;
        BurstMeta.HexPlot.rRRvsTauRR = [];
        BurstMeta.Plots.rRRvsTauRR(3) = scatter([0,1],[0,1],'.','Parent',h.axes_rRRvsTauRR,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        %%% Consider up to three Perrin lines
        BurstMeta.Plots.Fits.PerrinRR(1) = plot(h.axes_rRRvsTauRR,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinRR(2) = plot(h.axes_rRRvsTauRR,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinRR(3) = plot(h.axes_rRRvsTauRR,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','-','LineWidth',3,'Visible','off');
        %%% Lifetime Tab 3C
        BurstMeta.Plots.E_BtoGRvsTauBB(1) = imagesc(zeros(2),'Parent',h.axes_E_BtoGRvsTauBB);axis(h.axes_E_BtoGRvsTauBB,'tight');
        [~,BurstMeta.Plots.E_BtoGRvsTauBB(2)] = contourf(zeros(2),10,'Parent',h.axes_E_BtoGRvsTauBB,'Visible','off');
        BurstMeta.Plots.E_BtoGRvsTauBB(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.E_BtoGRvsTauBB(2).UIContextMenu = h.LifeTime_Menu;
        BurstMeta.HexPlot.E_BtoGRvsTauBB = [];
        BurstMeta.Plots.E_BtoGRvsTauBB(3) = scatter([0,1],[0,1],'.','Parent',h.axes_E_BtoGRvsTauBB,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB = plot(h.axes_E_BtoGRvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.rBBvsTauBB(1) = imagesc(zeros(2),'Parent',h.axes_rBBvsTauBB);axis(h.axes_rBBvsTauBB,'tight');
        [~,BurstMeta.Plots.rBBvsTauBB(2)] = contourf(zeros(2),10,'Parent',h.axes_rBBvsTauBB,'Visible','off');
        BurstMeta.Plots.rBBvsTauBB(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.rBBvsTauBB(2).UIContextMenu = h.LifeTime_Menu;
        BurstMeta.HexPlot.rBBvsTauBB = [];
        BurstMeta.Plots.rBBvsTauBB(3) = scatter([0,1],[0,1],'.','Parent',h.axes_rBBvsTauBB,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        %%% Consider up to three Perrin lines
        BurstMeta.Plots.Fits.PerrinBB(1) = plot(h.axes_rBBvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinBB(2) = plot(h.axes_rBBvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinBB(3) = plot(h.axes_rBBvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','-','LineWidth',3,'Visible','off');
        %%% Individual Lifetime Tab
        BurstMeta.Plots.LifetimeInd_histX(1) = bar(h.axes_lifetime_ind_1d_x,0.5,1,'FaceColor',[0.6 0.6 0.6],'EdgeColor','none','BarWidth',1);BurstMeta.Plots.LifetimeInd_histX.UIContextMenu = h.ExportGraphLifetime_Menu;
        BurstMeta.Plots.LifetimeInd_histX(2) = stairs(h.axes_lifetime_ind_1d_x,[0 1],[nan nan],'Color',[0,0,0],'LineWidth',1);
        BurstMeta.Plots.LifetimeInd_histY(1) = bar(h.axes_lifetime_ind_1d_y,0.5,1,'FaceColor',[0.6 0.6 0.6],'EdgeColor','none','BarWidth',1);BurstMeta.Plots.LifetimeInd_histY.UIContextMenu = h.ExportGraphLifetime_Menu;
        BurstMeta.Plots.LifetimeInd_histY(2) = stairs(h.axes_lifetime_ind_1d_y,[0 1],[nan nan],'Color',[0,0,0],'LineWidth',1);
        BurstMeta.Plots.MultiScatter.h1dx_lifetime = [];
        BurstMeta.Plots.MultiScatter.h1dy_lifetime = [];
        %%% fFCS Tab
        BurstMeta.Plots.fFCS.IRF_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species1_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species2_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color',[0 0.5 0],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_DOnly_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color',[0.75 0 0.75],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.Microtime_Total_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        
        BurstMeta.Plots.fFCS.IRF_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species1_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species2_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color',[0 0.5 0],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_DOnly_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color',[0.75 0 0.75],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.Microtime_Total_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        
        BurstMeta.Plots.fFCS.FilterPar_Species1 = plot(h.axes_fFCS_FilterPar,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPar_Species2 = plot(h.axes_fFCS_FilterPar,[0 1],[0 0],'Color',[0 0.5 0],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPar_IRF = plot(h.axes_fFCS_FilterPar,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPar_DOnly = plot(h.axes_fFCS_FilterPar,[0 1],[0 0],'Color',[0.75 0 0.75],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.Reconstruction_Par = plot(h.axes_fFCS_ReconstructionPar,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Reconstruction_Decay_Par = plot(h.axes_fFCS_ReconstructionPar,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Weighted_Residuals_Par = plot(h.axes_fFCS_ReconstructionParResiduals,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        
        BurstMeta.Plots.fFCS.FilterPerp_Species1 = plot(h.axes_fFCS_FilterPerp,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPerp_Species2 = plot(h.axes_fFCS_FilterPerp,[0 1],[0 0],'Color',[0 0.5 0],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPerp_IRF = plot(h.axes_fFCS_FilterPerp,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPerp_DOnly = plot(h.axes_fFCS_FilterPerp,[0 1],[0 0],'Color',[0.75 0 0.75],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.Reconstruction_Perp = plot(h.axes_fFCS_ReconstructionPerp,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Reconstruction_Decay_Perp = plot(h.axes_fFCS_ReconstructionPerp,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Weighted_Residuals_Perp = plot(h.axes_fFCS_ReconstructionPerpResiduals,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.result_1x1 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.result_2x2 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color',[0 0.5 0],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.result_1x2 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.result_2x1 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color',[0.5 0.5 0.5],'LineStyle','-','LineWidth',1);
        %%%Corrections Tab for 3CMFD
        BurstMeta.Plots.histEBG_blueonly = bar(h.Corrections.ThreeCMFD.axes_crosstalk_BG,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
        %%%Consider fits also (three lines for 2 gauss fit)
        BurstMeta.Plots.Fits.histEBG_blueonly(1) = plot(h.Corrections.ThreeCMFD.axes_crosstalk_BG,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3);
        BurstMeta.Plots.Fits.histEBG_blueonly(2) = plot(h.Corrections.ThreeCMFD.axes_crosstalk_BG,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.histEBG_blueonly(3) = plot(h.Corrections.ThreeCMFD.axes_crosstalk_BG,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.histEBR_blueonly = bar(h.Corrections.ThreeCMFD.axes_crosstalk_BR,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
        %%%Consider fits also (three lines for 2 gauss fit)
        BurstMeta.Plots.Fits.histEBR_blueonly(1) = plot(h.Corrections.ThreeCMFD.axes_crosstalk_BR,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3);
        BurstMeta.Plots.Fits.histEBR_blueonly(2) = plot(h.Corrections.ThreeCMFD.axes_crosstalk_BR,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.histEBR_blueonly(3) = plot(h.Corrections.ThreeCMFD.axes_crosstalk_BR,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.histSBG_greenonly = bar(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
        %%%Consider fits also (three lines for 2 gauss fit)
        BurstMeta.Plots.Fits.histSBG_greenonly(1) = plot(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3);
        BurstMeta.Plots.Fits.histSBG_greenonly(2) = plot(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.histSBG_greenonly(3) = plot(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.histSBR_redonly = bar(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
        %%%Consider fits also (three lines for 2 gauss fit)
        BurstMeta.Plots.Fits.histSBR_redonly(1) = plot(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3);
        BurstMeta.Plots.Fits.histSBR_redonly(2) = plot(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.histSBR_redonly(3) = plot(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.gamma_BG_fit(1) = imagesc(zeros(2),'Parent',h.Corrections.ThreeCMFD.axes_gammaBG_threecolor);axis(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'tight');
        [~,BurstMeta.Plots.gamma_BG_fit(2)] = contourf(zeros(2),10,'Parent',h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'Visible','off');
        BurstMeta.Plots.Fits.gamma_BG = plot(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3);  %Fit
        BurstMeta.Plots.Fits.gamma_BG_manual = scatter(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,[0 1],[0 1],1000,'+','LineWidth',4,'MarkerFaceColor','b','MarkerEdgeColor','b','Visible','off');  %Manual
        BurstMeta.Plots.gamma_BR_fit(1) = imagesc(zeros(2),'Parent',h.Corrections.ThreeCMFD.axes_gammaBR_threecolor);axis(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'tight');
        [~,BurstMeta.Plots.gamma_BR_fit(2)] = contourf(zeros(2),10,'Parent',h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'Visible','off');
        BurstMeta.Plots.Fits.gamma_BR = plot(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3);  %Fit
        BurstMeta.Plots.Fits.gamma_BR_manual = scatter(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,[0 1],[0 1],1000,'+','LineWidth',4,'MarkerFaceColor','b','MarkerEdgeColor','b','Visible','off');  %Manual
        BurstMeta.Plots.gamma_threecolor_lifetime(1) = imagesc(zeros(2),'Parent',h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime);axis(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,'tight');
        [~,BurstMeta.Plots.gamma_threecolor_lifetime(2)] = contourf(zeros(2),'Parent',h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,'Visible','off');
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime = plot(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        
        ChangePlotType(h.PlotContourLines,[]);
        ChangePlotType(h.PlotTypePopumenu,[]);

        %%% Force switchgui to 2color to update axis label positions and
        %%% axis locations
        if isempty(BurstData)
            SwitchGUI(2,1);
        else
            SwitchGUI(BurstData{1}.BAMethod,1);
        end
    case 2
        %%% reset plots
        obj = [findall(h.BurstBrowser,'Type','stair');...
            findall(h.BurstBrowser,'Type','line');...
            findall(h.BurstBrowser,'Type','bar')];
        set(obj,'XData',0.5,'YData',1);
        obj = findall(h.BurstBrowser,'Type','image');
        set(obj,'XData',[0 1],'YData',[0 1],'CData',zeros(2));
        obj = findall(h.BurstBrowser,'Type','contour');
        set(obj,'XData',[0 1],'YData',[0 1],'ZData',zeros(2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Close Function: Clear global Variable on closing  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_BurstBrowser(obj,~)
global BurstData UserValues BurstTCSPCData PhotonStream BurstMeta
if ~isempty(BurstData) && UserValues.BurstBrowser.Settings.SaveOnClose
    %%% Ask for saving
    choice = questdlg('Save Changes?','Save before closing','Yes','Discard','Cancel','Discard');
    switch choice
        case 'Yes'
            Save_Analysis_State_Callback([],[]);
        case 'Cancel'
            return;
    end
end

CloseWindow(obj,[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Load *.bur file  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Burst_Data_Callback(obj,~,filenames)
global BurstData UserValues BurstMeta PhotonStream BurstTCSPCData

if ~isempty(obj)
    h = guidata(obj);
else
    h = guidata(findobj('Tag','BurstBrowser'));
    obj = 'FileHistory';
end

if obj ~= h.Append_File
    if ~isempty(BurstData) && UserValues.BurstBrowser.Settings.SaveOnClose
        %%% Ask for saving
        choice = questdlg('Save Changes?','Save before closing','Yes','Discard','Cancel','Discard');
        switch choice
            case 'Yes'
                Save_Analysis_State_Callback([],[]);
            case 'Cancel'
                return;
        end
    end
end
    
if obj ~= h.DatabaseBB.List
    LSUserValues(0);
    %%% check if there are subfolders
    subdir = dir(UserValues.File.BurstBrowserPath);
    subdir = subdir([subdir.isdir]);
    subdir = subdir(3:end); %%% remove '.' and '..' folders
    if isempty(subdir) %%% no subfolders, move one folder up
        path = fullfile(UserValues.File.BurstBrowserPath,'..',filesep);
    else 
        path = UserValues.File.BurstBrowserPath;
    end
    switch obj
        case {h.Load_Bursts, h.Append_File}
            switch obj
                case h.Load_Bursts %%% load once from one folder
                    [FileName,pathname,FilterIndex] = uigetfile({'*.bur','*.bur file';'*.kba','*.kba file from old PAM'}, 'Choose a file', path, 'MultiSelect', 'on');
                    if FilterIndex == 0
                        return;
                    end
                    if ischar(FileName)
                        FileName = {FileName};
                    end
                    %%% make pathname to cell array
                    for i = 1:numel(FileName)
                        PathName{i} = pathname;
                    end
                case h.Append_File
                    %%% query multiple files (only allow  *.bur files)
                    [FileName,pathname,FilterIndex] = uigetfile({'*.bur','*.bur file'}, 'Choose a file', path, 'MultiSelect', 'on');
                    if ischar(FileName)
                        FileName = {FileName};
                    end
                    %%% make pathname to cell array
                    for i = 1:numel(FileName)
                        PathName{i} = pathname;
                    end
                    while FilterIndex ~= 0 %%% query for more files until cancel is selected
                        [fn,pn,FilterIndex] = uigetfile({'*.bur','*.bur file'}, 'Choose a file', path, 'MultiSelect', 'on');
                        if FilterIndex ~= 0
                            if ischar(fn)
                                fn = {fn};
                            end
                            FileName = [FileName;fn];
                            for i = 1:numel(fn)
                                PathName{end+1} = pn;
                            end
                        end
                    end
            end
            
        case h.Load_Bursts_From_Folder
            %%% Choose a folder and load files from all subfolders
            %%% only consider one level downwards
            FileName = cell(0);
            PathName = cell(0);
            pathname = uigetdir(path,'Choose a folder. All *.bur files from direct subfolders will be loaded.');
            if pathname == 0
                return;
            end
            subdir = dir(pathname);
            subdir = subdir([subdir.isdir]);
            subdir = subdir(3:end); %%% remove '.' and '..' folders
            if isempty(subdir) %%% no subfolders
                return;
            end
            for i = 1:numel(subdir)
                files = dir([pathname filesep subdir(i).name]);
                if ~isempty(files) %%% ensure that there are files in this subfolder
                    for j = 1:numel(files)
                        if ~( strcmp(files(j).name,'.') || strcmp(files(j).name,'..') )
                            if strcmp(files(j).name(end-3:end),'.bur') %%% check for bur extension
                                FileName{end+1} = files(j).name;
                                PathName{end+1} = [pathname filesep subdir(i).name];
                            end
                        end
                    end
                end
            end
            if isempty(FileName)
                %%% no files have been found
                return;
            end
            FilterIndex = 1; %%% Only bur files supported
        case 'FileHistory'
            pathname = fileparts(filenames{1});
        otherwise
            pathname = UserValues.File.BurstBrowserPath;
    end
elseif obj == h.DatabaseBB.List
    %%% get Filelist from Database
    PathName = BurstMeta.Database(h.DatabaseBB.List.Value,2);
    FileName = BurstMeta.Database(h.DatabaseBB.List.Value,1);
    FilterIndex = 1;
    pathname = PathName{1};
else
    pathname = UserValues.File.BurstBrowserPath;
end

UserValues.File.BurstBrowserPath=pathname;
LSUserValues(1);

%%% Reset FCS buttons (no *.aps loaded anymore!)
%h.CorrelateWindow_Button.Enable = 'off';
%h.CorrelateWindow_Edit.Enable = 'off';
%%% Load data
switch obj
    case {h.Load_Bursts,h.DatabaseBB.List,h.Load_Bursts_From_Folder}
        Load_BurstFile(PathName,FileName,FilterIndex);
        %%% Enable append file
        h.Append_File.Enable = 'on';
    case h.Append_File
        Load_BurstFile(PathName,FileName,FilterIndex,1)
    otherwise %%% loaded from recent file list
        if nargin > 2
            for i = 1:numel(filenames)
                [PathName{i},FileName{i},ext] = fileparts(filenames{i});
                FileName{i} = [FileName{i},ext];
            end
            Load_BurstFile(PathName,FileName,1);
        end
        %%% Enable append file
        h.Append_File.Enable = 'on';
end
if isempty(BurstData)
    Progress(1,h.Progress_Axes,h.Progress_Text);
    return;
end

BurstMeta.SelectedFile = 1;
%%% Update Figure Name
BurstMeta.DisplayName = BurstData{1}.FileName;

%%%update file history with new files
%%% add files to file history
for i = 1:numel(FileName)
    file = fullfile(PathName{i},FileName{i});
    if strcmp(file(end-3:end),'.bur')
        h.DatabaseBB.FileHistory.add_file(file);
    end
end

% set default to efficiency and stoichiometry
if any(BurstData{1}.BAMethod == [1,2,5]) %%% Two-Color MFD
    %find positions of FRET Efficiency and Stoichiometry in NameArray
    posE = find(strcmp(BurstData{1}.NameArray,'FRET Efficiency'));
    %%% Compatibility check for old BurstExplorer Data
    if sum(strcmp(BurstData{1}.NameArray,'Stoichiometry')) == 0
        BurstData{1}.NameArray{strcmp(BurstData{1}.NameArray,'Stochiometry')} = 'Stoichiometry';
    end
    posS = find(strcmp(BurstData{1}.NameArray,'Stoichiometry'));
elseif any(BurstData{1}.BAMethod == [3,4]) %%% Three-Color MFD
    posE = find(strcmp(BurstData{1}.NameArray,'FRET Efficiency GR'));
    posS = find(strcmp(BurstData{1}.NameArray,'Stoichiometry GR'));
end

if BurstData{1}.APBS == 1
    %%% Enable the donor only lifetime checkbox
    h.DonorLifetimeFromDataCheckbox.Enable = 'on';
end

%%% Enable DataBase Append Loaded Files
h.DatabaseBB.AppendLoadedFiles.Enable = 'on';
%%% Reset Plots
Initialize_Plots(2);

%%% Switches GUI to 3cMFD or 2cMFD format
SwitchGUI(BurstData{1}.BAMethod);

%%% Initialize Parameters and Corrections for every loaded file
for i = 1:numel(BurstData)
    BurstMeta.SelectedFile = i;
    %%% Initialize Correction Structure
    UpdateCorrections([],[],h);
    %%% Add Derived Parameters
    AddDerivedParameters([],[],h);
    %%% ensure that Cut data is available
    UpdateCuts();
end
BurstMeta.SelectedFile = 1;

%%% Set Parameter list after all parameters are defined
set(h.ParameterListX, 'String', BurstData{1}.NameArray);
set(h.ParameterListX, 'Value', posE);

set(h.ParameterListY, 'String', BurstData{1}.NameArray);
set(h.ParameterListY, 'Value', posS);

if isfield(BurstMeta,'fFCS')
    BurstMeta = rmfield(BurstMeta,'fFCS');
end
if isfield(BurstMeta,'Data')
    BurstMeta = rmfield(BurstMeta,'Data');
end

%%% Update Species List
UpdateSpeciesList(h);
h = guidata(h.BurstBrowser);drawnow;

%%% Apply correction on load
if UserValues.BurstBrowser.Settings.CorrectionOnLoad == 1
    for i = 1:numel(BurstData)
        BurstMeta.SelectedFile = i;
        ApplyCorrections([],[],h,0);
    end
else %%% indicate that no corrections are applied
    h.ApplyCorrectionsButton.ForegroundColor = [1 0 0];
end
BurstMeta.SelectedFile = 1; % select first file again

UpdateCutTable(h);
UpdateCuts();

ChangePlotType(h.PlotContourLines) 
ChangePlotType(h.PlotTypePopumenu) 

Update_fFCS_GUI(gcbo,[]);

function Load_BurstFile(PathName,FileName,FilterIndex,append)
global BurstData BurstMeta BurstTCSPCData PhotonStream
if ischar(FileName)
    FileName = {FileName};
end
if nargin < 4
    append = 0;
end
if append == 0
    %%% clear global variables
    BurstData = [];
    BurstTCSPCData = [];
    PhotonStream = [];
end
h = guidata(findobj('Tag','BurstBrowser'));
for i = 1:numel(FileName)
    Progress((i-1)/numel(FileName),h.Progress_Axes,h.Progress_Text,['Loading File ' num2str(i) ' of ' num2str(numel(FileName))]);
    if ~exist(fullfile(PathName{i},FileName{i}),'file')
        disp(['File ' fullfile(PathName{i},FileName{i}) ' does not exist.']);
        h.Progress_Text.String = 'Error - File not found.';
        uiwait(h.BurstBrowser,1);
        return;
    end
    S = load('-mat',fullfile(PathName{i},FileName{i}));
    
    %%% Convert old File Format to new
    if FilterIndex == 2 % KBA file was loaded
        if ~isfield(S,'Data') % no variable named Data exists (very old)
            %%% find out the BurstSearch Type from filename
            if ~isempty(strfind(FileName{i},'ACBS_2C'))
                S.Data.BAMethod = 1;
            elseif ~isempty(strfind(FileName{i},'DCBS_2C'))
                S.Data.BAMethod = 2;
            elseif ~isempty(strfind(FileName{i},'ACBS_3C'))
                S.Data.BAMethod = 3;
            elseif ~isempty(strfind(FileName{i},'TCBS_3C'))
                S.Data.BAMethod = 4;
            end
        end
        switch S.Data.BAMethod
            case {1,2} %%% 2 Color MFD
                %%% Convert NameArray
                S.NameArray{strcmp(S.NameArray,'TFRET - TR')} = '|TDX-TAA| Filter';
                S.NameArray{strcmp(S.NameArray,'Stochiometry')} = 'Stoichiometry';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (green)')} = 'Number of Photons (DD)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (fret)')} = 'Number of Photons (DA)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (red)')} = 'Number of Photons (AA)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (green, parallel)')} = 'Number of Photons (DD par)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (green, perpendicular)')} = 'Number of Photons (DD perp)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (fret, parallel)')} = 'Number of Photons (DA par)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (fret, perpendicular)')} = 'Number of Photons (DA perp)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (red, parallel)')} = 'Number of Photons (AA par)';
                S.NameArray{strcmp(S.NameArray,'Number of Photons (red, perpendicular)')} = 'Number of Photons (AA perp)';
                if sum(strcmp(S.NameArray,'tau(green)')) > 0
                    S.NameArray{strcmp(S.NameArray,'tau(green)')} = 'Lifetime D [ns]';
                    S.NameArray{strcmp(S.NameArray,'tau(red)')} = 'Lifetime A [ns]';
                    S.DataArray(:,strcmp(S.NameArray,'Lifetime D [ns]')) = S.DataArray(:,strcmp(S.NameArray,'Lifetime D [ns]'))*1E9;
                    S.DataArray(:,strcmp(S.NameArray,'Lifetime A [ns]')) = S.DataArray(:,strcmp(S.NameArray,'Lifetime A [ns]'))*1E9;
                else %%% create zero value arrays
                    S.NameArray{end+1} = 'Lifetime D [ns]';
                    S.NameArray{end+1} = 'Lifetime A [ns]';
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                end
                S.NameArray{end+1} = 'Anisotropy D';
                S.NameArray{end+1} = 'Anisotropy A';
                %%% Calculate Anisotropies
                S.DataArray(:,end+1) = (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DD par)')) - S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DD perp)')))./...
                    (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DD par)')) + 2.*S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DD perp)')));
                S.DataArray(:,end+1) = (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (AA par)')) - S.DataArray(:,strcmp(S.NameArray,'Number of Photons (AA perp)')))./...
                    (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (AA par)')) + 2*S.DataArray(:,strcmp(S.NameArray,'Number of Photons (AA perp)')));
                
                if sum(strcmp(S.NameArray,'Proximity Ratio')) == 0
                    S.NameArray{end+1} = 'Proximity Ratio';
                    S.DataArray(:,end+1) = (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DA par)')) + S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DA perp)')))./...
                        (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DD par)')) + S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DD perp)')) +...
                         S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DA par)')) + S.DataArray(:,strcmp(S.NameArray,'Number of Photons (DA perp)')));
                end
                S.BurstData.NameArray = S.NameArray;
                S.BurstData.DataArray = S.DataArray;
                S.BurstData.BAMethod = S.Data.BAMethod;
                if isfield(S.Data,'Filetype')
                    S.BurstData.FileType = S.Data.Filetype;
                else
                    S.BurstData.FileType = 'SPC';
                end
                if ~isfield(S.Data,'SyncRate')
                    S.Data.SyncRate = round(1/37.5E-9);
                end
                if isfield(S.Data,'TACrange')
                    S.BurstData.TACRange = S.Data.TACrange;
                else
                    S.BurstData.TACRange = 1E9./S.Data.SyncRate; %kba file from old Pam
                    % this will not work when the syncrate and clock rate are
                    % different
                end
                S.BurstData.SyncPeriod = 1./S.Data.SyncRate;
                S.BurstData.ClockPeriod = S.BurstData.SyncPeriod;
                S.BurstData.FileInfo.MI_Bins = 4096;
                S.BurstData.FileInfo.TACRange = S.BurstData.TACRange;
                if isfield(S.Data,'PIEChannels')
                    S.BurstData.PIE.From = [S.Data.PIEChannels.fromGG1, S.Data.PIEChannels.fromGG2,...
                        S.Data.PIEChannels.fromGR1, S.Data.PIEChannels.fromGR2,...
                        S.Data.PIEChannels.fromRR1, S.Data.PIEChannels.fromRR2];
                    S.BurstData.PIE.To = [S.Data.PIEChannels.toGG1, S.Data.PIEChannels.toGG2,...
                        S.Data.PIEChannels.toGR1, S.Data.PIEChannels.toGR2,...
                        S.Data.PIEChannels.toRR1, S.Data.PIEChannels.toRR2];
                elseif isfield(S.Data,'fFCS')
                    S.BurstData.PIE.From = S.Data.fFCS.lower;
                    S.BurstData.PIE.To = S.Data.fFCS.upper;
                end

                %%% Calculate IRF microtime histogram
                if isfield(S.Data,'IRFmicrotime')
                    for j = 1:6
                        S.BurstData.IRF{j} = histc(S.Data.IRFmicrotime{j}, 0:(S.BurstData.FileInfo.MI_Bins-1));
                    end
                    S.BurstData.ScatterPattern = S.BurstData.IRF;
                end
                if isfield(S.Data,'Macrotime')
                    S.BurstTCSPCData.Macrotime = S.Data.Macrotime;
                    S.BurstTCSPCData.Microtime = S.Data.Microtime;
                    S.BurstTCSPCData.Channel = S.Data.Channel;
                    S.BurstTCSPCData.Macrotime = cellfun(@(x) x',S.BurstTCSPCData.Macrotime,'UniformOutput',false);
                    S.BurstTCSPCData.Microtime = cellfun(@(x) x',S.BurstTCSPCData.Microtime,'UniformOutput',false);
                    S.BurstTCSPCData.Channel = cellfun(@(x) x',S.BurstTCSPCData.Channel,'UniformOutput',false);
                end
            case {3,4} %%% 3Color MFD
                %%% Convert NameArray
                S.NameArray{strcmp(S.NameArray,'TG - TR (PIE)')} = '|TGX-TRR| Filter';
                S.NameArray{strcmp(S.NameArray,'TB - TR (PIE)')} = '|TBX-TRR| Filter';
                S.NameArray{strcmp(S.NameArray,'TB - TG (PIE)')} = '|TBX-TGX| Filter';
                S.NameArray{strcmp(S.NameArray,'Efficiency* (G -> R)')} = 'FRET Efficiency GR';
                S.NameArray{strcmp(S.NameArray,'Efficiency* (B -> R)')} = 'FRET Efficiency BR';
                S.NameArray{strcmp(S.NameArray,'Efficiency* (B -> G)')} = 'FRET Efficiency BG';
                S.NameArray{strcmp(S.NameArray,'Efficiency* (B -> G+R)')} = 'FRET Efficiency B->G+R';
                S.NameArray{strcmp(S.NameArray,'Stochiometry (GR)')} = 'Stoichiometry GR';
                S.NameArray{strcmp(S.NameArray,'Stochiometry (BG)')} = 'Stoichiometry BG';
                S.NameArray{strcmp(S.NameArray,'Stochiometry (BR)')} = 'Stoichiometry BR';
                if sum(strcmp(S.NameArray,'tau(green)')) > 0
                    S.NameArray{strcmp(S.NameArray,'tau(blue)')} = 'Lifetime BB [ns]';
                    S.NameArray{strcmp(S.NameArray,'tau(green)')} = 'Lifetime GG [ns]';
                    S.NameArray{strcmp(S.NameArray,'tau(red)')} = 'Lifetime RR [ns]';
                    S.DataArray(:,strcmp(S.NameArray,'Lifetime BB [ns]')) = S.DataArray(:,strcmp(S.NameArray,'Lifetime BB [ns]'))*1E9;
                    S.DataArray(:,strcmp(S.NameArray,'Lifetime GG [ns]')) = S.DataArray(:,strcmp(S.NameArray,'Lifetime GG [ns]'))*1E9;
                    S.DataArray(:,strcmp(S.NameArray,'Lifetime RR [ns]')) = S.DataArray(:,strcmp(S.NameArray,'Lifetime RR [ns]'))*1E9;
                else %%% create zero value arrays
                    S.NameArray{end+1} = 'Lifetime BB [ns]';
                    S.NameArray{end+1} = 'Lifetime GG [ns]';
                    S.NameArray{end+1} = 'Lifetime RR [ns]';
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                end
                if sum(strcmp(S.NameArray,'Proximity Ratio B->G+R'))==0
                    S.NameArray{end+1} = 'Proximity Ratio B->G+R';
                    S.DataArray(:,end+1) = S.DataArray(:,strcmp(S.NameArray,'FRET Efficiency B->G+R'));
                end
                %%% Calculate Anisotropies
                S.NameArray{end+1} = 'Anisotropy BB';
                S.NameArray{end+1} = 'Anisotropy GG';
                S.NameArray{end+1} = 'Anisotropy RR';
                if sum(strcmp(S.NameArray,'Number of Photons (BB par)'))
                    S.DataArray(:,end+1) = (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (BB par)')) - S.DataArray(:,strcmp(S.NameArray,'Number of Photons (BB perp)')))./...
                        (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (BB par)')) + 2.*S.DataArray(:,strcmp(S.NameArray,'Number of Photons (BB perp)')));
                    S.DataArray(:,end+1) = (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (GG par)')) - S.DataArray(:,strcmp(S.NameArray,'Number of Photons (GG perp)')))./...
                        (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (GG par)')) + 2.*S.DataArray(:,strcmp(S.NameArray,'Number of Photons (GG perp)')));
                    S.DataArray(:,end+1) = (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (RR par)')) - S.DataArray(:,strcmp(S.NameArray,'Number of Photons (RR perp)')))./...
                        (S.DataArray(:,strcmp(S.NameArray,'Number of Photons (RR par)')) + 2*S.DataArray(:,strcmp(S.NameArray,'Number of Photons (RR perp)')));
                else
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                    S.DataArray(:,end+1) = zeros(size(S.DataArray,1),1);
                end
                S.BurstData.NameArray = S.NameArray;
                S.BurstData.DataArray = S.DataArray;
                S.BurstData.BAMethod = S.Data.BAMethod;
                if isfield(S.Data,'Filetype')
                    S.BurstData.FileType = S.Data.Filetype;
                end
                if ~isfield(S.Data,'SyncRate')
                    S.Data.SyncRate = round(1/37.5E-9);
                end
                if isfield(S.Data,'TACrange')
                    S.BurstData.TACRange = S.Data.TACrange;
                    S.BurstData.FileInfo.TACRange = S.Data.TACrange;
                else
                    S.BurstData.TACRange =  1E9./S.Data.SyncRate;
                    S.BurstData.FileInfo.TACRange =  1E9./S.Data.SyncRate;
                    % this will not work if the syncrate and clockrate are
                    % different
                end
                S.BurstData.SyncPeriod = 1./S.Data.SyncRate;
                S.BurstData.ClockPeriod = S.BurstData.SyncPeriod;  %kba file from old pam
                S.BurstData.FileInfo.MI_Bins = 4096;

                if isfield(S.Data,'PIEChannels')
                    S.BurstData.PIE.From = [S.Data.PIEChannels.fromBB1, S.Data.PIEChannels.fromBB2,...
                        S.Data.PIEChannels.fromBG1, S.Data.PIEChannels.fromBG2,...
                        S.Data.PIEChannels.fromBR1, S.Data.PIEChannels.fromBR2,...
                        S.Data.PIEChannels.fromGG1, S.Data.PIEChannels.fromGG2,...
                        S.Data.PIEChannels.fromGR1, S.Data.PIEChannels.fromGR2,...
                        S.Data.PIEChannels.fromRR1, S.Data.PIEChannels.fromRR2];
                    S.BurstData.PIE.To = [S.Data.PIEChannels.toBB1, S.Data.PIEChannels.toBB2,...
                        S.Data.PIEChannels.toBG1, S.Data.PIEChannels.toBG2,...
                        S.Data.PIEChannels.toBR1, S.Data.PIEChannels.toBR2,...
                        S.Data.PIEChannels.toGG1, S.Data.PIEChannels.toGG2,...
                        S.Data.PIEChannels.toGR1, S.Data.PIEChannels.toGR2,...
                        S.Data.PIEChannels.toRR1, S.Data.PIEChannels.toRR2];
                elseif isfield(S.Data,'fFCS')
                    S.BurstData.PIE.From = S.Data.fFCS.lower;
                    S.BurstData.PIE.To = S.Data.fFCS.upper;
                end

                %%% Calculate IRF microtime histogram
                if isfield(S.Data,'IRFmicrotime')
                    for j = 1:12
                        S.BurstData.IRF{j} = histc(S.Data.IRFmicrotime{j}, 0:(S.BurstData.FileInfo.MI_Bins-1));
                    end
                    S.BurstData.ScatterPattern = S.BurstData.IRF;
                end
                if isfield(S.Data,'Macrotime')
                    S.BurstTCSPCData.Macrotime = S.Data.Macrotime;
                    S.BurstTCSPCData.Microtime = S.Data.Microtime;
                    S.BurstTCSPCData.Channel = S.Data.Channel;
                    S.BurstTCSPCData.Macrotime = cellfun(@(x) x',S.BurstTCSPCData.Macrotime,'UniformOutput',false);
                    S.BurstTCSPCData.Microtime = cellfun(@(x) x',S.BurstTCSPCData.Microtime,'UniformOutput',false);
                    S.BurstTCSPCData.Channel = cellfun(@(x) x',S.BurstTCSPCData.Channel,'UniformOutput',false);
                end
        end
    end
    
    %%% Check if newly loaded file is compatible with currently loaded file
    if ~isempty(BurstData) %%% make sure the was a file loaded before
        switch BurstData{1}.BAMethod
            case {1,2,5} %%% loaded files are 2color
                if ~any(S.BurstData.BAMethod == [1,2,5]) %%% loaded file is not of same type
                    fprintf('Error loading file %s\nSkipping file %i because it is not of same type as loaded files.\nLoaded files are 2 color type.\nFile %i is 3 color type.\n',FileName{i},i,i);
                    Progress(1,h.Progress_Axes,h.Progress_Text);
                    return; %%% Skip file
                end
            case {3,4} %%% loaded files are 2color
                if ~any(S.BurstData.BAMethod == [3,4]) %%% loaded file is not of same type
                    fprintf('Error loading file %s\nSkipping file %i because it is not of same type as loaded files.\nLoaded files are 3 color type.\nFile %i is 2 color type.\n',FileName{i},i,i);
                    Progress(1,h.Progress_Axes,h.Progress_Text);
                    return; %%% Skip file
                end
        end
    end
    
    %%% Determine if an APBS or DCBS file was loaded
    %%% This is important because for APBS, the donor only lifetime can be
    %%% determined from the measurement!
    %%% Check for DCBS/TCBS
    if isfield(S.BurstData,'BAMethod')
        if ~any(S.BurstData.BAMethod == [2,4]);
            %%% Crosstalk/direct excitation can be determined!
            %%% set flag:
            S.BurstData.APBS = 1;
        else
            S.BurstData.APBS = 0;
        end
    end
    %%% New: Cuts stored in Additional Variable when it was already saved
    %%% once in BurstBrowser
    %%% overwrite BurstData subfields with separately saved variables
    if isfield(S,'Cut')
        S.BurstData.Cut = S.Cut;
    end
    
    %%% Add corrected proximity ratios (== signal fractions) for three-colorMFD
    if any(S.BurstData.BAMethod == [3,4])
        if ~any(strcmp(S.BurstData.NameArray,'Proximity Ratio GR (raw)'))
            NameArray_dummy = cell(1,size(S.BurstData.NameArray,2)+4);
            DataArray_dummy = zeros(size(S.BurstData.DataArray,1),size(S.BurstData.DataArray,2)+4);
            %%% Insert corrected proximity ratios into namearray
            NameArray_dummy(1:11) = S.BurstData.NameArray(1:11);
            NameArray_dummy(12:15) = {'Proximity Ratio GR (raw)','Proximity Ratio BG (raw)','Proximity Ratio BR (raw)','Proximity Ratio B->G+R (raw)'};
            NameArray_dummy(16:end) = S.BurstData.NameArray(12:end);
            %%% duplicate proximity ratios into data array
            DataArray_dummy(:,1:11) = S.BurstData.DataArray(:,1:11);
            DataArray_dummy(:,12:15) = S.BurstData.DataArray(:,8:11);
            DataArray_dummy(:,16:end) = S.BurstData.DataArray(:,12:end);
            %%% replace arrays
            S.BurstData.NameArray = NameArray_dummy;
            S.BurstData.DataArray = DataArray_dummy;
        end
    end

    %% Fix missing "FRET" in Efficiency naming (NameArray) and update old GG/RR naming scheme to D/A
    try
        if any(S.BurstData.BAMethod == [1,2,5])
            S.BurstData.NameArray{strcmp(S.BurstData.NameArray,'Efficiency')} = 'FRET Efficiency';
            %%% also fix Cuts
            if isfield(S.BurstData,'Cut')
                for k = 1:numel(S.BurstData.Cut) %%% loop over species
                    for l = 1:numel(S.BurstData.Cut{k}) %%% loop over cuts in species
                        if strcmp(S.BurstData.Cut{k}{l}{1},'Efficiency')
                            S.BurstData.Cut{k}{l}{1} = 'FRET Efficiency';
                        end
                    end
                end
            end
        elseif any(S.BurstData.BAMethod == [3,4])
            S.BurstData.NameArray{strcmp(S.BurstData.NameArray,'Efficiency GR')} = 'FRET Efficiency GR';
            S.BurstData.NameArray{strcmp(S.BurstData.NameArray,'Efficiency BG')} = 'FRET Efficiency BG';
            S.BurstData.NameArray{strcmp(S.BurstData.NameArray,'Efficiency BR')} = 'FRET Efficiency BR';
            S.BurstData.NameArray{strcmp(S.BurstData.NameArray,'Efficiency B->G+R')} = 'FRET Efficiency B->G+R';
            %%% also fix Cuts
            if isfield(S.BurstData,'Cut')
                for k = 1:numel(S.BurstData.Cut) %%% loop over species
                    for j = 1:numel(S.BurstData.Cut{k}) %%% loop over cuts in species
                        if strcmp(S.BurstData.Cut{k}{j}{1},'Efficiency GR')
                            S.BurstData.Cut{k}{j}{1} = 'FRET Efficiency GR';
                        end
                        if strcmp(S.BurstData.Cut{k}{j}{1},'Efficiency BG')
                            S.BurstData.Cut{k}{j}{1} = 'FRET Efficiency BG';
                        end
                        if strcmp(S.BurstData.Cut{k}{j}{1},'Efficiency BR')
                            S.BurstData.Cut{k}{j}{1} = 'FRET Efficiency BR';
                        end
                        if strcmp(S.BurstData.Cut{k}{j}{1},'Efficiency B->G+R')
                            S.BurstData.Cut{k}{j}{1} = 'FRET Efficiency B->G+R';
                        end
                    end
                end
            end
        end
    end
	if any(S.BurstData.BAMethod == [1,2,5])
        oldNames = {'Lifetime GG [ns]','Lifetime RR [ns]','Anisotropy GG','Anisotropy RR','|TGX-TRR| Filter','|TGG-TGR| Filter','Countrate [kHz]'...
            'Count rate (GG) [kHz]','Count rate (GR) [kHz]','Count rate (RR) [kHz]','Count rate (GG par) [kHz]','Count rate (GG per) [kHz]','Count rate (GR par) [kHz]','Count rate (GR per) [kHz]','Count rate (RR par) [kHz]','Count rate (RR per) [kHz]',...
            'Countrate (GG) [kHz]','Countrate (GR) [kHz]','Countrate (RR) [kHz]','Countrate (GG par) [kHz]','Countrate (GG per) [kHz]','Countrate (GR par) [kHz]','Countrate (GR per) [kHz]','Countrate (RR par) [kHz]','Countrate (RR per) [kHz]',...
            'Number of Photons (GG)','Number of Photons (GR)','Number of Photons (RR)','Number of Photons (GG par)','Number of Photons (GG perp)','Number of Photons (GR par)','Number of Photons (GR perp)','Number of Photons (RR par)','Number of Photons (RR perp)'};
        newNames = {'Lifetime D [ns]','Lifetime A [ns]','Anisotropy D','Anisotropy A','|TDX-TAA| Filter','|TDD-TDA| Filter','Count rate [kHz]'...
            'Count rate (DD) [kHz]','Count rate (DA) [kHz]','Count rate (AA) [kHz]','Count rate (DD par) [kHz]','Count rate (DD perp) [kHz]','Count rate (DA par) [kHz]','Count rate (DA perp) [kHz]','Count rate (AA par) [kHz]','Count rate (AA perp) [kHz]',...
            'Count rate (DD) [kHz]','Count rate (DA) [kHz]','Count rate (AA) [kHz]','Count rate (DD par) [kHz]','Count rate (DD perp) [kHz]','Count rate (DA par) [kHz]','Count rate (DA perp) [kHz]','Count rate (AA par) [kHz]','Count rate (AA perp) [kHz]',...
            'Number of Photons (DD)','Number of Photons (DA)','Number of Photons (AA)','Number of Photons (DD par)','Number of Photons (DD perp)','Number of Photons (DA par)','Number of Photons (DA perp)','Number of Photons (AA par)','Number of Photons (AA perp)'};
        oldName_exists = false(size(oldNames));
        for m = 1:numel(oldNames)
            if sum(strcmp(S.BurstData.NameArray,oldNames{m})) > 0
                S.BurstData.NameArray{strcmp(S.BurstData.NameArray,oldNames{m})} = newNames{m};
                oldName_exists(m) = true;
            end
        end
        %%% also fix Cuts for corrected parameters
        if isfield(S.BurstData,'Cut')
            for k = 1:numel(S.BurstData.Cut) %%% loop over species
                for l = 1:numel(S.BurstData.Cut{k}) %%% loop over cuts in species
                    for m = 1:numel(oldNames)
                        if oldName_exists(m)
                            if strcmp(S.BurstData.Cut{k}{l}{1},oldNames{m})
                                S.BurstData.Cut{k}{l}{1} = newNames{m};
                            end
                        end
                    end
                end
            end
        end
    end
    %% Fix naming of ClockPeriod/SyncPeriod
    % burst analysis before December 16, 2015
    if ~isfield(S.BurstData, 'ClockPeriod')
        S.BurstData.ClockPeriod = S.BurstData.SyncPeriod;
        if isfield(S.BurstData,'FileInfo')
            if isfield(S.BurstData.FileInfo,'SyncPeriod')
                S.BurstData.FileInfo.ClockPeriod = S.BurstData.FileInfo.SyncPeriod;
            end
        else
            S.BurstData.FileInfo.SyncPeriod = S.BurstData.SyncPeriod;
            S.BurstData.FileInfo.ClockPeriod = S.BurstData.SyncPeriod;
        end
        if isfield(S.BurstData.FileInfo,'Card')
            if ~strcmp(S.BurstData.FileInfo.Card, 'SPC-140/150/830/130')
                %if SPC-630 is used, set the SyncPeriod to what it really is
                S.BurstData.SyncPeriod = 1/8E7*3;
                S.BurstData.FileInfo.SyncPeriod = 1/8E7*3;
                if rand < 0.05
                    msgbox('Be aware that the SyncPeriod is hardcoded. This message appears 1 out of 20 times.')
                end
            end
        end
    end
    
    %%
    S.BurstData.FileName = FileName{i};
    S.BurstData.PathName = PathName{i};
    %%% check for existing Cuts
    if ~isfield(S.BurstData,'Cut') %%% no cuts existed
        %initialize Cut Cell Array with standard cuts
        switch S.BurstData.BAMethod
            case {1,2,5}
                %%% FRET efficiency and stoichiometry basic cuts
                Cut = {{'FRET Efficiency',-0.1,1.1,true,false},{'Stoichiometry',-0.1,1.1,true,false}};
            case {3,4}
                %%% 3color, only do FRET GR and Stoichiometry cuts
                Cut = {{'FRET Efficiency GR',-0.1,1.1,true,false},{'Stoichiometry GR',-0.1,1.1,true,false},...
                    {'Stoichiometry BG',-0.1,1.1,true,false},{'Stoichiometry BR',-0.1,1.1,true,false}};
        end
        S.BurstData.Cut{1} = Cut;
        S.BurstData.Cut{2} = Cut;
        S.BurstData.Cut{3} = Cut;
        %add species to list
        S.BurstData.SpeciesNames{1} = 'Global Cuts';
        % also add two species for convenience
        S.BurstData.SpeciesNames{2} = 'Subspecies 1';
        S.BurstData.SpeciesNames{3} = 'Subspecies 2';
        S.BurstData.SelectedSpecies = [1,1];
    elseif isfield(S.BurstData,'Cut') %%% cuts existed, change to new format with uitree
        if isfield(S.BurstData,'SelectedSpecies')
            if numel(S.BurstData.SelectedSpecies) == 1
                S.BurstData.SelectedSpecies = [1,1];
            end
        end
    end
    
    if isfield(S,'SpeciesNames')
        S.BurstData.SpeciesNames = S.SpeciesNames;
    end
    if isfield(S,'SelectedSpecies')
        S.BurstData.SelectedSpecies = S.SelectedSpecies;
    end
    if isfield(S,'Background')
        S.BurstData.Background = S.Background;
    end
    if isfield(S,'Corrections')
        S.BurstData.Corrections = S.Corrections;
    end
    if isfield(S,'FitCut')
        S.BurstData.FitCut = S.FitCut;
    end
    if isfield(S,'ArbitraryCut')
        S.BurstData.ArbitraryCut = S.ArbitraryCut;
    end
    if isfield(S,'AdditionalParameters')
        S.BurstData.AdditionalParameters = S.AdditionalParameters;
    end
    %%% initialize DataCut
    S.BurstData.DataCut = S.BurstData.DataArray;
    %%% transfer to Global BurstData Structure holding all loaded files
    if append
        BurstData{end+1} = S.BurstData;
        if ~isfield(S,'BurstTCSPCData')
            BurstTCSPCData{end+1} = [];
        elseif isfield(S,'BurstTCSPCData')
            BurstTCSPCData{end+1} = S.BurstTCSPCData;
        end
        PhotonStream{end+1} = [];
    else
        BurstData{i} = S.BurstData;
        if ~isfield(S,'BurstTCSPCData')
            BurstTCSPCData{i} = [];
        elseif isfield(S,'BurstTCSPCData')
            BurstTCSPCData{i} = S.BurstTCSPCData;
        end
        PhotonStream{i} = [];
    end
end

BurstMeta.SelectedFile = 1;
Progress(1,h.Progress_Axes,h.Progress_Text);

function Files = GetMultipleFiles(FilterSpec,Title,PathName)
FileName = 1;
count = 0;
PathName= fullfile(PathName,'..',filesep);%%% go one layer above since .*bur files are nested
Files = [];
while FileName ~= 0
    [FileName,PathName] = uigetfile(FilterSpec,Title, PathName, 'MultiSelect', 'on');
    if ~iscell(FileName)
        if FileName ~= 0
            count = count+1;
            Files{count,1} = FileName;
            Files{count,2} = PathName;
        end
    elseif iscell(FileName)
        for i = 1:numel(FileName)
            if FileName{i} ~= 0
                count = count+1;
                Files{count,1} = FileName{i};
                Files{count,2} = PathName;
            end
        end
        FileName = FileName{end};
    end
    PathName= fullfile(PathName,'..',filesep);%%% go one layer above since .*bur files are nested
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Merge multiple *.bur file  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Merge_bur_files(~,~)
h = guidata(gcbo);
global UserValues

%%% Select files
Files = GetMultipleFiles({'*.bur','*.bur file'}, 'Choose a file', UserValues.File.BurstBrowserPath);

if size(Files,1) < 2
    m = msgbox('Select more than one file!');
    pause(1);
    delete(m);
    return;
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Merging files...');
%%% Load Files in CellArray
MergeData = cell(size(Files,1),1);
for i = 1:size(Files,1)
    MergeData{i} = load(fullfile(Files{i,2},Files{i,1}),'-mat');
    % burst analysis before December 16, 2015
    if ~isfield(MergeData{i}.BurstData, 'ClockPeriod')
        MergeData{i}.BurstData.ClockPeriod = MergeData{i}.BurstData.SyncPeriod;
        MergeData{i}.FileInfo.ClockPeriod = MergeData{i}.BurstData.FileInfo.SyncPeriod;
        if isfield(MergeData{i}.BurstData.FileInfo,'Card')
            if ~strcmp(MergeData{i}.BurstData.FileInfo.Card, 'SPC-140/150/830/130')
                %if SPC-630 is used, set the SyncPeriod to what it really is
                MergeData{i}.BurstData.SyncPeriod = 1/8E7*3;
                MergeData{i}.BurstData.FileInfo.SyncPeriod = 1/8E7*3;
                if rand < 0.05
                    msgbox('Be aware that the SyncPeriod is hardcoded. This message appears 1 out of 20 times.')
                end
            end
        end
    end
end

Progress(0.2,h.Progress_Axes,h.Progress_Text,'Merging files...');

%%% Create Arrays of Parameters
for i=1:numel(MergeData)
    MergedParameters.NameArray{i} = MergeData{i}.BurstData.NameArray;
    try
        MergedParameters.TACRange{i} = MergeData{i}.BurstData.TACRange;
    catch
        MergedParameters.TACRange{i} = MergeData{i}.BurstData.TACrange;
    end
    MergedParameters.BAMethod{i} = MergeData{i}.BurstData.BAMethod;
    MergedParameters.Filetype{i} = MergeData{i}.BurstData.Filetype;
    MergedParameters.SyncPeriod{i} = MergeData{i}.BurstData.SyncPeriod;
    MergedParameters.ClockPeriod{i} = MergeData{i}.BurstData.ClockPeriod;
    MergedParameters.FileInfo{i} = MergeData{i}.BurstData.FileInfo;
    MergedParameters.PIE{i} = MergeData{i}.BurstData.PIE;
    MergedParameters.IRF{i} = MergeData{i}.BurstData.IRF;
    MergedParameters.ScatterPattern{i} = MergeData{i}.BurstData.ScatterPattern;
    MergedParameters.Background{i} = MergeData{i}.BurstData.Background;
    MergedParameters.FileNameSPC{i} = MergeData{i}.BurstData.FileNameSPC;
    %%% use update path information
    MergedParameters.PathName{i} = fileparts(Files{i,1});
    MergedParameters.FileName{i} = Files{i,1};
    %MergedParameters.PathName{i} = MergeData{i}.BurstData.PathName;
    %MergedParameters.FileName{i} = MergeData{i}.BurstData.FileName;
    if isfield(MergeData{i}.BurstData,'Cut')
        MergedParameters.Cut{i} = MergeData{i}.BurstData.Cut;
    end
    if isfield(MergeData{i}.BurstData,'SpeciesNames')
        MergedParameters.SpeciesNames{i} = MergeData{i}.BurstData.SpeciesNames;
    end
    if isfield(MergeData{i}.BurstData,'SelectedSpecies')
        MergedParameters.SelectedSpecies{i} = MergeData{i}.BurstData.SelectedSpecies;
    end
    if isfield(MergeData{i}.BurstData,'Corrections')
        MergedParameters.Corrections{i} = MergeData{i}.BurstData.Corrections;
    end
end
%%% Use first file for general variables
Merged = MergeData{1}.BurstData;

Progress(0.2,h.Progress_Axes,h.Progress_Text,'Merging files...');

%%% Concatenate DataArray
for i =2:numel(MergeData)
    Merged.DataArray = [Merged.DataArray;MergeData{i}.BurstData.DataArray];
end

%%% Add a new parameter (file number);
Merged.NameArray{end+1} = 'File Number';
filenumber = [];
for i = 1:numel(MergeData)
    filenumber = [filenumber; i*ones(size(MergeData{i}.BurstData.DataArray,1),1)];
end
Merged.DataArray(:,end+1) = filenumber;

BurstData = Merged;
BurstData.MergedParameters = MergedParameters;

Progress(0.3,h.Progress_Axes,h.Progress_Text,'Merging files...');

%%% Also Load *.bps files and concatenate
MergeData = cell(size(Files,1),1);
for i = 1:size(Files,1)
    file = fullfile(Files{i,2},Files{i,1});
    MergeData{i} = load([file(1:end-3) 'bps'],'-mat');
end

Progress(0.4,h.Progress_Axes,h.Progress_Text,'Merging files...');

Macrotime = MergeData{1}.Macrotime;
Microtime = MergeData{1}.Microtime;
Channel = MergeData{1}.Channel;
for i = 2:numel(MergeData)
    Macrotime = vertcat(Macrotime,MergeData{i}.Macrotime);
    Microtime = vertcat(Microtime,MergeData{i}.Microtime);
    Channel = vertcat(Channel,MergeData{i}.Channel);
end

Progress(0.6,h.Progress_Axes,h.Progress_Text,'Saving merged file...');

%%% Save merged data
[FileName,PathName] = uiputfile({'*.bur','*.bur file'},'Choose a filename for the merged file',fileparts(Files{1,1}));
if FileName == 0
    m = msgbox('No valid filepath specified... Canceling');
    pause(1);
    delete(m);
    return;
end
BurstData.PathName = PathName;
BurstData.FileName = FileName;

filename = fullfile(BurstData.PathName,BurstData.FileName);
save(filename,'BurstData');
Progress(0.8,h.Progress_Axes,h.Progress_Text,'Saving merged file...');
save([filename(1:end-3) 'bps'],'Macrotime','Microtime','Channel');

Progress(1,h.Progress_Axes,h.Progress_Text);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Update the print path %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Choose_PrintPath_Menu(obj,~)
global UserValues BurstData BurstMeta
h = guidata(obj);
switch obj
    case h.Choose_PrintPath_Menu
        try
            PathName = uigetdir(UserValues.BurstBrowser.PrintPath, 'Choose a folder to place files into');
        catch
            path = pwd;
            PathName = uigetdir(path, 'Choose a folder to place files into');
        end

        if PathName == 0
            return;
        end
        UserValues.BurstBrowser.PrintPath = PathName;
    case h.Autoset_PrintPath_Menu
        switch obj.Checked
            case 'off'
                if ~isempty(BurstData)
                    PathName = BurstData{BurstMeta.SelectedFile}.PathName;
                end
                obj.Checked = 'on';
                UserValues.BurstBrowser.Settings.UseFilePathForExport = 1;
                h.Choose_PrintPath_Menu.Enable = 'off';
                h.Current_PrintPath_Menu.Enable = 'off';
            case 'on'
                obj.Checked = 'off';
                UserValues.BurstBrowser.Settings.UseFilePathForExport = 0;
                PathName = UserValues.BurstBrowser.PrintPath;
                h.Choose_PrintPath_Menu.Enable = 'on';
                h.Current_PrintPath_Menu.Enable = 'on';
        end
end
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Compare exported FRET histograms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Compare_FRET_Hist(obj,~)
global UserValues BurstMeta BurstData
h = guidata(obj);
if obj == h.FRET_comp_File_Menu
    %%% Load *.his files (assume they are in one folder)
    try
        [FileNames,PathName] = uigetfile('*.his','Choose *.his files',getPrintPath(),'Multiselect','on');
    catch
        Choose_PrintPath_Menu([],[]);
        [FileNames,PathName] = uigetfile('*.his','Choose *.his files',getPrintPath(),'Multiselect','on');
    end
    if ~iscell(FileNames)
        return;
    end
    dummy = load(fullfile(PathName,FileNames{1}),'-mat');
    switch numel(fieldnames(dummy))% 2is 2color, 3 is 3color
        case 1
            mode = 2;
        case 3
            mode= 3;
    end

    switch mode
        case 2 
            %%% Load FRET arrays
            for i = 1:numel(FileNames)
                data = load(fullfile(PathName,FileNames{i}),'-mat');
                E{i} = data.E;
            end
        case 3
            %%% Load FRET arrays
        for i = 1:numel(FileNames)
            data = load(fullfile(PathName,FileNames{i}),'-mat');
            EGR{i} = data.EGR;
            EBG{i} = data.EBG;
            EBR{i} = data.EBR;
        end
    end
elseif any(obj == [h.FRET_comp_Loaded_Menu,h.FRET_comp_selected_Menu])
    file = BurstMeta.SelectedFile;
    switch BurstData{file}.BAMethod
        case {1,2,5}
            mode = 2;
        case {3,4}
            mode = 3;
    end
    
    switch obj
        case h.FRET_comp_Loaded_Menu
            sel_file = BurstMeta.SelectedFile;
            for i = 1:numel(BurstData);
                BurstMeta.SelectedFile = i;
                %%% Make sure to apply corrections
                ApplyCorrections(obj,[],h,0);
                %%% read fret values
                file = i;
                SelectedSpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)};
                if BurstData{file}.SelectedSpecies(2) > 1 %%% subspecies selected
                    SelectedSpeciesName = [BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),1} '/' SelectedSpeciesName];
                end
                FileNames{i} = [BurstData{file}.FileName(1:end-4) '/' SelectedSpeciesName '.his'];
                switch mode
                    case 2
                        E{i} = BurstData{file}.DataCut(:,1);
                    case 3
                        EGR{i} = BurstData{file}.DataCut(:,1);
                        EBG{i} = BurstData{file}.DataCut(:,2);
                        EBR{i} = BurstData{file}.DataCut(:,3);
                end
            end
            BurstMeta.SelectedFile = sel_file;
        case h.FRET_comp_selected_Menu
            sel_file = BurstMeta.SelectedFile;
            [files,species,subspecies] = get_multiselection(h);
            for i = 1:numel(files)
                file = files(i);
                BurstMeta.SelectedFile = file;
                %%% Make sure to apply corrections
                ApplyCorrections(obj,[],h,0);
                %%% read fret values
                try
                    SelectedSpeciesName = BurstData{file}.SpeciesNames{species(i),subspecies(i)};
                    if subspecies(i) > 1 %%% subspecies selected
                        SelectedSpeciesName = [BurstData{file}.SpeciesNames{species(i),1} '/' SelectedSpeciesName];
                    end
                    FileNames{i} = [BurstData{file}.FileName(1:end-4) '/' SelectedSpeciesName '.his'];
                catch
                    FileNames{i} = [BurstData{file}.FileName(1:end-4) '.his'];
                end
                [~, Data] = UpdateCuts([species(i),subspecies(i)],file);
                switch mode
                    case 2
                        E{i} = Data(:,1);
                    case 3
                        EGR{i} = Data(:,1);
                        EBG{i} = Data(:,2);
                        EBR{i} = Data(:,3);
                end
            end
            BurstMeta.SelectedFile = sel_file;
    end
elseif  obj == h.Param_comp_Loaded_Menu
    mode = 0;
    param = h.ParameterListX.String{h.ParameterListX.Value};
    sel_file = BurstMeta.SelectedFile;
    P = cell(numel(BurstData),1);
    for i = 1:numel(BurstData);
        BurstMeta.SelectedFile = i;
        %%% Make sure to apply corrections
        ApplyCorrections(obj,[],h,0);
        %%% read parameter values
        file = i;
        try
            SelectedSpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)};
            if BurstData{file}.SelectedSpecies(2) > 1 %%% subspecies selected
                SelectedSpeciesName = [BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),1} '/' SelectedSpeciesName];
            end
            FileNames{i} = [BurstData{file}.FileName(1:end-4) '/' SelectedSpeciesName '.his'];
        catch
            FileNames{i} = [BurstData{file}.FileName(1:end-4) '.his'];
        end
        p = find(strcmp(BurstData{file}.NameArray,param));
        if ~isempty(p)
            P{i} = BurstData{file}.DataCut(:,p);
        end
    end
    BurstMeta.SelectedFile = sel_file;
elseif obj == h.Param_comp_selected_Menu
    [files,species,subspecies] = get_multiselection(h);
    mode = 0;
    param = h.ParameterListX.String{h.ParameterListX.Value};
    sel_file = BurstMeta.SelectedFile;
    P = cell(numel(files),1);
    for i = 1:numel(files)
        file = files(i);
        BurstMeta.SelectedFile = file;
        %%% Make sure to apply corrections
        ApplyCorrections(obj,[],h,0);
        %%% read parmeter values
        try
            SelectedSpeciesName = BurstData{file}.SpeciesNames{species(i),subspecies(i)};
            if subspecies(i) > 1 %%% subspecies selected
                SelectedSpeciesName = [BurstData{file}.SpeciesNames{species(i),1} '/' SelectedSpeciesName];
            end
            FileNames{i} = [BurstData{file}.FileName(1:end-4) '/' SelectedSpeciesName '.his'];
        catch
            FileNames{i} = [BurstData{file}.FileName(1:end-4) '.his'];
        end
        p = find(strcmp(BurstData{file}.NameArray,param));
        if ~isempty(p)
            [~, Data] = UpdateCuts([species(i),subspecies(i)],file);
            P{i} = Data(:,p);
        end
    end
    BurstMeta.SelectedFile = sel_file;
end

N_bins = UserValues.BurstBrowser.Display.NumberOfBinsX;

if numel(FileNames) == 1
    return;
end

switch mode
    case 2 % 2ColorMFD
        xE = linspace(-0.1,1,N_bins+1);
        for i = 1:numel(E)
            H{i} = histcounts(E{i},xE);
            H{i} = H{i}./sum(H{i});
        end
        
        color = lines(numel(H));
        f = figure('Color',[1 1 1],'Position',[100 100 600 400]);
        stairs(xE(1:end),[H{1} H{1}(end)],'Color',color(1,:),'LineWidth',2);
        hold on
        for i = 2:numel(H)
            stairs(xE(1:end),[H{i} H{i}(end)],'Color',color(i,:),'LineWidth',2);
        end
        ax = gca;
        ax.Color = [1 1 1];
        ax.FontSize = 20;
        ax.LineWidth = 2;
        ax.Layer = 'top';
        ax.XLim = [-0.1,1];
        ax.Units = 'pixels';
        xlabel('FRET efficiency');
        ylabel('occurrence (norm.)');
        legend_entries = cellfun(@(x) strrep(x(1:end-4),'_',' '),FileNames,'UniformOutput',false);
        hl = legend(legend_entries,'fontsize',12,'Box','off');
        set([f,ax,hl],'Units','pixel');
        f.Position(4) = f.Position(4)+hl.Position(4);
        hl.Position(1) = 40;
        hl.Position(2) = 390;
        if UserValues.BurstBrowser.Settings.CompareFRETHist_Waterfall
            %%% waterfall or image/contour plot
            %%% constuct time series histogram
            for i = 1:numel(H);
                H{i} = [H{i} H{i}(end)];
                H{i} = smooth(H{i},3); H{i} = H{i}';
            end
            H = vertcat(H{:}); H = H';
            f = figure('Color',[1 1 1],'Position',[700 100 600 400]);
            contourf(1:1:size(H,2),xE(1:end),H);
            colormap(jet);
            ax = gca;
            ax.Color = [1 1 1];
            ax.FontSize = 20;
            ax.LineWidth = 2;
            ax.Layer = 'top';
            ax.YLim = [0,1];
            ax.Units = 'normalized';
            ax.Position(3) = 0.6;
            ax.Units = 'pixels';
            ylabel('FRET efficiency');
            xlabel('File Number');
            text(1.02,ax.YLim(2),legend_entries);
        end
        FigureName = 'Comp_FRETefficiency';
    case 3 
        xE = linspace(-0.1,1,ceil(N_bins*1.1)+1);
        xEBR = linspace(-0.2,1,ceil(N_bins*1.2)+1);
        for i = 1:numel(EGR)
            HGR{i} = histcounts(EGR{i},xE);
            HGR{i} = HGR{i}./sum(HGR{i});
            HBG{i} = histcounts(EBG{i},xE);
            HBG{i} = HBG{i}./sum(HBG{i});
            HBR{i} = histcounts(EBR{i},xEBR);
            HBR{i} = HBR{i}./sum(HBR{i});
        end
        
        color = lines(numel(HGR));
        H_all = {HGR,HBG,HBR};
        xlb = {'FRET efficiency GR','FRET efficiency BG','FRET efficiency BR'};
        for j = 1:3
            if j == 3
                xE = xEBR;
            end
            H = H_all{j};
            f = figure('Color',[1 1 1],'Position',[100+600*(j-1) 100 600 400],'name',xlb{j});
            stairs(xE(1:end),[H{1} H{1}(end)],'Color',color(1,:),'LineWidth',2);
            hold on
            for i = 2:numel(H)
                stairs(xE(1:end),[H{i} H{i}(end)],'Color',color(i,:),'LineWidth',2);
            end
            ax = gca;
            ax.Color = [1 1 1];
            ax.FontSize = 20;
            ax.LineWidth = 2;
            ax.Layer = 'top';
            ax.XLim = [-0.1 1];
            if j == 3
                ax.XLim = [-0.2 1];
            end
            ax.Units = 'pixels';
            xlabel(xlb{j});
            ylabel('occurrence (norm.)');
            legend_entries = cellfun(@(x) strrep(x(1:end-4),'_',' '),FileNames,'UniformOutput',false);
            hl = legend(legend_entries,'fontsize',12,'Box','off');
            set([f,ax,hl],'Units','pixel');
            f.Position(4) = f.Position(4)+hl.Position(4);
            hl.Position(1) = 40;
            hl.Position(2) = 390;
        end
        
        if UserValues.BurstBrowser.Settings.CompareFRETHist_Waterfall
            %%% waterfall or image/contour plot
            %%% constuct time series histogram
            for i = 1:numel(EGR);
                HGR{i} = [HGR{i} HGR{i}(end)]; HGR{i} = smooth(HGR{i},3); HGR{i} = HGR{i}';
                HBG{i} = [HBG{i} HBG{i}(end)]; HBG{i} = smooth(HBG{i},3); HBG{i} = HBG{i}';
                HBR{i} = [HBR{i} HBR{i}(end)]; HBR{i} = smooth(HBR{i},3); HBR{i} = HBR{i}';
            end
            HGR = vertcat(HGR{:});
            HBG = vertcat(HBG{:});
            HBR = vertcat(HBR{:});
            H_all = {HGR,HBG,HBR};
            xE = linspace(-0.1,1,56);
            for j = 1:3
                if j == 3
                    xE = xEBR;
                end
                H = H_all{j}; H = H';
                figure('Color',[1 1 1],'Position',[100+600*(j-1) 500 600 400]);
                contourf(1:1:size(H,2),xE(1:end),H);
                colormap(jet);
                ax = gca;
                ax.Color = [1 1 1];
                ax.FontSize = 20;
                ax.LineWidth = 2;
                ax.Layer = 'top';
                ax.YLim = [0,1];
                ax.Units = 'normalized';
                ax.Position(3) = 0.6;
                ax.Units = 'pixels';
                ylabel(xlb{j});
                xlabel('File Number');
                text(1.02,ax.YLim(2),legend_entries);
            end
        end
    case 0 % no FRET, other parameter
        valid = ~(cellfun(@isempty,P));
        %%% take X hist limits
        xlim = h.axes_1d_x.XLim;
        xP = linspace(xlim(1),xlim(2),N_bins+1);
        for i = 1:numel(P)
            if valid(i)
                H{i} = histcounts(P{i},xP);
                H{i} = H{i}./sum(H{i});
            end
        end
        
        color = lines(numel(H));
        f = figure('Color',[1 1 1],'Position',[100 100 600 400]);
        hold on
        for i = 1:numel(H)
            if valid(i)
                stairs(xP(1:end),[H{i} H{i}(end)],'Color',color(i,:),'LineWidth',2);
            end
        end
        ax = gca;
        ax.Color = [1 1 1];
        ax.FontSize = 20;
        ax.LineWidth = 2;
        ax.Layer = 'top';
        ax.XLim = xlim;
        ax.Units = 'pixels';
        xlabel(param);
        ylabel('occurrence (norm.)');
        legend_entries = cellfun(@(x) strrep(x(1:end-4),'_',' '),FileNames,'UniformOutput',false);
        legend_entries = legend_entries(valid);
        hl = legend(legend_entries,'fontsize',12,'Box','off');
        set([f,ax,hl],'Units','pixel');
        f.Position(4) = f.Position(4)+hl.Position(4);
        hl.Position(1) = 40;
        hl.Position(2) = 390;
        FigureName = ['Comp_' h.ParameterListX.String{h.ParameterListX.Value}];
        FigureName = strrep(FigureName,' ','_');
end
%%% add close request function
if any(mode == [0,2])
    ask_file = 1;
    f.CloseRequestFcn = {@ExportGraph_CloseFunction,ask_file,FigureName};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Update Options in UserValues Structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateOptions(obj,~,h)
global UserValues
if isempty(obj)
    return;
end
if nargin < 3
    h = guidata(obj);
end
switch obj
    case h.SaveOnClose
        UserValues.BurstBrowser.Settings.SaveOnClose = obj.Value;
    case h.Downsample_fFCS_edit
        UserValues.BurstBrowser.Settings.Downsample_fFCS_Time = str2double(h.Downsample_fFCS_edit.String);
    case h.Downsample_fFCS
        UserValues.BurstBrowser.Settings.Downsample_fFCS = obj.Value;
        switch h.Downsample_fFCS.Value
            case 1
                h.Downsample_fFCS_edit.Enable = 'on';
            case 0
                h.Downsample_fFCS_edit.Enable = 'off';
        end
    case h.fFCS_UseIRF
        UserValues.BurstBrowser.Settings.fFCS_UseIRF = obj.Value;
    case h.CorrelateWindow_Edit
        UserValues.BurstBrowser.Settings.Corr_TimeWindowSize = str2double(obj.String);
    case h.fFCS_selectmode_popupmenu
        UserValues.BurstBrowser.Settings.fFCS_Mode = obj.Value;
    case h.SaveFileExportFigure_Checkbox
        UserValues.BurstBrowser.Settings.SaveFileExportFigure = obj.Value;
    case h.fFCS_UseFRET
        UserValues.BurstBrowser.Settings.fFCS_UseFRET = obj.Value;
    case h.Fit_Gaussian_Pick
        UserValues.BurstBrowser.Settings.FitGaussPick = obj.Value;
    case h.ApplyCorrectionsOnLoad
        UserValues.BurstBrowser.Settings.CorrectionOnLoad = obj.Value;
    case h.Fit_GaussianMethod_Popupmenu
        switch obj.Value
            case 1 %%% changed to MLE
                h.Fit_Gaussian_Text.ColumnName = h.GUIData.ColumnNameMLE;
                h.Fit_Gaussian_Text.Data = h.GUIData.TableDataMLE;
                h.Fit_Gaussian_Text.ColumnEditable = h.GUIData.ColumnEditableMLE;
                h.Fit_Gaussian_Text.ColumnWidth = h.GUIData.ColumnWidthMLE;
                h.Fit_Gaussian_Text.ColumnFormat = h.GUIData.ColumnFormatMLE;
                UserValues.BurstBrowser.Settings.GaussianFitMethod = 'MLE';
                h.Fit_GaussianChi2_Text.String = '';
            case 2 %%% changed to LSQ
                h.Fit_Gaussian_Text.ColumnName = h.GUIData.ColumnNameLSQ;
                h.Fit_Gaussian_Text.Data = h.GUIData.TableDataLSQ;
                h.Fit_Gaussian_Text.ColumnEditable = h.GUIData.ColumnEditableLSQ;
                h.Fit_Gaussian_Text.ColumnWidth = h.GUIData.ColumnWidthLSQ;
                h.Fit_Gaussian_Text.ColumnFormat = h.GUIData.ColumnFormatLSQ;
                UserValues.BurstBrowser.Settings.GaussianFitMethod = 'LSQ';
        end
        UpdateOptions(h.Fit_NGaussian_Popupmenu,[]);
    case h.Fit_NGaussian_Popupmenu
        if strcmp(UserValues.BurstBrowser.Settings.GaussianFitMethod,'LSQ')
            %%% change fixed values in table
            nG = obj.Value;
            h.Fit_Gaussian_Text.Data(:,1) = {1/nG,1/nG,1/nG,1/nG,1/nG};
            for i = 1:nG           
                h.Fit_Gaussian_Text.Data(i,4:4:end) = {false,false,false,false,false,false};
            end
            for i = (nG+1):5           
                h.Fit_Gaussian_Text.Data(i,4:4:end) = {true,true,true,true,true,true};
                h.Fit_Gaussian_Text.Data{i,1} = 0;
            end
        end
    case h.IsoLineGaussFit_Edit
        UserValues.BurstBrowser.Settings.IsoLineGaussFit = str2double(obj.String);
    case h.TimeBinPDAEdit
        % store it as a string cause it might not be a number but a range
        UserValues.BurstBrowser.Settings.PDATimeBin = obj.String;
    case h.CompareFRETHist_Waterfall
        UserValues.BurstBrowser.Settings.CompareFRETHist_Waterfall = obj.Value;
    case h.MultiPlot_PlotType
        UserValues.BurstBrowser.Display.MultiPlotMode = obj.Value;
    case h.MultiselectOnCheckbox
        switch obj.UserData
            case 0
                %%% enable multiselect
                h.SpeciesList.Tree.setMultipleSelectionEnabled(true);
                % disable right click
                set(h.SpeciesList.Tree.getTree, 'MousePressedCallback', []);
                %%% enable multiplot button
                h.MultiPlotButton.Visible = 'on';
                %%% Disable buttonsin Species List
                h.AddSpecies_Button.Visible = 'off';
                h.RemoveSpecies_Button.Visible = 'off';
                h.RenameSpecies_Button.Visible = 'off';
                h.Export_To_PDA_Button.Visible = 'off';
                h.Send_to_TauFit_Button.Visible = 'off';
                h.Param_comp_selected_Menu.Enable = 'on';
                h.FRET_comp_selected_Menu.Enable = 'on';
                obj.UserData = 1;
                obj.CData = circshift(obj.CData,[0,0,1]);
            case 1
                %%% disable multiselect
                h.SpeciesList.Tree.setMultipleSelectionEnabled(false);
                % reenable right click
                set(h.SpeciesList.Tree.getTree, 'MousePressedCallback', {@SpeciesListContextMenuCallback,h.SpeciesListMenu});
                %%% disable multiplot button
                h.MultiPlotButton.Visible = 'off';
                %%% Reenable buttonsin Species List
                h.AddSpecies_Button.Visible = 'on';
                h.RemoveSpecies_Button.Visible = 'on';
                h.RenameSpecies_Button.Visible = 'on';
                h.Export_To_PDA_Button.Visible = 'on';
                h.Send_to_TauFit_Button.Visible = 'on';
                h.Param_comp_selected_Menu.Enable = 'off';
                h.FRET_comp_selected_Menu.Enable = 'off';
                obj.UserData = 0;
                obj.CData = circshift(obj.CData,[0,0,-1]);
        end
        UpdatePlot([],[],h);
        UpdateLifetimePlots([],[],h);
        PlotLifetimeInd([],[],h);
    case h.Threshold_S_Donly_Min_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
             h.Threshold_S_Donly_Min_Edit.String = num2str(UserValues.BurstBrowser.Settings.S_Donly_Min);
        else
            UserValues.BurstBrowser.Settings.S_Donly_Min = newVal;
        end
    case h.Threshold_S_Donly_Max_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
             h.Threshold_S_Donly_Max_Edit.String = num2str(UserValues.BurstBrowser.Settings.S_Donly_Max);
        else
            UserValues.BurstBrowser.Settings.S_Donly_Max = newVal;
        end
    case h.Threshold_S_Aonly_Min_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
             h.Threshold_S_Aonly_Min_Edit.String = num2str(UserValues.BurstBrowser.Settings.S_Aonly_Min);
        else
            UserValues.BurstBrowser.Settings.S_Aonly_Min = newVal;
        end
    case h.Threshold_S_Aonly_Max_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
             h.Threshold_S_Aonly_Max_Edit.String = num2str(UserValues.BurstBrowser.Settings.S_Aonly_Max);
        else
            UserValues.BurstBrowser.Settings.S_Aonly_Max = newVal;
        end
    case h.Threshold_E_Aonly_Min_Edit
        newVal = str2double(obj.String);
        if isnan(newVal)
             h.Threshold_E_Aonly_Min_Edit.String = num2str(UserValues.BurstBrowser.Settings.E_Aonly_Min);
        else
            UserValues.BurstBrowser.Settings.E_Aonly_Min = newVal;
        end
    case h.ArbitraryCutInvertCheckbox
        switch h.ArbitraryCutInvertCheckbox.Checked
            case 'off'
                h.ArbitraryCutInvertCheckbox.Checked = 'on';
            case 'on'
                h.ArbitraryCutInvertCheckbox.Checked = 'off';
        end
    case h.MultiPlotButtonMenu_ToggleNormalize
        switch h.MultiPlotButtonMenu_ToggleNormalize.Checked
            case 'off'
                h.MultiPlotButtonMenu_ToggleNormalize.Checked = 'on';
                UserValues.BurstBrowser.Settings.Normalize_Multiplot = true;
            case 'on'
                h.MultiPlotButtonMenu_ToggleNormalize.Checked = 'off';
                UserValues.BurstBrowser.Settings.Normalize_Multiplot = false;
        end
        UpdatePlot([],[],h);
        UpdateLifetimePlots([],[],h);
        PlotLifetimeInd([],[],h);
   case h.MultiPlotButtonMenu_ToggleDisplayTotal
        switch h.MultiPlotButtonMenu_ToggleDisplayTotal.Checked
            case 'off'
                h.MultiPlotButtonMenu_ToggleDisplayTotal.Checked = 'on';
                UserValues.BurstBrowser.Settings.Display_Total_Multiplot = true;
            case 'on'
                h.MultiPlotButtonMenu_ToggleDisplayTotal.Checked = 'off';
                UserValues.BurstBrowser.Settings.Display_Total_Multiplot = false;
        end
        UpdatePlot([],[],h);
        PlotLifetimeInd([],[],h); 
end
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Callback for Parameter List: Left-click updates plot,    %%%%%%%%%%
%%%%%%% Right-click adds parameter to CutList                    %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ParameterList_ButtonDownFcn(jListbox,eventData,hListbox)
global BurstData BurstMeta
if isempty(BurstData)
    return;
end

h = guidata(hListbox);
file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;

if eventData.isMetaDown % right-click is like a Meta-button
    clickType = 'right';
else
    clickType = 'left';
end

% Determine the current listbox index
% Remember: Java index starts at 0, Matlab at 1
mousePos = java.awt.Point(eventData.getX, eventData.getY);
clickedIndex = jListbox.locationToIndex(mousePos) + 1;
if strcmpi(clickType,'right')
    %%% check if master species is selected
    if all(species == [0,0])
        disp('Cuts can not be applied to total data set. Select a species first.');
        return;
    end

    %%%add to cut list if right-clicked
    param = clickedIndex;
    
    %%% Check whether the CutParameter already exists or not
    ExistingCuts = vertcat(BurstData{file}.Cut{species(1),species(2)}{:});
    if ~isempty(ExistingCuts)
        if any(strcmp(BurstData{file}.NameArray{param},ExistingCuts(:,1)))
            return;
        end
    end
    
    %%% use default limits for FRET efficiency and Stoichiometry
    switch BurstData{file}.NameArray{clickedIndex}
        case {'FRET Efficiency','FRET Efficiency GR','FRET Efficiency BG','FRET Efficiency BR'}
            lower = -0.1;
            upper = 1;
        case {'Stoichiometry','Stoichiometry GR','Stoichiometry BG','Stoichiometry BR'}
            lower = 0;
            upper = 1;
        case {'Anisotropy RR','Anisotropy GG','Anisotropy BB','Anisotropy A','Anisotropy D'}
            lower = -0.2;
            upper = 0.6;
        otherwise  
            lower = min(BurstData{file}.DataCut(~isinf(BurstData{file}.DataCut(:,param)),param));
            upper = max(BurstData{file}.DataCut(~isinf(BurstData{file}.DataCut(:,param)),param));
    end
            
    BurstData{file}.Cut{species(1),species(2)}{end+1} = {BurstData{file}.NameArray{param}, lower,upper, true,false};
    
    %%% If Global Cuts, Update all other species
    if species(2) == 1
        ChangedParameterName = BurstData{file}.NameArray{param};
        %%% find number of species for species group
        num_species = sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
        if num_species > 1 %%% Check if there are other species defined
            %%% cycle through the number of other species
            for j = 2:num_species
                %%% Check if the parameter already exists in the species j
                ParamList = vertcat(BurstData{file}.Cut{species(1),j}{:});
                if ~isempty(ParamList)
                    ParamList = ParamList(1:numel(BurstData{file}.Cut{species(1),j}),1);
                    CheckParam = strcmp(ParamList,ChangedParameterName);
                    if any(CheckParam)
                        %%% do nothing
                    else %%% Parameter is new to species
                        BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(end);
                    end
                else %%% Parameter is new to GlobalCut
                    BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(end);
                end
            end
        end
    end
    UpdateCutTable(h);
    UpdateCuts();    
elseif strcmpi(clickType,'left') %%% Update Plot
    %%% Update selected value
    hListbox.Value = clickedIndex;
end
UpdatePlot([],[],h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Mouse-click Callback for Species List       %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Left-click: Change plot to selected Species %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Right-click: Open menu                      %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SpeciesList_ButtonDownFcn(hTree,eventData)
global BurstData BurstMeta UserValues
if isempty(BurstData)
    return;
end
h = guidata(findobj('Tag','BurstBrowser'));

%%% get the clicked node
%clicked = eventData.getCurrentNode;
clicked = hTree.getSelectedNodes;
if isempty(clicked)
    return;
end

if numel(clicked) > 1
    %%% if more than one element was selected -> Multiselection for multiplot
    %%% remove all top level species
    valid = true(numel(clicked),1);
    for i = 1:numel(clicked)
        if clicked(i).getLevel < 2
            valid(i) = false;
        end
    end
    clicked = clicked(valid);
    %%% update the selection to reflect the filtering
    hTree.setSelectedNodes(clicked);
end

clicked = clicked(1);
%%% find out what exact node was clicked on with relation to array of
%%% species names
switch clicked.getLevel
    case 0
        % top level was clicked
        %%% reset selected node according to BurstData{file}.SelectedSpecies
        if all(BurstData{BurstMeta.SelectedFile}.SelectedSpecies == [0,0])
            h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.File(BurstMeta.SelectedFile));
        elseif BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) == 1
            h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(max([1,BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)])));
        elseif BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) > 1
            h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)).getChildAt(BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2)-2));
        end
        return;
    case 1
        % file was clicked
        % which one?
        for i = 1:numel(h.SpeciesList.File)
            file(i) = h.SpeciesList.File(i).equals(clicked);
        end
        file = find(file);
        BurstMeta.SelectedFile = file;
        % default to the stored species selection for this file
        if all(BurstData{BurstMeta.SelectedFile}.SelectedSpecies == [0,0])
            h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.File(BurstMeta.SelectedFile));
        elseif BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) == 1
            h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(max([1,BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)])));
        elseif BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) > 1
            h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)).getChildAt(BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2)-2));
        end
        
        %%% enable/disable gui elements based on type of file
        if BurstData{file}.APBS == 1
            %%% Enable the donor only lifetime checkbox
            h.DonorLifetimeFromDataCheckbox.Enable = 'on';
        else
            h.DonorLifetimeFromDataCheckbox.Enable = 'off';
        end
       
    case 2
        % species group was clicked
        % which file?
        f = clicked.getParent;
        for i = 1:numel(h.SpeciesList.File)
            file(i) = h.SpeciesList.File(i).equals(f);
        end
        file = find(file);
        % which one?
        for i = 1:numel(h.SpeciesList.Species{file})
            species(i) = h.SpeciesList.Species{file}(i).equals(clicked);
        end
        species = find(species);
        
        BurstMeta.SelectedFile = file;
        BurstData{file}.SelectedSpecies = [species,1];
    case 3
        % subspecies was clicked
        % which parent file?
        f = clicked.getParent.getParent;
        for i = 1:numel(h.SpeciesList.File)
            file(i) = h.SpeciesList.File(i).equals(f);
        end
        file = find(file);
        % which parent species?
        parent = clicked.getParent;
        for i = 1:numel(h.SpeciesList.Species{file})
            group(i) = h.SpeciesList.Species{file}(i).equals(parent);
        end
        group = find(group);
        % which subspecies?
        for i = 1:parent.getChildCount
            subspecies(i) = parent.getChildAt(i-1).equals(clicked);
        end
        subspecies = find(subspecies)+1;
        
        BurstMeta.SelectedFile = file;
        BurstData{file}.SelectedSpecies = [group,subspecies];
end
UserValues.File.BurstBrowserPath = BurstData{file}.PathName;

UpdateCorrections([],[],h);
UpdateCutTable(h);
UpdateCuts();
Update_fFCS_GUI([],[],h);
Update_ParameterList([],[],h);

%%% Update Plots
%%% To speed up, find out which tab is visible and only update the respective tab
switch h.Main_Tab.SelectedTab
    case h.Main_Tab_General
        %%% we switched to the general tab
        UpdatePlot([],[],h);
    case h.Main_Tab_Lifetime
        %%% we switched to the lifetime tab
        %%% figure out what subtab is selected
        UpdateLifetimePlots([],[],h);
        switch h.LifetimeTabgroup.SelectedTab
            case h.LifetimeTabAll
            case h.LifetimeTabInd
                PlotLifetimeInd([],[],h);
        end     
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Add Species to List (Right-click menu item)  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AddSpecies(~,~)
global BurstData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));

file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;
% distinguish between top level ('Species') or SpeciesGroup 
% using name --> level = 0,1
if all(species == [0,0])
    return;
elseif species(2) == 1
    level = 1;
elseif species(2) > 1
    level = 2;
end

switch level
    case 1
        % add a species group to top level
        % use default cut template
        switch BurstData{file}.BAMethod
            case {1,2,5}
                %%% FRET efficiency and stoichiometry basic cuts
                Cut = {{'FRET Efficiency',-0.1,1.1,true,false},{'Stoichiometry',-0.1,1.1,true,false}};
            case {3,4}
                %%% 3color, only do FRET GR and Stoichiometry cuts
                Cut = {{'FRET Efficiency GR',-0.1,1.1,true,false},{'Stoichiometry GR',-0.1,1.1,true,false},...
                    {'Stoichiometry BG',-0.1,1.1,true,false},{'Stoichiometry BR',-0.1,1.1,true,false}};
        end
        name = ['Species ' num2str(size(BurstData{file}.SpeciesNames,1)+1)];
        BurstData{file}.SpeciesNames{end+1,1} = name;
        BurstData{file}.Cut{end+1,1} = Cut;
        BurstData{file}.SelectedSpecies = [size(BurstData{file}.SpeciesNames,1),1];
        %%% add two subspecies
        BurstData{file}.SpeciesNames{end,2} = 'Subspecies 1';
        BurstData{file}.SpeciesNames{end,3} = 'Subspecies 2';
        BurstData{file}.Cut{end,2} = Cut; BurstData{file}.Cut{end,3} = Cut;
    case 2
        % add species to species group
        % check if species group exists
        if ~isempty(BurstData{file}.SpeciesNames{species(1),species(2)})
            % find out number of existing species for species group
            num_species= sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
            name = ['Subspecies ' num2str(num_species)];
            BurstData{file}.SpeciesNames{species(1),num_species+1} = name;
            BurstData{file}.Cut{species(1),num_species+1} = BurstData{file}.Cut{species(1),1};
            BurstData{file}.SelectedSpecies(2) = num_species+1;
        end
end
        
UpdateSpeciesList(h);
h = guidata(gcf);drawnow;
UpdateCutTable(h);
UpdateCuts();
Update_fFCS_GUI([],[]);

UpdatePlot([],[],h);
UpdateLifetimePlots([],[],h);
PlotLifetimeInd([],[],h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Remove Selected Species (Right-click menu item)  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RemoveSpecies(obj,eventData)
global BurstData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));

file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;
% distinguish between  SpeciesGroup or Species
% using name --> level = 1,2
if species(2) == 1
    level = 1;
elseif species(2) > 1
    level = 2;
elseif species(2) == 0
    level = 0;
end
switch level
    case 0
        %%% remove file
        BurstData{file} = [];
        for i = file:(numel(BurstData)-1);
            BurstData{i} = BurstData{i+1};
        end
        BurstData(end) = [];
        BurstMeta.SelectedFile = 1;
        UpdatePlot([],[],h);
        UpdateLifetimePlots([],[],h);
    case 1
        %%% remove entire species group
        %%% only remove if there are other groups left afterwards!
        if size(BurstData{file}.SpeciesNames,1) > 1
            BurstData{file}.SpeciesNames(species(1),:) = [];
            BurstData{file}.Cut(species(1),:) = [];
            BurstData{file}.SelectedSpecies(1)=species(1)-1;
        end
    case 2 %%% subspecies
        %%% only remove if there is more than 1 subspecies left
        if sum(cellfun(@(x) ~isempty(x),BurstData{file}.SpeciesNames(species(1),:))) >= 3
            %%% remove only the one field and shift right of it to the left
            BurstData{file}.SpeciesNames{species(1),species(2)} = [];
            temp = BurstData{file}.SpeciesNames(species(1),:);
            temp = temp(~cellfun(@isempty,temp));
            BurstData{file}.SpeciesNames(species(1),:) = [];
            BurstData{file}.SpeciesNames(species(1),1:numel(temp)) = temp;

            BurstData{file}.Cut{species(1),species(2)} = [];
            temp = BurstData{file}.Cut(species(1),:);
            temp = temp(cellfun(@iscell,temp));
            BurstData{file}.Cut(species(1),:) = [];
            BurstData{file}.Cut(species(1),1:numel(temp)) = temp;
        end
end

UpdateSpeciesList(h);
h = guidata(gcf);drawnow;
Update_fFCS_GUI([],[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Remove File belonging to Selected Species (Right-click menu item) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RemoveFile(obj,eventData)
global BurstData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));

file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;

%%% remove file
BurstData{file} = [];
for i = file:(numel(BurstData)-1);
    BurstData{i} = BurstData{i+1};
end
BurstData(end) = [];
BurstMeta.SelectedFile = 1;
UpdatePlot([],[],h);
UpdateLifetimePlots([],[],h);

UpdateSpeciesList(h);
h = guidata(gcf);drawnow;
Update_fFCS_GUI([],[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Rename Selected Species (Right-click menu item)  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RenameSpecies(~,~)
global BurstData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;
SelectedSpeciesName = BurstData{file}.SpeciesNames{species(1),species(2)};
NewName = inputdlg('Specify the new species name','Rename Species',[1 50],{SelectedSpeciesName},'on');

if ~isempty(NewName)
    BurstData{file}.SpeciesNames{species(1),species(2)} = NewName{1};
    UpdateSpeciesList(h);
end
Update_fFCS_GUI([],[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export Photons for PDA analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export_To_PDA(obj,~)
global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
if obj == h.Export_PDA_All_Menu
    files = 1:numel(BurstData);
elseif obj == h.Export_PDA_Sel_Menu
    [files,species,subspecies] = get_multiselection(h);
else
    files = BurstMeta.SelectedFile;
end

k = 0;
sel_file =  BurstMeta.SelectedFile;
for i = 1:numel(files)
    file = files(i);
    BurstMeta.SelectedFile = file;
    if obj == h.Export_PDA_Sel_Menu
        sel_species = BurstData{file}.SelectedSpecies;
        BurstData{file}.SelectedSpecies = [species(i),subspecies(i)];        
    end
    UpdateCuts();
    Progress(k/numel(files),h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
    %%% Load associated .bps file, containing Macrotime, Microtime and Channel
    if isempty(BurstTCSPCData{file})
        Load_Photons();
    end
    Progress(k/numel(files),h.Progress_Axes,h.Progress_Text,'Exporting...');
    
    SelectedSpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)};
    SelectedSpeciesName = strrep(strrep(SelectedSpeciesName,'/','-'),':','');
    %% Export FRET Species
    %%% find selected bursts
    MT = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
    CH = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);
    
    % Timebin can be a single number or a range e.g. "0.2,0.5,1", without the " "
    Timebin = str2num(h.TimeBinPDAEdit.String).*1E-3;
    
    for i = 1:numel(Timebin)
        timebin = Timebin(i);
        duration = timebin./BurstData{file}.ClockPeriod;
        
        PDAdata = Bursts_to_Timebins(MT,CH,duration);
        
        Progress(k/numel(files),h.Progress_Axes,h.Progress_Text,'Exporting...');
        
        %%% Save Brightness Reference?
        save_brightness_reference = 1;
        %now save channel wise photon numbers
        total = numel(PDAdata);
        filename = fullfile(BurstData{file}.PathName,BurstData{file}.FileName);
        
        newfilename = GenerateName([filename(1:end-4) '_' SelectedSpeciesName '_' num2str(timebin*1000) 'ms.pda'], 1);
        switch BurstData{file}.BAMethod
            case {1,2}
                PDA.NGP = zeros(total,1);
                PDA.NGS = zeros(total,1);
                PDA.NFP = zeros(total,1);
                PDA.NFS = zeros(total,1);
                PDA.NRP = zeros(total,1);
                PDA.NRS = zeros(total,1);
                
                PDA.NG = zeros(total,1);
                PDA.NF = zeros(total,1);
                PDA.NR = zeros(total,1);
                
                PDA.NGP = cellfun(@(x) sum((x==1)),PDAdata);
                PDA.NGS = cellfun(@(x) sum((x==2)),PDAdata);
                PDA.NFP = cellfun(@(x) sum((x==3)),PDAdata);
                PDA.NFS = cellfun(@(x) sum((x==4)),PDAdata);
                PDA.NRP = cellfun(@(x) sum((x==5)),PDAdata);
                PDA.NRS = cellfun(@(x) sum((x==6)),PDAdata);
                
                PDA.NG = PDA.NGP + PDA.NGS;
                PDA.NF = PDA.NFP + PDA.NFS;
                PDA.NR = PDA.NRP + PDA.NRS;
                
                PDA.Corrections = BurstData{file}.Corrections;
                PDA.Background = BurstData{file}.Background;
                if save_brightness_reference
                    posS = (strcmp(BurstData{file}.NameArray,'Stoichiometry'));
                    donly = (BurstData{file}.DataArray(:,posS) > 0.95);
                    DOnly_PDA = Bursts_to_Timebins(BurstTCSPCData{file}.Macrotime(donly),BurstTCSPCData{file}.Channel(donly),duration);
                    NGP = cellfun(@(x) sum((x==1)),DOnly_PDA);
                    NGS = cellfun(@(x) sum((x==2)),DOnly_PDA);
                    PDA.BrightnessReference.N = NGP + NGS;
                end
                save(newfilename, 'PDA', 'timebin')
            case 5 %noMFD
                PDA.NG = zeros(total,1);
                PDA.NF = zeros(total,1);
                PDA.NR = zeros(total,1);
                
                PDA.NG = cellfun(@(x) sum((x==1)),PDAdata);
                PDA.NF = cellfun(@(x) sum((x==2)),PDAdata);
                PDA.NR = cellfun(@(x) sum((x==3)),PDAdata);
                
                PDA.Corrections = BurstData{file}.Corrections;
                PDA.Background = BurstData{file}.Background;
                for i = fieldnames(PDA.Background)'
                    PDA.Background.(i{1}) = PDA.Background.(i{1})/2;
                end
                if save_brightness_reference
                    posS = (strcmp(BurstData{file}.NameArray,'Stoichiometry'));
                    donly = (BurstData{file}.DataArray(:,posS) > 0.95);
                    DOnly_PDA = Bursts_to_Timebins(BurstTCSPCData{file}.Macrotime(donly),BurstTCSPCData{file}.Channel(donly),duration);
                    NG = cellfun(@(x) sum((x==1)),DOnly_PDA);
                    PDA.BrightnessReference.N = NG;
                end
                save(newfilename, 'PDA', 'timebin')
            case {3,4}
                %%% ask user for either 3CPDA or two color subpopulation
                [choice, ok] = listdlg('PromptString','Select Export Mode:',...
                    'SelectionMode','single',...
                    'ListString',{'3CPDA','GR','BG','BR'});
                if ~ok
                    return;
                end
                switch choice
                    case 1
                        NBBP = cellfun(@(x) sum((x==1)),PDAdata);
                        NBBS = cellfun(@(x) sum((x==2)),PDAdata);
                        NBGP = cellfun(@(x) sum((x==3)),PDAdata);
                        NBGS = cellfun(@(x) sum((x==4)),PDAdata);
                        NBRP = cellfun(@(x) sum((x==5)),PDAdata);
                        NBRS = cellfun(@(x) sum((x==6)),PDAdata);
                        NGGP = cellfun(@(x) sum((x==7)),PDAdata);
                        NGGS = cellfun(@(x) sum((x==8)),PDAdata);
                        NGRP = cellfun(@(x) sum((x==9)),PDAdata);
                        NGRS = cellfun(@(x) sum((x==10)),PDAdata);
                        NRRP = cellfun(@(x) sum((x==11)),PDAdata);
                        NRRS = cellfun(@(x) sum((x==12)),PDAdata);
                        
                        tcPDAstruct.NBB = NBBP + NBBS;
                        tcPDAstruct.NBG = NBGP + NBGS;
                        tcPDAstruct.NBR = NBRP + NBRS;
                        tcPDAstruct.NGG = NGGP + NGGS;
                        tcPDAstruct.NGR = NGRP + NGRS;
                        tcPDAstruct.NRR = NRRP + NRRS;
                        tcPDAstruct.duration = ones(numel(NBBP),1)*timebin*1000;
                        tcPDAstruct.timebin = timebin*1000;
                        tcPDAstruct.background = BurstData{file}.Background;
                        tcPDAstruct.corrections = BurstData{file}.Corrections;
                        
                        if save_brightness_reference
                            posSGR = (strcmp(BurstData{file}.NameArray,'Stoichiometry GR'));
                            posSBG = (strcmp(BurstData{file}.NameArray,'Stoichiometry BG'));
                            posSBR = (strcmp(BurstData{file}.NameArray,'Stoichiometry BR'));
                            gonly = (BurstData{file}.DataArray(:,posSGR) > 0.95) & (BurstData{file}.DataArray(:,posSBG) < 0.05);
                            GOnly_PDA = Bursts_to_Timebins(BurstTCSPCData{file}.Macrotime(gonly),BurstTCSPCData{file}.Channel(gonly),duration);
                            NGP = cellfun(@(x) sum((x==7)),GOnly_PDA);
                            NGS = cellfun(@(x) sum((x==8)),GOnly_PDA);
                            tcPDAstruct.BrightnessReference.NG = NGP + NGS;
                            bonly = (BurstData{file}.DataArray(:,posSBR) > 0.95) & (BurstData{file}.DataArray(:,posSBG) > 0.95);
                            BOnly_PDA = Bursts_to_Timebins(BurstTCSPCData{file}.Macrotime(bonly),BurstTCSPCData{file}.Channel(bonly),duration);
                            NBP = cellfun(@(x) sum((x==1)),BOnly_PDA);
                            NBS = cellfun(@(x) sum((x==2)),BOnly_PDA);
                            tcPDAstruct.BrightnessReference.NB = NBP + NBS;
                        end
                        filename = fullfile(BurstData{file}.PathName,BurstData{file}.FileName);
                        newfilename = [filename(1:end-4) '_' SelectedSpeciesName '_' num2str(timebin*1000) 'ms.tcpda'];
                        save(newfilename, 'tcPDAstruct', 'timebin')
                    case {2,3,4}
                        PDA.NGP = zeros(total,1);
                        PDA.NGS = zeros(total,1);
                        PDA.NFP = zeros(total,1);
                        PDA.NFS = zeros(total,1);
                        PDA.NRP = zeros(total,1);
                        PDA.NRS = zeros(total,1);
                        
                        PDA.NG = zeros(total,1);
                        PDA.NF = zeros(total,1);
                        PDA.NR = zeros(total,1);
                        
                        %chan gives the photon counts in format
                        %[Donor_par/perp,FRET_par/perp,Acc_par/perp]
                        switch choice
                            case 2
                                chan = [7,8,9,10,11,12];
                                newfilename = [newfilename(1:end-4) '_GR.pda'];
                            case 3
                                chan = [1, 2, 3, 4, 7, 8];
                                newfilename = [newfilename(1:end-4) '_BG.pda'];
                            case 4
                                chan = [1, 2, 5, 6, 11, 12];
                                newfilename = [newfilename(1:end-4) '_BR.pda'];
                        end
                        
                        PDA.NGP = cellfun(@(x) sum((x==chan(1))),PDAdata);
                        PDA.NGS = cellfun(@(x) sum((x==chan(2))),PDAdata);
                        PDA.NFP = cellfun(@(x) sum((x==chan(3))),PDAdata);
                        PDA.NFS = cellfun(@(x) sum((x==chan(4))),PDAdata);
                        PDA.NRP = cellfun(@(x) sum((x==chan(5))),PDAdata);
                        PDA.NRS = cellfun(@(x) sum((x==chan(6))),PDAdata);
                        
                        %PDA.NGP = cellfun(@(x) sum((x==7)),PDAdata);
                        %PDA.NGS = cellfun(@(x) sum((x==8)),PDAdata);
                        %PDA.NFP = cellfun(@(x) sum((x==9)),PDAdata);
                        %PDA.NFS = cellfun(@(x) sum((x==10)),PDAdata);
                        %PDA.NRP = cellfun(@(x) sum((x==11)),PDAdata);
                        %PDA.NRS = cellfun(@(x) sum((x==12)),PDAdata);
                        
                        PDA.NG = PDA.NGP + PDA.NGS;
                        PDA.NF = PDA.NFP + PDA.NFS;
                        PDA.NR = PDA.NRP + PDA.NRS;
                        
                        PDA.Corrections = BurstData{file}.Corrections;
                        PDA.Background = BurstData{file}.Background;
                        %%% change corrections with values for selected species
                        switch choice
                            case 2
                                %%% keep as is
                            case 3
                                PDA.Corrections.Gamma_GR = PDA.Corrections.Gamma_BG;
                                PDA.Corrections.CrossTalk_GR = PDA.Corrections.CrossTalk_BG;
                                PDA.Corrections.FoersterRadius = PDA.Corrections.FoersterRadiusBG;
                                PDA.Background.Background_GGpar = PDA.Background.Background_BBpar;
                                PDA.Background.Background_GGperp = PDA.Background.Background_BBperp;
                                PDA.Background.Background_GRpar = PDA.Background.Background_BGpar;
                                PDA.Background.Background_GRperp = PDA.Background.Background_BGperp;
                                PDA.Background.Background_RRpar = PDA.Background.Background_GGpar;
                                PDA.Background.Background_RRperp = PDA.Background.Background_GGperp;
                            case 4
                                PDA.Corrections.Gamma_GR = PDA.Corrections.Gamma_BR;
                                PDA.Corrections.CrossTalk_GR = PDA.Corrections.CrossTalk_BR;
                                PDA.Corrections.FoersterRadius = PDA.Corrections.FoersterRadiusBR;
                                PDA.Background.Background_GGpar = PDA.Background.Background_BBpar;
                                PDA.Background.Background_GGperp = PDA.Background.Background_BBperp;
                                PDA.Background.Background_GRpar = PDA.Background.Background_BRpar;
                                PDA.Background.Background_GRperp = PDA.Background.Background_BRperp;
                        end
                        if save_brightness_reference
                            posSGR = (strcmp(BurstData{file}.NameArray,'Stoichiometry GR'));
                            posSBG = (strcmp(BurstData{file}.NameArray,'Stoichiometry BG'));
                            donly = (BurstData{file}.DataArray(:,posSGR) > 0.95) & (BurstData{file}.DataArray(:,posSBG) < 0.05);
                            DOnly_PDA = Bursts_to_Timebins(BurstTCSPCData{file}.Macrotime(donly),BurstTCSPCData{file}.Channel(donly),duration);
                            NGP = cellfun(@(x) sum((x==7)),DOnly_PDA);
                            NGS = cellfun(@(x) sum((x==8)),DOnly_PDA);
                            PDA.BrightnessReference.N = NGP + NGS;
                        end
                        save(newfilename, 'PDA', 'timebin')
                end
        end
    end
    k = k+1;
    
    if obj == h.Export_PDA_Sel_Menu
        BurstData{file}.SelectedSpecies = sel_species;
    end
end
BurstMeta.SelectedFile = sel_file;
Progress(1,h.Progress_Axes,h.Progress_Text);
%%% Set tcPDA Path to BurstBrowser Path
UserValues.tcPDA.PathName = UserValues.File.BurstBrowserPath;
UserValues.File.PDAPath = UserValues.File.BurstBrowserPath;
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Slice Bursts in time bins for  PDA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PDAdata = Bursts_to_Timebins(MT,CH,duration)
%%% Get the maximum number of bins possible in data set
max_duration = double(ceil(max(cellfun(@(x) x(end)-x(1),MT))./duration));

%convert absolute macrotimes to relative macrotimes
bursts = cellfun(@(x) x-x(1)+1,MT,'UniformOutput',false);
bursts = cellfun(@double,bursts,'UniformOutput',false);
%bin the bursts according to dur, up to max_duration
bins = cellfun(@(x) histc(x,duration.*[0:1:max_duration]),bursts,'UniformOutput',false);

%remove last bin
last_bin = cellfun(@(x) find(x,1,'last'),bins,'UniformOutput',false);
for i = 1:numel(bins)
    bins{i}(last_bin{i}) = 0;
    %remove zero bins
    bins{i}(bins{i} == 0) = [];
end

%total number of bins is:
n_bins = sum(cellfun(@numel,bins));

%construct cumsum of bins
cumsum_bins = cellfun(@(x) [0; cumsum(x)],bins,'UniformOutput',false);

%get channel information --> This is the only relavant information for PDA!
PDAdata = cell(n_bins,1);
index = 1;
for i = 1:numel(CH)
    for j = 2:numel(cumsum_bins{i})
        PDAdata{index,1} = CH{i}(cumsum_bins{i}(j-1)+1:cumsum_bins{i}(j));
        index = index + 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export Microtime Pattern for fFCS analysis %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export_Microtime_Pattern(~,~)
global BurstData BurstTCSPCData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));

file = BurstMeta.SelectedFile;
Progress(0,h.Progress_Axes,h.Progress_Text,'Exporting...');
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Exporting...');
%%% find selected bursts
MI = BurstTCSPCData{file}.Microtime(BurstData{file}.Selected);
CH = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);

MI = vertcat(MI{:});
CH = vertcat(CH{:});

% read number of channels and compute microtime histograms
NChan = numel(unique(CH));
hMI = cell(NChan,1);
for i = 1:NChan %%% 6 Channels (GG1,GG2,GR1,GR2,RR1,RR2)
    hMI{i} = histc(MI(CH == i),0:(BurstData{file}.FileInfo.MI_Bins-1));
end

Progress(0.5,h.Progress_Axes,h.Progress_Text,'Exporting...');

% assign donor/fret/acceptor channels back to routing/detector
MIPattern = cell(0);
for i = 1:numel(hMI)
    MIPattern{BurstData{file}.PIE.Detector(i),BurstData{file}.PIE.Router(i)} = hMI{i};
end

% save
SpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)};
SpeciesName = strrep(SpeciesName,' ','_');
SpeciesName = strrep(strrep(SpeciesName,'/','-'),':','');
Path = BurstData{file}.PathName;
FileName = [BurstData{file}.FileName(1:end-4) '_' SpeciesName];
[File, Path] = uiputfile('*.mi', 'Save Microtime Pattern', fullfile(Path,FileName));
if all(File==0)
    return
end
save(fullfile(Path,File),'MIPattern');

Progress(1,h.Progress_Axes,h.Progress_Text);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Plot in the Main Axis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdatePlot(obj,~,h)
%% Preparation
global BurstData UserValues BurstMeta
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end

%%% If a display option was changed, update the UserValues!
UpdateGUIOptions(obj,[],h);

if isempty(BurstData)
    return;
end
if ~verLessThan('matlab','8.5')
    drawnow nocallbacks
end
%% Update Main Plot
x = get(h.ParameterListX,'Value');
y = get(h.ParameterListY,'Value');
x_name = h.ParameterListX.String{x};
y_name = h.ParameterListY.String{y};
%%% Read out the Number of Bins
nbinsX = UserValues.BurstBrowser.Display.NumberOfBinsX;
nbinsY = UserValues.BurstBrowser.Display.NumberOfBinsY;

%%% Update ColorMap
if ischar(UserValues.BurstBrowser.Display.ColorMap)
    eval(['colormap(h.BurstBrowser,' UserValues.BurstBrowser.Display.ColorMap ')']);
else
    colormap(h.BurstBrowser,UserValues.BurstBrowser.Display.ColorMap);
end
if UserValues.BurstBrowser.Display.ColorMapInvert
    colormap(flipud(colormap));
end
h.colorbar.Visible = 'on';
%%% Disable/Enable respective plots
switch UserValues.BurstBrowser.Display.PlotType
    case 'Image'
        BurstMeta.Plots.Main_Plot(1).Visible = 'on';
    case 'Contour'
        BurstMeta.Plots.Main_Plot(2).Visible = 'on';
    case 'Scatter'
        BurstMeta.Plots.Main_Plot(3).Visible = 'on';
end
set(BurstMeta.Plots.Main_histX,'Visible','on');
set(BurstMeta.Plots.Main_histY,'Visible','on');
BurstMeta.Plots.Multi.Main_Plot_multiple.Visible = 'off';
set(BurstMeta.Plots.Multi.Multi_histX,'Visible','off');
set(BurstMeta.Plots.Multi.Multi_histY,'Visible','off');

for i = 1:numel(BurstMeta.Plots.MultiScatter.h1dx)
    try;delete(BurstMeta.Plots.MultiScatter.h1dx(i));end;
    try;delete(BurstMeta.Plots.MultiScatter.h1dy(i));end;
end
BurstMeta.Plots.MultiScatter.h1dx = [];
BurstMeta.Plots.MultiScatter.h1dy = [];
%%% additionally, delete all left-over stair plots (those are multi-species
%%% plots, which sometimes are not deleted by the above code...)
delete(h.axes_1d_x.Children(1:end-12));
delete(h.axes_1d_y.Children(1:end-12));

legend(h.axes_1d_x,'off');
%%% only hide fit plots if selection of parameter or species has changed,
%%% or if we switched on KDE
obj = gcbo;
if any(obj == [h.SmoothKDE,h.NumberOfBinsXEdit,h.NumberOfBinsYEdit])
    set(BurstMeta.Plots.Mixture.Main_Plot,'Visible','off');
    set(BurstMeta.Plots.Mixture.plotX,'Visible','off');
    set(BurstMeta.Plots.Mixture.plotY,'Visible','off');
elseif obj == h.SpeciesList.Tree
    set(BurstMeta.Plots.Mixture.Main_Plot,'Visible','off');
    set(BurstMeta.Plots.Mixture.plotX,'Visible','off');
    set(BurstMeta.Plots.Mixture.plotY,'Visible','off');
else
    try %%% try for java handle with property name
        if any(strcmp(obj.Name,{'ParameterListX','ParameterListY'}))
            set(BurstMeta.Plots.Mixture.Main_Plot,'Visible','off');
            set(BurstMeta.Plots.Mixture.plotX,'Visible','off');
            set(BurstMeta.Plots.Mixture.plotY,'Visible','off');
        end
    end
end

file = BurstMeta.SelectedFile;
datatoplot = BurstData{file}.DataCut;
species = BurstData{file}.SelectedSpecies;
NameArray = BurstData{file}.NameArray;
%%% logarithmic plot option
if UserValues.BurstBrowser.Display.logX
    val = datatoplot(:,x) > 0; % avoid complex numbers
    datatoplot(val,x) = log10(datatoplot(val,x));
    datatoplot(~val,x) = NaN;
end
if UserValues.BurstBrowser.Display.logY
    val = datatoplot(:,y) > 0; % avoid complex numbers
    datatoplot(val,y) = log10(datatoplot(val,y));
    datatoplot(~val,y) = NaN;
end
%% histogram generation and plotting
%%% set limits
xlimits = [min(datatoplot(isfinite(datatoplot(:,x)),x)) max(datatoplot(isfinite(datatoplot(:,x)),x))];
ylimits = [min(datatoplot(isfinite(datatoplot(:,y)),y)) max(datatoplot(isfinite(datatoplot(:,y)),y))];
%%% find cuts to parameters to be plotted and change limits if needed
if all(species == [0,0])
    CutState= {};
else
    Cut = BurstData{file}.Cut{species(1),species(2)};
    CutState = vertcat(Cut{:});
end
if size(CutState,2) > 0
    CutParameters = CutState(:,1);
    if any(strcmp(NameArray{x},CutParameters))
        if CutState{strcmp(NameArray{x},CutParameters),4} == 1 %%% Check if active
            %%% Set x-axis limits according to cut boundaries of selected parameter
            xlimits = [CutState{strcmp(NameArray{x},CutParameters),2},...
                CutState{strcmp(NameArray{x},CutParameters),3}];
            if UserValues.BurstBrowser.Display.logX
                xlimits(xlimits <= 0) = 1e-2;
                xlimits = log10(xlimits);
            end
        else
            %%% set to min max
            xlimits = [min(datatoplot(isfinite(datatoplot(:,x)),x)), max(datatoplot(isfinite(datatoplot(:,x)),x))];
        end
    else
        %%% set to min max
        xlimits = [min(datatoplot(isfinite(datatoplot(:,x)),x)), max(datatoplot(isfinite(datatoplot(:,x)),x))];
    end

    if any(strcmp(NameArray{y},CutParameters))
        if CutState{strcmp(NameArray{y},CutParameters),4} == 1 %%% Check if active
            %%% Set x-axis limits according to cut boundaries of selected parameter
            ylimits = [CutState{strcmp(NameArray{y},CutParameters),2},...
                CutState{strcmp(NameArray{y},CutParameters),3}];
            if UserValues.BurstBrowser.Display.logY
                ylimits(ylimits <= 0) = 1e-2;
                ylimits = log10(ylimits);
            end
        else
            %%% set to min max
            ylimits = [min(datatoplot(isfinite(datatoplot(:,y)),y)), max(datatoplot(isfinite(datatoplot(:,y)),y))];
        end
    else
        %%% set to min max
        ylimits = [min(datatoplot(isfinite(datatoplot(:,y)),y)), max(datatoplot(isfinite(datatoplot(:,y)),y))];
    end
    if isempty(xlimits)
        %selection is empty
        xlimits = [0,1];
    end
    if isempty(ylimits)
        %selection is empty
        ylimits = [0,1];
    end
    if sum(xlimits == [0,0]) == 2
        xlimits = [0 1];
    end
    if sum(ylimits == [0,0]) == 2
        ylimits = [0 1];
    end
    if UserValues.BurstBrowser.Display.Restrict_EandS_Range
        %%% hard-code limits of [-0.1,1.1] for any Stoichiometry or FRET
        %%% efficiency parameter if the cut limits fall within that range
        if ~isempty(strfind(NameArray{x},'Stoichiometry')) || ~isempty(strfind(NameArray{x},'Efficiency'))
            xlimits = [min(xlimits(1),-0.1) max(xlimits(2),1.1)];
            if UserValues.BurstBrowser.Display.logX
                if xlimits(1) <= 0
                    xlimits(1) = 1E-2;
                end
                xlimits = log10(xlimits);
            end
        end
        if ~isempty(strfind(NameArray{y},'Stoichiometry')) || ~isempty(strfind(NameArray{y},'Efficiency'))
            ylimits = [min(ylimits(1),-0.1) max(ylimits(2),1.1)];
            if UserValues.BurstBrowser.Display.logY
                if ylimits(1) <= 0
                    ylimits(1) = 1E-2;
                end
                ylimits = log10(ylimits);
            end
        end
    end
end

%%% check what plot type to use
advanced = any(cell2mat(h.CutTable.Data(:,6))) && ~(h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1) && ~h.SmoothKDE.Value;
if ~advanced
    if ~h.MultiselectOnCheckbox.UserData
        [H, xbins,ybins,~,~,bin] = calc2dhist(datatoplot(:,x),datatoplot(:,y),[nbinsX nbinsY],xlimits,ylimits);
    else
        %%% call MultiPlot for superposition of all histograms
        [H,xbins,ybins,xlimits,ylimits,datapoints,n_per_species] = MultiPlot([],[],h);
    end
    if(get(h.Hist_log10, 'Value'))
        HH = log10(H);
        if UserValues.BurstBrowser.Display.KDE
            HH = real(HH);
        end
    else
        HH = H;
    end
    %%% Update Image Plot and Contour Plot
    BurstMeta.Plots.Main_Plot(1).XData = xbins;
    BurstMeta.Plots.Main_Plot(1).YData = ybins;
    BurstMeta.Plots.Main_Plot(1).CData = HH;
    if ~UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.Main_Plot(1).AlphaData = HH./max(max(HH)) > UserValues.BurstBrowser.Display.ImageOffset/100;
    elseif UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.Main_Plot(1).AlphaData = HH./max(max(HH)) > UserValues.BurstBrowser.Display.ImageOffset/100;%(HH./max(max(HH)) > 0.01);
    end
    BurstMeta.Plots.Main_Plot(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
    BurstMeta.Plots.Main_Plot(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
    HHcontour =zeros(size(HH)+2); HHcontour(2:end-1,2:end-1) = HH; 
    % replicate to fix edges
    HHcontour(2:end-1,1) = HH(:,1);HHcontour(2:end-1,end) = HH(:,end);HHcontour(1,2:end-1) = HH(1,:);HHcontour(end,2:end-1) = HH(end,:);
    HHcontour(1,1) = HH(1,1);HHcontour(end,1) = HH(end,1);HHcontour(1,end) = HH(1,end);HHcontour(end,end) = HH(end,end);
    BurstMeta.Plots.Main_Plot(2).ZData = HHcontour;
    BurstMeta.Plots.Main_Plot(2).LevelList = max(HH(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    h.axes_general.CLimMode = 'auto';h.axes_general.CLim(1) = 0;
    %%% Disable ZScale Axis
    h.axes_ZScale.Visible = 'off';
    set(BurstMeta.Plots.ZScale_hist,'Visible','off');
    %%% Update Colorbar
    h.colorbar.Label.String = 'Occurrence';
    h.colorbar.Ticks = [];
    h.colorbar.TickLabels = [];
    h.colorbar.TickLabelsMode = 'auto';
    pause(0.1)
    h.colorbar.TicksMode = 'auto';
    %%% update hex plot if selected
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
        delete(BurstMeta.HexPlot.MainPlot_hex);
        %%% hide all other plots
        set(BurstMeta.Plots.Main_Plot,'Visible','off');
        %%% we need to choose one binning, choose x binning
        nbins = nbinsX;
        UserValues.BurstBrowser.Display.NumberOfBinsX = nbins;
        UserValues.BurstBrowser.Display.NumberOfBinsY = nbins;
        h.NumberOfBinsXEdit.String = num2str(nbins);
        h.NumberOfBinsYEdit.String = num2str(nbins);
        %%% get data
        if ~h.MultiselectOnCheckbox.UserData
            datapoints = [datatoplot(:,x),datatoplot(:,y)];
        end
        %%% make hexplot
        axes(h.axes_general);
        BurstMeta.HexPlot.MainPlot_hex = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',xlimits,'ylim',ylimits,'res',nbins);
        set(BurstMeta.HexPlot.MainPlot_hex,'UIContextMenu',h.ExportGraph_Menu);
    end
    if  h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1 %%% multiple species selected, plot individual hists
        normalize = UserValues.BurstBrowser.Settings.Normalize_Multiplot && ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex') && ~(gcbo == h.Fit_Gaussian_Button);
        %%% prepare 1d hists
        binsx = linspace(xlimits(1),xlimits(2),nbinsX+1);
        binsy = linspace(ylimits(1),ylimits(2),nbinsY+1);
        n_per_species_cum = cumsum([1,(n_per_species-1)]);
        for i = 1:numel(n_per_species_cum)-1
            hx{i} = histcounts(datapoints(n_per_species_cum(i):n_per_species_cum(i+1),1),binsx);
            hy{i} = histcounts(datapoints(n_per_species_cum(i):n_per_species_cum(i+1),2),binsy); 
            if normalize %obj ~= h.Fit_Gaussian_Button
                hx{i} = hx{i}./sum(hx{i});
                hy{i} = hy{i}./sum(hy{i});
            end
        end
        color = lines(numel(n_per_species));
        for i = 1:numel(hx)
            BurstMeta.Plots.MultiScatter.h1dx(i) = handle(stairs(binsx,[hx{i},hx{i}(end)],'Color',color(i,:),'LineWidth',2,'Parent',h.axes_1d_x));
            BurstMeta.Plots.MultiScatter.h1dy(i) = handle(stairs(binsy,[hy{i},hy{i}(end)],'Color',color(i,:),'LineWidth',2,'Parent',h.axes_1d_y));
        end
        if UserValues.BurstBrowser.Settings.Display_Total_Multiplot
            hx_total = sum(vertcat(hx{:}),1);hy_total = sum(vertcat(hy{:}),1);
            BurstMeta.Plots.MultiScatter.h1dx(end+1) = handle(stairs(binsx,[hx_total,hx_total(end)],'Color',[0,0,0],'LineWidth',2,'Parent',h.axes_1d_x));
            BurstMeta.Plots.MultiScatter.h1dy(end+1) = handle(stairs(binsy,[hy_total,hy_total(end)],'Color',[0,0,0],'LineWidth',2,'Parent',h.axes_1d_y));
        end
        %%% hide normal 1d plots
        set(BurstMeta.Plots.Main_histX,'Visible','off');
        set(BurstMeta.Plots.Main_histY,'Visible','off');
        %%% add legend
        [file_n,species_n,subspecies_n,sel] = get_multiselection(h);
        num_species = numel(file_n);
        str = cell(num_species,1);
        for i = 1:num_species
            %%% extract name
            name = BurstData{file_n(i)}.FileName;
            if (species_n(i) ~= 0)
                if (subspecies_n(i) ~= 1) %%% we have a subspecies selected
                    name = [name,'/', char(sel(i).getParent.getName),'/',char(sel(i).getName)];
                else %%% we have a species selected 
                    name = [name,'/', char(sel(i).getName)];
                end
            end
            str{i} = strrep(name,'_',' ');  
        end
        if UserValues.BurstBrowser.Settings.Display_Total_Multiplot
            legend(h.axes_1d_x.Children(num_species+1:-1:2),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
        else
            legend(h.axes_1d_x.Children(num_species:-1:1),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
        end
    end
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter') %%% update scatter plots
        if  h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1 %%% multiple species selected, color automatically
            color = [];
            for i = 1:numel(n_per_species)
                color = [color; i*ones(n_per_species(i),1)];
            end
            colors = lines(numel(n_per_species));
            colordata = colors(color,:);
            %%% permute data points randomly to avoid hiding populations below another
            perm = randperm(size(colordata,1));
            colordata = colordata(perm,:);
            datapoints = datapoints(perm,:);
        else
            datapoints = [datatoplot(:,x),datatoplot(:,y)];
            colordata = UserValues.BurstBrowser.Display.MarkerColor;
        end
        BurstMeta.Plots.Main_Plot(3).XData = datapoints(:,1);
        BurstMeta.Plots.Main_Plot(3).YData = datapoints(:,2);
        BurstMeta.Plots.Main_Plot(3).CData = colordata;
        h.colorbar.Visible = 'off';
    end
else
    % histogram X vs Y parameter
    [H, xbins,ybins,~,~,bin] = calc2dhist(datatoplot(:,x),datatoplot(:,y),[nbinsX nbinsY],xlimits,ylimits);
    % create Mask of size H
    Mask = zeros(size(H,1),size(H,2));
    counter = zeros(size(H,1),size(H,2));
    % which parameter in the list defines the Mask
    param = h.CutTable.Data{cell2mat(h.CutTable.Data(:,6)),1};
    %%% remove html formatting
    param = param(23:end-18);
    z = find(strcmp(param,BurstData{file}.NameArray)); 
    z = datatoplot(:,z);

    % sort all selected bursts into the Mask
    for i = 1:size(bin,1) %bin in a list of X and Y bins of all selected bursts
        if ~isnan(z(i)) && ~isnan(bin(i,1)) && ~isnan(bin(i,2))
            Mask(bin(i,1),bin(i,2)) = Mask(bin(i,1),bin(i,2)) + z(i);
            counter(bin(i,1),bin(i,2)) = counter(bin(i,1),bin(i,2)) + 1;
        end
    end
    % make the average of all entries in Mask depending on the number of bursts in the pixel
    Mask(counter > 0) = Mask(counter > 0)./counter(counter > 0); 
    zParam = Mask(:);
    % go in between the limits defined in the cut table 
    zlim = [h.CutTable.Data{cell2mat(h.CutTable.Data(:,6)),2} h.CutTable.Data{cell2mat(h.CutTable.Data(:,6)),3}];
    Mask(Mask < zlim(1)) = zlim(1);
    Mask(Mask > zlim(2)) = zlim(2);
    Mask = floor(63*(Mask-zlim(1))./(zlim(2)-zlim(1)))+1;
    % get the colormap user wants
    if ischar(UserValues.BurstBrowser.Display.ColorMap)
        eval(['cmap =' UserValues.BurstBrowser.Display.ColorMap '(64);']);
    else
        cmap=UserValues.BurstBrowser.Display.ColorMap;
    end
    % invert colormap
    if UserValues.BurstBrowser.Display.ColorMapInvert
        cmap=flipud(cmap);
    end
    % a = cmap(Mask,:)
    %    if Mask(1) = n, then a(1) is the nth element of cmap
    % reshape(a, size(Mask,1),size(Mask,2),3))
    %   converts a back to the size of Mask, but now the color in the 3rd dimension
    Color = reshape(cmap(Mask,:),size(Mask,1),size(Mask,2),3);

    if UserValues.BurstBrowser.Display.ZScale_Intensity
        %%% rescale intensity
        ImageColor=gray(128);
        %%% brighten image color map by beta = 25%
        beta = UserValues.BurstBrowser.Display.BrightenColorMap;
        if beta > 0
            ImageColor = ImageColor.^(1-beta);
        elseif beta <= 0
            ImageColor = ImageColor.^(1/(1+beta));
        end
        offset = 0;
        Image=round((127-offset)*(H-min(min(H)))/(max(max(H))-min(min(H))))+1+offset;
        Image=reshape(ImageColor(Image(:),:),size(Image,1),size(Image,2),3);
        Image = Image.*Color;
    else
        Image = Color;
    end
    BurstMeta.Plots.Main_Plot(1).XData = xbins;
    BurstMeta.Plots.Main_Plot(1).YData = ybins;
    BurstMeta.Plots.Main_Plot(1).CData = Image;
    BurstMeta.Plots.Main_Plot(1).AlphaData = (H./max(max(H)) > offset);
    
    %%% Enable ZScale Axis
    h.axes_ZScale.Visible = 'on';
    set(BurstMeta.Plots.ZScale_hist,'Visible','on');
    %%% Plot histogram of average Z paramter
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
        %%% use non-averaged parameter
        zData = z;
    else
        %%% image plot, show histogram of pixel wise average
        zData = zParam(zParam>0);
    end
    [Z,xZ] = histcounts(zData,linspace(zlim(1),zlim(2),26));
    xZ = xZ(1:end-1)+min(diff(xZ))/2;
    BurstMeta.Plots.ZScale_hist(1).XData = xZ;
    BurstMeta.Plots.ZScale_hist(1).YData = Z;
    BurstMeta.Plots.ZScale_hist(2).XData = [xZ,xZ(end)+min(diff(xZ))]-min(diff(xZ))/2;
    BurstMeta.Plots.ZScale_hist(2).YData = [Z, Z(end)];
    xlim(h.axes_ZScale,zlim);
    h.axes_ZScale.XTick = linspace(zlim(1),zlim(2),5);
    h.axes_ZScale.XTickLabel = [];
    h.axes_ZScale.YTick = linspace(h.axes_ZScale.YLim(1),h.axes_ZScale.YLim(2),5);
    h.axes_ZScale.YTickLabel = [];
    %%% Update Colorbar
    h.colorbar.Label.String = param;%h.CutTable.RowName(cell2mat(h.CutTable.Data(:,5)));
    h.colorbar.Ticks = [0,1/2,1];
    h.colorbar.TickLabels = {sprintf('%.2f',(zlim(1)));sprintf('%.2f',zlim(1)+(zlim(2)-zlim(1))/2);sprintf('%.2f',zlim(2))};
    h.colorbar.AxisLocation='out';
    
    if any(strcmp(UserValues.BurstBrowser.Display.PlotType,{'Contour','Hex'}))
        %%% Change plot type to image
        h.PlotTypePopumenu.Value = 1;
        UserValues.BurstBrowser.Display.PlotType = 'Image';
        ChangePlotType(h.PlotTypePopumenu,[]);
    end
    
    if strcmp(UserValues.BurstBrowser.Display.PlotType,{'Scatter'})
        %%% simply use z-paramter as color
        BurstMeta.Plots.Main_Plot(3).XData = datatoplot(:,x);
        BurstMeta.Plots.Main_Plot(3).YData = datatoplot(:,y);
        %%% map z value to colormap
        cmap = colormap;
        z(z<zlim(1)) = zlim(1); z(z>zlim(2)) = zlim(2);
        z_to_color = ceil((z-min(z))./(max(z)-min(z)).*size(cmap,1));
        z_to_color(z_to_color == 0) = 1;
        z_to_color(isnan(z_to_color)) = size(cmap,1);
        z_color = cmap(z_to_color,:);
        BurstMeta.Plots.Main_Plot(3).CData = z_color;
    end

    HH = H;
end

%% plotting of 1d hists

%%% set limits of axes
if ~(xlimits(1) == xlimits(2))
    h.axes_general.XLim = xlimits;
    h.axes_1d_x.XLim = xlimits;
end
if ~(ylimits(1) == ylimits(2))
    h.axes_general.YLim = ylimits;
    h.axes_1d_y.XLim = ylimits;
end
%%% Update Labels
xlabel(h.axes_general,h.ParameterListX.String{x},'Color',UserValues.Look.Fore);
ylabel(h.axes_general,h.ParameterListY.String{y},'Color',UserValues.Look.Fore);
xlabel(h.axes_1d_x,h.ParameterListX.String{x},'Color',UserValues.Look.Fore);
%xlabel(h.axes_1d_y,h.ParameterListX.String{y},'Color',UserValues.Look.Fore,'Rotation',270,'Units','normalized','Position',[1.35,0.5]);

%plot 1D hists
h.axes_1d_x.XTickLabelMode = 'auto';
BurstMeta.Plots.Main_histX(1).XData = xbins;
BurstMeta.Plots.Main_histX(1).YData = sum(H,1);
BurstMeta.Plots.Main_histX(2).XData = [xbins,xbins(end)+min(diff(xbins))]-min(diff(xbins))/2;
BurstMeta.Plots.Main_histX(2).YData = [BurstMeta.Plots.Main_histX(1).YData, BurstMeta.Plots.Main_histX(1).YData(end)];
h.axes_1d_x.YTickMode = 'auto';
yticks= get(h.axes_1d_x,'YTick');
set(h.axes_1d_x,'YTick',yticks(2:end));

BurstMeta.Plots.Main_histY(1).XData = ybins;
BurstMeta.Plots.Main_histY(1).YData = sum(H,2);
BurstMeta.Plots.Main_histY(2).XData = [ybins,ybins(end)+min(diff(ybins))]-min(diff(ybins))/2;
BurstMeta.Plots.Main_histY(2).YData = [BurstMeta.Plots.Main_histY(1).YData, BurstMeta.Plots.Main_histY(1).YData(end)];
h.axes_1d_y.YTickMode = 'auto';
yticks = get(h.axes_1d_y,'YTick');
set(h.axes_1d_y,'YTick',yticks(2:end));

if (h.axes_1d_x.XLim(2) - h.axes_1d_x.XTick(end))/(h.axes_1d_x.XLim(2)-h.axes_1d_x.XLim(1)) < 0.02
    %%% Last XTick Label is at the end of the axis and thus overlaps with colorbar
    h.axes_1d_x.XTickLabel{end} = '';
else
    h.axes_1d_x.XTickLabel = h.axes_general.XTickLabel;
end

% Update no. bursts
set(h.text_nobursts, 'String', [num2str(sum(BurstData{file}.Selected)) ' bursts ('...
                                num2str(round(sum(BurstData{file}.Selected/numel(BurstData{file}.Selected)*1000))/10) '% of total)']);
                            
if sum(strcmp('Mean Macrotime [s]',BurstData{file}.NameArray)) == 1
    h.text_nobursts.TooltipString = sprintf('%.1f events per second',size(BurstData{file}.DataArray,1)./BurstData{file}.DataArray(end,strcmp('Mean Macrotime [s]',BurstData{file}.NameArray)));
end

if h.DisplayAverage.Value == 1
    h.axes_1d_x_text.Visible = 'on';
    h.axes_1d_y_text.Visible = 'on';

    set(h.axes_1d_x_text, 'String', sprintf('avg = %.3f%c%.3f',mean(datatoplot(:,x),'omitnan'),char(177),std(datatoplot(:,x),'omitnan')));
    set(h.axes_1d_y_text, 'String', sprintf('avg = %.3f%c%.3f',mean(datatoplot(:,y),'omitnan'),char(177),std(datatoplot(:,y),'omitnan')));
else
    h.axes_1d_x_text.Visible = 'off';
    h.axes_1d_y_text.Visible = 'off';
end

% Update axis labels if log option is used
%%% logarithmic plot option
if UserValues.BurstBrowser.Display.logX
    h.axes_general.XLabel.String = [h.axes_general.XLabel.String ' log'];
    h.axes_1d_x.XLabel.String = [h.axes_1d_x.XLabel.String ' log'];
end
if UserValues.BurstBrowser.Display.logY
    h.axes_general.YLabel.String = [h.axes_general.YLabel.String ' log'];
end
%% Gaussian fitting
if obj == h.Fit_Gaussian_Button
    %%% reset plots
    set(BurstMeta.Plots.Mixture.Main_Plot,'Visible','off');
    set(BurstMeta.Plots.Mixture.plotX,'Visible','off');
    set(BurstMeta.Plots.Mixture.plotY,'Visible','off');
    if isfield(BurstMeta,'Fitting')
        %%% remove field in BurstMeta
        BurstMeta = rmfield(BurstMeta,'Fitting');
    end
    paramx = x; paramy = y;
    %%% Perform fitting of Gausian Mixture model to currently plotted data
    h.Progress_Text.String = 'Fitting Gaussian Mixture...';drawnow;
    nG = h.Fit_NGaussian_Popupmenu.Value;
    %%% update datatoplot if multiselection is enabled
    if h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1
        data_x = get_multiselection_data(h,x_name);
        data_y = get_multiselection_data(h,y_name);
        %%% logarithmic plot option
        if UserValues.BurstBrowser.Display.logX
            val = data_x > 0; % avoid complex numbers
            data_x(val) = log10(data_x(val));
            data_x(~val) = NaN;
        end
        if UserValues.BurstBrowser.Display.logY
            val = data_y > 0; % avoid complex numbers
            data_y(val) = log10(data_y(val));
            data_y(~val) = NaN;
        end
    else
        data_x = datatoplot(:,x);
        data_y = datatoplot(:,y);
    end
    %%% we need to adjust the number of xbins/ybins of KDE has been used
    if UserValues.BurstBrowser.Display.KDE
        nbinsX = numel(xbins);
        nbinsY = numel(ybins);
    end
    % Fit mixture to data
    switch UserValues.BurstBrowser.Settings.GaussianFitMethod
        case 'MLE'
            if x == y %%% same data selected, 1D fitting
                BurstMeta.Fitting.FitType = '1D';
                
                GModel = fitgmdist(data_x,nG,'Options',statset('MaxIter',1000));
                xbins_fit = linspace(xbins(1)-min(diff(xbins)),xbins(end)+min(diff(xbins)),1000);
                p = pdf(GModel,xbins_fit');
                Res = zeros(1,3*nG);
                Res(1:3:end) = GModel.ComponentProportion;
                Res(2:3:end) = GModel.mu;
                Res(3:3:end) = sqrt(GModel.Sigma);
                Res(end+1) = GModel.NegativeLogLikelihood;
                Res(end+1) = GModel.BIC;
                BurstMeta.Fitting.FitResult = Res;
                
                BurstMeta.Plots.Mixture.plotX(1).Visible = 'on';
                BurstMeta.Plots.Mixture.plotX(1).XData = xbins_fit;
                BurstMeta.Plots.Mixture.plotX(1).YData = p./sum(p).*sum(sum(HH))*1000/nbinsX;
                if nG > 1
                    for i = 1:nG
                        p_ind = normpdf(xbins_fit,GModel.mu(i),sqrt(GModel.Sigma(:,:,i)));
                        p_ind = p_ind./sum(p_ind).*sum(sum(HH)).*GModel.ComponentProportion(i);
                        BurstMeta.Plots.Mixture.plotX(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.plotX(i+1).XData = xbins_fit;
                        BurstMeta.Plots.Mixture.plotX(i+1).YData = p_ind*1000/nbinsX;
                    end
                end
                h.Fit_Gaussian_Text.Data(1,1:3) = {double(GModel.Converged),GModel.NegativeLogLikelihood,GModel.BIC};
                for i = 1:nG
                    h.Fit_Gaussian_Text.Data(3+i,:) = {GModel.ComponentProportion(i),GModel.mu(i,1),'-',sqrt(GModel.Sigma(1,1,i)),'-','-'};
                end
                if nG < 5
                    h.Fit_Gaussian_Text.Data(3+nG+1:end,:) = cell(5-nG,6);
                end
            else
                BurstMeta.Fitting.FitType = '2D';
                
                valid = isfinite(data_x) & isfinite(data_y);
                if h.Fit_Gaussian_Pick.Value
                    cov = [std(data_x),0; 0,std(data_y)];
                    [x_start,y_start] = ginput(nG);
                    start = struct('mu',[x_start,y_start],'Sigma',repmat(cov,[1,1,nG]),'ComponentProportion',ones(1,nG)./nG);
                    GModel = fitgmdist([data_x(valid),data_y(valid)],nG,'Start',start,'Options',statset('MaxIter',1000));
                else
                    %[~,ix_max] = max(HH(:));
                    %[y_start,x_start] = ind2sub([nbinsX,nbinsY],ix_max);
                    %start = struct('mu',repmat([xbins(x_start),ybins(y_start)],[nG,1]),'Sigma',repmat(cov,[1,1,nG]),'ComponentProportion',ones(1,nG)./nG);
                    GModel = fitgmdist([data_x(valid),data_y(valid)],nG,'Start','plus','Options',statset('MaxIter',1000));
                end
                Res = zeros(1,6*nG);
                Res(1:6:end) = GModel.ComponentProportion;
                Res(2:6:end) = GModel.mu(:,1);
                Res(3:6:end) = GModel.mu(:,2);
                Res(4:6:end) = sqrt(GModel.Sigma(1,1,:));
                Res(5:6:end) = sqrt(GModel.Sigma(2,2,:));
                Res(6:6:end) = GModel.Sigma(1,2,:);
                Res(end+1) = GModel.NegativeLogLikelihood;
                Res(end+1) = GModel.BIC;
                BurstMeta.Fitting.FitResult = Res;
                % plot contour plot over image plot
                % hide contourf plot, make image plot visible
                %BurstMeta.Plots.Main_Plot(1).Visible = 'on';
                %BurstMeta.Plots.Main_Plot(2).Visible = 'off';
                for i = 1:nG
                    BurstMeta.Plots.Mixture.Main_Plot(i).Visible = 'on';
                    BurstMeta.Plots.Mixture.plotX(i).Visible = 'on';
                    BurstMeta.Plots.Mixture.plotY(i).Visible = 'on';
                end
                % prepare fit data
                if h.Hist_log10.Value; HH = 10.^(HH);end;
                xbins_fit = linspace(xbins(1)-min(diff(xbins)),xbins(end)+min(diff(xbins)),1000);
                ybins_fit = linspace(ybins(1)-min(diff(ybins)),ybins(end)+min(diff(ybins)),1000);
                [X,Y] = meshgrid(xbins_fit,ybins_fit);
                p = reshape(pdf(GModel,[X(:) Y(:)]),[1000,1000]);
                pX = sum(p,1);pX = pX./sum(pX).*sum(sum(HH))*1000/nbinsX;
                pY = sum(p,2);pY = pY./sum(pY).*sum(sum(HH))*1000/nbinsY;
                BurstMeta.Plots.Mixture.Main_Plot(1).XData = xbins_fit;
                BurstMeta.Plots.Mixture.Main_Plot(1).YData = ybins_fit;
                BurstMeta.Plots.Mixture.Main_Plot(1).ZData = p/sum(sum(p)).*sum(sum(HH))*1000^2/nbinsX/nbinsY;
                BurstMeta.Plots.Mixture.Main_Plot(1).LevelList = UserValues.BurstBrowser.Settings.IsoLineGaussFit*max(max(BurstMeta.Plots.Mixture.Main_Plot(1).ZData));%linspace(0,max(max(HH)),10);
                BurstMeta.Plots.Mixture.plotX(1).XData = xbins_fit;
                BurstMeta.Plots.Mixture.plotX(1).YData = pX;
                BurstMeta.Plots.Mixture.plotY(1).XData = ybins_fit;
                BurstMeta.Plots.Mixture.plotY(1).YData = pY;
                
                [Xdata,Ydata] = meshgrid(xbins,ybins);
                %%% Update subplots
                if nG > 1
                    for i = 1:nG
                        p_ind = mvnpdf([X(:) Y(:)],GModel.mu(i,:),GModel.Sigma(:,:,i));
                        p_ind = reshape(p_ind,[1000,1000]);
                        p_ind = p_ind./sum(sum(p_ind)).*sum(sum(HH)).*GModel.ComponentProportion(i)*1000^2/nbinsX/nbinsY;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).XData = xbins_fit;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).YData = ybins_fit;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).ZData = p_ind;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).LevelList = UserValues.BurstBrowser.Settings.IsoLineGaussFit*max(max(BurstMeta.Plots.Mixture.Main_Plot(i+1).ZData));%linspace(0,max(max(p_ind)),10);
                        p_ind_x = sum(p_ind,1);
                        BurstMeta.Plots.Mixture.plotX(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.plotX(i+1).XData = xbins_fit;
                        BurstMeta.Plots.Mixture.plotX(i+1).YData = p_ind_x./sum(p_ind_x).*sum(sum(HH)).*GModel.ComponentProportion(i)*1000/nbinsX;
                        p_ind_y = sum(p_ind,2);
                        BurstMeta.Plots.Mixture.plotY(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.plotY(i+1).XData = ybins_fit;
                        BurstMeta.Plots.Mixture.plotY(i+1).YData = p_ind_y./sum(p_ind_y).*sum(sum(HH)).*GModel.ComponentProportion(i)*1000/nbinsY;
                        %%% store for species assignment using data binning
                        p_ind = mvnpdf([Xdata(:) Ydata(:)],GModel.mu(i,:),GModel.Sigma(:,:,i));
                        p_ind = reshape(p_ind,[numel(xbins),numel(ybins)]);p_ind = p_ind./sum(sum(p_ind));
                        BurstMeta.Fitting.Species{i} = p_ind;
                        BurstMeta.Fitting.MeanX(i) = GModel.mu(i,1);
                        BurstMeta.Fitting.MeanY(i) = GModel.mu(i,2);
                    end
                end
                %%% output result in table
                h.Fit_Gaussian_Text.Data(1,1:3) = {double(GModel.Converged),GModel.NegativeLogLikelihood,GModel.BIC};
                for i = 1:nG
                    h.Fit_Gaussian_Text.Data(3+i,:) = {GModel.ComponentProportion(i),GModel.mu(i,1),GModel.mu(i,2),sqrt(GModel.Sigma(1,1,i)),sqrt(GModel.Sigma(2,2,i)),GModel.Sigma(1,2,i)};
                end
                if nG < 5
                    h.Fit_Gaussian_Text.Data(3+nG+1:end,:) = cell(5-nG,6);
                end
            end
        case 'LSQ'
            if x == y %%% same data selected, 1D fitting
                BurstMeta.Fitting.FitType = '1D';
                
                xbins_fit = linspace(xbins(1)-min(diff(xbins)),xbins(end)+min(diff(xbins)),1000);
                x_start = mean(data_x(isfinite(data_x)));
                %%% for non fixed values, take estimate
                %%% set fixed values to x0
                x0 = zeros(1,12);
                lb = zeros(1,12);
                ub = inf(1,12);
                fixed = false(1,12);
                for i = 1:5
                    x0((1+(i-1)*3):(3+(i-1)*3)) = cell2mat(h.Fit_Gaussian_Text.Data(i,[1,5,13]));
                    lb((1+(i-1)*3):(3+(i-1)*3)) = cell2mat(h.Fit_Gaussian_Text.Data(i,[2,6,14]));
                    ub((1+(i-1)*3):(3+(i-1)*3)) = cell2mat(h.Fit_Gaussian_Text.Data(i,[3,7,15]));
                    fixed((1+(i-1)*3):(3+(i-1)*3)) = cell2mat(h.Fit_Gaussian_Text.Data(i,[4,8,16]));
                end

                %%% set starting center values to mean values or picked
                for i = 1:nG
                    if ~fixed(2+(i-1)*3)
                        x0(2+(i-1)*3) = x_start;
                    end
                    if ~fixed(1+(i-1)*3)
                        x0(1+(i-1)*3) = 1/nG;
                    end
                end
                
                xdata = {xbins,sum(sum(HH)),fixed,nG,0};
                ydata = sum(HH,1);
                BurstMeta.GaussianFit.Params = x0;
                opt = optimoptions('lsqcurvefit','MaxFunEvals',10000);
                [x,~,residuals] = lsqcurvefit(@MultiGaussFit_1D,x0(~fixed),xdata,ydata,lb(~fixed),ub(~fixed),opt);
                
                chi2 = sum((residuals.^2)./max(1,ydata))./(numel(ydata)-1-sum(fixed));
                h.Fit_GaussianChi2_Text.String = sprintf('red. Chi2 = %.2f',chi2);
                
                Res = zeros(1,numel(fixed));
                Res(~fixed)=x;
                %%% Assigns parameters from table to fixed parameters
                Res(fixed)=BurstMeta.GaussianFit.Params(fixed);
                Res(1:3:end) = Res(1:3:end)./sum(Res(1:3:end));
                BurstMeta.Fitting.FitResult = [Res(1:3*nG), chi2];
                
                p = MultiGaussFit_1D(Res,{xbins_fit,sum(sum(HH)),fixed,nG,1});
                BurstMeta.Plots.Mixture.plotX(1).Visible = 'on';
                BurstMeta.Plots.Mixture.plotX(1).XData = xbins_fit;
                BurstMeta.Plots.Mixture.plotX(1).YData = p*1000/nbinsX;
                if nG > 1
                    for i = 1:nG
                        x_ind = Res;
                        for j = 1:nG %%% set other components to zero
                            if j ~=i
                                x_ind(1+(j-1)*3) = 0;
                            else
                                x_ind(1+(j-1)*3) = 1;
                            end
                        end
                        p_ind = MultiGaussFit_1D(x_ind,{xbins_fit,sum(sum(HH)),fixed,nG,1});
                        BurstMeta.Plots.Mixture.plotX(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.plotX(i+1).XData = xbins_fit;
                        BurstMeta.Plots.Mixture.plotX(i+1).YData = Res(1+(i-1)*3)*p_ind*1000/nbinsX;
                    end
                end
                 %%% output result in table
                Data = h.Fit_Gaussian_Text.Data;
                for i = 1:nG
                    Data(i,[1,5,13]) = num2cell(Res(1+(i-1)*3:3+(i-1)*3));
                end
                h.Fit_Gaussian_Text.Data = Data;
                
            else
                BurstMeta.Fitting.FitType = '2D';
                
                cov = [std(data_x).^2,std(data_y).^2,0];
                if h.Fit_Gaussian_Pick.Value
                    [x_start,y_start] = ginput(nG);
                    x0_input = zeros(1,18);
                    for i = 1:nG
                        x0_input((1+(i-1)*6):(6+(i-1)*6)) = [1/nG,x_start(i),y_start(i),cov];
                    end
                    drawnow;
                end

                %%% for non fixed values, take estimate
                %%% set fixed values to x0
                x0 = zeros(1,24);
                lb = zeros(1,24);
                ub = inf(1,24);
                fixed = false(1,24);
                lowerx = min(data_x);
                lowery = min(data_y);
                upperx = max(data_x);
                uppery = max(data_y);
                for i = 1:5
                    x0((1+(i-1)*6):(6+(i-1)*6)) = cell2mat(h.Fit_Gaussian_Text.Data(i,1:4:end));
                    lb((1+(i-1)*6):(6+(i-1)*6)) = cell2mat(h.Fit_Gaussian_Text.Data(i,2:4:end));
                    lb(2+(i-1)*6) = max([lowerx lb(2+(i-1)*6)]);
                    lb(3+(i-1)*6) = max([lowery lb(3+(i-1)*6)]);
                    ub((1+(i-1)*6):(6+(i-1)*6)) = cell2mat(h.Fit_Gaussian_Text.Data(i,3:4:end));
                    ub(2+(i-1)*6) = min([upperx ub(2+(i-1)*6)]);
                    ub(3+(i-1)*6) = min([uppery ub(3+(i-1)*6)]);
                    fixed((1+(i-1)*6):(6+(i-1)*6)) = cell2mat(h.Fit_Gaussian_Text.Data(i,4:4:end));
                    %%% square sigma
                    x0([4,5]+(i-1)*6) = x0([4,5]+(i-1)*6).^2;
                    lb([4,5]+(i-1)*6) = lb([4,5]+(i-1)*6).^2;
                    ub([4,5]+(i-1)*6) = ub([4,5]+(i-1)*6).^2;
                end

                %%% set starting center values to mean values or picked values
                if h.Fit_Gaussian_Pick.Value
                    for i = 1:nG
                        if ~fixed(2+(i-1)*6)
                            x0(2+(i-1)*6) = x0_input(2+(i-1)*6);
                        end
                        if ~fixed(3+(i-1)*6)
                            x0(3+(i-1)*6) = x0_input(3+(i-1)*6);
                        end
                        %%% set amplitude to 1/N
                        if ~fixed(1+(i-1)*6)
                            x0(1+(i-1)*6) = 1/nG;
                        end
                    end
                end
                
                if h.Hist_log10.Value; HH = 10.^(HH);end;
                ydata = HH;
                xdata = {xbins,ybins,sum(sum(ydata)),fixed,nG,0};
                BurstMeta.GaussianFit.Params = x0;
                opt = optimoptions('lsqcurvefit','MaxFunEvals',10000);
                [x,~,residuals] = lsqcurvefit(@MultiGaussFit,x0(~fixed),xdata,ydata,lb(~fixed),ub(~fixed),opt);
                valid = (ydata ~= 0);
                if UserValues.BurstBrowser.Display.KDE
                    %%% no bin is zero, so use a different threshold as well
                    valid = valid & (ydata >= 1);
                end
                chi2 = sum(sum((residuals(valid).^2)./max(1,ydata(valid))))./(numel(ydata(valid))-1-sum(fixed));
                h.Fit_GaussianChi2_Text.String = sprintf('red. Chi2 = %.2f',chi2);
                
                Res = zeros(1,numel(fixed));
                Res(~fixed)=x;
                %%% Assigns parameters from table to fixed parameters
                Res(fixed)=BurstMeta.GaussianFit.Params(fixed);
                for i =1:nG
                    COV = [Res(4+(i-1)*6),Res(6+(i-1)*6);Res(6+(i-1)*6),Res(5+(i-1)*6)];
                    [~,f] = chol(COV);
                    if f~=0 %%% error
                        COV = fix_covariance_matrix(COV);
                    end
                    Res(4+(i-1)*6) = COV(1,1);
                    Res(6+(i-1)*6) = COV(1,2);
                    Res(5+(i-1)*6) = COV(2,2);
                end
                Res(1:6:end) = Res(1:6:end)./sum(Res(1:6:end));
                
                FitResult = Res;
                FitResult(4:6:end) = sqrt(FitResult(4:6:end));
                FitResult(5:6:end) = sqrt(FitResult(5:6:end));
                BurstMeta.Fitting.FitResult = [FitResult(1:6*nG),chi2];
                % hide contourf plot, make image plot visible
                %BurstMeta.Plots.Main_Plot(1).Visible = 'on';
                %BurstMeta.Plots.Main_Plot(2).Visible = 'off';
                for i = 1:nG
                    BurstMeta.Plots.Mixture.Main_Plot(i).Visible = 'on';
                    BurstMeta.Plots.Mixture.plotX(i).Visible = 'on';
                    BurstMeta.Plots.Mixture.plotY(i).Visible = 'on';
                end

                % prepare fit data
                xbins_fit = linspace(xbins(1)-min(diff(xbins)),xbins(end)+min(diff(xbins)),1000);
                ybins_fit = linspace(ybins(1)-min(diff(ybins)),ybins(end)+min(diff(ybins)),1000);
                p = MultiGaussFit(x,{xbins_fit,ybins_fit,sum(sum(HH)),fixed,nG,0});
                pX = sum(p,1);
                pY = sum(p,2);
                BurstMeta.Plots.Mixture.Main_Plot(1).XData = xbins_fit;
                BurstMeta.Plots.Mixture.Main_Plot(1).YData = ybins_fit;
                BurstMeta.Plots.Mixture.Main_Plot(1).ZData = p*1000^2/nbinsX/nbinsY;
                BurstMeta.Plots.Mixture.Main_Plot(1).LevelList = UserValues.BurstBrowser.Settings.IsoLineGaussFit*max(max(BurstMeta.Plots.Mixture.Main_Plot(1).ZData));%linspace(0,max(max(HH)),10);
                BurstMeta.Plots.Mixture.plotX(1).XData = xbins_fit;
                BurstMeta.Plots.Mixture.plotX(1).YData = pX*1000/nbinsX;
                BurstMeta.Plots.Mixture.plotY(1).XData = ybins_fit;
                BurstMeta.Plots.Mixture.plotY(1).YData = pY*1000/nbinsY;

                %%% Update subplots
                if nG > 1
                    for i = 1:nG
                        x_ind = Res;
                        for j = 1:nG %%% set other components to zero
                            if j ~=i
                                x_ind(1+(j-1)*6) = 0;
                            else
                                x_ind(1+(j-1)*6) = 1;
                            end
                        end
                        p_ind = MultiGaussFit(x_ind,{xbins_fit,ybins_fit,sum(sum(HH)),fixed,nG,1});
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).XData = xbins_fit;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).YData = ybins_fit;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).ZData = Res(1+(i-1)*6)*p_ind*1000^2/nbinsX/nbinsY;
                        BurstMeta.Plots.Mixture.Main_Plot(i+1).LevelList = UserValues.BurstBrowser.Settings.IsoLineGaussFit*max(max(BurstMeta.Plots.Mixture.Main_Plot(i+1).ZData));%linspace(0,max(max(p_ind)),10);
                        p_ind_x = sum(p_ind,1);
                        BurstMeta.Plots.Mixture.plotX(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.plotX(i+1).XData = xbins_fit;
                        BurstMeta.Plots.Mixture.plotX(i+1).YData = Res(1+(i-1)*6)*p_ind_x*1000/nbinsX;
                        p_ind_y = sum(p_ind,2);
                        BurstMeta.Plots.Mixture.plotY(i+1).Visible = 'on';
                        BurstMeta.Plots.Mixture.plotY(i+1).XData = ybins_fit;
                        BurstMeta.Plots.Mixture.plotY(i+1).YData = Res(1+(i-1)*6)*p_ind_y*1000/nbinsY;
                        %%% store for species assignment using data binning
                        p_ind = MultiGaussFit(x_ind,{xbins,ybins,sum(sum(HH)),fixed,nG,1});
                        BurstMeta.Fitting.Species{i} = Res(1+(i-1)*6)*p_ind;
                        BurstMeta.Fitting.MeanX(i) = x_ind(2+(i-1)*6);
                        BurstMeta.Fitting.MeanY(i) = x_ind(3+(i-1)*6);
                    end
                end
                %%% make variance to sigma
                for i =1:5
                    Res([4,5]+(i-1)*6) = sqrt(Res([4,5]+(i-1)*6));
                end
                %%% output result in table
                Data = h.Fit_Gaussian_Text.Data;
                for i = 1:nG
                    Data(i,1:4:end) = num2cell(Res(1+(i-1)*6:6+(i-1)*6));
                end
                h.Fit_Gaussian_Text.Data = Data;
            end
    end
    if (paramx ~= paramy) && ~h.MultiselectOnCheckbox.UserData
        BurstMeta.Fitting.BurstBins = NaN(size(BurstData{file}.DataArray,1),2);
        BurstMeta.Fitting.BurstBins(BurstData{file}.Selected,:) = bin;
        BurstMeta.Fitting.BurstCount = H;
        BurstMeta.Fitting.ParamX = BurstData{file}.NameArray{paramx};
        BurstMeta.Fitting.ParamY = BurstData{file}.NameArray{paramy};
    end
    if advanced
        h.colorbar.Ticks = [h.colorbar.Limits(1) h.colorbar.Limits(1)+0.5*(h.colorbar.Limits(2)-h.colorbar.Limits(1)) h.colorbar.Limits(2)];
    end
    h.Progress_Text.String = 'Done';
    %%% set linecolor of bar plot to none
    BurstMeta.Plots.Main_histX(2).Color = 'none';
    BurstMeta.Plots.Main_histY(2).Color = 'none';
else
    %%% set linecolor of bar plot to black
    BurstMeta.Plots.Main_histX(2).Color = [0,0,0];
    BurstMeta.Plots.Main_histY(2).Color = [0,0,0];
end

drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Defines new cuts from fitted Gaussians  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SpeciesFromGaussianFit(obj,~)
global BurstData BurstMeta
file = BurstMeta.SelectedFile;
h = guidata(obj);
if h.MultiselectOnCheckbox.UserData
    disp('Disable multiplot mode and fit a single file!');
    return;
end
if ~isfield(BurstMeta,'Fitting')
    disp('Perform a Gaussian fit first');
    return;
end
if ~isfield(BurstMeta.Fitting,'Species') %%% occurs when only one species was used for fitting
    disp('Multi-species fit required.');
    return;
end
%%% assign bursts to species according to bin and probability
%%% uses stored information in BurstMeta.Fitting

%%% convert species probability density functions to probability for bin
nSpecies = numel(BurstMeta.Fitting.Species);
pTotal = BurstMeta.Fitting.Species{1}(:);
for i = 2:nSpecies
    pTotal = pTotal + BurstMeta.Fitting.Species{i}(:);
end
pSpecies = BurstMeta.Fitting.Species{1}(:)./pTotal;
for i = 2:nSpecies
    pSpecies = [pSpecies, BurstMeta.Fitting.Species{i}(:)./pTotal];
end

%%% number of bursts in each bin
burstCount = BurstMeta.Fitting.BurstCount(:);
%%% bins of valid bursts
burstIdx = sub2ind(size(BurstMeta.Fitting.BurstCount),BurstMeta.Fitting.BurstBins(:,1),BurstMeta.Fitting.BurstBins(:,2));

speciesAssignment = NaN(numel(burstIdx),1);
%%% loop over all bins
for i = 1:numel(burstCount)
    if burstCount(i) == 0
        continue;
    end
    %%% assign the bursts randomly to a species based on pSpecies
    nPerSpecies = round(burstCount(i).*pSpecies(i,:));
    while sum(nPerSpecies) < burstCount(i)
        ix = randi(nSpecies);
        nPerSpecies(ix) = nPerSpecies(ix) + 1;
    end
    spec = [];
    for s = 1:nSpecies
        spec = [spec, s*ones(1,nPerSpecies(s))];
    end
    spec = spec(randperm(numel(spec)));
    spec = spec(1:burstCount(i));
    speciesAssignment(burstIdx == i) = spec;
end

%%% add a new species to the species list with specific name
%%% subspecies correspond to the identified species
SpeciesNames = BurstData{file}.SpeciesNames;
SpeciesNames(end+1,1) = {['Fit: ' BurstMeta.Fitting.ParamX ' - ' BurstMeta.Fitting.ParamY]};
BurstData{file}.Cut{end+1,1} = {{BurstMeta.Fitting.ParamX,h.axes_general.XLim(1),h.axes_general.XLim(2),true,false},{BurstMeta.Fitting.ParamY,h.axes_general.YLim(1),h.axes_general.YLim(2),true,false}};
for i = 1:nSpecies
    SpeciesNames(end,i+1) = {['Species ' num2str(i) ': ('  sprintf('%.2f',BurstMeta.Fitting.MeanX(i)) '/' sprintf('%.2f',BurstMeta.Fitting.MeanY(i)) ')']};
    BurstData{file}.Cut{end,i+1} = {{BurstMeta.Fitting.ParamX,h.axes_general.XLim(1),h.axes_general.XLim(2),true,false};{BurstMeta.Fitting.ParamY,h.axes_general.YLim(1),h.axes_general.YLim(2),true,false}};
end
BurstData{file}.SpeciesNames = SpeciesNames;

%%% Add valid arrays to BurstData{file}.FitCut cell array
BurstData{file}.FitCut(size(SpeciesNames,1),1) = {~isnan(burstIdx)};
for i = 1:nSpecies
    BurstData{file}.FitCut(size(SpeciesNames,1),i+1) = {speciesAssignment == i};
end
UpdateSpeciesList(h);

%%%%%%% Changes PlotType  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangePlotType(obj,~,h)
global UserValues BurstMeta
if nargin < 3
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
        obj = h.PlotTypePopumenu;
    else
        h = guidata(obj);
    end
else
    if isempty(obj)
        obj = h.PlotTypePopumenu;
    end
end



switch obj
    case h.PlotTypePopumenu
        set([h.MarkerSize_edit,h.MarkerSize_text,h.MarkerColor_button,h.MarkerColor_text,...
        h.NumberOfContourLevels_text,h.NumberOfContourLevels_edit,h.PlotOffset_edit,h.PlotOffset_text,h.PlotContourLines],...
        'Visible','off');
            
        UserValues.BurstBrowser.Display.PlotType = obj.String{obj.Value};
        fields = fieldnames(BurstMeta.Plots); %%% loop through h structure
        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Image')
            %%% Make Image Plots Visible, Hide Contourf Plots
            for i = 1:numel(fields)
                if ~isempty(BurstMeta.Plots.(fields{i}))
                    if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                        if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                            BurstMeta.Plots.(fields{i})(1).Visible = 'on';
                            BurstMeta.Plots.(fields{i})(2).Visible = 'off';
                            if numel(BurstMeta.Plots.(fields{i}))>2
                                BurstMeta.Plots.(fields{i})(3).Visible = 'off';
                            end
                        end
                    end
                end
            end
            set([h.PlotOffset_edit,h.PlotOffset_text],...
             'Visible','on');
            h.PlotOffset_text.String = 'Plot Offset [%]';
            h.PlotOffset_edit.String = num2str(UserValues.BurstBrowser.Display.ImageOffset);
        end
        
        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour')
            delete(BurstMeta.HexPlot.MainPlot_hex);
            %%% Make Image Plots Visible, Hide Contourf Plots
            for i = 1:numel(fields)
                if ~isempty(BurstMeta.Plots.(fields{i}))
                    if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                        if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                            BurstMeta.Plots.(fields{i})(1).Visible = 'off';
                            BurstMeta.Plots.(fields{i})(2).Visible = 'on';
                            if numel(BurstMeta.Plots.(fields{i}))>2
                                BurstMeta.Plots.(fields{i})(3).Visible = 'off';
                            end
                        end
                    end
                end
            end
            set([h.NumberOfContourLevels_edit,h.NumberOfContourLevels_text,h.PlotOffset_edit,h.PlotOffset_text,h.PlotContourLines],...
             'Visible','on');
            h.PlotOffset_text.String = 'Plot Offset [%]';
            h.PlotOffset_edit.String = num2str(UserValues.BurstBrowser.Display.ContourOffset);
        end
        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
            delete(BurstMeta.HexPlot.MainPlot_hex);
            %%% Make Image Plots Visible, Hide Contourf Plots
            for i = 1:numel(fields)
                if ~isempty(BurstMeta.Plots.(fields{i}))
                    if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                        if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                            if numel(BurstMeta.Plots.(fields{i}))>2
                                BurstMeta.Plots.(fields{i})(1).Visible = 'off';
                                BurstMeta.Plots.(fields{i})(2).Visible = 'off';
                                BurstMeta.Plots.(fields{i})(3).Visible = 'on';
                            end
                        end
                    end
                end
            end
            UpdatePlot([],[],h);
            set([h.MarkerSize_edit,h.MarkerSize_text,h.MarkerColor_button,h.MarkerColor_text],...
                'Visible','on');
        end
        if any(strcmp(UserValues.BurstBrowser.Display.PlotType,{'Image','Contour','Scatter'}))
            fields = fieldnames(BurstMeta.HexPlot);
            for i = 1:numel(fields)
                delete(BurstMeta.HexPlot.(fields{i}));
            end
        end
        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
            %%% Make Image Plots Visible, Hide Contourf Plots
            for i = 1:numel(fields)
                if ~isempty(BurstMeta.Plots.(fields{i}))
                    if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                        if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                            if numel(BurstMeta.Plots.(fields{i}))>2
                                BurstMeta.Plots.(fields{i})(1).Visible = 'off';
                                BurstMeta.Plots.(fields{i})(2).Visible = 'off';
                                BurstMeta.Plots.(fields{i})(3).Visible = 'off';
                            end
                        end
                    end
                end
            end
            %%% Update Plots
            %%% To speed up, find out which tab is visible and only update the respective tab
            switch h.Main_Tab.SelectedTab
                case h.Main_Tab_General
                    %%% we switched to the general tab
                    UpdatePlot([],[],h);
                case h.Main_Tab_Lifetime
                    %%% we switched to the lifetime tab
                    %%% figure out what subtab is selected
                    UpdateLifetimePlots([],[],h);
                    switch h.LifetimeTabgroup.SelectedTab
                        case h.LifetimeTabAll
                        case h.LifetimeTabInd
                            PlotLifetimeInd([],[],h);
                    end     
            end
        end
    case h.PlotContourLines
        UserValues.BurstBrowser.Display.PlotContourLines = h.PlotContourLines.Value;
        fields = fieldnames(BurstMeta.Plots); %%% loop through h structure
        for i = 1:numel(fields)
            if ~isempty(BurstMeta.Plots.(fields{i}))
                if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                    if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                        if UserValues.BurstBrowser.Display.PlotContourLines == 0
                            BurstMeta.Plots.(fields{i})(2).LineStyle = 'none';
                        elseif UserValues.BurstBrowser.Display.PlotContourLines == 1
                            BurstMeta.Plots.(fields{i})(2).LineStyle = '-';
                        end
                    end
                end
            end
        end
end
UpdatePlot([],[],h);
UpdateLifetimePlots([],[],h);
PlotLifetimeInd([],[],h);
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Plots the Species in one Plot (not considering GlobalCuts)  %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [HistOut,xbins,ybins,x_boundaries,y_boundaries,datapoints,n_per_species] = MultiPlot(obj,~,h,paramX,paramY,limits)
%%% limits is optional global max and min boundaries for x and y
if nargin < 3
    if ishandle(obj)
        h = guidata(obj);
    else
        if isprop(obj,'EventName') %%% actiondata obj
            h = guidata(obj.Source);
        else
            h = guidata(findobj('Tag','BurstBrowser'));
        end
    end 
end
global BurstData UserValues BurstMeta
%%% special case when lifetime_ind tab is selected
if (nargout == 0) && (h.Main_Tab.SelectedTab == h.Main_Tab_Lifetime) && (h.LifetimeTabgroup.SelectedTab == h.LifetimeTabInd)
    PlotLifetimeInd(obj,[],h);
    return;
end
%%% get selection of species list
[file_n,species_n,subspecies_n,sel] = get_multiselection(h);

num_species = numel(file_n);

if ~exist('paramX','var')
    paramX = h.ParameterListX.String{h.ParameterListX.Value};
end
if ~exist('paramY','var')
    paramY = h.ParameterListY.String{h.ParameterListY.Value};
end
for i = 1:num_species %%% read out parameter positions for every species
    x{i} = find(strcmp(BurstData{file_n(i)}.NameArray,paramX));
    y{i} = find(strcmp(BurstData{file_n(i)}.NameArray,paramY));
end
valid = ~(cellfun(@isempty,x) | cellfun(@isempty,y));
x = x(valid); y=y(valid);
file_n = file_n(valid); species_n = species_n(valid); subspecies_n = subspecies_n(valid);
num_species = sum(valid);
%%% Read out the Number of Bins
nbinsX = UserValues.BurstBrowser.Display.NumberOfBinsX;
nbinsY = UserValues.BurstBrowser.Display.NumberOfBinsY;
if obj == h.MultiPlotButton %%% only limit species when multiplot button has been pressed
    if num_species == 1
        return;
    end
    if num_species > 3
        num_species = 3;
    end
end

datatoplot = cell(num_species,1);
for i = 1:num_species
    [~,datatoplot{i}] = UpdateCuts([species_n(i),subspecies_n(i)],file_n(i));
end

%%% logarithmic plot option
if UserValues.BurstBrowser.Display.logX
    for i = 1:num_species
        val = datatoplot{i}(:,x{i}) > 0; % avoid complex numbers
        datatoplot{i}(val,x{i}) = log10(datatoplot{i}(val,x{i}));
        datatoplot{i}(~val,x{i}) = NaN;
    end
end
if UserValues.BurstBrowser.Display.logY
    for i = 1:num_species
        val = datatoplot{i}(:,y{i}) > 0; % avoid complex numbers
        datatoplot{i}(val,y{i}) = log10(datatoplot{i}(val,y{i}));
        datatoplot{i}(~val,y{i}) = NaN;
    end
end

%find data ranges
minx = zeros(num_species,1);
miny = zeros(num_species,1);
maxx = zeros(num_species,1);
maxy = zeros(num_species,1);
for i = 1:num_species
    minx(i) = min(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i}));
    miny(i) = min(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i}));
    maxx(i) = max(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i}));
    maxy(i) = max(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i}));
end
x_boundaries = [min(minx) max(maxx)];
y_boundaries = [min(miny) max(maxy)];

if ~exist('limits','var') 
    %%% additionally, look for specified cuts and overwrite auto-bounds
    xlimits = cell(num_species,1); ylimits = cell(num_species,1);
    for i = 1:num_species
        %%% find the bounds
        file =file_n(i);
        species = [species_n(i),subspecies_n(i)];
        NameArray = BurstData{file}.NameArray;

        %%% set limits
        xlimits{i} = [min(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i})) max(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i}))];
        ylimits{i} = [min(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i})) max(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i}))];
        %%% find cuts to parameters to be plotted and change limits if needed
        if all(species == [0,0])
            CutState= {};
        else
            Cut = BurstData{file}.Cut{species(1),species(2)};
            CutState = vertcat(Cut{:});
        end
        if size(CutState,2) > 0
            CutParameters = CutState(:,1);
            if any(strcmp(NameArray{x{i}},CutParameters))
                if CutState{strcmp(NameArray{x{i}},CutParameters),4} == 1 %%% Check if active
                    %%% Set x-axis limits according to cut boundaries of selected parameter
                    xlimits{i} = [CutState{strcmp(NameArray{x{i}},CutParameters),2},...
                        CutState{strcmp(NameArray{x{i}},CutParameters),3}];
                else
                    %%% set to min max
                    xlimits{i} = [min(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i})), max(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i}))];
                end
            else
                %%% set to min max
                xlimits{i} = [min(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i})), max(datatoplot{i}(isfinite(datatoplot{i}(:,x{i})),x{i}))];
            end

            if any(strcmp(NameArray{y{i}},CutParameters))
                if CutState{strcmp(NameArray{y{i}},CutParameters),4} == 1 %%% Check if active
                    %%% Set x-axis limits according to cut boundaries of selected parameter
                    ylimits{i} = [CutState{strcmp(NameArray{y{i}},CutParameters),2},...
                        CutState{strcmp(NameArray{y{i}},CutParameters),3}];
                else
                    %%% set to min max
                    ylimits{i} = [min(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i})), max(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i}))];
                end
            else
                %%% set to min max
                ylimits{i} = [min(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i})), max(datatoplot{i}(isfinite(datatoplot{i}(:,y{i})),y{i}))];
            end
            if isempty(xlimits{i})
                %selection is empty
                xlimits{i} = [0,1];
            end
            if isempty(ylimits{i})
                %selection is empty
                ylimits{i} = [0,1];
            end
            if sum(xlimits{i} == [0,0]) == 2
                xlimits{i} = [0 1];
            end
            if sum(ylimits{i} == [0,0]) == 2
                ylimits{i} = [0 1];
            end
        end
    end
    %%% find minimum and maximum limits
    xlimits = cell2mat(vertcat(xlimits(:)));
    ylimits = cell2mat(vertcat(ylimits(:)));
    %%% overwrite
    x_boundaries(1) = min([x_boundaries(1) min(xlimits(:,1))]);
    x_boundaries(2) = max([x_boundaries(2) max(xlimits(:,2))]);
    y_boundaries(1) = min([y_boundaries(1) min(ylimits(:,1))]);
    y_boundaries(2) = max([y_boundaries(2) max(ylimits(:,2))]);
elseif exist('limits','var') %%% called with absolute limits
    %%% obey specified limits!
    x_boundaries(1) = limits{1}(1);
    x_boundaries(2) = limits{1}(2);
    y_boundaries(1) = limits{2}(1);
    y_boundaries(2) = limits{2}(2);
%     x_boundaries(1) = max([x_boundaries(1) limits{1}(1)]);
%     x_boundaries(2) = min([x_boundaries(2) limits{1}(2)]);
%     y_boundaries(1) = max([y_boundaries(1) limits{2}(1)]);
%     y_boundaries(2) = min([y_boundaries(2) limits{2}(2)]);
end
if UserValues.BurstBrowser.Display.Restrict_EandS_Range
    %%% hard-code limits of [-0.1,1.1] for any Stoichiometry or FRET
    %%% efficiency parameter if the cut limits fall within that range
    if ~isempty(strfind(paramX,'Stoichiometry')) || ~isempty(strfind(paramX,'Efficiency'))
        x_boundaries = [min(x_boundaries(1),-0.1) max(x_boundaries(2),1.1)];
    end
    if ~isempty(strfind(paramY,'Stoichiometry')) || ~isempty(strfind(paramY,'Efficiency'))
        y_boundaries = [min(y_boundaries(1),-0.1) max(y_boundaries(2),1.1)];
    end
end

H = cell(num_species,1);
for i = 1:num_species
    [H{i}, xbins, ybins] = calc2dhist(datatoplot{i}(:,x{i}), datatoplot{i}(:,y{i}),[nbinsX,nbinsY], x_boundaries, y_boundaries);
end

normalize = UserValues.BurstBrowser.Settings.Normalize_Multiplot && num_species > 1 && ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex') && ~(gcbo == h.Fit_Gaussian_Button);
if normalize
    %%% normalize each histogram to equal proportion
    for i = 1:num_species
        H{i} = H{i}./sum(H{i}(:))./num_species; %%% ensure that total data sums up to 1
    end
end

if nargout > 0 %%% we requested the histogram, do not plot!
    if (gcbo == h.MultiPlotButton) && (h.Main_Tab.SelectedTab == h.Main_Tab_Lifetime) && (h.LifetimeTabgroup.SelectedTab == h.LifetimeTabInd)
        HistOut = H; %%% just return the cell array
    else
        Hcum = H{1};
        for k = 2:numel(H)
            Hcum = Hcum + H{k};
        end
        if UserValues.BurstBrowser.Settings.Normalize_Multiplot && num_species > 1 && ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex') && ~(gcbo == h.Fit_Gaussian_Button)
            HistOut = Hcum./max(Hcum(:));
        else
            HistOut = Hcum;
        end
    end
    
    datapoints = [];
    n_per_species = [];
    if nargout >= 6 %%% return raw data points for scatter/hex plot
        for i = 1:num_species
            n_per_species(end+1) = size(datatoplot{i},1);
            datapoints = [datapoints; [datatoplot{i}(:,x{i}),datatoplot{i}(:,y{i})]];
        end
    end
    return;
end
delete(BurstMeta.HexPlot.MainPlot_hex);
%%% prepare image plot
white = 1-UserValues.BurstBrowser.Display.MultiPlotMode;
axes(h.axes_general);

%%% mix histograms
[zz,color] = overlay_colored(H);

%%% remove old plots
for i = 1:numel(BurstMeta.Plots.MultiScatter.h1dx)
    try;delete(BurstMeta.Plots.MultiScatter.h1dx(i));end;
    try;delete(BurstMeta.Plots.MultiScatter.h1dy(i));end;
end
BurstMeta.Plots.MultiScatter.h1dx = [];
BurstMeta.Plots.MultiScatter.h1dy = [];
%%% additionally, delete all left-over stair plots (those are multi-species
%%% plots, which sometimes are not deleted by the above code...)
delete(h.axes_1d_x.Children(1:end-12));
delete(h.axes_1d_y.Children(1:end-12));

%%% plot
set(BurstMeta.Plots.Main_Plot,'Visible','off');
set(BurstMeta.Plots.Main_histX,'Visible','off');
set(BurstMeta.Plots.Main_histY,'Visible','off');
BurstMeta.Plots.Multi.Main_Plot_multiple.Visible = 'on';
for i = 1:3
    BurstMeta.Plots.Multi.Multi_histX(i).Visible = 'off';
    BurstMeta.Plots.Multi.Multi_histY(i).Visible = 'off';
end
for i = 1:numel(BurstMeta.Plots.MultiScatter.h1dx)
    try;delete(BurstMeta.Plots.MultiScatter.h1dx(i));end;
    try;delete(BurstMeta.Plots.MultiScatter.h1dy(i));end;
end
BurstMeta.Plots.Multi.Main_Plot_multiple.XData = xbins;
BurstMeta.Plots.Multi.Main_Plot_multiple.YData = ybins;
BurstMeta.Plots.Multi.Main_Plot_multiple.CData = zz;

if white == 0
    %%% set alpha property
    BurstMeta.Plots.Multi.Main_Plot_multiple.AlphaData = sum(zz,3)>0;
    %%% change color of 1d hists
    for i = 1:num_species
        BurstMeta.Plots.Multi.Multi_histX(i).Color = color(i,1,:);
        BurstMeta.Plots.Multi.Multi_histY(i).Color = color(i,1,:);
    end
else
    %%% set alpha property
    BurstMeta.Plots.Multi.Main_Plot_multiple.AlphaData = 1-(sum(zz,3)==3);
    color = [0,0,1;1,0,0;0,1,0];
    for i = 1:num_species
        BurstMeta.Plots.Multi.Multi_histX(i).Color = color(i,:);
        BurstMeta.Plots.Multi.Multi_histY(i).Color = color(i,:);
    end
end

xlabel(h.axes_general,paramX,'Color',UserValues.Look.Fore);
ylabel(h.axes_general,paramY,'Color',UserValues.Look.Fore);

% Update axis labels if log option is used
%%% logarithmic plot option
if UserValues.BurstBrowser.Display.logX
    h.axes_general.XLabel.String = [h.axes_general.XLabel.String ' log'];
    h.axes_1d_x.XLabel.String = [h.axes_1d_x.XLabel.String ' log'];
end
if UserValues.BurstBrowser.Display.logY
    h.axes_general.YLabel.String = [h.axes_general.YLabel.String ' log'];
end

%plot first histogram
hx = sum(H{1},1);
%normalize
if normalize
    hx = hx./sum(hx);
end
hx = hx'; hx = [hx; hx(end)];
xbins = [xbins, xbins(end)+min(diff(xbins))]-min(diff(xbins))/2;
BurstMeta.Plots.Multi.Multi_histX(1).Visible = 'on';
BurstMeta.Plots.Multi.Multi_histX(1).XData = xbins;
BurstMeta.Plots.Multi.Multi_histX(1).YData = hx;
%plot rest of histograms
for i = 2:num_species
    BurstMeta.Plots.Multi.Multi_histX(i).Visible = 'on';
    hx = sum(H{i},1);
    %normalize
    if normalize
        hx = hx./sum(hx);
    end
    hx = hx'; hx = [hx; hx(end)];
    BurstMeta.Plots.Multi.Multi_histX(i).XData = xbins;
    BurstMeta.Plots.Multi.Multi_histX(i).YData = hx;
end
h.axes_1d_x.YTickMode = 'auto';
yticks = get(h.axes_1d_x,'YTick');
set(h.axes_1d_x,'YTick',yticks(2:end));

%plot first histogram
hy = sum(H{1},2);
%normalize
if normalize
    hy = hy./sum(hy);
end
hy = hy'; hy = [hy, hy(end)];
ybins = [ybins, ybins(end)+min(diff(ybins))]-min(diff(ybins))/2;
BurstMeta.Plots.Multi.Multi_histY(1).Visible = 'on';
BurstMeta.Plots.Multi.Multi_histY(1).XData = ybins;
BurstMeta.Plots.Multi.Multi_histY(1).YData = hy;
%plot rest of histograms
for i = 2:num_species
    BurstMeta.Plots.Multi.Multi_histY(i).Visible = 'on';
    hy = sum(H{i},2);
    %normalize
    if normalize
        hy = hy./sum(hy);
    end
    hy = hy'; hy = [hy, hy(end)];
    BurstMeta.Plots.Multi.Multi_histY(i).XData = ybins;
    BurstMeta.Plots.Multi.Multi_histY(i).YData = hy;
end
h.axes_1d_y.YTickMode = 'auto';
yticks = get(h.axes_1d_y,'YTick');
set(h.axes_1d_y,'YTick',yticks(2:end));
%%% add legend
str = cell(num_species,1);
for i = 1:num_species
    %%% extract name
    name = BurstData{file_n(i)}.FileName;
    if (species_n(i) ~= 0)
        if (subspecies_n(i) ~= 1) %%% we have a subspecies selected
            name = [name,'/', char(sel(i).getParent.getName),'/',char(sel(i).getName)];
        else %%% we have a species selected 
            name = [name,'/', char(sel(i).getName)];
        end
    end
    str{i} = strrep(name,'_',' ');  
end
legend(BurstMeta.Plots.Multi.Multi_histX(1:num_species),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
%legend(h.axes_1d_x.Children(8:-1:8-num_species+1),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
h.colorbar.Visible = 'off';
h.axes_ZScale.Visible = 'off';
set(h.axes_ZScale.Children,'Visible','off');

function [zz,color] = overlay_colored(H)
global UserValues
%%% H is a Nx1 cell array of the individual histograms
%%% white specifies the mode
white = 1-UserValues.BurstBrowser.Display.MultiPlotMode;
num_species = numel(H);
color = zeros(3,1,3);
color(1,1,:) = [0    0.4471    0.7412];
color(2,1,:) = [0.8510    0.3255    0.0980];
color(3,1,:) = [0.4667    0.6745    0.1882];
if num_species == 2
    H{1}(isnan(H{1})) = 0;
    H{2}(isnan(H{2})) = 0;
    if white == 0
        zz = zeros(size(H{1},1),size(H{1},2),3);
        zz(:,:,:) = zz(:,:,:) + repmat(H{1}/max(max(H{1})),1,1,3).*repmat(color(1,1,:),size(H{1},1),size(H{1},2),1); %%% color1
        zz(:,:,:) = zz(:,:,:) + repmat(H{2}/max(max(H{2})),1,1,3).*repmat(color(2,1,:),size(H{2},1),size(H{2},2),1); %%% color2
    elseif white == 1
        %%% sub
        zz = ones(size(H{1},1),size(H{1},2),3);
        zz(:,:,1) = zz(:,:,1) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{2}./max(max(H{2})); %%% red
        zz(:,:,3) = zz(:,:,3) - H{2}./max(max(H{2})); %%% red
    end
elseif num_species == 3
    H{1}(isnan(H{1})) = 0;
    H{2}(isnan(H{2})) = 0;
    H{3}(isnan(H{3})) = 0;
    if white == 0
        zz = zeros(size(H{1},1),size(H{1},2),3);
        zz(:,:,:) = zz(:,:,:) + repmat(H{1}/max(max(H{1})),1,1,3).*repmat(color(1,1,:),size(H{1},1),size(H{1},2),1); %%% color1
        zz(:,:,:) = zz(:,:,:) + repmat(H{2}/max(max(H{2})),1,1,3).*repmat(color(2,1,:),size(H{2},1),size(H{2},2),1); %%% color2
        zz(:,:,:) = zz(:,:,:) + repmat(H{3}/max(max(H{3})),1,1,3).*repmat(color(3,1,:),size(H{3},1),size(H{3},2),1); %%% color3
    elseif white == 1
        zz = ones(size(H{1},1),size(H{1},2),3);
        zz(:,:,1) = zz(:,:,1) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{2}./max(max(H{2})); %%% red
        zz(:,:,3) = zz(:,:,3) - H{2}./max(max(H{2})); %%% red
        zz(:,:,1) = zz(:,:,1) - H{3}./max(max(H{3})); %%% green
        zz(:,:,3) = zz(:,:,3) - H{3}./max(max(H{3})); %%% green
    end
else
    return;
end
if white == 0
    beta = UserValues.BurstBrowser.Display.BrightenColorMap;
    if beta > 0
        zz = zz.^(1-beta);
    elseif beta <= 0
        zz = zz.^(1/(1+beta));
    end
end

function [file_n,species_n,subspecies_n,sel] = get_multiselection(h)
%%% get the selection of species list
sel = h.SpeciesList.Tree.getSelectedNodes;
k = 1;
for s = 1:numel(sel)
    switch sel(s).getLevel
        case 0
            % top level was clicked
            % ignore
        case 1
            % file was clicked
            % which one?
            for i = 1:numel(h.SpeciesList.File)
                file(i) = h.SpeciesList.File(i).equals(sel(s));
            end
            file = find(file);

            species_n(k) = 0;
            subspecies_n(k) = 0;
            file_n(k) = file;
            k = k+1;
        case 2
            % species group was clicked
            % which file?
            f = sel(s).getParent;
            for i = 1:numel(h.SpeciesList.File)
                file(i) = h.SpeciesList.File(i).equals(f);
            end
            file = find(file);
            % which one?
            for i = 1:numel(h.SpeciesList.Species{file})
                species(i) = h.SpeciesList.Species{file}(i).equals(sel(s));
            end
            species = find(species);

            species_n(k) = species;
            subspecies_n(k) = 1;
            file_n(k) = file;
            k = k+1;
        case 3
            % subspecies was clicked
            % which parent file?
            f = sel(s).getParent.getParent;
            for i = 1:numel(h.SpeciesList.File)
                file(i) = h.SpeciesList.File(i).equals(f);
            end
            file = find(file);
            % which parent species?
            parent = sel(s).getParent;
            for i = 1:numel(h.SpeciesList.Species{file})
                group(i) = h.SpeciesList.Species{file}(i).equals(parent);
            end
            species = find(group);
            % which subspecies?
            for i = 1:parent.getChildCount
                subspecies(i) = parent.getChildAt(i-1).equals(sel(s));
            end
            subspecies = find(subspecies)+1;

            species_n(k) = species;
            subspecies_n(k) = subspecies;
            file_n(k) = file;
            k = k+1;
    end
end

function data = get_multiselection_data(h,param)
%%% return concatenated data for parameter over all selected species
%%% if only one argument is supplied, gives out the total data array over
%%% all parameters
global BurstData
[file_n,species_n,subspecies_n] = get_multiselection(h);

if nargin > 1
    par = cell(numel(file_n),1);
    for i = 1:numel(file_n) %%% read out parameter positions for every species
        par{i} = find(strcmp(BurstData{file_n(i)}.NameArray,param));
    end
    valid = ~(cellfun(@isempty,par));
    par = par(valid);
    file_n = file_n(valid); species_n = species_n(valid); subspecies_n = subspecies_n(valid);
end

num_species = numel(file_n);
data = cell(num_species,1);
for i = 1:num_species
    [~,data{i}] = UpdateCuts([species_n(i),subspecies_n(i)],file_n(i));
    if nargin > 1
        data{i} = data{i}(:,par{i});
    end
end
data = vertcat(data{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Manual Cut by selecting an area in the current selection  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ManualCut(obj,~)

h = guidata(obj);
global BurstData BurstMeta
%%% switch to main tab
h.Main_Tab.SelectedTab = h.Main_Tab_General;

file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;
        
switch obj
    case h.CutButton
        set(gcf,'Pointer','cross');
        k = waitforbuttonpress;
        point1 = get(gca,'CurrentPoint');    % button down detected
        %%% check if correct axis was clicked
        if gca ~= h.axes_general
            return;
        end
        finalRect = rbbox;           % return figure units
        point2 = get(gca,'CurrentPoint');    % button up detected
        set(gcf,'Pointer','Arrow');
        point1 = point1(1,1:2);
        point2 = point2(1,1:2);

        if (all(point1(1:2) == point2(1:2)))
            disp('error');
            return;
        end

        %%% Check whether the CutParameter already exists or not
        ExistingCuts = vertcat(BurstData{file}.Cut{species(1),species(2)}{:});
        param_x = get(h.ParameterListX,'Value');
        param_y = get(h.ParameterListY,'Value');
        if ~isempty(ExistingCuts)
            if any(strcmp(BurstData{file}.NameArray{param_x},ExistingCuts(:,1)))
                BurstData{file}.Cut{species(1),species(2)}{strcmp(BurstData{file}.NameArray{param_x},ExistingCuts(:,1))} = {BurstData{file}.NameArray{get(h.ParameterListX,'Value')}, min([point1(1) point2(1)]),max([point1(1) point2(1)]), true,false};
            else
                BurstData{file}.Cut{species(1),species(2)}{end+1} = {BurstData{file}.NameArray{get(h.ParameterListX,'Value')}, min([point1(1) point2(1)]),max([point1(1) point2(1)]), true,false};
            end

            if any(strcmp(BurstData{file}.NameArray{param_y},ExistingCuts(:,1)))
                BurstData{file}.Cut{species(1),species(2)}{strcmp(BurstData{file}.NameArray{param_y},ExistingCuts(:,1))} = {BurstData{file}.NameArray{get(h.ParameterListY,'Value')}, min([point1(2) point2(2)]),max([point1(2) point2(2)]), true,false};
            else
                BurstData{file}.Cut{species(1),species(2)}{end+1} = {BurstData{file}.NameArray{get(h.ParameterListY,'Value')}, min([point1(2) point2(2)]),max([point1(2) point2(2)]), true,false};
            end
        else
            BurstData{file}.Cut{species(1),species(2)}{end+1} = {BurstData{file}.NameArray{get(h.ParameterListX,'Value')}, min([point1(1) point2(1)]),max([point1(1) point2(1)]), true,false};
            BurstData{file}.Cut{species(1),species(2)}{end+1} = {BurstData{file}.NameArray{get(h.ParameterListY,'Value')}, min([point1(2) point2(2)]),max([point1(2) point2(2)]), true,false};
        end

        %%% If a change was made to the GlobalCuts Species, update all other
        %%% existent species with the changes
        if species(2) == 1
            if numel(BurstData{file}.Cut) > 1 %%% Check if there are other species defined
                ChangedParamX = BurstData{file}.NameArray{get(h.ParameterListX,'Value')};
                ChangedParamY = BurstData{file}.NameArray{get(h.ParameterListY,'Value')};
                GlobalParams = vertcat(BurstData{file}.Cut{species(1),1}{:});
                GlobalParams = GlobalParams(1:numel(BurstData{file}.Cut{species(1),1}),1);
                %%% cycle through the number of other species
                num_species = sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
                for j = 2:num_species
                    %%% Check if the parameter already exists in the species j
                    ParamList = vertcat(BurstData{file}.Cut{species(1),j}{:});
                    if ~isempty(ParamList)
                        ParamList = ParamList(1:numel(BurstData{file}.Cut{species(1),j}),1);
                        CheckParam = strcmp(ParamList,ChangedParamX);
                        if any(CheckParam)
                            %%% Parameter added or changed
                            %%% Override the parameter with GlobalCut
                            BurstData{file}.Cut{species(1),j}(CheckParam) = BurstData{file}.Cut{species(1),1}(strcmp(GlobalParams,ChangedParamX));
                        else %%% Parameter is new to GlobalCut
                            BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(strcmp(GlobalParams,ChangedParamX));
                        end
                    else %%% Parameter is new to GlobalCut
                        BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(strcmp(GlobalParams,ChangedParamX));
                    end
                end
                for j = 2:num_species
                    %%% Check if the parameter already exists in the species j
                    ParamList = vertcat(BurstData{file}.Cut{species(1),j}{:});
                    if ~isempty(ParamList)
                        ParamList = ParamList(1:numel(BurstData{file}.Cut{species(1),j}),1);
                        CheckParam = strcmp(ParamList,ChangedParamY);
                        if any(CheckParam)
                            %%% Parameter added or changed
                            %%% Override the parameter with GlobalCut
                            BurstData{file}.Cut{species(1),j}(CheckParam) = BurstData{file}.Cut{species(1),1}(strcmp(GlobalParams,ChangedParamY));
                        else %%% Parameter is new to GlobalCut
                            BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(strcmp(GlobalParams,ChangedParamY));
                        end
                    else %%% Parameter is new to GlobalCut
                        BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(strcmp(GlobalParams,ChangedParamY));
                    end
                end
            end
        end
    case h.ArbitraryCutButton
        %%% enable imfreehand
        roi = imfreehand(h.axes_general);
        %%% wait till double click
        wait(roi);
        if ~roi.isvalid
            return;
        end
        %%% make mask
        mask = createMask(roi,BurstMeta.Plots.Main_Plot(1));
        if strcmp(h.ArbitraryCutInvertCheckbox.Checked,'on')
            mask = 1-mask;
        end
        %%% delete roi
        delete(roi);
        
        %%% we need to store the current plot state to recall the arbitrary cut later
        % add it in any way to the selected species
        % additional field contains a structure with parameter names, plot boundaries and mask
        name = ['AR: ' BurstData{file}.NameArray{get(h.ParameterListX,'Value')} '/' BurstData{file}.NameArray{get(h.ParameterListY,'Value')}];
        BurstData{file}.Cut{species(1),species(2)}{end+1} = {name, NaN, NaN, true,false};
        BurstData{file}.ArbitraryCut{species(1),species(2)}{numel(BurstData{file}.Cut{species(1),species(2)})} = struct('ParamX',BurstData{file}.NameArray{get(h.ParameterListX,'Value')},'ParamY',BurstData{file}.NameArray{get(h.ParameterListY,'Value')},...
            'Mask',mask,'LimX',h.axes_general.XLim,'LimY',h.axes_general.YLim);
        
        %%% If a change was made to the GlobalCuts Species, add arbitrary cut to all other
        %%% existent species with the changes
        if species(2) == 1
            CutData = BurstData{file}.Cut{species(1),species(2)}(end);
            ARCutData = BurstData{file}.ArbitraryCut{species(1),species(2)}(end);
            if numel(BurstData{file}.Cut) > 1 %%% Check if there are other species defined
                %%% cycle through the number of other species
                num_species = sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
                for j = 2:num_species
                    %%% add arbitrary cut
                    BurstData{file}.Cut{species(1),j}(end+1) = CutData;
                    BurstData{file}.ArbitraryCut{species(1),j}(numel(BurstData{file}.Cut{species(1),j})) = ARCutData;
                end
            end
        end
        
end
UpdateCutTable(h);
UpdateCuts();

UpdatePlot([],[],h);
UpdateLifetimePlots([],[],h);
PlotLifetimeInd([],[],h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Executes on key press on main axis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BurstBrowser_KeyPress(obj,eventdata)
h = guidata(obj);
if ~isempty(eventdata.Modifier)
    switch eventdata.Modifier{1}
        case 'control'
            %%% File Menu Controls
            switch eventdata.Key
                case 'n'
                    %%% Load File
                    Load_Burst_Data_Callback([],[])
                case 's'
                    %%% Save Analysis State
                    Save_Analysis_State_Callback([],[])
                case 'q'
                    %%% Close Application
                    Close_BurstBrowser([],[])
                case 'space'
                    %%% Manual Cut
                     ManualCut(h.CutButton,[])
                case 't'
                    %%% open notepad
                    Open_Notepad([],[])
                case 'c'
                    %%% Copy currently selected x-parameter to clipboard
                    Param_to_clip([],[]);
            end
    end
else
    switch eventdata.Key
        case 'space' %%% arbitrary cut
            ManualCut(h.ArbitraryCutButton,[])
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates/Initializes the Cut Table in GUI with stored Cuts  %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateCutTable(h)
global BurstData BurstMeta
file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;

if all(species == [0,0])
    data = {'','','',false,false};
    %rownames = {''};
else
    if ~isempty(BurstData{file}.Cut{species(1),species(2)})
        data = vertcat(BurstData{file}.Cut{species(1),species(2)}{:});
        data(:,1) = cellfun(@(x) ['<html><font size=4><b>' x '</b></font></html>'],data(:,1),'UniformOutput',false);
        %rownames = data(:,1);
        %data = data(:,2:end);
    else %data has been deleted, reset to default values
        data = {'','','',false,false};
        %rownames = {''};
    end
end

if size(data,1) == size(h.CutTable.Data,1)
    h.CutTable.Data(:,1:5) = data;
elseif size(data,1) < size(h.CutTable.Data,1) 
    h.CutTable.Data = [data, h.CutTable.Data(1:size(data,1),6)];
elseif size(data,1) > size(h.CutTable.Data,1)
    h.CutTable.Data = [data, vertcat(h.CutTable.Data(:,6),num2cell(false(size(data,1)-size(h.CutTable.Data,1),1)))];
end
%h.CutTable.RowName = rownames;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Applies Cuts to Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Valid, Data] = UpdateCuts(species,file)
global BurstData BurstMeta
%%% If no species is specified, read out selected species.
if nargin == 0
    file = BurstMeta.SelectedFile;
    species = BurstData{file}.SelectedSpecies;
end
if nargin < 2 % no file specified
    file = BurstMeta.SelectedFile;
end

Valid = true(size(BurstData{file}.DataArray,1),1);

if ~all(species == [0,0])
    CutState = vertcat(BurstData{file}.Cut{species(1),species(2)}{:});
    if ~isempty(CutState) %%% only proceed if there are elements in the CutTable
        for i = 1:size(CutState,1)
            if CutState{i,4} == 1 %%% only if the Cut is set to "active"
                if ~strcmp(CutState{i,1}(1:4),'AR: ') %%% if not arbitrary cut
                    Index = (strcmp(CutState(i,1),BurstData{file}.NameArray));
                    Valid = Valid & (BurstData{file}.DataArray(:,Index) >= CutState{i,2}) & (BurstData{file}.DataArray(:,Index) <= CutState{i,3});
                else %%% arbitrary cut
                    ARCutState = BurstData{file}.ArbitraryCut{species(1),species(2)}{i};
                    [nbinsY, nbinsX] = size(ARCutState.Mask);
                    mask = ARCutState.Mask(:);
                    %%% read out parameters used for arbitrary cut
                    IndexX = (strcmp(ARCutState.ParamX,BurstData{file}.NameArray));
                    IndexY = (strcmp(ARCutState.ParamY,BurstData{file}.NameArray));
                    parX = BurstData{file}.DataArray(:,IndexX);
                    parY = BurstData{file}.DataArray(:,IndexY);
                    %%% filter out-of-bounds data
                    valid_bounds = (parX >= ARCutState.LimX(1)) & (parX <= ARCutState.LimX(2)) &...
                        (parY >= ARCutState.LimY(1)) & (parY <= ARCutState.LimY(2));
                    %%% histogram data to apply mask
                    [~,~,~,~,~, bin] = calc2dhist(parX(valid_bounds),parY(valid_bounds),[nbinsX,nbinsY],ARCutState.LimX,ARCutState.LimY);

                    valid_mask = mask(sub2ind(size(ARCutState.Mask),bin(:,1),bin(:,2)));
                    valid_bounds(valid_bounds) = valid_mask;

                    Valid = Valid & valid_bounds;
                end
            end
        end
    end
    if strcmp(BurstData{file}.SpeciesNames{species(1),1}(1:min([end,5])),'Fit: ')%%% check if fit species was selected
        %%% read out additonal cuts from stored variable
        Valid = Valid & BurstData{file}.FitCut{species(1),species(2)};
    end
end

Data = BurstData{file}.DataArray(Valid,:);

if nargout == 0 %%% Only update global Variable if no output is requested!
    BurstData{file}.Selected = Valid;
    BurstData{file}.DataCut = Data;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Callback of CutSelection Popupmenu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateCutDatabase(obj,eventData)
global UserValues BurstData BurstMeta
h = guidata(obj);

if ~isempty(BurstData)
    %%% check burst method
    %%% 1 for 2color, 2 for 3color
    switch BurstData{BurstMeta.SelectedFile}.BAMethod
        case {1,2,5}
            BAMethod = 1;
        case {3,4}
            BAMethod = 2;
    end
else %%% fall back to 2C
    BAMethod = 1;
end

switch obj
    case {h.ApplyCutDatabase, h.AddCutDatabase} %%% button was clicked
        %%% check if cuts are available
        if isempty(fieldnames(UserValues.BurstBrowser.CutDatabase{BAMethod}))
            disp('No cuts stored!');
            return;
        end
        %%% read out cut
        cutName = h.CutDatabase.String{h.CutDatabase.Value};
        cutToApply = UserValues.BurstBrowser.CutDatabase{BAMethod}.(cutName);
        switch obj
            case h.ApplyCutDatabase
                %%% apply to selected species
                if ~h.MultiselectOnCheckbox.UserData
                    file_n = BurstMeta.SelectedFile;
                    species_n = BurstData{file_n}.SelectedSpecies(1);
                    subspecies_n = BurstData{file_n}.SelectedSpecies(2);
                else
                    [file_n,species_n,subspecies_n] = get_multiselection(h);
                end
                for f = 1:numel(file_n)
                    file = file_n(f);
                    species = [species_n(f), subspecies_n(f)];
                    for i = 1:numel(cutToApply)
                        paramName  = cutToApply{i}{1};
                        %%% Check whether the CutParameter already exists or not
                        ExistingCuts = vertcat(BurstData{file}.Cut{species(1),species(2)}{:});
                        paramExists = false;
                        if ~isempty(ExistingCuts)
                            if any(strcmp(paramName,ExistingCuts(:,1)))
                                paramExists = find(strcmp(paramName,ExistingCuts(:,1)));
                            else
                                paramExists = false;
                            end
                        end
                        if paramExists
                            %%% override boundaries
                            BurstData{file}.Cut{species(1),species(2)}{paramExists}{2} = cutToApply{i}{2};
                            BurstData{file}.Cut{species(1),species(2)}{paramExists}{3} = cutToApply{i}{3};
                        else
                            %%% append to Cut Array
                            BurstData{file}.Cut{species(1),species(2)}{end+1} = cutToApply{i};
                        end

                        %%% If Global Cuts, Update all other species
                        if species(2) == 1
                            ChangedParameterName = paramName;
                            %%% find number of species for species group
                            num_species = sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
                            if num_species > 1 %%% Check if there are other species defined
                                %%% cycle through the number of other species
                                for j = 2:num_species
                                    %%% Check if the parameter already exists in the species j
                                    ParamList = vertcat(BurstData{file}.Cut{species(1),j}{:});
                                    if ~isempty(ParamList)
                                        ParamList = ParamList(1:numel(BurstData{file}.Cut{species(1),j}),1);
                                        CheckParam = strcmp(ParamList,ChangedParameterName);
                                        if any(CheckParam)
                                            %%% do nothing
                                        else %%% Parameter is new to species
                                            BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(end);
                                        end
                                    else %%% Parameter is new to GlobalCut
                                        BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(end);
                                    end
                                end
                            end
                        end
                    end
                end
            case h.AddCutDatabase
                file = BurstMeta.SelectedFile;
                %%% add a new top level species
                BurstData{file}.SpeciesNames{end+1,1} = cutName;
                BurstData{file}.Cut{end+1,1} = cutToApply;
                UpdateSpeciesList(h);
        end
        %%% Update Cuts
        UpdateCutTable(h);
        UpdateCuts();
        
        %%% Update Plot
        UpdatePlot([],[],h);
        UpdateLifetimePlots([],[],h);
    case h.RemoveCutDatabase_Menu
        %%% check if cuts are available
        if isempty(fieldnames(UserValues.BurstBrowser.CutDatabase{BAMethod}))
            disp('No cuts stored!');
            return;
        end
        %%% remove field from database
        currentCut = h.CutDatabase.String{h.CutDatabase.Value};
        UserValues.BurstBrowser.CutDatabase{BAMethod} = rmfield(UserValues.BurstBrowser.CutDatabase{BAMethod},currentCut);
        %%% Refresh GUI
        if ~isempty(fieldnames(UserValues.BurstBrowser.CutDatabase{BAMethod}))
            h.CutDatabase.String = fieldnames(UserValues.BurstBrowser.CutDatabase{BAMethod});
        else
            h.CutDatabase.String = '-';
        end
        LSUserValues(1);
    case h.StoreInCutDatabase_Menu %%% add cut to database
        file = BurstMeta.SelectedFile;
        species = BurstData{file}.SelectedSpecies;
        if all(species == [0,0])
            return;
        end
        %%% query name
        CutName = inputdlg('Specify the new cut name:','Adding cut to database...',[1 50],{'New Cut'},'on');
        if ~isempty(CutName)
            CutName = CutName{1};
            CutName = matlab.lang.makeValidName(CutName); %%% make it a valid variable name
            Cut = BurstData{file}.Cut{species(1),species(2)}; %%% read out the cut
            del = false(size(Cut));
            for i = 1:numel(Cut) %%% remove Arbitrary Region cuts
                if strcmp(Cut{i}{1}(1:4),'AR: ')
                    del(i) = true;
                end
            end
            Cut(del) = [];
            UserValues.BurstBrowser.CutDatabase{BAMethod}.(CutName) = Cut;
        end
        %%% Refresh GUI
        h.CutDatabase.String = fieldnames(UserValues.BurstBrowser.CutDatabase{BAMethod});
        LSUserValues(1);
    case h.PrintDatabaseCut_Menu
        %%% read out cut
        cutName = h.CutDatabase.String{h.CutDatabase.Value};
        %%% print output
        disp(sprintf('Cuts for database entry:\t%s',cutName));
        currentCut = UserValues.BurstBrowser.CutDatabase{BAMethod}.(cutName);
        currentCut = vertcat(currentCut{:});
        currentCut = currentCut(:,1:3);
        output = table(currentCut(:,1),cell2mat(currentCut(:,2)),cell2mat(currentCut(:,3)),'VariableNames',{'Parameter','min','max'});
        str = evalc('disp(output)');
        disp(str);
        str = strrep(str,'<strong>','');str = strrep(str,'</strong>','');
        msgbox(str,cutName);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Applies Cuts to all Loaded files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ApplyCutsToLoaded(obj,~)
global BurstMeta BurstData
h = guidata(obj);
file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;
if species(2) > 1
    disp('Only implemented for top level species');
    return;
end
speciesname = BurstData{file}.SpeciesNames{species(1),species(2)};
%%% read out cuts of currently selected species
currentCuts = BurstData{file}.Cut{species(1),species(2)};
%%% Synchronize all other top-level species
for i = 1:numel(BurstData)
    if i == file
        continue;
    end
    %%% Check if species with same name exists
    if any(strcmp(BurstData{i}.SpeciesNames(:,1),speciesname))
        targetSpecies = strcmp(BurstData{i}.SpeciesNames(:,1),speciesname);
        for j = 1:numel(currentCuts)
            %%% Check if the parameter already exists in the species j
            ParamList = vertcat(BurstData{i}.Cut{targetSpecies,1}{:});
            if ~isempty(ParamList)
                ParamList = ParamList(:,1);
                CheckParam = strcmp(ParamList,currentCuts{j}{1});
                if any(CheckParam) %%% parameter exists
                    %%% overwrite limits and active state
                    BurstData{i}.Cut{targetSpecies,1}{CheckParam}(2:4) = currentCuts{j}(2:4);
                else
                    %%% parameter is new
                    BurstData{i}.Cut{targetSpecies,1}(end+1) = currentCuts(j);
                end
            else %%% parameter is new
                BurstData{i}.Cut{targetSpecies,1}(end+1) = currentCuts(j);
            end
        end
    else %%% add a species with this name
        BurstData{i}.Cut{end+1,1} = currentCuts;
        BurstData{i}.SpeciesNames{end+1,1} = speciesname;
        BurstData{i}.SelectedSpecies = [size(BurstData{i}.SpeciesNames,1),1];
    end
end

UpdateSpeciesList(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Executes on change in the Cut Table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Cut Array and GUI/Plots     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CutTableChange(hObject,eventdata)
%this executes if a value in the CutTable is changed
h = guidata(hObject);
global BurstData BurstMeta
%check which cell was changed
index = eventdata.Indices;
index(2) = index(2)-1; %%% lower by one since we changed the parameter name to be in first column
file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies; % in the DataTree

%read out the parameter name
ChangedParameterName = BurstData{file}.Cut{species(1),species(2)}{index(1)}{1};
%change value in structure
NewData = eventdata.NewData;
if isnan(NewData)
    hObject.Data{eventdata.Indices(1),eventdata.Indices(2)} = eventdata.PreviousData;
    return;
end
switch index(2)
    case {1} %min boundary was changed
        %%% if upper boundary is lower than new min boundary -> reject
        if BurstData{file}.Cut{species(1),species(2)}{index(1)}{3} < NewData
            NewData = eventdata.PreviousData;
        end
        if species(2) ~= 1
            %%% if new lower boundary is lower than global lower boundary -->
            %%% reset to global lower boundary
            if ~isempty(BurstData{file}.Cut{species(1),1})
                %%% check whether the parameter exists in global cuts
                %%% already
                for l = 1:numel(BurstData{file}.Cut{species(1),1})
                    exist(l) = strcmp(BurstData{file}.Cut{species(1),1}{l}{1},BurstData{file}.Cut{species(1),species(2)}{index(1)}{1});
                end
                if any(exist == 1)
                    if NewData <= BurstData{file}.Cut{species(1)}{exist}{index(2)+1}
                        NewData = BurstData{file}.Cut{species(1)}{exist}{index(2)+1};
                    end
                end
            end
        end
    case {2} %max boundary was changed
        %%% if lower boundary is higher than new upper boundary --> reject
        if BurstData{file}.Cut{species(1),species(2)}{index(1)}{2} > NewData
            NewData = eventdata.PreviousData;
        end
        if species(2) ~= 1
            %%% if new upper boundary is higher than global upper boundary -->
            %%% reset to global upper boundary
            if ~isempty(BurstData{file}.Cut{species(1),1})
                %%% check whether the parameter exists in global cuts
                %%% already
                for l = 1:numel(BurstData{file}.Cut{species(1),1})
                    exist(l) = strcmp(BurstData{file}.Cut{species(1),1}{l}{1},BurstData{file}.Cut{species(1),species(2)}{index(1)}{1});
                end
                if any(exist == 1)
                    if NewData >= BurstData{file}.Cut{species(1),1}{exist}{index(2)+1}
                        NewData = BurstData{file}.Cut{species(1),1}{exist}{index(2)+1};
                    end
                end
            end
        end
    case {3} %active/inactive change
        % unchanged
    case {5} % ZScale was changed
        %%% disable all other active components
        for i = 1:size(hObject.Data)
            if i ~= index(1)
                hObject.Data{i,6} = false;
            end
        end
        %%% if arbitrary cut was clicked, prevent checking 
        if strcmp(ChangedParameterName(1:4),'AR: ')
            hObject.Data{index(1),6} = false;
        end
end

if index(2) < 4
    % assign the new value
    BurstData{file}.Cut{species(1),species(2)}{index(1)}{index(2)+1}=NewData;
elseif index(2) == 4 %delete this entry
    BurstData{file}.Cut{species(1),species(2)}(index(1)) = [];
    try
        BurstData{file}.ArbitraryCut{species(1),species(2)}(index(1)) = [];
    end
end

%%% If a change was made to the GlobalCuts Species, update all other
%%% existent species with the changes
if species(2) == 1
    %%% find number of species for species group
    num_species = sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
    if  num_species > 1 %%% Check if there are other species defined
        %%% cycle through the number of other species
        for j = 2:num_species
            %%% Check if the parameter already exists in the species j
            ParamList = vertcat(BurstData{file}.Cut{species(1),j}{:});
            if ~isempty(ParamList)
                ParamList = ParamList(1:numel(BurstData{file}.Cut{species(1),j}),1);
                CheckParam = strcmp(ParamList,ChangedParameterName);
                if any(CheckParam)
                    %%% Check whether to delete or change the parameter
                    if index(2) ~= 4 %%% Parameter added or changed
                        %%% Override the parameter with GlobalCut
                        %%% But only if it affects the boundaries of the
                        %%% species!
                        switch index(2)
                            case 1 %%% lower boundary changed
                                %%% If new global lower boundary is above
                                %%% species lower boundary, update
                                if BurstData{file}.Cut{species(1),1}{index(1)}{index(2)+1} > BurstData{file}.Cut{species(1),j}{CheckParam}{index(2)+1}
                                    BurstData{file}.Cut{species(1),j}{CheckParam}(index(2)+1) = BurstData{file}.Cut{species(1),1}{index(1)}(index(2)+1);
                                end
                            case 2 %%% upper boundary changed
                                %%% If new global upper boundary is below
                                %%% species upper boundary, update
                                if BurstData{file}.Cut{species(1),1}{index(1)}{index(2)+1} < BurstData{file}.Cut{species(1),j}{CheckParam}{index(2)+1}
                                    BurstData{file}.Cut{species(1),j}{CheckParam}(index(2)+1) = BurstData{file}.Cut{species(1),1}{index(1)}(index(2)+1);
                                end
                            case 3 %%% active changed
                                BurstData{file}.Cut{species(1),j}{CheckParam}(index(2)+1) = BurstData{file}.Cut{species(1),1}{index(1)}(index(2)+1);
                        end
                    elseif index(2) == 4 %%% Parameter was deleted
                        BurstData{file}.Cut{species(1),j}(CheckParam) = [];
                        try
                            BurstData{file}.ArbitraryCut{species(1),j}(CheckParam) = [];
                        end
                    end
                else %%% Parameter is new to species
                    if index(2) ~= 4 %%% Parameter added or changed
                        BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(index(1));
                    end
                end
            else %%% Parameter is new to GlobalCut
                if ~strcmp(ChangedParameterName(1:4),'AR: ') %%% make sure it is not an arbitrary selection
                    BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(index(1));
                end
            end
        end
    end
end

%%% Update GUI elements
UpdateCutTable(h);
UpdateCuts();

%%% Update Plots
%%% To speed up, find out which tab is visible and only update the respective tab
switch h.Main_Tab.SelectedTab
    case h.Main_Tab_General
        %%% we switched to the general tab
        UpdatePlot([],[],h);
    case h.Main_Tab_Lifetime
        %%% we switched to the lifetime tab
        %%% figure out what subtab is selected
        UpdateLifetimePlots([],[],h);
        switch h.LifetimeTabgroup.SelectedTab
            case h.LifetimeTabAll
            case h.LifetimeTabInd
                PlotLifetimeInd([],[],h);
        end     
end

function AddDerivedParameters(~,~,h)
global BurstData BurstMeta
file = BurstMeta.SelectedFile;

%% Add/Update distance (from intensity), E (from lifetime) and distance (from lifetime) entries
if any(BurstData{file}.BAMethod == [1,2,5]) % 2-color MFD
    %No. of Photons (GX) and Countrate (GX)
    if ~sum(strcmp(BurstData{file}.NameArray,'Number of Photons (DX)'))
        BurstData{file}.NameArray{end+1} = 'Number of Photons (DX)';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DX)')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DD)')) + BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'));
    
    if ~sum(strcmp(BurstData{file}.NameArray,'Count rate (DX) [kHz]'))
        BurstData{file}.NameArray{end+1} = 'Count rate (DX) [kHz]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Count rate (DX) [kHz]')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DX)')) ./ BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Duration [ms]'));
         
    % distance (from intensity)
    if ~sum(strcmp(BurstData{file}.NameArray,'Distance (from intensity) [A]'))
        BurstData{file}.NameArray{end+1} = 'Distance (from intensity) [A]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
    E(E<0 | E>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadius;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance (from intensity) [A]')) = ((1./E-1).*R0^6).^(1/6);
    % E (from lifetime)
    if ~sum(strcmp(BurstData{file}.NameArray,'FRET efficiency (from lifetime)'))
        BurstData{file}.NameArray{end+1} = 'FRET efficiency (from lifetime)';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    tauDA = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'));
    tauD = BurstData{file}.Corrections.DonorLifetime;
    El = 1-tauDA./tauD;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET efficiency (from lifetime)')) = El;
    
    % distance (from lifetime)
    if ~sum(strcmp(BurstData{file}.NameArray,'Distance (from lifetime) [A]'))
        BurstData{file}.NameArray{end+1} = 'Distance (from lifetime) [A]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    El(El<0 | El>1) = NaN;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance (from lifetime) [A]')) = ((1./El-1).*R0^6).^(1/6);
    
    %FRET from sensitized acceptor emission
    if ~sum(strcmp(BurstData{file}.NameArray,'FRET efficiency (sens. Acc. Em.)'))
        BurstData{file}.NameArray{end+1} = 'FRET efficiency (sens. Acc. Em.)';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    E_A = BurstData{file}.Corrections.Beta_GR*BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'))./BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (AA)'));
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET efficiency (sens. Acc. Em.)')) = E_A;
elseif any(BurstData{file}.BAMethod == [3,4]) % 3-color MFD
     %No. of Photons (GX) and Countrate (GX)
    if ~sum(strcmp(BurstData{file}.NameArray,'Number of Photons (GX)'))
        BurstData{file}.NameArray{end+1} = 'Number of Photons (GX)';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (GX)')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (GG)')) + BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (GR)'));
    
    if ~sum(strcmp(BurstData{file}.NameArray,'Count rate (GX) [kHz]'))
        BurstData{file}.NameArray{end+1} = 'Count rate (GX) [kHz]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Count rate (GX) [kHz]')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (GX)')) ./ BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Duration [ms]'));
    %No. of Photons (BX) and Countrate (BX)
    if ~sum(strcmp(BurstData{file}.NameArray,'Number of Photons (BX)'))
        BurstData{file}.NameArray{end+1} = 'Number of Photons (BX)';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (BX)')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (BB)')) + BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (BG)')) + BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (BR)'));
    
    if ~sum(strcmp(BurstData{file}.NameArray,'Count rate (BX) [kHz]'))
        BurstData{file}.NameArray{end+1} = 'Count rate (BX) [kHz]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Count rate (BX) [kHz]')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (BX)')) ./ BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Duration [ms]'));
    
    % GR distance (from intensity)
    if ~sum(strcmp(BurstData{file}.NameArray,'Distance GR (from intensity) [A]'))
        BurstData{file}.NameArray{end+1} = 'Distance GR (from intensity) [A]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end 
    EGR = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency GR'));
    EGR(EGR<0 | EGR>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadius;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance GR (from intensity) [A]')) = ((1./EGR-1).*R0^6).^(1/6);
    
    % E GR (from lifetime)
    if ~sum(strcmp(BurstData{file}.NameArray,'FRET efficiency GR (from lifetime)'))
        BurstData{file}.NameArray{end+1} = 'FRET efficiency GR (from lifetime)';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    tauDA = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime GG [ns]'));
    tauD = BurstData{file}.Corrections.DonorLifetime;
    El = 1-tauDA./tauD;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET efficiency GR (from lifetime)')) = El;

    % distance GR (from lifetime)
    if ~sum(strcmp(BurstData{file}.NameArray,'Distance GR (from lifetime) [A]'))
        BurstData{file}.NameArray{end+1} = 'Distance GR (from lifetime) [A]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    El(El<0 | El>1) = NaN;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance GR (from lifetime) [A]')) = ((1./El-1).*R0^6).^(1/6);
    
    % BG distance (from intensity)
    if ~sum(strcmp(BurstData{file}.NameArray,'Distance BG (from intensity) [A]'))
        BurstData{file}.NameArray{end+1} = 'Distance BG (from intensity) [A]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    EBG= BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency BG'));
    EBG(EBG<0 | EBG>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadiusBG;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance BG (from intensity) [A]')) = ((1./EBG-1).*R0^6).^(1/6);
    % BR distance (from intensity)
    if ~sum(strcmp(BurstData{file}.NameArray,'Distance BR (from intensity) [A]'))
        BurstData{file}.NameArray{end+1} = 'Distance BR (from intensity) [A]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    EBR = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency BR'));
    EBR(EBR<0 | EBR>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadiusBR;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance BR (from intensity) [A]')) = ((1./EBR-1).*R0^6).^(1/6);
end
if isfield(BurstData{file},'AdditionalParameters')
    %%% Add diffusion time/diffusion coefficient
    if isfield(BurstData{file}.AdditionalParameters,'tauD')
        if ~sum(strcmp(BurstData{file}.NameArray,'Diffusion time [ms]'))
            BurstData{file}.NameArray{end+1} = 'Diffusion time [ms]';
            BurstData{file}.DataArray(:,end+1) = 0;
        end
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Diffusion time [ms]')) = BurstData{file}.AdditionalParameters.tauD./1E-3;
    end
    if isfield(BurstData{file}.AdditionalParameters,'DiffusionCoefficient')
        if ~sum(strcmp(BurstData{file}.NameArray,'Diffusion coefficient [mum2/s]'))
            BurstData{file}.NameArray{end+1} ='Diffusion coefficient [mum2/s]';
            BurstData{file}.DataArray(:,end+1) = 0;
        end
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Diffusion coefficient [mum2/s]')) = BurstData{file}.AdditionalParameters.DiffusionCoefficient;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Determine Corrections (alpha, beta, gamma from intensity) %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineCorrections(obj,~)
global BurstData BurstMeta UserValues
LSUserValues(0);
h = guidata(obj);

file = BurstMeta.SelectedFile;

h.Main_Tab.SelectedTab = h.Main_Tab_Corrections;
%%% Change focus to CorrectionsTab
switch BurstData{file}.BAMethod
    case {1,2,5}
        indS = find(strcmp(BurstData{file}.NameArray,'Stoichiometry (raw)'));
        indE = find(strcmp(BurstData{file}.NameArray,'Proximity Ratio'));
        indNGG = find(strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'));
        indNGR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'));
        indNRR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (AA)'));
    case {3,4}
        indS = find(strcmp(BurstData{file}.NameArray,'Stoichiometry GR'));
        indE = find(strcmp(BurstData{file}.NameArray,'Proximity Ratio GR'));
        indNGG = find(strcmp(BurstData{file}.NameArray,'Number of Photons (GG)'));
        indNGR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (GR)'));
        indNRR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (RR)'));
end
%indE = find(strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
indDur = find(strcmp(BurstData{file}.NameArray,'Duration [ms]'));


%%% Read out corrections
if ~(BurstData{file}.BAMethod == 5) %%% MFD
    Background_GR = BurstData{file}.Background.Background_GRpar + BurstData{file}.Background.Background_GRperp;
    Background_GG = BurstData{file}.Background.Background_GGpar + BurstData{file}.Background.Background_GGperp;
    Background_RR = BurstData{file}.Background.Background_RRpar + BurstData{file}.Background.Background_RRperp;
elseif BurstData{file}.BAMethod == 5
    Background_GR = BurstData{file}.Background.Background_GRpar;
    Background_GG = BurstData{file}.Background.Background_GGpar;
    Background_RR = BurstData{file}.Background.Background_RRpar;
end

%% 2cMFD Corrections
%% Crosstalk and direct excitation
if obj == h.DetermineCorrectionsButton
    %%% read raw data
    if ~h.MultiselectOnCheckbox.UserData
        data_for_corrections = BurstData{file}.DataArray;
    else
        Files = get_multiselection(h);
        Files = unique(Files);
        data_for_corrections = cell(numel(Files),1);
        for i = 1:numel(Files)
            data_for_corrections{i} = BurstData{Files(i)}.DataArray;
        end
        data_for_corrections = vertcat(data_for_corrections{:});
        %%% (Note for the future: We are assuming here that all files have the
        %%% same order of parameters in NameArray...)
    end
    %% plot raw FRET Efficiency for S>0.9
    x_axis = linspace(-0.1,0.3,120);
    Smin = UserValues.BurstBrowser.Settings.S_Donly_Min;
    Smax = UserValues.BurstBrowser.Settings.S_Donly_Max;
    S_threshold = (data_for_corrections(:,indS)>Smin) & (data_for_corrections(:,indS)<Smax);
    NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
    NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
    
    E_raw = NGR./(NGR+NGG);
    histE_donly = histc(E_raw,x_axis);
    x_axis = x_axis(1:end-1);
    histE_donly(end-1) = histE_donly(end-1)+histE_donly(end);
    histE_donly(end) = [];
    BurstMeta.Plots.histE_donly.XData = x_axis;
    BurstMeta.Plots.histE_donly.YData = histE_donly;
    axis(h.Corrections.TwoCMFD.axes_crosstalk,'tight');
    h.Corrections.TwoCMFD.axes_crosstalk.XLabel.String = 'Proximity Ratio';
    h.Corrections.TwoCMFD.axes_crosstalk.Title.String = 'Proximity Ratio of Donor only';
    %fit single gaussian
    [mean_ct, GaussFit] = GaussianFit(x_axis',histE_donly);
    BurstMeta.Plots.Fits.histE_donly(1).XData = x_axis;
    BurstMeta.Plots.Fits.histE_donly(1).YData = GaussFit;
    ct = mean_ct/(1-mean_ct);
    if ~isnan(ct) && (ct > 0)
        UserValues.BurstBrowser.Corrections.CrossTalk_GR = ct;
    end
    
    if ~h.MultiselectOnCheckbox.UserData
        BurstData{file}.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
    else %%% Update for all files contributing
        Files = get_multiselection(h);
        for i = 1:numel(Files)
            BurstData{Files(i)}.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
        end
    end
    %% plot raw data for S < 0.25 for direct excitation
    Smin = UserValues.BurstBrowser.Settings.S_Aonly_Min;
    Smax = UserValues.BurstBrowser.Settings.S_Aonly_Max;
    Emin = UserValues.BurstBrowser.Settings.E_Aonly_Min;
    x_axis = linspace(Smin,Smax,100);
    S_threshold = (data_for_corrections(:,indS)<Smax) & (data_for_corrections(:,indS)>Smin) & ...
        (data_for_corrections(:,indE)>Emin);
    NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
    NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
    NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
    S_raw = (NGG+NGR)./(NGG+NGR+NRR);
    histS_aonly = histc(S_raw,x_axis);
    x_axis = x_axis(1:end-1);
    histS_aonly(end-1) = histS_aonly(end-1)+histS_aonly(end);
    histS_aonly(end) = [];
    BurstMeta.Plots.histS_aonly.XData = x_axis;
    BurstMeta.Plots.histS_aonly.YData = histS_aonly;
    axis(h.Corrections.TwoCMFD.axes_direct_excitation,'tight');
    h.Corrections.TwoCMFD.axes_direct_excitation.XLabel.String = 'Stoichiometry (raw)';
    h.Corrections.TwoCMFD.axes_direct_excitation.Title.String = 'Raw Stoichiometry of Acceptor only';
    %fit single gaussian
    [mean_de, GaussFit] = GaussianFit(x_axis',histS_aonly);
    BurstMeta.Plots.Fits.histS_aonly(1).XData = x_axis;
    BurstMeta.Plots.Fits.histS_aonly(1).YData = GaussFit;
    de = mean_de/(1-mean_de);
    if ~isnan(de) && (de > 0)
        UserValues.BurstBrowser.Corrections.DirectExcitation_GR = de;
    end
    if ~h.MultiselectOnCheckbox.UserData
        BurstData{file}.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
    else %%% Update for all files contributing
        Files = get_multiselection(h);
        for i = 1:numel(Files)
            BurstData{Files(i)}.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
        end
    end
end
if any(obj == [h.FitGammaButton, h.DetermineGammaManuallyButton])
    %% plot gamma plot for two populations (or lifetime versus E)
    % use the user selected species
    if ~h.MultiselectOnCheckbox.UserData
        Valid = UpdateCuts();
        %%% Calculate "raw" E and S with gamma = 1, but still apply direct
        %%% excitation,crosstalk, and background corrections!
        NGR = BurstData{file}.DataArray(Valid,indNGR) - Background_GR.*BurstData{file}.DataArray(Valid,indDur);
        NGG = BurstData{file}.DataArray(Valid,indNGG) - Background_GG.*BurstData{file}.DataArray(Valid,indDur);
        NRR = BurstData{file}.DataArray(Valid,indNRR) - Background_RR.*BurstData{file}.DataArray(Valid,indDur);
        NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
    else
        switch BurstData{file}.BAMethod
            case {1,2,5}
                NGR = get_multiselection_data(h,'Number of Photons (DA)');
                NGG = get_multiselection_data(h,'Number of Photons (DD)');
                NRR = get_multiselection_data(h,'Number of Photons (AA)');
            case {3,4}
                NGR = get_multiselection_data(h,'Number of Photons (GR)');
                NGG = get_multiselection_data(h,'Number of Photons (GG)');
                NRR = get_multiselection_data(h,'Number of Photons (RR)');
        end
        dur = get_multiselection_data(h,'Duration [ms]');
        NGR = NGR - Background_GR.*dur;
        NGG = NGG - Background_GG.*dur;
        NRR = NRR - Background_RR.*dur;
        NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
    end
    E_raw = NGR./(NGR+NGG);
    S_raw = (NGG+NGR)./(NGG+NGR+NRR);
    % switch obj
    %     case h.FitGammaButton
    %         [H,xbins,ybins] = calc2dhist(E_raw,1./S_raw,[51 51],[0 1], [1 quantile(1./S_raw,0.99)]);
    %     case h.DetermineGammaManuallyButton
    %         [H,xbins,ybins] = calc2dhist(E_raw,S_raw,[51 51],[0 1], [min(S_raw) max(S_raw)]);
    % end
    [H,xbins,ybins] = calc2dhist(E_raw,S_raw,[51 51],[-0.1 1], [min(S_raw) max(S_raw)]);
    
    BurstMeta.Plots.gamma_fit(1).XData= xbins;
    BurstMeta.Plots.gamma_fit(1).YData= ybins;
    BurstMeta.Plots.gamma_fit(1).CData= H;
    BurstMeta.Plots.gamma_fit(1).AlphaData= (H>0);
    BurstMeta.Plots.gamma_fit(2).XData= xbins;
    BurstMeta.Plots.gamma_fit(2).YData= ybins;
    BurstMeta.Plots.gamma_fit(2).ZData= H/max(max(H));
    BurstMeta.Plots.gamma_fit(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    switch obj
        case h.FitGammaButton
            %%% Update/Reset Axis Labels
            xlabel(h.Corrections.TwoCMFD.axes_gamma,'FRET Efficiency','Color',UserValues.Look.Fore);
            ylabel(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry','Color',UserValues.Look.Fore);
            title(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry vs. FRET Efficiency for gamma = 1','Color',UserValues.Look.Fore);
            %%% store for later use
            BurstMeta.Data.E_raw = E_raw;
            BurstMeta.Data.S_raw = S_raw;
            %%% Fit using E S relation (x is E)
            funS = @(b,g,x) (1+g*b+(1-g)*b*x).^(-1);
            %fitGamma = fit(E_raw,1./S_raw,@(m,b,x) m*x+b,'StartPoint',[1,1],'Robust','LAR');
            fitGamma = fit(E_raw,S_raw,funS,'StartPoint',[1,1],'Robust','LAR');
            BurstMeta.Plots.Fits.gamma.Visible = 'on';
            BurstMeta.Plots.Fits.gamma_manual.Visible = 'off';
            BurstMeta.Plots.Fits.gamma.XData = linspace(-0.1,1,1100);
            BurstMeta.Plots.Fits.gamma.YData = fitGamma(linspace(-0.1,1,1100));
            axis(h.Corrections.TwoCMFD.axes_gamma,'tight');
            xlim(h.Corrections.TwoCMFD.axes_gamma,[-0.1,1]);
            %ylim(h.Corrections.TwoCMFD.axes_gamma,[1,quantile(1./S_raw,0.99)]);

            %%% Determine Gamma and Beta
            coeff = coeffvalues(fitGamma); %m = coeff(1); b = coeff(2);
            beta = coeff(1); gamma = coeff(2);
        case h.DetermineGammaManuallyButton
            axis(h.Corrections.TwoCMFD.axes_gamma,'tight');
            %%% Update Axis Labels
            xlabel(h.Corrections.TwoCMFD.axes_gamma,'FRET Efficiency','Color',UserValues.Look.Fore);
            ylabel(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry','Color',UserValues.Look.Fore);
            title(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry vs. FRET Efficiency for gamma = 1','Color',UserValues.Look.Fore);
            %%% Hide Fit
            BurstMeta.Plots.Fits.gamma.Visible = 'off';
            [e, s] = ginput(2);
            BurstMeta.Plots.Fits.gamma_manual.XData = e;
            BurstMeta.Plots.Fits.gamma_manual.YData = s;
            BurstMeta.Plots.Fits.gamma_manual.Visible = 'on';
            BurstMeta.Plots.Fits.gamma_manual.MarkerEdgeColor = UserValues.BurstBrowser.Display.ColorLine1;
            
            s = 1./s;
            m = (s(2)-s(1))./(e(2)-e(1));
            b = s(2) - m.*e(2);
            
            gamma = (b - 1)/(b + m - 1);
            beta = b+m-1;
    end
    
    UserValues.BurstBrowser.Corrections.Gamma_GR = gamma;
    UserValues.BurstBrowser.Corrections.Beta_GR = beta;
            
    if ~h.MultiselectOnCheckbox.UserData
        BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
        BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
    else %%% Update for all files contributing
        sel_file = BurstMeta.SelectedFile;
        Files = get_multiselection(h);
        for i = 1:numel(Files)
            BurstMeta.SelectedFile = Files(i);
            BurstData{Files(i)}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
            BurstData{Files(i)}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
            ApplyCorrections([],[],h,0);
        end
        BurstMeta.SelectedFile = sel_file;
    end
end
if obj == h.DetermineGammaLifetimeTwoColorButton
    % use the user selected species
    if ~h.MultiselectOnCheckbox.UserData
        Valid = UpdateCuts();

        indTauGG = (strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'));
        tauGG = BurstData{file}.DataArray(Valid,indTauGG);
        
        %%% Calculate "raw" E and S with gamma = 1, but still apply direct
        %%% excitation,crosstalk, and background corrections!
        NGR = BurstData{file}.DataArray(Valid,indNGR) - Background_GR.*BurstData{file}.DataArray(Valid,indDur);
        NGG = BurstData{file}.DataArray(Valid,indNGG) - Background_GG.*BurstData{file}.DataArray(Valid,indDur);
        NRR = BurstData{file}.DataArray(Valid,indNRR) - Background_RR.*BurstData{file}.DataArray(Valid,indDur);
        NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
    else
        NGR = get_multiselection_data(h,'Number of Photons (DA)');
        NGG = get_multiselection_data(h,'Number of Photons (DD)');
        NRR = get_multiselection_data(h,'Number of Photons (AA)');
        dur = get_multiselection_data(h,'Duration [ms]');
        tauGG = get_multiselection_data(h,'Lifetime D [ns]');
        
        NGR = NGR - Background_GR.*dur;
        NGG = NGG - Background_GG.*dur;
        NRR = NRR - Background_RR.*dur;
        NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
    end
    %%% Calculate static FRET line in presence of linker fluctuations
    [FRETline, statFRETfun,tau] = conversion_tau(BurstData{file}.Corrections.DonorLifetime,...
        BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength);
    %staticFRETline = @(x) 1 - (coeff(1).*x.^3 + coeff(2).*x.^2 + coeff(3).*x + coeff(4))./BurstData{file}.Corrections.DonorLifetime;
    %%% minimize deviation from static FRET line as a function of gamma
    valid = (tauGG < BurstData{file}.Corrections.DonorLifetime) & (tauGG > 0.01) & ~isnan(tauGG) & ~isnan(statFRETfun(tauGG));
    %dev = @(gamma) sum( ( ( NGR(valid)./(gamma.*NGG(valid)+NGR(valid)) ) - statFRETfun( tauGG(valid) ) ).^2 );
    %gamma_fit = fmincon(dev,1,[],[],[],[],0,10);
    gamma_fit = fit([NGR(valid),NGG(valid)],statFRETfun(tauGG(valid)), @(gamma,x,y) (x./(gamma.*y+x) ),'StartPoint',1,'Robust','bisquare');
    gamma_fit = coeffvalues(gamma_fit);
    E =  NGR./(gamma_fit.*NGG+NGR);
    %%% plot E versus tau with static FRET line
    [H,xbins,ybins] = calc2dhist(tauGG,E,[51 51],[0 min([max(tauGG) BurstData{file}.Corrections.DonorLifetime+1.5])],[-0.1 1.1]);
    BurstMeta.Plots.gamma_lifetime(1).XData= xbins;
    BurstMeta.Plots.gamma_lifetime(1).YData= ybins;
    BurstMeta.Plots.gamma_lifetime(1).CData= H;
    BurstMeta.Plots.gamma_lifetime(1).AlphaData= (H>0);
    BurstMeta.Plots.gamma_lifetime(2).XData= xbins;
    BurstMeta.Plots.gamma_lifetime(2).YData= ybins;
    BurstMeta.Plots.gamma_lifetime(2).ZData= H/max(max(H));
    BurstMeta.Plots.gamma_lifetime(2).LevelList= linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    %%% add static FRET line
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.Visible = 'on';
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.XData = tau;
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.YData = FRETline;
    ylim(h.Corrections.TwoCMFD.axes_gamma_lifetime,[-0.1 1.1]);
    %%% Update UserValues
    UserValues.BurstBrowser.Corrections.Gamma_GR =gamma_fit;
    if ~h.MultiselectOnCheckbox.UserData
        BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
    else %%% Update for all files contributing
        Files = get_multiselection(h);
        for i = 1:numel(Files)
            BurstData{Files(i)}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
        end
    end
end
if any(BurstData{file}.BAMethod == [3,4])
    %% 3cMFD corrections
    %%% Read out parameter positions
    indSBG = find(strcmp(BurstData{file}.NameArray,'Stoichiometry BG'));
    indSBR = find(strcmp(BurstData{file}.NameArray,'Stoichiometry BR'));
    %%% Read out photon counts
    indNBB = find(strcmp(BurstData{file}.NameArray,'Number of Photons (BB)'));
    indNBG = find(strcmp(BurstData{file}.NameArray,'Number of Photons (BG)'));
    indNBR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (BR)'));
    %%% Read out corrections
    Background_BB = BurstData{file}.Background.Background_BBpar + BurstData{file}.Background.Background_BBperp;
    Background_BG = BurstData{file}.Background.Background_BGpar + BurstData{file}.Background.Background_BGperp;
    Background_BR = BurstData{file}.Background.Background_BRpar + BurstData{file}.Background.Background_BRperp;
    
    if obj == h.DetermineCorrectionsButton
        %% Blue dye only
        Smin = UserValues.BurstBrowser.Settings.S_Donly_Min;
        Smax = UserValues.BurstBrowser.Settings.S_Donly_Max;
        S_threshold = (data_for_corrections(:,indSBG) > Smin) & (data_for_corrections(:,indSBG) < Smax) &...
            (data_for_corrections(:,indSBR) > Smin) & (data_for_corrections(:,indSBR) < Smax) ;
        x_axis = linspace(-0.05,0.3,50);
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBG = data_for_corrections(S_threshold,indNBG) - Background_BG.*data_for_corrections(S_threshold,indDur);
        NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
        %%% Crosstalk B->G
        EBG_raw = NBG./(NBG+NBB);
        histEBG_blueonly = histc(EBG_raw,x_axis);
        x_axis = x_axis(1:end-1);
        histEBG_blueonly(end-1) = histEBG_blueonly(end-1)+histEBG_blueonly(end);
        histEBG_blueonly(end) = [];
        BurstMeta.Plots.histEBG_blueonly.XData = x_axis;
        BurstMeta.Plots.histEBG_blueonly.YData = histEBG_blueonly;
        axis(h.Corrections.ThreeCMFD.axes_crosstalk_BG,'tight');
        %fit single gaussian
        [mean_ct, GaussFit] = GaussianFit(x_axis',histEBG_blueonly);
        BurstMeta.Plots.Fits.histEBG_blueonly(1).XData = x_axis;
        BurstMeta.Plots.Fits.histEBG_blueonly(1).YData = GaussFit;
        ct = mean_ct/(1-mean_ct);
        if ~isnan(ct) && (ct > 0)
            UserValues.BurstBrowser.Corrections.CrossTalk_BG = ct;
        end
        if ~h.MultiselectOnCheckbox.UserData
            BurstData{file}.Corrections.CrossTalk_BG = UserValues.BurstBrowser.Corrections.CrossTalk_BG;
        else %%% Update for all files contributing
            Files = get_multiselection(h);
            for i = 1:numel(Files)
                BurstData{Files(i)}.Corrections.CrossTalk_BG = UserValues.BurstBrowser.Corrections.CrossTalk_BG;
            end
        end
        
        %%% Crosstalk B->R
        x_axis = linspace(-0.05,0.25,50);
        EBR_raw = NBR./(NBR+NBB);
        histEBR_blueonly = histc(EBR_raw,x_axis);
        x_axis = x_axis(1:end-1);
        histEBR_blueonly(end-1) = histEBR_blueonly(end-1)+histEBR_blueonly(end);
        histEBR_blueonly(end) = [];
        BurstMeta.Plots.histEBR_blueonly.XData = x_axis;
        BurstMeta.Plots.histEBR_blueonly.YData = histEBR_blueonly;
        axis(h.Corrections.ThreeCMFD.axes_crosstalk_BR,'tight');
        %fit single gaussian
        [mean_ct, GaussFit] = GaussianFit(x_axis',histEBR_blueonly);
        BurstMeta.Plots.Fits.histEBR_blueonly(1).XData = x_axis;
        BurstMeta.Plots.Fits.histEBR_blueonly(1).YData = GaussFit;
        ct = mean_ct/(1-mean_ct);
        if ~isnan(ct) && (ct > 0)
            UserValues.BurstBrowser.Corrections.CrossTalk_BR = ct;
        end
        if ~h.MultiselectOnCheckbox.UserData
            BurstData{file}.Corrections.CrossTalk_BR = UserValues.BurstBrowser.Corrections.CrossTalk_BR;
        else %%% Update for all files contributing
            Files = get_multiselection(h);
            for i = 1:numel(Files)
                BurstData{Files(i)}.Corrections.CrossTalk_BR = UserValues.BurstBrowser.Corrections.CrossTalk_BR;
            end
        end
        %% Green dye only
        S_threshold =  (data_for_corrections(:,indSBG) < UserValues.BurstBrowser.Settings.S_Aonly_Max) & (data_for_corrections(:,indSBG) > UserValues.BurstBrowser.Settings.S_Aonly_Min) &...
            (data_for_corrections(:,indS) > UserValues.BurstBrowser.Settings.S_Donly_Min) & (data_for_corrections(:,indS) < UserValues.BurstBrowser.Settings.S_Donly_Max) ;
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBG = data_for_corrections(S_threshold,indNBG) - Background_BG.*data_for_corrections(S_threshold,indDur);
        NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
        
        x_axis = linspace(UserValues.BurstBrowser.Settings.S_Aonly_Min,UserValues.BurstBrowser.Settings.S_Aonly_Max,25);
        SBG_raw = (NBB+NBG)./(NBB+NBG+NGG);
        histSBG_greenonly = histc(SBG_raw,x_axis);
        x_axis = x_axis(1:end-1);
        histSBG_greenonly(end-1) = histSBG_greenonly(end-1)+histSBG_greenonly(end);
        histSBG_greenonly(end) = [];
        BurstMeta.Plots.histSBG_greenonly.XData = x_axis;
        BurstMeta.Plots.histSBG_greenonly.YData = histSBG_greenonly;
        axis(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,'tight');
        %fit single gaussian
        [mean_de, GaussFit] = GaussianFit(x_axis',histSBG_greenonly);
        BurstMeta.Plots.Fits.histSBG_greenonly(1).XData = x_axis;
        BurstMeta.Plots.Fits.histSBG_greenonly(1).YData = GaussFit;
        de =  mean_de/(1-mean_de);
        if ~isnan(de) && (de > 0)
            UserValues.BurstBrowser.Corrections.DirectExcitation_BG = de;
        end
        if ~h.MultiselectOnCheckbox.UserData
            BurstData{file}.Corrections.DirectExcitation_BG = UserValues.BurstBrowser.Corrections.DirectExcitation_BG;
        else %%% Update for all files contributing
            Files = get_multiselection(h);
            for i = 1:numel(Files)
                BurstData{Files(i)}.Corrections.DirectExcitation_BG = UserValues.BurstBrowser.Corrections.DirectExcitation_BG;
            end
        end
        %% Red dye only
        S_threshold = (data_for_corrections(:,indS) < UserValues.BurstBrowser.Settings.S_Aonly_Max) & (data_for_corrections(:,indS) > UserValues.BurstBrowser.Settings.S_Aonly_Min) &...
            (data_for_corrections(:,indSBR) < UserValues.BurstBrowser.Settings.S_Aonly_Max) & (data_for_corrections(:,indSBR) > UserValues.BurstBrowser.Settings.S_Aonly_Min);
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
        NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
        
        x_axis = linspace(UserValues.BurstBrowser.Settings.S_Aonly_Min,UserValues.BurstBrowser.Settings.S_Aonly_Max,25);
        SBR_raw = (NBB+NBR)./(NBB+NBR+NRR);
        histSBR_redonly = histc(SBR_raw,x_axis);
        x_axis = x_axis(1:end-1);
        histSBR_redonly(end-1) = histSBR_redonly(end-1)+histSBR_redonly(end);
        histSBR_redonly(end) = [];
        BurstMeta.Plots.histSBR_redonly.XData = x_axis;
        BurstMeta.Plots.histSBR_redonly.YData = histSBR_redonly;
        axis(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,'tight');
        %fit single gaussian
        [mean_de, GaussFit] = GaussianFit(x_axis',histSBR_redonly);
        BurstMeta.Plots.Fits.histSBR_redonly(1).XData = x_axis;
        BurstMeta.Plots.Fits.histSBR_redonly(1).YData = GaussFit;
        de = mean_de/(1-mean_de);
        if ~isnan(de) && (de > 0)
            UserValues.BurstBrowser.Corrections.DirectExcitation_BR = de;
        end
        if ~h.MultiselectOnCheckbox.UserData
            BurstData{file}.Corrections.DirectExcitation_BR = UserValues.BurstBrowser.Corrections.DirectExcitation_BR;
        else %%% Update for all files contributing
            Files = get_multiselection(h);
            for i = 1:numel(Files)
                BurstData{Files(i)}.Corrections.DirectExcitation_BR = UserValues.BurstBrowser.Corrections.DirectExcitation_BR;
            end
        end
    end
    if obj == h.FitGammaButton
        %m = msgbox('Using double labeled populations for three-color.');
        m = msgbox('Not implemented for 3 color. Use 2 color standards to determine 3 color gamma factors instead.');
        pause(1);
        delete(m);
        if 0
            %%% Gamma factor determination based on triple labeled population
            %%% using currently selected bursts
            S_threshold = UpdateCuts();
            %%% Read out corrections
            ct_gr = BurstData{file}.Corrections.CrossTalk_GR;
            de_gr = BurstData{file}.Corrections.DirectExcitation_GR;
            ct_bg = BurstData{file}.Corrections.CrossTalk_BG;
            de_bg = BurstData{file}.Corrections.DirectExcitation_BG;
            ct_br = BurstData{file}.Corrections.CrossTalk_BR;
            de_br = BurstData{file}.Corrections.DirectExcitation_BR;
            gamma_gr = BurstData{file}.Corrections.Gamma_GR;
            %%% Calculate correct EGR
            %%% excitation,crosstalk, and background corrections!
            NGR = BurstData{file}.DataArray(S_threshold,indNGR) - Background_GR.*BurstData{file}.DataArray(S_threshold,indDur);
            NGG = BurstData{file}.DataArray(S_threshold,indNGG) - Background_GG.*BurstData{file}.DataArray(S_threshold,indDur);
            NRR = BurstData{file}.DataArray(S_threshold,indNRR) - Background_RR.*BurstData{file}.DataArray(S_threshold,indDur);
            NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
            EGR = NGR./(NGR+gamma_gr*NGG);
            %%% correct three-color photon counts for background
            NBB = BurstData{file}.DataArray(S_threshold,indNBB) - Background_BB.*BurstData{file}.DataArray(S_threshold,indDur);
            NBG = BurstData{file}.DataArray(S_threshold,indNBG) - Background_BG.*BurstData{file}.DataArray(S_threshold,indDur);
            NBR = BurstData{file}.DataArray(S_threshold,indNBR) - Background_BR.*BurstData{file}.DataArray(S_threshold,indDur);
            
            %%% Apply CrossTalk and DirectExcitation Corrections
            NBR = NBR - de_br.*NRR - ct_br.*NBB - ct_gr.*(NBG-ct_bg.*NBB) - de_bg*(EGR./(1-EGR)).*NGG;
            NBG = NBG - de_bg.*NGG - ct_bg.*NBB;
            %%% calculate corrected photon counts by adding FRET photons back
            NBGcor = NBG./(1-EGR);
            NBRcor = NBR-(EGR./(1-EGR)).*gamma_gr.*NBG;
            %%% Calculate FRET efficiencies for gamma_br = 1 and stoichiometries
            gamma_br = 1; gamma_bg = 1;
            EBG = NBGcor./(gamma_bg.*NBB+NBGcor);
            EBR = NBRcor./(gamma_br.*NBB+NBRcor);
            SBG = (gamma_bg.*NBB+NBG+NBR)./(gamma_bg.*NBB+NBG+NBR+NGG+(NGR./gamma_gr));
            SBR = (gamma_br.*NBB+NBR+gamma_gr.*NBG)./(gamma_br.*NBB+NBR+gamma_gr.*NBG+NRR);

            fitGamma = fit(EBG,1./SBG,@(m,b,x) m*x+b,'StartPoint',[1,1],'Robust','LAR');
            coeff = coeffvalues(fitGamma); m = coeff(1); b = coeff(2);
            gamma_bg = (b - 1)/(b + m - 1);
            beta_bg = b+m-1;
            
            fitGamma = fit(EBR,1./SBR,@(m,b,x) m*x+b,'StartPoint',[1,1],'Robust','LAR');
            coeff = coeffvalues(fitGamma); m = coeff(1); b = coeff(2);
            gamma_br = (b - 1)/(b + m - 1);
            beta_br = b+m-1;
        end
        if 0
        %% Gamma factor determination based on double-labeled species
        %%% BG labeled
        S_threshold = ( (data_for_corrections(:,indS) > 0.9) &...
            (data_for_corrections(:,indSBG) > 0.3) & (data_for_corrections(:,indSBG) < 0.7) &...
            (data_for_corrections(:,indSBR) > 0.9) );
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBG = data_for_corrections(S_threshold,indNBG) - Background_BG.*data_for_corrections(S_threshold,indDur);
        NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
        NBG = NBG - BurstData{file}.Corrections.DirectExcitation_BG.*NGG - BurstData{file}.Corrections.CrossTalk_BG.*NBB;
        EBG_raw = NBG./(NBG+NBB);
        SBG_raw = (NBB+NBG)./(NBB+NBG+NGG);
        %%% Calculate 2D-Hist and Fit
        [H,xbins,ybins] = calc2dhist(EBG_raw,1./SBG_raw,[51 51],[0 1], [1 10]);
        BurstMeta.Plots.gamma_BG_fit(1).XData= xbins;
        BurstMeta.Plots.gamma_BG_fit(1).YData= ybins;
        BurstMeta.Plots.gamma_BG_fit(1).CData= H;
        BurstMeta.Plots.gamma_BG_fit(1).AlphaData= (H>0);
        BurstMeta.Plots.gamma_BG_fit(2).XData= xbins;
        BurstMeta.Plots.gamma_BG_fit(2).YData= ybins;
        BurstMeta.Plots.gamma_BG_fit(2).ZData= H/max(max(H));
        BurstMeta.Plots.gamma_BG_fit(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
        %%% Update/Reset Axis Labels
        xlabel(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'FRET Efficiency BG','Color',UserValues.Look.Fore);
        ylabel(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'1/Stoichiometry BG','Color',UserValues.Look.Fore);
        title(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'1/Stoichiometry BG vs. FRET Efficiency BG for gammaBG = 1','Color',UserValues.Look.Fore);
        %%% store for later use
        BurstMeta.Data.EBG_raw = EBG_raw;
        BurstMeta.Data.SBG_raw = SBG_raw;
        %%% Fit linearly
        valid = ( EBG_raw >= 0 & EBG_raw <= 1 & SBG_raw >= 0 & SBG_raw <= 1);
        fitGamma = fit(EBG_raw(valid),1./SBG_raw(valid),'poly1');
        BurstMeta.Plots.Fits.gamma_BG.Visible = 'on';
        BurstMeta.Plots.Fits.gamma_BG_manual.Visible = 'off';
        BurstMeta.Plots.Fits.gamma_BG.XData = linspace(0,1,1000);
        BurstMeta.Plots.Fits.gamma_BG.YData = fitGamma(linspace(0,1,1000));
        axis(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'tight');
        ylim(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,[1,10]);
        xlim(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,[0,1]);
        %%% Determine Gamma and Beta
        coeff = coeffvalues(fitGamma); m = coeff(1); b = coeff(2);
        UserValues.BurstBrowser.Corrections.Gamma_BG = (b - 1)/(b + m - 1);
        BurstData{file}.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
        UserValues.BurstBrowser.Corrections.Beta_BG = b+m-1;
        BurstData{file}.Corrections.Beta_BG = UserValues.BurstBrowser.Corrections.Beta_BG;
        
        S_threshold = ( (data_for_corrections(:,indS) < 0.2) &...
            (data_for_corrections(:,indSBG) > 0.9) &...
            (data_for_corrections(:,indSBR) > 0.2) & (data_for_corrections(:,indSBR) < 0.8) );
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
        NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
        NBR = NBR - BurstData{file}.Corrections.DirectExcitation_BR.*NRR - BurstData{file}.Corrections.CrossTalk_BR.*NBB;
        EBR_raw = NBR./(NBR+NBB);
        SBR_raw = (NBB+NBR)./(NBB+NBR+NRR);
        %%% Calculate 2D-Hist and Fit
        [H,xbins,ybins] = calc2dhist(EBR_raw,1./SBR_raw,[51 51],[0 2], [1 10]);
        BurstMeta.Plots.gamma_BR_fit(1).XData= xbins;
        BurstMeta.Plots.gamma_BR_fit(1).YData= ybins;
        BurstMeta.Plots.gamma_BR_fit(1).CData= H;
        BurstMeta.Plots.gamma_BR_fit(1).AlphaData= (H>0);
        BurstMeta.Plots.gamma_BR_fit(2).XData= xbins;
        BurstMeta.Plots.gamma_BR_fit(2).YData= ybins;
        BurstMeta.Plots.gamma_BR_fit(2).ZData= H/max(max(H));
        BurstMeta.Plots.gamma_BR_fit(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
        %%% Update/Reset Axis Labels
        xlabel(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'FRET Efficiency* BR','Color',UserValues.Look.Fore);
        ylabel(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'1/Stoichiometry* BR','Color',UserValues.Look.Fore);
        title(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'1/Stoichiometry* BR vs. FRET Efficiency* BR for gammaBR = 1','Color',UserValues.Look.Fore);
        %%% store for later use
        BurstMeta.Data.EBR_raw = EBR_raw;
        BurstMeta.Data.SBR_raw = SBR_raw;
        %%% Fit linearly
        %valid = EBR_raw >= 0 & EBR_raw <= 1 &...
        %     SBR_raw >= 0 & SBR_raw <= 1 ;
        fitGamma = fit(EBR_raw,1./SBR_raw,'poly1');
        BurstMeta.Plots.Fits.gamma_BR.Visible = 'on';
        BurstMeta.Plots.Fits.gamma_BR_manual.Visible = 'off';
        BurstMeta.Plots.Fits.gamma_BR.XData = linspace(0,1,1000);
        BurstMeta.Plots.Fits.gamma_BR.YData = fitGamma(linspace(0,1,1000));
        axis(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'tight');
        ylim(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,[1,10]);
        xlim(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,[0,1]);
        %%% Determine Gamma and Beta
        coeff = coeffvalues(fitGamma); m = coeff(1); b = coeff(2);
        UserValues.BurstBrowser.Corrections.Gamma_BR = (b - 1)/(b + m - 1);
        BurstData{file}.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
        UserValues.BurstBrowser.Corrections.Beta_BR = b+m-1;
        BurstData{file}.Corrections.Beta_BR = UserValues.BurstBrowser.Corrections.Beta_BR;
        end
    end
    if obj == h.DetermineGammaLifetimeThreeColorButton
        % use the user selected species
        if ~h.MultiselectOnCheckbox.UserData
            indTauBB = (strcmp(BurstData{file}.NameArray,'Lifetime BB [ns]'));
            data_for_corrections = BurstData{file}.DataArray;
            %%% use selected species
            Valid = UpdateCuts();
            tauBB = data_for_corrections(Valid,indTauBB);
            %%% Calculate "raw" E1A and with gamma_br = 1, but still apply direct
            %%% excitation,crosstalk, and background corrections!
            NBB = data_for_corrections(Valid,indNBB) - Background_BB.*data_for_corrections(Valid,indDur);
            NBG = data_for_corrections(Valid,indNBG) - Background_BG.*data_for_corrections(Valid,indDur);
            NBR = data_for_corrections(Valid,indNBR) - Background_BR.*data_for_corrections(Valid,indDur);
            NGG = data_for_corrections(Valid,indNGG) - Background_GG.*data_for_corrections(Valid,indDur);
            NGR = data_for_corrections(Valid,indNGR) - Background_GR.*data_for_corrections(Valid,indDur);
            NRR = data_for_corrections(Valid,indNRR) - Background_RR.*data_for_corrections(Valid,indDur);
           
        else
            NBB = get_multiselection_data(h,'Number of Photons (BB)');
            NBG = get_multiselection_data(h,'Number of Photons (BG)');
            NBR = get_multiselection_data(h,'Number of Photons (BR)');
            NGR = get_multiselection_data(h,'Number of Photons (GR)');
            NGG = get_multiselection_data(h,'Number of Photons (GG)');
            NRR = get_multiselection_data(h,'Number of Photons (RR)');
            dur = get_multiselection_data(h,'Duration [ms]');
            tauBB = get_multiselection_data(h,'Lifetime BB [ns]');
                
            NBB = NBB - Background_BB.*dur;
            NBG = NBG - Background_BG.*dur;
            NBR = NBR - Background_BR.*dur;
            NGR = NGR - Background_GR.*dur;
            NGG = NGG - Background_GG.*dur;
            NRR = NRR - Background_RR.*dur;
        end
        
        NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
        gamma_gr = BurstData{file}.Corrections.Gamma_GR;
        EGR = NGR./(gamma_gr.*NGG+NGR);
        NBR = NBR - BurstData{file}.Corrections.DirectExcitation_BR.*NRR - BurstData{file}.Corrections.CrossTalk_BR.*NBB -...
            BurstData{file}.Corrections.CrossTalk_GR.*(NBG-BurstData{file}.Corrections.CrossTalk_BG.*NBB) -...
            BurstData{file}.Corrections.DirectExcitation_BG*(EGR./(1-EGR)).*NGG;
        NBG = NBG - BurstData{file}.Corrections.DirectExcitation_BG.*NGG - BurstData{file}.Corrections.CrossTalk_BG.*NBB;
        %%% Calculate static FRET line in presence of linker fluctuations
        [statFRETline, statFRETfun,tau] = conversion_tau_3C(BurstData{file}.Corrections.DonorLifetimeBlue,...
            BurstData{file}.Corrections.FoersterRadiusBG,BurstData{file}.Corrections.FoersterRadiusBR,...
            BurstData{file}.Corrections.LinkerLengthBG,BurstData{file}.Corrections.LinkerLengthBR);
        %staticFRETline = @(x) 1 - (coeff(1).*x.^3 + coeff(2).*x.^2 + coeff(3).*x + coeff(4))./BurstData{file}.Corrections.DonorLifetimeBlue;
        valid = (tauBB < BurstData{file}.Corrections.DonorLifetimeBlue) & (tauBB > 0.01) & ~isnan(tauBB);
        valid = find(valid);
        valid = valid(~isnan(statFRETfun( tauBB(valid))));
        %%% minimize deviation from static FRET line as a function of gamma_br!
        dev = @(gamma) sum( ( ( (gamma_gr.*NBG(valid)+NBR(valid))./(gamma.*NBB(valid) + gamma_gr.*NBG(valid) + NBR(valid)) ) - statFRETfun( tauBB(valid) ) ).^2 );
        gamma_fit = fmincon(dev,1,[],[],[],[],0,10);
        E1A =  (gamma_gr.*NBG+NBR)./(gamma_fit.*NBB + gamma_gr.*NBG + NBR);
        %%% plot E versus tau with static FRET line
        [H,xbins,ybins] = calc2dhist(tauBB,E1A,[51 51],[0 min([max(tauBB) BurstData{file}.Corrections.DonorLifetimeBlue+1.5])],[-0.1 1.1]);
        BurstMeta.Plots.gamma_threecolor_lifetime(1).XData= xbins;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).YData= ybins;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).CData= H;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).AlphaData= (H>0);
        BurstMeta.Plots.gamma_threecolor_lifetime(2).XData= xbins;
        BurstMeta.Plots.gamma_threecolor_lifetime(2).YData= ybins;
        BurstMeta.Plots.gamma_threecolor_lifetime(2).ZData= H/max(max(H));
        BurstMeta.Plots.gamma_threecolor_lifetime(2).LevelList= linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
        %%% add static FRET line
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.Visible = 'on';
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.XData = tau;
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.YData = statFRETline;%statFRETfun(tau);
        ylim(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,[-0.1 1.1]);
        %%% Update UserValues
        UserValues.BurstBrowser.Corrections.Gamma_BR =gamma_fit;
        UserValues.BurstBrowser.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BR./UserValues.BurstBrowser.Corrections.Gamma_GR;
        
        if ~h.MultiselectOnCheckbox.UserData
            BurstData{file}.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
            BurstData{file}.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
        else %%% Update for all files contributing
            Files = get_multiselection(h);
            for i = 1:numel(Files)
                BurstData{Files(i)}.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
                BurstData{Files(i)}.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
            end
        end
    end
end
%% Save and Update GUI
%%% Save UserValues
LSUserValues(1);
%%% Update Correction Table Data
UpdateCorrections([],[],h);
%%% Apply Corrections
ApplyCorrections(gcbo,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Manual gamma determination by selecting the mid-points %%%%%%%%%%%%
%%%%%%% of two populations                                     %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineGammaManually(obj,~)
global UserValues BurstMeta BurstData
file = BurstMeta.SelectedFile;
if isempty(obj)
    h = guidata(findobj('Tag','BurstBrowser'));
else
    h = guidata(obj);
end
h.Main_Tab.SelectedTab = h.Main_Tab_Corrections;
indDur = find(strcmp(BurstData{file}.NameArray,'Duration [ms]'));
switch BurstData{file}.BAMethod
    case {1,2,5}
        indNGG = find(strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'));
        indNGR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'));
        indNRR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (AA)'));
    case {3,4}
        indNGG = find(strcmp(BurstData{file}.NameArray,'Number of Photons (GG)'));
        indNGR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (GR)'));
        indNRR = find(strcmp(BurstData{file}.NameArray,'Number of Photons (RR)'));
end
%%% Read out corrections
if ~(BurstData{file}.BAMethod == 5) %%% MFD
    Background_GR = BurstData{file}.Background.Background_GRpar + BurstData{file}.Background.Background_GRperp;
    Background_GG = BurstData{file}.Background.Background_GGpar + BurstData{file}.Background.Background_GGperp;
    Background_RR = BurstData{file}.Background.Background_RRpar + BurstData{file}.Background.Background_RRperp;
elseif BurstData{file}.BAMethod == 5
    Background_GR = BurstData{file}.Background.Background_GRpar;
    Background_GG = BurstData{file}.Background.Background_GGpar;
    Background_RR = BurstData{file}.Background.Background_RRpar;
end

%%% change the plot in axes_gamma to S vs E (instead of default 1/S vs. E)
S_threshold = UpdateCuts();
%%% Calculate "raw" E and S with gamma = 1, but still apply direct
%%% excitation,crosstalk, and background corrections!
NGR = BurstData{file}.DataArray(S_threshold,indNGR) - Background_GR.*BurstData{file}.DataArray(S_threshold,indDur);
NGG = BurstData{file}.DataArray(S_threshold,indNGG) - Background_GG.*BurstData{file}.DataArray(S_threshold,indDur);
NRR = BurstData{file}.DataArray(S_threshold,indNRR) - Background_RR.*BurstData{file}.DataArray(S_threshold,indDur);
NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
E_raw = NGR./(NGR+NGG);
S_raw = (NGG+NGR)./(NGG+NGR+NRR);
[H,xbins,ybins] = calc2dhist(E_raw,S_raw,[51 51],[0 1], [min(S_raw) max(S_raw)]);
%[H, xbins, ybins] = calc2dhist(BurstMeta.Data.E_raw,BurstMeta.Data.S_raw,[51 51], [0 1], [0 1]);
BurstMeta.Plots.gamma_fit(1).XData = xbins;
BurstMeta.Plots.gamma_fit(1).YData = ybins;
BurstMeta.Plots.gamma_fit(1).CData = H;
BurstMeta.Plots.gamma_fit(1).AlphaData = (H>0);
BurstMeta.Plots.gamma_fit(2).XData = xbins;
BurstMeta.Plots.gamma_fit(2).YData = ybins;
BurstMeta.Plots.gamma_fit(2).ZData = H/max(max(H));
BurstMeta.Plots.gamma_fit(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
axis(h.Corrections.TwoCMFD.axes_gamma,'tight');

%%% Update Axis Labels
xlabel(h.Corrections.TwoCMFD.axes_gamma,'FRET Efficiency','Color',UserValues.Look.Fore);
ylabel(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry','Color',UserValues.Look.Fore);
title(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry vs. FRET Efficiency for gamma = 1','Color',UserValues.Look.Fore);
%%% Hide Fit
BurstMeta.Plots.Fits.gamma.Visible = 'off';
[e, s] = ginput(2);
BurstMeta.Plots.Fits.gamma_manual.XData = e;
BurstMeta.Plots.Fits.gamma_manual.YData = s;
BurstMeta.Plots.Fits.gamma_manual.Visible = 'on';
s = 1./s;
m = (s(2)-s(1))./(e(2)-e(1));
b = s(2) - m.*e(2);

UserValues.BurstBrowser.Corrections.Gamma_GR = (b - 1)/(b + m - 1);
BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;

UserValues.BurstBrowser.Corrections.Beta_GR = b+m-1;
BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;

%%% Save UserValues
LSUserValues(1);
%%% Update Correction Table Data
UpdateCorrections([],[],h);
%%% Apply Corrections
ApplyCorrections([],[],h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates the Gamma Factor using the lifetime information %%%%%%%%
%%%%%%% by minimizing the deviation from the static FRET line      %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineGammaLifetime(obj,~)
global BurstData UserValues BurstMeta
h = guidata(obj);
LSUserValues(0);
h.Main_Tab.SelectedTab = h.Main_Tab_Corrections;
file = BurstMeta.SelectedFile;
%% 2cMFD
%%% Prepare photon counts
indDur = (strcmp(BurstData{file}.NameArray,'Duration [ms]'));
indNGG = (strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'));
indNGR = (strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'));
indNRR = (strcmp(BurstData{file}.NameArray,'Number of Photons (AA)'));
indTauGG = (strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'));

data_for_corrections = BurstData{file}.DataArray;

%%% Read out corrections
if ~(BurstData{file}.BAMethod == 5) % MFD
    Background_GR = BurstData{file}.Background.Background_GRpar + BurstData{file}.Background.Background_GRperp;
    Background_GG = BurstData{file}.Background.Background_GGpar + BurstData{file}.Background.Background_GGperp;
    Background_RR = BurstData{file}.Background.Background_RRpar + BurstData{file}.Background.Background_RRperp;
elseif BurstData{file}.BAMethod == 5 % noMFD
    Background_GR = BurstData{file}.Background.Background_GRpar;
    Background_GG = BurstData{file}.Background.Background_GGpar;
    Background_RR = BurstData{file}.Background.Background_RRpar;
end

%%% use selected species
S_threshold = UpdateCuts();
%%% Calculate "raw" E and S with gamma = 1, but still apply direct
%%% excitation,crosstalk, and background corrections!
NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;

if obj == h.DetermineGammaLifetimeTwoColorButton
    %%% Calculate static FRET line in presence of linker fluctuations
    [FRETline, statFRETfun,tau] = conversion_tau(BurstData{file}.Corrections.DonorLifetime,...
        BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength);
    %staticFRETline = @(x) 1 - (coeff(1).*x.^3 + coeff(2).*x.^2 + coeff(3).*x + coeff(4))./BurstData{file}.Corrections.DonorLifetime;
    %%% minimize deviation from static FRET line as a function of gamma
    tauGG = data_for_corrections(S_threshold,indTauGG);
    valid = (tauGG < BurstData{file}.Corrections.DonorLifetime) & (tauGG > 0.01) & ~isnan(tauGG) & ~isnan(statFRETfun(tauGG));
    %dev = @(gamma) sum( ( ( NGR(valid)./(gamma.*NGG(valid)+NGR(valid)) ) - statFRETfun( tauGG(valid) ) ).^2 );
    %gamma_fit = fmincon(dev,1,[],[],[],[],0,10);
    gamma_fit = fit([NGR(valid),NGG(valid)],statFRETfun(tauGG(valid)), @(gamma,x,y) (x./(gamma.*y+x) ),'StartPoint',1,'Robust','bisquare');
    gamma_fit = coeffvalues(gamma_fit);
    E =  NGR./(gamma_fit.*NGG+NGR);
    %%% plot E versus tau with static FRET line
    [H,xbins,ybins] = calc2dhist(data_for_corrections(S_threshold,indTauGG),E,[51 51],[0 min([max(tauGG) BurstData{file}.Corrections.DonorLifetime+1.5])],[-0.1 1.1]);
    BurstMeta.Plots.gamma_lifetime(1).XData= xbins;
    BurstMeta.Plots.gamma_lifetime(1).YData= ybins;
    BurstMeta.Plots.gamma_lifetime(1).CData= H;
    BurstMeta.Plots.gamma_lifetime(1).AlphaData= (H>0);
    BurstMeta.Plots.gamma_lifetime(2).XData= xbins;
    BurstMeta.Plots.gamma_lifetime(2).YData= ybins;
    BurstMeta.Plots.gamma_lifetime(2).ZData= H/max(max(H));
    BurstMeta.Plots.gamma_lifetime(2).LevelList= linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    %%% add static FRET line
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.Visible = 'on';
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.XData = tau;
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.YData = FRETline;
    ylim(h.Corrections.TwoCMFD.axes_gamma_lifetime,[-0.1,1.1]);
    %%% Update UserValues
    UserValues.BurstBrowser.Corrections.Gamma_GR =gamma_fit;
    BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
end
%% 3cMFD - Fit E1A vs. TauBlue
if obj == h.DetermineGammaLifetimeThreeColorButton
    if any(BurstData{file}.BAMethod == [3,4])
        %%% Prepare photon counts
        indNBB = (strcmp(BurstData{file}.NameArray,'Number of Photons (BB)'));
        indNBG = (strcmp(BurstData{file}.NameArray,'Number of Photons (BG)'));
        indNBR = (strcmp(BurstData{file}.NameArray,'Number of Photons (BR)'));
        indTauBB = (strcmp(BurstData{file}.NameArray,'Lifetime BB [ns]'));
        indSBG = (strcmp(BurstData{file}.NameArray,'Stoichiometry BG'));
        indSBR = (strcmp(BurstData{file}.NameArray,'Stoichiometry BR'));
        
        data_for_corrections = BurstData{file}.DataArray;
        
        %%% Read out corrections
        Background_BB = BurstData{file}.Background.Background_BBpar + BurstData{file}.Background.Background_BBperp;
        Background_BG = BurstData{file}.Background.Background_BGpar + BurstData{file}.Background.Background_BGperp;
        Background_BR = BurstData{file}.Background.Background_BRpar + BurstData{file}.Background.Background_BRperp;
        
        %%% use selected species
        S_threshold = UpdateCuts();
        %%% also use Lifetime Threshold
        S_threshold = S_threshold & (data_for_corrections(:,indTauBB) > 0.05);
        %%% Calculate "raw" E1A and with gamma_br = 1, but still apply direct
        %%% excitation,crosstalk, and background corrections!
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBG = data_for_corrections(S_threshold,indNBG) - Background_BG.*data_for_corrections(S_threshold,indDur);
        NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
        NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
        NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
        NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
        NGR = NGR - BurstData{file}.Corrections.DirectExcitation_GR.*NRR - BurstData{file}.Corrections.CrossTalk_GR.*NGG;
        gamma_gr = BurstData{file}.Corrections.Gamma_GR;
        EGR = NGR./(gamma_gr.*NGG+NGR);
        NBR = NBR - BurstData{file}.Corrections.DirectExcitation_BR.*NRR - BurstData{file}.Corrections.CrossTalk_BR.*NBB -...
            BurstData{file}.Corrections.CrossTalk_GR.*(NBG-BurstData{file}.Corrections.CrossTalk_BG.*NBB) -...
            BurstData{file}.Corrections.DirectExcitation_BG*(EGR./(1-EGR)).*NGG;
        NBG = NBG - BurstData{file}.Corrections.DirectExcitation_BG.*NGG - BurstData{file}.Corrections.CrossTalk_BG.*NBB;
        %%% Calculate static FRET line in presence of linker fluctuations
        [statFRETline, statFRETfun,tau] = conversion_tau_3C(BurstData{file}.Corrections.DonorLifetimeBlue,...
            BurstData{file}.Corrections.FoersterRadiusBG,BurstData{file}.Corrections.FoersterRadiusBR,...
            BurstData{file}.Corrections.LinkerLengthBG,BurstData{file}.Corrections.LinkerLengthBR);
        %staticFRETline = @(x) 1 - (coeff(1).*x.^3 + coeff(2).*x.^2 + coeff(3).*x + coeff(4))./BurstData{file}.Corrections.DonorLifetimeBlue;
        tauBB = data_for_corrections(S_threshold,indTauBB);
        valid = (tauBB < BurstData{file}.Corrections.DonorLifetimeBlue) & (tauBB > 0.01) & ~isnan(tauBB);
        valid = find(valid);
        valid = valid(~isnan(statFRETfun( tauBB(valid))));
        %%% minimize deviation from static FRET line as a function of gamma_br!
        dev = @(gamma) sum( ( ( (gamma_gr.*NBG(valid)+NBR(valid))./(gamma.*NBB(valid) + gamma_gr.*NBG(valid) + NBR(valid)) ) - statFRETfun( tauBB(valid) ) ).^2 );
        gamma_fit = fmincon(dev,1,[],[],[],[],0,10);
        E1A =  (gamma_gr.*NBG+NBR)./(gamma_fit.*NBB + gamma_gr.*NBG + NBR);
        %%% plot E versus tau with static FRET line
        [H,xbins,ybins] = calc2dhist(data_for_corrections(S_threshold,indTauBB),E1A,[51 51],[0 min([max(tauBB) BurstData{file}.Corrections.DonorLifetimeBlue+1.5])],[-0.1 1.1]);
        BurstMeta.Plots.gamma_threecolor_lifetime(1).XData= xbins;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).YData= ybins;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).CData= H;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).AlphaData= (H>0);
        BurstMeta.Plots.gamma_threecolor_lifetime(2).XData= xbins;
        BurstMeta.Plots.gamma_threecolor_lifetime(2).YData= ybins;
        BurstMeta.Plots.gamma_threecolor_lifetime(2).ZData= H/max(max(H));
        BurstMeta.Plots.gamma_threecolor_lifetime(2).LevelList= linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
        %%% add static FRET line
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.Visible = 'on';
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.XData = tau;
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.YData = statFRETline;%statFRETfun(tau);
        ylim(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,[-0.1 1.1]);
        %%% Update UserValues
        UserValues.BurstBrowser.Corrections.Gamma_BR =gamma_fit;
        UserValues.BurstBrowser.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BR./UserValues.BurstBrowser.Corrections.Gamma_GR;
        BurstData{file}.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
        BurstData{file}.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
    end
end
%%% Save UserValues
LSUserValues(1);
%%% Update Correction Table Data
UpdateCorrections([],[],h);
%%% Apply Corrections
ApplyCorrections(obj,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Applies Corrections to data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ApplyCorrections(obj,~,h,display_update)
global BurstData UserValues BurstMeta
if nargin == 2
    h = guidata(obj);
end
if nargin < 4
    display_update = 1; %%% default to true
end
if nargin > 0
    if obj == h.UseBetaCheckbox
        UserValues.BurstBrowser.Corrections.UseBeta = obj.Value;
        LSUserValues(1);
    end
end
if obj == h.ApplyCorrectionsAll_Menu
    %%% Set all files Corrections to values for current file
    BAMethod = BurstData{BurstMeta.SelectedFile}.BAMethod;
    switch BAMethod
        case {1,2,5}
            validBAMethods = [1,2,5];
        case {3,4}
            validBAMethods = [3,4];
    end
    Corrections = BurstData{BurstMeta.SelectedFile}.Corrections;

    %if ~h.MultiselectOnCheckbox.UserData
        files = 1:numel(BurstData);
    %else %%% only loop over selected foles
    %    files = get_multiselection(h);
    %    files = unique(files);
    %end
    for i = files
        if any(BurstData{i}.BAMethod == validBAMethods)
            %%% don't replace donor-only lifetimes
            DonorLifetime = BurstData{i}.Corrections.DonorLifetime;
            AcceptorLifetime = BurstData{i}.Corrections.AcceptorLifetime;

            BurstData{i}.Corrections = Corrections;

            BurstData{i}.Corrections.DonorLifetime = DonorLifetime;
            BurstData{i}.Corrections.AcceptorLifetime = AcceptorLifetime;
        end
    end
    %%% Apply Corrections
    sel_file = BurstMeta.SelectedFile;
    for i = files
        BurstMeta.SelectedFile = i;
        ApplyCorrections([],[],h,0); %%% Apply without display update
    end
    BurstMeta.SelectedFile = sel_file;
    
    %%% Update Cuts
    UpdateCuts;
    %%% Update Display
    UpdatePlot([],[],h);
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
    return;
end
if (obj == h.ApplyCorrectionsButton) & h.MultiselectOnCheckbox.UserData
    %%% disable callback and disable checkbox
    h.MultiselectOnCheckbox.Callback = [];
    h.MultiselectOnCheckbox.UserData = 0;
    
    %%% apply corrections to all selected files
    sel_file = BurstMeta.SelectedFile;
    files = get_multiselection(h); files = unique(files);
    for file = files
        BurstMeta.SelectedFile = file;
        ApplyCorrections([],[],h,0); %%% Apply without display update
    end
    BurstMeta.SelectedFile = sel_file;

    %%% reenable callback and checkbox
    h.MultiselectOnCheckbox.Callback = @UpdateOptions;
    h.MultiselectOnCheckbox.UserData = 1;
    
    %%% Update Cuts
    UpdateCuts;
    %%% Update Display
    UpdatePlot([],[],h);
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
    
    return;
end
file = BurstMeta.SelectedFile;
%% 2colorMFD
%% FRET and Stoichiometry Corrections
%%% Read out indices of parameters
switch BurstData{file}.BAMethod
    case {1,2,5} %2color
        indS = find(strcmp(BurstData{file}.NameArray,'Stoichiometry'));
        indE = find(strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
        indEPR = find(strcmp(BurstData{file}.NameArray,'Proximity Ratio'));
        indNGG = strcmp(BurstData{file}.NameArray,'Number of Photons (DD)');
        indNGR = strcmp(BurstData{file}.NameArray,'Number of Photons (DA)');
        indNRR = strcmp(BurstData{file}.NameArray,'Number of Photons (AA)');
    case {3,4} %3color
        indS = find(strcmp(BurstData{file}.NameArray,'Stoichiometry GR'));
        indE = find(strcmp(BurstData{file}.NameArray,'FRET Efficiency GR'));
        indEPR = find(strcmp(BurstData{file}.NameArray,'Proximity Ratio GR'));
        indNGG = strcmp(BurstData{file}.NameArray,'Number of Photons (GG)');
        indNGR = strcmp(BurstData{file}.NameArray,'Number of Photons (GR)');
        indNRR = strcmp(BurstData{file}.NameArray,'Number of Photons (RR)');
end
indDur = strcmp(BurstData{file}.NameArray,'Duration [ms]');


%%% Read out photons counts and duration
NGG = BurstData{file}.DataArray(:,indNGG);
NGR = BurstData{file}.DataArray(:,indNGR);
NRR = BurstData{file}.DataArray(:,indNRR);
Dur = BurstData{file}.DataArray(:,indDur);

%%% Read out corrections
gamma_gr = BurstData{file}.Corrections.Gamma_GR;
beta_gr = BurstData{file}.Corrections.Beta_GR;
ct_gr = BurstData{file}.Corrections.CrossTalk_GR;
de_gr = BurstData{file}.Corrections.DirectExcitation_GR;
if ~(BurstData{file}.BAMethod == 5) % MFD
    BG_GG = BurstData{file}.Background.Background_GGpar + BurstData{file}.Background.Background_GGperp;
    BG_GR = BurstData{file}.Background.Background_GRpar + BurstData{file}.Background.Background_GRperp;
    BG_RR = BurstData{file}.Background.Background_RRpar + BurstData{file}.Background.Background_RRperp;
elseif BurstData{file}.BAMethod == 5 % noMFD
    BG_GG = BurstData{file}.Background.Background_GGpar;
    BG_GR = BurstData{file}.Background.Background_GRpar;
    BG_RR = BurstData{file}.Background.Background_RRpar;
end

%%% Apply Background corrections
NGG = NGG - Dur.*BG_GG;
NGR = NGR - Dur.*BG_GR;
NRR = NRR - Dur.*BG_RR;

%%% recalculate proximity ratio (only background corrected)
% EPR = NGR./(NGR+NGG);

%%% Apply CrossTalk and DirectExcitation Corrections
NGR = NGR - de_gr.*NRR - ct_gr.*NGG;

%%% Recalculate FRET Efficiency and Stoichiometry
E = NGR./(NGR + gamma_gr.*NGG);
if UserValues.BurstBrowser.Corrections.UseBeta == 1
    S = (NGR + gamma_gr.*NGG)./(NGR + gamma_gr.*NGG + NRR./beta_gr);
elseif UserValues.BurstBrowser.Corrections.UseBeta == 0
    S = (NGR + gamma_gr.*NGG)./(NGR + gamma_gr.*NGG + NRR);
end

%%% Update Values in the DataArray
BurstData{file}.DataArray(:,indE) = E;
BurstData{file}.DataArray(:,indS) = S;
%BurstData{file}.DataArray(:,indEPR) = EPR;
if any(BurstData{file}.BAMethod == [1,2,5])
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET efficiency (sens. Acc. Em.)')) = beta_gr*NGR./NRR;
end
if BurstData{file}.BAMethod ~= 5 % ensure that polarized detection was used
    %% Anisotropy Corrections
    %%% Read out indices of parameters
    switch BurstData{file}.BAMethod
        case {1,2}
            ind_rGG = strcmp(BurstData{file}.NameArray,'Anisotropy D');
            ind_rRR = strcmp(BurstData{file}.NameArray,'Anisotropy A');
            indNGGpar = strcmp(BurstData{file}.NameArray,'Number of Photons (DD par)');
            indNGGperp = strcmp(BurstData{file}.NameArray,'Number of Photons (DD perp)');
            indNRRpar = strcmp(BurstData{file}.NameArray,'Number of Photons (AA par)');
            indNRRperp = strcmp(BurstData{file}.NameArray,'Number of Photons (AA perp)');
        case {3,4}
            ind_rGG = strcmp(BurstData{file}.NameArray,'Anisotropy GG');
            ind_rRR = strcmp(BurstData{file}.NameArray,'Anisotropy RR');
            indNGGpar = strcmp(BurstData{file}.NameArray,'Number of Photons (GG par)');
            indNGGperp = strcmp(BurstData{file}.NameArray,'Number of Photons (GG perp)');
            indNRRpar = strcmp(BurstData{file}.NameArray,'Number of Photons (RR par)');
            indNRRperp = strcmp(BurstData{file}.NameArray,'Number of Photons (RR perp)');
    end

    %%% Read out photons counts and duration
    NGGpar = BurstData{file}.DataArray(:,indNGGpar);
    NGGperp = BurstData{file}.DataArray(:,indNGGperp);
    NRRpar = BurstData{file}.DataArray(:,indNRRpar);
    NRRperp = BurstData{file}.DataArray(:,indNRRperp);

    %%% Read out corrections
    Ggreen = BurstData{file}.Corrections.GfactorGreen;
    Gred = BurstData{file}.Corrections.GfactorRed;
    l1 = UserValues.BurstBrowser.Corrections.l1;
    l2 = UserValues.BurstBrowser.Corrections.l2;
    BG_GGpar = BurstData{file}.Background.Background_GGpar;
    BG_GGperp = BurstData{file}.Background.Background_GGperp;
    BG_RRpar = BurstData{file}.Background.Background_RRpar;
    BG_RRperp = BurstData{file}.Background.Background_RRperp;

    %%% Apply Background corrections
    NGGpar = NGGpar - Dur.*BG_GGpar;
    NGGperp = NGGperp - Dur.*BG_GGperp;
    NRRpar = NRRpar - Dur.*BG_RRpar;
    NRRperp = NRRperp - Dur.*BG_RRperp;

    %%% Recalculate Anisotropies
    rGG = (Ggreen.*NGGpar - NGGperp)./( (1-3*l2).*Ggreen.*NGGpar + (2-3*l1).*NGGperp);
    rRR = (Gred.*NRRpar - NRRperp)./( (1-3*l2).*Gred.*NRRpar + (2-3*l1).*NRRperp);

    %%% Update Values in the DataArray
    BurstData{file}.DataArray(:,ind_rGG) = rGG;
    BurstData{file}.DataArray(:,ind_rRR) = rRR;
end
%% 3colorMFD
if any(BurstData{file}.BAMethod == [3,4])
    %% FRET Efficiencies and Stoichiometries
    %%% Read out indices of parameters
    indE1A = strcmp(BurstData{file}.NameArray,'FRET Efficiency B->G+R');
    indEBG = strcmp(BurstData{file}.NameArray,'FRET Efficiency BG');
    indEBR = strcmp(BurstData{file}.NameArray,'FRET Efficiency BR');
    indSBG = strcmp(BurstData{file}.NameArray,'Stoichiometry BG');
    indSBR = strcmp(BurstData{file}.NameArray,'Stoichiometry BR');
    indPrGR = strcmp(BurstData{file}.NameArray,'Proximity Ratio GR');
    indPrBG = strcmp(BurstData{file}.NameArray,'Proximity Ratio BG');
    indPrBR = strcmp(BurstData{file}.NameArray,'Proximity Ratio BR');
    indPrBtoGR = strcmp(BurstData{file}.NameArray,'Proximity Ratio B->G+R');
    indNBB = strcmp(BurstData{file}.NameArray,'Number of Photons (BB)');
    indNBG = strcmp(BurstData{file}.NameArray,'Number of Photons (BG)');
    indNBR= strcmp(BurstData{file}.NameArray,'Number of Photons (BR)');
    
    %%% Read out photons counts and duration
    NBB= BurstData{file}.DataArray(:,indNBB);
    NBG = BurstData{file}.DataArray(:,indNBG);
    NBR = BurstData{file}.DataArray(:,indNBR);
    
    %%% Read out corrections
    gamma_bg = BurstData{file}.Corrections.Gamma_BG;
    beta_bg = BurstData{file}.Corrections.Beta_BG;
    gamma_br = BurstData{file}.Corrections.Gamma_BR;
    beta_br = BurstData{file}.Corrections.Beta_BR;
    ct_bg = BurstData{file}.Corrections.CrossTalk_BG;
    de_bg = BurstData{file}.Corrections.DirectExcitation_BG;
    ct_br = BurstData{file}.Corrections.CrossTalk_BR;
    de_br = BurstData{file}.Corrections.DirectExcitation_BR;
    BG_BB = BurstData{file}.Background.Background_BBpar + BurstData{file}.Background.Background_BBperp;
    BG_BG = BurstData{file}.Background.Background_BGpar + BurstData{file}.Background.Background_BGperp;
    BG_BR = BurstData{file}.Background.Background_BRpar + BurstData{file}.Background.Background_BRperp;
    
    %%% Apply Background corrections
    NBB = NBB - Dur.*BG_BB;
    NBG = NBG - Dur.*BG_BG;
    NBR = NBR - Dur.*BG_BR;
    
    %%% change name of variable E to EGR
    EGR = E;
    %%% Apply CrossTalk and DirectExcitation Corrections
    NBR = NBR - de_br.*NRR - ct_br.*NBB - ct_gr.*(NBG-ct_bg.*NBB) - de_bg*(EGR./(1-EGR)).*NGG;
    NBG = NBG - de_bg.*NGG - ct_bg.*NBB;
    %%% Recalculate FRET Efficiency and Stoichiometry
    E1A = (gamma_gr.*NBG + NBR)./(gamma_br.*NBB + gamma_gr.*NBG + NBR);
    EBG = (gamma_gr.*NBG)./(gamma_br.*NBB.*(1-EGR)+ gamma_gr.*NBG);
    EBR = (NBR - EGR.*(gamma_gr.*NBG+NBR))./(gamma_br.*NBB + NBR - EGR.*(gamma_br.*NBB + gamma_gr.*NBG + NBR));
    if UserValues.BurstBrowser.Corrections.UseBeta == 1
        SBG = (gamma_br.*NBB + gamma_gr.*NBG + NBR)./(gamma_br.*NBB + gamma_gr.*NBG + NBR + (gamma_gr.*NGG + NGR)./beta_bg);
        SBR = (gamma_br.*NBB + gamma_gr.*NBG + NBR)./(gamma_br.*NBB + gamma_gr.*NBG + NBR + NRR./beta_br);
    elseif UserValues.BurstBrowser.Corrections.UseBeta == 0
        SBG = (gamma_br.*NBB + gamma_gr.*NBG + NBR)./(gamma_br.*NBB + gamma_gr.*NBG + NBR + gamma_gr.*NGG + NGR);
        SBR = (gamma_br.*NBB + gamma_gr.*NBG + NBR)./(gamma_br.*NBB + gamma_gr.*NBG + NBR + NRR);
    end
    %%% Recalculate proximity ratios (these are corrected, but not directly
    %%% related to distance. They can be converted to distances, however,
    %%% using correct formulas.) 
    PrGR = EGR; % no change for GR
    PrBG = gamma_gr.*NBG./(gamma_br.*NBB+gamma_gr.*NBG+NBR);
    PrBR = NBR./(gamma_br.*NBB+gamma_gr.*NBG+NBR);
    PrBtoGR = gamma_br.*NBB./(gamma_br.*NBB+gamma_gr.*NBG+NBR);
    %%% Update Values in the DataArray
    BurstData{file}.DataArray(:,indE1A) = E1A;
    BurstData{file}.DataArray(:,indEBG) = EBG;
    BurstData{file}.DataArray(:,indEBR) = EBR;
    BurstData{file}.DataArray(:,indSBG) = SBG;
    BurstData{file}.DataArray(:,indSBR) = SBR;
    BurstData{file}.DataArray(:,indPrGR) = PrGR;
    BurstData{file}.DataArray(:,indPrBG) = PrBG;
    BurstData{file}.DataArray(:,indPrBR) = PrBR;
    BurstData{file}.DataArray(:,indPrBtoGR) = PrBtoGR;
    %% Anisotropy Correction of blue channel
    %%% Read out indices of parameters
    ind_rBB = strcmp(BurstData{file}.NameArray,'Anisotropy BB');
    indNBBpar = strcmp(BurstData{file}.NameArray,'Number of Photons (BB par)');
    indNBBperp = strcmp(BurstData{file}.NameArray,'Number of Photons (BB perp)');
    
    %%% Read out photons counts and duration
    NBBpar = BurstData{file}.DataArray(:,indNBBpar);
    NBBperp = BurstData{file}.DataArray(:,indNBBperp);
    
    %%% Read out corrections
    Gblue = BurstData{file}.Corrections.GfactorBlue;
    BG_BBpar = BurstData{file}.Background.Background_BBpar;
    BG_BBperp = BurstData{file}.Background.Background_BBperp;
    
    %%% Apply Background corrections
    NBBpar = NBBpar - Dur.*BG_BBpar;
    NBBperp = NBBperp - Dur.*BG_BBperp;
    
    %%% Recalculate Anisotropies
    rBB = (Gblue.*NBBpar - NBBperp)./( (1-3*l2).*Gblue.*NBBpar + (2-3*l1).*NBBperp);
    
    %%% Update Value in the DataArray
    BurstData{file}.DataArray(:,ind_rBB) = rBB;
end

%% Update to derived distances from intensity and lifetime
if any(BurstData{file}.BAMethod == [1,2,5]) % 2-color MFD
    %%% Distance from intensity
    E(E<0 | E>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadius;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance (from intensity) [A]')) = ((1./E-1).*R0^6).^(1/6);
    %%% Efficiency from lifetime
    tauDA = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'));
    tauD = BurstData{file}.Corrections.DonorLifetime;
    El = 1-tauDA./tauD;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET efficiency (from lifetime)')) = El;
    %%% Distance from efficiency from lifetime
    El(El<0 | El>1) = NaN;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance (from lifetime) [A]')) = ((1./El-1).*R0^6).^(1/6);
elseif any(BurstData{file}.BAMethod == [3,4]) % 3-color MFD
    %%% Distance from intensity GR
    EGR(EGR<0 | EGR>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadius;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance GR (from intensity) [A]')) = ((1./EGR-1).*R0^6).^(1/6);
    %%% Efficiency from lifetime GR
    tauDA = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime GG [ns]'));
    tauD = BurstData{file}.Corrections.DonorLifetime;
    El = 1-tauDA./tauD;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET efficiency GR (from lifetime)')) = El;
    %%% Distance from efficiency from lifetime
    El(El<0 | El>1) = NaN;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance GR (from lifetime) [A]')) = ((1./El-1).*R0^6).^(1/6);
    %%% Distance from intensity BG
    EBG(EBG<0 | EBG>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadiusBG;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance BG (from intensity) [A]')) = ((1./EBG-1).*R0^6).^(1/6);
     %%% Distance from intensity BG
    EBR(EBR<0 | EBR>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadiusBR;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance BR (from intensity) [A]')) = ((1./EBR-1).*R0^6).^(1/6);
    %%% Lifetime-Efficiency relation does not hold true for 3 color!
end

h.ApplyCorrectionsButton.ForegroundColor = UserValues.Look.Fore;

if display_update
    UpdateCuts;
    %%% Update Display
    UpdatePlot([],[],h);
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% General 1D-Gauss Fit Function  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mean,GaussFun,Gauss1,Gauss2] = GaussianFit(x_data,y_data,mean_new)
%%% Inputs:
%%% xdata/ydata     : Data to Fit
%%% mean_new        : User-defined mean value
%%%
%%% Outputs:
%%% mean            : Determined Mean Value
%%% GaussFun        : The Values of the FitFunction at xdata
%%% Gauss1/2        : The Values of Gauss1/2 at xdata for multi-Gauss fit
if any(size(x_data) ~= size(y_data))
    y_data = y_data';
end
%% fit with 1 Gaussian
Gauss = @(A,m,s,b,x) A*exp(-(x-m).^2./s^2)+b;

A = max(y_data);%set amplitude as max value
m = sum(y_data.*x_data)./sum(y_data);%mean as center value
s = sqrt(sum(y_data.*(x_data-m).^2)./sum(y_data));%std as sigma
if s == 0
    s = 1;
end
b=0;%assume zero background
param = [A,m,s,b];

if nargin == 3 %%% output the Gauss with new mean value
    GaussFun = Gauss(A,mean_new,s,b,x_data);
    [mean,Gauss1,Gauss2] = deal([]);
    return;
end

if sum(y_data) <= 10 %%% low amount of data, take mean and std instead
    mean = m;
    GaussFun = Gauss(A,m,s,0,x_data);
    GaussFun = (GaussFun./max(GaussFun)).*max(y_data);
    return;
end
[gauss, gof] = fit(x_data,y_data,Gauss,'StartPoint',param,'Lower',[0,0,0,0],'Upper',[Inf,Inf,Inf,A/4]);
coefficients = coeffvalues(gauss);
mean = coefficients(2);
GaussFun = Gauss(coefficients(1),coefficients(2),coefficients(3),coefficients(4),x_data);

if gof.adjrsquare < 0.9 %%% fit was bad
    %%% fit with 2 Gaussians
    Gauss2fun = @(A1,m1,s1,A2,m2,s2,b,x) A1*exp(-(x-m1).^2./s1^2)+A2*exp(-(x-m2).^2./s2^2)+b;
    if nargin <5 %no start parameters specified
        A1 = max(y_data);%set amplitude as max value
        A2 = A1;
        m1 = sum(y_data.*x_data)./sum(y_data);%mean as center value
        m2 = m1;
        s1 = sqrt(sum(y_data.*(x_data-m1).^2)./sum(y_data));%std as sigma
        s2 = s1;
        b=0;%assume zero background
        param = [A1,m1,s1,A2,m2,s2,b];
    end
    [gauss,~] = fit(x_data,y_data,Gauss2fun,'StartPoint',param,'Lower',zeros(1,numel(param)),'Upper',[inf(1,numel(param)-1),A1/4]);
    coefficients = coeffvalues(gauss);
    %get maximum amplitude
    [~,Amax] = max([coefficients(1) coefficients(4)]);
    if Amax == 1
        mean = coefficients(2);
    elseif Amax == 2
        mean = coefficients(5);
    end
    GaussFun = Gauss2fun(coefficients(1),coefficients(2),coefficients(3),coefficients(4),coefficients(5),coefficients(6),coefficients(7),x_data);
    G1 = @(A,m,s,b,x) A*exp(-(x-m).^2./s^2)+b;
    Gauss1 = G1(coefficients(1),coefficients(2),coefficients(3),coefficients(7)/2,x_data);
    Gauss2 = G1(coefficients(4),coefficients(5),coefficients(6),coefficients(7)/2,x_data);
    if nargin == 3 %%% output the Gauss with new mean value
        if Amax == 1
            coefficients(2) = mean_new;
        elseif Amax == 2
            coefficients(5) = mean_new;
        end
        GaussFun = Gauss2fun(coefficients(1),coefficients(2),coefficients(3),coefficients(4),coefficients(5),coefficients(6),coefficients(7),x_data);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates GUI elements in fFCS tab and Lifetime Tab %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_fFCS_GUI(obj,~,h)
global BurstData BurstMeta UserValues
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end
if isempty(obj) || ~any(obj == [h.fFCS_Species1_popupmenu, h.fFCS_Species2_popupmenu])
    %%% Update the lists
    file = BurstMeta.SelectedFile;
    species = BurstData{file}.SelectedSpecies;
    if all(species == [0,0])
        num_species = 0;
    else
        num_species = sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
    end
    if num_species > 1
        species_names = BurstData{file}.SpeciesNames(species(1),2:num_species);
        if isfield(BurstMeta,'fFCS') && isfield(BurstMeta.fFCS,'syntheticpatterns_names')
            species_names = [species_names,BurstMeta.fFCS.syntheticpatterns_names];
        end
        species_names = [species_names,{'Load synthetic pattern...'}];
        h.fFCS_Species1_popupmenu.String = species_names;
        h.fFCS_Species1_popupmenu.Value = 1;
        h.fFCS_Species2_popupmenu.String = species_names;
        if num_species > 2
            h.fFCS_Species2_popupmenu.Value = 2;
        else
            h.fFCS_Species2_popupmenu.Value = 1;
        end
        h.Plot_Microtimes_button.Enable = 'on';
    else %%% Set to empty
        h.fFCS_Species1_popupmenu.String = 'Load synthetic pattern...';
        h.fFCS_Species1_popupmenu.Value = 1;
        h.fFCS_Species2_popupmenu.String = 'Load synthetic pattern...';
        h.fFCS_Species2_popupmenu.Value = 1;
        h.Plot_Microtimes_button.Enable = 'off';
        h.Calc_fFCS_Filter_button.Enable = 'off';
        h.Do_fFCS_button.Enable = 'off';
    end
else
    %%% popupmenu selection was changed
    if obj.Value == numel(obj.String) %%% we clicked the last element, which is used to load a synthetic pattern
        [FileName,PathName] = uigetfile({'*.mi','Microtime pattern (*.mi)'},'Choose a synthetic microtime pattern',UserValues.File.BurstBrowserPath);
        if FileName == 0
            return;
        end
        if ~isfield(BurstMeta,'fFCS')
            BurstMeta.fFCS = [];
        end
        if ~isfield(BurstMeta.fFCS,'syntheticpatterns_names')
            BurstMeta.fFCS.syntheticpatterns_names = [];
        end
        BurstMeta.fFCS.syntheticpatterns_names{end+1} = FileName(1:end-3);
        if ~isfield(BurstMeta.fFCS,'syntheticpatterns')
            BurstMeta.fFCS.syntheticpatterns = [];
        end
        BurstMeta.fFCS.syntheticpatterns{end+1} = load(fullfile(PathName,FileName),'-mat');
        Update_fFCS_GUI([],[]);
    else
        %%% a different pattern was selected, do nothing
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Microtime Histograms in fFCS tab %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_MicrotimeHistogramsfFCS(obj,~)
global BurstData BurstMeta BurstTCSPCData UserValues PhotonStream
h = guidata(obj);
Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
%%% Load associated *.bps data if it doesn't exist yet
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
file = BurstMeta.SelectedFile;
h.Calc_fFCS_Filter_button.Enable = 'off';
h.Do_fFCS_button.Enable = 'off';

%%% check if a synthetic pattern has been chosen
if isfield(BurstMeta,'fFCS') && isfield(BurstMeta.fFCS,'syntheticpatterns')
    synthetic_species1 = find(strcmp(h.fFCS_Species1_popupmenu.String{h.fFCS_Species1_popupmenu.Value},BurstMeta.fFCS.syntheticpatterns_names));
    if isempty(synthetic_species1); synthetic_species1 = false;end;
    synthetic_species2 = find(strcmp(h.fFCS_Species2_popupmenu.String{h.fFCS_Species2_popupmenu.Value},BurstMeta.fFCS.syntheticpatterns_names));
    if isempty(synthetic_species2); synthetic_species2 = false;end;
    use_FRET = false;
    downsample = false;
else
    synthetic_species1 = false;
    synthetic_species2 = false;
    use_FRET = UserValues.BurstBrowser.Settings.fFCS_UseFRET;
    downsample = UserValues.BurstBrowser.Settings.Downsample_fFCS;
end

%%% Read out the bursts contained in the different species selections
valid_total = UpdateCuts([BurstData{file}.SelectedSpecies(1),1],file);
if ~synthetic_species1
    species1 = [BurstData{file}.SelectedSpecies(1),h.fFCS_Species1_popupmenu.Value + 1];
    valid_species1 = UpdateCuts(species1,file);
end
if ~synthetic_species2
    species2 = [BurstData{file}.SelectedSpecies(1),h.fFCS_Species2_popupmenu.Value + 1];
    valid_species2 = UpdateCuts(species2,file);
end

Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
if isempty(BurstTCSPCData{file})
    Load_Photons();
end

if UserValues.BurstBrowser.Settings.fFCS_Mode == 2 %include timewindow
    if isempty(PhotonStream{file})
        success = Load_Photons('aps');
        if ~success
            Progress(1,h.Progress_Axes,h.Progress_Text);
            return;
        end
    end
    start = PhotonStream{file}.start(valid_total);
    stop = PhotonStream{file}.stop(valid_total);
    
    use_time = 1; %%% use time or photon window
    if use_time
        %%% histogram the Macrotimes in bins of 10 ms
        bw = ceil(1E-3./BurstData{file}.ClockPeriod);
        bins_time = bw.*(0:1:ceil(PhotonStream{file}.Macrotime(end)./bw));
        if ~isfield(PhotonStream,'MT_bin')
            %%% finds the PHOTON index of the first photon in each
            %%% time bin
            [~, PhotonStream{file}.MT_bin] = histc(PhotonStream{file}.Macrotime,bins_time);
            Progress(0.2,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
            [PhotonStream{file}.unique,PhotonStream{file}.first_idx,~] = unique(PhotonStream{file}.MT_bin);
            Progress(0.4,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
            used_tw = zeros(numel(bins_time),1);
            used_tw(PhotonStream{file}.unique) = PhotonStream{file}.first_idx;
            %%% fill empty time windows with starting index from next non-empty
            %%% if the last time window is empty, use the maximum macrotime
            if used_tw(end) == 0
                last_non_empty = find(used_tw > 0,1,'last');
                used_tw((last_non_empty+1):end) = numel(PhotonStream{file}.Macrotime);
            end
            %%% fill the rest with start from next non-empty time window
            while sum(used_tw == 0) > 0
                used_tw(used_tw == 0) = used_tw(find(used_tw == 0)+1);
            end
            Progress(0.6,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
            PhotonStream{file}.first_idx = used_tw;
        end
        [~, start_bin] = histc(PhotonStream{file}.Macrotime(start),bins_time);
        [~, stop_bin] = histc(PhotonStream{file}.Macrotime(stop),bins_time);
        
        Progress(0.8,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
        
        [~, start_all_bin] = histc(PhotonStream{file}.Macrotime(PhotonStream{file}.start),bins_time);
        [~, stop_all_bin] = histc(PhotonStream{file}.Macrotime(PhotonStream{file}.stop),bins_time);
        
        Progress(1,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
        use = ones(numel(start),1);
        %%% loop over selected bursts
        Progress(0,h.Progress_Axes,h.Progress_Text,'Including Time Window...');
        tw = UserValues.BurstBrowser.Settings.Corr_TimeWindowSize; %%% photon window of (2*tw+1)*10ms
        
        start_tw = start_bin - tw;start_tw(start_tw < 1) = 1;
        stop_tw = stop_bin + tw;stop_tw(stop_tw > (numel(bins_time) -1)) = numel(bins_time)-1;
        
        for i = 1:numel(start_tw)
            %%% Check if ANY burst falls into the time window
            val = (start_all_bin < stop_tw(i)) & (stop_all_bin > start_tw(i));
            %%% Check if they are of the same species
            inval = val & (~valid_total);
            %%% if there are bursts of another species in the timewindow,
            %%% --> remove it
            if sum(inval) > 0
                use(i) = 0;
            end
            %Progress(i/numel(start),h.Progress_Axes,h.Progress_Text,'Including Time Window...');
        end
        
        %%% Construct reduced Macrotime and Channel vector
        Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
        MT_total = cell(sum(use),1);
        CH_total = cell(sum(use),1);
        MI_total = cell(sum(use),1);
        k=1;
        for i = 1:numel(start_tw)
            if use(i)
                range = PhotonStream{file}.first_idx(start_tw(i)):(PhotonStream{file}.first_idx(stop_tw(i)+1)-1);
                MT_total{k} = PhotonStream{file}.Macrotime(range);
                MT_total{k} = MT_total{k}-MT_total{k}(1) +1;
                CH_total{k} = PhotonStream{file}.Channel(range);
                MI_total{k} = PhotonStream{file}.Microtime(range);
                %val = (PhotonStream{file}.MT_bin > start_tw(i)) & (PhotonStream{file}.MT_bin < stop_tw(i) );
                %MT{k} = PhotonStream{file}.Macrotime(val);
                %MT{k} = MT{k}-MT{k}(1) +1;
                %CH{k} = PhotonStream{file}.Channel(val);
                k = k+1;
            end
            %Progress(i/numel(start_tw),h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
        end
    else
        use = ones(numel(start),1);
        %%% loop over selected bursts
        Progress(0,h.Progress_Axes,h.Progress_Text,'Including Time Window...');
        tw = 100; %%% photon window of 100 photons
        
        start_tw = start - tw;
        stop_tw = stop + tw;
        
        for i = 1:numel(start_tw)
            %%% Check if ANY burst falls into the time window
            val = (PhotonStream{file}.start < stop_tw(i)) & (PhotonStream{file}.stop > start_tw(i));
            %%% Check if they are of the same species
            inval = val & (~BurstData{file}.Selected);
            %%% if there are bursts of another species in the timewindow,
            %%% --> remove it
            if sum(inval) > 0
                use(i) = 0;
            end
            %Progress(i/numel(start),h.Progress_Axes,h.Progress_Text,'Including Time Window...');
        end
        
        %%% Construct reduced Macrotime and Channel vector
        Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
        MT_total = cell(sum(use),1);
        CH_total = cell(sum(use),1);
        MI_total = cell(sum(use),1);
        k=1;
        for i = 1:numel(start_tw)
            if use(i)
                MT_total{k} = PhotonStream{file}.Macrotime(start_tw(i):stop_tw(i));MT_total{k} = MT_total{k}-MT_total{k}(1) +1;
                CH_total{k} = PhotonStream{file}.Channel(start_tw(i):stop_tw(i));
                MI_total{k} = PhotonStream{file}.Microtime(start_tw(i):stop_tw(i));
                k = k+1;
            end
            %Progress(i/numel(start_tw),h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
        end
    end
    
    %%% Store burstwise photon stream
    BurstMeta.fFCS.Photons.MT_total = MT_total;
    BurstMeta.fFCS.Photons.MI_total = MI_total;
    BurstMeta.fFCS.Photons.CH_total = CH_total;
elseif any(UserValues.BurstBrowser.Settings.fFCS_Mode == [3,4])
    %%% Load total stream and also include a donor only species
    %%% later (automatically)
    if isempty(PhotonStream{file})
        success=Load_Photons('aps');
        if ~success
            Progress(1,h.Progress_Axes,h.Progress_Text);
            return;
        end
    end
    MT_total = PhotonStream{file}.Macrotime;
    MI_total = PhotonStream{file}.Microtime;
    CH_total = PhotonStream{file}.Channel;
    %BurstMeta.fFCS.Photons.MT_total = MT_total;
    %BurstMeta.fFCS.Photons.MI_total = MI_total;
    %BurstMeta.fFCS.Photons.CH_total = CH_total;
elseif UserValues.BurstBrowser.Settings.fFCS_Mode == 1
    % Burstwise only
    %%% find selected bursts
    MI_total = BurstTCSPCData{file}.Microtime(valid_total);
    CH_total = BurstTCSPCData{file}.Channel(valid_total);
    MT_total = BurstTCSPCData{file}.Macrotime(valid_total);
    for k = 1:numel(MT_total)
        MT_total{k} = MT_total{k}-MT_total{k}(1) +1;
    end
    BurstMeta.fFCS.Photons.MT_total = MT_total;
    BurstMeta.fFCS.Photons.MI_total = MI_total;
    BurstMeta.fFCS.Photons.CH_total = CH_total;
end

Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Microtime Histograms...');
if any(UserValues.BurstBrowser.Settings.fFCS_Mode == [1,2])
    MI_total = vertcat(MI_total{:});
    CH_total = vertcat(CH_total{:});
    MT_total = vertcat(MT_total{:});
end
if ~synthetic_species1
    MI_species{1} = BurstTCSPCData{file}.Microtime(valid_species1);MI_species{1} = vertcat(MI_species{1}{:});
    CH_species{1} = BurstTCSPCData{file}.Channel(valid_species1);CH_species{1} = vertcat(CH_species{1}{:});
else
    switch BurstData{file}.BAMethod
        case {1,2} %%% 2ColorMFD
            %%% assert that pattern has information for donor channel par
            MIPattern = BurstMeta.fFCS.syntheticpatterns{synthetic_species1}.MIPattern;
            if isempty(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}(BurstData{file}.PIE.From(1):BurstData{file}.PIE.To(1))) == 0)
                disp('Loaded pattern does not contain the required information for parallel channel.');
                return;
            end
            if isempty(MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)}(BurstData{file}.PIE.From(2):BurstData{file}.PIE.To(2))) == 0)
                disp('Loaded pattern does not contain the required information for perpendicual channel.');
                return;
            end
            MIPatternPar = MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)};
            MIPatternPer = MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)};
            %%% create dummy variable representing the synthetic decay pattern as photon stamps
            MIPatternPar = round(1E5*MIPatternPar./sum(MIPatternPar)); %%% 1E5 photons
            MIPatternPer = round(1E5*MIPatternPer./sum(MIPatternPer)); %%% 1E5 photons
            MI_species{1} = [];
            CH_species{1} = [1*ones(sum(MIPatternPar),1);2*ones(sum(MIPatternPer),1)];
            for i = 1:numel(MIPatternPar)
                MI_species{1} = [MI_species{1}; i*ones(MIPatternPar(i),1)];
            end
            for i = 1:numel(MIPatternPer)
                MI_species{1} = [MI_species{1}; i*ones(MIPatternPer(i),1)];
            end
        case {3,4,5}
            disp('Only implemented for 2color MFD');
            return;
    end
end
if ~synthetic_species2
    MI_species{2} = BurstTCSPCData{file}.Microtime(valid_species2);MI_species{2} = vertcat(MI_species{2}{:});
    CH_species{2} = BurstTCSPCData{file}.Channel(valid_species2);CH_species{2} = vertcat(CH_species{2}{:});
else
    switch BurstData{file}.BAMethod
        case {1,2} %%% 2ColorMFD
            %%% assert that pattern has information for donor channel par
            MIPattern = BurstMeta.fFCS.syntheticpatterns{synthetic_species2}.MIPattern;
            if isempty(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)}(BurstData{file}.PIE.From(1):BurstData{file}.PIE.To(1))) == 0)
                disp('Loaded pattern does not contain the required information for parallel channel.');
                return;
            end
            if isempty(MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)}) ||  (sum(MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)}(BurstData{file}.PIE.From(2):BurstData{file}.PIE.To(2))) == 0)
                disp('Loaded pattern does not contain the required information for perpendicual channel.');
                return;
            end
            MIPatternPar = MIPattern{BurstData{file}.PIE.Detector(1),BurstData{file}.PIE.Router(1)};
            MIPatternPer = MIPattern{BurstData{file}.PIE.Detector(2),BurstData{file}.PIE.Router(2)};
            %%% create dummy variable representing the synthetic decay pattern as photon stamps
            MIPatternPar = round(1E5*MIPatternPar./sum(MIPatternPar)); %%% 1E5 photons
            MIPatternPer = round(1E5*MIPatternPer./sum(MIPatternPer)); %%% 1E5 photons
            MI_species{2} = [];
            CH_species{2} = [1*ones(sum(MIPatternPar),1);2*ones(sum(MIPatternPer),1)];
            for i = 1:numel(MIPatternPar)
                MI_species{2} = [MI_species{2}; i*ones(MIPatternPar(i),1)];
            end
            for i = 1:numel(MIPatternPer)
                MI_species{2} = [MI_species{2}; i*ones(MIPatternPer(i),1)];
            end
        case {3,4,5}
            disp('Only implemented for 2color MFD');
            return;
    end
end

switch BurstData{file}.BAMethod
    case {1,2} %%% 2ColorMFD
        if use_FRET
            ParChans = [1,3]; %% GG1 and GR1
            PerpChans = [2,4]; %% GG2 and GR2
        else
            ParChans = [1]; %% GG1
            PerpChans = [2]; %% GG2
        end
    case {3,4} %%% 3ColorMFD
        if use_FRET
            ParChans = [1 3 5 7 9]; %% BB1, BG1, BR1, GG1, GR1
            PerpChans = [2 4 6 8 10]; %% BB2, BG2, BR2, GG2, GR2
        else
            ParChans = [1 7]; %% BB1, BG1, BR1, GG1, GR1
            PerpChans = [2 8]; %% BB2, BG2, BR2, GG2, GR2
        end
end
%%% Construct Stacked Microtime Channels
%%% ___| MT1 |___| MT2 + max(MT1) |___
MI_par{1} = [];MI_par{2} = [];
MI_perp{1} = [];MI_perp{2} = [];
%%% read out the limits of the PIE channels
limit_low_par = [0, BurstData{file}.PIE.From(ParChans)];
limit_high_par = [0, BurstData{file}.PIE.To(ParChans)];
dif_par = cumsum(limit_high_par)-cumsum(limit_low_par);
limit_low_perp = [0,BurstData{file}.PIE.From(PerpChans)];
limit_high_perp = [0, BurstData{file}.PIE.To(PerpChans)];
dif_perp = cumsum(limit_high_perp)-cumsum(limit_low_perp);
for i = 1:2 %%% loop over species
    for j = 1:numel(ParChans) %%% loop over channels to consider for par/perp
        MI_par{i} = vertcat(MI_par{i},...
            MI_species{i}(CH_species{i} == ParChans(j)) -...
            limit_low_par(j+1) + 1 +...
            dif_par(j));
        MI_perp{i} = vertcat(MI_perp{i},...
            MI_species{i}(CH_species{i} == PerpChans(j)) -...
            limit_low_perp(j+1) + 1 +...
            dif_perp(j));
        %         MI_par{i} = vertcat(MI_par{i},...
        %             MI_species{i}(CH_species{i} == ParChans(j)) -...
        %             limit_low_par(j+1) + 1 +...
        %             limit_high_par(j)-limit_low_par(j));
        %         MI_perp{i} = vertcat(MI_perp{i},...
        %             MI_species{i}(CH_species{i} == PerpChans(j)) -...
        %             limit_low_perp(j+1) + 1 +...
        %             limit_high_perp(j)-limit_low_perp(j));
    end
end

if UserValues.BurstBrowser.Settings.fFCS_Mode == 4 %%% add donor only species
    valid_donly = BurstData{file}.DataArray(:,2) > 0.95; %%% Stoichiometry threshold
    MI_donly = BurstTCSPCData{file}.Microtime(valid_donly);MI_donly = vertcat(MI_donly{:});
    CH_donly = BurstTCSPCData{file}.Channel(valid_donly);CH_donly = vertcat(CH_donly{:});
    MI_donly_par = [];MI_donly_perp = [];
    for j = 1:numel(ParChans) %%% loop over channels to consider for par/perp
        MI_donly_par = vertcat(MI_donly_par,...
            MI_donly(CH_donly == ParChans(j)) -...
            limit_low_par(j+1) + 1 +...
            dif_par(j));
        MI_donly_perp = vertcat(MI_donly_perp,...
            MI_donly(CH_donly == PerpChans(j)) -...
            limit_low_perp(j+1) + 1 +...
            dif_perp(j));
    end
end
MI_total_par = [];
MI_total_perp = [];
MT_total_par = [];
MT_total_perp = [];
for i = 1:numel(ParChans)
    MI_total_par = vertcat(MI_total_par,...
        MI_total(CH_total == ParChans(i)) -...
        limit_low_par(i+1) + 1 +...
        dif_par(i));
    %     MI_total_par = vertcat(MI_total_par,...
    %         MI_total(CH_total == ParChans(i)) -...
    %         limit_low_par(i+1) + 1 +...
    %         limit_high_par(i)-limit_low_par(i));
    MT_total_par = vertcat(MT_total_par,...
        MT_total(CH_total == ParChans(i)));
    MI_total_perp = vertcat(MI_total_perp,...
        MI_total(CH_total == PerpChans(i)) -...
        limit_low_perp(i+1) + 1 +...
        dif_perp(i));
    %     MI_total_perp = vertcat(MI_total_perp,...
    %         MI_total(CH_total == PerpChans(i)) -...
    %         limit_low_perp(i+1) + 1 +...
    %         limit_high_perp(i)-limit_low_perp(i));
    MT_total_perp = vertcat(MT_total_perp,...
        MT_total(CH_total == PerpChans(i)));
end

%%% sort photons
[MT_total_par,idx] = sort(MT_total_par);
MI_total_par = MI_total_par(idx);
[MT_total_perp,idx] = sort(MT_total_perp);
MI_total_perp = MI_total_perp(idx);

%%% Burstwise treatment if using time window or burst photons only
if any(UserValues.BurstBrowser.Settings.fFCS_Mode == [1,2])
    BurstMeta.fFCS.Photons.MI_total_par = cell(numel(BurstMeta.fFCS.Photons.MT_total),1);
    BurstMeta.fFCS.Photons.MI_total_perp = cell(numel(BurstMeta.fFCS.Photons.MT_total),1);
    BurstMeta.fFCS.Photons.MT_total_par = cell(numel(BurstMeta.fFCS.Photons.MT_total),1);
    BurstMeta.fFCS.Photons.MT_total_perp = cell(numel(BurstMeta.fFCS.Photons.MT_total),1);
    for k = 1:numel(BurstMeta.fFCS.Photons.MT_total)
        for i = 1:numel(ParChans)
            BurstMeta.fFCS.Photons.MI_total_par{k} = vertcat(BurstMeta.fFCS.Photons.MI_total_par{k},...
                BurstMeta.fFCS.Photons.MI_total{k}(BurstMeta.fFCS.Photons.CH_total{k} == ParChans(i)) -...
                limit_low_par(i+1) + 1 +...
                dif_par(i));
            BurstMeta.fFCS.Photons.MT_total_par{k} = vertcat(BurstMeta.fFCS.Photons.MT_total_par{k},...
                BurstMeta.fFCS.Photons.MT_total{k}(BurstMeta.fFCS.Photons.CH_total{k} == ParChans(i)));
            BurstMeta.fFCS.Photons.MI_total_perp{k} = vertcat(BurstMeta.fFCS.Photons.MI_total_perp{k},...
                BurstMeta.fFCS.Photons.MI_total{k}(BurstMeta.fFCS.Photons.CH_total{k} == PerpChans(i)) -...
                limit_low_perp(i+1) + 1 +...
                dif_perp(i));
            BurstMeta.fFCS.Photons.MT_total_perp{k} = vertcat(BurstMeta.fFCS.Photons.MT_total_perp{k},...
                BurstMeta.fFCS.Photons.MT_total{k}(BurstMeta.fFCS.Photons.CH_total{k} == PerpChans(i)));
        end
        
        %%% sort photons
        [BurstMeta.fFCS.Photons.MT_total_par{k},idx] = sort(BurstMeta.fFCS.Photons.MT_total_par{k});
        BurstMeta.fFCS.Photons.MI_total_par{k} = BurstMeta.fFCS.Photons.MI_total_par{k}(idx);
        [BurstMeta.fFCS.Photons.MT_total_perp{k},idx] = sort(BurstMeta.fFCS.Photons.MT_total_perp{k});
        BurstMeta.fFCS.Photons.MI_total_perp{k} = BurstMeta.fFCS.Photons.MI_total_perp{k}(idx);
    end
elseif any(UserValues.BurstBrowser.Settings.fFCS_Mode == [3,4]) % use sorted photon stream
    BurstMeta.fFCS.Photons.MT_total_par = MT_total_par;
    BurstMeta.fFCS.Photons.MI_total_par = MI_total_par;
    BurstMeta.fFCS.Photons.MT_total_perp = MT_total_perp;
    BurstMeta.fFCS.Photons.MI_total_perp = MI_total_perp;
end
%%% Downsampling if checked
%%% New binwidth in picoseconds
if downsample
    if ~isfield(BurstData{file}.FileInfo,'Resolution')
        TACChannelWidth = BurstData{file}.FileInfo.ClockPeriod*1E9/BurstData{file}.FileInfo.MI_Bins;
    elseif isfield(BurstData{file}.FileInfo,'Resolution') %%% HydraHarp Data
        TACChannelWidth = BurstData{file}.FileInfo.Resolution/1000;
    end
    new_bin_width = floor(UserValues.BurstBrowser.Settings.Downsample_fFCS_Time/(1000*TACChannelWidth));
    MI_total_par = ceil(double(MI_total_par)/new_bin_width);
    MI_total_perp = ceil(double(MI_total_perp)/new_bin_width);
    for i = 1:2
        MI_par{i} = ceil(double(MI_par{i})/new_bin_width);
        MI_perp{i} = ceil(double(MI_perp{i})/new_bin_width);
    end
    switch UserValues.BurstBrowser.Settings.fFCS_Mode
        case {3,4}
            BurstMeta.fFCS.Photons.MI_total_par = MI_total_par;
            BurstMeta.fFCS.Photons.MI_total_perp = MI_total_perp;
        case {1,2}
            BurstMeta.fFCS.Photons.MI_total_par = cellfun(@(x) ceil(double(x)/new_bin_width),BurstMeta.fFCS.Photons.MI_total_par,'UniformOutput',false);
            BurstMeta.fFCS.Photons.MI_total_perp = cellfun(@(x) ceil(double(x)/new_bin_width),BurstMeta.fFCS.Photons.MI_total_perp,'UniformOutput',false);     
    end
end

%%% Calculate the histograms
maxTAC_par = max(MI_total_par);
maxTAC_perp = max(MI_total_perp);
BurstMeta.fFCS.TAC_par = 1:1:(maxTAC_par);
BurstMeta.fFCS.TAC_perp = 1:1:(maxTAC_perp);
for i = 1:2
    BurstMeta.fFCS.hist_MIpar_Species{i} = histc(MI_par{i},BurstMeta.fFCS.TAC_par);
    BurstMeta.fFCS.hist_MIperp_Species{i} = histc(MI_perp{i},BurstMeta.fFCS.TAC_perp);
end
BurstMeta.fFCS.hist_MItotal_par = histc(MI_total_par,BurstMeta.fFCS.TAC_par);
BurstMeta.fFCS.hist_MItotal_perp = histc(MI_total_perp,BurstMeta.fFCS.TAC_perp);

%%% restrict species microtime histograms to valid region if synthetic species is selected
if synthetic_species1 || synthetic_species2
    %%% range for par channel
    valid_range = [1,numel(BurstMeta.fFCS.TAC_par)];
    if synthetic_species1
        valid_range(1) = max(valid_range(1),find(BurstMeta.fFCS.hist_MIpar_Species{1} > 0,1,'first'));
        valid_range(2) = min(valid_range(2),find(BurstMeta.fFCS.hist_MIpar_Species{1} > 0,1,'last')+1);
    end
    if synthetic_species2
        valid_range(1) = max(valid_range(1),find(BurstMeta.fFCS.hist_MIpar_Species{2} > 0,1,'first'));
        valid_range(2) = min(valid_range(2),find(BurstMeta.fFCS.hist_MIpar_Species{2} > 0,1,'last')+1);
    end
    valid_par = false(numel(BurstMeta.fFCS.TAC_par),1);
    valid_par(valid_range(1):valid_range(2)) = true;
    %%% range for perp channel
    valid_range = [1,numel(BurstMeta.fFCS.TAC_perp)];
    if synthetic_species1
        valid_range(1) = max(valid_range(1),find(BurstMeta.fFCS.hist_MIperp_Species{1} > 0,1,'first'));
        valid_range(2) = min(valid_range(2),find(BurstMeta.fFCS.hist_MIperp_Species{1} > 0,1,'last')+1);
    end
    if synthetic_species2
        valid_range(1) = max(valid_range(1),find(BurstMeta.fFCS.hist_MIperp_Species{2} > 0,1,'first'));
        valid_range(2) = min(valid_range(2),find(BurstMeta.fFCS.hist_MIperp_Species{2} > 0,1,'last')+1);
    end
    valid_perp = false(numel(BurstMeta.fFCS.TAC_perp),1);
    valid_perp(valid_range(1):valid_range(2)) = true;
    %%% set invalid region to zero
    for i = 1:2
        BurstMeta.fFCS.hist_MIpar_Species{i}(~valid_par) = 0;
        BurstMeta.fFCS.hist_MIperp_Species{i}(~valid_perp) = 0;
    end
end
%%% Plot the Microtime histograms
BurstMeta.Plots.fFCS.Microtime_Total_par.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.Microtime_Total_par.YData = BurstMeta.fFCS.hist_MItotal_par./sum(BurstMeta.fFCS.hist_MItotal_par);
BurstMeta.Plots.fFCS.Microtime_Species1_par.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.Microtime_Species1_par.YData = BurstMeta.fFCS.hist_MIpar_Species{1}./sum( BurstMeta.fFCS.hist_MIpar_Species{1});
BurstMeta.Plots.fFCS.Microtime_Species2_par.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.Microtime_Species2_par.YData = BurstMeta.fFCS.hist_MIpar_Species{2}./sum(BurstMeta.fFCS.hist_MIpar_Species{2});

BurstMeta.Plots.fFCS.Microtime_Total_perp.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.Microtime_Total_perp.YData = BurstMeta.fFCS.hist_MItotal_perp./sum(BurstMeta.fFCS.hist_MItotal_perp);
BurstMeta.Plots.fFCS.Microtime_Species1_perp.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.Microtime_Species1_perp.YData = BurstMeta.fFCS.hist_MIperp_Species{1}./sum(BurstMeta.fFCS.hist_MIperp_Species{1});
BurstMeta.Plots.fFCS.Microtime_Species2_perp.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.Microtime_Species2_perp.YData = BurstMeta.fFCS.hist_MIperp_Species{2}./sum(BurstMeta.fFCS.hist_MIperp_Species{2});

%%% Add IRF Pattern if existent
if isfield(BurstData{file},'ScatterPattern') && UserValues.BurstBrowser.Settings.fFCS_UseIRF
    BurstMeta.Plots.fFCS.IRF_par.Visible = 'on';
    BurstMeta.Plots.fFCS.IRF_perp.Visible = 'on';
    
    hScat_par = [];
    hScat_perp = [];
    for i = 1:numel(ParChans)
        hScat_par = [hScat_par, BurstData{file}.ScatterPattern{ParChans(i)}(limit_low_par(i+1):limit_high_par(i+1))];
        hScat_perp = [hScat_perp, BurstData{file}.ScatterPattern{PerpChans(i)}(limit_low_perp(i+1):limit_high_perp(i+1))];
    end
    
    if UserValues.BurstBrowser.Settings.Downsample_fFCS
        %%% Downsampling if checked
        hScat_par = downsamplebin(hScat_par,new_bin_width);hScat_par = hScat_par';
        hScat_perp = downsamplebin(hScat_perp,new_bin_width);hScat_perp = hScat_perp';
    end
    
    %%% normaize with respect to the total decay histogram
    hScat_par = hScat_par./max(hScat_par).*max(BurstMeta.fFCS.hist_MItotal_par./sum(BurstMeta.fFCS.hist_MItotal_par));
    hScat_perp = hScat_perp./max(hScat_perp).*max(BurstMeta.fFCS.hist_MItotal_perp./sum(BurstMeta.fFCS.hist_MItotal_perp));
    
    %%% restrict scatter microtime histograms to valid region if synthetic species is selected
    if synthetic_species1 || synthetic_species2
        hScat_par(~valid_par) = 0;
        hScat_perp(~valid_perp) = 0;
    end
    %%% store in BurstMeta
    BurstMeta.fFCS.hScat_par = hScat_par(1:numel(BurstMeta.fFCS.TAC_par));
    BurstMeta.fFCS.hScat_perp = hScat_perp(1:numel(BurstMeta.fFCS.TAC_perp));
    %%% Update Plots
    BurstMeta.Plots.fFCS.IRF_par.XData = BurstMeta.fFCS.TAC_par;
    BurstMeta.Plots.fFCS.IRF_par.YData = BurstMeta.fFCS.hScat_par;
    BurstMeta.Plots.fFCS.IRF_perp.XData = BurstMeta.fFCS.TAC_perp;
    BurstMeta.Plots.fFCS.IRF_perp.YData = BurstMeta.fFCS.hScat_perp;
elseif ~isfield(BurstData{file},'ScatterPattern') || ~UserValues.BurstBrowser.Settings.fFCS_UseIRF
    %%% Hide IRF plots
    BurstMeta.Plots.fFCS.IRF_par.Visible = 'off';
    BurstMeta.Plots.fFCS.IRF_perp.Visible = 'off';
end
%%% Add Donly pattern if checked
if UserValues.BurstBrowser.Settings.fFCS_Mode == 4
    BurstMeta.Plots.fFCS.Microtime_DOnly_par.Visible = 'on';
    BurstMeta.Plots.fFCS.Microtime_DOnly_perp.Visible = 'on';
    
    if UserValues.BurstBrowser.Settings.Downsample_fFCS
        MI_donly_par = ceil(double(MI_donly_par)/new_bin_width);
        MI_donly_perp = ceil(double(MI_donly_perp)/new_bin_width);
        %%% Downsampling if checked
        %hDOnly_par = downsamplebin(hDOnly_par,new_bin_width);hDOnly_par = hDOnly_par';
        %hDOnly_perp = downsamplebin(hDOnly_perp,new_bin_width);hDOnly_perp = hDOnly_perp';
    end
    
    hDOnly_par = histc(MI_donly_par,BurstMeta.fFCS.TAC_par);
    hDOnly_perp = histc(MI_donly_perp,BurstMeta.fFCS.TAC_perp);
    
    %%% normaize with respect to the total decay histogram
    hDOnly_par = hDOnly_par./sum(hDOnly_par);
    hDOnly_perp = hDOnly_perp./sum(hDOnly_perp);
    
    %%% store in BurstMeta
    BurstMeta.fFCS.hDOnly_par = hDOnly_par(1:numel(BurstMeta.fFCS.TAC_par));
    BurstMeta.fFCS.hDOnly_perp = hDOnly_perp(1:numel(BurstMeta.fFCS.TAC_perp));
    %%% Update Plots
    BurstMeta.Plots.fFCS.Microtime_DOnly_par.XData = BurstMeta.fFCS.TAC_par;
    BurstMeta.Plots.fFCS.Microtime_DOnly_par.YData = BurstMeta.fFCS.hDOnly_par;
    BurstMeta.Plots.fFCS.Microtime_DOnly_perp.XData = BurstMeta.fFCS.TAC_perp;
    BurstMeta.Plots.fFCS.Microtime_DOnly_perp.YData = BurstMeta.fFCS.hDOnly_perp;
else
    BurstMeta.Plots.fFCS.Microtime_DOnly_par.Visible = 'off';
    BurstMeta.Plots.fFCS.Microtime_DOnly_perp.Visible = 'off';
end
h.Calc_fFCS_Filter_button.Enable = 'on';
axis(h.axes_fFCS_DecayPar,'tight');
axis(h.axes_fFCS_DecayPerp,'tight');
h.fFCS_axes_tab.SelectedTab = h.fFCS_axes_decay_tab;
Progress(1,h.Progress_Axes,h.Progress_Text);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Prepare data for subensemble TCSPC fitting %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Send_To_TauFit(obj,~)
% Close TauFit cause it might be called from somewhere else than before
delete(findobj('Tag','TauFit'));
clear global TauFitData
global BurstData BurstTCSPCData UserValues TauFitData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');

file = BurstMeta.SelectedFile;
Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
% User clicks Send Species to TauFit
Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
if isempty(BurstTCSPCData{file})
    Load_Photons();
end

TauFitData.FileName = fullfile(BurstData{file}.PathName, BurstData{file}.FileName);
TauFitData.BAMethod = BurstData{file}.BAMethod;
TauFitData.FileInfo = BurstData{file}.FileInfo;
TauFitData.PIE = BurstData{file}.PIE;
TauFitData.SpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies};
TauFitData.FileName = BurstData{file}.FileName;
TauFitData.Path = BurstData{file}.PathName;
%%% Read out the bursts contained in the different species selections
valid = UpdateCuts([BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)],file);

%%% bootstrapping for selecting a random subset of bursts
%if 1
%    valid = find(valid);
%    valid = valid(randi(numel(valid),size(valid,1),size(valid,2)));
%    valid = valid(1:floor(numel(valid)/4));
%end

Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Microtime Histograms...');

%%% find selected bursts
MI_total = BurstTCSPCData{file}.Microtime(valid);
MI_total = vertcat(MI_total{:});
CH_total = BurstTCSPCData{file}.Channel(valid);
CH_total = vertcat(CH_total{:});
switch BurstData{file}.BAMethod
    case {1,2}
        %%% 2color MFD
        c{1} = [1,2]; %% GG
        c{2} = [5,6]; %% RR
        c{3} = [3,4];
    case {3,4}
        %%% 3color MFD
        c{1} = [1,2]; %% BB
        c{2} = [7,8]; %% GG
        c{3} = [11,12];%% RR
    case 5
        c{1} = [1,1];
        c{2} = [3,3];
end
for chan = 1:size(c,2)
    MI_par = MI_total(CH_total == c{chan}(1));
    MI_perp = MI_total(CH_total == c{chan}(2));
    
    %%% Calculate the histograms
    MI_par = histc(MI_par,1:BurstData{file}.FileInfo.MI_Bins);
    MI_perp = histc(MI_perp,1:BurstData{file}.FileInfo.MI_Bins);
    TauFitData.hMI_Par{chan} = MI_par(BurstData{file}.PIE.From(c{chan}(1)):min([BurstData{file}.PIE.To(c{chan}(1)) end]));
    TauFitData.hMI_Per{chan} = MI_perp(BurstData{file}.PIE.From(c{chan}(2)):min([BurstData{file}.PIE.To(c{chan}(2)) end]));
    
    % IRF
    TauFitData.hIRF_Par{chan} = BurstData{file}.IRF{c{chan}(1)}(BurstData{file}.PIE.From(c{chan}(1)):min([BurstData{file}.PIE.To(c{chan}(1)) end]));
    TauFitData.hIRF_Per{chan} = BurstData{file}.IRF{c{chan}(2)}(BurstData{file}.PIE.From(c{chan}(2)):min([BurstData{file}.PIE.To(c{chan}(2)) end]));
    TauFitData.hIRF_Par{chan} = (TauFitData.hIRF_Par{chan}./max(TauFitData.hIRF_Par{chan})).*max(TauFitData.hMI_Par{chan});
    TauFitData.hIRF_Per{chan} = (TauFitData.hIRF_Per{chan}./max(TauFitData.hIRF_Per{chan})).*max(TauFitData.hMI_Per{chan});
    
    % Scatter Pattern
    TauFitData.hScat_Par{chan} = BurstData{file}.ScatterPattern{c{chan}(1)}(BurstData{file}.PIE.From(c{chan}(1)):min([BurstData{file}.PIE.To(c{chan}(1)) end]));
    TauFitData.hScat_Per{chan} = BurstData{file}.ScatterPattern{c{chan}(2)}(BurstData{file}.PIE.From(c{chan}(2)):min([BurstData{file}.PIE.To(c{chan}(2)) end]));
    TauFitData.hScat_Par{chan} = (TauFitData.hScat_Par{chan}./max(TauFitData.hScat_Par{chan})).*max(TauFitData.hMI_Par{chan});
    TauFitData.hScat_Per{chan} = (TauFitData.hScat_Per{chan}./max(TauFitData.hScat_Per{chan})).*max(TauFitData.hMI_Per{chan});
    
    %%% Generate XData
    TauFitData.XData_Par{chan} = (BurstData{file}.PIE.From(c{chan}(1)):BurstData{file}.PIE.To(c{chan}(1))) - BurstData{file}.PIE.From(c{chan}(1));
    TauFitData.XData_Per{chan} = (BurstData{file}.PIE.From(c{chan}(2)):BurstData{file}.PIE.To(c{chan}(2))) - BurstData{file}.PIE.From(c{chan}(2));
end
TauFitData.TACRange = BurstData{file}.FileInfo.TACRange; % in seconds
TauFitData.MI_Bins = double(BurstData{file}.FileInfo.MI_Bins); %Anders, why double
if ~isfield(BurstData{file}.FileInfo,'Resolution')
    % in nanoseconds/microtime bin
    TauFitData.TACChannelWidth = TauFitData.TACRange*1E9/TauFitData.MI_Bins;
elseif isfield(BurstData{file}.FileInfo,'Resolution') %%% HydraHarp Data
    TauFitData.TACChannelWidth = BurstData{file}.FileInfo.Resolution/1000;
end
TauFit(obj,[]);
Progress(1,h.Progress_Axes,h.Progress_Text);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates fFCS filter and updates plots %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Calc_fFCS_Filters(obj,~)
global BurstMeta BurstData UserValues
h = guidata(obj);
file = BurstMeta.SelectedFile;
%%% Concatenate Decay Patterns
Decay_par = [BurstMeta.fFCS.hist_MIpar_Species{1},...
    BurstMeta.fFCS.hist_MIpar_Species{2}];
if isfield(BurstData{file},'ScatterPattern') && UserValues.BurstBrowser.Settings.fFCS_UseIRF %%% include scatter pattern
    if isfield(BurstMeta.fFCS,'hScat_par')
        Decay_par = [Decay_par, BurstMeta.fFCS.hScat_par(1:size(Decay_par,1))'];
    end
end

if UserValues.BurstBrowser.Settings.fFCS_Mode == 4 %%% include DOnly pattern
    if isfield(BurstMeta.fFCS,'hDOnly_par')
        Decay_par = [Decay_par, BurstMeta.fFCS.hDOnly_par(1:size(Decay_par,1))];
    end
end
Decay_par = Decay_par./repmat(sum(Decay_par,1),size(Decay_par,1),1);
Decay_total_par = BurstMeta.fFCS.hist_MItotal_par;
Decay_total_par(Decay_total_par == 0) = 1; %%% fill zeros with eps
Decay_perp = [BurstMeta.fFCS.hist_MIperp_Species{1},...
    BurstMeta.fFCS.hist_MIperp_Species{2}];
if isfield(BurstData{file},'ScatterPattern') && UserValues.BurstBrowser.Settings.fFCS_UseIRF %%% include scatter pattern
    if isfield(BurstMeta.fFCS,'hScat_perp')
        Decay_perp = [Decay_perp, BurstMeta.fFCS.hScat_perp(1:size(Decay_perp,1))'];
    end
end
if UserValues.BurstBrowser.Settings.fFCS_Mode == 4 %%% include DOnly pattern
    if isfield(BurstMeta.fFCS,'hDOnly_perp')
        Decay_perp = [Decay_perp, BurstMeta.fFCS.hDOnly_perp(1:size(Decay_perp,1))];
    end
end
Decay_perp = Decay_perp./repmat(sum(Decay_perp,1),size(Decay_perp,1),1);
Decay_total_perp = BurstMeta.fFCS.hist_MItotal_perp;
Decay_total_perp(Decay_total_perp == 0) = 1; %%% fill zeros with 1
%%% calculate the diagonal over the Decay_total
diag_Decay_total_par = zeros(numel(Decay_total_par));
for i = 1:numel(Decay_total_par)
    diag_Decay_total_par(i,i) = 1/Decay_total_par(i);
end
diag_Decay_total_perp = zeros(numel(Decay_total_perp));
for i = 1:numel(Decay_total_perp)
    diag_Decay_total_perp(i,i) = 1/Decay_total_perp(i);
end

BurstMeta.fFCS.filters_par = (Decay_par'*diag_Decay_total_par*Decay_par)^(-1)*Decay_par'*diag_Decay_total_par;
BurstMeta.fFCS.reconstruction_par = sum((Decay_par'*diag_Decay_total_par*Decay_par)^(-1)*Decay_par',1);
BurstMeta.fFCS.weighted_residuals_par = (Decay_total_par'-BurstMeta.fFCS.reconstruction_par)./(sqrt(Decay_total_par'));
BurstMeta.fFCS.filters_perp = (Decay_perp'*diag_Decay_total_perp*Decay_perp)^(-1)*Decay_perp'*diag_Decay_total_perp;
BurstMeta.fFCS.reconstruction_perp = sum((Decay_perp'*diag_Decay_total_perp*Decay_perp)^(-1)*Decay_perp',1);
BurstMeta.fFCS.weighted_residuals_perp = (Decay_total_perp'-BurstMeta.fFCS.reconstruction_perp)./(sqrt(Decay_total_perp'));

%%% Update plots
BurstMeta.Plots.fFCS.FilterPar_Species1.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.FilterPar_Species1.YData = BurstMeta.fFCS.filters_par(1,:);
BurstMeta.Plots.fFCS.FilterPar_Species2.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.FilterPar_Species2.YData = BurstMeta.fFCS.filters_par(2,:);
if size(BurstMeta.fFCS.filters_par,1) > 2
    BurstMeta.Plots.fFCS.FilterPar_IRF.Visible = 'on';
    BurstMeta.Plots.fFCS.FilterPar_IRF.XData = BurstMeta.fFCS.TAC_par;
    BurstMeta.Plots.fFCS.FilterPar_IRF.YData = BurstMeta.fFCS.filters_par(3,:);
else
    BurstMeta.Plots.fFCS.FilterPar_IRF.Visible = 'off';
end
if size(BurstMeta.fFCS.filters_par,1) > 3
    BurstMeta.Plots.fFCS.FilterPar_DOnly.Visible = 'on';
    BurstMeta.Plots.fFCS.FilterPar_DOnly.XData = BurstMeta.fFCS.TAC_par;
    BurstMeta.Plots.fFCS.FilterPar_DOnly.YData = BurstMeta.fFCS.filters_par(4,:);
else
    BurstMeta.Plots.fFCS.FilterPar_DOnly.Visible = 'off';
end
BurstMeta.Plots.fFCS.Reconstruction_Decay_Par.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.Reconstruction_Decay_Par.YData = BurstMeta.fFCS.hist_MItotal_par;
BurstMeta.Plots.fFCS.Reconstruction_Par.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.Reconstruction_Par.YData = BurstMeta.fFCS.reconstruction_par;
BurstMeta.Plots.fFCS.Weighted_Residuals_Par.XData = BurstMeta.fFCS.TAC_par;
BurstMeta.Plots.fFCS.Weighted_Residuals_Par.YData = BurstMeta.fFCS.weighted_residuals_par;

BurstMeta.Plots.fFCS.FilterPerp_Species1.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.FilterPerp_Species1.YData = BurstMeta.fFCS.filters_perp(1,:);
BurstMeta.Plots.fFCS.FilterPerp_Species2.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.FilterPerp_Species2.YData = BurstMeta.fFCS.filters_perp(2,:);
if size(BurstMeta.fFCS.filters_perp,1) > 2
    BurstMeta.Plots.fFCS.FilterPerp_IRF.Visible = 'on';
    BurstMeta.Plots.fFCS.FilterPerp_IRF.XData = BurstMeta.fFCS.TAC_perp;
    BurstMeta.Plots.fFCS.FilterPerp_IRF.YData = BurstMeta.fFCS.filters_perp(3,:);
else
    BurstMeta.Plots.fFCS.FilterPerp_IRF.Visible = 'off';
end
if size(BurstMeta.fFCS.filters_perp,1) > 3
    BurstMeta.Plots.fFCS.FilterPerp_DOnly.Visible = 'on';
    BurstMeta.Plots.fFCS.FilterPerp_DOnly.XData = BurstMeta.fFCS.TAC_perp;
    BurstMeta.Plots.fFCS.FilterPerp_DOnly.YData = BurstMeta.fFCS.filters_perp(4,:);
else
    BurstMeta.Plots.fFCS.FilterPerp_DOnly.Visible = 'off';
end
BurstMeta.Plots.fFCS.Reconstruction_Decay_Perp.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.Reconstruction_Decay_Perp.YData = BurstMeta.fFCS.hist_MItotal_perp;
BurstMeta.Plots.fFCS.Reconstruction_Perp.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.Reconstruction_Perp.YData = BurstMeta.fFCS.reconstruction_perp;
BurstMeta.Plots.fFCS.Weighted_Residuals_Perp.XData = BurstMeta.fFCS.TAC_perp;
BurstMeta.Plots.fFCS.Weighted_Residuals_Perp.YData = BurstMeta.fFCS.weighted_residuals_perp;

axis(h.axes_fFCS_FilterPar,'tight');
axis(h.axes_fFCS_FilterPerp,'tight');
axis(h.axes_fFCS_ReconstructionPar,'tight');h.axes_fFCS_ReconstructionPar.YScale = 'log';
axis(h.axes_fFCS_ReconstructionPerp,'tight');h.axes_fFCS_ReconstructionPerp.YScale = 'log';
axis(h.axes_fFCS_ReconstructionParResiduals,'tight');
axis(h.axes_fFCS_ReconstructionPerpResiduals,'tight');

h.Do_fFCS_button.Enable = 'on';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Does fFCS Correlation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_fFCS(obj,~)
global BurstMeta BurstData UserValues
if isempty(obj)
    h = guidata(findobj('Tag','BurstBrowser'));
else
    h = guidata(obj);
end
%%% clear previous result
BurstMeta.fFCS.Result = struct;
BurstMeta.fFCS.Result.FileName = [];
BurstMeta.fFCS.Result.Header = [];
BurstMeta.fFCS.Result.Counts = [];
BurstMeta.fFCS.Result.Valid = [];
BurstMeta.fFCS.Result.Cor_Times = [];
BurstMeta.fFCS.Result.Cor_Average = [];
BurstMeta.fFCS.Result.Cor_SEM = [];
BurstMeta.fFCS.Result.Cor_Array = [];
%%% Set Up Progress Bar
Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
%%% define channels
Name = {h.fFCS_Species1_popupmenu.String{h.fFCS_Species1_popupmenu.Value},...
        h.fFCS_Species2_popupmenu.String{h.fFCS_Species2_popupmenu.Value}};
file = BurstMeta.SelectedFile;
CorrMat = true(2);
NumChans = size(CorrMat,1);
%%% Read out photons and filters from BurstMeta
%MT_par = BurstMeta.fFCS.Photons.MT_total_par;
%MT_perp = BurstMeta.fFCS.Photons.MT_total_perp;
%MI_par = BurstMeta.fFCS.Photons.MI_total_par;
%MI_perp = BurstMeta.fFCS.Photons.MI_total_perp;
filters_par{1} = BurstMeta.fFCS.filters_par(1,:)';
filters_par{2} = BurstMeta.fFCS.filters_par(2,:)';
filters_perp{1} = BurstMeta.fFCS.filters_perp(1,:)';
filters_perp{2} = BurstMeta.fFCS.filters_perp(2,:)';

count = 0;
for i=1:NumChans
    for j=1:NumChans
        if CorrMat(i,j)
            MT1 = BurstMeta.fFCS.Photons.MT_total_par;
            MT2 = BurstMeta.fFCS.Photons.MT_total_perp;
            MIpar = BurstMeta.fFCS.Photons.MI_total_par;
            MIperp = BurstMeta.fFCS.Photons.MI_total_perp;
            if any(UserValues.BurstBrowser.Settings.fFCS_Mode == [1,2])
                inval = cellfun(@isempty,MT1) | cellfun(@isempty,MT2);
                MT1(inval) = []; MT2(inval) = [];
                MIpar(inval) = [];
                MIperp(inval) = [];
                %%% prepare weights
                Weights1 = cell(numel(MT1),1);
                Weights2 = cell(numel(MT1),1);
                for k = 1:numel(MT1)
                    Weights1{k} = filters_par{i}(MIpar{k});
                    Weights2{k} = filters_perp{j}(MIperp{k});
                end
                %%% Calculates the maximum inter-photon time in clock ticks
                Maxtime=cellfun(@(x,y) max([x(end) y(end)]),MT1,MT2);
                %%% Do Correlation
                [Cor_Array,Cor_Times]=CrossCorrelation(MT1,MT2,Maxtime,Weights1,Weights2,2);
            elseif any(UserValues.BurstBrowser.Settings.fFCS_Mode == [3,4]) %%% Full correlation
                Weights1_dummy = filters_par{i}(MIpar);
                Weights2_dummy = filters_perp{j}(MIperp);
                Maxtime = max([MT1(end),MT2(end)]);
                %%% Split in 10 timebins
                Times = ceil(linspace(0,Maxtime,11));
                Data1 = cell(10,1);
                Data2 = cell(10,1);
                Weights1 = cell(10,1);
                Weights2 = cell(10,1);
                for k = 1:10
                    Data1{k} = MT1(MT1 >= Times(k) &...
                        MT1 <Times(k+1)) - Times(k);
                    Weights1{k} = Weights1_dummy(MT1 >= Times(k) &...
                        MT1 <Times(k+1));
                    Data2{k} = MT2(MT2 >= Times(k) &...
                        MT2 <Times(k+1)) - Times(k);
                    Weights2{k} = Weights2_dummy(MT2 >= Times(k) &...
                        MT2 <Times(k+1));
                end
                %%% Do Correlation
                [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data2,Maxtime,Weights1,Weights2);
            end
            Cor_Times = Cor_Times*BurstData{file}.ClockPeriod;
            
            %%% Calculates average and standard error of mean (without tinv_table yet
            if numel(Cor_Array)>1
                Cor_Average=mean(Cor_Array,2);
                Cor_SEM=std(Cor_Array,0,2);
            else
                Cor_Average=Cor_Array{1};
                Cor_SEM=Cor_Array{1};
            end
            
            %%% Save the correlation file
            %%% Generates filename
            filename = fullfile(BurstData{file}.PathName,BurstData{file}.FileName);
            Current_FileName=[filename(1:end-4) '_' Name{i} '_x_' Name{j} '.mcor'];
            
            BurstMeta.fFCS.Result.FileName{end+1} = Current_FileName;
            BurstMeta.fFCS.Result.Header{end+1} = ['Correlation file for: ' strrep(filename,'\','\\') ' of Channels ' Name{i} ' cross ' Name{j}];
            BurstMeta.fFCS.Result.Counts{end+1} = [0,0];
            BurstMeta.fFCS.Result.Valid{end+1} = 1:size(Cor_Array,2);
            BurstMeta.fFCS.Result.Cor_Times{end+1} = Cor_Times;
            BurstMeta.fFCS.Result.Cor_Average{end+1} = Cor_Average;
            BurstMeta.fFCS.Result.Cor_SEM{end+1} = Cor_SEM;
            BurstMeta.fFCS.Result.Cor_Array{end+1} = Cor_Array;
            %Header = ['Correlation file for: ' strrep(filename,'\','\\') ' of Channels ' Name{i} ' cross ' Name{j}];
            %Counts = [0 ,0];
            %Valid = 1:size(Cor_Array,2);
            %save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
            
            count = count +1;
            Progress(count/4,h.Progress_Axes,h.Progress_Text,'Correlating...');
        end
    end
end
Progress(1,h.Progress_Axes,h.Progress_Text);

%%% show fit result in result axis
BurstMeta.Plots.fFCS.result_1x1.XData = BurstMeta.fFCS.Result.Cor_Times{1};
BurstMeta.Plots.fFCS.result_1x1.YData = BurstMeta.fFCS.Result.Cor_Average{1};
BurstMeta.Plots.fFCS.result_1x2.XData = BurstMeta.fFCS.Result.Cor_Times{2};
BurstMeta.Plots.fFCS.result_1x2.YData = BurstMeta.fFCS.Result.Cor_Average{2};
BurstMeta.Plots.fFCS.result_2x1.XData = BurstMeta.fFCS.Result.Cor_Times{3};
BurstMeta.Plots.fFCS.result_2x1.YData = BurstMeta.fFCS.Result.Cor_Average{3};
BurstMeta.Plots.fFCS.result_2x2.XData = BurstMeta.fFCS.Result.Cor_Times{4};
BurstMeta.Plots.fFCS.result_2x2.YData = BurstMeta.fFCS.Result.Cor_Average{4};
axis(h.axes_fFCS_Result,'tight');
h.fFCS_axes_tab.SelectedTab = h.fFCS_axes_result_tab;

%%%%% saves the fFCS result
function Save_fFCS(~,~)
global BurstMeta
for i = 1:numel(BurstMeta.fFCS.Result.FileName)
    Current_FileName = BurstMeta.fFCS.Result.FileName{i};
    %%% Checks, if file already exists
    if  exist(Current_FileName,'file')
        k=1;
        %%% Adds 1 to filename
        Current_FileName=[Current_FileName(1:end-5) '_' num2str(k) '.mcor'];
        %%% Increases counter, until no file is found
        while exist(Current_FileName,'file')
            k=k+1;
            Current_FileName=[Current_FileName(1:end-(5+numel(num2str(k-1)))) num2str(k) '.mcor'];
        end
    end
    Header = BurstMeta.fFCS.Result.Header{i};
    Counts = BurstMeta.fFCS.Result.Counts{i};
    Valid = BurstMeta.fFCS.Result.Valid{i};
    Cor_Times = BurstMeta.fFCS.Result.Cor_Times{i};
    Cor_Average = BurstMeta.fFCS.Result.Cor_Average{i};
    Cor_SEM = BurstMeta.fFCS.Result.Cor_SEM{i};
    Cor_Array = BurstMeta.fFCS.Result.Cor_Array{i};
    
    save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Corrections in GUI and UserValues  %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateCorrections(obj,e,h)
global UserValues BurstData BurstMeta

if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end

file = BurstMeta.SelectedFile;
if isempty(obj) %%% Just change the data to what is stored in UserValues
    if isempty(BurstData)
        %%% function was called on GUI startup, default to 2cMFD
        h.CorrectionsTable.Data(:,2) = {UserValues.BurstBrowser.Corrections.Gamma_GR;...
            UserValues.BurstBrowser.Corrections.Beta_GR;...
            UserValues.BurstBrowser.Corrections.CrossTalk_GR;...
            UserValues.BurstBrowser.Corrections.DirectExcitation_GR;...
            UserValues.BurstBrowser.Corrections.GfactorGreen;...
            UserValues.BurstBrowser.Corrections.GfactorRed;...
            UserValues.BurstBrowser.Corrections.l1;...
            UserValues.BurstBrowser.Corrections.l2;...
            UserValues.BurstBrowser.Corrections.Background_GGpar;...
            UserValues.BurstBrowser.Corrections.Background_GGperp;...
            UserValues.BurstBrowser.Corrections.Background_GRpar;...
            UserValues.BurstBrowser.Corrections.Background_GRperp;...
            UserValues.BurstBrowser.Corrections.Background_RRpar;...
            UserValues.BurstBrowser.Corrections.Background_RRperp};
    else
        %%% Catch case where no Background Information is stored in
        %%% BurstData
        if ~isfield(BurstData{file},'Background')
            switch BurstData{file}.BAMethod
                case {1,2}
                    BurstData{file}.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
                    BurstData{file}.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
                    BurstData{file}.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
                    BurstData{file}.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
                    BurstData{file}.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
                    BurstData{file}.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
                case {3,4}
                    BurstData{file}.Background.Background_BBpar = UserValues.BurstBrowser.Corrections.Background_BBpar;
                    BurstData{file}.Background.Background_BBperp = UserValues.BurstBrowser.Corrections.Background_BBperp;
                    BurstData{file}.Background.Background_BGpar = UserValues.BurstBrowser.Corrections.Background_BGpar;
                    BurstData{file}.Background.Background_BGperp = UserValues.BurstBrowser.Corrections.Background_BGperp;
                    BurstData{file}.Background.Background_BRpar = UserValues.BurstBrowser.Corrections.Background_BRpar;
                    BurstData{file}.Background.Background_BRperp = UserValues.BurstBrowser.Corrections.Background_BRperp;
                    BurstData{file}.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
                    BurstData{file}.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
                    BurstData{file}.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
                    BurstData{file}.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
                    BurstData{file}.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
                    BurstData{file}.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
                case {5}
                    BurstData{file}.Background.Background_GG = UserValues.BurstBrowser.Corrections.Background_GGpar;
                    BurstData{file}.Background.Background_GR = UserValues.BurstBrowser.Corrections.Background_GRpar;
                    BurstData{file}.Background.Background_RR = UserValues.BurstBrowser.Corrections.Background_RRpar;
            end
        end
        %%% Backwards Compatibility Check (Remove at some point)
        if ~isstruct(BurstData{file}.Background) % Second check for compatibility of old data (Background was stored in array, not in struct)
            switch BurstData{file}.BAMethod
                case {1,2}
                    Background.Background_GGpar = BurstData{file}.Background(1);
                    Background.Background_GGperp = BurstData{file}.Background(2);
                    Background.Background_GRpar = BurstData{file}.Background(3);
                    Background.Background_GRperp = BurstData{file}.Background(4);
                    Background.Background_RRpar = BurstData{file}.Background(5);
                    Background.Background_RRperp = BurstData{file}.Background(6);
                case {3,4}
                    Background.Background_BBpar = BurstData{file}.Background(1);
                    Background.Background_BBperp = BurstData{file}.Background(2);
                    Background.Background_BGpar = BurstData{file}.Background(3);
                    Background.Background_BGperp = BurstData{file}.Background(4);
                    Background.Background_BRpar = BurstData{file}.Background(5);
                    Background.Background_BRperp = BurstData{file}.Background(6);
                    Background.Background_GGpar = BurstData{file}.Background(7);
                    Background.Background_GGperp = BurstData{file}.Background(8);
                    Background.Background_GRpar = BurstData{file}.Background(9);
                    Background.Background_GRperp = BurstData{file}.Background(10);
                    Background.Background_RRpar = BurstData{file}.Background(11);
                    Background.Background_RRperp = BurstData{file}.Background(12);
            end
            BurstData{file}.Background = Background;
        end
        %%% Set Correction Struct to UserValues. From here on, corrections
        %%% are stored individually per measurement.
        if ~isfield(BurstData{file},'Corrections') || ~isstruct(BurstData{file}.Corrections) % Second check for compatibility of old data
            switch BurstData{file}.BAMethod
                case {1,2,5}
                    BurstData{file}.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
                    BurstData{file}.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
                    BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
                    BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
                    BurstData{file}.Corrections.GfactorGreen =  UserValues.BurstBrowser.Corrections.GfactorGreen;
                    BurstData{file}.Corrections.GfactorRed = UserValues.BurstBrowser.Corrections.GfactorRed;
                    BurstData{file}.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
                    BurstData{file}.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
                    BurstData{file}.Corrections.FoersterRadius = UserValues.BurstBrowser.Corrections.FoersterRadius;
                    BurstData{file}.Corrections.LinkerLength = UserValues.BurstBrowser.Corrections.LinkerLength;
                case {3,4}
                    BurstData{file}.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
                    BurstData{file}.Corrections.CrossTalk_BG = UserValues.BurstBrowser.Corrections.CrossTalk_BG;
                    BurstData{file}.Corrections.CrossTalk_BR = UserValues.BurstBrowser.Corrections.CrossTalk_BR;
                    BurstData{file}.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
                    BurstData{file}.Corrections.DirectExcitation_BG = UserValues.BurstBrowser.Corrections.DirectExcitation_BG;
                    BurstData{file}.Corrections.DirectExcitation_BR = UserValues.BurstBrowser.Corrections.DirectExcitation_BR;
                    BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
                    BurstData{file}.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
                    BurstData{file}.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
                    BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
                    BurstData{file}.Corrections.Beta_BG = UserValues.BurstBrowser.Corrections.Beta_BG;
                    BurstData{file}.Corrections.Beta_BR = UserValues.BurstBrowser.Corrections.Beta_BR;
                    BurstData{file}.Corrections.GfactorBlue = UserValues.BurstBrowser.Corrections.GfactorBlue;
                    BurstData{file}.Corrections.GfactorGreen = UserValues.BurstBrowser.Corrections.GfactorGreen;
                    BurstData{file}.Corrections.GfactorRed = UserValues.BurstBrowser.Corrections.GfactorRed;
                    BurstData{file}.Corrections.DonorLifetimeBlue = UserValues.BurstBrowser.Corrections.DonorLifetimeBlue;
                    BurstData{file}.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
                    BurstData{file}.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
                    BurstData{file}.Corrections.FoersterRadius = UserValues.BurstBrowser.Corrections.FoersterRadius;
                    BurstData{file}.Corrections.LinkerLength = UserValues.BurstBrowser.Corrections.LinkerLength;
                    BurstData{file}.Corrections.FoersterRadiusBG = UserValues.BurstBrowser.Corrections.FoersterRadiusBG;
                    BurstData{file}.Corrections.LinkerLengthBG = UserValues.BurstBrowser.Corrections.LinkerLengthBG;
                    BurstData{file}.Corrections.FoersterRadiusBR = UserValues.BurstBrowser.Corrections.FoersterRadiusBR;
                    BurstData{file}.Corrections.LinkerLengthBR = UserValues.BurstBrowser.Corrections.LinkerLengthBR;
                    BurstData{file}.Corrections.r0_green = UserValues.BurstBrowser.Corrections.r0_green;
                    BurstData{file}.Corrections.r0_red = UserValues.BurstBrowser.Corrections.r0_red;
                    BurstData{file}.Corrections.r0_blue = UserValues.BurstBrowser.Corrections.r0_blue;
            end
        end
        if ~isfield(BurstData{file}.Corrections,'r0_green')
            BurstData{file}.Corrections.r0_green = UserValues.BurstBrowser.Corrections.r0_green;
        end
        if ~isfield(BurstData{file}.Corrections,'r0_red')
            BurstData{file}.Corrections.r0_red = UserValues.BurstBrowser.Corrections.r0_red;
        end
        if ~isfield(BurstData{file}.Corrections,'r0_blue') && any(BurstData{file}.BAMethod == [3,4])
            BurstData{file}.Corrections.r0_blue = UserValues.BurstBrowser.Corrections.r0_blue;
        end
        %%% Update GUI with values stored in BurstData Structure
        switch BurstData{file}.BAMethod
            case {1,2}
                h.DonorLifetimeEdit.String = num2str(BurstData{file}.Corrections.DonorLifetime);
                h.AcceptorLifetimeEdit.String = num2str(BurstData{file}.Corrections.AcceptorLifetime);
                h.FoersterRadiusEdit.String = num2str(BurstData{file}.Corrections.FoersterRadius);
                h.LinkerLengthEdit.String = num2str(BurstData{file}.Corrections.LinkerLength);
                h.r0Green_edit.String = num2str(BurstData{file}.Corrections.r0_green);
                h.r0Red_edit.String = num2str(BurstData{file}.Corrections.r0_red);
            case {3,4}
                h.DonorLifetimeBlueEdit.String = num2str(BurstData{file}.Corrections.DonorLifetimeBlue);
                h.DonorLifetimeEdit.String = num2str(BurstData{file}.Corrections.DonorLifetime);
                h.AcceptorLifetimeEdit.String = num2str(BurstData{file}.Corrections.AcceptorLifetime);
                h.FoersterRadiusEdit.String = num2str(BurstData{file}.Corrections.FoersterRadius);
                h.LinkerLengthEdit.String = num2str(BurstData{file}.Corrections.LinkerLength);
                h.FoersterRadiusBGEdit.String = num2str(BurstData{file}.Corrections.FoersterRadiusBG);
                h.LinkerLengthBGEdit.String = num2str(BurstData{file}.Corrections.LinkerLengthBG);
                h.FoersterRadiusBREdit.String = num2str(BurstData{file}.Corrections.FoersterRadiusBR);
                h.LinkerLengthBREdit.String = num2str(BurstData{file}.Corrections.LinkerLengthBR);
                h.r0Blue_edit.String = num2str(BurstData{file}.Corrections.r0_blue);
                h.r0Green_edit.String = num2str(BurstData{file}.Corrections.r0_green);
                h.r0Red_edit.String = num2str(BurstData{file}.Corrections.r0_red);
        end
        
        if any(BurstData{file}.BAMethod == [1,2,5]) %%% 2cMFD, same as default
            h.CorrectionsTable.Data(:,2) = {BurstData{file}.Corrections.Gamma_GR;...
                BurstData{file}.Corrections.Beta_GR;...
                BurstData{file}.Corrections.CrossTalk_GR;...
                BurstData{file}.Corrections.DirectExcitation_GR;...
                BurstData{file}.Corrections.GfactorGreen;...
                BurstData{file}.Corrections.GfactorRed;...
                UserValues.BurstBrowser.Corrections.l1;...
                UserValues.BurstBrowser.Corrections.l2;...
                BurstData{file}.Background.Background_GGpar;...
                BurstData{file}.Background.Background_GGperp;...
                BurstData{file}.Background.Background_GRpar;...
                BurstData{file}.Background.Background_GRperp;...
                BurstData{file}.Background.Background_RRpar;...
                BurstData{file}.Background.Background_RRperp};
        elseif any(BurstData{file}.BAMethod == [3,4]) %%% 3cMFD
            h.CorrectionsTable.Data(:,2) = {BurstData{file}.Corrections.Gamma_GR;...
                BurstData{file}.Corrections.Gamma_BG;...
                BurstData{file}.Corrections.Gamma_BR;...
                BurstData{file}.Corrections.Beta_GR;...
                BurstData{file}.Corrections.Beta_BG;...
                BurstData{file}.Corrections.Beta_BR;...
                BurstData{file}.Corrections.CrossTalk_GR;...
                BurstData{file}.Corrections.CrossTalk_BG;...
                BurstData{file}.Corrections.CrossTalk_BR;...
                BurstData{file}.Corrections.DirectExcitation_GR;...
                BurstData{file}.Corrections.DirectExcitation_BG;...
                BurstData{file}.Corrections.DirectExcitation_BR;...
                BurstData{file}.Corrections.GfactorBlue;...
                BurstData{file}.Corrections.GfactorGreen;...
                BurstData{file}.Corrections.GfactorRed;...
                UserValues.BurstBrowser.Corrections.l1;...
                UserValues.BurstBrowser.Corrections.l2;...
                BurstData{file}.Background.Background_BBpar;...
                BurstData{file}.Background.Background_BBperp;...
                BurstData{file}.Background.Background_BGpar;...
                BurstData{file}.Background.Background_BGperp;...
                BurstData{file}.Background.Background_BRpar;...
                BurstData{file}.Background.Background_BRperp;...
                BurstData{file}.Background.Background_GGpar;...
                BurstData{file}.Background.Background_GGperp;...
                BurstData{file}.Background.Background_GRpar;...
                BurstData{file}.Background.Background_GRperp;...
                BurstData{file}.Background.Background_RRpar;...
                BurstData{file}.Background.Background_RRperp};
        end
        
    end
else %%% Update UserValues and BurstData with new values
    LSUserValues(0);
    if ~h.MultiselectOnCheckbox.UserData
       files = BurstMeta.SelectedFile;
    else %%% loop over selected files
       files = get_multiselection(h);
       files = unique(files);
    end
    switch obj
        case h.CorrectionsTable
            Data = obj.Data(:,2);
            if isnan(e.NewData)
                %%% revert to old data and don't proceed
                obj.Data{e.Indices(1),e.Indices(2)} = e.PreviousData;
                return;
            end
            h.ApplyCorrectionsButton.ForegroundColor = [1 0 0];
            if any(BurstData{file}.BAMethod == [1,2,5]) %%% 2cMFD
                %%% Update UserValues Structure
                UserValues.BurstBrowser.Corrections.Gamma_GR = Data{1};
                UserValues.BurstBrowser.Corrections.Beta_GR = Data{2};
                UserValues.BurstBrowser.Corrections.CrossTalk_GR = Data{3};
                UserValues.BurstBrowser.Corrections.DirectExcitation_GR= Data{4};
                UserValues.BurstBrowser.Corrections.GfactorGreen = Data{5};
                UserValues.BurstBrowser.Corrections.GfactorRed = Data{6};
                UserValues.BurstBrowser.Corrections.l1 = Data{7};
                UserValues.BurstBrowser.Corrections.l2 = Data{8};
                UserValues.BurstBrowser.Corrections.Background_GGpar= Data{9};
                UserValues.BurstBrowser.Corrections.Background_GGperp= Data{10};
                UserValues.BurstBrowser.Corrections.Background_GRpar= Data{11};
                UserValues.BurstBrowser.Corrections.Background_GRperp= Data{12};
                UserValues.BurstBrowser.Corrections.Background_RRpar= Data{13};
                UserValues.BurstBrowser.Corrections.Background_RRperp= Data{14};
                for file = files
                    switch e.Indices(1)
                        case 1
                            BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
                        case 2
                            BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
                        case 3
                            BurstData{file}.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
                        case 4
                            BurstData{file}.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
                        case 5
                            BurstData{file}.Corrections.GfactorGreen = UserValues.BurstBrowser.Corrections.GfactorGreen;
                        case 6
                            BurstData{file}.Corrections.GfactorRed = UserValues.BurstBrowser.Corrections.GfactorRed;
                        case 7
                            
                        case 8
                            
                        case 9
                            BurstData{file}.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
                        case 10
                            BurstData{file}.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
                        case 11
                            BurstData{file}.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
                        case 12
                            BurstData{file}.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
                        case 13
                            BurstData{file}.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
                        case 14
                            BurstData{file}.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
                    end
                end
                if ~strcmp(h.Corrections.TwoCMFD.axes_crosstalk.Title.String,'Lifetime of Donor only')
                    %%% only execute when axis is not used for lifetime plot
                    switch e.Indices(1)
                        case 3 %%% crosstalk was changed, update the Gauss fit plot
                            crosstalk_new = e.NewData;
%                             mean_new = crosstalk_new/(crosstalk_new+1);
%                             if BurstMeta.Plots.histE_donly.YData == 1
%                                 % correction histograms don't exist yet
%                                 DetermineCorrections(h.DetermineCorrectionsButton,[]); 
%                             end
%                             obj.Data{e.Indices(1),2} = crosstalk_new; %update the value in the table
%                             [~, GaussFun] = GaussianFit(BurstMeta.Plots.histE_donly.XData',...
%                                                         BurstMeta.Plots.histE_donly.YData',...
%                                                         mean_new); %create the new red line
%                             BurstMeta.Plots.Fits.histE_donly(1).YData = GaussFun;
                            UserValues.BurstBrowser.Corrections.CrossTalk_GR = crosstalk_new;
                            BurstData{file}.Corrections.CrossTalk_GR = crosstalk_new;
                        case 4 %%% direct exc. was changed, update the Gauss fit plot
                            directexc_new = e.NewData;
%                             mean_new = directexc_new/(directexc_new+1);
%                             if BurstMeta.Plots.histS_aonly.YData == 1
%                                 % correction histograms don't exist yet
%                                 DetermineCorrections(h.DetermineCorrectionsButton,[]); %generate the directexc histogram if it isn't there already
%                             end
%                             obj.Data{e.Indices(1),2} = directexc_new; %update the value in the table
%                             [~, GaussFun] = GaussianFit(BurstMeta.Plots.histS_aonly.XData',...
%                                                         BurstMeta.Plots.histS_aonly.YData',...
%                                                         mean_new); %create the new red line
%                             BurstMeta.Plots.Fits.histS_aonly(1).YData = GaussFun;
                            UserValues.BurstBrowser.Corrections.DirectExcitation_GR = directexc_new;
                            BurstData{file}.Corrections.DirectExcitation_GR = directexc_new;
                    end
                end
            elseif any(BurstData{file}.BAMethod == [3,4]) %%% 3cMFD
                %%% first update the gamma values!
                %%% gamma_br = gamma_bg*gamma_gr
                switch e.Indices(1)
                    case 1 %%% gamma GR was changed
                        %%% hold gamma BR constant, but change gamma BG
                        %%% (gamma BG is not really used directly in the code)
                        Data{2} = Data{3}/Data{1};
                        obj.Data{2,2} = Data{2};
                    case 2 %%% gamma BG was changed, update gamma BR
                        Data{3} = Data{2}*Data{1};
                        obj.Data{3,2} = Data{3};
                    case 3 %%% gamma BR was changed, update gamma BG
                        Data{2} = Data{3}/Data{1};
                        obj.Data{2,2} = Data{2};
                end
                %%% Update UserValues
                UserValues.BurstBrowser.Corrections.Gamma_GR = Data{1};
                UserValues.BurstBrowser.Corrections.Gamma_BG = Data{2};
                UserValues.BurstBrowser.Corrections.Gamma_BR = Data{3};
                UserValues.BurstBrowser.Corrections.Beta_GR = Data{4};
                UserValues.BurstBrowser.Corrections.Beta_BG = Data{5};
                UserValues.BurstBrowser.Corrections.Beta_BR = Data{6};
                UserValues.BurstBrowser.Corrections.CrossTalk_GR = Data{7};
                UserValues.BurstBrowser.Corrections.CrossTalk_BG = Data{8};
                UserValues.BurstBrowser.Corrections.CrossTalk_BR = Data{9};
                UserValues.BurstBrowser.Corrections.DirectExcitation_GR= Data{10};
                UserValues.BurstBrowser.Corrections.DirectExcitation_BG= Data{11};
                UserValues.BurstBrowser.Corrections.DirectExcitation_BR= Data{12};
                UserValues.BurstBrowser.Corrections.GfactorBlue = Data{13};
                UserValues.BurstBrowser.Corrections.GfactorGreen = Data{14};
                UserValues.BurstBrowser.Corrections.GfactorRed = Data{15};
                UserValues.BurstBrowser.Corrections.l1 = Data{16};
                UserValues.BurstBrowser.Corrections.l2 = Data{17};
                UserValues.BurstBrowser.Corrections.Background_BBpar= Data{18};
                UserValues.BurstBrowser.Corrections.Background_BBperp= Data{19};
                UserValues.BurstBrowser.Corrections.Background_BGpar= Data{20};
                UserValues.BurstBrowser.Corrections.Background_BGperp= Data{21};
                UserValues.BurstBrowser.Corrections.Background_BRpar= Data{22};
                UserValues.BurstBrowser.Corrections.Background_BRperp= Data{23};
                UserValues.BurstBrowser.Corrections.Background_GGpar= Data{24};
                UserValues.BurstBrowser.Corrections.Background_GGperp= Data{25};
                UserValues.BurstBrowser.Corrections.Background_GRpar= Data{26};
                UserValues.BurstBrowser.Corrections.Background_GRperp= Data{27};
                UserValues.BurstBrowser.Corrections.Background_RRpar= Data{28};                
                UserValues.BurstBrowser.Corrections.Background_RRperp= Data{29};
                for file = files
                    switch e.Indices(1)
                        case 1
                            BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
                        case {2,3} %%% Update both gamma_BG and gamma_BR if either one is changed
                            BurstData{file}.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
                            BurstData{file}.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
                        case 4
                            BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
                        case 5
                            BurstData{file}.Corrections.Beta_BG = UserValues.BurstBrowser.Corrections.Beta_BG;
                        case 6
                            BurstData{file}.Corrections.Beta_BR = UserValues.BurstBrowser.Corrections.Beta_BR;
                        case 7
                            BurstData{file}.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
                        case 8
                            BurstData{file}.Corrections.CrossTalk_BG = UserValues.BurstBrowser.Corrections.CrossTalk_BG;
                        case 9
                            BurstData{file}.Corrections.CrossTalk_BR = UserValues.BurstBrowser.Corrections.CrossTalk_BR;
                        case 10
                            BurstData{file}.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
                        case 11
                            BurstData{file}.Corrections.DirectExcitation_BG = UserValues.BurstBrowser.Corrections.DirectExcitation_BG;
                        case 12
                            BurstData{file}.Corrections.DirectExcitation_BR = UserValues.BurstBrowser.Corrections.DirectExcitation_BR;
                        case 13
                            BurstData{file}.Corrections.GfactorBlue = UserValues.BurstBrowser.Corrections.GfactorBlue;
                        case 14
                            BurstData{file}.Corrections.GfactorGreen = UserValues.BurstBrowser.Corrections.GfactorGreen;
                        case 15
                            BurstData{file}.Corrections.GfactorRed = UserValues.BurstBrowser.Corrections.GfactorRed;
                        case 16
                            
                        case 17
                            
                        case 18
                            BurstData{file}.Background.Background_BBpar = UserValues.BurstBrowser.Corrections.Background_BBpar;
                        case 19
                            BurstData{file}.Background.Background_BBperp = UserValues.BurstBrowser.Corrections.Background_BBperp;
                        case 20
                            BurstData{file}.Background.Background_BGpar = UserValues.BurstBrowser.Corrections.Background_BGpar;
                        case 21
                            BurstData{file}.Background.Background_BGperp = UserValues.BurstBrowser.Corrections.Background_BGperp;
                        case 22
                            BurstData{file}.Background.Background_BRpar = UserValues.BurstBrowser.Corrections.Background_BRpar;
                        case 23
                            BurstData{file}.Background.Background_BRperp = UserValues.BurstBrowser.Corrections.Background_BRperp;
                        case 24
                            BurstData{file}.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
                        case 25
                            BurstData{file}.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
                        case 26
                            BurstData{file}.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
                        case 27
                            BurstData{file}.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
                        case 28
                            BurstData{file}.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
                        case 29
                            BurstData{file}.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
                    end
                end
                switch e.Indices(1)
                    case {7:12} 
                        %msgbox('anders, if you"re interested in having the red plots being updated when you change this value, see the two color code or let me know! xxx Jelle')
                end
            end
        case h.DonorLifetimeEdit
            if ~isnan(str2double(h.DonorLifetimeEdit.String))
                UserValues.BurstBrowser.Corrections.DonorLifetime = str2double(h.DonorLifetimeEdit.String);
                for file = files
                    BurstData{file}.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
                end
            else %%% Reset value
                h.DonorLifetimeEdit.String = num2str(UserValues.BurstBrowser.Corrections.DonorLifetime);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
            ApplyCorrections([],[],h);
        case h.AcceptorLifetimeEdit
            if ~isnan(str2double(h.AcceptorLifetimeEdit.String))
                UserValues.BurstBrowser.Corrections.AcceptorLifetime = str2double(h.AcceptorLifetimeEdit.String);
                for file = files
                    BurstData{file}.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
                end
            else %%% Reset value
                h.AcceptorLifetimeEdit.String = num2str(UserValues.BurstBrowser.Corrections.AcceptorLifetime);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
        case h.DonorLifetimeBlueEdit
            if ~isnan(str2double(h.DonorLifetimeBlueEdit.String))
                UserValues.BurstBrowser.Corrections.DonorLifetimeBlue = str2double(h.DonorLifetimeBlueEdit.String);
                for file = files
                    BurstData{file}.Corrections.DonorLifetimeBlue = UserValues.BurstBrowser.Corrections.DonorLifetimeBlue;
                end
            else %%% Reset value
                h.DonorLifetimeBlueEdit.String = num2str(UserValues.BurstBrowser.Corrections.DonorLifetimeBlue);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
            ApplyCorrections([],[],h);
        case h.FoersterRadiusEdit
            if ~isnan(str2double(h.FoersterRadiusEdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadius = str2double(h.FoersterRadiusEdit.String);
                for file = files
                    BurstData{file}.Corrections.FoersterRadius = UserValues.BurstBrowser.Corrections.FoersterRadius;
                end
            else %%% Reset value
                h.FoersterRadiusEdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadius);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
            ApplyCorrections([],[],h);
        case h.LinkerLengthEdit
            if ~isnan(str2double(h.LinkerLengthEdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLength = str2double(h.LinkerLengthEdit.String);
                for file = files
                    BurstData{file}.Corrections.LinkerLength = UserValues.BurstBrowser.Corrections.LinkerLength;
                end
            else %%% Reset value
                h.LinkerLengthEdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLength);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
        case h.FoersterRadiusBGEdit
            if ~isnan(str2double(h.FoersterRadiusBGEdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadiusBG = str2double(h.FoersterRadiusBGEdit.String);
                for file = files
                    BurstData{file}.Corrections.FoersterRadiusBG = UserValues.BurstBrowser.Corrections.FoersterRadiusBG;
                end
            else %%% Reset value
                h.FoersterRadiusBGEdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadiusBG);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
            ApplyCorrections([],[],h);
        case h.LinkerLengthBGEdit
            if ~isnan(str2double(h.LinkerLengthBGEdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLengthBG = str2double(h.LinkerLengthBGEdit.String);
                for file = files
                    BurstData{file}.Corrections.LinkerLengthBG = UserValues.BurstBrowser.Corrections.LinkerLengthBG;
                end
            else %%% Reset value
                h.LinkerLengthBGEdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLengthBG);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
        case h.FoersterRadiusBREdit
            if ~isnan(str2double(h.FoersterRadiusBREdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadiusBR = str2double(h.FoersterRadiusBREdit.String);
                for file = files
                    BurstData{file}.Corrections.FoersterRadiusBR = UserValues.BurstBrowser.Corrections.FoersterRadiusBR;
                end
            else %%% Reset value
                h.FoersterRadiusBREdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadiusBR);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
            ApplyCorrections([],[],h);
        case h.LinkerLengthBREdit
            if ~isnan(str2double(h.LinkerLengthBREdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLengthBR = str2double(h.LinkerLengthBREdit.String);
                for file = files
                    BurstData{file}.Corrections.LinkerLengthBR = UserValues.BurstBrowser.Corrections.LinkerLengthBR;
                end
            else %%% Reset value
                h.LinkerLengthBREdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLengthBR);
            end
            UpdateLifetimePlots([],[],h);
            PlotLifetimeInd([],[],h);
        case h.r0Green_edit
            if ~isnan(str2double(h.r0Green_edit.String))
                UserValues.BurstBrowser.Corrections.r0_green = str2double(h.r0Green_edit.String);
                for file = files
                    BurstData{file}.Corrections.r0_green = UserValues.BurstBrowser.Corrections.r0_green;
                end
            else %%% Reset value
                h.r0Green_edit.String = num2str(UserValues.BurstBrowser.Corrections.r0_green);
            end
        case h.r0Red_edit
            if ~isnan(str2double(h.r0Red_edit.String))
                UserValues.BurstBrowser.Corrections.r0_red = str2double(h.r0Red_edit.String);
                for file = files
                    BurstData{file}.Corrections.r0_red = UserValues.BurstBrowser.Corrections.r0_red;
                end
            else %%% Reset value
                h.r0Red_edit.String = num2str(UserValues.BurstBrowser.Corrections.r0_red);
            end
        case h.r0Blue_edit
            if ~isnan(str2double(h.r0Blue_edit.String))
                UserValues.BurstBrowser.Corrections.r0_blue = str2double(h.r0Blue_edit.String);
                for file = files
                    BurstData{file}.Corrections.r0_blue = UserValues.BurstBrowser.Corrections.r0_blue;
                end
            else %%% Reset value
                h.r0Blue_edit.String = num2str(UserValues.BurstBrowser.Corrections.r0_blue);
            end
    end  
    LSUserValues(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Does Time Window Analysis of selected species %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Time_Window_Analysis(~,~)
global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));

file = BurstMeta.SelectedFile;

%%% query photon threshold
threshold = inputdlg({'Minimum number of photons'},'Set threshold',1,{'50'});
if isempty(threshold)
    return;
else
    threshold = str2double(threshold{1});
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating Histograms...');
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating Histograms...');
%%% find selected bursts
MT = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
CH = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);

xProx = linspace(-0.1,1.1,61);
timebin = {10E-3,5E-3,2E-3,1E-3,0.5E-3,0.25E-3};
for t = 1:numel(timebin)
    %%% 1.) Bin BurstData according to time bin
    
    duration = timebin{t}/BurstData{file}.ClockPeriod;
    %%% Get the maximum number of bins possible in data set
    max_duration = double(ceil(max(cellfun(@(x) x(end)-x(1),MT))./duration));
    %convert absolute macrotimes to relative macrotimes
    bursts = cellfun(@(x) double(x-x(1)+1),MT,'UniformOutput',false);
    %bin the bursts according to dur, up to max_duration
    bins = cellfun(@(x) histc(x,duration.*[0:1:max_duration]),bursts,'UniformOutput',false);
    %remove last bin
    last_bin = cellfun(@(x) find(x,1,'last'),bins,'UniformOutput',false);
    for i = 1:numel(bins)
        bins{i}(last_bin{i}) = 0;
        %remove zero bins
        bins{i}(bins{i} == 0) = [];
    end
    %total number of bins is:
    n_bins = sum(cellfun(@numel,bins));
    %construct cumsum of bins
    cumsum_bins = cellfun(@(x) [0; cumsum(x)],bins,'UniformOutput',false);
    %get channel information --> This is the only relavant information for PDA!
    PDAdata = cell(n_bins,1);
    index = 1;
    for i = 1:numel(CH)
        for j = 2:numel(cumsum_bins{i})
            PDAdata{index,1} = CH{i}(cumsum_bins{i}(j-1)+1:cumsum_bins{i}(j));
            index = index + 1;
        end
    end
    
    %%% 2.) Calculate Proximity Ratio Histogram
    switch BurstData{file}.BAMethod
        case {1,2}
            NGP = cellfun(@(x) sum((x==1)),PDAdata);
            NGS = cellfun(@(x) sum((x==2)),PDAdata);
            NFP = cellfun(@(x) sum((x==3)),PDAdata);
            NFS = cellfun(@(x) sum((x==4)),PDAdata);
            NRP = cellfun(@(x) sum((x==5)),PDAdata);
            NRS = cellfun(@(x) sum((x==6)),PDAdata);
        case {3,4}
            NGP = cellfun(@(x) sum((x==7)),PDAdata);
            NGS = cellfun(@(x) sum((x==8)),PDAdata);
            NFP = cellfun(@(x) sum((x==9)),PDAdata);
            NFS = cellfun(@(x) sum((x==10)),PDAdata);
            NRP = cellfun(@(x) sum((x==11)),PDAdata);
            NRS = cellfun(@(x) sum((x==12)),PDAdata);
        case {5}
            NG = cellfun(@(x) sum((x==1)),PDAdata);
            NF = cellfun(@(x) sum((x==2)),PDAdata);
            NR = cellfun(@(x) sum((x==3)),PDAdata);
    end
    if ~(BurstData{file}.BAMethod == 5)
        NG = NGP + NGS;
        NF = NFP + NFS;
        NR = NRP + NRS;
    end
    valid = (NG+NF+NR) > threshold; NG = NG(valid); NF = NF(valid); NR = NR(valid);
    NG = NG - timebin{t}.*(BurstData{file}.Background.Background_GGpar+BurstData{file}.Background.Background_GGperp);
    NF = NF - timebin{t}.*(BurstData{file}.Background.Background_GRpar+BurstData{file}.Background.Background_GRperp);
    NR = NR - timebin{t}.*(BurstData{file}.Background.Background_RRpar+BurstData{file}.Background.Background_RRperp);
    NF = NF - BurstData{1, 1}.Corrections.CrossTalk_GR.*NG - BurstData{1, 1}.Corrections.DirectExcitation_GR.*NR;
    Prox = NF./(BurstData{1, 1}.Corrections.Gamma_GR.*NG+NF);
    
    Hist{t} = histcounts(Prox,xProx); Hist{t} = Hist{t}./sum(Hist{t});
    Progress(t/numel(timebin),h.Progress_Axes,h.Progress_Text,'Calculating Histograms...');
end


f1 = figure('Color',[1,1,1]);hold on;
a = 3;
for i = 1:numel(timebin)
    ha = stairs(xProx,[Hist{i},Hist{i}(end)]);
    set(ha, 'Linewidth', a)
    a = a-0.33;
end
ax = gca;
ax.Color = [1,1,1];
ax.LineWidth = 1.5;
ax.FontSize = 20;
xlabel('FRET efficiency');
ylabel('occurrence (norm.)');
xlim([-0.1,1.1]);
for i = 1:numel(timebin)
    leg{i} = [num2str(timebin{i}*1000) ' ms'];
end
legend(leg,'Box','off');

%%% also make image plot
Hist = flipud(vertcat(Hist{1:6}));
f2 = figure('Color',[1,1,1]);
f2.Position(1) = f1.Position(1) +  f1.Position(3);
im = imagesc(xProx,fliplr(horzcat(timebin{1:6}))*1000,Hist);
ax = gca;
ax.YDir = 'normal';
ax.FontSize = 20;
xlabel('FRET efficiency');
ylabel('time bin [ms]');
Progress(1,h.Progress_Axes,h.Progress_Text);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Saves FRET Hist to a file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export_FRET_Hist(obj,~,mode)
global BurstData UserValues BurstMeta
if ~isempty(obj)
    if ~isobject(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
        obj = 'None';
    else
        h = guidata(obj);
    end
    switch obj
        case h.FRET_Export_All_Menu;
            %%% loop over all files
            sel_file = BurstMeta.SelectedFile;
            for i = 1:numel(BurstData);
                BurstMeta.SelectedFile = i;
                %%% Make sure to apply corrections
                ApplyCorrections(obj,[]);
                Export_FRET_Hist([],[],'Export FRET Efficiency Histogram');
            end
            BurstMeta.SelectedFile = sel_file;
        case h.FRET_Export_Sel_Menu;
            %%% loop over all selected species
            sel_file = BurstMeta.SelectedFile;
            [files,species,subspecies] = get_multiselection(h);
            for i = 1:numel(files)
                file = files(i);
                BurstMeta.SelectedFile = file;
                sel_species = BurstData{file}.SelectedSpecies;
                BurstData{file}.SelectedSpecies = [species(i),subspecies(i)];
                %%% Make sure to apply corrections
                ApplyCorrections(obj,[],h,0);
                Export_FRET_Hist([],[],'Export FRET Efficiency Histogram');
                BurstData{file}.SelectedSpecies = sel_species;
            end
            BurstMeta.SelectedFile = sel_file;
        otherwise %% java menu item
             %%% loop over all files
            sel_file = BurstMeta.SelectedFile;
            for i = 1:numel(BurstData);
                BurstMeta.SelectedFile = i;
                %%% Make sure to apply corrections
                ApplyCorrections(h.BurstBrowser,[]);
                Export_FRET_Hist([],[]);
            end
            BurstMeta.SelectedFile = sel_file;
    end
    %%% set FCSFit path to the current print path
    UserValues.File.FCSPath = getPrintPath();
    LSUserValues(1);
else
    file = BurstMeta.SelectedFile;
    if BurstData{file}.SelectedSpecies(2) == 0 %%% total measurement is selected
        SelectedSpeciesName = 'total';
    else
        %%% top level species is selected
        SelectedSpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),1};
        if BurstData{file}.SelectedSpecies(2) > 1 %%% subpspecies is selected
            SelectedSpeciesName = [SelectedSpeciesName '_' BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)}];
        end
    end
    SelectedSpeciesName = strrep(SelectedSpeciesName,' ','_');
    filename = [BurstData{file}.FileName(1:end-4) '_' SelectedSpeciesName '.his'];
    filename = strrep(strrep(filename,'/','-'),':','');
    if nargin < 3
        obj = gcbo;
    else
        obj.Label = mode;
    end
    switch obj.Label
        case 'Export FRET Efficiency Histogram'
            switch BurstData{file}.BAMethod
                case {1,2}
                    E = BurstData{file}.DataCut(:,1);
                    %%% Save E array in *.his file
                    save(fullfile(getPrintPath(),filename),'E');
                case {3,4}
                    EGR = BurstData{file}.DataCut(:,1);
                    EBG = BurstData{file}.DataCut(:,2);
                    EBR = BurstData{file}.DataCut(:,3);
                    %%% Save E array in *.his file
                    save(fullfile(getPrintPath(),filename),'EGR','EBG','EBR');
            end
        case 'Export FRET Efficiency Histogram (Time Series)'
            %%% export a time series in specific binnig
            %%% query binning
            timebin = inputdlg('Enter time bin in minutes:','Specifiy time bin',1,{'10'});
            timebin = round(str2double(timebin{1}))*60;
            macrotime = BurstData{file}.DataCut(:,strcmp('Mean Macrotime [s]',BurstData{file}.NameArray));
            times = 0:timebin:ceil(macrotime(end)/timebin)*timebin;
            for i = 1:numel(times)-1
                % get valid bursts
                valid = (macrotime >= times(i)) & (macrotime <= times(i+1));
                E = BurstData{file}.DataCut(valid,1);
                % generate name
                name = [filename(1:end-4) '_' num2str(round(times(i)/60)) 'to' num2str(round(times(i+1)/60)) 'min.his'];
                %%% Save E array in *.his file
                save(fullfile(getPrintPath(),name),'E');
            end
            m = msgbox('Done exporting time series.');
            pause(1);
            delete(m);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Saves the state of the analysis to the .bur file %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Save_Analysis_State_Callback(obj,~)
global BurstData BurstTCSPCData BurstMeta
if isempty(obj)
    h = guidata(findobj('Tag','BurstBrowser'));
else
    h = guidata(obj);
end
if isempty(BurstData)
    disp('No data loaded.');
    return;
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Saving...');
%%% construct filenames
for i = 1:numel(BurstData)
    filename{i} = fullfile(BurstData{i}.PathName, BurstData{i}.FileName);
end
%%% Store burstdata in temp var
if all(strcmp(cellfun(@(x) x(end-2:end),filename,'UniformOutput',false),'bur')) % all bur file, normal 'fast' save
    for i = 1:numel(BurstData)
        Cut = BurstData{i}.Cut;
        SpeciesNames = BurstData{i}.SpeciesNames;
        SelectedSpecies = BurstData{i}.SelectedSpecies;
        Background = BurstData{i}.Background;
        Corrections = BurstData{i}.Corrections;
        %%% New: Cuts stored in Additional Variables (first happens when
        %%% saved in BurstBrowser)
        save(filename{i},'Cut','SpeciesNames','SelectedSpecies',...
            'Background','Corrections','-append');
        if isfield(BurstData{i},'FitCut')
            FitCut = BurstData{i}.FitCut;
            save(filename{i},'FitCut','-append');
        end
        if isfield(BurstData{i},'ArbitraryCut')
            ArbitraryCut = BurstData{i}.ArbitraryCut;
            save(filename{i},'ArbitraryCut','-append');
        end
        if isfield(BurstData{i},'AdditionalParameters')
            AdditionalParameters = BurstData{i}.AdditionalParameters;
            save(filename{i},'AdditionalParameters','-append');
        end
        Progress(i/numel(BurstData),h.Progress_Axes,h.Progress_Text,'Saving...');
    end
elseif any(strcmp(cellfun(@(x) x(end-2:end),filename,'UniformOutput',false),'kba')) % kba files loaded, convert to bur
    BurstData_temp = BurstData;
    BurstTCSPCData_temp = BurstTCSPCData;
    for i = 1:numel(BurstData_temp)
        BurstData = BurstData_temp{i};
        Cut = BurstData.Cut;
        SpeciesNames = BurstData.SpeciesNames;
        SelectedSpecies = BurstData.SelectedSpecies;
        Background = BurstData.Background;
        Corrections = BurstData.Corrections;
        save([filename{i}(1:end-4) '_kba.bur'],'BurstData',...
            'Cut','SpeciesNames','SelectedSpecies','Background','Corrections');
        if ~isempty(BurstTCSPCData_temp{i})
            %%% also save BurstTCSPCData
            BurstTCSPCData = BurstTCSPCData_temp{i};
            save([filename{i}(1:end-4) '_kba.bps'],'-struct','BurstTCSPCData');
        end
        Progress(i/numel(BurstData),h.Progress_Axes,h.Progress_Text,'Saving...');
    end
    BurstData = BurstData_temp;
    BurstTCSPCData= BurstTCSPCData_temp;
end
Progress(1,h.Progress_Axes,h.Progress_Text);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Plots in Left Lifetime Tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateLifetimePlots(obj,~,h)
global BurstData BurstMeta UserValues
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end

if isempty(BurstData)
    return;
end

file = BurstMeta.SelectedFile;
NameArray = BurstData{file}.NameArray;
%%% Use the current cut Data (of the selected species) for plots
if ~h.MultiselectOnCheckbox.UserData
    datatoplot = BurstData{file}.DataCut;
else
    %%% get average dye only lifetimes from selected files
    sel_files = get_multiselection(h);
    DonorLifetime = 0;
    AcceptorLifetime = 0;
    for i = 1:numel(sel_files)
        DonorLifetime = max([DonorLifetime, BurstData{sel_files(i)}.Corrections.DonorLifetime]);
        AcceptorLifetime = max([AcceptorLifetime, BurstData{sel_files(i)}.Corrections.AcceptorLifetime]);
    end
    if any(BurstData{file}.BAMethod == [3,4])
        DonorLifetimeBlue = 0;
        for i = 1:numel(sel_files)
            DonorLifetimeBlue = max([DonorLifetimeBlue, BurstData{sel_files(i)}.Corrections.DonorLifetimeBlue]);
        end
    end
end
%%% read out the indices of the parameters to plot
switch BurstData{file}.BAMethod
    case {1,2,5} %2color
        idx_tauGG = strcmp('Lifetime D [ns]',NameArray);
        idx_tauRR = strcmp('Lifetime A [ns]',NameArray);
        idx_rGG = strcmp('Anisotropy D',NameArray);
        idx_rRR = strcmp('Anisotropy A',NameArray);
        idxE = find(strcmp(NameArray,'FRET Efficiency'));
    case {3,4}
        idx_tauGG = strcmp('Lifetime GG [ns]',NameArray);
        idx_tauRR = strcmp('Lifetime RR [ns]',NameArray);
        idx_rGG = strcmp('Anisotropy GG',NameArray);
        idx_rRR = strcmp('Anisotropy RR',NameArray);
        idxE = find(strcmp(NameArray,'FRET Efficiency GR'));
end
%%% Read out the Number of Bins
nbinsX = UserValues.BurstBrowser.Display.NumberOfBinsX;
nbinsY = UserValues.BurstBrowser.Display.NumberOfBinsY;
%% Plot E vs. tauGG in first plot
if ~h.MultiselectOnCheckbox.UserData
    maxX = min([max(datatoplot(:,idx_tauGG)) BurstData{file}.Corrections.DonorLifetime+1.5]);
    [H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauGG), datatoplot(:,idxE),[nbinsX nbinsY], [0 maxX], [-0.1 1.1]);
    datapoints = [datatoplot(:,idx_tauGG), datatoplot(:,idxE)];
else
    maxX = BurstData{file}.Corrections.DonorLifetime+1.5;
    [H,xbins,ybins,~,~,datapoints,n_per_species] = MultiPlot([],[],h,NameArray{idx_tauGG},NameArray{idxE},{[0 maxX], [-0.1 1.1]});
end
BurstMeta.Plots.EvsTauGG(1).XData = xbins;
BurstMeta.Plots.EvsTauGG(1).YData = ybins;
BurstMeta.Plots.EvsTauGG(1).CData = H;
if ~UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.EvsTauGG(1).AlphaData = (H>0);
elseif UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.EvsTauGG(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
end
BurstMeta.Plots.EvsTauGG(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
BurstMeta.Plots.EvsTauGG(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
H = H/max(max(H));Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
% replicate to fix edges
Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
BurstMeta.Plots.EvsTauGG(2).ZData = Hcontour;
BurstMeta.Plots.EvsTauGG(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
    if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1
        color = [];
        for i = 1:numel(n_per_species)
            color = [color; i*ones(n_per_species(i),1)];
        end
        colors = lines(numel(n_per_species));
        colordata = colors(color,:);
        %%% permute data points randomly to avoid hiding populations below another
        perm = randperm(size(colordata,1));
        colordata = colordata(perm,:);
        datapoints = datapoints(perm,:);
    else
        colordata = UserValues.BurstBrowser.Display.MarkerColor;
    end
    BurstMeta.Plots.EvsTauGG(3).XData = datapoints(:,1);
    BurstMeta.Plots.EvsTauGG(3).YData = datapoints(:,2);
    BurstMeta.Plots.EvsTauGG(3).CData = colordata;
end

%%% update hex plot if selected
if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
    delete(BurstMeta.HexPlot.EvsTauGG);
    %%% make hexplot
    axes(h.axes_EvsTauGG);
    BurstMeta.HexPlot.EvsTauGG = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',[0 maxX],'ylim',[-0.1 1.1],'res',nbinsX);
end
try h.axes_EvsTauGG.XLim=[0,maxX]; end
ylim(h.axes_EvsTauGG,[-0.1 1.1]);
h.axes_EvsTauGG.CLimMode = 'auto';h.axes_EvsTauGG.CLim(1) = 0;
if strcmp(BurstMeta.Plots.Fits.staticFRET_EvsTauGG.Visible,'on')
    %%% replot the static FRET line
    UpdateLifetimeFits(h.PlotStaticFRETButton,[]);
end
%% Plot E vs. tauRR in second plot
if ~h.MultiselectOnCheckbox.UserData
    maxX = min([max(datatoplot(:,idx_tauRR)) BurstData{file}.Corrections.AcceptorLifetime+2]);
    [H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauRR), datatoplot(:,idxE),[nbinsX nbinsY], [0 maxX], [-0.1 1.1]);
    datapoints = [datatoplot(:,idx_tauRR), datatoplot(:,idxE)];
else
    maxX = BurstData{file}.Corrections.AcceptorLifetime+2;
    [H,xbins,ybins,~,~,datapoints,n_per_species] = MultiPlot([],[],h,NameArray{idx_tauRR},NameArray{idxE},{[0 maxX], [-0.1 1.1]});
end
BurstMeta.Plots.EvsTauRR(1).XData = xbins;
BurstMeta.Plots.EvsTauRR(1).YData = ybins;
BurstMeta.Plots.EvsTauRR(1).CData = H;
if ~UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.EvsTauRR(1).AlphaData = (H>0);
elseif UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.EvsTauRR(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
end
BurstMeta.Plots.EvsTauRR(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
BurstMeta.Plots.EvsTauRR(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
H = H/max(max(H));Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
% replicate to fix edges
Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
BurstMeta.Plots.EvsTauRR(2).ZData = Hcontour;
BurstMeta.Plots.EvsTauRR(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
    if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1
        color = [];
        for i = 1:numel(n_per_species)
            color = [color; i*ones(n_per_species(i),1)];
        end
        colors = lines(numel(n_per_species));
        colordata = colors(color,:);
        %%% permute data points randomly to avoid hiding populations below another
        perm = randperm(size(colordata,1));
        colordata = colordata(perm,:);
        datapoints = datapoints(perm,:);
    else
        colordata = UserValues.BurstBrowser.Display.MarkerColor;
    end
    BurstMeta.Plots.EvsTauRR(3).XData = datapoints(:,1);
    BurstMeta.Plots.EvsTauRR(3).YData = datapoints(:,2);
    BurstMeta.Plots.EvsTauRR(3).CData = colordata;
end
%%% update hex plot if selected
if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
    delete(BurstMeta.HexPlot.EvsTauRR);
    %%% make hexplot
    axes(h.axes_EvsTauRR);
    BurstMeta.HexPlot.EvsTauRR = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',[0 maxX],'ylim',[-0.1 1.1],'res',nbinsX);
end
try h.axes_EvsTauRR.XLim=[0,maxX]; end
ylim(h.axes_EvsTauRR,[-0.1 1.1]);
h.axes_EvsTauRR.CLimMode = 'auto';h.axes_EvsTauRR.CLim(1) = 0;
if BurstData{file}.BAMethod ~= 5 %ensure that polarized detection was used
    %% Plot rGG vs. tauGG in third plot
    if ~h.MultiselectOnCheckbox.UserData
        maxX = min([max(datatoplot(:,idx_tauGG)) BurstData{file}.Corrections.DonorLifetime+1.5]);
        [H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauGG), datatoplot(:,idx_rGG),[nbinsX nbinsY], [0 maxX], [-0.1 0.5]);
        datapoints = [datatoplot(:,idx_tauGG), datatoplot(:,idx_rGG)];
    else
        maxX = BurstData{file}.Corrections.DonorLifetime+1.5;
        [H,xbins,ybins,~,~,datapoints,n_per_species] = MultiPlot([],[],h,NameArray{idx_tauGG},NameArray{idx_rGG},{[0 maxX], [-0.1 0.5]});
    end
    BurstMeta.Plots.rGGvsTauGG(1).XData = xbins;
    BurstMeta.Plots.rGGvsTauGG(1).YData = ybins;
    BurstMeta.Plots.rGGvsTauGG(1).CData = H;
    if ~UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rGGvsTauGG(1).AlphaData = (H>0);
    elseif UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rGGvsTauGG(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
    end
    BurstMeta.Plots.rGGvsTauGG(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
    BurstMeta.Plots.rGGvsTauGG(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
    H = H/max(max(H));Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
    % replicate to fix edges
    Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
    Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
    BurstMeta.Plots.rGGvsTauGG(2).ZData = Hcontour;
    BurstMeta.Plots.rGGvsTauGG(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
        if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1
            color = [];
            for i = 1:numel(n_per_species)
                color = [color; i*ones(n_per_species(i),1)];
            end
            colors = lines(numel(n_per_species));
            colordata = colors(color,:);
            %%% permute data points randomly to avoid hiding populations below another
            perm = randperm(size(colordata,1));
            colordata = colordata(perm,:);
            datapoints = datapoints(perm,:);
        else
            colordata = UserValues.BurstBrowser.Display.MarkerColor;
        end
        BurstMeta.Plots.rGGvsTauGG(3).XData = datapoints(:,1);
        BurstMeta.Plots.rGGvsTauGG(3).YData = datapoints(:,2);
        BurstMeta.Plots.rGGvsTauGG(3).CData = colordata;
    end
    %%% update hex plot if selected
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
        delete(BurstMeta.HexPlot.rGGvsTauGG);
        %%% make hexplot
        axes(h.axes_rGGvsTauGG);
        BurstMeta.HexPlot.rGGvsTauGG = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',[0 maxX],'ylim',[-0.1 0.5],'res',nbinsX);
    end
    try h.axes_rGGvsTauGG.XLim=[0,maxX]; end
    ylim(h.axes_rGGvsTauGG,[-0.1 0.5]);
    h.axes_rGGvsTauGG.CLimMode = 'auto';h.axes_rGGvsTauGG.CLim(1) = 0;
    %% Plot rRR vs. tauRR in fourth plot
    if ~h.MultiselectOnCheckbox.UserData
        maxX = min([max(datatoplot(:,idx_tauRR)) BurstData{file}.Corrections.AcceptorLifetime+2]);
        [H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauRR), datatoplot(:,idx_rRR),[nbinsX nbinsY], [0 maxX], [-0.1 0.5]);
        datapoints = [datatoplot(:,idx_tauRR), datatoplot(:,idx_rRR)];
    else
        maxX = BurstData{file}.Corrections.AcceptorLifetime+2;
        [H,xbins,ybins,~,~,datapoints,n_per_species] = MultiPlot([],[],h,NameArray{idx_tauRR},NameArray{idx_rRR},{[0 maxX], [-0.1 0.5]});
    end
    BurstMeta.Plots.rRRvsTauRR(1).XData = xbins;
    BurstMeta.Plots.rRRvsTauRR(1).YData = ybins;
    BurstMeta.Plots.rRRvsTauRR(1).CData = H;
    if ~UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rRRvsTauRR(1).AlphaData = (H>0);
    elseif UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rRRvsTauRR(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
    end
    BurstMeta.Plots.rRRvsTauRR(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
    BurstMeta.Plots.rRRvsTauRR(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
    H = H/max(max(H));Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
    % replicate to fix edges
    Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
    Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
    BurstMeta.Plots.rRRvsTauRR(2).ZData = Hcontour;
    BurstMeta.Plots.rRRvsTauRR(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
        if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1
            color = [];
            for i = 1:numel(n_per_species)
                color = [color; i*ones(n_per_species(i),1)];
            end
            colors = lines(numel(n_per_species));
            colordata = colors(color,:);
            %%% permute data points randomly to avoid hiding populations below another
            perm = randperm(size(colordata,1));
            colordata = colordata(perm,:);
            datapoints = datapoints(perm,:);
        else
            colordata = UserValues.BurstBrowser.Display.MarkerColor;
        end
        BurstMeta.Plots.rRRvsTauRR(3).XData = datapoints(:,1);
        BurstMeta.Plots.rRRvsTauRR(3).YData = datapoints(:,2);
        BurstMeta.Plots.rRRvsTauRR(3).CData = colordata;
    end
    %%% update hex plot if selected
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
        delete(BurstMeta.HexPlot.rRRvsTauRR);
        %%% make hexplot
        axes(h.axes_rRRvsTauRR);
        BurstMeta.HexPlot.rRRvsTauRR = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',[0 maxX],'ylim',[-0.1 0.5],'res',nbinsX);
    end
    try h.axes_rRRvsTauRR.XLim=[0,maxX]; end
    ylim(h.axes_rRRvsTauRR,[-0.1 0.5]);
    h.axes_rRRvsTauRR.CLimMode = 'auto';h.axes_rRRvsTauRR.CLim(1) = 0;
end
%% 3cMFD
if any(BurstData{file}.BAMethod == [3,4])
    idx_tauBB = strcmp('Lifetime BB [ns]',NameArray);
    idx_rBB = strcmp('Anisotropy BB',NameArray);
    idxE1A = strcmp('FRET Efficiency B->G+R',NameArray);
    %% Plot E1A vs. tauBB
    if ~h.MultiselectOnCheckbox.UserData
        valid = (datatoplot(:,idx_tauBB) > 0.01);
        maxX = min([max(datatoplot(:,idx_tauBB)) BurstData{file}.Corrections.DonorLifetimeBlue+1.5]);
        [H, xbins, ybins] = calc2dhist(datatoplot(valid,idx_tauBB), datatoplot(valid,idxE1A),[nbinsX nbinsY], [0 maxX], [-0.1 1.1]);
        datapoints = [datatoplot(valid,idx_tauBB), datatoplot(valid,idxE1A)];
    else
        maxX = BurstData{file}.Corrections.DonorLifetimeBlue+1.5;
        [H,xbins,ybins,~,~,datapoints,n_per_species] = MultiPlot([],[],h,NameArray{idx_tauBB},NameArray{idxE1A},{[0 maxX], [-0.1 1.1]});
    end
    BurstMeta.Plots.E_BtoGRvsTauBB(1).XData = xbins;
    BurstMeta.Plots.E_BtoGRvsTauBB(1).YData = ybins;
    BurstMeta.Plots.E_BtoGRvsTauBB(1).CData = H;
    if ~UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.E_BtoGRvsTauBB(1).AlphaData = (H>0);
    elseif UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.E_BtoGRvsTauBB(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
    end
    BurstMeta.Plots.E_BtoGRvsTauBB(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
    BurstMeta.Plots.E_BtoGRvsTauBB(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
    H = H/max(max(H));Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
    % replicate to fix edges
    Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
    Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
    BurstMeta.Plots.E_BtoGRvsTauBB(2).ZData = Hcontour;
    BurstMeta.Plots.E_BtoGRvsTauBB(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
        if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1
            color = [];
            for i = 1:numel(n_per_species)
                color = [color; i*ones(n_per_species(i),1)];
            end
            colors = lines(numel(n_per_species));
            colordata = colors(color,:);
            %%% permute data points randomly to avoid hiding populations below another
            perm = randperm(size(colordata,1));
            colordata = colordata(perm,:);
            datapoints = datapoints(perm,:);
        else
            colordata = UserValues.BurstBrowser.Display.MarkerColor;
        end
        BurstMeta.Plots.E_BtoGRvsTauBB(3).XData = datapoints(:,1);
        BurstMeta.Plots.E_BtoGRvsTauBB(3).YData = datapoints(:,2);
        BurstMeta.Plots.E_BtoGRvsTauBB(3).CData = colordata;
    end
    %%% update hex plot if selected
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
        delete(BurstMeta.HexPlot.E_BtoGRvsTauBB);
        %%% make hexplot
        axes(h.axes_E_BtoGRvsTauBB);
        BurstMeta.HexPlot.E_BtoGRvsTauBB = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',[0 maxX],'ylim',[-0.1 1.1],'res',nbinsX);
    end
    try h.axes_E_BtoGRvsTauBB.XLim=[0,maxX]; end
    ylim(h.axes_E_BtoGRvsTauBB,[-0.1 1.1]);
    h.axes_E_BtoGRvsTauBB.CLimMode = 'auto';h.axes_E_BtoGRvsTauBB.CLim(1) = 0;
    %% Plot rBB vs tauBB
    if ~h.MultiselectOnCheckbox.UserData
        maxX = min([max(datatoplot(:,idx_tauBB)) BurstData{file}.Corrections.DonorLifetimeBlue+1.5]);
        [H, xbins, ybins] = calc2dhist(datatoplot(valid,idx_tauBB), datatoplot(valid,idx_rBB),[nbinsX nbinsY], [0 maxX], [-0.1 0.5]);
        datapoints = [datatoplot(valid,idx_tauBB), datatoplot(valid,idx_rBB)];
    else
        maxX = BurstData{file}.Corrections.DonorLifetimeBlue+1.5;
        [H,xbins,ybins,~,~,datapoints,n_per_species] = MultiPlot([],[],h,NameArray{idx_tauBB},NameArray{idx_rBB},{[0 maxX], [-0.1 0.5]});
    end
    BurstMeta.Plots.rBBvsTauBB(1).XData = xbins;
    BurstMeta.Plots.rBBvsTauBB(1).YData = ybins;
    BurstMeta.Plots.rBBvsTauBB(1).CData = H;
    if ~UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rBBvsTauBB(1).AlphaData = (H>0);
    elseif UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rBBvsTauBB(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
    end
    BurstMeta.Plots.rBBvsTauBB(2).XData = [xbins(1)-min(diff(xbins)),xbins,xbins(end)+min(diff(xbins))];
    BurstMeta.Plots.rBBvsTauBB(2).YData = [ybins(1)-min(diff(ybins)),ybins,ybins(end)+min(diff(ybins))];
    H = H/max(max(H));Hcontour =zeros(size(H)+2); Hcontour(2:end-1,2:end-1) = H;
    % replicate to fix edges
    Hcontour(2:end-1,1) = H(:,1);Hcontour(2:end-1,end) = H(:,end);Hcontour(1,2:end-1) = H(1,:);Hcontour(end,2:end-1) = H(end,:);
    Hcontour(1,1) = H(1,1);Hcontour(end,1) = H(end,1);Hcontour(1,end) = H(1,end);Hcontour(end,end) = H(end,end);
    BurstMeta.Plots.rBBvsTauBB(2).ZData = Hcontour;
    BurstMeta.Plots.rBBvsTauBB(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter')
        if h.MultiselectOnCheckbox.UserData && numel(n_per_species) > 1
            color = [];
            for i = 1:numel(n_per_species)
                color = [color; i*ones(n_per_species(i),1)];
            end
            colors = lines(numel(n_per_species));
            colordata = colors(color,:);
            %%% permute data points randomly to avoid hiding populations below another
            perm = randperm(size(colordata,1));
            colordata = colordata(perm,:);
            datapoints = datapoints(perm,:);
        else
            colordata = UserValues.BurstBrowser.Display.MarkerColor;
        end
        BurstMeta.Plots.rBBvsTauBB(3).XData = datapoints(:,1);
        BurstMeta.Plots.rBBvsTauBB(3).YData = datapoints(:,2);
        BurstMeta.Plots.rBBvsTauBB(3).CData = colordata;
    end
    %%% update hex plot if selected
    if strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex')
        delete(BurstMeta.HexPlot.rBBvsTauBB);
        %%% make hexplot
        axes(h.axes_rBBvsTauBB);
        BurstMeta.HexPlot.rBBvsTauBB = hexscatter(datapoints(:,1),datapoints(:,2),'xlim',[0 maxX],'ylim',[-0.1 0.5],'res',nbinsX);
    end
    try h.axes_rBBvsTauBB.XLim=[0,maxX]; end
    ylim(h.axes_rBBvsTauBB,[-0.1 0.5]);
    h.axes_rBBvsTauBB.CLimMode = 'auto';h.axes_rBBvsTauBB.CLim(1) = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Copies Selected Lifetime Plot to Individual Tab %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotLifetimeInd(obj,~,h)
global BurstMeta UserValues BurstData
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end
if isempty(BurstData)
    return;
end

file = BurstMeta.SelectedFile;

switch BurstData{file}.BAMethod
    case {1,2,5}
        switch h.lifetime_ind_popupmenu.Value
            case 1 %E vs tauGG
                origin = h.axes_EvsTauGG;
                paramX = 'Lifetime D [ns]';
                paramY = 'FRET Efficiency';
            case 2 %E vs tauRR
                origin = h.axes_EvsTauRR;
                paramX = 'Lifetime A [ns]';
                paramY = 'FRET Efficiency';
            case 3 %rGG vs tauGG
                origin = h.axes_rGGvsTauGG;
                paramX = 'Lifetime D [ns]';
                paramY = 'Anisotropy D';
            case 4 %rRR vs tauRR
                origin = h.axes_rRRvsTauRR;
                paramX = 'Lifetime A [ns]';
                paramY = 'Anisotropy A';
        end
    case {3,4}
        switch h.lifetime_ind_popupmenu.Value
            case 1 %E vs tauGG
                origin = h.axes_EvsTauGG;
                paramX = 'Lifetime GG [ns]';
                paramY = 'FRET Efficiency GR';
            case 2 %E vs tauRR
                origin = h.axes_EvsTauRR;
                paramX = 'Lifetime RR [ns]';
                paramY = 'FRET Efficiency GR';
            case 3 %E1A vs tauBB
                origin = h.axes_E_BtoGRvsTauBB;
                paramX = 'Lifetime BB [ns]';
                paramY = 'FRET Efficiency B->G+R';
            case 4 %rGG vs tauGG
                origin = h.axes_rGGvsTauGG;
                paramX = 'Lifetime GG [ns]';
                paramY = 'Anisotropy GG';
            case 5 %rRR vs tauRR
                origin = h.axes_rRRvsTauRR;
                paramX = 'Lifetime RR [ns]';
                paramY = 'Anisotropy RR';
            case 6 %rBB vs tauBB
                origin = h.axes_rBBvsTauBB;
                paramX = 'Lifetime BB [ns]';
                paramY = 'Anisotropy BB';
        end
end
set(BurstMeta.Plots.LifetimeInd_histX,'Visible','on');
set(BurstMeta.Plots.LifetimeInd_histY,'Visible','on');
for i=1:numel(BurstMeta.Plots.MultiScatter.h1dx_lifetime)
    try;delete(BurstMeta.Plots.MultiScatter.h1dx_lifetime(i));end;
end
for i=1:numel(BurstMeta.Plots.MultiScatter.h1dy_lifetime)
    try;delete(BurstMeta.Plots.MultiScatter.h1dy_lifetime(i));end;
end
legend(h.axes_lifetime_ind_1d_x,'off');
cla(h.axes_lifetime_ind_2d);
plots =origin.Children;
for i = numel(plots):-1:1
    handle_temp = copyobj(plots(i),h.axes_lifetime_ind_2d);
    type{i} = plots(i).Type;
    handle_temp.UIContextMenu = h.ExportGraphLifetime_Menu;
end

h.axes_lifetime_ind_2d.XLim = origin.XLim;
h.axes_lifetime_ind_2d.YLim = origin.YLim;
h.axes_lifetime_ind_2d.XLabel.String = origin.XLabel.String;
h.axes_lifetime_ind_2d.XLabel.Color = UserValues.Look.Fore;
h.axes_lifetime_ind_2d.YLabel.String = origin.YLabel.String;
h.axes_lifetime_ind_2d.YLabel.Color = UserValues.Look.Fore;
h.axes_lifetime_ind_2d.CLimMode = 'auto';h.axes_lifetime_ind_2d.CLim(1) = 0;
%%% find the image plot
xdata = plots(strcmp(type,'image')).XData;
ydata = plots(strcmp(type,'image')).YData;
zdata = plots(strcmp(type,'image')).CData;

if sum(zdata(:)) == 0
    return;
end
histx = sum(zdata,1);
histy = sum(zdata,2);

BurstMeta.Plots.LifetimeInd_histX(1).XData = xdata;
BurstMeta.Plots.LifetimeInd_histX(1).YData = histx;
BurstMeta.Plots.LifetimeInd_histX(2).XData = [xdata,xdata(end)+min(diff(xdata))]-min(diff(xdata))/2;
BurstMeta.Plots.LifetimeInd_histX(2).YData = [histx, histx(end)];

BurstMeta.Plots.LifetimeInd_histY(1).XData = ydata;
BurstMeta.Plots.LifetimeInd_histY(1).YData = histy;
BurstMeta.Plots.LifetimeInd_histY(2).XData = [ydata,ydata(end)+min(diff(ydata))]-min(diff(ydata))/2;
BurstMeta.Plots.LifetimeInd_histY(2).YData = [histy; histy(end)];

h.axes_lifetime_ind_1d_x.XLim = origin.XLim;
h.axes_lifetime_ind_1d_y.XLim = origin.YLim;
h.axes_lifetime_ind_1d_x.YLim = [0,max(histx)*1.05];
h.axes_lifetime_ind_1d_y.YLim = [0,max(histy)*1.05];

if  h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1 %%% multiple species selected, color automatically
    [H,xbins,ybins,xlimits,ylimits,datapoints,n_per_species] = MultiPlot([],[],h,paramX,paramY,{origin.XLim,origin.YLim});
    normalize = UserValues.BurstBrowser.Settings.Normalize_Multiplot && ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Hex');
    if gcbo ~= h.MultiPlotButton
        %%% prepare 1d hists
        binsx = linspace(xlimits(1),xlimits(2),numel(xbins)+1);
        binsy = linspace(ylimits(1),ylimits(2),numel(ybins)+1);
        n_per_species = cumsum([1,(n_per_species-1)]);
        for i = 1:numel(n_per_species)-1
            hx{i} = histcounts(datapoints(n_per_species(i):n_per_species(i+1),1),binsx); 
            if normalize;hx{i} = hx{i}./sum(hx{i});end;
            hy{i} = histcounts(datapoints(n_per_species(i):n_per_species(i+1),2),binsy); 
            if normalize;hy{i} = hy{i}./sum(hy{i});end;
        end
        color = lines(numel(n_per_species));
        for i = 1:numel(hx)
            BurstMeta.Plots.MultiScatter.h1dx_lifetime(i) = handle(stairs(binsx,[hx{i},hx{i}(end)],'Color',color(i,:),'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_x));
            BurstMeta.Plots.MultiScatter.h1dy_lifetime(i) = handle(stairs(binsy,[hy{i},hy{i}(end)],'Color',color(i,:),'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_y));
        end
        if UserValues.BurstBrowser.Settings.Display_Total_Multiplot
            hx_total = sum(vertcat(hx{:}),1);hy_total = sum(vertcat(hy{:}),1);
            BurstMeta.Plots.MultiScatter.h1dx_lifetime(end+1) = handle(stairs(binsx,[hx_total,hx_total(end)],'Color',[0,0,0],'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_x));
            BurstMeta.Plots.MultiScatter.h1dy_lifetime(end+1) = handle(stairs(binsy,[hy_total,hy_total(end)],'Color',[0,0,0],'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_y));
        end
    elseif gcbo == h.MultiPlotButton
        [zz,color] = overlay_colored(H);
        del = false(numel(h.axes_lifetime_ind_2d.Children),1);
        for k = 1:numel(h.axes_lifetime_ind_2d.Children)
            if ~strcmp(h.axes_lifetime_ind_2d.Children(k).Type,'line')
                del(k) = true;
            end
        end
        delete(h.axes_lifetime_ind_2d.Children(del));
        
        normalize = UserValues.BurstBrowser.Settings.Normalize_Multiplot;
        
        multiplot = imagesc(h.axes_lifetime_ind_2d,xbins,ybins,zz);
        uistack(multiplot,'bottom'); multiplot.UIContextMenu = h.ExportGraphLifetime_Menu;
        white = 1-UserValues.BurstBrowser.Display.MultiPlotMode;
        %%% set alpha property
        if white == 0
            multiplot.AlphaData = sum(zz,3)>0;
        else
            multiplot.AlphaData = 1-(sum(zz,3)==3);
        end
        %plot first histogram
        hx = sum(H{1},1);
        if normalize
            hx = hx./sum(hx);
        end
        hx = hx'; hx = [hx; hx(end)];
        xbins = [xbins, xbins(end)+min(diff(xbins))]-min(diff(xbins))/2;
        BurstMeta.Plots.MultiScatter.h1dx_lifetime(1) = handle(stairs(xbins,hx,'Color',color(1,:),'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_x));
        %plot rest of histograms
        for i = 2:numel(H)
            hx = sum(H{i},1);
            if normalize
                hx = hx./sum(hx);
            end
            hx = hx'; hx = [hx; hx(end)];
            BurstMeta.Plots.MultiScatter.h1dx_lifetime(i) = handle(stairs(xbins,hx,'Color',color(i,:),'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_x));
        end
        
        %plot first histogram
        hy = sum(H{1},2);
        if normalize
            hy = hy./sum(hy);
        end
        hy = [hy; hy(end)];
        ybins = [ybins, ybins(end)+min(diff(ybins))]-min(diff(ybins))/2;
        BurstMeta.Plots.MultiScatter.h1dy_lifetime(1) = handle(stairs(ybins,hy,'Color',color(1,:),'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_y));
        %plot rest of histograms
        for i = 2:numel(H)
            hy = sum(H{i},2);
            if normalize
                hy = hy./sum(hy);
            end
            hy = [hy; hy(end)];
            BurstMeta.Plots.MultiScatter.h1dy_lifetime(i) = handle(stairs(ybins,hy,'Color',color(i,:),'LineWidth',2,'Parent',h.axes_lifetime_ind_1d_y));
        end
    end
    %%% hide normal 1d plots
    set(BurstMeta.Plots.LifetimeInd_histX,'Visible','off');
    set(BurstMeta.Plots.LifetimeInd_histY,'Visible','off');
    
    %%% add legend
    [file_n,species_n,subspecies_n,sel] = get_multiselection(h);
    num_species = numel(file_n);
    str = cell(num_species,1);
    for i = 1:num_species
        %%% extract name
        name = BurstData{file_n(i)}.FileName;
        if (species_n(i) ~= 0)
            if (subspecies_n(i) ~= 1) %%% we have a subspecies selected
                name = [name,'/', char(sel(i).getParent.getName),'/',char(sel(i).getName)];
            else %%% we have a species selected 
                name = [name,'/', char(sel(i).getName)];
            end
        end
        str{i} = strrep(name,'_',' ');  
    end
    if gcbo ~= h.MultiPlotButton
        if UserValues.BurstBrowser.Settings.Display_Total_Multiplot
            legend(h.axes_lifetime_ind_1d_x.Children((num_species+1):-1:2),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
        else
            legend(h.axes_lifetime_ind_1d_x.Children(num_species:-1:1),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
        end
    elseif gcbo ==  h.MultiPlotButton
        legend(h.axes_lifetime_ind_1d_x.Children(num_species:-1:1),str,'Interpreter','none','FontSize',12,'Box','off','Color','none');
    end
    h.axes_lifetime_ind_1d_x.YLimMode = 'auto';
    h.axes_lifetime_ind_1d_y.YLimMode = 'auto';
end
h.axes_lifetime_ind_1d_x.YTickMode = 'auto';
yticks= get(h.axes_lifetime_ind_1d_x,'YTick');
set(h.axes_lifetime_ind_1d_x,'YTick',yticks(2:end));
h.axes_lifetime_ind_1d_y.YTickMode = 'auto';
yticks= get(h.axes_lifetime_ind_1d_y,'YTick');
set(h.axes_lifetime_ind_1d_y,'YTick',yticks(2:end));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Lifetime Plot (+fit) in the left Corrections Tab %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateLifetimeFits(obj,~)
global BurstData UserValues BurstMeta
h = guidata(obj);
file = BurstMeta.SelectedFile;
%%% Use the current cut Data (of the selected species) for plots
datatoplot = BurstData{file}.DataCut;
%%% read out the indices of the parameters to plot
switch BurstData{file}.BAMethod
    case {1,2,5}
        idx_tauGG = strcmp('Lifetime D [ns]',BurstData{file}.NameArray);
        idx_tauRR = strcmp('Lifetime A [ns]',BurstData{file}.NameArray);
        idx_rGG = strcmp('Anisotropy D',BurstData{file}.NameArray);
        idx_rRR = strcmp('Anisotropy A',BurstData{file}.NameArray);
    case {3,4}
        idx_tauGG = strcmp('Lifetime GG [ns]',BurstData{file}.NameArray);
        idx_tauRR = strcmp('Lifetime RR [ns]',BurstData{file}.NameArray);
        idx_rGG = strcmp('Anisotropy GG',BurstData{file}.NameArray);
        idx_rRR = strcmp('Anisotropy RR',BurstData{file}.NameArray);
end
%% Add Fits
if obj == h.PlotStaticFRETButton
    %% Add a static FRET line EvsTau plots
    %%% Calculate static FRET line in presence of linker fluctuations
    [staticFRETline, ~,tau] = conversion_tau(BurstData{file}.Corrections.DonorLifetime,...
        BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength);
    BurstMeta.Plots.Fits.staticFRET_EvsTauGG.Visible = 'on';
    BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData = tau;
    BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData = staticFRETline;
    %BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG.Visible = 'off';
    if any(BurstData{file}.BAMethod == [3,4])
        %%% Calculate static FRET line in presence of linker fluctuations
        [staticFRETline,~,tau] = conversion_tau_3C(BurstData{file}.Corrections.DonorLifetimeBlue,...
            BurstData{file}.Corrections.FoersterRadiusBG,BurstData{file}.Corrections.FoersterRadiusBR,...
            BurstData{file}.Corrections.LinkerLengthBG,BurstData{file}.Corrections.LinkerLengthBR);
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.Visible = 'on';
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.XData = tau;
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.YData = staticFRETline;
    end
end
if any(obj == [h.PlotDynamicFRETButton, h.DynamicFRETManual_Menu, h.DynamicFRETRemove_Menu])
    switch obj
        case {h.PlotDynamicFRETButton, h.DynamicFRETManual_Menu}
            if obj == h.PlotDynamicFRETButton
                menu_stored = h.axes_EvsTauGG.UIContextMenu; 
                h.axes_EvsTauGG.UIContextMenu = []; set(h.axes_EvsTauGG.Children,'UIContextMenu',[]);
                h.axes_lifetime_ind_2d.UIContextMenu = []; set(h.axes_lifetime_ind_2d.Children,'UIContextMenu',[]);
                %%% Query Lifetimes using ginput
                [x,~,button] = ginput(2);
                if gca == h.axes_lifetime_ind_2d
                    switch BurstData{file}.BAMethod
                        case {1,2}
                            switch h.lifetime_ind_popupmenu.Value
                                case 1 % E vs tauGG is selected
                                    axes(h.axes_EvsTauGG)
                            end
                        case {3,4}
                            switch h.lifetime_ind_popupmenu.Value
                                case 1 % E vs tauGG is selected
                                    axes(h.axes_EvsTauGG)
                            end
                    end
                end
                if gca ~= h.axes_EvsTauGG
                    m=msgbox('Click on a E vs. tauGG axis!');
                    pause(1);
                    delete(m);
                    return;
                end
                %y = conversion_tau(BurstData{file}.Corrections.DonorLifetime,...
                %    BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength,...
                %    x);
                if button(1) == 1 %%% left mouseclick, update first line, reset all others off
                    BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(2).Visible = 'off';
                    BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(3).Visible = 'off';
                    line = 1;
                elseif button(1) == 3
                    %%% Check for visibility of plots
                    for i = 1:3
                        vis(i) = strcmp(BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(i).Visible,'on');
                    end
                    if sum(vis) == 3 %% all visible
                        line = 3; %%% update last plot
                    elseif sum(vis) == 0 %% all hidden
                        line = 1;
                    else %%% find the first hidden plot
                        line = find(vis == 0, 1,'first');
                    end
                end
                h.axes_EvsTauGG.UIContextMenu = menu_stored; set(h.axes_EvsTauGG.Children,'UIContextMenu',menu_stored);
                h.axes_lifetime_ind_2d.UIContextMenu = h.axes_lifetime_ind_1d_x.UIContextMenu; set(h.axes_lifetime_ind_2d.Children,'UIContextMenu',h.axes_lifetime_ind_1d_x.UIContextMenu);
            elseif obj == h.DynamicFRETManual_Menu
                %%% Query using edit box
                %y = inputdlg({'FRET Efficiency 1','FRET Efficiency 2'},'Enter State Efficiencies',1,{'0.25','0.75'});
                data = inputdlg({'Line #','tau1 [ns]','tau2 [ns]'},'Enter State Lifetimes',1,{'1','1','3'});
                data = cellfun(@str2double,data);
                if any(isnan(data)) || isempty(data)
                    return;
                end
                x = data(2:end);
                line = data(1);
                if line < 1 || line > 3
                    return;
                end
                %y = conversion_tau(BurstData{file}.Corrections.DonorLifetime,...
                %    BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength,...
                %    x);
            end
            [dynFRETline, ~,tau] = dynamicFRETline(BurstData{file}.Corrections.DonorLifetime,...
                x(1),x(2),BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength);
            BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(line).Visible = 'on';
            BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(line).XData = tau;
            BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(line).YData = dynFRETline;
        case h.DynamicFRETRemove_Menu
            data = inputdlg({'Line #'},'Remove dynamic line...',1,{'1'});
            data = cellfun(@str2double,data);
            if any(isnan(data))
                return;
            end
            for i=1:numel(data)
                BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(data(i)).Visible = 'off';
            end
    end
end
if obj == h.FitAnisotropyButton
    %% Add Perrin Fits to Anisotropy Plot
    %% GG
    fPerrin = @(rho,x) BurstData{file}.Corrections.r0_green./(1+x./rho); %%% x = tau
    if ~h.MultiselectOnCheckbox.UserData
        tauGG = datatoplot(:,idx_tauGG);
        rGG = datatoplot(:,idx_rGG);
    else
        switch BurstData{file}.BAMethod
            case {1,2,5}
                tauGG = get_multiselection_data(h,'Lifetime D [ns]');
                rGG = get_multiselection_data(h,'Anisotropy D');
            case {3,4}
                tauGG = get_multiselection_data(h,'Lifetime GG [ns]');
                rGG = get_multiselection_data(h,'Anisotropy GG');
        end
    end
    PerrinFitGG = fit(tauGG(~isnan(tauGG)),rGG(~isnan(tauGG)),fPerrin,'StartPoint',1);
    tau = linspace(0,h.axes_rGGvsTauGG.XLim(2),100);
    BurstMeta.Plots.Fits.PerrinGG(1).Visible = 'on';
    BurstMeta.Plots.Fits.PerrinGG(1).XData = tau;
    BurstMeta.Plots.Fits.PerrinGG(1).YData = PerrinFitGG(tau);
    BurstMeta.Plots.Fits.PerrinGG(2).Visible = 'off';
    BurstMeta.Plots.Fits.PerrinGG(3).Visible = 'off';
    
    BurstData{file}.Parameters.rhoGG = coeffvalues(PerrinFitGG);
    if any(BurstData{file}.BAMethod == [3,4])
        title(h.axes_rGGvsTauGG,['\rho_{GG} = ' sprintf('%2.2f',BurstData{file}.Parameters.rhoGG) ' ns'],'Color',UserValues.Look.Fore);
    else
        title(h.axes_rGGvsTauGG,['\rho_{D} = ' sprintf('%2.2f',BurstData{file}.Parameters.rhoGG) ' ns'],'Color',UserValues.Look.Fore);
    end
    %% RR
    fPerrin = @(rho,x) BurstData{file}.Corrections.r0_red./(1+x./rho); %%% x = tau
    if ~h.MultiselectOnCheckbox.UserData
        tauRR = datatoplot(:,idx_tauRR);
        rRR = datatoplot(:,idx_rRR);
    else
        switch BurstData{file}.BAMethod
            case {1,2,5}
                tauRR = get_multiselection_data(h,'Lifetime A [ns]');
                rRR = get_multiselection_data(h,'Anisotropy A');
            case {3,4}
                tauRR = get_multiselection_data(h,'Lifetime RR [ns]');
                rRR = get_multiselection_data(h,'Anisotropy RR');
        end
    end
    PerrinFitRR = fit(tauRR(~isnan(tauRR)),rRR(~isnan(tauRR)),fPerrin,'StartPoint',1);
    tau = linspace(0,h.axes_rRRvsTauRR.XLim(2),100);
    BurstMeta.Plots.Fits.PerrinRR(1).Visible = 'on';
    BurstMeta.Plots.Fits.PerrinRR(1).XData = tau;
    BurstMeta.Plots.Fits.PerrinRR(1).YData = PerrinFitRR(tau);
    BurstMeta.Plots.Fits.PerrinRR(2).Visible = 'off';
    BurstMeta.Plots.Fits.PerrinRR(3).Visible = 'off';
    BurstData{file}.Parameters.rhoRR = coeffvalues(PerrinFitRR);
    if any(BurstData{file}.BAMethod == [3,4])
        title(h.axes_rRRvsTauRR,['\rho_{RR} = ' sprintf('%2.2f',BurstData{file}.Parameters.rhoRR) ' ns'],'Color',UserValues.Look.Fore);
    else
        title(h.axes_rRRvsTauRR,['\rho_{A} = ' sprintf('%2.2f',BurstData{file}.Parameters.rhoRR) ' ns'],'Color',UserValues.Look.Fore);
    end
    if any(BurstData{file}.BAMethod == [3,4])
        %% BB
        idx_tauBB = strcmp('Lifetime BB [ns]',BurstData{file}.NameArray);
        idx_rBB = strcmp('Anisotropy BB',BurstData{file}.NameArray);
        if ~h.MultiselectOnCheckbox.UserData
            tauBB = datatoplot(:,idx_tauBB);
            rBB = datatoplot(:,idx_rBB);
        else
            tauBB = get_multiselection_data(h,'Lifetime BB [ns]');
            rBB = get_multiselection_data(h,'Anisotropy BB');
        end
        fPerrin = @(rho,x) BurstData{file}.Corrections.r0_blue./(1+x./rho); %%% x = tau
        valid = (tauBB > 0.01) & (tauBB < 5) &...
            (rBB > -1) & (rBB < 2) &...
            (~isnan(tauBB));
        PerrinFitBB = fit(tauBB(valid),rBB(valid),fPerrin,'StartPoint',1);
        tau = linspace(0,h.axes_rBBvsTauBB.XLim(2),100);
        BurstMeta.Plots.Fits.PerrinBB(1).Visible = 'on';
        BurstMeta.Plots.Fits.PerrinBB(1).XData = tau;
        BurstMeta.Plots.Fits.PerrinBB(1).YData = PerrinFitBB(tau);
        BurstMeta.Plots.Fits.PerrinBB(2).Visible = 'off';
        BurstMeta.Plots.Fits.PerrinBB(3).Visible = 'off';
        BurstData{file}.Parameters.rhoBB = coeffvalues(PerrinFitBB);
        title(h.axes_rBBvsTauBB,['\rho_{BB} = ' num2str(BurstData{file}.Parameters.rhoBB) ' ns'],'Color',UserValues.Look.Fore);
    end
end
%% Manual Perrin plots
if obj == h.ManualAnisotropyButton
    %%% disable right-click callbacks
    BurstMeta.Plots.rGGvsTauGG(1).UIContextMenu =[];BurstMeta.Plots.rGGvsTauGG(2).UIContextMenu = [];
    BurstMeta.Plots.rRRvsTauRR(1).UIContextMenu =[];BurstMeta.Plots.rRRvsTauRR(2).UIContextMenu = [];
    BurstMeta.Plots.rBBvsTauBB(1).UIContextMenu =[];BurstMeta.Plots.rBBvsTauBB(2).UIContextMenu = [];
    h.axes_lifetime_ind_2d.UIContextMenu = []; set(h.axes_lifetime_ind_2d.Children,'UIContextMenu',[]);
    [x,y,button] = ginput(1);
    %%% Lifetime Ind plot: If it was selected, check what plot is active
    %%% and set gca accordingly
    if gca == h.axes_lifetime_ind_2d
        switch BurstData{file}.BAMethod
            case {1,2}
                switch h.lifetime_ind_popupmenu.Value
                    case 3 %%% rGG  vs tauGG
                        axes(h.axes_rGGvsTauGG);
                    case 4
                        axes(h.axes_rRRvsTauRR);
                    otherwise
                        m = msgbox('Click on a anistropy axis!');
                        pause(1)
                        delete(m)
                        return;
                end
            case {3,4}
                switch h.lifetime_ind_popupmenu.Value
                    case 4 %%% rGG  vs tauGG
                        axes(h.axes_rGGvsTauGG);
                    case 5
                        axes(h.axes_rRRvsTauRR);
                    case 6
                        axes(h.axes_rBBvsTauBB);
                    otherwise
                        m = msgbox('Click on a anistropy axis!');
                        pause(1)
                        delete(m)
                        return;
                end
        end
    end
    if button == 1 %%% left mouse click, reset plot and plot one perrin line
        if (gca == h.axes_rGGvsTauGG) || (gca == h.axes_rRRvsTauRR) || (gca == h.axes_rBBvsTauBB)
            haxes = gca;
            %%% Determine rho
            switch gca
                case h.axes_rGGvsTauGG
                    r0 = BurstData{file}.Corrections.r0_green;
                case h.axes_rRRvsTauRR
                    r0 = BurstData{file}.Corrections.r0_red;
                case h.axes_rBBvsTauBB
                    r0 = BurstData{file}.Corrections.r0_blue;
            end
            rho = x/(r0/y - 1);
            fitPerrin = @(x) r0./(1+x./rho);
            %%% plot
            tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
            switch haxes
                case h.axes_rGGvsTauGG
                    BurstMeta.Plots.Fits.PerrinGG(1).Visible = 'on';
                    BurstMeta.Plots.Fits.PerrinGG(1).XData = tau;
                    BurstMeta.Plots.Fits.PerrinGG(1).YData = fitPerrin(tau);
                    BurstMeta.Plots.Fits.PerrinGG(2).Visible = 'off';
                    BurstMeta.Plots.Fits.PerrinGG(3).Visible = 'off';
                    if any(BurstData{file}.BAMethod == [3,4])
                        title(['\rho_{GG} = ' sprintf('%2.2f',rho) ' ns'],'Color',UserValues.Look.Fore);
                    else
                        title(['\rho_{D} = ' sprintf('%2.2f',rho) ' ns'],'Color',UserValues.Look.Fore);
                    end
                    BurstData{file}.Parameters.rhoGG = rho;
                case h.axes_rRRvsTauRR
                    BurstMeta.Plots.Fits.PerrinRR(1).Visible = 'on';
                    BurstMeta.Plots.Fits.PerrinRR(1).XData = tau;
                    BurstMeta.Plots.Fits.PerrinRR(1).YData = fitPerrin(tau);
                    BurstMeta.Plots.Fits.PerrinRR(2).Visible = 'off';
                    BurstMeta.Plots.Fits.PerrinRR(3).Visible = 'off';
                    if any(BurstData{file}.BAMethod == [3,4])
                        title(['\rho_{RR} = ' sprintf('%2.2f',rho) ' ns'],'Color',UserValues.Look.Fore);
                    else
                        title(['\rho_{A} = ' sprintf('%2.2f',rho) ' ns'],'Color',UserValues.Look.Fore);
                    end
                    BurstData{file}.Parameters.rhoRR = rho;
                case h.axes_rBBvsTauBB
                    BurstMeta.Plots.Fits.PerrinBB(1).Visible = 'on';
                    BurstMeta.Plots.Fits.PerrinBB(1).XData = tau;
                    BurstMeta.Plots.Fits.PerrinBB(1).YData = fitPerrin(tau);
                    BurstMeta.Plots.Fits.PerrinBB(2).Visible = 'off';
                    BurstMeta.Plots.Fits.PerrinBB(3).Visible = 'off';
                    title(['\rho_{BB} = ' sprintf('%2.2f',rho) ' ns'],'Color',UserValues.Look.Fore);
                    BurstData{file}.Parameters.rhoBB = rho;
            end
        end
    elseif button == 3 %%% right mouse click, add plot if a Perrin plot already exists
        haxes = gca;
        if haxes == h.axes_rGGvsTauGG
            %%% Check for visibility of plots
            vis = 0;
            for i = 1:3
                vis = vis + strcmp(BurstMeta.Plots.Fits.PerrinGG(i).Visible,'on');
            end
            if vis < 3
                %%% Determine rho
                r0 = BurstData{file}.Corrections.r0_green;
                rho = x/(r0/y - 1);
                fitPerrin = @(x) r0./(1+x./rho);
                tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
                BurstMeta.Plots.Fits.PerrinGG(vis+1).Visible = 'on';
                BurstMeta.Plots.Fits.PerrinGG(vis+1).XData = tau;
                BurstMeta.Plots.Fits.PerrinGG(vis+1).YData = fitPerrin(tau);
                if vis == 0
                    if any(BurstData{file}.BAMethod == [3,4])
                        title(haxes,['\rho_{GG} = ' sprintf('%2.2f',rho)],'Color',UserValues.Look.Fore);
                    else
                        title(haxes,['\rho_{D} = ' sprintf('%2.2f',rho)],'Color',UserValues.Look.Fore);
                    end
                else
                    %%% add rho2 to title
                    new_title = [haxes.Title.String ' and ' sprintf('%2.2f',rho) ' ns'];
                    title(new_title);
                end
                BurstData{file}.Parameters.rhoGG(vis+1) = rho;
            end
        elseif haxes == h.axes_rRRvsTauRR
            %%% Check for visibility of plots
            vis = 0;
            for i = 1:3
                vis = vis + strcmp(BurstMeta.Plots.Fits.PerrinRR(i).Visible,'on');
            end
            if vis < 3
                %%% Determine rho
                r0 = BurstData{file}.Corrections.r0_red;
                rho = x/(r0/y - 1);
                fitPerrin = @(x) r0./(1+x./rho);
                tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
                BurstMeta.Plots.Fits.PerrinRR(vis+1).Visible = 'on';
                BurstMeta.Plots.Fits.PerrinRR(vis+1).XData = tau;
                BurstMeta.Plots.Fits.PerrinRR(vis+1).YData = fitPerrin(tau);
                if vis == 0
                    if any(BurstData{file}.BAMethod == [3,4])
                        title(haxes,['\rho_{RR} = ' sprintf('%2.2f',rho)],'Color',UserValues.Look.Fore);
                    else
                        title(haxes,['\rho_{A} = ' sprintf('%2.2f',rho)],'Color',UserValues.Look.Fore);
                    end
                else
                    %%% add rho2 to title
                    new_title = [haxes.Title.String ' and ' sprintf('%2.2f',rho) ' ns'];
                    title(new_title);
                end
                BurstData{file}.Parameters.rhoRR(vis+1) = rho;
            end
        elseif haxes == h.axes_rBBvsTauBB
            %%% Check for visibility of plots
            vis = 0;
            for i = 1:3
                vis = vis + strcmp(BurstMeta.Plots.Fits.PerrinBB(i).Visible,'on');
            end
            if vis < 3
                %%% Determine rho
                r0 = BurstData{file}.Corrections.r0_blue;
                rho = x/(r0/y - 1);
                fitPerrin = @(x) r0./(1+x./rho);
                tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
                BurstMeta.Plots.Fits.PerrinBB(vis+1).Visible = 'on';
                BurstMeta.Plots.Fits.PerrinBB(vis+1).XData = tau;
                BurstMeta.Plots.Fits.PerrinBB(vis+1).YData = fitPerrin(tau);
                if vis == 0
                    title(haxes,['\rho_{BB} = ' sprintf('%2.2f',rho)],'Color',UserValues.Look.Fore);
                else
                    %%% add rho2 to title
                    new_title = [haxes.Title.String ' and ' sprintf('%2.2f',rho) ' ns'];
                    title(new_title);
                end
                BurstData{file}.Parameters.rhoBB(vis+1) = rho;
            end
        end
    end
    %%% reenable right-click callbacks
    BurstMeta.Plots.rGGvsTauGG(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.rGGvsTauGG(2).UIContextMenu = h.LifeTime_Menu;
    BurstMeta.Plots.rRRvsTauRR(1).UIContextMenu =h.LifeTime_Menu;BurstMeta.Plots.rRRvsTauRR(2).UIContextMenu = h.LifeTime_Menu;
    BurstMeta.Plots.rBBvsTauBB(1).UIContextMenu =h.LifeTime_Menu;BurstMeta.Plots.rBBvsTauBB(2).UIContextMenu = h.LifeTime_Menu;
    h.axes_lifetime_ind_2d.UIContextMenu = h.axes_lifetime_ind_1d_x.UIContextMenu; set(h.axes_lifetime_ind_2d.Children,'UIContextMenu',h.axes_lifetime_ind_1d_x.UIContextMenu);
end
PlotLifetimeInd([],[],h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Executes on Tab-Change in Main Window and updates Plots %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TabSelectionChange(obj,e)
h = guidata(obj);
if isempty(h)
    return;
end

switch obj %%% distinguish between maintab change and lifetime subtab change
    case h.Main_Tab
        switch e.NewValue
            case h.Main_Tab_General
                %%% we switched to the general tab
                UpdatePlot([],[],h);
            case h.Main_Tab_Lifetime
                %%% we switched to the lifetime tab
                %%% figure out what subtab is selected
                UpdateLifetimePlots([],[],h);
                switch h.LifetimeTabgroup.SelectedTab
                    case h.LifetimeTabAll
                    case h.LifetimeTabInd
                        PlotLifetimeInd([],[],h);
                end     
        end
    case h.LifetimeTabgroup %%% we clicked the lifetime subtabgroup
        UpdateLifetimePlots([],[],h);
        switch e.NewValue
            case h.LifetimeTabAll
            case h.LifetimeTabInd
                PlotLifetimeInd([],[],h);
        end
end
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Reads out the Donor only lifetime from Donor only bursts %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DonorOnlyLifetimeCallback(obj,~)
global BurstData UserValues BurstMeta
h = guidata(obj);
file = BurstMeta.SelectedFile;

LSUserValues(0);

if ~h.MultiselectOnCheckbox.UserData
    data = BurstData{file}.DataArray;
else
    files = get_multiselection(h);
    files = unique(files);
    data = cell(numel(files),1);
    for i = 1:numel(files)
        data{i} = BurstData{files(i)}.DataArray;
    end
    data = vertcat(data{:});
    %%% for future reference: we are assuming that all files have the same
    %%% NameArray!
end
%%% Determine Donor Only lifetime from data with S > 0.95
switch BurstData{file}.BAMethod
    case {1,2,5}
        idx_tauGG = strcmp(BurstData{file}.NameArray,'Lifetime D [ns]');
    case {3,4}
        idx_tauGG = strcmp(BurstData{file}.NameArray,'Lifetime GG [ns]');
end
%%% catch case where no lifetime was determined

if all(data(:,idx_tauGG) == 0)
    return;
end
if any(BurstData{file}.BAMethod == [1,2,5])
    idxS = strcmp(BurstData{file}.NameArray,'Stoichiometry');
    valid = (data(:,idxS) > UserValues.BurstBrowser.Settings.S_Donly_Min) & (data(:,idxS) < UserValues.BurstBrowser.Settings.S_Donly_Max);
elseif any(BurstData{file}.BAMethod == [3,4])
    idxS = strcmp(BurstData{file}.NameArray,'Stoichiometry GR');
    %idxSBG = strcmp(BurstData{file}.NameArray,'Stoichiometry BG');
    valid = (data(:,idxS) > UserValues.BurstBrowser.Settings.S_Donly_Min) & (data(:,idxS) < UserValues.BurstBrowser.Settings.S_Donly_Max);% &...
        %(BurstData{file}.DataArray(:,idxSBG) > 0) & (BurstData{file}.DataArray(:,idxSBG) < 0.1);
end
x_axis = 0:0.05:10;
htauGG = histc(data(valid,idx_tauGG),x_axis);

x_axis = x_axis(1:end-1);
htauGG(end-1) = htauGG(end-1)+htauGG(end);
htauGG(end) = [];
BurstMeta.Plots.histE_donly.XData = x_axis;
BurstMeta.Plots.histE_donly.YData = htauGG;
h.Corrections.TwoCMFD.axes_crosstalk.XLabel.String = 'Lifetime D [ns]';
h.Corrections.TwoCMFD.axes_crosstalk.Title.String = 'Lifetime of Donor only';
axis(h.Corrections.TwoCMFD.axes_crosstalk,'tight');
%%% fit
[DonorOnlyLifetime, GaussFit] = GaussianFit(x_axis',htauGG);
BurstMeta.Plots.Fits.histE_donly(1).XData = x_axis;
BurstMeta.Plots.Fits.histE_donly(1).YData = GaussFit;
h.Corrections.TwoCMFD.axes_crosstalk.XLim = [0, DonorOnlyLifetime+3*sqrt(sum((x_axis'-DonorOnlyLifetime).^2.*GaussFit)./sum(GaussFit))];
%%% Update GUI
h.DonorLifetimeEdit.String = num2str(DonorOnlyLifetime);
UserValues.BurstBrowser.Corrections.DonorLifetime = DonorOnlyLifetime;
%%% Determine Acceptor Only Lifetime from data with S < 0.1
if any(BurstData{file}.BAMethod == [1,2,5])
    idx_tauRR = strcmp(BurstData{file}.NameArray,'Lifetime A [ns]');
    idxS = strcmp(BurstData{file}.NameArray,'Stoichiometry');
    valid = (data(:,idxS) < UserValues.BurstBrowser.Settings.S_Aonly_Max) & (data(:,idxS) > UserValues.BurstBrowser.Settings.S_Aonly_Min);
elseif any(BurstData{file}.BAMethod == [3,4])
    idx_tauRR = strcmp(BurstData{file}.NameArray,'Lifetime RR [ns]');
    idxS = strcmp(BurstData{file}.NameArray,'Stoichiometry GR');
    %idxSBR = strcmp(BurstData{file}.NameArray,'Stoichiometry BR');
    valid = (data(:,idxS) < UserValues.BurstBrowser.Settings.S_Aonly_Max) & (data(:,idxS) > UserValues.BurstBrowser.Settings.S_Aonly_Min);% &...
        %(BurstData{file}.DataArray(:,idxSBR) < 0.1) & (BurstData{file}.DataArray(:,idxSBR) > -0.1);
end
x_axis = 0:0.05:10;
htauRR = histc(data(valid,idx_tauRR),x_axis);
if size(htauRR,2) > size(htauRR,1)
    htauRR = htauRR';
end
x_axis = x_axis(1:end-1);
htauRR(end-1) = htauRR(end-1)+htauRR(end);
htauRR(end) = [];
BurstMeta.Plots.histS_aonly.XData = x_axis;
BurstMeta.Plots.histS_aonly.YData = htauRR;
h.Corrections.TwoCMFD.axes_direct_excitation.XLabel.String = 'Lifetime A [ns]';
h.Corrections.TwoCMFD.axes_direct_excitation.Title.String = 'Lifetime of Acceptor only';
axis(h.Corrections.TwoCMFD.axes_direct_excitation,'tight');
[AcceptorOnlyLifetime, GaussFit] = GaussianFit(x_axis',htauRR);
BurstMeta.Plots.Fits.histS_aonly(1).XData = x_axis;
BurstMeta.Plots.Fits.histS_aonly(1).YData = GaussFit;
h.Corrections.TwoCMFD.axes_direct_excitation.XLim = [0, AcceptorOnlyLifetime+3*sqrt(sum((x_axis'-AcceptorOnlyLifetime).^2.*GaussFit)./sum(GaussFit))];
%%% Update GUI
h.AcceptorLifetimeEdit.String = num2str(AcceptorOnlyLifetime);
UserValues.BurstBrowser.Corrections.AcceptorLifetime = AcceptorOnlyLifetime;

if ~h.MultiselectOnCheckbox.UserData
    BurstData{file}.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
    BurstData{file}.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
else
    for i = 1:numel(files)
        BurstData{files(i)}.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
        BurstData{files(i)}.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
    end
end

if any(BurstData{file}.BAMethod == [3,4])
    %%% Determine Donor Blue Lifetime from Blue dye only species
    idx_tauBB = strcmp(BurstData{file}.NameArray,'Lifetime BB [ns]');
    idxSBG = strcmp(BurstData{file}.NameArray,'Stoichiometry BG');
    idxSBR = strcmp(BurstData{file}.NameArray,'Stoichiometry BR');

    valid = (data(:,idxSBG) > UserValues.BurstBrowser.Settings.S_Donly_Min) & (data(:,idxSBG) < UserValues.BurstBrowser.Settings.S_Donly_Max) &...
        (data(:,idxSBR) > UserValues.BurstBrowser.Settings.S_Donly_Min) & (data(:,idxSBR) < UserValues.BurstBrowser.Settings.S_Donly_Max);
    x_axis = 0:0.05:10;
    htauBB = histc(data(valid,idx_tauBB),x_axis);
    [DonorBlueLifetime, ~] = GaussianFit(x_axis',htauBB);
    %DonorBlueLifetime = mean(BurstData{file}.DataArray(valid,idx_tauBB));
    h.DonorLifetimeBlueEdit.String = num2str(DonorBlueLifetime);

    UserValues.BurstBrowser.Corrections.DonorLifetimeBlue = DonorBlueLifetime;
    if ~h.MultiselectOnCheckbox.UserData
        BurstData{file}.Corrections.DonorLifetimeBlue = UserValues.BurstBrowser.Corrections.DonorLifetimeBlue;
    else
        for i = 1:numel(files)
            BurstData{files(i)}.Corrections.DonorLifetimeBlue = UserValues.BurstBrowser.Corrections.DonorLifetimeBlue;
        end
    end
    h.Corrections.TwoCMFD.axes_crosstalk.XLabel.String = 'Lifetime GG [ns]';
    h.Corrections.TwoCMFD.axes_direct_excitation.XLabel.String = 'Lifetime RR [ns]';
end
LSUserValues(1);
UpdateLifetimePlots([],[],h);
PlotLifetimeInd([],[],h);
ApplyCorrections([],[],h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates static FRET line with Linker Dynamics %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, func, xval] = conversion_tau(tauD,R0,s,xval_in)
global BurstData BurstMeta
% s = 6;
res = 1000;

%range of RDA center values, i.e. 1000 values in 0*R0 to 3*R0
R = linspace(0*R0,3*R0,res);

%for every R calculate gaussian distribution
p = zeros(numel(R),res);
r = zeros(numel(R),res);
for j = 1:numel(R)
    x = linspace(R(j)-4*s,R(j)+4*s,res);
    dummy = exp(-((x-R(j)).^2)./(2*s^2));
    dummy(x < 0) = 0;
    dummy = dummy./sum(dummy);
    p(j,:) = dummy;
    r(j,:) = x;
end

%calculate lifetime distribution
tau = zeros(numel(R),res);
for j = 1:numel(R)
    tau(j,:) = tauD./(1+((R0./r(j,:)).^6));
end

%calculate species weighted taux
taux = zeros(1,numel(R));
for j = 1:numel(R)
    taux(j) = sum(p(j,:).*tau(j,:));
end

%calculate intensity weighted tauf
tauf = zeros(1,numel(R));
for j = 1:numel(R)
    tauf(j) = sum(p(j,:).*(tau(j,:).^2))./taux(j);
end

%coefficients = polyfit(tauf,taux,3);
%out = 1- ( coefficients(1).*xval.^3 + coefficients(2).*xval.^2 + coefficients(3).*xval + coefficients(4) )./tauD;

if nargin < 4
    %%% no interpolation, just return data
    out = 1-taux./tauD;
    xval = tauf;
else
    %%% return distance at specified intensity-weighted lifetimes (used for calculation of dynamic FRET lines)
    xval = xval_in;
    if xval > tauf(end)
        out = R(end); return;
    end
    if xval < tauf(1);
        out = tauf(1); return;
    end
    %%% find nearest neighbours
    dif = tauf-xval; neg = find(dif < 0,1,'last'); pos = find(dif > 0,1,'first');
    %%% interpolate to zero crossing
    m = (dif(pos)-dif(neg))./(R(pos)-R(neg));
    out = R(neg)-dif(neg)./m;
end
%%% legacy code:
%%% fix for display
%%% set tau=0 to E=1
% out(xval == 0) = 1; % lifetime zero is E = 1
% out(xval == BurstData{BurstMeta.SelectedFile}.Corrections.DonorLifetime) = 0; % lifetime = tauD is E = 0
% valid = ~isnan(out);
% out = out(valid); %%% remove NaNs for E -> 1
% xval = xval(valid);

if nargout > 1
    func = @(x) 1-interp1(tauf,taux,x)./tauD;
end

function [out, func, xval] = conversion_tau_3C(tauD,R0BG,R0BR,sBG,sBR)
global BurstData BurstMeta
res = 10;
xval = linspace(0,tauD,1000);
%range of RDA center values, i.e. 100 values in 0.1*R0 to 10*R0
[RBG, RBR] = meshgrid(linspace(0*R0BG,4*R0BG,100),linspace(0*R0BR,4*R0BR,100));
RBG = RBG(:);
RBR = RBR(:);
%RBG = linspace(0*R0BG,4*R0BG,res);
%RBR = linspace(0*R0BR,4*R0BR,res);
n = numel(RBG);
%for every R calculate gaussian distribution
p = zeros(res,res,n);
rBG = zeros(res,res,n);
rBR = zeros(res,res,n);
for j = 1:n
    [xRBG, xRBR] = meshgrid(linspace(RBG(j)-3*sBG,RBG(j)+3*sBG,res),linspace(RBR(j)-3*sBR,RBR(j)+3*sBR,res));
    dummy = exp(-( ((xRBG-RBG(j)).^2)./(2*sBG^2) + ((xRBR-RBR(j)).^2)./(2*sBR^2) ));
    dummy(xRBG < 0) = 0;
    dummy(xRBR < 0) = 0;
    dummy = dummy./sum(sum(dummy));
    p(:,:,j) = dummy;
    rBG(:,:,j) = xRBG;
    rBR(:,:,j) = xRBR;
end

%calculate lifetime distribution
tau = zeros(res,res,n);
for j = 1:n
    %%% first calculate the Efficiencies B->G and B->R
    EBG = 1./((rBG(:,:,j)./R0BG).^6 + 1);
    EBR = 1./((rBR(:,:,j)./R0BR).^6 + 1);
    %%% calculate E1A from EBG and EBR
    E1A = (EBG.*(1-EBR) + EBR.*(1-EBG))./(1-EBG.*EBR);
    E1A(isnan(E1A)) = 1;
    %%% tau = tau0*(1-E1A)
    tau(:,:,j) = tauD.*(1-E1A);
end

%calculate species weighted taux
taux = zeros(1,n);
for j = 1:n
    taux(j) = sum(sum(p(:,:,j).*tau(:,:,j)));
end

%calculate intensity weighted tauf
tauf = zeros(1,n);
for j = 1:n
    tauf(j) = sum(sum(p(:,:,j).*(tau(:,:,j).^2)))./taux(j);
end

% we need the fitting here because of ambiguity between tauf and taux
% similar taux values can have different tauf values, e.g. one can not
% distinguish between donor (B) quenching due to close G and far R, or close R
% and far G, which will have different effect on the relation between tauf
% and taux due to the mixing.
coefficients = polyfit(tauf,taux,3);
out = 1- ( coefficients(1).*xval.^3 + coefficients(2).*xval.^2 + coefficients(3).*xval + coefficients(4) )./tauD;
% figure;plot(xval,out);hold on;plot(xval,1-interp1(tauf,taux,xval)./tauD)

%out = 1-interp1(tauf,taux,xval)./tauD;
%out(xval == 0) = 1; %%% set E to 1 at tau = 0 (interp1 returns NaN)
%out(xval == BurstData{BurstMeta.SelectedFile}.Corrections.DonorLifetimeBlue) = 0; % lifetime = tauD is E = 0
if nargout > 1
    func = @(x) 1-interp1(tauf,taux,x)./tauD;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates dynamic FRET line between two states  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, func, xval] = dynamicFRETline(tauD,tau1,tau2,R0,s)
res = 1000;
if tau1 > tau2
    xval  = linspace(tau2,tau1,1000);
else
    xval  = linspace(tau1,tau2,1000);
end
%%% Calculate two distance distribution for two states
%%% convert input lifetime (intensity-weighted) to center distance given sigmaR


%%% legacy:
%RDA1 = R0*((tauD/tau1)-1)^(-1/6);
%RDA2 = R0*((tauD/tau2)-1)^(-1/6);
%%% convert to intensity weighted lifetime
%E1 = conversion_tau(tauD,R0,s,tau1);
%E2 = conversion_tau(tauD,R0,s,tau2);
%RDA1 = R0.*(1/E1-1)^(1/6);if E1 == 0;RDA1 = 5*R0-2*s;end;
%RDA2 = R0.*(1/E2-1)^(1/6);if E2 == 0;RDA2 = 5*R0-2*s;end;

RDA1 = conversion_tau(tauD,R0,s,tau1);
RDA2 = conversion_tau(tauD,R0,s,tau2);
r = linspace(0*R0,3*R0,res);
p1 = exp(-((r-RDA1).^2)./(2*s^2));p1 = p1./sum(p1);
p2 = exp(-((r-RDA2).^2)./(2*s^2));p2 = p2./sum(p2);
%%% Generate mixed distributions
x = linspace(0,1,res);
p = zeros(res,res);
for i = 1:numel(x)
    p(i,:) = x(i).*p1 + (1-x(i)).*p2;
end

%calculate lifetime distribution
tau = tauD./(1+((R0./r).^6));


%calculate species weighted taux
taux = zeros(1,numel(x));
for j = 1:numel(x)
    taux(j) = sum(p(j,:).*tau);
end

%calculate intensity weighted tauf
tauf = zeros(1,numel(x));
for j = 1:numel(x)
    tauf(j) = sum(p(j,:).*(tau.^2))./taux(j);
end

%coefficients = polyfit(tauf,taux,3);

%out = 1- ( coefficients(1).*xval.^3 + coefficients(2).*xval.^2 + coefficients(3).*xval + coefficients(4) )./tauD;
out = 1-interp1(tauf,taux,xval)./tauD;
if nargout > 1
    func = @(x) 1-interp1(tauf,taux,x)./tauD;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Normal Correlation of Burst Photon Streams %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Correlate_Bursts(obj,~)
global BurstData BurstTCSPCData PhotonStream UserValues BurstMeta
h = guidata(obj);
%%% Set Up Progress Bar
Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
file = BurstMeta.SelectedFile;
UpdateCuts();
%%% Read out the species name
if (BurstData{file}.SelectedSpecies(1) == 0)
    species = 'total';
elseif (BurstData{file}.SelectedSpecies(1) >= 1)
    species = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),1};
    if (BurstData{file}.SelectedSpecies(2) > 1)
        species = [species '-' BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)}];
    end
end
species = strrep(species,' ','_');
%%% define channels
switch BurstData{file}.BAMethod
    case {1,2}
        Chan = {    1,    2,    3,    4,    5,    6,[1 2],[3 4],[1 2 3 4],[1 3],[2 4],[5 6]};
    case {3,4}
        Chan = {1,2,3,4,5,6,7,8,9,10,11,12,[1 3 5],[2 4 6],[7 9],[8 10], [1 2],[3 4],[5 6],[7 8],[9 10],[11 12],[1 2 3 4 5 6],[7 8 9 10]};
end
%Name = {'GG1','GG2','GR1','GR2','RR1','RR2', 'GG', 'GR','GX','GX1','GX2', 'RR'};
Name = h.Correlation_Table.RowName;
CorrMat = h.Correlation_Table.Data;
NumChans = size(CorrMat,1);
NCor = sum(sum(CorrMat));

switch obj
    case h.Correlate_Button
        %%% Load associated .bps file, containing Macrotime, Microtime and Channel
        Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
        if isempty(BurstTCSPCData{file})
            Load_Photons();
        end
        Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
        %%% find selected bursts
        MT = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
        CH = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);
        
        for k = 1:numel(MT)
            MT{k} = MT{k}-MT{k}(1) +1;
        end
          
    case {h.CorrelateWindow_Button, h.BurstwiseDiffusionTime_Menu}
        if isempty(PhotonStream{file})
            success = Load_Photons('aps');
            if ~success
                Progress(1,h.Progress_Axes,h.Progress_Text);
                return;
            end
        end
        % use selected only
        start = PhotonStream{file}.start(BurstData{file}.Selected);
        stop = PhotonStream{file}.stop(BurstData{file}.Selected);

        
        use_time = 1; %%% use time or photon window
        if use_time
            %%% histogram the Macrotimes in bins of 1 ms
            bw = ceil(1E-3./BurstData{file}.ClockPeriod);
            bins_time = bw.*(0:1:ceil(PhotonStream{file}.Macrotime(end)./bw));
            if ~isfield(PhotonStream{file},'MT_bin')
                %%% find the first photon belonging to a time window
                Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
                [~, PhotonStream{file}.MT_bin] = histc(PhotonStream{file}.Macrotime,bins_time);
                [PhotonStream{file}.unique,PhotonStream{file}.first_idx,~] = unique(PhotonStream{file}.MT_bin);
                %%% store starting macrotime for populated time windows
                used_tw = zeros(numel(bins_time),1);
                used_tw(PhotonStream{file}.unique) = PhotonStream{file}.first_idx;
                %%% some time windows are emtpy
                %%% if the last time window is empty, use the maximum macrotime
                if used_tw(end) == 0
                    last_non_empty = find(used_tw > 0,1,'last');
                    used_tw((last_non_empty+1):end) = numel(PhotonStream{file}.Macrotime);
                end
                %%% fill the rest with start from next non-empty time window
                while sum(used_tw == 0) > 0
                    used_tw(used_tw == 0) = used_tw(find(used_tw == 0)+1);
                end
                PhotonStream{file}.first_idx = used_tw;
            end
            [~, start_bin] = histc(PhotonStream{file}.Macrotime(start),bins_time);
            [~, stop_bin] = histc(PhotonStream{file}.Macrotime(stop),bins_time);
            [~, start_all_bin] = histc(PhotonStream{file}.Macrotime(PhotonStream{file}.start),bins_time);
            [~, stop_all_bin] = histc(PhotonStream{file}.Macrotime(PhotonStream{file}.stop),bins_time);
            
            use = ones(numel(start),1);
            %%% loop over selected bursts
            Progress(0,h.Progress_Axes,h.Progress_Text,'Including Time Window...');
            
            tw = UserValues.BurstBrowser.Settings.Corr_TimeWindowSize; %%% photon window of (2*tw+1)*10ms
            
            if tw > 0
                start_tw = start_bin - tw;start_tw(start_tw < 1) = 1;
                stop_tw = stop_bin + tw;stop_tw(stop_tw > (numel(bins_time) -1)) = numel(bins_time)-1;

                for i = 1:numel(start_tw)
                    %%% Check if ANY burst falls into the time window
                    val = (start_all_bin < stop_tw(i)) & (stop_all_bin > start_tw(i));
                    %%% Check if they are of the same species
                    inval = val & (~BurstData{file}.Selected);
                    %%% if there are bursts of another species in the timewindow,
                    %%% --> remove it
                    if sum(inval) > 0
                        use(i) = 0;
                    end
                    %Progress(i/numel(start),h.Progress_Axes,h.Progress_Text,'Including Time Window...');
                end

                %%% Construct reduced Macrotime and Channel vector
                Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
                MT = cell(sum(use),1);
                CH = cell(sum(use),1);
                k=1;
                for i = 1:numel(start_tw)
                    if use(i)
                        range = PhotonStream{file}.first_idx(start_tw(i)):(PhotonStream{file}.first_idx(stop_tw(i)+1)-1);
                        MT{k} = PhotonStream{file}.Macrotime(range);
                        MT{k} = MT{k}-MT{k}(1) +1;
                        CH{k} = PhotonStream{file}.Channel(range);
                        %val = (PhotonStream{file}.MT_bin > start_tw(i)) & (PhotonStream{file}.MT_bin < stop_tw(i) );
                        %MT{k} = PhotonStream{file}.Macrotime(val);
                        %MT{k} = MT{k}-MT{k}(1) +1;
                        %CH{k} = PhotonStream{file}.Channel(val);
                        k = k+1;
                    end
                    %Progress(i/numel(start_tw),h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
                end
            else
                % default to burst-wise
                if isempty(BurstTCSPCData{file})
                    Load_Photons();
                end
                Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
                %%% find selected bursts
                MT = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
                CH = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);

                for k = 1:numel(MT)
                    MT{k} = MT{k}-MT{k}(1) +1;
                end
            end
        else
            use = ones(numel(start),1);
            %%% loop over selected bursts
            Progress(0,h.Progress_Axes,h.Progress_Text,'Including Time Window...');
            tw = 50; %%% photon window of 100 photons
            
            start_tw = start - tw;
            stop_tw = stop + tw;
            
            for i = 1:numel(start_tw)
                %%% Check if ANY burst falls into the time window
                val = (PhotonStream{file}.start < stop_tw(i)) & (PhotonStream{file}.stop > start_tw(i));
                %%% Check if they are of the same species
                inval = val & (~BurstData{file}.Selected);
                %%% if there are bursts of another species in the timewindow,
                %%% --> remove it
                if sum(inval) > 0
                    use(i) = 0;
                end
                %Progress(i/numel(start),h.Progress_Axes,h.Progress_Text,'Including Time Window...');
            end
            
            %%% Construct reduced Macrotime and Channel vector
            Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
            MT = cell(sum(use),1);
            CH = cell(sum(use),1);
            k=1;
            for i = 1:numel(start_tw)
                if use(i)
                    MT{k} = PhotonStream{file}.Macrotime(start_tw(i):stop_tw(i));MT{k} = MT{k}-MT{k}(1) +1;
                    CH{k} = PhotonStream{file}.Channel(start_tw(i):stop_tw(i));
                    k = k+1;
                end
                Progress(i/numel(start_tw),h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
            end
        end
end

if obj == h.BurstwiseDiffusionTime_Menu
    %%% use all channels for the correlation function
    NumChans = 1;
    CorrMat = 1;
    switch BurstData{file}.BAMethod
        case {1,2}
            Chan = {[1 2 3 4 5 6]};
        case {3,4}
            Chan = {[1 2 3 4 5 6 7 8 9 10 11 12]};
    end
end
%%% Apply different correlation algorithm
%%% (Burstwise correlation with correct summation and normalization)
Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
count = 0;
for i=1:NumChans
    for j=1:NumChans
        if CorrMat(i,j)
            MT1 = cell(numel(MT),1);
            MT2 = cell(numel(MT),1);
            for k = 1:numel(MT)
                MT1{k} = MT{k}(ismember(CH{k},Chan{i}));
                MT2{k} = MT{k}(ismember(CH{k},Chan{j}));
            end
            %%% find empty bursts
            inval = cellfun(@isempty,MT1) | cellfun(@isempty,MT2);
            %%% exclude empty bursts
            MT1 = MT1(~inval); MT2 = MT2(~inval);            
            %%% Applies divider to data
            if UserValues.Settings.Pam.Cor_Divider > 1
                for k=1:numel(MT1)
                    MT1{k}=floor(MT1{k}/UserValues.Settings.Pam.Cor_Divider);
                    MT2{k}=floor(MT2{k}/UserValues.Settings.Pam.Cor_Divider);
                end
            end
            %%% Calculates the maximum inter-photon time in clock ticks
            Maxtime=cellfun(@(x,y) max([x(end) y(end)]),MT1,MT2);
            switch obj
                case {h.Correlate_Button,h.CorrelateWindow_Button}
                    %%% Do Correlation
                    [Cor_Array,Cor_Times]=CrossCorrelation(MT1,MT2,Maxtime,[],[],2);
                    Cor_Times = Cor_Times*BurstData{file}.ClockPeriod*UserValues.Settings.Pam.Cor_Divider;

                    %%% Calculates average and standard error of mean (without tinv_table yet
                    if size(Cor_Array,2)>1
                        Cor_Average=mean(Cor_Array,2);
                        Cor_SEM=std(Cor_Array,0,2);
                    else
                        Cor_Average=Cor_Array{1};
                        Cor_SEM=Cor_Array{1};
                    end

                    %%% Save the correlation file
                    %%% Generates filename
                    filename = fullfile(BurstData{file}.PathName,BurstData{file}.FileName);
                    if obj == h.CorrelateWindow_Button
                        Current_FileName=[filename(1:end-4) '_' species '_' Name{i} '_x_' Name{j} '_tw' num2str(UserValues.BurstBrowser.Settings.Corr_TimeWindowSize) 'ms' '.mcor'];
                    else
                        Current_FileName=[filename(1:end-4) '_' species '_' Name{i} '_x_' Name{j} '_bw' '.mcor'];
                    end
                    %%% Checks, if file already exists
                    if  exist(Current_FileName,'file')
                        k=1;
                        %%% Adds 1 to filename
                        Current_FileName=[Current_FileName(1:end-5) '_' num2str(k) '.mcor'];
                        %%% Increases counter, until no file is found
                        while exist(Current_FileName,'file')
                            k=k+1;
                            Current_FileName=[Current_FileName(1:end-(5+numel(num2str(k-1)))) num2str(k) '.mcor'];
                        end
                    end

                    Header = ['Correlation file for: ' strrep(filename,'\','\\') ' of Channels ' Name{i} ' cross ' Name{j}];
                    %Counts = [numel(MT1) numel(MT2)]/(BurstData{file}.ClockPeriod*max([MT1;MT2]))/1000;
                    Counts = [0 ,0];
                    Valid = 1:size(Cor_Array,2);
                    save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
                    count = count+1;
                case h.BurstwiseDiffusionTime_Menu
                    %%% Do Correlation
                    [Cor_Array,Cor_Times]=CrossCorrelation(MT1,MT2,Maxtime,[],[],3);
                    Cor_Times = Cor_Times*BurstData{file}.ClockPeriod*UserValues.Settings.Pam.Cor_Divider;
                    %%% remove everything below 1E-6 s
                    threshold_low = 1E-5;
                    threshold_high = Cor_Times(end)/10; %%% only consider up to 10%
                    Cor_Array = cellfun(@(x) x(Cor_Times>threshold_low & Cor_Times<threshold_high),Cor_Array,'Uniformoutput',false);
                    Cor_Times = Cor_Times(Cor_Times>threshold_low & Cor_Times<threshold_high);
                    %%% estimate G0 from first 10 time bins
                    G0 = cellfun(@(x) mean(x(x~=-1)),cellfun(@(x) x(1:10),Cor_Array,'Uniformoutput',false),'Uniformoutput',false);
                    %%% get valid time bins, i.e. finite and not equal -1
                    % needs to be done before normalizing
                    valid = cellfun(@(x) isfinite(x) & (x > -1),Cor_Array,'Uniformoutput',false);
                    %%% divide by G0
                    Cor_Array = cellfun(@(x,y) x./y,Cor_Array,G0,'Uniformoutput',false);
                    %%% define model
                    model = @(x,xdata) 1./(1+xdata./x(1));
                    %%% fit the diffusion time
                    tauD = NaN(numel(Cor_Array),1);
                    options = optimoptions('lsqcurvefit','Display','none','FunctionTolerance',1E-3);
                    for i = 1:numel(Cor_Array)
                        y = Cor_Array{i};
                        if sum(valid{i}) > 10 %%% require at least 10 data points
                            res = lsqcurvefit(model,[2e-3],Cor_Times(valid{i}),y(valid{i}),[1E-4],[Inf],options);
                            tauD(i) = res(1);
                        end
                        if mod(i,floor(numel(Cor_Array)/20)) == 0
                            Progress(i/numel(Cor_Array),h.Progress_Axes,h.Progress_Text,'Fitting diffusion time...');
                        end
                    end

                    %%% store in BurstData as extra field
                    if ~isfield(BurstData{file},'AdditionalParameters')
                        BurstData{file}.AdditionalParameters = [];
                    end
                    if ~isfield(BurstData{file}.AdditionalParameters,'tauD')
                        BurstData{file}.AdditionalParameters.tauD = NaN(size(BurstData{file}.DataArray,1),1);
                    end
                    %%% assign back to bursts
                    tauD_temp = NaN(size(use,1),1); 
                    tauD_temp(logical(use)) = tauD;
                    BurstData{file}.AdditionalParameters.tauD(BurstData{file}.Selected) = tauD_temp;
                    %%% ask for omega_r
                    omega_r = inputdlg('Specify focus size in nm:','Focus size?',1,{num2str(UserValues.BurstBrowser.Settings.FocusSize)});
                    if isempty(omega_r)
                        omega_r{1} = num2str(UserValues.BurstBrowser.Settings.FocusSize);
                        disp('Setting default value omega_r from UserValues.');
                    end
                    omega_r = str2num(omega_r{1});
                    if isnan(omega_r)
                        omega_r = UserValues.BurstBrowser.Settings.FocusSize;
                        disp('Setting default value omega_r from UserValues.');
                    end
                    UserValues.BurstBrowser.Settings.FocusSize = omega_r;
                    D = (omega_r./1000).^2./4./(tauD);
                    if ~isfield(BurstData{file}.AdditionalParameters,'DiffusionCoefficient')
                        BurstData{file}.AdditionalParameters.DiffusionCoefficient = NaN(size(BurstData{file}.DataArray,1),1);
                    end
                    %%% assign back to bursts
                    D_temp = NaN(size(use,1),1); 
                    D_temp(logical(use)) = D;
                    BurstData{file}.AdditionalParameters.DiffusionCoefficient(BurstData{file}.Selected) = D_temp;
                    %%% Add parameters to list
                    AddDerivedParameters([],[],h);
                    set(h.ParameterListX, 'String', BurstData{file}.NameArray);
                    set(h.ParameterListY, 'String', BurstData{file}.NameArray);
                    UpdateCuts();
                    UpdatePlot([],[],h);
            end
            Progress(count/NCor,h.Progress_Axes,h.Progress_Text,'Correlating...');
        end
    end
end

%%% Update FCSFit Path
UserValues.File.FCSPath = UserValues.File.BurstBrowserPath;
LSUserValues(1);

Progress(1,h.Progress_Axes,h.Progress_Text);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Load Photon Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function success = Load_Photons(mode)
global PhotonStream BurstData UserValues BurstTCSPCData BurstMeta
h = guidata(findobj('Tag','BurstBrowser')); 
if nargin == 0
    mode = 'bps';
end
file = BurstMeta.SelectedFile;
filename = fullfile(BurstData{file}.PathName,BurstData{file}.FileName);
prev_string = h.Progress_Text.String;
h.Progress_Text.String = 'Loading Photon Data';
success = true;
switch mode
    case 'aps'
        if isempty(PhotonStream)
            PhotonStream = cell(numel(BurstData),1);
        end
        %%% Load associated .aps file, containing Macrotime, Microtime and Channel
        if isempty(PhotonStream{file})
            if exist([filename(1:end-3) 'aps'],'file') == 2
                %%% load if it exists
                S = load([filename(1:end-3) 'aps'],'-mat');
            else
                disp('No *.aps file found.'); 
                h.Progress_Text.String = prev_string; 
                success = false;
                return;
                %%% else ask for the file
                %[FileName,PathName] = uigetfile({'*.aps'}, 'Choose the associated *.aps file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');
                %if FileName == 0
                %    return;
                %end
                %S = load('-mat',fullfile(PathName,FileName));
            end
            % transfer to global array
            PhotonStream{file}.start = S.PhotonStream.start;
            PhotonStream{file}.stop = S.PhotonStream.stop;
            PhotonStream{file}.Macrotime = double(S.PhotonStream.Macrotime);
            PhotonStream{file}.Microtime = S.PhotonStream.Microtime;
            PhotonStream{file}.Channel = S.PhotonStream.Channel;
            clear S;
        end
        %%% Enable CorrelateWindow Button
        %h.CorrelateWindow_Button.Enable = 'on';
        %h.CorrelateWindow_Edit.Enable = 'on';
    case 'bps'
        if exist([filename(1:end-3) 'bps'],'file') == 2
            %%% load if it exists
            BurstTCSPCData{file} = load([filename(1:end-3) 'bps'],'-mat');
        else
            %%% else ask for the file
            [FileName,PathName] = uigetfile({'*.bps'}, 'Choose the associated *.bps file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');
            if FileName == 0
                return;
            end
            BurstTCSPCData{file} = load('-mat',fullfile(PathName,FileName));
            %%% Store the correct Path in BurstData
            BurstData{file}.FileName = [FileName(1:end-3) 'bur'];
        end
        %BurstTCSPCData{file}.Macrotime = Macrotime;%cellfun(@double,Macrotime,'UniformOutput',false);
        %BurstTCSPCData{file}.Microtime = Microtime;%cellfun(@double,Microtime,'UniformOutput',false);
        %BurstTCSPCData{file}.Channel = Channel;%cellfun(@double,Channel,'UniformOutput',false);
        %clear Macrotime Microtime Channel
end
h.Progress_Text.String = prev_string;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Change GUI to 2cMFD or 3cMFD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SwitchGUI(BAMethod,force)
global UserValues
h = guidata(findobj('Tag','BurstBrowser'));
if nargin == 1
    force = 0;
end
%%% convert BAMethod to 2 (2colorMFD) or 3 (3cMFD)
if any(BAMethod == [1,2,5])
    BAMethod = 2;
elseif any(BAMethod == [3,4])
    BAMethod = 3;
end
%%% determine which GUI format is currently used
%%% This can be done by checking whether the Corrections Tab for 3cMFD is
%%% hidden or not
if (h.Main_Tab_Corrections_ThreeCMFD.Parent == h.Hide_Tab)
    %%% Three-color Corrections Tab is currently hidden
    %%% Two-color MFD was set
    PreviousBAMethod = 2;
elseif (h.Main_Tab_Corrections_ThreeCMFD.Parent == h.Main_Tab)
    %%% Three-color Corrections Tab is currently active
    %%% Three-color MFD was set
    PreviousBAMethod = 3;
end

%%% stop here if no change
if force == 0
    if PreviousBAMethod == BAMethod
        return;
    end
end

%%% unhide panel if change is TO 3cMFD
if BAMethod == 3
    %% Change Tabs
    
    %%% move the three-color Corrections Tab to Main Panel
    h.Main_Tab_Corrections_ThreeCMFD.Parent = h.Main_Tab;
    %%% Then add again the other tabs in correct order
    h.Main_Tab_Lifetime.Parent = h.Main_Tab;
    h.Main_Tab_fFCS.Parent = h.Main_Tab;
    
    %h.ExportSpeciesToPDA_2C_for3CMFD_MenuItem.Visible = 'on';
    %% Change correction table
    Corrections_Rownames = {'<html><b>&gamma(GR)</b></html>','<html><b>&gamma(BG)</b></html>','<html><b>&gamma(BR)</b></html>','<html><b>&beta(GR)</b></html>','<html><b>&beta(BG</b>)</html>','<html><b>&beta(BR)</b></html>',...
        '<html><b>crosstalk GR</b></html>','<html><b>crosstalk BG</b></html>','<html><b>crosstalk BR</b></html>','<html><b>direct exc. GR</b></html>','<html><b>direct exc. BG</b></html>','<html><b>direct exc. BR</b></html>',...
        '<html><b>G(blue)</b></html>','<html><b>G(green)</b></html>','<html><b>G(red)</b></html>','<html><b>l1</b></html>','<html><b>l2</b></html>',...
        '<html><b>BG BB par</b></html>','<html><b>BG BB perp</b></html>','<html><b>BG BG par</b></html>','<html><b>BG BG perp</b></html>','<html><b>BG BR par</b></html>','<html><b>BG BR perp</b></html>',...
        '<html><b>BG GG par</b></html>','<html><b>BG GG perp</b></html>','<html><b>BG GR par</b></html>','<html><b>BG GR perp</b></html>','<html><b>BG RR par</b></html>','<html><b>BG RR perp</b></html>'}';
    Corrections_Data = {1;1;1;1;1;1;...
        0;0;0;0;0;0;...
        0;0;0;0;0;0;...
        0;0;0;0;0;0;...
        1;1;1;0;0};
    %% Change Corrections GUI
    h.DetermineGammaLifetimeThreeColorButton.Visible = 'on';
    %%% Add DetermineGammaLifetimeThreeColorButton to layout
    % remove last two elements
    h.ApplyCorrectionsButton.Parent = h.SecondaryTabCorrectionsPanel;
    h.UseBetaCheckbox.Parent = h.SecondaryTabCorrectionsPanel;
    % add in correct order
    h.DetermineGammaLifetimeThreeColorButton.Parent = h.CorrectionsButtonsContainer;
    h.ApplyCorrectionsButton.Parent = h.CorrectionsButtonsContainer;
    h.UseBetaCheckbox.Parent = h.CorrectionsButtonsContainer;
    
    h.FoersterRadiusText.String = 'Foerster Radius GR [A]';
    h.LinkerLengthText.String = 'Linker Length GR [A]';
    h.FoersterRadiusBGEdit.Visible = 'on';
    h.FoersterRadiusBGText.Visible = 'on';
    h.FoersterRadiusBREdit.Visible = 'on';
    h.FoersterRadiusBRText.Visible = 'on';
    h.LinkerLengthBGEdit.Visible = 'on';
    h.LinkerLengthBGText.Visible = 'on';
    h.LinkerLengthBREdit.Visible = 'on';
    h.LinkerLengthBRText.Visible = 'on';
    h.DonorLifetimeBlueText.Visible = 'on';
    h.DonorLifetimeBlueEdit.Visible = 'on';
    h.r0Green_text.String = 'r0 Green';
    h.r0Red_text.String = 'r0 Red';
    h.r0Blue_edit.Visible = 'on';
    h.r0Blue_text.Visible = 'on';
    %% Change Lifetime GUI
    %%% Make 3C-Plots visible
    h.axes_E_BtoGRvsTauBB.Parent = h.LifetimePanelAll;
    h.axes_rBBvsTauBB.Parent = h.LifetimePanelAll;
    %%% Change Position of 2Color-Plots
    h.axes_EvsTauGG.Position = [0.05 0.57 (0.8/3) 0.4];
    h.axes_EvsTauRR.Position = [(0.1+0.8/3)+0.0125 0.57 (0.8/3) 0.4];
    h.axes_rGGvsTauGG.Position = [0.05 0.07 (0.8/3) 0.4];
    h.axes_rRRvsTauRR.Position = [(0.1+0.8/3)+0.0125 0.07 (0.8/3) 0.4];
    
    %%% Change axes in lifetime tab
    h.axes_EvsTauGG.YLabel.String = 'FRET Efficiency GR';
    h.axes_EvsTauGG.XLabel.String = '\tau_{GG} [ns]';
    h.axes_EvsTauGG.Title.String = 'FRET Efficiency GR vs. Lifetime GG';
    h.axes_EvsTauGG.Title.Color = UserValues.Look.Fore;
    h.axes_EvsTauRR.YLabel.String = 'FRET Efficiency GR';
    h.axes_EvsTauRR.XLabel.String = '\tau_{RR} [ns]';
    h.axes_EvsTauRR.Title.String = 'FRET Efficiency GR vs. Lifetime RR';
    h.axes_EvsTauRR.Title.Color = UserValues.Look.Fore;
    h.axes_rGGvsTauGG.XLabel.String = '\tau_{GG} [ns]';
    h.axes_rGGvsTauGG.YLabel.String = 'r_{GG}';
    h.axes_rGGvsTauGG.YLabel.Position= [-0.12, 0.5, 0];
    h.axes_rGGvsTauGG.Title.String= 'Anisotropy GG vs Lifetime GG';
    h.axes_rRRvsTauRR.XLabel.String = '\tau_{RR} [ns]';
    h.axes_rRRvsTauRR.YLabel.String = 'r_{RR}';
    h.axes_rRRvsTauRR.YLabel.Position= [-0.12, 0.5, 0];
    h.axes_rRRvsTauRR.Title.String= 'Anisotropy RR vs Lifetime RR';
    %%% Unhide TauBB Export Option
    h.ExportEvsTauBB_Menu.Visible = 'on';
    %%% Update Popupmenu in LifetimeInd Tab
    h.lifetime_ind_popupmenu.String = {'E vs tauGG', 'E vs tauRR', 'E(B->G+R) vs tauBB',...
        'rGG vs tauGG','rRR vs tauRR','rBB vs tauBB'};
    %% Change Correlation Table
    Names = {'BB1','BB2','BG1','BG2','BR1','BR2','GG1','GG2','GR1','GR2','RR1','RR2','BX1','BX2','GX1','GX2','BB','BG','BR','GG','GR','RR','BX','GX'};
    h.Correlation_Table.RowName = Names;
    h.Correlation_Table.ColumnName = Names;
    h.Correlation_Table.Data = logical(zeros(numel(Names)));
    h.Secondary_Tab_Correlation_Standard2CMFD_Menu.Visible = 'off';
    %% Change CutDatabase
    %%% Update string if cuts have been stores
    if ~isempty(fieldnames(UserValues.BurstBrowser.CutDatabase{2}))
        h.CutDatabase.String = fieldnames(UserValues.BurstBrowser.CutDatabase{2});
    else
        h.CutDatabase.String = {'-'};
    end
elseif BAMethod == 2
    %%% move the three-color Corrections Tab to the Hide_Tab
    h.Main_Tab_Corrections_ThreeCMFD.Parent = h.Hide_Tab;
    %%% reset Corrections Table
    Corrections_Rownames = {'<html><b>&gamma</b></html>','<html><b>&beta</b></html>',...
        '<html><b>crosstalk</b></html>','<html><b>direct exc.</b></html>',...
        '<html><b>G(D)</b></html>','<html><b>G(A)</b></html>',...
        '<html><b>l1</b></html>','<html><b>l2</b></html>',...
        '<html><b>BG DD par</b></html>','<html><b>BG DD perp</b></html>','<html><b>BG DA par</b></html>',...
        '<html><b>BG DA perp</b></html>','<html><b>BG AA par</b></html>','<html><b>BG AA perp</b></html>'}';
    Corrections_Data = {1;1;0;0;1;1;0;0;0;0;0;0;0;0};
    %%% Hide 3cMFD corrections
    %h.ExportSpeciesToPDA_2C_for3CMFD_MenuItem.Visible = 'off';
    h.DetermineGammaLifetimeThreeColorButton.Visible = 'off';
    h.DetermineGammaLifetimeThreeColorButton.Parent = h.SecondaryTabCorrectionsPanel;
    h.FoersterRadiusText.String = 'Foerster Radius [A]';
    h.LinkerLengthText.String = 'Linker Length [A]';
    h.FoersterRadiusBGEdit.Visible = 'off';
    h.FoersterRadiusBGText.Visible = 'off';
    h.FoersterRadiusBREdit.Visible = 'off';
    h.FoersterRadiusBRText.Visible = 'off';
    h.LinkerLengthBGEdit.Visible = 'off';
    h.LinkerLengthBGText.Visible = 'off';
    h.LinkerLengthBREdit.Visible = 'off';
    h.LinkerLengthBRText.Visible = 'off';
    h.DonorLifetimeBlueText.Visible = 'off';
    h.DonorLifetimeBlueEdit.Visible = 'off';
    h.r0Green_text.String = 'r0 Donor';
    h.r0Red_text.String = 'r0 Acceptor';
    h.r0Blue_edit.Visible = 'off';
    h.r0Blue_text.Visible = 'off';
    %%% Reset Lifetime Plots
    %%% Make 3C-Plots invisible
    h.axes_E_BtoGRvsTauBB.Parent = h.Hide_Stuff;
    h.axes_rBBvsTauBB.Parent =  h.Hide_Stuff;
    %%% Change Position of 2Color-Plots
    h.axes_EvsTauGG.Position = [0.075 0.57 0.4 0.4];
    h.axes_EvsTauRR.Position = [0.575 0.57 0.4 0.4];
    h.axes_rGGvsTauGG.Position = [0.075 0.07 0.4 0.4];
    h.axes_rRRvsTauRR.Position = [0.575 0.07 0.4 0.4];
    
    %%% Change axes in lifetime tab
    h.axes_EvsTauGG.YLabel.String = 'FRET Efficiency';
    h.axes_EvsTauGG.XLabel.String = '\tau_{D(A)} [ns]';
    h.axes_EvsTauGG.Title.String = 'FRET Efficiency vs. Lifetime D';
    h.axes_EvsTauGG.Title.Color = UserValues.Look.Fore;
    h.axes_EvsTauRR.YLabel.String = 'FRET Efficiency';
    h.axes_EvsTauGG.XLabel.String = '\tau_{D(A)} [ns]';
    h.axes_EvsTauRR.Title.String = 'FRET Efficiency vs. Lifetime A';
    h.axes_EvsTauRR.Title.Color = UserValues.Look.Fore;
    h.axes_rGGvsTauGG.XLabel.String = '\tau_{D(A)} [ns]';
    h.axes_rGGvsTauGG.YLabel.String = 'r_{D}';
    h.axes_rGGvsTauGG.YLabel.Position= [-0.125, 0.5, 0];
    h.axes_rGGvsTauGG.Title.String= 'Anisotropy D vs Lifetime D';
    h.axes_rRRvsTauRR.XLabel.String = '\tau_{A} [ns]';
    h.axes_rRRvsTauRR.YLabel.String = 'r_{A}';
    h.axes_rRRvsTauRR.YLabel.Position= [-0.125, 0.5, 0];
    h.axes_rRRvsTauRR.Title.String= 'Anisotropy A vs Lifetime A';
    %%% Hide TauBB Export Option
    h.ExportEvsTauBB_Menu.Visible = 'off';
    %% Change Correlation Table
    Names = {'DD1','DD2','DA1','DA2','AA1','AA2','DD','DA','DX','DX1','DX2','AA'};
    h.Correlation_Table.RowName = Names;
    h.Correlation_Table.ColumnName = Names;
    h.Correlation_Table.Data = logical(zeros(numel(Names)));
    h.Secondary_Tab_Correlation_Standard2CMFD_Menu.Visible = 'on';
    %% lifetime ind
    h.lifetime_ind_popupmenu.String = {'<html>E vs &tau;<sub>D(A)</sub></html>','<html>E vs &tau;<sub>A</sub></html>','<html>r<sub>D</sub> vs &tau;<sub>D(A)</sub></html>','<html>r<sub>A</sub> vs &tau;<sub>A</sub></html>'};
    %% Change CutDatabase
    %%% Update string if cuts have been stores
    if ~isempty(fieldnames(UserValues.BurstBrowser.CutDatabase{1}))
        h.CutDatabase.String = fieldnames(UserValues.BurstBrowser.CutDatabase{1});
    else
        h.CutDatabase.String = {'-'};
    end
end
%h.CorrectionsTable.RowName = Corrections_Rownames;
h.CorrectionsTable.Data = horzcat(Corrections_Rownames,Corrections_Data);
%%% Update CorrectionsTable with UserValues-stored Data
UpdateCorrections([],[],h)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export Graphs to PNG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hfig, FigureName] = ExportGraphs(obj,~,ask_file)
global BurstData UserValues BurstMeta
file = BurstMeta.SelectedFile;
if nargin < 3
    ask_file = 1;
end
h = guidata(obj);
fontsize = 20;
if ispc
    fontsize = fontsize/1.3;
end

size_pixels = 500;
switch obj
    case h.Export1DX_Menu
        %%% Create a new figure with aspect ratio appropiate for the current plot
        %%% i.e. 1.2*[x y]
        AspectRatio = 0.7;
        pos = [100,100, round(1.2*size_pixels),round(1.2*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1],'Visible','on');
        %%% Copy axes to figure
        axes_copy = copyobj(h.axes_1d_x,hfig);
        %%% Rescale Position
        axes_copy.Position = [0.15 0.19 0.8 0.78];
        %%% Increase fontsize
        axes_copy.FontSize = fontsize;
        %%% change Background Color
        axes_copy.Color = [1,1,1];
        %%% change X/YColor Color Color
        axes_copy.XColor = [0,0,0];
        axes_copy.YColor = [0,0,0];
        axes_copy.XLabel.Color = [0,0,0];
        axes_copy.YLabel.Color = [0,0,0];
        %%% Reset XAxis Location
        axes_copy.XAxisLocation = 'bottom';
        %%% Make Ticks point Outwards
        axes_copy.TickDir = 'out';
        %%% Disable Box
        axes_copy.Box = 'off';
        %%% Change FaceColor of BarPlot
        %axes_copy.Children(end-1).FaceColor = [0.5 0.5 0.5];
        %axes_copy.Children(4).LineWidth = 1;
        %%% Redo YAxis Label
        axes_copy.YTickMode = 'auto';
        %%% Set XLabel
        xlabel(BurstData{file}.NameArray{h.ParameterListX.Value},'FontSize',fontsize);
        ylabel('Frequency','FontSize',fontsize);
        axes_copy.XTickLabelMode = 'auto';
        %%% Construct Name
        FigureName = BurstData{file}.NameArray{h.ParameterListX.Value};
        %%%remove text
        del = false(numel(axes_copy.Children),1);
        for i = 1:numel(axes_copy.Children)
            if strcmp(axes_copy.Children(i).Type,'text')
                del(i) = true;
            end
        end
        delete(axes_copy.Children(del));
        if (h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1)
            %%% Multiplot is used (first stair plot is visible)
            %%% delete all invisible plots
            del = false(numel(axes_copy.Children),1);
            for i = 1:numel(axes_copy.Children);
                if strcmp(axes_copy.Children(i).Visible, 'off')
                    del(i) = true;
                end
            end
            delete(axes_copy.Children(del));
            if numel(axes_copy.Children)>1
                if ~isempty(h.axes_1d_x.Legend)
                    hl = legend(h.axes_1d_x.Legend.String);
                    hl.Box = 'off';
                    hfig.Units = 'pixel';
                    axes_copy.Units = 'pixel';
                    hl.Units = 'pixel';
                    hl.FontSize = 12;
                    hfig.Position(4) = hfig.Position(4) + 75;
                    hl.Position(2) =  hl.Position(2)+75;                
                    hl.Position(1) = 40;
                end
            end
        end
    case h.Export1DY_Menu
        AspectRatio = 0.7;
        pos = [100,100, round(1.2*size_pixels),round(1.2*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1],'Visible','on');
        %%% Copy axes to figure
        axes_copy = copyobj(h.axes_1d_y,hfig);
        %%% flip axes
        axes_copy.View = [0,90];
        %%% Reverse XDir
        axes_copy.XDir = 'normal';
        %%% Rescale Position
        axes_copy.Position = [0.15 0.19 0.8 0.78];
        %%% Increase fontsize
        axes_copy.FontSize = fontsize;
        %%% change Background Color
        axes_copy.Color = [1,1,1];
        %%% change X/YColor Color Color
        axes_copy.XColor = [0,0,0];
        axes_copy.YColor = [0,0,0];
        axes_copy.XLabel.Color = [0,0,0];
        axes_copy.YLabel.Color = [0,0,0];
        %%% Reset XAxis Location
        axes_copy.XAxisLocation = 'bottom';
        %%% Make Ticks point Outwards
        axes_copy.TickDir = 'out';
        %%% Disable Box
        axes_copy.Box = 'off';
        %%% Change FaceColor of BarPlot
        %axes_copy.Children(4).FaceColor = [0.5 0.5 0.5];
        %axes_copy.Children(4).LineWidth = 3;
        %%% Redo YAxis Label
        axes_copy.YTickMode = 'auto';
        %%% Set XLabel
        xlabel(BurstData{file}.NameArray{h.ParameterListY.Value},'FontSize',fontsize);
        ylabel('Frequency','FontSize',fontsize);
        axes_copy.XTickLabelMode = 'auto';
        %%% Construct Name
        FigureName = BurstData{file}.NameArray{h.ParameterListY.Value};
        %%%remove text
        del = false(numel(axes_copy.Children),1);
        for i = 1:numel(axes_copy.Children)
            if strcmp(axes_copy.Children(i).Type,'text')
                del(i) = true;
            end
        end
        delete(axes_copy.Children(del));
        if (h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1)
            %%% Multiplot is used (first stair plot is visible)
            %%% delete all invisible plots
            del = false(numel(axes_copy.Children),1);
            for i = 1:numel(axes_copy.Children);
                if strcmp(axes_copy.Children(i).Visible, 'off')
                    del(i) = true;
                end
            end
            delete(axes_copy.Children(del));
            if numel(axes_copy.Children)>1
                if ~isempty(h.axes_1d_x.Legend)
                    hl = legend(h.axes_1d_x.Legend.String);
                    hl.Box = 'off';
                    hfig.Units = 'pixel';
                    axes_copy.Units = 'pixel';
                    hl.Units = 'pixel';
                    hl.FontSize = 12;
                    hfig.Position(4) = hfig.Position(4) + 75;
                    hl.Position(2) =  hl.Position(2)+75;                
                    hl.Position(1) = 40;
                end
            end
        end
    case h.Export2D_Menu
        AspectRatio = 1;
        pos = [100,100, round(1.3*size_pixels),round(1.2*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1],'Visible','on');
        %%% Copy axes to figure
        panel_copy = copyobj(h.MainTabGeneralPanel,hfig);
        panel_copy.ShadowColor = [1 1 1];
        %%% set Background Color to white
        panel_copy.BackgroundColor = [1 1 1];
        panel_copy.HighlightColor = [1 1 1];
        %%% Update ColorMap
        if ischar(UserValues.BurstBrowser.Display.ColorMap)
            eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);
        else
            colormap(UserValues.BurstBrowser.Display.ColorMap);
        end
        if UserValues.BurstBrowser.Display.ColorMapInvert
            colormap(h.BurstBrowser,flipud(colormap));
        end
        %%% Remove non-axes object
        del = zeros(numel(panel_copy.Children),1);
        for i = 1:numel(panel_copy.Children)
            if ~strcmp(panel_copy.Children(i).Type,'axes')
                if ~strcmp(panel_copy.Children(i).Type,'legend')
                    del(i) = 1;
                end
            end
        end
        delete(panel_copy.Children(logical(del)));
        
        for i = 1:numel(panel_copy.Children)
            if strcmp(panel_copy.Children(i).Type,'legend')
                continue;
            end
            %%% Set the Color of Axes to white
            panel_copy.Children(i).Color = [1 1 1];
            %%% change X/YColor Color Color
            panel_copy.Children(i).XColor = [0,0,0];
            panel_copy.Children(i).YColor = [0,0,0];
            %%% Increase FontSize
            panel_copy.Children(i).FontSize = fontsize;
            %panel_copy.Children(i).Layer = 'bottom'; %put the grid lines (axis) below the plot
            %%% Reorganize Axes Positions
            switch panel_copy.Children(i).Tag
                case 'Axes_1D_Y'
                    panel_copy.Children(i).Position = [0.77 0.135 0.15 0.65];
                    panel_copy.Children(i).YTickLabelRotation = 270;
                    lim = 0;
                    for j = 1:numel(panel_copy.Children(i).Children)
                        if strcmp(panel_copy.Children(i).Children(j).Type,'text')
                            delete(panel_copy.Children(i).Children(j));
                            continue;
                        end
                        if strcmp(panel_copy.Children(i).Children(j).Visible,'on')
                            lim = max([lim,max(panel_copy.Children(i).Children(j).YData)*1.05]);
                        end
                    end
                    set(panel_copy.Children(i),'YTickLabelRotation',0);
                    panel_copy.Children(i).YLim = [0, lim];
                    panel_copy.Children(i).YTickMode = 'auto';
                    panel_copy.Children(i).YTickLabel = [];
                    panel_copy.Children(i).YLabel.String = '';
                    panel_copy.Children(i).YGrid = 'off';
                    panel_copy.Children(i).XGrid = 'off';
                    panel_copy.Children(i).Layer = 'top';
                    %yticks = get(panel_copy.Children(i),'YTick');
                    %set(panel_copy.Children(i),'YTick',yticks(2:end));
                    % change the grayscale of the bars and remove the line
                    if strcmp(panel_copy.Children(i).Children(9).Type,'bar')
                        panel_copy.Children(i).Children(9).FaceColor = [0.7 0.7 0.7];
                        panel_copy.Children(i).Children(9).LineStyle = 'none';
                    end
                case 'Axes_1D_X'
                    panel_copy.Children(i).Position = [0.12 0.785 0.65 0.15];
                    xlabel(panel_copy.Children(i),'');
                    lim = 0;
                    for j = 1:numel(panel_copy.Children(i).Children)
                        if strcmp(panel_copy.Children(i).Children(j).Type,'text')
                            delete(panel_copy.Children(i).Children(j));
                            continue;
                        end
                        if strcmp(panel_copy.Children(i).Children(j).Visible,'on')
                            lim = max([lim,max(panel_copy.Children(i).Children(j).YData)*1.05]);
                        end
                    end
                    panel_copy.Children(i).YLim = [0, lim];
                    panel_copy.Children(i).YTickMode = 'auto';
                    panel_copy.Children(i).YTickLabel = [];
                    panel_copy.Children(i).YLabel.String = '';
                    panel_copy.Children(i).YGrid = 'off';
                    panel_copy.Children(i).XGrid = 'off';
                    panel_copy.Children(i).Layer = 'top';
                    %yticks = get(panel_copy.Children(i),'YTick');
                    %set(panel_copy.Children(i),'YTick',yticks(2:end));
                    panel_copy.Children(i).XTickLabelMode = 'auto';
                    % change the grayscale of the bars and remove the line
                    if strcmp(panel_copy.Children(i).Children(9).Type,'bar')
                        panel_copy.Children(i).Children(9).FaceColor = [0.7 0.7 0.7];
                        panel_copy.Children(i).Children(9).LineStyle = 'none';
                    end
                    ax1dx = i;
                case 'Axes_General'
                    panel_copy.Children(i).Position = [0.12 0.135 0.65 0.65];
                    panel_copy.Children(i).XLabel.Color = [0 0 0];
                    panel_copy.Children(i).YLabel.Color = [0 0 0];
                    ax2d = i;
                case 'axes_ZScale'
                    if strcmp(panel_copy.Children(i).Visible,'on')
                        panel_copy.Children(i).Position = [0.77,0.785,0.15,0.13];
                    end
                    panel_copy.Children(i).YGrid = 'off';
            end
        end
        
        %%% Update Colorbar by plotting it anew
        %%% multiplot is NOT used
        if any(cell2mat(h.CutTable.Data(:,6))) && ~(h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1)  %%% colored by parameter
            cbar = colorbar(panel_copy.Children(4),'Location','north','Color',[0 0 0],'FontSize',fontsize-8); 
            %panel_copy.Children(3).XTickLabel(end) = {' '};
            param = h.CutTable.Data{cell2mat(h.CutTable.Data(:,6)),1};
            param = param(23:end-18); %%% remove html string
            cbar.Position = [0.77,0.915,0.15,0.02];
            cbar.AxisLocation = 'out';
            cbar.Label.String = 'Occurrence';
            cbar.Label.Units = 'normalized';
            cbar.Label.Position = [0.5,2.85,0];
            cbar.Label.String = param;
            cbar.Ticks = [cbar.Limits(1), cbar.Limits(1) + 0.5*(cbar.Limits(2)-cbar.Limits(1)),cbar.Limits(2)];
            zlim = [h.CutTable.Data{cell2mat(h.CutTable.Data(:,6)),2} h.CutTable.Data{cell2mat(h.CutTable.Data(:,6)),3}];
            cbar.TickLabels = {sprintf('%.1f',(zlim(1)));sprintf('%.1f',zlim(1)+(zlim(2)-zlim(1))/2);sprintf('%.1f',zlim(2))};
            if (panel_copy.Children(3).XLim(2) - panel_copy.Children(3).XTick(end))/(panel_copy.Children(3).XLim(2)-panel_copy.Children(3).XLim(1)) < 0.05 %%% Last XTick Label is at the end of the axis and thus overlaps with colorbar
                panel_copy.Children(3).XTickLabel{end} = '';
            end
        elseif ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter') %%% only occurence
            for n = 1:numel(panel_copy.Children)
                if strcmp(panel_copy.Children(n).Tag,'Axes_General')
                    ax2d = n;
                elseif strcmp(panel_copy.Children(n).Tag,'Axes_1D_X')
                    ax1dx = n;
                end
            end
            panel_copy.Children(ax1dx).XTickLabel = panel_copy.Children(ax2d).XTickLabel; 
            % for some strange reason, the below colorbar will be part of panel_copy.Children, before the Axes_General 
            cbar = colorbar('peer', panel_copy.Children(ax2d),'Location','north','Color',[0 0 0],'FontSize',fontsize-6); 
            cbar.Position = [0.8,0.85,0.18,0.025];
            cbar.Label.String = 'Occurrence';
            cbar.Limits(1) = 0;
            cbar.TicksMode = 'auto';
            cbar.TickLabelsMode = 'auto';
        end
        for n = 1:numel(panel_copy.Children)
            if strcmp(panel_copy.Children(n).Tag,'Axes_1D_X')
                ax1dx = n;
            end
        end
        if (h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1)
            %%% (if multi plot is used, first stair plot is visible)
            %%% if multiplot, extend figure and shift legend upstairs
            %%% delete the zscale axis
            for i = 1:numel(hfig.Children(end).Children)
                if strcmp(hfig.Children(end).Children(i).Tag,'axes_ZScale')
                    del = i;
                end
            end
            delete(hfig.Children(end).Children(del));
            %%% Set all units to pixels for easy editing without resizing
            hfig.Units = 'pixels';
            panel_copy.Units = 'pixels';
            for i = 1:numel(panel_copy.Children)
                if isprop(panel_copy.Children(i),'Units');
                    panel_copy.Children(i).Units = 'pixels';
                end
            end
            %%% refind legend item
            leg = [];
            for i = 1:numel(panel_copy.Children)
                if strcmp(panel_copy.Children(i).Type,'legend')
                    leg = i;
                end
            end
            if ~isempty(leg)
                if strcmp(panel_copy.Children(leg).Visible,'on')
                    hfig.Position(4) = 650;
                    panel_copy.Position(4) = 650;
                    panel_copy.Children(leg).Position(1) = 40;
                    panel_copy.Children(leg).Position(2) = 590;
                end
            end
            %%% hide colorbar if it exists
            if exist('cbar','var')
                %cbar.Visible = 'off';
            end
        end
        if UserValues.BurstBrowser.Display.ColorMapInvert
            colormap(flipud(colormap));
        end
        %%% check if occurrence scale in BurstBrowser is visible
        if strcmp(h.colorbar.Visible,'off')
            cbar.Visible = 'off';
        end
        if ~UserValues.BurstBrowser.Display.PlotGridAboveData
            %%% create dummy axis to prevent data overlapping the axis
            ax2d = findobj(panel_copy.Children,'Tag','Axes_General');
            ax_dummy = axes('Parent',panel_copy,'Units',ax2d.Units,'Position',ax2d.Position);
            %linkaxes([ax2d ax_dummy]);
            set(ax_dummy,'Color','none','XTick',ax2d.XTick,'YTick',ax2d.YTick,'XTickLAbel',[],'YTickLabel',[],...
                'LineWidth',1,'Box','on','XLim',ax2d.XLim, 'YLim', ax2d.YLim);
        end
        FigureName = [BurstData{file}.NameArray{h.ParameterListX.Value} '_' BurstData{file}.NameArray{h.ParameterListY.Value}];
    case h.ExportLifetime_Menu
        fontsize = 20;
        if ispc
            fontsize = fontsize/1.3;
        end
        AspectRatio = 1;
        pos = [100,100, round(1.6*size_pixels),round(1.6*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1]);
        %%% Copy axes to figure
        panel_copy = copyobj(h.LifetimePanelAll,hfig);
        panel_copy.ShadowColor = [1 1 1];
        panel_copy.HighlightColor = [1 1 1];
        %%% set Background Color to white
        panel_copy.BackgroundColor = [1 1 1];
        %%% Update ColorMap
        if ischar(UserValues.BurstBrowser.Display.ColorMap)
            eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);
        else
            colormap(UserValues.BurstBrowser.Display.ColorMap);
        end
        if any(BurstData{file}.BAMethod == [1,2,5])
            for i = 1:numel(panel_copy.Children)
                %%% Set the Color of Axes to white
                panel_copy.Children(i).Color = [1 1 1];
                %%% change X/YColor Color Color
                panel_copy.Children(i).XColor = [0,0,0];
                panel_copy.Children(i).YColor = [0,0,0];
                panel_copy.Children(i).XLabel.Color = [0,0,0];
                panel_copy.Children(i).YLabel.Color = [0,0,0];
                %%% Increase FontSize
                panel_copy.Children(i).FontSize = fontsize;
                %%% Make Bold
                %panel_copy.Children(i).FontWeight = 'bold';
                %%% disable titles
                title(panel_copy.Children(i),'');
                %panel_copy.Children(i).Layer = 'bottom';
                %%% move axes up and left
                panel_copy.Children(i).Position = panel_copy.Children(i).Position + [0.01 0.02 0 0];
                if any(i==[1,2])
                    panel_copy.Children(i).YLabel.Units = 'normalized';
                    panel_copy.Children(i).YLabel.Position = [-0.16 0.5 0];
                end
                %%% Add rotational correlation time
                if isfield(BurstData{file},'Parameters')
                    switch i
                        case 1
                            %%%rRR vs TauRR
                            if isfield(BurstData{file}.Parameters,'rhoRR')
                                if ~isempty(BurstData{file}.Parameters.rhoRR)
                                    str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoRR(1))];
                                    if numel(BurstData{file}.Parameters.rhoRR) > 1
                                        str = {[str(1:4) '_1' str(5:end)]};
                                        for j=2:numel(BurstData{file}.Parameters.rhoRR)
                                            str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoRR(j))];
                                        end
                                    end
                                end
                            end
                            text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                            %'BackgroundColor',[1 1 1],...
                            %'EdgeColor',[0 0 0]);
                        case 2
                            %%%rGG vs TauGG
                            if isfield(BurstData{file}.Parameters,'rhoGG')
                                if ~isempty(BurstData{file}.Parameters.rhoGG)
                                    str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoGG(1))];
                                    if numel(BurstData{file}.Parameters.rhoGG) > 1
                                        str = {[str(1:4) '_1' str(5:end)]};
                                        for j=2:numel(BurstData{file}.Parameters.rhoGG)
                                            str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoGG(j))];
                                        end
                                    end
                                end
                            end
                            text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                            %'BackgroundColor',[1 1 1],...
                            %'EdgeColor',[0 0 0]);
                    end
                end
            end
        elseif any(BurstData{file}.BAMethod == [3,4])
            hfig.Position(3) = hfig.Position(3)*1.55;
            %hfig.Position(4) = hfig.Position(3)*1.1;
            
            for i = 1:numel(panel_copy.Children)
                %%% Set the Color of Axes to white
                panel_copy.Children(i).Color = [1 1 1];
                %%% Move axis to top of stack
                %panel_copy.Children(i).Layer = 'bottom';
                %%% change X/YColor Color Color
                panel_copy.Children(i).XColor = [0,0,0];
                panel_copy.Children(i).YColor = [0,0,0];
                panel_copy.Children(i).XLabel.Color = [0,0,0];
                panel_copy.Children(i).YLabel.Color = [0,0,0];
                %%% Increase FontSize
                panel_copy.Children(i).FontSize = fontsize;
                %%% Make Bold
                %panel_copy.Children(i).FontWeight = 'bold';
                %%% disable titles
                title(panel_copy.Children(i),'');
                %%% move axes up and left
                panel_copy.Children(i).Position = panel_copy.Children(i).Position + [0.01 0.02 0 0];
                if any(i==[1,3,4])
                    panel_copy.Children(i).YLabel.Units = 'normalized';
                    panel_copy.Children(i).YLabel.Position = [-0.16 0.5 0];
                end
                %%% Add rotational correlation time
                if isfield(BurstData{file},'Parameters')
                    switch i
                        case 1
                            %%%rBB vs TauBB
                            if isfield(BurstData{file}.Parameters,'rhoBB')
                                if ~isempty(BurstData{file}.Parameters.rhoBB)
                                    str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoBB(1))];
                                    if numel(BurstData{file}.Parameters.rhoBB) > 1
                                        str = {[str(1:4) '_1' str(5:end)]};
                                        for j=2:numel(BurstData{file}.Parameters.rhoBB)
                                            str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoBB(j))];
                                        end
                                    end
                                end
                            end
                            text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                            %'BackgroundColor',[1 1 1],...
                            %'EdgeColor',[0 0 0]);
                        case 3
                            %%%rRR vs TauRR
                            if isfield(BurstData{file}.Parameters,'rhoRR')
                                if ~isempty(BurstData{file}.Parameters.rhoRR)
                                    str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoRR(1))];
                                    if numel(BurstData{file}.Parameters.rhoRR) > 1
                                        str = {[str(1:4) '_1' str(5:end)]};
                                        for j=2:numel(BurstData{file}.Parameters.rhoRR)
                                            str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoRR(j))];
                                        end
                                    end
                                end
                            end
                            text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                            %'BackgroundColor',[1 1 1],...
                            %'EdgeColor',[0 0 0]);
                        case 4
                            %%%rGG vs TauGG
                            if isfield(BurstData{file}.Parameters,'rhoGG')
                                if ~isempty(BurstData{file}.Parameters.rhoGG)
                                    str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoGG(1))];
                                    if numel(BurstData{file}.Parameters.rhoGG) > 1
                                        str = {[str(1:4) '_1' str(5:end)]};
                                        for j=2:numel(BurstData{file}.Parameters.rhoGG)
                                            str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoGG(j))];
                                        end
                                    end
                                end
                            end
                            text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                            %'BackgroundColor',[1 1 1],...
                            %'EdgeColor',[0 0 0]);
                    end
                end
            end
        end
        FigureName = 'LifetimePlots';
%     case h.ExportEvsTau_Menu
%         AspectRatio = 1;
%         pos = [100,100, round(1.2*0.5*size_pixels),round(1.2*0.5*size_pixels*AspectRatio)];
%         hfig = figure('Position',pos,'Color',[1 1 1]);
%         %%% Copy axes to figure
%         axes_copy = copyobj(h.axes_EvsTauGG,hfig);
%         axes_copy.Position = [0.17 0.17 0.8 0.8];
%         axes_copy.Title.Visible = 'off';
%         axes_copy.XLabel.String = '\tau_{D(A)} [ns]';
%         %%% set Background Color to white
%         axes_copy.Color = [1 1 1];
%         %%% change X/YColor Color Color
%         axes_copy.XColor = [0,0,0];
%         axes_copy.YColor = [0,0,0];
%         axes_copy.XLabel.Color = [0,0,0];
%         axes_copy.YLabel.Color = [0,0,0];
%         axes_copy.Layer = 'top';
%         %%% Update ColorMap
%         if ischar(UserValues.BurstBrowser.Display.ColorMap)
%             eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);
%         else
%             colormap(UserValues.BurstBrowser.Display.ColorMap);
%         end
%         FigureName = 'E vs. TauGG';
%         axes_copy.Layer = 'top';
%     case h.ExportEvsTauBB_Menu
%         AspectRatio = 1;
%         pos = [100,100, round(1.2*0.5*size_pixels),round(1.2*0.5*size_pixels*AspectRatio)];
%         hfig = figure('Position',pos,'Color',[1 1 1]);
%         %%% Copy axes to figure
%         axes_copy = copyobj(h.axes_E_BtoGRvsTauBB,hfig);
%         axes_copy.Position = [0.17 0.17 0.8 0.8];
%         axes_copy.Title.Visible = 'off';
%         %%% set Background Color to white
%         axes_copy.Color = [1 1 1];
%         %%% change X/YColor Color Color
%         axes_copy.XColor = [0,0,0];
%         axes_copy.YColor = [0,0,0];
%         axes_copy.XLabel.Color = [0,0,0];
%         axes_copy.YLabel.Color = [0,0,0];
%         axes_copy.Layer = 'top';
%         %%% Update ColorMap
%         if ischar(UserValues.BurstBrowser.Display.ColorMap)
%             eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);
%         else
%             colormap(UserValues.BurstBrowser.Display.ColorMap);
%         end
%         FigureName = 'E vs. TauBB';
    case h.Export2DLifetime_Menu
        AspectRatio = 1;
        pos = [100,100, round(1.3*size_pixels),round(1.2*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1],'Visible','on');
        %%% Copy axes to figure
        panel_copy = copyobj(h.LifetimePanelInd,hfig);
        panel_copy.ShadowColor = [1 1 1];
        %%% set Background Color to white
        panel_copy.BackgroundColor = [1 1 1];
        panel_copy.HighlightColor = [1 1 1];
        
        color_bar = true;
        
        %%% Update ColorMap
        if ischar(UserValues.BurstBrowser.Display.ColorMap)
            eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);
        else
            colormap(UserValues.BurstBrowser.Display.ColorMap);
        end
        if UserValues.BurstBrowser.Display.ColorMapInvert
            colormap(h.BurstBrowser,flipud(colormap));
        end
        %%% Remove non-axes object
        del = zeros(numel(panel_copy.Children),1);
        for i = 1:numel(panel_copy.Children)
            if ~strcmp(panel_copy.Children(i).Type,'axes')
                if ~strcmp(panel_copy.Children(i).Type,'legend')
                    del(i) = 1;
                end
            end
        end
        delete(panel_copy.Children(logical(del)));
        for i = 1:numel(panel_copy.Children)
            if strcmp(panel_copy.Children(i).Type,'legend')
                continue;
            end
            %%% Set the Color of Axes to white
            panel_copy.Children(i).Color = [1 1 1];
            %%% change X/YColor Color Color
            panel_copy.Children(i).XColor = [0,0,0];
            panel_copy.Children(i).YColor = [0,0,0];
            %%% Increase FontSize
            panel_copy.Children(i).FontSize = fontsize;
            %panel_copy.Children(i).Layer = 'bottom';
            
            %%% Reorganize Axes Positions
            switch panel_copy.Children(i).Tag
                case 'axes_lifetime_ind_1d_y'
                    panel_copy.Children(i).Position = [0.77 0.135 0.15 0.65];
                    panel_copy.Children(i).YTickLabelRotation = 270;
                    if numel(panel_copy.Children(i).Children) == 1 %%% no multiplot
                        panel_copy.Children(i).YLim = [0, max(panel_copy.Children(i).Children(1).YData)*1.05];
                    else
                        if all(panel_copy.Children(i).Children(1).Color == [0,0,0]) %%% overlayed plot, not multiplot
                            panel_copy.Children(i).YLim = [0, max(panel_copy.Children(i).Children(1).YData)*1.05];
                        else
                             maxY = 0;
                             for k = 1:numel(panel_copy.Children(i).Children)-1
                                 maxY = max([maxY,max(panel_copy.Children(i).Children(k).YData)]);
                             end
                             panel_copy.Children(i).YLim = [0, maxY*1.05];
                             color_bar = false;
                        end
                    end
                    panel_copy.Children(i).YTickLabel = [];
                    panel_copy.Children(i).YLabel.String = '';
                    panel_copy.Children(i).YGrid = 'off';
                    panel_copy.Children(i).XGrid = 'off';
                    panel_copy.Children(i).Layer = 'top';
                    % change the grayscale of the bars and remove the line
                    for k = 1:numel(panel_copy.Children(i).Children)
                        if strcmp(panel_copy.Children(i).Children(k).Type,'bar')
                            %panel_copy.Children(i).Children(k).FaceColor = [0.7 0.7 0.7];
                            panel_copy.Children(i).Children(k).LineStyle = 'none';
                        end
                    end
                case 'axes_lifetime_ind_1d_x'
                    panel_copy.Children(i).Position = [0.12 0.785 0.65 0.15];
                    xlabel(panel_copy.Children(i),'');
                    if numel(panel_copy.Children(i).Children) == 1 %%% no multiplot
                        panel_copy.Children(i).YLim = [0, max(panel_copy.Children(i).Children(1).YData)*1.05];
                    else
                        if all(panel_copy.Children(i).Children(1).Color == [0,0,0]) %%% overlayed plot, not multiplot
                            panel_copy.Children(i).YLim = [0, max(panel_copy.Children(i).Children(1).YData)*1.05];
                        else
                            maxY = 0;
                            for k = 1:numel(panel_copy.Children(i).Children)-1
                                maxY = max([maxY,max(panel_copy.Children(i).Children(k).YData)]);
                            end
                            panel_copy.Children(i).YLim = [0, maxY*1.05];
                        end
                    end
                    panel_copy.Children(i).YTickLabel = [];
                    panel_copy.Children(i).YLabel.String = '';
                    panel_copy.Children(i).YGrid = 'off';
                    panel_copy.Children(i).XGrid = 'off';
                    panel_copy.Children(i).Layer = 'top';
                    % change the grayscale of the bars and remove the line
                    for k = 1:numel(panel_copy.Children(i).Children)
                        if strcmp(panel_copy.Children(i).Children(k).Type,'bar')
                            %panel_copy.Children(i).Children(k).FaceColor = [0.7 0.7 0.7];
                            panel_copy.Children(i).Children(k).LineStyle = 'none';
                        end
                    end
                case 'axes_lifetime_ind_2d'
                    panel_copy.Children(i).Position = [0.12 0.135 0.65 0.65];
                    panel_copy.Children(i).XLabel.Color = [0 0 0];
                    panel_copy.Children(i).YLabel.Color = [0 0 0];
                    switch BurstData{file}.BAMethod
                        case {1,2}
                            switch h.lifetime_ind_popupmenu.Value
                                case {3,4} % Ansiotropy plot, adjust y axis label
                                    panel_copy.Children(i).YLabel.Position(1) =...
                                        panel_copy.Children(i).YLabel.Position(1) + 0.1;
                            end
                        case {3,4}
                            switch h.lifetime_ind_popupmenu.Value
                                case {4,5,6} % Ansiotropy plot, adjust y axis label
                                    panel_copy.Children(i).YLabel.Position(1) =...
                                        panel_copy.Children(i).YLabel.Position(1) + 0.1;
                            end
                    end
            end
        end
        if ~strcmp(UserValues.BurstBrowser.Display.PlotType,'Scatter') && color_bar
            cbar = colorbar(panel_copy.Children(find(strcmp(get(panel_copy.Children,'Tag'),'axes_lifetime_ind_2d'))),...
                'Location','north','Color',[0 0 0],'FontSize',fontsize-6); 
            cbar.Position = [0.8,0.85,0.18,0.025];
            cbar.Label.String = 'Occurrence';
            cbar.TickLabelsMode = 'auto';
            if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour')
                labels = cellfun(@str2double,cbar.TickLabels);
                %%% find maximum number of bursts
                for j = 1:numel(panel_copy.Children)
                    if strcmp(panel_copy.Children(j).Tag,'axes_lifetime_ind_2d')
                        for k=1:numel(panel_copy.Children(j).Children)
                            if strcmp(panel_copy.Children(j).Children(k).Type,'image')
                                maxZ = max(panel_copy.Children(j).Children(k).CData(:));
                            end
                        end
                    end
                end
                if maxZ > 1 %%% ensure that the plot is not normalized
                    for i = 1:numel(labels)
                        cbar.TickLabels{i} = num2str(round(labels(i)*maxZ));
                    end
                end
            end
            cbar.Units = 'pixels';drawnow;
        end
        if (h.MultiselectOnCheckbox.UserData && numel(get_multiselection(h)) > 1)
            %%% Set all units to pixels for easy editing without resizing
            hfig.Units = 'pixels';
            panel_copy.Units = 'pixels';
            for i = 1:numel(panel_copy.Children)
                if isprop(panel_copy.Children(i),'Units');
                    panel_copy.Children(i).Units = 'pixels';
                end
            end
            %%% refind legend item
            for i = 1:numel(panel_copy.Children)
                if strcmp(panel_copy.Children(i).Type,'legend')
                    leg = i;
                end
            end
            if strcmp(panel_copy.Children(leg).Visible,'on')
                hfig.Position(4) = 660;
                panel_copy.Position(4) = 660;
                panel_copy.Children(leg).Position(1) = 10;
                panel_copy.Children(leg).Position(2) = 590;
            end
        end
        if UserValues.BurstBrowser.Display.ColorMapInvert
            colormap(flipud(colormap));
        end
        if ~UserValues.BurstBrowser.Display.PlotGridAboveData
            %%% create dummy axis to prevent data overlapping the axis
            ax2d = findobj(panel_copy.Children,'Tag','axes_lifetime_ind_2d');
            ax_dummy = axes('Parent',panel_copy,'Units',ax2d.Units,'Position',ax2d.Position);
            %linkaxes([ax2d ax_dummy]);
            set(ax_dummy,'Color','none','XTick',ax2d.XTick,'YTick',ax2d.YTick,'XTickLAbel',[],'YTickLabel',[],...
                'LineWidth',1,'Box','on','XLim',ax2d.XLim, 'YLim', ax2d.YLim)
        end
        FigureName = h.lifetime_ind_popupmenu.String{h.lifetime_ind_popupmenu.Value};
        %%% remove html formatting
        origStr = {'<html>','</html>','&',';','<sub>','</sub>'}; repStr = {'','','','','',''};
        for i = 1:numel(origStr)
            FigureName = strrep(FigureName,origStr{i},repStr{i});
        end
    case h.ExportCorrections_Menu
        fontsize = 22;
        if ispc
            fontsize = fontsize/1.3;
        end
        AspectRatio = 1;
        pos = [100,100, round(1.6*size_pixels),round(1.6*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1]);
        %%% Copy axes to figure
        panel_copy = copyobj(h.MainTabCorrectionsPanel,hfig);
        panel_copy.ShadowColor = [1 1 1];
        panel_copy.HighlightColor = [1 1 1];
        %%% set Background Color to white
        panel_copy.BackgroundColor = [1 1 1];
        %%% Update ColorMap
        if ischar(UserValues.BurstBrowser.Display.ColorMap)
            eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);
        else
            colormap(UserValues.BurstBrowser.Display.ColorMap);
        end
        if any(BurstData{file}.BAMethod == [1,2,5])
            for i = 1:numel(panel_copy.Children)
                %%% Set the Color of Axes to white
                panel_copy.Children(i).Color = [1 1 1];
                %%% change X/YColor Color Color
                panel_copy.Children(i).XColor = [0,0,0];
                panel_copy.Children(i).YColor = [0,0,0];
                panel_copy.Children(i).XLabel.Color = [0,0,0];
                panel_copy.Children(i).YLabel.Color = [0,0,0];
                %%% Increase FontSize
                panel_copy.Children(i).FontSize = fontsize;
                %%% Make Bold
                %panel_copy.Children(i).FontWeight = 'bold';
                %%% disable titles
                title(panel_copy.Children(i),'');
                %panel_copy.Children(i).Layer = 'bottom';
                %%% move axes up and left
                panel_copy.Children(i).Position = panel_copy.Children(i).Position + [0.03 0.04 0 0];
                %%% Add parameters on plot
                if isfield(BurstData{file},'Corrections')
                    switch i
                        case 4
                            %%% crosstalk
                            str = ['crosstalk = ' sprintf('%1.3f',BurstData{file}.Corrections.CrossTalk_GR)];
                            text(0.35*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                        case 3
                            %%%direct excitation
                            str = ['direct exc. = ' sprintf('%1.3f',BurstData{file}.Corrections.DirectExcitation_GR)];
                            text(0.35*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                        case 2
                            %%% gamma
                            str = ['gamma = ' sprintf('%1.3f',BurstData{file}.Corrections.Gamma_GR)];

                            text(0.35*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',fontsize);
                    end
                end
            end
        elseif any(BurstData{file}.BAMethod == [3,4])
            hfig.Position(3) = hfig.Position(3)*1.55;
            %hfig.Position(4) = hfig.Position(3)*1.1;
            
            for i = 1:numel(panel_copy.Children)
                %%% Set the Color of Axes to white
                panel_copy.Children(i).Color = [1 1 1];
                %%% Move axis to top of stack
                %panel_copy.Children(i).Layer = 'bottom';
                %%% change X/YColor Color Color
                panel_copy.Children(i).XColor = [0,0,0];
                panel_copy.Children(i).YColor = [0,0,0];
                panel_copy.Children(i).XLabel.Color = [0,0,0];
                panel_copy.Children(i).YLabel.Color = [0,0,0];
                %%% Increase FontSize
                panel_copy.Children(i).FontSize = fontsize;
                %%% Make Bold
                %panel_copy.Children(i).FontWeight = 'bold';
                %%% disable titles
                title(panel_copy.Children(i),'');
                %%% move axes up and left
                panel_copy.Children(i).Position = panel_copy.Children(i).Position + [0.01 0.02 0 0];
                if any(i==[1,3,4])
                    panel_copy.Children(i).YLabel.Units = 'normalized';
                    panel_copy.Children(i).YLabel.Position = [-0.16 0.5 0];
                end
                msgbox('anders, see the 2 color code')
%                 %%% Add rotational correlation time
%                 if isfield(BurstData{file},'Parameters')
%                     switch i
%                         case 1
%                             %%%rBB vs TauBB
%                             if isfield(BurstData{file}.Parameters,'rhoBB')
%                                 if ~isempty(BurstData{file}.Parameters.rhoBB)
%                                     str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoBB(1))];
%                                     if numel(BurstData{file}.Parameters.rhoBB) > 1
%                                         str = {[str(1:4) '_1' str(5:end)]};
%                                         for j=2:numel(BurstData{file}.Parameters.rhoBB)
%                                             str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoBB(j))];
%                                         end
%                                     end
%                                 end
%                             end
%                             text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
%                                 'Parent',panel_copy.Children(i),...
%                                 'FontSize',fontsize);
%                             %'BackgroundColor',[1 1 1],...
%                             %'EdgeColor',[0 0 0]);
%                         case 3
%                             %%%rRR vs TauRR
%                             if isfield(BurstData{file}.Parameters,'rhoRR')
%                                 if ~isempty(BurstData{file}.Parameters.rhoRR)
%                                     str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoRR(1))];
%                                     if numel(BurstData{file}.Parameters.rhoRR) > 1
%                                         str = {[str(1:4) '_1' str(5:end)]};
%                                         for j=2:numel(BurstData{file}.Parameters.rhoRR)
%                                             str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoRR(j))];
%                                         end
%                                     end
%                                 end
%                             end
%                             text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
%                                 'Parent',panel_copy.Children(i),...
%                                 'FontSize',fontsize);
%                             %'BackgroundColor',[1 1 1],...
%                             %'EdgeColor',[0 0 0]);
%                         case 4
%                             %%%rGG vs TauGG
%                             if isfield(BurstData{file}.Parameters,'rhoGG')
%                                 if ~isempty(BurstData{file}.Parameters.rhoGG)
%                                     str = ['\rho = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoGG(1))];
%                                     if numel(BurstData{file}.Parameters.rhoGG) > 1
%                                         str = {[str(1:4) '_1' str(5:end)]};
%                                         for j=2:numel(BurstData{file}.Parameters.rhoGG)
%                                             str{j} = ['\rho_' num2str(j) ' = ' sprintf('%1.1f ns',BurstData{file}.Parameters.rhoGG(j))];
%                                         end
%                                     end
%                                 end
%                             end
%                             text(0.05*panel_copy.Children(i).XLim(2),0.87*panel_copy.Children(i).YLim(2),str,...
%                                 'Parent',panel_copy.Children(i),...
%                                 'FontSize',fontsize);
%                             %'BackgroundColor',[1 1 1],...
%                             %'EdgeColor',[0 0 0]);
%                     end
%                 end
             end
        end
        FigureName = 'CorrectionPlots';
end

%%% Set all units to pixels for easy editing without resizing
hfig.Units = 'pixels';
for i = 1:numel(hfig.Children)
    if isprop(hfig.Children(i),'Units');
        hfig.Children(i).Units = 'pixels';
    end
end
%%% Combine the Original FileName and the parameter names
if isfield(BurstData{file},'FileNameSPC')
    if strcmp(BurstData{file}.FileNameSPC,'_m1')
        FileName = BurstData{file}.FileNameSPC(1:end-3);
    else
        FileName = BurstData{file}.FileNameSPC;
    end
else
    FileName = BurstData{file}.FileName(1:end-4);
end

if BurstData{file}.SelectedSpecies(1) ~= 0
    SpeciesName = ['_' BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),1}];
    if BurstData{file}.SelectedSpecies(2) > 1 %%% subspecies selected, append
        SpeciesName = [SpeciesName '_' BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)}];
    end
else
    SpeciesName = '';
end
FigureName = [FileName SpeciesName '_' FigureName];
%%% remove spaces
FigureName = strrep(strrep(FigureName,' ','_'),'/','-');
hfig.CloseRequestFcn = {@ExportGraph_CloseFunction,ask_file,FigureName};

function ExportGraph_CloseFunction(hfig,~,ask_file,FigureName)
global UserValues BurstData BurstMeta
if isempty(UserValues) || isempty(BurstData)
    delete(hfig);
    return;
end
directly_save = UserValues.BurstBrowser.Settings.SaveFileExportFigure;
file = BurstMeta.SelectedFile;
if directly_save
    if ask_file
        %%% Get Path to save File
        FilterSpec = {'*.png','PNG File';'*.pdf','PDF File';'*.eps','EPS File';'*.tif','TIFF File'};
        [FileName,PathName,FilterIndex] = uiputfile(FilterSpec,'Choose a filename',fullfile(getPrintPath(),FigureName));       
        if FileName == 0
            delete(hfig);
            return;
        end
        if ~UserValues.BurstBrowser.Settings.UseFilePathForExport
            UserValues.BurstBrowser.PrintPath = PathName;
            h.Current_PrintPath_Text.Label = PathName;
        end
        LSUserValues(1);
    else
        FilterIndex = 1; %%% Save as png
        FileName = [FigureName '.png'];
        PathName = getPrintPath();
    end
    FileName = strrep(FileName,'/','-');
    %%% print figure
    hfig.PaperPositionMode = 'auto';
    dpi = 300;
    switch FilterIndex
        case 1
            print(hfig,fullfile(PathName,FileName),'-dpng',sprintf('-r%d',dpi),'-painters');
        case {2,3}
            % Make changing paper type possible
            set(hfig,'PaperType','<custom>');
            
            % Set units to all be the same
            set(hfig,'PaperUnits','inches');
            set(hfig,'Units','inches');
            
            % Set the page size and position to match the figure's dimensions
            position = get(hfig,'Position');
            set(hfig,'PaperPosition',[0,0,position(3:4)]);
            set(hfig,'PaperSize',position(3:4));
            set(hfig,'InvertHardCopy', 'off');
            switch FilterIndex
                case 2
                    print(hfig,fullfile(PathName,FileName),'-dpdf',sprintf('-r%d',dpi));
                case 3
                    print(hfig,fullfile(PathName,FileName),'-depsc','-painters');
            end
        case 4
            print(hfig,fullfile(PathName,FileName),'-dtiff',sprintf('-r%d',dpi));
    end
    
    hfig.CloseRequestFcn = @(x,y) delete(x);
    pause(0.5)
    delete(hfig);
    LSUserValues(1);
else
    delete(hfig);
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export All Graphs at once %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExportAllGraphs(obj,~)
global BurstData BurstMeta UserValues
h = guidata(obj);

%%% enable saving
prev_setting = UserValues.BurstBrowser.Settings.SaveFileExportFigure;
UserValues.BurstBrowser.Settings.SaveFileExportFigure = 1;
file = BurstMeta.SelectedFile;
UpdateCorrections([],[],h);
UpdateCutTable(h);
UpdateCuts();
%Update_fFCS_GUI([],[],h);
%update all plots, cause that's what we'll be copying
UpdatePlot([],[],h);
UpdateLifetimePlots([],[],h);
PlotLifetimeInd([],[],h);

if any(BurstData{file}.BAMethod == [3,4])
    disp('Not implemented for three color.');
    return;
end

% 2D E-S 
h.ParameterListX.Value = find(strcmp('FRET Efficiency',BurstData{file}.NameArray));
h.ParameterListY.Value = find(strcmp('Stoichiometry',BurstData{file}.NameArray));
UpdatePlot([],[],h);
[hfig, FigureName] = ExportGraphs(h.Export2D_Menu,[],0);
ExportGraph_CloseFunction(hfig,[],0,FigureName)
% 1D E
[hfig, FigureName] = ExportGraphs(h.Export1DX_Menu,[],0);
ExportGraph_CloseFunction(hfig,[],0,FigureName) 
% all lifetime & anisotropy plots
[hfig, FigureName] = ExportGraphs(h.ExportLifetime_Menu,[],0);
ExportGraph_CloseFunction(hfig,[],0,FigureName)
% 2D E-tau
h.lifetime_ind_popupmenu.Value = 1;
PlotLifetimeInd([],[]);
[hfig, FigureName] = ExportGraphs(h.Export2DLifetime_Menu,[],0);
ExportGraph_CloseFunction(hfig,[],0,FigureName)
% Corrections
% [hfig, FigureName] = ExportGraphs(h.ExportCorrections_Menu,[],0);
% ExportGraph_CloseFunction(hfig,[],0,FigureName)

UserValues.BurstBrowser.Settings.SaveFileExportFigure = prev_setting;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export all-in-one graphs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExportAllInOneGraphs(obj,~,arrangement)
global BurstData BurstMeta UserValues
h = guidata(obj);

%%% some options
overlay = true; %%% overlay the axis labels on 1D plot
opacity = 0.8; %%% gray color for 1D axis if overlay = true
% file and species that are currently selected
[file, species, subspecies] = get_multiselection(h);
file_old = BurstMeta.SelectedFile;
old_paramX = h.ParameterListX.Value;
old_paramY = h.ParameterListY.Value;
            
Progress(0,h.Progress_Axes,h.Progress_Text,'Generating figure...');

for k = 1:numel(file) %loop through all selected species
    BurstMeta.SelectedFile = file(k);
    % select the same species for all files as for the currently selected file
    SelectedSpecies_old = BurstData{file(k)}.SelectedSpecies;
    BurstData{file(k)}.SelectedSpecies = [species(k), subspecies(k)];
    
    %%% Make sure to apply corrections
    ApplyCorrections(obj,[],h,0);
    UpdateCutTable(h);
    UpdateCuts();
    %update all plots, cause that's what we'll be copying
    UpdatePlot([],[],h);
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
    
    if any(BurstData{file(k)}.BAMethod == [3,4])
        disp('Not implemented for three color.');
        return;
    end
    
    % initialize the figure
    fontsize = 8;
    if ispc
        fontsize = fontsize/1.2;
    end
    size_pixels = 650;
    AspectRatio = 1;
    pos = [100,100, round(1.3*size_pixels),round(1.2*size_pixels*AspectRatio)];
    
    % make a cell containing the strings of the parameters you want to plot
    % in the figure.
    paramname = cell(4,2);
    % 2D Lifetime-E
    paramname{1,1} = 'Lifetime D [ns]';
    paramname{1,2} = 'FRET Efficiency';
    % 2D lifetime GG-Anisotropy GG
    paramname{2,1} = 'Lifetime D [ns]';
    paramname{2,2} = 'Anisotropy D';
    % 2D lifetime RR-Anisotropy RR
    paramname{3,1} = 'Lifetime A [ns]';
    paramname{3,2} = 'Anisotropy A';
    % 2D Stoichiometry-E
    paramname{5,1} = 'Stoichiometry';
    paramname{5,2} = 'FRET Efficiency';
    % 2D FRET efficiency vs Lifetime A
    paramname{4,1} = 'Lifetime A [ns]';
    paramname{4,2} = 'FRET Efficiency';
    
    panel_copy = cell(5,1);
    
    % Make 4 new figures with the appropriate plots
    for f = 1:5
        hfig{f} = figure('Position',pos,'Color',[1 1 1],'Visible','off');
        if f < 5
            %%% Update lifetime ind plot
            switch f
                case 1
                    h.lifetime_ind_popupmenu.Value = 1;
                case 2
                    h.lifetime_ind_popupmenu.Value = 3;
                case 3
                    h.lifetime_ind_popupmenu.Value = 4;
                case 4
                    h.lifetime_ind_popupmenu.Value = 2;
            end
            PlotLifetimeInd([],[],h);
            panel_copy{f} = copyobj([h.axes_lifetime_ind_1d_y,...
                h.axes_lifetime_ind_1d_x,...
                h.axes_lifetime_ind_2d],...
                hfig{f});
        else
            h.ParameterListX.Value = find(strcmp(paramname{f,1},BurstData{file(k)}.NameArray));
            h.ParameterListY.Value = find(strcmp(paramname{f,2},BurstData{file(k)}.NameArray));
            %%% restrict E and S to fixed intervals
            prev_setting = UserValues.BurstBrowser.Display.Restrict_EandS_Range;
            UserValues.BurstBrowser.Display.Restrict_EandS_Range = 1;
            UpdatePlot([],[],h);
            %%% Copy axes to figure
            panel_copy{f} = copyobj([findobj('Parent',h.MainTabGeneralPanel,'Tag','Axes_1D_Y'),...
                findobj('Parent',h.MainTabGeneralPanel,'Tag','Axes_1D_X'),...
                findobj('Parent',h.MainTabGeneralPanel,'Tag','Axes_General')],...
                hfig{f});
            UserValues.BurstBrowser.Display.Restrict_EandS_Range = prev_setting;
            UpdatePlot([],[],h);
        end
        %%% set Background Color to white
        for a = 1:3
            panel_copy{f}(a).Color = [1 1 1];
            panel_copy{f}(a).XColor = [0 0 0];
            panel_copy{f}(a).GridAlpha=0.5;
            panel_copy{f}(a).GridAlphaMode = 'manual';
            panel_copy{f}(a).GridColor = [0 0 0];
            panel_copy{f}(a).GridColorMode = 'auto';
            panel_copy{f}(a).GridLineStyle = '-';
            %panel_copy{f}(a).XTickLabelMode = 'auto';
            %panel_copy{f}(a).YTickLabelMode = 'auto';
            panel_copy{f}(a).XMinorGrid = 'off';
            panel_copy{f}(a).YMinorGrid = 'off';
            %%% change X/YColor Color Color
            panel_copy{f}(a).XColor = [0,0,0];
            panel_copy{f}(a).YColor = [0,0,0];
            panel_copy{f}(a).XLabel.Color = [0,0,0];
            panel_copy{f}(a).YLabel.Color = [0,0,0];
        end
        for a = 3
            panel_copy{f}(a).YColor = [0 0 0];
            panel_copy{f}(a).XGrid = 'on';
            panel_copy{f}(a).YGrid = 'on';
        end
        for a = 1:2
            panel_copy{f}(a).XTickLabelMode = 'auto';
            panel_copy{f}(a).YTickLabelMode = 'auto';
            panel_copy{f}(a).XGrid = 'off';
            panel_copy{f}(a).YGrid = 'off';
            %%% delete the stair plot
            if f == 5
                set(panel_copy{f}(a).Children(end-2),'Color','none');
            else
                delete(panel_copy{f}(a).Children(1));
            end
        end
        for a = 3
            panel_copy{f}(a).XTickLabel = [];
            panel_copy{f}(a).YTickLabel = [];
            panel_copy{f}(a).XLabel.String = [];
            panel_copy{f}(a).YLabel.String = [];
        end
            
    end
    panel_copy([5,4]) = deal(panel_copy([4,5]));
    hfigallinone = figure('Position',pos.*[1,1,1.5,1],'Color',[1 1 1],'Visible','on');
    norm_to_pix = [pos(3),pos(4),pos(3),pos(4)];
    
    corr = BurstData{file(k)}.Corrections;
    Pos = struct;
    %tauD - E plots
    Pos.Y.tauD_E =  [0.06 0.53 0.06 0.35].*norm_to_pix;
    Pos.X.tauD_E =   [0.12 0.88 0.35 0.06].*norm_to_pix;
    Pos.XY.tauD_E =   [0.12 0.53 0.35 0.35].*norm_to_pix;
    %tauD - rD plots
    Pos.Y.tauD_rD = [0.06 0.18 0.06 0.35].*norm_to_pix;
    Pos.X.tauD_rD =  [0.12 0.12 0.35 0.06].*norm_to_pix;
    Pos.XY.tauD_rD =  [0.12 0.18 0.35 0.35].*norm_to_pix;
    if arrangement == 1
        %[1, 2, 3;
        %[4, 5,  ];
        Pos.Y.tauA_E =  [1.5  1.5  0.06 0.35].*norm_to_pix; %move it out of the screen
        Pos.X.tauA_E =  [0.47 0.88 0.35 0.06].*norm_to_pix;
        Pos.XY.tauA_E = [0.47 0.53 0.35 0.35].*norm_to_pix;
        Pos.Y.tauA_rA = [0.82 0.18 0.06 0.35].*norm_to_pix;
        Pos.X.tauA_rA = [0.47 0.12 0.35 0.06].*norm_to_pix;
        Pos.XY.tauA_rA =[0.47 0.18 0.35 0.35].*norm_to_pix;
        Pos.Y.S_E =     [1.17 0.53 0.06 0.35].*norm_to_pix;
        Pos.X.S_E =     [0.82 0.88 0.35 0.06].*norm_to_pix;
        Pos.XY.S_E =    [0.82 0.53 0.35 0.35].*norm_to_pix;
        Pos.cbar =      [0.98,0.49,0.19,0.02].*norm_to_pix;
        Pos.table =     [0.6000 0.180 0.2750 0.2750];
    else
        %[1, 3, 2;
        %[4,  , 5];
        Pos.Y.tauA_E =  [1.17  0.53  0.06 0.35].*norm_to_pix;
        Pos.X.tauA_E =  [0.82 0.88 0.35 0.06].*norm_to_pix;
        Pos.XY.tauA_E = [0.82 0.53 0.35 0.35].*norm_to_pix;
        Pos.Y.tauA_rA = [1.17 0.18 0.06 0.35].*norm_to_pix;
        Pos.X.tauA_rA = [0.82 0.12 0.35 0.06].*norm_to_pix;
        Pos.XY.tauA_rA =[0.82 0.18 0.35 0.35].*norm_to_pix;
        Pos.Y.S_E =     [1.17 1.5 0.06 0.35].*norm_to_pix; %move it out of the screen
        Pos.X.S_E =     [0.47 0.88 0.35 0.06].*norm_to_pix;
        Pos.XY.S_E =    [0.47 0.53 0.35 0.35].*norm_to_pix;
        Pos.cbar =      [0.55,0.47,0.19,0.02].*norm_to_pix;
        Pos.table =     [0.32 0.180 0.22 0.25];
    end
    
    % 2D Lifetime-E
    copyobj([panel_copy{1}],hfigallinone);
    delete(hfigallinone.Children(strcmp(get(hfigallinone.Children,'Type'),'uicontextmenu')));
    hfigallinone.Children(1).Units = 'pixel';
    hfigallinone.Children(1).Position = Pos.Y.tauD_E;
    set(hfigallinone.Children(1).YLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(1).XAxisLocation = 'bottom';
    hfigallinone.Children(1).YLabel.Position = [0.48 1.1 0];
    set(hfigallinone.Children(1).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(1).XLabel.Position = [-0.55 0.5 0];
    hfigallinone.Children(1).XLabel.String = 'FRET Efficiency';
    set(hfigallinone.Children(1), 'Ydir','reverse')
    hfigallinone.Children(1).YAxisLocation = 'Right';
    hfigallinone.Children(1).YTickLabelRotation = 90;
    hfigallinone.Children(1).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(1).YAxis.FontSize = fontsize;
    end
    hfigallinone.Children(1).YTick = [];
    hfigallinone.Children(1).YLabel.String = '';
    
    hfigallinone.Children(2).Units = 'pixel';
    hfigallinone.Children(2).Position = Pos.X.tauD_E;   
    set(hfigallinone.Children(2).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(2).XLabel.Position = [0.43 1.5 0];
    hfigallinone.Children(2).YAxisLocation = 'Right';
    hfigallinone.Children(2).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(2).YAxis.FontSize = fontsize;
    end
    hfigallinone.Children(2).TickLength = [0.0100 0.0250];
    hfigallinone.Children(2).YTickLabel = [];
    hfigallinone.Children(2).YLabel.String = '';
    hfigallinone.Children(2).YTick = [];
    hfigallinone.Children(2).XLabel.String = 'Lifetime D [ns]';
    
    hfigallinone.Children(3).Units = 'pixel';
    hfigallinone.Children(3).Position = Pos.XY.tauD_E;
    hfigallinone.Children(3).XAxisLocation = 'top';
    hfigallinone.Children(3).XGrid = 'on';
    hfigallinone.Children(3).YGrid = 'on';
    hfigallinone.Children(3).YTickLabel = [];
    hfigallinone.Children(3).YLabel.String = '';
    
    b = 1;
    labels = hfigallinone.Children(b).XTickLabel;
    if hfigallinone.Children(b).XTick(1) == hfigallinone.Children(1).XLim(1)
        labels{1} = '';
    end
    hfigallinone.Children(b).XTickLabel = labels;
    
    hfigallinone.Children(1).Layer = 'top';
    hfigallinone.Children(2).Layer = 'top';

    if overlay
        hfigallinone.Children(1).Children(1).FaceColor = [opacity,opacity,opacity];
        hfigallinone.Children(1).Visible = 'off';
        hfigallinone.Children(3).YLabel.String = hfigallinone.Children(1).XLabel.String;
        hfigallinone.Children(3).YTickLabel = hfigallinone.Children(1).XTickLabel;
        hfigallinone.Children(3).YLabel.Units = 'norm';
        hfigallinone.Children(3).YLabel.Position(1) = -0.17;
        hfigallinone.Children(2).Children(1).FaceColor = [opacity,opacity,opacity];
        hfigallinone.Children(2).Visible = 'off';
        hfigallinone.Children(3).XLabel.String = hfigallinone.Children(2).XLabel.String;
        hfigallinone.Children(3).XTickLabel = hfigallinone.Children(2).XTickLabel;
        hfigallinone.Children(3).XLabel.Units = 'norm';
        hfigallinone.Children(3).XLabel.Position(2) = 1.17;
        hfigallinone.Children(3).TickDir = 'out';
        uistack(hfigallinone.Children(1:2),'bottom');
    end
   
    % 2D lifetime GG-Anisotropy GG
    copyobj([panel_copy{2}],hfigallinone);
    delete(hfigallinone.Children(strcmp(get(hfigallinone.Children,'Type'),'uicontextmenu')));
    hfigallinone.Children(1).Units = 'pixel';
    hfigallinone.Children(1).Position = Pos.Y.tauD_rD;
    hfigallinone.Children(1).YLabel.Color = 'k';
    set(hfigallinone.Children(1).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(1).XAxisLocation = 'bottom';
    hfigallinone.Children(1).XLabel.Position = [-0.55 0.5 0];
    hfigallinone.Children(1).XLabel.String = 'Anisotropy D';
    hfigallinone.Children(1).TickLength = [0.0100 0.0250];
    hfigallinone.Children(1).YAxisLocation = 'Left';
    hfigallinone.Children(1).YTickLabelRotation = 90;
    hfigallinone.Children(1).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(1).YAxis.FontSize = fontsize;
    end
    hfigallinone.Children(1).YTick = [500 1000 1500];
    hfigallinone.Children(1).YTick = [];
    hfigallinone.Children(1).YLabel.String = '';
    
    hfigallinone.Children(2).Units = 'pixel';
    hfigallinone.Children(2).Position = Pos.X.tauD_rD;
    hfigallinone.Children(2).XAxisLocation = 'bottom';
    set(hfigallinone.Children(2).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(2).YTickLabel = [];
    hfigallinone.Children(2).YLabel.String = '';
    hfigallinone.Children(2).YTick = [];
    hfigallinone.Children(2).XLabel.Position = [0.50 -0.5 0];
    hfigallinone.Children(2).XLabel.String = 'Lifetime D [ns]';
    
    hfigallinone.Children(3).Units = 'pixel';
    hfigallinone.Children(3).Position = Pos.XY.tauD_rD;
    hfigallinone.Children(3).XGrid = 'on';
    hfigallinone.Children(3).YGrid = 'on';
    hfigallinone.Children(3).YTickLabel = [];
    hfigallinone.Children(3).YLabel.String = '';
    
    set(hfigallinone.Children(1), 'Ydir','reverse')
    set(hfigallinone.Children(2), 'Ydir','reverse')
    
    hfigallinone.Children(1).Layer = 'top';
    hfigallinone.Children(2).Layer = 'top';
    
    if overlay
        hfigallinone.Children(1).Children(1).FaceColor = [opacity,opacity,opacity];
        hfigallinone.Children(1).Visible = 'off';
        hfigallinone.Children(3).YLabel.String = hfigallinone.Children(1).XLabel.String;
        hfigallinone.Children(3).YTickLabel = hfigallinone.Children(1).XTickLabel;
        hfigallinone.Children(3).YLabel.Units = 'norm';
        hfigallinone.Children(3).YLabel.Position(1) = -0.17;
        hfigallinone.Children(2).Children(1).FaceColor = [opacity,opacity,opacity];
        hfigallinone.Children(2).Visible = 'off';
        hfigallinone.Children(3).XLabel.String = hfigallinone.Children(2).XLabel.String;
        hfigallinone.Children(3).XTickLabel = hfigallinone.Children(2).XTickLabel;
        hfigallinone.Children(3).XLabel.Units = 'norm';
        hfigallinone.Children(3).XLabel.Position(2) = -0.17;
        hfigallinone.Children(3).TickDir = 'out';
        uistack(hfigallinone.Children(1:2),'bottom');
    end

    % 2D lifetime RR-Anisotropy RR
    copyobj([panel_copy{3}],hfigallinone);
    delete(hfigallinone.Children(strcmp(get(hfigallinone.Children,'Type'),'uicontextmenu')));
    hfigallinone.Children(1).Units = 'pixel';
    hfigallinone.Children(1).Position = Pos.Y.tauA_rA;
    set(hfigallinone.Children(1).XLabel,'Color', 'k', 'Units', 'norm','rotation', -90);
    hfigallinone.Children(1).XLabel.Position = [2.1 0.5 0];
    hfigallinone.Children(1).XLabel.String = 'Anisotropy A';
    hfigallinone.Children(1).YAxisLocation = 'Right';
    hfigallinone.Children(1).YTickLabelRotation = -90;
    hfigallinone.Children(1).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(1).YAxis.FontSize = fontsize;
    catch
        %hfigallinone.Children(1).FontSize = fontsize;
    end
    hfigallinone.Children(1).YTick = [];
    
    hfigallinone.Children(2).Units = 'pixel';
    hfigallinone.Children(2).Position = Pos.X.tauA_rA;
    hfigallinone.Children(2).XAxisLocation = 'bottom';
    set(hfigallinone.Children(2).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(2).XLabel.Position = [0.50 -0.5 0];
    hfigallinone.Children(2).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(2).YAxis.FontSize = fontsize;
    end
    %hfigallinone.Children(2).XTick = [0 1 2 3 4 5 6];
    hfigallinone.Children(2).YTick = [];
    hfigallinone.Children(2).YLabel.String = '';
    hfigallinone.Children(2).XLabel.String = 'Lifetime A [ns]';
    
    hfigallinone.Children(3).Units = 'pixel';
    hfigallinone.Children(3).Position = Pos.XY.tauA_rA;
    hfigallinone.Children(3).XGrid = 'on';
    hfigallinone.Children(3).YGrid = 'on';
    hfigallinone.Children(3).YTickLabel = [];
    hfigallinone.Children(3).YLabel.String = '';
    
    set(hfigallinone.Children(2), 'Ydir','reverse')
	b = 1;
    labels = hfigallinone.Children(b).XTickLabel;
    if hfigallinone.Children(b).XTick(end) == hfigallinone.Children(b).XLim(2)
        labels{end} = '';
    end
    hfigallinone.Children(b).XTickLabel = labels;
    
    hfigallinone.Children(1).Layer = 'top';
    hfigallinone.Children(2).Layer = 'top';
    
    if overlay
        hfigallinone.Children(1).Children(1).FaceColor = [opacity,opacity,opacity];
        hfigallinone.Children(1).Visible = 'off';
        hfigallinone.Children(3).YLabel.String = hfigallinone.Children(1).XLabel.String;
        hfigallinone.Children(3).YTickLabel = hfigallinone.Children(1).XTickLabel;
        hfigallinone.Children(3).YLabel.Units = 'norm';
        hfigallinone.Children(3).YLabel.Rotation = -90;
        hfigallinone.Children(3).YTickLabelRotation = -90;
        hfigallinone.Children(3).YAxisLocation = 'right';
        hfigallinone.Children(3).YLabel.Position(1) = 1.24;
        hfigallinone.Children(2).Children(1).FaceColor = [opacity,opacity,opacity];
        hfigallinone.Children(2).Visible = 'off';
        hfigallinone.Children(3).XLabel.String = hfigallinone.Children(2).XLabel.String;
        hfigallinone.Children(3).XTickLabel = hfigallinone.Children(2).XTickLabel;
        hfigallinone.Children(3).XLabel.Units = 'norm';
        hfigallinone.Children(3).XLabel.Position(2) = -0.17;
        hfigallinone.Children(3).TickDir = 'out';
        uistack(hfigallinone.Children(1:2),'bottom');
    end

    % 2D E-tauA
    copyobj([panel_copy{5}],hfigallinone);
    delete(hfigallinone.Children(strcmp(get(hfigallinone.Children,'Type'),'uicontextmenu')));
    hfigallinone.Children(1).Units = 'pixel';
    hfigallinone.Children(1).Position = Pos.Y.tauA_E;
    if arrangement == 1
        hfigallinone.Children(1).Visible = 'off';
    else
        set(hfigallinone.Children(1).XLabel,'Color', 'k', 'Units', 'norm','rotation', -90);
        hfigallinone.Children(1).XLabel.Position = [2.1 0.5 0];
        hfigallinone.Children(1).XLabel.String = 'FRET Efficiency';
        hfigallinone.Children(1).YAxisLocation = 'Right';
        hfigallinone.Children(1).YTickLabelRotation = -90;
        try
            hfigallinone.Children(1).YAxis.FontSize = fontsize;
        catch
            %hfigallinone.Children(1).FontSize = fontsize;
        end
        hfigallinone.Children(1).YTick = [];
    end

    hfigallinone.Children(2).Units = 'pixel';
    hfigallinone.Children(2).Position = Pos.X.tauA_E;
    set(hfigallinone.Children(2).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(2).XLabel.Position = [0.50 1.5 0];
    hfigallinone.Children(2).YAxisLocation = 'Right';
    hfigallinone.Children(2).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(2).YAxis.FontSize = fontsize;
    end
    hfigallinone.Children(2).TickLength = [0.0100 0.0250];
    hfigallinone.Children(2).YTick = [];
    hfigallinone.Children(2).YLabel.String = '';
    hfigallinone.Children(2).XLabel.String = 'Lifetime A [ns]';
    
    hfigallinone.Children(3).Units = 'pixel';
    hfigallinone.Children(3).Position = Pos.XY.tauA_E;
    hfigallinone.Children(3).XAxisLocation = 'top';
    hfigallinone.Children(3).XLabel.Position = [0.50 1.0 0];
    hfigallinone.Children(3).XGrid = 'on';
    hfigallinone.Children(3).YGrid = 'on';    
%     b = 2;
%     labels = hfigallinone.Children(b).XTickLabel;
%     if hfigallinone.Children(b).XTick(1) == hfigallinone.Children(b).XLim(1)
%         labels{1} = '';
%     end
%     hfigallinone.Children(b).XTickLabel = labels;
    hfigallinone.Children(b).YTick = [];
    
    hfigallinone.Children(1).Layer = 'top';
    hfigallinone.Children(2).Layer = 'top';
    
    if overlay
        if arrangement == 2
            set(findobj(hfigallinone.Children(1).Children,'Type','bar'),'FaceColor',[opacity,opacity,opacity]);
            hfigallinone.Children(1).Visible = 'off';
            hfigallinone.Children(3).YLabel.String = hfigallinone.Children(1).XLabel.String;
            hfigallinone.Children(3).YTickLabel = hfigallinone.Children(1).XTickLabel;
            hfigallinone.Children(3).YLabel.Units = 'norm';
            hfigallinone.Children(3).YLabel.Rotation = -90;
            hfigallinone.Children(3).YTickLabelRotation = -90;
            hfigallinone.Children(3).YAxisLocation = 'right';
            hfigallinone.Children(3).YLabel.Position(1) = 1.24;
        end
        hfigallinone.Children(2).Children(1).FaceColor = [opacity,opacity,opacity];
        hfigallinone.Children(2).Visible = 'off';
        hfigallinone.Children(3).XLabel.String = hfigallinone.Children(2).XLabel.String;
        hfigallinone.Children(3).XTickLabel = hfigallinone.Children(2).XTickLabel;
        hfigallinone.Children(3).XLabel.Units = 'norm';
        hfigallinone.Children(3).XLabel.Position(1:2) = [0.5, 1.17];
        hfigallinone.Children(3).TickDir = 'out';
        uistack(hfigallinone.Children(1:2),'bottom');
    end
      
    % 2D Stoichiometry-E
    copyobj([panel_copy{4}],hfigallinone);
    delete(hfigallinone.Children(strcmp(get(hfigallinone.Children,'Type'),'uicontextmenu')));
    hfigallinone.Children(1).Units = 'pixel';
    hfigallinone.Children(1).Position = Pos.Y.S_E;
    if arrangement == 2
        hfigallinone.Children(1).Visible = 'off';
    else
        hfigallinone.Children(1).YTickLabel = [];
        hfigallinone.Children(1).YLabel.String = '';
        hfigallinone.Children(1).YTick = [];
        hfigallinone.Children(1).XLabel.String = 'FRET Efficiency';
        set(hfigallinone.Children(1).XLabel,'Color', 'k', 'Units', 'norm','rotation', -90);
        hfigallinone.Children(1).XLabel.Position = [2.1 0.5 0];
        hfigallinone.Children(1).YLim(2) = max(hfigallinone.Children(1).Children(end-1).YData)*1.05; %%% adapt to YLim of related axes
    end
    hfigallinone.Children(2).Units = 'pixel';
    hfigallinone.Children(2).Position = Pos.X.S_E;
    set(hfigallinone.Children(2).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(2).XLabel.Position = [0.50 1.5 0];
    hfigallinone.Children(2).YAxisLocation = 'Right';
    hfigallinone.Children(2).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(2).YAxis.FontSize = fontsize;
    end
    hfigallinone.Children(2).TickLength = [0.0100 0.0250];
    hfigallinone.Children(2).YTick = [];
    hfigallinone.Children(2).YLabel.String = '';
    hfigallinone.Children(2).YLim(2) = max(hfigallinone.Children(2).Children(end-1).YData)*1.05; %%% adapt to YLim of related axes
    
    hfigallinone.Children(3).Units = 'pixel';
    hfigallinone.Children(3).Position = Pos.XY.S_E;
    hfigallinone.Children(3).XAxisLocation = 'top';
    hfigallinone.Children(3).XLabel.Position = [0.50 1.0 0];
    hfigallinone.Children(3).XGrid = 'on';
    hfigallinone.Children(3).YGrid = 'on';
    b = 2;
    labels = hfigallinone.Children(b).XTickLabel;
    if hfigallinone.Children(b).XTick(1) == hfigallinone.Children(b).XLim(1)
        labels{1} = '';
    end
    hfigallinone.Children(b).XTickLabel = labels;
    hfigallinone.Children(b).YTick = [];
    
    hfigallinone.Children(1).Layer = 'top';
    hfigallinone.Children(2).Layer = 'top';
    
    if overlay
        if arrangement == 1
            set(findobj(hfigallinone.Children(1).Children,'Type','bar'),'FaceColor',[opacity,opacity,opacity]);
            hfigallinone.Children(1).Visible = 'off';
            hfigallinone.Children(3).YLabel.String = hfigallinone.Children(1).XLabel.String;
            hfigallinone.Children(3).YTickLabel = hfigallinone.Children(1).XTickLabel;
            hfigallinone.Children(3).YLabel.Units = 'norm';
            hfigallinone.Children(3).YLabel.Rotation = -90;
            hfigallinone.Children(3).YTickLabelRotation = -90;
            hfigallinone.Children(3).YAxisLocation = 'right';
            hfigallinone.Children(3).YLabel.Position(1) = 1.24;
        end
        set(findobj(hfigallinone.Children(2).Children,'Type','bar'),'FaceColor',[opacity,opacity,opacity]);
        hfigallinone.Children(2).Visible = 'off';
        hfigallinone.Children(3).XLabel.String = hfigallinone.Children(2).XLabel.String;
        hfigallinone.Children(3).XTickLabel = hfigallinone.Children(2).XTickLabel;
        hfigallinone.Children(3).XLabel.Units = 'norm';
        hfigallinone.Children(3).XLabel.Position(2) = 1.17;
        hfigallinone.Children(3).TickDir = 'out';
        uistack(hfigallinone.Children(1:2),'bottom');
    end
    
    for u = 1:5
        close(hfig{u})
    end
    colormap(colormap(h.BurstBrowser));
    
    %%% fix plots overlaying on axes
    if ~UserValues.BurstBrowser.Display.PlotGridAboveData
        % find 2d axes
        ax2d = {};
        for i = 1:numel(hfigallinone.Children)
            if  strcmp(hfigallinone.Children(i).Type,'axes')
                if any(strcmp(get(hfigallinone.Children(i).Children,'Type'),'image'))
                    ax2d{end+1} = hfigallinone.Children(i);
                end
            end
        end
        for i = 1:numel(ax2d)
            %%% create dummy axis to prevent data overlapping the axis
            ax_dummy = axes('Parent',hfigallinone,'Units',ax2d{i}.Units,'Position',ax2d{i}.Position);
            %linkaxes([ax2d ax_dummy]);
            set(ax_dummy,'Color','none','XTick',ax2d{i}.XTick,'YTick',ax2d{i}.YTick,'XTickLabel',[],'YTickLabel',[],...
                'LineWidth',1,'Box','on','XLim',ax2d{i}.XLim, 'YLim', ax2d{i}.YLim);
        end
    end
    
    %%% add colorbar
    cbar = colorbar('peer', hfigallinone.Children(1),'Location','north','Color',[0 0 0]); 
    cbar.Units = 'pixel';
    cbar.Position = Pos.cbar;
    cbar.Label.String = 'Occurrence';
    cbar.Label.FontSize = 16;
    if ispc
        cbar.Label.FontSize = cbar.Label.FontSize/1.2;
    end
    cbar.Limits(1) = 0;
    cbar.Ticks = [];
    cbar.TickLabels = [];
    
    table_mode = 'html';
    switch table_mode
        case 'latex'
            %%% Add text box with information about applied corrections
            text_box = '$$\begin{tabular}{ll}';
            text_box = [text_box '\bf{Correction factors} & \\ '];
            text_box = [text_box sprintf('crosstalk: & %.2f\\\\ ',corr.CrossTalk_GR)];
            text_box = [text_box sprintf('direct excitation: & %.2f\\\\ ',corr.DirectExcitation_GR)];
            text_box = [text_box sprintf('$\\gamma$-factor: & %.2f\\\\ ',corr.Gamma_GR)];
            text_box = [text_box sprintf('$\\beta$-factor: & %.2f\\\\ ',corr.Beta_GR)];
            text_box = [text_box sprintf('$G_{D}$: & %.2f\\\\ ',corr.GfactorGreen)];
            text_box = [text_box sprintf('$G_{A}$: & %.2f\\\\ ',corr.GfactorRed)];
            text_box = [text_box ' & \\ '];
            text_box = [text_box '\bf{Dye parameters} & \\ '];
            text_box = [text_box sprintf('Foerster distance: & %d $\\rm{\\AA}$\\\\ ',corr.FoersterRadius)];
            text_box = [text_box sprintf('Linker length: & %d $\\rm{\\AA}$\\\\ ',corr.LinkerLength)];
            text_box = [text_box sprintf('Donor lifetime: & %.2f ns\\\\ ',corr.DonorLifetime)];
            text_box = [text_box sprintf('Acceptor lifetime: & %.2f ns\\\\ ',corr.AcceptorLifetime)];
            text_box = [text_box sprintf('$r_0(D)$: & %.2f\\\\ ',corr.r0_green)];
            text_box = [text_box sprintf('$r_0(A)$: & %.2f\\\\ ',corr.r0_green)];
            text_box = [text_box '\end{tabular}$$'];
            
            t=text(-1,0,text_box,'interpreter','latex','FontSize',fontsize);
            t.Units = 'normalized';
            t.Position = [-3.34 -0.81];
        case 'html'
            if arrangement == 1
                fontsize = 12; if ispc; fontsize = fontsize./1.2;end
                table = '<html><table>';
                table = [table '<tr><th align="left">Correction factors</th><th></th><th>&nbsp;&nbsp;</th><th align="left">Dye parameters</th><th></th></tr>'];
                table = [table '<tr><td>crosstalk:</td><td>' sprintf('%.2f', corr.CrossTalk_GR) '</td><td>&nbsp;</td><td>Foerster distance:</td><td>' sprintf('%d', corr.FoersterRadius) ' &#8491;</td></tr>'];
                table = [table '<tr><td>direct excitation:</td><td>' sprintf('%.2f', corr.DirectExcitation_GR) '</td><td>&nbsp;</td><td>app. Linker length:</td><td>' sprintf('%d', corr.LinkerLength) ' &#8491;</td></tr>'];
                table = [table '<tr><td>&gamma;-factor:</td><td>' sprintf('%.2f', corr.Gamma_GR) '</td><td>&nbsp;</td><td>Donor lifetime:</td><td>' sprintf('%.2f', corr.DonorLifetime) ' ns</td></tr>'];
                table = [table '<tr><td>&beta;-factor:</td><td>' sprintf('%.2f', corr.Gamma_GR) '</td><td>&nbsp;</td><td>Acceptor lifetime:</td><td>' sprintf('%.2f', corr.AcceptorLifetime) ' ns</td></tr>'];
                table = [table '<tr><td>G<sub>D</sub>:</td><td>' sprintf('%.2f', corr.GfactorGreen) '</td><td>&nbsp;</td><td>r<sub>0</sub>(D):</td><td>' sprintf('%.2f', corr.r0_green) '</td></tr>'];
                table = [table '<tr><td>G<sub>A</sub>:</td><td>' sprintf('%.2f', corr.GfactorRed) '</td><td>&nbsp;</td><td>r<sub>0</sub>(A):</td><td>' sprintf('%.2f', corr.r0_red) '</td></tr>'];
                table = [table '</table></html>'];
            else
                fontsize = 8.5; if ispc; fontsize = fontsize./1.2;end
                table = '<html><table>';
                table = [table '<tr><th align="left">Correction factors</th><th></th><th>&nbsp;&nbsp;</th><th align="left">Dye parameters</th><th></th></tr>'];
                table = [table '<tr><td>crosstalk:</td><td>' sprintf('%.2f', corr.CrossTalk_GR) '</td><td>&nbsp;</td><td>Foerster distance:</td><td>' sprintf('%d', corr.FoersterRadius) ' &#8491;</td></tr>'];
                table = [table '<tr><td>direct excitation:</td><td>' sprintf('%.2f', corr.DirectExcitation_GR) '</td><td>&nbsp;</td><td>app. Linker length:</td><td>' sprintf('%d', corr.LinkerLength) ' &#8491;</td></tr>'];
                table = [table '<tr><td>&gamma;-factor:</td><td>' sprintf('%.2f', corr.Gamma_GR) '</td><td>&nbsp;</td><td>Donor lifetime:</td><td>' sprintf('%.2f', corr.DonorLifetime) ' ns</td></tr>'];
                table = [table '<tr><td>&beta;-factor:</td><td>' sprintf('%.2f', corr.Gamma_GR) '</td><td>&nbsp;</td><td>Acceptor lifetime:</td><td>' sprintf('%.2f', corr.AcceptorLifetime) ' ns</td></tr>'];
                table = [table '<tr><td>G<sub>D</sub>:</td><td>' sprintf('%.2f', corr.GfactorGreen) '</td><td>&nbsp;</td><td>r<sub>0</sub>(D):</td><td>' sprintf('%.2f', corr.r0_green) '</td></tr>'];
                table = [table '<tr><td>G<sub>A</sub>:</td><td>' sprintf('%.2f', corr.GfactorRed) '</td><td>&nbsp;</td><td>r<sub>0</sub>(A):</td><td>' sprintf('%.2f', corr.r0_red) '</td></tr>'];
                table = [table '</table></html>'];
            end
            hTextbox = uicontrol('style','pushbutton', 'max',1000, 'Units', 'normalized', 'Position', Pos.table,...
                'FontName', UserValues.Look.Font, 'String',table, 'BackgroundColor',[1,1,1], 'FontSize', fontsize);
            hTextbox.Units = 'pixel';
            jPushButton = findjobj(hTextbox);
            jPushButton.setBorderPainted(false);
    end
    %%% Set all units to pixels for easy editing without resizing
    hfigallinone.Units = 'pixels';
    offset_y = 70; %%% shift everything down
    offset_x = 30; %%% shift everything left
    for i = 1:numel(hfigallinone.Children)
        if isprop(hfigallinone.Children(i),'Units');
            hfigallinone.Children(i).Units = 'pixels';
            hfigallinone.Children(i).Position(2) = hfigallinone.Children(i).Position(2) - offset_y;
            hfigallinone.Children(i).Position(1) = hfigallinone.Children(i).Position(1) - offset_x;
        end
    end
    hfigallinone.Position(3) = 1100 - offset_x;
    hfigallinone.Position(4) = hfigallinone.Position(4) - offset_y - 30;
    %%% Combine the Original FileName and the parameter names
    if isfield(BurstData{file(k)},'FileNameSPC')
        if strcmp(BurstData{file(k)}.FileNameSPC,'_m1')
            FileName = BurstData{file(k)}.FileNameSPC(1:end-3);
        else
            FileName = BurstData{file(k)}.FileNameSPC;
        end
    else
        FileName = BurstData{file(k)}.FileName(1:end-4);
    end

    if BurstData{file(k)}.SelectedSpecies(1) ~= 0
        SpeciesName = ['_' BurstData{file(k)}.SpeciesNames{BurstData{file(k)}.SelectedSpecies(1),1}];
        if BurstData{file(k)}.SelectedSpecies(2) > 1 %%% subspecies selected, append
            SpeciesName = [SpeciesName '_' BurstData{file(k)}.SpeciesNames{BurstData{file(k)}.SelectedSpecies(1),BurstData{file(k)}.SelectedSpecies(2)}];
        end
    else
        SpeciesName = '';
    end
    FigureName = 'AllInOne';
    FigureName = [FileName SpeciesName '_' FigureName];
    hfigallinone.Name = FigureName;
    hfigallinone.NumberTitle = 'off';
    %%% remove spaces
    FigureName = strrep(strrep(FigureName,' ','_'),'/','-');
    hfigallinone.CloseRequestFcn = {@ExportGraph_CloseFunction,1,FigureName};

    BurstData{file(k)}.SelectedSpecies = SelectedSpecies_old;
    
    Progress(k/numel(file),h.Progress_Axes,h.Progress_Text,'Generating figure...');
end 
h.ParameterListX.Value = old_paramX;
h.ParameterListY.Value = old_paramY;
BurstMeta.SelectedFile = file_old;
UpdatePlot([],[],h);
Progress(1,h.Progress_Axes,h.Progress_Text,'Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Update Color of Lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateLineColor(obj,~)
global BurstMeta UserValues
h = guidata(obj);
fields = fieldnames(BurstMeta.Plots.Fits);
switch obj
    case h.ColorLine1
        c = uisetcolor(UserValues.BurstBrowser.Display.ColorLine1);
        UserValues.BurstBrowser.Display.ColorLine1 = c;
        n=1;
    case h.ColorLine2
        c = uisetcolor(UserValues.BurstBrowser.Display.ColorLine2);
        UserValues.BurstBrowser.Display.ColorLine2 = c;
        n=2;
    case h.ColorLine3
        c = uisetcolor(UserValues.BurstBrowser.Display.ColorLine3);
        UserValues.BurstBrowser.Display.ColorLine3 = c;
        n=3;
    case h.ColorLine4
        c = uisetcolor(UserValues.BurstBrowser.Display.ColorLine4);
        UserValues.BurstBrowser.Display.ColorLine4 = c;
        n=4;
    case h.ColorLine5
        c = uisetcolor(UserValues.BurstBrowser.Display.ColorLine5);
        UserValues.BurstBrowser.Display.ColorLine5 = c;
        n=5;
    case h.ColorLine6
        c = uisetcolor(UserValues.BurstBrowser.Display.ColorLine6);
        UserValues.BurstBrowser.Display.ColorLine6 = c;
        n=6;
    case h.MarkerColor_button
        c = uisetcolor(UserValues.BurstBrowser.Display.MarkerColor);
        UserValues.BurstBrowser.Display.MarkerColor = c;
end

obj.BackgroundColor = c;

if obj == h.MarkerColor_button
    fields = fieldnames(BurstMeta.Plots); %%% loop through h structure
    %%% Make Image Plots Visible, Hide Contourf Plots
    for i = 1:numel(fields)
        if ~isempty(BurstMeta.Plots.(fields{i}))
            if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                    if numel(BurstMeta.Plots.(fields{i}))>2
                        BurstMeta.Plots.(fields{i})(3).CData = c;
                    end
                end
            end
        end
    end
    PlotLifetimeInd([],[],h);
    return;
end
%%% Change Color of Line Plots
for i = 1:numel(fields)
    if n <= numel(BurstMeta.Plots.Fits.(fields{i}))
        if strcmp(BurstMeta.Plots.Fits.(fields{i})(n).Type,'line')
            BurstMeta.Plots.Fits.(fields{i})(n).Color = c;
        end
    end
end

BurstMeta.Plots.Mixture.Main_Plot(1).LineColor = UserValues.BurstBrowser.Display.ColorLine1;
BurstMeta.Plots.Mixture.Main_Plot(2).LineColor = UserValues.BurstBrowser.Display.ColorLine2;
BurstMeta.Plots.Mixture.Main_Plot(3).LineColor = UserValues.BurstBrowser.Display.ColorLine3;
BurstMeta.Plots.Mixture.Main_Plot(4).LineColor = UserValues.BurstBrowser.Display.ColorLine4;
BurstMeta.Plots.Mixture.Main_Plot(5).LineColor = UserValues.BurstBrowser.Display.ColorLine5;
BurstMeta.Plots.Mixture.Main_Plot(6).LineColor = UserValues.BurstBrowser.Display.ColorLine6;
BurstMeta.Plots.Mixture.plotX(1).Color = UserValues.BurstBrowser.Display.ColorLine1;
BurstMeta.Plots.Mixture.plotX(2).Color = UserValues.BurstBrowser.Display.ColorLine2;
BurstMeta.Plots.Mixture.plotX(3).Color = UserValues.BurstBrowser.Display.ColorLine3;
BurstMeta.Plots.Mixture.plotX(4).Color = UserValues.BurstBrowser.Display.ColorLine4;
BurstMeta.Plots.Mixture.plotX(5).Color = UserValues.BurstBrowser.Display.ColorLine5;
BurstMeta.Plots.Mixture.plotX(6).Color = UserValues.BurstBrowser.Display.ColorLine6;
BurstMeta.Plots.Mixture.plotY(1).Color = UserValues.BurstBrowser.Display.ColorLine1;
BurstMeta.Plots.Mixture.plotY(2).Color = UserValues.BurstBrowser.Display.ColorLine2;
BurstMeta.Plots.Mixture.plotY(3).Color = UserValues.BurstBrowser.Display.ColorLine3;
BurstMeta.Plots.Mixture.plotY(4).Color = UserValues.BurstBrowser.Display.ColorLine4;
BurstMeta.Plots.Mixture.plotY(5).Color = UserValues.BurstBrowser.Display.ColorLine5;
BurstMeta.Plots.Mixture.plotY(6).Color = UserValues.BurstBrowser.Display.ColorLine6;
%%% Reset color of correction fits
BurstMeta.Plots.Fits.histE_donly(1).Color = [1,0,0];
BurstMeta.Plots.Fits.histS_aonly(1).Color = [1,0,0];
BurstMeta.Plots.Fits.histEBG_blueonly(1).Color = [1,0,0];
BurstMeta.Plots.Fits.histEBR_blueonly(1).Color = [1,0,0];
BurstMeta.Plots.Fits.histSBG_greenonly(1).Color = [1,0,0];
BurstMeta.Plots.Fits.histSBR_redonly(1).Color = [1,0,0];

LSUserValues(1);
PlotLifetimeInd([],[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% General Functions for plotting 2d-Histogram of data %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [H,xbins,ybins,xbins_hist,ybins_hist, bin_out] = calc2dhist(x,y,nbins,limx,limy)
%%% ouput arguments:
%%% H:                      Image Data
%%% xbins/ybins:            corrected xbins for image plot
%%% xbins_hist/ybins_hist:  use these x/y values for 1d-bar plots
%%% bin:                    a list of the x and y bins of all selected bursts
global UserValues
if nargin <2
    return;
end
%%% if number of bins is not specified, read from UserValues struct
if nargin < 3
    nbins = [UserValues.BurstBrowser.Display.NumberOfBinsX,...
        UserValues.BurstBrowser.Display.NumberOfBinsY];
end
%%% if no limits are specified, set limits to min-max
if nargin < 5
    limx = [min(x(isfinite(x))) max(x(isfinite(x)))];
    limy = [min(y(isfinite(y))) max(y(isfinite(y)))];
end

valid = (x >= limx(1)) & (x <= limx(2)) & (y >= limy(1)) & (y <= limy(2));
x = x(valid);
y = y(valid);

bin_out = NaN(size(valid,1),2);
if (~UserValues.BurstBrowser.Display.KDE) || (sum(x) == 0 || sum(y) == 0) %%% no smoothing
    %%% prepare bins
    Xn = nbins(1)+1;
    Yn = nbins(2)+1;
    xbins_hist = linspace(limx(1),limx(2),Xn);
    ybins_hist = linspace(limy(1),limy(2),Yn);
    Zbins = linspace(1, Xn+(1-1/(Yn+1)), Xn*Yn);
    % convert data
    x = floor((x-limx(1))/(limx(2)-limx(1))*(Xn-1))+1;
    y = floor((y-limy(1))/(limy(2)-limy(1))*(Yn-1))+1;
    z = x + y/(Yn) ;

    % calculate histogram
    if nargout < 6 % Bin assignment is not requested
        h = histc(z, Zbins);
    elseif nargout == 6
        [h, bin]  = histc(z, Zbins);
        [biny,binx] = ind2sub([Yn,Xn],bin);
        binx(binx == Xn) = Xn -1;
        biny(biny == Yn) = Yn -1;
        binx(binx == 0) = 1;
        biny(biny == 0) = 1;
        bin_out(valid,:) = [biny,binx];
    end
    H = reshape(h, Yn, Xn);
    
    H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
    H(end-1,:) = H(end-1,:) + H(end,:); H(end,:) = [];
    xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
    ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;
elseif UserValues.BurstBrowser.Display.KDE %%% smoothing
    [~,H, xbins_hist, ybins_hist] = kde2d([x y],nbins(1),[limx(1) limy(1)],[limx(2), limy(2)]);
    H = (H./sum(H(:))).*numel(x);
    xbins_hist = xbins_hist(1,:);
    ybins_hist = ybins_hist(:,1);
    H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
    H(end-1,:) = H(end-1,:) + H(end,:); H(end,:) = [];
    xbins = xbins_hist(1:end-1);% + diff(xbins_hist)/2;
    ybins = ybins_hist(1:end-1);% + diff(ybins_hist)/2;
    ybins = ybins';
end

function Calculate_Settings(obj,~)
global UserValues
h = guidata(obj);
%%% Sets new divider
if obj == h.Secondary_Tab_Correlation_Divider_Menu
    %%% Opens input dialog and gets value
    Divider=inputdlg('New divider:');
    if ~isempty(Divider)
        h.Secondary_Tab_Correlation_Divider_Menu.Label = ['Divider: ' cell2mat(Divider)];
        try
            g = guidata(findobj('Tag','Pam'));
            g.Cor_Divider_Menu.Label = ['Divider: ' cell2mat(Divider)];
        end
        UserValues.Settings.Pam.Cor_Divider=round(str2double(Divider));
    end
elseif obj == h.Secondary_Tab_Correlation_Standard2CMFD_Menu
    h.Correlation_Table.Data = false(size(h.Correlation_Table.Data));
    h.Correlation_Table.Data(1,2) = true;
    h.Correlation_Table.Data(3,4) = true;
    h.Correlation_Table.Data(5,6) = true;
    h.Correlation_Table.Data(7,8) = true;
    h.Correlation_Table.Data(9,12) = true;
    h.Correlation_Table.Data(10,11) = true;
elseif obj == h.Secondary_Tab_Correlation_Reset_Menu
    h.Correlation_Table.Data = false(size(h.Correlation_Table.Data));
end
%%% Saves UserValues
LSUserValues(1);

function [outv] = downsamplebin(invec,newbin)
%%% treat case where mod(numel/newbin) =/= 0
% if mod(numel(invec),newbin) ~= 0
%      %%% Discard the last bin
%     invec = invec(1:(floor(numel(invec)/newbin)*newbin));
% end
while mod(numel(invec),newbin) ~= 0
    invec(end+1) = 0;
end
outv = sum(reshape(invec,newbin,numel(invec)/newbin),1)';

function model = MultiGaussFit_1D(x,xdata)
global BurstMeta
xbins = xdata{1};
N_datapoints = xdata{2};
fixed = xdata{3};
nG = xdata{4};
plot = xdata{5};
%%% x contains the parameters for fitting in order
%%% fraction,mu1,mu2,var1,var2,cov12
%%% i.e. 6*n_species in total
if ~plot
    %%% deal with fixed parameters
    P=zeros(numel(fixed),1);
    %%% Assigns fitting parameters to unfixed parameters of fit
    P(~fixed)=x;
    %%% Assigns parameters from table to fixed parameters
    P(fixed)=BurstMeta.GaussianFit.Params(fixed);
else
    P = x';
end
%%% A total of 3 2D gauss are considered
model = zeros(1,numel(xbins));
for i = 1:nG
    pdf = P(1+(i-1)*3)*normpdf(xbins,P(2+(i-1)*3),P(3+(i-1)*3));
    model = model + pdf;
end
model = model./max([1,sum(model)]);
model = model.*N_datapoints;

function model = MultiGaussFit(x,xdata)
global BurstMeta
xbins = xdata{1};
ybins = xdata{2};
N_datapoints = xdata{3};
fixed = xdata{4};
nG = xdata{5};
plot = xdata{6};
%%% x contains the parameters for fitting in order
%%% fraction,mu1,mu2,var1,var2,cov12
%%% i.e. 6*n_species in total
if ~plot
    %%% deal with fixed parameters
    P=zeros(numel(fixed),1);
    %%% Assigns fitting parameters to unfixed parameters of fit
    P(~fixed)=x;
    %%% Assigns parameters from table to fixed parameters
    P(fixed)=BurstMeta.GaussianFit.Params(fixed);
else
    P = x';
end
%%% A total of 3 2D gauss are considered
[X,Y] = meshgrid(xbins,ybins);
model = zeros(numel(xbins),numel(ybins));
for i = 1:nG
    COV = [P(4+(i-1)*6),P(6+(i-1)*6);P(6+(i-1)*6),P(5+(i-1)*6)];
    [~,f] = chol(COV);
    if f~=0 %%% error
        COV = fix_covariance_matrix(COV);
    end
    pdf = P(1+(i-1)*6)*mvnpdf([X(:) Y(:)],P([2:3]+(i-1)*6)',COV);
    model = model + reshape(pdf,[numel(xbins),numel(ybins)]);
end
model = model./max([1,sum(sum(model))]);
model = model.*N_datapoints;

function [covNew] = fix_covariance_matrix(cov)
%find eigenvalue smaller 0
k = min(eig(cov));
%add to matrix to make positive semi-definite
A = cov - k*eye(size(cov))+1E-6; %add small increment because sometimes eigenvalues are still slightly negative (~-1E-17)

%rescale A to match the standard deviations on the diagonal

%convert to correlation matrix
Acorr = corrcov(A);
%get standard deviations
sigma = sqrt(diag(cov));

covNew = zeros(2,2);
for i = 1:2
    for j = 1:2
        covNew(i,j) = Acorr(i,j)*sigma(i)*sigma(j);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions concerning database of quick access filenames %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Database(obj,e,mode)
global UserValues BurstMeta BurstData
h = guidata(obj);

if mode == 0 %%% Checks, which key was pressed
    switch e.EventName
        case 'KeyPress'
            switch e.Key
                case 'delete'
                    mode = 2;
                case 'return'
                    %mode = 5;
            end
        case 'Action' %%% mouse-click
            switch get(gcbf,'SelectionType')
                case 'open' %%% double click
                    mode = 5;
            end
    end
end

switch mode
    case 1 %% Add files to database
        switch obj
            case h.DatabaseBB.AddFiles %% Open dialog to add files to database
                if isempty(BurstMeta.Database) %%% no data base loaded
                    if isempty(BurstData)
                        Path = UserValues.File.BurstBrowserPath;
                    else
                        Path = BurstData{BurstMeta.SelectedFile}.PathName;
                    end
                else
                    Path = BurstMeta.Database{h.DatabaseBB.List.Value,2};
                end
                Files = GetMultipleFiles({'*.bur','*.bur files'},'Choose files to add to DataBase',Path);
                if isempty(Files)
                    return;
                end
            case h.DatabaseBB.AppendLoadedFiles %% Add loaded files to database
                for i = 1:numel(BurstData) %%% loop over loaded files
                    Files{i,1} = BurstData{i}.FileName;
                    Files{i,2} = BurstData{i}.PathName;
                end
            case h.DatabaseBB.DatabaseFromFolder %% get files from all subfolders
                %%% Choose a folder and load files from all subfolders
                %%% only consider one level downwards
                FileName = cell(0);
                PathName = cell(0);
                path= fullfile(UserValues.File.BurstBrowserPath,'..',filesep);
                pathname = uigetdir(path,'Choose a folder. All *.bur files from direct subfolders will be added to the database');
                if pathname == 0
                    return;
                end
                subdir = dir(pathname);
                subdir = subdir([subdir.isdir]);
                subdir = subdir(3:end); %%% remove '.' and '..' folders
                if isempty(subdir) %%% no subfolders
                    return;
                end
                for i = 1:numel(subdir)
                    files = dir([pathname filesep subdir(i).name]);
                    files = files(3:end);
                    if ~isempty(files) %%% ensure that there are files in this subfolder
                        for j = 1:numel(files)
                            if ~files(j).isdir %%% is a file
                                %%% check for bur extension
                                [~,~,ext] = fileparts(files(j).name);
                                if strcmp(ext,'.bur') %%% check for bur extension
                                    FileName{end+1} = files(j).name;
                                    PathName{end+1} = [pathname filesep subdir(i).name];
                                end
                            else %%% is a folder, go one layer deeper
                                subfolder = [pathname filesep subdir(i).name filesep files(j).name];
                                files_subfolder = dir(subfolder);
                                files_subfolder = files_subfolder(3:end);
                                if ~isempty(files_subfolder)
                                    for k = 1:numel(files_subfolder)
                                        %%% check for bur extension
                                        [~,~,ext] = fileparts(files_subfolder(k).name);
                                        if strcmp(ext,'.bur') 
                                            FileName{end+1} = files_subfolder(k).name;
                                            PathName{end+1} = subfolder;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if isempty(FileName)
                    %%% no files have been found
                    return;
                end
                Files(:,1) = FileName;
                Files(:,2) = PathName;
                %%% remove existing database
                BurstMeta.Database = {};
                h.DatabaseBB.List.String = {};
                %%% set path
                UserValues.File.BurstBrowserPath = pathname;
        end  
        %%%check for existing files and append new files to database list
        new = true(size(Files,1),1);
        if ~isempty(BurstMeta.Database) % ensure database exists
            for i = 1:size(Files,1)
                exist_name = find(strcmp(Files{i,1},BurstMeta.Database(:,1)));
                if ~isempty(exist_name)
                    if any(strcmp(Files{i,2},BurstMeta.Database(exist_name,2)))
                        new(i) = false;
                    end
                end
            end
        end
        Files = Files(new,:);
        %% Add files to database
        % add new files to database
        for i = 1:size(Files,1)
            BurstMeta.Database{end+1,1} = Files{i,1};
            BurstMeta.Database{end,2} = Files{i,2};
            h.DatabaseBB.List.String{end+1} = [Files{i,1} ' (path:' Files{i,2} ')'];
        end
        if size(BurstMeta.Database, 1) > 0
            % reenable save
            h.DatabaseBB.Save.Enable = 'on';
        end
    case 2 %% Delete files from database
        %remove rows from list
        h.DatabaseBB.List.String(h.DatabaseBB.List.Value) = [];
        %remove rows from database
        BurstMeta.Database(h.DatabaseBB.List.Value, :) = [];
        h.DatabaseBB.List.Value = 1;
        if size(BurstMeta.Database, 1) < 1
            % no files are left
            h.DatabaseBB.Save.Enable = 'off';
        end
    case 3 %% Load database
        Path = UserValues.File.BurstBrowserDatabasePath;
        [FileName, Path] = uigetfile({'*.bdb', 'Burst Database file (*.bdb)';'*.dab','PAM Database file (*.dab)'}, 'Choose database to load',Path,'MultiSelect', 'on');
        if ~iscell(FileName)
            if  FileName == 0
                return;
            end
        end
        if ~iscell(FileName)
            FileName = {FileName};
        end
        %%% store path in BurstMeta
        UserValues.File.BurstBrowserDatabasePath = Path;
        DB = [];
        list_of_files = [];
        for i = 1:numel(FileName)
            db = load('-mat',fullfile(Path,FileName{i})); db = db.s;
            %%% do check of database
            % check for non *.bur files
            % check for non-existing files/invalid paths
            valid = true(size(db.database,1),1);
            for i = 1:size(db.database,1)
                if ~strcmp(db.database{i,1}(end-3:end),'.bur') || ~(exist([db.database{i,2} filesep db.database{i,1}],'file')==2)
                    valid(i) = false;
                end
            end
            if sum(valid) == 0
                disp('Database file does not contain *.bur files or files are not accessible.');
                return;
            end
            % remove invalid
            db.str = db.str(valid); db.database=db.database(valid,:);
            DB = [DB; db.database];
            list_of_files  = [list_of_files; db.str];
            clear db;
        end
        BurstMeta.Database = DB;
        h.DatabaseBB.List.String = list_of_files;
        h.DatabaseBB.List.Value = 1;
        if size(BurstMeta.Database, 1) > 0
            % reenable save
            h.DatabaseBB.Save.Enable = 'on';
        end
        LSUserValues(1);
    case 4 %% Save complete database
        Path = UserValues.File.BurstBrowserDatabasePath;
        [File, Path] = uiputfile({'*.bdb', 'Database file (*.bdb)'}, 'Save database', Path);
        if File == 0
            return;
        end
        s = struct;
        s.database = BurstMeta.Database;
        s.str = h.DatabaseBB.List.String;
        save(fullfile(Path,File),'s');
        %%% store path in UserValues
        UserValues.File.BurstBrowserDatabasePath = Path;
        LSUserValues(1);
    case 5 %% Loads selected files into BurstBrowser
        h.Progress.Text.String='Loading new files';
        Load_Burst_Data_Callback(obj,[]);
end
if mode ~= 5
    %%% Update UserValues
    UserValues.BurstBrowser.DatabaseString = h.DatabaseBB.List.String;
    UserValues.BurstBrowser.Database = BurstMeta.Database;
end

function UpdateSpeciesList(h)
global BurstData BurstMeta
h.SpeciesList.Root = uitreenode('v0',h.SpeciesList.Tree,'Data Tree',[] ,false);
h.SpeciesList.Root.setIcon(im2java(h.icons.iconBurst));
for f = 1:numel(BurstData)
    % populate uitree
    h.SpeciesList.File(f) = uitreenode('v0', h.SpeciesList.Tree, BurstData{f}.FileName, [], false);
    h.SpeciesList.File(f).setIcon(im2java(h.icons.iconFile));
    for i = 1:size(BurstData{f}.SpeciesNames,1)
        %%% make uitreenode for every subgroup
        h.SpeciesList.Species{f}(i) = uitreenode('v0', h.SpeciesList.Tree, BurstData{f}.SpeciesNames{i,1}, [], false);
        h.SpeciesList.Species{f}(i).setIcon(im2java(h.icons.iconSpecies));
        %%% add subnodes for every subspecies
        for j = 2:size(BurstData{f}.SpeciesNames,2)
            if ~isempty(BurstData{f}.SpeciesNames{i,j})
                h.SpeciesList.Nodes{f}{i}(j) = uitreenode('v0', h.SpeciesList.Tree, BurstData{f}.SpeciesNames{i,j}, [], true);
                h.SpeciesList.Species{f}(i).add(h.SpeciesList.Nodes{f}{i}(j));
                h.SpeciesList.Nodes{f}{i}(j).setIcon(im2java(h.icons.iconSubspecies));
            end
        end
        h.SpeciesList.File(f).add(h.SpeciesList.Species{f}(i));
    end
    h.SpeciesList.Root.add(h.SpeciesList.File(f));
end
h.SpeciesList.Tree.setRoot(h.SpeciesList.Root);

%%% expand all
h.SpeciesList.Tree.expand(h.SpeciesList.Root);
for f = 1:numel(BurstData)
    h.SpeciesList.Tree.expand(h.SpeciesList.File(f));
    %for i = 1:numel(h.SpeciesList.Species{f})
    %    h.SpeciesList.Tree.expand(h.SpeciesList.Species{f}(i));
    %end
end

guidata(h.BurstBrowser,h);

set(h.SpeciesList.Tree,'NodeSelectedCallback',@SpeciesList_ButtonDownFcn);
%%% set selected node according to Stored Selection
if all(BurstData{BurstMeta.SelectedFile}.SelectedSpecies == [0,0])
    h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.File(BurstMeta.SelectedFile));
elseif BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) == 1
    h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(max([1,BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)])));
elseif BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) > 1
    try
        h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)).getChildAt(BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2)-2));
    catch % by going to parent species
        h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(max([1,BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)])));
    end
end

function SpeciesListContextMenuCallback(hTree,eventData,jmenu)
if eventData.isMetaDown  % right-click is like a Meta-button
  % Get the clicked node
  clickX = eventData.getX;
  clickY = eventData.getY;
  jtree = eventData.getSource;
  
  % Display the (possibly-modified) context menu
  jmenu.show(jtree, clickX, clickY);
  jmenu.repaint;
end

function UpdateGUIOptions(obj,~,h)
global UserValues BurstMeta
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end
if obj == h.NumberOfBinsXEdit
    nbinsX = str2double(h.NumberOfBinsXEdit.String);
    if ~isnan(nbinsX)
        if nbinsX > 0
            UserValues.BurstBrowser.Display.NumberOfBinsX = nbinsX;
        else
            h.NumberOfBinsXEdit.String = UserValues.BurstBrowser.Display.NumberOfBinsX;
        end
    else
        h.NumberOfBinsXEdit.String = num2str(UserValues.BurstBrowser.Display.NumberOfBinsX);
    end        
    UpdateLifetimePlots(obj,[]);
end
if obj == h.NumberOfBinsYEdit
    nbinsY = str2double(h.NumberOfBinsYEdit.String);
    if ~isnan(nbinsY)
        if nbinsY > 0
            UserValues.BurstBrowser.Display.NumberOfBinsY = nbinsY;
        else
            h.NumberOfBinsYEdit.String = UserValues.BurstBrowser.Display.NumberOfBinsY;
        end
    else
        h.NumberOfBinsYEdit.String = num2str(UserValues.BurstBrowser.Display.NumberOfBinsY);
    end
    UpdateLifetimePlots(obj,[]);
end
if obj == h.logX_checkbox
    UserValues.BurstBrowser.Display.logX = obj.Value;
end
if obj == h.logY_checkbox
    UserValues.BurstBrowser.Display.logY = obj.Value;
end
if obj == h.NumberOfContourLevels_edit
    nClevels = str2double(h.NumberOfContourLevels_edit.String);
    if ~isnan(nClevels)
        if nClevels > 1
            UserValues.BurstBrowser.Display.NumberOfContourLevels = nClevels;
        else
            h.NumberOfContourLevels_edit.String = UserValues.BurstBrowser.Display.NumberOfContourLevels;
        end
    else
        h.NumberOfContourLevels_edit.String = num2str(UserValues.BurstBrowser.Display.NumberOfContourLevels);
    end
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
end
if obj == h.ZScale_Intensity
    UserValues.BurstBrowser.Display.ZScale_Intensity = obj.Value;
end
if obj == h.PlotOffset_edit
    switch UserValues.BurstBrowser.Display.PlotType
        case 'Contour'
            ContourOffset = str2double(h.PlotOffset_edit.String);
            if ~isnan(ContourOffset)
                if ContourOffset >=0 && ContourOffset<=100
                    UserValues.BurstBrowser.Display.ContourOffset = ContourOffset;
                else
                    h.PlotOffset_edit.String = UserValues.BurstBrowser.Display.ContourOffset;
                end
            else
                h.PlotOffset_edit.String = num2str(UserValues.BurstBrowser.Display.ContourOffset);
            end
        case 'Image'
            ImageOffset = str2double(h.PlotOffset_edit.String);
            if ~isnan(ImageOffset)
                if ImageOffset >=0 && ImageOffset<=100
                    UserValues.BurstBrowser.Display.ImageOffset = ImageOffset;
                else
                    h.PlotOffset_edit.String = UserValues.BurstBrowser.Display.ImageOffset;
                end
            else
                h.PlotOffset_edit.String = num2str(UserValues.BurstBrowser.Display.ImageOffset);
            end
    end
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
end
if obj == h.ColorMapPopupmenu
    if ~strcmp(h.ColorMapPopupmenu.String{h.ColorMapPopupmenu.Value},'jetvar')
        UserValues.BurstBrowser.Display.ColorMap = h.ColorMapPopupmenu.String{h.ColorMapPopupmenu.Value};
    else %%% custom colormap
        UserValues.BurstBrowser.Display.ColorMap = jetvar;
    end
end
if obj == h.SmoothKDE
    UserValues.BurstBrowser.Display.KDE = h.SmoothKDE.Value;
    UpdateLifetimePlots(obj,[]);
end
if obj == h.ColorMapInvert
    UserValues.BurstBrowser.Display.ColorMapInvert = h.ColorMapInvert.Value;
end
if obj == h.BrightenColorMap_edit
    beta = str2double(h.BrightenColorMap_edit.String);
    if ~isnan(beta)
        if beta > 1
            h.BrightenColorMap_edit.String = 1;
            UserValues.BurstBrowser.Display.BrightenColorMap = 1;
        elseif beta < -1
            h.BrightenColorMap_edit.String = -1;
            UserValues.BurstBrowser.Display.BrightenColorMap = -1;
        else
            UserValues.BurstBrowser.Display.BrightenColorMap = beta;
        end
    else
        h.BrightenColorMap_edit.String = num2str(UserValues.BurstBrowser.Display.BrightenColorMap);
    end
end
if obj == h.PlotGridAboveDataCheckbox
    %%% change layer property of 2d axes to "top" or "bottom"
    UserValues.BurstBrowser.Display.PlotGridAboveData = obj.Value;
    switch obj.Value
        case 0
            layer = 'bottom';
        case 1
            layer = 'top';
    end
    set([h.axes_general,h.axes_EvsTauGG,h.axes_EvsTauRR,h.axes_rGGvsTauGG,h.axes_rRRvsTauRR,...
        h.axes_E_BtoGRvsTauBB,h.axes_rBBvsTauBB,h.axes_lifetime_ind_2d],'Layer',layer);
end
if obj == h.Restrict_EandS_Range
    UserValues.BurstBrowser.Display.Restrict_EandS_Range = obj.Value;
end
if obj == h.MarkerSize_edit
    markersize = str2double(h.MarkerSize_edit.String);
    if ~isnan(markersize)
        UserValues.BurstBrowser.Display.MarkerSize = markersize;
        fields = fieldnames(BurstMeta.Plots); %%% loop through h structure
        for i = 1:numel(fields)
            if ~isempty(BurstMeta.Plots.(fields{i}))
                if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                    if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                        if numel(BurstMeta.Plots.(fields{i}))>2
                            BurstMeta.Plots.(fields{i})(3).SizeData = markersize;
                        end
                    end
                end
            end
        end
    else
        h.MarkerSize_edit.String = num2str(UserValues.BurstBrowser.Display.MarkerSize);
    end
    PlotLifetimeInd([],[],h);
end
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Updates the Parameter List after change of data %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_ParameterList(obj,~,h)
global BurstData BurstMeta
if nargin == 2
    if isempty(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
    else
        h = guidata(obj);
    end
end

file = BurstMeta.SelectedFile;
if numel(h.ParameterListX.String) ~= numel(BurstData{file}.NameArray) || any(~strcmp(h.ParameterListX.String',BurstData{file}.NameArray))
    paramX = h.ParameterListX.String{h.ParameterListX.Value};
    h.ParameterListX.String = BurstData{file}.NameArray;
    val = find(strcmp(BurstData{file}.NameArray,paramX));
    if ~isempty(val)
        h.ParameterListX.Value = val;
    else
        h.ParameterListX.Value = 1;
    end
end

if numel(h.ParameterListY.String) ~= numel(BurstData{file}.NameArray)
    paramY = h.ParameterListY.String{h.ParameterListY.Value};
    h.ParameterListY.String = BurstData{file}.NameArray;
    val = find(strcmp(BurstData{file}.NameArray,paramY));
    if ~isempty(val)
        h.ParameterListY.Value = val;
    else
        h.ParameterListY.Value = 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Copies Gauss Fit Data to Clipboard %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CopyFitresultToClipboard(obj,~)
global BurstMeta
if ~isfield(BurstMeta,'Fitting')
    return;
end
res = BurstMeta.Fitting.FitResult;
h = guidata(obj);

switch BurstMeta.Fitting.FitType
    case '1D'
        Header = {'Fraction','Mean(X)','sigma(X)'};
    case '2D'
        Header = {'Fraction','Mean(X)','Mean(Y)','sigma(XX)','sigma(YY)','COV(XY)'};
end

Info = cell(2,numel(Header));
switch h.Fit_GaussianMethod_Popupmenu.Value
    case 1 %MLE
        Info(1:2,1:2) = {'NegativeLogLikelihood','BIC';res(end-1),res(end)};
        res(end-1:end) = [];
    case 2 %LSQ
        Info(1:2,1) = {'Chi2';res(end)};
        res(end) = [];
end
Header = [Info;Header];
data = [];
switch BurstMeta.Fitting.FitType
    case '1D'
        nG = numel(res)/3;
        for i = 1:nG
            data = [data;num2cell(res((1:3)+(i-1)*3))];
        end
    case '2D'
        nG = numel(res)/6;
        for i = 1:nG
            data = [data;num2cell(res((1:6)+(i-1)*6))];
        end
end
Mat2clip([Header;data]);

function DisplayFileInfo(~,~)
global BurstMeta BurstData

fid = fopen(fullfile(BurstData{BurstMeta.SelectedFile}.PathName,[BurstData{BurstMeta.SelectedFile}.FileName(1:end-3) 'txt']));
if fid == -1
    disp('No file info found.');
    return;
end
screensize = get(0,'screensize');

f = figure('menu','none','toolbar','none',...
    'numbertitle','off','name','',...
    'Units','pixels',...
    'Position',[screensize(3)/2-300,screensize(4)/2-400,600,800]);
ph = uipanel(f,'Units','normalized','position',[0 0 1 1],'title',...
    ['File Info for ' BurstData{BurstMeta.SelectedFile}.FileName],'FontSize',12);
lbh = uicontrol(ph,'style','edit','Units','normalized','position',...
    [0 0 1 1],'FontSize',12,'HorizontalAlignment','left');
indic = 1;
while 1
     tline = fgetl(fid);
     if ~ischar(tline), 
         break
     end
     strings{indic}=tline; 
     indic = indic + 1;
end
fclose(fid);
set(lbh,'Max',numel(strings));
set(lbh,'string',strings);

function linkaxes_y(~,obj)
h = guidata(obj.AffectedObject);
switch obj.AffectedObject
    case h.axes_general
        %%% update XLim of 1d y axis
        if any(h.axes_general.YLim ~= h.axes_1d_y.XLim)
            h.axes_1d_y.XLim = h.axes_general.YLim;
        end
    case h.axes_1d_y
        %%% update YLim of 2d axis
        if any(h.axes_general.YLim ~= h.axes_1d_y.XLim)
            h.axes_general.YLim = h.axes_1d_y.XLim;
        end
end

function Open_Notepad(~,~)
%%% Check whether notepad is open
notepad = findobj('Tag','BurstBrowser_Notepad');
if isempty(notepad)
    Notepad('BurstBrowser');
else
    figure(notepad);
end

function CalculateGammaGUI(obj,~)
%%% opens figure with table to put in values and button to calculate gamma
f = findobj('Tag','CalculateGammaFigure');
if isempty(f)
    f = figure('Tag','CalculateGammaFigure','Menubar','none','Toolbar','none','Name','E-S table','NumberTitle','off','Units','pixels');
    m = uimenu('Parent',f,'Label','Calculate','Callback',@CalculateGamma);
    t = uitable('Parent',f,'ColumnName',{'E','S','<html>&sigma;E</html>','<html>&sigma;S</html>'},...
        'ColumnFormat',{'numeric','numeric','numeric','numeric'},...
        'Units','normalized','Position',[0,0,1,1],'Tag','CalculateGammaTable',...
        'Data',cell(10,4),'ColumnEditable',true);
    extent = t.Extent;
    f.Position(3) = f.Position(3)*extent(3);
    f.Position(4) = f.Position(4)*extent(4);
else
    figure(f);
end

function CalculateGamma(obj,~)
%%% read out the data from the table and calculate gamma
t = findobj('Tag','CalculateGammaTable');
data = t.Data;
%%% remove NaNs
for i = 1:numel(data)
    if isnan(data{i})
        data{i} = [];
    end
end
try
    data = cell2mat(data);
catch
    m = msgbox('Input data has the wrong format.');
end
if size(data,2) < 4 %%% no error specified
    gamma_from_ES(data(:,1),data(:,2));
else
    gamma_from_ES(data(:,1),data(:,2),data(:,3),data(:,4));
end

function path = getPrintPath()
global UserValues BurstData BurstMeta
if UserValues.BurstBrowser.Settings.UseFilePathForExport
    path = BurstData{BurstMeta.SelectedFile}.PathName;
else
    path = UserValues.BurstBrowser.PrintPath;
end

function Export_to_Tracy(obj,~)
global BurstTCSPCData BurstMeta
answer = inputdlg('Time resolution [ms]:','Specify binning',1,{'1'});
answer = str2double(answer{1});
if ~isfinite(answer)
    disp('Invalid binning.');
    return;
end
if isempty(BurstTCSPCData{BurstMeta.SelectedFile})
    Load_Photons();
end
export_to_tracy(answer);

function Param_to_clip(~,~)
global BurstData BurstMeta
%%% copy the currently selected x-parameter to clipboard
h = guidata(gcbo);
%%% get the parameter
data = BurstData{BurstMeta.SelectedFile}.DataArray(BurstData{BurstMeta.SelectedFile}.Selected,strcmp(h.ParameterListX.String{h.ParameterListX.Value},BurstData{BurstMeta.SelectedFile}.NameArray));
Mat2clip(data);

function PCA_analysis(obj,~)
global BurstData
h = guidata(obj);
%%% Perform Principal Component Analysis to find differences between data
%%% sets and indentify parameters with high variance/differences between
%%% data sets, i.e. "sensitive" parameters.

%%% get selection of species list
[file_n,species_n,subspecies_n,sel] = get_multiselection(h);
%%% read out data
datatoplot = cell(numel(file_n),1);
for i = 1:numel(file_n)
    [~,datatoplot{i}] = UpdateCuts([species_n(i),subspecies_n(i)],file_n(i));
end

%%% PCA analysis on multiple data sets
%%% pooling of all data sets to generate joint principal components
%%% parameters: E,S,tauD,tauA,rD,rA,(ALEX2CDE,FRET2CDE,Duration,NumberOfPhotons)
param = [1,2,5,6,7,8];%,10,12];%,13,15]; (Better: read out parameter indices from name array)
data = vertcat(datatoplot{:});
for i = 1:numel(datatoplot)
    n(i)=size(datatoplot{i},1);
end
id = [];
for i = 1:numel(n)
    id = [id, i*ones(1,n(i))];
end
data_val = data(:,param);
[coeff,score,latent] = pca(data_val);

%%% do thresholding on PC1 and PC2
val = true(size(score,1),1);
alpha = 0.3; %99.7 percentile, i.e. 3 sigma
val = val & (score(:,1) > prctile(score(:,1),alpha/2)) &...
    (score(:,1) < prctile(score(:,1),100-alpha/2)) &...
    (score(:,2) > prctile(score(:,2),alpha/2)) &...
    (score(:,2) < prctile(score(:,2),100-alpha/2));

data_val = data_val(val,:);
id_val = id(val);
[coeff,score,latent] = pca(data_val);

%%% plot in different colors
f = figure('Units','pixel','Position',[100,100,1000,400],'Color',[1,1,1]);
ax(1) = subplot(1,2,1);
hold on;
color = lines(numel(datatoplot));
%%% define scatter colors
scat_col = color(id_val,:);
%%% randomize scatter data clouds
order = randperm(size(score,1));
scatter(score(order,1),score(order,2),10,scat_col(order,:),'Marker','.','MarkerFaceColor',color(i,:));
for i = 1:numel(datatoplot)
    p(i) = plot(mean(score(id_val==i,1)),mean(score(id_val==i,2)),'o','MarkerFaceColor',color(i,:),'MarkerEdgeColor','k','MarkerSize',10);
end
xlabel('PC1');ylabel('PC2');
axis('tight');
%%% add legend
[file_n,species_n,subspecies_n,sel] = get_multiselection(h);
num_species = numel(file_n);
str = cell(num_species,1);
for i = 1:num_species
    %%% extract name
    name = BurstData{file_n(i)}.FileName;
    if (species_n(i) ~= 0)
        if (subspecies_n(i) ~= 1) %%% we have a subspecies selected
            name = [name,'/', char(sel(i).getParent.getName),'/',char(sel(i).getName)];
        else %%% we have a species selected 
            name = [name,'/', char(sel(i).getName)];
        end
    end
    str{i} = strrep(name,'_',' ');  
end
hl = legend(p,str,'Interpreter','none','FontSize',12,'Box','off','Color','none');

ax(2) = subplot(1,2,2);
b = bar(coeff(:,1:2));legend('PC1','PC2');
b(1).FaceColor = [0.7,0.7,0.7];
b(2).FaceColor = [0.3,0.3,0.3];
set(gca,'XTickLabel',{'E','S','tauD','tauA','rD','rA'});
ylabel('weight');
xlim([0.5,6.5]);

c = get(f,'Children');
for i = 1:numel(c)
    c(i).Units = 'pixel';
    c(i).Position(2) = c(i).Position(2) + 10;
end
f.Position(4) = f.Position(4)+50;
FontSize = 14; if ispc; FontSize = FontSize/1.25;end
set(ax,'FontSize',FontSize);
set(ax,'Color',[1,1,1]);
hl.Position(2) = ax(1).Position(2)+ax(1).Position(4)+10;