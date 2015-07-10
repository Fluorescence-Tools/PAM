function BurstBrowser(~,~)

hfig=findobj('Name','BurstBrowser');
global UserValues %BurstMeta BurstData BurstTCSPCData
addpath([pwd filesep 'TauFit Models']);
LSUserValues(0);
Look=UserValues.Look;
if isempty(hfig)
    %% Define main window
    h.BurstBrowser = figure(...
        'Units','normalized',...
        'Name','BurstBrowser',...
        'NumberTitle','off',...
        'MenuBar','none',...
        'defaultUicontrolFontName','Times',...
        'defaultAxesFontName','Times',...
        'defaultTextFontName','Times',...
        'OuterPosition',[0.01 0.05 0.98 0.95],...
        'UserData',[],...
        'Visible','on',...
        'Tag','BurstBrowser',...
        'Toolbar','figure',...
        'CloseRequestFcn',@Close_BurstBrowser);
    %'WindowScrollWheelFcn',@Bowser_Wheel,...
    %'KeyPressFcn',@Bowser_KeyPressFcn,...
    whitebg(h.BurstBrowser,Look.Axes);
    set(h.BurstBrowser,'Color',Look.Back);
   
    %%% define menu items
    h.File_Menu = uimenu(...
        'Parent',h.BurstBrowser,...
        'Label','File',...
        'Tag','File_Menu',...
        'Enable','off');
    %%% Load Burst Data Callback
    h.Load_Bursts = uimenu(...
        'Parent',h.File_Menu,...
        'Label','Load Burst Data',...
        'Callback',@Load_Burst_Data_Callback,...
        'Tag','Load_Burst_Data');
    
    %%% Save Analysis State
    h.Save_Bursts = uimenu(...
        'Parent',h.File_Menu,...
        'Label','Save Analysis State',...
        'Callback',@Save_Analysis_State_Callback,...
        'Tag','Save_Analysis_State');
    
    %define tabs
    %main tab
    h.Main_Tab = uitabgroup(...
        'Parent',h.BurstBrowser,...
        'Tag','Main_Tab',...
        'Units','normalized',...
        'Position',[0 0 0.65 1],...
        'SelectionChangedFcn',@MainTabSelectionChange);
    
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
    
    h.LifeTime_Menu = uicontextmenu;
    h.ExportLifetime_Menu = uimenu(...
        'Parent',h.LifeTime_Menu,...
        'Label','Export Lifetime Plots',...
        'Tag','ExportLifetime_Menu',...
        'Callback',@ExportGraphs);
    h.ExportEvsTau_Menu = uimenu(...
        'Parent',h.LifeTime_Menu,...
        'Label','Export E vs TauGG Plot',...
        'Tag','ExportEvsTau_Menu',...
        'Callback',@ExportGraphs);
    
    h.Main_Tab_Lifetime= uitab(h.Main_Tab,...
        'title','Lifetime',...
        'Tag','Main_Tab_Lifetime'...
        );
    
    h.MainTabLifetimePanel = uibuttongroup(...
        'Parent',h.Main_Tab_Lifetime,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabLifetimePanel',...
        'UIContextMenu',h.LifeTime_Menu);
    
    %%% sub-ensemble TCSPC tab
    h.Main_Tab_TauFit= uitab(h.Main_Tab,...
        'title','Lifetime Fitting',...
        'Tag','Main_Tab_TauFit'...
        );
    
    h.MainTabTauFitPanel = uibuttongroup(...
        'Parent',h.Main_Tab_TauFit,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabTauFitPanel');
    
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
        'Position',[0 0 0.5 0.5]);
    
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
        'Position',[0.5 0 0.5 0.5]);
    
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
        'Position',[0.65 0.03 0.35 0.97]);
    
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
        'title','Corrections/Fitting',...
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
    
    h.Secondary_Tab_Correlation= uitab(...
        'Parent',h.Secondary_Tab,...
        'title','Correlate',...
        'Tag','Secondary_Tab_Correlation'...
        );
    
    h.SecondaryTabCorrelationPanel = uibuttongroup(...
        'Parent',h.Secondary_Tab_Correlation,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','SecondaryTabCorrelationPanel');
    
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
    
    %%% Species List Right-click Menu
    h.SpeciesListMenu = uicontextmenu;
    
    h.AddSpeciesMenuItem = uimenu(...
        'Parent',h.SpeciesListMenu,...
        'Label','Add Species',...
        'Tag','AddSpeciesMenuItem',...
        'Callback',@AddSpecies);
    
    h.RemoveSpeciesMenuItem = uimenu(...
        'Parent',h.SpeciesListMenu,...
        'Label','Remove Species',...
        'Tag','RemoveSpeciesMenuItem',...
        'Callback',@RemoveSpecies);
    
    h.RenameSpeciesMenuItem = uimenu(...
        'Parent',h.SpeciesListMenu,...
        'Label','Rename Species',...
        'Tag','RenameSpeciesMenuItem',...
        'Callback',@RenameSpecies);
    
    h.ExportSpeciesToPDAMenuItem = uimenu(...
        'Parent',h.SpeciesListMenu,...
        'Label','Export Species to PDA',...
        'Tag','ExportSpeciesToPDAMenuItem',...
        'Callback',@Export_To_PDA);
    
    h.ExportMicrotimePattern = uimenu(...
        'Parent',h.SpeciesListMenu,...
        'Label','Export Microtime Pattern',...
        'Tag','ExportMicrotimePatternMenuItem',...
        'Callback',@Export_Microtime_Pattern);
    
    h.ExportSpeciesToPDA_2C_for3CMFD_MenuItem = uimenu(...
        'Parent',h.SpeciesListMenu,...
        'Label','Export Species to 2C-PDA',...
        'Tag','ExportSpeciesToPDA_2C_for3CMFD_MenuItem',...
        'Callback',@Export_To_PDA,...
        'Visible','off');
    
    h.DoTimeWindowAnalysis = uimenu(...
        'Parent',h.SpeciesListMenu,...
        'Label','Time Window Analysis',...
        'Tag','DoTimeWindowAnalysis',...
        'Callback',@Time_Window_Analysis);
    
    %%% Define Species List
    h.SpeciesList = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Fore,...
        'KeyPressFcn',[],...
        'Max',5,...
        'Position',[0 0 1 0.2],...
        'Style','listbox',...
        'Tag','SpeciesList',...
        'UIContextMenu',h.SpeciesListMenu);
    %'ButtonDownFcn',@List_ButtonDownFcn,...
    %'CallBack',@List_ButtonDownFcn,...
    % for right click selection to work, we need to access the underlying
    % java object
    %see: http://undocumentedmatlab.com/blog/setting-listbox-mouse-actions
    drawnow;
    jScrollPane = findjobj(h.SpeciesList);
    jSpeciesList = jScrollPane.getViewport.getComponent(0);
    jSpeciesList = handle(jSpeciesList, 'CallbackProperties');
    set(jSpeciesList, 'MousePressedCallback',{@SpeciesList_ButtonDownFcn,h.SpeciesList});
    
    %define the cut table
    cname = {'min','max','active','delete'};
    cformat = {'numeric','numeric','logical','logical'};
    ceditable = [true true true true];
    table_dat = {'','',false,false};
    cwidth = {'auto','auto',50,50};
    
    h.CutTable = uitable(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'ForegroundColor',Look.Fore,...
        'Position',[0 0.2 1 0.3],...
        'Tag','CutTable',...
        'ColumnName',cname,...
        'ColumnFormat',cformat,...
        'ColumnEditable',ceditable,...
        'Data',table_dat,...
        'ColumnWidth',cwidth,...
        'CellEditCallback',@CutTableChange);
    
    %define the parameter selection listboxes
    h.ParameterListX = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Fore,...
        'Max',5,...
        'Position',[0 0.55 0.5 0.45],...
        'Style','listbox',...
        'Tag','ParameterListX',...
        'Enable','on');
    
    h.ParameterListY = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Fore,...
        'Max',5,...
        'Position',[0.5 0.55 0.5 0.45],...
        'Style','listbox',...
        'Tag','ParameterListY',...
        'Enable','on');
    
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
    
    %%% Define MultiPlot Button
    h.MultiPlotButton = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.51 0.3 0.03],...
        'Style','pushbutton',...
        'Tag','MutliPlotButton',...
        'String','Plot multiple species',...
        'FontSize',12,...
        'Callback',@MultiPlot);
    
    %define manual cut button
    h.CutButton = uicontrol(...
        'Parent',h.SecondaryTabSelectionPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.6 0.51 0.2 0.03],...
        'Style','pushbutton',...
        'Tag','CutButton',...
        'String','Manual Cut',...
        'FontSize',12,...
        'Callback',@ManualCut);
    %% Secondary tab corrections
    %%% Buttons
    %%% Button to determine CrossTalk and DirectExcitation
    h.DetermineCorrectionsButton = uicontrol(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.95 0.4 0.03],...
        'Style','pushbutton',...
        'Tag','DetermineCorrectionsButton',...
        'String','Determine Corrections',...
        'FontSize',12,...
        'Callback',@DetermineCorrections);
    
    %%% Button to fit gamma
    h.FitGammaButton = uicontrol(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.91 0.4 0.03],...
        'Style','pushbutton',...
        'Tag','FitGammaButton',...
        'String','Fit Gamma (2 species or more)',...
        'FontSize',12,...
        'Callback',@DetermineCorrections);
    
    %%% Button for manual gamma determination
    h.DetermineGammaManuallyButton = uicontrol(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.86 0.4 0.03],...
        'Style','pushbutton',...
        'Tag','DetermineGammaManuallyButton',...
        'String','Determine Gamma Manually',...
        'FontSize',12,...
        'Callback',@DetermineGammaManually);
    
    %%% Button to determine gamma from lifetime
    h.DetermineGammaLifetimeTwoColorButton = uicontrol(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.91 0.5 0.03],...
        'Style','pushbutton',...
        'Tag','DetermineGammaLifetimeTwoColorButton',...
        'String','Determine Gamma from Lifetime (2C)',...
        'FontSize',12,...
        'Callback',@DetermineGammaLifetime);
    
    h.DetermineGammaLifetimeThreeColorButton = uicontrol(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.86 0.5 0.03],...
        'Style','pushbutton',...
        'Tag','DetermineGammaLifetimeThreeColorButton',...
        'String','Determine Gamma from Lifetime (3C)',...
        'FontSize',12,...
        'Callback',@DetermineGammaLifetime,...
        'Visible','off');
    
    %%% Button to apply custom correction factors
    h.ApplyCorrectionsButton = uicontrol(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.81 0.4 0.03],...
        'Style','pushbutton',...
        'Tag','ApplyCorrectionsButton',...
        'String','Apply Corrections',...
        'FontSize',12,...
        'Callback',@ApplyCorrections);
    
    %%% Checkbox to enabel/disable beta factor Stoichiometry corrections
    %%% (Corrects S to be 0.5 for double labeled)
    h.UseBetaCheckbox = uicontrol(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.76 0.4 0.03],...
        'Style','checkbox',...
        'Tag','UseBetaCheckbox',...
        'Value',UserValues.BurstBrowser.Corrections.UseBeta,...
        'String','Use Beta Correction of Stoichiometry',...
        'FontSize',12,...
        'Callback',@ApplyCorrections);
    
    %%% Table for Corrections factors
    Corrections_Rownames = {'Gamma','Beta','Crosstalk','Direct Exc.','G factor Green','G factor Red','l1','l2',...
        'BG GG par','BG GG perp','BG GR par',...
        'BG GR perp','BG RR par','BG RR perp'};
    Corrections_Columnnames = {'Correction Factors'};
    Corrections_Editable = true;
    Corrections_Data = {1;1;0;0;0;0;0:0;0;0;1;1;0};
    Corrections_Columnformat = {'numeric'};
    
    h.CorrectionsTable = uitable(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'Tag','CorrectionsTable',...
        'Position',[0 0.36 0.7 0.4],...
        'Data',Corrections_Data,...sdfgh
        'RowName',Corrections_Rownames,...
        'ColumnName',Corrections_Columnnames,...
        'ColumnEditable',Corrections_Editable,...
        'ColumnFormat',Corrections_Columnformat,...
        'ColumnWidth','auto',...
        'CellEditCallback',@UpdateCorrections,...
        'ForegroundColor',Look.Fore);
    
    h.TGX_TRR_text = uicontrol('Style','text',...
        'Tag','T_Threshold_Text',...
        'String','Threshold |TGX-TRR|',...
        'FontSize',12,...
        'Units','normalized',...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Position',[0.45 0.96 0.35 0.02],...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore);
    
    h.T_Threshold_Edit =  uicontrol('Style','edit',...
        'Tag','T_Threshold_Edit',...
        'String','0.1',...
        'FontSize',12,...
        'Units','normalized',...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Position',[0.8 0.96 0.15 0.02],...
        'BackgroundColor',Look.Control,...
        'ForegroundColor',Look.Fore);
    
    %%% Uipanel for fitting lifetime-related quantities
    h.FitLifetimeRelatedPanel = uipanel(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'Position',[0 0 1 0.3],...
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
        'Position',[0 0.85 0.4 0.1],...
        'Style','pushbutton',...
        'Tag','FitAnisotropyButton',...
        'String','Fit Anisotropy',...
        'FontSize',12,...
        'Callback',@UpdateLifetimeFits);
    
    h.ManualAnisotropyButton = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.75 0.4 0.1],...
        'Style','pushbutton',...
        'Tag','ManualAnisotropyButton',...
        'String','Manual Perrin Fit',...
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
        'String','r0 Green',...
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
        'FontSize',12,...
        'Callback',@UpdateCorrections);
    
    h.r0Red_text = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.5 0.84 0.2 0.07],...
        'Style','text',...
        'Tag','r0RR_text',...
        'String','r0 Red',...
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
        'String','r0 Blue',...
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
        'FontSize',12,...
        'Visible','off',...
        'Callback',@UpdateCorrections);
    
    h.PlotStaticFRETButton = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.55 0.4 0.1],...
        'Style','pushbutton',...
        'Tag','PlotStaticFRETButton',...
        'String','Plot Static FRET Line',...
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
        'Position',[0.4 0.55 0.2 0.1],...
        'Style','pushbutton',...
        'Tag','PlotDynamicFRETButton',...
        'String','Dynamic',...
        'FontSize',12,...
        'UIContextMenu',h.DynamicFRET_Menu,...
        'Callback',@UpdateLifetimeFits);
    
    h.DonorLifetimeText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.45 0.35 0.07],...
        'Style','text',...
        'Tag','SelectDonorDyeText',...
        'String','Donor Lifetime',...
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
        'FontSize',12,...
        'Callback',@UpdateCorrections);
    
    h.AcceptorLifetimeText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.3 0.35 0.07],...
        'Style','text',...
        'Tag','SelectAcceptorDyeText',...
        'String','Acceptor Lifetime',...
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
        'FontSize',12,...
        'Callback',@UpdateCorrections);
    
    h.DonorLifetimeBlueText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0 0.15 0.35 0.07],...
        'Style','text',...
        'Tag','DonorLifetimeBlueText',...
        'String','Donor Lifetime Blue',...
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
        'FontSize',12,...
        'Visible','off',...
        'Callback',@UpdateCorrections);
    
    h.DonorLifetimeFromDataCheckbox = uicontrol(....
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.02 0.05 0.45 0.07],...
        'Style','checkbox',...
        'Tag','DonorLifetimeFromDataCheckbox',...
        'String','Get Donor only Lifetime from Data',...
        'Value',0,...
        'enable','off',...
        'FontSize',12,...
        'Callback',@DonorOnlyLifetimeCallback);
    
    h.FoersterRadiusText = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.65 0.65 0.35 0.07],...
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
        'Position',[0.87 0.65 0.1 0.07],...
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
        'Position',[0.65 0.55 0.35 0.07],...
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
        'Position',[0.87 0.55 0.1 0.07],...
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
        'Position',[0.5 0.45 0.35 0.07],...
        'Style','text',...
        'Tag','FoersterRadiusBGText',...
        'String','Foerster Radius BG [A]',...
        'FontSize',12,...
        'Visible','off');
    
    h.FoersterRadiusBGEdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.87 0.45 0.1 0.07],...
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
        'Position',[0.5 0.35 0.35 0.07],...
        'Style','text',...
        'Tag','LinkerLengthBGText',...
        'String','Linker Length BG [A]',...
        'Visible','off',...
        'FontSize',12);
    
    h.LinkerLengthBGEdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.87 0.35 0.1 0.07],...
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
        'Position',[0.5 0.25 0.35 0.07],...
        'Style','text',...
        'Tag','FoersterRadiusBRText',...
        'String','Foerster Radius BR [A]',...
        'Visible','off',...
        'FontSize',12);
    
    h.FoersterRadiusBREdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.87 0.25 0.1 0.07],...
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
        'Position',[0.5 0.15 0.35 0.07],...
        'Style','text',...
        'Tag','LinkerLengthBRText',...
        'Visible','off',...
        'String','Linker Length BR [A]',...
        'FontSize',12);
    
    h.LinkerLengthBREdit = uicontrol(...
        'Parent',h.FitLifetimeRelatedPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.87 0.15 0.1 0.07],...
        'Style','edit',...
        'Tag','FoersterRadiusBREdit',...
        'String',num2str(UserValues.BurstBrowser.Corrections.LinkerLengthBR),...
        'FontSize',12,...
        'Visible','off',...
        'Callback',@UpdateCorrections);
    %% Secondary tab correlation
    %%% Contexmenu for correlation table
    h.Secondary_Tab_Correlation_Menu = uicontextmenu;
    
    %%% Sets a divider for correlation
    h.Secondary_Tab_Correlation_Divider_Menu = uimenu(...
        'Parent',h.Secondary_Tab_Correlation_Menu,...
        'Label',['Divider: ' num2str(UserValues.Settings.Pam.Cor_Divider)],...
        'Tag','Secondary_Tab_Correlation_Divider_Menu',...
        'Callback',@Calculate_Settings);
    
    Names = {'GG1','GG2','GR1','GR2','RR1','RR2','GG','GR','GX','GX1','GX2','RR'};
    h.Correlation_Table = uitable(...
        'Parent',h.SecondaryTabCorrelationPanel,...
        'Units','normalized',...
        'Position',[0 0.6 1 0.4],...
        'Tag','CorrelationTable',...
        'TooltipString',sprintf([...
        'Rightclick to open contextmenu with additional function: \n'...
        'Divider: Divider for correlation time resolution for certain excitation schemes']),...
        'UIContextMenu',h.Secondary_Tab_Correlation_Menu,...
        'ColumnWidth',{40},...
        'ColumnEditable',true,...
        'ColumnName',Names,...
        'RowName',Names,...
        'Data',false(numel(Names)));
    
    h.Correlate_Button = uicontrol(...
        'Style','pushbutton',...
        'Parent',h.SecondaryTabCorrelationPanel,...
        'Units','normalized',...
        'Position',[0 0.55 0.3 0.05],...
        'Tag','Correlate_Button',...
        'String','Correlate',...
        'ForegroundColor',Look.Fore,...
        'BackgroundColor',Look.Control,...
        'FontSize',12,...
        'Callback',@Correlate_Bursts);
    
    h.LoadAllPhotons_Button = uicontrol(...
        'Style','pushbutton',...
        'Parent',h.SecondaryTabCorrelationPanel,...
        'Units','normalized',...
        'Position',[0 0.45 0.3 0.05],...
        'ForegroundColor',Look.Fore,...
        'BackgroundColor',Look.Control,...
        'Tag','LoadAllPhotons_Button',...
        'String','Load All Photons (*.aps)',...
        'FontSize',12,...
        'Callback',@Load_Photons);
    
    h.CorrelateWindow_Button = uicontrol(...
        'Style','pushbutton',...
        'Parent',h.SecondaryTabCorrelationPanel,...
        'Units','normalized',...
        'Position',[0 0.35 0.3 0.05],...
        'Tag','CorrelateWindow_Button',...
        'String','Correlate with time window',...
        'ForegroundColor',Look.Fore,...
        'BackgroundColor',Look.Control,...
        'Callback',@Correlate_Bursts,...
        'FontSize',12,...
        'Enable','off');
    
    h.CorrelateWindow_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.SecondaryTabCorrelationPanel,...
        'Units','normalized',...
        'BackgroundColor',Look.Control,...
        'ForegroundColor',Look.Fore,...
        'Position',[0.4 0.35 0.1 0.025],...
        'Tag','CorrelateWindow_Edit',...
        'String',num2str(UserValues.BurstBrowser.Settings.Corr_TimeWindowSize),...
        'Callback',@UpdateOptions,...
        'FontSize',12,...
        'Enable','off');
    
    h.CorrelateWindow_Text = uicontrol(...
        'Style','text',...
        'Parent',h.SecondaryTabCorrelationPanel,...
        'Units','normalized',...
        'Position',[0.55 0.35 0.5 0.025],...
        'Tag','CorrelateWindow_Text',...
        'String','Time Window in multiples of 10 ms',...
        'Callback',@UpdateOptions,...
        'BackgroundColor',Look.Control,...
        'ForegroundColor',Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'Enable','on');
    %% Secondary tab options
    
    %%% Display Options Panel
    h.DisplayOptionsPanel = uipanel(...
        'Parent',h.SecondaryTabOptionsPanel,...
        'Units','normalized',...
        'Position',[0 0.6 1 0.4],...
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
        'Position',[0 0.85 0.4 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    h.NumberOfBinsXEdit = uicontrol(...
        'Style','edit',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.4 0.85 0.2 0.07],...
        'FontSize',12,...
        'Tag','NumberOfBinsEdit',...
        'String',UserValues.BurstBrowser.Display.NumberOfBinsX,...
        'Callback',@UpdatePlot...
        );
    
    h.NBinsYText = uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Number of Bins Y',...
        'Tag','Text_Number_of_BinsY',...
        'Units','normalized',...
        'Position',[0 0.78 0.4 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    h.NumberOfBinsYEdit = uicontrol(...
        'Style','edit',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.4 0.78 0.2 0.07],...
        'FontSize',12,...
        'Tag','NumberOfBinsEdit',...
        'String',UserValues.BurstBrowser.Display.NumberOfBinsY,...
        'Callback',@UpdatePlot...
        );
    
    %%% Specify the Plot Type
    h.PlotTypeText = uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Plot Type',...
        'Tag','Text_Plot_Type',...
        'Units','normalized',...
        'Position',[0 0.68 0.4 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    PlotType_String = {'Image','Contour'};
    h.PlotTypePopumenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Disabled,...
        'Units','normalized',...
        'Position',[0.4 0.68 0.2 0.07],...
        'FontSize',12,...
        'Tag','PlotTypePopupmenu',...
        'String',PlotType_String,...
        'Value',find(strcmp(PlotType_String,UserValues.BurstBrowser.Display.PlotType)),...
        'Callback',@ChangePlotType...
        );
    
    h.NumberOfContourLevels_text = uicontrol(...
        'Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.62 0.68 0.28 0.07],...
        'FontSize',12,...
        'Tag','NumberOfContourLevels_edit',...
        'String','Number of Contour Levels'...
        );
    
    h.NumberOfContourLevels_edit = uicontrol(...
        'Style','edit',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.9 0.68 0.1 0.07],...
        'FontSize',12,...
        'Tag','NumberOfContourLevels_edit',...
        'String',num2str(UserValues.BurstBrowser.Display.NumberOfContourLevels),...
        'Callback',@UpdatePlot...
        );
    
    h.ContourOffset_text = uicontrol(...
        'Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.62 0.58 0.28 0.07],...
        'FontSize',12,...
        'Tag','NumberOfContourLevels_edit',...
        'String','Contour Plot Offset [%]'...
        );
    
    h.ContourOffset_edit = uicontrol(...
        'Style','edit',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.9 0.58 0.1 0.07],...
        'FontSize',12,...
        'Tag','NumberOfContourLevels_edit',...
        'String',num2str(UserValues.BurstBrowser.Display.ContourOffset),...
        'Callback',@UpdatePlot...
        );
    
    %%% Specify the colormap
    h.ColormapText = uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Colormap',...
        'Tag','Text_ColorMap',...
        'Units','normalized',...
        'Position',[0 0.58 0.4 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    Colormaps_String = {'jet','jetvar','hot','bone','gray','parula'};
    if ischar(UserValues.BurstBrowser.Display.ColorMap)
        try
            colormap_val = find(strcmp(Colormaps_String,UserValues.BurstBrowser.Display.ColorMap));
        catch 
            colormap_val = 1;
            UserValues.BurstBrowser.Display.ColorMap = Colormaps_String(1);
        end
    else
        colormap_val = numel(Colormaps_String);
    end
    h.ColorMapPopupmenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Disabled,...
        'Units','normalized',...
        'Position',[0.4 0.58 0.2 0.07],...
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
        'Position',[0.3 0.58 0.1 0.07],...
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
        'Position',[0.6 0.48 0.4 0.07],...
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
        'Position',[0.1 0.48 0.4 0.07],...
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
        'Position',[0.1 0.38 0.5 0.07],...
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
        'Position',[0.1 0.28 0.5 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdatePlot...
        );
    
    h.ColorLine1 = uicontrol('Style','pushbutton',...
        'Parent',h.DisplayOptionsPanel,...
        'String','',...
        'Tag','ColorLine1',...
        'Units','normalized',...
        'Position',[0.15 0.1 0.07 0.07],...
        'FontSize',12,...
        'BackgroundColor', UserValues.BurstBrowser.Display.ColorLine1,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateLineColor...
        );
        
    h.ColorLine2 = uicontrol('Style','pushbutton',...
        'Parent',h.DisplayOptionsPanel,...
        'String','',...
        'Tag','ColorLine2',...
        'Units','normalized',...
        'Position',[0.35 0.1 0.07 0.07],...
        'FontSize',12,...
        'BackgroundColor', UserValues.BurstBrowser.Display.ColorLine2,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateLineColor...
        );
    
    h.ColorLine3 = uicontrol('Style','pushbutton',...
        'Parent',h.DisplayOptionsPanel,...
        'String','',...
        'Tag','ColorLine3',...
        'Units','normalized',...
        'Position',[0.55 0.1 0.07 0.07],...
        'FontSize',12,...
        'BackgroundColor', UserValues.BurstBrowser.Display.ColorLine3,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateLineColor...
        );
    
    h.ColorLine1Text = uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Line 1',...
        'Tag','ColorLine1Text',...
        'Units','normalized',...
        'Position',[0.05 0.1 0.1 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
     h.ColorLine2Text = uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Line 2',...
        'Tag','ColorLine2Text',...
        'Units','normalized',...
        'Position',[0.25 0.1 0.1 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
     h.ColorLine3Text = uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Line 3',...
        'Tag','ColorLine3Text',...
        'Units','normalized',...
        'Position',[0.45 0.1 0.1 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    %%% Data Processing Options Panel
    h.DataProcessingPanel = uipanel(...
        'Parent',h.SecondaryTabOptionsPanel,...
        'Units','normalized',...
        'Position',[0 0.2 1 0.4],...
        'Tag','DataProcessingPanel',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'Title','Data Processing Options',...
        'HighlightColor', Look.Fore,...
        'FontSize',12);
    
    %%% Option to enable/disable save dialog on closing
    h.SaveOnClose = uicontrol('Style','checkbox',...
        'Parent',h.DataProcessingPanel,...
        'String','Ask for saving when closing window',...
        'Tag','SaveOnClose',...
        'Value', UserValues.BurstBrowser.Settings.SaveOnClose,...
        'Units','normalized',...
        'Position',[0.1 0.88 0.5 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    
    %%% Option to check/uncheck downsampling for fFCS
    h.Downsample_fFCS = uicontrol('Style','checkbox',...
        'Parent',h.DataProcessingPanel,...
        'String','Increase TAC bin width for fFCS',...
        'Tag','Downsample_fFCS',...
        'Value', UserValues.BurstBrowser.Settings.Downsample_fFCS,...
        'Units','normalized',...
        'Position',[0.1 0.78 0.5 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    
    h.Downsample_fFCS_edit = uicontrol('Style','edit',...
        'Parent',h.DataProcessingPanel,...
        'Tag','Downsample_fFCS',...
        'String', num2str(UserValues.BurstBrowser.Settings.Downsample_fFCS_Time),...
        'Units','normalized',...
        'Position',[0.6 0.78 0.2 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    uicontrol('Style','text',...
        'Parent',h.DataProcessingPanel,...
        'Tag','Downsample_fFCS',...
        'String','ps',...
        'Units','normalized',...
        'Position',[0.8 0.78 0.2 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore...
        );
    
    if UserValues.BurstBrowser.Settings.Downsample_fFCS
        h.Downsample_fFCS_edit.Enable = 'on';
    else
        h.Downsample_fFCS_edit.Enable = 'off';
    end
    
    h.fFCS_UseIRF = uicontrol('Style','checkbox',...
        'Parent',h.DataProcessingPanel,...
        'String','Use Scatter Pattern for fFCS',...
        'Tag','fFCS_UseIRF',...
        'Value', UserValues.BurstBrowser.Settings.fFCS_UseIRF,...
        'Units','normalized',...
        'Position',[0.1 0.68 0.5 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
    
    h.fFCS_UseTimeWindow = uicontrol('Style','checkbox',...
        'Parent',h.DataProcessingPanel,...
        'String','Include Time Window for fFCS',...
        'Tag','fFCS_UseTimeWindow',...
        'Value', UserValues.BurstBrowser.Settings.fFCS_UseTimewindow,...
        'Units','normalized',...
        'Position',[0.1 0.58 0.5 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Callback',@UpdateOptions...
        );
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
        'nextplot','add',...
        'Color',Look.Axes,...
        'UIContextMenu',h.ExportGraph_Menu);
    
    %display no. bursts
    h.text_nobursts = uicontrol(...
        'Style','text',...
        'Parent',h.MainTabGeneralPanel,...
        'Tag','Text_Burst',...
        'Units','normalized',...
        'FontSize',14,...
        'String','no bursts',...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.83 0.81 0.16 0.07]);
    
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
        'UIContextMenu',h.ExportGraph_Menu);
    ylabel(h.axes_1d_x, 'counts');
    
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
        'View',[90 90],...
        'XDir','reverse',...
        'UIContextMenu',h.ExportGraph_Menu);
    ylabel(h.axes_1d_y, 'counts');
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
    %% Define axes in Corrections tab
    %% Corrections - 2ColorMFD
    h.Corrections.TwoCMFD.axes_crosstalk =  axes(...
        'Parent',h.MainTabCorrectionsPanel,...
        'Units','normalized',...
        'Position',[0.05 0.55 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_crosstalk',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    xlabel(h.Corrections.TwoCMFD.axes_crosstalk,'Proximity Ratio');
    ylabel(h.Corrections.TwoCMFD.axes_crosstalk,'#');
    title(h.Corrections.TwoCMFD.axes_crosstalk,'Proximity Ratio of Donor only');
    
    h.Corrections.TwoCMFD.axes_direct_excitation =  axes(...
        'Parent',h.MainTabCorrectionsPanel,...
        'Units','normalized',...
        'Position',[0.55 0.55 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_direct_excitation',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    xlabel(h.Corrections.TwoCMFD.axes_direct_excitation,'Stoichiometry (raw)');
    ylabel(h.Corrections.TwoCMFD.axes_direct_excitation,'#');
    title(h.Corrections.TwoCMFD.axes_direct_excitation,'Raw Stoichiometry of Acceptor only');
    
    h.Corrections.TwoCMFD.axes_gamma=  axes(...
        'Parent',h.MainTabCorrectionsPanel,...
        'Units','normalized',...
        'Position',[0.05 0.05 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_gamma',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    xlabel(h.Corrections.TwoCMFD.axes_gamma,'Efficiency');
    ylabel(h.Corrections.TwoCMFD.axes_gamma,'1/Stoichiometry');
    title(h.Corrections.TwoCMFD.axes_gamma,'1/Stoichiometry vs. Efficiency for gamma = 1');
    
    h.Corrections.TwoCMFD.axes_gamma_lifetime =  axes(...
        'Parent',h.MainTabCorrectionsPanel,...
        'Units','normalized',...
        'Position',[0.55 0.05 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_gamma_lifetime',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    xlabel(h.Corrections.TwoCMFD.axes_gamma_lifetime,'Lifetime GG [ns]');
    ylabel(h.Corrections.TwoCMFD.axes_gamma_lifetime,'Efficiency');
    title(h.Corrections.TwoCMFD.axes_gamma_lifetime,'Efficiency vs. Lifetime GG');
    %% Corrections - 3ColorMFD
    h.Corrections.ThreeCMFD.axes_crosstalk_BG =  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[0.05 0.7 0.2 0.25],...
        'Tag','Main_Tab_Corrections_Plot_crosstalk',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    xlabel(h.Corrections.ThreeCMFD.axes_crosstalk_BG,'Proximity Ratio BG');
    ylabel(h.Corrections.ThreeCMFD.axes_crosstalk_BG,'#');
    title(h.Corrections.ThreeCMFD.axes_crosstalk_BG,'Blue dye only');
    
    h.Corrections.ThreeCMFD.axes_crosstalk_BR =  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[(0.25+0.1/3) 0.7 0.2 0.25],...
        'Tag','Main_Tab_Corrections_Plot_crosstalk',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    xlabel(h.Corrections.ThreeCMFD.axes_crosstalk_BR,'Proximity Ratio BR');
    ylabel(h.Corrections.ThreeCMFD.axes_crosstalk_BR,'#');
    title(h.Corrections.ThreeCMFD.axes_crosstalk_BR,'Blue dye only');
    
    h.Corrections.ThreeCMFD.axes_direct_excitation_BG =  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[(0.45+0.2/3) 0.7 0.2 0.25],...
        'Tag','Main_Tab_Corrections_Plot_direct_excitation',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    xlabel(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,'Stoichiometry BG (raw)');
    ylabel(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,'#');
    title(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,'Green dye only');
    
    h.Corrections.ThreeCMFD.axes_direct_excitation_BR =  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[0.75 0.7 0.2 0.25],...
        'Tag','Main_Tab_Corrections_Plot_direct_excitation',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    xlabel(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,'Stoichiometry BR (raw)');
    ylabel(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,'#');
    title(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,'Red dye only');
    
    h.Corrections.ThreeCMFD.axes_gammaBG_threecolor=  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[0.05 0.375 0.4 0.25],...
        'Tag','Main_Tab_Corrections_Plot_gammaBG_threecolor',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    xlabel(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'Efficiency* BG');
    ylabel(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'1/Stoichiometry* BG');
    title(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'1/Stoichiometry* BG vs. Efficiency* BG for gammaBG = 1');
    
    h.Corrections.ThreeCMFD.axes_gammaBR_threecolor=  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[0.05 0.05 0.4 0.25],...
        'Tag','Main_Tab_Corrections_Plot_gammaBG_threecolor',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    xlabel(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'Efficiency* BR');
    ylabel(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'1/Stoichiometry* BR');
    title(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'1/Stoichiometry* BR vs. Efficiency* BR for gammaBR = 1');
    
    %%% 07-2015 Disable Gamma from populations since it does not work
    h.Corrections.ThreeCMFD.axes_gammaBR_threecolor.Visible = 'off';
    h.Corrections.ThreeCMFD.axes_gammaBG_threecolor.Visible = 'off';
    
    h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime =  axes(...
        'Parent',h.MainTabCorrectionsThreeCMFDPanel,...
        'Units','normalized',...
        'Position',[0.5 0.05 0.45 0.575],...
        'Tag','Main_Tab_Corrections_Plot_gamma_threecolor_lifetime',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    xlabel(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,'Lifetime BB [ns]');
    ylabel(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,'Efficiency B->G+R');
    title(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,'Efficiency B->G+R vs. Lifetime BB');
    %% Define Axes in Lifetime Tab
    h.axes_EvsTauGG =  axes(...
        'Parent',h.MainTabLifetimePanel,...
        'Units','normalized',...
        'Position',[0.05 0.55 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_EvsTauGG',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    ylabel(h.axes_EvsTauGG,'Efficiency');
    xlabel(h.axes_EvsTauGG,'Lifetime GG [ns]');
    title(h.axes_EvsTauGG,'Efficiency vs. Lifetime GG');
    
    h.axes_EvsTauRR =  axes(...
        'Parent',h.MainTabLifetimePanel,...
        'Units','normalized',...
        'Position',[0.55 0.55 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_EvsTauRR',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    ylabel(h.axes_EvsTauRR,'Efficiency');
    xlabel(h.axes_EvsTauRR,'Lifetime RR [ns]');
    title(h.axes_EvsTauRR,'Efficiency vs. Lifetime RR');
    
    h.axes_rGGvsTauGG =  axes(...
        'Parent',h.MainTabLifetimePanel,...
        'Units','normalized',...
        'Position',[0.05 0.05 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_rGGvsTauGG',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    ylabel(h.axes_rGGvsTauGG,'Anisotropy GG');
    xlabel(h.axes_rGGvsTauGG,'Lifetime GG [ns]');
    title(h.axes_rGGvsTauGG,'Anisotropy GG vs. Lifetime GG');
    
    h.axes_rRRvsTauRR=  axes(...
        'Parent',h.MainTabLifetimePanel,...
        'Units','normalized',...
        'Position',[0.55 0.05 0.4 0.4],...
        'Tag','Main_Tab_Corrections_Plot_rRRvsTauRR',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    ylabel(h.axes_rRRvsTauRR,'Anisotropy RR');
    xlabel(h.axes_rRRvsTauRR,'Lifetime RR [ns]');
    title(h.axes_rRRvsTauRR,'Anisotropx RR vs. Lifetime RR');
    
    %%% Define Axes for 3C
    %%% (For 3C, the four axes of 2C are shifted to the left and two
    %%% additional axes are made visible)
    h.axes_E_BtoGRvsTauBB =  axes(...
        'Parent',h.Hide_Stuff,...
        'Units','normalized',...
        'Position',[(0.15+0.8*2/3) 0.55 0.8/3 0.4],...
        'Tag','Main_Tab_Corrections_Plot_EBtoGRvsTauBB',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    ylabel(h.axes_E_BtoGRvsTauBB,'Efficiency B->G+R');
    xlabel(h.axes_E_BtoGRvsTauBB,'Lifetime BB [ns]');
    title(h.axes_E_BtoGRvsTauBB,'Efficiency B->G+R vs. Lifetime BB');
    
    h.axes_rBBvsTauBB=  axes(...
        'Parent',h.Hide_Stuff,...
        'Units','normalized',...
        'Position',[(0.15+0.8*2/3) 0.05 0.8/3 0.4],...
        'Tag','Main_Tab_Corrections_Plot_rBBvsTauBB',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'View',[0 90]);
    ylabel(h.axes_rBBvsTauBB,'Anisotropy BB');
    xlabel(h.axes_rBBvsTauBB,'Lifetime BB [ns]');
    title(h.axes_rBBvsTauBB,'Anisotropy BB vs. Lifetime BB');
    %% Define Axes in filtered FCS tab
    h.axes_fFCS_DecayPar =  axes(...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0.05 0.55 0.4 0.4],...
        'Tag','Main_Tab_fFCS_Decays_Par',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add');
    
    h.axes_fFCS_DecayPerp =  axes(...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0.55 0.55 0.4 0.4],...
        'Tag','Main_Tab_fFCS_Decays_Perp',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add');
    
    %%% Popupmenus for selection of species
    uicontrol('Style','text',...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0.05 0.965 0.10 0.02],...
        'String','Species 1:',...
        'BackgroundColor',Look.Back,...
        'FontSize',12);
    
    h.fFCS_Species1_popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Tag','fFCS_Species1_popupmenu',...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0.14 0.94 0.15 0.05],...
        'String',{'-'},...
        'Value',1,...
        'FontSize',12);
    
    uicontrol('Style','text',...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0.3 0.965 0.10 0.02],...
        'String','Species 2:',...
        'BackgroundColor',Look.Back,...
        'FontSize',12);
    
    h.fFCS_Species2_popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Tag','fFCS_Species2_popupmenu',...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0.39 0.94 0.15 0.05],...
        'String',{'-'},...
        'Value',1,...
        'FontSize',12);
    
    %%% Button to Update Microtime Histograms
    h.Plot_Microtimes_button = uicontrol(...
        'Style','pushbutton',...
        'Tag','Plot_Microtimes_button',...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0.55 0.9625 0.15 0.03],...
        'String','Plot Microtimes',...
        'FontSize',12,...
        'Callback',@Update_MicrotimeHistograms);
    
    %%% Button to calculate filters
    h.Calc_fFCS_Filter_button = uicontrol(...
        'Style','pushbutton',...
        'Tag','Calc_fFCS_Filter_button',...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0.7 0.9625 0.15 0.03],...
        'String','Calculate Filters',...
        'FontSize',12,...
        'Callback',@Calc_fFCS_Filters);
    
    %%% Button to do correlation
    h.Do_fFCS_button = uicontrol(...
        'Style','pushbutton',...
        'Tag','Do_fFCS_button',...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0.85 0.9625 0.15 0.03],...
        'String','Do fFCS',...
        'FontSize',12,...
        'Callback',@Do_fFCS);
    
    h.axes_fFCS_FilterPar =  axes(...
        'Parent',h.fFCS_SubTabParFilterPanel,...
        'Units','normalized',...
        'Position',[0.075 0.075 0.9 0.9],...
        'Tag','Sub_Tab_fFCS_Filter_Par',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add');
    
    h.axes_fFCS_FilterPerp =  axes(...
        'Parent',h.fFCS_SubTabPerpFilterPanel,...
        'Units','normalized',...
        'Position',[0.075 0.075 0.9 0.9],...
        'Tag','Sub_Tab_fFCS_Filter_Perp',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add');
    
    h.axes_fFCS_ReconstructionPar =  axes(...
        'Parent',h.fFCS_SubTabParReconstructionPanel,...
        'Units','normalized',...
        'Position',[0.075 0.075 0.9 0.75],...
        'Tag','Sub_Tab_fFCS_Reconstruction_Par',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add');
    
    h.axes_fFCS_ReconstructionParResiduals =  axes(...
        'Parent',h.fFCS_SubTabParReconstructionPanel,...
        'Units','normalized',...
        'Position',[0.075 0.825 0.9 0.15],...
        'Tag','Sub_Tab_fFCS_Reconstruction_Par_Residuals',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'XTickLabel',[]);
    
    h.axes_fFCS_ReconstructionPerp =  axes(...
        'Parent',h.fFCS_SubTabPerpReconstructionPanel,...
        'Units','normalized',...
        'Position',[0.075 0.075 0.9 0.75],...
        'Tag','Sub_Tab_fFCS_Reconstruction_Perp',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add');
    
    h.axes_fFCS_ReconstructionPerpResiduals =  axes(...
        'Parent',h.fFCS_SubTabPerpReconstructionPanel,...
        'Units','normalized',...
        'Position',[0.075 0.825 0.9 0.15],...
        'Tag','Sub_Tab_fFCS_Reconstruction_Perp_Residuals',...
        'Box','on',...
        'FontSize',12,...
        'nextplot','add',...
        'XTickLabel',[]);
    %% Define Axes in TauFit Tab
    %%% Right-click menu for plot changes
    h.TauFit.Microtime_Plot_Menu_MIPlot = uicontextmenu;
    h.TauFit.Microtime_Plot_ChangeYScaleMenu_MIPlot = uimenu(...
        h.TauFit.Microtime_Plot_Menu_MIPlot,...
        'Label','Logscale',...
        'Tag','Plot_Logscale_MIPlot',...
        'Callback',@ChangeYScale);
    h.TauFit.Microtime_Plot_Menu_ResultPlot = uicontextmenu;
    h.TauFit.Microtime_Plot_ChangeYScaleMenu_ResultPlot = uimenu(...
        h.TauFit.Microtime_Plot_Menu_ResultPlot,...
        'Label','Logscale',...
        'Tag','Plot_Logscale_ResultPlot',...
        'Callback',@ChangeYScale);
    %%% Main Microtime Plot
    h.TauFit.Microtime_Plot = axes(...
        'Parent',h.MainTabTauFitPanel,...
        'Units','normalized',...
        'Position',[0.05 0.35 0.9 0.55],...
        'Tag','Microtime_Plot',...
        'Box','on',...
        'UIContextMenu',h.TauFit.Microtime_Plot_Menu_MIPlot,...
        'nextplot','add');
    
    h.Microtime_Plot.XLim = [0 1];
    h.Microtime_Plot.YLim = [0 1];
    h.Microtime_Plot.XLabel.Color = Look.Fore;
    h.Microtime_Plot.XLabel.String = 'time [ns]';
    h.Microtime_Plot.YLabel.Color = Look.Fore;
    h.Microtime_Plot.YLabel.String = 'intensity [counts]';
    h.Microtime_Plot.XGrid = 'on';
    h.Microtime_Plot.YGrid = 'on';
    
    %%% Residuals Plot
    h.TauFit.Residuals_Plot = axes(...
        'Parent',h.MainTabTauFitPanel,...
        'Units','normalized',...
        'Position',[0.05 0.9 0.9 0.08],...
        'Tag','Residuals_Plot',...
        'XTick',[],...
        'Box','on',...
        'nextplot','add');
    
    h.Residuals_Plot.YLabel.Color = Look.Fore;
    h.Residuals_Plot.YLabel.String = 'res_w';
    h.Residuals_Plot.XGrid = 'on';
    h.Residuals_Plot.YGrid = 'on';
    
    %%% Result Plot (Replaces Microtime Plot after fit is done)
    h.TauFit.Result_Plot = axes(...
        'Parent',h.MainTabTauFitPanel,...
        'Units','normalized',...
        'Position',[0.05 0.35 0.9 0.55],...
        'Tag','Microtime_Plot',...
        'Box','on',...
        'Visible','on',...
        'UIContextMenu',h.TauFit.Microtime_Plot_Menu_ResultPlot,...
        'nextplot','add');
    h.TauFit.Result_Plot_Text = text(...
        0,0,'',...
        'Parent',h.TauFit.Result_Plot,...
        'FontSize',12,...
        'FontWeight','bold',...
        'BackgroundColor',[1 1 1]);
    
    h.Result_Plot.XLim = [0 1];
    h.Result_Plot.YLim = [0 1];
    h.Result_Plot.XLabel.Color = Look.Fore;
    h.Result_Plot.XLabel.String = 'time [ns]';
    h.Result_Plot.YLabel.Color = Look.Fore;
    h.Result_Plot.YLabel.String = 'intensity [counts]';
    h.Result_Plot.XGrid = 'on';
    h.Result_Plot.YGrid = 'on';
    linkaxes([h.TauFit.Result_Plot, h.TauFit.Residuals_Plot],'x');
    
    %%% dummy panel to hide plots
    h.TauFit.HidePanel = uibuttongroup(...
        'Visible','off',...
        'Parent',h.MainTabTauFitPanel,...
        'Tag','HidePanel');
    
    %%% Hide Result Plot
    h.TauFit.Result_Plot.Parent = h.TauFit.HidePanel;
    
    %%% Panel for Selection
    h.TauFit.Selection_Panel = uibuttongroup(...
        'Parent',h.MainTabTauFitPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Fore,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0.2 0.6 0.1],...
        'Tag','Slider_Panel');
    %%% Dropdown menu for selecting a species
    h.TauFit.SpeciesSelect_Text = uicontrol('Style','text',...
        'Tag','TauFit_SpeciesSelect_text',...
        'Parent',h.TauFit.Selection_Panel,...
        'Units','normalized',...
        'Position',[0 0.7 0.2 0.2],...
        'String','Species selection:',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'FontSize',12);
    h.TauFit.SpeciesSelect = uicontrol(...
        'Style','popupmenu',...
        'Tag','TauFit_SpeciesSelect_popupmenu',...
        'Parent',h.TauFit.Selection_Panel,...
        'Units','normalized',...
        'Position',[0 0.3 0.2 0.3],...
        'String',{'-'},...
        'Value',1,...
        'FontSize',12);
    
    %%% Dropdown menu for selecting a channel (GG/RR)
    h.TauFit.ChannelSelect_Text = uicontrol('Style','text',...
        'Tag','TauFit_ChannelSelect_text',...
        'Parent',h.TauFit.Selection_Panel,...
        'Units','normalized',...
        'Position',[0.25 0.7 0.2 0.2],...
        'String','Channel selection:',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'FontSize',12);
    h.TauFit.ChannelSelect = uicontrol(...
        'Style','popupmenu',...
        'Tag','TauFit_ChannelSelect_popupmenu',...
        'Parent',h.TauFit.Selection_Panel,...
        'Units','normalized',...
        'Position',[0.25 0.3 0.2 0.3],...
        'String',{'GG','RR'},...
        'Value',1,...
        'FontSize',12);
    
    %%% Button to Update Microtime Histograms
    h.TauFit.Plot_Microtimes_button = uicontrol(...
        'Style','pushbutton',...
        'Tag','Plot_Microtimes_button',...
        'Parent',h.TauFit.Selection_Panel,...
        'Units','normalized',...
        'Position',[0.45 0.7 0.25 0.25],...
        'String','Plot Microtimes',...
        'FontSize',12,...
        'Callback',@Update_MicrotimeHistograms);
    
    %%% Button to Start Lifetime Fit
    h.TauFit.Start_TauFit_button = uicontrol(...
        'Style','pushbutton',...
        'Tag','Start_Fit_button',...
        'Parent',h.TauFit.Selection_Panel,...
        'Units','normalized',...
        'Position',[0.45 0.35 0.25 0.25],...
        'String','Start Fit',...
        'FontSize',12,...
        'Callback',@Start_TauFit);
    
    %%% Button to Start time-resolved Anisotropy fit
    h.TauFit.Start_AnisoFit_button = uicontrol(...
        'Style','pushbutton',...
        'Tag','Start_AnisoFit_button',...
        'Parent',h.TauFit.Selection_Panel,...
        'Units','normalized',...
        'Position',[0.45 0.05 0.25 0.25],...
        'String','Fit time-resolved Anisotropy',...
        'FontSize',12,...
        'Callback',@Start_TauFit);
    
    %%% Popup Menu for Fit Method Selection
    h.TauFit.FitMethods = {'Single Exponential','Biexponential','Three Exponentials',...
        'Distribution','Distribution plus Donor only','Fit Anisotropy'};
    h.TauFit.FitMethod_Popupmenu = uicontrol(...
        'Parent',h.TauFit.Selection_Panel,...
        'Style','Popupmenu',...
        'Tag','FitMethod_Popupmenu',...
        'Units','normalized',...
        'Position',[0.72 0.3 0.27 0.3],...
        'String',h.TauFit.FitMethods,...
        'Callback',@Method_Selection_TauFit);
    
    h.TauFit.FitMethod_Text = uicontrol(...
        'Parent',h.TauFit.Selection_Panel,...
        'Style','Text',...
        'Tag','FitMethod_Text',...
        'Units','normalized',...
        'Position',[0.72 0.7 0.27 0.2],...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','center',...
        'FontSize',12,...
        'String','Fit Method:',...
        'ToolTipString','Select the Fit Method');
    
    %%% Sliders
    %%% Define the container
    h.TauFit.Slider_Panel = uibuttongroup(...
        'Parent',h.MainTabTauFitPanel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Fore,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 0.6 0.2],...
        'Tag','Slider_Panel');
    
    %%% Individual sliders for:
    %%% 1) Start
    %%% 2) Length
    %%% 3) Shift of perpendicular channel
    %%% 4) Shift of IRF
    %%% 5) IRF length to consider
    %%%
    %%% Slider for Selection of Start
    h.TauFit.StartPar_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.TauFit.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.79 0.8 0.1],...
        'Tag','StartPar_Slider',...
        'Callback',@Update_TauFitPlots);
    
    h.TauFit.StartPar_Edit = uicontrol(...
        'Parent',h.TauFit.Slider_Panel,...
        'Style','edit',...
        'Tag','StartPar_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.80 0.05 0.1],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_TauFitPlots);
    
    h.TauFit.StartPar_Text = uicontrol(...
        'Style','text',...
        'Parent',h.TauFit.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','Start Parallel',...
        'TooltipString','Start Value for the Parallel Channel',...
        'Position',[0.01 0.80 0.14 0.1],...
        'Tag','StartPar_Text');
    
    %%% Slider for Selection of Length
    h.TauFit.Length_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.TauFit.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.64 0.8 0.1],...
        'Tag','Length_Slider',...
        'Callback',@Update_TauFitPlots);
    
    h.TauFit.Length_Edit = uicontrol(...
        'Parent',h.TauFit.Slider_Panel,...
        'Style','edit',...
        'Tag','Length_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.65 0.05 0.1],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_TauFitPlots);
    
    h.TauFit.Length_Text = uicontrol(...
        'Style','text',...
        'Parent',h.TauFit.Slider_Panel,...
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
    h.TauFit.ShiftPer_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.TauFit.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.49 0.8 0.1],...
        'Tag','ShiftPer_Slider',...
        'Callback',@Update_TauFitPlots);
    
    h.TauFit.ShiftPer_Edit = uicontrol(...
        'Parent',h.TauFit.Slider_Panel,...
        'Style','edit',...
        'Tag','ShiftPer_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.5 0.05 0.1],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_TauFitPlots);
    
    h.TauFit.ShiftPer_Text = uicontrol(...
        'Style','text',...
        'Parent',h.TauFit.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','Perpendicular Shift',...
        'TooltipString','Shift of the Perpendicular Channel',...
        'Position',[0.01 0.5 0.14 0.1],...
        'Tag','ShiftPer_Text');
    
    %%% Slider for Selection of IRF Shift
    h.TauFit.IRFShift_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.TauFit.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.34 0.8 0.1],...
        'Tag','IRFShift_Slider',...
        'Callback',@Update_TauFitPlots);
    
    h.TauFit.IRFShift_Edit = uicontrol(...
        'Parent',h.TauFit.Slider_Panel,...
        'Style','edit',...
        'Tag','IRFShift_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.35 0.05 0.1],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_TauFitPlots);
    
    h.TauFit.IRFShift_Text = uicontrol(...
        'Style','text',...
        'Parent',h.TauFit.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','IRF Shift',...
        'TooltipString','Shift of the IRF',...
        'Position',[0.01 0.35 0.14 0.1],...
        'Tag','IRFShift_Text');
    
    %%% Slider for Selection of IRF Length
    h.TauFit.IRFLength_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.TauFit.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.19 0.8 0.1],...
        'Tag','IRFLength_Slider',...
        'Callback',@Update_TauFitPlots);
    
    h.TauFit.IRFLength_Edit = uicontrol(...
        'Parent',h.TauFit.Slider_Panel,...
        'Style','edit',...
        'Tag','IRFLength_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.2 0.05 0.1],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_TauFitPlots);
    
    h.TauFit.IRFLength_Text = uicontrol(...
        'Style','text',...
        'Parent',h.TauFit.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','IRF Length',...
        'TooltipString','Length of the IRF',...
        'Position',[0.01 0.2 0.14 0.1],...
        'Tag','IRFLength_Text');
    
    %%% Slider for Selection of Ignore Region in the Beginning
    h.TauFit.Ignore_Slider = uicontrol(...
        'Style','slider',...
        'Parent',h.TauFit.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.2 0.04 0.8 0.1],...
        'Tag','Ignore_Slider',...
        'Callback',@Update_TauFitPlots);
    
    h.TauFit.Ignore_Edit = uicontrol(...
        'Parent',h.TauFit.Slider_Panel,...
        'Style','edit',...
        'Tag','Ignore_Edit',...
        'Units','normalized',...
        'Position',[0.15 0.05 0.05 0.1],...
        'String','0',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',10,...
        'Callback',@Update_TauFitPlots);
    
    h.TauFit.Ignore_Text = uicontrol(...
        'Style','text',...
        'Parent',h.TauFit.Slider_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'FontSize',12,...
        'String','Ignore Length',...
        'TooltipString','Length of the Ignore Region in the Beginning',...
        'Position',[0.01 0.05 0.14 0.1],...
        'Tag','Ignore_Text');
    %%% Tab for FitParameters and Settings
    %%% Tab containing a table for the fit parameters
    h.TauFit.TauFit_Tabgroup = uitabgroup(...
        'Parent',h.MainTabTauFitPanel,...
        'Tag','TauFit_Tabgroup',...
        'Units','normalized',...
        'Position',[0.6 0 0.4 0.3]);
    
    h.TauFit.FitPar_Tab = uitab(...
        'Parent',h.TauFit.TauFit_Tabgroup,...
        'Title','Fit',...
        'Tag','FitPar_Tab');
    h.TauFit.FitSet_Tab = uitab(...
        'Parent',h.TauFit.TauFit_Tabgroup,...
        'Title','Settings',...
        'Tag','FitSet_Tab');
    
    h.TauFit.FitPar_Panel = uibuttongroup(...
        'Parent',h.TauFit.FitPar_Tab,...
        'Units','normalized',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'HighlightColor',Look.Control,...
        'ShadowColor',Look.Shadow,...
        'Position',[0 0 1 1],...
        'Tag','FitPar_Panel');
    h.TauFit.FitSet_Panel = uibuttongroup(...
        'Parent',h.TauFit.FitSet_Tab,...
        'Units','normalized',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'HighlightColor',Look.Control,...
        'ShadowColor',Look.Shadow,...
        'Position',[0 0 1 1],...
        'Tag','FitPar_Panel');
    %%% Fit Parameter Table
    h.TauFit.FitPar_Table = uitable(...
        'Parent',h.TauFit.FitPar_Panel,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'ColumnName',{'Value','LB','UB','Fixed'},...
        'ColumnFormat',{'numeric','numeric','numeric','logical'},...
        'RowName',{'Test'},...
        'ColumnEditable',[true true true true],...
        'ColumnWidth',{50,50,50,40},...
        'Tag','FitPar_Table',...
        'CellEditCallBack',@Update_TauFitPlots);
    %%% RowNames - Store the Parameter Names of different FitMethods
    h.TauFit.Parameters = cell(numel(h.TauFit.FitMethods),1);
    h.TauFit.Parameters{1} = {'Tau [ns]','Scatter','Background','IRF Shift'};
    h.TauFit.Parameters{2} = {'Tau1 [ns]','Tau2 [ns]','Fraction 1','Scatter','Background','IRF Shift'};
    h.TauFit.Parameters{3} = {'Tau1 [ns]','Tau2 [ns]','Tau3 [ns]','Fraction 1','Fraction 2','Scatter','Background','IRF Shift'};
    h.TauFit.Parameters{4} = {'Center R [A]','Sigma R [A]','Scatter','Background','R0 [A]','TauD0 [ns]','IRF Shift'};
    h.TauFit.Parameters{5} = {'Center R [A]','Sigma R [A]','Fraction Donly','Scatter','Background','R0 [A]','TauD0 [ns]','IRF Shift'};
    h.TauFit.Parameters{6} = {'Tau [ns]','Rho [ns]','r0','r_infinity','Scatter Par','Scatter Per','Background Par', 'Background Per', 'l1','l2','IRF Shift'};
    h.TauFit.FitPar_Table.RowName = h.TauFit.Parameters{1};
    %%% Initial Data - Store the StartValues as well as LB and UB
    h.TauFit.StartPar = cell(numel(h.TauFit.FitMethods),1);
    h.TauFit.StartPar{1} = {2,0,Inf,false;0,0,1,false;0,0,1,false;0,0,0,true};
    h.TauFit.StartPar{2} = {2,0,Inf,false;2,0,Inf,false;0,0,1,false;0,0,1,false;0,0,1,false;0,0,0,true};
    h.TauFit.StartPar{3} = {2,0,Inf,false;2,0,Inf,false;2,0,Inf,false;0,0,1,false;0,0,1,false;0,0,1,false;0,0,1,false;0,0,0,true};
    h.TauFit.StartPar{4} = {50,0,Inf,false;5,0,Inf,false;0,0,1,false;0,0,1,false;50,0,Inf,true;4,0,Inf,true;0,0,0,true};
    h.TauFit.StartPar{5} = {50,0,Inf,false;5,0,Inf,false;0,0,1,false;0,0,1,false;0,0,1,false;50,0,Inf,true;4,0,Inf,true;0,0,0,true};
    h.TauFit.StartPar{6} = {2,0,Inf,false;1,0,Inf,false;0.4,0,0.4,false;0,-0.4,0.4,false;0,0,1,false;0,0,1,false;0,0,1,false;0,0,1,false;0,0,1,true;0,0,1,true;0,0,0,true};
    h.TauFit.FitPar_Table.Data = h.TauFit.StartPar{1};
    
    %%% Popupmenu to change convolution type
    uicontrol(...
        'Style','text',...
        'Parent',h.TauFit.FitSet_Panel,...
        'Units','normalized',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'Position',[0.05 0.9 0.35 0.07],...
        'String','Convolution Type',...
        'FontSize',12,...
        'Tag','ConvolutionType_Text');
    
    h.TauFit.ConvolutionType_Menu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.TauFit.FitSet_Panel,...
        'Units','normalized',...
        'BackgroundColor',Look.Fore,...
        'ForegroundColor',Look.Back,...
        'Position',[0.4 0.9 0.5 0.07],...
        'String',{'linear','circular'},...
        'Value',find(strcmp({'linear','circular'},UserValues.TauFit.ConvolutionType)),...
        'Tag','ConvolutionType_Menu');
    %% Mac upscaling of Font Sizes
    if ismac
        scale_factor = 1.2;
        fields = fieldnames(h); %%% loop through h structure
        for i = 1:numel(fields)
            if isprop(h.(fields{i}),'FontSize')
                h.(fields{i}).FontSize = (h.(fields{i}).FontSize)*scale_factor;
            end
%             if isprop(h.(fields{i}),'Style')
%                 if strcmp(h.(fields{i}).Style,'popupmenu')
%                     h.(fields{i}).BackgroundColor = Look.Fore;
%                     h.(fields{i}).ForegroundColor = Look.Back;
%                 end
%             end
        end
        fields = fieldnames(h.TauFit); %%% loop through h structure
        for i = 1:numel(fields)
            if isprop(h.TauFit.(fields{i}),'FontSize')
                h.TauFit.(fields{i}).FontSize = (h.TauFit.(fields{i}).FontSize)*scale_factor;
            end
%             if isprop(h.TauFit.(fields{i}),'Style')
%                 if strcmp(h.TauFit.(fields{i}).Style,'popupmenu')
%                     h.TauFit.(fields{i}).BackgroundColor = Look.Fore;
%                     h.TauFit.(fields{i}).ForegroundColor = Look.Back;
%                 end
%             end
        end
    end
    %% Store GUI data
    guidata(h.BurstBrowser,h);
    %%% Initialize Plots
    Initialize_Plots(1);
    %% set UserValues in GUI
    UpdateCorrections([],[]);
    %%% Update ColorMap
    if ischar(UserValues.BurstBrowser.Display.ColorMap)
        eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);
    else
        colormap(UserValues.BurstBrowser.Display.ColorMap);
    end
    %%% Re-Enable Menu
    h.File_Menu.Enable = 'on';
else
    figure(hfig);
end

clearvars -global BurstData BurstTCSPCData

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Initializes/Resets Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Initialize_Plots(mode)
global BurstMeta UserValues
h = guidata(findobj('Tag','BurstBrowser'));
%%% supress warning associated with constant Z data and contour plots
warning('off','MATLAB:contour:ConstantData');
switch mode
    case 1
        %%% Initialize BurstMeta.TauFit
        BurstMeta.TauFit.FitType = h.TauFit.FitMethod_Popupmenu.String{h.TauFit.FitMethod_Popupmenu.Value};
        %%% Initialize Plots in Global Variable
        %%% Enables easy Updating later on
        BurstMeta.Plots = [];
        %%% Main Tab
        BurstMeta.Plots.Main_histX = bar(h.axes_1d_x,0.5,1,'FaceColor',[0 0 0],'BarWidth',1,'UIContextMenu',h.ExportGraph_Menu);
        BurstMeta.Plots.Main_histY = bar(h.axes_1d_y,0.5,1,'FaceColor',[0 0 0],'BarWidth',1,'UIContextMenu',h.ExportGraph_Menu);
        %%% Initialize both image AND contour plots in array
        BurstMeta.Plots.Main_Plot(1) = imagesc(zeros(2),'Parent',h.axes_general,'UIContextMenu',h.ExportGraph_Menu);axis(h.axes_general,'tight');
        [~,BurstMeta.Plots.Main_Plot(2)] = contourf(zeros(2),10,'Parent',h.axes_general,'Visible','off');BurstMeta.Plots.Main_Plot(2).UIContextMenu = h.ExportGraph_Menu;
        %%% Main Tab multiple species (consider up to three)
        BurstMeta.Plots.Multi.Main_Plot_multiple = imagesc(zeros(2),'Parent',h.axes_general,'Visible','off','UIContextMenu',h.ExportGraph_Menu);
        BurstMeta.Plots.Multi.Multi_histX(1) = stairs(h.axes_1d_x,0.5,1,'Color','b','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histX(2) = stairs(h.axes_1d_x,0.5,1,'Color','r','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histX(3) = stairs(h.axes_1d_x,0.5,1,'Color','g','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histY(1) = stairs(h.axes_1d_y,0.5,1,'Color','b','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histY(2) = stairs(h.axes_1d_y,0.5,1,'Color','r','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histY(3) = stairs(h.axes_1d_y,0.5,1,'Color','g','LineWidth',2,'Visible','off');
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
        BurstMeta.Plots.Fits.staticFRET_EvsTauGG = plot(h.axes_EvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG = plot(h.axes_EvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.EvsTauRR(1) = imagesc(zeros(2),'Parent',h.axes_EvsTauRR);axis(h.axes_EvsTauRR,'tight');
        [~,BurstMeta.Plots.EvsTauRR(2)] = contourf(zeros(2),10,'Parent',h.axes_EvsTauRR,'Visible','off');
        BurstMeta.Plots.Fits.AcceptorLifetime_EvsTauRR = plot(h.axes_EvsTauGG,[0],[1],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.rGGvsTauGG(1) = imagesc(zeros(2),'Parent',h.axes_rGGvsTauGG);axis(h.axes_rGGvsTauGG,'tight');
        [~,BurstMeta.Plots.rGGvsTauGG(2)] = contourf(zeros(2),10,'Parent',h.axes_rGGvsTauGG,'Visible','off');
        %%% Consider up to three Perrin lines
        BurstMeta.Plots.Fits.PerrinGG(1) = plot(h.axes_rGGvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinGG(2) = plot(h.axes_rGGvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinGG(3) = plot(h.axes_rGGvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.rRRvsTauRR(1) = imagesc(zeros(2),'Parent',h.axes_rRRvsTauRR);axis(h.axes_rRRvsTauRR,'tight');
        [~,BurstMeta.Plots.rRRvsTauRR(2)] = contourf(zeros(2),10,'Parent',h.axes_rRRvsTauRR,'Visible','off');axis(h.axes_rRRvsTauRR,'tight');
        %%% Consider up to three Perrin lines
        BurstMeta.Plots.Fits.PerrinRR(1) = plot(h.axes_rRRvsTauRR,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinRR(2) = plot(h.axes_rRRvsTauRR,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinRR(3) = plot(h.axes_rRRvsTauRR,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','-','LineWidth',3,'Visible','off');
        %%% Lifetime Tab 3C
        BurstMeta.Plots.E_BtoGRvsTauBB(1) = imagesc(zeros(2),'Parent',h.axes_E_BtoGRvsTauBB);axis(h.axes_E_BtoGRvsTauBB,'tight');
        [~,BurstMeta.Plots.E_BtoGRvsTauBB(2)] = contourf(zeros(2),10,'Parent',h.axes_E_BtoGRvsTauBB,'Visible','off');
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB = plot(h.axes_E_BtoGRvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.rBBvsTauBB(1) = imagesc(zeros(2),'Parent',h.axes_rBBvsTauBB);axis(h.axes_rBBvsTauBB,'tight');
        [~,BurstMeta.Plots.rBBvsTauBB(2)] = contourf(zeros(2),10,'Parent',h.axes_rBBvsTauBB,'Visible','off');
        %%% Consider up to three Perrin lines
        BurstMeta.Plots.Fits.PerrinBB(1) = plot(h.axes_rBBvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinBB(2) = plot(h.axes_rBBvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinBB(3) = plot(h.axes_rBBvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','-','LineWidth',3,'Visible','off');
        %%% fFCS Tab
        BurstMeta.Plots.fFCS.IRF_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species1_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species2_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color',[0 0.5 0],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Total_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        
        BurstMeta.Plots.fFCS.IRF_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species1_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species2_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color',[0 0.5 0],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Total_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        
        BurstMeta.Plots.fFCS.FilterPar_Species1 = plot(h.axes_fFCS_FilterPar,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPar_Species2 = plot(h.axes_fFCS_FilterPar,[0 1],[0 0],'Color',[0 0.5 0],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPar_IRF = plot(h.axes_fFCS_FilterPar,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Reconstruction_Par = plot(h.axes_fFCS_ReconstructionPar,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Reconstruction_Decay_Par = plot(h.axes_fFCS_ReconstructionPar,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Weighted_Residuals_Par = plot(h.axes_fFCS_ReconstructionParResiduals,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        
        BurstMeta.Plots.fFCS.FilterPerp_Species1 = plot(h.axes_fFCS_FilterPerp,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPerp_Species2 = plot(h.axes_fFCS_FilterPerp,[0 1],[0 0],'Color',[0 0.5 0],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPerp_IRF = plot(h.axes_fFCS_FilterPerp,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Reconstruction_Perp = plot(h.axes_fFCS_ReconstructionPerp,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Reconstruction_Decay_Perp = plot(h.axes_fFCS_ReconstructionPerp,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Weighted_Residuals_Perp = plot(h.axes_fFCS_ReconstructionPerpResiduals,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        
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
        
        %%% TauFit
        %%% Microtime Plot
        BurstMeta.Plots.TauFit.Scatter_Par = plot([0 1],[0 0],'LineStyle',':','Color',[0.5 0.5 0.5],'Parent',h.TauFit.Microtime_Plot);
        BurstMeta.Plots.TauFit.Scatter_Per = plot([0 1],[0 0],'LineStyle',':','Color',[0.3 0.3 0.3],'Parent',h.TauFit.Microtime_Plot);
        BurstMeta.Plots.TauFit.Decay_Sum = plot([0 1],[0 0],'--k','Parent',h.TauFit.Microtime_Plot);
        BurstMeta.Plots.TauFit.Decay_Par = plot([0 1],[0 0],'--g','Parent',h.TauFit.Microtime_Plot);
        BurstMeta.Plots.TauFit.Decay_Per = plot([0 1],[0 0],'--r','Parent',h.TauFit.Microtime_Plot);
        BurstMeta.Plots.TauFit.IRF_Par = plot([0 1],[0 0],'.g','Parent',h.TauFit.Microtime_Plot);
        BurstMeta.Plots.TauFit.IRF_Per = plot([0 1],[0 0],'.r','Parent',h.TauFit.Microtime_Plot);
        BurstMeta.Plots.TauFit.FitPreview = plot([0 1],[0 0],'k','Parent',h.TauFit.Microtime_Plot);
        BurstMeta.Plots.TauFit.Ignore_Plot = plot([0 0],[0 1],'Color','k','Visible','off','LineWidth',2,'Parent',h.TauFit.Microtime_Plot);
        %%% Residuals Plot
        BurstMeta.Plots.TauFit.Residuals = plot([0 1],[0 0],'-k','Parent',h.TauFit.Residuals_Plot);
        BurstMeta.Plots.TauFit.Residuals_ZeroLine = plot([0 1],[0 0],'-k','Parent',h.TauFit.Residuals_Plot);
        %%% Result Plot
        BurstMeta.Plots.TauFit.DecayResult = plot([0 1],[0 0],'--k','Parent',h.TauFit.Result_Plot);
        BurstMeta.Plots.TauFit.FitResult = plot([0 1],[0 0],'r','LineWidth',2,'Parent',h.TauFit.Result_Plot);
        %%% Initialize TauFit Variables
        BurstMeta.TauFit.FitType = 'Single Exponential';
        ChangePlotType(h.PlotTypePopumenu,[]);
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
function Close_BurstBrowser(~,~)
global BurstData UserValues BurstTCSPCData
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

clear global -regexp BurstMeta BurstTCSPCData
Pam = findobj('Tag','Pam');
if isempty(Pam)
    clear global -regexp BurstData
end
Phasor=findobj('Tag','Phasor');
FCSFit=findobj('Tag','FCSFit');
MIAFit=findobj('Tag','MIAFit');
Mia=findobj('Tag','Mia');
Sim=findobj('Tag','Sim');
PCF=findobj('Tag','PCF');
TauFit=findobj('Tag','TauFit');
PhasorTIFF = findobj('Tag','PhasorTIFF');
if isempty(Pam) && isempty(Phasor) && isempty(FCSFit) && isempty(MIAFit) && isempty(PCF) && isempty(Mia) && isempty(Sim) && isempty(TauFit) && isempty(PhasorTIFF)
    clear global -regexp UserValues
end

delete(gcf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Load *.bur file  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Burst_Data_Callback(~,~)
h = guidata(gcbo);
global BurstData UserValues BurstMeta PhotonStream BurstTCSPCData
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
if isfield(BurstMeta,'fFCS')
    BurstMeta = rmfield(BurstMeta,'fFCS');
end
if isfield(BurstMeta,'TauFit')
    BurstMeta = rmfield(BurstMeta,'TauFit');
    BurstMeta.TauFit.FitType = h.TauFit.FitMethod_Popupmenu.String{h.TauFit.FitMethod_Popupmenu.Value};
end
if isfield(BurstMeta,'Data')
    BurstMeta = rmfield(BurstMeta,'Data');
end
LSUserValues(0);
[FileName,PathName,FilterIndex] = uigetfile({'*.bur','*.bur file';'*.kba','*.kba file from old PAM'}, 'Choose a file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');

if FileName == 0
    return;
end
%%% clear global variable
%clearvars -global BurstData BurstTCSPCData PhotonStream
BurstData = [];
BurstTCSPCData = [];
PhotonStream = [];

LSUserValues(0);
UserValues.File.BurstBrowserPath=PathName;
LSUserValues(1);
load('-mat',fullfile(PathName,FileName));
BurstData.FileName = fullfile(PathName,FileName);
%%% Determine if an APBS or DCBS file was loaded
%%% This is important because for APBS, the donor only lifetime can be
%%% determined from the measurement!
if ~isempty(strfind(FileName,'APBS')) || ~isempty(strfind(FileName,'ACBS'))
    %%% Enable the donor only lifetime checkbox
    h.DonorLifetimeFromDataCheckbox.Enable = 'on';
    %%% Crosstalk/direct excitation can be determined!
    %%% set flag:
    BurstMeta.APBS = 1;
end

%%% Convert old File Format to new
if FilterIndex == 2 % KBA file was loaded
    switch Data.BAMethod
        case {1,2} %%% 2 Color MFD
            %%% Convert NameArray
            NameArray{strcmp(NameArray,'TFRET - TR')} = '|TGX-TRR| Filter';
            NameArray{strcmp(NameArray,'Number of Photons (green)')} = 'Number of Photons (GG)';
            NameArray{strcmp(NameArray,'Number of Photons (fret)')} = 'Number of Photons (GR)';
            NameArray{strcmp(NameArray,'Number of Photons (red)')} = 'Number of Photons (RR)';
            NameArray{strcmp(NameArray,'Number of Photons (green, parallel)')} = 'Number of Photons (GG par)';
            NameArray{strcmp(NameArray,'Number of Photons (green, perpendicular)')} = 'Number of Photons (GG perp)';
            NameArray{strcmp(NameArray,'Number of Photons (fret, parallel)')} = 'Number of Photons (GR par)';
            NameArray{strcmp(NameArray,'Number of Photons (fret, perpendicular)')} = 'Number of Photons (GR perp)';
            NameArray{strcmp(NameArray,'Number of Photons (red, parallel)')} = 'Number of Photons (RR par)';
            NameArray{strcmp(NameArray,'Number of Photons (red, perpendicular)')} = 'Number of Photons (RR perp)';
            if sum(strcmp(NameArray,'tau(green)')) > 0
                NameArray{strcmp(NameArray,'tau(green)')} = 'Lifetime GG [ns]';
                NameArray{strcmp(NameArray,'tau(red)')} = 'Lifetime RR [ns]';
                DataArray(:,strcmp(NameArray,'Lifetime GG [ns]')) = DataArray(:,strcmp(NameArray,'Lifetime GG [ns]'))*1E9;
                DataArray(:,strcmp(NameArray,'Lifetime RR [ns]')) = DataArray(:,strcmp(NameArray,'Lifetime RR [ns]'))*1E9;
            else %%% create zero value arrays
                NameArray{end+1} = 'Lifetime GG [ns]';
                NameArray{end+1} = 'Lifetime RR [ns]';
                DataArray(:,end+1) = zeros(size(DataArray,1),1);
                DataArray(:,end+1) = zeros(size(DataArray,1),1);
            end
            NameArray{end+1} = 'Anisotropy GG';
            NameArray{end+1} = 'Anisotropy RR';
            %%% Caculate Anisotropies
            DataArray(:,end+1) = (DataArray(:,strcmp(NameArray,'Number of Photons (GG par)')) - DataArray(:,strcmp(NameArray,'Number of Photons (GG perp)')))./...
                (DataArray(:,strcmp(NameArray,'Number of Photons (GG par)')) + 2.*DataArray(:,strcmp(NameArray,'Number of Photons (GG perp)')));
            DataArray(:,end+1) = (DataArray(:,strcmp(NameArray,'Number of Photons (RR par)')) - DataArray(:,strcmp(NameArray,'Number of Photons (RR perp)')))./...
                (DataArray(:,strcmp(NameArray,'Number of Photons (RR par)')) + 2*DataArray(:,strcmp(NameArray,'Number of Photons (RR perp)')));
            
            BurstData.NameArray = NameArray;
            BurstData.DataArray = DataArray;
            BurstData.BAMethod = Data.BAMethod;
            BurstData.FileType = Data.Filetype;
            BurstData.TACRange = Data.TACrange;
            BurstData.SyncPeriod = 1./Data.SyncRate;
            
            BurstData.FileInfo.MI_Bins = 4096;
            BurstData.FileInfo.TACRange = Data.TACrange;
            if isfield(Data,'PIEChannels')
                BurstData.PIE.From = [Data.PIEChannels.fromGG1, Data.PIEChannels.fromGG2,...
                    Data.PIEChannels.fromGR1, Data.PIEChannels.fromGR2,...
                    Data.PIEChannels.fromRR1, Data.PIEChannels.fromRR2];
                BurstData.PIE.To = [Data.PIEChannels.toGG1, Data.PIEChannels.toGG2,...
                    Data.PIEChannels.toGR1, Data.PIEChannels.toGR2,...
                    Data.PIEChannels.toRR1, Data.PIEChannels.toRR2];
            elseif isfield(Data,'fFCS')
                BurstData.PIE.From = Data.fFCS.lower;
                BurstData.PIE.To = Data.fFCS.upper;
            end
            
            %%% Calculate IRF microtime histogram
            if isfield(Data,'IRFmicrotime')
                for i = 1:6
                    BurstData.IRF{i} = histc( Data.IRFmicrotime{i}, 0:(BurstData.FileInfo.MI_Bins-1));
                end
                BurstData.ScatterPattern = BurstData.IRF;
            end
            
            BurstTCSPCData.Macrotime = Data.Macrotime;
            BurstTCSPCData.Microtime = Data.Microtime;
            BurstTCSPCData.Channel = Data.Channel;
            BurstTCSPCData.Macrotime = cellfun(@(x) x',BurstTCSPCData.Macrotime,'UniformOutput',false);
            BurstTCSPCData.Microtime = cellfun(@(x) x',BurstTCSPCData.Microtime,'UniformOutput',false);
            BurstTCSPCData.Channel = cellfun(@(x) x',BurstTCSPCData.Channel,'UniformOutput',false);
        case {3,4} %%% 3Color MFD
            %%% Convert NameArray
            NameArray{strcmp(NameArray,'TG - TR (PIE)')} = '|TGX-TRR| Filter';
            NameArray{strcmp(NameArray,'TB - TR (PIE)')} = '|TBX-TRR| Filter';
            NameArray{strcmp(NameArray,'TB - TG (PIE)')} = '|TBX-TGX| Filter';
            NameArray{strcmp(NameArray,'Efficiency* (G -> R)')} = 'Efficiency GR';
            NameArray{strcmp(NameArray,'Efficiency* (B -> R)')} = 'Efficiency BR';
            NameArray{strcmp(NameArray,'Efficiency* (B -> G)')} = 'Efficiency BG';
            NameArray{strcmp(NameArray,'Efficiency* (B -> G+R)')} = 'Efficiency B->G+R';
            NameArray{strcmp(NameArray,'Stochiometry (GR)')} = 'Stoichiometry GR';
            NameArray{strcmp(NameArray,'Stochiometry (BG)')} = 'Stoichiometry BG';
            NameArray{strcmp(NameArray,'Stochiometry (BR)')} = 'Stoichiometry BR';
            if sum(strcmp(NameArray,'tau(green)')) > 0
                NameArray{strcmp(NameArray,'tau(blue)')} = 'Lifetime BB [ns]';
                NameArray{strcmp(NameArray,'tau(green)')} = 'Lifetime GG [ns]';
                NameArray{strcmp(NameArray,'tau(red)')} = 'Lifetime RR [ns]';
                DataArray(:,strcmp(NameArray,'Lifetime BB [ns]')) = DataArray(:,strcmp(NameArray,'Lifetime BB [ns]'))*1E9;
                DataArray(:,strcmp(NameArray,'Lifetime GG [ns]')) = DataArray(:,strcmp(NameArray,'Lifetime GG [ns]'))*1E9;
                DataArray(:,strcmp(NameArray,'Lifetime RR [ns]')) = DataArray(:,strcmp(NameArray,'Lifetime RR [ns]'))*1E9;
            else %%% create zero value arrays
                NameArray{end+1} = 'Lifetime BB [ns]';
                NameArray{end+1} = 'Lifetime GG [ns]';
                NameArray{end+1} = 'Lifetime RR [ns]';
                DataArray(:,end+1) = zeros(size(DataArray,1),1);
                DataArray(:,end+1) = zeros(size(DataArray,1),1);
                DataArray(:,end+1) = zeros(size(DataArray,1),1);
            end
            NameArray{end+1} = 'Anisotropy BB';
            NameArray{end+1} = 'Anisotropy GG';
            NameArray{end+1} = 'Anisotropy RR';
            %%% Caculate Anisotropies
            DataArray(:,end+1) = (DataArray(:,strcmp(NameArray,'Number of Photons (BB par)')) - DataArray(:,strcmp(NameArray,'Number of Photons (BB perp)')))./...
                (DataArray(:,strcmp(NameArray,'Number of Photons (BB par)')) + 2.*DataArray(:,strcmp(NameArray,'Number of Photons (BB perp)')));
            DataArray(:,end+1) = (DataArray(:,strcmp(NameArray,'Number of Photons (GG par)')) - DataArray(:,strcmp(NameArray,'Number of Photons (GG perp)')))./...
                (DataArray(:,strcmp(NameArray,'Number of Photons (GG par)')) + 2.*DataArray(:,strcmp(NameArray,'Number of Photons (GG perp)')));
            DataArray(:,end+1) = (DataArray(:,strcmp(NameArray,'Number of Photons (RR par)')) - DataArray(:,strcmp(NameArray,'Number of Photons (RR perp)')))./...
                (DataArray(:,strcmp(NameArray,'Number of Photons (RR par)')) + 2*DataArray(:,strcmp(NameArray,'Number of Photons (RR perp)')));
            
            BurstData.NameArray = NameArray;
            BurstData.DataArray = DataArray;
            BurstData.BAMethod = Data.BAMethod;
            BurstData.FileType = Data.Filetype;
            if isfield(Data,'TACrange')
                BurstData.TACRange = Data.TACrange;
                BurstData.FileInfo.TACRange = Data.TACrange;
            else
                BurstData.TACRange =  1E9./Data.SyncRate;
                BurstData.FileInfo.TACRange =  1E9./Data.SyncRate;
            end
            BurstData.SyncPeriod = 1./Data.SyncRate;
            
            BurstData.FileInfo.MI_Bins = 4096;
            
            if isfield(Data,'PIEChannels')
                BurstData.PIE.From = [Data.PIEChannels.fromBB1, Data.PIEChannels.fromBB2,...
                    Data.PIEChannels.fromBG1, Data.PIEChannels.fromBG2,...
                    Data.PIEChannels.fromBR1, Data.PIEChannels.fromBR2,...
                    Data.PIEChannels.fromGG1, Data.PIEChannels.fromGG2,...
                    Data.PIEChannels.fromGR1, Data.PIEChannels.fromGR2,...
                    Data.PIEChannels.fromRR1, Data.PIEChannels.fromRR2];
                BurstData.PIE.To = [Data.PIEChannels.toBB1, Data.PIEChannels.toBB2,...
                    Data.PIEChannels.toBG1, Data.PIEChannels.toBG2,...
                    Data.PIEChannels.toBR1, Data.PIEChannels.toBR2,...
                    Data.PIEChannels.toGG1, Data.PIEChannels.toGG2,...
                    Data.PIEChannels.toGR1, Data.PIEChannels.toGR2,...
                    Data.PIEChannels.toRR1, Data.PIEChannels.toRR2];
            elseif isfield(Data,'fFCS')
                BurstData.PIE.From = Data.fFCS.lower;
                BurstData.PIE.To = Data.fFCS.upper;
            end
            
            %%% Calculate IRF microtime histogram
            if isfield(Data,'IRFmicrotime')
                for i = 1:12
                    BurstData.IRF{i} = histc( Data.IRFmicrotime{i}, 0:(BurstData.FileInfo.MI_Bins-1));
                end
                BurstData.ScatterPattern = BurstData.IRF;
            end
            
            BurstTCSPCData.Macrotime = Data.Macrotime;
            BurstTCSPCData.Microtime = Data.Microtime;
            BurstTCSPCData.Channel = Data.Channel;
            BurstTCSPCData.Macrotime = cellfun(@(x) x',BurstTCSPCData.Macrotime,'UniformOutput',false);
            BurstTCSPCData.Microtime = cellfun(@(x) x',BurstTCSPCData.Microtime,'UniformOutput',false);
            BurstTCSPCData.Channel = cellfun(@(x) x',BurstTCSPCData.Channel,'UniformOutput',false);
    end
end

%%% Update Figure Name
if ~isfield(BurstData,'DisplayName')
    [~,BurstData.DisplayName,~] = fileparts(BurstData.FileName);
end
h.BurstBrowser.Name = ['BurstBrowser - ' BurstData.DisplayName];
h.Progress_Text.String = BurstData.DisplayName;

if any(BurstData.BAMethod == [1,2]) %%% Two-Color MFD
    %find positions of Efficiency and Stoichiometry in NameArray
    posE = find(strcmp(BurstData.NameArray,'Efficiency'));
    %%% Compatibility check for old BurstExplorer Data
    if sum(strcmp(BurstData.NameArray,'Stoichiometry')) == 0
        BurstData.NameArray{strcmp(BurstData.NameArray,'Stochiometry')} = 'Stoichiometry';
    end
    posS = find(strcmp(BurstData.NameArray,'Stoichiometry'));
elseif any(BurstData.BAMethod == [3,4]) %%% Three-Color MFD
    posE = find(strcmp(BurstData.NameArray,'Efficiency GR'));
    posS = find(strcmp(BurstData.NameArray,'Stoichiometry GR'));
end
%%% store posE and posS in BurstMeta
BurstMeta.posE = posE;
BurstMeta.posS = posS;

set(h.ParameterListX, 'String', BurstData.NameArray);
set(h.ParameterListX, 'Value', posE);

set(h.ParameterListY, 'String', BurstData.NameArray);
set(h.ParameterListY, 'Value', posS);

if ~isfield(BurstData,'Cut')
    %initialize Cut Cell Array
    BurstData.Cut{1} = {};
    %add species to list
    BurstData.SpeciesNames{1} = 'Global Cuts';
    %update species list
    set(h.SpeciesList,'String',BurstData.SpeciesNames,'Value',1);
    BurstData.SelectedSpecies = 1;
end

BurstData.DataCut = BurstData.DataArray;

if isfield(BurstData,'SpeciesNames') %%% Previous Cuts exist
    if ~isempty(BurstData.SpeciesNames)
        %%% Update the Species List
        h.SpeciesList.String = BurstData.SpeciesNames;
        h.SpeciesList.Value = BurstData.SelectedSpecies;
    end
end

%%% Reset Plots
Initialize_Plots(2);
UpdateCorrections([],[]);
%%% Switches GUI to 3cMFD or 2cMFD format
SwitchGUI(BurstData.BAMethod);
UpdateCutTable(h);
UpdateCuts();
UpdatePlot([]);
UpdateLifetimePlots([],[]);
DonorOnlyLifetimeCallback(h.DonorLifetimeFromDataCheckbox,[]);
Update_fFCS_GUI(gcbo,[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Update Options in UserValues Structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateOptions(obj,~)
global UserValues
if isempty(obj)
    return;
end
h = guidata(obj);
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
    case h.fFCS_UseTimeWindow
        UserValues.BurstBrowser.Settings.fFCS_UseTimewindow = obj.Value;
end
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Callback for Parameter List: Left-click updates plot,    %%%%%%%%%%
%%%%%%% Right-click adds parameter to CutList                    %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ParameterList_ButtonDownFcn(jListbox,jEventData,hListbox)
% Determine the click type
% (can similarly test for CTRL/ALT/SHIFT-click)
if jEventData.isMetaDown  % right-click is like a Meta-button
    clickType = 'Right-click';
else
    clickType = 'Left-click';
end

% Determine the current listbox index
% Remember: Java index starts at 0, Matlab at 1
mousePos = java.awt.Point(jEventData.getX, jEventData.getY);
clickedIndex = jListbox.locationToIndex(mousePos) + 1;
%listValues = get(hListbox,'string');
%clickedValue = listValues{clickedIndex};

h = guidata(hListbox);
global BurstData

if strcmpi(clickType,'Right-click')
    %%%add to cut list if right-clicked
    if ~isfield(BurstData,'Cut')
        %initialize Cut Cell Array
        BurstData.Cut{1} = {};
        %add species to list
        BurstData.SpeciesNames{1} = 'Global Cuts';
        %update species list
        set(h.SpeciesList,'String',BurstData.SpeciesNames,'Value',1);
        BurstData.SelectedSpecies = 1;
    end
    species = get(h.SpeciesList,'Value');
    param = clickedIndex;
    
    %%% Check whether the CutParameter already exists or not
    ExistingCuts = vertcat(BurstData.Cut{species}{:});
    if ~isempty(ExistingCuts)
        if any(strcmp(BurstData.NameArray{param},ExistingCuts(:,1)))
            return;
        end
    end
    
    BurstData.Cut{species}{end+1} = {BurstData.NameArray{param}, min(BurstData.DataArray(:,param)),max(BurstData.DataArray(:,param)), true,false};
    
    %%% If Global Cuts, Update all other species
    if species == 1
        ChangedParameterName = BurstData.NameArray{param};
        if numel(BurstData.Cut) > 1 %%% Check if there are other species defined
            %%% cycle through the number of other species
            for j = 2:numel(BurstData.Cut)
                %%% Check if the parameter already exists in the species j
                ParamList = vertcat(BurstData.Cut{j}{:});
                if ~isempty(ParamList)
                    ParamList = ParamList(1:numel(BurstData.Cut{j}),1);
                    CheckParam = strcmp(ParamList,ChangedParameterName);
                    if any(CheckParam)
                        %%% do nothing
                    else %%% Parameter is new to species
                        BurstData.Cut{j}(end+1) = BurstData.Cut{1}(end);
                    end
                else %%% Parameter is new to GlobalCut
                    BurstData.Cut{j}(end+1) = BurstData.Cut{1}(end);
                end
            end
        end
    end
    UpdateCutTable(h);
    UpdateCuts();
    %UpdateCorrections;
elseif strcmpi(clickType,'Left-click') %%% Update Plot
    %%% Update selected value
    hListbox.Value = clickedIndex;
end
UpdatePlot([],[]);
UpdateLifetimePlots([],[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Mouse-click Callback for Species List       %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Left-click: Change plot to selected Species %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Right-click: Open menu                      %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SpeciesList_ButtonDownFcn(jListbox,jEventData,hListbox)
% Determine the click type
% (can similarly test for CTRL/ALT/SHIFT-click)
if jEventData.isMetaDown  % right-click is like a Meta-button
    clickType = 'Right-click';
else
    clickType = 'Left-click';
end


% Determine the current listbox index
% Remember: Java index starts at 0, Matlab at 1
mousePos = java.awt.Point(jEventData.getX, jEventData.getY);
clickedIndex = jListbox.locationToIndex(mousePos) + 1;

listValues = get(hListbox,'string');
if isempty(listValues)
    return;
end

clickedString = listValues{clickedIndex};

h = guidata(hListbox);
global BurstData
if strcmpi(clickType,'Right-click')
    %     if numel(get(hListbox,'String')) > 1 %remove selected field
    %         val = clickedIndex;
    %         BurstData.SpeciesNames(val) = [];
    %         set(hListbox,'Value',val-1);
    %         set(hListbox,'String',BurstData.SpeciesNames);
    %     end
else %leftclick
    set(hListbox,'Value',clickedIndex);
    BurstData.SelectedSpecies = clickedIndex;
end
UpdateCutTable(h);
UpdateCuts();
UpdatePlot(hListbox);
Update_fFCS_GUI(hListbox,[]);
UpdateLifetimePlots(hListbox,[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Add Species to List (Right-click menu item)  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AddSpecies(~,~)
global BurstData
h = guidata(findobj('Tag','BurstBrowser'));
hListbox = h.SpeciesList;
%add a species to the list
BurstData.SpeciesNames{end+1} = ['Species ' num2str(numel(get(hListbox,'String')))];
set(hListbox,'String',BurstData.SpeciesNames);
%set to new species
set(hListbox,'Value',numel(get(hListbox,'String')));
BurstData.SelectedSpecies = get(hListbox,'Value');

%initialize new species Cut array - Copy from Global Cuts
BurstData.Cut{BurstData.SelectedSpecies} = BurstData.Cut{1};

UpdateCutTable(h);
UpdateCuts();
UpdatePlot([],[]);
UpdateLifetimePlots([],[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Remove Selected Species (Right-click menu item)  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RemoveSpecies(~,~)
global BurstData
h = guidata(findobj('Tag','BurstBrowser'));
if numel(get(h.SpeciesList,'String')) > 1 %remove selected field
    val = h.SpeciesList.Value;
    BurstData.SpeciesNames(val) = [];
    set(h.SpeciesList,'Value',val-1);
    set(h.SpeciesList,'String',BurstData.SpeciesNames);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Rename Selected Species (Right-click menu item)  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RenameSpecies(~,~)
global BurstData
h = guidata(findobj('Tag','BurstBrowser'));
SelectedSpecies = h.SpeciesList.Value;
SelectedSpeciesName = BurstData.SpeciesNames{SelectedSpecies};
NewName = inputdlg('Specify the new species name','Rename Species',[1 50],{SelectedSpeciesName},'on');

if ~isempty(NewName)
    BurstData.SpeciesNames{SelectedSpecies} = NewName{1};
    set(h.SpeciesList,'String',BurstData.SpeciesNames);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export Photons for PDA analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export_To_PDA(obj,~)
global BurstData BurstTCSPCData UserValues
h = guidata(findobj('Tag','BurstBrowser'));
SelectedSpecies = h.SpeciesList.Value;
SelectedSpeciesName = BurstData.SpeciesNames{SelectedSpecies};

%Valid = UpdateCuts(SelectedSpecies);
Progress(0,h.Progress_Axes,h.Progress_Text,'Exporting...');
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData)
    Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
    if exist([BurstData.FileName(1:end-3) 'bps'],'file') == 2
        %%% load if it exists
        load([BurstData.FileName(1:end-3) 'bps'],'-mat');
    else
        %%% else ask for the file
        [FileName,PathName] = uigetfile({'*.bps'}, 'Choose the associated *.bps file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');
        if FileName == 0
            return;
        end
        load('-mat',fullfile(PathName,FileName));
        %%% Store the correct Path in TauFitBurstData
        BurstData.FileName = fullfile(PathName,[FileName(1:end-3) 'bur']);
    end
    BurstTCSPCData.Macrotime = Macrotime;
    BurstTCSPCData.Microtime = Microtime;
    BurstTCSPCData.Channel = Channel;
    clear Macrotime Microtime Channel
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Exporting...');
%%% find selected bursts
MT = BurstTCSPCData.Macrotime(BurstData.Selected);
CH = BurstTCSPCData.Channel(BurstData.Selected);
%%% Hard-Code 1ms here
timebin = 1E-3;
duration = timebin/BurstData.SyncPeriod;
%%% Get the maximum number of bins possible in data set
max_duration = ceil(max(cellfun(@(x) x(end)-x(1),MT))./duration);

Progress(0.1,h.Progress_Axes,h.Progress_Text,'Exporting...');

%convert absolute macrotimes to relative macrotimes
bursts = cellfun(@(x) x-x(1)+1,MT,'UniformOutput',false);

Progress(0.2,h.Progress_Axes,h.Progress_Text,'Exporting...');

%bin the bursts according to dur, up to max_duration
bins = cellfun(@(x) histc(x,duration.*[0:1:max_duration]),bursts,'UniformOutput',false);

Progress(0.3,h.Progress_Axes,h.Progress_Text,'Exporting...');
%remove last bin
last_bin = cellfun(@(x) find(x,1,'last'),bins,'UniformOutput',false);
for i = 1:numel(bins)
    bins{i}(last_bin{i}) = 0;
    %remove zero bins
    bins{i}(bins{i} == 0) = [];
end

Progress(0.4,h.Progress_Axes,h.Progress_Text,'Exporting...');
%total number of bins is:
n_bins = sum(cellfun(@numel,bins));

Progress(0.5,h.Progress_Axes,h.Progress_Text,'Exporting...');

%construct cumsum of bins
cumsum_bins = cellfun(@(x) [0; cumsum(x)],bins,'UniformOutput',false);

Progress(0.6,h.Progress_Axes,h.Progress_Text,'Exporting...');

%get channel information --> This is the only relavant information for PDA!
PDAdata = cell(n_bins,1);
index = 1;
for i = 1:numel(CH)
    for j = 2:numel(cumsum_bins{i})
        PDAdata{index,1} = CH{i}(cumsum_bins{i}(j-1)+1:cumsum_bins{i}(j));
        index = index + 1;
    end
end

Progress(0.7,h.Progress_Axes,h.Progress_Text,'Exporting...');

%now save channel wise photon numbers
total = n_bins;
newfilename = GenerateName([BurstData.FileName(1:end-4) '_' SelectedSpeciesName '_' num2str(timebin*1000) 'ms.pda']);
switch BurstData.BAMethod
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
        
        PDA.Corrections = BurstData.Corrections;
        PDA.Background = BurstData.Background;
        save(newfilename, 'PDA', 'timebin')
    case {3,4}
        switch obj
            case h.ExportSpeciesToPDAMenuItem
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
                tcPDAstruct.corrections = BurstData.Corrections;
                tcPDAstruct.background = BurstData.Background;
                newfilename = [BurstData.FileName(1:end-4) '_' SelectedSpeciesName '_' num2str(timebin*1000) 'ms.tcpda'];
                save(newfilename, 'tcPDAstruct', 'timebin')
            case h.ExportSpeciesToPDA_2C_for3CMFD_MenuItem
                PDA.NGP = zeros(total,1);
                PDA.NGS = zeros(total,1);
                PDA.NFP = zeros(total,1);
                PDA.NFS = zeros(total,1);
                PDA.NRP = zeros(total,1);
                PDA.NRS = zeros(total,1);

                PDA.NG = zeros(total,1);
                PDA.NF = zeros(total,1);
                PDA.NR = zeros(total,1);

                PDA.NGP = cellfun(@(x) sum((x==7)),PDAdata);
                PDA.NGS = cellfun(@(x) sum((x==8)),PDAdata);
                PDA.NFP = cellfun(@(x) sum((x==9)),PDAdata);
                PDA.NFS = cellfun(@(x) sum((x==10)),PDAdata);
                PDA.NRP = cellfun(@(x) sum((x==11)),PDAdata);
                PDA.NRS = cellfun(@(x) sum((x==12)),PDAdata);

                PDA.NG = PDA.NGP + PDA.NGS;
                PDA.NF = PDA.NFP + PDA.NFS;
                PDA.NR = PDA.NRP + PDA.NRS;

                PDA.Corrections = BurstData.Corrections;
                PDA.Background = BurstData.Background;
                save(newfilename, 'PDA', 'timebin')
        end
end

Progress(1,h.Progress_Axes,h.Progress_Text);
h.Progress_Text.String = BurstData.DisplayName;
%%% Set tcPDA Path to BurstBrowser Path
UserValues.tcPDA.PathName = UserValues.File.BurstBrowserPath;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export Microtime Pattern for fFCS analysis %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export_Microtime_Pattern(~,~)
global BurstData BurstTCSPCData UserValues
h = guidata(findobj('Tag','BurstBrowser'));
SelectedSpecies = h.SpeciesList.Value;
SelectedSpeciesName = BurstData.SpeciesNames{SelectedSpecies};

%Valid = UpdateCuts(SelectedSpecies);
Progress(0,h.Progress_Axes,h.Progress_Text,'Exporting...');
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData)
    Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
    if exist([BurstData.FileName(1:end-3) 'bps'],'file') == 2
        %%% load if it exists
        load([BurstData.FileName(1:end-3) 'bps'],'-mat');
    else
        %%% else ask for the file
        [FileName,PathName] = uigetfile({'*.bps'}, 'Choose the associated *.bps file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');
        if FileName == 0
            return;
        end
        load('-mat',fullfile(PathName,FileName));
        %%% Store the correct Path in TauFitBurstData
        BurstData.FileName = fullfile(PathName,[FileName(1:end-3) 'bur']);
    end
    BurstTCSPCData.Macrotime = Macrotime;
    BurstTCSPCData.Microtime = Microtime;
    BurstTCSPCData.Channel = Channel;
    clear Macrotime Microtime Channel
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Exporting...');
%%% find selected bursts
MI = BurstTCSPCData.Microtime(BurstData.Selected);
CH = BurstTCSPCData.Channel(BurstData.Selected);

MI = vertcat(MI{:});
CH = vertcat(CH{:});

hMI = cell(6,1);
for i = 1:6 %%% 6 Channels (GG1,GG2,GR1,GR2,RR1,RR2)
   hMI{i} = histc(MI(CH == i),0:(BurstData.FileInfo.MI_Bins-1)); 
end

Progress(0.5,h.Progress_Axes,h.Progress_Text,'Exporting...');

species = SelectedSpeciesName;
newfilename = [BurstData.FileName(1:end-4) '_' SelectedSpeciesName '.mi'];
save(newfilename, 'hMI', 'species');
Progress(1,h.Progress_Axes,h.Progress_Text);
h.Progress_Text.String = BurstData.DisplayName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Plot in the Main Axis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdatePlot(obj,~)
%% Preparation
global BurstData UserValues BurstMeta
if isempty(BurstData)
    return;
end
h = guidata(findobj('Tag','BurstBrowser'));
LSUserValues(0);
% if (gcbo ~= h.DetermineCorrectionsButton) && (gcbo ~= h.DetermineGammaManuallyButton) && (h.Main_Tab.SelectedTab ~= h.Main_Tab_Lifetime) && (gcbo ~= h.DetermineGammaLifetimeButton)
%     %%% Change focus to GeneralTab
%     h.Main_Tab.SelectedTab = h.Main_Tab_General;
% end
%%% If a display option was changed, update the UserValues!
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
    UpdateLifetimePlots([],[]);
end
if obj == h.ContourOffset_edit
    ContourOffset = str2double(h.ContourOffset_edit.String);
    if ~isnan(ContourOffset)
        if ContourOffset >=0 && ContourOffset<=100
            UserValues.BurstBrowser.Display.ContourOffset = ContourOffset;
        else
            h.ContourOffset_edit.String = UserValues.BurstBrowser.Display.ContourOffset;
        end
    else
        h.ContourOffset_edit.String = num2str(UserValues.BurstBrowser.Display.ContourOffset);
    end
    UpdateLifetimePlots([],[]);
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
LSUserValues(1);

x = get(h.ParameterListX,'Value');
y = get(h.ParameterListY,'Value');

%%% Read out the Number of Bins
nbinsX = UserValues.BurstBrowser.Display.NumberOfBinsX;
nbinsY = UserValues.BurstBrowser.Display.NumberOfBinsY;

%% Update Plot
%%% Disable/Enable respective plots
switch UserValues.BurstBrowser.Display.PlotType
    case 'Image'
        BurstMeta.Plots.Main_Plot(1).Visible = 'on';
        BurstMeta.Plots.Main_Plot(2).Visible = 'off';
    case 'Contour'
        BurstMeta.Plots.Main_Plot(1).Visible = 'off';
        BurstMeta.Plots.Main_Plot(2).Visible = 'on';
end
BurstMeta.Plots.Main_histX.Visible = 'on';
BurstMeta.Plots.Main_histY.Visible = 'on';
BurstMeta.Plots.Multi.Main_Plot_multiple.Visible = 'off';
set(BurstMeta.Plots.Multi.Multi_histX,'Visible','off');
set(BurstMeta.Plots.Multi.Multi_histY,'Visible','off');

datatoplot = BurstData.DataCut;

[H, xbins,ybins] = calc2dhist(datatoplot(:,x),datatoplot(:,y),[nbinsX nbinsY]);

if(get(h.Hist_log10, 'Value'))
    H = log10(H);
end

%%% Update Image Plot and Contour Plot
BurstMeta.Plots.Main_Plot(1).XData = xbins;
BurstMeta.Plots.Main_Plot(1).YData = ybins;
BurstMeta.Plots.Main_Plot(1).CData = H;
if ~UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.Main_Plot(1).AlphaData = (H > 0);
elseif UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.Main_Plot(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
end
BurstMeta.Plots.Main_Plot(2).XData = xbins;
BurstMeta.Plots.Main_Plot(2).YData = ybins;
BurstMeta.Plots.Main_Plot(2).ZData = H/max(max(H));
BurstMeta.Plots.Main_Plot(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);

axis(h.axes_general,'tight');
%%% Update Labels
xlabel(h.axes_general,h.ParameterListX.String{x});
ylabel(h.axes_general,h.ParameterListY.String{y});
xlabel(h.axes_1d_x,h.ParameterListX.String{x});
%xlabel(h.axes_1d_y,h.ParameterListY.String{y}, 'rot', -90);


[H, xbins,ybins] = calc2dhist(datatoplot(:,x),datatoplot(:,y),[nbinsX nbinsY]);

%plot 1D hists
%hx = histc(datatoplot(:,x),xbins_1d);
%hx(end-1) = hx(end-1) + hx(end); hx(end) = [];
BurstMeta.Plots.Main_histX.XData = xbins;
%BurstMeta.Plots.Main_histX.YData = hx;
BurstMeta.Plots.Main_histX.YData = sum(H,1);
h.axes_1d_x.YTickMode = 'auto';
yticks= get(h.axes_1d_x,'YTick');
set(h.axes_1d_x,'YTick',yticks(2:end));

%hy = histc(datatoplot(:,y),ybins_1d);
%hy(end-1) = hy(end-1) + hy(end); hy(end) = [];
BurstMeta.Plots.Main_histY.XData = ybins;
%BurstMeta.Plots.Main_histY.YData = hy;
BurstMeta.Plots.Main_histY.YData = sum(H,2);
h.axes_1d_y.YTickMode = 'auto';
yticks = get(h.axes_1d_y,'YTick');
set(h.axes_1d_y,'YTick',yticks(2:end));

%%% set axes limits
CutState = vertcat(BurstData.Cut{BurstData.SelectedSpecies}{:});
if size(CutState,2) > 0
    CutParameters = CutState(:,1);
    if any(strcmp(BurstData.NameArray{x},CutParameters))
        if CutState{strcmp(BurstData.NameArray{x},CutParameters),4} == 1 %%% Check if active
            %%% Set x-axis limits according to cut boundaries of selected parameter
            xlimits = [CutState{strcmp(BurstData.NameArray{x},CutParameters),2},...
                CutState{strcmp(BurstData.NameArray{x},CutParameters),3}];
        else
            %%% set to min max
            xlimits = [min(datatoplot(:,x)), max(datatoplot(:,x))];
        end
    else
        %%% set to min max
        xlimits = [min(datatoplot(:,x)), max(datatoplot(:,x))];
    end
    
    if any(strcmp(BurstData.NameArray{y},CutParameters))
        if CutState{strcmp(BurstData.NameArray{y},CutParameters),4} == 1 %%% Check if active
            %%% Set x-axis limits according to cut boundaries of selected parameter
            ylimits = [CutState{strcmp(BurstData.NameArray{y},CutParameters),2},...
                CutState{strcmp(BurstData.NameArray{y},CutParameters),3}];
        else
            %%% set to min max
            ylimits = [min(datatoplot(:,y)), max(datatoplot(:,y))];
        end
    else
        %%% set to min max
        ylimits = [min(datatoplot(:,y)), max(datatoplot(:,y))];
    end
    if sum(xlimits == [0,0]) == 2
        xlimits = [0 1];
    end
    if sum(ylimits == [0,0]) == 2
        ylimits = [0 1];
    end
    %%% set limits of axes
    xlim(h.axes_general,xlimits);
    ylim(h.axes_general,ylimits);
    xlim(h.axes_1d_x,xlimits);
    xlim(h.axes_1d_y,ylimits);
else
    %%% set limits of axes
    axis(h.axes_general,'tight');
    axis(h.axes_1d_x,'tight');
    axis(h.axes_1d_y,'tight');
end
%%% Update ColorMap
if ischar(UserValues.BurstBrowser.Display.ColorMap)
    eval(['colormap(h.BurstBrowser,' UserValues.BurstBrowser.Display.ColorMap ')']);
else
    colormap(h.BurstBrowser,UserValues.BurstBrowser.Display.ColorMap);
end
if UserValues.BurstBrowser.Display.ColorMapInvert
    colormap(flipud(colormap));
end
% Update no. bursts
set(h.text_nobursts, 'String', {[num2str(sum(BurstData.Selected)) ' bursts']; [num2str(round(sum(BurstData.Selected/numel(BurstData.Selected)*1000))/10) '% of total']})

if h.DisplayAverage.Value == 1
    h.axes_1d_x_text.Visible = 'on';
    h.axes_1d_y_text.Visible = 'on';
    % Update average value X histogram
    x = get(BurstMeta.Plots.Main_histX, 'XData');
    y = get(BurstMeta.Plots.Main_histX, 'YData');
    avg = sum(x.*y)/sum(y);
    if avg < 1
        rounding = 100;
    elseif avg < 10
        rounding = 10;
    else
        rounding = 1;
    end
    stdev = round(sqrt(sum((y.*(x-avg).^2))/(sum(y)-1))*rounding)/rounding;
    avg = round(avg*rounding)/rounding;
    set(h.axes_1d_x_text, 'String', sprintf('avg = %.2f%c%.2f',avg,char(177),stdev))
    
    % Update average value Y histogram
    x = get(BurstMeta.Plots.Main_histY, 'XData');
    y = get(BurstMeta.Plots.Main_histY, 'YData');
    avg = sum(x.*y)/sum(y);
    if avg < 1
        rounding = 100;
    elseif avg < 10
        rounding = 10;
    else
        rounding = 1;
    end
    stdev = round(sqrt(sum((y.*(x-avg).^2))/(sum(y)-1))*rounding)/rounding;
    avg = round(avg*rounding)/rounding;
    set(h.axes_1d_y_text, 'String', sprintf('avg = %.2f%c%.2f',avg,char(177),stdev))
else
    h.axes_1d_x_text.Visible = 'off';
    h.axes_1d_y_text.Visible = 'off';
end

drawnow;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Changes PlotType  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangePlotType(obj,~)
global UserValues BurstMeta
h = guidata(obj);
switch obj
    case h.PlotTypePopumenu
        UserValues.BurstBrowser.Display.PlotType = obj.String{obj.Value};
        fields = fieldnames(BurstMeta.Plots); %%% loop through h structure
        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Image')
            %%% Make Image Plots Visible, Hide Contourf Plots
            for i = 1:numel(fields)
                if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                    if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                        BurstMeta.Plots.(fields{i})(1).Visible = 'on';
                        BurstMeta.Plots.(fields{i})(2).Visible = 'off';
                    end
                end
            end
        end
        
        if strcmp(UserValues.BurstBrowser.Display.PlotType,'Contour')
            %%% Make Image Plots Visible, Hide Contourf Plots
            for i = 1:numel(fields)
                if isprop(BurstMeta.Plots.(fields{i})(1),'Type')
                    if strcmp(BurstMeta.Plots.(fields{i})(1).Type,'image')
                        BurstMeta.Plots.(fields{i})(1).Visible = 'off';
                        BurstMeta.Plots.(fields{i})(2).Visible = 'on';
                    end
                end
            end
        end
    case h.PlotContourLines
        UserValues.BurstBrowser.Display.PlotContourLines = h.PlotContourLines.Value;
        fields = fieldnames(BurstMeta.Plots); %%% loop through h structure
        for i = 1:numel(fields)
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
LSUserValues(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Plots the Species in one Plot (not considering GlobalCuts)  %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MultiPlot(~,~)
h = guidata(findobj('Tag','BurstBrowser'));
global BurstData UserValues BurstMeta

x = get(h.ParameterListX,'Value');
y = get(h.ParameterListY,'Value');

%%% Read out the Number of Bins
nbinsX = UserValues.BurstBrowser.Display.NumberOfBinsX;
nbinsY = UserValues.BurstBrowser.Display.NumberOfBinsY;
num_species = numel(get(h.SpeciesList,'String')) - 1;
if num_species == 1
    return;
end
if num_species > 3
    num_species = 3;
end

datatoplot = cell(num_species,1);
for i = 1:num_species
    UpdateCuts(i+1);
    if ~isfield(BurstData,'Cut') || isempty(BurstData.Cut{i+1})
        datatoplot{i} = BurstData.DataArray;
    elseif isfield(BurstData,'Cut')
        datatoplot{i} = BurstData.DataCut;
    end
end

%find data ranges
minx = zeros(num_species,1);
miny = zeros(num_species,1);
maxx = zeros(num_species,1);
maxy = zeros(num_species,1);
for i = 1:num_species
    minx(i) = min(datatoplot{i}(isfinite(datatoplot{i}(:,x)),x));
    miny(i) = min(datatoplot{i}(isfinite(datatoplot{i}(:,y)),y));
    maxx(i) = max(datatoplot{i}(isfinite(datatoplot{i}(:,x)),x));
    maxy(i) = max(datatoplot{i}(isfinite(datatoplot{i}(:,y)),y));
end
x_boundaries = [min(minx) max(maxx)];
y_boundaries = [min(miny) max(maxy)];

H = cell(num_species,1);
for i = 1:num_species
    [H{i}, xbins, ybins] = calc2dhist(datatoplot{i}(:,x), datatoplot{i}(:,y),[nbinsX,nbinsY], x_boundaries, y_boundaries);
end


%%% prepare image plot
white = 1;
axes(h.axes_general);
if num_species == 2
    H{1}(isnan(H{1})) = 0;
    H{2}(isnan(H{2})) = 0;
    if white == 0
        zz = zeros(size(H{1},1),size(H{1},2),3);
        zz(:,:,3) = H{1}/max(max(H{1})); %%% blue
        zz(:,:,1) = H{2}/max(max(H{2})); %%% red
    elseif white == 1
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
        zz(:,:,3) = H{1}/max(max(H{1})); %%% blue
        zz(:,:,1) = H{2}/max(max(H{2})); %%% red
        zz(:,:,2) = H{3}/max(max(H{3})); %%% green
    elseif white == 1
        zz = ones(size(H{1},1),size(H{1},2),3);
        zz(:,:,1) = zz(:,:,1) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{2}./max(max(H{2})); %%% red
        zz(:,:,3) = zz(:,:,3) - H{2}./max(max(H{2})); %%% red
        zz(:,:,1) = zz(:,:,1) - H{3}./max(max(H{3})); %%% green
        zz(:,:,3) = zz(:,:,3) - H{3}./max(max(H{3})); %%% greenrt?f?
    end
else
    return;
end


%%% plot
set(BurstMeta.Plots.Main_Plot,'Visible','off');
BurstMeta.Plots.Main_histX.Visible = 'off';
BurstMeta.Plots.Main_histY.Visible = 'off';
BurstMeta.Plots.Multi.Main_Plot_multiple.Visible = 'on';

BurstMeta.Plots.Multi.Main_Plot_multiple.XData = xbins;
BurstMeta.Plots.Multi.Main_Plot_multiple.YData = ybins;
BurstMeta.Plots.Multi.Main_Plot_multiple.CData = zz;

xlabel(h.axes_general,h.ParameterListX.String{x});
ylabel(h.axes_general,h.ParameterListY.String{y});

%plot first histogram
hx = sum(H{1},1);
%normalize
hx = hx./sum(hx); hx = hx';
BurstMeta.Plots.Multi.Multi_histX(1).Visible = 'on';
BurstMeta.Plots.Multi.Multi_histX(1).XData = xbins;
BurstMeta.Plots.Multi.Multi_histX(1).YData = hx;
%plot rest of histograms
for i = 2:num_species
    BurstMeta.Plots.Multi.Multi_histX(i).Visible = 'on';
    hx = sum(H{i},1);
    %normalize
    hx = hx./sum(hx); hx = hx';
    BurstMeta.Plots.Multi.Multi_histX(i).XData = xbins;
    BurstMeta.Plots.Multi.Multi_histX(i).YData = hx;
end

yticks = get(h.axes_1d_x,'YTick');
set(h.axes_1d_x,'YTick',yticks(2:end));

%plot first histogram
hy = sum(H{1},2);
%normalize
hy = hy./sum(hy); hy = hy';
BurstMeta.Plots.Multi.Multi_histY(1).Visible = 'on';
BurstMeta.Plots.Multi.Multi_histY(1).XData = ybins;
BurstMeta.Plots.Multi.Multi_histY(1).YData = hy;
%plot rest of histograms
for i = 2:num_species
    BurstMeta.Plots.Multi.Multi_histY(i).Visible = 'on';
    hy = sum(H{i},2);
    %normalize
    hy = hy./sum(hy); hy = hy';
    BurstMeta.Plots.Multi.Multi_histY(i).XData = ybins;
    BurstMeta.Plots.Multi.Multi_histY(i).YData = hy;
end
yticks = get(h.axes_1d_y,'YTick');
set(h.axes_1d_y,'YTick',yticks(2:end));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Manual Cut by selecting an area in the current selection  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ManualCut(~,~)

h = guidata(gcbo);
global BurstData
set(gcf,'Pointer','cross');
k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;           % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
set(gcf,'Pointer','Arrow');
point1 = point1(1,1:2);
point2 = point2(1,1:2);

if (all(point1(1:2) == point2(1:2)))
    disp('error');
    return;
end

if ~isfield(BurstData,'Cut')
    %initialize Cut Cell Array
    BurstData.Cut{1} = {};
    %add species to list
    BurstData.SpeciesNames{1} = 'Species 1';
    %update species list
    set(h.SpeciesList,'String',BurstData.SpeciesNames,'Value',1);
    BurstData.SelectedSpecies = 1;
end

species = get(h.SpeciesList,'Value');

%%% Check whether the CutParameter already exists or not
ExistingCuts = vertcat(BurstData.Cut{species}{:});
param_x = get(h.ParameterListX,'Value');
param_y = get(h.ParameterListY,'Value');
if ~isempty(ExistingCuts)
    if any(strcmp(BurstData.NameArray{param_x},ExistingCuts(:,1)))
        BurstData.Cut{species}{strcmp(BurstData.NameArray{param_x},ExistingCuts(:,1))} = {BurstData.NameArray{get(h.ParameterListX,'Value')}, min([point1(1) point2(1)]),max([point1(1) point2(1)]), true,false};
    else
        BurstData.Cut{species}{end+1} = {BurstData.NameArray{get(h.ParameterListX,'Value')}, min([point1(1) point2(1)]),max([point1(1) point2(1)]), true,false};
    end
    
    if any(strcmp(BurstData.NameArray{param_y},ExistingCuts(:,1)))
        BurstData.Cut{species}{strcmp(BurstData.NameArray{param_y},ExistingCuts(:,1))} = {BurstData.NameArray{get(h.ParameterListY,'Value')}, min([point1(2) point2(2)]),max([point1(2) point2(2)]), true,false};
    else
        BurstData.Cut{species}{end+1} = {BurstData.NameArray{get(h.ParameterListY,'Value')}, min([point1(2) point2(2)]),max([point1(2) point2(2)]), true,false};
    end
else
    BurstData.Cut{species}{end+1} = {BurstData.NameArray{get(h.ParameterListX,'Value')}, min([point1(1) point2(1)]),max([point1(1) point2(1)]), true,false};
    BurstData.Cut{species}{end+1} = {BurstData.NameArray{get(h.ParameterListY,'Value')}, min([point1(2) point2(2)]),max([point1(2) point2(2)]), true,false};
end

%%% If a change was made to the GlobalCuts Species, update all other
%%% existent species with the changes
if BurstData.SelectedSpecies == 1
    if numel(BurstData.Cut) > 1 %%% Check if there are other species defined
        ChangedParamX = BurstData.NameArray{get(h.ParameterListX,'Value')};
        ChangedParamY = BurstData.NameArray{get(h.ParameterListY,'Value')};
        GlobalParams = vertcat(BurstData.Cut{1}{:});
        GlobalParams = GlobalParams(1:numel(BurstData.Cut{1}),1);
        %%% cycle through the number of other species
        for j = 2:numel(BurstData.Cut)
            %%% Check if the parameter already exists in the species j
            ParamList = vertcat(BurstData.Cut{j}{:});
            if ~isempty(ParamList)
                ParamList = ParamList(1:numel(BurstData.Cut{j}),1);
                CheckParam = strcmp(ParamList,ChangedParamX);
                if any(CheckParam)
                    %%% Parameter added or changed
                    %%% Override the parameter with GlobalCut
                    BurstData.Cut{j}(CheckParam) = BurstData.Cut{1}(strcmp(GlobalParams,ChangedParamX));
                else %%% Parameter is new to GlobalCut
                    BurstData.Cut{j}(end+1) = BurstData.Cut{1}(strcmp(GlobalParams,ChangedParamX));
                end
            else %%% Parameter is new to GlobalCut
                BurstData.Cut{j}(end+1) = BurstData.Cut{1}(strcmp(GlobalParams,ChangedParamX));
            end
        end
        for j = 2:numel(BurstData.Cut)
            %%% Check if the parameter already exists in the species j
            ParamList = vertcat(BurstData.Cut{j}{:});
            if ~isempty(ParamList)
                ParamList = ParamList(1:numel(BurstData.Cut{j}),1);
                CheckParam = strcmp(ParamList,ChangedParamY);
                if any(CheckParam)
                    %%% Parameter added or changed
                    %%% Override the parameter with GlobalCut
                    BurstData.Cut{j}(CheckParam) = BurstData.Cut{1}(strcmp(GlobalParams,ChangedParamY));
                else %%% Parameter is new to GlobalCut
                    BurstData.Cut{j}(end+1) = BurstData.Cut{1}(strcmp(GlobalParams,ChangedParamY));
                end
            else %%% Parameter is new to GlobalCut
                BurstData.Cut{j}(end+1) = BurstData.Cut{1}(strcmp(GlobalParams,ChangedParamY));
            end
        end
    end
end

UpdateCutTable(h);
UpdateCuts();
UpdatePlot([],[]);
UpdateLifetimePlots([],[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates/Initializes the Cut Table in GUI with stored Cuts  %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateCutTable(h)
global BurstData
species = BurstData.SelectedSpecies;

if ~isempty(BurstData.Cut{species})
    data = vertcat(BurstData.Cut{species}{:});
    rownames = data(:,1);
    data = data(:,2:end);
else %data has been deleted, reset to default values
    data = {'','',false,false};
    rownames = {''};
end

set(h.CutTable,'Data',data,'RowName',rownames);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Applies Cuts to Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Valid] = UpdateCuts(species)
global BurstData
%%% If no species is specified, read out selected species.
if nargin < 1
    species = BurstData.SelectedSpecies;
end

%%% If species number is to high, return
if species > numel(BurstData.SpeciesNames)
    return;
end
%%% If no Cuts are specified yet, return.
if ~isfield(BurstData,'Cut')
    return;
end

CutState = vertcat(BurstData.Cut{species}{:});
Valid = true(size(BurstData.DataArray,1),1);
if ~isempty(CutState) %%% only procede if there are elements in the CutTable
    for i = 1:size(CutState,1)
        if CutState{i,4} == 1 %%% only if the Cut is set to "active"
            Index = find(strcmp(CutState(i,1),BurstData.NameArray));
            Valid = Valid & (BurstData.DataArray(:,Index) >= CutState{i,2}) & (BurstData.DataArray(:,Index) <= CutState{i,3});
        end
    end
end
if nargout == 0 %%% Only update global Variable if no output is requested!
    BurstData.Selected = Valid;
    BurstData.DataCut = BurstData.DataArray(Valid,:);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Executes on change in the Cut Table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Cut Array and GUI/Plots     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CutTableChange(hObject,eventdata)
%this executes if a value in the CutTable is changed
h = guidata(hObject);
global BurstData
%check which cell was changed
index = eventdata.Indices;
%read out the parameter name
ChangedParameterName = BurstData.Cut{BurstData.SelectedSpecies}{index(1)}{1};
%change value in structure
NewData = eventdata.NewData;
switch index(2)
    case {1} %min boundary was changed
        if BurstData.Cut{BurstData.SelectedSpecies}{index(1)}{3} < eventdata.NewData
            NewData = eventdata.PreviousData;
        end
    case {2} %max boundary was changed
        if BurstData.Cut{BurstData.SelectedSpecies}{index(1)}{2} > eventdata.NewData
            NewData = eventdata.PreviousData;
        end
    case {3} %active/inactive change
        NewData = eventdata.NewData;
end

if index(2) ~= 4
    BurstData.Cut{BurstData.SelectedSpecies}{index(1)}{index(2)+1}=NewData;
elseif index(2) == 4 %delete this entry
    BurstData.Cut{BurstData.SelectedSpecies}(index(1)) = [];
end

%%% If a change was made to the GlobalCuts Species, update all other
%%% existent species with the changes
if BurstData.SelectedSpecies == 1
    if numel(BurstData.Cut) > 1 %%% Check if there are other species defined
        %%% cycle through the number of other species
        for j = 2:numel(BurstData.Cut)
            %%% Check if the parameter already exists in the species j
            ParamList = vertcat(BurstData.Cut{j}{:});
            if ~isempty(ParamList)
                ParamList = ParamList(1:numel(BurstData.Cut{j}),1);
                CheckParam = strcmp(ParamList,ChangedParameterName);
                if any(CheckParam)
                    %%% Check wheter do delete or change the parameter
                    if index(2) ~= 4 %%% Parameter added or changed
                        %%% Override the parameter with GlobalCut
                        BurstData.Cut{j}(CheckParam) = BurstData.Cut{1}(index(1));
                    elseif index(2) == 4 %%% Parameter was deleted
                        BurstData.Cut{j}(CheckParam) = [];
                    end
                else %%% Parameter is new to species
                    if index(2) ~= 4 %%% Parameter added or changed
                        BurstData.Cut{j}(end+1) = BurstData.Cut{1}(index(1));
                    end
                end
            else %%% Parameter is new to GlobalCut
                BurstData.Cut{j}(end+1) = BurstData.Cut{1}(index(1));
            end
        end
    end
end

%%% Update GUI elements
UpdateCutTable(h);
UpdateCuts();
UpdatePlot([],[]);
UpdateLifetimePlots(hObject,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Determines the Correction Factors automatically  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineCorrections(obj,~)
global BurstData BurstMeta UserValues
LSUserValues(0);
h = guidata(obj);

%%% Change focus to CorrectionsTab
%h.Main_Tab.SelectedTab = h.Main_Tab_Corrections;
indS = BurstMeta.posS;
%indE = find(strcmp(BurstData.NameArray,'Efficiency'));
indDur = find(strcmp(BurstData.NameArray,'Duration [ms]'));
indNGG = find(strcmp(BurstData.NameArray,'Number of Photons (GG)'));
indNGR = find(strcmp(BurstData.NameArray,'Number of Photons (GR)'));
indNRR = find(strcmp(BurstData.NameArray,'Number of Photons (RR)'));

T_threshold = str2double(h.T_Threshold_Edit.String);
if isnan(T_threshold)
    T_threshold = 0.1;
end

cutT = 1;

if cutT == 0
    data_for_corrections = BurstData.DataArray;
elseif cutT == 1
    T = strcmp(BurstData.NameArray,'|TGX-TRR| Filter');
    valid = (BurstData.DataArray(:,T) < T_threshold);
    data_for_corrections = BurstData.DataArray(valid,:);
end

%%% Read out corrections
Background_GR = BurstData.Background.Background_GRpar + BurstData.Background.Background_GRperp;
Background_GG = BurstData.Background.Background_GGpar + BurstData.Background.Background_GGperp;
Background_RR = BurstData.Background.Background_RRpar + BurstData.Background.Background_RRperp;
%% 2cMFD Corrections
%% Crosstalk and direct excitation
if obj == h.DetermineCorrectionsButton
    %% plot raw Efficiency for S>0.9
    x_axis = linspace(0,0.3,50);
    Smin = 0.9;
    S_threshold = (data_for_corrections(:,indS)>Smin);
    NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
    NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
    E_raw = NGR./(NGR+NGG);
    histE_donly = histc(E_raw,x_axis);
    BurstMeta.Plots.histE_donly.XData = x_axis;
    BurstMeta.Plots.histE_donly.YData = histE_donly;
    axis(h.Corrections.TwoCMFD.axes_crosstalk,'tight');
    
    %fit single gaussian
    [mean_ct, GaussFit] = GaussianFit(x_axis',histE_donly,1);
    BurstMeta.Plots.Fits.histE_donly(1).XData = x_axis;
    BurstMeta.Plots.Fits.histE_donly(1).YData = GaussFit;
    UserValues.BurstBrowser.Corrections.CrossTalk_GR = mean_ct./(1-mean_ct);
    BurstData.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
    %% plot raw data for S < 0.2 for direct excitation
    %%% check if plot exists
    Smax = 0.2;
    x_axis = linspace(0,Smax,20);
    S_threshold = (data_for_corrections(:,indS)<Smax);
    NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
    NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
    NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
    S_raw = (NGG+NGR)./(NGG+NGR+NRR);
    histS_aonly = histc(S_raw,x_axis);
    BurstMeta.Plots.histS_aonly.XData = x_axis;
    BurstMeta.Plots.histS_aonly.YData = histS_aonly;
    axis(h.Corrections.TwoCMFD.axes_direct_excitation,'tight');
    %fit single gaussian
    [mean_de, GaussFit] = GaussianFit(x_axis',histS_aonly,1);
    BurstMeta.Plots.Fits.histS_aonly(1).XData = x_axis;
    BurstMeta.Plots.Fits.histS_aonly(1).YData = GaussFit;
    UserValues.BurstBrowser.Corrections.DirectExcitation_GR = mean_de./(1-mean_de);
    BurstData.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
end
if obj == h.FitGammaButton
    %% plot gamma plot for two populations (or lifetime versus E)
    %%% get E-S values between 0.3 and 0.8;
    S_threshold = ( (data_for_corrections(:,indS) > 0.2) & (data_for_corrections(:,indS) < 0.8) );
    %%% Calculate "raw" E and S with gamma = 1, but still apply direct
    %%% excitation,crosstalk, and background corrections!
    NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
    NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
    NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
    NGR = NGR - BurstData.Corrections.DirectExcitation_GR.*NRR - BurstData.Corrections.CrossTalk_GR.*NGG;
    E_raw = NGR./(NGR+NGG);
    S_raw = (NGG+NGR)./(NGG+NGR+NRR);
    [H,xbins,ybins] = calc2dhist(E_raw,1./S_raw,[51 51],[0 1], [1 10]);
    BurstMeta.Plots.gamma_fit(1).XData= xbins;
    BurstMeta.Plots.gamma_fit(1).YData= ybins;
    BurstMeta.Plots.gamma_fit(1).CData= H;
    BurstMeta.Plots.gamma_fit(1).AlphaData= (H>0);
    BurstMeta.Plots.gamma_fit(2).XData= xbins;
    BurstMeta.Plots.gamma_fit(2).YData= ybins;
    BurstMeta.Plots.gamma_fit(2).ZData= H/max(max(H));
    BurstMeta.Plots.gamma_fit(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    %%% Update/Reset Axis Labels
    xlabel(h.Corrections.TwoCMFD.axes_gamma,'Efficiency');
    ylabel(h.Corrections.TwoCMFD.axes_gamma,'1/Stoichiometry');
    title(h.Corrections.TwoCMFD.axes_gamma,'1/Stoichiometry vs. Efficiency for gamma = 1');
    %%% store for later use
    BurstMeta.Data.E_raw = E_raw;
    BurstMeta.Data.S_raw = S_raw;
    %%% Fit linearly
    fitGamma = fit(E_raw,1./S_raw,'poly1');
    BurstMeta.Plots.Fits.gamma.Visible = 'on';
    BurstMeta.Plots.Fits.gamma_manual.Visible = 'off';
    BurstMeta.Plots.Fits.gamma.XData = linspace(0,1,1000);
    BurstMeta.Plots.Fits.gamma.YData = fitGamma(linspace(0,1,1000));
    axis(h.Corrections.TwoCMFD.axes_gamma,'tight');
    ylim(h.Corrections.TwoCMFD.axes_gamma,[1,10]);
    xlim(h.Corrections.TwoCMFD.axes_gamma,[0,1]);
    %%% Determine Gamma and Beta
    coeff = coeffvalues(fitGamma); m = coeff(1); b = coeff(2);
    UserValues.BurstBrowser.Corrections.Gamma_GR = (b - 1)/(b + m - 1);
    BurstData.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
    UserValues.BurstBrowser.Corrections.Beta_GR = b+m-1;
    BurstData.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
end
if any(BurstData.BAMethod == [3,4])
    %% 3cMFD corrections
    %%% Read out parameter positions
    indSBG = find(strcmp(BurstData.NameArray,'Stoichiometry BG'));
    indSBR = find(strcmp(BurstData.NameArray,'Stoichiometry BR'));
    %%% Read out photon counts
    indNBB = find(strcmp(BurstData.NameArray,'Number of Photons (BB)'));
    indNBG = find(strcmp(BurstData.NameArray,'Number of Photons (BG)'));
    indNBR = find(strcmp(BurstData.NameArray,'Number of Photons (BR)'));
    %%% Read out corrections
    Background_BB = BurstData.Background.Background_BBpar + BurstData.Background.Background_BBperp;
    Background_BG = BurstData.Background.Background_BGpar + BurstData.Background.Background_BGperp;
    Background_BR = BurstData.Background.Background_BRpar + BurstData.Background.Background_BRperp;
    %%% define T-threshold
    if cutT == 0
        data_for_corrections = BurstData.DataArray;
    elseif cutT == 1
        T1 = strcmp(BurstData.NameArray,'|TGX-TRR| Filter');
        T2 = strcmp(BurstData.NameArray,'|TBX-TRR| Filter');
        T3 = strcmp(BurstData.NameArray,'|TBX-TGX| Filter');
        valid = (BurstData.DataArray(:,T1) < T_threshold) &...
            (BurstData.DataArray(:,T2) < T_threshold) &...
            (BurstData.DataArray(:,T3) < T_threshold);
        data_for_corrections = BurstData.DataArray(valid,:);
    end
    if obj == h.DetermineCorrectionsButton
        %% Blue dye only
        S_threshold = ( (data_for_corrections(:,indSBG) > 0.9) &...
            (data_for_corrections(:,indSBR) > 0.9) );
        x_axis = linspace(0,0.3,50);
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBG = data_for_corrections(S_threshold,indNBG) - Background_BG.*data_for_corrections(S_threshold,indDur);
        NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
        %%% Crosstalk B->G
        EBG_raw = NBG./(NBG+NBB);
        histEBG_blueonly = histc(EBG_raw,x_axis);
        BurstMeta.Plots.histEBG_blueonly.XData = x_axis;
        BurstMeta.Plots.histEBG_blueonly.YData = histEBG_blueonly;
        axis(h.Corrections.ThreeCMFD.axes_crosstalk_BG,'tight');
        %fit single gaussian
        [mean_ct, GaussFit] = GaussianFit(x_axis',histEBG_blueonly,1);
        BurstMeta.Plots.Fits.histEBG_blueonly(1).XData = x_axis;
        BurstMeta.Plots.Fits.histEBG_blueonly(1).YData = GaussFit;
        UserValues.BurstBrowser.Corrections.CrossTalk_BG = mean_ct./(1-mean_ct);
        BurstData.Corrections.CrossTalk_BG = UserValues.BurstBrowser.Corrections.CrossTalk_BG;
        %%% Crosstalk B->R
        x_axis = linspace(-0.05,0.25,50);
        EBR_raw = NBR./(NBR+NBB);
        histEBR_blueonly = histc(EBR_raw,x_axis);
        BurstMeta.Plots.histEBR_blueonly.XData = x_axis;
        BurstMeta.Plots.histEBR_blueonly.YData = histEBR_blueonly;
        axis(h.Corrections.ThreeCMFD.axes_crosstalk_BR,'tight');
        %fit single gaussian
        [mean_ct, GaussFit] = GaussianFit(x_axis',histEBR_blueonly,1);
        BurstMeta.Plots.Fits.histEBR_blueonly(1).XData = x_axis;
        BurstMeta.Plots.Fits.histEBR_blueonly(1).YData = GaussFit;
        UserValues.BurstBrowser.Corrections.CrossTalk_BR = mean_ct./(1-mean_ct);
        BurstData.Corrections.CrossTalk_BR = UserValues.BurstBrowser.Corrections.CrossTalk_BR;
        %% Green dye only
        S_threshold = ( (data_for_corrections(:,indSBG) < 0.2) &...
            (data_for_corrections(:,indS) > 0.9) );
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBG = data_for_corrections(S_threshold,indNBG) - Background_BG.*data_for_corrections(S_threshold,indDur);
        NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
        
        x_axis = linspace(0,0.2,20);
        SBG_raw = (NBB+NBG)./(NBB+NBG+NGG);
        histSBG_greenonly = histc(SBG_raw,x_axis);
        BurstMeta.Plots.histSBG_greenonly.XData = x_axis;
        BurstMeta.Plots.histSBG_greenonly.YData = histSBG_greenonly;
        axis(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,'tight');
        %fit single gaussian
        [mean_de, GaussFit] = GaussianFit(x_axis',histSBG_greenonly,1);
        BurstMeta.Plots.Fits.histSBG_greenonly(1).XData = x_axis;
        BurstMeta.Plots.Fits.histSBG_greenonly(1).YData = GaussFit;
        UserValues.BurstBrowser.Corrections.DirectExcitation_BG = mean_de./(1-mean_de);
        BurstData.Corrections.DirectExcitation_BG = UserValues.BurstBrowser.Corrections.DirectExcitation_BG;
        %% Red dye only
        S_threshold = ( (data_for_corrections(:,indS) < 0.2) &...
            (data_for_corrections(:,indSBR) < 0.2) );
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
        NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
        
        x_axis = linspace(-0.05,0.2,50);
        SBR_raw = (NBB+NBR)./(NBB+NBR+NRR);
        histSBR_redonly = histc(SBR_raw,x_axis);
        BurstMeta.Plots.histSBR_redonly.XData = x_axis;
        BurstMeta.Plots.histSBR_redonly.YData = histSBR_redonly;
        axis(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,'tight');
        %fit single gaussian
        [mean_de, GaussFit] = GaussianFit(x_axis',histSBR_redonly,1);
        BurstMeta.Plots.Fits.histSBR_redonly(1).XData = x_axis;
        BurstMeta.Plots.Fits.histSBR_redonly(1).YData = GaussFit;
        UserValues.BurstBrowser.Corrections.DirectExcitation_BR = mean_de./(1-mean_de);
        BurstData.Corrections.DirectExcitation_BR = UserValues.BurstBrowser.Corrections.DirectExcitation_BR;
    end
    if obj == h.FitGammaButton
        %% Gamma factor determination based on double-labeled species
        %%% BG labeled
        S_threshold = ( (data_for_corrections(:,indS) > 0.9) &...
            (data_for_corrections(:,indSBG) > 0.3) & (data_for_corrections(:,indSBG) < 0.7) &...
            (data_for_corrections(:,indSBR) > 0.9) );
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBG = data_for_corrections(S_threshold,indNBG) - Background_BG.*data_for_corrections(S_threshold,indDur);
        NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
        NBG = NBG - BurstData.Corrections.DirectExcitation_BG.*NGG - BurstData.Corrections.CrossTalk_BG.*NBB;
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
        xlabel(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'Efficiency BG');
        ylabel(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'1/Stoichiometry BG');
        title(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'1/Stoichiometry BG vs. Efficiency BG for gammaBG = 1');
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
        BurstData.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
        UserValues.BurstBrowser.Corrections.Beta_BG = b+m-1;
        BurstData.Corrections.Beta_BG = UserValues.BurstBrowser.Corrections.Beta_BG;
        
        S_threshold = ( (data_for_corrections(:,indS) < 0.2) &...
            (data_for_corrections(:,indSBG) > 0.9) &...
            (data_for_corrections(:,indSBR) > 0.2) & (data_for_corrections(:,indSBR) < 0.8) );
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
        NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
        NBR = NBR - BurstData.Corrections.DirectExcitation_BR.*NRR - BurstData.Corrections.CrossTalk_BR.*NBB;
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
        xlabel(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'Efficiency* BR');
        ylabel(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'1/Stoichiometry* BR');
        title(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'1/Stoichiometry* BR vs. Efficiency* BR for gammaBR = 1');
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
        BurstData.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
        UserValues.BurstBrowser.Corrections.Beta_BR = b+m-1;
        BurstData.Corrections.Beta_BR = UserValues.BurstBrowser.Corrections.Beta_BR;
    end
end
%% Save and Update GUI
%%% Save UserValues
LSUserValues(1);
%%% Update Correction Table Data
UpdateCorrections([],[]);
%%% Apply Corrections
ApplyCorrections(gcbo,[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% General 1D-Gauss Fit Function  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mean,GaussFun,Gauss1,Gauss2] = GaussianFit(x_data,y_data,N_gauss)
%%% Inputs:
%%% xdata/ydata     :   Data to Fit
%%% N_gauss         :   Number of Gauss Funktions (1 or 2)
%%%
%%% Outputs:
%%% mean            : Determined Mean Value
%%% GaussFun        : The Values of the FitFunction at xdata
%%% Gauss1/2        : The Values of Gauss1/2 at xdata for multi-Gauss fit
if N_gauss == 1
    Gauss = @(A,m,s,b,x) A*exp(-(x-m).^2./s^2)+b;
    if nargin <5 %no start parameters specified
        A = max(y_data);%set amplitude as max value
        m = sum(y_data.*x_data)./sum(y_data);%mean as center value
        s = sqrt(sum(y_data.*(x_data-m).^2)./sum(y_data));%std as sigma
        b=0;%assume zero background
        param = [A,m,s,b];
    end
    gauss = fit(x_data,y_data,Gauss,'StartPoint',param);
    coefficients = coeffvalues(gauss);
    mean = coefficients(2);
    GaussFun = Gauss(coefficients(1),coefficients(2),coefficients(3),coefficients(4),x_data);
elseif N_gauss == 2
    Gauss = @(A1,m1,s1,A2,m2,s2,b,x) A1*exp(-(x-m1).^2./s1^2)+A2*exp(-(x-m2).^2./s2^2)+b;
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
    gauss = fit(x_data,y_data,Gauss,'StartPoint',param);
    coefficients = coeffvalues(gauss);
    %get maximum amplitude
    [~,Amax] = max([coefficients(1) coefficients(4)]);
    if Amax == 1
        mean = coefficients(2);
    elseif Amax == 2
        mean = coefficients(5);
    end
    GaussFun = Gauss(coefficients(1),coefficients(2),coefficients(3),coefficients(4),coefficients(5),coefficients(6),coefficients(7),x_data);
    G1 = @(A,m,s,b,x) A*exp(-(x-m).^2./s^2)+b;
    Gauss1 = G1(coefficients(1),coefficients(2),coefficients(3),coefficients(7)/2,x_data);
    Gauss2 = G1(coefficients(4),coefficients(5),coefficients(6),coefficients(7)/2,x_data);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates GUI elements in fFCS tab and Lifetime Tab %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_fFCS_GUI(~,~)
global BurstData
h = guidata(findobj('Tag','BurstBrowser'));

if numel(BurstData.SpeciesNames) > 1
    h.fFCS_Species1_popupmenu.String = BurstData.SpeciesNames(2:end);
    h.fFCS_Species1_popupmenu.Value = 1;
    h.fFCS_Species2_popupmenu.String = BurstData.SpeciesNames(2:end);
    if numel(BurstData.SpeciesNames) > 2
        h.fFCS_Species2_popupmenu.Value = 2;
    else
        h.fFCS_Species2_popupmenu.Value = 1;
    end
    h.Plot_Microtimes_button.Enable = 'off';
else %%% Set to empty
    h.fFCS_Species1_popupmenu.String = '-';
    h.fFCS_Species1_popupmenu.Value = 1;
    h.fFCS_Species2_popupmenu.String = '-';
    h.fFCS_Species2_popupmenu.Value = 1;
    h.Plot_Microtimes_button.Enable = 'off';
    h.Calc_fFCS_Filter_button.Enable = 'off';
    h.Do_fFCS_button.Enable = 'off';
end

%%% Update Lifetime GUI popupmenu with species list
h.TauFit.SpeciesSelect.String = BurstData.SpeciesNames;
h.TauFit.SpeciesSelect.Value = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Microtime Histograms in fFCS tab %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_MicrotimeHistograms(obj,~)
global BurstData BurstMeta BurstTCSPCData UserValues PhotonStream
h = guidata(obj);
Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
%%% Load associated *.bps data if it doesn't exist yet
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData)
    Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
    if exist([BurstData.FileName(1:end-3) 'bps'],'file') == 2
        %%% load if it exists
        load([BurstData.FileName(1:end-3) 'bps'],'-mat');
    else
        %%% else ask for the file
        [FileName,PathName] = uigetfile({'*.bps'}, 'Choose the associated *.bps file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');
        if FileName == 0
            return;
        end
        load('-mat',fullfile(PathName,FileName));
        %%% Store the correct Path in TauFitBurstData
        BurstData.FileName = fullfile(PathName,[FileName(1:end-3) 'bur']);
    end
    BurstTCSPCData.Macrotime = Macrotime;
    BurstTCSPCData.Microtime = Microtime;
    BurstTCSPCData.Channel = Channel;
    clear Macrotime Microtime Channel    
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
switch obj
    case h.Plot_Microtimes_button %%% fFCS
        %%% Read out the bursts contained in the different species selections
        valid_total = UpdateCuts(1);
        species1 = h.fFCS_Species1_popupmenu.Value + 1;BurstMeta.fFCS.Names{1} = h.fFCS_Species1_popupmenu.String{h.fFCS_Species1_popupmenu.Value};
        species2 = h.fFCS_Species2_popupmenu.Value + 1;BurstMeta.fFCS.Names{2} = h.fFCS_Species2_popupmenu.String{h.fFCS_Species2_popupmenu.Value};
        valid_species1 = UpdateCuts(species1);
        valid_species2 = UpdateCuts(species2);
        
        if UserValues.BurstBrowser.Settings.fFCS_UseTimewindow
            if isempty(PhotonStream)
                Progress(1,h.Progress_Axes,h.Progress_Text);
                h.Progress_Text.String = BurstData.DisplayName;
                m = msgbox('Load Total Photon Stream (*.aps) file first using Correlation Tab!');
                pause(2)
                delete(m)
                return;
            end
            start = PhotonStream.start(valid_total);
            stop = PhotonStream.stop(valid_total);
            
            use_time = 1; %%% use time or photon window
            if use_time
                %%% histogram the Macrotimes in bins of 10 ms
                bw = ceil(10E-3./BurstData.SyncPeriod);
                bins_time = bw.*(0:1:ceil(PhotonStream.Macrotime(end)./bw));
                if ~isfield(PhotonStream,'MT_bin')
                    [~, PhotonStream.MT_bin] = histc(PhotonStream.Macrotime,bins_time);
                    Progress(0.2,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
                    [PhotonStream.unique,PhotonStream.first_idx,~] = unique(PhotonStream.MT_bin);
                    Progress(0.4,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
                    used_tw = zeros(numel(bins_time),1);
                    used_tw(PhotonStream.unique) = PhotonStream.first_idx;
                    while sum(used_tw == 0) > 0
                        used_tw(used_tw == 0) = used_tw(find(used_tw == 0)-1);
                    end
                    Progress(0.6,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
                    PhotonStream.first_idx = used_tw;
                end
                [~, start_bin] = histc(PhotonStream.Macrotime(start),bins_time);
                [~, stop_bin] = histc(PhotonStream.Macrotime(stop),bins_time);
                
                Progress(0.8,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
                
                [~, start_all_bin] = histc(PhotonStream.Macrotime(PhotonStream.start),bins_time);
                [~, stop_all_bin] = histc(PhotonStream.Macrotime(PhotonStream.stop),bins_time);
                
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
                    Progress(i/numel(start),h.Progress_Axes,h.Progress_Text,'Including Time Window...');
                end
                
                %%% Construct reduced Macrotime and Channel vector
                Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
                MT_total = cell(sum(use),1);
                CH_total = cell(sum(use),1);
                MI_total = cell(sum(use),1);
                k=1;
                for i = 1:numel(start_tw)
                    if use(i)
                        range = PhotonStream.first_idx(start_tw(i)):(PhotonStream.first_idx(stop_tw(i)+1)-1);
                        MT_total{k} = PhotonStream.Macrotime(range);
                        MT_total{k} = MT_total{k}-MT_total{k}(1) +1;
                        CH_total{k} = PhotonStream.Channel(range);
                        MI_total{k} = PhotonStream.Microtime(range);
                        %val = (PhotonStream.MT_bin > start_tw(i)) & (PhotonStream.MT_bin < stop_tw(i) );
                        %MT{k} = PhotonStream.Macrotime(val);
                        %MT{k} = MT{k}-MT{k}(1) +1;
                        %CH{k} = PhotonStream.Channel(val);
                        k = k+1;
                    end
                    Progress(i/numel(start_tw),h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
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
                    val = (PhotonStream.start < stop_tw(i)) & (PhotonStream.stop > start_tw(i));
                    %%% Check if they are of the same species
                    inval = val & (~BurstData.Selected);
                    %%% if there are bursts of another species in the timewindow,
                    %%% --> remove it
                    if sum(inval) > 0
                        use(i) = 0;
                    end
                    Progress(i/numel(start),h.Progress_Axes,h.Progress_Text,'Including Time Window...');
                end
                
                %%% Construct reduced Macrotime and Channel vector
                Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
                MT_total = cell(sum(use),1);
                CH_total = cell(sum(use),1);
                MI_total = cell(sum(use),1);
                k=1;
                for i = 1:numel(start_tw)
                    if use(i)
                        MT_total{k} = PhotonStream.Macrotime(start_tw(i):stop_tw(i));MT_total{k} = MT_total{k}-MT_total{k}(1) +1;
                        CH_total{k} = PhotonStream.Channel(start_tw(i):stop_tw(i));
                        MI_total{k} = PhotonStream.Microtime(start_tw(i):stop_tw(i));
                        k = k+1;
                    end
                    Progress(i/numel(start_tw),h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
                end
            end
            
            %%% Store burstwise photon stream
            BurstMeta.fFCS.Photons.MT_total = MT_total;
            BurstMeta.fFCS.Photons.MI_total = MI_total;
            BurstMeta.fFCS.Photons.CH_total = CH_total;
        else
            %%% find selected bursts
            MI_total = BurstTCSPCData.Microtime(valid_total);
            CH_total = BurstTCSPCData.Channel(valid_total);
            MT_total = BurstTCSPCData.Macrotime(valid_total);
            for k = 1:numel(MT_total)
                MT_total{k} = MT_total{k}-MT_total{k}(1) +1;
            end
            BurstMeta.fFCS.Photons.MT_total = MT_total;
            BurstMeta.fFCS.Photons.MI_total = MI_total;
            BurstMeta.fFCS.Photons.CH_total = CH_total;
        end
        
        Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Microtime Histograms...');
        
        MI_total = vertcat(MI_total{:});
        CH_total = vertcat(CH_total{:});
        MT_total = vertcat(MT_total{:});
        %MT_species{1} = BurstTCSPCData.Macrotime(valid_species1);MT_species{1} = vertcat(MT_species{1}{:});
        MI_species{1} = BurstTCSPCData.Microtime(valid_species1);MI_species{1} = vertcat(MI_species{1}{:});
        CH_species{1} = BurstTCSPCData.Channel(valid_species1);CH_species{1} = vertcat(CH_species{1}{:});
        %MT_species{2} = BurstTCSPCData.Macrotime(valid_species2);MT_species{2} = vertcat(MT_species{2}{:});
        MI_species{2} = BurstTCSPCData.Microtime(valid_species2);MI_species{2} = vertcat(MI_species{2}{:});
        CH_species{2} = BurstTCSPCData.Channel(valid_species2);CH_species{2} = vertcat(CH_species{2}{:});
        
        switch BurstData.BAMethod
            case {1,2} %%% 2ColorMFD
                ParChans = [1 3]; %% GG1 and GR1
                PerpChans = [2 4]; %% GG2 and GR2
            case {3,4} %%% 3ColorMFD
                ParChans = [1 3 5 7 9]; %% BB1, BG1, BR1, GG1, GR1
                PerpChans = [2 4 6 8 10]; %% BB2, BG2, BR2, GG2, GR2
        end
        %%% Construct Stacked Microtime Channels
        %%% ___| MT1 |___| MT2 + max(MT1) |___
        MI_par{1} = [];MI_par{2} = [];
        MI_perp{1} = [];MI_perp{2} = [];
        %%% read out the limits of the PIE channels
        limit_low_par = [0, BurstData.PIE.From(ParChans)];
        limit_high_par = [0, BurstData.PIE.To(ParChans)];
        dif_par = cumsum(limit_high_par)-cumsum(limit_low_par);
        limit_low_perp = [0,BurstData.PIE.From(PerpChans)];
        limit_high_perp = [0, BurstData.PIE.To(PerpChans)];
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
        
        %%% Burstwise treatment if using time window
        %if UserValues.BurstBrowser.Settings.fFCS_UseTimewindow
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
        %end
        %%% Downsampling if checked
        %%% New binwidth in picoseconds
        if UserValues.BurstBrowser.Settings.Downsample_fFCS
            if ~isfield(BurstData.FileInfo,'Resolution')
                TACChannelWidth = BurstData.FileInfo.SyncPeriod*1E9/BurstData.FileInfo.MI_Bins;
            elseif isfield(BurstData.FileInfo,'Resolution') %%% HydraHarp Data
                TACChannelWidth = BurstData.FileInfo.Resolution/1000;
            end
            new_bin_width = floor(UserValues.BurstBrowser.Settings.Downsample_fFCS_Time/(1000*TACChannelWidth));
            MI_total_par = ceil(double(MI_total_par)/new_bin_width);
            MI_total_perp = ceil(double(MI_total_perp)/new_bin_width);
            for i = 1:2
                MI_par{i} = ceil(double(MI_par{i})/new_bin_width);
                MI_perp{i} = ceil(double(MI_perp{i})/new_bin_width);
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
        
        %%% Store Photon Vectors of total photons in BurstMeta
        %         if ~UserValues.BurstBrowser.Settings.fFCS_UseTimewindow
        %             BurstMeta.fFCS.Photons.MT_total_par = MT_total_par;
        %             BurstMeta.fFCS.Photons.MI_total_par = MI_total_par;
        %             BurstMeta.fFCS.Photons.MT_total_perp = MT_total_perp;
        %             BurstMeta.fFCS.Photons.MI_total_perp = MI_total_perp;
        %         end
        %%% Plot the Microtime histograms
        BurstMeta.Plots.fFCS.Microtime_Total_par.XData = BurstMeta.fFCS.TAC_par;
        BurstMeta.Plots.fFCS.Microtime_Total_par.YData = BurstMeta.fFCS.hist_MItotal_par;
        BurstMeta.Plots.fFCS.Microtime_Species1_par.XData = BurstMeta.fFCS.TAC_par;
        BurstMeta.Plots.fFCS.Microtime_Species1_par.YData = BurstMeta.fFCS.hist_MIpar_Species{1};
        BurstMeta.Plots.fFCS.Microtime_Species2_par.XData = BurstMeta.fFCS.TAC_par;
        BurstMeta.Plots.fFCS.Microtime_Species2_par.YData = BurstMeta.fFCS.hist_MIpar_Species{2};
        axis(h.axes_fFCS_DecayPar,'tight');
        BurstMeta.Plots.fFCS.Microtime_Total_perp.XData = BurstMeta.fFCS.TAC_perp;
        BurstMeta.Plots.fFCS.Microtime_Total_perp.YData = BurstMeta.fFCS.hist_MItotal_perp;
        BurstMeta.Plots.fFCS.Microtime_Species1_perp.XData = BurstMeta.fFCS.TAC_perp;
        BurstMeta.Plots.fFCS.Microtime_Species1_perp.YData = BurstMeta.fFCS.hist_MIperp_Species{1};
        BurstMeta.Plots.fFCS.Microtime_Species2_perp.XData = BurstMeta.fFCS.TAC_perp;
        BurstMeta.Plots.fFCS.Microtime_Species2_perp.YData = BurstMeta.fFCS.hist_MIperp_Species{2};
        axis(h.axes_fFCS_DecayPerp,'tight');
        
        %%% Add IRF Pattern if existent
        if isfield(BurstData,'ScatterPattern') && UserValues.BurstBrowser.Settings.fFCS_UseIRF
            BurstMeta.Plots.fFCS.IRF_par.Visible = 'on';
            BurstMeta.Plots.fFCS.IRF_perp.Visible = 'on';
            
            hScat_par = [];
            hScat_perp = [];
            for i = 1:numel(ParChans)
                hScat_par = [hScat_par, BurstData.ScatterPattern{ParChans(i)}(limit_low_par(i+1):limit_high_par(i+1))];
                hScat_perp = [hScat_perp, BurstData.ScatterPattern{PerpChans(i)}(limit_low_perp(i+1):limit_high_perp(i+1))];
            end
            
            if UserValues.BurstBrowser.Settings.Downsample_fFCS
                %%% Downsampling if checked
                hScat_par = downsamplebin(hScat_par,new_bin_width);hScat_par = hScat_par';
                hScat_perp = downsamplebin(hScat_perp,new_bin_width);hScat_perp = hScat_perp';
            end
            
            %%% normaize with respect to the total decay histogram
            hScat_par = hScat_par./max(hScat_par).*max(BurstMeta.fFCS.hist_MItotal_par);
            hScat_perp = hScat_perp./max(hScat_perp).*max(BurstMeta.fFCS.hist_MItotal_perp);
            
            %%% store in BurstMeta
            BurstMeta.fFCS.hScat_par = hScat_par(1:numel(BurstMeta.fFCS.TAC_par));
            BurstMeta.fFCS.hScat_perp = hScat_perp(1:numel(BurstMeta.fFCS.TAC_perp));
            %%% Update Plots
            BurstMeta.Plots.fFCS.IRF_par.XData = BurstMeta.fFCS.TAC_par;
            BurstMeta.Plots.fFCS.IRF_par.YData = BurstMeta.fFCS.hScat_par;
            BurstMeta.Plots.fFCS.IRF_perp.XData = BurstMeta.fFCS.TAC_perp;
            BurstMeta.Plots.fFCS.IRF_perp.YData = BurstMeta.fFCS.hScat_perp;
        elseif ~isfield(BurstData,'ScatterPattern') || ~UserValues.BurstBrowser.Settings.fFCS_UseIRF
            %%% Hide IRF plots
            BurstMeta.Plots.fFCS.IRF_par.Visible = 'off';
            BurstMeta.Plots.fFCS.IRF_perp.Visible = 'off';
        end
        
        h.Calc_fFCS_Filter_button.Enable = 'on';
        
    case h.TauFit.Plot_Microtimes_button %%% TauFit
        %%% Read out the bursts contained in the different species selections
        species = h.TauFit.SpeciesSelect.Value;
        valid = UpdateCuts(species);
        
        Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Microtime Histograms...');
        
        %%% find selected bursts
        MI_total = BurstTCSPCData.Microtime(valid);MI_total = vertcat(MI_total{:});
        CH_total = BurstTCSPCData.Channel(valid);CH_total = vertcat(CH_total{:});
        switch BurstData.BAMethod
            case {1,2} %%% 2color MFD
                switch h.TauFit.ChannelSelect.Value
                    case 1 %% GG
                        chan = [1,2];
                    case 2 %% RR
                        chan = [5,6];
                end
            case {3,4}
                switch h.TauFit.ChannelSelect.Value
                    case 1 %% BB
                        chan = [1,2];
                    case 2 %% GG
                        chan = [7,8];
                    case 3 %% RR
                        chan = [11,12];
                end
        end
        MI_par = MI_total(CH_total == chan(1));
        MI_perp = MI_total(CH_total == chan(2));
        
        %%% Calculate the histograms
        MI_par = histc(MI_par,0:(BurstData.FileInfo.MI_Bins-1));
        MI_perp = histc(MI_perp,0:(BurstData.FileInfo.MI_Bins-1));
        BurstMeta.TauFit.hMI_Par = MI_par(BurstData.PIE.From(chan(1)):min([BurstData.PIE.To(chan(1)) end]));
        BurstMeta.TauFit.hMI_Per = MI_perp(BurstData.PIE.From(chan(2)):min([BurstData.PIE.To(chan(2)) end]));
        
        BurstMeta.TauFit.hIRF_Par = BurstData.IRF{chan(1)}(BurstData.PIE.From(chan(1)):min([BurstData.PIE.To(chan(1)) end]));
        BurstMeta.TauFit.hIRF_Per = BurstData.IRF{chan(2)}(BurstData.PIE.From(chan(2)):min([BurstData.PIE.To(chan(2)) end]));
        BurstMeta.TauFit.hIRF_Par = (BurstMeta.TauFit.hIRF_Par./max(BurstMeta.TauFit.hIRF_Par)).*max(BurstMeta.TauFit.hMI_Par);
        BurstMeta.TauFit.hIRF_Per = (BurstMeta.TauFit.hIRF_Per./max(BurstMeta.TauFit.hIRF_Per)).*max(BurstMeta.TauFit.hMI_Per);
        
        BurstMeta.TauFit.hScat_Par = BurstData.ScatterPattern{chan(1)}(BurstData.PIE.From(chan(1)):min([BurstData.PIE.To(chan(1)) end]));
        BurstMeta.TauFit.hScat_Per = BurstData.ScatterPattern{chan(2)}(BurstData.PIE.From(chan(2)):min([BurstData.PIE.To(chan(2)) end]));
        BurstMeta.TauFit.hScat_Par = (BurstMeta.TauFit.hScat_Par./max(BurstMeta.TauFit.hScat_Par)).*max(BurstMeta.TauFit.hMI_Par);
        BurstMeta.TauFit.hScat_Per = (BurstMeta.TauFit.hScat_Per./max(BurstMeta.TauFit.hScat_Per)).*max(BurstMeta.TauFit.hMI_Per);
        
        %%% Generate XData
        BurstMeta.TauFit.XData_Par = (BurstData.PIE.From(chan(1)):BurstData.PIE.To(chan(1))) - BurstData.PIE.From(chan(1));
        BurstMeta.TauFit.XData_Per = (BurstData.PIE.From(chan(2)):BurstData.PIE.To(chan(2))) - BurstData.PIE.From(chan(2));
        
        %%% Plot
        %%% Plot the Data
        TACtoTime = 1/BurstData.FileInfo.MI_Bins*BurstData.FileInfo.TACRange*1e9;
        BurstMeta.Plots.TauFit.Decay_Par.XData = BurstMeta.TauFit.XData_Par*TACtoTime;
        BurstMeta.Plots.TauFit.Decay_Per.XData = BurstMeta.TauFit.XData_Per*TACtoTime;
        BurstMeta.Plots.TauFit.IRF_Par.XData = BurstMeta.TauFit.XData_Par*TACtoTime;
        BurstMeta.Plots.TauFit.IRF_Per.XData = BurstMeta.TauFit.XData_Per*TACtoTime;
        BurstMeta.Plots.TauFit.Scatter_Par.XData = BurstMeta.TauFit.XData_Par*TACtoTime;
        BurstMeta.Plots.TauFit.Scatter_Per.XData = BurstMeta.TauFit.XData_Per*TACtoTime;
        BurstMeta.Plots.TauFit.Decay_Par.YData = BurstMeta.TauFit.hMI_Par;
        BurstMeta.Plots.TauFit.Decay_Per.YData = BurstMeta.TauFit.hMI_Per;
        BurstMeta.Plots.TauFit.IRF_Par.YData = BurstMeta.TauFit.hIRF_Par;
        BurstMeta.Plots.TauFit.IRF_Per.YData = BurstMeta.TauFit.hIRF_Per;
        BurstMeta.Plots.TauFit.Scatter_Par.YData = BurstMeta.TauFit.hScat_Par;
        BurstMeta.Plots.TauFit.Scatter_Per.YData = BurstMeta.TauFit.hScat_Per;
        
        h.TauFit.Microtime_Plot.XLim = [min([BurstMeta.TauFit.XData_Par*TACtoTime BurstMeta.TauFit.XData_Per*TACtoTime]) max([BurstMeta.TauFit.XData_Par*TACtoTime BurstMeta.TauFit.XData_Per*TACtoTime])];
        h.TauFit.Microtime_Plot.YLim = [min([BurstMeta.TauFit.hMI_Par; BurstMeta.TauFit.hMI_Per]) 10/9*max([BurstMeta.TauFit.hMI_Par; BurstMeta.TauFit.hMI_Per])];
        
        %%% Define the Slider properties
        %%% Values to consider:
        %%% The length of the shortest PIE channel
        BurstMeta.TauFit.MaxLength = min([numel(BurstMeta.TauFit.hMI_Par) numel(BurstMeta.TauFit.hMI_Per)]);
        %%% The Length Slider defaults to the length of the shortest PIE
        %%% channel and should not assume larger values
        h.TauFit.Length_Slider.Min = 1;
        h.TauFit.Length_Slider.Max = BurstMeta.TauFit.MaxLength;
        h.TauFit.Length_Slider.Value = BurstMeta.TauFit.MaxLength;
        BurstMeta.TauFit.Length = BurstMeta.TauFit.MaxLength;
        h.TauFit.Length_Edit.String = num2str(BurstMeta.TauFit.Length);
        %%% Start Parallel Slider can assume values from 0 (no shift) up to the
        %%% length of the shortest PIE channel minus the set length
        h.TauFit.StartPar_Slider.Min = 0;
        h.TauFit.StartPar_Slider.Max = BurstMeta.TauFit.MaxLength;
        h.TauFit.StartPar_Slider.Value = 0;
        BurstMeta.TauFit.StartPar = 0;
        h.TauFit.StartPar_Edit.String = num2str(BurstMeta.TauFit.StartPar);
        %%% Shift Perpendicular Slider can assume values from the difference in
        %%% start point between parallel and perpendicular up to the difference
        %%% between the end point of the parallel channel and the start point
        %%% of the perpendicular channel
        h.TauFit.ShiftPer_Slider.Min = -floor(BurstMeta.TauFit.MaxLength/10);
        h.TauFit.ShiftPer_Slider.Max = floor(BurstMeta.TauFit.MaxLength/10);
        h.TauFit.ShiftPer_Slider.Value = 0;
        BurstMeta.TauFit.ShiftPer = 0;
        h.TauFit.ShiftPer_Edit.String = num2str(BurstMeta.TauFit.ShiftPer);
        
        %%% IRF Length has the same limits as the Length property
        h.TauFit.IRFLength_Slider.Min = 1;
        h.TauFit.IRFLength_Slider.Max = BurstMeta.TauFit.MaxLength;
        h.TauFit.IRFLength_Slider.Value = BurstMeta.TauFit.MaxLength;
        BurstMeta.TauFit.IRFLength = BurstMeta.TauFit.MaxLength;
        h.TauFit.IRFLength_Edit.String = num2str(BurstMeta.TauFit.IRFLength);
        %%% IRF Shift has the same limits as the perp shift property
        h.TauFit.IRFShift_Slider.Min = -floor(BurstMeta.TauFit.MaxLength/10);
        h.TauFit.IRFShift_Slider.Max = floor(BurstMeta.TauFit.MaxLength/10);
        h.TauFit.IRFShift_Slider.Value = 0;
        BurstMeta.TauFit.IRFShift = 0;
        h.TauFit.IRFShift_Edit.String = num2str(BurstMeta.TauFit.IRFShift);
        
        %%% Ignore Slider reaches from 1 to maximum length
        h.TauFit.Ignore_Slider.Value = 1;
        h.TauFit.Ignore_Slider.Min = 1;
        h.TauFit.Ignore_Slider.Max = BurstMeta.TauFit.MaxLength;
        BurstMeta.TauFit.Ignore = 1;
        h.TauFit.Ignore_Edit.String = num2str(BurstMeta.TauFit.Ignore);
        
        %%% Update Plot
        h.TauFit.Microtime_Plot.Parent = h.MainTabTauFitPanel;
        h.TauFit.Result_Plot.Parent = h.TauFit.HidePanel;
        BurstMeta.Plots.TauFit.Residuals.YData = zeros(numel(BurstMeta.Plots.TauFit.Residuals.XData),1);
end
Progress(1,h.Progress_Axes,h.Progress_Text);
h.Progress_Text.String = BurstData.DisplayName;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates fFCS filter and updates plots %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Calc_fFCS_Filters(obj,~)
global BurstMeta BurstData UserValues
h = guidata(obj);

%%% Concatenate Decay Patterns
Decay_par = [BurstMeta.fFCS.hist_MIpar_Species{1},...
    BurstMeta.fFCS.hist_MIpar_Species{2}];
if isfield(BurstData,'ScatterPattern') && UserValues.BurstBrowser.Settings.fFCS_UseIRF %%% include scatter pattern
    if isfield(BurstMeta.fFCS,'hScat_par')
        Decay_par = [Decay_par, BurstMeta.fFCS.hScat_par(1:size(Decay_par,1))'];
    end
end
Decay_par = Decay_par./repmat(sum(Decay_par,1),size(Decay_par,1),1);
Decay_total_par = BurstMeta.fFCS.hist_MItotal_par;
Decay_total_par(Decay_total_par == 0) = 1; %%% fill zeros with 1
Decay_perp = [BurstMeta.fFCS.hist_MIperp_Species{1},...
    BurstMeta.fFCS.hist_MIperp_Species{2}];
if isfield(BurstData,'ScatterPattern') && UserValues.BurstBrowser.Settings.fFCS_UseIRF %%% include scatter pattern
    if isfield(BurstMeta.fFCS,'hScat_perp')
        Decay_perp = [Decay_perp, BurstMeta.fFCS.hScat_perp(1:size(Decay_perp,1))'];
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
    BurstMeta.Plots.fFCS.FilterPar_IRF.XData = BurstMeta.fFCS.TAC_par;
    BurstMeta.Plots.fFCS.FilterPar_IRF.YData = BurstMeta.fFCS.filters_par(3,:);
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
    BurstMeta.Plots.fFCS.FilterPerp_IRF.XData = BurstMeta.fFCS.TAC_perp;
    BurstMeta.Plots.fFCS.FilterPerp_IRF.YData = BurstMeta.fFCS.filters_perp(3,:);
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
function Do_fFCS(~,~)
global BurstMeta BurstData UserValues
h = guidata(findobj('Tag','BurstBrowser'));
%%% Set Up Progress Bar
Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
%%% define channels
Name = BurstMeta.fFCS.Names;
CorrMat = true(2);
NumChans = size(CorrMat,1);
%%% Read out photons and filters from BurstMeta
MT_par = BurstMeta.fFCS.Photons.MT_total_par;
MT_perp = BurstMeta.fFCS.Photons.MT_total_perp;
MI_par = BurstMeta.fFCS.Photons.MI_total_par;
MI_perp = BurstMeta.fFCS.Photons.MI_total_perp;
filters_par{1} = BurstMeta.fFCS.filters_par(1,:)';
filters_par{2} = BurstMeta.fFCS.filters_par(2,:)';
filters_perp{1} = BurstMeta.fFCS.filters_perp(1,:)';
filters_perp{2} = BurstMeta.fFCS.filters_perp(2,:)';


% if ~UserValues.BurstBrowser.Settings.fFCS_UseTimewindow
%     %%% Split Data in 10 time bins for errorbar calculation
%     Times = ceil(linspace(0,max([MT_par;MT_perp]),11));
%     count = 0;
%     for i=1:NumChans
%         for j=1:NumChans
%             if CorrMat(i,j)
%                 %%% Calculates the maximum inter-photon time in clock ticks
%                 Maxtime=max(diff(Times));
%                 Data1 = cell(10,1);
%                 Data2 = cell(10,1);
%                 Weights1 = cell(10,1);
%                 Weights2 = cell(10,1);
%                 for k = 1:10
%                     Data1{k} = MT_par( MT_par > Times(k) &...
%                         MT_par <= Times(k+1)) - Times(k);
%                     Weights1{k} = filters_par{i}(MI_par( MT_par > Times(k) &...
%                         MT_par <= Times(k+1)) );
%                     Data2{k} = MT_perp( MT_perp > Times(k) &...
%                         MT_perp <= Times(k+1)) - Times(k);
%                     Weights2{k} = filters_perp{j}(MI_perp(MT_perp > Times(k) &...
%                         MT_perp <= Times(k+1)) );
%                 end
%                 %%% Do Correlation
%                 [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data2,Maxtime,Weights1,Weights2);
%                 Cor_Times=Cor_Times*BurstData.SyncPeriod;
%                 %%% Calculates average and standard error of mean (without tinv_table yet
%                 if numel(Cor_Array)>1
%                     Cor_Average=mean(Cor_Array,2);
%                     %Cor_SEM=std(Cor_Array,0,2)/sqrt(size(Cor_Array,2));
%                     %%% Averages files before saving to reduce errorbars
%                     Amplitude=sum(Cor_Array,1);
%                     Cor_Norm=Cor_Array./repmat(Amplitude,[size(Cor_Array,1),1])*mean(Amplitude);
%                     Cor_SEM=std(Cor_Norm,0,2)/sqrt(size(Cor_Array,2));
%
%                 else
%                     Cor_Average=Cor_Array{1};
%                     Cor_SEM=Cor_Array{1};
%                 end
%                 %%% Save the correlation file
%                 %%% Generates filename
%                 Current_FileName=[BurstData.FileName(1:end-4) '_' Name{i} '_x_' Name{j} '.mcor'];
%                 %%% Checks, if file already exists
%                 if  exist(Current_FileName,'file')
%                     k=1;
%                     %%% Adds 1 to filename
%                     Current_FileName=[Current_FileName(1:end-5) '_' num2str(k) '.mcor'];
%                     %%% Increases counter, until no file is found
%                     while exist(Current_FileName,'file')
%                         k=k+1;
%                         Current_FileName=[Current_FileName(1:end-(5+numel(num2str(k-1)))) num2str(k) '.mcor'];
%                     end
%                 end
%
%                 Header = ['Correlation file for: ' strrep(fullfile(BurstData.FileName),'\','\\') ' of Channels ' Name{i} ' cross ' Name{j}];
%                 Counts = [numel(MT_par) numel(MT_perp)]/(BurstData.SyncPeriod*max([MT_par;MT_perp]))/1000;
%                 Valid = 1:10;
%                 save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
%                 count = count +1;waitbar(count/4);
%             end
%         end
%     end
% else
count = 0;
for i=1:NumChans
    for j=1:NumChans
        if CorrMat(i,j)
            MT1 = BurstMeta.fFCS.Photons.MT_total_par;
            MT2 = BurstMeta.fFCS.Photons.MT_total_perp;
            MIpar = BurstMeta.fFCS.Photons.MI_total_par;
            MIperp = BurstMeta.fFCS.Photons.MI_total_perp;
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
            [Cor_Array,Cor_Times]=CrossCorrBurst(MT1,MT2,Maxtime,Weights1,Weights2);
            Cor_Times = Cor_Times*BurstData.SyncPeriod;
            
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
            Current_FileName=[BurstData.FileName(1:end-4) '_' Name{i} '_x_' Name{j} '.mcor'];
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
            
            Header = ['Correlation file for: ' strrep(fullfile(BurstData.FileName),'\','\\') ' of Channels ' Name{i} ' cross ' Name{j}];
            %Counts = [numel(MT1) numel(MT2)]/(BurstData.SyncPeriod*max([MT1;MT2]))/1000;
            Counts = [0 ,0];
            Valid = 1:size(Cor_Array,2);
            save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
            count = count +1;
            Progress(count/4,h.Progress_Axes,h.Progress_Text,'Correlating...');
        end
    end
end
Progress(1,h.Progress_Axes,h.Progress_Text);
h.Progress_Text.String = BurstData.DisplayName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates TauFit Plots  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_TauFitPlots(obj,~)
global BurstData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
%%% Update Values
switch obj
    case {h.TauFit.StartPar_Slider, h.TauFit.StartPar_Edit}
        if obj == h.TauFit.StartPar_Slider
            BurstMeta.TauFit.StartPar = floor(obj.Value);
        elseif obj == h.TauFit.StartPar_Edit
            BurstMeta.TauFit.StartPar = str2double(obj.String);
        end
    case {h.TauFit.Length_Slider, h.TauFit.Length_Edit}
        %%% Update Value
        if obj == h.TauFit.Length_Slider
            BurstMeta.TauFit.Length = floor(obj.Value);
        elseif obj == h.TauFit.Length_Edit
            BurstMeta.TauFit.Length = str2double(obj.String);
        end
        %%% Correct if IRFLength exceeds the Length
        if BurstMeta.TauFit.IRFLength > BurstMeta.TauFit.Length
            BurstMeta.TauFit.IRFLength = BurstMeta.TauFit.Length;
        end
    case {h.TauFit.ShiftPer_Slider, h.TauFit.ShiftPer_Edit}
        %%% Update Value
        if obj == h.TauFit.ShiftPer_Slider
            BurstMeta.TauFit.ShiftPer = floor(obj.Value);
        elseif obj == h.TauFit.ShiftPer_Edit
            BurstMeta.TauFit.ShiftPer = str2double(obj.String);
        end
    case {h.TauFit.IRFLength_Slider, h.TauFit.IRFLength_Edit}
        %%% Update Value
        if obj == h.TauFit.IRFLength_Slider
            BurstMeta.TauFit.IRFLength = floor(obj.Value);
        elseif obj == h.IRFLength_Edit
            BurstMeta.TauFit.IRFLength = str2double(obj.String);
        end
        %%% Correct if IRFLength exceeds the Length
        if BurstMeta.TauFit.IRFLength > BurstMeta.TauFit.Length
            BurstMeta.TauFit.IRFLength = BurstMeta.TauFit.Length;
        end
    case {h.TauFit.IRFShift_Slider, h.TauFit.IRFShift_Edit}
        %%% Update Value
        if obj == h.TauFit.IRFShift_Slider
            BurstMeta.TauFit.IRFShift = floor(obj.Value);
        elseif obj == h.TauFit.IRFShift_Edit
            BurstMeta.TauFit.IRFShift = str2double(obj.String);
        end
    case {h.TauFit.Ignore_Slider,h.TauFit.Ignore_Edit}%%% Update Value
        if obj == h.TauFit.Ignore_Slider
            BurstMeta.TauFit.Ignore = floor(obj.Value);
        elseif obj == h.TauFit.Ignore_Edit
            BurstMeta.TauFit.Ignore = str2double(obj.String);
        end
    case {h.TauFit.FitPar_Table}
        BurstMeta.TauFit.IRFShift = obj.Data{end,1};
        %%% Update Edit Box and Slider
        h.IRFShift_Edit.String = num2str(BurstMeta.TauFit.IRFShift);
        h.IRFShift_Slider.Value = BurstMeta.TauFit.IRFShift;
end
%%% Update Edit Boxes if Slider was used and Sliders if Edit Box was used
if isprop(obj,'Style')
    switch obj.Style
        case 'slider'
            h.TauFit.StartPar_Edit.String = num2str(BurstMeta.TauFit.StartPar);
            h.TauFit.Length_Edit.String = num2str(BurstMeta.TauFit.Length);
            h.TauFit.ShiftPer_Edit.String = num2str(BurstMeta.TauFit.ShiftPer);
            h.TauFit.IRFLength_Edit.String = num2str(BurstMeta.TauFit.IRFLength);
            h.TauFit.IRFShift_Edit.String = num2str(BurstMeta.TauFit.IRFShift);
            h.TauFit.FitPar_Table.Data{end,1} = BurstMeta.TauFit.IRFShift;
            h.TauFit.Ignore_Edit.String = num2str(BurstMeta.TauFit.Ignore);
        case 'edit'
            h.TauFit.StartPar_Slider.Value = BurstMeta.TauFit.StartPar;
            h.TauFit.Length_Slider.Value = BurstMeta.TauFit.Length;
            h.TauFit.ShiftPer_Slider.Value = BurstMeta.TauFit.ShiftPer;
            h.TauFit.IRFLength_Slider.Value = BurstMeta.TauFit.IRFLength;
            h.TauFit.IRFShift_Slider.Value = BurstMeta.TauFit.IRFShift;
            h.TauFit.FitPar_Table.Data{end,1} = BurstMeta.TauFit.IRFShift;
            h.TauFit.Ignore_Slider.Value = BurstMeta.TauFit.Ignore;
    end
end
%%% Update Plot
%%% Make the Microtime Adjustment Plot Visible, hide Result
h.TauFit.Microtime_Plot.Parent = h.MainTabTauFitPanel;
h.TauFit.Result_Plot.Parent = h.TauFit.HidePanel;

TACtoTime = 1/BurstData.FileInfo.MI_Bins*BurstData.FileInfo.TACRange*1e9;
%%% Apply the shift to the parallel channel
BurstMeta.Plots.TauFit.Decay_Par.XData = ((BurstMeta.TauFit.StartPar:(BurstMeta.TauFit.Length-1)) - BurstMeta.TauFit.StartPar)*TACtoTime;
BurstMeta.Plots.TauFit.Decay_Par.YData = BurstMeta.TauFit.hMI_Par((BurstMeta.TauFit.StartPar+1):BurstMeta.TauFit.Length)';
%%% Apply the shift to the perpendicular channel
BurstMeta.Plots.TauFit.Decay_Per.XData = ((BurstMeta.TauFit.StartPar:(BurstMeta.TauFit.Length-1)) - BurstMeta.TauFit.StartPar)*TACtoTime;
hMI_Per_Shifted = circshift(BurstMeta.TauFit.hMI_Per,[BurstMeta.TauFit.ShiftPer,0])';
BurstMeta.Plots.TauFit.Decay_Per.YData = hMI_Per_Shifted((BurstMeta.TauFit.StartPar+1):BurstMeta.TauFit.Length);
%%% Apply the shift to the parallel IRF channel
BurstMeta.Plots.TauFit.IRF_Par.XData = ((BurstMeta.TauFit.StartPar:(BurstMeta.TauFit.IRFLength-1)) - BurstMeta.TauFit.StartPar)*TACtoTime;
hIRF_Par_Shifted = circshift(BurstMeta.TauFit.hIRF_Par,[0,BurstMeta.TauFit.IRFShift])';
BurstMeta.Plots.TauFit.IRF_Par.YData = hIRF_Par_Shifted((BurstMeta.TauFit.StartPar+1):BurstMeta.TauFit.IRFLength);
%%% Apply the shift to the perpendicular IRF channel
BurstMeta.Plots.TauFit.IRF_Per.XData = ((BurstMeta.TauFit.StartPar:(BurstMeta.TauFit.IRFLength-1)) - BurstMeta.TauFit.StartPar)*TACtoTime;
hIRF_Per_Shifted = circshift(BurstMeta.TauFit.hIRF_Per,[0,BurstMeta.TauFit.IRFShift+BurstMeta.TauFit.ShiftPer])';
BurstMeta.Plots.TauFit.IRF_Per.YData = hIRF_Per_Shifted((BurstMeta.TauFit.StartPar+1):BurstMeta.TauFit.IRFLength);
%%% Scatter Pattern
BurstMeta.Plots.TauFit.Scatter_Par.XData = ((BurstMeta.TauFit.StartPar:(BurstMeta.TauFit.Length-1)) - BurstMeta.TauFit.StartPar)*TACtoTime;
hScatter_Par_Shifted = circshift(BurstMeta.TauFit.hScat_Par,[0,BurstMeta.TauFit.IRFShift])';
BurstMeta.Plots.TauFit.Scatter_Par.YData = hScatter_Par_Shifted((BurstMeta.TauFit.StartPar+1):BurstMeta.TauFit.Length);
BurstMeta.Plots.TauFit.Scatter_Per.XData = ((BurstMeta.TauFit.StartPar:(BurstMeta.TauFit.Length-1)) - BurstMeta.TauFit.StartPar)*TACtoTime;
hScatter_Per_Shifted = circshift(BurstMeta.TauFit.hScat_Per,[0,BurstMeta.TauFit.IRFShift+BurstMeta.TauFit.ShiftPer])';
BurstMeta.Plots.TauFit.Scatter_Per.YData = hScatter_Per_Shifted((BurstMeta.TauFit.StartPar+1):BurstMeta.TauFit.Length);

axes(h.TauFit.Microtime_Plot);xlim([BurstMeta.Plots.TauFit.Decay_Par.XData(1),BurstMeta.Plots.TauFit.Decay_Par.XData(end)]);
%%% Update Ignore Plot
if BurstMeta.TauFit.Ignore > 1
    %%% Make plot visible
    BurstMeta.Plots.TauFit.Ignore_Plot.Visible = 'on';
    BurstMeta.Plots.TauFit.Ignore_Plot.XData = [BurstMeta.TauFit.Ignore*TACtoTime BurstMeta.TauFit.Ignore*TACtoTime];
    BurstMeta.Plots.TauFit.Ignore_Plot.YData = h.TauFit.Microtime_Plot.YLim;
elseif BurstMeta.TauFit.Ignore == 1
    %%% Hide Plot Again
    BurstMeta.Plots.TauFit.Ignore_Plot.Visible = 'off';
end
function ChangeYScale(obj,~)
h = guidata(obj);
if strcmp(obj.Checked,'off')
    %%% Set Checked
    h.TauFit.Microtime_Plot_ChangeYScaleMenu_MIPlot.Checked = 'on';
    h.TauFit.Microtime_Plot_ChangeYScaleMenu_ResultPlot.Checked = 'on';
    %%% Change Scale to Log
    h.TauFit.Microtime_Plot.YScale = 'log';
    h.TauFit.Result_Plot.YScale = 'log';
elseif strcmp(obj.Checked,'on')
    %%% Set Unchecked
    h.TauFit.Microtime_Plot_ChangeYScaleMenu_MIPlot.Checked = 'off';
    h.TauFit.Microtime_Plot_ChangeYScaleMenu_ResultPlot.Checked = 'off';
    %%% Change Scale to Lin
    h.TauFit.Microtime_Plot.YScale = 'lin';
    h.TauFit.Result_Plot.YScale = 'lin';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Executes on Method selection change in TauFit %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Method_Selection_TauFit(obj,~)
global BurstMeta
BurstMeta.TauFit.FitType = obj.String{obj.Value};
%%% Update FitTable
h = guidata(obj);
h.TauFit.FitPar_Table.RowName = h.TauFit.Parameters{obj.Value};
h.TauFit.FitPar_Table.Data = h.TauFit.StartPar{obj.Value};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Fit the Data with selected Model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Start_TauFit(obj,~)
global BurstMeta BurstData
h = guidata(obj);
h.TauFit.Result_Plot_Text.Visible = 'off';
%% Prepare FitData
BurstMeta.TauFit.FitData.Decay_Par = BurstMeta.Plots.TauFit.Decay_Par.YData;
BurstMeta.TauFit.FitData.Decay_Per = BurstMeta.Plots.TauFit.Decay_Per.YData;

switch h.TauFit.ChannelSelect.String{h.TauFit.ChannelSelect.Value}
    case 'GG'
        G = BurstData.Corrections.GfactorGreen;
    case 'RR'
        G = BurstData.Corrections.GfactorRed;
    case 'BB'
        G = BurstData.Corrections.GfactorBlue;
end
l1 = 0;
l2 = 0;
Conv_Type = h.TauFit.ConvolutionType_Menu.String{h.TauFit.ConvolutionType_Menu.Value};

%BurstMeta.TauFit.FitData.IRF_Par = h.Plots.IRF_Par.YData;
%BurstMeta.TauFit.FitData.IRF_Per = h.Plots.IRF_Per.YData;
%%% Read out the shifted scatter pattern
%%% Don't Apply the IRF Shift here, it is done in the FitRoutine using the
%%% total Scatter Pattern to avoid Edge Effects when using circshift!
ScatterPer = circshift(BurstMeta.TauFit.hScat_Per,[0,BurstMeta.TauFit.ShiftPer]);
ScatterPattern = BurstMeta.TauFit.hScat_Par(1:BurstMeta.TauFit.Length) +...
    2*ScatterPer(1:BurstMeta.TauFit.Length);
ScatterPattern = ScatterPattern'./sum(ScatterPattern);

IRFPer = circshift(BurstMeta.TauFit.hIRF_Per,[0,BurstMeta.TauFit.ShiftPer]);
IRFPattern = BurstMeta.TauFit.hIRF_Par(1:BurstMeta.TauFit.Length) +...
    2*IRFPer(1:BurstMeta.TauFit.Length);
IRFPattern = IRFPattern'./sum(IRFPattern);
%%% Old:
%Scatter_Par_Shifted = circshift(BurstMeta.TauFit.hIRF_Par,[0,BurstMeta.TauFit.IRFShift])';
%BurstMeta.TauFit.FitData.Scatter_Par = Scatter_Par_Shifted((BurstMeta.TauFit.StartPar+1):BurstMeta.TauFit.Length)';
%Scatter_Per_Shifted = circshift(BurstMeta.TauFit.hIRF_Per,[0,BurstMeta.TauFit.IRFShift + BurstMeta.TauFit.ShiftPer])';
%BurstMeta.TauFit.FitData.Scatter_Per = Scatter_Per_Shifted((BurstMeta.TauFit.StartPar+1):BurstMeta.TauFit.Length)';
%Scatter = BurstMeta.TauFit.FitData.Scatter_Par + 2*BurstMeta.TauFit.FitData.Scatter_Per;
%Scatter = Scatter./sum(Scatter);

%%% The IRF is also adjusted in the Fit dynamically from the total scatter
%%% pattern and start,length, and shift values stored in ShiftParams
%%% ShiftParams(1)  :   StartPar
%%% ShiftParams(2)  :   IRFShift
%%% ShiftParams(3)  :   IRFLength
ShiftParams(1) = BurstMeta.TauFit.StartPar;
ShiftParams(2) = BurstMeta.TauFit.IRFShift;
ShiftParams(3) = BurstMeta.TauFit.Length;
ShiftParams(4) = BurstMeta.TauFit.IRFLength;

%%% Old:
%Irf = BurstMeta.TauFit.FitData.IRF_Par+2*BurstMeta.TauFit.FitData.IRF_Per;
%Irf = Irf-min(Irf(Irf~=0));
%Irf = Irf./sum(Irf);
%Irf = [Irf zeros(1,numel(Decay)-numel(Irf))];

%%% initialize inputs for fit
Decay = G*(1-3*l1)*BurstMeta.TauFit.FitData.Decay_Par+(2-3*l2)*BurstMeta.TauFit.FitData.Decay_Per;
BurstMeta.TauFit.TACRange = BurstData.FileInfo.TACRange;
if ~isfield(BurstData.FileInfo,'Resolution')
    BurstMeta.TauFit.TACChannelWidth = BurstMeta.TauFit.TACRange*1E9/BurstData.FileInfo.MI_Bins;
elseif isfield(BurstData.FileInfo,'Resolution') %%% HydraHarp Data
    BurstMeta.TauFit.TACChannelWidth = BurstData.FileInfo.Resolution/1000;
end
%%% Check if IRFshift is fixed or not
if h.TauFit.FitPar_Table.Data{end,4} == 0
    %%% IRF is not fixed
    irf_lb = h.TauFit.FitPar_Table.Data{end,2};
    irf_ub = h.TauFit.FitPar_Table.Data{end,3};
    shift_range = floor(BurstMeta.TauFit.IRFShift + irf_lb):ceil(BurstMeta.TauFit.IRFShift + irf_ub);
elseif h.TauFit.FitPar_Table.Data{end,4} == 1
    shift_range = BurstMeta.TauFit.IRFShift;
end
ignore = BurstMeta.TauFit.Ignore;
%% Start Fit
%%% Update Progressbar
%h.Progress_Text.String = 'Fitting...';
MI_Bins = BurstData.FileInfo.MI_Bins;

switch obj
    case h.TauFit.Start_TauFit_button
        %%% Read out parameters
        x0 = cell2mat(h.TauFit.FitPar_Table.Data(1:end-1,1))';
        lb = cell2mat(h.TauFit.FitPar_Table.Data(1:end-1,2))';
        ub = cell2mat(h.TauFit.FitPar_Table.Data(1:end-1,3))';
        fixed = cell2mat(h.TauFit.FitPar_Table.Data(1:end-1,4));
        switch BurstMeta.TauFit.FitType
            case 'Single Exponential'
                %%% Parameter:
                %%% taus    - Lifetimes
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                x0(1) = round(x0(1)/BurstMeta.TauFit.TACChannelWidth);
                lb(1) = round(lb(1)/BurstMeta.TauFit.TACChannelWidth);
                ub(1) = round(ub(1)/BurstMeta.TauFit.TACChannelWidth);
                %%% fit for different IRF offsets and compare the results
                count = 1;
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                for i = shift_range
                    %%% Update Progressbar
                    %Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_1exp(interlace(x0,x,fixed),xdata),...
                        x0(~fixed),xdata,Decay(ignore:end),lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay(ignore:end);sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum((x.^2./sigma_est)/(numel(Decay(ignore:end))-numel(x0))),residuals);
                [~,best_fit] = min(chi2);
                FitFun = fitfun_1exp(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun)./sqrt(Decay);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                FitResult{1} = FitResult{1}.*BurstMeta.TauFit.TACChannelWidth;
                h.TauFit.FitPar_Table.Data(:,1) = FitResult;
            case 'Biexponential'
                %%% Parameter:
                %%% taus    - Lifetimes
                %%% A       - Amplitude of first lifetime
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                x0(1:2) = round(x0(1:2)/BurstMeta.TauFit.TACChannelWidth);
                lb(1:2) = round(lb(1:2)/BurstMeta.TauFit.TACChannelWidth);
                ub(1:2) = round(ub(1:2)/BurstMeta.TauFit.TACChannelWidth);
                %%% fit for different IRF offsets and compare the results
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                count = 1;
                for i = shift_range
                    %%% Update Progressbar
                    %Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_2exp(interlace(x0,x,fixed),xdata),...
                        x0(~fixed),xdata,Decay(ignore:end),lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay(ignore:end);sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum((x.^2./sigma_est)/(numel(Decay(ignore:end))-numel(x0))),residuals);
                [~,best_fit] = min(chi2);
                FitFun = fitfun_2exp(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun)./sqrt(Decay);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*BurstMeta.TauFit.TACChannelWidth;
                FitResult{2} = FitResult{2}.*BurstMeta.TauFit.TACChannelWidth;
                %%% Convert Fraction from Area Fraction to Amplitude Fraction
                %%% (i.e. correct for brightness)
                amp1 = FitResult{3}./FitResult{1}; amp2 = (1-FitResult{3})./FitResult{2};
                amp1 = amp1./(amp1+amp2);
                FitResult{3} = amp1;
                h.TauFit.FitPar_Table.Data(:,1) = FitResult;
            case 'Three Exponentials'
                %%% Parameter:
                %%% taus    - Lifetimes
                %%% A1      - Amplitude of first lifetime
                %%% A2      - Amplitude of first lifetime
                %%% scatter - Scatter Background (IRF pattern)
                %%% Convert Lifetimes
                x0(1:3) = round(x0(1:3)/BurstMeta.TauFit.TACChannelWidth);
                lb(1:3) = round(lb(1:3)/BurstMeta.TauFit.TACChannelWidth);
                ub(1:3) = round(ub(1:3)/BurstMeta.TauFit.TACChannelWidth);
                %%% fit for different IRF offsets and compare the results
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                count = 1;
                for i = shift_range
                    %%% Update Progressbar
                    %Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_3exp(interlace(x0,x,fixed),xdata),...
                        x0(~fixed),xdata,Decay(ignore:end),lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay(ignore:end);sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum((x.^2./sigma_est)/(numel(Decay(ignore:end))-numel(x0))),residuals);
                [~,best_fit] = min(chi2);
                FitFun = fitfun_3exp(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun)./sqrt(Decay);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*BurstMeta.TauFit.TACChannelWidth;
                FitResult{2} = FitResult{2}.*BurstMeta.TauFit.TACChannelWidth;
                FitResult{3} = FitResult{3}.*BurstMeta.TauFit.TACChannelWidth;
                %%% Convert Fraction from Area Fraction to Amplitude Fraction
                %%% (i.e. correct for brightness)
                amp1 = FitResult{4}./FitResult{1}; amp2 = FitResult{5}./FitResult{2}; amp3 = (1-FitResult{4}-FitResult{5})./FitResult{3};
                amp1 = amp1./(amp1+amp2+amp3); amp2 = amp2./(amp1+amp2+amp3);
                FitResult{4} = amp1;
                FitResult{5} = amp2;
                h.TauFit.FitPar_Table.Data(:,1) = FitResult;
            case 'Distribution'
                %%% Parameter:
                %%% Center R
                %%% sigmaR
                %%% Background
                %%% R0
                %%% Donor only lifetime
                %%% Convert Lifetimes
                x0(6) = round(x0(6)/BurstMeta.TauFit.TACChannelWidth);
                lb(6) = round(lb(6)/BurstMeta.TauFit.TACChannelWidth);
                ub(6) = round(ub(6)/BurstMeta.TauFit.TACChannelWidth);
                %%% fit for different IRF offsets and compare the results
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                count = 1;
                for i = shift_range
                    %%% Update Progressbar
                    %Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_dist(interlace(x0,x,fixed),xdata),...
                        x0(~fixed),xdata,Decay(ignore:end),lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay(ignore:end);sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum((x.^2./sigma_est)/(numel(Decay(ignore:end))-numel(x0))),residuals);
                [~,best_fit] = min(chi2);
                FitFun = fitfun_dist(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun)./sqrt(Decay);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{6} = FitResult{6}.*BurstMeta.TauFit.TACChannelWidth;
                h.TauFit.FitPar_Table.Data(:,1) = FitResult;
            case 'Distribution plus Donor only'
                %%% Parameter:
                %%% Center R
                %%% sigmaR
                %%% Fraction D only
                %%% Background
                %%% R0
                %%% Donor only lifetime
                
                %%% Convert Lifetimes
                x0(7) = round(x0(7)/BurstMeta.TauFit.TACChannelWidth);
                lb(7) = round(lb(7)/BurstMeta.TauFit.TACChannelWidth);
                ub(7) = round(ub(7)/BurstMeta.TauFit.TACChannelWidth);
                %%% fit for different IRF offsets and compare the results
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                count = 1;
                for i = shift_range
                    %%% Update Progressbar
                    %Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(ignore:end),i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_dist_donly(interlace(x0,x,fixed),xdata),...
                        x0(~fixed),xdata,Decay(ignore:end),lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay(ignore:end);sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum((x.^2./sigma_est)/(numel(Decay(ignore:end))-numel(x0))),residuals);
                [~,best_fit] = min(chi2);
                FitFun = fitfun_dist_donly(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay(1:end),shift_range(best_fit),1,Conv_Type});
                wres = (Decay-FitFun)./sqrt(Decay);
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{7} = FitResult{7}.*BurstMeta.TauFit.TACChannelWidth;
                h.TauFit.FitPar_Table.Data(:,1) = FitResult;
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
                IRFPattern{1} = BurstMeta.TauFit.hIRF_Par(1:BurstMeta.TauFit.Length)';IRFPattern{1} = IRFPattern{1}./sum(IRFPattern{1});
                IRFPattern{2} = IRFPer(1:BurstMeta.TauFit.Length)';IRFPattern{2} = IRFPattern{2}./sum(IRFPattern{2});
                
                %%% Define separate Scatter Patterns
                ScatterPattern = cell(2,1);
                ScatterPattern{1} = BurstMeta.TauFit.hScat_Par(1:BurstMeta.TauFit.Length)';ScatterPattern{1} = ScatterPattern{1}./sum(ScatterPattern{1});
                ScatterPattern{2} = ScatterPer(1:BurstMeta.TauFit.Length)';ScatterPattern{2} = ScatterPattern{2}./sum(ScatterPattern{2});
                
                %%% Convert Lifetimes
                x0(1:2) = round(x0(1:2)/BurstMeta.TauFit.TACChannelWidth);
                lb(1:2) = round(lb(1:2)/BurstMeta.TauFit.TACChannelWidth);
                ub(1:2) = round(ub(1:2)/BurstMeta.TauFit.TACChannelWidth);
                
                %%% Prepare data as vector
                Decay =  [BurstMeta.TauFit.FitData.Decay_Par(ignore:end); BurstMeta.TauFit.FitData.Decay_Per(ignore:end)];
                Decay_stacked = [BurstMeta.TauFit.FitData.Decay_Par(ignore:end) BurstMeta.TauFit.FitData.Decay_Per(ignore:end)];
                %%% fit for different IRF offsets and compare the results
                x = cell(numel(shift_range,1));
                residuals = cell(numel(shift_range,1));
                count = 1;
                for i = shift_range
                    %%% Update Progressbar
                    %Progress((count-1)/numel(shift_range),h.Progress_Axes,h.Progress_Text,'Fitting...');
                    xdata = {ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,i,ignore,Conv_Type};
                    [x{count}, ~, residuals{count}] = lsqcurvefit(@(x,xdata) fitfun_aniso(interlace(x0,x,fixed),xdata),...
                        x0(~fixed),xdata,Decay_stacked,lb(~fixed),ub(~fixed));
                    x{count} = interlace(x0,x{count},fixed);
                    count = count +1;
                end
                sigma_est = Decay_stacked;sigma_est(sigma_est == 0) = 1;
                chi2 = cellfun(@(x) sum((x.^2./sigma_est)/(numel(Decay_stacked)-numel(x0))),residuals);
                [~,best_fit] = min(chi2);
                %%% remove ignore range from decay
                Decay = [BurstMeta.TauFit.FitData.Decay_Par; BurstMeta.TauFit.FitData.Decay_Per];
                Decay_stacked = [BurstMeta.TauFit.FitData.Decay_Par BurstMeta.TauFit.FitData.Decay_Per];
                FitFun = fitfun_aniso(x{best_fit},{ShiftParams,IRFPattern,ScatterPattern,MI_Bins,Decay,shift_range(best_fit),1,Conv_Type});
                wres = (Decay_stacked-FitFun)./sqrt(Decay_stacked); Decay = Decay_stacked;
                
                %%% Update FitResult
                FitResult = num2cell([x{best_fit} shift_range(best_fit)]');
                %%% Convert Lifetimes to Nanoseconds
                FitResult{1} = FitResult{1}.*BurstMeta.TauFit.TACChannelWidth;
                FitResult{2} = FitResult{2}.*BurstMeta.TauFit.TACChannelWidth;
                h.TauFit.FitPar_Table.Data(:,1) = FitResult;
        end
        
        %%% Update IRFShift in Slider and Edit Box
        h.TauFit.IRFShift_Slider.Value = shift_range(best_fit);
        h.TauFit.IRFShift_Edit.String = num2str(shift_range(best_fit));
        
        %%% Reset Progressbar
        %h.Progress_Text.String = 'Fit done';
        %%% Update Plot
        h.TauFit.Microtime_Plot.Parent = h.TauFit.HidePanel;
        h.TauFit.Result_Plot.Parent = h.MainTabTauFitPanel;
        
        
        TACtoTime = 1/BurstData.FileInfo.MI_Bins*BurstData.FileInfo.TACRange*1e9;
        BurstMeta.Plots.TauFit.DecayResult.XData = (1:numel(Decay))*TACtoTime;
        BurstMeta.Plots.TauFit.DecayResult.YData = Decay;
        BurstMeta.Plots.TauFit.FitResult.XData = (1:numel(Decay))*TACtoTime;
        BurstMeta.Plots.TauFit.FitResult.YData = FitFun;
        axis(h.TauFit.Result_Plot,'tight');
        % plot chi^2 on graph
        h.TauFit.Result_Plot_Text.Visible = 'on';
        h.TauFit.Result_Plot_Text.String = sprintf(['chi^2 = ' num2str(chi2(best_fit))]);
        h.TauFit.Result_Plot_Text.Position = [0.8*h.TauFit.Result_Plot.XLim(2) 0.9*h.TauFit.Result_Plot.YLim(2)];
        
        BurstMeta.Plots.TauFit.Residuals.XData = (1:numel(Decay))*TACtoTime;
        BurstMeta.Plots.TauFit.Residuals.YData = wres;
        BurstMeta.Plots.TauFit.Residuals_ZeroLine.XData = (1:numel(Decay))*TACtoTime;
        BurstMeta.Plots.TauFit.Residuals_ZeroLine.YData = zeros(1,numel(Decay));
    case h.TauFit.Start_AnisoFit_button
        %%% construct Anisotropy
        Aniso = (G*BurstMeta.TauFit.FitData.Decay_Par - BurstMeta.TauFit.FitData.Decay_Per)./Decay;
        Aniso(isnan(Aniso)) = 0;
        Aniso_fit = Aniso(ignore:end); x = 1:numel(Aniso_fit);
        %%% Fit function
        tres_aniso = @(x,xdata) (x(2)-x(3))*exp(-xdata./x(1)) + x(3);
        param0 = [1/(BurstData.FileInfo.TACRange*1e9)*BurstData.FileInfo.MI_Bins, 0.4,0];
        param = lsqcurvefit(tres_aniso,param0,x,Aniso_fit,[0 0 -1],[Inf,1,1]);
        
        fitres = tres_aniso(param,x);
        res = Aniso_fit-fitres;
        
        TACtoTime = 1/BurstData.FileInfo.MI_Bins*BurstData.FileInfo.TACRange*1e9;
        %%% Update Plot
        h.TauFit.Microtime_Plot.Parent = h.TauFit.HidePanel;
        h.TauFit.Result_Plot.Parent = h.MainTabTauFitPanel;
        
        BurstMeta.Plots.TauFit.DecayResult.XData = x*TACtoTime;
        BurstMeta.Plots.TauFit.DecayResult.YData = Aniso_fit;
        BurstMeta.Plots.TauFit.FitResult.XData = x*TACtoTime;
        BurstMeta.Plots.TauFit.FitResult.YData = fitres;
        axis(h.TauFit.Result_Plot,'tight');
        h.TauFit.Result_Plot_Text.Visible = 'on';
        h.TauFit.Result_Plot_Text.String = sprintf('rho = %1.2f ns\nr0 = %2.2f\nr_{inf} = %3.2f',param(1)*TACtoTime,param(2),param(3));
        h.TauFit.Result_Plot_Text.Position = [0.8*h.TauFit.Result_Plot.XLim(2) 0.9*h.TauFit.Result_Plot.YLim(2)];
        
        BurstMeta.Plots.TauFit.Residuals.XData = x*TACtoTime;
        BurstMeta.Plots.TauFit.Residuals.YData = res;
        BurstMeta.Plots.TauFit.Residuals_ZeroLine.XData = x*TACtoTime;
        BurstMeta.Plots.TauFit.Residuals_ZeroLine.YData = zeros(1,numel(x));
end
function a = interlace( a, x, fix )
a(~fix) = x;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Corrections in GUI and UserValues  %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateCorrections(obj,~)
global UserValues BurstData
h = guidata(findobj('Tag','BurstBrowser'));
if isempty(obj) %%% Just change the data to what is stored in UserValues
    if isempty(BurstData)
        %%% function was called on GUI startup, default to 2cMFD
        h.CorrectionsTable.Data = {UserValues.BurstBrowser.Corrections.Gamma_GR;...
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
        if ~isfield(BurstData,'Background')
            switch BurstData.BAMethod
                case {1,2}
                    BurstData.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
                    BurstData.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
                    BurstData.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
                    BurstData.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
                    BurstData.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
                    BurstData.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
                case {3,4}
                    BurstData.Background.Background_BBpar = UserValues.BurstBrowser.Corrections.Background_BBpar;
                    BurstData.Background.Background_BBperp = UserValues.BurstBrowser.Corrections.Background_BBperp;
                    BurstData.Background.Background_BGpar = UserValues.BurstBrowser.Corrections.Background_BGpar;
                    BurstData.Background.Background_BGperp = UserValues.BurstBrowser.Corrections.Background_BGperp;
                    BurstData.Background.Background_BRpar = UserValues.BurstBrowser.Corrections.Background_BRpar;
                    BurstData.Background.Background_BRperp = UserValues.BurstBrowser.Corrections.Background_BRperp;
                    BurstData.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
                    BurstData.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
                    BurstData.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
                    BurstData.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
                    BurstData.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
                    BurstData.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
            end
        end
        %%% Backwards Compatibility Check (Remove at some point)
        if ~isstruct(BurstData.Background) % Second check for compatibility of old data (Background was stored in array, not in struct)
            switch BurstData.BAMethod
                case {1,2}
                    Background.Background_GGpar = BurstData.Background(1);
                    Background.Background_GGperp = BurstData.Background(2);
                    Background.Background_GRpar = BurstData.Background(3);
                    Background.Background_GRperp = BurstData.Background(4);
                    Background.Background_RRpar = BurstData.Background(5);
                    Background.Background_RRperp = BurstData.Background(6);
                case {3,4}
                    Background.Background_BBpar = BurstData.Background(1);
                    Background.Background_BBperp = BurstData.Background(2);
                    Background.Background_BGpar = BurstData.Background(3);
                    Background.Background_BGperp = BurstData.Background(4);
                    Background.Background_BRpar = BurstData.Background(5);
                    Background.Background_BRperp = BurstData.Background(6);
                    Background.Background_GGpar = BurstData.Background(7);
                    Background.Background_GGperp = BurstData.Background(8);
                    Background.Background_GRpar = BurstData.Background(9);
                    Background.Background_GRperp = BurstData.Background(10);
                    Background.Background_RRpar = BurstData.Background(11);
                    Background.Background_RRperp = BurstData.Background(12);
            end
            BurstData.Background = Background;
        end
        %%% Set Correction Struct to UserValues. From here on, corrections
        %%% are stored individually per measurement.
        if ~isfield(BurstData,'Corrections') || ~isstruct(BurstData.Corrections) % Second check for compatibility of old data
            switch BurstData.BAMethod
                case {1,2}
                    BurstData.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
                    BurstData.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
                    BurstData.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
                    BurstData.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
                    BurstData.Corrections.GfactorGreen =  UserValues.BurstBrowser.Corrections.GfactorGreen;
                    BurstData.Corrections.GfactorRed = UserValues.BurstBrowser.Corrections.GfactorRed;
                    BurstData.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
                    BurstData.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
                    BurstData.Corrections.FoersterRadius = UserValues.BurstBrowser.Corrections.FoersterRadius;
                    BurstData.Corrections.LinkerLength = UserValues.BurstBrowser.Corrections.LinkerLength;
                case {3,4}
                    BurstData.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
                    BurstData.Corrections.CrossTalk_BG = UserValues.BurstBrowser.Corrections.CrossTalk_BG;
                    BurstData.Corrections.CrossTalk_BR = UserValues.BurstBrowser.Corrections.CrossTalk_BR;
                    BurstData.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
                    BurstData.Corrections.DirectExcitation_BG = UserValues.BurstBrowser.Corrections.DirectExcitation_BG;
                    BurstData.Corrections.DirectExcitation_BR = UserValues.BurstBrowser.Corrections.DirectExcitation_BR;
                    BurstData.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
                    BurstData.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
                    BurstData.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
                    BurstData.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
                    BurstData.Corrections.Beta_BG = UserValues.BurstBrowser.Corrections.Beta_BG;
                    BurstData.Corrections.Beta_BR = UserValues.BurstBrowser.Corrections.Beta_BR;
                    BurstData.Corrections.GfactorBlue = UserValues.BurstBrowser.Corrections.GfactorBlue;
                    BurstData.Corrections.GfactorGreen = UserValues.BurstBrowser.Corrections.GfactorGreen;
                    BurstData.Corrections.GfactorRed = UserValues.BurstBrowser.Corrections.GfactorRed;
                    BurstData.Corrections.DonorLifetimeBlue = UserValues.BurstBrowser.Corrections.DonorLifetimeBlue;
                    BurstData.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
                    BurstData.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
                    BurstData.Corrections.FoersterRadius = UserValues.BurstBrowser.Corrections.FoersterRadius;
                    BurstData.Corrections.LinkerLength = UserValues.BurstBrowser.Corrections.LinkerLength;
                    BurstData.Corrections.FoersterRadiusBG = UserValues.BurstBrowser.Corrections.FoersterRadiusBG;
                    BurstData.Corrections.LinkerLengthBG = UserValues.BurstBrowser.Corrections.LinkerLengthBG;
                    BurstData.Corrections.FoersterRadiusBR = UserValues.BurstBrowser.Corrections.FoersterRadiusBR;
                    BurstData.Corrections.LinkerLengthBR = UserValues.BurstBrowser.Corrections.LinkerLengthBR;
                    BurstData.Corrections.r0_green = UserValues.BurstBrowser.Corrections.r0_green;
                    BurstData.Corrections.r0_red = UserValues.BurstBrowser.Corrections.r0_red;
                    BurstData.Corrections.r0_blue = UserValues.BurstBrowser.Corrections.r0_blue;
            end
        end
        if ~isfield(BurstData.Corrections,'r0_green')
            BurstData.Corrections.r0_green = UserValues.BurstBrowser.Corrections.r0_green;
        end
        if ~isfield(BurstData.Corrections,'r0_red')
            BurstData.Corrections.r0_red = UserValues.BurstBrowser.Corrections.r0_red;
        end
        if ~isfield(BurstData.Corrections,'r0_blue') && any(BurstData.BAMethod == [3,4])
            BurstData.Corrections.r0_blue = UserValues.BurstBrowser.Corrections.r0_blue;
        end
        %%% Update GUI with values stored in BurstData Structure
        switch BurstData.BAMethod
            case {1,2}
                h.DonorLifetimeEdit.String = num2str(BurstData.Corrections.DonorLifetime);
                h.AcceptorLifetimeEdit.String = num2str(BurstData.Corrections.AcceptorLifetime);
                h.FoersterRadiusEdit = num2str(BurstData.Corrections.FoersterRadius);
                h.LinkerLengthEdit = num2str(BurstData.Corrections.LinkerLength);
                h.r0Green_edit.String = num2str(BurstData.Corrections.r0_green);
                h.r0Red_edit = num2str(BurstData.Corrections.r0_red);
            case {3,4}
                h.DonorLifetimeBlueEdit.String = num2str(BurstData.Corrections.DonorLifetimeBlue);
                h.DonorLifetimeEdit.String = num2str(BurstData.Corrections.DonorLifetime);
                h.AcceptorLifetimeEdit.String = num2str(BurstData.Corrections.AcceptorLifetime);
                h.FoersterRadiusEdit = num2str(BurstData.Corrections.FoersterRadius);
                h.LinkerLengthEdit = num2str(BurstData.Corrections.LinkerLength);
                h.FoersterRadiusBGEdit = num2str(BurstData.Corrections.FoersterRadiusBG);
                h.LinkerLengthBGEdit = num2str(BurstData.Corrections.LinkerLengthBG);
                h.FoersterRadiusBREdit = num2str(BurstData.Corrections.FoersterRadiusBR);
                h.LinkerLengthBREdit = num2str(BurstData.Corrections.LinkerLengthBR);
                h.r0Blue_edit.String = num2str(BurstData.Corrections.r0_blue);
                h.r0Green_edit.String = num2str(BurstData.Corrections.r0_green);
                h.r0Red_edit = num2str(BurstData.Corrections.r0_red);
        end
        
        if any(BurstData.BAMethod == [1,2]) %%% 2cMFD, same as default
            h.CorrectionsTable.Data = {BurstData.Corrections.Gamma_GR;...
                BurstData.Corrections.Beta_GR;...
                BurstData.Corrections.CrossTalk_GR;...
                BurstData.Corrections.DirectExcitation_GR;...
                BurstData.Corrections.GfactorGreen;...
                BurstData.Corrections.GfactorRed;...
                UserValues.BurstBrowser.Corrections.l1;...
                UserValues.BurstBrowser.Corrections.l2;...
                BurstData.Background.Background_GGpar;...
                BurstData.Background.Background_GGperp;...
                BurstData.Background.Background_GRpar;...
                BurstData.Background.Background_GRperp;...
                BurstData.Background.Background_RRpar;...
                BurstData.Background.Background_RRperp};
        elseif any(BurstData.BAMethod == [3,4]) %%% 3cMFD
            h.CorrectionsTable.Data = {BurstData.Corrections.Gamma_GR;...
                BurstData.Corrections.Gamma_BG;...
                BurstData.Corrections.Gamma_BR;...
                BurstData.Corrections.Beta_GR;...
                BurstData.Corrections.Beta_BG;...
                BurstData.Corrections.Beta_BR;...
                BurstData.Corrections.CrossTalk_GR;...
                BurstData.Corrections.CrossTalk_BG;...
                BurstData.Corrections.CrossTalk_BR;...
                BurstData.Corrections.DirectExcitation_GR;...
                BurstData.Corrections.DirectExcitation_BG;...
                BurstData.Corrections.DirectExcitation_BR;...
                BurstData.Corrections.GfactorBlue;...
                BurstData.Corrections.GfactorGreen;...
                BurstData.Corrections.GfactorRed;...
                UserValues.BurstBrowser.Corrections.l1;...
                UserValues.BurstBrowser.Corrections.l2;...
                BurstData.Background.Background_BBpar;...
                BurstData.Background.Background_BBperp;...
                BurstData.Background.Background_BGpar;...
                BurstData.Background.Background_BGperp;...
                BurstData.Background.Background_BRpar;...
                BurstData.Background.Background_BRperp;...
                BurstData.Background.Background_GGpar;...
                BurstData.Background.Background_GGperp;...
                BurstData.Background.Background_GRpar;...
                BurstData.Background.Background_GRperp;...
                BurstData.Background.Background_RRpar;...
                BurstData.Background.Background_RRperp};
        end
        
    end
else %%% Update UserValues with new values
    LSUserValues(0);
    switch obj
        case h.CorrectionsTable
            if any(BurstData.BAMethod == [1,2]) %%% 2cMFD
                UserValues.BurstBrowser.Corrections.Gamma_GR = obj.Data{1};
                BurstData.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
                UserValues.BurstBrowser.Corrections.Beta_GR = obj.Data{2};
                BurstData.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
                UserValues.BurstBrowser.Corrections.CrossTalk_GR = obj.Data{3};
                BurstData.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
                UserValues.BurstBrowser.Corrections.DirectExcitation_GR= obj.Data{4};
                BurstData.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
                UserValues.BurstBrowser.Corrections.GfactorGreen = obj.Data{5};
                BurstData.Corrections.GfactorGreen = UserValues.BurstBrowser.Corrections.GfactorGreen;
                UserValues.BurstBrowser.Corrections.GfactorRed = obj.Data{6};
                BurstData.Corrections.GfactorRed = UserValues.BurstBrowser.Corrections.GfactorRed;
                UserValues.BurstBrowser.Corrections.l1 = obj.Data{7};
                UserValues.BurstBrowser.Corrections.l2 = obj.Data{8};
                UserValues.BurstBrowser.Corrections.Background_GGpar= obj.Data{9};
                BurstData.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
                UserValues.BurstBrowser.Corrections.Background_GGperp= obj.Data{10};
                BurstData.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
                UserValues.BurstBrowser.Corrections.Background_GRpar= obj.Data{11};
                BurstData.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
                UserValues.BurstBrowser.Corrections.Background_GRperp= obj.Data{12};
                BurstData.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
                UserValues.BurstBrowser.Corrections.Background_RRpar= obj.Data{13};
                BurstData.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
                UserValues.BurstBrowser.Corrections.Background_RRperp= obj.Data{14};
                BurstData.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
            elseif any(BurstData.BAMethod == [3,4]) %%% 3cMFD
                UserValues.BurstBrowser.Corrections.Gamma_GR = obj.Data{1};
                BurstData.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
                UserValues.BurstBrowser.Corrections.Gamma_BG = obj.Data{2};
                BurstData.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
                UserValues.BurstBrowser.Corrections.Gamma_BR = obj.Data{3};
                BurstData.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
                UserValues.BurstBrowser.Corrections.Beta_GR = obj.Data{4};
                BurstData.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
                UserValues.BurstBrowser.Corrections.Beta_BG = obj.Data{5};
                BurstData.Corrections.Beta_BG = UserValues.BurstBrowser.Corrections.Beta_BG;
                UserValues.BurstBrowser.Corrections.Beta_BR = obj.Data{6};
                BurstData.Corrections.Beta_BR = UserValues.BurstBrowser.Corrections.Beta_BR;
                UserValues.BurstBrowser.Corrections.CrossTalk_GR = obj.Data{7};
                BurstData.Corrections.CrossTalk_GR = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
                UserValues.BurstBrowser.Corrections.CrossTalk_BG = obj.Data{8};
                BurstData.Corrections.CrossTalk_BG = UserValues.BurstBrowser.Corrections.CrossTalk_BG;
                UserValues.BurstBrowser.Corrections.CrossTalk_BR = obj.Data{9};
                BurstData.Corrections.CrossTalk_BR = UserValues.BurstBrowser.Corrections.CrossTalk_BR;
                UserValues.BurstBrowser.Corrections.DirectExcitation_GR= obj.Data{10};
                BurstData.Corrections.DirectExcitation_GR = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
                UserValues.BurstBrowser.Corrections.DirectExcitation_BG= obj.Data{11};
                BurstData.Corrections.DirectExcitation_BG = UserValues.BurstBrowser.Corrections.DirectExcitation_BG;
                UserValues.BurstBrowser.Corrections.DirectExcitation_BR= obj.Data{12};
                BurstData.Corrections.DirectExcitation_BR = UserValues.BurstBrowser.Corrections.DirectExcitation_BR;
                UserValues.BurstBrowser.Corrections.GfactorBlue = obj.Data{13};
                BurstData.Corrections.GfactorBlue = UserValues.BurstBrowser.Corrections.GfactorBlue;
                UserValues.BurstBrowser.Corrections.GfactorGreen = obj.Data{14};
                BurstData.Corrections.GfactorGreen = UserValues.BurstBrowser.Corrections.GfactorGreen;
                UserValues.BurstBrowser.Corrections.GfactorRed = obj.Data{15};
                BurstData.Corrections.GfactorRed = UserValues.BurstBrowser.Corrections.GfactorRed;
                UserValues.BurstBrowser.Corrections.l1 = obj.Data{16};
                UserValues.BurstBrowser.Corrections.l2 = obj.Data{17};
                UserValues.BurstBrowser.Corrections.Background_BBpar= obj.Data{18};
                BurstData.Background.Background_BBpar = UserValues.BurstBrowser.Corrections.Background_BBpar;
                UserValues.BurstBrowser.Corrections.Background_BBperp= obj.Data{19};
                BurstData.Background.Background_BBperp = UserValues.BurstBrowser.Corrections.Background_BBperp;
                UserValues.BurstBrowser.Corrections.Background_BGpar= obj.Data{20};
                BurstData.Background.Background_BGpar = UserValues.BurstBrowser.Corrections.Background_BGpar;
                UserValues.BurstBrowser.Corrections.Background_BGperp= obj.Data{21};
                BurstData.Background.Background_BGperp = UserValues.BurstBrowser.Corrections.Background_BGperp;
                UserValues.BurstBrowser.Corrections.Background_BRpar= obj.Data{22};
                BurstData.Background.Background_BRpar = UserValues.BurstBrowser.Corrections.Background_BRpar;
                UserValues.BurstBrowser.Corrections.Background_BRperp= obj.Data{23};
                BurstData.Background.Background_BRperp = UserValues.BurstBrowser.Corrections.Background_BRperp;
                UserValues.BurstBrowser.Corrections.Background_GGpar= obj.Data{24};
                BurstData.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
                UserValues.BurstBrowser.Corrections.Background_GGperp= obj.Data{25};
                BurstData.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
                UserValues.BurstBrowser.Corrections.Background_GRpar= obj.Data{26};
                BurstData.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
                UserValues.BurstBrowser.Corrections.Background_GRperp= obj.Data{27};
                BurstData.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
                UserValues.BurstBrowser.Corrections.Background_RRpar= obj.Data{28};
                BurstData.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
                UserValues.BurstBrowser.Corrections.Background_RRperp= obj.Data{29};
                BurstData.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
            end
        case h.DonorLifetimeEdit
            if ~isnan(str2double(h.DonorLifetimeEdit.String))
                UserValues.BurstBrowser.Corrections.DonorLifetime = str2double(h.DonorLifetimeEdit.String);
                BurstData.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
            else %%% Reset value
                h.DonorLifetimeEdit.String = num2str(BurstData.Corrections.DonorLifetime);
            end
            UpdateLifetimePlots([],[]);
        case h.AcceptorLifetimeEdit
            if ~isnan(str2double(h.AcceptorLifetimeEdit.String))
                UserValues.BurstBrowser.Corrections.AcceptorLifetime = str2double(h.AcceptorLifetimeEdit.String);
                BurstData.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
            else %%% Reset value
                h.AcceptorLifetimeEdit.String = num2str(UserValues.BurstBrowser.Corrections.AcceptorLifetime);
            end
            UpdateLifetimePlots([],[]);
        case h.DonorLifetimeBlueEdit
            if ~isnan(str2double(h.DonorLifetimeBlueEdit.String))
                UserValues.BurstBrowser.Corrections.DonorLifetimeBlue = str2double(h.DonorLifetimeBlueEdit.String);
                BurstData.Corrections.DonorLifetimeBlue = UserValues.BurstBrowser.Corrections.DonorLifetimeBlue;
            else %%% Reset value
                h.DonorLifetimeBlueEdit.String = num2str(UserValues.BurstBrowser.Corrections.DonorLifetimeBlue);
            end
            UpdateLifetimePlots([],[]);
        case h.FoersterRadiusEdit
            if ~isnan(str2double(h.FoersterRadiusEdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadius = str2double(h.FoersterRadiusEdit.String);
                BurstData.Corrections.FoersterRadius = UserValues.BurstBrowser.Corrections.FoersterRadius;
            else %%% Reset value
                h.FoersterRadiusEdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadius);
            end
        case h.LinkerLengthEdit
            if ~isnan(str2double(h.LinkerLengthEdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLength = str2double(h.LinkerLengthEdit.String);
                BurstData.Corrections.LinkerLength = UserValues.BurstBrowser.Corrections.LinkerLength;
            else %%% Reset value
                h.LinkerLengthEdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLength);
            end
        case h.FoersterRadiusBGEdit
            if ~isnan(str2double(h.FoersterRadiusBGEdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadiusBG = str2double(h.FoersterRadiusBGEdit.String);
                BurstData.Corrections.FoersterRadiusBG = UserValues.BurstBrowser.Corrections.FoersterRadiusBG;
            else %%% Reset value
                h.FoersterRadiusBGEdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadiusBG);
            end
        case h.LinkerLengthBGEdit
            if ~isnan(str2double(h.LinkerLengthBGEdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLengthBG = str2double(h.LinkerLengthBGEdit.String);
                BurstData.Corrections.LinkerLengthBG = UserValues.BurstBrowser.Corrections.LinkerLengthBG;
            else %%% Reset value
                h.LinkerLengthBGEdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLengthBG);
            end
        case h.FoersterRadiusBREdit
            if ~isnan(str2double(h.FoersterRadiusBREdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadiusBR = str2double(h.FoersterRadiusBREdit.String);
                BurstData.Corrections.FoersterRadiusBR = UserValues.BurstBrowser.Corrections.FoersterRadiusBR;
            else %%% Reset value
                h.FoersterRadiusBREdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadiusBR);
            end
        case h.LinkerLengthBREdit
            if ~isnan(str2double(h.LinkerLengthBREdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLengthBR = str2double(h.LinkerLengthBREdit.String);
                BurstData.Corrections.LinkerLengthBR = UserValues.BurstBrowser.Corrections.LinkerLengthBR;
            else %%% Reset value
                h.LinkerLengthBREdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLengthBR);
            end
        case h.r0Green_edit
            if ~isnan(str2double(h.r0Green_edit.String))
                UserValues.BurstBrowser.Corrections.r0_green = str2double(h.r0Green_edit.String);
                BurstData.Corrections.r0_green = UserValues.BurstBrowser.Corrections.r0_green;
            else %%% Reset value
                h.r0Green_edit.String = num2str(UserValues.BurstBrowser.Corrections.r0_green);
            end
        case h.r0Red_edit
            if ~isnan(str2double(h.r0Red_edit.String))
                UserValues.BurstBrowser.Corrections.r0_red = str2double(h.r0Red_edit.String);
                BurstData.Corrections.r0_red = UserValues.BurstBrowser.Corrections.r0_red;
            else %%% Reset value
                h.r0Red_edit.String = num2str(UserValues.BurstBrowser.Corrections.r0_red);
            end
        case h.r0Blue_edit
            if ~isnan(str2double(h.r0Blue_edit.String))
                UserValues.BurstBrowser.Corrections.r0_blue = str2double(h.r0Blue_edit.String);
                BurstData.Corrections.r0_blue = UserValues.BurstBrowser.Corrections.r0_blue;
            else %%% Reset value
                h.r0Blue_edit.String = num2str(UserValues.BurstBrowser.Corrections.r0_blue);
            end
    end
    LSUserValues(1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Applies Corrections to data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ApplyCorrections(obj,~)
global BurstData UserValues BurstMeta
h = guidata(obj);
if obj == h.UseBetaCheckbox
    UserValues.BurstBrowser.Corrections.UseBeta = obj.Value;
    LSUserValues(1);
end
%% 2colorMFD
%% FRET and Stoichiometry Corrections
%%% Read out indices of parameters
indS = BurstMeta.posS;
indE = BurstMeta.posE;
indDur = strcmp(BurstData.NameArray,'Duration [ms]');
indNGG = strcmp(BurstData.NameArray,'Number of Photons (GG)');
indNGR = strcmp(BurstData.NameArray,'Number of Photons (GR)');
indNRR = strcmp(BurstData.NameArray,'Number of Photons (RR)');

%%% Read out photons counts and duration
NGG = BurstData.DataArray(:,indNGG);
NGR = BurstData.DataArray(:,indNGR);
NRR = BurstData.DataArray(:,indNRR);
Dur = BurstData.DataArray(:,indDur);

%%% Read out corrections
gamma_gr = BurstData.Corrections.Gamma_GR;
beta_gr = BurstData.Corrections.Beta_GR;
ct_gr = BurstData.Corrections.CrossTalk_GR;
de_gr = BurstData.Corrections.DirectExcitation_GR;
BG_GG = BurstData.Background.Background_GGpar + BurstData.Background.Background_GGperp;
BG_GR = BurstData.Background.Background_GRpar + BurstData.Background.Background_GRperp;
BG_RR = BurstData.Background.Background_RRpar + BurstData.Background.Background_RRperp;

%%% Apply Background corrections
NGG = NGG - Dur.*BG_GG;
NGR = NGR - Dur.*BG_GR;
NRR = NRR - Dur.*BG_RR;

%%% Apply CrossTalk and DirectExcitation Corrections
NGR = NGR - de_gr.*NRR - ct_gr.*NGG;

%%% Recalculate Efficiency and Stoichiometry
E = NGR./(NGR + gamma_gr.*NGG);
if UserValues.BurstBrowser.Corrections.UseBeta == 1
    S = (NGR + gamma_gr.*NGG)./(NGR + gamma_gr.*NGG + NRR./beta_gr);
elseif UserValues.BurstBrowser.Corrections.UseBeta == 0
    S = (NGR + gamma_gr.*NGG)./(NGR + gamma_gr.*NGG + NRR);
end
%%% Update Values in the DataArray
BurstData.DataArray(:,indE) = E;
BurstData.DataArray(:,indS) = S;
%% Anisotropy Corrections
%%% Read out indices of parameters
ind_rGG = strcmp(BurstData.NameArray,'Anisotropy GG');
ind_rRR = strcmp(BurstData.NameArray,'Anisotropy RR');
indNGGpar = strcmp(BurstData.NameArray,'Number of Photons (GG par)');
indNGGperp = strcmp(BurstData.NameArray,'Number of Photons (GG perp)');
indNRRpar = strcmp(BurstData.NameArray,'Number of Photons (RR par)');
indNRRperp = strcmp(BurstData.NameArray,'Number of Photons (RR perp)');

%%% Read out photons counts and duration
NGGpar = BurstData.DataArray(:,indNGGpar);
NGGperp = BurstData.DataArray(:,indNGGperp);
NRRpar = BurstData.DataArray(:,indNRRpar);
NRRperp = BurstData.DataArray(:,indNRRperp);

%%% Read out corrections
Ggreen = BurstData.Corrections.GfactorGreen;
Gred = BurstData.Corrections.GfactorRed;
l1 = UserValues.BurstBrowser.Corrections.l1;
l2 = UserValues.BurstBrowser.Corrections.l2;
BG_GGpar = BurstData.Background.Background_GGpar;
BG_GGperp = BurstData.Background.Background_GGperp;
BG_RRpar = BurstData.Background.Background_RRpar;
BG_RRperp = BurstData.Background.Background_RRperp;

%%% Apply Background corrections
NGGpar = NGGpar - Dur.*BG_GGpar;
NGGperp = NGGperp - Dur.*BG_GGperp;
NRRpar = NRRpar - Dur.*BG_RRpar;
NRRperp = NRRperp - Dur.*BG_RRperp;

%%% Recalculate Anisotropies
rGG = (Ggreen.*NGGpar - NGGperp)./( (1-3*l2).*Ggreen.*NGGpar + (2-3*l1).*NGGperp);
rRR = (Gred.*NRRpar - NRRperp)./( (1-3*l2).*Gred.*NRRpar + (2-3*l1).*NRRperp);

%%% Update Values in the DataArray
BurstData.DataArray(:,ind_rGG) = rGG;
BurstData.DataArray(:,ind_rRR) = rRR;

%% 3colorMFD
if any(BurstData.BAMethod == [3,4])
    %% FRET Efficiencies and Stoichiometries
    %%% Read out indices of parameters
    indE1A = strcmp(BurstData.NameArray,'Efficiency B->G+R');
    indEBG = strcmp(BurstData.NameArray,'Efficiency BG');
    indEBR = strcmp(BurstData.NameArray,'Efficiency BR');
    indSBG = strcmp(BurstData.NameArray,'Stoichiometry BG');
    indSBR = strcmp(BurstData.NameArray,'Stoichiometry BR');
    indNBB = strcmp(BurstData.NameArray,'Number of Photons (BB)');
    indNBG = strcmp(BurstData.NameArray,'Number of Photons (BG)');
    indNBR= strcmp(BurstData.NameArray,'Number of Photons (BR)');
    
    %%% Read out photons counts and duration
    NBB= BurstData.DataArray(:,indNBB);
    NBG = BurstData.DataArray(:,indNBG);
    NBR = BurstData.DataArray(:,indNBR);
    
    %%% Read out corrections
    gamma_bg = BurstData.Corrections.Gamma_BG;
    beta_bg = BurstData.Corrections.Beta_BG;
    gamma_br = BurstData.Corrections.Gamma_BR;
    beta_br = BurstData.Corrections.Beta_BR;
    ct_bg = BurstData.Corrections.CrossTalk_BG;
    de_bg = BurstData.Corrections.DirectExcitation_BG;
    ct_br = BurstData.Corrections.CrossTalk_BR;
    de_br = BurstData.Corrections.DirectExcitation_BR;
    BG_BB = BurstData.Background.Background_BBpar + BurstData.Background.Background_BBperp;
    BG_BG = BurstData.Background.Background_BGpar + BurstData.Background.Background_BGperp;
    BG_BR = BurstData.Background.Background_BRpar + BurstData.Background.Background_BRperp;
    
    %%% Apply Background corrections
    NBB = NBB - Dur.*BG_BB;
    NBG = NBG - Dur.*BG_BG;
    NBR = NBR - Dur.*BG_BR;
    
    %%% change name of variable E to EGR
    EGR = E;
    %%% Apply CrossTalk and DirectExcitation Corrections
    NBR = NBR - de_br.*NRR - ct_br.*NBB - ct_gr.*(NBG-ct_bg.*NBB) - de_bg*(EGR./(1-EGR)).*NGG;
    NBG = NBG - de_bg.*NGG - ct_bg.*NBB;
    %%% Recalculate Efficiency and Stoichiometry
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
    %%% Update Values in the DataArray
    BurstData.DataArray(:,indE1A) = E1A;
    BurstData.DataArray(:,indEBG) = EBG;
    BurstData.DataArray(:,indEBR) = EBR;
    BurstData.DataArray(:,indSBG) = SBG;
    BurstData.DataArray(:,indSBR) = SBR;
    
    %% Anisotropy Correction of blue channel
    %%% Read out indices of parameters
    ind_rBB = strcmp(BurstData.NameArray,'Anisotropy BB');
    indNBBpar = strcmp(BurstData.NameArray,'Number of Photons (BB par)');
    indNBBperp = strcmp(BurstData.NameArray,'Number of Photons (BB perp)');
    
    %%% Read out photons counts and duration
    NBBpar = BurstData.DataArray(:,indNBBpar);
    NBBperp = BurstData.DataArray(:,indNBBperp);
    
    %%% Read out corrections
    Gblue = BurstData.Corrections.GfactorBlue;
    BG_BBpar = BurstData.Background.Background_BBpar;
    BG_BBperp = BurstData.Background.Background_BBperp;
    
    %%% Apply Background corrections
    NBBpar = NBBpar - Dur.*BG_BBpar;
    NBBperp = NBBperp - Dur.*BG_BBperp;
    
    %%% Recalculate Anisotropies
    rBB = (Gblue.*NBBpar - NBBperp)./( (1-3*l2).*Gblue.*NBBpar + (2-3*l1).*NBBperp);
    
    %%% Update Value in the DataArray
    BurstData.DataArray(:,ind_rBB) = rBB;
end

%%% Update Display
UpdateCuts;
UpdatePlot([],[]);
UpdateLifetimePlots([],[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Manual gamma determination by selecting the mid-points %%%%%%%%%%%%
%%%%%%% of two populations                                     %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineGammaManually(~,~)
global UserValues BurstMeta BurstData
h = guidata(findobj('Tag','BurstBrowser'));
%%% change the plot in axes_gamma to S vs E (instead of default 1/S vs. E)
[H, xbins, ybins] = calc2dhist(BurstMeta.Data.E_raw,BurstMeta.Data.S_raw,[51 51], [0 1], [0 1]);
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
xlabel(h.Corrections.TwoCMFD.axes_gamma,'Efficiency');
ylabel(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry');
title(h.Corrections.TwoCMFD.axes_gamma,'Stoichiometry vs. Efficiency for gamma = 1');
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
BurstData.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;


%%% Save UserValues
LSUserValues(1);
%%% Update Correction Table Data
UpdateCorrections([],[]);
%%% Apply Corrections
ApplyCorrections;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Does Time Window Analysis of selected species %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Time_Window_Analysis(~,~)
global BurstData BurstTCSPCData UserValues
h = guidata(findobj('Tag','BurstBrowser'));
SelectedSpecies = h.SpeciesList.Value;
SelectedSpeciesName = BurstData.SpeciesNames{SelectedSpecies};

%Valid = UpdateCuts(SelectedSpecies);
Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating Histograms...');
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData)
    Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
    if exist([BurstData.FileName(1:end-3) 'bps'],'file') == 2
        %%% load if it exists
        load([BurstData.FileName(1:end-3) 'bps'],'-mat');
    else
        %%% else ask for the file
        [FileName,PathName] = uigetfile({'*.bps'}, 'Choose the associated *.bps file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');
        if FileName == 0
            return;
        end
        load('-mat',fullfile(PathName,FileName));
        %%% Store the correct Path in TauFitBurstData
        BurstData.FileName = fullfile(PathName,[FileName(1:end-3) 'bur']);
    end
    BurstTCSPCData.Macrotime = Macrotime;
    BurstTCSPCData.Microtime = Microtime;
    BurstTCSPCData.Channel = Channel;
    clear Macrotime Microtime Channel
end
Progress(0,h.Progress_Axes,h.Progress_Text,'Calculating Histograms...');
%%% find selected bursts
MT = BurstTCSPCData.Macrotime(BurstData.Selected);
CH = BurstTCSPCData.Channel(BurstData.Selected);

xProx = linspace(0,1,51);
timebin = {10E-3,5E-3,3E-3,2E-3,1E-3,0.5E-3};
for t = 1:numel(timebin)
    %%% 1.) Bin BurstData according to time bin
    
    duration = timebin{t}/BurstData.SyncPeriod;
    %%% Get the maximum number of bins possible in data set
    max_duration = ceil(max(cellfun(@(x) x(end)-x(1),MT))./duration);
    %convert absolute macrotimes to relative macrotimes
    bursts = cellfun(@(x) x-x(1)+1,MT,'UniformOutput',false);
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
    switch BurstData.BAMethod
        case {1,2}
            NGP = cellfun(@(x) sum((x==1)),PDAdata);
            NGS = cellfun(@(x) sum((x==2)),PDAdata);
            NFP = cellfun(@(x) sum((x==3)),PDAdata);
            NFS = cellfun(@(x) sum((x==4)),PDAdata);
        case {3,4}
            NGP = cellfun(@(x) sum((x==7)),PDAdata);
            NGS = cellfun(@(x) sum((x==8)),PDAdata);
            NFP = cellfun(@(x) sum((x==9)),PDAdata);
            NFS = cellfun(@(x) sum((x==10)),PDAdata);
    end

    NG = NGP + NGS;
    NF = NFP + NFS;
    
    Prox = NF./(NG+NF);
    
    Hist{t} = histcounts(Prox,xProx); Hist{t} = Hist{t}./sum(Hist{t});
    Progress(t/numel(timebin),h.Progress_Axes,h.Progress_Text,'Calculating Histograms...');
end


figure;hold on;
a = 3;
for i = 1:numel(timebin)
    x = xProx(1:end-1);
    % slightly modify x-axis for each following dataset, to
    % allow better visualization of the different datasets.
    if i ~= 1
        % i = 1: do nothing
        % i = 2: shift each x value +5% of the x bin size
        % i = 3: shift each x value -5% of the x bin size
        % i = 4: shift each x value +10% of the x bin size
        % i = 5: shift each x value -10% of the x bin size
        % ...
        diffx = mean(diff(x))/20;
        if mod(i,2) == 0 %i = 2, 4, 6...
            x = x + diffx*i/2;
        else %i = 3, 5, 7...
            x = x - diffx*(i-1)/2;
        end
    end
    h = stairs(x,Hist{i});
    set(h, 'Linewidth', a)
    a = a-0.33;
end

for i = 1:numel(timebin)
    leg{i} = [num2str(timebin{i}*1000) ' ms'];
end
legend(leg);

Progress(1,h.Progress_Axes,h.Progress_Text);
h.Progress_Text.String = BurstData.DisplayName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Saves the state of the analysis to the .bur file %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Save_Analysis_State_Callback(~,~)
global BurstData BurstTCSPCData
Progress(0,h.Progress_Axes,h.Progress_Text,'Saving...');
if strcmp(BurstData.FileName(end-2:end),'bur') %bur file, normal save
    save(BurstData.FileName,'BurstData');
elseif strcmp(BurstData.FileName(end-2:end),'kba') % kba file, convert to bur
    save([BurstData.FileName(1:end-4) '_kba.bur'],'BurstData');
    %%% also save BurstTCSPCData
    save([BurstData.FileName(1:end-4) '_kba.bps'],'-struct','BurstTCSPCData');
end
Progress(1,h.Progress_Axes,h.Progress_Text);
h.Progress_Text.String = BurstData.DisplayName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates lifetime-related plots in Lifetime Tab %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateLifetimePlots(~,~)
global BurstData BurstMeta UserValues
h = guidata(findobj('Tag','BurstBrowser'));

if isempty(BurstData)
    return;
end

%%% Use the current cut Data (of the selected species) for plots
datatoplot = BurstData.DataCut;
%%% read out the indices of the parameters to plot
idx_tauGG = strcmp('Lifetime GG [ns]',BurstData.NameArray);
idx_tauRR = strcmp('Lifetime RR [ns]',BurstData.NameArray);
idx_rGG = strcmp('Anisotropy GG',BurstData.NameArray);
idx_rRR = strcmp('Anisotropy RR',BurstData.NameArray);
idxE = BurstMeta.posE;

%% Plot E vs. tauGG in first plot
[H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauGG), datatoplot(:,idxE),[51 51], [0 min([max(datatoplot(:,idx_tauGG)) BurstData.Corrections.DonorLifetime+1.5])], [-0.1 1]);
BurstMeta.Plots.EvsTauGG(1).XData = xbins;
BurstMeta.Plots.EvsTauGG(1).YData = ybins;
BurstMeta.Plots.EvsTauGG(1).CData = H;
if ~UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.EvsTauGG(1).AlphaData = (H>0);
elseif UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.EvsTauGG(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
end
BurstMeta.Plots.EvsTauGG(2).XData = xbins;
BurstMeta.Plots.EvsTauGG(2).YData = ybins;
BurstMeta.Plots.EvsTauGG(2).ZData = H/max(max(H));
BurstMeta.Plots.EvsTauGG(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
axis(h.axes_EvsTauGG,'tight');
ylim(h.axes_EvsTauGG,[-0.1 1]);
if strcmp(BurstMeta.Plots.Fits.staticFRET_EvsTauGG.Visible,'on')
    %%% replot the static FRET line
    UpdateLifetimeFits(h.PlotStaticFRETButton,[]);
end
%% Plot E vs. tauRR in second plot
[H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauRR), datatoplot(:,idxE),[51 51], [0 min([max(datatoplot(:,idx_tauRR)) BurstData.Corrections.AcceptorLifetime+1.5])], [0 1]);
BurstMeta.Plots.EvsTauRR(1).XData = xbins;
BurstMeta.Plots.EvsTauRR(1).YData = ybins;
BurstMeta.Plots.EvsTauRR(1).CData = H;
if ~UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.EvsTauRR(1).AlphaData = (H>0);
elseif UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.EvsTauRR(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
end
BurstMeta.Plots.EvsTauRR(2).XData = xbins;
BurstMeta.Plots.EvsTauRR(2).YData = ybins;
BurstMeta.Plots.EvsTauRR(2).ZData = H/max(max(H));
BurstMeta.Plots.EvsTauRR(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
ylim(h.axes_EvsTauRR,[0 1]);
axis(h.axes_EvsTauRR,'tight');
%% Plot rGG vs. tauGG in third plot
[H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauGG), datatoplot(:,idx_rGG),[51 51], [0 min([max(datatoplot(:,idx_tauGG)) BurstData.Corrections.DonorLifetime+1.5])], [-0.1 0.5]);
BurstMeta.Plots.rGGvsTauGG(1).XData = xbins;
BurstMeta.Plots.rGGvsTauGG(1).YData = ybins;
BurstMeta.Plots.rGGvsTauGG(1).CData = H;
if ~UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.rGGvsTauGG(1).AlphaData = (H>0);
elseif UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.rGGvsTauGG(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
end
BurstMeta.Plots.rGGvsTauGG(2).XData = xbins;
BurstMeta.Plots.rGGvsTauGG(2).YData = ybins;
BurstMeta.Plots.rGGvsTauGG(2).ZData = H/max(max(H));
BurstMeta.Plots.rGGvsTauGG(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
axis(h.axes_rGGvsTauGG,'tight');
%% Plot rRR vs. tauRR in third plot
[H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauRR), datatoplot(:,idx_rRR),[51 51], [0 min([max(datatoplot(:,idx_tauRR)) BurstData.Corrections.AcceptorLifetime+1.5])], [-0.1 0.5]);
BurstMeta.Plots.rRRvsTauRR(1).XData = xbins;
BurstMeta.Plots.rRRvsTauRR(1).YData = ybins;
BurstMeta.Plots.rRRvsTauRR(1).CData = H;
if ~UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.rRRvsTauRR(1).AlphaData = (H>0);
elseif UserValues.BurstBrowser.Display.KDE
    BurstMeta.Plots.rRRvsTauRR(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
end
BurstMeta.Plots.rRRvsTauRR(2).XData = xbins;
BurstMeta.Plots.rRRvsTauRR(2).YData = ybins;
BurstMeta.Plots.rRRvsTauRR(2).ZData = H/max(max(H));
BurstMeta.Plots.rRRvsTauRR(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
axis(h.axes_rRRvsTauRR,'tight');
%% 3cMFD
if any(BurstData.BAMethod == [3,4])
    idx_tauBB = strcmp('Lifetime BB [ns]',BurstData.NameArray);
    idx_rBB = strcmp('Anisotropy BB',BurstData.NameArray);
    idxE1A = strcmp('Efficiency B->G+R',BurstData.NameArray);
    %% Plot E1A vs. tauBB
    valid = (datatoplot(:,idx_tauBB) > 0.01);
    [H, xbins, ybins] = calc2dhist(datatoplot(valid,idx_tauBB), datatoplot(valid,idxE1A),[51 51], [0 min([max(datatoplot(:,idx_tauBB)) BurstData.Corrections.DonorLifetimeBlue+1.5])], [0 1]);
    BurstMeta.Plots.E_BtoGRvsTauBB(1).XData = xbins;
    BurstMeta.Plots.E_BtoGRvsTauBB(1).YData = ybins;
    BurstMeta.Plots.E_BtoGRvsTauBB(1).CData = H;
    if ~UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.E_BtoGRvsTauBB(1).AlphaData = (H>0);
    elseif UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.E_BtoGRvsTauBB(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
    end
    BurstMeta.Plots.E_BtoGRvsTauBB(2).XData = xbins;
    BurstMeta.Plots.E_BtoGRvsTauBB(2).YData = ybins;
    BurstMeta.Plots.E_BtoGRvsTauBB(2).ZData = H/max(max(H));
    BurstMeta.Plots.E_BtoGRvsTauBB(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    axis(h.axes_E_BtoGRvsTauBB,'tight');
    ylim(h.axes_E_BtoGRvsTauBB,[0 1]);
    if strcmp(BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.Visible,'on')
        %%% replot the static FRET line
        UpdateLifetimeFits(h.PlotStaticFRETButton,[]);
    end
    %% Plot rBB vs tauBB
    [H, xbins, ybins] = calc2dhist(datatoplot(valid,idx_tauBB), datatoplot(valid,idx_rBB),[51 51], [0 min([max(datatoplot(:,idx_tauBB)) BurstData.Corrections.DonorLifetimeBlue+1.5])], [-0.1 0.5]);
    BurstMeta.Plots.rBBvsTauBB(1).XData = xbins;
    BurstMeta.Plots.rBBvsTauBB(1).YData = ybins;
    BurstMeta.Plots.rBBvsTauBB(1).CData = H;
    if ~UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rBBvsTauBB(1).AlphaData = (H>0);
    elseif UserValues.BurstBrowser.Display.KDE
        BurstMeta.Plots.rBBvsTauBB(1).AlphaData = (H./max(max(H)) > 0.01);%ones(size(H,1),size(H,2));
    end
    BurstMeta.Plots.rBBvsTauBB(2).XData = xbins;
    BurstMeta.Plots.rBBvsTauBB(2).YData = ybins;
    BurstMeta.Plots.rBBvsTauBB(2).ZData = H/max(max(H));
    BurstMeta.Plots.rBBvsTauBB(2).LevelList = linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    axis(h.axes_rBBvsTauBB,'tight');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Fits/theoretical Curves in Lifetime Tab %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateLifetimeFits(obj,~)
global BurstData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
%%% Use the current cut Data (of the selected species) for plots
datatoplot = BurstData.DataCut;
%%% read out the indices of the parameters to plot
idx_tauGG = strcmp('Lifetime GG [ns]',BurstData.NameArray);
idx_tauRR = strcmp('Lifetime RR [ns]',BurstData.NameArray);
idx_rGG = strcmp('Anisotropy GG',BurstData.NameArray);
idx_rRR = strcmp('Anisotropy RR',BurstData.NameArray);
idxE = strcmp('Efficiency',BurstData.NameArray);
%% Add Fits
if obj == h.PlotStaticFRETButton
    %% Add a static FRET line EvsTau plots
    %%% Calculate static FRET line in presence of linker fluctuations
    tau = linspace(h.axes_EvsTauGG.XLim(1),h.axes_EvsTauGG.XLim(2),100);
    staticFRETline = conversion_tau(BurstData.Corrections.DonorLifetime,...
        BurstData.Corrections.FoersterRadius,BurstData.Corrections.LinkerLength,...
        tau);
    BurstMeta.Plots.Fits.staticFRET_EvsTauGG.Visible = 'on';
    BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData = tau;
    BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData = staticFRETline;
    BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG.Visible = 'off';
    if any(BurstData.BAMethod == [3,4])
        %%% Calculate static FRET line in presence of linker fluctuations
        tau = linspace(h.axes_E_BtoGRvsTauBB.XLim(1),h.axes_E_BtoGRvsTauBB.XLim(2),100);
        staticFRETline = conversion_tau_3C(BurstData.Corrections.DonorLifetimeBlue,...
            BurstData.Corrections.FoersterRadiusBG,BurstData.Corrections.FoersterRadiusBR,...
            BurstData.Corrections.LinkerLengthBG,BurstData.Corrections.LinkerLengthBR,...
            tau);
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.Visible = 'on';
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.XData = tau;
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.YData = staticFRETline;
    end
end
if any(obj == [h.PlotDynamicFRETButton, h.DynamicFRETManual_Menu, h.DynamicFRETRemove_Menu])
    switch obj
        case {h.PlotDynamicFRETButton, h.DynamicFRETManual_Menu}
            if obj == h.PlotDynamicFRETButton
                %%% Query Effiencies using ginput
                [x,~] = ginput(2);
                y = conversion_tau(BurstData.Corrections.DonorLifetime,...
                    BurstData.Corrections.FoersterRadius,BurstData.Corrections.LinkerLength,...
                    x);
            elseif obj == h.DynamicFRETManual_Menu
                %%% Query using edit box
                y = inputdlg({'Efficiency 1','Efficiency 2'},'Enter State Efficiencies',1,{'0.25','0.75'});
                y = cellfun(@str2double,y);
                if any(isnan(y))
                    return;
                end
            end
            tau = linspace(h.axes_EvsTauGG.XLim(1),h.axes_EvsTauGG.XLim(2),10000);
            dynFRETline = dynamicFRETline(BurstData.Corrections.DonorLifetime,...
                y(1),y(2),BurstData.Corrections.FoersterRadius,BurstData.Corrections.LinkerLength,...
                tau);
            BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG.Visible = 'on';
            BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG.XData = tau;
            BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG.YData = dynFRETline;
        case h.DynamicFRETRemove_Menu
            BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG.Visible = 'off';
    end
end
if obj == h.FitAnisotropyButton
    %% Add Perrin Fits to Anisotropy Plot
    %% GG
    fPerrin = @(rho,x) BurstData.Corrections.r0_green./(1+x./rho); %%% x = tau
    tauGG = datatoplot(:,idx_tauGG);
    PerrinFitGG = fit(tauGG(~isnan(tauGG)),datatoplot(~isnan(tauGG),idx_rGG),fPerrin,'StartPoint',1);
    tau = linspace(h.axes_rGGvsTauGG.XLim(1),h.axes_rGGvsTauGG.XLim(2),100);
    BurstMeta.Plots.Fits.PerrinGG(1).Visible = 'on';
    BurstMeta.Plots.Fits.PerrinGG(1).XData = tau;
    BurstMeta.Plots.Fits.PerrinGG(1).YData = PerrinFitGG(tau);
    BurstMeta.Plots.Fits.PerrinGG(2).Visible = 'off';
    BurstMeta.Plots.Fits.PerrinGG(3).Visible = 'off';
    
    BurstData.Parameters.rhoGG = coeffvalues(PerrinFitGG);
    title(h.axes_rGGvsTauGG,['rhoGG = ' num2str(BurstData.Parameters.rhoGG) ' ns']);
    %% RR
    fPerrin = @(rho,x) BurstData.Corrections.r0_red./(1+x./rho); %%% x = tau
    tauRR = datatoplot(:,idx_tauRR);
    PerrinFitRR = fit(tauRR(~isnan(tauRR)),datatoplot(~isnan(tauRR),idx_rRR),fPerrin,'StartPoint',1);
    tau = linspace(h.axes_rRRvsTauRR.XLim(1),h.axes_rRRvsTauRR.XLim(2),100);
    BurstMeta.Plots.Fits.PerrinRR(1).Visible = 'on';
    BurstMeta.Plots.Fits.PerrinRR(1).XData = tau;
    BurstMeta.Plots.Fits.PerrinRR(1).YData = PerrinFitRR(tau);
    BurstMeta.Plots.Fits.PerrinRR(2).Visible = 'off';
    BurstMeta.Plots.Fits.PerrinRR(3).Visible = 'off';
    BurstData.Parameters.rhoRR = coeffvalues(PerrinFitRR);
    title(h.axes_rRRvsTauRR,['rhoRR = ' num2str(BurstData.Parameters.rhoRR) ' ns']);
    if any(BurstData.BAMethod == [3,4])
        %% BB
        idx_tauBB = strcmp('Lifetime BB [ns]',BurstData.NameArray);
        idx_rBB = strcmp('Anisotropy BB',BurstData.NameArray);
        fPerrin = @(rho,x) BurstData.Corrections.r0_blue./(1+x./rho); %%% x = tau
        valid = (datatoplot(:,idx_tauBB) > 0.01) & (datatoplot(:,idx_tauBB) < 5) &...
            (datatoplot(:,idx_rBB) > -1) & (datatoplot(:,idx_rBB) < 2) &...
            (~isnan(datatoplot(:,idx_tauBB)));
        tauBB = datatoplot(valid,idx_tauBB);
        PerrinFitBB = fit(tauBB,datatoplot(valid,idx_rBB),fPerrin,'StartPoint',1);
        tau = linspace(h.axes_rBBvsTauBB.XLim(1),h.axes_rBBvsTauBB.XLim(2),100);
        BurstMeta.Plots.Fits.PerrinBB(1).Visible = 'on';
        BurstMeta.Plots.Fits.PerrinBB(1).XData = tau;
        BurstMeta.Plots.Fits.PerrinBB(1).YData = PerrinFitBB(tau);
        BurstMeta.Plots.Fits.PerrinBB(2).Visible = 'off';
        BurstMeta.Plots.Fits.PerrinBB(3).Visible = 'off';
        BurstData.Parameters.rhoBB = coeffvalues(PerrinFitBB);
        title(h.axes_rBBvsTauBB,['rhoBB = ' num2str(BurstData.Parameters.rhoBB) ' ns']);
    end
end
%% Manual Perrin plots
if obj == h.ManualAnisotropyButton
    [x,y,button] = ginput(1);
    if button == 1 %%% left mouse click, reset plot and plot one perrin line
        if (gca == h.axes_rGGvsTauGG) || (gca == h.axes_rRRvsTauRR) || (gca == h.axes_rBBvsTauBB)
            haxes = gca;
            %%% Determine rho
            switch gca
                case h.axes_rGGvsTauGG
                    r0 = BurstData.Corrections.r0_green;
                case h.axes_rRRvsTauRR
                    r0 = BurstData.Corrections.r0_red;
                case h.axes_rBBvsTauBB
                    r0 = BurstData.Corrections.r0_blue;
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
                    title(['rhoGG = ' num2str(rho) ' ns']);
                case h.axes_rRRvsTauRR
                    BurstMeta.Plots.Fits.PerrinRR(1).Visible = 'on';
                    BurstMeta.Plots.Fits.PerrinRR(1).XData = tau;
                    BurstMeta.Plots.Fits.PerrinRR(1).YData = fitPerrin(tau);
                    BurstMeta.Plots.Fits.PerrinRR(2).Visible = 'off';
                    BurstMeta.Plots.Fits.PerrinRR(3).Visible = 'off';
                    title(['rhoRR = ' num2str(rho) ' ns']);
                case h.axes_rBBvsTauBB
                    BurstMeta.Plots.Fits.PerrinBB(1).Visible = 'on';
                    BurstMeta.Plots.Fits.PerrinBB(1).XData = tau;
                    BurstMeta.Plots.Fits.PerrinBB(1).YData = fitPerrin(tau);
                    BurstMeta.Plots.Fits.PerrinBB(2).Visible = 'off';
                    BurstMeta.Plots.Fits.PerrinBB(3).Visible = 'off';
                    title(['rhoBB = ' num2str(rho) ' ns']);
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
                r0 = BurstData.Corrections.r0_green;
                rho = x/(r0/y - 1);
                fitPerrin = @(x) r0./(1+x./rho);
                tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
                BurstMeta.Plots.Fits.PerrinGG(vis+1).Visible = 'on';
                BurstMeta.Plots.Fits.PerrinGG(vis+1).XData = tau;
                BurstMeta.Plots.Fits.PerrinGG(vis+1).YData = fitPerrin(tau);
                if vis == 0
                    title(haxes,['rhoGG = ' num2str(rho)]);
                else
                    %%% add rho2 to title
                    new_title = [haxes.Title.String ' and ' num2str(rho) ' ns'];
                    title(new_title);
                end
                BurstData.Parameters.rhoGG(vis+1) = rho;
            end
        elseif haxes == h.axes_rRRvsTauRR
            %%% Check for visibility of plots
            vis = 0;
            for i = 1:3
                vis = vis + strcmp(BurstMeta.Plots.Fits.PerrinRR(i).Visible,'on');
            end
            if vis < 3
                %%% Determine rho
                r0 = BurstData.Corrections.r0_red;
                rho = x/(r0/y - 1);
                fitPerrin = @(x) r0./(1+x./rho);
                tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
                BurstMeta.Plots.Fits.PerrinRR(vis+1).Visible = 'on';
                BurstMeta.Plots.Fits.PerrinRR(vis+1).XData = tau;
                BurstMeta.Plots.Fits.PerrinRR(vis+1).YData = fitPerrin(tau);
                if vis == 0
                    title(haxes,['rhoRR = ' num2str(rho)]);
                else
                    %%% add rho2 to title
                    new_title = [haxes.Title.String ' and ' num2str(rho) ' ns'];
                    title(new_title);
                end
                BurstData.Parameters.rhoRR(vis+1) = rho;
            end
        elseif haxes == h.axes_rBBvsTauBB
            %%% Check for visibility of plots
            vis = 0;
            for i = 1:3
                vis = vis + strcmp(BurstMeta.Plots.Fits.PerrinBB(i).Visible,'on');
            end
            if vis < 3
                %%% Determine rho
                r0 = BurstData.Corrections.r0_blue;
                rho = x/(r0/y - 1);
                fitPerrin = @(x) r0./(1+x./rho);
                tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
                BurstMeta.Plots.Fits.PerrinBB(vis+1).Visible = 'on';
                BurstMeta.Plots.Fits.PerrinBB(vis+1).XData = tau;
                BurstMeta.Plots.Fits.PerrinBB(vis+1).YData = fitPerrin(tau);
                if vis == 0
                    title(haxes,['rhoBB = ' num2str(rho)]);
                else
                    %%% add rho2 to title
                    new_title = [haxes.Title.String ' and ' num2str(rho) ' ns'];
                    title(new_title);
                end
                BurstData.Parameters.rhoBB(vis+1) = rho;
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Executes on Tab-Change in Main Window and updates Plots %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MainTabSelectionChange(obj,e)
h = guidata(obj);
if e.NewValue == h.Main_Tab_Lifetime
    if isempty(h.axes_EvsTauGG.Children)
        %%% Update Lifetime Plots
        UpdateLifetimePlots(obj,[]);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Reads out the Donor only lifetime from Donor only bursts %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DonorOnlyLifetimeCallback(obj,~)
global BurstData UserValues BurstMeta
h = guidata(obj);
if obj.Value == 1 %%% Checkbox was clicked on
    LSUserValues(0);
    %%% Determine Donor Only lifetime from data with S > 0.95
    idx_tauGG = strcmp(BurstData.NameArray,'Lifetime GG [ns]');
    idxS = BurstMeta.posS;
    if any(BurstData.BAMethod == [1,2])
        valid = (BurstData.DataArray(:,idxS) > 0.95);
    elseif any(BurstData.BAMethod == [3,4])
        idxSBG = strcmp(BurstData.NameArray,'Stoichiometry BG');
        valid = (BurstData.DataArray(:,idxS) > 0.90) & (BurstData.DataArray(:,idxS) < 1.1) &...
            (BurstData.DataArray(:,idxSBG) > 0) & (BurstData.DataArray(:,idxSBG) < 0.1);
    end
    x_axis = 0:0.05:10;
    htauGG = histc(BurstData.DataArray(valid,idx_tauGG),x_axis);
    [DonorOnlyLifetime, ~] = GaussianFit(x_axis',htauGG,1);
    %%% Update GUI
    h.DonorLifetimeEdit.String = num2str(DonorOnlyLifetime);
    h.DonorLifetimeEdit.Enable = 'off';
    UserValues.BurstBrowser.Corrections.DonorLifetime = DonorOnlyLifetime;
    BurstData.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
    %%% Determine Acceptor Only Lifetime from data with S < 0.1
    idx_tauRR = strcmp(BurstData.NameArray,'Lifetime RR [ns]');
    idxS = BurstMeta.posS;
    if any(BurstData.BAMethod == [1,2])
        valid = (BurstData.DataArray(:,idxS) < 0.1);
    elseif any(BurstData.BAMethod == [3,4])
        idxSBR = strcmp(BurstData.NameArray,'Stoichiometry BR');
        valid = (BurstData.DataArray(:,idxS) < 0.1) & (BurstData.DataArray(:,idxS) > -0.1) &...
            (BurstData.DataArray(:,idxSBR) < 0.1) & (BurstData.DataArray(:,idxSBR) > -0.1);
    end
    x_axis = 0:0.05:10;
    htauRR = histc(BurstData.DataArray(valid,idx_tauRR),x_axis);
    [AcceptorOnlyLifetime, ~] = GaussianFit(x_axis',htauRR,1);
    %%% Update GUI
    h.AcceptorLifetimeEdit.String = num2str(AcceptorOnlyLifetime);
    h.AcceptorLifetimeEdit.Enable = 'off';
    UserValues.BurstBrowser.Corrections.AcceptorLifetime = AcceptorOnlyLifetime;
    BurstData.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
    if any(BurstData.BAMethod == [3,4])
        %%% Determine Donor Blue Lifetime from Blue dye only species
        idx_tauBB = strcmp(BurstData.NameArray,'Lifetime BB [ns]');
        idxSBG = strcmp(BurstData.NameArray,'Stoichiometry BG');
        idxSBR = strcmp(BurstData.NameArray,'Stoichiometry BR');
        
        valid = ( (BurstData.DataArray(:,idxSBG) > 0.98) &...
            (BurstData.DataArray(:,idxSBR) > 0.98) );
        x_axis = 0:0.05:10;
        htauBB = histc(BurstData.DataArray(valid,idx_tauBB),x_axis);
        [DonorBlueLifetime, ~] = GaussianFit(x_axis',htauBB,1);
        %DonorBlueLifetime = mean(BurstData.DataArray(valid,idx_tauBB));
        h.DonorLifetimeBlueEdit.String = num2str(DonorBlueLifetime);
        h.DonorLifetimeBlueEdit.Enable = 'off';
        UserValues.BurstBrowser.Corrections.DonorLifetimeBlue = DonorBlueLifetime;
        BurstData.Corrections.DonorLifetimeBlue = UserValues.BurstBrowser.Corrections.DonorLifetimeBlue;
    end
    LSUserValues(1);
    UpdateLifetimePlots([],[]);
else
    h.DonorLifetimeEdit.Enable = 'on';
    h.DonorLifetimeBlueEdit.Enable = 'on';
    h.AcceptorLifetimeEdit.Enable = 'on';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates static FRET line with Linker Dynamics %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, func] = conversion_tau(tauD,R0,s,xval)
% s = 6;
res = 1000;
%range of RDA center values, i.e. 100 values in 0.1*R0 to 10*R0
R = linspace(0*R0,5*R0,res);

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
out = 1-interp1(tauf,taux,xval)./tauD;
if nargout > 1
    func = @(x) 1-interp1(tauf,taux,x)./tauD;
end
function [out, func] = conversion_tau_3C(tauD,R0BG,R0BR,sBG,sBR,xval)
res = 100;
%range of RDA center values, i.e. 100 values in 0.1*R0 to 10*R0
RBG = linspace(0*R0BG,4*R0BG,res);
RBR = linspace(0*R0BR,4*R0BR,res);
%for every R calculate gaussian distribution
p = zeros(res,res,res);
rBG = zeros(res,res,res);
rBR = zeros(res,res,res);
for j = 1:res
    [xRBG, xRBR] = meshgrid(linspace(RBG(j)-4*sBG,RBG(j)+4*sBG,res),linspace(RBR(j)-4*sBR,RBR(j)+4*sBR,res));
    dummy = exp(-( ((xRBG-RBG(j)).^2)./(2*sBG^2) + ((xRBR-RBR(j)).^2)./(2*sBR^2) ));
    dummy(xRBG < 0) = 0;
    dummy(xRBR < 0) = 0;
    dummy = dummy./sum(sum(dummy));
    p(:,:,j) = dummy;
    rBG(:,:,j) = xRBG;
    rBR(:,:,j) = xRBR;
end

%calculate lifetime distribution
tau = zeros(res,res,res);
for j = 1:res
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
taux = zeros(1,res);
for j = 1:res
    taux(j) = sum(sum(p(:,:,j).*tau(:,:,j)));
end

%calculate intensity weighted tauf
tauf = zeros(1,res);
for j = 1:res
    tauf(j) = sum(sum(p(:,:,j).*(tau(:,:,j).^2)))./taux(j);
end

%coefficients = polyfit(tauf,taux,3);
%out = 1- ( coefficients(1).*xval.^3 + coefficients(2).*xval.^2 + coefficients(3).*xval + coefficients(4) )./tauD;

out = 1-interp1(tauf,taux,xval)./tauD;
if nargout > 1
    func = @(x) 1-interp1(tauf,taux,x)./tauD;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates dynamic FRET line between two states  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, func] = dynamicFRETline(tauD,E1,E2,R0,s,xval)
res = 1000;
%%% Calculate two distance distribution for two states
%RDA1 = R0*((tauD/tau1)-1)^(-1/6);
%RDA2 = R0*((tauD/tau2)-1)^(-1/6);
RDA1 = R0.*(1/E1-1)^(1/6);
RDA2 = R0.*(1/E2-1)^(1/6);
r = linspace(0*R0,5*R0,res);
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
%%%%%%% Calculates the Gamma Factor using the lifetime information %%%%%%%%
%%%%%%% by minimizing the deviation from the static FRET line      %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineGammaLifetime(obj,~)
global BurstData UserValues BurstMeta
h = guidata(obj);
LSUserValues(0);
%%% Change focus to CorrectionsTab
%h.Main_Tab.SelectedTab = h.Main_Tab_Corrections;
%% 2cMFD
%%% Prepare photon counts
indS = BurstMeta.posS;
indDur = (strcmp(BurstData.NameArray,'Duration [ms]'));
indNGG = (strcmp(BurstData.NameArray,'Number of Photons (GG)'));
indNGR = (strcmp(BurstData.NameArray,'Number of Photons (GR)'));
indNRR = (strcmp(BurstData.NameArray,'Number of Photons (RR)'));
indTauGG = (strcmp(BurstData.NameArray,'Lifetime GG [ns]'));
T_threshold = str2double(h.T_Threshold_Edit.String);
if isnan(T_threshold)
    T_threshold = 0.1;
end
cutT = 1;
if cutT == 0
    data_for_corrections = BurstData.DataArray;
elseif cutT == 1
    T = strcmp(BurstData.NameArray,'|TGX-TRR| Filter');
    valid = (BurstData.DataArray(:,T) < T_threshold);
    data_for_corrections = BurstData.DataArray(valid,:);
end

%%% Read out corrections
Background_GR = BurstData.Background.Background_GRpar + BurstData.Background.Background_GRperp;
Background_GG = BurstData.Background.Background_GGpar + BurstData.Background.Background_GGperp;
Background_RR = BurstData.Background.Background_RRpar + BurstData.Background.Background_RRperp;

%%% get E-S values between 0.3 and 0.8;
S_threshold = ( (data_for_corrections(:,indS) > 0.3) & (data_for_corrections(:,indS) < 0.9) );
if any(BurstData.BAMethod == [3,4])
    %%% also cut SBG! (otherwise there is contamination by blue only)
    indSBG = (strcmp(BurstData.NameArray,'Stoichiometry BG'));
    S_threshold = S_threshold & (data_for_corrections(:,indSBG) < 0.8);
end
%%% Calculate "raw" E and S with gamma = 1, but still apply direct
%%% excitation,crosstalk, and background corrections!
NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
NGR = NGR - BurstData.Corrections.DirectExcitation_GR.*NRR - BurstData.Corrections.CrossTalk_GR.*NGG;

if obj == h.DetermineGammaLifetimeTwoColorButton
    %%% Calculate static FRET line in presence of linker fluctuations
    tau = linspace(0,5,100);
    [~, statFRETfun] = conversion_tau(BurstData.Corrections.DonorLifetime,...
        BurstData.Corrections.FoersterRadius,BurstData.Corrections.LinkerLength,...
        tau);
    %staticFRETline = @(x) 1 - (coeff(1).*x.^3 + coeff(2).*x.^2 + coeff(3).*x + coeff(4))./BurstData.Corrections.DonorLifetime;
    %%% minimize deviation from static FRET line as a function of gamma
    tauGG = data_for_corrections(S_threshold,indTauGG);
    valid = (tauGG < BurstData.Corrections.DonorLifetime) & (tauGG > 0.01) & ~isnan(tauGG);
    dev = @(gamma) sum( ( ( NGR(valid)./(gamma.*NGG(valid)+NGR(valid)) ) - statFRETfun( tauGG(valid) ) ).^2 );
    gamma_fit = fmincon(dev,1,[],[],[],[],0,10);
    E =  NGR./(gamma_fit.*NGG+NGR);
    %%% plot E versus tau with static FRET line
    [H,xbins,ybins] = calc2dhist(data_for_corrections(S_threshold,indTauGG),E,[51 51],[0 min([max(tauGG) BurstData.Corrections.DonorLifetime+1.5])],[-0.1 1]);
    BurstMeta.Plots.gamma_lifetime(1).XData= xbins;
    BurstMeta.Plots.gamma_lifetime(1).YData= ybins;
    BurstMeta.Plots.gamma_lifetime(1).CData= H;
    BurstMeta.Plots.gamma_lifetime(1).AlphaData= (H>0);
    BurstMeta.Plots.gamma_lifetime(2).XData= xbins;
    BurstMeta.Plots.gamma_lifetime(2).YData= ybins;
    BurstMeta.Plots.gamma_lifetime(2).ZData= H/max(max(H));
    BurstMeta.Plots.gamma_lifetime(2).LevelList= linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
    %%% add static FRET line
    tau = linspace(h.Corrections.TwoCMFD.axes_gamma_lifetime.XLim(1),h.Corrections.TwoCMFD.axes_gamma_lifetime.XLim(2),100);
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.Visible = 'on';
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.XData = tau;
    FRETline = statFRETfun(tau);
    FRETline(find(FRETline < 0,1,'first')+10:end) = NaN;
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.YData = FRETline;
    ylim(h.Corrections.TwoCMFD.axes_gamma_lifetime,[-0.1,1]);
    %%% Update UserValues
    UserValues.BurstBrowser.Corrections.Gamma_GR =gamma_fit;
    BurstData.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
end
%% 3cMFD - Fit E1A vs. TauBlue
if obj == h.DetermineGammaLifetimeThreeColorButton
    if any(BurstData.BAMethod == [3,4])
        %%% Prepare photon counts
        indNBB = (strcmp(BurstData.NameArray,'Number of Photons (BB)'));
        indNBG = (strcmp(BurstData.NameArray,'Number of Photons (BG)'));
        indNBR = (strcmp(BurstData.NameArray,'Number of Photons (BR)'));
        indTauBB = (strcmp(BurstData.NameArray,'Lifetime BB [ns]'));
        indSBG = (strcmp(BurstData.NameArray,'Stoichiometry BG'));
        indSBR = (strcmp(BurstData.NameArray,'Stoichiometry BR'));
        
        T_threshold = str2double(h.T_Threshold_Edit.String);
        if isnan(T_threshold)
            T_threshold = 0.1;
        end
        cutT = 1;
        %%% define T-threshold
        if cutT == 0
            data_for_corrections = BurstData.DataArray;
        elseif cutT == 1
            T1 = strcmp(BurstData.NameArray,'|TGX-TRR| Filter');
            T2 = strcmp(BurstData.NameArray,'|TBX-TRR| Filter');
            T3 = strcmp(BurstData.NameArray,'|TBX-TGX| Filter');
            valid = (BurstData.DataArray(:,T1) < T_threshold) &...
                (BurstData.DataArray(:,T2) < T_threshold) &...
                (BurstData.DataArray(:,T3) < T_threshold);
            data_for_corrections = BurstData.DataArray(valid,:);
        end
        
        %%% Read out corrections
        Background_BB = BurstData.Background.Background_BBpar + BurstData.Background.Background_BBperp;
        Background_BG = BurstData.Background.Background_BGpar + BurstData.Background.Background_BGperp;
        Background_BR = BurstData.Background.Background_BRpar + BurstData.Background.Background_BRperp;
        
        %%% get E-S values between 0.1 and 0.9;
        S_threshold = ( (data_for_corrections(:,indS) > 0.1) & (data_for_corrections(:,indS) < 0.9) &...
            (data_for_corrections(:,indSBG) > 0.1) & (data_for_corrections(:,indSBG) < 0.9) &...
            (data_for_corrections(:,indSBR) > 0.1) & (data_for_corrections(:,indSBR) < 0.9) );
        %%% also use Lifetime Threshold
        S_threshold = S_threshold & (data_for_corrections(:,indTauBB) > 0.1);
        %%% Calculate "raw" E1A and with gamma_br = 1, but still apply direct
        %%% excitation,crosstalk, and background corrections!
        NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
        NBG = data_for_corrections(S_threshold,indNBG) - Background_BG.*data_for_corrections(S_threshold,indDur);
        NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
        NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
        NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
        NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
        NGR = NGR - BurstData.Corrections.DirectExcitation_GR.*NRR - BurstData.Corrections.CrossTalk_GR.*NGG;
        gamma_gr = BurstData.Corrections.Gamma_GR;
        EGR = NGR./(gamma_gr.*NGG+NGR);
        NBR = NBR - BurstData.Corrections.DirectExcitation_BR.*NRR - BurstData.Corrections.CrossTalk_BR.*NBB -...
            BurstData.Corrections.CrossTalk_GR.*(NBG-BurstData.Corrections.CrossTalk_BG.*NBB) -...
            BurstData.Corrections.DirectExcitation_BG*(EGR./(1-EGR)).*NGG;
        NBG = NBG - BurstData.Corrections.DirectExcitation_BG.*NGG - BurstData.Corrections.CrossTalk_BG.*NBB;
        %%% Calculate static FRET line in presence of linker fluctuations
        tau = linspace(0,5,100);
        [~, statFRETfun] = conversion_tau_3C(BurstData.Corrections.DonorLifetimeBlue,...
            BurstData.Corrections.FoersterRadiusBG,BurstData.Corrections.FoersterRadiusBR,...
            BurstData.Corrections.LinkerLengthBG,BurstData.Corrections.LinkerLengthBR,...
            tau);
        %staticFRETline = @(x) 1 - (coeff(1).*x.^3 + coeff(2).*x.^2 + coeff(3).*x + coeff(4))./BurstData.Corrections.DonorLifetimeBlue;
        tauBB = data_for_corrections(S_threshold,indTauBB);
        valid = (tauBB < BurstData.Corrections.DonorLifetimeBlue) & (tauBB > 0.01) & ~isnan(tauBB);
        %%% minimize deviation from static FRET line as a function of gamma_br!
        dev = @(gamma) sum( ( ( (gamma_gr.*NBG(valid)+NBR(valid))./(gamma.*NBB(valid) + gamma_gr.*NBG(valid) + NBR(valid)) ) - statFRETfun( tauBB(valid) ) ).^2 );
        gamma_fit = fmincon(dev,1,[],[],[],[],0,10);
        E1A =  (gamma_gr.*NBG+NBR)./(gamma_fit.*NBB + gamma_gr.*NBG + NBR);
        %%% plot E versus tau with static FRET line
        [H,xbins,ybins] = calc2dhist(data_for_corrections(S_threshold,indTauBB),E1A,[51 51],[0 min([max(tauBB) BurstData.Corrections.DonorLifetimeBlue+1.5])],[-0.1 1]);
        BurstMeta.Plots.gamma_threecolor_lifetime(1).XData= xbins;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).YData= ybins;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).CData= H;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).AlphaData= (H>0);
        BurstMeta.Plots.gamma_threecolor_lifetime(2).XData= xbins;
        BurstMeta.Plots.gamma_threecolor_lifetime(2).YData= ybins;
        BurstMeta.Plots.gamma_threecolor_lifetime(2).ZData= H/max(max(H));
        BurstMeta.Plots.gamma_threecolor_lifetime(2).LevelList= linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels);
        %%% add static FRET line
        tau = linspace(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime.XLim(1),h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime.XLim(2),100);
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.Visible = 'on';
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.XData = tau;
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.YData = statFRETfun(tau);
        ylim(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,[-0.1,1]);
        %%% Update UserValues
        UserValues.BurstBrowser.Corrections.Gamma_BR =gamma_fit;
        UserValues.BurstBrowser.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BR./UserValues.BurstBrowser.Corrections.Gamma_GR;
        BurstData.Corrections.Gamma_BR = UserValues.BurstBrowser.Corrections.Gamma_BR;
        BurstData.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BG;
    end
end
%%% Save UserValues
LSUserValues(1);
%%% Update Correction Table Data
UpdateCorrections([],[]);
%%% Apply Corrections
ApplyCorrections(obj,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Normal Correlation of Burst Photon Streams %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Correlate_Bursts(obj,~)
global BurstData BurstTCSPCData PhotonStream UserValues
h = guidata(obj);
%%% Set Up Progress Bar
Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');

%%% Read out the species name
if (BurstData.SelectedSpecies == 1)
    species = 'global';
else
    species = BurstData.SpeciesNames{BurstData.SelectedSpecies};
end
%%% define channels
switch BurstData.BAMethod
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
        if isempty(BurstTCSPCData)
            Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
            if exist([BurstData.FileName(1:end-3) 'bps'],'file') == 2
                %%% load if it exists
                load([BurstData.FileName(1:end-3) 'bps'],'-mat');
            else
                %%% else ask for the file
                [FileName,PathName] = uigetfile({'*.bps'}, 'Choose the associated *.bps file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');
                if FileName == 0
                    return;
                end
                load('-mat',fullfile(PathName,FileName));
                %%% Store the correct Path in TauFitBurstData
                BurstData.FileName = fullfile(PathName,[FileName(1:end-3) 'bur']);
            end
            BurstTCSPCData.Macrotime = Macrotime;
            BurstTCSPCData.Microtime = Microtime;
            BurstTCSPCData.Channel = Channel;
            clear Macrotime Microtime Channel
            Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
        end
        %%% find selected bursts
        MT = BurstTCSPCData.Macrotime(BurstData.Selected);
        %MT = vertcat(MT{:});
        CH = BurstTCSPCData.Channel(BurstData.Selected);
        %CH = vertcat(CH{:});
        
        for k = 1:numel(MT)
            MT{k} = MT{k}-MT{k}(1) +1;
        end
        %        waitbar(0,h_waitbar,'Correlating...');
        %        count = 0;
        %         for i=1:NumChans
        %             for j=1:NumChans
        %                 if CorrMat(i,j)
        %                     MT1 = MT(ismember(CH,Chan{i}));
        %                     MT2 = MT(ismember(CH,Chan{j}));
        %                     %%% Split Data in 10 time bins for errorbar calculation
        %                     Times = ceil(linspace(0,max([MT1;MT2]),11));
        %                     %%% Calculates the maximum inter-photon time in clock ticks
        %                     Maxtime=max(diff(Times))/UserValues.Settings.Pam.Cor_Divider;
        %                     Data1 = cell(10,1);
        %                     Data2 = cell(10,1);
        %                     for k = 1:10
        %                         Data1{k} = MT1( MT1 > Times(k) &...
        %                             MT1 <= Times(k+1)) - Times(k);
        %                         Data2{k} = MT2( MT2 > Times(k) &...
        %                             MT2 <= Times(k+1)) - Times(k);
        %                         Data1{k} = Data1{k}/UserValues.Settings.Pam.Cor_Divider;
        %                         Data2{k} = Data2{k}/UserValues.Settings.Pam.Cor_Divider;
        %                     end
        %                     %%% Do Correlation
        %                     [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data2,Maxtime);
        %                     Cor_Times = Cor_Times*BurstData.SyncPeriod*UserValues.Settings.Pam.Cor_Divider;
        %                     %%% Calculates average and standard error of mean (without tinv_table yet
        %                     if numel(Cor_Array)>1
        %                         Cor_Average=mean(Cor_Array,2);
        %                         %Cor_SEM=std(Cor_Array,0,2)/sqrt(size(Cor_Array,2));
        %                         %%% Averages files before saving to reduce errorbars
        %                         Amplitude=sum(Cor_Array,1);
        %                         Cor_Norm=Cor_Array./repmat(Amplitude,[size(Cor_Array,1),1])*mean(Amplitude);
        %                         Cor_SEM=std(Cor_Norm,0,2)/sqrt(size(Cor_Array,2));
        %
        %                     else
        %                         Cor_Average=Cor_Array{1};
        %                         Cor_SEM=Cor_Array{1};
        %                     end
        %                     %%% Save the correlation file
        %                     %%% Generates filename
        %                     Current_FileName=[BurstData.FileName(1:end-4) '_' species '_' Name{i} '_x_' Name{j} '.mcor'];
        %                     %%% Checks, if file already exists
        %                     if  exist(Current_FileName,'file')
        %                         k=1;
        %                         %%% Adds 1 to filename
        %                         Current_FileName=[Current_FileName(1:end-5) '_' num2str(k) '.mcor'];
        %                         %%% Increases counter, until no file is found
        %                         while exist(Current_FileName,'file')
        %                             k=k+1;
        %                             Current_FileName=[Current_FileName(1:end-(5+numel(num2str(k-1)))) num2str(k) '.mcor'];
        %                         end
        %                     end
        %
        %                     Header = ['Correlation file for: ' strrep(fullfile(BurstData.FileName),'\','\\') ' of Channels ' Name{i} ' cross ' Name{j}];
        %                     Counts = [numel(MT1) numel(MT2)]/(BurstData.SyncPeriod*max([MT1;MT2]))/1000;
        %                     Valid = 1:10;
        %                     save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
        %                     count = count+1;waitbar(count/NCor);
        %                 end
        %             end
        %         end
        
    case h.CorrelateWindow_Button
        if isempty(PhotonStream)
            return;
        end
        
        start = PhotonStream.start(BurstData.Selected);
        stop = PhotonStream.stop(BurstData.Selected);
        
        use_time = 1; %%% use time or photon window
        if use_time
            %%% histogram the Macrotimes in bins of 10 ms
            bw = ceil(10E-3./BurstData.SyncPeriod);
            bins_time = bw.*(0:1:ceil(PhotonStream.Macrotime(end)./bw));
            if ~isfield(PhotonStream,'MT_bin')
                Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Data...');
                [~, PhotonStream.MT_bin] = histc(PhotonStream.Macrotime,bins_time);
                [PhotonStream.unique,PhotonStream.first_idx,~] = unique(PhotonStream.MT_bin);
                used_tw = zeros(numel(bins_time),1);
                used_tw(PhotonStream.unique) = PhotonStream.first_idx;
                while sum(used_tw == 0) > 0
                    used_tw(used_tw == 0) = used_tw(find(used_tw == 0)-1);
                end
                PhotonStream.first_idx = used_tw;
            end
            [~, start_bin] = histc(PhotonStream.Macrotime(start),bins_time);
            [~, stop_bin] = histc(PhotonStream.Macrotime(stop),bins_time);
            [~, start_all_bin] = histc(PhotonStream.Macrotime(PhotonStream.start),bins_time);
            [~, stop_all_bin] = histc(PhotonStream.Macrotime(PhotonStream.stop),bins_time);
            
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
                inval = val & (~BurstData.Selected);
                %%% if there are bursts of another species in the timewindow,
                %%% --> remove it
                if sum(inval) > 0
                    use(i) = 0;
                end
                Progress(i/numel(start),h.Progress_Axes,h.Progress_Text,'Including Time Window...');
            end
            
            %%% Construct reduced Macrotime and Channel vector
            Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
            MT = cell(sum(use),1);
            CH = cell(sum(use),1);
            k=1;
            for i = 1:numel(start_tw)
                if use(i)
                    range = PhotonStream.first_idx(start_tw(i)):(PhotonStream.first_idx(stop_tw(i)+1)-1);
                    MT{k} = PhotonStream.Macrotime(range);
                    MT{k} = MT{k}-MT{k}(1) +1;
                    CH{k} = PhotonStream.Channel(range);
                    %val = (PhotonStream.MT_bin > start_tw(i)) & (PhotonStream.MT_bin < stop_tw(i) );
                    %MT{k} = PhotonStream.Macrotime(val);
                    %MT{k} = MT{k}-MT{k}(1) +1;
                    %CH{k} = PhotonStream.Channel(val);
                    k = k+1;
                end
                Progress(i/numel(start_tw),h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
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
                val = (PhotonStream.start < stop_tw(i)) & (PhotonStream.stop > start_tw(i));
                %%% Check if they are of the same species
                inval = val & (~BurstData.Selected);
                %%% if there are bursts of another species in the timewindow,
                %%% --> remove it
                if sum(inval) > 0
                    use(i) = 0;
                end
                Progress(i/numel(start),h.Progress_Axes,h.Progress_Text,'Including Time Window...');
            end
            
            %%% Construct reduced Macrotime and Channel vector
            Progress(0,h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
            MT = cell(sum(use),1);
            CH = cell(sum(use),1);
            k=1;
            for i = 1:numel(start_tw)
                if use(i)
                    MT{k} = PhotonStream.Macrotime(start_tw(i):stop_tw(i));MT{k} = MT{k}-MT{k}(1) +1;
                    CH{k} = PhotonStream.Channel(start_tw(i):stop_tw(i));
                    k = k+1;
                end
                Progress(i/numel(start_tw),h.Progress_Axes,h.Progress_Text,'Preparing Photon Stream...');
            end
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
            %%% Calculates the maximum inter-photon time in clock ticks
            Maxtime=cellfun(@(x,y) max([x(end) y(end)]),MT1,MT2);
            %%% Do Correlation
            [Cor_Array,Cor_Times]=CrossCorrBurst(MT1,MT2,Maxtime);
            Cor_Times = Cor_Times*BurstData.SyncPeriod;
            
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
            Current_FileName=[BurstData.FileName(1:end-4) '_' species '_' Name{i} '_x_' Name{j} '.mcor'];
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
            
            Header = ['Correlation file for: ' strrep(fullfile(BurstData.FileName),'\','\\') ' of Channels ' Name{i} ' cross ' Name{j}];
            %Counts = [numel(MT1) numel(MT2)]/(BurstData.SyncPeriod*max([MT1;MT2]))/1000;
            Counts = [0 ,0];
            Valid = 1:size(Cor_Array,2);
            save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
            count = count+1;
            Progress(count/NCor,h.Progress_Axes,h.Progress_Text,'Correlating...');
        end
    end
end

%%% Update FCSFit Path
UserValues.File.FCSPath = UserValues.File.BurstBrowserPath;
LSUserValues(1);

Progress(1,h.Progress_Axes,h.Progress_Text);
h.Progress_Text.String = BurstData.DisplayName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Load Photon Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Photons(obj,~)
global PhotonStream BurstData UserValues
h = guidata(obj);
%%% Set Up Progress Bar
switch obj
    case h.LoadAllPhotons_Button
        %%% Load associated .bps file, containing Macrotime, Microtime and Channel
        if isempty(PhotonStream)
            Progress(0,h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
            if exist([BurstData.FileName(1:end-3) 'bps'],'file') == 2
                %%% load if it exists
                load([BurstData.FileName(1:end-3) 'aps'],'-mat');
            else
                %%% else ask for the file
                [FileName,PathName] = uigetfile({'*.aps'}, 'Choose the associated *.aps file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');
                if FileName == 0
                    return;
                end
                load('-mat',fullfile(PathName,FileName));

            end
        end
        %%% Enable CorrelateWindow Button
        h.CorrelateWindow_Button.Enable = 'on';
        h.CorrelateWindow_Edit.Enable = 'on';
end
Progress(1,h.Progress_Axes,h.Progress_Text);
h.Progress_Text.String = BurstData.DisplayName;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Change GUI to 2cMFD or 3cMFD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SwitchGUI(BAMethod)
h = guidata(findobj('Tag','BurstBrowser'));
%%% convert BAMethod to 2 (2colorMFD) or 3 (3cMFD)
if any(BAMethod == [1,2])
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
if PreviousBAMethod == BAMethod
    return;
end

%%% unhide panel if change is TO 3cMFD
if BAMethod == 3
    %% Change Tabs

    %%% move the three-color Corrections Tab to Main Panel
    h.Main_Tab_Corrections_ThreeCMFD.Parent = h.Main_Tab;
    %%% Then add again the other tabs in correct order
    h.Main_Tab_Lifetime.Parent = h.Main_Tab;
    h.Main_Tab_fFCS.Parent = h.Main_Tab;
    
    h.ExportSpeciesToPDA_2C_for3CMFD_MenuItem.Visible = 'on';
    %% Change correction table
    Corrections_Rownames = {'Gamma GR','Gamma BG','Gamma BR','Beta GR','Beta BG','Beta BR',...
        'Crosstalk GR','Crosstalk BG','Crosstalk BR','Direct Exc. GR','Direct Exc. BG','Direct Exc. BR',...
        'G factor blue','G factor Green','G factor Red','l1','l2',...
        'BG BB par','BG BB perp','BG BG par','BG BG perp','BG BR par','BG BR perp',...
        'BG GG par','BG GG perp','BG GR par','BG GR perp','BG RR par','BG RR perp'};
    Corrections_Data = {1;1;1;1;1;1;...
        0;0;0;0;0;0;...
        0;0;0;0;0;0;...
        0;0;0;0;0;0;...
        1;1;1;0;0};
    %% Change Corrections GUI
    h.DetermineGammaLifetimeThreeColorButton.Visible = 'on';
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
    h.r0Blue_edit.Visible = 'on';
    h.r0Blue_text.Visible = 'on';
    %% Change Lifetime GUI
    %%% Make 3C-Plots visible
    h.axes_E_BtoGRvsTauBB.Parent = h.MainTabLifetimePanel;
    h.axes_rBBvsTauBB.Parent = h.MainTabLifetimePanel;
    %%% Change Position of 2Color-Plots
    h.axes_EvsTauGG.Position = [0.05 0.55 (0.8/3) 0.4];
    h.axes_EvsTauRR.Position = [(0.1+0.8/3) 0.55 (0.8/3) 0.4];
    h.axes_rGGvsTauGG.Position = [0.05 0.05 (0.8/3) 0.4];
    h.axes_rRRvsTauRR.Position = [(0.1+0.8/3) 0.05 (0.8/3) 0.4];
    %% Change Lifetime Fit GUI
    h.TauFit.ChannelSelect.String = {'BB','GG','RR'};
    h.TauFit.ChannelSelect.Value = 1;
    %% Change Correlation Table
    Names = {'BB1','BB2','BG1','BG2','BR1','BR2','GG1','GG2','GR1','GR2','RR1','RR2','BX1','BX2','GX1','GX2','BB','BG','BR','GG','GR','RR','BX','GX'};
    h.Correlation_Table.RowName = Names;
    h.Correlation_Table.ColumnName = Names;
    h.Correlation_Table.Data = logical(zeros(numel(Names)));
elseif BAMethod == 2
    %%% move the three-color Corrections Tab to the Hide_Tab
    h.Main_Tab_Corrections_ThreeCMFD.Parent = h.Hide_Tab;
    %%% reset Corrections Table
    Corrections_Rownames = {'Gamma','Beta','Crosstalk','Direct Exc.',...
        'G factor Green','G factor Red','l1','l2',...
        'BG GG par','BG GG perp','BG GR par','BG GR perp','BG RR par','BG RR perp'};
    Corrections_Data = {1;1;0;0;0;0;0:0;0;0;1;1;0};
    %%% Hide 3cMFD corrections
    h.ExportSpeciesToPDA_2C_for3CMFD_MenuItem.Visible = 'off';
    h.DetermineGammaLifetimeThreeColorButton.Visible = 'off';
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
    h.r0Blue_edit.Visible = 'off';
    h.r0Blue_text.Visible = 'off';
    %%% Reset Lifetime Plots
    %%% Make 3C-Plots invisible
    h.axes_E_BtoGRvsTauBB.Parent = h.Hide_Stuff;
    h.axes_rBBvsTauBB.Parent =  h.Hide_Stuff;
    %%% Change Position of 2Color-Plots
    h.axes_EvsTauGG.Position = [0.05 0.55 0.4 0.4];
    h.axes_EvsTauRR.Position = [0.55 0.55 0.4 0.4];
    h.axes_rGGvsTauGG.Position = [0.05 0.05 0.4 0.4];
    h.axes_rRRvsTauRR.Position = [0.55 0.05 0.4 0.4];
    %% Change Lifetime Fit GUI
    h.TauFit.ChannelSelect.String = {'GG','RR'};
    h.TauFit.ChannelSelect.Value = 1;
    %% Change Correlation Table
    Names = {'GG1','GG2','GR1','GR2','RR1','RR2','GG','GR','GX','GX1','GX2','RR'};
    h.Correlation_Table.RowName = Names;
    h.Correlation_Table.ColumnName = Names;
    h.Correlation_Table.Data = logical(zeros(numel(Names)));
end
h.CorrectionsTable.RowName = Corrections_Rownames;
h.CorrectionsTable.Data = Corrections_Data;
%%% Update CorrectionsTable with UserValues-stored Data
UpdateCorrections([],[])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export Graphs to PNG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExportGraphs(obj,~)
global BurstData UserValues
h = guidata(obj);
fontsize = 24;
if ispc
    fontsize = fontsize/1.2;
end

size_pixels = 500;
switch obj
    case h.Export1DX_Menu
        %%% Create a new figure with aspect ratio appropiate for the current plot
        %%% i.e. 1.2*[x y]
        AspectRatio = 0.7;
        pos = [1,1, round(1.2*size_pixels),round(1.2*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1],'Visible','on');
        %%% Copy axes to figure
        axes_copy = copyobj(h.axes_1d_x,hfig);
        %%% Rescale Position
        axes_copy.Position = [0.15 0.17 0.8 0.8];
        %%% Increase fontsize
        axes_copy.FontSize = fontsize;
        %%% change Background Color
        axes_copy.Color = [1,1,1];
        %%% Reset XAxis Location
        axes_copy.XAxisLocation = 'bottom';
        %%% Make Ticks point Outwards
        axes_copy.TickDir = 'out';
        %%% Disable Box
        axes_copy.Box = 'off';
        %%% increase LineWidth of Axes
        axes_copy.LineWidth = 3;
        %%% Change FaceColor of BarPlot
        axes_copy.Children(4).FaceColor = [0.5 0.5 0.5];
        axes_copy.Children(4).LineWidth = 3;
        %%% Redo YAxis Label
        axes_copy.YTickMode = 'auto';
        %%% Set XLabel
        xlabel(BurstData.NameArray{h.ParameterListX.Value},'FontSize',fontsize);
        ylabel('Frequency','FontSize',fontsize);
        %%% Construct Name
        FigureName = BurstData.NameArray{h.ParameterListX.Value};
    case h.Export1DY_Menu
        AspectRatio = 0.7;
        pos = [1,1, round(1.2*size_pixels),round(1.2*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1],'Visible','on');
        %%% Copy axes to figure
        axes_copy = copyobj(h.axes_1d_y,hfig);
        %%% flip axes
        axes_copy.View = [0,90];
        %%% Reverse XDir
        axes_copy.XDir = 'normal';
        %%% Rescale Position
        axes_copy.Position = [0.18 0.17 0.8 0.8];
        %%% Increase fontsize
        axes_copy.FontSize = 50;
        %%% change Background Color
        axes_copy.Color = [1,1,1];
        %%% Reset XAxis Location
        axes_copy.XAxisLocation = 'bottom';
        %%% Make Ticks point Outwards
        axes_copy.TickDir = 'out';
        %%% Disable Box
        axes_copy.Box = 'off';
        %%% increase LineWidth of Axes
        axes_copy.LineWidth = 3;
        %%% Change FaceColor of BarPlot
        axes_copy.Children(4).FaceColor = [0.5 0.5 0.5];
        axes_copy.Children(4).LineWidth = 3;
        %%% Redo YAxis Label
        axes_copy.YTickMode = 'auto';
        %%% Set XLabel
        xlabel(BurstData.NameArray{h.ParameterListY.Value},'FontSize',50);
        ylabel('Frequency','FontSize',50);
        %%% Construct Name
        FigureName = BurstData.NameArray{h.ParameterListY.Value};
    case h.Export2D_Menu
        AspectRatio = 1;
        pos = [1,1, round(1.3*size_pixels),round(1.2*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1],'Visible','on');
        %%% Copy axes to figure
        panel_copy = copyobj(h.MainTabGeneralPanel,hfig);
        %%% set Background Color to white
        panel_copy.BackgroundColor = [1 1 1];
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
        for i = 1:numel(panel_copy.Children)
            if ~strcmp(panel_copy.Children(i),'axes')
                del(i) = 1;
            end
        end
        delete(panel_copy.Children(del));
        for i = 1:numel(panel_copy.Children)
            %%% Set the Color of Axes to white
            panel_copy.Children(i).Color = [1 1 1];
            %%% increase LineWidth of Axes
            panel_copy.Children(i).LineWidth = 3;
            %%% Increase FontSize
            panel_copy.Children(i).FontSize = fontsize;
            %%% Reorganize Axes Positions
            switch panel_copy.Children(i).Tag
                case 'Axes_1D_Y'
                    panel_copy.Children(i).Position = [0.77 0.135 0.15 0.65];
                    panel_copy.Children(i).YTickLabelRotation = 270;
                case 'Axes_1D_X'
                    panel_copy.Children(i).Position = [0.12 0.785 0.65 0.15];
                    xlabel(panel_copy.Children(i),'');
                case 'Axes_General'
                    panel_copy.Children(i).Position = [0.12 0.135 0.65 0.65];
            end
        end
        FigureName = [BurstData.NameArray{h.ParameterListX.Value} '_' BurstData.NameArray{h.ParameterListY.Value}];
    case h.ExportLifetime_Menu
        AspectRatio = 1;
        pos = [1,1, round(1.2*size_pixels),round(1.2*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1]);
        %%% Copy axes to figure
        panel_copy = copyobj(h.MainTabLifetimePanel,hfig);
        %%% set Background Color to white
        panel_copy.BackgroundColor = [1 1 1];
        %%% Update ColorMap
        if ischar(UserValues.BurstBrowser.Display.ColorMap)
            eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);
        else
            colormap(UserValues.BurstBrowser.Display.ColorMap);
        end
        if any(BurstData.BAMethod == [1,2])
            for i = 1:numel(panel_copy.Children)
                %%% Set the Color of Axes to white
                panel_copy.Children(i).Color = [1 1 1];
                %%% increase LineWidth of Axes
                panel_copy.Children(i).LineWidth = 3;
                %%% Increase FontSize
                panel_copy.Children(i).FontSize = 30;
                %%% Make Bold
                %panel_copy.Children(i).FontWeight = 'bold';
                %%% disable titles
                title(panel_copy.Children(i),'');
                %%% move axes up and left
                panel_copy.Children(i).Position = panel_copy.Children(i).Position + [0.0325 0.0325 0 0];
                %%% Add rotational correlation time
                if isfield(BurstData,'Parameters')
                    switch i
                        case 1
                            %%%rRR vs TauRR
                            if ~isempty(BurstData.Parameters.rhoRR)
                                str = sprintf('\\rho = %1.1f ns',BurstData.Parameters.rhoRR(1));
                                if numel(BurstData.Parameters.rhoRR) > 1
                                    str = [str(1:4) '_1' str(5:end)];
                                    for j=2:numel(BurstData.Parameters.rhoRR)
                                        str = [str sprintf(['\n\\rho_' num2str(j) ' = %1.1f ns'],BurstData.Parameters.rhoRR(j))];
                                    end
                                end
                            end
                            text(0.775*panel_copy.Children(i).XLim(2),0.85*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',20);
                            %'BackgroundColor',[1 1 1],...
                            %'EdgeColor',[0 0 0]);
                        case 2
                            %%%rGG vs TauGG
                            if ~isempty(BurstData.Parameters.rhoGG)
                                str = sprintf('\\rho = %1.1f ns',BurstData.Parameters.rhoGG(1));
                                if numel(BurstData.Parameters.rhoGG) > 1
                                    str = [str(1:4) '_1' str(5:end)];
                                    for j=2:numel(BurstData.Parameters.rhoGG)
                                        str = [str sprintf(['\n\\rho_' num2str(j) ' = %1.1f ns'],BurstData.Parameters.rhoGG(j))];
                                    end
                                end
                            end
                            text(0.775*panel_copy.Children(i).XLim(2),0.85*panel_copy.Children(i).YLim(2),str,...
                                'Parent',panel_copy.Children(i),...
                                'FontSize',20);
                            %'BackgroundColor',[1 1 1],...
                            %'EdgeColor',[0 0 0]);
                    end
                end
            end
        end
        FigureName = 'LifetimePlots';
    case h.ExportEvsTau_Menu
        AspectRatio = 1;
        pos = [1,1, round(1.2*0.5*size_pixels),round(1.2*0.5*size_pixels*AspectRatio)];
        hfig = figure('Position',pos,'Color',[1 1 1]);
        %%% Copy axes to figure
        axes_copy = copyobj(h.axes_EvsTauGG,hfig);
        axes_copy.Position = [0.1 0.1 0.8 0.8];
        %%% set Background Color to white
        axes_copy.Color = [1 1 1];
        %%% Update ColorMap
        if ischar(UserValues.BurstBrowser.Display.ColorMap)
            eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);
        else
            colormap(UserValues.BurstBrowser.Display.ColorMap);
        end
        FigureName = 'E vs. TauGG';
end
%%% Combine the Original FileName and the parameter names
if strcmp(BurstData.FileNameSPC,'_m1')
    FileName = BurstData.FileNameSPC(1:end-3);
else
    FileName = BurstData.FileNameSPC;
end
FigureName = [FileName '_' FigureName];

directly_save = 0;
if directly_save
    %%% Get Path to save File
    FilterSpec = {'*.png','PNG File';'*.pdf','PDF File';'*.tif','TIFF File'};
    [FileName,PathName,FilterIndex] = uiputfile(FilterSpec,'Choose a filename',fullfile(UserValues.BurstBrowser.PrintPath,FigureName));
    UserValues.BurstBrowser.PrintPath = PathName;
    LSUserValues(1);
    %%% print figure
    hfig.PaperPositionMode = 'auto';
    dpi = 300;
    switch FilterIndex
        case 1
            print(hfig,fullfile(PathName,FileName),'-dpng',sprintf('-r%d',dpi));
        case 2
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
            
            print(hfig,fullfile(PathName,FileName),'-dpdf',sprintf('-r%d',dpi));
        case 3
            print(hfig,fullfile(PathName,FileName),'-dtiff',sprintf('-r%d',dpi));
    end
    close(hfig);
end

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
end

obj.BackgroundColor = c;

%%% Change Color of Line Plots
for i = 1:numel(fields)
  if n <= numel(BurstMeta.Plots.Fits.(fields{i}))
      if strcmp(BurstMeta.Plots.Fits.(fields{i})(n).Type,'line')
        BurstMeta.Plots.Fits.(fields{i})(n).Color = c;
      end
  end
end

LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% General Functions for plotting 2d-Histogram of data %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [H,xbins,ybins,xbins_hist,ybins_hist] = calc2dhist(x,y,nbins,limx,limy)
%%% ouput arguments:
%%% H:                      Image Data
%%% xbins/ybins:            corrected xbins for image plot
%%% xbins_hist/ybins_hist:  use these x/y values for 1d-bar plots
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
if ~UserValues.BurstBrowser.Display.KDE %%% no smoothing
    [H, xbins_hist, ybins_hist] = hist2d([x y], nbins(1), nbins(2), limx, limy);
    H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
    H(end-1,:) = H(end-1,:) + H(end,:); H(end,:) = [];
    xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
    ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;
elseif UserValues.BurstBrowser.Display.KDE %%% smoothing
    if sum(x) == 0 || sum(y) == 0 %%% KDE fails if this is the case
        [H, xbins_hist, ybins_hist] = hist2d([x y], nbins(1), nbins(2), limx, limy);
    else
        [~,H, xbins_hist, ybins_hist] = kde2d([x y],nbins(1),[limx(1) limy(1)],[limx(2), limy(2)]);
        xbins_hist = xbins_hist(1,:);
        ybins_hist = ybins_hist(:,1);
    end
    H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
    H(end-1,:) = H(end-1,:) + H(end,:); H(end,:) = [];
    xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
    ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;
end

function [Hout, Xbins, Ybins] = hist2d(D, varargin) %Xn, Yn, Xrange, Yrange)
%HIST2D 2D histogram
%
% [H XBINS YBINS] = HIST2D(D, XN, YN, [XLO XHI], [YLO YHI])
% [H XBINS YBINS] = HIST2D(D, 'display' ...)
%
% HIST2D calculates a 2-dimensional histogram and returns the histogram
% array and (optionally) the bins used to calculate the histogram.
%
% Inputs:
%     D:         N x 2 real array containing N data points or N x 1 array
%                 of N complex values
%     XN:        number of bins in the x dimension (defaults to 200)
%     YN:        number of bins in the y dimension (defaults to 200)
%     [XLO XHI]: range for the bins in the x dimension (defaults to the
%                 minimum and maximum of the data points)
%     [YLO YHI]: range for the bins in the y dimension (defaults to the
%                 minimum and maximum of the data points)
%     'display': displays the 2D histogram as a surf plot in the current
%                 axes
%
% Outputs:
%     H:         2D histogram array (rows represent X, columns represent Y)
%     XBINS:     the X bin edges (see below)
%     YBINS:     the Y bin edges (see below)
%
% As with histc, h(i,j) is the number of data points (dx,dy) where
% x(i) <= dx < x(i+1) and y(j) <= dx < y(j+1). The last x bin counts
% values where dx exactly equals the last x bin value, and the last y bin
% counts values where dy exactly equals the last y bin value.
%
% If D is a complex array, HIST2D splits the complex numbers into real (x)
% and imaginary (y) components.
%
% Created by Amanda Ng on 5 December 2008

% Modification history
%   25 March 2009 - fixed error when min and max of ranges are equal.
%   22 November 2009 - added display option; modified code to handle 1 bin

% PROCESS INPUT D
if nargin < 1 %check D is specified
    error 'Input D not specified'
end

Dcomplex = false;
if ~isreal(D) %if D is complex ...
    if isvector(D) %if D is a vector, split into real and imaginary
        D=[real(D(:)) imag(D(:))];
    else %throw error
        error 'D must be either a complex vector or nx2 real array'
    end
    Dcomplex = true;
end

if (size(D,1)<size(D,2) && size(D,1)>1)
    D=D';
end

if size(D,2)~=2;
    error('The input data matrix must have 2 rows or 2 columns');
end

% PROCESS OTHER INPUTS
var = varargin;

% check if DISPLAY is specified
index = find(strcmpi(var,'display'));
if ~isempty(index)
    display = true;
    var(index) = [];
else
    display = false;
end

% process number of bins
Xn = 200; %default
Xndefault = true;
if numel(var)>=1 && ~isempty(var{1}) % Xn is specified
    if ~isscalar(var{1})
        error 'Xn must be scalar'
    elseif var{1}<1 || mod(var{1},1)
        error 'Xn must be an integer greater than or equal to 1'
    else
        Xn = var{1};
        Xndefault = false;
    end
end

Yn = 200; %default
Yndefault = true;
if numel(var)>=2 && ~isempty(var{2}) % Yn is specified
    if ~isscalar(var{2})
        error 'Yn must be scalar'
    elseif var{2}<1 || mod(var{2},1)
        error 'Xn must be an integer greater than or equal to 1'
    else
        Yn = var{2};
        Yndefault = false;
    end
end

% process ranges
if numel(var) < 3 || isempty(var{3}) %if XRange not specified
    Xrange=[min(D(:,1)),max(D(:,1))]; %default
else
    if nnz(size(var{3})==[1 2]) ~= 2 %check is 1x2 array
        error 'XRange must be 1x2 array'
    end
    Xrange = var{3};
end
if Xrange(1)==Xrange(2) %handle case where XLO==XHI
    if Xndefault
        Xn = 1;
    else
        Xrange(1) = Xrange(1) - floor(Xn/2);
        Xrange(2) = Xrange(2) + floor((Xn-1)/2);
    end
end

if numel(var) < 4 || isempty(var{4}) %if XRange not specified
    Yrange=[min(D(:,2)),max(D(:,2))]; %default
else
    if nnz(size(var{4})==[1 2]) ~= 2 %check is 1x2 array
        error 'YRange must be 1x2 array'
    end
    Yrange = var{4};
end
if Yrange(1)==Yrange(2) %handle case where YLO==YHI
    if Yndefault
        Yn = 1;
    else
        Yrange(1) = Yrange(1) - floor(Yn/2);
        Yrange(2) = Yrange(2) + floor((Yn-1)/2);
    end
end

% SET UP BINS
Xlo = Xrange(1) ; Xhi = Xrange(2) ;
Ylo = Yrange(1) ; Yhi = Yrange(2) ;
if Xn == 1
    XnIs1 = true;
    Xbins = [Xlo Inf];
    Xn = 2;
else
    XnIs1 = false;
    Xbins = linspace(Xlo,Xhi,Xn) ;
end
if Yn == 1
    YnIs1 = true;
    Ybins = [Ylo Inf];
    Yn = 2;
else
    YnIs1 = false;
    Ybins = linspace(Ylo,Yhi,Yn) ;
end

Z = linspace(1, Xn+(1-1/(Yn+1)), Xn*Yn);

% split data
Dx = floor((D(:,1)-Xlo)/(Xhi-Xlo)*(Xn-1))+1;
Dy = floor((D(:,2)-Ylo)/(Yhi-Ylo)*(Yn-1))+1;
Dz = Dx + Dy/(Yn) ;

% calculate histogram
h = reshape(histc(Dz, Z), Yn, Xn);

if nargout >=1
    Hout = h;
end

if XnIs1
    Xn = 1;
    Xbins = Xbins(1);
    h = sum(h,1);
end
if YnIs1
    Yn = 1;
    Ybins = Ybins(1);
    h = sum(h,2);
end

% DISPLAY IF REQUESTED
if ~display
    return
end

[x y] = meshgrid(Xbins,Ybins);
dispH = h;

% handle cases when Xn or Yn
if Xn==1
    dispH = padarray(dispH,[1 0], 'pre');
    x = [x x];
    y = [y y];
end
if Yn==1
    dispH = padarray(dispH, [0 1], 'pre');
    x = [x;x];
    y = [y;y];
end

surf(x,y,dispH);
colormap(jet);
if Dcomplex
    xlabel real;
    ylabel imaginary;
else
    xlabel x;
    ylabel y;
end

function Calculate_Settings(obj,~)
global UserValues
h = guidata(findobj('Tag','BurstBrowser'));
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

function out = jetvar(m)

% JETVAR Variant of Jet colormap.
% 
% Usage: OUT = JETVAR(M)
% 
% This returns an M-by-3 matrix containing a variant of the Jet colormap.
% Instead of starting at dark blue as Jet does, it starts at white. It goes
% to pure blue from white, and then continues exactly as Jet does, ranging
% through shades blue, cyan, green, yellow, and red, and ending with dark
% red. M should be at least 10 to ensure there is at least one white color.
% 
% Inputs:
%   -M: Length of colormap (optional, default is the length of the current
%   figure's colormap).
% 
% Outputs:
%   -OUT: M-by-3 colormap.
% 
% See also: JET, HSV, HOT, PINK, FLAG, COLORMAP, RGBPLOT.

if nargin < 1
    m = size(get(gcf, 'colormap'), 1);
end
out = jet(m);
% Modify the output starting at 1 before where Jet outputs pure blue.
n = find(out(:, 3) == 1, 1) - 1;
out(1:n, 1:2) = repmat((n:-1:1)'/n, [1 2]);
out(1:n, 3) = 1;
















