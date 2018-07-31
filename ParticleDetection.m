function ParticleDetection(~,~)
global UserValues
h.Particle=findobj('Tag','Particle');

addpath(genpath(['.' filesep 'functions']));

if ~isempty(h.Particle) % Creates new figure, if none exists
    figure(h.Particle);
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
h.Particle = figure(...
    'Units','normalized',...
    'Tag','Particle',...
    'Name','Phasor Particle Detection',...
    'NumberTitle','off',...
    'Menu','none',...
    'defaultUicontrolFontName',Look.Font,...
    'defaultAxesFontName',Look.Font,...
    'defaultTextFontName',Look.Font,...
    'defaultAxesYColor',Look.Fore,...
    'Toolbar','figure',...
    'UserData',[],...
    'BusyAction','cancel',...
    'OuterPosition',[0.01 0.1 0.98 0.9],...
    'CloseRequestFcn',@CloseWindow,...
    'Visible','on');
%%% Sets background of axes and other things
whitebg(Look.Fore);
%%% Changes Pam background; must be called after whitebg
h.Particle.Color=Look.Back;
%%% Remove unneeded items from toolbar
toolbar = findall(h.Particle,'Type','uitoolbar');
toolbar_items = findall(toolbar);
delete(toolbar_items([2:7 9 13:17]));

h.Load_Particle = uimenu(...
    'Parent',h.Particle,...
    'Label','Load Phasor Data',...
    'Callback',@Load_Particle_Data);

h.Load_MaskData = uimenu(...
    'Parent',h.Particle,...
    'Label','Load External Mask Data',...
    'Callback',@Load_Mask_Data);

h.Text = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Image Plot and Controls %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Plot panel
h.Plot_Panel = uibuttongroup(...
    'Parent',h.Particle,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.005 0.25 0.29 0.74]);

%%% Main Image plot
h.Particle_Plot = axes(...
    'Parent',h.Plot_Panel,...
    'Units','normalized',...
    'Position',[0 0.34 1 0.635]);
h.Particle_Image = image(zeros(1,1,3));
h.Particle_Plot.DataAspectRatio = [1 1 1];
h.Particle_Plot.XTick = [];
h.Particle_Plot.YTick = [];

%%% Pixel Counts plot
h.Particle_Counts = axes(...
    'Parent',h.Plot_Panel,...
    'Nextplot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'Units','normalized',...
    'Position',[0.13 0.07 0.82 0.25]);
h.Particle_CountsHist{1} = plot(h.Particle_Counts,zeros(100,1),'Color',[0.8 0 0]);
h.Particle_CountsHist{2} = plot(h.Particle_Counts,zeros(100,1),'Color',[0 0.6 0]);

h.Particle_Counts.XLabel.String = 'Counts';
h.Particle_Counts.XLabel.Color = Look.Fore;
h.Particle_Counts.YLabel.String = 'Frequency';
h.Particle_Counts.YLabel.Color = Look.Fore;

%%% Plot control panel
h.Plot_Control_Panel = uibuttongroup(...
    'Parent',h.Particle,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.005 0.01 0.29 0.24]);
%%% Frame
h.Text{end+1} = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.87, 0.15 0.12],...
    'String','Frame:');
%%% Editbox for frame
h.Particle_Frame = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame,1},...
    'Position',[0.18 0.86, 0.1 0.12],...
    'String','1');
%%% Checkbox for use frame
h.Particle_FrameSlider = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame,2},...
    'Position',[0.29 0.86, 0.2 0.12]);

%%% Colormap selection
h.Text{end+1} = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.85, 0.2 0.12],...
    'String','Colormap:');
h.Particle_Colormap = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Plot_Particle,0},...
    'Position',[0.71 0.86, 0.25 0.12],...
    'String',{'Jet','Gray','Hot','HSV'});

%%% Autoscale
h.Particle_ManualScale = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Plot_Particle,0:2},...
    'Value',0,...
    'Position',[0.02 0.72, 0.35 0.12],...
    'String','Manual Scale:');

%%% Min Scale
h.Particle_ScaleMin = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Plot_Particle,0:2},...
    'Position',[0.38 0.72, 0.1 0.12],...
    'String','0');
%%% Max Scale
h.Particle_ScaleMax = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Plot_Particle,0:2},...
    'Position',[0.49 0.72, 0.1 0.12],...
    'String','100');

%%% Frames to use
h.Text{end+1} = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.58, 0.3 0.12],...
    'String','Use Frames:');
h.Particle_Frames_Start = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','1',...
    'Position',[0.38 0.58, 0.1 0.12]);
h.Particle_Frames_Stop = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','999',...
    'Position',[0.49 0.58, 0.1 0.12]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Particle detection selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Particle Detection settings panel
h.Detection_Panel = uibuttongroup(...
    'Parent',h.Particle,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.3 0.01 0.2 0.98]);

%%% Method of particle detection
h.Particle_Method = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Method_Update,0},...
    'Position',[0.01 0.93, 0.98 0.06],...
    'String',{'Simple threshold method',...
    'Simple wavelet method',...
    'Extended wavelet method'});

h.Particle_Method_Description = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',10,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.73, 0.98 0.20],...
    'String','This method uses a full stack threshold to calculate a binary map. Based on this map it used the matlab "regionprops" function to detect particles. Always works with full stack.');

%%% Method settings Table
TableData = {   'Pixel Threshold [Counts]',150;...
    'Use Non-Particle',0};
ColumnNames = {'Parameter Name', 'Value'};
ColumnWidth = {210,70};
ColumnEditable = [false,true];
RowNames = [];

h.Particle_Method_Settings = uitable(...
    'Parent',h.Detection_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Position',[0.01 0.22 0.98 0.51],...
    'Data',TableData,...
    'ColumnName',ColumnNames,...
    'RowName',RowNames,...
    'ColumnWidth',ColumnWidth,...
    'ColumnEditable',ColumnEditable);


h.Particle_Use_External_Mask = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',0,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Use external mask',...
    'Callback',{@Misc},...
    'Position',[0.01 0.19, 0.5 0.02]);

h.Particle_Use_NonParticle = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',0,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Use non-detected pixels',...
    'Position',[0.01 0.16, 0.8 0.02]);

h.Particle_Track_Per_Frame = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',0,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Track per Frame',...
    'Callback',{@Misc},...
    'Position',[0.01 0.11, 0.5 0.02]);

h.Particle_Track_FrameSkip = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Visible','off',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','1',...
    'ToolTipString','Allowed frames to skip',...
    'Position',[0.51 0.11, 0.15 0.02]);

h.Particle_Track_MaxDist = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Visible','off',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','5',...
    'ToolTipString','Maximum Lateral Distance',...
    'Position',[0.75 0.11, 0.15 0.02]);

h.Particle_Track_Frame_Text = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',10,...
    'Visible','off',...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.45 0.13, 0.3 0.02],...
    'String','Frame Skip');

h.Particle_Track_Dist_Text = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',10,...
    'Visible','off',...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.73 0.13, 0.2 0.02],...
    'String','Distance');


%%% Starts Calculation
h.Particle_DoCalculation = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',15,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Method_Update,1},...
    'Position',[0.01 0.05, 0.4 0.04],...
    'String','Calculate');
h.Particle_Save = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',15,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Save},...
    'Position',[0.45 0.05, 0.4 0.04],...
    'String','Save');
h.Particle_Save_Method = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.01, 0.5 0.03],...
    'Callback',{@Misc},...
    'String',{'Save Average',...
    'Save FLIM Trace',...
    'Save Text'});
%%% Frames to use
h.Particle_Frames_Sum_Text = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'Visible','off',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.53 0.01, 0.3 0.02],...
    'String','Sum Frames:');
h.Particle_Frames_Sum = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Visible','off',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','1',...
    'Position',[0.83 0.01, 0.15 0.02]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Particle detection display %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Particle display panel
h.Display_Panel = uibuttongroup(...
    'Parent',h.Particle,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.51 0.25 0.29 0.74]);

%%% Partilce display plot
h.Particle_Display = axes(...
    'Parent',h.Display_Panel,...
    'Units','normalized',...
    'Position',[0 0.34 1 0.635]);
h.Particle_Display_Image = image(zeros(1,1,3));
h.Particle_Display.DataAspectRatio = [1 1 1];
h.Particle_Display.XTick = [];
h.Particle_Display.YTick = [];

%%% Display type selection
h.Particle_Disply_Type = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Plot_Particle,2},...
    'Position',[0.02 0.26, 0.4 0.05],...
    'String',{  'Mask only',...
    'Mask overlay',...
    'Mask gray/red',...
    'Mask magenta/green',...
    'Particles only',...
    'Particles overlay',...
    'Particles gray/jet'});

h.Particle_Display_ExternalMask = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',0,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Show external mask',...
    'Callback',{@Plot_Particle,2},....
    'Position',[0.45 0.27, 0.4 0.04]);

h.Particle_Number = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.21, 0.96 0.04],...
    'String','Particle detected: 0 ');
%% Stores Info in guidata
guidata(h.Particle,h);
%%% Updated method table
Method_Update([],[],0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loads new phasor file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Particle_Data(~,~)
h = guidata(findobj('Tag','Particle'));
global ParticleData UserValues
LSUserValues(0);

%%% Choose files to load
[FileName,PathName] = uigetfile({'*.phf'}, 'Choose a referenced data file', UserValues.File.PhasorPath, 'MultiSelect', 'off');
%%% Only esecutes, if at least one file was selected
if all(FileName==0)
    return
end
%%% Saves Path
UserValues.File.PhasorPath=PathName;
LSUserValues(1);

%%% Loads Data
ParticleData.Data=load(fullfile(PathName, FileName),'-mat');
ParticleData.FileName = FileName;
ParticleData.PathName = PathName;

%%% Removed detected particle data
if isfield(ParticleData,'Regions')
    ParticleData = rmfield(ParticleData,'Regions');
end
if isfield(ParticleData,'Mask')
    ParticleData = rmfield(ParticleData,'Mask');
end
if isfield(ParticleData,'Particle')
    ParticleData = rmfield(ParticleData,'Particle');
end
h.Particle_Number.String = 'Particles detected: 0';


%%% Creates full stack counts histogram
Max=max(ParticleData.Data.Intensity(:))+1;
ParticleData.Hist = histcounts(ParticleData.Data.Intensity(:),0:Max)/numel(ParticleData.Data.Intensity);
Max=max(max(sum(ParticleData.Data.Intensity,3)))+1;
ParticleData.Hist_Sum = histcounts(reshape(sum(ParticleData.Data.Intensity,3),1,[]),0:Max)/numel(ParticleData.Data.Intensity(:,:,1));
ParticleData.Int_Sum = sum(ParticleData.Data.Intensity,3);


%%% Adjusts slider and frame range
h.Particle_FrameSlider.Min=0;
h.Particle_FrameSlider.Max=size(ParticleData.Data.Intensity,3);
h.Particle_FrameSlider.SliderStep=[1./size(ParticleData.Data.Intensity,3),10/size(ParticleData.Data.Intensity,3)];
h.Particle_FrameSlider.Value=0;
h.Particle_Frame.String = '0';
guidata(h.Particle,h);

%%% Plots loaded image
Plot_Particle([],[],0:2,h)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loads external mask data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Mask_Data(~,~)
h = guidata(findobj('Tag','Particle'));
global ParticleData UserValues
LSUserValues(0);

%%% Choose files to load
[FileName,PathName] = uigetfile({'*.tif'}, 'Choose a mask image file', UserValues.File.PhasorPath, 'MultiSelect', 'off');
%%% Only esecutes, if at least one file was selected
if all(FileName==0)
    return
end

%%% Loads Data
    Info=imfinfo(fullfile(PathName,FileName));
    Frames = numel(Info);
    ParticleData.MaskData = zeros(Info(1).Height,Info(1).Width,Frames);
    
    TIFF_Handle = Tiff(fullfile(PathName,FileName),'r'); % Open tif reference
    
    for i=1:Frames
        TIFF_Handle.setDirectory(i);
        ParticleData.MaskData(:,:,i) = TIFF_Handle.read();
    end
    TIFF_Handle.close(); % Close tif reference
    ParticleData.MaskData_Sum = sum(ParticleData.MaskData,3);

%%% Plots loaded image
Plot_Particle([],[],0:2,h)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Updates plots in Particle figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Plot_Particle(~,~,mode,h)

if ~exist('h','var')
    h = guidata(findobj('Tag','Particle'));
end
global ParticleData

if isempty(ParticleData)
    return;
end

Frame = round(h.Particle_FrameSlider.Value);

%%% Plots simple image
if any(mode==0)
    %%% Selects colormap for plotting
    switch h.Particle_Colormap.Value
        case 1
            Color = jet(128);
        case 2
            Color = gray(128);
        case 3
            Color = hot(128);
        case 4
            Color = hsv(128);
    end
    
    %%% Selects right frame for plotting or summed frame
    if Frame == 0 %% Summed up image
        Int = ParticleData.Int_Sum;
    else %%% Framewise image
        Int = ParticleData.Data.Intensity(:,:,Frame);
    end
    %%% Adjusts to range
    if h.Particle_ManualScale.Value
        Min = str2double(h.Particle_ScaleMin.String); Int(Int < Min)= Min;
        Max = str2double(h.Particle_ScaleMax.String); Int(Int > Max)= Max;
    else
        Min = min(Int(:));
        Max = max(Int(:));
    end
    %%% Transforms intensity image to 128 colors
    Int=round(127*(Int-Min)/(Max-Min))+1;
    %%% Applies colormap
    Image=reshape(Color(Int(:),:),size(Int,1),size(Int,2),3);
    
    h.Particle_Image.CData = Image;
    h.Particle_Plot.XLim = [0.5 size(Image,2)+0.5];
    h.Particle_Plot.YLim = [0.5 size(Image,1)+0.5];
    
end

%%% Plots count histogram
if any(mode==1)
    if Frame == 0 %%% Summed up intensity
        %%% Extracts right data
        Hist = ParticleData.Hist_Sum;
        %%% Adjusts to range
        %%% Adjusts to range
        if h.Particle_ManualScale.Value
            Min = max([0,ceil(str2double(h.Particle_ScaleMin.String))]);
            Max = min([numel(ParticleData.Hist_Sum)-1 floor(str2double(h.Particle_ScaleMax.String))]);
            %%% Adjusts full stack histogram
            if Max+1<numel(Hist)
               Hist(Max+1)=sum(Hist(Max+1:end));
               Hist=Hist(1:Max+1);
            end
            if Min>0
                Hist(Min+1) = sum(Hist(1:Min+1));
                Hist(1:Min) = [];
            end
        else
            Min = 0;
            Max = numel(ParticleData.Hist_Sum)-1;
        end
        %%% Updates plot
        h.Particle_CountsHist{1}.YData = Hist;
        h.Particle_CountsHist{1}.XData = Min:Max;
        %%% Turns single frame plot off
        h.Particle_CountsHist{2}.Visible ='off';
    else %%% Framewise intensity
        %%% Extracts right data
        Int=ParticleData.Hist;        

        %%% Adjusts to range
        if h.Particle_ManualScale.Value
            Min = max([0,ceil(str2double(h.Particle_ScaleMin.String))]);
            Max = min([numel(ParticleData.Hist)-1 floor(str2double(h.Particle_ScaleMax.String))]);
            %%% Adjusts full stack histogram
            if Max+1<numel(Int)
               Int(Max+1)=sum(Int(Max+1:end));
               Int=Int(1:Max+1);
            end
            if Min>0
                Int(Min+1) = sum(Int(1:Min+1));
                Int(1:Min) = [];
            end
            Int_Frame = histcounts(reshape(ParticleData.Data.Intensity(:,:,Frame),1,[]),Min:(Max+1))./numel(ParticleData.Data.Intensity(:,:,Frame));
            
        else
            Min = 0;
            Max = numel(ParticleData.Hist)-1;
            Int_Frame = histcounts(reshape(ParticleData.Data.Intensity(:,:,Frame),1,[]),Min:(Max+1))./numel(ParticleData.Data.Intensity(:,:,Frame));
        end
        %%% Updates plot
        h.Particle_CountsHist{1}.YData = Int;
        h.Particle_CountsHist{1}.XData = Min:Max;
        h.Particle_CountsHist{2}.YData = Int_Frame;
        h.Particle_CountsHist{2}.XData = Min:Max;
        %%% Turns single frame plot on
        h.Particle_CountsHist{2}.Visible ='on';
        
    end
end

%%% Plots detected particles
if any(mode==2)
    if isfield(ParticleData,'Regions')
        
        %%% Distinguishes between framewise and total mask
        if size(ParticleData.Mask,3) == 1
            Mask = ParticleData.Mask;            
        elseif Frame == 0 || size(ParticleData.Mask,3)<Frame
            Mask = ParticleData.Mask(:,:,1);
        else
            Mask = ParticleData.Mask(:,:,Frame);
        end
        %%% Distinguishes between framewise and total particle assignement
        if size(ParticleData.Particle,3) == 1
            Particle = ParticleData.Particle;
        elseif Frame == 0 || size(ParticleData.Particle,3)<Frame
            Particle = ParticleData.Particle(:,:,1);
        else
            Particle = ParticleData.Particle(:,:,Frame);
        end
        
        %%% Selects right frame for plotting or summed frame
        if h.Particle_Display_ExternalMask.Value...%%% Uses external mask for displaying  
                && h.Particle_Use_External_Mask.Value...
                && isfield(ParticleData,'MaskData')...
                && size(ParticleData.MaskData,1) == size(Mask,1)...
                && size(ParticleData.MaskData,2) == size(Mask,2)
                         
            if Frame == 0 %% Summed up image
                Int = ParticleData.MaskData_Sum;
            elseif Frame >size(ParticleData.MaskData,3) 
                Int = ParticleData.MaskData(:,:,1);
            else %%% Framewise image
                Int = ParticleData.MaskData(:,:,Frame);
            end
        else %%% Uses data itself for displaying
            
            if Frame == 0 %% Summed up image
                Int = ParticleData.Int_Sum;
            else %%% Framewise image
                Int = ParticleData.Data.Intensity(:,:,Frame);
            end
        end
        %%% Adjusts to range
        if h.Particle_ManualScale.Value
            Min = str2double(h.Particle_ScaleMin.String); Int(Int < Min)= Min;
            Max = str2double(h.Particle_ScaleMax.String); Int(Int > Max)= Max;
        else
            Min = min(Int(:));
            Max = max(Int(:));
        end
        
        switch h.Particle_Disply_Type.Value
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
                
            case 5 %%% Particles only
                %%% Particles colored with jet
                Color = [0,0,0; jet(max(Particle(:)))];
                Image=reshape(Color(Particle+1,:),size(Int,1),size(Int,2),3);
            case 6 %%% Particles overlay
                %%% Scales Intensity image
                Int=(Int-Min)/(Max-Min);
                %%% Sets particles to homogeneous jet color
                Color = [0,0,0; jet(max(Particle(:)))];
                Image=reshape(Color(Particle+1,:),size(Int,1),size(Int,2),3);
                %%% Sets non-particles to grayscale
                Image = repmat(Int.*~Particle,[1 1 3])+Image;
                
            case 7 %%% Particles gray/jet
                %%% Scales Intensity image
                Int=(Int-Min)/(Max-Min);
                %%% Sets particles to scaled jet and rest to gray scale
                Color = [1 1 1 ; jet(max(Particle(:)))];
                Image=reshape(Color(Particle+1,:),size(Int,1),size(Int,2),3).*repmat(Int,[1 1 3]);
        end
        
        h.Particle_Display_Image.CData = Image;
        h.Particle_Display.XLim = [0.5 size(Image,2)+0.5];
        h.Particle_Display.YLim = [0.5 size(Image,1)+0.5];
        h.Particle_Number.String = ['Particles detected: ' num2str(numel(ParticleData.Regions))];
    elseif h.Particle_Display_ExternalMask.Value...%%% Displays only the external mask
                && h.Particle_Use_External_Mask.Value...
                && isfield(ParticleData,'MaskData')...
                && size(ParticleData.MaskData,1) == size(ParticleData.Data.Intensity,1)...
                && size(ParticleData.MaskData,2) == size(ParticleData.Data.Intensity,2)
            
            if Frame == 0 %% Summed up image
                Int = ParticleData.MaskData_Sum;
            elseif Frame >size(ParticleData.MaskData,3)
                Int = ParticleData.MaskData(:,:,1);
            else %%% Framewise image
                Int = ParticleData.MaskData(:,:,Frame);
            end
            %%% Adjusts to range
            if h.Particle_ManualScale.Value
                Min = str2double(h.Particle_ScaleMin.String); Int(Int < Min)= Min;
                Max = str2double(h.Particle_ScaleMax.String); Int(Int > Max)= Max;
            else
                Min = min(Int(:));
                Max = max(Int(:));
            end
            
            Image=(Int-Min)/(Max-Min);
            Image = repmat(Image,[1 1 3]);
            
            h.Particle_Display_Image.CData = Image;
            h.Particle_Display.XLim = [0.5 size(Image,2)+0.5];
            h.Particle_Display.YLim = [0.5 size(Image,1)+0.5];
            h.Particle_Number.String = 'Particles detected: 0';
    
    else %%% Displays nothing
        if Frame == 0 %% Summed up image
            Int = ParticleData.Int_Sum;
        else %%% Framewise image
            Int = ParticleData.Data.Intensity(:,:,Frame);
        end
        %%% Adjusts to range
        if h.Particle_ManualScale.Value
            Min = str2double(h.Particle_ScaleMin.String); Int(Int < Min)= Min;
            Max = str2double(h.Particle_ScaleMax.String); Int(Int > Max)= Max;
        else
            Min = min(Int(:));
            Max = max(Int(:));
        end
        
        Image=(Int-Min)/(Max-Min);
        Image = repmat(Image,[1 1 3]);
        
        h.Particle_Display_Image.CData = Image;
        h.Particle_Display.XLim = [0.5 size(Image,2)+0.5];
        h.Particle_Display.YLim = [0.5 size(Image,1)+0.5];
        h.Particle_Number.String = 'Particles detected: 0';
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Go through frames %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Particle_Frame(~,~,mode)
h = guidata(findobj('Tag','Particle'));
global ParticleData

if isempty(ParticleData)
    return;
end

%%% Gets new value
switch mode
    case 1 %%% Editbox was changed
        Frame = round(str2double(h.Particle_Frame.String));
    case 2 %%% Slider was changed
        Frame = round(h.Particle_FrameSlider.Value);
end
%%% Sets value to valid range
if isempty(Frame) || Frame < 0
    Frame = 0;
elseif Frame > size(ParticleData.Data.Intensity,3)
    Frame = size(ParticleData.Data.Intensity,3);
end
%%% Updates both Frame settings
h.Particle_Frame.String = num2str(Frame);
h.Particle_FrameSlider.Value = Frame;
%%% Plots loaded image
Plot_Particle([],[],0:2,h)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to update method selection and settings %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Method_Update(~,~,mode)
h = guidata(findobj('Tag','Particle'));
LSUserValues(0);

switch h.Particle_Method.Value
    case 1 %%% Regionprops with some shape detection
        Method_Regionprops_Shape([],[],mode);
    case 2 %%% Wavelets and Regionprops
        Method_Wavelets_Simple([],[],mode);
    case 3 %%% Extended Wavelets Method
        Method_Wavelets_Extended([],[],mode);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Here are all the different methods collected in separate functions %%%%
%%% General shape:
%%% mode == 0 to update settings
%%% mode == 1 calculating the detection
%%% Note: The particle detection can be both full stack and frame by frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Regionprops with thresholding and shape %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Method_Regionprops_Shape(~,~,mode)
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Is only called for updating the table/info
if mode == 0
        
    %%% Updates Table
    TableData = {   'Pixel Threshold [Counts]',150;...
        'Min Size [px]:', 10;...
        'Max Size [px]:', 100;...
        'Gauss. Filter [Px]' ,2;...
        'Eccentricity', 0.7};
    ColumnNames = {'Parameter Name', 'Value'};
    
    h.Particle_Method_Settings.ColumnName = ColumnNames;
    h.Particle_Method_Settings.Data = TableData;
    
    %%% Updates Method information
    h.Particle_Method_Description.String =['This method uses a threshold to calculate a binary map. '...
        'Gaussian filtering is applied before thresholding. '....
        'Based on this map it uses the matlab "regionprops" function to detect particles. '...
        'It uses eccentricity filtering for shape detection. ',...
        'The data defined within the frame range is used. '];
    %%% Removed detected particle data
    if isfield(ParticleData,'Regions')
        ParticleData = rmfield(ParticleData,'Regions');
    end
    if isfield(ParticleData,'Mask')
        ParticleData = rmfield(ParticleData,'Mask');
    end
    if isfield(ParticleData,'Particle')
        ParticleData = rmfield(ParticleData,'Particle');
    end
    Plot_Particle([],[],2,h)
    return;
end

%%% Actual particle detection and averaging
if mode == 1
    %%% Extracts parameters
    TH = h.Particle_Method_Settings.Data{1,2};
    MinSize = h.Particle_Method_Settings.Data{2,2};
    MaxSize = h.Particle_Method_Settings.Data{3,2};
    Gaus = h.Particle_Method_Settings.Data{4,2};
    Eccent = h.Particle_Method_Settings.Data{5,2};
    
    From = str2double(h.Particle_Frames_Start.String);
    To = str2double(h.Particle_Frames_Stop.String);
    
    %%% Adjusts frame range to data
    if To>size(ParticleData.Data.Intensity,3)
        To = size(ParticleData.Data.Intensity,3);
        h.Particle_Frames_Stop.String = size(ParticleData.Data.Intensity,3);
    end
    if From > To
        From = 1;
        h.Particle_Frames_Start.String = 1;
    end
    
    %%% Averages image   
    if h.Particle_Use_External_Mask.Value
        %%% Used external map if possible
        if ~isfield(ParticleData,'MaskData') ||...
                size(ParticleData.MaskData,1)<size(ParticleData.Data.Intensity,1) ||...
                size(ParticleData.MaskData,2)<size(ParticleData.Data.Intensity,2)
            
            Int = sum(ParticleData.Data.Intensity(:,:,From:To),3);
            h.Particle_Use_External_Mask.Value=0;
        elseif  size(ParticleData.MaskData,3)<To
            Int = sum(ParticleData.MaskData,3);
        else
            Int = sum(ParticleData.MaskData(:,:,From:To),3);
        end
    else
        %%% Used image directly
        Int = sum(ParticleData.Data.Intensity(:,:,From:To),3);
    end
    
    a=Int;
    %%% Gaussian filter
    if Gaus>1
        h = fspecial('gaussian', round(3.*[Gaus Gaus]), Gaus);
        Int = filter2(h, Int);
    end
    
    %%% Applies threshold
    BitImage = Int > TH;
    
    %%% Calculates regionprops
    Regions = regionprops(BitImage,Int,'eccentricity', 'PixelList','Area','PixelIdxList','MaxIntensity','MeanIntensity','PixelValues');
    
    %%% Aborts calculation when no particles were detected
    if isempty(Regions)
        msgbox('No particles detected! Please change threshold.');
        return;
    end
    
    
    if MinSize<1
        MinSize =1;
    end
    if MaxSize<MinSize || MaxSize>numel(BitImage)
        MaxSize = numel(BitImage);
    end
    %%% Removes small regions
    Regions(cat(1, Regions.Area)<MinSize)=[];
    %%% Removes large regions
    Regions(cat(1, Regions.Area)>MaxSize)=[];
    %%% Removes eccentric regions
    Regions(cat(1, Regions.Eccentricity)>Eccent)=[];
    
    ParticleData.Regions = Regions;
    ParticleData.Mask = false(size(ParticleData.Data.Intensity,1),size(ParticleData.Data.Intensity,2));
    ParticleData.Particle = zeros(size(ParticleData.Data.Intensity,1),size(ParticleData.Data.Intensity,2));
    %%% Reformats particle information for Phasor calculation
    for i=1:numel(Regions)
        ParticleData.Mask(Regions(i).PixelIdxList) = true;
        ParticleData.Particle(Regions(i).PixelIdxList) = i;
        ParticleData.Regions(i).TotalCounts = Regions(i).MeanIntensity.*Regions(i).Area;
    end
    ParticleData.Particle = repmat(ParticleData.Particle,1,1,To-From+1);
    Plot_Particle([],[],2,h)
    return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Simplet Wavelet Method %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Method_Wavelets_Simple(~,~,mode)
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Is only called for updating the table/info
switch mode
    case 0
        %%% Updates Table
        TableData = {'Threshold Significance [0-1]',0.8;...
                    'Min Photons',10;...
                    'Max Photons',3000;...
                    'Min Size [px]', 8;...
                    'Max Size [px]', 30;...
                    'Wavelet depth' ,3;...
                    'Eccentricity', 0.8;...
                    'Min Track Length [fr]', 2;...
                    'Fill Gaps', true};

        ColumnNames = {'Parameter Name', 'Value'};

        h.Particle_Method_Settings.ColumnName = ColumnNames;
        h.Particle_Method_Settings.Data = TableData;

        %%% Updates Method information
        h.Particle_Method_Description.String =['This method uses wavelets to calculate a binary map. '...
            'Based on this map it uses the matlab "regionprops" function to detect particles. '...
            'Detected particles are filtered for area, intensity and eccentricity. ',...
            'Spot linking is done through Simple Tracker from JY Tinevez, ',...
            'which links particles using the Hungarian algorithm. ',...
            'Gaps due to missed detections can be filled using linear interpolation. '];

%%% Actual particle detection and averaging
    case 1
        %% Removed detected particle data
        if isfield(ParticleData,'Regions')
            ParticleData = rmfield(ParticleData,'Regions');
        end
        if isfield(ParticleData,'Mask')
            ParticleData = rmfield(ParticleData,'Mask');
        end
        if isfield(ParticleData,'Particle')
            ParticleData = rmfield(ParticleData,'Particle');
        end
        
        %% Extracts parameters
        TH_init = h.Particle_Method_Settings.Data{1,2};
        MinP = h.Particle_Method_Settings.Data{2,2};
        MaxP = h.Particle_Method_Settings.Data{3,2};
        MinSize = h.Particle_Method_Settings.Data{4,2};
        MaxSize = h.Particle_Method_Settings.Data{5,2};
        if MaxSize < MinSize || MaxSize == 0
            MaxSize = Inf;
        end
        Wavelet = h.Particle_Method_Settings.Data{6,2};
        Eccent = h.Particle_Method_Settings.Data{7,2};
        MinLength = h.Particle_Method_Settings.Data{8,2};
        FillGaps = h.Particle_Method_Settings.Data{9,2} && MinLength >= 2 &&...
            h.Particle_Track_Per_Frame.Value;

        %%% Sets max size and intensity to Inf if values don't make sense
        if MaxP<MinP || MaxP==0
            MaxP = Inf;
        end
        if MaxSize < MinSize || MaxSize == 0
            MaxSize = Inf;
        end

        %% Get frame range
        From = str2double(h.Particle_Frames_Start.String);
        To = str2double(h.Particle_Frames_Stop.String);
        %%% Adjusts frame range to data
        if To>size(ParticleData.Data.Intensity,3)
            To = size(ParticleData.Data.Intensity,3);
            h.Particle_Frames_Stop.String = size(ParticleData.Data.Intensity,3);
        end
        if From > To
            From = 1;
            h.Particle_Frames_Start.String = 1;
        end

        %% Extracts regions
        %%% Averages image
        if h.Particle_Use_External_Mask.Value
            %%% Used external map if possible
            if ~isfield(ParticleData,'MaskData') ||...
                    size(ParticleData.MaskData,1)<size(ParticleData.Data.Intensity,1) ||...
                    size(ParticleData.MaskData,2)<size(ParticleData.Data.Intensity,2)

                Int = sum(ParticleData.Data.Intensity(:,:,From:To),3);
                h.Particle_Use_External_Mask.Value=0;
            elseif  size(ParticleData.MaskData,3)<To
                Int = sum(ParticleData.MaskData,3);
            else
                Int = sum(ParticleData.MaskData(:,:,From:To),3);
            end
        elseif h.Particle_Track_Per_Frame.Value
            Int = ParticleData.Data.Intensity(:,:,From:To);
            thre = 0.5;
        else
            %%% Use summed image
            Int = sum(ParticleData.Data.Intensity(:,:,From:To),3);
            thre = 1;
        end
        
        %% Get image size data
        [H, W, nFrames] = size(Int);
        thrIdx = round(TH_init*H*W); % index of threshold
        
        %% Extract properties of detected regions
        STATS = cell(nFrames, 1);
        for f = 1:nFrames
        
            %%% Wavelet filter ® P. Messer, 2016
            tempInt = Int(:,:,f);
            for i = 1:Wavelet-1
                % Convolution Kernel (a trous)
                kern = [1/16,zeros(1,2^(i-1)-1),1/4,zeros(1,2^(i-1)-1),...
                    3/8,zeros(1,2^(i-1)-1),1/4,zeros(1,2^(i-1)-1),1/16];
                
                % Perform convolution
                newInt = imfilter(tempInt, kern.*kern', 'symmetric', 'same', 'conv');
                
                wavIm = tempInt - newInt;
                
                % use convolution result for next loop
                tempInt = newInt;
            end
            
            %%% threshold with median absolute deviation
            medianAD = median(abs(wavIm(:)-median(wavIm(:)))); % Median Absolute Deviation
            sigma = medianAD/0.67; % std estimate from MAD
            wavIm(wavIm < 3*sigma) = 0; % Remove non-significant wavelet coefficients (k = 3)
            
            %%% Apply user-specified threshold
            sortedIm = sort(wavIm(:));
            thres = sortedIm(thrIdx,:) + thre;
            BitImage = wavIm > thres;
            
            %%% Calculates regionprops
            Regions = regionprops(BitImage,Int(:,:,f),'Eccentricity', 'PixelList','Area','PixelIdxList','MaxIntensity','MeanIntensity','PixelValues','Centroid');

            %%% Aborts calculation when no particles were detected
            if isempty(Regions)
                msgbox('No particles detected! Please change threshold.');
                return;
            end

            for ii=1:numel(Regions)
                %%% Calculate total counts
                Regions(ii).TotalCounts = Regions(ii).MeanIntensity.*Regions(ii).Area;

                %%% Correct PixelIdxList to apply to the whole stack instead of single frames
                Regions(ii).PixelIdxList = Regions(ii).PixelIdxList + (From+f-2)*(H*W);
            end

            %% Applies region criteria
            %%% Removes small and large regions
            area = cat(1, Regions.Area);
            Regions(area < MinSize | area > MaxSize)=[];

            %%% Removes dark and bright particles
            totalCounts = cat(1, Regions.TotalCounts);
            Regions(totalCounts < MinP | totalCounts > MaxP)=[];

            %%% Removes eccentric regions
            Regions(cat(1, Regions.Eccentricity) > Eccent)=[];

            %%% Save in cell array
            STATS{f} = Regions;
        end

        %% Link spots with SimpleTracker
        inputPoints = cellfun(@(x) vertcat(x.Centroid), STATS, 'UniformOutput', false);
        [tracks, adjTracks] = simpletracker(inputPoints,...
            'MaxGapClosing', str2double(h.Particle_Track_FrameSkip.String),...
            'MaxLinkingDistance', str2double(h.Particle_Track_MaxDist.String));
        regionPropertyNames = fieldnames(STATS{1}); % saves field names
        STATS = cellfun(@struct2cell, STATS, 'UniformOutput', false);
        STATS = cat(2, STATS{:});
        STATS = cellfun(@(x) STATS(:, x), adjTracks, 'UniformOutput', false);

        Part_Array = cell(numel(STATS), size(STATS{1}, 1)+1);
        for p = 1:numel(STATS)
            for q = 1:size(STATS{p}, 1)
                Part_Array{p, q} = cat(1, STATS{p}{q,:});
            end
            %%% frames (corrected for frame selection)
            Part_Array{p, q+1} = find(~isnan(tracks{p})) + From - 1;
        end

        %% Remove tracks below minimmum length
        if h.Particle_Track_Per_Frame.Value
            cellsize = cellfun('size', Part_Array(:,10), 1);
            Part_Array(cellsize < MinLength, :) = [];
        end

        %% Fill gaps in tracks
        if FillGaps
            Part_Array(:, 2) = cellfun(@(X, Y) interp1(X, Y, (X(1):X(end))'),...
                Part_Array(:, 10), Part_Array(:, 2), 'UniformOutput',false); % Centroid
            Part_Array(:, 3) = cellfun(@(X, Y) interp1(X, Y, (X(1):X(end))', 'previous'),...
                Part_Array(:, 10), Part_Array(:, 3), 'UniformOutput',false); % Eccentricity

            %%% interpolate roi positions and extract interpolated roi properties
            %%% [Area, PixelIdxList, PixelList, PixelValue, MeanInt, MaxInt, TotalCounts]
            [Part_Array(:, 1), Part_Array(:, 4), Part_Array(:, 5), Part_Array(:, 6),...
                Part_Array(:, 7), Part_Array(:, 8), Part_Array(:, 9), Part_Array(:, 10)]...
                = cellfun(@(X, Y) InterpPixel(X, Y, ParticleData.Data.Intensity),...
                Part_Array(:,4), Part_Array(:, 2), 'UniformOutput',false);     
        end

        %% Apply particle selection
        ParticleData.Regions = cell2struct(Part_Array,[regionPropertyNames;'Frame'],2);

        %%% Generate masks for plotting and phasor calculations
        ParticleData.Mask = false(size(ParticleData.Data.Intensity,1),size(ParticleData.Data.Intensity,2), To);
        ParticleData.Particle = zeros(size(ParticleData.Data.Intensity,1),size(ParticleData.Data.Intensity,2), To);
        for p = 1:numel(ParticleData.Regions)
            ParticleData.Mask(ParticleData.Regions(p).PixelIdxList) = true;
            ParticleData.Particle(ParticleData.Regions(p).PixelIdxList) = p;
        end

        %display('Tracking Done');
        msgbox('Tracking Done');
end

Plot_Particle([],[],2,h)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Extended Wavelet Method %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Method_Wavelets_Extended(~,~,mode)
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Is only called for updating the table/info
switch mode
    case 0
        %%% Updates Table
        TableData = {'Threshold [0-1]', 0.1;...
                    'Std dev scale factor (k)', 3;...
                    'Min Photons', 5;...
                    'Max Photons', 200;...
                    'Min Size [px]', 5;...
                    'Max Size [px]', 50;...
                    'Wavelet depth', 3;...
                    'Method [1: Prod; 2: Sum]', 1;... 
                    'Eccentricity', 0.8;...
                    'Min Track Length [fr]', 2;...
                    'Fill Gaps', true};

        ColumnNames = {'Parameter Name', 'Value'};

        h.Particle_Method_Settings.ColumnName = ColumnNames;
        h.Particle_Method_Settings.Data = TableData;

        %%% Updates Method information
        h.Particle_Method_Description.String =['Wavelet detection with more options. '...
            'Wavelet coefficients are filtered with k*std deviation of each wavelet. ',...
            'The product or sum of wavelet coefficients at depth>=2 ',...
            'is further thresholded to detect particles. ',...
            'Spot linking is done through Simple Tracker from JY Tinevez, ',...
            'which links particles using the Hungarian algorithm. ',...
            'Gaps due to missed detections can be filled using linear interpolation. '];

%%% Actual particle detection and averaging
    case 1
        %% Removed detected particle data
        if isfield(ParticleData,'Regions')
            ParticleData = rmfield(ParticleData,'Regions');
        end
        if isfield(ParticleData,'Mask')
            ParticleData = rmfield(ParticleData,'Mask');
        end
        if isfield(ParticleData,'Particle')
            ParticleData = rmfield(ParticleData,'Particle');
        end
        
        %% Extracts parameters
        TH_init = h.Particle_Method_Settings.Data{1,2};
        K = h.Particle_Method_Settings.Data{2,2};
        MinP = h.Particle_Method_Settings.Data{3,2};
        MaxP = h.Particle_Method_Settings.Data{4,2};
        MinSize = h.Particle_Method_Settings.Data{5,2};
        MaxSize = h.Particle_Method_Settings.Data{6,2};
        if MaxSize < MinSize || MaxSize == 0
            MaxSize = Inf;
        end
        Wavelet = h.Particle_Method_Settings.Data{7,2};
        Method = h.Particle_Method_Settings.Data{8,2};
        Eccent = h.Particle_Method_Settings.Data{9,2};
        MinLength = h.Particle_Method_Settings.Data{10,2};
        FillGaps = h.Particle_Method_Settings.Data{11,2} && MinLength >= 2 &&...
            h.Particle_Track_Per_Frame.Value;

        %%% Sets max size and intensity to Inf if values don't make sense
        if MaxP<MinP || MaxP==0
            MaxP = Inf;
        end
        if MaxSize < MinSize || MaxSize == 0
            MaxSize = Inf;
        end

        %% Get frame range
        From = str2double(h.Particle_Frames_Start.String);
        To = str2double(h.Particle_Frames_Stop.String);
        %%% Adjusts frame range to data
        if To>size(ParticleData.Data.Intensity,3)
            To = size(ParticleData.Data.Intensity,3);
            h.Particle_Frames_Stop.String = size(ParticleData.Data.Intensity,3);
        end
        if From > To
            From = 1;
            h.Particle_Frames_Start.String = 1;
        end

        %% Extracts regions
        %%% Averages image
        if h.Particle_Use_External_Mask.Value
            %%% Used external map if possible
            if ~isfield(ParticleData,'MaskData') ||...
                    size(ParticleData.MaskData,1)<size(ParticleData.Data.Intensity,1) ||...
                    size(ParticleData.MaskData,2)<size(ParticleData.Data.Intensity,2)

                Int = sum(ParticleData.Data.Intensity(:,:,From:To),3);
                h.Particle_Use_External_Mask.Value=0;
            elseif  size(ParticleData.MaskData,3)<To
                Int = sum(ParticleData.MaskData,3);
            else
                Int = sum(ParticleData.MaskData(:,:,From:To),3);
            end
        elseif h.Particle_Track_Per_Frame.Value
            Int = ParticleData.Data.Intensity(:,:,From:To);
        else
            %%% Use summed image
            Int = sum(ParticleData.Data.Intensity(:,:,From:To),3);
        end
        
        %% Get image size data
        [H, W, nFrames] = size(Int);
        
        %% Extract properties of detected regions
        STATS = cell(nFrames, 1);
        for f = 1:nFrames
        
            %%% Wavelet filter ® P. Messer, 2016
            tempInt = Int(:,:,f);
            w = zeros(H, W, Wavelet);
            for i = 1:Wavelet
                % Convolution Kernel (a trous)
                kern = [1/16,zeros(1,2^(i-1)-1),1/4,zeros(1,2^(i-1)-1),...
                    3/8,zeros(1,2^(i-1)-1),1/4,zeros(1,2^(i-1)-1),1/16];
                
                % Perform convolution
                newInt = imfilter(tempInt, kern.*kern', 'symmetric', 'same', 'conv');
                
                % Get wavelet
                tw = tempInt - newInt;
                
                %%% threshold with median absolute deviation
                medianAD = median(abs(tw(:)-median(tw(:)))); % Median Absolute Deviation
                sigma = medianAD/0.67; % std estimate from MAD
                tw(tw < K*sigma) = 0; % Remove non-significant wavelet coefficients
                w(:,:,i) = tw;
                
                % use convolution result for next loop
                tempInt = newInt;
            end
            
            %%% Take sum or product of wavelets
            switch Method
                case 1 %% product
                    P = prod(w(:,:,2:Wavelet), 3);
                case 2
                    P = sum(w(:,:,2:Wavelet), 3);
            end

            %%% Apply user-specified threshold
            sortedIm = sort(P(P > 0));
            thrIdx = round(TH_init * numel(sortedIm));
            if thrIdx == 0
                thrIdx = 1;
            end
            BitImage = P >= sortedIm(thrIdx);
            BitImage = bwmorph(BitImage, 'fill');
            
            %%% Calculates regionprops
            Regions = regionprops(BitImage,Int(:,:,f),'Eccentricity', 'PixelList','Area','PixelIdxList','MaxIntensity','MeanIntensity','PixelValues','Centroid');

            %%% if particles are detected
            if ~isempty(Regions)
                for ii=1:numel(Regions)
                    %%% Calculate total counts
                    Regions(ii).TotalCounts = Regions(ii).MeanIntensity.*Regions(ii).Area;
                    
                    %%% Correct PixelIdxList to apply to the whole stack instead of single frames
                    Regions(ii).PixelIdxList = Regions(ii).PixelIdxList + (From+f-2)*(H*W);
                end
                
                %% Applies region criteria
                %%% Removes small and large regions
                area = cat(1, Regions.Area);
                Regions(area < MinSize | area > MaxSize)=[];
                
                %%% Removes dark and bright particles
                totalCounts = cat(1, Regions.TotalCounts);
                Regions(totalCounts < MinP | totalCounts > MaxP)=[];
                
                %%% Removes eccentric regions
                Regions(cat(1, Regions.Eccentricity) > Eccent)=[];
            end
            %%% Save in cell array
            STATS{f} = Regions;
        end

        %% Link spots with SimpleTracker
        inputPoints = cellfun(@(x) vertcat(x.Centroid), STATS, 'UniformOutput', false);
        [tracks, adjTracks] = simpletracker(inputPoints,...
            'MaxGapClosing', str2double(h.Particle_Track_FrameSkip.String),...
            'MaxLinkingDistance', str2double(h.Particle_Track_MaxDist.String));
        regionPropertyNames = fieldnames(STATS{1}); % saves field names
        STATS = cellfun(@struct2cell, STATS, 'UniformOutput', false);
        STATS = cat(2, STATS{:});
        STATS = cellfun(@(x) STATS(:, x), adjTracks, 'UniformOutput', false);

        Part_Array = cell(numel(STATS), size(STATS{1}, 1)+1);
        for p = 1:numel(STATS)
            for q = 1:size(STATS{p}, 1)
                Part_Array{p, q} = cat(1, STATS{p}{q,:});
            end
            %%% frames (corrected for frame selection)
            Part_Array{p, q+1} = find(~isnan(tracks{p})) + From - 1;
        end

        %% Remove tracks below minimmum length
        if h.Particle_Track_Per_Frame.Value
            cellsize = cellfun('size', Part_Array(:,10), 1);
            Part_Array(cellsize < MinLength, :) = [];
        end

        %% Fill gaps in tracks
        if FillGaps
            Part_Array(:, 2) = cellfun(@(X, Y) interp1(X, Y, (X(1):X(end))'),...
                Part_Array(:, 10), Part_Array(:, 2), 'UniformOutput',false); % Centroid
            Part_Array(:, 3) = cellfun(@(X, Y) interp1(X, Y, (X(1):X(end))', 'previous'),...
                Part_Array(:, 10), Part_Array(:, 3), 'UniformOutput',false); % Eccentricity

            %%% interpolate roi positions and extract interpolated roi properties
            %%% [Area, PixelIdxList, PixelList, PixelValue, MeanInt, MaxInt, TotalCounts]
            [Part_Array(:, 1), Part_Array(:, 4), Part_Array(:, 5), Part_Array(:, 6),...
                Part_Array(:, 7), Part_Array(:, 8), Part_Array(:, 9), Part_Array(:, 10)]...
                = cellfun(@(X, Y) InterpPixel(X, Y, ParticleData.Data.Intensity),...
                Part_Array(:,4), Part_Array(:, 2), 'UniformOutput',false);     
        end

        %% Apply particle selection
        ParticleData.Regions = cell2struct(Part_Array,[regionPropertyNames;'Frame'],2);

        %%% Generate masks for plotting and phasor calculations
        ParticleData.Mask = false(size(ParticleData.Data.Intensity));
        ParticleData.Particle = zeros(size(ParticleData.Data.Intensity));
        for p = 1:numel(ParticleData.Regions)
            ParticleData.Mask(ParticleData.Regions(p).PixelIdxList) = true;
            ParticleData.Particle(ParticleData.Regions(p).PixelIdxList) = p;
        end

        %display('Tracking Done');
        msgbox('Tracking Done');
end

Plot_Particle([],[],2,h)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Here are all the different methods for applying ROI and saving the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Particle_Save(~,~)
h = guidata(findobj('Tag','Particle'));
switch h.Particle_Save_Method.Value
    case 1 %%% Save time sum
        Save_Averaged
    case 2 %%% Save FLIM trace
        Save_FLIM_Trace
    case 3 %%% Save Text
        Save_Text
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Averages the selected regions and frames and saves the FLIM image
function Save_Averaged
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Stops execution if data is not complete
if isempty(ParticleData) || ~isfield(ParticleData,'Regions')
    return;
end
%%% Select file names for saving
[FileName,PathName] = uiputfile('*.phr','Save Phasor Data', fullfile(ParticleData.PathName, ParticleData.FileName(1:end-4)));
%%% Checks, if selection was cancled
if all(FileName == 0)
    return;
end

%%% Uses summed up Image and Phasor
From = str2double(h.Particle_Frames_Start.String);
To = str2double(h.Particle_Frames_Stop.String);
%%% Adjusts frame range to data
if To>size(ParticleData.Data.Intensity,3)
    To = size(ParticleData.Data.Intensity,3);
    h.Particle_Frames_Stop.String = size(ParticleData.Data.Intensity,3);
end
if From > To
    From = 1;
    h.Particle_Frames_Start.String = 1;
end


Mask = logical(squeeze(sum(ParticleData.Mask,3)));
g = sum(ParticleData.Data.g(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);
s = sum(ParticleData.Data.s(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);
Intensity = sum(ParticleData.Data.Intensity(:,:,From:To),3);

%%% Applies particle averaging
for i=1:numel(ParticleData.Regions)
    %%% Calculates mean particle phasor
    ind = mod(ParticleData.Regions(i).PixelIdxList(1:ParticleData.Regions(i).Area(1)),numel(g));
    ParticleData.Regions(i).g = sum(g(ind).*Intensity(ind))./sum(Intensity(ind));
    ParticleData.Regions(i).s = sum(s(ind).*Intensity(ind))./sum(Intensity(ind));
    %%% Applies particle phasor to pixels
    g(ind) = ParticleData.Regions(i).g;
    s(ind) = ParticleData.Regions(i).s;
end

%%% Sets non-particle pixels to 0
if ~h.Particle_Use_NonParticle.Value
    g(~Mask) = 0;
    s(~Mask) = 0;
    Mean_LT(~Mask) = 0;
end

%%% Updates secondary parameters
Freq = ParticleData.Data.Freq;
Fi = atan(s./g); Fi(isnan(Fi)) = 0;
M = sqrt(s.^2+g.^2);Fi(isnan(M)) = 0;
TauP = real(tan(Fi)./(2*pi*Freq/10^9)); TauP(isnan(TauP)) = 0; %#ok<*NASGU>
TauM = real(sqrt((1./(s.^2+g.^2))-1)/(2*pi*Freq/10^9)); TauM(isnan(TauM)) = 0;
Mean_LT = sum(ParticleData.Data.Mean_LT(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);
Lines = ParticleData.Data.Lines;
Pixels = ParticleData.Data.Pixels;
Imagetime = ParticleData.Data.Imagetime;
Frames = To-From+1;
FileNames = ParticleData.Data.FileNames;
Type = ParticleData.Data.Type;
Regions =ParticleData.Regions;
Path = ParticleData.Data.Path;

save(fullfile(PathName,FileName), 'g','s','Mean_LT','Fi','M','TauP','TauM','Intensity','Lines','Pixels','Freq','Imagetime','Frames','FileNames','Path','Type','Regions');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Save the FLIM data as a trace for each (static) region over time
function Save_FLIM_Trace
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Stops execution if data is not complete
if isempty(ParticleData) || ~isfield(ParticleData,'Regions')
    return;
end
%%% Select file names for saving
[FileName,PathName] = uiputfile('*.phr','Save Phasor Data', fullfile(ParticleData.PathName, ParticleData.FileName(1:end-4)));
%%% Checks, if selection was cancled
if all(FileName == 0)
    return;
end

%%% Uses summed up Image and Phasor
From = str2double(h.Particle_Frames_Start.String);
To = str2double(h.Particle_Frames_Stop.String);
Frames_Sum = str2double(h.Particle_Frames_Sum.String);
%%% Adjusts frame range to data
if To>size(ParticleData.Data.Intensity,3)
    To = size(ParticleData.Data.Intensity,3);
    h.Particle_Frames_Stop.String = size(ParticleData.Data.Intensity,3);
end
if From > To
    From = 1;
    h.Particle_Frames_Start.String = 1;
end


%%% Applies particle averaging
Int = ParticleData.Data.Intensity(:,:,From:To);
G = ParticleData.Data.g(:,:,From:To).*Int; %%%unnormalized g
S = ParticleData.Data.s(:,:,From:To).*Int; %%%unnormalized s

%%% Creates arrays with size(Particle,Frames)
g=NaN(numel(ParticleData.Regions),To-From+1);
s=NaN(numel(ParticleData.Regions),To-From+1);
Intensity=NaN(numel(ParticleData.Regions),To-From+1);

%%%Calculates frame-wise average for each particle
for i=1:numel(ParticleData.Regions)
    %%% Extends PixelId for every frame
    % PixelId = repmat((0:(size(g,2)-1))*numel(Int(:,:,1)),numel(ParticleData.Regions(i).PixelIdxList),1);
    % PixelId = PixelId + repmat(ParticleData.Regions(i).PixelIdxList,1,size(g,2));
    %%% 
    % Intensity(i,:)=sum(Int(PixelId),1);
    PixelId = ParticleData.Regions(i).PixelIdxList - (From-1)*size(Int, 1)*size(Int, 2);
    Intensity(i,ParticleData.Regions(i).Frame)=ParticleData.Regions(i).TotalCounts';
    [~,~,z] = ind2sub(size(Int),PixelId);
    G_temp = mat2cell(G(PixelId),histcounts(z,[1:max(z),Inf]),1);
    d = cellfun('isempty',G_temp);
    g(i,ParticleData.Regions(i).Frame) = cellfun(@(x)sum(x,'omitnan'),G_temp(~d));
    S_temp = mat2cell(S(PixelId),histcounts(z,[1:max(z),Inf]),1);
    ds = cellfun('isempty',S_temp);
    s(i,ParticleData.Regions(i).Frame) = cellfun(@(x)sum(x,'omitnan'),S_temp(~ds));
    % g(i,:)=sum(G(PixelId),1); %%%unnormalized g
    % s(i,:)=sum(S(PixelId),1); %%%unnormalized s
    
    %Intensity(i,:)= squeeze(sum(sum(Int(ParticleData.Regions(i).PixelList(:,2),ParticleData.Regions(i).PixelList(:,1),:),1),2));
    %g(i,:)= squeeze(sum(sum(G(ParticleData.Regions(i).PixelList(:,2),ParticleData.Regions(i).PixelList(:,1),:),1),2));
    %s(i,:)= squeeze(sum(sum(S(ParticleData.Regions(i).PixelList(:,2),ParticleData.Regions(i).PixelList(:,1),:),1),2));
end
truepart = sum(~isnan(s),2)>0;
Intensity(~truepart,:) = [];
s(~truepart,:) = [];
g(~truepart,:) = [];

%%% Cuts size to a multiple of the Frames_Sum
Intensity= Intensity(:,1:(floor(size(Intensity,2)/Frames_Sum))*Frames_Sum);
g= g(:,1:(floor(size(Intensity,2)/Frames_Sum))*Frames_Sum);
s= s(:,1:(floor(size(Intensity,2)/Frames_Sum))*Frames_Sum);
%%% Summs up frame range
Intensity = squeeze(sum(reshape(Intensity,size(Intensity,1),Frames_Sum,[]),2,'omitnan'));
g = squeeze(sum(reshape(g,size(g,1),Frames_Sum,[]),2,'omitnan'))./Intensity; %%% normalized g
s = squeeze(sum(reshape(s,size(s,1),Frames_Sum,[]),2,'omitnan'))./Intensity; %%% normalized s
Intensity(isnan(Intensity))=0;
g(isnan(g))=0;
s(isnan(s))=0;

%%% Updates secondary parameters
Freq = ParticleData.Data.Freq;
Fi = atan(s./g); Fi(isnan(Fi)) = 0;
M = sqrt(s.^2+g.^2);Fi(isnan(M)) = 0;
TauP = real(tan(Fi)./(2*pi*Freq/10^9)); TauP(isnan(TauP)) = 0; %#ok<*NASGU>
TauM = real(sqrt((1./(s.^2+g.^2))-1)/(2*pi*Freq/10^9)); TauM(isnan(TauM)) = 0;
Mean_LT = sum(ParticleData.Data.Mean_LT(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);
Lines = ParticleData.Data.Lines;
Pixels = ParticleData.Data.Pixels;
Imagetime = ParticleData.Data.Imagetime;
Frames = Frames_Sum;
FileNames = ParticleData.Data.FileNames;
Type = ParticleData.Data.Type;
Regions =ParticleData.Regions(truepart); % removes particle regions with invalid phasor information
Path = ParticleData.Data.Path;

save(fullfile(PathName,FileName), 'g','s','Mean_LT','Fi','M','TauP','TauM','Intensity','Lines','Pixels','Freq','Imagetime','Frames','FileNames','Path','Type','Regions');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Save the particle data as a text or excel file
function Save_Text
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Stops execution if data is not complete
if isempty(ParticleData) || ~isfield(ParticleData,'Regions')
    return;
end
%%% Select file names for saving
[FileName,PathName, FilterIndex] = uiputfile({'*.txt';'*.csv';'*.xlsx';},'Save Particle Data', fullfile(ParticleData.PathName, ParticleData.FileName(1:end-4)));
%%% Checks, if selection was cancled
if all(FileName == 0)
    return;
end

%%% Uses summed up Image and Phasor
From = str2double(h.Particle_Frames_Start.String);
To = str2double(h.Particle_Frames_Stop.String);
%%% Adjusts frame range to data
if To>size(ParticleData.Data.Intensity,3)
    To = size(ParticleData.Data.Intensity,3);
    h.Particle_Frames_Stop.String = size(ParticleData.Data.Intensity,3);
end
if From > To
    From = 1;
    h.Particle_Frames_Start.String = 1;
end

Mask = logical(squeeze(sum(ParticleData.Mask,3)));
g = sum(ParticleData.Data.g(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);
s = sum(ParticleData.Data.s(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);
Intensity = sum(ParticleData.Data.Intensity(:,:,From:To),3);

%%% Applies particle averaging
G=zeros(numel(ParticleData.Regions),1);
S=zeros(numel(ParticleData.Regions),1);
x=zeros(numel(ParticleData.Regions),1);
y=zeros(numel(ParticleData.Regions),1);
for i=1:numel(ParticleData.Regions)
    %%% Calculates mean particle phasor
    G(i) = sum(ParticleData.Data.g(ParticleData.Regions(i).PixelIdxList).*ParticleData.Data.Intensity(ParticleData.Regions(i).PixelIdxList))...
        ./sum(ParticleData.Data.Intensity(ParticleData.Regions(i).PixelIdxList));
    S(i) = sum(ParticleData.Data.s(ParticleData.Regions(i).PixelIdxList).*ParticleData.Data.Intensity(ParticleData.Regions(i).PixelIdxList))...
        ./sum(ParticleData.Data.Intensity(ParticleData.Regions(i).PixelIdxList));
    %%% Extracts first pixel position of each particle
    x(i) = ParticleData.Regions(i).PixelList(1,1);
    y(i) = ParticleData.Regions(i).PixelList(1,2);
    %%% Calculate particle properties
    TotalCounts(i) = sum(ParticleData.Regions(i).TotalCounts);
    MeanIntensity(i) = mean(ParticleData.Regions(i).MeanIntensity);
    MaxIntensity(i) = max(ParticleData.Regions(i).MaxIntensity);
    Area(i) = mean(ParticleData.Regions(i).Area);
end

%%% Calculate lifetimes from phasor
Freq = repmat(ParticleData.Data.Freq,size(G));
Fi = atan(S./G);
M = sqrt(S.^2+G.^2);
TauP = real(tan(Fi)./(2*pi*Freq/10^9));
TauM = real(sqrt((1./(S.^2+G.^2))-1)./(2*pi*Freq/10^9));

VarNames = {'TauP','TauM','TotalPhotons','MeanPhotons','MaxPhotons','Area','x','y','s','g','Frequency'};
%%% Creates table variable for saving
tab = table(TauP,... Phase based lifetime
            TauM,... Modulation based lifetime
            TotalCounts.',... Total photons of particle
            MeanIntensity.',... Average photons per pixel
            MaxIntensity.',... Brightest pixel counts
            Area.',... Particle area in photons
            x,... x position of first pixel
            y,... y position of first pixel
            S,... S value of particle
            G,... G value of particle
            Freq,... %%% Measurement frequency, e.g. 1/TAC
            'VariableNames',VarNames);

%%% Saves data as text or table
if FilterIndex == 1 %%% Use tab sepparation for .txt files
    writetable(tab,fullfile(PathName,FileName),'Delimiter','tab');
else
    writetable(tab,fullfile(PathName,FileName));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Collection of various small functions
function Misc(Obj,~)
h = guidata(findobj('Tag','Particle'));
global ParticleData
switch Obj
    case h.Particle_Save_Method %%% Toggle frame summing visibility
        if h.Particle_Save_Method.Value == 2
            h.Particle_Frames_Sum.Visible = 'on';
            h.Particle_Frames_Sum_Text.Visible = 'on';
        else
            h.Particle_Frames_Sum.Visible = 'off';
            h.Particle_Frames_Sum_Text.Visible = 'off';
        end
    case h.Particle_Use_External_Mask %%% Turns off External Maks if empty
        if ~isfield(ParticleData,'MaskData')
            h.Particle_Use_External_Mask.Value = 0;
        end
        Plot_Particle([],[],2,h);
    case h.Particle_Track_Per_Frame %%% Toggle frame summing visibility
        if h.Particle_Track_Per_Frame.Value
            h.Particle_Track_FrameSkip.Visible = 'on';
            h.Particle_Track_MaxDist.Visible = 'on';
            h.Particle_Track_Frame_Text.Visible = 'on';
            h.Particle_Track_Dist_Text.Visible = 'on';
        else
            h.Particle_Track_FrameSkip.Visible = 'off';
            h.Particle_Track_MaxDist.Visible = 'off';
            h.Particle_Track_Frame_Text.Visible = 'off';
            h.Particle_Track_Dist_Text.Visible = 'off';
        end
end
