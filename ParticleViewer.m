function ParticleViewer()
global UserValues
h.ParticleViewer=findobj('Tag','ParticleViewer');
addpath(genpath(['.' filesep 'functions']));
if ~isempty(h.ParticleViewer) % Creates new figure, if none exists
    figure(h.ParticleViewer);
    return
end
%%% Loads user profile
LSUserValues(0);
%%% Localize appearance data (to save typing)
Look=UserValues.Look;

%% Main Window
h.ParticleViewer = figure(...
    'Units','normalized',...
    'Tag','ParticleViewer',...
    'Name','Phasor Particle Viewer',...
    'NumberTitle','off',...
    'Menu','none',...
    'defaultUicontrolFontName',Look.Font,...
    'defaultAxesFontName',Look.Font,...
    'defaultTextFontName',Look.Font,...
    'defaultAxesXColor',Look.Fore,...    
    'defaultAxesYColor',Look.Fore,...
    'Toolbar','figure',...
    'UserData',[],...
    'BusyAction','cancel',...
    'OuterPosition',[0.01 0.01 0.98 0.98],...
    'CloseRequestFcn', @CloseWindow,...
    'Visible','on');
%%% Sets background of axes and other things
whitebg(Look.Axes);
%%% Changes background; must be called after whitebg
h.ParticleViewer.Color=Look.Back;
%%% Remove unneeded items from toolbar
toolbar = findall(h.ParticleViewer,'Type','uitoolbar');
toolbar_items = findall(toolbar);
delete(toolbar_items([2:7 9 13:17]));

h.Load_Particle_Data = uimenu(...
    'Parent',h.ParticleViewer,...
    'Label','Load Particle Data',...
    'Callback',{@Load_Data, 1});
h.Load_Phasor_Data = uimenu(...
    'Parent',h.ParticleViewer,...
    'Label','Load Phasor Data',...
    'Callback',{@Load_Data, 2});

%%% Particle display plot
h.Particle_Display = axes(...
    'Parent',h.ParticleViewer,...
    'Units','normalized',...
    'Position',[0.01 0.32 0.33 0.66]);
h.Particle_Display_Image = image(zeros(1,1,3));
h.Particle_Display.DataAspectRatio = [1 1 1];
h.Particle_Display.XTick = [];
h.Particle_Display.YTick = [];

%%% Top display plot
h.Particle_Plot1 = axes(...
    'Parent',h.ParticleViewer,...
    'Units','normalized',...
    'Position',[0.38 0.69 0.29 0.28]);
%h.Particle_Plot1.XLabel.String = 'Frame';
h.Particle_Plot1.YLabel.String = 'Intensity (counts)';
h.Particle_Plot1.XColor = Look.Fore;
h.Particle_Plot1.YColor = Look.Fore;

%%% Bottom display plot
h.Particle_Plot2 = axes(...
    'Parent',h.ParticleViewer,...
    'Units','normalized',...
    'Position',[0.38 0.36 0.29 0.28]);
h.Particle_Plot2.XLabel.String = 'Frame';
h.Particle_Plot2.YLabel.String = 'Lifetime (ns)';
h.Particle_Plot2.XColor = Look.Fore;
h.Particle_Plot2.YColor = Look.Fore;

%%% Right display plot
h.Particle_Plot3 = axes(...
    'Parent',h.ParticleViewer,...
    'Units','normalized',...
    'XColor', Look.Fore,...
    'YColor', Look.Fore,...
    'Position',[0.72 0.36 0.27 0.63]);
h.Particle_Plot3.DataAspectRatio = [1 1 1];

%% Plot display selection
h.Particle_Plot1_Type = uicontrol(...
    'Parent',h.ParticleViewer,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Num, 1},...
    'Position',[0.57 0.85 , 0.1 0.12],...
    'String',{'TauP', 'TauM', 'Mean Lifetime', 'Intensity'},...
    'Value', 4);
%%% Plot display selection
h.Particle_Plot2_Type = uicontrol(...
    'Parent',h.ParticleViewer,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Num, 1},...
    'Position',[0.57 0.52 , 0.1 0.12],...
    'String',{'TauP', 'TauM', 'Mean Lifetime', 'Intensity'},...
    'Value', 3);

%%% Plot display selection
h.Particle_Plot3_Type = uicontrol(...
    'Parent',h.ParticleViewer,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Num, 1},...
    'Position',[0.8 0.22 , 0.12 0.12],...
    'String',{'Position', 'Phasor', 'Lifetime vs Intensity', 'LF vs Int (All Particles'},...
    'Value', 1);

h.Text = {};

%% Plot control panel
h.Plot_Control_Panel = uibuttongroup(...
    'Parent',h.ParticleViewer,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.01 0.01 0.33 0.29]);
%%% Frame
h.Text{end+1} = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.86, 0.12 0.12],...
    'String','Frame:');
%%% Editbox for frame
h.Particle_Frame = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame, 1},...
    'Position',[0.15 0.86, 0.1 0.12],...
    'String','1');
%%% Frame slider
h.Particle_FrameSlider = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame, 2},...
    'Position',[0.27 0.86, 0.25 0.12]);

%%% Autoscale
h.Particle_ManualScale = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame, 1},...
    'Value',0,...
    'Position',[0.02 0.72, 0.25 0.12],...
    'String','Manual Scale:');
%%% Min Scale
h.Particle_ScaleMin = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame, 1},...
    'Position',[0.32 0.72, 0.1 0.12],...
    'String','0');
%%% Max Scale
h.Particle_ScaleMax = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame, 1},...
    'Position',[0.43 0.72, 0.1 0.12],...
    'String','100');

%%% Show Particle Label
h.Particle_ShowLabel = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Callback',{@Particle_Frame, 1},...
    'Value',0,...
    'Position',[0.02 0.58, 0.45 0.12],...
    'String','Show Particle Labels');
h.Text{end+1} = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Position',[0.06 0.44, 0.22 0.12],...
    'String','Label Offset:');
h.Particle_LabelXOffset = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame, 1},...
    'Position',[0.32 0.44, 0.1 0.12],...
    'String','5');
h.Particle_LabelYOffset = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame, 1},...
    'Position',[0.43 0.44, 0.1 0.12],...
    'String','0');

%%% Min trace length to show label
h.Text{end+1} = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Position',[0.06 0.30, 0.26 0.12],...
    'String','Min trace length:');
h.Particle_LabelMin = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame, 1},...
    'Position',[0.32 0.30, 0.1 0.12],...
    'String','0');
h.Text{end+1} = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Position',[0.43 0.30, 0.12 0.12],...
    'String','frames');

%%% Display type selection
h.Particle_Display_Type = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame, 1},...
    'Position',[0.57 0.87 , 0.4 0.12],...
    'String',{  'Mask only',...
    'Mask overlay',...
    'Mask gray/red',...
    'Mask magenta/green'});

%%% Controls for exporting image plot
h.Particle_Export = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback', @Extract_Particle_Phasor,...
    'String', 'Re-extract Phasors',...
    'TooltipString', ['Re-extract particlewise phasor data from '...
          'currently loaded framewise phasor data'],...
    'Position',[0.57 0.71, 0.38 0.14]);

%%% Controls for exporting image plot
h.Particle_Export = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback', @Export_TIFF,...
    'String', 'Export as TIFF',...
    'Position',[0.01 0.02, 0.32 0.14]);
%%% Frame range for export
h.Text{end+1} = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.34 0.02, 0.14 0.12],...
    'String','Frames:');
h.Particle_Frames_Start = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','1',...
    'Position',[0.48 0.02, 0.1 0.12]);
h.Particle_Frames_Stop = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','999',...
    'Position',[0.59 0.02, 0.1 0.12]);


%% Particle control panel
h.Particle_Control_Panel = uibuttongroup(...
    'Parent',h.ParticleViewer,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.35 0.01 0.34 0.29]);
%%% Text: Particle number
h.Text{end+1} = uicontrol(...
    'Parent',h.Particle_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Position',[0.02 0.86, 0.12 0.12],...
    'String','Particle:');
%%% Editbox for particle number
h.Particle_PartNumber = uicontrol(...
    'Parent',h.Particle_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Num, 1},...
    'Position',[0.15 0.86, 0.12 0.12],...
    'String','1');
%%% Particle slider
h.Particle_PartSlider = uicontrol(...
    'Parent',h.Particle_Control_Panel,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Num, 2},...
    'Position',[0.29 0.86, 0.35 0.12]);
%%% Moving average
h.Particle_MovingAverage = uicontrol(...
    'Parent',h.Particle_Control_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Num, 1},...
    'Value',0,...
    'Position',[0.02 0.72, 0.28 0.12],...
    'String','Moving Average:');
h.Particle_MovAvgWindow = uicontrol(...
    'Parent',h.Particle_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Num, 1},...
    'Position',[0.3 0.72, 0.1 0.12],...
    'String','15');
h.Text{end+1} = uicontrol(...
    'Parent',h.Particle_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment','left',...
    'Position',[0.41 0.72, 0.1 0.12],...
    'String','frames');

%%% Checkbox to highlight particle on image plot
h.Particle_Highlight = uicontrol(...
    'Parent',h.Particle_Control_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame, 1},...
    'Value',0,...
    'Position',[0.02 0.58, 0.28 0.12],...
    'String','Highlight Particle');

%% Controls for exporting traces
%%% Export settings table
TableData = {1, 0, 5, 30, 1.8, 3.0};
ColumnNames = {'Submovie [fr]', 'Break [s]',...
    'Frame Time [s]', 'Threshold [fr]',...
    'LF_min [ns]', 'LF_max [ns]'};
ColumnWidth = {85,85,85,85,76,76};
RowNames = [];
h.Particle_Export_Settings = uitable(...
    'Parent',h.Particle_Control_Panel,...
    'Units','normalized',...
    'FontSize',11,...
    'Position',[0.01 0.01 0.98 0.24],...
    'Data',TableData,...
    'ColumnName',ColumnNames,...
    'RowName',RowNames,...
    'ColumnEditable', true,...
    'ColumnWidth',ColumnWidth);

%%% Checkbox to export individual traces
h.Particle_WriteTraces = uicontrol(...
    'Parent',h.Particle_Control_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Value',0,...
    'Position',[0.3 0.26, 0.5 0.12],...
    'String','Plot and Save Individual Traces');
h.Particle_Export = uicontrol(...
    'Parent',h.Particle_Control_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback', @Export,...
    'String', 'Export Traces',...
    'Position',[0.01 0.26, 0.28 0.14]);

%% Stores Info in guidata
guidata(h.ParticleViewer,h);

end

%%% Main Plot Update Function%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotUpdate(Frame)
h = guidata(findobj('Tag','ParticleViewer'));
global PhasorViewer ParticleViewer
if isempty(ParticleViewer)
    return
end

%Update plot
Mask = ParticleViewer.Mask(:,:,Frame);
if isfield(PhasorViewer, 'Intensity')
    Int = PhasorViewer.Intensity(:,:,Frame);
else
    Int = zeros(size(Mask));
end

%%% Adjusts to range
if h.Particle_ManualScale.Value
    Min = str2double(h.Particle_ScaleMin.String); Int(Int < Min)= Min;
    Max = str2double(h.Particle_ScaleMax.String); Int(Int > Max)= Max;
else
    Min = min(Int(:));
    Max = max(Int(:));
end

switch h.Particle_Display_Type.Value
    case 1 %%% Mask only
        Image = zeros(size(Mask,1),size(Mask,2),3);
        Image(:,:,1)=Mask;
    case 2 %%% Mask overlay           
        %%% Grayscale Image with red homogeneous particles
        Image=(Int-Min)/(Max-Min).*~Mask;
        Image = repmat(Image,[1 1 3]);
        Image(Mask) = 1;

    case 3 %%% Mask gray/red               
        %%% Grayscale Image with red scaled particles
        Int=(Int-Min)/(Max-Min);
        Image = Int.*~Mask;
        Image = repmat(Image,[1 1 3]);
        Image(Mask) = Int(Mask);
    case 4 %%% Mask magenta/green
        %%% Scales Intensity image
        Int=(Int-Min)/(Max-Min);

        %%% Green scaled Image with red scaled particles              
        Image = repmat(Int.*Mask,[1 1 3]);
        Image(:,:,2) = Int.*~Mask;

%     case 5 %%% Particles only
%         %%% Particles colored with jet
%         Color = [0,0,0; jet(max(Particle(:)))];
%         Image=reshape(Color(Particle+1,:),size(Int,1),size(Int,2),3);
%     case 6 %%% Particles overlay
%         %%% Scales Intensity image
%         Int=(Int-Min)/(Max-Min);
%         %%% Sets particles to homogeneous jet color
%         Color = [0,0,0; jet(max(Particle(:)))];
%         Image=reshape(Color(Particle+1,:),size(Int,1),size(Int,2),3);
%         %%% Sets non-particles to grayscale
%         Image = repmat(Int.*~Particle,[1 1 3])+Image;
% 
%     case 7 %%% Particles gray/jet
%         %%% Scales Intensity image
%         Int=(Int-Min)/(Max-Min);
%         %%% Sets particles to scaled jet and rest to gray scale
%         Color = [1 1 1 ; jet(max(Particle(:)))];
%         Image=reshape(Color(Particle+1,:),size(Int,1),size(Int,2),3).*repmat(Int,[1 1 3]);
end

%Update plot
h.Particle_Display_Image.CData = Image;

%plot particle label

%Clear previous labels
delete(findobj(h.Particle_Display.Children, 'type', 'text'));
delete(findobj(h.Particle_Display.Children, 'type', 'line'));

if h.Particle_ShowLabel.Value
    XOffset = str2double(h.Particle_LabelXOffset.String);
    YOffset = str2double(h.Particle_LabelYOffset.String);
    Particles = find(ParticleViewer.ParticlesOnFrame(Frame, :));
    for i = 1:numel(Particles)
        coord = ParticleViewer.Regions(Particles(i)).Centroid(ParticleViewer.Regions(Particles(i)).Frame == Frame, :);
        if size(ParticleViewer.Regions(Particles(i)).Centroid, 1) >= str2double(h.Particle_LabelMin.String)
           if ParticleViewer.Highlight(Particles(i))
               text(h.Particle_Display, coord(1) + XOffset, coord(2) - YOffset, num2str(Particles(i)), 'Color', 'yellow');
               line(h.Particle_Display, ParticleViewer.Regions(Particles(i)).Centroid(:, 1), ParticleViewer.Regions(Particles(i)).Centroid(:,2), 'Color','yellow');
           else
               text(h.Particle_Display, coord(1) + XOffset, coord(2) - YOffset, num2str(Particles(i)), 'Color', 'red');
           end
        end

    end
end

end

%%% Frame Update  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Particle_Frame(~,~,mode)
h = guidata(findobj('Tag','ParticleViewer'));
global PhasorViewer ParticleViewer

%%% Creates highlight table if it doesn't exist
if ~isfield(ParticleViewer, 'Highlight')
    ParticleViewer.Highlight = false(size(ParticleViewer.Intensity, 1));
end

%%% Gets new value
switch mode
    case 1 %%% Editbox was changed
        Frame = round(str2double(h.Particle_Frame.String));
    case 2 %%% Slider was changed
        Frame = round(h.Particle_FrameSlider.Value);
end
%%% Sets value to valid range
if isfield(PhasorViewer, 'Intensity')
    MaxFrame = size(PhasorViewer.Intensity,3);
else
    MaxFrame = size(ParticleViewer.Intensity, 2);
end
if isempty(Frame) || Frame < 1
    Frame = 1;
elseif Frame > MaxFrame
    Frame = MaxFrame;
end
%%% Updates both Frame settings
h.Particle_Frame.String = num2str(Frame);
h.Particle_FrameSlider.Value = Frame;

%%% Sets particle highlight if selected
PartNum = round(str2double(h.Particle_PartNumber.String));
ParticleViewer.Highlight(PartNum) = h.Particle_Highlight.Value;

%%% Plots loaded image
PlotUpdate(Frame);
end

%%% Update Particle Number and Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Particle_Num(~,~, mode)
global ParticleViewer
h = guidata(findobj('Tag','ParticleViewer'));

if ~isfield(ParticleViewer, 'Intensity')
    return;
end

%%% Get particle number and type of lifetime plot
switch mode
    case 1 %%% Editbox was changed
        PartNum = round(str2double(h.Particle_PartNumber.String));
    case 2 %%% Slider was changed
        PartNum = round(h.Particle_PartSlider.Value);
end

%%% sets value to valid range
if isempty(PartNum) || PartNum < 1
    PartNum = 1;
elseif PartNum > size(ParticleViewer.Intensity, 1)
    PartNum = size(ParticleViewer.Intensity, 1);
end

%%% Updates particle number and highlight settings
h.Particle_PartNumber.String = num2str(PartNum);
h.Particle_PartSlider.Value = PartNum;
h.Particle_Highlight.Value = ParticleViewer.Highlight(PartNum);

%%% Determine type of data to plot
Plot_Type = h.Particle_Plot1_Type.Value;
Particle_Plot(h.Particle_Plot1, PartNum, Plot_Type);
Plot_Type = h.Particle_Plot2_Type.Value;
Particle_Plot(h.Particle_Plot2, PartNum, Plot_Type);
Plot_Type = h.Particle_Plot3_Type.Value+4;
Particle_Plot(h.Particle_Plot3, PartNum, Plot_Type);

end

%%% Update Particle Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Particle_Plot(axes,PartNum,Plot_Type)
global ParticleViewer UserValues
h = guidata(findobj('Tag','ParticleViewer'));
Look = UserValues.Look;

switch Plot_Type
    case 1 %Plot TauP
        XValue = 1:size(ParticleViewer.TauP, 2);
        YValue = ParticleViewer.TauP(PartNum,:);
        YValue(YValue==0) = NaN;
        LineSpec = '.-b';
        YLabel = 'TauP (ns)';
        XLabel = 'Frames';
        Property = {'XLim', [1, size(YValue, 2)+1]};
    case 2 %Plot TauM
        XValue = 1:size(ParticleViewer.TauM, 2);
        YValue = ParticleViewer.TauM(PartNum,:);
        YValue(isinf(YValue)) = NaN;
        LineSpec = '.-b';
        YLabel = 'TauM (ns)';
        XLabel = 'Frames';
        Property = {'XLim', [1, size(YValue, 2)+1]};
    case 3 %Mean of TauP and TauM
        XValue = 1:size(ParticleViewer.TauP, 2);
        TauP = ParticleViewer.TauP(PartNum,:);
        TauP(TauP == 0) = NaN;
        TauM = ParticleViewer.TauM(PartNum,:);
        TauM(isinf(TauM)) = NaN;
        YValue = (TauP + TauM)/2;
        LineSpec = '.-b';
        YLabel = 'Lifetime (ns)';
        XLabel = 'Frames';
        Property = {'XLim', [1, size(YValue, 2)+1]};
    case 4 %Intensity
        XValue = 1:size(ParticleViewer.Intensity, 2);
        YValue = ParticleViewer.Intensity(PartNum,:);
        YValue(YValue==0) = NaN;
        LineSpec = '.-r';
        YLabel = 'Intensity (counts)';
        XLabel = 'Frames';
        Property = {'XLim', [1, size(YValue, 2)+1]};
    case 5 %Position
        XValue = ParticleViewer.Regions(PartNum).Centroid(:, 1);
        YValue = ParticleViewer.Regions(PartNum).Centroid(:, 2);
        LineSpec = '-r';
        YLabel = 'y';
        XLabel = 'x';
        Property = {'YDir', 'reverse', 'DataAspectRatio', [1 1 1],...
            'PlotBoxAspectRatio', [1 1 1]};
    case 6 %Phasor (s and g)
        y=0:0.001:1; z=0:0.001:1;
        h.Universal_Circle=plot(axes,sqrt(z-z.^2),'k','LineStyle','--','Linewidth',2);
        XValue = ParticleViewer.g(PartNum,:);
        YValue = ParticleViewer.s(PartNum,:);
        YValue(YValue==0) = NaN;
        LineSpec = '.-b';
        YLabel = 's';
        XLabel = 'g';
        Property = {'XLim', [0.5, 1],...
            'YLim', [0, 0.5],...
            'PlotBoxAspectRatio', [1 1 1]};
    case 7 %Lifetime vs Intensity
        TauP = ParticleViewer.TauP(PartNum,:);
        TauP(TauP == 0) = NaN;
        TauM = ParticleViewer.TauM(PartNum,:);
        TauM(isinf(TauM)) = NaN;
        XValue = (TauP + TauM)/2;
        YValue = ParticleViewer.Intensity(PartNum,:);
        LineSpec = '.b';
        YLabel = 'Intensity (counts)';
        XLabel = 'Lifetime (ns)';
        Property = {'PlotBoxAspectRatio', [1 1 1]};
    case 8 %Lifetime vs Intensity All Particles
        TauP = ParticleViewer.TauP;
        TauM = ParticleViewer.TauM;
        TauM(isinf(TauM)) = NaN;
        XValue = (TauP + TauM)/2;
        XValue = mean(XValue, 2, 'omitnan');
        YValue = ParticleViewer.Intensity;
        YValue(YValue==0) = NaN;
        YValue = mean(YValue, 2, 'omitnan');
        LineSpec = '.b';
        YLabel = 'Intensity (counts)';
        XLabel = 'Lifetime (ns)';
        Property = {'PlotBoxAspectRatio', [1 1 1]};
end
%%%Moving Average
if h.Particle_MovingAverage.Value && Plot_Type <= 4
    Window = str2double(h.Particle_MovAvgWindow.String);
    if Window < 2 % min value for averaging window
        Window = 2;
        h.Particle_MovAvgWindow.String = '2';
    end    
    YValue = movmean(YValue, Window, 'omitnan');
    
    %removes partial averaging windows at start and end of trace
    idx_start = find(~isnan(YValue),1) + floor(Window/2) -1;
    idx_end = find(~isnan(YValue), 1, 'last') - floor(Window/2);
    YValue([1:idx_start idx_end:end]) = NaN;
    YValue([1:idx_start idx_end:end]) = NaN;
end
p = plot(axes, XValue, YValue, LineSpec);

% Adds universal circle to phasor plot
if Plot_Type == 6
    hold on;
    x=0:0.001:1; y=0:0.001:1;
    h.Universal_Circle=plot(axes,y,sqrt(y-y.^2),'k','LineStyle','--','Linewidth',2);
    hold off;
end

% Sets plot properties
set(axes, Property{:});
axes.XLabel.String = XLabel;
axes.YLabel.String = YLabel;
axes.XColor = Look.Fore;
axes.YColor = Look.Fore;

end

function Extract_Particle_Phasor(~,~)
global ParticleViewer PhasorViewer

%%% Stops execution if data is not complete
if isempty(ParticleViewer) || isempty(ParticleViewer) || ~isfield(ParticleViewer,'Regions')
    return;
end

%%% Undo G and S normalization
Int = PhasorViewer.Intensity;
G = PhasorViewer.g.*Int; %%%unnormalized g
S = PhasorViewer.s.*Int; %%%unnormalized s

%%% Creates arrays with size(Particle,Frames)
g=NaN(size(ParticleViewer.Intensity));
s=NaN(size(ParticleViewer.Intensity));
Intensity=NaN(size(ParticleViewer.Intensity));

%%%Calculates frame-wise average for each particle
for i=1:numel(ParticleViewer.Regions)
    %%% Extends PixelId for every frame
    PixelId = ParticleViewer.Regions(i).PixelIdxList;
    [~,~,z] = ind2sub(size(Int),PixelId);
    Int_temp = mat2cell(Int(PixelId),histcounts(z, [1:max(z), Inf]), 1);
    dint = cellfun('isempty',Int_temp);
    Intensity(i,ParticleViewer.Regions(i).Frame) = cellfun(@(x)sum(x,'omitnan'),Int_temp(~dint));
    G_temp = mat2cell(G(PixelId),histcounts(z,[1:max(z),Inf]),1);
    dg = cellfun('isempty',G_temp);
    g(i,ParticleViewer.Regions(i).Frame) = cellfun(@(x)sum(x,'omitnan'),G_temp(~dg));
    S_temp = mat2cell(S(PixelId),histcounts(z,[1:max(z),Inf]),1);
    ds = cellfun('isempty',S_temp);
    s(i,ParticleViewer.Regions(i).Frame) = cellfun(@(x)sum(x,'omitnan'),S_temp(~ds));
end
g = g./Intensity;
s = s./Intensity;
Intensity(isnan(Intensity))=0;
g(isnan(g))=0;
s(isnan(s))=0;

%%% Updates parameters in global variable
ParticleViewer.Intensity = Intensity;
ParticleViewer.g = g;
ParticleViewer.s = s;
ParticleViewer.Fi = atan(s./g);
ParticleViewer.Fi(isnan(ParticleViewer.Fi)) = 0;
ParticleViewer.M = sqrt(s.^2+g.^2);ParticleViewer.Fi(isnan(ParticleViewer.M)) = 0;
ParticleViewer.TauP = real(tan(ParticleViewer.Fi)./(2*pi*ParticleViewer.Freq/10^9));
ParticleViewer.TauP(isnan(ParticleViewer.TauP)) = 0; %#ok<*NASGU>
ParticleViewer.TauM = real(sqrt((1./(s.^2+g.^2))-1)/(2*pi*ParticleViewer.Freq/10^9));
ParticleViewer.TauM(isnan(ParticleViewer.TauM)) = 0;
%ParticleViewer.Mean_LT = sum(ParticleData.Data.Mean_LT(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);

end

%%% Load Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Data(~,~, mode)
global PhasorViewer ParticleViewer UserValues
LSUserValues(0);

h = guidata(findobj('Tag','ParticleViewer'));

switch mode
    case 1 % Loads ParticleDetection Results
        [FileName,PathName] = uigetfile({'*.phr'},'Load Results of ParticleDetection', UserValues.File.PhasorPath, 'MultiSelect', 'off');
        if ~iscell(FileName) && all(FileName==0)
            disp('No file selected');
            return
        end
        %%% Saves Path
        UserValues.File.PhasorPath=PathName;
        LSUserValues(1);
        
        File = fullfile(PathName,FileName);
        ParticleViewer = load(File,'-mat');
        ParticleViewer.Path = PathName;
        ParticleViewer.FileName = FileName;
        
        % Sets particle control parameters
        h.Particle_PartSlider.Min = 1;
        h.Particle_PartSlider.Max=size(ParticleViewer.Intensity, 1);
        h.Particle_PartSlider.SliderStep=[1./size(ParticleViewer.Intensity, 1),10/size(ParticleViewer.Intensity, 1)];
        h.Particle_PartSlider.Value=1;
        
        % Creates particle mask and sets frame control parameters
%         if isfield(PhasorViewer, 'Intensity')
%             ParticleViewer.Mask = false(size(PhasorViewer.Intensity));
%             %%% Adjusts slider and frame range
%             h.Particle_FrameSlider.Min=1;
%             h.Particle_FrameSlider.Max=size(PhasorViewer.Intensity,3);
%             h.Particle_FrameSlider.SliderStep=[1./size(PhasorViewer.Intensity,3),10/size(PhasorViewer.Intensity,3)];
%             h.Particle_FrameSlider.Value=1;
%         else
            ParticleViewer.Mask = false(ParticleViewer.Lines, ParticleViewer.Pixels, size(ParticleViewer.Intensity,2));
            %%% Adjusts slider and frame range
            h.Particle_FrameSlider.Min=1;
            h.Particle_FrameSlider.Max=size(ParticleViewer.Intensity,2);
            h.Particle_FrameSlider.SliderStep=[1./size(ParticleViewer.Intensity,2),10/size(ParticleViewer.Intensity,2)];
            h.Particle_FrameSlider.Value=1;
            
            %%% Resets image plot zoom
            h.Particle_Display.XLim = [0.5 size(ParticleViewer.Mask,2)+0.5];
            h.Particle_Display.YLim = [0.5 size(ParticleViewer.Mask,1)+0.5];
%         end
        ParticleViewer.ParticlesOnFrame = false(size(ParticleViewer.Intensity, 2), numel(ParticleViewer.Regions));
        for i = 1:numel(ParticleViewer.Regions)
            ParticleViewer.Mask(ParticleViewer.Regions(i).PixelIdxList)=true;
            ParticleViewer.ParticlesOnFrame(ParticleViewer.Regions(i).Frame, i) = true;
        end
        
        % Resets highlighted particles
        ParticleViewer.Highlight = false(size(ParticleViewer.Intensity, 1));
        Particle_Num([],[],1);
        
    case 2 % Load Framewise Phasor Data
        [FileName,PathName] = uigetfile({'*.phf'},'Load Corresponding Framewise Phasor', UserValues.File.PhasorPath, 'MultiSelect', 'off');
        if ~iscell(FileName) && all(FileName==0)
            disp('No file selected');
            return
        end
        %%% Saves Path
        UserValues.File.PhasorPath=PathName;
        LSUserValues(1);
        
        File = fullfile(PathName,FileName);
        PhasorViewer = load(File,'-mat');

        %%% Adjusts slider and frame range
        h.Particle_FrameSlider.Min=1;
        h.Particle_FrameSlider.Max=size(PhasorViewer.Intensity,3);
        h.Particle_FrameSlider.SliderStep=[1./size(PhasorViewer.Intensity,3),10/size(PhasorViewer.Intensity,3)];
        h.Particle_FrameSlider.Value=1;
        
        %%% Resets image plot zoom
        h.Particle_Display.XLim = [0.5 size(PhasorViewer.Intensity,2)+0.5];
        h.Particle_Display.YLim = [0.5 size(PhasorViewer.Intensity,1)+0.5];
end

PlotUpdate(1);

end

%%% Export Traces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export(~,~)
global ParticleViewer
h = guidata(findobj('Tag','ParticleViewer'));

%%% Determines save path
savePath = uigetdir(ParticleViewer.Path, 'Choose the folder to export results to');
if savePath == 0
    return;
end

%%%Initialize variables and settings
Var.FileName = ParticleViewer.FileName;
Var.Submovie = h.Particle_Export_Settings.Data{1}; %Number of frames in each submovie
Var.Break = h.Particle_Export_Settings.Data{2};   %Break between each submovie when scanning is paused, time in seconds
Var.FrameTime = h.Particle_Export_Settings.Data{3}; %Frame time in seconds
Var.Threshold = h.Particle_Export_Settings.Data{4}; %Minimum number of submovies a particle must be detected on for it to be saved
Var.WriteTraces = h.Particle_WriteTraces.Value; %Toggle export of individual traces
Var.MovingAvg = str2double(h.Particle_MovAvgWindow.String); %Moving average window
Var.NPar = size(ParticleViewer.Intensity,1);

%%% Makes local copy of data
Int = ParticleViewer.Intensity;
TauM = ParticleViewer.TauM;
TauP = ParticleViewer.TauP;
LFall = (TauM + TauP)/2;
LFall(isinf(LFall)) = NaN;
s = ParticleViewer.s;
g = ParticleViewer.g;

%%% Applies threshold
thr = sum(~(ParticleViewer.Intensity == 0), 2) < Var.Threshold;
Int(thr, :) = NaN;
TauM(thr, :) = NaN;
TauP(thr, :) = NaN;
LFall(thr, :) = NaN;
s(thr, :) = NaN;
g(thr, :) = NaN;

%%%Calculates mean lifetime for each particle
MeanLF = mean(LFall, 2, 'omitnan');

%%%Moving Average
if h.Particle_MovingAverage.Value
    %TauM = movmean(TauM, Window, 'omitnan');
    %TauP = movmean(TauP, Window, 'omitnan');
    LFall = movmean(LFall, Var.MovingAvg, 2, 'omitnan');
    Int(Int == 0) = NaN; % Sets 0 Intensity to NaN
    Int = movmean(Int, Var.MovingAvg, 2, 'omitnan');

    %removes partial averaging windows at start and end of trace
    for i = 1:Var.NPar
        idx_start = find(~isnan(LFall(i, :)),1) + floor(Var.MovingAvg/2) -1;
        idx_end = find(~isnan(LFall(i, :)), 1, 'last') - floor(Var.MovingAvg/2);
        LFall(i, [1:idx_start idx_end:end]) = NaN;
        Int(i, [1:idx_start idx_end:end]) = NaN;
    end
end

%%% Convert to table
Table.Var = struct2table(Var);
%MeanPhasor = struct2table(a);
PartNo = cell(Var.NPar, 1);
for i = 1:Var.NPar
    PartNo{i} = ['Par_', num2str(i)];
end
Table.TauM = array2table(TauM', 'VariableNames', PartNo);
Table.TauP = array2table(TauP', 'VariableNames', PartNo);
Table.Int = array2table(Int', 'VariableNames', PartNo);
Table.S = array2table(s', 'VariableNames', PartNo);
Table.G = array2table(g', 'VariableNames', PartNo);
Table.LFall = array2table(LFall', 'VariableNames', PartNo);
Table.MeanLF = array2table(MeanLF', 'VariableNames', PartNo);

%%% Saves data
writetable(Table.Var,fullfile(savePath,'Variables.csv'));
writetable(Table.TauM,fullfile(savePath,'TauM.csv'));
writetable(Table.TauP,fullfile(savePath,'TauP.csv'));
writetable(Table.Int,fullfile(savePath,'Int.csv'));
writetable(Table.S,fullfile(savePath,'S.csv'));
writetable(Table.G,fullfile(savePath,'G.csv'));
writetable(Table.LFall,fullfile(savePath,'LFall.csv'));
writetable(Table.MeanLF,fullfile(savePath,'MeanLF.csv'));

%%% Save Traces
if Var.WriteTraces
    %Generate Time Vector
    Time = zeros(size(ParticleViewer.Intensity,2),1);
    for i=1:size(ParticleViewer.Intensity,2)
        Time(i) = (Var.FrameTime*(i-0.5)+Var.Break*(ceil(i/Var.Submovie)-1))/60;
    end
    %Get lifetime axis limits from settings
    LF_min = h.Particle_Export_Settings.Data{5};
    LF_max = h.Particle_Export_Settings.Data{6};
    %Initialize Figure
    h.Export = figure;
    set(h.Export, 'Visible', 'off');
    a = axes('Parent',h.Export, 'Units','normalized');
    
    %Progress Bar
    delete(findall(0,'type','figure','tag','TMWWaitbar')); %closes existing waitbars
    h.ProgressBar = waitbar(0, 'Saving traces',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    
    %Plot and Save traces
    for k=1:Var.NPar
        if getappdata(h.ProgressBar,'canceling') %user cancellation
            break 
        end
        if all(isnan(LFall(k,:))) %skips particles below frame threshold
            continue
        end
        Suffix = '_LFtime';
        Par = num2str(k);
        NewName = replace(Var.FileName, '_', '-');
        yyaxis(a, 'left'); %switch to left axis
        plot(a,Time,LFall(k,:),'-b.'); 
        xlabel(a, 'Time [min]'); ylabel(a, 'Lifetime [ns]');
        xlim(a, [0 max(Time)]); ylim(a, [LF_min LF_max]);
        title(a, {Par, NewName});
        yyaxis(a, 'right'); %switch to right axis
        plot(a,Time,Int(k,:),'-r.');
        ylabel(a, 'Intensity');
        ylim(a, [0 1.1*max(Int(k,:))]);
        set(a,'XMinorTick','on');
        set(a,'YMinorTick','on');
        Fig = fullfile(savePath,[Par,Suffix]);
        waitbar(k/Var.NPar, h.ProgressBar, ['Saving trace ',Par,' of ',...
            num2str(Var.NPar)]);
        saveas(h.Export,Fig,'png');
        saveas(h.Export,Fig,'fig');  
    end
    delete(h.ProgressBar);
    delete(h.Export);
end
end

function Export_TIFF(~,~)
global UserValues PhasorViewer
h = guidata(findobj('Tag','ParticleViewer'));

if ~isfield(PhasorViewer, 'Intensity')
    return;
end

[FileName,PathName] = uiputfile([UserValues.File.PhasorPath, '*.tif'], 'Export movie as TIFF stack');
FullFileName = fullfile(PathName, FileName);

Start = round(str2double(h.Particle_Frames_Start.String));
Stop = round(str2double(h.Particle_Frames_Stop.String));
MaxFrame = size(PhasorViewer.Intensity, 3);

%Check if export range is valid
if isempty(Start) || Start < 1
    Start = 1;
elseif Start > MaxFrame
    Start = MaxFrame;
end
if isempty(Stop) || Stop < Start || Stop > MaxFrame
    Stop = MaxFrame;
end

%Updates frame range
h.Particle_Frames_Start.String = num2str(Start);
h.Particle_Frames_Stop.String = num2str(Stop);

%Progress Bar
delete(findall(0,'type','figure','tag','TMWWaitbar')); %closes existing waitbars
h.ProgressBar = waitbar(0, 'Exporting to TIFF',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

for i = Start:Stop
    if getappdata(h.ProgressBar,'canceling') %user cancellation
       break 
    end
    waitbar(i/(Stop-Start+1), h.ProgressBar);
    PlotUpdate(i);
    F = getframe(h.Particle_Display);
    if i == Start
        imwrite(F.cdata, FullFileName);
    elseif i > Start
        imwrite(F.cdata, FullFileName, 'WriteMode','append');
    end
end
delete(h.ProgressBar);
end