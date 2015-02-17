function BurstBrowser %Burst Browser

hfig=findobj('Name','BurstBrowser');
global UserValues BurstMeta
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
    whitebg(h.BurstBrowser, Look.Fore);
    set(h.BurstBrowser,'Color',Look.Back);
    
    %%% define menu items
    %%% Load Burst Data Callback
    h.Load_Bursts = uimenu(...
    'Parent',h.BurstBrowser,...
    'Label','Load Burst Data',...
    'Callback',@Load_Burst_Data_Callback,...
    'Tag','Load_Burst_Data');
    
    %%% Save Analysis State
     h.Load_Bursts = uimenu(...
    'Parent',h.BurstBrowser,...
    'Label','Save Analysis State',...
    'Callback',@Save_Analysis_State_Callback,...
    'Tag','Save_Analysis_State');

    %define tabs
    %main tab
    h.Main_Tab = uitabgroup(...
        'Parent',h.BurstBrowser,...
        'Tag','Main_Tab',...
        'Units','normalized',...
        'Position',[0 0.01 0.65 0.98],...
        'SelectionChangedFcn',@MainTabSelectionChange);

    h.Main_Tab_General = uitab(h.Main_Tab,...
        'title','General',...
        'Tag','Main_Tab_General'...
        ); 

    h.MainTabGeneralPanel = uibuttongroup(...
        'Parent',h.Main_Tab_General,...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabGeneralPanel');
    
    h.Main_Tab_Corrections= uitab(h.Main_Tab,...
        'title','Corrections',...
        'Tag','Main_Tab_Corrections'...
        ); 
    
    h.MainTabCorrectionsPanel = uibuttongroup(...
        'Parent',h.Main_Tab_Corrections,...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabCorrectionsPanel');
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
    
    h.Main_Tab_Corrections_ThreeCMFD= uitab(h.Hide_Tab,...
        'title','Corrections (3C)',...
        'Tag','Main_Tab_Corrections_ThreeCMFD'...
        ); 
    
    h.MainTabCorrectionsThreeCMFDPanel = uibuttongroup(...
        'Parent',h.Main_Tab_Corrections_ThreeCMFD,...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabCorrectionsThreeCMFDPanel'...
        );
    
    h.Main_Tab_Lifetime= uitab(h.Main_Tab,...
        'title','Lifetime',...
        'Tag','Main_Tab_Lifetime'...
        ); 
    
    h.MainTabLifetimePanel = uibuttongroup(...
        'Parent',h.Main_Tab_Lifetime,...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabLifetimePanel');
    
    %%% fFCS main tab
    h.Main_Tab_fFCS= uitab(h.Main_Tab,...
        'title','filtered FCS',...
        'Tag','Main_Tab_fFCS'...
        ); 
    
    h.MainTabfFCSPanel = uibuttongroup(...
        'Parent',h.Main_Tab_fFCS,...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabfFCSPanel');
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
        'BackgroundColor', Look.Axes,...
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
        'BackgroundColor', Look.Axes,...
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
        'BackgroundColor', Look.Axes,...
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
        'BackgroundColor', Look.Axes,...
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
    'Position',[0.65 0.01 0.34 0.98]);

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
    
    h.Secondary_Tab_Correlation= uitab(h.Secondary_Tab,...
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
    
    %%% Define Species List
    h.SpeciesList = uicontrol(...
    'Parent',h.SecondaryTabSelectionPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Disabled,...
    'KeyPressFcn',@List_KeyPressFcn,...
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
    'BackgroundColor',[Look.Axes;Look.Fore],...
    'ForegroundColor',Look.Disabled,...
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
    'ForegroundColor', Look.Disabled,...
    'Max',5,...
    'Position',[0 0.55 0.5 0.45],...
    'Style','listbox',...
    'Tag','ParameterListX',...
    'Enable','on');
    
    h.ParameterListY = uicontrol(...
    'Parent',h.SecondaryTabSelectionPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Axes,...
    'ForegroundColor', Look.Disabled,...
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
    Corrections_Rownames = {'Gamma','Beta','Crosstalk','Direct Exc.','BG GG par','BG GG perp','BG GR par',...
        'BG GR perp','BG RR par','BG RR perp','G factor Green','G factor Red','l1','l2'};
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
        'BackgroundColor',[Look.Axes;Look.Fore],...
        'ForegroundColor',Look.Disabled);
    
    uicontrol('Style','text',...
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
        
    uicontrol(...
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
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
    'Position',[0.37 0.45 0.1 0.07],...
    'Style','edit',...
    'Tag','DonorLifetimeEdit',...
    'String',num2str(UserValues.BurstBrowser.Corrections.DonorLifetime),...
    'FontSize',12,...
    'Callback',@UpdateCorrections);

    uicontrol(...
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
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
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
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
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
    'FontSize',10,...
    'Callback',@DonorOnlyLifetimeCallback);

    uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.65 0.35 0.07],...
    'Style','text',...
    'Tag','FoersterRadiusText',...
    'String','Foerster Radius [A]',...
    'FontSize',12);
    
    h.FoersterRadiusEdit = uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
    'Position',[0.87 0.65 0.1 0.07],...
    'Style','edit',...
    'Tag','FoersterRadiusEdit',...
    'String',num2str(UserValues.BurstBrowser.Corrections.FoersterRadius),...
    'FontSize',12,...
    'Callback',@UpdateCorrections);

    uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.55 0.35 0.07],...
    'Style','text',...
    'Tag','LinkerLengthText',...
    'String','Linker Length [A]',...
    'FontSize',12);
    
    h.LinkerLengthEdit = uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
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
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
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
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
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
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
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
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
    'Position',[0.87 0.15 0.1 0.07],...
    'Style','edit',...
    'Tag','FoersterRadiusBREdit',...
    'String',num2str(UserValues.BurstBrowser.Corrections.LinkerLengthBR),...
    'FontSize',12,...
    'Visible','off',...
    'Callback',@UpdateCorrections);
    %% Secondary tab correlation
    Names = {'GG1','GG2','GR1','GR2','RR1','RR2','GG','GR','GX','RR'};
    h.Correlation_Table = uitable(...
        'Parent',h.SecondaryTabCorrelationPanel,...
        'Units','normalized',...
        'Position',[0 0.6 1 0.4],...
        'Tag','CorrelationTable',...
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
        'Tag','CorrelationTable',...
        'String','Correlate',...
        'Callback',@Correlate_Bursts);
    %% Secondary tab options
    
    %%% Display Options Panel
    h.DisplayOptionsPanel = uipanel(...
        'Parent',h.SecondaryTabOptionsPanel,...
        'Units','normalized',...
        'Position',[0 0.6 1 0.4],...
        'Tag','DisplayOptionsPanel',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'Title','Display Options',...
        'FontSize',12);
    
    %%% Specify the Number of Bins
    uicontrol('Style','text',...
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
    
    uicontrol('Style','text',...
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
    uicontrol('Style','text',...
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
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Disabled,...
        'Units','normalized',...
        'Position',[0.4 0.68 0.2 0.07],...
        'FontSize',12,...
        'Tag','PlotTypePopupmenu',...
        'String',PlotType_String,...
        'Value',find(strcmp(PlotType_String,UserValues.BurstBrowser.Display.PlotType)),...
        'Callback',@ChangePlotType...
        );
    
    %%% Specify the colormap
    uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Colormap',...
        'Tag','Text_ColorMap',...
        'Units','normalized',...
        'Position',[0 0.58 0.4 0.07],...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    Colormaps_String = {'jet','hot','bone','gray'};
    h.ColorMapPopupmenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Disabled,...
        'Units','normalized',...
        'Position',[0.4 0.58 0.2 0.07],...
        'FontSize',12,...
        'Tag','ColorMapPopupmenu',...
        'String',Colormaps_String,...
        'Value',find(strcmp(Colormaps_String,UserValues.BurstBrowser.Display.ColorMap)),...
        'Callback',@UpdatePlot...
        );
    
    %%% Data Processing Options Panel
    h.DataProcessingPanel = uipanel(...
        'Parent',h.SecondaryTabOptionsPanel,...
        'Units','normalized',...
        'Position',[0 0.2 1 0.4],...
        'Tag','DataProcessingPanel',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'Title','Data Processing Options',...
        'FontSize',12);
    %% Define axes in main_tab_general
    %define 2d axis
    h.axes_general =  axes(...
    'Parent',h.MainTabGeneralPanel,...
    'Units','normalized',...
    'Position',[0.07 0.06 0.73 0.75],...
    'Box','on',...
    'Tag','Axes_General',...
    'FontSize',12,...
    'View',[0 90],...
    'nextplot','add');
    
    %define 1d axes
    h.axes_1d_x =  axes(...
    'Parent',h.MainTabGeneralPanel,...
    'Units','normalized',...
    'Position',[0.07 0.81 0.73, 0.15],...
    'Box','on',...
    'Tag','Axes_1D_X',...
    'FontSize',12,...
    'XAxisLocation','top',...
    'nextplot','add',...
    'View',[0 90]);

    h.axes_1d_y =  axes(...
    'Parent',h.MainTabGeneralPanel,...
    'Units','normalized',...
    'Position',[0.8 0.06 0.15, 0.75],...
    'Tag','Main_Tab_General_Plot',...
    'Box','on',...
    'Tag','Axes_1D_Y',...
    'FontSize',12,...
    'XAxisLocation','top',...
    'nextplot','add',...
    'View',[90 90],...
    'XDir','reverse');
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
    title(h.axes_rGGvsTauGG,'Anisotropx GG vs. Lifetime GG');
    
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
        'BackgroundColor',Look.Axes,...
        'FontSize',12);
    
    h.fFCS_Species1_popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Tag','fFCS_Species1_popupmenu',...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0.14 0.94 0.15 0.05],...
        'String',{' '},...
        'Value',1,...
        'FontSize',12);
    
    uicontrol('Style','text',...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0.3 0.965 0.10 0.02],...
        'String','Species 2:',...
        'BackgroundColor',Look.Axes,...
        'FontSize',12);
    
    h.fFCS_Species2_popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Tag','fFCS_Species2_popupmenu',...
        'Parent',h.MainTabfFCSPanel,...
        'Units','normalized',...
        'Position',[0.39 0.94 0.15 0.05],...
        'String',{' '},...
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
                    h.(fields{i}).BackgroundColor = Look.Fore;
                    h.(fields{i}).ForegroundColor = Look.Back;
                end
            end
        end
    end
    %% Initialize Plots in Global Variable
    %%% Enables easy Updating later on
    BurstMeta.Plots = [];
    %%% Main Tab
    BurstMeta.Plots.Main_histX = bar(h.axes_1d_x,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
    BurstMeta.Plots.Main_histY = bar(h.axes_1d_y,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
    %%% Initialize both image AND contour plots in array
    BurstMeta.Plots.Main_Plot(1) = imagesc(zeros(2),'Parent',h.axes_general);axis(h.axes_general,'tight');
    [~,BurstMeta.Plots.Main_Plot(2)] = contourf(zeros(2),10,'Parent',h.axes_general,'Visible','off');
        %%% Main Tab multiple species (consider up to three)
        BurstMeta.Plots.Multi.Main_Plot_multiple = imagesc(zeros(2),'Parent',h.axes_general,'Visible','off');
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
        BurstMeta.Plots.Fits.gamma = plot(h.Corrections.TwoCMFD.axes_gamma,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',3);  %Fit
        BurstMeta.Plots.Fits.gamma_manual = scatter(h.Corrections.TwoCMFD.axes_gamma,[0 1],[0 1],1000,'+','LineWidth',4,'MarkerFaceColor','b','MarkerEdgeColor','b','Visible','off');  %Manual
    BurstMeta.Plots.gamma_lifetime(1) = imagesc(zeros(2),'Parent',h.Corrections.TwoCMFD.axes_gamma_lifetime);axis(h.Corrections.TwoCMFD.axes_gamma_lifetime,'tight');
    [~,BurstMeta.Plots.gamma_lifetime(2)] = contourf(zeros(2),'Parent',h.Corrections.TwoCMFD.axes_gamma_lifetime,'Visible','off');
        BurstMeta.Plots.Fits.staticFRET_gamma_lifetime = plot(h.Corrections.TwoCMFD.axes_gamma_lifetime,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',3,'Visible','off');
    %%% Lifetime Tab
    BurstMeta.Plots.EvsTauGG(1) = imagesc(zeros(2),'Parent',h.axes_EvsTauGG);axis(h.axes_EvsTauGG,'tight');
    [~,BurstMeta.Plots.EvsTauGG(2)] = contourf(zeros(2),10,'Parent',h.axes_EvsTauGG,'Visible','off');
        BurstMeta.Plots.Fits.staticFRET_EvsTauGG = plot(h.axes_EvsTauGG,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',3,'Visible','off');
    BurstMeta.Plots.EvsTauRR(1) = imagesc(zeros(2),'Parent',h.axes_EvsTauRR);axis(h.axes_EvsTauRR,'tight');
    [~,BurstMeta.Plots.EvsTauRR(2)] = contourf(zeros(2),10,'Parent',h.axes_EvsTauRR,'Visible','off');
        BurstMeta.Plots.Fits.AcceptorLifetime_EvsTauRR = plot(h.axes_EvsTauGG,[0],[1],'Color','b','LineStyle','-','LineWidth',3,'Visible','off');
    BurstMeta.Plots.rGGvsTauGG(1) = imagesc(zeros(2),'Parent',h.axes_rGGvsTauGG);axis(h.axes_rGGvsTauGG,'tight');
    [~,BurstMeta.Plots.rGGvsTauGG(2)] = contourf(zeros(2),10,'Parent',h.axes_rGGvsTauGG,'Visible','off');
        %%% Consider up to three Perrin lines
        BurstMeta.Plots.Fits.PerrinGG(1) = plot(h.axes_rGGvsTauGG,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinGG(2) = plot(h.axes_rGGvsTauGG,[0 1],[0 0],'Color','g','LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinGG(3) = plot(h.axes_rGGvsTauGG,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3,'Visible','off');
    BurstMeta.Plots.rRRvsTauRR(1) = imagesc(zeros(2),'Parent',h.axes_rRRvsTauRR);axis(h.axes_rRRvsTauRR,'tight');
    [~,BurstMeta.Plots.rRRvsTauRR(2)] = contourf(zeros(2),10,'Parent',h.axes_rRRvsTauRR,'Visible','off');axis(h.axes_rRRvsTauRR,'tight');
        %%% Consider up to three Perrin lines
        BurstMeta.Plots.Fits.PerrinRR(1) = plot(h.axes_rRRvsTauRR,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinRR(2) = plot(h.axes_rRRvsTauRR,[0 1],[0 0],'Color','g','LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinRR(3) = plot(h.axes_rRRvsTauRR,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3,'Visible','off'); 
    %%% Lifetime Tab 3C
    BurstMeta.Plots.E_BtoGRvsTauBB(1) = imagesc(zeros(2),'Parent',h.axes_E_BtoGRvsTauBB);axis(h.axes_E_BtoGRvsTauBB,'tight');
    [~,BurstMeta.Plots.E_BtoGRvsTauBB(2)] = contourf(zeros(2),10,'Parent',h.axes_E_BtoGRvsTauBB,'Visible','off');
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB = plot(h.axes_E_BtoGRvsTauBB,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',3,'Visible','off');
    BurstMeta.Plots.rBBvsTauBB(1) = imagesc(zeros(2),'Parent',h.axes_rBBvsTauBB);axis(h.axes_rBBvsTauBB,'tight');
    [~,BurstMeta.Plots.rBBvsTauBB(2)] = contourf(zeros(2),10,'Parent',h.axes_rBBvsTauBB,'Visible','off');
        %%% Consider up to three Perrin lines
        BurstMeta.Plots.Fits.PerrinBB(1) = plot(h.axes_rBBvsTauBB,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinBB(2) = plot(h.axes_rBBvsTauBB,[0 1],[0 0],'Color','g','LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinBB(3) = plot(h.axes_rBBvsTauBB,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3,'Visible','off');
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
        BurstMeta.Plots.Fits.gamma_BG = plot(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',3);  %Fit
        BurstMeta.Plots.Fits.gamma_BG_manual = scatter(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,[0 1],[0 1],1000,'+','LineWidth',4,'MarkerFaceColor','b','MarkerEdgeColor','b','Visible','off');  %Manual
    BurstMeta.Plots.gamma_BR_fit(1) = imagesc(zeros(2),'Parent',h.Corrections.ThreeCMFD.axes_gammaBR_threecolor);axis(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'tight');
    [~,BurstMeta.Plots.gamma_BR_fit(2)] = contourf(zeros(2),10,'Parent',h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'Visible','off');
        BurstMeta.Plots.Fits.gamma_BR = plot(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',3);  %Fit
        BurstMeta.Plots.Fits.gamma_BR_manual = scatter(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,[0 1],[0 1],1000,'+','LineWidth',4,'MarkerFaceColor','b','MarkerEdgeColor','b','Visible','off');  %Manual
    BurstMeta.Plots.gamma_threecolor_lifetime(1) = imagesc(zeros(2),'Parent',h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime);axis(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,'tight');
    [~,BurstMeta.Plots.gamma_threecolor_lifetime(2)] = contourf(zeros(2),'Parent',h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,'Visible','off');
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime = plot(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,[0 1],[0 0],'Color','b','LineStyle','-','LineWidth',3,'Visible','off');
    
    ChangePlotType(h.PlotTypePopumenu,[]);
    %% set UserValues in GUI
    UpdateCorrections([],[]);
    guidata(h.BurstBrowser,h);    
    %%% Update ColorMap
    eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);
else
    figure(hfig);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Close Function: Clear global Variable on closing  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_BurstBrowser(~,~)
clear global -regexp BurstMeta
Phasor=findobj('Tag','Phasor');
Pam=findobj('Tag','Pam');
if isempty(Phasor) && isempty(Pam)
    clear global -regexp UserValues BurstData
end
delete(gcf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Load *.bur file  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Burst_Data_Callback(~,~)
%%% clear global variable
clearvars -global BurstData BurstTCSPCData
h = guidata(gcbo);
global BurstData UserValues BurstMeta
if isfield(BurstMeta,'fFCS')
    BurstMeta = rmfield(BurstMeta,'fFCS');
end
if isfield(BurstMeta,'Data')
    BurstMeta = rmfield(BurstMeta,'Data');
end
LSUserValues(0);
[FileName,PathName] = uigetfile({'*.bur'}, 'Choose a file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');

if FileName == 0
    return;
end

LSUserValues(0);
UserValues.File.BurstBrowserPath=PathName;
LSUserValues(1);
load('-mat',fullfile(PathName,FileName));

%%% Determine if an APBS or DCBS file was loaded
%%% This is important because for APBS, the donor only lifetime can be
%%% determined from the measurement!
if ~isempty(strfind(FileName,'APBS'))
    %%% Enable the donor only lifetime checkbox
    h.DonorLifetimeFromDataCheckbox.Enable = 'on';
    %%% Crosstalk/direct excitation can be determined!
    %%% set flag:
    BurstMeta.APBS = 1;
end
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

SwitchGUI(BurstData.BAMethod); %%% Switches GUI to 3cMFD or 2cMFD format
UpdateCorrections([],[]);
UpdateCutTable(h);
UpdateCuts();
UpdatePlot([]);
UpdateLifetimePlots([],[]);
Update_fFCS_GUI(gcbo,[]);

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
    
    BurstData.Cut{species}{end+1} = {BurstData.NameArray{param}, min(BurstData.DataArray(:,param)),max(BurstData.DataArray(:,param)), true,false};
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
function Export_To_PDA(~,~)
global BurstData BurstTCSPCData
h = guidata(findobj('Tag','BurstBrowser'));
SelectedSpecies = h.SpeciesList.Value;
SelectedSpeciesName = BurstData.SpeciesNames{SelectedSpecies};

Valid = UpdateCuts(SelectedSpecies);
h_waitbar = waitbar(0,'Exporting...');
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData)
    waitbar(0,h_waitbar,'Loading Photon Data');
    load('-mat',[BurstData.FileName(1:end-3) 'bps']);
    BurstTCSPCData.Macrotime = Macrotime;
    BurstTCSPCData.Microtime = Microtime;
    BurstTCSPCData.Channel = Channel;
    clear Macrotime Microtime Channel
end
waitbar(0,h_waitbar,'Exporting...');
%%% find selected bursts
MT = BurstTCSPCData.Macrotime(BurstData.Selected);
CH = BurstTCSPCData.Channel(BurstData.Selected);
%%% Hard-Code 1ms here
timebin = 1E-3;
duration = timebin/BurstData.SyncPeriod;
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

%now save channel wise photon numbers
total = n_bins;
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

newfilename = [BurstData.FileName(1:end-4) '_' SelectedSpeciesName '_' num2str(timebin*1000) 'ms.pda'];
save(newfilename, 'PDA', 'timebin')

delete(h_waitbar);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Plot in the Main Axis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdatePlot(obj,~)
%% Preparation
global BurstData UserValues BurstMeta  
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
        h.NumberOfBinsXEdit.String = UserValues.BurstBrowser.Display.NumberOfBinsX;
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
        h.NumberOfBinsYEdit.String = UserValues.BurstBrowser.Display.NumberOfBinsY;
    end
end

if obj == h.ColorMapPopupmenu
    UserValues.BurstBrowser.Display.ColorMap = h.ColorMapPopupmenu.String{h.ColorMapPopupmenu.Value};
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

[H, xbins,ybins,~,~] = calc2dhist(datatoplot(:,x),datatoplot(:,y),[nbinsX nbinsY]);

%%% Update Image Plot and Contour Plot
BurstMeta.Plots.Main_Plot(1).XData = xbins;
BurstMeta.Plots.Main_Plot(1).YData = ybins;
BurstMeta.Plots.Main_Plot(1).CData = H;
BurstMeta.Plots.Main_Plot(1).AlphaData = (H > 0);
BurstMeta.Plots.Main_Plot(2).XData = xbins;
BurstMeta.Plots.Main_Plot(2).YData = ybins;
BurstMeta.Plots.Main_Plot(2).ZData = H/max(max(H));
BurstMeta.Plots.Main_Plot(2).LevelList = linspace(0.1,1,10);

axis(h.axes_general,'tight');
%%% Update Labels
xlabel(h.axes_general,h.ParameterListX.String{x});
ylabel(h.axes_general,h.ParameterListY.String{y});

%plot 1D hists    
%hx = histc(datatoplot(:,x),xbins_1d);
%hx(end-1) = hx(end-1) + hx(end); hx(end) = [];
BurstMeta.Plots.Main_histX.XData = xbins;
%BurstMeta.Plots.Main_histX.YData = hx;
BurstMeta.Plots.Main_histX.YData = sum(H,1);
yticks= get(h.axes_1d_x,'YTick');
set(h.axes_1d_x,'YTick',yticks(2:end));

%hy = histc(datatoplot(:,y),ybins_1d);
%hy(end-1) = hy(end-1) + hy(end); hy(end) = [];
BurstMeta.Plots.Main_histY.XData = ybins;
%BurstMeta.Plots.Main_histY.YData = hy;
BurstMeta.Plots.Main_histY.YData = sum(H,2);
yticks = get(h.axes_1d_y,'YTick');
set(h.axes_1d_y,'YTick',yticks(2:end));

%%% tighten axes
axis(h.axes_general,'tight');
axis(h.axes_1d_x,'tight');
axis(h.axes_1d_y,'tight');
%%% Update ColorMap
eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);
drawnow;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Changes PlotType  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangePlotType(obj,~)
global UserValues BurstMeta
UserValues.BurstBrowser.Display.PlotType = obj.String{obj.Value};
LSUserValues(1);

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
    [H{i}, xbins_hist, ybins_hist] = hist2d([datatoplot{i}(:,x) datatoplot{i}(:,y)],nbinsX, nbinsY, x_boundaries, y_boundaries);
    H{i}(H{i}==0) = NaN;
    H{i}(:,end-1) = H{i}(:,end-1) + H{i}(:,end); H{i}(:,end) = [];
    H{i}(end-1,:) = H{i}(end-1,:) + H{i}(end,:); H{i}(end,:) = [];
end

xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;

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
hx = histc(datatoplot{1}(:,x),xbins_hist);
hx(end-1) = hx(end-1) + hx(end); hx(end) = [];
%normalize
hx = hx./sum(hx); hx = hx';
BurstMeta.Plots.Multi.Multi_histX(1).Visible = 'on';
BurstMeta.Plots.Multi.Multi_histX(1).XData = [xbins(1)-min(diff(xbins))/2 xbins+min(diff(xbins))/2];
BurstMeta.Plots.Multi.Multi_histX(1).YData = [hx, hx(end)];
%stairsx(1) = stairs([xbins(1)-min(diff(xbins))/2 xbins+min(diff(xbins))/2],[hx, hx(end)],'Color','b','LineWidth',2);
%plot rest of histograms
for i = 2:num_species
    BurstMeta.Plots.Multi.Multi_histX(i).Visible = 'on';
    hx = histc(datatoplot{i}(:,x),xbins_hist);
    hx(end-1) = hx(end-1) + hx(end); hx(end) = [];
    %normalize
    hx = hx./sum(hx); hx = hx';
    BurstMeta.Plots.Multi.Multi_histX(i).XData = [xbins(1)-min(diff(xbins))/2 xbins+min(diff(xbins))/2];
    BurstMeta.Plots.Multi.Multi_histX(i).YData = [hx, hx(end)];
    %stairsx(i) = stairs([xbins(1)-min(diff(xbins))/2 xbins+min(diff(xbins))/2],[hx, hx(end)],'Color','r','LineWidth',2);
    %stairsx(i) = stairs([xbins(1)-min(diff(xbins))/2 xbins+min(diff(xbins))/2],[hx, hx(end)],'Color','g','LineWidth',2);
end

yticks = get(h.axes_1d_x,'YTick');
set(h.axes_1d_x,'YTick',yticks(2:end));

%plot first histogram
hy = histc(datatoplot{1}(:,y),ybins_hist);
hy(end-1) = hy(end-1) + hy(end); hy(end) = [];
%normalize
hy = hy./sum(hy); hy = hy';
BurstMeta.Plots.Multi.Multi_histY(1).Visible = 'on';
BurstMeta.Plots.Multi.Multi_histY(1).XData = [ybins(1)-min(diff(ybins))/2 ybins+min(diff(ybins))/2];
BurstMeta.Plots.Multi.Multi_histY(1).YData = [hy, hy(end)];
%stairsy(1) = stairs([ybins(1)-min(diff(ybins))/2 ybins+min(diff(ybins))/2],[hy, hy(end)],'Color','b','LineWidth',2);
%plot rest of histograms
for i = 2:num_species
    BurstMeta.Plots.Multi.Multi_histY(i).Visible = 'on';
    hy = histc(datatoplot{i}(:,y),ybins_hist);
    hy(end-1) = hy(end-1) + hy(end); hy(end) = [];
    %normalize
    hy = hy./sum(hy); hy = hy';
    BurstMeta.Plots.Multi.Multi_histY(i).XData = [ybins(1)-min(diff(ybins))/2 ybins+min(diff(ybins))/2];
    BurstMeta.Plots.Multi.Multi_histY(i).YData = [hy, hy(end)];
    %stairsy(i) = stairs([ybins(1)-min(diff(ybins))/2 ybins+min(diff(ybins))/2],[hy, hy(end)],'Color','r','LineWidth',2);
    %stairsy(i) = stairs([ybins(1)-min(diff(ybins))/2 ybins+min(diff(ybins))/2],[hy, hy(end)],'Color','g','LineWidth',2);
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
BurstData.Cut{species}{end+1} = {BurstData.NameArray{get(h.ParameterListX,'Value')}, min([point1(1) point2(1)]),max([point1(1) point2(1)]), true,false};
BurstData.Cut{species}{end+1} = {BurstData.NameArray{get(h.ParameterListY,'Value')}, min([point1(2) point2(2)]),max([point1(2) point2(2)]), true,false};

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
                else %%% Parameter is new to GlobalCut
                    BurstData.Cut{j}(end+1) = BurstData.Cut{1}(index(1));
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
Background_GR = UserValues.BurstBrowser.Corrections.Background_GRpar + UserValues.BurstBrowser.Corrections.Background_GRperp;
Background_GG = UserValues.BurstBrowser.Corrections.Background_GGpar + UserValues.BurstBrowser.Corrections.Background_GGperp;
Background_RR = UserValues.BurstBrowser.Corrections.Background_RRpar + UserValues.BurstBrowser.Corrections.Background_RRperp;
%% 2cMFD Corrections
%% Crosstalk and direct excitation
if obj ==h.DetermineCorrectionsButton
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
NGR = NGR - UserValues.BurstBrowser.Corrections.DirectExcitation_GR.*NRR - UserValues.BurstBrowser.Corrections.CrossTalk_GR.*NGG;
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
BurstMeta.Plots.gamma_fit(2).LevelList = linspace(0.1,1,10);
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
UserValues.BurstBrowser.Corrections.Beta_GR = b+m-1;
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
    Background_BB = UserValues.BurstBrowser.Corrections.Background_BBpar + UserValues.BurstBrowser.Corrections.Background_BBperp;
    Background_BG = UserValues.BurstBrowser.Corrections.Background_BGpar + UserValues.BurstBrowser.Corrections.Background_BGperp;
    Background_BR = UserValues.BurstBrowser.Corrections.Background_BRpar + UserValues.BurstBrowser.Corrections.Background_BRperp;
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
    NBG = NBG - UserValues.BurstBrowser.Corrections.DirectExcitation_BG.*NGG - UserValues.BurstBrowser.Corrections.CrossTalk_BG.*NBB;
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
    BurstMeta.Plots.gamma_BG_fit(2).LevelList = linspace(0.1,1,10);
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
    UserValues.BurstBrowser.Corrections.Beta_BG = b+m-1;
    
    S_threshold = ( (data_for_corrections(:,indS) < 0.2) &...
        (data_for_corrections(:,indSBG) > 0.9) &...
        (data_for_corrections(:,indSBR) > 0.2) & (data_for_corrections(:,indSBR) < 0.8) );
    NBB = data_for_corrections(S_threshold,indNBB) - Background_BB.*data_for_corrections(S_threshold,indDur);
    NBR = data_for_corrections(S_threshold,indNBR) - Background_BR.*data_for_corrections(S_threshold,indDur);
    NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
    NBR = NBR - UserValues.BurstBrowser.Corrections.DirectExcitation_BR.*NRR - UserValues.BurstBrowser.Corrections.CrossTalk_BR.*NBB;
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
    BurstMeta.Plots.gamma_BR_fit(2).LevelList = linspace(0.1,1,10);
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
    UserValues.BurstBrowser.Corrections.Beta_BR = b+m-1;
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
%%%%%%% Updates GUI elements in fFCS tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
else %%% Set to empty
    h.fFCS_Species1_popupmenu.String = '';
    h.fFCS_Species1_popupmenu.Value = 1;
    h.fFCS_Species2_popupmenu.String = '';
    h.fFCS_Species2_popupmenu.Value = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Microtime Histograms in fFCS tab %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_MicrotimeHistograms(obj,~)
global BurstData BurstMeta BurstTCSPCData
h = guidata(obj);
%%% Load associated *.bps data if it doesn't exist yet
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData)
    load('-mat',[BurstData.FileName(1:end-3) 'bps']);
    BurstTCSPCData.Macrotime = Macrotime;
    BurstTCSPCData.Microtime = Microtime;
    BurstTCSPCData.Channel = Channel;
    clear Macrotime Microtime Channel
end
%%% Read out the bursts contained in the different species selections
valid_total = UpdateCuts(1);
species1 = h.fFCS_Species1_popupmenu.Value + 1;BurstMeta.fFCS.Names{1} = h.fFCS_Species1_popupmenu.String{h.fFCS_Species1_popupmenu.Value};
species2 = h.fFCS_Species2_popupmenu.Value + 1;BurstMeta.fFCS.Names{2} = h.fFCS_Species2_popupmenu.String{h.fFCS_Species2_popupmenu.Value};
valid_species1 = UpdateCuts(species1);
valid_species2 = UpdateCuts(species2);

%%% find selected bursts
MI_total = BurstTCSPCData.Microtime(valid_total);MI_total = vertcat(MI_total{:});
CH_total = BurstTCSPCData.Channel(valid_total);CH_total = vertcat(CH_total{:});
MT_total = BurstTCSPCData.Macrotime(valid_total);MT_total = vertcat(MT_total{:});
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
limit_low_par = [0, BurstData.fFCS.From(ParChans)];
limit_high_par = [0, BurstData.fFCS.To(ParChans)];
dif_par = cumsum(limit_high_par)-cumsum(limit_low_par);
limit_low_perp = [0,BurstData.fFCS.From(PerpChans)];
limit_high_perp = [0, BurstData.fFCS.To(PerpChans)];
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
% for i = 1:2 %%% loop over species
%     [MT_par{i},idx] = sort(MT_par{i});
%     MI_par{i} = MI_par{i}(idx);
%     [MT_perp{i},idx] = sort(MT_perp{i});
%     MI_perp{i} = MI_perp{i}(idx);
% end

%%% Calculate the histograms
maxTAC_par = max(MI_total_par);
maxTAC_perp = max(MI_total_perp);
BurstMeta.fFCS.TAC_par = 1:1:(maxTAC_par+1);%%% Add one because of how histc treats the bin edges
BurstMeta.fFCS.TAC_perp = 1:1:(maxTAC_perp+1);
for i = 1:2
    BurstMeta.fFCS.hist_MIpar_Species{i} = histc(MI_par{i},BurstMeta.fFCS.TAC_par);
    BurstMeta.fFCS.hist_MIperp_Species{i} = histc(MI_perp{i},BurstMeta.fFCS.TAC_perp);
end
BurstMeta.fFCS.hist_MItotal_par = histc(MI_total_par,BurstMeta.fFCS.TAC_par);
BurstMeta.fFCS.hist_MItotal_perp = histc(MI_total_perp,BurstMeta.fFCS.TAC_perp);

%%% Store Photon Vectors of total photons in BurstMeta
BurstMeta.fFCS.Photons.MT_total_par = MT_total_par;
BurstMeta.fFCS.Photons.MI_total_par = MI_total_par;
BurstMeta.fFCS.Photons.MT_total_perp = MT_total_perp;
BurstMeta.fFCS.Photons.MI_total_perp = MI_total_perp;
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
if isfield(BurstData.fFCS,'IRF')
    hIRF_par = [];
    hIRF_perp = [];
    for i = 1:numel(ParChans)
        hIRF_par = [hIRF_par, BurstData.fFCS.IRF(BurstData.PIE.Detector(ParChans(i)),limit_low_par(i+1):limit_high_par(i+1))];
        hIRF_perp = [hIRF_perp, BurstData.fFCS.IRF(BurstData.PIE.Detector(PerpChans(i)),limit_low_perp(i+1):limit_high_perp(i+1))];
    end
    %%% normaize with respect to the total decay histogram
    hIRF_par = hIRF_par./max(hIRF_par).*max(BurstMeta.fFCS.hist_MItotal_par);
    hIRF_perp = hIRF_perp./max(hIRF_perp).*max(BurstMeta.fFCS.hist_MItotal_perp);
    %%% store in BurstMeta
    BurstMeta.fFCS.hIRF_par = hIRF_par;
    BurstMeta.fFCS.hIRF_perp = hIRF_perp;
    %%% Update Plots
    BurstMeta.Plots.fFCS.IRF_par.XData = BurstMeta.fFCS.TAC_par;
    BurstMeta.Plots.fFCS.IRF_par.YData = BurstMeta.fFCS.hIRF_par;
    BurstMeta.Plots.fFCS.IRF_perp.XData = BurstMeta.fFCS.TAC_perp;
    BurstMeta.Plots.fFCS.IRF_perp.YData = BurstMeta.fFCS.hIRF_perp;
elseif ~isfield(BurstData.fFCS,'IRF')
    %%% Hide IRF plots
    BurstMeta.Plots.fFCS.IRF_par.Visible = 'off';
    BurstMeta.Plots.fFCS.IRF_perp.Visible = 'off';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates fFCS filter and updates plots %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Calc_fFCS_Filters(obj,~)
global BurstMeta BurstData
h = guidata(obj);

%%% Concatenate Decay Patterns
Decay_par = [BurstMeta.fFCS.hist_MIpar_Species{1},...
    BurstMeta.fFCS.hist_MIpar_Species{2}];
if isfield(BurstData.fFCS,'IRF') %%% include scatter pattern
    Decay_par = [Decay_par, BurstMeta.fFCS.hIRF_par(1:size(Decay_par,1))'];
end
Decay_par = Decay_par./repmat(sum(Decay_par,1),size(Decay_par,1),1);
Decay_total_par = BurstMeta.fFCS.hist_MItotal_par;
Decay_total_par(Decay_total_par == 0) = 1; %%% fill zeros with 1
Decay_perp = [BurstMeta.fFCS.hist_MIperp_Species{1},...
    BurstMeta.fFCS.hist_MIperp_Species{2}];
if isfield(BurstData.fFCS,'IRF') %%% include scatter pattern
    Decay_perp = [Decay_perp, BurstMeta.fFCS.hIRF_perp(1:size(Decay_perp,1))'];
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Does fFCS Correlation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_fFCS(~,~)
global BurstMeta BurstData
h = guidata(findobj('Tag','BurstBrowser'));
%%% Set Up Progress Bar
h_waitbar = waitbar(0,'Correlating...');
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
%%% Split Data in 10 time bins for errorbar calculation
Times = ceil(linspace(0,max([MT_par;MT_perp]),11));
count = 0;
for i=1:NumChans
    for j=1:NumChans
        if CorrMat(i,j)
            %%% Calculates the maximum inter-photon time in clock ticks
            Maxtime=max(diff(Times));
            Data1 = cell(10,1);
            Data2 = cell(10,1);
            Weights1 = cell(10,1);
            Weights2 = cell(10,1);
            for k = 1:10
                Data1{k} = MT_par( MT_par > Times(k) &...
                    MT_par <= Times(k+1)) - Times(k);
                Weights1{k} = filters_par{i}(MI_par( MT_par > Times(k) &...
                    MT_par <= Times(k+1)) );
                Data2{k} = MT_perp( MT_perp > Times(k) &...
                    MT_perp <= Times(k+1)) - Times(k);
                Weights2{k} = filters_perp{j}(MI_perp(MT_perp > Times(k) &...
                    MT_perp <= Times(k+1)) );
            end
            %%% Do Correlation
            [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data2,Maxtime,Weights1,Weights2);
            Cor_Times=Cor_Times*BurstData.SyncPeriod;
            %%% Calculates average and standard error of mean (without tinv_table yet
            if numel(Cor_Array)>1
                Cor_Average=mean(Cor_Array,2);
                %Cor_SEM=std(Cor_Array,0,2)/sqrt(size(Cor_Array,2));
                %%% Averages files before saving to reduce errorbars
                Amplitude=sum(Cor_Array,1);
                Cor_Norm=Cor_Array./repmat(Amplitude,[size(Cor_Array,1),1])*mean(Amplitude);
                Cor_SEM=std(Cor_Norm,0,2)/sqrt(size(Cor_Array,2));

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
            Counts = [numel(MT_par) numel(MT_perp)]/(BurstData.SyncPeriod*max([MT_par;MT_perp]))/1000;
            Valid = 1:10;
            save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
            count = count +1;waitbar(count/4);
        end 
    end
end
delete(h_waitbar);

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
            UserValues.BurstBrowser.Corrections.Background_GGpar;...
            UserValues.BurstBrowser.Corrections.Background_GGperp;...
            UserValues.BurstBrowser.Corrections.Background_GRpar;...
            UserValues.BurstBrowser.Corrections.Background_GRperp;...
            UserValues.BurstBrowser.Corrections.Background_RRpar;...
            UserValues.BurstBrowser.Corrections.Background_RRperp;...
            UserValues.BurstBrowser.Corrections.GfactorGreen;...
            UserValues.BurstBrowser.Corrections.GfactorRed;...
            UserValues.BurstBrowser.Corrections.l1;...
            UserValues.BurstBrowser.Corrections.l2};
    elseif any(BurstData.BAMethod == [1,2]) %%% 2cMFD, same as default
        h.CorrectionsTable.Data = {UserValues.BurstBrowser.Corrections.Gamma_GR;...
            UserValues.BurstBrowser.Corrections.Beta_GR;...
            UserValues.BurstBrowser.Corrections.CrossTalk_GR;...
            UserValues.BurstBrowser.Corrections.DirectExcitation_GR;...
            UserValues.BurstBrowser.Corrections.Background_GGpar;...
            UserValues.BurstBrowser.Corrections.Background_GGperp;...
            UserValues.BurstBrowser.Corrections.Background_GRpar;...
            UserValues.BurstBrowser.Corrections.Background_GRperp;...
            UserValues.BurstBrowser.Corrections.Background_RRpar;...
            UserValues.BurstBrowser.Corrections.Background_RRperp;...
            UserValues.BurstBrowser.Corrections.GfactorGreen;...
            UserValues.BurstBrowser.Corrections.GfactorRed;...
            UserValues.BurstBrowser.Corrections.l1;...
            UserValues.BurstBrowser.Corrections.l2};
    elseif any(BurstData.BAMethod == [3,4]) %%% 3cMFD
        h.CorrectionsTable.Data = {UserValues.BurstBrowser.Corrections.Gamma_GR;...
            UserValues.BurstBrowser.Corrections.Gamma_BG;...
            UserValues.BurstBrowser.Corrections.Gamma_BR;...
            UserValues.BurstBrowser.Corrections.Beta_GR;...
            UserValues.BurstBrowser.Corrections.Beta_BG;...
            UserValues.BurstBrowser.Corrections.Beta_BR;...
            UserValues.BurstBrowser.Corrections.CrossTalk_GR;...
            UserValues.BurstBrowser.Corrections.CrossTalk_BG;...
            UserValues.BurstBrowser.Corrections.CrossTalk_BR;...
            UserValues.BurstBrowser.Corrections.DirectExcitation_GR;...
            UserValues.BurstBrowser.Corrections.DirectExcitation_BG;...
            UserValues.BurstBrowser.Corrections.DirectExcitation_BR;...
            UserValues.BurstBrowser.Corrections.Background_BBpar;...
            UserValues.BurstBrowser.Corrections.Background_BBperp;...
            UserValues.BurstBrowser.Corrections.Background_BGpar;...
            UserValues.BurstBrowser.Corrections.Background_BGperp;...
            UserValues.BurstBrowser.Corrections.Background_BRpar;...
            UserValues.BurstBrowser.Corrections.Background_BRperp;...
            UserValues.BurstBrowser.Corrections.Background_GGpar;...
            UserValues.BurstBrowser.Corrections.Background_GGperp;...
            UserValues.BurstBrowser.Corrections.Background_GRpar;...
            UserValues.BurstBrowser.Corrections.Background_GRperp;...
            UserValues.BurstBrowser.Corrections.Background_RRpar;...
            UserValues.BurstBrowser.Corrections.Background_RRperp;...
            UserValues.BurstBrowser.Corrections.GfactorBlue;...
            UserValues.BurstBrowser.Corrections.GfactorGreen;...
            UserValues.BurstBrowser.Corrections.GfactorRed;...
            UserValues.BurstBrowser.Corrections.l1;...
            UserValues.BurstBrowser.Corrections.l2};
    end
else %%% Update UserValues with new values
    LSUserValues(0);
    switch obj
        case h.CorrectionsTable
            if any(BurstData.BAMethod == [1,2]) %%% 2cMFD
                UserValues.BurstBrowser.Corrections.Gamma_GR = obj.Data{1};
                UserValues.BurstBrowser.Corrections.Beta_GR = obj.Data{2};
                UserValues.BurstBrowser.Corrections.CrossTalk_GR = obj.Data{3};
                UserValues.BurstBrowser.Corrections.DirectExcitation_GR= obj.Data{4};
                UserValues.BurstBrowser.Corrections.Background_GGpar= obj.Data{5};
                UserValues.BurstBrowser.Corrections.Background_GGperp= obj.Data{6};
                UserValues.BurstBrowser.Corrections.Background_GRpar= obj.Data{7};
                UserValues.BurstBrowser.Corrections.Background_GRperp= obj.Data{8};
                UserValues.BurstBrowser.Corrections.Background_RRpar= obj.Data{9};
                UserValues.BurstBrowser.Corrections.Background_RRperp= obj.Data{10};
                UserValues.BurstBrowser.Corrections.GfactorGreen = obj.Data{11};
                UserValues.BurstBrowser.Corrections.GfactorRed = obj.Data{12};
                UserValues.BurstBrowser.Corrections.l1 = obj.Data{13};
                UserValues.BurstBrowser.Corrections.l2 = obj.Data{14};
            elseif any(BurstData.BAMethod == [3,4]) %%% 3cMFD
                UserValues.BurstBrowser.Corrections.Gamma_GR = obj.Data{1};
                UserValues.BurstBrowser.Corrections.Gamma_BG = obj.Data{2};
                UserValues.BurstBrowser.Corrections.Gamma_BR = obj.Data{3};
                UserValues.BurstBrowser.Corrections.Beta_GR = obj.Data{4};
                UserValues.BurstBrowser.Corrections.Beta_BG = obj.Data{5};
                UserValues.BurstBrowser.Corrections.Beta_BR = obj.Data{6};
                UserValues.BurstBrowser.Corrections.CrossTalk_GR = obj.Data{7};
                UserValues.BurstBrowser.Corrections.CrossTalk_BG = obj.Data{8};
                UserValues.BurstBrowser.Corrections.CrossTalk_BR = obj.Data{9};
                UserValues.BurstBrowser.Corrections.DirectExcitation_GR= obj.Data{10};
                UserValues.BurstBrowser.Corrections.DirectExcitation_BG= obj.Data{11};
                UserValues.BurstBrowser.Corrections.DirectExcitation_BR= obj.Data{12};
                UserValues.BurstBrowser.Corrections.Background_BBpar= obj.Data{13};
                UserValues.BurstBrowser.Corrections.Background_BBperp= obj.Data{14};
                UserValues.BurstBrowser.Corrections.Background_BGpar= obj.Data{15};
                UserValues.BurstBrowser.Corrections.Background_BGperp= obj.Data{16};
                UserValues.BurstBrowser.Corrections.Background_BRpar= obj.Data{17};
                UserValues.BurstBrowser.Corrections.Background_BRperp= obj.Data{18};
                UserValues.BurstBrowser.Corrections.Background_GGpar= obj.Data{19};
                UserValues.BurstBrowser.Corrections.Background_GGperp= obj.Data{20};
                UserValues.BurstBrowser.Corrections.Background_GRpar= obj.Data{21};
                UserValues.BurstBrowser.Corrections.Background_GRperp= obj.Data{22};
                UserValues.BurstBrowser.Corrections.Background_RRpar= obj.Data{23};
                UserValues.BurstBrowser.Corrections.Background_RRperp= obj.Data{24};
                UserValues.BurstBrowser.Corrections.GfactorBlue = obj.Data{25};
                UserValues.BurstBrowser.Corrections.GfactorGreen = obj.Data{26};
                UserValues.BurstBrowser.Corrections.GfactorRed = obj.Data{27};
                UserValues.BurstBrowser.Corrections.l1 = obj.Data{28};
                UserValues.BurstBrowser.Corrections.l2 = obj.Data{29};
            end
        case h.DonorLifetimeEdit
            if ~isnan(str2double(h.DonorLifetimeEdit.String))
                UserValues.BurstBrowser.Corrections.DonorLifetime = str2double(h.DonorLifetimeEdit.String);
            else %%% Reset value
                h.DonorLifetimeEdit.String = num2str(UserValues.BurstBrowser.Corrections.DonorLifetime);
            end
        case h.AcceptorLifetimeEdit
            if ~isnan(str2double(h.AcceptorLifetimeEdit.String))
                UserValues.BurstBrowser.Corrections.AcceptorLifetime = str2double(h.AcceptorLifetimeEdit.String);
            else %%% Reset value
                h.AcceptorLifetimeEdit.String = num2str(UserValues.BurstBrowser.Corrections.AcceptorLifetime);
            end
        case h.DonorLifetimeBlueEdit
            if ~isnan(str2double(h.DonorLifetimeBlueEdit.String))
                UserValues.BurstBrowser.Corrections.DonorLifetimeBlue = str2double(h.DonorLifetimeBlueEdit.String);
            else %%% Reset value
                h.DonorLifetimeBlueEdit.String = num2str(UserValues.BurstBrowser.Corrections.DonorLifetimeBlue);
            end
        case h.FoersterRadiusEdit
            if ~isnan(str2double(h.FoersterRadiusEdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadius = str2double(h.FoersterRadiusEdit.String);
            else %%% Reset value
                h.FoersterRadiusEdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadius);
            end
        case h.LinkerLengthEdit
            if ~isnan(str2double(h.LinkerLengthEdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLength = str2double(h.LinkerLengthEdit.String);
            else %%% Reset value
                h.LinkerLengthEdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLength);
            end
        case h.FoersterRadiusBGEdit
            if ~isnan(str2double(h.FoersterRadiusBGEdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadiusBG = str2double(h.FoersterRadiusBGEdit.String);
            else %%% Reset value
                h.FoersterRadiusBGEdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadiusBG);
            end
        case h.LinkerLengthBGEdit
            if ~isnan(str2double(h.LinkerLengthBGEdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLengthBG = str2double(h.LinkerLengthBGEdit.String);
            else %%% Reset value
                h.LinkerLengthBGEdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLengthBG);
            end
        case h.FoersterRadiusBREdit
            if ~isnan(str2double(h.FoersterRadiusBREdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadiusBR = str2double(h.FoersterRadiusBREdit.String);
            else %%% Reset value
                h.FoersterRadiusBREdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadiusBR);
            end
        case h.LinkerLengthBREdit
            if ~isnan(str2double(h.LinkerLengthBREdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLengthBR = str2double(h.LinkerLengthBREdit.String);
            else %%% Reset value
                h.LinkerLengthBREdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLengthBR);
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
gamma_gr = UserValues.BurstBrowser.Corrections.Gamma_GR;
beta_gr = UserValues.BurstBrowser.Corrections.Beta_GR;
ct_gr = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
de_gr = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
BG_GG = UserValues.BurstBrowser.Corrections.Background_GGpar + UserValues.BurstBrowser.Corrections.Background_GGperp;
BG_GR = UserValues.BurstBrowser.Corrections.Background_GRpar + UserValues.BurstBrowser.Corrections.Background_GRperp;
BG_RR = UserValues.BurstBrowser.Corrections.Background_RRpar + UserValues.BurstBrowser.Corrections.Background_RRperp;

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
Ggreen = UserValues.BurstBrowser.Corrections.GfactorGreen;
Gred = UserValues.BurstBrowser.Corrections.GfactorRed;
l1 = UserValues.BurstBrowser.Corrections.l1;
l2 = UserValues.BurstBrowser.Corrections.l2;
BG_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
BG_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
BG_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
BG_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;

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
    gamma_bg = UserValues.BurstBrowser.Corrections.Gamma_BG;
    beta_bg = UserValues.BurstBrowser.Corrections.Beta_BG;
    gamma_br = UserValues.BurstBrowser.Corrections.Gamma_BR;
    beta_br = UserValues.BurstBrowser.Corrections.Beta_BR;
    ct_bg = UserValues.BurstBrowser.Corrections.CrossTalk_BG;
    de_bg = UserValues.BurstBrowser.Corrections.DirectExcitation_BG;
    ct_br = UserValues.BurstBrowser.Corrections.CrossTalk_BR;
    de_br = UserValues.BurstBrowser.Corrections.DirectExcitation_BR;
    BG_BB = UserValues.BurstBrowser.Corrections.Background_BBpar + UserValues.BurstBrowser.Corrections.Background_BBperp;
    BG_BG = UserValues.BurstBrowser.Corrections.Background_BGpar + UserValues.BurstBrowser.Corrections.Background_BGperp;
    BG_BR = UserValues.BurstBrowser.Corrections.Background_BRpar + UserValues.BurstBrowser.Corrections.Background_BRperp;

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
    E1A = (gamma_gr.*NBG + NBR)./(gamma_br.*NBB + gamma_gr.*NGG + NBR);
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
    Gblue = UserValues.BurstBrowser.Corrections.GfactorBlue;
    BG_BBpar = UserValues.BurstBrowser.Corrections.Background_BBpar;
    BG_BBperp = UserValues.BurstBrowser.Corrections.Background_BBperp;

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
global UserValues BurstMeta
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
BurstMeta.Plots.gamma_fit(2).LevelList = linspace(0.1,1,10);
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


%%% Save UserValues
LSUserValues(1);
%%% Update Correction Table Data
UpdateCorrections([],[]);
%%% Apply Corrections
ApplyCorrections;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Saves the state of the analysis to the .bur file %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Save_Analysis_State_Callback(~,~)
global BurstData

save(BurstData.FileName,'BurstData');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates lifetime-related plots in Lifetime Tab %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateLifetimePlots(~,~)
global BurstData BurstMeta
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
[H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauGG), datatoplot(:,idxE),[51 51], [0 5], [0 1]);
BurstMeta.Plots.EvsTauGG(1).XData = xbins;
BurstMeta.Plots.EvsTauGG(1).YData = ybins;
BurstMeta.Plots.EvsTauGG(1).CData = H;
BurstMeta.Plots.EvsTauGG(1).AlphaData = (H>0);
BurstMeta.Plots.EvsTauGG(2).XData = xbins;
BurstMeta.Plots.EvsTauGG(2).YData = ybins;
BurstMeta.Plots.EvsTauGG(2).ZData = H/max(max(H));
BurstMeta.Plots.EvsTauGG(2).LevelList = linspace(0.1,1,10);
axis(h.axes_EvsTauGG,'tight');
ylim(h.axes_EvsTauGG,[0 1]);
if strcmp(BurstMeta.Plots.Fits.staticFRET_EvsTauGG.Visible,'on')
    %%% replot the static FRET line
    UpdateLifetimeFits(h.PlotStaticFRETButton,[]);
end
%% Plot E vs. tauRR in second plot
[H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauRR), datatoplot(:,idxE),[51 51], [0 6], [0 1]);
BurstMeta.Plots.EvsTauRR(1).XData = xbins;
BurstMeta.Plots.EvsTauRR(1).YData = ybins;
BurstMeta.Plots.EvsTauRR(1).CData = H;
BurstMeta.Plots.EvsTauRR(1).AlphaData = (H>0);
BurstMeta.Plots.EvsTauRR(2).XData = xbins;
BurstMeta.Plots.EvsTauRR(2).YData = ybins;
BurstMeta.Plots.EvsTauRR(2).ZData = H/max(max(H));
BurstMeta.Plots.EvsTauRR(2).LevelList = linspace(0.1,1,10);
ylim(h.axes_EvsTauRR,[0 1]);
axis(h.axes_EvsTauRR,'tight');
%% Plot rGG vs. tauGG in third plot
[H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauGG), datatoplot(:,idx_rGG),[51 51], [0 5], [-0.1 0.5]);
BurstMeta.Plots.rGGvsTauGG(1).XData = xbins;
BurstMeta.Plots.rGGvsTauGG(1).YData = ybins;
BurstMeta.Plots.rGGvsTauGG(1).CData = H;
BurstMeta.Plots.rGGvsTauGG(1).AlphaData = (H>0);
BurstMeta.Plots.rGGvsTauGG(2).XData = xbins;
BurstMeta.Plots.rGGvsTauGG(2).YData = ybins;
BurstMeta.Plots.rGGvsTauGG(2).ZData = H/max(max(H));
BurstMeta.Plots.rGGvsTauGG(2).LevelList = linspace(0.1,1,10);
axis(h.axes_rGGvsTauGG,'tight');
%% Plot rRR vs. tauRR in third plot
[H, xbins, ybins] = calc2dhist(datatoplot(:,idx_tauRR), datatoplot(:,idx_rRR),[51 51], [0 6], [-0.1 0.5]);
BurstMeta.Plots.rRRvsTauRR(1).XData = xbins;
BurstMeta.Plots.rRRvsTauRR(1).YData = ybins;
BurstMeta.Plots.rRRvsTauRR(1).CData = H;
BurstMeta.Plots.rRRvsTauRR(1).AlphaData = (H>0);
BurstMeta.Plots.rRRvsTauRR(2).XData = xbins;
BurstMeta.Plots.rRRvsTauRR(2).YData = ybins;
BurstMeta.Plots.rRRvsTauRR(2).ZData = H/max(max(H));
BurstMeta.Plots.rRRvsTauRR(2).LevelList = linspace(0.1,1,10);
axis(h.axes_rRRvsTauRR,'tight');
%% 3cMFD
if any(BurstData.BAMethod == [3,4])
    idx_tauBB = strcmp('Lifetime BB [ns]',BurstData.NameArray);
    idx_rBB = strcmp('Anisotropy BB',BurstData.NameArray);
    idxE1A = strcmp('Efficiency B->G+R',BurstData.NameArray);
    %% Plot E1A vs. tauBB
    valid = (datatoplot(:,idx_tauBB) > 0.01);
    [H, xbins, ybins] = calc2dhist(datatoplot(valid,idx_tauBB), datatoplot(valid,idxE1A),[51 51], [0 5], [0 1]);
    BurstMeta.Plots.E_BtoGRvsTauBB(1).XData = xbins;
    BurstMeta.Plots.E_BtoGRvsTauBB(1).YData = ybins;
    BurstMeta.Plots.E_BtoGRvsTauBB(1).CData = H;
    BurstMeta.Plots.E_BtoGRvsTauBB(1).AlphaData = (H>0);
    BurstMeta.Plots.E_BtoGRvsTauBB(2).XData = xbins;
    BurstMeta.Plots.E_BtoGRvsTauBB(2).YData = ybins;
    BurstMeta.Plots.E_BtoGRvsTauBB(2).ZData = H/max(max(H));
    BurstMeta.Plots.E_BtoGRvsTauBB(2).LevelList = linspace(0.1,1,10);
    axis(h.axes_E_BtoGRvsTauBB,'tight');
    ylim(h.axes_E_BtoGRvsTauBB,[0 1]);
    if strcmp(BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.Visible,'on')
        %%% replot the static FRET line
        UpdateLifetimeFits(h.PlotStaticFRETButton,[]);
    end
    %% Plot rBB vs tauBB
    [H, xbins, ybins] = calc2dhist(datatoplot(valid,idx_tauBB), datatoplot(valid,idx_rBB),[51 51], [0 6], [-0.1 0.5]);
    BurstMeta.Plots.rBBvsTauBB(1).XData = xbins;
    BurstMeta.Plots.rBBvsTauBB(1).YData = ybins;
    BurstMeta.Plots.rBBvsTauBB(1).CData = H;
    BurstMeta.Plots.rBBvsTauBB(1).AlphaData = (H>0);
    BurstMeta.Plots.rBBvsTauBB(2).XData = xbins;
    BurstMeta.Plots.rBBvsTauBB(2).YData = ybins;
    BurstMeta.Plots.rBBvsTauBB(2).ZData = H/max(max(H));
    BurstMeta.Plots.rBBvsTauBB(2).LevelList = linspace(0.1,1,10);
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
    staticFRETline = conversion_tau(UserValues.BurstBrowser.Corrections.DonorLifetime,...
        UserValues.BurstBrowser.Corrections.FoersterRadius,UserValues.BurstBrowser.Corrections.LinkerLength,...
        tau);
    BurstMeta.Plots.Fits.staticFRET_EvsTauGG.Visible = 'on';
    BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData = tau;
    BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData = staticFRETline;
    if any(BurstData.BAMethod == [3,4])
        %%% Calculate static FRET line in presence of linker fluctuations
        tau = linspace(h.axes_E_BtoGRvsTauBB.XLim(1),h.axes_E_BtoGRvsTauBB.XLim(2),100);
        staticFRETline = conversion_tau_3C(UserValues.BurstBrowser.Corrections.DonorLifetimeBlue,...
            UserValues.BurstBrowser.Corrections.FoersterRadiusBG,UserValues.BurstBrowser.Corrections.FoersterRadiusBR,...
            UserValues.BurstBrowser.Corrections.LinkerLengthBG,UserValues.BurstBrowser.Corrections.LinkerLengthBR,...
            tau);
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.Visible = 'on';
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.XData = tau;
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.YData = staticFRETline;
    end
end
if obj == h.FitAnisotropyButton
    %% Add Perrin Fits to Anisotropy Plot
    %% GG
    r0 = 0.4;
    fPerrin = @(rho,x) r0./(1+x./rho); %%% x = tau
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
    r0 = 0.4;
    fPerrin = @(rho,x) r0./(1+x./rho); %%% x = tau
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
        r0 = 0.4;
        fPerrin = @(rho,x) r0./(1+x./rho); %%% x = tau
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
            r0 = 0.4;
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
                    title(['rhoGG = ' num2str(rho)]);
                case h.axes_rRRvsTauRR
                    BurstMeta.Plots.Fits.PerrinRR(1).Visible = 'on';
                    BurstMeta.Plots.Fits.PerrinRR(1).XData = tau;
                    BurstMeta.Plots.Fits.PerrinRR(1).YData = fitPerrin(tau);
                    BurstMeta.Plots.Fits.PerrinRR(2).Visible = 'off';
                    BurstMeta.Plots.Fits.PerrinRR(3).Visible = 'off';
                    title(['rhoRR = ' num2str(rho)]);
                case h.axes_rBBvsTauBB
                    BurstMeta.Plots.Fits.PerrinBB(1).Visible = 'on';
                    BurstMeta.Plots.Fits.PerrinBB(1).XData = tau;
                    BurstMeta.Plots.Fits.PerrinBB(1).YData = fitPerrin(tau);
                    BurstMeta.Plots.Fits.PerrinBB(2).Visible = 'off';
                    BurstMeta.Plots.Fits.PerrinBB(3).Visible = 'off';
                    title(['rhoBB = ' num2str(rho)]);
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
                r0 = 0.4;
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
            end
        elseif haxes == h.axes_rRRvsTauRR
            %%% Check for visibility of plots
            vis = 0;
            for i = 1:3
                vis = vis + strcmp(BurstMeta.Plots.Fits.PerrinRR(i).Visible,'on');
            end
            if vis < 3
                %%% Determine rho
                r0 = 0.4;
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
            end
        elseif haxes == h.axes_rBBvsTauBB
             %%% Check for visibility of plots
            vis = 0;
            for i = 1:3
                vis = vis + strcmp(BurstMeta.Plots.Fits.PerrinBB(i).Visible,'on');
            end
            if vis < 3
                %%% Determine rho
                r0 = 0.4;
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
    %%% Determine Donor Only lifetime from data with S > 0.98
    idx_tauGG = strcmp(BurstData.NameArray,'Lifetime GG [ns]');
    idxS = BurstMeta.posS;
    if any(BurstData.BAMethod == [1,2])
        valid = (BurstData.DataArray(:,idxS) > 0.98);
    elseif any(BurstData.BAMethod == [3,4])
        idxSBG = strcmp(BurstData.NameArray,'Stoichiometry BG');
        valid = (BurstData.DataArray(:,idxS) > 0.90) & (BurstData.DataArray(:,idxS) < 1.1) &...
            (BurstData.DataArray(:,idxSBG) > 0) & (BurstData.DataArray(:,idxSBG) < 0.1);
    end
    %DonorOnlyLifetime = mean(BurstData.DataArray(valid,idx_tauGG));
    x_axis = 0:0.05:10;
    htauGG = histc(BurstData.DataArray(valid,idx_tauGG),x_axis);
    [DonorOnlyLifetime, ~] = GaussianFit(x_axis',htauGG,1);
    %%% Update GUI
    h.DonorLifetimeEdit.String = num2str(DonorOnlyLifetime);
    h.DonorLifetimeEdit.Enable = 'off';
    UserValues.BurstBrowser.Corrections.DonorLifetime = DonorOnlyLifetime;
    
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
    end
    LSUserValues(1);
else
    h.DonorLifetimeEdit.Enable = 'on';
    h.DonorLifetimeBlueEdit.Enable = 'on';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates static FRET line with Linker Dynamics %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, coefficients] = conversion_tau(tauD,R0,s,xval)
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

coefficients = polyfit(tauf,taux,3);

out = 1- ( coefficients(1).*xval.^3 + coefficients(2).*xval.^2 + coefficients(3).*xval + coefficients(4) )./tauD;
function [out, coefficients] = conversion_tau_3C(tauD,R0BG,R0BR,sBG,sBR,xval)
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

coefficients = polyfit(tauf,taux,3);

out = 1- ( coefficients(1).*xval.^3 + coefficients(2).*xval.^2 + coefficients(3).*xval + coefficients(4) )./tauD;
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
Background_GR = UserValues.BurstBrowser.Corrections.Background_GRpar + UserValues.BurstBrowser.Corrections.Background_GRperp;
Background_GG = UserValues.BurstBrowser.Corrections.Background_GGpar + UserValues.BurstBrowser.Corrections.Background_GGperp;
Background_RR = UserValues.BurstBrowser.Corrections.Background_RRpar + UserValues.BurstBrowser.Corrections.Background_RRperp;

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
NGR = NGR - UserValues.BurstBrowser.Corrections.DirectExcitation_GR.*NRR - UserValues.BurstBrowser.Corrections.CrossTalk_GR.*NGG;

if obj == h.DetermineGammaLifetimeTwoColorButton
    %%% Calculate static FRET line in presence of linker fluctuations
    tau = linspace(0,5,100);
    [~, coeff] = conversion_tau(UserValues.BurstBrowser.Corrections.DonorLifetime,...
        UserValues.BurstBrowser.Corrections.FoersterRadius,UserValues.BurstBrowser.Corrections.LinkerLength,...
        tau);
    staticFRETline = @(x) 1 - (coeff(1).*x.^3 + coeff(2).*x.^2 + coeff(3).*x + coeff(4))./UserValues.BurstBrowser.Corrections.DonorLifetime;
    %%% minimize deviation from static FRET line as a function of gamma
    tauGG = data_for_corrections(S_threshold,indTauGG);
    dev = @(gamma) sum( ( ( NGR(~isnan(tauGG))./(gamma.*NGG(~isnan(tauGG))+NGR(~isnan(tauGG))) ) - staticFRETline( tauGG(~isnan(tauGG)) ) ).^2 );
    gamma_fit = fmincon(dev,1,[],[],[],[],0,10);
    E =  NGR./(gamma_fit.*NGG+NGR);
    %%% plot E versus tau with static FRET line
    [H,xbins,ybins] = calc2dhist(data_for_corrections(S_threshold,indTauGG),E,[51 51],[0 5],[-0.1 1]);
    BurstMeta.Plots.gamma_lifetime(1).XData= xbins;
    BurstMeta.Plots.gamma_lifetime(1).YData= ybins;
    BurstMeta.Plots.gamma_lifetime(1).CData= H;
    BurstMeta.Plots.gamma_lifetime(1).AlphaData= (H>0);
    BurstMeta.Plots.gamma_lifetime(2).XData= xbins;
    BurstMeta.Plots.gamma_lifetime(2).YData= ybins;
    BurstMeta.Plots.gamma_lifetime(2).ZData= H/max(max(H));
    BurstMeta.Plots.gamma_lifetime(2).LevelList= linspace(0.1,1,10);
    %%% add static FRET line
    tau = linspace(h.Corrections.TwoCMFD.axes_gamma_lifetime.XLim(1),h.Corrections.TwoCMFD.axes_gamma_lifetime.XLim(2),100);
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.Visible = 'on';
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.XData = tau;
    BurstMeta.Plots.Fits.staticFRET_gamma_lifetime.YData = staticFRETline(tau);
    ylim(h.Corrections.TwoCMFD.axes_gamma_lifetime,[-0.1,1]);
    %%% Update UserValues
    UserValues.BurstBrowser.Corrections.Gamma_GR =gamma_fit;
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
        Background_BB = UserValues.BurstBrowser.Corrections.Background_BBpar + UserValues.BurstBrowser.Corrections.Background_BBperp;
        Background_BG = UserValues.BurstBrowser.Corrections.Background_BGpar + UserValues.BurstBrowser.Corrections.Background_BGperp;
        Background_BR = UserValues.BurstBrowser.Corrections.Background_BRpar + UserValues.BurstBrowser.Corrections.Background_BRperp;

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
        NGR = NGR - UserValues.BurstBrowser.Corrections.DirectExcitation_GR.*NRR - UserValues.BurstBrowser.Corrections.CrossTalk_GR.*NGG;
        gamma_gr = UserValues.BurstBrowser.Corrections.Gamma_GR;
        EGR = NGR./(gamma_gr.*NGG+NGR);
        NBR = NBR - UserValues.BurstBrowser.Corrections.DirectExcitation_BR.*NRR - UserValues.BurstBrowser.Corrections.CrossTalk_BR.*NBB -...
            UserValues.BurstBrowser.Corrections.CrossTalk_GR.*(NBG-UserValues.BurstBrowser.Corrections.CrossTalk_BG.*NBB) -...
            UserValues.BurstBrowser.Corrections.DirectExcitation_BG*(EGR./(1-EGR)).*NGG;
        NBG = NBG - UserValues.BurstBrowser.Corrections.DirectExcitation_BG.*NGG - UserValues.BurstBrowser.Corrections.CrossTalk_BG.*NBB;
        %%% Calculate static FRET line in presence of linker fluctuations
        tau = linspace(0,5,100);
        [~, coeff] = conversion_tau_3C(UserValues.BurstBrowser.Corrections.DonorLifetimeBlue,...
            UserValues.BurstBrowser.Corrections.FoersterRadiusBG,UserValues.BurstBrowser.Corrections.FoersterRadiusBR,...
            UserValues.BurstBrowser.Corrections.LinkerLengthBG,UserValues.BurstBrowser.Corrections.LinkerLengthBR,...
            tau);
        staticFRETline = @(x) 1 - (coeff(1).*x.^3 + coeff(2).*x.^2 + coeff(3).*x + coeff(4))./UserValues.BurstBrowser.Corrections.DonorLifetimeBlue;
        tauBB = data_for_corrections(S_threshold,indTauBB);
        %%% minimize deviation from static FRET line as a function of gamma_br!
        valid = (~isnan(tauBB));
        dev = @(gamma) sum( ( ( (gamma_gr.*NBG(valid)+NBR(valid))./(gamma.*NBB(valid) + gamma_gr.*NBG(valid) + NBR(valid)) ) - staticFRETline( tauBB(valid) ) ).^2 );
        gamma_fit = fmincon(dev,1,[],[],[],[],0,10);
        E1A =  (gamma_gr.*NBG+NBR)./(gamma_fit.*NBB + gamma_gr.*NBG + NBR);
        %%% plot E versus tau with static FRET line
        [H,xbins,ybins] = calc2dhist(data_for_corrections(S_threshold,indTauBB),E1A,[51 51],[0 5],[-0.1 1]);
        BurstMeta.Plots.gamma_threecolor_lifetime(1).XData= xbins;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).YData= ybins;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).CData= H;
        BurstMeta.Plots.gamma_threecolor_lifetime(1).AlphaData= (H>0);
        BurstMeta.Plots.gamma_threecolor_lifetime(2).XData= xbins;
        BurstMeta.Plots.gamma_threecolor_lifetime(2).YData= ybins;
        BurstMeta.Plots.gamma_threecolor_lifetime(2).ZData= H/max(max(H));
        BurstMeta.Plots.gamma_threecolor_lifetime(2).LevelList= linspace(0.1,1,10);
        %%% add static FRET line
        tau = linspace(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime.XLim(1),h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime.XLim(2),100);
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.Visible = 'on';
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.XData = tau;
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime.YData = staticFRETline(tau);
        ylim(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,[-0.1,1]);
        %%% Update UserValues
        UserValues.BurstBrowser.Corrections.Gamma_BR =gamma_fit;
        UserValues.BurstBrowser.Corrections.Gamma_BG = UserValues.BurstBrowser.Corrections.Gamma_BR./UserValues.BurstBrowser.Corrections.Gamma_GR;
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
global BurstData BurstTCSPCData
h = guidata(obj);
%%% Set Up Progress Bar
h_waitbar = waitbar(0,'Correlating...');
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData)
    waitbar(0,h_waitbar,'Loading Photon Data');
    load('-mat',[BurstData.FileName(1:end-3) 'bps']);
    BurstTCSPCData.Macrotime = Macrotime;
    BurstTCSPCData.Microtime = Microtime;
    BurstTCSPCData.Channel = Channel;
    clear Macrotime Microtime Channel
    waitbar(0,h_waitbar,'Correlating');
end
%%% find selected bursts
MT = BurstTCSPCData.Macrotime(BurstData.Selected);
MT = vertcat(MT{:});
CH = BurstTCSPCData.Channel(BurstData.Selected);
CH = vertcat(CH{:});

%%% Read out the species name
if (BurstData.SelectedSpecies == 1)
    species = 'global';
else
    species = BurstData.SpeciesNames{BurstData.SelectedSpecies};
end
%%% define channels
Chan = {1,2,3,4,5,6,[1 2],[3 4],[1 2 3 4],[5 6]};
Name = {'GG1','GG2','GR1','GR2','RR1','RR2','GG','GR','GX','RR'};
CorrMat = h.Correlation_Table.Data;
NumChans = size(CorrMat,1);
NCor = sum(sum(CorrMat));
count = 0;
for i=1:NumChans
    for j=1:NumChans
        if CorrMat(i,j)
            MT1 = MT(ismember(CH,Chan{i}));
            MT2 = MT(ismember(CH,Chan{j}));
            %%% Split Data in 10 time bins for errorbar calculation
            Times = ceil(linspace(0,max([MT1;MT2]),11));
            %%% Calculates the maximum inter-photon time in clock ticks
            Maxtime=max(diff(Times));
            Data1 = cell(10,1);
            Data2 = cell(10,1);
            for k = 1:10
                Data1{k} = MT1( MT1 > Times(k) &...
                    MT1 <= Times(k+1)) - Times(k);
                Data2{k} = MT2( MT2 > Times(k) &...
                    MT2 <= Times(k+1)) - Times(k);
            end
            %%% Do Correlation
            [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data2,Maxtime);
            Cor_Times=Cor_Times*BurstData.SyncPeriod;
            %%% Calculates average and standard error of mean (without tinv_table yet
            if numel(Cor_Array)>1
                Cor_Average=mean(Cor_Array,2);
                %Cor_SEM=std(Cor_Array,0,2)/sqrt(size(Cor_Array,2));
                %%% Averages files before saving to reduce errorbars
                Amplitude=sum(Cor_Array,1);
                Cor_Norm=Cor_Array./repmat(Amplitude,[size(Cor_Array,1),1])*mean(Amplitude);
                Cor_SEM=std(Cor_Norm,0,2)/sqrt(size(Cor_Array,2));

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
            Counts = [numel(MT1) numel(MT2)]/(BurstData.SyncPeriod*max([MT1;MT2]))/1000;
            Valid = 1:10;
            save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
            count = count+1;waitbar(count/NCor);
        end 
    end
end
delete(h_waitbar);
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
    %%% to keep the order of tabs, one first has to move Lifetime and fFCS
    %%% tabs to the Hide_Panel
    h.Main_Tab_Lifetime.Parent = h.Hide_Tab;
    h.Main_Tab_fFCS.Parent = h.Hide_Tab;
    %%% Then move the three-color Corrections Tab to Main Panel
    h.Main_Tab_Corrections_ThreeCMFD.Parent = h.Main_Tab;
    %%% Then add again the other tabs in correct order
    h.Main_Tab_Lifetime.Parent = h.Main_Tab;
    h.Main_Tab_fFCS.Parent = h.Main_Tab;
    %% Change correction table
    Corrections_Rownames = {'Gamma GR','Gamma BG','Gamma BR','Beta GR','Beta BG','Beta BR',...
        'Crosstalk GR','Crosstalk BG','Crosstalk BR','Direct Exc. GR','Direct Exc. BG','Direct Exc. BR',...
        'BG BB par','BG BB perp','BG BG par','BG BG perp','BG BR par','BG BR perp',...
        'BG GG par','BG GG perp','BG GR par','BG GR perp','BG RR par','BG RR perp',...
        'G factor blue','G factor Green','G factor Red','l1','l2'};
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
    %% Change Lifetime GUI
    %%% Make 3C-Plots visible
    h.axes_E_BtoGRvsTauBB.Parent = h.MainTabLifetimePanel;
    h.axes_rBBvsTauBB.Parent = h.MainTabLifetimePanel;
    %%% Change Position of 2Color-Plots
    h.axes_EvsTauGG.Position = [0.05 0.55 (0.8/3) 0.4];
    h.axes_EvsTauRR.Position = [(0.1+0.8/3) 0.55 (0.8/3) 0.4];
    h.axes_rGGvsTauGG.Position = [0.05 0.05 (0.8/3) 0.4];
    h.axes_rRRvsTauRR.Position = [(0.1+0.8/3) 0.05 (0.8/3) 0.4];
elseif BAMethod == 2
    %%% move the three-color Corrections Tab to the Hide_Tab
    h.Main_Tab_Corrections_ThreeCMFD.Parent = h.Hide_Tab;
    %%% reset Corrections Table
    Corrections_Rownames = {'Gamma','Beta','Crosstalk','Direct Exc.','BG GG par','BG GG perp','BG GR par',...
        'BG GR perp','BG RR par','BG RR perp','G factor Green','G factor Red','l1','l2'};
    Corrections_Data = {1;1;0;0;0;0;0:0;0;0;1;1;0};
    %%% Hide 3cMFD corrections
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
    %%% Reset Lifetime Plots
     %%% Make 3C-Plots invisible
    h.axes_E_BtoGRvsTauBB.Parent = h.Hide_Stuff;
    h.axes_rBBvsTauBB.Parent =  h.Hide_Stuff;
    %%% Change Position of 2Color-Plots
    h.axes_EvsTauGG.Position = [0.05 0.55 0.4 0.4];
    h.axes_EvsTauRR.Position = [0.55 0.55 0.4 0.4];
    h.axes_rGGvsTauGG.Position = [0.05 0.05 0.4 0.4];
    h.axes_rRRvsTauRR.Position = [0.55 0.05 0.4 0.4];
end
h.CorrectionsTable.RowName = Corrections_Rownames;
h.CorrectionsTable.Data = Corrections_Data;
%%% Update CorrectionsTable with UserValues-stored Data
UpdateCorrections([],[])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% General Functions for plotting 2d-Histogram of data %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [H,xbins,ybins,xbins_hist,ybins_hist] = calc2dhist(x,y,nbins,limx,limy,haxes)
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
%%% set axes
if nargin == 6
    axes(haxes);
end
valid = (x >= limx(1)) & (x <= limx(2)) & (y >= limy(1)) & (y <= limy(2));
x = x(valid);
y = y(valid);
[H, xbins_hist, ybins_hist] = hist2d([x y], nbins(1), nbins(2), limx, limy);
H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
H(end-1,:) = H(end-1,:) + H(end,:); H(end,:) = [];
xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;

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