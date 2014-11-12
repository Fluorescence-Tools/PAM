function Pam
global UserValues FileInfo PamMeta TcspcData
h.Pam=findobj('Tag','Pam');

if isempty(h.Pam) % Creates new figure, if none exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Disables uitabgroup warning
    warning('off','MATLAB:uitabgroup:OldVersion');   
    %%% Loads user profile    
    [Profiles,~]=LSUserValues(0);
    %%% To save typing
    Look=UserValues.Look;    
    %%% Generates the Pam figure
    
    Figure = figure(...
        'Units','normalized',...
        'Tag','Pam',...
        'Name','PAM: PIE Analysis with Matlab',...
        'NumberTitle','off',...
        'Menu','none',...
        'defaultUicontrolFontName','Times',...
        'defaultAxesFontName','Times',...
        'defaultTextFontName','Times',...
        'Toolbar','figure',...
        'UserData',[],...
        'OuterPosition',[0.01 0.1 0.98 0.9],...
        'CloseRequestFcn',@Close_Pam,...
        'Visible','on');
    h.Pam=handle(Figure);    
    %h.Pam.Visible='off';
    
    %%% Sets background of axes and other things
    whitebg(Look.Axes);
    %%% Changes Pam background; must be called after whitebg
    h.Pam.Color=Look.Back;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Menubar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
    %%% File menu with loading, saving and exporting functions
    File = uimenu(...
        'Parent',h.Pam,...
        'Tag','File',...
        'Label','File');
    h.File=handle(File);

    Loadtcspc = uimenu(h.File,...
        'Tag','LoadTcspc',...
        'Label','Load Tcspc Data',...
        'Callback',{@LoadTcspc,@Update_Data,@Calibrate_Detector,h.Pam});
    h.LoadTcspc=handle(Loadtcspc);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Progressbar and file name %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Panel for progressbar
    Progress_Panel = uibuttongroup(...
        'Parent',Figure,...
        'Tag','Progress_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0.01 0.96 0.485 0.03]);
    h.Progress_Panel=handle(Progress_Panel);
    %%% Axes for progressbar
    Progress_Axes = axes(...
        'Parent',Progress_Panel,...
        'Tag','Progress_Axes',...
        'Units','normalized',...
        'Color',Look.Control,...
        'Position',[0 0 1 1]);
    h.Progress_Axes=handle(Progress_Axes);
    h.Progress_Axes.XTick=[]; h.Progress_Axes.YTick=[];
    %%% Progress and filename text
    Progress_Text=text(...
        'Parent',Progress_Axes,...
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
    h.Progress_Text=handle(Progress_Text);    

%% Microtime tabs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Microtime tabs container
    MI_Tabs = uitabgroup(...
        'Parent',h.Pam,...
        'Tag','MI_Tabs',...
        'Units','normalized',...
        'Position',[0.505 0.01 0.485 0.98]);
    h.MI_Tabs=handle(MI_Tabs);  
    
    %%% Invisible dummy tabgroup to put "unused" tab in
    Dummy_Tabgroup = uitabgroup(...
        'Parent',h.Pam,...
        'Tag','Dummy_Tabgroup',...
        'Units','pixel',...
        'Position',[0 0 1 1],...
        'Visible','off');
    h.Dummy_Tabgroup=handle(Dummy_Tabgroup);
    %%% Dummy tab to keep Dummy_Tabgroup from being empty
    h.Dummy_Tab = handle(uitab('Parent',Dummy_Tabgroup));   
    %% Plot and functions for all microtimes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% All microtime tab
    MI_All_Tab= uitab(...
        'Parent',MI_Tabs,...
        'Tag','MI_All_Tab',...
        'Title','Microtimes');
    h.MI_All_Tab=handle(MI_All_Tab);

    %%% All microtime panel
    MI_All_Panel = uibuttongroup(...
        'Parent',MI_All_Tab,...
        'Tag','MI_All_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    h.MI_All_Panel=handle(MI_All_Panel);
    
    %%% Contexmenu for all microtime axes
    MI_Menu = uicontextmenu;
    h.MI_Menu=handle(MI_Menu);
    %%% Menu for Log scal plotting
    MI_Log = uimenu(...
        'Parent',MI_Menu,...
        'Label','Plot as log scale',...
        'Tag','MI_Log',...
        'Callback',@MI_Axes_Menu);
    h.MI_Log=handle(MI_Log);

    %%% All microtime axes
    MI_All_Axes = axes(...
        'Parent',MI_All_Panel,...
        'Tag','MI_All_Axes',...
        'Units','normalized',...
        'NextPlot','add',...
        'UIContextMenu',MI_Menu,...        
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Position',[0.09 0.05 0.89 0.93],...
        'Box','on');
    h.MI_All_Axes=handle(MI_All_Axes);
    h.MI_All_Axes.XLabel.String='TAC channel';
    h.MI_All_Axes.XLabel.Color=Look.Fore;
    h.MI_All_Axes.YLabel.String='Counts';
    h.MI_All_Axes.YLabel.Color=Look.Fore;
    h.MI_All_Axes.XLim=[1 4096];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Mictrotime plots general settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Microtime settings tab
    MI_Settings_Tab= uitab(...
        'Parent',MI_Tabs,...
        'Tag','MI_Settings_Tab',...
        'Title','Settings');
    h.MI_Settings_Tab=handle(MI_Settings_Tab);
    %%% Microtime settings panel
    MI_Settings_Panel = uibuttongroup(...
        'Parent',MI_Settings_Tab,...
        'Tag','MI_Settings_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    h.MI_Settings_Panel=handle(MI_Settings_Panel);  
    
    %%% Contexmenu for MI Channels List
    MI_Channels_Menu = uicontextmenu;
    h.MI_Channels_Menu=handle(MI_Channels_Menu);
    %%% Menu to add MI channels
    MI_Add = uimenu(...
        'Parent',MI_Channels_Menu,...
        'Label','Add new microtime channel',...
        'Tag','MI_Add',...
        'Callback',@MI_Channels_Functions);
    h.MI_Add=handle(MI_Add);
    %%% Menu to delete MI channels
    MI_Delete = uimenu(...
        'Parent',MI_Channels_Menu,...
        'Label','Delete selected microtime channels',...
        'Tag','MI_Delete',...
        'Callback',@MI_Channels_Functions);
    h.MI_Delete=handle(MI_Delete);
    %%% Menu to enable MI channels
    MI_Enable = uimenu(...
        'Parent',MI_Channels_Menu,...
        'Label','Enable selected microtime channels',...
        'Tag','MI_Enable',...
        'Callback',@MI_Channels_Functions);
    h.MI_Enable=handle(MI_Enable);
    %%% Menu to delete MI channels
    MI_Disable = uimenu(...
        'Parent',MI_Channels_Menu,...
        'Label','Disable selected microtime channels',...
        'Tag','MI_Disable',...
        'Callback',@MI_Channels_Functions);
    h.MI_Disable=handle(MI_Disable);
    %%% Menu to change MI channel color
    MI_Color = uimenu(...
        'Parent',MI_Channels_Menu,...
        'Label','Change microtime channel color',...
        'Tag','MI_Color',...
        'Callback',@MI_Channels_Functions);
    h.MI_Color=handle(MI_Color);
    
    %%% List of detector/routing pairs to use     
    MI_Channels_List = uicontrol(...
        'Parent',MI_Settings_Panel,...
        'Tag','MI_Channels_List',...
        'Style','listbox',...
        'Units','normalized',...
        'FontSize',14,...
        'Max',2,...
        'TooltipString',sprintf('List of detector/routing pairs to be loaded/displayed \n disabled denotes pairs that will be loaded but not displayed'),...
        'Uicontextmenu',MI_Channels_Menu,...
        'KeyPressFcn',@MI_Channels_Functions,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.71 0.5 0.28]);
    h.MI_Channels_List=handle(MI_Channels_List);
    %% Plots and navigation for phasor referencing
    %%% Phasor referencing tab    
    MI_Phasor_Tab= uitab(...
        'Parent',MI_Tabs,...
        'Tag','MI_Phasor_Tab',...
        'Title','Phasor Referencing');
    h.MI_Phasor_Tab=handle(MI_Phasor_Tab);    
    %%% Phasor referencing panel
    MI_Phasor_Panel = uibuttongroup(...
        'Parent',MI_Phasor_Tab,...
        'Tag','MI_All_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    h.MI_Phasor_Panel=handle(MI_Phasor_Panel);
    %%% Text    
    uicontrol(...
        'Parent',MI_Phasor_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'String','Shift:',...
        'Horizontalalignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.965 0.06 0.025]);
    %%% Editbox for showing and setting shift
    MI_Phasor_Shift = uicontrol(...
        'Parent',MI_Phasor_Panel,...
        'Tag','MI_Phasor_Shift',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'String','0',...
        'Callback',@Update_Phasor_Shift,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.08 0.965 0.08 0.025]);
    h.MI_Phasor_Shift=handle(MI_Phasor_Shift);
    %%% Shift slider
    MI_Phasor_Slider = uicontrol(...
        'Parent',MI_Phasor_Panel,...
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
    h.MI_Phasor_Slider=handle(MI_Phasor_Slider);
    %%% Text    
    uicontrol(...
        'Parent',MI_Phasor_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'String','Range to use:',...
        'Horizontalalignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.18 0.965 0.15 0.025]);
    %%% Phasor Range From
    MI_Phasor_From = uicontrol(...
        'Parent',MI_Phasor_Panel,...
        'Tag','MI_Phasor_From',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'String','1',...
        'Callback',{@Update_Display;6},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.34 0.965 0.08 0.025]);
    h.MI_Phasor_From=handle(MI_Phasor_From);
    %%% Phasor Range To
    MI_Phasor_To = uicontrol(...
        'Parent',MI_Phasor_Panel,...
        'Tag','MI_Phasor_To',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'String','4000',...
        'Callback',{@Update_Display;6},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.43 0.965 0.08 0.025]);
    h.MI_Phasor_To=handle(MI_Phasor_To);  
    %%% Phasor detector channel
    MI_Phasor_Det = uicontrol(...
        'Parent',MI_Phasor_Panel,...
        'Tag','MI_Phasor_Det',...
        'Style','popupmenu',...
        'Units','normalized',...
        'FontSize',12,...
        'String',{''},...
        'Callback',{@Update_Display;6},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.18 0.93 0.33 0.025]);
    h.MI_Phasor_Det=handle(MI_Phasor_Det); 
    %%% Phasor reference selection
    MI_Phasor_UseRef = uicontrol(...
        'Parent',MI_Phasor_Panel,...
        'Tag','MI_Phasor_UseRef',...
        'Style','pushbutton',...
        'Units','normalized',...
        'FontSize',12,...
        'String','Use MI as reference',...
        'Callback',@Phasor_UseRef,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.52 0.965 0.25 0.025]);
    h.MI_Phasor_UseRef=handle(MI_Phasor_UseRef);
    %%% Phasor reference selection
    MI_Calc_Phasor = uicontrol(...
        'Parent',MI_Phasor_Panel,...
        'Tag','MI_Calc_Phasor',...
        'Style','pushbutton',...
        'Units','normalized',...
        'FontSize',12,...
        'String','Calculate Phasor Data',...
        'Callback',@Phasor_Calc,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.52 0.93 0.25 0.025]);
    h.MI_Calc_Phasor=handle(MI_Calc_Phasor);
    %%% Text    
    uicontrol(...
        'Parent',MI_Phasor_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'String','Ref LT [ns]:',...
        'Horizontalalignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.78 0.965 0.13 0.025]);
    %%% Editbox for the reference lifetime
    MI_Phasor_Ref = uicontrol(...
        'Parent',MI_Phasor_Panel,...
        'Tag','MI_Phasor_Ref',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'String','4.1',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.91 0.965 0.08 0.025]);
    h.MI_Phasor_Ref=handle(MI_Phasor_Ref);
    %%% Text    
    uicontrol(...
        'Parent',MI_Phasor_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'String','TAC [ns]:',...
        'Horizontalalignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.78 0.93 0.13 0.025]);
    %%% Editbox for the TAC range
    MI_Phasor_TAC = uicontrol(...
        'Parent',MI_Phasor_Panel,...
        'Tag','MI_Phasor_TAC',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'String','40',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.91 0.93 0.08 0.025]);
    h.MI_Phasor_TAC=handle(MI_Phasor_TAC);
    %%% Phasor referencing axes
    MI_Phasor_Axes = axes(...
        'Parent',MI_Phasor_Panel,...
        'Tag','MI_Phasor_Axes',...
        'Units','normalized',...
        'NextPlot','add',...
        'UIContextMenu',MI_Menu,...        
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Position',[0.09 0.05 0.89 0.83],...
        'Box','on');
    h.MI_Phasor_Axes=handle(MI_Phasor_Axes);
    h.MI_Phasor_Axes.XLabel.String='TAC channel';
    h.MI_Phasor_Axes.XLabel.Color=Look.Fore;
    h.MI_Phasor_Axes.YLabel.String='Counts';
    h.MI_Phasor_Axes.YLabel.Color=Look.Fore;
    h.MI_Phasor_Axes.XLim=[1 4096];
    h.Plots.PhasorRef=handle(plot([0 1],[0 0],'b')); 
    h.Plots.Phasor=handle(plot([0 4000],[0 0],'r')); 
    %% Tab for calibrating Detectors
    %%% Detector calibration tab    
    MI_Calib_Tab= uitab(...
        'Parent',MI_Tabs,...
        'Tag','MI_Calib_Tab',...
        'Title','Detector Calibration');
    h.MI_Calib_Tab=handle(MI_Calib_Tab);    
    %%% Detector calibration panel
    MI_Calib_Panel = uibuttongroup(...
        'Parent',MI_Calib_Tab,...
        'Tag','MI_Calib_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    h.MI_Calib_Panel=handle(MI_Calib_Panel);
    %%% Button to start calibration
    MI_Calib_Calc = uicontrol(...
        'Parent',MI_Calib_Panel,...
        'Tag','MI_Calib_Calc',...
        'Style','pushbutton',...
        'Units','normalized',...
        'FontSize',12,...
        'String','Calculate correction',...
        'Callback',@Calibrate_Detector,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.965 0.25 0.025]);
    h.MI_Calib_Calc=handle(MI_Calib_Calc);
    %%% Detector calibration channel
    MI_Calib_Det = uicontrol(...
        'Parent',MI_Calib_Panel,...
        'Tag','MI_Calib_Det',...
        'Style','popupmenu',...
        'Units','normalized',...
        'FontSize',12,...
        'String',{''},...
        'Callback',{@Update_Display;7},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.93 0.25 0.025]);
    h.MI_Calib_Det=handle(MI_Calib_Det); 
    %%% Interphoton time selection
    MI_Calib_Single = uicontrol(...
        'Parent',MI_Calib_Panel,...
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
        'Position',[0.28 0.965 0.25 0.025]);
    h.MI_Calib_Single=handle(MI_Calib_Single);
    %%% Show interphoton time
    MI_Calib_Single_Text = uicontrol(...
        'Parent',MI_Calib_Panel,...
        'Tag','MI_Calib_Single_Text',...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'String','1',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.54 0.965 0.05 0.025]);
    h.MI_Calib_Single_Text=handle(MI_Calib_Single_Text);
    %%% Text
    uicontrol(...
        'Parent',MI_Calib_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','Left',...
        'String','Range',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.28 0.93 0.1 0.025]);

    %%% Sum interphoton time bins
    MI_Calib_Single_Range = uicontrol(...
        'Parent',MI_Calib_Panel,...
        'Tag','MI_Calib_Single_Range',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'String','1',...
        'Callback',{@Update_Display;7},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.38 0.93 0.05 0.025]);
    h.MI_Calib_Single_Range=handle(MI_Calib_Single_Range); 
    %%% Saves current shift
    MI_Calib_Save = uicontrol(...
        'Parent',MI_Calib_Panel,...
        'Tag','MI_Calib_Save',...
        'Style','pushbutton',...
        'Units','normalized',...
        'FontSize',12,...
        'String','Save Shift',...
        'Callback',@Det_Calib_Save,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.45 0.93 0.12 0.025]);
    h.MI_Calib_Save=handle(MI_Calib_Save); 
    
    %%% Detector calibration axes    
    MI_Calib_Axes = axes(...
        'Parent',MI_Calib_Panel,...
        'Tag','MI_Calib_Axes',...
        'Units','normalized',...
        'NextPlot','add',...
        'UIContextMenu',MI_Menu,...        
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Position',[0.09 0.4 0.89 0.48],...
        'Box','on');
    h.MI_Calib_Axes=handle(MI_Calib_Axes);
    h.MI_Calib_Axes.XLabel.String='TAC channel';
    h.MI_Calib_Axes.XLabel.Color=Look.Fore;
    h.MI_Calib_Axes.YLabel.String='Counts';
    h.MI_Calib_Axes.YLabel.Color=Look.Fore;
    h.MI_Calib_Axes.XLim=[1 4096];
    h.Plots.Calib_No=handle(plot([0 1], [0 0],'b'));
    h.Plots.Calib=handle(plot([0 1], [0 0],'r'));
    h.Plots.Calib_Cur=handle(plot([0 1], [0 0],'c'));
    h.Plots.Calib_Sel=handle(plot([0 1], [0 0],'g'));
    
    %%% Detector calibration shift axes    
    MI_Calib_Axes_Shift = axes(...
        'Parent',MI_Calib_Panel,...
        'Tag','MI_Calib_Axes_Shift',...
        'Units','normalized',...
        'NextPlot','add',...      
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Position',[0.09 0.05 0.89 0.28],...
        'Box','on');
    h.MI_Calib_Axes_Shift=handle(MI_Calib_Axes_Shift);
    h.MI_Calib_Axes_Shift.XLabel.String='Interphoton time [macrotime ticks]';
    h.MI_Calib_Axes_Shift.XLabel.Color=Look.Fore;
    h.MI_Calib_Axes_Shift.YLabel.String='Shift [microtime ticks]';
    h.MI_Calib_Axes_Shift.YLabel.Color=Look.Fore;
    h.MI_Calib_Axes_Shift.XLim=[1 400];
    h.Plots.Calib_Shift_Applied=handle(plot(1:400, zeros(400,1),'b'));
    h.Plots.Calib_Shift_New=handle(plot(1:400, zeros(400,1),'r'));

    
%% Trace and Image tabs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Macrotime tabs container
    MT_Tab = uitabgroup(...
        'Parent',h.Pam,...
        'Tag','MT_Tab',...
        'Units','normalized',...
        'Position',[0.01 0.01 0.485 0.485]);
    h.MT_Tab=handle(MT_Tab);       
    %% Plot and functions for intensity trace %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Intensity trace tab
    Trace_Tab= uitab(...
        'Parent',MT_Tab,...
        'Tag','Trace_Tab',...
        'Title','Intensity Trace');
    h.Trace_Tab=handle(Trace_Tab);

    %%% Intensity trace panel
    Trace_Panel = uibuttongroup(...
        'Parent',Trace_Tab,...
        'Tag','Trace_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    h.Trace_Panel=handle(Trace_Panel);

    %%% Intensity trace axes
    Trace_Axes = axes(...
        'Parent',Trace_Panel,...
        'Tag','Trace_Axes',...
        'Units','normalized',...
        'NextPlot','add',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'Position',[0.08 0.1 0.9 0.87],...
        'Box','on');
    h.Trace_Axes=handle(Trace_Axes);
    h.Trace_Axes.XLabel.String='Time [s]';
    h.Trace_Axes.XLabel.Color=Look.Fore;
    h.Trace_Axes.YLabel.String='Countrate [kHz]';
    h.Trace_Axes.YLabel.Color=Look.Fore;
    h.Plots.Trace=handle(plot([0 1],[0 0],'b')); 
    %%%         
    %% Plot and functions for image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Image tab
    Image_Tab= uitab(...
        'Parent',MT_Tab,...
        'Tag','Image_Tab',...
        'Title','Image');
    h.Image_Tab=handle(Image_Tab);
    
    %%% Image panel
    Image_Panel = uibuttongroup(...
        'Parent',Image_Tab,...
        'Tag','Image_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    h.Image_Panel=handle(Image_Panel);
    
    %%% Image axes
    Image_Axes = axes(...
        'Parent',Image_Panel,...
        'Tag','Image_Axes',...
        'Units','normalized',...
        'Position',[0.01 0.01 0.7 0.98]);
    h.Image_Axes=handle(Image_Axes);
    h.Plots.Image=handle(imagesc(0));
    h.Image_Axes.XTick=[]; h.Image_Axes.YTick=[];
    h.Image_Colorbar=colorbar;
    colormap(jet);
    h.Image_Colorbar.Color=Look.Fore;
    
    %%% Popupmenu to switch between intensity and mean arrival time images
    Image_Type = uicontrol(...
        'Parent',Image_Panel,...
        'Tag','Image_Type',...
        'Style','popupmenu',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@Update_Display,...
        'String',{'Intensity';'Mean arrival time'},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.75 0.92 0.24 0.06]);
    h.Image_Type=handle(Image_Type);
    
    %%% Checkbox that determins if autoscale is on
    Image_Autoscale = uicontrol(...
        'Parent',Image_Panel,...
        'Tag','Image_Autoscale',...
        'Style','checkbox',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@Update_Display,...
        'String','Use Autoscale',...
        'Value',1,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.75 0.84 0.24 0.06]);
    h.Image_Autoscale=handle(Image_Autoscale);   

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Settings for trace and image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Setting tab
    MT_Settings_Tab= uitab(...
        'Parent',MT_Tab,...
        'Tag','MT_Settings_Tab',...
        'Title','Settings');
    h.MT_Settings_Tab=handle(MT_Settings_Tab);
    
    %%% Settings panel
    MT_Settings_Panel = uibuttongroup(...
        'Parent',MT_Settings_Tab,...
        'Tag','MT_Settings_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    h.MT_Settings_Panel=handle(MT_Settings_Panel);
    
    %%% Text
    uicontrol(...
        'Parent',MT_Settings_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'HorizontalAlignment','left',...
        'String','Binning size for trace [ms]:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.92 0.34 0.06]);
    
    %%% Mactotime binning
    MT_Binning = uicontrol(...
        'Parent',MT_Settings_Panel,...
        'Tag','MT_Binning',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',14,...
        'Callback',@Calculate_Settings,...
        'String','10',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.36 0.92 0.1 0.06]);
    h.MT_Binning=handle(MT_Binning);
    
    %%% Text
    uicontrol(...
        'Parent',MT_Settings_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'HorizontalAlignment','left',...
        'String','MT sectioning type:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.82 0.26 0.06]); 
    
    %%% Trace sectioning settings
    MT_Trace_Sectioning = uicontrol(...
        'Parent',MT_Settings_Panel,...
        'Tag','MT_Trace_Sectioning',...
        'Style','popupmenu',...
        'Units','normalized',...
        'FontSize',14,...
        'Callback',@Calculate_Settings,...
        'String',{'Constant number';'Constant time'},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.28 0.83 0.28 0.06]);
    h.MT_Trace_Sectioning=handle(MT_Trace_Sectioning);
    
    %%% Text
    uicontrol(...
        'Parent',MT_Settings_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'HorizontalAlignment','left',...
        'String','Sectioning time [s]:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.72 0.26 0.06]);
    
    %%% Time Sectioning
    MT_Time_Section = uicontrol(...
        'Parent',MT_Settings_Panel,...
        'Tag','MT_Time_Section',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',14,...
        'Callback',@Calculate_Settings,...
        'String','5',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.28 0.72 0.1 0.06]);
    h.MT_Time_Section=handle(MT_Time_Section);
    
    %%% Text
    uicontrol(...
        'Parent',MT_Settings_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'HorizontalAlignment','left',...
        'String','Section number:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.62 0.26 0.06]);
    
    %%% Number Sectioning
    MT_Number_Section = uicontrol(...
        'Parent',MT_Settings_Panel,...
        'Tag','MT_Number_Section',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',14,...
        'Callback',@Calculate_Settings,...
        'String','10',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.28 0.62 0.1 0.06]);
    h.MT_Number_Section=handle(MT_Number_Section);
    
    %%% Text
    uicontrol(...
        'Parent',MT_Settings_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'HorizontalAlignment','left',...
        'String','Images to export:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.42 0.23 0.06]);  
    
    %%% Image exporting settings
    MT_Image_Export = uicontrol(...
        'Parent',MT_Settings_Panel,...
        'Tag','MT_Image_Export',...
        'Style','popupmenu',...
        'Units','normalized',...
        'FontSize',14,...
        'String',{'Both';'Intensity';'Mean arrival time'},...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Value',2,...
        'Position',[0.28 0.43 0.28 0.06]);
    h.MT_Image_Export=handle(MT_Image_Export);
    
    %%% Checkbox to determine if image is calculated
    MT_Use_Image = uicontrol(...
        'Parent',MT_Settings_Panel,...
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
    h.MT_Use_Image=handle(MT_Use_Image);
    
    %%% Checkbox to determine if mean arrival time image is calculated
    MT_Use_Lifetime = uicontrol(...
        'Parent',MT_Settings_Panel,...
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
    h.MT_Use_Lifetime=handle(MT_Use_Lifetime);

%% Various tabs (PIE Channels, general information, settings etc.) %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Macrotime tabs container
    Var_Tab = uitabgroup(...
        'Parent',h.Pam,...
        'Tag','Var_Tab',...
        'Units','normalized',...
        'Position',[0.01 0.505 0.485 0.442]);
    h.Var_Tab=handle(Var_Tab);        
    %% PIE Channels and general information tab
    PIE_Tab= uitab(...
        'Parent',Var_Tab,...
        'Tag','PIE_Tab',...
        'Title','PIE');
    h.PIE_Tab=handle(PIE_Tab);
    
    %%% PIE Channels and general information panel
    PIE_Panel = uibuttongroup(...
        'Parent',PIE_Tab,...
        'Tag','PIE_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    h.PIE_Panel=handle(PIE_Panel);
    
    %%% Contexmenu for PIE Channel list
    PIE_List_Menu = uicontextmenu;
    h.PIE_List_Menu=handle(PIE_List_Menu);
    %%% Menu for PIE channel navigation
    PIE_Channels = uimenu(...
        'Parent',PIE_List_Menu,...
        'Label','PIE channel',...
        'Tag','PIE_Channels');
    h.PIE_Channels=handle(PIE_Channels);
    %%% Adds new PIE Channel
    PIE_Add = uimenu(...
        'Parent',PIE_Channels,...
        'Label','Add new PIE channel',...
        'Tag','PIE_Add',...
        'Callback',@PIE_List_Functions);
    h.PIE_Add=handle(PIE_Add);
    %%% Deletes selected PIE Channels
    PIE_Delete = uimenu(...
        'Parent',PIE_Channels,...
        'Label','Delete selected channels',...
        'Tag','PIE_Delete',...
        'Callback',@PIE_List_Functions);
    h.PIE_Delete=handle(PIE_Delete);
    %%% Creates Combined Channel
    PIE_Combine = uimenu(...
        'Parent',PIE_Channels,...
        'Label','Create combined channel',...
        'Tag','PIE_Combine',...
        'Callback',@PIE_List_Functions);
    h.PIE_Combine=handle(PIE_Combine);
    %%% Manually select microtime
    PIE_Select = uimenu(...
        'Parent',PIE_Channels,...
        'Label','Manually select microtime',...
        'Tag','PIE_Select',...
        'Callback',@PIE_List_Functions);
    h.PIE_Select=handle(PIE_Select);
    %%% Changes Channel Color
    PIE_Color = uimenu(...
        'Parent',PIE_List_Menu,...
        'Label','Change channel colors',...
        'Tag','PIE_Color',...
        'Callback',@PIE_List_Functions);
    h.PIE_Color=handle(PIE_Color);
    %%% Export main
    PIE_Export = uimenu(...
        'Parent',PIE_List_Menu,...
        'Label','Export...',...
        'Tag','PIE_Export');
    h.PIE_Export=handle(PIE_Export);
    %%% Exports MI and MT as one vector each
    PIE_Export_Raw_Total = uimenu(...
        'Parent',PIE_Export,...
        'Label','...Raw data (total)',...
        'Tag','PIE_Export_Raw_Total',...
        'Callback',@PIE_List_Functions);
    h.PIE_Export_Raw_Total=handle(PIE_Export_Raw_Total);
    %%% Exports MI and MT for each file
    PIE_Export_Raw_File = uimenu(...
        'Parent',PIE_Export,...
        'Label','...Raw data (per file)',...
        'Tag','PIE_Export_Raw_File',...
        'Callback',@PIE_List_Functions);
    h.PIE_Export_Raw_File=handle(PIE_Export_Raw_File);
    %%% Exports and plots and image of the PIE channel
    PIE_Export_Image_Total = uimenu(...
        'Parent',PIE_Export,...
        'Label','...image (total)',...
        'Tag','PIE_Export_Image_Total',...
        'Callback',@PIE_List_Functions);
    h.PIE_Export_Image_Total=handle(PIE_Export_Image_Total);
    %%% Exports all frames of the PIE channel
    PIE_Export_Image_File = uimenu(...
        'Parent',PIE_Export,...
        'Label','...image (per file)',...
        'Tag','PIE_Export_Image_File',...
        'Callback',@PIE_List_Functions);
    h.PIE_Export_Image_File=handle(PIE_Export_Image_File);
    PIE_Export_Image_Tiff = uimenu(...
        'Parent',PIE_Export,...
        'Label','...image (as .tiff)',...
        'Tag','PIE_Export_Image_Tiff',...
        'Callback',@PIE_List_Functions);
    h.PIE_Export_Image_Tiff=handle(PIE_Export_Image_Tiff);
    
    %%% PIE Channel list
    PIE_List = uicontrol(...
        'Parent',PIE_Panel,...
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
        'UIContextMenu',PIE_List_Menu,...
        'Callback',@Update_Display,...
        'KeyPressFcn',@PIE_List_Functions,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.01 0.4 0.98]);
    h.PIE_List=handle(PIE_List);
    
    %%% Text
    uicontrol(...
        'Parent',PIE_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','PIE channel name:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.415 0.92 0.22 0.06]);
    
    %%% Editbox for PIE channel name
    PIE_Name = uicontrol(...
        'Parent',PIE_Panel,...
        'Tag','PIE_Name',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@Update_PIE_Channels,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.64 0.92 0.34 0.06]);
    h.PIE_Name=handle(PIE_Name);
    
    %%% Text
    uicontrol(...
        'Parent',PIE_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','Detector:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.415 0.84 0.11 0.06]);
    
    %%% Editbox for PIE channel detector
    PIE_Detector = uicontrol(...
        'Parent',PIE_Panel,...
        'Tag','PIE_Detector',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@Update_PIE_Channels,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.54 0.84 0.08 0.06]);
    h.PIE_Detector=handle(PIE_Detector);
    
    %%% Text
    uicontrol(...
        'Parent',PIE_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','Routing:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.63 0.84 0.11 0.06]);
    
    %%% Editbox for PIE channel routing
    PIE_Routing = uicontrol(...
        'Parent',PIE_Panel,...
        'Tag','PIE_Routing',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@Update_PIE_Channels,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.745 0.84 0.08 0.06]);
    h.PIE_Routing=handle(PIE_Routing);
    
    %%% Text
    uicontrol(...
        'Parent',PIE_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','From:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.415 0.76 0.11 0.06]);
    
    %%% Editbox for microtime minimum of PIE channel
    PIE_From = uicontrol(...
        'Parent',PIE_Panel,...
        'Tag','PIE_From',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@Update_PIE_Channels,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.54 0.76 0.08 0.06]);
    h.PIE_From=handle(PIE_From);
    
    %%% Text
    uicontrol(...
        'Parent',PIE_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','To:',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.63 0.76 0.11 0.06]);
    
    %%% Editbox for mictotime maximum of PIE channel
    PIE_To = uicontrol(...
        'Parent',PIE_Panel,...
        'Tag','PIE_To',...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',@Update_PIE_Channels,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.745 0.76 0.08 0.06]);
    h.PIE_To=handle(PIE_To);
    
    %%% Text
    uicontrol(...
        'Parent',PIE_Panel,...
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
    PIE_Info = uicontrol(...
        'Parent',PIE_Panel,...
        'Tag','PIE_Info',...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String',{'Total photons:';'Channel photons:'; 'Total countrate:'; 'Channel countrate:'},...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.66 0.52 0.15 0.22]);
    h.PIE_Info=handle(PIE_Info);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Correlations tab
    Cor_Tab= uitab(...
        'Parent',Var_Tab,...
        'Tag','Cor_Tab',...
        'Title','Correlate');
    h.Cor_Tab=handle(Cor_Tab);
    
    %%% Correlation panel
    Cor_Panel = uibuttongroup(...
        'Parent',Cor_Tab,...
        'Tag','Cor_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    h.Cor_Panel=handle(Cor_Panel);
    
    %%% Contexmenu for correlation table
    Cor_Menu = uicontextmenu;
    h.Cor_Menu=handle(Cor_Menu);
    %%% Adds new PIE Channel
    Cor_Multi_Menu = uimenu(...
        'Parent',Cor_Menu,...
        'Label','Use Multi-core',...
        'Tag','Cor_Multi_Menu',...
        'Callback',@Calculate_Settings);
    h.Cor_Multi_Menu=handle(Cor_Multi_Menu);
    %%% Sets a divider for correlation
    Cor_Divider_Menu = uimenu(...
        'Parent',Cor_Menu,...
        'Label','Divider: 1',...
        'Tag','Cor_Divider_Menu',...
        'Callback',@Calculate_Settings);
    h.Cor_Divider_Menu=handle(Cor_Divider_Menu);
    
    %%% Correlations table
    Cor_Table = uitable(...
        'Parent',Cor_Panel,...
        'Tag','Cor_Table',...
        'Units','normalized',...
        'FontSize',8,...
        'Position',[0.005 0.11 0.99 0.88],...
        'TooltipString',sprintf([...
            'Selection for cross correlations: \n'...
            '"Column"/"Row" (un)selects full column/row; \n'...
            'Bottom right checkbox (un)selects diagonal \n'...
            'Rightclick to open contextmenu with additional functions: \n'...
            'Use multi-core: En-/Disable use of multiple CPUs for correlation; \n'...
            'Divider: Divider for correlation time resolution for certain excitation schemes']),...
        'UIContextMenu',Cor_Menu,...
        'CellEditCallback',@Update_Cor_Table);
    h.Cor_Table=handle(Cor_Table);
    
    %%% Correlatse current loaded data
    Cor_Button = uicontrol(...
        'Parent',Cor_Panel,...
        'Tag','Cor_Button',...
        'Units','normalized',...
        'FontSize',14,...
        'FontWeight','bold',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Correlate',...
        'Callback',@Correlate,...
        'Position',[0.005 0.01 0.16 0.09],...
        'TooltipString',sprintf('Correlates loaded data for selected PIE channel pairs;'));
    h.Cor_Button=handle(Cor_Button);
    
    %%% Correlates multiple data sets
    Cor_Multi_Button = uicontrol(...
        'Parent',Cor_Panel,...
        'Tag','Cor_Multi_Button',...
        'Units','normalized',...
        'FontSize',14,...
        'FontWeight','bold',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Multi-Cor',...
        'Callback',@Correlate,...
        'Position',[0.17 0.01 0.16 0.09],...
        'TooltipString',sprintf('Load multiple files and individually correlates them'));
    h.Cor_Multi_Button=handle(Cor_Multi_Button);   
    
    %%% Determines data format
    h.Cor_Format = uicontrol(...
        'Parent',Cor_Panel,...
        'Tag','Cor_Format',...
        'Units','normalized',...
        'FontSize',10,...
        'FontWeight','bold',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String',{'Matlab file (.mcor)';'Text file (.cor)'; 'both'},... 
        'Position',[0.34 0 0.22 0.09],...
        'Style','popupmenu',...
        'TooltipString',sprintf('Select fileformat for saving correlation files'));
    %% Burst tab
    Burst_Tab = uitab(...
        'Parent',Var_Tab,...
        'Tag','Burst_Tab',...
        'Title','Burst Analysis');
    h.Burst_Tab = handle(Burst_Tab);
    
    %%% Burst panel
    Burst_Panel = uibuttongroup(...
        'Parent',Burst_Tab,...
        'Tag','Burst_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
   h.Burst_Panel=handle(Burst_Panel);
   
   %%% Axes for preview of Burst Selection
   Burst_Axes = axes(...
       'Parent',Burst_Panel,...
       'Tag','Burst_Axes',...
       'Position',[0.07 0.12 0.92 0.4],...
       'Units','normalized',...
       'NextPlot','add',...
       'XColor',Look.Fore,...
       'YColor',Look.Fore,...
       'Box','on');
   
    h.Burst_Axes=handle(Burst_Axes);
    h.Burst_Axes.XLabel.String='Time [ms]';
    h.Burst_Axes.XLabel.Color=Look.Fore;
    h.Burst_Axes.YLabel.String='Counts per Timebin';
    h.Burst_Axes.YLabel.Color=Look.Fore;
    h.Burst_Axes.XLim=[0 1];
   
    %%% Button to start Burst Analysis
    Burst_Button = uicontrol(...
        'Parent',Burst_Panel,...
        'Tag','Burst_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Do Burst Search',...
        'Callback',@BurstAnalysis,...
        'Position',[0.75 0.92 0.24 0.07],...
        'TooltipString',sprintf('Start Burst Analysis'));
    h.Burst_Button=handle(Burst_Button);
    
     %%% Button to start burstwise Lifetime Fitting
    BurstLifetime_Button = uicontrol(...
        'Parent',Burst_Panel,...
        'Tag','BurstLifetime_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Burstwise Lifetime',...
        'Callback',@BurstLifetime,...
        'Position',[0.75 0.84 0.24 0.07],...
        'TooltipString',sprintf('Perform burstwise Lifetime Fit'));
    h.BurstLifetime_Button=handle(BurstLifetime_Button);
    
    %%% Button to caluclate 2CDE filter
    NirFilter_Button = uicontrol(...
        'Parent',Burst_Panel,...
        'Tag','NirFilter_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','2CDE',...
        'Callback',@NirFilter,...
        'Position',[0.75 0.76 0.08 0.07],...
        'TooltipString',sprintf('Calculate 2CDE Filter'));
    h.NirFilter_Button=handle(NirFilter_Button);
    
    %%%Edit to change the time constant for the filter
    NirFilter_Edit = uicontrol(...
        'Style','edit',...
        'Parent',Burst_Panel,...
        'Tag','NirFilter_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','100',...
        'Callback',[],...
        'Position',[0.84 0.76 0.05 0.07],...
        'TooltipString',sprintf('Specify the Time Constant for Filter Calculation'));
    h.NirFilter_Edit=handle(NirFilter_Edit);
    
    %%%text label to specify the unit of the edit values (mu s)
    NirFilter_Text = uicontrol(...
        'Style','push',...
        'enable','inactive',...
        'Parent',Burst_Panel,...
        'Tag','NirFilter_Text',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','<HTML> &mu s</HTML>',...
        'Callback',[],...
        'Position',[0.891 0.76 0.05 0.07],...
        'TooltipString',sprintf('Specify the Time Constant for Filter Calculation'));
    h.NirFilter_Text=handle(NirFilter_Text);
    
    %%%Table for PIE channel assignment
    BurstPIE_Table = uitable(...
        'Parent',Burst_Panel,...
        'Units','normalized',...
        'Tag','BurstPIE_Table',...
        'FontSize',12,...
        'Position',[0 0.6 0.27 0.4],...
        'CellEditCallback',@BurstSearchParameterUpdate,...
        'RowStriping','on');
    h.BurstPIE_Table=handle(BurstPIE_Table);
    
    %%% store the information for the BurstPIE_Table in the handles
    %%% structure
    %%% Labels for 2C-noMFD All-Photon Burst Search
    h.BurstPIE_Table_Content.APBS_twocolornoMFD.RowName = {'GG','GR','RR'};
    h.BurstPIE_Table_Content.APBS_twocolornoMFD.ColumnName = {'PIE Channel'};
    %%% Labels for 2C-MFD All-Photon Burst Search
    h.BurstPIE_Table_Content.APBS_twocolorMFD.RowName = {'GG','GR','RR'};
    h.BurstPIE_Table_Content.APBS_twocolorMFD.ColumnName = {'Parallel','Perpendicular'};
    %%% Labels for 2C-MFD Dual-Channel Burst Search
    h.BurstPIE_Table_Content.DCBS_twocolorMFD.RowName = {'GG','GR','RR'};
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
    PhotonstreamConvert_Button = uicontrol(...
        'Parent',Burst_Panel,...
        'Tag','PhotonstreamConvert_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Convert Photonstream',...
        'Callback',@PhotonstreamConvert,...
        'Position',[0.75 0.68 0.24 0.07],...
        'TooltipString',sprintf('Convert Photonstream to channels based on PIE channel selection'));
    h.PhotonstreamConvert_Button=handle(PhotonstreamConvert_Button);
    
    %%% Button to show a preview of the burst search
    BurstSearchPreview_Button = uicontrol(...
        'Parent',Burst_Panel,...
        'Tag','BurstSearchPreview_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','Preview',...
        'Callback',@BurstSearchPreview,...
        'Position',[0.88 0 0.12 0.05],...
        'TooltipString',sprintf('Update the preview display.'));
    h.BurstSearchPreview_Button=handle(BurstSearchPreview_Button);
    
    %%%Buttons to shift the preview by one second forwards or backwards
    BurstSearchPreview_Forward_Button = uicontrol(...
        'Parent',Burst_Panel,...
        'Tag','BurstSearchPreview_Forward_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','>',...
        'Callback',@BurstSearchPreviewShift,...
        'Position',[0.85 0 0.029 0.05],...
        'TooltipString',sprintf(''));
    h.BurstSearchPreview_Forward_Button=handle(BurstSearchPreview_Forward_Button);
    
    BurstSearchPreview_Backward_Button = uicontrol(...
        'Parent',Burst_Panel,...
        'Tag','BurstSearchPreview_Backward_Button',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','<',...
        'Callback',@BurstSearchPreviewShift,...
        'Position',[0.82 0 0.029 0.05],...
        'TooltipString',sprintf(''));
    h.BurstSearchPreview_Backward_Button=handle(BurstSearchPreview_Backward_Button);
    
    %%%Popup Menu for Selection of Burst Search
    BurstSearchSelection_Popupmenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',Burst_Panel,...
        'Tag','BurstSearchSelection_Popupmenu',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Fore,...
        'ForegroundColor', Look.Back,...
        'String',{'APBS 2C-MFD','DCBS 2C-MFD','APBS 3C-MFD','TCBS 3C-MFD','APBS 2C-noMFD'},...
        'Callback',@Update_BurstGUI,...
        'Position',[0.28 0.9 0.30 0.09],...
        'TooltipString',sprintf(''));
    h.BurstSearchSelection_Popupmenu=handle(BurstSearchSelection_Popupmenu);
    
    %%% Edit Box for Parameter1 (Number of Photons Threshold)
    BurstParameter1_Edit = uicontrol(...
        'Style','edit',...
        'Parent',Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','100',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.63 0.85 0.07 0.05],...
        'TooltipString',sprintf(''));
    h.BurstParameter1_Edit=handle(BurstParameter1_Edit);
    
    %%% Text Box for Parameter1 (Number of Photons Threshold)
    BurstParameter1_Text = uicontrol(...
        'Style','text',...
        'Parent',Burst_Panel,...
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
    h.BurstParameter1_Text=handle(BurstParameter1_Text);
    
    %%% Edit Box for Parameter2 (Time Window)
    BurstParameter2_Edit = uicontrol(...
        'Style','edit',...
        'Parent',Burst_Panel,...
        'Tag','BurstParameter2_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','500',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.63 0.79 0.07 0.05],...
        'TooltipString',sprintf(''));
    h.BurstParameter2_Edit=handle(BurstParameter2_Edit);
    
    %%% Text Box for Parameter2 (Number of Photons Threshold)
    BurstParameter2_Text = uicontrol(...
        'Style','text',...
        'Parent',Burst_Panel,...
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
    h.BurstParameter2_Text=handle(BurstParameter2_Text);
    
    %%% Edit Box for Parameter3 (Photons per Time Window Threshold 1)
    BurstParameter3_Edit = uicontrol(...
        'Style','edit',...
        'Parent',Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','5',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.63 0.73 0.07 0.05],...
        'TooltipString',sprintf(''));
    h.BurstParameter3_Edit=handle(BurstParameter3_Edit);
    
    %%% Text Box for Parameter3 (Photons per Time Window Threshold 1)
    BurstParameter3_Text = uicontrol(...
        'Style','text',...
        'Parent',Burst_Panel,...
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
    h.BurstParameter3_Text=handle(BurstParameter3_Text);
    
    %%% Edit Box for Parameter4 (Photons per Time Window Threshold 2)
    BurstParameter4_Edit = uicontrol(...
        'Style','edit',...
        'Parent',Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','5',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.63 0.67 0.07 0.05],...
        'TooltipString',sprintf(''));
    h.BurstParameter4_Edit=handle(BurstParameter4_Edit);
    
    %%% Text Box for Parameter4 (Photons per Time Window Threshold 2)
    BurstParameter4_Text = uicontrol(...
        'Style','text',...
        'Parent',Burst_Panel,...
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
    h.BurstParameter4_Text=handle(BurstParameter4_Text);
    
    %%% Edit Box for Parameter5 (Photons per Time Window Threshold 3)
    BurstParameter5_Edit = uicontrol(...
        'Style','edit',...
        'Parent',Burst_Panel,...
        'Tag','BurstParameter1_Edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','5',...
        'Callback',@BurstSearchParameterUpdate,...
        'Position',[0.63 0.61 0.07 0.05],...
        'TooltipString',sprintf(''));
    h.BurstParameter5_Edit=handle(BurstParameter5_Edit);
    
    %%% Text Box for Parameter5 (Photons per Time Window Threshold 3)
    BurstParameter5_Text = uicontrol(...
        'Style','text',...
        'Parent',Burst_Panel,...
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
    h.BurstParameter5_Text=handle(BurstParameter5_Text);
    %% Profiles tab
    Profiles_Tab= uitab(...
        'Parent',Var_Tab,...
        'Tag','Profiles_Tab',...
        'Title','Profiles');
    h.Profiles_Tab=handle(Profiles_Tab);
    
    %%% Profiles panel
    Profiles_Panel = uibuttongroup(...
        'Parent',Profiles_Tab,...
        'Tag','Profiles_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    h.Profiles_Panel=handle(Profiles_Panel);
    
    %%% Contexmenu for Profiles list
    Profiles_Menu = uicontextmenu;
    h.Profiles_Menu=handle(Profiles_Menu);
    %%% Adds new Profile
    Profiles_Add = uimenu(...
        'Parent',Profiles_Menu,...
        'Label','Add new profile',...
        'Tag','Profiles_Add',...
        'Callback',@Update_Profiles);
    h.Profiles_Add=handle(Profiles_Add);
    %%% Deletes selected profile
    Profiles_Delete = uimenu(...
        'Parent',Profiles_Menu,...
        'Label','Delete selected profile',...
        'Tag','Profiles_Delete',...
        'Callback',@Update_Profiles);
    h.Profiles_Delete=handle(Profiles_Delete);
    %%% Selects profile
    Profiles_Select = uimenu(...
        'Parent',Profiles_Menu,...
        'Label','Select profile',...
        'Tag','Profiles_Delete',...
        'Callback',@Update_Profiles);
    h.Profiles_Select=handle(Profiles_Select);   
    
    %%% Profiles list
    Profiles_List = uicontrol(...
        'Parent',Profiles_Panel,...
        'Tag','Profiles_List',...
        'Style','listbox',...
        'Units','normalized',...
        'FontSize',14,...
        'String',Profiles,...
        'Uicontextmenu',Profiles_Menu,...
        'TooltipString',sprintf([...
            'List of available profiles: \n'...
            '"+" adds profile; \n'...
            '"-" or "del" deletes channel; \n'...
            '"return" changes current profile; \n'...
            'TSCPCData will not be updated; \n'...
            'To update all settings, a restart of Pam migth be required']),...
        'KeyPressFcn',@Update_Profiles,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.01 0.01 0.4 0.98]);
    h.Profiles_List=handle(Profiles_List);
        
    %%% Description of profile
    Profiles_Description = uicontrol(...
        'Parent',Profiles_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'String','',...
        'Max',2,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.415 0.01 0.575 0.98]);
    h.Profiles_Description=handle(Profiles_Description);
        
%% Global variable initialization  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FileInfo=[];
FileInfo.MI_Bins=4096;
FileInfo.NumberOfFiles=1;
FileInfo.Type=1;
FileInfo.ImageTime=1;
FileInfo.RepRate=1;
FileInfo.Lines=1;
FileInfo.Pixels=1;
FileInfo.FileName={'Nothing loaded'};

PamMeta=[];
PamMeta.MI_Hist=repmat({zeros(4096,1)},numel(UserValues.Detector.Use),1);
PamMeta.Trace=repmat({0:0.01:(FileInfo.NumberOfFiles*FileInfo.ImageTime)},numel(UserValues.PIE.Name),1);
PamMeta.Image=repmat({0},numel(UserValues.PIE.Name),1);
PamMeta.Lifetime=repmat({0},numel(UserValues.PIE.Name),1);
PamMeta.TimeBins=0:0.01:(FileInfo.NumberOfFiles*FileInfo.ImageTime);
PamMeta.Info=repmat({zeros(4,1)},numel(UserValues.PIE.Name),1);
PamMeta.MI_Tabs=[];
PamMeta.Applied_Shift=cell(1);
PamMeta.Det_Calib=[];

TcspcData=[];
TcspcData.MI=cell(1);
TcspcData.MT=cell(1);

guidata(Figure,h);  

%% Initializes to UserValues
Update_to_UserValues;

else % If a Pam figure exists already    
    figure(h.Pam); % Gives focus to Pam figure    
end 
h.Pam.Visible='on';
%%% Initializes Profiles List
Update_Profiles([],[])
%%% Initializes detector/routing list
Update_Detector_Channels(1);
%%% Initializes plots
Update_Data([],[],0,0);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions that executes upon closing of pam window %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_Pam(~,~)
clear global -regexp PamMeta TcspcData FileInfo
Phasor=findobj('Tag','Phasor');
FCSFit=findobj('Tag','FCSFit');
if isempty(Phasor) && isempty(FCSFit)
    clear global -regexp UserValues
end
delete(gcf);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Updates Pam Meta Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Data(~,~,Detector,PIE)
global TcspcData FileInfo UserValues PamMeta
h = guidata(gcf);

h.Progress_Text.String = 'Updating meta data';
h.Progress_Axes.Color=[1 0 0];
drawnow;
if Detector==0
    Detector = 1:numel(UserValues.Detector.Use);
    PamMeta.MI_Hist=cell(numel(UserValues.Detector.Use),1);
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
        if all(size(TcspcData.MI)>=[UserValues.Detector.Det(i),UserValues.Detector.Rout(i)]) && UserValues.Detector.Use(i) && ~isempty(TcspcData.MI{UserValues.Detector.Det(i),UserValues.Detector.Rout(i)})
            PamMeta.MI_Hist{i}=histc(TcspcData.MI{UserValues.Detector.Det(i),UserValues.Detector.Rout(i)},0:(FileInfo.MI_Bins-1));
        else
            PamMeta.MI_Hist{i}=zeros(FileInfo.MI_Bins,1);
        end
    end
end
%% Creates trace and image plots

%%% Creates macrotime bins for traces (currently fixed 10ms)
PamMeta.TimeBins=0:str2double(h.MT_Binning.String)/1000:(FileInfo.NumberOfFiles*FileInfo.ImageTime);
%%% Creates a intensity trace and image for each non-combined PIE channel
if ~isempty(PIE)
    for i=PIE
        Det=UserValues.PIE.Detector(i);
        Rout=UserValues.PIE.Router(i);
        From=UserValues.PIE.From(i);
        To=UserValues.PIE.To(i);
        %%% Checks, if selected detector/routing pair exists/is not empty
        if all(~isempty([Det,Rout])) && all([Det Rout] <= size(TcspcData.MI)) && ~isempty(TcspcData.MT{Det,Rout}) && any(UserValues.Detector.Use(UserValues.Detector.Det==Det & UserValues.Detector.Rout==Rout))
            %% Calculates trace
            %%% Takes PIE channel macrotimes
            PIE_MT=TcspcData.MT{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To)*FileInfo.RepRate;
            %%% Calculate intensity trace for PIE channel (currently with 10ms bins)
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
                PamMeta.Image{i}=histc(PIE_MT,Pixeltimes*FileInfo.RepRate);  
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
                PamMeta.Lifetime{i}=PIE_MI(Image_Sum(2:(FileInfo.Pixels+1)))-PIE_MI(Image_Sum(1:FileInfo.Pixels));
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
            PamMeta.Info{i}(2,1)=sum(PamMeta.Trace{i});
            clear Image_Sum;
            PamMeta.Info{i}(3,1)=PamMeta.Info{i}(1)/(FileInfo.NumberOfFiles*FileInfo.ImageTime)/1000;
            PamMeta.Info{i}(4,1)=PamMeta.Info{i}(2)/(FileInfo.NumberOfFiles*FileInfo.ImageTime)/1000;
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

%% Updates display
Update_Display([],[],0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Determines settings for various things %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Calculate_Settings(obj,~)
global UserValues
h = guidata(gcf);
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
end
%%% Saves UserValues
LSUserValues(1);
%%% Updates pam meta data, if Update_Data was not called
if Display
    Update_Data([],[],0,0)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Updates Pam plots  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Display(~,~,mode)
global UserValues PamMeta FileInfo
h = guidata(gcf);

%%% Determines which parts are updated
%%% 1: PIE list and PIE info
%%% 2: Trace plot and sections
%%% 3: Image plot
%%% 4: Microtime histograms and PIE patches
%%% 5: Only PIE patches
%%% 6: Phasor Plot
if nargin<3 || any(mode==0)
    mode=[1:4, 6];
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
            for j=1:numel(h.Plots.PIE_Patches{i})
                if ishandle(h.Plots.PIE_Patches{i}{j})
                h.Plots.PIE_Patches{i}{j}.YData=[1 0 0 1];
                end
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
    for i=1:numel(PamMeta.MI_Hist)
        %%% Checks, if lineseries already exists
        if ~isempty(h.Plots.MI_All{i})
            %%% Only changes YData of plot to increase speed
            h.Plots.MI_All{i}.YData=PamMeta.MI_Hist{i};
        else
            %%% Plots new lineseries, if none exists
            h.Plots.MI_All{i}=handle(plot(PamMeta.MI_Hist{i}));
        end
        %%% Sets color of lineseries
        h.Plots.MI_All{i}.Color=UserValues.Detector.Color(i,:);
    end
end

%% Individual microtime plots update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==4)
    for i=1:size(h.MI_Tab,1)
        %%% Checks, if lineseries already exists
        if ~isempty(h.MI_Tab{i,4})
            %%% Only changes YData of plot to increase speed
            h.MI_Tab{i,4}.YData=PamMeta.MI_Hist{i};
        else
            %%% Plots new lineseries, if none exists
            h.MI_Tab{i,4}=handle(plot(h.MI_Tab{i,3},PamMeta.MI_Hist{i}));
        end
        %%% Sets color of lineseries
        h.MI_Tab{i,4}.Color=UserValues.Detector.Color(i,:);
    end
end

%% Phasor microtime plot update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==6)
    From=str2double(h.MI_Phasor_From.String);
    To=str2double(h.MI_Phasor_To.String);
    Shift=str2double(h.MI_Phasor_Shift.String);
    Det=h.MI_Phasor_Det.Value;
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

%% Detector Calibration plot update
if any(mode==7)
    if isfield(PamMeta.Det_Calib,'Hist') && ~isempty(PamMeta.Det_Calib.Shift)
        h.Plots.Calib_No.YData=sum(PamMeta.Det_Calib.Hist,2)/max(smooth(sum(PamMeta.Det_Calib.Hist,2),5));
        h.Plots.Calib_No.XData=1:FileInfo.MI_Bins;
        Cor_Hist=zeros(size(PamMeta.Det_Calib.Hist));
        for i=1:400
            Cor_Hist(:,i)=circshift(PamMeta.Det_Calib.Hist(:,i),[-PamMeta.Det_Calib.Shift(i),0]);
        end
        h.Plots.Calib.YData=sum(Cor_Hist,2)/max(smooth(sum(Cor_Hist,2),5));
        h.Plots.Calib.XData=1:FileInfo.MI_Bins;
        
        
        h.MI_Calib_Single.Value=round(h.MI_Calib_Single.Value);  
        MIN=max([1 h.MI_Calib_Single.Value]);
        MAX=min([400, MIN+str2double(h.MI_Calib_Single_Range.String)-1]);
        h.MI_Calib_Single_Text.String=num2str(MIN);
                
        h.Plots.Calib_Sel.YData=sum(Cor_Hist(:,MIN:MAX),2)/max(smooth(sum(Cor_Hist(:,MIN:MAX),2),5));
        h.Plots.Calib_Sel.XData=1:FileInfo.MI_Bins;
        
    end
    Det=UserValues.Detector.Det(h.MI_Calib_Det.Value);
    Rout=UserValues.Detector.Rout(h.MI_Calib_Det.Value);
    if all(size(PamMeta.Applied_Shift)>=[Det,Rout]) && ~isempty(PamMeta.Applied_Shift{Det,Rout})
        h.Plots.Calib_Shift_Applied.YData=PamMeta.Applied_Shift{Det,Rout};
    else
        h.Plots.Calib_Shift_Applied.YData=zeros(1,400);
    end 
end

%% PIE Patches %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==4) || any(mode==5)
    %%% Creates empty entry for PIE patch
    if ~isfield(h.Plots,'PIE_Patches') || numel(h.Plots.PIE_Patches)<numel(UserValues.PIE.Detector)
        h.Plots.PIE_Patches{numel(UserValues.PIE.Detector)}=[];
    end
    for i=1:numel(List)
        %%% Reads in PIE setting to save typing
        From=UserValues.PIE.From(i);
        To=UserValues.PIE.To(i);
        Det=UserValues.PIE.Detector(i);
        Rout=UserValues.PIE.Router(i);
        %%% Reduces color saturation
        Color=(UserValues.PIE.Color(i,:)+3*UserValues.Look.Axes)/4;
        %%% Finds detector channels containing PIE channel
        Channel1=find(UserValues.Detector.Det==Det);
        Channel2=find(UserValues.Detector.Rout==Rout);
        Channel=intersect(Channel1,Channel2);
        %%% If a valid detector channel was found
        if ~isempty(Channel)
            %%% Only uses active detector channels
            Channel=Channel((Channel.*UserValues.Detector.Use(Channel))>0);
            %%% Creates new Patches if none exist
            if isempty(h.Plots.PIE_Patches{i})
                k=1;
                for j=Channel
                    YData=h.MI_Tab{j,3}.YLim;
                    h.Plots.PIE_Patches{i}{k}=handle(patch([From From To To],[YData(2) YData(1) YData(1) YData(2)],Color,'Parent',h.MI_Tab{j,3}));
                    h.Plots.PIE_Patches{i}{k}.HitTest='off';
                    uistack(h.Plots.PIE_Patches{i}{k},'bottom');
                    k=k+1;
                end
                %%% Deletes surplus patches and resets old ones
            elseif numel(h.Plots.PIE_Patches{i})>numel(Channel)
                %%% Delete surplus
                for j=numel(Channel)+1:numel(h.Plots.PIE_Patches{i})
                    delete(h.Plots.PIE_Patches{i}{j});
                end
                h.Plots.PIE_Patches{i}(numel(Channel)+1:end)=[];
                %%% Resets used patches
                k=1;
                for j=Channel
                    YData=h.MI_Tab{j,3}.YLim;
                    h.Plots.PIE_Patches{i}{k}.XData=[From From To To];
                    h.Plots.PIE_Patches{i}{k}.YData=[YData(2) YData(1) YData(1) YData(2)];
                    h.Plots.PIE_Patches{i}{k}.Parent=h.MI_Tab{j,3};
                    uistack(h.Plots.PIE_Patches{i}{k},'bottom');
                    k=k+1;
                end
                %%% Resets old patches and creates additional ones
            elseif numel(h.Plots.PIE_Patches{i})<numel(Channel)
                %%% Resets used patches
                for j=1:numel(h.Plots.PIE_Patches{i})
                    YData=h.MI_Tab{Channel(j),3}.YLim;
                    h.Plots.PIE_Patches{i}{k}.XData=[From From To To];
                    h.Plots.PIE_Patches{i}{j}.YData=[YData(2) YData(1) YData(1) YData(2)];
                    h.Plots.PIE_Patches{i}{j}.Parent=h.MI_Tab{Channel(j),3};
                    uistack(h.Plots.PIE_Patches{i}{j},'bottom');
                end
                %%% Creates additional patches
                for k=(j+1):numel(Channel)
                    YData=h.MI_Tab{Channel(k),3}.YLim;
                    h.Plots.PIE_Patches{i}{k}=handle(patch([From From To To],[YData(2) YData(1) YData(1) YData(2)],Color,'Parent',h.MI_Tab{j,3}));
                    h.Plots.PIE_Patches{i}{k}.HitTest='off';
                    uistack(h.Plots.PIE_Patches{i}{k},'bottom');
                end
                %%% Resets old patches
            elseif numel(h.Plots.PIE_Patches{i})==numel(Channel)
                k=1;
                for j=Channel
                    YData=h.MI_Tab{j,3}.YLim;
                    h.Plots.PIE_Patches{i}{k}.XData=[From From To To];
                    h.Plots.PIE_Patches{i}{k}.YData=[YData(2) YData(1) YData(1) YData(2)];
                    h.Plots.PIE_Patches{i}{k}.Parent=h.MI_Tab{j,3};
                    uistack(h.Plots.PIE_Patches{i}{k},'bottom');
                    k=k+1;
                end
            end
            %%% Deletes all patches for PIE channel if no valid detector channel exists
        else
            for j=1:numel(h.Plots.PIE_Patches{i})
                delete(h.Plots.PIE_Patches{i}{j})
            end
            h.Plots.PIE_Patches{i}=[];
        end
    end
    %%% Moves patches of selected PIE channel to tip, but below histogramm
    %%% Don't konow why I have to move it down by 3
    for i=1:numel(h.Plots.PIE_Patches{Sel})
        uistack(h.Plots.PIE_Patches{Sel}{i},'top');
        uistack(h.Plots.PIE_Patches{Sel}{i},'down',3);
    end
end

%% Trace sections %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(mode==2)
    %%% Calculates the borders of the trace patches
    if h.MT_Trace_Sectioning.Value==1
        PamMeta.MT_Patch_Times=linspace(0,FileInfo.ImageTime*FileInfo.NumberOfFiles,UserValues.Settings.Pam.MT_Number_Section+1);
    else
        PamMeta.MT_Patch_Times=0:UserValues.Settings.Pam.MT_Time_Section:(FileInfo.ImageTime*FileInfo.NumberOfFiles);
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
guidata(gcf,h)
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
global UserValues TcspcData FileInfo PamMeta
h = guidata(gcf);

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
        %%% Updates Pam meta data; input 3 should be empty to improve speed
        %%% Input 4 is the new channel
        Update_to_UserValues
        Update_Data([],[],[],numel(UserValues.PIE.Name))
        %%% Updates correlation table
        Update_Cor_Table(obj);
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
        Update_Display([],[],[1,2,3])
        %%% Updates correlation table
        Update_Cor_Table(obj);
    case 'c' 
        %% Changes color of selected channels
        %%% Opens menu to choose color
        color=uisetcolor;
        %%% Checks, if color was selected
        if numel(color)==3
            for i=Sel
            UserValues.PIE.Color(i,:)=color;
            end
        end
        %%% Updates Plots
        Update_Display
    case 'leftarrow'
        %% Moves first selected channel up    
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
        end  
    case 'rightarrow'
        %% Moves first selected channel down 
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
        end
    case 'Export_Raw_Total'
        %% Exports macrotime and microtime as one vector for each PIE channel
        h.Progress_Text.String = 'Exporting';
        h.Progress_Axes.Color=[1 0 0];
        drawnow;
        for i=Sel
            Det=UserValues.PIE.Detector(i);
            Rout=UserValues.PIE.Router(i);
            From=UserValues.PIE.From(i);
            To=UserValues.PIE.To(i); 
            if all (size(TcspcData.MI) >= [Det Rout])
                MI=TcspcData.MI{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To);
                assignin('base',[UserValues.PIE.Name{i} '_MI'],MI); clear MI;
                MT=TcspcData.MT{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To);
                assignin('base',[UserValues.PIE.Name{i} '_MT'],MT); clear MT;          
            end
        end
    case 'Export_Raw_File'        
        %% Exports macrotime and microtime as a cell for each PIE channel
        h.Progress_Text.String = 'Exporting';
        h.Progress_Axes.Color=[1 0 0];
        drawnow;
        for i=Sel
            Det=UserValues.PIE.Detector(i);
            Rout=UserValues.PIE.Router(i);
            From=UserValues.PIE.From(i);
            To=UserValues.PIE.To(i);
            
            if all (size(TcspcData.MI) >= [Det Rout])                
                MI=cell(FileInfo.NumberOfFiles,1);
                MT=cell(FileInfo.NumberOfFiles,1);                
                MI{1}=TcspcData.MI{Det,Rout}(1:FileInfo.LastPhoton{Det,Rout,1});
                MI{1}=MI{1}(MI{1}>=From & MI{1}<=To);
                MT{1}=TcspcData.MT{Det,Rout}(1:FileInfo.LastPhoton{Det,Rout,1});
                MT{1}=MT{1}(MI{1}>=From & MI{1}<=To);
                if FileInfo.NumberOfFiles>1
                    for j=2:(FileInfo.NumberOfFiles)
                        MI{j}=TcspcData.MI{Det,Rout}(FileInfo.LastPhoton{Det,Rout,j-1}:FileInfo.LastPhoton{Det,Rout,j});
                        MI{j}=MI{j}(MI{j}>=From & MI{j}<=To);
                        MT{j}=TcspcData.MT{Det,Rout}(FileInfo.LastPhoton{Det,Rout,j-1}:FileInfo.LastPhoton{Det,Rout,j});
                        MT{j}=MT{j}(MI{j}>=From & MI{j}<=To)-(j-1)*round(FileInfo.ImageTime/FileInfo.RepRate);
                    end
                end
                assignin('base',[UserValues.PIE.Name{i} '_MI'],MI); clear MI;
                assignin('base',[UserValues.PIE.Name{i} '_MT'],MT); clear MT;          
            end

        end 
    case 'Export_Image_Total'
        %% Plots image and exports it into workspace
        h.Progress_Text.String = 'Exporting';
        h.Progress_Axes.Color=[1 0 0];
        drawnow;
        for i=Sel
            %%% Exports intensity image
            if h.MT_Image_Export.Value == 1 || h.MT_Image_Export.Value == 2
                assignin('base',[UserValues.PIE.Name{i} '_Image'],PamMeta.Image{i});
                figure('Name',[UserValues.PIE.Name{i} '_Image']);
                imagesc(PamMeta.Image{i});
            end
            %%% Exports mean arrival time image
            if h.MT_Image_Export.Value == 1 || h.MT_Image_Export.Value == 3
                assignin('base',[UserValues.PIE.Name{i} '_LT'],PamMeta.Lifetime{i});
                figure('Name',[UserValues.PIE.Name{i} '_LT']);
                imagesc(PamMeta.Lifetime{i});
            end
        end
        %%% gives focus back to Pam
        figure(h.Pam);
    case 'Export_Image_File'
        %% Exports image stack into workspace
        h.Progress_Text.String = 'Exporting';
        h.Progress_Axes.Color=[1 0 0];
        drawnow;
        for i=Sel
            %%% Gets the photons
            Stack=TcspcData.MT{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}(...
                TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}>=UserValues.PIE.From(i) &...
                TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}<=UserValues.PIE.To(i)); 
            
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
            assignin('base',[UserValues.PIE.Name{i} '_Images'],Stack);            
        end
    case 'Export_Image_Tiff'
        %% Exports image stack into workspace
        Path=uigetdir(UserValues.File.ExportPath,'Select folder to save TIFFs');
        if all(Path~=0)
            h.Progress_Text.String = 'Exporting';
            h.Progress_Axes.Color=[1 0 0];
            drawnow;
            UserValues.File.ExportPath=Path;
            LSUserValues(1);
            for i=Sel
                %%% Gets the photons
                Stack=TcspcData.MT{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}(...
                    TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}>=UserValues.PIE.From(i) &...
                    TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}<=UserValues.PIE.To(i));
                
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
                imwrite(Stack(:,:,1),File,'tif','Compression','lzw');
                for j=2:size(Stack,3)
                    imwrite(Stack(:,:,j),File,'tif','WriteMode','append','Compression','lzw');
                end
            end
            Progress((i-1)/numel(Sel),h.Progress_Axes,h.Progress_Text,'Exporting:')
        end
    case 'Combine'
        %% Generates a combined PIE channel from existing PIE channels
        %%% Does not combine single
        if numel(Sel)>1 && isempty(cell2mat(UserValues.PIE.Combined(Sel)))
            
            UserValues.PIE.Color(end+1,:)=[0 0 1];
            UserValues.PIE.Combined{end+1}=Sel;
            UserValues.PIE.Detector(end+1)=0;
            UserValues.PIE.Router(end+1)=0;
            UserValues.PIE.From(end+1)=0;
            UserValues.PIE.To(end+1)=0;            
            UserValues.PIE.Name{end+1}='Comb.: ';
            for i=Sel;
                UserValues.PIE.Name{end}=[UserValues.PIE.Name{end} UserValues.PIE.Name{i} '+'];
            end
            UserValues.PIE.Name{end}(end)=[];
            UserValues.PIE.Duty_Cycle(end+1)=0;
            Update_Data([],[],[],[])
            %%% Updates correlation table
            Update_Cor_Table(obj);
        end        
    otherwise
        e.Key='';
end
h.Progress_Text.String = FileInfo.FileName{1};
h.Progress_Axes.Color=UserValues.Look.Control;
%% Only saves user values, if one of the function was used
if ~isempty(e.Key)
    LSUserValues(1);    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes PIE channel settings and saves them in the profile %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_PIE_Channels(obj,~)
global UserValues
h = guidata(gcf);

Sel=h.PIE_List.Value(1);
if numel(Sel)==1 && isempty(UserValues.PIE.Combined{Sel})
    %%% Updates PIE Channel name
    if obj == h.PIE_Name
        UserValues.PIE.Name{Sel}=h.PIE_Name.String;
        %%% Updates correlation table
        Update_Cor_Table(obj);
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
    %%% Only updates plots, if just the name was changed
    else
        Update_Display([],[],[1,2,3,5]);
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Callback functions of Microtime plots and UIContextmenues  %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MI_Axes_Menu(obj,~)
h = guidata(gcf);
if obj == h.MI_Log
    if strcmp(h.MI_Log.Checked,'off')
        h.MI_All_Axes.YScale='Log';
        for i=1:size(h.MI_Tab,1)
            h.MI_Tab{i,3}.YScale='Log';
        end
        h.MI_Phasor_Axes.YScale='Log';
        h.MI_Calib_Axes.YScale='Log';
        h.MI_Log.Checked='on';
    else
        h.MI_All_Axes.YScale='Linear';
        for i=1:size(h.MI_Tab,1)
            h.MI_Tab{i,3}.YScale='Linear';
        end
        h.MI_Phasor_Axes.YScale='Linear';
        h.MI_Calib_Axes.YScale='Linear';
        h.MI_Log.Checked='off';
    end
end
Update_Display([],[],5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Selects/Unselects macrotime sections  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MT_Section(obj,~)
global PamMeta
h = guidata(gcf);

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
%%% "leftarrow"-Key or disable channel: disable channels but keep them
%%% 'rigtharrow'-Key or enable channel: enable channels
function MI_Channels_Functions(obj,ed)
global UserValues PamMeta
h = guidata(gcf);
%% Determines which buttons was pressed, if function was not called via key press 
if ~strcmp(ed.EventName,'KeyPress')
    if obj == h.MI_Add
        e.Key='add';
    elseif obj == h.MI_Delete
        e.Key='delete';
    elseif obj == h.MI_Color;
        e.Key='c';
    elseif obj == h.MI_Disable;
        e.Key='leftarrow';
    elseif obj == h.MI_Enable;
        e.Key='rightarrow';
    else
        e.Key='';
    end
else
    e.Key=ed.Key;
end
Sel=h.MI_Channels_List.Value;

%% Determines which Key/Button was pressed
switch e.Key
    case 'add'
        %% Created a new microtime channel as specified in input dialog
        Input=inputdlg({'Enter detector:'; 'Enter routing:'; 'Enabled?'; 'Enter RGB color'},'Create new detector/routing pair',1,{'1'; '1'; '1';'1 1 1'});
        if ~isempty(Input)
            UserValues.Detector.Det(end+1)=str2double(Input{1});
            UserValues.Detector.Rout(end+1)=str2double(Input{2});
            UserValues.Detector.Use(end+1)=str2double(Input{3});
            UserValues.Detector.Color(end+1,:)=str2num(Input{4});  
            UserValues.Detector.Shift{end+1}=zeros(400,1);
            %%% Updates microtime channels list
            Update_Detector_Channels(2);
            %%% Finds all PIE channels that use the new detector   
            PIE1=find(UserValues.PIE.Detector==UserValues.Detector.Det(end));
            %%% Finds all PIE channels that use the new routing            
            PIE2=find(UserValues.PIE.Router==UserValues.Detector.Rout(end));
            %%% Finds all PIE channels that use the new detector/routing pair           
            PIE=intersect(PIE1,PIE2);           
            %%% Updates Pam meta data; input 3 is the new detector/routing pair            
            %%% Input 4 are the PIE channels that use the new detector/routing pair
            Update_Data([],[],numel(UserValues.Detector.Use),PIE);
        end
    case 'delete' 
        %% Deletes all selected microtimechannels        
        %%% Finds all PIE channels that use the delteted detector
        PIE1=find(UserValues.PIE.Detector==UserValues.Detector.Det(Sel));
        %%% Finds all PIE channels that use the deleted routing
        PIE2=find(UserValues.PIE.Router==UserValues.Detector.Rout(Sel));
        %%% Finds all PIE channels that use the deleted detector/routing pair
        PIE=intersect(PIE1,PIE2);               
        UserValues.Detector.Det(Sel)=[];
        UserValues.Detector.Rout(Sel)=[];
        UserValues.Detector.Use(Sel)=[];
        UserValues.Detector.Color(Sel,:)=[];
        UserValues.Detector.Shift(Sel)=[];
        PamMeta.MI_Hist(Sel)=[];
        
        %%% Finds all PIE patches in tab and deletes them
        if ~isempty(PIE)
            for i=PIE
                for j=1:numel(h.Plots.PIE_Patches{i})
                    if h.Plots.PIE_Patches{i}{j}.Parent==findobj(h.MI_Tab{Sel,3},'flat');
                        delete(h.Plots.PIE_Patches{i}{j});
                        h.Plots.PIE_Patches{i}{j}=[];
                        break;
                    end
                end
            end
        end
        
        %%% Deletes tab
        delete(h.MI_Tab{Sel,1});
        h.MI_Tab(Sel,:)=[];
        
        %%% Removes nonexistent selected channels
        h.MI_Channels_List.Value(h.MI_Channels_List.Value>numel(UserValues.Detector.Det))=[];
        %%% Selects first channel, if none is selected
        if isempty(h.MI_Channels_List.Value)
            h.MI_Channels_List.Value=1;
        end
        %%% Saves new tabs in guidata
        guidata(gcf,h)
        
        %%% Updates microtime channels list
        Update_Detector_Channels(2);
        %%% Updates Pam meta data; input 3 is empty
        %%% Input 4 are the PIE channels that use the  deleted detector/routing pair
        Update_Data([],[],[],PIE);        
    case 'c'
        %% Selects new color for microtime channel
        %%% Opens menu to choose color
        color=uisetcolor;
        %%% Checks, if color was selected
        if numel(color)==3
            for i=Sel
                UserValues.Detector.Color(i,:)=color;
            end
        end
        %%% Updates channels
        Update_Detector_Channels(2,[])
        %%% Updates plots
        Update_Display([],[],4);
    case 'leftarrow'
        %% Disables selected channels but keeps them
        UserValues.Detector.Use(Sel)=0;
        %%% Updates microtime channels list
        Update_Detector_Channels(2);        
        %%% Finds all PIE channels that use the unselected detector
        PIE1=find(UserValues.PIE.Detector==UserValues.Detector.Det(Sel));
        %%% Finds all PIE channels that use the unselected routing
        PIE2=find(UserValues.PIE.Router==UserValues.Detector.Rout(Sel));
        %%% Finds all PIE channels that use the unselected detector/routing pair
        PIE=intersect(PIE1,PIE2);
        %%% Updates Pam meta data; input 3 is the unselected detector/routing pair
        %%% Input 4 are the PIE channels that use the unselected detector/routing pair
        Update_Data([],[],Sel,PIE);
    case 'rightarrow'
        %% Esables selected channels again
        UserValues.Detector.Use(Sel)=1;
        %%% Updates microtime channels list
        Update_Detector_Channels(2);
        %%% Finds all PIE channels that use the selected detector
        PIE1=find(UserValues.PIE.Detector==UserValues.Detector.Det(Sel));
        %%% Finds all PIE channels that use the selected routing
        PIE2=find(UserValues.PIE.Router==UserValues.Detector.Rout(Sel));
        %%% Finds all PIE channels that use the selected detector/routing pair
        PIE=intersect(PIE1,PIE2);
        %%% Updates Pam meta data; input 3 is the selected detector/routing pair
        %%% Input 4 are the PIE channels that use the selected detector/routing pair
        Update_Data([],[],Sel,PIE);
    otherwise
        e.Key='';
end
%% Updates, if one of the function was used
if ~isempty(e.Key)
    LSUserValues(1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for updating microtime channels list  %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Detector_Channels(mode,~)
global UserValues
h = guidata(gcf);
List=cell(numel(UserValues.Detector.Use),1);

%%% Adjusts MI_Tabs cell to right size
if ~isfield(h,'MI_Tab') || (size(h.MI_Tab,1)<numel(List))
    h.MI_Tab{numel(List),4}=[];
end
%%% Need to do this, because matlab is stupid
drawnow;

%%% Finds handle value of MI_Tabs, because Matlab cannot use handle objects as parent
MI_Tabs=findobj('Tag','MI_Tabs');
Dummy_Tabgroup=findobj('Tag','Dummy_Tabgroup');
%%% Goes through all detector/routing pairs
for i=1:numel(List)    
    %% Creates a tab for each detector/routing pair
    if isempty(h.MI_Tab{i,1})
        %%% Microtime tab
        MI_Tab= uitab(...
            'Parent',Dummy_Tabgroup,...
            'Tag','MI_Tab',...
            'Title',[num2str(UserValues.Detector.Det(i)) '/' num2str(UserValues.Detector.Rout(i))]);         
        h.MI_Tab{i,1}=handle(MI_Tab);        
        %%% Microtime panel
        MI_Panel = uibuttongroup(...
            'Parent',MI_Tab,...
            'Tag','MI_Panel',...
            'Units','normalized',...
            'BackgroundColor', UserValues.Look.Back,...
            'ForegroundColor', UserValues.Look.Fore,...
            'HighlightColor', UserValues.Look.Control,...
            'ShadowColor', UserValues.Look.Shadow,...
            'Position',[0 0 1 1]);
        h.MI_Tab{i,2}=handle(MI_Panel);
                
        %%% Microtime axes
        MI_Axes = axes(...
            'Parent',MI_Panel,...
            'Tag','MI_Axes',...
            'Units','normalized',...
            'NextPlot','add',...
            'UIContextMenu',h.MI_Menu,...
            'XColor',UserValues.Look.Fore,...
            'YColor',UserValues.Look.Fore,...
            'Position',[0.09 0.05 0.89 0.93],...
            'Box','on');
        h.MI_Tab{i,3}=handle(MI_Axes);
        set(h.MI_Tab{i,3}.XLabel,'String','TAC channel');
        set(h.MI_Tab{i,3}.YLabel,'String','Counts');
        h.MI_Tab{i,3}.XLim=[1 4096];
    else
        h.MI_Tab{i,1}.Parent=Dummy_Tabgroup;
    end
    
    %% Creates list entry for each detector/routing pair
    %%% If detector is enabled, it will be ploted in a new tab
    if UserValues.Detector.Use(i)
        %%% Calculates Hex code for detector color
        Hex_color=dec2hex(UserValues.Detector.Color(i,:)*255)';                
        List{i}=['<HTML><FONT color=#' Hex_color(:)' '> Detector: ' num2str(UserValues.Detector.Det(i)) ' / Routing: ' num2str(UserValues.Detector.Rout(i)) ' enabled </Font></html>'];
    %%% If detector is disabled, data will be loaded, but not ploted
    else
        List{i}=['<HTML><FONT> Detector: ' num2str(UserValues.Detector.Det(i)) ' / Routing: ' num2str(UserValues.Detector.Rout(i)) ' disabled </Font></html>'];
    end        
end
%%% Shifts all enabled channes to tabgroup to keep right order
for i=find(UserValues.Detector.Use)
    h.MI_Tab{i,1}.Parent=MI_Tabs;
end
%%% Matlab is just stupid
drawnow
%%% Shifts Settings\Phasor\Calibration tab around to make it the last one
h.MI_Settings_Tab.Parent=h.Dummy_Tabgroup;
h.MI_Phasor_Tab.Parent=h.Dummy_Tabgroup;
h.MI_Calib_Tab.Parent=h.Dummy_Tabgroup;
%%% See above
drawnow;
h.MI_Phasor_Tab.Parent=h.MI_Tabs;
h.MI_Calib_Tab.Parent=h.MI_Tabs;
h.MI_Settings_Tab.Parent=h.MI_Tabs;
%%% Gives focus to the right tab
switch mode
    case 1
        h.MI_Tabs.SelectedTab=h.MI_Tabs.Children(1);
    case 2
        h.MI_Tabs.SelectedTab=h.MI_Tabs.Children(end);
end

%%% Updates detector list
h.MI_Channels_List.String=List;
if h.MI_Channels_List.Value > numel(h.MI_Channels_List.String)
    h.MI_Channels_List.Value=numel(h.MI_Channels_List.String);
end

%%% Saves new tabs in guidata
guidata(gcf,h)

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
    case 'Macrotimes'
        Photons = TcspcData.MT;
    case 'Microtimes'
        Photons = TcspcData.MI;
end

Det = UserValues.PIE.Detector(PIEchannel);
Rout = UserValues.PIE.Router(PIEchannel);
From = UserValues.PIE.From(PIEchannel);
To = UserValues.PIE.To(PIEchannel);

if nargin == 2 %%% read whole photon stream
    if ~isempty(Photons{Det,Rout})
        Photons_PIEchannel = Photons{Det,Rout}(...
            TcspcData.MI{Det,Rout} >= From &...
            TcspcData.MI{Det,Rout} <= To);
    end
elseif nargin == 3 %%% read only the specified block
    %%% Calculates the block start times in clock ticks
    Times=ceil(PamMeta.MT_Patch_Times/FileInfo.RepRate);
    if ~isempty(Photons{Det,Rout})
        Photons_PIEchannel = Photons{Det,Rout}(...
            TcspcData.MI{Det,Rout} >= From &...
            TcspcData.MI{Det,Rout} <= To &...
            TcspcData.MT{Det,Rout} >= Times(block) &...
            TcspcData.MT{Det,Rout} < Times(block+1));
    end
elseif nargin == 4 %%% read only the specified chunk
    %%% define the chunk start and stop time based on chunksize and measurement
    %%% time
    %%% Determine Macrotime Boundaries from ChunkNumber and ChunkSize
    %%% (defined in minutes)
    LimitLow = (block-1)*chunk*60*FileInfo.RepRate+1;
    LimitHigh = ChunkNumber*ChunkSize*60*FileInfo.RepRate;
    if ~isempty(Photons{Det,Rout})
        Photons_PIEchannel = Photons{Det,Rout}(...
            TcspcData.MI{Det,Rout} >= From &...
            TcspcData.MI{Det,Rout} <= To &...
            TcspcData.MT{Det,Rout} >= LimitLow &...
            TcspcData.MT{Det1(l),Rout1(l)} < LimitHigh);
    end
end           

        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function generating deleting and selecting profiles  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "+"-Key or Add menu: Generate new profile
%%% "-"-Key, "del"-Key or Delete menu: Deletes selected profile
%%% "enter"-Key or Select menu: Makes selected profile current profile
function Update_Profiles(obj,ed)
h=guidata(gcf);
%global PamMeta UserValues
%% obj is empty, if function was called during initialization
if isempty(obj)
    %%% findes current profile
    load([pwd filesep 'profiles' filesep 'profile.mat']);    
    for i=1:numel(h.Profiles_List.String)
        %%% Looks for current profile in profiles list
        if strcmp(h.Profiles_List.String{i}, Profile)
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
                Update_Detector_Channels(1,[]);
                Update_Data([],[],0,0);
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
            LSUserValues(1);
            %%% Changes color to indicate current profile
            h.Profiles_List.String{Sel}=['<HTML><FONT color=FF0000>' h.Profiles_List.String{Sel} '</Font></html>']; 
            
            %%% Deletes and microtime tabs and clears PIE patches
            for i=1:size(h.MI_Tab,1)
                delete(h.MI_Tab{i,1});
            end            
            h.MI_Tab={};
            h.Plots=rmfield(h.Plots,'PIE_Patches');
            guidata(gcf,h);
            
            %%% Resets applied shift to zero; might lead to overcorrection
            
            Update_to_UserValues;
            Update_Detector_Channels(1,[]);
            Update_Data([],[],0,0);
        end        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to adjust setting to UserValues if a new profile was loaded  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_to_UserValues
global UserValues
h=guidata(gcf);

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
h.Cor_Multi_Menu.Checked=UserValues.Settings.Pam.Multi_Core;
h.Cor_Divider_Menu.Label=['Divider: ' num2str(UserValues.Settings.Pam.Cor_Divider)];

%%% Updates Detector calibration and Phasor channel lists
List=cell(numel(UserValues.Detector.Det));
for i=1:numel(UserValues.Detector.Det)
   List{i}=['Detector: ' num2str(UserValues.Detector.Det(i)) ' \ Routing' num2str(UserValues.Detector.Rout(i))];
end
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
h=guidata(gcf);

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for correlating data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Correlate (~,~)
h=guidata(gcf);
global UserValues TcspcData FileInfo PamMeta

%%% Initializes matlabpool for paralell computation
h.Progress_Text.String='Opening matlabpool';
drawnow;
gcp;

h.Progress_Text.String = 'Correlating';
h.Progress_Axes.Color=[1 0 0];
%%% Finds the right combinations to correlate
[Cor_A,Cor_B]=find(h.Cor_Table.Data(1:end-1,1:end-1));
%%% Calculates the maximum inter-photon time in clock ticks
Maxtime=ceil(max(diff(PamMeta.MT_Patch_Times))/FileInfo.RepRate)/UserValues.Settings.Pam.Cor_Divider;
%%% Calculates the photon start times in clock ticks
Times=ceil(PamMeta.MT_Patch_Times/FileInfo.RepRate);
%%% Uses truncated Filename
FileName=FileInfo.FileName{1}(1:end-5);
drawnow;

%%% For every active combination
for i=1:numel(Cor_A)
    %% Initializes data
    %%% Initializes data cells
    Data1=cell(sum(PamMeta.Selected_MT_Patches),1);
    Data2=cell(sum(PamMeta.Selected_MT_Patches),1);
    
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
          
    %% Assigns photons and does correlation
    %%% Starts progressbar
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
    Cor_Times=Cor_Times*FileInfo.RepRate*UserValues.Settings.Pam.Cor_Divider;
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
        
        Header = ['Correlation file for: ' strrep(fullfile(FileInfo.Path, FileName),'\','\\') ' of Channels ' UserValues.PIE.Name{Cor_A(i)} ' cross ' UserValues.PIE.Name{Cor_A(i)}];
        Counts = [Counts1 Counts2]/FileInfo.ImageTime/FileInfo.NumberOfFiles/1000;
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
        
        %%% Creates new correlation file
        FileID=fopen(Current_FileName,'w');
        
        %%% Writes Heater
        fprintf(FileID, ['Correlation file for: ' strrep(fullfile(FileInfo.Path, FileName),'\','\\') ' of Channels ' UserValues.PIE.Name{Cor_A(i)} ' cross ' UserValues.PIE.Name{Cor_A(i)} '\n']);
        fprintf(FileID, ['Countrate channel 1 [kHz]: ' num2str(Counts1/1000, '%12.2f') '\n']);
        fprintf(FileID, ['Countrate channel 2 [kHz]: ' num2str(Counts2/1000, '%12.2f') '\n']);
        fprintf(FileID, ['Valid bins: ' num2str(Valid) '\n']);
        fprintf(FileID, ['Used  bins: ' num2str(1,ones(numel(Valid))) '\n']);
        %%% Indicates start of data
        fprintf(FileID, ['Data starts here: ' '\n']);
        
        %%% Writes data as columns: Time    Averaged    SEM     Individual bins
        fprintf(FileID, ['%8.12f\t%8.8f\t%8.8f' repmat('\t%8.8f',1,numel(Valid)) '\n'], [Cor_Times Cor_Average Cor_SEM Cor_Array]');
        fclose(FileID); 
    end

    Progress(1);
    Progress((i)/numel(Cor_A),h.Progress_Axes,h.Progress_Text,'Correlating :')
end
Update_Display([],[],1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to keep shift equal  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Phasor_Shift(obj,~)
h=guidata(gcf);
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
h=guidata(gcf);
Det=h.MI_Phasor_Det.Value;
%%% Sets reference to 0 in case of shorter MI length
UserValues.Phasor.Reference(Det,:)=0;
%%% Assigns current MI histogram as reference
UserValues.Phasor.Reference(Det,1:numel(PamMeta.MI_Hist{Det}))=PamMeta.MI_Hist{Det};

LSUserValues(1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to calculate and save Phasor Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Phasor_Calc(~,~)   
global UserValues TcspcData FileInfo PamMeta
h=guidata(gcf);
if isfield(UserValues,'Phasor') && isfield(UserValues.Phasor,'Reference') 
    
    %%% Determines correct detector and routing
    Det=UserValues.Detector.Det(h.MI_Phasor_Det.Value);
    Rout=UserValues.Detector.Rout(h.MI_Phasor_Det.Value);
    %%% Selects filename to save
    [FileName,PathName] = uiputfile('*.phr','Save Phasor Data',UserValues.File.Path);
    
    if ~all(FileName==0)
        Progress(0,h.Progress_Axes, h.Progress_Text,'Calculating Phasor Data:');
        
        %%% Saves pathname
        UserValues.File.Path=PathName;
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
        Photons=TcspcData.MT{Det,Rout}(TcspcData.MI{Det,Rout}>=From & TcspcData.MI{Det,Rout}<=To)*FileInfo.RepRate;        
        [Photons,Index]=sort(mod(Photons,FileInfo.ImageTime));
        Index=uint32(Index);
        
        %%% Calculates Pixel vector
        Pixeltimes=0;
        for j=1:FileInfo.Lines
            Pixeltimes(end:(end+FileInfo.Lines))=linspace(FileInfo.LineTimes(j),FileInfo.LineTimes(j+1),FileInfo.Lines+1);
        end
        
        %%% Calculates, which Photons belong to which pixel
        Intensity=histc(Photons,Pixeltimes(1:end-1).*FileInfo.RepRate);        
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
        save(fullfile(PathName,FileName), 'g','s','Mean_LT','Fi','M','TauP','TauM','Intensity','Lines','Freq','Imagetime','Frames','FileNames','Path'); 
        
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
h=guidata(gcf);
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
%%% Function for updating BurstSearch Parameters in UserValues  %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BurstSearchParameterUpdate(obj,~)
global UserValues
h=guidata(gcf);
if obj == h.BurstPIE_Table %change in PIE channel selection
    UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method} = obj.Data;
else %change in edit boxes
    UserValues.BurstSearch.SearchParameters{UserValues.BurstSearch.Method} = [str2double(h.BurstParameter1_Edit.String),...
        str2double(h.BurstParameter2_Edit.String), str2double(h.BurstParameter3_Edit.String), str2double(h.BurstParameter4_Edit.String),...
        str2double(h.BurstParameter5_Edit.String)];
end
LSUserValues(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Performs a Burst Search  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_BurstSearch()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to apply microtime shift for detector correction %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Calibrate_Detector(~,~,Det,Rout)
global UserValues TcspcData PamMeta FileInfo
h=guidata(gcf);
h.Progress_Text.String = 'Calculating detector calibration';
h.Progress_Axes.Color=[1 0 0];
drawnow;
if nargin<3
    Det=UserValues.Detector.Det(h.MI_Calib_Det.Value);
    Rout=UserValues.Detector.Rout(h.MI_Calib_Det.Value);
    Dif=[400; uint16(diff(TcspcData.MT{Det,Rout}))];
    Dif(Dif>400)=400;
    MI=TcspcData.MI{Det,Rout};
    
    if all(size(PamMeta.Applied_Shift)>=[Det,Rout]) && ~isempty(PamMeta.Applied_Shift{Det,Rout})
        PamMeta.Det_Calib.Hist=histc(double(Dif-1)*FileInfo.MI_Bins+double(MI)+PamMeta.Applied_Shift{Det,Rout}(Dif)',0:(400*FileInfo.MI_Bins-1));
    else
        PamMeta.Det_Calib.Hist=histc(double(Dif-1)*FileInfo.MI_Bins+double(MI),0:(400*FileInfo.MI_Bins-1));
    end
    PamMeta.Det_Calib.Hist=reshape(PamMeta.Det_Calib.Hist,FileInfo.MI_Bins,400);
    
    [Counts,Index]=sort(PamMeta.Det_Calib.Hist);
    PamMeta.Det_Calib.Shift=sum(Counts(end-100:end,:).*Index(end-100:end,:))./sum(Counts(end-100:end,:));
    PamMeta.Det_Calib.Shift=round(PamMeta.Det_Calib.Shift-PamMeta.Det_Calib.Shift(end));
    PamMeta.Det_Calib.Shift(isnan(PamMeta.Det_Calib.Shift))=0;
    PamMeta.Det_Calib.Shift(1:5)=PamMeta.Det_Calib.Shift(6);
    PamMeta.Det_Calib.Shift=PamMeta.Det_Calib.Shift-max(PamMeta.Det_Calib.Shift);
    
    clear Counts Index
    
    h.Plots.Calib_No.YData=sum(PamMeta.Det_Calib.Hist,2)/max(smooth(sum(PamMeta.Det_Calib.Hist,2),5));
    h.Plots.Calib_No.XData=1:FileInfo.MI_Bins;
    Cor_Hist=zeros(size(PamMeta.Det_Calib.Hist));
    for i=1:400
       Cor_Hist(:,i)=circshift(PamMeta.Det_Calib.Hist(:,i),[-PamMeta.Det_Calib.Shift(i),0]);
    end
    h.Plots.Calib.YData=sum(Cor_Hist,2)/max(smooth(sum(Cor_Hist,2),5));
    h.Plots.Calib.XData=1:FileInfo.MI_Bins;
    h.MI_Calib_Single.Value=round(h.MI_Calib_Single.Value);
    h.Plots.Calib_Sel.YData=Cor_Hist(:,h.MI_Calib_Single.Value)/max(smooth(Cor_Hist(:,h.MI_Calib_Single.Value),5));
    h.Plots.Calib_Sel.XData=1:FileInfo.MI_Bins;
    
    h.Plots.Calib_Shift_New.YData=PamMeta.Det_Calib.Shift;
else
    if Det==0
        Det=UserValues.Detector.Det;
        Rout=UserValues.Detector.Rout;
    end
    for i=1:numel(Det)
        if size(UserValues.Detector.Shift,1)>=Det(i) &&  any(UserValues.Detector.Shift{Det(i)}) && ~isempty(TcspcData.MI{Det(i),Rout(i)})
            %%% Calculates inter-photon time; first photon gets 0 shift
            Dif=[400; uint16(diff(TcspcData.MT{Det(i),Rout(i)}))];
            Dif(Dif>400)=400;
            %%% Applies shift to microtime; no shift for >=400
            TcspcData.MI{Det(i),Rout(i)}(Dif<=400)...
                =uint16(double(TcspcData.MI{Det(i),Rout(i)}(Dif<=400))...
                -UserValues.Detector.Shift{Det(i)}(Dif(Dif<=400))');
            PamMeta.Applied_Shift{Det(i)}=UserValues.Detector.Shift{Det(i)};

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
h=guidata(gcf);
Det=UserValues.Detector.Det(h.MI_Calib_Det.Value);
Rout=UserValues.Detector.Rout(h.MI_Calib_Det.Value);
if isfield(PamMeta.Det_Calib,'Shift')
    UserValues.Detector.Shift{Det,Rout}=PamMeta.Det_Calib.Shift;
    Calibrate_Detector([],[],Det,Rout);
end
LSUserValues(1)

