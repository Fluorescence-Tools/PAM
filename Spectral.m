function Spectral
global UserValues SpectralData
h.SpectralImage = findobj('Tag','SpectralImage');

addpath(genpath(['.' filesep 'bfmatlab']));
addpath(genpath(['.' filesep 'functions']));

if ~isempty(h.SpectralImage) % Creates new figure, if none exists
    figure(h.SpectralImage);
    return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Disables uitabgroup warning
warning('off','MATLAB:uitabgroup:OldVersion');
%%% Loads user profile
LSUserValues(0);
%%% To save typing
Look=UserValues.Look;
%%% Generates the Pam figure
h.SpectralImage = figure(...
    'Units','normalized',...
    'Tag','SpectralImage',...
    'Name','Spectral Imaging',...
    'NumberTitle','off',...
    'Menu','none',...
    'defaultUicontrolFontName',Look.Font,...
    'defaultAxesFontName',Look.Font,...
    'defaultTextFontName',Look.Font,...
    'defaultAxesYColor',Look.Fore,...
    'Toolbar','figure',...
    'UserData',[],...
    'BusyAction','cancel',...
    'WindowButtonUpFcn',@Stop_All,...
    'WindowScrollWheelFcn',{@Phasor_Move,3,[],[]},...
    'KeyPressFcn',{@Phasor_Key,1},...
    'OuterPosition',[0.01 0.1 0.98 0.9],...
    'CloseRequestFcn',@Close_Filter,...
    'Visible','on');
%%% Sets background of axes and other things
whitebg(Look.Fore);
%%% Changes Pam background; must be called after whitebg
h.SpectralImage.Color=Look.Back;
%%% Remove unneeded items from toolbar
toolbar = findall(h.SpectralImage,'Type','uitoolbar');
toolbar_items = findall(toolbar);
delete(toolbar_items([2:7 9 13:17]));

%%% Loading menues
h.Load = uimenu(...
    'Parent',h.SpectralImage,...
    'Label','Load...');

h.Load_Data = uimenu(...
    'Parent',h.Load,...
    'Label','data directly',...
    'Callback',{@Load_Data,1});

h.Load_Database = uimenu(...
    'Parent',h.Load,...
    'Label','data to database',...
    'Callback',{@Load_Data,2});

h.Load_Database = uimenu(...
    'Parent',h.Load,...
    'Label','species data',...
    'Callback',{@Load_Data,4});

h.Text = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Progressbar and file names %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Panel for progressbar
h.Spectral_Progress_Panel = uibuttongroup(...
    'Parent',h.SpectralImage,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.005 0.965 0.99 0.03]);
%%% Axes for progressbar
h.Spectral_Progress_Axes = axes(...
    'Parent',h.Spectral_Progress_Panel,...
    'Units','normalized',...
    'Color',Look.Control,...
    'Position',[0 0 1 1]);
h.Spectral_Progress_Axes.XTick=[]; h.Spectral_Progress_Axes.YTick=[];
%%% Progress and filename text
h.Spectral_Progress_Text=text(...
    'Parent',h.Spectral_Progress_Axes,...
    'Units','normalized',...
    'FontSize',12,...
    'FontWeight','bold',...
    'String','Nothing loaded',...
    'Interpreter','none',...
    'HorizontalAlignment','center',...
    'BackgroundColor','none',...
    'Color',Look.Fore,...
    'Position',[0.5 0.5]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Image Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Plot panel 1
h.Plot_Panel = uibuttongroup(...
    'Parent',h.SpectralImage,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.005 0.485 0.29 0.475]);

%%% Main Image plot
h.Image_Plot = axes(...
    'Parent',h.Plot_Panel,...
    'Units','normalized',...
    'Position',[0.01 0.01 0.98 0.98]);
h.Spectral_Image = image(zeros(1,1,3));
h.Image_Plot.DataAspectRatio = [1 1 1];
h.Image_Plot.XTick = [];
h.Image_Plot.YTick = [];

%%% Plot panel 2
h.Phasor_Panel = uibuttongroup(...
    'Parent',h.SpectralImage,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.305 0.485 0.29 0.475]);

%%% Main Image plot
h.Phasor_Plot = axes(...
    'Parent',h.Phasor_Panel,...
    'Units','normalized',...
    'NextPlot','add',...
    'Position',[0.1 0.1 0.86 0.86]);
h.Phasor_Image = image(ones(1,1,3));
h.Phasor_Image.HitTest = 'off';

h.Phasor_Plot.DataAspectRatio = [1 1 1];
h.Phasor_Plot.YColor = Look.Fore;
h.Phasor_Plot.XColor = Look.Fore;
h.Phasor_Plot.YLabel.String = 's';
h.Phasor_Plot.XLabel.String = 'g';
h.Phasor_Plot.YLabel.Color = Look.Fore;
h.Phasor_Plot.XLabel.Color = Look.Fore;
h.Phasor_Plot.YDir = 'normal';
h.Phasor_Plot.XLim =[-1.01 1.01];
h.Phasor_Plot.YLim =[-1.01 1.01];
h.Phasor_Plot.ButtonDownFcn = {@Phasor_Click,[]};


%%% Initializes ROIs
ROI_Color = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
for i=1:6
    %%% Rectangular ROIS
    h.Phasor_ROI(i,1)=rectangle(...
        'Parent',h.Phasor_Plot,...
        'Position',[0 0 0 0],...
        'HitTest','off',...
        'Visible','off',...
        'EdgeColor',ROI_Color(i,:));
    %%% Elipsiod ROIS
    h.Phasor_ROI(i,2)=line(...
        'Parent',h.Phasor_Plot,...
        'XData',[0 0],...
        'YData',[0 0],...
        'HitTest','off',...
        'Visible','off',...
        'Color',ROI_Color(i,:));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Image and Phasor display settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Image display panel
h.Display_Panel = uibuttongroup(...
    'Parent',h.SpectralImage,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.605 0.485 0.39 0.475]);


h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.92 0.4 0.06],...
    'String','Image Settings:');

%%%% Colormap selection
h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.82 0.2 0.06],...
    'String','Colormap:');

h.Colormap = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','popup',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.2 0.82 0.18 0.06],...
    'Callback',{@Plot_Spectral,1},...
    'String',{'Gray','Jet','Hot','RGB'});


%%%% Data to be plotted selection
h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.4 0.82 0.2 0.06],...
    'String','Plotted data:');


h.PlottedData = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','popup',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.6 0.82 0.38 0.06],...
    'Callback',{@Plot_Spectral,1},...
    'String',{'Full'});


%%%% Frame Selection
h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.72 0.2 0.06],...
    'String','Frame:');

h.Frame_Edit = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Frame},...
    'Position',[0.2 0.72 0.18 0.06],...
    'String','0');

h.Frame_Slider = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.4 0.72 0.58 0.06]);

h.Frame_Listener=addlistener(h.Frame_Slider,'Value','PostSet',@Frame);

%%%% Scaling settings
h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.62 0.2 0.06],...
    'String','Scale Image:');

h.Autoscale = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.2 0.62 0.18 0.06],...
    'Callback',{@Plot_Spectral,1},...
    'Value',1,...
    'String','Autoscale');

h.Scale{1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.4 0.62 0.18 0.06],...
    'Callback',{@Plot_Spectral,1},...
    'String','0');

h.Scale{2} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.6 0.62 0.18 0.06],...
    'Callback',{@Plot_Spectral,1},...
    'String','100');


%%%% Phasor Settings
h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.47 0.4 0.06],...
    'String','Phasor Settings:');

%%%% Colormap selection
h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.37 0.2 0.06],...
    'String','Colormap:');

h.Phasor_Colormap = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','popup',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',2,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.2 0.37 0.18 0.06],...
    'Callback',{@Plot_Spectral,4},...
    'String',{'Gray','Jet','Hot'});

%%%% Colormap selection
h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.4 0.37 0.2 0.06],...
    'String','Threshold:');

h.Phasor_TH{1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.6 0.37 0.18 0.06],...
    'Callback',{@Calculate_Phasor},...
    'String','100');

h.Phasor_TH{2} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.8 0.37 0.18 0.06],...
    'Callback',{@Calculate_Phasor},...
    'String','0');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Tabs for Species and Filters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.Main_Tabs = uitabgroup(...
    'Parent',h.SpectralImage,...
    'Units','normalized',...
    'Position',[0.005 0.005 0.59 0.475]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tab for Species %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.Species_Tab = uitab(...
    'Parent',h.Main_Tabs,...
    'Title','Species',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', [0 0 0],...
    'Units','normalized');

%%% List containing the species
h.Species_List = uicontrol(...
    'Parent',h.Species_Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.List,...
    'ForegroundColor', Look.ListFore,...
    'FontSize',12,...
    'String',{'Data'},...
    'Value',1,...
    'Max',5,...
    'KeyPressFcn',{@Species_Callback},...
    'Callback',{@Plot_Spectral,2},...
    'Position',[0.01 0.01 0.28 0.98],...
    'Style','listbox');

%%% Axis for plotting species spectra
h.Species_Plot = axes(...
    'Parent',h.Species_Tab,...
    'Units','normalized',...
    'Box','off',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'FontSize',12,...
    'LineWidth', Look.AxWidth,...
    'YGrid','on',...
    'XGrid','on',...
    'Position',[0.36 0.14 0.61 0.78]);

h.Species_Plot.YLabel.String = 'Frequency';
h.Species_Plot.YLabel.Color = Look.Fore;

h.Species_Plot.XLabel.String = 'Spectral channel';
h.Species_Plot.XLabel.Color = Look.Fore;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tab for Filters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.Filter_Tab = uitab(...
    'Parent',h.Main_Tabs,...
    'Title','Filters',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', [0 0 0],...
    'Units','normalized');

%%% List containing the species
h.Filter_List = uicontrol(...
    'Parent',h.Filter_Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.List,...
    'ForegroundColor', Look.ListFore,...
    'FontSize',12,...
    'String',{'Full'},...
    'Value',1,...
    'Max',5,...
    'Callback',{@Plot_Spectral,[1,3]},...
    'KeyPressFcn',{@Filter_Callback},...
    'Position',[0.01 0.01 0.28 0.78],...
    'Style','listbox');

%%% Axis for plotting species spectra
h.Filter_Plot = axes(...
    'Parent',h.Filter_Tab,...
    'Units','normalized',...
    'Box','off',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'FontSize',12,...
    'LineWidth', Look.AxWidth,...
    'YGrid','on',...
    'XGrid','on',...
    'Position',[0.36 0.14 0.61 0.78]);

h.Filter_Plot.YLabel.String = 'Weight';
h.Filter_Plot.YLabel.Color = Look.Fore;

h.Filter_Plot.XLabel.String = 'Spectral channel';
h.Filter_Plot.XLabel.Color = Look.Fore;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Tabs for controls and processes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.Control_Tabs = uitabgroup(...
    'Parent',h.SpectralImage,...
    'Units','normalized',...
    'Position',[0.605 0.005 0.39 0.475]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tab for Species and Filter Generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.SF_Tab = uitab(...
    'Parent',h.Control_Tabs,...
    'Title','Species and Filters',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', [0 0 0],...
    'Units','normalized');

%%% Controls to create simple rectangular filters
h.Simple_Button = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback', {@Calc_Filter,1},...
    'Position',[0.02 0.92 0.4 0.06],...
    'String','Create simple filter');

h.Simple_Range = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.43 0.92 0.15 0.06],...
    'String','1:10');

%%% Button to save selected filters
h.Calc_Filter = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback', {@Calc_Filter,2},...
    'Position',[0.02 0.82 0.4 0.06],...
    'String','Create filters');

%%% Button to save selected filters
h.Save_Homo_Filter = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback', {@Save_Filtered,1},...
    'Position',[0.02 0.42 0.46 0.12],...
    'String','Save filtered data');

%%% Button to save selected filters
h.Save_Phasor_Filter = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback', {@Save_Filtered,3},...
    'Position',[0.02 0.22 0.46 0.12],...
    'String','Save phasor resolved data');

%%% Button to save selected filters
h.Save_Hetero_Filter = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback', {@Save_Filtered,2},...
    'Position',[0.02 0.02 0.46 0.12],...
    'String','Save spatially resolved');


h.Spatial_Average_Type = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.02 0.34 0.07],...
    'String',{'No averaging', 'Moving average','Gaussian','Disk'});

h.Spatial_Average_Size = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.86 0.02 0.12 0.06],...
    'String','3');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tab for Database %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.Database_Tab = uitab(...
    'Parent',h.Control_Tabs,...
    'Title','Database',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', [0 0 0],....
    'Units','normalized');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Defines custom cursor shapes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SpectralData.Cursor=[];
%%%%1
Point=zeros(16);
Point(1:8,1:2)=1;
Point(1:2,1:8)=1;
Point(5,8:11)=1;
Point(6,7:11)=1;
Point(7,6:11)=1;
Point(8,[5:7 10:11])=1;
Point(9,[5:6 10:11])=1;
Point(10:14,10:11)=1;
Point(15:16,7:14)=1;
Point(Point==0)=NaN;
SpectralData.Cursor{1}=Point;

%%%%2
Point=zeros(16);
Point(1:8,1:2)=1;
Point(1:2,1:8)=1;
Point([5:6 10:11 15:16],5:11)=1;
Point(10:16,5:6)=1;
Point(5:11,10:11)=1;
Point(Point==0)=NaN;
SpectralData.Cursor{2}=Point;

%%%%3
Point=zeros(16);
Point(1:8,1:2)=1;
Point(1:2,1:8)=1;
Point([5:6 10:11 15:16],5:11)=1;
Point(5:16,10:11)=1;
Point(Point==0)=NaN;
SpectralData.Cursor{3}=Point;

%%%%4
Point=zeros(16);
Point(1:8,1:2)=1;
Point(1:2,1:8)=1;
Point(5:16,10:11)=1;
Point(5:11,5:6)=1;
Point(10:11,5:11)=1;
Point(Point==0)=NaN;
SpectralData.Cursor{4}=Point;

%%%%5
Point=zeros(16);
Point(1:8,1:2)=1;
Point(1:2,1:8)=1;
Point([5:6 10:11 15:16],5:11)=1;
Point(5:11,5:6)=1;
Point(11:16,10:11)=1;
Point(Point==0)=NaN;
SpectralData.Cursor{5}=Point;

%%%%6
Point=zeros(16);
Point(1:8,1:2)=1;
Point(1:2,1:8)=1;
Point([5:6 10:11 15:16],5:11)=1;
Point(5:16,5:6)=1;
Point(11:16,10:11)=1;
Point(Point==0)=NaN;
SpectralData.Cursor{6}=Point;

%%%%7
Point=zeros(16);
Point(1:8,1:2)=1;
Point(1:2,1:8)=1;
Point(5:6,5:11)=1;
Point(5:16,10:11)=1;
Point(Point==0)=NaN;
SpectralData.Cursor{7}=Point;

%%%%8
Point=zeros(16);
Point(1:8,1:2)=1;
Point(1:2,1:8)=1;
Point([5:6 10:11 15:16],5:11)=1;
Point(5:16,10:11)=1;
Point(5:16,5:6)=1;
Point(Point==0)=NaN;
SpectralData.Cursor{8}=Point;

%%%%9
Point=zeros(16);
Point(1:8,1:2)=1;
Point(1:2,1:8)=1;
Point([5:6 10:11 15:16],5:11)=1;
Point(5:10,5:6)=1;
Point(5:16,10:11)=1;
Point(Point==0)=NaN;
SpectralData.Cursor{9}=Point;
%% Saves guidata and initializes global variable %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SpectralData.Data = [];
SpectralData.Int = [];
SpectralData.G = [];
SpectralData.S = [];
SpectralData.Phasor = [];
SpectralData.PhasorROI = [];
SpectralData.Species = struct('Name',{'Data'},'Data',{ones(1,1,30,1)},'Phasor',[0 0]);
SpectralData.Filter = struct('Name',{'Full'},'Data',{ones(1,1,30,1)},'Species',1);
SpectralData.Meta = [];

h.SpeciesPlots = [];
h.SpeciesPhasor = [];
h.FilterPlots = [];

guidata(h.SpectralImage,h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for closing and deleting global variables
%%% Will be removed later
function Close_Filter(Obj,~)
clear global -regexp SpectralData
Pam=findobj('Tag','Pam');
FCSFit=findobj('Tag','FCSFit');
MIAFit=findobj('Tag','MIAFit');
Mia=findobj('Tag','Mia');
Sim=findobj('Tag','Sim');
PCF=findobj('Tag','PCF');
BurstBrowser=findobj('Tag','BurstBrowser');
TauFit=findobj('Tag','TauFit');
PhasorTIFF = findobj('Tag','PhasorTIFF');
Phasor = findobj('Tag','Phasor');
Particle = findobj('Tag','Particle');

if isempty(Pam) && isempty(FCSFit) && isempty(MIAFit) && isempty(PCF) && isempty(Mia) && isempty(Sim) && isempty(TauFit) && isempty(BurstBrowser) && isempty(PhasorTIFF)  && isempty(Phasor) && isempty(Particle)
    clear global -regexp UserValues PathToApp
end
delete(Obj);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Loading Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for loading data and species
%%% mode 1: load data
%%% mode 2: load data into database
%%% mode 3: not used yet; might be used for automatic loading from database
%%% mode 4: load species data
function Load_Data(~,~,mode)
global SpectralData UserValues
h = guidata(findobj('Tag','SpectralImage'));

switch mode
    case 1 %%% Normal data loading
        %%%% This is a test version and will be adjusted for the final
        %%%% version
        
        %% Get filenames
        [FileName,Path,Type] = uigetfile({'*.czi';'*.tif'}, 'Load spectral image data', 'MultiSelect', 'on',UserValues.File.Spectral_Standard);
        
        if all(Path==0)
            return
        end
        %%% Updates Progressbar
        h.Spectral_Progress_Axes.Color = [1 0 0];
        h.Spectral_Progress_Text.String = 'Loading Data';
        drawnow;
        
        %%% Transforms FileName into cell array
        if ~iscell(FileName)
            FileName={FileName};
        end
        UserValues.File.Spectral_Standard = Path;
        LSUserValues(1);
        
        SpectralData.Data = [];
        SpectralData.Meta = [];
        %% Loads Data
        switch Type
            case 1 %%% Zeiss CZI files
                Frame=0;
                for i=1:numel(FileName)
                    %%% Loads Data
                    Data = bfopen(fullfile(Path,FileName{i}));
                    
                    %%% Reads MetaData
                    FileInfo  = czifinfo(fullfile(Path,FileName{i}));
                    Info = FileInfo.metadataXML;
                    
                    %%%FrameTime
                    Start = strfind(Info,'<FrameTime>');
                    Stop = strfind(Info,'</FrameTime>');
                    SpectralData.Meta.Frame = Info(Start+11:Stop-1);
                    %%%LineTime => seems to be off, so I don't read it in
                    %             Start = strfind(Info,'<LineTime>');
                    %             Stop = strfind(Info,'</LineTime>');
                    %             h.Mia_Image.Settings.Image_Line.String = Info(Start+10:Stop-1);
                    %             h.Mia_ICS.Fit_Table.Data(15,:) = {Info(Start+10:Stop-1);};
                    %%%PixelTime
                    Start = strfind(Info,'<PixelTime>');
                    Stop = strfind(Info,'</PixelTime>');
                    PixelTime = str2double(Info(Start+11:Stop-1))*10^6;
                    SpectralData.Meta.Pixel = num2str(PixelTime);

                    SpectralData.Meta.Line = '3';
                    SpectralData.Meta.Size = '50.2';
                    
                    %%% Finds positions of plane/channel/time seperators
                    Sep = strfind(Data{1,1}{1,2},';');
                    
                    if numel(Sep) == 3 %%% Normal mode
                        %%% Determines number of frames
                        F_Sep = strfind(Data{1,1}{1,2}(Sep(3):end),'/');
                        N_F = str2double(Data{1,1}{1,2}(Sep(3)+F_Sep:end));
                        
                        %%% Determines number of channels
                        C_Sep = strfind(Data{1,1}{1,2}(Sep(2):(Sep(3)-1)),'/');
                        N_C = str2double(Data{1,1}{1,2}(Sep(2)+C_Sep:(Sep(3)-1)));
                    elseif numel(Sep) == 2 %%% Single Frame or Single Channel
                        if ~isempty(strfind(Data{1,1}{1,2}(Sep(2):end),'C')) %%% Single Color
                            %%% Determines number of channels
                            C_Sep = strfind(Data{1,1}{1,2}(Sep(2):end),'/');
                            N_C = str2double(Data{1,1}{1,2}(Sep(2)+C_Sep:end));
                            N_F  = 1;
                        else %%% Single Frame
                            msgbox('Inavalid data type')
                            return;
                        end
                    else
                        msgbox('Inavalid data type')
                        return;
                    end
                    
                    for j=1:size(Data{1,1},1)
                        %%% Current channel
                        C = mod(j-1,N_C)+1;
                        %%% Current frame
                        F = floor((j-1)/N_C)+1;
                        %%% Adds data
                        SpectralData.Data(:,:,C,F+Frame) = uint16(Data{1,1}{j,1});
                    end
                    Frame = size(SpectralData.Data,4);
                end
                
            case 2 %%% Tiff based files created with simulations
                SpectralData.Data=uint16.empty(0,0,0);
                for i=1:numel(FileName)
                    Info=imfinfo(fullfile(Path,FileName{i}));
                    
                    %%% Automatically updates image properties
                    TIFF_Handle = Tiff(fullfile(Path,FileName{i}),'r'); % Open tif reference
                    Frames = 1:numel(Info);
                    
                    for j=Frames
                        TIFF_Handle.setDirectory(j);
                        SpectralData.Data(:,:,end+1) = TIFF_Handle.read();
                    end
                    TIFF_Handle.close(); % Close tif reference
                end
                SpectralData.Data = reshape(SpectralData.Data,size(SpectralData.Data,1),size(SpectralData.Data,2),36,[]);
        end
        
        %% Calculates Metadata
        SpectralData.Path = Path;
        SpectralData.FileName = FileName{1};
        
        
        SpectralData.Int = squeeze(sum(double(sum(SpectralData.Data,3)),4));
        
        SpectralData.Species(1).Data = sum(sum(double(sum(SpectralData.Data,4)),2),1);
        SpectralData.Species(1).Data = SpectralData.Species(1).Data/max(SpectralData.Species(1).Data(:));
        
        G = reshape(cos(2*pi*(1:size(SpectralData.Species(1).Data,3))/size(SpectralData.Species(1).Data,3)),1,1,[]);
        S = reshape(sin(2*pi*(1:size(SpectralData.Species(1).Data,3))/size(SpectralData.Species(1).Data,3)),1,1,[]);
        SpectralData.Species(1).Phasor(1) = sum(SpectralData.Species(1).Data.*G)/sum(SpectralData.Species(1).Data);
        SpectralData.Species(1).Phasor(2) = sum(SpectralData.Species(1).Data.*S)/sum(SpectralData.Species(1).Data);
        
        SpectralData.Filter(1).Data = ones(1,1,size(SpectralData.Data,3),1);
        
        
        
        %%% Adjusts slider and frame range
        h.Frame_Slider.Min=0;
        h.Frame_Slider.Max = size(SpectralData.Data,4);
        h.Frame_Slider.SliderStep=[1./size(SpectralData.Data,4), 10/size(SpectralData.Data,4);];
        h.Frame_Slider.Value=0;
        h.Frame_Edit.String = '0';
        
        %%% Recalculates filters for current data
        for i=1:numel(SpectralData.Filter)
            h.Filter_List.Value = i;
            if any(SpectralData.Filter(i).Species ~= 1)
                Calc_Filter([],[],2,SpectralData.Filter(i).Species);
            end
        end
        
        %% Calculates Spectral Phasor for current data
        Calculate_Phasor;
        
        
        Plot_Spectral([],[],0);
        
    case 2 %%% Loads files into database
        
    case 4 %%% Loads species
        %%%% This is a test version and will be adjusted for the final
        %%%% version
        
        [FileName,Path,Type] = uigetfile({'*.czi';'*.tif'}, 'Load species data', 'MultiSelect', 'on',UserValues.File.Spectral_Standard);
        
        if all(Path==0)
            return
        end
        %%% Updates Progressbar
        h.Spectral_Progress_Axes.Color = [1 0 0];
        h.Spectral_Progress_Text.String = 'Loading Species';
        drawnow;
        
        UserValues.File.Spectral_Standard = Path;
        LSUserValues(1);
        
        %%% Transforms FileName into cell array
        if ~iscell(FileName)
            FileName={FileName};
        end
        
        SpectralData.Meta = [];
        %% Loads all frames
        for i=1:numel(FileName)
            switch Type
                case 1 %%% Zeiss CZI data
                    %%% Loads Data
                    Data_Raw = bfopen(fullfile(Path,FileName{i}));
                    
                    %%% Finds positions of plane/channel/time seperators
                    Sep = strfind(Data_Raw{1,1}{1,2},';');
                    
                    if numel(Sep) == 3 %%% Normal mode
                        %%% Determines number of frames
                        F_Sep = strfind(Data_Raw{1,1}{1,2}(Sep(3):end),'/');
                        N_F = str2double(Data_Raw{1,1}{1,2}(Sep(3)+F_Sep:end));
                        
                        %%% Determines number of channels
                        C_Sep = strfind(Data_Raw{1,1}{1,2}(Sep(2):(Sep(3)-1)),'/');
                        N_C = str2double(Data_Raw{1,1}{1,2}(Sep(2)+C_Sep:(Sep(3)-1)));
                    elseif numel(Sep) == 2 %%% Single Frame or Single Channel
                        if ~isempty(strfind(Data_Raw{1,1}{1,2}(Sep(2):end),'C')) %%% Single Color
                            %%% Determines number of channels
                            C_Sep = strfind(Data_Raw{1,1}{1,2}(Sep(2):end),'/');
                            N_C = str2double(Data_Raw{1,1}{1,2}(Sep(2)+C_Sep:end));
                            N_F  = 1;
                        else %%% Single Frame
                            msgbox('Inavalid data type')
                            return;
                        end
                    else
                        msgbox('Inavalid data type')
                        return;
                    end
                    
                    Data = zeros(size(Data_Raw{1,1}{1,1},1),size(Data_Raw{1,1}{1,1},1),N_C,N_F,'uint16');
                    for j=1:size(Data_Raw{1,1},1)
                        %%% Current channel
                        C = mod(j-1,N_C)+1;
                        %%% Current frame
                        F = floor((j-1)/N_C)+1;
                        %%% Adds data
                        Data(:,:,C,F) = uint16(Data_Raw{1,1}{j,1});
                    end
                case 2 %%% Tiff based data              
                    Info=imfinfo(fullfile(Path,FileName{i}));
                    
                    %%% Automatically updates image properties
                    TIFF_Handle = Tiff(fullfile(Path,FileName{i}),'r'); % Open tif reference
                    Frames = 1:numel(Info);
                    Data=uint16.empty(0,0,0);
                    for j=Frames
                        TIFF_Handle.setDirectory(j);
                        Data(:,:,end+1) = TIFF_Handle.read();
                    end
                    TIFF_Handle.close(); % Close tif reference
                    Data = reshape(Data,size(Data,1),size(Data,2),36,[]);
                    
            end
            SpectralData.Species(end+1).Data = reshape((sum(sum(sum(Data,4),2),1)),1,1,[],1);
            SpectralData.Species(end).Data = SpectralData.Species(end).Data./max(SpectralData.Species(end).Data(:));
            SpectralData.Species(end).Name = FileName{i}(1:end-4);
            
            G = reshape(cos(2*pi*(1:size(SpectralData.Species(end).Data,3))/size(SpectralData.Species(end).Data,3)),1,1,[]);
            S = reshape(sin(2*pi*(1:size(SpectralData.Species(end).Data,3))/size(SpectralData.Species(end).Data,3)),1,1,[]);
            SpectralData.Species(end).Phasor(1) = sum(SpectralData.Species(end).Data.*G)/sum(SpectralData.Species(end).Data);
            SpectralData.Species(end).Phasor(2) = sum(SpectralData.Species(end).Data.*S)/sum(SpectralData.Species(end).Data);
            
            h.Species_List.String{end+1} = SpectralData.Species(end).Name;
        end
        
        
        Plot_Spectral([],[],2);
        
end
h.Spectral_Progress_Axes.Color = UserValues.Look.Control;
h.Spectral_Progress_Text.String = SpectralData.FileName;
drawnow;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%  Plotting Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for displaying data
function Plot_Spectral(~,~,mode)
global SpectralData
h = guidata(findobj('Tag','SpectralImage'));

%%% Updates everything
if isempty(mode) || any(mode==0)
    mode = 1:4;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Updates Image plot
if any(mode == 1) && ~isempty(SpectralData.Data)
    FilterMode = h.PlottedData.Value;
    ColormapMode = h.Colormap.Value;
    
    if ColormapMode <4 %%% Plots one selected filter with colormap
        %%% Turns off image recalculation when fixed filter is selected
        h.Filter_List.Callback{2} = 3;
        
        Filter = single(SpectralData.Filter(FilterMode).Data);
        
        %%% Adjusts sizes of filter
        if size(Filter,3) < size(SpectralData.Data,3) %%% Extends filter with zeros to fit data
            Filter(1,1,size(SpectralData.Data,3),1) = 0;
        elseif size(Filter,3) > size(SpectralData.Data,3) %%% Shortens filter at the end to fit data
            Filter(1,1,size(SpectralData.Data,3)+1:end,1) = [];
        end
        
        %%% Calculates filter weightes intensity
        Frame = str2double(h.Frame_Edit.String);
        if Frame == 0 %%% Sum over time
            
            %%% Applies filter weighting
            if FilterMode == 1
                Image = SpectralData.Int;
            else
                Image = single(SpectralData.Data) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, size(SpectralData.Data,4));
                %%% Summs over spectral information
                Image = squeeze(sum(sum(Image,3),4));
            end
            
            
        else %%% Single Frame
            Image = single(SpectralData.Data(:,:,:,Frame)) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, 1);
            %%% Summs over spectral information
            Image = squeeze(sum(Image,3));
        end
        
        %%% Set image colormap
        switch ColormapMode
            case 1
                Map = gray(64);
            case 2
                Map = jet(64);
            case 3
                Map = hot(64);
        end
        
        %%% Scale image
        if h.Autoscale.Value %%% Autoscaling
            %%% Transforms intensity image to 64 bits
            Int = round(63*(Image-min(Image(:)))/(max(Image(:))-min(Image(:))))+1;
            
        else %%% Manual scaling
            Min = str2double(h.Scale{1}.String);
            Max = str2double(h.Scale{2}.String);
            if isempty(Min)
                Min = 0;
                h.Scale{1}.String = '0';
            end
            if isempty(Max) || Max <= Min
                Max = Min+1;
                h.Scale{2}.String = num2str(Max);
            end
            
            %%% Transforms intensity image to 64 bits
            Int = round(63*(Image-Min)/(Max-Min))+1;
        end
        Int(Int<1) = 1;
        Int(Int>64) = 64;
        %%% Applies colormap
        Image = reshape(Map(Int(:),:),size(Image,1),size(Image,2),3);
        
        %%% Applies ROI filter to image
        if any(cell2mat(strfind({h.Phasor_ROI.Visible},'on')))
            Color = zeros(size(SpectralData.Int,1),size(SpectralData.Int,2),3);
            Mask = zeros(size(SpectralData.Int,1),size(SpectralData.Int,2));
            for i=1:6
                if strcmp(h.Phasor_ROI(i,1).Visible,'on') || strcmp(h.Phasor_ROI(i,2).Visible,'on')
                    %%% Sets pixels color to sum of ROI colors
                    Color(:,:,1) = Color(:,:,1) + SpectralData.PhasorROI(:,:,i) .* h.Phasor_ROI(i,1).EdgeColor(1);
                    Color(:,:,2) = Color(:,:,2) + SpectralData.PhasorROI(:,:,i) .* h.Phasor_ROI(i,1).EdgeColor(2);
                    Color(:,:,3) = Color(:,:,3) + SpectralData.PhasorROI(:,:,i) .* h.Phasor_ROI(i,1).EdgeColor(3);
                    %%% Sum of ROI per pixel
                    Mask = Mask + SpectralData.PhasorROI(:,:,i);
                end
            end
            %%% Rescales to average ROI color
            Mask = repmat(Mask,1,1,3);
            Color = Color./Mask;
            if ColormapMode == 1
                %%% Scales ROI color with intensity
                Image(Mask>0) = Image(Mask>0) .* Color(Mask>0);
            else
                %%% Uses Plane ROI color
                Image(Mask>0) = Color(Mask>0);
            end
            
        end
        
    elseif ColormapMode == 4 %%% Plots up to three filters in RGB
        %%% Turns on image recalculation when variable filter is selected
        h.Filter_List.Callback{2} = [1 3];
        
        %%% Selects channels to be plotted
        Sel = h.Filter_List.Value;
        %%% Removes extra chennels
        if numel(Sel)>3
            Sel(Sel==1)=[]; %% Removes first channel
            Sel = Sel(1:3);
        end
        
        switch numel(Sel)
            case 1 %%% Plots single channel in green
                
                Filter = single(SpectralData.Filter(Sel).Data);
                %%% Adjusts sizes of filter
                if size(Filter,3) < size(SpectralData.Data,3) %%% Extends filter with zeros to fit data
                    Filter(1,1,size(SpectralData.Data,3),1) = 0;
                elseif size(Filter,3) > size(SpectralData.Data,3) %%% Shortens filter at the end to fit data
                    Filter(1,1,size(SpectralData.Data,3)+1:end,1) = [];
                end
                
                %%% Calculates filter weightes intensity
                Frame = str2double(h.Frame_Edit.String);
                if Frame == 0 %%% Sum over time
                    %%% Applies filter weighting
                    if Sel == 1
                        Image = single(SpectralData.Data);
                    else
                        Image = single(SpectralData.Data) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, size(SpectralData.Data,4));
                    end
                    %%% Summs over spectral information
                    Image = squeeze(sum(sum(Image,3),4));
                    
                else %%% Single Frame
                    Image = single(SpectralData.Data(:,:,:,Frame)) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, 1);
                    %%% Summs over spectral information
                    Image = squeeze(sum(Image,3));
                end
                %%% Scale image
                if h.Autoscale.Value %%% Autoscaling
                    Image = (Image-min(Image(:)))/(max(Image(:))-min(Image(:)));
                    %%% Homogeneous image
                    if all(isinf(Image(:)))
                        Image = Image*0;
                    end
                    %%% Sets blue and red channels to zero
                    Image_R = Image*0;
                    Image_B = Image*0;
                    
                else %%% Manual scaling
                    %%% Extracts scale
                    Min = str2double(h.Scale{1}.String);
                    Max = str2double(h.Scale{2}.String);
                    if isempty(Min)
                        Min = 0;
                        h.Scale{1}.String = '0';
                    end
                    if isempty(Max) || Max <= Min
                        Max = Min+1;
                        h.Scale{2}.String = num2str(Max);
                    end
                    
                    %%% Rescales image
                    Image = (Image-Min)/(Max-Min);
                    %%% Pixels outside of range are shown in blue and red
                    Image_B = Image<0;
                    Image_R = Image>1;
                    Image = Image.*~(Image_B | Image_R);
                    
                end
                
                %%% Plots Image
                Image = repmat(Image,1,1,3);
                Image(:,:,1) = Image_R;
                Image(:,:,3) = Image_B;
                
            case 2 %%% Plots two channels in green/magenta
                for i = 1:2
                    Filter = single(SpectralData.Filter(Sel(i)).Data);
                    %%% Adjusts sizes of filter
                    if size(Filter,3) < size(SpectralData.Data,3) %%% Extends filter with zeros to fit data
                        Filter(1,1,size(SpectralData.Data,3),1) = 0;
                    elseif size(Filter,3) > size(SpectralData.Data,3) %%% Shortens filter at the end to fit data
                        Filter(1,1,size(SpectralData.Data,3)+1:end,1) = [];
                    end
                    
                    %%% Calculates filter weightes intensity
                    Frame = str2double(h.Frame_Edit.String);
                    if Frame == 0 %%% Sum over time
                        %%% Applies filter weighting
                        if Sel == 1
                            Image = single(SpectralData.Data);
                        else
                            Image = single(SpectralData.Data) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, size(SpectralData.Data,4));
                        end
                        %%% Summs over spectral information
                        Image = squeeze(sum(sum(Image,3),4));
                        
                    else %%% Single Frame
                        Image = single(SpectralData.Data(:,:,:,Frame)) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, 1);
                        %%% Summs over spectral information
                        Image = squeeze(sum(Image,3));
                    end
                    %%% Scale image
                    if h.Autoscale.Value %%% Autoscaling
                        Image = (Image-min(Image(:)))/(max(Image(:))-min(Image(:)));
                        %%% Homogeneous image
                        if all(isinf(Image(:)))
                            Image = Image*0;
                        end
                        
                    else %%% Manual scaling
                        %%% Extracts scale
                        Min = str2double(h.Scale{1}.String);
                        Max = str2double(h.Scale{2}.String);
                        if isempty(Min)
                            Min = 0;
                            h.Scale{1}.String = '0';
                        end
                        if isempty(Max) || Max <= Min
                            Max = Min+1;
                            h.Scale{2}.String = num2str(Max);
                        end
                        
                        %%% Rescales image
                        Image = (Image-Min)/(Max-Min);
                        %%% Pixels outside of range are shown in blue and red
                    end
                    
                    if i==1 %%% Stores Green image part
                        Image_G = Image;
                    end
                end
                
                %%% Plots Image
                Image = repmat(Image,1,1,3);
                Image(:,:,2) = Image_G;
                
            case 3 %%% Plots three channels in RGB
                for i = 1:3
                    Filter = single(SpectralData.Filter(Sel(i)).Data);
                    %%% Adjusts sizes of filter
                    if size(Filter,3) < size(SpectralData.Data,3) %%% Extends filter with zeros to fit data
                        Filter(1,1,size(SpectralData.Data,3),1) = 0;
                    elseif size(Filter,3) > size(SpectralData.Data,3) %%% Shortens filter at the end to fit data
                        Filter(1,1,size(SpectralData.Data,3)+1:end,1) = [];
                    end
                    
                    %%% Calculates filter weightes intensity
                    Frame = str2double(h.Frame_Edit.String);
                    if Frame == 0 %%% Sum over time
                        %%% Applies filter weighting
                        if Sel == 1
                            Image = single(SpectralData.Data);
                        else
                            Image = single(SpectralData.Data) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, size(SpectralData.Data,4));
                        end
                        %%% Summs over spectral information
                        Image = squeeze(sum(sum(Image,3),4));
                        
                    else %%% Single Frame
                        Image = single(SpectralData.Data(:,:,:,Frame)) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, 1);
                        %%% Summs over spectral information
                        Image = squeeze(sum(Image,3));
                    end
                    %%% Scale image
                    if h.Autoscale.Value %%% Autoscaling
                        Image = (Image-min(Image(:)))/(max(Image(:))-min(Image(:)));
                        %%% Homogeneous image
                        if all(isinf(Image(:)))
                            Image = Image*0;
                        end
                        
                    else %%% Manual scaling
                        %%% Extracts scale
                        Min = str2double(h.Scale{1}.String);
                        Max = str2double(h.Scale{2}.String);
                        if isempty(Min)
                            Min = 0;
                            h.Scale{1}.String = '0';
                        end
                        if isempty(Max) || Max <= Min
                            Max = Min+1;
                            h.Scale{2}.String = num2str(Max);
                        end
                        
                        %%% Rescales image
                        Image = (Image-Min)/(Max-Min);
                        %%% Pixels outside of range are shown in blue and red
                    end
                    
                    if i==1 %%% Stores Green image part
                        Image_G = Image;
                    elseif i==2
                        Image_R = Image;
                    end
                end
                
                %%% Plots Image
                Image = repmat(Image,1,1,3);
                Image(:,:,2) = Image_G;
                Image(:,:,1) = Image_R;
        end
        
    end
    %%% Plots image and rescalses size
    h.Spectral_Image.CData = Image;
    h.Spectral_Image.CDataMapping = 'direct';
    
    h.Image_Plot.XLim = [0.5 size(h.Spectral_Image.CData,2)+0.5];
    h.Image_Plot.YLim = [0.5 size(h.Spectral_Image.CData,1)+0.5];
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Updates Species plot
if any(mode == 2)
    Sel = h.Species_List.Value;
    for i=1:numel(SpectralData.Species)
        
        %%% Updates plot data
        if numel(h.SpeciesPlots) < i
            h.SpeciesPlots{i} = plot(h.Species_Plot, squeeze(SpectralData.Species(i).Data));
        else
            h.SpeciesPlots{i}.YData = SpectralData.Species(i).Data;
        end
        %%% Updates phasor data
        if numel(h.SpeciesPhasor) < i
            h.SpeciesPhasor{i} = scatter(h.Phasor_Plot, SpectralData.Species(i).Phasor(1),SpectralData.Species(i).Phasor(2),'CData',h.SpeciesPlots{i}.Color);
        else
            h.SpeciesPhasor{i}.XData = SpectralData.Species(i).Phasor(1);
            h.SpeciesPhasor{i}.YData = SpectralData.Species(i).Phasor(2);
        end
        
        %%% Shows only selected species
        if any(i==Sel)
            h.SpeciesPlots{i}.Visible = 'on';
            h.SpeciesPhasor{i}.Visible = 'on';
        else
            h.SpeciesPlots{i}.Visible = 'off';
            h.SpeciesPhasor{i}.Visible = 'off';
        end
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Updates Filter plot
if any(mode == 3)
    Sel = h.Filter_List.Value;
    Min = -0.05;
    Max = 1.05;
    for i=1:numel(SpectralData.Filter)
        
        %%% Updates plot data
        if numel(h.FilterPlots) < i
            h.FilterPlots{i} = plot(h.Filter_Plot, squeeze(SpectralData.Filter(i).Data), 'LineStyle','--', 'LineWidth',2);
        else
            h.FilterPlots{i}.YData = SpectralData.Filter(i).Data;
        end
        
        %%% Shows only selected species
        if any(i==Sel)
            h.FilterPlots{i}.Visible = 'on';
            
            Min = min([h.FilterPlots{i}.YData-0.05 Min]);
            Max = max([h.FilterPlots{i}.YData+0.05 Max]);
        else
            h.FilterPlots{i}.Visible = 'off';
        end
    end
    
    h.Filter_Plot.YLim = [Min Max];
    
    
end

%% Uppdates Phasor plot
if any(mode == 4) && ~isempty(SpectralData.Phasor)
    
    %%% Plots phasor histogram
    h.Phasor_Image.CData = SpectralData.Phasor;
    h.Phasor_Image.CDataMapping = 'scaled'; 
    h.Phasor_Image.XData = linspace(-1, 1, 200);
    h.Phasor_Image.YData = linspace(-1, 1, 200);
    h.Phasor_Image.AlphaData = SpectralData.Phasor>0;
    %%% Sets histogram colormap
    switch h.Phasor_Colormap.Value
        case 1
            colormap(h.Phasor_Plot,'gray');
        case 2
            colormap(h.Phasor_Plot,'jet');
        case 3
            colormap(h.Phasor_Plot,'hot');
    end
end

guidata(h.SpectralImage,h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for updating frame
function Frame(obj,e)
h = guidata(findobj('Tag','SpectralImage'));
global SpectralData

if obj == h.Frame_Edit %%% Editbox was changed
    Frame=str2double(h.Frame_Edit.String);
    
    %%% Set Frame to 0 if it was an invalid input
    if isempty(Frame) || Frame <0
        Frame = 0;
        h.Frame_Edit.String = str2double(Frame);
    end
    %%% rounds Frame to nearest integer
    if mod(Frame,1)~=0
        Frame = round(Frame);
        h.Frame_Edit.String = str2double(Frame);
    end
    %%% Sets Frame into bounds
    if Frame > size(SpectralData.Data,4)
        Frame = size(SpectralData.Data,4);
        h.Frame_Edit.String = str2double(Frame);
    end
    h.Frame_Slider.Value = Frame;
    
    
elseif strcmp(e.EventName, 'PostSet') && e.AffectedObject == h.Frame_Slider %%% Slider was changed
    
    Frame=h.Frame_Slider.Value;
    
    %%% rounds Frame to nearest integer
    if mod(Frame,1)~=0
        Frame = round(Frame);
        h.Frame_Slider.Value = Frame;
    end
    %%% Sets Frame into bounds
    if Frame > size(SpectralData.Data,4)
        Frame = size(SpectralData.Data,4);
        h.Frame_Slider.Value = Frame;
    end
    h.Frame_Edit.String = num2str(Frame);
end
Plot_Spectral([],[],1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% FIlter and Species Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions for the interaction with the filter list
function Filter_Callback(obj, e)
h = guidata(findobj('Tag','SpectralImage'));
global SpectralData

event = 'nothing';
%%% Determines action
switch e.EventName
    case 'KeyPress' %%% Event was executed via key press
        switch e.Key
            case {'delete','backspace'} %%% delete filter
                event = 'delete';
            case 'r' %%% rename filter
                event = 'rename';
        end
        
end

%%% Executes action
switch event
    case 'nothing'
        return;
    case 'delete' %%% delete filter
        %%% Selected entries
        if isfield(e, 'Selected') %%% Species was deleted
            Sel = e.Selected;
        else %%% Filter was deleted
            Sel = obj.Value;
        end
        
        %%% ignores the first entry
        Sel(Sel==1)=[];
        
        %%% Stops if ony first was selected
        if isempty(Sel)
            return;
        end
        
        %%% Deletes filter
        SpectralData.Filter(Sel) = [];
        %%% Removes filter from list
        obj.String(Sel) = [];
        %%% Removes plot selections
        h.PlottedData.String(Sel)=[];
        %%% Deletes filter plots
        for i = Sel
            if numel(h.FilterPlots) >= i && isvalid(h.FilterPlots{i})
                delete(h.FilterPlots{i});
            end
        end
        %%% Removes deleted plots
        for i= numel(h.FilterPlots):-1:1
            if ~isvalid(h.FilterPlots{i})
                h.FilterPlots(i)=[];
            end
        end
        guidata(h.SpectralImage,h);
        
        %%% Sets list selection to first
        obj.Value = 1;
        %%% Re-sets selected filter
        if any(h.PlottedData.Value == Sel)
            h.PlottedData.Value = 1;
        elseif any(h.PlottedData.Value > Sel)
            h.PlottedData.Value = h.PlottedData.Value - sum(h.PlottedData.Value > Sel);
        end
        Plot_Spectral([],[],[1,3]);
        
    case 'rename'
        Sel = obj.Value;
        %%% ignores the first entry
        Sel(Sel==1)=[];
        %%% only applies to first selected entry
        if numel(Sel) == 0
            return;
        elseif numel(Sel) > 1
            Sel = Sel(1);
        end
        
        Name = inputdlg('Pleas enter new filter name','Rename filter',1,{SpectralData.Filter(Sel).Name});
        if ~isempty(Name)
            SpectralData.Filter(Sel).Name = Name{1};
            h.Filter_List.String{Sel} = Name{1};
            h.PlottedData.String{Sel} = Name{1};
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions for the interaction with the filter list
function Species_Callback(obj, e)
h = guidata(findobj('Tag','SpectralImage'));
global SpectralData

event = 'nothing';
%%% Determine action
switch e.EventName
    case 'KeyPress' %%% key was pressed
        switch e.Key
            case {'delete' 'backspace'} %%% delete species
                event = 'delete';
            case 'r'
                event = 'rename'; %%% rename species
            case 'f'
                event = 'filters'; %%% calculates filters
        end
end

%%% Execute action
switch event
    case 'nothing'
        return;
    case 'delete' %%% Deletes species
        %%% Selected entries
        Sel = obj.Value;
        
        %%% ignores the first entry
        Sel(Sel==1)=[];
        
        %%% Stops if ony first was selected
        if isempty(Sel)
            return;
        end
        
        %%% Deletes all associated filters
        Filter = [];
        for i = 1:numel(SpectralData.Filter)
            if ~isempty(intersect(SpectralData.Filter(i).Species,Sel))
                Filter = [Filter i];
            end
        end
        if ~isempty(Filter)
            evt.EventName = 'KeyPress' ;
            evt.Selected = Filter;
            evt.Key = 'delete';
            Filter_Callback(h.Filter_List, evt)
        end
        
        
        %%% Deletes filter
        SpectralData.Species(Sel) = [];
        %%% Removes species from list
        obj.String(Sel) = [];
        %%% Deletes species plots
        for i = Sel
            if numel(h.SpeciesPlots) >= i && isvalid(h.SpeciesPlots{i})
                delete(h.SpeciesPlots{i});
            end
            if numel(h.SpeciesPhasor) >= i && isvalid(h.SpeciesPhasor{i})
                delete(h.SpeciesPhasor{i});
            end
        end
        %%% Removes deleted plots
        for i= numel(h.SpeciesPlots):-1:1
            if ~isvalid(h.SpeciesPlots{i})
                h.SpeciesPlots(i)=[];
            end
        end
        for i= numel(h.SpeciesPhasor):-1:1
            if ~isvalid(h.SpeciesPhasor{i})
                h.SpeciesPhasor(i)=[];
            end
        end
        guidata(h.SpectralImage,h);
        
        %%% Sets list selection to first
        obj.Value = 1;
        Plot_Spectral([],[],2);
    case 'rename' %%% Renames species
        Sel = obj.Value;
        %%% ignores the first entry
        Sel(Sel==1)=[];
        %%% only applies to first selected entry
        Sel = Sel(1);
        
        Name = inputdlg('Pleas enter new species name','Rename species',1,{SpectralData.Species(Sel).Name});
        if ~isempty(Name)
            SpectralData.Species(Sel).Name = Name{1};
            h.Species_List.String{Sel} = Name{1};
        end
    case 'filters' %%% Calculates new filters
        Calc_Filter([],[],2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for creating new filters
function Filter = Calc_Filter(~,~,mode,Sel,Spectrum)

global SpectralData
switch mode
    case 1 %%% Create a simple rectangular filter based on the imput
        h = guidata(findobj('Tag','SpectralImage'));
        %%% Bins to be used
        Bins = round(str2num(h.Simple_Range.String));
        %%% Removes invalid bins
        Bins(Bins<0 | Bins > numel(SpectralData.Filter(1).Data)) = [];
        
        %%% Creates new empty filter
        SpectralData.Filter(end+1).Data = zeros(1,1,numel(SpectralData.Filter(1).Data),1);
        %%% Set bins to 1
        SpectralData.Filter(end).Data(Bins) = 1;
        %%% Creates name for filter
        SpectralData.Filter(end).Name = ['Simple_' num2str(min(Bins)) 'to' num2str(max(Bins))];
        SpectralData.Filter(end).Species = 1;
        
        h.Filter_List.String{end+1} = SpectralData.Filter(end).Name;
        h.PlottedData.String{end+1} = SpectralData.Filter(end).Name;
        
        Plot_Spectral([],[],[1 3]);
    case 2 %%% calculate filter for current data
        h = guidata(findobj('Tag','SpectralImage'));
        %%% Take input species or selected
        if ~exist('Sel','var') || isempty(Sel)
            New = 1;
            Sel = h.Species_List.Value;
        else
            New = 0;
        end
        %%% Stop, if only one species is selected
        if numel(Sel)<2
            return;
        end
        
        %%% Calculates summed up spectrum of current data
        Spectrum = squeeze(sum(sum(double(sum(SpectralData.Data,4)),2),1));
        
        diag_Spectrum = zeros(numel(Spectrum));
        for i = 1:numel(Spectrum)
            diag_Spectrum(i,i) = 1./Spectrum(i);
        end
        %%% Sets no-photon bins to 0
        diag_Spectrum(isinf(diag_Spectrum)) = 0;
        
        Species = [];
        for i = Sel
            Species = [Species, squeeze(SpectralData.Species(i).Data./sum(SpectralData.Species(i).Data))]; % re-normalize here just in case
        end
        Filter = ((Species'*diag_Spectrum*Species)^(-1)*Species'*diag_Spectrum)';
        Filter(isinf(Filter)) = 0;
        
        if New %%% Updates data of old filters or creates new filters
            for i=1:numel(Sel)
                SpectralData.Filter(end+1).Data(1,1,:,1) = Filter(:,i);
                SpectralData.Filter(end).Name = SpectralData.Species(Sel(i)).Name;
                SpectralData.Filter(end).Species = [Sel(i) Sel(Sel~=Sel(i))];
                h.Filter_List.String{end+1} = SpectralData.Filter(end).Name;
                h.PlottedData.String{end+1} = SpectralData.Filter(end).Name;
            end
        else
            SpectralData.Filter(h.Filter_List.Value).Data(1,1,:,1) = Filter(:,1);
        end
    case 3 %%% Spatially resolved filter calculation
        
        %%% Calculates summed up spectrum of current data
        diag_Spectrum = zeros(numel(Spectrum));
        for i = 1:numel(Spectrum)
            diag_Spectrum(i,i) = 1./Spectrum(i);
        end
        %%% Sets no-photon bins to 0
        diag_Spectrum(isinf(diag_Spectrum)) = 0;
        
        Species = [];
        for i = Sel
            Species = [Species, squeeze(SpectralData.Species(i).Data./sum(SpectralData.Species(i).Data))]; % re-normalize here just in case
        end
        Filter = ((Species'*diag_Spectrum*Species)^(-1)*Species'*diag_Spectrum)';
        Filter(isinf(Filter)) = 0;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Phasor Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to recalculate phasor histogram
function Calculate_Phasor(~,~)
global SpectralData
h = guidata(findobj('Tag','SpectralImage'));

%%% Extracts threshold
TH(1) = str2double(h.Phasor_TH{1}.String);
TH(2) = str2double(h.Phasor_TH{2}.String);

%%% Calculates and normalizes phasor data
G = reshape(cos(2*pi*(1:size(SpectralData.Data,3))/size(SpectralData.Data,3)),1,1,[]);
S = reshape(sin(2*pi*(1:size(SpectralData.Data,3))/size(SpectralData.Data,3)),1,1,[]);
SpectralData.G = sum(double(sum(SpectralData.Data,4)).*repmat(G,size(SpectralData.Data,1),size(SpectralData.Data,2),1),3);
SpectralData.G = SpectralData.G./SpectralData.Int;
SpectralData.S = sum(double(sum(SpectralData.Data,4)).*repmat(S,size(SpectralData.Data,1),size(SpectralData.Data,2),1),3);
SpectralData.S = SpectralData.S./SpectralData.Int;

%%% Applies threshold
Use = SpectralData.Int>=TH(1);
if TH(2)>0 && TH(2)>TH(1)
    Use = Use & SpectralData.Int<=TH(2);
end
G = SpectralData.G(Use);
S = SpectralData.S(Use);

%%% Creates histogram
SpectralData.Phasor = reshape(histcounts(floor((G+1)*100)*200 + (S+1)*100,linspace(0,40000,40001)),200,200);

%%% ROIs selected
SpectralData.PhasorROI=zeros(size(SpectralData.Int,1),size(SpectralData.Int,2),6);
for i=1:6
    if strcmp(h.Phasor_ROI(i,1).Visible,'on')
        Pos=h.Phasor_ROI(i,1).Position;
        %%% Generates ROI map
        SpectralData.PhasorROI(:,:,i)= SpectralData.G>=Pos(1) &...
            SpectralData.G<=(Pos(1)+Pos(3)) &...
            SpectralData.S>=Pos(2) &...
            SpectralData.S<=(Pos(2)+Pos(4)) &...
            Use;
        
    elseif strcmp(h.Phasor_ROI(i,2).Visible,'on')
        %%% Determins position of ROI
        x=round(100*(h.Phasor_ROI(i,2).XData+1));
        y=round(100*(h.Phasor_ROI(i,2).YData+1));
        x(x<1)=1; y(y<1)=1;
        Map=zeros(200);
        %%% Transforms ROI position into pixelmap
        Map(sub2ind(size(Map),x,y))=1;
        %%% Fills ROI pixelmap
        Map=mod(cumsum(Map),2);
        %%% Finds valid pixel
        G=round((SpectralData.G+1)*100);
        G(isnan(G) | G<1)=1;
        S=round((SpectralData.S+1)*100);
        S(isnan(S) | S<1)=1;
        
        Index=sub2ind(size(Map),G,S);
        %%% Generates ROI map
        SpectralData.PhasorROI(:,:,i) = Map(Index) & Use;
    end
end

%%% Plots phasor
Plot_Spectral([],[],[1 4]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions for phasor plot mouse-clicks
function Phasor_Click(~,~,Key)
h=guidata(findobj('Tag','SpectralImage'));

%%% Checks, which mouse button was clicked
Type=h.SpectralImage.SelectionType;
if isempty(Key)
    %% Normal mouse clicks
    switch Type
        case 'normal' %%% Left mouse button
            %% Pans plot while holding left mouse button
            %%% Gets starting position
            Pos=h.Phasor_Plot.CurrentPoint;
            %%% Disables further mouse click callbacks
            h.Phasor_Plot.ButtonDownFcn=[];
            %%% Changes mouse move callback to panning
            h.SpectralImage.WindowButtonMotionFcn={@Phasor_Move,2,Pos(1,1:2),[]};
        case 'extend' %%% Middle mouse button\ left+right mouse buttons
            %% Resets limits by pressing middle mouse button
            h.Phasor_Plot.XLim=[-1.01 1.01];
            h.Phasor_Plot.YLim=[-1.01 1.01];
    end
elseif Key>0 && Key <=6
    %% ROI selection mouse clicks
    switch Type
        case 'normal' %%% Rectangular ROI selection
            h.Phasor_ROI(Key,1).Position=[h.Phasor_Plot.CurrentPoint(1,1:2) 0 0];
            [h.Phasor_ROI(Key,:).Visible] = deal('off');
            h.SpectralImage.WindowButtonMotionFcn={@Phasor_Move,4,h.Phasor_Plot.CurrentPoint(1,1:2),Key};
        case 'alt' %%% Ellipsoid ROI
            [h.Phasor_ROI(Key,:).Visible] = deal('off');
            h.SpectralImage.WindowButtonMotionFcn={@Phasor_Move,5,h.Phasor_Plot.CurrentPoint(1,1:2),Key};
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions for phasor plot mouse movement
function Phasor_Move(~,e,mode,Start,Key)
%%% Only executes, if Phasor is the current figure
Fig = gcf;
if strcmp('SpectralImage',get(Fig,'Tag'))
    h=guidata(Fig);
    Pos=h.Phasor_Plot.CurrentPoint(1,1:2);
    switch mode
        case 2 %%% Pans the plot around (hold left mouse button)
            h.Phasor_Plot.XLim=h.Phasor_Plot.XLim-(Pos(1)-Start(1));
            h.Phasor_Plot.YLim=h.Phasor_Plot.YLim-(Pos(2)-Start(2));
            pause(0.01);
        case 3 %%% Zooms (via mouse scroll
            %%% Calculates current cursor position relative to limits
            XLim=h.Phasor_Plot.XLim;
            YLim=h.Phasor_Plot.YLim;
            %%% Only ecexutes inside plot bounds
            if (Pos(1)>XLim(1) && Pos(1)<XLim(2) && Pos(2)>YLim(1) && Pos(2)<YLim(2))
                %%% Zooms in by sqrt(2)
                if e.VerticalScrollCount<0
                    h.Phasor_Plot.XLim=[mean(XLim)-diff(XLim)/sqrt(8),mean(XLim)+diff(XLim)/sqrt(8)];
                    h.Phasor_Plot.YLim=[mean(YLim)-diff(YLim)/sqrt(8),mean(YLim)+diff(YLim)/sqrt(8)];
                    %%% Zooms out by sqrt(2)
                elseif e.VerticalScrollCount>0
                    h.Phasor_Plot.XLim=[mean(XLim)-diff(XLim)/sqrt(2),mean(XLim)+diff(XLim)/sqrt(2)];
                    h.Phasor_Plot.YLim=[mean(YLim)-diff(YLim)/sqrt(2),mean(YLim)+diff(YLim)/sqrt(2)];
                end
            end
        case 4 %%% Generates a rectangular ROI
            %%% Disables callback, to avoit multiple executions
            h.SpectralImage.WindowButtonMotionFcn=[];
            %%% Resizes ROI rectangle
            h.Phasor_ROI(Key,1).Position=[min([Start(1) Pos(1)]),min([Start(2) Pos(2)]),abs(Start(1)-Pos(1)),abs(Start(2)-Pos(2))];
            
            %%% Make ROI rectangle visible
            if all(h.Phasor_ROI(Key,1).Position(3:4)>0)
                h.Phasor_ROI(Key,1).Visible='on';
            else
                h.Phasor_ROI(Key,1).Visible='off';
            end
            %%% Enables callback
            h.SpectralImage.WindowButtonMotionFcn={@Phasor_Move,4,Start,Key};
        case 5 %%% Generates a elliposidal ROI
            %%% Disables callback, to avoit multiple executions
            h.SpectralImage.WindowButtonMotionFcn=[];
            %%% Ony executes, if mouse moved
            if all((Pos-Start)~=0)
                
                Pixel=100;
                Width=0.1;
                
                %%% Generates vector, connecting start and end
                x1=linspace(Start(1),Pos(1),Pixel);
                y1=linspace(Start(2),Pos(2),Pixel);
                
                %%% Creates circle
                x=cos(2*pi*(0:0.01:1));
                y=sin(2*pi*(0:0.01:1));
                x2=[];y2=[];
                
                %%% Applies circle around each point on line
                for i=1:Pixel
                    x2(end+1:end+numel(x))=round(Pixel*(Width*x+x1(i)));
                    y2(end+1:end+numel(y))=round(Pixel*(Width*y+y1(i)));
                end
                %%% Transforms points to integers
                Xmin=min(x2)-1; x2=x2-Xmin;
                Ymin=min(y2)-1; y2=y2-Ymin;
                %%% Draws circles into a pixelmap
                Map1=zeros(max(x2),max(y2));
                Map1(sub2ind(size(Map1),x2,y2))=1;
                %%% Only uses edgepoints in map
                Map2=zeros(size(Map1));
                for j=1:size(Map1,2)
                    Map2(find(Map1(:,j),1,'first'),j)=1;
                    Map2(find(Map1(:,j),1,'last'),j)=1;
                end
                %%% Transforms pixelmat to coordinates
                [x,y]=find(Map2);
                %%% Shifts coordinates to right position
                x=(x+Xmin)/Pixel;
                y=(y+Ymin)/Pixel;
                %%% Updates ROI object
                h.Phasor_ROI(Key,2).XData=[x(1:2:end); flipud(x(2:2:end)); x(1)];
                h.Phasor_ROI(Key,2).YData=[y(1:2:end); flipud(y(2:2:end)); y(1)];
                h.Phasor_ROI(Key,2).UserData = [Start, Pos];
                %%% Makes ROI visible
                h.Phasor_ROI(Key,2).Visible='on';
            else
                %%% Hides ROI, if no ROI was selected
                h.Phasor_ROI(Key,2).Visible='off';
            end
            %%% Enables callback
            h.SpectralImage.WindowButtonMotionFcn={@Phasor_Move,5,Start,Key};
            
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions for phasor plot mouse clicks
function Phasor_Key(~,e,mode)
h=guidata(findobj('Tag','SpectralImage'));
global SpectralData
switch mode
    case 1
        %% Key press callback
        %%% Makes numpad and normal number keys equal
        if ~isempty(strfind(e.Key,'numpad'))
            Key=str2double(e.Key(7:end));
        else
            Key=str2double(e.Key);
        end
        %%% Checks, if keys 0-6 were pressed
        if ~isnan(Key) && Key<=6 && Key>=0
            %%% Defines key release callback to stop
            h.SpectralImage.KeyReleaseFcn={@Phasor_Key,2};
            %%% Disables further key press callbacks
            h.SpectralImage.KeyPressFcn=[];
            %%% Changes cursor shape
            if Key~=0
                h.SpectralImage.Pointer='custom';
                h.SpectralImage.PointerShapeCData=SpectralData.Cursor{Key};
                h.Phasor_Plot.ButtonDownFcn={@Phasor_Click,Key};
            else
                h.Phasor.Pointer='crosshair';
                h.Phasor_Plot.ButtonDownFcn={@Phasor_Click,Key};
            end
        end
        
    otherwise
        %% Key Release callback
        h.SpectralImage.KeyReleaseFcn=[];
        h.SpectralImage.KeyPressFcn={@Phasor_Key,1};
        h.SpectralImage.Pointer='arrow';
        h.Phasor_Plot.ButtonDownFcn={@Phasor_Click,[]};
        Calculate_Phasor;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Mouse button release callback %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Stop_All(~,~)
Fig = findobj('Tag','SpectralImage');
figure(Fig);
h=guidata(Fig);
%%% Sets standard mouse click callback (in case it was changed/disabled)
h.Phasor_Plot.ButtonDownFcn={@Phasor_Click,[]};
%%% Updates plot, if new ROI was selected
if ~isempty(h.SpectralImage.WindowButtonMotionFcn)
    h.SpectralImage.Pointer='arrow';
    h.SpectralImage.WindowButtonMotionFcn={};
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Filter Exporting Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that applies filters and saves the data
function Save_Filtered (~,~,mode)
h = guidata(findobj('Tag','SpectralImage'));
global SpectralData UserValues

Sel = h.Filter_List.Value;
Path = uigetdir(SpectralData.Path, 'Select folder to save filtered TIFFs');
if all(Path==0)
    return;
end

%%% Updates Progressbar
h.Spectral_Progress_Axes.Color = [1 0 0];
h.Spectral_Progress_Text.String = 'Saving Filtered Data';
drawnow;

for i=1:numel(Sel)
    %% Calculates the filtered data
    Full = uint16(squeeze(sum(SpectralData.Data,3)));
    
    switch mode
        case 1 %%% Apply uniform filters
            %%% Applies filter
            Filter = single(SpectralData.Filter(Sel(i)).Data);
            Stack = single(SpectralData.Data) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, size(SpectralData.Data,4));
            Stack = squeeze(sum(Stack,3));
        case 2 %%% Apply pixel-by pixel filters
            %%% Initializes data cells
            Stack = zeros(size(SpectralData.Data,1),size(SpectralData.Data,2),size(SpectralData.Data,4));
            
            %%% Checks, if simple filter was used
            if numel(SpectralData.Filter(Sel(i)).Species)>1
                %%% Summs up all frames
                Data = double(sum(SpectralData.Data,4));
                
                %%% Applies spatial averaging to the data
                if h.Spatial_Average_Type.Value >1 && str2double(h.Spatial_Average_Size.String)>1
                    switch h.Spatial_Average_Type.Value
                        case 2 %%% Moving average
                            F = fspecial('average',round(str2double(h.Spatial_Average_Size.String)));
                        case 3 %%% Gaussian
                            F = fspecial('gaussian',round(str2double(h.Spatial_Average_Size.String))*2,round(str2double(h.Spatial_Average_Size.String)));
                        case 4 %%% Disk
                            F = fspecial('disk',round(str2double(h.Spatial_Average_Size.String)));
                    end
                    Data = imfilter(Data,F,'replicate');
                end
                
                %%% Recalculates filter for each line
                %%% This calculates the filters for each filter, although
                %%% each one is used at least twice.
                %%% I will try to remove this redundancy at some point
                for j=1:size(SpectralData.Data,1)
                    for k=1:size(SpectralData.Data,2)
                        Filter = Calc_Filter([],[],3,SpectralData.Filter(Sel(i)).Species,squeeze(Data(j,k,:)));
                        Filter = reshape(Filter(:,1),1,1,[],1);
                        Stack(j,k,:) = squeeze(sum(double(SpectralData.Data(j,k,:,:)) .* repmat(Filter,[1,1,1,size(Stack,3)]),3));
                    end
                end
                
            else %%% Applies homogeneous filter, if a simple filter was used
                Filter = SpectralData.Filter(Sel(i)).Data;
                Stack = single(SpectralData.Data) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, size(SpectralData.Data,4));
                Stack = squeeze(sum(Stack,3));
            end
        case 3 %%% Applies phasor ROI based filtering
            %%% Initializes data cells
            Stack = zeros(size(SpectralData.Data,1),size(SpectralData.Data,2),size(SpectralData.Data,4));
            
            %%% Checks, if simple filter was used
            if numel(SpectralData.Filter(Sel(i)).Species)>1
                %%% Summs up all frames
                Data = squeeze(double(sum(SpectralData.Data,4)));
                
                %%% Recalculates filter for each ROI
                %%% This calculates the filters for each filter, although
                %%% each one is used at least twice.
                %%% I will try to remove this redundancy at some point
                for j=1:6
                    if any(any(SpectralData.PhasorROI(:,:,j)>0))
                        %%% Applies ROI to Data
                        ROI = Data.*repmat(SpectralData.PhasorROI(:,:,j),1,1,size(SpectralData.Data,3));
                        ROI = squeeze(sum(sum(ROI,1),2));
                        
                        if numel(SpectralData.Filter(Sel(i)).Species)==1 && SpectralData.Filter(Sel(i)).Species ==1
                            %%% Simple filter was used
                            Filter = SpectralData.Filter(Sel(i)).Filter;
                        else
                            %%% Complex filter is recalculated for the data
                            Filter = Calc_Filter([],[],3,SpectralData.Filter(Sel(i)).Species,ROI);
                            Filter = reshape(Filter(:,1),1,1,[],1);
                        end
                        
                        Stack = Stack +... %%% Sumas up to average overlap
                            squeeze(sum(...
                            single(SpectralData.Data)... %%% Data
                            .* repmat(Filter,[size(Data,1),size(Data,2),1,size(Stack,3)])... %%% Filter
                            .* repmat(SpectralData.PhasorROI(:,:,j),[1,1,size(Filter,3),size(Stack,3)]),3)); %%% ROI
                    end
                end
                %%% Averages ROI overlap
                Stack = Stack ./ repmat(sum(SpectralData.PhasorROI,3),1,1,size(Stack,3));
                %%% Sets pixels outside of ROIs to zero
                Stack(isinf(Stack) | isnan(Stack)) = 0;
            end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Saves the data
    
    %%% Rescales and reshapes weighed stack
    Min = min(Stack(:));
    Max = max(Stack(:));
    Stack=uint16((Stack-Min)./(Max-Min)*2^16);
    
    %%% Adjusts filename
    switch mode
        case 1
            File=fullfile(Path,[SpectralData.FileName(1:end-4) '_' SpectralData.Filter(Sel(i)).Name '.tif']);
        case 2
            File=fullfile(Path,[SpectralData.FileName(1:end-4) '_' SpectralData.Filter(Sel(i)).Name '_SR.tif']);
        case 3
            File=fullfile(Path,[SpectralData.FileName(1:end-4) '_' SpectralData.Filter(Sel(i)).Name '_ROI.tif']);
    end
    
    %%% Creates info data
    Tagstruct.ImageLength = size(Stack,2);
    Tagstruct.ImageWidth = size(Stack,1);
    Tagstruct.Compression = 5; %1==None; 5==LZW
    Tagstruct.SampleFormat = 1; %UInt
    Tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    Tagstruct.BitsPerSample =  16;                        %32= float data, 16= Andor standard sampling
    Tagstruct.SamplesPerPixel = 1;
    Tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    
    %%% Write image information into TIFF header
    if isempty (SpectralData.Meta)
        Tagstruct.ImageDescription = ['Type: ' '10' '\n',...
            'FrameTime [s]: 0.1 \n',...
            'LineTime [ms]: 1 \n',...
            'PixelTime [us]: 10 \n',...
            'PixelSize [nm]: 50 \n',...
            'RLICS_Scale: ' num2str(Max-Min) '\n',...
            'RLICS_Offset: ' num2str(Min) '\n'];
    else
        Tagstruct.ImageDescription = ['Type: ' '10' '\n',...
            'FrameTime [s]: ' SpectralData.Meta.Frame '\n',...
            'LineTime [ms]: ' SpectralData.Meta.Line '\n',...
            'PixelTime [us]: ' SpectralData.Meta.Pixel '\n',...
            'PixelSize [nm]: ' SpectralData.Meta.Size '\n',...
            'RLICS_Scale: ' num2str(Max-Min) '\n',...
            'RLICS_Offset: ' num2str(Min) '\n'];        
    end
    
    TIFF_handle = Tiff(File, 'w');
    TIFF_handle.setTag(Tagstruct);
    
    %%% Writes unfilterd data to the first frames
    for j=1:size(Full,3)
        TIFF_handle.write(Full(:,:,j));
        TIFF_handle.writeDirectory();
        TIFF_handle.setTag(Tagstruct);
    end
    
    %%% Writes filtered data to the last frames
    for j=1:size(Stack,3)
        TIFF_handle.write(Stack(:,:,j));
        if j<size(Stack,3)
            TIFF_handle.writeDirectory();
            TIFF_handle.setTag(Tagstruct);
        end
    end
    TIFF_handle.close()
    
end

h.Spectral_Progress_Axes.Color = UserValues.Look.Control;
h.Spectral_Progress_Text.String = SpectralData.FileName;
drawnow;






