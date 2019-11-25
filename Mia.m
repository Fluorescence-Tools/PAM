function Mia(~,~)
global UserValues MIAData PathToApp
h.Mia=findobj('Tag','Mia');

addpath(genpath(['.' filesep 'functions']));

if ~isempty(h.Mia)
    figure(h.Mia); % Gives focus to Pam figure
    return;
end
if isempty(PathToApp)
    GetAppFolder();
end
%%% start splash screen
s = SplashScreen( 'Splashscreen', [PathToApp filesep 'images' filesep 'PAM' filesep 'logo.png'], ...
    'ProgressBar', 'on', ...
    'ProgressPosition', 5, ...
    'ProgressRatio', 0 );
s.addText( 30, 50, 'MIA - Microtime Image Analysis', 'FontSize', 30, 'Color', [1 1 1] );
s.addText( 30, 80, 'v1.0', 'FontSize', 20, 'Color', [1 1 1] );
s.addText( 375, 395, 'Loading...', 'FontSize', 25, 'Color', 'white' );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loads user profile
LSUserValues(0);
%%% To save typing
Look=UserValues.Look;
%%% Generates the Mia figure
h.Mia = figure(...
    'Units','normalized',...
    'Tag','Mia',...
    'Name','MIA: Microtime image analysis',...
    'NumberTitle','off',...
    'Menu','none',...
    'defaultUicontrolFontName',Look.Font,...
    'defaultAxesFontName',Look.Font,...
    'defaultTextFontName',Look.Font,...
    'Toolbar','figure',...
    'UserData',[],...
    'OuterPosition',[0.01 0.1 0.98 0.9],...
    'CloseRequestFcn',@CloseWindow,...
    'Visible','off');
%h.Mia.Visible='off';
h.Text=[];

%%% Sets background of axes and other things
whitebg(Look.Axes);
%%% Changes Pam background; must be called after whitebg
h.Mia.Color=Look.Back;
%%% Remove unneeded items from toolbar
toolbar = findall(h.Mia,'Type','uitoolbar');
toolbar_items = findall(toolbar);
if verLessThan('matlab','9.5') %%% toolbar behavior changed in MATLAB 2018b
    delete(toolbar_items([2:7 13:17]));
else %%% 2018b and upward
    %%% just remove the tool bar since the options are now in the axis
    %%% (e.g. axis zoom etc)
    delete(toolbar_items);
end
%%% Menu to load mia data
h.Mia_Load = uimenu(...
    'Parent',h.Mia,...
    'Label','Load...',...
    'Tag','Load_Mia');
%%% Load TIFF
h.Mia_Load_TIFF_Single = uimenu(...
    'Parent',h.Mia_Load,...
    'Label','...single color TIFFs',...
    'Callback',{@Mia_Load,1},...
    'Tag','Load_Mia_TIFF_SIngle');
%%% Load TIFF
h.Mia_Load_TIFF_RGB = uimenu(...
    'Parent',h.Mia_Load,...
    'Label','...RGB TIFFs');
%%% Load TIFF
h.Mia_Load_TIFF_RGB_GR = uimenu(...
    'Parent',h.Mia_Load_TIFF_RGB,...
    'Label','...Green-Red',...
    'Callback',{@Mia_Load,4},...
    'Tag','Load_Mia_TIFF_SIngle');
%%% Load TIFF
h.Mia_Load_TIFF_RGB_GR = uimenu(...
    'Parent',h.Mia_Load_TIFF_RGB,...
    'Label','...Blue-Green',...
    'Callback',{@Mia_Load,5},...
    'Tag','Load_Mia_TIFF_SIngle');
%%% Load TIFF
h.Mia_Load_TIFF_RGB_GR = uimenu(...
    'Parent',h.Mia_Load_TIFF_RGB,...
    'Label','...Blue-Red',...
    'Callback',{@Mia_Load,6},...
    'Tag','Load_Mia_TIFF_SIngle');

%%% Load TIFF
h.Mia_Load_TIFF_RLICS = uimenu(...
    'Parent',h.Mia_Load,...
    'Label','...weighted TIFFs',...
    'Callback',{@Mia_Load,1.5},...
    'Tag','Load_Mia_TIFF_RLICS');
%%% Load Data from Pam
h.Mia_Load_Pam = uimenu(...
    'Parent',h.Mia_Load,...
    'Label','...data from PAM',...
    'Callback',{@Mia_Load,2},...
    'Tag','Load_Mia_Pam');
%%% Load custom data format
h.Mia_Load_Custom = uimenu(...
    'Parent',h.Mia_Load,...
    'Label','...custom data format',...
    'Callback',{@Mia_Load,3},...
    'Tag','Load_Mia_Custom');


%%% Menu to open MIAFit and Spectral
h.Mia_Open = uimenu(...
    'Parent',h.Mia,...
    'Label','Open...',...
    'Tag','Mia_Open');
%%% Open MIAFit
h.Mia_Open_MIAFit = uimenu(...
    'Parent',h.Mia_Open,...
    'Label','MIAFit',...
    'Callback',@MIAFit,...
    'Tag','Mia_Open_MIAFit');
%%% Open RICSPE
h.Mia_Open_RICSPE = uimenu(...
    'Parent',h.Mia_Open,...
    'Label','RICSPE',...
    'Callback',@RICSPE_GUI,...
    'Tag','Mia_Open_RICSPE');
%%% Open Spectral
h.Mia_Open_Spectral = uimenu(...
    'Parent',h.Mia_Open,...
    'Label','Spectral',...
    'Callback',@Spectral,...
    'Tag','Mia_Open_Spectral');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Progressbar and file names %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Panel for progressbar
h.Mia_Progress_Panel = uibuttongroup(...
    'Parent',h.Mia,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.001 0.98 0.998 0.02]);
%%% Axes for progressbar
h.Mia_Progress_Axes = axes(...
    'Parent',h.Mia_Progress_Panel,...
    'Units','normalized',...
    'Color',Look.Control,...
    'Position',[0 0 1 1]);
h.Mia_Progress_Axes.XTick=[]; h.Mia_Progress_Axes.YTick=[];
%%% Progress and filename text
h.Mia_Progress_Text=text(...
    'Parent',h.Mia_Progress_Axes,...
    'Units','normalized',...
    'FontSize',12,...
    'FontWeight','bold',...
    'String','Nothing loaded',...
    'Interpreter','none',...
    'HorizontalAlignment','center',...
    'BackgroundColor','none',...
    'Color',Look.Fore,...
    'Position',[0.5 0.5]);
%% Main tab container %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.Mia_Main_Tabs = uitabgroup(...
    'Parent',h.Mia,...
    'Tag','Mia_Main_Tabs',...
    'Units','normalized',...
    'Position',[0 0 1 0.98]);
%% Image Tab
h.Mia_Image.Tab = uitab(...
    'Parent',h.Mia_Main_Tabs,...
    'Title','Image',...
    'Tag','Mia_Main_Tabs',...
    'Units','normalized');
h.Mia_Image.Panel = uibuttongroup(...
    'Parent',h.Mia_Image.Tab,...
    'Tag','Mia_Main_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 0.8 1]);

h.Mia_Image.Menu = uicontextmenu;
h.Mia_Image.Select_Manual_ROI = uimenu(...
    'Parent',h.Mia_Image.Menu,...
    'Label','Select manual ROI',...
    'Callback',{@Mia_Freehand,1});
h.Mia_Image.Unselect_Manual_ROI = uimenu(...
    'Parent',h.Mia_Image.Menu,...
    'Label','Unselect manual ROI',...
    'Callback',{@Mia_Freehand,2});
h.Mia_Image.Clear_Manual_ROI = uimenu(...
    'Parent',h.Mia_Image.Menu,...
    'Label','Clear manual ROI',...
    'Callback',{@Mia_Freehand,3});
for i=1:2
    %%% Axes to display images
    h.Mia_Image.Axes(i,1)= axes(...
        'Parent',h.Mia_Image.Panel,...
        'Tag', ['ImRaw', num2str(i)],...
        'Units','normalized',...
        'NextPlot','Add',...
        'Position',[0.28 0.99-0.49*i 0.35 0.48]);
    colormap(h.Mia_Image.Axes(i,1),gray(64));
    h.Mia_Image.Axes(i,2)= axes(...
        'Parent',h.Mia_Image.Panel,...
        'Tag', ['ImCorr', num2str(i)],...
        'Units','normalized',...
        'NextPlot','Add',...
        'Position',[0.64 0.99-0.49*i 0.35 0.48]);
    colormap(h.Mia_Image.Axes(i,2),gray(64));
    %%% Initializes empty plots
    h.Plots.Image(i,1)=imagesc(zeros(1),...
        'Parent',h.Mia_Image.Axes(i,1),...
        'ButtonDownFcn',{@Mia_ROI,2});
    h.Mia_Image.Axes(i,1).DataAspectRatio=[1 1 1];
    h.Mia_Image.Axes(i,1).XTick=[];
    h.Mia_Image.Axes(i,1).YTick=[];
    h.Plots.Image(i,2)=imagesc(zeros(1),...
        'Parent',h.Mia_Image.Axes(i,2),...
        'ButtonDownFcn',@Mia_Export);
    h.Mia_Image.Axes(i,2).DataAspectRatio=[1 1 1];
    h.Mia_Image.Axes(i,2).XTick=[];
    h.Mia_Image.Axes(i,2).YTick=[];
    %%% Initializes a rectangle ROI
    h.Plots.ROI(i)=rectangle(...
        'Parent',h.Mia_Image.Axes(i,1),...
        'Position',[0.5 0.5 1 1],...
        'EdgeColor',[1 1 1],...
        'HitTest','off');
end

%%% Text
h.Mia_Image.DoPCH = handle(uicontrol(...
    'Parent',h.Mia_Image.Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Value', UserValues.MIA.DoPCH,...
    'Position',[0.05 0.97 0.21 0.02],...
    'String','Calculate PCH' ));

h.Mia_Image.Intensity_Axes = axes(...
    'Parent',h.Mia_Image.Panel,...
    'Units','normalized',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'Position',[0.05 0.55 0.21 0.38]);
h.Plots.Int(1,1) = line(...
    'Parent',h.Mia_Image.Intensity_Axes,...
    'XData',[0 1],...
    'YData', [0 0],...
    'LineStyle','--',...
    'Color',[0 0.6 0]);
h.Plots.Int(1,2) = line(...
    'Parent',h.Mia_Image.Intensity_Axes,...
    'XData',[0 1],...
    'YData', [0 0],...
    'Color',[0 0.6 0]);
h.Plots.Int(2,1) = line(...
    'Parent',h.Mia_Image.Intensity_Axes,...
    'XData',[0 1],...
    'YData', [0 0],...
    'LineStyle','--',...
    'Visible','off',...
    'Color',[1 0 0]);
h.Plots.Int(2,2) = line(...
    'Parent',h.Mia_Image.Intensity_Axes,...
    'XData',[0 1],...
    'YData', [0 0],...
    'Visible','off',...
    'Color',[1 0 0]);

h.Mia_Image.Intensity_Axes.XLabel.String = 'Frame';
h.Mia_Image.Intensity_Axes.YLabel.String = 'Average Countrate [kHz]';
h.Mia_Image.Intensity_Axes.XLabel.Color = Look.Fore;
h.Mia_Image.Intensity_Axes.YLabel.Color = Look.Fore;
h.Mia_Image.Intensity_Axes.YLabel.UserData = 1;
h.Mia_Image.Intensity_Axes.YLabel.ButtonDownFcn = {@MIA_Various,[1 2]};
h.Mia_Image.Intensity_Axes.XLabel.UserData = 1;
h.Mia_Image.Intensity_Axes.XLabel.ButtonDownFcn = {@MIA_Various,[1 2]};

h.Mia_Image.PCH_Axes = axes(...
    'Parent',h.Mia_Image.Panel,...
    'Units','normalized',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'Position',[0.05 0.07 0.21 0.38]);
h.Plots.PCH(1,1) = line(...
    'Parent',h.Mia_Image.PCH_Axes,...
    'XData',[0 1],...
    'YData', [0 0],...
    'LineStyle','--',...
    'Color',[0 0.6 0]);
h.Plots.PCH(1,2) = line(...
    'Parent',h.Mia_Image.PCH_Axes,...
    'XData',[0 1],...
    'YData', [0 0],...
    'Color',[0 0.6 0]);
h.Plots.PCH(2,1) = line(...
    'Parent',h.Mia_Image.PCH_Axes,...
    'XData',[0 1],...
    'YData', [0 0],...
    'LineStyle','--',...
    'Visible','off',...
    'Color',[1 0 0]);
h.Plots.PCH(2,2) = line(...
    'Parent',h.Mia_Image.PCH_Axes,...
    'XData',[0 1],...
    'YData', [0 0],...
    'Visible','off',...
    'Color',[1 0 0]);

h.Mia_Image.PCH_Axes.XLabel.String = 'Counts';
h.Mia_Image.PCH_Axes.YLabel.String = 'Frequency';
h.Mia_Image.PCH_Axes.XLabel.Color = Look.Fore;
h.Mia_Image.PCH_Axes.YLabel.Color = Look.Fore;
h.Mia_Image.PCH_Axes.YLabel.UserData = 1;
h.Mia_Image.PCH_Axes.YLabel.ButtonDownFcn = {@MIA_Various,[1 2]};
h.Mia_Image.PCH_Axes.XLabel.UserData = 1;
h.Mia_Image.PCH_Axes.XLabel.ButtonDownFcn = {@MIA_Various,[1 2]};
%% Settings Tab container
h.Mia_Image.Settings.Panel = uibuttongroup(...
    'Parent',h.Mia_Image.Tab,...
    'Tag','Mia_Settings_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.8 0.5 0.2 0.5]);
h.Mia_Image.Settings.Tabs = uitabgroup(...
    'Parent',h.Mia_Image.Settings.Panel,...
    'Tag','Mia_Settings_Tabs',...
    'Units','normalized',...
    'Position',[0 0 1 1]);
%% Mia Channel setting container
%%% Tab and panel for Mia image settings UIs
h.Mia_Image.Settings.Channel_Tab= uitab(...
    'Parent',h.Mia_Image.Settings.Tabs,...
    'Title','Channels');
h.Mia_Image.Settings.Channel_Panel = uibuttongroup(...
    'Parent',h.Mia_Image.Settings.Channel_Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Text
h.Text{end+1} = handle(uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.92 0.48 0.06],...
    'String','Channel 1' ));
%%% Text
h.Text{end+1} = handle(uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.51 0.92 0.48 0.06],...
    'String','Channel 2' ));
%%% Text
h.Text{end+1} = handle(uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.86 0.98 0.05],...
    'String','Image Colormap:' ));
%%% Colormap selection for images
h.Mia_Image.Settings.Channel_Colormap(1) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'Value', UserValues.MIA.ColorMap_Main(1),...
    'UserData',UserValues.MIA.CustomColor(1,:),...
    'UserData',[0 1 0],...
    'Callback',{@Update_Plots,1,1},...
    'ButtonDownFcn',{@Mia_Color,1},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.80 0.48 0.06],...
    'String',{'Gray','Jet','Hot','HSV','Custom', 'HiLo'});
%%% Colormap selection for images
h.Mia_Image.Settings.Channel_Colormap(2) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'Value', UserValues.MIA.ColorMap_Main(2),...
    'UserData',UserValues.MIA.CustomColor(2,:),...
    'Callback',{@Update_Plots,1,2},...
    'ButtonDownFcn',{@Mia_Color,2},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.51 0.80 0.48 0.06],...
    'String',{'Gray','Jet','Hot','HSV','Custom', 'HiLo'});
if ismac
    h.Mia_Image.Settings.Channel_Colormap(1).ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.Channel_Colormap(1).BackgroundColor = [1 1 1];
    h.Mia_Image.Settings.Channel_Colormap(2).ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.Channel_Colormap(2).BackgroundColor = [1 1 1];
end
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.71 0.98 0.05],...
    'String','PIE Channel to load:');
%%% Colormap selection for images
h.Mia_Image.Settings.Channel_PIE(1) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Value',1,...
    'Position',[0.01 0.65, 0.48 0.06],...
    'String',UserValues.PIE.Name);
%%% Colormap selection for images
h.Mia_Image.Settings.Channel_PIE(2) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Value',numel(UserValues.PIE.Name)+1,...
    'Position',[0.51 0.65, 0.48 0.06],...
    'String',[UserValues.PIE.Name,{'Nothing'}]);
if ismac
    h.Mia_Image.Settings.Channel_PIE(1).ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.Channel_PIE(1).BackgroundColor = [1 1 1];
    h.Mia_Image.Settings.Channel_PIE(2).ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.Channel_PIE(2).BackgroundColor = [1 1 1];
end

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.56, 0.98 0.05],...
    'String','Show in second plot:');
%%% Popupmenu to select what to plot in second plot
h.Mia_Image.Settings.Channel_Second(1) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.50, 0.48 0.06],...
    'Callback',{@Update_Plots,1,1},...
    'Value',2,...
    'String',{'Original','Dynamic','Static'});
%%% Popupmenu to select what to plot in second plot
h.Mia_Image.Settings.Channel_Second(2) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.51 0.50, 0.48 0.06],...
    'Callback',{@Update_Plots,1,2},...
    'Value',2,...
    'String',{'Original','Dynamic','Static'});
if ismac
    h.Mia_Image.Settings.Channel_Second(1).ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.Channel_Second(1).BackgroundColor = [1 1 1];
    h.Mia_Image.Settings.Channel_Second(2).ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.Channel_Second(2).BackgroundColor = [1 1 1];
end

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.41, 0.98 0.05],...
    'String','Scale image:');
%%% Popupmenu to select how to scale images
h.Mia_Image.Settings.AutoScale = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.35, 0.98 0.06],...
    'Callback',{@Update_Plots,1,1:2},...
    'Value',1,...
    'String',{'Autoscale Frame','Autoscale Total','Manual Scale'});
if ismac
    h.Mia_Image.Settings.AutoScale.ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.AutoScale.BackgroundColor = [1 1 1];
    
end
%%% Text
h.Mia_Image.Settings.Scale_Text = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Visible', 'off',...
    'Position',[0.01 0.28, 0.98 0.05],...
    'String','Scale min/max [Counts]:');

%%% Editboxes for scaleing
h.Mia_Image.Settings.Scale(1,1) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Visible', 'off',...
    'Callback',{@Update_Plots,1,1},...
    'Position',[0.01 0.23, 0.2 0.05],...
    'String','0');
h.Mia_Image.Settings.Scale(1,2) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Visible', 'off',...
    'Callback',{@Update_Plots,1,1},...
    'Position',[0.23 0.23, 0.2 0.05],...
    'String','100');
h.Mia_Image.Settings.Scale(2,1) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Visible', 'off',...
    'Callback',{@Update_Plots,1,2},...
    'Position',[0.51 0.23, 0.2 0.05],...
    'String','0');
h.Mia_Image.Settings.Scale(2,2) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Visible', 'off',...
    'Callback',{@Update_Plots,1,2},...
    'Position',[0.73 0.23, 0.2 0.05],...
    'String','100');

%%% Checkbox to link channels
h.Mia_Image.Settings.Channel_Link = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Callback',{@Mia_Frame,2,1},...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.16, 0.98 0.05],...
    'Value',1,...
    'String','Link channels');

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.11, 0.98 0.05],...
    'String','Show Frame:');
%%% Editbox for frame
h.Mia_Image.Settings.Channel_Frame(1) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Mia_Frame,1,1},...
    'Position',[0.01 0.06, 0.2 0.05],...
    'String','1');
%%% Checkbox for use frame
h.Mia_Image.Settings.Channel_FrameUse(1) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Mia_CheckFrame,1},...
    'Value',1,...
    'Position',[0.23 0.06, 0.25 0.05],...
    'String','Use');
%%% Slider for frame
h.Mia_Image.Settings.Channel_Frame_Slider(1) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'UserData',[2,1],...
    'Position',[0.01 0.01, 0.48 0.04]);
h.Mia_Image.Settings.Channel_Frame_Listener(1)=addlistener(h.Mia_Image.Settings.Channel_Frame_Slider(1),'Value','PostSet',@Mia_Frame);
%%% Editbox for frame
h.Mia_Image.Settings.Channel_Frame(2) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Mia_Frame,1,2},...
    'Position',[0.51 0.06, 0.2 0.05],...
    'String','1');
%%% Checkbox for use frame
h.Mia_Image.Settings.Channel_FrameUse(2) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Mia_CheckFrame,2},...
    'Value',1,...
    'Position',[0.73 0.06, 0.25 0.05],...
    'String','Use');
%%% Slider for frame
h.Mia_Image.Settings.Channel_Frame_Slider(2) = uicontrol(...
    'Parent',h.Mia_Image.Settings.Channel_Panel,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'UserData',[2,2],...
    'Position',[0.51 0.01, 0.48 0.04]);
h.Mia_Image.Settings.Channel_Frame_Listener(2)=addlistener(h.Mia_Image.Settings.Channel_Frame_Slider(2),'Value','PostSet',@Mia_Frame);
%% Mia image settings tab
%%% Tab and panel for Mia image settings UIs
h.Mia_Image.Settings.Image_Tab= uitab(...
    'Parent',h.Mia_Image.Settings.Tabs,...
    'Tag','MI_Image_Tab',...
    'Title','Image');
h.Mia_Image.Settings.Image_Panel = uibuttongroup(...
    'Parent',h.Mia_Image.Settings.Image_Tab,...
    'Tag','Mia_Image_Settings_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Image_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.92, 0.4 0.06],...
    'String','Frame time [s]:');
%%% Editbox to set frame time
h.Mia_Image.Settings.Image_Frame = uicontrol(...
    'Parent',h.Mia_Image.Settings.Image_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Update_Plots, [4 5 6],1:3},...
    'Position',[0.45 0.92, 0.2 0.06],...
    'String','1');
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Image_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.84, 0.4 0.06],...
    'String','Line time [ms]:');
%%% Editbox to set line time
h.Mia_Image.Settings.Image_Line = uicontrol(...
    'Parent',h.Mia_Image.Settings.Image_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.45 0.84, 0.2 0.06],...
    'String','3.333');
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Image_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.76, 0.4 0.06],...
    'String','Pixel time [us]:');
%%% Editbox to set pixel time
h.Mia_Image.Settings.Image_Pixel = uicontrol(...
    'Parent',h.Mia_Image.Settings.Image_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Update_Plots,4,[]},...
    'Position',[0.45 0.76, 0.2 0.06],...
    'String','11.11');
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Image_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.68, 0.4 0.06],...
    'String','Pixel size [nm]:');
%%% Editbox to set pixel size
h.Mia_Image.Settings.Image_Size = uicontrol(...
    'Parent',h.Mia_Image.Settings.Image_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.45 0.68, 0.2 0.06],...
    'Callback',{@Update_Plots, 6,1:3},...
    'String','40');

%%% Text
h.Mia_Image.Settings.Image_Mean_CR = uicontrol(...
    'Parent',h.Mia_Image.Settings.Image_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.52, 0.96 0.1],...
    'String','Mean Countrate [kHz]:');
%% Mia ROI setting tab
%%% Tab and panel for Mia ROI settings UIs
h.Mia_Image.Settings.ROI_Tab= uitab(...
    'Parent',h.Mia_Image.Settings.Tabs,...
    'Tag','MI_ROI_Settings_Tab',...
    'Title','ROI');
h.Mia_Image.Settings.ROI_Panel = uibuttongroup(...
    'Parent',h.Mia_Image.Settings.ROI_Tab,...
    'Tag','Mia_ROI_Settings_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.ROI_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.92, 0.35 0.06],...
    'String','ROI size:');
%%% Popupmenu to select ROI Size
h.Mia_Image.Settings.ROI_SizeX = uicontrol(...
    'Parent',h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.35 0.92, 0.25 0.06],...
    'Callback',{@Mia_ROI,1},...
    'String','200');
%%% Popupmenu to select ROI Size
h.Mia_Image.Settings.ROI_SizeY = uicontrol(...
    'Parent',h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.62 0.92, 0.25 0.06],...
    'Callback',{@Mia_ROI,1},...
    'String','200');
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.ROI_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.84, 0.35 0.06],...
    'String','ROI pos:');
%%% Popupmenu to select ROI Position
h.Mia_Image.Settings.ROI_PosX = uicontrol(...
    'Parent',h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.35 0.84, 0.25 0.06],...
    'Callback',{@Mia_ROI,1},...
    'String','0');
%%% Popupmenu to select ROI Position
h.Mia_Image.Settings.ROI_PosY = uicontrol(...
    'Parent',h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.62 0.84, 0.25 0.06],...
    'Callback',{@Mia_ROI,1},...
    'String','0');

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.76, 0.5 0.06],...
    'String','Frame range:',...
    'Tooltipstring','Sets the frame range to use (applies to all analyses)');
%%% Editbox to select, which frames to correlate
h.Mia_Image.Settings.ROI_Frames = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.62 0.76, 0.25 0.06],...
    'String','1',...
    'Tooltipstring','Sets the frame range to use (applies to all analyses)');

%%%Button to Import ROI from file
h.Mia_Image.Settings.Load_ROI = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Tab,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.02, 0.8 0.06],...
    'Callback',{@Import_ROI},...
    'String','Import ROI from .mat File');

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.68, 0.35 0.06],...
    'String','Special selection:');

%%% Select unselection criteria
h.Mia_Image.Settings.ROI_FramesUse = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.34 0.68, 0.27 0.06],...
    'Callback',{@MIA_Various,3},...
    'String',{'None','Checked frames','Arbitrary ROI'});
if ismac
    h.Mia_Image.Settings.ROI_FramesUse.ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.ROI_FramesUse.BackgroundColor = [1 1 1];
end

h.Mia_Image.Settings.ROI_AR_Text = {};
% h.Mia_Image.Settings.ROI_AR_Text{end+1} = uicontrol(...
%     'Parent', h.Mia_Image.Settings.ROI_Panel,...
%     'Style','text',...
%     'Units','normalized',...
%     'FontSize',14,...
%     'HorizontalAlignment','left',...
%     'BackgroundColor', Look.Back,...
%     'ForegroundColor', Look.Fore,...
%     'Position',[0.02 0.54, 0.56 0.11],...
%     'Visible', 'off',...
%     'String','Arbitrary region threshold');
%%% Text
h.Mia_Image.Settings.ROI_AR_Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.58 0.58, 0.2 0.06],...
    'Visible', 'off',...
    'String','MIN');
%%% Text
h.Mia_Image.Settings.ROI_AR_Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.81 0.58, 0.2 0.06],...
    'Visible', 'off',...
    'String','MAX');
%%% Text
h.Mia_Image.Settings.ROI_AR_Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies min\max pixel countrate' 10 'averaged over all frames'],...
    'Position',[0.02 0.52, 0.50 0.06],...
    'Visible', 'off',...
    'String','Intensity [kHz]:');
%%% Minimal average pixel countrate
h.Mia_Image.Settings.ROI_AR_Int_Min(1) = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',11,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies min pixel countrate' 10 'averaged over all frames'],...
    'Position',[0.52 0.52, 0.11 0.06],...
    'Visible', 'off',...
    'Callback',{@Mia_Correct,1},...
    'String',num2str(UserValues.MIA.AR_Int(1)));
%%% Minimal average pixel countrate
h.Mia_Image.Settings.ROI_AR_Int_Min(2) = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',11,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies min pixel countrate' 10 'averaged over all frames'],...
    'Position',[0.63 0.52, 0.11 0.06],...
    'Visible', 'off',...
    'Callback',{@Mia_Correct,1},...
    'String',num2str(UserValues.MIA.AR_Int(2)));
%%% Maximal average pixel countrate
h.Mia_Image.Settings.ROI_AR_Int_Max(1) = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',11,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies max pixel countrate' 10 'averaged over all frames'],...
    'Position',[0.76 0.52, 0.11 0.06],...
    'Visible', 'off',...
    'Callback',{@Mia_Correct,1},...
    'String',num2str(UserValues.MIA.AR_Int(3)));
%%% Maximal average pixel countrate
h.Mia_Image.Settings.ROI_AR_Int_Max(2) = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',11,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies max pixel countrate' 10 'averaged over all frames'],...
    'Position',[0.87 0.52, 0.11 0.06],...
    'Visible', 'off',...
    'Callback',{@Mia_Correct,1},...
    'String',num2str(UserValues.MIA.AR_Int(4)));
%%% Text
h.Mia_Image.Settings.ROI_AR_Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies the sliding windows used' 10 'for intensity\variance thresholding' 10 'for arbitrary region ICS'],...
    'Position',[0.02 0.45, 0.72 0.06],...
    'Visible', 'off',...
    'String','Subregions [px]:');
%%% Smaller subregion
h.Mia_Image.Settings.ROI_AR_Sub1 = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies the smaller sliding window used' 10 'for intensity\variance thresholding' 10 'for arbitrary region ICS'],...
    'Position',[0.56 0.45, 0.2 0.06],...
    'Visible', 'off',...
    'Callback',{@Mia_Correct,1},...
    'String',num2str(UserValues.MIA.AR_Region(1)));
%%% Larger subregion
h.Mia_Image.Settings.ROI_AR_Sub2 = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies the larger sliding window used' 10 'for intensity\variance thresholding' 10 'for arbitrary region ICS'],...
    'Position',[0.78 0.45, 0.2 0.06],...
    'Visible', 'off',...
    'Callback',{@Mia_Correct,1},...
    'String',num2str(UserValues.MIA.AR_Region(2)));
%%% Text
h.Mia_Image.Settings.ROI_AR_Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies min\max intensity ratio' 10 'of subregions specified above'],...
    'Position',[0.02 0.38, 0.72 0.06],...
    'Visible', 'off',...
    'String','Intensity [Fold]:');
%%% Minimal intensity ratio of subregions
h.Mia_Image.Settings.ROI_AR_Int_Fold_Min = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies min intensity ratio' 10 'of subregions specified above'],...
    'Position',[0.56 0.38, 0.2 0.06],...
    'Visible', 'off',...
    'Callback',{@Mia_Correct,1},...
    'String',num2str(UserValues.MIA.AR_Int_Fold(1)));
%%% Maximal intensity ratio of subregions
h.Mia_Image.Settings.ROI_AR_Int_Fold_Max = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies max intensity ratio' 10 'of subregions specified above'],...
    'Position',[0.78 0.38, 0.2 0.06],...
    'Visible', 'off',...
    'Callback',{@Mia_Correct,1},...
    'String',num2str(UserValues.MIA.AR_Int_Fold(2)));
%%% Text
h.Mia_Image.Settings.ROI_AR_Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies min\max variance ratio' 10 'of subregions specified above'],...
    'Position',[0.02 0.31, 0.72 0.06],...
    'Visible', 'off',...
    'String','Variance [Fold]:');
%%% Minimal variance ratio of subregions
h.Mia_Image.Settings.ROI_AR_Var_Fold_Min = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies min variance ratio' 10 'of subregions specified above'],...
    'Position',[0.56 0.31, 0.2 0.06],...
    'Visible', 'off',...
    'Callback',{@Mia_Correct,1},...
    'String',num2str(UserValues.MIA.AR_Var_Fold(1)));
%%% Maximal variance ratio of subregions
h.Mia_Image.Settings.ROI_AR_Var_Fold_Max = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'TooltipString',['Specifies max variance ratio' 10 'of subregions specified above'],...
    'Position',[0.78 0.31, 0.2 0.06],...
    'Visible', 'off',...
    'Callback',{@Mia_Correct,1},...
    'String',num2str(UserValues.MIA.AR_Var_Fold(2)));
%%% Same AR for both channels
h.Mia_Image.Settings.ROI_AR_Same = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','popup',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Value',1,...
    'Position',[0.02 0.24, 0.64 0.06],...
    'Visible', 'off',...
    'Callback',{@Mia_Correct,1},...
    'String',{'Individual Channels', 'Channel1','Channel2','Both'});
if ismac
    h.Mia_Image.Settings.ROI_AR_Same.ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.ROI_AR_Same.BackgroundColor = [1 1 1];
end
h.Mia_Image.Settings.ROI_AR_Spatial_Int = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',0,...
    'Callback', {@Mia_Correct,1},...
    'Visible', 'off',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.18, 0.5 0.06],...
    'TooltipString',['Do spatial absolute intensity' 10 'thresholding in the small sub-ROI' 10 'instead of over all frames.' 10 'the code considers photobleaching'],...
    'String','Framewise Int. Threshold');
h.Mia_Image.Settings.ROI_AR_median = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',0,...
    'Callback', {@Mia_Correct,1},...
    'Visible', 'off',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.62 0.18, 0.3 0.06],...
    'TooltipString',['median filter the ROI' 10, 'in a square region' 10 'with small subROI size'],...
    'String','Median Filter');

%%%Button to Store ROI count rate as background
h.Mia_Image.Settings.GetBG = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Tab,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.1, 0.5 0.06],...
    'Callback',{@MIA_Various,4},...
    'String','Get background from ROI');

%%% Editbox to select, which frames to correlate
h.Mia_Image.Settings.Background(1) = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.55 0.1, 0.2 0.06],...
    'String','0',...
    'Callback',{@Mia_Correct,1},...
    'ToolTipString', 'Background channel 1 in counts per dwell time');
%%% Editbox to select, which frames to correlate
h.Mia_Image.Settings.Background(2) = uicontrol(...
    'Parent', h.Mia_Image.Settings.ROI_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.75 0.1, 0.2 0.06],...
    'String','0',...
    'Callback',{@Mia_Correct,1},...
    'ToolTipString', 'Background channel 2 in counts per dwell time');
%% Mia correction tab
%%% Tab and panel for Mia image correction settings UIs
h.Mia_Image.Settings.Correction_Tab= uitab(...
    'Parent',h.Mia_Image.Settings.Tabs,...
    'Tag','MI_Correction_SettingsTab',...
    'Title','Correction');
h.Mia_Image.Settings.Correction_Panel = uibuttongroup(...
    'Parent',h.Mia_Image.Settings.Correction_Tab,...
    'Tag','Mia_Correction_Settings_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Correction_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.92, 0.3 0.06],...
    'String','Subtract:');
%%% Popupmenu to select what to subtract
h.Mia_Image.Settings.Correction_Subtract = uicontrol(...
    'Parent',h.Mia_Image.Settings.Correction_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',UserValues.MIA.Correct_Type(1),...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.34 0.92, 0.64 0.06],...
    'Callback',{@Mia_Correct,1},...
    'String',{'Nothing','Frame mean','Pixel mean','Moving average'});
if ismac
    h.Mia_Image.Settings.Correction_Subtract.ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.Correction_Subtract.BackgroundColor = [1 1 1];
end
%%% Text
h.Mia_Image.Settings.Correction_Subtract_Pixel_Text = uicontrol(...
    'Parent',h.Mia_Image.Settings.Correction_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.84, 0.25 0.06],...
    'Visible','off',...
    'String','Pixel:');
%%% Pixels to average for subtracting moving average
h.Mia_Image.Settings.Correction_Subtract_Pixel = uicontrol(...
    'Parent',h.Mia_Image.Settings.Correction_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.27 0.84, 0.15 0.06],...
    'Callback',{@Mia_Correct,1},...
    'Visible','off',...
    'String',num2str(UserValues.MIA.Correct_Sub_Values(1)));
%%% Text
h.Mia_Image.Settings.Correction_Subtract_Frames_Text = uicontrol(...
    'Parent',h.Mia_Image.Settings.Correction_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.52 0.84, 0.28 0.06],...
    'Visible','off',...
    'String','Frames:');
%%% Pixels to average for subtracting moving average
h.Mia_Image.Settings.Correction_Subtract_Frames = uicontrol(...
    'Parent',h.Mia_Image.Settings.Correction_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.83 0.84, 0.15 0.06],...
    'Callback',{@Mia_Correct,1},...
    'Visible','off',...
    'String',num2str(UserValues.MIA.Correct_Sub_Values(2)));

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Correction_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.7, 0.3 0.06],...
    'String','Add:');
%%% Popupmenu to select what to subtract
h.Mia_Image.Settings.Correction_Add = uicontrol(...
    'Parent',h.Mia_Image.Settings.Correction_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',UserValues.MIA.Correct_Type(2),...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.34 0.7, 0.64 0.06],...
    'Callback',{@Mia_Correct,1},...
    'String',{'Nothing','Total mean','Frame mean','Pixel mean','Moving average'});
if ismac
    h.Mia_Image.Settings.Correction_Add.ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.Correction_Add.BackgroundColor = [1 1 1];
end
%%% Text
h.Mia_Image.Settings.Correction_Add_Pixel_Text = uicontrol(...
    'Parent',h.Mia_Image.Settings.Correction_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.62, 0.25 0.06],...
    'Visible','off',...
    'String','Pixel:');
%%% Pixels to average for subtracting moving average
h.Mia_Image.Settings.Correction_Add_Pixel = uicontrol(...
    'Parent',h.Mia_Image.Settings.Correction_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.27 0.62, 0.15 0.06],...
    'Callback',{@Mia_Correct,1},...
    'Visible','off',...
    'String',num2str(UserValues.MIA.Correct_Add_Values(1)));
%%% Text
h.Mia_Image.Settings.Correction_Add_Frames_Text = uicontrol(...
    'Parent',h.Mia_Image.Settings.Correction_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.52 0.62, 0.28 0.06],...
    'Visible','off',...
    'String','Frames:');
%%% Pixels to average for subtracting moving average
h.Mia_Image.Settings.Correction_Add_Frames = uicontrol(...
    'Parent',h.Mia_Image.Settings.Correction_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.83 0.62, 0.15 0.06],...
    'Callback',{@Mia_Correct,1},...
    'Visible','off',...
    'String',num2str(UserValues.MIA.Correct_Add_Values(2)));
%% Mia image orientation tab
%%% Tab and panel for Mia image orientation settings UIs
h.Mia_Image.Settings.Orientation_Tab= uitab(...
    'Parent',h.Mia_Image.Settings.Tabs,...
    'Tag','MI_Orientation_SettingsTab',...
    'Title','Options');
h.Mia_Image.Settings.Orientation_Panel = uibuttongroup(...
    'Parent',h.Mia_Image.Settings.Orientation_Tab,...
    'Tag','Mia_Orientation_Settings_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Orientation_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.9, 0.9 0.06],...
    'String','Change Orientation of Channel 2');
%%% pushbutton for horizontal mirroring
h.Mia_Image.Settings.Orientation_Flip_Hor = uicontrol(...
    'Parent',h.Mia_Image.Settings.Orientation_Panel,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Mia_Orientation,1},...
    'Value',0,...
    'Position',[0.02 0.83, 0.47 0.06],...
    'String','Flip Horizontally');
%%% pushbutton for vertical mirroring
h.Mia_Image.Settings.Orientation_Flip_Ver = uicontrol(...
    'Parent',h.Mia_Image.Settings.Orientation_Panel,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Mia_Orientation,2},...
    'Value',0,...
    'Position',[0.02 0.75, 0.47 0.06],...
    'String','Flip Vertically');
%%% pushbutton for rotation
h.Mia_Image.Settings.Orientation_Rotate = uicontrol(...
    'Parent',h.Mia_Image.Settings.Orientation_Panel,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Mia_Orientation,3},...
    'Value',0,...
    'Position',[0.02 0.67, 0.47 0.06],...
    'String','Rotate');

%%% Popupmenu for rotation direction
h.Mia_Image.Settings.Orientation_Rotate_Dir = uicontrol(...
    'Parent',h.Mia_Image.Settings.Orientation_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'clockwise','counterclockwise'},...
    'Value',1,...
    'Position',[0.51 0.685, 0.41 0.05] );
if ismac
    h.Mia_Image.Settings.Orientation_Rotate_Dir.ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.Orientation_Rotate_Dir.BackgroundColor = [1 1 1];
end

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Orientation_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.56, 0.9 0.06],...
    'String','Custom Filetype:');

%%% Allows custom Filetype selection
if ~isdeployed
    Customdir = [PathToApp filesep 'functions' filesep 'MIA' filesep 'ReadIN'];
    if ~(exist(Customdir,'dir') == 7)
        mkdir(Customdir);
    end
    %%% Finds all matlab files in profiles directory
    Custom_Methods = what(Customdir);
    Custom_Methods = ['none'; Custom_Methods.m(:)];
    Custom_Value = 1;
    for i=2:numel(Custom_Methods)
        Custom_Methods{i}=Custom_Methods{i}(1:end-2);
        if strcmp(Custom_Methods{i},UserValues.File.MIA_Custom_Filetype)
            Custom_Value = i;
        end
    end
else
    %%% compiled application
    %%% custom file types are embedded
    %%% names are in associated text file
    fid = fopen([PathToApp filesep 'Custom_Read_Ins_MIA.txt'],'rt');
    if fid == -1
        disp('No Custom Read-In routines defined. Missing file Custom_Read_Ins.txt');
        Custom_Methods = {'none'};
        Custom_Value = 1;
    else % read file
        % skip the first three lines (header)
        for i = 1:3
            tline = fgetl(fid);
        end
        Custom_Methods = {'none'};
        Custom_Value = 1;
        while ischar(tline)
            tline = fgetl(fid);
            if ischar(tline)
                Custom_Methods{end+1,1} = tline;
            end
        end
        for i=2:numel(Custom_Methods)
            if strcmp(Custom_Methods{i},UserValues.File.MIA_Custom_Filetype)
                Custom_Value = i;
            end
        end
    end
end

%%% Creates objects for custom filetype settings
h.Mia_Image.Settings.FileType = uicontrol(...
    'Parent',h.Mia_Image.Settings.Orientation_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String', Custom_Methods,...
    'UserData',{[],[],[]},...
    'Value',Custom_Value,...
    'Callback',{@MIA_CustomFileType,1},...
    'Position',[0.02 0.48, 0.41 0.05] );
if ismac
    h.Mia_Image.Settings.FileType.ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.FileType.BackgroundColor = [1 1 1];
end
MIA_CustomFileType(h.Mia_Image.Settings.FileType,[],1);
h.Mia_Image.Settings.Custom = h.Mia_Image.Settings.FileType.UserData{3};

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Orientation_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.16, 0.15 0.06],...
    'String','S:');
% editbox for variance-intensity slope
h.Mia_Image.Settings.S = uicontrol(...
    'Tag','h.Mia_Image.Settings.S',...
    'Parent',h.Mia_Image.Settings.Orientation_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String', num2str(UserValues.MIA.Options.S),...
    'Callback',{@Mia_Orientation,4},...
    'Position',[0.20 0.18, 0.3 0.05],...
    'Tooltipstring','Variance vs Intensity slope for a sample without concentration fluctuations');

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_Image.Settings.Orientation_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.06, 0.15 0.06],...
    'String','Offset:');
% editbox for offset ("what is the intensity if you extrapolate to variance zero")
h.Mia_Image.Settings.Offset = uicontrol(...
    'Tag','h.Mia_Image.Settings.Offset',...
    'Parent',h.Mia_Image.Settings.Orientation_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',num2str(UserValues.MIA.Options.Offset),...
    'Callback',{@Mia_Orientation,4},...
    'Position',[0.20 0.08, 0.3 0.05],...
    'Tooltipstring','Extrapolated Intensity at zero variance for a sample without concentration fluctuations');

%% Calculations tab container
h.Mia_Image.Calculations_Panel = uibuttongroup(...
    'Parent',h.Mia_Image.Tab,...
    'Tag','Mia_Calculations_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.8 0 0.2 0.5]);
h.Mia_Image.Calculations_Tabs = uitabgroup(...
    'Parent',h.Mia_Image.Calculations_Panel,...
    'Tag','Mia_Calculations_Tabs',...
    'Units','normalized',...
    'Position',[0 0 1 1]);

%% Perform correlation tab
%%% Tab and panel for perform correlation UIs
h.Mia_Image.Calculations.Cor_Tab= uitab(...
    'Parent',h.Mia_Image.Calculations_Tabs,...
    'Tag','MI_Image_Tab',...
    'Title','Correlate');
h.Mia_Image.Calculations.Cor_Panel = uibuttongroup(...
    'Parent',h.Mia_Image.Calculations.Cor_Tab,...
    'Tag','Mia_Calculations_Cor_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Select, what to correlate
h.Mia_Image.Calculations.Cor_Type = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Cor_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.92, 0.96 0.06],...
    'String',{'ACF1','ACF2','ACFs+CCF'});
if ismac
    h.Mia_Image.Calculations.Cor_Type.ForegroundColor = [0 0 0];
    h.Mia_Image.Calculations.Cor_Type.BackgroundColor = [1 1 1];
end
%%% Button to start image correlation
h.Mia_Image.Calculations.Cor_Do_ICS = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Cor_Panel,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.82, 0.47 0.06],...
    'Callback',{@Do_2D_XCor,1},...
    'String','Do (R)ICS');
%%% Selects data saving procedure
h.Mia_Image.Calculations.Cor_Save_ICS = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Cor_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.51 0.82, 0.47 0.06],...
    'String',{'Do not save','Save as .miacor','Save as TIFF', 'Save blockwise analysis as .miacor'});
if ismac
    h.Mia_Image.Settings.ROI_AR_Same.ForegroundColor = [0 0 0];
    h.Mia_Image.Settings.ROI_AR_Same.BackgroundColor = [1 1 1];
    h.Mia_Image.Calculations.Cor_Save_ICS.ForegroundColor = [0 0 0];
    h.Mia_Image.Calculations.Cor_Save_ICS.BackgroundColor = [1 1 1];
end
%%% Button to start temporal image correlation
h.Mia_Image.Calculations.Cor_Do_TICS = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Cor_Panel,...
    'Style','push',...
    'Tag', 'DoTICS',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.72, 0.47 0.06],...
    'Callback',@Do_1D_XCor,...
    'String','Do TICS');
%%% Selects data saving procedure
h.Mia_Image.Calculations.Cor_Save_TICS = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Cor_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.51 0.72, 0.47 0.06],...
    'String',{'Do not save','Save as .mcor'});
if ismac
    h.Mia_Image.Calculations.Cor_Save_TICS.ForegroundColor = [0 0 0];
    h.Mia_Image.Calculations.Cor_Save_TICS.BackgroundColor = [1 1 1];
end
%%% Button to start spatio-temporal correlation
h.Mia_Image.Calculations.Cor_Do_STICS = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Cor_Panel,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.62, 0.47 0.06],...
    'Callback',@Do_3D_XCor,...
    'String','Do STICS/iMSD');
%%% Selects data saving procedure
h.Mia_Image.Calculations.Cor_Save_STICS = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Cor_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.51 0.62, 0.47 0.06],...
    'String',{'Do not save','Save as iMSD(.mcor)','Save as STICS (.stcor)','Both'});
if ismac
    h.Mia_Image.Calculations.Cor_Save_STICS.ForegroundColor = [0 0 0];
    h.Mia_Image.Calculations.Cor_Save_STICS.BackgroundColor = [1 1 1];
end
h.Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Cor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.54, 0.76 0.06],...
    'String','Window [Frames]:');
%%% Edit box to choose the n.o. lags to calculate (STICS) or the window size (RICS)
h.Mia_Image.Calculations.Cor_ICS_Window = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Cor_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.78 0.54, 0.2 0.06],...
    'String','20');
h.Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Cor_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.44, 0.76 0.06],...
    'String','Offset [Frames]:');
%%% Edit box to choose the n.o. frames to slide from one window to the other (RICS)
h.Mia_Image.Calculations.Cor_ICS_Offset = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Cor_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.78 0.44, 0.2 0.06],...
    'String','20');
%%% Checkbox to switch between automatic\manual filenames
h.Mia_Image.Calculations.Save_Name = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Cor_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',UserValues.MIA.AutoNames,...
    'Callback', @(src,event) LSUserValues(1,src,{'Value','MIA','AutoNames'}),...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.36, 0.7 0.06],...
    'String','Use automatic filename');
%% Perform N&B calculation tab
%%% Tab and panel for perform correlation UIs
h.Mia_Image.Calculations.NB_Tab= uitab(...
    'Parent',h.Mia_Image.Calculations_Tabs,...
    'Title','Do N&B');
h.Mia_Image.Calculations.NB_Panel = uibuttongroup(...
    'Parent',h.Mia_Image.Calculations.NB_Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%% Button to start N&B calculation
h.Mia_Image.Calculations.NB_Do = uicontrol(...
    'Parent', h.Mia_Image.Calculations.NB_Panel,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.92, 0.96 0.06],...
    'Callback',@Do_NB,...
    'String','Calculate N&B');
%%% Popupmenu to select for which channels to calculate
h.Mia_Image.Calculations.NB_Type = uicontrol(...
    'Parent', h.Mia_Image.Calculations.NB_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.84, 0.4 0.06],...
    'String',{'Channel1','Channel2','Cross'});
if ismac
    h.Mia_Image.Calculations.NB_Type.ForegroundColor = [0 0 0];
    h.Mia_Image.Calculations.NB_Type.BackgroundColor = [1 1 1];
end
%%% Popupmenu to select averaging style
h.Mia_Image.Calculations.NB_Average = uicontrol(...
    'Parent', h.Mia_Image.Calculations.NB_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',2,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.76, 0.4 0.06],...
    'String',{'None','Average','Disk','Gaussian'},...
    'Tooltipstring','apply an averaging filter to the intensity and variance images');
if ismac
    h.Mia_Image.Calculations.NB_Average.ForegroundColor = [0 0 0];
    h.Mia_Image.Calculations.NB_Average.BackgroundColor = [1 1 1];
end
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Calculations.NB_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.44 0.745, 0.26 0.06],...
    'String','Radius:');
%%% Editbox for Averaging radius
h.Mia_Image.Calculations.NB_Average_Radius = uicontrol(...
    'Parent', h.Mia_Image.Calculations.NB_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.72 0.75, 0.15 0.06],...
    'String','3',...
    'Tooltipstring','sets the radius for the averaging and median filtering');
%%% Checkboxbox for Median filter
h.Mia_Image.Calculations.NB_Median = uicontrol(...
    'Parent', h.Mia_Image.Calculations.NB_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.68, 0.35 0.06],...
    'String','Median filter',...
    'Tooltipstring','apply a median filter to the N and epsilon images');
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Calculations.NB_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.60, 0.8 0.06],...
    'String','Detector Dead time [ns]:');
%%% Editbox for Deadtime correction
h.Mia_Image.Calculations.NB_Detector_Deadtime = uicontrol(...
    'Parent', h.Mia_Image.Calculations.NB_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.7 0.60, 0.22 0.06],...
    'String','100');

%% Perform FRET tab
%%% Tab and panel for perform correlation UIs
h.Mia_Image.Calculations.FRET_Tab= uitab(...
    'Parent',h.Mia_Image.Calculations_Tabs,...
    'Tag','MI_Image_Tab',...
    'Title','FRET');
h.Mia_Image.Calculations.FRET_Panel = uibuttongroup(...
    'Parent',h.Mia_Image.Calculations.FRET_Tab,...
    'Tag','Mia_Calculations_FRET_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Select, which FRET method to use
h.Mia_Image.Calculations.FRET_Type = uicontrol(...
    'Parent', h.Mia_Image.Calculations.FRET_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.92, 0.96 0.06],...
    'String',{'norm A/D','A/D','Fc (Youvan)', 'FRETN (Gordon)', 'N-FRET (Xia)'});
if ismac
    h.Mia_Image.Calculations.FRET_Type.ForegroundColor = [0 0 0];
    h.Mia_Image.Calculations.FRET_Type.BackgroundColor = [1 1 1];
end
%%% Button to start FRET calculation
h.Mia_Image.Calculations.DoFRET = uicontrol(...
    'Parent', h.Mia_Image.Calculations.FRET_Panel,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.72, 0.47 0.06],...
    'Callback',@Do_FRET,...
    'String','Do FRET');
%%% Selects data saving procedure
h.Mia_Image.Calculations.Save_FRET = uicontrol(...
    'Parent', h.Mia_Image.Calculations.FRET_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.51 0.72, 0.47 0.06],...
    'String',{'Do not save','Save'});
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Calculations.FRET_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.82, 0.4 0.06],...
    'String','Normalize on frames:');
%%% Editbox for Averaging radius
h.Mia_Image.Calculations.FRET_norm = uicontrol(...
    'Parent', h.Mia_Image.Calculations.FRET_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.52 0.82, 0.15 0.06],...
    'String','1:5',...
    'Tooltipstring','normalizes the FRET data on frames n:m');
if ismac
    h.Mia_Image.Calculations.Save_FRET.ForegroundColor = [0 0 0];
    h.Mia_Image.Calculations.Save_FRET.BackgroundColor = [1 1 1];
end

%% Perform Colocalization tab
%%% Tab and panel for perform correlation UIs
h.Mia_Image.Calculations.Coloc_Tab= uitab(...
    'Parent',h.Mia_Image.Calculations_Tabs,...
    'Tag','MI_Image_Tab',...
    'Title','Colocalization');
h.Mia_Image.Calculations.Coloc_Panel = uibuttongroup(...
    'Parent',h.Mia_Image.Calculations.Coloc_Tab,...
    'Tag','Mia_Calculations_Coloc_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Select, which Coloc method to use
h.Mia_Image.Calculations.Coloc_Type = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Coloc_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.92, 0.5 0.06],...
    'String',{'Pearson','Manders', 'Costes', 'Van Steensel', 'Li', 'object-based'});
if ismac
    h.Mia_Image.Calculations.Coloc_Type.ForegroundColor = [0 0 0];
    h.Mia_Image.Calculations.Coloc_Type.BackgroundColor = [1 1 1];
end

%%% Checkboxbox for intensity weighting
h.Mia_Image.Calculations.Coloc_weighting = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Coloc_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.82, 0.5 0.06],...
    'String','Intensity weighted',...
    'Tooltipstring','Calculate the colocalization using intensity-weighting. Option doesn`t work yet!');
h.Text{end+1} = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Coloc_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.72, 0.3 0.06],...
    'String','Averaging diameter:');
%%% Editbox for Averaging radius
h.Mia_Image.Calculations.Coloc_avg = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Coloc_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.52 0.72, 0.15 0.06],...
    'String','3',...
    'Tooltipstring','size of the square subregion for calculating the square');

h.Mia_Image.Calculations.Coloc_avg.Visible = 'off';
h.Text{end}.Visible = 'off';

%%% Button to start Coloc calculation
h.Mia_Image.Calculations.DoColoc = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Coloc_Panel,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.62, 0.3 0.06],...
    'Callback',@Do_Coloc,...
    'Tooltipstring','Calculate the colocalization using the top right AROI',...
    'String','Analyze');
%%% Selects data saving procedure
h.Mia_Image.Calculations.Save_Coloc = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Coloc_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.35 0.62, 0.47 0.06],...
    'String',{'Do not save','Save as .miacor'});
%% mean Pearson's coefficient
h.Mia_Image.Calculations.Coloc_Pearsons = uicontrol(...
    'Parent', h.Mia_Image.Calculations.Coloc_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.47, 0.96 0.1],...
    'String','mean Pearson`s: ',...
    'ToolTipString', 'Pearsons correlation coefficient/nfor the corrected images within the AROI');% %%% Text
if ismac
    h.Mia_Image.Calculations.Save_Coloc.ForegroundColor = [0 0 0];
    h.Mia_Image.Calculations.Save_Coloc.BackgroundColor = [1 1 1];
end

%% Additional Properties Tab
s.ProgressRatio = 0.15;
h.Mia_Additional.Tab = uitab(...
    'Parent',h.Mia_Main_Tabs,...
    'Title','Additional Information',...
    'Units','normalized');
h.Mia_Additional.Panel = uibuttongroup(...
    'Parent',h.Mia_Additional.Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Axes to display additional plots
h.Mia_Additional.Axes(1)= axes(...
    'Parent',h.Mia_Additional.Panel,...
    'Units','normalized',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'Nextplot','Add',...
    'Position',[0.21 0.55 0.3 0.4]);
h.Plots.Additional_Axes(1,1) = line(...
    'Parent',h.Mia_Additional.Axes(1),...
    'XData',[0 1],...
    'YData', [0 0],...
    'Color',[0 0.6 0]);
h.Plots.Additional_Axes(1,2) = line(...
    'Parent',h.Mia_Additional.Axes(1),...
    'XData',[0 1],...
    'YData', [0 0],...
    'Color',[1 0 0],...
    'Visible','off');
h.Mia_Additional.Axes(1).XLabel.String = 'Frame';
h.Mia_Additional.Axes(1).YLabel.String = 'Average Counts';
h.Mia_Additional.Axes(1).XLabel.Color = Look.Fore;
h.Mia_Additional.Axes(1).YLabel.Color = Look.Fore;
h.Mia_Additional.Axes(1).YLabel.UserData = 0;
h.Mia_Additional.Axes(1).YLabel.ButtonDownFcn = {@MIA_Various,[1 2]};
h.Mia_Additional.Axes(1).XLabel.UserData = 1;
h.Mia_Additional.Axes(1).XLabel.ButtonDownFcn = {@MIA_Various,[1 2]};

h.Mia_Additional.Plot_Popup(1,1) = uicontrol(...
    'Parent',h.Mia_Additional.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.92, 0.1 0.03],...
    'Callback',{@Update_Plots,4,[1 2]},...
    'String',{'Intensity';'Variance';'PCH'});
h.Mia_Additional.Plot_Popup(1,2) = uicontrol(...
    'Parent',h.Mia_Additional.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',2,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.12 0.92, 0.05 0.03],...
    'Callback',{@Update_Plots,4,[1 2]},...
    'String',{'Frame';'ROI'});
if ismac
    h.Mia_Additional.Plot_Popup(1,1).ForegroundColor = [0 0 0];
    h.Mia_Additional.Plot_Popup(1,1).BackgroundColor = [1 1 1];
    h.Mia_Additional.Plot_Popup(1,2).ForegroundColor = [0 0 0];
    h.Mia_Additional.Plot_Popup(1,2).BackgroundColor = [1 1 1];
end

h.Mia_Additional.Axes(2)= axes(...
    'Parent',h.Mia_Additional.Panel,...
    'Units','normalized',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'Nextplot','Add',...
    'Position',[0.21 0.07 0.3 0.4]);
h.Plots.Additional_Axes(2,1) = line(...
    'Parent',h.Mia_Additional.Axes(2),...
    'XData',[0 1],...
    'YData', [0 0],...
    'Color',[0 0.6 0]);
h.Plots.Additional_Axes(2,2) = line(...
    'Parent',h.Mia_Additional.Axes(2),...
    'XData',[0 1],...
    'YData', [0 0],...
    'Color',[1 0 0],...
    'Visible','off');
h.Mia_Additional.Axes(2).XLabel.String = 'Counts';
h.Mia_Additional.Axes(2).YLabel.String = 'Frequency';
h.Mia_Additional.Axes(2).XLabel.Color = Look.Fore;
h.Mia_Additional.Axes(2).YLabel.Color = Look.Fore;
h.Mia_Additional.Axes(2).YLabel.UserData = 1;
h.Mia_Additional.Axes(2).YLabel.ButtonDownFcn = {@MIA_Various,[1 2]};
h.Mia_Additional.Axes(2).XLabel.UserData = 1;
h.Mia_Additional.Axes(2).XLabel.ButtonDownFcn = {@MIA_Various,[1 2]};

h.Mia_Additional.Plot_Popup(2,1) = uicontrol(...
    'Parent',h.Mia_Additional.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',3,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.44, 0.1 0.03],...
    'Callback',{@Update_Plots,4,[1 2]},...
    'String',{'Intensity';'Variance';'PCH' });
h.Mia_Additional.Plot_Popup(2,2) = uicontrol(...
    'Parent',h.Mia_Additional.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',2,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.12 0.44, 0.05 0.03],...
    'Callback',{@Update_Plots,4,[1 2]},...
    'String',{'Frame';'ROI'});
if ismac
    h.Mia_Additional.Plot_Popup(2,1).ForegroundColor = [0 0 0];
    h.Mia_Additional.Plot_Popup(2,1).BackgroundColor = [1 1 1];
    h.Mia_Additional.Plot_Popup(2,2).ForegroundColor = [0 0 0];
    h.Mia_Additional.Plot_Popup(2,2).BackgroundColor = [1 1 1];
end

%%% Axes to display images
h.Mia_Additional.Image(1,1)= axes(...
    'Parent',h.Mia_Additional.Panel,...
    'Units','normalized',...
    'ButtonDownFcn',{@Mia_ROI,2},...
    'Position',[0.65 0.55 0.34 0.4]);
h.Plots.Additional_Image(1)=imagesc(...
    zeros(1,1,1),...
    'Parent',h.Mia_Additional.Image(1),...
    'ButtonDownFcn',{@Mia_ROI,2});
h.Mia_Additional.Image(1).DataAspectRatio=[1 1 1];
h.Mia_Additional.Image(1).XTick=[];
h.Mia_Additional.Image(1).YTick=[];
colormap(h.Mia_Additional.Image(1),gray);
h.Mia_Additional.Image(1,2) = colorbar(h.Mia_Additional.Image(1));
h.Mia_Additional.Image(1,2).YColor = Look.Fore;

h.Plots.ROI(3)=rectangle(...
    'Parent',h.Mia_Additional.Image(1),...
    'Position',[0.5 0.5 1 1],...
    'EdgeColor',[1 1 1],...
    'HitTest','off');

h.Mia_Additional.Plot_Popup(1,3) = uicontrol(...
    'Parent',h.Mia_Additional.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.53 0.92, 0.1 0.03],...
    'Callback',{@Update_Plots,4,[1 2]},...
    'String',{'Intensity';'Variance';'Max Projection'});

h.Mia_Additional.Image(2,1)= axes(...
    'Parent',h.Mia_Additional.Panel,...
    'Units','normalized',...
    'Position',[0.65 0.07 0.34 0.4]);
h.Plots.Additional_Image(2)=imagesc(...
    zeros(1,1,1),...
    'Parent',h.Mia_Additional.Image(2),...
    'ButtonDownFcn',{@Mia_ROI,2});
h.Mia_Additional.Image(2).DataAspectRatio=[1 1 1];
h.Mia_Additional.Image(2).XTick=[];
h.Mia_Additional.Image(2).YTick=[];
colormap(h.Mia_Additional.Image(2),gray);
h.Mia_Additional.Image(2,2) = colorbar(h.Mia_Additional.Image(2));
h.Mia_Additional.Image(2,2).YColor = Look.Fore;

h.Plots.ROI(4)=rectangle(...
    'Parent', h.Mia_Additional.Image(2),...
    'Position',[0.5 0.5 1 1],...
    'EdgeColor',[1 1 1],...
    'HitTest','off');

h.Mia_Additional.Plot_Popup(2,3) = uicontrol(...
    'Parent',h.Mia_Additional.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.53 0.44, 0.1 0.03],...
    'Callback',{@Update_Plots,4,[1 2]},...
    'String',{'Intensity';'Variance';'Max Projection'; 'Both Colors'; 'Ratio'; 'Ratio (Normalized)'});
if ismac
    h.Mia_Additional.Plot_Popup(1,3).ForegroundColor = [0 0 0];
    h.Mia_Additional.Plot_Popup(1,3).BackgroundColor = [1 1 1];
    h.Mia_Additional.Plot_Popup(2,3).ForegroundColor = [0 0 0];
    h.Mia_Additional.Plot_Popup(2,3).BackgroundColor = [1 1 1];
end

%% (R)ICS Tab
s.ProgressRatio = 0.35;
h.Mia_ICS.Tab = uitab(...
    'Parent',h.Mia_Main_Tabs,...
    'Title','(R)ICS',...
    'Tag','Mia_Cor_Tabs',...
    'Units','normalized');
h.Mia_ICS.Panel = uibuttongroup(...
    'Parent',h.Mia_ICS.Tab,...
    'Tag','Mia_Cor_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_ICS.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.95, 0.045 0.03],...
    'String','Size');
%%% Editbox for correlation size
h.Mia_ICS.Size = uicontrol(...
    'Parent',h.Mia_ICS.Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Update_Plots,2,1:3},...
    'Position',[0.06 0.95, 0.03 0.03],...
    'String','31');
%%% Colormap selection for correlations
h.Mia_ICS.Cor_Colormap = uicontrol(...
    'Parent',h.Mia_ICS.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'UserData',[1 0 0],...
    'Callback',{@Update_Plots,2,1:3},...
    'ButtonDownFcn',{@Mia_Color,1},...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Value',2,...
    'Position',[0.1 0.95, 0.08 0.03],...
    'String',{'Gray','Jet','Hot','HSV','Custom'});
if ismac
    h.Mia_ICS.Cor_Colormap.ForegroundColor = [0 0 0];
    h.Mia_ICS.Cor_Colormap.BackgroundColor = [1 1 1];
end
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_ICS.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.91, 0.045 0.03],...
    'String','Frame:');
%%% Editbox for frame
h.Mia_ICS.Frame = uicontrol(...
    'Parent',h.Mia_ICS.Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Mia_Frame,3,1:3},...
    'Position',[0.06 0.91, 0.03 0.03],...
    'String','0');
%%% Slider for frame
h.Mia_ICS.Frame_Slider = uicontrol(...
    'Parent',h.Mia_ICS.Panel,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'UserData',[4,i],...
    'Position',[0.1 0.91, 0.08 0.03]);
h.Mia_ICS.Frame_Listener=addlistener(h.Mia_ICS.Frame_Slider,'Value','PostSet',@Mia_Frame);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_ICS.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.87, 0.1 0.03],...
    'String','Frames to use:');
%%% Editbox for frames to use
h.Mia_ICS.Frames2Use = uicontrol(...
    'Parent',h.Mia_ICS.Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Update_Plots,2,1:3},...
    'Position',[0.12 0.87, 0.03 0.03],...
    'String','0');

%%% RICS Fit table
h.Mia_ICS.Fit_Table = uitable(...
    'Parent',h.Mia_ICS.Panel,...
    'Units','normalized',...
    'FontSize',8,...
    'BackgroundColor', [Look.Table1;Look.Table2],...
    'ForegroundColor', Look.TableFore,...
    'ColumnName',{'ACF1','CCF','ACF2'},...
    'ColumnWidth',num2cell([40,40,40]),...
    'ColumnEditable',true,...
    'RowName',{'N';'Fix';'D [um2/s]';'Fix';'w_r [um]';'Fix';'w_z [um]';'Fix';'y0';'Fix';'P Size [nm]';'Fix';'P Time [us]';'Fix';'L Time [ms]';'Fix'},...
    'CellEditCallback',{@Update_Plots,2,1:3},...
    'Position',[0.01 0.46, 0.2 0.4]);
Data=cell(16,3);
Data(1,:)={'1'};
Data(3,:)={'10'};
Data(5,:)={'0.2'};
Data(7,:)={'1'};
Data(9,:)={'0'};
Data(11,:)={'40'};
Data(13,:)={'11.11'};
Data(15,:)={'3.33'};
Data([2 4 6 10],:)={false};
Data([6 8 12 14 16],:)={true};
h.Mia_ICS.Fit_Table.Data=Data;

%%% Buttons to fit correlation
h.Mia_ICS.Fit(1) = uicontrol(...
    'Parent',h.Mia_ICS.Panel,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Fit ACF1',...
    'Callback',{@Do_RICS_Fit,1},...
    'Position',[0.01 0.42, 0.06 0.03]);
h.Mia_ICS.Fit(2) = uicontrol(...
    'Parent',h.Mia_ICS.Panel,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Fit CCF',...
    'Callback',{@Do_RICS_Fit,2},...
    'Position',[0.08 0.42, 0.06 0.03]);
h.Mia_ICS.Fit(3) = uicontrol(...
    'Parent',h.Mia_ICS.Panel,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Fit ACF2',...
    'Callback',{@Do_RICS_Fit,3},...
    'Position',[0.15 0.42, 0.06 0.03]);
%%% Pupupmenu, to select, what fit to plot
h.Mia_ICS.Fit_Type = uicontrol(...
    'Parent',h.Mia_ICS.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'Fit surf','Residuals surf','Fit/Residuals','On Axes plot'},...
    'Callback',{@Update_Plots,2,1:3},...
    'Position',[0.01 0.38, 0.1 0.03]);
if ismac
    h.Mia_ICS.Fit_Type.ForegroundColor = [0 0 0];
    h.Mia_ICS.Fit_Type.BackgroundColor = [1 1 1];
end
for i=1:3
    %%% Axes to display correlation images
    h.Mia_ICS.Axes(i,1)= axes(...
        'Parent',h.Mia_ICS.Panel,...
        'Units','normalized',...
        'Position',[0.02+0.25*i 0.67 0.22 0.32]);
    %%% Axes to display correlation surface
    h.Mia_ICS.Axes(i,2)= axes(...
        'Parent',h.Mia_ICS.Panel,...
        'Units','normalized',...
        'Position',[0.02+0.25*i 0.34 0.22 0.32]);
    %%% Axes to display correlation 0 lines
    h.Mia_ICS.Axes(i,4)= axes(...
        'Parent',h.Mia_ICS.Panel,...
        'Units','normalized',...
        'Position',[0.02+0.25*i 0.05 0.22 0.28],...
        'NextPlot','add');
    %%% Axes to display correlation fit surface
    h.Mia_ICS.Axes(i,3)= axes(...
        'Parent',h.Mia_ICS.Panel,...
        'Units','normalized',...
        'Position',[0.02+0.25*i 0.01 0.22 0.32]);
    linkaxes(h.Mia_ICS.Axes(i,1:3), 'xy');
    
    
    %%% Initializes empty plots
    h.Plots.Cor(i,1)=image(zeros(1,1,3),...
        'Parent',h.Mia_ICS.Axes(i,1));
    h.Mia_ICS.Axes(i,1).Color=[0 0 0];
    h.Mia_ICS.Axes(i,1).Visible='off';
    h.Plots.Cor(i,1).Visible='off';
    h.Mia_ICS.Axes(i,1).DataAspectRatio=[1 1 1];
    h.Mia_ICS.Axes(i,1).XTick=[];
    h.Mia_ICS.Axes(i,1).YTick=[];
    h.Plots.Cor(i,2)=surf(zeros(2),zeros(2,2,3),...
        'Parent',h.Mia_ICS.Axes(i,2));
    h.Mia_ICS.Axes(i,2).Visible='off';
    h.Plots.Cor(i,2).Visible='off';
    h.Mia_ICS.Axes(i,2).Color=(Look.Back+0.1)/1.1;
    h.Mia_ICS.Axes(i,2).XColor = Look.Fore;
    h.Mia_ICS.Axes(i,2).YColor = Look.Fore;
    h.Mia_ICS.Axes(i,2).ZColor = Look.Fore;
    h.Mia_ICS.Axes(i,2).XTick=[];
    h.Mia_ICS.Axes(i,2).YTick=[];
    h.Plots.Cor(i,3)=surf(zeros(2),zeros(2,2,3),...
        'Parent',h.Mia_ICS.Axes(i,3));
    h.Mia_ICS.Axes(i,3).Visible='off';
    h.Plots.Cor(i,3).Visible='off';
    h.Mia_ICS.Axes(i,3).XColor = Look.Fore;
    h.Mia_ICS.Axes(i,3).YColor = Look.Fore;
    h.Mia_ICS.Axes(i,3).ZColor = Look.Fore;
    h.Mia_ICS.Axes(i,3).Color=(Look.Back+0.1)/1.1;
    h.Mia_ICS.Axes(i,3).XTick=[];
    h.Mia_ICS.Axes(i,3).YTick=[];
    h.Plots.Cor(i,4)=plot(0,0,...
        'Parent',h.Mia_ICS.Axes(i,4),...
        'Color','b',...
        'LineStyle','none',...
        'Marker','o');
    h.Plots.Cor(i,5)=plot(0,0,...
        'Parent',h.Mia_ICS.Axes(i,4),...
        'Color','b');
    h.Plots.Cor(i,6)=plot(0,0,...
        'Parent',h.Mia_ICS.Axes(i,4),...
        'Color','r',...
        'LineStyle','none',...
        'Marker','o');
    h.Plots.Cor(i,7)=plot(0,0,...
        'Parent',h.Mia_ICS.Axes(i,4),...
        'Color','r');
    h.Mia_ICS.Axes(i,4).Visible='off';
    h.Plots.Cor(i,4).Visible='off';
    h.Plots.Cor(i,5).Visible='off';
    h.Plots.Cor(i,6).Visible='off';
    h.Plots.Cor(i,7).Visible='off';
    h.Mia_ICS.Axes(i,4).XColor = Look.Fore;
    h.Mia_ICS.Axes(i,4).YColor = Look.Fore;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% TICS Tab
s.ProgressRatio = 0.65;
h.Mia_TICS.Tab = uitab(...
    'Parent',h.Mia_Main_Tabs,...
    'Title','TICS',...
    'Units','normalized');
h.Mia_TICS.Panel = uibuttongroup(...
    'Parent',h.Mia_TICS.Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% TICS Fit table
h.Mia_TICS.Fit_Table = uitable(...
    'Parent',h.Mia_TICS.Panel,...
    'Units','normalized',...
    'FontSize',8,...
    'BackgroundColor', [Look.Table1;Look.Table2],...
    'ForegroundColor', Look.TableFore,...
    'ColumnName',{'ACF1','CCF','ACF2'},...
    'ColumnWidth',num2cell([40,40,40]),...
    'ColumnEditable',true,...
    'RowName',{'N';'Fix';'D [um2/s]';'Fix';'w_r [um]';'Fix';'w_z [um]';'Fix';'y0';'Fix';},...
    'CellEditCallback',{@Calc_TICS_Fit,1:3},...
    'Position',[0.01 0.71, 0.18 0.27]);
Data=cell(10,3);
Data(1,:)={'1'};
Data(3,:)={'0.01'};
Data(5,:)={'0.2'};
Data(7,:)={'1'};
Data(9,:)={'0'};
Data([2 4 10],:)={false};
Data([6 8],:)={true};
h.Mia_TICS.Fit_Table.Data=Data;

%%% Buttons to fit correlation
h.Mia_TICS.Fit = uicontrol(...
    'Parent',h.Mia_TICS.Panel,...
    'Style','push',...
    'Tag','Fit',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Fit',...
    'Callback',@Do_TICS_Fit,...
    'Position',[0.01 0.67, 0.04 0.03]);
%%% Button to Save the correlation data to .mcor
h.Mia_TICS.Save = uicontrol(...
    'Parent',h.Mia_TICS.Panel,...
    'Style','push',...
    'Units','normalized',...
    'Tag','Save',...
    'FontSize',14,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Save',...
    'Callback',{@Update_Plots,5,[]},...
    'Position',[0.01 0.63, 0.04 0.03],...
    'ToolTipString', 'Save currently displayed data as .mcor');
%%% Button to Reset thresholds
h.Mia_TICS.Reset = uicontrol(...
    'Parent',h.Mia_TICS.Panel,...
    'Style','push',...
    'Tag','Reset',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Reset',...
    'Callback',{@Update_Plots,5,[]},...
    'Position',[0.01 0.59, 0.04 0.03],...
    'ToolTipString', 'Reset thresholds to their initial values');


%%% Popup to select what to image
h.Mia_TICS.SelectImage = uicontrol(...
    'Parent',h.Mia_TICS.Panel,...
    'Tag','SelectImage',...
    'Style','popup',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'G(1)','Brightness','Counts','Half-Life'},...
    'Callback',{@Update_Plots,5,[]},...
    'Position',[0.01 0.54, 0.06 0.03]);
if ismac
    h.Mia_TICS.SelectImage.ForegroundColor = [0 0 0];
    h.Mia_TICS.SelectImage.BackgroundColor = [1 1 1];
end

%%% Popup to select what to which image the thresholds apply
h.Mia_TICS.SelectCor = uicontrol(...
    'Parent',h.Mia_TICS.Panel,...
    'Style','popup',...
    'Tag','SelectCor',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'ACF1','ACF2','CCF'},...
    'Callback',{@Update_Plots,5,[]},...
    'Position',[0.01 0.51, 0.06 0.03]);
if ismac
    h.Mia_TICS.SelectCor.ForegroundColor = [0 0 0];
    h.Mia_TICS.SelectCor.BackgroundColor = [1 1 1];
end

%%% Editboxes for different thresholds for species selection
    h.Mia_TICS.ThresholdsContainer = uigridcontainer(...
        'GridSize',[5,3],...
        'HorizontalWeight',[0.3,0.2,0.2],... 
        'Parent',h.Mia_TICS.Panel,...
        'Units','norm',...
        'Position',[.08,0.57,0.13,0.13],...
        'BackgroundColor',Look.Back);
    h.Mia_TICS.Threshold_Text = uicontrol('style','text',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'String','Thresholds:',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
     h.Mia_TICS.Threshold_MinText = uicontrol('style','text',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'String','Min',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Mia_TICS.Threshold_MaxText = uicontrol('style','text',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'String','Max',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Mia_TICS.Threshold_G1_Text = uicontrol('style','text',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'String','G(1)',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Mia_TICS.Threshold_G1_Min_Edit = uicontrol('style','edit',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'Tag', 'thresholds',...
        'String',0,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',{@Update_Plots,5,[]});
    h.Mia_TICS.Threshold_G1_Max_Edit = uicontrol('style','edit',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'Tag', 'thresholds',...
        'String',100,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',{@Update_Plots,5,[]});
    h.Mia_TICS.Threshold_brightness_Text = uicontrol('style','text',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'String','Brightness',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Mia_TICS.Threshold_brightness_Min_Edit = uicontrol('style','edit',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'Tag', 'thresholds',...
        'String',0,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',{@Update_Plots,5,[]});
    h.Mia_TICS.Threshold_brightness_Max_Edit = uicontrol('style','edit',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'Tag', 'thresholds',...
        'String',100,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',{@Update_Plots,5,[]});
    h.Mia_TICS.Threshold_counts_Text = uicontrol('style','text',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'String','Counts',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Mia_TICS.Threshold_counts_Min_Edit = uicontrol('style','edit',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'Tag', 'thresholds',...
        'String',0,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',{@Update_Plots,5,[]});
    h.Mia_TICS.Threshold_counts_Max_Edit = uicontrol('style','edit',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'Tag', 'thresholds',...
        'String',100,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',{@Update_Plots,5,[]});
    h.Mia_TICS.Threshold_halflife_Text = uicontrol('style','text',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'String','Half-life',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    h.Mia_TICS.Threshold_halflife_Min_Edit = uicontrol('style','edit',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'Tag', 'thresholds',...
        'String',0,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',{@Update_Plots,5,[]});
    h.Mia_TICS.Threshold_halflife_Max_Edit = uicontrol('style','edit',...
        'Parent',h.Mia_TICS.ThresholdsContainer,...
        'Tag', 'thresholds',...
        'String',100,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'FontSize',12,...
        'Callback',{@Update_Plots,5,[]});

%%% Axes to display correlation
h.Mia_TICS.Axes = axes(...
    'Parent',h.Mia_TICS.Panel,...
    'Units','normalized',...
    'NextPlot','Add',...
    'Position',[0.24 0.59 0.74 0.38]);

%%% UIContextMenus for TICS freehand selection
h.Mia_TICS.Menu = uicontextmenu;
h.Mia_TICS.Select_Manual_ROI = uimenu(...
    'Parent',h.Mia_TICS.Menu,...
    'Label','Select manual ROI',...
    'Callback',{@Mia_Freehand,4});
h.Mia_TICS.Unselect_Manual_ROI = uimenu(...
    'Parent',h.Mia_TICS.Menu,...
    'Label','Unselect manual ROI',...
    'Callback',{@Mia_Freehand,5});
h.Mia_TICS.Clear_Manual_ROI = uimenu(...
    'Parent',h.Mia_TICS.Menu,...
    'Label','Clear manual ROI',...
    'Callback',{@Mia_Freehand,6});
for i=1:3
    h.Plots.TICS(i,1) = errorbar(...
        [0.1 1],...
        [0 0],...
        [0 0],...
        [0 0],...
        'Parent',h.Mia_TICS.Axes,...
        'LineStyle','none',...
        'Marker','.',...
        'MarkerSize',8,...
        'Color',ceil([mod(i-1,3)/2 mod(3-i,3)/2 0]));
    h.Plots.TICS(i,2) = line(...
        'Parent',h.Mia_TICS.Axes,...
        'XData',[0.1 1],...
        'YData',[0 0],...
        'LineStyle','-',...
        'Marker','none',...
        'MarkerSize',8,...
        'Color',ceil([mod(i-1,3)/2 mod(3-i,3)/2 0]));
    
    h.Text{end+1} = uicontrol(...
        'Parent',h.Mia_TICS.Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'FontWeight','bold',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.02+(i-1)*0.33 0.48 0.3 0.03]);
    switch i
        case 1
            h.Text{end}.String = 'ACF1';
        case 2
            h.Text{end}.String = 'CCF';
        case 3
            h.Text{end}.String = 'ACF2';
    end
    
    %%% Axes to display correlation images
    h.Mia_TICS.Image(i,1) = axes(...
        'Parent',h.Mia_TICS.Panel,...
        'Units','normalized',...
        'Box','off',...
        'Nextplot','Add',...
        'DataAspectRatio',[1 1 1],...
        'PlotBoxAspectRatio', [1 1 1],...
        'UIContextMenu',h.Mia_TICS.Menu,...
        'Position',[0.02+(i-1)*0.33 0.02 0.3 0.45]);
    
    h.Plots.TICSImage(i,1) = imagesc(...
        zeros(2),...
        'Parent',h.Mia_TICS.Image(i),...
        'UIContextMenu',h.Mia_TICS.Menu,...
        'Visible','off');
    h.Mia_TICS.Image(i,1).XTick = [];
    h.Mia_TICS.Image(i,1).YTick = [];
    h.Mia_TICS.Image(i,1).Visible = 'off';
    colormap(jet);
    h.Mia_TICS.Image(i,2) = colorbar(...
        'Peer',h.Mia_TICS.Image(i,1),...
        'YColor',Look.Fore,...
        'Visible','off');
end
h.Mia_TICS.Axes.XColor = Look.Fore;
h.Mia_TICS.Axes.YColor = Look.Fore;
h.Mia_TICS.Axes.XLabel.String = 'Time Lag {\it\tau{}} [s]';
h.Mia_TICS.Axes.XLabel.Color = Look.Fore;
h.Mia_TICS.Axes.YLabel.String = 'G({\it\tau{}})';
h.Mia_TICS.Axes.YLabel.Color = Look.Fore;
h.Mia_TICS.Axes.XScale = 'log';

%% iMSD/STICS Tab
s.ProgressRatio = 0.75;
h.Mia_STICS.Tab = uitab(...
    'Parent',h.Mia_Main_Tabs,...
    'Title','STICS/iMDS',...
    'Units','normalized');
h.Mia_STICS.Panel = uibuttongroup(...
    'Parent',h.Mia_STICS.Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_STICS.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.95, 0.045 0.03],...
    'String','Size');
%%% Editbox for correlation size
h.Mia_STICS.Size = uicontrol(...
    'Parent',h.Mia_STICS.Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Update_Plots,6,1:3},...
    'Position',[0.06 0.95, 0.03 0.03],...
    'String','31');
h.Mia_STICS.Do_Gaussian = uicontrol(...
    'Parent',h.Mia_STICS.Panel,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Do_Gaussian},...
    'String','Calc iMSD',...
    'Position',[0.1 0.95, 0.08 0.03]);
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_STICS.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.91, 0.045 0.03],...
    'String','Lag:');
%%% Editbox for frame
h.Mia_STICS.Lag = uicontrol(...
    'Parent',h.Mia_STICS.Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Mia_Frame,5,1:3},...
    'Position',[0.06 0.91, 0.03 0.03],...
    'String','0');
h.Mia_STICS.Lag_Slider = uicontrol(...
    'Parent',h.Mia_STICS.Panel,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',12,...
    'Min',0,...
    'Max',1,...
    'SliderStep',[1 1],...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Mia_Frame,6,1:3},...
    'Position',[0.1 0.91, 0.08 0.03]);
%%% STICS Fit table
h.Mia_STICS.Fit_Table = uitable(...
    'Parent',h.Mia_STICS.Panel,...
    'Units','normalized',...
    'FontSize',8,...
    'BackgroundColor', [Look.Table1;Look.Table2],...
    'ForegroundColor', Look.TableFore,...
    'ColumnName',{'ACF1','CCF','ACF2'},...
    'ColumnWidth',num2cell([40,40,40]),...
    'ColumnEditable',true,...
    'RowName',{'w_r [um]';'Fix';'D [um2/s]';'Fix';'Alpha';'Fix';},...
    'CellEditCallback',{@Update_Plots,6,1:3},...
    'Position',[0.01 0.73, 0.18 0.17]);
Data = cell(6,3);
Data(1,:)={'0.2'};
Data(3,:)={'0.01'};
Data(5,:)={'1'};
Data([2 4],:)={false};
Data(6,:)={true};
h.Mia_STICS.Fit_Table.Data=Data;

h.Mia_STICS.Do_iMSD = uicontrol(...
    'Parent',h.Mia_STICS.Panel,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Do_iMSD},...
    'String','Fit iMSD',...
    'Position',[0.01 0.69, 0.08 0.03]);

%%% Axes to display correlation
h.Mia_STICS.Axes = axes(...
    'Parent',h.Mia_STICS.Panel,...
    'Units','normalized',...
    'NextPlot','Add',...
    'Position',[0.24 0.59 0.74 0.38]);
for i=1:3
    h.Plots.STICS(i,1) = errorbar(...
        [0.1 1],...
        [0 0],...
        [0 0],...
        [0 0],...
        'Parent',h.Mia_STICS.Axes,...
        'LineStyle','none',...
        'Marker','.',...
        'MarkerSize',8,...
        'Visible','off',...
        'Color',ceil([mod(i-1,3)/2 mod(3-i,3)/2 0]));
    h.Plots.STICS(i,2) = line(...
        'Parent',h.Mia_STICS.Axes,...
        'XData',[0.1 1],...
        'YData',[0 0],...
        'LineStyle','-',...
        'Marker','none',...
        'MarkerSize',8,...
        'Visible','off',...
        'Color',ceil([mod(i-1,3)/2 mod(3-i,3)/2 0]));
    h.Mia_STICS.Axes.XColor = Look.Fore;
    h.Mia_STICS.Axes.YColor = Look.Fore;
    h.Mia_STICS.Axes.XLabel.String = 'Time Lag {\it\tau{}} [s]';
    h.Mia_STICS.Axes.XLabel.Color = Look.Fore;
    h.Mia_STICS.Axes.YLabel.String = 'iMSD [um2/s]';
    h.Mia_STICS.Axes.YLabel.Color = Look.Fore;
    
    
    h.Text{end+1} = uicontrol(...
        'Parent',h.Mia_STICS.Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',14,...
        'FontWeight','bold',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.02+(i-1)*0.33 0.48 0.3 0.03]);
    switch i
        case 1
            h.Text{end}.String = 'ACF1';
        case 2
            h.Text{end}.String = 'CCF';
        case 3
            h.Text{end}.String = 'ACF2';
    end
    %%% Axes to display correlation images
    h.Mia_STICS.Image(i,1) = axes(...
        'Parent',h.Mia_STICS.Panel,...
        'Units','normalized',...
        'Box','off',...
        'Nextplot','Add',...
        'DataAspectRatio',[1 1 1],...
        'PlotBoxAspectRatio', [1 1 1],...
        'UIContextMenu',h.Mia_TICS.Menu,...
        'Position',[0.02+(i-1)*0.33 0.02 0.3 0.45]);
    
    h.Plots.STICSImage(i,1) = imagesc(...
        zeros(2),...
        'Visible','off',...
        'Parent',h.Mia_STICS.Image(i));
    h.Mia_STICS.Image(i,1).XTick = [];
    h.Mia_STICS.Image(i,1).YTick = [];
    h.Mia_STICS.Image(i,1).Visible = 'off';
    colormap(jet);
    h.Mia_STICS.Image(i,2) = colorbar(...
        'Peer',h.Mia_STICS.Image(i,1),...
        'Visible','off',...
        'YColor',Look.Fore);
end

%% N&B Tab
s.ProgressRatio = 0.85;
h.Mia_NB.Tab = uitab(...
    'Parent',h.Mia_Main_Tabs,...
    'Title','N&B',...
    'Units','normalized');
h.Mia_NB.Panel = uibuttongroup(...
    'Parent',h.Mia_NB.Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_NB.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.04 0.96, 0.3 0.03],...
    'String','Intensity');
%%% Axes to display intensity images
h.Mia_NB.Axes(1)= axes(...
    'Parent',h.Mia_NB.Panel,...
    'Units','normalized',...
    'Position',[0.04 0.55 0.3 0.4]);
colormap(h.Mia_NB.Axes(1),jet);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_NB.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.36 0.96, 0.3 0.03],...
    'String','Number n');
%%% Axes to display number images
h.Mia_NB.Axes(2)= axes(...
    'Parent',h.Mia_NB.Panel,...
    'Units','normalized',...
    'Position',[0.36 0.55 0.3 0.4]);
colormap(h.Mia_NB.Axes(2),jet);
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_NB.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.68 0.96, 0.3 0.03],...
    'String','Brightness epsilon');
%%% Axes to display brightness images
h.Mia_NB.Axes(3)= axes(...
    'Parent',h.Mia_NB.Panel,...
    'Units','normalized',...
    'Position',[0.68 0.55 0.3 0.4]);
colormap(h.Mia_NB.Axes(3),jet);

%%% Popupmenu to select histogram to plot
h.Mia_NB.Hist1D = uicontrol(...
    'Parent',h.Mia_NB.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.04 0.49, 0.06 0.03],...
    'Callback',{@Update_Plots,3,1:3},...
    'String',{'PCH';'Intensity';'Number';'Brightness'});
if ismac
    h.Mia_NB.Hist1D.ForegroundColor = [0 0 0];
    h.Mia_NB.Hist1D.BackgroundColor = [1 1 1];
end
%%% Axes to display 2D histograms
h.Mia_NB.Axes(4)= axes(...
    'Parent',h.Mia_NB.Panel,...
    'Units','normalized',...
    'Position',[0.04 0.06 0.26 0.4]);

%%% Popupmenu to select 2D histogram Y axes
h.Mia_NB.Hist2D(1) = uicontrol(...
    'Parent',h.Mia_NB.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Value',3,...
    'Position',[0.36 0.49, 0.08 0.03],...
    'Callback',{@Update_Plots,3,1:3},...
    'String',{'Intensity';'Number';'Brightness'});
%%% Popupmenu to select 2D histogram X axes
h.Mia_NB.Hist2D(2) = uicontrol(...
    'Parent',h.Mia_NB.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Value',1,...
    'Position',[0.45 0.49, 0.08 0.03],...
    'Callback',{@Update_Plots,3,1:3},...
    'String',{'Intensity';'Number';'Brightness'});
%%% Popupmenu to select 2D histogram Color
h.Mia_NB.Hist2D(3) = uicontrol(...
    'Parent',h.Mia_NB.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', [1 1 1],...
    'ForegroundColor', [0 0 0],...
    'Value',1,...
    'ButtonDownFcn',@NB_2DHist_BG,...
    'Position',[0.54 0.49, 0.05 0.03],...
    'Callback',{@Update_Plots,3,1:3},...
    'String',{'Jet';'Hot';'HSV';'Gray'});
if ismac
    for i = 1:3
        h.Mia_NB.Hist2D(i).ForegroundColor = [0 0 0];
        h.Mia_NB.Hist2D(i).BackgroundColor = [1 1 1];
    end
end
%%% Axes to display various histograms
h.Mia_NB.Axes(5)= axes(...
    'Parent',h.Mia_NB.Panel,...
    'Units','normalized',...
    'Position',[0.36 0.06 0.3 0.4]);
colormap(h.Mia_NB.Axes(5),jet);

%%% Initializes empty plots
h.Plots.NB(1)=imagesc(zeros(1,1),...
    'Parent',h.Mia_NB.Axes(1));
h.Mia_NB.Axes(1).Color=[0 0 0];
h.Mia_NB.Axes(1).DataAspectRatio=[1 1 1];
h.Mia_NB.Axes(1).XTick=[];
h.Mia_NB.Axes(1).YTick=[];
a=colorbar(h.Mia_NB.Axes(1));
a.YColor=Look.Fore;
h.Plots.NB(2)=imagesc(zeros(1,1),...
    'Parent',h.Mia_NB.Axes(2));
h.Mia_NB.Axes(2).Color=[0 0 0];
h.Mia_NB.Axes(2).DataAspectRatio=[1 1 1];
h.Mia_NB.Axes(2).XTick=[];
h.Mia_NB.Axes(2).YTick=[];
a=colorbar(h.Mia_NB.Axes(2));
a.YColor=Look.Fore;
h.Plots.NB(3)=imagesc(zeros(1,1),...
    'Parent',h.Mia_NB.Axes(3));
h.Mia_NB.Axes(3).Color=[0 0 0];
h.Mia_NB.Axes(3).DataAspectRatio=[1 1 1];
h.Mia_NB.Axes(3).XTick=[];
h.Mia_NB.Axes(3).YTick=[];
a=colorbar(h.Mia_NB.Axes(3));
a.YColor=Look.Fore;
h.Plots.NB(5)=imagesc(zeros(1,1,3),...
    'Parent',h.Mia_NB.Axes(5));
h.Mia_NB.Axes(5).Color=[0 0 0];
h.Mia_NB.Axes(5).XColor = Look.Fore;
h.Mia_NB.Axes(5).YColor = Look.Fore;
h.Mia_NB.Axes(5).XLabel.String='Intensity [kHz]';
h.Mia_NB.Axes(5).XLabel.Color=Look.Fore;
h.Mia_NB.Axes(5).YLabel.String='Brightness [kHz]';
h.Mia_NB.Axes(5).YLabel.Color=Look.Fore;
h.Mia_NB.Axes(5).YDir='normal';

h.Plots.NB(4)=stairs(0,0,...
    'Parent',h.Mia_NB.Axes(4),...
    'Color','b');
h.Mia_NB.Axes(4).XColor = Look.Fore;
h.Mia_NB.Axes(4).YColor = Look.Fore;
h.Mia_NB.Axes(4).XLabel.String='Counts per pixel';
h.Mia_NB.Axes(4).XLabel.Color=Look.Fore;
h.Mia_NB.Axes(4).YLabel.String='Frequency';
h.Mia_NB.Axes(4).YLabel.Color=Look.Fore;
%%% Text to show mean
h.Mia_NB.Hist1D_Text = text(....
    'Parent',h.Mia_NB.Axes(4),...
    'Units','normalized',...
    'FontSize',14,...
    'Color', 'b',...
    'Position',[0.7 0.93],...
    'String','');

%%% Tabs for N%B Settings
h.Mia_NB.Settings.Tabs = uitabgroup(...
    'Parent',h.Mia_NB.Panel,...
    'Tag','Mia_NB_Settings_Tabs',...
    'Units','normalized',...
    'Position',[0.68 0.01 0.31 0.45]);
%% Tab for N%B Image and Plot Settings
h.Mia_NB.Image.Tab = uitab(...
    'Parent',h.Mia_NB.Settings.Tabs,...
    'Title','Image & Plot');
h.Mia_NB.Image.Panel = uibuttongroup(...
    'Parent',h.Mia_NB.Image.Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.92, 0.26 0.06],...
    'String','Frame time [s]:');
%%% Editbox to set frame time
h.Mia_NB.Image.Frame = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.29 0.92, 0.14 0.06],...
    'String','1');
h.FT_Linker=linkprop([h.Mia_NB.Image.Frame,h.Mia_Image.Settings.Image_Frame],'String');
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.84, 0.26 0.06],...
    'String','Line time [ms]:');
%%% Editbox to set line time
h.Mia_NB.Image.Line = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.29 0.84, 0.14 0.06],...
    'String','3.333');
h.LT_Linker=linkprop([h.Mia_NB.Image.Line,h.Mia_Image.Settings.Image_Line],'String');
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.76, 0.26 0.06],...
    'String','Pixel time [us]:');
%%% Editbox to set pixel time
h.Mia_NB.Image.Pixel = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Update_Plots,3,1:3},...
    'Position',[0.29 0.76, 0.14 0.06],...
    'String','11.11');
h.PT_Linker=linkprop([h.Mia_NB.Image.Pixel,h.Mia_Image.Settings.Image_Pixel],'String');

%%% Popupmenu to select N&B channel
h.Mia_NB.Image.Channel = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Update_Plots,3,1:3},...
    'Position',[0.55 0.92, 0.25 0.06],...
    'String',{'Channel1','Cross','Channel2'});
if ismac
    h.Mia_NB.Image.Channel.ForegroundColor = [0 0 0];
    h.Mia_NB.Image.Channel.BackgroundColor = [1 1 1];
end
%%% Text
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.22 0.66, 0.12 0.06],...
    'String','Min');
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.36 0.66, 0.12 0.06],...
    'String','Max');
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.66, 0.12 0.06],...
    'String','Bins');
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.58, 0.18 0.06],...
    'String','Intensity:');
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.5, 0.18 0.06],...
    'String','Number:');
h.Text{end+1} = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.42, 0.18 0.06],...
    'String','Brightness:');

%%% Editboxes for Min, Max and Bin number
%%% Checkboxes for threshold use
for i=1:3
    for j=1:3
        h.Mia_NB.Image.Hist(i,j) = uicontrol(...
            'Parent',h.Mia_NB.Image.Panel,...
            'Style','edit',...
            'Units','normalized',...
            'FontSize',12,...
            'BackgroundColor', Look.Control,...
            'ForegroundColor', Look.Fore,...
            'Callback',{@Update_Plots,3,1:3},...
            'Position',[0.08+0.14*i 0.66-0.08*j, 0.12 0.06],...
            'String','1');
    end
    h.Mia_NB.Image.UseTH(i) = uicontrol(...
        'Parent',h.Mia_NB.Image.Panel,...
        'Style','checkbox',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Value',0,...
        'Callback',{@Update_Plots,3,1:3},...
        'Position',[0.63 0.66-0.08*i, 0.18 0.06],...
        'String','Use TH');
end

%%Button for ROI mask generation
h.Mia_NB.Image.Mask = uicontrol(...
    'Parent',h.Mia_NB.Image.Panel,...
    'Style','push',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.2 0.2, 0.6 0.10],...
    'Callback',{@Export_ROI, 1},...
    'String','Export Threshold as ROI');

%% Initializes global variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MIAData=[];
MIAData.Data=[];
MIAData.Cor=cell(3,2);
MIAData.FileName=cell(0);
MIAData.Use=ones(2,1);
MIAData.AR = [];
MIAData.MS = cell(2,2);
MIAData.TICS.Data = [];
MIAData.TICS.Data = [];
MIAData.TICS.Data.Int = [];
MIAData.TICS.Data.MS = [];
MIAData.PCH = [];
MIAData.STICS = [];
MIAData.STICS_SEM = [];
MIAData.iMSD = [];
delete(s);
h.Mia.Visible = 'on';
guidata(h.Mia,h); 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions to load different data types %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mia_Load(~,~,mode)
global MIAData UserValues FileInfo TcspcData
h = guidata(findobj('Tag','Mia'));

switch mode
    case {1, 1.5} %%% Loads single color TIFFs
        % case 1 is normal data
        % case 1.5 is RSICS/RLICS data - the first half of the frames is
        % the raw data, the second half of the data is the filtered data
        [FileName1,Path1] = uigetfile({'*.tif'}, 'Load TIFFs for channel 1', UserValues.File.MIAPath, 'MultiSelect', 'on');
        
        if all(Path1==0)
            return
        else
            [FileName2,Path2] = uigetfile({'*.tif'}, 'Load TIFFs for channel 2', Path1, 'MultiSelect', 'on');
        end
        UserValues.File.MIAPath = Path1;

        LSUserValues(1);
        %%% Transforms FileName into cell array
        if ~iscell(FileName1)
            FileName1={FileName1};
        end
        if ~iscell(FileName2)
            FileName2={FileName2};
        end
              
        MIAData.Data = {};
        MIAData.Type = mode;
        MIAData.FileName = [];
        MIAData.PCH = [];
        %% Clears correlation data and plots
        MIAData.Cor=cell(3,2);
        MIAData.TICS.Data.MS = [];
        MIAData.TICS.Data = [];
        MIAData.TICS.Data.Int = [];
        MIAData.STICS = [];
        MIAData.STICS_SEM = [];
        MIAData.RLICS = [];
        for i=1:3
            h.Plots.Cor(i,1).CData=zeros(1,1,3);
            h.Plots.Cor(i,2).ZData=zeros(1);
            h.Plots.Cor(i,2).CData=zeros(1,1,3);
            h.Mia_ICS.Axes(i,1).Visible='off';
            h.Mia_ICS.Axes(i,2).Visible='off';
            h.Mia_ICS.Axes(i,3).Visible='off';
            h.Mia_ICS.Axes(i,4).Visible='off';
            h.Plots.Cor(i,1).Visible='off';
            h.Plots.Cor(i,2).Visible='off';
            h.Plots.Cor(i,3).Visible='off';
            h.Plots.Cor(i,4).Visible='off';
            h.Plots.Cor(i,5).Visible='off';
            h.Plots.Cor(i,6).Visible='off';
            h.Plots.Cor(i,7).Visible='off';
            h.Plots.TICS(i,1).Visible = 'off';
            h.Plots.TICS(i,2).Visible = 'off';
            h.Plots.STICS(i,1).Visible = 'off';
            h.Plots.STICS(i,2).Visible = 'off';
            h.Plots.TICSImage(i).Visible = 'off';
            h.Plots.STICSImage(i,1).Visible = 'off';
            h.Mia_TICS.Image(i,1).Visible = 'off';
            h.Mia_STICS.Image(i,1).Visible = 'off';
            h.Mia_STICS.Image(i,2).Visible = 'off';
        end
        h.Mia_ICS.Frame_Slider.Min=0;
        h.Mia_ICS.Frame_Slider.Max=0;
        h.Mia_ICS.Frame_Slider.SliderStep=[1 1];
        h.Mia_ICS.Frame_Slider.Value=0;
        h.Mia_STICS.Lag_Slider.Min=0;
        h.Mia_STICS.Lag_Slider.Max=1;
        h.Mia_STICS.Lag_Slider.SliderStep=[1 1];
        h.Mia_STICS.Lag_Slider.Value=0;
        %% Clears N&B data and plots
        MIAData.NB=[];
        h.Plots.NB(1).CData=zeros(1,1);
        h.Plots.NB(2).CData=zeros(1,1);
        h.Plots.NB(3).CData=zeros(1,1);
        h.Plots.NB(4).YData=0;
        h.Plots.NB(4).XData=0;
        h.Plots.NB(5).CData=zeros(1,1);        
        %% Loads all frames for channel 1
        for i=1:numel(FileName1)  
            MIAData.FileName{1}{i}=FileName1{i};
            Info=imfinfo(fullfile(Path1,FileName1{i}));
            
            %%% Automatically updates image properties
            if isfield(Info(1), 'ImageDescription') && ~isempty(Info(1).ImageDescription)
                Start = strfind(Info(1).ImageDescription,': ');
                Stop = strfind(Info(1).ImageDescription,'\n');
                if numel(Start)==5 && numel(Stop)==5
                    h.Mia_Image.Settings.Image_Frame.String = Info(1).ImageDescription(Start(2)+1:Stop(2)-1);
                    h.Mia_Image.Settings.Image_Line.String = Info(1).ImageDescription(Start(3)+1:Stop(3)-1);
                    h.Mia_ICS.Fit_Table.Data(15,:) = {Info(1).ImageDescription(Start(3)+1:Stop(3)-1)};
                    h.Mia_Image.Settings.Image_Pixel.String = Info(1).ImageDescription(Start(4)+1:Stop(4)-1);
                    h.Mia_ICS.Fit_Table.Data(13,:) = {Info(1).ImageDescription(Start(4)+1:Stop(4)-1)};
                    h.Mia_Image.Settings.Image_Size.String = Info(1).ImageDescription(Start(5)+1:Stop(5)-1);
                    h.Mia_ICS.Fit_Table.Data(11,:) = {Info(1).ImageDescription(Start(5)+1:Stop(5)-1)};
                elseif numel(Start)==7 && numel(Stop)==7
                    h.Mia_Image.Settings.Image_Frame.String = Info(1).ImageDescription(Start(2)+1:Stop(2)-1);
                    h.Mia_Image.Settings.Image_Line.String = Info(1).ImageDescription(Start(3)+1:Stop(3)-1);
                    h.Mia_ICS.Fit_Table.Data(15,:) = {Info(1).ImageDescription(Start(3)+1:Stop(3)-1)};
                    h.Mia_Image.Settings.Image_Pixel.String = Info(1).ImageDescription(Start(4)+1:Stop(4)-1);
                    h.Mia_ICS.Fit_Table.Data(13,:) = {Info(1).ImageDescription(Start(4)+1:Stop(4)-1)};
                    h.Mia_Image.Settings.Image_Size.String = Info(1).ImageDescription(Start(5)+1:Stop(5)-1);
                    h.Mia_ICS.Fit_Table.Data(11,:) = {Info(1).ImageDescription(Start(5)+1:Stop(5)-1)};
                    MIAData.RLICS(1,1) = str2double(Info(1).ImageDescription(Start(6)+1:Stop(6)-1));
                    MIAData.RLICS(1,2) = str2double(Info(1).ImageDescription(Start(7)+1:Stop(7)-1));
                end
            end
            H = Info.Height;
            W = Info.Width;
            
            warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
            TIFF_Handle = Tiff(fullfile(Path1,FileName1{i}),'r'); % Open tif reference
            
            %%% If RLICS or RSICS was used, the data contains the
            %%% unfiltered data first. MIA can load the unfiltere or the
            %%% filtered data
            if isempty(MIAData.RLICS) 
                % normal TIFFs
                Frames = 1:numel(Info);
                Data = zeros([H, W, numel(Frames)], 'uint16');
            elseif ~isempty(MIAData.RLICS) && mode==1
                % TIFFs generated via RLICS or spectral and user wants to
                % load the raw data that is stored in the first half of the
                % frames
                Frames = 1:numel(Info)/2;
                Data = zeros([H, W, numel(Frames)], 'uint16');
            else
                % TIFFs generated via RLICS or spectral and user wants to load the weighted data
                % that is stored in the last half of the frames
                Frames = (numel(Info)/2+1):numel(Info);
                Data = zeros([H, W, numel(Frames)], 'single');
            end
            
            for j=Frames
                if mod(j,10)==0
                    %%% Updates progress bar
                    Progress(((j-1)+numel(Info)*(i-1))/(numel(Info)*numel(FileName1)),...
                        h.Mia_Progress_Axes,...
                        h.Mia_Progress_Text,...
                        ['Loading Frame ' num2str(j) ' of ' num2str(numel(Info)) ' in File ' num2str(i) ' of ' num2str(numel(FileName1)) ' for Channel 1']);
                end
                %%% Reads the actual data
                TIFF_Handle.setDirectory(j);
                
                %%% Adjusts range for RLICS and RSICS data
                if ~isempty(MIAData.RLICS) && mode==1.5
                    % TIFFs generated via RLICS or spectral and user wants to load the weighted data
                    % that is stored in the last half of the frames
                    NoF = numel(Frames);
                    Data(:,:,j-NoF) = single(TIFF_Handle.read());
                    Data(:,:,j-NoF)= Data(:,:,j-NoF)/2^16*MIAData.RLICS(1,1)+MIAData.RLICS(1,2);
                else
                    data = TIFF_Handle.read();
                    if size(data,3) > 1
                        % 3 color TIFFs, code takes the sum
                        if i ==1 
                            msgbox('3 color TIFFs, code takes the sum')
                        end
                        data = sum(data, 3);
                    end
                    Data(:,:,j) = data;
                end
            end
            
            % Concatenate to existing data if available
            if i > 1
                MIAData.Data{1,1} = cat(3, MIAData.Data{1,1}, Data);
            else
                MIAData.Data{1,1} = Data;
            end
            TIFF_Handle.close(); % Close tif reference
            warning('on', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
        end
        %% Updates frame settings for channel 1
        %%% Unlinks framses
        h.Mia_Image.Settings.Channel_Link.Value = 0;
        h.Mia_Image.Settings.Channel_Link.Visible = 'off';
        h.Mia_Image.Settings.Channel_Frame(2).Visible = 'off';
        h.Mia_Image.Settings.Channel_FrameUse(2).Visible = 'off';
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Visible = 'off';
        h.Mia_Image.Axes(2,1).Visible = 'off';
        h.Mia_Image.Axes(2,2).Visible = 'off';
        h.Plots.Image(2,1).Visible = 'off';
        h.Plots.Image(2,2).Visible = 'off';
        h.Plots.ROI(2).Visible = 'off';
        h.Mia_Image.Settings.Channel_Frame_Slider(1).SliderStep=[1./size(MIAData.Data{1,1},3),10/size(MIAData.Data{1,1},3)];
        h.Mia_Image.Settings.Channel_Frame_Slider(1).Max=size(MIAData.Data{1,1},3);
        h.Mia_Image.Settings.ROI_Frames.String=['1:' num2str(size(MIAData.Data{1,1},3))];
        h.Mia_Image.Settings.Channel_Frame_Slider(1).Value=0;  
        h.Mia_Image.Settings.Channel_Frame_Slider(1).Min=0;
        MIAData.Use=ones(2,size(MIAData.Data{1,1},3));
        %% Stops function, if only one channel was loaded and clear channel 2
        if all(Path2==0) 
            %%% Clears images
            h.Plots.Image(2,1).CData=zeros(1,1,3);
            h.Mia_Image.Axes(2,1).XLim=[0 1]+0.5;
            h.Mia_Image.Axes(2,1).YLim=[0 1]+0.5;
            h.Plots.Image(2,2).CData=zeros(1,1,3);
            h.Mia_Image.Axes(2,2).XLim=[0 1]+0.5;
            h.Mia_Image.Axes(2,2).YLim=[0 1]+0.5;
            %%% Resets slider
            h.Mia_Image.Settings.Channel_Frame_Slider(2).SliderStep=[1 1];
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Max=1;
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Value=1;
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Min=1;
            h.Mia_Image.Settings.Channel_Frame(2).String='1';
            Progress(1);
            %%% Updates plot
            Mia_ROI([],[],1)  
            return
        end
        %% Loads all frames for channel 2
        for i=1:numel(FileName2)
            MIAData.FileName{2}{i}=FileName2{i};
            Info=imfinfo(fullfile(Path2,FileName2{i}));
                        
            %%% Automatically updates image properties
            if isfield(Info(1), 'ImageDescription') && ~isempty(Info(1).ImageDescription)
                Start = strfind(Info(1).ImageDescription,': ');
                Stop = strfind(Info(1).ImageDescription,'\n');
                if numel(Start)==7 && numel(Stop)==7
                    MIAData.RLICS(2,1) = str2double(Info(1).ImageDescription(Start(6)+1:Stop(6)-1));
                    MIAData.RLICS(2,2) = str2double(Info(1).ImageDescription(Start(7)+1:Stop(7)-1));
                end
            end
            H = Info.Height;
            W = Info.Width;
            
            warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
            TIFF_Handle = Tiff(fullfile(Path2,FileName2{i}),'r'); % Open tif reference
            
            if isempty(MIAData.RLICS) || size(MIAData.RLICS,1)~=2
                % normal TIFFs
                Frames = 1:numel(Info);
                Data = zeros([H, W, numel(Frames)], 'uint16');
            elseif size(MIAData.RLICS,1)==2 && mode==1 
                % TIFFs generated via RLICS or spectral and user wants to
                % load the raw data that is stored in the first half of the
                % frames
                Frames = 1:numel(Info)/2;
                Data = zeros([H, W, numel(Frames)], 'uint16');
            else
                % TIFFs generated via RLICS or spectral and user wants to load the weighted data
                % that is stored in the last half of the frames
                Frames = (numel(Info)/2+1):numel(Info);
                Data = zeros([H, W, numel(Frames)], 'single');
            end
            
            for j=Frames
                if mod(j,10)==0
                    %%% Updates progress bar
                    Progress(((j-1)+numel(Info)*(i-1))/(numel(Info)*numel(FileName2)),...
                        h.Mia_Progress_Axes,...
                        h.Mia_Progress_Text,...
                        ['Loading Frame ' num2str(j) ' of ' num2str(numel(Info)) ' in File ' num2str(i) ' of ' num2str(numel(FileName2)) ' for Channel 2']);
                end
                TIFF_Handle.setDirectory(j);
                
                %%% Adjusts for RLICS and RSICS range
                if ~isempty(MIAData.RLICS) && mode==1.5
                    % TIFFs generated via RLICS or spectral and user wants to load the weighted data
                    % that is stored in the last half of the frames
                    NoF = numel(Frames);
                    Data(:,:,j-NoF) = single(TIFF_Handle.read());
                    Data(:,:,j-NoF) = Data(:,:,j-NoF)/2^16*MIAData.RLICS(2,1)+MIAData.RLICS(2,2);
                else
                    data = TIFF_Handle.read();
                    if size(data,3) > 1
                        % 3 color TIFFs, code takes the sum
                        if i ==1 
                            msgbox('3 color TIFFs, code takes the sum')
                        end
                        data = sum(data, 3);
                    end
                    Data(:,:,j) = data;
                end
            end
            if i>1
                MIAData.Data{2,1} = cat(3, MIAData.Data{2,1}, Data);
            else
                MIAData.Data{2,1} = Data;
            end
            TIFF_Handle.close(); % Close tif reference
            warning('on', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
        end
        % convert data using S and offset parameter
        Mia_Orientation([],[],5)

        %%% Updates frame settings for channel 2
        h.Mia_Image.Settings.Channel_Frame_Slider(2).SliderStep=[1./size(MIAData.Data{2,1},3),10/size(MIAData.Data{2,1},3)];
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Max=size(MIAData.Data{2,1},3);
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Value=0;
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Min=0;
        h.Plots.ROI(2).Position=[10 10 200 200];
        h.Plots.ROI(4).Position=[10 10 200 200];
        %%% Links frames
        h.Mia_Image.Settings.Channel_Link.Value = 1;
        h.Mia_Image.Settings.Channel_Link.Visible = 'on';
        h.Mia_Image.Settings.Channel_Frame(2).Visible = 'on';
        h.Mia_Image.Settings.Channel_FrameUse(2).Visible = 'on';
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Visible = 'on';
        h.Mia_Image.Axes(2,1).Visible = 'on';
        h.Mia_Image.Axes(2,2).Visible = 'on';
        h.Plots.Image(2,1).Visible = 'on';
        h.Plots.Image(2,2).Visible = 'on';
        h.Plots.ROI(2).Visible = 'on';
        
        Progress(1);
        %%% Updates plots
        Mia_ROI([],[],1)
    case {4,5,6} %%% Loads RGB TIFFs
        % case 4 green red
        % case 5 blue green
        % case 6 blue red
        [FileName1,Path1] = uigetfile({'*.tif'}, 'Load TIFF', UserValues.File.MIAPath, 'MultiSelect', 'on');
        
        if all(Path1==0)
            retur
        end
        UserValues.File.MIAPath = Path1;
        Path2 = Path1;
        LSUserValues(1);
        %%% Transforms FileName into cell array
        if ~iscell(FileName1)
            FileName1={FileName1};
        end
        FileName2 = FileName1;      
        MIAData.Data = {};
        MIAData.Type = mode;
        MIAData.FileName = [];
        MIAData.PCH = [];
        %% Clears correlation data and plots
        MIAData.Cor=cell(3,2);
        MIAData.TICS.Data.MS = [];
        MIAData.TICS.Data = [];
        MIAData.TICS.Data.Int = [];
        MIAData.STICS = [];
        MIAData.STICS_SEM = [];
        MIAData.RLICS = [];
        for i=1:3
            h.Plots.Cor(i,1).CData=zeros(1,1,3);
            h.Plots.Cor(i,2).ZData=zeros(1);
            h.Plots.Cor(i,2).CData=zeros(1,1,3);
            h.Mia_ICS.Axes(i,1).Visible='off';
            h.Mia_ICS.Axes(i,2).Visible='off';
            h.Mia_ICS.Axes(i,3).Visible='off';
            h.Mia_ICS.Axes(i,4).Visible='off';
            h.Plots.Cor(i,1).Visible='off';
            h.Plots.Cor(i,2).Visible='off';
            h.Plots.Cor(i,3).Visible='off';
            h.Plots.Cor(i,4).Visible='off';
            h.Plots.Cor(i,5).Visible='off';
            h.Plots.Cor(i,6).Visible='off';
            h.Plots.Cor(i,7).Visible='off';
            h.Plots.TICS(i,1).Visible = 'off';
            h.Plots.TICS(i,2).Visible = 'off';
            h.Plots.STICS(i,1).Visible = 'off';
            h.Plots.STICS(i,2).Visible = 'off';
            h.Plots.TICSImage(i).Visible = 'off';
            h.Plots.STICSImage(i,1).Visible = 'off';
            h.Mia_TICS.Image(i,1).Visible = 'off';
            h.Mia_STICS.Image(i,1).Visible = 'off';
            h.Mia_STICS.Image(i,2).Visible = 'off';
        end
        h.Mia_ICS.Frame_Slider.Min=0;
        h.Mia_ICS.Frame_Slider.Max=0;
        h.Mia_ICS.Frame_Slider.SliderStep=[1 1];
        h.Mia_ICS.Frame_Slider.Value=0;
        h.Mia_STICS.Lag_Slider.Min=0;
        h.Mia_STICS.Lag_Slider.Max=1;
        h.Mia_STICS.Lag_Slider.SliderStep=[1 1];
        h.Mia_STICS.Lag_Slider.Value=0;
        %% Clears N&B data and plots
        MIAData.NB=[];
        h.Plots.NB(1).CData=zeros(1,1);
        h.Plots.NB(2).CData=zeros(1,1);
        h.Plots.NB(3).CData=zeros(1,1);
        h.Plots.NB(4).YData=0;
        h.Plots.NB(4).XData=0;
        h.Plots.NB(5).CData=zeros(1,1);        
        %% Loads all frames for channel 1
        for i=1:numel(FileName1)  
            MIAData.FileName{1}{i}=FileName1{i};
            Info=imfinfo(fullfile(Path1,FileName1{i}));
            
            %%% Automatically updates image properties
            if isfield(Info(1), 'ImageDescription') && ~isempty(Info(1).ImageDescription)
                Start = strfind(Info(1).ImageDescription,': ');
                Stop = strfind(Info(1).ImageDescription,'\n');
                if numel(Start)==5 && numel(Stop)==5
                    h.Mia_Image.Settings.Image_Frame.String = Info(1).ImageDescription(Start(2)+1:Stop(2)-1);
                    h.Mia_Image.Settings.Image_Line.String = Info(1).ImageDescription(Start(3)+1:Stop(3)-1);
                    h.Mia_ICS.Fit_Table.Data(15,:) = {Info(1).ImageDescription(Start(3)+1:Stop(3)-1)};
                    h.Mia_Image.Settings.Image_Pixel.String = Info(1).ImageDescription(Start(4)+1:Stop(4)-1);
                    h.Mia_ICS.Fit_Table.Data(13,:) = {Info(1).ImageDescription(Start(4)+1:Stop(4)-1)};
                    h.Mia_Image.Settings.Image_Size.String = Info(1).ImageDescription(Start(5)+1:Stop(5)-1);
                    h.Mia_ICS.Fit_Table.Data(11,:) = {Info(1).ImageDescription(Start(5)+1:Stop(5)-1)};
                elseif numel(Start)==7 && numel(Stop)==7
                    h.Mia_Image.Settings.Image_Frame.String = Info(1).ImageDescription(Start(2)+1:Stop(2)-1);
                    h.Mia_Image.Settings.Image_Line.String = Info(1).ImageDescription(Start(3)+1:Stop(3)-1);
                    h.Mia_ICS.Fit_Table.Data(15,:) = {Info(1).ImageDescription(Start(3)+1:Stop(3)-1)};
                    h.Mia_Image.Settings.Image_Pixel.String = Info(1).ImageDescription(Start(4)+1:Stop(4)-1);
                    h.Mia_ICS.Fit_Table.Data(13,:) = {Info(1).ImageDescription(Start(4)+1:Stop(4)-1)};
                    h.Mia_Image.Settings.Image_Size.String = Info(1).ImageDescription(Start(5)+1:Stop(5)-1);
                    h.Mia_ICS.Fit_Table.Data(11,:) = {Info(1).ImageDescription(Start(5)+1:Stop(5)-1)};
                    MIAData.RLICS(1,1) = str2double(Info(1).ImageDescription(Start(6)+1:Stop(6)-1));
                    MIAData.RLICS(1,2) = str2double(Info(1).ImageDescription(Start(7)+1:Stop(7)-1));
                end
            end
            H = Info.Height;
            W = Info.Width;
            
            warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
            TIFF_Handle = Tiff(fullfile(Path1,FileName1{i}),'r'); % Open tif reference
            
                Frames = 1:numel(Info);
                Data = zeros([H, W, numel(Frames)], 'uint16');
            for j=Frames
                if mod(j,10)==0
                    %%% Updates progress bar
                    Progress(((j-1)+numel(Info)*(i-1))/(numel(Info)*numel(FileName1)),...
                        h.Mia_Progress_Axes,...
                        h.Mia_Progress_Text,...
                        ['Loading Frame ' num2str(j) ' of ' num2str(numel(Info)) ' in File ' num2str(i) ' of ' num2str(numel(FileName1)) ' for Channel 1']);
                end
                %%% Reads the actual data
                TIFF_Handle.setDirectory(j);
               
                data = TIFF_Handle.read();
                if mode == 4
                    data = data(:,:,2); %green
                else %mode == 5 or 6
                    data = data(:,:,3); %blue
                    
                end
                Data(:,:,j) = data;
            end
            
            % Concatenate to existing data if available
            if i > 1
                MIAData.Data{1,1} = cat(3, MIAData.Data{1,1}, Data);
            else
                MIAData.Data{1,1} = Data;
            end
            TIFF_Handle.close(); % Close tif reference
            warning('on', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
        end
        %% Updates frame settings for channel 1
        %%% Unlinks framses
        h.Mia_Image.Settings.Channel_Link.Value = 0;
        h.Mia_Image.Settings.Channel_Link.Visible = 'off';
        h.Mia_Image.Settings.Channel_Frame(2).Visible = 'off';
        h.Mia_Image.Settings.Channel_FrameUse(2).Visible = 'off';
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Visible = 'off';
        h.Mia_Image.Axes(2,1).Visible = 'off';
        h.Mia_Image.Axes(2,2).Visible = 'off';
        h.Plots.Image(2,1).Visible = 'off';
        h.Plots.Image(2,2).Visible = 'off';
        h.Plots.ROI(2).Visible = 'off';
        h.Mia_Image.Settings.Channel_Frame_Slider(1).SliderStep=[1./size(MIAData.Data{1,1},3),10/size(MIAData.Data{1,1},3)];
        h.Mia_Image.Settings.Channel_Frame_Slider(1).Max=size(MIAData.Data{1,1},3);
        h.Mia_Image.Settings.ROI_Frames.String=['1:' num2str(size(MIAData.Data{1,1},3))];
        h.Mia_Image.Settings.Channel_Frame_Slider(1).Value=0;  
        h.Mia_Image.Settings.Channel_Frame_Slider(1).Min=0;
        MIAData.Use=ones(2,size(MIAData.Data{1,1},3));
        %% Stops function, if only one channel was loaded and clear channel 2
        if all(Path2==0) 
            %%% Clears images
            h.Plots.Image(2,1).CData=zeros(1,1,3);
            h.Mia_Image.Axes(2,1).XLim=[0 1]+0.5;
            h.Mia_Image.Axes(2,1).YLim=[0 1]+0.5;
            h.Plots.Image(2,2).CData=zeros(1,1,3);
            h.Mia_Image.Axes(2,2).XLim=[0 1]+0.5;
            h.Mia_Image.Axes(2,2).YLim=[0 1]+0.5;
            %%% Resets slider
            h.Mia_Image.Settings.Channel_Frame_Slider(2).SliderStep=[1 1];
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Max=1;
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Value=1;
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Min=1;
            h.Mia_Image.Settings.Channel_Frame(2).String='1';
            Progress(1);
            %%% Updates plot
            Mia_ROI([],[],1)  
            return
        end
        %% Loads all frames for channel 2
        for i=1:numel(FileName2)
            MIAData.FileName{2}{i}=FileName2{i};
            Info=imfinfo(fullfile(Path2,FileName2{i}));
                        
            %%% Automatically updates image properties
            if isfield(Info(1), 'ImageDescription') && ~isempty(Info(1).ImageDescription)
                Start = strfind(Info(1).ImageDescription,': ');
                Stop = strfind(Info(1).ImageDescription,'\n');
                if numel(Start)==7 && numel(Stop)==7
                    MIAData.RLICS(2,1) = str2double(Info(1).ImageDescription(Start(6)+1:Stop(6)-1));
                    MIAData.RLICS(2,2) = str2double(Info(1).ImageDescription(Start(7)+1:Stop(7)-1));
                end
            end
            H = Info.Height;
            W = Info.Width;
            
            warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
            TIFF_Handle = Tiff(fullfile(Path2,FileName2{i}),'r'); % Open tif reference
            
            Frames = 1:numel(Info);
            Data = zeros([H, W, numel(Frames)], 'uint16');
            
            
            for j=Frames
                if mod(j,10)==0
                    %%% Updates progress bar
                    Progress(((j-1)+numel(Info)*(i-1))/(numel(Info)*numel(FileName2)),...
                        h.Mia_Progress_Axes,...
                        h.Mia_Progress_Text,...
                        ['Loading Frame ' num2str(j) ' of ' num2str(numel(Info)) ' in File ' num2str(i) ' of ' num2str(numel(FileName2)) ' for Channel 2']);
                end
                TIFF_Handle.setDirectory(j);
                
                
                data = TIFF_Handle.read();
                if mode == 5
                    data = data(:,:,2); % green
                else
                    data = data(:,:,1);
                end
                Data(:,:,j) = data;
            end
            
            % Concatenate to existing data if available
            if i>1
                MIAData.Data{2,1} = cat(3, MIAData.Data{2,1}, Data);
            else
                MIAData.Data{2,1} = Data;
            end
            TIFF_Handle.close(); % Close tif reference
            warning('on', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
        end
        % convert data using S and offset parameter
        Mia_Orientation([],[],5)

        %%% Updates frame settings for channel 2
        h.Mia_Image.Settings.Channel_Frame_Slider(2).SliderStep=[1./size(MIAData.Data{2,1},3),10/size(MIAData.Data{2,1},3)];
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Max=size(MIAData.Data{2,1},3);
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Value=0;
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Min=0;
        h.Plots.ROI(2).Position=[10 10 200 200];
        h.Plots.ROI(4).Position=[10 10 200 200];
        %%% Links frames
        h.Mia_Image.Settings.Channel_Link.Value = 1;
        h.Mia_Image.Settings.Channel_Link.Visible = 'on';
        h.Mia_Image.Settings.Channel_Frame(2).Visible = 'on';
        h.Mia_Image.Settings.Channel_FrameUse(2).Visible = 'on';
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Visible = 'on';
        h.Mia_Image.Axes(2,1).Visible = 'on';
        h.Mia_Image.Axes(2,2).Visible = 'on';
        h.Plots.Image(2,1).Visible = 'on';
        h.Plots.Image(2,2).Visible = 'on';
        h.Plots.ROI(2).Visible = 'on';
        
        Progress(1);  
        %%% Updates plots
        Mia_ROI([],[],1)
    case 2 %%% Loads data from Pam
        %% Aborts, if not Data is loaded or Pam is closed
        if isempty(findobj('Tag','Pam'))
            return;
        end
        Pam = guidata(findobj('Tag','Pam'));        
        if isempty(Pam) || all(all(cellfun(@isempty,TcspcData.MT)))
           return 
        end
        %% Clear current Data
        MIAData.Data=[];
        MIAData.Data{1,1} = single.empty(0,0,0);
        %% Clears correlation data and plots
        MIAData.Cor=cell(3,2);
        MIAData.TICS.Data.MS = [];
        MIAData.TICS.Data = [];
        MIAData.TICS.Data.Int = [];
        for i=1:3
            h.Plots.Cor(i,1).CData=zeros(1,1,3);
            h.Plots.Cor(i,2).ZData=zeros(1);
            h.Plots.Cor(i,2).CData=zeros(1,1,3);
            h.Mia_ICS.Axes(i,1).Visible='off';
            h.Mia_ICS.Axes(i,2).Visible='off';
            h.Mia_ICS.Axes(i,3).Visible='off';
            h.Mia_ICS.Axes(i,4).Visible='off';
            h.Plots.Cor(i,1).Visible='off';
            h.Plots.Cor(i,2).Visible='off';
            h.Plots.Cor(i,3).Visible='off';
            h.Plots.Cor(i,4).Visible='off';
            h.Plots.Cor(i,5).Visible='off';
            h.Plots.Cor(i,6).Visible='off';
            h.Plots.Cor(i,7).Visible='off';
        end
        h.Mia_ICS.Frame_Slider.Min=0;
        h.Mia_ICS.Frame_Slider.Max=0;
        h.Mia_ICS.Frame_Slider.SliderStep=[1 1];
        h.Mia_ICS.Frame_Slider.Value=0;        
        %% Clears N&B data and plots
        MIAData.NB=[];
        h.Plots.NB(1).CData=zeros(1,1);
        h.Plots.NB(2).CData=zeros(1,1);
        h.Plots.NB(3).CData=zeros(1,1);
        h.Plots.NB(4).YData=0;
        h.Plots.NB(4).XData=0;
        h.Plots.NB(5).CData=zeros(1,1);                 
        %% Extracts data from Pam for channel 1
        %%% Automatically updates image properties
        UserValues.File.MIAPath = FileInfo.Path;
        LSUserValues(1);
        MIAData.Type = mode;
        MIAData.FileName{1} = FileInfo.FileName;
        h.Mia_Image.Settings.Image_Frame.String = num2str(mean(diff(FileInfo.ImageTimes)));
        
        if isfield(FileInfo, 'LineStops')
            h.Mia_Image.Settings.Image_Pixel.String = num2str(mean(mean(FileInfo.LineStops-FileInfo.LineTimes))./FileInfo.Lines*1000000);
            h.Mia_Image.Settings.Image_Line.String = num2str(mean(mean(diff(FileInfo.LineTimes,1,2)))*1000);
        else
            h.Mia_Image.Settings.Image_Pixel.String = num2str(mean(diff(FileInfo.ImageTimes))./FileInfo.Lines^2*1000000);
            h.Mia_Image.Settings.Image_Line.String = num2str(mean(diff(FileInfo.ImageTimes))./FileInfo.Lines*1000);
        end
        
        h.Mia_ICS.Fit_Table.Data(15,:) = {num2str(mean(diff(FileInfo.ImageTimes))./FileInfo.Lines*1000)};
        h.Mia_ICS.Fit_Table.Data(13,:) = {num2str(mean(diff(FileInfo.ImageTimes))./FileInfo.Lines^2*1000000)};
        
        if isfield(FileInfo, 'Fabsurf') && ~isempty(FileInfo.Fabsurf)
            h.Mia_Image.Settings.Image_Size.String = num2str(FileInfo.Fabsurf.Imagesize/FileInfo.Lines*1000);
            h.Mia_ICS.Fit_Table.Data(11,:) = {num2str(FileInfo.Fabsurf.Imagesize/FileInfo.Lines*1000)};
        else
            h.Mia_Image.Settings.Image_Size.String = '50';
            h.Mia_ICS.Fit_Table.Data(11,:) = {'50'};
        end
        
        Sel = h.Mia_Image.Settings.Channel_PIE(1).Value;
        
        if UserValues.PIE.Detector(Sel)~=0
            if ~isempty(TcspcData.MT{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}(...
                    TcspcData.MI{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}>=UserValues.PIE.From(Sel) &...
                    TcspcData.MI{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}<=UserValues.PIE.To(Sel)))
                
                [MIAData.Data{1,1},~] = CalculateImage(TcspcData.MT{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}(...
                    TcspcData.MI{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}>=UserValues.PIE.From(Sel) &...
                    TcspcData.MI{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}<=UserValues.PIE.To(Sel))*FileInfo.ClockPeriod, 3);
            else
                MIAData.Data{1,1} = 0;
                msgbox('Empty PIE channel');
            end
            
        else
            PIE_MT=[];
            for i=UserValues.PIE.Combined{Sel}
                PIE_MT = [PIE_MT; TcspcData.MT{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}(...
                    TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}>=UserValues.PIE.From(i) &...
                    TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}<=UserValues.PIE.To(i))];
            end
            if ~isempty(PIE_MT)
                [MIAData.Data{1,1}, ~] = CalculateImage(PIE_MT*FileInfo.ClockPeriod, 3);
            else
                MIAData.Data{1,1} = 0;
                msgbox('Empty PIE channel');
            end
            clear PIE_MT;
            
        end
        
        %% Updates frame settings for channel 1
        %%% Unlinks framses
        h.Mia_Image.Settings.Channel_Link.Value = 0;
        h.Mia_Image.Settings.Channel_Link.Visible = 'off';
        h.Mia_Image.Settings.Channel_Frame(2).Visible = 'off';
        h.Mia_Image.Settings.Channel_FrameUse(2).Visible = 'off';
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Visible = 'off';
        h.Mia_Image.Axes(2,1).Visible = 'off';
        h.Mia_Image.Axes(2,2).Visible = 'off';
        h.Plots.Image(2,1).Visible = 'off';
        h.Plots.Image(2,2).Visible = 'off';
        h.Plots.ROI(2).Visible = 'off';
        h.Mia_Image.Settings.Channel_Frame_Slider(1).SliderStep=[1./size(MIAData.Data{1,1},3),10/size(MIAData.Data{1,1},3)];
        h.Mia_Image.Settings.Channel_Frame_Slider(1).Max=size(MIAData.Data{1,1},3);
        h.Mia_Image.Settings.ROI_Frames.String=['1:' num2str(size(MIAData.Data{1,1},3))];
        h.Mia_Image.Settings.Channel_Frame_Slider(1).Value=0;
        h.Mia_Image.Settings.Channel_Frame_Slider(1).Min=0;
        MIAData.Use=ones(2,size(MIAData.Data{1,1},3));
        %% Stops function, if only one channel was loaded and clear channel 2
        if h.Mia_Image.Settings.Channel_PIE(2).Value == numel(h.Mia_Image.Settings.Channel_PIE(2).String)
            %%% Clears images
            h.Plots.Image(2,1).CData=zeros(1,1,3);
            h.Mia_Image.Axes(2,1).XLim=[0 1]+0.5;
            h.Mia_Image.Axes(2,1).YLim=[0 1]+0.5;
            h.Plots.Image(2,2).CData=zeros(1,1,3);
            h.Mia_Image.Axes(2,2).XLim=[0 1]+0.5;
            h.Mia_Image.Axes(2,2).YLim=[0 1]+0.5;
            %%% Resets slider
            h.Mia_Image.Settings.Channel_Frame_Slider(2).SliderStep=[1 1];
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Max=1;
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Value=1;
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Min=1;
            h.Mia_Image.Settings.Channel_Frame(2).String='1';
            Progress(1);
            %%% Updates plot
            Mia_ROI([],[],1)
            return;
        end
        %% Extracts data from Pam for channel 2
        MIAData.FileName{2} = FileInfo.FileName;
        Sel = h.Mia_Image.Settings.Channel_PIE(2).Value;
        %%% Gets the photons        
        if UserValues.PIE.Detector(Sel)~=0
            if ~isempty(TcspcData.MT{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}(...
                    TcspcData.MI{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}>=UserValues.PIE.From(Sel) &...
                    TcspcData.MI{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}<=UserValues.PIE.To(Sel)))
                
                [MIAData.Data{2,1},~] = CalculateImage(TcspcData.MT{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}(...
                    TcspcData.MI{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}>=UserValues.PIE.From(Sel) &...
                    TcspcData.MI{UserValues.PIE.Detector(Sel),UserValues.PIE.Router(Sel)}<=UserValues.PIE.To(Sel))*FileInfo.ClockPeriod, 3);
            else
                MIAData.Data{2,1} = 0;
                msgbox('Empty PIE channel');
            end
        else
            PIE_MT=[];
            for i=UserValues.PIE.Combined{Sel}
                PIE_MT = [PIE_MT; TcspcData.MT{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}(...
                    TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}>=UserValues.PIE.From(i) &...
                    TcspcData.MI{UserValues.PIE.Detector(i),UserValues.PIE.Router(i)}<=UserValues.PIE.To(i))];
            end
            if ~isempty(PIE_MT)
                [MIAData.Data{2,1}, ~] = CalculateImage(PIE_MT*FileInfo.ClockPeriod, 3);
            else
                MIAData.Data{2,1} = 0;
                msgbox('Empty PIE channel');
            end
            clear PiE_MT;
        end
        %% Updates frame settings for channel 2
        h.Mia_Image.Settings.Channel_Frame_Slider(2).SliderStep=[1./size(MIAData.Data{2,1},3),10/size(MIAData.Data{2,1},3)];
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Max=size(MIAData.Data{2,1},3);
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Value=0;
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Min=0;
        h.Plots.ROI(2).Position=[10 10 200 200];       
        
        %%% Links frames
        h.Mia_Image.Settings.Channel_Link.Value = 1;
        h.Mia_Image.Settings.Channel_Link.Visible = 'on';
        h.Mia_Image.Settings.Channel_Frame(2).Visible = 'on';
        h.Mia_Image.Settings.Channel_FrameUse(2).Visible = 'on';
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Visible = 'on';
        h.Mia_Image.Axes(2,1).Visible = 'on';
        h.Mia_Image.Axes(2,2).Visible = 'on';
        h.Plots.Image(2,1).Visible = 'on';
        h.Plots.Image(2,2).Visible = 'on';
        h.Plots.ROI(2).Visible = 'on';
        Progress(1);  
        %%% Updates plots
        Mia_ROI([],[],1)
        
    case 3 %%% Loads custom data formats
        MIA_CustomFileType([],[],2);
              
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Updates mia plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(obj,~,mode,channel)
global MIAData UserValues
Fig = gcf; 
%%% This speeds display up
if strcmp(Fig.Tag,'Mia') 
    h = guidata(Fig);
else
    h = guidata(findobj('Tag','Mia'));
end
Save_MIA_UserValues(h)

h.Mia_Progress_Text.String = 'Updating plots';
h.Mia_Progress_Axes.Color=[1 0 0];  
drawnow;

%% Image info update
if size(MIAData.Data,1)==1 && size(MIAData.Data,2)==2
    h.Mia_Image.Settings.Image_Mean_CR.String = {'Mean Countrate [kHz]:';...
                            [num2str(mean2(MIAData.Data{1,2})/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1e3) ' / -']};
elseif size(MIAData.Data,1)==2 && size(MIAData.Data,2)==2
    h.Mia_Image.Settings.Image_Mean_CR.String = {'Mean Countrate [kHz]:';...
                            [num2str(mean2(MIAData.Data{1,2})/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1e3) ' / '...
                             num2str(mean2(MIAData.Data{2,2})/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1e3)]};
else 
    h.Mia_Image.Settings.Image_Mean_CR.String = 'Mean Countrate [kHz]: - / -';
end

%% Plots intensity images
if any(mode==1)   
    for i=channel
        %% Selects colormap
        switch h.Mia_Image.Settings.Channel_Colormap(i).Value
            case 1 %%% Gray
                colormap(h.Mia_Image.Axes(i,1),gray(64));
                colormap(h.Mia_Image.Axes(i,2),gray(64));
                h.Mia_Image.Axes(i,2).Color = [1 0 0];
                h.Mia_Image.Settings.Channel_Colormap(i).BackgroundColor = UserValues.Look.Control;
                AlphaRatio = 3;
            case 2 %%% Jet
                colormap(h.Mia_Image.Axes(i,1),jet(64));
                colormap(h.Mia_Image.Axes(i,2),jet(64));
                h.Mia_Image.Axes(i,2).Color = [0 0 0];
                h.Mia_Image.Settings.Channel_Colormap(i).BackgroundColor = UserValues.Look.Control;
                AlphaRatio = 0.25;
            case 3 %%% Hot
                colormap(h.Mia_Image.Axes(i,1),hot(64));
                colormap(h.Mia_Image.Axes(i,2),hot(64));
                h.Mia_Image.Axes(i,2).Color = [0 1 0];
                h.Mia_Image.Settings.Channel_Colormap(i).BackgroundColor = UserValues.Look.Control;
                AlphaRatio = 2;
            case 4 %%% HSV
                colormap(h.Mia_Image.Axes(i,1),hsv(64));
                colormap(h.Mia_Image.Axes(i,2),hsv(64));
                h.Mia_Image.Axes(i,2).Color = [0 0 0];
                h.Mia_Image.Settings.Channel_Colormap(i).BackgroundColor = UserValues.Look.Control;
                AlphaRatio = 0.5;
            case 5 %%% Custom
                colormap(h.Mia_Image.Axes(i,1),gray(64).*repmat(h.Mia_Image.Settings.Channel_Colormap(i).UserData,[64,1]));
                colormap(h.Mia_Image.Axes(i,2),gray(64).*repmat(h.Mia_Image.Settings.Channel_Colormap(i).UserData,[64,1]));
                h.Mia_Image.Axes(i,2).Color = 1 - h.Mia_Image.Settings.Channel_Colormap(i).UserData;
                h.Mia_Image.Settings.Channel_Colormap(i).BackgroundColor = h.Mia_Image.Settings.Channel_Colormap(i).UserData;
                AlphaRatio = 3;
            case 6 %%% HiLo
                colormap(h.Mia_Image.Axes(i,1),[0 0 1;gray(2^16-2);1 0 0]);
                colormap(h.Mia_Image.Axes(i,2),[0 0 1;gray(2^16-2);1 0 0]);
                h.Mia_Image.Axes(i,2).Color = [0 1 0];
                h.Mia_Image.Settings.Channel_Colormap(i).BackgroundColor = UserValues.Look.Control;
                AlphaRatio = 3;
        end        
        %% Plots main image
        if size(MIAData.Data,1)>=i
            Frame=round(h.Mia_Image.Settings.Channel_Frame_Slider(i).Value);
            if Frame>0 %%% Extracts data of current frame
                Image=MIAData.Data{i,1}(:,:,Frame);
            elseif Frame == 0 %%% Extracts data of all selected frames, if Frame==0
                Frames = str2num(h.Mia_Image.Settings.ROI_Frames.String); %#ok<ST2NM>
                Image = mean(MIAData.Data{i,1}(:,:,Frames),3);
            end
            %%% Updates image and axis
            h.Plots.Image(i,1).CData = Image;
            %%% Adjusts Scale of image
            switch h.Mia_Image.Settings.AutoScale.Value
                case 1 
                    h.Mia_Image.Axes(i,1).CLimMode = 'auto';
                    h.Mia_Image.Settings.Scale(i,1).Visible = 'off';
                    h.Mia_Image.Settings.Scale(i,2).Visible = 'off';
                    h.Mia_Image.Settings.Scale_Text.Visible = 'off';
                case 2
                    Min = nanmin(MIAData.Data{i,1}(:));
                    Max = nanmax(MIAData.Data{i,1}(:));
                    h.Mia_Image.Axes(i,1).CLim = [Min Max];
                    h.Mia_Image.Settings.Scale(i,1).Visible = 'off';
                    h.Mia_Image.Settings.Scale(i,2).Visible = 'off';
                    h.Mia_Image.Settings.Scale_Text.Visible = 'off';
                case 3
                    h.Mia_Image.Axes(i,1).CLim = [str2double(h.Mia_Image.Settings.Scale(i,1).String) str2double(h.Mia_Image.Settings.Scale(i,2).String)];
                    h.Mia_Image.Settings.Scale(i,1).Visible = 'on';
                    h.Mia_Image.Settings.Scale(i,2).Visible = 'on';
                    h.Mia_Image.Settings.Scale_Text.Visible = 'on';
            end
            
            h.Mia_Image.Axes(i,1).XLim=[0 size(Image,2)]+0.5;
            h.Mia_Image.Axes(i,1).YLim=[0 size(Image,1)]+0.5;
        end
        
        %% Plots second image
        if size(MIAData.Data,1)>=i && size(MIAData.Data,2)>=2
            Frame=round(h.Mia_Image.Settings.Channel_Frame_Slider(i).Value);
            From= h.Plots.ROI(i).Position(1:2)+0.5;
            To=From+h.Plots.ROI(i).Position(3:4)-1;
            switch h.Mia_Image.Settings.Channel_Second(i).Value
                case 1 %%% Uses ROI of original image
                    if Frame>0
                        Image =MIAData.Data{i,1}(From(2):To(2),From(1):To(1),Frame);
                    elseif Frame==0
                        Frames = str2num(h.Mia_Image.Settings.ROI_Frames.String); %#ok<ST2NM>
                        Image = mean(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),Frames),3);
                    end
                case 2 %%% Uses ROI of corrected image (=> dynamic species)
                    if Frame>0
                        Image = MIAData.Data{i,2}(:,:,Frame);
                    elseif Frame==0
                        Frames = str2num(h.Mia_Image.Settings.ROI_Frames.String); %#ok<ST2NM>
                        Image = mean(MIAData.Data{i,2}(:,:,Frames),3);
                    end
                case 3 %%% Uses ROI of correctiond image (=> static species)
                    if Frame>0
                        Image=single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),Frame))-MIAData.Data{i,2}(:,:,Frame);
                    elseif Frame==0
                        Frames = str2num(h.Mia_Image.Settings.ROI_Frames.String); %#ok<ST2NM>
                        Image=mean(single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),Frames))-MIAData.Data{i,2}(:,:,Frames),3);
                    end
            end

            %%% Updates image
            h.Plots.Image(i,2).CData = Image;
            %%% Adjusts Scale of image
            switch h.Mia_Image.Settings.AutoScale.Value
                case 1
                    h.Mia_Image.Axes(i,2).CLimMode = 'auto';
                case 2
                    Min = nanmin(MIAData.Data{i,2}(:));
                    Max = nanmax(MIAData.Data{i,2}(:));
                    h.Mia_Image.Axes(i,2).CLim = [Min Max];
                case 3
                    h.Mia_Image.Axes(i,2).CLim = [str2double(h.Mia_Image.Settings.Scale(i,1).String) str2double(h.Mia_Image.Settings.Scale(i,2).String)];
            end

            %%% Sets transparency of NaN pixels to 100%;
            %%% Also sets AlphaData to right size
            h.Plots.Image(i,2).AlphaData = ~isnan(Image);
            if Frame>0 %%% For one frame, use manual selection and arbitrary region
                if ~isempty(MIAData.AR) 
                    h.Plots.Image(i,2).AlphaData = ((MIAData.AR{i,1}(:,:,Frame) & MIAData.MS{i})+AlphaRatio)/(1+AlphaRatio);
                elseif ~all(all(MIAData.MS{1}))
                    % AROI was imported without further ado
                    h.Plots.Image(i,2).AlphaData = (MIAData.MS{i}+AlphaRatio)/(1+AlphaRatio);
                else
                    h.Plots.Image(i,2).AlphaData = 1;
                end
            else %%% For all frames, only use manual selection
                if ~isempty(MIAData.AR)
                    h.Plots.Image(i,2).AlphaData = ((MIAData.AR{i,2}(:,:) & MIAData.MS{i})+AlphaRatio)/(1+AlphaRatio);
                elseif ~all(all(MIAData.MS{1}))
                    % AROI was imported without further ado
                    h.Plots.Image(i,2).AlphaData = (MIAData.MS{i}+AlphaRatio)/(1+AlphaRatio);
                else
                    h.Plots.Image(i,2).AlphaData = 1;
                end
            end
            %%% Updates axis
            h.Mia_Image.Axes(i,2).XLim=[0 size(Image,2)]+0.5;
            h.Mia_Image.Axes(i,2).YLim=[0 size(Image,1)]+0.5;
        end
        drawnow
    end
end

%% Plots ICS data
if any(mode==2)
    %%% Selects colormap
    switch h.Mia_ICS.Cor_Colormap.Value
        case 1
            Colormap=gray(64);
            h.Mia_ICS.Cor_Colormap.BackgroundColor = UserValues.Look.Control;
        case 2
            Colormap = jet(64);
            h.Mia_ICS.Cor_Colormap.BackgroundColor=UserValues.Look.Control;
        case 3
            Colormap=hot(64);
            h.Mia_ICS.Cor_Colormap.BackgroundColor=UserValues.Look.Control;
        case 4
            Colormap=hsv(64);
            h.Mia_ICS.Cor_Colormap.BackgroundColor=UserValues.Look.Control;
        case 5
            Colormap=gray(64).*repmat(h.Mia_ICS.Cor_Colormap.UserData,[64,1]);
            h.Mia_ICS.Cor_Colormap.BackgroundColor=h.Mia_ICS.Cor_Colormap.UserData;
    end
    %%% Determins frame to plot            
    Frame=round(h.Mia_ICS.Frame_Slider.Value); 
    %%% Determins correlation size to plot
    Size=str2double(h.Mia_ICS.Size.String);    
    %%% Updates correlationplots 
    for i=channel
        if ~isempty(MIAData.Cor{i,1})
            %%% Forces Size into bounds
            if Size>size(MIAData.Cor{i},1) || Size>size(MIAData.Cor{i},2)
                Size=min([size(MIAData.Cor{i},1),size(MIAData.Cor{i},2)]);
                h.Mia_ICS.Size.String=num2str(Size);
            end
            %%% Determines center of correlation
            X(1)=ceil(floor(size(MIAData.Cor{i,1},1)/2)-Size/2)+1;
            X(2)=ceil(floor(size(MIAData.Cor{i,1},1)/2)+Size/2);
            Y(1)=ceil(floor(size(MIAData.Cor{i,1},2)/2)-Size/2)+1;
            Y(2)=ceil(floor(size(MIAData.Cor{i,1},2)/2)+Size/2);
            %%% Plots average correlation, if frame 0 was selected
            if Frame==0
                Frames=str2num(h.Mia_ICS.Frames2Use.String); %#ok<ST2NM>
                Frames=Frames((Frames>0) & (Frames <= size(MIAData.Cor{i,1},3)));
                Image=mean(MIAData.Cor{i,1}(X(1):X(2),Y(1):Y(2),Frames),3);
            else
                Image=MIAData.Cor{i,1}(X(1):X(2),Y(1):Y(2),Frame);  
            end
            %%% Plots surface plot of correlation
            h.Plots.Cor(i,2).ZData=Image;
            %%% Resizes correlation and plots it as RGB
            Image=round(63*(Image-min(min(Image)))/(max(max(Image))-min(min(Image))))+1;
            Image(isnan(Image))=1;
            Image=reshape(Colormap(Image,:),[size(Image,1),size(Image,2),3]);
            h.Plots.Cor(i,1).CData=Image;
            h.Mia_ICS.Axes(i,1).XLim=[0 size(Image,2)]+0.5;
            h.Mia_ICS.Axes(i,1).YLim=[0 size(Image,1)]+0.5;
            
            %%% Calculate average of verteces surrounding the face in surf plot
            Image_Surf=h.Plots.Cor(i,2).ZData;
            Image_Surf=Image_Surf...
                +circshift(Image_Surf,[-1  0 0])...
                +circshift(Image_Surf,[-1 -1 0])...
                +circshift(Image_Surf,[ 0 -1 0]);
            %%% Resizes face intenity and plots it as RGB
            Image_Surf=round(63*(Image_Surf-min(min(Image_Surf)))/(max(max(Image_Surf))-min(min(Image_Surf))))+1;
            Image_Surf(isnan(Image_Surf))=1;
            Image_Surf=reshape(Colormap(Image_Surf,:),[size(Image_Surf,1),size(Image_Surf,2),3]);
            h.Plots.Cor(i,2).CData=Image_Surf;
                      
            %%% Calculates fit from table values
            Fit=reshape(Calc_RICS_Fit(i),[Size,Size]);             
            %%% Changes fit axes visibility
            h.Mia_ICS.Axes(i,3).Visible='on';
            h.Plots.Cor(i,3).Visible='on';
            h.Mia_ICS.Axes(i,4).Visible='off';
            h.Plots.Cor(i,4).Visible='off';
            h.Plots.Cor(i,5).Visible='off';
            h.Plots.Cor(i,6).Visible='off';
            h.Plots.Cor(i,7).Visible='off';
            %%% Determins fit plot type
            switch h.Mia_ICS.Fit_Type.Value
                case 1 %%% Plots fit surf plot
                    %%% Calculate average of verteces surrounding the face in fit surf plot
                    Fit_Faces=(Fit+circshift(Fit,[-1 0 0])+circshift(Fit,[-1 -1 0])+circshift(Fit,[0 -1 0]))/4;
                    %%% Resizes fit face intenity and applies colormap
                    Fit_Faces=round(63*(Fit_Faces-min(min(Fit_Faces)))/(max(max(Fit_Faces))-min(min(Fit_Faces))))+1;
                    Fit_Faces(isnan(Fit_Faces))=1;
                    Fit_Faces=reshape(Colormap(Fit_Faces,:),[size(Fit_Faces,1),size(Fit_Faces,2),3]);
                    %%% Links fit z-axes to data axes
                    h.Mia_ICS.Axes(i,3).ZLim=h.Mia_ICS.Axes(i,2).ZLim;
                case 2 %%% Plots fit residual surf plot
                    %%% Calculates standard error of mean or uses one
                    if Frame==0
                        SEM=std(MIAData.Cor{i,1}(X(1):X(2),Y(1):Y(2),Frames),0,3)/sqrt(numel(Frames));
                    else
                        SEM=ones(size(Fit,1),size(Fit,2));
                    end 
                    
                    
                    %%% Calculates weighted residuals
                    Fit=(h.Plots.Cor(i,2).ZData-Fit)./SEM;
                    %%% Calculate average of verteces surrounding the face in residual surf plot
                    Fit_Faces=(Fit+circshift(Fit,[-1 0 0])+circshift(Fit,[-1 -1 0])+circshift(Fit,[0 -1 0]))/4;
                    %%% Resizes residual face intenity and applies colormap
                    Fit_Faces=round(63*(Fit_Faces-min(min(Fit_Faces)))/(max(max(Fit_Faces))-min(min(Fit_Faces))))+1;

                    Fit_Faces=reshape(Colormap(Fit_Faces,:),[size(Fit_Faces,1),size(Fit_Faces,2),3]);
                    %%% Autosets z axes
                    h.Mia_ICS.Axes(i,3).ZLimMode='auto';
                case 3 %%% Plots fit surf plot with residuals as blue (neg), red(pos) and gray(neutal)
                    %%% Calculates standard error of mean or uses one
                    if Frame==0
                        SEM=std(MIAData.Cor{i,1}(X(1):X(2),Y(1):Y(2),Frames),0,3)/sqrt(numel(Frames));
                    else
                        SEM=ones(size(Fit,1),size(Fit,2));
                    end 
                    if any(any(SEM==0))
                        SEM=1;
                    end
                    %%% Calculates weighted residuals
                    Residuals=(h.Plots.Cor(i,2).ZData-Fit)./SEM;
                    %%% Calculate average of verteces surrounding the face in fit/residual surf plot
                    Residuals=(Residuals+circshift(Residuals,[-1 0 0])+circshift(Residuals,[-1 -1 0])+circshift(Residuals,[0 -1 0]))/4;
                    %%% Generates colormap blue-gray-red
                    Errormap=zeros(64,3);
                    Errormap(:,1)=[linspace(0,0.8,32), repmat(0.8,[1,32])]; 
                    Errormap(:,2)=[linspace(0,0.8,32), linspace(0.8,0,32)]; 
                    Errormap(:,3)=[repmat(0.8,[1,32]), linspace(0.8,0,32)];
                    %%% Applies colormap to residuals from -3 to +3
                    Residuals=round((Residuals+3)/6*64);
                    Residuals(Residuals<1)=1;
                    Residuals(Residuals>64)=64;
                    Fit_Faces=reshape(Errormap(Residuals(:),:),[size(Fit,1),size(Fit,2),3]);
                    %%% Links fit z-axes to data axes
                    h.Mia_ICS.Axes(i,3).ZLim=h.Mia_ICS.Axes(i,2).ZLim;
                case 4 %%% Plots x and y axes of the fit and the data
                    h.Mia_ICS.Axes(i,3).Visible='off';
                    h.Plots.Cor(i,3).Visible='off';                    
                    h.Mia_ICS.Axes(i,4).Visible='on';
                    h.Plots.Cor(i,4).XData=(1:size(Fit,2))-round(size(Fit,2)/2);
                    h.Plots.Cor(i,4).YData=h.Plots.Cor(i,2).ZData(round(size(Fit,2)/2),:);
                    h.Plots.Cor(i,4).Visible='on';
                    h.Plots.Cor(i,5).XData=(1:size(Fit,2))-round(size(Fit,2)/2);
                    h.Plots.Cor(i,5).YData=Fit(round(size(Fit,2)/2),:);
                    h.Plots.Cor(i,5).Visible='on';
                    h.Plots.Cor(i,6).XData=(1:size(Fit,1))-round(size(Fit,1)/2);
                    h.Plots.Cor(i,6).YData=h.Plots.Cor(i,2).ZData(:,round(size(Fit,1)/2));
                    h.Plots.Cor(i,6).Visible='on';
                    h.Plots.Cor(i,7).XData=(1:size(Fit,1))-round(size(Fit,1)/2);
                    h.Plots.Cor(i,7).YData=Fit(:,round(size(Fit,1)/2));
                    h.Plots.Cor(i,7).Visible='on';
                    
                    Fit_Faces=Fit;
            end
            %%% Plots fit and applies face color
            h.Plots.Cor(i,3).ZData=Fit;
            h.Plots.Cor(i,3).CData=Fit_Faces;            
        end        
    end

end

%% Plots N&B data
if any(mode==3) && isfield(MIAData.NB,'PCH')
    %%% Selects channel to plot
    i=h.Mia_NB.Image.Channel.Value;
    %%% Selects nonempty channel
    if size(MIAData.NB.PCH,2)<i || isempty(MIAData.NB.PCH{i})
        k=1;
        while isempty(MIAData.NB.PCH{k}); k=k+1;end
        i=k;
        h.Mia_NB.Image.Channel.Value=i;
    end
    %% Updates intensity, number and brightness plots
    %%% Images intensity in kHz in borders determined by threshold
    h.Plots.NB(1).CData=MIAData.NB.Int{i}/str2double(h.Mia_NB.Image.Pixel.String)*10^3;
    h.Mia_NB.Axes(1).CLim=[str2double(h.Mia_NB.Image.Hist(1,1).String),str2double(h.Mia_NB.Image.Hist(2,1).String)];
    h.Mia_NB.Axes(1).XLim=[0 size(MIAData.NB.Int{i},2)]+0.5;
    h.Mia_NB.Axes(1).YLim=[0 size(MIAData.NB.Int{i},1)]+0.5;    
    %%% Images number in borders determined by threshold
    h.Plots.NB(2).CData=MIAData.NB.Num{i};
    h.Mia_NB.Axes(2).CLim=[str2double(h.Mia_NB.Image.Hist(1,2).String),str2double(h.Mia_NB.Image.Hist(2,2).String)];
    h.Mia_NB.Axes(2).XLim=[0 size(MIAData.NB.Int{i},2)]+0.5;
    h.Mia_NB.Axes(2).YLim=[0 size(MIAData.NB.Int{i},1)]+0.5;
    %%% Images brightness in kHz in borders determined by threshold
    h.Plots.NB(3).CData=MIAData.NB.Eps{i}/str2double(h.Mia_NB.Image.Pixel.String)*10^3;
    h.Mia_NB.Axes(3).CLim=[str2double(h.Mia_NB.Image.Hist(1,3).String),str2double(h.Mia_NB.Image.Hist(2,3).String)];
    h.Mia_NB.Axes(3).XLim=[0 size(MIAData.NB.Int{i},2)]+0.5;
    h.Mia_NB.Axes(3).YLim=[0 size(MIAData.NB.Int{i},1)]+0.5;

    %% Plots 1D histogram of selected parameter
    %%% Removes pixel determined by thresholds
    MIAData.NB.Use=((MIAData.NB.Int{i}/str2double(h.Mia_NB.Image.Pixel.String)*10^3>=str2double(h.Mia_NB.Image.Hist(1,1).String) &... %%% Lower int TH
        MIAData.NB.Int{i}/str2double(h.Mia_NB.Image.Pixel.String)*10^3<=str2double(h.Mia_NB.Image.Hist(2,1).String)) |... %%% Upper in TH
        repmat(~h.Mia_NB.Image.UseTH(1).Value,size(MIAData.NB.Int{i}))) &... %%% Do not apply if checked
        ((MIAData.NB.Num{i}>=str2double(h.Mia_NB.Image.Hist(1,2).String) &... %%% Lower number TH
        MIAData.NB.Num{i}<=str2double(h.Mia_NB.Image.Hist(2,2).String)) |... %%% Upper number TH
        repmat(~h.Mia_NB.Image.UseTH(2).Value,size(MIAData.NB.Int{i}))) &...%%% Do not apply if checked
        ((MIAData.NB.Eps{i}/str2double(h.Mia_NB.Image.Pixel.String)*10^3>=str2double(h.Mia_NB.Image.Hist(1,3).String) &... %%% Lower brightness TH
        MIAData.NB.Eps{i}/str2double(h.Mia_NB.Image.Pixel.String)*10^3<=str2double(h.Mia_NB.Image.Hist(2,3).String)) |... %%% Upper brightness TH
        repmat(~h.Mia_NB.Image.UseTH(3).Value,size(MIAData.NB.Int{i}))); %%% Do not apply if checked
    %%% Plots bar histogram
    switch h.Mia_NB.Hist1D.Value
        case 1 %%% PCH histogram; Not threshold
            h.Plots.NB(4).YData=MIAData.NB.PCH{i};
            h.Plots.NB(4).XData=0:(numel(MIAData.NB.PCH{i})-1);
            h.Mia_NB.Axes(4).XLabel.String='Counts per pixel';
            h.Mia_NB.Hist1D_Text.String='';
        case 2 %%% Intensity histogram
            h.Plots.NB(4).XData=linspace(str2double(h.Mia_NB.Image.Hist(1,1).String),str2double(h.Mia_NB.Image.Hist(2,1).String),str2double(h.Mia_NB.Image.Hist(3,1).String));
            h.Plots.NB(4).YData=histc(MIAData.NB.Int{i}(MIAData.NB.Use)/str2double(h.Mia_NB.Image.Pixel.String)*10^3,h.Plots.NB(4).XData);
            h.Mia_NB.Axes(4).XLabel.String='Intensity [kHz]';
            h.Mia_NB.Hist1D_Text.String=[num2str(mean(MIAData.NB.Int{i}(MIAData.NB.Use)/str2double(h.Mia_NB.Image.Pixel.String)*10^3),'%6.3f') '+/-' num2str(std(MIAData.NB.Int{i}(MIAData.NB.Use)/str2double(h.Mia_NB.Image.Pixel.String)*10^3),'%6.3f') ' kHz'];
        case 3 %%% Number histogram
            h.Plots.NB(4).XData=linspace(str2double(h.Mia_NB.Image.Hist(1,2).String),str2double(h.Mia_NB.Image.Hist(2,2).String),str2double(h.Mia_NB.Image.Hist(3,2).String));
            h.Plots.NB(4).YData=histc(MIAData.NB.Num{i}(MIAData.NB.Use),h.Plots.NB(4).XData);
            h.Mia_NB.Axes(4).XLabel.String='Number';
            h.Mia_NB.Hist1D_Text.String=[num2str(mean(MIAData.NB.Num{i}(MIAData.NB.Use)),'%6.3f') '+/-' num2str(std(MIAData.NB.Num{i}(MIAData.NB.Use)),'%6.3f')];
        case 4 %%% Brightness histogram
            h.Plots.NB(4).XData=linspace(str2double(h.Mia_NB.Image.Hist(1,3).String),str2double(h.Mia_NB.Image.Hist(2,3).String),str2double(h.Mia_NB.Image.Hist(3,3).String));
            h.Plots.NB(4).YData=histc(MIAData.NB.Eps{i}(MIAData.NB.Use)/str2double(h.Mia_NB.Image.Pixel.String)*10^3,h.Plots.NB(4).XData);
            h.Mia_NB.Axes(4).XLabel.String='Brightness [kHz]';
            h.Mia_NB.Hist1D_Text.String=[num2str(mean(MIAData.NB.Eps{i}(MIAData.NB.Use)/str2double(h.Mia_NB.Image.Pixel.String)*10^3),'%6.3f') '+/-' num2str(std(MIAData.NB.Eps{i}(MIAData.NB.Use)/str2double(h.Mia_NB.Image.Pixel.String)*10^3),'%6.3f') ' kHz'];
    end
    h.Mia_NB.Hist1D_Text.Position(1)=0.99-h.Mia_NB.Hist1D_Text.Extent(3);
    %%% Set X-Limit; uses 1/2 of binsize to not cut first and last bar
    h.Mia_NB.Axes(4).XLim=[h.Plots.NB(4).XData(1)-diff(h.Plots.NB(4).XData(1:2)/2),...
                           h.Plots.NB(4).XData(end)+diff(h.Plots.NB(4).XData(1:2))/2];
                                              
    %% Plots 2D histogram of selected parameters
    %%% Selects Colormap
    switch h.Mia_NB.Hist2D(3).Value
        case 1
            Color=jet(64);
        case 2
            Color=hot(64);
        case 3
            Color=hsv(64);
        case 4
            Color=gray(64);
    end
    Color=[h.Mia_NB.Hist2D(3).BackgroundColor; Color];
    h.Mia_NB.Axes(5).XColor = h.Mia_NB.Hist2D(3).ForegroundColor;
    h.Mia_NB.Axes(5).YColor = h.Mia_NB.Hist2D(3).ForegroundColor;
   
    %%% Selects x axis bounds and bins
    MinX=str2double(h.Mia_NB.Image.Hist(1,h.Mia_NB.Hist2D(2).Value).String);
    MaxX=str2double(h.Mia_NB.Image.Hist(2,h.Mia_NB.Hist2D(2).Value).String);
    BinX=str2double(h.Mia_NB.Image.Hist(3,h.Mia_NB.Hist2D(2).Value).String);
    %%% Determins parameter for x axis
    switch h.Mia_NB.Hist2D(2).Value
        case 1
            X=MIAData.NB.Int{i}(MIAData.NB.Use)/str2double(h.Mia_NB.Image.Pixel.String)*10^3;
            h.Mia_NB.Axes(5).XLabel.String='Intensity [kHz]';
        case 2
            X=MIAData.NB.Num{i}(MIAData.NB.Use);
            h.Mia_NB.Axes(5).XLabel.String='Number';
        case 3
            X=MIAData.NB.Eps{i}(MIAData.NB.Use)/str2double(h.Mia_NB.Image.Pixel.String)*10^3;
            h.Mia_NB.Axes(5).XLabel.String='Brightness [kHz]';
    end
    h.Mia_NB.Axes(5).XColor = UserValues.Look.Fore;
    h.Mia_NB.Axes(5).XLabel.Color = UserValues.Look.Fore;
    %%% Scales x data into bins
    X=floor(BinX*(X-MinX)/(MaxX-MinX));
    
    %%% Selects y axis bounds and bins
    MinY=str2double(h.Mia_NB.Image.Hist(1,h.Mia_NB.Hist2D(1).Value).String);
    MaxY=str2double(h.Mia_NB.Image.Hist(2,h.Mia_NB.Hist2D(1).Value).String);
    BinY=str2double(h.Mia_NB.Image.Hist(3,h.Mia_NB.Hist2D(1).Value).String);
    %%% Determins parameter for y axis
    switch h.Mia_NB.Hist2D(1).Value
        case 1
            Y=MIAData.NB.Int{i}(MIAData.NB.Use)/str2double(h.Mia_NB.Image.Pixel.String)*10^3;
            h.Mia_NB.Axes(5).YLabel.String='Intensity [kHz]';
        case 2
            Y=MIAData.NB.Num{i}(MIAData.NB.Use);
            h.Mia_NB.Axes(5).YLabel.String='Number';
        case 3
            Y=MIAData.NB.Eps{i}(MIAData.NB.Use)/str2double(h.Mia_NB.Image.Pixel.String)*10^3;
            h.Mia_NB.Axes(5).YLabel.String='Brightness [kHz]';
    end
    h.Mia_NB.Axes(5).YColor = UserValues.Look.Fore;
    h.Mia_NB.Axes(5).YLabel.Color = UserValues.Look.Fore;
    %%% Scales y data into bins
    Y=floor(BinY*(Y-MinY)/(MaxY-MinY));
    
    %%% Removes pixels with Y<0, due to the way the histogram is calculated
    X=X(Y>0); Y=Y(Y>0);X=X(Y<BinY); Y=Y(Y<BinY);
    Y=Y(X>0); X=X(X>0);Y=Y(X<BinX); X=X(X<BinX);
    %%% Calculates 2D histogram
    if ~isempty(X)
        Image=reshape(histc(Y+(BinY*(X-1)),1:(BinX*BinY)),[BinY,BinX]);
        Image=ceil(64*Image/max(Image(:)))+1;
        Image=reshape(Color(Image,:),[BinY, BinX, 3]);
        %%% Plots and scales 2D histogram
        h.Plots.NB(5).CData=Image;
        h.Plots.NB(5).XData=linspace(MinX,MaxX,BinX);
        h.Plots.NB(5).YData=linspace(MinY,MaxY,BinY);
        h.Mia_NB.Axes(5).XLim=[MinX MaxX]-(MaxX-MinX)/(2*BinX);
        h.Mia_NB.Axes(5).YLim=[MinY MaxY]-(MaxY-MinY)/(2*BinY);        
    end
end

%% Plots additional properties
if any(mode==4)
    
    %% Plots first color if it exists
    if isempty(MIAData.Data) %%% Resets data to standard, if no file is loaded
        h.Plots.Additional_Axes(1,1).XData = [0 1];
        h.Plots.Additional_Axes(1,1).YData = [0 0];
        h.Plots.Additional_Axes(2,1).XData = [0 1];
        h.Plots.Additional_Axes(2,1).YData = [0 0];
        h.Plots.Int(1,1).XData = [0 1];
        h.Plots.Int(1,1).YData = [0 0];
        h.Plots.PCH(1,1).XData = [0 1];
        h.Plots.PCH(1,1).YData = [0 0];
        h.Plots.Int(1,2).XData = [0 1];
        h.Plots.Int(1,2).YData = [0 0];
        h.Plots.PCH(1,2).XData = [0 1];
        h.Plots.PCH(1,2).YData = [0 0];
    else
        %% Updates Intensity and PCH plots on Image Tab
        if h.Mia_Image.Intensity_Axes.XLabel.UserData == 0
            h.Plots.Int(1,1).XData = (1:size(MIAData.Data{1,1},3))*str2double(h.Mia_Image.Settings.Image_Frame.String);
            h.Plots.Int(1,2).XData = (1:size(MIAData.Data{1,1},3))*str2double(h.Mia_Image.Settings.Image_Frame.String);
            h.Mia_Image.Intensity_Axes.XLabel.String = 'Time [s]';
        else
            h.Plots.Int(1,1).XData = 1:size(MIAData.Data{1,1},3);
            h.Plots.Int(1,2).XData = 1:size(MIAData.Data{1,2},3);
            h.Mia_Image.Intensity_Axes.XLabel.String = 'Frame';
        end
        h.Mia_Image.Intensity_Axes.XLim = [h.Plots.Int(1,1).XData(1) h.Plots.Int(1,1).XData(end)+0.00001];
        
        
        if h.Mia_Image.Intensity_Axes.YLabel.UserData == 0
            h.Plots.Int(1,1).YData = mean(mean(MIAData.Data{1,1},2),1);
            
            Data = MIAData.Data{1,2};
            if ~isempty(MIAData.AR)
                Data(~(MIAData.AR{1,1} & repmat(MIAData.MS{1},1,1,size(MIAData.AR{1,1},3)))) = NaN;
            end
            h.Plots.Int(1,2).YData = nanmean(nanmean(Data,2),1);
            
            h.Mia_Image.Intensity_Axes.YLabel.String = 'Average Frame Counts';
        else
            h.Plots.Int(1,1).YData = mean(mean(MIAData.Data{1,1},2),1)/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1000;
            Data = MIAData.Data{1,2};
            if ~isempty(MIAData.AR)
                Data(~(MIAData.AR{1,1} & repmat(MIAData.MS{1},1,1,size(MIAData.AR{1,1},3)))) = NaN;
            end
            h.Plots.Int(1,2).YData = nanmean(nanmean(Data,2),1)/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1000;
            h.Mia_Image.Intensity_Axes.YLabel.String = 'Average Frame Countrate [kHz]';
        end
        
        if h.Mia_Image.DoPCH.Value
            
            if isempty(MIAData.PCH)
                MIAData.PCH{1} = histc(double(MIAData.Data{1,1}(:)), 0:double(max(MIAData.Data{1,1}(:))));
            end
            h.Plots.PCH(1,1).XData = 0:(numel(MIAData.PCH{1})-1);
            h.Plots.PCH(1,1).YData = MIAData.PCH{1};
            Max = max(MIAData.Data{1,2}(:));
            h.Plots.PCH(1,2).XData = 0:Max;
            if ~isempty(MIAData.AR)
                h.Plots.PCH(1,2).YData = histc(MIAData.Data{1,2}(MIAData.AR{1,1} & repmat(MIAData.MS{1},1,1,size(MIAData.AR{1,1},3))), 0:Max);
            else
                h.Plots.PCH(1,2).YData = 0*h.Plots.PCH(1,2).XData;
            end
            if h.Mia_Image.PCH_Axes.YLabel.UserData == 0
                h.Mia_Image.PCH_Axes.YScale = 'Lin';
            else
                h.Mia_Image.PCH_Axes.YScale = 'Log';
            end
        else
           h.Plots.PCH(1,1).XData = [0 1];
           h.Plots.PCH(1,1).YData = [0 0];
           h.Plots.PCH(1,2).XData = [0 1];
           h.Plots.PCH(1,2).YData = [0 0];
        end
        
        
        %% Updates first plot
        h.Plots.Additional_Axes(1,1).XData = 1:size(MIAData.Data{1,h.Mia_Additional.Plot_Popup(1,2).Value},3);
        h.Mia_Additional.Axes(1).XLabel.String = 'Frame';
        h.Mia_Additional.Axes(1).YScale = 'Lin';
        switch h.Mia_Additional.Plot_Popup(1,1).Value
            case 1 %%% Counts/Countrate
                h.Plots.Additional_Axes(1,1).YData = mean(nanmean(single(MIAData.Data{1,h.Mia_Additional.Plot_Popup(1,2).Value}),2),1);
                if h.Mia_Additional.Axes(1).YLabel.UserData == 1
                    h.Plots.Additional_Axes(1,1).YData = h.Plots.Additional_Axes(1,1).YData/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1000;
                    h.Mia_Additional.Axes(1).YLabel.String = 'Average Frame Countrate [kHz]';
                else
                    h.Mia_Additional.Axes(1).YLabel.String = 'Average Frame Counts';
                end   
            case 2 %%% Variance
                h.Plots.Additional_Axes(1,1).YData = var(reshape(single(MIAData.Data{1,h.Mia_Additional.Plot_Popup(1,2).Value}),[],size(MIAData.Data{1,h.Mia_Additional.Plot_Popup(1,2).Value},3)));
                h.Mia_Additional.Axes(1).YLabel.String = 'Spatial Variance';
            case 3 %%% PCH
                h.Plots.Additional_Axes(1,1).XData = h.Plots.PCH(1,h.Mia_Additional.Plot_Popup(1,2).Value).XData;
                h.Plots.Additional_Axes(1,1).YData = h.Plots.PCH(1,h.Mia_Additional.Plot_Popup(1,2).Value).YData;
                h.Mia_Additional.Axes(1).XLabel.String = 'Counts';
                h.Mia_Additional.Axes(1).YLabel.String = 'Frequency';
                if h.Mia_Additional.Axes(1).YLabel.UserData == 1
                    h.Mia_Additional.Axes(1).YScale = 'Log';
                else
                    h.Mia_Additional.Axes(1).YScale = 'Lin';
                end
        end
        %% Updates second plot
        h.Plots.Additional_Axes(2,1).XData = 1:size(MIAData.Data{1,h.Mia_Additional.Plot_Popup(2,2).Value},3);
        h.Mia_Additional.Axes(2).XLabel.String = 'Frame';
        h.Mia_Additional.Axes(2).YScale = 'Lin';
        switch h.Mia_Additional.Plot_Popup(2,1).Value
            case 1 %%% Counts/Countrate
                h.Plots.Additional_Axes(2,1).YData = mean(mean(MIAData.Data{1,h.Mia_Additional.Plot_Popup(2,2).Value},2),1);
                if h.Mia_Additional.Axes(2).YLabel.UserData == 1
                    h.Plots.Additional_Axes(2,1).YData = h.Plots.Additional_Axes(2,1).YData/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1000;
                    h.Mia_Additional.Axes(2).YLabel.String = 'Average Frames Countrate [kHz]';
                else
                    h.Mia_Additional.Axes(2).YLabel.String = 'Average Frame Counts';
                end
            case 2 %%% Variance
                h.Plots.Additional_Axes(2,1).YData = var(reshape(MIAData.Data{1,h.Mia_Additional.Plot_Popup(2,2).Value},[],size(MIAData.Data{1,h.Mia_Additional.Plot_Popup(2,2).Value},3)));
                h.Mia_Additional.Axes(2).YLabel.String = 'Spatial Variance';
            case 3 %%% PCH
                h.Plots.Additional_Axes(2,1).XData = h.Plots.PCH(1,h.Mia_Additional.Plot_Popup(1,2).Value).XData;
                h.Plots.Additional_Axes(2,1).YData = h.Plots.PCH(1,h.Mia_Additional.Plot_Popup(1,2).Value).YData;
                h.Mia_Additional.Axes(2).XLabel.String = 'Counts';
                h.Mia_Additional.Axes(2).YLabel.String = 'Frequency';
                if h.Mia_Additional.Axes(2).YLabel.UserData == 1
                    h.Mia_Additional.Axes(2).YScale = 'Log';
                else
                    h.Mia_Additional.Axes(2).YScale = 'Lin';
                end
        end
        %% Updates image plot 
        switch h.Mia_Additional.Plot_Popup(1,3).Value
            case 1 %%% Counts/Countrate
                Data = mean(single(MIAData.Data{1,1}),3);
            case 2 %%% Variance
                Data = var(single(MIAData.Data{1,1}),0,3);
            case 3 %%% Maximum Projection
                Data = max(MIAData.Data{1,1},[],3);
        end
        h.Plots.Additional_Image(1).CData = Data;
        h.Mia_Additional.Image(1).XLim = [0.5 size(Data,1)+0.5];
        h.Mia_Additional.Image(1).YLim = [0.5 size(Data,2)+0.5];
        
    end

    %% Plots second color if it exists
    if isempty(MIAData.Data) || size(MIAData.Data,1)<2
        h.Plots.Additional_Axes(1,2).XData = [0 1];
        h.Plots.Additional_Axes(1,2).YData = [0 0];
        h.Plots.Additional_Axes(1,2).Visible = 'off';
        h.Plots.Additional_Axes(2,2).XData = [0 1];
        h.Plots.Additional_Axes(2,2).YData = [0 0];
        h.Plots.Additional_Axes(2,2).Visible = 'off';
        h.Plots.Int(2,1).XData = [0 1];
        h.Plots.Int(2,1).YData = [0 0];
        h.Plots.Int(2,1).Visible = 'off';
        h.Plots.PCH(2,1).XData = [0 1];
        h.Plots.PCH(2,1).YData = [0 0];
        h.Plots.PCH(2,1).Visible = 'off';
        h.Plots.Int(2,2).XData = [0 1];
        h.Plots.Int(2,2).YData = [0 0];
        h.Plots.Int(2,2).Visible = 'off';
        h.Plots.PCH(2,2).XData = [0 1];
        h.Plots.PCH(2,2).YData = [0 0];
        h.Plots.PCH(2,2).Visible = 'off';
    else
        %% Updates Intensity and PCH plots on Image Tab
        %% Updates Intensity and PCH plots on Image Tab
        if h.Mia_Image.Intensity_Axes.XLabel.UserData == 0
            h.Plots.Int(2,1).XData = (1:size(MIAData.Data{2,1},3))*str2double(h.Mia_Image.Settings.Image_Frame.String);
            h.Plots.Int(2,2).XData = (1:size(MIAData.Data{2,1},3))*str2double(h.Mia_Image.Settings.Image_Frame.String);
            h.Mia_Image.Intensity_Axes.XLabel.String = 'Time [s]';
        else
            h.Plots.Int(2,1).XData = 1:size(MIAData.Data{2,1},3);
            h.Plots.Int(2,2).XData = 1:size(MIAData.Data{2,2},3);
            h.Mia_Image.Intensity_Axes.XLabel.String = 'Frame';
        end
        h.Plots.Int(2,1).Visible = 'on';
        h.Plots.Int(2,2).Visible = 'on';
        if h.Mia_Image.Intensity_Axes.YLabel.UserData == 0
            h.Plots.Int(2,1).YData = mean(mean(MIAData.Data{2,1},2),1);
            Data = MIAData.Data{2,2};
            if ~isempty(MIAData.AR)
                Data(~(MIAData.AR{2,1} & repmat(MIAData.MS{2},1,1,size(MIAData.AR{2,1}(1,:,:),3)))) = NaN;
            end
            h.Plots.Int(2,2).YData = nanmean(nanmean(Data,2),1);
        else
            h.Plots.Int(2,1).YData = mean(mean(MIAData.Data{2,1},2),1)/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1000;
            Data = MIAData.Data{2,2};
            if ~isempty(MIAData.AR)
                Data(~(MIAData.AR{2,1} & repmat(MIAData.MS{2},1,1,size(MIAData.AR{2,1}(1,:,:),3)))) = NaN;
            end
            h.Plots.Int(2,2).YData = nanmean(nanmean(Data,2),1)/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1000;
            
        end
        
        if h.Mia_Image.DoPCH.Value
            
            if numel(MIAData.PCH,1)<2
                MIAData.PCH{2} = histc(double(MIAData.Data{2,1}(:)), 0:max(double(MIAData.Data{2,1}(:))));
            end
            h.Plots.PCH(2,1).XData = 0:(numel(MIAData.PCH{2})-1);
            h.Plots.PCH(2,1).YData = MIAData.PCH{2};
            h.Plots.PCH(2,1).Visible = 'on';
            Max = max(MIAData.Data{2,2}(:));
             h.Plots.PCH(2,2).XData = 0:Max;
            if ~isempty(MIAData.AR)
                h.Plots.PCH(2,2).YData = histc(MIAData.Data{2,2}(MIAData.AR{2,1} & repmat(MIAData.MS{2},1,1,size(MIAData.AR{2,1},3))), 0:Max);
            else
                h.Plots.PCH(2,2).YData = 0*h.Plots.PCH(2,2).XData;
            end
            h.Plots.PCH(2,2).Visible = 'on';
        else
           h.Plots.PCH(2,1).XData = [0 1];
           h.Plots.PCH(2,1).YData = [0 0];
           h.Plots.PCH(2,2).XData = [0 1];
           h.Plots.PCH(2,2).YData = [0 0];
        end
        
        %% Updates first plot
        h.Plots.Additional_Axes(1,2).XData = 1:size(MIAData.Data{2,h.Mia_Additional.Plot_Popup(1,2).Value},3);
        h.Plots.Additional_Axes(1,2).Visible = 'on';
        switch h.Mia_Additional.Plot_Popup(1,1).Value
            case 1 %%% Counts/Countrate
                h.Plots.Additional_Axes(1,2).YData = mean(mean(single(MIAData.Data{2,h.Mia_Additional.Plot_Popup(1,2).Value}),2),1);
                if h.Mia_Additional.Axes(1).YLabel.UserData == 1
                    h.Plots.Additional_Axes(1,2).YData = h.Plots.Additional_Axes(1,2).YData/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1000;
                end
            case 2 %%% Variance
                h.Plots.Additional_Axes(1,2).YData = var(reshape(single(MIAData.Data{2,h.Mia_Additional.Plot_Popup(1,2).Value}),[],size(MIAData.Data{2,h.Mia_Additional.Plot_Popup(1,2).Value},3)));
            case 3 %%% PCH
                h.Plots.Additional_Axes(1,2).XData = h.Plots.PCH(1,h.Mia_Additional.Plot_Popup(2,2).Value).XData;
                h.Plots.Additional_Axes(1,2).YData = h.Plots.PCH(1,h.Mia_Additional.Plot_Popup(2,2).Value).YData;
        end
        %% Updates second plot
        h.Plots.Additional_Axes(2,2).XData = 1:size(MIAData.Data{2,h.Mia_Additional.Plot_Popup(2,2).Value},3);
        h.Plots.Additional_Axes(2,2).Visible = 'on';
        switch h.Mia_Additional.Plot_Popup(2,1).Value
            case 1 %%% Counts/Countrate
                h.Plots.Additional_Axes(2,2).YData = mean(mean(MIAData.Data{2,h.Mia_Additional.Plot_Popup(2,2).Value},2),1);
                if h.Mia_Additional.Axes(2).YLabel.UserData == 1
                    h.Plots.Additional_Axes(2,2).YData = h.Plots.Additional_Axes(2,2).YData/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1000;
                end
            case 2 %%% Variance
                h.Plots.Additional_Axes(2,2).YData = var(reshape(MIAData.Data{2,h.Mia_Additional.Plot_Popup(2,2).Value},[],size(MIAData.Data{2,h.Mia_Additional.Plot_Popup(2,2).Value},3)));
            case 3 %%% PCH
                h.Plots.Additional_Axes(2,2).XData = h.Plots.PCH(1,h.Mia_Additional.Plot_Popup(2,2).Value).XData;
                h.Plots.Additional_Axes(2,2).YData = h.Plots.PCH(1,h.Mia_Additional.Plot_Popup(2,2).Value).YData;
        end
        %% Updates image plot
        switch h.Mia_Additional.Plot_Popup(2,3).Value
            case 1 %%% Counts/Countrate
                Data = mean(single(MIAData.Data{2,1}),3);
            case 2 %%% Variance
                Data = var(single(MIAData.Data{2,1}),0,3);
            case 3 %%% Maximum Projection
                Data = max(MIAData.Data{2,1},[],3);
            case 4 %%% Combines both colors
                Data = mean(single(MIAData.Data{1,1}),3);
                Data(:,:,2) = (Data-min(Data(:)))/(max(Data(:))-min(Data(:)));
                Data2 = mean(single(MIAData.Data{2,1}),3);
                Data2 = repmat((Data2-min(Data2(:)))/(max(Data2(:))-min(Data2(:))),1,1,3);
                Data(:,:,[1 3]) = Data2(:,:,[1 3]);
            case 5 %%% Ratio of both colors
                Data = mean(single(MIAData.Data{1,1}),3)./mean(single(MIAData.Data{2,1}),3);
                Data(isnan(Data))= nanmax(Data(:));
            case 6 %%% Ratio of both colors
                Data = (mean(single(MIAData.Data{1,1}),3)/mean2(single(MIAData.Data{1,1})))./(mean(single(MIAData.Data{2,1}),3)/mean2(single(MIAData.Data{2,1})));
                Data(isnan(Data))= nanmax(Data(:));
        end
        h.Plots.Additional_Image(2).CData = Data;
        h.Mia_Additional.Image(2).XLim = [0.5 size(Data,1)+0.5];
        h.Mia_Additional.Image(2).YLim = [0.5 size(Data,2)+0.5];

    end
    
end

%% Plots TICS data
if any(mode==5)
    for i=1:3
        %%% 1&3: ACF 1&2
        %%% 2:   CCF
        if size(MIAData.TICS.Data,2)>=i && ~isempty(MIAData.TICS.Data{i})
            % different images to be plotted
            %%% G(first lag)
            G1 = MIAData.TICS.Data{i}(:,:,1);
            %%% G(first lag)./mean(Counts)
            switch i
                case 1 %ACF1
                    brightness = MIAData.TICS.Data{1}(:,:,1).*mean(MIAData.Data{1,2}(:,:,str2num(h.Mia_Image.Settings.ROI_Frames.String)),3); %#ok<ST2NM>
                    counts = MIAData.TICS.Int{1};
                case 2 %CCF
                    brightness = MIAData.TICS.Data{2}(:,:,1).*...
                        (mean(MIAData.Data{1,2}(:,:,str2num(h.Mia_Image.Settings.ROI_Frames.String)),3)+... %#ok<ST2NM>
                        mean(MIAData.Data{2,2}(:,:,str2num(h.Mia_Image.Settings.ROI_Frames.String)),3))/2; %#ok<ST2NM>
                    counts = (MIAData.TICS.Int{1}+MIAData.TICS.Int{2});
                case 3 %ACF2
                    brightness = MIAData.TICS.Data{3}(:,:,1).*mean(MIAData.Data{2,2}(:,:,str2num(h.Mia_Image.Settings.ROI_Frames.String)),3); %#ok<ST2NM>
                    counts = MIAData.TICS.Int{2};
            end
            
            %%% Find G(0)/2
            halflife = (size(MIAData.TICS.Data{i},3)-sum(cumsum(MIAData.TICS.Data{i}./repmat(MIAData.TICS.Data{i}(:,:,1),1,1,size(MIAData.TICS.Data{i},3))<0.5,3)~=0,3)).*...
                str2double(h.Mia_Image.Settings.Image_Frame.String);
            
            
            % reset the values
            if ~isempty(obj)
                if strcmp(obj.Tag, 'DoTICS') || strcmp(obj.Tag, 'Reset')
                    % store or reset the values for each correlation
                    MIAData.TICS.Thresholds{i}(1,1) = min(min(G1));
                    MIAData.TICS.Thresholds{i}(1,2) = max(max(G1));
                    MIAData.TICS.Thresholds{i}(2,1) = min(min(brightness));
                    MIAData.TICS.Thresholds{i}(2,2) = max(max(brightness));
                    MIAData.TICS.Thresholds{i}(3,1) = min(min(counts));
                    MIAData.TICS.Thresholds{i}(3,2) = max(max(counts));
                    MIAData.TICS.Thresholds{i}(4,1) = min(min(halflife));
                    MIAData.TICS.Thresholds{i}(4,2) = max(max(halflife));
                    
                    % display the values of the popupmenu selected correlation
                    h.Mia_TICS.Threshold_G1_Min_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(1,1));
                    h.Mia_TICS.Threshold_G1_Max_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(1,2));
                    h.Mia_TICS.Threshold_brightness_Min_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(2,1));
                    h.Mia_TICS.Threshold_brightness_Max_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(2,2));
                    h.Mia_TICS.Threshold_counts_Min_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(3,1));
                    h.Mia_TICS.Threshold_counts_Max_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(3,2));
                    h.Mia_TICS.Threshold_halflife_Min_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(4,1));
                    h.Mia_TICS.Threshold_halflife_Max_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(4,2));
                elseif strcmp(obj.Tag, 'SelectCor')
                    % display the values of the popupmenu selected correlation
                    h.Mia_TICS.Threshold_G1_Min_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(1,1));
                    h.Mia_TICS.Threshold_G1_Max_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(1,2));
                    h.Mia_TICS.Threshold_brightness_Min_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(2,1));
                    h.Mia_TICS.Threshold_brightness_Max_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(2,2));
                    h.Mia_TICS.Threshold_counts_Min_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(3,1));
                    h.Mia_TICS.Threshold_counts_Max_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(3,2));
                    h.Mia_TICS.Threshold_halflife_Min_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(4,1));
                    h.Mia_TICS.Threshold_halflife_Max_Edit.String = num2str(MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(4,2));
                elseif strcmp(obj.Tag, 'thresholds')
                    % user changed threshold value
                    MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(1,1) = str2num(h.Mia_TICS.Threshold_G1_Min_Edit.String);
                    MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(1,2) = str2num(h.Mia_TICS.Threshold_G1_Max_Edit.String);
                    MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(2,1) = str2num(h.Mia_TICS.Threshold_brightness_Min_Edit.String);
                    MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(2,2) = str2num(h.Mia_TICS.Threshold_brightness_Max_Edit.String);
                    MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(3,1) = str2num(h.Mia_TICS.Threshold_counts_Min_Edit.String);
                    MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(3,2) = str2num(h.Mia_TICS.Threshold_counts_Max_Edit.String);
                    MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(4,1) = str2num(h.Mia_TICS.Threshold_halflife_Min_Edit.String);
                    MIAData.TICS.Thresholds{h.Mia_TICS.SelectCor.Value}(4,2) = str2num(h.Mia_TICS.Threshold_halflife_Max_Edit.String);
                end
            end
            
            %%% Sets unselected pixels to NaN
            if size(MIAData.TICS.MS,1)~=size(MIAData.TICS.Data{i},1) || size(MIAData.TICS.MS,2)~=size(MIAData.TICS.Data{i},2)
                TICS = MIAData.TICS.Data{i};
                MIAData.TICS.MS = true(size(MIAData.TICS.Int{1}));
                mask = MIAData.TICS.MS;
            else    
                % take the thresholds into account in the mask
                mask = true(size(MIAData.TICS.Int{1}));
                mask(G1 < MIAData.TICS.Thresholds{i}(1,1)) = false;
                mask(G1 > MIAData.TICS.Thresholds{i}(1,2)) = false;
                mask(brightness < MIAData.TICS.Thresholds{i}(2,1)) = false;
                mask(brightness > MIAData.TICS.Thresholds{i}(2,2)) = false;
                mask(counts < MIAData.TICS.Thresholds{i}(3,1)) = false;
                mask(counts > MIAData.TICS.Thresholds{i}(3,2)) = false;
                mask(halflife < MIAData.TICS.Thresholds{i}(4,1)) = false;
                mask(halflife > MIAData.TICS.Thresholds{i}(4,2)) = false;
                % apply thresholds and freehand mask
                mask = mask & MIAData.TICS.MS;
                TICS = MIAData.TICS.Data{i};
                TICS(repmat(~mask,1,1,size(TICS,3))) = NaN;
            end
            %set the intensity NaN outside the mask
            Int1 = MIAData.TICS.Int{1};
            Int2 = MIAData.TICS.Int{2};
            Int1(~mask)=NaN;
            Int2(~mask)=NaN;
            
            %%% Averages pixel TICS data for selected (~NaN) pixels and
            %%% plots the curve
            h.Plots.TICS(i,1).YData = squeeze(nanmean(nanmean(TICS,2),1));
            h.Plots.TICS(i,1).XData = (1:size(TICS,3)).*str2double(h.Mia_Image.Settings.Image_Frame.String);
            EData = double(squeeze(nanstd(nanstd(TICS,0,2),0,1))');
            EData = EData./sqrt(sum(reshape(~isnan(TICS),[],size(TICS,3)),1));
            h.Plots.TICS(i,1).UData = EData;
            h.Plots.TICS(i,1).LData = EData;
            
            MIAData.TICS.Counts = [nanmean(nanmean(Int1,2),1) nanmean(nanmean(Int2,2),1)]/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1000;
            data{i}.Valid = 1;
            data{i}.Cor_Times = (1:size(MIAData.TICS.Data{i},3))*str2double(h.Mia_Image.Settings.Image_Frame.String);
            data{i}.Cor_Average = double(squeeze(nanmean(nanmean(TICS,2),1))');
            data{i}.Cor_Array = data{i}.Cor_Average';
            data{i}.Cor_SEM = EData;
            
            %%% Updates fit curve
            Calc_TICS_Fit([],[],i);
            
            %%% Plots individual pixel data in images
            switch(h.Mia_TICS.SelectImage.Value)
                case 1 %%% G(first lag)
                    h.Plots.TICSImage(i).CData = G1;
                case 2 %%% G(first lag)./mean(Counts)
                    h.Plots.TICSImage(i).CData = brightness;
                case 3 %%% Mean counts
                    h.Plots.TICSImage(i).CData = counts;
                case 4 %%% Find G(0)/2
                    h.Plots.TICSImage(i).CData = halflife;
            end
            %%% Sets transparency of unselected pixels to 80%
            h.Plots.TICSImage(i).AlphaData = (any(~isnan(TICS),3)+0.25)/1.25;
            
            %%% Updates axis and shows plots
            h.Mia_TICS.Image(i,1).XLim = [0 size(TICS,2)]+0.5;
            h.Mia_TICS.Image(i,1).YLim = [0 size(TICS,1)]+0.5;
            h.Plots.TICSImage(i).Visible = 'on';
            h.Mia_TICS.Image(i,2).Visible = 'on';
            h.Mia_TICS.Image(i,1).Visible = 'on';
        else %%% Hides plots, if no TICS data exists for current channel
            h.Plots.TICS(i,1).Visible = 'off';
            h.Plots.TICS(i,2).Visible = 'off';
            h.Plots.TICSImage(i).Visible = 'off';
            h.Mia_TICS.Image(i,2).Visible = 'off';
            h.Mia_TICS.Image(i,1).Visible = 'off';
        end
    end
    % Save displayed TICS data
    if ~isempty(obj)
        if strcmp(obj.Tag, 'Save')
            Save_TICS([],[],data)
        end
    end
end

%% Plots STICS/iMSD data
if any(mode==6)
    for i=1:3
        %%% 1&3: ACF 1&2
        %%% 2:   CCF
        if size(MIAData.STICS,2)>=i && ~isempty(MIAData.STICS{i})
            %% 2D STICS Images
            Size = round(str2double(h.Mia_STICS.Size.String));
            if isempty(Size) || Size<1
                Size = 31;
                h.Mia_STICS.Size.String = '31';
            elseif Size > size(MIAData.STICS{i},1) || Size > size(MIAData.STICS{i},2)
                Size = min([size(MIAData.STICS{i},2), size(MIAData.STICS{i},2)]);
                h.Mia_STICS.Size.String = num2str(Size);
            end
            X(1)=ceil(floor(size(MIAData.STICS{i},1)/2)-Size/2)+1;
            X(2)=ceil(floor(size(MIAData.STICS{i},1)/2)+Size/2);
            Y(1)=ceil(floor(size(MIAData.STICS{i},2)/2)-Size/2)+1;
            Y(2)=ceil(floor(size(MIAData.STICS{i},2)/2)+Size/2);
            
            h.Plots.STICSImage(i,1).CData = MIAData.STICS{i}(X(1):X(2),Y(1):Y(2),round(h.Mia_STICS.Lag_Slider.Value+1));
            h.Plots.STICSImage(i,1).Visible = 'on';
            h.Mia_STICS.Image(i,2).Visible = 'on';
            %% Fitted iMSD plot
            Size = str2double(h.Mia_Image.Settings.Image_Size.String);
            Time = (0:(numel(MIAData.iMSD{i,1})-1))*str2double(h.Mia_Image.Settings.Image_Frame.String);
            %%% Data
            h.Plots.STICS(i,1).YData = (MIAData.iMSD{i,1}.*Size/1000).^2;
            h.Plots.STICS(i,1).XData = Time;
            h.Plots.STICS(i,1).UData = (MIAData.iMSD{i,2}(:,1).^2-MIAData.iMSD{i,1}.^2).*Size.^2/10^6;
            h.Plots.STICS(i,1).LData = (MIAData.iMSD{i,1}.^2-MIAData.iMSD{i,2}(:,2).^2).*Size.^2/10^6;
            h.Plots.STICS(i,1).Visible = 'on';
            h.Plots.STICS(i,1).Visible = 'on';
            %%% Fit
            Time = linspace(0,Time(end),1000);
            P = cellfun(@str2double,h.Mia_STICS.Fit_Table.Data(1:2:end,i));
            h.Plots.STICS(i,2).YData = P(1)^2+4*P(2).*(Time.^P(3));
            h.Plots.STICS(i,2).XData = Time;
            h.Plots.STICS(i,2).Visible = 'on';
            h.Plots.STICS(i,2).Visible = 'on';
            
            h.Mia_STICS.Axes.XLim = [0 Time(end)];
            
        else
            h.Plots.STICSImage(i,1).Visible = 'off';
            h.Mia_STICS.Image(i,2).Visible = 'off';
            h.Plots.STICS(i,1).Visible = 'off';
            h.Plots.STICS(i,1).Visible = 'off';
            h.Plots.STICS(i,2).Visible = 'off';
            h.Plots.STICS(i,2).Visible = 'off';
        end
    end
end

%% Updates filename display
if numel(MIAData.FileName)==2
    h.Mia_Progress_Text.String = [MIAData.FileName{1}{1} ' / ' MIAData.FileName{2}{1}];
elseif numel(MIAData.FileName)==1
    h.Mia_Progress_Text.String = MIAData.FileName{1}{1};
else
    h.Mia_Progress_Text.String = 'Nothing loaded';
end
h.Mia_Progress_Axes.Color=UserValues.Look.Control;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Moves through frames %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mia_Frame(~,e,mode,channel)
global MIAData

Fig = gcf;
%%% This speeds display up
if strcmp(Fig.Tag,'Mia') 
    h = guidata(Fig);
else
    h = guidata(findobj('Tag','Mia'));
end
if size(MIAData.Data,1)>0
    %%% Determins slider in case of listener callback
    if nargin<4
        mode=e.AffectedObject.UserData(1);
        channel=e.AffectedObject.UserData(2);
    end
    %%% Updates UIs
    switch mode
        case 1 %%% Image frames editbox changed
            Frame=str2double(h.Mia_Image.Settings.Channel_Frame(channel).String);
            %%% Forces frame into bounds
            if Frame>size(MIAData.Data{channel,1},3)
                Frame=size(MIAData.Data{channel,1},3);
                h.Mia_Image.Settings.Channel_Frame(channel).String=num2str(size(MIAData.Data{channel,1},3));
            end
            if mod(Frame,1)~=0
                Frame=round(Frame);
                h.Mia_Image.Settings.Channel_Frame(channel).String=num2str(Frame);
            end
            if Frame<0
                Frame=0;
                h.Mia_Image.Settings.Channel_Frame(channel).String='0';
            end
            h.Mia_Image.Settings.Channel_Frame_Slider(channel).Value=Frame;
        case 2 %%% Image frames slider changed
            
            h.Mia_Image.Settings.Channel_Frame_Listener(1).Enabled=0;
            h.Mia_Image.Settings.Channel_Frame_Listener(2).Enabled=0;
            Frame=h.Mia_Image.Settings.Channel_Frame_Slider(channel).Value;

            if mod(Frame,1)~=0
                Frame=round(Frame);                
                h.Mia_Image.Settings.Channel_Frame_Slider(channel).Value=Frame;             
            end
            if Frame<0
                Frame=0;
            end
            h.Mia_Image.Settings.Channel_Frame(channel).String=num2str(Frame);
            
            if h.Mia_Image.Settings.Channel_Link.Value
                h.Mia_Image.Settings.Channel_Frame(mod(2*channel,3)).String=num2str(Frame);
                h.Mia_Image.Settings.Channel_Frame_Slider(mod(2*channel,3)).Value=Frame;
                Update_Plots([],[],1,[1 2]);
            else
                Update_Plots([],[],1,channel);
            end
            h.Mia_Image.Settings.Channel_Frame_Listener(1).Enabled=1;
            h.Mia_Image.Settings.Channel_Frame_Listener(2).Enabled=1;
        case 3 %%% Cor frames editbox changed
            Frame = round(str2double(h.Mia_ICS.Frame.String));
            i = find(~cellfun(@isempty,MIAData.Cor),1,'first');
            %%% Forces frame into bounds
            if Frame>size(MIAData.Cor{i},3)
                Frame=size(MIAData.Cor{i},3);
                h.Mia_ICS.Frame.String=num2str(size(MIAData.Cor{i},3));
            elseif Frame<0 || isempty(Frame)
                Frame=0;
                h.Mia_ICS.Frame.String='0';
            end
            h.Mia_ICS.Frame_Slider.Value=Frame;
        case 4 %%% Cor frames slider changed
            Frame=h.Mia_ICS.Frame_Slider.Value;
            if mod(Frame,1)~=0
                Frame=round(Frame);
                h.Mia_ICS.Frame_Slider.Value=Frame;
            end
            h.Mia_ICS.Frame.String=num2str(Frame);
            Update_Plots([],[],2,1:3);
        case 5 %%% STICS lag editbox changed
            Lag = round(str2double(h.Mia_STICS.Lag.String));
            i = find(~cellfun(@isempty,MIAData.STICS),1,'first');
            if isempty(i) %%%Stop, if no file is loaded
               return; 
            end
            %%% Forces frame into bounds
            if Lag > size(MIAData.STICS{i},3)
                Lag = size(MIAData.STICS{i},3);
                h.Mia_STICS.Lag.String = num2str(Lag);
            elseif Lag <0 || isempty(Lag)
                Lag = 0;
                h.Mia_STICS.Lag.String = '0';
            end
            %%% Updates Slider
            h.Mia_STICS.Lag_Slider.Value = Lag;
            Update_Plots([],[],6,1:3);
        case 6 %%% STICS lag slider changed
           Lag = h.Mia_STICS.Lag_Slider.Value;
           if mod(Lag,1)~=0
               Lag = round(Lag);
               h.Mia_STICS.Lag_Slider.Value = Lag;
           end
           h.Mia_STICS.Lag.String = num2str(Lag);
           Update_Plots([],[],6,1:3);
    end
    %%% Sets the frame use value
    if str2double(h.Mia_Image.Settings.Channel_Frame(1).String)>0
        % MIAData.Use is just a 1xFrames logical with the checkboxes
        h.Mia_Image.Settings.Channel_FrameUse(1).Value=MIAData.Use(1,str2double(h.Mia_Image.Settings.Channel_Frame(1).String));
    end
    if str2double(h.Mia_Image.Settings.Channel_Frame(2).String)>0
        h.Mia_Image.Settings.Channel_FrameUse(2).Value=MIAData.Use(2,str2double(h.Mia_Image.Settings.Channel_Frame(2).String));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes custom plots color %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mia_Color(Obj,~,mode)
if ~isdeployed
    Color=uisetcolor;
elseif isdeployed %%% uisetcolor dialog does not work in compiled application
    Color = color_setter(Obj.UserData); % open dialog to input color
end
if numel(Color)
    Obj.UserData=Color;
end
Update_Plots([],[],1,mode);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Selects\Unselects frames via checkbox %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mia_CheckFrame(~,~,mode) %mode is channel
global MIAData
h = guidata(findobj('Tag','Mia'));
if h.Mia_Image.Settings.Channel_Link.Value
    MIAData.Use(1,str2double(h.Mia_Image.Settings.Channel_Frame(mode).String))=h.Mia_Image.Settings.Channel_FrameUse(mode).Value;
    MIAData.Use(2,str2double(h.Mia_Image.Settings.Channel_Frame(mode).String))=h.Mia_Image.Settings.Channel_FrameUse(mode).Value;
    h.Mia_Image.Settings.Channel_FrameUse(mod(mode,2)+1).Value=h.Mia_Image.Settings.Channel_FrameUse(mode).Value;
else
    MIAData.Use(mode,str2double(h.Mia_Image.Settings.Channel_Frame(mode).String))=h.Mia_Image.Settings.Channel_FrameUse(mode).Value;
end
h.Mia_Image.Settings.ROI_FramesUse.Value=2;
MIA_Various([],[],3)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generates corrected images %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mia_Correct(~,~,AR)
global MIAData
h = guidata(findobj('Tag','Mia'));
h.Mia_Progress_Text.String = 'Applying Correction';
h.Mia_Progress_Axes.Color=[1 0 0];  
drawnow;

%%% Clears manually selected ROIs
if AR==2  
Mia_Freehand([],[],3,0);
end
%%% Performs Arbitrary Region selection
if h.Mia_Image.Settings.ROI_FramesUse.Value == 3 && AR~=0
     Mia_Arbitrary_Region([],[]);
end

%%% Extracts ROI position
From=h.Plots.ROI(1).Position(1:2)+0.5;
To=From+h.Plots.ROI(1).Position(3:4)-1;

h.Mia_Image.Settings.Correction_Subtract_Pixel.Visible='off';
h.Mia_Image.Settings.Correction_Subtract_Pixel_Text.Visible='off';
h.Mia_Image.Settings.Correction_Subtract_Frames.Visible='off';
h.Mia_Image.Settings.Correction_Subtract_Frames_Text.Visible='off';
h.Mia_Image.Settings.Correction_Add_Pixel.Visible='off';
h.Mia_Image.Settings.Correction_Add_Pixel_Text.Visible='off';
h.Mia_Image.Settings.Correction_Add_Frames.Visible='off';
h.Mia_Image.Settings.Correction_Add_Frames_Text.Visible='off';

%%% Actually performs correction
for i=1:2
    if size(MIAData.Data,1)>=i  
        MIAData.Data{i,2}=[];
        %% Adds to image
        switch h.Mia_Image.Settings.Correction_Add.Value
            case 1 %%% Do nothing
                MIAData.Data{i,2}=single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:));
            case 2 %%% Total ROI mean
                Add=single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:));
                if h.Mia_Image.Settings.ROI_FramesUse.Value == 3
                    Add(~(repmat(MIAData.MS{1},[1 1 size(MIAData.AR{i,1},3)]) & MIAData.AR{i,1}))=NaN;
                end
                MIAData.Data{i,2}=single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:)) + nanmean(Add(:));
                clear Add
            case 3 %%% Frame ROI mean
                Add=single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:));
                if AR~=0 && h.Mia_Image.Settings.ROI_FramesUse.Value == 3
                    Add(~(repmat(MIAData.MS{1},[1 1 size(MIAData.AR{i,1},3)]) & MIAData.AR{i,1}))=NaN;
                end
                MIAData.Data{i,2}=single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:))...
                                  +repmat(nanmean(nanmean(Add)),[(To(2)-From(2)+1),(To(1)-From(1)+1),1]);
            case 4 %%% Pixel mean
                Add=single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:));
                if AR~=0 && h.Mia_Image.Settings.ROI_FramesUse.Value == 3
                    Add(~(repmat(MIAData.MS{1},[1 1 size(MIAData.AR{i,1},3)]) & MIAData.AR{i,1}))=NaN;
                end
                MIAData.Data{i,2}=single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:))...
                                 +(repmat(nanmean(Add,3),[1,1,size(MIAData.Data{i,1},3)]));
            case 5 %%% Moving average
                h.Mia_Image.Settings.Correction_Add_Pixel.Visible='on';
                h.Mia_Image.Settings.Correction_Add_Pixel_Text.Visible='on';
                h.Mia_Image.Settings.Correction_Add_Frames.Visible='on';
                h.Mia_Image.Settings.Correction_Add_Frames_Text.Visible='on';                
                Box=[str2double(h.Mia_Image.Settings.Correction_Add_Pixel.String), str2double(h.Mia_Image.Settings.Correction_Add_Pixel.String), str2double(h.Mia_Image.Settings.Correction_Add_Frames.String)];
                
                MIAData.Data{i,2}=single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:));                 
                %%% Forces averaging sizes into bounds
                if any(Box<1) || any(Box>size(MIAData.Data{i,2}))
                    Box(Box<1)=1;
                    if Box(1)>size(MIAData.Data{i,2},1)
                        Box(1)=size(MIAData.Data{i,2},1);
                    end
                    if Box(2)>size(MIAData.Data{i,2},2)
                        Box(2)=size(MIAData.Data{i,2},2);
                    end
                    if Box(3)>size(MIAData.Data{i,2},3)
                        Box(3)=min(size(MIAData.Data{i,2},3));   
                    end 
                    h.Mia_Image.Settings.Correction_Add_Pixel.String=num2str(Box(1));
                    h.Mia_Image.Settings.Correction_Add_Frames.String=num2str(Box(3));
                end
                %%% Calculates Filter
                Filter=ones(Box)/prod(Box);
                MIAData.Data{i,2}=MIAData.Data{i,2}+imfilter(MIAData.Data{i,2},Filter,'replicate');
        end
        %% Subtracts from image
        switch h.Mia_Image.Settings.Correction_Subtract.Value
            case 1 %%% Do nothing
            case 2 %%% Frame ROI mean
                Sub=single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:));
                if AR~=0 && h.Mia_Image.Settings.ROI_FramesUse.Value == 3
                    Sub(~(repmat(MIAData.MS{1},[1 1 size(MIAData.AR{i,1},3)]) & MIAData.AR{i,1}))=NaN;
                end
                MIAData.Data{i,2}=MIAData.Data{i,2}...
                                 -(repmat(nanmean(nanmean(Sub)),[(To(2)-From(2)+1),(To(1)-From(1)+1),1]));
            case 3 %%% Pixel mean
                Sub=single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:));
                if AR~=0 && h.Mia_Image.Settings.ROI_FramesUse.Value == 3
                    Sub(~(repmat(MIAData.MS{1},[1 1 size(MIAData.AR{i,1},3)]) & MIAData.AR{i,1}))=NaN;
                end
                MIAData.Data{i,2}=MIAData.Data{i,2}...
                                 -(repmat(nanmean(Sub,3),[1,1,size(MIAData.Data{i,1},3)]));
            case 4 %%% Moving average
                h.Mia_Image.Settings.Correction_Subtract_Pixel.Visible='on';
                h.Mia_Image.Settings.Correction_Subtract_Pixel_Text.Visible='on';
                h.Mia_Image.Settings.Correction_Subtract_Frames.Visible='on';
                h.Mia_Image.Settings.Correction_Subtract_Frames_Text.Visible='on';
                Box=[str2double(h.Mia_Image.Settings.Correction_Subtract_Pixel.String),... 
                     str2double(h.Mia_Image.Settings.Correction_Subtract_Pixel.String),...
                     str2double(h.Mia_Image.Settings.Correction_Subtract_Frames.String)];
                 
                %%% Forces averaging sizes into bounds
                if any(Box<1) || any(Box>size(MIAData.Data{i,2}))
                    Box(Box<1)=1;
                    if Box(1)>size(MIAData.Data{i,2},1)
                        Box(1)=size(MIAData.Data{i,2},1);
                    end
                    if Box(2)>size(MIAData.Data{i,2},2)
                        Box(2)=size(MIAData.Data{i,2},2);
                    end
                    if Box(3)>size(MIAData.Data{i,2},3)
                        Box(3)=min(size(MIAData.Data{i,2},3));   
                    end 
                    h.Mia_Image.Settings.Correction_Subtract_Pixel.String=num2str(Box(1));
                    h.Mia_Image.Settings.Correction_Subtract_Frames.String=num2str(Box(3));
                end 
                %%% Calculates Filter
                Filter=ones(Box)/prod(Box);
                MIAData.Data{i,2}=MIAData.Data{i,2}-imfilter(single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:)),Filter,'replicate');    
        end
        
        %%% Removes NaNs from file
        %%% Sometimes happens with filtered data
        MIAData.Data{i,2}(isnan(MIAData.Data{i,2})) = 0;
        %subtract the background stored displayed on the ROI tab
        MIAData.Data{i,2}=MIAData.Data{i,2}-str2double(h.Mia_Image.Settings.Background(i).String);
        
    end
end

Update_Plots([],[],[1,4],1:size(MIAData.Data,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculates arbitrary regions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mia_Arbitrary_Region(~,~)
h = guidata(findobj('Tag','Mia'));
global MIAData
%%% Uses Intensity and Variance thesholding to remove bad pixels
%%% ROI borders
From=h.Plots.ROI(1).Position(1:2)+0.5;
To=From+h.Plots.ROI(1).Position(3:4)-1;
%%% Thresholding Parameters
Int_Max(1)=str2double(h.Mia_Image.Settings.Image_Pixel.String)*str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(1).String)/1000;
Int_Max(2)=str2double(h.Mia_Image.Settings.Image_Pixel.String)*str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(2).String)/1000;
Int_Min(1)=str2double(h.Mia_Image.Settings.Image_Pixel.String)*str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(1).String)/1000;
Int_Min(2)=str2double(h.Mia_Image.Settings.Image_Pixel.String)*str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(2).String)/1000;
Int_Fold_Max=str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Max.String);
Int_Fold_Min=str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Min.String);
Var_Fold_Max=str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Max.String);
Var_Fold_Min=str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Min.String);
Var_Sub=str2double(h.Mia_Image.Settings.ROI_AR_Sub2.String);
Var_SubSub=str2double(h.Mia_Image.Settings.ROI_AR_Sub1.String);

if size(MIAData.Data,1)==0
    return;
end
if size(MIAData.Data,1)==1 || h.Mia_Image.Settings.ROI_AR_Same.Value==2
    Channel = 1;
elseif size(MIAData.Data,1)==2 && h.Mia_Image.Settings.ROI_AR_Same.Value==3
    Channel = 2;
else
    Channel = [1 2];
end

%%% Actually calculates arbitrary regions
for i=Channel
    %% Static region intensity thresholding for arbitrary region ICS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Because the intenities per pixel are very low, the tresholding
    %%% works on the sum of the stack
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Thresholding operates on summed up, uncorrected data
    Data=mean(single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:)),3);
    %%% Logical array to determin which pixels to use
    Use=true(size(Data));
    if ~h.Mia_Image.Settings.ROI_AR_Spatial_Int.Value
        %%% Removes pixel below an intensity threshold set in kHz
        if Int_Min(i)>0
            Use(Data<Int_Min(i))=false;
        end
        %%% Removes pixel above an intensity threshold set in kHz
        if Int_Max(i)>Int_Min(i)
            Use(Data>Int_Max(i))=false;
        end
        if h.Mia_Image.Settings.ROI_AR_median.Value
            Use = medfilt2(Use,[Var_SubSub,Var_SubSub]);
        end
    end
    MIAData.AR{i,2}=Use;
    %% Sliding window thresholding for arbitrary region ICS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% The variance and itensity in a small rectangular region is
    %%% calculated and compared to the variance in a bigger region
    %%% around it
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Thresholding operates on uncorrected data
    Data=single(MIAData.Data{i,1}(From(2):To(2),From(1):To(1),:));
    %%% Extends aray to determine which pixels to use, because now
    %%% every frame is calculated individually
    Use=repmat(Use,[1 1 size(Data,3)]);
    if Var_SubSub>1 && Var_Sub>Var_SubSub
        Start=ceil(Var_Sub/2)-1;
        Stop=floor(Var_Sub/2)-1;
        for j=1:size(Data,3)
            Filter1=ones(Var_SubSub)/(Var_SubSub)^2;
            Filter2=ones(Var_Sub)/(Var_Sub^2);
            
            %%% Calculates mean of both subregions
            Mean1=filter2(Filter1,Data(:,:,j));
            Mean2=filter2(Filter2,Data(:,:,j));
            BleachFact = mean2(Data(:,:,j))/mean2(Data(:,:,1));
            %%% Calculates population variance for both subregions (sample2population var)
            Var1=(filter2(Filter1,Data(:,:,j).^2)-Mean1.^2)*(Var_SubSub^2/(Var_SubSub^2-1));
            Var2=(filter2(Filter2,Data(:,:,j).^2)-Mean2.^2)*((Var_Sub^2)/(Var_Sub^2-1));
            %%% Discards samples with too low\high variance
            if Var_Fold_Max>1
                Use(:,:,j)=Use(:,:,j) & (Var1<(Var2*Var_Fold_Max));
            end
            if Var_Fold_Min<1 && Var_Fold_Min>0
                Use(:,:,j)=Use(:,:,j) & (Var1>(Var2*Var_Fold_Min));
            end
            %%% Discards samples with too low\high relative intensities
            if Int_Fold_Max>1
                Use(:,:,j)=Use(:,:,j) & (Mean1<(Mean2*Int_Fold_Max));
            end
            if Int_Fold_Min<1 && Int_Fold_Min>0
                Use(:,:,j)=Use(:,:,j) & (Mean1>(Mean2*Int_Fold_Min));
            end
            if h.Mia_Image.Settings.ROI_AR_Spatial_Int.Value
                %%% Discards samples with too low\high absolute intensities
                if Int_Max(i)>Int_Min(i)
                    Use(:,:,j)=Use(:,:,j) & ((Mean1/BleachFact)<Int_Max(i));
                end
                if Int_Min(i)>0
                    Use(:,:,j)=Use(:,:,j) & ((Mean1/BleachFact)>Int_Min(i));
                end
            end
            %%% For very low frame intensities, the IntFold and VarFold calculations fail
            %%% Include regions again in the ROI that contained no signal to begin with
            Mean1_zero = false(size(Mean1));
            Mean1_zero(Mean1==0) = true;
            Use(:,:,j) = Use(:,:,j) | Mean1_zero;
            %%% median filter the image
            if h.Mia_Image.Settings.ROI_AR_median.Value
                Use(:,:,j) = medfilt2(Use(:,:,j),[Var_SubSub,Var_SubSub]);
            end
        end
        %%% Discards border pixels, where variance and intensity were not calculated
        Use(1:Start,:,:)=false; Use(:,1:Start,:)=false;
        Use(end-Stop:end,:,:)=false; Use(:,end-Stop:end,:)=false;
        
    end
    
    %%% Removes pixels, if invalid pixels were used for averaging
    if h.Mia_Image.Settings.Correction_Add.Value==5 || h.Mia_Image.Settings.Correction_Subtract.Value==4
        % you add the moving average or subtract the moving average
        if h.Mia_Image.Settings.Correction_Add.Value==5
            % you add the moving average
            Box1=[str2double(h.Mia_Image.Settings.Correction_Add_Pixel.String), str2double(h.Mia_Image.Settings.Correction_Add_Frames.String)];
        else
            Box1=[1 1];
        end
        if h.Mia_Image.Settings.Correction_Subtract.Value==4
            % you subtract the moving average
            Box2=[str2double(h.Mia_Image.Settings.Correction_Subtract_Pixel.String), str2double(h.Mia_Image.Settings.Correction_Subtract_Frames.String)];
        else
            Box2=[1 1];
        end
        Box=max([Box1;Box2]);
        Filter=ones(Box(1),Box(1),Box(2))/(Box(1)^2*Box(2));
        Use=logical(floor(imfilter(single(Use),Filter,'replicate')));
    end
    
    MIAData.AR{i,1}=Use;
    clear Data;
end

switch h.Mia_Image.Settings.ROI_AR_Same.Value
    case 1 %%% Individual channels 
        MIAData.MS{1,1} = MIAData.MS{1,2};
        if size(MIAData.Data,1)>1
            MIAData.MS{2,1} = MIAData.MS{2,2};
        end
    case 2 %%% Channel 1
        if size(MIAData.Data,1)>1
            MIAData.AR{2,1} = MIAData.AR{1,1};
            MIAData.AR{2,2} = MIAData.AR{1,2};
            MIAData.MS{2,1} = MIAData.MS{1,2};
        end  
        MIAData.MS{1,1} = MIAData.MS{1,2};
        
    case 3 %%% Channel 2
        if size(MIAData.Data,1)>1
            MIAData.AR{1,1} = MIAData.AR{2,1};
            MIAData.AR{1,2} = MIAData.AR{2,2};
            MIAData.MS{1,1} = MIAData.MS{2,2};
            MIAData.MS{2,1} = MIAData.MS{2,2};
        end   
    case 4 %%% Both channels
        if size(MIAData.Data,1)>1
            MIAData.AR{1,1} = MIAData.AR{1,1} & MIAData.AR{2,1};
            MIAData.AR{1,2} = MIAData.AR{1,2} & MIAData.AR{2,2};
            MIAData.AR{2,1} = MIAData.AR{1,1} & MIAData.AR{2,1};
            MIAData.AR{2,2} = MIAData.AR{1,2} & MIAData.AR{2,2};
            MIAData.MS{1,1} = MIAData.MS{1,2} & MIAData.MS{2,2};
            MIAData.MS{2,1} = MIAData.MS{1,2} & MIAData.MS{2,2};
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculates arbitrary regions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mia_Freehand(~,~,mode,Correct)
h = guidata(findobj('Tag','Mia'));
global MIAData

if isempty(MIAData.Data)
    return;
end

switch mode
    %%% General manual selection
    case 1 %%% Select Region for general manual seletion
        ROI = imfreehand;
        Mask = createMask(ROI);
        delete(ROI);        
        switch gca
            case h.Mia_Image.Axes(1,2)
                if any(~MIAData.MS{1,2}(:))
                    MIAData.MS{1,2} = MIAData.MS{1,2} | Mask;
                    MIAData.MS{2,2} = MIAData.MS{2,2} | Mask;
                else
                    MIAData.MS{1,2} = Mask;
                    MIAData.MS{2,2} = Mask;
                end
            case h.Mia_Image.Axes(2,2)
                if any(~MIAData.MS{2,2}(:))
                    MIAData.MS{2,2} = MIAData.MS{2,2} | Mask;
                    MIAData.MS{1,2} = MIAData.MS{1,2} | Mask;
                else
                    MIAData.MS{2,2} = Mask;
                    MIAData.MS{1,2} = Mask;
                end
        end          
        switch h.Mia_Image.Settings.ROI_AR_Same.Value
            case 1 %%% Individual channels
                MIAData.MS{1,1} = MIAData.MS{1,2};
                if size(MIAData.Data,1)>1
                    MIAData.MS{2,1} = MIAData.MS{2,2};
                end
            case 2 %%% Channel 1
                if size(MIAData.Data,1)>1
                    MIAData.MS{2,1} = MIAData.MS{1,2};
                end
                MIAData.MS{1,1} = MIAData.MS{1,2};
            case 3 %%% Channel 2
                if size(MIAData.Data,1)>1
                    MIAData.MS{1,1} = MIAData.MS{2,2};
                    MIAData.MS{2,1} = MIAData.MS{2,2};
                end
            case 4 %%% Both channels
                if size(MIAData.Data,1)>1
                    MIAData.MS{1,1} = MIAData.MS{1,2} & MIAData.MS{2,2};
                    MIAData.MS{2,1} = MIAData.MS{1,2} & MIAData.MS{2,2};
                end
        end
        Mia_Correct([],[],1);
    case 2 %%% Unselect Region for general manual seletion
        ROI = imfreehand;
        Mask = createMask(ROI);
        delete(ROI);
        
        switch gca
            case h.Mia_Image.Axes(1,2)
                MIAData.MS{1,2} = MIAData.MS{1,2} & ~Mask;
                MIAData.MS{2,2} = MIAData.MS{2,2} & ~Mask;
            case h.Mia_Image.Axes(2,2)
                MIAData.MS{2,2} = MIAData.MS{2,2} & ~Mask;
                MIAData.MS{1,2} = MIAData.MS{1,2} & ~Mask;
        end      
        if h.Mia_Image.Settings.ROI_AR_Same.Value == 4 && size(MIAData.Data,1)>1
            MIAData.MS{1,2} = MIAData.MS{1,2} & MIAData.MS{2,2};
            MIAData.MS{2,2} = MIAData.MS{1,2} & MIAData.MS{2,2};
        end
        
        switch h.Mia_Image.Settings.ROI_AR_Same.Value
            case 1 %%% Individual channels
                MIAData.MS{1,1} = MIAData.MS{1,2};
                if size(MIAData.Data,1)>1
                    MIAData.MS{2,1} = MIAData.MS{2,2};
                end
            case 2 %%% Channel 1
                if size(MIAData.Data,1)>1
                    MIAData.MS{2,1} = MIAData.MS{1,2};
                end
                MIAData.MS{1,1} = MIAData.MS{1,2};
            case 3 %%% Channel 2
                if size(MIAData.Data,1)>1
                    MIAData.MS{1,1} = MIAData.MS{2,2};
                    MIAData.MS{2,1} = MIAData.MS{2,2};
                end
            case 4 %%% Both channels
                if size(MIAData.Data,1)>1
                    MIAData.MS{1,1} = MIAData.MS{1,2} & MIAData.MS{2,2};
                    MIAData.MS{2,1} = MIAData.MS{1,2} & MIAData.MS{2,2};
                end
        end
        Mia_Correct([],[],1);
    case 3 %%% Clear Region for general manual seletion
        for i=1:size(MIAData.Data,1)
            MIAData.MS{i,2} = true(str2double(h.Mia_Image.Settings.ROI_SizeY.String),str2double(h.Mia_Image.Settings.ROI_SizeX.String));
        end 
        if h.Mia_Image.Settings.ROI_AR_Same.Value == 4 && size(MIAData.Data,1)>1
            MIAData.MS{1,2} = MIAData.MS{1,2} & MIAData.MS{2,2};
            MIAData.MS{2,2} = MIAData.MS{1,2} & MIAData.MS{2,2};
        end
        
        switch h.Mia_Image.Settings.ROI_AR_Same.Value
            case 1 %%% Individual channels
                MIAData.MS{1,1} = MIAData.MS{1,2};
                if size(MIAData.Data,1)>1
                    MIAData.MS{2,1} = MIAData.MS{2,2};
                end
            case 2 %%% Channel 1
                if size(MIAData.Data,1)>1
                    MIAData.MS{2,1} = MIAData.MS{1,2};
                end
                MIAData.MS{1,1} = MIAData.MS{1,2};
            case 3 %%% Channel 2
                if size(MIAData.Data,1)>1
                    MIAData.MS{1,1} = MIAData.MS{2,2};
                    MIAData.MS{2,1} = MIAData.MS{2,2};
                end
            case 4 %%% Both channels
                if size(MIAData.Data,1)>1
                    MIAData.MS{1,1} = MIAData.MS{1,2} & MIAData.MS{2,2};
                    MIAData.MS{2,1} = MIAData.MS{1,2} & MIAData.MS{2,2};
                end
        end
        if nargin<4 || Correct~=0
            Mia_Correct([],[],0);
            %Update_Plots([],[],1,1:size(MIAData.Data,1));
        end
    %%% TICS manual selection 
    case 4 %%% Select Region for TICS manual seletion
        ROI = imfreehand;
        Mask = createMask(ROI);
        delete(ROI);        
        if any(~MIAData.TICS.MS(:))
            MIAData.TICS.MS = MIAData.TICS.MS | Mask;
        else
            MIAData.TICS.MS = Mask;
        end
        Update_Plots([],[],5,1:size(MIAData.Data,1));
    case 5 %%% Unselect Region for TICS manual seletion
        ROI = imfreehand;
        Mask = createMask(ROI);
        delete(ROI);
        if ~isempty(MIAData.TICS.MS)
            MIAData.TICS.MS = MIAData.TICS.MS & ~Mask;
        else
            MIAData.TICS.MS = ~Mask;
        end
        Update_Plots([],[],5,1:size(MIAData.Data,1));
    case 6 %%% Clear Region for TICS manual seletion
        MIAData.TICS.MS = true(size(MIAData.TICS.Int{1}));
        Update_Plots([],[],5,1:size(MIAData.Data,1));
        
end

switch h.Mia_Image.Settings.ROI_AR_Same.Value
    case 1 %%% Individual channels 
        MIAData.MS{1,1} = MIAData.MS{1,2};
        if size(MIAData.Data,1)>1
            MIAData.MS{2,1} = MIAData.MS{2,2};
        end
    case 2 %%% Channel 1
        if size(MIAData.Data,1)>1
            MIAData.MS{2,1} = MIAData.MS{1,2};
        end  
        MIAData.MS{1,1} = MIAData.MS{1,2};        
    case 3 %%% Channel 2
        if size(MIAData.Data,1)>1
            MIAData.MS{1,1} = MIAData.MS{2,2};
            MIAData.MS{2,1} = MIAData.MS{2,2};
        end   
    case 4 %%% Both channels
        if size(MIAData.Data,1)>1
            MIAData.MS{1,1} = MIAData.MS{1,2} & MIAData.MS{2,2};
            MIAData.MS{2,1} = MIAData.MS{1,2} & MIAData.MS{2,2};
        end
end

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Funtion to update ROI position and size %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mia_ROI(obj,e,mode)
global MIAData UserValues
h = guidata(findobj('Tag','Mia'));

h.Mia_Progress_Text.String = 'Calculating ROI';
h.Mia_Progress_Axes.Color=[1 0 0];  
drawnow;

if ~isempty(MIAData.Data)
    switch mode
        case 1 %%% Editboxes were changed
            %%% Update Size
            Size=round([str2double(h.Mia_Image.Settings.ROI_SizeX.String) str2double(h.Mia_Image.Settings.ROI_SizeY.String)]);
            %%% Forces ROI size into bounds
            if Size(1)>size(MIAData.Data{1,1},2) || Size(1)<1
                Size(1)=size(MIAData.Data{1,1},2);
                h.Mia_Image.Settings.ROI_SizeX.String=num2str(Size(1));
            end
            if Size(2)>size(MIAData.Data{1,1},1) || Size(2)<1
                Size(2)=size(MIAData.Data{1,1},1);
                h.Mia_Image.Settings.ROI_SizeY.String=num2str(Size(2));
            end
            %%% Update Position
            Pos=round([str2double(h.Mia_Image.Settings.ROI_PosX.String) str2double(h.Mia_Image.Settings.ROI_PosY.String)]);
            %%% Forces ROI size into bounds
            Pos(Pos<1)=1;
            if (Pos(1)+Size(1)-1)>size(MIAData.Data{1,1},2)
                Pos(1)=(size(MIAData.Data{1,1},2)-Size(1)+1);
                h.Mia_Image.Settings.ROI_PosX.String=num2str(Pos(1));
            end
            if (Pos(2)+Size(2)-1)>size(MIAData.Data{1,1},1)
                Pos(2)=(size(MIAData.Data{1,1},1)-Size(2)+1);
                h.Mia_Image.Settings.ROI_PosY.String=num2str(Pos(2));
            end
        case 2 %%% Image was clicked
            Type=h.Mia.SelectionType;
            switch Type
                case 'normal' %%% Centers on point
                    %%% Update Size
                    Size=round([str2double(h.Mia_Image.Settings.ROI_SizeX.String) str2double(h.Mia_Image.Settings.ROI_SizeY.String)]);
                    %%% Forces ROI size into bounds
                    if Size(1)>size(MIAData.Data{1,1},2) || Size(1)<1
                        Size(1)=size(MIAData.Data{1,1},2);
                        h.Mia_Image.Settings.ROI_SizeX.String=num2str(Size(1));
                    end
                    if Size(2)>size(MIAData.Data{1,1},1) || Size(2)<1
                        Size(2)=size(MIAData.Data{1,1},1);
                        h.Mia_Image.Settings.ROI_SizeY.String=num2str(Size(2));
                    end
                    %%% Updates position
                    Pos=round(e.Source.Parent.CurrentPoint(1,1:2)-Size/2);
                    h.Mia_Image.Settings.ROI_PosX.String=num2str(Pos(1));
                    h.Mia_Image.Settings.ROI_PosY.String=num2str(Pos(2));                    
                    %%% Forces ROI size into bounds
                    Pos(Pos<1)=1;
                    if (Pos(1)+Size(1)-1)>size(MIAData.Data{1,1},2)
                        Pos(1)=(size(MIAData.Data{1,1},2)-Size(1)+1);
                        h.Mia_Image.Settings.ROI_PosX.String=num2str(Pos(1));
                    end
                    if (Pos(2)+Size(2)-1)>size(MIAData.Data{1,1},1)
                        Pos(2)=(size(MIAData.Data{1,1},1)-Size(2)+1);
                        h.Mia_Image.Settings.ROI_PosY.String=num2str(Pos(2));
                    end
                case 'alt' %%% Draw ROI
                    %%% Turns off ROI during selection
                    h.Plots.ROI(1).Visible='off';
                    h.Plots.ROI(2).Visible='off';
                    h.Plots.ROI(3).Visible='off';
                    h.Plots.ROI(4).Visible='off';
                    %%% Determins selected area via dinamic box
                    Start=e.Source.Parent.CurrentPoint(1,1:2);
                    rbbox;
                    Stop=e.Source.Parent.CurrentPoint(1,1:2);
                    %%% Forces edges into bounds
                    if Stop(1)<e.Source.Parent.XLim(1)
                        Stop(1)=e.Source.Parent.XLim(1);
                    end
                    if Stop(1)>e.Source.Parent.XLim(2)
                        Stop(1)=e.Source.Parent.XLim(2);
                    end
                    if Stop(2)<e.Source.Parent.YLim(1)
                        Stop(2)=e.Source.Parent.YLim(1);
                    end
                    if Stop(2)>e.Source.Parent.YLim(2)
                        Stop(2)=e.Source.Parent.YLim(2);
                    end
                    %%% Updates position and size
                    Pos=[round(min(Start(1),Stop(1))+0.5) round(min(Start(2),Stop(2))+0.5)];
                    Size=[round(abs(Start(1)-Stop(1))) round(abs(Start(2)-Stop(2)))];
                    Size(Size<1)=1;
                    h.Mia_Image.Settings.ROI_PosX.String=num2str(Pos(1));
                    h.Mia_Image.Settings.ROI_PosY.String=num2str(Pos(2));                    
                    h.Mia_Image.Settings.ROI_SizeX.String=num2str(Size(1));
                    h.Mia_Image.Settings.ROI_SizeY.String=num2str(Size(2));
                    %%% Turns ROIs back on
                    h.Plots.ROI(1).Visible='on';
                    h.Plots.ROI(2).Visible='on';
                    h.Plots.ROI(3).Visible='on';
                    h.Plots.ROI(4).Visible='on';
                case 'extend' %%% Export Frame
                    Mia_Export(obj,e);
                    %% Updates filename display
                    if numel(MIAData.FileName)==2
                        h.Mia_Progress_Text.String = [MIAData.FileName{1}{1} ' / ' MIAData.FileName{2}{1}];
                    elseif numel(MIAData.FileName)==1
                        h.Mia_Progress_Text.String = MIAData.FileName{1}{1};
                    else
                        h.Mia_Progress_Text.String = 'Nothing loaded';
                    end
                    h.Mia_Progress_Axes.Color=UserValues.Look.Control;
                    return;
                otherwise 
                    %%% Updates images
                    Mia_Correct([],[],2);
                    return;                   
            end
    end

    %%% Updates ROI rectangles
    for i=1:4
        h.Plots.ROI(i).Position=[Pos-0.5 Size];
    end
    %%% Updates images
    Mia_Correct([],[],2);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Funtion to update ROI position and size %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mia_Orientation(~,~,mode)
global MIAData UserValues
h = guidata(findobj('Tag','Mia'));

if isempty(MIAData.Data)
    return;
end

switch mode
    case {1, 2, 3}
        if size(MIAData.Data,1)~=2
            return;
        end
end
switch mode
    %% Rotate and flip data
    case 1
        MIAData.Data(2,:) = cellfun(@(x)fliplr(x),MIAData.Data(2,:),'UniformOutput',false);
        
    case 2
        MIAData.Data(2,:) = cellfun(@(x)flipud(x),MIAData.Data(2,:),'UniformOutput',false);
        
    case 3
        switch h.Mia_Image.Settings.Orientation_Rotate_Dir.Value
            case 1 % clockwise
                d = 1;
            case 2 % counterclockwise
                d = -1;
        end
        MIAData.Data(2,:) = cellfun(@(x)rot90(x,d),MIAData.Data(2,:),'UniformOutput',false);
    %% Convert data to photon counting when parameters change
    case 4
    % callback of the editboxes
        for i = 1:size(MIAData.Data,1)
            % read new values from user interface
            S = str2double(h.Mia_Image.Settings.S.String);
            offset = str2double(h.Mia_Image.Settings.Offset.String);
            % scale the displayed data to S = 1 and offset = 0
            MIAData.Data{i,1} = (MIAData.Data{i,1}.*UserValues.MIA.Options.S)+UserValues.MIA.Options.Offset;
            % scale the displayed data to the new values
            MIAData.Data{i,1} = (MIAData.Data{i,1}-offset)./S;
            %%% Updates plots
            Mia_ROI([],[],1)
        end
        
        % store the new values in UserValues
        UserValues.MIA.Options.S = S;
        UserValues.MIA.Options.Offset = offset;
        LSUserValues(1)
    case 5
    % Convert data to photon counting upon data load
        for i = 1:size(MIAData.Data,1)
            % rescale the data
            MIAData.Data{i,1} = (MIAData.Data{i,1}-str2double(h.Mia_Image.Settings.Offset.String))./str2double(h.Mia_Image.Settings.S.String);
        end
end

Update_Plots([],[],1,1:size(MIAData.Data,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Funtion to calculate image correlations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_2D_XCor(~,~,mode)
% mode = 1 % RICS
% mode = 2 % Van steensel type co-localization

h = guidata(findobj('Tag','Mia'));

global MIAData UserValues

%%% Stops, if no data was loaded
if size(MIAData.Data,1)<1
    return;
end

%%% Clears correlation data and plots
MIAData.Cor=cell(3,2);
for i=1:3
    h.Plots.Cor(i,1).CData=zeros(1,1,3);
    h.Plots.Cor(i,2).ZData=zeros(1);
    h.Plots.Cor(i,2).CData=zeros(1,1,3);    
    h.Mia_ICS.Axes(i,1).Visible='off';
    h.Mia_ICS.Axes(i,2).Visible='off';
    h.Mia_ICS.Axes(i,3).Visible='off';
    h.Mia_ICS.Axes(i,4).Visible='off';
    h.Plots.Cor(i,1).Visible='off';
    h.Plots.Cor(i,2).Visible='off';
    h.Plots.Cor(i,3).Visible='off';
    h.Plots.Cor(i,4).Visible='off';
    h.Plots.Cor(i,5).Visible='off';
    h.Plots.Cor(i,6).Visible='off';
    h.Plots.Cor(i,7).Visible='off';
end
h.Mia_ICS.Frame_Slider.Min=0;
h.Mia_ICS.Frame_Slider.Max=0;
h.Mia_ICS.Frame_Slider.SliderStep=[1 1];
h.Mia_ICS.Frame_Slider.Value=0;

if size(MIAData.Data,1)<2
    h.Mia_Image.Calculations.Cor_Type.Value=1;
end

%%% Determins, which correlations to perform
if mode == 2 %Van Steensel type colocalization
    Auto = 1:2; Cross = 1;
    channel=2; %the CCF is stored at channe 2
elseif h.Mia_Image.Calculations.Cor_Type.Value==3
    Auto=1:2; Cross=1;
    channel=1:3;
else
    Auto=h.Mia_Image.Calculations.Cor_Type.Value; Cross=0;
    channel=floor(Auto*1.5);
end


%%% Determins, which frames to correlate
Frames=str2num(h.Mia_Image.Settings.ROI_Frames.String); %#ok<ST2NM> %%% Uses str2num, because the output is not scalar
%%% Uses all Frames, if input was 0
if all(Frames==0)
    Frames=1:size(MIAData.Data{1,2},3);
end
%%% Remove all Frames<1 and >Movie size
if any(Frames<0 | Frames>size(MIAData.Data{1,2},3))
    Min=max(1,min(Frames)); Min=min(Min,size(MIAData.Data{1,2},3));   
    Max=min(size(MIAData.Data{1,2},3),max(Frames)); Max=max(Max,1);
    Frames=Min:Max;
    h.Mia_Image.Settings.ROI_Frames.String=[num2str(Min) ':' num2str(Max)];
end

%%% Applies arbitrary region selection
switch (h.Mia_Image.Settings.ROI_FramesUse.Value)
    case 1 %%% Use All Frames
    case 2 %%% Use selected Frames
        if Cross
            Active=find(prod(MIAData.Use));
        else
            Active=find(MIAData.Use(Auto,:));
        end
        Frames=intersect(Frames,Active);
    case 3 %%% Does arbitrary region ICS
        if Cross
            Active=find(prod(MIAData.Use));
        else
            Active=find(MIAData.Use(Auto,:));
        end
        Frames=intersect(Frames,Active);
        for i=Auto
            Use{i} = MIAData.AR{i,1}(:,:,Frames) & repmat(MIAData.MS{i},1,1,numel(Frames));
        end
end

%%% Performs autocorrelation
for i=Auto
    Progress(0,h.Mia_Progress_Axes, h.Mia_Progress_Text,['Correlating ACF' num2str(i)]);
    MIAData.Cor{floor(i*1.5)}=zeros(size(MIAData.Data{1,2},1),size(MIAData.Data{1,2},2),numel(Frames));
    TotalInt = zeros(numel(Frames));
    TotalPx = zeros(numel(Frames));
    for j=1:numel(Frames)
        Image=double(MIAData.Data{i,2}(:,:,Frames(j)));
        Size = [2*size(Image,1)-1, 2*size(Image,2)-1];
        if h.Mia_Image.Settings.ROI_FramesUse.Value==3  %%% Arbitrary region ICS
            %%% Calculates normalization for zero regions
            Norm=fft2(Use{i}(:,:,j),Size(1),Size(2));
            Norm=fftshift(ifft2(Norm.*conj(Norm)));
            %%% Calculates fluctutation image
            ImageFluct=Image-mean(Image(Use{i}(:,:,j)));
            %%% Applies selected region and FFT
            ImageFluct=fft2(ImageFluct.*Use{i}(:,:,j),Size(1),Size(2));
            %%% Actual correlation
            ImageCor = fftshift(real(ifft2(ImageFluct.*conj(ImageFluct))));
            %%% Corrects for shape of selected region
            ImageCor = ImageCor./Norm;
            ImageCor = ImageCor(ceil(Size(1)/4):round(Size(1)*3/4),ceil(Size(2)/4):round(Size(2)*3/4));
            MIAData.Cor{floor(i*1.5)}(:,:,j)=ImageCor./(mean2(Image(Use{i}(:,:,j)))^2);
            %%% Used to calculate total mean
            TotalInt(j)=sum(Image(Use{i}(:,:,j)));
            TotalPx(j)=numel(Image(Use{i}(:,:,j)));
        else %%% Standard ICS
            %%% Actual correlation
            Image_FFT=fft2(Image);
            %%% Used to calculate total mean
            TotalInt(j)=sum(sum((Image)));
            TotalPx(j)=numel(Image);
            MIAData.Cor{floor(i*1.5)}(:,:,j)=fftshift(real(ifft2(Image_FFT.*conj(Image_FFT))))/(size(Image,1)*size(Image,2)*(mean2(Image))^2)-1;
        end
        if mod(j,100)==0
            Progress(j/numel(Frames),h.Mia_Progress_Axes, h.Mia_Progress_Text,['Correlating ACF' num2str(i)]);
        end       
    end
    %%% Calculates mean intensity for saving
    MeanInt(i)=sum(TotalInt)/sum(TotalPx);
    clear Image ImageFluct ImageCor;
end
%%% Performs crosscorrelation
if Cross
    MIAData.Cor{2}=zeros(size(MIAData.Data{1,2},1),size(MIAData.Data{1,2},2),numel(Frames));
    for j=1:numel(Frames)
        Image{1}=double(MIAData.Data{1,2}(:,:,Frames(j)));
        Image{2}=double(MIAData.Data{2,2}(:,:,Frames(j)));
        Size = [2*size(Image{1},1)-1, 2*size(Image{1},2)-1];
        if h.Mia_Image.Settings.ROI_FramesUse.Value==3  %%% Arbitrary region ICS
            %%% Calculates normalization for zero regions
            Norm=fft2(Use{1}(:,:,j).*Use{2}(:,:,j),Size(1),Size(2));
            Norm=fftshift(ifft2(Norm.*conj(Norm)));
            %%% Calculates fluctutation image
            ImageFluct{1}=Image{1}-mean(Image{1}(Use{1}(:,:,j) & Use{2}(:,:,j)));
            ImageFluct{2}=Image{2}-mean(Image{2}(Use{1}(:,:,j) & Use{2}(:,:,j)));
            %%% Applies selected region and FFT
            ImageFluct{1}=fft2(ImageFluct{1}.*(Use{1}(:,:,j) & Use{2}(:,:,j)),Size(1),Size(2));
            ImageFluct{2}=fft2(ImageFluct{2}.*(Use{1}(:,:,j) & Use{2}(:,:,j)),Size(1),Size(2));
            %%% Actual correlation
            ImageCor = fftshift(real(ifft2(ImageFluct{1}.*conj(ImageFluct{2}))));
            %%% Corrects for shape of selected region
            ImageCor = ImageCor./Norm;
            ImageCor = ImageCor(ceil(Size(1)/4):round(Size(1)*3/4),ceil(Size(2)/4):round(Size(2)*3/4));
            switch mode
                case 1 %normal cc(R)ICS
                    MIAData.Cor{2}(:,:,j)=ImageCor/(mean(Image{1}(Use{1}(:,:,j) & Use{2}(:,:,j)))*mean(Image{2}(Use{1}(:,:,j) & Use{2}(:,:,j))));
                case 2 %Van Steensel type colocalization, but then in 2D
                    MIAData.Cor{2}(:,:,j)=ImageCor/(std(Image{1}(Use{1}(:,:,j) & Use{2}(:,:,j)))*std(Image{2}(Use{1}(:,:,j) & Use{2}(:,:,j))));
            end
        else
            ImageFluct{1} = Image{1}-mean2(Image{1});
            ImageFluct{2} = Image{2}-mean2(Image{2});
            %%% Actual correlation
            MIAData.Cor{2}(:,:,j)=fftshift(real(ifft2(fft2(ImageFluct{1}).*conj(fft2(ImageFluct{2})))))/(size(Image{1},1)*size(Image{1},2));
            switch mode
                case 1 %normal cc(R)ICS
                    MIAData.Cor{2}(:,:,j)=MIAData.Cor{2}(:,:,j)/(mean2(Image{1})*mean2(Image{2}));
                case 2 %Van Steensel type colocalization, but then in 2D
                    MIAData.Cor{2}(:,:,j)=MIAData.Cor{2}(:,:,j)/(std2(Image{1})*std2(Image{2}));
            end
        end
        if mod(j,100)==0
            Progress(j/numel(Frames),h.Mia_Progress_Axes, h.Mia_Progress_Text,'Correlating CCF');
        end
        
    end
end
clear Image ImageFluct ImageCor;

Progress(1,h.Mia_Progress_Axes, h.Mia_Progress_Text);
%%% Corrects the amplitude changes due to temporal moving average addition/subtraction
%%% The Formula assumes 2 or 3 species with different brightnesses and corrects the amplitude accordingly
if h.Mia_Image.Settings.Correction_Add.Value==5 && h.Mia_Image.Settings.Correction_Subtract.Value==4 %%% Subtracts and Adds moving average
    Sub=str2double(h.Mia_Image.Settings.Correction_Subtract_Frames.String);
    Add=str2double(h.Mia_Image.Settings.Correction_Add_Frames.String);
    if Sub~=Add %%% If Add==Sub, nothing was done        
        Correct=1/((1+1/Add-1/Sub)^2+(1/Add-1/Sub)^2*(min(Add,Sub)-1)+(1/max(Add,Sub))^2*abs(Add-Sub));
    else %%% If Add==Sub, nothing was done
        Correct=1;
    end
elseif h.Mia_Image.Settings.Correction_Add.Value==5
    Add=str2double(h.Mia_Image.Settings.Correction_Add_Frames.String); 
    Correct=1/((1+1/Add)^2+(1/Add)^2*(Add-1));
elseif h.Mia_Image.Settings.Correction_Subtract.Value==4
    Sub=str2double(h.Mia_Image.Settings.Correction_Subtract_Frames.String);
    Correct=1/((1-1/Sub)^2+(1/Sub)^2*(Sub-1));
else
    Correct=1;
end
%%% Applies amplitude correction
for i=1:size(MIAData.Cor)
    if ~isempty(MIAData.Cor{i})
        MIAData.Cor{i}=MIAData.Cor{i}*Correct;
    end
end

switch mode
    case 1 %normal RICS
        savedata = h.Mia_Image.Calculations.Cor_Save_ICS.Value;
    case 2 %Van Steensel type colocalization
        savedata = h.Mia_Image.Calculations.Save_Coloc.Value;
end

%%% Saves correlation files
if savedata > 1
    if ~isdir(fullfile(UserValues.File.MIAPath,'Mia'))
        mkdir(fullfile(UserValues.File.MIAPath,'Mia'))
    end
    
    if savedata ~= 4 %% normal saving
        Window = numel(Frames);
        Offset = numel(Frames);
        Blocks = 1;
    else  %% save blockwise .miacor
        % Window size
        if str2double(h.Mia_Image.Calculations.Cor_ICS_Window.String) == 0
            h.Mia_Image.Calculations.Cor_ICS_Window.String = num2str(floor(numel(Frames)/5));
        end
        Window = str2double(h.Mia_Image.Calculations.Cor_ICS_Window.String);
        % Offset size
        if str2double(h.Mia_Image.Calculations.Cor_ICS_Offset.String) == 0
            h.Mia_Image.Calculations.Cor_ICS_Offset.String = num2str(Window);
        end
        Offset = str2double(h.Mia_Image.Calculations.Cor_ICS_Offset.String);
        % n.o. blocks
        Blocks = floor((numel(Frames)-Window+Offset)/Offset);
        if Blocks < 1 %% reset values to make it work
            h.Mia_Image.Calculations.Cor_ICS_Window.String = num2str(floor(numel(Frames)/5));
            Window = str2double(h.Mia_Image.Calculations.Cor_ICS_Window.String);
            h.Mia_Image.Calculations.Cor_ICS_Offset.String = num2str(Window);
            Offset = str2double(h.Mia_Image.Calculations.Cor_ICS_Offset.String);
            Blocks = floor((numel(Frames)-Window+Offset)/Offset);
        end
    end

    for b = 1:Blocks
        frames = Frames(1+(b-1)*Offset:(b-1)*Offset+Window);
        DataAll=cell(3,2);
        InfoAll = struct;
        %% Gets auto correlation data to save
        for i = Auto
            %%% File name information
            InfoAll(i).File = MIAData.FileName{i};
            InfoAll(i).Path = UserValues.File.MIAPath;
            %%% ROI and TOI
            InfoAll(i).Frames = frames;
            From = h.Plots.ROI(1).Position(1:2)+0.5;
            To = From+h.Plots.ROI(1).Position(3:4)-1;
            InfoAll(i).ROI = [From To];
            %%% Pixel [us], Line [ms] and Frametime [s]
            InfoAll(i).Times = [str2double(h.Mia_Image.Settings.Image_Pixel.String) str2double(h.Mia_Image.Settings.Image_Line.String) str2double(h.Mia_Image.Settings.Image_Frame.String)];
            %%% Pixel size
            InfoAll(i).Size = str2double(h.Mia_Image.Settings.Image_Size.String);
            %%% Correction information
            InfoAll(i).Correction.SubType = h.Mia_Image.Settings.Correction_Subtract.String{h.Mia_Image.Settings.Correction_Subtract.Value};
            if h.Mia_Image.Settings.Correction_Subtract.Value == 4
                InfoAll(i).Correction.SubROI = [str2double(h.Mia_Image.Settings.Correction_Subtract_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Subtract_Frames.String)];
            end
            InfoAll(i).Correction.AddType = h.Mia_Image.Settings.Correction_Add.String{h.Mia_Image.Settings.Correction_Add.Value};
            if h.Mia_Image.Settings.Correction_Add.Value == 5
                InfoAll(i).Correction.AddROI = [str2double(h.Mia_Image.Settings.Correction_Add_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Add_Frames.String)];
            end
            %%% Correlation Type (Arbitrary region == 3)
            InfoAll(i).Type = h.Mia_Image.Settings.ROI_FramesUse.String{h.Mia_Image.Settings.ROI_FramesUse.Value};
            switch h.Mia_Image.Settings.ROI_FramesUse.Value
                case {1 2} %%% All/Selected frames
                    %%% Mean intensity [counts]
                    %InfoAll(i).Mean = mean2(double(MIAData.Data{i,2}(:,:,frames))); %Waldi
                    InfoAll(i).AR = [];
                case 3 %%% Arbitrary region
                    %%% Mean intensity of selected pixels [counts]
                    Image = double(MIAData.Data{i,2}(:,:,frames));
                    %InfoAll(i).Mean = mean(Image(Use{i}));
                    %%% Arbitrary region information
                    InfoAll(i).AR.Int_Max(1) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(1).String);
                    InfoAll(i).AR.Int_Max(2) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(2).String);
                    InfoAll(i).AR.Int_Min(1) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(1).String);
                    InfoAll(i).AR.Int_Min(2) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(2).String);
                    InfoAll(i).AR.Int_Fold_Max = str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Max.String);
                    InfoAll(i).AR.Int_Fold_Min = str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Min.String);
                    InfoAll(i).AR.Var_Fold_Max = str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Max.String);
                    InfoAll(i).AR.Var_Fold_Min = str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Min.String);
                    InfoAll(i).AR.Var_Sub=str2double(h.Mia_Image.Settings.ROI_AR_Sub2.String);
                    InfoAll(i).AR.Var_SubSub=str2double(h.Mia_Image.Settings.ROI_AR_Sub1.String);
            end
            %%% Mean intensity
            InfoAll(i).Counts = MeanInt(i); %Waldi
            %%% Averaged correlation
            DataAll{i,1} = mean(MIAData.Cor{floor(1.5*i),1}(:,:,(1:numel(frames))+(b-1)*Offset),3);
            %%% Error of correlation
            if size(MIAData.Cor{floor(1.5*i),1}(:,:,1:numel(frames)),3)>1
                DataAll{i,2} = std(MIAData.Cor{floor(1.5*i),1}(:,:,(1:numel(frames))+(b-1)*Offset),0,3)./sqrt(size(MIAData.Cor{floor(1.5*i),1}(:,:,(1:numel(frames))+(b-1)*Offset),3));
            else
                DataAll{i,2} = MIAData.Cor{floor(1.5*i),1}(:,:,(1:numel(frames))+(b-1)*Offset);
            end
        end
        %% Gets cross correlation data to save
        if Cross == 1
            %%% File name information
            InfoAll(3).File = MIAData.FileName{1};
            InfoAll(3).Path = UserValues.File.MIAPath;
            %%% ROI and TOI
            InfoAll(3).Frames = frames;
            From=h.Plots.ROI(1).Position(1:2)+0.5;
            To=From+h.Plots.ROI(1).Position(3:4)-1;
            InfoAll(3).ROI = [From To];
            %%% Pixel [us], Line [ms] and Frametime [s]
            InfoAll(3).Times = [str2double(h.Mia_Image.Settings.Image_Pixel.String) str2double(h.Mia_Image.Settings.Image_Line.String) str2double(h.Mia_Image.Settings.Image_Frame.String)];
            %%% Pixel size
            InfoAll(3).Size = str2double(h.Mia_Image.Settings.Image_Size.String);
            %%% Correction information
            InfoAll(3).Correction.SubType = h.Mia_Image.Settings.Correction_Subtract.String{h.Mia_Image.Settings.Correction_Subtract.Value};
            if h.Mia_Image.Settings.Correction_Subtract.Value == 4
                InfoAll(3).Correction.SubROI = [str2double(h.Mia_Image.Settings.Correction_Subtract_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Subtract_Frames.String)];
            end
            InfoAll(3).Correction.AddType = h.Mia_Image.Settings.Correction_Add.String{h.Mia_Image.Settings.Correction_Add.Value};
            if h.Mia_Image.Settings.Correction_Add.Value == 5
                InfoAll(3).Correction.AddROI = [str2double(h.Mia_Image.Settings.Correction_Add_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Add_Frames.String)];
            end
            %%% Correlation Type (Arbitrary region == 3)
            InfoAll(3).Type = h.Mia_Image.Calculations.Cor_Type.String{h.Mia_Image.Calculations.Cor_Type.Value};
            switch h.Mia_Image.Settings.ROI_FramesUse.Value
                case {1,2} %%% All/Selected frames
                    %%% Mean intensity [counts]
                    InfoAll(3).Mean = (mean2(double(MIAData.Data{1,2}(:,:,frames))) + mean2(double(MIAData.Data{2,2}(:,:,frames))))/2;
                    InfoAll(3).AR = [];
                case 3 %%% Arbitrary region
                    %%% Mean intensity of selected pixels [counts]
                    Use1 = Use{1}(frames);
                    Use2 = Use{2}(frames);
                    Image1 = double(MIAData.Data{1,2}(:,:,frames));
                    Image2 = double(MIAData.Data{2,2}(:,:,frames));
                    InfoAll(3).Mean = (mean(Image1(Use1 & Use2)) + mean(Image2(Use1 & Use2)))/2;
                    %%% Arbitrary region information
                    InfoAll(3).AR.Int_Max(1) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(1).String);
                    InfoAll(3).AR.Int_Min(1) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(1).String);
                    InfoAll(3).AR.Int_Max(2) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(2).String);
                    InfoAll(3).AR.Int_Min(2) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(2).String);
                    InfoAll(3).AR.Int_Fold_Max = str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Max.String);
                    InfoAll(3).AR.Int_Fold_Min = str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Min.String);
                    InfoAll(3).AR.Var_Fold_Max = str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Max.String);
                    InfoAll(3).AR.Var_Fold_Min = str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Min.String);
                    InfoAll(3).AR.Var_Sub=str2double(h.Mia_Image.Settings.ROI_AR_Sub2.String);
                    InfoAll(3).AR.Var_SubSub=str2double(h.Mia_Image.Settings.ROI_AR_Sub1.String);
            end
            %%% Mean intensity
            InfoAll(3).Counts = sum(MeanInt);
            %%% Averaged correlation
            DataAll{3,1} = mean(MIAData.Cor{2,1}(:,:,(1:numel(frames))+(b-1)*Offset),3);
            %%% Error of correlation
            DataAll{3,2} = std(MIAData.Cor{2,1}(:,:,1:numel(frames)),0,3)./sqrt(size(MIAData.Cor{2,1}(:,:,(1:numel(frames))+(b-1)*Offset),3));
        end
        %% Saves correlations
        switch savedata
            case {2,4} %%% .miacor filetype
                
                %% Creates new filename
                %%% Removes file extension
                switch MIAData.Type
                    case {1,1.5, 2}
                        FileName=MIAData.FileName{1}{1}(1:end-4);
                end
                
                if ~h.Mia_Image.Calculations.Save_Name.Value
                    %%% Manually enter a filename
                    [FileName,PathName] = uiputfile([FileName '.miacor'], 'Save correlation as', [UserValues.File.MIAPath,'Mia']);
                    if numel(FileName)>11 && (strcmp(FileName(end-11:end),'_ACF1_1.miacor') || strcmp(FileName(end-11:end),'_ACF2_1.miacor'))
                        FileName=FileName(1:end-12);
                        
                    elseif numel(FileName)>10 && strcmp(FileName(end-10:end),'_CCF_1.miacor')
                        FileName=FileName(1:end-11);
                    else
                        FileName=FileName(1:end-7);
                    end
                    Current_FileName1=fullfile(PathName,[FileName '_ACF1_1.miacor']);
                    Current_FileName2=fullfile(PathName,[FileName '_ACF2_1.miacor']);
                    Current_FileName3=fullfile(PathName,[FileName '_CCF_1.miacor']);
                    Current_FileName4=fullfile(PathName,[FileName '_Info_1.txt']);
                    
                else
                    %%% Automatically generate filename
                    Current_FileName1=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_ACF1_1.miacor']);
                    Current_FileName2=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_ACF2_1.miacor']);
                    Current_FileName3=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_CCF_1.miacor']);
                    Current_FileName4=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_Info_1.txt']);
                    %%% Checks, if file already exists and create new filename
                    if  exist(Current_FileName1,'file')  || exist(Current_FileName2,'file') || exist(Current_FileName3,'file') || exist(Current_FileName4,'file')
                        k=1;
                        %%% Adds 1 to filename
                        Current_FileName1=[Current_FileName1(1:end-9) '_' num2str(k) '.miacor'];
                        Current_FileName2=[Current_FileName2(1:end-9) '_' num2str(k) '.miacor'];
                        Current_FileName3=[Current_FileName3(1:end-9) '_' num2str(k) '.miacor'];
                        Current_FileName4=[Current_FileName4(1:end-6) '_' num2str(k) '.txt'];
                        %%% Increases counter, until no file is found
                        while exist(Current_FileName1,'file')  || exist(Current_FileName2,'file') || exist(Current_FileName3,'file') || exist(Current_FileName4,'file')
                            k=k+1;
                            Current_FileName1=[Current_FileName1(1:end-(7+numel(num2str(k-1)))) num2str(k) '.miacor'];
                            Current_FileName2=[Current_FileName2(1:end-(7+numel(num2str(k-1)))) num2str(k) '.miacor'];
                            Current_FileName3=[Current_FileName3(1:end-(7+numel(num2str(k-1)))) num2str(k) '.miacor'];
                            Current_FileName4=[Current_FileName4(1:end-(4+numel(num2str(k-1)))) num2str(k) '.txt'];
                        end
                    end
                end
                %%% Saves Auto correlations
                for i=Auto
                    Info = InfoAll(i); %#ok<NASGU>
                    Data = DataAll(i,:); 
                    if i==1
                        save(Current_FileName1,'Info','Data');
                    else
                        save(Current_FileName2,'Info','Data');
                    end
                end
                %%% Saves Cross correlations
                if Cross
                    Info = InfoAll(3); %#ok<NASGU>
                    Data = DataAll(3,:); 
                    save(Current_FileName3,'Info','Data');
                end
                
                %% Saves info file
                FID = fopen(Current_FileName4,'w');
                if Cross
                    Info = InfoAll(3);
                else
                    Info = InfoAll(Auto);
                end
                fprintf(FID,'%s\n','Image Correlation info file');
                %%% Pixel\Line\Frame times
                fprintf(FID,'%s\t%f\n', 'Pixel time [us]:',Info.Times(1));
                fprintf(FID,'%s\t%f\n', 'Line  time [ms]:',Info.Times(2));
                fprintf(FID,'%s\t%f\n', 'Frame time [s] :',Info.Times(3));
                %%% Pixel size
                fprintf(FID,'%s\t%f\n', 'Pixel size [nm]:',Info.Size);
                %%% Region of interest
                fprintf(FID,'%s\t%u,%u,%u,%u\t%s\n', 'Region used [px]:',Info.ROI, 'X Start, Y Start, X Stop, Y Stop');
                %%% Counts per pixel
                fprintf(FID,'%s\t%f\n', 'Mean counts per pixel:',Info.Counts);
                %%% Frames used
                fprintf(FID,['%s\t',repmat('%u\t',[1 numel(Info.Frames)]) '\n'],'Frames Used:',Info.Frames);
                %%% Subtraction used
                switch h.Mia_Image.Settings.Correction_Subtract.Value
                    case 1
                        fprintf(FID,'%s\n','Nothing subtracted');
                    case 2
                        fprintf(FID,'%s\n','Frame mean subtracted');
                    case 3
                        fprintf(FID,'%s\n','Pixel mean subtracted');
                    case 4
                        fprintf(FID,'%s\t%u%s\t%u%s\n','Moving average subtracted:', InfoAll(i).Correction.SubROI(1), ' Pixel', InfoAll(i).Correction.SubROI(2),' Frames');
                end
                %%% Addition used
                switch h.Mia_Image.Settings.Correction_Subtract.Value
                    case 1
                        fprintf(FID,'%s\n','Nothing added');
                    case 2
                        fprintf(FID,'%s\n','Total mean added');
                    case 3
                        fprintf(FID,'%s\n','Frame mean added');
                    case 4
                        fprintf(FID,'%s\n','Pixel mean added');
                    case 5
                        fprintf(FID,'%s\t%u%s%u%s\n','Moving average added:', InfoAll(i).Correction.SubROI(1), ' Pixel', InfoAll(i).Correction.SubROI(2),' Frames');
                end
                %%% Arbitrary region
                if h.Mia_Image.Settings.ROI_FramesUse.Value==3
                    fprintf(FID,'%s\n','Arbitrary region used:');
                    fprintf(FID,'%s\t%f\n','Minimal average intensity [kHz]:',InfoAll(i).AR.Int_Min(1), '; ', InfoAll(i).AR.Int_Min(2));
                    fprintf(FID,'%s\t%f\n','Maximal average intensity [kHz]:',InfoAll(i).AR.Int_Max(1), '; ', InfoAll(i).AR.Int_Max(2));
                    fprintf(FID,'%s\t%u,%u\n','Subregions size:',InfoAll(i).AR.Var_SubSub,InfoAll(i).AR.Var_Sub);
                    fprintf(FID,'%s\t%f,%f\n','Minimal\Maximal intensity deviation:',InfoAll(i).AR.Int_Fold_Min,InfoAll(i).AR.Int_Fold_Max);
                    fprintf(FID,'%s\t%f,%f\n','Minimal\Maximal variance deviation:',InfoAll(i).AR.Var_Fold_Min,InfoAll(i).AR.Var_Fold_Max);
                    
                end
                fclose(FID);
                
                
            case 3 %%% .tif + .txt files
                %% Creates new filename
                %%% Removes file extension
                switch MIAData.Type
                    case {1,2}
                        FileName=MIAData.FileName{1}{1}(1:end-4);
                end
                if ~h.Mia_Image.Calculations.Save_Name.Value
                    [FileName,PathName] = uiputfile([FileName '.tif'], 'Save correlation as', [UserValues.File.MIAPath,'Mia']);
                    if numel(FileName)>8 && (strcmp(FileName(end-8:end),'_ACF1.tif') || strcmp(FileName(end-8:end),'_ACF2.tif'))
                        FileName=FileName(1:end-9);
                        
                    elseif numel(FileName)>7 && strcmp(FileName(end-7:end),'_CCF.tif')
                        FileName=FileName(1:end-8);
                    else
                        FileName=FileName(1:end-4);
                    end
                    Current_FileName1=fullfile(PathName,[FileName '_ACF1.tif']);
                    Current_FileName2=fullfile(PathName,[FileName '_ACF2.tif']);
                    Current_FileName3=fullfile(PathName,[FileName '_CCF.tif']);
                    Current_FileName4=fullfile(PathName,[FileName '_Info.txt']);
                    
                else
                    
                    
                    %%% Generates filename
                    Current_FileName1=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_ACF1.tif']);
                    Current_FileName2=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_ACF2.tif']);
                    Current_FileName3=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_CCF.tif']);
                    Current_FileName4=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_Info.txt']);
                    %%% Checks, if file already exists and create new filename
                    if  exist(Current_FileName1,'file')  || exist(Current_FileName2,'file') || exist(Current_FileName3,'file') || exist(Current_FileName4,'file')
                        k=1;
                        %%% Adds 1 to filename
                        Current_FileName1=[Current_FileName1(1:end-4) '_' num2str(k) '.tif'];
                        Current_FileName2=[Current_FileName2(1:end-4) '_' num2str(k) '.tif'];
                        Current_FileName3=[Current_FileName3(1:end-4) '_' num2str(k) '.tif'];
                        Current_FileName4=[Current_FileName4(1:end-4) '_' num2str(k) '.txt'];
                        %%% Increases counter, until no file is found
                        while exist(Current_FileName1,'file')  || exist(Current_FileName2,'file') || exist(Current_FileName3,'file')
                            k=k+1;
                            Current_FileName1=[Current_FileName1(1:end-(4+numel(num2str(k-1)))) num2str(k) '.tif'];
                            Current_FileName2=[Current_FileName2(1:end-(4+numel(num2str(k-1)))) num2str(k) '.tif'];
                            Current_FileName3=[Current_FileName3(1:end-(4+numel(num2str(k-1)))) num2str(k) '.tif'];
                            Current_FileName4=[Current_FileName4(1:end-(4+numel(num2str(k-1)))) num2str(k) '.txt'];
                        end
                    end
                end
                %% Saves info file
                FID = fopen(Current_FileName4,'w');
                if Cross
                    Info = InfoAll(3);
                else
                    Info = InfoAll(Auto);
                end
                fprintf(FID,'%s\n','Image Correlation info file');
                %%% Pixel\Line\Frame times
                fprintf(FID,'%s\t%f\n', 'Pixel time [us]:',Info.Times(1));
                fprintf(FID,'%s\t%f\n', 'Line  time [ms]:',Info.Times(2));
                fprintf(FID,'%s\t%f\n', 'Frame time [s] :',Info.Times(3));
                %%% Pixel size
                fprintf(FID,'%s\t%f\n', 'Pixel size [nm]:',Info.Size);
                %%% Region of interest
                fprintf(FID,'%s\t%u,%u,%u,%u\t%s\n', 'Region used [px]:',Info.ROI, 'X Start, Y Start, X Stop, Y Stop');
                %%% Counts per pixel
                fprintf(FID,'%s\t%f\n', 'Mean counts per pixel:',Info.Counts);
                %%% Frames used
                fprintf(FID,['%s\t',repmat('%u\t',[1 numel(Info.Frames)]) '\n'],'Frames Used:',Info.Frames);
                %%% Subtraction used
                switch h.Mia_Image.Settings.Correction_Subtract.Value
                    case 1
                        fprintf(FID,'%s\n','Nothing subtracted');
                    case 2
                        fprintf(FID,'%s\n','Frame mean subtracted');
                    case 3
                        fprintf(FID,'%s\n','Pixel mean subtracted');
                    case 4
                        fprintf(FID,'%s\t%u%s\t%u%s\n','Moving average subtracted:', InfoAll(i).Correction.SubROI(1), ' Pixel', InfoAll(i).Correction.SubROI(2),' Frames');
                end
                %%% Addition used
                switch h.Mia_Image.Settings.Correction_Subtract.Value
                    case 1
                        fprintf(FID,'%s\n','Nothing added');
                    case 2
                        fprintf(FID,'%s\n','Total mean added');
                    case 3
                        fprintf(FID,'%s\n','Frame mean added');
                    case 4
                        fprintf(FID,'%s\n','Pixel mean added');
                    case 5
                        fprintf(FID,'%s\t%u%s%u%s\n','Moving average added:', InfoAll(i).Correction.SubROI(1), ' Pixel', InfoAll(i).Correction.SubROI(2),' Frames');
                end
                %%% Arbitrary region
                if h.Mia_Image.Settings.ROI_FramesUse.Value==3
                    fprintf(FID,'%s\n','Arbitrary region used:');
                    fprintf(FID,'%s\t%f\n','Minimal average intensity [kHz]:',InfoAll(i).AR.Int_Min(1), '; ',InfoAll(i).AR.Int_Min(2));
                    fprintf(FID,'%s\t%f\n','Maximal average intensity [kHz]:',InfoAll(i).AR.Int_Max(1), '; ',InfoAll(i).AR.Int_Max(2));
                    fprintf(FID,'%s\t%u,%u\n','Subregions size:',InfoAll(i).AR.Var_SubSub,InfoAll(i).AR.Var_Sub);
                    fprintf(FID,'%s\t%f,%f\n','Minimal\Maximal intensity deviation:',InfoAll(i).AR.Int_Fold_Min,InfoAll(i).AR.Int_Fold_Max);
                    fprintf(FID,'%s\t%f,%f\n','Minimal\Maximal variance deviation:',InfoAll(i).AR.Var_Fold_Min,InfoAll(i).AR.Var_Fold_Max);
                    
                end
                fclose(FID);
                %% Saves correlation TIFFs
                for i=Auto
                    %%% Resizes double to 16bit uint
                    Data{1} = DataAll{i,1};
                    Min(1) = min(min(Data{1}));
                    Max(1) = max(max(Data{1}));
                    Data{1} = uint16(2^16*(Data{1}-Min(1))/(Max(1)-Min(1)));
                    Data{2} = DataAll{i,2};
                    Min(2) = min(min(Data{2}));
                    Max(2) = max(max(Data{2}));
                    Data{2} = uint16(2^16*(Data{2}-Min(2))/(Max(2)-Min(2)));
                    %%% Creates header information
                    TiffStruct.ImageWidth = size(Data{1},2);
                    TiffStruct.ImageLength = size(Data{1},1);
                    TiffStruct.BitsPerSample = 16;
                    TiffStruct.Photometric = Tiff.Photometric.MinIsBlack;
                    TiffStruct.Compression = Tiff.Compression.LZW;
                    TiffStruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
                    TiffStruct.ImageDescription = num2str([round(2^16/(Max(1)-Min(1))), Min(1), InfoAll(i).Counts, InfoAll(i).Times(1)]);
                    %%% Creates new TIFF file
                    if i==1
                        
                        t = Tiff(Current_FileName1,'w');
                    else
                        t = Tiff(Current_FileName2,'w');
                    end
                    %%% Saves correlation as 2 frames (Cor and Error)
                    t.setTag(TiffStruct);
                    t.write(Data{1});
                    t.writeDirectory();
                    TiffStruct.ImageDescription = num2str([round(2^16/(Max(1)-Min(1))), Min(1), InfoAll(i).Counts, InfoAll(i).Times(1)]);
                    t.setTag(TiffStruct);
                    t.write(Data{2});
                    t.close();
                end
                if Cross
                    %%% Resizes double to 16bit uint
                    Data{1} = DataAll{3,1};
                    Min(1) = min(min(Data{1}));
                    Max(1) = max(max(Data{1}));
                    Data{1} = uint16(2^16*(Data{1}-Min(1))/(Max(1)-Min(1)));
                    Data{2} = DataAll{i,2};
                    Min(2) = min(min(Data{2}));
                    Max(2) = max(max(Data{2}));
                    Data{2} = uint16(2^16*(Data{2}-Min(2))/(Max(2)-Min(2)));
                    %%% Creates header information
                    TiffStruct.ImageWidth = size(Data{1},2);
                    TiffStruct.ImageLength = size(Data{1},1);
                    TiffStruct.BitsPerSample = 16;
                    TiffStruct.Photometric = Tiff.Photometric.MinIsBlack;
                    TiffStruct.Compression = Tiff.Compression.LZW;
                    TiffStruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
                    TiffStruct.ImageDescription = num2str([round(2^16/(Max(1)-Min(1))), Min(1), InfoAll(3).Counts, InfoAll(3).Times(1)]);
                    %%% Creates new TIFF file
                    t = Tiff(Current_FileName3,'w');
                    %%% Saves correlation as 2 frames (Cor and Error)
                    t.setTag(TiffStruct);
                    t.write(Data{1});
                    t.writeDirectory();
                    TiffStruct.ImageDescription = num2str([round(2^16/(Max(2)-Min(2))), Min(2)]);
                    t.setTag(TiffStruct);
                    t.write(Data{2});
                    t.close();
                end
                
            otherwise
        end
        
    end
end



for i=channel
    h.Mia_ICS.Axes(i,1).Visible='on';
    h.Mia_ICS.Axes(i,2).Visible='on';
    h.Mia_ICS.Axes(i,3).Visible='on';
    h.Plots.Cor(i,1).Visible='on';
    h.Plots.Cor(i,2).Visible='on';
    h.Plots.Cor(i,3).Visible='on';
    
    center=[floor(size(MIAData.Cor{i},1)/2)+1,floor(size(MIAData.Cor{i},2)/2)+1];
    MIAData.Cor{i}(center(1),center(2),:)=(MIAData.Cor{i}(center(1),center(2)-1,:)+MIAData.Cor{i}(center(1),center(2)+1,:))/2;
end

%%% Updates correlation frame slider
i=channel(1);
h.Mia_ICS.Frame_Slider.Min=0;
h.Mia_ICS.Frame_Slider.Max=size(MIAData.Cor{i},3);
h.Mia_ICS.Frame_Slider.SliderStep=[1./(size(MIAData.Cor{i},3)+1),10/(size(MIAData.Cor{i},3)+1)];
h.Mia_ICS.Frame_Slider.Value=0;
h.Mia_ICS.Frames2Use.String=['1:' num2str(size(MIAData.Cor{i},3))];

%%% Updates correlation plots

Update_Plots([],[],2,channel);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Funtion to calculate temporal image correlations %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_1D_XCor(obj,~)
global MIAData
h = guidata(findobj('Tag','Mia'));

%%% Stops, if no data was loaded
if size(MIAData.Data,1)<1
    return;
end

h.Mia_Progress_Text.String = 'Correlating';
h.Mia_Progress_Axes.Color=[1 0 0];  
drawnow;
%%% Clears correlation data and plots
MIAData.TICS.Data = [];
MIAData.TICS.MS = [];

%%% Adjust for number of selected files
if size(MIAData.Data,1)<2
    h.Mia_Image.Calculations.Cor_Type.Value = 1;
end

%%% Determines, which correlations to perform
if h.Mia_Image.Calculations.Cor_Type.Value==3
    Auto = 1:2; Cross = 1;
    channel = 1:3;
else
    Auto = h.Mia_Image.Calculations.Cor_Type.Value; Cross = 0;
    channel = floor(Auto*1.5);
end
MIAData.TICS.Auto = Auto;
MIAData.TICS.Cross = Cross;

%%% Determins, which frames to correlate
Frames = sort(str2num(h.Mia_Image.Settings.ROI_Frames.String)); %#ok<ST2NM> %%% Uses str2num, because the output is not scalar
%%% Uses all Frames, if input was 0
if all(Frames == 0)
    Frames = 1:size(MIAData.Data{1,2},3);
end
%%% Remove all Frames<1 and >Movie size
if any(Frames<0 | Frames>size(MIAData.Data{1,2},3))
    Min = max(1,min(Frames)); Min = min(Min,size(MIAData.Data{1,2},3));   
    Max = min(size(MIAData.Data{1,2},3),max(Frames)); Max = max(Max,1);
    Frames = Min:Max;
    h.Mia_Image.Settings.ROI_Frames.String = [num2str(Min) ':' num2str(Max)];
end

%%% Applies arbitrary region selection
switch (h.Mia_Image.Settings.ROI_FramesUse.Value)
    case 1 %%% Use All Frames
        for i=Auto
            Use{i} = true(size(MIAData.Data{1,2},1), size(MIAData.Data{1,2},2), Frames(end));
        end
    case 2 %%% Use selected Frames
        if Cross
            Active = find(prod(MIAData.Use));
        else
            Active = find(MIAData.Use(Auto,:));
        end
        Frames = intersect(Frames,Active);
        for i=Auto
            Use{i} = true(size(MIAData.Data{1,2},1), size(MIAData.Data{1,2},2), Frames(end));
        end        
    case 3 %%% Does arbitrary region ICS
        if Cross
            Active = find(prod(MIAData.Use));
        else
            Active = find(MIAData.Use(Auto,:));
        end
        Frames = intersect(Frames,Active);
        for i=Auto
            Use{i} = logical(MIAData.AR{i,1}(:,:,1:Frames(end)) & repmat(MIAData.MS{i},1,1,Frames(end)));
        end   
end
MIAData.TICS.Frames = Frames;
MIAData.TICS.Use = Use;
%% Performs TICS correlation
for i=1:3 %%%    
    if any(Auto==i) || (i==3 && Cross)       
        %% FFT based time correlation
        %%% Exctracts data and sets unused frames to 0
        Empty = setdiff(Frames(1):Frames(end),Frames)-Frames(1);
        if i<3 %%% For autocorrelation both channels are equal
            Norm = logical(Use{i}(:,:,Frames(1):Frames(end)));
            Norm (:,:,Empty) = false;
            TICS{1} = MIAData.Data{i,2}(:,:,(Frames(1):Frames(end)));
            TICS{1}(~Norm) = NaN;
            Int{1} = nanmean(TICS{1},3);
            TICS{1} = TICS{1}-mean2(TICS{1}(Norm));
            TICS{1}(~Norm) = 0;
            Int{2} = Int{1};
        else %%% For crosscorelation, use both channels
            Norm = logical(Use{1}(:,:,Frames(1):Frames(end)) & Use{2}(:,:,Frames(1):Frames(end)));
            Norm (:,:,Empty) = false;
            TICS{1} = MIAData.Data{1,2}(:,:,(Frames(1):Frames(end)));
            TICS{1}(~Norm) = NaN;
            Int{1} = nanmean(TICS{1},3);
            TICS{1} = TICS{1}-mean2(TICS{1}(Norm));
            TICS{1}(~Norm) = 0;
            TICS{2} = MIAData.Data{2,2}(:,:,(Frames(1):Frames(end)));
            TICS{2}(~Norm) = NaN;
            Int{2} = nanmean(TICS{2},3);
            TICS{2} = TICS{2}-mean2(TICS{2}(Norm));
            TICS{2}(~Norm) = 0;
        end
        
        %%% Calculate normalization, acounting for arbitrary region and
        %%% missing frames
        Normt = Norm; clear Norm;
        for l = 1:size(Normt,1)
            Norm = Normt(l,:,:);
            Norm = single(fft(Norm,2*size(Norm,3)-1,3));
            Norm = fftshift(real(ifft(Norm.*conj(Norm),[],3)),3);
            %%% Averages forward and backward correlation
            if mod(size(Norm,3),2) == 0
                Norm = Norm(:,:,(size(Norm,3)/2):-1:2)+Norm(:,:,(size(Norm,3)/2)+2:end);
            else
                Norm = Norm(:,:,(floor(size(Norm,3)/2):-1:1))+Norm(:,:,(ceil(size(Norm,3)/2)+1:end));
            end
            %%% Removes very long lag times (1/10th of frames)
            Norm = Norm(:,:,1:ceil((Frames(end)-Frames(1))/10));

            %%% FFT based time correlation 
            TICSl{1} = fft(TICS{1}(l,:,:),2*size(TICS{1},3)-1,3);
            if i<3 %%% Saves time for autocorrelation
                TICSl{2}=TICSl{1};
            else
                TICSl{2} = fft(TICS{2}(l,:,:),2*size(TICS{2},3)-1,3);
            end
            TICSresult = fftshift(real(ifft(TICSl{1}.*conj(TICSl{2}),[],3)),3);
            % clear TICS;
            %%% Averages forward and backward correlation
            if mod(size(TICSresult,3),2) == 0
                TICSresult = TICSresult(:,:,(size(TICSresult,3)/2):-1:2)+TICSresult(:,:,(size(TICSresult,3)/2)+2:end);
            else
                TICSresult = TICSresult(:,:,(floor(size(TICSresult,3)/2):-1:1))+TICSresult(:,:,(ceil(size(TICSresult,3)/2)+1:end));
            end
            %%% Removes very long lag times (1/10th of frames)
            TICSresult = TICSresult(:,:,1:ceil((Frames(end)-Frames(1))/10));
            %%% Normalizes to different lag occurrence
            TICSresult = TICSresult./Norm;
            clear Norm;
            %%% Normalizes to pixel intensity
            MIAData.TICS.Data{i}(l,:,:) = TICSresult./repmat(Int{1}(l,:).*Int{2}(l,:),1,1,size(TICSresult,3));
        end
        clear Normt;
        MIAData.TICS.Int{i,1} = Int{1};
        MIAData.TICS.Int{i,2} = Int{2};
        clear TICSresult;
        %%% Remove too dark pixels
        Valid = sqrt(Int{1}.*Int{2})> nanmean(nanmean(sqrt(Int{1}.*Int{2}),2),1)/10;
        MIAData.TICS.Data{i}(~repmat(Valid,1,1,size(MIAData.TICS.Data{i},3))) = NaN;
        MIAData.TICS.Counts = [nanmean(nanmean(Int{1},2),1) nanmean(nanmean(Int{2},2),1)]/str2double(h.Mia_Image.Settings.Image_Pixel.String)*1000;
        data{i}.Valid = 1;
        data{i}.Cor_Times = (1:size(MIAData.TICS.Data{i},3))*str2double(h.Mia_Image.Settings.Image_Frame.String);
        data{i}.Cor_Average = double(squeeze(nanmean(nanmean(MIAData.TICS.Data{i},2),1))');
        data{i}.Cor_Array = data{i}.Cor_Average';
        data{i}.Cor_SEM = double(squeeze(nanstd(nanstd(MIAData.TICS.Data{i},0,2),0,1))');
        data{i}.Cor_SEM = data{i}.Cor_SEM./sqrt(sum(reshape(~isnan(MIAData.TICS.Data{i}),[],size(MIAData.TICS.Data{i},3)),1));
    end
end
%% Saves data & info file
if h.Mia_Image.Calculations.Cor_Save_TICS.Value == 2   
    Save_TICS([],[],data)
end
%%% Switches 2nd and 3rd entry to make it conform with ICS
%%% Cross is 2nd entry
if size(MIAData.TICS.Data,2)>1
    if size(MIAData.TICS.Data,2)==2
        % User calculated ACF2
        MIAData.TICS.Data{3} = MIAData.TICS.Data{2};
        MIAData.TICS.Data{2} = [];
    else
        % User calculated ACF+CCF
        MIAData.TICS.Data = MIAData.TICS.Data([1 3 2]);
    end
end

Update_Plots(obj,[],5,channel);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Funtion to calculate STICS/iMSD correlations %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_3D_XCor(~,~)
h = guidata(findobj('Tag','Mia'));
global MIAData UserValues

MIAData.STICS = [];
%%% Stops, if no data was loaded
if size(MIAData.Data,1)<1
    return;
end

if size(MIAData.Data,1)<2
    h.Mia_Image.Calculations.Cor_Type.Value=1;
end

%%% Determins, which correlations to perform
if h.Mia_Image.Calculations.Cor_Type.Value==3
    Auto=1:2; Cross=1;
else
    Auto=h.Mia_Image.Calculations.Cor_Type.Value; Cross=0;
end


%%% Determins, which frames to correlate
Frames = str2num(h.Mia_Image.Settings.ROI_Frames.String); %#ok<ST2NM> %%% Uses str2num, because the output is not scalar
%%% Uses all Frames, if input was 0
if all(Frames==0)
    Frames=1:size(MIAData.Data{1,2},3);
end
%%% Remove all Frames<1 and >Movie size
if any(Frames<0 | Frames>size(MIAData.Data{1,2},3))
    Min=max(1,min(Frames)); Min=min(Min,size(MIAData.Data{1,2},3));   
    Max=min(size(MIAData.Data{1,2},3),max(Frames)); Max=max(Max,1);
    Frames=Min:Max;
    h.Mia_Image.Settings.ROI_Frames.String=[num2str(Min) ':' num2str(Max)];
end

%%% Applies arbitrary region selection
switch (h.Mia_Image.Settings.ROI_FramesUse.Value)
    case 1 %%% Use All Frames
        for i=Auto
            Use{i} = true(size(MIAData.Data{i,2},1),size(MIAData.Data{i,2},2),numel(Frames));
        end
    case 2 %%% Use selected Frames
        if Cross
            Active = find(prod(MIAData.Use));
        else
            Active = find(MIAData.Use(Auto,:));
        end
        Frames=intersect(Frames,Active);
        for i=Auto
            Use{i} = true(size(MIAData.Data{i,2},1),size(MIAData.Data{i,2},2),numel(Frames));
        end
    case 3 %%% Does arbitrary region ICS
        if Cross
            Active=find(prod(MIAData.Use));
        else
            Active=find(MIAData.Use(Auto,:));
        end
        Frames=intersect(Frames,Active);
        for i=Auto
            Use{i} = MIAData.AR{i,1}(:,:,Frames) & repmat(MIAData.MS{i},1,1,numel(Frames));
        end
end


MaxLag = str2double(h.Mia_Image.Calculations.Cor_ICS_Window.String);
h.Mia_STICS.Lag_Slider.Max = MaxLag;
h.Mia_STICS.Lag_Slider.SliderStep = [1/MaxLag 1/MaxLag];


%% Performs stapio temporal correlation
for i = 1:3
    if any(Auto==i) || (i==3 && Cross)
        TotalInt = zeros(numel(Frames));
        TotalPx = zeros(numel(Frames));
        Fist = 2-abs(i-2);        
        Second = floor(i/2)+1;              
        MIAData.STICS{i} = single(zeros(size(MIAData.Data{Fist,2},1),size(MIAData.Data{Fist,2},2),MaxLag+1));
        MIAData.STICS_SEM{i} = single(zeros(size(MIAData.Data{Fist,2},1),size(MIAData.Data{Fist,2},2),MaxLag+1));
        STICS_Num = uint16(zeros(size(MIAData.Data{Fist,2},1),size(MIAData.Data{Fist,2},2),MaxLag+1));
        if i<3
            Progress(0,h.Mia_Progress_Axes, h.Mia_Progress_Text,['Correlating ACF' num2str(i)]);
        else
            Progress(0,h.Mia_Progress_Axes, h.Mia_Progress_Text,'Correlating CCF');
        end
        for j=i:numel(Frames)
            Image{1} = double(MIAData.Data{Fist,2}(:,:,Frames(j)));
            if i<3
                TotalInt(j)=sum(Image{1}(Use{i}(:,:,j)));
                TotalPx(j)=numel(Image{1}(Use{i}(:,:,j)));
            end
            ImageFluct{1} = Image{1}-mean(Image{1}(Use{Fist}(:,:,j) & Use{Second}(:,:,j)));
            Size = [2*size(Image{1},1)-1, 2*size(Image{1},2)-1];
            ImageFluct{1} = fft2(ImageFluct{1}.*(Use{Fist}(:,:,j) & Use{Second}(:,:,j)),Size(1),Size(2));
                      
            for k = 0:MaxLag
                if any(Frames == Frames(j)+k)
                    Lag = find(Frames == Frames(j)+k,1,'first');
                    Image{2} = double(MIAData.Data{Second,2}(:,:,Frames(Lag)));
                    %%% Calculates normalization for zero regions
                    Norm=fft2(Use{Fist}(:,:,j).*Use{Second}(:,:,Lag),Size(1),Size(2));
                    Norm=fftshift(ifft2(Norm.*conj(Norm)));
                    %%% Calculates fluctutation image
                    
                    ImageFluct{2} = Image{2}-mean(Image{2}(Use{Fist}(:,:,j) & Use{Second}(:,:,Lag)));
                    %%% Applies selected region and FFT
                    
                    ImageFluct{2} = fft2(ImageFluct{2}.*(Use{Fist}(:,:,j) & Use{Second}(:,:,Lag)),Size(1),Size(2));
                    %%% Actual correlation
                    ImageCor = fftshift(real(ifft2(ImageFluct{1}.*conj(ImageFluct{2}))));
                    %%% Corrects for shape of selected region
                    ImageCor = ImageCor./Norm;
                    ImageCor = ImageCor(ceil(Size(1)/4):round(Size(1)*3/4),ceil(Size(2)/4):round(Size(2)*3/4));
                    ImageCor = ImageCor/(mean(Image{1}(Use{Fist}(:,:,j) & Use{Second}(:,:,Lag)))*mean(Image{2}(Use{Fist}(:,:,j) & Use{Second}(:,:,Lag))));
                    
                    %%% Searches for pixels with entries 
                    NonZero = ~isnan(ImageCor);
                    %%% Old mean
                    Old_Mean = MIAData.STICS{i}(:,:,k+1)./double(STICS_Num(:,:,k+1));   
                    Old_Mean(isnan(Old_Mean)) = 0;
                    %%% Adds to counter
                    STICS_Num(:,:,k+1) = STICS_Num(:,:,k+1) + uint16(~isnan(ImageCor));
                    ImageCor(isnan(ImageCor)) = 0;       
                    %%% Sum of correlations
                    MIAData.STICS{i}(:,:,k+1) = MIAData.STICS{i}(:,:,k+1) + ImageCor;
                    %%% New Mean
                    New_Mean = MIAData.STICS{i}(:,:,k+1)./double(STICS_Num(:,:,k+1));
                    
                    %%% Calculates "current mean" according to online
                    %%% algorithm (see wikipedia)
                    S = MIAData.STICS_SEM{i}(:,:,k+1);
                    S(NonZero) = S(NonZero) + (ImageCor(NonZero)-Old_Mean(NonZero)).*(ImageCor(NonZero)-New_Mean(NonZero));
                    MIAData.STICS_SEM{i}(:,:,k+1) = S;
                end                
            end            
            if mod(j,100)==0
                if i<3
                    Progress(j/numel(Frames),h.Mia_Progress_Axes, h.Mia_Progress_Text,['Correlating ACF' num2str(i)]);
                else
                    Progress(j/numel(Frames),h.Mia_Progress_Axes, h.Mia_Progress_Text,'Correlating CCF');
                end
            end
        end
        if i<3
            %%% Calculates mean intensity for saving
            MeanInt(i)=sum(TotalInt)/sum(TotalPx);
        end
        MIAData.STICS{i} = MIAData.STICS{i}./single(STICS_Num);
        MIAData.STICS_SEM{i} = sqrt(MIAData.STICS_SEM{i}./single(STICS_Num-1)./single(STICS_Num));
        
        %%% Removes noise peak at G(0, 0, 0)
        MIAData.STICS{i}(ceil((size(MIAData.STICS{i},1)+1)/2),ceil((size(MIAData.STICS{i},2)+1)/2),1) =...
            (MIAData.STICS{i}(ceil((size(MIAData.STICS{i},1)+1)/2),ceil((size(MIAData.STICS{i},2)+1)/2)-1,1)+...
             MIAData.STICS{i}(ceil((size(MIAData.STICS{i},1)+1)/2),ceil((size(MIAData.STICS{i},2)+1)/2)+1,1))/2;
        MIAData.STICS{i}(isnan(MIAData.STICS{i})) = 0;
    end  
end
clear Image ImageFluct ImageCor;

%%% Switches 2nd and 3rd entry to make it conform with ICS
%%% Cross is 2nd entry
if size(MIAData.STICS,2)>1
    if size(MIAData.STICS,2)==2
        MIAData.STICS{3} = MIAData.STICS{2};
        MIAData.STICS{2} = [];
    else
        MIAData.STICS = MIAData.STICS([1 3 2]);
    end
end

%%% Creates empty iMSD entry
for i=1:3
    if size(MIAData.STICS,2)>=i && ~isempty(MIAData.STICS{i})
        MIAData.iMSD{i,1} = zeros(size(MIAData.STICS{i},3),1);
        MIAData.iMSD{i,2} = zeros(size(MIAData.STICS{i},3),2);
    end
end

Progress(1,h.Mia_Progress_Axes, h.Mia_Progress_Text);
%% Saves correlations
if ~isdir(fullfile(UserValues.File.MIAPath,'Mia')) && h.Mia_Image.Calculations.Cor_Save_STICS.Value>1
    mkdir(fullfile(UserValues.File.MIAPath,'Mia'))
end
%%% .mcor filetype (iMSD)
if any(h.Mia_Image.Calculations.Cor_Save_STICS.Value == [2 4])
    %% Creates new filename
    %%% Removes file extension
    switch MIAData.Type
        case {1,2}
            FileName = MIAData.FileName{1}{1}(1:end-4);
    end
    %%% Generates filename
    Current_FileName1=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_iMSD1.mcor']);
    Current_FileName2=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_cciMSD.mcor']);
    Current_FileName3=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_iMSD2.mcor']);
    %%% Checks, if file already exists and create new filename
    if  exist(Current_FileName1,'file')  || exist(Current_FileName2,'file') || exist(Current_FileName3,'file')
        k=1;
        %%% Adds 1 to filename
        Current_FileName1=[Current_FileName1(1:end-5) '_' num2str(k) '.mcor'];
        Current_FileName2=[Current_FileName2(1:end-5) '_' num2str(k) '.mcor'];
        Current_FileName3=[Current_FileName3(1:end-5) '_' num2str(k) '.mcor'];
        %%% Increases counter, until no file is found
        while exist(Current_FileName1,'file')  || exist(Current_FileName2,'file') || exist(Current_FileName3,'file')
            k=k+1;
            Current_FileName1=[Current_FileName1(1:end-(6+numel(num2str(k-1)))) num2str(k) '.mcor'];
            Current_FileName2=[Current_FileName2(1:end-(6+numel(num2str(k-1)))) num2str(k) '.mcor'];
            Current_FileName3=[Current_FileName3(1:end-(6+numel(num2str(k-1)))) num2str(k) '.mcor'];
        end
    end
    for i=1:3
        if size(MIAData.iMSD,1) >= i && ~isempty(MIAData.iMSD{i,1})
            %%% Fit STICS data with gaussin
            if all(MIAData.iMSD{i,1}==0)
                Do_Gaussian
            end
            Header = 'iMSD correlation file'; %#ok<NASGU>
            Counts = [1 1];
            Valid = 1;
            Cor_Times = (0:(size(MIAData.iMSD{i,1},1)-1))'*str2double(h.Mia_Image.Settings.Image_Frame.String);
            Cor_Times(1) = 10^-10;
            Cor_Average = MIAData.iMSD{i,1}.^2;
            Cor_Array = MIAData.iMSD{i,1}.^2;
            Cor_SEM = (abs((MIAData.iMSD{i,1}.^2-MIAData.iMSD{i,2}(:,1).^2))+abs((MIAData.iMSD{i,1}.^2-MIAData.iMSD{i,2}(:,2).^2)))/2;
            save(eval(['Current_FileName' num2str(i)]),'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
        end
    end
end
%%% .stcor filetype
if any(h.Mia_Image.Calculations.Cor_Save_STICS.Value == [3 4])
    DataAll = cell(3,2);
    InfoAll = struct;
    %% Gets auto correlations data to save
    for i = Auto
        %%% File name information
        InfoAll(i).File = MIAData.FileName{i};
        InfoAll(i).Path = UserValues.File.MIAPath;
        %%% ROI and TOI
        InfoAll(i).Frames = Frames;
        From = h.Plots.ROI(1).Position(1:2)+0.5;
        To = From+h.Plots.ROI(1).Position(3:4)-1;
        InfoAll(i).ROI = [From To];
        %%% Pixel [us], Line [ms] and Frametime [s]
        InfoAll(i).Times = [str2double(h.Mia_Image.Settings.Image_Pixel.String) str2double(h.Mia_Image.Settings.Image_Line.String) str2double(h.Mia_Image.Settings.Image_Frame.String)];
        %%% Pixel size
        InfoAll(i).Size = str2double(h.Mia_Image.Settings.Image_Size.String);
        %%% Correction information
        InfoAll(i).Correction.SubType = h.Mia_Image.Settings.Correction_Subtract.String{h.Mia_Image.Settings.Correction_Subtract.Value};
        if h.Mia_Image.Settings.Correction_Subtract.Value == 4
            InfoAll(i).Correction.SubROI = [str2double(h.Mia_Image.Settings.Correction_Subtract_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Subtract_Frames.String)];
        end
        InfoAll(i).Correction.AddType = h.Mia_Image.Settings.Correction_Add.String{h.Mia_Image.Settings.Correction_Add.Value};
        if h.Mia_Image.Settings.Correction_Add.Value == 5
            InfoAll(i).Correction.AddROI = [str2double(h.Mia_Image.Settings.Correction_Add_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Add_Frames.String)];
        end
        %%% Correlation Type (Arbitrary region == 3)
        InfoAll(i).Type = h.Mia_Image.Settings.ROI_FramesUse.String{h.Mia_Image.Settings.ROI_FramesUse.Value};
        switch h.Mia_Image.Settings.ROI_FramesUse.Value
            case {1,2} %%% All/Selected frames
                %%% Mean intensity [counts]
                %InfoAll(i).Mean = mean2(double(MIAData.Data{i,2}(:,:,Frames)));
                InfoAll(i).AR = [];
            case 3 %%% Arbitrary region
                %%% Mean intensity of selected pixels [counts]
                Image = double(MIAData.Data{i,2}(:,:,Frames));
                %InfoAll(i).Mean = mean(Image(Use{i}));
                %%% Arbitrary region information
                InfoAll(i).AR.Int_Max(1) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(1).String);
                InfoAll(i).AR.Int_Max(2) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(2).String);
                InfoAll(i).AR.Int_Min(1) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(1).String);
                InfoAll(i).AR.Int_Min(2) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(2).String);
                InfoAll(i).AR.Int_Fold_Max = str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Max.String);
                InfoAll(i).AR.Int_Fold_Min = str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Min.String);
                InfoAll(i).AR.Var_Fold_Max = str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Max.String);
                InfoAll(i).AR.Var_Fold_Min = str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Min.String);
                InfoAll(i).AR.Var_Sub=str2double(h.Mia_Image.Settings.ROI_AR_Sub2.String);
                InfoAll(i).AR.Var_SubSub=str2double(h.Mia_Image.Settings.ROI_AR_Sub1.String);
        end
        %%% Mean intensity
        InfoAll(i).Counts = MeanInt(i);
        DataAll{i,1} = double(MIAData.STICS{floor(1.5*i)});
        DataAll{i,2} = double(MIAData.STICS_SEM{floor(1.5*i)});
    end
    %% Gets cross correlation data to save
    if Cross == 1
        %%% File name information
        InfoAll(3).File = MIAData.FileName{1};
        InfoAll(3).Path = UserValues.File.MIAPath;
        %%% ROI and TOI
        InfoAll(3).Frames = Frames;
        From=h.Plots.ROI(1).Position(1:2)+0.5;
        To=From+h.Plots.ROI(1).Position(3:4)-1;
        InfoAll(3).ROI = [From To];
        %%% Pixel [us], Line [ms] and Frametime [s]
        InfoAll(3).Times = [str2double(h.Mia_Image.Settings.Image_Pixel.String) str2double(h.Mia_Image.Settings.Image_Line.String) str2double(h.Mia_Image.Settings.Image_Frame.String)];
        %%% Pixel size
        InfoAll(3).Size = str2double(h.Mia_Image.Settings.Image_Size.String);
        %%% Correction information
        InfoAll(3).Correction.SubType = h.Mia_Image.Settings.Correction_Subtract.String{h.Mia_Image.Settings.Correction_Subtract.Value};
        if h.Mia_Image.Settings.Correction_Subtract.Value == 4
            InfoAll(3).Correction.SubROI = [str2double(h.Mia_Image.Settings.Correction_Subtract_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Subtract_Frames.String)];
        end
        InfoAll(3).Correction.AddType = h.Mia_Image.Settings.Correction_Add.String{h.Mia_Image.Settings.Correction_Add.Value};
        if h.Mia_Image.Settings.Correction_Add.Value == 5
            InfoAll(3).Correction.AddROI = [str2double(h.Mia_Image.Settings.Correction_Add_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Add_Frames.String)];
        end
        %%% Correlation Type (Arbitrary region == 3)
        InfoAll(3).Type = h.Mia_Image.Calculations.Cor_Type.String{h.Mia_Image.Calculations.Cor_Type.Value};
        switch h.Mia_Image.Settings.ROI_FramesUse.Value
            case {1,2} %%% All/Selected frames
                %%% Mean intensity [counts]
                InfoAll(3).Mean = (mean2(double(MIAData.Data{1,2}(:,:,Frames))) + mean2(double(MIAData.Data{2,2}(:,:,Frames))))/2;
                InfoAll(3).AR = [];
            case 3 %%% Arbitrary region
                %%% Mean intensity of selected pixels [counts]
                Image1 = double(MIAData.Data{1,2}(:,:,Frames));
                Image2 = double(MIAData.Data{2,2}(:,:,Frames));
                InfoAll(3).Mean = (mean(Image1(Use{1} & Use{2})) + mean(Image2(Use{1} & Use{2})))/2;
                %%% Arbitrary region information
                InfoAll(3).AR.Int_Max(1) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(1).String);
                InfoAll(3).AR.Int_Max(2) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(2).String);
                InfoAll(3).AR.Int_Min(1) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(1).String);
                InfoAll(3).AR.Int_Min(2) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(2).String);
                InfoAll(3).AR.Int_Fold_Max = str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Max.String);
                InfoAll(3).AR.Int_Fold_Min = str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Min.String);
                InfoAll(3).AR.Var_Fold_Max = str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Max.String);
                InfoAll(3).AR.Var_Fold_Min = str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Min.String);
                InfoAll(3).AR.Var_Sub=str2double(h.Mia_Image.Settings.ROI_AR_Sub2.String);
                InfoAll(3).AR.Var_SubSub=str2double(h.Mia_Image.Settings.ROI_AR_Sub1.String);
        end
        %%% Mean intensity
        InfoAll(3).Counts = sum(MeanInt);
        DataAll{3,1} = double(MIAData.STICS{2});
        DataAll{3,2} = double(MIAData.STICS_SEM{2});
    end
    %% Creates new filename
    %%% Removes file extension
    switch MIAData.Type
        case {1,2}
            FileName = MIAData.FileName{1}{1}(1:end-4);
    end
    %%% Generates filename
    Current_FileName1=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_ACF1.stcor']);
    Current_FileName2=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_ACF2.stcor']);
    Current_FileName3=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_CCF.stcor']);
    %%% Checks, if file already exists and create new filename
    if  exist(Current_FileName1,'file')  || exist(Current_FileName2,'file') || exist(Current_FileName3,'file')
        k=1;
        %%% Adds 1 to filename
        Current_FileName1=[Current_FileName1(1:end-6) '_' num2str(k) '.stcor'];
        Current_FileName2=[Current_FileName2(1:end-6) '_' num2str(k) '.stcor'];
        Current_FileName3=[Current_FileName3(1:end-6) '_' num2str(k) '.stcor'];
        %%% Increases counter, until no file is found
        while exist(Current_FileName1,'file')  || exist(Current_FileName2,'file') || exist(Current_FileName3,'file')
            k=k+1;
            Current_FileName1=[Current_FileName1(1:end-(6+numel(num2str(k-1)))) num2str(k) '.stcor'];
            Current_FileName2=[Current_FileName2(1:end-(6+numel(num2str(k-1)))) num2str(k) '.stcor'];
            Current_FileName3=[Current_FileName3(1:end-(6+numel(num2str(k-1)))) num2str(k) '.stcor'];
        end
    end
    %%% Saves Auto correlations
    for i=Auto
        Info = InfoAll(i); %#ok<NASGU>
        Data = DataAll(i,:); %#ok<NASGU>
        if i==1
            save(Current_FileName1,'Info','Data');
        else
            save(Current_FileName2,'Info','Data');
        end
    end
    %%% Saves Cross correlations
    if Cross
        Info = InfoAll(3); %#ok<NASGU>
        Data = DataAll(3,:); %#ok<NASGU>
        save(Current_FileName3,'Info','Data');
    end
end

Update_Plots([],[],6,[]);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Peforms rics fit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_RICS_Fit(~,~,mode)
global MIAData
h = guidata(findobj('Tag','Mia'));
h.Mia_Progress_Text.String = 'Fitting correlation';
h.Mia_Progress_Axes.Color=[1 0 0];  
drawnow;

%%% Extracts parameters and data
NotFixed=find(~cell2mat(h.Mia_ICS.Fit_Table.Data(2:2:end,mode)));
Params=cellfun(@str2double,h.Mia_ICS.Fit_Table.Data(1:2:end,mode));
Fit_Params=Params(NotFixed);
YData=h.Plots.Cor(mode,2).ZData;
%YData(round(size(YData,1)/2),:) = YData(round(size(YData,1)/2)+1,:);
Size=str2double(h.Mia_ICS.Size.String);  
if str2double(h.Mia_ICS.Frame.String)==0
    %%% Extracts, what frames to use
    Frames=str2num(h.Mia_ICS.Frames2Use.String);     %#ok<ST2NM>
    %%% Calculate borders
    X(1)=ceil(floor(size(MIAData.Cor{mode,1},1)/2)-Size/2)+1;
    X(2)=ceil(floor(size(MIAData.Cor{mode,1},1)/2)+Size/2);
    Y(1)=ceil(floor(size(MIAData.Cor{mode,1},2)/2)-Size/2)+1;
    Y(2)=ceil(floor(size(MIAData.Cor{mode,1},2)/2)+Size/2);
    %%% calculates SEM
    SEM=std(double(MIAData.Cor{mode,1}(X(1):X(2),Y(1):Y(2),Frames)),0,3)/sqrt(numel(Frames));
else
    SEM=ones(size(YData));
end
if any(any(SEM==0))
    SEM=1;
end

%%%
opts=optimset('Display','off');
%%% Performas fit
[Fitted_Params,~,~,~]=lsqcurvefit(@Fit_RICS,Fit_Params,{Params,NotFixed,Size,SEM(:)},YData(:)./SEM(:),[],[],opts);
%%% Updates parameters and table
Params(NotFixed)=Fitted_Params;
h.Mia_ICS.Fit_Table.Data(1:2:end,mode)=deal(cellfun(@num2str,num2cell(Params),'UniformOutput',false));
%%% Calculates fit function
Calc_RICS_Fit(mode);
%%% Updates correlation plots
Update_Plots([],[],2,mode);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% RICS fit function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [OUT] = Fit_RICS(Fit_Params,Data)

Shift=floor(Data{3}/2)+1;
[X,Y]=meshgrid(1:Data{3},1:Data{3});
X=X(:); Y=Y(:);
SEM=Data{4};

P=Data{1};
P(Data{2})=Fit_Params;

OUT= P(5) + 2.^(-3./2)./P(1).... %%% Amplitude
    .*(1+4*P(2)*10^-12*(abs(X-Shift)*P(7)*10^-6+abs(Y-Shift)*P(8)*10^-3)/(P(3)*10^-6)^2).^(-1)... %%% XY Diffusion
    .*(1+4*P(2)*10^-12*(abs(X-Shift)*P(7)*10^-6+abs(Y-Shift)*P(8)*10^-3)/(P(4)*10^-6)^2).^(-0.5)... %%% Z Diffusion
    .*exp(-(P(6)*10^-9)^2*((X-Shift).^2+(Y-Shift).^2)./((P(3)*10^-6)^2+4*P(2)*10^-12*(abs(X-Shift)*P(7)*10^-6+abs(Y-Shift)*P(8)*10^-3))); %%% Scanning
OUT((Shift-1)*(Data{3}+1)+1)=(OUT((Shift-1)*(Data{3}-1))+OUT(Shift*(Data{3}+1)))/2;
OUT=OUT./SEM;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculates fit function without fitting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
function [OUT] = Calc_RICS_Fit(mode)
global MIAData
h = guidata(findobj('Tag','Mia'));
P=cellfun(@str2double,h.Mia_ICS.Fit_Table.Data(1:2:end,mode));
Size=str2double(h.Mia_ICS.Size.String);

Shift=floor(Size/2)+1;
[X,Y]=meshgrid(1:Size,1:Size);
X=X(:); Y=Y(:);

OUT= P(5) + 2.^(-3./2)./P(1).... %%% Amplitude
    .*(1+4*P(2)*10^-12*(abs(X-Shift)*P(7)*10^-6+abs(Y-Shift)*P(8)*10^-3)/(P(3)*10^-6)^2).^(-1)... %%% XY Diffusion
    .*(1+4*P(2)*10^-12*(abs(X-Shift)*P(7)*10^-6+abs(Y-Shift)*P(8)*10^-3)/(P(4)*10^-6)^2).^(-0.5)... %%% Z Diffusion
    .*exp(-(P(6)*10^-9)^2*((X-Shift).^2+(Y-Shift).^2)./((P(3)*10^-6)^2+4*P(2)*10^-12*(abs(X-Shift)*P(7)*10^-6+abs(Y-Shift)*P(8)*10^-3))); %%% Scanning
OUT((Shift-1)*(Size+1)+1)=(OUT((Shift-1)*(Size-1))+OUT(Shift*(Size+1)))/2;
MIAData.Cor{mode,2} = reshape(OUT,[Size,Size]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Peforms tics fit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_TICS_Fit(~,~)
h = guidata(findobj('Tag','Mia'));
global MIAData
h.Mia_Progress_Text.String = 'Fitting correlation';
h.Mia_Progress_Axes.Color=[1 0 0];  
drawnow;


for i=1:3
    if size(MIAData.TICS.Data,2)>=i && ~isempty(MIAData.TICS.Data{i})
        %%% Extracts parameters and data
        NotFixed=find(~cell2mat(h.Mia_TICS.Fit_Table.Data(2:2:end,i)));
        Params=cellfun(@str2double,h.Mia_TICS.Fit_Table.Data(1:2:end,i));
        Fit_Params=Params(NotFixed);
        XData = h.Plots.TICS(i,1).XData;
        YData = h.Plots.TICS(i,1).YData;
        EData = h.Plots.TICS(i,1).UData;
        
        %%%
        opts=optimset('Display','off');
        %%% Performas fit
        [Fitted_Params,~,~,~] = lsqcurvefit(@Fit_TICS,Fit_Params,{Params,NotFixed,XData,EData},double(YData./EData),[],[],opts);
        %%% Updates parameters and table
        Params(NotFixed) = Fitted_Params;
        h.Mia_TICS.Fit_Table.Data(1:2:end,i) = deal(cellfun(@num2str,num2cell(Params),'UniformOutput',false));
        %%% Calculates fit function
        Calc_TICS_Fit([],[],i);
        %%% Updates correlation plots
    end
end
Update_Plots([],[],5,[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TICS fit function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [OUT] = Fit_TICS(Fit_Params,Data)
P = Data{1};
P(Data{2}) = Fit_Params;
X = Data{3};
SEM = Data{4};

%%%-----------------------------FIT FUNCTION----------------------------%%%
OUT=(1/sqrt(8))*1/P(1).*(1./(1+4*(P(2)*1e-12).*X/(P(3)*1e-6)^2)).*(1./sqrt(1+4*(P(2)*1e-12).*X/(P(4)*1e-6)^2))+P(5);
OUT=OUT./SEM;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculates fit function without fitting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [OUT] = Calc_TICS_Fit(~,~,mode)
h = guidata(findobj('Tag','Mia'));
global MIAData

for i=mode
    if size(MIAData.TICS.Data,2)>=i && ~isempty(MIAData.TICS.Data{i})
        P = cellfun(@str2double,h.Mia_TICS.Fit_Table.Data(1:2:end,i));
        X = logspace(log10(h.Plots.TICS(i,1).XData(1)),log10(h.Plots.TICS(i,1).XData(end)),1000);
        
        OUT=real((1/sqrt(8))*1/P(1).*(1./(1+4*(P(2)*1e-12).*X/(P(3)*1e-6)^2)).*(1./sqrt(1+4*(P(2)*1e-12).*X/(P(4)*1e-6)^2))+P(5));
        
        h.Plots.TICS(i,2).XData = X;
        h.Plots.TICS(i,2).YData = OUT;
        
        h.Plots.TICS(i,1).Visible = 'on';
        h.Plots.TICS(i,2).Visible = 'on';
    else
        h.Plots.TICS(i,1).Visible = 'off';
        h.Plots.TICS(i,2).Visible = 'off';
    end
end
drawnow

function Save_TICS(~,~, data)
global UserValues MIAData
h = guidata(findobj('Tag','Mia'));

for i = 1:3
    if any(MIAData.TICS.Auto==i) || (i==3 && MIAData.TICS.Cross)
        if ~isdir(fullfile(UserValues.File.MIAPath,'Mia'))
            mkdir(fullfile(UserValues.File.MIAPath,'Mia'))
        end
        
        %%% Generates filename
        if h.Mia_Image.Calculations.Save_Name.Value
            if i == 1 %ACF1
                FileName = MIAData.FileName{i}{1}(1:end-4);
            elseif i == 2 %ACF2
                FileName = MIAData.FileName{1}{1}(1:end-4);
            elseif i == 3 %CCF
                FileName = MIAData.FileName{2}{1}(1:end-4);
            end
        else
            [FileName,PathName] = uiputfile(Current_FileName, 'Save correlation as', [UserValues.File.MIAPath,'Mia']);
        end
        if i==1
            Current_FileName = fullfile(UserValues.File.MIAPath,'Mia',[FileName '_ACF1.mcor']);
        elseif i==2
            Current_FileName = fullfile(UserValues.File.MIAPath,'Mia',[FileName '_ACF2.mcor']);
        else
            Current_FileName = fullfile(UserValues.File.MIAPath,'Mia',[FileName '_CCF.mcor']);
        end
        k=0;
        %%% Checks, if file already exists
        if  exist(Current_FileName,'file')
            k=1;
            %%% Adds 1 to filename
            Current_FileName=[Current_FileName(1:end-5) '_' num2str(k) '.mcor'];
            %%% Increases counter, until no file is fount
            while exist(Current_FileName,'file')
                k=k+1;
                Current_FileName=[Current_FileName(1:end-(5+numel(num2str(k-1)))) num2str(k) '.mcor'];
            end
        end
        Header = 'TICS correlation file'; %#ok<NASGU>
        Counts = MIAData.TICS.Counts;
        Valid = data{i}.Valid;
        Cor_Times = data{i}.Cor_Times;
        Cor_Average = data{i}.Cor_Average;
        Cor_SEM = data{i}.Cor_SEM;
        Cor_Array = data{i}.Cor_Array;
        save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
    end
end
%% Get Info structure
Info = struct;
%%% Pixel [us], Line [ms] and Frametime [s]
Info.Times = [str2double(h.Mia_Image.Settings.Image_Pixel.String) str2double(h.Mia_Image.Settings.Image_Line.String) str2double(h.Mia_Image.Settings.Image_Frame.String)];
%%% Pixel size
Info.Size = str2double(h.Mia_Image.Settings.Image_Size.String);
%%% ROI and TOI
Info.Frames = MIAData.TICS.Frames;
From = h.Plots.ROI(1).Position(1:2)+0.5;
To = From+h.Plots.ROI(1).Position(3:4)-1;
Info.ROI = [From To];
%%% Countrate
Info.Counts = MIAData.TICS.Counts;
%%% Correction information
Info.Correction.SubType = h.Mia_Image.Settings.Correction_Subtract.String{h.Mia_Image.Settings.Correction_Subtract.Value};
if h.Mia_Image.Settings.Correction_Subtract.Value == 4
    Info.Correction.SubROI = [str2double(h.Mia_Image.Settings.Correction_Subtract_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Subtract_Frames.String)];
end
Info.Correction.AddType = h.Mia_Image.Settings.Correction_Add.String{h.Mia_Image.Settings.Correction_Add.Value};
if h.Mia_Image.Settings.Correction_Add.Value == 5
    Info.Correction.AddROI = [str2double(h.Mia_Image.Settings.Correction_Add_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Add_Frames.String)];
end
%%% Correlation Type (Arbitrary region == 3)
Info.Type = h.Mia_Image.Settings.ROI_FramesUse.String{h.Mia_Image.Settings.ROI_FramesUse.Value};
switch h.Mia_Image.Settings.ROI_FramesUse.Value
    case {1,2} %%% All/Selected frames
        %%% Mean intensity [counts]
        for i = 1:2
            if any(MIAData.TICS.Auto==i)
                Info.Mean(i) = mean2(double(MIAData.Data{i,2}(:,:,Info.Frames)));
            end
        end
        Info.AR = [];
    case 3 %%% Arbitrary region
        %%% Mean intensity of selected pixels [counts]
        for i = 1:2
            if any(MIAData.TICS.Auto==i)
                Image = double(MIAData.Data{i,2}(:,:,Info.Frames));
                Info.Mean(i) = mean(Image(MIAData.TICS.Use{i}));
            end
        end
        %%% Arbitrary region information
        Info.AR.Int_Max(1) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(1).String);
        Info.AR.Int_Max(2) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(2).String);
        Info.AR.Int_Min(1) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(1).String);
        Info.AR.Int_Min(2) = str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(2).String);
        Info.AR.Int_Fold_Max = str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Max.String);
        Info.AR.Int_Fold_Min = str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Min.String);
        Info.AR.Var_Fold_Max = str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Max.String);
        Info.AR.Var_Fold_Min = str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Min.String);
        Info.AR.Var_Sub=str2double(h.Mia_Image.Settings.ROI_AR_Sub2.String);
        Info.AR.Var_SubSub=str2double(h.Mia_Image.Settings.ROI_AR_Sub1.String);
end
%% Saves info file
FileName = MIAData.FileName{1}{1}(1:end-4);
Current_FileName=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_Info.txt']);
k=0;
%%% Checks, if file already exists
if exist(Current_FileName,'file')
    %%% Increases counter, until no file is fount
    while exist(Current_FileName,'file')
        k=k+1;
        Current_FileName=fullfile(UserValues.File.MIAPath,'Mia',[FileName '_Info_' num2str(k) '.txt']);
    end
end

FID = fopen(Current_FileName,'w');
fprintf(FID,'%s\n','Image Correlation info file');
%%% Pixel\Line\Frame times
fprintf(FID,'%s\t%f\n', 'Pixel time [us]:',Info.Times(1));
fprintf(FID,'%s\t%f\n', 'Line  time [ms]:',Info.Times(2));
fprintf(FID,'%s\t%f\n', 'Frame time [s] :',Info.Times(3));
%%% Pixel size
fprintf(FID,'%s\t%f\n', 'Pixel size [nm]:',Info.Size);
%%% Region of interest
fprintf(FID,'%s\t%u,%u,%u,%u\t%s\n', 'Region used [px]:',Info.ROI, 'X Start, Y Start, X Stop, Y Stop');
%%% Counts per pixel
fprintf(FID,'%s\t%f\t%f\n', 'Mean counts per pixel:',Info.Counts(1),Info.Counts(2));
%%% Frames used
fprintf(FID,['%s\t',repmat('%u\t',[1 numel(Info.Frames)]) '\n'],'Frames Used:',Info.Frames);
%%% Subtraction used
switch h.Mia_Image.Settings.Correction_Subtract.Value
    case 1
        fprintf(FID,'%s\n','Nothing subtracted');
    case 2
        fprintf(FID,'%s\n','Frame mean subtracted');
    case 3
        fprintf(FID,'%s\n','Pixel mean subtracted');
    case 4
        fprintf(FID,'%s\t%u%s\t%u%s\n','Moving average subtracted:', Info.Correction.SubROI(1), ' Pixel', Info.Correction.SubROI(2),' Frames');
end
%%% Addition used
switch h.Mia_Image.Settings.Correction_Subtract.Value
    case 1
        fprintf(FID,'%s\n','Nothing added');
    case 2
        fprintf(FID,'%s\n','Total mean added');
    case 3
        fprintf(FID,'%s\n','Frame mean added');
    case 4
        fprintf(FID,'%s\n','Pixel mean added');
    case 5
        fprintf(FID,'%s\t%u%s%u%s\n','Moving average added:', Info.Correction.SubROI(1), ' Pixel', Info.Correction.SubROI(2),' Frames');
end
%%% Arbitrary region
if h.Mia_Image.Settings.ROI_FramesUse.Value==3
    fprintf(FID,'%s\n','Arbitrary region used:');
    fprintf(FID,'%s\t%f\n','Minimal average intensity [kHz]:',Info.AR.Int_Min(1), '; ',Info.AR.Int_Min(2));
    fprintf(FID,'%s\t%f\n','Maximal average intensity [kHz]:',Info.AR.Int_Max(1), '; ',Info.AR.Int_Max(2));
    fprintf(FID,'%s\t%u,%u\n','Subregions size:',Info.AR.Var_SubSub,Info.AR.Var_Sub);
    fprintf(FID,'%s\t%f,%f\n','Minimal\Maximal intensity deviation:',Info.AR.Int_Fold_Min,Info.AR.Int_Fold_Max);
    fprintf(FID,'%s\t%f,%f\n','Minimal\Maximal variance deviation:',Info.AR.Var_Fold_Min,Info.AR.Var_Fold_Max);
end
fclose(FID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Peforms Gaussian fit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_Gaussian(~,~)
h = guidata(findobj('Tag','Mia'));
global MIAData
h.Mia_Progress_Text.String = 'Fitting Gaussian';
h.Mia_Progress_Axes.Color=[1 0 0];  
drawnow;

for i=1:3

    if size(MIAData.STICS,2)>=i && ~isempty(MIAData.STICS{i})
        MIAData.iMSD{i,1} = zeros(size(MIAData.STICS{i},3),1);
        MIAData.iMSD{i,2} = zeros(size(MIAData.STICS{i},3),2);
        for j=1:size(MIAData.STICS{i},3)
            Fit_Params = [1,5,0];
            
            Size = round(str2double(h.Mia_STICS.Size.String));
            if isempty(Size) || Size<1
                Size = 31;
                h.Mia_STICS.Size.String = '31';
            elseif Size > size(MIAData.STICS{i},1) || Size > size(MIAData.STICS{i},2)
                Size = min([size(MIAData.STICS{i},2), size(MIAData.STICS{i},2)]);
                h.Mia_STICS.Size.String = num2str(Size);
            end
            X(1)=ceil(floor(size(MIAData.STICS{i},1)/2)-Size/2)+1;
            X(2)=ceil(floor(size(MIAData.STICS{i},1)/2)+Size/2);
            Y(1)=ceil(floor(size(MIAData.STICS{i},2)/2)-Size/2)+1;
            Y(2)=ceil(floor(size(MIAData.STICS{i},2)/2)+Size/2);
            YData = MIAData.STICS{i}(X(1):X(2),Y(1):Y(2),j);
            %%% Removes noise point at G(0,0,0)
            if j==1
               YData(floor(Size/2)+1,floor(Size/2)+1) = 0;
            end
            EData = MIAData.STICS_SEM{i}(X(1):X(2),Y(1):Y(2),j);
        
        opts=optimset('Display','off');
        %%% Performas fit        
        [Fitted_Params,~,weighted_residuals,~,~,~,jacobian] = lsqcurvefit(@Fit_Gaussian,Fit_Params,{Size,double(EData),j},double(YData(:)./EData(:)),[],[],opts);

        MIAData.iMSD{i,1}(j,1) = Fitted_Params(2);
        Confidence = nlparci(Fitted_Params,weighted_residuals,'jacobian',jacobian);
        MIAData.iMSD{i,2}(j,:) = Confidence(2,:);
        end
    end
end
Update_Plots([],[],6,[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gaussian Fit function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [OUT] = Fit_Gaussian(Fit_Params,Data)
Shift = floor(Data{1}/2)+1;
[X,Y]=meshgrid(1:Data{1},1:Data{1});
X=X(:); Y=Y(:);
SEM = Data{2};

A = Fit_Params(1);
Omega = Fit_Params(2);
I0 = Fit_Params(3);

OUT = I0+A.*exp(-((X-Shift).^2+(Y-Shift).^2)./(Omega^2));
OUT((Shift-1)*(Data{1}+1)+1) = (OUT((Shift-1)*(Data{1}-1))+OUT(Shift*(Data{1}+1)))/2;
OUT = OUT./SEM(:);
%%% Removes noise point at G(0,0,0)
if Data{3}==1
   OUT(sub2ind(size(Data{2}),Shift,Shift)) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Peforms iMSD fit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_iMSD(~,~)
h = guidata(findobj('Tag','Mia'));
global MIAData
h.Mia_Progress_Text.String = 'Fitting iMSD';
h.Mia_Progress_Axes.Color=[1 0 0];  
drawnow;

for i=1:3
    if size(MIAData.iMSD,1)>=i && ~isempty(MIAData.iMSD{i,1}) && any(MIAData.iMSD{i,1}~=0)
        %%% Extracts parameters and data
        NotFixed = ~cell2mat(h.Mia_STICS.Fit_Table.Data(2:2:end,i));
        Params = cellfun(@str2double,h.Mia_STICS.Fit_Table.Data(1:2:end,i));
        Fit_Params = Params(NotFixed);
        
        XData = h.Plots.STICS(i,1).XData;
        YData = h.Plots.STICS(i,1).YData;
        EData = (h.Plots.STICS(i,1).UData + h.Plots.STICS(i,1).LData)/2; 
        
        opts=optimset('Display','off');
        %%% Performas fit
        [Fitted_Params,~,~,~,~,~,~] = lsqcurvefit(@Fit_iMSD,Fit_Params,{Params,NotFixed,XData,EData},double(YData./EData),[],[],opts);
        %%% Updates parameters and table
        Params(NotFixed) = Fitted_Params;
        h.Mia_STICS.Fit_Table.Data(1:2:end,i) = deal(cellfun(@num2str,num2cell(Params),'UniformOutput',false));
    end
end
Update_Plots([],[],6,[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gaussian Fit function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [OUT] = Fit_iMSD(Fit_Params,Data)
P = Data{1};
P(Data{2}) = Fit_Params;
X = Data{3};
SEM = Data{4};

%%%-----------------------------FIT FUNCTION----------------------------%%%  
OUT=P(1)^2+4*P(2)*(X.^P(3));
OUT=OUT./SEM;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Funtion to calculate correlations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_NB(~,~)
h = guidata(findobj('Tag','Mia'));
global MIAData

h.Mia_Progress_Text.String = 'Calculating N&B';
h.Mia_Progress_Axes.Color=[1 0 0];  
drawnow;

MIAData.NB=[];

%% Determins, for which channels to calculate
if h.Mia_Image.Calculations.NB_Type.Value==3
    Auto=1:2; Cross=1;
    channel=1:3;
else
    Auto=h.Mia_Image.Calculations.NB_Type.Value; Cross=0;
    channel=floor(Auto*1.5);
end

%% Calculates N&B
for i=Auto
    %%% Apply Dead time correction
    MIAData.NB.DTCorr_Img{floor(i*1.5)} = (double(MIAData.Data{i,2}))./(1-double(MIAData.Data{i,2}).*(str2double(h.Mia_Image.Calculations.NB_Detector_Deadtime.String)/(str2double(h.Mia_Image.Settings.Image_Pixel.String)*1000)));
    %%% Limit for PCH
    MaxPhotons=ceil(max(max(max(MIAData.NB.DTCorr_Img{floor(i*1.5)}))));
    %%% Calculaces PCH, mean intensity, standard deviation for each pixel
    MIAData.NB.PCH{floor(i*1.5)}=histc(MIAData.NB.DTCorr_Img{floor(i*1.5)}(:),0:MaxPhotons); 
    MIAData.NB.Int{floor(i*1.5)}=nanmean(MIAData.NB.DTCorr_Img{floor(i*1.5)},3);
    MIAData.NB.Std{floor(i*1.5)}=nanstd(MIAData.NB.DTCorr_Img{floor(i*1.5)},0,3);
    %%% Applies spacial filter to intensity and standard deviation
    if str2double(h.Mia_Image.Calculations.NB_Average_Radius.String)<=1
        h.Mia_Image.Calculations.NB_Average.Value=1;
    end
    %%% Determinesspatial filter
    switch h.Mia_Image.Calculations.NB_Average.Value
        case 1 %%% Do nothing
            Filter = fspecial('average',1);
        case 2 %%% Moving average
            Filter = fspecial('average',round(str2double(h.Mia_Image.Calculations.NB_Average_Radius.String)));
        case 3 %%% Disc average
            Filter = fspecial('disk',str2double(h.Mia_Image.Calculations.NB_Average_Radius.String)-1);
        case 4 %%% Gaussian average
            Filter = fspecial('gaussian',2*str2double(h.Mia_Image.Calculations.NB_Average_Radius.String),str2double(h.Mia_Image.Calculations.NB_Average_Radius.String)/2);
    end
    %%% Applies filter
    MIAData.NB.Int{floor(i*1.5)}=imfilter(MIAData.NB.Int{floor(i*1.5)},Filter,'symmetric');
    MIAData.NB.Std{floor(i*1.5)}=imfilter(MIAData.NB.Std{floor(i*1.5)},Filter,'symmetric');
    %%% Calculates number and brightness for each pixel
    %MIAData.NB.Num{floor(i*1.5)}=MIAData.NB.Int{floor(i*1.5)}.^2./(MIAData.NB.Std{floor(i*1.5)}.^2);
    %MIAData.NB.Eps{floor(i*1.5)}=MIAData.NB.Std{floor(i*1.5)}.^2./MIAData.NB.Int{floor(i*1.5)};
    MIAData.NB.Num{floor(i*1.5)}=MIAData.NB.Int{floor(i*1.5)}.^2./(MIAData.NB.Std{floor(i*1.5)}.^2-MIAData.NB.Int{floor(i*1.5)})/sqrt(8);
    MIAData.NB.Eps{floor(i*1.5)}=(MIAData.NB.Std{floor(i*1.5)}.^2-MIAData.NB.Int{floor(i*1.5)})./MIAData.NB.Int{floor(i*1.5)}*sqrt(8);
    if h.Mia_Image.Calculations.NB_Median.Value
        MIAData.NB.Num{floor(i*1.5)}=medfilt2(MIAData.NB.Num{floor(i*1.5)},[3 3]);
        MIAData.NB.Eps{floor(i*1.5)}=medfilt2(MIAData.NB.Eps{floor(i*1.5)},[3 3]);
    end
end

%% Calculates crossN&B
if Cross
    MaxPhotons=ceil(max(max(max(MIAData.Data{1,2}+MIAData.Data{2,2}))));
    %%% Calculaces PCH, mean intensity, standard deviation for each pixel
    MIAData.NB.PCH{2}=histc(MIAData.Data{1,2}(:)+MIAData.Data{2,2}(:),0:MaxPhotons); %%% PCH of sum of channels
    MIAData.NB.Int{2}=sqrt(MIAData.NB.Int{1}.*MIAData.NB.Int{3}); %%% sqrt of product to be able to calculate N&B
    MIAData.NB.Std{2}=sqrt(mean((MIAData.Data{1,2}-repmat(mean(MIAData.Data{1,2},3),[1 1,size(MIAData.Data{1,2},3)]))...
                                 .*(MIAData.Data{2,2}-repmat(mean(MIAData.Data{2,2},3),[1 1,size(MIAData.Data{2,2},3)])),3)); %%% sqrt of co-variance
    %%% Applies spacial filter to intensity and standard deviation
    if str2double(h.Mia_Image.Calculations.NB_Average_Radius.String)<=1
        h.Mia_Image.Calculations.NB_Average.Value=1;
    end
    %%% Determinesspatial filter
    switch h.Mia_Image.Calculations.NB_Average.Value
        case 1 %%% Do nothing
            Filter = fspecial('average',1);
        case 2 %%% Moving average
            Filter = fspecial('average',round(str2double(h.Mia_Image.Calculations.NB_Average_Radius.String)));
        case 3 %%% Disc average
            Filter = fspecial('disk',str2double(h.Mia_Image.Calculations.NB_Average_Radius.String)-1);
        case 4 %%% Gaussian average
            Filter = fspecial('gaussian',2*str2double(h.Mia_Image.Calculations.NB_Average_Radius.String),str2double(h.Mia_Image.Calculations.NB_Average_Radius.String)/2);
    end
    %%% Applies filter
    MIAData.NB.Int{floor(2)}=imfilter(MIAData.NB.Int{floor(2)},Filter,'symmetric');
    MIAData.NB.Std{floor(2)}=imfilter(MIAData.NB.Std{floor(2)},Filter,'symmetric');
    %%% Calculates number and brightness for each pixel
    MIAData.NB.Num{2}=real(MIAData.NB.Int{2}.^2./(MIAData.NB.Std{2}.^2));
    MIAData.NB.Eps{2}=real((MIAData.NB.Std{2}.^2)./MIAData.NB.Int{2}); 
end

i=channel(1);

%% Uses first active channel to initiate standard threshold parameters
%%% Uses actual min/max of mean+-3sigma for intensity
h.Mia_NB.Image.Hist(1,1).String=num2str(max([min(MIAData.NB.Int{i}(:)), mean2(MIAData.NB.Int{i})-3*mean2(MIAData.NB.Std{i})])/str2double(h.Mia_NB.Image.Pixel.String)*10^3);
h.Mia_NB.Image.Hist(2,1).String=num2str(min([max(MIAData.NB.Int{i}(:)), mean2(MIAData.NB.Int{i})+3*mean2(MIAData.NB.Std{i})])/str2double(h.Mia_NB.Image.Pixel.String)*10^3);
h.Mia_NB.Image.Hist(3,1).String='50';

%%%  Removes 5% of top and bottom values to remove outliers 
NoOutliers=sort(MIAData.NB.Num{i}(:));
NoOutliers=NoOutliers(~isnan(NoOutliers));
NoOutliers=NoOutliers(round(0.05*numel(NoOutliers)):round(0.95*numel(NoOutliers)));
%%% mena+-3sigma for number
h.Mia_NB.Image.Hist(1,2).String=num2str(mean(NoOutliers)-3*std(NoOutliers));
h.Mia_NB.Image.Hist(2,2).String=num2str(mean(NoOutliers)+3*std(NoOutliers));
h.Mia_NB.Image.Hist(3,2).String='50';

%%%  Removes 5% of top and bottom values to remove outliers 
NoOutliers=sort(MIAData.NB.Eps{i}(:));
NoOutliers=NoOutliers(~isnan(NoOutliers));
NoOutliers=NoOutliers(round(0.05*numel(NoOutliers)):round(0.95*numel(NoOutliers)));
%%% mena+-3sigma for brightness
h.Mia_NB.Image.Hist(1,3).String=num2str((mean(NoOutliers)-3*std(NoOutliers))/str2double(h.Mia_NB.Image.Pixel.String)*10^3);
h.Mia_NB.Image.Hist(2,3).String=num2str((mean(NoOutliers)+3*std(NoOutliers))/str2double(h.Mia_NB.Image.Pixel.String)*10^3);
h.Mia_NB.Image.Hist(3,3).String='50';

%%% Updates N&B plots
Update_Plots([],[],3,channel);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes 2D histogram background color %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NB_2DHist_BG(~,~)
h = guidata(findobj('Tag','Mia'));
h.Mia_NB.Hist2D(3).BackgroundColor=1-h.Mia_NB.Hist2D(3).BackgroundColor;
h.Mia_NB.Hist2D(3).ForegroundColor=1-h.Mia_NB.Hist2D(3).ForegroundColor;
Update_Plots([],[],3,1:3)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Export ROI as Binary Mask %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export_ROI(~,~,mode)
global MIAData UserValues
h = guidata(findobj('Tag','Mia'));
ch = h.Mia_NB.Image.Channel.Value;

ROI=[str2num(h.Mia_Image.Settings.ROI_SizeX.String)...
    str2num(h.Mia_Image.Settings.ROI_SizeY.String)...
    str2num(h.Mia_Image.Settings.ROI_PosX.String)...
    str2num(h.Mia_Image.Settings.ROI_PosY.String)];
switch mode
    case 1
        Mask=MIAData.NB.Use;
end

%Dialog for saving file
[FileName,Path] = uiputfile('*.mat', 'Save ROI as...', UserValues.File.MIAPath);
if ~(isequal(FileName,0) || isequal(Path,0))
   f = strcat(Path,FileName);
   save(f,'ch', 'ROI','Mask');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Import ROI exported with Export_ROI function%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Import_ROI(~,~)
global MIAData UserValues
h = guidata(findobj('Tag','Mia'));
% put UI to arbitrary ROI and set to values that will not apply it
h.Mia_Image.Settings.ROI_FramesUse.Value = 3;
h.Mia_Image.Settings.ROI_AR_Int_Fold_Max.String = 1000;
h.Mia_Image.Settings.ROI_AR_Int_Fold_Min.String = 0.001;
h.Mia_Image.Settings.ROI_AR_Int_Max(1).String = 10000;
h.Mia_Image.Settings.ROI_AR_Int_Max(2).String = 10000;
h.Mia_Image.Settings.ROI_AR_Int_Min(1).String = 0;
h.Mia_Image.Settings.ROI_AR_Int_Min(2).String = 0;
h.Mia_Image.Settings.ROI_AR_Same.Value = 1;
h.Mia_Image.Settings.ROI_AR_Sub1.String = 5;
h.Mia_Image.Settings.ROI_AR_Sub2.String = 10;
h.Mia_Image.Settings.ROI_AR_Var_Fold_Max.String = 1000;
h.Mia_Image.Settings.ROI_AR_Var_Fold_Min.String = 0.001;
h.Mia_Image.Settings.ROI_AR_Spatial_Int.Value = 0;
h.Mia_Image.Settings.ROI_AR_median.Value = 0;

MIA_Various([],[],3);

[FileName,Path] = uigetfile('*.mat', 'Load ROI', UserValues.File.MIAPath);
if ~(isequal(FileName,0) || isequal(Path,0))
    info = load(strcat(Path,FileName));
    if isfield(info, 'ROI')
        %Set ROI size and position to the one exported from N&B
        h.Mia_Image.Settings.ROI_SizeX.String = num2str(info.ROI(1,1));
        h.Mia_Image.Settings.ROI_SizeY.String = num2str(info.ROI(1,2));
        h.Mia_Image.Settings.ROI_PosX.String = num2str(info.ROI(1,3));
        h.Mia_Image.Settings.ROI_PosY.String = num2str(info.ROI(1,4));
    end
    %Update ROI position
    Mia_ROI([],[],1)
    if ~isfield(info, 'Mask')
        a = struct2cell(info);
        info.Mask = a{1};
        info.ch = 1;
    end
    %Merge loaded ROI with existing arbitrary region
    if prod(size(MIAData.MS{1}) == size(info.Mask))&&(info.ch==1)
        MIAData.MS{1} = MIAData.MS{1} & info.Mask;
        MIAData.MS{2} = MIAData.MS{1};
    end
    if prod(size(MIAData.MS{2}) == size(info.Mask))&&(info.ch==3)     
        MIAData.MS{2} = MIAData.MS{2} & info.Mask;
    end
    %Update images
    Mia_Correct([],[],0);
    % set the ROI popupmenu to Arbitrary
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Collection of small callbacks and functions %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1:Toggle logical in UserData of UI
%%% 2:Updates additional parameters plots
%%% 3:Hide\Show Arbitrary region controls
%%% 4:Save TICS manual selection
%%% 5:Display Count rate axes in kHz or a.u.

function MIA_Various(Obj,~,mode)
h = guidata(findobj('Tag','Mia'));
global MIAData UserValues
for i=mode
    switch i
        case 1 %%% Toggle logical in UserData of UI
            Obj.UserData = ~Obj.UserData;
        case 2 %%% Updates additional parameters plots
            Update_Plots([],[],4,[1 2]);
        case 3 %%% Hide\Show Arbitrary region controls
            switch h.Mia_Image.Settings.ROI_FramesUse.Value
                case {1,2} %%% Hide arbitrary region controls
                    MIAData.AR = [];
                    h.Mia_Image.Settings.ROI_AR_Int_Fold_Max.Visible = 'off';
                    h.Mia_Image.Settings.ROI_AR_Int_Fold_Min.Visible = 'off';
                    h.Mia_Image.Settings.ROI_AR_Int_Max(1).Visible = 'off';
                    h.Mia_Image.Settings.ROI_AR_Int_Max(2).Visible = 'off';
                    h.Mia_Image.Settings.ROI_AR_Int_Min(1).Visible = 'off';
                    h.Mia_Image.Settings.ROI_AR_Int_Min(2).Visible = 'off';
                    h.Mia_Image.Settings.ROI_AR_Same.Visible = 'off';
                    h.Mia_Image.Settings.ROI_AR_Sub1.Visible = 'off';
                    h.Mia_Image.Settings.ROI_AR_Sub2.Visible = 'off';
                    h.Mia_Image.Settings.ROI_AR_Var_Fold_Max.Visible = 'off';
                    h.Mia_Image.Settings.ROI_AR_Var_Fold_Min.Visible = 'off';
                    h.Mia_Image.Settings.ROI_AR_Spatial_Int.Visible = 'off';
                    h.Mia_Image.Settings.ROI_AR_median.Visible = 'off';
                    for j=1:numel(h.Mia_Image.Settings.ROI_AR_Text)
                        h.Mia_Image.Settings.ROI_AR_Text{j}.Visible = 'off';
                    end
                    %                     if size(MIAData.Data,1)>0
                    %                         MIAData.AR{1} = true(size(MIAData.Data{1,2}));
                    %                     end
                    %                     if size(MIAData.Data,1)>1
                    %                         MIAData.AR{2} = true(size(MIAData.Data{2,2}));
                    %                     end
                    h.Plots.Image(1,2).UIContextMenu = [];
                    h.Plots.Image(2,2).UIContextMenu = [];
                    Update_Plots([],[],1,1:size(MIAData.Data,1));
                case 3 %%% Show arbitrary region controls
                    h.Mia_Image.Settings.ROI_AR_Int_Fold_Max.Visible = 'on';
                    h.Mia_Image.Settings.ROI_AR_Int_Fold_Min.Visible = 'on';
                    h.Mia_Image.Settings.ROI_AR_Int_Max(1).Visible = 'on';
                    h.Mia_Image.Settings.ROI_AR_Int_Max(2).Visible = 'on';
                    h.Mia_Image.Settings.ROI_AR_Int_Min(1).Visible = 'on';
                    h.Mia_Image.Settings.ROI_AR_Int_Min(2).Visible = 'on';
                    h.Mia_Image.Settings.ROI_AR_Same.Visible = 'on';
                    h.Mia_Image.Settings.ROI_AR_Sub1.Visible = 'on';
                    h.Mia_Image.Settings.ROI_AR_Sub2.Visible = 'on';
                    h.Mia_Image.Settings.ROI_AR_Var_Fold_Max.Visible = 'on';
                    h.Mia_Image.Settings.ROI_AR_Var_Fold_Min.Visible = 'on';
                    h.Mia_Image.Settings.ROI_AR_Spatial_Int.Visible = 'on';
                    h.Mia_Image.Settings.ROI_AR_median.Visible = 'on';
                    for j=1:numel(h.Mia_Image.Settings.ROI_AR_Text)
                        h.Mia_Image.Settings.ROI_AR_Text{j}.Visible = 'on';
                    end
                    h.Plots.Image(1,2).UIContextMenu = h.Mia_Image.Menu;
                    h.Plots.Image(2,2).UIContextMenu = h.Mia_Image.Menu;
                    Mia_Correct([],[],1);
            end
        case 4
            %% Set the background to 0
            tmp(1) = str2double(h.Mia_Image.Settings.Background(1).String);
            tmp(2) = str2double(h.Mia_Image.Settings.Background(2).String);
            h.Mia_Image.Settings.Background(1).String = '0';
            h.Mia_Image.Settings.Background(2).String = '0';
            Mia_Correct([],[],1)
            %% Get the background from the current ROI
            h.Mia_Image.Settings.Background(1).String = num2str(tmp(1));
            h.Mia_Image.Settings.Background(2).String = num2str(tmp(2));
            if size(MIAData.Data,1)==1 && size(MIAData.Data,2)==2
                h.Mia_Image.Settings.Background(1).String = num2str(mean2(MIAData.Data{1,2}));
                h.Mia_Image.Settings.Background(2).String = '0';
            elseif size(MIAData.Data,1)==2 && size(MIAData.Data,2)==2
                h.Mia_Image.Settings.Background(1).String = num2str(mean2(MIAData.Data{1,2}));
                h.Mia_Image.Settings.Background(2).String = num2str(mean2(MIAData.Data{2,2}));
            else
                h.Mia_Image.Settings.Background(1).String = '0';
                h.Mia_Image.Settings.Background(2).String = '0';
            end
            Mia_Correct([],[],1)
            
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to update UserValues %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Save_MIA_UserValues(h)
global UserValues

Save = false;
%%% Colormaps
if any(UserValues.MIA.ColorMap_Main ~= [h.Mia_Image.Settings.Channel_Colormap(1).Value; h.Mia_Image.Settings.Channel_Colormap(2).Value])
    UserValues.MIA.ColorMap_Main = [h.Mia_Image.Settings.Channel_Colormap(1).Value; h.Mia_Image.Settings.Channel_Colormap(2).Value];
    Save = true;
end
if any(UserValues.MIA.CustomColor ~= [h.Mia_Image.Settings.Channel_Colormap(1).UserData; h.Mia_Image.Settings.Channel_Colormap(2).UserData])
    UserValues.MIA.CustomColor = [h.Mia_Image.Settings.Channel_Colormap(1).UserData; h.Mia_Image.Settings.Channel_Colormap(2).UserData];
    Save = true;
end
%%% Image correction setting
if any(UserValues.MIA.Correct_Type ~= [h.Mia_Image.Settings.Correction_Subtract.Value h.Mia_Image.Settings.Correction_Add.Value])
    UserValues.MIA.Correct_Type = [h.Mia_Image.Settings.Correction_Subtract.Value h.Mia_Image.Settings.Correction_Add.Value];
    Save = true;
end
if any(UserValues.MIA.Correct_Sub_Values ~= [str2double(h.Mia_Image.Settings.Correction_Subtract_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Subtract_Frames.String)])
    UserValues.MIA.Correct_Sub_Values = [str2double(h.Mia_Image.Settings.Correction_Subtract_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Subtract_Frames.String)];
    Save = true;
end
if any(UserValues.MIA.Correct_Add_Values ~= [str2double(h.Mia_Image.Settings.Correction_Add_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Add_Frames.String)])
    UserValues.MIA.Correct_Add_Values = [str2double(h.Mia_Image.Settings.Correction_Add_Pixel.String) str2double(h.Mia_Image.Settings.Correction_Add_Frames.String)];
    Save = true;
end
%%% Arbitrary Region settings
if any(UserValues.MIA.AR_Int ~= [str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(1).String),...
                             str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(2).String),...
                             str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(1).String),...
                             str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(2).String),])
    UserValues.MIA.AR_Int = [str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(1).String),...
                             str2double(h.Mia_Image.Settings.ROI_AR_Int_Min(2).String),...
                             str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(1).String),...
                             str2double(h.Mia_Image.Settings.ROI_AR_Int_Max(2).String)];
    Save = true;
end
if any(UserValues.MIA.AR_Region ~= [str2double(h.Mia_Image.Settings.ROI_AR_Sub1.String) str2double(h.Mia_Image.Settings.ROI_AR_Sub2.String)])
    UserValues.MIA.AR_Region = [str2double(h.Mia_Image.Settings.ROI_AR_Sub1.String) str2double(h.Mia_Image.Settings.ROI_AR_Sub2.String)];
    Save = true;
end
if any(UserValues.MIA.AR_Int_Fold ~= [str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Min.String) str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Max.String)])
    UserValues.MIA.AR_Int_Fold = [str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Min.String) str2double(h.Mia_Image.Settings.ROI_AR_Int_Fold_Max.String)];
    Save = true;
end
if any(UserValues.MIA.AR_Var_Fold ~= [str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Min.String) str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Max.String)])
    UserValues.MIA.AR_Var_Fold = [str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Min.String) str2double(h.Mia_Image.Settings.ROI_AR_Var_Fold_Max.String)];
    Save = true;
end
if Save
    LSUserValues(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for exporting various things %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mia_Export(obj,~)
global UserValues
h = guidata(findobj('Tag','Mia'));

if ~strcmp(h.Mia.SelectionType,'extend') && ~strcmp(h.Mia.SelectionType,'open')
   return; 
end
[FileName,PathName] = uiputfile({'*.tif'}, 'Save TIFF as', UserValues.File.ExportPath);
if any(FileName~=0)
    UserValues.File.ExportPath=PathName;
    LSUserValues(1)
    Image=single(obj.CData);
    if size(Image,3)==3       
        Image=Image/max(Image(:))*255;
    else
        if h.Mia_Image.Settings.AutoScale.Value == 3
            % manual scaling values for the respective imaging channel
            mini = str2num(h.Mia_Image.Settings.Scale(str2num(obj.Parent.Tag(end)),1).String);
            maxi = str2num(h.Mia_Image.Settings.Scale(str2num(obj.Parent.Tag(end)),2).String);
            Image(Image<mini)=mini;
            Image(Image>maxi)=maxi;
        end
        
        cmap=colormap(obj.Parent);
        r=cmap(:,1)*255; g=cmap(:,2)*255; b=cmap(:,3)*255;
        CData = round((Image-min(Image(:)))/(max(Image(:))-min(Image(:)))*(size(cmap,1)-1))+1;
        Image(:,:,1) = reshape(r(CData),size(CData));
        Image(:,:,2) = reshape(g(CData),size(CData));
        Image(:,:,3) = reshape(b(CData),size(CData));
        
        if numel(obj.AlphaData)>1 %%% When transparency is used to show unselected regions
            Image(:,:,1) = Image(:,:,1).*obj.AlphaData + 255*(1-obj.AlphaData)*obj.Parent.Color(1);
            Image(:,:,2) = Image(:,:,2).*obj.AlphaData + 255*(1-obj.AlphaData)*obj.Parent.Color(2);
            Image(:,:,3) = Image(:,:,3).*obj.AlphaData + 255*(1-obj.AlphaData)*obj.Parent.Color(3);
        end
    end
    
    imwrite(uint8(Image),fullfile(PathName,FileName));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for exporting various things %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MIA_CustomFileType(obj,~,mode)
h = guidata(findobj('Tag','Mia'));
global UserValues
switch mode
    case 1 %%% MIA is initialized or selection is changed
        
        %%% Clears previous custom file info
        for i=numel(obj.UserData{3}):-1:1
            %%% Deletes custom settings UIs
            if isvalid(obj.UserData{3}(i))
                delete(obj.UserData{3}(i));
            end
        end
        obj.UserData = {[],[],[]};
        
        %%% Updates UserValues
        UserValues.File.MIA_Custom_Filetype = obj.String(obj.Value);
        LSUserValues(1);
        
        %%% Stops execution, if no custom file type was selected
        if obj.Value == 1
            return;
        end
        
        %%% Retrieves the function handle of the custom filetype
        Function = str2func(obj.String{obj.Value});
        %%% Tells function to create settings UI
        %%% Out: cell array containing:
        %%% 1: File extension
        %%% 2: File description
        %%% 3: Settings object handles
        %%% 4: Function handle
        Out = Function(1);
        Out{4} = Function;
        %%% Stores custom filetype info
        if isempty(h)
            obj.UserData = Out;
        else
            obj.UserData = Out;
            h.Mia_Image.Settings.Custom = Out{3};
            guidata(h.Mia,h);
        end
       
    case 2 %%% New data is loaded
        %%% Stops execution for no selected custom filetype
        if h.Mia_Image.Settings.FileType.Value == 1 
           return; 
        end
        %%% Gets function handle
        Function = h.Mia_Image.Settings.FileType.UserData{4};
        %%% Executed data loading
        Function(2);
        
        
        Progress(1);
        
        %%% Updates plots
        Mia_ROI([],[],1)


end

function Do_FRET(~,~)
% Function for calculating intensity based FRET
global MIAData
h = guidata(findobj('Tag','Mia'));

% what is plotted in the count rate tab solid lines,
% i.e. the AROI pixels
donor = h.Plots.Int(1,2).YData;
acceptor = h.Plots.Int(2,2).YData;

%go to a post
DIm = medfilt2(mean(MIAData.Data{1,2}(:,:,10:50),3),[3,3]);
AIm = medfilt2(mean(MIAData.Data{2,2}(:,:,10:50),3),[3,3]);
DIm(DIm<0)=0;
AIm(AIm<0)=0;
ar  = MIAData.AR{1,2};
DIm(~ar)=0;
ar  = MIAData.AR{2,2};
AIm(~ar)=0;
% range over which the normalization is calculated
normrange = eval(h.Mia_Image.Calculations.FRET_norm.String);

method = h.Mia_Image.Calculations.FRET_Type.Value;
if method == 1
    normFactor = mean(acceptor(normrange)./donor(normrange));
elseif method == 2
    normFactor = 1;
else 
    return
end

frametime = str2double(h.Mia_NB.Image.Frame.String);
AoverD = (acceptor./donor)./normFactor;
time = (0:(numel(donor)-1))*frametime;
figure
hold on 
plot(time, AoverD);
xlabel('time [s]');
ylabel('normalized A/D');
hold off

f = figure;
im=axes(f);
AoverDim = medfilt2(AIm./DIm./normFactor,[5,5]);
imagesc(im, flipud(AoverDim));
axis equal
im.XLim= [0,size(AoverDim,2)];
im.YLim= [0,size(AoverDim,1)];
colormap(im, jet);
colorbar(im)



function Do_Coloc(~,~)
% Function for calculating intensity based FRET
global MIAData
h = guidata(findobj('Tag','Mia'));

%if the 'get background from ROI' button on the ROI tab was pushed, or if a
%background count rate was entered in the corresponding edit boxes, images
%are background corrected, and thus the Pearson's calculation also.

if size(MIAData.Data,1) > 1
    switch h.Mia_Image.Calculations.Coloc_Type.Value
        case 1 %Pearson's correlation coefficient
            % Calculate a Pearson's correlation coefficient for the corrected images within the AROI           
            Image = h.Plots.Image(1,2).CData; % channel 1 corrected image
            if iscell(MIAData.AR)
                AROI = MIAData.AR{1,2}; %for now top right AROI
            else
                AROI = true(size(Image));
            end
            Image = Image(AROI); %linear array of only the included pixels
            Image2 = h.Plots.Image(2,2).CData; % channel 2 corrected image
            Image2 = Image2(AROI); %linear array of only the included pixels
            if ~h.Mia_Image.Calculations.Coloc_weighting.Value
                %% Calculations without intensity weighting
                %% Mean Pearson's coefficient
                mean_1 = mean2(Image);  % the mean intensity of image1 in the ROI
                std_1 = std2(Image);
                mean_2 = mean2(Image2);
                std_2 = std2(Image2);
                ImageP = Image.*Image2;
                n = numel(Image); %number of included pixels
                Pearson = (sum(ImageP) - n.*mean_1.*mean_2)/((n-1).*std_1.*std_2);
                h.Mia_Image.Calculations.Coloc_Pearsons.String = ['mean Pearson`s: ',num2str(Pearson)];
                
                %% Image of the Pearson's coefficeint
                % to be developed
                % spatially average the image via gaussian filtering
                %             stdeviation = str2double(h.Mia_Image.Calculations.Coloc_avg.String);
                %             Image = imgaussfilt(Image,stdeviation,'Padding','symmetric');
                %             Image2 = imgaussfilt(Image2,stdeviation,'Padding','symmetric');
                
                %% Pearson's coefficient vs. intensity G or R
                bins = linspace(min(min(Image),min(Image2)),max(max(Image),max(Image2)),50);
                for i = 1:(numel(bins)-1)
                    %green
                    im =   Image(Image>=bins(i) & Image<bins(i+1));
                    im2 = Image2(Image>=bins(i) & Image<bins(i+1));
                    mean_1 = mean(im);  % the mean intensity of image1 in the ROI
                    std_1 = std(im);
                    mean_2 = mean(im2);
                    std_2 = std(im2);
                    ImageP = im.*im2;
                    n = numel(im); %number of included pixels
                    IntG(i) = mean(bins(i:i+1));
                    ccG(i) = (sum(ImageP) - n.*mean_1.*mean_2)/((n-1).*std_1.*std_2);
                    ErrorG(i) = sqrt(ccG(i))/sqrt(n);
                    
                    %red
                    im =   Image(Image2>=bins(i) & Image2<bins(i+1));
                    im2 = Image2(Image2>=bins(i) & Image2<bins(i+1));
                    mean_1 = mean(im);  % the mean intensity of image1 in the ROI
                    std_1 = std(im);
                    mean_2 = mean(im2);
                    std_2 = std(im2);
                    ImageP = im.*im2;
                    n = numel(im); %number of included pixels
                    IntR(i) = mean(bins(i:i+1));
                    ccR(i) = (sum(ImageP) - n.*mean_1.*mean_2)/((n-1).*std_1.*std_2);
                    ErrorR(i) = sqrt(ccR(i))/sqrt(n);
                end
                %% Pearson's coefficient vs. G/R
                GoverR = Image./Image2;
                bins = linspace(min(GoverR),max(GoverR),50);
                for i = 1:(numel(bins)-1)
                    im =   Image(GoverR>=bins(i) & GoverR<bins(i+1));
                    im2 = Image2(GoverR>=bins(i) & GoverR<bins(i+1));
                    mean_1 = mean(im);  % the mean intensity of image1 in the ROI
                    std_1 = std(im);
                    mean_2 = mean(im2);
                    std_2 = std(im2);
                    ImageP = im.*im2;
                    n = numel(im); %number of included pixels
                    GR(i) = mean(bins(i:i+1));
                    ccGR(i) = (sum(ImageP) - n.*mean_1.*mean_2)/((n-1).*std_1.*std_2);
                    ErrorGR(i) = sqrt(ccGR(i))/sqrt(n);
                end
            else
                %plak hier de corresponderende berekening als wél intensity weighting wordt gedaan
            end
            %% plotting everything
            f = figure;
            ax1 = axes(f);
            errorbar(ax1,IntG,ccG,ErrorG,'g');
            hold on
            errorbar(ax1,IntR,ccR,ErrorR,'r');
            xlabel(ax1,'Intensity (a.u.)');
            ylabel(ax1,'Correlation coefficient');
            ax1.YLim = [-0.05,1.05];
            ax2 = axes('Position',ax1.Position,'Color','none');
            errorbar(ax2, GR,ccGR,ErrorGR, 'Color','k');
            ax2.Color = 'none';
            ax2.XAxisLocation = 'top';
            ax2.YAxisLocation = 'right';
            ax2.XLim = [0,ax2.XLim(2)];
            ax2.YLim = [-0.05,1.05];
            xlabel(ax2, 'Intensity ratio G/R');
            
            %     case 2 %Manders
            %     case 3 %Costes
        case 4 %Van Steensel
            Do_2D_XCor([],[],2)
            %     case 5 %Li
            %     case 6 %object based (particle localization)
        otherwise
            msgbox('not implemented yet')
            h.Mia_Image.Calculations.Coloc_Type.Value = 1;
    end
    

    
else
    msgbox('load 2-color data!')
end

