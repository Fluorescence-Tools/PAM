function Output = Pam (SubFunction)
global UserValues FileInfo PamMeta TcspcData
h.Pam=findobj('Tag','Pam');

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Disables negative values for log plot warning
    warning('off','MATLAB:Axes:NegativeDataInLogAxis');
    %%% Loads user profile    
    Profiles=LSUserValues(0);
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
        'CloseRequestFcn',@Close_Pam,...
        'Visible','on');  
    %h.Pam.Visible='off';
    
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
    h.File = uimenu(...
        'Parent',h.Pam,...
        'Tag','File',...
        'Label','File');

    h.Loadtcspc = uimenu(...
        'Parent', h.File,...
        'Tag','LoadTcspc',...
        'Label','Load Tcspc Data',...
        'Callback',{@LoadTcspc,@Update_Data,@Update_Display,@Shift_Detector,h.Pam});
    h.Database.Add = uimenu(...
        'Parent', h.File,...
        'Tag','Database_Add',...
        'Label','Add Tcspc Files to Database',...
        'Callback',{@Database,1});
    h.Export.Add = uimenu(...
        'Parent', h.File,...
        'Tag','Export_Add',...
        'Label','Add Tcspc Files to Export Database',...
        'Callback',{@Export_Database,1});
    
    h.AdvancedAnalysis_Menu = uimenu(...
        'Parent',h.Pam,...
        'Tag','AdvancedAnalysis',...
        'Label','Advanced Analysis');
    
    h.OpenFCSFit_Menu = uimenu(...
        'Parent', h.AdvancedAnalysis_Menu,...
        'Tag','OpenFCSFit',...
        'Label','FCSFit',...
        'Callback',@FCSFit);
    h.OpenMIAFit_Menu = uimenu(...
        'Parent', h.AdvancedAnalysis_Menu,...
        'Tag','OpenMIAFit',...
        'Label','MIAFit',...
        'Callback',@MIAFit);
    h.OpenTauFit_Menu = uimenu(...
        'Parent', h.AdvancedAnalysis_Menu,...
        'Tag','OpenTauFit',...
        'Label','TauFit',...
        'Callback',@TauFit);
    h.OpenBurstBrowser_Menu = uimenu(...
        'Parent', h.AdvancedAnalysis_Menu,...
        'Separator','on',...
        'Tag','OpenBurstBrowser',...
        'Label','BurstBrowser',...
        'Callback',@BurstBrowser);
    h.OpenPDA_Menu = uimenu(...
        'Parent', h.AdvancedAnalysis_Menu,...
        'Tag','OpenPDA',...
        'Label','PDAFit',...
        'Callback',@GlobalPDAFit);
    h.OpenMia_Menu = uimenu(...
        'Parent', h.AdvancedAnalysis_Menu,...
        'Tag','OpenMia',...
        'Label','MIA',...
        'Callback',@Mia);
    h.OpenPhasor_Menu = uimenu(...
        'Parent', h.AdvancedAnalysis_Menu,...
        'Tag','OpenPhasor',...
        'Label','Phasor',...
        'Callback',@Phasor);
    h.OpenPhasorTIFF_Menu = uimenu(...
        'Parent', h.AdvancedAnalysis_Menu,...
        'Tag','OpenPhasorTIFF',...
        'Label','PhasorTIFF',...
        'Callback',@PhasorTIFF);
    h.OpenPCF_Menu = uimenu(...
        'Parent', h.AdvancedAnalysis_Menu,...
        'Tag','OpenPCF',...
        'Label','PCF Analysis',...
        'Callback',@PCFAnalysis);
    h.SaveIRF_Menu = uimenu(...
        'Parent', h.AdvancedAnalysis_Menu,...
        'Separator','on',...
        'Tag','SaveIRF_Menu',...
        'Label','Save Measurement as IRF for all PIE Channels',...
        'Callback',@SaveIRF);
    h.SaveScatter_Menu = uimenu(...
        'Parent', h.AdvancedAnalysis_Menu,...
        'Tag','SaveScatter_Menu',...
        'Label','Save Measurement as Scatter/Background',...
        'Callback',@SaveScatter);
    
    
    h.Extras_Menu = uimenu(...
        'Parent',h.Pam,...
        'Tag','Extras',...
        'Label','Extras');
    h.Look_Menu = uimenu(...
        'Parent', h.Extras_Menu,...
        'Tag','Look_Menu',...
        'Label','Adjust Pam Look',...
        'Callback',@LookSetup);
    h.Manual_Menu = uimenu(...
        'Parent', h.Extras_Menu,...
        'Tag','Manual_Menu',...
        'Label','Pam Manual (not enabled yet)');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Progressbar and file name %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Panel for progressbar
    h.Progress_Panel = uibuttongroup(...
        'Parent',h.Pam,...
        'Tag','Progress_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0.01 0.96 0.485 0.03]);
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
%% Detector tabs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Microtime tabs container
    h.Det_Tabs = uitabgroup(...
        'Parent',h.Pam,...
        'Tag','Det_Tabs',...
        'Units','normalized',...
        'Position',[0.505 0.01 0.485 0.98]);    
    %% Plot and functions for microtimes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Microtime tab
    h.MI_Tab= uitab(...
        'Parent',h.Det_Tabs,...
        'Tag','MI_Tab',...
        'Title','Microtimes');     
    %%% Microtime tabs container
    h.MI_Tabs = uitabgroup(...
        'Parent',h.MI_Tab,...
        'Tag','MI_Tabs',...
        'Units','normalized',...
        'Position',[0 0 1 1]);    
    %%% All microtime tab
    h.MI_All_Tab= uitab(...
        'Parent',h.MI_Tabs,...
        'Tag','MI_All_Tab',...
        'Title','All');
    %%% All microtime panel
    h.MI_All_Panel = uibuttongroup(...
        'Parent',h.MI_All_Tab,...
        'Tag','MI_All_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);    
    %%% Contexmenu for all microtime axes
    h.MI_Menu = uicontextmenu;
    %%% Menu for Log scal plotting
    h.MI_Log = uimenu(...
        'Parent',h.MI_Menu,...
        'Label','Plot as log scale',...
        'Tag','MI_Log',...
        'Checked',UserValues.Settings.Pam.PlotLog,...
        'Callback',@Calculate_Settings);
    %%% Contextmenu for individual microtime axes
    h.MI_Menu_Individual = uicontextmenu;
    %%% Menu for Log scal plotting
    h.MI_Log_Ind = uimenu(...
        'Parent',h.MI_Menu_Individual,...
        'Label','Plot as log scale',...
        'Tag','MI_Log',...
        'Checked',UserValues.Settings.Pam.PlotLog,...
        'Callback',@Calculate_Settings);
    %%% Menu for Enabling/Disabling IRF Plotting
    h.MI_IRF = uimenu(...
        'Parent',h.MI_Menu_Individual,...
        'Label','Plot IRF',...
        'Separator','on',...
        'Tag','MI_IRF',...
        'Checked',UserValues.Settings.Pam.PlotIRF,...
        'Callback',@Calculate_Settings);
    %%% Menu for Enabling/Disabling Scatter Pattern Plotting
    h.MI_ScatterPattern = uimenu(...
        'Parent',h.MI_Menu_Individual,...
        'Label','Plot Scatter Pattern',...
        'Tag','MI_ScatterPattern',...
        'Checked',UserValues.Settings.Pam.PlotScat,...
        'Callback',@Calculate_Settings);
    %%% All microtime axes
    h.MI_All_Axes = axes(...
        'Parent',h.MI_All_Panel,...
        'Tag','MI_All_Axes',...
        'Units','normalized',...
        'NextPlot','add',...
        'UIContextMenu',h.MI_Menu,...        
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Position',[0.09 0.05 0.89 0.93],...
        'Box','on');
    h.MI_All_Axes.XLabel.String='TAC channel';
    h.MI_All_Axes.XLabel.Color=Look.Fore;
    h.MI_All_Axes.YLabel.String='Counts';
    h.MI_All_Axes.YLabel.Color=Look.Fore;
    h.MI_All_Axes.XLim=[1 4096];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% Additional detector functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Aditional detector functions tab
    h.Additional_Tab= uitab(...
        'Parent',h.Det_Tabs,...
        'Tag','Additional_Tab',...
        'Title','Additional'); 
    %%% Microtime tabs container
    h.Additional_Tabs = uitabgroup(...
        'Parent',h.Additional_Tab,...
        'Tag','Additional_Tabs',...
        'Units','normalized',...
        'Position',[0 0 1 1]);  
        %% Plots and navigation for phasor referencing
    %%% Phasor referencing tab    
    h.MI_Phasor_Tab= uitab(...
        'Parent',h.Additional_Tabs,...
        'Tag','MI_Phasor_Tab',...
        'Title','Phasor Referencing'); 
    %%% Phasor referencing panel
    h.MI_Phasor_Panel = uibuttongroup(...
        'Parent',h.MI_Phasor_Tab,...
        'Tag','MI_All_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    %%% Text    
    h.Text{end+1} = uicontrol(...
        'Parent',h.MI_Phasor_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'String','Shift:',...
        'Horizontalalignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.965 0.06 0.025]);
    %%% Editbox for showing and setting shift
    h.MI_Phasor_Shift = uicontrol(...
        'Parent',h.MI_Phasor_Panel,...
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
    h.MI_Phasor_Slider = uicontrol(...
        'Parent',h.MI_Phasor_Panel,...
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
        'Parent',h.MI_Phasor_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'String','Range to use:',...
        'Horizontalalignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.18 0.965 0.15 0.025]);
    %%% Phasor Range From
    h.MI_Phasor_From = uicontrol(...
        'Parent',h.MI_Phasor_Panel,...
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
    h.MI_Phasor_To = uicontrol(...
        'Parent',h.MI_Phasor_Panel,...
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
    h.MI_Phasor_Det = uicontrol(...
        'Parent',h.MI_Phasor_Panel,...
        'Tag','MI_Phasor_Det',...
        'Style','popupmenu',...
        'Units','normalized',...
        'FontSize',12,...
        'String',{''},...
        'Callback',{@Update_Display;6},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.18 0.93 0.33 0.025]);
    %%% Phasor reference selection
    h.MI_Phasor_UseRef = uicontrol(...
        'Parent',h.MI_Phasor_Panel,...
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
    h.MI_Calc_Phasor = uicontrol(...
        'Parent',h.MI_Phasor_Panel,...
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
        'Parent',h.MI_Phasor_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'String','Ref LT [ns]:',...
        'Horizontalalignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.78 0.965 0.13 0.025]);
    %%% Editbox for the reference lifetime
    h.MI_Phasor_Ref = uicontrol(...
        'Parent',h.MI_Phasor_Panel,...
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
        'Parent',h.MI_Phasor_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'String','TAC [ns]:',...
        'Horizontalalignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.78 0.93 0.13 0.025]);
    %%% Editbox for the TAC range
    h.MI_Phasor_TAC = uicontrol(...
        'Parent',h.MI_Phasor_Panel,...
        'Tag','MI_Phasor_TAC',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'String','40',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.91 0.93 0.08 0.025]);
    %%% Phasor referencing axes
    h.MI_Phasor_Axes = axes(...
        'Parent',h.MI_Phasor_Panel,...
        'Tag','MI_Phasor_Axes',...
        'Units','normalized',...
        'NextPlot','add',...
        'UIContextMenu',h.MI_Menu,...        
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Position',[0.09 0.05 0.89 0.83],...
        'Box','on');
    h.MI_Phasor_Axes.XLabel.String='TAC channel';
    h.MI_Phasor_Axes.XLabel.Color=Look.Fore;
    h.MI_Phasor_Axes.YLabel.String='Counts';
    h.MI_Phasor_Axes.YLabel.Color=Look.Fore;
    h.MI_Phasor_Axes.XLim=[1 4096];
    h.Plots.PhasorRef=handle(plot([0 1],[0 0],'b')); 
    h.Plots.Phasor=handle(plot([0 4000],[0 0],'r')); 
        %% Tab for calibrating Detectors
    %%% Detector calibration tab    
    h.MI_Calib_Tab= uitab(...
        'Parent',h.Additional_Tabs,...
        'Tag','MI_Calib_Tab',...
        'Title','Detector Calibration');  
    %%% Detector calibration panel
    h.MI_Calib_Panel = uibuttongroup(...
        'Parent',h.MI_Calib_Tab,...
        'Tag','MI_Calib_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    %%% Button to start calibration
    h.MI_Calib_Calc = uicontrol(...
        'Parent',h.MI_Calib_Panel,...
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
        'Parent',h.MI_Calib_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','Left',...
        'String','Max',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.28 0.965 0.1 0.025]);
    %%% Edit box maximum corrected ticks
    h.MI_Calib_Single_Max = uicontrol(...
        'Parent',h.MI_Calib_Panel,...
        'Tag','MI_Calib_Single_Max',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'String','400',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.38 0.965 0.1 0.025]); 
    
    %%% Detector calibration channel
    h.MI_Calib_Det = uicontrol(...
        'Parent',h.MI_Calib_Panel,...
        'Tag','MI_Calib_Det',...
        'Style','popupmenu',...
        'Units','normalized',...
        'FontSize',12,...
        'String',{''},...
        'Callback',{@Update_Display;7},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.93 0.25 0.025]);
    %%% Interphoton time selection
    h.MI_Calib_Single = uicontrol(...
        'Parent',h.MI_Calib_Panel,...
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
    h.MI_Calib_Single_Text = uicontrol(...
        'Parent',h.MI_Calib_Panel,...
        'Tag','MI_Calib_Single_Text',...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'String','1',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.77 0.965 0.05 0.025]);
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.MI_Calib_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','Left',...
        'String','Range',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.28 0.93 0.1 0.025]);

    %%% Sum interphoton time bins
    h.MI_Calib_Single_Range = uicontrol(...
        'Parent',h.MI_Calib_Panel,...
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
    h.MI_Calib_Save = uicontrol(...
        'Parent',h.MI_Calib_Panel,...
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
    h.MI_Calib_Clear = uicontrol(...
        'Parent',h.MI_Calib_Panel,...
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
    h.MI_Calib_Axes = axes(...
        'Parent',h.MI_Calib_Panel,...
        'Tag','MI_Calib_Axes',...
        'Units','normalized',...
        'NextPlot','add',...
        'UIContextMenu',h.MI_Menu,...        
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Position',[0.09 0.4 0.89 0.48],...
        'Box','on');
    h.MI_Calib_Axes.XLabel.String='TAC channel';
    h.MI_Calib_Axes.XLabel.Color=Look.Fore;
    h.MI_Calib_Axes.YLabel.String='Counts';
    h.MI_Calib_Axes.YLabel.Color=Look.Fore;
    h.MI_Calib_Axes.XLim=[1 4096];
    % uncorrected MI histogram:
    h.Plots.Calib_No=handle(plot([0 1], [0 0],'b'));
    % corrected MI histogram:
    h.Plots.Calib=handle(plot([0 1], [0 0],'r'));
    % ?:
    h.Plots.Calib_Cur=handle(plot([0 1], [0 0],'c'));
    % selected interphoton time MI histogram:
    h.Plots.Calib_Sel=handle(plot([0 1], [0 0],'g'));
    
    %%% Detector calibration shift axes    
    h.MI_Calib_Axes_Shift = axes(...
        'Parent',h.MI_Calib_Panel,...
        'Tag','MI_Calib_Axes_Shift',...
        'Units','normalized',...
        'NextPlot','add',...      
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Position',[0.09 0.05 0.89 0.28],...
        'Box','on');
    h.MI_Calib_Axes_Shift.XLabel.String='Interphoton time [macrotime ticks]';
    h.MI_Calib_Axes_Shift.XLabel.Color=Look.Fore;
    h.MI_Calib_Axes_Shift.YLabel.String='Shift [microtime ticks]';
    h.MI_Calib_Axes_Shift.YLabel.Color=Look.Fore;
    h.MI_Calib_Axes_Shift.XLim=[1 400];
    h.Plots.Calib_Shift_New=handle(plot(1:400, zeros(400,1),'r'));
    %% Detector tabs general settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Microtime settings tab
    h.MI_Settings_Tab= uitab(...
        'Parent',h.Det_Tabs,...
        'Tag','MI_Settings_Tab',...
        'Title','Settings');
    %%% Microtime settings panel
    h.MI_Settings_Panel = uibuttongroup(...
        'Parent',h.MI_Settings_Tab,...
        'Tag','MI_Settings_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    
    %%% Contexmenu for MI Channels List
    h.MI_Channels_Menu = uicontextmenu;
    %%% Menu to add MI channels
    h.MI_Add = uimenu(...
        'Parent',h.MI_Channels_Menu,...
        'Label','Add new microtime channel',...
        'Tag','MI_Add',...
        'Callback',@MI_Channels_Functions);
    %%% Menu to delete MI channels
    h.MI_Delete = uimenu(...
        'Parent',h.MI_Channels_Menu,...
        'Label','Delete selected microtime channels',...
        'Tag','MI_Delete',...
        'Callback',@MI_Channels_Functions);
    %%% Menu to rename MI channels
    h.MI_Name = uimenu(...
        'Parent',h.MI_Channels_Menu,...
        'Label','Rename microtime channels',...
        'Tag','MI_Rename',...
        'Callback',@MI_Channels_Functions);

    %%% Menu to change MI channel color
    h.MI_Color = uimenu(...
        'Parent',h.MI_Channels_Menu,...
        'Label','Change microtime channel color',...
        'Tag','MI_Color',...
        'Callback',@MI_Channels_Functions);    
    %%% List of detector/routing pairs to use     
    h.MI_Channels_List = uicontrol(...
        'Parent',h.MI_Settings_Panel,...
        'Tag','MI_Channels_List',...
        'Style','listbox',...
        'Units','normalized',...
        'FontSize',14,...
        'Max',2,...
        'TooltipString',sprintf('List of detector/routing pairs to be loaded/displayed \n disabled denotes pairs that will be loaded but not displayed'),...
        'Uicontextmenu',h.MI_Channels_Menu,...
        'KeyPressFcn',@MI_Channels_Functions,...
        'BackgroundColor', Look.List,...
        'ForegroundColor', Look.ListFore,...
        'Position',[0.01 0.71 0.5 0.28]);
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.MI_Settings_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String', 'Number of microtime tabs:',...
        'Position',[0.01 0.67 0.4 0.03]);
    %%% Selects, how many microtime tabs to generate
    h.MI_NTabs = uicontrol(...
        'Parent',h.MI_Settings_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',14,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String', '1',...
        'Callback',{@Update_Detector_Channels, [0,1]},...
        'Position',[0.41 0.67 0.06 0.03]);
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.MI_Settings_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String', 'Number of plots per tab:',...
        'Position',[0.01 0.635 0.4 0.03]);
    %%% Selects, how many plots per microtime tabs to generate
    h.MI_NPlots = uicontrol(...
        'Parent',h.MI_Settings_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',14,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String', '1',...
        'Callback',{@Update_Detector_Channels, [0,1]},...
        'Position',[0.41 0.635 0.06 0.03]);
%% Trace and Image tabs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Macrotime tabs container
    h.MT_Tab = uitabgroup(...
        'Parent',h.Pam,...
        'Tag','MT_Tab',...
        'Units','normalized',...
        'Position',[0.01 0.01 0.485 0.485]);   
    %% Plot and functions for intensity trace %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Intensity trace tab
    h.Trace_Tab= uitab(...
        'Parent',h.MT_Tab,...
        'Tag','Trace_Tab',...
        'Title','Intensity Trace');

    %%% Intensity trace panel
    h.Trace_Panel = uibuttongroup(...
        'Parent',h.Trace_Tab,...
        'Tag','Trace_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);

    %%% Intensity trace axes
    h.Trace_Axes = axes(...
        'Parent',h.Trace_Panel,...
        'Tag','Trace_Axes',...
        'Units','normalized',...
        'NextPlot','add',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Position',[0.08 0.1 0.9 0.87],...
        'Box','on');
    h.Trace_Axes.XLabel.String='Time [s]';
    h.Trace_Axes.XLabel.Color=Look.Fore;
    h.Trace_Axes.YLabel.String='Countrate [kHz]';
    h.Trace_Axes.YLabel.Color=Look.Fore;
    h.Plots.Trace=handle(plot([0 1],[0 0],'b')); 
    %%%         
    %% Plot and functions for image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Image tab
    h.Image_Tab= uitab(...
        'Parent',h.MT_Tab,...
        'Tag','Image_Tab',...
        'Title','Image');    
    %%% Image panel
    h.Image_Panel = uibuttongroup(...
        'Parent',h.Image_Tab,...
        'Tag','Image_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);    
    %%% Image axes
    h.Image_Axes = axes(...
        'Parent',h.Image_Panel,...
        'Tag','Image_Axes',...
        'Units','normalized',...
        'Position',[0.01 0.01 0.7 0.98]);
    h.Plots.Image=imagesc(0);
    h.Image_Axes.XTick=[]; h.Image_Axes.YTick=[];
    h.Image_Colorbar=colorbar;
    colormap(jet);
    h.Image_Colorbar.Color=Look.Fore;
    
    %%% Popupmenu to switch between intensity and mean arrival time images
    h.Image_Type = uicontrol(...
        'Parent',h.Image_Panel,...
        'Tag','Image_Type',...
        'Style','popupmenu',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',{@Update_Display,3},...
        'String',{'Intensity';'Mean arrival time'},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.75 0.92 0.24 0.06]);    
    %%% Checkbox that determins if autoscale is on
    h.Image_Autoscale = uicontrol(...
        'Parent',h.Image_Panel,...
        'Tag','Image_Autoscale',...
        'Style','checkbox',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',{@Update_Display,3},...
        'String','Use Autoscale',...
        'Value',1,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.75 0.84 0.24 0.06]);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Settings for trace and image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Setting tab
    h.MT_Settings_Tab= uitab(...
        'Parent',h.MT_Tab,...
        'Tag','MT_Settings_Tab',...
        'Title','Settings');    
    %%% Settings panel
    h.MT_Settings_Panel = uibuttongroup(...
        'Parent',h.MT_Settings_Tab,...
        'Tag','MT_Settings_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);    
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.MT_Settings_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'HorizontalAlignment','left',...
        'String','Binning size for trace [ms]:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.92 0.34 0.06]);    
    %%% Mactotime binning
    h.MT_Binning = uicontrol(...
        'Parent',h.MT_Settings_Panel,...
        'Tag','MT_Binning',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',14,...
        'Callback',@Calculate_Settings,...
        'String','10',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.36 0.92 0.1 0.06]);   
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.MT_Settings_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'HorizontalAlignment','left',...
        'String','MT sectioning type:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.82 0.26 0.06]);     
    %%% Trace sectioning settings
    h.MT_Trace_Sectioning = uicontrol(...
        'Parent',h.MT_Settings_Panel,...
        'Tag','MT_Trace_Sectioning',...
        'Style','popupmenu',...
        'Units','normalized',...
        'FontSize',14,...
        'Callback',@Calculate_Settings,...
        'String',{'Constant number';'Constant time'},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.28 0.83 0.28 0.06]);   
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.MT_Settings_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'HorizontalAlignment','left',...
        'String','Sectioning time [s]:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.72 0.26 0.06]);    
    %%% Time Sectioning
    h.MT_Time_Section = uicontrol(...
        'Parent',h.MT_Settings_Panel,...
        'Tag','MT_Time_Section',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',14,...
        'Callback',@Calculate_Settings,...
        'String','5',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.28 0.72 0.1 0.06]);    
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.MT_Settings_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'HorizontalAlignment','left',...
        'String','Section number:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.62 0.26 0.06]);    
    %%% Number Sectioning
    h.MT_Number_Section = uicontrol(...
        'Parent',h.MT_Settings_Panel,...
        'Tag','MT_Number_Section',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',14,...
        'Callback',@Calculate_Settings,...
        'String','10',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.28 0.62 0.1 0.06]);
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.MT_Settings_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'HorizontalAlignment','left',...
        'String','Images to export:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.42 0.23 0.06]);
    %%% Image exporting settings
    h.MT_Image_Export = uicontrol(...
        'Parent',h.MT_Settings_Panel,...
        'Tag','MT_Image_Export',...
        'Style','popupmenu',...
        'Units','normalized',...
        'FontSize',14,...
        'String',{'Both';'Intensity';'Mean arrival time'},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Value',2,...
        'Position',[0.28 0.43 0.28 0.06]);
    %%% Checkbox to determine if image is calculated
    h.MT_Use_Image = uicontrol(...
        'Parent',h.MT_Settings_Panel,...
        'Tag','MT_Use_Image',...
        'Style','checkbox',...
        'Units','normalized',...
        'FontSize',14,...
        'Value',UserValues.Settings.Pam.Use_Image,...
        'String','Calculate image',...
        'Callback',@Calculate_Settings,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.32 0.26 0.06]);
    %%% Checkbox to determine if mean arrival time image is calculated
    h.MT_Use_Lifetime = uicontrol(...
        'Parent',h.MT_Settings_Panel,...
        'Tag','MT_Use_Lifetime',...
        'Style','checkbox',...
        'Units','normalized',...
        'FontSize',14,...
        'Value',UserValues.Settings.Pam.Use_Lifetime,...
        'String','Calculate lifetime image',...
        'Callback',@Calculate_Settings,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.28 0.32 0.38 0.06]);
%% Various tabs (PIE Channels, general information, settings etc.) %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Macrotime tabs container
    h.Var_Tab = uitabgroup(...
        'Parent',h.Pam,...
        'Tag','Var_Tab',...
        'Units','normalized',...
        'Position',[0.01 0.505 0.485 0.442]);     
    %% PIE Channels and general information tab
    h.PIE_Tab= uitab(...
        'Parent',h.Var_Tab,...
        'Tag','PIE_Tab',...
        'Title','PIE');    
    %%% PIE Channels and general information panel
    h.PIE_Panel = uibuttongroup(...
        'Parent',h.PIE_Tab,...
        'Tag','PIE_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);    
    %%% Contexmenu for PIE Channel list
    h.PIE_List_Menu = uicontextmenu;
    %%% Menu for PIE channel navigation
    h.PIE_Channels = uimenu(...
        'Parent',h.PIE_List_Menu,...
        'Label','PIE channel',...
        'Tag','PIE_Channels');
    %%% Adds new PIE Channel
    h.PIE_Add = uimenu(...
        'Parent',h.PIE_Channels,...
        'Label','Add new PIE channel',...
        'Tag','PIE_Add',...
        'Callback',@PIE_List_Functions);
    %%% Deletes selected PIE Channels
    h.PIE_Delete = uimenu(...
        'Parent',h.PIE_Channels,...
        'Label','Delete selected channels',...
        'Tag','PIE_Delete',...
        'Callback',@PIE_List_Functions);
    %%% Creates Combined Channel
    h.PIE_Combine = uimenu(...
        'Parent',h.PIE_Channels,...
        'Label','Create combined channel',...
        'Tag','PIE_Combine',...
        'Callback',@PIE_List_Functions);
    %%% Manually select microtime
    h.PIE_Select = uimenu(...
        'Parent',h.PIE_Channels,...
        'Label','Manually select microtime',...
        'Tag','PIE_Select',...
        'Callback',@PIE_List_Functions);
    %%% Changes Channel Color
    h.PIE_Color = uimenu(...
        'Parent',h.PIE_Channels,...
        'Label','Change channel colors',...
        'Tag','PIE_Color',...
        'Callback',@PIE_List_Functions);
    %%% Saves the current Measurement as IRF for the Channel
    h.PIE_IRF = uimenu(...
        'Parent',h.PIE_List_Menu,...
        'Label','Save IRF for selected PIE Channel',...
        'Tag','PIE_IRF',...
        'Callback',@SaveIRF);
    %%% Export main
    h.PIE_Export = uimenu(...
        'Parent',h.PIE_List_Menu,...
        'Label','Export...',...
        'Tag','PIE_Export');
    %%% Exports MI and MT as one vector each
    h.PIE_Export_Raw_Total = uimenu(...
        'Parent',h.PIE_Export,...
        'Label','...Raw data (total)',...
        'Tag','PIE_Export_Raw_Total',...
        'Callback',@PIE_List_Functions);
    %%% Exports MI and MT for each file
    h.PIE_Export_Raw_File = uimenu(...
        'Parent',h.PIE_Export,...
        'Label','...Raw data (per file)',...
        'Tag','PIE_Export_Raw_File',...
        'Callback',@PIE_List_Functions);
    %%% Exports and plots and image of the PIE channel
    h.PIE_Export_Image_Total = uimenu(...
        'Parent',h.PIE_Export,...
        'Label','...image (total)',...
        'Tag','PIE_Export_Image_Total',...
        'Callback',@PIE_List_Functions);
    %%% Exports all frames of the PIE channel
    h.PIE_Export_Image_File = uimenu(...
        'Parent',h.PIE_Export,...
        'Label','...image (per file)',...
        'Tag','PIE_Export_Image_File',...
        'Callback',@PIE_List_Functions);
    h.PIE_Export_Image_Tiff = uimenu(...
        'Parent',h.PIE_Export,...
        'Label','...image (as .tiff)',...
        'Tag','PIE_Export_Image_Tiff',...
        'Callback',@PIE_List_Functions);   
    %%% PIE Channel list
    h.PIE_List = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Tag','PIE_List',...
        'Style','listbox',...
        'Units','normalized',...
        'FontSize',14,...
        'Max',2,...
        'String',UserValues.PIE.Name,...
        'TooltipString',sprintf([...
            'List of currently selected PIE Channels: \n'...
            '"+" adds channel; \n "-" or del deletes channel; \n'...
            '"leftarrow" moves channel up; \n'...
            '"rightarrow" moves channel down \n'...
            'Rightclick to open contextmenu with additional functions;']),...
        'UIContextMenu',h.PIE_List_Menu,...
        'Callback',{@Update_Display,1:5},...
        'KeyPressFcn',@PIE_List_Functions,...
        'BackgroundColor', Look.List,...
        'ForegroundColor', Look.ListFore,...
        'Position',[0.01 0.01 0.4 0.98]);   
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','PIE channel name:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.415 0.92 0.22 0.06]);
    
    %%% Editbox for PIE channel name
    h.PIE_Name = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Tag','PIE_Name',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@Update_PIE_Channels,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.64 0.92 0.34 0.06]);    
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','Detector:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.415 0.84 0.11 0.06]);    
    %%% Editbox for PIE channel detector
    h.PIE_Detector = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Tag','PIE_Detector',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@Update_PIE_Channels,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.54 0.84 0.08 0.06]);   
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','Routing:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.63 0.84 0.11 0.06]);    
    %%% Editbox for PIE channel routing
    h.PIE_Routing = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Tag','PIE_Routing',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@Update_PIE_Channels,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.745 0.84 0.08 0.06]); 
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','From:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.415 0.76 0.11 0.06]);    
    %%% Editbox for microtime minimum of PIE channel
    h.PIE_From = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Tag','PIE_From',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@Update_PIE_Channels,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.54 0.76 0.08 0.06]);
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','To:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.63 0.76 0.11 0.06]);    
    %%% Editbox for mictotime maximum of PIE channel
    h.PIE_To = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Tag','PIE_To',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@Update_PIE_Channels,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.745 0.76 0.08 0.06]);
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Tag','PIE_Info',...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String',{'Total photons:';'Channel photons:'; 'Total countrate:'; 'Channel countrate:'},...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.415 0.52 0.2 0.22]);        
    %%% Textfield for photon number and countrate
    h.PIE_Info = uicontrol(...
        'Parent',h.PIE_Panel,...
        'Tag','PIE_Info',...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String',{'Total photons:';'Channel photons:'; 'Total countrate:'; 'Channel countrate:'},...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.66 0.52 0.15 0.22]);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Correlations tab
    h.Cor_Tab= uitab(...
        'Parent',h.Var_Tab,...
        'Tag','Cor_Tab',...
        'Title','Correlate');
    %%% Correlation panel
    h.Cor_Panel = uibuttongroup(...
        'Parent',h.Cor_Tab,...
        'Tag','Cor_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    %%% Contexmenu for correlation table
    h.Cor_Menu = uicontextmenu;
    %%% multicorsupport
    h.Cor_Multi_Menu = uimenu(...
        'Parent',h.Cor_Menu,...
        'Label','Use Multi-core',...
        'Tag','Cor_Multi_Menu',...
        'Callback',@Calculate_Settings);
    %%% Sets a divider for correlation
    h.Cor_Divider_Menu = uimenu(...
        'Parent',h.Cor_Menu,...
        'Label',['Divider: ' num2str(UserValues.Settings.Pam.Cor_Divider)],...
        'Tag','Cor_Divider_Menu',...
        'Callback',@Calculate_Settings);
    %%% Correlations table
    h.Cor_Table = uitable(...
        'Parent',h.Cor_Panel,...
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
            'Use multi-core: En-/Disable use of multiple CPUs for correlation; \n'...
            'Divider: Divider for correlation time resolution for certain excitation schemes']),...
        'UIContextMenu',h.Cor_Menu,...
        'CellEditCallback',@Update_Cor_Table);
    %%% Correlates current loaded data
    h.Cor_Button = uicontrol(...
        'Parent',h.Cor_Panel,...
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
    h.Cor_Multi_Button = uicontrol(...
        'Parent',h.Cor_Panel,...
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
    h.Cor_Format = uicontrol(...
        'Parent',h.Cor_Panel,...
        'Tag','Cor_Format',...
        'Units','normalized',...
        'FontSize',10,...
        'FontWeight','bold',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String',{'Matlab file (.mcor)';'Text file (.cor)'; 'both'},... 
        'Position',[0.26 0 0.22 0.09],...
        'Style','popupmenu',...
        'TooltipString',sprintf('Select fileformat for saving correlation files'));
    %%% Determines correlation type
    h.Cor_Type = uicontrol(...
        'Parent',h.Cor_Panel,...
        'Units','normalized',...
        'FontSize',10,...
        'FontWeight','bold',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String',{'Point';'Pair'},... 
        'Position',[0.49 0 0.1 0.09],...
        'Style','popupmenu',...
        'TooltipString',sprintf('Choose between point and pair correlation'));    
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.Cor_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String','#Bins:',...
        'HorizontalAlignment','left',...
        'Position',[0.6 0 0.07 0.09]);
    %%% Sets number of bins for pair correlation
    h.Cor_Pair_Bins = uicontrol(...
        'Parent',h.Cor_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','edit',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','50',...
        'Position',[0.67 0.01 0.06 0.09],...
        'TooltipString',sprintf('Select number of bins for pair correlation'));    
    %%% Text
    h.Text{end+1} = uicontrol(...
        'Parent',h.Cor_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String','Distance:',...
        'HorizontalAlignment','left',...
        'Position',[0.74 0 0.10 0.09]);
    %%% Sets bin distances to correlatie
    h.Cor_Pair_Dist = uicontrol(...
        'Parent',h.Cor_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','edit',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','1:50',...
        'Position',[0.84 0.01 0.06 0.09],...
        'TooltipString',sprintf('Select bin distances to calculate for pair correlation'));
    %% Burst tab
    h.Burst_Tab = uitab(...
        'Parent',h.Var_Tab,...
        'Tag','Burst_Tab',...
        'Title','Burst Analysis');   
    %%% Burst panel
    h.Burst_Panel = uibuttongroup(...
        'Parent',h.Burst_Tab,...
        'Tag','Burst_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
   %%% Axes for preview of Burst Selection
   h.Burst_Axes = axes(...
       'Parent',h.Burst_Panel,...
       'Tag','Burst_Axes',...
       'Position',[0.07 0.12 0.92 0.4],...
       'Units','normalized',...
       'NextPlot','add',...
       'XColor',Look.Fore,...
       'YColor',Look.Fore,...
       'Box','on');
    h.Burst_Axes.XLabel.String='Time [ms]';
    h.Burst_Axes.XLabel.Color=Look.Fore;
    h.Burst_Axes.YLabel.String='Counts per Timebin';
    h.Burst_Axes.YLabel.Color=Look.Fore;
    h.Burst_Axes.XLim=[0 1];
    
    h.Plots.BurstPreview.Channel1 = plot([0 1],[0 0],'g');
    h.Plots.BurstPreview.Channel2 = plot([0 1],[0 0],'r');
    h.Plots.BurstPreview.Channel3 = plot([0 1],[0 0],'b');
    %%% Button to start Burst Analysis
    h.Burst_Button = uicontrol(...
        'Parent',h.Burst_Panel,...
        'Tag','Burst_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Do Burst Search',...
        'Callback',@Do_BurstAnalysis,...
        'Position',[0.75 0.92 0.24 0.07],...
        'TooltipString',sprintf('Start Burst Analysis'));   
    %%% Right-click menu for Burst_Button to allow loading of performed
    %%% BurstSearches for posterior Lifetime (re-)fitting and NirFilter
    %%% (re-)calculation
    h.Burst_Button_Menu = uicontextmenu;
    h.Burst_Button_Menu_LoadData = uimenu(h.Burst_Button_Menu,...
            'Label','Load Performed BurstSearch',...
            'Callback',@Load_Performed_BurstSearch);
    h.Burst_Button_Menu_SaveTotalPhotonStream = uimenu(h.Burst_Button_Menu,...
        'Label','Save Total Photons Stream for correlation analysis',...
        'Callback',@Calculate_Settings);
    switch UserValues.BurstSearch.SaveTotalPhotonStream
        case 0
            h.Burst_Button_Menu_SaveTotalPhotonStream.Checked = 'off';
        case 1
            h.Burst_Button_Menu_SaveTotalPhotonStream.Checked = 'on';
    end
    h.Burst_Button.UIContextMenu = h.Burst_Button_Menu;
    %%% Right-click menu for BurstLifetime_Button to allow loading of
    %%% IRF/Scatter AFTER performed burst search using stored PIE settings
    h.BurstLifetime_Button_Menu = uicontextmenu;
    h.BurstLifetime_Button_Menu_StoreIRF = uimenu(h.BurstLifetime_Button_Menu,...
            'Label','Store current IRF in *.bur file',...
            'Callback',{@Store_IRF_Scat_inBur,0});
    h.BurstLifetime_Button_Menu_StoreScatter = uimenu(h.BurstLifetime_Button_Menu,...
        'Label','Store current Scatter and background measurement in *.bur file',...
        'Callback',{@Store_IRF_Scat_inBur,1});
    
    %%% Button to start burstwise Lifetime Fitting
    h.BurstLifetime_Button = uicontrol(...
        'Parent',h.Burst_Panel,...
        'Tag','BurstLifetime_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Burstwise Lifetime',...
        'Callback',@BurstLifetime,...
        'Position',[0.75 0.76 0.24 0.07],...
        'TooltipString',sprintf('Perform Burstwise Lifetime Fit or set Burstwise Lifetime settings'),...
        'UIContextMenu',h.BurstLifetime_Button_Menu);  
    %%% Button to calculate 2CDE Filter
        h.NirFilter_Button = uicontrol(...
        'Parent',h.Burst_Panel,...
        'Tag','NirFilter_Button',...
        'Units','normalized',...
        'FontSize',12,... 
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','2CDE',...
        'Callback',@NirFilter,...
        'Position',[0.75 0.68 0.08 0.07],...
        'TooltipString',sprintf('Calculate 2CDE Filter'));
    %%% Checkbox to calculate 2CDE filter
    h.NirFilter_Checkbox = uicontrol(...
        'Parent',h.Burst_Panel,...
        'Tag','NirFilter_Button',...
        'Style', 'checkbox',...
        'Units','normalized',...
        'FontSize',14,...
        'Value',1,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String','2CDE',...
        'Position',[0.75 0.84 0.08 0.07],...
        'TooltipString',sprintf('Calculate 2CDE Filter when doing Burst Search'));  
            %%% Checkbox to calculate 2CDE filter
    h.BurstLifetime_Checkbox = uicontrol(...
        'Parent',h.Burst_Panel,...
        'Tag','BurstLifetime_Button',...
        'Style', 'checkbox',...
        'Units','normalized',...
        'FontSize',14,...
        'Value',0,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String','lifetime',...
        'Position',[0.85 0.84 0.10 0.07],...
        'TooltipString',sprintf('Calculate Burstwise Lifetime when doing Burst Search. All settings for lifetime analysis need to be set correctly beforehand!')); 
    %%%Edit to change the time constant for the filter
    h.NirFilter_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.Burst_Panel,...
        'Tag','NirFilter_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','100',...
        'Callback',[],...
        'Position',[0.84 0.68 0.05 0.07],...
        'TooltipString',sprintf('Specify the Time Constant for Filter Calculation (e.g. 100 or 100;200 or 100:100:1000)'));   
    %%%text label to specify the unit of the edit values (mu s)
    h.NirFilter_Text = uicontrol(...
        'Style','push',...
        'enable','inactive',...
        'Parent',h.Burst_Panel,...
        'Tag','NirFilter_Text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String','<HTML> &mu s</HTML>',...
        'Callback',[],...
        'Position',[0.891 0.68 0.05 0.07],...
        'TooltipString',sprintf('Specify the Time Constant for Filter Calculation (e.g. 100 or 100;200 or 100:100:1000)'));    
    %%%Table for PIE channel assignment
    h.BurstPIE_Table = uitable(...
        'Parent',h.Burst_Panel,...
        'Units','normalized',...
        'Tag','BurstPIE_Table',...
        'FontSize',12,...
        'Position',[0 0.6 0.27 0.4],...
        'CellEditCallback',@BurstSearchParameterUpdate,...
        'RowStriping','on');
   
    %%% store the information for the BurstPIE_Table in the handles
    %%% structure
    %%% Labels for 2C-noMFD All-Photon Burst Search
    h.BurstPIE_Table_Content.APBS_twocolornoMFD.RowName = {'DD','DA','AA'};
    h.BurstPIE_Table_Content.APBS_twocolornoMFD.ColumnName = {'PIE Channel'};
    %%% Labels for 2C-MFD All-Photon Burst Search
    h.BurstPIE_Table_Content.APBS_twocolorMFD.RowName = {'DD','DA','AA'};
    h.BurstPIE_Table_Content.APBS_twocolorMFD.ColumnName = {'Parallel','Perpendicular'};
    %%% Labels for 2C-MFD Dual-Channel Burst Search
    h.BurstPIE_Table_Content.DCBS_twocolorMFD.RowName = {'DD','DA','AA'};
    h.BurstPIE_Table_Content.DCBS_twocolorMFD.ColumnName = {'Parallel','Perpendicular'};
    %%% Labels for 3C-MFD All-Photon Burst Search
    h.BurstPIE_Table_Content.APBS_threecolorMFD.RowName = {'BB','BG','BR','GG','GR','RR'};
    h.BurstPIE_Table_Content.APBS_threecolorMFD.ColumnName = {'Parallel','Perpendicular'};
    %%% Labels for 3C-MFD Triple-Channel Burst Search
    h.BurstPIE_Table_Content.TCBS_threecolorMFD.RowName = {'BB','BG','BR','GG','GR','RR'};
    h.BurstPIE_Table_Content.TCBS_threecolorMFD.ColumnName = {'Parallel','Perpendicular'};
    
    h.BurstSearchMethods = {'APBS_twocolorMFD','DCBS_twocolorMFD','APBS_threecolorMFD','TCBS_threecolorMFD','APBS_twocolornoMFD'};
    %%% Button to convert a measurement to a photon stream based on PIE
    %%% channel  selection
    h.PhotonstreamConvert_Button = uicontrol(...
        'Parent',h.Burst_Panel,...
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
     h.Burst_LoadedFile_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','center',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String','no *.bur file loaded',...
        'Position',[0.75 0.53 0.25 0.13],...
        'TooltipString',sprintf(''));    
    
    %%% Button to show a preview of the burst search
    h.BurstSearchPreview_Button = uicontrol(...
        'Parent',h.Burst_Panel,...
        'Tag','BurstSearchPreview_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Preview',...
        'Callback',@BurstSearch_Preview,...
        'Position',[0.88 0 0.12 0.05],...
        'TooltipString',sprintf('Update the preview display.'));   
    %%%Buttons to shift the preview by one second forwards or backwards
    h.BurstSearchPreview_Forward_Button = uicontrol(...
        'Parent',h.Burst_Panel,...
        'Tag','BurstSearchPreview_Forward_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','>',...
        'Callback',@BurstSearch_Preview,...
        'Position',[0.85 0 0.029 0.05],...
        'TooltipString',sprintf(''));
    h.BurstSearchPreview_Backward_Button = uicontrol(...
        'Parent',h.Burst_Panel,...
        'Tag','BurstSearchPreview_Backward_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','<',...
        'Callback',@BurstSearch_Preview,...
        'Position',[0.82 0 0.029 0.05],...
        'TooltipString',sprintf(''));    
    %%%Popup Menu for Selection of Burst Search
    h.BurstSearchSelection_Popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.Burst_Panel,...
        'Tag','BurstSearchSelection_Popupmenu',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String',{'APBS 2C-MFD','DCBS 2C-MFD','APBS 3C-MFD','TCBS 3C-MFD','APBS 2C-noMFD'},...
        'Callback',@Update_BurstGUI,...
        'Position',[0.28 0.9 0.30 0.09],...
        'TooltipString',sprintf(''));   
    %%% Edit Box for Parameter1 (Number of Photons Threshold)
    h.BurstParameter1_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','100',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.63 0.85 0.07 0.05],...
        'TooltipString',sprintf(''));
    %%% Text Box for Parameter1 (Number of Photons Threshold)
    h.BurstParameter1_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String','Minimum Photons per Burst:',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.28 0.85 0.34 0.05],...
        'TooltipString',sprintf(''));    
    %%% Edit Box for Parameter2 (Time Window)
    h.BurstParameter2_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.Burst_Panel,...
        'Tag','BurstParameter2_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','500',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.63 0.79 0.07 0.05],...
        'TooltipString',sprintf(''));   
    %%% Text Box for Parameter2 (Number of Photons Threshold)
    h.BurstParameter2_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String','Time Window [us]:',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.28 0.79 0.34 0.05],...
        'TooltipString',sprintf(''));    
    %%% Edit Box for Parameter3 (Photons per Time Window Threshold 1)
    h.BurstParameter3_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','5',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.63 0.73 0.07 0.05],...
        'TooltipString',sprintf(''));    
    %%% Text Box for Parameter3 (Photons per Time Window Threshold 1)
    h.BurstParameter3_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...'
        'ForegroundColor', Look.Fore,...
        'String','Photons per Time Window:',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.28 0.73 0.34 0.05],...
        'TooltipString',sprintf(''));    
    %%% Edit Box for Parameter4 (Photons per Time Window Threshold 2)
    h.BurstParameter4_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','5',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.63 0.67 0.07 0.05],...
        'TooltipString',sprintf(''));   
    %%% Text Box for Parameter4 (Photons per Time Window Threshold 2)
    h.BurstParameter4_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String','Photons per Time Window:',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.28 0.67 0.34 0.05],...
        'TooltipString',sprintf(''));    
    %%% Edit Box for Parameter5 (Photons per Time Window Threshold 3)
    h.BurstParameter5_Edit = uicontrol(...
        'Style','edit',...
        'Parent',h.Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','5',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.63 0.61 0.07 0.05],...
        'TooltipString',sprintf(''));
    %%% Text Box for Parameter5 (Photons per Time Window Threshold 3)
    h.BurstParameter5_Text = uicontrol(...
        'Style','text',...
        'Parent',h.Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String','Photons per Time Window:',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.28 0.61 0.34 0.05],...
        'TooltipString',sprintf(''));
    
    %%% Disable all further processing buttons of BurstSearch
    h.NirFilter_Button.Enable = 'off';
    h.BurstLifetime_Button.Enable = 'off';
    %% Profiles tab
    h.Profiles_Tab= uitab(...
        'Parent',h.Var_Tab,...
        'Tag','Profiles_Tab',...
        'Title','Profiles');
    %%% Profiles panel
    h.Profiles_Panel = uibuttongroup(...
        'Parent',h.Profiles_Tab,...
        'Tag','Profiles_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    %%% Contexmenu for Profiles list
    h.Profiles_Menu = uicontextmenu;
    %%% Selects profile
    h.Profiles_Select = uimenu(...
        'Parent',h.Profiles_Menu,...
        'Label','Select profile',...
        'Tag','Profiles_Delete',...
        'Callback',@Update_Profiles);
    %%% Deletes selected profile
    h.Profiles_Duplicate = uimenu(...
        'Parent',h.Profiles_Menu,...
        'Label','Duplicate selected profile',...
        'Tag','Profiles_Duplicate',...
        'Callback',@Update_Profiles);
    %%% Adds new Profile
    h.Profiles_Add = uimenu(...
        'Parent',h.Profiles_Menu,...
        'Label','Add new profile',...
        'Tag','Profiles_Add',...
        'Callback',@Update_Profiles);
    %%% Deletes selected profile
    h.Profiles_Delete = uimenu(...
        'Parent',h.Profiles_Menu,...
        'Label','Delete selected profile',...
        'Tag','Profiles_Delete',...
        'Callback',@Update_Profiles);
    %%% Profiles list
    h.Profiles_List = uicontrol(...
        'Parent',h.Profiles_Panel,...
        'Tag','Profiles_List',...
        'Style','listbox',...
        'Units','normalized',...
        'FontSize',14,...
        'String',Profiles,...
        'Uicontextmenu',h.Profiles_Menu,...
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
        'Position',[0.01 0.01 0.4 0.98]);
    %%% Description of profile
    h.Profiles_Description = uicontrol(...
        'Parent',h.Profiles_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','',...
        'Max',2,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.415 0.01 0.575 0.98]);    
    %% Database tab
    h.Database.Tab= uitab(...
        'Parent',h.Var_Tab,...
        'Tag','Database_Tab',...
        'Title','Database');    
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
    h.Database.List = uicontrol(...
        'Parent',h.Database.Panel,...
        'Tag','Database_List',...
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
                          '<i>"return"</i>: Loads selected files <b>!!!Only works with same Path and Type!!!</b><br>',...
                          '<I>"delete"</i>: Removes selected files from list </b>'],...
        'Position',[0.01 0.01 0.7 0.98]);   
    h.Database.Text = {};
    h.Database.Text{end+1} = uicontrol(...
        'Parent',h.Database.Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','Manage database',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.75 0.90 0.24 0.07]);
    h.Database.Load = uicontrol(...
        'Parent',h.Database.Panel,...
        'Tag','Database_Load_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Load database',...
        'Callback',{@Database,3},...
        'Position',[0.75 0.84 0.24 0.07],...
        'Tooltipstring', 'Load database from file');
    %%% Button to add files to the database
    h.Database.Save = uicontrol(...
        'Parent',h.Database.Panel,...
        'Tag','Database_Save_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Save Database',...
        'Callback',{@Database,4},...
        'Position',[0.75 0.76 0.24 0.07],...
        'enable', 'off',...
        'Tooltipstring', 'Save database to a file');
    h.Database.Text{end+1} = uicontrol(...
        'Parent',h.Database.Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','Batch analysis',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.75 0.66 0.24 0.07]);
    %%% Button to add files to the database
    h.Database.Correlate = uicontrol(...
        'Parent',h.Database.Panel,...
        'Tag','Database_Correlate_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Correlate',...
        'Callback',{@Database,5},...
        'Position',[0.75 0.60 0.24 0.07],...
        'enable', 'off',...
        'UserData',0,...
        'Tooltipstring', 'Make sure "Correlate" tab settings are correct!');  
    %%% Button to add files to the database
    h.Database.Burst = uicontrol(...
        'Parent',h.Database.Panel,...
        'Tag','Database_Burst_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Burst analysis',...
        'Callback',{@Database,6},...
        'Position',[0.75 0.52 0.24 0.07],...
        'enable', 'off',...
        'UserData',0,...
        'Tooltipstring', 'Make sure "Burst analysis" tab settings are correct');  
    %% Export tab
    h.Export.Tab= uitab(...
        'Parent',h.Var_Tab,...
        'Tag','Export_Tab',...
        'Title','Export');    
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
    h.Export.List = uicontrol(...
        'Parent',h.Export.Panel,...
        'Tag','Export_List',...
        'Style','listbox',...
        'Units','normalized',...
        'FontSize',14,...
        'Max',2,...
        'String',[],...
        'BackgroundColor', Look.List,...
        'ForegroundColor', Look.ListFore,...
        'KeyPressFcn',{@Export_Database,0},...
        'Tooltipstring', ['<html>'...
                          'List of file groups in export database <br>'],...
        'Position',[0.01 0.01 0.6 0.98]);  
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
        'Position',[0.63 0.51 0.35 0.48]);      
    %%% Changes the size of the ROW names
    drawnow
    Export_PIE = findjobj(h.Export.PIE);
    Names = Export_PIE.getComponent(4);
    Names.setPreferredSize(java.awt.Dimension(175,100));
    Names = Names.getComponent(0);
    Names.setSize(175,100);
    
    h.Export.Text = {};
    h.Export.Text{end+1} = uicontrol(...
        'Parent',h.Export.Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','Manage export',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.65 0.42 0.24 0.07]);
    h.Export.Load = uicontrol(...
        'Parent',h.Export.Panel,...
        'Tag','Export_Load_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Load database',...
        'Callback',{@Export_Database,3},...
        'Position',[0.65 0.34 0.24 0.07],...
        'Tooltipstring', 'Load export database from file');
    %%% Button to add files to the database
    h.Export.Save = uicontrol(...
        'Parent',h.Export.Panel,...
        'Tag','Export_Save_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Save database',...
        'Callback',{@Export_Database,4},...
        'Position',[0.65 0.26 0.24 0.07],...
        'enable', 'off',...
        'Tooltipstring', 'Save exportdatabase to a file');
    %%% Button to add files to the database
    h.Export.TIFF = uicontrol(...
        'Parent',h.Export.Panel,...
        'Tag','Export_TIFF_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Export TIFFs',...
        'Callback',{@Export_Database,5},...
        'Position',[0.65 0.16 0.24 0.07],...
        'enable', 'off',...
        'UserData',0,...
        'Tooltipstring', 'Exports selected files as TIFF!');  
    


    
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
FileInfo.SyncPeriod=1;
FileInfo.Lines=1;
FileInfo.Pixels=1;
FileInfo.FileName={'Nothing loaded'};

PamMeta=[];
PamMeta.MI_Hist=repmat({zeros(4096,1)},numel(UserValues.Detector.Name),1);
PamMeta.Trace=repmat({0:0.01:FileInfo.MeasurementTime},numel(UserValues.PIE.Name),1);
PamMeta.Image=repmat({0},numel(UserValues.PIE.Name),1);
PamMeta.Lifetime=repmat({0},numel(UserValues.PIE.Name),1);
PamMeta.TimeBins=0:0.01:FileInfo.MeasurementTime;
PamMeta.Info=repmat({zeros(4,1)},numel(UserValues.PIE.Name),1);
PamMeta.MI_Tabs=[];
PamMeta.Det_Calib=[];
PamMeta.Burst.Preview = [];

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

h.Pam.Visible='on';  
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions that executes upon closing of pam window %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_Pam(Obj,~)
clear global -regexp PamMeta TcspcData FileInfo TauFitBurstData
Phasor=findobj('Tag','Phasor');
FCSFit=findobj('Tag','FCSFit');
MIAFit=findobj('Tag','MIAFit');
Mia=findobj('Tag','Mia');
Sim=findobj('Tag','Sim');
PCF=findobj('Tag','PCF');
BurstBrowser=findobj('Tag','BurstBrowser');
TauFit=findobj('Tag','TauFit');
PhasorTIFF = findobj('Tag','PhasorTIFF');
if isempty(Phasor) && isempty(FCSFit) && isempty(MIAFit) && isempty(PCF) && isempty(Mia) && isempty(Sim) && isempty(BurstBrowser) && isempty(TauFit) && isempty(PhasorTIFF)
    clear global -regexp UserValues
end
if isempty(BurstBrowser)
    clear global -regexp BurstData BurstTCSPCData PhotonStream
end
delete(Obj);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Updates Pam Meta Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Data(~,~,Detector,PIE)
global TcspcData FileInfo UserValues PamMeta
h = guidata(findobj('Tag','Pam'));

h.Progress_Text.String = 'Updating meta data';
h.Progress_Axes.Color=[1 0 0];
drawnow;
if Detector==0
    Detector = 1:numel(UserValues.Detector.Name);
    PamMeta.MI_Hist=cell(numel(UserValues.Detector.Name),1);
end
if PIE==0
    PIE = find(UserValues.PIE.Detector>0);    
    PamMeta.Image=cell(numel(UserValues.PIE.Name),1);
    PamMeta.Trace=cell(numel(UserValues.PIE.Name),1);
end

%% Creates a microtime histogram for each detector/routing pair
if ~isempty(Detector)
    for i=Detector
        %%% Checks, if the appropriate channel is loaded
        if all(size(TcspcData.MI)>=[UserValues.Detector.Det(i),UserValues.Detector.Rout(i)]) && ~isempty(TcspcData.MI{UserValues.Detector.Det(i),UserValues.Detector.Rout(i)})
            PamMeta.MI_Hist{i}=histc(TcspcData.MI{UserValues.Detector.Det(i),UserValues.Detector.Rout(i)},0:(FileInfo.MI_Bins-1));
        else
            PamMeta.MI_Hist{i}=zeros(FileInfo.MI_Bins,1);
        end
    end
end
%% Creates trace and image plots

%%% Creates macrotime bins for traces (currently fixed 10ms)
PamMeta.TimeBins=0:str2double(h.MT_Binning.String)/1000:FileInfo.MeasurementTime;
%%% Creates a intensity trace and image for each non-combined PIE channel
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
            PIE_MT=TcspcData.MT{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To)*FileInfo.SyncPeriod;
            %%% Calculate intensity trace for PIE channel (currently with 100 ms bins)
            PamMeta.Trace{i}=histc(PIE_MT,PamMeta.TimeBins)./str2double(h.MT_Binning.String);
            
            %% Calculates image
            if h.MT_Use_Image.Value
                %%% Goes back from total microtime to file microtime
                PIE_MT=mod(PIE_MT,FileInfo.ImageTime);
                %%% Calculates Pixel vector
                Pixeltimes=0;
                for j=1:FileInfo.Lines
                    Pixeltimes(end:(end+FileInfo.Lines))=linspace(FileInfo.LineTimes(j),FileInfo.LineTimes(j+1),FileInfo.Lines+1);
                end
                Pixeltimes(end)=[];
                %%% Calculate image vector
                PamMeta.Image{i}=histc(PIE_MT,Pixeltimes*FileInfo.SyncPeriod);  
                %%% Reshapes pixel vector to image
                PamMeta.Image{i}=flipud(reshape(PamMeta.Image{i},FileInfo.Lines,FileInfo.Lines)');
                
                
            else
                PamMeta.Image{i}=zeros(FileInfo.Lines);
            end
            
            %% Calculate mean arival time image
            if h.MT_Use_Image.Value && h.MT_Use_Lifetime.Value
                %%% Calculates sorted photon indeces and transforms it to uint32 to save memory
                [~,PIE_MT]=sort(PIE_MT); PIE_MT=uint32(PIE_MT);
                %%% Extracts microtimes of PIE channel
                PIE_MI=TcspcData.MI{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To);
                %%% Sorts microtimes
                PIE_MI=PIE_MI(PIE_MT); clear PIE_MT;
                %%% Calculates summed up microtime to speed up mean arrival time calculation
                PIE_MI=cumsum(double(PIE_MI));
                %%% Calculates last pixel photon vector
                Image_Sum=double(fliplr(PamMeta.Image{i}'));
                Image_Sum=[1;cumsum(Image_Sum(:))];
                %%% Needed for later indexing
                Image_Sum(Image_Sum<1)=1;
                %%% Calculates mean arrival time image vector
                if ~isempty(PIE_MI)
                    PamMeta.Lifetime{i} = PIE_MI(Image_Sum(2:(FileInfo.Pixels+1)))-PIE_MI(Image_Sum(1:FileInfo.Pixels));
                else
                    PamMeta.Lifetime{i} = zeros(1,FileInfo.Pixels);
                end
                clear PIE_MI;
                %%% Reshapes pixel vector to image and normalizes to nomber of photons
                PamMeta.Lifetime{i}=flipud(reshape(PamMeta.Lifetime{i},FileInfo.Lines,FileInfo.Lines)')./double(PamMeta.Image{i});
                %%% Sets NaNs to 0 for empty pixels
                PamMeta.Lifetime{i}(PamMeta.Image{i}==0)=0;
            else
                PamMeta.Lifetime{i}=zeros(FileInfo.Lines);
            end
            
            %% Calculates photons and countrate for PIE channel
            PamMeta.Info{i}(1,1)=numel(TcspcData.MT{Det,Rout});
            PamMeta.Info{i}(2,1)=sum(PamMeta.Trace{i})*str2double(h.MT_Binning.String);
            clear Image_Sum;
            PamMeta.Info{i}(3,1)=PamMeta.Info{i}(1)/FileInfo.MeasurementTime/1000;
            PamMeta.Info{i}(4,1)=PamMeta.Info{i}(2)/FileInfo.MeasurementTime/1000;
        else
            %%% Creates a 0 trace for empty/nonexistent detector/routing pairs
            PamMeta.Trace{i}=zeros(numel(PamMeta.TimeBins),1);
            %%% Creates a 1x1 zero image for empty/nonexistent detector/routing pairs
            PamMeta.Image{i}=zeros(FileInfo.Lines);
            PamMeta.Lifetime{i}=zeros(FileInfo.Lines);
            %%% Sets coutrate and photon info to 0
            PamMeta.Info{i}(1:4,1)=0;
        end
    end
end
%%% Calculates trace, image, mean arrival time and info for combined
%%% channels
for  i=find(UserValues.PIE.Detector==0)    
    PamMeta.Image{i}=zeros(FileInfo.Lines);
    PamMeta.Trace{i}=zeros(numel(PamMeta.TimeBins),1);
    PamMeta.Lifetime{i}=zeros(FileInfo.Lines);
    PamMeta.Info{i}(1:4,1)=0; 
    for j=UserValues.PIE.Combined{i}
        PamMeta.Image{i}=PamMeta.Image{i}+PamMeta.Image{j};
        PamMeta.Lifetime{i}=PamMeta.Lifetime{i}+PamMeta.Lifetime{j};
        PamMeta.Trace{i}=PamMeta.Trace{i}+PamMeta.Trace{j};
        PamMeta.Info{i}=PamMeta.Info{i}+PamMeta.Info{j};
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Determines settings for various things %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Calculate_Settings(obj,~)
global UserValues
h = guidata(findobj('Tag','Pam'));
Display=0;
%%% If use_image was clicked
if obj == h.MT_Use_Image
    UserValues.Settings.Pam.Use_Image=h.MT_Use_Image.Value;
    %%% If also deactivate lifetime calculation
    if h.MT_Use_Image.Value==0
        UserValues.Settings.Pam.Use_Lifetime=0;
        h.MT_Use_Lifetime.Value=0;
    end
%%% If use_lifetime was clicked    
elseif obj == h.MT_Use_Lifetime
    UserValues.Settings.Pam.Use_Lifetime=h.MT_Use_Lifetime.Value;
    %%% If also activate image calculation
    if h.MT_Use_Lifetime.Value
        h.MT_Use_Image.Value=1;
        UserValues.Settings.Pam.Use_Image=1;
    end
%%% When changing trace bin size  
elseif obj == h.MT_Binning
    UserValues.Settings.Pam.MT_Binning=str2double(h.MT_Binning.String);
    Display=1;
%%% When changing trace sectioning type   
elseif obj == h.MT_Trace_Sectioning
    UserValues.Settings.Pam.MT_Trace_Sectioning=h.MT_Trace_Sectioning.Value;
    Update_Display([],[],2);
%%% When selection time was changed
elseif obj == h.MT_Time_Section
    UserValues.Settings.Pam.MT_Time_Section=str2double(h.MT_Time_Section.String);
    Update_Display([],[],2);
%%% When number of sections was changes
elseif obj == h.MT_Number_Section
    UserValues.Settings.Pam.MT_Number_Section=str2double(h.MT_Number_Section.String);
    Update_Display([],[],2);
%%% Turns usa of multiple cores on/off 
elseif obj == h.Cor_Multi_Menu
    h.Cor_Multi_Menu.Checked=cell2mat(setxor(h.Cor_Multi_Menu.Checked,{'on','off'}));
    UserValues.Settings.Pam.Multi_Core=h.Cor_Multi_Menu.Checked;
%%% Sets new divider
elseif obj == h.Cor_Divider_Menu
    %%% Opens input dialog and gets value 
    Divider=inputdlg('New divider:');
    if ~isempty(Divider)
        h.Cor_Divider_Menu.Label=['Divider: ' cell2mat(Divider)];
        UserValues.Settings.Pam.Cor_Divider=round(str2double(Divider));
    end
elseif obj == h.MI_Log_Ind || obj == h.MI_Log
    %%% Puts Y-axis in log scale
    if strcmp(h.MI_Log.Checked,'off')
        UserValues.Settings.Pam.PlotLog = 'on';
        h.MI_Log.Checked='on';
        h.MI_Log_Ind.Checked='on';
    else
        UserValues.Settings.Pam.PlotLog = 'off';
        h.MI_Log.Checked='off';
        h.MI_Log_Ind.Checked='off';
    end
    Update_Display([],[],9)
    Update_Display([],[],5)
elseif obj == h.MI_IRF
    %%% Switches IRF Check Display
    if strcmp(h.MI_IRF.Checked,'on')
        h.MI_IRF.Checked = 'off';
        UserValues.Settings.Pam.PlotIRF = 'off';
    else
        h.MI_IRF.Checked = 'on';
        UserValues.Settings.Pam.PlotIRF = 'on';
    end
    Update_Display([],[],8);
elseif obj == h.MI_ScatterPattern
    %%% Switches IRF Check Display
    if strcmp(h.MI_ScatterPattern.Checked,'on')
        h.MI_ScatterPattern.Checked = 'off';
        UserValues.Settings.Pam.PlotScat = 'off';
    else
        h.MI_ScatterPattern.Checked = 'on';
        UserValues.Settings.Pam.PlotScat = 'on';
    end
    Update_Display([],[],8);
elseif obj == h.Burst_Button_Menu_SaveTotalPhotonStream
    if strcmp(obj.Checked,'on')
        UserValues.BurstSearch.SaveTotalPhotonStream = 0;
        obj.Checked = 'off';
    else
        UserValues.BurstSearch.SaveTotalPhotonStream = 1;
        obj.Checked = 'on';
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

if nargin<3 || any(mode==0)
    mode=[1:5, 6, 8, 9];
end


%% PIE List update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Uses HTML to set color of each channel to selected color
List=cell(numel(UserValues.PIE.Name),1);
for i=1:numel(List)
    Hex_color=dec2hex(UserValues.PIE.Color(i,:)*255)';
    List{i}=['<HTML><FONT color=#' Hex_color(:)' '>' UserValues.PIE.Name{i} '</Font></html>'];
end
%%% Updates PIE_List string
h.PIE_List.String=List;
%%% Removes nonexistent selected channels
h.PIE_List.Value(h.PIE_List.Value>numel(UserValues.PIE.Name))=[];
%%% Selects first channel, if none is selected
if isempty(h.PIE_List.Value)
    h.PIE_List.Value=1;
end
drawnow;
%%% Finds currently selected PIE channel
Sel=h.PIE_List.Value(1);

%% PIE info update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==1)
    %%% Updates PIE channel settings to current PIE channel
    h.PIE_Name.String=UserValues.PIE.Name{Sel};
    h.PIE_Detector.String=num2str(UserValues.PIE.Detector(Sel));
    h.PIE_Routing.String=num2str(UserValues.PIE.Router(Sel));
    h.PIE_From.String=num2str(UserValues.PIE.From(Sel));
    h.PIE_To.String=num2str(UserValues.PIE.To(Sel));
    
    %%% Updates PIE channel infos to current PIE channel
    h.PIE_Info.String{1}=num2str(PamMeta.Info{Sel}(1) );
    h.PIE_Info.String{2}=num2str(PamMeta.Info{Sel}(2));
    h.PIE_Info.String{3}=[num2str(PamMeta.Info{Sel}(3),'%6.2f' ) ' kHz'];
    h.PIE_Info.String{4}=[num2str(PamMeta.Info{Sel}(4),'%6.2f' ) ' kHz'];
    
    %%% Disables PIE info controls for combined channels
    if UserValues.PIE.Detector(Sel)==0
       h.PIE_Name.Enable='inactive'; 
       h.PIE_Detector.Enable='inactive';
       h.PIE_Routing.Enable='inactive';
       h.PIE_From.Enable='inactive';
       h.PIE_To.Enable='inactive';
       
       h.PIE_Name.BackgroundColor=UserValues.Look.Back; 
       h.PIE_Detector.BackgroundColor=UserValues.Look.Back; 
       h.PIE_Routing.BackgroundColor=UserValues.Look.Back; 
       h.PIE_From.BackgroundColor=UserValues.Look.Back; 
       h.PIE_To.BackgroundColor=UserValues.Look.Back;  
       
       h.PIE_Name.ForegroundColor=UserValues.Look.Disabled; 
       h.PIE_Detector.ForegroundColor=UserValues.Look.Disabled; 
       h.PIE_Routing.ForegroundColor=UserValues.Look.Disabled; 
       h.PIE_From.ForegroundColor=UserValues.Look.Disabled;  
       h.PIE_To.ForegroundColor=UserValues.Look.Disabled;   
    else
       h.PIE_Name.Enable='on'; 
       h.PIE_Detector.Enable='on';
       h.PIE_Routing.Enable='on';
       h.PIE_From.Enable='on';
       h.PIE_To.Enable='on';   
       
       h.PIE_Name.BackgroundColor=UserValues.Look.Control; 
       h.PIE_Detector.BackgroundColor=UserValues.Look.Control; 
       h.PIE_Routing.BackgroundColor=UserValues.Look.Control; 
       h.PIE_From.BackgroundColor=UserValues.Look.Control; 
       h.PIE_To.BackgroundColor=UserValues.Look.Control;  
       
       h.PIE_Name.ForegroundColor=UserValues.Look.Fore; 
       h.PIE_Detector.ForegroundColor=UserValues.Look.Fore; 
       h.PIE_Routing.ForegroundColor=UserValues.Look.Fore; 
       h.PIE_From.ForegroundColor=UserValues.Look.Fore;  
       h.PIE_To.ForegroundColor=UserValues.Look.Fore; 
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
    h.Plots.Trace.YData=PamMeta.Trace{Sel};
    h.Plots.Trace.XData=PamMeta.TimeBins;
    h.Plots.Trace.Color=UserValues.PIE.Color(Sel,:);
end

%% Image plot update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Updates image
if any(mode==3)
    switch h.Image_Type.Value
        %%% Intensity image
        case 1
            h.Plots.Image.CData=PamMeta.Image{Sel};
            %%% Autoscales between min-max; +1 is for max=min
            if h.Image_Autoscale.Value
                h.Image_Axes.CLim=[min(min(PamMeta.Image{Sel})), max(max(PamMeta.Image{Sel}))+1];
            end
        %%% Mean arrival time image
        case 2
            h.Plots.Image.CData=PamMeta.Lifetime{Sel};
            %%% Autoscales between min-max of pixels with at least 10% intensity;
            if h.Image_Autoscale.Value
                Min=0.1*max(max(PamMeta.Image{Sel}))-1; %%% -1 is for 0 intensity images
                h.Image_Axes.CLim=[min(min(PamMeta.Lifetime{Sel}(PamMeta.Image{Sel}>Min))), max(max(PamMeta.Lifetime{Sel}(PamMeta.Image{Sel}>Min)))+1];
            end
        %%% Lifetime from phase    
        case 3
            h.Plots.Image.CData=PamMeta.TauP;
            %%% Autoscales between min-max of pixels with at least 10% intensity;
            if h.Image_Autoscale.Value
                Min=0.1*max(max(PamMeta.Phasor_Int))-1; %%% -1 is for 0 intensity images
                h.Image_Axes.CLim=[min(min(PamMeta.TauP(PamMeta.Phasor_Int>Min))), max(max(PamMeta.TauP(PamMeta.Phasor_Int>Min)))+1];
            end
        %%% Lifetime from modulation    
        case 4
            h.Plots.Image.CData=PamMeta.TauM;
            %%% Autoscales between min-max of pixels with at least 10% intensity;
            if h.Image_Autoscale.Value
                Min=0.1*max(max(PamMeta.Phasor_Int))-1; %%% -1 is for 0 intensity images
                h.Image_Axes.CLim=[min(min(PamMeta.TauM(PamMeta.Phasor_Int>Min))), max(max(PamMeta.TauM(PamMeta.Phasor_Int>Min)))+1];
            end
        %%% g from phasor calculation
        case 5
            h.Plots.Image.CData=PamMeta.g;
            %%% Autoscales between min-max of pixels with at least 10% intensity;
            if h.Image_Autoscale.Value
                Min=0.1*max(max(PamMeta.Phasor_Int))-1; %%% -1 is for 0 intensity images
                h.Image_Axes.CLim=[min(min(PamMeta.g(PamMeta.Phasor_Int>Min))), max(max(PamMeta.g(PamMeta.Phasor_Int>Min)))+1];
            end
        %%% s from phasor calculation
        case 6
            h.Plots.Image.CData=PamMeta.s;
            %%% Autoscales between min-max of pixels with at least 10% intensity;
            if h.Image_Autoscale.Value
                Min=0.1*max(max(PamMeta.Phasor_Int))-1; %%% -1 is for 0 intensity images
                h.Image_Axes.CLim=[min(min(PamMeta.s(PamMeta.Phasor_Int>Min))), max(max(PamMeta.s(PamMeta.Phasor_Int>Min)))+1];
            end
    end
    %%% Sets xy limits and aspectration ot 1
    h.Image_Axes.DataAspectRatio=[1 1 1];
    h.Image_Axes.XLim=[0.5 size(PamMeta.Image{Sel},1)+0.5];
    h.Image_Axes.YLim=[0.5 size(PamMeta.Image{Sel},1)+0.5];
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
    axes(h.MI_All_Axes);
    xlim([1 FileInfo.MI_Bins]);
    for i=1:numel(PamMeta.MI_Hist)
        %%% Checks, if lineseries already exists
        if ~isempty(h.Plots.MI_All{i})
            %%% Only changes YData of plot to increase speed
            h.Plots.MI_All{i}.YData=PamMeta.MI_Hist{i};
        else
            %%% Plots new lineseries, if none exists
            h.Plots.MI_All{i}=handle(plot(PamMeta.MI_Hist{i}));
        end
        %%% Sets color of lineseries (Divide by max to make 0 <= c <= 1
        h.Plots.MI_All{i}.Color= UserValues.Detector.Color(i,:);
    end
end

%% Individual microtime plots update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==4)
    %%% Plots individual microtime histograms
    for i=1:numel(UserValues.Detector.Plots)
        if UserValues.Detector.Plots(i)<=numel(PamMeta.MI_Hist)
            h.Plots.MI_Ind{i}.XData=1:numel(PamMeta.MI_Hist{UserValues.Detector.Plots(i)});
            h.Plots.MI_Ind{i}.YData=PamMeta.MI_Hist{UserValues.Detector.Plots(i)};
            h.Plots.MI_Ind{i}.Color=UserValues.Detector.Color(UserValues.Detector.Plots(i),:);
            %%% Set XLim to Microtime Range
            h.Plots.MI_Ind{i}.Parent.XLim = [1 FileInfo.MI_Bins];
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

if any(mode==8)
    %% Plot IRFs on the individual microtime plots
    if strcmp(h.MI_IRF.Checked,'on')
        for i = 1:size(UserValues.Detector.Plots,1) %loop through microtime tabs
            for j = 1:size(UserValues.Detector.Plots,2) %loop through plots per microtime tab
                % find which detector is selected for the current individual microtime plot
                detector = h.MI_Individual{i, 2*j+2}.Value;
                % loop through PIE channels
                for k = 1:numel(UserValues.PIE.IRF)
                    if ~isempty(UserValues.PIE.IRF{k})
                        % combined channels will either not be in
                        % UserValues.PIE.IRF, or will be empty
                        FromTo = UserValues.PIE.From(k):UserValues.PIE.To(k);
                        if (UserValues.PIE.Detector(k) == UserValues.Detector.Det(detector))...
                                && (UserValues.PIE.Router(k) == UserValues.Detector.Rout(detector))
                            %%% Plot IRF in PIE Channel range
                            h.Plots.MI_Ind_IRF{i,j}.Visible = 'on';
                            h.Plots.MI_Ind_IRF{i,j}.XData = 1:numel(UserValues.PIE.IRF{k});
                             if isequal(h.Plots.MI_Ind_IRF{i,j}.YData,[0 0])
                                 % no IRF has been plotted yet on microtime plot (i,j)
                                 h.Plots.MI_Ind_IRF{i,j}.YData = zeros(numel(UserValues.PIE.IRF{k}),1);
                             end
                            if max(PamMeta.MI_Hist{UserValues.Detector.Plots(i,j)}) == 0
                                % there is no data, so just show the IRF
                                norm = 1;
                            else
                                norm = max(PamMeta.MI_Hist{UserValues.Detector.Plots(i,j)}(FromTo));
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
    if strcmp(h.MI_ScatterPattern.Checked,'on')
         for i = 1:size(UserValues.Detector.Plots,1) %loop through microtime tabs
            for j = 1:size(UserValues.Detector.Plots,2) %loop through plots per microtime tab
                % find which detector is selected for the current individual microtime plot
                detector = h.MI_Individual{i, 2*j+2}.Value;
                % loop through PIE channels
                for k = 1:numel(UserValues.PIE.ScatterPattern)
                    if ~isempty(UserValues.PIE.ScatterPattern{k})
                        % combined channels will either not be in
                        % UserValues.PIE.ScatterPattern, or will be empty
                        FromTo = UserValues.PIE.From(k):UserValues.PIE.To(k);
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
    From=str2double(h.MI_Phasor_From.String);
    To=str2double(h.MI_Phasor_To.String);
    Shift=str2double(h.MI_Phasor_Shift.String);
    Det=h.MI_Phasor_Det.Value;
    
    if From<1
        From=1;
        h.MI_Phasor_From.String=num2str(From);
    end
    if To>numel(PamMeta.MI_Hist{Det})
        To=numel(PamMeta.MI_Hist{Det});
        h.MI_Phasor_To.String=num2str(To);        
    end
    
    if(size(UserValues.Phasor.Reference,2) < To)
        UserValues.Phasor.Reference(end,To) = 0;
    end
    %%% Plots Reference histogram 
    Ref=circshift(UserValues.Phasor.Reference(Det,:),[0 Shift]);Ref=Ref(From:To);
    h.Plots.PhasorRef.XData=From:To;
    h.Plots.PhasorRef.YData=(Ref-min(Ref))/(max(Ref)-min(Ref));
    %%% Plots Phasor microtime    
    h.Plots.Phasor.XData=From:To;
    Pha=PamMeta.MI_Hist{Det}(From:To);
    h.Plots.Phasor.YData=(Pha-min(Pha))/(max(Pha)-min(Pha));
    h.MI_Phasor_Axes.XLim=[From To];    
end

%% Detector Calibration plot update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==7)
    if isfield(PamMeta.Det_Calib,'Hist') && ~isempty(PamMeta.Det_Calib.Shift)
        % uncorrected MI histogram (blue)
        h.Plots.Calib_No.YData=sum(PamMeta.Det_Calib.Hist,2)/max(smooth(sum(PamMeta.Det_Calib.Hist,2),5));
        h.Plots.Calib_No.XData=1:FileInfo.MI_Bins;
        
        % corrected MI histogram (red)
        Cor_Hist=zeros(size(PamMeta.Det_Calib.Hist));     
        maxtick = str2double(h.MI_Calib_Single_Max.String);
        h.MI_Calib_Single.Max = maxtick;
        for i=1:maxtick
            Cor_Hist(:,i)=circshift(PamMeta.Det_Calib.Hist(:,i),[-PamMeta.Det_Calib.Shift(i),0]);
        end
        h.Plots.Calib.YData=sum(Cor_Hist,2)/max(smooth(sum(Cor_Hist,2),5));
        h.Plots.Calib.XData=1:FileInfo.MI_Bins;
        
        % slider
        h.MI_Calib_Single.Value=round(h.MI_Calib_Single.Value);  
        MIN=max([1 h.MI_Calib_Single.Value]);
        MAX=min([maxtick, MIN+str2double(h.MI_Calib_Single_Range.String)-1]);
        h.MI_Calib_Single_Text.String=num2str(MIN);
        
        % interphoton time selected MI histogram (green)
        h.Plots.Calib_Sel.YData=sum(Cor_Hist(:,MIN:MAX),2)/max(smooth(sum(Cor_Hist(:,MIN:MAX),2),5));
        h.Plots.Calib_Sel.XData=1:FileInfo.MI_Bins;
        
    end
end

%% Plot Y-axis in log %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this has to be before mode == 5 PIE Patches!
if any(mode==9)
    if strcmp(h.MI_Log.Checked, 'on')
        for i=1:(size(h.MI_Individual,2)/2-1)
            for j=1:size(h.MI_Individual,1)
                h.MI_Individual{j,2*i+1}.YScale='Log';
            end
        end
        h.MI_All_Axes.YScale='Log';
        h.MI_Phasor_Axes.YScale='Log';
        h.MI_Calib_Axes.YScale='Log';
    else
        h.MI_All_Axes.YScale='Linear';
        for i=1:(size(h.MI_Individual,2)/2-1)
            for j=1:size(h.MI_Individual,1)
                h.MI_Individual{j,2*i+1}.YScale='Linear';
            end
        end
        h.MI_Phasor_Axes.YScale='Linear';
        h.MI_Calib_Axes.YScale='Linear';
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
           Valid=[Valid find(UserValues.Detector.Plots(:)==j)];
        end
        %%% For all microtime plots containing PIE channel
        for j=Valid(:)'
            x=mod(j-1,size(UserValues.Detector.Plots,1))+1;
            y=2+2*ceil(j/size(UserValues.Detector.Plots,1))-1;
            %%% Creates a new patch object
            YData=h.MI_Individual{x,y}.YLim;
            h.Plots.PIE_Patches{end+1}=patch([From From To To],[YData(2) YData(1) YData(1) YData(2)],Color,'Parent',h.MI_Individual{x,y},'UserData',i);
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
    if h.MT_Trace_Sectioning.Value==1
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
    YData=h.Trace_Axes.YLim;
    YData=[YData(2) YData(1) YData(1) YData(2)];
    for i=1:numel(h.Plots.MT_Patches)
        %%% Creates new patch
        if isempty(h.Plots.MT_Patches{i})
            h.Plots.MT_Patches{i}=handle(patch([PamMeta.MT_Patch_Times(i) PamMeta.MT_Patch_Times(i) PamMeta.MT_Patch_Times(i+1) PamMeta.MT_Patch_Times(i+1)],YData,UserValues.Look.Axes,'Parent',h.Trace_Axes));
            h.Plots.MT_Patches{i}.ButtonDownFcn=@MT_Section;
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
h.Progress_Text.String = FileInfo.FileName{1};
h.Progress_Axes.Color=UserValues.Look.Control;


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
    if obj == h.PIE_Add
        e.Key='add';
    elseif obj == h.PIE_Delete
        e.Key='delete';
    elseif obj == h.PIE_Color;
        e.Key='c';
    elseif obj == h.PIE_Export_Raw_Total
        e.Key='Export_Raw_Total';
    elseif obj == h.PIE_Export_Raw_File
        e.Key='Export_Raw_File';
    elseif obj == h.PIE_Export_Image_Total
        e.Key='Export_Image_Total';
    elseif obj == h.PIE_Export_Image_File
        e.Key='Export_Image_File';
    elseif obj == h.PIE_Export_Image_Tiff
        e.Key='Export_Image_Tiff';
    elseif obj == h.PIE_Combine
        e.Key='Combine';
    elseif obj == h.PIE_Select
        e.Key='PIE_Select';
    else
        e.Key='';
    end
else
    e.Key=ed.Key;
end
%%% Find selected channels
Sel=h.PIE_List.Value;

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
        UserValues.PIE.IRF{end+1} = [];
        UserValues.PIE.ScatterPattern{end+1} = [];
        %%% Reset Correlation Table Data Matrix
        UserValues.Settings.Pam.Cor_Selection = false(numel(UserValues.PIE.Name)+1);      
        %%% Updates Pam meta data; input 3 should be empty to improve speed
        %%% Input 4 is the new channel
        Update_to_UserValues
        Update_Data([],[],[],numel(UserValues.PIE.Name));
        Update_Display([],[],0);
        %%% Updates correlation table
        Update_Cor_Table(obj);
        %%% Add channel to Export table
        h.Export.PIE.RowName = [UserValues.PIE.Name, {'All'}];
        h.Export.PIE.Data{end+1} = h.Export.PIE.Data{end};  
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
        %%% Reset Correlation Table Data Matrix
        UserValues.Settings.Pam.Cor_Selection = false(numel(UserValues.PIE.Name)+1);
        %%% in Pam meta data
        PamMeta.Trace(Sel)=[];
        PamMeta.Image(Sel)=[];
        PamMeta.Lifetime(Sel)=[];
        PamMeta.Info(Sel)=[];
        
        %%% Removes deleted PIE channel from all combined channels
        Combined=find(UserValues.PIE.Detector==0);
        new=0;
        for i=Combined
           if ~isempty(intersect(UserValues.PIE.Combined{i},Sel))
               UserValues.PIE.Combined{i}=setdiff(UserValues.PIE.Combined{i},Sel);
               UserValues.PIE.Name{i}='Comb.: ';
               for j=UserValues.PIE.Combined{i};
                   UserValues.PIE.Name{i}=[UserValues.PIE.Name{i} UserValues.PIE.Name{j} '+'];
               end
               UserValues.PIE.Name{i}(end)=[];
               new=1;
           end
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
        %%% Opens menu to choose color
        color=uisetcolor;
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
            %%% Selects moved channel again
            h.PIE_List.Value(1)=h.PIE_List.Value(1)-1;
        
            %%% Updates combined channels to new position
            Combined=find(UserValues.PIE.Detector==0);
            for i=Combined
                if any(UserValues.PIE.Combined{i} == Sel(1))
                    UserValues.PIE.Combined{i}(UserValues.PIE.Combined{i} == Sel(1)) = Sel(1)-1;
                end
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
        if Sel(1)<numel(h.PIE_List.String);
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
            %%% Selects moved channel again 
            h.PIE_List.Value(1)=h.PIE_List.Value(1)+1;
            
            %%% Updates combined channels to new position
            Combined=find(UserValues.PIE.Detector==0);
            for i=Combined
                if any(UserValues.PIE.Combined{i} == Sel(1))
                    UserValues.PIE.Combined{i}(UserValues.PIE.Combined{i} == Sel(1)) = Sel(1)+1;
                end
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
           'Export_Image_Tiff'} %%% Exports image stack into workspace
       Pam_Export([],e,Sel);
    case 'Combine' %%% Generates a combined PIE channel from existing PIE channels
        %%% Does not combine single
        if numel(Sel)>1 && isempty(cell2mat(UserValues.PIE.Combined(Sel)))
            
            UserValues.PIE.Color(end+1,:)=[0 0 1];
            UserValues.PIE.Combined{end+1}=Sel;
            UserValues.PIE.Detector(end+1)=0;
            UserValues.PIE.Router(end+1)=0;
            UserValues.PIE.From(end+1)=0;
            UserValues.PIE.To(end+1)=0;  
            UserValues.PIE.Duty_Cycle(end+1)=0;
            UserValues.PIE.IRF{end+1} = [];
            UserValues.PIE.ScatterPattern{end+1} = [];
            UserValues.PIE.Name{end+1}='Comb.: ';
            for i=Sel;
                UserValues.PIE.Name{end}=[UserValues.PIE.Name{end} UserValues.PIE.Name{i} '+'];
            end
            UserValues.PIE.Name{end}(end)=[];
            UserValues.PIE.Duty_Cycle(end+1)=0;
            %%% Reset Correlation Table Data Matrix
            UserValues.Settings.Pam.Cor_Selection = false(numel(UserValues.PIE.Name)+1);
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
        %%% Read out which Axis was clicked to get the Detector/Routing
        Clicked_Axis = gca;
        Axes_Handles = cell(size(UserValues.Detector.Plots,1),size(UserValues.Detector.Plots,2));
        for i = 1:size(UserValues.Detector.Plots,1)
            for j = 1:size(UserValues.Detector.Plots,2)
                Axes_Handles{i,j} = h.MI_Individual{i,2*j+1};
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
        e.Key='';
end
h.Progress_Text.String = FileInfo.FileName{1};
h.Progress_Axes.Color=UserValues.Look.Control;
Update_to_UserValues; %%% Updates CorrTable and BurstGUI
%% Only saves user values, if one of the function was used
if ~isempty(e.Key)
    LSUserValues(1);    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes PIE channel settings and saves them in the profile %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_PIE_Channels(obj,~)
global UserValues
h = guidata(findobj('Tag','Pam'));

Sel=h.PIE_List.Value(1);
if numel(Sel)==1 && isempty(UserValues.PIE.Combined{Sel})
    %%% Updates PIE Channel name
    if obj == h.PIE_Name
        UserValues.PIE.Name{Sel}=h.PIE_Name.String;
        %%% Updates correlation table
        Update_Cor_Table(obj);
        %%% Rename channels in Export table
        h.Export.PIE.RowName = [UserValues.PIE.Name, {'All'}];
    %%% Updates PIE detector
    elseif obj == h.PIE_Detector
        UserValues.PIE.Detector(Sel)=str2double(h.PIE_Detector.String);
    %%% Updates PIE routing
    elseif obj == h.PIE_Routing
        UserValues.PIE.Router(Sel)=str2double(h.PIE_Routing.String);
    %%% Updates PIE mictrotime minimum
    elseif obj == h.PIE_From
        UserValues.PIE.From(Sel)=str2double(h.PIE_From.String);
    %%% Updates PIE microtime maximum
    elseif obj == h.PIE_To
        UserValues.PIE.To(Sel)=str2double(h.PIE_To.String);
    end 
    LSUserValues(1);
    %%% Updates pam meta data; input 3 should be empty; input 4 is the
    %%% selected PIE channel
    if obj ~= h.PIE_Name        
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
function MT_Section(obj,~)
global PamMeta
h = guidata(findobj('Tag','Pam'));

for i=1:numel(h.Plots.MT_Patches)
    if obj==h.Plots.MT_Patches{i}
        break;
    end
end
PamMeta.Selected_MT_Patches(i)=abs(PamMeta.Selected_MT_Patches(i)-1);
Update_Display([],[],2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Callback functions of microtime channel list and UIContextmenues  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "+"-Key or Add menu: Generate new PIE channel
%%% "-"-Key, "del"-Key or Delete menu: Deletes first selected PIE channel
%%% "c"-Key or Color menu: Opens menu to choose channel color
%%% "n"-Key: Opens dialog menu to change Channel name
function MI_Channels_Functions(obj,ed)
global UserValues PamMeta
h = guidata(findobj('Tag','Pam'));
%% Determines which buttons was pressed, if function was not called via key press 
if ~strcmp(ed.EventName,'KeyPress')
    if obj == h.MI_Add
        e.Key='add';
    elseif obj == h.MI_Delete
        e.Key='delete';
    elseif obj == h.MI_Color;
        e.Key='c';
    elseif obj == h.MI_Name;
        e.Key='n';
    else
        e.Key='';
    end
else
    e.Key=ed.Key;
end
Sel=h.MI_Channels_List.Value;
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
        h.MI_Channels_List.String(Sel)=[];
        %%% Removes nonexistent selected channels
        h.MI_Channels_List.Value(h.MI_Channels_List.Value>numel(UserValues.Detector.Det))=[];
        %%% Selects first channel, if none is selected
        if isempty(h.MI_Channels_List.Value)
            h.MI_Channels_List.Value=1;
        end
        %%% Saves new tabs in guidata
        guidata(h.Pam,h)       
    case 'c' %% Selects new color for microtime channel
        %%% Opens menu to choose color
        color=uisetcolor;
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
h = guidata(findobj('Tag','Pam'));

%% Updates number of microtime tabs and plots
if any(mode==0)
    NTabs=str2double(h.MI_NTabs.String);
    NPlots=str2double(h.MI_NPlots.String);
    %%% Updates plot selection lists
    for i=1:NTabs 
        for j=1:NPlots
            try
                UserValues.Detector.Plots(i,j)=h.MI_Individual{i,2*(1+j)}.Value;
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
    h.MI_NTabs.String=num2str(NTabs);
    h.MI_NPlots.String=num2str(NPlots);
end
%% Creates individual microtime channels
if any(mode==1);
    %%% Deletes existing microtime tabs
    if isfield(h,'MI_Individual')
        cellfun(@delete,h.MI_Individual(:,1))
    end
    h.MI_Individual=cell(NTabs,2*NPlots+2);
    h.Plots.MI_Ind=cell(NTabs,NPlots);
    for i=1:NTabs %%% Creates set number of tabs
        %%% Individual microtime tabs
        h.MI_Individual{i,1} = uitab(...
            'Parent',h.MI_Tabs,...
            'Title',[num2str(NPlots*(i-1)+1) '-' num2str(i*NPlots)]);
        %%% Individual microtime panels
        h.MI_Individual{i,2} = uibuttongroup(...
            'Parent',h.MI_Individual{i}(1),...
            'Units','normalized',...
            'BackgroundColor', UserValues.Look.Back,...
            'ForegroundColor', UserValues.Look.Fore,...
            'HighlightColor', UserValues.Look.Control,...
            'ShadowColor', UserValues.Look.Shadow,...
            'Position',[0 0 1 1]);
        for j=1:NPlots %%% Creates set number of plots per tab
            %%% Individual microtime plots
            h.MI_Individual{i,2*(1+j)-1} = axes(...
                'Parent',h.MI_Individual{i,2},...
                'Units','normalized',...
                'NextPlot','add',...
                'UIContextMenu',h.MI_Menu_Individual,...
                'XColor',UserValues.Look.Fore,...
                'YColor',UserValues.Look.Fore,...
                'Position',[0.09 0.05+(j-1)*(0.98/NPlots) 0.89 0.98/NPlots-0.05],...
                'Box','on');
            h.MI_Individual{i,2*(1+j)-1}.XLabel.String = 'TAC channel';
            h.MI_Individual{i,2*(1+j)-1}.YLabel.String = 'Counts';
            h.MI_Individual{i,2*(1+j)-1}.YLabel.Color = UserValues.Look.Fore;
            h.MI_Individual{i,2*(1+j)-1}.XLim=[1 FileInfo.MI_Bins];
            %%% Individual microtime popup for channel selection
            h.MI_Individual{i,2*(1+j)} = uicontrol(...
                'Parent',h.MI_Individual{i,2},...
                'Style','popupmenu',...
                'Units','normalized',...
                'FontSize',14,...
                'String',UserValues.Detector.Name,...
                'BackgroundColor', UserValues.Look.Control,...
                'ForegroundColor', UserValues.Look.Fore,...
                'Value',UserValues.Detector.Plots(i,j),...
                'Callback',{@Update_Detector_Channels,0},...
                'Position',[0.78 j*(0.98/NPlots)-0.03 0.2 0.03]);
            if ismac %%% Change colors for readability on Mac
                h.MI_Individual{i,2*(1+j)}.BackgroundColor = UserValues.Look.Fore;
                h.MI_Individual{i,2*(1+j)}.ForegroundColor = UserValues.Look.Back;
            end
            h.Plots.MI_Ind{i,j}=line(...
                'Parent',h.MI_Individual{i,2*(1+j)-1},...
                'Color',UserValues.Detector.Color(UserValues.Detector.Plots(i,j),:),...
                'XData',[0 1],...
                'YData',[0 0]);
            h.Plots.MI_Ind_Scat{i,j}=line(...
                'Parent',h.MI_Individual{i,2*(1+j)-1},...
                'Color',[0.5 0.5 0.5],...
                'LineStyle',':',...
                'XData',[0 1],...
                'YData',[0 0],...
                'Visible','off');
            h.Plots.MI_Ind_IRF{i,j}=line(...
                'Parent',h.MI_Individual{i,2*(1+j)-1},...
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
    List=cell(numel(UserValues.Detector.Name),1);
    for i=1:numel(List)
        %%% Calculates Hex code for detector color
        Hex_color=dec2hex(round(UserValues.Detector.Color(i,:)*255))';
        List{i}=['<HTML><FONT color=#' Hex_color(:)' '>'... Sets entry color in HTML
            UserValues.Detector.Name{i}... Detector Name
            ': Detector: ' num2str(UserValues.Detector.Det(i))... Detector Number
            ' / Routing: ' num2str(UserValues.Detector.Rout(i))... Routing Number
            ' enabled </Font></html>'];
    end
    h.MI_Channels_List.String=List;
    %%% Updates plot selection lists
    for i=1:NTabs 
        for j=1:NPlots 
            h.MI_Individual{i,2*(1+j)}.String=UserValues.Detector.Name;
        end
    end
end
%% Saves new tabs in guidata
guidata(h.Pam,h)
Update_Display([],[],[4, 5, 8]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for extracting Macro- and Microtimes of PIE channels  %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Photons_PIEchannel] = Get_Photons_from_PIEChannel(PIEchannel,type,block,chunk)
%%% PIEchannel: Specifies the PIE channel as name or as number
%%% type:       Specifies the type of Photons to be extracted
%%%             (can be 'Macrotimes' or 'Microtimes')
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
if ~isempty(TcspcData.(type){Det,Rout})
    if nargin == 2 %%% read whole photon stream
        
        Photons_PIEchannel = TcspcData.(type){Det,Rout}(...
            TcspcData.MI{Det,Rout} >= From &...
            TcspcData.MI{Det,Rout} <= To);
        
    elseif nargin == 3 %%% read only the specified block
        %%% Calculates the block start times in clock ticks
        Times=ceil(PamMeta.MT_Patch_Times/FileInfo.SyncPeriod);
        
        Photons_PIEchannel = TcspcData.(type){Det,Rout}(...
            TcspcData.MI{Det,Rout} >= From &...
            TcspcData.MI{Det,Rout} <= To &...
            TcspcData.MT{Det,Rout} >= Times(block) &...
            TcspcData.MT{Det,Rout} < Times(block+1));
        
    elseif nargin == 4 %%% read only the specified chunk
        %%% define the chunk start and stop time based on chunksize and measurement
        %%% time
        %%% Determine Macrotime Boundaries from ChunkNumber and ChunkSize
        %%% (defined in minutes)
        LimitLow = (block-1)*chunk*60/FileInfo.SyncPeriod+1;
        LimitHigh = block*chunk*60/FileInfo.SyncPeriod;
        
        Photons_PIEchannel = TcspcData.(type){Det,Rout}(...
            TcspcData.MI{Det,Rout} >= From &...
            TcspcData.MI{Det,Rout} <= To &...
            TcspcData.MT{Det,Rout} >= LimitLow &...
            TcspcData.MT{Det,Rout} < LimitHigh);
    end
else %%% PIE channel contains no photons
    Photons_PIEchannel = [];
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function generating deleting and selecting profiles  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "+"-Key or Add menu: Generate new profile
%%% "-"-Key, "del"-Key or Delete menu: Deletes selected profile
%%% "enter"-Key or Select menu: Makes selected profile current profile
function Update_Profiles(obj,ed)
h=guidata(findobj('Tag','Pam'));
global UserValues
%% obj is empty, if function was called during initialization
if isempty(obj)
    %%% findes current profile
    load([pwd filesep 'profiles' filesep 'profile.mat']);    
    for i=1:numel(h.Profiles_List.String)
        %%% Looks for current profile in profiles list
        if strcmp(h.Profiles_List.String{i}, Profile) %#ok<NODEF>
            %%% Changes color to indicate current profile
            h.Profiles_List.String{i}=['<HTML><FONT color=FF0000>' h.Profiles_List.String{i} '</Font></html>'];
            return
        end        
    end
end
%% Determines which buttons was pressed, if function was not called via key press
if ~strcmp(ed.EventName,'KeyPress')
    if obj == h.Profiles_Add
        e.Key='add';
    elseif obj == h.Profiles_Delete
        e.Key='delete';
    elseif obj == h.Profiles_Select;
        e.Key='return';
    elseif obj == h.Profiles_Duplicate
        e.Key = 'duplicate';
    else
        e.Key='';
    end
else
    e.Key=ed.Key;
end
%% Determines, which Key/Button was pressed
Sel=h.Profiles_List.Value;
switch e.Key
    case 'add'
        %% Adds a new profile
        %%% Get profile name
        Name=inputdlg('Enter profile name:');
        %%% Creates new file and list entry if input was not empty
        if ~isempty(Name)            
            PIE=[];
            save([pwd filesep 'profiles' filesep Name{1} '.mat'],'PIE');
            h.Profiles_List.String{end+1}=[Name{1} '.mat'];
        end        
    case {'delete';'subtract'}
        %% Deletes selected profile
        if numel(h.Profiles_List.String)>1
            %%% If selected profile is not the current profile
            if isempty(strfind(h.Profiles_List.String{Sel},'<HTML><FONT color=FF0000>'))
                %%% Deletes profile file and list entry
                delete([pwd filesep 'profiles' filesep h.Profiles_List.String{Sel}])
                h.Profiles_List.String(Sel)=[];
            else
                %%% Deletes profile file and list entry
                delete([pwd filesep 'profiles' filesep h.Profiles_List.String{Sel}(26:(end-14))])
                h.Profiles_List.String(Sel)=[];
                %%% Selects first profile as current profile
                Profile=h.Profiles_List.String{1};
                save([pwd filesep 'profiles' filesep 'Profile.mat'],'Profile');
                %%% Updates UserValues
                LSUserValues(1);
                %%% Changes color to indicate current profile
                h.Profiles_List.String{1}=['<HTML><FONT color=FF0000>' h.Profiles_List.String{1} '</Font></html>']; 
                Update_Detector_Channels([],[],[1,2]);
                Update_Data([],[],0,0);
                Update_Display([],[],0);
            end  
            %%% Move selection to last entry
            if numel(h.Profiles_List.String) <Sel
                h.Profiles_List.Value=numel(h.Profiles_List.String);
            end
            
        end
    case 'return'
        %%% Only executes if 
        if isempty(strfind(h.Profiles_List.String{Sel},'<HTML><FONT color=FF0000>'))
            for i=1:numel(h.Profiles_List.String)
                if~isempty(strfind(h.Profiles_List.String{i},'<HTML><FONT color=FF0000>'))
                    h.Profiles_List.String{i}=h.Profiles_List.String{i}(26:(end-14));
                    break;
                end
            end
            %%% Makes selected profile the current profile
            Profile=h.Profiles_List.String{Sel};
            save([pwd filesep 'profiles' filesep 'Profile.mat'],'Profile');
            %%% Updates UserValues
            LSUserValues(0);
            %%% Changes color to indicate current profile
            h.Profiles_List.String{Sel}=['<HTML><FONT color=FF0000>' h.Profiles_List.String{Sel} '</Font></html>']; 
            
            %%% Resets applied shift to zero; might lead to overcorrection
            Update_to_UserValues;
            Update_Data([],[],0,0);
            Update_Detector_Channels([],[],[1,2]);
            Update_Display([],[],0);
            %%% Update export table
            h.Export.PIE.RowName = [UserValues.PIE.Name, {'All'}];
            h.Export.PIE.Data = false(numel(UserValues.PIE.Name)+1,1);
        end
    case 'duplicate'
        %% Duplicates selected profile
        %%% Get profile name
        Name=inputdlg('Enter profile name:');
        %%% Creates new file and list entry if input was not empty
        if ~isempty(Name)            
            save([pwd filesep 'profiles' filesep Name{1} '.mat'],'-struct','UserValues');
            h.Profiles_List.String{end+1}=[Name{1} '.mat'];
        end      
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to adjust setting to UserValues if a new profile was loaded  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_to_UserValues
global UserValues
h=guidata(findobj('Tag','Pam'));

h.MT_Binning.String=UserValues.Settings.Pam.MT_Binning;
h.MT_Time_Section.String=UserValues.Settings.Pam.MT_Time_Section;
h.MT_Number_Section.String=UserValues.Settings.Pam.MT_Number_Section;

%%% Sets Correlation table to UserValues
h.Cor_Table.RowName=[UserValues.PIE.Name 'Column'];
h.Cor_Table.ColumnName=[UserValues.PIE.Name 'Row'];
h.Cor_Table.Data=false(numel(UserValues.PIE.Name)+1);
h.Cor_Table.ColumnEditable=true(numel(UserValues.PIE.Name)+1,1)';
ColumnWidth=cellfun(@length,UserValues.PIE.Name).*6+16;
ColumnWidth(end+1)=37; %%% Row = 3*8+16;
h.Cor_Table.ColumnWidth=num2cell(ColumnWidth);
h.Cor_Table.Data = UserValues.Settings.Pam.Cor_Selection;
h.Cor_Multi_Menu.Checked=UserValues.Settings.Pam.Multi_Core;
h.Cor_Divider_Menu.Label=['Divider: ' num2str(UserValues.Settings.Pam.Cor_Divider)];

%%% Updates Detector calibration and Phasor channel lists
List=UserValues.Detector.Name;
h.MI_Phasor_Det.String=List;
h.MI_Calib_Det.String=List;
h.MI_Phasor_Det.Value=1;
h.MI_Calib_Det.Value=1;    

%%% Sets BurstSearch GUI according to UserValues
Update_BurstGUI([],[]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for keeping correlation table updated  %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Cor_Table(obj,e)
global UserValues
h=guidata(findobj('Tag','Pam'));

%%% Is executed, if one of the checkboxes was clicked
if obj == h.Cor_Table
    %%% Activate/deactivate column
    if e.Indices(1) == size(h.Cor_Table.Data,1) && e.Indices(2) < size(h.Cor_Table.Data,2)
        h.Cor_Table.Data(1:end-1,e.Indices(2))=e.NewData;
    %%% Activate/deactivate row
    elseif e.Indices(2) == size(h.Cor_Table.Data,2) && e.Indices(1) < size(h.Cor_Table.Data,1)
        h.Cor_Table.Data(e.Indices(1),1:end-1)=e.NewData;
    %%% Activate/deactivate diagonal
    elseif e.Indices(1) == size(h.Cor_Table.Data,1) && e.Indices(2) == size(h.Cor_Table.Data,2)
        for i=1:(size(h.Cor_Table.Data,2)-1)
            h.Cor_Table.Data(i,i)=e.NewData;
        end
    
    end
end

%%% Activates/deactivates column/row/diagonal checkboxes
%%% Is done here to update, if new PIE channel was created
for i=1:size(h.Cor_Table.Data,1)
    if any(~h.Cor_Table.Data(i,1:end-1))
        h.Cor_Table.Data(i,end)=false;
    else
        h.Cor_Table.Data(i,end)=true;
    end
    if any(~h.Cor_Table.Data(1:end-1,i))
        h.Cor_Table.Data(end,i)=false;
    else
        h.Cor_Table.Data(end,i)=true;
    end
end
if any(~diag(h.Cor_Table.Data(1:end-1,1:end-1)))
    h.Cor_Table.Data(end)=false;
else
    h.Cor_Table.Data(end)=true;
end

if obj == h.Cor_Table
    %%% Store Selection Change in UserValues
    UserValues.Settings.Pam.Cor_Selection = h.Cor_Table.Data;
end
LSUserValues(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for correlating data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Correlate (~,~,mode)
h=guidata(findobj('Tag','Pam'));
global UserValues TcspcData FileInfo PamMeta

h.Progress_Text.String = 'Starting Correlation';
h.Progress_Axes.Color=[1 0 0];

if mode==2 %%% For Multiple Correlation
    %%% following code is for remembering the last used FileType
    LSUserValues(0);    
    %%% Loads all possible file types
    Filetypes = UserValues.File.SPC_FileTypes;
    %%% Finds last used file type
    Lastfile = UserValues.File.OpenTCSPC_FilterIndex;
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
    %%% Initializes matlabpool for paralell computation
    if strcmp(h.Cor_Multi_Menu.Checked,'on')
        Pool=gcp;
        if isempty(Pool)
            h.Progress_Text.String='Opening matlabpool';
            drawnow;
            parpool('local');
        end        
    end
end

for m=NCors %%% Goes through every File selected (multiple correlation) or just the one already loaded(single file correlation)   
    if mode==2 %%% Loads new file
        h.Progress_Text.String='Loading new file';
        LoadTcspc([],[],@Update_Data,@Update_Display,@Shift_Detector,h.Pam,File{m},Type);
    end    
    %%% Finds the right combinations to correlate
    [Cor_A,Cor_B]=find(h.Cor_Table.Data(1:end-1,1:end-1));
    %%% Calculates the maximum inter-photon time in clock ticks
    Maxtime=ceil(max(diff(PamMeta.MT_Patch_Times))/FileInfo.SyncPeriod)/UserValues.Settings.Pam.Cor_Divider;
    %%% Calculates the photon start times in clock ticks
    Times=ceil(PamMeta.MT_Patch_Times/FileInfo.SyncPeriod);
    %%% Uses truncated Filename
    switch FileInfo.FileType
        case {'FabsurfSPC','SPC'}
            FileName = FileInfo.FileName{1}(1:end-5);
        case {'HydraHar?','FabSurf-HydraHarp','Simulation'}
            FileName = FileInfo.FileName{1}(1:end-4);
        otherwise
            FileName = FileInfo.FileName{1}(1:end-5);                
    end
    drawnow;    
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
        
        switch h.Cor_Type.Value %%% Assigns photons and does correlation
            case 1 %%% Point correlation
                %%% Initializes data cells
                Data1=cell(sum(PamMeta.Selected_MT_Patches),1);
                Data2=cell(sum(PamMeta.Selected_MT_Patches),1);
                k=1;
                Counts1=0;
                Counts2=0;
                Valid=find(PamMeta.Selected_MT_Patches)';
                %%% Seperate calculation for each block
                for j=find(PamMeta.Selected_MT_Patches)'
                    Data1{k}=[];
                    %%% Combines all photons to one vector
                    for l=1:numel(Det1)
                        if ~isempty(TcspcData.MI{Det1(l),Rout1(l)})
                            Data1{k}=[Data1{k};...
                                TcspcData.MT{Det1(l),Rout1(l)}(...
                                TcspcData.MI{Det1(l),Rout1(l)}>=From1(l) &...
                                TcspcData.MI{Det1(l),Rout1(l)}<=To1(l) &...
                                TcspcData.MT{Det1(l),Rout1(l)}>=Times(j) &...
                                TcspcData.MT{Det1(l),Rout1(l)}<Times(j+1))-Times(j)];
                        end
                    end
                    %%% Calculates total photons
                    Counts1=Counts1+numel(Data1{k});
                    
                    %%% Only executes if channel1 is not empty
                    if ~isempty(Data1{k})
                        Data2{k}=[];
                        %%% Combines all photons to one vector
                        for l=1:numel(Det2)
                            if ~isempty(TcspcData.MI{Det2(l),Rout2(l)})
                                Data2{k}=[Data2{k};...
                                    TcspcData.MT{Det2(l),Rout2(l)}(...
                                    TcspcData.MI{Det2(l),Rout2(l)}>=From2(l) &...
                                    TcspcData.MI{Det2(l),Rout2(l)}<=To2(l) &...
                                    TcspcData.MT{Det2(l),Rout2(l)}>=Times(j) &...
                                    TcspcData.MT{Det2(l),Rout2(l)}<Times(j+1))-Times(j)];
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
                [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data2,Maxtime);
                Cor_Times=Cor_Times*FileInfo.SyncPeriod*UserValues.Settings.Pam.Cor_Divider;
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
                
                if any(h.Cor_Format.Value == [1 3])
                    %%% Generates filename
                    Current_FileName=fullfile(FileInfo.Path,[FileName '_' PIE_Name1 '_x_' PIE_Name2 '.mcor']);
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
                    Counts = [Counts1 Counts2]/FileInfo.MeasurementTime/1000*numel(PamMeta.Selected_MT_Patches)/numel(Valid); %#ok<NASGU>
                    save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');  
                end
                
                if any(h.Cor_Format.Value == [2 3])
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
                    
                    %%% Writes Heater
                    fprintf(FileID, ['Correlation file for: ' strrep(fullfile(FileInfo.Path, FileName),'\','\\') ' of Channels ' UserValues.PIE.Name{Cor_A(i)} ' cross ' UserValues.PIE.Name{Cor_A(i)} '\n']);
                    fprintf(FileID, ['Countrate channel 1 [kHz]: ' num2str(Counts(1), '%12.2f') '\n']);
                    fprintf(FileID, ['Countrate channel 2 [kHz]: ' num2str(Counts(2), '%12.2f') '\n']);
                    fprintf(FileID, ['Valid bins: ' num2str(Valid) '\n']);
                    %%% Indicates start of data
                    fprintf(FileID, ['Data starts here: ' '\n']);
                    
                    %%% Writes data as columns: Time    Averaged    SEM     Individual bins
                    fprintf(FileID, ['%8.12f\t%8.8f\t%8.8f' repmat('\t%8.8f',1,numel(Valid)) '\n'], [Cor_Times Cor_Average Cor_SEM Cor_Array]');
                    fclose(FileID);
                end
                
                Progress(1);
                Progress((i)/numel(Cor_A),h.Progress_Axes,h.Progress_Text,'Correlating :')                
            case 2 %%% Pair correlation
                Bins=str2double(h.Cor_Pair_Bins.String);
                Dist=[0,str2num(h.Cor_Pair_Dist.String)]; %#ok<ST2NM>
                Dist= Dist(Dist<Bins); 
                Times = (Times*FileInfo.SyncPeriod*FileInfo.ScanFreq);
                Maxtime = max(diff(Times));
                h.Progress_Text.String='Assigning photons to bins';
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
                Valid = find(PamMeta.Selected_MT_Patches);
                Data = Data*FileInfo.SyncPeriod*FileInfo.ScanFreq;
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
                    for m = Valid'                        
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
                    Valid = find(PamMeta.Selected_MT_Patches);
                    Data = Data*FileInfo.SyncPeriod*FileInfo.ScanFreq;
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
                        for m = Valid'
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
                Progress(0,h.Progress_Axes, h.Progress_Text,'Calculating PCF:');
                h.Progress_Axes.Color=UserValues.Look.Control;
                for j=1:Bins %%% Goes through every bin
                    for l=Dist %%% Goes through every selected bin distance
                        if (l+j)<=Bins %%% Checks if bin distance is valid
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
                        end                        
                    end
                    Progress(j/Bins,h.Progress_Axes, h.Progress_Text,'Calculating PCF:');
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
    Update_Display([],[],1);
end
%%% Set FCSFit Path to FilePath
UserValues.File.FCSPath = FileInfo.Path;
LSUserValues(1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to keep shift equal  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Phasor_Shift(obj,~)
h=guidata(findobj('Tag','Pam'));
if obj==h.MI_Phasor_Shift
    h.MI_Phasor_Slider.Value=str2double(h.MI_Phasor_Shift.String);
elseif obj==h.MI_Phasor_Slider
    h.MI_Phasor_Shift.String=num2str(h.MI_Phasor_Slider.Value);
end
Update_Display([],[],6);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to assign histogram as Phasor reference %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Phasor_UseRef(~,~)
global UserValues PamMeta
h=guidata(findobj('Tag','Pam'));
Det=h.MI_Phasor_Det.Value;
%%% Sets reference to 0 in case of shorter MI length
UserValues.Phasor.Reference(Det,:)=0;
%%% Assigns current MI histogram as reference
UserValues.Phasor.Reference(Det,1:numel(PamMeta.MI_Hist{Det}))=PamMeta.MI_Hist{Det};

%%% Anders: Highjacking this to also save an IRF for Lifetime Fitting
for i = 1:max(UserValues.Detector.Det)
    UserValues.TauFit.IRF(i,1:numel(PamMeta.MI_Hist{i}))=PamMeta.MI_Hist{i};
end

LSUserValues(1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to calculate and save Phasor Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Phasor_Calc(~,~)   
global UserValues TcspcData FileInfo PamMeta
h=guidata(findobj('Tag','Pam'));
if isfield(UserValues,'Phasor') && isfield(UserValues.Phasor,'Reference') 
    
    %%% Determines correct detector and routing
    Det=UserValues.Detector.Det(h.MI_Phasor_Det.Value);
    Rout=UserValues.Detector.Rout(h.MI_Phasor_Det.Value);
    %%% Selects filename to save
    [FileName,PathName] = uiputfile('*.phr','Save Phasor Data',UserValues.File.PhasorPath);
    
    if ~all(FileName==0)
        Progress(0,h.Progress_Axes, h.Progress_Text,'Calculating Phasor Data:');
        
        %%% Saves pathname
        UserValues.File.PhasorPath=PathName;
        LSUserValues(1);

        Shift=h.MI_Phasor_Slider.Value;
        Bins=FileInfo.MI_Bins;
        TAC=str2double(h.MI_Phasor_TAC.String);
        Ref_LT=str2double(h.MI_Phasor_Ref.String);
        From=str2double(h.MI_Phasor_From.String);
        To=str2double(h.MI_Phasor_To.String);
        
        %%% Calculates theoretical phase and modulation for reference
        Fi_ref = atan(2*pi*Ref_LT/TAC);
        M_ref  = 1/sqrt(1+(2*pi*Ref_LT/TAC)^2);
        
        %%% Normalizes reference data
        Ref=circshift(UserValues.Phasor.Reference(h.MI_Phasor_Det.Value,:)/sum(UserValues.Phasor.Reference(h.MI_Phasor_Det.Value,:)),[0 Shift]);
        if From>1
            Ref(1:(From-1))=0;
        end
        if To<Bins
            Ref(To+1:Bins)=0;
        end
        Ref_Mean=sum(Ref.*(1:Bins))/sum(Ref)*TAC/Bins-Ref_LT;       
        
        %%% Calculates phase and modulation of the instrument
        G_inst(1:Bins)=cos((2*pi./Bins)*(1:Bins)-Fi_ref)/M_ref;
        S_inst(1:Bins)=sin((2*pi./Bins)*(1:Bins)-Fi_ref)/M_ref;
        g_inst=sum(Ref(1:Bins).*G_inst);
        s_inst=sum(Ref(1:Bins).*S_inst);
        Fi_inst=atan(s_inst/g_inst);
        M_inst=sqrt(s_inst^2+g_inst^2);
        if (g_inst<0 && s_inst<0)
            Fi_inst=Fi_inst+pi;
        end
        
        %%% Selects and sorts photons;
        Photons=TcspcData.MT{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To)*FileInfo.SyncPeriod;        
        [Photons,Index]=sort(mod(Photons,FileInfo.ImageTime));
        Index=uint32(Index);
        
        %%% Calculates Pixel vector
        Pixeltimes=0;
        for j=1:FileInfo.Lines
            Pixeltimes(end:(end+FileInfo.Lines))=linspace(FileInfo.LineTimes(j),FileInfo.LineTimes(j+1),FileInfo.Lines+1);
        end
        
        %%% Calculates, which Photons belong to which pixel
        Intensity=histc(Photons,Pixeltimes(1:end-1).*FileInfo.SyncPeriod);        
        clear Photons
        Pixel=[1;cumsum(Intensity)];
        Pixel(Pixel==0)=1;
        %%% Sorts Microtimes
        Photons=TcspcData.MI{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To);
        Photons=Photons(Index);
        clear Index
        
        %%% Calculates phasor data for each pixel
        G(1:Bins)=cos((2*pi/Bins).*(1:Bins)-Fi_inst)/M_inst;
        S(1:Bins)=sin((2*pi/Bins).*(1:Bins)-Fi_inst)/M_inst;        
        g=zeros(FileInfo.Lines);
        s=zeros(FileInfo.Lines);
        Mean_LT=zeros(FileInfo.Lines);
        FLIM=zeros(1,Bins);
        flim=FLIM;
        for i=1:(numel(Pixel)-1)
            FLIM(:)=histc(Photons(Pixel(i):(Pixel(i+1)-1)),0:(Bins-1));
            flim=flim+FLIM;
            Mean_LT(i)=(sum(FLIM.*(1:Bins))/sum(FLIM))*TAC/Bins-Ref_Mean;
            g(i)=sum(G.*FLIM)/sum(FLIM);
            s(i)=sum(S.*FLIM)/sum(FLIM);
            if isnan(g(i)) || isnan(s(i))
                g(i)=0; s(i)=0;
            end
            if mod(i,FileInfo.Lines)==0
                Progress(i/(numel(Pixel)-1),h.Progress_Axes, h.Progress_Text,'Calculating Phasor Data:');
            end
        end
        g=flip(g',1);s=flip(s',1);
        
        neg=find(g<0 & s<0);
        g(neg)=-g(neg);
        s(neg)=-s(neg);
        
        %%% Calculates additional data
        PamMeta.Fi=atan(s./g); PamMeta.Fi(isnan(PamMeta.Fi))=0;
        PamMeta.M=sqrt(s.^2+g.^2);PamMeta.Fi(isnan(PamMeta.M))=0;
        PamMeta.TauP=real(tan(PamMeta.Fi)./(2*pi/TAC));PamMeta.TauP(isnan(PamMeta.TauP))=0;
        PamMeta.TauM=real(sqrt((1./(s.^2+g.^2))-1)/(2*pi/TAC));PamMeta.TauM(isnan(PamMeta.TauM))=0;
        PamMeta.g=g;
        PamMeta.s=s;
        PamMeta.Phasor_Int=flip(reshape(Intensity,[FileInfo.Lines,FileInfo.Lines])',1);
        
        %%% Creates data to save and saves referenced file
        Freq=1/TAC*10^9;
        Frames=FileInfo.NumberOfFiles;
        FileNames=FileInfo.FileName;
        Path=FileInfo.Path;
        Imagetime=FileInfo.ImageTime;
        Lines=FileInfo.Lines;
        Fi=PamMeta.Fi;
        M=PamMeta.M;
        TauP=PamMeta.TauP;
        TauM=PamMeta.TauM;
        Intensity=reshape(Intensity,[Lines,Lines]);
        Intensity=flip(Intensity',1);
        Type = FileInfo.Type;
        save(fullfile(PathName,FileName), 'g','s','Mean_LT','Fi','M','TauP','TauM','Intensity','Lines','Freq','Imagetime','Frames','FileNames','Path','Type'); 
        
        h.Image_Type.String={'Intensity';'Mean arrival time';'TauP';'TauM';'g';'s'};
    end
    
    h.Progress_Text.String = FileInfo.FileName{1};
    h.Progress_Axes.Color=UserValues.Look.Control;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for keeping Burst GUI updated  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_BurstGUI(obj,~)
global UserValues
h=guidata(findobj('Tag','Pam'));
if obj == h.BurstSearchSelection_Popupmenu %executed on change in Popupmenu
    %update the UserValues
    UserValues.BurstSearch.Method = obj.Value;
    BAMethod = h.BurstSearchMethods{UserValues.BurstSearch.Method};
    LSUserValues(1);
else %executed on startup, set GUI according to stored BurstSearch Method in UserValues settings
    BAMethod = h.BurstSearchMethods{UserValues.BurstSearch.Method};
    h.BurstSearchSelection_Popupmenu.Value = UserValues.BurstSearch.Method;
end
TableContent = h.BurstPIE_Table_Content.(BAMethod);
h.BurstPIE_Table.RowName = TableContent.RowName;
h.BurstPIE_Table.ColumnName = TableContent.ColumnName;
h.BurstPIE_Table.ColumnEditable=true(numel(h.BurstPIE_Table.ColumnName),1)';

BurstPIE_Table_Data = UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}; 
BurstPIE_Table_Format = cell(1,size(BurstPIE_Table_Data,2));
BurstPIE_Table_Format(:) = {UserValues.PIE.Name};

BurstPIE_Table_Data = UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}; 
h.BurstPIE_Table.Data = BurstPIE_Table_Data;
h.BurstPIE_Table.ColumnFormat = BurstPIE_Table_Format;

switch BAMethod %%% define which Burst Search Parameters are to be displayed
    case 'APBS_twocolorMFD'
        h.BurstParameter3_Text.String = 'Photons per Time Window:';
        h.BurstParameter4_Text.Visible = 'off';
        h.BurstParameter4_Edit.Visible = 'off';
        h.BurstParameter5_Text.Visible = 'off';
        h.BurstParameter5_Edit.Visible = 'off';
    case 'DCBS_twocolorMFD'
        h.BurstParameter3_Text.String = 'Photons per Time Window GX:';
        h.BurstParameter4_Text.Visible = 'on';
        h.BurstParameter4_Text.String = 'Photons per Time Window RR:';
        h.BurstParameter4_Edit.Visible = 'on';
        h.BurstParameter5_Text.Visible = 'off';
        h.BurstParameter5_Edit.Visible = 'off';
    case 'APBS_threecolorMFD'
        h.BurstParameter3_Text.String = 'Photons per Time Window:';
        h.BurstParameter4_Text.Visible = 'off';
        h.BurstParameter4_Edit.Visible = 'off';
        h.BurstParameter5_Text.Visible = 'off';
        h.BurstParameter5_Edit.Visible = 'off';
    case 'TCBS_threecolorMFD'
        h.BurstParameter3_Text.String = 'Photons per Time Window BX:';
        h.BurstParameter4_Text.Visible = 'on';
        h.BurstParameter4_Text.String = 'Photons per Time Window GX.';
        h.BurstParameter4_Edit.Visible = 'on';
        h.BurstParameter5_Text.Visible = 'on';
        h.BurstParameter5_Text.String = 'Photons per Time Window RR:';
        h.BurstParameter5_Edit.Visible = 'on';
    case 'APBS_twocolornoMFD'
        h.BurstParameter3_Text.String = 'Photons per Time Window:';
        h.BurstParameter4_Text.Visible = 'off';
        h.BurstParameter4_Edit.Visible = 'off';
        h.BurstParameter5_Text.Visible = 'off';
        h.BurstParameter5_Edit.Visible = 'off';
end

%set parameter for the edit boxes
h.BurstParameter1_Edit.String = num2str(UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.Method}(1));
h.BurstParameter2_Edit.String = num2str(UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.Method}(2));
h.BurstParameter3_Edit.String = num2str(UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.Method}(3));
h.BurstParameter4_Edit.String = num2str(UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.Method}(4));
h.BurstParameter5_Edit.String = num2str(UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.Method}(5));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for updating BurstSearch Parameters in UserValues %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BurstSearchParameterUpdate(obj,~)
global UserValues
h=guidata(findobj('Tag','Pam'));
if obj == h.BurstPIE_Table %change in PIE channel selection
    UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method} = obj.Data;
else %change in edit boxes
    UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.Method} = [str2double(h.BurstParameter1_Edit.String),...
        str2double(h.BurstParameter2_Edit.String), str2double(h.BurstParameter3_Edit.String), str2double(h.BurstParameter4_Edit.String),...
        str2double(h.BurstParameter5_Edit.String)];
end
LSUserValues(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Performs a Burst Analysis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_BurstAnalysis(~,~)
global FileInfo UserValues
%% Initialization
h = guidata(findobj('Tag','Pam'));
%%% clear preview burst data still in workspace
clearvars -global BurstData
global BurstData

%%% Set Progress Bar
h.Progress_Text.String = 'Performing Burst Search...';
drawnow;

%%% Reset BurstSearch Button Color
h.Burst_Button.ForegroundColor = UserValues.Look.Fore;
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
%achieve loading of less photons by using chunksize of preview and first
%chunk
ChunkSize = 30; %30 minutes, hard-coded for now
Number_of_Chunks = ceil(FileInfo.MeasurementTime/(ChunkSize*60));
%%% Preallocation
Macrotime_dummy = cell(Number_of_Chunks,1);
Microtime_dummy = cell(Number_of_Chunks,1);
Channel_dummy = cell(Number_of_Chunks,1);

if UserValues.BurstSearch.SaveTotalPhotonStream
    start_all = cell(Number_of_Chunks,1);
    stop_all = cell(Number_of_Chunks,1);
    Macrotime_all = cell(Number_of_Chunks,1);
    Microtime_all = cell(Number_of_Chunks,1);
    Channel_all = cell(Number_of_Chunks,1);
end

for i = 1:Number_of_Chunks
    Progress((i-1)/Number_of_Chunks,h.Progress_Axes, h.Progress_Text,'Performing Burst Search...');
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
        
        if BAMethod == 1
            T = UserValues.BurstSearch.SearchParameters{BAMethod}(2);
            M = UserValues.BurstSearch.SearchParameters{BAMethod}(3);
            L = UserValues.BurstSearch.SearchParameters{BAMethod}(1);
            [start, stop, Number_of_Photons] = Perform_BurstSearch(AllPhotons,[],'APBS',T,M,L);
        elseif BAMethod == 2
            T = UserValues.BurstSearch.SearchParameters{BAMethod}(2);
            M = [UserValues.BurstSearch.SearchParameters{BAMethod}(3),...
                UserValues.BurstSearch.SearchParameters{BAMethod}(4)];
            L = UserValues.BurstSearch.SearchParameters{BAMethod}(1);
            [start, stop, Number_of_Photons] = Perform_BurstSearch(AllPhotons,Channel,'DCBS',T,M,L);
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
        
        if BAMethod == 3 %ACBS 3 Color
            T = UserValues.BurstSearch.SearchParameters{BAMethod}(2);
            M = UserValues.BurstSearch.SearchParameters{BAMethod}(3);
            L = UserValues.BurstSearch.SearchParameters{BAMethod}(1);
            [start, stop, Number_of_Photons] = Perform_BurstSearch(AllPhotons,[],'APBS',T,M,L);
        elseif BAMethod == 4 %TCBS
            T = UserValues.BurstSearch.SearchParameters{BAMethod}(2);
            M = [UserValues.BurstSearch.SearchParameters{BAMethod}(3),...
                UserValues.BurstSearch.SearchParameters{BAMethod}(4),...
                UserValues.BurstSearch.SearchParameters{BAMethod}(5)];
            L = UserValues.BurstSearch.SearchParameters{BAMethod}(1);
            [start, stop, Number_of_Photons] = Perform_BurstSearch(AllPhotons,Channel,'TCBS',T,M,L);
        end
        
    elseif BAMethod == 5 %2 color no MFD
        %prepare photons
        %read out macrotimes for all channels
        Photons{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Macrotime',i,ChunkSize);
        Photons{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Macrotime',i,ChunkSize);
        Photons{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Macrotime',i,ChunkSize);
        AllPhotons_unsort = horzcat(Photons{:});
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
        
        %do search
        T = UserValues.BurstSearch.SearchParameters{BAMethod}(2);
        M = UserValues.BurstSearch.SearchParameters{BAMethod}(3);
        L = UserValues.BurstSearch.SearchParameters{BAMethod}(1);
        [start, stop, Number_of_Photons] = Perform_BurstSearch(AllPhotons,[],'APBS',T,M,L);
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
end
%%% Concatenate data from chunks
Macrotime = vertcat(Macrotime_dummy{:});
Microtime = vertcat(Microtime_dummy{:});
Channel = vertcat(Channel_dummy{:});

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
%% Parameter Calculation
Progress(0,h.Progress_Axes, h.Progress_Text, 'Calculating Burstwise Parameters...');

Number_of_Bursts = numel(Macrotime);

Number_of_Photons = cellfun(@numel,Macrotime);
Mean_Macrotime = cellfun(@mean,Macrotime)*FileInfo.SyncPeriod;
Duration = cellfun(@(x) max(x)-min(x),Macrotime)*FileInfo.SyncPeriod/1E-3;

Progress(0.1,h.Progress_Axes, h.Progress_Text, 'Calculating Burstwise Parameters...');

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
    
    Progress(0.3,h.Progress_Axes, h.Progress_Text, 'Calculating Burstwise Parameters...');
      
    Number_of_Photons_per_Color = zeros(Number_of_Bursts,3);
    for i = 1:3
        Number_of_Photons_per_Color(:,i) = Number_of_Photons_per_Chan(:,2*i-1)+Number_of_Photons_per_Chan(:,2*i);
    end
    Mean_Macrotime_per_Chan = zeros(Number_of_Bursts,6);
    Duration_per_Chan = cell(Number_of_Bursts,6);
    for i = 1:6 %only calculate Mean Macrotime for combined channels GG, GR, RR
        Mean_Macrotime_per_Chan(:,i) = cellfun(@(x,y) mean(x(y == i)),Macrotime, Channel)*FileInfo.SyncPeriod;
        Duration_per_Chan(:,i) = cellfun(@(x,y) max(x(y == i))-min(x(y == i)),Macrotime,Channel,'UniformOutput',false);
    end
    
    Progress(0.5,h.Progress_Axes, h.Progress_Text, 'Calculating Burstwise Parameters...');

    Mean_Macrotime_per_Color = zeros(Number_of_Bursts,4);
    Duration_per_Color = cell(Number_of_Bursts,4);
    for i = 1:3 %only calculate Mean Macrotime for combined channels GG, GR, RR
        Mean_Macrotime_per_Color(:,i) = cellfun(@(x,y) mean(x(y == 2*i-1 | y == 2*i)),Macrotime, Channel)*FileInfo.SyncPeriod;
        Duration_per_Color(:,i) = cellfun(@(x,y) max(x(y == 2*i-1 | y == 2*i))-min(x(y == 2*i-1 | y == 2*i)),Macrotime,Channel,'UniformOutput',false);
    end
    
    Progress(0.6,h.Progress_Axes, h.Progress_Text, 'Calculating Burstwise Parameters...');    
    %Also calculate GX
    Mean_Macrotime_per_Color(:,4) = cellfun(@(x,y) mean(x(y == 1 | y == 2 | y == 3 | y == 4)),Macrotime, Channel)*FileInfo.SyncPeriod;
    Duration_per_Color(:,4) = cellfun(@(x,y) max(x(y == 1 | y == 2 | y == 3 | y == 4))-min(x(y == 1 | y == 2 | y == 3 | y == 4)),Macrotime,Channel,'UniformOutput',false);
       
    %there are empty cells for Duration_per_Chan if Channels are empty
    ix=cellfun('isempty',Duration_per_Chan);
    Duration_per_Chan(ix)={nan};
    Duration_per_Chan = cell2mat(Duration_per_Chan)*FileInfo.SyncPeriod/1E-3;
    
    ix=cellfun('isempty',Duration_per_Color);
    Duration_per_Color(ix)={nan};
    Duration_per_Color = cell2mat(Duration_per_Color)*FileInfo.SyncPeriod/1E-3;
    
    %Determine TGG-TGR and TGX-TRR
    TGG_TGR = abs(Mean_Macrotime_per_Color(:,1)-Mean_Macrotime_per_Color(:,2));
    TGX_TRR = abs(Mean_Macrotime_per_Color(:,4)-Mean_Macrotime_per_Color(:,3));
    %also provide normalized quantities
    TGG_TGR(:,2) = TGG_TGR(:,1)./Duration;
    TGX_TRR(:,2) = TGX_TRR(:,1)./Duration;
    TGG_TGR(:,1) = TGG_TGR(:,1)./1E-3;
    TGX_TRR(:,1) = TGX_TRR(:,1)./1E-3;
    
    Progress(0.8,h.Progress_Axes, h.Progress_Text, 'Calculating Burstwise Parameters...');    
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
        Mean_Macrotime_per_Chan(:,i) = cellfun(@(x,y) mean(x(y == i)),Macrotime, Channel)*FileInfo.SyncPeriod;
        Duration_per_Chan(:,i) = cellfun(@(x,y) max(x(y == i))-min(x(y == i)),Macrotime,Channel,'UniformOutput',false);
    end
    
    Mean_Macrotime_per_Color = zeros(Number_of_Bursts,8);
    Duration_per_Color = cell(Number_of_Bursts,8);
    for i = 1:6 %only calculate Mean Macrotime for combined channels GG, GR, RR
        Mean_Macrotime_per_Color(:,i) = cellfun(@(x,y) mean(x(y == 2*i-1 | y == 2*i)),Macrotime, Channel)*FileInfo.SyncPeriod;
        Duration_per_Color(:,i) = cellfun(@(x,y) max(x(y == 2*i-1 | y == 2*i))-min(x(y == 2*i-1 | y == 2*i)),Macrotime,Channel,'UniformOutput',false);
    end
    
    %Also for BX and GX
    Mean_Macrotime_per_Color(:,7) = cellfun(@(x,y) mean(x(y == 1 | y == 2 | y == 3 | y == 4 | y == 5 | y == 6)),Macrotime, Channel)*FileInfo.SyncPeriod;
    Mean_Macrotime_per_Color(:,8) = cellfun(@(x,y) mean(x(y == 7 | y == 8 | y == 9 | y == 10)),Macrotime, Channel)*FileInfo.SyncPeriod;
    Duration_per_Color(:,7) = cellfun(@(x,y) max(x(y == 1 | y == 2 | y == 3 | y == 4 | y == 5 | y == 6)) - min(x(y == 1 | y == 2 | y == 3 | y == 4 | y == 5 | y == 6)),Macrotime,Channel,'UniformOutput',false);
    Duration_per_Color(:,8) = cellfun(@(x,y) max(x(y == 7 | y == 8 | y == 9 | y == 10)) - min(x(y == 7 | y == 8 | y == 9 | y == 10)),Macrotime,Channel,'UniformOutput',false);
    
    %there are empty cells for Duration_per_Chan if Channels are empty
    ix=cellfun('isempty',Duration_per_Chan);
    Duration_per_Chan(ix)={nan};
    Duration_per_Chan = cell2mat(Duration_per_Chan)*FileInfo.SyncPeriod/1E-3;
    
    ix=cellfun('isempty',Duration_per_Color);
    Duration_per_Color(ix)={nan};
    Duration_per_Color = cell2mat(Duration_per_Color)*FileInfo.SyncPeriod/1E-3;
    
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
    
    Countrate_per_Chan = zeros(Number_of_Bursts,12);
    for i = 1:12
        Countrate_per_Chan(:,i) = Number_of_Photons_per_Chan(:,i)./Duration_per_Chan(:,i);
    end
    
    Countrate_per_Color = zeros(Number_of_Bursts,3);
    for i = 1:6
        Countrate_per_Color(:,i) = Number_of_Photons_per_Color(:,i)./Duration_per_Color(:,i);
    end
elseif BAMethod == 5 %only 3 channels
    
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
        Mean_Macrotime_per_Color(:,i) = cellfun(@(x,y) mean(x(y == i)),Macrotime, Channel)*FileInfo.SyncPeriod;
        Duration_per_Color(:,i) = cellfun(@(x,y) max(x(y == i)) - min(x(y == i)),Macrotime,Channel,'UniformOutput',false);
    end    
    
    %Also calculate GX
    Mean_Macrotime_per_Color(:,4) = cellfun(@(x,y) mean(x(y == 1 | y == 2)),Macrotime, Channel)*FileInfo.SyncPeriod;
    Duration_per_Color(:,4) = cellfun(@(x,y) max(x(y == 1 | y == 2)) - min(x(y == 1 | y == 2)),Macrotime,Channel,'UniformOutput',false);
       
    %there are empty cells for Duration_per_Chan if Channels are empty
    ix=cellfun('isempty',Duration_per_Color);
    Duration_per_Color(ix)={nan};
    Duration_per_Color = cell2mat(Duration_per_Color)*FileInfo.SyncPeriod/1E-3;
    
    %Determine TGG-TGR and TGX-TRR
    TGG_TGR = abs(Mean_Macrotime_per_Color(:,1)-Mean_Macrotime_per_Color(:,2));
    TGX_TRR = abs(Mean_Macrotime_per_Color(:,4)-Mean_Macrotime_per_Color(:,3));
    %also provide normalized quantities
    TGG_TGR(:,2) = TGG_TGR(:,1)./Duration;
    TGX_TRR(:,2) = TGX_TRR(:,1)./Duration;
    TGG_TGR(:,1) = TGG_TGR(:,1)./1E-3;
    TGX_TRR(:,1) = TGX_TRR(:,1)./1E-3;
    %Countrate per chan
    Countrate_per_Color = zeros(Number_of_Bursts,3);
    for i = 1:3
        Countrate_per_Color(:,i) = Number_of_Photons_per_Color(:,i)./Duration_per_Color(:,i);
    end
    
end

Countrate = Number_of_Photons./Duration;

Progress(0.95,h.Progress_Axes, h.Progress_Text, 'Saving...');

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
        TGX_TRR(:,1)...
        ALEX_2CDE...
        TGG_TGR(:,1)...
        FRET_2CDE...
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
                'Lifetime GG [ns]',...
                'Lifetime RR [ns]',...
                'Anisotropy GG',...
                'Anisotropy RR',...
                '|TGX-TRR| Filter',...
                'ALEX 2CDE Filter',...
                '|TGG-TGR| Filter',...
                'FRET 2CDE Filter',...
                'Duration [ms]',...
                'Mean Macrotime [s]',...
                'Number of Photons',...
                'Countrate [kHz]',...
                'Countrate (GG) [kHz]',...
                'Countrate (GR) [kHz]',...
                'Countrate (RR) [kHz]',...
                'Countrate (GG par) [kHz]',...
                'Countrate (GG per) [kHz]',...
                'Countrate (GR par) [kHz]',...
                'Countrate (GR per) [kHz]',...
                'Countrate (RR par) [kHz]',...
                'Countrate (RR per) [kHz]',...
                'Number of Photons (GG)',...
                'Number of Photons (GR)',...
                'Number of Photons (RR)'...
                'Number of Photons (GG par)',...
                'Number of Photons (GG perp)',...
                'Number of Photons (GR par)',...
                'Number of Photons (GR perp)',...
                'Number of Photons (RR par)',...
                'Number of Photons (RR perp)',...
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
            'Countrate [kHz]',...
            'Countrate (BB) [kHz]',...
            'Countrate (BG) [kHz]',...
            'Countrate (BR) [kHz]',...
            'Countrate (GG) [kHz]',...
            'Countrate (GR) [kHz]',...
            'Countrate (RR) [kHz]',...
            'Countrate (BB par) [kHz]',...
            'Countrate (BB perp) [kHz]',...
            'Countrate (BG par) [kHz]',...
            'Countrate (BG perp) [kHz]',...
            'Countrate (BR par) [kHz]',...
            'Countrate (BR perp) [kHz]',...
            'Countrate (GG par) [kHz]',...
            'Countrate (GG perp) [kHz]',...
            'Countrate (GR par) [kHz]',...
            'Countrate (GR perp) [kHz]',...
            'Countrate (RR par) [kHz]',...
            'Countrate (RR perp) [kHz]',...
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
elseif BAMethod == 5
    BurstData.DataArray = [...
        E...
        S...
        Proximity_Ratio...
        S...
        tauGG...
        tauRR...
        rGG...
        rRR...
        TGX_TRR(:,1)...
        ALEX_2CDE...
        TGG_TGR(:,1)...
        FRET_2CDE...
        Duration...
        Mean_Macrotime...
        Number_of_Photons...
        Countrate...
        Countrate_per_Color(:,1:3)...
        Number_of_Photons_per_Color...
        ];

    BurstData.NameArray = {'Efficiency',...
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
                'Mean Macrotime [ms]',...
                'Countrate [kHz]',...
                'Countrate (GG) [kHz]',...
                'Countrate (GR) [kHz]',...
                'Countrate (RR) [kHz]',...
                'Number of Photons',...
                'Number of Photons (GG)',...
                'Number of Photons (GR)',...
                'Number of Photons (RR)'...
                };
end
%%% Append other important parameters/values to BurstData structure


BurstData.TACRange = FileInfo.TACRange;
BurstData.BAMethod = BAMethod;
BurstData.Filetype = FileInfo.FileType;
BurstData.SyncPeriod = FileInfo.SyncPeriod;
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

% get the IRF, scatter decay and background from UserValues
Store_IRF_Scat_inBur('nothing',[],[0,1])

%%% get path from spc files, create folder
[pathstr, FileName, ~] = fileparts(fullfile(FileInfo.Path,FileInfo.FileName{1}));

BurstData.FileNameSPC = FileName; %%% The Name without extension
BurstData.PathName = FileInfo.Path;

if ~exist([pathstr filesep FileName],'dir')
    mkdir(pathstr,FileName);
end
pathstr = [pathstr filesep FileName];

%%% Add Burst Search Type
%%% The Naming follows the Abbreviation for the BurstSearch Method.
switch BAMethod 
    case 1
        FullFileName = fullfile(pathstr, [FileName(1:end-2) 'APBS_2CMFD_']);
    case 2
        FullFileName = fullfile(pathstr, [FileName(1:end-2) 'DCBS_2CMFD_']);
    case 3
        FullFileName = fullfile(pathstr, [FileName(1:end-2) 'APBS_3CMFD_']);
    case 4
        FullFileName = fullfile(pathstr, [FileName(1:end-2) 'TCBS_3CMFD_']);
    case 5
        FullFileName = fullfile(pathstr, [FileName(1:end-2) 'APBS_2CnoMFD_']);
end

%%% add the used parameters also to the filename
switch BAMethod
    case {1,3,5} %APBS L,M,T
        FullFileName = [FullFileName ...
            num2str(L) '_' num2str(M)...
            '_' num2str(T)];
    case 2 %DCBS, now 2 M values; L,MD,MA,T
        FullFileName = [FullFileName ...
            num2str(L) '_' num2str(M(1))...
            '_' num2str(M(2))...
            '_' num2str(T)];
    case 4 %TCBS
        FullFileName = [FullFileName ...
            num2str(L) '_' num2str(M(1))...
            '_' num2str(M(2))...
            '_' num2str(M(3))...
            '_' num2str(T)];
end

%%% Save the Burst Data
BurstFileName = [FullFileName '.bur'];
BurstFileName = GenerateName(BurstFileName, 1);
%%% Store the FileName of the *.bur file
BurstData.FileName = BurstFileName;
save(BurstFileName,'BurstData');


%%% Save the full Photon Information (for FCS/fFCS) in an external file
%%% that can be loaded at a later timepoint
PhotonsFileName = [FullFileName '.bps']; %%% .bps is burst-photon-stream
PhotonsFileName = GenerateName(PhotonsFileName, 1);
%Macrotime = cellfun(@uint64,Macrotime,'UniformOutput',false);
%Microtime = cellfun(@uint16,Microtime,'UniformOutput',false);
%Channel = cellfun(@uint8,Channel,'UniformOutput',false);
save(PhotonsFileName,'Macrotime','Microtime','Channel');
%%% Save the whole photon stream for fFCS with Donor-Only inclusion or 
%%% purified FCS (inclusion of time window around burst)
if UserValues.BurstSearch.SaveTotalPhotonStream
    PhotonsFileName = [FullFileName '.aps']; %%% .bps is all-photon-stream
    PhotonsFileName = GenerateName(PhotonsFileName, 1);
    PhotonStream.start = start_all;
    PhotonStream.stop = stop_all;
    PhotonStream.Macrotime = Macrotime_all;
    PhotonStream.Microtime = Microtime_all;
    PhotonStream.Channel = Channel_all;
    save(PhotonsFileName,'PhotonStream');
end

%%% Set BurstBrowserPath Path to FilePath
UserValues.File.BurstBrowserPath = FileInfo.Path;
LSUserValues(1);

Progress(1,h.Progress_Axes, h.Progress_Text, 'Done');
Update_Display([],[],1);
%%% set the text of the BurstSearch Button to green color to indicate that
%%% a burst search has been done
h.Burst_Button.ForegroundColor = [0 0.8 0];
%%% Enable Lifetime and 2CDE Button
h.BurstLifetime_Button.Enable = 'on';
h.BurstLifetime_Button.ForegroundColor = [1 0 0];
h.NirFilter_Button.Enable = 'on';
h.NirFilter_Button.ForegroundColor = [1 0 0];

% Perform 2CDE filter calculation directly after burst search
if h.NirFilter_Checkbox.Value
    NirFilter
end

% Perform burstwise lifetime fitting directly after burst search
if h.BurstLifetime_Checkbox.Value
    BurstLifetime
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculates the 2CDE Filter for the BurstSearch Result  %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NirFilter(~,~)
global BurstData
h = guidata(findobj('Tag','Pam'));

% possibilites for tau_2CDE
% number eg. 100
% some numbers eg. 100;200
% range of numbers eg. 100:100:1000
tau_2CDE = str2num(h.NirFilter_Edit.String);
h.Progress_Text.String = 'Preparing Data...';drawnow;
if isnan(tau_2CDE)
    h.NirFilter_Edit.String =  '100';
    tau_2CDE = 100;
end

%%% Load associated Macro- and Microtimes from *.bps file
[Path,File,~] = fileparts(BurstData.FileName);
load(fullfile(Path,[File '.bps']),'-mat');

h.Progress_Text.String = 'Calculating 2CDE Filter...'; drawnow;
tic
for t=1:numel(tau_2CDE)
    tau = tau_2CDE(t)*1E-6/BurstData.SyncPeriod;
    if numel(tau_2CDE) == 1
        tex = 'Calculating 2CDE Filter...';
    else
        tex = ['Calculating 2CDE Filter ' num2str(t) ' of ' num2str(numel(tau_2CDE))];
    end
    if any(BurstData.BAMethod == [1,2]) %2 Color Data
        FRET_2CDE = zeros(numel(Macrotime),1); %#ok<USENS>
        ALEX_2CDE = zeros(numel(Macrotime),1);

        %%% Split into 10 parts to display progress
        parts = (floor(linspace(1,numel(Macrotime),11)));
        for j = 1:10
            Progress((j-1)/10,h.Progress_Axes, h.Progress_Text,tex);
            parfor i = parts(j):parts(j+1)
                [FRET_2CDE(i), ALEX_2CDE(i)] = KDE(Macrotime{i}',Channel{i}',tau); %#ok<USENS,PFIIN>
            end
        end
        idx_ALEX2CDE = strcmp('ALEX 2CDE Filter',BurstData.NameArray);
        idx_FRET2CDE = strcmp('FRET 2CDE Filter',BurstData.NameArray);
        BurstData.DataArray(:,idx_ALEX2CDE) = ALEX_2CDE;
        BurstData.DataArray(:,idx_FRET2CDE) = FRET_2CDE;
    elseif any(BurstData.BAMethod == [3,4]) %3 Color Data
        FRET_2CDE = zeros(numel(Macrotime),3);
        ALEX_2CDE = zeros(numel(Macrotime),3);
        %%% Split into 10 parts to display progress
        parts = (floor(linspace(1,numel(Macrotime),11)));
        for j = 1:10
            Progress((j-1)/10,h.Progress_Axes, h.Progress_Text,tex);
            parfor i = parts(j):parts(j+1)
                [FRET_2CDE(i,:), ALEX_2CDE(i,:)] = KDE_3C(Macrotime{i}',Channel{i}',tau); %#ok<PFIIN>
            end
        end    
        idx_ALEX2CDE = find(strcmp('ALEX 2CDE BG Filter',BurstData.NameArray));
        idx_FRET2CDE = find(strcmp('FRET 2CDE BG Filter',BurstData.NameArray));
        BurstData.DataArray(:,idx_ALEX2CDE:(idx_ALEX2CDE+2)) = ALEX_2CDE;
        BurstData.DataArray(:,idx_FRET2CDE:(idx_FRET2CDE+2)) = FRET_2CDE;
    end
    if numel(tau_2CDE) == 1
        save(BurstData.FileName,'BurstData');
    else
        save([BurstData.FileName(1:end-4) '_TC' num2str(tau_2CDE(t)) '_.bur'],'BurstData');
    end
end
Progress(1,h.Progress_Axes, h.Progress_Text,tex);
toc
Update_Display([],[],1);
h.NirFilter_Button.ForegroundColor = [0 0.8 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loads a performed BurstSearch for further/re-analysis  %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Performed_BurstSearch(obj,~)
clearvars -global BurstData BurstTCSPCData
global BurstData UserValues
h = guidata(obj);
[FileName,PathName] = uigetfile({'*.bur'}, 'Choose a file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');

if FileName == 0
    return;
end
UserValues.File.BurstBrowserPath=PathName;
LSUserValues(1);
load('-mat',fullfile(PathName,FileName));
%%% Update FileName (if it was previously analyzed on a different computer)
BurstData.FileName = fullfile(PathName,FileName);

Update_Display([],[],1);
%%% set the text of the BurstSearch Button to green color to indicate that
%%% a burst search has been done
h.Burst_Button.ForegroundColor = [0 0.8 0];
%%% Enable Lifetime and 2CDE Button
h.BurstLifetime_Button.Enable = 'on';
%%% Check if lifetime has been fit already
if any(BurstData.BAMethod == [1,2])
    if (sum(BurstData.DataArray(:,strcmp('Lifetime GG [ns]',BurstData.NameArray))) == 0 )
        %%% no lifetime fit
        h.BurstLifetime_Button.ForegroundColor = [1 0 0];
    else
        %%% lifetime was fit
        h.BurstLifetime_Button.ForegroundColor = [0 0.8 0];
    end
elseif any(BurstData.BAMethod == [3,4])
    if (sum(BurstData.DataArray(:,strcmp('Lifetime BB [ns]',BurstData.NameArray))) == 0 )
        %%% no lifetime fit
        h.BurstLifetime_Button.ForegroundColor = [1 0 0];
    else
        %%% lifetime was fit
        h.BurstLifetime_Button.ForegroundColor = [0 0.8 0];
    end
end

h.NirFilter_Button.Enable = 'on';
%%% Check if NirFilter was calculated before
if any(BurstData.BAMethod == [1,2])
    if (sum(BurstData.DataArray(:,strcmp('ALEX 2CDE Filter',BurstData.NameArray))) == 0 )
        %%% no NirFilter
        h.NirFilter_Button.ForegroundColor = [1 0 0];
    else
        %%% NirFilter was calcuated
        h.NirFilter_Button.ForegroundColor = [0 0.8 0];
    end
elseif any(BurstData.BAMethod == [3,4])
    if (sum(BurstData.DataArray(:,strcmp('ALEX 2CDE GR Filter',BurstData.NameArray))) == 0 )
        %%% no NirFilter
        h.NirFilter_Button.ForegroundColor = [1 0 0];
    else
        %%% NirFilter was calculated
        h.NirFilter_Button.ForegroundColor = [0 0.8 0];
    end
end
[~,h.Burst_LoadedFile_Text.String,~] = fileparts(BurstData.FileName);
[~,h.Burst_LoadedFile_Text.TooltipString,~] = fileparts(BurstData.FileName);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Performs a Burst Search with specified algorithm  %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [start, stop, Number_of_Photons] = Perform_BurstSearch(Photons,Channel,type,T,M,L)

switch type
    case 'APBS'
        %All-Photon Burst Search
        [start, stop, Number_of_Photons] = APBS(Photons,T,M,L);
    case 'DCBS'
        %Dual Channel Burst Search
        %Get GX and RR photon streams
        %1,2 = GG12
        %3,4 = GR12
        %5,6 = RR12
        PhotonsD = Photons(Channel == 1 | Channel == 2 | Channel == 3 | Channel == 4);
        PhotonsA = Photons(Channel == 5 | Channel == 6);
        indexD = find((Channel == 1 | Channel == 2 | Channel == 3 | Channel == 4));
        indexA = find((Channel == 5 | Channel == 6));

        %do burst search on each channel
        MD = M(1);
        MA = M(2);
        %ACBS(Photons,T,M,L), don't specify L for no cutting!
        [startD, stopD, ~] = APBS(PhotonsD,T,MD);
        [startA, stopA, ~] = APBS(PhotonsA,T,MA);

        startD = indexD(startD);
        stopD = indexD(stopD);
        startA = indexA(startA);
        stopA = indexA(stopA);

        validA = zeros(1,numel(startA));
        for i = 1:numel(startA)
            current = find(stopD-startA(i) > 0,1,'first');
            if startD(current) < stopA(i)
                startA(i) = max([startD(current) startA(i)]);
                stopA(i) = min([stopD(current) stopA(i)]);
                validA(i) = 1;
            end
        end
        start = startA(validA == 1);
        stop = stopA(validA == 1);

        Number_of_Photons = stop-start+1;
        start(Number_of_Photons<L)=[];
        stop(Number_of_Photons<L)=[];
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
function [start, stop, Number_of_Photons] = APBS(Photons,T,M,L)
global FileInfo
%All-Photon Burst Search
valid=(Photons(1+M:end)-Photons(1:end-M)) < T*1e-6/FileInfo.SyncPeriod;

% and find start and stop of bursts
start = find(valid(1:end-1)-valid(2:end)==-1)+floor(M/2);
stop = find(valid(1:end-1)-valid(2:end)==1)+floor(M/2);

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
%only cut if L is specified (it is not for DCBS sub-searches)
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
%%% Updates or shifts the preview  window in BurstAnalysis %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BurstSearch_Preview(obj,~)
global FileInfo UserValues PamMeta
h = guidata(findobj('Tag','Pam'));

if obj ==  h.BurstSearchPreview_Button %%% recalculate the preview
    %%% Set Progress Bar
    h.Progress_Text.String = 'Calculating Burst Search Preview...';
    drawnow;

    %bintime for display, based on the time window used for the burst analysis
    Bin_Time = UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.Method}(2)*1E-6/FileInfo.SyncPeriod;
    %perform burst analysis on first 60 seconds
    %achieve loading of less photons by using chunksize of preview and first
    %chunk
    ChunkSize = 1; %1 minute
    T_preview = 60*ChunkSize/FileInfo.SyncPeriod;
    BAMethod = UserValues.BurstSearch.Method;
    
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
            4*ones(1,numel(Photons{4})) 5*ones(1,numel(Photons{5})) 6*ones(1,numel(Photons{6}))]);
        Channel = chan_temp(index);
        clear index chan_temp
        
        if BAMethod == 1
            T = UserValues.BurstSearch.SearchParameters{BAMethod}(2);
            M = UserValues.BurstSearch.SearchParameters{BAMethod}(3);
            L = UserValues.BurstSearch.SearchParameters{BAMethod}(1);
            [start, stop, ~] = Perform_BurstSearch(AllPhotons,[],'APBS',T,M,L);
        elseif BAMethod == 2
            T = UserValues.BurstSearch.SearchParameters{BAMethod}(2);
            M = [UserValues.BurstSearch.SearchParameters{BAMethod}(3),...
                UserValues.BurstSearch.SearchParameters{BAMethod}(4)];
            L = UserValues.BurstSearch.SearchParameters{BAMethod}(1);
            [start, stop, ~] = Perform_BurstSearch(AllPhotons,Channel,'DCBS',T,M,L);
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
            10*ones(1,numel(Photons{10})) 11*ones(1,numel(Photons{11})) 12*ones(1,numel(Photons{12}))]);
        Channel = chan_temp(index);
        clear index chan_temp
        
        if BAMethod == 3 %ACBS 3 Color
            T = UserValues.BurstSearch.SearchParameters{BAMethod}(2);
            M = UserValues.BurstSearch.SearchParameters{BAMethod}(3);
            L = UserValues.BurstSearch.SearchParameters{BAMethod}(1);
            [start, stop, ~] = Perform_BurstSearch(AllPhotons,[],'APBS',T,M,L);
        elseif BAMethod == 4 %TCBS
            T = UserValues.BurstSearch.SearchParameters{BAMethod}(2);
            M = [UserValues.BurstSearch.SearchParameters{BAMethod}(3),...
                UserValues.BurstSearch.SearchParameters{BAMethod}(4),...
                UserValues.BurstSearch.SearchParameters{BAMethod}(5)];
            L = UserValues.BurstSearch.SearchParameters{BAMethod}(1);
            [start, stop, ~] = Perform_BurstSearch(AllPhotons,Channel,'TCBS',T,M,L);
        end
        
    elseif BAMethod == 5 %2 color no MFD
        %prepare photons
        %read out macrotimes for all channels
        Photons{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Macrotime',1,ChunkSize);
        Photons{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Macrotime',1,ChunkSize);
        Photons{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Macrotime',1,ChunkSize);
        AllPhotons_unsort = horzcat(Photons{:});
        %sort
        [AllPhotons, ~] = sort(AllPhotons_unsort);
        clear AllPhotons_unsort
        %get colors of photons
        
        %do search
        T = UserValues.BurstSearch.SearchParameters{BAMethod}(2);
            M = UserValues.BurstSearch.SearchParameters{BAMethod}(3);
            L = UserValues.BurstSearch.SearchParameters{BAMethod}(1);
        [start, stop, ~] = Perform_BurstSearch(AllPhotons,[],'APBS',T,M,L);
    end
    
    %prepare trace for display
    xout = 0:Bin_Time:T_preview;
    switch BAMethod %make histograms for lower display with binning T_classic
        case {1,2}    % 2 color, MFD
            [ch1] = hist([Photons{1}; Photons{2}; Photons{3}; Photons{4}], xout);
            [ch2] = hist([Photons{5}; Photons{6}], xout);
        case {3,4}    % 3 color, MFD
            [ch3] = hist([Photons{1}; Photons{2}; Photons{3}; Photons{4}; Photons{5}; Photons{6}], xout);
            [ch1] = hist([Photons{7}; Photons{8}; Photons{9}; Photons{10}], xout);
            [ch2] = hist([Photons{11}; Photons{12}], xout);
        case 5
            [ch1] = hist([Photons{1} Photons{2}], xout);
            [ch2] = hist([Photons{3}], xout);
    end
    %convert photon number to bin number
    starttime = max(floor(AllPhotons(start)/Bin_Time),1);
    stoptime = min(ceil(AllPhotons(stop)/Bin_Time),xout(end));
    
    %Update PamMeta
    PamMeta.Burst.Preview.x = xout*FileInfo.SyncPeriod;
    PamMeta.Burst.Preview.ch1 = ch1;
    PamMeta.Burst.Preview.ch2 = ch2;
    PamMeta.Burst.Preview.stop = stop;
    PamMeta.Burst.Preview.start = start;
    PamMeta.Burst.Preview.starttime = starttime;
    PamMeta.Burst.Preview.stoptime = stoptime;
    PamMeta.Burst.Preview.AllPhotons = AllPhotons;
    if any(BAMethod == [3 4])
        PamMeta.Burst.Preview.ch3 = ch3;
    end
    %%% set the second to be displayed (here first)+
    PamMeta.Burst.Preview.Second = 0;
    
    %%% clear old data
    if isfield(h.Plots.BurstPreview,'SearchResult')
        for i = 1:numel(h.Plots.BurstPreview.SearchResult.Channel1)
            delete(h.Plots.BurstPreview.SearchResult.Channel1(i));
        end
        for i = 1:numel(h.Plots.BurstPreview.SearchResult.Channel2)
            delete(h.Plots.BurstPreview.SearchResult.Channel2(i));
        end
        if isfield(h.Plots.BurstPreview.SearchResult,'Channel3')
            for i = 1:numel(h.Plots.BurstPreview.SearchResult.Channel3)
                delete(h.Plots.BurstPreview.SearchResult.Channel3(i));
            end
        end
    end
    
    %%% Plot the data
    h.Plots.BurstPreview.Channel1.XData = PamMeta.Burst.Preview.x;
    h.Plots.BurstPreview.Channel1.YData = PamMeta.Burst.Preview.ch1;
    h.Plots.BurstPreview.Channel2.XData = PamMeta.Burst.Preview.x;
    h.Plots.BurstPreview.Channel2.YData = PamMeta.Burst.Preview.ch2;
    h.Plots.BurstPreview.Channel1.Color = [0 1 0];
    h.Plots.BurstPreview.Channel2.Color = [1 0 0];
    %%% hide third channel
    h.Plots.BurstPreview.Channel3.Visible = 'off';
    if any(BAMethod == [3 4])
        h.Plots.BurstPreview.Channel3.XData = PamMeta.Burst.Preview.x;
        h.Plots.BurstPreview.Channel3.YData = PamMeta.Burst.Preview.ch3;
        h.Plots.BurstPreview.Channel3.Color = [0 0 1];
        h.Plots.BurstPreview.Channel3.Visible = 'on';
    end
    h.Burst_Axes.XLim = [0 1];
    
    %find first and last burst in second
    first = find(AllPhotons(start),1,'first');
    last = find(AllPhotons(stop),1,'last');
    for i=first:last
        h.Plots.BurstPreview.SearchResult.Channel1(i) = plot(h.Burst_Axes, PamMeta.Burst.Preview.x(starttime(i):stoptime(i)),ch1(starttime(i):stoptime(i)),'og');
        h.Plots.BurstPreview.SearchResult.Channel2(i) = plot(h.Burst_Axes, PamMeta.Burst.Preview.x(starttime(i):stoptime(i)),ch2(starttime(i):stoptime(i)),'or');
        if any(BAMethod == [3 4])
            h.Plots.BurstPreview.SearchResult.Channel3(i) = plot(h.Burst_Axes, PamMeta.Burst.Preview.x(starttime(i):stoptime(i)),ch3(starttime(i):stoptime(i)),'ob');
        end
    end
    guidata(findobj('Tag','Pam'),h);
else %%% < or > was pressed
    switch obj %%% determine if < or > was clicked
        case h.BurstSearchPreview_Forward_Button
            %%% increase by one second
            if PamMeta.Burst.Preview.Second < 59
                PamMeta.Burst.Preview.Second = PamMeta.Burst.Preview.Second +1;
            end
        case h.BurstSearchPreview_Backward_Button
            %%% decrease by one second
            if PamMeta.Burst.Preview.Second > 0
                PamMeta.Burst.Preview.Second = PamMeta.Burst.Preview.Second -1;
            end
    end
    %%% Update the x-axis limits of Burst_Axes
    h.Burst_Axes.XLim = [PamMeta.Burst.Preview.Second  PamMeta.Burst.Preview.Second+1];
end
%%% Update Display
Update_Display([],[],1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Saves the current measurement as IRF pattern %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SaveIRF(obj,~)
global UserValues FileInfo TcspcData
if strcmp(FileInfo.FileName{1},'Nothing loaded')
    errordlg('Load a measurement first!','No measurement loaded...');
    return;
end
h = guidata(findobj('Tag','Pam'));
colorr = h.Progress_Axes.Color;
strr = h.Progress_Text.String;
h.Progress_Text.String = 'Saving IRF';
h.Progress_Axes.Color=[1 0 0];
switch obj
    case h.SaveIRF_Menu
        %%% Update the IRF for ALL PIE channel
        for i=1:numel(UserValues.PIE.Name)
            if isempty(UserValues.PIE.Combined{i})
                UserValues.PIE.IRF{i} = (histc( TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}, 0:(FileInfo.MI_Bins-1)))';
            end
        end
    case h.PIE_IRF
        %%% Find selected channels
        Sel=h.PIE_List.Value;
        if isempty(UserValues.PIE.Combined{Sel})
            %%% Update IRF of selected channel
            UserValues.PIE.IRF{Sel}(FromTo) = (histc( TcspcData.MI{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}, 0:(FileInfo.MI_Bins-1)))';
        else
            uiwait(msgbox('IRF cannot be saved for combined channels!', 'Important', 'modal'))
            return
        end
end
h.MI_IRF.Checked = 'on';
UserValues.Settings.Pam.PlotIRF = 'on';
LSUserValues(1);
Update_Display([],[],8)
h.Progress_Text.String = strr;
h.Progress_Axes.Color=colorr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Saves the current measurement as Scatter pattern %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SaveScatter(~,~)
global UserValues PamMeta TcspcData FileInfo
h=guidata(findobj('Tag','Pam'));

for i=1:numel(UserValues.PIE.Name)
    if isempty(UserValues.PIE.Combined{i})
        UserValues.PIE.ScatterPattern{i} = (histc( TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}, 0:(FileInfo.MI_Bins-1)))';
    end
end

uiwait(msgbox('If scatter is used as background for burst analysis, the correct burst method and channels have to be selected','Important','modal'));

% PamMeta.Info contains the total photons, channel photons.... information
% per PIE Channel
% Store the channel count rates in the UserValues.BurstSearch structure.
BAMethod = UserValues.BurstSearch.Method;
switch BAMethod
    case {1,2}
        UserValues.BurstBrowser.Corrections.Background_GGpar = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1}))}(4);
        UserValues.BurstBrowser.Corrections.Background_GGperp = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2}))}(4);
        UserValues.BurstBrowser.Corrections.Background_GRpar = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1}))}(4);
        UserValues.BurstBrowser.Corrections.Background_GRperp = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2}))}(4);
        UserValues.BurstBrowser.Corrections.Background_RRpar = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1}))}(4);
        UserValues.BurstBrowser.Corrections.Background_RRperp = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2}))}(4);
    case {3,4}
        UserValues.BurstBrowser.Corrections.Background_BBpar = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1}))}(4);
        UserValues.BurstBrowser.Corrections.Background_BBperp = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2}))}(4);
        UserValues.BurstBrowser.Corrections.Background_BGpar = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1}))}(4);
        UserValues.BurstBrowser.Corrections.Background_BGperp = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2}))}(4);
        UserValues.BurstBrowser.Corrections.Background_BRpar = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1}))}(4);
        UserValues.BurstBrowser.Corrections.Background_BRperp = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2}))}(4);
        UserValues.BurstBrowser.Corrections.Background_GGpar = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,1}))}(4);
        UserValues.BurstBrowser.Corrections.Background_GGperp = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,2}))}(4);
        UserValues.BurstBrowser.Corrections.Background_GRpar = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{5,1}))}(4);
        UserValues.BurstBrowser.Corrections.Background_GRperp = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{5,2}))}(4);
        UserValues.BurstBrowser.Corrections.Background_RRpar = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,1}))}(4);
        UserValues.BurstBrowser.Corrections.Background_RRperp = ...
            PamMeta.Info{...
            (strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,2}))}(4);
end
h.MI_ScatterPattern.Checked = 'on';
UserValues.Settings.Pam.PlotScat = 'on';
LSUserValues(1);
Update_Display([],[],8)
h.SaveScatter_Button.ForegroundColor = [0 1 0];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Open TauFitBurst Window for Burstwise Lifetime Fitting %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BurstLifetime(~,~)
global UserValues BurstData TauFitBurstData
h = guidata(findobj('Tag','Pam'));
%%% Check if IRF and Scatter exists
if any(isempty(BurstData.IRF)) || any(isempty(BurstData.ScatterPattern))
    warndlg('Define IRF and Scatter first.','No IRF found!');
    return;
end
%% Prepare the data for lifetime fitting
h.Progress_Text.String = 'Preparing Data for Lifetime Fit...';drawnow;
%%% Load associated Macro- and Microtimes from *.bps file
[Path,File,~] = fileparts(BurstData.FileName);
if exist(fullfile(Path,[File '.bps']),'file') == 2
    %%% load if it exists
    load(fullfile(Path,[File '.bps']),'-mat');
    TauFitBurstData.FileName = BurstData.FileName;
else
    %%% else ask for the file
    [FileName,PathName] = uigetfile({'*.bps'}, 'Choose the associated *.bps file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');
    if FileName == 0
        return;
    end
    load('-mat',fullfile(PathName,FileName));
    %%% Store the correct Path in TauFitBurstData
    TauFitBurstData.FileName = fullfile(PathName,[FileName(1:end-3) 'bur']);
end
TauFitBurstData.Microtime = Microtime;
TauFitBurstData.Channel = Channel;
%%% Get total vector of microtime and channel
Microtime = vertcat(Microtime{:});
Channel = vertcat(Channel{:});
%%% Calculate the total Microtime Histogram per Color from all bursts
switch BurstData.BAMethod
    case {1,2} %two color MFD  
        %%% Read out the indices of the PIE channels
        idx_GGpar = 1;
        idx_GGperp = 2;
        idx_RRpar = 5;
        idx_RRperp = 6;
        
        %%% Calculate the MI histograms
        max_MIBins_GGpar = min([numel(BurstData.IRF{idx_GGpar}) numel(BurstData.ScatterPattern{idx_GGpar})]);
        max_MIBins_GGperp = min([numel(BurstData.IRF{idx_GGperp}) numel(BurstData.ScatterPattern{idx_GGperp})]);
        max_MIBins_RRpar = min([numel(BurstData.IRF{idx_RRpar}) numel(BurstData.ScatterPattern{idx_RRpar})]);
        max_MIBins_RRperp = min([numel(BurstData.IRF{idx_RRperp}) numel(BurstData.ScatterPattern{idx_RRperp})]);
        
        GGpar = histc(Microtime(Channel == 1), (BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GGpar])));
        GGperp = histc(Microtime(Channel == 2), (BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_GGperp])));
        RRpar = histc(Microtime(Channel == 5), (BurstData.PIE.From(5):min([BurstData.PIE.To(5) max_MIBins_RRpar])));
        RRperp = histc(Microtime(Channel == 6), (BurstData.PIE.From(6):min([BurstData.PIE.To(6) max_MIBins_RRperp])));
        
        %%% Store Histograms in TauFitBurstData
        TauFitBurstData.hMI_Par{1} = GGpar;
        TauFitBurstData.hMI_Per{1} = GGperp;
        TauFitBurstData.hMI_Par{2} = RRpar;
        TauFitBurstData.hMI_Per{2} = RRperp;
        %%% Read out the Microtime Histograms of the IRF for the two channels
        hIRF_GGpar = BurstData.IRF{idx_GGpar}((BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GGpar])));
        hIRF_GGperp = BurstData.IRF{idx_GGperp}((BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_GGperp])));
        hIRF_RRpar = BurstData.IRF{idx_RRpar}((BurstData.PIE.From(5):min([BurstData.PIE.To(5) max_MIBins_RRpar])));
        hIRF_RRperp = BurstData.IRF{idx_RRperp}((BurstData.PIE.From(6):min([BurstData.PIE.To(6) max_MIBins_RRperp])));
        
        TauFitBurstData.hIRF_Par{1} = hIRF_GGpar;
        TauFitBurstData.hIRF_Par{2} = hIRF_RRpar;
        TauFitBurstData.hIRF_Per{1} = hIRF_GGperp;
        TauFitBurstData.hIRF_Per{2} = hIRF_RRperp;
        %%% Normalize IRF for better Visibility
        for i = 1:2
            TauFitBurstData.hIRF_Par{i} = (TauFitBurstData.hIRF_Par{i}./max(TauFitBurstData.hIRF_Par{i})).*max(TauFitBurstData.hMI_Par{i});
            TauFitBurstData.hIRF_Per{i} = (TauFitBurstData.hIRF_Per{i}./max(TauFitBurstData.hIRF_Per{i})).*max(TauFitBurstData.hMI_Per{i});
        end
        
        %%% Read out the Microtime Histograms of the Scatter for the two channels
        hScatter_GGpar = BurstData.ScatterPattern{idx_GGpar}((BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GGpar])));
        hScatter_GGperp = BurstData.ScatterPattern{idx_GGperp}((BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_GGperp])));
        hScatter_RRpar = BurstData.ScatterPattern{idx_RRpar}((BurstData.PIE.From(5):min([BurstData.PIE.To(5) max_MIBins_RRpar])));
        hScatter_RRperp = BurstData.ScatterPattern{idx_RRperp}((BurstData.PIE.From(6):min([BurstData.PIE.To(6) max_MIBins_RRperp])));
        
        TauFitBurstData.hScatter_Par{1} = hScatter_GGpar;
        TauFitBurstData.hScatter_Par{2} = hScatter_RRpar;
        TauFitBurstData.hScatter_Per{1} = hScatter_GGperp;
        TauFitBurstData.hScatter_Per{2} = hScatter_RRperp;
        
        %%% Generate XData
        TauFitBurstData.XData_Par{1} = (BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_GGpar])) - BurstData.PIE.From(1);
        TauFitBurstData.XData_Per{1} = (BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_GGperp])) - BurstData.PIE.From(2);
        TauFitBurstData.XData_Par{2} = (BurstData.PIE.From(5):min([BurstData.PIE.To(5) max_MIBins_RRpar])) - BurstData.PIE.From(5);
        TauFitBurstData.XData_Per{2} = (BurstData.PIE.From(6):min([BurstData.PIE.To(6) max_MIBins_RRperp])) - BurstData.PIE.From(6);
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
        %%% Calculate the MI histograms
        BBpar = histc(Microtime(Channel == 1), (BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_BBpar])));
        BBperp = histc(Microtime(Channel == 2), (BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_BBperp])));
        GGpar = histc(Microtime(Channel == 7), (BurstData.PIE.From(7):min([BurstData.PIE.To(7) max_MIBins_GGpar])));
        GGperp = histc(Microtime(Channel == 8), (BurstData.PIE.From(8):min([BurstData.PIE.To(8) max_MIBins_GGperp])));
        RRpar = histc(Microtime(Channel == 11), (BurstData.PIE.From(11):min([BurstData.PIE.To(11) max_MIBins_RRpar])));
        RRperp = histc(Microtime(Channel == 12), (BurstData.PIE.From(12):min([BurstData.PIE.To(12) max_MIBins_RRperp])));
        
        %%% Store Histograms in TauFitBurstData
        TauFitBurstData.hMI_Par{1} = BBpar;
        TauFitBurstData.hMI_Per{1} = BBperp;
        TauFitBurstData.hMI_Par{2} = GGpar;
        TauFitBurstData.hMI_Per{2} = GGperp;
        TauFitBurstData.hMI_Par{3} = RRpar;
        TauFitBurstData.hMI_Per{3} = RRperp;
        %%% Read out the Microtime Histograms of the IRF for the two channels
        hIRF_BBpar = BurstData.IRF{idx_BBpar}(BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_BBpar]));
        hIRF_BBperp = BurstData.IRF{idx_BBperp}(BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_BBperp]));
        hIRF_GGpar = BurstData.IRF{idx_GGpar}(BurstData.PIE.From(7):min([BurstData.PIE.To(7) max_MIBins_GGpar]));
        hIRF_GGperp = BurstData.IRF{idx_GGperp}(BurstData.PIE.From(8):min([BurstData.PIE.To(8) max_MIBins_GGperp]));
        hIRF_RRpar = BurstData.IRF{idx_RRpar}(BurstData.PIE.From(11):min([BurstData.PIE.To(11) max_MIBins_RRpar]));
        hIRF_RRperp = BurstData.IRF{idx_RRperp}(BurstData.PIE.From(12):min([BurstData.PIE.To(12) max_MIBins_RRperp]));
        
        TauFitBurstData.hIRF_Par{1} = hIRF_BBpar;
        TauFitBurstData.hIRF_Par{2} = hIRF_GGpar;
        TauFitBurstData.hIRF_Par{3} = hIRF_RRpar;
        TauFitBurstData.hIRF_Per{1} = hIRF_BBperp;
        TauFitBurstData.hIRF_Per{2} = hIRF_GGperp;
        TauFitBurstData.hIRF_Per{3} = hIRF_RRperp;
        %%% Normalize IRF for better Visibility
        for i = 1:3
            TauFitBurstData.hIRF_Par{i} = (TauFitBurstData.hIRF_Par{i}./max(TauFitBurstData.hIRF_Par{i})).*max(TauFitBurstData.hMI_Par{i});
            TauFitBurstData.hIRF_Per{i} = (TauFitBurstData.hIRF_Per{i}./max(TauFitBurstData.hIRF_Per{i})).*max(TauFitBurstData.hMI_Per{i});
        end
        
        %%% Read out the Microtime Histograms of the IRF for the two channels
        hScatter_BBpar = BurstData.ScatterPattern{idx_BBpar}(BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_BBpar]));
        hScatter_BBperp = BurstData.ScatterPattern{idx_BBperp}(BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_BBperp]));
        hScatter_GGpar = BurstData.ScatterPattern{idx_GGpar}(BurstData.PIE.From(7):min([BurstData.PIE.To(7) max_MIBins_GGpar]));
        hScatter_GGperp = BurstData.ScatterPattern{idx_GGperp}(BurstData.PIE.From(8):min([BurstData.PIE.To(8) max_MIBins_GGperp]));
        hScatter_RRpar = BurstData.ScatterPattern{idx_RRpar}(BurstData.PIE.From(11):min([BurstData.PIE.To(11) max_MIBins_RRpar]));
        hScatter_RRperp = BurstData.ScatterPattern{idx_RRperp}(BurstData.PIE.From(12):min([BurstData.PIE.To(12) max_MIBins_RRperp]));
        
        TauFitBurstData.hIRF_Par{1} = hScatter_BBpar;
        TauFitBurstData.hIRF_Par{2} = hScatter_GGpar;
        TauFitBurstData.hIRF_Par{3} = hScatter_RRpar;
        TauFitBurstData.hIRF_Per{1} = hScatter_BBperp;
        TauFitBurstData.hIRF_Per{2} = hScatter_GGperp;
        TauFitBurstData.hIRF_Per{3} = hScatter_RRperp;
        
        %%% Generate XData
        TauFitBurstData.XData_Par{1} = (BurstData.PIE.From(1):min([BurstData.PIE.To(1) max_MIBins_BBpar])) - BurstData.PIE.From(1);
        TauFitBurstData.XData_Per{1} = (BurstData.PIE.From(2):min([BurstData.PIE.To(2) max_MIBins_BBperp])) - BurstData.PIE.From(2);
        TauFitBurstData.XData_Par{2} = (BurstData.PIE.From(7):min([BurstData.PIE.To(7) max_MIBins_GGpar])) - BurstData.PIE.From(7);
        TauFitBurstData.XData_Per{2} = (BurstData.PIE.From(8):min([BurstData.PIE.To(8) max_MIBins_GGperp])) - BurstData.PIE.From(8);
        TauFitBurstData.XData_Par{3} = (BurstData.PIE.From(11):min([BurstData.PIE.To(11) max_MIBins_RRpar])) - BurstData.PIE.From(11);
        TauFitBurstData.XData_Per{3} = (BurstData.PIE.From(12):min([BurstData.PIE.To(12) max_MIBins_RRperp])) - BurstData.PIE.From(12);
end
%%% Read out relevant parameters
if ~isfield(BurstData.FileInfo,'Resolution')
    TauFitBurstData.TAC_Bin = BurstData.FileInfo.TACRange*1E9/double(BurstData.FileInfo.MI_Bins);
else % HydraHarp
    TauFitBurstData.TAC_Bin = BurstData.FileInfo.Resolution/1000;
end
TauFitBurstData.BAMethod = BurstData.BAMethod;
TauFitBurstData.SyncPeriod = BurstData.SyncPeriod;
TauFitBurstData.TACRange = BurstData.FileInfo.TACRange*1E9;
TauFitBurstData.MI_Bins = double(BurstData.FileInfo.MI_Bins);
TauFitBurst;
Update_Display([],[],1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Store loaded IRF/Scatter Measurment in performed BurstSearch %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Store_IRF_Scat_inBur(obj,~,mode)
global BurstData UserValues
LSUserValues(0)
h = guidata(findobj('Tag','Pam'));
if isempty(BurstData)
    disp('No Burst Data loaded...');
    return;
end

if strcmp(obj,'nothing')
    % function is called during Burst Analysis
else
    % function is called from right clicking the Burstwise lifetime button
    h.Progress_Text.String = 'Saving changed MI pattern...';
end

if any(mode==0)
    %% Save IRF
    switch BurstData.BAMethod
        case {1,2}
            %%% Read out the Microtime Histograms of the IRF for the two channels
            hIRF_GGpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
            hIRF_GGperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2})};
            hIRF_GRpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})};
            hIRF_GRperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2})};
            hIRF_RRpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})};
            hIRF_RRperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2})};
            BurstData.IRF = {hIRF_GGpar; hIRF_GGperp;...
                hIRF_GRpar; hIRF_GRperp;...
                hIRF_RRpar; hIRF_RRperp};
        case {3,4}
            %%% Read out the Microtime Histograms of the IRF for the two channels
            hIRF_BBpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
            hIRF_BBperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2})};
            hIRF_BGpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})};
            hIRF_BGperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2})};
            hIRF_BRpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})};
            hIRF_BRperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2})};
            hIRF_GGpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,1})};
            hIRF_GGperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,2})};
            hIRF_GRpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,1})};
            hIRF_GRperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,2})};
            hIRF_RRpar = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,1})};
            hIRF_RRperp = UserValues.PIE.IRF{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,2})};
            BurstData.IRF = {hIRF_BBpar; hIRF_BBperp;...
                hIRF_BGpar; hIRF_BGperp;...
                hIRF_BRpar; hIRF_BRperp;...
                hIRF_GGpar; hIRF_GGperp;...
                hIRF_GRpar; hIRF_GRperp;...
                hIRF_RRpar; hIRF_RRperp};
    end
end
if any(mode==1)
    %% Save ScatterPattern, as well as background counts!
    switch BurstData.BAMethod
        case {1,2}
            % Scatter patterns for all burst channels
            hScat_GGpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
            hScat_GGperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2})};
            hScat_GRpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})};
            hScat_GRperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2})};
            hScat_RRpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})};
            hScat_RRperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2})};
            BurstData.ScatterPattern = {hScat_GGpar; hScat_GGperp;...
                hScat_GRpar; hScat_GRperp;...
                hScat_RRpar; hScat_RRperp};
            % Background for all burst channels
            BurstData.Background.Background_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
            BurstData.Background.Background_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
            BurstData.Background.Background_GRpar = UserValues.BurstBrowser.Corrections.Background_GRpar;
            BurstData.Background.Background_GRperp = UserValues.BurstBrowser.Corrections.Background_GRperp;
            BurstData.Background.Background_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
            BurstData.Background.Background_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;
        case {3,4}
            % Scatter patterns for all burst channels
            hScat_BBpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,1})};
            hScat_BBperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{1,2})};
            hScat_BGpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,1})};
            hScat_BGperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{2,2})};
            hScat_BRpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,1})};
            hScat_BRperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{3,2})};
            hScat_GGpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,1})};
            hScat_GGperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{4,2})};
            hScat_GRpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,1})};
            hScat_GRperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{5,2})};
            hScat_RRpar = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,1})};
            hScat_RRperp = UserValues.PIE.ScatterPattern{strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{BurstData.BAMethod}{6,2})};
            BurstData.ScatterPattern = {hScat_BBpar; hScat_BBperp;...
                hScat_BGpar; hScat_BGperp;...
                hScat_BRpar; hScat_BRperp;...
                hScat_GGpar; hScat_GGperp;...
                hScat_GRpar; hScat_GRperp;...
                hScat_RRpar; hScat_RRperp};
            % Background for all burst channels
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

if ~strcmp(obj,'nothing')
    % function is called from right clicking the Burstwise lifetime button
    save(BurstData.FileName,'BurstData');
    Progress(1,h.Progress_Axes,h.Progress_Text);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function related to 2CDE filter calcula tion (Nir-Filter) %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [KDE]= kernel_density_estimate(A,B,tau) %KDE of B around A
if nargin == 3
    M = abs(ones(numel(B),1)*A - B'*ones(1,numel(A)));
    M(M>5*tau) = 0;
    E = exp(-M./tau);
    E(M==0) = 0;
    KDE = sum(E,1)';
elseif nargin == 2
    tau = B;
    M = abs(ones(numel(A),1)*A - A'*ones(1,numel(A)));
    M(M>5*tau) = 0;
    E = exp(-M./tau);
    E(M==0) = 0;
    KDE = sum(E,1)'+1;
end
function [KDE]= nb_kernel_density_estimate(B,tau) %non biased KDE of B around B
M = abs(ones(numel(B),1)*B - B'*ones(1,numel(B)));
M(M>5*tau) = 0;
E = exp(-M./tau);
E(M==0) = 0;
KDE = sum(E,1)';
KDE = (1+2/numel(B)).*KDE;
function [FRET_2CDE, ALEX_2CDE] = KDE(Trace,Chan_Trace,tau)

if numel(Trace) < 10000
T_GG = Trace(Chan_Trace == 1 | Chan_Trace == 2);
T_GR = Trace(Chan_Trace == 3 | Chan_Trace == 4);
T_RR = Trace(Chan_Trace == 5 | Chan_Trace == 6);
T_GX = Trace(Chan_Trace == 1 | Chan_Trace == 2 | Chan_Trace == 3 | Chan_Trace == 4);
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
else 
    FRET_2CDE = NaN;
    ALEX_2CDE = NaN;
end
function [FRET_2CDE, ALEX_2CDE] = KDE_3C(Trace,Chan_Trace,tau)
if numel(Trace) < 10000  %necessary to prevent memory overrun in matlab 64bit which occured in a test sample for a burst with 400000 photons to maintain usability on systems with only 12 GB Ram the threshold is set to 10000 but might be changed if necessary
    
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
else
    FRET_2CDE(1,1:3) = NaN;
    ALEX_2CDE(1,1:3) = NaN;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to apply microtime shift for detector correction %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Shift_Detector(~,~,info)
global UserValues TcspcData PamMeta FileInfo
h=guidata(findobj('Tag','Pam'));
h.Progress_Text.String = 'Calculating detector calibration';
h.Progress_Axes.Color=[1 0 0];
maxtick = str2double(h.MI_Calib_Single_Max.String);
drawnow;
if nargin<3 % calculate the shift
    Det=UserValues.Detector.Det(h.MI_Calib_Det.Value);
    Rout=UserValues.Detector.Rout(h.MI_Calib_Det.Value);
    Dif=[maxtick; uint16(diff(TcspcData.MT{Det,Rout}))];
    Dif(Dif>maxtick)=maxtick;
    MI=TcspcData.MI{Det,Rout};
    
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
    PamMeta.Det_Calib.Shift(1:5)=PamMeta.Det_Calib.Shift(6);
    PamMeta.Det_Calib.Shift=PamMeta.Det_Calib.Shift-max(PamMeta.Det_Calib.Shift);
    
    clear Counts Index
    
    % uncorrected MI histogram (blue)
    h.Plots.Calib_No.YData=sum(PamMeta.Det_Calib.Hist,2)/max(smooth(sum(PamMeta.Det_Calib.Hist,2),5));
    h.Plots.Calib_No.XData=1:FileInfo.MI_Bins;
   
    % corrected MI histogram (red)
    Cor_Hist=zeros(size(PamMeta.Det_Calib.Hist));
    for i=1:maxtick
       Cor_Hist(:,i)=circshift(PamMeta.Det_Calib.Hist(:,i),[-PamMeta.Det_Calib.Shift(i),0]);
    end
    h.Plots.Calib.YData=sum(Cor_Hist,2)/max(smooth(sum(Cor_Hist,2),5));
    h.Plots.Calib.XData=1:FileInfo.MI_Bins;
    
    % slider
    h.MI_Calib_Single.Value=round(h.MI_Calib_Single.Value);
    
    % interphoton time selected MI histogram (green)
    h.Plots.Calib_Sel.YData=Cor_Hist(:,h.MI_Calib_Single.Value)/max(smooth(Cor_Hist(:,h.MI_Calib_Single.Value),5));
    h.Plots.Calib_Sel.XData=1:FileInfo.MI_Bins;
    
    % shift plot (red)
    h.MI_Calib_Axes_Shift.XLim = [1 maxtick];
    h.Plots.Calib_Shift_New.XData=1:maxtick;
    h.Plots.Calib_Shift_New.YData=PamMeta.Det_Calib.Shift;
    
else % apply the shift
    if strcmp(info,'load')  %called from LoadTCSPC
        index = 1:numel(UserValues.Detector.Det);
    else %save shift of current channel
        index = h.MI_Calib_Det.Value;
    end
    Det=UserValues.Detector.Det;   
    Rout=UserValues.Detector.Rout;
    for i = index
        if numel(UserValues.Detector.Shift)>=i &&  any(UserValues.Detector.Shift{i}) && ~isempty(TcspcData.MI{Det(i),Rout(i)})
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
h.Progress_Text.String = FileInfo.FileName{1};
h.Progress_Axes.Color=UserValues.Look.Control;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Saves Shift to UserValues and applies it %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Det_Calib_Save(~,~)
global UserValues PamMeta
h=guidata(findobj('Tag','Pam'));
if isfield(PamMeta.Det_Calib,'Shift')
    UserValues.Detector.Shift{h.MI_Calib_Det.Value}=PamMeta.Det_Calib.Shift;
    Shift_Detector([],[],'save');
    m = msgbox('Load data again');
    pause(1)
    delete(m)
end
LSUserValues(1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Clears Shift from UserValues %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Det_Calib_Clear(~,~)
global UserValues PamMeta
h=guidata(findobj('Tag','Pam'));
if isfield(PamMeta.Det_Calib,'Shift')
    UserValues.Detector.Shift{h.MI_Calib_Det.Value} = [];
    m = msgbox('Load data again');
    pause(1)
    delete(m)
end
LSUserValues(1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions concerning database of quick access filenames %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Database(~,e,mode)
global UserValues PamMeta
h = guidata(findobj('Tag','Pam'));

if mode == 0 %%% Checks, which key was pressed
    switch e.Key
        case 'delete'
            mode = 2;
        case 'return'
            mode =7;
    end
end

switch mode
    case 1 %% Add files to database
        %%% following code is for remembering the last used FileType
        LSUserValues(0);
        %%% Loads all possible file types
        Filetypes = UserValues.File.SPC_FileTypes;
        %%% Finds last used file type
        Lastfile = UserValues.File.OpenTCSPC_FilterIndex;
        if isempty(Lastfile) || numel(Lastfile)~=1 || ~isnumeric(Lastfile) || isnan(Lastfile) ||  Lastfile <1
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
            PamMeta.Database{end+1,1} = FileName{i};
            PamMeta.Database{end,2} = Path;
            PamMeta.Database{end,3} = Type;
            h.Database.List.String{end+1} = [FileName{i} ' (path:' Path ')'];
        end
        h.Database.Correlate.Enable = 'on';
        h.Database.Burst.Enable = 'on';
        h.Database.Save.Enable = 'on'; 
        h.Database.Delete.Enable = 'on';  
    case 2 %% Delete files from database
        %remove rows from list
        h.Database.List.String(h.Database.List.Value) = [];
        %remove rows from database
        PamMeta.Database(h.Database.List.Value, :) = [];
        h.Database.List.Value = 1;
        if size(PamMeta.Database, 1) < 1
            % no files are left
            h.Database.Correlate.Enable = 'off';
            h.Database.Burst.Enable = 'off';
            h.Database.Save.Enable = 'off';
            h.Database.Delete.Enable = 'off';
        end
    case 3 %% Load database
        [FileName, Path] = uigetfile({'*.dab', 'Database file'}, 'Choose database to load',UserValues.File.Path,'MultiSelect', 'off');
        load('-mat',fullfile(Path,FileName));
        PamMeta.Database = s.database;
        h.Database.List.String = s.str;
        clear s;
        if size(PamMeta.Database, 1) > 0
            % no files are left
            h.Database.Correlate.Enable = 'on';
            h.Database.Burst.Enable = 'on';
            h.Database.Save.Enable = 'on';
            h.Database.Delete.Enable = 'on';
        end
    case 4 %% Save complete database
        [File, Path] = uiputfile({'*.dab', 'Database file'}, 'Save database', UserValues.File.Path);
        s = struct;
        s.database = PamMeta.Database;
        s.str = h.Database.List.String;
        save(fullfile(Path,File),'s');
    case 5 %% Correlate active ones in database
        if h.Database.Correlate.UserData == 0
            h.Database.Correlate.UserData = 1;
            h.Database.Correlate.String = 'Stop';
        elseif h.Database.Correlate.UserData == 1
            h.Database.Correlate.UserData = 0;
        end
        for i = h.Database.List.Value
            pause(0.01)
            if h.Database.Correlate.UserData == 0
               h.Database.Correlate.String = 'Correlate';
               return 
            end
            try
                % Path is unique per file in the database, so we have to store
                % it globally in UserValues each time
                UserValues.File.Path = PamMeta.Database{i,2};
                LSUserValues(1)
                LoadTcspc([],[],@Update_Data,@Update_Display,@Shift_Detector,h.Pam,...
                    PamMeta.Database{i,1},...   %file
                    PamMeta.Database{i,3});     %type
                Correlate ([],[],1)
                % set filename color to green
                h.Database.List.String{i} = ['<HTML><FONT color=00FF00>' PamMeta.Database{i,1} ' (path:' PamMeta.Database{i,2} ')</Font></html>'];
            catch
                h.Database.List.String{i}=['<HTML><FONT color=FF0000>' PamMeta.Database{i,1} ' (path:' PamMeta.Database{i,2} ')</Font></html>'];
            end
        end
        h.Database.Correlate.UserData = 0;
        h.Database.Correlate.String = 'Correlate';
    case 6 %% Burst analyse active ones in database
        for i = h.Database.List.Value
            try
            % Path is unique per file in the database, so we have to store
            % it globally in UserValues each time
            UserValues.File.Path = PamMeta.Database{i,2};
            LSUserValues(1)
            LoadTcspc([],[],@Update_Data,@Update_Display,@Shift_Detector,h.Pam,...
                PamMeta.Database{i,1},...   %file
                PamMeta.Database{i,3});     %type
            Do_BurstAnalysis
            % depending on whether the '2CDE' and 'lifetime' checkboxes are
            % checked on the 'Burst analysis' tab, this might also be performed
            % set filename color to green
            h.Database.List.String{i}=['<HTML><FONT color=00FF00>' h.Database.List.String{i} '</Font></html>'];
            catch
                %set filename color to red
                h.Database.List.String{i}=['<HTML><FONT color=FF0000>' h.Database.List.String{i} '</Font></html>'];
            end
        end
        % here some button to push, to put the colors back to black
    case 7 %% Loads selected files into Pam
        %%% Caution! Only works if Path and filetype are the same for all files!        
        h.Progress_Text.String='Loading new file';
        % Path is unique per file in the database, so we have to store
        % it globally in UserValues each time
        UserValues.File.Path = PamMeta.Database{h.Database.List.Value(1),2};
        LSUserValues(1)
        LoadTcspc([],[],@Update_Data,@Update_Display,@Shift_Detector,h.Pam,...
            PamMeta.Database(h.Database.List.Value,1),...   %file
            PamMeta.Database{h.Database.List.Value(1),3});     %type
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions concerning database for quick export %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function Export_Database(~,e,mode)
global UserValues PamMeta FileInfo
h = guidata(findobj('Tag','Pam'));

if mode == 0 %%% Checks, which key was pressed
    switch e.Key
        case 'delete'
            mode = 2;
%         case 'return'
%             mode =7;
    end
end

switch mode
    case 1 %% Add files to database
        LSUserValues(0);        
        while true %%% Continuously askes for more files, till none was selected
            %%% following code is for remembering the last used FileType
            %%% Loads all possible file types
            Filetypes = UserValues.File.SPC_FileTypes;
            %%% Finds last used file type
            Lastfile = UserValues.File.OpenTCSPC_FilterIndex;
            if isempty(Lastfile) || numel(Lastfile)~=1 || ~isnumeric(Lastfile) || isnan(Lastfile) ||  Lastfile <1
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
                break
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
            PamMeta.Export{end+1,1} = FileName;
            PamMeta.Export{end,2} = Path;
            PamMeta.Export{end,3} = Type;
            h.Export.List.String{end+1} = [num2str(numel(FileName)) ' Files: ' FileName{1} ' (path:' Path ')'];
            
            h.Export.TIFF.Enable = 'on';
            h.Export.Save.Enable = 'on';
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
    case 4 %% Save complete database
        [File, Path] = uiputfile({'*.edb', 'Database file'}, 'Save export database', UserValues.File.Path);
        if all(FileName==0)
            return
        end
        s = struct;
        s.export = PamMeta.Export;
        s.str = h.Export.List.String;
        save(fullfile(Path,File),'s');
    case 5 %% Export PIE channels as TIFF
        if h.Export.TIFF.UserData == 0
            h.Export.TIFF.UserData = 1;
            h.Export.TIFF.String = 'Stop';
        elseif h.Export.TIFF.UserData == 1
            h.Export.TIFF.UserData = 0;
        end
        Sel = find(h.Export.PIE.Data);
        if numel(Sel)==0
            return;
        end
        event.Key = 'Export_Image_Tiff';
        for i = h.Export.List.Value
            pause(0.01)
            if h.Export.TIFF.UserData == 0
                h.Export.TIFF.String = 'Export TIFFs';
                h.Progress_Text.String = FileInfo.FileName{1};
                h.Progress_Axes.Color=UserValues.Look.Control;
                return
            end
            try
                % Path is unique per file in the database, so we have to store
                % it globally in UserValues each time
                UserValues.File.Path = PamMeta.Export{i,2};
                LSUserValues(1)
                LoadTcspc([],[],@Update_Data,@Update_Display,@Shift_Detector,h.Pam,...
                    PamMeta.Export{i,1},...   %file
                    PamMeta.Export{i,3});     %type
                Pam_Export([],event,Sel,1)
                % set filename color to green
                h.Export.List.String{i} = ['<HTML><FONT color=00FF00>' num2str(numel(PamMeta.Export{i,1}{1})) ' Files: ' PamMeta.Export{i,1}{1} ' (path:' PamMeta.Export{i,2} ')</Font></html>'];
            catch
                h.Export.List.String{i}=['<HTML><FONT color=FF0000>' num2str(numel(PamMeta.Export{i,1}{1})) ' Files: ' PamMeta.Export{i,1}{1} ' (path:' PamMeta.Export{i,2} ')</Font></html>'];
            end
            h.Progress_Text.String = FileInfo.FileName{1};
            h.Progress_Axes.Color = UserValues.Look.Control;
        end
        h.Export.TIFF.UserData = 0;
        h.Export.TIFF.String = 'Export TIFFs';
end

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
        h.Progress_Text.String = 'Exporting';
        h.Progress_Axes.Color=[1 0 0];
        drawnow;
        for i=Sel
            Det=UserValues.PIE.Detector(i);
            Rout=UserValues.PIE.Router(i);
            From=UserValues.PIE.From(i);
            To=UserValues.PIE.To(i);
            if Det>0 && all(size(TcspcData.MI)>=[Det Rout]) %%% Normal PIE channel
                MI=TcspcData.MI{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To);
                assignin('base',[UserValues.PIE.Name{i} '_MI'],MI); clear MI;
                MT=TcspcData.MT{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To);
                assignin('base',[UserValues.PIE.Name{i} '_MT'],MT); clear MT;
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
                assignin('base',[Name 'MI'],MI); clear MI;
                assignin('base',[Name 'MT'],MT); clear MT;
            end
        end
    case 'Export_Raw_File' %%% Exports macrotime and microtime as a cell for each PIE channel
        h.Progress_Text.String = 'Exporting';
        h.Progress_Axes.Color=[1 0 0];
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
                        MT{j}=MT{j}(MI{j}>=From & MI{j}<=To)-(j-1)*round(FileInfo.MeasurementTime/FileInfo.SyncPeriod);
                    end
                end
                assignin('base',[UserValues.PIE.Name{i} '_MI'],MI); clear MI;
                assignin('base',[UserValues.PIE.Name{i} '_MT'],MT); clear MT;
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
                assignin('base',[Name 'MI'],MI); clear MI;
                assignin('base',[Name 'MT'],MT); clear MT;
            end
            
        end
    case 'Export_Image_Total'%%% Plots image and exports it into workspace
        h.Progress_Text.String = 'Exporting';
        h.Progress_Axes.Color=[1 0 0];
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
            if h.MT_Image_Export.Value == 1 || h.MT_Image_Export.Value == 2
                assignin('base',[Name 'Image'],PamMeta.Image{i});
                figure('Name',[UserValues.PIE.Name{i} '_Image']);
                imagesc(PamMeta.Image{i});
            end
            %%% Exports mean arrival time image
            if h.MT_Image_Export.Value == 1 || h.MT_Image_Export.Value == 3
                assignin('base',[Name '_LT'],PamMeta.Lifetime{i});
                figure('Name',[UserValues.PIE.Name{i} '_LT']);
                imagesc(PamMeta.Lifetime{i});
            end
        end
        %%% gives focus back to Pam
        figure(h.Pam);
    case 'Export_Image_File' %%% Exports image stack into workspace
        h.Progress_Text.String = 'Exporting';
        h.Progress_Axes.Color=[1 0 0];
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
            
            %%% Calculates pixel times for each line and file
            Pixeltimes=zeros(FileInfo.Lines^2,FileInfo.NumberOfFiles);
            for j=1:FileInfo.NumberOfFiles
                for k=1:FileInfo.Lines
                    Pixel=linspace(FileInfo.LineTimes(k,j),FileInfo.LineTimes(k+1,j),FileInfo.Lines+1);
                    Pixeltimes(((k-1)*FileInfo.Lines+1):(k*FileInfo.Lines),j)=Pixel(1:end-1);
                end
            end
            
            %%% Histograms photons to pixels
            Stack=uint16(histc(Stack,Pixeltimes(:)));
            %%% Reshapes pixelvector to a pixel x pixel x frames matrix
            Stack=flip(permute(reshape(Stack,FileInfo.Lines,FileInfo.Lines,FileInfo.NumberOfFiles),[2 1 3]),1);
            %%% Exports matrix to workspace
            if strfind(UserValues.PIE.Name{i},'Comb.:')
                Name = '';
                for j = UserValues.PIE.Combined{i}
                    Name = [Name UserValues.PIE.Name{j} '_'];
                end
                assignin('base',[Name 'Image'],Stack);
            else
                assignin('base',[UserValues.PIE.Name{i} '_Image'],Stack);
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
        h.Progress_Text.String = 'Exporting';
        h.Progress_Axes.Color=[1 0 0];
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
            
            %%% Calculates pixel times for each line and file
            Pixeltimes=zeros(FileInfo.Lines^2,FileInfo.NumberOfFiles);
            for j=1:FileInfo.NumberOfFiles
                for k=1:FileInfo.Lines
                    Pixel=linspace(FileInfo.LineTimes(k,j),FileInfo.LineTimes(k+1,j),FileInfo.Lines+1);
                    Pixeltimes(((k-1)*FileInfo.Lines+1):(k*FileInfo.Lines),j)=Pixel(1:end-1);
                end
            end
            
            %%% Histograms photons to pixels
            Stack=uint16(histc(Stack,Pixeltimes(:)));
            %%% Reshapes pixelvector to a pixel x pixel x frames matrix
            Stack=flip(permute(reshape(Stack,FileInfo.Lines,FileInfo.Lines,FileInfo.NumberOfFiles),[2 1 3]),1);
            
            File=fullfile(Path,[FileInfo.FileName{1}(1:end-4) UserValues.PIE.Name{i} '.tif']);
            
            TIFF_handle = Tiff(File, 'w');
            Tagstruct.ImageLength = FileInfo.Lines;
            Tagstruct.ImageWidth = FileInfo.Lines;
            Tagstruct.Compression = 5; %1==None; 5==LZW
            Tagstruct.SampleFormat = 1; %UInt
            Tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
            Tagstruct.BitsPerSample =  16;                        %32= float data, 16= Andor standard sampling
            Tagstruct.SamplesPerPixel = 1;
            Tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            if isfield(FileInfo, 'Fabsurf') && ~isempty(FileInfo.Fabsurf)
                Tagstruct.ImageDescription = ['Type: ' FileInfo.FileType '\n',...
                    'FrameTime [s]: ' num2str(FileInfo.ImageTime) '\n',...
                    'LineTime [ms]: ' num2str(FileInfo.ImageTime/FileInfo.Lines*1000) '\n',...
                    'PixelTime [us]: ' num2str(FileInfo.ImageTime/FileInfo.Lines^2*1e6) '\n',...
                    'PixelSize [nm]: ' num2str(FileInfo.Fabsurf.Imagesize/FileInfo.Lines*1000) '\n'];
            else
                Tagstruct.ImageDescription = ['Type: ' FileInfo.FileType '\n',...
                    'FrameTime [s]: ' num2str(FileInfo.ImageTime) '\n',...
                    'LineTime [ms]: ' num2str(FileInfo.ImageTime/FileInfo.Lines*1000) '\n',...
                    'PixelTime [us]: ' num2str(FileInfo.ImageTime/FileInfo.Lines^2*1e6) '\n',...
                    'PixelSize [nm]: ' '50' '\n'];
            end
            TIFF_handle.setTag(Tagstruct);

            for j=1:size(Stack,3)                
                TIFF_handle.write(Stack(:,:,j));
                if j<size(Stack,3)
                    TIFF_handle.writeDirectory();
                    TIFF_handle.setTag(Tagstruct);
                end
            end
             TIFF_handle.close()

        end
        Progress((i-1)/numel(Sel),h.Progress_Axes,h.Progress_Text,'Exporting:')
end